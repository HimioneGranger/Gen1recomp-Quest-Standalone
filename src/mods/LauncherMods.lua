-- Launcher-side mod surface (18/launcher redesign): the mods panel runs
-- BEFORE Game:load, so this NEVER loads a mod entry chunk -- it scans
-- manifests only.  The full loader (src/mods/Loader.lua) still owns the real
-- load at boot; this reads the same options.mods enable-state the loader
-- writes, derives per-mod status with the pure ManagerState.resolveToggle,
-- installs a dropped/chosen .zip into a "mods/<id>/" tree, and uninstalls a
-- mod by removing that tree + clearing options.mods[id].
--
-- Where that tree lives is CacheFs's call, not love.filesystem's: a portable
-- install (portable.txt beside the executable) keeps its mods in the game
-- folder like everything else it owns, and only the OS save directory
-- otherwise (#330 -- love.filesystem.write always resolves to the save dir,
-- so the installer used to strand every mod in appdata).  Reads stay on
-- love.filesystem: the portable folder is on the physfs read path either way
-- (it IS the source for a `love <gamedir>` run, and CacheFs mounts it for a
-- fused build), which is why those mods still loaded while landing in the
-- wrong place.
--
-- The same split decides where a mod is FOUND, and that has a sharp edge: a
-- non-portable install never reads the game folder at all, so a mod unzipped
-- next to the executable -- where most games would want it -- is not wrong so
-- much as invisible, with an empty panel and no error to explain it.
-- adoptStrays looks in those folders anyway (a scoped mount that comes down
-- again, CacheFs.withMounted) and copies what it finds into the tree the game
-- really reads, so the mistake costs a line of notice rather than a support
-- thread.
--
-- Split in two: the pure derivation (deriveList, locateRoot, pickStrays) has
-- no love and no filesystem, so the engine tier can table-drive it; the
-- discovery, install, uninstall, and stray-scan paths reach for
-- love.filesystem and SaveData.

local Manifest = require("src.mods.Manifest")
local ManagerState = require("src.mods.ManagerState")
local ModTargets = require("src.mods.ModTargets")
local Semver = require("src.mods.Semver")
local Version = require("src.core.Version")
local SaveData = require("src.core.SaveData")
local GameVersion = require("src.core.GameVersion")
local CacheFs = require("src.import.CacheFs")

local LauncherMods = {}

-- ------- pure status derivation

-- A hard-dependency / conflict / version verdict for one manifest.  mods is
-- the id -> validated-manifest map resolveToggle reads (its dependencySpecs,
-- conflictSpecs, version and game_version are exactly the fields the loader's
-- Manifest.validate produced); enabledSet is the current desired enable-set.
local function statusFor(mods, id, enabledSet, enabled, version, forcedFor)
  local m = mods[id]
  local forced = forcedFor(id)
  -- The game this mod is for outranks everything below it: a mod that is not
  -- going to run here has no useful conflict or dependency verdict.  Same
  -- source as the in-game manager (src/mods/ModTargets.lua), so the two
  -- surfaces cannot disagree about the same mod.
  if version and not ModTargets.supports(m, version) then
    if forced then
      return "warn", "Forced onto " .. ModTargets.gameLabel(version)
        .. " by you (untested)"
    end
    return "other_game", ModTargets.detail(m, version)
  end
  -- conflict only bites an enabled mod: resolveToggle's conflict list is
  -- bidirectional (this mod's conflicts spec vs an enabled other, and an
  -- enabled other's spec vs this mod), which is exactly the launcher chip.
  if enabled then
    local r = ManagerState.resolveToggle(mods, id, true, enabledSet)
    if #r.conflicts > 0 then
      local otherId = r.conflicts[1]
      local other = mods[otherId]
      return "conflict",
        "Conflicts with " .. ((other and other.name) or otherId)
    end
  end
  -- warn: the engine is outside the mod's game_version range.  The dev
  -- placeholder is skipped here exactly as Loader.devEngine skips it, so the
  -- launcher and the loader cannot disagree about the same mod.
  if m.game_version and Version.engine:match("^0%.0%.0%-") == nil
      and not Semver.satisfies(Version.engine, m.game_version) then
    return "warn", "Needs engine " .. m.game_version
      .. " (have " .. Version.engine .. ")"
  end
  -- warn: a hard dependency is absent, switched off, or the wrong version.
  -- resolveToggle would cascade-enable a merely-disabled dep rather than flag
  -- it, so the disabled case is judged straight off the manifest here.
  for _, spec in ipairs(m.dependencySpecs or {}) do
    local dep = mods[spec.id]
    if not dep then
      return "warn", "Needs " .. spec.id .. " (not installed)"
    elseif not enabledSet[spec.id] then
      return "warn", "Needs " .. spec.id .. " (disabled)"
    -- installed and on, but not for THIS game: the loader skips the
    -- dependency and the skip is contagious (Loader:_enforceDependencies),
    -- so a mod that runs everywhere still does not run here
    elseif version
        and not ModTargets.runsHere(dep, version, nil, forcedFor(spec.id)) then
      return "warn", "Needs " .. spec.id .. " (not for "
        .. ModTargets.gameLabel(version) .. ")"
    elseif spec.range
        and not Semver.satisfies(dep.version, spec.range) then
      return "warn", "Needs " .. spec.id .. " " .. spec.range
    end
  end
  return "ok", "Ready"
end

-- deriveList(manifests, options [, version]) -> the panel row list, pure.
-- manifests is an array of validated manifests (Manifest.validate output);
-- options is the options table (options.mods, options.modsByVersion and
-- options.modsGen2 are read).  `version` is the game the panel is showing;
-- each row also carries its answer for every game so the launcher can render
-- the coloured game checkboxes together.
-- Rows come back sorted by id so the panel order is stable.
function LauncherMods.deriveList(manifests, options, version)
  local ordered = {}
  for _, m in ipairs(manifests) do ordered[#ordered + 1] = m end
  table.sort(ordered, function(a, b) return a.id < b.id end)

  -- the override is one answer per game (SaveData.modForced), the same scope
  -- the loader resolves it under
  local forcedFor = function(id)
    return version and SaveData.modForced(options, id, version) or false
  end
  local byId, enabledSet = {}, {}
  for _, m in ipairs(ordered) do
    byId[m.id] = m
    -- this game's choice, then the shared flag, then the default: enabled,
    -- matching the loader -- except experimental mods, which stay off until
    -- the player opts in.  Scoped through modScope, so this reads exactly what
    -- setEnabled writes and the loader loads for the selected game.
    local decided = SaveData.modEnabled(options, m.id, SaveData.modScope(version))
    if decided == nil then decided = not m.experimental end
    if decided then enabledSet[m.id] = true end
  end

  local out = {}
  for _, m in ipairs(ordered) do
    local enabled = enabledSet[m.id] == true
    local forced = forcedFor(m.id)
    local status, detail =
      statusFor(byId, m.id, enabledSet, enabled, version, forcedFor)
    -- nil, not false, when the panel is showing every game at once
    local here = nil
    if version then here = ModTargets.runsHere(m, version, nil, forced) end
    local raw = m.raw or {}
    local badge = tostring(raw.category or m.profile or "MOD"):upper()
    if m.experimental then badge = "EXPERIMENTAL" end
    out[#out + 1] = {
      id = m.id,
      name = m.name or m.id,
      version = m.version,
      badge = badge,
      description = m.description or "",
      enabled = enabled,
      enabledByVersion = (function()
        local answers = {}
        for _, game in ipairs(GameVersion.ORDER) do
          local answer = SaveData.modEnabled(options, m.id, game)
          answers[game] = answer == true or (answer == nil and not m.experimental)
        end
        return answers
      end)(),
      status = status,
      statusDetail = detail,
      github = m.github,
      experimental = m.experimental == true,
      -- what game this mod is for, and whether it will run on the one the
      -- panel is showing (src/mods/ModTargets.lua)
      targets = ModTargets.chip(m),
      targetsHere = here,
    }
  end
  return out
end

-- locateRoot(paths) -> the mod-root prefix inside a mounted archive, pure.
-- paths is a shallow listing: top-level file names as-is, and for a top-level
-- directory a "<dir>/manifest.json" entry when it holds one.  Returns "" when
-- the manifest sits at the archive root, "<dir>" when a single top-level
-- folder holds it, or nil + a user-presentable reason.
function LauncherMods.locateRoot(paths)
  for _, p in ipairs(paths) do
    if p == "manifest.json" then return "" end
  end
  local topDirs, seen, hasManifest = {}, {}, {}
  for _, p in ipairs(paths) do
    local top, rest = p:match("^([^/]+)/(.+)$")
    if top then
      if not seen[top] then
        seen[top] = true
        topDirs[#topDirs + 1] = top
      end
      if rest == "manifest.json" then hasManifest[top] = true end
    end
  end
  if #topDirs == 1 and hasManifest[topDirs[1]] then return topDirs[1] end
  if #topDirs > 1 then
    return nil, "the .zip must contain a single mod folder"
  end
  return nil, "no manifest.json found in the .zip"
end

-- pickStrays(found, installed) -> the rows worth adopting, pure.
-- found is an array of { id, name, folder, path } in scan order (game folder
-- order, then directory order); installed is the id -> true set of what the
-- game can already see.  An installed id is dropped -- the player has a
-- working copy and the loose folder is just where they first put it -- and a
-- duplicate id across two game folders keeps the first, the same first-wins
-- rule discover() uses.  Sorted by id so the notice reads the same every time.
function LauncherMods.pickStrays(found, installed)
  installed = installed or {}
  local out, seen = {}, {}
  for _, row in ipairs(found or {}) do
    local id = row.id
    if id and not installed[id] and not seen[id] then
      seen[id] = true
      out[#out + 1] = { id = id, name = row.name or id,
                        folder = row.folder, path = row.path }
    end
  end
  table.sort(out, function(a, b) return a.id < b.id end)
  return out
end

-- isReadableRoot(folder, source, cacheRoot) -> is folder already on the
-- physfs read path, pure.  source is love.filesystem.getSource(), cacheRoot
-- the mounted portable game folder (CacheFs.root()); a fused build has both,
-- and they are different paths (the archive inside the executable vs the
-- folder beside it).  Either one's mods/ is readable already, so nothing in
-- it is a stray -- and the portable folder must additionally never be handed
-- to CacheFs.withMounted: PHYSFS_mount reports success for a directory
-- already in the search path WITHOUT adding a second entry, so the paired
-- unmount tears down the one real mount and the panel loses every mod in the
-- game folder (#413).
function LauncherMods.isReadableRoot(folder, source, cacheRoot)
  if not folder or folder == "" then return false end
  return folder == source or folder == cacheRoot
end

-- ------- discovery (love.filesystem)

local function decodeManifest(raw, path)
  local Json = require("src.link.Json")
  local data, decodeErr = Json.decode(raw)
  if not data then return nil, decodeErr end
  local ok, manifest = pcall(Manifest.validate, data, path)
  if not ok then return nil, manifest end
  return manifest
end

-- Scan "mods/" one level deep for valid manifests (mirrors Loader:_discover,
-- but validates only -- no entry chunk is ever loaded).  First id wins on a
-- duplicate.  Returns an array of validated manifests.
local function discover()
  local fs = love and love.filesystem
  local out = {}
  if not (fs and fs.getInfo and fs.getDirectoryItems) then return out end
  -- A fused portable build keeps its mods in the game folder next to the
  -- executable; resolving the cache root is what mounts that folder onto the
  -- physfs read path, so this is what makes those mods enumerable at all
  -- (#330).  A source run needs nothing (the game folder IS the source), and
  -- the launcher's readiness check has usually resolved it already; the call
  -- is cached and idempotent.
  CacheFs.root()
  if not fs.getInfo("mods") then return out end
  local seen = {}
  for _, name in ipairs(fs.getDirectoryItems("mods")) do
    local path = "mods/" .. name
    local info = fs.getInfo(path)
    -- a dev-linked mod dir (ln -s) reports type "symlink" even with
    -- setSymlinksEnabled(true); see the matching note in Loader:_discover.
    if info and (info.type == "directory" or info.type == "symlink") then
      local raw = fs.read(path .. "/manifest.json")
      if raw then
        local manifest = decodeManifest(raw, path)
        if manifest and not seen[manifest.id] then
          seen[manifest.id] = true
          out[#out + 1] = manifest
        end
      end
    end
  end
  return out
end

-- list([version]) -> the mods-panel rows for the current install.  Reads the
-- same enable-state the loader persists, so a toggle here is what the game
-- sees on its next boot; `version` narrows that to one game's answers.
function LauncherMods.list(version)
  local ok, result = pcall(function()
    local options = SaveData.loadOptions()
    local manifests = discover()
    -- The first build containing game-specific switches turns the old shared
    -- state into one explicit answer per installed mod and game.  Saving here
    -- means users who only visit the launcher still receive the migration.
    if SaveData.migrateModEnablement(options, manifests) then
      SaveData.saveOptions(options)
    end
    return LauncherMods.deriveList(manifests, options, version)
  end)
  if not ok then
    -- a single bad options/mod file must not blank the launcher
    return {}
  end
  return result or {}
end

-- ------- pre-boot translation strings
--
-- The launcher draws before Game:load, so the loader has not run and Strings
-- has no catalog.  #767/#791 routed the launcher's text through Strings, but
-- nothing filled the catalog this early, so a translation mod still could not
-- reach the launcher however complete it was -- and no restart helped, because
-- the ordering is the same on every launch.
--
-- This fills it, and deliberately does the smallest thing that can: one
-- declarative file per enabled mod, lang/strings.lua, and never the entry
-- chunk.  That keeps the promise the rest of this module is built on -- no mod
-- behaviour runs before the game boots -- because a catalog is data.
--
-- It is still a mod-authored chunk, so it runs with an empty environment: a
-- plain `return { ... }` evaluates fine, while anything reaching for love, io
-- or os raises and is skipped rather than being trusted this early.
--
-- Game:load calls Strings.load(Data) again after the real merge, which
-- replaces whatever this installed, so the two never disagree for long.
local STRINGS_CATALOG = "lang/strings.lua"

local function readStringsCatalog(path)
  local fs = love and love.filesystem
  if not (fs and fs.read) then return nil end
  local rel = path .. "/" .. STRINGS_CATALOG
  local raw = fs.read(rel)
  if type(raw) ~= "string" or raw == "" then return nil end
  local chunk = loadstring(raw, "@" .. rel)
  if not chunk then return nil end
  -- Lua 5.1/LuaJIT: no _ENV, so setfenv is the sandbox.
  if setfenv then setfenv(chunk, {}) end
  local ok, result = pcall(chunk)
  if not ok or type(result) ~= "table" then return nil end
  return result
end

-- deriveStrings(rows, byId, read) -> the merged catalog, pure.
-- rows is deriveList's output, byId the id -> manifest map, and read(path) a
-- reader returning that mod's catalog table (or nil).  Split out so the engine
-- tier can table-drive the enable/precedence rules with no filesystem.
function LauncherMods.deriveStrings(rows, byId, read)
  local out, any = {}, false
  for _, row in ipairs(rows or {}) do
    local manifest = row.enabled and byId and byId[row.id] or nil
    local catalog = manifest and manifest.path and read(manifest.path)
    for source, value in pairs(catalog or {}) do
      -- an empty value means "not translated yet", never "translate to
      -- blank" -- the same rule the mod's own loader applies
      if type(source) == "string" and type(value) == "string"
          and value ~= "" then
        out[source] = value
        any = true
      end
    end
  end
  return any and out or nil
end

-- translationStrings() -> a source -> translation map for the launcher, or nil
-- when no enabled mod ships one.  Enable-state and ordering are deriveList's,
-- so a mod that wins a key here wins it at boot too.
function LauncherMods.translationStrings()
  local ok, merged = pcall(function()
    local manifests = discover()
    if #manifests == 0 then return nil end
    local rows = LauncherMods.deriveList(manifests, SaveData.loadOptions())
    local byId = {}
    for _, m in ipairs(manifests) do byId[m.id] = m end
    return LauncherMods.deriveStrings(rows, byId, readStringsCatalog)
  end)
  if not ok then return nil end
  return merged
end

-- setEnabled(id, enabled [, version]): with a game, persist just that game's
-- answer.  The loader and the in-game manager use the same scope on next boot.
function LauncherMods.setEnabled(id, enabled, version)
  local options = SaveData.loadOptions()
  SaveData.setModEnabled(options, id, enabled, SaveData.modScope(version))
  SaveData.saveOptions(options)
  return true
end

-- setAllEnabled(ids, enabled [, version]): the launcher's Enable all / Disable
-- all buttons (#647).  Writes what setEnabled writes, but loads and
-- saves once for the whole list: saveOptions rewrites the whole options file per
-- call, so looping setEnabled over a big mods folder is one disk write per mod
-- and leaves a half-applied state behind if one of them fails.
function LauncherMods.setAllEnabled(ids, enabled, version)
  local options = SaveData.loadOptions()
  local scope = SaveData.modScope(version)
  for _, id in ipairs(ids or {}) do
    if scope then
      SaveData.setModEnabled(options, id, enabled, scope)
    elseif SaveData.PER_VERSION_MODS then
      for _, game in ipairs(GameVersion.ORDER) do
        SaveData.setModEnabled(options, id, enabled, game)
      end
    else
      SaveData.setModEnabled(options, id, enabled)
    end
  end
  SaveData.saveOptions(options)
  return true
end

-- ------- install (love.filesystem)

-- Read a .zip source into bytes.  Save-dir-relative paths (inbox /
-- picked_mod.zip) prefer love.filesystem so NX/Android never hit a cwd-relative
-- io.open that can see a different file than PhysFS.  Absolute host paths
-- (desktop picker) still use io.*.  DroppedFile matches RomImporter ROM drops.
local function isHostAbsolutePath(path)
  return type(path) == "string" and (
      path:match("^/")
      or path:match("^%a:[/\\]")
      or path:match("^[Ss][Dd][Mm][Cc]:")
    )
end

local function readArchive(source, maxBytes, label)
  local function tooLarge(size)
    if maxBytes and size and size > maxBytes then
      return nil, (label or "archive") .. " is larger than the "
        .. tostring(maxBytes) .. " byte import limit"
    end
  end
  local t = type(source)
  if (t == "userdata" or t == "table") and type(source.open) == "function" then
    local size = type(source.getSize) == "function" and source:getSize() or nil
    local ok, err = tooLarge(size)
    if not ok and err then return nil, err end
    local ok = source:open("r")
    if not ok then return nil, "could not open the dropped file" end
    local data = source:read(source:getSize())
    source:close()
    if not data then return nil, "the dropped file could not be read" end
    ok, err = tooLarge(#data)
    if not ok and err then return nil, err end
    return data
  end
  if t == "string" then
    if not isHostAbsolutePath(source) and love and love.filesystem then
      local info = love.filesystem.getInfo and love.filesystem.getInfo(source)
      local ok, err = tooLarge(info and info.size)
      if not ok and err then return nil, err end
      local data = love.filesystem.read(source)
      if data then
        ok, err = tooLarge(#data)
        if not ok and err then return nil, err end
        return data
      end
    end
    local f = io.open(source, "rb")
    if f then
      if maxBytes then
        local size = f:seek("end")
        f:seek("set", 0)
        local ok, err = tooLarge(size)
        if not ok and err then f:close(); return nil, err end
      end
      local data = f:read("*a")
      f:close()
      if not data then return nil, "could not read " .. source end
      local ok, err = tooLarge(#data)
      if not ok and err then return nil, err end
      return data
    end
    if love and love.filesystem then
      local info = love.filesystem.getInfo and love.filesystem.getInfo(source)
      local ok, err = tooLarge(info and info.size)
      if not ok and err then return nil, err end
      local data = love.filesystem.read(source)
      if data then
        ok, err = tooLarge(#data)
        if not ok and err then return nil, err end
        return data
      end
    end
    return nil, "could not open " .. source
  end
  return nil, "unsupported archive source"
end

-- Local PK\3\4 / empty-file check before mount (corrupt MTP / AppleDouble).
local function zipLooksValid(data)
  if type(data) ~= "string" or #data < 4 then return false end
  return data:sub(1, 2) == "PK"
end

-- Shallow listing of a mounted archive shaped for locateRoot: files by name,
-- and for each top-level directory a "<dir>/manifest.json" marker only when it
-- actually holds one (so a lone folder with no manifest still reads as empty).
local function topLevelPaths(mount)
  local fs = love.filesystem
  local paths = {}
  for _, name in ipairs(fs.getDirectoryItems(mount)) do
    local info = fs.getInfo(mount .. "/" .. name)
    if info and info.type == "directory" then
      if fs.getInfo(mount .. "/" .. name .. "/manifest.json", "file") then
        paths[#paths + 1] = name .. "/manifest.json"
      end
    else
      paths[#paths + 1] = name
    end
  end
  return paths
end

-- Copy the mounted archive subtree at `src` to the install path `dst`.  Reads
-- come from love.filesystem (the .zip is mounted there); every write goes
-- through CacheFs so it lands in the portable game folder when portable.txt is
-- in play and in the OS save directory otherwise (#330).  No explicit mkdir:
-- CacheFs.write creates the parent chain on both paths, which also means an
-- empty folder inside the .zip is simply not carried over (it holds nothing).
local function copyTree(src, dst, onFile)
  local fs = love.filesystem
  for _, name in ipairs(fs.getDirectoryItems(src)) do
    local s = src .. "/" .. name
    local d = dst .. "/" .. name
    local info = fs.getInfo(s)
    if info and info.type == "directory" then
      local ok, err = copyTree(s, d, onFile)
      if not ok then return nil, err end
    else
      local data = fs.read(s)
      if data == nil then return nil, "could not read " .. name end
      local ok, err = CacheFs.write(d, data)
      if not ok then return nil, "could not write " .. name .. ": " .. tostring(err) end
      if onFile then onFile(#data) end
    end
  end
  return true
end

-- Delete an installed mod subtree.  Enumeration stays on love.filesystem (the
-- portable game folder is on its read path), but the deletes go through
-- CacheFs so a portable install's real files actually go away instead of
-- love.filesystem no-opping outside the save directory (#330).  Directories
-- are removed after their children, since rmdir refuses a non-empty one.
local function removeTree(path)
  local fs = love.filesystem
  local info = fs.getInfo(path)
  if not info then return end
  if info.type == "directory" then
    for _, child in ipairs(fs.getDirectoryItems(path)) do
      removeTree(path .. "/" .. child)
    end
    CacheFs.removeDir(path)
  else
    CacheFs.remove(path)
  end
  -- A portable install can still be carrying a pre-#330 copy in the OS save
  -- directory, which is where every install used to land and which physfs
  -- searches first.  CacheFs only touched the game folder, so clear the
  -- save-directory twin too or that copy would keep the mod alive; outside
  -- portable mode this repeats the delete CacheFs just did and no-ops.
  fs.remove(path)
end

-- Every mods/ folder currently holding this id, plus the bare mods/<id> tree
-- even when its manifest is missing or unreadable.  Second return: whether any
-- of them carries a manifest the panel can actually list.  An install names
-- its dest after the manifest id, but a hand-unzipped copy keeps whatever
-- folder name the archive carried, and discover()'s first-id-wins rule means
-- whichever folder physfs happens to enumerate first is the one the panel and
-- the loader really use.  Replacing only mods/<id> let an update report
-- success while the old copy kept winning that race (#801); and a
-- manifest-less mods/<id> left by an interrupted copy blocked every re-import
-- as "already installed" while showing nowhere the player could see (#834).
local function sameIdTrees(fs, id)
  local out, installed = {}, false
  if not fs.getInfo("mods") then return out, installed end
  for _, name in ipairs(fs.getDirectoryItems("mods")) do
    local path = "mods/" .. name
    local raw = fs.read(path .. "/manifest.json")
    local manifest = raw and decodeManifest(raw, path)
    if manifest and manifest.id == id then
      out[#out + 1] = path
      installed = true
    elseif name == id and fs.getInfo(path) then
      out[#out + 1] = path
    end
  end
  return out, installed
end

-- ------- bundle import (top-level package archives only)

-- A bundle is an ordinary .zip which is not itself a mod package, but holds a
-- small set of ordinary mod archives.  It is intentionally not a general
-- archive extractor: only .zip/.modpkg files at the bundle root are examined,
-- and their contents are mounted through LOVE/PhysFS exactly like a direct
-- import.  This keeps README files harmless and gives nested packages no path
-- outside the game's controlled filesystem.
local BUNDLE_LIMITS = {
  -- The outer carrier and the sum of its immediate package archives may each
  -- be at most 100 MiB. Bundle handling mounts the carrier from storage and
  -- stages one inner archive at a time, so it never retains the carrier plus
  -- every nested archive in Lua memory. This is a product limit, not a
  -- measured Quest storage maximum; a user-present capacity benchmark still
  -- validates practical headroom.
  maxOuterBytes = 100 * 1024 * 1024,
  maxMembers = 16,
  -- Do not set a smaller compressed-member cap: one legitimate member may
  -- use the whole bundle budget. The aggregate cap remains the hard bound.
  maxMemberBytes = 100 * 1024 * 1024,
  maxTotalMemberBytes = 100 * 1024 * 1024,
  maxFilesPerMember = 16 * 1024,
  maxTotalFiles = 32 * 1024,
  -- Files are copied one at a time. These independent expanded-data bounds
  -- block zip bombs and reserve disk space before any install is written.
  maxMemberFileBytes = 8 * 1024 * 1024,
  maxMemberExpandedBytes = 128 * 1024 * 1024,
  maxTotalExpandedBytes = 192 * 1024 * 1024,
  -- Do not consume the final free bytes: Android needs working storage for
  -- the app, PhysFS, and the system while a confirmed import writes files.
  minFreeBytes = 64 * 1024 * 1024,
  maxPathDepth = 8,
  maxPathBytes = 240,
}
LauncherMods.BUNDLE_LIMITS = BUNDLE_LIMITS

local bundleMountSerial = 0

local function mountArchiveBytes(data, tag)
  local fs = love and love.filesystem
  if not fs then return nil, "mod import needs LOVE" end
  bundleMountSerial = bundleMountSerial + 1
  local suffix = tostring(os.time()) .. "_" .. tostring(bundleMountSerial)
  local mount = "mod_" .. tag .. "_mount_" .. suffix
  local tmp, mountKey, mounted = nil, nil, false
  if fs.newFileData then
    local okFd, fd = pcall(fs.newFileData, data, "mod_" .. tag .. "_" .. suffix .. ".zip")
    if okFd and fd and fs.mount(fd, mount) then
      mounted, mountKey = true, fd
    end
  end
  if not mounted then
    tmp = "mod_" .. tag .. "_" .. suffix .. ".zip"
    local ok, writeErr = fs.write(tmp, data)
    if not ok then return nil, "could not stage the archive: " .. tostring(writeErr) end
    if not fs.mount(tmp, mount) then
      fs.remove(tmp)
      return nil, "that archive could not be opened"
    end
    mountKey = tmp
  end
  return mount, function()
    pcall(fs.unmount, mountKey)
    if tmp then pcall(fs.remove, tmp) end
  end
end

-- Mount an archive that already exists in LOVE's writable filesystem. This is
-- the bundle path on Android: SAF has copied the carrier to picked_mod.zip,
-- so PhysFS can read its central directory and entries from disk without a
-- second Lua copy of the whole outer ZIP.
local function mountArchivePath(path, tag)
  local fs = love and love.filesystem
  if not fs or type(path) ~= "string" then return nil, "mod import needs a staged archive" end
  bundleMountSerial = bundleMountSerial + 1
  local mount = "mod_" .. tag .. "_mount_" .. tostring(os.time()) .. "_" .. tostring(bundleMountSerial)
  if not fs.mount(path, mount) then return nil, "that archive could not be opened" end
  return mount, function() pcall(fs.unmount, path) end
end

local function newBundleStageName(tag)
  bundleMountSerial = bundleMountSerial + 1
  return "mod_bundle_stage_" .. tostring(tag) .. "_" .. tostring(os.time())
    .. "_" .. tostring(bundleMountSerial) .. ".zip"
end

-- Copy one mounted inner archive to a temporary file in 64 KiB blocks. The
-- temporary archive is then mounted and validated. This is deliberately a
-- disk stage, not love.filesystem.read: an outer 100 MiB bundle with one 100
-- MiB member must not create two large Lua strings.
local function stageMountedArchive(sourcePath, tag, maxBytes, progress)
  local fs = love and love.filesystem
  if not fs then return nil, "mod import needs LOVE" end
  local info = fs.getInfo(sourcePath, "file")
  if not info then return nil, "could not read a bundle package" end
  if info.size and info.size > maxBytes then
    return nil, "a bundle package is larger than " .. tostring(maxBytes) .. " bytes"
  end
  if not fs.newFile then
    -- Test doubles before LOVE 11's streaming File API keep this small-data
    -- fallback. Production Quest builds always have newFile.
    local data = fs.read(sourcePath)
    if type(data) ~= "string" then return nil, "could not read a bundle package" end
    local logicalBytes = info.size or #data
    if logicalBytes > maxBytes then
      return nil, "a bundle package is larger than " .. tostring(maxBytes) .. " bytes"
    end
    return data, function() end, logicalBytes, true
  end
  local input, output
  local stage = newBundleStageName(tag)
  local ok, err = pcall(function()
    input = assert(fs.newFile(sourcePath, "r"))
    output = assert(fs.newFile(stage, "w"))
    local copied = 0
    while true do
      local chunk, size = input:read(64 * 1024)
      size = size or (type(chunk) == "string" and #chunk or 0)
      if size == 0 then break end
      if type(chunk) ~= "string" or not output:write(chunk) then
        error("could not stage a bundle package")
      end
      copied = copied + size
      if copied > maxBytes then error("a bundle package is larger than " .. tostring(maxBytes) .. " bytes") end
      if progress then progress(copied, info.size) end
    end
    if info.size and copied ~= info.size then error("bundle package changed while it was read") end
  end)
  if input then pcall(input.close, input) end
  if output then pcall(output.close, output) end
  if not ok then pcall(fs.remove, stage); return nil, tostring(err) end
  return stage, function() pcall(fs.remove, stage) end, info.size or 0, false
end

local function safeArchiveName(name)
  return type(name) == "string" and name ~= "" and #name <= BUNDLE_LIMITS.maxPathBytes
    and not name:find("/", 1, true) and not name:find("\\", 1, true)
    and not name:find("\0", 1, true) and name ~= "." and name ~= ".."
end

local function safeArchivePath(path)
  if type(path) ~= "string" or path == "" or #path > BUNDLE_LIMITS.maxPathBytes
      or path:sub(1, 1) == "/" or path:find("\\", 1, true)
      or path:find("\0", 1, true) then
    return false
  end
  for piece in path:gmatch("[^/]+") do
    if not safeArchiveName(piece) then return false end
  end
  return not path:find("//", 1, true) and path:sub(-1) ~= "/"
end

local function scanPackageTree(root, onFile)
  local fs = love.filesystem
  local state = { files = 0, bytes = 0 }
  local function walk(path, depth)
    if depth > BUNDLE_LIMITS.maxPathDepth then
      return nil, "package path is deeper than " .. BUNDLE_LIMITS.maxPathDepth .. " folders"
    end
    local items = fs.getDirectoryItems(path)
    for _, name in ipairs(items) do
      if not safeArchiveName(name) then return nil, "package has an unsafe file name" end
      local child = path .. "/" .. name
      local info = fs.getInfo(child)
      if not info then return nil, "package has an unreadable file" end
      if info.type == "directory" then
        local ok, err = walk(child, depth + 1)
        if not ok then return nil, err end
      elseif info.type == "file" then
        state.files = state.files + 1
        if state.files > BUNDLE_LIMITS.maxFilesPerMember then
          return nil, "package has more than " .. BUNDLE_LIMITS.maxFilesPerMember .. " files"
        end
        local fileBytes = info.size
        if fileBytes and fileBytes > BUNDLE_LIMITS.maxMemberFileBytes then
          return nil, "package file is larger than " .. BUNDLE_LIMITS.maxMemberFileBytes .. " bytes"
        end
        local data = fs.read(child)
        if type(data) ~= "string" then return nil, "package has an unreadable file" end
        if #data > BUNDLE_LIMITS.maxMemberFileBytes then
          return nil, "package file is larger than " .. BUNDLE_LIMITS.maxMemberFileBytes .. " bytes"
        end
        -- PhysFS reports the uncompressed entry size before this bounded read.
        -- Use it for the aggregate bomb budget so an archive cannot hide its
        -- expansion behind a short read from a broken provider.
        fileBytes = fileBytes or #data
        state.bytes = state.bytes + fileBytes
        if state.bytes > BUNDLE_LIMITS.maxMemberExpandedBytes then
          return nil, "package expands beyond " .. BUNDLE_LIMITS.maxMemberExpandedBytes .. " bytes"
        end
        if onFile then onFile(state) end
      else
        return nil, "package contains an unsupported filesystem entry"
      end
    end
    return true
  end
  local ok, err = walk(root, 0)
  if not ok then return nil, err end
  return true, nil, state
end

local function validateMountedPackage(mount, cleanup, onFile)
  local function fail(err)
    cleanup()
    return nil, err
  end
  local prefix, rootErr = LauncherMods.locateRoot(topLevelPaths(mount))
  if not prefix then return fail(rootErr) end
  local root = prefix == "" and mount or (mount .. "/" .. prefix)
  local raw = love.filesystem.read(root .. "/manifest.json")
  if not raw then return fail("the package has no readable manifest.json") end
  local manifest, manifestErr = decodeManifest(raw, root)
  if not manifest then return fail("invalid mod manifest: " .. tostring(manifestErr)) end
  local treeOk, treeErr, treeState = scanPackageTree(root, onFile)
  if not treeOk then return fail(treeErr) end
  for _, field in ipairs({ "entry", "options_schema", "assets_transforms" }) do
    local path = manifest[field]
    if path then
      if not safeArchivePath(path) then return fail("manifest " .. field .. " has an unsafe path") end
      if not love.filesystem.getInfo(root .. "/" .. path, "file") then
        return fail("manifest " .. field .. " file is missing: " .. path)
      end
    end
  end
  return { mount = mount, root = root, manifest = manifest, cleanup = cleanup,
    tree = treeState }
end

local function openValidatedPackage(data, tag, onFile)
  if not zipLooksValid(data) then return nil, "not a zip file" end
  local mount, cleanup = mountArchiveBytes(data, tag)
  if not mount then return nil, cleanup end
  return validateMountedPackage(mount, cleanup, onFile)
end

local function openValidatedPackageFile(path, tag, onFile)
  local mount, cleanup = mountArchivePath(path, tag)
  if not mount then return nil, cleanup end
  return validateMountedPackage(mount, cleanup, onFile)
end

local function compatibleConflict(a, b)
  for _, spec in ipairs(a.conflictSpecs or {}) do
    if spec.id == b.id and (not spec.range or Semver.satisfies(b.version, spec.range)) then
      return true
    end
  end
  return false
end

local function emitProgress(progress, phase, index, total, id, bytes, totalBytes, files, totalFiles)
  if progress then progress(phase, index, total, id, bytes, totalBytes, files, totalFiles) end
end

local function bundleFreeBytes()
  if not (love and love.system and love.system.getOS and love.system.getOS() == "Android") then
    return nil
  end
  local fn = love.system.getStorageFreeBytes
  if type(fn) ~= "function" then return false end
  local path = love.filesystem and love.filesystem.getSaveDirectory
    and love.filesystem.getSaveDirectory() or ""
  local ok, bytes = pcall(fn, path)
  return ok and type(bytes) == "number" and bytes >= 0 and bytes or false
end

local function ensureBundleSpace(required)
  local free = bundleFreeBytes()
  if free == nil then return true end -- desktop / test runtime
  if free == false then return nil, "could not check free storage for the bundle import" end
  if free < required then
    return nil, "not enough free storage for the bundle import (need "
      .. tostring(required) .. " bytes free)"
  end
  return true
end

local function openBundleMember(outerMount, member, tag, index, total, progress, onFile)
  local source = outerMount .. "/" .. member.name
  local staged, stageCleanup, bytes, inMemory = stageMountedArchive(source, tag,
    BUNDLE_LIMITS.maxMemberBytes, function(done, expected)
      emitProgress(progress, "staging", index, total, nil, done, expected)
    end)
  if not staged then return nil, stageCleanup end
  if member.size and bytes ~= member.size then
    stageCleanup()
    return nil, "bundle package changed while it was read"
  end
  local opened, err
  if inMemory then opened, err = openValidatedPackage(staged, tag, onFile)
  else opened, err = openValidatedPackageFile(staged, tag, onFile) end
  if not opened then stageCleanup(); return nil, err end
  local cleanup = opened.cleanup
  opened.cleanup = function()
    cleanup()
    stageCleanup()
  end
  return opened, nil, bytes
end

local function validateBundlePlan(plan, progress)
  if type(plan) ~= "table" or type(plan.source) ~= "string"
      or type(plan.members) ~= "table" or #plan.members == 0 then
    return nil, "bundle import has no prepared packages"
  end
  if #plan.members > BUNDLE_LIMITS.maxMembers then
    return nil, "bundle has more than " .. BUNDLE_LIMITS.maxMembers .. " packages"
  end
  local fs = love and love.filesystem
  if not fs then return nil, "mod import needs LOVE" end
  local outer, outerCleanup = mountArchivePath(plan.source, "bundle_validate")
  if not outer then return nil, outerCleanup end
  local function fail(reason)
    outerCleanup()
    return nil, reason
  end
  local largestMember, totalDeclared = 0, 0
  for _, member in ipairs(plan.members) do
    if type(member.name) ~= "string" or type(member.size) ~= "number" or member.size < 0 then
      return fail("bundle package metadata is invalid")
    end
    if member.size > BUNDLE_LIMITS.maxMemberBytes then
      return fail("bundle package is larger than " .. BUNDLE_LIMITS.maxMemberBytes .. " bytes")
    end
    largestMember = math.max(largestMember, member.size)
    totalDeclared = totalDeclared + member.size
    if totalDeclared > BUNDLE_LIMITS.maxTotalMemberBytes then
      return fail("bundle packages exceed " .. BUNDLE_LIMITS.maxTotalMemberBytes .. " bytes")
    end
  end
  local stageOk, stageErr = ensureBundleSpace(largestMember + BUNDLE_LIMITS.minFreeBytes)
  if not stageOk then return fail(stageErr) end
  local byId, total, totalFiles, totalExpanded = {}, 0, 0, 0
  for index, member in ipairs(plan.members) do
    emitProgress(progress, "checking", index, #plan.members)
    local opened, err, bytes = openBundleMember(outer, member, "bundle_check", index,
      #plan.members, progress, function(state)
        emitProgress(progress, "validating", index, #plan.members, nil,
          state.bytes, nil, state.files, nil)
      end)
    if not opened then return fail("a bundle package is invalid: " .. tostring(err)) end
    total = total + bytes
    if total > BUNDLE_LIMITS.maxTotalMemberBytes then
      opened.cleanup()
      return fail("bundle packages exceed " .. BUNDLE_LIMITS.maxTotalMemberBytes .. " bytes")
    end
    local manifest = opened.manifest
    opened.cleanup()
    if byId[manifest.id] then
      return fail("bundle contains duplicate mod id '" .. manifest.id .. "'")
    end
    if member.id and (member.id ~= manifest.id or member.version ~= manifest.version) then
      return fail("bundle package changed after it was checked")
    end
    member.id, member.version, member.manifest = manifest.id, manifest.version, manifest
    member.files, member.bytes = opened.tree.files, opened.tree.bytes
    totalFiles = totalFiles + opened.tree.files
    if totalFiles > BUNDLE_LIMITS.maxTotalFiles then
      return fail("bundle packages have more than " .. BUNDLE_LIMITS.maxTotalFiles .. " files")
    end
    totalExpanded = totalExpanded + opened.tree.bytes
    if totalExpanded > BUNDLE_LIMITS.maxTotalExpandedBytes then
      return fail("bundle packages expand beyond "
        .. BUNDLE_LIMITS.maxTotalExpandedBytes .. " bytes")
    end
    emitProgress(progress, "validating", index, #plan.members, manifest.id,
      opened.tree.bytes, opened.tree.bytes, opened.tree.files, opened.tree.files)
    byId[manifest.id] = member
    local _, installed = sameIdTrees(fs, manifest.id)
    if installed then return fail("a mod named '" .. manifest.id .. "' is already installed") end
  end
  local spaceOk, spaceErr = ensureBundleSpace(totalExpanded + largestMember + BUNDLE_LIMITS.minFreeBytes)
  if not spaceOk then return fail(spaceErr) end
  local all = {}
  for _, manifest in ipairs(discover()) do all[manifest.id] = manifest end
  for id, member in pairs(byId) do all[id] = member.manifest end
  for id, member in pairs(byId) do
    for otherId, other in pairs(all) do
      if otherId ~= id and (compatibleConflict(member.manifest, other)
          or compatibleConflict(other, member.manifest)) then
        return fail("bundle mod '" .. id .. "' conflicts with '" .. otherId .. "'")
      end
    end
  end
  outerCleanup()
  return true
end

-- prepareBundle(source) -> plan | nil, reason.  No mod files are written by
-- this phase.  It accepts only an outer archive with no package manifest and
-- only top-level nested package files; other files such as README are ignored.
function LauncherMods.prepareBundle(source, progress)
  local ok, plan, err = pcall(LauncherMods._prepareBundleInner, source, progress)
  if not ok then return nil, "bundle inspection failed: " .. tostring(plan) end
  return plan, err
end

-- The launcher worker calls this internal form so its progress callback can
-- yield between bounded archive operations.  The public wrapper remains safe
-- for normal callers and tests which do not yield.
function LauncherMods._prepareBundleInner(source, progress)
    if not (love and love.filesystem) then return nil, "mod import needs LOVE" end
    local fs = love.filesystem
    local info = type(source) == "string" and fs.getInfo(source, "file") or nil
    if info and info.size and info.size > BUNDLE_LIMITS.maxOuterBytes then
      return nil, "mod bundle is larger than the " .. tostring(BUNDLE_LIMITS.maxOuterBytes)
        .. " byte import limit"
    end
    -- Android SAF and launcher inbox imports are save-dir paths. Mounting that
    -- path is the bounded path: it avoids reading a 100 MiB carrier into Lua.
    -- A dropped/host file keeps the direct importer behavior and is not treated
    -- as a large bundle unless it can first be staged by the host integration.
    if type(source) ~= "string" then
      return nil, "bundle import needs a staged .zip file"
    end
    local mount, cleanup = mountArchivePath(source, "bundle_outer")
    if not mount then return nil, cleanup end
    local function fail(reason)
      cleanup()
      return nil, reason
    end
    emitProgress(progress, "scanning", 0, 0)
    local root = LauncherMods.locateRoot(topLevelPaths(mount))
    if root then return fail("this archive is already a mod package") end
    local members, total = {}, 0
    for _, name in ipairs(fs.getDirectoryItems(mount)) do
      local memberInfo = fs.getInfo(mount .. "/" .. name)
      local lower = type(name) == "string" and name:lower() or ""
      if memberInfo and memberInfo.type == "file" and (lower:match("%.zip$") or lower:match("%.modpkg$")) then
        if not safeArchiveName(name) then return fail("bundle has an unsafe package name") end
        if #members >= BUNDLE_LIMITS.maxMembers then
          return fail("bundle has more than " .. BUNDLE_LIMITS.maxMembers .. " packages")
        end
        if not memberInfo.size then return fail("could not read a bundle package size") end
        if memberInfo.size > BUNDLE_LIMITS.maxMemberBytes then
          return fail("a bundle package is larger than "
            .. BUNDLE_LIMITS.maxMemberBytes .. " bytes")
        end
        total = total + memberInfo.size
        if total > BUNDLE_LIMITS.maxTotalMemberBytes then
          return fail("bundle packages exceed " .. BUNDLE_LIMITS.maxTotalMemberBytes .. " bytes")
        end
        members[#members + 1] = { name = name, size = memberInfo.size }
      end
    end
    cleanup()
    if #members == 0 then
      return nil, "the .zip has no package manifest and no top-level .zip or .modpkg files"
    end
    table.sort(members, function(a, b) return a.name < b.name end)
    local result = { source = source, members = members }
    local valid, validErr = validateBundlePlan(result, progress)
    if not valid then return nil, validErr end
    return result
end

-- installBundle(plan) -> true, { id, ... } | nil, reason.  Every package is
-- rechecked immediately before copy.  Existing ids are refused during the
-- preflight, so a failed copy can safely delete only the new destinations and
-- leave the prior active mod set unchanged.
function LauncherMods.installBundle(plan, progress)
  local ok, result, err = pcall(LauncherMods._installBundleInner, plan, progress)
  if not ok then return nil, "bundle import failed; no mods were installed: " .. tostring(result) end
  return result, err
end

function LauncherMods._installBundleInner(plan, progress)
    local valid, validErr = validateBundlePlan(plan, progress)
    if not valid then return nil, validErr end
    local created, ids = {}, {}
    local outer, outerCleanup = mountArchivePath(plan.source, "bundle_install")
    if not outer then return nil, outerCleanup end
    local savedPrefix = CacheFs.prefix
    CacheFs.prefix = ""
    local function rollback()
      emitProgress(progress, "rollback", 0, #created)
      for i = #created, 1, -1 do pcall(removeTree, created[i]) end
    end
      for index, member in ipairs(plan.members) do
        local opened, openErr = openBundleMember(outer, member, "bundle_install", index,
          #plan.members, progress, function(state)
            emitProgress(progress, "validating", index, #plan.members, nil,
              state.bytes, nil, state.files, nil)
          end)
        if not opened then rollback(); CacheFs.prefix = savedPrefix
          outerCleanup()
          return nil, "bundle import failed; no mods were installed: invalid package: " .. tostring(openErr) end
        if opened.manifest.id ~= member.id or opened.manifest.version ~= member.version then
          opened.cleanup()
          rollback(); CacheFs.prefix = savedPrefix
          outerCleanup()
          return nil, "bundle import failed; no mods were installed: package changed after checking"
        end
        local dest = "mods/" .. member.id
        local copiedBytes, copiedFiles = 0, 0
        emitProgress(progress, "installing", index, #plan.members, member.id, 0,
          member.bytes, 0, member.files)
        local copied, copyErr = copyTree(opened.root, dest, function(bytes)
          copiedBytes, copiedFiles = copiedBytes + bytes, copiedFiles + 1
          emitProgress(progress, "installing", index, #plan.members, member.id,
            copiedBytes, member.bytes, copiedFiles, member.files)
        end)
        opened.cleanup()
        if not copied then
          pcall(removeTree, dest)
          rollback(); CacheFs.prefix = savedPrefix
          outerCleanup()
          return nil, "bundle import failed; no mods were installed: "
            .. tostring(copyErr or "could not copy bundle package")
        end
        created[#created + 1] = dest
        ids[#ids + 1] = member.id
      end
    CacheFs.prefix = savedPrefix
    outerCleanup()
    emitProgress(progress, "complete", #ids, #plan.members, nil)
    return true, ids
end

-- ------- strays: mods dropped beside the game that it cannot see

-- love.filesystem looks in two places for "mods/": the save directory, and --
-- portable installs only -- the game folder, which CacheFs mounts.  A player
-- who unzips a mod next to the executable of an ordinary install, which is
-- where very nearly every other game would want it, gets no error and no mod.
-- The MODS panel simply stays empty, and there is nothing on screen to
-- suggest the files are twenty centimetres away in the wrong folder.
--
-- The scan mounts each game folder at a private mount point just long enough
-- to list mods/ inside it and drops it again (CacheFs.withMounted), so the
-- read path the game actually runs on is never touched and a stray can never
-- shadow a real file.
local STRAY_MOUNT = "stray_scan"

-- Run fn(mountedModsRoot) for each game folder that has a readable mods/
-- directory, one mount at a time.  Folders already on the read path are
-- skipped (isReadableRoot): the physfs source, which is every `love <gamedir>`
-- dev run, and the portable game folder CacheFs mounted, where re-mounting is
-- what used to drop the mount (#413).
local function eachStrayRoot(fn)
  local SaveData_ = require("src.core.SaveData")
  local fs = love and love.filesystem
  if not fs then return end
  local source = fs.getSource and fs.getSource()
  local cacheRoot = CacheFs.root()
  local seen = {}
  for _, folder in ipairs(SaveData_.gameFolders() or {}) do
    if not seen[folder]
      and not LauncherMods.isReadableRoot(folder, source, cacheRoot) then
      seen[folder] = true
      CacheFs.withMounted(folder, STRAY_MOUNT, function()
        local root = STRAY_MOUNT .. "/mods"
        if fs.getInfo(root) then fn(root, folder) end
      end)
    end
  end
end

-- Every valid mod folder sitting in a game folder's mods/, in scan order.
-- Only reads.  The rows carry the mounted path, which is live for the length
-- of the mount and dead after it -- copying has to happen inside the same
-- scan, which is why adoption is a flag here rather than a second pass.
local function findStrays(fs, adopt, installed)
  local found, adopted = {}, {}
  eachStrayRoot(function(root, folder)
    local batch = {}
    for _, name in ipairs(fs.getDirectoryItems(root)) do
      local path = root .. "/" .. name
      local info = fs.getInfo(path)
      if info and info.type == "directory" then
        local raw = fs.read(path .. "/manifest.json")
        local manifest = raw and decodeManifest(raw, path)
        if manifest then
          batch[#batch + 1] = { id = manifest.id,
                                name = manifest.name or manifest.id,
                                folder = folder, path = path }
        end
      end
    end
    -- filtered per mount, so a copy only ever runs for a row that survived
    -- the pure rules -- and so the second game folder sees the first one's
    -- ids as taken
    for _, row in ipairs(LauncherMods.pickStrays(batch, installed)) do
      if adopt then
        -- same root pin installZip uses: the mods tree is shared by Red and
        -- Blue, never version-prefixed (#330)
        local savedPrefix = CacheFs.prefix
        CacheFs.prefix = ""
        local dest = "mods/" .. row.id
        local copied, copyErr = copyTree(row.path, dest)
        if not copied then removeTree(dest) end
        CacheFs.prefix = savedPrefix
        if not copied then row.err = copyErr or "could not copy the files" end
      end
      installed[row.id] = true
      row.path = nil                    -- dead once this mount comes down
      adopted[#adopted + 1] = row
      found[#found + 1] = row
    end
  end)
  return LauncherMods.pickStrays(found, {})
end

-- The strays, optionally adopted.  A folder whose id the game can already see
-- is left out: the player has a working copy, and the loose one is just where
-- they first put it.  Rows that failed to copy come back with .err set.
local function scanStrays(adopt)
  local fs = love and love.filesystem
  if not fs then return {} end
  local installed = {}
  for _, m in ipairs(discover()) do installed[m.id] = true end
  return findStrays(fs, adopt, installed)
end

-- strays() -> the rows, nothing copied.
function LauncherMods.strays() return scanStrays(false) end

-- adoptStrays() -> the rows, each one copied into the mods tree the game
-- really reads (rows carrying .err failed).  Idempotent: a second call finds
-- the ids installed and returns nothing, so the panel can run this on every
-- open without duplicating anything or nagging twice.  The loose folder is
-- deliberately left where it is -- deleting files outside the save directory
-- on the player's behalf is not this function's call to make.
function LauncherMods.adoptStrays() return scanStrays(true) end

-- installZip(source [, opts]) -> true, id  |  nil, errString
-- source is an external path or a love DroppedFile.  The archive is validated
-- BEFORE anything is copied; every path unmounts and clears the staged temp
-- file, and a failed copy rolls its partial tree back.  A dropped file outside
-- the save dir is staged into a save-dir temp first, because
-- love.filesystem.mount only reaches a save-directory-relative path.
-- opts.replace = true uninstalls an existing same-id mod first (updates /
-- rollbacks).  opts.expectId, when set, refuses a zip whose manifest id differs.
function LauncherMods.installZip(source, opts)
  local ok, result, err = pcall(LauncherMods._installZipInner, source, opts)
  if not ok then return nil, "import failed: " .. tostring(result) end
  return result, err
end

function LauncherMods._installZipInner(source, opts)
  opts = opts or {}
  local progress = opts.progress
  if not (love and love.filesystem) then
    return nil, "mod install needs LOVE"
  end
  local fs = love.filesystem
  local data, readErr = readArchive(source)
  if not data then return nil, readErr end
  if progress then progress("checking", 1, 1) end
  if not zipLooksValid(data) then
    local label = type(source) == "string" and (source:match("[^/\\]+$") or source)
      or "archive"
    return nil, "not a zip file: " .. tostring(label)
      .. " (need a real .zip; skip Mac ._ files from MTP)"
  end

  -- Prefer in-memory mount (PHYSFS_mountMemory via FileData). Avoids Horizon's
  -- "file already open" failure when write-then-mount reopens a save-dir zip.
  local mount = "mod_import_mount"
  local tmp = nil
  local mountKey = nil
  local mounted = false
  if fs.newFileData then
    local archiveName = ("mod_import_%d_%d.zip"):format(
      os.time(), math.random(0, 999999))
    local okFd, fd = pcall(fs.newFileData, data, archiveName)
    if okFd and fd and fs.mount(fd, mount) then
      mounted = true
      mountKey = fd
    end
  end
  if not mounted then
    -- Fallback: stage into a save-dir temp so path-mount can reach it.
    tmp = ("mod_import_%d_%d.zip"):format(os.time(), math.random(0, 999999))
    local ok, writeErr = fs.write(tmp, data)
    if not ok then
      return nil, "could not stage the .zip: " .. tostring(writeErr)
    end
    if not fs.mount(tmp, mount) then
      fs.remove(tmp)
      return nil, "that .zip could not be opened"
    end
    mountKey = tmp
  end
  local function cleanup()
    pcall(fs.unmount, mountKey)
    if tmp then fs.remove(tmp) end
  end

  local prefix, rootErr = LauncherMods.locateRoot(topLevelPaths(mount))
  if not prefix then
    cleanup()
    return nil, rootErr
  end
  local root = prefix == "" and mount or (mount .. "/" .. prefix)

  local raw = fs.read(root .. "/manifest.json")
  if not raw then
    cleanup()
    return nil, "the .zip has no readable manifest.json"
  end
  local manifest, manifestErr = decodeManifest(raw, root)
  if not manifest then
    cleanup()
    return nil, "invalid mod manifest: " .. tostring(manifestErr)
  end
  if opts.expectId and manifest.id ~= opts.expectId then
    cleanup()
    return nil, ("zip is for '%s', expected '%s'")
      :format(manifest.id, opts.expectId)
  end

  -- Direct packages do not have a precomputed expanded size in the existing
  -- importer.  Report discrete, truthful stages instead of inventing a byte
  -- percentage.  Bundle installs below have measured file and byte totals.
  if progress then progress("installing", 1, 1, manifest.id) end

  local dest = "mods/" .. manifest.id
  local existing, installedSomewhere = sameIdTrees(fs, manifest.id)
  if installedSomewhere and not opts.replace then
    cleanup()
    return nil, "a mod named '" .. manifest.id .. "' is already installed"
  end
  if #existing > 0 then
    -- drop every old tree before copy -- mods/<id> and any same-id folder
    -- under another name, or the survivor keeps winning discover()'s
    -- first-id-wins race after the "successful" update (#801).  A tree with
    -- no readable manifest is debris from an interrupted copy: it never
    -- refuses the install, it only gets cleared (#834).  Enable-flag is
    -- preserved (uninstall would clear it, which would surprise an update).
    local savedPrefix = CacheFs.prefix
    CacheFs.prefix = ""
    for _, path in ipairs(existing) do removeTree(path) end
    CacheFs.prefix = savedPrefix
  end

  -- CacheFs.prefix steers ROM-cache writes into a version subtree (blue/...);
  -- the mods tree is shared by Red and Blue, so pin the prefix to the root for
  -- the copy and the rollback, then hand back whatever the launcher had set
  -- (an import coroutine leaves it pointed at that version -- RomImporter.lua).
  -- No fs.createDirectory("mods") here any more: CacheFs.write creates the
  -- parent chain in both homes, and doing it through love.filesystem would
  -- only ever make the directory in the save dir (#330).
  local savedPrefix = CacheFs.prefix
  CacheFs.prefix = ""
  local copied, copyErr = copyTree(root, dest)
  if not copied then removeTree(dest) end
  CacheFs.prefix = savedPrefix
  if not copied then
    cleanup()
    return nil, copyErr or "could not copy the mod files"
  end
  cleanup()
  if progress then progress("complete", 1, 1, manifest.id) end
  return true, manifest.id
end

-- Install (or replace) a mod from a GitHub release zip URL.
-- Returns true, version  |  nil, errString. Soft-fails: download / install /
-- cleanup errors never throw into the launcher UI.
function LauncherMods.installFromRelease(modId, release)
  local ok, result, err = pcall(function()
    if type(modId) ~= "string" or modId == "" then
      return nil, "missing mod id"
    end
    if type(release) ~= "table" or not release.zip or not release.zip.url then
      return nil, "release has no downloadable .zip"
    end
    local ModUpdate = require("src.mods.ModUpdate")
    local tmpName = ("mod_update_%s_%s.zip"):format(
      tostring(modId), tostring(release.version or os.time()))
    local localPath, dlErr = ModUpdate.downloadZip(release.zip.url, tmpName)
    if not localPath then return nil, dlErr end
    local installed, res = LauncherMods.installZip(localPath, {
      replace = true, expectId = modId,
    })
    pcall(love.filesystem.remove, localPath)
    if not installed then return nil, res end
    return true, release.version or res
  end)
  if not ok then return nil, "install failed: " .. tostring(result) end
  return result, err
end

-- The install half of installFromRelease, split out so the launcher can run
-- the DOWNLOAD half asynchronously (src/net/Fetch.lua) and still land in the
-- same place.  `localPath` is a love.filesystem-relative path to an already
-- downloaded zip; it is consumed (removed) either way.
-- Returns true, version | nil, errString.
function LauncherMods.installDownloadedZip(modId, localPath, version)
  local ok, result, err = pcall(function()
    if type(modId) ~= "string" or modId == "" then
      return nil, "missing mod id"
    end
    if type(localPath) ~= "string" or localPath == "" then
      return nil, "missing downloaded archive"
    end
    local installed, res = LauncherMods.installZip(localPath, {
      replace = true, expectId = modId,
    })
    pcall(love.filesystem.remove, localPath)
    if not installed then return nil, res end
    return true, version or res
  end)
  if not ok then return nil, "install failed: " .. tostring(result) end
  return result, err
end

-- Install a mod listed in a community index (src/mods/ModIndex.lua).
-- The index only ever tells us WHERE the zip is; resolving that URL is
-- ModIndex's job and installing it is installFromRelease's, so this is the
-- seam between them and nothing about the archive is special-cased.  expectId
-- comes from the listing, so a feed that points an entry at somebody else's
-- zip fails the manifest check instead of installing the wrong mod.
-- Returns true, version | nil, errString.
function LauncherMods.installFromIndex(entry)
  local ok, result, err = pcall(function()
    if type(entry) ~= "table" or type(entry.id) ~= "string" then
      return nil, "index entry has no mod id"
    end
    local ModIndex = require("src.mods.ModIndex")
    local release, why = ModIndex.releaseFor(entry)
    if not release then
      return nil, why or "this mod cannot be installed from the index"
    end
    return LauncherMods.installFromRelease(entry.id, release)
  end)
  if not ok then return nil, "install failed: " .. tostring(result) end
  return result, err
end

-- uninstall(id) -> true  |  nil, errString
-- Removes mods/<id>/ from wherever it was installed (the portable game folder
-- or the save directory, CacheFs decides -- #330) and clears every enable flag
-- so the loader and in-game manager no longer see it.  Rejects missing ids.
-- Does not touch other mods' enable state.
function LauncherMods.uninstall(id)
  if type(id) ~= "string" or id == "" then
    return nil, "missing mod id"
  end
  if id:find("[/\\]") or id == "." or id == ".." then
    return nil, "invalid mod id"
  end
  if not (love and love.filesystem) then
    return nil, "mod uninstall needs LOVE"
  end
  local fs = love.filesystem
  local trees = sameIdTrees(fs, id)
  if #trees == 0 then
    return nil, "mod '" .. id .. "' is not installed"
  end
  -- same root pin as installZip: the mods tree is not version-prefixed (#330).
  -- Every same-id tree goes, folder name notwithstanding, so Delete works on a
  -- hand-unzipped copy too and cannot leave a shadow copy for discover()'s
  -- first-id-wins rule to resurrect on the next boot (#801)
  local savedPrefix = CacheFs.prefix
  CacheFs.prefix = ""
  for _, path in ipairs(trees) do removeTree(path) end
  CacheFs.prefix = savedPrefix
  -- Drop the enable flag so a reinstall of the same id starts from the
  -- loader's default (enabled) rather than a stale false.
  local options = SaveData.loadOptions()
  local changed = false
  if options.mods and options.mods[id] ~= nil then
    options.mods[id] = nil
    changed = true
  end
  for _, version in ipairs(GameVersion.ORDER) do
    local bucket = options.modsByVersion and options.modsByVersion[version]
    if type(bucket) == "table" and bucket[id] ~= nil then
      bucket[id] = nil
      changed = true
    end
  end
  if changed then
    SaveData.saveOptions(options)
  end
  return true
end

return LauncherMods

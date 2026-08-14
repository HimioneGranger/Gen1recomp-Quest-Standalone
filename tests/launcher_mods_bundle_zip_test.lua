-- LauncherMods bundle import: the outer archive is only a carrier.  These
-- tests model PhysFS mounts, so they prove preflight, limits and rollback
-- without touching an installed mod tree or a Quest device.
package.path = "./?.lua;./?/init.lua;" .. package.path
if not _G.love then _G.love = require("tests.love_stub") end

local S = require("tests.harness").suite("launcher mods bundle import")
local check, eq = S.check, S.eq

local files, dirs, arch, mounted, archives = {}, {}, {}, {}, {}
local failPrefix = nil

local function clear(map)
  for k in pairs(map) do map[k] = nil end
end

local function child(path, parent)
  if parent == nil or parent == "" then return path:match("^[^/]+") end
  local prefix = parent .. "/"
  if path:sub(1, #prefix) ~= prefix then return nil end
  return path:sub(#prefix + 1):match("^[^/]+")
end

local function mapInfo(map, path, kind)
  if map[path] ~= nil then
    return { type = kind or "file", size = type(map[path]) == "string" and #map[path] or nil }
  end
  for key in pairs(map) do
    if child(key, path) then return { type = "directory" } end
  end
  return nil
end

local vfs = {}
function vfs.write(path, data)
  if failPrefix and path:sub(1, #failPrefix) == failPrefix then return nil, "test write failure" end
  files[path] = data
  return true
end
function vfs.read(path)
  if arch[path] ~= nil then return arch[path] end
  return files[path]
end
function vfs.remove(path)
  files[path], dirs[path], arch[path] = nil, nil, nil
  for key in pairs(files) do if key:sub(1, #path + 1) == path .. "/" then files[key] = nil end end
  for key in pairs(dirs) do if key:sub(1, #path + 1) == path .. "/" then dirs[key] = nil end end
  return true
end
function vfs.createDirectory(path) dirs[path] = true; return true end
function vfs.getInfo(path, kind)
  local info = mapInfo(arch, path) or mapInfo(files, path) or mapInfo(dirs, path, "directory")
  if info and kind and info.type ~= kind then return nil end
  return info
end
function vfs.getDirectoryItems(path)
  local seen, out = {}, {}
  local function add(name)
    if name and not seen[name] then seen[name] = true; out[#out + 1] = name end
  end
  for key in pairs(arch) do add(child(key, path)) end
  for key in pairs(files) do add(child(key, path)) end
  for key in pairs(dirs) do add(child(key, path)) end
  table.sort(out)
  return out
end
function vfs.newFileData(data, name) return { __filedata = true, data = data, name = name } end
function vfs.mount(key, point)
  local data = type(key) == "table" and key.data or files[key]
  local tree = archives[data]
  if not tree then return false end
  mounted[key] = { point = point }
  for rel, body in pairs(tree) do arch[point .. "/" .. rel] = body end
  return true
end
function vfs.unmount(key)
  local m = mounted[key]
  if m then
    for path in pairs(arch) do
      if path:sub(1, #m.point + 1) == m.point .. "/" then arch[path] = nil end
    end
    mounted[key] = nil
  end
  return true
end
function vfs.getSaveDirectory() return "/tmp/pokeport-bundle-test" end
function vfs.getSource() return nil end

local function pkg(id, extra)
  local fields = {
    ('"id":"%s"'):format(id), '"name":"' .. id .. '"',
    '"version":"1.0.0"', '"entry":"main.lua"', '"api":2',
  }
  if extra then fields[#fields + 1] = extra end
  return {
    [id .. "/manifest.json"] = "{" .. table.concat(fields, ",") .. "}",
    [id .. "/main.lua"] = "return function() end\n",
  }
end

local A, B, BAD, DUP, CONFLICT_A, CONFLICT_B =
  "PK\3\4package-a", "PK\3\4package-b", "PK\3\4bad", "PK\3\4duplicate",
  "PK\3\4conflict-a", "PK\3\4conflict-b"
archives[A] = pkg("alpha")
archives[B] = pkg("bravo")
archives[BAD] = { ["not-a-package.txt"] = "not a mod" }
archives[DUP] = pkg("alpha")
archives[CONFLICT_A] = pkg("conflict_a", '"conflicts":["conflict_b"]')
archives[CONFLICT_B] = pkg("conflict_b")

local function outer(data, tree) archives[data] = tree; return data end
local TEST_MODS = outer("PK\3\4test-mods", {
  ["README.md"] = "These are test packages.",
  ["alpha.modpkg"] = A,
  ["bravo.zip"] = B,
})

local savedFs = love.filesystem
local SaveData = require("src.core.SaveData")
local savedPortable = SaveData.portableBaseDir
local savedCacheFs = package.loaded["src.import.CacheFs"]
local savedLauncherMods = package.loaded["src.mods.LauncherMods"]

local function freshMods()
  package.loaded["src.import.CacheFs"] = nil
  package.loaded["src.mods.LauncherMods"] = nil
  SaveData.portableBaseDir = function() return nil end
  return require("src.mods.LauncherMods")
end

local function reset()
  clear(files); clear(dirs); clear(arch); clear(mounted)
  failPrefix = nil
end

love.filesystem = vfs
local LauncherMods = freshMods()

-- A direct package remains the old one-package flow.
reset()
files["imports/direct.zip"] = A
local ok, id = LauncherMods.installZip("imports/direct.zip")
check(ok == true and id == "alpha", "direct package keeps normal import behavior")
check(files["mods/alpha/manifest.json"] ~= nil, "direct package lands in its normal destination")

-- TestMods-style carrier: README is ignored, both root package files are
-- checked before confirmation, and prepare itself makes no change.
reset()
files["imports/TestMods.zip"] = TEST_MODS
local plan, err = LauncherMods.prepareBundle("imports/TestMods.zip")
check(plan ~= nil, "bundle with README and valid packages prepares (" .. tostring(err) .. ")")
eq(#(plan and plan.members or {}), 2, "README is ignored and two packages are found")
check(files["mods/alpha/manifest.json"] == nil, "prepare/cancel leaves mod storage unchanged")
ok, id = LauncherMods.installBundle(plan)
check(ok == true, "prepared TestMods bundle installs atomically (" .. tostring(id) .. ")")
check(files["mods/alpha/manifest.json"] ~= nil and files["mods/bravo/manifest.json"] ~= nil,
  "valid bundle imports each package through the normal mod tree")

reset()
files["imports/bad-inner.zip"] = outer("PK\3\4bad-inner", { ["bad.zip"] = BAD })
plan, err = LauncherMods.prepareBundle("imports/bad-inner.zip")
check(not plan and tostring(err):find("invalid package", 1, true), "invalid inner ZIP fails before confirmation")

reset()
files["imports/duplicate.zip"] = outer("PK\3\4duplicate-bundle", { ["a.zip"] = A, ["b.zip"] = DUP })
plan, err = LauncherMods.prepareBundle("imports/duplicate.zip")
check(not plan and tostring(err):find("duplicate mod id", 1, true), "duplicate id/version is refused")

reset()
files["imports/conflict.zip"] = outer("PK\3\4conflict-bundle", { ["a.zip"] = CONFLICT_A, ["b.zip"] = CONFLICT_B })
plan, err = LauncherMods.prepareBundle("imports/conflict.zip")
check(not plan and tostring(err):find("conflicts with", 1, true), "declared conflict is refused before confirmation")

-- A write failure after the first package rolls the first package back too.
reset()
files["imports/rollback.zip"] = TEST_MODS
plan = assert(LauncherMods.prepareBundle("imports/rollback.zip"))
failPrefix = "mods/bravo/"
ok, err = LauncherMods.installBundle(plan)
check(not ok and tostring(err):find("no mods were installed", 1, true), "partial copy reports rollback")
check(files["mods/alpha/manifest.json"] == nil and files["mods/bravo/manifest.json"] == nil,
  "partial copy leaves no new active mod state")

reset()
files["imports/readme-only.zip"] = outer("PK\3\4readme-only", { ["README.md"] = "nothing here" })
plan, err = LauncherMods.prepareBundle("imports/readme-only.zip")
check(not plan and tostring(err):find("no package manifest", 1, true), "manifest-less archive with no package members is actionable")

reset()
files["imports/nested.zip"] = outer("PK\3\4nested", { ["inside/alpha.zip"] = A })
plan, err = LauncherMods.prepareBundle("imports/nested.zip")
check(not plan and tostring(err):find("no package manifest", 1, true), "nested package archives are not recursively accepted")

reset()
local many = {}
for i = 1, LauncherMods.BUNDLE_LIMITS.maxMembers + 1 do many[("m%02d.zip"):format(i)] = A end
files["imports/many.zip"] = outer("PK\3\4many", many)
plan, err = LauncherMods.prepareBundle("imports/many.zip")
check(not plan and tostring(err):find("more than", 1, true), "package count limit blocks unbounded bundles")

reset()
files["imports/too-large.zip"] = "PK" .. string.rep("x", LauncherMods.BUNDLE_LIMITS.maxOuterBytes)
plan, err = LauncherMods.prepareBundle("imports/too-large.zip")
check(not plan and tostring(err):find("larger than", 1, true), "outer archive size limit is enforced before mount")

love.filesystem = savedFs
SaveData.portableBaseDir = savedPortable
package.loaded["src.import.CacheFs"] = savedCacheFs
package.loaded["src.mods.LauncherMods"] = savedLauncherMods

S.finish()

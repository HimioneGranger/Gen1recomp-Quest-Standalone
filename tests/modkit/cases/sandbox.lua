-- T4: the mod sandbox (src/mods/Sandbox.lua) and the compat reroute over it
-- (src/mods/LegacyCompat.lua).  A mod's own chunks still cannot name a path
-- outside their own directory: the pre-sandbox globals are back as stand-ins
-- whose reads come from the mod's own files and whose writes land in a private
-- per-mod overlay.  Every case here is an escape a mod would actually try.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Manifest = require("src.mods.Manifest")
local Sandbox = require("src.mods.Sandbox")
local SafePath = require("src.mods.SafePath")
local LegacyCompat = require("src.mods.LegacyCompat")

local function manifest(id, extra)
  return ('{"id":"%s","name":"%s","version":"1.0.0","entry":"main.lua",'
    .. '"api":2%s}'):format(id, id, extra or "")
end

-- what a probe reports back; pcall'd so one broken assumption does not take
-- the whole entry chunk down and hide the rest
local PROBE = [[
  local mod = ...
  local out = mod.exports
  out.io = type(io)
  out.package = type(package)
  out.dofile = type(dofile)
  out.loadfile = type(loadfile)
  out.setfenv = setfenv
  out.getfenv = getfenv
  out.debug = debug
  out.osGetenv = type(os.getenv)
  out.osTime = type(os.time)
  out.stringOk = ("a"):rep(3)

  local function attempt(fn, ...)
    local ok, err = pcall(fn, ...)
    if ok then return false end
    return tostring(err)
  end
  out.requireIoIsShim = select(2, pcall(require, "io")) == io
  out.requireLoveFsIsShim =
    select(2, pcall(require, "love.filesystem")) == love.filesystem
  out.requireDebug = attempt(require, "debug")
  out.requirePackage = attempt(require, "package")
  out.requireFfi = attempt(require, "ffi")
  -- jit.util exposes bytecode/constant introspection over any function this
  -- chunk can reach -- the same class of escape the debug library is denied
  -- for -- so it must fail the same way require("debug") does rather than
  -- walking straight through under the bare "jit" global's cover.
  out.requireJitUtil = attempt(require, "jit.util")
  out.requireSocket = attempt(require, "socket")
  out.requireSemver = select(2, pcall(require, "src.mods.Semver"))

  out.loveThread = attempt(function() return love.thread end)
  out.loveGraphics = type(love.graphics)
  out.loveAssign = attempt(function() love.filesystem = {} end)
  -- the callback chain a mod wrapping the mouse writes: it has to reach the
  -- real love table or the wrap silently never fires
  out.chainedInner = false
  local inner = love.mousemoved
  love.mousemoved = function(...)
    out.chainedInner = true
    if inner then return inner(...) end
  end
  out.assignRun = attempt(function() love.run = function() end end)
  out.assignGarbage = attempt(function() love.mousemoved = 7 end)
  out.powerInfo = type(love.system.getPowerInfo)
  out.openUrl = love.system.openURL("https://example.com")
  -- tls* is forwarded from the real love.system when the engine hung it
  -- (Gen1Tls / Android JNI); without that it's just nil, not an error.
  out.tlsOpenType = type(love.system.tlsOpen)
  out.eventQuit = love.event.quit()
  out.popen = select(1, io.popen("ls"))

  -- the reroute: a write anywhere a mod used to name must land in the mod's
  -- own overlay, and reading it back must see the write and nothing else
  local escape = io.open("/etc/hosts", "w")
  out.escapeOpened = escape ~= nil
  if escape then
    escape:write("pwned")
    escape:close()
  end
  local reread = io.open("/etc/hosts", "r")
  out.escapeReadBack = reread and reread:read("*a") or nil
  if reread then reread:close() end

  out.homeEnv = os.getenv("HOME")
  out.saveDir = love.filesystem.getSaveDirectory()

  love.filesystem.write("cfg/settings.txt", "x=1\ny=2\n")
  out.roundTrip = love.filesystem.read("cfg/settings.txt")
  out.roundTripInfo = love.filesystem.getInfo("cfg/settings.txt")
  local lines = {}
  for line in love.filesystem.lines("cfg/settings.txt") do
    lines[#lines + 1] = line
  end
  out.roundTripLines = lines
  love.filesystem.append("cfg/settings.txt", "z=3\n")
  out.appended = love.filesystem.read("cfg/settings.txt")

  -- an absolute path built off the reported save directory comes back to the
  -- same overlay, which is what a legacy mod's own path joining does
  love.filesystem.write(out.saveDir .. "/cfg/settings.txt", "rooted")
  out.rootedRead = love.filesystem.read("cfg/settings.txt")

  -- the mod's own packaged files still read through the old call
  out.ownThroughLove = love.filesystem.read("mods/fix_sandbox/data/note.txt")
  out.ownThroughIo = (function()
    local f = io.open("data/note.txt", "r")
    if not f then return nil end
    local body = f:read("*a")
    f:close()
    return body
  end)()

  -- copy-on-write: writing over a packaged path shadows it, it does not
  -- rewrite the shipped file
  love.filesystem.write("mods/fix_sandbox/data/note.txt", "shadowed")
  out.shadowed = love.filesystem.read("mods/fix_sandbox/data/note.txt")
  out.shadowedOwn = mod:read("data/note.txt")

  -- the multi-file pattern mods/timekeepers_hut uses: a chunk loaded from the
  -- mod's own source must inherit the sandbox, not the real globals
  local child = load("return io, os.getenv, _G")
  local childIo, childGetenv, childG = child()
  out.childIoIsShim = childIo == io
  out.childGetenvIsShim = childGetenv == os.getenv
  out.childSharesEnv = childG == _G

  out.readEscape = attempt(function() return mod:read("../../secret.txt") end)
  out.readAbsolute = attempt(function() return mod:read("/etc/hosts") end)
  out.readBackslash = attempt(function() return mod:read("..\\secret.txt") end)
  out.assetsEscape = attempt(function() return mod.assets:path("../../x.png") end)
  out.readOwn = mod:read("data/note.txt")
  out.listAssets = mod:list("assets")
  out.listSprites = mod:list("assets/sprites")
  out.listRoot = mod:list()
  out.assetsList = mod.assets:list("assets")
  out.infoAssets = mod:info("assets")
  out.infoNote = mod:info("data/note.txt")
  out.infoMissing = mod:info("nope")
  out.listMissing = mod:list("nope")
  out.listEscape = attempt(function() return mod:list("../secret") end)
  out.infoEscape = attempt(function() return mod:info("../../x") end)

  _G.SANDBOX_LEAK = "escaped"
  out.globalsAreOwn = _G ~= nil and _G.SANDBOX_LEAK == "escaped"
  -- a mod stomping the standard library must not reach the engine
  table.insert = function() error("stomped") end
  string.format = function() error("stomped") end
]]

local FILES = {
  ["mods/fix_sandbox/manifest.json"] = manifest("fix_sandbox"),
  ["mods/fix_sandbox/main.lua"] = PROBE,
  ["mods/fix_sandbox/data/note.txt"] = "own file",
  ["mods/fix_sandbox/assets/front.png"] = "png",
  ["mods/fix_sandbox/assets/sprites/walk.png"] = "png",
}

LegacyCompat.reset()
local savedMouseMoved = love.mousemoved
local run = T.sdk.loadMods({ "mods/fix_sandbox" }, { fs = T.sdk.memfs(FILES) })
local installedMouseMoved = love.mousemoved
love.mousemoved = savedMouseMoved
T.eq(#run.errors, 0,
  "the probe mod loads clean (" .. tostring(run.errors[1]) .. ")")
local out = run.loader.exports.fix_sandbox or {}

-- ------- the pre-sandbox globals are stand-ins, not the real thing

T.eq(out.io, "table", "io is present again, as the compat stand-in")
T.eq(out.package, "table", "so is package, as an inert stub")
T.eq(out.dofile, "function", "dofile routes through the stand-in")
T.eq(out.loadfile, "function", "so does loadfile")
T.eq(out.osGetenv, "function", "os.getenv answers rather than crashing the mod")
T.eq(out.osTime, "function", "os.time still works: the clock was never the hole")
T.eq(out.stringOk, "aaa", "the safe standard library is intact")

-- what stays gone: there is no rerouted stand-in for these, so faking one
-- would be the hole rather than a compat shim
T.eq(out.setfenv, nil, "setfenv is still absent, so a mod cannot swap its own env")
T.eq(out.getfenv, nil, "getfenv is still absent, so a mod cannot read the real _G out")
T.eq(out.debug, nil, "the debug library is still absent")
T.check(out.loveThread ~= false, "love.thread is still refused: it opens a full Lua state")
T.check(out.requireFfi ~= false, "require(\"ffi\") is still refused: it is arbitrary C")
T.check(out.requireJitUtil ~= false,
  "require(\"jit.util\") is still refused: it is bytecode/constant introspection")
T.check(out.requireDebug ~= false, "require(\"debug\") is still refused")
T.check(out.requirePackage ~= false, "require(\"package\") is still refused")
T.eq(out.popen, nil, "io.popen refuses rather than spawning a process")
T.eq(out.openUrl, false, "love.system.openURL does nothing")
T.eq(out.eventQuit, false, "love.event.quit cannot close the game on the player")

-- ------- require answers with the same stand-ins

T.check(out.requireIoIsShim, "require(\"io\") hands back the same compat table")
T.check(out.requireLoveFsIsShim,
  "require(\"love.filesystem\") hands back the same compat table")
T.check(out.requireSocket and out.requireSocket:find("network", 1, true),
  "a network module still names the permission it needs: " .. tostring(out.requireSocket))
T.eq(type(out.requireSemver), "table",
  "the supported engine requires still resolve")

-- ------- the love facade

T.eq(out.loveGraphics, "table", "the rest of love passes through")
T.check(out.loveAssign ~= false,
  "a mod cannot replace a love module table: " .. tostring(out.loveAssign))
T.eq(out.powerInfo, "function",
  "love.system reads through to the same information mod.device exposes")
T.check(out.tlsOpenType == "function" or out.tlsOpenType == "nil",
  "tls* is readable through the system shim (nil until the engine hangs it)")

-- a wrapped callback has to land on the real table or the wrap never fires
T.eq(type(installedMouseMoved), "function",
  "love.mousemoved assigned by a mod reaches the real love table")
T.check(installedMouseMoved ~= savedMouseMoved,
  "and it is the mod's wrapper, not the one that was there")
T.check(out.assignRun and out.assignRun:find("fixed-step loop", 1, true),
  "love.run stays refused: it is the engine's own loop ("
  .. tostring(out.assignRun) .. ")")
T.check(out.assignGarbage ~= false,
  "and a callback slot only takes a function")

-- ------- containment: every rerouted write lands in the mod's own overlay

T.check(out.escapeOpened, "io.open on an absolute path outside the tree opens")
T.eq(out.escapeReadBack, "pwned", "and reads its own write back")
T.eq(FILES["/etc/hosts"], nil,
  "but nothing was written outside the game tree")
T.eq(FILES["mod_compat/fix_sandbox/etc/hosts"], "pwned",
  "the bytes went to this mod's private overlay instead")
T.eq(out.homeEnv, "/pokeport/fix_sandbox",
  "os.getenv(\"HOME\") answers with the mod's virtual root, not the real one")
T.eq(out.saveDir, "/pokeport/fix_sandbox",
  "and so does the reported save directory")

T.eq(out.roundTrip, "x=1\ny=2\n", "a love.filesystem write reads back")
T.eq(out.roundTripInfo and out.roundTripInfo.type, "file",
  "and getInfo sees it")
T.same(out.roundTripLines, { "x=1", "y=2" }, "lines() walks it")
T.eq(out.appended, "x=1\ny=2\nz=3\n", "append extends it")
T.eq(out.rootedRead, "rooted",
  "a path joined to the reported save directory routes to the same key")
T.eq(FILES["mod_compat/fix_sandbox/cfg/settings.txt"], "rooted",
  "one key in the overlay, under the mod's own id, however it was named")

-- ------- reads still see the mod's packaged files

T.eq(out.ownThroughLove, "own file",
  "love.filesystem.read of a path inside the mod reads the shipped file")
T.eq(out.ownThroughIo, "own file", "and so does io.open on a relative path")
T.eq(out.shadowed, "shadowed", "a write over a packaged path shadows it")
T.eq(FILES["mods/fix_sandbox/data/note.txt"], "own file",
  "without rewriting what the mod shipped")
T.eq(out.shadowedOwn, "own file",
  "and mod:read still reports the packaged bytes")

-- ------- the reroute is reported, not silent

do
  local report = run.loader:legacyReport("fix_sandbox")
  local calls = {}
  for _, row in ipairs(report) do calls[row.call] = row end
  T.check(calls["io.open"], "io.open is recorded against the mod")
  T.check(calls["love.filesystem.write"], "so is love.filesystem.write")
  T.check(calls["os.getenv"], "and os.getenv")
  T.check(calls["love.filesystem.write"].count >= 2,
    "with a count, so a manager can rank the worst offenders")
  T.check(calls["io.open"].advice and #calls["io.open"].advice > 0,
    "each row carries the advice the warning printed")
end

-- ------- env propagation and isolation

T.check(out.childIoIsShim,
  "a chunk a mod load()s inherits the sandbox (5.1 would hand it the real _G)")
T.check(out.childGetenvIsShim, "the child chunk gets the same rerouted os")
T.check(out.childSharesEnv, "the child chunk shares the mod's own globals table")
T.check(out.globalsAreOwn, "a mod's globals write to its own table")
T.eq(_G.SANDBOX_LEAK, nil, "and never reach the engine's _G")
T.eq(("%d"):format(1), "1",
  "a mod stomping string.format cannot reach the engine's copy")
do
  local probe = {}
  table.insert(probe, "still works")
  T.eq(probe[1], "still works",
    "nor table.insert -- each mod gets its own standard-library namespace")
end

-- ------- paths

T.check(out.readEscape and out.readEscape:find("must stay inside", 1, true),
  "mod:read cannot climb out of the mod directory: " .. tostring(out.readEscape))
T.check(out.readAbsolute ~= false, "mod:read refuses an absolute path")
T.check(out.readBackslash ~= false, "mod:read refuses a backslash climb")
T.check(out.assetsEscape ~= false, "mod.assets:path refuses a climb")
T.eq(out.readOwn, "own file", "and the mod's own files still read")
T.same(out.listAssets, { "front.png", "sprites" },
  "mod:list names the children of a directory inside the mod")
T.same(out.listSprites, { "walk.png" },
  "and a nested directory")
T.check(out.listRoot and out.listRoot[1] ~= nil,
  "mod:list() with no path lists the mod root")
T.same(out.assetsList, out.listAssets,
  "mod.assets:list is the same listing")
T.eq(out.infoAssets and out.infoAssets.type, "directory",
  "mod:info reports a directory")
T.eq(out.infoNote and out.infoNote.type, "file",
  "and a file")
T.eq(out.infoMissing, nil, "mod:info is nil for a missing path")
T.same(out.listMissing, {}, "mod:list of a missing path is empty, not an error")
T.check(out.listEscape and out.listEscape:find("must stay inside", 1, true),
  "mod:list cannot climb out of the mod directory: " .. tostring(out.listEscape))
T.check(out.infoEscape and out.infoEscape:find("must stay inside", 1, true),
  "mod:info cannot climb either")
run.release()

-- ------- two mods never share an overlay

do
  local files = {
    ["mods/one/manifest.json"] = manifest("one"),
    ["mods/one/main.lua"] = [[
      local mod = ...
      love.filesystem.write("shared.txt", "from one")
      mod.exports.mine = love.filesystem.read("shared.txt")
    ]],
    ["mods/two/manifest.json"] = manifest("two"),
    ["mods/two/main.lua"] = [[
      local mod = ...
      mod.exports.peek = love.filesystem.read("shared.txt")
      mod.exports.climb = love.filesystem.read("../one/shared.txt")
    ]],
  }
  local pair = T.sdk.loadMods({ "mods/one", "mods/two" },
    { fs = T.sdk.memfs(files) })
  T.eq(#pair.errors, 0, "both mods load (" .. tostring(pair.errors[1]) .. ")")
  T.eq(pair.loader.exports.one.mine, "from one", "the first mod sees its write")
  T.eq(pair.loader.exports.two.peek, nil,
    "the second mod, naming the same path, sees nothing")
  T.eq(files["mod_compat/one/shared.txt"], "from one",
    "because the overlay is keyed by mod id")
  T.eq(pair.loader.exports.two.climb, nil,
    "and a climb out of the overlay resolves inside it, not into the neighbour")
  pair.release()
end

-- ------- the grammar itself

for _, bad in ipairs({ "../x", "a/../../x", "/etc/hosts", "C:/Windows/x",
                       "..\\x", "a\\b", "..", ".", "" }) do
  T.eq(SafePath.safe(bad), nil, ("SafePath rejects %q"):format(bad))
end
T.eq(SafePath.safe("maps/NEW_BARK_TOWN.lua"), "maps/NEW_BARK_TOWN.lua",
  "an ordinary relative path passes")
T.eq(SafePath.safe("./main.lua"), "main.lua",
  "a leading ./ is normalized rather than rejected, so older manifests load")

-- ------- manifest paths are untrusted input too

T.check(not pcall(Manifest.validate,
  { id = "evil", name = "evil", version = "1.0.0", entry = "../../../evil.lua" }),
  "a manifest cannot point entry outside the mod directory")
T.check(not pcall(Manifest.validate,
  { id = "evil", name = "evil", version = "1.0.0", entry = "main.lua",
    options_schema = "../../options.lua" }),
  "nor options_schema")
T.check(pcall(Manifest.validate,
  { id = "fine", name = "fine", version = "1.0.0", entry = "main.lua" }),
  "an ordinary manifest still validates")

-- ------- bytecode

do
  local bad = {
    ["mods/fix_bytecode/manifest.json"] = manifest("fix_bytecode"),
    ["mods/fix_bytecode/main.lua"] = string.dump(function() end),
  }
  local bytecodeRun = T.sdk.loadMods({ "mods/fix_bytecode" },
    { fs = T.sdk.memfs(bad) })
  T.eq(#bytecodeRun.errors, 1, "a mod that ships bytecode fails to load")
  T.check(tostring(bytecodeRun.errors[1]):find("bytecode", 1, true),
    "and says why: " .. tostring(bytecodeRun.errors[1]))
  bytecodeRun.release()
end

-- ------- the sandbox with no compat layer is still closed

do
  local env = Sandbox.envFor({ modId = "probe" })
  T.eq(env.io, nil, "a bare Sandbox.envFor has no io")
  T.eq(env._G, env, "_G points at the sandbox, not the real globals")
  T.check(not pcall(env.require, "io"), "and its require refuses io")
end

T.finish("sandbox")

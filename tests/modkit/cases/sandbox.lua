-- T4: the mod sandbox (src/mods/Sandbox.lua).  A mod's own chunks run against
-- an environment with no io, no os beyond the clock, and no way to name a path
-- outside its own directory, so a mod cannot reach the player's filesystem.
-- Every case here is an escape a mod would actually try.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Manifest = require("src.mods.Manifest")
local Sandbox = require("src.mods.Sandbox")
local SafePath = require("src.mods.SafePath")

local function manifest(id, extra)
  return ('{"id":"%s","name":"%s","version":"1.0.0","entry":"main.lua",'
    .. '"api":2%s}'):format(id, id, extra or "")
end

-- what a probe reports back; pcall'd so one broken assumption does not take
-- the whole entry chunk down and hide the rest
local PROBE = [[
  local mod = ...
  local out = mod.exports
  out.io = io
  out.package = package
  out.dofile = dofile
  out.loadfile = loadfile
  out.setfenv = setfenv
  out.getfenv = getfenv
  out.debug = debug
  out.osGetenv = os.getenv
  out.osExecute = os.execute
  out.osRemove = os.remove
  out.osTime = type(os.time)
  out.stringOk = ("a"):rep(3)

  local function attempt(fn, ...)
    local ok, err = pcall(fn, ...)
    if ok then return false end
    return tostring(err)
  end
  out.requireIo = attempt(require, "io")
  out.requireOs = attempt(require, "os")
  out.requireDebug = attempt(require, "debug")
  out.requirePackage = attempt(require, "package")
  out.requireFfi = attempt(require, "ffi")
  out.requireLoveFs = attempt(require, "love.filesystem")
  out.requireSocket = attempt(require, "socket")
  -- called from a nested Lua frame rather than straight off pcall, which is
  -- the shape a stack-walking gate reads differently
  out.requireIoNested = attempt(function() return require("io") end)
  out.requireSemver = select(2, pcall(require, "src.mods.Semver"))

  out.loveFilesystem = attempt(function() return love.filesystem end)
  out.loveThread = attempt(function() return love.thread end)
  out.loveSystem = attempt(function() return love.system end)
  out.loveGraphics = type(love.graphics)
  out.loveAssign = attempt(function() love.filesystem = {} end)

  -- the multi-file pattern mods/timekeepers_hut uses: a chunk loaded from the
  -- mod's own source must inherit the sandbox, not the real globals
  local child = load("return io, os.getenv, _G")
  local childIo, childGetenv, childG = child()
  out.childIo = childIo
  out.childGetenv = childGetenv
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

local run = T.sdk.loadMods({ "mods/fix_sandbox" }, { fs = T.sdk.memfs(FILES) })
T.eq(#run.errors, 0,
  "the probe mod loads clean (" .. tostring(run.errors[1]) .. ")")
local out = run.loader.exports.fix_sandbox or {}

-- ------- the standard library a mod does not get

T.eq(out.io, nil, "io is absent from the mod environment")
T.eq(out.package, nil, "package is absent, so package.loaded is unreachable")
T.eq(out.dofile, nil, "dofile is absent")
T.eq(out.loadfile, nil, "loadfile is absent")
T.eq(out.setfenv, nil, "setfenv is absent, so a mod cannot swap its own env")
T.eq(out.getfenv, nil, "getfenv is absent, so a mod cannot read the real _G out")
T.eq(out.debug, nil, "the debug library is absent")
T.eq(out.osGetenv, nil, "os.getenv is absent -- it is how the report's exploit "
  .. "found the user's home directory")
T.eq(out.osExecute, nil, "os.execute is absent")
T.eq(out.osRemove, nil, "os.remove is absent")
T.eq(out.osTime, "function", "os.time still works: the clock is not the hole")
T.eq(out.stringOk, "aaa", "the safe standard library is intact")

-- ------- require, the one call that would undo all of the above

T.check(out.requireIo and out.requireIo:find("not available to mods", 1, true),
  "require(\"io\") is refused: " .. tostring(out.requireIo))
T.check(out.requireOs ~= false, "require(\"os\") is refused")
T.check(out.requireDebug ~= false, "require(\"debug\") is refused")
T.check(out.requirePackage ~= false, "require(\"package\") is refused")
T.check(out.requireFfi ~= false, "require(\"ffi\") is refused: it is arbitrary C")
T.check(out.requireLoveFs ~= false, "require(\"love.filesystem\") is refused")
T.check(out.requireIoNested ~= false,
  "require(\"io\") from a nested frame is refused the same way")
T.check(out.requireSocket and out.requireSocket:find("network", 1, true),
  "a network module names the permission it needs: " .. tostring(out.requireSocket))
T.eq(type(out.requireSemver), "table",
  "the supported engine requires still resolve")

-- ------- the love facade

T.check(out.loveFilesystem and out.loveFilesystem:find("mod.storage", 1, true),
  "love.filesystem is refused and names the replacement")
T.check(out.loveThread ~= false, "love.thread is refused: it opens a full Lua state")
T.check(out.loveSystem and out.loveSystem:find("mod.device:powerInfo()", 1, true),
  "love.system is refused and names the scoped power replacement")
T.eq(out.loveGraphics, "table", "the rest of love passes through")
T.check(out.loveAssign ~= false, "a mod cannot assign into the love facade")

-- ------- env propagation and isolation

T.eq(out.childIo, nil,
  "a chunk a mod load()s inherits the sandbox (5.1 would hand it the real _G)")
T.eq(out.childGetenv, nil, "the child chunk gets the same reduced os")
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

-- ------- the sandbox is not opt-in

do
  local env = Sandbox.envFor({ modId = "probe" })
  T.eq(env.io, nil, "a bare Sandbox.envFor is already closed")
  T.eq(env._G, env, "_G points at the sandbox, not the real globals")
  T.check(not pcall(env.require, "io"), "and its require refuses io")
end

T.finish("sandbox")

-- The "steps" permission gates the native step bridge (#1186): a
-- permissioned mod syncs and polls deliveries without ever seeing
-- love.system or the pending file; an unpermissioned mod gets a quiet
-- available() = false and loud, permission-naming refusals from the
-- calls that would act.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Steps = require("src.mods.Steps")

local WALKER = {
  ["mods/step_walker/manifest.json"] = [[{
    "id": "step_walker",
    "name": "Step Walker",
    "version": "1.0.0",
    "entry": "main.lua",
    "api": 2,
    "permissions": ["steps"]
  }]],
  ["mods/step_walker/main.lua"] = [[
    local mod = ...
    mod.exports.available = mod.steps:available()
    mod.exports.synced = mod.steps:sync()
    mod.exports.poll = function() return mod.steps:poll() end
  ]],
}

local SECOND = {
  ["mods/step_second/manifest.json"] = [[{
    "id": "step_second",
    "name": "Step Second",
    "version": "1.0.0",
    "entry": "main.lua",
    "api": 2,
    "permissions": ["steps"]
  }]],
  ["mods/step_second/main.lua"] = [[
    local mod = ...
    mod.exports.poll = function() return mod.steps:poll() end
  ]],
}

local UNPERMISSIONED = {
  ["mods/step_probe/manifest.json"] = [[{
    "id": "step_probe",
    "name": "Step Probe",
    "version": "1.0.0",
    "entry": "main.lua",
    "api": 2
  }]],
  ["mods/step_probe/main.lua"] = [[
    local mod = ...
    mod.exports.available = mod.steps:available()
    local ok, err = pcall(function() return mod.steps:sync() end)
    mod.exports.refused = not ok and tostring(err) or false
  ]],
}

local function merged(...)
  local out = {}
  for _, fixture in ipairs({ ... }) do
    for path, body in pairs(fixture) do out[path] = body end
  end
  return out
end

local savedSync = T.love.system.syncHealthSteps
local syncCalls = 0
T.love.system.syncHealthSteps = function()
  syncCalls = syncCalls + 1
  return true
end

-- no mod: the bridge stays cold and a pending delivery stays on disk
T.love.filesystem.write(Steps.PENDING, '{"steps": 4312}')
local vanilla = T.sdk.loadNone({})
T.eq(syncCalls, 0, "no mod leaves the step bridge cold")
T.check(T.love.filesystem.read(Steps.PENDING) ~= nil,
  "no mod leaves the pending delivery untouched")
vanilla.release()

-- a permissioned mod syncs and receives the delivery
local run = T.sdk.loadMods({ "mods/step_walker", "mods/step_second" },
  { fs = T.sdk.memfs(merged(WALKER, SECOND)) })
T.eq(#run.errors, 0,
  "the permissioned mods load clean (" .. tostring(run.errors[1]) .. ")")
local walker = run.loader.exports.step_walker
T.eq(walker.available, true, "available() sees the bridge")
T.eq(walker.synced, true, "sync() reaches the bridge")
T.eq(syncCalls, 1, "one sync call makes one bridge call")

local delivery = walker.poll()
T.check(delivery and delivery.steps == 4312,
  "poll() hands the mod the delivered step count")
T.check(T.love.filesystem.read(Steps.PENDING) == nil,
  "the engine consumed the pending file, not the mod")
T.eq(walker.poll(), nil, "a delivery is handed out once per mod")

local second = run.loader.exports.step_second
local secondDelivery = second.poll()
T.check(secondDelivery and secondDelivery.steps == 4312,
  "a second permissioned mod receives its own copy of the walk")
T.check(secondDelivery ~= delivery, "copies, not a shared table")

-- contract fields only, and a malformed delivery is dropped whole
T.love.filesystem.write(Steps.PENDING,
  '{"steps": 12, "from": "a", "to": "b", "path": "/etc/passwd"}')
delivery = walker.poll()
T.eq(delivery.steps, 12, "the steps field travels")
T.eq(delivery.from, "a", "the from field travels")
T.eq(delivery.path, nil, "fields outside the contract do not travel")
T.love.filesystem.write(Steps.PENDING, "not json at all")
T.eq(walker.poll(), nil, "a malformed delivery is dropped, not raised")
T.check(T.love.filesystem.read(Steps.PENDING) == nil,
  "and the bad file does not wedge the pump")
run.release()

-- without the permission: quiet probe, loud act
local probe = T.sdk.loadMods({ "mods/step_probe" },
  { fs = T.sdk.memfs(UNPERMISSIONED) })
T.eq(#probe.errors, 0,
  "the unpermissioned mod loads clean (" .. tostring(probe.errors[1]) .. ")")
local out = probe.loader.exports.step_probe
T.eq(out.available, false, "available() is quietly false without the permission")
T.check(out.refused and out.refused:find('"steps" permission', 1, true),
  "sync() without the permission names it")
probe.release()

-- no bridge on this build: sync reports it, nothing raises
T.love.system.syncHealthSteps = nil
local ashore = T.sdk.loadMods({ "mods/step_walker" },
  { fs = T.sdk.memfs(WALKER) })
local dry = ashore.loader.exports.step_walker
T.eq(dry.available, false, "available() is false without a native bridge")
T.eq(dry.synced, false, "sync() reports there was no bridge to ask")
ashore.release()

T.love.system.syncHealthSteps = savedSync
T.love.filesystem.remove(Steps.PENDING)
T.finish("steps_bridge")

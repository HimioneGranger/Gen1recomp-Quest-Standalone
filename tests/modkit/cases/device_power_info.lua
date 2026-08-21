-- A sandboxed mod may read battery state without receiving love.system and
-- its process-launching surface.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")

local FIXTURE = {
  ["mods/power_probe/manifest.json"] = [[{
    "id": "power_probe",
    "name": "Power Probe",
    "version": "1.0.0",
    "entry": "main.lua",
    "api": 2
  }]],
  ["mods/power_probe/main.lua"] = [[
    local mod = ...
    mod.exports.state, mod.exports.percent = mod.device:powerInfo()
  ]],
}

local saved = T.love.system.getPowerInfo
local calls = 0
T.love.system.getPowerInfo = function()
  calls = calls + 1
  return "charging", 42, 900
end

local vanilla = T.sdk.loadNone({})
T.eq(calls, 0, "no mod leaves the device power backend cold")
vanilla.release()

local run = T.sdk.loadMods({ "mods/power_probe" },
  { fs = T.sdk.memfs(FIXTURE) })
T.eq(#run.errors, 0,
  "the sandboxed power probe loads clean (" .. tostring(run.errors[1]) .. ")")
local out = run.loader.exports.power_probe or {}
T.eq(out.state, "charging", "the public facade reports battery state")
T.eq(out.percent, 42, "the public facade reports battery percentage")
T.eq(calls, 1, "one facade read makes one platform call")
run.release()

T.love.system.getPowerInfo = nil
local unavailable = T.sdk.loadMods({ "mods/power_probe" },
  { fs = T.sdk.memfs(FIXTURE) })
out = unavailable.loader.exports.power_probe or {}
T.eq(out.state, "unknown", "a missing platform backend has a stable state")
T.eq(out.percent, nil, "a missing platform backend has no invented percentage")
unavailable.release()

T.love.system.getPowerInfo = saved
T.finish("device_power_info")

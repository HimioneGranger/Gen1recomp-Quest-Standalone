-- The Quest engine-owned conductor must refresh independently of the optional
-- matched VRXR/VRGL transport payload. A missing packaging companion once
-- left an old writable VR.lua active and restored the 12-map preload policy.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local writes, logs = {}, {}

love = {
  system = { getOS = function() return "Android" end },
  filesystem = {
    read = function(path)
      if path == "src/quest/dramaless/VR.lua" then
        return "return { candidate = 'bounded' }"
      end
      -- Deliberately omit lib/VRXR.lua, lib/VRGL.lua and writable adapter
      -- targets: only conductor independence is under test here.
      return nil
    end,
    write = function(path, data)
      writes[path] = data
      return true
    end,
  },
}

package.loaded.ffi = {
  cdef = function() end,
  C = {
    questxr_request_panel_capture = function() end,
    questxr_poll_input = function() return 0 end,
    questxr_poll_held_input = function() return 0 end,
    questxr_log = function(message) logs[#logs + 1] = tostring(message) end,
  },
}

package.loaded["src.quest.PanelBridge"] = nil
require("src.quest.PanelBridge")

T.eq(writes["mods/DRAMALESS_SHAPE/lib/VR.lua"],
  "return { candidate = 'bounded' }",
  "engine conductor refresh does not depend on packaged VRXR/VRGL")
T.eq(writes["mods/DRAMALESS_SHAPE/lib/VRXR.lua"], nil,
  "missing transport is retained instead of replaced with invalid data")
T.eq(writes["mods/DRAMALESS_SHAPE/lib/VRGL.lua"], nil,
  "missing VRGL is retained instead of replaced with invalid data")

local retained
for _, line in ipairs(logs) do
  if line:find("retained installed transport", 1, true) then retained = true end
end
T.check(retained, "missing optional transport is explicitly logged")

local handle = assert(io.open(
  "mobile/android/love/src/jni/questxr_bridge/questxr_bridge.c", "rb"))
local native = handle:read("*a")
handle:close()
T.check(native:find("right_magnitude2", 1, true) ~= nil,
  "launcher event selection reads the right thumbstick")
T.check(native:find("event_stick", 1, true) ~= nil,
  "launcher logs which thumbstick produced navigation")
T.check(native:find("if (left_magnitude2 > 0.1225f)", 1, true) ~= nil,
  "held gameplay movement remains gated by the left thumbstick")

T.finish("Quest panel bridge install/input contract")

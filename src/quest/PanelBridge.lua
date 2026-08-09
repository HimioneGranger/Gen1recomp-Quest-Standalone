-- Copies the finished LÖVE window into the native Quest OpenXR quad.
-- Inert everywhere except an Android build exporting the native bridge.

local PanelBridge = {}
local C
local elapsed = 0
local bit = require("bit")

do
  if love.system.getOS() ~= "Android" then return PanelBridge end
  local ok, ffi = pcall(require, "ffi")
  if not ok then return PanelBridge end
  pcall(ffi.cdef, [[
    void questxr_capture_panel_gl(int width, int height);
    void questxr_log(const char *message);
    unsigned int questxr_poll_input(void);
  ]])
  local libraries = {
    function() return ffi.C end,
    function() return ffi.load("love") end,
    function() return ffi.load("liblove.so") end,
  }
  for _, resolve in ipairs(libraries) do
    local okLib, lib = pcall(resolve)
    if okLib and lib and pcall(function()
        return lib.questxr_capture_panel_gl, lib.questxr_poll_input
      end) then
      C = lib
      break
    end
  end
  if C then pcall(C.questxr_log, "Lua fixed-buffer panel bridge linked") end

  -- Quest builds carry the matching OpenXR handoff module beside the game.
  -- Refresh only Dramatic Shape's VR transport file; ROMs, saves, manifests,
  -- settings, and all other mod files remain user-owned and untouched.
  local replacement = love.filesystem.read("lib/VRXR.lua")
  if C and replacement and replacement:find("questxr_request_launcher_shutdown", 1, true) then
    local okWrite = love.filesystem.write(
      "mods/DRAMATIC_SHAPE/lib/VRXR.lua", replacement)
    pcall(C.questxr_log, okWrite and
      "Dramatic Shape Quest OpenXR handoff installed" or
      "Dramatic Shape Quest OpenXR handoff install failed")
  end
end

function PanelBridge.update(dt)
  elapsed = elapsed + (dt or 0)
  if not C then return end
  local ok, events = pcall(C.questxr_poll_input)
  if not ok then
    pcall(C.questxr_log, "Lua Quest input poll failed")
    return
  end
  events = tonumber(events)
  if not events or events == 0 then return end
  pcall(C.questxr_log, "Lua dispatching Quest input")
  local keys = {
    { 1, "up" }, { 2, "down" }, { 4, "left" }, { 8, "right" },
    { 16, "return" }, { 32, "escape" },
  }
  for _, binding in ipairs(keys) do
    if bit.band(events, binding[1]) ~= 0 then
      love.keypressed(binding[2], binding[2], false)
    end
  end
end

function PanelBridge.capture()
  if not C or elapsed < (1 / 15) then return end
  elapsed = 0
  local dimensions = love.graphics.getPixelDimensions or love.graphics.getDimensions
  local width, height = dimensions()
  pcall(C.questxr_capture_panel_gl, width, height)
end

return PanelBridge

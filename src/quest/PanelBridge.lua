-- Copies the finished LÖVE window into the native Quest OpenXR quad.
-- Inert everywhere except an Android build exporting the native bridge.

local PanelBridge = {}
local C
local elapsed = 0

do
  if love.system.getOS() ~= "Android" then return PanelBridge end
  local ok, ffi = pcall(require, "ffi")
  if not ok then return PanelBridge end
  pcall(ffi.cdef, [[
    void questxr_capture_panel_gl(int width, int height);
    void questxr_log(const char *message);
  ]])
  local libraries = {
    function() return ffi.C end,
    function() return ffi.load("love") end,
    function() return ffi.load("liblove.so") end,
  }
  for _, resolve in ipairs(libraries) do
    local okLib, lib = pcall(resolve)
    if okLib and lib and pcall(function()
        return lib.questxr_capture_panel_gl
      end) then
      C = lib
      break
    end
  end
  if C then pcall(C.questxr_log, "Lua fixed-buffer panel bridge linked") end
end

function PanelBridge.update(dt)
  elapsed = elapsed + (dt or 0)
end

function PanelBridge.capture()
  if not C or elapsed < (1 / 15) then return end
  elapsed = 0
  local dimensions = love.graphics.getPixelDimensions or love.graphics.getDimensions
  local width, height = dimensions()
  pcall(C.questxr_capture_panel_gl, width, height)
end

return PanelBridge

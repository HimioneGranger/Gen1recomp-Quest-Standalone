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
  ]])
  local okLib, lib = pcall(ffi.load, "love")
  if okLib and lib and pcall(function()
      return lib.questxr_capture_panel_gl
    end) then
    C = lib
  elseif pcall(function() return ffi.C.questxr_capture_panel_gl end) then
    C = ffi.C
  end
end

function PanelBridge.update(dt)
  elapsed = elapsed + (dt or 0)
end

function PanelBridge.capture()
  if not C or elapsed < (1 / 15) then return end
  elapsed = 0
  local width, height = love.graphics.getPixelDimensions()
  pcall(C.questxr_capture_panel_gl, width, height)
end

return PanelBridge

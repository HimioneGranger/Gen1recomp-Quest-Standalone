-- Optional Quest OpenXR display transport. This module owns no launcher,
-- gameplay, or mod policy; it only forwards completed engine frames to the
-- flavor-scoped native host.
local QuestOpenXRDisplay = {}

local function newBackend(native)
  local backend = { native = native, elapsed = 0 }

  function backend:update(dt)
    self.elapsed = self.elapsed + (dt or 0)
  end

  function backend:endFrame()
    if self.elapsed < (1 / 15) then return end
    self.elapsed = 0
    local dimensions = love.graphics.getPixelDimensions
      or love.graphics.getDimensions
    local width, height = dimensions()
    pcall(self.native.questxr_capture_panel_gl, width, height)
  end

  return backend
end

function QuestOpenXRDisplay.detect()
  if not love or not love.system or love.system.getOS() ~= "Android" then
    return nil
  end
  local ok, ffi = pcall(require, "ffi")
  if not ok then return nil end
  pcall(ffi.cdef, [[
    void questxr_capture_panel_gl(int width, int height);
    void questxr_log(const char *message);
  ]])
  for _, library in ipairs({ "questxr", "libquestxr.so" }) do
    local loaded, native = pcall(ffi.load, library)
    if loaded and native and pcall(function()
        return native.questxr_capture_panel_gl
      end) then
      pcall(native.questxr_log, "generic HostDisplay bridge linked")
      return newBackend(native)
    end
  end
end

QuestOpenXRDisplay._newForTests = newBackend

return QuestOpenXRDisplay

-- Optional Quest OpenXR display transport. This module owns no launcher,
-- gameplay, or mod policy; it only forwards completed engine frames to the
-- flavor-scoped native host.
local QuestOpenXRDisplay = {}

local INPUT_KEYS = {
  { 1, "up" }, { 2, "down" }, { 4, "left" }, { 8, "right" },
  { 16, "return" }, { 32, "escape" },
}

local function newBackend(native)
  local backend = { native = native, elapsed = 0 }

  function backend:update(dt)
    self.elapsed = self.elapsed + (dt or 0)
    local ok, events = pcall(self.native.questxr_poll_input)
    events = ok and tonumber(events) or 0
    if not events or events == 0 then return end
    for _, binding in ipairs(INPUT_KEYS) do
      if self.bit.band(events, binding[1]) ~= 0 then
        local key = binding[2]
        love.keypressed(key, key, false)
        love.keyreleased(key, key)
      end
    end
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
    unsigned int questxr_poll_input(void);
  ]])
  for _, library in ipairs({ "questxr", "libquestxr.so" }) do
    local loaded, native = pcall(ffi.load, library)
    if loaded and native and pcall(function()
        return native.questxr_capture_panel_gl
      end) then
      pcall(native.questxr_log, "generic HostDisplay bridge linked")
      local backend = newBackend(native)
      backend.bit = require("bit")
      return backend
    end
  end
end

function QuestOpenXRDisplay._newForTests(native, bitLibrary)
  local backend = newBackend(native)
  backend.bit = bitLibrary or require("bit")
  return backend
end

return QuestOpenXRDisplay

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
    void questxr_set_focus_rect(float x, float y, float width, float height);
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
  if C then
    _G.QUEST_PANEL_ACTIVE = true
    pcall(C.questxr_log, "Lua fixed-buffer panel bridge linked")
  end

  -- Quest builds carry the matching OpenXR handoff module beside the game.
  -- Refresh only Dramatic Shape's VR transport file; ROMs, saves, manifests,
  -- settings, and all other mod files remain user-owned and untouched.
  local replacement = love.filesystem.read("lib/VRXR.lua")
  local questVR = love.filesystem.read("lib/VR.lua")
  local questVRGL = love.filesystem.read("lib/VRGL.lua")
  if C and replacement and questVR and questVRGL
      and replacement:find("questxr_request_launcher_shutdown", 1, true) then
    local okXR = love.filesystem.write(
      "mods/DRAMATIC_SHAPE/lib/VRXR.lua", replacement)
    local okVR = love.filesystem.write(
      "mods/DRAMATIC_SHAPE/lib/VR.lua", questVR)
    local okVRGL = love.filesystem.write(
      "mods/DRAMATIC_SHAPE/lib/VRGL.lua", questVRGL)
    pcall(C.questxr_log, okXR and okVR and okVRGL and
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
      local key = binding[2]
      if key == "up" or key == "down" or key == "left" or key == "right" then
        -- Native input arrives during update, after the previous immediate-mode
        -- frame has already built a complete navigation graph. Resolve against
        -- that graph now so the visible ring changes on the very next draw.
        local okKit, Kit = pcall(require, "src.ui.kit.Kit")
        if okKit and Kit then
          local before = tostring(Kit.focusId)
          Kit.navigate(key)
          Kit._resolveNav()
          pcall(C.questxr_log, ("Quest focus %s: %s -> %s"):format(
            key, before, tostring(Kit.focusId)))
        else
          love.keypressed(key, key, false)
        end
      else
        love.keypressed(key, key, false)
      end
    end
  end
end

function PanelBridge.capture()
  if not C then return end
  local pixelDimensions = love.graphics.getPixelDimensions or love.graphics.getDimensions
  local pixelWidth, pixelHeight = pixelDimensions()
  local width, height = love.graphics.getDimensions()
  local okKit, Kit = pcall(require, "src.ui.kit.Kit")
  local target
  if okKit and Kit and Kit.focusId then
    for i = 1, Kit._navN or 0 do
      local candidate = Kit._nav[i]
      if candidate and candidate.id == Kit.focusId then
        target = candidate
        break
      end
    end
  end
  if target then
    -- Lua UI coordinates start at the top-left; GL texture coordinates start
    -- at the bottom-left. Expand slightly so the native ring sits outside the
    -- control instead of covering its label.
    local pad = 6
    pcall(C.questxr_set_focus_rect,
      math.max(0, target.x - pad) / width,
      math.max(0, height - target.y - target.h - pad) / height,
      math.min(width, target.w + pad * 2) / width,
      math.min(height, target.h + pad * 2) / height)
  else
    pcall(C.questxr_set_focus_rect, -1, -1, 0, 0)
  end
  if elapsed < (1 / 15) then return end
  elapsed = 0
  pcall(C.questxr_capture_panel_gl, pixelWidth, pixelHeight)
end

return PanelBridge

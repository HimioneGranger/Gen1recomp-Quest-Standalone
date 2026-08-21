-- Optional Quest OpenXR display transport. This module owns no launcher,
-- gameplay, or mod policy; it only forwards completed engine frames to the
-- flavor-scoped native host.
local QuestOpenXRDisplay = {}

local INPUT_KEYS = {
  { 1, "up" }, { 2, "down" }, { 4, "left" }, { 8, "right" },
  { 16, "return" }, { 32, "escape" },
}

-- The launcher owns its focus graph; the native host only needs the focused
-- rectangle in normalized panel coordinates. Keeping this lookup in the
-- flavor-scoped adapter leaves the generic HostDisplay contract and vanilla
-- rendering unchanged.
local function focusTarget(kind)
  if kind ~= "launcher" then return nil end
  local ok, Kit = pcall(require, "src.ui.kit.Kit")
  if not ok or not Kit or not Kit.focusId then return nil end
  for i = 1, Kit._navN or 0 do
    local candidate = Kit._nav[i]
    if candidate and candidate.id == Kit.focusId then
      return candidate, Kit
    end
  end
end

-- Resolve the control under the virtual pointer from the launcher's previous
-- completed immediate-mode frame. Activating its stable id alongside the
-- synthetic mouse click makes controller Select deterministic even when
-- Android's hidden SDL mouse state interferes with the polled click path.
local function activatePointerTarget(subject)
  if not subject or not subject._padCursor then return nil end
  local ok, Kit = pcall(require, "src.ui.kit.Kit")
  if not ok or not Kit then return nil end
  local x, y = subject._padCursor.x, subject._padCursor.y
  local count = Kit._navPrevN or Kit._navN or 0
  local target, targetArea
  local nearest, nearestDistance
  for i = count, 1, -1 do
    local candidate = Kit._nav[i]
    if candidate then
      if x >= candidate.x and x <= candidate.x + candidate.w
          and y >= candidate.y and y <= candidate.y + candidate.h then
        local area = candidate.w * candidate.h
        if not targetArea or area < targetArea then
          target, targetArea = candidate, area
        end
      else
        local closestX = math.max(candidate.x,
          math.min(candidate.x + candidate.w, x))
        local closestY = math.max(candidate.y,
          math.min(candidate.y + candidate.h, y))
        local dx, dy = x - closestX, y - closestY
        local distance = dx * dx + dy * dy
        if not nearestDistance or distance < nearestDistance then
          nearest, nearestDistance = candidate, distance
        end
      end
    end
  end
  -- VR rays naturally tremble at control edges. Use a scaled magnetic margin
  -- around the nearest registered control, matching the forgiving targets in
  -- Quest system UI without making arbitrary blank panel space clickable.
  if not target and nearest then
    local margin = 48 * (Kit.scale or 1)
    if nearestDistance <= margin * margin then target = nearest end
  end
  if not target or not target.id then return nil end
  Kit.setFocus(target.id)
  Kit.activateFocused()
  return target.id
end

local function focusRect(kind, subject)
  -- Once the launcher's own pointer is active it is the sole visible input
  -- affordance. Keeping the compositor focus border as well would show two
  -- cursors that can disagree.
  if subject and subject._padCursorActive then return -1, -1, 0, 0 end
  local target = focusTarget(kind)
  if not target then return -1, -1, 0, 0 end
  local dimensions = love.graphics.getDimensions
  local width, height = dimensions()
  if not width or not height or width <= 0 or height <= 0 then
    return -1, -1, 0, 0
  end
  local pad = 6
  return math.max(0, target.x - pad) / width,
    math.max(0, height - target.y - target.h - pad) / height,
    math.min(width, target.w + pad * 2) / width,
    math.min(height, target.h + pad * 2) / height
end

local function pointerState(kind, subject)
  if kind ~= "launcher" or not subject or not subject._padCursorActive
      or not subject._padCursor then
    return -1, -1, 0
  end
  local width, height = love.graphics.getDimensions()
  if not width or not height or width <= 0 or height <= 0 then
    return -1, -1, 0
  end
  local x = math.max(0, math.min(width, subject._padCursor.x or 0))
  local y = math.max(0, math.min(height, subject._padCursor.y or 0))
  -- LÖVE addresses UI from the top-left; the GLES panel texture is sampled
  -- from the bottom-left.
  return x / width, (height - y) / height, 1
end

local function newBackend(native, axisX, axisY, pointerX, pointerY, pointerActive)
  local backend = {
    apiVersion = 1,
    native = native, elapsed = 0,
    axisX = axisX, axisY = axisY,
    pointerX = pointerX, pointerY = pointerY, pointerActive = pointerActive,
  }

  function backend:update(dt)
    self.elapsed = self.elapsed + (dt or 0)
    local launcher = self.kind == "launcher" and self.subject or nil
    if launcher and self.pendingActivation then
      self.pendingActivation.frames = self.pendingActivation.frames - 1
      if self.pendingActivation.frames <= 0 then
        local queued = launcher._uiActions and #launcher._uiActions or 0
        pcall(self.native.questxr_log,
          ("launcher activation result target=%s settings=%s gameManage=%s work=%s queued=%d")
            :format(self.pendingActivation.id,
              tostring(launcher._settings ~= nil),
              tostring(launcher._gameManage ~= nil),
              tostring(launcher.workState), queued))
        self.pendingActivation = nil
      end
    end
    if launcher and type(launcher.gamepadaxis) == "function"
        and self.axisX and self.axisY then
      launcher._hostPointerComposited = true
      if not self.systemCursorHidden and love.mouse
          and type(love.mouse.setVisible) == "function" then
        pcall(love.mouse.setVisible, false)
        self.systemCursorHidden = true
      end
      -- The launcher normally yields its virtual pad cursor whenever the
      -- desktop mouse moves. On Quest SDL's hidden system pointer does not
      -- represent user intent, but its stale coordinates can still trip that
      -- desktop-only handoff before the cursor is drawn. Refresh the launcher's
      -- comparison baseline immediately before its update so Touch input keeps
      -- ownership of the visible virtual cursor. This adapter is packaged only
      -- in the Quest flavor; stock desktop and Android keep their normal mouse
      -- handoff behavior.
      if love.mouse and type(love.mouse.getPosition) == "function" then
        local mouseOk, mx, my = pcall(love.mouse.getPosition)
        if mouseOk then
          launcher._lastMouseX, launcher._lastMouseY = mx, my
        end
      end
      local axesOk = pcall(function()
        self.native.questxr_poll_pointer_axes(self.axisX, self.axisY)
      end)
      local pointerOk = self.pointerX and self.pointerY and self.pointerActive
        and pcall(function()
          self.native.questxr_poll_pointer_position(
            self.pointerX, self.pointerY, self.pointerActive)
        end)
      local rayActive = pointerOk and tonumber(self.pointerActive[0]) ~= 0
      if rayActive then
        local width, height = love.graphics.getDimensions()
        launcher._padCursor.x = math.max(0, math.min(width,
          (tonumber(self.pointerX[0]) or 0) * width))
        launcher._padCursor.y = math.max(0, math.min(height,
          (1 - (tonumber(self.pointerY[0]) or 0)) * height))
        launcher._padCursorActive = true
        launcher:gamepadaxis(nil, "leftx", 0)
        launcher:gamepadaxis(nil, "lefty", 0)
        if not self.pointerMetricsLogged then
          self.pointerMetricsLogged = true
          local pixelWidth, pixelHeight = width, height
          if love.graphics.getPixelDimensions then
            pixelWidth, pixelHeight = love.graphics.getPixelDimensions()
          end
          pcall(self.native.questxr_log,
            ("pointer metrics logical=%dx%d pixel=%dx%d ray=%.3f,%.3f cursor=%.1f,%.1f")
              :format(width, height, pixelWidth, pixelHeight,
                tonumber(self.pointerX[0]) or 0,
                tonumber(self.pointerY[0]) or 0,
                launcher._padCursor.x, launcher._padCursor.y))
        end
      elseif axesOk then
        -- OpenXR stick Y is positive up; LÖVE/gamepad Y is positive down.
        launcher:gamepadaxis(nil, "leftx", tonumber(self.axisX[0]) or 0)
        launcher:gamepadaxis(nil, "lefty", -(tonumber(self.axisY[0]) or 0))
      end
    end
    local ok, events = pcall(self.native.questxr_poll_input)
    events = ok and tonumber(events) or 0
    if not events or events == 0 then return end
    for _, binding in ipairs(INPUT_KEYS) do
      if self.bit.band(events, binding[1]) ~= 0 then
        local key = binding[2]
        local handled = false
        if launcher then
          if key == "up" or key == "down"
              or key == "left" or key == "right" then
            -- Continuous axes drive the launcher's existing virtual mouse.
            -- Consume the old flick edge so it cannot move a second cursor.
            handled = true
          elseif key == "return" then
            if type(launcher.gamepadpressed) == "function" then
              -- Use the established virtual-pointer click path. It already
              -- covers every launcher panel, modal, importer, and mod action.
              local targetId = activatePointerTarget(launcher)
              launcher:gamepadpressed(nil, "a")
              if targetId then
                -- The immediate-mode button queues during the next draw and
                -- its owner executes that queue in the following update. Log
                -- two host ticks later so physical tests prove the action's
                -- resulting state, not merely that a trigger edge arrived.
                self.pendingActivation = { id = targetId, frames = 2 }
              end
              handled = true
              pcall(self.native.questxr_log,
                ("launcher pointer clicked x=%.1f y=%.1f target=%s"):format(
                  launcher._padCursor.x, launcher._padCursor.y,
                  tostring(targetId or "none")))
            end
          elseif key == "escape" and type(launcher.keypressed) == "function" then
            launcher:keypressed("escape")
            handled = true
          end
        end
        if not handled then
          love.keypressed(key, key, false)
          love.keyreleased(key, key)
        end
      end
    end
  end

  function backend:endFrame(kind, subject)
    self.kind, self.subject = kind, subject
    local px, py, visible = pointerState(kind, subject)
    pcall(self.native.questxr_set_panel_pointer, px, py, visible)
    if self.elapsed < (1 / 15) then return end
    self.elapsed = 0
    local fx, fy, fw, fh = focusRect(kind, subject)
    -- Queue only the panel metadata here. The optional Android presentation
    -- observer captures pixels after LÖVE flushes its batched UI draws and
    -- before SDL swaps the completed default framebuffer.
    pcall(self.native.questxr_request_panel_capture, fx, fy, fw, fh)
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
    void questxr_request_panel_capture(
      float focus_x, float focus_y, float focus_width, float focus_height);
    void questxr_log(const char *message);
    unsigned int questxr_poll_input(void);
    void questxr_poll_pointer_axes(float *x, float *y);
    void questxr_poll_pointer_position(float *x, float *y, int *active);
    void questxr_set_panel_pointer(float x, float y, int visible);
  ]])
  for _, library in ipairs({ "questxr", "libquestxr.so" }) do
    local loaded, native = pcall(ffi.load, library)
    if loaded and native and pcall(function()
        return native.questxr_request_panel_capture
      end) then
      -- Compatibility capability for VR mods that must keep the native
      -- launcher session alive until gameplay has constructed a world.  The
      -- flag is published only after the Quest-flavor bridge is positively
      -- identified, so desktop and stock Android retain their exact behavior.
      _G.QUEST_PANEL_ACTIVE = true
      pcall(native.questxr_log, "generic HostDisplay bridge linked")
      local backend = newBackend(native,
        ffi.new("float[1]"), ffi.new("float[1]"),
        ffi.new("float[1]"), ffi.new("float[1]"), ffi.new("int[1]"))
      backend.bit = require("bit")
      return backend
    end
  end
end

function QuestOpenXRDisplay._newForTests(native, bitLibrary)
  local backend = newBackend(native,
    { [0] = 0 }, { [0] = 0 }, { [0] = 0 }, { [0] = 0 }, { [0] = 0 })
  backend.bit = bitLibrary or require("bit")
  return backend
end

return QuestOpenXRDisplay

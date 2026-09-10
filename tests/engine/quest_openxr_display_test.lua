-- Quest's packaged display adapter is transport-only and rate-limits native
-- capture without changing the generic HostDisplay contract.
-- Self-contained: luajit tests/engine/quest_openxr_display_test.lua
package.path = "./?.lua;./?/init.lua;" .. package.path
if not _G.love then _G.love = require("tests.love_stub") end

local T = require("tests.harness")
local check, eq = T.check, T.eq
local Provider = require("src.host.android.QuestOpenXRDisplay")

local captures = {}
local pointers = {}
local axisX, axisY = 0, 0
local rayX, rayY, rayActive = 0, 0, 0
local native = {
  questxr_poll_input = function() return 0 end,
  questxr_poll_pointer_axes = function(x, y)
    x[0], y[0] = axisX, axisY
  end,
  questxr_poll_pointer_position = function(x, y, active)
    x[0], y[0], active[0] = rayX, rayY, rayActive
  end,
  questxr_request_panel_capture = function(fx, fy, fw, fh)
    captures[#captures + 1] = { fx, fy, fw, fh }
  end,
  questxr_set_panel_pointer = function(x, y, visible)
    pointers[#pointers + 1] = { x, y, visible }
  end,
}
local oldDimensions = love.graphics.getDimensions
love.graphics.getDimensions = function() return 1000, 500 end
local oldMousePosition = love.mouse.getPosition
love.mouse.getPosition = function() return 123, 45 end
local oldMouseVisible = love.mouse.setVisible
local mouseVisible = true
love.mouse.setVisible = function(value) mouseVisible = value end

local Kit = require("src.ui.kit.Kit")
local oldFocusId, oldNavN = Kit.focusId, Kit._navN
local oldNavPrevN = Kit._navPrevN
local oldActivateId = Kit._activateId
local oldFirstNav = Kit._nav[1]
local oldSecondNav = Kit._nav[2]
Kit.focusId = "play-yellow"
Kit._navN, Kit._navPrevN = 2, 2
Kit._nav[1] = { id = "play-yellow", x = 100, y = 50, w = 200, h = 100 }
Kit._nav[2] = { id = "save-slot", x = 100, y = 200, w = 200, h = 100 }

local padAxes, padButtons, launcherKeys = {}, {}, {}
local backend = Provider._newForTests(native)
local launcher
launcher = {
  _flex = true,
  _padCursor = { x = 500, y = 225 },
  gamepadaxis = function(_, _, axis, value)
    padAxes[axis] = value
    if math.abs(value) > 0.28 then launcher._padCursorActive = true end
  end,
  gamepadpressed = function(_, _, button)
    padButtons[#padButtons + 1] = button
  end,
  keypressed = function(_, key) launcherKeys[#launcherKeys + 1] = key end,
}
check(type(backend) == "table", "test factory returns a backend")
eq(backend.apiVersion, 1, "Quest display backend uses HostDisplay API v1")
eq(backend.beginFrame, nil, "adapter does not invent a beginFrame policy")
-- HostDisplay learns the active draw subject from a completed frame. Seed the
-- launcher once before its next update, matching LÖVE's update/draw cadence.
backend:endFrame("launcher", launcher)
backend:update(1 / 30)
eq(launcher._lastMouseX, 123,
  "Quest pointer owns the launcher's desktop-mouse handoff baseline")
eq(launcher._lastMouseY, 45,
  "Quest pointer records both hidden SDL mouse coordinates")
backend:endFrame("launcher", launcher)
eq(#captures, 0, "capture is rate-limited below 15 Hz")
eq(pointers[1][3], 0, "inactive launcher pointer is hidden by the compositor")
backend:update(1 / 30)
backend:endFrame("launcher", launcher)
eq(#captures, 1, "completed frame is captured at the 15 Hz boundary")
check(math.abs(captures[1][1] - 0.094) < 0.000001,
  "launcher focus x is normalized with padding")
check(math.abs(captures[1][2] - 0.688) < 0.000001,
  "launcher focus y is converted to panel coordinates")
check(math.abs(captures[1][3] - 0.212) < 0.000001,
  "launcher focus width is normalized with padding")
check(math.abs(captures[1][4] - 0.224) < 0.000001,
  "launcher focus height is normalized with padding")
axisX, axisY = 0.5, -0.25
backend:update(1 / 15)
eq(padAxes.leftx, 0.5, "Quest left stick X drives the launcher pointer")
eq(padAxes.lefty, 0.25, "OpenXR stick Y is converted to launcher coordinates")
rayX, rayY, rayActive = 0.2, 0.7, 1
backend:update(0)
check(math.abs(launcher._padCursor.x - 200) < 0.000001,
  "Touch aim ray controls launcher pointer X")
check(math.abs(launcher._padCursor.y - 150) < 0.000001,
  "Touch aim ray converts panel Y to launcher coordinates")
eq(padAxes.leftx, 0, "Touch aim ray suppresses thumbstick pointer X")
eq(padAxes.lefty, 0, "Touch aim ray suppresses thumbstick pointer Y")
check(backend.systemCursorHidden,
  "Quest launcher hides the stale SDL cursor beneath its controller target")
check(launcher._hostPointerComposited,
  "Quest launcher suppresses its delayed captured software cursor")
backend:endFrame("launcher", launcher)
eq(#captures, 2, "another completed frame consumes a new capture budget")
check(math.abs(pointers[#pointers][1] - 0.2) < 0.000001,
  "launcher pointer X is normalized for the compositor")
check(math.abs(pointers[#pointers][2] - 0.7) < 0.000001,
  "launcher pointer Y is converted to panel coordinates")
eq(pointers[#pointers][3], 1, "active launcher pointer is compositor-visible")
eq(captures[2][1], -1, "active pointer disables the second host focus affordance")
eq(captures[2][2], -1, "disabled focus border has no panel position")
eq(captures[2][3], 0, "disabled focus border has no width")
eq(captures[2][4], 0, "disabled focus border has no height")
backend:endFrame("game", {})
eq(pointers[#pointers][3], 0, "gameplay hides the launcher pointer")
eq(#captures, 3,
  "the first completed game frame retires the cached loading panel immediately")
backend:endFrame("launcher", launcher)
eq(#captures, 4,
  "the first completed launcher frame also retires stale game presentation")

local pressed, released = {}, {}
local oldPressed, oldReleased = love.keypressed, love.keyreleased
love.keypressed = function(key) pressed[#pressed + 1] = key end
love.keyreleased = function(key) released[#released + 1] = key end
native.questxr_poll_input = function() return 2 end
backend:update(0)
eq(Kit.focusId, "play-yellow",
  "legacy direction edges do not also move the pointer's fallback ring")
eq(#pressed, 0, "launcher direction does not create a second queued key edge")
native.questxr_poll_input = function() return 16 end
Kit.focusId = "save-slot"
rayX, rayY = 0.075, 0.85
backend:update(0)
eq(table.concat(padButtons, ","), "a",
  "launcher Select uses the existing virtual-pointer click path")
eq(Kit.focusId, "play-yellow",
  "launcher Select magnetically activates a nearby Quest ray target")
check(backend.pendingActivation and backend.pendingActivation.id == "play-yellow",
  "Quest Select schedules action-result diagnostics for its resolved target")
eq(mouseVisible, false, "Quest controller target hides the SDL mouse arrow")
eq(#pressed, 0, "handled launcher Select does not also emit Return")
native.questxr_poll_input = function() return 32 end
backend:update(0)
eq(table.concat(launcherKeys, ","), "escape",
  "launcher Back is delivered to the visible launcher")
eq(#pressed, 0, "handled launcher Back does not emit a duplicate key tap")
eq(#released, 0, "handled launcher Back emits no orphan key release")
love.keypressed, love.keyreleased = oldPressed, oldReleased

Kit.focusId, Kit._navN, Kit._navPrevN = oldFocusId, oldNavN, oldNavPrevN
Kit._activateId = oldActivateId
Kit._nav[1], Kit._nav[2] = oldFirstNav, oldSecondNav
love.graphics.getDimensions = oldDimensions
love.mouse.getPosition = oldMousePosition
love.mouse.setVisible = oldMouseVisible

T.finish("Quest OpenXR display")

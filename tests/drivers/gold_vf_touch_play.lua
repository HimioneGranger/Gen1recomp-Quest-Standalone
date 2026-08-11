-- INDEPENDENT VERIFICATION that the Gold on-screen pad actually PLAYS the
-- game, not just that it sets a flag in src/core/Input.lua.
--
-- The three presses a phone player cannot do without, each read at a different
-- place in Game2's fixed step:
--
--   d-pad   -> World:pollInput, the walk itself
--   START   -> the wasPressed("start") arm that opens the start menu
--   SELECT  -> the wasPressed("select") arm, UseRegisteredItem
--              (engine/overworld/select_menu.asm)
--
-- START and SELECT are edge reads, so this is also the check that the
-- overlay's press survives Input:step's per-tick edge promotion -- a hold that
-- never produces an edge would leave the menus unreachable even though
-- Input:isDown said the button was down.  Everything goes through the global
-- LOVE callbacks, the way a finger does.
--
--   POKEPORT_GAME=gold POKEPORT_TOUCH=1 \
--     POKEPORT_DRIVER=tests/drivers/gold_vf_touch_play.lua love .
--   POKEPORT_SHOT_DIR=/tmp/gold-vf-touchplay   (default)
local U = require("tests.drivers.util")

local Input = require("src.core.Input")
local TouchControls = require("src.core.TouchControls")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-vf-touchplay"
  local failures = 0

  local function ok(label, condition, detail)
    if condition then
      print("[vf-play] ok   " .. label)
    else
      failures = failures + 1
      print("[vf-play] FAIL " .. label .. " " .. tostring(detail))
    end
  end

  local function finger(id, x, y, frames)
    love.touchpressed(id, x, y, 0, 0, 1)
    U.wait(frames or 6)
    love.touchreleased(id, x, y, 0, 0, 1)
    U.wait(6)
  end

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")
  ok("the pad is up over the overworld", TouchControls:visible())
  local L = TouchControls:layout()

  -- WALK.  Hold a d-pad direction long enough for OWPlayerInput to take the
  -- step, and check the player actually moved a cell.
  local x0, y0 = world.player.cellX, world.player.cellY
  local moved, tries = false, 0
  for _, dir in ipairs({ "down", "up", "left", "right" }) do
    if moved then break end
    tries = tries + 1
    local dx = (dir == "left" and -0.4) or (dir == "right" and 0.4) or 0
    local dy = (dir == "up" and -0.4) or (dir == "down" and 0.4) or 0
    love.touchpressed("walk", L.dpad.cx + L.dpad.w * dx,
      L.dpad.cy + L.dpad.w * dy, 0, 0, 1)
    U.wait(40)
    love.touchreleased("walk", L.dpad.cx + L.dpad.w * dx,
      L.dpad.cy + L.dpad.w * dy, 0, 0, 1)
    U.wait(10)
    if world.player.cellX ~= x0 or world.player.cellY ~= y0 then moved = true end
  end
  ok("a finger on the d-pad walks the player", moved,
    ("%d,%d -> %d,%d after %d directions"):format(x0, y0,
      world.player.cellX, world.player.cellY, tries))
  U.shot(game, out .. "/01-walked.png")

  -- START.  The overworld arm is an edge read (input:wasPressed), so a hold
  -- that never promotes to an edge would leave the menu unreachable.
  local before = #game.stack.states
  finger("start", L.start.cx, L.start.cy, 8)
  U.wait(12)
  local menu = game.stack:top()
  ok("a finger on START opens the start menu",
    #game.stack.states > before and menu ~= nil,
    #game.stack.states .. " states")
  U.shot(game, out .. "/02-start-menu.png")

  -- B backs out of it, so the pad can leave the menu it just opened.
  finger("b", L.b.cx, L.b.cy, 8)
  U.wait(12)
  ok("and a finger on B backs out of it",
    #game.stack.states == before, #game.stack.states)

  -- SELECT.  Nothing is registered, so UseRegisteredItem takes CantUseItem's
  -- "nothing registered" arm -- which is still a text box, i.e. proof the
  -- press reached the arm rather than quitting the process (the old
  -- Game2:gamepadpressed answered `back` with love.event.quit()).
  finger("select", L.select.cx, L.select.cy, 8)
  U.wait(20)
  ok("a finger on SELECT reaches UseRegisteredItem",
    #game.stack.states > before or world:busy(),
    #game.stack.states .. " states, busy=" .. tostring(world:busy()))
  U.shot(game, out .. "/03-select.png")

  -- And the controller's own SELECT, which is what bug 3 was about: `back` is
  -- SDL's name for the DualSense CREATE button (the shipped controller DB row
  -- "PS5 Controller,...,back:b8,...") and GamepadMap binds it to GB SELECT.
  -- The process must still be alive after it.
  love.gamepadpressed(nil, "back")
  U.wait(2)
  ok("a controller `back` presses GB SELECT instead of quitting",
    Input:isDown("select"))
  love.gamepadreleased(nil, "back")
  U.wait(2)
  ok("and releases it", not Input:isDown("select"))
  ok("the process is still running", love.window ~= nil)

  print(failures == 0 and "PASS gold_vf_touch_play"
    or ("FAIL gold_vf_touch_play (%d)"):format(failures))
  love.event.quit(failures == 0 and 0 or 1)
end

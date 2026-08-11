-- The mobile on-screen pad, on Gold.  Gen 1 has had it since #415
-- (src/core/TouchControls.lua, Xelu's CC0 art in assets/touch/); Gold drew
-- nothing at all, so a phone player without a controller had no way to press
-- anything.  Same module, same art, same options.touchControls layout -- what
-- was missing was every seam in src/core/Game2.lua that has to reach it.
--
--   POKEPORT_TOUCH=1 POKEPORT_GAME=gold \
--     POKEPORT_DRIVER=tests/drivers/gold_touch_controls.lua love .
--   POKEPORT_SHOT_DIR=/tmp/gold-touch   (default)
--
-- POKEPORT_TOUCH=1 is what forces the overlay onto a desktop, and main.lua
-- then routes the mouse into love.touch* as a stand-in finger, which is the
-- same path a real finger takes -- so driving Game2:touchpressed here exercises
-- exactly what a phone does.
--
--   01-pad.png     the pad over the overworld, nothing held
--   02-pressed.png A and RIGHT held, both controls lit
--
-- The assertions are the half a picture cannot show: that a press on a control
-- actually reaches Input as a GB button under the overlay's own source name,
-- that the d-pad swaps direction on a slide without ever double-holding, that a
-- captured touch is NOT offered to the mod pointer hook, and that a controller
-- press puts the pad away.
local U = require("tests.drivers.util")

local Input = require("src.core.Input")
local TouchControls = require("src.core.TouchControls")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-touch"
  local failures = 0

  local function ok(label, condition, detail)
    if condition then
      print("[touch] ok   " .. label)
    else
      failures = failures + 1
      print("[touch] FAIL " .. label .. " " .. tostring(detail))
    end
  end

  U.wait(45)
  assert(game.world and game.world.map, "gold world did not boot")

  ok("Game2 owns the shared overlay", game.touchControls == TouchControls)
  ok("POKEPORT_TOUCH=1 forces it on for this desktop run",
    TouchControls.active == true)
  ok("and it has art to draw", TouchControls:visible(),
    tostring(TouchControls.img))
  if not TouchControls:visible() then
    print("FAIL gold_touch_controls (no overlay)")
    love.event.quit(1)
    return
  end

  local L = TouchControls:layout()
  U.shot(game, out .. "/01-pad.png")

  -- A: press, hold, release.  The overlay presses GB buttons through
  -- Input:overlayPressed rather than a keyboard alias, so isTouchDown is the
  -- proof it went through the pad and not through some other source.
  game:touchpressed("f1", L.a.cx, L.a.cy)
  ok("a finger on A holds GB A", Input:isDown("a"))
  ok("under the overlay's own input source", Input:isTouchDown("a"))

  -- The d-pad, and the slide between directions the pad exists for.
  game:touchpressed("f2", L.dpad.cx + L.dpad.w * 0.4, L.dpad.cy)
  ok("a finger right of the d-pad centre holds RIGHT", Input:isDown("right"))
  U.shot(game, out .. "/02-pressed.png")
  game:touchmoved("f2", L.dpad.cx, L.dpad.cy - L.dpad.w * 0.4)
  ok("sliding it up swaps the hold to UP", Input:isDown("up"))
  ok("and RIGHT is no longer held", not Input:isDown("right"))

  game:touchreleased("f2", L.dpad.cx, L.dpad.cy - L.dpad.w * 0.4)
  ok("lifting it drops UP", not Input:isDown("up"))
  ok("without dropping A, which another finger still owns", Input:isDown("a"))
  game:touchreleased("f1", L.a.cx, L.a.cy)
  ok("and lifting that finger drops A", not Input:isDown("a"))

  -- Two fingers on one button: the second must not double-press it, and
  -- lifting one must not release the other's hold (TouchControls.held counts).
  game:touchpressed("f3", L.b.cx, L.b.cy)
  game:touchpressed("f4", L.b.cx + 1, L.b.cy + 1)
  game:touchreleased("f3", L.b.cx, L.b.cy)
  ok("two fingers on B: lifting one keeps B held", Input:isDown("b"))
  game:touchreleased("f4", L.b.cx + 1, L.b.cy + 1)
  ok("lifting the second drops it", not Input:isDown("b"))

  -- The pointer seam (#807): a touch the pad captured belongs to the pad for
  -- its whole life and must never be offered to a mod.
  game.modPointers = nil
  game:touchpressed("f5", L.start.cx, L.start.cy)
  ok("a captured touch never becomes a mod pointer",
    game.modPointers == nil or game.modPointers.f5 == nil)
  game:touchreleased("f5", L.start.cx, L.start.cy)

  -- A controller press puts the pad away until the next screen touch.  The
  -- release matters: `a` is GB A on the pad map too, and a hold left standing
  -- here would be indistinguishable from the overlay pressing it below.
  game:gamepadpressed(nil, "a")
  game:gamepadreleased(nil, "a")
  ok("a controller press hides the pad", not TouchControls:visible())
  game:touchpressed("f6", L.a.cx, L.a.cy)
  ok("and the next touch only brings it back, it does not press",
    TouchControls:visible() and not Input:isDown("a"))
  game:touchreleased("f6", L.a.cx, L.a.cy)

  -- SELECT on a controller.  `back` is SDL's name for the PS CREATE/SHARE
  -- button (and Xbox VIEW, and Switch MINUS); src/core/GamepadMap.lua maps it
  -- to GB SELECT, and Game2 used to swallow it with love.event.quit().
  game:gamepadpressed(nil, "back")
  ok("the pad's back/CREATE button presses GB SELECT", Input:isDown("select"))
  game:gamepadreleased(nil, "back")
  ok("and releases it", not Input:isDown("select"))

  print(failures == 0 and "PASS gold_touch_controls"
    or ("FAIL gold_touch_controls (%d)"):format(failures))
  love.event.quit(failures == 0 and 0 or 1)
end

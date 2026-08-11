-- INDEPENDENT VERIFICATION of the Gold on-screen pad, taken from the angle a
-- phone actually uses it: the BOOT CINEMA, through LOVE's own callbacks.
--
-- tests/drivers/gold_touch_controls.lua drives game:touchpressed directly and
-- only ever with the overworld up.  That leaves two things unproven, and both
-- are the difference between "a mobile player can start Gold" and "a mobile
-- player is stuck on the title screen":
--
--   1. love.touchpressed -> main.lua -> Game2:touchpressed is the REAL route
--      (main.lua:672-720 picks the service owner up out of its `Game` local,
--      which is the Game2 instance for a Gold boot -- main.lua:247).  A pad
--      wired only where a driver reaches it would still be dead on a phone.
--   2. Game2:drawHud is called on every return path of Game2:draw, including
--      the pre-world cinema, and TouchControls:init happens in Game2:load --
--      before the copyright splash -- so the pad must be up and pressable on
--      the title screen, which is the first thing that ever asks for a button.
--
--   POKEPORT_GAME=gold POKEPORT_TOUCH=1 POKEPORT_BOOT_CINEMA=1 \
--     POKEPORT_DRIVER=tests/drivers/gold_vf_touch_boot.lua love .
--   POKEPORT_SHOT_DIR=/tmp/gold-vf-touchboot   (default)
local U = require("tests.drivers.util")

local Input = require("src.core.Input")
local TouchControls = require("src.core.TouchControls")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-vf-touchboot"
  local failures = 0

  local function ok(label, condition, detail)
    if condition then
      print("[vf-touch] ok   " .. label)
    else
      failures = failures + 1
      print("[vf-touch] FAIL " .. label .. " " .. tostring(detail))
    end
  end

  -- A press the way a finger delivers one: through the global LOVE callback,
  -- not through the game object.
  local function finger(id, x, y, frames)
    love.touchpressed(id, x, y, 0, 0, 1)
    U.wait(frames or 6)
    love.touchreleased(id, x, y, 0, 0, 1)
    U.wait(4)
  end

  U.wait(20)
  ok("the pad is up before the world exists", TouchControls:visible(),
    tostring(TouchControls.active))
  ok("boot cinema really is running (no world yet)", game.world == nil,
    game.phase)

  local L = TouchControls:layout()
  assert(L and L.a and L.start, "no pad layout")

  -- Walk the cinema with the pad alone: copyright -> GameFreak -> intro ->
  -- title -> main menu.  Nothing but the overlay presses a button here.
  local seen, lastTop = {}, nil
  local reachedMenu = false
  for _ = 1, 90 do
    local top = game.stack:top()
    if top ~= lastTop then
      lastTop = top
      seen[#seen + 1] = top
    end
    if game.world or (game.phase == "boot" and #seen >= 4) then
      reachedMenu = true
      break
    end
    finger("boot", L.a.cx, L.a.cy, 8)
  end
  ok("the pad alone walked the boot cinema forward", #seen >= 3,
    #seen .. " screens")
  ok("and got past the title screen without a keyboard", reachedMenu,
    tostring(game.phase))
  U.shot(game, out .. "/01-boot-pad.png")

  -- The pad is still the thing pressing: hold A down through the real
  -- callbacks and check Input sees it under the overlay's own source.
  love.touchpressed("hold", L.a.cx, L.a.cy, 0, 0, 1)
  U.wait(2)
  ok("a finger on A during the cinema reaches Input", Input:isDown("a"))
  ok("under the overlay's source, not a keyboard alias",
    Input:isTouchDown("a"))
  U.shot(game, out .. "/02-held.png")
  love.touchreleased("hold", L.a.cx, L.a.cy, 0, 0, 1)
  U.wait(2)
  ok("and lifting it releases", not Input:isDown("a"))

  -- Focus loss with a finger down: LOVE has no touchcancelled, so without the
  -- reset in Game2:focus a held overlay button is stranded forever.
  love.touchpressed("stranded", L.b.cx, L.b.cy, 0, 0, 1)
  U.wait(2)
  ok("B is held before focus is taken away", Input:isDown("b"))
  game:focus(false)
  U.wait(2)
  ok("losing focus frees the held pad button", not Input:isDown("b"))
  game:focus(true)
  U.wait(2)

  print(failures == 0 and "PASS gold_vf_touch_boot"
    or ("FAIL gold_vf_touch_boot (%d)"):format(failures))
  love.event.quit(failures == 0 and 0 or 1)
end

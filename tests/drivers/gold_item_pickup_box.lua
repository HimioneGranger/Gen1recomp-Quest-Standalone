-- The seam gold_giveitem_box.lua measures, on the OTHER two scripts that hand
-- the player an item in the overworld.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_item_pickup_box.lua love .
--
-- FindItemInBallScript (engine/events/misc_scripts.asm:10-19) is
-- `opentext / writetext .FoundItemText / playsound SFX_ITEM / pause 60 /
-- itemnotify / closetext`, and FruitTreeScript (engine/events/fruit_trees.asm
-- :17-25) is `writetext ObtainedFruitText / callasm PickedFruitTree /
-- specialsound / itemnotify`.  Neither has a `waitbutton` between the found
-- line and the itemnotify line: both print into the ONE MapTextbox the script's
-- own `opentext` opened, and nothing takes it down in between.
--
-- So the same rule as GiveItemScript applies: no frame between the two pages
-- may render with an empty state stack, because that is a visible tear-down of
-- the box AND it lets Game2's play clock (wGameTimerPaused, which is only held
-- while a state is on the stack) come off pause mid-pickup.
local U = require("tests.drivers.util")
local HiddenItems = require("src.world.gen2.HiddenItems")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-item-pickup"

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  local function clockFrames()
    local t = game.save.playTime
    return ((t.hours * 60 + t.minutes) * 60 + t.seconds) * 60 + t.frames
  end

  -- Same sampling shape as gold_giveitem_box: every frame is looked at, and
  -- the A press goes in every sixth, so the seam between two pages is never
  -- stepped over by a sample that only lands on press frames.
  local function measure(label, script, shotPrefix)
    game.save.playTime = { hours = 0, minutes = 0, seconds = 0, frames = 0 }
    world.vm:start(script)
    local bare, boxes, seenFirst = 0, 0, false
    local clockFirst, clockLast
    local shots, pressIn = 0, 8
    for _ = 1, 1200 do
      if not world:busy() and seenFirst then break end
      local top = game.stack:top()
      if top then
        if not seenFirst then
          seenFirst = true
          clockFirst = clockFrames()
        end
        clockLast = clockFrames()
        if shots < 2 and boxes % 12 == 6 then
          shots = shots + 1
          U.shot(game, ("%s/%s-%02d-page.png"):format(out, shotPrefix, shots))
        end
        boxes = boxes + 1
      elseif seenFirst then
        bare = bare + 1
      end
      pressIn = pressIn - 1
      if pressIn <= 0 then
        pressIn = 6
        game.input.pressQueue[#game.input.pressQueue + 1] = "a"
        game.input.state.a = true
        U.wait(1)
        game.input.state.a = false
      else
        U.wait(1)
      end
    end
    local spent = (clockLast or 0) - (clockFirst or 0)
    print(("[driver] %s: %d box frames, %d bare frames, clock ran %d frames")
      :format(label, boxes, bare, spent))
    assert(seenFirst, label .. ": no text box ever went up")
    return bare, spent
  end

  -- FindItemInBallScript, exactly as World:interact builds it for every Poke
  -- Ball on the floor.  Object 1 stands in for LAST_TALKED; `disappear` on an
  -- object this map may not have is a no-op, which is fine here -- the seam
  -- being measured is the text, not the despawn.
  local ballBare, ballClock = measure("item ball",
    HiddenItems.ballPickupScript("POTION", 1, 1,
      function(want, id) return world:sfxIdNamed(want, id) end),
    "ball")

  U.wait(20)

  -- FruitTreeScript.  Tree 1 is FRUITTREE_ROUTE_29 (the BERRY on Route 29).
  -- The script's own `callasm TryResetFruitTrees` clears wFruitTreeFlags on
  -- the first examine after the daily rollover, so a fresh boot takes the arm
  -- that actually hands the fruit over rather than "There's nothing here".
  local treeBare, treeClock = measure("fruit tree",
    { { op = "opentext" }, { op = "fruittree", args = { 1 } } },
    "tree")

  assert(ballBare == 0,
    ("the overworld drew bare for %d frames inside ONE FindItemInBallScript "
     .. "textbox"):format(ballBare))
  assert(ballClock == 0,
    ("the play clock ran %d frames while an item ball was picked up")
      :format(ballClock))
  assert(treeBare == 0,
    ("the overworld drew bare for %d frames inside ONE FruitTreeScript "
     .. "textbox"):format(treeBare))
  assert(treeClock == 0,
    ("the play clock ran %d frames while a berry was picked"):format(treeClock))
  print("[driver] PASS gold item pickup single box in " .. out)
  love.event.quit()
end

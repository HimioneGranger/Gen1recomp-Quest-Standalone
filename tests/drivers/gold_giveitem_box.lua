-- GiveItemScript (engine/overworld/scripting.asm:441-449) is ONE MapTextbox.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_giveitem_box.lua love .
--
-- `writetext .ReceivedItemText / iffalse .Full / waitsfx / specialsound /
-- waitbutton / itemnotify`: the received line and the "put it in the pocket"
-- line print into the SAME box, which the caller's `opentext` opened and the
-- caller's `closetext` closes.  Nothing between them takes the box down.
--
-- This port draws a box per message, so the seam between them is where the
-- fidelity is: the second box has to go up inside the same frame the first
-- one pops.  If a frame renders with an empty state stack in between, the box
-- visibly tears down and rebuilds AND Game2's play clock -- which only ticks
-- while the overworld is the top state (src/core/Game2.lua, wGameTimerPaused)
-- -- comes off pause for the length of the gap.
--
-- The run counts the bare-overworld frames between the two boxes and the
-- play-clock frames they cost, and shoots both pages.
local U = require("tests.drivers.util")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-giveitem"

  local function tap(button)
    game.input.pressQueue[#game.input.pressQueue + 1] = button
    game.input.state[button] = true
    U.wait(2)
    game.input.state[button] = false
    U.wait(2)
  end

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  game.save.playTime = { hours = 0, minutes = 0, seconds = 0, frames = 0 }
  local function clockFrames()
    local t = game.save.playTime
    return ((t.hours * 60 + t.minutes) * 60 + t.seconds) * 60 + t.frames
  end

  -- `opentext / verbosegiveitem POTION, 1 / closetext / end`, the shape every
  -- NPC hand-over in the game uses.
  world.vm:start({
    { op = "opentext" },
    { op = "verbosegiveitem", args = { "POTION", 1 } },
    { op = "closetext" },
    { op = "end" },
  })

  -- Sampled every frame, and the A press goes in every sixth: a sample taken
  -- only on press frames would step straight over the seam being measured.
  local bare, boxes, seenFirst = 0, 0, false
  local clockAtFirstBox, clockAtLastBox = nil, nil
  local shots, pressIn = 0, 8
  for _ = 1, 900 do
    if not world:busy() and seenFirst then break end
    local top = game.stack:top()
    if top then
      if not seenFirst then
        seenFirst = true
        clockAtFirstBox = clockFrames()
      end
      clockAtLastBox = clockFrames()
      if shots < 2 and boxes % 12 == 6 then
        shots = shots + 1
        U.shot(game, ("%s/%02d-page.png"):format(out, shots))
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

  local spent = (clockAtLastBox or 0) - (clockAtFirstBox or 0)
  print(("[driver] %d frames with a box up, %d bare frames between the pages")
    :format(boxes, bare))
  print(("[driver] the play clock advanced %d frames across the exchange")
    :format(spent))
  assert(seenFirst, "no text box ever went up for the item")
  assert(bare == 0,
    ("the overworld drew bare for %d frames between the two pages of one "
     .. "GiveItemScript textbox"):format(bare))
  assert(spent == 0,
    ("the play clock ran for %d frames while an item was being handed over")
      :format(spent))
  print("[driver] PASS gold giveitem single box in " .. out)
  love.event.quit()
end

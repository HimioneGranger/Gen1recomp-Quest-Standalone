-- FreezeAllOtherObjects (engine/overworld/scripting.asm:751-755): the FIRST
-- act of every `applymovement`, before it has even read the movement pointer.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_freeze_other_objects.lua love .
--
-- FreezeAllObjects sets FROZEN_F on every object struct and ApplyMovement then
-- clears it on the one being moved (engine/overworld/map_objects.asm:2529),
-- and nothing puts it back until EndScript's UnfreezeAllObjects.  So from the
-- moment a Rocket grunt starts walking at you -- SeenByTrainerScript's
-- `applymovementlasttalked` (engine/events/trainer_scripts.asm:14) -- until
-- his after-battle line is done, NOBODY else on the floor turns.
--
-- RADIO_TOWER_4F is the test bench: DJ MARY's teacher at (14,6) is
-- SPRITEMOVEDATA_SPINRANDOM_SLOW (maps/RadioTower4F.asm:263) and stands well
-- clear of the grunt at (5,6), so she is a pure observer.  She must roll new
-- facings before the trainer engages, hold ONE facing for the whole exchange,
-- and start rolling again once it is over.
local U = require("tests.drivers.util")
local Mon = require("src.battle.gen2.Mon")

local TEACHER, GRUNT = 2, 4 -- def.objects indices

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-freeze"

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  game.save.party = { assert(Mon.new(game.data, "TYPHLOSION", 60)) }

  -- Every Rocket on this floor carries EVENT_RADIO_TOWER_ROCKET_TAKEOVER
  -- (maps/RadioTower4F.asm:265), which the story clears when Team Rocket moves
  -- in.  Read the flag off the object rather than naming a number.
  world:setMap("RADIO_TOWER_4F", 10, 10, "up")
  U.wait(5)
  world.events:set(world.map.def.objects[4].eventFlag, false)
  world:setMap("RADIO_TOWER_4F", 10, 10, "up")
  U.wait(20)
  -- (10,10) shares no row and no column with any sight cone on the floor.  The
  -- map's own stairs land at (5,9), three cells below the grunt at (5,6), who
  -- faces DOWN with sight 3 -- land there with a party and the trainer script
  -- is already running before the idle window opens.
  local function obj(index)
    for _, npc in ipairs(world.npcs) do
      if npc.def and npc.def.index == index then return npc end
    end
    return nil
  end
  local teacher = obj(TEACHER)
  local grunt = obj(GRUNT)
  assert(teacher, "RADIO_TOWER_4F has no teacher at index " .. TEACHER)
  assert(grunt, "RADIO_TOWER_4F has no grunt at index " .. GRUNT)
  assert(teacher.def.movement == 3,
    "the teacher is not SPINRANDOM_SLOW, got " .. tostring(teacher.def.movement))

  -- Facing CHANGES over a window, plus any frame the object was holding
  -- FROZEN_F.  The facing count is the behaviour; the flag is the mechanism,
  -- and it is the one that does not depend on a random re-roll picking a
  -- different quarter (SPINRANDOM_SLOW holds 60-180 frames and may well roll
  -- the same way twice).
  local function watch(frames)
    local changes, frozen, last = 0, 0, teacher.facing
    for _ = 1, frames do
      if teacher.facing ~= last then
        changes = changes + 1
        last = teacher.facing
      end
      if teacher.frozen then frozen = frozen + 1 end
      U.wait(1)
    end
    return changes, frozen
  end

  -- Idle: nothing is frozen, because no script has run an applymovement.
  local idleTurns, idleFrozen = watch(600)
  print(("[driver] idle: %d facing changes, %d frozen frames")
    :format(idleTurns, idleFrozen))
  U.shot(game, out .. "/00-idle.png")
  assert(idleFrozen == 0, "the teacher was frozen with no script running")

  -- The freeze starts at the FIRST applymovement, not at the first command:
  -- SeenByTrainerScript spends `showemote EMOTE_SHOCK, LAST_TALKED, 30` before
  -- it walks (engine/events/trainer_scripts.asm:12-14), and on the cart the
  -- floor is still live through the bubble.  Latch the moment ApplyMovement
  -- runs and only hold the port to the flag from there on.
  local walked = false
  local realBegin = world.beginMovement
  world.beginMovement = function(self, objectId, bytes, onDone)
    walked = true
    return realBegin(self, objectId, bytes, onDone)
  end

  -- Engage: stand in the grunt's line and let the eyesight test fire.
  grunt.facing = "down"
  world.player.cellX, world.player.cellY = grunt.cellX, grunt.cellY + 3
  world.player.px = world.player.cellX * 16
  world.player.py = world.player.cellY * 16
  local fired = false
  for _ = 1, 120 do
    if world:busy() then fired = true break end
    world:checkTrainerBattle()
    U.wait(1)
  end
  assert(fired, "the grunt never noticed the player")

  -- Hold: every frame the world is busy, right through the battle and the
  -- after-battle text.
  local held = teacher.facing
  local drift, busyFrames, thawed = 0, 0, 0
  for _ = 1, 2400 do
    local top = game.stack:top()
    if top and top.battle then
      for _ = 1, 900 do
        if top.battle.over then break end
        game.input.pressQueue[#game.input.pressQueue + 1] = "a"
        game.input.state.a = true
        U.wait(2)
        game.input.state.a = false
        U.wait(2)
      end
    end
    if world:busy() then
      busyFrames = busyFrames + 1
      if walked then
        if teacher.facing ~= held then drift = drift + 1 end
        if not teacher.frozen then thawed = thawed + 1 end
      else
        held = teacher.facing
      end
    elseif busyFrames > 60 then
      break
    end
    game.input.pressQueue[#game.input.pressQueue + 1] = "a"
    game.input.state.a = true
    U.wait(1)
    game.input.state.a = false
    U.wait(1)
  end
  print(("[driver] %d busy frames: %d facing changes, %d frames unfrozen")
    :format(busyFrames, drift, thawed))
  U.shot(game, out .. "/01-during.png")
  assert(busyFrames > 60, "the exchange was too short to prove anything")
  assert(thawed == 0,
    ("the teacher was unfrozen on %d of %d script frames; ApplyMovement's "
     .. "FreezeAllOtherObjects holds every object but the one being moved")
      :format(thawed, busyFrames))
  assert(drift == 0,
    "the teacher kept spinning through the trainer exchange")

  -- Release: EndScript's UnfreezeAllObjects gives every object its movement
  -- function back.
  local afterTurns, afterFrozen = watch(600)
  print(("[driver] after: %d facing changes, %d frozen frames")
    :format(afterTurns, afterFrozen))
  U.shot(game, out .. "/02-after.png")
  assert(afterFrozen == 0,
    "the teacher never came out of FROZEN_F; EndScript's UnfreezeAllObjects "
      .. "gives every object its movement function back")
  print("[driver] PASS gold freeze-all-other-objects in " .. out)
  love.event.quit()
end

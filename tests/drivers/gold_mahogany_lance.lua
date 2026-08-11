-- MahoganyMart1FLanceUncoversStaircaseScript (maps/MahoganyMart1F.asm:63), the
-- scene where Lance's DRAGONITE hyper-beams the Rocket behind the counter.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_mahogany_lance.lua love .
--
-- MAHOGANYMART1F_LANCE and MAHOGANYMART1F_DRAGONITE share ONE
-- MAPOBJECT_EVENT_FLAG (maps/MahoganyMart1F.asm:158-159), and the script
-- `disappear`s the DRAGONITE less than half way through and Lance only at the
-- very end -- so a port that derives who is standing from the event flag pulls
-- Lance off the map the moment his Dragonite goes, and the rest of his walk and
-- all three of his text boxes then come out of nobody.
--
-- The run prints the standing census every beat and shoots the two moments a
-- human has to look at: Lance mid-speech (he must be ON SCREEN) and the room
-- after he takes the stairs (he must be GONE, and an A press where he stood
-- must do nothing).
local U = require("tests.drivers.util")

local LANCE, DRAGONITE = 3, 4 -- def.objects indices; object consts are +1

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-mahogany"

  local function tap(button, frames)
    game.input.pressQueue[#game.input.pressQueue + 1] = button
    game.input.state[button] = true
    U.wait(2)
    game.input.state[button] = false
    U.wait(frames or 4)
  end

  local world
  local function standing(index)
    for _, npc in ipairs(world.npcs) do
      if npc.def and npc.def.index == index then return npc end
    end
    return nil
  end

  U.wait(45)
  world = game.world
  assert(world and world.map, "gold world did not boot")

  -- LakeOfRage.asm:61 `clearevent EVENT_MAHOGANY_MART_LANCE_AND_DRAGONITE` is
  -- what puts the pair in the shop; both objects carry that ONE flag
  -- (maps/MahoganyMart1F.asm:236-237).  Read it off the object rather than
  -- naming a number, so a re-extracted cache cannot make this stale.
  world:setMap("MAHOGANY_MART_1F", 3, 6, "up")
  U.wait(5)
  world.events:set(world.map.def.objects[LANCE].eventFlag, false)
  -- SCENE_MAHOGANYMART1F_LANCE_UNCOVERS_STAIRS is scene 1; the scene script is
  -- `sdefer`, and World:step only arms it on a map ENTRY, so the id has to be
  -- in place before the load that runs it.
  world.mapScenes["MAHOGANY_MART_1F"] = 1
  world:setMap("MAHOGANY_MART_1F", 3, 6, "up")
  U.wait(20)
  assert(world.map.id == "MAHOGANY_MART_1F", tostring(world.map.id))
  assert(standing(LANCE), "Lance is not on the map before the scene")
  assert(standing(DRAGONITE), "the Dragonite is not on the map before the scene")

  U.shot(game, out .. "/00-before.png")

  local lanceGoneAt, dragoniteGoneAt, shotMidway = nil, nil, false
  for step = 1, 900 do
    if not world:busy() and step > 30 then break end
    local lance, drag = standing(LANCE), standing(DRAGONITE)
    if not drag and not dragoniteGoneAt then dragoniteGoneAt = step end
    if not lance and not lanceGoneAt then lanceGoneAt = step end
    -- The Dragonite is gone and Lance is still talking: this is the frame the
    -- shared flag would have culled him on.
    if dragoniteGoneAt and not shotMidway and step == dragoniteGoneAt + 30 then
      shotMidway = true
      U.shot(game, out .. "/01-after-hyper-beam.png")
      print(("[driver] after the Dragonite went: Lance standing = %s")
        :format(tostring(standing(LANCE) ~= nil)))
    end
    tap("a", 2)
  end

  print(("[driver] Dragonite left the map at beat %s, Lance at beat %s")
    :format(tostring(dragoniteGoneAt), tostring(lanceGoneAt)))
  U.wait(20)
  U.shot(game, out .. "/02-after.png")

  assert(dragoniteGoneAt, "the Dragonite never disappeared")
  assert(lanceGoneAt, "Lance never disappeared")
  assert(lanceGoneAt > dragoniteGoneAt + 20,
    ("Lance left the map %d beats after his Dragonite; the script keeps him "
     .. "standing for the whole walk, the radio speech, the stairs and the "
     .. "split-up line"):format(lanceGoneAt - dragoniteGoneAt))

  -- The other half: a masked object must not answer an A press.  Stand where
  -- Lance ended up and face him.
  local def = world.map.def.objects[LANCE]
  world.player.cellX, world.player.cellY = def.x, def.y + 1
  world.player.px = world.player.cellX * 16
  world.player.py = world.player.cellY * 16
  world.player.facing = "up"
  U.wait(4)
  local answered = world:interact()
  print("[driver] A press on the masked Lance answered: " .. tostring(answered))
  assert(not answered, "a masked object answered a talk")

  print("[driver] PASS gold mahogany Lance scene in " .. out)
  love.event.quit()
end

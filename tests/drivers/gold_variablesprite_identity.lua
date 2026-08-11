-- `variablesprite` mid-script must repaint an object, not replace it.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_variablesprite_identity.lua love .
--
-- Two of the four map scripts that run `variablesprite` do it with the object
-- standing right there, mid-conversation, and with the VM holding a reference
-- to it as LAST_TALKED:
--
--   LassAliceScript (maps/FuchsiaGym.asm:61-66) is
--   `applymovement FUCHSIAGYM_FUCHSIA_GYM_1, Movement_NinjaSpin / faceplayer /
--   variablesprite SPRITE_FUCHSIA_GYM_1, SPRITE_LASS / special
--   LoadUsedSpritesGFX / faceplayer` -- the ninja spins, unmasks, and the very
--   next command turns the SAME object back to the player;
--   CopycatsHouse2F.asm:23-48 does the same for the Copycat.
--
-- On the cart nothing about the object struct moves: Script_variablesprite
-- writes ONE byte of wVariableSprites (scripting.asm:869) and LoadUsedSpritesGFX
-- reloads the tiles behind it.  The object keeps its coordinates, its facing,
-- its FROZEN_F and its place as wLastTalked.
--
-- So the port must keep the same NPC table.  Building a new one strands
-- World.talkNpc, .trainerNpc, .followState and any live moveState on an object
-- that is no longer on the map, and drops the object back to its map-def home
-- cell and default facing in the middle of the scene.
local U = require("tests.drivers.util")

return function(game)
  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  -- Route 36's Sudowoodo is the port's one live object on a SPRITE_VARS byte
  -- outside Kanto (maps/Route36.asm:486, SPRITE_WEIRD_TREE = slot 4).
  world:setMap("ROUTE_36", 34, 9, "right")
  U.wait(20)

  local tree, treeId
  for _, npc in ipairs(world.npcs) do
    if npc.def and npc.def.sprite == 0xf0 + 4 then
      tree, treeId = npc, (npc.def.index or 0) + 1
      break
    end
  end
  assert(tree, "no SPRITE_WEIRD_TREE object on ROUTE_36")

  -- The state a mid-script `variablesprite` has to survive: the object is the
  -- one being talked to, it has been turned, and it has been frozen.
  world.talkNpc = tree
  world.trainerNpc = tree
  tree.facing = "left"
  tree.frozen = true
  local beforeX, beforeY = tree.cellX, tree.cellY

  -- `variablesprite SPRITE_WEIRD_TREE, SPRITE_TWIN`, the same slot write
  -- WateredWeirdTreeScript makes (maps/Route36.asm:58).
  world:setVariableSprite(4, 38)
  U.wait(2)

  local after = world:objectEntity(treeId)
  print(("[driver] object identity kept: %s"):format(tostring(after == tree)))
  print(("[driver] talkNpc still on the map: %s")
    :format(tostring(after == world.talkNpc)))
  print(("[driver] facing %s -> %s, frozen %s -> %s, cell (%s,%s) -> (%s,%s)")
    :format(tostring(tree.facing), tostring(after and after.facing),
      tostring(tree.frozen), tostring(after and after.frozen),
      tostring(beforeX), tostring(beforeY),
      tostring(after and after.cellX), tostring(after and after.cellY)))
  print(("[driver] sheet now %s (SPRITE_TWIN wanted)")
    :format(tostring(after and after.spriteDef and after.spriteDef.id)))

  assert(after, "the object vanished from the map entirely")
  assert(after.spriteDef and after.spriteDef.id == "SPRITE_TWIN",
    "the slot write did not repaint the object: it is "
      .. tostring(after.spriteDef and after.spriteDef.id))
  assert(after == tree,
    "variablesprite REPLACED the object -- World.talkNpc / .trainerNpc and any "
      .. "live movement now point at an NPC that is no longer on the map")
  assert(after.facing == "left",
    "the object lost the facing a `faceplayer` had just given it: "
      .. tostring(after.facing))
  assert(after.frozen == true, "the object came back unfrozen mid-script")
  assert(after.cellX == beforeX and after.cellY == beforeY,
    "the object moved on a slot write")

  print("[driver] PASS gold variablesprite keeps the object")
  love.event.quit()
end

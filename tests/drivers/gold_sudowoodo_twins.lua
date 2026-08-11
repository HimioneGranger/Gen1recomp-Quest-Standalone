-- Route 36's Sudowoodo and Route 37's TWINS ANN & ANNE share ONE
-- wVariableSprites slot, and the fight is what repaints it.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_sudowoodo_twins.lua love .
--
-- maps/Route36.asm:486 gives the tree `SPRITE_WEIRD_TREE`, and maps/Route37.asm
-- :237-238 give BOTH twins the same byte -- it is a SLOT ($f4), not a sheet.
-- InitializeEventsScript seeds the slot with SPRITE_SUDOWOODO, and
-- WateredWeirdTreeScript's `variablesprite SPRITE_WEIRD_TREE, SPRITE_TWIN`
-- (maps/Route36.asm:58, and again at :70 on the DidntCatchSudowoodo arm) is the
-- only thing that ever repaints it.  Miss that command and the two girls on
-- Route 37 are drawn as a pair of Sudowoodo.
--
-- Shots land in /tmp/gold-twins: the twins before the fight (Sudowoodo, which
-- is what the cart draws too -- the tree blocks the only road north), the tree
-- itself, and the twins after.
local U = require("tests.drivers.util")
local Mon = require("src.battle.gen2.Mon")

local function twinSprites(world)
  local out = {}
  for _, npc in ipairs(world.npcs) do
    if npc.def and (npc.def.index == 1 or npc.def.index == 2) then
      out[#out + 1] = (npc.spriteDef and npc.spriteDef.id) or "?"
    end
  end
  return out
end

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-twins"

  local function tap(button, frames)
    game.input.pressQueue[#game.input.pressQueue + 1] = button
    game.input.state[button] = true
    U.wait(2)
    game.input.state[button] = false
    U.wait(frames or 6)
  end

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  print(("[driver] slot 4 seeds to %s (SPRITE_SUDOWOODO is 82)")
    :format(tostring(world.variableSprites[4])))

  -- Before: Route 37, the two twins standing at (6,12) and (7,12).
  world:setMap("ROUTE_37", 6, 14, "up")
  U.wait(20)
  print("[driver] twins before: " .. table.concat(twinSprites(world), ", "))
  U.shot(game, out .. "/00-twins-before.png")

  -- The fight.  A SQUIRTBOTTLE in the bag is what turns the A press into
  -- WateredWeirdTreeScript rather than the shake-and-nothing arm.
  local Bag = require("src.inventory.Bag")
  local starter = Mon.new(game.data, "TYPHLOSION", 60)
  assert(starter, "could not build a TYPHLOSION")
  game.save.party = { starter }
  Bag.add(game.save, "SQUIRTBOTTLE", 1, game.data)

  world:setMap("ROUTE_36", 34, 9, "right")
  U.wait(20)
  U.shot(game, out .. "/01-tree.png")
  world:interact()
  U.wait(4)

  -- yesorno: "Use the SQUIRTBOTTLE?" -> YES is the default cursor row.
  local battle
  for _ = 1, 400 do
    local top = game.stack:top()
    if top and top.battle then battle = top break end
    tap("a", 2)
  end
  assert(battle, "the Sudowoodo battle never started")
  U.shot(game, out .. "/02-battle.png")

  local attackSlot = 1
  for i, move in ipairs(starter.moves) do
    local def = game.data.moves and game.data.moves[move.id]
    if def and (def.power or 0) > 0 then attackSlot = i break end
  end
  for _ = 1, 900 do
    if battle.battle.over then break end
    if battle.phase == "menu" then
      tap("a")
      U.wait(4)
      for _ = 2, attackSlot do tap("down", 2) end
      tap("a")
    else
      tap("a", 3)
    end
  end
  assert(battle.battle.over, "the Sudowoodo battle did not resolve")
  print("[driver] outcome " .. tostring(battle.battle.outcome))

  for _ = 1, 300 do
    if not world:busy() then break end
    tap("a", 2)
  end
  print(("[driver] slot 4 after the fight: %s (SPRITE_TWIN is 38)")
    :format(tostring(world.variableSprites[4])))
  U.shot(game, out .. "/03-after-fight.png")

  -- The half a plain setMap cannot see.  Route 37 is a CONNECTION of Route 36,
  -- so its objects are already pooled as ghosts on the neighbor strip -- with
  -- the sheet the slot held when they were pooled, i.e. SPRITE_SUDOWOODO --
  -- and walking north is a SEAMLESS setMap that KEEPS World.npcPool.  Only
  -- World:repaintVariableSpritePool hands them the new sheet.
  for _, key in ipairs({ "ROUTE_37_obj_1", "ROUTE_37_obj_2" }) do
    local ghost = world.npcPool[key]
    print(("[driver] pooled %s: %s"):format(key,
      ghost and tostring(ghost.spriteDef and ghost.spriteDef.id) or "not pooled"))
    assert(not ghost or (ghost.spriteDef and ghost.spriteDef.id) == "SPRITE_TWIN",
      key .. " is still pooled as " .. tostring(ghost.spriteDef and ghost.spriteDef.id))
  end
  world:setMap("ROUTE_37", 6, 14, "up", { seamless = true })
  U.wait(20)
  local after = twinSprites(world)
  print("[driver] twins after: " .. table.concat(after, ", "))
  U.shot(game, out .. "/04-twins-after.png")
  assert(world.variableSprites[4] == 38,
    "wVariableSprites[SPRITE_WEIRD_TREE] is "
      .. tostring(world.variableSprites[4]) .. ", wanted 38 (SPRITE_TWIN)")
  for _, id in ipairs(after) do
    assert(id == "SPRITE_TWIN", "a twin is drawn as " .. tostring(id))
  end
  print("[driver] PASS gold sudowoodo -> twins in " .. out)
  love.event.quit()
end

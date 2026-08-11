-- "The guy who tells you about UNOWN never comes out."  The whole chain, live.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_unown_scientist.lua love .
--
-- RuinsOfAlphOutsideScientistCallback (maps/RuinsOfAlphOutside.asm:22) is a
-- MAPCALLBACK_OBJECTS with THREE gates, and the scientist only appears when all
-- three answer:
--
--   checkflag ENGINE_UNOWN_DEX          -- must still be CLEAR
--   checkevent EVENT_MADE_UNOWN_APPEAR_IN_RUINS
--   readvar VAR_UNOWNCOUNT / ifgreater 2
--
-- The middle one is set by RuinsOfAlphInnerChamberStrangePresenceScript
-- (maps/RuinsOfAlphInnerChamber.asm:20), which is the `sdefer` on
-- SCENE_RUINSOFALPHINNERCHAMBER_STRANGE_PRESENCE -- the scene a solved chamber
-- puzzle writes with `setmapscene` (maps/RuinsOfAlphKabutoChamber.asm:36).  The
-- last is CountUnown over wUnownDex, which only a caught FORM grows.
--
-- The run walks all three and prints which gate is standing, so a failure names
-- its own cause instead of "he is not there".  Shots in /tmp/gold-unown.
local U = require("tests.drivers.util")
local Unown = require("src.core.gen2.Unown")

local SCIENTIST = 2 -- def.objects index on RUINS_OF_ALPH_OUTSIDE

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-unown"

  local function tap(button, frames)
    game.input.pressQueue[#game.input.pressQueue + 1] = button
    game.input.state[button] = true
    U.wait(2)
    game.input.state[button] = false
    U.wait(frames or 4)
  end

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  local function standing(index)
    for _, npc in ipairs(world.npcs) do
      if npc.def and npc.def.index == index then return npc end
    end
    return nil
  end

  -- Gate 1: he is NOT there before any of it.
  world:setMap("RUINS_OF_ALPH_OUTSIDE", 11, 16, "up")
  U.wait(20)
  print("[driver] scientist before the chain: " .. tostring(standing(SCIENTIST) ~= nil))
  U.shot(game, out .. "/00-before.png")
  local flag = world.map.def.objects[SCIENTIST].eventFlag
  assert(not standing(SCIENTIST), "the scientist is out before the puzzle")

  -- The puzzle's own `setmapscene RUINS_OF_ALPH_INNER_CHAMBER,
  -- SCENE_RUINSOFALPHINNERCHAMBER_STRANGE_PRESENCE`.  Solving the sliding
  -- panels is a UI, not a script, so stand in for that one command only.
  world.mapScenes["RUINS_OF_ALPH_INNER_CHAMBER"] = 1

  -- Gate 2: walking into the inner chamber must run the strange-presence
  -- script and set EVENT_MADE_UNOWN_APPEAR_IN_RUINS.
  world:setMap("RUINS_OF_ALPH_INNER_CHAMBER", 10, 20, "up")
  -- The scene's `sdefer` only fires on the first settled World:step after the
  -- load, so give it a few frames before the "is it still running" loop -- a
  -- busy() test on frame one reads "already finished".
  U.wait(30)
  for _ = 1, 300 do
    if not world:busy() then break end
    tap("a", 2)
  end
  U.wait(20)
  U.shot(game, out .. "/01-inner-chamber.png")
  local madeAppear = world.events:get(46)
  print("[driver] EVENT_MADE_UNOWN_APPEAR_IN_RUINS: " .. tostring(madeAppear))
  print("[driver] inner chamber scene is now " .. tostring(world.mapScenes["RUINS_OF_ALPH_INNER_CHAMBER"]))
  assert(madeAppear,
    "the strange-presence scene never set EVENT_MADE_UNOWN_APPEAR_IN_RUINS")

  -- Gate 3: three distinct Unown forms, the way AddPartyMon's
  -- `.registerunowndex` grows wUnownDex.
  for _, letter in ipairs({ "A", "B", "C" }) do
    Unown.updateDex(game.save, letter)
  end
  print("[driver] VAR_UNOWNCOUNT is now " .. tostring(Unown.count(game.save)))
  assert(Unown.count(game.save) == 3, "wUnownDex did not take three forms")

  world:setMap("RUINS_OF_ALPH_OUTSIDE", 11, 16, "up")
  U.wait(20)
  local npc = standing(SCIENTIST)
  print(("[driver] scientist after the chain: %s (his flag %s is %s)")
    :format(tostring(npc ~= nil), tostring(flag),
      tostring(world.events:get(flag))))
  U.shot(game, out .. "/02-scientist.png")
  assert(npc, "RuinsOfAlphOutsideScientistCallback never appeared the scientist")

  -- And he must have something to say: the scene id the callback set is what
  -- his walk-you-to-the-lab script hangs off.
  print("[driver] outside scene is now "
    .. tostring(world.mapScenes["RUINS_OF_ALPH_OUTSIDE"]))
  print("[driver] PASS gold Unown scientist in " .. out)
  love.event.quit()
end

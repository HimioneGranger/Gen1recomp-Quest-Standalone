-- Assertion driver: object hour windows, the temporary event-flag byte, and
-- the Route 30 roadblock's facing, all through real map loads in the running
-- game.  PASSES or errors; nothing to eyeball.
--
--   POKEPORT_GAME=gold POKEPORT_IDENTITY=gold-dev \
--     POKEPORT_DRIVER=tests/drivers/gold_overworld_npc.lua love .
--
-- tests/gen2_object_hours_test.lua and tests/gen2_temp_events_test.lua prove
-- the same rules over fixtures and a bare cache; what only this can prove is
-- that a genuine boot, cache and setMap chain agree with them: CheckObjectTime
-- filters the spawn (home/map_objects.asm), ResetMapBufferEventFlags clears
-- flags 0-7 on the load (home/map.asm), and the spoken-to roadblock MONSTER
-- turns to the player (ObjectEvent's jumptextfaceplayer, home/map.asm).
local U = require("tests.drivers.util")

return function(game)
  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  local function momCount()
    local n = 0
    for _, npc in ipairs(world.npcs) do
      if npc.def and npc.def.sprite == "SPRITE_MOM" then n = n + 1 end
    end
    return n
  end

  -- ---- hour windows: one Mom, whatever the hour --------------------------
  -- Post-intro state: EVENT_PLAYERS_HOUSE_MOM_1 (1735) hides the intro Mom,
  -- EVENT_PLAYERS_HOUSE_MOM_2 (1736) clear shows the time-of-day set.  Both
  -- scene maps go to their NOOP scene first, or the MeetMom / Elm's-aide
  -- walk-ups fire on the load and park a text box over the whole run.
  world.mapScenes = world.mapScenes or {}
  world.mapScenes.PLAYERS_HOUSE_1F = 1
  world.mapScenes.NEW_BARK_TOWN = 1
  world.events:set(1735, true)
  world.events:set(1736, false)
  for _, hour in ipairs({ 6, 12, 20 }) do
    world.clockHour = hour
    assert(world:setMap("PLAYERS_HOUSE_1F", 3, 3, "down"),
      "PLAYERS_HOUSE_1F did not load")
    U.wait(2)
    local n = momCount()
    assert(n == 1, ("%02d:00 spawned %d Moms, want exactly 1"):format(hour, n))
  end
  U.log("hour windows: one Mom in the kitchen at 06:00, 12:00 and 20:00")

  local function pharmacists()
    local n = 0
    for _, npc in ipairs(world.npcs) do
      if npc.def and npc.def.sprite == "SPRITE_PHARMACIST" then n = n + 1 end
    end
    return n
  end
  for _, row in ipairs({ { 6, 0 }, { 12, 1 }, { 20, 1 } }) do
    world.clockHour = row[1]
    assert(world:setMap("GOLDENROD_GAME_CORNER", 8, 10, "up"),
      "GOLDENROD_GAME_CORNER did not load")
    U.wait(2)
    local n = pharmacists()
    assert(n == row[2],
      ("game corner at %02d:00: %d pharmacists, want %d")
        :format(row[1], n, row[2]))
  end
  U.log("hour windows: the pharmacist pair collapses to one, absent at dawn")

  -- ---- the temporary byte dies on the load --------------------------------
  for id = 0, 8 do world.events:set(id, true) end
  assert(world:setMap("NEW_BARK_TOWN", 8, 8, "down"),
    "NEW_BARK_TOWN did not load")
  U.wait(2)
  for id = 0, 7 do
    assert(not world.events:get(id),
      ("temporary flag %d survived the map load"):format(id))
  end
  assert(world.events:get(8), "flag 8 must survive: only one byte clears")
  world.events:set(8, false)
  U.log("temp events: flags 0-7 cleared by the load, flag 8 kept")

  -- ---- the roadblock Rattata turns to the player --------------------------
  -- EVENT_ROUTE_30_BATTLE (1812) clear puts the battling pair on the map.
  world.events:set(1812, false)
  world.clockHour = 12
  assert(world:setMap("ROUTE_30", 4, 25, "right"), "ROUTE_30 did not load")
  U.wait(2)
  local rattata
  for _, npc in ipairs(world.npcs) do
    if npc.def and npc.def.sprite == "SPRITE_MONSTER"
        and npc.cellX == 5 and npc.cellY == 25 then
      rattata = npc
    end
  end
  assert(rattata, "the (5,25) roadblock MONSTER did not spawn")
  assert(rattata.facing == "up",
    "before the talk it faces its partner (STANDING_UP), got " .. rattata.facing)
  U.tap(game, "a")
  U.wait(4)
  assert(rattata.facing == "left",
    "spoken to from the west it must turn left, got " .. rattata.facing)
  assert(world:busy(), "and its ObjectEvent text box is up")
  assert(rattata.frozen, "and it holds still under the box")
  -- Type the line out and close the box (held A is the fast path).
  for _ = 1, 120 do
    if not world:busy() then break end
    U.tap(game, "a")
  end
  assert(not world:busy(), "the box closed")
  U.wait(4)
  assert(not rattata.frozen, "and the freeze lifted with the script")

  U.log("PASS gold_overworld_npc: hour windows, temp flags, roadblock facing")
  love.event.quit(0)
end

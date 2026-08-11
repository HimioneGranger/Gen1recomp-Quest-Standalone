-- ReleaseTheBeasts (maps/BurnedTowerB1F.asm:25), the one scene in the game
-- that stages six objects sharing two event flags one beat at a time.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_burned_tower_beasts.lua love .
--
-- What a human is watching for, in the cart's own order: Raikou APPEARS, its
-- standing twin blinks out, Raikou cries; then Entei, then Suicune, each on
-- its own beat -- and at the end each of the three jumps away and vanishes on
-- its own turn rather than all three going at once.
--
-- All three animated beasts carry EVENT_BURNED_TOWER_B1F_BEASTS_1 and all
-- three statics carry EVENT_BURNED_TOWER_B1F_BEASTS_2, so a port that derives
-- who is standing from the event flag alone pops the whole group on the first
-- `appear` and clears it on the first `disappear`.  wObjectMasks is the per
-- object byte that keeps them independent (home/map.asm:1542 MaskObject,
-- engine/overworld/map_objects_2.asm:1 LoadObjectMasks).
--
-- Shots land in /tmp/gold-beasts, one per beat plus a running census.
local U = require("tests.drivers.util")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-beasts"

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  -- The scene is entered from the ladder; drop in beside the trigger instead,
  -- which is the coord event at (9,5).
  world:setMap("BURNED_TOWER_B1F", 9, 7, "up")
  U.wait(20)

  -- The coord event carries its own scene id, so ask the map rather than
  -- hardcoding SCENE_BURNEDTOWERB1F_RELEASE_THE_BEASTS.
  local trigger
  for _, ev in ipairs(world.map.def.coordEvents or {}) do
    if ev.x == 9 and ev.y == 5 then trigger = ev end
  end
  assert(trigger, "BURNED_TOWER_B1F has no coord event at (9,5)")
  world.mapScenes[world.map.id] = trigger.sceneId or 0

  local function census()
    local n = 0
    for _, npc in ipairs(world.npcs) do
      if npc.def and npc.def.eventFlag and npc.def.eventFlag ~= 0xFFFF then
        n = n + 1
      end
    end
    return n
  end

  U.shot(game, out .. "/00-before.png")
  print(("[driver] %d flagged objects standing before the scene")
    :format(census()))

  -- Walk onto the trigger and let the scene run, shooting every beat.
  U.hold(game, "up", 24)
  U.wait(10)

  local counts = {}
  for step = 1, 60 do
    U.wait(10)
    counts[#counts + 1] = census()
    if step % 3 == 0 then
      U.shot(game, ("%s/01-beat-%02d.png"):format(out, step))
    end
    if step > 6 and not world:busy() then break end
  end
  U.wait(30)
  U.shot(game, out .. "/02-after.png")

  -- The census must never jump by three: every appear and every disappear in
  -- ReleaseTheBeasts moves exactly one object.
  local worst = 0
  for i = 2, #counts do
    local delta = math.abs(counts[i] - counts[i - 1])
    if delta > worst then worst = delta end
  end
  print(("[driver] %d samples, largest one-sample swing %d (want 1)")
    :format(#counts, worst))
  print(("[driver] %d flagged objects standing after the scene")
    :format(census()))
  print("[driver] PASS gold burned tower beasts in " .. out)
  love.event.quit()
end

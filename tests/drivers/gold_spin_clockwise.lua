-- SPRITEMOVEDATA_SPINCLOCKWISE / _SPINCOUNTERCLOCKWISE, the two spins that are
-- not random.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_spin_clockwise.lua love .
--
-- MovementFunction_SpinClockwise / _SpinCounterclockwise
-- (engine/overworld/map_objects.asm:790-843) hold OBJECT_STEP_DURATION $10 --
-- sixteen frames -- on each quarter and then take the next facing out of a
-- FIXED table: clockwise is down -> left -> up -> right, counterclockwise is
-- down -> right -> up -> left.  No Random is called anywhere in the loop, which
-- is the point: the Rocket base's guards are a puzzle, and a puzzle has to be
-- predictable.
--
-- The port used to answer both rows with "stand", so Route 32's Youngster
-- Gordon, Route 35's Firebreather Walt, RadioTower4F's GruntM10 and the Route
-- 40/41 swimmers never turned at all.
local U = require("tests.drivers.util")

local CLOCKWISE = { down = "left", up = "right", left = "up", right = "down" }
local COUNTER = { down = "right", up = "left", left = "down", right = "up" }

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-spin"

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  -- Route 32 has Youngster Gordon on SPRITEMOVEDATA_SPINCLOCKWISE ($1f); the
  -- driver takes whatever spinners the map actually carries rather than naming
  -- an object index, so a cache rebuild cannot silently retarget it.
  world:setMap("ROUTE_32", 9, 12, "down")
  U.wait(30)

  local found = {}
  for _, npc in ipairs(world.npcs) do
    local m = npc.def and npc.def.movement
    if m == 0x1f or m == 0x1e then
      found[#found + 1] = { npc = npc, cw = (m == 0x1f) }
    end
  end
  print(("[driver] %d fixed-spin objects on ROUTE_32"):format(#found))
  assert(#found > 0, "ROUTE_32 has no SPINCLOCKWISE / SPINCOUNTERCLOCKWISE object")

  U.shot(game, out .. "/00-before.png")

  -- Sixteen frames a quarter, so 200 frames is a dozen turns even allowing for
  -- the initial timer NPC.new seeds.
  local seen = {}
  for _, e in ipairs(found) do seen[e.npc] = { [e.npc.facing] = true } end
  local order = {}
  for _, e in ipairs(found) do order[e.npc] = {} end
  for _ = 1, 200 do
    for _, e in ipairs(found) do
      local f = e.npc.facing
      local trail = order[e.npc]
      if trail[#trail] ~= f then trail[#trail + 1] = f end
      seen[e.npc][f] = true
    end
    U.wait(1)
  end
  U.shot(game, out .. "/01-after.png")

  for i, e in ipairs(found) do
    local n = 0
    for _ in pairs(seen[e.npc]) do n = n + 1 end
    local trail = order[e.npc]
    print(("[driver] object %d (%s): %d distinct facings over %d turns: %s")
      :format(i, e.cw and "clockwise" or "counterclockwise", n, #trail - 1,
        table.concat(trail, ">")))
    assert(n == 4,
      "a fixed spinner only reached " .. n .. " facings -- it is not turning")
    -- Every consecutive pair has to be the table's own successor: a RANDOM
    -- spin would pass the count above and fail here.
    local want = e.cw and CLOCKWISE or COUNTER
    for j = 2, #trail do
      assert(trail[j] == want[trail[j - 1]],
        ("turn %d went %s -> %s, wanted %s"):format(j - 1, trail[j - 1],
          trail[j], tostring(want[trail[j - 1]])))
    end
  end

  print("[driver] PASS gold fixed-order spinners in " .. out)
  love.event.quit()
end

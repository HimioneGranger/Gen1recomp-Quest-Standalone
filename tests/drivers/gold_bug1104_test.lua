-- #1104: the Ruins of Alph ladders warp somewhere else.
--   POKEPORT_GAME=gold POKEPORT_TOUCH=0 \
--     POKEPORT_DRIVER=tests/drivers/gold_bug1104_test.lua love .
local Mon = require("src.battle.gen2.Mon")

-- maps/RuinsOfAlphInnerChamber.asm:76, maps/RuinsOfAlphOutside.asm:126,
-- maps/RuinsOfAlphKabutoChamber.asm and its three siblings.
local CASES = {
  { "RUINS_OF_ALPH_INNER_CHAMBER", 10, 13, "RUINS_OF_ALPH_OUTSIDE", 10, 13 },
  { "RUINS_OF_ALPH_OUTSIDE", 10, 13, "RUINS_OF_ALPH_INNER_CHAMBER", 10, 13 },
  { "RUINS_OF_ALPH_OUTSIDE", 2, 17, "RUINS_OF_ALPH_HO_OH_CHAMBER", 3, 9 },
  { "RUINS_OF_ALPH_OUTSIDE", 14, 7, "RUINS_OF_ALPH_KABUTO_CHAMBER", 3, 9 },
  { "RUINS_OF_ALPH_OUTSIDE", 2, 29, "RUINS_OF_ALPH_OMANYTE_CHAMBER", 3, 9 },
  { "RUINS_OF_ALPH_OUTSIDE", 16, 33, "RUINS_OF_ALPH_AERODACTYL_CHAMBER", 3, 9 },
  { "RUINS_OF_ALPH_OUTSIDE", 17, 11, "RUINS_OF_ALPH_RESEARCH_CENTER", 2, 7 },
  { "RUINS_OF_ALPH_KABUTO_CHAMBER", 3, 9, "RUINS_OF_ALPH_OUTSIDE", 14, 7, "down" },
  { "RUINS_OF_ALPH_HO_OH_CHAMBER", 3, 9, "RUINS_OF_ALPH_OUTSIDE", 2, 17, "down" },
  { "RUINS_OF_ALPH_OMANYTE_CHAMBER", 3, 9, "RUINS_OF_ALPH_OUTSIDE", 2, 29, "down" },
  { "RUINS_OF_ALPH_AERODACTYL_CHAMBER", 3, 9, "RUINS_OF_ALPH_OUTSIDE", 16, 33, "down" },
  { "RUINS_OF_ALPH_RESEARCH_CENTER", 2, 7, "RUINS_OF_ALPH_OUTSIDE", 17, 11, "down" },
}

return function(game)
  local function wait(n) for _ = 1, n do coroutine.yield() end end
  local function clearDirs()
    for _, d in ipairs({ "up", "down", "left", "right" }) do
      game.input.state[d] = false
    end
  end
  -- Hold until the map changes, then let the load settle and STOP: holding
  -- past the arrival would walk the player off the landing tile.
  local function walkUntilWarp(dir, frames, fromMap)
    for _ = 1, frames do
      clearDirs()
      game.input.state[dir] = true
      table.insert(game.input.pressQueue, dir)
      coroutine.yield()
      if game.world.map and game.world.map.id ~= fromMap then
        clearDirs()
        -- The ARRIVAL cell is the one the warp table names.  Standing on a
        -- door/cave/staircase tile then forces one step DOWN off it
        -- (engine/overworld/player_movement.asm:201-213), so the settled cell
        -- is legitimately one row lower on an outdoor mouth.
        local ax, ay = game.world.player.cellX, game.world.player.cellY
        for _ = 1, 45 do coroutine.yield() end
        return game.world.map.id, ax, ay,
          game.world.player.cellX, game.world.player.cellY
      end
    end
    clearDirs()
    return game.world.map and game.world.map.id, nil, nil
  end

  wait(30)
  local world = game.world
  game.save.party = { Mon.new(game.data, "PIDGEY", 5) }

  local bad = 0
  for _, c in ipairs(CASES) do
    local src, wx, wy, wantMap, wantX, wantY = c[1], c[2], c[3], c[4], c[5], c[6]
    -- default approach is from below, the way the report describes facing the
    -- ladder from below; a chamber's exit sits on the bottom row instead
    local dir = c[7] or "up"
    local sy = (dir == "up") and wy + 1 or wy - 1
    world:setMap(src, wx, sy, dir)
    wait(12)
    local from = ("%s (%d,%d)"):format(src, world.player.cellX, world.player.cellY)
    local m, ax, ay, sx, sy = walkUntilWarp(dir, 90, src)
    local ok = (m == wantMap and ax == wantX and ay == wantY)
    if not ok then bad = bad + 1 end
    print(("[driver] %-12s %s -> %s (%s,%s) settled (%s,%s)   want %s (%d,%d)")
      :format(ok and "OK" or "MISMATCH", from, tostring(m),
              tostring(ax), tostring(ay), tostring(sx), tostring(sy),
              wantMap, wantX, wantY))
  end
  print(("[driver] %s ruins warps: %d mismatches")
    :format(bad == 0 and "PASS" or "FAIL", bad))
end

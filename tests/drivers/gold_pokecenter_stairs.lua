-- Assertion driver: the shared POKECENTER_2F staircase, walked for real.
--
--   POKEPORT_GAME=gold POKEPORT_IDENTITY=gold-dev \
--     POKEPORT_DRIVER=tests/drivers/gold_pokecenter_stairs.lua love .
--
-- tests/gen2_pokecenter_stairs_test.lua drives takeWarp against the real map
-- defs; what it cannot do is put a player's feet on the tile.  This walks up
-- the stairs of two different Pokemon Centers and back down, through the real
-- step loop, the real fades and the real warp machinery, and asserts the one
-- thing the cart guarantees: the single second floor leads back down into
-- whichever centre it was climbed from (home/map.asm CopyWarpData's -1 arm).
-- It PASSES or it errors; there is nothing to eyeball.
local U = require("tests.drivers.util")

return function(game)
  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  -- Wait out fades, script beats and the step in flight.
  local function settle(limit)
    for _ = 1, limit or 600 do
      if not world:busy() and not (world.player and world.player.moving) then
        return
      end
      U.wait(1)
    end
    error("world never settled")
  end

  local function at()
    return world.map.id, world.player.cellX, world.player.cellY
  end

  local function climbAndReturn(centerId)
    -- Stand two cells east of the staircase and walk onto it.
    assert(world:setMap(centerId, 2, 7, "left"), "setMap " .. centerId)
    U.wait(5)
    settle()
    U.hold(game, "left", 80)
    settle()
    local mapId, x, y = at()
    assert(mapId == "POKECENTER_2F",
      ("%s stairs went to %s at (%d,%d), not the shared 2F")
        :format(centerId, mapId, x, y))
    U.log(centerId .. ": up the stairs onto the shared 2F")

    -- Step off the staircase, then back onto it: the -1 warp must resolve to
    -- the centre just left.
    U.hold(game, "right", 30)
    settle()
    assert(world.player.cellX >= 1,
      "did not step off the 2F staircase (x=" .. world.player.cellX .. ")")
    U.hold(game, "left", 80)
    settle()
    mapId, x, y = at()
    assert(mapId == centerId,
      ("the 2F stairs came down in %s, expected %s"):format(mapId, centerId))
    assert(x == 0 and y == 7,
      ("landed at (%d,%d), expected the 1F staircase (0,7)"):format(x, y))
    U.log(centerId .. ": back down into the same centre")
  end

  climbAndReturn("CHERRYGROVE_POKECENTER_1F")
  climbAndReturn("VIOLET_POKECENTER_1F")

  U.log("PASS gold_pokecenter_stairs")
  love.event.quit()
end

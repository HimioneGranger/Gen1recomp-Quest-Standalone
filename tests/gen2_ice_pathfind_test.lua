-- Ice-aware Bot:slideRest / planPath.  Self-contained:
--   luajit tests/gen2_ice_pathfind_test.lua
--
-- The engine half (CheckForced latch) lives in gen2_world_test.lua.  This file
-- proves the planner's graph is over REST positions: a press on ice ends where
-- the slide stops, so a cell the player would skate past is not a node.
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 ice pathfind")
local check, eq = S.check, S.eq

local Permissions = require("src.world.gen2.Permissions")
local Bot = dofile("tests/drivers/gold/bot.lua")
local A = Bot.adapter

local COLL_FLOOR, COLL_ICE, COLL_WALL = 0x00, 0x23, 0x07

local function fakeMap(cells)
  return {
    id = "ICE_TEST",
    inBounds = function(_, x, y)
      return x >= 0 and y >= 0 and x < 20 and y < 20
    end,
    cellCollision = function(_, x, y)
      return cells[y * 100 + x] or COLL_FLOOR
    end,
  }
end

-- A bot stub that only needs passable / slideRest / planPath / wallCost.
local function stubBot(map, sx, sy, cells)
  local g = { _map = map, _x = sx, _y = sy }
  local bot = setmetatable({
    g = g,
    walls = {},
    surfKnown = false,
  }, Bot)
  -- Adapter seams the planner reads.  Keep them on A so the real methods run.
  local realMap, realPos, realWalkable, realIsIce, realIsWater, realNpcAt,
        realIsWarp, realSurfing =
    A.map, A.pos, A.walkable, A.isIce, A.isWater, A.npcAt, A.isWarpTile, A.surfing
  A.map = function() return map end
  A.pos = function() return g._x, g._y end
  A.mapId = function() return map.id end
  A.walkable = function(_, m, x, y)
    if not m:inBounds(x, y) then return false end
    return Permissions.isWalkable(m:cellCollision(x, y))
  end
  A.isIce = function(m, x, y)
    return Permissions.isIce(m:cellCollision(x, y))
  end
  A.isWater = function() return false end
  A.npcAt = function() return nil end
  A.isWarpTile = function() return false end
  A.surfing = function() return false end
  bot._restore = function()
    A.map, A.pos, A.walkable, A.isIce, A.isWater, A.npcAt, A.isWarpTile, A.surfing =
      realMap, realPos, realWalkable, realIsIce, realIsWater, realNpcAt,
      realIsWarp, realSurfing
  end
  return bot
end

-- Corridor of ice ending at a wall: press right from floor rests on the last ice.
do
  local cells = {
    [5 * 100 + 3] = COLL_ICE,
    [5 * 100 + 4] = COLL_ICE,
    [5 * 100 + 5] = COLL_ICE,
    [5 * 100 + 6] = COLL_WALL,
  }
  local map = fakeMap(cells)
  local bot = stubBot(map, 2, 5)
  local rx, ry, steps = bot:slideRest(map, 2, 5, "right")
  eq(rx, 5, "slideRest stops on the last ice cell")
  eq(ry, 5, "same row")
  eq(steps, 3, "three cells of travel")
  check(bot:slideRest(map, 5, 5, "right") == nil,
    "pressing into the wall from the rest cell is no edge")
  bot._restore()
end

-- Mid-corridor ice is not a rest node: planPath to it must fail.
do
  local cells = {
    [5 * 100 + 3] = COLL_ICE,
    [5 * 100 + 4] = COLL_ICE,
    [5 * 100 + 5] = COLL_ICE,
    [5 * 100 + 6] = COLL_WALL,
  }
  local map = fakeMap(cells)
  local bot = stubBot(map, 2, 5)
  check(bot:planPath(4, 5) == nil,
    "a cell the slide skates past is unreachable as a rest")
  local path = bot:planPath(5, 5)
  check(path ~= nil, "the rest against the wall is reachable")
  eq(#path, 1, "one press")
  eq(path[1], "right", "to the east")
  bot._restore()
end

-- Off ice, planPath is still ordinary adjacency.
do
  local map = fakeMap({})
  local bot = stubBot(map, 2, 5)
  local path = bot:planPath(4, 5)
  check(path ~= nil, "dry floor still paths")
  eq(#path, 2, "two single-cell presses")
  eq(path[1], "right", "first step")
  eq(path[2], "right", "second step")
  bot._restore()
end

S.finish()

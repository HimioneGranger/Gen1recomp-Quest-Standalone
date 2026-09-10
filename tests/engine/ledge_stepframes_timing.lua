-- Upstream f1388279: a ledge arc follows the player's active step length.
-- ROM-free: a synthetic ledge drives the real overworld, movement, and pose
-- paths with an 8-frame active step and a 16-frame configured fallback.
--
--   luajit tests/engine/ledge_stepframes_timing.lua

package.path = "./?.lua;./?/init.lua;" .. package.path
if not _G.love then _G.love = require("tests.love_stub") end

local T = require("tests.modkit")
local Game = require("src.core.Game")
local Player = require("src.world.Player")
local OW = require("src.world.OverworldController")

local function setUpvalue(fn, name, value)
  local i = 1
  while true do
    local found = debug.getupvalue(fn, i)
    if not found then return false end
    if found == name then
      debug.setupvalue(fn, i, value)
      return true
    end
    i = i + 1
  end
end

local realSound = package.loaded["src.core.Sound"]
package.loaded["src.core.Sound"] = { play = function() end }

Game.data = {
  field = {
    ledges = {
      {
        tileset = "FIX_OUT",
        facing = "down",
        input = "down",
        standingTile = 1,
        ledgeTile = 2,
      },
    },
  },
}
T.check(setUpvalue(OW.checkLedgeHop, "Game", Game),
  "the focused ledge method uses the fixture Game")

local player = setmetatable({
  cellX = 2,
  cellY = 2,
  px = 32,
  py = 32,
  facing = "down",
  moving = false,
  progress = 0,
  turnTimer = 0,
  stepFrames = 16,
  stepFramesCur = 8,
}, { __index = Player })

local map = {
  def = { tileset = "FIX_OUT" },
  inBounds = function(_, x, y) return x >= 0 and x < 5 and y >= 0 and y < 6 end,
  cellTile = function(_, x, y)
    if x == 2 and y == 2 then return 1 end
    if x == 2 and y == 3 then return 2 end
    return 0
  end,
  isWalkableCell = function(_, x, y) return x == 2 and y == 4 end,
}

local world = setmetatable({
  player = player,
  map = map,
  entities = { player },
  scriptMoves = {},
  marchers = {},
}, { __index = OW })

local function advance(frames)
  for _ = 1, frames do
    world:updateScriptMoves()
    player:update()
  end
end

T.check(world:checkLedgeHop("down"), "the synthetic ledge starts a hop")
T.eq(player.hopFrames, 16, "the arc uses two active 8-frame steps")
T.eq(player.hopTotal, 16, "the pose denominator uses the same duration")

advance(8)
local _, _, peakY, _, _, _, peakHopping = player:pose()
T.eq(player.cellY, 3, "one active step reaches the ledge tile")
T.eq(peakY, player.py - 10, "the arc peaks after the first tile")
T.check(peakHopping, "the hop remains active at its midpoint")

advance(8)
local _, _, landedY, _, _, _, landedHopping = player:pose()
T.eq(player.cellY, 4, "the second active step reaches the landing tile")
T.eq(player.hopFrames, 0, "the arc ends on the landing frame")
T.eq(landedY, player.py, "the landed pose returns to ground height")
T.check(not landedHopping, "the landed pose is no longer hopping")

package.loaded["src.core.Sound"] = realSound
T.finish("ledge step-frame timing")

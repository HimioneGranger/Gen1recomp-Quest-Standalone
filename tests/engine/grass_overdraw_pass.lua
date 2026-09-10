-- ROM-free runtime contract for the visible-cell tall-grass overdraw pass.
--   luajit tests/engine/grass_overdraw_pass.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

love = require("tests.love_stub")

local T = require("tests.modkit")
local PaletteFX = require("src.render.PaletteFX")
local TileRenderer = require("src.render.TileRenderer")

local block = {}
for i = 1, 16 do block[i] = 1 end
local map = {
  tileset = { blocks = { block } },
  blockAt = function() return 0 end,
  tileAt = function() return 1 end,
  isGrassCell = function(_, cx, cy) return cx == 0 and cy == 0 end,
}
local renderer = setmetatable({
  bodyTilesW = 4,
  bodyTilesH = 4,
  image = {},
  map = map,
  quads = { [1] = {} },
  claimedBy = {},
  anims = {},
}, { __index = TileRenderer })

renderer:ensureWindow(0, 0, 32, 32)
T.eq(#renderer.grassCells, 1, "the visible grass cell is recorded once")
T.eq(renderer.grassCells[1][1], 0, "the recorded grass x is stable")
T.eq(renderer.grassCells[1][2], 0, "the recorded grass y is stable")
T.eq(#renderer.grassBatch.sprites, 2,
  "the DMG/SGB batch contains both bottom-row tiles")

local oldDraw = love.graphics.draw
local drawn, drawX, drawY
love.graphics.draw = function(batch, x, y)
  drawn, drawX, drawY = batch, x, y
end
renderer:drawGrassOverdraw(3.8, 4.2)
love.graphics.draw = oldDraw
T.eq(drawn, renderer.grassBatch, "flat overdraw uses one grass SpriteBatch")
T.eq(drawX, -3, "flat grass follows the floored camera x")
T.eq(drawY, -4, "flat grass follows the floored camera y")

local oldMark = PaletteFX.markSpriteRedraw
local marks = 0
PaletteFX.markSpriteRedraw = function() marks = marks + 1 end
renderer:markGrassOverdrawRedraw(0, 0, { 1, 1, 1, 1 })
PaletteFX.markSpriteRedraw = oldMark
T.eq(marks, 2, "GBC palette replay queues both bottom-row tiles")

local raw = {}
local gbc = setmetatable({
  gbcCtx = {},
  grassCells = { { 1, 2 }, { 3, 4 } },
  drawCellBottomRaw = function(_, cx, cy)
    raw[#raw + 1] = { cx, cy }
  end,
}, { __index = TileRenderer })
gbc:drawGrassOverdraw(0, 0)
T.eq(#raw, 2, "GBC draws each pre-keyed grass cell")
T.eq(raw[2][1], 3, "GBC keeps visible-cell order")

local released = 0
renderer.winBatch.release = function() released = released + 1 end
renderer.grassBatch.release = function() released = released + 1 end
renderer:releaseBatches()
T.eq(released, 2, "release frees both task-owned SpriteBatches")
T.eq(renderer.grassCells, nil, "release clears the visible-cell cache")

T.finish("grass overdraw pass")

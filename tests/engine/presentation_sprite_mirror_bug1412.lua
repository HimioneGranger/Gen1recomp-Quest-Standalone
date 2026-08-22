-- Evolution and trade front sprites use the Game Boy movie orientation.
-- ROM-free: synthetic sprites and captured draw calls only.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
love = require("tests.love_stub")

local draws = {}
local graphics = love.graphics
local originalDraw = graphics.draw
graphics.draw = function(...)
  draws[#draws + 1] = { ... }
end

local Font = require("src.render.Font")
local originalFontDraw = Font.draw
Font.draw = function() end

local sprite = {
  getWidth = function() return 24 end,
  getHeight = function() return 32 end,
  getDimensions = function() return 24, 32 end,
}

local EvolutionState = require("src.ui.EvolutionState")
EvolutionState.draw({
  done = false,
  t = 0,
  oldName = "MON",
  oldSprite = sprite,
  oldSpriteTrueColor = false,
})
local evo = draws[#draws]
T.eq(evo[1], sprite, "evolution draws the selected front sprite")
T.eq(evo[2], 92, "evolution anchors the mirrored 24-pixel sprite")
T.eq(evo[4], 0, "evolution mirror keeps zero rotation")
T.eq(evo[5], -1, "evolution front sprite is mirrored horizontally")
T.eq(evo[6], 1, "evolution front sprite keeps vertical scale")

local TradeAnim = require("src.ui.TradeAnim")
local function drawTrade(phase, key)
  draws = {}
  local state = {
    phase = phase,
    scx = 0,
    monVisible = true,
    sentSprite = key == "sent" and sprite or nil,
    recvSprite = key == "recv" and sprite or nil,
    sentSpriteTrueColor = false,
    recvSpriteTrueColor = false,
    sent = {}, received = {}, playerOt = "A", enemyName = "B",
    playerOtId = 1, enemyOtId = 2,
    drawMonInfo = function() end,
  }
  TradeAnim.draw(state)
  return draws[#draws]
end

local sent = drawTrade("show_player", "sent")
T.eq(sent[2], 80, "sent trade sprite anchors after its width")
T.eq(sent[5], -1, "sent trade sprite is mirrored horizontally")
local received = drawTrade("show_enemy", "recv")
T.eq(received[2], 80, "received trade sprite anchors after its width")
T.eq(received[5], -1, "received trade sprite is mirrored horizontally")

Font.draw = originalFontDraw
graphics.draw = originalDraw

T.finish("presentation sprite mirror (#1412)")

-- ROM-free trade cable geometry and fallback regression for upstream
-- f5b8b6c85fb20b91de53f5f8ab274a3c799fb287.
--   luajit tests/engine/trade_cable_geometry.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local S = require("tests.harness").suite("trade cable geometry")
local check, eq = S.check, S.eq

local Data = T.fixtures.fresh()
local Game = require("src.core.Game")
local Input = require("src.core.Input")
local SaveData = require("src.core.SaveData")
local TradeAnim = require("src.ui.TradeAnim")

Game.data = Data
Game.input = Input; Input:init()
Game.save = SaveData.newGame()
Game.save.player.name = "RED"

local species = T.fixtures.ids.species[1]
local mon = { species = species, nickname = "MON", ot = "TRAINER", otId = 1 }
local anim = TradeAnim.new(Game, { sent = mon, received = mon })

local G = love.graphics
local realDraw, realNewQuad, realRectangle = G.draw, G.newQuad, G.rectangle
local draws, quads, rects

local function image(name, w, h)
  return {
    name = name,
    getDimensions = function() return w or 8, h or 8 end,
  }
end

local horiz = image("horizontal", 160, 8)
local segment = image("segment", 8, 8)
local vertical = image("vertical", 8, 8)

local function reset()
  draws, quads, rects = {}, {}, {}
  G.draw = function(img, ...)
    draws[#draws + 1] = { image = img, args = { ... } }
  end
  G.newQuad = function(x, y, w, h, iw, ih)
    local quad = { x = x, y = y, w = w, h = h, iw = iw, ih = ih }
    quads[#quads + 1] = quad
    return quad
  end
  G.rectangle = function(mode, x, y, w, h)
    rects[#rects + 1] = { mode = mode, x = x, y = y, w = w, h = h }
  end
end

anim.img = { cableHoriz = horiz, cableVert = vertical }
reset()
anim:drawLeftGB()
eq(#quads, 1, "left cable uses one cropped quad")
eq(quads[1].w, 64, "left cable quad is cropped to its 64-pixel span")
eq(draws[1].args[2], 96, "left cable starts at x=96 without scroll-offset overshoot")

reset()
anim:drawRightGB()
eq(#quads, 1, "right cable uses one cropped quad")
eq(quads[1].w, 112, "right cable quad is cropped to its 112-pixel span")
local verticalXs = {}
for _, call in ipairs(draws) do
  if call.image == vertical then verticalXs[#verticalXs + 1] = call.args[1] end
end
eq(#verticalXs, 4, "right cable draws four vertical segments")
for i, x in ipairs(verticalXs) do
  eq(x, 112, ("right vertical segment %d aligns with the corner"):format(i))
end

anim.img = { cableSeg = segment }
reset()
anim:drawLeftGB()
eq(#draws, 8, "left cable falls back to eight 8-pixel segments")
eq(draws[1].args[1], 96, "left segment fallback starts at x=96")
eq(draws[#draws].args[1], 152, "left segment fallback ends at x=152")

reset()
anim:drawRightGB()
eq(#draws, 14, "right cable falls back to fourteen 8-pixel segments")
eq(draws[1].args[1], 0, "right segment fallback starts at x=0")
eq(draws[#draws].args[1], 104, "right segment fallback ends at x=104")

anim.img = {}
reset()
anim:drawLeftGB()
check(#rects >= 1, "missing cable art uses a rectangle fallback")
eq(rects[1].w, 64, "left rectangle fallback matches the cable span")

G.draw, G.newQuad, G.rectangle = realDraw, realNewQuad, realRectangle
S.finish()

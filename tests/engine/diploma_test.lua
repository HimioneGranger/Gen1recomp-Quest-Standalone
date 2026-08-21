-- ROM-free Diploma layout, palette, player-art, and dismissal regression.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Data = T.fixtures.fresh()
local S = require("tests.harness").suite("diploma")
local check, eq = S.check, S.eq

local Game = require("src.core.Game")
local Input = require("src.core.Input")
local StateStack = require("src.core.StateStack")
local SaveData = require("src.core.SaveData")
local Font = require("src.render.Font")

Game.data = Data
Data.palettes = {
  palettes = {
    MEWMON = { {255,255,255}, {180,180,180}, {90,90,90}, {0,0,0} },
  },
}
Game.input = Input; Input:init()
Game.stack = StateStack; StateStack:init()
Game.save = SaveData.newGame()
Game.save.player.name = "ASH"
Font.load(Data)

local G = love.graphics
local realDraw, realNewImage, realNewQuad = G.draw, G.newImage, G.newQuad
local draws, loaded, quadCount = {}, {}, 0
G.newImage = function(path)
  loaded[path] = true
  return realNewImage(path)
end
G.newQuad = function(...)
  quadCount = quadCount + 1
  return realNewQuad(...)
end
G.draw = function(image, ...)
  draws[#draws + 1] = { image = image, args = { ... } }
end

local Diploma = require("src.ui.Diploma")
local done = false
local diploma = Diploma.new(Game, function() done = true end)
Game.stack:push(diploma)

check(diploma.isOpaque, "Diploma is an opaque screen")
local pals = diploma:sgbPalettes(Game)
check(pals ~= nil, "Diploma resolves the MEWMON whole-screen palette")

local ok, err = pcall(function() diploma:draw() end)
check(ok, "Diploma renders from synthetic images: " .. tostring(err))
check(loaded["assets/generated/trainer_card/trainer_info.png"],
  "Diploma loads the ornate frame through the asset seam")
check(loaded["assets/generated/trainer_card/circle_tile.png"],
  "Diploma loads the header circle through the asset seam")
check(loaded["assets/generated/trainer_card/red.png"],
  "Diploma resolves the default player front picture")
eq(quadCount, 9, "Diploma slices all nine frame tiles")

local playerDraw
for _, call in ipairs(draws) do
  if call.image and call.image.path == "assets/generated/trainer_card/red.png" then
    playerDraw = call
    break
  end
end
check(playerDraw ~= nil, "Diploma draws the player picture")
if playerDraw then
  eq(playerDraw.args[1], 115, "player picture x matches DisplayDiploma")
  eq(playerDraw.args[2], 80, "player picture y matches DisplayDiploma")
end

G.draw, G.newImage, G.newQuad = realDraw, realNewImage, realNewQuad

Input.pressed = { a = true }
diploma:update()
check(done, "Diploma calls onDone on A press")
eq(Game.stack:top(), nil, "Diploma pops from the stack")

S.finish()

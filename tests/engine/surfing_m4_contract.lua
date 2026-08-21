-- ROM-free contracts for the M4 Surfing Pikachu source and extraction lane.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")

local function read(path)
  local file = assert(io.open(path, "rb"))
  local body = file:read("*a")
  file:close()
  return body
end

local build = read("tools/build_rom_data.py")
T.check(build:find('_has_symbol(symbols, "SurfingPikachu1Graphics1")', 1, true),
  "extractor gates Surfing Pikachu assets by the Yellow symbol")
for _, path in ipairs({
  "minigame/surf_1a.png",
  "minigame/surf_1b.png",
  "minigame/surf_1c.png",
  "minigame/title_bg.png",
}) do
  T.check(build:find(path, 1, true), "extractor declares " .. path)
end

local game = read("src/core/Game.lua")
T.check(game:find("Game.isFixedSpeedInStack(self.stack)", 1, true),
  "game speed checks fixed-speed states before overrides")
local music = read("src/core/Music.lua")
T.check(music:find("function Music.setPitch(pitch)", 1, true),
  "music exposes the minigame pitch control")

local world = read("src/world/OverworldController.lua")
T.check(world:find("drawCellBottom(e.cellX, e.cellY", 1, true),
  "flat world overdraws grass only for an entity's current cell")
T.check(world:find("drawCellBottom(e.targetX, e.targetY", 1, true),
  "flat world includes an entity's target grass cell")
T.check(world:find("drawCellBottomRaw(e.cellX, e.cellY", 1, true),
  "tilted world keeps grass attached to the entity billboard")

local tiles = read("src/render/TileRenderer.lua")
T.check(not tiles:find("function TileRenderer:drawGrassOverdraw", 1, true),
  "tile renderer does not overdraw every visible grass cell")

T.finish("surfing M4 contract")

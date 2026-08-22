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
T.check(world:find("drawGrassOverdraw(cam.x, bgY)", 1, true),
  "flat world overdraws every visible grass cell after sprites")
T.check(world:find("markGrassOverdrawRedraw(cam.x, bgY, grassColors)", 1, true),
  "flat GBC overdraw keeps its post-zone palette replay")
T.check(world:find('kind = "grass"', 1, true),
  "tilted world depth-sorts grass cells as independent billboards")
T.check(world:find("drawCellBottomRaw(cx, cy, cam.x, bgY)", 1, true),
  "tilted grass billboards keep the elevator-shake offset")

local tiles = read("src/render/TileRenderer.lua")
T.check(tiles:find("function TileRenderer:drawGrassOverdraw", 1, true),
  "tile renderer exposes the visible-cell grass pass")
T.check(tiles:find("function TileRenderer:markGrassOverdrawRedraw", 1, true),
  "tile renderer exposes the GBC redraw pass")

T.finish("surfing M4 contract")

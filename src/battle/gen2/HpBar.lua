-- The HP bar, exactly as the cart computes it.
--
-- Two routines, and both matter for parity because the bar is what a player
-- reads the whole battle off:
--
-- engine/pokemon/health.asm ComputeHPBarPixels
--   pixels = curHP * HP_BAR_LENGTH_PX / maxHP, floored, where
--   HP_BAR_LENGTH_PX = HP_BAR_LENGTH (6 tiles) * TILE_WIDTH (8) = 48.
--   A live mon never shows an empty bar: a result of 0 is forced to 1.
--   A fainted mon shows exactly 0.
--   When maxHP >= 256 the routine divides both the product and maxHP by 4
--   first, because hDivisor is one byte -- so a high-HP mon's bar moves in
--   coarser steps than the exact ratio would.  Reproduced, not smoothed over.
--
-- home/tilemap.asm GetHPPal
--   green  when pixels >= 24   (HP_BAR_LENGTH_PX * 50 / 100)
--   yellow when pixels >= 10   (HP_BAR_LENGTH_PX * 21 / 100, integer 10)
--   red    otherwise
--   Note the boundaries are inclusive on the *pixel* count, not a percentage:
--   exactly half HP is green, and the yellow floor is 10/48 rather than 21%.
--
-- Colours themselves come from palettes.lua's hpBar (gfx/battle/hp_bar.pal).

local HpBar = {}

HpBar.LENGTH_TILES = 6
HpBar.TILE_WIDTH = 8
HpBar.LENGTH_PX = HpBar.LENGTH_TILES * HpBar.TILE_WIDTH -- 48
-- How tall the coloured channel is inside the bar's frame.  The cart's bar
-- tiles are 8px rows with a 1px rule above and below the fill.
HpBar.CHANNEL_PX = 3

-- GetHPPal's thresholds, computed the way RGBDS does (integer division).
HpBar.GREEN_PIXELS = math.floor(HpBar.LENGTH_PX * 50 / 100)  -- 24
HpBar.YELLOW_PIXELS = math.floor(HpBar.LENGTH_PX * 21 / 100) -- 10

-- Pixels of bar to fill, 0..48.
function HpBar.pixels(hp, maxHp)
  hp = math.max(0, hp or 0)
  maxHp = math.max(0, maxHp or 0)
  if hp == 0 then return 0 end
  if maxHp == 0 then return 0 end
  local product = hp * HpBar.LENGTH_PX
  local divisor = maxHp
  if divisor >= 256 then
    -- The one-byte-divisor shift, applied to both sides.
    product = math.floor(product / 4)
    divisor = math.floor(divisor / 4)
    if divisor == 0 then divisor = 1 end
  end
  local pixels = math.floor(product / divisor)
  if pixels == 0 then return 1 end
  return math.min(HpBar.LENGTH_PX, pixels)
end

-- "green" / "yellow" / "red", keyed to match palettes.lua's hpBar table.
function HpBar.palette(pixels)
  if (pixels or 0) >= HpBar.GREEN_PIXELS then return "green" end
  if (pixels or 0) >= HpBar.YELLOW_PIXELS then return "yellow" end
  return "red"
end

function HpBar.paletteFor(hp, maxHp)
  return HpBar.palette(HpBar.pixels(hp, maxHp))
end

-- The bar's two colours out of palettes.lua: the light background the empty
-- part of the bar shows, and the fill.
function HpBar.colors(palettes, key)
  local pal = palettes and palettes.hpBar and palettes.hpBar[key]
  if not pal then return nil, nil end
  return pal[1], pal[2]
end

-- Draw the bar at a pixel position: 6 tiles wide, black frame, white interior,
-- coloured fill from the left.
--
-- The cart builds it out of tiles -- $62 is an empty bar cell and $63..$6a are
-- the eight partial fills, so the fill really does move one pixel at a time
-- inside a fixed 48px frame, and the *unfilled* part is white, not tinted.
function HpBar.draw(palettes, hp, maxHp, px, py)
  local G = love and love.graphics
  if not G then return end
  local pixels = HpBar.pixels(hp, maxHp)
  local _, fill = HpBar.colors(palettes, HpBar.palette(pixels))
  -- Frame: one pixel of black around the 48x2 channel the fill lives in.
  G.setColor(0, 0, 0, 1)
  G.rectangle("fill", px - 1, py - 1, HpBar.LENGTH_PX + 2, HpBar.CHANNEL_PX + 2)
  G.setColor(1, 1, 1, 1)
  G.rectangle("fill", px, py, HpBar.LENGTH_PX, HpBar.CHANNEL_PX)
  if pixels > 0 then
    if fill then
      G.setColor(fill[1] / 255, fill[2] / 255, fill[3] / 255, 1)
    else
      G.setColor(0.1, 0.1, 0.1, 1)
    end
    G.rectangle("fill", px, py, pixels, HpBar.CHANNEL_PX)
  end
  G.setColor(0, 0, 0, 1)
end

-- The battle HUD's bar, which is the plain bar with the cart's "HP:" prefix in
-- front of it (tiles $60/$61 in home/pokemon.asm, two tiles wide).  `tx`/`ty`
-- are the tile the prefix starts at; the bar follows two tiles later, so the
-- whole assembly is 2 + 6 = 8 tiles wide.
--
-- Returns the tile column just past the bar, so a caller can put the bar's end
-- cap or the frame stub there.
function HpBar.drawWithLabel(palettes, hp, maxHp, tx, ty, font)
  if font then
    love.graphics.setColor(0, 0, 0, 1)
    font.draw("HP:", tx * 8, ty * 8)
  end
  -- The bar's channel sits in the middle of the tile row, matching the tiles.
  HpBar.draw(palettes, hp, maxHp, (tx + 2) * 8, ty * 8 + 2)
  return tx + 2 + HpBar.LENGTH_TILES
end

-- The experience bar under the player's HUD (FillInExpBar).  Same 6-tile
-- width, but it fills toward the *next* level rather than showing a ratio of a
-- maximum, and it is a flat blue with no colour states (gfx/battle/exp_bar.pal).
function HpBar.drawExp(palettes, fraction, px, py)
  local G = love and love.graphics
  if not G then return end
  fraction = math.max(0, math.min(1, fraction or 0))
  local pixels = math.floor(fraction * HpBar.LENGTH_PX)
  local pal = palettes and palettes.expBar
  local fill = pal and pal[2] or pal and pal[1]
  G.setColor(0, 0, 0, 1)
  G.rectangle("fill", px - 1, py - 1, HpBar.LENGTH_PX + 2, 3)
  G.setColor(1, 1, 1, 1)
  G.rectangle("fill", px, py, HpBar.LENGTH_PX, 1)
  if pixels > 0 then
    if fill then
      G.setColor(fill[1] / 255, fill[2] / 255, fill[3] / 255, 1)
    else
      G.setColor(0.3, 0.55, 0.95, 1)
    end
    G.rectangle("fill", px, py, pixels, 1)
  end
  G.setColor(0, 0, 0, 1)
end

-- How far along its current level a mon is, for the exp bar.
function HpBar.expFraction(mon, growth, levelFor)
  if not (mon and growth and levelFor) then return 0 end
  local level = mon.level or 1
  local base = levelFor(growth, level)
  local next_ = levelFor(growth, level + 1)
  if next_ <= base then return 0 end
  local into = (mon.experience or base) - base
  return math.max(0, math.min(1, into / (next_ - base)))
end

return HpBar

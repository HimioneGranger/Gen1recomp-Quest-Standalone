-- Drawing for the Gen 2 battle-animation runtime.
--
-- src/battle/gen2/AnimRunner.lua produces two things a frame: a list of OAM
-- entries (the OBJ layer) and a set of BG register writes.  This turns them
-- into draw calls, and it is the only half of the runtime that touches love.
--
-- The BG half is the interesting one.  A Gen 2 battle animation shakes and
-- sinks its mons through wLYOverridesBackup -- a per-scanline value the LCD
-- STAT interrupt writes into rSCX or rSCY as the beam passes -- so the port
-- draws the battle panel into a canvas and then blits it back one scanline at
-- a time at that scanline's own offset.  144 quads a frame is nothing, and it
-- is the only model that gets Tackle (every row of the attacker moves the same
-- way) and Withdraw (a growing number of rows are pushed off while the rest
-- stay) both right out of the same data.
--
-- OBJs are NOT affected by SCX/SCY, so they are drawn after the blit, at their
-- own coordinates.

local bit = require("bit")
local Assets = require("src.render.Assets")
local GbcPalette = require("src.render.GbcPalette")
local Palettes = require("src.world.gen2.Palettes")

local BattleAnimView = {}
BattleAnimView.__index = BattleAnimView

local SCREEN_W, SCREEN_H = 160, 144

-- An OBJ at OAM (x, y) draws at (x - 8, y - 16).
local OAM_X_BIAS, OAM_Y_BIAS = 8, 16

local OAM_YFLIP, OAM_XFLIP = 0x40, 0x20

-- Every coordinate the runtime produces is a byte, and the ones that mean
-- "left of / above the origin" arrive as two's complement.
local function signed(value)
  value = (value or 0) % 256
  return value < 0x80 and value or value - 256
end

-- data: the cache's battle_anims.lua; palettes: the cache's palettes.lua
function BattleAnimView.new(data, palettes)
  local self = setmetatable({}, BattleAnimView)
  self.data = data or {}
  self.palettes = palettes
  self.images = {}
  self.quads = {}
  self.canvas = nil
  self.blitQuad = nil
  return self
end

function BattleAnimView:image(path)
  if not path then return nil end
  local cached = self.images[path]
  if cached == nil then
    -- `and` would truncate pcall's second return, so this cannot fold into a
    -- one-liner: every sheet would come back "unavailable".
    local ok, image = pcall(Assets.image, path)
    self.images[path] = (ok and image) or false
    cached = self.images[path]
  end
  return cached or nil
end

function BattleAnimView:quad(sheetName, index, wide, image)
  local key = sheetName .. ":" .. index
  local quad = self.quads[key]
  if not quad then
    local w, h = image:getDimensions()
    quad = love.graphics.newQuad(
      (index % wide) * 8, math.floor(index / wide) * 8, 8, 8, w, h)
    self.quads[key] = quad
  end
  return quad
end

-- Which loaded sheet a tile id falls in.  The runner's `loaded` list is in
-- load order and each entry knows its base tile and its length, which is the
-- same walk GetBattleAnimTileOffset does in reverse.
local function sheetForTile(runner, tile)
  for i = #runner.loaded, 1, -1 do
    local entry = runner.loaded[i]
    if tile >= entry.tile and tile < entry.tile + math.max(entry.tiles, 1) then
      return entry, tile - entry.tile
    end
  end
  return nil
end

-- PAL_BATTLE_OB_ENEMY and PAL_BATTLE_OB_PLAYER are the two battlers' own
-- colours; the other six are the fixed block from
-- gfx/battle_anims/battle_anims.pal, which the extractor reads into
-- palettes.battleObjects.
function BattleAnimView:objPalette(name, battle)
  if name == "PAL_BATTLE_OB_ENEMY" then
    local enemy = battle and battle.enemy
    return enemy and Palettes.monColors(self.palettes, enemy.species, enemy.shiny)
  end
  if name == "PAL_BATTLE_OB_PLAYER" then
    local player = battle and battle.player
    return player and Palettes.monColors(self.palettes, player.species, player.shiny)
  end
  local set = self.palettes and self.palettes.battleObjects
  return set and set[name] or nil
end

-- One frame's OBJ layer.
function BattleAnimView:drawObjects(runner, battle)
  local G = love.graphics
  G.setColor(1, 1, 1, 1)
  for _, obj in ipairs(runner:oam()) do
    local entry, index = sheetForTile(runner, obj.tile)
    -- The two battler-pic pseudo-sheets are the mons' own tiles; nothing in
    -- the cache holds them as a sheet, so they are simply not drawn rather
    -- than drawn from the wrong image.
    if entry and not entry.battler then
      local sheet = (self.data.gfx or {})[entry.gfx]
      local image = sheet and self:image(sheet.image)
      if image then
        local wide = sheet.wide or 8
        local quad = self:quad(entry.gfx, index, wide, image)
        local _, sy = quad:getViewport()
        local _, ih = image:getDimensions()
        if sy < ih then
          local x = obj.x - OAM_X_BIAS
          local y = obj.y - OAM_Y_BIAS
          -- love flips about the draw origin, so a flipped 8x8 sprite has to
          -- be pushed one cell back along that axis.
          local sxScale = bit.band(obj.attr, OAM_XFLIP) ~= 0 and -1 or 1
          local syScale = bit.band(obj.attr, OAM_YFLIP) ~= 0 and -1 or 1
          local ox = sxScale < 0 and 8 or 0
          local oy = syScale < 0 and 8 or 0
          local colors = self:objPalette(obj.palette, battle)
          local function body()
            G.draw(image, quad, x + ox, y + oy, 0, sxScale, syScale)
          end
          if colors and GbcPalette.available() then
            GbcPalette.with(colors, body)
          else
            body()
          end
        end
      end
    end
  end
end

-- True when the BG layer needs the scanline treatment at all; a plain
-- animation (most of them) skips the canvas entirely.
local function needsCanvas(runner)
  local bg = runner.bg
  if bg.scx ~= 0 or bg.scy ~= 0 then return true end
  if not bg.lcdc then return false end
  if bg.lyEnd <= bg.lyStart then return false end
  for row = bg.lyStart, math.min(bg.lyEnd, SCREEN_H) - 1 do
    if (bg.lyBackup[row] or 0) ~= 0 then return true end
  end
  return false
end

-- The battle background is BG colour 0 everywhere the two pic boxes and the
-- text box are not, which Chrome.clear draws as plain white; anything the
-- scanline blit exposes has to be that colour and not a hole.
function BattleAnimView:fillBackground()
  local G = love.graphics
  G.setColor(1, 1, 1, 1)
  G.rectangle("fill", 0, 0, SCREEN_W, SCREEN_H)
end

-- One reusable quad, re-aimed per scanline.  A row shifted by `dx` is drawn
-- CLIPPED to the 160-pixel screen rather than allowed to hang over the edge:
-- the cart's BG map wraps, so a scrolled scanline never spills past the LCD.
function BattleAnimView:blitRow(row, dx, dy)
  local canvas = self.canvas
  if not self.blitQuad then
    self.blitQuad = love.graphics.newQuad(0, 0, SCREEN_W, 1, SCREEN_W, SCREEN_H)
  end
  local srcX, width, destX = 0, SCREEN_W, dx
  if dx > 0 then
    width = SCREEN_W - dx
  elseif dx < 0 then
    srcX, width, destX = -dx, SCREEN_W + dx, 0
  end
  if width <= 0 then return end
  self.blitQuad:setViewport(srcX, row, width, 1, SCREEN_W, SCREEN_H)
  love.graphics.draw(canvas, self.blitQuad, destX, row + dy)
end

-- Draw the battle panel into the blit canvas, optionally with an rBGP byte
-- folded into every palette on the way in.
--
-- The byte is set on GbcPalette rather than applied afterwards, which is what
-- makes it exact: the panel is still being DRAWN, so its palettes can take
-- CopyPals' permutation before they ever reach the shader.  That is bit for bit
-- what DmgToCgbBGPals does, and it is why nothing here has to guess which
-- palette entry produced a finished pixel.
--
-- pcall so a drawBg that throws cannot leave the byte standing on GbcPalette
-- for the rest of the frame.
function BattleAnimView:bake(drawBg, palByte)
  local G = love.graphics
  if not self.canvas then
    self.canvas = G.newCanvas(SCREEN_W, SCREEN_H)
    self.canvas:setFilter("nearest", "nearest")
  end
  local previousCanvas = G.getCanvas()
  local previousBgp = GbcPalette.setBgp(palByte)
  G.setCanvas(self.canvas)
  G.clear(0, 0, 0, 0)
  -- A love canvas does NOT reset the transform: without this the panel is
  -- drawn at whatever scale and offset the caller was already under, and then
  -- scaled again on the way back out.
  G.push()
  G.origin()
  local ok, err = pcall(drawBg)
  G.pop()
  G.setCanvas(previousCanvas)
  GbcPalette.setBgp(previousBgp)
  if not ok then error(err, 0) end
end

-- The rBGP window's scanlines grouped by the byte they hold, identity first.
--
-- `.SetLYOverridesBackup` writes one value on every SECOND row and leaves the
-- rest on whatever ClearLYOverrides put there, so a beta send-out frame holds
-- two bytes and FadeMonsToBlackRepeating's DMG path holds two bands of one
-- each.  Grouping means the panel is re-baked twice a frame rather than 144
-- times, and the grouping is by VALUE so a table that happens to repeat costs
-- nothing extra.
local function bgpBands(bg)
  local order, bands = {}, {}
  for row = 0, SCREEN_H - 1 do
    local inWindow = row >= bg.lyStart and row < bg.lyEnd
    -- Outside the window the register still reads whatever wBGP holds, which
    -- for every effect that aims hLCDCPointer at rBGP is the identity.
    local byte = inWindow and (bg.lyBackup[row] or GbcPalette.BGP_IDENTITY)
      or GbcPalette.BGP_IDENTITY
    local band = bands[byte]
    if not band then
      band = { byte = byte, rows = {} }
      bands[byte] = band
      order[#order + 1] = band
    end
    band.rows[#band.rows + 1] = row
  end
  -- Identity first so the fillBackground below it happens before any blit and
  -- the common band is the one drawn from the first bake.
  table.sort(order, function(a, b)
    if a.byte == b.byte then return false end
    if a.byte == GbcPalette.BGP_IDENTITY then return true end
    if b.byte == GbcPalette.BGP_IDENTITY then return false end
    return a.rows[1] < b.rows[1]
  end)
  return order
end

-- Runs `drawBg` (the battle panel) and then puts it on screen through the
-- animation's BG registers.  Returns without a canvas when nothing is
-- displacing anything, which is the common case and costs nothing.
function BattleAnimView:present(runner, drawBg)
  if not (love and love.graphics) then return end
  local bg = runner.bg
  if not needsCanvas(runner) then
    drawBg()
    return
  end
  local G = love.graphics

  -- hLCDCPointer can also aim at rBGP, in which case each scanline gets its own
  -- PALETTE rather than its own scroll (the beta send-out effects, and
  -- FadeMonsToBlackRepeating on the DMG path).  Nothing scrolls on that path,
  -- so the whole of it is: bake the panel once per distinct byte and blit that
  -- byte's rows out of it.
  if bg.lcdc == "BGP" and GbcPalette.available() then
    local baseX, baseY = -signed(bg.scx), -signed(bg.scy)
    local bands = bgpBands(bg)
    local filled = false
    for _, band in ipairs(bands) do
      self:bake(drawBg, band.byte)
      if not filled then
        self:fillBackground()
        filled = true
      end
      G.setColor(1, 1, 1, 1)
      for _, row in ipairs(band.rows) do
        self:blitRow(row, baseX, baseY)
      end
    end
    return
  end

  self:bake(drawBg, nil)

  -- A shifted scanline exposes whatever the BG map holds beside the pic, which
  -- outside the two pic boxes is the blank tile.  Without this the exposed
  -- strip is the canvas's own transparency and every shake shows a seam.
  self:fillBackground()
  G.setColor(1, 1, 1, 1)
  -- hSCX / hSCY move the whole background; the per-scanline overrides only
  -- apply inside the effect's own window.
  local baseX, baseY = -signed(bg.scx), -signed(bg.scy)
  for row = 0, SCREEN_H - 1 do
    local dx, dy = baseX, baseY
    local inWindow = bg.lcdc and row >= bg.lyStart and row < bg.lyEnd
    if inWindow and bg.lcdc ~= "BGP" then
      local value = signed(bg.lyBackup[row] or 0)
      if bg.lcdc == "SCX" then dx = -value else dy = -value end
    end
    -- A row scrolled to $90 is showing a blank part of the map: skip it, which
    -- is what makes Withdraw and Dig look like the mon sinking out of sight.
    if (bg.lyBackup[row] or 0) ~= 0x90 or not bg.lcdc or bg.lcdc == "BGP"
        or not inWindow then
      self:blitRow(row, dx, dy)
    end
  end
  -- Shaderless boot: the panel is raw grayscale, so there are no palettes to
  -- permute and the entry's BRIGHTNESS is the only thing left to reproduce.
  if bg.lcdc == "BGP" then
    for row = math.max(0, bg.lyStart), math.min(bg.lyEnd, SCREEN_H) - 1 do
      local veil = BattleAnimView.palVeil(bg.lyBackup[row])
      if veil ~= 0 then
        local shade = veil > 0 and 0 or 1
        G.setColor(shade, shade, shade, math.min(1, math.abs(veil)))
        G.rectangle("fill", 0, row, SCREEN_W, 1)
      end
    end
    G.setColor(1, 1, 1, 1)
  end
end

-- A DMG palette byte's mean shade against the identity %11100100, signed:
-- +1 is solid black ($ff), -1 solid white ($00), 0 the identity.  The
-- approximation, kept for the shaderless path in `present` above.
function BattleAnimView.palVeil(palByte)
  if not palByte then return 0 end
  local sum = 0
  for index = 0, 3 do
    sum = sum + math.floor(palByte / (4 ^ index)) % 4
  end
  return (sum - 6) / 6
end

--------------------------------------------------------------------------
-- The battle intro slide (engine/battle/sliding_intro.asm)
--------------------------------------------------------------------------

-- BattleIntroSlidingPics runs 72 frames.  It holds three SCX values at once:
-- scanlines 0-$3f take `c`, which starts at $90 and falls by 2 a frame, so
-- the enemy's half enters from the RIGHT; $40-$5f take `b`, which starts at
-- $70 and RISES by 2, wrapping to 0 on the last frame, so the player's half
-- enters from the LEFT; everything from $60 down is already in place.
BattleAnimView.SLIDE_FRAMES = 72

function BattleAnimView.slideOffsets(frame)
  local step = math.max(0, math.min(BattleAnimView.SLIDE_FRAMES, frame))
  local top = (0x90 - step * 2) % 256
  local middle = (0x70 + step * 2) % 256
  return top, middle
end

-- The pixels the cart's OAM back-pic copy still has to travel at `frame`:
-- CopyBackpic parks 18 sprites just off the RIGHT edge (x = 168 in OAM
-- terms) and the slide's `.subfunction1` walks every one left 2px a frame,
-- so the whole pic crosses 144px to its resting column in the 72 frames.
function BattleAnimView.slideBackpicOffset(frame)
  local step = math.max(0, math.min(BattleAnimView.SLIDE_FRAMES, frame))
  return (BattleAnimView.SLIDE_FRAMES - step) * 2
end

-- The same band-at-a-time blit `present` uses, with the intro's own offsets.
--
-- `drawBackpic(offset)`, when given, draws the player's back pic OVER the
-- bands the way the cart's OAM copy rides over them: InitBattleDisplay clears
-- the pic's top rows out of the BG before the slide (the hlcoord 1, 5
-- ClearBox) precisely because the pic straddles the $40 scanline where the
-- two bands part ways -- baked into the bands it tears in half there, its top
-- rows riding the enemy's offset and its bottom rows the player's.  The
-- caller must leave the pic OUT of drawBg and hand it here instead.
function BattleAnimView:presentSlide(frame, drawBg, drawBackpic)
  if not (love and love.graphics) then return end
  local top, middle = BattleAnimView.slideOffsets(frame)
  if top == 0 and middle == 0 then
    drawBg()
    if drawBackpic then drawBackpic(0) end
    return
  end
  local G = love.graphics
  self:bake(drawBg, nil)
  self:fillBackground()
  G.setColor(1, 1, 1, 1)
  for row = 0, SCREEN_H - 1 do
    local scx = 0
    if row < 0x40 then
      scx = top
    elseif row < 0x60 then
      scx = middle
    end
    -- SCX is unsigned and the map wraps at 256, so a value over half the
    -- screen reads as "coming in from the other side" rather than as a jump.
    local dx = -scx
    if scx > 128 then dx = 256 - scx end
    self:blitRow(row, dx, 0)
  end
  if drawBackpic then
    drawBackpic(BattleAnimView.slideBackpicOffset(frame))
  end
end

-- A DMG palette byte read as a shade remap, so a BG effect that fades a mon
-- through $f8/$fc can be applied to that mon's four CGB colours.  The same
-- CopyPals permutation `present` now folds into the whole panel, which is why
-- it lives in GbcPalette and this is a name for it rather than a second copy.
function BattleAnimView.shadeColors(colors, palByte)
  return GbcPalette.remap(colors, palByte)
end

BattleAnimView.SCREEN_W = SCREEN_W
BattleAnimView.SCREEN_H = SCREEN_H

return BattleAnimView

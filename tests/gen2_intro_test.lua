-- The Gold/Silver intro movie: the sprite-anim runtime it is built on
-- (src/ui/gen2/SpriteAnims.lua) and the 17-scene state machine that drives it
-- (src/ui/gen2/GoldSilverIntro.lua).
--
-- ROM-free: the asset fixture below is the shape data/generated/intro.lua has,
-- with just enough of a tilemap to prove the BG map is being built the way
-- Intro_DrawBackground builds it.  Every expected value traces back to
-- pokegold, so a failure names the routine it disagrees with.
--   luajit tests/gen2_intro_test.lua
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 intro")
local check, eq = S.check, S.eq

love = require("tests.love_stub")

local SpriteAnims = require("src.ui.gen2.SpriteAnims")
local GoldSilverIntro = require("src.ui.gen2.GoldSilverIntro")

-- ---- sine -----------------------------------------------------------------
-- engine/math/sine.asm's table as it sits in the Gold ROM at 02:4afb.
local ROM_SINE = {
  [0] = 0x000, 0x019, 0x032, 0x04a, 0x062, 0x079, 0x08e, 0x0a2,
  0x0b5, 0x0c6, 0x0d5, 0x0e2, 0x0ed, 0x0f5, 0x0fb, 0x0ff,
  0x100, 0x0ff, 0x0fb, 0x0f5, 0x0ed, 0x0e2, 0x0d5, 0x0c6,
  0x0b5, 0x0a2, 0x08e, 0x079, 0x062, 0x04a, 0x032, 0x019,
}
local sineOk = true
for index = 0, 31 do
  if SpriteAnims.SINE[index] ~= ROM_SINE[index] then sineOk = false end
end
check(sineOk, "the sine table matches the one in the cart")

-- a = d * sin(a * pi/32), high byte only, two's complement past the halfway
-- point.  AnimSeq_GSIntroChikoritaTotodile leans on all of these.
eq(SpriteAnims.sine(0, 8), 0, "sin(0) is flat")
eq(SpriteAnims.sine(16, 8), 8, "a quarter turn reaches the full amplitude")
eq(SpriteAnims.sine(48, 0x90), 256 - 0x90, "three quarters is the negative peak")
eq(SpriteAnims.cosine(0, 8), 8, "cosine leads sine by a quarter turn")
eq(SpriteAnims.cosine(16, 8), 0, "and is flat where sine peaks")

-- ---- frame stepping -------------------------------------------------------
local sys = SpriteAnims.new()
eq(sys:activeCount(), 0, "a fresh system has no live structs")

-- Frameset_GSIntroShellder: two OAM sets, 8 frames apiece, then oamrestart.
local shellder = sys:init("GS_INTRO_SHELLDER", 7 * 8, 18 * 8)
check(shellder ~= nil, "a struct is handed out")
eq(shellder.x, 56, "depixel 18, 7 puts x at 7 tiles")
eq(shellder.y, 144, "and y at 18 tiles")
eq(shellder.index, 1, "wSpriteAnimCount starts at 1")

local oam = sys:playFrame()
eq(#oam, 4, "OAMData_GSIntroShellder is a 2x2 block")
-- spriteanimoam $6c + dbsprite -1,-1 -> the top-left tile of the pair.
eq(oam[1].tile, 0x6c, "the OAM set's vtile offset lands on the tile id")
eq(oam[1].x, 48, "and the -1 column is 8 pixels left of the struct")
eq(oam[1].y, 136, "with the -1 row 8 pixels up")
eq(oam[2].tile, 0x6d, "the next column is the next tile")
eq(oam[3].tile, 0x7c, "and the next row is 16 tiles on, as the sheet is 16 wide")

-- The first frame consumes one showing and loads a duration of 8, so the pair
-- swaps on the tenth pass, not the ninth.
for _ = 1, 8 do sys:playFrame() end
eq(sys.oam[1].tile, 0x6c, "the first OAM set holds for its whole duration")
eq(sys:playFrame()[1].tile, 0x6e, "then the frameset steps to SHELLDER_2")

-- Ten slots, and the eleventh request is refused (_InitSpriteAnimStruct's
-- carry return).
local fresh = SpriteAnims.new()
for _ = 1, SpriteAnims.NUM_STRUCTS do
  check(fresh:init("GS_INTRO_BUBBLE", 0, 0) ~= nil, nil)
end
eq(fresh:activeCount(), 10, "ten structs fit")
check(fresh:init("GS_INTRO_BUBBLE", 0, 0) == nil, "the eleventh is refused")

-- ---- flips ----------------------------------------------------------------
-- Frameset_GSIntroCyndaquil is the one intro frame with B_OAM_XFLIP on it, and
-- AddOrSubtractX mirrors every dbsprite around its own cell.
local flip = SpriteAnims.new()
flip:init("GS_INTRO_CYNDAQUIL", 100, 100)
local flipped = flip:playFrame()
eq(#flipped, 25, "OAMData_GSIntroStarter is 5x5")
eq(flipped[1].attr % 0x100, SpriteAnims.OAM_XFLIP,
  "the frame's flip toggles into the OAM attribute")
-- dbsprite -3, -3, 4, 4: both offsets are $ec, and AddOrSubtractX turns the
-- x one into -($ec + 8).
eq(flipped[1].x, (100 - (0xec + 8)) % 256, "and mirrors the x offset")
eq(flipped[1].y, (100 + 0xec) % 256, "while y is untouched")

-- ---- sequences ------------------------------------------------------------
-- AnimSeq_GSIntroBubble deletes itself once var2 passes $40.
local bubbles = SpriteAnims.new()
local bubble = bubbles:init("GS_INTRO_BUBBLE", 48, 116)
for _ = 1, 0x40 do bubbles:playFrame() end
check(bubble.index ~= 0, "a bubble survives $40 frames")
bubbles:playFrame()
eq(bubble.index, 0, "and is deleted on the next one")

-- AnimSeq_GSIntroShellder deletes once wGlobalAnimYOffset has carried it to
-- $b0; nothing else moves a Shellder.
local drift = SpriteAnims.new()
local shell = drift:init("GS_INTRO_SHELLDER", 56, 0xa0)
drift.globalY = 0x0f
drift:playFrame()
check(shell.index ~= 0, "a Shellder above $b0 stays")
drift.globalY = 0x10
drift:playFrame()
eq(shell.index, 0, "and goes once the climb pushes it past")

-- AnimSeq_GSIntroLapras: swim in to x $58, hold $b0 frames, swim off left and
-- raise wIntroSpriteStateFlag on the way out.
-- It starts at x $c0 and only moves on the odd frames, so it takes 212 to walk
-- down to the $58 the check is looking for and one step past it.
local sea = SpriteAnims.new()
local lapras = sea:init("GS_INTRO_LAPRAS", 24 * 8, 16 * 8)
for _ = 1, 212 do sea:playFrame() end
eq(lapras.jt, 1, "Lapras reaches its resting spot")
eq(lapras.x, 0x57, "one step past the $58 it was checking for")
eq(lapras.var2, 0xaf, "one frame into the $b0-frame hold")
eq(sea.flag, 0, "with the movie not told to move on yet")
for _ = 1, 2000 do sea:playFrame() end
eq(sea.flag, 1, "leaving the screen raises wIntroSpriteStateFlag")
eq(lapras.index, 0, "and takes the struct with it")

-- AnimSeq_GSIntroPikachu runs four stages; the third is the one that tells
-- Jigglypuff to bail out.
-- $c0 -> $80 is 64 frames at a pixel each, then $30 + 1 frames of wind-up,
-- then the charge covers $80 -> $50 four pixels at a time.
local field = SpriteAnims.new()
local pikachu = field:init("GS_INTRO_PIKACHU", 24 * 8, 14 * 8)
for _ = 1, 65 do field:playFrame() end
eq(pikachu.jt, 1, "Pikachu stops at x $80")
eq(pikachu.x, 0x80, nil)
for _ = 1, 49 do field:playFrame() end
eq(pikachu.jt, 2, "then winds up for $30 frames")
eq(field.flag, 0, "without releasing Jigglypuff yet")
for _ = 1, 12 do field:playFrame() end
eq(pikachu.x, 0x50, "the charge covers $30 pixels")
eq(field.flag, 0, "the flag goes up on the frame that sees the finish line")
field:playFrame()
eq(field.flag, 1, "which is the one after")

-- ---- the movie ------------------------------------------------------------
-- A fixture with the shape the extractor writes: 16-wide metatile grids, four
-- tile ids per metatile, one palette per slot.
local function ramp(count, modulus)
  local out = {}
  for index = 1, count do out[index] = (index - 1) % (modulus or 256) end
  return out
end

local function palette()
  return { { 8, 8, 8 }, { 16, 16, 16 }, { 32, 32, 32 }, { 64, 64, 64 } }
end

local FIXTURE = {
  water = {
    tiles = "water.png", sprites = "water_ob.png",
    meta = ramp(64 * 4), tilemap = ramp(32 * 16, 64), tilemapRows = 32,
    firstRow = 15,
  },
  grass = {
    tiles = "grass.png", sprites = "grass_ob.png",
    meta = ramp(48 * 4), tilemap = ramp(16 * 16, 48), tilemapRows = 16,
    firstRow = 0,
  },
  fire = { tiles = "fire.png", sprites = "fire_ob.png" },
  palettes = {
    waterBg = palette(), waterOb = { palette(), palette() },
    magikarpBg = palette(), magikarpOb = palette(),
    grassBg = palette(), grassOb = palette(),
    startersOb = palette(), fireBg = { palette() },
  },
}

local movie = GoldSilverIntro.new(nil, { intro = FIXTURE })
eq(movie.scene, 1, "the movie opens on IntroScene1")

movie:step()
eq(movie.scene, 2, "which runs once and hands over")
eq(movie.scx, 0x58, "IntroScene1 parks hSCX at $58")
eq(movie.counter1, 0x80, "and gives the bubbles $80 frames")
eq(movie.act, "water", "on the water act's art")
eq(movie.anims:activeCount(), 3, "with Intro_InitShellders' three Shellders")
check(movie.lyActive, "and the per-scanline wobble switched on")

-- Intro_InitBubble's .pixel_table has six 2-byte entries, but the index it
-- reads (wIntroFrameCounter1 & $70, swapped into a 0-7 range) covers eight
-- slots.  On hardware the top two slots read past the table into whatever
-- code bytes follow it, so those two bubble spawns are lost; this is a cart
-- bug, not a porting gap, and the port reproduces the drop rather than
-- inventing entries $6 and $7 never had.
local bubbleCases = {
  { before = 0x71, spot = nil },              -- e=7: past the table, dropped
  { before = 0x61, spot = nil },              -- e=6: past the table, dropped
  { before = 0x51, spot = { 8 * 8, 17 * 8 } }, -- e=5
  { before = 0x41, spot = { 4 * 8, 13 * 8 } }, -- e=4
  { before = 0x31, spot = { 12 * 8, 15 * 8 } }, -- e=3
  { before = 0x21, spot = { 10 * 8, 16 * 8 + 4 } }, -- e=2
  { before = 0x11, spot = { 14 * 8, 18 * 8 + 4 } }, -- e=1
  { before = 0x01, spot = { 6 * 8, 14 * 8 + 4 } },  -- e=0
}
local probe = GoldSilverIntro.new(nil, { intro = FIXTURE })
probe:step()
for _, case in ipairs(bubbleCases) do
  probe.counter1 = case.before
  probe.anims:clear()
  GoldSilverIntro.Scenes[2](probe)
  if case.spot then
    eq(probe.anims:activeCount(), 1,
      ("slot for frame counter $%x spawns a bubble"):format(case.before))
    local live
    for slot = 1, SpriteAnims.NUM_STRUCTS do
      local st = probe.anims.structs[slot]
      if st.index ~= 0 then live = st end
    end
    eq(live.x, case.spot[1] % 256, "at the table's x")
    eq(live.y, case.spot[2] % 256, "and its y")
  else
    eq(probe.anims:activeCount(), 0,
      ("slot for frame counter $%x runs past the table and drops"):format(case.before))
  end
end

-- The BG map is real: Intro_DrawBackground lays metatile row 15 across BG
-- rows 0-1, and Intro_Draw2x2Tiles puts its four tile ids in reading order.
local first = FIXTURE.water.tilemap[15 * 16 + 1]
eq(movie.bgmap[1], FIXTURE.water.meta[first * 4 + 1],
  "BG (0,0) is the first tile of the first metatile of row 15")
eq(movie.bgmap[2], FIXTURE.water.meta[first * 4 + 2], "then its top right")
eq(movie.bgmap[32 + 1], FIXTURE.water.meta[first * 4 + 3], "then its bottom left")

-- The climb: hSCY drops one pixel every other frame, and every sixteenth
-- pixel streams a fresh metatile row into the row that just wrapped off.
local function runTo(state, scene, limit)
  for _ = 1, limit or 4000 do
    if state.scene == scene or state.done then return end
    state:step()
  end
end

runTo(movie, 3)
eq(movie.scene, 3, "the bubbles give way to the climb")
eq(movie.counter1, 0x10, "with $10 metatile rows to stream in")
local rowBefore = movie.tilemapRow
for _ = 1, 32 do movie:step() end
eq(movie.tilemapRow, rowBefore - 1, "32 frames buys one metatile row")
eq(movie.bgRow, 30, "written into the two BG rows that just wrapped")

runTo(movie, 4)
eq(movie.scy, 0x10, "the climb ends 16 pixels below where the map wraps")
check(not movie.lyActive, "and the wobble is off by then")

runTo(movie, 6)
eq(movie.bgp, 0x00, "IntroScene5 fades the BG palette flat")
movie:step()
eq(movie.act, "grass", "IntroScene6 swaps in the grass act")
eq(movie.scx, 0x60, "at hSCX $60")
eq(movie.anims.globalX, 0xa0, "with wGlobalAnimXOffset holding the sprites")

runTo(movie, 8)
eq(movie.scx, 0, "IntroScene7 scrolls all the way left")
local live = {}
for slot = 1, SpriteAnims.NUM_STRUCTS do
  local st = movie.anims.structs[slot]
  if st.index ~= 0 then live[st.seqId] = true end
end
check(live.GSIntroPikachu and live.GSIntroPikachuTail,
  "and Intro_InitPikachu adds the body and the tail")
check(live.GSIntroJigglypuff, "with Jigglypuff still waiting")

runTo(movie, 10, 4000)
movie:step()
eq(movie.act, "fire", "IntroScene10 swaps in the fire act")
eq(movie.scy, 0x80, "starting a screen and a half below the silhouette")
eq(movie.bgp, 0x3f, "with the flat silhouette palette")
-- DrawIntroCharizardGraphic 0: 8x8 tiles of running ids from $00 at (10,6).
eq(movie.bgmap[6 * 32 + 10 + 1], 0x00, "the silhouette starts at tilemap (10,6)")
eq(movie.bgmap[6 * 32 + 17 + 1], 0x07, "and runs its ids across the row")
eq(movie.bgmap[7 * 32 + 10 + 1], 0x08, "then wraps to the next")

runTo(movie, 13, 4000)
eq(movie.counter1, 0x80, "IntroScene12 leaves $80 frames of held breath")
runTo(movie, 15, 4000)
eq(movie.bgmap[6 * 32 + 8 + 1], 0x88, "the fire-breathing frame is redrawn wider")

runTo(movie, 17, 4000)
for _ = 1, 64 do movie:step() end
check(movie.done, "and 64 frames of black end the movie")

-- The whole thing, start to finish, is about 39 seconds -- which is what the
-- cart takes.  A wrong counter shows up here before it shows up on screen.
local timed = GoldSilverIntro.new(nil, { intro = FIXTURE })
local frames = 0
for index = 1, 6000 do
  if timed:step() then frames = index break end
end
check(frames > 2200 and frames < 2500,
  "the movie runs about 2300 frames (got " .. frames .. ")")

-- Any button skips it, as .PlayFrame does on PAD_BUTTONS.
local skipped, called = GoldSilverIntro.new(nil, { intro = FIXTURE }), false
skipped.onDone = function() called = true end
skipped:skip()
check(called, "a skip reports the movie as done")

-- ---- palette remapping ----------------------------------------------------
-- CopyPals: colour i comes from colour (reg >> 2i) & 3 of the loaded palette.
local base = { { 1, 1, 1 }, { 2, 2, 2 }, { 3, 3, 3 }, { 4, 4, 4 } }
local identity = GoldSilverIntro.remap(base, 0xe4)
eq(identity[1][1], 1, "%11100100 is the identity")
eq(identity[4][1], 4, nil)
local flat = GoldSilverIntro.remap(base, 0x00)
eq(flat[1][1], 1, "%00000000 collapses every shade")
eq(flat[4][1], 1, "onto colour 0")
local silhouette = GoldSilverIntro.remap(base, 0x3f)
eq(silhouette[1][1], 4, "%00111111 fills the screen with colour 3")
eq(silhouette[4][1], 1, "and paints colour 3 with colour 0")

S.finish()

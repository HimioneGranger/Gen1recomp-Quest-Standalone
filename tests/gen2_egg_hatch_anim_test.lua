-- The egg hatch cutscene's clock, sprite lifetimes and pic placement.
--
--   luajit tests/gen2_egg_hatch_anim_test.lua
--
-- Everything here is geometry or bookkeeping the ASM states outright, so it
-- runs with no cache and no window: EggHatchAnim only reaches love.graphics
-- from its draw path, and the stub below is enough for that.
--
-- What it pins:
--
--   * AnimSeq_RevealNewMon's `cp $80 / jr nc, .finish_EggShell` really does
--     retire the shell fragment (engine/sprite_anims/functions.asm:1270-1305).
--     They used to keep drawing, frozen at their last offset, for the ~113
--     frames left in Hatch_ShellFragmentLoop.
--   * .OAMData_1x1_Palette0's own -4 on each axis is in the screen position
--     (data/sprite_anims/oam.asm:112-114).
--   * The pic sits where PadFrontpic put it (engine/gfx/load_pics.asm:342),
--     which for a 6-wide pic is a whole tile in, not half of one.
--   * hSCX and wGlobalAnimXOffset move the background and the objects the SAME
--     way during a wobble (engine/pokemon/breeding.asm:707-719), so a crack
--     does not slide across the shell it is sitting on.
--   * The EGG has a palette row of its own (data/pokemon/palettes.asm:530).
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 egg hatch anim")
local check, eq = S.check, S.eq

local EggHatchAnim = require("src.ui.gen2.EggHatchAnim")

--------------------------------------------------------------------------
-- A love.graphics that records instead of drawing.  No newShader, so
-- GbcPalette.available() is false and the palette shader stays out of the way.
--------------------------------------------------------------------------

local draws = {}
local ox, oy = 0, 0
local saved = {}
local function fakeImage(w, h)
  return {
    getWidth = function() return w end,
    getHeight = function() return h end,
    getDimensions = function() return w, h end,
  }
end

_G.love = {
  graphics = {
    setColor = function() end,
    rectangle = function() end,
    push = function() saved[#saved + 1] = { ox, oy } end,
    pop = function()
      local t = table.remove(saved)
      ox, oy = t[1], t[2]
    end,
    translate = function(x, y) ox = ox + (x or 0) oy = oy + (y or 0) end,
    scale = function() end,
    newQuad = function(x, y, w, h) return { x = x, y = y, w = w, h = h } end,
    draw = function(_image, a, b, c)
      if type(a) == "table" then
        -- G.draw(image, quad, x, y, ...): a sprite object.
        draws[#draws + 1] = { kind = "sprite", quad = a, x = ox + b, y = oy + c }
      else
        draws[#draws + 1] = { kind = "pic", x = ox + a, y = oy + b }
      end
    end,
  },
}

local function render(anim)
  draws = {}
  anim:drawPanel()
  local out = { pic = nil, sprites = {} }
  for _, d in ipairs(draws) do
    if d.kind == "pic" then out.pic = d
    else out.sprites[#out.sprites + 1] = d end
  end
  return out
end

--------------------------------------------------------------------------
-- A game with a 5x5 egg pic, a 6x6 hatchling and the two-tile shell sheet.
--------------------------------------------------------------------------

local EGG_COLORS = { { 240, 208, 88 }, { 184, 128, 0 } }
local MON_COLORS = { { 100, 100, 100 }, { 40, 40, 40 } }

local function newAnim()
  local data = {
    -- SENTRET's frontpic is 48px, the width the old centring rule got wrong.
    pokemon = { SENTRET = { spriteFront = "sentret.png" } },
    gen2MenuGfx = { eggHatch = {
      egg = "egg.png", shell = "shell.png", shellTiles = 2,
    } },
    gen2Palettes = { pokemon = {
      EGG = { normal = EGG_COLORS, shiny = EGG_COLORS },
      SENTRET = { normal = MON_COLORS, shiny = MON_COLORS },
    } },
  }
  local anim = EggHatchAnim.new({ data = data }, {
    mon = { species = "SENTRET", shiny = false },
    species = "SENTRET",
  })
  anim.picCache["egg.png"] = fakeImage(40, 40)
  anim.picCache["sentret.png"] = fakeImage(48, 48)
  anim.picCache["shell.png"] = fakeImage(8, 16)
  return anim
end

--------------------------------------------------------------------------
-- Sprite lifetimes
--------------------------------------------------------------------------

local anim = newAnim()

-- Hatch_InitShellFragments lays ten `shell_fragment` rows, and `.done` has
-- already run ClearSprites over the cracks by then.
local frames, spawned, cleared = 0, nil, nil
while not anim.done and frames < 5000 do
  anim:update(1 / 60)
  frames = frames + 1
  if not spawned and #anim.sprites == 10 and anim.showMon then
    spawned = frames
  end
  if spawned and not cleared and #anim.sprites == 0 then cleared = frames end
end

eq(frames, 482, "the whole sequence is 482 frames of DelayFrames operands")
check(spawned ~= nil, "the ten shell fragments go up at `.done`")
check(cleared ~= nil, "and every one of them leaves the screen again")
-- var1 starts at 0 and gains 8 a frame; the seventeenth frame is the first to
-- see $80 at the top of AnimSeq_RevealNewMon and take .finish_EggShell.
eq(cleared and (cleared - spawned), 17,
   "sixteen frames of flight, then DeinitializeSprite")
eq(#anim.sprites, 0, "and nothing is left drawing when the loop ends")

--------------------------------------------------------------------------
-- Screen positions
--------------------------------------------------------------------------

anim = newAnim()

-- The egg at hlcoord 7, 4 with PadFrontpic's `.five` offset of (1, 2) tiles.
local frame = render(anim)
check(frame.pic ~= nil, "the egg pic draws while the shell is up")
eq(frame.pic and frame.pic.x, 7 * 8 + 8, "the 5-wide egg's x")
eq(frame.pic and frame.pic.y, 4 * 8 + 16, "the 5-wide egg's y")

-- EggHatch_CrackShell's first surviving round: `ld e, 11 * TILE_WIDTH` and
-- `add 9 * TILE_WIDTH`, less the -8 / -16 OAM bias and the oamset's own -4.
anim:crackShell(2)
eq(#anim.sprites, 1, "round 2 is the first round to crack the shell")
frame = render(anim)
eq(#frame.sprites, 1, "and the crack draws")
eq(frame.sprites[1] and frame.sprites[1].x, 11 * 8 - 8 - 4, "the crack's x")
eq(frame.sprites[1] and frame.sprites[1].y, 9 * 8 - 16 - 4, "the crack's y")

-- A wobble half moves BOTH layers two pixels left, so the crack keeps its
-- place on the shell instead of sliding across it.
local still = frame
anim.shakeX = 2
local shaken = render(anim)
eq(shaken.pic.x - still.pic.x, -2, "hSCX = +2 slides the background left")
eq(shaken.sprites[1].x - still.sprites[1].x, -2,
   "and wGlobalAnimXOffset = -2 takes the crack with it")
eq(shaken.pic.y, still.pic.y, "the wobble is horizontal only")
anim.shakeX = 0

-- The hatchling at hlcoord 6, 3 with `.six`'s offset of (1, 1) tiles: a whole
-- blank column, then one blank tile above each pic column.
anim.showMon = true
frame = render(anim)
eq(frame.pic and frame.pic.x, 6 * 8 + 8, "the 6-wide hatchling's x")
eq(frame.pic and frame.pic.y, 3 * 8 + 8, "the 6-wide hatchling's y")

--------------------------------------------------------------------------
-- Palettes
--------------------------------------------------------------------------

anim = newAnim()
local colors = anim:picColors()
check(colors ~= nil, "the egg has a palette of its own, not flat GB greys")
eq(colors and colors[2] and colors[2][1], EGG_COLORS[1][1],
   "and it is the EGG row _CGB_Evolution loads for wPlayerHPPal = EGG")
anim.showMon = true
colors = anim:picColors()
eq(colors and colors[2] and colors[2][1], MON_COLORS[1][1],
   "the hatchling brings its own once the pic swaps")

-- A cache built before the extractor grew the EGG row still runs.
anim = newAnim()
anim.palettes.pokemon.EGG = nil
eq(anim:picColors(), nil, "an older cache simply draws in the raw shades")

S.finish()

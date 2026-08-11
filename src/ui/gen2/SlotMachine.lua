-- Gold's slot machine (engine/games/slot_machine.asm _SlotMachine), reached by
-- the `special SlotMachine` every Game Corner machine's tile script calls.
--
-- The machine is not a coin flip with a spinning picture over it.  Every spin
-- rolls a BIAS symbol out of a weighted table (Slots_InitBias), and each reel's
-- stop is then MANIPULATED toward that symbol -- or, when the spin is unbiased,
-- deliberately away from every symbol -- for up to four slots past where the
-- player's A press landed.  Reel 3 additionally has three near-miss theatres
-- (the slow advance, the Golem drops and the Chansey egg) that only ever run
-- when the first two reels already show matching SEVENs, which is what makes
-- the machine feel like it nearly paid 300 far more often than it can.
--
-- Everything that decides an outcome is a pure function here, taking a
-- `random(n) -> 0..n-1` the way src/battle/gen2 does, so a test can drive
-- thousands of seeded spins and assert the distribution.  The screen half is
-- the only part that touches love.
--
-- Layout is transcribed from the ASM's own coordinates, never laid out by eye:
--
--   .PrintCoinsAndPayout  hlcoord 5, 1 and hlcoord 11, 1, each PrintNum with
--                         PRINTNUM_LEADINGZEROS | 2 bytes, 4 digits
--   Slots_Lights*OnOff    hlcoord 3, 2 / 3, 4 / 3, 6 / 3, 8 / 3, 10, and
--                         Slots_TurnLightsOnOrOff writes the second tile of
--                         each light at +SCREEN_WIDTH/2+3 (column 16, same
--                         row) and the pair below it one row down
--   Slots_InitReelTiles   REEL_X_COORD 6, 10 and 14 * TILE_WIDTH -- so the
--                         three reels sit in tile columns 6-7, 10-11, 14-15
--   Slots_UpdateReelPositionAndOAM
--                         wCurReelYCoord starts at 10 * TILE_WIDTH and steps
--                         up two tiles per symbol.  OAM y is 16px above the
--                         screen, so the bottom symbol covers tile rows 8-9,
--                         the middle 6-7, the top 4-5, and a fourth symbol
--                         peeks in at rows 2-3
--   Slots_AskBet          menu_coords 14, 10, 19, 17 with STATICMENU_CURSOR and
--                         no STATICMENU_NO_TOP_SPACING, so GetMenuTextStartCoord
--                         puts " 3" at (16,12) with the cursor in column 15 and
--                         the three labels two rows apart
--   Slots_PayoutText      .Text_PrintPayout lays the matched symbol's four
--                         tiles at (2,13),(3,13),(2,14),(3,14) and the ▼ at
--                         (18,17)
--
-- The cart's own reel art (gfx/slots/slots_1..3.2bpp.lz plus
-- gfx/slots/slots.tilemap) is NOT in the cache: src/import/RomExtractorGen2.lua
-- writes no `slots` entry into menu_gfx.lua yet.  SlotMachine:sheet() reads one
-- the moment it appears and falls back to labelled cells until then, the same
-- way src/ui/gen2/PackGfx.lua degrades.

local Chrome = require("src.ui.gen2.Chrome")
local CoinCase = require("src.core.gen2.CoinCase")
local Sound = require("src.core.Sound")

local SlotMachine = {}
SlotMachine.__index = SlotMachine
SlotMachine.isOpaque = true

-- ------------------------------------------------------------------ symbols
--
-- The wSlotMatched constants are a `const_def 0, 4` block, so they step by four
-- and double as the index into every table that is `srl a`'d first (the payout
-- table, the payout strings).  Keeping the cart's values rather than 1..6 means
-- those halvings stay literal.
SlotMachine.SEVEN    = 0x00
SlotMachine.POKEBALL = 0x04
SlotMachine.CHERRY   = 0x08
SlotMachine.PIKACHU  = 0x0c
SlotMachine.SQUIRTLE = 0x10
SlotMachine.STARYU   = 0x14

-- SLOTS_NO_MATCH and SLOTS_NO_BIAS are both -1 ($ff in the byte).  They are
-- different things sharing a value, so they get different names here.
SlotMachine.NO_MATCH = -1
SlotMachine.NO_BIAS = -1

SlotMachine.NAMES = {
  [0x00] = "SEVEN", [0x04] = "POKEBALL", [0x08] = "CHERRY",
  [0x0c] = "PIKACHU", [0x10] = "SQUIRTLE", [0x14] = "STARYU",
}

-- What a symbol cell shows while the cart's own 2x2 reel tiles are unextracted.
SlotMachine.LABELS = {
  [0x00] = "7", [0x04] = "()", [0x08] = "CH",
  [0x0c] = "PI", [0x10] = "SQ", [0x14] = "ST",
}

-- Slots_GetPayout .PayoutTable, indexed by wSlotMatched srl'd once.  The payout
-- does NOT scale with the bet in Gen 2 -- the bet buys extra LINES, not a
-- multiplier, which is the single biggest difference from Red's slots.
SlotMachine.PAYOUTS = {
  [0x00] = 300, -- SLOTS_SEVEN
  [0x04] = 50,  -- SLOTS_POKEBALL
  [0x08] = 6,   -- SLOTS_CHERRY
  [0x0c] = 8,   -- SLOTS_PIKACHU
  [0x10] = 10,  -- SLOTS_SQUIRTLE
  [0x14] = 15,  -- SLOTS_STARYU
}

function SlotMachine.payout(matched)
  if not matched or matched == SlotMachine.NO_MATCH then return 0 end
  return SlotMachine.PAYOUTS[matched] or 0
end

-- ------------------------------------------------------------------- reels
--
-- Reel1Tilemap / Reel2Tilemap / Reel3Tilemap.  REEL_SIZE is 15; the first three
-- entries are repeated at the end so Slots_GetCurrentReelState can read three
-- consecutive bytes without wrapping, which is also why the `and $f` mask below
-- is harmless for a slot the reel can actually spin to.
SlotMachine.REEL_SIZE = 15

local SEVEN, POKEBALL = 0x00, 0x04
local CHERRY, PIKACHU, SQUIRTLE, STARYU = 0x08, 0x0c, 0x10, 0x14

SlotMachine.REELS = {
  -- Reel1Tilemap: three SEVENs' worth of structure -- SEVEN at 0 and 5, and a
  -- POKEBALL where the third SEVEN would be, at 10.
  { SEVEN, CHERRY, STARYU, PIKACHU, SQUIRTLE,
    SEVEN, CHERRY, STARYU, PIKACHU, SQUIRTLE,
    POKEBALL, CHERRY, STARYU, PIKACHU, SQUIRTLE,
    SEVEN, CHERRY, STARYU },
  -- Reel2Tilemap: one SEVEN, at 0, and POKEBALLs at 5 and 10.
  { SEVEN, PIKACHU, CHERRY, SQUIRTLE, STARYU,
    POKEBALL, PIKACHU, CHERRY, SQUIRTLE, STARYU,
    POKEBALL, PIKACHU, CHERRY, SQUIRTLE, STARYU,
    SEVEN, PIKACHU, CHERRY },
  -- Reel3Tilemap: one SEVEN at 0 and one POKEBALL at 10.
  { SEVEN, PIKACHU, CHERRY, SQUIRTLE, STARYU,
    PIKACHU, CHERRY, SQUIRTLE, STARYU, PIKACHU,
    POKEBALL, CHERRY, SQUIRTLE, STARYU, PIKACHU,
    SEVEN, PIKACHU, CHERRY },
}

-- Slots_GetCurrentReelState, byte for byte:
--
--   ld a, [REEL_POSITION] / and a / jr nz, .okay / ld a, $f
--   .okay: dec a / and $f
--
-- so slot 0 reads as if it were 15.  The mask is $f (16) while the strip is 15
-- long, which is only harmless because entries 16-18 repeat entries 1-3: a
-- position of 16 reads the same window a position of 1 does.  A SEARCH that
-- walks the position past 16 (Slots_GetNumberOfGolems does) reads a window that
-- is one slot off, and the cart depends on whatever falls out of that.
--
-- Returns bottom, middle, top -- index 0 is the BOTTOM row, which is what
-- .CheckBottomRow reading wReel1Stopped + 0 establishes.
function SlotMachine.window(strip, position)
  local a = position
  if a == 0 then a = 0x0f end
  a = (a - 1) % 16
  return strip[a + 1], strip[a + 2], strip[a + 3]
end

-- Slots_UpdateReelPositionAndOAM's tail: inc a / and $f / cp REEL_SIZE / xor a.
function SlotMachine.advance(position)
  local a = (position + 1) % 16
  if a == SlotMachine.REEL_SIZE then a = 0 end
  return a
end

-- ------------------------------------------------------------------- lines
--
-- Slots_CheckMatchedAllThreeReels' jumptable is indexed by `wSlotBet and 3`,
-- and .three FALLS THROUGH into .two, which falls through into .one.  ASM
-- fallthrough is not a branch: a bet of 3 runs all five checks on the same
-- frame, a bet of 2 runs three, a bet of 1 runs one.
--
-- Every check that hits calls .StoreResult, which OVERWRITES wSlotMatched, so
-- the LAST line checked is the one that pays.  In fallthrough order that is
-- upward diagonal, downward diagonal, bottom, top, middle -- meaning the middle
-- row wins any tie and only ONE line is ever paid.
--
-- Each row is { reel1 index, reel2 index, reel3 index }, 1 = bottom.
local UP_DIAG   = { 1, 2, 3 }
local DOWN_DIAG = { 3, 2, 1 }
local BOTTOM    = { 1, 1, 1 }
local TOP       = { 3, 3, 3 }
local MIDDLE    = { 2, 2, 2 }

SlotMachine.LINES = {
  [0] = {},
  [1] = { MIDDLE },
  [2] = { BOTTOM, TOP, MIDDLE },
  [3] = { UP_DIAG, DOWN_DIAG, BOTTOM, TOP, MIDDLE },
}

local function betLines(bet)
  return SlotMachine.LINES[(bet or 0) % 4] or {}
end

-- Slots_CheckMatchedAllThreeReels.  r1/r2/r3 are three-entry windows.
-- Returns the matched symbol, or NO_MATCH.
function SlotMachine.matchAll(bet, r1, r2, r3)
  local matched = SlotMachine.NO_MATCH
  for _, line in ipairs(betLines(bet)) do
    local a = r1[line[1]]
    if a == r3[line[3]] and a == r2[line[2]] then matched = a end
  end
  return matched
end

-- Slots_CheckMatchedFirstTwoReels.  Same jumptable, same fallthrough, but the
-- comparisons are DIFFERENT rows: with only two reels down there is no third
-- column to close a diagonal, so both diagonals and the middle row all test
-- reel 2's middle symbol.
--
--   .CheckBottomRow     r1 bottom vs r2 bottom
--   .CheckUpwardsDiag   r1 bottom vs r2 middle
--   .CheckMiddleRow     r1 middle vs r2 middle
--   .CheckDownwardsDiag r1 top    vs r2 middle
--   .CheckTopRow        r1 top    vs r2 top
--
-- Returns the building symbol (or NO_MATCH) and whether it is a SEVEN, which is
-- wFirstTwoReelsMatchingSevens -- the flag every reel-3 theatre gates on.
local TWO_LINES = {
  [0] = {},
  [1] = { { 2, 2 } },
  [2] = { { 1, 1 }, { 3, 3 }, { 2, 2 } },
  [3] = { { 1, 2 }, { 3, 2 }, { 1, 1 }, { 3, 3 }, { 2, 2 } },
}

function SlotMachine.matchFirstTwo(bet, r1, r2)
  local building = SlotMachine.NO_MATCH
  for _, line in ipairs(TWO_LINES[(bet or 0) % 4] or {}) do
    if r1[line[1]] == r2[line[2]] then building = r1[line[1]] end
  end
  return building, building == SlotMachine.SEVEN
end

-- ------------------------------------------------------------------- bias
--
-- Slots_InitBias.  `percent` is EQUS "* $ff / 100" (macros/data.asm) with
-- rgbasm's integer division, so "19 percent" is 48 and not 48.45 -- the tables
-- below are the bytes the assembler emits, not the percentages they read as.
--
-- The scan is `ld a, [hli] / cp c / jr nc, .done`: the first row whose
-- threshold is >= the random byte wins, so the thresholds are cumulative and
-- the last row is 100 percent = 255.
SlotMachine.BIAS_NORMAL = {
  { 1,   SEVEN },     --   1 percent - 1
  { 3,   POKEBALL },  --   1 percent + 1
  { 10,  STARYU },    --   4 percent
  { 20,  SQUIRTLE },  --   8 percent
  { 40,  PIKACHU },   --  16 percent
  { 48,  CHERRY },    --  19 percent
  { 255, SlotMachine.NO_BIAS },
}

-- The luckier table, picked when wScriptVar is non-zero on entry: the Game
-- Corner's scripts pass one machine per room in as the lucky one.
SlotMachine.BIAS_LUCKY = {
  { 2,   SEVEN },     --   1 percent
  { 3,   POKEBALL },  --   1 percent + 1
  { 8,   STARYU },    --   3 percent + 1
  { 16,  SQUIRTLE },  --   6 percent + 1
  { 30,  PIKACHU },   --  12 percent
  { 80,  CHERRY },    --  31 percent + 1
  { 255, SlotMachine.NO_BIAS },
}

-- `ld a, [wSlotBias] / and a / ret z` at the top of Slots_InitBias: a spin that
-- is ALREADY biased to SEVEN (value 0) keeps that bias without rerolling.  That
-- one instruction is the whole seven streak -- see keepSevenBias below for what
-- ends it.
function SlotMachine.initBias(currentBias, lucky, random)
  if currentBias == SlotMachine.SEVEN then return SlotMachine.SEVEN end
  local table_ = lucky and SlotMachine.BIAS_LUCKY or SlotMachine.BIAS_NORMAL
  local roll = random(256)
  for _, row in ipairs(table_) do
    if row[1] >= roll then return row[2] end
  end
  return SlotMachine.NO_BIAS
end

-- .InitGFX's tail rolls wKeepSevenBiasChance once for the whole session:
-- `call Random / and %00101010 / ret nz` leaves it FALSE 87.5% of the time.
-- Lua 5.1 has no bitwise operators, so a mask is spelled out as the bits it
-- names -- %00101010 is $2a, bits 1, 3 and 5.
local function maskIsZero(value, bits)
  for _, bit in ipairs(bits) do
    if math.floor(value / bit) % 2 == 1 then return false end
  end
  return true
end

function SlotMachine.rollKeepSevenChance(random)
  return maskIsZero(random(256), { 2, 8, 32 })
end

-- .LinedUpSevens, after the 300-coin fanfare.  A SEVEN payout usually DROPS the
-- seven bias; the chance it survives into the next spin is what makes a streak.
--
-- Oddly, the rarer session flag (wKeepSevenBiasChance = TRUE, 12.5% of visits)
-- is the one with the WORSE streak odds, 12.5% against 25% -- the ASM's own
-- comment flags this as probably-inverted, and it is transcribed as written.
function SlotMachine.keepSevenBias(keepSevenChance, random)
  -- keepSevenChance: and %0011100 ($1c, three bits) -> 1 in 8
  -- otherwise:       and %0010100 ($14, two bits)   -> 1 in 4
  local mask = keepSevenChance and { 4, 8, 16 } or { 4, 16 }
  return maskIsZero(random(256), mask)
end

-- ------------------------------------------------------------- reel stops
--
-- Each ReelAction_StopReel* runs once per SLOT (Slots_SpinReel only calls the
-- action jumptable when the spin distance's low nibble is zero), and either
-- stops the reel there or lets it turn one more slot and asks again.  Running
-- that decision to a fixed point up front gives exactly the slot the cart
-- reaches, so the screen spins toward a known stop instead of carrying the
-- whole ReelAction jumptable.
--
-- REEL_MANIP_COUNTER starts at 4 for every reel (SlotsAction_BetAndStart).
SlotMachine.MANIP_COUNTER = 4

-- The loop is bounded on the cart by the reel coming back around; the guard
-- here is a full strip plus the manipulation budget, and reaching it stops the
-- reel the way Slots_StopReel would.
local SEARCH_LIMIT = SlotMachine.REEL_SIZE * 4

-- ReelAction_StopReel1: with no bias, stop where the player pressed.  With a
-- bias, walk up to four slots looking for the biased symbol ANYWHERE in reel
-- one's three-symbol window -- even on a line the current bet does not buy.
function SlotMachine.stopReel1(position, bias)
  local strip = SlotMachine.REELS[1]
  local manip = SlotMachine.MANIP_COUNTER
  for _ = 1, SEARCH_LIMIT do
    if bias == SlotMachine.NO_BIAS or manip == 0 then return position end
    manip = manip - 1
    local a, b, c = SlotMachine.window(strip, position)
    if a == bias or b == bias or c == bias then return position end
    position = SlotMachine.advance(position)
  end
  return position
end

-- ReelAction_StopReel2: stop early once reels one and two are already building
-- the biased symbol on a line this bet buys, otherwise burn the four slots.
function SlotMachine.stopReel2(position, bias, bet, stopped1)
  local strip = SlotMachine.REELS[2]
  local manip = SlotMachine.MANIP_COUNTER
  for _ = 1, SEARCH_LIMIT do
    local window = { SlotMachine.window(strip, position) }
    local building = SlotMachine.matchFirstTwo(bet, stopped1, window)
    if building ~= SlotMachine.NO_MATCH and building == bias then
      return position
    end
    if bias == SlotMachine.NO_BIAS or manip == 0 then return position end
    manip = manip - 1
    position = SlotMachine.advance(position)
  end
  return position
end

-- ReelAction_StopReel3, and the one place the "no bias means no win" rule is
-- actually enforced:
--
--   * a line that matches the bias stops the reel dead
--   * a line that matches ANYTHING ELSE keeps the reel turning, manip counter
--     or not (`ret z` returns without stopping, it does not fall through)
--   * no line at all stops the reel, unless a bias is still being hunted and
--     the four-slot budget has not run out
function SlotMachine.stopReel3(position, bias, bet, stopped1, stopped2)
  local strip = SlotMachine.REELS[3]
  local manip = SlotMachine.MANIP_COUNTER
  for _ = 1, SEARCH_LIMIT do
    local window = { SlotMachine.window(strip, position) }
    local matched = SlotMachine.matchAll(bet, stopped1, stopped2, window)
    if matched ~= SlotMachine.NO_MATCH then
      if matched == bias then return position end
      if manip > 0 then manip = manip - 1 end
    else
      if bias == SlotMachine.NO_BIAS or manip == 0 then return position end
      manip = manip - 1
    end
    position = SlotMachine.advance(position)
  end
  return position
end

-- ---------------------------------------------------- reel 2's skip-to-seven
--
-- Slots_StopReel2's alternative: with a bet of 2 or more, a SEVEN visible
-- anywhere in reel one, and a spin that is either unbiased or biased to SEVEN,
-- there is a 31.25% chance (`cp 31 percent + 1 / jr nc` = 80/256) that reel two
-- ignores the player entirely, pauses, and then fast-spins until the two reels
-- line up SEVENs.
--
-- It is almost always a tease: lining up two SEVENs is what UNLOCKS the reel-3
-- theatres below, and those only pay when the bias was SEVEN to begin with.
function SlotMachine.reel2SkipsToSeven(bet, bias, stopped1, random)
  if (bet or 0) < 2 then return false end
  if bias ~= SlotMachine.SEVEN and bias ~= SlotMachine.NO_BIAS then
    return false
  end
  -- .CheckReel1ForASeven returns z only when one of the three is SLOTS_SEVEN,
  -- which is zero -- so the test really is "any zero in the window".
  if not (stopped1[1] == SlotMachine.SEVEN or stopped1[2] == SlotMachine.SEVEN
      or stopped1[3] == SlotMachine.SEVEN) then
    return false
  end
  return random(256) < 80
end

-- ReelAction_FastSpinReel2UntilLinedUp7s: keep turning until the two reels show
-- matching SEVENs on a line this bet buys.
function SlotMachine.spinReel2ToSevens(position, bet, stopped1)
  local strip = SlotMachine.REELS[2]
  for _ = 1, SEARCH_LIMIT do
    local window = { SlotMachine.window(strip, position) }
    local building, sevens = SlotMachine.matchFirstTwo(bet, stopped1, window)
    if building ~= SlotMachine.NO_MATCH and sevens then return position end
    position = SlotMachine.advance(position)
  end
  return position
end

-- ------------------------------------------------------- reel 3's theatre
--
-- Slots_StopReel3's action roll, which only happens when the first two reels
-- already show matching SEVENs.  The ASM's `.biased` label is misleading: it is
-- reached when the bias is NOT SEVEN (including no bias at all), and the
-- fallthrough above it is the bias-to-SEVEN case.  The ASM's own comment block
-- confirms which set of odds belongs to which.
SlotMachine.REEL3_STOP  = "stop"
SlotMachine.REEL3_SLOW  = "slowAdvance"
SlotMachine.REEL3_GOLEM = "golem"
SlotMachine.REEL3_EGG   = "chansey"

function SlotMachine.reel3Action(matchingSevens, bias, random)
  if not matchingSevens then return SlotMachine.REEL3_STOP end
  local r = random(256)
  if bias == SlotMachine.SEVEN then
    -- cp 71 percent - 1 (180) / cp 47 percent + 1 (120) / cp 24 percent - 1 (60)
    if r >= 180 then return SlotMachine.REEL3_STOP end        -- 29.7%
    if r >= 120 then return SlotMachine.REEL3_SLOW end        -- 23.4%
    if r >= 60 then return SlotMachine.REEL3_GOLEM end        -- 23.4%
    return SlotMachine.REEL3_EGG                              -- 23.4%
  end
  -- cp 63 percent (160) / cp 31 percent + 1 (80).  Chansey is unreachable here,
  -- which is why the egg is the rarest thing on the machine.
  if r >= 160 then return SlotMachine.REEL3_STOP end          -- 37.5%
  if r >= 80 then return SlotMachine.REEL3_SLOW end           -- 31.25%
  return SlotMachine.REEL3_GOLEM                              -- 31.25%
end

-- The predicate every theatre spins toward, from ReelAction_WaitSlowAdvanceReel3
-- .check1 / .check2: biased to SEVEN means "keep going until SEVENs line up",
-- anything else means "keep going until NOTHING lines up".
local function theatreSatisfied(bias, matched)
  if bias == SlotMachine.SEVEN then return matched == SlotMachine.SEVEN end
  return matched == SlotMachine.NO_MATCH
end

function SlotMachine.slowAdvance(position, bias, bet, stopped1, stopped2)
  local strip = SlotMachine.REELS[3]
  for _ = 1, SEARCH_LIMIT do
    local window = { SlotMachine.window(strip, position) }
    local matched = SlotMachine.matchAll(bet, stopped1, stopped2, window)
    if theatreSatisfied(bias, matched) then return position end
    position = SlotMachine.advance(position)
  end
  return position
end

-- Slots_GetNumberOfGolems.  Two different searches, and only one of them is
-- honest:
--
--   biased to SEVEN  the position is stepped ONE slot per Golem until SEVENs
--                    line up, and the count returned is exactly that many
--                    steps -- so the reel really does land where the search
--                    looked (1 to 14 Golems)
--   anything else    the search steps by a growing stride (a random 4..7, then
--                    5, 6, ...) while the returned count is the FINAL stride,
--                    and each Golem only advances the reel one slot.  The reel
--                    therefore lands somewhere the search never checked, and
--                    ReelAction_WaitGolem `.two` stops it there regardless.
--                    That mismatch is the cart's, not a shortcut here.
--
-- Returns the Golem count; the reel ends up `count` slots on from where it was.
function SlotMachine.golemCount(position, bias, bet, stopped1, stopped2, random)
  local strip = SlotMachine.REELS[3]
  if bias == SlotMachine.SEVEN then
    local walk, count = position, 0
    for _ = 1, SEARCH_LIMIT do
      walk = walk + 1
      count = count + 1
      local window = { SlotMachine.window(strip, walk) }
      local matched = SlotMachine.matchAll(bet, stopped1, stopped2, window)
      if matched == SlotMachine.SEVEN then return count end
    end
    return count
  end
  -- `call Random / and $7 / cp $8 / 2 / jr c` rerolls until the low three bits
  -- are 4..7.
  local stride = random(8)
  while stride < 4 do stride = random(8) end
  local walk = position
  for _ = 1, SEARCH_LIMIT do
    walk = walk + stride
    stride = stride + 1
    local window = { SlotMachine.window(strip, walk) }
    local matched = SlotMachine.matchAll(bet, stopped1, stopped2, window)
    if matched == SlotMachine.NO_MATCH then return stride end
  end
  return stride
end

-- ReelAction_DropReel: Chansey's egg drops the reel 17 slots at a time and
-- re-checks, over and over, until SEVENs are lined up.  17 slots is two slots
-- of net movement per egg on a 15-slot reel, which is why the egg keeps
-- falling for so long.
SlotMachine.EGG_DROP = 17

function SlotMachine.eggDrops(position, bet, stopped1, stopped2)
  local strip = SlotMachine.REELS[3]
  local drops = 0
  for _ = 1, SEARCH_LIMIT do
    for _ = 1, SlotMachine.EGG_DROP do
      position = SlotMachine.advance(position)
    end
    drops = drops + 1
    local window = { SlotMachine.window(strip, position) }
    local matched = SlotMachine.matchAll(bet, stopped1, stopped2, window)
    -- `.check_match: jr nc, .EggAgain / and a / jr nz, .EggAgain` -- it takes a
    -- match AND that match being SEVEN to settle.
    if matched == SlotMachine.SEVEN then return position, drops end
  end
  return position, drops
end

-- ------------------------------------------------------------- whole spin
--
-- One spin resolved end to end, for the tests and for anything that wants the
-- machine's numbers without its animation.  `stops` is where the player's three
-- A presses landed (0-based slot per reel, the way REEL_POSITION reads).
--
-- Returns { matched, payout, bias, positions, reel3Action }.
function SlotMachine.spin(opts)
  local random = opts.random
  local bet = opts.bet or 1
  local bias = SlotMachine.initBias(opts.bias or SlotMachine.NO_BIAS,
    opts.lucky, random)
  local stops = opts.stops or { 0, 0, 0 }

  local p1 = SlotMachine.stopReel1(stops[1], bias)
  local r1 = { SlotMachine.window(SlotMachine.REELS[1], p1) }

  local p2
  if SlotMachine.reel2SkipsToSeven(bet, bias, r1, random) then
    p2 = SlotMachine.spinReel2ToSevens(stops[2], bet, r1)
  else
    p2 = SlotMachine.stopReel2(stops[2], bias, bet, r1)
  end
  local r2 = { SlotMachine.window(SlotMachine.REELS[2], p2) }
  local _, matchingSevens = SlotMachine.matchFirstTwo(bet, r1, r2)

  local action = SlotMachine.reel3Action(matchingSevens, bias, random)
  local p3 = stops[3]
  if action == SlotMachine.REEL3_STOP then
    p3 = SlotMachine.stopReel3(p3, bias, bet, r1, r2)
  elseif action == SlotMachine.REEL3_SLOW then
    p3 = SlotMachine.slowAdvance(p3, bias, bet, r1, r2)
  elseif action == SlotMachine.REEL3_GOLEM then
    local count = SlotMachine.golemCount(p3, bias, bet, r1, r2, random)
    for _ = 1, count do p3 = SlotMachine.advance(p3) end
  else
    p3 = SlotMachine.eggDrops(p3, bet, r1, r2)
  end
  local r3 = { SlotMachine.window(SlotMachine.REELS[3], p3) }

  local matched = SlotMachine.matchAll(bet, r1, r2, r3)
  return {
    matched = matched,
    payout = SlotMachine.payout(matched),
    bias = bias,
    reel3Action = action,
    positions = { p1, p2, p3 },
    windows = { r1, r2, r3 },
  }
end

-- ------------------------------------------------------------------ layout
local COINS_X, COINS_Y = 5, 1
local PAYOUT_X, PAYOUT_Y = 11, 1
-- REEL_X_COORD / TILE_WIDTH.
local REEL_X = { 6, 10, 14 }
-- Slots_UpdateReelPositionAndOAM's y ladder, converted from OAM space (which
-- sits 16px above the screen) to tile rows: bottom, middle, top, and the
-- fourth symbol that only half shows.
local REEL_ROW = { 8, 6, 4, 2 }
-- Slots_Lights3OnOff / 2 / 1: the row each bet's pair of lights is drawn on,
-- and the two columns Slots_TurnLightsOnOrOff writes.
local LIGHT_ROWS = { [3] = { 2, 10 }, [2] = { 4, 8 }, [1] = { 6 } }
local LIGHT_COLS = { 3, 16 }
-- Slots_AskBet's MenuHeader through GetMenuTextStartCoord.
local BET_BOX_X, BET_BOX_Y, BET_BOX_W, BET_BOX_H = 14, 10, 6, 8
local BET_LABEL_X, BET_LABEL_Y, BET_SPACING = 16, 12, 2
-- .Text_PrintPayout's four ldcoord_a writes.
local PAYOUT_SYMBOL_X, PAYOUT_SYMBOL_Y = 2, 13
-- Textbox(0, TEXTBOX_Y) -- the standard speech box every PrintText here uses.
local TEXT_BOX_X, TEXT_BOX_Y, TEXT_BOX_W, TEXT_BOX_H = 0, 12, 20, 6
local TEXT_X, TEXT_Y, TEXT_LINE = 1, 14, 2

-- ------------------------------------------------------------------- text
--
-- data/text/common_2.asm and common_3.asm.  None of these are in the cache's
-- text.lua: no script bytecode points at them, so the extractor -- which walks
-- reachable script pointers -- never reaches them.
local TEXTS = {
  betHowMany = { "Bet how many", "coins?" },      -- _SlotsBetHowManyCoinsText
  start = { "Start!" },                            -- _SlotsStartText
  notEnough = { "Not enough", "coins." },          -- _SlotsNotEnoughCoinsText
  ranOut = { "Darn… Ran out of", "coins…" },       -- _SlotsRanOutOfCoinsText
  playAgain = { "Play again?" },                   -- _SlotsPlayAgainText
  darn = { "Darn!" },                              -- _SlotsDarnText
}
SlotMachine.TEXTS = TEXTS

-- _SlotsLinedUpText: "lined up!" / "Won @<wStringBuffer2> coins!", with the
-- matched symbol's 2x2 tiles printed to its left by .Text_PrintPayout.
local function linedUpLines(payout)
  return { "lined up!", ("Won %d coins!"):format(payout) }
end

-- Slots_PlaySFX's labels, spelled the pokegold way (Sound.GEN2_ALIASES is what
-- maps the shared UI's own names onto these, never the other way round).
local SFX_START = "Sfx_SlotMachineStart"
local SFX_STOP = "Sfx_StopSlot"
local SFX_PAY_DAY = "Sfx_PayDay"
local SFX_COIN = "Sfx_GetCoinFromSlots"
local SFX_QUIT = "Sfx_QuitSlots"
local SFX_SEVENS = "Sfx_2ndPlace"
local SFX_POKEBALLS = "Sfx_3rdPlace"
local SFX_SMALL_WIN = "Sfx_Present"

-- ------------------------------------------------------------------ screen
function SlotMachine:wantsFillScale() return true end
function SlotMachine:drawsWidescreen() return true end

-- opts: save, lucky (wScriptVar on entry), random(n), onClose()
function SlotMachine.new(game, opts)
  opts = opts or {}
  local self = setmetatable({}, SlotMachine)
  self.game = game
  self.save = opts.save or (game and game.save)
  self.lucky = opts.lucky or false
  self.onClose = opts.onClose
  self.random = opts.random or function(n)
    if love and love.math and love.math.random then
      return love.math.random(n) - 1
    end
    return math.random(n) - 1
  end
  -- .InitGFX's tail, rolled once for the whole visit to the machine.
  self.keepSevenChance = SlotMachine.rollKeepSevenChance(self.random)
  self.bias = SlotMachine.NO_BIAS
  self.payoutLeft = 0
  self.positions = { 0, 0, 0 }
  self.distance = { 0, 0, 0 }
  self.rate = { 0, 0, 0 }
  self.stops = { nil, nil, nil }
  self:playMusic()
  self:enterInit()
  return self
end

function SlotMachine:playMusic()
  local data = self.game and self.game.data
  if not data then return end
  require("src.core.Music").play(data, "Music_GameCorner")
end

function SlotMachine:sfx(name)
  local data = self.game and self.game.data
  if data then Sound.play(data, name) end
end

function SlotMachine:coins()
  return CoinCase.coins(self.save)
end

-- ---------------------------------------------------------------- phases
--
-- SlotsAction_Init: clear the match flags, then straight into the bet menu.
function SlotMachine:enterInit()
  self.matched = SlotMachine.NO_MATCH
  self.matchingSevens = false
  self.phase = "bet"
  self.betIndex = 1 -- `db 1 ; default option`, which is the " 3" row
  self.message = nil
end

-- Slots_AskBet: `ld a, 4 / sub b` turns the cursor row into the bet, so the
-- top row is three coins and the bottom is one.
local BET_ROWS = { " 3", " 2", " 1" }

function SlotMachine:updateBet(input)
  if self.message then
    if input:wasPressed("a") or input:wasPressed("b") then self.message = nil end
    return
  end
  if input:wasPressed("up") then
    self.betIndex = self.betIndex > 1 and self.betIndex - 1 or #BET_ROWS
    return
  elseif input:wasPressed("down") then
    self.betIndex = self.betIndex < #BET_ROWS and self.betIndex + 1 or 1
    return
  elseif input:wasPressed("b") then
    -- VerticalMenu returning carry is what SlotsAction_BetAndStart reads as
    -- SLOTS_QUIT.
    self:quit()
    return
  elseif input:wasPressed("a") then
    local bet = 4 - self.betIndex
    if self:coins() < bet then
      self.message = TEXTS.notEnough
      return
    end
    self.bet = bet
    CoinCase.takeCoins(self.save, bet)
    self:sfx(SFX_PAY_DAY)
    self:startSpin()
  end
end

-- SlotsAction_BetAndStart's tail: the bias for THIS spin, all three reels at
-- REEL_ACTION_NORMAL_RATE, and 32 frames of wSlotsDelay before A does anything.
function SlotMachine:startSpin()
  self.bias = SlotMachine.initBias(self.bias, self.lucky, self.random)
  self.phase = "spinning"
  self.reel = 1
  self.delay = 32
  self.message = TEXTS.start
  for i = 1, 3 do
    self.rate[i] = 4 -- ReelAction_NormalRate
    self.stops[i] = nil
  end
  self:sfx(SFX_START)
end

-- Slots_SpinReel, per reel per frame: the action jumptable runs only on a slot
-- boundary, and the position advances when the distance's low nibble wraps.
function SlotMachine:spinReels()
  for i = 1, 3 do
    local rate = self.rate[i]
    if rate > 0 then
      self.distance[i] = (self.distance[i] + rate) % 256
      if self.distance[i] % 16 == 0 then
        self.positions[i] = SlotMachine.advance(self.positions[i])
        -- A reel with a resting slot chosen stops the moment it reaches it.
        if self.stops[i] and self.positions[i] == self.stops[i] then
          self.rate[i] = 0
          self.stopped = self.stopped or {}
          self.stopped[i] = { SlotMachine.window(SlotMachine.REELS[i],
            self.positions[i]) }
          self:sfx(SFX_STOP)
          self:reelStopped(i)
        end
      end
    end
  end
end

-- The three symbols reel `i` is currently showing.  Named apart from
-- SlotMachine.window so the instance method cannot shadow the pure one.
function SlotMachine:reelWindow(i)
  return { SlotMachine.window(SlotMachine.REELS[i], self.positions[i]) }
end

-- SlotsAction_WaitReel1 / 2 / 3: A picks the slot, and the reel then turns to
-- wherever the manipulation put it.
function SlotMachine:pressStop()
  local i = self.reel
  if self.stops[i] then return end
  local here = self.positions[i]
  if i == 1 then
    self.stops[1] = SlotMachine.stopReel1(here, self.bias)
  elseif i == 2 then
    local r1 = self.stopped[1]
    if SlotMachine.reel2SkipsToSeven(self.bet, self.bias, r1, self.random) then
      -- ReelAction_SetUpReel2SkipTo7 pauses the reel for 32 frames and then
      -- fast-spins it at double rate; the pause is the tell.
      self.stops[2] = SlotMachine.spinReel2ToSevens(here, self.bet, r1)
      self.rate[2] = 8
    else
      self.stops[2] = SlotMachine.stopReel2(here, self.bias, self.bet, r1)
    end
  else
    local r1, r2 = self.stopped[1], self.stopped[2]
    local _, sevens = SlotMachine.matchFirstTwo(self.bet, r1, r2)
    self.matchingSevens = sevens
    local action = SlotMachine.reel3Action(sevens, self.bias, self.random)
    self.reel3Action = action
    if action == SlotMachine.REEL3_STOP then
      self.stops[3] = SlotMachine.stopReel3(here, self.bias, self.bet, r1, r2)
    elseif action == SlotMachine.REEL3_SLOW then
      self.stops[3] = SlotMachine.slowAdvance(here, self.bias, self.bet, r1, r2)
      self.rate[3] = 1 -- ReelAction_QuarterRate
    elseif action == SlotMachine.REEL3_GOLEM then
      local count = SlotMachine.golemCount(here, self.bias, self.bet, r1, r2,
        self.random)
      local target = here
      for _ = 1, count do target = SlotMachine.advance(target) end
      self.stops[3] = target
      self.golems = count
      self.rate[3] = 8
    else
      local target = SlotMachine.eggDrops(here, self.bet, r1, r2)
      self.stops[3] = target
      self.rate[3] = 16 -- ReelAction_QuadrupleRate, the egg drop
    end
  end
  -- A reel already sitting on its resting slot has nowhere to turn.
  if self.stops[i] == self.positions[i] then
    self.rate[i] = 0
    self.stopped = self.stopped or {}
    self.stopped[i] = self:reelWindow(i)
    self:sfx(SFX_STOP)
    self:reelStopped(i)
  end
end

function SlotMachine:reelStopped(i)
  if i < 3 then
    self.reel = i + 1
    return
  end
  -- SlotsAction_FlashIfWin: a win flashes the object palette for 16 frames
  -- before the payout is counted out; a loss skips straight past it.
  local r1, r2, r3 = self.stopped[1], self.stopped[2], self.stopped[3]
  self.matched = SlotMachine.matchAll(self.bet, r1, r2, r3)
  if self.matched == SlotMachine.NO_MATCH then
    self.phase = "payoutText"
    self.message = TEXTS.darn
    return
  end
  self.phase = "flash"
  self.flash = 16
end

-- SlotsAction_GiveEarnedCoins / SlotsAction_PayoutTextAndAnim: the payout
-- counter is filled from the table, the fanfare plays, and then the coins tick
-- across one per two frames.
function SlotMachine:beginPayout()
  self.payoutLeft = SlotMachine.payout(self.matched)
  self.payoutTick = 0
  self.phase = "payoutText"
  self.message = linedUpLines(self.payoutLeft)
  if self.matched == SlotMachine.SEVEN then
    self:sfx(SFX_SEVENS)
    -- .LinedUpSevens decides here whether the seven streak survives.
    if not SlotMachine.keepSevenBias(self.keepSevenChance, self.random) then
      self.bias = SlotMachine.NO_BIAS
    end
  elseif self.matched == SlotMachine.POKEBALL then
    self:sfx(SFX_POKEBALLS)
  else
    self:sfx(SFX_SMALL_WIN)
  end
end

-- SlotsAction_PayoutAnim: `ld a, [hl] / inc [hl] / and $1` -- one coin every
-- other frame, and the coin case clamp is checked BEFORE the increment, so a
-- full case eats the rest of the payout.
function SlotMachine:updatePayoutAnim()
  self.payoutTick = (self.payoutTick or 0) + 1
  if self.payoutTick % 2 == 1 then return end
  if self.payoutLeft <= 0 then
    self.phase = "again"
    return
  end
  self.payoutLeft = self.payoutLeft - 1
  CoinCase.giveCoins(self.save, 1)
  if self.payoutTick % 8 == 0 then self:sfx(SFX_COIN) end
end

-- Slots_AskPlayAgain: no coins left is not a question, it is the exit.
function SlotMachine:enterAgain()
  if self:coins() <= 0 then
    self.phase = "ranOut"
    self.message = TEXTS.ranOut
    self.ranOutDelay = 60 -- `ld c, 60 / call DelayFrames`
    return
  end
  self.phase = "again"
  self.againChoice = 1
  self.message = TEXTS.playAgain
end

function SlotMachine:quit()
  self.phase = "quit"
  self:sfx(SFX_QUIT)
  local data = self.game and self.game.data
  if data then require("src.core.Music").restoreMap(data) end
  if self.onClose then self.onClose() end
end

function SlotMachine:update(_dt)
  local input = self.game and self.game.input
  if not input then return end
  local phase = self.phase

  if phase == "bet" then
    self:updateBet(input)
    return
  end

  if phase == "spinning" then
    -- SlotsAction_WaitStart clears hJoypadSum first, so a press held from the
    -- bet menu cannot stop reel one.
    if self.delay > 0 then
      self.delay = self.delay - 1
      self:spinReels()
      return
    end
    self.message = nil
    if input:wasPressed("a") then self:pressStop() end
    self:spinReels()
    return
  end

  if phase == "flash" then
    self.flash = self.flash - 1
    if self.flash <= 0 then self:beginPayout() end
    return
  end

  if phase == "payoutText" then
    if self.matched == SlotMachine.NO_MATCH then
      if input:wasPressed("a") or input:wasPressed("b") then
        self:enterAgain()
      end
      return
    end
    self:updatePayoutAnim()
    if self.phase == "again" then self:enterAgain() end
    return
  end

  if phase == "again" then
    if input:wasPressed("up") or input:wasPressed("down") then
      self.againChoice = self.againChoice == 1 and 2 or 1
      return
    end
    if input:wasPressed("b") then
      self:quit()
      return
    end
    if input:wasPressed("a") then
      if self.againChoice == 1 then self:enterInit() else self:quit() end
    end
    return
  end

  if phase == "ranOut" then
    self.ranOutDelay = self.ranOutDelay - 1
    if self.ranOutDelay <= 0 then self:quit() end
    return
  end
end

-- ------------------------------------------------------------------- draw
--
-- The cart's reel art is unextracted (see the header), so a symbol draws as its
-- two-letter label inside a 2x2 cell.  A `slots` entry in menu_gfx.lua switches
-- this to the real tiles without any other change.
function SlotMachine:sheet()
  if self.sheetCache == nil then
    local data = self.game and self.game.data
    local gfx = data and data.gen2MenuGfx and data.gen2MenuGfx.slots
    if gfx and gfx.image then
      local TileSheet = require("src.ui.gen2.TileSheet")
      self.sheetCache = TileSheet.new({ path = gfx.image, wide = gfx.wide or 16,
        firstTile = gfx.firstTile or 0 })
    else
      self.sheetCache = false
    end
  end
  return self.sheetCache or nil
end

local function cell(tx, ty, label)
  local G = love.graphics
  G.setColor(0, 0, 0, 1)
  G.rectangle("line", tx * 8, ty * 8, 16, 16)
  Chrome.print(label, tx, ty + 1)
end

function SlotMachine:drawReels()
  for i = 1, 3 do
    local strip = SlotMachine.REELS[i]
    local position = self.positions[i]
    -- .LoadOAM reads FOUR consecutive strip entries from REEL_POSITION and lays
    -- them bottom upward, which is what the three repeated entries at the end
    -- of each strip are for: position 14 reads indices 14, 15, 16 and 17
    -- without wrapping.  Only the lower three are on a pay line; the fourth
    -- half-shows at the top of the window.
    for row = 1, 4 do
      local symbol = strip[position + row]
      cell(REEL_X[i], REEL_ROW[row], SlotMachine.LABELS[symbol] or "?")
    end
  end
end

function SlotMachine:drawLights()
  local lit = {}
  -- Slots_IlluminateBetLights lights the rows for THIS bet and every smaller
  -- one: `dec a / jr z` falls through from three to two to one.
  for bet = 1, (self.bet or 0) do
    for _, row in ipairs(LIGHT_ROWS[bet] or {}) do lit[row] = true end
  end
  for _, row in ipairs({ 2, 4, 6, 8, 10 }) do
    for _, col in ipairs(LIGHT_COLS) do
      Chrome.print(lit[row] and "*" or "-", col, row)
    end
  end
end

function SlotMachine:drawMessage()
  if not self.message then return end
  Chrome.textbox(TEXT_BOX_X, TEXT_BOX_Y, TEXT_BOX_W - 2, TEXT_BOX_H - 2)
  for i, line in ipairs(self.message) do
    Chrome.print(line, TEXT_X, TEXT_Y + (i - 1) * TEXT_LINE)
  end
  if self.matched and self.matched ~= SlotMachine.NO_MATCH
      and self.phase == "payoutText" then
    cell(PAYOUT_SYMBOL_X, PAYOUT_SYMBOL_Y,
      SlotMachine.LABELS[self.matched] or "?")
  end
end

function SlotMachine:drawPanel()
  Chrome.clear()
  self:drawLights()
  -- PRINTNUM_LEADINGZEROS | 2 bytes, 4 digits, for both counters.
  Chrome.print(Chrome.number(self:coins(), 4, true), COINS_X, COINS_Y)
  Chrome.print(Chrome.number(self.payoutLeft or 0, 4, true), PAYOUT_X, PAYOUT_Y)
  self:drawReels()
  if self.phase == "bet" then
    Chrome.textbox(BET_BOX_X, BET_BOX_Y, BET_BOX_W - 2, BET_BOX_H - 2)
    for i, label in ipairs(BET_ROWS) do
      local ty = BET_LABEL_Y + (i - 1) * BET_SPACING
      if i == self.betIndex then Chrome.cursor(BET_LABEL_X - 1, ty) end
      Chrome.print(label, BET_LABEL_X, ty)
    end
    if not self.message then
      Chrome.textbox(TEXT_BOX_X, TEXT_BOX_Y, TEXT_BOX_W - 2, TEXT_BOX_H - 2)
      for i, line in ipairs(TEXTS.betHowMany) do
        Chrome.print(line, TEXT_X, TEXT_Y + (i - 1) * TEXT_LINE)
      end
    end
  end
  self:drawMessage()
  if self.phase == "again" then
    -- PlaceYesNoBox `lb bc, 14, 12`: a 6x5 box at (14,12) with YES at (16,13).
    Chrome.textbox(14, 12, 4, 3)
    Chrome.print("YES", 16, 13)
    Chrome.print("NO", 16, 15)
    Chrome.cursor(15, 13 + (self.againChoice - 1) * 2)
  end
end

function SlotMachine:draw()
  self:drawPanel()
end

function SlotMachine:drawWidescreen(winW, winH)
  local G = love.graphics
  G.setColor(1, 1, 1, 1)
  G.rectangle("fill", 0, 0, winW, winH)
  local scale = Chrome.fitScale(winW, winH)
  G.push()
  G.translate(math.floor((winW - 160 * scale) / 2),
    math.floor((winH - 144 * scale) / 2))
  G.scale(scale, scale)
  self:drawPanel()
  G.pop()
end

return SlotMachine

-- Gen 2 evolution: the EvosAttacks condition walk, the party record an
-- evolution produces, and the frame counts of the animation that plays over it.
--   GOLD_CACHE="$HOME/Library/Application Support/LOVE/gold-dev/gold" \
--     luajit tests/gen2_evolution_test.lua
--
-- The fixtures below are the shapes data/generated/pokemon.lua writes, with
-- numbers traceable to pokegold so a failure names the ASM it disagrees with.
-- The last block re-runs the same questions against a real Gold cache when one
-- is present, and skips when it is not.
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 evolution")
local check, eq = S.check, S.eq

love = require("tests.love_stub")

local Evolution = require("src.core.gen2.Evolution")
local Mon = require("src.battle.gen2.Mon")

-- ---- fixtures -------------------------------------------------------------

-- GROWTH_MEDIUM_FAST is plain n^3 (data/growth_rates.asm), which keeps the
-- experience arithmetic below readable.
local GROWTH = {
  MEDIUM_FAST = { numerator = 1, denominator = 1, squared = 0, linear = 0,
    constant = 0 },
}

local function base(hp, attack, defense, speed, spa, spd)
  return { hp = hp, attack = attack, defense = defense, speed = speed,
    specialAttack = spa, specialDefense = spd }
end

local POKEMON = {
  growthRates = GROWTH,
  -- data/pokemon/evos_attacks.asm ChikoritaEvosAttacks / BayleefEvosAttacks.
  CHIKORITA = {
    name = "CHIKORITA", index = 152, growthRate = "MEDIUM_FAST",
    genderRatio = 0x1f, types = { "GRASS" },
    baseStats = base(45, 49, 65, 45, 49, 65),
    evolutions = { { method = "EVOLVE_LEVEL", level = 16, into = "BAYLEEF" } },
    levelMoves = {
      { level = 1, move = "TACKLE" }, { level = 8, move = "GROWL" },
      { level = 12, move = "RAZOR_LEAF" },
    },
  },
  BAYLEEF = {
    name = "BAYLEEF", index = 153, growthRate = "MEDIUM_FAST",
    genderRatio = 0x1f, types = { "GRASS" },
    baseStats = base(60, 62, 80, 60, 63, 80),
    evolutions = { { method = "EVOLVE_LEVEL", level = 32, into = "MEGANIUM" } },
    levelMoves = {
      { level = 1, move = "TACKLE" }, { level = 8, move = "GROWL" },
      -- Two rows at the level the evolution happens at: one already known, one
      -- not, so LearnLevelMoves' duplicate skip is exercised.
      { level = 16, move = "REFLECT" }, { level = 16, move = "GROWL" },
      { level = 23, move = "POISONPOWDER" },
    },
  },
  MEGANIUM = {
    name = "MEGANIUM", index = 154, growthRate = "MEDIUM_FAST",
    genderRatio = 0x1f, types = { "GRASS" },
    baseStats = base(80, 82, 100, 80, 83, 100), evolutions = {},
    levelMoves = { { level = 1, move = "TACKLE" } },
  },
  -- EeveeEvosAttacks: three stones and two happiness rows, in ROM order.
  EEVEE = {
    name = "EEVEE", index = 133, growthRate = "MEDIUM_FAST",
    genderRatio = 0x1f, types = { "NORMAL" },
    baseStats = base(55, 55, 50, 55, 45, 65),
    evolutions = {
      { method = "EVOLVE_ITEM", item = "THUNDERSTONE", into = "JOLTEON" },
      { method = "EVOLVE_ITEM", item = "WATER_STONE", into = "VAPOREON" },
      { method = "EVOLVE_ITEM", item = "FIRE_STONE", into = "FLAREON" },
      { method = "EVOLVE_HAPPINESS", time = "MORNDAY", into = "ESPEON" },
      { method = "EVOLVE_HAPPINESS", time = "NITE", into = "UMBREON" },
    },
    levelMoves = { { level = 1, move = "TACKLE" } },
  },
  JOLTEON = {
    name = "JOLTEON", index = 135, growthRate = "MEDIUM_FAST",
    genderRatio = 0x1f, types = { "ELECTRIC" },
    baseStats = base(65, 65, 60, 130, 110, 95), evolutions = {},
    levelMoves = { { level = 1, move = "TACKLE" } },
  },
  ESPEON = {
    name = "ESPEON", index = 196, growthRate = "MEDIUM_FAST",
    genderRatio = 0x1f, types = { "PSYCHIC" },
    baseStats = base(65, 65, 60, 110, 130, 95), evolutions = {},
    levelMoves = { { level = 1, move = "TACKLE" } },
  },
  UMBREON = {
    name = "UMBREON", index = 197, growthRate = "MEDIUM_FAST",
    genderRatio = 0x1f, types = { "DARK" },
    baseStats = base(95, 65, 110, 65, 60, 130), evolutions = {},
    levelMoves = { { level = 1, move = "TACKLE" } },
  },
  -- GolbatEvosAttacks: TR_ANYTIME, i.e. no `time` field at all.
  GOLBAT = {
    name = "GOLBAT", index = 42, growthRate = "MEDIUM_FAST",
    genderRatio = 0x7f, types = { "POISON", "FLYING" },
    baseStats = base(75, 80, 70, 90, 65, 75),
    evolutions = { { method = "EVOLVE_HAPPINESS", into = "CROBAT" } },
    levelMoves = { { level = 1, move = "SCREECH" } },
  },
  CROBAT = {
    name = "CROBAT", index = 169, growthRate = "MEDIUM_FAST",
    genderRatio = 0x7f, types = { "POISON", "FLYING" },
    baseStats = base(85, 90, 80, 130, 70, 80), evolutions = {},
    levelMoves = { { level = 1, move = "SCREECH" } },
  },
  -- PoliwhirlEvosAttacks: a stone row and a held-item TRADE row, in that ROM
  -- order, which is the only thing that decides which of the two wins.
  POLIWHIRL = {
    name = "POLIWHIRL", index = 61, growthRate = "MEDIUM_FAST",
    genderRatio = 0x7f, types = { "WATER" },
    baseStats = base(65, 65, 65, 90, 50, 50),
    evolutions = {
      { method = "EVOLVE_ITEM", item = "WATER_STONE", into = "POLIWRATH" },
      { method = "EVOLVE_TRADE", item = "KINGS_ROCK", into = "POLITOED" },
    },
    levelMoves = { { level = 1, move = "BUBBLE" } },
  },
  POLIWRATH = {
    name = "POLIWRATH", index = 62, growthRate = "MEDIUM_FAST",
    genderRatio = 0x7f, types = { "WATER", "FIGHTING" },
    baseStats = base(90, 85, 95, 70, 70, 90), evolutions = {},
    levelMoves = { { level = 1, move = "BUBBLE" } },
  },
  POLITOED = {
    name = "POLITOED", index = 186, growthRate = "MEDIUM_FAST",
    genderRatio = 0x7f, types = { "WATER" },
    baseStats = base(90, 75, 75, 70, 90, 100), evolutions = {},
    levelMoves = { { level = 1, move = "BUBBLE" } },
  },
  -- GravelerEvosAttacks: EVOLVE_TRADE with no item ($ff).
  GRAVELER = {
    name = "GRAVELER", index = 75, growthRate = "MEDIUM_FAST",
    genderRatio = 0x1f, types = { "ROCK", "GROUND" },
    baseStats = base(55, 95, 115, 35, 45, 45),
    evolutions = { { method = "EVOLVE_TRADE", into = "GOLEM" } },
    levelMoves = { { level = 1, move = "TACKLE" } },
  },
  GOLEM = {
    name = "GOLEM", index = 76, growthRate = "MEDIUM_FAST",
    genderRatio = 0x1f, types = { "ROCK", "GROUND" },
    baseStats = base(80, 110, 130, 45, 55, 65), evolutions = {},
    levelMoves = { { level = 1, move = "TACKLE" } },
  },
  -- TyrogueEvosAttacks: three EVOLVE_STAT rows at level 20.
  TYROGUE = {
    name = "TYROGUE", index = 236, growthRate = "MEDIUM_FAST",
    genderRatio = 0x00, types = { "FIGHTING" },
    baseStats = base(35, 35, 35, 35, 35, 35),
    evolutions = {
      { method = "EVOLVE_STAT", level = 20, comparison = "ATK_LT_DEF",
        into = "HITMONCHAN" },
      { method = "EVOLVE_STAT", level = 20, comparison = "ATK_GT_DEF",
        into = "HITMONLEE" },
      { method = "EVOLVE_STAT", level = 20, comparison = "ATK_EQ_DEF",
        into = "HITMONTOP" },
    },
    levelMoves = { { level = 1, move = "TACKLE" } },
  },
  HITMONCHAN = {
    name = "HITMONCHAN", index = 107, growthRate = "MEDIUM_FAST",
    genderRatio = 0x00, types = { "FIGHTING" },
    baseStats = base(50, 105, 79, 76, 35, 110), evolutions = {},
    levelMoves = { { level = 1, move = "TACKLE" } },
  },
  HITMONLEE = {
    name = "HITMONLEE", index = 106, growthRate = "MEDIUM_FAST",
    genderRatio = 0x00, types = { "FIGHTING" },
    baseStats = base(50, 120, 53, 87, 35, 110), evolutions = {},
    levelMoves = { { level = 1, move = "TACKLE" } },
  },
  HITMONTOP = {
    name = "HITMONTOP", index = 237, growthRate = "MEDIUM_FAST",
    genderRatio = 0x00, types = { "FIGHTING" },
    baseStats = base(50, 95, 95, 70, 35, 110), evolutions = {},
    levelMoves = { { level = 1, move = "TACKLE" } },
  },
  -- A species that never evolves, so the sweep has something to skip.
  TAUROS = {
    name = "TAUROS", index = 128, growthRate = "MEDIUM_FAST",
    genderRatio = 0x00, types = { "NORMAL" },
    baseStats = base(75, 100, 95, 110, 40, 70), evolutions = {},
    levelMoves = { { level = 1, move = "TACKLE" } },
  },
}

local MOVES = {
  TACKLE = { name = "TACKLE", pp = 35 },
  GROWL = { name = "GROWL", pp = 40 },
  RAZOR_LEAF = { name = "RAZOR LEAF", pp = 25 },
  REFLECT = { name = "REFLECT", pp = 20 },
  POISONPOWDER = { name = "POISONPOWDER", pp = 35 },
  SCREECH = { name = "SCREECH", pp = 40 },
  BUBBLE = { name = "BUBBLE", pp = 30 },
}

local DATA = { pokemon = POKEMON, moves = MOVES }

-- Fixed DVs so every stat below is reproducible.
local DVS = { attack = 9, defense = 8, speed = 8, special = 8 }

local function newMon(species, level, opts)
  opts = opts or {}
  opts.dvs = { attack = DVS.attack, defense = DVS.defense,
    speed = DVS.speed, special = DVS.special }
  return Mon.new(DATA, species, level, opts)
end

local function row(species, index)
  return POKEMON[species].evolutions[index or 1]
end

-- ---- the animation schedule ----------------------------------------------
-- engine/movie/evolution_animation.asm `lb bc, 1, 16` then `inc b / dec c /
-- dec c` per round.
local rounds = Evolution.flashRounds()
eq(#rounds, 8, "the flash loop runs eight rounds")
eq(rounds[1].wait, 16, "round 1 holds the old pic 16 frames")
eq(rounds[1].flashes, 1, "and flashes once")
eq(rounds[2].wait, 14, "round 2 holds 14")
eq(rounds[2].flashes, 2, "and flashes twice")
eq(rounds[8].wait, 2, "the last round holds only 2")
eq(rounds[8].flashes, 8, "and flashes eight times")
-- 16+14+...+2 = 72 frames of holding, (1+...+8) * 2 swaps = 72 frames of
-- flashing.
eq(Evolution.flashFrames(), 144, "the flashing half is 144 frames end to end")
eq(Evolution.EVOLVING_FRAMES, 50, "EvolvingText holds for 50 frames")
eq(Evolution.MUSIC_FRAMES, 80, "MUSIC_EVOLUTION plays 80 frames before the flash")
eq(Evolution.CONGRATS_FRAMES, 40, "the evolved-into page holds 40 frames")
eq(Evolution.BALL_SPAWN_FRAMES + Evolution.BALL_TAIL_FRAMES, 64,
  ".PlayEvolvedSFX is 32 spawn frames plus 32 more")
-- depixel 9, 11 takes the Y tile FIRST, and an OAM object draws at
-- (x - 8, y - 16).
eq(Evolution.BALL_ORIGIN_X, 80, "the balls of light come out of x = 80")
eq(Evolution.BALL_ORIGIN_Y, 56, "and y = 56")
eq(Evolution.HAPPINESS_TO_EVOLVE, 220, "HAPPINESS_TO_EVOLVE EQU 220")

-- ---- EVOLVE_LEVEL ---------------------------------------------------------
local chikorita = newMon("CHIKORITA", 15)
check(not Evolution.checkMon(DATA, chikorita, {}),
  "a level 15 CHIKORITA is one level short")
chikorita = newMon("CHIKORITA", 16)
local entry = Evolution.checkMon(DATA, chikorita, {})
check(entry ~= nil, "at 16 it evolves")
eq(entry and entry.into, "BAYLEEF", "into BAYLEEF")
-- `cp b / jp c, .dont_evolve_3` is >=, not ==, so an overlevelled mon still
-- evolves the first time the sweep looks at it.
check(Evolution.checkMon(DATA, newMon("CHIKORITA", 40), {}) ~= nil,
  "a level 40 CHIKORITA still evolves")

-- IsMonHoldingEverstone, checked on the LEVEL path.
local everstoned = newMon("CHIKORITA", 20, { item = Evolution.EVERSTONE })
check(not Evolution.checkMon(DATA, everstoned, {}),
  "an EVERSTONE stops a level evolution")
local ok, reason = Evolution.rowMatches(row("CHIKORITA"), everstoned, {})
eq(reason, "everstone", "and says why")
check(not ok, "rowMatches agrees")

-- wForceEvolution: a stone was just used, so nothing but the ITEM path fires.
check(not Evolution.checkMon(DATA, newMon("CHIKORITA", 20), { force = true }),
  "a forced (stone) evolution does not trip the level row")
-- wLinkMode: nothing but the TRADE path fires while a link is up.
_, reason = Evolution.rowMatches(row("CHIKORITA"), newMon("CHIKORITA", 20),
  { link = true })
eq(reason, "linked", "and a link blocks it too")

-- ---- EVOLVE_ITEM ----------------------------------------------------------
local eevee = newMon("EEVEE", 25)
check(not Evolution.checkMon(DATA, eevee, { item = "THUNDERSTONE" }),
  "a stone in the bag does nothing without wForceEvolution")
entry = Evolution.checkMon(DATA, eevee, { item = "THUNDERSTONE", force = true })
eq(entry and entry.into, "JOLTEON", "using a THUNDERSTONE picks JOLTEON")
entry = Evolution.checkMon(DATA, eevee, { item = "WATER_STONE", force = true })
eq(entry and entry.into, "VAPOREON", "a WATER STONE picks VAPOREON")
check(not Evolution.checkMon(DATA, eevee, { item = "LEAF_STONE", force = true }),
  "a stone EEVEE has no row for does nothing")
-- .item never calls IsMonHoldingEverstone, which is why the stone still works.
local stoneHolder = newMon("EEVEE", 25, { item = Evolution.EVERSTONE })
check(Evolution.checkMon(DATA, stoneHolder,
  { item = "FIRE_STONE", force = true }) ~= nil,
  "an EVERSTONE does NOT block a stone evolution in Gen 2")

-- ---- EVOLVE_HAPPINESS -----------------------------------------------------
local golbat = newMon("GOLBAT", 30, { happiness = 219 })
check(not Evolution.checkMon(DATA, golbat, { timeOfDay = "DAY" }),
  "happiness 219 is one short of HAPPINESS_TO_EVOLVE")
golbat = newMon("GOLBAT", 30, { happiness = 220 })
check(Evolution.checkMon(DATA, golbat, { timeOfDay = "DAY" }) ~= nil,
  "at 220 GOLBAT evolves in the day")
check(Evolution.checkMon(DATA, golbat, { timeOfDay = "NITE" }) ~= nil,
  "and at night, because a row with no `time` is TR_ANYTIME")
check(not Evolution.checkMon(DATA,
  newMon("GOLBAT", 30, { happiness = 220, item = Evolution.EVERSTONE }),
  { timeOfDay = "DAY" }), "an EVERSTONE stops it")

local happyEevee = newMon("EEVEE", 25, { happiness = 220 })
entry = Evolution.checkMon(DATA, happyEevee, { timeOfDay = "DAY" })
eq(entry and entry.into, "ESPEON", "TR_MORNDAY gives ESPEON by day")
entry = Evolution.checkMon(DATA, happyEevee, { timeOfDay = "MORN" })
eq(entry and entry.into, "ESPEON", "and in the morning")
entry = Evolution.checkMon(DATA, happyEevee, { timeOfDay = "NITE" })
eq(entry and entry.into, "UMBREON", "TR_NITE gives UMBREON at night")
-- The stone rows come first in ROM order but need wForceEvolution, so the
-- after-battle sweep walks straight past them to the happiness rows.
eq(#POKEMON.EEVEE.evolutions, 5, "EEVEE still has all five rows")

-- ---- EVOLVE_TRADE ---------------------------------------------------------
local graveler = newMon("GRAVELER", 30)
_, reason = Evolution.rowMatches(row("GRAVELER"), graveler, {})
eq(reason, "not trading", "a trade evolution needs wLinkMode")
entry = Evolution.checkMon(DATA, graveler, { link = true })
eq(entry and entry.into, "GOLEM", "traded, GRAVELER becomes GOLEM")
check(not Evolution.checkMon(DATA,
  newMon("GRAVELER", 30, { item = Evolution.EVERSTONE }), { link = true }),
  "an EVERSTONE stops a trade evolution")

local poliwhirl = newMon("POLIWHIRL", 30)
check(not Evolution.checkMon(DATA, poliwhirl, { link = true }),
  "trading a POLIWHIRL with nothing held does nothing")
local kingsRock = newMon("POLIWHIRL", 30, { item = "KINGS_ROCK" })
local consumed
entry, consumed = Evolution.checkMon(DATA, kingsRock, { link = true })
eq(entry and entry.into, "POLITOED", "with a KING'S ROCK it becomes POLITOED")
check(consumed, "and the held item is consumed by the trade")
check(not Evolution.checkMon(DATA, kingsRock,
  { link = true, timeCapsule = true }),
  "LINK_TIMECAPSULE blocks a held-item trade evolution")
-- The WATER STONE row sits FIRST in the ROM, so a stone beats the trade.
entry = Evolution.checkMon(DATA, kingsRock,
  { item = "WATER_STONE", force = true })
eq(entry and entry.into, "POLIWRATH", "EvosAttacks order is the tiebreak")

-- ---- EVOLVE_STAT ----------------------------------------------------------
-- CompareBytes over wTempMonAttack and wTempMonDefense.
eq(Evolution.statComparison({ stats = { attack = 30, defense = 40 } }),
  "ATK_LT_DEF", "attack under defense")
eq(Evolution.statComparison({ stats = { attack = 40, defense = 30 } }),
  "ATK_GT_DEF", "attack over defense")
eq(Evolution.statComparison({ stats = { attack = 30, defense = 30 } }),
  "ATK_EQ_DEF", "attack equal to defense")

local tyrogue = newMon("TYROGUE", 19)
check(not Evolution.checkMon(DATA, tyrogue, {}), "TYROGUE waits for level 20")
tyrogue = newMon("TYROGUE", 20)
tyrogue.stats.attack, tyrogue.stats.defense = 30, 40
eq(Evolution.checkMon(DATA, tyrogue, {}).into, "HITMONCHAN",
  "ATK_LT_DEF gives HITMONCHAN")
tyrogue.stats.attack, tyrogue.stats.defense = 40, 30
eq(Evolution.checkMon(DATA, tyrogue, {}).into, "HITMONLEE",
  "ATK_GT_DEF gives HITMONLEE")
tyrogue.stats.attack, tyrogue.stats.defense = 35, 35
eq(Evolution.checkMon(DATA, tyrogue, {}).into, "HITMONTOP",
  "ATK_EQ_DEF gives HITMONTOP")

-- ---- the sweep ------------------------------------------------------------
-- ExitBattle's `ld a, [wBattleResult] / and $f / jr nz`.
check(Evolution.runsAfterBattle("win"), "a win runs the sweep")
check(Evolution.runsAfterBattle("caught"), "so does a catch")
check(not Evolution.runsAfterBattle("lose"), "a loss does not")

local party = {
  newMon("CHIKORITA", 16),
  newMon("TAUROS", 30),
  newMon("GRAVELER", 30),
}
local plan = Evolution.plan(DATA, party, { [1] = true, [2] = true }, {})
eq(#plan, 1, "only the flagged slot that can evolve is planned")
eq(plan[1].index, 1, "and it names its party slot")
eq(plan[1].into, "BAYLEEF", "and its target")
eq(#Evolution.plan(DATA, party, { [2] = true }, {}), 0,
  "a flagged TAUROS plans nothing")
eq(#Evolution.plan(DATA, party, nil, {}), 1,
  "with no flags at all every slot is eligible, and only one qualifies")
eq(#Evolution.plan(DATA, party, nil, { link = true }), 1,
  "a trade sweep finds the GRAVELER instead")
eq(Evolution.plan(DATA, party, nil, { link = true })[1].index, 3,
  "in slot 3")

-- ---- nicknames ------------------------------------------------------------
-- UpdateSpeciesNameIfNotNicknamed.
check(Evolution.keptNickname(DATA, newMon("CHIKORITA", 16)) == nil,
  "an un-nicknamed mon has no nickname to keep")
check(Evolution.keptNickname(DATA,
  newMon("CHIKORITA", 16, { nickname = "CHIKORITA" })) == nil,
  "a `nickname` that is just the species name is not a nickname")
eq(Evolution.keptNickname(DATA,
  newMon("CHIKORITA", 16, { nickname = "LEAFY" })), "LEAFY",
  "a real nickname survives")

-- ---- LearnLevelMoves ------------------------------------------------------
local learner = newMon("BAYLEEF", 16, { moves = {
  { id = "TACKLE", pp = 35, maxPp = 35 },
  { id = "GROWL", pp = 40, maxPp = 40 },
} })
local learned = Evolution.learnedOnEvolve(DATA, "BAYLEEF", 16, learner)
eq(#learned, 1, "only the level-16 move it does not already know is offered")
eq(learned[1], "REFLECT", "and that is REFLECT")
eq(#Evolution.learnedOnEvolve(DATA, "BAYLEEF", 17, learner), 0,
  "the match is on the exact level, not a range")
eq(#Evolution.learnedOnEvolve(DATA, "BAYLEEF", 23, learner), 1,
  "level 23 offers POISONPOWDER")

-- ---- apply ----------------------------------------------------------------
local before = newMon("CHIKORITA", 16, { nickname = "LEAFY" })
before.hp = 20
before.status = "PSN"
before.pokerus = 4 -- a field Mon.new knows nothing about
local beforeMax = before.maxHp
local beforeExp = before.experience
local after = Evolution.apply(DATA, before, row("CHIKORITA"))
check(after ~= nil, "apply returns a record")
eq(after.species, "BAYLEEF", "the species changed")
eq(after.name, "BAYLEEF", "and so did the display name")
eq(after.nickname, "LEAFY", "the real nickname rode along")
eq(after.level, 16, "the level did not move")
eq(after.experience, beforeExp, "and neither did the experience")
-- CalcMonStats through the one builder, at the same level and DVs.
local expected = Mon.stats(POKEMON.BAYLEEF.baseStats, before.dvs, 16)
eq(after.maxHp, expected.hp, "max HP is BAYLEEF's, recomputed")
eq(after.stats.attack, expected.attack, "so is attack")
eq(after.stats.specialDefense, expected.specialDefense,
  "and special defense, which Gen 1's builder has no slot for")
-- `ld hl, wTempMonHP + 1 / add c`: the max-HP DELTA is added, not a refill.
eq(after.hp, 20 + (expected.hp - beforeMax),
  "HP carries the max-HP gain rather than refilling")
check(after.hp < after.maxHp, "a half-dead mon is still half dead")
eq(after.status, "PSN", "the status carried over")
eq(after.pokerus, 4, "and so did a field the builder does not own")
eq(#after.moves, #before.moves, "the moves came with it")
eq(after.types[1], "GRASS", "the types are the new species'")

-- An un-nicknamed mon takes the new species' name.
local plain = newMon("CHIKORITA", 16)
local grown = Evolution.apply(DATA, plain, row("CHIKORITA"))
check(grown.nickname == nil, "an un-nicknamed mon stays un-nicknamed")
eq(grown.name, "BAYLEEF", "and simply reads as BAYLEEF")
eq(grown.hp, grown.maxHp, "a mon at full HP comes out at full HP")

-- A held item survives a level evolution but not the trade that demanded it.
local held = newMon("CHIKORITA", 16, { item = "BERRY" })
eq(Evolution.apply(DATA, held, row("CHIKORITA")).item, "BERRY",
  "a level evolution leaves the held item alone")
local traded = Evolution.apply(DATA, newMon("POLIWHIRL", 30,
  { item = "KINGS_ROCK" }), row("POLIWHIRL", 2))
eq(traded.species, "POLITOED", "the trade evolution applied")
check(traded.item == nil, "and it ate the KING'S ROCK")
-- GRAVELER's row asks for no item ($ff), so a trade leaves one in place.
local rockGolem = Evolution.apply(DATA,
  newMon("GRAVELER", 30, { item = "BERRY" }), row("GRAVELER"))
eq(rockGolem.item, "BERRY", "a no-item trade row keeps what is held")

-- ---- SetSeenAndCaughtMon --------------------------------------------------
local save = { pokedex = { seen = {}, caught = {} } }
check(Evolution.markPokedex(save, "BAYLEEF"), "the dex accepted the tick")
check(save.pokedex.seen.BAYLEEF, "BAYLEEF is seen")
check(save.pokedex.caught.BAYLEEF, "and caught, the way GivePoke does it")
local bare = {}
Evolution.markPokedex(bare, "CROBAT")
check(bare.pokedex.caught.CROBAT, "a save with no dex tables grows them")
check(not Evolution.markPokedex(nil, "CROBAT"), "and no save is a no-op")

-- ---- against a real Gold cache -------------------------------------------
local cache = os.getenv("GOLD_CACHE")
if not cache then
  local home = os.getenv("HOME") or ""
  cache = home .. "/Library/Application Support/LOVE/gold-dev/gold"
end
local path = cache .. "/data/generated/pokemon.lua"
local file = io.open(path, "r")
if not file then
  check(true, "gold pokemon cache absent - SKIP")
  S.finish()
  return
end
file:close()

local cachedPokemon = assert(loadfile(path))()
local withEvolutions = 0
for _, def in pairs(cachedPokemon) do
  if type(def) == "table" and def.evolutions and #def.evolutions > 0 then
    withEvolutions = withEvolutions + 1
  end
end
check(withEvolutions > 100,
  "the cache carries evolution rows for " .. withEvolutions .. " species")

local bulbasaur = cachedPokemon.BULBASAUR
check(bulbasaur ~= nil, "BULBASAUR is in the cache")
if bulbasaur then
  eq(bulbasaur.evolutions[1].method, "EVOLVE_LEVEL", "its row is a level row")
  eq(bulbasaur.evolutions[1].level, 16, "at level 16")
  eq(bulbasaur.evolutions[1].into, "IVYSAUR", "into IVYSAUR")
end

-- EeveeEvosAttacks: three stones then two happiness rows.  The `time` field
-- itself is NOT asserted here: src/import/RomExtractorGen2.lua's TR_NAMES and
-- ATK_NAMES tables are indexed from 0 while the TR_* / ATK_*_DEF constants
-- start at 1, so those two fields currently come out one constant off.
local cachedEevee = cachedPokemon.EEVEE
if cachedEevee then
  local stones, happy = 0, 0
  for _, e in ipairs(cachedEevee.evolutions) do
    if e.method == "EVOLVE_ITEM" then stones = stones + 1 end
    if e.method == "EVOLVE_HAPPINESS" then happy = happy + 1 end
  end
  eq(stones, 3, "EEVEE has three stone rows in the cache")
  eq(happy, 2, "and two happiness rows")
end

-- A whole evolution driven off the real tables, to prove the reader and the
-- builder agree about the cache's field names.
local cachedData = {
  pokemon = cachedPokemon,
  moves = (function()
    local movePath = cache .. "/data/generated/moves.lua"
    local f = io.open(movePath, "r")
    if not f then return {} end
    f:close()
    return assert(loadfile(movePath))()
  end)(),
}
local real = Mon.new(cachedData, "CHIKORITA", 16, { dvs = {
  attack = 9, defense = 8, speed = 8, special = 8 } })
if real then
  local realEntry = Evolution.checkMon(cachedData, real, {})
  eq(realEntry and realEntry.into, "BAYLEEF",
    "a real level 16 CHIKORITA evolves into BAYLEEF")
  local realAfter = Evolution.apply(cachedData, real, realEntry)
  eq(realAfter and realAfter.species, "BAYLEEF", "and apply builds one")
  check(realAfter and realAfter.maxHp > real.maxHp,
    "with more max HP than it had")
  check(realAfter and realAfter.hp == realAfter.maxHp,
    "and a full-health mon still at full health")
  eq(realAfter and #realAfter.moves, #real.moves,
    "carrying the same number of moves")
end

S.finish()

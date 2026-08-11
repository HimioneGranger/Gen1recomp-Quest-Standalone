-- Badge battle boosts: BadgeStatBoosts (engine/battle/core.asm:6534) and
-- DoBadgeTypeBoosts (engine/battle/misc.asm:146).
--
--   luajit tests/gen2_badge_boosts_test.lua
--
-- ROM-free.  Every Johto badge on the boost walk raises the PLAYER's
-- in-battle stat by 1/8 -- Zephyr on Attack, Mineral on Defense and Plain on
-- Speed (the deliberate bit swap), Glacier on Special Attack with the buggy
-- Special Defense re-check -- and an owned badge whose BadgeTypeBoosts row
-- matches the move's type adds an eighth to the damage ahead of STAB.

package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 badge boosts")
local check, eq = S.check, S.eq

local Battle = require("src.battle.gen2.Battle")
local Damage = require("src.battle.gen2.Damage")
local Mon = require("src.battle.gen2.Mon")

-- ---------------------------------------------------------------- fixtures

local TYPES = {
  NORMAL = { id = "NORMAL", index = 0, category = "physical" },
  FLYING = { id = "FLYING", index = 2, category = "physical" },
  ROCK = { id = "ROCK", index = 5, category = "physical" },
  FIRE = { id = "FIRE", index = 20, category = "special" },
  WATER = { id = "WATER", index = 21, category = "special" },
}

local MOVES = {
  TACKLE = { id = "TACKLE", name = "TACKLE", power = 35, type = "NORMAL",
    accuracy = 100, pp = 35, effect = "EFFECT_NORMAL_HIT" },
  ROCK_THROW = { id = "ROCK_THROW", name = "ROCK THROW", power = 50,
    type = "ROCK", accuracy = 100, pp = 15, effect = "EFFECT_NORMAL_HIT" },
  GUST = { id = "GUST", name = "GUST", power = 40, type = "FLYING",
    accuracy = 100, pp = 35, effect = "EFFECT_NORMAL_HIT" },
}

local GROWTH = {
  GROWTH_MEDIUM_FAST = { numerator = 1, denominator = 1, squared = 0,
    linear = 0, constant = 0 },
}

local POKEMON = {
  growthRates = GROWTH,
  MACHOP = {
    id = "MACHOP", index = 66, name = "MACHOP",
    baseStats = { hp = 70, attack = 80, defense = 50, speed = 35,
      specialAttack = 35, specialDefense = 35 },
    types = { "NORMAL", "NORMAL" }, catchRate = 180, baseExp = 75,
    growthRate = "GROWTH_MEDIUM_FAST", genderRatio = 63,
    levelMoves = { { level = 1, move = "TACKLE" } }, evolutions = {},
  },
  PIDGEY = {
    id = "PIDGEY", index = 16, name = "PIDGEY",
    baseStats = { hp = 40, attack = 45, defense = 40, speed = 56,
      specialAttack = 35, specialDefense = 35 },
    types = { "NORMAL", "FLYING" }, catchRate = 255, baseExp = 55,
    growthRate = "GROWTH_MEDIUM_FAST", genderRatio = 127,
    levelMoves = { { level = 1, move = "TACKLE" } }, evolutions = {},
  },
}

local DATA = {
  pokemon = POKEMON,
  moves = MOVES,
  type_chart = { types = TYPES, matchups = {} },
  items = {},
}

local perfect = { attack = 15, defense = 15, speed = 15, special = 15 }
perfect.hp = Mon.hpDV(perfect)

local function newBattle(badges, kantoBadges)
  local player = Mon.new(DATA, "MACHOP", 20, { dvs = perfect })
  player.moves = {
    { id = "TACKLE", pp = 35, maxPp = 35 },
    { id = "ROCK_THROW", pp = 15, maxPp = 15 },
    { id = "GUST", pp = 35, maxPp = 35 },
  }
  local wild = Mon.new(DATA, "PIDGEY", 20, { dvs = perfect })
  wild.moves = { { id = "TACKLE", pp = 35, maxPp = 35 } }
  local save = { player = { id = 7, badges = badges or {},
    kantoBadges = kantoBadges or {} } }
  local battle = Battle.new({ data = DATA, party = { player }, wild = wild,
    save = save, random = function(n) return (n or 1) > 1 and 1 or 0 end })
  return battle, player, wild, save
end

-- ---- BoostStat: +1/8, capped at 999 ---------------------------------------
do
  eq(Battle.boostStat(80), 90, "80 + 80/8 = 90")
  eq(Battle.boostStat(7), 7, "a stat under 8 gains nothing (plain shift)")
  eq(Battle.boostStat(999), 999, "the 999 cap holds")
  eq(Battle.boostStat(950), 999, "and clips a boost past it")
end

-- ---- the stat walk: Zephyr/Mineral/Plain/Glacier --------------------------
do
  local battle, player = newBattle({})
  local base = player.stats.attack
  eq(battle:battleStat(player, "attack"), base,
    "no badge, no boost")

  battle, player = newBattle({ ZEPHYR = true })
  eq(battle:battleStat(player, "attack"), Battle.boostStat(base),
    "ZEPHYRBADGE boosts Attack by 1/8")
  eq(battle:battleStat(player, "defense"), player.stats.defense,
    "and only Attack")

  battle, player = newBattle({ MINERAL = true })
  eq(battle:battleStat(player, "defense"),
    Battle.boostStat(player.stats.defense),
    "MINERALBADGE lands on Defense (the PlainBadge bit swap)")

  battle, player = newBattle({ PLAIN = true })
  eq(battle:battleStat(player, "speed"),
    Battle.boostStat(player.stats.speed),
    "PLAINBADGE lands on Speed")

  battle, player = newBattle({ GLACIER = true })
  eq(battle:battleStat(player, "specialAttack"),
    Battle.boostStat(player.stats.specialAttack),
    "GLACIERBADGE boosts Special Attack")

  -- The ENEMY never gets badge boosts: BadgeStatBoosts runs against
  -- wBattleMon only.
  local wild = battle.enemy
  eq(battle:battleStat(wild, "attack"), wild.stats.attack,
    "the enemy's stats are never badge boosted")

  -- Positional keying, the same fallback FieldMoves.hasBadge accepts.
  battle, player = newBattle({ true })
  eq(battle:battleStat(player, "attack"), Battle.boostStat(base),
    "badges keyed by bit position read the same")
end

-- ---- the buggy Glacier Special Defense re-check ---------------------------
-- `srl a` runs on BoostStat's leftover cap arithmetic (core.asm:6584's own
-- "this check is buggy" comment), so whether SpDef gets the second boost
-- depends on the BOOSTED Special Attack value.
do
  -- high(v) = 0: a = 0 - 3 - borrow; odd only when low(v) >= LOW(999).
  eq(Battle.glacierBoostsSpDef(100), false, "SpA 100: no SpDef boost")
  eq(Battle.glacierBoostsSpDef(240), true, "SpA 240: boosted")
  -- high(v) = 1: odd while the borrow holds.
  eq(Battle.glacierBoostsSpDef(300), true, "SpA 300: boosted")
  eq(Battle.glacierBoostsSpDef(500), false, "SpA 500: not boosted")
  -- high(v) = 2: only the no-borrow tail.
  eq(Battle.glacierBoostsSpDef(600), false, "SpA 600: not boosted")
  eq(Battle.glacierBoostsSpDef(750), true, "SpA 750: boosted")
  -- high(v) = 3 under the cap always borrows.
  eq(Battle.glacierBoostsSpDef(800), true, "SpA 800: boosted")
  -- At or past the cap `a` leaves as LOW(999) = $e7, odd.
  eq(Battle.glacierBoostsSpDef(999), true, "capped SpA: boosted")

  local battle, player = newBattle({ GLACIER = true })
  local spAtk = Battle.boostStat(player.stats.specialAttack)
  local want = Battle.glacierBoostsSpDef(spAtk)
    and Battle.boostStat(player.stats.specialDefense)
    or player.stats.specialDefense
  eq(battle:battleStat(player, "specialDefense"), want,
    "battleStat routes SpDef through the buggy re-check")

  battle, player = newBattle({})
  eq(battle:battleStat(player, "specialDefense"),
    player.stats.specialDefense,
    "no Glacier, no SpDef boost ever (the srl lands on a zero bit)")
end

-- ---- Plain Badge Speed feeds turn order -----------------------------------
do
  local battle, player = newBattle({ PLAIN = true })
  eq(battle:effectiveSpeed(player),
    Damage.applyStage(Battle.boostStat(player.stats.speed), 0),
    "effectiveSpeed reads the boosted Speed")
end

-- ---- DoBadgeTypeBoosts in the damage pipe ---------------------------------
do
  -- Hand-sized numbers: level 10, power 40, attack 50, defense 40.
  -- base = (floor(10*2/5)+2) * 40 * 50 / 40 / 50 -> 6, +MIN_DAMAGE = 8.
  local args = {
    level = 10, power = 40, moveType = "ROCK",
    attacker = { attack = 50, types = {}, stages = {} },
    defender = { defense = 40, types = {}, stages = {} },
    types = TYPES, matchups = {},
    variation = 100,
  }
  local plain = Damage.calc(args)
  eq(plain, 8, "the unboosted pipe leaves 8")
  args.badgeTypeBoost = true
  eq(Damage.calc(args), 9,
    "the badge boost adds an eighth (at least 1) ahead of STAB")
end

-- ---- the boost table walks Johto then Kanto -------------------------------
do
  local battle = newBattle({ ZEPHYR = true })
  eq(battle:badgeTypeBoost(battle.player, "FLYING"), true,
    "ZEPHYRBADGE boosts FLYING moves")
  eq(battle:badgeTypeBoost(battle.player, "ROCK"), false,
    "but not ROCK (BOULDERBADGE's row, not owned)")
  eq(battle:badgeTypeBoost(battle.enemy, "FLYING"), false,
    "and never on the enemy's turn (hBattleTurn gate)")

  battle = newBattle({}, { BOULDER = true })
  eq(battle:badgeTypeBoost(battle.player, "ROCK"), true,
    "BOULDERBADGE (wKantoBadges) boosts ROCK -- Brock's own line")
  eq(battle:badgeTypeBoost(battle.player, "NORMAL"), false,
    "PLAINBADGE's NORMAL row stays shut without the badge")

  battle = newBattle({}, { VOLCANO = true, EARTH = true })
  eq(battle:badgeTypeBoost(battle.player, "FIRE"), true,
    "VOLCANOBADGE boosts FIRE")
  eq(battle:badgeTypeBoost(battle.player, "GROUND"), true,
    "EARTHBADGE boosts GROUND")
end

-- ---- through the real hit -------------------------------------------------
do
  -- Same battle twice, the only difference the badge: the ROCK move's damage
  -- must grow and the NORMAL move's must not.
  local function hit(badges, kanto, move)
    local battle = newBattle(badges, kanto)
    local enemy = battle.enemy
    local before = enemy.hp
    battle:useMove(battle.player, enemy, move)
    return before - enemy.hp
  end
  local bare = hit({}, {}, "ROCK_THROW")
  local badged = hit({}, { BOULDER = true }, "ROCK_THROW")
  check(badged > bare,
    ("BOULDERBADGE raises ROCK THROW's damage (%d -> %d)"):format(
      bare, badged))
  eq(hit({}, { BOULDER = true }, "TACKLE"), hit({}, {}, "TACKLE"),
    "a NORMAL move is not BOULDERBADGE's business")
end

S.finish()

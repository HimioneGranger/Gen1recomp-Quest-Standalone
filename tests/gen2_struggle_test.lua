-- STRUGGLE: what a mon does when every move is spent.
--
--   luajit tests/gen2_struggle_test.lua
--
-- Found by the Gold route bot (tests/drivers/gold_bot.lua), which walked into
-- it about two hours into a run and could not get out.  Before this, a mon with
-- no PP left simply did not act:
--
--   * the player's turn emitted "No PP left for this move!" and returned
--   * the enemy's turn emitted "<name> has no moves left!" and returned
--
-- Neither side dealt damage, so the battle could not end -- and because RUN is
-- refused in a trainer battle, it could not be left either.  The save was
-- effectively dead.  The cart has no such state: `.CheckPlayerHasUsableMoves`
-- (engine/battle/core.asm:5273) and `.struggle` (:5631) both substitute
-- STRUGGLE, which is exactly what is asserted here.
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 struggle")
local check, eq = S.check, S.eq

local Battle = require("src.battle.gen2.Battle")

-- hasUsableMoves is the predicate the substitution hangs off, and it is worth
-- pinning on its own: a mon whose only remaining PP is on a STATUS move is not
-- dry, and must not struggle.
do
  eq(Battle.hasUsableMoves({}, { moves = {} }), false, "no moves at all is dry")
  eq(Battle.hasUsableMoves({}, { moves = { { id = "TACKLE", pp = 0 } } }), false,
     "a single spent move is dry")
  eq(Battle.hasUsableMoves({}, { moves = { { id = "TACKLE", pp = 0 },
                                           { id = "LEER", pp = 3 } } }), true,
     "PP left on a status move is not dry")
  eq(Battle.hasUsableMoves({}, { moves = { { id = "TACKLE", pp = 1 } } }), true,
     "one PP is not dry")
  eq(Battle.hasUsableMoves({}, { moves = { { id = "GROWL", pp = 40 } },
     volatile = { disabled = "GROWL" } }), false,
     "PP on the disabled slot alone is dry (.CheckPlayerHasUsableMoves)")
  eq(Battle.hasUsableMoves({}, { moves = { { id = "GROWL", pp = 40 },
     { id = "TACKLE", pp = 5 } }, volatile = { disabled = "GROWL" } }), true,
     "another slot with PP is not dry")
end

eq(Battle.STRUGGLE, "STRUGGLE", "the fallback names the real move id")

-- ---------------------------------------------------------------------------
-- The move itself has to exist in the extracted data, or the substitution
-- swaps one dead turn for another: useMove bails with "has no move to use!"
-- when moveDef comes back nil.
-- ---------------------------------------------------------------------------

local cache = os.getenv("GOLD_CACHE")
if not cache then
  cache = (os.getenv("HOME") or "")
    .. "/Library/Application Support/LOVE/gold-dev/gold"
end
local movesPath = cache .. "/data/generated/moves.lua"
local mf = io.open(movesPath, "r")
if not mf then
  check(true, "gold cache absent : predicate checked, move data SKIPPED")
  S.finish()
  return
end
mf:close()

local moves = assert(loadfile(movesPath))()
local struggle = moves[Battle.STRUGGLE]
check(struggle ~= nil, "STRUGGLE is in the extracted move table")
if struggle then
  eq(struggle.power, 50, "STRUGGLE has power, so a dry turn still does damage")
  eq(struggle.effect, "EFFECT_RECOIL_HIT",
     "STRUGGLE recoils (the effect the port already implements)")
  -- The recoil is the reason a stalemate resolves even when NEITHER side can
  -- damage the other any other way: both sides wear themselves down.
  check((struggle.pp or 0) > 0, "STRUGGLE carries its own PP")
end

S.finish()

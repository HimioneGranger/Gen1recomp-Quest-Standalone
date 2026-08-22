-- Trainer battles may use a battle-local view of save-party records without
-- mutating, reordering, or hiding those records in the authoritative save.

package.path = "./?.lua;./?/init.lua;" .. package.path
love = love or require("tests.love_stub")

local T = require("tests.harness").suite("trainer battle party scope")
local BattleState = require("src.battle.BattleState")
local Fixtures = require("tests.modkit").fixtures
local PartyMenu = require("src.ui.PartyMenu")
local Pokemon = require("src.pokemon.Pokemon")
local SaveData = require("src.core.SaveData")

local Data = Fixtures.fresh()

local function makeGame()
  local save = SaveData.newGame()
  save.party = {
    Pokemon.new(Data, "FIXMON_A", 10),
    Pokemon.new(Data, "FIXMON_B", 11),
    Pokemon.new(Data, "FIXMON_C", 12),
  }
  return { data = Data, save = save, stack = {
    push = function() end, pop = function() end, top = function() end,
  } }
end

local game = makeGame()
local originalParty = game.save.party
local first, second, third = unpack(originalParty)
local battle = BattleState.newTrainer(game, "OPP_FIX_YOUNGSTER", 1, {
  playerPartyIndices = { 2, 3 },
})
T.check(game.save.party == originalParty,
  "scoping never replaces the authoritative save-party table")
T.check(game.save.party[1] == first and game.save.party[2] == second
    and game.save.party[3] == third,
  "scoping never reorders authoritative save-party records")
T.same(battle.playerPartyIndices, { 2, 3 },
  "the battle records normalized save-party indices")
T.check(battle.playerParty[1] == second and battle.playerParty[2] == third,
  "the local party view contains the same selected Pokemon records")
T.check(battle.player.mon == second,
  "initial send chooses the first healthy scoped member")

local menu = PartyMenu.new(game, { battle = battle })
T.check(menu.party == battle.playerParty,
  "battle party menus traverse only the local eligible view")

second.hp = 0
battle.player.mon.hp = 0
battle:playerMonFainted()
T.eq(battle.result, nil,
  "a healthy scoped replacement prevents premature exhaustion")
third.hp = 0
battle:playerMonFainted()
T.eq(battle.result, "lose",
  "an excluded healthy save-party member cannot prevent scoped exhaustion")
T.check(first.hp > 0, "the excluded save-party member remains untouched")

local expGame = makeGame()
expGame.save.inventory.EXP_ALL = 1
local expBattle = BattleState.newTrainer(expGame,
  "OPP_FIX_YOUNGSTER", 1, { playerPartyIndices = { 2, 3 } })
local excludedExp = expGame.save.party[1].exp
local participantExp = expGame.save.party[2].exp
local sharedExp = expGame.save.party[3].exp
expBattle.participants = { [expGame.save.party[2]] = true }
expBattle:awardExp()
T.eq(expGame.save.party[1].exp, excludedExp,
  "EXP.ALL cannot award an excluded save-party member")
T.check(expGame.save.party[2].exp > participantExp,
  "a scoped participant receives battle experience")
T.check(expGame.save.party[3].exp > sharedExp,
  "EXP.ALL traverses other eligible scoped members")

for _, bad in ipairs({ { 0, 99, 1.5, 0 }, { 2, 99 }, { 2, 2 } }) do
  local fallbackGame = makeGame()
  local fallback = BattleState.newTrainer(fallbackGame,
    "OPP_FIX_YOUNGSTER", 1, { playerPartyIndices = bad })
  T.eq(fallback.playerParty, nil,
    "an invalid scope degrades to the vanilla full-party path")
  T.eq(fallback.player.mon, fallbackGame.save.party[1],
    "invalid scope fallback preserves vanilla initial send")
end

local linkGame = makeGame()
local linkBattle = BattleState.newTrainer(linkGame,
  "OPP_FIX_YOUNGSTER", 1, { playerPartyIndices = { 2, 3 } })
linkBattle.kind = "link"
linkBattle.result = "guestWin"
linkGame.save.party[2].hp, linkGame.save.party[3].hp = 0, 0
linkBattle:finish()
T.eq(linkBattle.result, "guestWin",
  "link spectator outcomes are not rewritten by trainer eligibility scope")

T.finish()

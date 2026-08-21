-- The stat name substituted into X-item/vitamin "rose!" messages must
-- itself reach a translation catalog, not just the surrounding sentence
-- template (src/inventory/ItemEffects.lua, src/battle/TrainerAI.lua).
-- With no catalog loaded it stays English (the existing baseline); with
-- one loaded that translates e.g. "ATTACK", the substituted word must
-- change too -- that is the actual bug this suite guards against, which
-- passing/failing sentences alone (as other suites already check)
-- cannot tell apart from a raw stat:upper() that was never wrapped in
-- Strings() at all.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Data = T.fixtures.fresh()
local Pokemon = require("src.pokemon.Pokemon")
local SaveData = require("src.core.SaveData")
local ItemEffects = require("src.inventory.ItemEffects")
local TrainerAI = require("src.battle.TrainerAI")
local Strings = require("src.core.Strings")

local function withCatalog(catalog, fn)
  Strings.load({ strings = catalog })
  local ok, err = pcall(fn)
  Strings.load(nil)
  if not ok then error(err, 0) end
end

-- ------------------------------------------------------- player X-item

local save = SaveData.newGame()
local player = { name = "FIXMON", stages = {} }
local xBattle = { player = player, kind = "wild" }

local _, baseline = ItemEffects.use(Data, save, "X_ATTACK", nil, xBattle)
T.check(baseline[1]:find("ATTACK", 1, true) ~= nil,
  "X ATTACK's rose! message names the stat in English with no catalog")

withCatalog({ ATTACK = "ATTAQUE" }, function()
  player.stages.attack = nil
  local _, msgs = ItemEffects.use(Data, save, "X_ATTACK", nil, xBattle)
  T.check(msgs[1]:find("ATTAQUE", 1, true) ~= nil,
    "a catalog translating ATTACK reaches the X ATTACK rose! message")
  T.check(msgs[1]:find("ATTACK", 1, true) == nil,
    "...and the untranslated English stat name is gone")
end)

-- --------------------------------------------------------- player vitamin

local target = Pokemon.new(Data, "FIXMON_A", 10)
withCatalog({ DEFENSE = "DEFENSE_FR" }, function()
  local _, msgs = ItemEffects.use(Data, save, "IRON", target)
  T.check(msgs[1]:find("DEFENSE_FR", 1, true) ~= nil,
    "a catalog translating DEFENSE reaches the IRON (vitamin) rose! message")
end)

local hpTarget = Pokemon.new(Data, "FIXMON_A", 10)
withCatalog({ HP = "PV" }, function()
  local _, msgs = ItemEffects.use(Data, save, "HP_UP", hpTarget)
  T.check(msgs[1]:find("PV", 1, true) ~= nil,
    "a catalog translating HP reaches the HP UP rose! message")
end)

-- ------------------------------------------------------- AI trainer X-item

local enemy = { name = "FOE", stages = {} }
local aiBattle = { enemy = enemy, trainer = { name = "TRAINER" }, data = Data }

withCatalog({ SPEED = "VITESSE" }, function()
  local msgs = TrainerAI.useItem(aiBattle, "X_SPEED")
  T.check(msgs[2]:find("VITESSE", 1, true) ~= nil,
    "a catalog translating SPEED reaches the AI trainer's X SPEED rose! message")
end)

T.finish("stat rise message translation")

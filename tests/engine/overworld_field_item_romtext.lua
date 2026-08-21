-- Portable subset of upstream bff40a5d and its 72592665 regressions.
-- The accepted core does not contain upstream useSoftboiledFieldMove, so this
-- covers only the independent field-poison, hidden-item, and item-ball paths.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Data = T.fixtures.fresh()

local SaveData = require("src.core.SaveData")
local Pokemon = require("src.pokemon.Pokemon")
local OW = require("src.world.OverworldController")

local function setUpvalue(fn, name, value)
  local i = 1
  while true do
    local found = debug.getupvalue(fn, i)
    if not found then return false end
    if found == name then
      debug.setupvalue(fn, i, value)
      return true
    end
    i = i + 1
  end
end

local pushed = {}
local textBoxStub = {
  new = function(_, text, onDone, opts)
    return { text = text, onDone = onDone, opts = opts }
  end,
}

local realSound = package.loaded["src.core.Sound"]
package.loaded["src.core.Sound"] = {
  play = function() end,
  playCry = function() end,
}

local function mkGame()
  local save = SaveData.newGame()
  save.player.name = "FAKEPLAYER"
  save.party = { Pokemon.new(Data, "FIXMON_A", 20) }
  pushed = {}
  return {
    data = Data,
    save = save,
    stack = { push = function(_, item) pushed[#pushed + 1] = item end },
  }
end

for _, method in ipairs({ "applyFieldPoison", "tryHiddenObject", "talkTo" }) do
  T.check(setUpvalue(OW[method], "Game", mkGame()),
    ("Game upvalue on %s"):format(method))
  T.check(setUpvalue(OW[method], "TextBox", textBoxStub),
    ("TextBox upvalue on %s"):format(method))
end
T.check(setUpvalue(OW.talkTo, "mapScripts", {
  talkScript = function() return nil end,
}), "mapScripts upvalue on talkTo")

local fakeSelf = setmetatable({}, { __index = OW })

local function poisonMessage(catalogText)
  local game = mkGame()
  setUpvalue(OW.applyFieldPoison, "Game", game)
  local mon = game.save.party[1]
  mon.status = "PSN"
  mon.hp = 1
  game.save.poisonSteps = 3
  Data.text._PokemonFaintedText = catalogText
  fakeSelf:applyFieldPoison()
  return pushed[1] and pushed[1].text, mon.nickname or "FIXMON A"
end

local text, monName = poisonMessage("FAKE {RAM:wNameBuffer} FAKE!")
T.eq(text, "FAKE " .. monName .. " FAKE!",
  "field poison uses translated _PokemonFaintedText")
text, monName = poisonMessage(nil)
T.eq(text, monName .. "\nfainted!",
  "field poison keeps the English fallback")

local mapId = "FIX_TOWN"
Data.field.hiddenItems[mapId] = { { x = 3, y = 3, item = "FIX_BALL" } }
local hiddenSelf = setmetatable({ map = { id = mapId } }, { __index = OW })

local function hiddenMessage(catalogText)
  local game = mkGame()
  setUpvalue(OW.tryHiddenObject, "Game", game)
  Data.text._FoundHiddenItemText = catalogText
  T.check(hiddenSelf:tryHiddenObject(3, 3) == true,
    "the fixture hidden item is found")
  return pushed[1] and pushed[1].text
end

T.eq(hiddenMessage("FAKE {PLAYER} found {RAM:wNameBuffer}!"),
  "FAKE FAKEPLAYER found FIX BALL!",
  "hidden items use translated _FoundHiddenItemText")
T.eq(hiddenMessage(nil), "FAKEPLAYER found\nFIX BALL!",
  "hidden items keep the English fallback")

local function itemBallMessage(catalogText)
  local game = mkGame()
  setUpvalue(OW.talkTo, "Game", game)
  Data.text._FoundItemText = catalogText
  local npc = { id = "FIX_ITEM", def = { item = "FIX_BALL", text = 1 } }
  local world = setmetatable({
    map = { id = mapId },
    npcs = { npc },
    entities = { npc },
  }, { __index = OW })
  world:talkTo(npc)
  return pushed[1] and pushed[1].text
end

T.eq(itemBallMessage("FAKE {PLAYER} got {RAM:wNameBuffer}!"),
  "FAKE FAKEPLAYER got FIX BALL!",
  "item balls use translated _FoundItemText")
T.eq(itemBallMessage(nil), "FAKEPLAYER found\nFIX BALL!",
  "item balls keep the English fallback")

Data.text._PokemonFaintedText = nil
Data.text._FoundHiddenItemText = nil
Data.text._FoundItemText = nil
package.loaded["src.core.Sound"] = realSound

T.finish("overworld field and item ROM text")

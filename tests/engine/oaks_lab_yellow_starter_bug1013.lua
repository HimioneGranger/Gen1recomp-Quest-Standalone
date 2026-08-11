-- Yellow's starter Pikachu gets the nickname prompt (#1013).
-- pokeyellow scripts/OaksLab.asm OaksLabPlayerReceivesPikachuScript.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Data = T.fixtures.load()

local pushed = {}
local realTextBox = package.loaded["src.render.TextBox"]
-- Commands requires TextBox at load time; stub it before the first require
package.loaded["src.render.TextBox"] = {
  new = function(_, text, onDone, opts)
    return { text = text, onDone = onDone, opts = opts }
  end,
}
local Commands = require("src.script.Commands")
local SaveData = require("src.core.SaveData")

-- === the lab scene: one PIKACHU gift row, and no skipNickname on it
local lab = dofile("data/scripts/oaks_lab_yellow.lua")
local ball = lab.talk.TEXT_OAKSLAB_EEVEE_POKE_BALL
T.check(type(ball) == "function", "the Eevee ball builds its rows per playthrough")

local captured
local function buildScene(cellX, cellY)
  captured = nil
  local game = { data = Data, save = SaveData.newGame() }
  game.save.flags.EVENT_OAK_ASKED_TO_CHOOSE_MON = true
  local ow = {
    player = { cellX = cellX, cellY = cellY },
    runner = { run = function(_, rows) captured = rows end },
  }
  ball(game, ow, { def = {} }, function() end)
  return captured or {}
end

local function indexOf(rows, verb, arg)
  for i, row in ipairs(rows) do
    if row[1] == verb and (arg == nil or row[2] == arg) then return i end
  end
end

-- the shove branch (player on the table row, py == 4) and the plain
for _, spot in ipairs({ { 9, 4 }, { 5, 6 } }) do
  local rows = buildScene(spot[1], spot[2])
  local where = ("from (%d,%d)"):format(spot[1], spot[2])
  local gives = 0
  for _, row in ipairs(rows) do
    if row[1] == "give_pokemon" then
      gives = gives + 1
      T.eq(row[2], "PIKACHU", "the gift species is PIKACHU " .. where)
      T.eq(row[3], 5, "the gift is level 5 " .. where)
      T.check(row[4] == nil,
        "no skipNickname: AskName is left to run " .. where .. " (#1013)")
    end
  end
  T.eq(gives, 1, "exactly one give_pokemon row " .. where)

  local give = indexOf(rows, "give_pokemon")
  local received = indexOf(rows, "show_text", "_OaksLabReceivedText")
  local got = indexOf(rows, "set_flag", "EVENT_GOT_STARTER")
  T.check(received and give and received < give,
    "the received line prints before the mon is added " .. where)
  T.check(give and got and give < got,
    "AddPartyMon runs before SetEvent EVENT_GOT_STARTER " .. where)
end

-- === nothing in the Yellow lab names a Kanto starter (#1014): only a mod
local source = assert(io.open("data/scripts/oaks_lab_yellow.lua", "r"))
local text = source:read("*a")
source:close()
for _, species in ipairs({ "CHARMANDER", "SQUIRTLE", "BULBASAUR" }) do
  T.check(not text:find(species, 1, true),
    "the Yellow lab script never names " .. species)
end

-- === give_pokemon offers AskName with a runner and no skipNickname
local function giveThrough(skipNickname)
  pushed = {}
  local game = { data = Data, save = SaveData.newGame(),
                 stack = { push = function(_, box) pushed[#pushed + 1] = box end } }
  local runner = {
    yield = function() return coroutine.yield() end,
    resume = function(self, ...) coroutine.resume(self.co, ...) end,
  }
  local ctx = { game = game, save = game.save, runner = runner }
  runner.co = coroutine.create(function()
    Commands.give_pokemon(ctx, "FIXMON_A", 5, skipNickname)
  end)
  local ok, err = coroutine.resume(runner.co)
  T.check(ok, "give_pokemon runs cleanly: " .. tostring(err))
  return game.save
end

local save = giveThrough(nil)
T.eq(#pushed, 1, "a plain gift puts one box up")
T.check(tostring(pushed[1].text):find("nickname", 1, true) ~= nil,
  "that box is AskName's question")
T.check(pushed[1].opts and pushed[1].opts.choice ~= nil,
  "AskName is a YES/NO, not a plain box")
T.eq(#save.party, 1, "the gift joined the party")

save = giveThrough(true)
T.eq(#pushed, 0, "skipNickname suppresses the prompt")
T.eq(#save.party, 1, "the gift still joined the party")

if realTextBox ~= nil then
  package.loaded["src.render.TextBox"] = realTextBox
else
  package.loaded["src.render.TextBox"] = nil
end

T.finish("oaks_lab_yellow_starter_bug1013")

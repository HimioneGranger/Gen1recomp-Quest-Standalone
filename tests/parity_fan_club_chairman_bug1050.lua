-- Parity: the Fan Club Chairman asks before telling his story (#1050).
-- pokered scripts/PokemonFanClub.asm PokemonFanClubChairmanText.
package.path = "./?.lua;./?/init.lua;" .. package.path
if not _G.love then _G.love = require("tests.love_stub") end
local Data = require("src.core.Data")
if not (Data.maps and Data.maps.PALLET_TOWN) then Data:load() end

local S = require("tests.harness").suite("parity Fan Club chairman")
local check, eq = S.check, S.eq

local Game = require("src.core.Game")
local Input = require("src.core.Input")
local StateStack = require("src.core.StateStack")
local SaveData = require("src.core.SaveData")
local ScriptRunner = require("src.script.ScriptRunner")
local Commands = require("src.script.Commands")
local Flags = require("src.script.Flags")
local ChoiceBox = require("src.ui.ChoiceBox")
local mapScripts = require("data.scripts.init")

Game.data = Data
Game.input = Input; Input:init()
Game.stack = StateStack; StateStack:init()
Game.save = SaveData.newGame()
require("src.render.Font").load(Data)

local MAP, TEXT = "POKEMON_FAN_CLUB", "TEXT_POKEMONFANCLUB_CHAIRMAN"
local script = mapScripts.talkScript(MAP, TEXT)
check(type(script) == "table", "the chairman is a row list")
eq(#ScriptRunner.validate(script), 0,
   "the rows validate cleanly (labels resolve after the renumbering)")

-- === the intro is the question, not a plain box ===
local asks = 0
for _, row in ipairs(type(script) == "table" and script or {}) do
  if row[1] == "ask" then
    asks = asks + 1
    eq(row[2], "_PokemonFanClubChairmanIntroText",
       "the YesNoChoice rides the intro text (#1050)")
  end
end
eq(asks, 1, "exactly one question, right after the intro")

-- === harness: run the talk script headless, recording show_text ids ===
local shown = {}
local origShow = Commands.show_text
-- forward extraOpts: Commands.ask rides show_text's 4th argument
Commands.show_text = function(ctx, textId, subs, ...)
  table.insert(shown, textId)
  return origShow(ctx, textId, subs, ...)
end

-- pressFn returns the Input.pressed table for this frame (default: A)
local function runScript(pressFn)
  shown = {}
  local ow = { map = { id = MAP, def = { label = MAP } },
               npcs = {}, entities = {} }
  local r = ScriptRunner.new(Game, ow)
  r:run(script, { npc = { def = {}, facePlayer = function() end },
                  overworld = ow })
  local guard = 0
  while r:isRunning() and guard < 3000 do
    guard = guard + 1
    Input.pressed = pressFn and pressFn() or { a = true }
    StateStack:update(1 / 60)
    r:update()
  end
  Input.pressed = {}
  return not r:isRunning()
end

local function shownIs(want, msg)
  eq(table.concat(shown, ","), table.concat(want, ","), msg)
end

-- press B while the YES/NO box is up, A otherwise: the NO answer
local function declines()
  if getmetatable(StateStack:top()) == ChoiceBox then return { b = true } end
  return { a = true }
end

local function held(id) return Game.save.inventory[id] or 0 end

-- === 1) YES: story, voucher, received line, explanation ===
Game.save = SaveData.newGame()
check(runScript(), "chairman script completes on YES")
shownIs({ "_PokemonFanClubChairmanIntroText",
          "_PokemonFanClubChairmanStoryText",
          "_PokemonFanClubReceivedBikeVoucherText",
          "_PokemonFanClubExplainBikeVoucherText" },
        "YES hears the RAPIDASH story out and collects the voucher")
eq(held("BIKE_VOUCHER"), 1, "the BIKE VOUCHER is in the bag")
check(Flags.get(Game.save, "EVENT_RECEIVED_BIKE_VOUCHER"),
      "EVENT_GOT_BIKE_VOUCHER is set")

-- === 2) NO: the brush-off, and the voucher stays with the chairman ===
Game.save = SaveData.newGame()
check(runScript(declines), "chairman script completes on NO")
shownIs({ "_PokemonFanClubChairmanIntroText", "_PokemonFanClubNoStoryText" },
        "NO skips the story and the gift (#1050)")
eq(held("BIKE_VOUCHER"), 0, "declining leaves the voucher unclaimed")
check(not Flags.get(Game.save, "EVENT_RECEIVED_BIKE_VOUCHER"),
      "declining leaves the event clear, so he can be asked again")

-- === 3) asking again after NO still works, and YES then pays out ===
check(runScript(), "second visit completes")
shownIs({ "_PokemonFanClubChairmanIntroText",
          "_PokemonFanClubChairmanStoryText",
          "_PokemonFanClubReceivedBikeVoucherText",
          "_PokemonFanClubExplainBikeVoucherText" },
        "a player who said NO can come back for the voucher")
eq(held("BIKE_VOUCHER"), 1, "the voucher arrives on the second visit")

-- === 4) served player: .nothingleft, no question at all ===
check(runScript(), "post-voucher script completes")
shownIs({ "_PokemonFanClubChairFinalText" },
        "with the voucher collected he only reminisces")
eq(held("BIKE_VOUCHER"), 1, "no second voucher")

Commands.show_text = origShow
S.finish()

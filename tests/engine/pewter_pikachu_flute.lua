-- ROM-free regression for Yellow's sleeping-Pikachu Poké Flute path. The
-- item effect must select the special result, and the bag must clear the
-- scene only after its message finishes.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
love = require("tests.love_stub")

local pika = { cellX = 5, cellY = 6 }
package.loaded["src.world.PikachuFollower"] = {
  current = function() return pika end,
}

local ItemEffects = require("src.inventory.ItemEffects")
local data = {
  items = { POKE_FLUTE = { name = "POKé FLUTE" } },
  text = {
    _PlayedFluteHadEffectText = "{PLAYER} played the\nPOKé FLUTE.",
  },
}
local save = {
  player = { name = "RED" }, party = {}, flags = {}, options = {},
  inventory = { POKE_FLUTE = 1 }, bagOrder = { "POKE_FLUTE" }, money = 0,
}
local overworld = {
  map = { id = "PEWTER_POKECENTER" },
  player = { cellX = 5, cellY = 5 },
  pikachuPewterSleepScene = true,
}

local result, messages = ItemEffects.use(
  data, save, "POKE_FLUTE", nil, nil, nil, overworld)
T.eq(result, "flute_wake_pikachu",
     "an adjacent sleeping follower selects the special flute result")
T.eq(#messages, 1, "the special result carries one message")

local Sound = require("src.core.Sound")
local realPlay = Sound.play
local played
Sound.play = function(_data, id) played = id end

local stack = { states = {} }
function stack:push(state) self.states[#self.states + 1] = state end
function stack:pop()
  local state = self.states[#self.states]
  self.states[#self.states] = nil
  return state
end
function stack:top() return self.states[#self.states] end

local game = {
  data = data, save = save, overworld = overworld, stack = stack,
  input = { wasPressed = function() return false end,
            isDown = function() return false end },
}
local BagMenu = require("src.ui.BagMenu")
local bag = BagMenu.new(game)
stack:push(bag)
bag.onChoose(bag.items[1], bag)
local useToss = stack:top()
T.check(useToss and useToss.items and useToss.items[1],
        "the Poké Flute opens its USE/TOSS menu")
stack:pop()
useToss.items[1].onSelect()
local box = stack:top()
T.eq(played, "Pokeflute", "the special bag path plays the flute cue")
T.eq(overworld.pikachuPewterSleepScene, true,
     "the sleep scene stays active while the message is open")
T.check(box and type(box.onDone) == "function",
        "the special message has a completion callback")
box.onDone()
T.eq(overworld.pikachuPewterSleepScene, nil,
     "the completion callback clears the sleep scene")

Sound.play = realPlay
T.finish("pewter_pikachu_flute")

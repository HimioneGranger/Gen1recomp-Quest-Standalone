-- Contextual Gen 1 bicycle and fishing actions use the public world contract
-- while the engine keeps ownership of field-item rules and presentation.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness").suite("mod world field items")

local facingWater = false
local redWorld = {
  isOverworld = true,
  map = { id = "ROUTE_1", def = { tileset = "OVERWORLD" } },
  player = { moving = false, inputLocked = false, surfing = false },
  runner = { isRunning = function() return false end },
  scriptMoves = {},
  bikeAllowed = function() return true end,
  facingIsShoreOrWater = function() return facingWater end,
  useBicycle = function(self) self.bikeUsed = true return true end,
  useFishingRod = function(self, rod) self.rodUsed = rod return true end,
}
local redGame = {
  data = { items = { OLD_ROD = { name = "OLD ROD" } } },
  save = { player = { name = "RED" }, party = {},
    inventory = { BICYCLE = 1, OLD_ROD = 1 } },
  stack = { states = { redWorld } },
  overworld = redWorld,
}
function redGame.stack:top() return self.states[#self.states] end

local RedAPI = require("src.world.WorldAPI")
local red = RedAPI.new(redGame, "fixture")
local RedWorld = require("src.world.OverworldController")
T.check(type(RedWorld.useBicycle) == "function"
    and type(RedWorld.useFishingRod) == "function",
  "Gen 1 keeps field-item execution in its world")
local actions = red:availableFieldActions()
T.eq(actions[1].id, "bicycle", "Gen 1 lists an owned usable bicycle")
T.check(red:useFieldAction("bicycle"), "Gen 1 accepts the listed bicycle")
T.check(redWorld.bikeUsed, "the facade delegates to the world bicycle path")

facingWater = true
actions = red:availableFieldActions()
T.eq(actions[2].rods[1].id, "OLD_ROD", "Gen 1 lists owned rods at water")
T.check(red:useFieldAction("fish", { rod = "OLD_ROD" }),
  "Gen 1 accepts a listed rod")
T.eq(redWorld.rodUsed, "OLD_ROD", "the facade delegates to the fishing path")
local used = redWorld.rodUsed
local ok, err = red:useFieldAction("fish", { rod = "SUPER_ROD" })
T.check(not ok and err == "fishing rod unavailable",
  "Gen 1 rejects an unowned rod")
T.eq(redWorld.rodUsed, used, "a rejected rod changes nothing")

redWorld.player.moving = true
T.eq(#red:availableFieldActions(), 0, "Gen 1 hides actions while moving")
ok, err = red:useFieldAction("bicycle")
T.check(not ok and err == "world is busy",
  "Gen 1 refuses a stale action while busy")

T.finish()

-- Contextual Gen 1 actions use the public world contract while the engine
-- keeps ownership of field-item and field-move rules and presentation.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness").suite("mod world field actions")

local facingWater = false
local redCut, redSurf = false, "no_water"
local redMoves = {}
local redWorld = {
  isOverworld = true,
  map = { id = "ROUTE_1", def = { tileset = "OVERWORLD" } },
  player = { moving = false, inputLocked = false, surfing = false },
  runner = { isRunning = function() return false end },
  scriptMoves = {},
  bikeAllowed = function() return true end,
  facingIsShoreOrWater = function() return facingWater end,
  useCutFieldMove = function() return redCut and "ok" or "nothing" end,
  useSurfFieldMove = function() return redSurf end,
  partyKnows = function(_, move) return redMoves[move] end,
  useBicycle = function(self) self.bikeUsed = true return true end,
  useFishingRod = function(self, rod) self.rodUsed = rod return true end,
}
local redGame = {
  data = { field = { outsideTilesets = { "OVERWORLD" } },
    items = { OLD_ROD = { name = "OLD ROD" } } },
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
    and type(RedWorld.useFishingRod) == "function"
    and type(RedWorld.useFlashFieldMove) == "function"
    and type(RedWorld.useStrengthFieldMove) == "function"
    and type(RedWorld.stopSurfing) == "function",
  "Gen 1 keeps field-action execution in its world")
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

redWorld.player.moving = false
facingWater, redCut, redSurf = false, true, "ok"
redWorld.dark = true
for _, move in ipairs({ "STRENGTH", "FLASH", "TELEPORT" }) do
  redMoves[move] = { species = "MEW", moves = { { id = move } } }
end
redWorld.player.facingCell = function() return 4, 5 end
redWorld.tryCut = function(self) self.cutUsed = true return true end
redWorld.trySurf = function(self) self.surfUsed = true end
redWorld.useStrengthFieldMove = function(self)
  self.strengthUsed = true return true
end
redWorld.useFlashFieldMove = function(self)
  self.flashUsed = true return true
end
redWorld.beginTeleportOut = function(self) self.teleportUsed = true end
actions = red:availableFieldActions()
local byId = {}
for _, action in ipairs(actions) do byId[action.id] = action end
T.check(byId.cut and byId.surf and byId.strength and byId.flash
    and byId.teleport, "Gen 1 lists field moves that can start now")
for _, id in ipairs({ "cut", "surf", "strength", "flash", "teleport" }) do
  T.check(red:useFieldAction(id), "Gen 1 accepts listed " .. id)
end
T.check(redWorld.cutUsed and redWorld.surfUsed and redWorld.strengthUsed
    and redWorld.flashUsed and redWorld.teleportUsed,
  "Gen 1 delegates every move to its overworld path")

redSurf = "dismount"
redWorld.player.surfing = true
redWorld.stopSurfing = function(self) self.dismounted = true end
T.check(red:useFieldAction("surf") and redWorld.dismounted,
  "Gen 1 delegates the contextual SURF dismount")
redWorld.player.surfing, redSurf = false, "ok"

redCut = false
ok, err = red:useFieldAction("cut")
T.check(not ok and err == "field action unavailable",
  "Gen 1 revalidates a stale field move")

redWorld.map.id = "ROCK_TUNNEL_1F"
redWorld.map.def.tileset = "CAVERN"
redMoves.DIG = { species = "MEW", moves = { { id = "DIG" } } }
redWorld.beginTeleportOut = function(self) self.digUsed = true end
byId = {}
for _, action in ipairs(red:availableFieldActions()) do byId[action.id] = action end
T.check(byId.dig and not byId.teleport,
  "Gen 1 distinguishes dungeon DIG from outdoor TELEPORT")
T.check(red:useFieldAction("dig") and redWorld.digUsed,
  "Gen 1 delegates DIG to its escape path")

T.finish()

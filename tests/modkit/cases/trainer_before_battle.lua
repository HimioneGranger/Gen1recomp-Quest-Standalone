-- A sandboxed mod can defer an ordinary trainer engagement and later resume
-- it with a battle-local player-party scope, using only public mod surfaces.

package.path = "./?.lua;./?/init.lua;" .. package.path
love = love or require("tests.love_stub")

local T = require("tests.modkit")
local OW = require("src.world.OverworldController")

local FIXTURE = {
  ["mods/scope_probe/manifest.json"] = [[{
    "id": "scope_probe", "name": "Scope Probe", "version": "1.0.0",
    "entry": "main.lua", "api": 2
  }]],
  ["mods/scope_probe/main.lua"] = [[
    local mod = ...
    mod.hooks:wrap("trainer.before_battle", function(next, game, context, continue)
      mod.exports.game = game
      mod.exports.context = context
      mod.exports.continue = continue
      return true
    end)
  ]],
}

local vanilla = T.sdk.loadNone({})
local vanillaCalls, vanillaOptions = 0
OW.prepareTrainerBattle({ id = "game" }, {
  trainerClass = "OPP_FIX_YOUNGSTER", partyIndex = 1,
  mapId = "FIX_ROUTE", npcId = "TRAINER_1",
}, function(options)
  vanillaCalls, vanillaOptions = vanillaCalls + 1, options
end)
T.eq(vanillaCalls, 1, "no mod starts the trainer battle exactly once")
T.eq(vanillaOptions, nil, "no mod supplies no battle-local party scope")
vanilla.release()

local run = T.sdk.loadMods({ "mods/scope_probe" }, {
  fs = T.sdk.memfs(FIXTURE),
})
T.eq(#run.errors, 0,
  "the public preparation probe loads clean (" .. tostring(run.errors[1]) .. ")")
local game = { id = "live-game" }
local calls, options = 0
OW.prepareTrainerBattle(game, {
  trainerClass = "OPP_FIX_YOUNGSTER", partyIndex = 2,
  mapId = "FIX_ROUTE", npcId = "TRAINER_7",
}, function(value)
  calls, options = calls + 1, value
end)
T.eq(calls, 0, "a claiming public hook defers battle construction")
local out = run.loader.exports.scope_probe or {}
T.check(out.game == game, "the hook receives the live game")
T.same(out.context, {
  trainerClass = "OPP_FIX_YOUNGSTER", partyIndex = 2,
  mapId = "FIX_ROUTE", npcId = "TRAINER_7",
}, "the hook receives data-only trainer identity context")
T.eq(out.continue({ playerPartyIndices = { 2, 4 } }), true,
  "the retained continuation resumes the deferred battle")
T.eq(calls, 1, "resume constructs the battle exactly once")
T.same(options, { playerPartyIndices = { 2, 4 } },
  "ordered eligible indices cross the public seam unchanged")
T.eq(out.continue({ playerPartyIndices = { 1 } }), false,
  "the continuation refuses a second invocation")
T.eq(calls, 1, "a duplicate resume cannot start a second battle")
run.release()

local cancelRun = T.sdk.loadMods({ "mods/scope_probe" }, {
  fs = T.sdk.memfs(FIXTURE),
})
local starts, cancels = 0, 0
OW.prepareTrainerBattle(game, {
  trainerClass = "OPP_FIX_YOUNGSTER", partyIndex = 2,
  mapId = "FIX_ROUTE", npcId = "TRAINER_7",
}, function()
  starts = starts + 1
end, function()
  cancels = cancels + 1
end)
local cancelOut = cancelRun.loader.exports.scope_probe or {}
T.eq(cancelOut.continue({ cancel = true }), true,
  "the retained continuation can cancel a deferred encounter")
T.eq(starts, 0, "cancelling never constructs a trainer battle")
T.eq(cancels, 1, "cancelling invokes the encounter's completion callback")
T.eq(cancelOut.continue(), false,
  "a cancelled continuation remains one-shot")
cancelRun.release()

T.finish("trainer_before_battle")

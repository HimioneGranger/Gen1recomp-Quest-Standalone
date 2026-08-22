-- ROM-free Gen 1 contract for the public battle.charge_required hook.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local BattleState = require("src.battle.BattleState")
local Font = require("src.render.Font")
local Pokemon = require("src.pokemon.Pokemon")
local Runtime = require("src.mods.Runtime")
local SaveData = require("src.core.SaveData")
local TypeChart = require("src.battle.TypeChart")

local function data()
  local d = T.fixtures.fresh()
  d.moves.SOLARBEAM = { id = "SOLARBEAM", index = 80, name = "SOLARBEAM", type = "GRASS", power = 120, accuracy = 100, pp = 10, effect = "CHARGE_EFFECT" }
  d.moves.FLY = { id = "FLY", index = 81, name = "FLY", type = "FLYING", power = 70, accuracy = 95, pp = 15, effect = "FLY_EFFECT" }
  Font.load(d)
  TypeChart.load(d)
  return d
end

local function battle(d, id)
  local save = SaveData.newGame()
  save.party = { Pokemon.new(d, "FIXMON_A", 30) }
  local move = { id = id, pp = 10, maxPp = 10 }
  save.party[1].moves = { move }
  local stack = { states = {} }
  function stack:push(state) self.states[#self.states + 1] = state end
  function stack:pop() return table.remove(self.states) end
  function stack:top() return self.states[#self.states] end
  local game = { data = d, save = save, stack = stack, input = { wasPressed = function() return false end, isDown = function() return false end } }
  local b = BattleState.newWild(game, "FIXMON_B", 20)
  b.rng = function() return 0 end
  return b, b.player, b.enemy, move
end

do
  local b, user, target, move = battle(data(), "SOLARBEAM")
  local oldWants, oldCall = Runtime.wantsHook, Runtime.call
  Runtime.wantsHook = function(name) T.eq(name, "battle.charge_required", "guard checks hook name"); return false end
  Runtime.call = function() error("unsubscribed hook dispatched", 0) end
  local hp = target.mon.hp
  local ok, err = pcall(b.performMove, b, user, target, move)
  T.check(ok, "unsubscribed charge path remains safe: " .. tostring(err))
  T.eq(target.mon.hp, hp, "SolarBeam still charges without a mod")
  T.eq(user.charging, move, "vanilla charge continuation remains")
  T.eq(move.pp, 9, "vanilla charge spends one PP")
  Runtime.wantsHook, Runtime.call = oldWants, oldCall
end

local FILES = {
  ["mods/charge_probe/manifest.json"] = [[{"id":"charge_probe","name":"Charge Probe","version":"1.0.0","entry":"main.lua","api":2,"games":["all"]}]],
  ["mods/charge_probe/main.lua"] = [[local mod = ...
mod.hooks:wrap("battle.charge_required", function(nextFn, ctx)
  mod.exports.calls = (mod.exports.calls or 0) + 1
  mod.exports.called = ctx.isCalled
  if ctx.move.id == "SOLARBEAM" then return false end
  return nextFn(ctx)
end)]],
}

do
  local run = T.sdk.loadMods({ "mods/charge_probe" }, { fs = T.sdk.memfs(FILES) })
  T.eq(#run.errors, 0, "charge hook mod loads")
  local b, user, target, move = battle(data(), "SOLARBEAM")
  local hp = target.mon.hp
  b:performMove(user, target, move)
  T.check(target.mon.hp < hp, "mod can resolve SolarBeam on its first turn")
  T.eq(user.charging, nil, "hook bypass creates no continuation")
  T.eq(move.pp, 9, "hook bypass spends one PP")
  local out = run.loader.exports.charge_probe
  T.eq(out.calls, 1, "hook runs once on an initial charge move")
  T.eq(out.called, false, "ordinary move reports isCalled false")
  b, user, target, move = battle(data(), "FLY")
  b:performMove(user, target, move, true)
  T.eq(user.charging, move, "next(ctx) retains Fly's charge state")
  T.eq(out.called, true, "called charge move reports isCalled true")
  run.release()
end

T.finish("battle charge required")

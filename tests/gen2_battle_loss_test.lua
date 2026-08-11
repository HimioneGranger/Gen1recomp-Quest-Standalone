-- Losing a trainer battle must END the script.
--
--   luajit tests/gen2_battle_loss_test.lua
--
-- Found by the Gold route bot (tests/drivers/gold_bot.lua), which lost to
-- Whitney's MILTANK with its whole party fainted and was handed
-- EVENT_BEAT_WHITNEY anyway.  Chased down, the same run had cleared four Elite
-- Four rooms and reached the Hall of Fame with two Pokemon.
--
-- Every trainer script in the game has the same three lines:
--
--   startbattle
--   reloadmapafterbattle
--   setevent EVENT_BEAT_<whoever>
--
-- and on the cart the middle one does not come back after a loss.
-- Script_reloadmapafterbattle (engine/overworld/scripting.asm:1080) reads
-- wBattleResult, and on LOSE does `ScriptJump Script_BattleWhiteout` -- which
-- replaces the running script rather than returning to it, so the `setevent`
-- below it never happens.  The port fell straight through, so a loss ran the
-- win branch of every leader, rival and Elite Four script in Johto and Kanto.
--
-- The whiteout half (heal, halve the money, warp to the spawn point) is
-- World's, and was already right; what is asserted here is only that the
-- script stops.
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 battle loss")
local check, eq = S.check, S.eq

local Vm = require("src.script.gen2.Vm")
local Events = require("src.world.gen2.Events")

-- A gym leader's script, in the shape maps/GoldenrodGym.asm writes it.
local function gymScripts()
  return {
    generation = 2,
    ["s:leader"] = {
      { op = "loadtrainer", class = 1, member = 1 },
      { op = "startbattle" },
      { op = "reloadmapafterbattle" },
      { op = "setevent", event = 100 },
      { op = "scall", script = "s:givebadge" },
      { op = "end" },
    },
    -- The badge itself lives behind a scall, which is why a loss that falls
    -- through leaves the flags and the badges disagreeing.
    ["s:givebadge"] = {
      { op = "setevent", event = 101 },
      { op = "end" },
    },
  }
end

local function run(outcome)
  local events = Events.new()
  local reloads = 0
  local vm = Vm.new(gymScripts(), {}, events, {
    startBattle = function(_, _wild, onDone) onDone(outcome) end,
    reloadMap = function() reloads = reloads + 1 end,
  })
  check(vm:start("s:leader"), "leader script starts (" .. outcome .. ")")
  for _ = 1, 20 do vm:update() end
  return events, reloads, vm
end

-- Winning runs the whole script, exactly as before.
do
  local events, reloads = run("win")
  eq(events:get(100), true, "a win sets the leader's beaten flag")
  eq(events:get(101), true, "a win reaches the badge scall below it")
  eq(reloads, 1, "a win still reloads the map")
end

-- Losing stops at reloadmapafterbattle.
do
  local events, reloads = run("lose")
  eq(events:get(100), false, "a loss does NOT set the leader's beaten flag")
  eq(events:get(101), false, "a loss does not reach the badge scall either")
  eq(reloads, 1, "a loss still reloads the map (Script_BattleWhiteout does)")
end

-- The abort is per-run: the next script must start clean, or one wipe would
-- silently disable every script for the rest of the session.
do
  local events = Events.new()
  local vm = Vm.new(gymScripts(), {}, events, {
    startBattle = function(_, _wild, onDone) onDone("lose") end,
    reloadMap = function() end,
  })
  vm:start("s:leader")
  for _ = 1, 20 do vm:update() end
  eq(events:get(100), false, "the lost battle aborted its script")

  local second = {
    generation = 2,
    ["s:after"] = { { op = "setevent", event = 200 }, { op = "end" } },
  }
  local vm2 = Vm.new(second, {}, events, {})
  vm2:start("s:after")
  for _ = 1, 5 do vm2:update() end
  eq(events:get(200), true, "a later script is unaffected by the earlier loss")

  -- Same VM, second run: the flag has to be cleared by Vm:start, not by luck.
  local vm3 = Vm.new({
    generation = 2,
    ["s:leader"] = gymScripts()["s:leader"],
    ["s:givebadge"] = gymScripts()["s:givebadge"],
  }, {}, events, {
    startBattle = function(_, _wild, onDone) onDone("win") end,
    reloadMap = function() end,
  })
  vm3:start("s:leader")
  for _ = 1, 20 do vm3:update() end
  eq(events:get(100), true, "the rematch, won, sets the flag")
end



-- ---------------------------------------------------------------------------
-- An EGG is not a battler.
--
-- Same session, same bot: carrying the Togepi egg meant Battle.firstHealthy
-- answered with the egg, so the wipe check never fired while the egg was
-- intact and the game sent an egg out against Morty's Gengar -- twice, dying
-- instantly each time, before the only mon that could fight got a turn.  With
-- the switch menu correctly refusing it, an all-fainted party plus an egg then
-- had no answer at all and the battle hung.  The cart refuses eggs on both
-- sides of that: they cannot be sent out, and they do not stop a whiteout.
local Battle = require("src.battle.gen2.Battle")

eq(Battle.firstHealthy({ { hp = 0 }, { hp = 12 } }), 2,
   "the first mon with HP is chosen")
eq(Battle.firstHealthy({ { hp = 0 }, { hp = 12, isEgg = true } }), nil,
   "an egg is not a replacement, so this party is wiped")
eq(Battle.firstHealthy({ { hp = 20, isEgg = true }, { hp = 12 } }), 2,
   "an egg in front is skipped rather than sent out")
eq(Battle.firstHealthy({ { hp = 20, isEgg = true } }), nil,
   "a party of nothing but an egg cannot fight")

S.finish()

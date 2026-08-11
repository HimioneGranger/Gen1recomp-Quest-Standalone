-- BATTLETYPE_FORCESHINY: the Lake of Rage Gyarados must come out SHINY and
-- must not be run from.
--
--   GOLD_CACHE=".../gold" luajit tests/gen2_forceshiny_test.lua
--
-- maps/LakeOfRage.asm arms the fight with
--
--   loadwildmon GYARADOS, 30
--   loadvar VAR_BATTLETYPE, BATTLETYPE_FORCESHINY
--   startbattle
--
-- and InitEnemyMon's `.NotRoaming` arm (engine/battle/core.asm:5876)
-- answers the type by replacing the rolled DVs with ATKDEFDV_SHINY $EA /
-- SPDSPCDV_SHINY $AA -- Attack 14, Defense/Speed/Special 10, the classic
-- shiny pattern.  TryToRunAwayFromBattle:3469 jumps straight to
-- .cant_escape for the same type, so the one-shot encounter cannot be
-- forfeited by RUN returning a WIN to the RedGyarados script.  What is
-- asserted here is the REAL World:startScriptedBattle -> World:startBattle
-- chain with the type armed the way Script_loadvar arms it.

package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 forceshiny")
local check, eq = S.check, S.eq

local World = require("src.world.gen2.World")
local Map = require("src.world.gen2.Map")
local Mon = require("src.battle.gen2.Mon")

-- ---- the latest load command decides what startbattle fights --------------
-- Script_loadwildmon rewrites wBattleScriptFlags to the wild shape, erasing
-- the trainer bit Script_loadtemptrainer set.  The port's VM lives as long
-- as the World, so a trainer record left by an earlier script (any sight
-- trainer fought on the way to the lake) must not shadow `loadwildmon` --
-- with the stale record, pressing A on the Red Gyarados refought the last
-- trainer instead of starting the FORCESHINY encounter at all.  ROM-free,
-- so it runs even without the cache below.
do
  local Vm = require("src.script.gen2.Vm")
  local Events = require("src.world.gen2.Events")
  local fought = {}
  local vm = Vm.new({
    ["s:trainer"] = {
      { op = "loadtemptrainer" },
      { op = "startbattle" },
      { op = "end" },
    },
    ["s:gyarados"] = {
      { op = "loadwildmon", species = 130, level = 30 },
      { op = "loadvar", args = { 3, 7 } },
      { op = "startbattle" },
      { op = "end" },
    },
  }, {}, Events.new(), {
    lookupTrainer = function() return { class = "POKEMANIAC", id = 1 } end,
    startBattle = function(trainer, wild, onDone)
      fought[#fought + 1] = { trainer = trainer, wild = wild }
      onDone("win")
    end,
  })
  vm.trainerObject = { class = "POKEMANIAC", member = 1 }
  check(vm:start("s:trainer"), "the trainer script starts")
  for _ = 1, 20 do vm:update() end
  check(fought[1] and fought[1].trainer ~= nil, "and fights its trainer")

  check(vm:start("s:gyarados"), "the wild script starts on the same VM")
  for _ = 1, 20 do vm:update() end
  check(fought[2] ~= nil, "and reaches its own startbattle")
  eq(fought[2] and fought[2].trainer, nil,
    "loadwildmon erased the stale trainer record")
  eq(fought[2] and fought[2].wild and fought[2].wild.species, 130,
    "so the wild GYARADOS is what gets fought")
end

local cache = os.getenv("GOLD_CACHE")
if not cache then
  local home = os.getenv("HOME") or ""
  cache = home .. "/Library/Application Support/LOVE/gold-dev/gold"
end
local probe = io.open(cache .. "/data/generated/maps.lua", "r")
if not probe then
  check(true, "gold cache absent (SKIP)")
  S.finish()
  return
end
probe:close()

local function loadLua(rel) return assert(loadfile(cache .. "/" .. rel))() end
local maps = loadLua("data/generated/maps.lua")
local tilesets = loadLua("data/generated/tilesets.lua")
local pokemon = loadLua("data/generated/pokemon.lua")
local moves = loadLua("data/generated/moves.lua")

-- constants/battle_constants.asm / engine/overworld/variables.asm.
local VAR_BATTLETYPE = 0x03
local BATTLETYPE_FORCESHINY = 7
local GYARADOS_INDEX = 130

-- The two battle screens as registry fakes: the transition hands off
-- immediately, the battle parks its Battle instance for the assertions.
local battleDone, builtBattle
local registry = {
  Gen2BattleTransition = { new = function(_g, opts)
    opts.onDone()
    return { screenId = "Gen2BattleTransition" }
  end },
  Gen2BattleState = { new = function(_g, opts)
    battleDone = opts.onDone
    builtBattle = opts.battle
    return { screenId = "Gen2BattleState" }
  end },
}

local function makeStack()
  local stack = { items = {} }
  function stack:push(inst) self.items[#self.items + 1] = inst end
  function stack:pop()
    local top = self.items[#self.items]
    self.items[#self.items] = nil
    return top
  end
  return stack
end

local function makeWorld()
  battleDone, builtBattle = nil, nil
  local game = {
    data = { audio = {}, screens = registry, pokemon = pokemon,
      moves = moves },
    save = {
      player = { name = "GOLD", money = 3000 },
      party = {},
      blackoutMap = "MAHOGANY_POKECENTER_1F",
    },
    stack = makeStack(),
  }
  local mine = Mon.new(game.data, "CYNDAQUIL", 30)
  check(mine ~= nil, "the cache can build the player's mon")
  game.save.party[1] = mine
  local w = World.new(game)
  w.maps, w.tilesets = maps, tilesets
  w.map = Map.new(maps.LAKE_OF_RAGE, tilesets[maps.LAKE_OF_RAGE.tileset])
  w.player = { cellX = 20, cellY = 20, facing = "up", moving = false }
  return w, game
end

-- ---- the armed type forces the shiny DV pattern ---------------------------
do
  local w = makeWorld()
  -- Script_loadvar's write, exactly as the extracted RedGyarados script
  -- (49:4f6f) runs it ahead of `startbattle`.
  w:writeVar(VAR_BATTLETYPE, BATTLETYPE_FORCESHINY)
  eq(w:battleType(), BATTLETYPE_FORCESHINY, "the type is armed")

  check(w:startScriptedBattle(nil, { species = GYARADOS_INDEX, level = 30 },
    function() end), "the scripted battle starts")
  check(builtBattle ~= nil, "the battle screen got the Battle instance")
  local wild = builtBattle.enemy
  eq(wild.species, "GYARADOS", "the wild mon is the GYARADOS")
  eq(wild.level, 30, "at level 30")
  eq(wild.dvs.attack, 14, "ATKDEFDV_SHINY $EA: Attack DV 14")
  eq(wild.dvs.defense, 10, "Defense DV 10")
  eq(wild.dvs.speed, 10, "SPDSPCDV_SHINY $AA: Speed DV 10")
  eq(wild.dvs.special, 10, "Special DV 10")
  eq(wild.shiny, true, "and the mon IS shiny")
  eq(Mon.isShiny(wild.dvs), true,
    "shininess survives a re-read of the DVs, so a catch keeps it")

  -- The battle got the type, and RUN is refused before any speed math.
  eq(builtBattle.battleType, BATTLETYPE_FORCESHINY,
    "opts.battleType reached Battle.new")
  eq(builtBattle:tryRun(), false,
    "TryToRunAwayFromBattle's .cant_escape arm for the type")
  eq(builtBattle.over, false, "the encounter is still live after RUN")
  eq(w:battleType(), 0, "the var is a one-shot, consumed on the way in")
  battleDone("win")
end

-- ---- without the type: an ordinary blue Gyarados that can be fled ---------
do
  local w = makeWorld()
  eq(w:battleType(), 0, "no type armed")
  check(w:startScriptedBattle(nil, { species = GYARADOS_INDEX, level = 30 },
    function() end), "the plain battle starts")
  eq(builtBattle.battleType, 0, "no battle type handed over")
  check(builtBattle.enemy.dvs ~= nil, "the DVs exist")
  -- One in 8192 runs would roll shiny DVs honestly; assert the FORCED
  -- pattern is not simply stamped on everything.
  local dvs = builtBattle.enemy.dvs
  local forced = dvs.attack == 14 and dvs.defense == 10
    and dvs.speed == 10 and dvs.special == 10
  check(not forced or Mon.isShiny(dvs),
    "unforced DVs are random, not the shiny constant")
  battleDone("win")
end

S.finish()

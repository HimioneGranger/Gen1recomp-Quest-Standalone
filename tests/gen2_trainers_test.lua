-- Gen 2 overworld trainers: the eyesight test, the approach path, the party
-- build, and the VM's half of engine/events/trainer_scripts.asm.
--   luajit tests/gen2_trainers_test.lua
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 trainers")
local check, eq = S.check, S.eq

love = require("tests.love_stub")

local Movement = require("src.script.gen2.Movement")
local Trainers = require("src.world.gen2.Trainers")
local Events = require("src.world.gen2.Events")
local Vm = require("src.script.gen2.Vm")

-- ---- FacingPlayerDistance (home/trainers.asm) -----------------------------
local function at(x, y, facing)
  return { cellX = x, cellY = y, facing = facing }
end

local npc = at(5, 5, "down")
eq(Trainers.sees(npc, at(5, 8), 4), 3, "3 cells below, facing down, sight 4")
eq(select(2, Trainers.sees(npc, at(5, 8), 4)), "down", "direction is down")
check(not Trainers.sees(npc, at(5, 10), 4), "5 cells away is past sight 4")
eq(Trainers.sees(npc, at(5, 9), 4), 4, "exactly sight 4 still sees")
check(not Trainers.sees(npc, at(5, 2), 4), "facing down does not see upward")
check(not Trainers.sees(npc, at(6, 8), 4), "off the column is not seen")
check(not Trainers.sees(npc, at(5, 5), 4), "standing on the trainer is not seen")
check(not Trainers.sees(npc, at(5, 6), 0), "sight 0 never sees")

local sideways = at(5, 5, "left")
eq(Trainers.sees(sideways, at(3, 5), 3), 2, "2 cells left, facing left")
eq(select(2, Trainers.sees(sideways, at(3, 5), 3)), "left", "direction is left")
check(not Trainers.sees(sideways, at(7, 5), 3), "facing left does not see right")

-- ---- TrainerWalkToPlayer --------------------------------------------------
eq(#Trainers.approach(1, "down"), 0, "spotted from 1 cell away: no walk")
eq(#Trainers.approach(4, "down"), 3, "spotted from 4 cells away: 3 steps")
eq(Trainers.approach(3, "up")[1], "up", "approach walks along the sight line")
eq(Movement.stepByte("down"), 0x0c, "step down byte")
eq(Movement.stepByte("up"), 0x0d, "step up byte")
eq(Movement.stepByte("left"), 0x0e, "step left byte")
eq(Movement.stepByte("right"), 0x0f, "step right byte")
eq(Movement.decodeByte(Movement.stepByte("right")).dir, "right",
  "stepByte round-trips through decodeByte")

-- ---- class lookup + party build -------------------------------------------
local data = {
  moves = {
    TACKLE = { pp = 35, power = 35, type = "NORMAL" },
    GUST = { pp = 35, power = 40, type = "FLYING" },
  },
  pokemon = {
    PIDGEY = {
      name = "PIDGEY", types = { "NORMAL", "FLYING" }, growthRate = "MEDIUM_SLOW",
      baseStats = { hp = 40, attack = 45, defense = 40, speed = 56,
        specialAttack = 35, specialDefense = 35 },
      levelMoves = { { level = 1, move = "TACKLE" } },
    },
    RATTATA = {
      name = "RATTATA", types = { "NORMAL" }, growthRate = "MEDIUM_FAST",
      baseStats = { hp = 30, attack = 56, defense = 35, speed = 72,
        specialAttack = 25, specialDefense = 35 },
      levelMoves = { { level = 1, move = "TACKLE" } },
    },
  },
  trainers = {
    classes = {
      YOUNGSTER = {
        index = 22, name = "YOUNGSTER", baseMoney = 20,
        trainers = {
          { index = 1, id = "JOEY1", name = "JOEY",
            trainerType = "TRAINERTYPE_NORMAL",
            party = { { species = "RATTATA", level = 4 } } },
        },
      },
      FALKNER = {
        index = 1, name = "LEADER",
        trainers = {
          { index = 1, id = "FALKNER1", name = "FALKNER",
            trainerType = "TRAINERTYPE_MOVES",
            party = { { species = "PIDGEY", level = 7,
              moves = { "TACKLE", "GUST" } } } },
        },
      },
    },
  },
}

local joey = Trainers.lookup(data.trainers, 22, 1)
check(joey, "class 22 member 1 resolves")
eq(joey.name, "JOEY", "trainer name")
eq(joey.className, "YOUNGSTER", "class display name")
eq(joey.classId, "YOUNGSTER", "class key")
check(not Trainers.lookup(data.trainers, 22, 9), "member 9 does not exist")
check(not Trainers.lookup(data.trainers, 250, 1), "class 250 does not exist")

local joeyParty = Trainers.party(data, joey)
eq(#joeyParty, 1, "JOEY has one mon")
eq(joeyParty[1].species, "RATTATA", "JOEY leads with RATTATA")
eq(joeyParty[1].level, 4, "at level 4")
check(joeyParty[1].hp > 0, "with hp")
-- MakeTrainerPartyMon fixes every trainer mon's DVs, so the same trainer
-- always brings the same stats.
local again = Trainers.party(data, joey)
eq(again[1].stats.attack, joeyParty[1].stats.attack, "trainer DVs are fixed")

local falkner = Trainers.party(data, Trainers.lookup(data.trainers, 1, 1))
eq(#falkner[1].moves, 2, "TRAINERTYPE_MOVES takes the explicit move list")
eq(falkner[1].moves[2].id, "GUST", "second move is GUST")
eq(falkner[1].moves[2].pp, 35, "PP comes from moves.lua")

-- ---- trainer_scripts.asm through the VM -----------------------------------
local events = Events.new()
local texts = {
  ["t:seen"] = "Wait! Let's battle!",
  ["t:win"] = "I lost...",
  ["t:after"] = "Train harder.",
}
local scripts = {
  ["s:after"] = { { op = "writetext", text = "t:after" }, { op = "end" } },
}

local BEAT_FLAG = 1336
local record = {
  event = BEAT_FLAG, class = 22, member = 1,
  seenText = "t:seen", winText = "t:win", scriptKey = "s:after",
}

local SEEN_SCRIPT = {
  { op = "loadtemptrainer" },
  { op = "encountermusic" },
  { op = "showemote", emote = 0, object = -2, frames = 30 },
  { op = "trainerapproach" },
  { op = "opentext" },
  { op = "trainertext", index = 0 },
  { op = "waitbutton" },
  { op = "closetext" },
  { op = "loadtemptrainer" },
  { op = "startbattle" },
  { op = "reloadmapafterbattle" },
  { op = "trainerflagaction", action = 1 },
  { op = "scripttalkafter" },
}

local shown, emoted, approached, battled = {}, false, false, nil
local vm = Vm.new(scripts, texts, events, {
  showText = function(body, onDone) shown[#shown + 1] = body onDone() end,
  showEmote = function(_, object) emoted = object end,
  trainerApproach = function(onDone) approached = true onDone() end,
  encounterMusic = function() end,
  lookupTrainer = function(class, member)
    return Trainers.lookup(data.trainers, class, member)
  end,
  startBattle = function(trainer, _wild, onDone)
    battled = trainer
    onDone("win")
  end,
})

vm.trainerObject = record
check(vm:start(SEEN_SCRIPT), "an inline command list runs")
for _ = 1, 60 do vm:update() end
check(not vm:running(), "the trainer script finished")
eq(emoted, -2, "the bubble goes over LAST_TALKED")
check(approached, "the trainer walked up")
check(battled, "a battle started")
eq(battled.name, "JOEY", "the battle is against the struct's trainer")
eq(shown[1], "Wait! Let's battle!", "TRAINERTEXT_SEEN is the struct's seen text")
eq(shown[2], "Train harder.", "the after-battle script ran")
check(events:get(BEAT_FLAG), "SET_FLAG marked the trainer beaten")

-- A beaten trainer takes the CHECK_FLAG branch straight to its after script.
local TALK_SCRIPT = {
  { op = "faceplayer" },
  { op = "trainerflagaction", action = 2 },
  { op = "iftrue", script = { { op = "scripttalkafter" } } },
  { op = "loadtemptrainer" },
  { op = "startbattle" },
  { op = "end" },
}
shown, battled = {}, nil
vm.trainerObject = record
check(vm:start(TALK_SCRIPT), "talk-to-trainer runs")
for _ = 1, 60 do vm:update() end
check(not vm:running(), "talk script finished")
check(not battled, "a beaten trainer does not battle again")
eq(shown[1], "Train harder.", "a beaten trainer says its after-battle line")

-- winlosstext overrides the struct's win text for one battle.
local WINLOSS_SCRIPT = {
  { op = "winlosstext", winText = "t:win" },
  { op = "trainertext", index = 1 },
  { op = "end" },
}
shown = {}
vm.trainerObject = { event = BEAT_FLAG, class = 22, member = 1 }
check(vm:start(WINLOSS_SCRIPT), "winlosstext script runs")
for _ = 1, 10 do vm:update() end
eq(shown[1], "I lost...", "trainertext 1 reads the winlosstext override")

-- endifjustbattled stops an after-battle script from re-running its intro.
local JUSTBATTLED_SCRIPT = {
  { op = "loadtemptrainer" },
  { op = "startbattle" },
  { op = "endifjustbattled" },
  { op = "writetext", text = "t:seen" },
  { op = "end" },
}
shown = {}
vm.trainerObject = record
check(vm:start(JUSTBATTLED_SCRIPT), "justbattled script runs")
for _ = 1, 30 do vm:update() end
eq(#shown, 0, "endifjustbattled ended the script after the battle")

-- ---- what a scripted battle actually hands the battle screen --------------
--
-- Trainers.lookup builds the whole of the class's attributes row, but
-- World:startScriptedBattle is the only place a trainer battle is built, so a
-- field it forgets to forward is a field no trainer in the game ever has.
-- That is what happened to `attributes` and `items`: Battle's AI gate reads
-- self.trainer.attributes and gives up on a nil, and AI_TryItem walks
-- self.trainer.items, so every trainer fought with no personality and no
-- potions while both models sat there unit tested.  Driven through the real
-- World and the real screens registry rather than asserted off the source.
local World = require("src.world.gen2.World")
local Screens = require("src.ui.Screens")

local FIGHT_DATA = {
  pokemon = {
    PIDGEY = { id = "PIDGEY", name = "PIDGEY", index = 15, baseExp = 55,
      growthRate = "MEDIUM_SLOW", stats = { hp = 40, attack = 45,
        defense = 40, speed = 56, specialAttack = 35, specialDefense = 35 },
      types = { "NORMAL", "FLYING" } },
  },
  moves = {},
  -- data/trainers/attributes.asm CHAMPION, verbatim: the seven-byte row
  -- (Ai.flagsOf folds bytes 4-6 into the AI flag set, byte 3 is
  -- TRNATTR_BASE_REWARD) and the two TRNATTR_ITEM slots.  CHAMPION rather
  -- than FALKNER because Falkner's two item slots are empty, and an empty
  -- list cannot tell a dropped field from a real one.
  trainers = { classes = { CHAMPION = { id = "CHAMPION", index = 1,
    name = "CHAMPION", baseMoney = 25,
    attributes = { 38, 14, 25, 211, 3, 68, 0 },
    items = { "FULL_HEAL", "FULL_RESTORE" },
    trainers = { { id = "LANCE1", name = "LANCE",
      party = { { species = "PIDGEY", level = 7 } } } } } } },
}

Screens.invalidate()
local fought = {}
local fightGame = {
  data = {
    pokemon = FIGHT_DATA.pokemon, moves = FIGHT_DATA.moves,
    trainers = FIGHT_DATA.trainers,
    screens = {
      Gen2BattleState = function(_, opts)
        fought.opts = opts
        return { screenId = "Gen2BattleState" }
      end,
    },
  },
  save = { party = {}, player = { name = "GOLD", money = 0 } },
  stack = { push = function() end, pop = function() end },
}
local fightWorld = World.new(fightGame)
fightGame.world = fightWorld
fightWorld.map = { def = { id = "TEST_MAP" } }
fightWorld.maps = { TEST_MAP = fightWorld.map.def }
fightWorld.events = Events.new()
fightWorld.playBattleMusic = function() end
fightWorld.battleMusicContext = function() return nil end
fightWorld.pushBattleTransition = function() return nil end
fightWorld.restoreMapMusic = function() end

local champion = Trainers.lookup(FIGHT_DATA.trainers, 1, 1)
check(champion ~= nil, "the class record is found")
eq(champion.attributes and champion.attributes[4], 211,
  "and it carries the attributes row")
eq(champion.items[1], "FULL_HEAL", "and the first TRNATTR_ITEM slot")
fightWorld:startScriptedBattle(champion, nil, function() end)
check(fought.opts ~= nil, "startScriptedBattle pushes the battle screen")
-- The screen is handed the Battle, and Battle keeps the record it was built
-- with as self.trainer: that is the field the AI gate and AI_TryItem read.
local sent = fought.opts and fought.opts.battle and fought.opts.battle.trainer
  or {}
check(sent.attributes ~= nil, "the AI personality reaches the battle")
eq(sent.items and sent.items[1], "FULL_HEAL", "and so does AI_TryItem's list")
eq(sent.items and sent.items[2], "FULL_RESTORE", "both slots, in order")
eq(sent.baseMoney, 25, "the payout byte still travels beside them")
-- The copy Trainers.lookup makes is the one the battle spends, so using an
-- item up must not empty the class record for the next trainer of that class.
check(sent.items ~= FIGHT_DATA.trainers.classes.CHAMPION.items,
  "the battle spends a copy, not the class row")

-- ---- the rival's name ------------------------------------------------------
--
-- Every RIVAL1/RIVAL2 row in data/trainers/parties.asm literally stores `db
-- "?@"`, and the cart never prints it: PlaceEnemysName (home/text.asm:327),
-- which is what the <ENEMY> character resolves to, checks wTrainerClass against
-- RIVAL1 and RIVAL2 and prints wRivalName ALONE for either -- no class prefix.
-- wRivalName is what `special NameRival` wrote, defaulting SILVER on Gold.
-- Building the display name as class .. " " .. row-name announced "RIVAL ?".
fought.opts = nil
fightGame.save.rival = { name = "KAMON" }
local rival = {
  class = 2, classId = "RIVAL1", className = "RIVAL", id = "RIVAL1_1",
  name = "?", baseMoney = 15,
  roster = { { species = "PIDGEY", level = 7 } },
}
fightWorld:startScriptedBattle(rival, nil, function() end)
local rivalSent = fought.opts and fought.opts.battle
  and fought.opts.battle.trainer or {}
eq(rivalSent.name, "KAMON", "a rival battle is named from wRivalName alone")
eq(rivalSent.trainerName, "KAMON", "and so is every line that names him")
eq(rivalSent.className, "RIVAL",
  "the class key is left alone -- BattleMusic and the palettes read it")

-- A save with no rival record is a save that has not reached the officer yet,
-- so wRivalName still holds InitializeNPCNames' "???" -- NameRival's SILVER
-- default only applies once the naming screen has actually been through.  This
-- is the name the Cherrygrove theft battle prints.
fought.opts = nil
fightGame.save.rival = nil
fightWorld:startScriptedBattle(rival, nil, function() end)
eq(fought.opts and fought.opts.battle and fought.opts.battle.trainer.name,
  "???", "before NameRival runs, InitializeNPCNames' seed stands")

-- A non-rival class still gets class then name, "YOUNGSTER JOEY".
fought.opts = nil
fightWorld:startScriptedBattle(champion, nil, function() end)
eq(fought.opts and fought.opts.battle and fought.opts.battle.trainer.name,
  "CHAMPION LANCE", "and no other class loses its prefix")

S.finish()

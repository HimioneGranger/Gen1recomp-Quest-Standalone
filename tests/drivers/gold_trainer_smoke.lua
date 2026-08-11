-- Smoke: a Route 30 trainer spots the player, walks up, and battles.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_trainer_smoke.lua love .
--
-- This is the whole overworld trainer path in one run: the `trainer` struct the
-- extractor now reads off OBJECTTYPE_TRAINER objects, the eyesight test from
-- home/trainers.asm, the approach walk, the seen text, a real battle against
-- the class's extracted party, and the beat flag that stops it re-triggering.
local U = require("tests.drivers.util")

local Mon = require("src.battle.gen2.Mon")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-trainer"

  local function tap(button, frames)
    game.input.pressQueue[#game.input.pressQueue + 1] = button
    game.input.state[button] = true
    U.wait(2)
    game.input.state[button] = false
    U.wait(frames or 6)
  end

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  -- A trainer only challenges a player who has a party, the same as the cart.
  local starter = Mon.new(game.data, "CYNDAQUIL", 20)
  assert(starter, "could not build a CYNDAQUIL from pokemon.lua")
  game.save.party = { starter }

  world:setMap("ROUTE_30", 5, 33, "up")
  U.wait(20)
  assert(world.map.id == "ROUTE_30", "setMap: " .. tostring(world.map.id))

  -- Object 4 is Route 30's BUG_CATCHER, sight 3, standing at (4,7).  JOEY
  -- (object 2) is the more famous one but InitializeEventsScript hides him
  -- until the Mr. Pokemon errand, so he is not on the map yet.
  local foe
  for _, npc in ipairs(world.npcs) do
    if npc.def and npc.def.trainer and npc.def.index == 4 then foe = npc end
  end
  assert(foe, "Route 30's BUG_CATCHER object has no trainer struct")
  assert(foe.def.trainer.class == 36 and foe.def.trainer.member == 1,
    ("expected BUG_CATCHER member 1, got class %s member %s"):format(
      tostring(foe.def.trainer.class), tostring(foe.def.trainer.member)))
  assert(foe.def.sight == 3,
    "expected sight 3, got " .. tostring(foe.def.sight))
  assert(not world:trainerBeaten(foe.def.trainer), "the trainer starts beaten")

  -- Put the player in his line of sight, three cells below him, and face him
  -- down the column so the eyesight test fires on the next settled step.
  foe.facing = "down"
  world.player.cellX, world.player.cellY = foe.cellX, foe.cellY + 3
  world.player.px = world.player.cellX * 16
  world.player.py = world.player.cellY * 16

  local fired = false
  for _ = 1, 60 do
    if world:busy() then fired = true break end
    world:checkTrainerBattle()
    U.wait(1)
  end
  assert(fired, "the trainer never noticed the player")
  U.shot(game, out .. "/01-spotted.png")

  -- PlayTrainerEncounterMusic plays the CLASS's own jingle while he walks up
  -- (data/trainers/encounter_music.asm), not the battle theme; PlayBattleMusic
  -- swaps that in a moment later, when the transition starts.
  local Music = require("src.core.Music")
  local encounter = Music.current()
  print("[driver] encounter music " .. tostring(encounter))
  assert(encounter and encounter:match("^Music_Look"),
    "expected a Music_Look* encounter jingle, got " .. tostring(encounter))

  -- The bubble is up and he closes to one cell short of the player.
  local sawEmote = world.emote ~= nil
  for _ = 1, 240 do
    if world.emote then sawEmote = true end
    if game.stack:top() ~= nil and game.stack:top().battle then break end
    tap("a", 2)
  end
  assert(sawEmote, "no ! bubble was shown")
  assert(math.abs(foe.cellY - world.player.cellY) == 1,
    ("the trainer stopped %d cells away, expected 1"):format(
      math.abs(foe.cellY - world.player.cellY)))

  local battle = game.stack:top()
  assert(battle and battle.battle, "no battle screen after the seen text")
  assert(battle.battle.trainer, "battle is not a trainer battle")
  print("[driver] battle music " .. tostring(Music.current()))
  assert(Music.current() == "Music_JohtoTrainerBattle",
    "a Johto bug catcher should fight to the Johto trainer theme, got "
      .. tostring(Music.current()))
  print("[driver] fighting " .. tostring(battle.battle.trainer.name))
  assert(#battle.battle.trainer.party > 0, "trainer party is empty")
  U.shot(game, out .. "/02-battle.png")

  -- Pick a damaging move rather than slot 1: CYNDAQUIL's L20 window leads
  -- with LEER, and two attackers who cannot hurt each other never finish.
  local attackSlot = 1
  for i, move in ipairs(starter.moves) do
    local def = game.data.moves and game.data.moves[move.id]
    if def and (def.power or 0) > 0 then attackSlot = i break end
  end
  for _ = 1, 600 do
    if battle.battle.over then break end
    if battle.phase == "menu" then
      tap("a")                       -- FIGHT
      U.wait(4)
      for _ = 2, attackSlot do tap("down", 2) end
      tap("a")
    else
      tap("a", 3)
    end
  end
  assert(battle.battle.over,
    "trainer battle did not resolve (phase " .. tostring(battle.phase) .. ")")
  assert(battle.battle.outcome == "win",
    "expected the L20 starter to win, got " .. tostring(battle.battle.outcome))

  -- The after-battle text runs, then the beat flag stops the rematch.
  for _ = 1, 200 do
    if not world:busy() then break end
    tap("a", 2)
  end
  assert(not world:busy(), "the trainer script never finished")
  assert(world:trainerBeaten(foe.def.trainer),
    "the beat flag was not set after the win")
  assert(not world:checkTrainerBattle(),
    "a beaten trainer challenged the player again")
  U.shot(game, out .. "/03-after.png")

  print("[driver] PASS gold overworld trainer battle in " .. out)
end

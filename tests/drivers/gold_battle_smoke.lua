-- Smoke: a real Gold wild battle, driven end to end from the overworld.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_battle_smoke.lua love .
--
-- Starts a battle against a live extracted species with a live extracted
-- moveset, presses FIGHT until something faints, and shoots the screen along
-- the way.  This is the check that the extracted moves/pokemon/type_chart
-- actually agree with the engine -- a fixture test cannot say that.
local U = require("tests.drivers.util")

local Mon = require("src.battle.gen2.Mon")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-battle"

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

  -- `givepoke` is how the STARTER arrives, and it used to hand back a mon with
  -- an empty move list (it went through Gen 1's Pokemon.new, whose
  -- level1Moves/learnset fields the Gen 2 extractor does not write).  That is
  -- what left FIGHT with nothing in it.  Drive the VM hook directly so the
  -- check does not depend on walking the whole Elm's Lab script.
  local cyndaquilIndex = game.data.pokemon.CYNDAQUIL.index
  game.save.party = {}
  world.vm.givePokeFn(cyndaquilIndex, 5, 0)
  local gift = game.save.party[1]
  assert(gift, "givepoke put nothing in the party")
  assert(#gift.moves > 0,
    "givepoke handed over a mon with no moves -- FIGHT would be empty")
  print(("[driver] givepoke gave %s L%d with %d moves (%s)"):format(
    gift.species, gift.level, #gift.moves, gift.moves[1].id))
  assert(game.save.pokedex and game.save.pokedex.caught[gift.species],
    "givepoke did not tick the starter off in the #DEX")

  -- Give the player a real Cyndaquil built from the extracted tables, so the
  -- moveset and stats come from the cart rather than the driver.
  local player = Mon.new(game.data, "CYNDAQUIL", 12)
  assert(player, "could not build a CYNDAQUIL from pokemon.lua")
  assert(#player.moves > 0,
    "CYNDAQUIL learned no moves -- levelMoves or moves.lua is missing")
  print(("[driver] player %s L%d hp %d/%d, %d moves (%s)"):format(
    player.species, player.level, player.hp, player.maxHp, #player.moves,
    player.moves[1].id))
  game.save.party = { player }
  game.save.inventory = { POKE_BALL = 5, POTION = 3 }

  local wild = Mon.new(game.data, "PIDGEY", 4)
  assert(wild and #wild.moves > 0, "could not build a wild PIDGEY")

  local Music = require("src.core.Music")
  assert(world:startBattle({ wild = wild }), "startBattle failed")
  -- PlayBattleMusic runs before the transition, so the theme is already going
  -- while the wipe is spinning.
  print("[driver] battle music " .. tostring(Music.current()))
  assert(Music.current() == "Music_JohtoWildBattle"
      or Music.current() == "Music_JohtoWildBattleNight",
    "the wild battle did not start the Johto wild theme: "
      .. tostring(Music.current()))

  -- DoBattleTransition owns the screen first; shoot it, then wait it out.
  U.wait(4)
  U.shot(game, out .. "/00-transition.png")
  local battle
  for _ = 1, 600 do
    local top = game.stack:top()
    if top and top.battle then battle = top break end
    U.wait(1)
  end
  assert(battle and battle.battle,
    "battle screen never came up after the transition")
  U.wait(20)
  U.shot(game, out .. "/01-battle-open.png")

  -- Page through the intro messages, then attack until the battle resolves.
  for _ = 1, 120 do
    if battle.battle.over then break end
    if battle.phase == "menu" then
      U.shot(game, out .. "/02-battle-menu.png")
      tap("a")          -- FIGHT
      U.wait(4)
      U.shot(game, out .. "/03-move-list.png")
      tap("a")          -- first move
    else
      tap("a", 3)
    end
  end

  assert(battle.battle.over,
    "battle did not resolve in 120 presses (phase " .. tostring(battle.phase) .. ")")
  print("[driver] outcome " .. tostring(battle.battle.outcome))
  assert(battle.battle.outcome == "win",
    "expected the L12 starter to win, got " .. tostring(battle.battle.outcome))
  print(("[driver] player ended at %d/%d hp, exp %d")
    :format(player.hp, player.maxHp, player.experience))
  assert(player.experience > 0, "no experience was awarded")
  U.shot(game, out .. "/04-battle-end.png")

  print("[driver] PASS gold wild battle in " .. out)
end

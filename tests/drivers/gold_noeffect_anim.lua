-- A move the target is immune to, and the two move lock-ins, on the real
-- battle screen.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_noeffect_anim.lua love .
--
-- What a human is here to see:
--
--   01 / 02  TACKLE (NORMAL) against a GASTLY (GHOST).  The move text prints,
--            the screen holds still for MoveDelay, and then "It doesn't affect
--            GASTLY..." appears.  No attack animation plays at any point.
--            BattleCommand_Stab's `.GotMatchup` writes wAttackMissed for a
--            zero matchup (effect_commands.asm:1337), `stab` runs ahead of
--            `moveanim` in every damaging effect list
--            (data/moves/effects.asm:5), and BattleCommand_MoveAnimNoSub
--            early-outs on wAttackMissed (:1958).
--   03       LEECH SEED on a Grass type: same shape, `.grass` ->
--            AnimateFailedMove (move_effects/leech_seed.asm).
--   04 - 09  ROLLOUT.  CheckPlayerLockedIn quits ParsePlayerAction while
--            SUBSTATUS_ROLLOUT is set (core.asm:546), so the FIGHT menu never
--            comes back at all: after the one selection in 04 the move repeats
--            on its own for four more turns and the menu only returns once the
--            fifth hit clears the bit (09).  The PP counter moves exactly once,
--            on the opening turn, because checkrollout skips past
--            doturn_command for every later turn of the lock.
--
-- The animation suppression is the deliverable here: no headless assertion can
-- see whether a sprite moved, so this driver is the check.
local U = require("tests.drivers.util")

local Mon = require("src.battle.gen2.Mon")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-noeffect-anim"

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

  -- One mon carrying exactly the three moves this driver exercises, so the
  -- FIGHT list is readable in the shots.
  local player = Mon.new(game.data, "CYNDAQUIL", 30)
  assert(player, "could not build a CYNDAQUIL from pokemon.lua")
  player.moves = {
    { id = "TACKLE", pp = 35, maxPp = 35 },
    { id = "LEECH_SEED", pp = 10, maxPp = 10 },
    { id = "ROLLOUT", pp = 20, maxPp = 20 },
  }
  game.save.party = { player }
  game.save.inventory = {}

  -- Waits for the battle screen to be sitting on its menu again.
  local function toMenu(battle, limit)
    for _ = 1, (limit or 400) do
      if battle.phase == "menu" or battle.battle.over then return end
      tap("a", 3)
    end
  end

  local function fight(battle, slot)
    tap("a")                                    -- FIGHT
    U.wait(6)
    for _ = 2, slot do tap("down", 4) end
    U.wait(4)
    return slot
  end

  local function openBattle(species, level)
    local wild = Mon.new(game.data, species, level)
    assert(wild, "could not build a wild " .. species)
    assert(world:startBattle({ wild = wild }), "startBattle failed")
    local battle
    for _ = 1, 600 do
      local top = game.stack:top()
      if top and top.battle then battle = top break end
      U.wait(1)
    end
    assert(battle and battle.battle, "battle screen never came up")
    toMenu(battle)
    return battle, wild
  end

  -- ---- immunity: NORMAL into GHOST ---------------------------------------
  local battle = openBattle("GASTLY", 8)
  U.shot(game, out .. "/00-menu.png")
  fight(battle, 1)                              -- TACKLE
  tap("a")
  -- Straight after the "used TACKLE!" line is exactly where the animation
  -- would be.  Both shots must show a still screen.
  U.wait(6)
  U.shot(game, out .. "/01-tackle-no-anim.png")
  U.wait(24)
  U.shot(game, out .. "/02-doesnt-affect.png")
  toMenu(battle)

  -- ---- LEECH SEED into a Grass type --------------------------------------
  for _ = 1, 200 do
    if not (game.stack:top() and game.stack:top().battle) then break end
    tap("b", 3)
    if battle.battle.over then break end
    tap("a", 3)
  end
  U.wait(30)
  battle = openBattle("BELLSPROUT", 8)
  fight(battle, 2)                              -- LEECH SEED
  tap("a")
  U.wait(6)
  U.shot(game, out .. "/03-leech-seed-no-anim.png")
  toMenu(battle)

  -- ---- ROLLOUT locks the FIGHT list --------------------------------------
  --
  -- A high-level target so the five turns actually happen.
  for _ = 1, 200 do
    if not (game.stack:top() and game.stack:top().battle) then break end
    tap("b", 3)
    if battle.battle.over then break end
    tap("a", 3)
  end
  U.wait(30)
  battle = openBattle("SNORLAX", 40)

  -- Both HP pools are widened first.  ROLLOUT's power doubles every turn
  -- (BattleCommand_RolloutPower), and at these levels either side faints inside
  -- the five, which ends the battle and leaves the deliverable unshot: the lock
  -- is what this segment is here to photograph, not a damage race.
  local function widen(mon)
    if not mon then return end
    mon.stats = mon.stats or {}
    mon.stats.hp, mon.maxHp, mon.hp = 999, 999, 999
  end
  widen(battle.battle.player)
  widen(battle.battle.enemy)

  local ppBefore = player.moves[3].pp
  tap("a")                                      -- FIGHT
  U.wait(8)
  U.shot(game, out .. "/04-rollout-picked-once.png")
  tap("down", 4)
  tap("down", 4)
  tap("a")                                      -- ROLLOUT, the only selection

  -- From here the player never chooses again.  A is still tapped, but only to
  -- page the text along: if the menu ever reappears while the bit is set, the
  -- port has lost CheckPlayerLockedIn.  `rolloutLock` is the port's name for
  -- SUBSTATUS_ROLLOUT and `rampCount` its counter minus one, so
  -- `rampCount + 1` is the cart's wPlayerRolloutCount.
  local menuDuringLock, shot, armed = false, {}, false
  for _ = 1, 600 do
    if battle.battle.over then break end
    local v = player.volatile or {}
    if v.rolloutLock then
      armed = true
      if battle.phase == "menu" then menuDuringLock = true end
      local count = (v.rampCount or 0) + 1
      if not shot[count] then
        shot[count] = true
        U.shot(game, ("%s/0%d-rollout-turn%d.png"):format(out, 4 + count, count))
      end
    elseif armed then
      -- The fifth hit is the one that clears the bit, so the loop leaves on it
      -- and 09 below is the menu coming back.
      break
    end
    tap("a", 3)
  end
  toMenu(battle)
  U.shot(game, out .. "/09-lock-released.png")

  local spent = ppBefore - player.moves[3].pp
  print(("[driver] %s the opening hit set SUBSTATUS_ROLLOUT")
    :format(armed and "ok  " or "FAIL"))
  print(("[driver] %s the FIGHT menu stayed shut for the whole lock")
    :format(menuDuringLock and "FAIL" or "ok  "))
  print(("[driver] %s ROLLOUT spent %d PP (1 is the cart: only turn one pays)")
    :format(spent == 1 and "ok  " or "FAIL", spent))
  print("[driver] shots in " .. out)
end

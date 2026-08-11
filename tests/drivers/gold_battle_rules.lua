-- The battle RULES that a fixture test cannot see: when TRANSFORM actually
-- lands on screen, what a caught mon's record says, and that STRUGGLE,
-- MAGNITUDE, DREAM EATER, SPITE and a refused RUN behave the way
-- engine/battle/effect_commands.asm and engine/battle/core.asm say they do --
-- all of it against the live extracted tables and the real battle screen
-- rather than a fixture.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_battle_rules.lua \
--     POKEPORT_SHOT_DIR=/tmp/gold-rules love .
--
-- The shots are the point of the first block: BattleState draws the enemy pic
-- from whichever mon its `shownMon` slot holds, and that slot follows the
-- EVENT QUEUE.  Battle:takeTurn resolves a whole round up front, so anything
-- the rules write straight into the mon record is on screen a beat before its
-- own message -- which is what "DITTO transformed at the beginning of its
-- turn" looked like.  01-submitted.png is taken one frame after the move is
-- submitted and before any message has been drained, and 02-transformed.png
-- once TRANSFORM's own line has been read: the two shots are what the pic
-- timing has to be judged on, and the driver PRINTS which one the swap landed
-- on rather than asserting it, because the rules half of that (the `transform`
-- event, and the pre-transform record kept beside it) is all this side of the
-- seam owns -- src/ui/gen2/BattleState.lua owns `shownMon`.
--
-- What the driver does assert is every rule: the transform is undone on the
-- way out of the battle (a caught DITTO is a DITTO), STRUGGLE's damage and its
-- quarter-damage recoil, MAGNITUDE's rolled power, DREAM EATER's checkhit gate
-- and SPITE's PP drain, and a RUN refused by a trainer battle costing nothing.
local U = require("tests.drivers.util")

local Mon = require("src.battle.gen2.Mon")

local function battleScreen(game)
  for _ = 1, 900 do
    local top = game.stack:top()
    if top and top.battle then return top end
    U.wait(1)
  end
  error("battle screen never came up")
end

-- Drain the screen's own queue: press A until it is asking for a move again.
local function drain(game, screen, frames)
  for _ = 1, (frames or 400) do
    if screen.phase == "menu" and #screen.queue == 0 and not screen.anim then
      return true
    end
    U.tap(game, "a")
    U.wait(3)
  end
  return false
end

local function newWild(game, species, level, moves)
  local mon = Mon.new(game.data, species, level)
  if moves then
    mon.moves = {}
    for i, id in ipairs(moves) do
      local def = assert(game.data.moves[id], id .. " is not in moves.lua")
      mon.moves[i] = { id = id, pp = def.pp, maxPp = def.pp }
    end
  end
  return mon
end

local function giveMoves(mon, game, moves)
  mon.moves = {}
  for i, id in ipairs(moves) do
    local def = assert(game.data.moves[id], id .. " is not in moves.lua")
    mon.moves[i] = { id = id, pp = def.pp, maxPp = def.pp }
  end
  return mon
end

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-rules"
  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")
  local failures = {}
  local function check(ok, what)
    print((ok and "[ok] " or "[FAIL] ") .. what)
    if not ok then failures[#failures + 1] = what end
  end

  -- ------------------------------------------------------------------ 1 + 3
  -- A wild DITTO whose only move is TRANSFORM, so the AI cannot pick anything
  -- else, and a player mon slow enough that the DITTO moves second.
  local player = Mon.new(game.data, "SNORLAX", 30)
  giveMoves(player, game, { "TACKLE" })
  game.save.party = { player }
  game.save.inventory = { MASTER_BALL = 5 }
  local ditto = newWild(game, "DITTO", 20, { "TRANSFORM" })
  assert(world:startBattle({ wild = ditto }), "startBattle failed")
  local screen = battleScreen(game)
  drain(game, screen, 200)
  U.shot(game, out .. "/00-menu.png")
  print("[driver] enemy shown as " .. tostring(screen:activeMon("enemy")
    and screen:activeMon("enemy").species))

  screen:submit({ kind = "move", move = "TACKLE" })
  local sawTransformEvent = false
  for _, event in ipairs(screen.queue) do
    if event.kind == "transform" then sawTransformEvent = true end
  end
  U.wait(1)
  U.shot(game, out .. "/01-submitted.png")
  local shownAtSubmit = screen:activeMon("enemy")
  print("[driver] pic timing: at submit the enemy draws as "
    .. tostring(shownAtSubmit and shownAtSubmit.species)
    .. " (01-submitted.png)")
  check(sawTransformEvent,
    "the round carries a `transform` event for the screen to swap its pic on")

  -- The frame the bug report is about: the player's own move is still on
  -- screen, its animation has finished and the enemy pic is being drawn again
  -- -- and the mon it is drawn from has already been rewritten by a TRANSFORM
  -- whose line has not been read yet.
  U.wait(120)
  U.shot(game, out .. "/01z-before-transform-line.png")
  print("[driver] with the box still reading "
    .. tostring(screen.message and screen.message:gsub("\n", " / "))
    .. " the enemy pic is drawn from "
    .. tostring(screen:activeMon("enemy") and screen:activeMon("enemy").species)
    .. " (01z-before-transform-line.png)")

  -- One shot per message on the way through the round, so the frame where the
  -- pic stops being a DITTO can be pointed at rather than described.
  for step = 1, 6 do
    U.tap(game, "a")
    U.wait(24)
    U.shot(game, out .. ("/01%s-step.png"):format(string.char(96 + step)))
    print("[driver] step " .. step .. " message: "
      .. tostring(screen.message and screen.message:gsub("\n", " / ")))
  end
  drain(game, screen, 400)
  U.shot(game, out .. "/02-transformed.png")
  local shownAfter = screen:activeMon("enemy")
  print("[driver] pic timing: after TRANSFORM's own line it draws as "
    .. tostring(shownAfter and shownAfter.species) .. " (02-transformed.png)")
  check(ditto.species == "SNORLAX",
    "the rules half lands at once: the battler IS the copy for the rest of "
      .. "the round")
  check(screen.battle:volatile(ditto).preTransform
    and screen.battle:volatile(ditto).preTransform.species == "DITTO",
    "and the record it was is kept for the reload")

  -- The catch: PokeBallEffect reloads the caught mon out of its base data
  -- (item_effects.asm `.catch_without_fail` reads wTempEnemyMonSpecies), so a
  -- transformed DITTO is caught as a DITTO.  A MASTER BALL so the roll is not
  -- part of what is being tested.
  screen:useItem("MASTER_BALL")
  for _ = 1, 400 do
    if game.save.party[2] then break end
    U.tap(game, "a")
    U.wait(3)
  end
  U.shot(game, out .. "/03-caught.png")
  local caught = game.save.party[2]
  check(caught ~= nil, "the DITTO was caught into the party")
  -- CleanUpBattleRAM (BattleState:finishBattle -> clearAllVolatiles) is where
  -- the reload lands, so the record is judged once the battle is off the
  -- stack -- which is also the last moment before the overworld and the next
  -- save write see it.
  -- B, not A: the capture ends on AskGiveNicknameText, and answering NO is
  -- what walks the screen through to ExitBattle instead of parking it in the
  -- naming screen (which sits ON TOP of the battle, so "the battle is not the
  -- top of the stack" is not the same as "the battle is over").
  local done = false
  for _ = 1, 900 do
    if screen.phase == "done" then done = true break end
    U.tap(game, "b")
    U.wait(3)
  end
  U.wait(30)
  print(("[driver] battle finished=%s phase=%s"):format(tostring(done),
    tostring(screen.phase)))
  check(done, "the battle screen reached ExitBattle")
  if caught then
    print("[driver] caught record: species=" .. tostring(caught.species)
      .. " move1=" .. tostring(caught.moves and caught.moves[1]
        and caught.moves[1].id))
    check(caught.species == "DITTO",
      "the caught record is the real DITTO (was "
        .. tostring(caught.species) .. ")")
    check(caught.moves and caught.moves[1]
      and caught.moves[1].id == "TRANSFORM",
      "and it kept its own move list")
  end

  -- ---------------------------------------------------------------------- 2
  -- STRUGGLE: real damage, then a quarter of it back (BattleCommand_Recoil).
  local struggler = Mon.new(game.data, "RATTATA", 30)
  giveMoves(struggler, game, { "TACKLE" })
  struggler.moves[1].pp = 0
  game.save.party = { struggler }
  local target = newWild(game, "SNORLAX", 30, { "SPLASH" })
  assert(world:startBattle({ wild = target }), "startBattle failed")
  screen = battleScreen(game)
  drain(game, screen, 200)
  local foeBefore, mineBefore = target.hp, struggler.hp
  screen:submit({ kind = "move", move = "TACKLE" })
  drain(game, screen, 400)
  U.shot(game, out .. "/04-struggle.png")
  local dealt = foeBefore - target.hp
  local recoil = mineBefore - struggler.hp
  print(("[driver] STRUGGLE dealt %d and recoiled %d"):format(dealt, recoil))
  check(dealt > 5, "STRUGGLE deals its 50 power, not chip damage")
  check(recoil == math.max(1, math.floor(dealt / 4)),
    "and the user takes a quarter of it back")
  for _ = 1, 400 do
    if not game.stack:top() or not game.stack:top().battle then break end
    U.tap(game, "a")
    U.wait(3)
  end
  U.wait(60)

  -- ------------------------------------------------------------------ 4/5/6
  local caster = Mon.new(game.data, "GASTLY", 40)
  giveMoves(caster, game, { "MAGNITUDE", "DREAM_EATER", "SPITE" })
  caster.hp = math.max(1, caster.hp - 20)
  game.save.party = { caster }
  local dummy = newWild(game, "RATTATA", 20, { "TACKLE" })
  assert(world:startBattle({ wild = dummy }), "startBattle failed")
  screen = battleScreen(game)
  drain(game, screen, 200)

  local before = dummy.hp
  screen:submit({ kind = "move", move = "MAGNITUDE" })
  local sawMagnitude = false
  for _, event in ipairs(screen.queue) do
    if event.text and event.text:match("^Magnitude %d") then
      sawMagnitude = true
    end
  end
  drain(game, screen, 400)
  U.shot(game, out .. "/05-magnitude.png")
  check(sawMagnitude, "MAGNITUDE announces its rolled magnitude")
  check(before - dummy.hp > 1,
    "and hits for the rolled power, not the ROM's stored 1 (dealt "
      .. tostring(before - dummy.hp) .. ")")

  local hpBefore, mineHp = dummy.hp, caster.hp
  screen:submit({ kind = "move", move = "DREAM_EATER" })
  drain(game, screen, 400)
  check(dummy.hp == hpBefore,
    "DREAM EATER misses an awake target outright")
  check(caster.hp <= mineHp, "and saps nothing from it")

  local ppBefore = dummy.moves[1].pp
  screen:submit({ kind = "move", move = "SPITE" })
  drain(game, screen, 400)
  U.shot(game, out .. "/06-spite.png")
  print(("[driver] SPITE took the foe's TACKLE from %d to %d PP")
    :format(ppBefore, dummy.moves[1].pp))
  check(dummy.moves[1].pp < ppBefore - 1,
    "SPITE drains 2-5 PP off the move the target last used")
  for _ = 1, 400 do
    if not game.stack:top() or not game.stack:top().battle then break end
    U.tap(game, "a")
    U.wait(3)
  end
  U.wait(60)

  -- ---------------------------------------------------------------------- 7
  -- RUN in a trainer battle: `.cant_run_from_trainer` leaves
  -- wBattlePlayerAction alone and falls back into BattleMenu, so the round is
  -- never spent and the trainer does not get a free swing.
  local runner = Mon.new(game.data, "RATTATA", 30)
  giveMoves(runner, game, { "TACKLE" })
  game.save.party = { runner }
  local foe = Mon.new(game.data, "GEODUDE", 30)
  giveMoves(foe, game, { "TACKLE" })
  assert(world:startBattle({ trainer = { class = "YOUNGSTER",
    name = "JOEY", party = { foe } } }), "trainer startBattle failed")
  screen = battleScreen(game)
  drain(game, screen, 300)
  local hpAtRun = runner.hp
  local turnAtRun = screen.battle.turn
  screen:submit({ kind = "run" })
  drain(game, screen, 300)
  U.shot(game, out .. "/07-run-refused.png")
  check(runner.hp == hpAtRun,
    "a refused RUN costs no HP: the trainer never got a swing")
  check(screen.battle.turn == turnAtRun + 1 and not screen.battle.over,
    "and the battle is still running")
  check(foe.hp == foe.maxHp, "nor did anything happen to the foe")

  if #failures > 0 then
    for _, what in ipairs(failures) do print("[FAIL] " .. what) end
    error(#failures .. " battle-rule checks failed")
  end
  print("[driver] all battle-rule checks passed")
  print("[driver] shots in " .. out)
end

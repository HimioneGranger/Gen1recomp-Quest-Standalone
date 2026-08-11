-- The exp bar crawl, the level number that rides it, and the siren that has to
-- stop when the enemy goes down.  All three are things only a person watching
-- the screen can sign off on.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_exp_bar.lua love .
--
-- What to look for, in order:
--   02..05  the blue bar under the player's HUD WALKS to the right, one pixel
--           at a time (AnimateExpBar, engine/battle/core.asm:7191), with
--           SFX_EXP_BAR sounding under it.  It must not be at its final width
--           in shot 02 already.
--   03      the ":L" number is still the PRE-kill level while the bar is
--           mid-crawl, and only changes on the frame the bar tops out
--           (wBattleMonLevel is written inside the level loop, :7267-7274),
--           with the end-of-bar hit playing there.
--   06      "<mon> grew to level N!", which comes AFTER all of that.
-- And by ear: the low-HP siren is loud on the way in (the player is left on 3
-- HP on purpose), and is cut dead the moment the wild mon faints -- it must
-- not blare on under the victory jingle and the exp lines
-- (wBattleLowHealthAlarm, core.asm:2071-2074).
local U = require("tests.drivers.util")

local Mon = require("src.battle.gen2.Mon")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-exp-bar"

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  local player = Mon.new(game.data, "CYNDAQUIL", 9)
  assert(player and #player.moves > 0, "could not build a CYNDAQUIL")
  -- One point short of the next level, so the single kill below crosses it and
  -- the bar has to fill, restart at zero and finish the second segment.
  local def = game.data.pokemon[player.species]
  local growth = game.data.pokemon.growthRates[def.growthRate]
  player.experience = Mon.experienceForLevel(growth, player.level + 1) - 1
  -- Red bar on the way in, so the siren is up before the faint.
  player.hp = 3
  game.save.party = { player }
  game.save.inventory = { POTION = 2 }

  local wild = Mon.new(game.data, "PIDGEY", 6)
  assert(wild, "could not build a wild PIDGEY")
  assert(world:startBattle({ wild = wild }), "startBattle failed")

  local screen
  for _ = 1, 600 do
    local top = game.stack:top()
    if top and top.battle then screen = top break end
    U.wait(1)
  end
  assert(screen and screen.battle, "battle screen never came up")

  -- Page the intro out to the menu, with the siren already sounding.
  for _ = 1, 200 do
    if screen.phase == "menu" then break end
    U.tap(game, "a")
    U.wait(3)
  end
  assert(screen.phase == "menu", "never reached the battle menu")
  U.shot(game, out .. "/00-red-bar-siren.png")
  print("[driver] player " .. player.hp .. "/" .. player.maxHp
    .. " hp, level " .. player.level .. ", exp " .. player.experience)

  -- One hit ends it.
  screen.battle.enemy.hp = 1
  U.tap(game, "a")   -- FIGHT
  U.wait(6)
  U.tap(game, "a")   -- first move
  U.shot(game, out .. "/01-the-kill.png")

  -- Page forward until the crawl arms, shooting the level line as it stands.
  local shots, armed = 0, false
  for _ = 1, 900 do
    if screen.expAnim then armed = true break end
    if screen.phase == "done" then break end
    U.tap(game, "a")
    U.wait(2)
  end
  assert(armed, "the exp bar crawl never armed (phase "
    .. tostring(screen.phase) .. ")")
  print("[driver] crawl armed at level " .. tostring(screen.shownLevel)
    .. ", bar at " .. tostring(screen.shownExp) .. "/64")

  -- Four stills across the crawl.  A bar that is already full in the first is
  -- the bug this driver exists for.
  local seen = {}
  while screen.expAnim and shots < 4 do
    shots = shots + 1
    seen[shots] = { screen.shownExp, screen.shownLevel }
    U.shot(game, out .. ("/%02d-crawl.png"):format(shots + 1))
    U.wait(18)
  end
  for i = 1, shots do
    print(("[driver] shot %d: bar %s/64, :L%s")
      :format(i + 1, tostring(seen[i][1]), tostring(seen[i][2])))
  end
  assert(shots >= 2, "the crawl was over before two frames could be shot")
  assert(seen[1][1] < 64, "the bar was already full on the first crawl frame")

  -- The rest of the queue: the grew-to-level line and the way out.
  for _ = 1, 900 do
    if screen.phase == "done" then break end
    if (screen.message or ""):find("grew to level") then
      U.shot(game, out .. "/06-grew-to-level.png")
    end
    U.tap(game, "a")
    U.wait(2)
  end
  print("[driver] ended at level " .. tostring(player.level)
    .. ", HUD showing :L" .. tostring(screen.shownLevel))
  print("[driver] PASS gold exp bar in " .. out)
end

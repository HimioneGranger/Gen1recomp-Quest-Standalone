-- The Route 29 DUDE, the scene two separate defects meet in.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_route29_tutorial.lua love .
--
-- What a human is watching for:
--   * "Would you like me / to show you how to / catch #MON?" -- the YES/NO
--     prompt must go up OVER that box, with the question still on it and with
--     NO extra button press in between.  CatchingTutorialIntroText ends
--     `done`, so DoneText returns without a PromptButton (home/text.asm:484)
--     and Script_yesorno's `call YesNoBox` is the very next thing that
--     happens (engine/overworld/scripting.asm:366).
--   * when the tutorial battle ends, the Route 29 map theme comes back.  The
--     silence used to outlive the battle: wDontPlayMapMusicOnReload was read
--     at the end of the fight instead of at the reload behind it, so the flag
--     sat set and stopped the music at the END of the NEXT battle.
--
-- Shots land in /tmp/gold-route29.
local U = require("tests.drivers.util")
local Music = require("src.core.Music")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-route29"

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  -- Route29Tutorial1 is a coord event at (53,8) gated on
  -- SCENE_ROUTE29_CATCH_TUTORIAL (maps/Route29.asm:422); take the scene id
  -- from the map rather than hardcoding the constant.
  world:setMap("ROUTE_29", 53, 10, "up")
  U.wait(20)
  local trigger
  for _, ev in ipairs(world.map.def.coordEvents or {}) do
    if ev.x == 53 and (ev.y == 8 or ev.y == 9) then trigger = trigger or ev end
  end
  assert(trigger, "ROUTE_29 has no catch tutorial coord event")
  world.mapScenes[world.map.id] = trigger.sceneId or 0
  local mapSong = Music.mapSong()

  U.hold(game, "up", 24)
  U.wait(20)

  -- Page to the question, counting the presses it costs.  The prompt must
  -- arrive on the press that finishes the last page, not one press later.
  local presses, sawPrompt = 0, false
  for _ = 1, 120 do
    if world.choicebox then
      sawPrompt = true
      break
    end
    U.tap(game, "a")
    presses = presses + 1
    U.wait(12)
  end
  U.shot(game, out .. "/00-yes-no-over-question.png")
  print(("[driver] %d presses to reach the prompt, prompt seen: %s")
    :format(presses, tostring(sawPrompt)))

  -- YES, then let the tutorial battle play itself out (it drives its own
  -- input on the cart, so all this has to do is not get in the way).
  U.tap(game, "a")
  for _ = 1, 200 do
    U.wait(15)
    if world:busy() then break end
  end
  for _ = 1, 400 do
    U.wait(15)
    if not world:busy() and game.stack:top() == game.overworld then break end
    U.tap(game, "a")
  end
  U.wait(60)
  U.shot(game, out .. "/01-after-tutorial.png")

  print(("[driver] map song %s, playing now %s, dontRestartMusic %s")
    :format(tostring(mapSong), tostring(Music.current()),
      tostring(world.dontRestartMusic)))
  print("[driver] PASS gold route 29 tutorial in " .. out)
  love.event.quit()
end

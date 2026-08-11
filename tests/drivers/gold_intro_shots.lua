-- The Gold/Silver intro movie, sampled every half second.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_intro_shots.lua love .
--
-- A cinematic is the one thing no assertion can check: "does Lapras surface
-- before the fade", "is the water bending", "is the fireball spiralling" are
-- questions for eyes.  So this pushes the real GoldSilverIntro onto the stack,
-- lets it run at its own 60 Hz, and lays the whole ~39 seconds out as a
-- contact sheet in POKEPORT_SHOT_DIR (/tmp/gold-intro by default).
--
-- Shots are named by the movie's own frame counter and current scene, so a
-- file is directly comparable against engine/movie/intro.asm's jumptable.
local U = require("tests.drivers.util")
local GoldSilverIntro = require("src.ui.gen2.GoldSilverIntro")

-- Every 30 frames covers each act's beats without producing an unreadable
-- number of files; the movie runs about 2340 frames end to end.
local INTERVAL = 30
local LIMIT = 3000

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-intro"
  local interval = tonumber(os.getenv("POKEPORT_SHOT_INTERVAL") or "") or INTERVAL

  U.wait(30)
  local assets = game.data and game.data.gen2Intro
  if not (assets and assets.water and assets.water.meta) then
    print("[driver] SKIP no intro tables in this cache -- re-import Gold")
    return
  end

  local finished = false
  local intro = GoldSilverIntro.new(game, {
    onDone = function() finished = true end,
  })
  game.stack:clear()
  game.stack:push(intro)

  local shots, scene = 0, 0
  while not finished and intro.frames < LIMIT do
    U.wait(interval)
    if intro.scene ~= scene then
      scene = intro.scene
      print(("[driver] scene %d at frame %d (scx=%02x scy=%02x objs=%d)")
        :format(scene, intro.frames, intro.scx, intro.scy,
          intro.anims:activeCount()))
    end
    U.shot(game, ("%s/%04d-scene%02d.png"):format(out, intro.frames, scene))
    shots = shots + 1
  end

  assert(finished, "the movie never reached the end of IntroScene17")
  print(("[driver] %d shots in %s over %d frames")
    :format(shots, out, intro.frames))
end

-- The end of the game, sampled: the Hall of Fame induction, the credits roll,
-- and the roster the PC shows afterwards.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_halloffame_shots.lua love .
--   POKEPORT_SHOT_DIR=/tmp/gold-hof   (default)
--
-- Everything here is a cinematic, which is exactly what no assertion can
-- check: "does the backpic really sweep off to the left before the frontpic
-- comes back", "does the banner change mon on each CREDITS_SCENE", "does THE
-- END stay up after the last blank" are questions for eyes.  So this stands
-- the real screens up on the real stack, lets them run at their own 60 Hz, and
-- lays each one out as a contact sheet.
--
-- Shots are named by the frame the screen has been running for and the phase
-- (or credits scene) it is in, so a file is directly comparable against
-- engine/events/halloffame.asm and engine/movie/credits.asm.
local U = require("tests.drivers.util")

local Core = require("src.core.gen2.HallOfFame")
local Credits = require("src.ui.gen2.Credits")
local HallOfFame = require("src.ui.gen2.HallOfFame")
local Mon = require("src.battle.gen2.Mon")

-- The induction is 292 frames a mon, so a six-mon party runs about 1900
-- frames; the credits are about 4400.  Half a second apiece keeps both
-- readable without an unusable number of files.
local INDUCT_INTERVAL = 20
local CREDITS_INTERVAL = 60
local LIMIT = 8000

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-hof"

  U.wait(45)
  assert(game.world and game.world.map, "gold world did not boot")

  local save = game.save
  local data = game.data

  -- A champion's party.  Mon.new is the ONE builder for a Gen 2 party member:
  -- anything routed through Gen 1's Pokemon.new comes back with no moves,
  -- because a Gen 2 moveset is levelMoves and Gen 1 reads level1Moves.
  local roster = {
    { "TYPHLOSION", 50, "BLAZE" },
    { "LANTURN", 46, "SPARK" },
    { "AMPHAROS", 45, nil },
    { "UMBREON", 44, "DUSK" },
    { "SCIZOR", 43, nil },
    { "GYARADOS", 47, "RAGE" },
  }
  save.party = {}
  for _, row in ipairs(roster) do
    local mon = Mon.new(data, row[1], row[2], { nickname = row[3] })
    if mon then
      mon.otId = save.player and save.player.id or 12345
      save.party[#save.party + 1] = mon
    end
  end
  assert(#save.party > 0, "no party could be built from this cache")
  save.player.name = save.player.name or "GOLD"
  save.playTime = { hours = 42, minutes = 7, seconds = 0, frames = 0 }

  -- ---- the induction ------------------------------------------------------

  -- What the `halloffame` opcode does to the save before the screen opens.
  -- `wasEntered` is the ALLOW_SKIPPING_CREDITS_F bit Credits wants: false the
  -- first time, which is why a first-time champion cannot hurry the roll.
  local entry, wasEntered = Core.induct(save, save.party)
  U.log(("inducted: %d mon(s), win count %d, spawn %s")
    :format(#entry.mons, entry.winCount, tostring(save.spawnAfterChampion)))

  local inducted = false
  local induction = HallOfFame.new(game, {
    save = save, entry = entry,
    onDone = function() inducted = true end,
  })
  game.stack:clear()
  game.stack:push(induction)

  local shots, phase = 0, nil
  while not inducted and induction.frames < LIMIT do
    U.wait(INDUCT_INTERVAL)
    if induction.phase ~= phase then
      phase = induction.phase
      U.log(("hof phase %s at frame %d (mon %d, scx=%02x scy=%02x)")
        :format(tostring(phase), induction.frames, induction.index,
          induction.scx, induction.scy))
    end
    U.shot(game, ("%s/hof-%04d-%s.png")
      :format(out, induction.frames, tostring(phase)))
    shots = shots + 1
  end
  assert(inducted, "the induction never reached HOF_AnimatePlayerPic's end")
  U.log(("%d induction shots over %d frames"):format(shots, induction.frames))
  game.stack:pop()

  -- ---- the credits --------------------------------------------------------

  local rolled = false
  local credits = Credits.new(game, {
    allowSkip = wasEntered,
    onDone = function() rolled = true end,
  })
  game.stack:clear()
  game.stack:push(credits)

  shots = 0
  local scene = -1
  while not credits.exiting and credits.frames < LIMIT do
    U.wait(CREDITS_INTERVAL)
    if credits.scene ~= scene then
      scene = credits.scene
      U.log(("credits scene %d at frame %d (pass %d, pos %d)")
        :format(scene, credits.frames, credits.passes, credits.pos))
    end
    U.shot(game, ("%s/credits-%04d-scene%d.png")
      :format(out, credits.frames, scene))
    shots = shots + 1
  end
  assert(credits.exiting, "the credits script never reached CREDITS_END")
  -- CREDITS_END only sets the exit flag; the screen waits on A, so the last
  -- shot is THE END sitting there exactly as the player sees it.
  U.wait(30)
  U.shot(game, ("%s/credits-%04d-theend.png"):format(out, credits.frames))
  U.log(("%d credits shots over %d frames, %d passes")
    :format(shots + 1, credits.frames, credits.passes))
  U.tap(game, "a")
  U.wait(10)
  assert(rolled, "A did not leave the credits once the exit flag was up")
  game.stack:clear()

  -- ---- the roster, as the PC shows it -------------------------------------

  -- _HallOfFamePC over the row that was just written: A walks the team, and
  -- the header is "-Time Famer" rather than "New Hall of Famer!".
  local viewer = HallOfFame.new(game, {
    mode = "view", save = save, onDone = function() end,
  })
  game.stack:push(viewer)
  for index = 1, #entry.mons do
    U.wait(10)
    U.shot(game, ("%s/pc-%02d-%s.png")
      :format(out, index, tostring((viewer:currentMon() or {}).species)))
    U.tap(game, "a")
  end
  U.log("roster viewer shot for " .. #entry.mons .. " mon(s) in " .. out)
end

-- Contact sheet: the Gen 2 evolution animation, frame by frame.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_evolution_shots.lua love .
--
-- Shoots src/ui/gen2/EvolutionAnim.lua into /tmp/gold-evo, one frame every few,
-- for a normal evolution and then for a B-cancelled one.  A test can assert
-- that the flash loop ran eight rounds; only a picture says the two pics are
-- swapping in the same 7x7 box at hlcoord 7, 2, that the silhouette really is
-- PREDEFPAL_BLACKOUT, and that the new mon's colours land on the last swap.
--
-- POKEPORT_EVO_SPECIES / POKEPORT_EVO_LEVEL pick the mon (default: a level 16
-- CHIKORITA, the first evolution a Gold playthrough actually reaches).
-- POKEPORT_SHOT_INTERVAL is how many frames apart the shots are.
local U = require("tests.drivers.util")

local Evolution = require("src.core.gen2.Evolution")
local EvolutionAnim = require("src.ui.gen2.EvolutionAnim")
local Mon = require("src.battle.gen2.Mon")

-- Frames to give one evolution before calling it hung: 50 (EvolvingText) + 80
-- (MUSIC_EVOLUTION) + 144 (the flash loop) + 64 (balls of light) + the text
-- pages, with room to spare.
local FRAME_LIMIT = 900

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-evo"
  local interval = tonumber(os.getenv("POKEPORT_SHOT_INTERVAL") or "4")
  local species = os.getenv("POKEPORT_EVO_SPECIES") or "CHIKORITA"
  local level = tonumber(os.getenv("POKEPORT_EVO_LEVEL") or "16")

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  local mon = Mon.new(game.data, species, level)
  assert(mon, "could not build a level " .. level .. " " .. species)
  -- The after-battle sweep's context: no link, no stone, and the clock's own
  -- time of day for the TR_MORNDAY / TR_NITE rows.
  local Palettes = require("src.world.gen2.Palettes")
  local entry = Evolution.checkMon(game.data, mon,
    { timeOfDay = Palettes.clockDaytime() })
  assert(entry, species .. " at level " .. level
    .. " has no evolution to show -- pick another with POKEPORT_EVO_SPECIES")
  print(("[driver] %s -> %s"):format(species, entry.into))

  -- One run of the screen, shooting every `interval` frames.  `cancelAt` is
  -- the frame to tap B on, which .WaitFrames_CheckPressedB only honours during
  -- a hold; nil runs it through to the end.
  local function run(prefix, cancelAt)
    game.save.party = { Mon.new(game.data, species, level) }
    local finished = nil
    local screen = EvolutionAnim.new(game, {
      mon = game.save.party[1],
      entry = entry,
      index = 1,
      party = game.save.party,
      save = game.save,
      onDone = function(result) finished = result end,
    })
    game.stack:push(screen)

    local frame = 0
    while not finished and frame < FRAME_LIMIT do
      if frame % interval == 0 then
        U.shot(game, ("%s/%s-%04d-%s.png"):format(out, prefix, frame,
          screen.phase or "?"))
      end
      if cancelAt and frame == cancelAt then
        U.tap(game, "b")
      else
        U.wait(1)
      end
      frame = frame + 1
    end
    assert(finished, prefix .. " never finished")
    game.stack:pop()
    print(("[driver] %-8s %d frames, canceled=%s, species now %s"):format(
      prefix, frame, tostring(finished.canceled),
      tostring(game.save.party[1].species)))
    return finished
  end

  local full = run("evolve", nil)
  assert(not full.canceled, "the uncancelled run reported a cancel")
  assert(game.save.party[1].species == entry.into,
    "the party slot did not take the new species")

  -- B during the very first hold, which is the 16 frames after the 50 + 80 of
  -- text and music: .cancel_evo leaves the OLD pic on screen and prints
  -- StoppedEvolvingText.
  local canceled = run("cancel",
    Evolution.EVOLVING_FRAMES + Evolution.MUSIC_FRAMES + 4)
  assert(canceled.canceled, "the B press did not cancel the evolution")
  assert(game.save.party[1].species == species,
    "a cancelled evolution changed the species anyway")

  print("[driver] PASS gold evolution in " .. out)
  love.event.quit()
end

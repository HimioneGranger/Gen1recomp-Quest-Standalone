-- Contact sheet: the egg hatch cutscene and the egg summary page.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold \
--     POKEPORT_DRIVER=tests/drivers/gold_egg_hatch_shots.lua \
--     perl -e 'alarm 300; exec @ARGV' \
--     python3 -c "import pty; pty.spawn(['love','.'])"
--
-- tests/drivers/gold_egg_hatch.lua walks a real party into a hatch and checks
-- the party record afterwards; this one puts a human in front of the parts of
-- it no assertion can reach.  Four things to look at, in the order they are
-- shot into /tmp/gold-egg (POKEPORT_SHOT_DIR):
--
--   crack, wobble-right, wobble-left
--       The crack sits ON the shell and stays there.  hSCX and
--       wGlobalAnimXOffset move the background and the objects the same way
--       (engine/pokemon/breeding.asm:707-719), so across the three shots the
--       egg and the crack shift together, never apart: lay them over each
--       other and the picture is the same one, two pixels either side of
--       where it rests.  The crack's own position carries
--       .OAMData_1x1_Palette0's -4 on each axis (data/sprite_anims/oam.asm
--       :112-114), which puts the first one at screen (76, 52).
--   burst, fragments-*, fragments-gone
--       The ten shards fly for sixteen frames and then leave
--       (AnimSeq_RevealNewMon's `.finish_EggShell`).  `fragments-gone` is
--       shot well after that and must show the hatchling alone.
--   hatchling
--       The pic is where PadFrontpic put it (engine/gfx/load_pics.asm:342).
--       The default species is SENTRET because its frontpic is 48px, the one
--       width the old centring rule placed four pixels wrong; POKEPORT_EGG
--       _SPECIES picks another.
--   summary-egg
--       EggStatsScreen's page (engine/pokemon/stats_screen.asm:747-794): the
--       EGG pic in the 7x7 block at hlcoord 0, 0, in the EGG palette row's
--       cream and brown rather than flat greys.  The egg is one cycle from
--       hatching, so SFX_2_BOOPS sounds as the page opens.
local U = require("tests.drivers.util")

local EggHatchAnim = require("src.ui.gen2.EggHatchAnim")
local Screens = require("src.ui.Screens")

-- 80 hold + 8 rounds of wobbles and stills + 129 fragment frames = 482, with
-- room to spare before calling it hung.
local FRAME_LIMIT = 700

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-egg"
  local species = os.getenv("POKEPORT_EGG_SPECIES") or "SENTRET"

  U.wait(45)
  assert(game.world and game.world.map, "gold world did not boot")

  local Mon = require("src.battle.gen2.Mon")
  local hatchling = Mon.new(game.data, species, 5)
  assert(hatchling, "no such species: " .. species)

  ------------------------------------------------------------------ cutscene

  local finished = false
  local screen = EggHatchAnim.new(game, {
    mon = hatchling, species = species,
    onDone = function() finished = true end,
  })
  game.stack:push(screen)

  -- Waiting on the screen's own state rather than a frame count: U.shot spins
  -- until the capture reaches disk, so it eats frames of its own and a
  -- frame-numbered target would drift past the beat it was aimed at.  A wobble
  -- half is only two frames long, shorter than that spin, so the screen is
  -- held still for the capture as well -- otherwise wobble-right and
  -- wobble-left would both be whatever beat the writer happened to land on.
  local frozen = false
  local advance = screen.update
  screen.update = function(s, dt)
    if frozen then return end
    return advance(s, dt)
  end

  local frames = 0
  local function until_(pred, what)
    while not pred() and frames < FRAME_LIMIT do
      U.wait(1)
      frames = frames + 1
    end
    assert(frames < FRAME_LIMIT, "never reached: " .. what)
  end

  local function shot(name)
    frozen = true
    U.shot(game, out .. "/" .. name .. ".png")
    frozen = false
  end

  -- The crack goes on at the end of a round's still frames and the next
  -- round's first wobble half is entered in the same update, so wait for the
  -- stillness after it: three shots, at shake 0, -2 and +2.
  until_(function() return #screen.sprites > 0 and screen.shakeX == 0 end,
    "the first crack, at rest")
  shot("crack")
  print(("[driver] first crack at (%d, %d) in struct coords")
    :format(screen.sprites[1].x, screen.sprites[1].y))

  until_(function() return screen.shakeX == 2 end, "a wobble's right half")
  shot("wobble-right")
  until_(function() return screen.shakeX == -2 end, "a wobble's left half")
  shot("wobble-left")

  until_(function() return screen.showMon end, "the shell breaking")
  shot("burst")
  for _, step in ipairs({ 4, 8, 12 }) do
    U.wait(step)
    frames = frames + step
    shot(("fragments-%02d"):format(step))
  end

  until_(function() return #screen.sprites == 0 end, "the shards leaving")
  print(("[driver] the fragments were gone %d frames in"):format(frames))
  U.wait(40)
  shot("fragments-gone")
  shot("hatchling")

  while not finished and frames < FRAME_LIMIT do
    U.wait(1)
    frames = frames + 1
  end
  assert(finished, "the cutscene never finished")
  if game.stack:top() == screen then game.stack:pop() end
  U.wait(10)

  ------------------------------------------------------------- summary page

  -- One cycle left, which is EggStatsScreen's `cp 6` arm: the "It's making
  -- sounds inside" line and SFX_2_BOOPS.
  local egg = {
    isEgg = true, species = species, name = "EGG", level = 5,
    eggSteps = 1, dvs = hatchling.dvs, moves = {},
    ot = game.save.player and game.save.player.name,
    otId = game.save.player and game.save.player.id,
  }
  game.save.party = { hatchling, egg }
  local summary = Screens.push(game, "Gen2SummaryMenu",
    { party = game.save.party, index = 2 })
  U.wait(20)
  U.shot(game, out .. "/summary-egg.png")
  U.wait(20)
  if game.stack:top() == summary then game.stack:pop() end

  print("[driver] PASS gold egg hatch shots -> " .. out)
end

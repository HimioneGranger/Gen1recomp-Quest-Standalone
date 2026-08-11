-- The Gold title screen, once per COLOR mode.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_title_shots.lua love .
--
-- Two things about this screen only a human can check, and both of them are
-- what this driver puts on disk:
--
--   * Ho-Oh's placement.  `depixel 12, 11` is OAM (x 88, y 96), and OAM is
--     biased by (-8, -16), so the bird's 64 pixels land on 48..112 -- dead
--     centre of the 160-wide screen.  A shot where it sits right of centre
--     means the bias (or the y-then-x argument order) has been dropped again.
--   * Ho-Oh under DMG and CLASSIC.  LoadTitleScreenPals writes rOBP0 =
--     %11111111 on a non-CGB screen, mapping all four of the pic's colours to
--     shade 3, so the bird is a solid BLACK silhouette there rather than the
--     shaded pose a straight 2bpp decode gives.
--
-- Writes to /tmp/gold-title (POKEPORT_SHOT_DIR to move it).
local U = require("tests.drivers.util")

local GbcPalette = require("src.render.GbcPalette")
local TitleState = require("src.ui.gen2.TitleState")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-title"

  U.wait(10)
  game:showTitle()
  U.wait(20)
  local title = game.stack:top()
  assert(getmetatable(title) == TitleState,
    "showTitle left " .. tostring(title) .. " on the stack")
  assert(title.hoohX == 48 and title.hoohY == 56,
    ("Ho-Oh is at (%s, %s), expected (48, 56) -- stale cache?")
      :format(tostring(title.hoohX), tostring(title.hoohY)))

  local previous = GbcPalette.mode
  for _, mode in ipairs(GbcPalette.MODES) do
    GbcPalette.setMode(mode)
    -- Land on the same wing-flap frame in every mode so the three shots
    -- differ only in colour: the frameset runs on its own timer.
    title.seqIndex, title.frame, title.seqLeft = 1, 1, 999
    title.hoohPhase = 0
    U.wait(2)
    U.shot(game, ("%s/title-%s.png"):format(out, mode))
    print(("[driver] %s"):format(GbcPalette.modeLabel(mode)))
  end
  GbcPalette.setMode(previous)

  print("[driver] PASS gold title shots in " .. out)
end

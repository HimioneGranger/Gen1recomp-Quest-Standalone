-- TILT on the Gen 2 overworld: the world pass rendered into a canvas and
-- projected onto the perspective quad, with the flat frame beside it for
-- comparison.  Shots land in /tmp/gold-tilt.
local U = require("tests.drivers.util")
local Tilt = require("src.render.Tilt")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-tilt"
  U.wait(45)
  U.shot(game, out .. "/00-flat.png")
  for level = 1, 3 do
    Tilt.setLevel(level)
    -- The angle eases in, so let the tween finish before the shot.
    U.wait(60)
    U.shot(game, ("%s/%02d-tilt%d.png"):format(out, level, level))
  end
  Tilt.setLevel(0)
  U.wait(60)
  print("[driver] PASS gold tilt shots in " .. out)
end

-- ZOOM in the Gold overworld: the map resizes, the UI does not.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_zoom_shots.lua love .
--
-- One shot per zoom level with a dialogue box up, and one more with the START
-- menu up.  Across the set the map behind the box has to change size and the
-- box itself has to be pixel-for-pixel identical -- that is the two-pass split
-- src/render/Renderer.lua makes for Gen 1 (UI LAYOUT = CENTERED: the world
-- canvas follows Zoom.scale, the UI canvas stays on fitScale), which
-- Game2:drawScene now makes too.  Before it did, the text box grew and
-- shrank along with the world.
--
-- Writes to /tmp/gold-zoom (POKEPORT_SHOT_DIR to move it).
local U = require("tests.drivers.util")

local StartMenu = require("src.ui.gen2.StartMenu")
local Zoom = require("src.render.Zoom")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-zoom"

  U.wait(45)
  assert(game.world and game.world.map, "gold world did not boot")
  -- Outside, where the survey zoom is worth looking at at all.
  if game.world.map.id ~= "NEW_BARK_TOWN" then
    game.world:setMap("NEW_BARK_TOWN", 13, 6, "down")
    U.wait(20)
  end

  local fit = game.world:fitScale()
  print(("[driver] fit scale %d"):format(fit))

  local function at(offset, name)
    Zoom.offset = Zoom.clampOffset(offset, fit)
    U.wait(4)
    U.shot(game, ("%s/%s.png"):format(out, name))
    print(("[driver] %s: offset %d, world x%.2f, ui x%d")
      :format(name, Zoom.offset, game.world:zoomScale(), fit))
    return Zoom.offset
  end

  game:say("ZOOM leaves this box alone.")
  U.wait(6)
  local survey = at(-2, "01-survey")
  at(0, "02-fit")
  local close = at(2, "03-close")
  assert(survey < 0 or close > 0,
    "the zoom range collapsed to a single step; nothing to compare")
  game.stack:pop()

  Zoom.offset = 0
  U.wait(4)
  game:openStartMenu()
  U.wait(10)
  assert(getmetatable(game.stack:top()) == StartMenu,
    "START menu did not open (top " .. tostring(game.stack:top()) .. ")")
  at(-2, "04-startmenu-survey")
  at(2, "05-startmenu-close")

  Zoom.offset = 0
  print("[driver] PASS gold zoom shots in " .. out)
end

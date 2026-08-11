-- The five full-screen Gold pages that used to letterbox over a live
-- overworld: the Ruins of Alph sliding puzzle, the DIPLOMA, the MAGNET TRAIN
-- ride, the Cianwood PHOTO card and the ALPH RUINS STAMP viewer.
--
-- Every one of them wipes the tilemap on the cart before it draws a single
-- tile -- ClearBGPalettes / ClearTilemap at engine/games/unown_puzzle.asm:11,
-- engine/events/diploma.asm:13, engine/events/magnet_train.asm:101,
-- engine/printer/print_party.asm:134 and engine/events/print_unown.asm:17 --
-- so no map pixel can be on screen while one is up.  In the port that means
-- src/core/Game2.lua:drawScene must never reach `world:draw()` while an
-- opaque screen owns the stack.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold \
--     POKEPORT_DRIVER=tests/drivers/gold_opaque_surround.lua love .
--   POKEPORT_SHOT_DIR=/tmp/gold-surround   (default)
--
-- The screenshots are the deliverable: each one must show its page centred in
-- a plain field with NO Route 31 grass, ledge or house around it.  The
-- assertions catch the same thing from inside (the overworld draw is counted
-- while the page is up, and has to stay at zero), so a run nobody watches is
-- still worth something.
local U = require("tests.drivers.util")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-surround"
  local failures = 0

  local function ok(label, condition, detail)
    if condition then
      print("[surround] ok   " .. label)
    else
      failures = failures + 1
      print("[surround] FAIL " .. label .. " " .. tostring(detail))
    end
  end

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  -- ROUTE_31 on purpose: grass, a ledge and a house, so a leak is obvious in
  -- the shot rather than a subtle band of colour.
  assert(world:setMap("ROUTE_31", 8, 6, "down"), "setMap failed for ROUTE_31")
  U.wait(8)

  -- Count the overworld draws the way drawScene issues them.  The instance
  -- entry shadows World.draw on the metatable, so this sees every call and
  -- still runs the real one.
  local drew = 0
  local worldDraw = world.draw
  world.draw = function(self, ...)
    drew = drew + 1
    return worldDraw(self, ...)
  end

  -- Control: the overworld IS the visible base here, so it must draw.  Without
  -- this the "never drew" assertions below would pass on a dead renderer.
  drew = 0
  U.shot(game, out .. "/00-overworld.png")
  ok("the plain overworld still draws the map", drew > 0, drew)

  -- `settle` is how many frames the page needs before it has anything to
  -- show: the still pages are ready at once, the Magnet Train has to run its
  -- scroll far enough for the carriage to exist.
  local function page(label, file, open, settle)
    if not open() then
      failures = failures + 1
      print("[surround] FAIL " .. label .. " did not open")
      return
    end
    U.wait(settle or 12)
    local base = game.stack._items[game.stack:visibleBase()]
    ok(label .. " is the opaque visible base",
      base ~= nil and base.isOpaque == true, base and base.isOpaque)
    drew = 0
    U.shot(game, out .. "/" .. file)
    ok(label .. " keeps the overworld off the screen (ClearTilemap)",
      drew == 0, drew)
    if game.stack:top() ~= game.overworld then game.stack:pop() end
    U.wait(6)
  end

  -- engine/games/unown_puzzle.asm _UnownPuzzle
  page("the sliding puzzle", "01-unown-puzzle.png", function()
    return world:unownPuzzle(0, function() end)
  end)

  -- engine/events/diploma.asm PlaceDiplomaOnScreen
  page("the DIPLOMA", "02-diploma.png", function()
    return world:showDiploma(function() end)
  end)

  -- engine/events/magnet_train.asm MagnetTrain_LoadGFX_PlayMusic
  page("the MAGNET TRAIN ride", "03-magnet-train.png", function()
    return world:magnetTrain(true, function() end)
  end, 90)

  -- engine/printer/print_party.asm PrintPartyMonPage1
  page("the PHOTO card", "04-photo-studio.png", function()
    local party = game.save and game.save.party
    return world:showPhotoStudio(party and party[1], function() end)
  end)

  -- engine/events/print_unown.asm _UnownPrinter
  page("the ALPH RUINS STAMP", "05-unown-printer.png", function()
    return world:showUnownPrinter(function() end)
  end)

  world.draw = worldDraw

  print(failures == 0 and "PASS gold_opaque_surround"
    or ("FAIL gold_opaque_surround (%d)"):format(failures))
  love.event.quit(failures == 0 and 0 or 1)
end

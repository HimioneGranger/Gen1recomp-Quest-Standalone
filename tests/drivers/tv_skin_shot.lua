-- Driver: shoots the bundled desktop CRT bezel (assets/skins/tv_crt) over a
-- live overworld in a 16:9 window, and checks the alpha-based screen detector
-- against the viewport the .cfg declares.
--   SHOT_DIR=/tmp/tv POKEPORT_DRIVER=tests/drivers/tv_skin_shot.lua love .
return function(game)
  local U = dofile("tests/drivers/util.lua")
  local TouchControls = require("src.core.TouchControls")
  local TouchSkin = require("src.core.TouchSkin")
  local Pokemon = require("src.pokemon.Pokemon")

  local dir = os.getenv("SHOT_DIR") or "/tmp/tv"
  local skinId = os.getenv("SKIN") or "tv_crt"

  love.window.setMode(1280, 720, { resizable = true, highdpi = true })
  U.wait(2)

  game.save.party = { Pokemon.new(game.data, "CHARIZARD", 50) }
  game.save.player.name = "bryan"
  game.save.options.touchControls = { enabled = true, skin = skinId }
  game.save.options.tilt = 0
  game.save.options.zoom = 0
  game.save.options.pipelines = {}
  game:applyOptions()

  U.log("active:", tostring(TouchControls.skinId), "err:", tostring(TouchControls.skinError))
  local page = TouchSkin.page()
  U.log("page:", page and page.name, "controls:", page and #page.controls)
  local v = page and page.viewport
  U.log("declared viewport:", v and v.x, v and v.y, v and v.w, v and v.h)

  local detected = TouchSkin.detectViewport(TouchSkin.active.root, page.imagePath)
  if detected then
    U.log(("detected hole: %.4f %.4f %.4f %.4f"):format(
      detected.x, detected.y, detected.w, detected.h))
    U.log(("delta vs declared: %.4f %.4f %.4f %.4f"):format(
      detected.x - v.x, detected.y - v.y, detected.w - v.w, detected.h - v.h))
  else
    U.log("FAIL no hole detected")
  end

  local pw, ph = love.graphics.getPixelDimensions()
  U.log("pixel dims:", pw, ph)
  U.log("engine viewport px:", TouchSkin.viewport(pw, ph))
  U.log("fitScale:", game.renderer:fitScale())

  U.teleport(game, "PALLET_TOWN", 10, 8, "down")
  U.wait(12)
  U.shot(game, dir .. "/tv_overworld.png")

  U.log("done")
  love.event.quit()
  while true do coroutine.yield() end
end

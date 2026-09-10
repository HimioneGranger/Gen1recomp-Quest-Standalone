-- Driver: authors a CRT bezel skin from nothing using only Skin Studio
-- actions -- New, drop the art on the window, Detect screen, Save -- then
-- loads the saved folder back and renders the game through it.  Answers
-- "could the studio have made tv_crt?" by doing it.
--   SHOT_DIR=/tmp/author POKEPORT_DRIVER=tests/drivers/skin_studio_author_tv.lua love .
return function(game)
  local U = dofile("tests/drivers/util.lua")
  local Studio = require("src.ui.SkinStudio")
  local TouchSkin = require("src.core.TouchSkin")

  local dir = os.getenv("SHOT_DIR") or "/tmp/author"
  os.execute('mkdir -p "' .. dir .. '" 2>/dev/null')
  love.window.setMode(1280, 720, { resizable = true, highdpi = true })
  U.wait(2)

  local baseDraw = love.draw
  local pending = nil
  love.draw = function()
    Studio.draw()
    if pending then
      local path = pending
      pending = nil
      love.graphics.captureScreenshot(function(imagedata)
        local f = io.open(path, "wb")
        if f then f:write(imagedata:encode("png"):getString()) f:close() end
      end)
    end
  end
  local function shot(name)
    pending = dir .. "/" .. name
    for _ = 1, 90 do
      if not pending then break end
      coroutine.yield()
    end
    U.wait(3)
  end

  -- a stand-in for LOVE's DroppedFile, same three calls Studio.filedropped uses
  local function droppedFile(realPath)
    local handle
    return {
      getFilename = function() return realPath end,
      open = function() handle = assert(io.open(realPath, "rb")) end,
      read = function() return handle:read("*a") end,
      close = function() if handle then handle:close() handle = nil end end,
    }
  end

  Studio.load({ onClose = function() end })
  U.wait(3)

  -- 1. New skin, named
  Studio.skin = TouchSkin.newSkin("my_tv")
  Studio.skinIdField = "my_tv"
  Studio.pageIndex, Studio.selected = 1, nil
  Studio.images = {}
  TouchSkin.setActive(Studio.skin)
  U.log("1. new skin:", Studio.skin.id, "controls:", #Studio.page().controls)

  -- 2. Desktop canvas preset
  for i, c in ipairs(Studio.CANVASES) do
    if c.id == "desktop_1080" then Studio.setCanvas(i) end
  end
  U.log("2. canvas:", Studio.canvas().label, Studio.canvas().w .. "x" .. Studio.canvas().h)

  -- 3. Drop the bezel art on the window
  Studio.filedropped(droppedFile("assets/skins/tv_crt/img/tv-integer.png"))
  U.log("3. drop:", Studio.status)
  U.log("   bezel:", tostring(Studio.page().imagePath), "root:", Studio.skin.root)

  -- 4. Detect the screen hole from the art's alpha
  Studio.detectViewport()
  local v = Studio.page().viewport
  U.log("4. detect:", Studio.status)
  U.log(("   viewport %.4f %.4f %.4f %.4f"):format(v.x, v.y, v.w, v.h))
  shot("author_studio.png")

  -- 5. Save
  Studio.save()
  U.log("5. save:", Studio.status)

  -- what landed on disk
  local root = "skins/my_tv"
  for _, name in ipairs(love.filesystem.getDirectoryItems(root)) do
    local info = love.filesystem.getInfo(root .. "/" .. name)
    U.log("   file:", name, info and info.type)
  end
  local src = love.filesystem.read(root .. "/skin.lua")
  U.log("   skin.lua bytes:", src and #src)
  U.log("   skin.lua:", (src or ""):gsub("%s+", " "):sub(1, 260))

  -- 6. Load the saved folder back as a normal skin and play through it
  Studio.unload()
  local reloaded, err = TouchSkin.load(root, "my_tv")
  U.log("6. reload:", reloaded and "ok" or tostring(err),
        "format:", reloaded and reloaded.format,
        "controls:", reloaded and #reloaded.pages[1].controls)

  game.save.options.touchControls = { enabled = true, skin = "my_tv" }
  game.save.options.tilt = 0
  game.save.options.zoom = 0
  game.save.options.pipelines = {}
  game:applyOptions()
  local TouchControls = require("src.core.TouchControls")
  U.log("   active:", tostring(TouchControls.skinId), "err:", tostring(TouchControls.skinError))
  U.log("   decorativeOnly:", TouchSkin.decorativeOnly(), "drawable:", TouchSkin.drawable())

  love.draw = baseDraw
  U.teleport(game, "PALLET_TOWN", 10, 8, "down")
  U.wait(12)
  U.shot(game, dir .. "/author_result.png")

  U.log("done")
  love.event.quit()
  while true do coroutine.yield() end
end

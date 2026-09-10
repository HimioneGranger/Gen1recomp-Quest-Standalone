-- Driver: shoots the launcher's Touch Controls editor with the built-in pad
-- and with the bundled skin picked, so the Skin row (#1386) can be eyeballed.
-- The editor is a top-level love.draw branch in main.lua, not a stack state,
-- so this stands in for that branch and captures the frame itself.
--   SHOT_DIR=/tmp/skin POKEPORT_DRIVER=tests/drivers/touch_skin_editor_shot.lua love .
return function(game)
  local U = dofile("tests/drivers/util.lua")
  local Editor = require("src.ui.TouchControlsEditor")
  local TouchControls = require("src.core.TouchControls")

  local dir = os.getenv("SHOT_DIR") or "/tmp/skin"
  os.execute('mkdir -p "' .. dir .. '" 2>/dev/null')
  love.window.setMode(432, 768, { resizable = true, highdpi = true })
  U.wait(2)

  local pending = nil
  love.draw = function()
    Editor.draw()
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
    for _ = 1, 60 do
      if not pending then break end
      coroutine.yield()
    end
    U.wait(3)
    local f = io.open(dir .. "/" .. name, "rb")
    if f then f:close() U.log("shot", name) else U.log("FAIL shot", name) end
  end

  Editor.load({ onClose = function() end })
  U.wait(5)
  U.log("skins:", #Editor.skins, "label:", Editor.skinLabel())
  shot("editor_pad.png")

  Editor.cycleSkin(1)
  U.wait(5)
  U.log("picked:", tostring(TouchControls.skinId), Editor.skinLabel())
  shot("editor_skin.png")

  Editor.exportSkin()
  U.wait(5)
  U.log("export:", tostring(Editor.exportMsg))
  U.log("skins after export:", #Editor.skins)
  shot("editor_export.png")

  U.log("done")
  love.event.quit()
  while true do coroutine.yield() end
end

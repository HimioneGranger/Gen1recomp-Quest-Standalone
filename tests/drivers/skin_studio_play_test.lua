-- Driver: presses Play in the Skin Studio the way the button does, then keeps
-- drawing and pumping update so the deferred handoff runs.  Regression cover
-- for the crash where Play unloaded the studio inside its own draw pass.
--   POKEPORT_DRIVER=tests/drivers/skin_studio_play_test.lua love .
return function(game)
  local U = dofile("tests/drivers/util.lua")
  local Studio = require("src.ui.SkinStudio")

  love.window.setMode(1280, 720, { resizable = true, highdpi = true })
  U.wait(2)

  local booted, bootVersion = false, nil
  Studio.load({
    version = "red",
    onClose = function() end,
    onPlay = function(v)
      -- what main.lua's handler does: unload, then boot
      Studio.unload()
      booted, bootVersion = true, v
    end,
  })
  U.wait(3)
  U.log("loaded skin:", Studio.skin and Studio.skin.id)

  Studio.skinIdField = "play_probe"

  -- press Play exactly as the inspector button does
  Studio.play()
  U.log("after play(): pendingPlay =", tostring(Studio.pendingPlay),
        "skin alive =", tostring(Studio.skin ~= nil), "booted =", tostring(booted))
  U.log("status:", tostring(Studio.status))

  -- the frame that queued the handoff must still draw
  local okDraw, errDraw = pcall(Studio.draw)
  U.log("draw on the click frame:", okDraw, errDraw or "")

  -- now the deferred handoff
  local okUp, errUp = pcall(Studio.update, 1 / 60)
  U.log("update handoff:", okUp, errUp or "")
  U.log("booted =", tostring(booted), "version =", tostring(bootVersion),
        "skin =", tostring(Studio.skin))

  -- and a draw after teardown, which is what actually crashed before
  local okAfter, errAfter = pcall(Studio.draw)
  U.log("draw after teardown:", okAfter, errAfter or "")

  local okUp2 = pcall(Studio.update, 1 / 60)
  U.log("second update:", okUp2, "booted still once =", tostring(booted))

  if okDraw and okUp and okAfter and booted then
    U.log("RESULT pass")
  else
    U.log("RESULT FAIL")
  end
  love.event.quit()
  while true do coroutine.yield() end
end

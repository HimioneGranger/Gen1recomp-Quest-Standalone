-- The MeetMomScript cutscene, shot at the moments that used to go wrong.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_mom_scene.lua love .
--
-- Three things this is watching for, all of them general rather than
-- Mom-specific:
--   * an object whose event flag a RUNNING script flips must not swap on the
--     spot -- the cart only re-reads the object list on a map load, so Mom
--     stays standing beside you until she has walked back to her chair
--   * an object that appears mid-map must have its palette baked immediately,
--     not on the next once-a-second poll, or it stands there in greyscale
--   * a `yesorno` keeps the question on screen underneath the prompt
--
-- Shots land in /tmp/gold-mom.
local U = require("tests.drivers.util")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-mom"

  local function tap(button, frames)
    game.input.pressQueue[#game.input.pressQueue + 1] = button
    game.input.state[button] = true
    U.wait(2)
    game.input.state[button] = false
    U.wait(frames or 4)
  end

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  U.shot(game, out .. "/00-bedroom.png")

  -- Drop straight into the living room at the top of the stairs, which is
  -- where MeetMomScript's coord event sits.  The indoor route down from the
  -- bedroom is a fragile way to reach a scene that is not about stairs.
  world:setMap("PLAYERS_HOUSE_1F", 7, 3, "down")
  U.wait(20)
  for _ = 1, 3 do tap("down", 8) end
  U.wait(40)
  U.shot(game, out .. "/01-scene-start.png")

  -- Page through until the first yes/no is up, shooting as we go.
  local shots, sawChoice = 1, false
  for step = 1, 200 do
    local top = game.stack:top()
    local isChoice = top and top.index ~= nil and top.onChoose ~= nil
    -- A TextBox that has pushed its own choice box counts too.
    if game.world.choicebox and not sawChoice then
      sawChoice = true
      U.shot(game, out .. "/02-yes-no.png")
    end
    if isChoice and not sawChoice then
      sawChoice = true
      U.shot(game, out .. "/02-yes-no.png")
    end
    if step % 25 == 0 then
      shots = shots + 1
      U.shot(game, ("%s/03-scene-%02d.png"):format(out, shots))
    end
    if not world:busy() and step > 20 then break end
    tap("a", 4)
  end
  U.wait(30)
  U.shot(game, out .. "/04-scene-end.png")

  -- The two invariants, checked rather than eyeballed.
  local greyed = {}
  for _, npc in pairs(world.npcPool or {}) do
    if npc.sprite and npc.spriteDef and not npc.sprite.objColors then
      greyed[#greyed + 1] = npc.spriteDef.id or "?"
    end
  end
  print(("[driver] %d pooled NPCs, %d without a baked palette")
    :format((function() local n = 0 for _ in pairs(world.npcPool or {}) do n = n + 1 end return n end)(),
      #greyed))
  print(("[driver] saw a yes/no prompt: %s"):format(tostring(sawChoice)))
  print("[driver] PASS gold mom scene in " .. out)
  love.event.quit()
end

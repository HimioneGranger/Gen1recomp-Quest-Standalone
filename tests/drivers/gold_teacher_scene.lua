-- NewBarkTown_TeacherStopsYouScene1/2, the coord event that stops you leaving
-- New Bark Town before Elm has given you a mon.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_teacher_scene.lua love .
--
-- What this is watching for:
--   * `follow NEWBARKTOWN_TEACHER, PLAYER` drags the player back into town
--     behind her.  Without it the player never leaves the coord event's tile,
--     the scene fires again the moment it ends, and she is back at her spawn
--     starting the same speech over -- which is what "she jumps back to her
--     original spot" looks like from the outside.
--   * she should be standing NEXT TO the player for the middle line, not back
--     at (6,8).
--
-- Shots land in /tmp/gold-teacher; the position trace goes to stdout.
local U = require("tests.drivers.util")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-teacher"

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

  -- SCENE_NEWBARKTOWN_TEACHER_STOPS_YOU is scene 0, the map's starting scene,
  -- so a fresh save is already in it.
  world:setMap("NEW_BARK_TOWN", 2, 8, "left")
  U.wait(30)
  U.shot(game, out .. "/00-before.png")

  local function teacher()
    for _, npc in ipairs(world.npcs or {}) do
      if npc.def and npc.def.index == 1 then return npc end
    end
    return nil
  end

  local function trace(tag)
    local t = teacher()
    print(("[driver] %-14s player=(%d,%d) teacher=(%s,%s) scene=%d busy=%s")
      :format(tag, world.player.cellX, world.player.cellY,
        t and tostring(t.cellX) or "-", t and tostring(t.cellY) or "-",
        world:scene(), tostring(world:busy())))
  end

  trace("start")
  -- One step left onto (1,8), the coord event's tile.
  tap("left", 30)
  trace("stepped")

  -- Page the scene through.  The middle shot is the one that matters: she has
  -- to be standing next to the player, not back at her spawn.
  local shots, adjacent = 0, false
  for step = 1, 400 do
    local t = teacher()
    if t and math.abs(t.cellX - world.player.cellX) <= 1
        and t.cellY == world.player.cellY then
      if not adjacent then
        adjacent = true
        U.shot(game, out .. "/01-she-is-here.png")
        trace("adjacent")
      end
    end
    if step % 25 == 0 then
      shots = shots + 1
      U.shot(game, ("%s/02-scene-%02d.png"):format(out, shots))
      trace("frame " .. shots)
    end
    -- Done when the scene has finished AND the player has been walked off the
    -- trigger tile.
    if not world:busy() and world.player.cellX ~= 1 and step > 20 then break end
    tap("a", 4)
  end
  trace("scene over")
  U.shot(game, out .. "/03-after.png")

  -- Hands off for a second: nothing may re-trigger.
  local restarted = false
  for _ = 1, 120 do
    if world:busy() then restarted = true end
    U.wait(1)
  end
  trace("idle")

  local dragged = world.player.cellX ~= 1
  print(("[driver] the player was walked back into town: %s")
    :format(tostring(dragged)))
  print(("[driver] she stood next to the player mid-scene: %s")
    :format(tostring(adjacent)))
  print(("[driver] the scene re-triggered while idle: %s")
    :format(tostring(restarted)))
  print(("[driver] %s gold teacher scene in %s")
    :format((dragged and adjacent and not restarted) and "PASS" or "FAIL", out))
  love.event.quit()
end

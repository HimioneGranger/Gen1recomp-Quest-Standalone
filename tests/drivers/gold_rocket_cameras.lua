-- SecurityCamera1a (maps/TeamRocketBaseB1F.asm:22): the two Rocket grunts the
-- camera calls down on you, ONE AFTER ANOTHER.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_rocket_cameras.lua love .
--
-- The cart has exactly ONE object for both of them (TEAMROCKETBASEB1F_ROCKET1)
-- and stages it twice: `moveobject` back to the corridor mouth, `appear`,
-- `applymovement SecurityCameraMovement1`, battle, `disappear` -- then the same
-- five commands again for the second grunt.  So the second run MUST start from
-- the cell the second `moveobject` names (19,2) and not from wherever the first
-- grunt stopped, or he sprints on past the player and off the room.
--
-- The driver prints where the object stands at the start and the end of each
-- of the two approach walks and shoots both.  Shots land in /tmp/gold-cameras.
local U = require("tests.drivers.util")
local Mon = require("src.battle.gen2.Mon")

local ROCKET1 = 1 -- def.objects index; the object const is this + 1

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-cameras"

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

  local starter = Mon.new(game.data, "TYPHLOSION", 60)
  assert(starter, "could not build a TYPHLOSION")
  game.save.party = { starter }

  world:setMap("TEAM_ROCKET_BASE_B1F", 23, 2, "right")
  U.wait(20)
  assert(world.map.id == "TEAM_ROCKET_BASE_B1F", tostring(world.map.id))

  -- Both guards the coord event checks: EVENT_SECURITY_CAMERA_1 (already seen)
  -- and EVENT_TEAM_ROCKET_BASE_POPULATION (the base already cleared out).  The
  -- second is the flag the two standing trainers on this floor carry, read off
  -- the object rather than named as a number.
  local rocket = world.map.def.objects[ROCKET1]
  world.events:set(world.map.def.objects[2].eventFlag, false)
  for _, ev in ipairs(world.map.def.coordEvents or {}) do
    if ev.x == 24 and ev.y == 2 then world.cameraEvent = ev end
  end

  local runs = {}
  local realBegin = world.beginMovement
  world.beginMovement = function(self, objectId, bytes, onDone)
    if objectId == ROCKET1 + 1 then
      local ent = self:objectEntity(objectId)
      runs[#runs + 1] = {
        fromX = ent and ent.cellX, fromY = ent and ent.cellY, bytes = #(bytes or {}),
      }
    end
    return realBegin(self, objectId, bytes, onDone)
  end

  U.shot(game, out .. "/00-corridor.png")
  U.hold(game, "right", 20)
  U.wait(10)

  local shots = 0
  local battles = 0
  for _ = 1, 2000 do
    local top = game.stack:top()
    if top and top.battle then
      battles = battles + 1
      U.shot(game, ("%s/%02d-battle.png"):format(out, battles))
      for _ = 1, 900 do
        if top.battle.over then break end
        tap("a", 3)
      end
      U.wait(20)
    end
    if #runs > shots then
      shots = #runs
      U.wait(30)
      U.shot(game, ("%s/%02d-approach.png"):format(out, shots))
    end
    if not world:busy() and battles >= 2 then break end
    tap("a", 2)
  end

  for i, run in ipairs(runs) do
    print(("[driver] approach %d started at (%s,%s), %d movement bytes")
      :format(i, tostring(run.fromX), tostring(run.fromY), run.bytes))
  end
  U.wait(20)
  U.shot(game, out .. "/09-after.png")

  assert(#runs >= 2, ("only %d approach walks ran; the camera calls two grunts")
    :format(#runs))
  for i, run in ipairs(runs) do
    assert(run.fromX == 19 and run.fromY == 2,
      ("approach %d started at (%s,%s); every `moveobject` in SecurityCamera1a "
       .. "names (19,2)"):format(i, tostring(run.fromX), tostring(run.fromY)))
  end
  print("[driver] PASS gold rocket security cameras in " .. out)
  love.event.quit()
end

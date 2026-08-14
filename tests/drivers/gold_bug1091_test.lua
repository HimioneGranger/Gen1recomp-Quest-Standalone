-- #1091: does GAME SPEED change the wild encounter rate per STEP?
--   POKEPORT_GAME=gold POKEPORT_TOUCH=0 \
--     POKEPORT_DRIVER=tests/drivers/gold_bug1091_test.lua love .
local Encounter = require("src.battle.gen2.Encounter")
local Player = require("src.world.gen2.Player")
local Mon = require("src.battle.gen2.Mon")

return function(game)
  local rolls, hits, steps = 0, 0, 0

  local realTriggers = Encounter.triggers
  Encounter.triggers = function(rate, random)
    rolls = rolls + 1
    if realTriggers(rate, random) then hits = hits + 1 end
    return false
  end

  local World = require("src.world.gen2.World")
  local ticks = 0
  local realWorldStep = World.step
  World.step = function(self)
    ticks = ticks + 1
    return realWorldStep(self)
  end

  local realUpdate = Player.update
  Player.update = function(self)
    local landed = realUpdate(self)
    if landed then steps = steps + 1 end
    return landed
  end

  local function wait(n) for _ = 1, n do coroutine.yield() end end
  local function clearDirs()
    for _, d in ipairs({ "up", "down", "left", "right" }) do
      game.input.state[d] = false
    end
  end

  wait(30)
  local world = game.world
  game.save.party = { Mon.new(game.data, "PIDGEY", 5) }

  local function measure(speed, yields)
    world:setMap("ROUTE_29", 44, 12, "right")
    wait(20)
    world.wildCooldown = 0
    game.speedOverride = speed
    rolls, hits, steps, ticks = 0, 0, 0, 0
    local dir = "right"
    for i = 1, yields do
      if i % 8 == 0 then dir = (dir == "right") and "left" or "right" end
      clearDirs()
      game.input.state[dir] = true
      table.insert(game.input.pressQueue, dir)
      coroutine.yield()
    end
    clearDirs()
    game.speedOverride = 1
    wait(5)
    return rolls, hits, steps, ticks
  end

  local r1, h1, s1, t1 = measure(1, 900)
  local r2, h2, s2, t2 = measure(200, 60)
  print(("[driver] 1X   frames=%d cells=%d rolls=%d hits=%d rolls/cell=%.3f")
    :format(t1, s1, r1, h1, s1 > 0 and r1 / s1 or 0))
  print(("[driver] 200X frames=%d cells=%d rolls=%d hits=%d rolls/cell=%.3f")
    :format(t2, s2, r2, h2, s2 > 0 and r2 / s2 or 0))

  Encounter.triggers = realTriggers
  Player.update = realUpdate
  World.step = realWorldStep
  local rate1 = s1 > 0 and r1 / s1 or 0
  local rate2 = s2 > 0 and r2 / s2 or 0
  assert(s1 > 20 and s2 > 20, "not enough walked cells to judge")
  assert(math.abs(rate1 - rate2) < 0.05,
    ("rolls per cell changed with GAME SPEED: %.3f vs %.3f"):format(rate1, rate2))
  print("[driver] PASS encounter rolls are one per walked cell at every speed")
end

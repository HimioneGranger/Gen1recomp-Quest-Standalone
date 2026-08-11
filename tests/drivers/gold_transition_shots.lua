-- DoBattleTransition, frame by frame.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_transition_shots.lua love .
--
-- Shoots each of the four outros (spin / speckle / sine / zoom) plus the Poke
-- Ball overlay a trainer battle stamps over the map first.  POKEPORT_SHOT_INTERVAL
-- picks the sampling; the default walks the whole thing at 6 frames.
--
-- Shots land in /tmp/gold-transition/<style>/.
local U = require("tests.drivers.util")

local Transition = require("src.ui.gen2.BattleTransition")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-transition"
  local interval = tonumber(os.getenv("POKEPORT_SHOT_INTERVAL") or "") or 6

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")
  world:setMap("NEW_BARK_TOWN", 5, 8, "down")
  U.wait(20)

  local function run(style, trainer)
    local done = false
    game.stack:push(Transition.new(game, {
      world = world,
      style = style,
      trainer = trainer,
      onDone = function() done = true end,
    }))
    -- Shoot the flash sparsely and the outro (the part with the shape in it)
    -- at every interval, so a nine-shot run is not all palette pulses.
    local state = game.stack:top()
    local shots, outroShots = 0, 0
    for frame = 1, 600 do
      local outro = state.phase == "outro"
      local want = outro and (outroShots % interval == 0)
        or (not outro and frame % 24 == 1)
      if want then
        shots = shots + 1
        U.shot(game, ("%s/%s/%s-%02d.png")
          :format(out, style, outro and "outro" or "flash", shots))
      end
      if outro then outroShots = outroShots + 1 end
      if done then break end
      U.wait(1)
    end
    print(("[driver] %-8s %d shots, finished=%s")
      :format(style, shots, tostring(done)))
    -- The state pops itself; if it did not, take it off so the next run starts
    -- from a clean stack.
    if not done then game.stack:pop() end
    U.wait(5)
  end

  run("spin", true)
  run("speckle", false)
  run("sine", false)
  run("zoom", false)

  print("[driver] shots in " .. out)
  love.event.quit()
end

-- Gold GBC palettes: one screenshot of New Bark Town per time of day, plus
-- one of Elm's lab (PALETTE_DAY, so it must NOT go dark at night).
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_palette_shots.lua love .
--
-- Palettes are the one part of the Gen 2 port a test cannot assert -- "is the
-- roof the right blue at 6am" only a human can answer -- so this driver's job
-- is to put those four frames on disk side by side.
local U = require("tests.drivers.util")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-palettes"

  local function world()
    return game.world
  end

  local function rebake(hour)
    local w = world()
    w.clockHour = hour
    -- Force the re-resolve the once-a-second poll would eventually do.
    w.paletteClock = 0
    if w:applyPalettes() then
      w.mapImages = {}
      w.mapImage = w:imageFor(w.map.id)
      w:rebuildNeighbors()
    end
    return w.daytime
  end

  U.wait(45)
  assert(world() and world().map, "gold world did not boot")
  -- A New Game starts in the bedroom now (SPAWN_HOME); step outside, which is
  -- where the time-of-day palettes are worth looking at.
  if world().map.id ~= "NEW_BARK_TOWN" then
    world():setMap("NEW_BARK_TOWN", 13, 6, "down")
    U.wait(15)
  end
  assert(world().map.id == "NEW_BARK_TOWN",
    "boot map " .. tostring(world().map.id))

  if not world().palettes then
    print("[driver] SKIP no palettes.lua in this cache -- re-import Gold")
    return
  end

  for _, entry in ipairs({
    { hour = 6, name = "morn" },
    { hour = 13, name = "day" },
    { hour = 21, name = "nite" },
  }) do
    local daytime = rebake(entry.hour)
    U.wait(4)
    U.shot(game, ("%s/newbark-%s.png"):format(out, entry.name))
    print(("[driver] %s (hour %d) -> %s"):format(entry.name, entry.hour, daytime))
    assert(daytime == entry.name:upper(),
      ("hour %d resolved to %s"):format(entry.hour, tostring(daytime)))
  end

  -- Elm's lab is PALETTE_DAY: walking in at 9pm must still be lit like day.
  rebake(21)
  world():setMap("ELMS_LAB", 4, 6, "up")
  U.wait(10)
  assert(world().daytime == "DAY",
    "ELMS_LAB at 21:00 should stay PALETTE_DAY, got "
      .. tostring(world().daytime))
  U.shot(game, out .. "/elmslab-night-is-day.png")

  print("[driver] PASS gold palette shots in " .. out)
end

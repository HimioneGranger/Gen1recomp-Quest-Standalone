-- Assertion driver: a run that skips the boot cinema still starts on an
-- anchored game clock.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold \
--     POKEPORT_DRIVER=tests/drivers/gold_clock_anchor.lua love .
--
-- NewGame (pokegold engine/menus/intro_menu.asm) calls OakSpeech, whose first
-- line is `farcall InitClock`, so wStartHour / wStartMinute always exist before
-- InitializeWorld.  A driver run never reaches that screen; without the anchor
-- the save has no base and every hour read falls through to the host clock, so
-- the same run is MORN in the morning and NITE at night and the grass rolls a
-- different table each time.  Prints PASS/FAIL and quits, because LOVE only
-- flushes stdout on exit.
local U = require("tests.drivers.util")

local Clock = require("src.core.gen2.Clock")
local Palettes = require("src.world.gen2.Palettes")

return function(game)
  local failures = 0
  local function want(label, ok, detail)
    if ok then
      U.log("ok   " .. label)
    else
      failures = failures + 1
      U.log("FAIL " .. label .. " (" .. tostring(detail) .. ")")
    end
  end

  U.wait(30)
  local world = game.world
  want("the world booted", world ~= nil and world.map ~= nil,
    world and world.status)
  if not (world and world.map) then
    U.log(failures == 0 and "PASS" or "FAIL")
    love.event.quit()
    return
  end

  want("the new game anchored the clock", Clock.isSet(game.save),
    "save.rtc.startMinute is nil")

  local hour = world:hour()
  want("World:hour reads that base", hour == Clock.hour(game.save),
    ("world %s vs clock %s"):format(tostring(hour),
      tostring(Clock.hour(game.save))))
  want("the map is lit by the same hour",
    world.daytime == Palettes.daytimeFor(world.map.def, hour, world.flashUsed),
    ("daytime %s at hour %s"):format(tostring(world.daytime), tostring(hour)))

  -- The pin a screenshot run uses has to move both halves together.
  local forced = tonumber(os.getenv("POKEPORT_GOLD_HOUR") or "")
  if forced then
    want("POKEPORT_GOLD_HOUR pins World:hour", hour == forced % 24, hour)
    want("and the palette follows it",
      world.daytime == Palettes.daytimeFor(world.map.def, forced,
        world.flashUsed), tostring(world.daytime))
  end

  -- The map's own PALETTE_* can pin the daytime (the bedroom is PALETTE_DAY),
  -- so log the clock's answer next to the map's.
  U.log(("clock %02d:%02d, clock daytime %s, map daytime %s, anchored %s"):format(
    world:hour(), world:minute(), Palettes.clockDaytime(hour),
    tostring(world.daytime), tostring(Clock.isSet(game.save))))
  U.log(failures == 0 and "PASS" or "FAIL")
  love.event.quit()
end

-- Assertion driver: the bedroom wall radio after the starter, played through
-- the real bg event -> jumpstd Radio1Script -> `special MapRadio` chain.
--
--   POKEPORT_GAME=gold POKEPORT_IDENTITY=gold-dev \
--     POKEPORT_DRIVER=tests/drivers/gold_wall_radio.lua love .
--
-- tests/gen2_map_radio_test.lua drives the screen's own logic; what it cannot
-- see is the dispatch: a real A press on the radio tile, the std script's
-- setval/special pair, the screen landing on the real stack, and the music
-- surviving the exit (ExitPokegearRadio_HandleMusic).  Each check here does it
-- the way a player would, twice, because the replay is half the point: the
-- radio must answer every interaction, not just the first.
local U = require("tests.drivers.util")

return function(game)
  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")
  local Music = require("src.core.Music")

  -- Past the starter: PlayersHouseRadioScript's `checkevent
  -- EVENT_GOT_A_POKEMON_FROM_ELM` picks the .NormalRadio arm, which is
  -- `jumpstd Radio1Script`.
  world.events:set(26, true)

  -- The radio bg event sits at (3,1) in PLAYERS_HOUSE_2F; (3,2) facing up
  -- reads it.
  assert(world:setMap("PLAYERS_HOUSE_2F", 3, 2, "up"),
    "setMap failed for PLAYERS_HOUSE_2F")
  U.wait(10)

  local function radioScreen()
    local top = game.stack:top()
    return (top and top.screenId == "Gen2MapRadio") and top or nil
  end

  local function listenOnce(round)
    U.tap(game, "a")
    local screen
    for _ = 1, 120 do
      screen = radioScreen()
      if screen then break end
      U.wait(1)
    end
    assert(screen, round .. ": A on the radio did not open the wall radio")
    assert(screen.station, round .. ": no station resolved")
    -- PlayRadio holds 100 frames with the station name up, then the show
    -- starts its channel song.
    U.wait(110)
    for _ = 1, 240 do
      if screen.radio.music then break end
      U.wait(1)
    end
    assert(screen.radio.music, round .. ": the show never started its song")
    local song = screen.radio.music
    assert(Music.current() == song,
      ("%s: playing %s, want %s"):format(round,
        tostring(Music.current()), tostring(song)))
    -- A closes it, and the song KEEPS PLAYING as the map music
    -- (RadioMusicRestartDE wrote it into wMapMusic).
    U.tap(game, "a")
    for _ = 1, 60 do
      if not radioScreen() then break end
      U.wait(1)
    end
    assert(not radioScreen(), round .. ": A did not close the radio")
    U.wait(5)
    assert(Music.current() == song,
      round .. ": the song stopped when the radio closed")
    assert(Music.mapSong() == song,
      round .. ": the song did not become the map music")
    U.log(round .. ": radio played " .. song .. " and it persists")
    return song
  end

  listenOnce("first listen")
  -- Back out, talk again: the radio must play again.
  local song = listenOnce("second listen")

  -- A map change is what replaces the song, exactly as a new map's
  -- PlayMapMusic would.
  assert(world:setMap("NEW_BARK_TOWN", 8, 8, "down"),
    "setMap failed for NEW_BARK_TOWN")
  U.wait(10)
  assert(Music.current() ~= song,
    "leaving the house did not restore the map's own music")
  U.log("map change replaced the radio song with "
    .. tostring(Music.current()))

  print("[driver] PASS gold wall radio")
  love.event.quit()
end

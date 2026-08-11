-- Assertion driver: the champion's ending, end to end on the real game.
--
--   POKEPORT_GAME=gold POKEPORT_IDENTITY=gold-dev POKEPORT_SPEED=200 \
--     POKEPORT_DRIVER=tests/drivers/gold_hof_continue.lua love .
--
-- The chain under test is the cart's own (engine/events/halloffame.asm,
-- engine/overworld/scripting.asm ReturnFromCredits, engine/menus/
-- intro_menu.asm Continue / FinishContinueFunction):
--
--   halloffame -> induction ceremony -> credits roll -> `jp Reset` (title)
--   CONTINUE   -> wSpawnAfterChampion = SPAWN_LANCE consumed -> New Bark Town
--
-- tests/gen2_hof_continue_test.lua proves each link against registry fakes;
-- this runs the real screens on the real stack, lets the real induction write
-- the real save slot, and then CONTINUEs through Game2:continueGame exactly
-- as the main menu does.  The active save slot is backed up first and
-- restored on the way out, whatever happens.
local U = require("tests.drivers.util")

local Gen2Save = require("src.core.gen2.Save")
local Mon = require("src.battle.gen2.Mon")

return function(game)
  U.wait(45)
  assert(game.world and game.world.map, "gold world did not boot")

  -- Guard the slot: the induction's SaveGameData writes it for real.
  local main, bak, tmp = Gen2Save.filenames("gold")
  local keep = {}
  for _, name in ipairs({ main, bak, tmp }) do
    keep[name] = love.filesystem.read(name)
  end
  local function restoreSlot()
    for _, name in ipairs({ main, bak, tmp }) do
      if keep[name] then
        love.filesystem.write(name, keep[name])
      else
        love.filesystem.remove(name)
      end
    end
  end

  local ok, err = pcall(function()
    local world, save, data = game.world, game.save, game.data
    save.party = { Mon.new(data, "TYPHLOSION", 50) }
    assert(save.party[1], "no party could be built from this cache")
    save.player.name = save.player.name or "GOLD"

    -- Stand where Script_halloffame runs: the Hall of Fame chamber.
    assert(world:setMap("HALL_OF_FAME", 4, 12, "up"), "setMap HALL_OF_FAME")
    U.wait(5)

    -- The `halloffame` command, off the live world.
    local resumed = false
    assert(world:hallOfFame(function() resumed = true end),
      "halloffame did not take the screen")
    assert(save.spawnAfterChampion == "SPAWN_LANCE",
      "induction did not write wSpawnAfterChampion")

    -- The ceremony auto-advances; the roll follows it on the same call.  A
    -- first-time champion cannot skip, so ride it out and press A at THE END.
    local sawCredits = false
    for _ = 1, 700 do
      local top = game.stack:top()
      if top and top.screenId == "Gen2Credits" then
        sawCredits = true
        if top.exiting then break end
      end
      U.wait(30)
    end
    assert(sawCredits, "the credits never followed the induction")
    local top = game.stack:top()
    assert(top and top.exiting, "the credits never reached CREDITS_END")
    U.tap(game, "a")
    U.wait(10)

    -- `jp Reset`: back on the title, world torn down, script resumed first.
    assert(resumed, "the script never resumed out of the credits")
    assert(game.phase == "boot", "the credits did not end on the title screen")
    assert(game.world == nil, "the world survived the reset")
    U.log("post-credits: reset to title, as FinishContinueFunction does")

    -- The slot on disk carries the one-shot and the sealed room.
    local written = Gen2Save.load("gold")
    assert(written, "the induction never saved")
    assert(written.spawnAfterChampion == "SPAWN_LANCE",
      "the saved slot lost wSpawnAfterChampion")
    assert(written.position and written.position.map == "HALL_OF_FAME",
      "the saved position is not the Hall of Fame")
    U.log("slot: spawnAfterChampion=SPAWN_LANCE, position=HALL_OF_FAME")

    -- CONTINUE, exactly as the main menu's row does it.
    game:continueGame(written)
    U.wait(10)
    assert(game.world and game.world.map, "CONTINUE did not boot a world")
    assert(game.world.map.id == "NEW_BARK_TOWN",
      "CONTINUE resumed on " .. tostring(game.world.map.id)
        .. ", expected NEW_BARK_TOWN")
    assert(game.world.player.cellX == 13 and game.world.player.cellY == 6,
      ("CONTINUE landed at (%d,%d), expected SPAWN_NEW_BARK (13,6)")
        :format(game.world.player.cellX, game.world.player.cellY))
    assert(game.save.spawnAfterChampion == nil,
      "PostCreditsSpawn did not zero the byte")
    U.log("CONTINUE: spawned at New Bark Town, byte consumed")
  end)

  restoreSlot()
  assert(ok, err)
  U.log("PASS gold_hof_continue")
  love.event.quit()
end

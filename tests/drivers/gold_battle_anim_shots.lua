-- Contact sheet: the Gen 2 battle-animation runtime, frame by frame.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_battle_anim_shots.lua love .
--
-- Shoots the 72-frame intro slide and then a run of move animations, one shot
-- every few frames, into /tmp/gold-anims.  This is the only way to check the
-- object functions: they are pure arithmetic on byte fields and a test can say
-- "the struct moved", but only a picture says the flame went the right way.
--
-- POKEPORT_ANIM_MOVES=TACKLE,EMBER picks the moves; the default set covers one
-- animation from each family the runtime has to get right (a straight throw,
-- a spiral, a screen shake, a per-scanline sink, a palette cycle).
local U = require("tests.drivers.util")

local Mon = require("src.battle.gen2.Mon")

local DEFAULT_MOVES = {
  "TACKLE", "EMBER", "WATER_GUN", "THUNDERSHOCK", "RAZOR_LEAF",
  "EARTHQUAKE", "WITHDRAW", "DIG", "SING", "ABSORB",
  -- The screen-wide deformations, which were no-ops until the sixth pass:
  -- rolling water, a warp, an afterimage and a melt.
  "SURF", "WHIRLPOOL", "PSYCHIC_M", "TELEPORT", "NIGHT_SHADE",
  "DOUBLE_TEAM", "ACID_ARMOR",
}

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-anims"
  local interval = tonumber(os.getenv("POKEPORT_SHOT_INTERVAL") or "4")

  local moves = {}
  local requested = os.getenv("POKEPORT_ANIM_MOVES")
  if requested then
    for name in requested:gmatch("[^,]+") do moves[#moves + 1] = name end
  else
    moves = DEFAULT_MOVES
  end

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  local player = Mon.new(game.data, "CYNDAQUIL", 30)
  assert(player, "could not build a CYNDAQUIL")
  game.save.party = { player }
  local wild = Mon.new(game.data, "PIDGEY", 30)
  assert(world:startBattle({ wild = wild }), "startBattle failed")
  -- DoBattleTransition owns the screen first now; wait it out.
  local battle
  for _ = 1, 600 do
    local top = game.stack:top()
    if top and top.battle then battle = top break end
    U.wait(1)
  end
  assert(battle and battle.battle, "battle screen is not on the stack")
  assert(battle.anims and battle.anims.scripts,
    "battle_anims.lua has no scripts -- re-import Gold")

  -- The intro slide, which runs before any input is read.
  for frame = 0, 72, 6 do
    U.shot(game, ("%s/00-slide-%02d.png"):format(out, frame))
    U.wait(6)
  end

  -- Then each move's own animation, started directly rather than through the
  -- menu so the shot numbering stays predictable.
  local missing = {}
  for index, move in ipairs(moves) do
    battle.anim = nil
    if not battle:animForMove(move, "player") then
      missing[#missing + 1] = move
    else
      -- BattleState:update steps the runner itself, so the driver only waits
      -- and shoots; stepping here too would run it at double speed.
      local shot = 0
      while battle.anim and shot < 400 do
        if shot % interval == 0 then
          U.shot(game, ("%s/%02d-%s-%03d.png"):format(out, index, move, shot))
        end
        shot = shot + 1
        U.wait(1)
      end
      assert(shot < 400, move .. " never finished")
      print(("[driver] %-14s %d frames"):format(move, shot))
    end
  end

  if #missing > 0 then
    print("[driver] no animation for: " .. table.concat(missing, ", "))
  end
  print("[driver] PASS gold battle anims in " .. out)
  love.event.quit()
end

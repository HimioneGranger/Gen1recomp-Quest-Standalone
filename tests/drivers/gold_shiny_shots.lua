-- The Red Gyarados, and an ordinary Miltank next to it for the contrast.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_shiny_shots.lua love .
--   POKEPORT_SHOT_DIR=/tmp/gold-shiny   (default)
--
-- A shiny in Gen 2 is not a second sprite: it is the SAME two-colour pic drawn
-- through the species' second palette row (data/pokemon/palettes.asm ships
-- `normal` and `shiny` for every species), which is why the Lake of Rage
-- Gyarados is red rather than a different Gyarados.  Palettes.monColors is the
-- one place that picks between the two rows, so this driver asserts the rows
-- really differ, builds the mon the way the cart does -- BATTLETYPE_FORCESHINY
-- writes ATKDEFDV_SHINY $EA / SPDSPCDV_SHINY $AA, not a `shiny` boolean -- and
-- then shoots the battle screen so a human can see the colour.
local U = require("tests.drivers.util")

local Mon = require("src.battle.gen2.Mon")
local Palettes = require("src.world.gen2.Palettes")
local GbcPalette = require("src.render.GbcPalette")

-- constants/battle_constants.asm: the DV pair BATTLETYPE_FORCESHINY forces.
-- Attack 14, Defense 10, Speed 10, Special 10 -- which is exactly the pattern
-- Mon.isShiny tests, so nothing here has to say `shiny = true` by hand.
local SHINY_DVS = { attack = 14, defense = 10, speed = 10, special = 10 }

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-shiny"

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  -- A shiny only reads as one in COLOR: on a DMG both palette rows fold to the
  -- same four greys, and the cart's own Gyarados is red for the same reason.
  GbcPalette.setMode("gbc")

  local pals = world.palettes
  local normal = Palettes.monColors(pals, "GYARADOS", false)
  local shiny = Palettes.monColors(pals, "GYARADOS", true)
  assert(normal and shiny, "no GYARADOS palette rows in the cache")
  local differ = false
  for i = 1, 4 do
    for c = 1, 3 do
      if normal[i][c] ~= shiny[i][c] then differ = true end
    end
  end
  assert(differ, "GYARADOS' shiny row is identical to its normal row")
  U.log(("GYARADOS normal (%d,%d,%d)/(%d,%d,%d)  shiny (%d,%d,%d)/(%d,%d,%d)")
    :format(normal[2][1], normal[2][2], normal[2][3],
      normal[3][1], normal[3][2], normal[3][3],
      shiny[2][1], shiny[2][2], shiny[2][3],
      shiny[3][1], shiny[3][2], shiny[3][3]))
  -- The Red Gyarados is red: its shiny row is the only one of the two whose
  -- brighter colour is dominated by RED.  Stated as a comparison rather than a
  -- literal so a re-import that shifts the 5-bit conversion still passes.
  local red = shiny[2]
  assert(red[1] > red[2] and red[1] > red[3],
    ("GYARADOS' shiny colour is not red: (%d,%d,%d)")
      :format(red[1], red[2], red[3]))

  local player = Mon.new(game.data, "CYNDAQUIL", 30)
  assert(player and #player.moves > 0, "could not build the player's mon")
  game.save.party = { player }
  game.save.inventory = { POKE_BALL = 5 }

  local function battleShot(species, level, dvs, name)
    local mon = Mon.new(game.data, species, level, { dvs = dvs })
    assert(mon, "no base data for " .. species)
    if dvs == SHINY_DVS then
      assert(mon.shiny,
        species .. " built from the FORCESHINY DVs did not come out shiny")
    else
      assert(not mon.shiny, species .. " came out shiny by accident")
    end
    player.hp = player.maxHp
    assert(world:startBattle({ wild = mon }), "startBattle failed")
    local battle
    for _ = 1, 900 do
      local top = game.stack:top()
      if top and top.battle then battle = top break end
      U.wait(1)
    end
    assert(battle, "battle screen never came up for " .. species)
    -- Let the intro slide finish so the enemy pic is fully on screen.
    U.wait(90)
    assert(U.shot(game, ("%s/%s.png"):format(out, name)), "no screenshot")
    -- Back out: RUN is the fourth menu item, but popping the state is enough
    -- for a screenshot driver and cannot fail on a speed tie.
    while game.stack:top() == battle do game.stack:pop() end
    U.wait(10)
  end

  battleShot("GYARADOS", 30, SHINY_DVS, "00-red-gyarados")
  battleShot("MILTANK", 30, { attack = 15, defense = 15, speed = 15,
    special = 15 }, "01-miltank")

  U.log("shiny shots in " .. out)
  love.event.quit()
end

-- #1159 (Fly / Dig leave the user on the field) and #1160 (64x64 front pics).
--
--   POKEPORT_GAME=gold POKEPORT_TOUCH=0 \
--     POKEPORT_DRIVER=tests/drivers/gold_bug1159_test.lua love .

local U = require("tests.drivers.util")

local Mon = require("src.battle.gen2.Mon")
local BattleState = require("src.ui.gen2.BattleState")

local function battleScreen(game)
  for _ = 1, 900 do
    local top = game.stack:top()
    if top and top.battle then return top end
    U.wait(1)
  end
  error("battle screen never came up")
end

local function drain(game, screen, frames)
  for _ = 1, (frames or 400) do
    if screen.phase == "menu" and #screen.queue == 0 and not screen.anim then
      return true
    end
    U.tap(game, "a")
    U.wait(3)
  end
  return false
end

-- One drawPic call with love.graphics.draw intercepted: how many blits it made
-- and where the first one landed.
local function probePic(screen, mon, back)
  local G = love.graphics
  local real = G.draw
  local count, x, y = 0, nil, nil
  G.draw = function(image, a, b, ...)
    count = count + 1
    if count == 1 then
      -- draw(image, x, y, ...) or draw(image, quad, x, y, ...)
      if type(a) == "number" then x, y = a, b else x, y = b, (...) end
    end
  end
  local ok, err = pcall(screen.drawPic, screen, mon, back)
  G.draw = real
  if not ok then error(err) end
  return count, x, y
end

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-bug1159"
  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")
  local failures = {}
  local function check(ok, what)
    print((ok and "[ok] " or "[FAIL] ") .. what)
    if not ok then failures[#failures + 1] = what end
  end

  ------------------------------------------------------------------ #1159
  local digger = Mon.new(game.data, "SANDSHREW", 30)
  local dig = assert(game.data.moves.DIG, "DIG missing from the Gold cache")
  digger.moves = { { id = "DIG", pp = dig.pp, maxPp = dig.pp } }
  game.save.party = { digger }
  local target = Mon.new(game.data, "SNORLAX", 40)
  target.moves = { { id = "SPLASH", pp = 40, maxPp = 40 } }
  assert(world:startBattle({ wild = target }), "startBattle failed")
  local screen = battleScreen(game)
  drain(game, screen, 300)

  local before = probePic(screen, screen.battle.player, true)
  check(before > 0, "the back pic is on the field before DIG")
  U.shot(game, out .. "/01-before-dig.png")

  screen:submit({ kind = "move", move = "DIG" })
  drain(game, screen, 600)

  check(BattleState.isVanished(screen.battle.player) == true,
    "SUBSTATUS_UNDERGROUND is set after the charge turn")
  local underground = probePic(screen, screen.battle.player, true)
  print("[driver] back-pic draws while underground: " .. underground)
  check(underground == 0, "the back pic is GONE for the charge turn")
  U.shot(game, out .. "/02-underground.png")

  -- The enemy front pic is untouched by the player's own dig.
  local foe = probePic(screen, screen.battle.enemy, false)
  check(foe > 0, "the enemy front pic is unaffected")

  -- Turn two: CheckCharge clears the bit and AppearUserRaiseSub redraws it.
  screen:submit({ kind = "move", move = "DIG" })
  drain(game, screen, 600)
  check(BattleState.isVanished(screen.battle.player) == false,
    "the substatus is cleared when the stored attack lands")
  local after = probePic(screen, screen.battle.player, true)
  print("[driver] back-pic draws after the attack: " .. after)
  check(after > 0, "the back pic is back on the field")
  U.shot(game, out .. "/03-resurfaced.png")

  ------------------------------------------------------------------ #1160
  -- A stubbed pic of each size through the same placement code.  trueColor is
  -- set so the probe never enters the GBC palette shader.
  local realPic = screen.pic
  local function place(size, back)
    local data = love.image.newImageData(size, size)
    local image = love.graphics.newImage(data)
    screen.pic = function() return image, true, "mods/front" .. size .. ".png" end
    local n, x, y = probePic(screen, screen.battle.enemy, back)
    screen.pic = realPic
    return n, x, y
  end

  local _, x56, y56 = place(56, false)
  print(("[driver] 56x56 front at (%s, %s)"):format(tostring(x56), tostring(y56)))
  check(x56 == 96 and y56 == 0, "vanilla 56x56 front pic is unmoved at (96, 0)")

  local _, x40, y40 = place(40, false)
  print(("[driver] 40x40 front at (%s, %s)"):format(tostring(x40), tostring(y40)))
  check(x40 == 104 and y40 == 16,
    "a small 40x40 front pic still stands on the box's ground line")

  local _, x64, y64 = place(64, false)
  print(("[driver] 64x64 front at (%s, %s)"):format(tostring(x64), tostring(y64)))
  check(x64 == 96 and y64 == 0,
    "a 64x64 front pic pins to the box corner and overlaps the HUD")

  if #failures > 0 then
    error(#failures .. " checks failed")
  end
  print("[driver] #1159 / #1160 fixed; shots in " .. out)
end

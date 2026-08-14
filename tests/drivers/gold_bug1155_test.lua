-- #1155: "MAGNITUDE always rolls a 4".
--
--   POKEPORT_GAME=gold POKEPORT_TOUCH=0 \
--     POKEPORT_DRIVER=tests/drivers/gold_bug1155_test.lua love .
local U = require("tests.drivers.util")

local Mon = require("src.battle.gen2.Mon")

local ROLLS = 15

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

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-bug1155"
  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  local caster = Mon.new(game.data, "DUNSPARCE", 50)
  local def = assert(game.data.moves.MAGNITUDE, "MAGNITUDE is not in moves.lua")
  caster.moves = { { id = "MAGNITUDE", pp = def.pp, maxPp = def.pp } }
  print("[driver] MAGNITUDE stored effect = " .. tostring(def.effect)
    .. ", stored power = " .. tostring(def.power))
  game.save.party = { caster }

  local seen, damages, shown = {}, {}, 0
  local screen
  for i = 1, ROLLS do
    if not (screen and game.stack:top() == screen and not screen.battle.over) then
      local dummy = Mon.new(game.data, "SNORLAX", 60)
      dummy.moves = { { id = "SPLASH", pp = 40, maxPp = 40 } }
      assert(world:startBattle({ wild = dummy }), "startBattle failed")
      screen = battleScreen(game)
      drain(game, screen, 300)
    end
    local foe = screen.battle.enemy
    local before = foe.hp
    caster.moves[1].pp = def.pp
    screen:submit({ kind = "move", move = "MAGNITUDE" })
    for _, event in ipairs(screen.queue) do
      local number = event.text and event.text:match("^Magnitude (%d+)")
      if number then
        seen[number] = (seen[number] or 0) + 1
        if shown < 1 then
          U.wait(1)
          U.shot(game, out .. "/01-magnitude-text.png")
          shown = 1
        end
      end
    end
    drain(game, screen, 400)
    local dealt = before - foe.hp
    if dealt > 0 then damages[dealt] = true end
    if i % 10 == 0 then U.wait(5) end
  end

  local numbers = {}
  for number, count in pairs(seen) do
    numbers[#numbers + 1] = number .. "x" .. count
  end
  table.sort(numbers)
  print("[driver] magnitudes over " .. ROLLS .. " uses: "
    .. table.concat(numbers, " "))
  local distinctPowers = 0
  for _ in pairs(damages) do distinctPowers = distinctPowers + 1 end

  local failures = {}
  local function check(ok, what)
    print((ok and "[ok] " or "[FAIL] ") .. what)
    if not ok then failures[#failures + 1] = what end
  end
  check(#numbers > 1, "MAGNITUDE rolls more than one number")
  check(seen["4"] == nil or seen["4"] < ROLLS,
    "and is not stuck on MAGNITUDE 4")
  check(distinctPowers > 1, "the rolled power reaches the damage (" ..
    distinctPowers .. " distinct damage figures)")

  if #failures > 0 then
    error(#failures .. " magnitude checks failed")
  end
  print("[driver] #1155 clear; shot in " .. out)
end

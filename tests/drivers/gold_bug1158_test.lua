-- #1158: you could not see the trainer's incoming mon before the switch offer.
--
--   POKEPORT_GAME=gold POKEPORT_TOUCH=0 \
--     POKEPORT_DRIVER=tests/drivers/gold_bug1158_test.lua love .

local U = require("tests.drivers.util")

local Mon = require("src.battle.gen2.Mon")

local function battleScreen(game)
  for _ = 1, 900 do
    local top = game.stack:top()
    if top and top.battle then return top end
    U.wait(1)
  end
  error("battle screen never came up")
end

local function runToPhase(game, screen, phase, frames)
  for _ = 1, (frames or 600) do
    if screen.phase == phase then return true end
    U.tap(game, "a")
    U.wait(3)
  end
  return false
end

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-bug1158"
  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")
  local failures = {}
  local function check(ok, what)
    print((ok and "[ok] " or "[FAIL] ") .. what)
    if not ok then failures[#failures + 1] = what end
  end

  -- SHIFT is the only style that offers at all (CheckWhetherToAskSwitch).
  game.options = game.options or {}
  game.options.battleStyle = "SHIFT"

  local lead = Mon.new(game.data, "TYPHLOSION", 40)
  lead.moves = { { id = "TACKLE", pp = 35, maxPp = 35 } }
  local bench = Mon.new(game.data, "FERALIGATR", 40)
  bench.moves = { { id = "TACKLE", pp = 35, maxPp = 35 } }
  game.save.party = { lead, bench }

  local foe1 = Mon.new(game.data, "PIDGEY", 5)
  foe1.moves = { { id = "TACKLE", pp = 35, maxPp = 35 } }
  local foe2 = Mon.new(game.data, "PIDGEOTTO", 20)
  foe2.moves = { { id = "TACKLE", pp = 35, maxPp = 35 } }
  assert(world:startBattle({ trainer = { class = "FALKNER", name = "FALKNER",
    party = { foe1, foe2 } } }), "trainer startBattle failed")
  local screen = battleScreen(game)
  runToPhase(game, screen, "menu", 400)

  foe1.hp = 1
  screen:submit({ kind = "move", move = "TACKLE" })

  -- Page by page, collecting what the box actually showed.
  local pages, sawBoxWithName = {}, false
  local incoming = foe2.nickname or foe2.species or "PIDGEOTTO"
  for _ = 1, 900 do
    local message = screen.message
    if message and pages[#pages] ~= message
        and (screen.phase == "shift-intro" or screen.phase == "ask-shift") then
      pages[#pages + 1] = message
      if #pages == 1 then U.shot(game, out .. "/01-first-page.png") end
      if message:find(incoming, 1, true) then
        U.shot(game, out .. "/02-names-the-mon.png")
        sawBoxWithName = true
      end
    end
    if screen.phase == "ask-shift" and (screen.messageTimer or 0) <= 0 then
      break
    end
    U.tap(game, "a")
    U.wait(4)
  end
  U.shot(game, out .. "/03-yes-no.png")

  for i, page in ipairs(pages) do
    print(("[driver] page %d: %s"):format(i, (page:gsub("\n", " / "))))
  end
  check(sawBoxWithName,
    "the incoming " .. incoming .. " is named in the box before the yes/no")
  check(screen.phase == "ask-shift",
    "and the prompt still ends on the YES/NO question")
  check(#pages > 1, "the offer runs as pages, not one over-long line")

  if #failures > 0 then
    error(#failures .. " send-out order checks failed")
  end
  print("[driver] #1158 fixed; shots in " .. out)
end

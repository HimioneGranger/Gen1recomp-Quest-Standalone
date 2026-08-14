-- #1157: SONIC BOOM has to deal a flat 20, not a rolled 8-10.
--
--   POKEPORT_GAME=gold POKEPORT_TOUCH=0 \
--     POKEPORT_DRIVER=tests/drivers/gold_bug1157_test.lua love .

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
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-bug1157"
  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")
  local failures = {}
  local function check(ok, what)
    print((ok and "[ok] " or "[FAIL] ") .. what)
    if not ok then failures[#failures + 1] = what end
  end

  -- The reporter's own matchup, three times over.
  local caster = Mon.new(game.data, "MAGNEMITE", 20)
  local boom = assert(game.data.moves.SONICBOOM, "SONICBOOM missing")
  print("[driver] SONICBOOM effect = " .. tostring(boom.effect)
    .. ", stored power = " .. tostring(boom.power))
  caster.moves = { { id = "SONICBOOM", pp = boom.pp, maxPp = boom.pp } }
  game.save.party = { caster }

  -- SONIC BOOM is a 90% move, so a miss (0) is legal and simply does not
  -- count: what matters is that every use that CONNECTS is 20.
  local dealt, hits, wrong = {}, 0, 0
  for i = 1, 6 do
    local rattata = Mon.new(game.data, "RATTATA", 11)
    rattata.moves = { { id = "SPLASH", pp = 40, maxPp = 40 } }
    assert(world:startBattle({ wild = rattata }), "startBattle failed")
    local screen = battleScreen(game)
    drain(game, screen, 300)
    local before = rattata.hp
    caster.hp = caster.maxHp or caster.hp
    caster.moves[1].pp = boom.pp
    screen:submit({ kind = "move", move = "SONICBOOM" })
    drain(game, screen, 400)
    dealt[i] = before - rattata.hp
    if dealt[i] > 0 then
      hits = hits + 1
      if dealt[i] ~= 20 then wrong = wrong + 1 end
    end
    if i == 1 then U.shot(game, out .. "/01-sonicboom.png") end
    for _ = 1, 400 do
      if not game.stack:top() or not game.stack:top().battle then break end
      U.tap(game, "a")
      U.wait(3)
    end
    U.wait(45)
  end
  print("[driver] SONIC BOOM dealt " .. table.concat(dealt, ", ")
    .. " (0 is a miss)")
  check(hits >= 3, "SONIC BOOM connected at least three times")
  check(wrong == 0, "and every hit was exactly 20")

  -- The two siblings on the same command.
  local dragon = Mon.new(game.data, "DRATINI", 25)
  local rage = assert(game.data.moves.DRAGON_RAGE, "DRAGON_RAGE missing")
  local toss = assert(game.data.moves.SEISMIC_TOSS, "SEISMIC_TOSS missing")
  dragon.moves = {
    { id = "DRAGON_RAGE", pp = rage.pp, maxPp = rage.pp },
    { id = "SEISMIC_TOSS", pp = toss.pp, maxPp = toss.pp },
  }
  game.save.party = { dragon }
  local target = Mon.new(game.data, "SNORLAX", 60)
  target.moves = { { id = "SPLASH", pp = 40, maxPp = 40 } }
  assert(world:startBattle({ wild = target }), "startBattle failed")
  local screen = battleScreen(game)
  drain(game, screen, 300)
  local before = target.hp
  screen:submit({ kind = "move", move = "DRAGON_RAGE" })
  drain(game, screen, 400)
  local rageDealt = before - target.hp
  before = target.hp
  screen:submit({ kind = "move", move = "SEISMIC_TOSS" })
  drain(game, screen, 400)
  local tossDealt = before - target.hp
  U.shot(game, out .. "/02-siblings.png")
  print(("[driver] DRAGON RAGE %d, SEISMIC TOSS %d (user is L%d)")
    :format(rageDealt, tossDealt, dragon.level))
  check(rageDealt == 40, "DRAGON RAGE deals exactly 40")
  check(tossDealt == dragon.level, "SEISMIC TOSS deals the user's level")

  if #failures > 0 then
    error(#failures .. " constant-damage checks failed")
  end
  print("[driver] #1157 fixed; shots in " .. out)
end

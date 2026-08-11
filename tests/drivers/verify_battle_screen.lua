-- Independent verification probe for the Gold battle screen lane.
-- Temporary: attacks the same claims from a different angle than
-- tests/drivers/gold_battle_screen_probe.lua.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/verify_battle_screen.lua \
--     POKEPORT_VPROBE=switch1 POKEPORT_SHOT_DIR=/tmp/verify-battle/v love .

local U = require("tests.drivers.util")
local Mon = require("src.battle.gen2.Mon")

local OUT = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/verify-battle/v"

local hostVisible = love.visible
love.visible = function(v) if hostVisible then pcall(hostVisible, v) end end

local function tap(game, button, frames)
  game.input.pressQueue[#game.input.pressQueue + 1] = button
  game.input.state[button] = true
  U.wait(2)
  game.input.state[button] = false
  U.wait(frames or 6)
end

local function openBattle(game, opts)
  assert(game.world:startBattle(opts), "startBattle failed")
  for _ = 1, 900 do
    local top = game.stack:top()
    if top and top.battle then return top end
    U.wait(1)
  end
  error("battle screen never came up")
end

local function toMenu(game, battle, limit)
  for _ = 1, (limit or 400) do
    if battle.phase == "menu" then return true end
    if battle.battle.over then return false end
    tap(game, "a", 2)
  end
  return battle.phase == "menu"
end

local V = {}

-- Bug 4, the real player route: after the faint, move the cursor to a HEALTHY
-- mon and press A exactly ONCE.  The claim under test is that the switch takes
-- on that press; the author's probe only ever proved the refusal LINE.
function V.switch1(game)
  local weak = Mon.new(game.data, "CYNDAQUIL", 5)
  weak.hp = 1
  game.save.party = { weak, Mon.new(game.data, "TOTODILE", 30) }
  game.save.inventory = {}
  local entry = game.world:trainerParty(36, 1)
  local Trainers = require("src.world.gen2.Trainers")
  entry.party = Trainers.party(game.data, entry)
  local battle = openBattle(game, { trainer = entry })
  assert(toMenu(game, battle), "never reached the battle menu")

  local aPresses, listOpens = 0, 0
  local realOpen = battle.openParty
  battle.openParty = function(self, forced)
    if forced then listOpens = listOpens + 1 end
    return realOpen(self, forced)
  end

  local switched, moved = false, false
  for _ = 1, 1200 do
    if battle.battle.over then break end
    local top = game.stack:top()
    if top ~= battle then
      -- The forced list.  Move down to the healthy mon FIRST, then one A.
      if not moved then tap(game, "down", 4); moved = true end
      aPresses = aPresses + 1
      tap(game, "a", 6)
      U.wait(20)
      if battle.battle.player and (battle.battle.player.hp or 0) > 0
          and battle.battle.player.species == "TOTODILE" then
        switched = true
        break
      end
    elseif battle.phase == "menu" then
      tap(game, "a", 2); U.wait(3); tap(game, "a", 2)
    else
      tap(game, "a", 2)
    end
  end
  print(("[v] switch1: listOpens=%d aPressesOnList=%d switched=%s active=%s")
    :format(listOpens, aPresses, tostring(switched),
      tostring(battle.battle.player and battle.battle.player.species)))
  U.shot(game, OUT .. "/switch1-after.png")
end

-- Bug 3, the NORMAL save: currentBox is 1, the value every fresh Gold save and
-- every save the engine itself writes carries.  If the catch only reached a box
-- because of the clamp, this is where that shows.
function V.box1(game)
  local party = {}
  for _ = 1, 6 do party[#party + 1] = Mon.new(game.data, "CYNDAQUIL", 30) end
  game.save.party = party
  game.save.boxes = nil
  game.save.currentBox = tonumber(os.getenv("POKEPORT_VBOX") or "1")
  game.save.inventory = { MASTER_BALL = 5 }
  local battle = openBattle(game, { wild = Mon.new(game.data, "PIDGEY", 5) })
  assert(toMenu(game, battle), "never reached the battle menu")
  battle:useItem("MASTER_BALL")
  for _ = 1, 600 do
    if not battle.anim then break end
    U.wait(1)
  end
  for _ = 1, 300 do
    if battle.phase == "ask-nickname" then tap(game, "b", 4)
    else tap(game, "a", 3) end
    if battle.phase == "done" or not game.stack:top() then break end
  end
  local total, where = 0, "nowhere"
  for i, box in pairs(game.save.boxes or {}) do
    total = total + #box
    if #box > 0 then where = "box" .. tostring(i) end
  end
  print(("[v] box1: currentBox=%s party=%d anywhere=%d landedIn=%s boxFilled=%s")
    :format(tostring(game.save.currentBox), #game.save.party, total, where,
      tostring(battle.battle.boxFilled)))
end

-- The picHidden REGRESSION risk: a trainer whose first mon faints must send its
-- SECOND one out and that mon must be visible.  A latch that a send-out fails
-- to clear leaves an invisible opponent for the rest of the battle.
function V.secondmon(game)
  game.save.party = { Mon.new(game.data, "TOTODILE", 40) }
  game.save.inventory = {}
  -- Find a trainer entry that actually carries two mons.
  local Trainers = require("src.world.gen2.Trainers")
  local entry, size
  for class = 1, 60 do
    for member = 1, 6 do
      local ok, e = pcall(game.world.trainerParty, game.world, class, member)
      if ok and e then
        local party = Trainers.party(game.data, e)
        if party and #party >= 2 then
          entry, size = e, #party
          e.party = party
          break
        end
      end
    end
    if entry then break end
  end
  assert(entry, "no multi-mon trainer found")
  print(("[v] secondmon: trainer class=%s members=%d")
    :format(tostring(entry.classId or entry.class), size))
  local battle = openBattle(game, { trainer = entry })
  assert(toMenu(game, battle), "never reached the battle menu")

  local sawSecond, hiddenAtSecond, shot = false, nil, 0
  for _ = 1, 2000 do
    if battle.battle.over then break end
    if battle.battle.enemyIndex and battle.battle.enemyIndex > 1
        and not sawSecond then
      sawSecond = true
      -- Let the send-out settle, then look at the latch and shoot it.
      U.wait(90)
      hiddenAtSecond = battle.picHidden.enemy
      U.shot(game, OUT .. "/secondmon-out.png")
    end
    if battle.phase == "menu" then
      tap(game, "a", 2); U.wait(3); tap(game, "a", 2)
    else
      if shot < 3 and battle.faintSlide then
        U.shot(game, ("%s/secondmon-faint-%02d.png"):format(OUT,
          battle.faintSlide.frames))
        shot = shot + 1
      end
      tap(game, "a", 2)
    end
  end
  print(("[v] secondmon: sawSecond=%s picHidden.enemy@second=%s outcome=%s")
    :format(tostring(sawSecond), tostring(hiddenAtSecond),
      tostring(battle.battle.outcome)))
  U.shot(game, OUT .. "/secondmon-end.png")
end

-- Bug 2, the half that is cache-side: what the DEFAULT identity's Gold cache
-- actually carries, and what the class key resolves to.
function V.trainerpic(game)
  local hud = game.data.gen2MenuGfx and game.data.gen2MenuGfx.battleHud
  local pics = hud and hud.trainerPics
  local n = 0
  local sample
  for k in pairs(pics or {}) do n = n + 1; sample = sample or k end
  print(("[v] trainerpic: cache trainerPics=%s count=%d sample=%s")
    :format(tostring(pics ~= nil), n, tostring(sample)))
  local Trainers = require("src.world.gen2.Trainers")
  local entry = game.world:trainerParty(36, 1)
  print(("[v] trainerpic: lookup(36,1) class=%s classId=%s className=%s")
    :format(tostring(entry and entry.class), tostring(entry and entry.classId),
      tostring(entry and entry.className)))
  entry.party = Trainers.party(game.data, entry)
  local battle = openBattle(game, { trainer = entry })
  print(("[v] trainerpic: enemyTrainerClass=%s showEnemyTrainer=%s path=%s")
    :format(tostring(battle.enemyTrainerClass),
      tostring(battle.showEnemyTrainer), tostring(battle.enemyTrainerPath)))
  for i = 0, 8 do
    U.shot(game, ("%s/trainerpic-%02d.png"):format(OUT, i))
    U.wait(10)
  end
end

-- The counterfactual to bug 1: a ball that FAILS.  BattleAnim_ThrowPokeBall's
-- break-out arm puts the mon back on the field, so a latch set anywhere but on
-- the caught arm would make a wild mon vanish for the rest of the battle.
function V.missball(game)
  game.save.party = { Mon.new(game.data, "TOTODILE", 40) }
  game.save.inventory = { POKE_BALL = 30 }
  local wild = Mon.new(game.data, "ONIX", 40) -- full HP, low catch rate
  local battle = openBattle(game, { wild = wild })
  assert(toMenu(game, battle), "never reached the battle menu")
  local tries, escaped = 0, false
  for _ = 1, 20 do
    tries = tries + 1
    battle:useItem("POKE_BALL")
    for _ = 1, 600 do
      if not battle.anim then break end
      U.wait(1)
    end
    U.wait(40)
    if battle.battle.outcome ~= "caught" and not battle.battle.over then
      escaped = true
      break
    end
    if battle.battle.over then break end
  end
  print(("[v] missball: tries=%d escaped=%s picHidden.enemy=%s outcome=%s")
    :format(tries, tostring(escaped), tostring(battle.picHidden.enemy),
      tostring(battle.battle.outcome)))
  for i = 0, 3 do
    U.shot(game, ("%s/missball-%02d.png"):format(OUT, i))
    tap(game, "a", 8)
  end
end

local name = os.getenv("POKEPORT_VPROBE") or "switch1"
return function(game)
  U.wait(45)
  assert(game.world and game.world.map, "gold world did not boot")
  print("[v] ---- " .. name)
  assert(V[name], "no such probe: " .. name)(game)
  print("[v] done, shots in " .. OUT)
  love.event.quit()
end

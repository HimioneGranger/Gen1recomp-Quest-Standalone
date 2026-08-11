-- Probe: the Gold battle SCREEN, one reported symptom per scenario.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_battle_screen_probe.lua \
--     POKEPORT_PROBE=catch POKEPORT_SHOT_DIR=/tmp/gold-battle-screen love .
--
-- POKEPORT_PROBE picks the scenario (comma separated, default `catch`):
--
--   catch    a wild mon is caught: the throw animation runs (the ball's own Y
--            is counted, so "it moved" is a number), and the mon's frontpic is
--            GONE from the box for every line after it
--   boxfull  the same catch with six in the party: it lands in a real box.
--            POKEPORT_PROBE_BOX sets save.currentBox first -- 0 is the value a
--            save converted off a cartridge carries, and the one that used to
--            drop the catch on the floor
--   faint    a player mon faints in a trainer battle: the fainted pic sinks
--            out of its box before the line, and picking the fainted mon in
--            the forced list is REFUSED out loud instead of silently
--   tutorial the DUDE's demonstration, start to finish, on its own auto-input
--   trainer  the trainer's own frontpic stands in the enemy box for the intro
--            (needs a cache with menu_gfx battleHud.trainerPics; an older
--            import has none and the mon stands in for the whole intro)
--   scale    the battle_sprite_scales reader, planted straight on data
--
-- Every scenario shoots, because the answer to most of these is a picture.
local U = require("tests.drivers.util")

local Mon = require("src.battle.gen2.Mon")

local OUT = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-battle-screen"

-- main.lua's love.visible forwards to Game:visible, which the Gen 2 Game
-- object does not have, so another window taking focus mid-run kills the whole
-- driver with "attempt to call method 'visible'".  It fires during the cache
-- mount, before the first frame this driver is resumed on, which is why the
-- guard is at module scope: loadfile runs it inside love.load.  Nothing this
-- probe is about, so the callback is let through under pcall rather than
-- costing a 200-frame run.
local hostVisible = love.visible
love.visible = function(v) if hostVisible then pcall(hostVisible, v) end end

local function tap(game, button, frames)
  game.input.pressQueue[#game.input.pressQueue + 1] = button
  game.input.state[button] = true
  U.wait(2)
  game.input.state[button] = false
  U.wait(frames or 6)
end

-- The battle screen, once the transition has handed the stack over.
local function openBattle(game, opts)
  assert(game.world:startBattle(opts), "startBattle failed")
  for _ = 1, 900 do
    local top = game.stack:top()
    if top and top.battle then return top end
    U.wait(1)
  end
  error("battle screen never came up")
end

-- Page the intro (slide, "appeared!", the send-out) until the menu is up.
local function toMenu(game, battle, limit)
  for _ = 1, (limit or 400) do
    if battle.phase == "menu" then return true end
    if battle.battle.over then return false end
    tap(game, "a", 2)
  end
  return battle.phase == "menu"
end

-- Shoots an animation while it runs, and tracks the OBJ layer's first sprite so
-- "the ball moved" is a number rather than a squint: BattleAnim_ThrowPokeBall's
-- own bounce and its three shakes are all Y motion on that one object.
local function shotsWhileAnim(game, battle, prefix, every)
  local frames, moves, lastY, minY, maxY = 0, 0, nil, nil, nil
  while battle.anim and frames < 600 do
    if frames % (every or 4) == 0 then
      U.shot(game, ("%s-%03d.png"):format(prefix, frames))
    end
    local obj = battle.anim:oam()[1]
    if obj then
      if lastY and obj.y ~= lastY then moves = moves + 1 end
      lastY = obj.y
      minY = math.min(minY or obj.y, obj.y)
      maxY = math.max(maxY or obj.y, obj.y)
    end
    frames = frames + 1
    U.wait(1)
  end
  return frames, moves, minY, maxY
end

--------------------------------------------------------------------------

local Probes = {}

-- 1, 5, 7: the throw animation, and the pic that must not come back.
function Probes.catch(game)
  local world = game.world
  game.save.party = { Mon.new(game.data, "CYNDAQUIL", 30) }
  game.save.inventory = { POKE_BALL = 10, MASTER_BALL = 5 }
  game.save.boxes = nil
  local battle = openBattle(game, { wild = Mon.new(game.data, "PIDGEY", 5) })
  assert(toMenu(game, battle), "never reached the battle menu")
  U.shot(game, OUT .. "/catch-00-menu.png")

  battle:useItem("MASTER_BALL")
  print(("[probe] catch: anim=%s ballThrow.caught=%s"):format(
    tostring(battle.anim ~= nil),
    tostring(battle.ballThrow and battle.ballThrow.caught)))
  local frames, moves, minY, maxY =
    shotsWhileAnim(game, battle, OUT .. "/catch-01-throw", 4)
  print(("[probe] catch: throw animation ran %d frames, ball moved on %d of"
    .. " them, y %s..%s"):format(frames, moves, tostring(minY), tostring(maxY)))

  -- The moment the animation lets go of the screen: the mon went into the
  -- ball, so nothing may be standing in the enemy box here or on any of the
  -- lines that follow.
  for i = 0, 5 do
    U.shot(game, ("%s/catch-01b-after-anim-%d.png"):format(OUT, i))
    tap(game, "a", 6)
  end

  -- Page the caught text, the dex line and the nickname prompt (NO).
  for _ = 1, 200 do
    if battle.phase == "done" or not game.stack:top() then break end
    if battle.phase == "ask-nickname" then
      tap(game, "b", 4)
    else
      tap(game, "a", 3)
    end
    if battle.phase == "resolving" and #battle.queue == 0
        and battle.message == nil then
      break
    end
  end
  U.shot(game, OUT .. "/catch-02-after.png")
  print(("[probe] catch: outcome=%s party=%d picHidden=%s"):format(
    tostring(battle.battle.outcome), #game.save.party,
    tostring(battle.picHidden and battle.picHidden.enemy)))
  print(("[probe] catch: enemy pic still resolvable: %s"):format(
    tostring(battle:pic(battle:activeMon("enemy"), false) ~= nil)))
end

-- 3: six in the party sends the catch to the box.
function Probes.boxfull(game)
  local party = {}
  for _ = 1, 6 do party[#party + 1] = Mon.new(game.data, "CYNDAQUIL", 30) end
  game.save.party = party
  game.save.boxes = nil
  -- wCurBox is 0-based on the cart (box 0 is BOX 1), and a save converted out
  -- of a real cartridge carries that byte through unchanged -- so this is a
  -- currentBox a live save really can hold, and the arm has to survive it.
  game.save.currentBox = tonumber(os.getenv("POKEPORT_PROBE_BOX") or "1")
  game.save.inventory = { MASTER_BALL = 5 }
  local battle = openBattle(game, { wild = Mon.new(game.data, "PIDGEY", 5) })
  assert(toMenu(game, battle), "never reached the battle menu")
  battle:useItem("MASTER_BALL")
  shotsWhileAnim(game, battle, OUT .. "/box-01-throw", 8)
  for _ = 1, 200 do
    if battle.phase == "ask-nickname" then tap(game, "b", 4)
    else tap(game, "a", 3) end
    if battle.phase == "done" or not game.stack:top() then break end
  end
  local total = 0
  for _, box in pairs(game.save.boxes or {}) do total = total + #box end
  local box = (game.save.boxes or {})[1] or {}
  print(("[probe] boxfull: currentBox=%s party=%d box1=%d anywhere=%d first=%s")
    :format(tostring(game.save.currentBox), #game.save.party, #box, total,
      tostring(box[1] and box[1].species)))
  U.shot(game, OUT .. "/box-02-after.png")
end

-- 4 and 6: the faint slide, and the forced switch that has to take first try.
function Probes.faint(game)
  local world = game.world
  local weak = Mon.new(game.data, "CYNDAQUIL", 5)
  weak.hp = 1
  local strong = Mon.new(game.data, "TOTODILE", 30)
  game.save.party = { weak, strong }
  game.save.inventory = {}
  local entry = world:trainerParty(36, 1) -- BUG_CATCHER member 1
  assert(entry, "no BUG_CATCHER member 1 in trainers.lua")
  local Trainers = require("src.world.gen2.Trainers")
  entry.party = Trainers.party(game.data, entry)
  local battle = openBattle(game, { trainer = entry })
  assert(toMenu(game, battle), "never reached the battle menu")

  -- Count how many times the party list is opened for the forced switch.
  local opens = 0
  local realOpen = battle.openParty
  battle.openParty = function(self, forced)
    if forced then opens = opens + 1 end
    return realOpen(self, forced)
  end

  -- What a player does: press A on the row the cursor is already on.  Row 1 is
  -- the mon that just fainted, so the first two picks are the refusal the cart
  -- answers with "There's no will to fight!"; only the third moves down.
  local picks, refusedMessages = 0, {}
  local shot, sawFaint = 0, false
  for _ = 1, 900 do
    if battle.battle.over then break end
    local top = game.stack:top()
    if top ~= battle then
      picks = picks + 1
      if picks > 2 then tap(game, "down", 3) end
      tap(game, "a", 4)
      if battle.message then
        refusedMessages[#refusedMessages + 1] = battle.message
      end
    elseif battle.faintSlide then
      -- MonFaintedAnimation is running: one shot a frame, because the whole
      -- claim is that the pic sinks out of its box before the line goes up.
      U.shot(game, ("%s/faint-slide-%s-%02d.png"):format(OUT,
        battle.faintSlide.side, battle.faintSlide.frames))
      U.wait(1)
    elseif battle.message and battle.message:match("fainted") then
      if not sawFaint then
        sawFaint = true
        print("[probe] faint: line up -- " .. battle.message)
      end
      if shot < 12 then
        U.shot(game, ("%s/faint-%02d.png"):format(OUT, shot))
        shot = shot + 1
        U.wait(2)
      else
        tap(game, "a", 2)
      end
    elseif battle.phase == "menu" then
      tap(game, "a", 2) -- FIGHT
      U.wait(3)
      tap(game, "a", 2) -- first move
    else
      tap(game, "a", 2)
    end
  end
  print(("[probe] faint: list opened %d time(s) for %d pick(s), outcome=%s")
    :format(opens, picks, tostring(battle.battle.outcome)))
  print(("[probe] faint: player is now %s (party slot 2 is %s)"):format(
    tostring(battle.battle.player and battle.battle.player.species),
    tostring(game.save.party[2] and game.save.party[2].species)))
  for i, text in ipairs(refusedMessages) do
    print(("[probe] faint: after pick %d the box said %q"):format(i, text))
  end
end

-- 5 and 7: the DUDE's demonstration, which throws the same ball through the
-- same animation and then has to leave the RATTATA inside it.
function Probes.tutorial(game)
  local world = game.world
  game.save.party = {}
  local rattata = game.data.pokemon.RATTATA
  local battle
  -- Script_catchtutorial arms CATCH_TUTORIAL around StartBattle and the DUDE's
  -- own presses are RE-ARMS of that ring (CatchTutorial.rearm refuses a ring
  -- that is not already active), so the stream has to be started here the way
  -- the VM starts it -- without it the demo hangs on its first prompt forever.
  game.autoInput:start("CATCH_TUTORIAL", game.input)
  world:startCatchTutorial({ species = rattata.index, level = 5 }, nil,
    function()
      game.autoInput:stop(game.input)
      print("[probe] tutorial: battle closed")
    end)
  for _ = 1, 900 do
    local top = game.stack:top()
    if top and top.battle then battle = top break end
    U.wait(1)
  end
  assert(battle, "the tutorial battle never came up")
  -- The DUDE plays it himself; all this does is shoot and stay out of the way.
  -- The loop watches the battle SCREEN rather than the stack top, because the
  -- demo opens the pack over it and a top-of-stack test would stop counting
  -- exactly where the throw happens.
  local shot, sawAnim, animFrames = 0, false, 0
  for _ = 1, 2000 do
    if battle.phase == "done" then break end
    if battle.anim then sawAnim = true animFrames = animFrames + 1 end
    if shot % 8 == 0 then
      U.shot(game, ("%s/tutorial-%03d.png"):format(OUT, shot))
    end
    shot = shot + 1
    U.wait(1)
  end
  print(("[probe] tutorial: ball animation seen=%s (%d frames), shots=%d")
    :format(tostring(sawAnim), animFrames, shot))
end

-- The battle_sprite_scales registry, whose records are keyed by ASSET PATH and
-- are the only handle on a pic that is not a species' own.  Schemas.GEN2 still
-- routes the registry nowhere, so the Loader drops a mod's registration with a
-- warning; the record is planted straight on data here to show the READER is
-- live, which is the half that has to exist before the row can be un-gated.
function Probes.scale(game)
  game.data.battle_sprite_scales = game.data.battle_sprite_scales or {}
  game.data.battle_sprite_scales.probe_back = {
    path = "assets/generated/battle/back/cyndaquil_back.png", scale = 0.5,
  }
  game.data.battle_sprite_scales.probe_front = {
    path = "assets/generated/battle/front/pidgey.png", scale = 1.5,
  }
  game.save.party = { Mon.new(game.data, "CYNDAQUIL", 30) }
  local battle = openBattle(game, { wild = Mon.new(game.data, "PIDGEY", 5) })
  assert(toMenu(game, battle), "never reached the battle menu")
  U.shot(game, OUT .. "/scale-00-menu.png")
  print(("[probe] scale: back=%s front=%s (1 means the reader is not wired)")
    :format(
      tostring(battle:picScale(
        "assets/generated/battle/back/cyndaquil_back.png", nil, true)),
      tostring(battle:picScale(
        "assets/generated/battle/front/pidgey.png", nil, false))))
  game.data.battle_sprite_scales.probe_back = nil
  game.data.battle_sprite_scales.probe_front = nil
end

-- 2: the trainer's frontpic during the intro.
function Probes.trainer(game)
  local world = game.world
  game.save.party = { Mon.new(game.data, "CYNDAQUIL", 30) }
  local entry = world:trainerParty(36, 1)
  assert(entry, "no BUG_CATCHER member 1")
  local Trainers = require("src.world.gen2.Trainers")
  entry.party = Trainers.party(game.data, entry)
  local hud = game.data.gen2MenuGfx and game.data.gen2MenuGfx.battleHud
  local pics = hud and hud.trainerPics
  print(("[probe] trainer: cache trainerPics=%s entry.class=%s classId=%s"
    .. " className=%s"):format(
    tostring(pics and "yes" or "no"), tostring(entry.class),
    tostring(entry.classId), tostring(entry.className)))
  local battle = openBattle(game, { trainer = entry })
  print(("[probe] trainer: showEnemyTrainer=%s image=%s class=%s"):format(
    tostring(battle.showEnemyTrainer), tostring(battle.enemyTrainerImage ~= nil),
    tostring(battle.enemyTrainerClass)))
  -- The intro slide, the "wants to battle!" line, then the pic sliding out.
  U.wait(40)
  U.shot(game, OUT .. "/trainer-00-slide.png")
  U.wait(45)
  U.shot(game, OUT .. "/trainer-01-intro.png")
  for _ = 1, 12 do
    tap(game, "a", 2)
    if battle.trainerSlide then break end
  end
  U.shot(game, OUT .. "/trainer-02-slide-out.png")
  U.wait(20)
  U.shot(game, OUT .. "/trainer-03-mon.png")
end

--------------------------------------------------------------------------

return function(game)
  U.wait(45)
  assert(game.world and game.world.map, "gold world did not boot")

  local wanted = os.getenv("POKEPORT_PROBE") or "catch"
  for name in wanted:gmatch("[%w_]+") do
    local probe = Probes[name]
    if not probe then
      print("[probe] no scenario named " .. name)
    else
      print("[probe] ---- " .. name)
      probe(game)
      -- Back to the overworld before the next scenario.
      for _ = 1, 300 do
        if game.stack:top() == nil then break end
        tap(game, "a", 2)
      end
    end
  end
  print("[probe] done, shots in " .. OUT)
  love.event.quit()
end

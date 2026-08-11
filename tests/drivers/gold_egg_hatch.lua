-- The per-step event chain, in the running game.
--
-- `World` kept no step counter at all until this, so `Happiness.step` and
-- `Breeding.step` were written, tested and never called: eggs never hatched.
-- CountStep (engine/overworld/events.asm) now runs between the coord events and
-- the wild roll, and DoEggStep ticks at wStepCount $80.
--
-- This walks a real party with a real egg in it until the counter reaches the
-- egg phase, then asserts the slot came out of it as a Pokemon.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold \
--     POKEPORT_DRIVER=tests/drivers/gold_egg_hatch.lua \
--     perl -e 'alarm 300; exec @ARGV' \
--     python3 -c "import pty; pty.spawn(['love','.'])"
local SHOT_DIR = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-steps"

return function(game)
  local w = game.world
  local fails = 0

  local function wait(n) for _ = 1, n do coroutine.yield() end end

  local function ok(cond, msg)
    if cond then print("[steps] ok   " .. msg)
    else fails = fails + 1 print("[steps] FAIL " .. msg) end
    return cond
  end

  local function clearDirs()
    game.input.pressQueue = {}
    for _, d in ipairs({ "up", "down", "left", "right" }) do
      game.input.state[d] = false
      game.input.sources[d] = nil
    end
  end

  -- Walk back and forth on a clear row.  Holding one direction for a fixed
  -- stretch is the reliable shape here: a step is 16 pixels at one a frame, so
  -- 20 held frames is always at least one full footfall.
  local function pace(frames, dir)
    for _ = 1, frames do
      if w:busy() then clearDirs() return true end
      table.insert(game.input.pressQueue, dir)
      game.input.state[dir] = true
      coroutine.yield()
    end
    clearDirs()
    coroutine.yield()
    return w:busy()
  end

  os.execute('mkdir -p "' .. SHOT_DIR .. '" 2>/dev/null')
  wait(45)

  local save = game.save
  -- No wild encounters and no coord events in the way: this is about the step
  -- counter, not about what else a footfall can trigger.
  w.mapScenes.NEW_BARK_TOWN = 1
  w:setMap("NEW_BARK_TOWN", 6, 8, "down")
  wait(15)

  -- An egg on its last cycle, and a mon in front of it so the party is honest.
  local Mon = require("src.battle.gen2.Mon")
  local lead = Mon.new(game.data, "CYNDAQUIL", 5)
  save.party = { lead, {
    isEgg = true, species = "TOGEPI", name = "EGG", level = 5,
    eggSteps = 1, dvs = lead.dvs, moves = {},
    ot = save.player and save.player.name,
    otId = save.player and save.player.id,
  } }
  save.stepCount = nil
  save.poisonStepCount = nil

  local Breeding = require("src.core.gen2.Breeding")
  ok(Breeding.isEgg(save.party[2]), "the party starts with an egg in slot 2")

  -- DoEggStep fires at wStepCount $80, so at most 128 footfalls from zero.
  local hit = false
  for i = 1, 300 do
    if pace(24, (i % 2 == 1) and "left" or "right") then hit = true break end
    if not Breeding.isEgg(save.party[2]) then hit = true break end
    if i == 1 then
      ok((save.stepCount or 0) > 0,
        "one lap already moved wStepCount to " .. tostring(save.stepCount))
    end
  end
  ok((save.stepCount or 0) > 0,
    "the world counts steps at all now (wStepCount = "
      .. tostring(save.stepCount) .. ")")
  ok(hit, "and something fired inside 128 footfalls")
  ok(save.stepCount == 0x80,
    "at wStepCount $80, DoEggStep's own phase (got "
      .. tostring(save.stepCount) .. ")")

  game.capturePath = SHOT_DIR .. "/hatch-huh.png"
  wait(4)

  -- "Huh?" and the hatch line advance on A; the nickname prompt is a yes/no and
  -- B is NO, which is the arm that keeps the species name (HatchEggs' own
  -- .nonickname).  Answering YES would push the naming screen, which is a stack
  -- state rather than a World busy flag and would sit there forever.
  for _ = 1, 600 do
    if not w:busy() then break end
    table.insert(game.input.pressQueue, w.choicebox and "b" or "a")
    wait(3)
  end
  wait(20)

  local slot = save.party[2]
  ok(slot ~= nil and not Breeding.isEgg(slot), "the egg is no longer an egg")
  ok(slot and slot.species == "TOGEPI", "it is a TOGEPI (got "
    .. tostring(slot and slot.species) .. ")")
  ok(slot and (slot.hp or 0) > 0 and slot.hp == slot.maxHp,
    "at full health, the way HatchEggs copies MON_MAXHP into MON_HP")
  ok(slot and slot.happiness == 0x78,
    "with the hatch happiness of $78 (got "
      .. tostring(slot and slot.happiness) .. ")")
  ok(save.pokedex and save.pokedex.caught
    and save.pokedex.caught.TOGEPI, "and SetSeenAndCaughtMon ticked the #DEX")
  -- HatchEggs sets EVENT_TOGEPI_HATCHED (84) by hand, for this species alone.
  ok(w.events and w.events:get(84) == true,
    "and the world set EVENT_TOGEPI_HATCHED")

  game.capturePath = SHOT_DIR .. "/hatched.png"
  wait(30)

  if fails > 0 then
    error(("gold egg hatch: %d assertion(s) failed"):format(fails))
  end
  print("[driver] PASS gold per-step chain: the egg hatched")
end

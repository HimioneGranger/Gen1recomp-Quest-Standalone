-- The RING itself, in the running game: does the player actually HEAR the
-- phone before the hang-up beep?
--
-- Phone_StartRinging is `call WaitSFX` and only THEN `ld de, SFX_CALL /
-- call PlaySFX` (engine/phone/phone.asm:564-567), and RingTwice_StartCall
-- runs that whole pass twice (:458-469).  Both halves matter in this port:
-- SFX_CALL is $6a (constants/sfx_constants.asm:109), low enough that the
-- PlaySFX priority gate DROPS it outright while a louder sound is still on
-- ch5-ch8, so a ring with no wait in front of it can be silent and leave
-- SFX_HANG_UP as the first phone sound the player ever hears.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold \
--     POKEPORT_DRIVER=tests/drivers/gold_phone_ring.lua love .
--   POKEPORT_SHOT_DIR=/tmp/gold-ring   (default)
--
-- Listen for two rings about a second apart before the caller-ID page, then
-- the Click! at the end.  The assertions cover the same ground for a run
-- nobody is listening to: the loud sound is started deliberately first, so a
-- ring that survives it proves the wait, not luck.
local U = require("tests.drivers.util")

local Phone = require("src.core.gen2.Phone")
local Sound = require("src.core.Sound")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-ring"
  local failures = 0

  local function ok(label, condition, detail)
    if condition then
      print("[ring] ok   " .. label)
    else
      failures = failures + 1
      print("[ring] FAIL " .. label .. " " .. tostring(detail))
    end
  end

  -- Every gated sfx request, in order, with whether it actually started: a
  -- dropped one returns no source (src/core/Sound.lua sfxPriorityGate).
  local order, rings, sounded = {}, 0, 0
  local realPlay = Sound.play
  Sound.play = function(data, name)
    local src = realPlay(data, name)
    order[#order + 1] = tostring(name)
    if tostring(name):find("Call") then
      rings = rings + 1
      if src then sounded = sounded + 1 end
    end
    return src
  end

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")
  local save = game.save

  game.clock = { day = 0, hour = 9, minute = 0 }
  save.phone = nil
  assert(world:setMap("ROUTE_31", 8, 6, "down"), "setMap failed for ROUTE_31")
  U.wait(3)
  -- CheckStandingOnEntrance refuses a call on a door tile, so stand on floor.
  local cx, cy = world.player.cellX, world.player.cellY
  for y = 2, 16 do
    for x = 2, 16 do
      if world.map:cellCollision(x, y) == 0x00 then cx, cy = x, y end
    end
  end
  assert(world:setMap("ROUTE_31", cx, cy, "down"), "no floor cell on ROUTE_31")
  U.wait(3)

  -- Is there an audio device at all?  Without one every source is nil and
  -- "the ring sounded" would fail for a reason that has nothing to do with
  -- the phone, so the control decides whether that half is checked.
  world:playSfxNamed("Sfx_ReadText2")
  local audio = world.lastSfx ~= nil
  print("[ring] audio device: " .. tostring(audio))

  -- Diagnostic, not an assertion.  WaitSFX blocks on the whole sfx channel
  -- set (CheckSFX, home/audio.asm), but the VM's waitsfx hook only polls
  -- World.lastSfx, so a sound started straight through Sound.play -- the
  -- A-press beep src/render/TextBox.lua plays through the Press_AB alias --
  -- is invisible to it while Sound.sfxBusy() can still see it.  While these
  -- two disagree, a ring queued inside that sound's window can still be
  -- dropped by the priority gate.
  world.lastSfx = nil -- isolate: the hook must answer about THIS sound alone
  Sound.play(game.data, "Sfx_ReadText2")
  local hook = world.vm and world.vm.waitSfxFn
  print(("[ring] WaitSFX seam: hook says busy=%s, Sound.sfxBusy=%s")
    :format(tostring(hook and not hook()), tostring(Sound.sfxBusy())))
  U.wait(30)

  Phone.addContact(save, 15) -- Joey, ROUTE_30, reachable from ROUTE_31
  order, rings, sounded = {}, 0, 0

  -- SFX_READ_TEXT_2 is $08: it outranks SFX_CALL, so this is the sound that
  -- eats an unwaited ring.  Started one frame before the call lands, exactly
  -- as the A press that closes a textbox does.
  world:playSfxNamed("Sfx_ReadText2")

  local calls, shot = 0, false
  for _ = 1, 40 do
    if calls > 0 and not world:busy() then break end
    game.clock.minute = game.clock.minute + 20
    for _ = 1, 20 do
      U.wait(1)
      if world:busy() then break end
    end
    if world:busy() then
      calls = calls + 1
      for _ = 1, 400 do
        if not shot and rings >= 2 then
          -- The caller-ID page, with both rings already behind it.  The wait
          -- is for the typewriter: the page is only worth looking at once
          -- the whole RING!…RING! line has printed.
          U.wait(30)
          U.shot(game, out .. "/01-ring.png")
          shot = true
        end
        if not world:busy() then break end
        game.input.pressQueue[#game.input.pressQueue + 1] = "a"
        game.input.state.a = true
        U.wait(2)
        game.input.state.a = false
        U.wait(2)
      end
    end
  end

  ok("a call rang in the overworld", calls > 0, calls)
  -- RingTwice_StartCall's `call .Ring` plus its fallthrough.
  ok("the phone rang twice", rings == 2, rings)
  if audio then
    ok("and both rings actually sounded past the priority gate",
      sounded == rings, ("%d of %d"):format(sounded, rings))
  end

  local firstCall, firstHang
  for index, name in ipairs(order) do
    if not firstCall and name:find("Call") then firstCall = index end
    if not firstHang and name:find("Hang") then firstHang = index end
  end
  ok("the ring is the FIRST phone sound, not the hang-up beep",
    firstCall ~= nil and (firstHang == nil or firstCall < firstHang),
    table.concat(order, ","))

  Sound.play = realPlay
  print(failures == 0 and "PASS gold_phone_ring"
    or ("FAIL gold_phone_ring (%d)"):format(failures))
  love.event.quit(failures == 0 and 0 or 1)
end

-- The caller-ID box an incoming call puts across the top of the screen:
-- Phone_TextboxWithName (pokegold engine/phone/phone.asm:582), reached from
-- RingTwice_StartCall's .CallerTextboxWithName (:466, :474).
--
-- Three shots, because the whole bug was "there is no box at all" and only a
-- picture can answer that:
--
--   01-ring.png    the ring, box up, naming who is calling
--   02-talking.png the caller's own script talking UNDER the box
--   03-after.png   the call over, box gone, overworld clean
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_phone_caller_box.lua love .
--   POKEPORT_SHOT_DIR=/tmp/gold-callerbox   (default)
--
-- The assertions cover the same ground for a run nobody is looking at: the box
-- is on the stack while the call runs, it is UNDER the text pages rather than
-- over them, and it is off the stack once the script has ended (a box left
-- behind would sit on the overworld forever -- it has no `update`, so nothing
-- would ever take it down).
local U = require("tests.drivers.util")

local Phone = require("src.core.gen2.Phone")

-- The tag src/script/gen2/CallAsm.lua marks the pushed state with.
local CALLER_BOX = "gen2CallerBox"

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-callerbox"
  local failures = 0

  local function ok(label, condition, detail)
    if condition then
      print("[callerbox] ok   " .. label)
    else
      failures = failures + 1
      print("[callerbox] FAIL " .. label .. " " .. tostring(detail))
    end
  end

  -- Index of the caller box on the stack, or nil.
  local function boxIndex()
    for index, state in ipairs(game.stack.states or {}) do
      if state[CALLER_BOX] then return index end
    end
    return nil
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

  ok("no caller box before the phone rings", boxIndex() == nil, boxIndex())

  Phone.addContact(save, 15) -- Joey, ROUTE_30, reachable from ROUTE_31

  -- Wind the clock forward twenty in-game minutes at a time until
  -- CheckReceiveCallTimer lands a random call.
  local rang = false
  for _ = 1, 40 do
    game.clock.minute = game.clock.minute + 20
    for _ = 1, 20 do
      U.wait(1)
      if world:busy() then break end
    end
    if world:busy() then rang = true break end
  end
  ok("a call rang in the overworld", rang)
  if not rang then
    print("FAIL gold_phone_caller_box (no call)")
    love.event.quit(1)
    return
  end

  -- The box goes up on the FIRST ring; the ring page only arrives after the
  -- second pass, three Phone_Wait20Frames later (engine/phone/phone.asm:576),
  -- so wait for the page rather than for a fixed count -- then let it type.
  for _ = 1, 300 do
    if #game.stack.states > 1 then break end
    U.wait(1)
  end
  U.wait(40)
  local ringIndex = boxIndex()
  ok("the caller box is up during the ring", ringIndex ~= nil)
  ok("and sits UNDER the ring's text page",
    ringIndex ~= nil and ringIndex < #game.stack.states,
    ringIndex and (ringIndex .. " of " .. #game.stack.states))
  U.shot(game, out .. "/01-ring.png")

  -- Into the caller's own script.  One A gets past the ring page; the shot is
  -- taken with a page of Joey's chatter up, which is what the player sees for
  -- most of a call.
  U.tap(game, "a")
  U.wait(40)
  ok("the box survives into the call itself", boxIndex() ~= nil)
  U.shot(game, out .. "/02-talking.png")

  -- Now page through to the end: the hang-up Click!, then the tail rows.
  local finished = false
  for _ = 1, 400 do
    if not world:busy() and boxIndex() == nil then finished = true break end
    U.tap(game, "a")
    U.wait(4)
  end
  ok("the call ran to the end", finished, world:busy())
  ok("and InitCallReceiveDelay took the caller box down",
    boxIndex() == nil, boxIndex())
  U.wait(10)
  U.shot(game, out .. "/03-after.png")

  print(failures == 0 and "PASS gold_phone_caller_box"
    or ("FAIL gold_phone_caller_box (%d)"):format(failures))
  love.event.quit(failures == 0 and 0 or 1)
end

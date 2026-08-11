-- INDEPENDENT VERIFICATION of the incoming-call caller box
-- (src/ui/gen2/CallerBox.lua, Phone_TextboxWithName at pokegold
-- engine/phone/phone.asm:582).  tests/drivers/gold_phone_caller_box.lua takes
-- the random-call route; this one goes at the same seam from the other side:
--
--   * MOM'S route.  MomTriesToBuySomething (engine/events/mom_phone.asm) ends
--     `farsjump Script_ReceivePhoneCall` with an INLINE page list and
--     wCurCaller = PHONE_MOM, so its rows are built by the same
--     src/core/gen2/PhoneRing.lua script() as a random call but the caller is
--     a NON-trainer: GetCallerClassAndName stops at the colon and there is no
--     class row (:635-666).  The box has to name MOM and print nothing at
--     (6,2).
--   * IDEMPOTENCE.  Script_ReceivePhoneCall rings TWICE (RingTwice_StartCall
--     is `call .Ring` falling into .Ring, :458-469), so the push runs twice
--     and exactly one box may ever be on the stack.
--   * NO STALENESS.  A second call after the first must name the SECOND
--     caller, which is the check that catches a box cached anywhere across
--     calls.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_vf_caller_box2.lua love .
--   POKEPORT_SHOT_DIR=/tmp/gold-vf-callerbox   (default)
local U = require("tests.drivers.util")

local Phone = require("src.core.gen2.Phone")
local PhoneRing = require("src.core.gen2.PhoneRing")

local CALLER_BOX = "gen2CallerBox"

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-vf-callerbox"
  local failures = 0

  local function ok(label, condition, detail)
    if condition then
      print("[vf-box] ok   " .. label)
    else
      failures = failures + 1
      print("[vf-box] FAIL " .. label .. " " .. tostring(detail))
    end
  end

  -- Every caller box on the stack, in stack order.
  local function boxes()
    local found = {}
    for index, state in ipairs(game.stack.states or {}) do
      if state[CALLER_BOX] then found[#found + 1] = { index = index, state = state } end
    end
    return found
  end

  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")
  local vm = world.vm
  assert(vm, "no script VM")

  -- Runs one call to the end, watching the box the whole way.  `pages` is the
  -- caller's own script as an inline row list, which is exactly the shape
  -- World:momTriesToBuy hands PhoneRing.script.
  local function runCall(tag, contact, name, className, pages)
    vm.curPhoneCaller = contact
    local rows = PhoneRing.script({ scriptKey = pages }, name, className)
    assert(vm:start(rows), tag .. ": vm refused the call rows")

    -- The first ring pushes the box; the ring page only arrives after the
    -- second pass.  Watch every frame in between so a duplicate pushed by the
    -- second RingTwice_StartCall cannot be missed by a coarse sample.
    local maxBoxes, sawBox = 0, false
    for _ = 1, 400 do
      local n = #boxes()
      if n > maxBoxes then maxBoxes = n end
      if n > 0 then sawBox = true end
      if #game.stack.states > 1 and sawBox then break end
      U.wait(1)
    end
    U.wait(30)
    local live = boxes()
    ok(tag .. ": exactly one caller box is up", #live == 1, #live)
    ok(tag .. ": and both rings only ever put up one", maxBoxes <= 1, maxBoxes)
    local box = live[1] and live[1].state
    ok(tag .. ": it names the caller", box and box.name == name,
      box and box.name)
    ok(tag .. ": and carries the class the cart prints at (6,2)",
      box and box.className == className,
      box and tostring(box.className))
    ok(tag .. ": it is UNDER the call's text page",
      live[1] and live[1].index < #game.stack.states,
      live[1] and (live[1].index .. "/" .. #game.stack.states))
    ok(tag .. ": and is transparent, so the overworld still draws",
      box and box.isOpaque == false, box and tostring(box.isOpaque))
    ok(tag .. ": no update, so it cannot steal the fixed step",
      box and box.update == nil)
    U.shot(game, out .. "/" .. tag .. ".png")

    for _ = 1, 400 do
      if not world:busy() then break end
      U.tap(game, "a")
      U.wait(4)
    end
    ok(tag .. ": the call ran to the end", not world:busy())
    ok(tag .. ": and the box came down with it", #boxes() == 0, #boxes())
  end

  -- MOM: a non-trainer caller, so no class row.
  runCall("mom", Phone.PHONECONTACT_MOM,
    Phone.NON_TRAINER_NAMES[Phone.PHONECONTACT_MOM], nil,
    { { op = "rawtext", text = "…MOM: Hi!" },
      { op = "rawtext", text = "…MOM: Bye!" },
      { op = "end" } })

  -- A trainer caller straight after, to prove nothing is cached between calls.
  local trainers = game.data and game.data.trainers
  local joeyName, joeyClass = Phone.contactName(15, trainers)
  runCall("trainer", 15, joeyName, joeyClass,
    { { op = "rawtext", text = "…JOEY: Yo!" }, { op = "end" } })

  U.wait(10)
  U.shot(game, out .. "/after.png")
  ok("nothing left on the stack over the overworld",
    #game.stack.states == 0, #game.stack.states)

  print(failures == 0 and "PASS gold_vf_caller_box2"
    or ("FAIL gold_vf_caller_box2 (%d)"):format(failures))
  love.event.quit(failures == 0 and 0 or 1)
end

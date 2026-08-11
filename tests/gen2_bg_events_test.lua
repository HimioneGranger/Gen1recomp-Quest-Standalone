-- bg_event function bytes past BGEVENT_READ.
--
--   luajit tests/gen2_bg_events_test.lua
--
-- World:bgEventAt matched `kind == 0` and nothing else, which quietly dropped
-- five of the nine arms of BGEventJumptable (engine/overworld/events.asm:631).
-- The expensive one is BGEVENT_IFNOTSET: TeamRocketBaseB3F's locked door is two
-- of them, at (10,9) and (11,9), so pressing A at Giovanni's door did nothing,
-- EVENT_OPENED_DOOR_TO_GIOVANNIS_OFFICE could never be set, and the Rocket
-- hideout dead-ended one room short of its boss. Found by the Gold route bot,
-- which stood on the correct cell facing the correct way and reported
-- "postcondition ... not set" forever.
--
-- The other half of the fix is in the extractor: IFSET/IFNOTSET point at a
-- `conditional_event` (dw event / dba script), not at a script, so those five
-- bytes used to be disassembled as commands and came out as a stray `sjump`.
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 bg events")
local check, eq = S.check, S.eq

local World = require("src.world.gen2.World")

local function world(bgEvents, flags, facing)
  local set = flags or {}
  return setmetatable({
    map = { def = { bgEvents = bgEvents } },
    player = { facing = facing or "up" },
    events = { get = function(_, id) return set[id] or false end },
  }, { __index = World })
end

-- BGEVENT_READ still works, and still ignores which way you face.
do
  local ev = { x = 3, y = 4, kind = 0, scriptKey = "a:1" }
  local w = world({ ev }, nil, "left")
  eq(w:bgEventAt(3, 4), ev, "a READ event reads")
  check(w:bgEventAt(9, 9) == nil, "and only on its own cell")
end

-- The directional arms: `.checkdir` refuses unless the facing matches.
do
  local up = { x = 1, y = 1, kind = 1, scriptKey = "a:1" }
  eq(world({ up }, nil, "up"):bgEventAt(1, 1), up, "UP reads while facing up")
  check(world({ up }, nil, "down"):bgEventAt(1, 1) == nil,
        "and not while facing down")
  local left = { x = 1, y = 1, kind = 4, scriptKey = "a:1" }
  eq(world({ left }, nil, "left"):bgEventAt(1, 1), left, "LEFT reads facing left")
  check(world({ left }, nil, "right"):bgEventAt(1, 1) == nil,
        "and not facing right")
end

-- IFNOTSET: the locked door. Runs while the flag is CLEAR, and stops the moment
-- the door has been opened -- which is what keeps the "open sesame" text from
-- replaying every time you walk past.
do
  local door = { x = 10, y = 9, kind = 6, event = 800, scriptKey = "45:ad03" }
  eq(world({ door }, {}):bgEventAt(10, 9), door,
     "IFNOTSET reads while the event is clear")
  check(world({ door }, { [800] = true }):bgEventAt(10, 9) == nil,
        "and refuses once it is set")
end

-- IFSET is the mirror.
do
  local ev = { x = 2, y = 2, kind = 5, event = 42, scriptKey = "a:1" }
  check(world({ ev }, {}):bgEventAt(2, 2) == nil,
        "IFSET refuses while the event is clear")
  eq(world({ ev }, { [42] = true }):bgEventAt(2, 2), ev,
     "and reads once it is set")
end

-- A cache extracted before the conditional_event fix has no `event` field. It
-- must refuse rather than guess: running a door script unconditionally would
-- open Giovanni's office without the passwords.
do
  local stale = { x = 10, y = 9, kind = 6, scriptKey = "45:5da9" }
  check(world({ stale }, {}):bgEventAt(10, 9) == nil,
        "an unresolved conditional_event is refused, not guessed at")
end

-- BGEVENT_ITEM stays with HiddenItems, and COPY has nothing to run.
do
  local item = { x = 5, y = 5, kind = 7, scriptKey = "a:1" }
  check(world({ item }):bgEventAt(5, 5) == nil, "ITEM is not a script read")
  local copy = { x = 6, y = 6, kind = 8, scriptKey = "a:1" }
  check(world({ copy }):bgEventAt(6, 6) == nil, "COPY is not a script read")
end

S.finish()

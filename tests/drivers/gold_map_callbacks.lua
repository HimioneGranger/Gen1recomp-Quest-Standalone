-- Assertion driver: the four map callback types, run by a real map load in the
-- running game.  It PASSES or it errors; there is nothing to eyeball.
--
--   POKEPORT_GAME=gold POKEPORT_IDENTITY=gold-dev \
--     POKEPORT_DRIVER=tests/drivers/gold_map_callbacks.lua love .
--
-- tests/gen2_map_callbacks_test.lua checks the bodies and the order against
-- fixtures; what it cannot check is that a genuine World:setMap, with a genuine
-- cache under it, comes out the other side with the door shut and the right
-- day's NPC standing there.  So each check here sets the state the cart's own
-- callback branches on, loads the map for real, and reads the world back.
--
-- Every number is read out of the extracted callback body rather than typed in,
-- so a re-import that renumbers an event or an object fails on the LOOKUP with
-- a name attached instead of quietly asserting the wrong thing.
local U = require("tests.drivers.util")

return function(game)
  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")

  local function body(mapId, kind)
    local def = world.maps[mapId]
    assert(def, "no such map: " .. mapId)
    for _, cb in ipairs(def.callbacks or {}) do
      if cb.callback == kind then
        local list = world.scripts[cb.scriptKey]
        assert(list, ("%s %s names a body the cache does not carry (%s)")
          :format(mapId, kind, tostring(cb.scriptKey)))
        return list
      end
    end
    error(("%s declares no %s -- re-import, or the extractor lost it")
      :format(mapId, kind))
  end

  -- The first command of a kind in a body, so the driver can name a flag by the
  -- command that reads it rather than by a constant it would have to keep in
  -- sync with constants/event_flags.asm.
  local function firstOp(list, op)
    for _, cmd in ipairs(list) do
      if cmd.op == op then return cmd end
    end
    return nil
  end

  local function load(mapId, x, y)
    assert(world:setMap(mapId, x, y, "down"), "setMap failed for " .. mapId)
    U.wait(2)
  end

  -- ---- MAPCALLBACK_NEWMAP ------------------------------------------------
  -- GoldenrodUndergroundResetSwitchesCallback: fifteen clearevents and a
  -- `writemem wUndergroundSwitchPositions`.  The puzzle is only solvable
  -- because walking in resets it, so a callback that does not run leaves the
  -- doors wherever the last visit left them.
  do
    local list = body("GOLDENROD_UNDERGROUND", "MAPCALLBACK_NEWMAP")
    local cleared = {}
    for _, cmd in ipairs(list) do
      if cmd.op == "clearevent" then cleared[#cleared + 1] = cmd.event end
    end
    assert(#cleared >= 15,
      ("expected the fifteen switch/door events, found %d"):format(#cleared))
    for _, id in ipairs(cleared) do world.events:set(id, true) end
    load("GOLDENROD_UNDERGROUND", 3, 3)
    for _, id in ipairs(cleared) do
      assert(not world.events:get(id),
        ("MAPCALLBACK_NEWMAP left event %d set: the switches did not reset")
          :format(id))
    end
    U.log(("NEWMAP: the map load cleared all %d underground switch events")
      :format(#cleared))
  end

  -- ---- MAPCALLBACK_TILES -------------------------------------------------
  -- BrunosRoomDoorsCallback: `changeblock 4, 14, $2a` walls the entrance in
  -- once EVENT_BRUNOS_ROOM_ENTRANCE_CLOSED is set.  Script_changeblock's two
  -- bytes are CELL coordinates (`add 4` then GetBlockLocation's `srl`), so the
  -- block it rewrites is (x / 2, y / 2).
  do
    local list = body("BRUNOS_ROOM", "MAPCALLBACK_TILES")
    local seal = firstOp(list, "changeblock")
    local gate = firstOp(list, "checkevent")
    assert(seal and gate, "Bruno's TILES callback lost its changeblock")
    local args = seal.args or {}
    local bx = math.floor((seal.x or args[1]) / 2)
    local by = math.floor((seal.y or args[2]) / 2)
    local wall = seal.block or args[3]
    local def = world.maps.BRUNOS_ROOM
    local index = by * def.width + bx + 1

    world.events:set(gate.event, false)
    load("BRUNOS_ROOM", 4, 12)
    local open = def.blocks[index]
    assert(open ~= wall,
      "the entrance is already walled in with the event clear")

    world.events:set(gate.event, true)
    load("BRUNOS_ROOM", 4, 12)
    assert(def.blocks[index] == wall,
      ("MAPCALLBACK_TILES did not seal Bruno's door: block %d is %s, want %s")
        :format(index, tostring(def.blocks[index]), tostring(wall)))

    -- And it comes back.  restoreBlocks is LoadMapAttributes' refill; without
    -- the bake being dropped with it, the wall would have been painted into the
    -- cached canvas for the rest of the session.
    world.events:set(gate.event, false)
    load("BRUNOS_ROOM", 4, 12)
    assert(def.blocks[index] == open,
      "the wall did not come back out of the buffer when the event cleared")
    U.log(("TILES: Bruno's entrance block %d flips %s <-> %s with the event")
      :format(index, tostring(open), tostring(wall)))
  end

  -- ---- MAPCALLBACK_OBJECTS -----------------------------------------------
  -- Route29TuscanyCallback: ZEPHYRBADGE, then `readvar VAR_WEEKDAY` and
  -- `ifnotequal TUESDAY`.  One of the seven travelling siblings, and the
  -- clearest thing on the list that a player can walk up to and talk to.
  do
    local list = body("ROUTE_29", "MAPCALLBACK_OBJECTS")
    local badge = firstOp(list, "checkflag")
    assert(badge, "Route 29's OBJECTS callback lost its badge check")
    -- The `appear` sits in .DoesTuscanyAppear, behind the `iftrue`; what is in
    -- the body itself is the .TuscanyDisappears fallthrough, and it names the
    -- same object.
    local hide = firstOp(list, "disappear")
    assert(hide, "and its disappear")
    local objectId = hide.object or (hide.args and hide.args[1])
    assert(objectId, "the disappear names no object")
    local index = objectId - 1

    local function tuscanyOut()
      for _, npc in ipairs(world.npcs) do
        if npc.def and npc.def.index == index then return true end
      end
      return false
    end

    world:setEngineFlag(badge.flag or (badge.args and badge.args[1]), true)
    world.clockDay = 2 -- TUESDAY
    load("ROUTE_29", 20, 8)
    assert(tuscanyOut(),
      "MAPCALLBACK_OBJECTS did not put Tuscany on Route 29 on a Tuesday")

    world.clockDay = 3 -- WEDNESDAY
    load("ROUTE_29", 20, 8)
    assert(not tuscanyOut(), "and she is still there on a Wednesday")

    -- The badge is the outer gate: no badge, no sibling on any day.
    world:setEngineFlag(badge.flag or (badge.args and badge.args[1]), false)
    world.clockDay = 2
    load("ROUTE_29", 20, 8)
    assert(not tuscanyOut(),
      "she appears without ZEPHYRBADGE, so the callback's first branch is dead")
    world.clockDay = nil
    U.log("OBJECTS: Tuscany is on Route 29 on Tuesdays, with the badge, only")
  end

  -- ---- MAPCALLBACK_CMDQUEUE ----------------------------------------------
  -- Already driven end to end by gold_icepath_boulder; what belongs here is
  -- that the map load still fills the queue from the EXTRACTED callback now
  -- that the other four types run alongside it.
  do
    local CmdQueue = require("src.world.gen2.CmdQueue")
    load("ICE_PATH_B1F", 9, 2)
    assert(CmdQueue.count(world.cmdQueue) == 1,
      ("the Ice Path load left %d queue entries, want 1")
        :format(CmdQueue.count(world.cmdQueue)))
    assert(world:extractedCmdQueue(),
      "and the entry did not come from the extracted callback")
    load("NEW_BARK_TOWN", 13, 6)
    assert(CmdQueue.count(world.cmdQueue) == 0,
      "ClearCmdQueue: the queue must not survive a map load")
    U.log("CMDQUEUE: the Ice Path stone table rides the map load and no other")
  end

  -- ---- the invariant -----------------------------------------------------
  -- Nothing reachable from a callback may block: ScriptEvents runs inside the
  -- map load with no frame to come back on.  Vm:runCallback records any that
  -- tries, and after eleven real map loads the ledger has to be empty.
  do
    local blocked = {}
    for key in pairs(world.vm.blockedCallbacks or {}) do
      blocked[#blocked + 1] = key
    end
    assert(#blocked == 0,
      "map callbacks blocked: " .. table.concat(blocked, ", "))
    local unknown = {}
    for op in pairs(world.vm.unknownOps or {}) do unknown[#unknown + 1] = op end
    assert(#unknown == 0,
      "map callbacks reached unimplemented opcodes: "
        .. table.concat(unknown, ", "))
  end

  U.log("PASS gold_map_callbacks")
  love.event.quit()
end

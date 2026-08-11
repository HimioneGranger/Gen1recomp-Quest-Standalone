-- The four things the extractor pass unblocked, driven in the real game.
--
-- Every one of them was a pointer the importer emitted raw, so the engine had
-- an address and nothing behind it.  This driver walks the player to each and
-- asserts the feature actually runs, rather than shooting a screenshot for
-- someone to squint at:
--
--   1. a scripted static menu  -- Goldenrod Dept Store 6F's vending machine
--      (`loadmenu` / `verticalmenu`).  Every one of the seventeen sites took
--      the cancel arm before the MenuHeader pointer was followed.
--   2. the elevator            -- Goldenrod Dept Store's, whose floor list
--      lives in its own script bank.  The ride is a `warp_event` with
--      destination warp -1 reading what Elevator_GoToFloor left behind.
--   3. a special phone call    -- SPECIALCALL_ROBBED, whose script is in ROM
--      bank $41.  Nothing on any map points into that bank; the seed is
--      PhoneContacts itself.
--   4. an in-game trade        -- NPC_TRADE_MIKE, off data/events/npc_trades.asm.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold \
--     POKEPORT_DRIVER=tests/drivers/gold_extractor_pass.lua \
--     perl -e 'alarm 300; exec @ARGV' \
--     python3 -c "import pty; pty.spawn(['love','.'])"
local SHOT_DIR = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-extractor"

return function(game)
  local w = game.world
  local fails = 0

  local function wait(n) for _ = 1, n do coroutine.yield() end end

  local function ok(cond, msg)
    if cond then print("[extract] ok   " .. msg)
    else fails = fails + 1 print("[extract] FAIL " .. msg) end
    return cond
  end

  -- A tap is a press AND a release.  Writing pressQueue directly injects a
  -- press with no source map behind it (src/core/Input.lua Input:step), and
  -- nothing else will ever clear it, so a tap that skipped the release would
  -- leave that button HELD for the rest of the run -- which put DOWN under the
  -- player's thumb on arrival in the elevator and walked them straight back out
  -- through its COLL_WARP_CARPET_DOWN door.
  local function tap(btn)
    table.insert(game.input.pressQueue, btn)
    coroutine.yield()
    coroutine.yield()
    game.input.state[btn] = false
  end

  -- DoPlayerMovement's .CheckWarp (engine/overworld/player_movement.asm): an
  -- edge warp is only taken while its own direction is actually on the d-pad,
  -- so walking out of a lift needs a real hold rather than a tap.
  local function hold(btn, frames)
    for _ = 1, (frames or 1) do
      table.insert(game.input.pressQueue, btn)
      game.input.state[btn] = true
      coroutine.yield()
    end
    game.input.state[btn] = false
  end

  -- Gold runs on the engine's own src/core/StateStack.lua, the same stack
  -- Gen 1 uses (src/core/Game2.lua:makeStack), so ask it for the top rather
  -- than indexing a field.
  local function top()
    return game.stack and game.stack:top()
  end

  -- Run a script by key and step the world until it parks on something.
  local function runUntilIdle(limit)
    for _ = 1, (limit or 400) do
      if not w:busy() then return true end
      coroutine.yield()
    end
    return false
  end

  os.execute('mkdir -p "' .. SHOT_DIR .. '" 2>/dev/null')
  wait(45)

  -- ---------------------------------------------------------------- 1. menu
  --
  -- CeladonDeptStore6F / GoldenrodDeptStore6F's vending machine is
  -- `opentext / writetext / special PlaceMoneyTopRight / loadmenu / verticalmenu`,
  -- and the `ifequal 1..3` ladder after it is what buys a drink.  With no
  -- header there was nothing to open and the script fell to the cancel arm.
  --
  -- The pair is run as an INLINE command list (Vm:start takes one) rather than
  -- by starting the whole vending-machine script: everything in front of the
  -- menu is text boxes and a money panel, and none of that is what this is
  -- about.  The two commands are the cache's own, lifted out of a real site.
  local menuCmds
  for key, cmds in pairs(w.scripts) do
    if type(cmds) == "table" and key ~= "movements" and not menuCmds then
      for i, cmd in ipairs(cmds) do
        if cmd.op == "loadmenu" and cmd.menu and cmd.menu.items
            and cmds[i + 1] and cmds[i + 1].op == "verticalmenu" then
          menuCmds = { cmd, cmds[i + 1], { op = "end" } }
          break
        end
      end
    end
  end
  if ok(menuCmds ~= nil, "the cache has a loadmenu site with a real header") then
    w:setMap("GOLDENROD_DEPT_STORE_6F", 5, 5, "up")
    wait(20)
    ok(w.vm:start(menuCmds), "the VM took the loadmenu / verticalmenu pair")
    local opened = false
    for _ = 1, 60 do
      local state = top()
      if state and state.screenId == "Gen2ScriptMenu" then opened = true break end
      coroutine.yield()
    end
    ok(opened, "the vending machine opened its menu")
    local menu = top()
    if opened then
      ok(#menu.items >= 2,
        ("with %d items off the extracted header"):format(#menu.items))
      game.capturePath = SHOT_DIR .. "/menu.png"
      wait(2)
      -- Walk to the last row and pick it: CANCEL, the arm the script used to
      -- take by default.  Picking it deliberately proves the cursor moves and
      -- the answer is the 1-based index rather than a stuck 0.
      local want = #menu.items
      for _ = 1, want do tap("down") end
      ok(menu.row == want,
        ("the cursor reached row %d (got %d)"):format(want, menu.row))
      tap("a")
      wait(4)
      ok(top() ~= menu, "and choosing closed it")
      ok(w.vm.scriptVar == want,
        ("wScriptVar is the 1-based choice %d (got %s)")
          :format(want, tostring(w.vm.scriptVar)))
    end
    runUntilIdle(200)
  end

  -- ------------------------------------------------------------ 2. elevator
  --
  -- Elevator writes wBackupWarpNumber / wBackupMapGroup / wBackupMapNumber and
  -- rides nowhere; the elevator's own door -- a warp_event whose destination
  -- warp is -1 -- is what carries the player out onto the chosen floor.
  -- Pick GOLDENROD'S list by the floor it names, not by whichever `elevator`
  -- pairs() reaches first: the three lists are per-building, and running
  -- Celadon's from Goldenrod's lift is the .FindCurrentFloor miss that quits
  -- with no menu at all.
  local FLOOR = "GOLDENROD_DEPT_STORE_1F"
  local elevatorCmds
  for key, cmds in pairs(w.scripts) do
    if type(cmds) == "table" and key ~= "movements" and not elevatorCmds then
      for _, cmd in ipairs(cmds) do
        for _, floor in ipairs((cmd.op == "elevator" and cmd.floors) or {}) do
          if floor.destMap == FLOOR then
            elevatorCmds = { cmd, { op = "end" } }
            break
          end
        end
        if elevatorCmds then break end
      end
    end
  end
  if ok(elevatorCmds ~= nil, "the cache has an elevator with a floor list") then
    -- Arrive the way a player does, so wBackupMapNumber is the floor they got
    -- in on -- .FindCurrentFloor answers `scf` and skips the whole thing
    -- otherwise.
    w:setMap(FLOOR, 4, 2, "up")
    wait(10)
    local door
    for _, warp in ipairs(w.map.def.warps or {}) do
      if warp.destMap == "GOLDENROD_DEPT_STORE_ELEVATOR" then door = warp end
    end
    if ok(door ~= nil, "1F has a door into the elevator") then
      w:takeWarp(door)
      runUntilIdle(300)
      wait(20)
      ok(w.map.id == "GOLDENROD_DEPT_STORE_ELEVATOR",
        ("the player is in the elevator (got %s)"):format(w.map.id))
      ok(w.backupMapId == FLOOR,
        ("and came in from 1F (got %s)"):format(tostring(w.backupMapId)))
      -- The door is the thing under test: a `warp_event` whose destination
      -- warp is -1 names no floor of its own.
      local door_ = nil
      for _, warp in ipairs(w.map.def.warps or {}) do
        if warp.destWarp == 0xff then door_ = warp end
      end
      ok(door_ ~= nil, "the elevator's own door is a -1 warp")
      ok(door_ and w:resolveWarp(door_) == FLOOR,
        "which resolves to the floor we came in on until a ride is picked")
      ok(w.vm:start(elevatorCmds), "the VM took the elevator command")
      local opened = false
      for _ = 1, 60 do
        local state = top()
        if state and state.screenId == "Gen2ElevatorMenu" then opened = true break end
        coroutine.yield()
      end
      ok(opened, "the elevator opened its floor list")
      local lift = top()
      if opened then
        ok(lift.origin ~= nil, "with the floor it came in on marked")
        game.capturePath = SHOT_DIR .. "/elevator.png"
        wait(2)
        -- Ride to the top floor of the list, which is never the one we are on.
        for _ = 1, #lift.floors do tap("down") end
        local target = lift.floors[lift.index]
        tap("a")
        wait(4)
        ok(w.backupWarp ~= nil and w.backupWarp.map == target.destMap,
          ("Elevator_GoToFloor stored %s"):format(tostring(target.destMap)))
        -- The SAME door now resolves somewhere else, which is the whole of
        -- what the ride is: nothing about the map changed.
        ok(door_ and w:resolveWarp(door_) == target.destMap,
          ("and the door now resolves to %s"):format(
            tostring(target.destMap)))
        -- Elevator_GoToFloor rides nowhere: the player still has to walk out
        -- through the door, which is the edge warp the -1 destination is on.
        hold("down", 40)
        runUntilIdle(300)
        wait(20)
        ok(w.map.id == target.destMap,
          ("walking out opens on %s (got %s)"):format(target.destMap,
            w.map.id))
      end
    end
  end

  -- --------------------------------------------------------- 3. phone call
  --
  -- SPECIALCALL_ROBBED is Elm's "your POKeMON was stolen" beat.  Its script is
  -- ElmPhoneCallerScript at 41:41e1, reached only because the extractor seeds
  -- its queue from PhoneContacts.
  local Phone = require("src.core.gen2.Phone")
  local key = Phone.SCRIPT_KEYS.ElmPhoneCallerScript
  ok(w.scripts[key] ~= nil,
    ("ElmPhoneCallerScript (%s) is in scripts.lua"):format(tostring(key)))
  do
    -- The condition is SpecialCallOnlyWhenOutside, so stand in a town.
    w:setMap("NEW_BARK_TOWN", 5, 8, "down")
    wait(20)
    Phone.queueSpecialCall(game.save, Phone.SPECIALCALL.SPECIALCALL_ROBBED)
    local call = Phone.checkSpecialCall(game.save, {
      map = w.map.def, maps = w.maps, daytime = w.daytime,
      environment = w.map.def and w.map.def.environment,
    })
    if ok(call ~= nil, "CheckSpecialPhoneCall produced a call outdoors") then
      ok(call.scriptKey == key,
        ("aimed at the caller script (%s)"):format(tostring(call.scriptKey)))
      local before = w.unrunnableCalls or 0
      local ran = w:receivePhoneCall(call)
      ok(ran, "and the world RAN it rather than dropping it")
      ok((w.unrunnableCalls or 0) == before,
        "so nothing was counted as unrunnable")
      game.capturePath = SHOT_DIR .. "/phonecall.png"
      wait(2)
      for _ = 1, 300 do
        if not w:busy() then break end
        tap("a")
      end
      -- The script's own first act is `specialphonecall SPECIALCALL_NONE`.
      ok(not Phone.hasSpecialCall(game.save),
        "and the script cleared the queue on its way out")
    end
  end

  -- --------------------------------------------------------------- 4. trade
  --
  -- NPC_TRADE_MIKE: hand over a DROWZEE, get MACHOP nicknamed MUSCLE.
  local NpcTrade = require("src.core.gen2.NpcTrade")
  local row = NpcTrade.row(w.eventTables, 0)
  if ok(row ~= nil, "the cache carries the six in-game trades") then
    local Mon = require("src.battle.gen2.Mon")
    game.save.party = { Mon.new(game.data, row.give, 20) }
    game.save.tradeFlags = {}
    ok(game.save.party[1] ~= nil,
      ("a level 20 %s in the party"):format(tostring(row.give)))
    w:openNpcTrade(0, function() end)
    local trade = top()
    if ok(trade and trade.screenId == "Gen2TradeMenu", "the trade opened") then
      game.capturePath = SHOT_DIR .. "/trade.png"
      wait(2)
      -- Page to the yes/no, answer YES, then pick the only party member.
      for _ = 1, 30 do
        if trade.confirm and trade.confirm.page >= #trade.confirm.pages then
          break
        end
        tap("a")
      end
      tap("a") -- YES
      wait(4)
      local party = top()
      if ok(party and party.screenId == "Gen2PartyMenu",
          "and it opened the party list") then
        tap("a")
        wait(4)
        for _ = 1, 60 do
          if not top() or top() == trade then break end
          tap("a")
        end
        for _ = 1, 60 do
          if trade.closed then break end
          tap("a")
        end
      end
      local got = game.save.party[1]
      ok(got and got.species == row.get,
        ("the party now holds %s (got %s)"):format(tostring(row.get),
          tostring(got and got.species)))
      ok(got and got.nickname == row.nickname,
        ("nicknamed %s (got %s)"):format(tostring(row.nickname),
          tostring(got and got.nickname)))
      ok(got and got.otName == row.otName,
        ("with OT %s"):format(tostring(row.otName)))
      ok(got and got.level == 20, "at the level of the mon handed over")
      ok(NpcTrade.done(game.save, 0), "and the trade's flag is set")
    end
  end

  if fails > 0 then
    error(("gold extractor pass: %d assertion(s) failed"):format(fails), 0)
  end
  print("[driver] PASS gold extractor pass in " .. SHOT_DIR)
end

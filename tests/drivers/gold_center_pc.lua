-- Assertion driver: the Pokecenter PC and the bedroom PC, in the running game.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold \
--     POKEPORT_DRIVER=tests/drivers/gold_center_pc.lua \
--     perl -e 'alarm 300; exec @ARGV' \
--     python3 -c "import pty; pty.spawn(['love','.'])"
--
-- What it proves that tests/gen2_pc_screens_test.lua cannot: the whole chain
-- inside a live love session -- the A press on the Cherrygrove Pokecenter's
-- COLL_PC tile runs PCScript (engine/events/std_scripts.asm) through the real
-- input path, `special PokemonCenterPC` opens the whose-PC menu, <PLAYER>'s
-- PC deposits an item into save.pcItems, and the bedroom PC opens the ITEM PC
-- (PLAYERSPC_HOUSE), not the storage system.
--
-- Shots land in /tmp/gold-center-pc.
local U = require("tests.drivers.util")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-center-pc"
  local fails = 0

  local function ok(cond, msg)
    if cond then print("[centerpc] ok   " .. msg)
    else fails = fails + 1 print("[centerpc] FAIL " .. msg) end
    return cond
  end

  local function tap(button, frames)
    game.input.pressQueue[#game.input.pressQueue + 1] = button
    game.input.state[button] = true
    U.wait(2)
    game.input.state[button] = false
    U.wait(frames or 4)
  end

  U.wait(45)
  local w = game.world
  assert(w and w.map, "gold world did not boot")
  local save = game.save

  local Mon = require("src.battle.gen2.Mon")
  save.party = { Mon.new(game.data, "CYNDAQUIL", 10) }
  save.inventory = save.inventory or {}
  save.inventory.POTION = (save.inventory.POTION or 0) + 2
  save.pcItems = {}
  local potionsBefore = save.inventory.POTION

  local function topId()
    local top = game.stack:top()
    return top and top.screenId or nil
  end

  -- ---- the Pokecenter ------------------------------------------------------
  assert(w:setMap("CHERRYGROVE_POKECENTER_1F", 4, 4, "up"),
    "setMap CHERRYGROVE_POKECENTER_1F failed")
  U.wait(5)
  local pcX, pcY
  for cy = 0, w.map.heightCells - 1 do
    for cx = 0, w.map.widthCells - 1 do
      if w.map:cellCollision(cx, cy) == 0x93 then pcX, pcY = cx, cy end
    end
  end
  assert(pcX, "no COLL_PC tile in the Pokecenter")
  assert(w:setMap("CHERRYGROVE_POKECENTER_1F", pcX, pcY + 1, "up"),
    "setMap onto the PC tile failed")
  U.wait(5)

  tap("a", 8)
  ok(topId() == "Gen2CenterPcMenu",
    "A at the Pokecenter PC opens the whose-PC menu (top: "
      .. tostring(topId()) .. ")")
  U.shot(game, out .. "/01-turned-on.png")
  tap("a", 4) -- the turn-on line
  U.shot(game, out .. "/02-whose-pc.png")

  -- <PLAYER>'s PC, then DEPOSIT ITEM, then one POTION into the PC.
  tap("down", 4)
  tap("a", 4)
  tap("a", 4)
  tap("a", 6) -- both PokecenterPlayersPCText pages
  ok(topId() == "Gen2ItemPcMenu",
    "<PLAYER>'s PC opens the item PC (top: " .. tostring(topId()) .. ")")
  U.shot(game, out .. "/03-item-pc.png")
  tap("down", 4)
  tap("a", 6)  -- DEPOSIT ITEM -> the PACK chooser
  U.shot(game, out .. "/04-deposit-pack.png")
  tap("a", 4)  -- the POTION row
  tap("a", 6)  -- x1
  ok(save.pcItems.POTION == 1,
    "one POTION landed in save.pcItems (" .. tostring(save.pcItems.POTION) .. ")")
  ok(save.inventory.POTION == potionsBefore - 1,
    "and left the bag (" .. tostring(save.inventory.POTION) .. ")")
  U.shot(game, out .. "/05-deposited.png")
  tap("a", 4)  -- the Deposited line
  tap("b", 6)  -- close the PACK
  tap("b", 4)  -- LOG OFF row is last; B logs off too
  ok(topId() == "Gen2CenterPcMenu", "logging off returns to the whose-PC menu")
  tap("b", 6)  -- shutdown
  ok(topId() == nil or topId() ~= "Gen2CenterPcMenu",
    "B shuts the Pokecenter PC down")

  -- ---- the bedroom ---------------------------------------------------------
  local house = w.maps and w.maps.PLAYERS_HOUSE_2F
  local hx, hy
  for _, ev in ipairs((house and house.bgEvents) or {}) do
    if ev.kind == 1 then hx, hy = ev.x, ev.y end -- BGEVENT_UP: the PC
  end
  assert(hx, "no BGEVENT_UP bg event in PLAYERS_HOUSE_2F")
  assert(w:setMap("PLAYERS_HOUSE_2F", hx, hy + 1, "up"),
    "setMap PLAYERS_HOUSE_2F failed")
  U.wait(5)

  tap("a", 8)
  local top = game.stack:top()
  ok(top and top.screenId == "Gen2ItemPcMenu",
    "the bedroom PC is the ITEM PC (top: " .. tostring(topId()) .. ")")
  ok(top and top.house == true, "in its PLAYERSPC_HOUSE shape")
  U.shot(game, out .. "/06-bedroom-boot.png")
  tap("a", 4) -- the turn-on line
  U.shot(game, out .. "/07-bedroom-menu.png")
  -- WITHDRAW the POTION deposited downstairs: the PC is one PC.
  tap("a", 6)
  tap("a", 4)
  tap("a", 6)
  ok(save.pcItems.POTION == nil,
    "the POTION withdrawn upstairs left the PC")
  ok(save.inventory.POTION == potionsBefore,
    "and is back in the bag (" .. tostring(save.inventory.POTION) .. ")")
  tap("a", 4) -- the Withdrew line
  tap("b", 4) -- back to the menu
  tap("b", 6) -- TURN OFF
  ok(game.stack:top() ~= top, "closing the bedroom PC pops it")
  ok(not w.vm:running(), "and PlayersHousePCScript ran to its end")

  print(("[centerpc] %d failures"):format(fails))
  love.event.quit(fails == 0 and 0 or 1)
end

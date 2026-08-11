-- Assertion driver: field item use from the PACK, end to end in the running
-- game.  It PASSES or it errors; there is nothing to eyeball.
--
--   POKEPORT_GAME=gold POKEPORT_IDENTITY=gold-dev \
--     POKEPORT_DRIVER=tests/drivers/gold_field_items.lua love .
--
-- tests/gen2_field_items_test.lua proves the effects and the menu wiring over
-- fixtures and a recording setMap; what it cannot prove is the whole loop --
-- a real START press, the real PACK over the real overworld, the queued
-- escape warp riding a genuine map load, and the SELECT box tearing down to
-- an empty stack.  So this drives everything with button taps:
--
--   1. bank the escape triple by taking Cherrygrove's Pokecenter stairs,
--      then use an ESCAPE ROPE from the PACK inside Union Cave B2F and land
--      back on the banked staircase (engine/events/overworld.asm
--      EscapeRopeOrDig, via the -1 backup triple this port banks);
--   2. use a POTION from the PACK on a hurt party mon through the real
--      "Use on which <PK><MN>?" list (pack.asm UseItem .Party);
--   3. an X ATTACK from the field PACK prints OakThisIsntTheTimeText and
--      stays in the PACK (UseItem's .Oak arm);
--   4. the SELECT MayRegisterItemText box pages and dismisses without
--      leaving anything on the stack.
local U = require("tests.drivers.util")
local Mon = require("src.battle.gen2.Mon")

return function(game)
  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")
  local save = game.save

  save.party = { Mon.new(game.data, "CYNDAQUIL", 12) }
  assert(save.party[1], "the cache carries no CYNDAQUIL to seed a party")

  local function tapUntil(predicate, tries, btn)
    for _ = 1, tries or 300 do
      if predicate() then return true end
      U.tap(game, btn or "a")
      U.wait(2)
    end
    return predicate()
  end

  -- START, then walk the cursor to the PACK row and open it.
  local function openPack()
    U.tap(game, "start")
    U.wait(3)
    local menu = game.stack:top()
    assert(menu and menu.list, "START menu did not open")
    local guard = 0
    while menu.list:current().value ~= "pack" do
      U.tap(game, "down")
      U.wait(2)
      guard = guard + 1
      assert(guard < 12, "no PACK row in the START menu")
    end
    U.tap(game, "a")
    U.wait(3)
    local pack = game.stack:top()
    assert(pack and pack.rows, "PACK did not open")
    return pack
  end

  -- ---- 1. the escape rope --------------------------------------------------

  -- Bank the triple the way play does: up the Cherrygrove stairs, whose
  -- arrival warp declares -1 (tests/gen2_pokecenter_stairs_test.lua owns the
  -- banking rules; this run just rides them).
  assert(world:setMap("CHERRYGROVE_POKECENTER_1F", 3, 4, "down"),
    "setMap CHERRYGROVE_POKECENTER_1F failed")
  U.wait(5)
  local stairs = world.maps.CHERRYGROVE_POKECENTER_1F.warps[3]
  world.player.cellX, world.player.cellY = stairs.x, stairs.y
  assert(world:takeWarp(stairs), "the Pokecenter stairs refused")
  for _ = 1, 300 do
    if world.map.id == "POKECENTER_2F" and not world.mapSetup then break end
    U.wait(1)
  end
  assert(world.map.id == "POKECENTER_2F", "did not arrive on POKECENTER_2F")
  assert(world.backupWarp
      and world.backupWarp.map == "CHERRYGROVE_POKECENTER_1F",
    "the -1 arrival did not bank the Cherrygrove triple")

  assert(world:setMap("UNION_CAVE_B2F", 5, 3, "down"),
    "setMap UNION_CAVE_B2F failed")
  U.wait(5)
  save.inventory = { ESCAPE_ROPE = 1 }

  local pack = openPack()
  assert(pack.rows[1] and pack.rows[1].id == "ESCAPE_ROPE",
    "the PACK does not show the ESCAPE ROPE")
  -- A picks the row and opens the item submenu
  -- (.ItemBallsKey_LoadSubmenu, engine/items/pack.asm:243); USE is its first
  -- row, so using an item from the field PACK is two presses.
  U.tap(game, "a")
  U.wait(2)
  assert(pack.submenu, "A on a field PACK row did not open the item submenu")
  U.tap(game, "a")
  U.wait(3)
  assert(game.stack:top() ~= pack,
    "using the rope must quit the PACK (PACKSTATE_QUITRUNSCRIPT)")
  -- The queued script: the used-rope line over the overworld, then the warp.
  tapUntil(function()
    return game.stack:top() == nil and not world.mapSetup
      and world.map.id ~= "UNION_CAVE_B2F"
  end)
  assert(world.map.id == "CHERRYGROVE_POKECENTER_1F",
    "the rope did not pay out to the banked centre (on "
      .. tostring(world.map.id) .. ")")
  assert(world.player.cellX == stairs.x and world.player.cellY == stairs.y,
    "the rope landed off the banked staircase tile")
  assert(save.inventory.ESCAPE_ROPE == nil, "the rope was not consumed")
  U.log("PASS escape rope: Union Cave B2F -> Cherrygrove stairs, consumed")

  -- ---- 2. a POTION on a party mon -----------------------------------------

  local mon = save.party[1]
  mon.hp = 5
  save.inventory = { POTION = 1 }
  local healPack = openPack()
  assert(healPack.rows[1] and healPack.rows[1].id == "POTION",
    "the PACK does not show the POTION")
  U.tap(game, "a")  -- the submenu
  U.wait(2)
  U.tap(game, "a")  -- USE
  U.wait(3)
  local party = game.stack:top()
  assert(party and party.prompt, "USE did not open the party list")
  U.tap(game, "a")
  U.wait(3)
  tapUntil(function() return game.stack:top() == healPack end)
  assert(game.stack:top() == healPack,
    "the heal message did not return to the PACK")
  assert(mon.hp == 25, "POTION healed to " .. tostring(mon.hp) .. ", want 25")
  assert(save.inventory.POTION == nil, "the POTION was not consumed")
  U.tap(game, "b")
  U.wait(2)
  U.tap(game, "b")
  U.wait(2)
  assert(game.stack:top() == nil, "the menus did not unwind after the heal")
  U.log("PASS potion: healed a party mon from the PACK, consumed")

  -- ---- 3. the .Oak refusal -------------------------------------------------

  -- A tossable field-NOUSE item is MenuHeader_HoldableItem: GIVE / TOSS /
  -- QUIT, with no USE row at all -- the cart refuses an X ATTACK in the field
  -- by never offering the verb.
  save.inventory = { X_ATTACK = 1 }
  local oakPack = openPack()
  U.tap(game, "a")
  U.wait(2)
  assert(oakPack.submenu, "A on the X ATTACK opened no submenu")
  assert(table.concat(oakPack.submenu.rows, ",") == "give,toss,quit",
    "the X ATTACK submenu is " .. table.concat(oakPack.submenu.rows, ","))
  U.tap(game, "b")
  U.wait(2)
  assert(save.inventory.X_ATTACK == 1, "backing out must not spend the item")
  U.tap(game, "b")
  U.wait(2)
  U.tap(game, "b")
  U.wait(2)
  assert(game.stack:top() == nil, "the menus did not unwind after the submenu")

  -- ...and an untossable one still gets USE, because .ItemBallsKey_LoadSubmenu's
  -- untossable arm never looks at the menu nibble -- so THAT is where
  -- OakThisIsntTheTimeText is still reachable in the field.
  save.inventory = { SECRETPOTION = 1 }
  local keyPack = openPack()
  while keyPack:pocket().id ~= "KEY_ITEM" do
    U.tap(game, "right")
    U.wait(2)
  end
  U.tap(game, "a")
  U.wait(2)
  assert(table.concat(keyPack.submenu.rows, ",") == "use,quit",
    "the SECRETPOTION submenu is " .. table.concat(keyPack.submenu.rows, ","))
  U.tap(game, "a")
  U.wait(2)
  assert(keyPack.message, "the key item printed no Oak line")
  assert(game.stack:top() == keyPack, "the refusal must keep the PACK open")
  assert(save.inventory.SECRETPOTION == 1,
    "the refusal must not spend the item")
  U.tap(game, "a")
  U.wait(2)
  U.tap(game, "b")
  U.wait(2)
  U.tap(game, "b")
  U.wait(2)
  assert(game.stack:top() == nil, "the menus did not unwind after the refusal")
  U.log("PASS oak: field-NOUSE key item refused inside the PACK")

  -- ---- 4. the SELECT box ---------------------------------------------------

  U.tap(game, "select")
  U.wait(3)
  local box = game.stack:top()
  assert(box and box.pages, "SELECT with nothing registered opened no box")
  assert(#box.pages == 2, "MayRegisterItemText must page: got "
    .. tostring(#box.pages))
  tapUntil(function() return game.stack:top() == nil end)
  assert(game.stack:top() == nil, "the SELECT box did not tear down")
  -- And nothing half-dismissed lingers: a second press opens a fresh one.
  U.tap(game, "select")
  U.wait(3)
  assert(game.stack:top() ~= nil, "the second SELECT box did not open")
  tapUntil(function() return game.stack:top() == nil end)
  U.log("PASS select: MayRegisterItemText pages and tears down cleanly")

  -- ---- 5. DIG through the party submenu -----------------------------------

  -- The same escape consumer off the MONMENU_FIELD_MOVE row: the triple is
  -- still banked from the stairs above.
  local mon2 = save.party[1]
  mon2.moves = { { id = "DIG", pp = 10, maxPp = 10 } }
  assert(world:setMap("UNION_CAVE_B2F", 5, 3, "down"),
    "setMap UNION_CAVE_B2F failed for DIG")
  U.wait(5)
  U.tap(game, "start")
  U.wait(3)
  local menu = game.stack:top()
  assert(menu and menu.list, "START menu did not open for DIG")
  local guard = 0
  while menu.list:current().value ~= "pokemon" do
    U.tap(game, "down")
    U.wait(2)
    guard = guard + 1
    assert(guard < 12, "no POKeMON row in the START menu")
  end
  U.tap(game, "a")
  U.wait(3)
  local list = game.stack:top()
  assert(list and list.wantsSubmenu, "the field party list did not open")
  U.tap(game, "a")
  U.wait(2)
  assert(list.submenu, "the mon submenu did not open")
  assert(list.submenu.items[1] and list.submenu.items[1].id == "DIG",
    "DIG is not the submenu's field-move row")
  U.tap(game, "a")
  U.wait(3)
  tapUntil(function()
    return game.stack:top() == nil and not world.mapSetup
      and world.map.id ~= "UNION_CAVE_B2F"
  end)
  assert(world.map.id == "CHERRYGROVE_POKECENTER_1F",
    "DIG did not pay out to the banked centre (on "
      .. tostring(world.map.id) .. ")")
  U.log("PASS dig: the party submenu row escapes to the banked warp")

  U.log("PASS gold_field_items")
  love.event.quit()
end

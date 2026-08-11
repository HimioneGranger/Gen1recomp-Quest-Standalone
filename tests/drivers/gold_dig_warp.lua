-- Assertion driver: the dig / escape triple that an ordinary door banks, and
-- the rod's BATTLETYPE_FISH, end to end in the running game.  It PASSES or it
-- errors; there is nothing to eyeball.
--
--   POKEPORT_GAME=gold POKEPORT_IDENTITY=gold-dev \
--     POKEPORT_DRIVER=tests/drivers/gold_dig_warp.lua love .
--
-- tests/gen2_dig_warp_test.lua proves the rule over the real map headers with
-- a recording setMap; what it cannot prove is a genuine map load underneath
-- it.  home/map.asm EnterMapWarp `.SaveDigWarp` banks the door on every
-- outdoor-to-indoor warp, so DARK CAVE entered off Route 31 must rope out onto
-- Route 31 and the same cave entered off Route 46 must rope out onto Route 46.
--
-- The tail rides World:updateFishing through the real stack: FishFunction's
-- `.goodtofish` writes BATTLETYPE_FISH beside the hooked mon, and that is the
-- one condition LureBallMultiplier reads.
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

  local function settle(mapId)
    for _ = 1, 300 do
      if world.map.id == mapId and not world.mapSetup then return true end
      U.wait(1)
    end
    return world.map.id == mapId and not world.mapSetup
  end

  -- Walk a real warp tile: stand on the door and take it, the way
  -- TryTileCollisionEvent's warpcheck does.
  local function useDoor(fromMap, warpIndex, intoMap)
    assert(world:setMap(fromMap, 5, 5, "down"), "setMap " .. fromMap .. " failed")
    U.wait(5)
    local door = world.maps[fromMap].warps[warpIndex]
    assert(door, fromMap .. " has no warp " .. warpIndex)
    world.player.cellX, world.player.cellY = door.x, door.y
    assert(world:takeWarp(door), fromMap .. " warp " .. warpIndex .. " refused")
    assert(settle(intoMap), "did not arrive on " .. intoMap
      .. " (on " .. tostring(world.map.id) .. ")")
    return door
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

  -- ---- the door banks, and the rope comes out of it ------------------------

  local function ropeOutOf(routeId, warpIndex)
    local door = useDoor(routeId, warpIndex, "DARK_CAVE_VIOLET_ENTRANCE")
    assert(world.backupWarp, routeId .. ": the cave door banked no triple")
    assert(world.backupWarp.map == routeId,
      routeId .. ": banked " .. tostring(world.backupWarp.map) .. " instead")
    assert(world.backupWarp.warp == warpIndex,
      routeId .. ": banked warp " .. tostring(world.backupWarp.warp))

    save.inventory = { ESCAPE_ROPE = 1 }
    local pack = openPack()
    assert(pack.rows[1] and pack.rows[1].id == "ESCAPE_ROPE",
      "the PACK does not show the ESCAPE ROPE")
    -- A opens the item submenu (.ItemBallsKey_LoadSubmenu,
    -- engine/items/pack.asm:243) and USE is its first row.
    U.tap(game, "a")
    U.wait(2)
    U.tap(game, "a")
    U.wait(3)
    assert(game.stack:top() ~= pack,
      "using the rope must quit the PACK (PACKSTATE_QUITRUNSCRIPT)")
    tapUntil(function()
      return game.stack:top() == nil and not world.mapSetup
        and world.map.id ~= "DARK_CAVE_VIOLET_ENTRANCE"
    end)
    assert(world.map.id == routeId,
      "the rope paid out to " .. tostring(world.map.id) .. ", not " .. routeId)
    assert(world.player.cellX == door.x and world.player.cellY == door.y,
      routeId .. ": the rope landed off the door tile")
    assert(save.inventory.ESCAPE_ROPE == nil, "the rope was not consumed")
  end

  ropeOutOf("ROUTE_31", 3)
  U.log("PASS dig warp: DARK CAVE off Route 31 ropes back onto Route 31")
  ropeOutOf("ROUTE_46", 3)
  U.log("PASS dig warp: the same cave off Route 46 ropes back onto Route 46")

  -- Leaving a cave for a route is indoor-to-outdoor: nothing banks.
  useDoor("ROUTE_31", 3, "DARK_CAVE_VIOLET_ENTRANCE")
  local banked = world.backupWarp
  useDoor("DARK_CAVE_VIOLET_ENTRANCE", 1, "ROUTE_31")
  assert(world.backupWarp == banked,
    "walking OUT of the cave rewrote the dig triple")
  U.log("PASS dig warp: an indoor-to-outdoor door leaves the triple alone")

  -- ---- the rod's own battle carries BATTLETYPE_FISH ------------------------

  local hooked = Mon.new(game.data, "MAGIKARP", 10)
  assert(hooked, "the cache carries no MAGIKARP")
  world.fishing = { phase = "bite", timer = 0, outcome = "battle",
    wild = hooked }
  world:updateFishing()
  tapUntil(function()
    local top = game.stack:top()
    return top ~= nil and top.battle ~= nil
  end)
  local screen = game.stack:top()
  assert(screen and screen.battle, "the rod's bite did not push a battle")
  assert(screen.battle.battleType == "fish",
    "the rod's battle carries battleType "
      .. tostring(screen.battle.battleType))
  U.log("PASS fishing: the rod's encounter carries BATTLETYPE_FISH")

  U.log("PASS gold_dig_warp")
  love.event.quit()
end

-- Assertion driver: the PACK inside a real battle, driven with button taps.
-- It PASSES or it errors; there is nothing to eyeball.
--
--   POKEPORT_GAME=gold POKEPORT_IDENTITY=gold-dev \
--     POKEPORT_DRIVER=tests/drivers/gold_battle_items.lua love .
--
-- tests/gen2_battle_items_test.lua proves each item_effects.asm family over
-- fixtures by calling BattleState:useItem; what it cannot prove is the link in
-- front of it -- BattleMenu's PACK row opening the real pack over a real
-- battle, the real "Use on which <PK><MN>?" list on top of that, and the pick
-- landing on a BENCHED mon.  So this revives a fainted party member from
-- inside a wild battle with nothing but taps (ReviveEffect through
-- UseItem_SelectMon), then spends an ETHER through the move list
-- (RestorePPEffect's MoveSelectionScreen pick).
local U = require("tests.drivers.util")
local Mon = require("src.battle.gen2.Mon")

return function(game)
  U.wait(45)
  local world = game.world
  assert(world and world.map, "gold world did not boot")
  local save = game.save

  local lead = Mon.new(game.data, "CYNDAQUIL", 12)
  local bench = Mon.new(game.data, "TOTODILE", 12)
  assert(lead and bench, "the cache carries no starters to seed a party")
  bench.hp = 0
  bench.status = "faint"
  save.party = { lead, bench }
  save.inventory = { REVIVE = 1, ETHER = 1 }

  local function battleScreen()
    local top = game.stack:top()
    return (top and top.battle) and top or nil
  end

  local function tapUntil(predicate, tries, btn)
    for _ = 1, tries or 400 do
      if predicate() then return true end
      U.tap(game, btn or "a")
      U.wait(2)
    end
    return predicate()
  end

  local wild = Mon.new(game.data, "PIDGEY", 3)
  assert(wild, "the cache carries no PIDGEY")
  assert(world:startBattle({ wild = wild }), "the wild battle refused to start")
  assert(tapUntil(function()
    local screen = battleScreen()
    return screen ~= nil and screen.phase == "menu"
  end), "the battle never reached BattleMenu")
  local screen = battleScreen()

  -- BattleMenuHeader's 2x2 grid, filled row-major: 1 FIGHT / 2 PkMn on top,
  -- 3 PACK / 4 RUN below.  LEFT swaps an even column to its odd neighbour and
  -- DOWN swaps the row, so those two presses reach PACK from any cursor.
  local function openPack()
    for _ = 1, 300 do
      if screen.phase == "moves" then
        U.tap(game, "b")
        U.wait(2)
      end
      if screen.phase == "menu" then break end
      U.wait(1)
    end
    assert(screen.phase == "menu", "the battle menu never came back")
    if screen.menuIndex % 2 == 0 then
      U.tap(game, "left")
      U.wait(3)
    end
    if screen.menuIndex <= 2 then
      U.tap(game, "down")
      U.wait(3)
    end
    assert(screen.menuIndex == 3,
      "the cursor sat on menu slot " .. tostring(screen.menuIndex))
    U.tap(game, "a")
    U.wait(4)
    local pack = game.stack:top()
    assert(pack and pack.rows, "the battle PACK did not open")
    return pack
  end

  -- ---- REVIVE on the fainted BENCHED mon ----------------------------------

  local pack = openPack()
  local reviveRow
  for index, row in ipairs(pack.rows) do
    if row.id == "REVIVE" then reviveRow = index end
  end
  assert(reviveRow, "the battle PACK does not show the REVIVE")
  for _ = 2, reviveRow do
    U.tap(game, "down")
    U.wait(2)
  end
  U.tap(game, "a")
  U.wait(4)
  local party = game.stack:top()
  assert(party and party.prompt, "the REVIVE did not open UseItem_SelectMon")
  -- Down to the second slot, which is the fainted one, then take it.
  U.tap(game, "down")
  U.wait(2)
  U.tap(game, "a")
  U.wait(6)
  local half = math.max(1, math.floor((bench.maxHp or bench.stats.hp) / 2))
  assert(bench.hp == half,
    "the REVIVE left the benched mon at " .. tostring(bench.hp)
      .. ", not ReviveHalfHP's " .. half)
  assert(save.inventory.REVIVE == nil, "the REVIVE was not consumed")
  U.log("PASS battle pack: REVIVE stands a BENCHED mon up mid-battle")

  -- ---- ETHER through the move list ----------------------------------------

  assert(tapUntil(function()
    return screen.phase == "menu" or screen.phase == "moves"
  end), "the revive turn never drained back to the menu")
  local slot = lead.moves and lead.moves[1]
  assert(slot, "the lead mon knows no moves")
  slot.pp = math.max(0, (slot.maxPp or slot.pp or 10) - 12)
  local before = slot.pp

  local ppPack = openPack()
  local etherRow
  for index, row in ipairs(ppPack.rows) do
    if row.id == "ETHER" then etherRow = index end
  end
  assert(etherRow, "the battle PACK does not show the ETHER")
  for _ = 2, etherRow do
    U.tap(game, "down")
    U.wait(2)
  end
  U.tap(game, "a")
  U.wait(4)
  local pickMon = game.stack:top()
  assert(pickMon and pickMon.prompt, "the ETHER did not open the party list")
  U.tap(game, "a")
  U.wait(4)
  local moveList = game.stack:top()
  assert(moveList and moveList ~= pickMon and moveList.list,
    "the ETHER did not open the move list")
  U.tap(game, "a")
  U.wait(6)
  assert(slot.pp == math.min(slot.maxPp or slot.pp, before + 10),
    "the ETHER restored " .. tostring(slot.pp - before) .. " PP, not 10")
  assert(save.inventory.ETHER == nil, "the ETHER was not consumed")
  U.log("PASS battle pack: ETHER restores PP through the move list")

  U.log("PASS gold_battle_items")
  love.event.quit()
end

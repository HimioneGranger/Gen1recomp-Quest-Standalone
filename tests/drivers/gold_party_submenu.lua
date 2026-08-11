-- The field party list, end to end through the pad: START > POKéMON opens
-- the list, A on a mon opens PokemonActionSubmenu (engine/pokemon/
-- mon_menu.asm), STATS pushes the summary, SWITCH reorders the save's own
-- party, and an EGG slot offers only STATS / SWITCH / CANCEL with an EGG row
-- and the EGG icon (engine/pokemon/party_menu.asm, mon_submenu.asm .egg).
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold \
--     POKEPORT_DRIVER=tests/drivers/gold_party_submenu.lua \
--     perl -e 'alarm 300; exec @ARGV' \
--     python3 -c "import pty; pty.spawn(['love','.'])"
local U = require("tests.drivers.util")

return function(game)
  local fails = 0
  local function ok(cond, msg)
    if cond then print("[party] ok   " .. msg)
    else fails = fails + 1 print("[party] FAIL " .. msg) end
    return cond
  end

  local function tap(btn) U.tap(game, btn) U.wait(3) end
  local function top() return game.stack:top() end

  U.wait(45)
  ok(game.world and game.world.map, "gold world booted")

  -- A real party out of the one Gen 2 builder, and the egg out of the same
  -- giveegg builder the aide's script calls (World:giveEgg, species index
  -- 175 = TOGEPI).
  local Mon = require("src.battle.gen2.Mon")
  local save = game.save
  save.party = {
    Mon.new(game.data, "CYNDAQUIL", 12),
    Mon.new(game.data, "TOTODILE", 10),
  }
  ok(game.world:giveEgg(175, 5), "giveegg filled slot 3")
  ok(save.party[3] and save.party[3].isEgg == true, "and marked it an egg")

  -- The cache carries the egg's own menu icon (ICON_EGG, IconPointers).
  local icons = game.data.gen2Icons
  ok(icons and icons.icons and icons.icons.ICON_EGG
    and icons.icons.ICON_EGG.image ~= nil, "the cache has ICON_EGG")

  -- START opens the menu; walk the cursor to the POKéMON row.
  tap("start")
  local menu = top()
  ok(menu and menu.screenId == "Gen2StartMenu", "START opened the menu")
  for _ = 1, 10 do
    if menu.list:current().value == "pokemon" then break end
    tap("down")
  end
  ok(menu.list:current().value == "pokemon", "the cursor found POKéMON")
  tap("a")

  local party = top()
  if not ok(party and party.screenId == "Gen2PartyMenu",
      "POKéMON opened the list") then
    error("gold party submenu: no party list, cannot continue")
  end
  ok(party.wantsSubmenu == true, "as the field flavour")

  -- The EGG row is a name and an icon alone.
  if party then
    local eggRow = party.rowFor(save.party[3])
    ok(eggRow.name == "EGG" and eggRow.hp == nil and eggRow.status == nil,
      "the egg's row reads EGG with no HP or FNT")
    ok(party:iconIdFor(save.party[3]) == "ICON_EGG",
      "and draws the EGG icon")
  end

  -- A on the lead mon: the submenu, not an exit.
  tap("a")
  ok(top() == party, "a kept the list open")
  ok(party and party.submenu ~= nil, "and opened the submenu")
  ok(party and party.submenu
    and party.submenu.items[1].id == "STATS", "STATS leads it")

  -- STATS pushes the summary over the list.
  tap("a")
  local summary = top()
  ok(summary and summary.screenId == "Gen2SummaryMenu", "STATS opened the summary")
  ok(summary and summary.mon and summary.mon.species == "CYNDAQUIL",
    "on the chosen mon")
  tap("b")
  ok(top() == party, "b landed back on the list")

  -- SWITCH: hold slot 1, drop it on slot 2.
  tap("a")
  tap("down")
  ok(party and party.submenu
    and party.submenu.items[party.submenu.index].id == "SWITCH",
    "the cursor found SWITCH")
  tap("a")
  ok(party and party.submenu == nil and party.switchFrom == 1,
    "SWITCH holds the slot")
  tap("down")
  tap("a")
  ok(save.party[1].species == "TOTODILE"
    and save.party[2].species == "CYNDAQUIL", "the party reordered")
  ok(party and party.switchFrom == nil, "and the hold released")

  -- The egg's own submenu: STATS / SWITCH / CANCEL, and STATS shows the EGG
  -- page with no species anywhere on it.
  tap("down")
  ok(party and party.index == 3, "the cursor reached the egg")
  tap("a")
  local items = party and party.submenu and party.submenu.items or {}
  ok(#items == 3 and items[1].id == "STATS" and items[2].id == "SWITCH"
    and items[3].id == "CANCEL", "an egg offers STATS / SWITCH / CANCEL")
  tap("a")
  summary = top()
  ok(summary and summary.screenId == "Gen2SummaryMenu", "STATS on the egg opened")
  if summary and summary.screenId == "Gen2SummaryMenu" then
    local SummaryMenu = require("src.ui.gen2.SummaryMenu")
    local page = summary:placements()
    ok(SummaryMenu.at(page, 8, 1) == "EGG", "as the EGG page")
    ok(SummaryMenu.at(page, 8, 2) == nil
      and SummaryMenu.at(page, 10, 4) == nil, "with the species kept secret")
    U.shot(game, (os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-party")
      .. "/egg-summary.png")
    tap("b")
  end
  ok(top() == party, "b came back to the list")

  -- Back out of everything.
  tap("b")
  ok(top() ~= party, "b closed the list")
  tap("b")

  if fails > 0 then
    error(("gold party submenu: %d assertion(s) failed"):format(fails))
  end
  print("[driver] PASS gold party submenu: STATS, SWITCH and the EGG rules")
end

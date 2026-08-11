-- Two things only a human can see, in one run.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold \
--     POKEPORT_DRIVER=tests/drivers/gold_naming_and_trade_item.lua \
--     perl -e 'alarm 300; exec @ARGV' \
--     python3 -c "import pty; pty.spawn(['love','.'])"
--
-- Only the gold-dev identity has a complete Gold cache; another one is missing
-- data/generated/marts.lua, RomImporter never reports ready, and the driver
-- coroutine is simply never resumed (a silent hang with no output).
--
-- 1. The naming keyboard.  Typing the LAST character does not close the screen:
--    `.a` is `call NamingScreen_TryAddCharacter / ret nc`, and
--    AdvanceCursor_CheckEndOfString answers CARRY once the buffer is full, so
--    the handler falls through into `.start` and parks the cursor on END with
--    the keyboard still up (engine/menus/naming_screen.asm:401-410).  Only
--    `.end` stores the entry.  The blank cells are typeable too: the NameInput*
--    rows are written into the tilemap and GetLastCharacter reads the tile
--    under the cursor back out, so the trailing spaces of "S T U V W X Y Z  "
--    are real characters (data/text/name_input_chars.asm).
--
-- 2. Kyle's Onix (VioletKylesHouse, NPC_TRADE_KYLE) arrives holding
--    BITTER_BERRY.  NPCTRADE_ITEM is an item id BYTE in the table
--    (data/events/npc_trades.asm:15) and DoNPCTrade copies it into
--    wPartyMon1Item; the port names it, so the summary's green page prints
--    BITTER BERRY and TAKE drops a real BITTER BERRY into the bag instead of
--    killing the game in Bag.isBadge.
--
-- Screenshots land in POKEPORT_SHOT_DIR (default /tmp/gold-naming-trade):
--   keyboard-parked-on-end.png  full buffer, cursor bracketing END
--   keyboard-on-blank-cell.png  the cursor sitting on the blank after Z
--   keyboard-typed-a-space.png  a name with a space in the middle of it
--   onix-summary-item.png       the green page's ITEM field
--   onix-item-taken.png         "TOOK BITTER BERRY from ROCKY."
local U = require("tests.drivers.util")

local Mon = require("src.battle.gen2.Mon")
local NpcTrade = require("src.core.gen2.NpcTrade")
local Screens = require("src.ui.Screens")
local SummaryMenu = require("src.ui.gen2.SummaryMenu")

return function(game)
  local out = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-naming-trade"
  local fails = 0
  local function ok(cond, msg)
    if cond then print("[naming] ok   " .. msg)
    else fails = fails + 1 print("[naming] FAIL " .. msg) end
    return cond
  end

  local function tap(btn) U.tap(game, btn) U.wait(3) end
  local function top() return game.stack:top() end

  U.wait(45)
  ok(game.world and game.world.map, "gold world booted")

  -- ---------------------------------------------------------- the keyboard
  local typed
  Screens.push(game, "Gen2NamingScreen", {
    type = "rival",
    menuGfx = game.data.gen2MenuGfx,
    -- The pop is the caller's, exactly as World:nameRival does it.
    onDone = function(name) game.stack:pop() typed = name end,
  })
  U.wait(10)
  local keyboard = top()
  if not ok(keyboard and keyboard.text == "", "the rival keyboard opened") then
    error("gold naming: no keyboard, cannot continue")
  end

  -- Seven A presses on the A key fill a 7-character rival name.
  for _ = 1, keyboard.maxLength do tap("a") end
  ok(top() == keyboard, "a full buffer leaves the keyboard up")
  ok(typed == nil, "and hands nothing back yet")
  ok(keyboard:cursorCharacter() == "END", "the cursor parked itself on END")
  U.shot(game, out .. "/keyboard-parked-on-end.png")

  -- The blank cell after Z types a space.  Back off two characters so the
  -- buffer has room for a space AND a letter after it (a name with a gap in
  -- the middle is the only way to see the space at all), then walk up out of
  -- the bottom row to row 2, column 8.
  tap("b")
  tap("b")
  tap("up")
  tap("up")
  tap("right")
  tap("right")
  ok(keyboard:cursorCharacter() == " ", "the cell after Z is a space")
  U.shot(game, out .. "/keyboard-on-blank-cell.png")
  tap("a")
  ok(keyboard.text:sub(-1) == " ", "and A types it into the name")
  -- Up twice from (8,2) is the I key, so the field ends up reading "AAAAA I".
  tap("up")
  tap("up")
  tap("a")
  ok(keyboard.text == "AAAAA I", "the space really is in the stored name")
  U.shot(game, out .. "/keyboard-typed-a-space.png")

  -- Only A on END ends entry.
  tap("start")
  tap("a")
  ok(typed ~= nil and #typed == keyboard.maxLength,
    "A on END is what stores the entry")
  U.wait(5)

  -- ------------------------------------------------------- Kyle's Onix
  -- data/generated/events.lua, which World loads as its own eventTables.
  local row = NpcTrade.row(game.world.eventTables, 1)
  if not ok(row and row.get == "ONIX", "the cache carries NPC_TRADE_KYLE") then
    error("gold naming: no trade row, cannot continue")
  end
  local save = game.save
  save.party = { Mon.new(game.data, "BELLSPROUT", 12) }
  local _, onix = NpcTrade.perform(game.data, save, row, 1)
  ok(onix and onix.nickname == "ROCKY", "the trade handed ROCKY over")
  ok(onix and onix.item == "BITTER_BERRY",
    "wearing a NAMED BITTER_BERRY, not the table's byte 83")

  -- START > POKeMON > A > STATS, then the green page.
  tap("start")
  local menu = top()
  for _ = 1, 10 do
    if menu.list:current().value == "pokemon" then break end
    tap("down")
  end
  tap("a")
  local party = top()
  if not ok(party and party.screenId == "Gen2PartyMenu",
      "the party list opened") then
    error("gold naming: no party list, cannot continue")
  end
  tap("a")
  tap("a") -- STATS leads the submenu
  local summary = top()
  ok(summary and summary.screenId == "Gen2SummaryMenu", "STATS opened STATS")
  tap("right") -- page 1 (pink) -> page 2 (green), which is the ITEM page
  U.wait(5)
  local placed = summary and summary:placements()
  local text = {}
  for _, p in ipairs(placed or {}) do text[#text + 1] = tostring(p.text or "") end
  ok(table.concat(text, "|"):find("BITTER BERRY", 1, true) ~= nil,
    "the green page prints BITTER BERRY, not 83")
  U.shot(game, out .. "/onix-summary-item.png")
  tap("b")

  -- ITEM > TAKE.  This is the press that used to crash in Bag.isBadge.
  tap("a")
  local submenu = party and party.submenu
  for _ = 1, 8 do
    if submenu and submenu.items[submenu.index]
      and submenu.items[submenu.index].id == "ITEM" then break end
    tap("down")
    submenu = party and party.submenu
  end
  ok(submenu and submenu.items[submenu.index]
    and submenu.items[submenu.index].id == "ITEM", "the cursor found ITEM")
  tap("a")
  local held = top()
  ok(held and held.screenId == "Gen2HeldItemMenu", "GIVE / TAKE opened")
  tap("down")
  tap("a")
  U.wait(5)
  ok(save.party[1].item == nil, "TAKE pulled the berry off")
  ok((save.inventory or {}).BITTER_BERRY == 1, "and it landed in the bag")
  U.shot(game, out .. "/onix-item-taken.png")

  print(("[naming] %d failure(s)"):format(fails))
  love.event.quit()
end

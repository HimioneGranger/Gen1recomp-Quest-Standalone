-- The held-item marker on the party list's mon icons (.SpawnItemIcon,
-- engine/gfx/mon_icons.asm): a mon carrying something swaps its icon's
-- BOTTOM-LEFT tile for HeldItemIcons $09 (gfx/stats/item.2bpp), and one
-- carrying MAIL swaps it for $08 (gfx/stats/mail.2bpp) instead.  Nothing about
-- it is text, so only a screenshot can say whether it is there.
--
-- Slot 1 holds a BERRY, slot 2 holds FLOWER MAIL, slot 3 holds nothing: one
-- shot with all three rows on screen is the whole comparison.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold \
--     POKEPORT_DRIVER=tests/drivers/gold_party_held_item.lua \
--     perl -e 'alarm 300; exec @ARGV' \
--     python3 -c "import pty; pty.spawn(['love','.'])"
--
-- The markers cannot appear until the ROM has been re-imported with a manifest
-- that lists HeldItemIcons: the driver says so out loud rather than leaving a
-- blank shot to be misread.
local U = require("tests.drivers.util")

return function(game)
  local fails = 0
  local function ok(cond, msg)
    if cond then print("[held] ok   " .. msg)
    else fails = fails + 1 print("[held] FAIL " .. msg) end
    return cond
  end

  local function tap(btn) U.tap(game, btn) U.wait(3) end
  local function top() return game.stack:top() end

  U.wait(45)
  ok(game.world and game.world.map, "gold world booted")

  local Mail = require("src.core.gen2.Mail")
  local Mon = require("src.battle.gen2.Mon")
  local save = game.save
  save.party = {
    Mon.new(game.data, "CYNDAQUIL", 12),
    Mon.new(game.data, "TOTODILE", 10),
    Mon.new(game.data, "GEODUDE", 8),
  }
  save.party[1].item = "BERRY"
  -- The letter itself rides sPartyMail, keyed by slot; the icon only reads the
  -- item byte, but a mon holding mail with no struct behind it is not a state
  -- the cart can reach, so write both.
  save.party[2].item = "FLOWER_MAIL"
  Mail.set(save, 2, Mail.entry("FLOWER_MAIL", "HI THERE!",
    save.player and save.player.name or "GOLD",
    save.player and save.player.id or 0, "TOTODILE"))
  ok(Mail.monHoldsMail(save.party[2]), "slot 2 is holding mail")
  ok(save.party[3].item == nil, "slot 3 is holding nothing")

  -- GetIconGFX uploads HeldItemIcons as the two tiles after each icon's eight,
  -- so the marker sheet rides the same cache entry the icons do.
  local icons = game.data.gen2Icons
  local hasMarkers = icons and icons.heldItem and icons.heldItem.image ~= nil
  if hasMarkers then
    print("[held] ok   the cache carries HeldItemIcons: "
      .. tostring(icons.heldItem.image))
  else
    print("[held] NOTE this cache predates the HeldItemIcons extraction, so "
      .. "the icons will be bare.  Re-import the ROM before reading the shot.")
  end

  -- START > POKéMON, the field flavour of the list.
  tap("start")
  local menu = top()
  ok(menu and menu.screenId == "Gen2StartMenu", "START opened the menu")
  for _ = 1, 10 do
    if menu.list:current().value == "pokemon" then break end
    tap("down")
  end
  tap("a")

  local party = top()
  if not ok(party and party.screenId == "Gen2PartyMenu",
      "POKéMON opened the list") then
    error("gold party held item: no party list, cannot continue")
  end

  -- ItemIsMail is what picks between the two tiles; row 0 of the sheet is
  -- mail.2bpp and row 1 is item.2bpp, the order they are INCBIN'd.
  ok(party.heldMarkerRow(save.party[1]) == 1, "the berry asks for tile $09")
  ok(party.heldMarkerRow(save.party[2]) == 0, "the mail asks for tile $08")
  ok(party.heldMarkerRow(save.party[3]) == nil, "the empty hand asks for none")

  -- The cursor sits on row 1, which slides its icon a tile right; wait out a
  -- full frame swap first so the shot catches the icons mid-animation and the
  -- marker can be checked for NOT bobbing with them.
  U.wait(20)
  U.shot(game, (os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-party")
    .. "/held-item-markers.png")
  tap("down")
  U.wait(20)
  U.shot(game, (os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-party")
    .. "/held-item-markers-row2.png")

  tap("b")
  tap("b")

  if fails > 0 then
    error(("gold party held item: %d assertion(s) failed"):format(fails))
  end
  print("[driver] PASS gold party held item: berry, mail and an empty hand")
end

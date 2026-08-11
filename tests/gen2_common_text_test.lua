-- Text no script pointer reaches: the Day-Care and breeding block, the whole
-- POKeMART conversation, and the Hall of Fame's three flavour strings.
--
-- The extractor's text walker only decodes what some `writetext` names, and
-- all three of these blocks are printed by engine asm instead, so they used to
-- exist in the port only as hand transcriptions at their call sites.
-- RomExtractorGen2's NAMED_TEXT seeds the walker at them by symbol and writes
-- text.labels[label] -> the "bank:addr" key the string landed on; the screens
-- read that and keep their transcriptions as the fallback.
--
-- This pins both sides against each other, the way tests/gen2_phone_test.lua
-- pins the phone tables:
--
--   PINNED is the cart's own decoded characters, one entry per label.
--   Every screen is then driven with a text.lua built out of PINNED, and what
--     it says has to equal what its transcription says -- so a transcription
--     that drifts from the ROM fails here rather than on screen.
--   The cache section at the bottom asserts the real import produced exactly
--     these strings, and SKIPs when there is no Gold cache or when the cache
--     predates the seed.
--
-- ROM-free: `luajit tests/gen2_common_text_test.lua`.
package.path = "./?.lua;./?/init.lua;" .. package.path

-- The UI modules require love-side helpers at load time.  Stub the pieces they
-- touch during construction; nothing here draws.
love = love or {}
love.graphics = love.graphics or {
  getColor = function() return 1, 1, 1, 1 end,
  setColor = function() end,
  rectangle = function() end,
  print = function() end,
  printf = function() end,
  draw = function() end,
  newQuad = function() return {} end,
  newImage = function() return nil end,
  getShader = function() return nil end,
  setShader = function() end,
  newShader = function() error("no shaders in this harness") end,
  getDimensions = function() return 160, 144 end,
  push = function() end, pop = function() end,
  translate = function() end, scale = function() end,
  circle = function() end, clear = function() end,
}
love.math = love.math or { random = function(a, b) return b and a or 1 end }
love.image = love.image or {}
love.filesystem = love.filesystem or {
  load = function() return nil end,
  getInfo = function() return nil end,
  read = function() return nil end,
  write = function() return true end,
  remove = function() return true end,
}
love.timer = love.timer or { getTime = function() return 0 end }

local S = require("tests.harness").suite("gen2 common text")
local check, eq = S.check, S.eq

require("src.core.Logger").warn = function() end

local CommonText = require("src.core.gen2.CommonText")
local DayCareMenu = require("src.ui.gen2.DayCareMenu")
local HallOfFame = require("src.ui.gen2.HallOfFame")
local MartMenu = require("src.ui.gen2.MartMenu")

-- The cart's own characters, decoded out of the ROM by the extractor's
-- decodeGen2Text: \n is `line` / `next`, \f is `para`, \v is `cont` (the box
-- scrolls one row), {STRBUF} is a TX_RAM name and {NUM} a TX_DECIMAL field.
-- data/text/common_1.asm and common_2.asm, plus the three `db` strings inside
-- engine/events/halloffame.asm.
local PINNED = {
  ["_DayCareManIntroText"] =
    "I'm the DAY-CARE\nMAN. Want me to\vraise a POKéMON?",
  ["_DayCareManIntroEggText"] =
    "I'm the DAY-CARE\nMAN. Do you know\vabout EGGS?\fI was raising\nPOKéMON with my\vwife, you see.\fWe were shocked to\nfind an EGG!\fHow incredible is\nthat?\fSo, want me to\nraise a POKéMON?",
  ["_DayCareLadyIntroText"] =
    "I'm the DAY-CARE\nLADY.\fShould I raise a\nPOKéMON for you?",
  ["_DayCareLadyIntroEggText"] =
    "I'm the DAY-CARE\nLADY. Do you know\vabout EGGS?\fMy husband and I\nwere raising some\vPOKéMON, you see.\fWe were shocked to\nfind an EGG!\fHow incredible\ncould that be?\fShould I raise a\nPOKéMON for you?",
  ["_WhatShouldIRaiseText"] =
    "What should I\nraise for you?",
  ["_OnlyOneMonText"] =
    "Oh? But you have\njust one POKéMON.",
  ["_CantAcceptEggText"] =
    "Sorry, but I can't\naccept an EGG.",
  ["_RemoveMailText"] =
    "Remove MAIL before\nyou come see me.",
  ["_LastHealthyMonText"] =
    "If you give me\nthat, what will\vyou battle with?",
  ["_IllRaiseYourMonText"] =
    "OK. I'll raise\nyour {STRBUF}.",
  ["_ComeBackLaterText"] =
    "Come back for it\nlater.",
  ["_AreWeGeniusesText"] =
    "Are we geniuses or\nwhat? Want to see\vyour {STRBUF}?",
  ["_YourMonHasGrownText"] =
    "Your {STRBUF}\nhas grown a lot.\fBy level, it's\ngrown by {NUM}.\fIf you want your\nPOKéMON back, it\vwill cost ¥{NUM}.",
  ["_PerfectHeresYourMonText"] =
    "Perfect! Here's\nyour POKéMON.",
  ["_GotBackMonText"] =
    "{PLAYER} got back\n{STRBUF}.",
  ["_BackAlreadyText"] =
    "Huh? Back already?\nYour {STRBUF}\fneeds a little\nmore time with us.\fIf you want your\nPOKéMON back, it\vwill cost ¥100.",
  ["_HaveNoRoomText"] =
    "You have no room\nfor it.",
  ["_NotEnoughMoneyText"] =
    "You don't have\nenough money.",
  ["_OhFineThenText"] =
    "Oh, fine then.",
  ["_ComeAgainText"] =
    "Come again.",
  ["_NotYetText"] =
    "Not yet…",
  ["_FoundAnEggText"] =
    "Ah, it's you!\fWe were raising\nyour POKéMON, and\fmy goodness, were\nwe surprised!\fYour POKéMON had\nan EGG!\fWe don't know how\nit got there, but\fyour POKéMON had\nit. You want it?",
  ["_ReceivedEggText"] =
    "{PLAYER} received\nthe EGG!",
  ["_TakeGoodCareOfEggText"] =
    "Take good care of\nit.",
  ["_IllKeepItThanksText"] =
    "Well then, I'll\nkeep it. Thanks!",
  ["_NoRoomForEggText"] =
    "You have no room\nin your party.\vCome back later.",
  ["_BreedEggHatchText"] =
    "{STRBUF} came\nout of its EGG!",
  ["_BreedAskNicknameText"] =
    "Give a nickname to\n{STRBUF}?",
  ["_LeftWithDayCareManText"] =
    "It's {STRBUF}\nthat was left with\vthe DAY-CARE MAN.",
  ["_LeftWithDayCareLadyText"] =
    "It's {STRBUF}\nthat was left with\vthe DAY-CARE LADY.",
  ["_BreedBrimmingWithEnergyText"] =
    "It's brimming with\nenergy.",
  ["_BreedNoInterestText"] =
    "It has no interest\nin {STRBUF}.",
  ["_BreedAppearsToCareForText"] =
    "It appears to care\nfor {STRBUF}.",
  ["_BreedFriendlyText"] =
    "It's friendly with\n{STRBUF}.",
  ["_BreedShowsInterestText"] =
    "It shows interest\nin {STRBUF}.",
  ["_MartWelcomeText"] =
    "Welcome! How may I\nhelp you?",
  ["_MartAskMoreText"] =
    "Can I do anything\nelse for you?",
  ["_MartComeAgainText"] =
    "Please come again!",
  ["_MartHowManyText"] =
    "How many?",
  ["_MartFinalPriceText"] =
    "{NUM} {STRBUF}(S)\nwill be ¥{NUM}.",
  ["_MartThanksText"] =
    "Here you are.\nThank you!",
  ["_MartNoMoneyText"] =
    "You don't have\nenough money.",
  ["_MartPackFullText"] =
    "You can't carry\nany more items.",
  ["_HerbShopLadyIntroText"] =
    "Hello, dear.\fI sell inexpensive\nherbal medicine.\fThey're good, but\na trifle bitter.\fYour POKéMON may\nnot like them.\fHehehehe…",
  ["_HerbalLadyHowManyText"] =
    "How many?",
  ["_HerbalLadyFinalPriceText"] =
    "{NUM} {STRBUF}(S)\nwill be ¥{NUM}.",
  ["_HerbalLadyThanksText"] =
    "Thank you, dear.\nHehehehe…",
  ["_HerbalLadyPackFullText"] =
    "Oh? Your PACK is\nfull, dear.",
  ["_HerbalLadyNoMoneyText"] =
    "Hehehe… You don't\nhave the money.",
  ["_HerbalLadyComeAgainText"] =
    "Come again, dear.\nHehehehe…",
  ["_BargainShopIntroText"] =
    "Hiya! Care to see\nsome bargains?\fI sell rare items\nthat nobody else\fcarries--but only\none of each item.",
  ["_BargainShopFinalPriceText"] =
    "{STRBUF} costs\n¥{NUM}. Want it?",
  ["_BargainShopThanksText"] =
    "Thanks.",
  ["_BargainShopPackFullText"] =
    "Uh-oh, your PACK\nis chock-full.",
  ["_BargainShopSoldOutText"] =
    "You bought that\nalready. I'm all\vsold out of it.",
  ["_BargainShopNoFundsText"] =
    "Uh-oh, you're\nshort on funds.",
  ["_BargainShopComeAgainText"] =
    "Come by again\nsometime.",
  ["_PharmacyIntroText"] =
    "What's up? Need\nsome medicine?",
  ["_PharmacyHowManyText"] =
    "How many?",
  ["_PharmacyFinalPriceText"] =
    "{NUM} {STRBUF}(S)\nwill cost ¥{NUM}.",
  ["_PharmacyThanksText"] =
    "Thanks much!",
  ["_PharmacyPackFullText"] =
    "You don't have any\nmore space.",
  ["_PharmacyNoMoneyText"] =
    "Huh? That's not\nenough money.",
  ["_PharmacyComeAgainText"] =
    "All right.\nSee you around.",
  ["_NothingToSellText"] =
    "You don't have\nanything to sell.",
  ["_MartSellHowManyText"] =
    "How many?",
  ["_MartSellPriceText"] =
    "I can pay you\n¥{NUM}.\fIs that OK?",
  ["_MartCantBuyText"] =
    "Sorry, I can't buy\nthat from you.",
  ["_MartBoughtText"] =
    "Got ¥{NUM} for\n{STRBUF}(S).",
  ["AnimateHallOfFame.String_NewHallOfFamer"] =
    "New Hall of Famer!",
  ["_HallOfFamePC.TimeFamer"] =
    "    -Time Famer",
  ["_HallOfFamePC.HOFMaster"] =
    "    HOF Master!",
}

-- Text_BreedHuh is the "Huh?" the hatch opens on, and the two empty strings
-- are real: `text_start / done` with nothing between them.  They are seeded
-- too, so a label with no body is still a label the cache has.
PINNED["Text_BreedHuh"] = "Huh?\f"
local EMPTY_LABELS = { "_DaycareDummyText", "_BreedClearboxText" }

-- The transcriptions spell the four-tile POKé compression byte as `#`, which
-- is the same sixteen columns the extractor's expansion draws.
local function norm(s) return (tostring(s):gsub("#", "POKé")) end

-- One eq per page: concatenating the lines compares the line count too.
local function samePages(got, want, what)
  eq(type(got) == "table" and #got or -1, #want, what .. ": page count")
  for i = 1, #want do
    eq(table.concat((got or {})[i] or {}, "|"),
      norm(table.concat(want[i] or {}, "|")), ("%s: page %d"):format(what, i))
  end
end

-- A text.lua shaped like the extractor's output, built out of PINNED so the
-- screens can be driven with it.  The keys are made up (nothing reads an
-- address, only text.labels), which is the whole point of the labels table.
local TEXT = { generation = 2, labels = {} }
do
  local n = 0
  for label, body in pairs(PINNED) do
    n = n + 1
    local key = ("64:%04x"):format(0x4000 + n)
    TEXT.labels[label] = key
    TEXT[key] = body
  end
end

-- ---- CommonText itself ----------------------------------------------------
do
  eq(CommonText.get(TEXT, "_MartHowManyText"), "How many?",
    "a label resolves through text.labels to its string")
  check(CommonText.get(TEXT, "_NoSuchText") == nil, "an unknown label is nil")
  check(CommonText.get({}, "_MartHowManyText") == nil,
    "and so is a cache with no labels table at all")
  check(CommonText.of(nil, "_MartHowManyText") == nil, "as is no text at all")

  -- `line` fills the box's second row, `para` clears it, `cont` scrolls it --
  -- so a cont page opens on the previous page's second line.
  local pages = CommonText.pages("one\ntwo\vthree\ffour")
  eq(#pages, 3, "para and cont each end a page")
  eq(table.concat(pages[1], "|"), "one|two", "line is the second row")
  eq(table.concat(pages[2], "|"), "two|three", "cont scrolls the row up")
  eq(table.concat(pages[3], "|"), "four", "para starts an empty box")
  eq(#CommonText.pages("just one line"), 1, "a bare string is one page")

  -- The markers are consumed in the order they appear, not by kind: the mart
  -- clerk leads with the quantity and the bargain shop with the item name.
  local price = CommonText.of(TEXT, "_MartFinalPriceText", { 2, "POTION", 600 })
  eq(table.concat(price[1], "|"), "2 POTION(S)|will be ¥600.",
    "{NUM} then {STRBUF} then {NUM}")
  local bargain = CommonText.of(TEXT, "_BargainShopFinalPriceText",
    { "POTION", 600 })
  eq(table.concat(bargain[1], "|"), "POTION costs|¥600. Want it?",
    "{STRBUF} then {NUM}")
  local egg = CommonText.of(TEXT, "_ReceivedEggText", { player = "GOLD" })
  eq(table.concat(egg[1], "|"), "GOLD received|the EGG!", "{PLAYER} by name")
  -- A marker with no value left prints nothing, the way the cart's freshly
  -- `@`-filled buffer does.
  local unset = CommonText.of(TEXT, "_IllRaiseYourMonText", {})
  eq(table.concat(unset[1], "|"), "OK. I'll raise|your .",
    "an unfilled marker leaves an empty span")
end

-- ---- the Day-Care ---------------------------------------------------------
--
-- The six entries that take arguments, with the values their markers name.
local DAY_CARE_ARGS = {
  deposit = { "NICK" },
  geniuses = { "NICK" },
  hasGrown = { "NICK", 2, 300 },
  backAlready = { "NICK" },
  gotBack = { "GOLD", "NICK" },
  receivedEgg = { "GOLD" },
}
do
  local screen = DayCareMenu.new(nil,
    { save = { daycare = {} }, side = "man", text = TEXT })
  local seen = 0
  for key, label in pairs(DayCareMenu.LABELS) do
    seen = seen + 1
    check(PINNED[label] ~= nil, label .. " is pinned")
    check(rawget(screen.TEXT, key) ~= nil,
      key .. " comes from the cache, not from the transcription")
    local got, want = screen.TEXT[key], DayCareMenu.TEXT[key]
    if type(want) == "function" then
      local args = DAY_CARE_ARGS[key]
      check(args ~= nil, key .. " has arguments pinned")
      got, want = got(unpack(args)), want(unpack(args))
    end
    samePages(got, want, label)
  end
  eq(seen, 26, "every Day-Care string the screen says is extracted")

  -- With no cache the screen still talks: the transcription is the fallback.
  local bare = DayCareMenu.new(nil, { save = { daycare = {} }, side = "man" })
  eq(bare.TEXT.comeAgain, DayCareMenu.TEXT.comeAgain,
    "and a cache with no labels falls back to the transcription")
end

-- ---- the POKeMART ---------------------------------------------------------
--
-- welcome / askMore / howMany are ONE screenful of lines rather than a list of
-- pages, because a menu sits over them instead of paging them.
local MART_SINGLE = { welcome = true, askMore = true, howMany = true }
local MART_ARGS = { finalPrice = { 2, "POTION", 600 } }
local SELL_ARGS = { price = { 600 }, bought = { "POTION", 600 } }
do
  local seen = 0
  for kind, labels in pairs(MartMenu.LABELS) do
    if kind ~= "SELL" then
      local screen = MartMenu.new(nil,
        { martType = kind, text = TEXT, save = { money = 1000 } })
      for key, label in pairs(labels) do
        seen = seen + 1
        check(PINNED[label] ~= nil, label .. " is pinned")
        check(rawget(screen.text, key) ~= nil,
          ("%s.%s comes from the cache"):format(kind, key))
        local got, want = screen.text[key], MartMenu.TEXTS[kind][key]
        if type(want) == "function" then
          got, want = got(unpack(MART_ARGS[key])), want(unpack(MART_ARGS[key]))
        elseif MART_SINGLE[key] then
          got, want = { got }, { want }
        end
        samePages(got, want, label)
      end
    end
  end

  -- SellMenu's own four, which only MARTTYPE_STANDARD ever reaches.
  local standard = MartMenu.new(nil,
    { martType = "STANDARD", text = TEXT, save = { money = 1000 } })
  local sell = MartMenu.new(nil, { martType = "STANDARD", save = {} })
  for key, label in pairs(MartMenu.LABELS.SELL) do
    seen = seen + 1
    check(PINNED[label] ~= nil, label .. " is pinned")
    check(rawget(standard.sellText, key) ~= nil,
      ("SELL.%s comes from the cache"):format(key))
    local got, want = standard.sellText[key], sell.sellText[key]
    if type(want) == "function" then
      got, want = got(unpack(SELL_ARGS[key])), want(unpack(SELL_ARGS[key]))
    elseif MART_SINGLE[key] then
      got, want = { got }, { want }
    end
    samePages(got, want, label)
  end
  eq(seen, 33, "every clerk line the screen says is extracted")
end

-- ---- the Hall of Fame -----------------------------------------------------
do
  local induct = HallOfFame.headerPlacements("induct", 1, TEXT)
  eq(HallOfFame.at(induct, 1, 2),
    PINNED["AnimateHallOfFame.String_NewHallOfFamer"],
    "the induction header is the cart's own string")
  eq(HallOfFame.at(induct, 1, 2), HallOfFame.NEW_FAMER,
    "and the transcription says the same thing")
  local viewed = HallOfFame.headerPlacements("view", 12, TEXT)
  eq(HallOfFame.at(viewed, 1, 2), PINNED["_HallOfFamePC.TimeFamer"],
    "the PC's header keeps its four leading spaces")
  eq(HallOfFame.at(viewed, 1, 2), HallOfFame.TIME_FAMER, "same transcription")
  -- The count is written OVER those spaces at (2,2), which is why they exist.
  eq(HallOfFame.at(viewed, 2, 2), " 12", "the win count lands on top of them")
  local master = HallOfFame.headerPlacements("view", 100000, TEXT)
  eq(HallOfFame.at(master, 1, 2), PINNED["_HallOfFamePC.HOFMaster"],
    "and the unreachable HOF Master! title is extracted too")
  eq(HallOfFame.at(master, 1, 2), HallOfFame.HOF_MASTER, "same transcription")
  eq(HallOfFame.at(HallOfFame.headerPlacements("induct", 1), 1, 2),
    HallOfFame.NEW_FAMER, "with no cache the constant is the fallback")
end

-- ---- against the cache ----------------------------------------------------
--
-- The strings above were transcribed from the decomp; this is what says the
-- import agrees.  A cache built before the NAMED_TEXT seed has no labels
-- table at all, and needs a re-import rather than a fix here.
do
  local cacheDir = os.getenv("GOLD_CACHE")
  if not cacheDir then
    cacheDir = (os.getenv("HOME") or "") ..
      "/Library/Application Support/LOVE/gold-dev/gold"
  end
  local textFile = loadfile(cacheDir .. "/data/generated/text.lua")
  if not textFile then
    check(true, "no Gold cache (SKIP)")
  else
    local text = textFile()
    if type(text.labels) ~= "table" then
      check(true, "cache predates the NAMED_TEXT seed; re-import (SKIP)")
    else
      local missing, wrong = {}, {}
      for label, want in pairs(PINNED) do
        local key = text.labels[label]
        if not key then
          missing[#missing + 1] = label
        elseif text[key] ~= want then
          wrong[#wrong + 1] = label
        end
      end
      eq(table.concat(missing, ", "), "", "every seeded label is in the cache")
      eq(table.concat(wrong, ", "), "",
        "and every string matches the transcription exactly")
      for _, label in ipairs(EMPTY_LABELS) do
        check(text.labels[label] ~= nil,
          label .. " is seeded even though it is empty")
        eq(text[text.labels[label]], "", label .. " really is empty")
      end
    end
  end
end

S.finish()

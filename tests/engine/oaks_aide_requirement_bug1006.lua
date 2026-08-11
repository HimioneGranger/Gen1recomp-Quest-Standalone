-- Oak's aide quotes the REQUIREMENT, not your current count (#1006).
-- pokered engine/events/oaks_aide.asm .notEnoughOwnedMons.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Data = T.fixtures.load()

-- the ROM-extracted strings the fixture text table does not carry; labels
-- and wording match pokered data/text/text_1.asm
Data.text._OaksAideHiText =
  "Hi! Remember me?\nI'm PROF.OAK's\vAIDE!\fIf you caught " ..
  "{NUM:hOaksAideRequirement, 1, 3}\nkinds of POKéMON,\vI'm supposed to\v" ..
  "give you an\v{RAM:wOaksAideRewardItemName}!\fSo, {PLAYER}! Have\n" ..
  "you caught at\vleast {NUM:hOaksAideRequirement, 1, 3} kinds of\vPOKéMON?"
Data.text._OaksAideUhOhText =
  "Let's see...\nUh-oh! You have\vcaught only " ..
  "{NUM:hOaksAideNumMonsOwned, 1, 3}\vkinds of POKéMON!\fYou need " ..
  "{NUM:hOaksAideRequirement, 1, 3} kinds\nif you want the\v" ..
  "{RAM:wOaksAideRewardItemName}."
Data.text._OaksAideComeBackText =
  "Oh. I see.\fWhen you get {NUM:hOaksAideRequirement, 1, 3}\nkinds, come " ..
  "back\vfor {RAM:wOaksAideRewardItemName}."
Data.text._OaksAideHereYouGoText =
  "Great! You have\ncaught {NUM:hOaksAideNumMonsOwned, 1, 3} kinds \v" ..
  "of POKéMON!\vCongratulations!\fHere you go!"
Data.text._OaksAideGotItemText =
  "{PLAYER} got the\n{RAM:wOaksAideRewardItemName}!"
-- the two rewards this suite drives (Route2Gate / Route11Gate2F pass them
Data.items.HM_FLASH = { id = "HM_FLASH", index = 196, name = "HM FLASH" }
Data.items.ITEMFINDER = { id = "ITEMFINDER", index = 6, name = "ITEMFINDER" }

local SaveData = require("src.core.SaveData")

local pushed = {}
local realTextBox = package.loaded["src.render.TextBox"]
-- story4's push/ask require TextBox lazily, so a package.loaded stub is
package.loaded["src.render.TextBox"] = {
  new = function(_, text, onDone, opts)
    return { text = text, onDone = onDone, opts = opts }
  end,
}

local story4 = dofile("data/scripts/story4.lua")
local ROUTE_11 = story4.ROUTE_11_GATE_2F.talk.TEXT_ROUTE11GATE2F_OAKS_AIDE
local ROUTE_2 = story4.ROUTE_2_GATE.talk.TEXT_ROUTE2GATE_OAKS_AIDE
T.check(type(ROUTE_11) == "function" and type(ROUTE_2) == "function",
  "both aides are wired to the shared oaksAide handler")

local game = {
  data = Data,
  save = SaveData.newGame(),
  stack = { push = function(_, box) pushed[#pushed + 1] = box end },
}

local function reset(ownedCount)
  game.save = SaveData.newGame()
  game.save.player.name = "RED"
  local owned = {}
  for i = 1, ownedCount do owned["SPECIES_" .. i] = true end
  game.save.pokedex = { seen = {}, owned = owned }
  pushed = {}
end
local function lastText()
  return tostring(pushed[#pushed] and pushed[#pushed].text)
end
local function has(fragment)
  return lastText():find(fragment, 1, true) ~= nil
end
local function held(id)
  return game.save.inventory[id] or 0
end
-- A press on the box that is up
local function dismiss()
  local box = pushed[#pushed]
  if box and box.onDone then box.onDone() end
end

-- === the aide asks for his own threshold, whatever the player owns
reset(12)
local done = false
ROUTE_11(game, {}, {}, function() done = true end)
local offer = pushed[1]
T.check(offer.opts and offer.opts.choice ~= nil,
  "the aide's opener is the YesNoChoice question")
T.check(has("least 30 kinds"), "opener asks for the aide's 30 kinds")
T.check(has("give you an\vITEMFINDER"), "opener names the reward item")
T.check(not has("{NUM"), "no placeholder survives into the opener")

-- === YES with too few kinds: both decimals are filled, and differently
offer.opts.choice(true)
T.check(has("caught only 12"), "Uh-oh line reports the kinds actually owned")
T.check(has("You need 30 kinds"), "Uh-oh line then states the requirement")
T.check(not has("You need 12 kinds"),
  "the requirement is not overwritten by the owned count (#1006)")
T.check(has("want the\vITEMFINDER"), "Uh-oh line still names the reward")
dismiss()
T.check(done, "the Uh-oh branch completes the talk")
T.eq(held("ITEMFINDER"), 0, "no reward below the threshold")
T.check(not game.save.flags.EVENT_GOT_ITEMFINDER,
  "the aide can still be asked again")

-- === the threshold tracks the aide, not a constant: Route 2 wants 10
reset(3)
ROUTE_2(game, {}, {}, function() end)
pushed[1].opts.choice(true)
T.check(has("caught only 3"), "Route 2 Uh-oh reports 3 kinds owned")
T.check(has("You need 10 kinds"), "Route 2 states its own 10-kind threshold")
T.check(has("want the\vHM FLASH"), "Route 2 names the HM FLASH reward")

-- === NO: ComeBackText quotes the requirement, nothing is given
reset(12)
done = false
ROUTE_11(game, {}, {}, function() done = true end)
pushed[1].opts.choice(false)
T.check(has("When you get 30"), "come-back line quotes the requirement")
T.check(has("back\vfor ITEMFINDER"), "come-back line names the reward")
dismiss()
T.check(done, "declining completes the talk")
T.eq(held("ITEMFINDER"), 0, "declining gives nothing")

-- === YES at the threshold: HereYouGo carries the OWNED count, then the
reset(30)
done = false
ROUTE_11(game, {}, {}, function() done = true end)
pushed[1].opts.choice(true)
T.check(has("caught 30 kinds"), "congratulation line carries the owned count")
dismiss()
T.check(has("RED got the\nITEMFINDER!"), "the item line names player and item")
dismiss()
T.check(done, "the reward branch completes the talk")
T.eq(held("ITEMFINDER"), 1, "ITEMFINDER lands in the bag")
T.check(game.save.flags.EVENT_GOT_ITEMFINDER, "the aide's event flag is set")

-- === repeat visit: the explanation text, no second ITEMFINDER
pushed = {}
done = false
ROUTE_11(game, {}, {}, function() done = true end)
T.eq(#pushed, 1, "a served player gets exactly one box")
T.check(pushed[1].opts == nil or pushed[1].opts.choice == nil,
  "the repeat line is not a question")
T.eq(held("ITEMFINDER"), 1, "no second ITEMFINDER")

if realTextBox ~= nil then
  package.loaded["src.render.TextBox"] = realTextBox
else
  package.loaded["src.render.TextBox"] = nil
end

T.finish("oaks_aide_requirement_bug1006")

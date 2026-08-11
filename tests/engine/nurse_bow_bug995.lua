-- Nurse Joy bows between the two closing lines (#995).
-- pokered engine/events/pokecenter.asm.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Data = T.fixtures.load()

-- the ROM-extracted strings the fixture text table does not carry
Data.text._PokemonFightingFitText = "Thank you for\nwaiting.\fYour POKéMON are\nfighting fit!"
Data.text._PokemonCenterFarewellText = "We hope to see\nyou again!"

local OW = require("src.world.OverworldController")

local function setUpvalue(fn, name, val)
  local i = 1
  while true do
    local n = debug.getupvalue(fn, i)
    if not n then return false end
    if n == name then debug.setupvalue(fn, i, val); return true end
    i = i + 1
  end
end

local pushed = {}
local stackStub = { push = function(_, item) pushed[#pushed + 1] = item end }
local textBoxStub = {
  new = function(_, text, onDone, opts)
    return { text = text, onDone = onDone, opts = opts }
  end,
}
local fakeGame = { data = Data, stack = stackStub }
T.check(setUpvalue(OW.finishNurseHeal, "TextBox", textBoxStub),
  "TextBox upvalue on finishNurseHeal")
T.check(setUpvalue(OW.finishNurseHeal, "Game", fakeGame),
  "Game upvalue on finishNurseHeal")

local FIT = Data.text._PokemonFightingFitText
local BYE = Data.text._PokemonCenterFarewellText

local player = { cellX = 3, cellY = 5 }
local faced
local function newNurse()
  faced = 0
  return {
    facing = "down",
    facePlayer = function(self) faced = faced + 1; self.facing = "down" end,
  }
end

local fakeSelf
local function reset()
  pushed = {}
  fakeSelf = setmetatable({ player = player }, { __index = OW })
end

-- === with the nurse on the counter: fit line, bow, farewell
reset()
local nurse = newNurse()
local finished = 0
fakeSelf:finishNurseHeal(BYE, function() finished = finished + 1 end, nurse)
T.eq(#pushed, 1, "the fighting-fit line goes up on its own")
T.eq(pushed[1].text, FIT, "first box is exactly the fighting-fit text")
T.check(pushed[1].text:find(BYE, 1, true) == nil,
  "the farewell is no longer merged into it with a page break (#995)")

pushed[1].onDone()
T.eq(#pushed, 1, "the farewell waits for the bow")
T.eq(nurse.facing, "up", "image index $14: the nurse bows")
T.check(fakeSelf.emote ~= nil, "the bow is a world hold, not a text pause")
local hold = fakeSelf.emote or {}
T.eq(hold.npc, nurse, "the hold is anchored on the nurse")
T.eq(hold.frames, 20, "DelayFrames $14 is 20 frames")
T.eq(hold.bubble, false, "no emotion bubble is drawn over her")
T.check(not hold.skippable, "the bow cannot be skipped with A/B")
T.eq(finished, 0, "the pokecenter is still busy during the bow")

-- OverworldState:update counts emote.frames down and then calls onDone
if hold.onDone then hold.onDone() end
T.eq(#pushed, 2, "the farewell follows the bow")
local farewell = pushed[2] or {}
T.eq(farewell.text, BYE, "second box is the farewell text")
T.eq(nurse.facing, "up", "she is still bowed while the farewell prints")

if farewell.onDone then farewell.onDone() end
T.eq(nurse.facing, "down", "the trailing UpdateSprites faces her back")
T.eq(faced, 1, "she is turned back exactly once")
T.eq(finished, 1, "control returns to the player once, after the farewell")

-- === no nurse sprite (the Yellow/rest-stop callers): no bow, same text
reset()
finished = 0
fakeSelf:finishNurseHeal(BYE, function() finished = finished + 1 end)
T.eq(pushed[1].text, FIT, "npc-less caller still opens with the fit line")
pushed[1].onDone()
T.check(fakeSelf.emote == nil, "nothing to bow, so no world hold")
T.eq(#pushed, 2, "the farewell follows immediately")
farewell = pushed[2] or {}
T.eq(farewell.text, BYE, "npc-less caller still closes with the farewell")
if farewell.onDone then farewell.onDone() end
T.eq(finished, 1, "npc-less caller returns control once")

T.finish("nurse_bow_bug995")

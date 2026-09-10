-- The Yellow Pewter rest scene must route its engine-authored fallback
-- through the translation catalog for both interaction entry points.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Strings = require("src.core.Strings")
local OW = require("src.world.OverworldController")

local function setUpvalue(fn, name, value)
  local i = 1
  while true do
    local found = debug.getupvalue(fn, i)
    if not found then return false end
    if found == name then
      debug.setupvalue(fn, i, value)
      return true
    end
    i = i + 1
  end
end

local pushed = {}
local textBoxStub = {
  new = function(_, text, onDone)
    return { text = text, onDone = onDone }
  end,
}
local game = {
  data = { text = {} },
  stack = { push = function(_, box) pushed[#pushed + 1] = box end },
}

for _, method in ipairs({ "nurseHeal", "cableClubReceptionist" }) do
  T.check(setUpvalue(OW[method], "Game", game), method .. " Game upvalue")
  T.check(setUpvalue(OW[method], "TextBox", textBoxStub),
    method .. " TextBox upvalue")
end

local source = "PIKACHU looks\ncontent."
local translated = "PIKACHU is\ncontent!"
Strings.load({ strings = { [source] = translated } })

local state = setmetatable({
  map = { id = "PEWTER_POKECENTER" },
  pikachuPewterSleepScene = true,
}, { __index = OW })

local completed = 0
local function done() completed = completed + 1 end
state:nurseHeal(done)
state:cableClubReceptionist(done)

T.eq(#pushed, 2, "both Pewter rest-scene interaction paths show one box")
T.eq(pushed[1].text, translated,
  "nurse path translates the engine-authored content fallback")
T.eq(pushed[2].text, translated,
  "cable receptionist path translates the same fallback")
T.check(pushed[1].onDone == done and pushed[2].onDone == done,
  "both short paths preserve their completion callback")

pushed[1].onDone()
pushed[2].onDone()
T.eq(completed, 2, "each interaction returns control exactly once")

Strings.load(nil)
T.finish("Pewter Pikachu content translation")

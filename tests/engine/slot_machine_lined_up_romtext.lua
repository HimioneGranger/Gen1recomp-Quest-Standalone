-- SlotMachine:resolveWin's lined-up message must use the ROM text catalog.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Data = T.fixtures.fresh()
local SlotMachine = require("src.ui.SlotMachine")

local function mkSelf()
  local game = { data = Data, save = { coins = 0 } }
  return setmetatable({ game = game, allowMatchesCounter = 0 }, SlotMachine)
end

do
  local self = mkSelf()
  Data.text._LinedUpText = " FAKE-SUFFIX {RAM:wStringBuffer}!"
  self:resolveWin({ symbol = "CHERRY", payout = 8 })
  T.eq(self.message, "CHERRY FAKE-SUFFIX 8!",
    "a translated _LinedUpText reaches the lined-up message")
  Data.text._LinedUpText = nil
end

do
  local self = mkSelf()
  self:resolveWin({ symbol = "CHERRY", payout = 8 })
  T.eq(self.message, "CHERRY lined up!\nScored 8 coins!",
    "no catalog entry keeps the English fallback")
end

T.finish("slot_machine_lined_up_romtext")

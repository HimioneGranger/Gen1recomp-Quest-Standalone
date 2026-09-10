-- Public mod-API coverage for the "item.use" hook (src/ui/BagMenu.lua).
--
-- Before this hook existed, every result ItemEffects.use returned fell
-- through to one unconditional call with nothing wrapped around it: a mod
-- could not suppress a message, delay it behind a screen of its own, or
-- replace what a specific item id does after the bag decides to use it.
-- This exercises the seam end to end through the public mod API -- a real
-- BagMenu list, a real USE selection -- rather than calling the hook
-- machinery directly.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Bag = require("src.inventory.Bag")

-- Real TextBoxes want a Font atlas; this only cares that useOn reaches the
-- no-effect fallthrough, so the same stand-in tests/parity_rare_candy_menu.lua
-- uses for a ROM-backed run works here too.
local realTextBox = package.loaded["src.render.TextBox"]
package.loaded["src.render.TextBox"] = {
  new = function(_, text, done) return { textBox = true, text = text, done = done } end,
}
package.loaded["src.ui.BagMenu"] = nil
local BagMenu = require("src.ui.BagMenu")

local FIXTURE = {
  ["mods/item_hook_probe/manifest.json"] = [[{
    "id": "item_hook_probe",
    "name": "Item Hook Probe",
    "version": "1.0.0",
    "entry": "main.lua",
    "api": 2
  }]],
  ["mods/item_hook_probe/main.lua"] = [[
    local mod = ...
    mod.hooks:wrap("item.use",
      function(vanilla, game, battle, id, target, list, moveIndex, picker)
        mod.exports.calls = (mod.exports.calls or 0) + 1
        mod.exports.id = id
        mod.exports.battle = battle
        mod.exports.target = target
        return vanilla(game, battle, id, target, list, moveIndex, picker)
      end)
  ]],
}

local function newStack()
  local stack = { states = {} }
  function stack:push(s) self.states[#self.states + 1] = s end
  function stack:pop() return table.remove(self.states) end
  function stack:top() return self.states[#self.states] end
  return stack
end

local run = T.sdk.loadMods({ "mods/item_hook_probe" }, {
  fs = T.sdk.memfs(FIXTURE),
})
T.eq(#run.errors, 0,
  "the probe mod loads clean (" .. tostring(run.errors[1]) .. ")")

local game = {
  data = run.data,
  stack = newStack(),
  save = {
    player = { name = "RED" }, inventory = {}, money = 0,
    options = { battleStyle = "set", battleAnim = "on" },
    pokedex = { seen = {}, owned = {} }, flags = {},
  },
}
Bag.add(game.save, "FIX_POTION", 1)

local list = BagMenu.new(game, {})
game.stack:push(list)
local row
for i, r in ipairs(list.items) do
  if r.value == "FIX_POTION" then row = i end
end
T.check(row ~= nil, "the fixture item is in the bag")
list.index = row
list.onChoose(list.items[row], list)

-- out of battle the bag offers USE / TOSS first (start_sub_menus.asm)
local sub = game.stack:top()
T.check(sub ~= nil and sub.items and sub.items[1] and sub.items[1].onSelect,
  "the USE/TOSS submenu opened")
sub.items[1].onSelect()

local out = run.loader.exports.item_hook_probe or {}
T.eq(out.calls, 1, "the hook fires exactly once for a bag item use")
T.eq(out.id, "FIX_POTION", "the hook sees the item id")
T.eq(out.battle, nil, "the hook sees the field-use battle argument (nil)")

local top = game.stack:top()
T.check(type(top) == "table" and top.textBox == true,
  "vanilla still ran: the no-effect message box landed on the stack")

run.release()
package.loaded["src.render.TextBox"] = realTextBox
package.loaded["src.ui.BagMenu"] = nil

T.finish()

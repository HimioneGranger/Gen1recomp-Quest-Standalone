-- Shop price confirmations must use imported ROM text when it is present.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Data = T.fixtures.fresh()
local ShopMenu = require("src.ui.ShopMenu")

local itemId = "FIX_POTION"
local item = Data.items[itemId]
local pushed = {}
local game = {
  data = Data,
  save = { money = item.price * 10, inventory = {}, inventoryOrder = {} },
  stack = {
    push = function(_, state) pushed[#pushed + 1] = state end,
    pop = function() end,
  },
}

local function buyFooter()
  pushed = {}
  local menu = ShopMenu.new(game, { itemId })
  menu.items[1].onSelect()
  local list = pushed[#pushed]
  list.onChoose(list.items[1])
  pushed[#pushed].onDone(2)
  return list.footer
end

local function sellFooter()
  pushed = {}
  game.save.inventory[itemId] = 2
  game.save.inventoryOrder = { itemId }
  local menu = ShopMenu.new(game, { itemId })
  menu.items[2].onSelect()
  local list = pushed[#pushed]
  list.onChoose(list.items[1])
  pushed[#pushed].onDone(2)
  return list.footer
end

Data.text._PokemartTellBuyPriceText = "BUY {ITEM} FOR {PRICE}?"
T.eq(buyFooter(), "BUY " .. item.name .. " FOR " .. (item.price * 2) .. "?",
  "buy confirmation uses imported ROM text")
Data.text._PokemartTellBuyPriceText = nil
T.eq(buyFooter(), item.name .. "?\nThat will be\n¥" .. (item.price * 2) .. ". OK?",
  "buy confirmation keeps the English fallback")

Data.text._PokemartTellSellPriceText = "SELL FOR {PRICE}?"
T.eq(sellFooter(), "SELL FOR " .. item.price .. "?",
  "sell confirmation uses imported ROM text")
Data.text._PokemartTellSellPriceText = nil
T.eq(sellFooter(), "I can pay you\n¥" .. item.price .. " for that.",
  "sell confirmation keeps the English fallback")

T.finish("shop price ROM text")

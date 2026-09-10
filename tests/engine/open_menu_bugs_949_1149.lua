package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local GenSave = require("src.save_convert.GenSave")
local romText = require("src.core.RomText")

local localized = {
  text = {
    _MoveIsDisabledText = "The move {RAM:wNameBuffer} from {USER} is disabled!",
  },
}
T.eq(romText(localized, "_MoveIsDisabledText", "%s's %s is disabled!", {
  USER = "PIKACHU", ["RAM:wNameBuffer"] = "THUNDER",
}), "The move THUNDER from PIKACHU is disabled!",
  "named ROM tokens survive translation reordering")

GenSave.setCharmap(loadfile("src/save_convert/data/charmap.lua")())
local data = {
  pokemon = {}, moves = {}, items = {}, maps = {},
  hiddenItems = loadfile("src/save_convert/data/hidden_items.lua")(),
}
local save = {
  player = { name = "RED", id = 1, map = "PALLET_TOWN", x = 0, y = 0 },
  rival = { name = "BLUE" }, party = {}, boxes = {}, inventory = {},
  pcItems = {}, flags = {}, pokedex = { seen = {}, owned = {} },
  hiddenTaken = {
    VIRIDIAN_FOREST_1_18 = true,
    VIRIDIAN_CITY_14_4 = true,
  },
}
for i = 1, 12 do save.boxes[i] = {} end
local bytes = GenSave.encode(save, data, nil)
local decoded = GenSave.decode(bytes, data)
T.check(decoded.hiddenTaken.VIRIDIAN_FOREST_1_18,
  "Viridian Forest hidden potion imports from wObtainedHiddenItemsFlags")
T.check(decoded.hiddenTaken.VIRIDIAN_CITY_14_4,
  "Viridian City hidden potion imports from wObtainedHiddenItemsFlags")
T.check(not decoded.hiddenTaken.ROUTE_9_14_7,
  "an uncollected hidden item remains available")

love = love or require("tests.love_stub")
local start = require("src.ui.StartMenu").new({
  data = {}, save = {
    flags = {}, party = {}, inventory = {}, options = {},
    player = { name = "RED" }, pokedex = { owned = {} },
  },
})
local pokemonRow
for _, row in ipairs(start.items) do
  if row.label == "POKéMON" then pokemonRow = row break end
end
T.check(pokemonRow and pokemonRow.keepOpen,
  "the empty-party POKéMON row leaves the start menu open")

T.finish("open menu bugs 949 and 1149")

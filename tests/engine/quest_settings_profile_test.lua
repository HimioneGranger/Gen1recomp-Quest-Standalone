-- Quest Standalone must not show controls that only affect a flat Android or
-- desktop display. Other renderer and gameplay controls remain available.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local check = T.check
love = love or require("tests.love_stub")

local realGetOS = love.system.getOS
love.system.getOS = function() return "Android" end

local function labels(model)
  local out = {}
  for _, section in ipairs(model.sections) do
    for _, row in ipairs(section.rows) do out[row.label] = true end
  end
  return out
end

local LauncherSettings = require("src.import.LauncherSettings")
local SaveData = require("src.core.SaveData")
local PaletteFX = require("src.render.PaletteFX")
local defaults = SaveData.defaultOptions()
check(defaults.colors == "redpp", "Quest core default uses Advanced colors")
check(PaletteFX.modeLabel(defaults.colors) == "ADVANCED",
  "Advanced default shows its user-facing label")
local launcher = labels(LauncherSettings.open(nil, "red"))
check(not launcher["VIDEO MODE"], "Quest launcher hides VIDEO MODE")
check(not launcher["ORIENTATION"], "Quest launcher hides ORIENTATION")
check(not launcher["TOUCH PAD"], "Quest launcher hides TOUCH PAD")
check(not launcher["VIBRATION"], "Quest launcher hides VIBRATION")
check(launcher["COLORS"], "Quest launcher keeps COLORS")
check(launcher["PERFORMANCE"], "Quest launcher keeps PERFORMANCE")

local OptionsMenu = require("src.ui.OptionsMenu")
local inGame = OptionsMenu.new({ save = { options = {} }, data = { audio = {} } })
local rows = {}
for _, row in ipairs(inGame.rows) do rows[row.id] = true end
check(not rows.videoMode, "Quest in-game menu hides VIDEO MODE")
check(not rows.orientation, "Quest in-game menu hides ORIENTATION")
check(not rows.touchControls, "Quest in-game menu hides TOUCH PAD")
check(not rows.haptics, "Quest in-game menu hides VIBRATION")
check(rows.colors, "Quest in-game menu keeps COLORS")
check(rows.performance, "Quest in-game menu keeps PERFORMANCE")

local function read(path)
  local file = assert(io.open(path, "rb"))
  local text = assert(file:read("*a"))
  file:close()
  return text
end
check(read("src/core/SaveData.lua"):find('colors = "redpp"', 1, true),
  "new Quest saves default to Advanced colors")
check(read("src/save_convert/SaveConvert.lua"):find('colors = "redpp"', 1, true),
  "ROM imports default to Advanced colors")

love.system.getOS = realGetOS
T.finish("quest settings profile")

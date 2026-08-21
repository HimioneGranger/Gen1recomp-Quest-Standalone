-- Quest Standalone must not show controls that only affect a flat Android or
-- desktop display. Other renderer and gameplay controls remain available.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local check = T.check
love = love or require("tests.love_stub")

local realGetOS = love.system.getOS
love.system.getOS = function() return "Android" end
local realGetenv = os.getenv
os.getenv = function(name)
  if name == "POKEPORT_QUEST_PROFILE" then return "1" end
  return realGetenv(name)
end
local realQuestPanel = rawget(_G, "QUEST_PANEL_ACTIVE")
_G.QUEST_PANEL_ACTIVE = nil

local function labels(model)
  local out = {}
  for _, section in ipairs(model.sections) do
    for _, row in ipairs(section.rows) do out[row.label] = true end
  end
  return out
end

local PlatformProfile = require("src.core.PlatformProfile")
check(PlatformProfile.isQuestStandalone(),
  "Quest flavor selects its profile without the panel FFI backend")
check(not PlatformProfile.optionRowSupported({ key = "t_shift", label = "T-SHIFT" }),
  "Quest hides the inactive T-shift row")
check(not PlatformProfile.optionRowSupported({ key = "v_curved", label = "V CURVED" }),
  "Quest hides the inactive V Curved row")
check(not PlatformProfile.optionRowSupported({ key = "v_curve", label = "V-CURVE" }),
  "Quest hides the captured inactive V-Curve row")
check(not PlatformProfile.optionRowSupported({ id = "legacy", label = "T-SHIFT" }),
  "Quest checks the inactive label when an unrelated id is present")
check(PlatformProfile.optionRowSupported({ key = "render_distance", label = "DISTANCE" }),
  "Quest retains a supported mod option")
local preserved = { id = "legacy", key = "v_curve", label = "V-CURVE", value = true }
check(not PlatformProfile.optionRowSupported(preserved) and preserved.value == true,
  "Quest filtering preserves the saved V-Curve value")
for _, row in ipairs({
  { key = "tshift", label = "T SHIFT" },
  { key = "t_shift", label = "T-SHIFT" },
  { key = "vcurve", label = "V CURVE" },
  { key = "v_curve", label = "V-CURVE" },
  { key = "v_curved", label = "V CURVED" },
}) do
  check(not PlatformProfile.optionRowSupported(row),
    "Quest hides inactive schema variant: " .. row.key)
end

local ManagerState = require("src.mods.ManagerState")
local managerOptions = {
  modOptions = { DRAMALESS_SHAPE = {
    tshift = true, v_curve = false, active_quest_control = 7,
  } },
}
local manager = ManagerState.new({
  save = { options = managerOptions },
  mods = { modOptions = managerOptions.modOptions },
})
local managerRows = manager:buildOptionRows({ id = "DRAMALESS_SHAPE" }, {
  { key = "tshift", label = "T-SHIFT", type = "toggle", default = false },
  { key = "v_curve", label = "V-CURVE", type = "toggle", default = true },
  { key = "active_quest_control", label = "QUEST SCALE", type = "number",
    default = 5, min = 1, max = 10, step = 1 },
})
local managerIds = {}
for _, row in ipairs(managerRows) do managerIds[row.id] = true end
check(not managerIds.tshift and not managerIds.v_curve
    and managerIds.active_quest_control and managerIds.__reset,
  "Quest mod manager hides only flat-display rows and keeps active controls")
check(managerOptions.modOptions.DRAMALESS_SHAPE.tshift == true
    and managerOptions.modOptions.DRAMALESS_SHAPE.v_curve == false,
  "mod manager filtering keeps hidden saved values byte-for-byte equivalent")

for _, path in ipairs({
  "src/import/LauncherSettings.lua",
  "src/ui/OptionsMenu.lua",
  "src/ui/gen2/OptionsMenu.lua",
  "src/mods/ManagerState.lua",
}) do
  local file = assert(io.open(path, "rb"))
  local source = assert(file:read("*a"))
  file:close()
  check(source:find("optionRowSupported", 1, true),
    "Quest row filter is active at menu consumer: " .. path)
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
for _, label in ipairs({
  "TEXT SPEED", "BATTLE ANIMATION", "BATTLE STYLE", "BATTLE LAYOUT",
  "BATTLE SIZE", "BATTLE BG", "UI LAYOUT", "MUSIC VOL", "SFX VOL",
  "MUSIC FILTER", "TILT", "VOID FILL", "FAITHFUL RATIO", "MAX FPS",
  "OVERWORLD SPEED", "BATTLE SPEED", "MENU SPEED", "RESET REBINDS",
}) do
  check(launcher[label], "Quest launcher keeps supported row: " .. label)
end

local launcherColors
for _, section in ipairs(LauncherSettings.open(nil, "red").sections) do
  for _, row in ipairs(section.rows) do
    if row.label == "COLORS" then launcherColors = row end
  end
end
check(launcherColors and launcherColors.value() == "ADVANCED",
  "missing launcher color option reads as Advanced")

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
for _, id in ipairs({
  "textSpeed", "animations", "battleStyle", "battleLayout", "battleFit",
  "battleBg", "uiLayout", "ruleset", "musicVol", "sfxVol", "musicFilter",
  "tilt", "zoom", "voidFill", "faithfulRes", "fpsCap", "speedOverworld",
  "speedBattle", "speedMenu", "mods", "controls", "dateFormat", "timeFormat",
}) do
  check(rows[id], "Quest in-game menu keeps supported row: " .. id)
end
local inGameColors
for _, row in ipairs(inGame.rows) do
  if row.id == "colors" then inGameColors = row end
end
check(inGameColors and inGameColors.value(inGame.game) == "ADVANCED",
  "missing in-game color option reads as Advanced")

local TouchControls = require("src.core.TouchControls")
TouchControls:init()
check(not TouchControls.active,
  "Quest flavor disables touch overlay without the panel FFI backend")

local yellowSource
do
  local file = assert(io.open("src/ui/YellowIntro.lua", "rb"))
  yellowSource = assert(file:read("*a"))
  file:close()
end
check(yellowSource:find("self.questLetterboxWhite = self.letterboxWhite", 1, true),
  "Quest Yellow Intro opts into the paper side fill")
local function read(path)
  local file = assert(io.open(path, "rb"))
  local text = assert(file:read("*a"))
  file:close()
  return text
end
check(read("src/ui/TitleState.lua"):find(
  "self.questLetterboxWhite = self.letterboxWhite", 1, true),
  "Quest Red Blue Yellow titles opt into the paper side fill")
check(read("src/core/SaveData.lua"):find('colors = "redpp"', 1, true),
  "new Quest saves default to Advanced colors")
check(read("src/save_convert/SaveConvert.lua"):find('colors = "redpp"', 1, true),
  "ROM imports default to Advanced colors")
check(read("src/render/PaletteFX.lua"):find('PaletteFX.mode = "redpp"', 1, true),
  "palette runtime starts at Advanced")
check(read("src/render/Renderer.lua"):find("state.questLetterboxWhite or not FaithfulRes.scaleCap()", 1, true),
  "Quest intro paper fill overrides flat-mobile letterbox black")
for _, path in ipairs({
  "src/ui/IntroMovie.lua",
  "src/ui/OakSpeech.lua",
  "src/ui/gen2/CopyrightSplash.lua",
  "src/ui/gen2/GameFreakPresents.lua",
  "src/ui/gen2/GoldSilverIntro.lua",
  "src/ui/gen2/OakSpeech.lua",
}) do
  check(read(path):find("questLetterboxWhite", 1, true),
    "Quest opening state opts into the paper side fill: " .. path)
end

love.system.getOS = realGetOS
os.getenv = function(name)
  if name == "POKEPORT_QUEST_PROFILE" then return nil end
  return realGetenv(name)
end
_G.QUEST_PANEL_ACTIVE = nil
check(not PlatformProfile.isQuestStandalone(),
  "generic Android remains outside the Quest profile")
_G.QUEST_PANEL_ACTIVE = true
check(PlatformProfile.isQuestStandalone(),
  "legacy panel signal remains a compatibility fallback")
os.getenv = realGetenv
_G.QUEST_PANEL_ACTIVE = realQuestPanel
T.finish("quest settings profile")

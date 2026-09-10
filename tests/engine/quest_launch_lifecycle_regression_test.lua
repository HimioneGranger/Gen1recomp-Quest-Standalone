-- One Play action owns one branded loading interval and one game handoff.
-- Self-contained: luajit tests/engine/quest_launch_lifecycle_regression_test.lua
package.path = "./?.lua;./?/init.lua;" .. package.path
if not _G.love then _G.love = require("tests.love_stub") end

local T = require("tests.harness")
local SaveData = require("src.core.SaveData")
local oldLoadOptions, oldSaveOptions = SaveData.loadOptions, SaveData.saveOptions
local oldGetenv = os.getenv
local saved = { marker = "preserve", modOptions = {
  DRAMALESS_SHAPE = { t_shift = true, v_curve = false },
} }
SaveData.loadOptions = function() return saved end
SaveData.saveOptions = function(value) T.eq(value, saved, "Play preserves options identity") end
os.getenv = function(name)
  if name == "POKEPORT_QUEST_PROFILE" then return "1" end
  return oldGetenv(name)
end

local completions = 0
local RomImporter = require("src.import.RomImporter")
local importer = RomImporter.new(function(version)
  completions = completions + 1
  T.eq(version, "yellow", "the selected game owns the handoff")
end, { launcher = true })
importer.ready.yellow = true

importer:play("yellow")
local loading = importer._questLaunch
T.check(loading ~= nil, "Play starts one branded loading interval")
importer:play("yellow")
T.eq(importer._questLaunch, loading,
  "a repeated Play action cannot start a second loading interval")
T.eq(completions, 0, "the game does not start before loading completes")

importer:update(1)
T.eq(importer._questLaunch, nil, "the completed loading interval is retired")
T.eq(completions, 1, "loading completion hands off exactly once")
importer:update(1)
T.eq(completions, 1, "later updates cannot repeat the game handoff")
T.eq(saved.marker, "preserve", "unrelated saved data remains unchanged")
T.eq(saved.modOptions.DRAMALESS_SHAPE.t_shift, true,
  "hidden T-shift value remains saved")
T.eq(saved.modOptions.DRAMALESS_SHAPE.v_curve, false,
  "hidden V-Curve value remains saved")

SaveData.loadOptions, SaveData.saveOptions = oldLoadOptions, oldSaveOptions
os.getenv = oldGetenv
T.finish("Quest launch lifecycle regression")

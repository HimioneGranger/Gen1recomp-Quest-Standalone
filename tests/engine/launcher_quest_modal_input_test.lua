-- Quest launcher modal input routing.
-- The experimental-mod dialogs are guarded inside RomImporter:keypressed;
-- Quest focus/confirm must reach LauncherView before that guard returns.
--   luajit tests/engine/launcher_quest_modal_input_test.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local check, eq = T.check, T.eq
love = love or require("tests.love_stub")

local RomImporter = require("src.import.RomImporter")
local viewName = "src.import.LauncherView"
local realView = package.loaded[viewName]
local calls = {}

package.loaded[viewName] = {
  keypressed = function(imp, key)
    calls[#calls + 1] = key
    if key == "return" then
      imp.activated = true
      return true
    end
    if key == "left" or key == "right" or key == "up" or key == "down" then
      imp.navigated = key
      return true
    end
    return false
  end,
}

local function importer(field)
  return setmetatable({ _flex = true, [field] = {} }, RomImporter)
end

local modalFields = {
  "_modConfirm", "_modVersions", "_modReleaseNotes", "_findDetails",
}

_G.QUEST_PANEL_ACTIVE = true
for _, field in ipairs(modalFields) do
  local imp = importer(field)
  imp:keypressed("return")
  check(imp.activated, "Quest confirm reaches focused " .. field .. " control")
  eq(calls[#calls], "return", "Quest confirm is forwarded as return")

  imp = importer(field)
  imp:keypressed("right")
  eq(imp.navigated, "right", "Quest navigation reaches " .. field)
end

-- Back remains owned by RomImporter so each overlay closes using its existing
-- precedence. LauncherView declines Escape in both the real and test paths.
do
  local imp = importer("_findDetails")
  imp:keypressed("escape")
  eq(imp._findDetails, nil, "Quest Escape closes details")
end
do
  local imp = importer("_modReleaseNotes")
  imp:keypressed("escape")
  eq(imp._modReleaseNotes, nil, "Quest Escape closes release notes")
end
do
  local imp = importer("_modVersions")
  imp._modConfirm = {}
  imp:keypressed("escape")
  eq(imp._modConfirm, nil, "Quest Escape closes confirm first")
  eq(imp._modVersions, nil, "Quest Escape also clears versions behind confirm")
end

-- Desktop keeps its legacy modal behavior; this Quest-only bridge must not
-- turn an unarmed Enter into an action on another platform.
_G.QUEST_PANEL_ACTIVE = nil
do
  local before = #calls
  local imp = importer("_modConfirm")
  imp:keypressed("return")
  check(not imp.activated, "desktop modal Enter is not routed by Quest bridge")
  eq(#calls, before, "desktop modal did not call LauncherView")
  check(imp._modConfirm ~= nil, "desktop modal stays open on unhandled Enter")
  imp:keypressed("escape")
  eq(imp._modConfirm, nil, "desktop Escape behavior is preserved")
end

package.loaded[viewName] = realView
_G.QUEST_PANEL_ACTIVE = nil

T.finish("launcher Quest modal input")

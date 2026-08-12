-- Launcher modal focus routing. The immediate-mode focus ring is shared by
-- the main launcher and its mod dialogs, so arrows and an armed confirmation
-- must be handled before the modal key guard returns.
--   luajit tests/engine/launcher_modal_focus_input_test.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local check, eq = T.check, T.eq
love = love or require("tests.love_stub")

local Kit = require("src.ui.kit.Kit")
local RomImporter = require("src.import.RomImporter")

local function resetFocus()
  Kit.focusId = "modal-primary"
  Kit._navQueue = nil
  Kit._activateId = nil
end

local function importer(field)
  return setmetatable({ _flex = true, [field] = {} }, RomImporter)
end

local modalFields = {
  "_modConfirm", "_modVersions", "_modReleaseNotes", "_findDetails",
}

for _, field in ipairs(modalFields) do
  resetFocus()
  local imp = importer(field)
  imp:keypressed("right")
  eq(Kit._navQueue, "right", field .. " accepts focus navigation")
  check(imp._ringArmed, field .. " navigation arms the focus ring")

  imp:keypressed("return")
  eq(Kit._activateId, "modal-primary",
    field .. " activates the focused modal control")
  check(imp[field] ~= nil, field .. " remains open until its button dispatches")
end

-- Enter without prior focus navigation must not invent an activation. This is
-- the vanilla compatibility contract behind the launcher's legacy Enter-to-
-- play shortcut; a modal simply absorbs that otherwise-unhandled key.
do
  resetFocus()
  local imp = importer("_modConfirm")
  imp:keypressed("return")
  eq(Kit._activateId, nil, "unarmed modal Enter does not activate focus")
  check(not imp._ringArmed, "unarmed modal Enter does not arm focus")
end

-- A focused text field remains exclusive. The modal fix must not move the
-- ring when an arrow is intended for a launcher text-input state.
do
  resetFocus()
  local imp = setmetatable({
    _flex = true,
    _findSearchFocus = true,
    findQuery = "PIKA",
  }, RomImporter)
  imp:keypressed("right")
  eq(Kit._navQueue, nil, "focused search field does not navigate the ring")
  check(not imp._ringArmed, "focused search field does not arm the ring")
end

-- Escape remains owned by the existing modal close path.
do
  resetFocus()
  local imp = importer("_findDetails")
  imp:keypressed("escape")
  eq(imp._findDetails, nil, "Escape closes details")
end
do
  resetFocus()
  local imp = importer("_modReleaseNotes")
  imp:keypressed("escape")
  eq(imp._modReleaseNotes, nil, "Escape closes release notes")
end
do
  resetFocus()
  local imp = importer("_modVersions")
  imp._modConfirm = {}
  imp:keypressed("escape")
  eq(imp._modConfirm, nil, "Escape closes confirmation")
  eq(imp._modVersions, nil, "Escape clears versions behind confirmation")
end

resetFocus()
T.finish("launcher modal focus input")

-- Quest launcher controller focus must be painted into the captured surface.
-- Native right-stick input bypasses LauncherView.keypressed, so _ringArmed is
-- false even after the focus target moves.
--   luajit tests/engine/launcher_quest_focus_cursor_test.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local check = T.check
love = love or require("tests.love_stub")
local LauncherView = require("src.import.LauncherView")

_G.QUEST_PANEL_ACTIVE = true
local quest = { _ringArmed = false }
check(LauncherView._showFocusCursor(quest, nil),
  "Quest paints a visible cursor without keyboard ring arming")
check(not LauncherView._showFocusCursor(quest, {}),
  "the blocking loader suppresses the Quest cursor")

_G.QUEST_PANEL_ACTIVE = nil
local desktop = { _ringArmed = false }
check(not LauncherView._showFocusCursor(desktop, nil),
  "unarmed desktop launcher does not gain a permanent cursor")

desktop._ringArmed = true
check(LauncherView._showFocusCursor(desktop, nil),
  "armed desktop keyboard navigation keeps its cursor")

_G.QUEST_PANEL_ACTIVE = nil

T.finish("launcher Quest focus cursor")

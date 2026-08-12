-- Quest's packaged display adapter is transport-only and rate-limits native
-- capture without changing the generic HostDisplay contract.
-- Self-contained: luajit tests/engine/quest_openxr_display_test.lua
package.path = "./?.lua;./?/init.lua;" .. package.path
if not _G.love then _G.love = require("tests.love_stub") end

local T = require("tests.harness")
local check, eq = T.check, T.eq
local Provider = require("src.host.android.QuestOpenXRDisplay")

local captures = {}
local native = {
  questxr_capture_panel_gl = function(width, height)
    captures[#captures + 1] = { width, height }
  end,
}
local oldPixelDimensions = love.graphics.getPixelDimensions
love.graphics.getPixelDimensions = function() return 1832, 1920 end

local backend = Provider._newForTests(native)
check(type(backend) == "table", "test factory returns a backend")
eq(backend.beginFrame, nil, "adapter does not invent a beginFrame policy")
backend:update(1 / 30)
backend:endFrame("launcher", {})
eq(#captures, 0, "capture is rate-limited below 15 Hz")
backend:update(1 / 30)
backend:endFrame("launcher", {})
eq(#captures, 1, "completed frame is captured at the 15 Hz boundary")
eq(captures[1][1], 1832, "native capture receives pixel width")
eq(captures[1][2], 1920, "native capture receives pixel height")
backend:endFrame("game", {})
eq(#captures, 1, "elapsed capture budget resets after a capture")

love.graphics.getPixelDimensions = oldPixelDimensions

T.finish("Quest OpenXR display")

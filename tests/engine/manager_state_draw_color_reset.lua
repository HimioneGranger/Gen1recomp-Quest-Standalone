-- ManagerState sets white before each Font.drawBox call. Font.drawBox restores
-- that caller color, so ManagerState must select black before later TTF text.
-- This ROM-free regression covers both the main frame and overlay frame.
--
--   luajit tests/engine/manager_state_draw_color_reset.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Font = require("src.render.Font")
local ManagerState = require("src.mods.ManagerState")

local drawn = {}
local realDraw = Font.draw
Font.draw = function(text)
  local r, g, b, a = love.graphics.getColor()
  drawn[tostring(text)] = ("%s,%s,%s,%s"):format(r, g, b, a)
  return 0
end

local state = ManagerState.new({})
state.banner = "MAIN LABEL"
state.drawList = function()
  Font.draw("LIST CONTENT", 0, 0)
end
state.overlay = { kind = "ok", lines = { "OVERLAY LABEL" } }
state:draw()

Font.draw = realDraw

T.eq(drawn["MAIN LABEL"], "0,0,0,1",
  "main frame resets black after Font.drawBox")
T.eq(drawn["OVERLAY LABEL"], "0,0,0,1",
  "overlay resets black after Font.drawBox")

T.finish("manager state draw color reset")

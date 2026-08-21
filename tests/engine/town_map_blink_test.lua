-- Gen 1 Town Map blink timing from upstream f5b8b6c8, exercised without ROM
-- data or a LÖVE window.  The test records the real draw calls at the two
-- visibility boundaries and across the complete 50-frame cycle.
--   luajit tests/engine/town_map_blink_test.lua

package.path = "./?.lua;./?/init.lua;" .. package.path
if not _G.love then _G.love = require("tests.love_stub") end

local T = require("tests.harness")
local check, eq = T.check, T.eq
local Font = require("src.render.Font")
local TownMap = require("src.ui.TownMap")

local oldDraw = love.graphics.draw
local oldRectangle = love.graphics.rectangle
local oldSetColor = love.graphics.setColor
local oldFontDraw = Font.draw
local oldFontDrawBox = Font.drawBox
local oldFontDrawCode = Font.drawCode

local BG_IMAGE = {}
local BG_QUAD = {}
local CURSOR_IMAGE = {}
local NEST_IMAGE = {}
local calls

local function resetCalls()
  calls = { images = {}, markerRects = 0, cursorRects = 0, listCursors = 0 }
end

love.graphics.setColor = function() end
love.graphics.draw = function(image)
  calls.images[image] = (calls.images[image] or 0) + 1
end
love.graphics.rectangle = function(mode, _, _, w, h)
  if mode == "fill" and w == 4 and h == 4 then
    calls.markerRects = calls.markerRects + 1
  elseif mode == "line" and w == 7 and h == 7 then
    calls.cursorRects = calls.cursorRects + 1
  end
end
Font.draw = function() end
Font.drawBox = function() end
Font.drawCode = function(code)
  if code == 0xED then calls.listCursors = calls.listCursors + 1 end
end

local loc = { name = "PALLET TOWN", x = 2, y = 3 }
local game = {
  data = { pokemon = { PIKACHU = { name = "PIKACHU" } } },
  input = { wasPressed = function() return false end },
  stack = { pop = function() end },
}
local background = {
  img = BG_IMAGE,
  quads = { [0] = BG_QUAD },
  map = { 0 },
  cursor = CURSOR_IMAGE,
}

local function townMap(fields)
  local map = {
    game = game,
    mode = "grid",
    locs = { loc },
    sel = 1,
    blink = 0,
  }
  for key, value in pairs(fields or {}) do map[key] = value end
  return setmetatable(map, TownMap)
end

local grid = townMap({ bg = background, playerLoc = loc })
local fallback = townMap({ playerLoc = loc })
local nest = townMap({
  bg = background,
  nestSpecies = "PIKACHU",
  nests = { loc },
  nestIcon = NEST_IMAGE,
})
local list = townMap({ mode = "list", playerLoc = loc })

local function drawAt(map, blink)
  resetCalls()
  map.blink = blink
  map:draw()
  return calls
end

-- Boundary frames prove the inclusive/exclusive split directly.
for _, frame in ipairs({ 0, 24, 25, 49 }) do
  local visible = frame < 25

  local got = drawAt(nest, frame)
  eq(got.images[NEST_IMAGE] or 0, visible and 1 or 0,
    ("nest visibility at frame %d"):format(frame))

  got = drawAt(grid, frame)
  eq(got.images[CURSOR_IMAGE] or 0, visible and 1 or 0,
    ("grid cursor visibility at frame %d"):format(frame))
  eq(got.markerRects, 1,
    ("background-grid player marker is static at frame %d"):format(frame))

  got = drawAt(fallback, frame)
  eq(got.cursorRects, visible and 1 or 0,
    ("fallback-grid cursor visibility at frame %d"):format(frame))
  eq(got.markerRects, 1,
    ("fallback-grid player marker is static at frame %d"):format(frame))

  got = drawAt(list, frame)
  eq(got.listCursors, 1,
    ("list cursor is static at frame %d"):format(frame))
  eq(got.markerRects, 1,
    ("list player marker is static at frame %d"):format(frame))
end

-- Count the real draw decisions across a complete cycle: cursor and nest are
-- visible for exactly 25 frames, while every player/list marker stays visible.
local nestOn, gridCursorOn, fallbackCursorOn = 0, 0, 0
local gridPlayerOn, fallbackPlayerOn = 0, 0
local listCursorOn, listPlayerOn = 0, 0
for frame = 0, 49 do
  local got = drawAt(nest, frame)
  nestOn = nestOn + (got.images[NEST_IMAGE] or 0)

  got = drawAt(grid, frame)
  gridCursorOn = gridCursorOn + (got.images[CURSOR_IMAGE] or 0)
  gridPlayerOn = gridPlayerOn + got.markerRects

  got = drawAt(fallback, frame)
  fallbackCursorOn = fallbackCursorOn + got.cursorRects
  fallbackPlayerOn = fallbackPlayerOn + got.markerRects

  got = drawAt(list, frame)
  listCursorOn = listCursorOn + got.listCursors
  listPlayerOn = listPlayerOn + got.markerRects
end

eq(nestOn, 25, "nest is visible for 25/50 frames")
eq(gridCursorOn, 25, "background-grid cursor is visible for 25/50 frames")
eq(fallbackCursorOn, 25, "fallback-grid cursor is visible for 25/50 frames")
eq(gridPlayerOn, 50, "background-grid player marker is visible for 50/50 frames")
eq(fallbackPlayerOn, 50, "fallback-grid player marker is visible for 50/50 frames")
eq(listCursorOn, 50, "list cursor is visible for 50/50 frames")
eq(listPlayerOn, 50, "list player marker is visible for 50/50 frames")

local counter = townMap({ mode = "list" })
counter.blink = 49
counter:update(0)
eq(counter.blink, 0, "the 50-frame counter wraps from 49 to 0")

love.graphics.draw = oldDraw
love.graphics.rectangle = oldRectangle
love.graphics.setColor = oldSetColor
Font.draw = oldFontDraw
Font.drawBox = oldFontDrawBox
Font.drawCode = oldFontDrawCode

local sourceFile = assert(io.open("src/ui/TownMap.lua", "r"))
local source = sourceFile:read("*a")
sourceFile:close()
check(not source:find("GameVersion", 1, true),
  "the Gen 1 TownMap source does not import GameVersion")

T.finish("town_map_blink")

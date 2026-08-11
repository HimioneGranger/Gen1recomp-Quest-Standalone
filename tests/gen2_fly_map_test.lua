-- FLY's destination picker (pokegold engine/pokegear/pokegear.asm _FlyMap).
--
-- _FlyMap is the town map on its OWN screen: the same LoadTownMapGFX art the
-- POKeGEAR's MAP card draws, with TownMapBubble's "Where?" plate instead of the
-- card strip and no ENGINE_MAP_CARD gate at all.  The cursor walks the
-- Flypoints table between wStartFlypoint and wEndFlypoint, skipping every row
-- CheckIfVisitedFlypoint rejects; A takes the row under it and B answers -1.
--   luajit tests/gen2_fly_map_test.lua
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 fly map")
local check, eq = S.check, S.eq

love = require("tests.love_stub")
require("src.core.Logger").warn = function() end

local FieldMoves = require("src.world.gen2.FieldMoves")
local Pokegear = require("src.ui.gen2.Pokegear")

local function fakeInput()
  local pressed = {}
  return {
    press = function(_self, button) pressed[button] = true end,
    wasPressed = function(_self, button)
      if pressed[button] then
        pressed[button] = nil
        return true
      end
      return false
    end,
  }
end

-- landmarks.lua's shape, for the rows the picker names and parks on.
-- KANTO_LANDMARK is $2e = 46, and Pokegear:region reads the PLAYER's landmark
-- index against it, so the Kanto rows have to sit above it here too.
local LANDMARKS = { landmarks = {}, order = {} }
for i, row in ipairs(FieldMoves.FLYPOINTS) do
  local index = i < FieldMoves.KANTO_FLYPOINT and i
    or (46 + i - FieldMoves.KANTO_FLYPOINT)
  LANDMARKS.landmarks[row.landmark] = {
    index = index, name = row.landmark:gsub("^LANDMARK_", ""), x = 8, y = 8,
  }
  LANDMARKS.order[index] = row.landmark
end

local function visited(...)
  local save = { engineFlags = {} }
  for _, spawn in ipairs({ ... }) do
    for _, row in ipairs(FieldMoves.FLYPOINTS) do
      if row.spawn == spawn then save.engineFlags[row.flag] = true end
    end
  end
  return save
end

-- The gate World:openFlyMap reads before it pushes this screen instead of
-- falling back to its yes/no chain.
check(Pokegear.FLY_MAP == true, "Pokegear now declares a fly mode")

local function flyScreen(save, opts)
  opts = opts or {}
  local input = fakeInput()
  local points = FieldMoves.flyPoints(save, LANDMARKS, opts.region or "johto")
  local chosen, closed
  local screen = Pokegear.new({ input = input, save = save }, {
    save = save,
    landmarks = LANDMARKS,
    currentLandmark = opts.currentLandmark,
    fly = points,
    onFly = function(spawn) chosen = spawn end,
    onClose = function() closed = true end,
  })
  return screen, input, points,
    function() return chosen end, function() return closed end
end

-- ---------------------------------------------------------------- the screen
do
  local save = visited("SPAWN_NEW_BARK", "SPAWN_VIOLET", "SPAWN_GOLDENROD")
  local screen, input, points, chosen, closed = flyScreen(save)
  eq(#points, 3, "only the visited flypoints are offered")
  eq(#screen.cards, 1, "the picker is one screen, not the card strip")
  eq(screen.mode, "card", "and it opens straight onto the map")
  -- FlyMap's Johto default is JOHTO_FLYPOINT, the first row (New Bark Town).
  eq(screen.flyIndex, 1, "the Johto map opens on the first flypoint")
  eq(screen:flyRow().spawn, "SPAWN_NEW_BARK", "which is New Bark Town")
  -- The MAP card's cursor follows the flypoint, so the name plate and the
  -- arrow both land on the row rather than on a free landmark.
  eq(screen:mapCursorIndex(), LANDMARKS.landmarks.LANDMARK_NEW_BARK_TOWN.index,
    "and the map cursor sits on it")

  input:press("up")
  screen:update(0)
  eq(screen:flyRow().spawn, "SPAWN_VIOLET", ".ScrollNext takes the next row")
  eq(screen:mapCursorIndex(), LANDMARKS.landmarks.LANDMARK_VIOLET_CITY.index,
    "and the cursor moves with it")
  input:press("up")
  screen:update(0)
  input:press("up")
  screen:update(0)
  eq(screen:flyRow().spawn, "SPAWN_NEW_BARK", "and it wraps at wEndFlypoint")
  input:press("down")
  screen:update(0)
  eq(screen:flyRow().spawn, "SPAWN_GOLDENROD",
    ".ScrollPrev wraps the other way at wStartFlypoint")

  -- Left and right do nothing: there is no card to page to on this screen.
  input:press("right")
  screen:update(0)
  eq(screen:flyRow().spawn, "SPAWN_GOLDENROD", "right does not page the gear")
  input:press("left")
  screen:update(0)
  eq(screen:flyRow().spawn, "SPAWN_GOLDENROD", "and neither does left")
  eq(#screen.cards, 1, "the strip is still one row")

  input:press("a")
  screen:update(0)
  eq(chosen(), "SPAWN_GOLDENROD", "A takes the flypoint under the cursor")
  check(not closed(), "and does not also close the screen")
end

do
  -- `ld a, -1`: B answers "no flypoint" and the caller drops it.
  local save = visited("SPAWN_NEW_BARK")
  local screen, input, _points, chosen, closed = flyScreen(save)
  input:press("b")
  screen:update(0)
  check(closed(), "B leaves the picker")
  eq(chosen(), nil, "with nothing chosen")
end

do
  -- .KantoFlyMap opens on the LAST row (Indigo Plateau), and the Kanto half is
  -- withheld entirely until Indigo is visited.
  local save = visited("SPAWN_NEW_BARK", "SPAWN_PALLET", "SPAWN_INDIGO")
  local screen = flyScreen(save, {
    region = "kanto", currentLandmark = "LANDMARK_PALLET_TOWN",
  })
  eq(screen.flyIndex, #screen.fly, "the Kanto map opens on the last flypoint")
  eq(screen:flyRow().spawn, "SPAWN_INDIGO", "which is Indigo Plateau")
end

do
  local save = visited("SPAWN_NEW_BARK", "SPAWN_PALLET")
  local points = FieldMoves.flyPoints(save, LANDMARKS, "kanto")
  eq(#points, 1, "with no Indigo the Kanto half is withheld")
  eq(points[1].spawn, "SPAWN_NEW_BARK", "and the Johto map is shown instead")
end

-- Drawing must not throw: the plain path (no town-map art in the cache) is
-- what a headless run and an older cache take.
do
  local save = visited("SPAWN_NEW_BARK", "SPAWN_VIOLET")
  local screen = flyScreen(save)
  local ok, err = pcall(function() screen:drawPanel() end)
  check(ok, "the unstyled fly picker draws (" .. tostring(err) .. ")")
end

S.finish()

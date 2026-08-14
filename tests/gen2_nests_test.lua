-- FindNest: which landmarks a species can be met in.
--
--   luajit tests/gen2_nests_test.lua
--
-- The data behind the Pokedex's AREA page, which the port drew a label for and
-- never implemented. engine/overworld/wildmons.asm FindNest reads exactly three
-- sources -- grass, water, and the three roamers' current map -- and nothing
-- else, so a HEADBUTT-only or fishing-only species legitimately has no nest and
-- the page is blank. That is the cart's answer, not a hole.
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 nests")
local check, eq = S.check, S.eq

local Nests = require("src.core.gen2.Nests")

-- Landmark indices from constants/landmark_constants.asm: Johto runs below
-- PALLET_TOWN ($2e), Kanto from it up to ROUTE_28.
local DATA = {
  -- gen2Maps, matching Game2's key for the Gold map table.
  gen2Maps = {
    ROUTE_29        = { landmark = 2 },   -- Johto
    ILEX_FOREST     = { landmark = 11 },  -- Johto
    ROUTE_1         = { landmark = 0x2f }, -- Kanto
    UNION_CAVE_1F   = { landmark = 9 },   -- Johto
    NOWHERE         = { },                -- no landmark at all
  },
  -- Game2 loads the encounter tables under gen2Encounters, not `encounters`:
  -- the flat name is Gen 1's and Gen2Compat only maps it for mods.
  gen2Encounters = {
    grass = {
      ROUTE_29 = { slots = {
        MORN = { { species = "PIDGEY" }, { species = "SENTRET" } },
        DAY  = { { species = "PIDGEY" } },
        NITE = { { species = "HOOTHOOT" } },
      } },
      ILEX_FOREST = { slots = {
        DAY = { { species = "ODDISH" }, { species = "PARAS" } },
      } },
      ROUTE_1 = { slots = { DAY = { { species = "PIDGEY" } } } },
      NOWHERE = { slots = { DAY = { { species = "PIDGEY" } } } },
    },
    water = {
      UNION_CAVE_1F = { slots = { DAY = { { species = "TENTACOOL" } } } },
    },
  },
}

-- Grass, every time of day. NITE-only HOOTHOOT counts: the cart walks all
-- NUM_GRASSMON * 3 slots without caring which third it is in.
do
  eq(#Nests.find(DATA, "HOOTHOOT", "johto"), 1,
     "a night-only encounter is still a nest")
  eq(Nests.find(DATA, "HOOTHOOT", "johto")[1], 2, "on Route 29's landmark")
end

-- Several maps, sorted, deduplicated across times of day.
do
  local pidgey = Nests.find(DATA, "PIDGEY", "johto")
  eq(#pidgey, 1, "PIDGEY appears on one JOHTO landmark")
  eq(pidgey[1], 2, "Route 29")
  local kanto = Nests.find(DATA, "PIDGEY", "kanto")
  eq(#kanto, 1, "and one KANTO landmark")
  eq(kanto[1], 0x2f, "Route 1")
  eq(#Nests.find(DATA, "PIDGEY"), 2, "both regions when none is asked for")
end

-- Water counts as well as grass.
do
  local t = Nests.find(DATA, "TENTACOOL", "johto")
  eq(#t, 1, "a water-only species has a nest")
  eq(t[1], 9, "Union Cave")
end

-- A map with no landmark contributes nothing rather than a nil index.
do
  local p = Nests.find(DATA, "PIDGEY", "johto")
  for _, index in ipairs(p) do
    check(index ~= nil and index > 0, "every returned landmark is a real index")
  end
end

-- Nothing anywhere.
do
  eq(#Nests.find(DATA, "MEWTWO", "johto"), 0, "an absent species has no nest")
end

-- Roamers: reported from their CURRENT map, and by Roamers.active rather than
-- by HP. A fresh roamer sits at hp 0 (`xor a ; generate new stats`), so an HP
-- test would hide all three until you had already met them.
do
  local save = { roamers = {
    { species = "RAIKOU", map = "ROUTE_29", hp = 0 },
    { species = "ENTEI" },                       -- caught: no map, inactive
  } }
  local r = Nests.find(DATA, "RAIKOU", "johto", save)
  eq(#r, 1, "an un-met roamer still shows a nest")
  eq(r[1], 2, "at the map it is currently on")
  eq(#Nests.find(DATA, "ENTEI", "johto", save), 0,
     "a caught roamer shows none")
end

-- The region split itself.
do
  eq(Nests.regionOf(2), "johto", "low indices are Johto")
  eq(Nests.regionOf(0x2d), "johto", "up to SILVER_CAVE")
  eq(Nests.regionOf(0x2e), "kanto", "PALLET_TOWN starts Kanto")
  check(Nests.regionOf(0) == nil, "LANDMARK_SPECIAL is neither")
  check(Nests.regionOf(0x5e) == nil, "and neither is FAST_SHIP")
end

S.finish()

-- Walking into a Pokecenter has to move the respawn point.
--
--   luajit tests/gen2_pokecenter_spawn_test.lua
--
-- Found by the Gold route bot (tests/drivers/gold_bot.lua): every whiteout at
-- the Elite Four dropped the player in CHERRYGROVE_CITY and the bot spent
-- ~40k frames per attempt walking back across Johto.
--
-- The cause is one unported rule. home/map.asm's LoadMapAttributes ends in
-- .SetSpawn:
--
--     call GetMapEnvironment / CheckOutdoorMap   ; leaving an outdoor map
--     call GetAnyMapEnvironment / CheckIndoorMap ; entering an indoor one
--     call GetAnyMapTileset / cp TILESET_POKECENTER
--     ld a, [wPrevMapGroup]  -> wLastSpawnMapGroup
--     ld a, [wPrevMapNumber] -> wLastSpawnMapNumber
--
-- That pair is what engine/events/whiteout.asm reads, and walking in the door
-- is the ONLY thing in the game that moves it -- healing does not, and neither
-- does saving. The port never had it, so the pair only ever held what
-- `blackoutmod` wrote... and MrPokemonsHouse.asm does `blackoutmod
-- CHERRYGROVE_CITY` in the first half hour. With no other writer, every
-- whiteout for the remaining forty hours of the game returned the player to
-- Cherrygrove.
--
-- What is stored is the map being LEFT, not the Pokecenter: spawn_points.asm is
-- keyed that way (`spawn PALLET_TOWN, 5, 6`), and warpToSpawn resolves the
-- stored map through that table to get the coordinates. It is what makes the
-- Indigo Plateau centre work -- it is entered from ROUTE_23, and SPAWN_INDIGO
-- is ROUTE_23 (9,6).
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 pokecenter spawn")
local check, eq = S.check, S.eq

local World = require("src.world.gen2.World")

-- The rule reads three fields off two map defs and writes one save field, so
-- it can be exercised against a stub world rather than a booted game.
local function world(prevDef)
  return setmetatable({
    maps = {},
    tilesets = {},
    game = { save = {} },
    map = prevDef and { def = prevDef } or nil,
  }, { __index = World })
end

local TOWN  = { id = "CHERRYGROVE_CITY", environment = "TOWN",
                tileset = "TILESET_JOHTO" }
local ROUTE = { id = "ROUTE_29", environment = "ROUTE",
                tileset = "TILESET_JOHTO" }
local CENTER = { id = "CHERRYGROVE_POKECENTER_1F", environment = "INDOOR",
                 tileset = "TILESET_POKECENTER" }
local CENTER2F = { id = "POKECENTER_2F", environment = "INDOOR",
                   tileset = "TILESET_POKECENTER" }
local MART = { id = "CHERRYGROVE_MART", environment = "INDOOR",
               tileset = "TILESET_MART" }
local GYM = { id = "BRUNOS_ROOM", environment = "INDOOR",
              tileset = "TILESET_ELITE_FOUR_ROOM" }

-- The shipped rule, not a restatement of it: setMap calls exactly this, and it
-- needs nothing but two map defs and a save.
local function applySpawnRule(w, def, mapId)
  return w:updateWhiteoutSpawn(def, mapId)
end

-- The case the bug was about: town -> Pokecenter moves the spawn.
do
  local w = world(TOWN)
  w.game.save.blackoutMap = "CHERRYGROVE_CITY"
  applySpawnRule(w, CENTER, CENTER.id)
  eq(w.game.save.blackoutMap, "CHERRYGROVE_CITY",
     "walking in from the town stores the TOWN, the way spawn_points.asm is keyed")
end

-- A Pokecenter reached from a ROUTE counts too: CheckOutdoorMap passes ROUTE
-- and TOWN alike, which is what makes the Indigo Plateau centre work (it is
-- entered from INDIGO_PLATEAU, environment ROUTE).
do
  local w = world(ROUTE)
  applySpawnRule(w, CENTER, CENTER.id)
  eq(w.game.save.blackoutMap, "ROUTE_29",
     "a Pokecenter entered from a route stores the route")
end

-- Indoor -> indoor must NOT move it. Going up to the trade floor is the case
-- that matters: POKECENTER_2F has the Pokecenter tileset, so without the
-- environment guard on the map being LEFT this would fire on the stairs and
-- pin the spawn to the second floor.
do
  local w = world(CENTER)
  w.game.save.blackoutMap = "CHERRYGROVE_POKECENTER_1F"
  applySpawnRule(w, CENTER2F, CENTER2F.id)
  eq(w.game.save.blackoutMap, "CHERRYGROVE_POKECENTER_1F",
     "1F -> 2F leaves the spawn alone")
end

-- Any other building leaves it alone, however indoor it is.
do
  local w = world(TOWN)
  w.game.save.blackoutMap = "CHERRYGROVE_POKECENTER_1F"
  applySpawnRule(w, MART, MART.id)
  eq(w.game.save.blackoutMap, "CHERRYGROVE_POKECENTER_1F",
     "the Mart is not a Pokecenter")
  applySpawnRule(w, GYM, GYM.id)
  eq(w.game.save.blackoutMap, "CHERRYGROVE_POKECENTER_1F",
     "an Elite Four room is not a Pokecenter")
end

-- The first map load of a new game has no previous map at all.
do
  local w = world(nil)
  applySpawnRule(w, CENTER, CENTER.id)
  check(w.game.save.blackoutMap == nil,
        "no previous map means no spawn write")
end

-- And the payoff: warpToSpawn honours what the rule wrote. This is the half
-- that was already correct -- the stored map wins over the SPAWN_* lookup --
-- and it is why storing the Pokecenter is enough.
do
  local landed = {}
  local w = setmetatable({
    maps = {
      CHERRYGROVE_POKECENTER_1F = { warps = { { x = 3, y = 7 } } },
    },
    game = { save = { blackoutMap = "CHERRYGROVE_POKECENTER_1F" } },
    setMap = function(_, id, x, y, facing)
      landed.id, landed.x, landed.y, landed.facing = id, x, y, facing
    end,
  }, { __index = World })
  w:warpToSpawn()
  eq(landed.id, "CHERRYGROVE_POKECENTER_1F", "a whiteout lands in the centre")
  eq(landed.x, 3, "at its first warp x")
  eq(landed.y, 7, "at its first warp y")
end

S.finish()

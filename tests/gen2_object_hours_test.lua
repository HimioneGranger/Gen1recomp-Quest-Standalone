-- Object hour windows: CheckObjectTime (pokegold home/map_objects.asm), the
-- half of LoadObjectMasks that CheckObjectFlag is not.  An object_event's two
-- hour bytes (macros/scripts/maps.asm) can hide it by hour range or by
-- MORN/DAY/NITE mask, and a port that ignores them stacks every time-shift
-- variant of an NPC on the map at once: three Moms in the player's kitchen,
-- two pharmacists on one Game Corner tile, and a Mt Moon gift shop that is
-- never unattended.
--
--   GOLD_CACHE=".../gold" luajit tests/gen2_object_hours_test.lua
--
-- The window semantics are ROM-free; the map sections SKIP without a cache.
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 object hours")
local check, eq = S.check, S.eq

love = require("tests.love_stub")

local World = require("src.world.gen2.World")

local function worldAtHour(hour)
  local world = World.new({ data = {}, save = { player = {} } })
  world.clockHour = hour
  return world
end

-- ---- the time-of-day mask (GetTimeOfDay, engine/rtc/rtc.asm) ---------------
-- 0400-0959 morn, 1000-1759 day, 1800-0359 nite; MORN 1 / DAY 2 / NITE 4 are
-- the shift_const values in constants/ram_constants.asm.
eq(worldAtHour(4):clockTimeMask(), 1, "04:00 is MORN")
eq(worldAtHour(9):clockTimeMask(), 1, "09:00 is still MORN")
eq(worldAtHour(10):clockTimeMask(), 2, "10:00 is DAY")
eq(worldAtHour(17):clockTimeMask(), 2, "17:00 is still DAY")
eq(worldAtHour(18):clockTimeMask(), 4, "18:00 is NITE")
eq(worldAtHour(3):clockTimeMask(), 4, "03:00 is NITE too, wrapping midnight")

-- ---- CheckObjectTime, arm by arm -------------------------------------------
local function visible(hour, h1, h2)
  return worldAtHour(hour):objectTimeVisible({ hours = { h1, h2 } })
end

-- h1 == -1: h2 is a MORN/DAY/NITE bitmask, -1 always appears.
check(visible(12, -1, -1), "hours {-1,-1} always appears")
check(worldAtHour(12):objectTimeVisible({}), "no hours field always appears")
check(visible(6, -1, 1), "MORN mask shows at 06:00")
check(not visible(12, -1, 1), "MORN mask hides at noon")
check(not visible(20, -1, 1), "and at night")
check(visible(12, -1, 2), "DAY mask shows at noon")
check(not visible(6, -1, 2), "DAY mask hides in the morning")
check(visible(20, -1, 4), "NITE mask shows at 20:00")
check(visible(3, -1, 4), "NITE mask shows at 03:00 across midnight")
check(not visible(12, -1, 4), "NITE mask hides at noon")
check(visible(6, -1, 5), "a MORN|NITE combo shows in the morning")
check(visible(20, -1, 5), "and at night")
check(not visible(12, -1, 5), "but not in the day")

-- h1 < h2: the object appears from h1 to h2, inclusive on both ends
-- (.check_timeofday's `cp` pair in CheckObjectTime).
check(visible(8, 8, 17), "window 8-17 shows at 08:00")
check(visible(17, 8, 17), "and at 17:00")
check(visible(12, 8, 17), "and in between")
check(not visible(7, 8, 17), "but not at 07:00")
check(not visible(18, 8, 17), "nor at 18:00")

-- h1 > h2: the object does NOT appear strictly between h2 and h1 -- it shows
-- at both endpoints and outside them (.check_hour's fallthrough arm).
check(visible(20, 20, 6), "inverted 20-6 shows at 20:00")
check(visible(23, 20, 6), "and at 23:00")
check(visible(3, 20, 6), "and at 03:00")
check(visible(6, 20, 6), "and at the 06:00 endpoint")
check(not visible(12, 20, 6), "but hides at noon")
check(not visible(19, 20, 6), "and at 19:00")

-- h1 == h2: always.
check(visible(0, 9, 9), "equal hours always appear")
check(visible(23, 9, 9), "at any hour")

-- ---- the spawn filter riding the real rebuildPeople ------------------------
-- The pooling half is stubbed (a sprite sheet needs a graphics device); the
-- filter chain -- hiddenObjects, then the event flag, then the hour window --
-- is the shipped code.
local cache = os.getenv("GOLD_CACHE")
if not cache then
  local home = os.getenv("HOME") or ""
  cache = home .. "/Library/Application Support/LOVE/gold-dev/gold"
end
local probe = io.open(cache .. "/data/generated/maps.lua", "r")
if not probe then
  check(true, "gold cache absent (SKIP map spawn checks)")
  S.finish()
  return
end
probe:close()

local maps = assert(loadfile(cache .. "/data/generated/maps.lua"))()

local function spawnWorld(mapId, hour, events)
  local world = worldAtHour(hour)
  world.maps = maps
  world.map = { id = mapId, def = maps[mapId] }
  world.neighbors = {}
  for _, id in ipairs(events or {}) do world.events:set(id, true) end
  world.pooledNpc = function(_, ownerMap, obj)
    return { def = obj, id = ownerMap .. ":" .. tostring(obj.index) }
  end
  world:rebuildPeople()
  return world
end

local function countSprites(world, sprite)
  local n = 0
  for _, npc in ipairs(world.npcs) do
    if npc.def.sprite == sprite then n = n + 1 end
  end
  return n
end

-- PLAYERS_HOUSE_1F: MOM1 is the intro Mom (EVENT_PLAYERS_HOUSE_MOM_1, 1735);
-- MOM2/3/4 share EVENT_PLAYERS_HOUSE_MOM_2 (1736) and split the day between
-- them with MORN/DAY/NITE masks (maps/PlayersHouse1F.asm).  After the intro
-- (1735 set, 1736 clear) exactly ONE Mom may stand in the kitchen.
for _, probeHour in ipairs({ 6, 12, 20 }) do
  local world = spawnWorld("PLAYERS_HOUSE_1F", probeHour, { 1735 })
  eq(countSprites(world, "SPRITE_MOM"), 1,
    ("one Mom at %02d:00, not three"):format(probeHour))
end

-- Before the intro (1736 set, 1735 clear) the intro Mom is the one Mom.
local intro = spawnWorld("PLAYERS_HOUSE_1F", 12, { 1736 })
eq(countSprites(intro, "SPRITE_MOM"), 1, "the intro house has one Mom too")
eq(intro.npcs[1] and intro.npcs[1].def.index, 1, "and it is MOM1")

-- GOLDENROD_GAME_CORNER: the pharmacist is defined twice on tile (8,7), one
-- DAY one NITE (maps/GoldenrodGameCorner.asm), so he must be single all day
-- and absent in the morning.
eq(countSprites(spawnWorld("GOLDENROD_GAME_CORNER", 12), "SPRITE_PHARMACIST"),
  1, "one pharmacist in the day")
eq(countSprites(spawnWorld("GOLDENROD_GAME_CORNER", 20), "SPRITE_PHARMACIST"),
  1, "one pharmacist at night")
eq(countSprites(spawnWorld("GOLDENROD_GAME_CORNER", 6), "SPRITE_PHARMACIST"),
  0, "and none in the morning")

-- MOUNT_MOON_GIFT_SHOP: a MORN pair and a DAY pair of clerk + lass, no NITE
-- staff at all -- the shop is unattended at night.
local function giftShopStaff(hour)
  local world = spawnWorld("MOUNT_MOON_GIFT_SHOP", hour)
  return #world.npcs
end
eq(giftShopStaff(6), 2, "gift shop: morning shift is two people")
eq(giftShopStaff(14), 2, "day shift is two people")
eq(giftShopStaff(22), 0, "and nobody minds the shop at night")

-- ---- the respawn on a clock rollover ---------------------------------------
-- On the cart a map load recomputes wObjectMasks; the port's stand-in is the
-- once-a-second palette poll noticing the hour moved and rebuilding people.
do
  local world = spawnWorld("GOLDENROD_GAME_CORNER", 17)
  local rebuilt = 0
  world.applyPalettes = function() return false end
  local realRebuild = world.rebuildPeople
  world.rebuildPeople = function(self, opts)
    rebuilt = rebuilt + 1
    return realRebuild(self, opts)
  end
  for _ = 1, 60 do world:pollTimeOfDay() end
  eq(rebuilt, 0, "a poll with the clock still on 17:00 rebuilds nothing")
  world.clockHour = 18
  for _ = 1, 60 do world:pollTimeOfDay() end
  eq(rebuilt, 1, "the poll that sees 18:00 rebuilds the people")
  eq(countSprites(world, "SPRITE_PHARMACIST"), 1,
    "and the night pharmacist clocks in")
  local night
  for _, npc in ipairs(world.npcs) do
    if npc.def.sprite == "SPRITE_PHARMACIST" then night = npc.def end
  end
  eq(night and night.hours and night.hours[2], 4,
    "specifically the NITE row of the pair")
end

S.finish()

-- The shared POKECENTER_2F staircase must lead back down into whichever
-- centre it was climbed from.
--
--   GOLD_CACHE=".../gold" luajit tests/gen2_pokecenter_stairs_test.lua
--
-- maps/Pokecenter2F.asm declares its one staircase as
--
--   warp_event  0,  7, POKECENTER_2F, -1
--
-- and that -1 is a contract with home/map.asm, in two halves.  CopyWarpData
-- stores the warp stepped ON and the map being left in wPrevWarp /
-- wPrevMapGroup / wPrevMapNumber on every warp taken; LoadMapAttributes'
-- warp-coordinate read then copies that triple into wBackupWarpNumber /
-- wBackupMapGroup / wBackupMapNumber whenever the warp ARRIVED ON declares
-- destination warp -1.  Stepping back onto the -1 warp reads the whole triple
-- out of the backup (`cp -1 / ld hl, wBackupWarpNumber` in CopyWarpData), so
-- one second floor serves every Pokemon Center in the game.
--
-- The port had only the read half (World:resolveWarp), and its single writer
-- was the elevator menu -- so the 2F staircase resolved to POKECENTER_2F warp
-- 255, found nothing, and did nothing: the player was trapped upstairs in
-- every centre.  What is asserted here is the write half riding the REAL
-- takeWarp, against the real extracted maps.
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 pokecenter stairs")
local check, eq = S.check, S.eq

local World = require("src.world.gen2.World")
local Map = require("src.world.gen2.Map")

local cache = os.getenv("GOLD_CACHE")
if not cache then
  local home = os.getenv("HOME") or ""
  cache = home .. "/Library/Application Support/LOVE/gold-dev/gold"
end
local probe = io.open(cache .. "/data/generated/maps.lua", "r")
if not probe then
  check(true, "gold cache absent (SKIP)")
  S.finish()
  return
end
probe:close()

local function loadLua(rel) return assert(loadfile(cache .. "/" .. rel))() end
local maps = loadLua("data/generated/maps.lua")
local tilesets = loadLua("data/generated/tilesets.lua")

-- The map data this whole feature hangs on: the 2F staircase really is the -1
-- sentinel, kept by the extractor as the raw byte.
eq(maps.POKECENTER_2F.warps[1].destWarp, 0xff,
  "POKECENTER_2F's staircase declares destination warp -1")
eq(maps.CHERRYGROVE_POKECENTER_1F.warps[3].destMap, "POKECENTER_2F",
  "Cherrygrove's stairs lead up to the shared 2F")
eq(maps.VIOLET_POKECENTER_1F.warps[3].destMap, "POKECENTER_2F",
  "and so do Violet's")

-- A World over the real defs.  setMap is recorded rather than run (baking a
-- map image needs a graphics device); takeWarp's own bookkeeping around it --
-- resolveWarp, the wPrev capture, recordWarpBackup -- is the shipped code.
local function world(mapId, x, y)
  local game = { data = { audio = { sfxOrder = {} } }, save = { player = {} } }
  local w = World.new(game)
  w.maps, w.tilesets = maps, tilesets
  w.map = Map.new(maps[mapId], tilesets[maps[mapId].tileset])
  w.player = { cellX = x, cellY = y, facing = "up", moving = false }
  w.loaded = nil
  w.setMap = function(self, id, cx, cy, facing)
    self.loaded = { id = id, x = cx, y = cy, facing = facing }
    return true
  end
  return w
end

-- MAPSETUP_DOOR fades out before the load, so the take is parked in
-- world.mapSetup; this drains it the way World:step does.
local function pump(w)
  for _ = 1, 64 do
    if not w.mapSetup then return end
    w:updateMapSetup()
  end
end

-- Climb the stairs from Cherrygrove: the arrival warp is the -1 staircase, so
-- the take must bank {Cherrygrove 1F, warp 3} as the way back.
do
  local w = world("CHERRYGROVE_POKECENTER_1F", 0, 7)
  check(w:takeWarp(maps.CHERRYGROVE_POKECENTER_1F.warps[3]),
    "the 1F stairs warp up")
  pump(w)
  eq(w.loaded and w.loaded.id, "POKECENTER_2F", "landing on the shared 2F")
  check(w.backupWarp ~= nil, "arriving on a -1 warp banks the backup triple")
  eq(w.backupWarp.map, "CHERRYGROVE_POKECENTER_1F",
    "the banked map is the centre being left")
  eq(w.backupWarp.warp, 3, "and the banked warp is the stairs stepped on")

  -- Step back onto the staircase: the -1 destination resolves through the
  -- backup, back into the same centre, onto the same stairs.
  w.map = Map.new(maps.POKECENTER_2F, tilesets[maps.POKECENTER_2F.tileset])
  w.player = { cellX = 0, cellY = 7, facing = "down", moving = false }
  w.loaded = nil
  check(w:takeWarp(maps.POKECENTER_2F.warps[1]), "the 2F stairs warp at all")
  pump(w)
  eq(w.loaded and w.loaded.id, "CHERRYGROVE_POKECENTER_1F",
    "and they lead back to the centre the player came from")
  eq(w.loaded.x, maps.CHERRYGROVE_POKECENTER_1F.warps[3].x,
    "onto that centre's own staircase tile x")
  eq(w.loaded.y, maps.CHERRYGROVE_POKECENTER_1F.warps[3].y, "and y")
end

-- The same 2F reached from Violet leads back to Violet: the backup is
-- re-banked on every -1 arrival, which is the whole point of the sentinel.
do
  local w = world("VIOLET_POKECENTER_1F", 0, 7)
  check(w:takeWarp(maps.VIOLET_POKECENTER_1F.warps[3]), "Violet's stairs warp")
  pump(w)
  eq(w.backupWarp.map, "VIOLET_POKECENTER_1F", "the backup now names Violet")

  w.map = Map.new(maps.POKECENTER_2F, tilesets[maps.POKECENTER_2F.tileset])
  w.player = { cellX = 0, cellY = 7, facing = "down", moving = false }
  w.loaded = nil
  check(w:takeWarp(maps.POKECENTER_2F.warps[1]), "the staircase works here too")
  pump(w)
  eq(w.loaded and w.loaded.id, "VIOLET_POKECENTER_1F",
    "and comes down in Violet, not Cherrygrove")
end

-- An ordinary warp arrival must NOT disturb the backup: the trade corner
-- doors up on the 2F carry real destinations, and only a -1 arrival re-banks.
do
  local w = world("CHERRYGROVE_POKECENTER_1F", 0, 7)
  check(w:takeWarp(maps.CHERRYGROVE_POKECENTER_1F.warps[3]), "up the stairs")
  pump(w)
  local banked = w.backupWarp
  w.map = Map.new(maps.CHERRYGROVE_POKECENTER_1F,
    tilesets[maps.CHERRYGROVE_POKECENTER_1F.tileset])
  w.player = { cellX = 3, cellY = 7, facing = "down", moving = false }
  check(w:takeWarp(maps.CHERRYGROVE_POKECENTER_1F.warps[1]),
    "out the front door")
  pump(w)
  eq(w.backupWarp, banked,
    "a warp whose arrival declares a real destination leaves the backup alone")
end

-- With no backup banked at all (a fresh boot standing upstairs), the -1 warp
-- still must not crash; the cart would read whatever the triple last held.
do
  local w = world("POKECENTER_2F", 0, 7)
  eq(w:takeWarp(maps.POKECENTER_2F.warps[1]), false,
    "an unbanked -1 warp refuses rather than crashing")
end

-- Save and reload upstairs: the triple is saved WRAM on the cart, so it rides
-- save.backupWarp -- Game2:snapshotSave writes it and World:loadPlayerData
-- reads it back into the rebuilt world.
do
  local w = world("CHERRYGROVE_POKECENTER_1F", 0, 7)
  check(w:takeWarp(maps.CHERRYGROVE_POKECENTER_1F.warps[3]), "up the stairs")
  pump(w)

  -- The snapshot half, through the real Game2 method.
  local Game2 = require("src.core.Game2")
  local host = setmetatable({
    save = { player = {} },
    world = w,
    options = {},
  }, { __index = Game2 })
  w.map = Map.new(maps.POKECENTER_2F, tilesets[maps.POKECENTER_2F.tileset])
  w.player = { cellX = 0, cellY = 7, facing = "down", moving = false }
  local saved = host:snapshotSave()
  check(type(saved.backupWarp) == "table", "the snapshot carries the triple")
  eq(saved.backupWarp.map, "CHERRYGROVE_POKECENTER_1F", "with the map")
  eq(saved.backupWarp.warp, 3, "and the warp")

  -- The restore half, through the real loadPlayerData on a fresh World.
  local w2 = world("POKECENTER_2F", 0, 7)
  w2:loadPlayerData(saved)
  check(w2.backupWarp ~= nil, "loadPlayerData restores the triple")
  eq(w2.backupWarp.map, "CHERRYGROVE_POKECENTER_1F", "map intact")
  eq(w2.backupWarp.warp, 3, "warp intact")
  w2.loaded = nil
  check(w2:takeWarp(maps.POKECENTER_2F.warps[1]),
    "so the stairs work after a save made upstairs")
  pump(w2)
  eq(w2.loaded and w2.loaded.id, "CHERRYGROVE_POKECENTER_1F",
    "and still lead home")
end

S.finish()

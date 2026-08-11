# Section 31 - Mount Silver and Red

Source: `../section-31-mount-silver-and-red.txt`
Maps covered: `MAP_SILVER_CAVE_OUTSIDE`, `MAP_SILVER_CAVE_POKECENTER_1F`,
`MAP_SILVER_CAVE_ROOM_1`, `MAP_SILVER_CAVE_ROOM_2`, `MAP_SILVER_CAVE_ITEM_ROOMS`,
`MAP_SILVER_CAVE_ROOM_3` (plus `MAP_VICTORY_ROAD_GATE`, cited only as the gate
that lets you reach Route 28 in the first place).
Badges / key milestones in this section: no badge. The milestone is the `RED`
trainer battle in `maps/SilverCaveRoom3.asm` and the `credits` opcode it ends
on - the last scripted event in the game.

Conventions reminder: disassembly paths are relative to the pokegold checkout
root; port paths are relative to this repo root; coordinates are the raw asm
values, i.e. **map cell coordinates**, 0-based from the map's top-left, the same
space `warp_event` / `bg_event` / `coord_event` use. `object_event` rows are
written in that same space (the `+ 4` in the `object_event` macro,
`macros/scripts/maps.asm` line 130, is the internal RAM border offset, not
something you add when reading the file).

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 0 | `MAP_ROUTE_28` | `maps/Route28.asm` (previous section) | `VictoryRoadGate` warps 7/8 at (1,7)/(2,7) | west map connection | "Head west and up from there and you'll be on Mt. Silver." Route 28 itself belongs to the previous section; only the hop off its west edge is in scope here. |
| 1 | `MAP_SILVER_CAVE_OUTSIDE` | `maps/SilverCaveOutside.asm` | east connection from `Route28` (`data/maps/attributes.asm:165`, `connection east, Route28, ROUTE_28, 9`) | warp 2 at (18,11) | Arrive on Mt. Silver; `MAPCALLBACK_NEWMAP` registers the fly point. Optional detour into the Pokémon Center. |
| 2 | `MAP_SILVER_CAVE_POKECENTER_1F` | `maps/SilverCavePokecenter1F.asm` | `SilverCaveOutside` warp 1 at (23,19) | warps 1/2 at (3,7)/(4,7) | Heal before the climb; the granny is pure flavour. |
| 3 | `MAP_SILVER_CAVE_ROOM_1` | `maps/SilverCaveRoom1.asm` | `SilverCaveOutside` warp 2 at (18,11) | warp 2 at (15,1) | "When you get in, use HM Flash." Escape Rope, X Accuracy, Max Elixer, two hidden items. |
| 4 | `MAP_SILVER_CAVE_ROOM_2` | `maps/SilverCaveRoom2.asm` | `SilverCaveRoom1` warp 2 at (15,1) -> lands on warp 1 at (17,31) | warp 2 at (11,5) | The Surf + Waterfall floor. Two side warps into `SilverCaveItemRooms`. |
| 5 | `MAP_SILVER_CAVE_ITEM_ROOMS` | `maps/SilverCaveItemRooms.asm` | `SilverCaveRoom2` warp 3 at (13,21) or warp 4 at (23,3) | warps 1/2 at (13,3)/(7,15) | "use Surf on the lake, and then use Waterfall, you can go through an entrance to grab a Full Restore." Two *disconnected* rooms in one map. |
| 6 | `MAP_SILVER_CAVE_ROOM_3` | `maps/SilverCaveRoom3.asm` | `SilverCaveRoom2` warp 2 at (11,5) -> lands on warp 1 at (9,33) | (no exit warp other than back to Room 2) | "keep going up, and you'll find a trainer." Red at (9,10); beating him runs `credits`. |

After `credits` the game does not return to the overworld normally: `Script_credits`
(`engine/overworld/scripting.asm:2215`) farcalls `RedCredits`
(`engine/events/halloffame.asm:34`), which sets `wSpawnAfterChampion = SPAWN_RED`
and jumps to `Credits`. `FinishContinueFunction` (`engine/menus/intro_menu.asm`)
sees `SPAWN_RED` on the way back out and calls `SpawnAfterRed`, which sets
`wDefaultSpawnpoint = SPAWN_MT_SILVER` and `hMapEntryMethod = MAPSETUP_WARP`, i.e.
you respawn at `data/maps/spawn_points.asm` -> `spawn SILVER_CAVE_OUTSIDE, 23, 20`,
the cell directly below the Pokémon Center door.

---

## 2. Maps

### MAP_SILVER_CAVE_OUTSIDE

- Script: `maps/SilverCaveOutside.asm`
- Blocks: `maps/SilverCaveOutside.blk` (20 x 18 blocks = 40 x 36 cells)
- Header: `data/maps/maps.asm:397` ->
  `map SilverCaveOutside, TILESET_KANTO, TOWN, LANDMARK_SILVER_CAVE, MUSIC_INDIGO_PLATEAU, FALSE, PALETTE_AUTO, FISHGROUP_POND`
  (fields per the `map` macro at `data/maps/maps.asm:1`: tileset, environment,
  location, music, phone-service flag, time-of-day palette, fishing group)
- Dimensions / attributes: `constants/map_constants.asm:367`
  (`map_const SILVER_CAVE_OUTSIDE, 20, 18`), group `SILVER` = 19, map id 2
- Connections: `data/maps/attributes.asm:164-165` -
  `map_attributes SilverCaveOutside, SILVER_CAVE_OUTSIDE, $2c` /
  `connection east, Route28, ROUTE_28, 9`. No north/south/west connection.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 23 | 19 | `SILVER_CAVE_POKECENTER_1F` | 1 |
| 2 | 18 | 11 | `SILVER_CAVE_ROOM_1` | 1 |

**Coord events** (`def_coord_events`)

None (the `def_coord_events` block is empty).

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 24 | 19 | `BGEVENT_READ` | `MtSilverPokecenterSign` -> `jumpstd PokecenterSignScript` |
| 17 | 13 | `BGEVENT_READ` | `MtSilverSign` -> `MtSilverSignText` ("MT.SILVER") |
| 9 | 25 | `BGEVENT_ITEM` | `SilverCaveOutsideHiddenFullRestore` -> `hiddenitem FULL_RESTORE, EVENT_SILVER_CAVE_OUTSIDE_HIDDEN_FULL_RESTORE` |

**Object events** (`def_object_events`)

None. `def_object_events` is the last line of the file with no rows after it -
there is not a single NPC or item ball on the outdoor map.

**Scripts of interest**

- `SilverCaveOutside_MapScripts` (`47`-bank sibling; symbol `49:5f15`) has an
  empty `def_scene_scripts` and one callback:
  `callback MAPCALLBACK_NEWMAP, SilverCaveOutsideFlypointCallback`.
- `SilverCaveOutsideFlypointCallback` (`49:5f1a`) is two opcodes:
  `setflag ENGINE_FLYPOINT_SILVER_CAVE` / `endcallback`. Simply *entering* the
  map unlocks Fly to Mt. Silver; there is no NPC or sign to talk to.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_SILVER_CAVE` | `constants/engine_flags.asm:90` | set by `SilverCaveOutsideFlypointCallback` | Fly destination `LANDMARK_SILVER_CAVE` (`data/maps/flypoints.asm:16` -> `SPAWN_MT_SILVER`) becomes selectable. Postcondition of first entry. |
| `EVENT_SILVER_CAVE_OUTSIDE_HIDDEN_FULL_RESTORE` | `constants/event_flags.asm:194` | `hiddenitem` at bg_event (9,25) | One-shot guard on the hidden Full Restore. |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `FULL_RESTORE` | hidden, needs a face-and-A or ITEMFINDER sweep at (9,25) | `bg_event 9, 25, BGEVENT_ITEM, SilverCaveOutsideHiddenFullRestore` | `EVENT_SILVER_CAVE_OUTSIDE_HIDDEN_FULL_RESTORE` |

**Trainers**

None.

**Wild encounters**

`data/wild/johto_grass.asm:2319`, `def_grass_wildmons SILVER_CAVE_OUTSIDE`,
encounter rate `10 percent` for morn/day/nite alike. Gold column
(`IF DEF(_GOLD)`); the Silver column swaps `URSARING` -> `DONPHAN` and is
otherwise identical.

| slot | morn | day | nite |
|---|---|---|---|
| 1 | 41 TANGELA | 41 TANGELA | 41 TANGELA |
| 2 | 42 PONYTA | 42 PONYTA | 42 PONYTA |
| 3 | 42 URSARING (Silver: DONPHAN) | 42 URSARING (Silver: DONPHAN) | 42 URSARING (Silver: DONPHAN) |
| 4 | 44 RAPIDASH | 44 RAPIDASH | 44 RAPIDASH |
| 5 | 41 DODUO | 41 DODUO | 38 SNEASEL |
| 6 | 43 DODRIO | 43 DODRIO | 42 SNEASEL |
| 7 | 43 DODRIO | 43 DODRIO | 42 SNEASEL |

Water (`data/wild/johto_water.asm:271`, `def_water_wildmons SILVER_CAVE_OUTSIDE`,
`2 percent`): 35 POLIWHIRL / 40 POLIWHIRL / 35 POLIWAG.
Fishing group `FISHGROUP_POND` (`data/wild/fish.asm:15`). Headbutt:
`data/wild/treemon_maps.asm:39` -> `TREEMON_SET_NONE`, so no headbutt table.

### MAP_SILVER_CAVE_POKECENTER_1F

- Script: `maps/SilverCavePokecenter1F.asm`
- Blocks: `maps/SilverCavePokecenter1F.blk` (symbol `2b:42e8 SilverCavePokecenter1F_Blocks`)
- Header: `data/maps/maps.asm:398` ->
  `map SilverCavePokecenter1F, TILESET_POKECENTER, INDOOR, LANDMARK_SILVER_CAVE, MUSIC_POKEMON_CENTER, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:368` (`map_const SILVER_CAVE_POKECENTER_1F, 5, 4`), group `SILVER` = 19, map id 3
- Connections: none

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `SILVER_CAVE_OUTSIDE` | 1 |
| 2 | 4 | 7 | `SILVER_CAVE_OUTSIDE` | 1 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

**Coord events** / **BG events**: both blocks are empty.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `SILVERCAVEPOKECENTER1F_NURSE` | `SPRITE_NURSE` | 3 | 1 | `SPRITEMOVEDATA_STANDING_DOWN`, radius 0/0, hours -1/-1, pal 0 | `OBJECTTYPE_SCRIPT` | `SilverCavePokecenter1FNurseScript` (`jumpstd PokecenterNurseScript`) | -1 (always) |
| `SILVERCAVEPOKECENTER1F_GRANNY` | `SPRITE_GRANNY` | 1 | 5 | `SPRITEMOVEDATA_STANDING_LEFT`, radius 2/1, hours -1/-1, pal 0 | `OBJECTTYPE_SCRIPT` | `SilverCavePokecenter1FGrannyScript` (`jumptextfaceplayer`) | -1 (always) |

**Flags and events / Items / Trainers**: none. **Wild encounters**: none.

### MAP_SILVER_CAVE_ROOM_1

- Script: `maps/SilverCaveRoom1.asm` (symbols `47:41e9 SilverCaveRoom1_MapScripts`, `47:41f7 SilverCaveRoom1_MapEvents`)
- Blocks: `maps/SilverCaveRoom1.blk` (10 x 18 blocks = 20 x 36 cells)
- Header: `data/maps/maps.asm:144` ->
  `map SilverCaveRoom1, TILESET_DARK_CAVE, CAVE, LANDMARK_SILVER_CAVE, MUSIC_LIGHTHOUSE, TRUE, PALETTE_DARK, FISHGROUP_LAKE`
  (the `TRUE` is the phone-service flag: no phone calls in here)
- Dimensions: `constants/map_constants.asm:131` (`map_const SILVER_CAVE_ROOM_1, 10, 18`), group `DUNGEONS` = 3, map id 66
- Connections: none (dungeon interior)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 33 | `SILVER_CAVE_OUTSIDE` | 2 |
| 2 | 15 | 1 | `SILVER_CAVE_ROOM_2` | 1 |

**Coord events** (`def_coord_events`)

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 16 | 23 | `BGEVENT_ITEM` | `SilverCaveRoom1HiddenDireHit` -> `hiddenitem DIRE_HIT, EVENT_SILVER_CAVE_ROOM_1_HIDDEN_DIRE_HIT` |
| 17 | 12 | `BGEVENT_ITEM` | `SilverCaveRoom1HiddenUltraBall` -> `hiddenitem ULTRA_BALL, EVENT_SILVER_CAVE_ROOM_1_HIDDEN_ULTRA_BALL` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `SILVERCAVEROOM1_POKE_BALL1` | `SPRITE_POKE_BALL` | 4 | 9 | `SPRITEMOVEDATA_STILL`, radius 0/0, hours -1/-1, pal 0 | `OBJECTTYPE_ITEMBALL` | `SilverCaveRoom1MaxElixer` (`itemball MAX_ELIXER`) | `EVENT_SILVER_CAVE_ROOM_1_MAX_ELIXER` |
| `SILVERCAVEROOM1_POKE_BALL2` | `SPRITE_POKE_BALL` | 15 | 29 | `SPRITEMOVEDATA_STILL`, radius 0/0, hours -1/-1, pal 0 | `OBJECTTYPE_ITEMBALL` | `SilverCaveRoom1XAccuracy` (`itemball X_ACCURACY`) | `EVENT_SILVER_CAVE_ROOM_1_X_ACCURACY` |
| `SILVERCAVEROOM1_POKE_BALL3` | `SPRITE_POKE_BALL` | 5 | 30 | `SPRITEMOVEDATA_STILL`, radius 0/0, hours -1/-1, pal 0 | `OBJECTTYPE_ITEMBALL` | `SilverCaveRoom1EscapeRope` (`itemball ESCAPE_ROPE`) | `EVENT_SILVER_CAVE_ROOM_1_ESCAPE_ROPE` |

**Scripts of interest**

`SilverCaveRoom1_MapScripts` has an empty `def_scene_scripts` and an empty
`def_callbacks`. Nothing scripted happens on this floor; the three labels above
are two-byte `itemball` payloads, not scripts (the `itemball`/`hiddenitem`
macros lay down data that the object/bg dispatcher reads, they are not `ScriptVM`
entry points).

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_SILVER_CAVE_ROOM_1_MAX_ELIXER` | `constants/event_flags.asm:1082` | object_event row (hide-when-set) | Set once the ball at (4,9) is taken. |
| `EVENT_SILVER_CAVE_ROOM_1_X_ACCURACY` | `constants/event_flags.asm:1083` | object_event row | Ball at (15,29). |
| `EVENT_SILVER_CAVE_ROOM_1_ESCAPE_ROPE` | `constants/event_flags.asm:1084` | object_event row | Ball at (5,30). |
| `EVENT_SILVER_CAVE_ROOM_1_HIDDEN_DIRE_HIT` | `constants/event_flags.asm:164` | `hiddenitem` | Hidden Dire Hit at (16,23). |
| `EVENT_SILVER_CAVE_ROOM_1_HIDDEN_ULTRA_BALL` | `constants/event_flags.asm:165` | `hiddenitem` | Hidden Ultra Ball at (17,12). |

Polarity note that matters for every object row in this section:
`CheckObjectFlag` (`engine/overworld/map_objects_2.asm:31-58`) masks (hides) the
object when its `MAPOBJECT_EVENT_FLAG` is **set**, and `Script_disappear`
(`engine/overworld/scripting.asm:887`) is exactly "set that flag". So a set flag
means gone, a clear flag means present.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `MAX_ELIXER` | item ball at (4,9) | `SilverCaveRoom1MaxElixer` | `EVENT_SILVER_CAVE_ROOM_1_MAX_ELIXER` |
| `X_ACCURACY` | item ball at (15,29) | `SilverCaveRoom1XAccuracy` | `EVENT_SILVER_CAVE_ROOM_1_X_ACCURACY` |
| `ESCAPE_ROPE` | item ball at (5,30) | `SilverCaveRoom1EscapeRope` | `EVENT_SILVER_CAVE_ROOM_1_ESCAPE_ROPE` |
| `DIRE_HIT` | hidden at (16,23) | bg_event | `EVENT_SILVER_CAVE_ROOM_1_HIDDEN_DIRE_HIT` |
| `ULTRA_BALL` | hidden at (17,12) | bg_event | `EVENT_SILVER_CAVE_ROOM_1_HIDDEN_ULTRA_BALL` |

**Trainers**: none.

**Wild encounters**

`data/wild/johto_grass.asm:1297`, `def_grass_wildmons SILVER_CAVE_ROOM_1`,
`6 percent` morn/day/nite. All three time slices are identical here.

| slot | all times (Gold) | Silver difference |
|---|---|---|
| 1 | 42 ONIX | - |
| 2 | 44 URSARING | 44 DONPHAN |
| 3 | 43 GRAVELER | - |
| 4 | 43 GRAVELER | - |
| 5 | 45 GOLBAT | - |
| 6 | 20 LARVITAR | - |
| 7 | 15 LARVITAR | - |

No water table for Room 1. Fishing group `FISHGROUP_LAKE`.

**Terrain notes** (derived by expanding `maps/SilverCaveRoom1.blk` through
`data/tilesets/cave_collision.asm`; `TilesetDarkCaveColl` and `TilesetCaveColl`
are the same label pair in `gfx/tilesets.asm:106-107`, so the dark-cave floor
uses the ordinary cave collision table)

- Entry from outside lands on (9,33); a short corridor runs up to the long
  east-west floor strip at y=32 spanning x=2..16.
- The Escape Rope at (5,30) sits **on a ledge cell**. Gen 2 ledges are not
  "hop over the tile in front"; `.TryJump`
  (`engine/overworld/player_movement.asm:354`) reads `wPlayerTileCollision`, the
  tile the player is *standing on*, so you walk onto the ledge row, grab the
  ball, then press the ledge's direction (`DOWN` for `COLL_HOP_DOWN`) to jump
  two cells down onto y=32. That is exactly the walkthrough's "drop down the
  ledge to get the Escape Rope. Jump back down."
- (11,27) and (13,27) carry `WARP_CARPET_DOWN` collision but there is **no**
  `warp_event` at either coordinate. Treat them as decoration, not exits.

### MAP_SILVER_CAVE_ROOM_2

- Script: `maps/SilverCaveRoom2.asm` (symbols `47:4238`, `47:423d`)
- Blocks: `maps/SilverCaveRoom2.blk` (15 x 18 blocks = 30 x 36 cells)
- Header: `data/maps/maps.asm:145` ->
  `map SilverCaveRoom2, TILESET_CAVE, CAVE, LANDMARK_SILVER_CAVE, MUSIC_LIGHTHOUSE, TRUE, PALETTE_NITE, FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:132` (`map_const SILVER_CAVE_ROOM_2, 15, 18`), group `DUNGEONS` = 3, map id 67
- Connections: none

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 17 | 31 | `SILVER_CAVE_ROOM_1` | 2 |
| 2 | 11 | 5 | `SILVER_CAVE_ROOM_3` | 1 |
| 3 | 13 | 21 | `SILVER_CAVE_ITEM_ROOMS` | 1 |
| 4 | 23 | 3 | `SILVER_CAVE_ITEM_ROOMS` | 2 |

**Coord events** (`def_coord_events`)

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 14 | 31 | `BGEVENT_ITEM` | `SilverCaveRoom2HiddenMaxPotion` -> `hiddenitem MAX_POTION, EVENT_SILVER_CAVE_ROOM_2_HIDDEN_MAX_POTION` |

**Object events**: none (`def_object_events` is the last line, no rows).

**Scripts of interest**

Empty `def_scene_scripts`, empty `def_callbacks`. Room 2 is pure terrain.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_SILVER_CAVE_ROOM_2_HIDDEN_MAX_POTION` | `constants/event_flags.asm:166` | `hiddenitem` at (14,31) | One-shot; the tile is right next to the Room 1 entrance warp at (17,31). |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `MAX_POTION` | hidden at (14,31) | bg_event | `EVENT_SILVER_CAVE_ROOM_2_HIDDEN_MAX_POTION` |

**Trainers**: none.

**Wild encounters**

Grass: `data/wild/johto_grass.asm:1352`, `def_grass_wildmons SILVER_CAVE_ROOM_2`,
`6 percent` morn/day/nite.

| slot | morn | day | nite |
|---|---|---|---|
| 1 | 45 QUAGSIRE | 45 QUAGSIRE | 45 QUAGSIRE |
| 2 | 48 GOLDUCK | 48 GOLDUCK | 48 GOLDUCK |
| 3 | 47 URSARING (Silver: DONPHAN) | 47 URSARING (Silver: DONPHAN) | 47 URSARING (Silver: DONPHAN) |
| 4 | 45 QUAGSIRE | 45 QUAGSIRE | **45 MISDREAVUS** |
| 5 | 48 GOLBAT | 48 GOLBAT | 48 GOLBAT |
| 6 | 20 LARVITAR | 20 LARVITAR | 20 LARVITAR |
| 7 | 15 LARVITAR | 15 LARVITAR | 15 LARVITAR |

Water: `data/wild/johto_water.asm:100`, `def_water_wildmons SILVER_CAVE_ROOM_2`,
`2 percent`: 35 SEAKING / 40 SEAKING / 35 GOLDEEN. Fishing group `FISHGROUP_LAKE`.

**Terrain notes** (expanded from `maps/SilverCaveRoom2.blk` +
`data/tilesets/cave_collision.asm`; both item-room warps are behind water)

- You arrive at (17,31) and stand on the south floor shelf, y=30..31, x=14..24.
- **South lake / Max Revive branch.** Surf west from (14,30) onto the water at
  x=4..13, y=30..31. The waterfall band is x=6..11, y=28..29; Waterfall up from
  it reaches the water pocket at y=22..27. Come ashore at (11,25), walk north to
  the floor pocket x=9..14, y=22..24, and step onto the warp at **(13,21)** ->
  `SILVER_CAVE_ITEM_ROOMS` warp 1 -> `MAX_REVIVE`.
- **North lake / Full Restore branch.** From the mid-map floor at (11,11) step
  down onto the water at (11,12); the lake runs x=10..13 y=12..15 and x=12..21
  y=14..15. The second waterfall band is x=18..21, y=10..13; Waterfall up lands
  in the pool at x=18..21, y=8..9. Come ashore at (21,7), walk up through the
  x=19..24 chamber to (23,4), and step onto the warp at **(23,3)** ->
  `SILVER_CAVE_ITEM_ROOMS` warp 2 -> `FULL_RESTORE`. This is the walkthrough's
  "use Surf on the lake, and then use Waterfall ... an entrance to grab a Full
  Restore."
- The Room 3 entrance is the `CAVE` cell at (11,5), reached on foot from the
  same north-central floor.
- The waterfall band at x=4..7, y=0..5 in the north-west corner has water below
  it (y=6..7) that is walled off on every side. It looks decorative; nothing in
  the asm routes through it.

### MAP_SILVER_CAVE_ITEM_ROOMS

- Script: `maps/SilverCaveItemRooms.asm` (symbols `47:42b7`, `47:42bd`)
- Blocks: `maps/SilverCaveItemRooms.blk` (10 x 9 blocks = 20 x 18 cells)
- Header: `data/maps/maps.asm:147` ->
  `map SilverCaveItemRooms, TILESET_CAVE, CAVE, LANDMARK_SILVER_CAVE, MUSIC_LIGHTHOUSE, TRUE, PALETTE_NITE, FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:134` (`map_const SILVER_CAVE_ITEM_ROOMS, 10, 9`), group `DUNGEONS` = 3, map id 69
- Connections: none

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 13 | 3 | `SILVER_CAVE_ROOM_2` | 3 |
| 2 | 7 | 15 | `SILVER_CAVE_ROOM_2` | 4 |

**Coord events** / **BG events**: both empty.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `SILVERCAVEITEMROOMS_POKE_BALL1` | `SPRITE_POKE_BALL` | 6 | 3 | `SPRITEMOVEDATA_STILL`, radius 0/0, hours -1/-1, pal 0 | `OBJECTTYPE_ITEMBALL` | `SilverCaveItemRoomsMaxRevive` (`itemball MAX_REVIVE`) | `EVENT_SILVER_CAVE_ITEM_ROOMS_MAX_REVIVE` |
| `SILVERCAVEITEMROOMS_POKE_BALL2` | `SPRITE_POKE_BALL` | 15 | 11 | `SPRITEMOVEDATA_STILL`, radius 0/0, hours -1/-1, pal 0 | `OBJECTTYPE_ITEMBALL` | `SilverCaveItemRoomsFullRestore` (`itemball FULL_RESTORE`) | `EVENT_SILVER_CAVE_ITEM_ROOMS_FULL_RESTORE` |

**Scripts of interest**

Empty scene scripts and callbacks; the two labels are `itemball` payloads.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_SILVER_CAVE_ITEM_ROOMS_MAX_REVIVE` | `constants/event_flags.asm:1085` | object_event row | Ball at (6,3), north room. |
| `EVENT_SILVER_CAVE_ITEM_ROOMS_FULL_RESTORE` | `constants/event_flags.asm:1086` | object_event row | Ball at (15,11), south room. |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `MAX_REVIVE` | item ball at (6,3) | `SilverCaveItemRoomsMaxRevive` | `EVENT_SILVER_CAVE_ITEM_ROOMS_MAX_REVIVE` |
| `FULL_RESTORE` | item ball at (15,11) | `SilverCaveItemRoomsFullRestore` | `EVENT_SILVER_CAVE_ITEM_ROOMS_FULL_RESTORE` |

**Trainers**: none.

**Wild encounters**

`data/wild/johto_grass.asm:1462`, `def_grass_wildmons SILVER_CAVE_ITEM_ROOMS`,
`6 percent`. Same shape as Room 2 but the night swap lands in slot 1 instead of
slot 4: morn/day slot 1 is 45 QUAGSIRE, nite slot 1 is **45 MISDREAVUS**; slot 4
stays 45 QUAGSIRE at all times. Slots 2/3/5/6/7 are 48 GOLDUCK / 47 URSARING
(Silver: DONPHAN) / 48 GOLBAT / 20 LARVITAR / 15 LARVITAR. No water table.

**Terrain notes**

The map is two disconnected chambers in one 20 x 18 grid, which is why both of
its warps go back to Room 2:

- North chamber, floor y=2..3 spanning x=4..15, warp 1 at (13,3), Max Revive at (6,3).
- South chamber, floor y=10..15 spanning roughly x=4..17, warp 2 at (7,15), Full
  Restore at (15,11).

### MAP_SILVER_CAVE_ROOM_3

- Script: `maps/SilverCaveRoom3.asm` (symbols `47:425c SilverCaveRoom3_MapScripts`, `47:425e Red`, `47:429f SilverCaveRoom3_MapEvents`)
- Blocks: `maps/SilverCaveRoom3.blk` (10 x 18 blocks = 20 x 36 cells)
- Header: `data/maps/maps.asm:146` ->
  `map SilverCaveRoom3, TILESET_CAVE, CAVE, LANDMARK_SILVER_CAVE, MUSIC_LIGHTHOUSE, TRUE, PALETTE_DAY, FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:133` (`map_const SILVER_CAVE_ROOM_3, 10, 18`), group `DUNGEONS` = 3, map id 68
- Connections: none

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 33 | `SILVER_CAVE_ROOM_2` | 2 |

**Coord events** (`def_coord_events`)

None. Red is *not* a trip-wire; you have to walk into him.

**BG events** (`def_bg_events`)

None.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `SILVERCAVEROOM3_RED` | `SPRITE_RED` | 9 | 10 | `SPRITEMOVEDATA_STANDING_UP`, radius 0/0, hours -1/-1, pal `PAL_NPC_RED` | `OBJECTTYPE_SCRIPT` (sight range 0) | `Red` | `EVENT_RED_IN_MT_SILVER` |

Note the type: Red is `OBJECTTYPE_SCRIPT`, **not** `OBJECTTYPE_TRAINER`. He has
no sight cone, no `loadtrainer` in his object row, and no "trainer spotted"
exclamation. You must stand next to him and press A.

**Scripts of interest**

`Red` (`maps/SilverCaveRoom3.asm:9`, symbol `47:425e`), in order:

1. `special FadeOutMusic`
2. `faceplayer` / `opentext` / `writetext RedSeenText` ("…" / "…") / `waitbutton` / `closetext`
3. `winlosstext RedWinLossText, RedWinLossText` - the same "…" text for both outcomes
4. `loadtrainer RED, RED1`
5. `startbattle`
6. `dontrestartmapmusic`
7. `reloadmapafterbattle`
8. `special FadeOutMusic`
9. `opentext` / `writetext RedLeavesText` / `waitbutton` / `closetext`
10. `special FadeOutToBlack` / `special ReloadSpritesNoPalettes`
11. `disappear SILVERCAVEROOM3_RED` - sets `EVENT_RED_IN_MT_SILVER`
12. `pause 15` / `special FadeInFromBlack` / `pause 30`
13. `special HealParty`
14. `reanchormap`
15. `credits`
16. `end`

There is no `checkevent`/`iftrue` guard anywhere in the script: the object flag
is the only gate, and the script is unconditional once you talk to him. There is
also no `applymovement` - "He flies away" in the walkthrough is prose; the asm
just fades to black and `disappear`s him.

`credits` is opcode `$a0` (`engine/overworld/scripting.asm:227`).
`Script_credits` (`engine/overworld/scripting.asm:2215`) farcalls `RedCredits`
(`engine/events/halloffame.asm:34`), which fades to white, sets
`wSpawnAfterChampion = SPAWN_RED`, and jumps into `Credits`; on return the
script is force-ended and `MAPSTATUS_DONE` is loaded.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_RED_IN_MT_SILVER` | `constants/event_flags.asm:1284` | **set** by `InitializeEventsScript` (`engine/events/std_scripts.asm:526`) at new game; **cleared** by `maps/HallOfFame.asm:36`; **set** again by `disappear SILVERCAVEROOM3_RED` inside `Red` | Set = Red hidden (see the `CheckObjectFlag` polarity note above). So: absent on a fresh save, present after your first Hall of Fame induction, gone once beaten, and present again after every subsequent Hall of Fame. That is the asm behind "If you want to fight Red again, beat the Elite Four again and then he'll be back at Mt. Silver." |

No `SCENE_*` values: `def_scene_scripts` is empty for this map (`wSilverCaveRoom3SceneID` exists in WRAM at `01:d6ea` but nothing writes a non-zero scene to it).

**Items**: none.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `RED1` | `RED` (`trainerclass RED ; 3f` = 63, `constants/trainer_constants.asm:637`) | 1 | `RedGroup` (`data/trainers/parties.asm:3143`, symbol `0e:75d5`) | `Red` | No phone number, no rematch table; he re-appears only via `EVENT_RED_IN_MT_SILVER` being cleared at the Hall of Fame |

`RedGroup`, `db "RED@", TRAINERTYPE_MOVES` - four explicit moves per mon, in
send-out order:

| # | level | species | moves |
|---|---|---|---|
| 1 | 81 | PIKACHU | CHARM, QUICK_ATTACK, THUNDERBOLT, THUNDER |
| 2 | 73 | ESPEON | MUD_SLAP, REFLECT, SWIFT, PSYCHIC_M |
| 3 | 75 | SNORLAX | AMNESIA, SNORE, REST, BODY_SLAM |
| 4 | 77 | VENUSAUR | SUNNY_DAY, GIGA_DRAIN, SYNTHESIS, SOLARBEAM |
| 5 | 77 | CHARIZARD | FLAMETHROWER, WING_ATTACK, SLASH, FIRE_SPIN |
| 6 | 77 | BLASTOISE | RAIN_DANCE, SURF, BLIZZARD, WHIRLPOOL |

Class attributes (`data/trainers/attributes.asm:377-381`, the `; Red` block):

- items: `FULL_RESTORE, FULL_RESTORE` - **two** slots, not three
- base reward: `25`
- AI: `AI_BASIC | AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_CAUTIOUS | AI_STATUS | AI_RISKY`
- item/switch: `CONTEXT_USE | SWITCH_SOMETIMES`

Prize money: `ComputeTrainerReward`
(`engine/battle/read_trainer_party.asm:300`) computes
`wBattleReward = base_reward * wCurPartyLevel`, and `wCurPartyLevel` at that
point is the level of the **last** party row, i.e. Blastoise's 77. So
`25 * 77 = 1925`. `WinTrainerBattle` (`engine/battle/core.asm:2292`) then pays it
out with `ld c, 4` - four additions - giving **7700**, which matches the
walkthrough's "You get: 7700G" exactly. (Amulet Coin doubles it via
`.DoubleReward` before the split; Mom's savings take a share of the four
quarters.)

**Wild encounters**

`data/wild/johto_grass.asm:1407`, `def_grass_wildmons SILVER_CAVE_ROOM_3`,
`6 percent`, identical across morn/day/nite:

| slot | species |
|---|---|
| 1 | 51 GOLBAT |
| 2 | 48 ONIX |
| 3 | 48 GOLBAT |
| 4 | 50 URSARING (Silver: DONPHAN) |
| 5 | 51 GOLDUCK |
| 6 | 20 LARVITAR |
| 7 | 15 LARVITAR |

No water table for Room 3.

**Terrain notes**

A single long north-south corridor. From the entrance warp at (9,33) the path
runs straight up the x=9..10 column to the wide chamber at y=9..16, then to the
top room; Red stands at (9,10), squarely in the corridor mouth, so you cannot
pass him without triggering the fight. (11,33) also carries `WARP_CARPET_DOWN`
collision but has no `warp_event`.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Reaching Route 28 at all (the north passage of the gate) | `maps/VictoryRoadGate.asm:19` `VictoryRoadGateBadgeCheckScript` / `VictoryRoadGateOfficerScript` (symbols `5f:4fdc` / `5f:4fe2`), fired by `coord_event 10, 11, SCENE_VICTORYROADGATE_BADGE_CHECK, VictoryRoadGateBadgeCheckScript` | `readvar VAR_BADGES` / `ifgreater NUM_JOHTO_BADGES - 1` - strictly more than 7 Johto badges | On pass: `setscene SCENE_VICTORYROADGATE_NOOP`, so the check never fires again. On fail: `applymovement PLAYER, VictoryRoadGateStepDownMovement` shoves you back one step. Note the west warps to Route 28 at (1,7)/(2,7) are *below* the trip-wire row; the badge scene guards the north corridor. |
| Mt. Silver "opened" flavour | `maps/OaksLab.asm:18-45` `Oak` -> `.CheckBadges` / `.OpenMtSilver` | `readvar VAR_BADGES` / `ifequal NUM_BADGES` (all 16) when you talk to Prof. Oak | `setevent EVENT_OPENED_MT_SILVER` (`constants/event_flags.asm:1265`). The only other reader is `maps/VictoryRoadGate.asm:118`, where it is the hide-flag of the left Black Belt at (7,5). **No script in any Mt. Silver map reads it**, and it does not appear in a `checkevent` on any warp. |
| Room 1 darkness | `engine/tilesets/timeofday_pals.asm:113` `ReplaceTimeOfDayPals` -> `.NeedsFlash`, driven by `PALETTE_DARK` in `data/maps/maps.asm:144` | `STATUSFLAGS_FLASH_F` in `wStatusFlags`, set by `BlindingFlash` (`engine/events/field_moves.asm:12`) | Use HM05 Flash. `FlashFunction` (`engine/events/overworld.asm:271`) needs `ENGINE_ZEPHYRBADGE` **and** `wTimeOfDayPalset == DARKNESS_PALSET`. Rooms 2/3 and the Item Rooms are `PALETTE_NITE`/`PALETTE_DAY`, so Flash is only needed for Room 1. It is a visibility gate, not a movement gate. |
| Room 2 lakes | `SurfFunction.TrySurf` (`engine/events/overworld.asm:322-345`) | `ENGINE_FOGBADGE` + a party mon with SURF + facing a `WATER_TILE` | Fog Badge (Morty). Blocks both Item Rooms entrances and everything past y<30 on the west lake. |
| Room 2 waterfalls | `WaterfallFunction.TryWaterfall` (`engine/events/overworld.asm:611`) and `TryWaterfallOW` (`engine/events/overworld.asm:687`), gated by `CheckMapCanWaterfall` | `ENGINE_RISINGBADGE`, party mon with WATERFALL, player facing UP, and `wTileUp` a waterfall tile | Rising Badge (Clair). Without it neither item room is reachable: the north branch (Full Restore at (23,3)) and the south branch (Max Revive at (13,21)) both sit above a waterfall band. |
| Red himself | `maps/SilverCaveRoom3.asm:62` object row's event flag | `EVENT_RED_IN_MT_SILVER` must be **clear** | Cleared by `maps/HallOfFame.asm:36`, i.e. by completing the Elite Four / Lance and being inducted. Before that the object is masked by `CheckObjectFlag` and Room 3 is an empty corridor. |

Not a gate, worth knowing: nothing in this section checks Strength, Whirlpool,
Cut or Rock Smash. The walkthrough's "bring all the HMs" is advice, not a
requirement - Flash, Surf and Waterfall are the only three the asm cares about,
and Flash only for comfort.

---

## 4. Bot checklist

Preconditions for the whole section: `EVENT_BEAT_ELITE_FOUR` set (Hall of Fame
done, which is what clears `EVENT_RED_IN_MT_SILVER`), 8 Johto badges for the
Victory Road Gate scene, `ENGINE_FOGBADGE` + `ENGINE_RISINGBADGE` for the item
rooms, `ENGINE_ZEPHYRBADGE` + Flash for Room 1 visibility.

1. `MAP_VICTORY_ROAD_GATE` - walk onto (10,11) if the scene is still
   `SCENE_VICTORYROADGATE_BADGE_CHECK`; talk through
   `VictoryRoadGateOfficerScript`. Pre: `VAR_BADGES > 7`. Post: scene becomes
   `SCENE_VICTORYROADGATE_NOOP`. Then take warp 7 or 8 at (1,7)/(2,7) to
   `MAP_ROUTE_28`.
2. `MAP_ROUTE_28` - cross west onto the map connection. Post: now on
   `MAP_SILVER_CAVE_OUTSIDE`. (Route 28 body belongs to the previous section.)
3. `MAP_SILVER_CAVE_OUTSIDE` - entering fires
   `SilverCaveOutsideFlypointCallback`. Post: `ENGINE_FLYPOINT_SILVER_CAVE` set;
   Fly to `LANDMARK_SILVER_CAVE` now works, and the respawn point is (23,20).
4. `MAP_SILVER_CAVE_OUTSIDE` - optional: face (9,25) and press A (or run the
   ITEMFINDER) for the hidden `FULL_RESTORE`. Pre:
   `EVENT_SILVER_CAVE_OUTSIDE_HIDDEN_FULL_RESTORE` clear. Post: it is set.
5. `MAP_SILVER_CAVE_OUTSIDE` - optional heal: warp 1 at (23,19) ->
   `MAP_SILVER_CAVE_POKECENTER_1F`, talk to `SILVERCAVEPOKECENTER1F_NURSE` at
   (3,1), leave by warp 1 at (3,7).
6. `MAP_SILVER_CAVE_OUTSIDE` - step on warp 2 at (18,11). Post: on
   `MAP_SILVER_CAVE_ROOM_1` at (9,33).
7. `MAP_SILVER_CAVE_ROOM_1` - use Flash from the party menu (`FlashFunction`).
   Pre: `ENGINE_ZEPHYRBADGE`, HM05 on a party mon, `wTimeOfDayPalset ==
   DARKNESS_PALSET`. Post: `STATUSFLAGS_FLASH_F` set.
8. `MAP_SILVER_CAVE_ROOM_1` - walk to `SILVERCAVEROOM1_POKE_BALL3` at (5,30) and
   press A (approach along the ledge row from above, x=2..6 at y=30). Post:
   `ESCAPE_ROPE` in the bag, `EVENT_SILVER_CAVE_ROOM_1_ESCAPE_ROPE` set. Then
   press DOWN while standing on the ledge to hop to y=32.
9. `MAP_SILVER_CAVE_ROOM_1` - `SILVERCAVEROOM1_POKE_BALL2` at (15,29) ->
   `X_ACCURACY`, flag `EVENT_SILVER_CAVE_ROOM_1_X_ACCURACY`.
10. `MAP_SILVER_CAVE_ROOM_1` - `SILVERCAVEROOM1_POKE_BALL1` at (4,9) ->
    `MAX_ELIXER`, flag `EVENT_SILVER_CAVE_ROOM_1_MAX_ELIXER`.
11. `MAP_SILVER_CAVE_ROOM_1` - optional hidden items: (17,12) `ULTRA_BALL`,
    (16,23) `DIRE_HIT`.
12. `MAP_SILVER_CAVE_ROOM_1` - step on warp 2 at (15,1). Post: on
    `MAP_SILVER_CAVE_ROOM_2` at (17,31).
13. `MAP_SILVER_CAVE_ROOM_2` - optional hidden `MAX_POTION` at (14,31), two
    cells west of where you land.
14. `MAP_SILVER_CAVE_ROOM_2` (Full Restore branch) - walk to (11,11), face down,
    Surf onto (11,12). Follow the lake east to x=18..21 at y=14..15, face UP on
    y=10 and use Waterfall. Come ashore at (21,7), walk to (23,4), step up onto
    the warp at (23,3). Post: on `MAP_SILVER_CAVE_ITEM_ROOMS` at (7,15).
15. `MAP_SILVER_CAVE_ITEM_ROOMS` - `SILVERCAVEITEMROOMS_POKE_BALL2` at (15,11)
    -> `FULL_RESTORE`, flag `EVENT_SILVER_CAVE_ITEM_ROOMS_FULL_RESTORE`. Leave
    by warp 2 at (7,15).
16. `MAP_SILVER_CAVE_ROOM_2` (Max Revive branch, optional, not in the
    walkthrough) - from the landing shelf walk to (14,30), Surf west, Waterfall
    up the x=6..11 band at y=28..29, come ashore at (11,25), walk to (13,22) and
    step up onto the warp at (13,21). Take
    `SILVERCAVEITEMROOMS_POKE_BALL1` at (6,3) -> `MAX_REVIVE`. Leave by warp 1
    at (13,3).
17. `MAP_SILVER_CAVE_ROOM_2` - step on warp 2 at (11,5). Post: on
    `MAP_SILVER_CAVE_ROOM_3` at (9,33).
18. `MAP_SILVER_CAVE_ROOM_3` - walk north up the x=9..10 corridor to (9,11),
    face UP, press A on `SILVERCAVEROOM3_RED` at (9,10). Pre:
    `EVENT_RED_IN_MT_SILVER` clear. This runs `Red`.
19. Battle `RED` / `RED1`. Six mons, levels 81/73/75/77/77/77, two Full Restores
    on the AI. Post on victory: 7700 money (before Amulet Coin / Mom split),
    `EVENT_RED_IN_MT_SILVER` set by `disappear`, party healed by
    `special HealParty`, then `credits`.
20. After the credits the game re-enters at `SPAWN_MT_SILVER` =
    `SILVER_CAVE_OUTSIDE` (23,20) with `hMapEntryMethod = MAPSETUP_WARP`. Save
    here (the walkthrough's "After the credits roll, save").

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map headers / warps / bg events / object events for all six maps | `src/import/RomExtractorGen2.lua` (warp + coord + bg + object decode around lines 785-861 and 2959-2990) | implemented - the maps are decoded generically from the ROM, so no Silver Cave specific data is hand-written anywhere |
| `itemball` object rows (Escape Rope, X Accuracy, Max Elixer, Max Revive, Full Restore) | `src/import/RomExtractorGen2.lua:2874`, `:2968` (`readItemBall`) | implemented |
| `hiddenitem` bg rows (Full Restore, Dire Hit, Ultra Ball, Max Potion) | `src/world/gen2/HiddenItems.lua` | implemented |
| `MAPCALLBACK_NEWMAP` flypoint callback | `src/world/gen2/Map.lua` + driver `tests/drivers/gold_map_callbacks.lua` | implemented |
| `ENGINE_FLYPOINT_SILVER_CAVE` -> Fly destination | `src/world/gen2/FieldMoves.lua:355` (`LANDMARK_SILVER_CAVE` / `SPAWN_MT_SILVER` / flag 75), `src/ui/gen2/Pokegear.lua:1478` | implemented |
| Flash (dark-cave palette gate) | `src/world/gen2/FieldMoves.lua:465-475` (`flashFromMenu`), badge table at `:105` | implemented |
| Surf | `src/world/gen2/FieldMoves.lua:477-500`, `src/world/gen2/Permissions.lua` | implemented |
| Waterfall (`CheckMapCanWaterfall`, `.CheckContinueWaterfall`) | `src/world/gen2/FieldMoves.lua:253-266`, `:528-540` | implemented |
| Gen 2 ledge hop (`.TryJump` / `HI_NYBBLE_LEDGES`) - needed for the Escape Rope drop in Room 1 | no gen2 implementation found; `src/world/gen2/Player.lua` is a plain grid stepper and `src/world/gen2/Permissions.lua` only models LAND/WATER/WALL. `src/world/OverworldController.lua:1330` `checkLedgeHop` is the **Gen 1** model (`data/tilesets/ledge_tiles.asm`, standing-tile + front-tile pair) and does not match Gen 2's standing-tile-nybble rule | missing |
| `loadtrainer` / `startbattle` / `winlosstext` | `src/script/gen2/Vm.lua:806`, `:817`; opcodes in `src/script/gen2/Opcodes.lua:99-105` | implemented |
| `disappear` | `src/script/gen2/Opcodes.lua:115`, handled in `src/script/gen2/Vm.lua` | implemented |
| `special FadeOutMusic` / `FadeOutToBlack` / `FadeInFromBlack` / `ReloadSpritesNoPalettes` / `HealParty` | `src/script/gen2/Specials.lua:450`, `:999`, `:1001`, `:1025`, `:1066` | implemented |
| `credits` opcode as a terminal script op | `src/script/gen2/Opcodes.lua:172`, `:194` | implemented |
| Red-credits path and post-credits respawn at Mt. Silver | `src/core/gen2/HallOfFame.lua:48-53`, `:239-259` (`markRedCredits`, `POST_CREDITS_SPAWN.SPAWN_RED = "SPAWN_MT_SILVER"`), test `tests/gen2_halloffame_test.lua:171` | implemented |
| Credits reel itself | `src/ui/Credits.lua`, driver `tests/drivers/gold_halloffame_shots.lua` | implemented (shared with the Hall of Fame credits) |
| Prize money (base reward x last level, x4, Mom split) | `src/battle/gen2/Prize.lua` | implemented - the `ld c, 4` factor is modelled explicitly, which is what makes Red's 7700 come out right |
| Trainer AI item use (Red's two Full Restores) | `src/battle/gen2/Ai.lua:1294`, `:1369-1375` | implemented |
| Wild tables incl. the morn/day/nite split | `src/import/RomExtractorGen2.lua:3720-3845` (`JohtoGrassWildMons` / `JohtoWaterWildMons` / `FishGroups`) | implemented |
| Trainer parties incl. `RedGroup` | `src/import/RomExtractorGen2.lua:3859-4001` (`TrainerGroups`) | implemented |
| A driver that actually reaches Red | none - the closest are `tests/drivers/gold_trainer_smoke.lua` and `tests/drivers/gold_halloffame_shots.lua` | missing |

---

## 6. Unresolved / verify by hand

- **"Items in Mount Silver: Escape Rope, Full Restore, Protein."** There is no
  `PROTEIN` anywhere in `maps/SilverCaveOutside.asm`, `SilverCaveRoom1.asm`,
  `SilverCaveRoom2.asm`, `SilverCaveRoom3.asm` or `SilverCaveItemRooms.asm`. The
  full real list is Max Elixer, X Accuracy, Escape Rope, Max Revive, Full Restore
  (balls) plus hidden Full Restore, Dire Hit, Ultra Ball, Max Potion. The
  walkthrough's summary list is also missing the X Accuracy and Max Elixir it
  later tells you to pick up.
- **"Pokémon in Mount Silver: ... #232 Donphan"** - Donphan is the *Silver*
  column of every one of these `def_grass_wildmons` blocks. In Gold the same
  slots are Ursaring. Same file, `IF DEF(_GOLD)` / `ELIF DEF(_SILVER)`.
- **"Red will have three Full Restores"** - `data/trainers/attributes.asm:378`
  gives the RED class exactly two item slots, both `FULL_RESTORE`. Could not find
  a third anywhere.
- **Red's party order.** The walkthrough lists Pikachu, Espeon, Blastoise,
  Snorlax, Charizard, Venusaur. `RedGroup` orders them Pikachu, Espeon, Snorlax,
  Venusaur, Charizard, Blastoise. Only the lead matches. The listed EXP yields
  (1422 / 3081 / 3465 / 2475 / 3448 / 3432) are not stored anywhere as data -
  they are computed from base experience and level at runtime - so they could not
  be confirmed against a table.
- **"Espeon is a dark type that cannot be hit with ghost moves."** Espeon is
  Psychic in `data/pokemon/base_stats/espeon.asm`; the ghost-immunity claim
  describes Umbreon/Dark. Strategy prose, not asm, but a bot following it would
  make bad move choices.
- **"He flies away."** The `Red` script has no `applymovement` and no fly
  animation - `special FadeOutToBlack`, `disappear`, `special FadeInFromBlack`.
  Cosmetic discrepancy only.
- **Which of the two Item Rooms the walkthrough means.** The text mentions only
  the Full Restore, which I traced to `SilverCaveRoom2` warp 4 at (23,3) ->
  `SilverCaveItemRooms` warp 2 at (7,15). That mapping is derived from expanding
  `maps/SilverCaveRoom2.blk` and `maps/SilverCaveItemRooms.blk` through
  `data/tilesets/cave_collision.asm`, not from an explicit statement in any asm
  file. The Surf/Waterfall requirement on both branches comes from the same
  derivation. Worth confirming in-game before a bot commits to the route.
- **`EVENT_OPENED_MT_SILVER` does nothing on these maps.** The walkthrough (and
  common knowledge) says you need all 16 badges and a word with Prof. Oak to
  enter Mt. Silver. `maps/OaksLab.asm` does set the flag on 16 badges, but the
  only consumer in the whole tree is the hide-flag of a Black Belt in
  `maps/VictoryRoadGate.asm:118`. I could not find a `checkevent` on that flag
  guarding any warp, coord event or NPC on the Route 28 / Silver Cave path. If
  the 16-badge requirement is real it is enforced somewhere I did not locate -
  verify by hand before assuming a bot with 8 Johto badges can walk in.
- **Two `WARP_CARPET_DOWN` cells with no `warp_event`**: (11,27) and (13,27) in
  Room 1, and (11,33) in Room 3. Collision says "warp", the event table says
  nothing. Assumed decorative; not tested.

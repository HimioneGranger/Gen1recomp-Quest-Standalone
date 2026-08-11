# Section 20 - Saffron City Gym

Source: `../section-20-saffron-city-gym.txt` (the FAQ numbers this chapter "26 > Saffron City Gym")
Maps covered: `MAP_ROUTE_6`, `MAP_ROUTE_6_UNDERGROUND_PATH_ENTRANCE`, `MAP_ROUTE_6_SAFFRON_GATE`, `MAP_SAFFRON_CITY`, `MAP_MR_PSYCHICS_HOUSE`, `MAP_SILPH_CO_1F`, `MAP_SAFFRON_MAGNET_TRAIN_STATION`, `MAP_SAFFRON_MART`, `MAP_FIGHTING_DOJO`, `MAP_SAFFRON_GYM`, `MAP_SAFFRON_POKECENTER_1F`
Badges / key milestones in this section: MARSHBADGE (`ENGINE_MARSHBADGE`), TM29 Psychic, Up-Grade, Focus Band, `ENGINE_FLYPOINT_SAFFRON` unlocked on first entry to Saffron City.

Map group / id pairs a bot needs (from `constants/map_constants.asm`):

| Map constant | group | id |
|---|---|---|
| `MAP_ROUTE_6` | 12 (`VERMILION`) | 1 |
| `MAP_ROUTE_6_SAFFRON_GATE` | 12 | 12 |
| `MAP_ROUTE_6_UNDERGROUND_PATH_ENTRANCE` | 12 | 13 |
| `MAP_SAFFRON_CITY` | 25 (`SAFFRON`) | 2 |
| `MAP_FIGHTING_DOJO` | 25 | 3 |
| `MAP_SAFFRON_GYM` | 25 | 4 |
| `MAP_SAFFRON_MART` | 25 | 5 |
| `MAP_SAFFRON_POKECENTER_1F` | 25 | 6 |
| `MAP_MR_PSYCHICS_HOUSE` | 25 | 8 |
| `MAP_SAFFRON_MAGNET_TRAIN_STATION` | 25 | 9 |
| `MAP_SILPH_CO_1F` | 25 | 10 |

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 0 | `MAP_VERMILION_CITY` | `maps/VermilionCity.asm` (previous section) | - | north map connection | "Heal at the Pokémon Center, then head north onto Route 6" - Vermilion belongs to the previous section |
| 1 | `MAP_ROUTE_6` | `maps/Route6.asm` | south connection from Vermilion City | warp 2 `(6, 1)` -> `ROUTE_6_SAFFRON_GATE` warp 3 | "barren wasteland"; the Underground Path door is blocked |
| 1a | `MAP_ROUTE_6_UNDERGROUND_PATH_ENTRANCE` | `maps/Route6UndergroundPathEntrance.asm` | warp 1 `(17, 3)` on Route 6 | - | Walkthrough only notes it is blocked; do not enter this section |
| 2 | `MAP_ROUTE_6_SAFFRON_GATE` | `maps/Route6SaffronGate.asm` | warp 3/4 `(4, 7)` / `(5, 7)` | warp 1/2 `(4, 0)` / `(5, 0)` -> `SAFFRON_CITY` warps 12 / 13 | "make your way all the way up through the checkpoint house" |
| 3 | `MAP_SAFFRON_CITY` | `maps/SaffronCity.asm` | warp 12 `(16, 33)` / warp 13 `(17, 33)` | see below | Hub for the rest of the section; `MAPCALLBACK_NEWMAP` sets the fly point |
| 4 | `MAP_MR_PSYCHICS_HOUSE` | `maps/MrPsychicsHouse.asm` | Saffron warp 5 `(27, 29)` | warp 1/2 `(2, 7)` / `(3, 7)` -> Saffron warp 5 | "Mr. Psychic ... gets you TM29 Psychic" |
| 5 | `MAP_SILPH_CO_1F` | `maps/SilphCo1F.asm` | Saffron warp 7 `(18, 21)` | warp 1/2 `(2, 7)` / `(3, 7)` -> Saffron warp 7 | "Talk to the man blocking the pathway ... he'll give you Up-Grade" |
| 6 | `MAP_SAFFRON_MAGNET_TRAIN_STATION` | `maps/SaffronMagnetTrainStation.asm` | Saffron warp 6 `(8, 3)` | warp 1/2 `(8, 17)` / `(9, 17)` -> Saffron warp 6 | "On the northwest side of town is the Magnet Train ... currently closed" |
| 7 | `MAP_SAFFRON_MART` | `maps/SaffronMart.asm` | Saffron warp 3 `(25, 11)` | warp 1/2 `(2, 7)` / `(3, 7)` -> Saffron warp 3 | "There's a PokeMart if you want to buy or sell items" |
| 8 | `MAP_FIGHTING_DOJO` | `maps/FightingDojo.asm` | Saffron warp 1 `(26, 3)` | warp 1/2 `(4, 11)` / `(5, 11)` -> Saffron warp 1 | "The former fighting gym has a Focus Band you can pick up" |
| 9 | `MAP_SAFFRON_GYM` | `maps/SaffronGym.asm` | Saffron warp 2 `(34, 3)` | warp 1/2 `(8, 17)` / `(9, 17)` -> Saffron warp 2 | "head to the gym on the right ... Sabrina" -> MARSHBADGE |
| 9a | `MAP_SAFFRON_POKECENTER_1F` | `maps/SaffronPokecenter1F.asm` | Saffron warp 4 `(9, 29)` | warp 1/2 `(3, 7)` / `(4, 7)` -> Saffron warp 4 | Optional mid-gym heal trip described in the walkthrough |

Spillover: the walkthrough's opening line ("Heal at the Pokémon Center") refers to Vermilion City, and its closing text ends inside the Saffron Gym exit - nothing past Saffron is described. `MAP_COPYCATS_HOUSE_1F` (Saffron warp 8, `(9, 11)`) exists on this map but the walkthrough never enters it in this section.

## 2. Maps

### MAP_ROUTE_6

- Script: `maps/Route6.asm`
- Blocks: `maps/Route6.blk` (`data/maps/blocks.asm:562` `Route6_Blocks`)
- Header: `data/maps/maps.asm:294` -> `TILESET_KANTO`, `ROUTE`, `LANDMARK_ROUTE_6`, `MUSIC_ROUTE_3`, phone `FALSE`, `PALETTE_AUTO`, `FISHGROUP_POND`
- Dimensions: `constants/map_constants.asm:271` `map_const ROUTE_6, 10, 9` (10x9 blocks = 20x18 cells)
- Connections: `data/maps/attributes.asm:346-348` - north `SaffronCity` (offset -5), south `VermilionCity` (offset -5). No east/west.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 17 | 3 | `ROUTE_6_UNDERGROUND_PATH_ENTRANCE` | 1 |
| 2 | 6 | 1 | `ROUTE_6_SAFFRON_GATE` | 3 |

**Coord events** (`def_coord_events`) - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 19 | 5 | `BGEVENT_READ` | `Route6UndergroundPathSign` (`Route6UndergroundPathSignText`) |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE6_POKEFAN_M` | `SPRITE_POKEFAN_M` | 17 | 4 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` (sight field 2, unused) | `Route6PokefanMScript` (`4f:581a`) | `EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH` |

**Scripts of interest**

- `Route6PokefanMScript` (`maps/Route6.asm:9`, sym `4f:581a`): a bare `jumptextfaceplayer Route6PokefanMText` - "The road is closed until the problem at the POWER PLANT is solved." No flag reads. He stands at `(17, 4)`, directly south of the Underground Path door at `(17, 3)`, so his body is the block, not a script check.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH` | `constants/event_flags.asm:1299` | set by `maps/PowerPlant.asm:164`; consumed as the object's event flag on `maps/Route6.asm:43` and `maps/Route5.asm:56` | Flag **set** hides the object (`CheckObjectFlag`, `engine/overworld/map_objects_2.asm:32`). Clear (default) = the man is standing there = Underground Path shut |

**Items** - none on this map.

**Trainers** - none on this map.

**Wild encounters**

`data/wild/kanto_grass.asm:480` `def_grass_wildmons ROUTE_6`, encounter rates 10/10/10 percent (morn/day/nite). Gold block (`IF DEF(_GOLD)`, lines 483-506):

| slot | morn | day | nite |
|---|---|---|---|
| 1 | L13 `PIDGEY` | L13 `PIDGEY` | L13 `ODDISH` |
| 2 | L13 `BELLSPROUT` | L13 `BELLSPROUT` | L14 `ODDISH` |
| 3 | L14 `PIDGEY` | L14 `PIDGEY` | L13 `BELLSPROUT` |
| 4 | L15 `MAGNEMITE` | L15 `MAGNEMITE` | L15 `MAGNEMITE` |
| 5 | L12 `ABRA` | L12 `ABRA` | L12 `ABRA` |
| 6 | L14 `ABRA` | L14 `ABRA` | L14 `ABRA` |
| 7 | L14 `ABRA` | L14 `ABRA` | L14 `ABRA` |

Silver (`ELIF DEF(_SILVER)`, lines 508-531) swaps the third slot for `MEOWTH` (L14) morn/day and slots 2/3 for `MEOWTH`/`BELLSPROUT` at nite.

Water: `data/wild/kanto_water.asm:12` `def_water_wildmons ROUTE_6`, 2 percent - L10 `PSYDUCK`, L5 `PSYDUCK`, L10 `GOLDUCK`.

Fishing group is `FISHGROUP_POND` (`data/maps/maps.asm:294`).

### MAP_ROUTE_6_UNDERGROUND_PATH_ENTRANCE

- Script: `maps/Route6UndergroundPathEntrance.asm`
- Blocks: shared `maps/UndergroundPathEntrance.blk` (`data/maps/blocks.asm:466`)
- Header: `data/maps/maps.asm:306` -> `TILESET_GATE`, `GATE`, `LANDMARK_ROUTE_6`, `MUSIC_ROUTE_3`, phone `FALSE`, `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:283` `map_const ROUTE_6_UNDERGROUND_PATH_ENTRANCE, 4, 4`
- Connections: none (indoor)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `ROUTE_6` | 1 |
| 2 | 4 | 7 | `ROUTE_6` | 1 |
| 3 | 4 | 3 | `UNDERGROUND_PATH` | 2 |

No coord events, no bg events, no object events. Nothing gates warp 3 from the inside - the only block is the NPC body on Route 6.

### MAP_ROUTE_6_SAFFRON_GATE

- Script: `maps/Route6SaffronGate.asm`
- Blocks: shared `maps/NorthSouthGate.blk` (`data/maps/blocks.asm:210,215`)
- Header: `data/maps/maps.asm:305` -> `TILESET_GATE`, `GATE`, `LANDMARK_ROUTE_6`, `MUSIC_ROUTE_3`, phone `FALSE`, `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:282` `map_const ROUTE_6_SAFFRON_GATE, 5, 4`
- Scene scripts: one entry, `scene_script Route6SaffronGateNoopScene` with no scene-id argument (`maps/Route6SaffronGate.asm:6`), so no `SCENE_*` constant is generated and the scene is a bare `end`.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 0 | `SAFFRON_CITY` | 12 |
| 2 | 5 | 0 | `SAFFRON_CITY` | 13 |
| 3 | 4 | 7 | `ROUTE_6` | 2 |
| 4 | 5 | 7 | `ROUTE_6` | 2 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE6SAFFRONGATE_OFFICER` | `SPRITE_OFFICER` | 0 | 4 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `Route6SaffronGuardScript` (`59:523c`) | -1 (always) |

**Scripts of interest**

- `Route6SaffronGuardScript` (`maps/Route6SaffronGate.asm:13`, sym `59:523c`): `faceplayer` / `opentext` / `checkevent EVENT_RETURNED_MACHINE_PART` / `iftrue .ReturnedPart`. Before the Power Plant is fixed he explains the Magnet Train is dead; after, a one-liner. He stands at `(0, 4)`, off the walking lane - he never blocks passage.

### MAP_SAFFRON_CITY

- Script: `maps/SaffronCity.asm`
- Blocks: `maps/SaffronCity.blk` (`data/maps/blocks.asm:24`)
- Header: `data/maps/maps.asm:490` -> `TILESET_KANTO`, `TOWN`, `LANDMARK_SAFFRON_CITY`, `MUSIC_VIRIDIAN_CITY`, phone `FALSE`, `PALETTE_AUTO`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:454` `map_const SAFFRON_CITY, 20, 18` (40x36 cells)
- Connections: `data/maps/attributes.asm:350-354` - north `Route5` (+5), south `Route6` (+5), west `Route7` (+9), east `Route8` (+9)
- Spawn / fly: `data/maps/spawn_points.asm:21` `spawn SAFFRON_CITY, 9, 30`; `data/maps/flypoints.asm:26` `db LANDMARK_SAFFRON_CITY, SPAWN_SAFFRON`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 26 | 3 | `FIGHTING_DOJO` | 1 |
| 2 | 34 | 3 | `SAFFRON_GYM` | 1 |
| 3 | 25 | 11 | `SAFFRON_MART` | 2 |
| 4 | 9 | 29 | `SAFFRON_POKECENTER_1F` | 1 |
| 5 | 27 | 29 | `MR_PSYCHICS_HOUSE` | 1 |
| 6 | 8 | 3 | `SAFFRON_MAGNET_TRAIN_STATION` | 2 |
| 7 | 18 | 21 | `SILPH_CO_1F` | 1 |
| 8 | 9 | 11 | `COPYCATS_HOUSE_1F` | 1 |
| 9 | 18 | 3 | `ROUTE_5_SAFFRON_GATE` | 3 |
| 10 | 0 | 24 | `ROUTE_7_SAFFRON_GATE` | 3 |
| 11 | 0 | 25 | `ROUTE_7_SAFFRON_GATE` | 4 |
| 12 | 16 | 33 | `ROUTE_6_SAFFRON_GATE` | 1 |
| 13 | 17 | 33 | `ROUTE_6_SAFFRON_GATE` | 2 |
| 14 | 39 | 22 | `ROUTE_8_SAFFRON_GATE` | 1 |
| 15 | 39 | 23 | `ROUTE_8_SAFFRON_GATE` | 2 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 21 | 5 | `BGEVENT_READ` | `SaffronCitySign` |
| 33 | 5 | `BGEVENT_READ` | `SaffronGymSign` |
| 25 | 5 | `BGEVENT_READ` | `FightingDojoSign` |
| 15 | 21 | `BGEVENT_READ` | `SilphCoSign` |
| 25 | 29 | `BGEVENT_READ` | `MrPsychicsHouseSign` |
| 11 | 5 | `BGEVENT_READ` | `SaffronCityMagnetTrainStationSign` |
| 10 | 29 | `BGEVENT_READ` | `SaffronCityPokecenterSign` (`jumpstd PokecenterSignScript`) |
| 26 | 11 | `BGEVENT_READ` | `SaffronCityMartSign` (`jumpstd MartSignScript`) |

No hidden items on this map.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `SAFFRONCITY_LASS1` | `SPRITE_LASS` | 7 | 14 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (rx 2) | `OBJECTTYPE_SCRIPT` | `SaffronCityLass1Script` | -1 |
| `SAFFRONCITY_POKEFAN_M` | `SPRITE_POKEFAN_M` | 19 | 30 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (rx 2) | `OBJECTTYPE_SCRIPT` | `SaffronCityPokefanMScript` | -1 |
| `SAFFRONCITY_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 32 | 7 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (rx 1) | `OBJECTTYPE_SCRIPT` | `SaffronCityCooltrainerMScript` | -1 |
| `SAFFRONCITY_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 20 | 24 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (rx 2) | `OBJECTTYPE_SCRIPT` | `SaffronCityCooltrainerFScript` | -1 |
| `SAFFRONCITY_FISHER` | `SPRITE_FISHER` | 27 | 12 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `SaffronCityFisherScript` | -1 |
| `SAFFRONCITY_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 15 | 19 | `SPRITEMOVEDATA_WALK_UP_DOWN` (ry 1) | `OBJECTTYPE_SCRIPT` | `SaffronCityYoungster1Script` | -1 |
| `SAFFRONCITY_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 35 | 22 | `SPRITEMOVEDATA_WANDER` (rx 1, ry 1) | `OBJECTTYPE_SCRIPT` | `SaffronCityYoungster2Script` | -1 |
| `SAFFRONCITY_LASS2` | `SPRITE_LASS` | 19 | 8 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `SaffronCityLass2Script` | -1 |

Every Saffron City NPC is `OBJECTTYPE_SCRIPT`; none of them blocks a warp tile.

**Scripts of interest**

- `SaffronCityFlypointCallback` (`maps/SaffronCity.asm:17`), registered as `callback MAPCALLBACK_NEWMAP`: `setflag ENGINE_FLYPOINT_SAFFRON` / `endcallback`. Walking in from the Route 6 gate is what unlocks Fly to Saffron - there is no NPC or item involved.
- `SaffronCityLass1Script`, `SaffronCityPokefanMScript`, `SaffronCityFisherScript` all branch on `checkevent EVENT_RETURNED_MACHINE_PART`. Purely dialogue; useful only as a state probe.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_SAFFRON` | `constants/engine_flags.asm:74` | set by `SaffronCityFlypointCallback` | Fly destination unlocked; also the `SPAWN_SAFFRON` blackout target once the player has been here |
| `EVENT_RETURNED_MACHINE_PART` | `constants/event_flags.asm:200` | set in `maps/PowerPlant.asm:161`; read by four Saffron scripts and `Route6SaffronGuardScript` | Not set in this section. Its absence is what keeps the Magnet Train shut |

**Items** - none directly on the city map.

**Trainers** - none.

**Wild encounters** - none. `SAFFRON_CITY` has no entry in `data/wild/kanto_grass.asm`, `kanto_water.asm`, `fish.asm` or `treemons.asm` (grep over `data/wild/` for `SAFFRON` returns nothing).

### MAP_MR_PSYCHICS_HOUSE

- Script: `maps/MrPsychicsHouse.asm`
- Blocks: shared `maps/House1.blk` (`data/maps/blocks.asm:195,201`)
- Header: `data/maps/maps.asm:496` -> `TILESET_HOUSE`, `INDOOR`, `LANDMARK_SAFFRON_CITY`, `MUSIC_VIRIDIAN_CITY`, phone `FALSE`, `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:460` `map_const MR_PSYCHICS_HOUSE, 4, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `SAFFRON_CITY` | 5 |
| 2 | 3 | 7 | `SAFFRON_CITY` | 5 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `MrPsychicsHouseBookshelf` (`jumpstd DifficultBookshelfScript`) |
| 1 | 1 | `BGEVENT_READ` | `MrPsychicsHouseBookshelf` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MRPSYCHICSHOUSE_FISHING_GURU` | `SPRITE_FISHING_GURU` | 5 | 3 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `MrPsychic` (`61:4b15`) | -1 |

**Scripts of interest**

- `MrPsychic` (`maps/MrPsychicsHouse.asm:9`, sym `61:4b15`):
  `faceplayer` / `opentext` / `checkevent EVENT_GOT_TM29_PSYCHIC` / `iftrue .AlreadyGotItem` / `writetext MrPsychicText1` / `promptbutton` / `verbosegiveitem TM_PSYCHIC_M` / `iffalse .Done` / `setevent EVENT_GOT_TM29_PSYCHIC` / `.AlreadyGotItem: writetext MrPsychicText2` / `waitbutton` / `.Done: closetext` / `end`.
  One `verbosegiveitem`; a full bag drops through `.Done` **without** setting the flag, so a bot must re-talk after making room.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_GOT_TM29_PSYCHIC` | `constants/event_flags.asm:226` | read+set by `MrPsychic` | One-shot guard on TM29 |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `TM_PSYCHIC_M` (TM29, `constants/item_constants.asm:250` `add_tm PSYCHIC_M ; dd`) | talk to `MRPSYCHICSHOUSE_FISHING_GURU` at `(5, 3)` | `MrPsychic`, `verbosegiveitem` | `EVENT_GOT_TM29_PSYCHIC` |

### MAP_SILPH_CO_1F

- Script: `maps/SilphCo1F.asm`
- Blocks: `maps/SilphCo1F.blk` (`data/maps/blocks.asm:874`)
- Header: `data/maps/maps.asm:498` -> `TILESET_FACILITY`, `INDOOR`, `LANDMARK_SAFFRON_CITY`, `MUSIC_VIRIDIAN_CITY`, phone `FALSE`, `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:462` `map_const SILPH_CO_1F, 8, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `SAFFRON_CITY` | 7 |
| 2 | 3 | 7 | `SAFFRON_CITY` | 7 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `SILPHCO1F_RECEPTIONIST` | `SPRITE_RECEPTIONIST` | 4 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `SilphCoReceptionistScript` | -1 |
| `SILPHCO1F_OFFICER` | `SPRITE_OFFICER` | 13 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `SilphCoOfficerScript` (`61:4f81`) | -1 |

**Scripts of interest**

- `SilphCoOfficerScript` (`maps/SilphCo1F.asm:13`, sym `61:4f81`): `faceplayer` / `opentext` / `checkevent EVENT_GOT_UP_GRADE` / `iftrue .GotUpGrade` / `writetext SilphCoOfficerText` / `promptbutton` / `verbosegiveitem UP_GRADE` / `iffalse .NoRoom` / `setevent EVENT_GOT_UP_GRADE` / `.GotUpGrade: writetext ...` / `waitbutton` / `.NoRoom: closetext` / `end`. Same full-bag shape as Mr. Psychic. There is no upstairs on this map at all - the "man blocking the stairway" is `(13, 1)`, standing on the only path north; nothing scripted opens it.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_GOT_UP_GRADE` | `constants/event_flags.asm:221` | read+set by `SilphCoOfficerScript` | One-shot guard on Up-Grade |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `UP_GRADE` (`constants/item_constants.asm:180`, `$ac`) | talk to `SILPHCO1F_OFFICER` at `(13, 1)` | `SilphCoOfficerScript`, `verbosegiveitem` | `EVENT_GOT_UP_GRADE` |

### MAP_SAFFRON_MAGNET_TRAIN_STATION

- Script: `maps/SaffronMagnetTrainStation.asm`
- Blocks: `maps/SaffronMagnetTrainStation.blk`
- Header: `data/maps/maps.asm:497` -> `TILESET_TRAIN_STATION`, `INDOOR`, `LANDMARK_SAFFRON_CITY`, `MUSIC_VIRIDIAN_CITY`, phone `FALSE`, `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:461` `map_const SAFFRON_MAGNET_TRAIN_STATION, 10, 9`
- Scene variable: `data/maps/scenes.asm:17` `scene_var SAFFRON_MAGNET_TRAIN_STATION, wSaffronMagnetTrainStationSceneID`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 8 | 17 | `SAFFRON_CITY` | 6 |
| 2 | 9 | 17 | `SAFFRON_CITY` | 6 |
| 3 | 6 | 5 | `GOLDENROD_MAGNET_TRAIN_STATION` | 4 |
| 4 | 11 | 5 | `GOLDENROD_MAGNET_TRAIN_STATION` | 3 |

**Coord events**

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_SAFFRONMAGNETTRAINSTATION_ARRIVE_FROM_GOLDENROD` (= 0, generated by the `scene_script` macro at `maps/SaffronMagnetTrainStation.asm:9`) | 11 | 6 | `Script_ArriveFromGoldenrod` | Arrival cutscene when riding in from Goldenrod; not reachable in this section |

**BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `SAFFRONMAGNETTRAINSTATION_OFFICER` | `SPRITE_OFFICER` | 9 | 9 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `SaffronMagnetTrainStationOfficerScript` (`61:4bc2`) | -1 |
| `SAFFRONMAGNETTRAINSTATION_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 10 | 14 | `SPRITEMOVEDATA_WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `SaffronMagnetTrainStationGymGuideScript` | -1 |
| `SAFFRONMAGNETTRAINSTATION_TEACHER` | `SPRITE_TEACHER` | 6 | 11 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `SaffronMagnetTrainStationTeacherScript` | `EVENT_SAFFRON_TRAIN_STATION_POPULATION` |
| `SAFFRONMAGNETTRAINSTATION_LASS` | `SPRITE_LASS` | 6 | 10 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `SaffronMagnetTrainStationLassScript` | `EVENT_SAFFRON_TRAIN_STATION_POPULATION` |

**Scripts of interest**

- `SaffronMagnetTrainStationOfficerScript` (`maps/SaffronMagnetTrainStation.asm:16`, sym `61:4bc2`): `checkevent EVENT_RESTORED_POWER_TO_KANTO` / `iftrue .MagnetTrainToGoldenrod`, else "the MAGNET TRAIN isn't operating now" and `end`. The ride arm additionally runs `yesorno`, `checkitem PASS`, two `applymovement`s, `setval TRUE` / `special MagnetTrain` / `warpcheck` / `newloadmap MAPSETUP_TRAIN`. In this section both `EVENT_RESTORED_POWER_TO_KANTO` and `PASS` are missing, so the officer is a dead end.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_RESTORED_POWER_TO_KANTO` | `constants/event_flags.asm:204` | set at `maps/PowerPlant.asm:165`; read by the officer script | Gate on the Magnet Train being operable at all |
| `EVENT_SAFFRON_TRAIN_STATION_POPULATION` | `constants/event_flags.asm:1300` | cleared at `maps/PowerPlant.asm:160` | While **set** (the state in this section) the Teacher and Lass are hidden - the station looks empty on purpose |

### MAP_SAFFRON_MART

- Script: `maps/SaffronMart.asm`
- Blocks: shared `maps/Mart.blk` (`data/maps/blocks.asm:333,335`)
- Header: `data/maps/maps.asm:493` -> `TILESET_MART`, `INDOOR`, `LANDMARK_SAFFRON_CITY`, `MUSIC_VIRIDIAN_CITY`, phone `FALSE`, `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:457` `map_const SAFFRON_MART, 6, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `SAFFRON_CITY` | 3 |
| 2 | 3 | 7 | `SAFFRON_CITY` | 3 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `SAFFRONMART_CLERK` | `SPRITE_CLERK` | 1 | 3 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `SaffronMartClerkScript` | -1 |
| `SAFFRONMART_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 7 | 2 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `SaffronMartCooltrainerMScript` | -1 |
| `SAFFRONMART_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 7 | 6 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (rx 1) | `OBJECTTYPE_SCRIPT` | `SaffronMartCooltrainerFScript` | -1 |

**Scripts of interest**

- `SaffronMartClerkScript`: `opentext` / `pokemart MARTTYPE_STANDARD, MART_SAFFRON` / `closetext` / `end`.

**Items** - shop stock, `data/items/marts.asm:362` `MartSaffron`: `GREAT_BALL`, `ULTRA_BALL`, `HYPER_POTION`, `MAX_POTION`, `FULL_HEAL`, `X_ATTACK`, `X_DEFEND`, `FLOWER_MAIL`.

### MAP_FIGHTING_DOJO

- Script: `maps/FightingDojo.asm`
- Blocks: `maps/FightingDojo.blk` (`data/maps/blocks.asm:871`)
- Header: `data/maps/maps.asm:491` -> `TILESET_TRAIN_STATION`, `INDOOR`, `LANDMARK_SAFFRON_CITY`, `MUSIC_VIRIDIAN_CITY`, phone `FALSE`, `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:455` `map_const FIGHTING_DOJO, 5, 6`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 11 | `SAFFRON_CITY` | 1 |
| 2 | 5 | 11 | `SAFFRON_CITY` | 1 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 4 | 0 | `BGEVENT_READ` | `FightingDojoSign1` |
| 5 | 0 | `BGEVENT_READ` | `FightingDojoSign2` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `FIGHTINGDOJO_BLACK_BELT` | `SPRITE_BLACK_BELT` | 4 | 4 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `FightingDojoBlackBelt` | -1 |
| `FIGHTINGDOJO_POKE_BALL` | `SPRITE_POKE_BALL` | 3 | 1 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `FightingDojoFocusBand` (`61:400b`) | `EVENT_PICKED_UP_FOCUS_BAND` |

**Scripts of interest**

- `FightingDojoFocusBand` (`maps/FightingDojo.asm:19`, sym `61:400b`): the two-byte `itemball FOCUS_BAND` struct (macro at `macros/scripts/maps.asm:154`, quantity defaults to 1), not a script. The engine's own item-ball path runs it.
- There are **no trainers** in the Fighting Dojo in Gen 2. `FightingDojoBlackBeltText` explains the Karate King is away in a Johto cave (Rock Tunnel-era content elsewhere), so nothing here fights back.

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `FOCUS_BAND` (`constants/item_constants.asm:127`, `$77`) | walk onto / press A at `(3, 1)` | `FightingDojoFocusBand` (`OBJECTTYPE_ITEMBALL`) | `EVENT_PICKED_UP_FOCUS_BAND` (`constants/event_flags.asm:1312`) - once set the ball object is masked |

### MAP_SAFFRON_GYM

- Script: `maps/SaffronGym.asm`
- Blocks: `maps/SaffronGym.blk` (`data/maps/blocks.asm:861`)
- Header: `data/maps/maps.asm:492` -> `TILESET_UNDERGROUND`, `INDOOR`, `LANDMARK_SAFFRON_CITY`, `MUSIC_GYM`, phone `TRUE` (phone calls suppressed), `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:456` `map_const SAFFRON_GYM, 10, 9` (20x18 cells)
- Connections: none

**Warps** (`def_warp_events`, `maps/SaffronGym.asm:294-326`) - warps 1-2 are the street doors; warps 3-32 are the 30 teleport pads. Every pad's destination is `SAFFRON_GYM` and the player lands on the destination warp's own tile.

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 8 | 17 | `SAFFRON_CITY` | 2 |
| 2 | 9 | 17 | `SAFFRON_CITY` | 2 |
| 3 | 11 | 15 | `SAFFRON_GYM` | 18 |
| 4 | 19 | 15 | `SAFFRON_GYM` | 19 |
| 5 | 19 | 11 | `SAFFRON_GYM` | 20 |
| 6 | 1 | 11 | `SAFFRON_GYM` | 21 |
| 7 | 5 | 3 | `SAFFRON_GYM` | 22 |
| 8 | 11 | 5 | `SAFFRON_GYM` | 23 |
| 9 | 1 | 15 | `SAFFRON_GYM` | 24 |
| 10 | 19 | 3 | `SAFFRON_GYM` | 25 |
| 11 | 15 | 17 | `SAFFRON_GYM` | 26 |
| 12 | 5 | 17 | `SAFFRON_GYM` | 27 |
| 13 | 5 | 9 | `SAFFRON_GYM` | 28 |
| 14 | 9 | 3 | `SAFFRON_GYM` | 29 |
| 15 | 15 | 9 | `SAFFRON_GYM` | 30 |
| 16 | 15 | 5 | `SAFFRON_GYM` | 31 |
| 17 | 1 | 5 | `SAFFRON_GYM` | 32 |
| 18 | 19 | 17 | `SAFFRON_GYM` | 3 |
| 19 | 19 | 9 | `SAFFRON_GYM` | 4 |
| 20 | 1 | 9 | `SAFFRON_GYM` | 5 |
| 21 | 5 | 5 | `SAFFRON_GYM` | 6 |
| 22 | 11 | 3 | `SAFFRON_GYM` | 7 |
| 23 | 1 | 17 | `SAFFRON_GYM` | 8 |
| 24 | 19 | 5 | `SAFFRON_GYM` | 9 |
| 25 | 15 | 15 | `SAFFRON_GYM` | 10 |
| 26 | 5 | 15 | `SAFFRON_GYM` | 11 |
| 27 | 5 | 11 | `SAFFRON_GYM` | 12 |
| 28 | 9 | 5 | `SAFFRON_GYM` | 13 |
| 29 | 15 | 11 | `SAFFRON_GYM` | 14 |
| 30 | 15 | 3 | `SAFFRON_GYM` | 15 |
| 31 | 1 | 3 | `SAFFRON_GYM` | 16 |
| 32 | 11 | 9 | `SAFFRON_GYM` | 17 |

**Teleporter graph, resolved to landing coordinates.** Every pair is mutual, so the graph is 15 undirected edges. Room labels are derived from the pad clusters and the object coordinates; they are a reading aid, the coordinates are the ground truth.

| room (occupant) | pads (x, y) |
|---|---|
| ENTRANCE (doors `(8,17)`/`(9,17)`, guide `(9,14)`, statue `(8,15)`) | `(11,15)` |
| BL (Psychic Franklin `(3,16)`) | `(1,15)` `(5,15)` `(1,17)` `(5,17)` |
| BR (Medium Rebecca `(17,16)`) | `(15,15)` `(19,15)` `(15,17)` `(19,17)` |
| ML | `(1,9)` `(5,9)` `(1,11)` `(5,11)` |
| CENTER (Sabrina `(9,8)`) | `(11,9)` |
| MR | `(15,9)` `(19,9)` `(15,11)` `(19,11)` |
| TL (Medium Doris `(3,4)`) | `(1,3)` `(5,3)` `(1,5)` `(5,5)` |
| TC | `(9,3)` `(11,3)` `(9,5)` `(11,5)` |
| TR (Psychic Jared `(17,4)`) | `(15,3)` `(19,3)` `(15,5)` `(19,5)` |

| step on pad | warp idx | lands at | room reached |
|---|---|---|---|
| `(11,15)` ENTRANCE | 3 | `(19,17)` | BR |
| `(19,17)` BR | 18 | `(11,15)` | ENTRANCE |
| `(19,15)` BR | 4 | `(19,9)` | MR |
| `(19,9)` MR | 19 | `(19,15)` | BR |
| `(15,17)` BR | 11 | `(5,15)` | BL |
| `(5,15)` BL | 26 | `(15,17)` | BR |
| `(15,15)` BR | 25 | `(19,3)` | TR |
| `(19,3)` TR | 10 | `(15,15)` | BR |
| `(1,15)` BL | 9 | `(19,5)` | TR |
| `(19,5)` TR | 24 | `(1,15)` | BL |
| `(1,17)` BL | 23 | `(11,5)` | TC |
| `(11,5)` TC | 8 | `(1,17)` | BL |
| `(5,17)` BL | 12 | `(5,11)` | ML |
| `(5,11)` ML | 27 | `(5,17)` | BL |
| `(1,9)` ML | 20 | `(19,11)` | MR |
| `(19,11)` MR | 5 | `(1,9)` | ML |
| `(5,9)` ML | 13 | `(9,5)` | TC |
| `(9,5)` TC | 28 | `(5,9)` | ML |
| `(1,11)` ML | 6 | `(5,5)` | TL |
| `(5,5)` TL | 21 | `(1,11)` | ML |
| `(15,9)` MR | 15 | `(15,3)` | TR |
| `(15,3)` TR | 30 | `(15,9)` | MR |
| `(15,11)` MR | 29 | `(9,3)` | TC |
| `(9,3)` TC | 14 | `(15,11)` | MR |
| `(5,3)` TL | 7 | `(11,3)` | TC |
| `(11,3)` TC | 22 | `(5,3)` | TL |
| `(1,3)` TL | 31 | `(15,5)` | TR |
| `(15,5)` TR | 16 | `(1,3)` | TL |
| **`(1,5)` TL** | **17** | **`(11,9)`** | **CENTER (Sabrina)** |
| **`(11,9)` CENTER** | **32** | **`(1,5)`** | **TL** |

`(1,5)` in the top-left room is the only pad that reaches Sabrina, and `(11,9)` is the only way out of her chamber. This matches the walkthrough's "go to the bottom left teleporter and you'll go straight to the gym leader".

**Coord events** - none. The gym has no trip-wires; every transition is a warp tile.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 8 | 15 | `BGEVENT_READ` | `SaffronGymStatue` (`61:4170`) |

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `SAFFRONGYM_SABRINA` | `SPRITE_SABRINA` | 9 | 8 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `SaffronGymSabrinaScript` (`61:40cf`) | -1 |
| `SAFFRONGYM_GRANNY1` | `SPRITE_GRANNY` | 17 | 16 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 3 | `TrainerMediumRebecca` (`61:410c`) | -1 |
| `SAFFRONGYM_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 3 | 16 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 3 | `TrainerPsychicFranklin` (`61:4120`) | -1 |
| `SAFFRONGYM_GRANNY2` | `SPRITE_GRANNY` | 3 | 4 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 2 | `TrainerMediumDoris` (`61:4134`) | -1 |
| `SAFFRONGYM_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 17 | 4 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 2 | `TrainerPsychicJared` (`61:4148`) | -1 |
| `SAFFRONGYM_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 9 | 14 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `SaffronGymGuideScript` | -1 |

All four trainers spin (`SPINRANDOM_FAST`), so their line of sight rotates - a bot cannot assume a fixed approach lane; walking into the room will trigger them.

**Scripts of interest**

- `SaffronGymSabrinaScript` (`maps/SaffronGym.asm:14`, sym `61:40cf`):
  `faceplayer` / `opentext` / `checkflag ENGINE_MARSHBADGE` / `iftrue .FightDone` / `writetext SabrinaIntroText` / `waitbutton` / `closetext` / `winlosstext SabrinaWinLossText, 0` / `loadtrainer SABRINA, SABRINA1` / `startbattle` / `reloadmapafterbattle` / then a burst of five `setevent`s: `EVENT_BEAT_SABRINA`, `EVENT_BEAT_MEDIUM_REBECCA`, `EVENT_BEAT_MEDIUM_DORIS`, `EVENT_BEAT_PSYCHIC_FRANKLIN`, `EVENT_BEAT_PSYCHIC_JARED` / `opentext` / `writetext ReceivedMarshBadgeText` / `playsound SFX_GET_BADGE` / `waitsfx` / `setflag ENGINE_MARSHBADGE` / `writetext SabrinaMarshBadgeText` / `waitbutton` / `closetext` / `end`.
  Two consequences a bot should exploit: **the four gym trainers are auto-cleared when Sabrina falls**, so they are entirely skippable; and the badge is a `setflag` on `ENGINE_MARSHBADGE`, which is also the re-entry guard (`.FightDone`).
- `TrainerMediumRebecca` / `TrainerPsychicFranklin` / `TrainerMediumDoris` / `TrainerPsychicJared` (`maps/SaffronGym.asm:47,58,69,80`): each is a `trainer CLASS, ID, EVENT_BEAT_*, SeenText, BeatenText, 0, .Script` struct (`macros/scripts/maps.asm:142`; field order is group, id, flag, seen, win, loss, after) followed by an `endifjustbattled` / `opentext` / `writetext ...AfterBattleText` / `waitbutton` / `closetext` / `end` after-battle script.
- `SaffronGymStatue` (`maps/SaffronGym.asm:107`, sym `61:4170`): `checkflag ENGINE_MARSHBADGE` / `iftrue .Beaten` / `jumpstd GymStatue1Script`; the beaten arm does `gettrainername STRING_BUFFER_4, SABRINA, SABRINA1` then `jumpstd GymStatue2Script`. Handy as a cheap post-badge assertion.
- `SaffronGymGuideScript` (`maps/SaffronGym.asm:91`): branches on `checkevent EVENT_BEAT_SABRINA`; no items, no flags written.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_MARSHBADGE` | `constants/engine_flags.asm:52` (bit 5 of `wKantoBadges`; Kanto order is Boulder, Cascade, Thunder, Rainbow, Soul, **Marsh**, Volcano, Earth) | `checkflag` in `SaffronGymSabrinaScript` and `SaffronGymStatue`; `setflag` after the win | The section's terminal postcondition |
| `EVENT_BEAT_SABRINA` | `constants/event_flags.asm:720` | set by `SaffronGymSabrinaScript`; read by `SaffronGymGuideScript` | Leader defeated |
| `EVENT_BEAT_MEDIUM_REBECCA` | `constants/event_flags.asm:935` | trainer struct flag; also force-set by the Sabrina script | Rebecca cleared |
| `EVENT_BEAT_MEDIUM_DORIS` | `constants/event_flags.asm:936` | as above | Doris cleared |
| `EVENT_BEAT_PSYCHIC_FRANKLIN` | `constants/event_flags.asm:564` | as above | Franklin cleared |
| `EVENT_BEAT_PSYCHIC_JARED` | `constants/event_flags.asm:573` | as above | Jared cleared |

**Items** - none in the gym.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `SABRINA` / `SABRINA1` | `SABRINA` (`constants/trainer_constants.asm:309`, class 23) | 1 | `SabrinaGroup` `; SABRINA (1)` (`data/trainers/parties.asm:1400-1406`), `TRAINERTYPE_MOVES`: L46 `ESPEON` (Sand-Attack, Quick Attack, Swift, Psychic), L46 `MR__MIME` (Barrier, Reflect, Baton Pass, Psychic), L48 `ALAKAZAM` (Recover, Future Sight, Psychic, Reflect) | `SaffronGymSabrinaScript` | none; leader (`data/trainers/leaders.asm:29`) |
| `MEDIUM` / `REBECCA` | `MEDIUM` | 6 (`constants/trainer_constants.asm:590`) | `MediumGroup` `; MEDIUM (6)`: L35 `DROWZEE`, L35 `HYPNO` | `TrainerMediumRebecca` | none |
| `PSYCHIC_T` / `FRANKLIN` | `PSYCHIC_T` (class 34) | 2 (`constants/trainer_constants.asm:513`) | `PsychicGroup` `; PSYCHIC_T (2)` (`data/trainers/parties.asm:2516`): L37 `KADABRA` | `TrainerPsychicFranklin` | none |
| `MEDIUM` / `DORIS` | `MEDIUM` | 7 (`constants/trainer_constants.asm:591`) | `MediumGroup` `; MEDIUM (7)`: L34 `SLOWPOKE`, L36 `SLOWBRO` | `TrainerMediumDoris` | none |
| `PSYCHIC_T` / `JARED` | `PSYCHIC_T` | 11 (`constants/trainer_constants.asm:522`) | `PsychicGroup` `; PSYCHIC_T (11)` (`data/trainers/parties.asm:2569`): L32 `MR__MIME`, L32 `EXEGGCUTE`, **L35** `EXEGGCUTE` | `TrainerPsychicJared` | none |

Prize money: `ComputeTrainerReward` (`engine/battle/read_trainer_party.asm:300`) is `base reward x last mon's level`, and `engine/battle/core.asm:2344-2358` pays that quarter out **four times**, so the visible payout is `4 x base x level`. Base rewards: Sabrina 25 (`data/trainers/attributes.asm:211`), Medium 10 (`:343`), Psychic T 8 (`:313`). That reproduces the walkthrough's 4800G / 1400G / 1440G / 1184G / 1120G exactly. Sabrina also carries a `HYPER_POTION` as an AI item (`data/trainers/attributes.asm:210`).

**Wild encounters** - none (indoor gym).

### MAP_SAFFRON_POKECENTER_1F

- Script: `maps/SaffronPokecenter1F.asm`
- Blocks: shared `maps/Pokecenter1F.blk` (`data/maps/blocks.asm:362,364`)
- Header: `data/maps/maps.asm:494` -> `TILESET_POKECENTER`, `INDOOR`, `LANDMARK_SAFFRON_CITY`, `MUSIC_POKEMON_CENTER`, phone `FALSE`, `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:458` `map_const SAFFRON_POKECENTER_1F, 5, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `SAFFRON_CITY` | 4 |
| 2 | 4 | 7 | `SAFFRON_CITY` | 4 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

**Object events** (nurse only listed; the rest are flavour)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `SAFFRONPOKECENTER1F_NURSE` | `SPRITE_NURSE` | 3 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `SaffronPokecenter1FNurseScript` (`jumpstd PokecenterNurseScript`) | -1 |
| `SAFFRONPOKECENTER1F_TEACHER` | `SPRITE_TEACHER` | 7 | 2 | `SPRITEMOVEDATA_WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `SaffronPokecenter1FTeacherScript` | -1 |
| `SAFFRONPOKECENTER1F_FISHER` | `SPRITE_FISHER` | 8 | 6 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `SaffronPokecenter1FFisherScript` | -1 |
| `SAFFRONPOKECENTER1F_YOUNGSTER` | `SPRITE_YOUNGSTER` | 1 | 4 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `SaffronPokecenter1FYoungsterScript` | -1 |

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Underground Path (Route 6 warp 1 at `(17, 3)`) | `maps/Route6.asm:43` - `ROUTE6_POKEFAN_M` object standing at `(17, 4)` with event flag `EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH`; visibility decided by `CheckObjectFlag`, `engine/overworld/map_objects_2.asm:32` | Nothing the player can do in this section | `maps/PowerPlant.asm:164` `setevent EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH` (flag set = object masked), which is part of returning the `MACHINE_PART` |
| Magnet Train Saffron -> Goldenrod | `maps/SaffronMagnetTrainStation.asm:19` `checkevent EVENT_RESTORED_POWER_TO_KANTO`, then `checkitem PASS` at `:30` | `EVENT_RESTORED_POWER_TO_KANTO` **and** `PASS` in bag | `maps/PowerPlant.asm:165` sets the event; the `PASS` comes from elsewhere. Both false here, so the officer only prints "isn't operating now" |
| Silph Co. upper floors | `maps/SilphCo1F.asm:69` - `SILPHCO1F_OFFICER` object at `(13, 1)` with event flag `-1` (never hides). No stairs warp exists on `SilphCo1F` at all | Permanently blocked in Gen 2 | Never; this is not a gate that opens |
| Saffron Gym maze | The 30 pad warps at `maps/SaffronGym.asm:296-326`. Pads are teleport panels (`COLL_WARP_PANEL`-class tiles), so they fire on landing, not on a directional press | Navigation only - no badge, item or flag check anywhere in `SaffronGym.asm` | n/a. The single route to Sabrina is `(11,15) -> (19,17) -> ... -> (1,5) -> (11,9)`; see the pad table |
| MARSHBADGE re-fight guard | `maps/SaffronGym.asm:17` `checkflag ENGINE_MARSHBADGE` / `iftrue .FightDone` | Badge not yet held | Beating Sabrina once; afterwards she only talks |
| Gym trainers | Each `trainer` struct's `EVENT_BEAT_*` flag; the trainer only challenges while its flag is clear | Walking into their sight cone (sight 3 for Rebecca/Franklin, 2 for Doris/Jared) | Beating them, **or** beating Sabrina, which sets all four flags at `maps/SaffronGym.asm:27-30` |

No HM field move is required anywhere in this section - no `engine/overworld/cut.asm`, `surf.asm`, `strength.asm` or `whirlpool.asm` check is reachable from these maps. The Bicycle the walkthrough recommends is convenience only.

## 4. Bot checklist

Coordinates are asm cell coordinates on the named map. "Warp N" means the `def_warp_events` index in that map's table.

1. `MAP_ROUTE_6` - walk north along the route to warp 2 at `(6, 1)`. Precondition: none. Postcondition: on `MAP_ROUTE_6_SAFFRON_GATE` warp 3 `(4, 7)`.
   - Optional: read the sign at `(19, 5)`. Do **not** try warp 1 at `(17, 3)`; `ROUTE6_POKEFAN_M` occupies `(17, 4)` while `EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH` is clear.
2. `MAP_ROUTE_6_SAFFRON_GATE` - walk from `(4, 7)` to warp 1 at `(4, 0)`. Postcondition: on `MAP_SAFFRON_CITY` warp 12 `(16, 33)`; `MAPCALLBACK_NEWMAP` fires and `ENGINE_FLYPOINT_SAFFRON` becomes set.
3. `MAP_SAFFRON_CITY` - walk to warp 5 at `(27, 29)`. Enter `MAP_MR_PSYCHICS_HOUSE`.
4. `MAP_MR_PSYCHICS_HOUSE` - talk to `MRPSYCHICSHOUSE_FISHING_GURU` at `(5, 3)` (approach from `(4, 3)` facing right, he faces left). Precondition: `EVENT_GOT_TM29_PSYCHIC` clear and TM pocket has room. Postcondition: `TM_PSYCHIC_M` in bag, `EVENT_GOT_TM29_PSYCHIC` set. Exit warp 1 `(2, 7)`.
5. `MAP_SAFFRON_CITY` - walk to warp 7 at `(18, 21)`. Enter `MAP_SILPH_CO_1F`.
6. `MAP_SILPH_CO_1F` - talk to `SILPHCO1F_OFFICER` at `(13, 1)`. Precondition: `EVENT_GOT_UP_GRADE` clear, item pocket has room. Postcondition: `UP_GRADE` in bag, `EVENT_GOT_UP_GRADE` set. Exit warp 1 `(2, 7)`.
7. (Optional, dialogue only) `MAP_SAFFRON_CITY` warp 6 at `(8, 3)` -> `MAP_SAFFRON_MAGNET_TRAIN_STATION`; talk to `SAFFRONMAGNETTRAINSTATION_OFFICER` at `(9, 9)`. Expect the "isn't operating now" arm because `EVENT_RESTORED_POWER_TO_KANTO` is clear. Exit warp 1 `(8, 17)`.
8. (Optional) `MAP_SAFFRON_CITY` warp 3 at `(25, 11)` -> `MAP_SAFFRON_MART`; talk to `SAFFRONMART_CLERK` at `(1, 3)` for `MART_SAFFRON`. Exit warp 1 `(2, 7)`.
9. `MAP_SAFFRON_CITY` - warp 1 at `(26, 3)` -> `MAP_FIGHTING_DOJO`. Walk onto / face `FIGHTINGDOJO_POKE_BALL` at `(3, 1)`. Precondition: `EVENT_PICKED_UP_FOCUS_BAND` clear. Postcondition: `FOCUS_BAND` in bag, `EVENT_PICKED_UP_FOCUS_BAND` set (ball object masked from then on). Exit warp 1 `(4, 11)`.
10. (Optional heal) `MAP_SAFFRON_CITY` warp 4 at `(9, 29)` -> `MAP_SAFFRON_POKECENTER_1F`; talk to nurse at `(3, 1)`. Exit warp 1 `(3, 7)`.
11. `MAP_SAFFRON_CITY` - warp 2 at `(34, 3)` -> `MAP_SAFFRON_GYM`, landing on warp 1 `(8, 17)`.
12. `MAP_SAFFRON_GYM` - walk to the pad at `(11, 15)`. Warps to `(19, 17)`.
13. `MAP_SAFFRON_GYM` BR room - battle `SAFFRONGYM_GRANNY1` (Medium Rebecca) at `(17, 16)`, sight 3. Precondition: `EVENT_BEAT_MEDIUM_REBECCA` clear. Postcondition: that flag set. (Skippable: her flag is force-set by the Sabrina script.)
14. `MAP_SAFFRON_GYM` - step on pad `(15, 17)`. Warps to `(5, 15)`.
15. `MAP_SAFFRON_GYM` BL room - battle `SAFFRONGYM_YOUNGSTER1` (Psychic Franklin) at `(3, 16)`, sight 3. Postcondition: `EVENT_BEAT_PSYCHIC_FRANKLIN` set.
16. `MAP_SAFFRON_GYM` - step on pad `(1, 15)`. Warps to `(19, 5)`.
17. `MAP_SAFFRON_GYM` TR room - battle `SAFFRONGYM_YOUNGSTER2` (Psychic Jared) at `(17, 4)`, sight 2. Postcondition: `EVENT_BEAT_PSYCHIC_JARED` set.
18. `MAP_SAFFRON_GYM` - step on pad `(15, 5)`. Warps to `(1, 3)`.
19. `MAP_SAFFRON_GYM` TL room - battle `SAFFRONGYM_GRANNY2` (Medium Doris) at `(3, 4)`, sight 2. Postcondition: `EVENT_BEAT_MEDIUM_DORIS` set.
20. `MAP_SAFFRON_GYM` - step on pad `(1, 5)`. Warps to `(11, 9)`, Sabrina's chamber.
21. `MAP_SAFFRON_GYM` - talk to `SAFFRONGYM_SABRINA` at `(9, 8)` (stand at `(9, 9)` facing up, or `(10, 8)` facing left). Precondition: `ENGINE_MARSHBADGE` clear. Battle `SABRINA`/`SABRINA1`. Postcondition: `EVENT_BEAT_SABRINA`, the four trainer flags, and `ENGINE_MARSHBADGE` all set; +4800G.
22. `MAP_SAFFRON_GYM` exit - `(11, 9)` -> `(1, 5)`; walk right to `(5, 5)` -> `(1, 11)`; walk right to `(5, 11)` -> `(5, 17)`; walk up to `(5, 15)` -> `(15, 17)`; walk right to `(19, 17)` -> `(11, 15)`; walk down to warp 1/2 at `(8, 17)`/`(9, 17)` -> `MAP_SAFFRON_CITY` warp 2 `(34, 3)`.
23. Mid-gym heal-and-return (if step 21 needs a fresh party): exit via step 22, heal at `MAP_SAFFRON_POKECENTER_1F`, re-enter, then `(11,15) -> (19,17)`, up to `(19,15) -> (19,9)`, left to `(15,9) -> (15,3)`, down to `(15,5) -> (1,3)`, down to `(1,5) -> (11,9)`. This is the walkthrough's "1st teleporter, then up, left, down, down" and it checks out against the pad table.

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map load, block grid, `COLL_*` collision, connections | `src/world/gen2/Map.lua`, `src/world/gen2/Permissions.lua`, `src/world/gen2/World.lua` | Implemented (generic; Gold maps come from `src/import/RomExtractorGen2.lua`, not hand-ported) |
| Warp panels / teleport pads (the whole gym maze) | `src/world/gen2/Permissions.lua:195` `COLL_WARP_PANEL = 0x7c` in `WARP_FACING_DOWN`, `Permissions.warpFacesDown`; warp taking in `src/world/gen2/World.lua:1566` `World:warpTo` | Implemented (panels warp on landing, which is what all 30 gym pads are) |
| Map-to-self warps (every gym pad targets `SAFFRON_GYM`) | `src/world/gen2/World.lua` warp handling | Implemented, but untested for this map - no driver exercises a same-map warp chain |
| `MAPCALLBACK_NEWMAP` -> `setflag ENGINE_FLYPOINT_SAFFRON` | `src/world/gen2/World.lua:5659` `self:runMapCallback("MAPCALLBACK_NEWMAP")`; fly-point row at `src/world/gen2/FieldMoves.lua:365` (`LANDMARK_SAFFRON_CITY` / `SPAWN_SAFFRON` / flag 59) | Implemented |
| Script opcodes used by every script in this section (`checkevent`, `iftrue`, `iffalse`, `setevent`, `checkflag`, `setflag`, `verbosegiveitem`, `promptbutton`, `writetext`, `waitbutton`, `jumptext`, `jumptextfaceplayer`, `jumpstd`, `gettrainername`, `pokemart`, `yesorno`, `checkitem`, `applymovement`, `special`, `warpcheck`, `newloadmap`, `loadtrainer`, `startbattle`, `reloadmapafterbattle`, `winlosstext`, `endifjustbattled`, `playsound`, `waitsfx`) | `src/script/gen2/Opcodes.lua`, `src/script/gen2/Vm.lua` (`checkflag` :195, `verbosegiveitem` :490, `pokemart` :597, `jumpstd` :742, `loadtrainer` :806, `startbattle` :817, `winlosstext` :918) | Implemented |
| Object visibility from event flags (the Route 6 blocker, the station's hidden Teacher/Lass, the picked-up Focus Band ball) | `src/world/gen2/Events.lua:1-2` documents and implements "flag SET -> object hidden", matching `CheckObjectFlag` | Implemented |
| Overworld trainer sight + battle handoff (Rebecca, Franklin, Doris, Jared) | `src/world/gen2/Trainers.lua` (eyesight from `home/trainers.asm`, party build) | Implemented |
| Gym leader battle, badge grant, prize money x4 | `src/battle/gen2/Battle.lua`; `src/battle/gen2/Prize.lua:82` `Prize.reward(baseMoney, level)` and `:181` `local quarter = ...` (the four-way payout) | Implemented |
| Item ball pickup (`FOCUS_BAND` in the Fighting Dojo) | Extracted at `src/import/RomExtractorGen2.lua:2968-2969` into `obj.itemball`, but **nothing reads `obj.itemball` at runtime** (grep for `.itemball` in `src/` hits only the extractor). `src/script/gen2/CallAsm.lua:551` explicitly stubs `TryReceiveItem` | **Missing** - the ball object will exist and be masked correctly by its flag, but stepping on it grants nothing |
| Magnet Train ride (`special MagnetTrain`) | `src/core/gen2/MagnetTrain.lua`, `src/ui/gen2/MagnetTrainRide.lua` | Implemented (not exercised in this section - the officer's gate is false here) |
| Mart (`pokemart MARTTYPE_STANDARD, MART_SAFFRON`) | `src/ui/gen2/MartMenu.lua`, `Vm.lua:597` | Implemented |
| Pokecenter heal (`jumpstd PokecenterNurseScript`) | std scripts extracted (`src/import/RomExtractorGen2.lua:2901`), heal hook `src/script/gen2/Specials.lua:451` | Implemented |
| Bicycle | `src/world/gen2/Bike.lua` | Implemented |
| Any Saffron-specific hand-ported content | none | **Missing by design** - the Gen 2 port is data-driven off the ROM; there are no `SAFFRON` symbols anywhere under `src/` except Gen 1 save-conversion tables (`src/save_convert/`), which are unrelated |
| Driver coverage for this section | `tests/drivers/gold_*.lua` (25 drivers: boot, walk, warp, trainer, battle, map callbacks, ...) | **Missing** - no driver reaches Kanto or Saffron; `gold_warp_scene.lua` / `gold_walk_smoke.lua` are Johto-early smoke tests |

## 6. Unresolved / verify by hand

- **Psychic Jared's third Pokemon.** The walkthrough lists "Level 32 Exeggcute (672 EXP)" twice. `data/trainers/parties.asm:2569-2574` gives `PSYCHIC_T (11) JARED` as L32 `MR__MIME`, L32 `EXEGGCUTE`, **L35** `EXEGGCUTE`. The asm wins; the walkthrough's second Exeggcute level and its EXP figure are both wrong.
- **EXP values.** None of the per-Pokemon EXP numbers in the walkthrough (765, 1237, 1149, 735, 672, 720, 1264, 1941, 1339, 1912) were checked against `data/pokemon/base_stats/` - they are outside what a bot needs and were not verified.
- **"PokeMart ... upper-right corner of Saffron City".** The mart door is warp 3 at `(25, 11)` on a 40x36-cell map, i.e. north-of-centre and east of the middle, not the corner. The two gyms it says are "further north" are at `(26, 3)` and `(34, 3)`, which is correct.
- **"Silph Co ... the multi-story building above the Pokémon Center".** Silph is warp 7 at `(18, 21)`; the Pokecenter is warp 4 at `(9, 29)`. Silph is north-**east** of it, and `SilphCo1F` has no stairs warp - only the two street doors. There is no upper floor in Gen 2.
- **"You now have 10 badges!"** `ENGINE_MARSHBADGE` is bit 5 of `wKantoBadges` (`constants/engine_flags.asm:52`), so it is the 6th Kanto badge in flag order, not the 10th badge overall. The count of 10 only holds for a player who took Vermilion before Saffron, as this FAQ's chapter order does. Nothing in the asm enforces that order.
- **The walkthrough's mid-maze "left/right (whichever way works) till you find that one trainer again (Franklin)" heal route** is deliberately vague in the source text and was not reduced to a single pad sequence. The precise post-heal route it gives afterwards ("1st teleporter, then up, left, down, down") *does* resolve cleanly and is recorded in bot checklist step 23.
- **The "large man who blocks the entire entrance to the Underground Path"** is described as taunting the player about moving boulders. `Route6PokefanMText` (`maps/Route6.asm:15`) contains only the Power Plant line; no boulder or strength text exists on this map. Treat the boulder remark as FAQ colour.

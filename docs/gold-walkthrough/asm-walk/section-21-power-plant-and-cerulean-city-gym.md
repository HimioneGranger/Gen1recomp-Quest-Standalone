# Section 21 - Power Plant and Cerulean City Gym

Source: `../section-21-power-plant-and-cerulean-city-gym.txt`
Maps covered: `MAP_ROUTE_5`, `MAP_ROUTE_5_SAFFRON_GATE`, `MAP_ROUTE_5_CLEANSE_TAG_HOUSE`,
`MAP_ROUTE_5_UNDERGROUND_PATH_ENTRANCE`, `MAP_CERULEAN_CITY`, `MAP_CERULEAN_GYM`,
`MAP_ROUTE_9`, `MAP_ROUTE_10_NORTH`, `MAP_POWER_PLANT`, `MAP_ROUTE_24`,
`MAP_ROUTE_25`, `MAP_BILLS_HOUSE`
Badges / key milestones in this section: CASCADEBADGE (`ENGINE_CASCADEBADGE`) from Misty;
the whole Machine Part chain (`EVENT_MET_MANAGER_AT_POWER_PLANT` ->
`EVENT_MET_ROCKET_GRUNT_AT_CERULEAN_GYM` -> Route 24 grunt battle ->
`EVENT_FOUND_MACHINE_PART_IN_CERULEAN_GYM`); Misty's date on Route 25 clears
`EVENT_TRAINERS_IN_CERULEAN_GYM` and is what actually populates the gym.

Coordinate note: `warp_event` / `bg_event` / `object_event` / `coord_event` x,y are in
*map cells* (walk tiles), while `map_const NAME, W, H` in `constants/map_constants.asm`
is in *blocks*. Cells = 2x blocks, so `map_const ROUTE_9, 30, 9` is a 60x18 cell map and
`warp_event 48, 15` is inside it.

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `MAP_ROUTE_5_SAFFRON_GATE` | `maps/Route5SaffronGate.asm` | from `SAFFRON_CITY` warp 9 into gate warps 3/4 (`4,7` / `5,7`) | gate warps 1/2 (`4,0` / `5,0`) -> `ROUTE_5` warps 2/3 | "head north through the route-changing station" |
| 2 | `MAP_ROUTE_5` | `maps/Route5.asm` | gate warps | north connection -> `CERULEAN_CITY` | walk north; optional detour to the old Day Care building |
| 3 | `MAP_ROUTE_5_CLEANSE_TAG_HOUSE` | `maps/Route5CleanseTagHouse.asm` | `ROUTE_5` warp 4 at `10,11` | warps 1/2 at `2,7` / `3,7` -> `ROUTE_5` warp 4 | granny gives CLEANSE_TAG |
| 4 | `MAP_CERULEAN_CITY` | `maps/CeruleanCity.asm` | south connection from `ROUTE_5` | warp 5 at `30,23` -> `CERULEAN_GYM` | first (empty) gym visit |
| 5 | `MAP_CERULEAN_GYM` | `maps/CeruleanGym.asm` | `CERULEAN_CITY` warp 5 | warps 1/2 at `4,15` / `5,15` | gym is empty: `EVENT_TRAINERS_IN_CERULEAN_GYM` is still set from `InitializeEventsScript` |
| 6 | `MAP_ROUTE_9` | `maps/Route9.asm` | east connection from `CERULEAN_CITY` | south connection -> `ROUTE_10_NORTH` | six trainers; needs CUT at the west entrance |
| 7 | `MAP_ROUTE_10_NORTH` | `maps/Route10North.asm` | north connection from `ROUTE_9` | warp 2 at `3,9` -> `POWER_PLANT` | Pokemon Center at warp 1 (`11,1`); Surf the river to the plant |
| 8 | `MAP_POWER_PLANT` | `maps/PowerPlant.asm` | `ROUTE_10_NORTH` warp 2 | warps 1/2 at `2,17` / `3,17` | talk to the MANAGER, then trip the `5,12` coord event on the way out |
| 9 | `MAP_CERULEAN_CITY` | `maps/CeruleanCity.asm` | FLY (`SPAWN_CERULEAN`, `data/maps/spawn_points.asm:17`) | warp 5 -> `CERULEAN_GYM` | "Fly back to Cerulean City" |
| 10 | `MAP_CERULEAN_GYM` | `maps/CeruleanGym.asm` | `CERULEAN_CITY` warp 5 | warps 1/2 | `SCENE_CERULEANGYM_GRUNT_RUNS_OUT` fires on entry |
| 11 | `MAP_ROUTE_24` | `maps/Route24.asm` | north connection from `CERULEAN_CITY` | north connection -> `ROUTE_25` | Rocket grunt on the old Nugget Bridge |
| 12 | `MAP_ROUTE_25` | `maps/Route25.asm` | south connection from `ROUTE_24` | warp 1 at `47,5` -> `BILLS_HOUSE` | six-pack trainers, Kevin's Nugget, Protein, Misty's date coord events |
| 13 | `MAP_BILLS_HOUSE` | `maps/BillsHouse.asm` | `ROUTE_25` warp 1 | warps 1/2 at `2,7` / `3,7` | Bill's grandpa evolution-stone chain |
| 14 | `MAP_CERULEAN_CITY` -> `MAP_CERULEAN_GYM` | `maps/CeruleanGym.asm` | FLY, then warp 5 | - | three Swimmers, hidden MACHINE_PART at `3,8`, Misty |

Spills into the next section: `maps/Route9.asm` warp 1 at `48,15` leads to `ROCK_TUNNEL_1F`,
and the Machine Part is *returned* to `PowerPlantManager` (which is what unlocks the Magnet
Train and the Underground Path). The walkthrough text stops at Misty; Rock Tunnel / Lavender
and the return trip belong to the neighbouring sections.

## 2. Maps

### MAP_ROUTE_5

- Script: `maps/Route5.asm`
- Blocks: `maps/Route5.blk`
- Header: `data/maps/maps.asm:489` -> `map Route5, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_5, MUSIC_ROUTE_3, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:453` -> `map_const ROUTE_5, 10, 9` (group `SAFFRON` = 25, id 1)
- Connections (`data/maps/attributes.asm:356`): north `CERULEAN_CITY` (offset -5), south `SAFFRON_CITY` (offset -5)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 17 | 15 | `ROUTE_5_UNDERGROUND_PATH_ENTRANCE` | 1 |
| 2 | 8 | 17 | `ROUTE_5_SAFFRON_GATE` | 1 |
| 3 | 9 | 17 | `ROUTE_5_SAFFRON_GATE` | 2 |
| 4 | 10 | 11 | `ROUTE_5_CLEANSE_TAG_HOUSE` | 1 |

**Coord events** - none (`def_coord_events` is empty).

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 17 | 17 | `BGEVENT_READ` | `Route5UndergroundPathSign` |
| 10 | 11 | `BGEVENT_READ` | `HouseForSaleSign` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE5_POKEFAN_M` | `SPRITE_POKEFAN_M` | 17 | 16 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route5PokefanMScript` | `EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH` |

**Scripts of interest**

- `Route5PokefanMScript` - one `jumptextfaceplayer Route5PokefanMText`: "The road is closed
  until the problem at the POWER PLANT is solved." He stands at `17,16`, directly below the
  Underground Path door at `17,15`, so the tile is physically blocked. His object row carries
  `EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH`; object events are hidden when their
  flag is *set*, and that flag is not in `InitializeEventsScript`, so at this point in the
  game it is clear and he is present. `PowerPlantManager` `setevent`s it after the part is
  returned (`maps/PowerPlant.asm:164`), removing him.
- `Route5UndergroundPathSign` / `HouseForSaleSign` - plain `jumptext`. Note the "House for
  Sale" sign shares the exact tile `10,11` with warp 4 into the Cleanse Tag house.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH` | `constants/event_flags.asm:1299` | object row `maps/Route5.asm:56` and `maps/Route6.asm:43`; `setevent` at `maps/PowerPlant.asm:164` | clear = NPC present and Underground Path door unreachable; set = NPC gone |

**Items** - none on the route proper.

**Wild encounters** - `data/wild/kanto_grass.asm:425` `def_grass_wildmons ROUTE_5`,
10/10/10 percent. Gold morn+day: L13 PIDGEY, L13 BELLSPROUT, L14 PIDGEY, L15 PIDGEY,
L12 ABRA, L14 ABRA, L14 ABRA. Gold nite: L13 ODDISH, L14 ODDISH, L13 BELLSPROUT,
L15 GLOOM, L12 ABRA, L14 ABRA, L14 ABRA. No water table. Fishing group `FISHGROUP_SHORE`
(`data/wild/fish.asm` `.Shore_*`).

---

### MAP_ROUTE_5_SAFFRON_GATE

- Script: `maps/Route5SaffronGate.asm`
- Blocks: shared, `data/maps/blocks.asm`
- Header: `data/maps/maps.asm:502` -> `map Route5SaffronGate, TILESET_GATE, GATE, LANDMARK_ROUTE_5, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:466` -> `map_const ROUTE_5_SAFFRON_GATE, 5, 4` (group 25, id 14)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 0 | `ROUTE_5` | 2 |
| 2 | 5 | 0 | `ROUTE_5` | 3 |
| 3 | 4 | 7 | `SAFFRON_CITY` | 9 |
| 4 | 5 | 7 | `SAFFRON_CITY` | 9 |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE5SAFFRONGATE_OFFICER` | `SPRITE_OFFICER` | 0 | 4 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `Route5SaffronGateOfficerScript` | -1 |

Nothing here gates progress: the officer is a single `jumptextfaceplayer`, and there are no
coord or bg events.

---

### MAP_ROUTE_5_CLEANSE_TAG_HOUSE

- Script: `maps/Route5CleanseTagHouse.asm`
- Blocks: shared, `data/maps/blocks.asm:196` (`Route5CleanseTagHouse_Blocks`)
- Header: `data/maps/maps.asm:503` -> `map Route5CleanseTagHouse, TILESET_HOUSE, INDOOR, LANDMARK_ROUTE_5, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:467` -> `map_const ROUTE_5_CLEANSE_TAG_HOUSE, 4, 4` (group 25, id 15)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `ROUTE_5` | 4 |
| 2 | 3 | 7 | `ROUTE_5` | 4 |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `HouseForSaleBookshelf` (`jumpstd DifficultBookshelfScript`) |
| 1 | 1 | `BGEVENT_READ` | `HouseForSaleBookshelf` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE5CLEANSETAGHOUSE_GRANNY` | `SPRITE_GRANNY` | 2 | 5 | `SPRITEMOVEDATA_SPINCLOCKWISE` | `OBJECTTYPE_SCRIPT` | `Route5CleanseTagHouseGrannyScript` | -1 |
| `ROUTE5CLEANSETAGHOUSE_TEACHER` | `SPRITE_TEACHER` | 5 | 3 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `Route5CleanseTagHouseTeacherScript` | -1 |

**Scripts of interest**

- `Route5CleanseTagHouseGrannyScript` (`pokegold.sym` `61:57de`) -
  `faceplayer` / `opentext` / `checkevent EVENT_GOT_CLEANSE_TAG` / `iftrue .GotCleanseTag`;
  otherwise `writetext Route5CleanseTagHouseGrannyText1`, `promptbutton`,
  `verbosegiveitem CLEANSE_TAG`, `iffalse .NoRoom`, `setevent EVENT_GOT_CLEANSE_TAG`,
  then the "you are protected now" line. Bag-full drops straight to `.NoRoom` without
  setting the flag, so a bot must have a free pocket slot or repeat the talk.

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `CLEANSE_TAG` | talk to `ROUTE5CLEANSETAGHOUSE_GRANNY` at `2,5` | `Route5CleanseTagHouseGrannyScript`, `verbosegiveitem CLEANSE_TAG` | `EVENT_GOT_CLEANSE_TAG` (`constants/event_flags.asm:218`) |

---

### MAP_ROUTE_5_UNDERGROUND_PATH_ENTRANCE

- Script: `maps/Route5UndergroundPathEntrance.asm`
- Header: `data/maps/maps.asm:501` -> `map Route5UndergroundPathEntrance, TILESET_GATE, GATE, LANDMARK_ROUTE_5, MUSIC_ROUTE_3, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:465` -> `map_const ROUTE_5_UNDERGROUND_PATH_ENTRANCE, 4, 4` (group 25, id 13)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `ROUTE_5` | 1 |
| 2 | 4 | 7 | `ROUTE_5` | 1 |
| 3 | 4 | 3 | `UNDERGROUND_PATH` | 1 |

Only reachable once the Route 5 Pokefan is gone. Listed here because the walkthrough calls
him out; nothing in this section actually enters it.

---

### MAP_CERULEAN_CITY

- Script: `maps/CeruleanCity.asm`
- Blocks: `maps/CeruleanCity.blk`
- Header: `data/maps/maps.asm:221` -> `map CeruleanCity, TILESET_KANTO, TOWN, LANDMARK_CERULEAN_CITY, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_AUTO, FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:203` -> `map_const CERULEAN_CITY, 20, 18` (group `CERULEAN` = 7, id 17)
- Connections (`data/maps/attributes.asm:360`): north `ROUTE_24` (+6), south `ROUTE_5` (+5), west `ROUTE_4` (+5), east `ROUTE_9` (+9)
- Fly / spawn: `data/maps/spawn_points.asm:17` `spawn CERULEAN_CITY, 19, 22`;
  `data/maps/flypoints.asm:21` `db LANDMARK_CERULEAN_CITY, SPAWN_CERULEAN`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 7 | 15 | `CERULEAN_GYM_BADGE_SPEECH_HOUSE` | 1 |
| 2 | 28 | 17 | `CERULEAN_POLICE_STATION` | 1 |
| 3 | 13 | 19 | `CERULEAN_TRADE_SPEECH_HOUSE` | 1 |
| 4 | 19 | 21 | `CERULEAN_POKECENTER_1F` | 1 |
| 5 | 30 | 23 | `CERULEAN_GYM` | 1 |
| 6 | 25 | 29 | `CERULEAN_MART` | 2 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 23 | 23 | `BGEVENT_READ` | `CeruleanCitySign` |
| 27 | 25 | `BGEVENT_READ` | `CeruleanGymSign` |
| 11 | 29 | `BGEVENT_READ` | `CeruleanBikeShopSign` ("The BIKE SHOP has moved to GOLDENROD") |
| 25 | 17 | `BGEVENT_READ` | `CeruleanPoliceSign` |
| 23 | 7 | `BGEVENT_READ` | `CeruleanCapeSign` |
| 14 | 29 | `BGEVENT_READ` | `CeruleanLockedDoor` |
| 20 | 21 | `BGEVENT_READ` | `CeruleanCityPokecenterSign` |
| 26 | 29 | `BGEVENT_READ` | `CeruleanCityMartSign` |
| 2 | 12 | `BGEVENT_ITEM` | `CeruleanCityHiddenBerserkGene` -> `hiddenitem BERSERK_GENE, EVENT_FOUND_BERSERK_GENE_IN_CERULEAN_CITY` (`pokegold.sym` `4f:60ad`) |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `CERULEANCITY_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 15 | 23 | `SPRITEMOVEDATA_WANDER` (2,2) | `OBJECTTYPE_SCRIPT` | `CeruleanCityCooltrainerMScript` | -1 |
| `CERULEANCITY_SUPER_NERD` | `SPRITE_SUPER_NERD` | 23 | 15 | `SPRITEMOVEDATA_WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `CeruleanCitySuperNerdScript` | -1 |
| `CERULEANCITY_SLOWPOKE` | `SPRITE_SLOWPOKE` | 20 | 24 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `CeruleanCitySlowbro` | -1 |
| `CERULEANCITY_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 21 | 24 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `CeruleanCityCooltrainerFScript` | -1 |
| `CERULEANCITY_FISHER` | `SPRITE_FISHER` | 30 | 26 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (1,0) | `OBJECTTYPE_SCRIPT` | `CeruleanCityFisherScript` | -1 |
| `CERULEANCITY_YOUNGSTER` | `SPRITE_YOUNGSTER` | 6 | 12 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` (1,0) | `OBJECTTYPE_SCRIPT` | `CeruleanCityYoungsterScript` | -1 |

**Scripts of interest**

- `CeruleanCityFlypointCallback` - `MAPCALLBACK_NEWMAP`, `setflag ENGINE_FLYPOINT_CERULEAN`
  then `endcallback`. Simply entering the city registers the Fly destination the walkthrough
  relies on twice.
- `CeruleanCityCooltrainerMScript` - `checkevent EVENT_RETURNED_MACHINE_PART`; before the
  part is returned he is the hint "KANTO's POWER PLANT is toward the end of ROUTE 9".
- `CeruleanCityFisherScript` - `checkevent EVENT_RETURNED_MACHINE_PART` (iftrue -> generic
  line), else `checkevent EVENT_MET_ROCKET_GRUNT_AT_CERULEAN_GYM` -> "I saw this shady guy
  go off toward CERULEAN's CAPE", i.e. the pointer to Route 24/25.
- `CeruleanCityYoungsterScript` - after his first line, if
  `EVENT_FOUND_BERSERK_GENE_IN_CERULEAN_CITY` is clear he plays the ITEMFINDER ping loop
  (`SFX_SECOND_PART_OF_ITEMFINDER` / `SFX_TRANSACTION` x4) and `showemote EMOTE_SHOCK`.
  That is the in-game hint for the hidden BERSERK_GENE at `2,12`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_CERULEAN` | `constants/engine_flags.asm:70` | `CeruleanCityFlypointCallback` | Fly target unlocked on first entry |
| `EVENT_MET_ROCKET_GRUNT_AT_CERULEAN_GYM` | `constants/event_flags.asm:202` | set by `CeruleanGymGruntRunsOutScript`; read by `CeruleanCityFisherScript` | grunt cutscene has played |
| `EVENT_RETURNED_MACHINE_PART` | `constants/event_flags.asm:200` | set by `PowerPlantManager`; read here and in ~10 other maps | post-section state |
| `EVENT_FOUND_BERSERK_GENE_IN_CERULEAN_CITY` | `constants/event_flags.asm:250` | `CeruleanCityHiddenBerserkGene`, `CeruleanCityYoungsterScript` | hidden item consumed |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `BERSERK_GENE` | face the tile and press A (hidden) | `bg_event 2, 12, BGEVENT_ITEM, CeruleanCityHiddenBerserkGene` | `EVENT_FOUND_BERSERK_GENE_IN_CERULEAN_CITY` |

**Wild encounters** - no grass table. Water: `data/wild/kanto_water.asm:131`
`def_water_wildmons CERULEAN_CITY`, 4 percent: L10 GOLDEEN, L5 GOLDEEN, L10 SEAKING.
Fishing group `FISHGROUP_LAKE`.

---

### MAP_CERULEAN_GYM

- Script: `maps/CeruleanGym.asm`
- Blocks: `maps/CeruleanGym.blk`
- Header: `data/maps/maps.asm:210` -> `map CeruleanGym, TILESET_PORT, INDOOR, LANDMARK_CERULEAN_CITY, MUSIC_GYM, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
  (the `data/maps/maps.asm:209` comment notes the known bug that you can fish in the gym pool)
- Dimensions: `constants/map_constants.asm:192` -> `map_const CERULEAN_GYM, 5, 8` (group 7, id 6)
- Scenes (`def_scene_scripts`, index order from `macros/scripts/maps.asm` `def_scene_scripts`/`scene_const`):
  `SCENE_CERULEANGYM_NOOP` = 0, `SCENE_CERULEANGYM_GRUNT_RUNS_OUT` = 1.
  Scene var: `data/maps/scenes.asm:13` `scene_var CERULEAN_GYM, wCeruleanGymSceneID`.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 15 | `CERULEAN_CITY` | 5 |
| 2 | 5 | 15 | `CERULEAN_CITY` | 5 |

**Coord events** - none. The grunt cutscene runs from the *scene script*
(`CeruleanGymGruntRunsOutScene` -> `sdefer CeruleanGymGruntRunsOutScript`), which fires on
map load while `wCeruleanGymSceneID == SCENE_CERULEANGYM_GRUNT_RUNS_OUT`, not from a tile.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 3 | 8 | `BGEVENT_ITEM` | `CeruleanGymHiddenMachinePart` -> `hiddenitem MACHINE_PART, EVENT_FOUND_MACHINE_PART_IN_CERULEAN_GYM` (`pokegold.sym` `54:440e`) |
| 2 | 13 | `BGEVENT_READ` | `CeruleanGymStatue1` |
| 6 | 13 | `BGEVENT_READ` | `CeruleanGymStatue2` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `CERULEANGYM_ROCKET` | `SPRITE_ROCKET` | 4 | 10 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` (inert; driven by the scene script) | `EVENT_CERULEAN_GYM_ROCKET` |
| `CERULEANGYM_MISTY` | `SPRITE_MISTY` | 5 | 3 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CeruleanGymMistyScript` | `EVENT_TRAINERS_IN_CERULEAN_GYM` |
| `CERULEANGYM_SWIMMER_GIRL1` | `SPRITE_SWIMMER_GIRL` | 4 | 6 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerSwimmerfDiana` | `EVENT_TRAINERS_IN_CERULEAN_GYM` |
| `CERULEANGYM_SWIMMER_GIRL2` | `SPRITE_SWIMMER_GIRL` | 1 | 9 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerSwimmerfBriana` | `EVENT_TRAINERS_IN_CERULEAN_GYM` |
| `CERULEANGYM_SWIMMER_GUY` | `SPRITE_SWIMMER_GUY` | 8 | 9 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerSwimmermParker` | `EVENT_TRAINERS_IN_CERULEAN_GYM` |
| `CERULEANGYM_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 7 | 13 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CeruleanGymGuideScript` | `EVENT_TRAINERS_IN_CERULEAN_GYM` |

**Scripts of interest**

- `CeruleanGymGruntRunsOutScript` (`pokegold.sym` `54:4336`) - the grunt runs down four
  `big_step DOWN`, `playsound SFX_TACKLE`, jumps into the player
  (`CeruleanGymGruntRunsIntoYouMovement`: `fix_facing` / `set_sliding` / `jump_step UP`),
  `playmusic MUSIC_ROCKET_ENCOUNTER`, three text boxes with a `showemote EMOTE_SHOCK`
  between them, then `CeruleanGymGruntRunsOutMovement` (`big_step RIGHT`, `big_step DOWN`),
  `playsound SFX_EXIT_BUILDING`, `disappear CERULEANGYM_ROCKET`. State changes, in order:
  `setevent EVENT_MET_ROCKET_GRUNT_AT_CERULEAN_GYM`,
  `clearevent EVENT_ROUTE_24_ROCKET` (spawns the grunt on Route 24),
  `clearevent EVENT_ROUTE_25_MISTY_BOYFRIEND` (spawns Misty + her date on Route 25),
  `setscene SCENE_CERULEANGYM_NOOP`,
  `setmapscene ROUTE_25, SCENE_ROUTE25_MISTYS_DATE`,
  `setmapscene POWER_PLANT, SCENE_POWERPLANT_NOOP`, then
  `special RestartMapMusic` and `turnobject PLAYER, DOWN`.
- `CeruleanGymMistyScript` (`pokegold.sym` `54:438a`) - `checkflag ENGINE_CASCADEBADGE`,
  `iftrue .FightDone`; else `MistyIntroText`, `winlosstext MistyWinLossText, 0`,
  `loadtrainer MISTY, MISTY1`, `startbattle`, `reloadmapafterbattle`, then
  `setevent EVENT_BEAT_MISTY` **and** `setevent EVENT_BEAT_SWIMMERF_DIANA`,
  `EVENT_BEAT_SWIMMERF_BRIANA`, `EVENT_BEAT_SWIMMERM_PARKER` (beating Misty retroactively
  marks the three gym trainers beaten), `ReceivedCascadeBadgeText`, `playsound SFX_GET_BADGE`,
  `setflag ENGINE_CASCADEBADGE`.
- `CeruleanGymStatue1` / `CeruleanGymStatue2` - `checkevent EVENT_TRAINERS_IN_CERULEAN_GYM`;
  if *false* (trainers present) they fall through to the shared `CeruleanGymStatue`
  (`jumpstd GymStatue1Script`, or `GymStatue2Script` with `gettrainername STRING_BUFFER_4, MISTY, MISTY1`
  once `ENGINE_CASCADEBADGE` is set). If true (gym empty) they print the "Sorry, I'll be out
  for a while - MISTY" / "Since MISTY's out, we'll be away too" notes.
- `CeruleanGymGuideScript` - `checkevent EVENT_BEAT_MISTY` for the post-win line.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_TRAINERS_IN_CERULEAN_GYM` | `constants/event_flags.asm:1297` | set in `engine/events/std_scripts.asm:550` (`InitializeEventsScript`); cleared by `Route25MistyDate1Script` / `Route25MistyDate2Script` | set = Misty, three Swimmers and the guide are all hidden. This is why the first gym visit is empty. |
| `EVENT_CERULEAN_GYM_ROCKET` | `constants/event_flags.asm:1295` | set at `std_scripts.asm:547`; cleared by `PowerPlantManager` (`maps/PowerPlant.asm:146`) | clear = grunt object exists so the scene can run |
| `EVENT_FOUND_MACHINE_PART_IN_CERULEAN_GYM` | `constants/event_flags.asm:251` | set at `std_scripts.asm:546`; cleared by `PowerPlantManager` (`maps/PowerPlant.asm:147`) | set = the hidden item at `3,8` yields nothing. Talking to the MANAGER is what arms it. |
| `EVENT_MET_ROCKET_GRUNT_AT_CERULEAN_GYM` | `constants/event_flags.asm:202` | `CeruleanGymGruntRunsOutScript` | cutscene done |
| `EVENT_BEAT_MISTY` | `constants/event_flags.asm:716` | `CeruleanGymMistyScript` | gym cleared |
| `ENGINE_CASCADEBADGE` | `constants/engine_flags.asm:48` | `CeruleanGymMistyScript` `checkflag` / `setflag` | the badge itself |
| `SCENE_CERULEANGYM_GRUNT_RUNS_OUT` (= 1) | `maps/CeruleanGym.asm:12` via `scene_const` | `setmapscene` at `maps/PowerPlant.asm:148`; cleared to `SCENE_CERULEANGYM_NOOP` at `maps/CeruleanGym.asm:49` | entering the gym with this scene id plays the grunt scene |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `MACHINE_PART` | stand at the pool and press A into `3,8` | `bg_event 3, 8, BGEVENT_ITEM, CeruleanGymHiddenMachinePart` | `EVENT_FOUND_MACHINE_PART_IN_CERULEAN_GYM` (must be cleared first by the MANAGER) |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `SWIMMERF, BRIANA` | `SWIMMERF` | 19 (`parties.asm:1885`) | L35 SEAKING, L35 SEAKING | `TrainerSwimmerfBriana` | none |
| `SWIMMERM, PARKER` | `SWIMMERM` | 21 (`parties.asm:1775`) | L32 HORSEA, L32 HORSEA, L35 SEADRA | `TrainerSwimmermParker` | none |
| `SWIMMERF, DIANA` | `SWIMMERF` | 18 (`parties.asm:1880`) | L37 GOLDUCK | `TrainerSwimmerfDiana` | none |
| `MISTY, MISTY1` | `MISTY` | 1 (`parties.asm:281`, `TRAINERTYPE_MOVES`) | L42 GOLDUCK (SURF, DISABLE, PSYCH_UP, PSYCHIC_M); L42 QUAGSIRE (SURF, AMNESIA, EARTHQUAKE, RAIN_DANCE); L44 LAPRAS (SURF, PERISH_SONG, BLIZZARD, RAIN_DANCE); L47 STARMIE (SURF, CONFUSE_RAY, RECOVER, ICE_BEAM) | `CeruleanGymMistyScript` | leader, no phone |

Base rewards (`data/trainers/attributes.asm`): SWIMMERF 5, SWIMMERM 2, MISTY 25. Payout is
`ComputeTrainerReward` (`engine/battle/read_trainer_party.asm:300`) = base x last mon level,
added four times by the `ld c, 4` loop in `engine/battle/core.asm:2340`, i.e. base x level x 4.
That reproduces every number in the walkthrough (Misty 25 x 47 x 4 = 4700).

---

### MAP_ROUTE_9

- Script: `maps/Route9.asm`
- Blocks: `maps/Route9.blk`
- Header: `data/maps/maps.asm:217` -> `map Route9, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_9, MUSIC_ROUTE_3, FALSE, PALETTE_AUTO, FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:199` -> `map_const ROUTE_9, 30, 9` (group 7, id 13)
- Connections (`data/maps/attributes.asm:366`): south `ROUTE_10_NORTH` (+20), west `CERULEAN_CITY` (-9)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 48 | 15 | `ROCK_TUNNEL_1F` | 1 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 15 | 7 | `BGEVENT_READ` | `Route9Sign` |
| 10 | 5 | `BGEVENT_ITEM` | `Route9HiddenEther` -> `hiddenitem ETHER, EVENT_ROUTE_9_HIDDEN_ETHER` (`pokegold.sym` `50:407d`) |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE9_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 23 | 11 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerCamperDean` | -1 |
| `ROUTE9_LASS1` | `SPRITE_LASS` | 35 | 8 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` (sight 2) | `TrainerPicnickerHeidi` | -1 |
| `ROUTE9_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 11 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 2) | `TrainerCamperSid` | -1 |
| `ROUTE9_LASS2` | `SPRITE_LASS` | 9 | 10 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerPicnickerEdna` | -1 |
| `ROUTE9_POKEFAN_M1` | `SPRITE_POKEFAN_M` | 32 | 3 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 4) | `TrainerHikerTim` | -1 |
| `ROUTE9_POKEFAN_M2` | `SPRITE_POKEFAN_M` | 33 | 15 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` (sight 4) | `TrainerHikerSidney` | -1 |

**Scripts of interest** - all six are the plain `trainer CLASS, ID, EVENT_BEAT_*, seen, beaten, 0, .Script`
form with an `endifjustbattled` + one after-battle text. No flags beyond `EVENT_BEAT_*`.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `ETHER` | hidden, face `10,5` | `bg_event 10, 5, BGEVENT_ITEM, Route9HiddenEther` | `EVENT_ROUTE_9_HIDDEN_ETHER` (`constants/event_flags.asm:242`) |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `PICNICKER, EDNA` | `PICNICKER` | 14 (`parties.asm:2659`) | L30 NIDORINA, L34 RAICHU | `TrainerPicnickerEdna` | none |
| `CAMPER, SID` | `CAMPER` | 8 (`parties.asm:2744`) | L32 DUGTRIO, L29 PRIMEAPE, L29 POLIWRATH | `TrainerCamperSid` | none |
| `CAMPER, DEAN` | `CAMPER` | 7 (`parties.asm:2738`) | L33 GOLDUCK, L31 SANDSLASH | `TrainerCamperDean` | none |
| `HIKER, SIDNEY` | `HIKER` | 15 (`parties.asm:2210`) | L34 DUGTRIO, L32 ONIX | `TrainerHikerSidney` | none |
| `HIKER, TIM` | `HIKER` | 13 (`parties.asm:2197`) | L31 GRAVELER x3 | `TrainerHikerTim` | none |
| `PICNICKER, HEIDI` | `PICNICKER` | 13 (`parties.asm:2653`) | L32 SKIPLOOM, L32 SKIPLOOM | `TrainerPicnickerHeidi` | none |

Base rewards: PICNICKER 5, CAMPER 5, HIKER 8 (`data/trainers/attributes.asm`).

**Wild encounters** - `data/wild/kanto_grass.asm:645` `def_grass_wildmons ROUTE_9`, 10/10/10 percent,
version-split with `IF DEF(_GOLD)`. Gold morn/day: L13 MANKEY, L15 RATTATA, L13 SPEAROW,
L15 RATICATE, L15 FEAROW, L15 PRIMEAPE, L15 PRIMEAPE. Gold nite: L13 MANKEY, L15 RATTATA,
L15 RATICATE, L13 RATTATA, L15 RATICATE, L15 PRIMEAPE, L15 PRIMEAPE. (Silver swaps MANKEY /
PRIMEAPE for RATTATA / RATICATE, which is exactly the "Gold only" note in the walkthrough.)
Water: `data/wild/kanto_water.asm:19`, 4 percent: L15 GOLDEEN, L10 GOLDEEN, L15 SEAKING.
Fishing group `FISHGROUP_LAKE`. No `treemon_maps.asm` row, so no headbutt table.

---

### MAP_ROUTE_10_NORTH

- Script: `maps/Route10North.asm`
- Blocks: `maps/Route10North.blk`
- Header: `data/maps/maps.asm:218` -> `map Route10North, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_10, MUSIC_ROUTE_3, FALSE, PALETTE_AUTO, FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:200` -> `map_const ROUTE_10_NORTH, 10, 9` (group 7, id 14)
- Connections (`data/maps/attributes.asm:389`): north `ROUTE_9` (-20), south `ROUTE_10_SOUTH` (0)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 11 | 1 | `ROUTE_10_POKECENTER_1F` | 1 |
| 2 | 3 | 9 | `POWER_PLANT` | 1 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 5 | 11 | `BGEVENT_READ` | `PowerPlantSign` ("KANTO POWER PLANT") |
| 12 | 1 | `BGEVENT_READ` | `Route10PokecenterSign` (`jumpstd PokecenterSignScript`) |

**Object events** - `def_object_events` is empty. No trainers on this map.

**Wild encounters** - `data/wild/kanto_grass.asm:700` `def_grass_wildmons ROUTE_10_NORTH`,
10/10/10 percent, no version split.
morn: L16 SPEAROW, L17 VOLTORB, L16 RATICATE, L18 FEAROW, L16 QUAGSIRE, L15 ELECTABUZZ, L15 ELECTABUZZ.
day: L16 SPEAROW, L17 VOLTORB, L17 RATICATE, L18 FEAROW, L15 ELECTABUZZ, L17 ELECTABUZZ, L17 ELECTABUZZ.
nite: L16 QUAGSIRE, L17 VOLTORB, L16 RATICATE, L17 QUAGSIRE, L18 RATICATE, L15 ELECTABUZZ, L15 ELECTABUZZ.
Water: `data/wild/kanto_water.asm:26`, 4 percent: L15 GOLDEEN, L10 GOLDEEN, L15 SEAKING.
Fishing group `FISHGROUP_LAKE`.

---

### MAP_POWER_PLANT

- Script: `maps/PowerPlant.asm`
- Blocks: `maps/PowerPlant.blk`
- Header: `data/maps/maps.asm:214` -> `map PowerPlant, TILESET_FACILITY, INDOOR, LANDMARK_POWER_PLANT, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:196` -> `map_const POWER_PLANT, 10, 9` (group 7, id 10)
- Scenes: `SCENE_POWERPLANT_NOOP` = 0, `SCENE_POWERPLANT_GUARD_GETS_PHONE_CALL` = 1
  (`maps/PowerPlant.asm:11-12`); scene var `data/maps/scenes.asm:12`
  `scene_var POWER_PLANT, wPowerPlantSceneID`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 17 | `ROUTE_10_NORTH` | 2 |
| 2 | 3 | 17 | `ROUTE_10_NORTH` | 2 |

**Coord events**

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_POWERPLANT_GUARD_GETS_PHONE_CALL` (1) | 5 | 12 | `PowerPlantGuardPhoneScript` | the "shady character in CERULEAN" cutscene; ends with `setscene SCENE_POWERPLANT_NOOP` |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `PowerPlantBookshelf` (`jumpstd DifficultBookshelfScript`) |
| 1 | 1 | `BGEVENT_READ` | `PowerPlantBookshelf` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `POWERPLANT_OFFICER1` | `SPRITE_OFFICER` | 4 | 14 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `PowerPlantOfficerScript` | -1 |
| `POWERPLANT_GYM_GUIDE1` | `SPRITE_GYM_GUIDE` | 2 | 9 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `PowerPlantGymGuide1Script` | -1 |
| `POWERPLANT_GYM_GUIDE2` | `SPRITE_GYM_GUIDE` | 6 | 11 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `PowerPlantGymGuide2Script` | -1 |
| `POWERPLANT_OFFICER2` | `SPRITE_OFFICER` | 9 | 3 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `PowerPlantOfficer2Script` | -1 |
| `POWERPLANT_GYM_GUIDE3` | `SPRITE_GYM_GUIDE` | 7 | 2 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (1,0) | `OBJECTTYPE_SCRIPT` | `PowerPlantGymGuide4Script` | -1 |
| `POWERPLANT_MANAGER` | `SPRITE_FISHER` | 14 | 10 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `PowerPlantManager` | -1 |

(The object const list names the fifth guide `POWERPLANT_GYM_GUIDE3` while its script is
called `PowerPlantGymGuide4Script`; that mismatch is in the source, not a transcription slip.)

**Scripts of interest**

- `PowerPlantManager` (`pokegold.sym` `54:4dbd`) - the spine of the whole section:
  1. `checkevent EVENT_RETURNED_MACHINE_PART` -> `.ReturnedMachinePart`
  2. `checkitem MACHINE_PART` -> `.FoundMachinePart`
  3. `checkevent EVENT_MET_MANAGER_AT_POWER_PLANT` -> `.MetManager`
  4. first talk: `PowerPlantManagerWhoWouldRuinMyGeneratorText`, then
     `setevent EVENT_MET_MANAGER_AT_POWER_PLANT`,
     `clearevent EVENT_CERULEAN_GYM_ROCKET`,
     `clearevent EVENT_FOUND_MACHINE_PART_IN_CERULEAN_GYM`,
     `setmapscene CERULEAN_GYM, SCENE_CERULEANGYM_GRUNT_RUNS_OUT`,
     `setscene SCENE_POWERPLANT_GUARD_GETS_PHONE_CALL`.
  5. `.FoundMachinePart` (out of scope for this walkthrough section, listed because it is the
     payoff): `takeitem MACHINE_PART`, `setevent EVENT_RETURNED_MACHINE_PART`,
     `clearevent EVENT_SAFFRON_TRAIN_STATION_POPULATION`,
     `setevent EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH`,
     `setevent EVENT_ROUTE_24_ROCKET`, `setevent EVENT_RESTORED_POWER_TO_KANTO`,
     `clearevent EVENT_GOLDENROD_TRAIN_STATION_GENTLEMAN`, then
     `verbosegiveitem TM_ZAP_CANNON` guarded by `EVENT_GOT_TM07_ZAP_CANNON`.
- `PowerPlantGuardPhoneScript` - `playsound SFX_CALL`, `showemote EMOTE_SHOCK` on
  `POWERPLANT_OFFICER1`, `applymovement POWERPLANT_OFFICER1 PowerPlantOfficer1ApproachGymGuide2Movement`
  (RIGHT, RIGHT, UP, UP), two text boxes, then `PowerPlantOfficer1ReturnToPostMovement`
  (DOWN, DOWN, LEFT, LEFT, turn_head DOWN) and `setscene SCENE_POWERPLANT_NOOP`.
- The four flavour NPCs all branch only on `EVENT_RETURNED_MACHINE_PART`
  (`PowerPlantOfficerScript` additionally on `EVENT_MET_MANAGER_AT_POWER_PLANT`).

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_MET_MANAGER_AT_POWER_PLANT` | `constants/event_flags.asm:201` | `PowerPlantManager` | gate for everything downstream |
| `EVENT_CERULEAN_GYM_ROCKET` | `constants/event_flags.asm:1295` | cleared by `PowerPlantManager` | grunt object now exists in the gym |
| `EVENT_FOUND_MACHINE_PART_IN_CERULEAN_GYM` | `constants/event_flags.asm:251` | cleared by `PowerPlantManager` | the hidden item is now live |
| `SCENE_POWERPLANT_GUARD_GETS_PHONE_CALL` (1) | `maps/PowerPlant.asm:12` | `setscene`, then the `5,12` coord event | forces the exit cutscene once |
| `EVENT_RETURNED_MACHINE_PART` / `EVENT_RESTORED_POWER_TO_KANTO` | `constants/event_flags.asm:200` / `:204` | `.FoundMachinePart` | later-section state (Magnet Train, Underground Path, roaming beasts checks in `maps/Route26.asm` etc.) |
| `EVENT_GOT_TM07_ZAP_CANNON` | `constants/event_flags.asm:222` | `.ReturnedMachinePart` | TM07 reward |

**Items** - `TM_ZAP_CANNON` from the MANAGER, but only on the *return* trip, which the
walkthrough section does not cover.

**Trainers / wild encounters** - none.

---

### MAP_ROUTE_24

- Script: `maps/Route24.asm`
- Blocks: `maps/Route24.blk`
- Header: `data/maps/maps.asm:219` -> `map Route24, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_24, MUSIC_ROUTE_3, FALSE, PALETTE_AUTO, FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:201` -> `map_const ROUTE_24, 10, 9` (group 7, id 15)
- Connections (`data/maps/attributes.asm:370`): north `ROUTE_25` (0), south `CERULEAN_CITY` (-6)

**Warps** - `def_warp_events` is empty.
**Coord events** - empty.
**BG events** - empty.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE24_ROCKET` | `SPRITE_ROCKET` | 8 | 7 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `Route24RocketScript` | `EVENT_ROUTE_24_ROCKET` |

**Scripts of interest**

- `Route24RocketScript` (`pokegold.sym` `50:4407`) - `faceplayer`,
  `playmusic MUSIC_ROCKET_ENCOUNTER`, `Route24RocketSeenText`,
  `winlosstext Route24RocketBeatenText, -1`, `loadtrainer GRUNTM, GRUNTM_31`, `startbattle`,
  `dontrestartmapmusic`, `reloadmapafterbattle`, then `Route24RocketAfterBattleText`
  (the "MACHINE PART ... hide it I did in GYM of the CERULEAN ... Inside water put it I did"
  hint), `special FadeOutMusic`, `Route24RocketDisappearsText`, `special FadeOutToBlack`,
  `special ReloadSpritesNoPalettes`, `disappear ROUTE24_ROCKET`, `pause 25`,
  `special FadeInFromBlack`, `playmapmusic`.
  Note: he is *talked to*, not a sight-line trainer, and there is no `EVENT_BEAT_*` -
  `disappear` sets `EVENT_ROUTE_24_ROCKET` and that is the only record of the win.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ROUTE_24_ROCKET` | `constants/event_flags.asm:1294` | set at `engine/events/std_scripts.asm:548`; cleared by `CeruleanGymGruntRunsOutScript`; set again by `disappear` and by `PowerPlantManager:165` | clear = grunt is standing on the bridge at `8,7` |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `GRUNTM, GRUNTM_31` | `GRUNTM` | 31 (`data/trainers/parties.asm:1340`) | L30 GOLBAT | `Route24RocketScript` | none |

**Wild encounters** - `data/wild/kanto_grass.asm:1061` `def_grass_wildmons ROUTE_24`, 10/10/10 percent.
morn: L8 BELLSPROUT, L10 BELLSPROUT, L9 ABRA, L12 WEEPINBELL, L8 VENONAT, L14 WEEPINBELL, L14 WEEPINBELL.
day: L8 BELLSPROUT, L10 SUNKERN, L9 ABRA, L12 WEEPINBELL, L10 BELLSPROUT, L14 WEEPINBELL, L14 WEEPINBELL.
nite: L8 VENONAT, L10 ODDISH, L9 ABRA, L13 WEEPINBELL, L10 BELLSPROUT, L10 VENOMOTH, L10 VENOMOTH.
Water: `data/wild/kanto_water.asm:75`, 4 percent: L10 GOLDEEN, L5 GOLDEEN, L10 SEAKING.

---

### MAP_ROUTE_25

- Script: `maps/Route25.asm`
- Blocks: `maps/Route25.blk`
- Header: `data/maps/maps.asm:220` -> `map Route25, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_25, MUSIC_ROUTE_3, FALSE, PALETTE_AUTO, FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:202` -> `map_const ROUTE_25, 30, 9` (group 7, id 16)
- Connections (`data/maps/attributes.asm:374`): south `ROUTE_24` (0). No other connection - the
  route is a dead end at Bill's house.
- Scenes: `SCENE_ROUTE25_NOOP` = 0, `SCENE_ROUTE25_MISTYS_DATE` = 1 (`maps/Route25.asm:16-17`);
  scene var `data/maps/scenes.asm:14`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 47 | 5 | `BILLS_HOUSE` | 1 |

**Coord events**

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_ROUTE25_MISTYS_DATE` (1) | 42 | 6 | `Route25MistyDate1Script` (`pokegold.sym` `50:4781`) | the date cutscene, upper approach |
| `SCENE_ROUTE25_MISTYS_DATE` (1) | 42 | 7 | `Route25MistyDate2Script` | same cutscene, lower approach |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 45 | 5 | `BGEVENT_READ` | `BillsHouseSign` ("SEA COTTAGE / BILL'S HOUSE") |
| 4 | 5 | `BGEVENT_ITEM` | `Route25HiddenPotion` -> `hiddenitem POTION, EVENT_ROUTE_25_HIDDEN_POTION` (`pokegold.sym` `50:48c6`) |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE25_MISTY` | `SPRITE_MISTY` | 46 | 9 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` (inert) | `EVENT_ROUTE_25_MISTY_BOYFRIEND` |
| `ROUTE25_COOLTRAINER_M1` | `SPRITE_COOLTRAINER_M` | 46 | 10 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` (inert) | `EVENT_ROUTE_25_MISTY_BOYFRIEND` |
| `ROUTE25_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 12 | 8 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerSchoolboyDudley` | -1 |
| `ROUTE25_LASS1` | `SPRITE_LASS` | 16 | 11 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerLassEllen` | -1 |
| `ROUTE25_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 21 | 8 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerSchoolboyJoe` | -1 |
| `ROUTE25_LASS2` | `SPRITE_LASS` | 22 | 6 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerLassLaura` | -1 |
| `ROUTE25_YOUNGSTER3` | `SPRITE_YOUNGSTER` | 25 | 4 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 2) | `TrainerCamperLloyd` | -1 |
| `ROUTE25_LASS3` | `SPRITE_LASS` | 28 | 11 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerLassShannon` | -1 |
| `ROUTE25_SUPER_NERD` | `SPRITE_SUPER_NERD` | 31 | 7 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerSupernerdPat` | -1 |
| `ROUTE25_COOLTRAINER_M2` | `SPRITE_COOLTRAINER_M` | 37 | 8 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `TrainerCooltrainermKevin` | -1 |
| `ROUTE25_POKE_BALL` | `SPRITE_POKE_BALL` | 32 | 4 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `Route25Protein` (`itemball PROTEIN`, `pokegold.sym` `50:48c4`) | `EVENT_ROUTE_25_PROTEIN` |

**Scripts of interest**

- `Route25MistyDate1Script` / `Route25MistyDate2Script` - identical except for the approach
  movement. `showemote EMOTE_HEART` on Misty, `pause 30`, `showemote EMOTE_SHOCK` on the
  boyfriend, `applymovement ROUTE25_COOLTRAINER_M1` (one or two `big_step DOWN`),
  `disappear ROUTE25_COOLTRAINER_M1`, `playmusic MUSIC_BEAUTY_ENCOUNTER`, Misty walks over
  (`Route25MistyApproachesPlayerMovement1` = UP,UP,UP,LEFT,LEFT,LEFT; variant 2 drops one UP),
  `writetext Route25MistyDateText` (the "pest" speech that ends with "Come to CERULEAN GYM"),
  Misty leaves via `Route25MistyLeavesMovement` (LEFT x5), `disappear ROUTE25_MISTY`,
  **`clearevent EVENT_TRAINERS_IN_CERULEAN_GYM`**, `setscene SCENE_ROUTE25_NOOP`,
  `special RestartMapMusic`.
- `TrainerCooltrainermKevin` - not a `trainer` macro; a hand-written script.
  `checkevent EVENT_BEAT_COOLTRAINERM_KEVIN` -> after-battle text;
  `checkevent EVENT_CLEARED_NUGGET_BRIDGE` -> skip the prize;
  otherwise `CooltrainermKevinNuggetText`, `verbosegiveitem NUGGET`, `iffalse .NoRoomForNugget`,
  `setevent EVENT_CLEARED_NUGGET_BRIDGE`, then `winlosstext CooltrainermKevinBeatenText, 0`,
  `loadtrainer COOLTRAINERM, KEVIN`, `startbattle`, `reloadmapafterbattle`,
  `setevent EVENT_BEAT_COOLTRAINERM_KEVIN`.
  A full bag at the Nugget step aborts before the battle.
- The six "six-pack" trainers are plain `trainer` macros with `EVENT_BEAT_*` flags only.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ROUTE_25_MISTY_BOYFRIEND` | `constants/event_flags.asm:1296` | set at `engine/events/std_scripts.asm:549`; cleared by `CeruleanGymGruntRunsOutScript` | clear = the pair are standing at `46,9` / `46,10` |
| `SCENE_ROUTE25_MISTYS_DATE` (1) | `maps/Route25.asm:17` | `setmapscene` from `maps/CeruleanGym.asm:50` | arms the two coord events |
| `EVENT_TRAINERS_IN_CERULEAN_GYM` | `constants/event_flags.asm:1297` | cleared here | the gym becomes populated |
| `EVENT_CLEARED_NUGGET_BRIDGE` | `constants/event_flags.asm:215` | `TrainerCooltrainermKevin` | Nugget already handed over |
| `EVENT_BEAT_COOLTRAINERM_KEVIN` | `constants/event_flags.asm:873` | `TrainerCooltrainermKevin` | Kevin battle done |
| `EVENT_ROUTE_25_HIDDEN_POTION` | `constants/event_flags.asm:248` | `Route25HiddenPotion` | hidden Potion taken |
| `EVENT_ROUTE_25_PROTEIN` | `constants/event_flags.asm:1326` | item ball object row | Protein ball taken |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `POTION` | hidden, face `4,5` | `bg_event 4, 5, BGEVENT_ITEM, Route25HiddenPotion` | `EVENT_ROUTE_25_HIDDEN_POTION` |
| `NUGGET` | talk to Kevin at `37,8` | `TrainerCooltrainermKevin`, `verbosegiveitem NUGGET` | `EVENT_CLEARED_NUGGET_BRIDGE` |
| `PROTEIN` | item ball at `32,4` | `object_event ... OBJECTTYPE_ITEMBALL, 0, Route25Protein` | `EVENT_ROUTE_25_PROTEIN` |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `SCHOOLBOY, DUDLEY` | `SCHOOLBOY` | 7 (`parties.asm:448`) | L35 ODDISH | `TrainerSchoolboyDudley` | none |
| `LASS, ELLEN` | `LASS` | 11 (`parties.asm:703`) | L30 WIGGLYTUFF, L34 GRANBULL | `TrainerLassEllen` | none |
| `SCHOOLBOY, JOE` | `SCHOOLBOY` | 8 (`parties.asm:453`) | L33 TANGELA, L33 VAPOREON | `TrainerSchoolboyJoe` | none |
| `LASS, LAURA` | `LASS` | 7 (`parties.asm:676`) | L28 GLOOM, L31 PIDGEOTTO, L31 BELLOSSOM | `TrainerLassLaura` | none |
| `CAMPER, LLOYD` | `CAMPER` | 6 (`parties.asm:2733`) | L34 NIDOKING | `TrainerCamperLloyd` | none |
| `LASS, SHANNON` | `LASS` | 8 (`parties.asm:683`) | L29 PARAS, L29 PARAS, L32 PARASECT | `TrainerLassShannon` | none |
| `SUPER_NERD, PAT` | `SUPER_NERD` | 8 (`parties.asm:2009`) | L36 PORYGON | `TrainerSupernerdPat` | none |
| `COOLTRAINERM, KEVIN` | `COOLTRAINERM` | 17 (`parties.asm:847`) | L38 RHYHORN, L35 CHARMELEON, L35 WARTORTLE | `TrainerCooltrainermKevin` | none |

Base rewards: SCHOOLBOY 8, LASS 6, CAMPER 5, SUPER_NERD 8, COOLTRAINERM 12.

**Wild encounters** - `data/wild/kanto_grass.asm:1089` `def_grass_wildmons ROUTE_25`, 10/10/10 percent.
morn: L8 PIDGEY, L10 BELLSPROUT, L8 VENONAT, L9 ABRA, L10 PIDGEOTTO, L14 WEEPINBELL, L14 WEEPINBELL.
day: L8 PIDGEY, L10 BELLSPROUT, L10 PIDGEY, L9 ABRA, L12 PIDGEOTTO, L14 WEEPINBELL, L14 WEEPINBELL.
nite: L8 VENONAT, L10 ODDISH, L10 VENOMOTH, L9 ABRA, L14 WEEPINBELL, L10 BELLSPROUT, L10 BELLSPROUT.
Water: `data/wild/kanto_water.asm:82`, 4 percent: L10 GOLDEEN, L5 GOLDEEN, L10 SEAKING.

---

### MAP_BILLS_HOUSE

- Script: `maps/BillsHouse.asm`
- Blocks: shared, `data/maps/blocks.asm:163` (`BillsHouse_Blocks`)
- Header: `data/maps/maps.asm:215` -> `map BillsHouse, TILESET_HOUSE, INDOOR, LANDMARK_ROUTE_25, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:197` -> `map_const BILLS_HOUSE, 4, 4` (group 7, id 11)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `ROUTE_25` | 1 |
| 2 | 3 | 7 | `ROUTE_25` | 1 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `BILLSHOUSE_GRAMPS` | `SPRITE_GRAMPS` | 2 | 3 | `SPRITEMOVEDATA_STANDING_UP` (radius 0,2) | `OBJECTTYPE_SCRIPT` | `BillsGrandpa` (`pokegold.sym` `54:547c`) | -1 |

**Scripts of interest**

- `BillsGrandpa` - a five-step chain, each step gated on the previous. Order in the asm:
  1. LICKITUNG -> `EVENT_SHOWED_LICKITUNG_TO_BILLS_GRANDPA` -> `verbosegiveitem EVERSTONE`
     (`EVENT_GOT_EVERSTONE_FROM_BILLS_GRANDPA`)
  2. ODDISH -> `EVENT_SHOWED_ODDISH_TO_BILLS_GRANDPA` -> `verbosegiveitem LEAF_STONE`
     (`EVENT_GOT_LEAF_STONE_FROM_BILLS_GRANDPA`)
  3. STARYU -> `EVENT_SHOWED_STARYU_TO_BILLS_GRANDPA` -> `verbosegiveitem WATER_STONE`
     (`EVENT_GOT_WATER_STONE_FROM_BILLS_GRANDPA`)
  4. GROWLITHE (Gold) / VULPIX (Silver, selected by `checkver` / `iftrue .AskVulpix`) ->
     `EVENT_SHOWED_GROWLITHE_VULPIX_TO_BILLS_GRANDPA` -> `verbosegiveitem FIRE_STONE`
     (`EVENT_GOT_FIRE_STONE_FROM_BILLS_GRANDPA`)
  5. PICHU -> `EVENT_SHOWED_PICHU_TO_BILLS_GRANDPA` -> `verbosegiveitem THUNDERSTONE`
     (`EVENT_GOT_THUNDERSTONE_FROM_BILLS_GRANDPA`, which also ends the chain)
  Mechanics: `writetext ... AskToSeeMonText`, `yesorno`, `scall .ExcitedToSee`,
  `special BillsGrandfather` (party pick; `iffalse` = cancelled), `ifnotequal <SPECIES>, .WrongPokemon`.
  `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1` (`constants/event_flags.asm:5`) is set after each
  successful hand-over, so he only accepts **one mon per visit** - a bot must leave and
  re-enter the house between stones.
- First talk sets `EVENT_MET_BILLS_GRANDPA` (`constants/event_flags.asm:457`).

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `EVERSTONE` | show LICKITUNG | `BillsGrandpa` | `EVENT_GOT_EVERSTONE_FROM_BILLS_GRANDPA` |
| `LEAF_STONE` | show ODDISH | `BillsGrandpa` | `EVENT_GOT_LEAF_STONE_FROM_BILLS_GRANDPA` |
| `WATER_STONE` | show STARYU | `BillsGrandpa` | `EVENT_GOT_WATER_STONE_FROM_BILLS_GRANDPA` |
| `FIRE_STONE` | show GROWLITHE (Gold) / VULPIX (Silver) | `BillsGrandpa` | `EVENT_GOT_FIRE_STONE_FROM_BILLS_GRANDPA` |
| `THUNDERSTONE` | show PICHU | `BillsGrandpa` | `EVENT_GOT_THUNDERSTONE_FROM_BILLS_GRANDPA` (`:467`) |

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Cut tree at the Route 9 west entrance (and the tree above Super Nerd Pat on Route 25) | `engine/events/overworld.asm:117` `CutFunction` -> `.CheckAble` (`ld de, ENGINE_HIVEBADGE` / `CheckBadge`, then `CheckMapForSomethingToCut` -> `engine/overworld/tile_events.asm:76` `CheckCutCollision`). The trees themselves are block data in `maps/Route9.blk` / `maps/Route25.blk`, not object events. | HIVEBADGE + a party mon with CUT | already held (Johto badge 2) |
| Surfing the Route 9 / Route 10 river to reach the Power Plant door at `3,9` | `engine/events/overworld.asm:322` `SurfFunction` `.TrySurf` (`ld de, ENGINE_FOGBADGE` / `CheckBadge`, then `GetTilePermission` == `WATER_TILE`); the overworld A-press path is `engine/events/overworld.asm:469` `TrySurfOW` with the same `ENGINE_FOGBADGE` `CheckEngineFlag` | FOGBADGE + SURF | already held (Johto badge 6) |
| "Fly back to Cerulean City" | `engine/events/overworld.asm:529` `FlyFunction` (`ld de, ENGINE_STORMBADGE` at `:545`), destination row `data/maps/flypoints.asm:21` | STORMBADGE + FLY + `ENGINE_FLYPOINT_CERULEAN` set by `CeruleanCityFlypointCallback` | flypoint flag set on first entry to Cerulean |
| Cerulean Gym is empty on the first visit | `maps/CeruleanGym.asm:379-383` object rows all carry `EVENT_TRAINERS_IN_CERULEAN_GYM`, set at `engine/events/std_scripts.asm:550` | - | `clearevent` in `Route25MistyDate1Script` / `Route25MistyDate2Script` (`maps/Route25.asm:48` / `:74`) |
| Rocket grunt does not exist in the gym | `maps/CeruleanGym.asm:378` object row `EVENT_CERULEAN_GYM_ROCKET`, set at `std_scripts.asm:547`; the scene is `SCENE_CERULEANGYM_NOOP` by default | - | first talk to `PowerPlantManager` (`clearevent` + `setmapscene CERULEAN_GYM, SCENE_CERULEANGYM_GRUNT_RUNS_OUT`, `maps/PowerPlant.asm:146-148`) |
| Rocket grunt does not exist on Route 24 | `maps/Route24.asm:129` object row `EVENT_ROUTE_24_ROCKET`, set at `std_scripts.asm:548` | - | `clearevent` in `CeruleanGymGruntRunsOutScript` (`maps/CeruleanGym.asm:47`) |
| Misty + date do not exist on Route 25, and the two coord events are inert | `maps/Route25.asm:445-446` object rows `EVENT_ROUTE_25_MISTY_BOYFRIEND`; coord rows require `SCENE_ROUTE25_MISTYS_DATE` | - | `clearevent` + `setmapscene ROUTE_25, SCENE_ROUTE25_MISTYS_DATE` in `CeruleanGymGruntRunsOutScript` (`maps/CeruleanGym.asm:48`, `:50`) |
| Hidden MACHINE_PART at Cerulean Gym `3,8` yields nothing | `maps/CeruleanGym.asm:373` -> `CeruleanGymHiddenMachinePart`, flag set at `std_scripts.asm:546` | - | `clearevent EVENT_FOUND_MACHINE_PART_IN_CERULEAN_GYM` in `PowerPlantManager` (`maps/PowerPlant.asm:147`) |
| Route 5 Underground Path door at `17,15` physically blocked | `maps/Route5.asm:56` NPC standing on `17,16` | - | `setevent EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH` in `PowerPlantManager` `.FoundMachinePart` (`maps/PowerPlant.asm:164`) - i.e. **after** this section |
| Bill's grandpa gives one stone per visit | `maps/BillsHouse.asm` `.JustShowedSomething` on `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1` | - | leave and re-enter the map |

## 4. Bot checklist

Ordered, machine-actionable. `(g,m)` is `(map group, map id)` from `constants/map_constants.asm`.

1. `ROUTE_5_SAFFRON_GATE (25,14)`: walk onto warp 1/2 (`4,0` / `5,0`) -> `ROUTE_5`. Pre: none. Post: none.
2. `ROUTE_5 (25,1)`: optional - walk to warp 4 (`10,11`), enter `ROUTE_5_CLEANSE_TAG_HOUSE (25,15)`, talk to `ROUTE5CLEANSETAGHOUSE_GRANNY` at `2,5`. Pre: `EVENT_GOT_CLEANSE_TAG` clear + free bag slot. Post: `EVENT_GOT_CLEANSE_TAG` set, CLEANSE_TAG in bag. Exit via warp 1/2 (`2,7`/`3,7`).
3. `ROUTE_5`: walk north across the connection into `CERULEAN_CITY (7,17)`. Post: `ENGINE_FLYPOINT_CERULEAN` set by `MAPCALLBACK_NEWMAP`.
4. `CERULEAN_CITY`: optional - face `2,12` and press A for BERSERK_GENE. Pre: `EVENT_FOUND_BERSERK_GENE_IN_CERULEAN_CITY` clear.
5. `CERULEAN_CITY`: heal at warp 4 (`19,21`, `CERULEAN_POKECENTER_1F`). Optional but the walkthrough does it twice.
6. `CERULEAN_CITY`: warp 5 (`30,23`) -> `CERULEAN_GYM (7,6)`. Expect an empty room (`EVENT_TRAINERS_IN_CERULEAN_GYM` set). Read `2,13` / `6,13` for the two notes. Exit via `4,15`/`5,15`.
7. `CERULEAN_CITY`: exit east into `ROUTE_9 (7,13)`. Pre: HIVEBADGE + CUT for the entrance tree.
8. `ROUTE_9`: battle in walkthrough order - `TrainerPicnickerEdna` (`9,10`), `TrainerCamperSid` (`11,2`), `TrainerCamperDean` (`23,11`), `TrainerHikerSidney` (`33,15`), `TrainerHikerTim` (`32,3`), `TrainerPicnickerHeidi` (`35,8`). Post: `EVENT_BEAT_*` per trainer. Optional hidden ETHER at `10,5`.
9. `ROUTE_9`: cross the south connection into `ROUTE_10_NORTH (7,14)`. Optional heal at warp 1 (`11,1`).
10. `ROUTE_10_NORTH`: Surf (pre: FOGBADGE + SURF) down the river and step onto warp 2 (`3,9`) -> `POWER_PLANT (7,10)`.
11. `POWER_PLANT`: walk to `POWERPLANT_MANAGER` at `14,10` and talk. Pre: `EVENT_MET_MANAGER_AT_POWER_PLANT` clear. Post: `EVENT_MET_MANAGER_AT_POWER_PLANT` set, `EVENT_CERULEAN_GYM_ROCKET` cleared, `EVENT_FOUND_MACHINE_PART_IN_CERULEAN_GYM` cleared, `CERULEAN_GYM` scene = 1, `POWER_PLANT` scene = 1.
12. `POWER_PLANT`: walk over `5,12` on the way to the exit. Post: `PowerPlantGuardPhoneScript` runs, `POWER_PLANT` scene back to 0. Then exit via warp 1/2 (`2,17`/`3,17`).
13. FLY to `CERULEAN_CITY` (`SPAWN_CERULEAN` = `19,22`). Pre: STORMBADGE + FLY + `ENGINE_FLYPOINT_CERULEAN`.
14. `CERULEAN_CITY`: warp 5 -> `CERULEAN_GYM`. On load the scene script fires; hold through the movement/text (four A presses: intro, big-mistake, bye, plus the emote pauses). Post: `EVENT_MET_ROCKET_GRUNT_AT_CERULEAN_GYM` set, `EVENT_ROUTE_24_ROCKET` cleared, `EVENT_ROUTE_25_MISTY_BOYFRIEND` cleared, `ROUTE_25` scene = 1, `CERULEAN_GYM` scene = 0.
15. `CERULEAN_CITY`: exit north into `ROUTE_24 (7,15)`. Talk to `ROUTE24_ROCKET` at `8,7`. Battle `GRUNTM, GRUNTM_31` (L30 GOLBAT). Post: `disappear` sets `EVENT_ROUTE_24_ROCKET`.
16. `ROUTE_24`: north connection into `ROUTE_25 (7,16)`.
17. `ROUTE_25`: optional hidden POTION - face `4,5`, press A. Pre: `EVENT_ROUTE_25_HIDDEN_POTION` clear.
18. `ROUTE_25`: battle `TrainerSchoolboyDudley` (`12,8`), `TrainerLassEllen` (`16,11`), `TrainerSchoolboyJoe` (`21,8`), `TrainerLassLaura` (`22,6`), `TrainerCamperLloyd` (`25,4`), `TrainerLassShannon` (`28,11`), `TrainerSupernerdPat` (`31,7`).
19. `ROUTE_25`: talk to `ROUTE25_COOLTRAINER_M2` at `37,8`. Pre: free bag slot. Post: NUGGET, `EVENT_CLEARED_NUGGET_BRIDGE`, then battle `COOLTRAINERM, KEVIN` and `EVENT_BEAT_COOLTRAINERM_KEVIN`.
20. `ROUTE_25`: CUT the tree, walk onto the item ball at `32,4` for PROTEIN. Post: `EVENT_ROUTE_25_PROTEIN`.
21. `ROUTE_25`: walk east onto `42,6` (or `42,7`). Pre: `ROUTE_25` scene = `SCENE_ROUTE25_MISTYS_DATE`. Post: date cutscene, `EVENT_TRAINERS_IN_CERULEAN_GYM` cleared, `ROUTE_25` scene = 0.
22. `ROUTE_25`: warp 1 (`47,5`) -> `BILLS_HOUSE (7,11)`. Talk to `BILLSHOUSE_GRAMPS` at `2,3`. One stone per map load; loop enter/talk/exit until the wanted stones are collected. Post: `EVENT_MET_BILLS_GRANDPA`, then the `EVENT_GOT_*_FROM_BILLS_GRANDPA` chain.
23. FLY to `CERULEAN_CITY`, heal at warp 4, then warp 5 -> `CERULEAN_GYM`.
24. `CERULEAN_GYM`: battle `TrainerSwimmerfBriana` (`1,9`), then face `3,8` and press A for MACHINE_PART. Pre: `EVENT_FOUND_MACHINE_PART_IN_CERULEAN_GYM` clear + free bag slot. Post: flag set, MACHINE_PART in bag.
25. `CERULEAN_GYM`: battle `TrainerSwimmermParker` (`8,9`), `TrainerSwimmerfDiana` (`4,6`).
26. `CERULEAN_GYM`: talk to `CERULEANGYM_MISTY` at `5,3`. Pre: `ENGINE_CASCADEBADGE` clear. Post: `EVENT_BEAT_MISTY`, `EVENT_BEAT_SWIMMERF_DIANA`, `EVENT_BEAT_SWIMMERF_BRIANA`, `EVENT_BEAT_SWIMMERM_PARKER`, `ENGINE_CASCADEBADGE` set, +4700 money.

Follow-up (next section): carry MACHINE_PART back to `POWERPLANT_MANAGER` at `14,10` to set
`EVENT_RETURNED_MACHINE_PART` / `EVENT_RESTORED_POWER_TO_KANTO` and collect TM07 ZAP CANNON.

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Kanto map headers, warps, coord/bg/object event tables extracted from ROM | `src/import/RomExtractorGen2.lua` (`OBJECTTYPE_ITEMBALL, OBJECTTYPE_TRAINER = 1, 2` at :71; branch at :2960-2968) | implemented - generic, all map groups, nothing Kanto-specific needed |
| Coord-event trip-wires (Power Plant `5,12`, Route 25 `42,6`/`42,7`) with the scene id filter | `src/world/gen2/World.lua:5006` `World:tryCoordScript` | implemented |
| Scene scripts on map load + `sdefer` (`CeruleanGymGruntRunsOutScene`) | `src/world/gen2/World.lua` `World:trySceneScript`; `src/script/gen2/Vm.lua:92` | partial - `sdefer` is run immediately rather than queued until the map settles (comment at `Vm.lua:93` says so). Cosmetic ordering risk on the gym grunt scene. |
| `setscene` / `setmapscene` / `checkmapscene` | `src/script/gen2/Vm.lua:274`, `:279`, `:284` | implemented, including the `0xff` "no scene var" sentinel |
| `checkevent` / `setevent` / `clearevent` and `checkflag` / `setflag` (`ENGINE_CASCADEBADGE`, `ENGINE_FLYPOINT_CERULEAN`) | `src/script/gen2/Vm.lua:198-229`, `engineFlags` store at `:1661` | implemented - generic id-keyed stores, no per-flag work needed |
| Hidden items (`BGEVENT_ITEM`): MACHINE_PART, ETHER, POTION, BERSERK_GENE | `src/world/gen2/HiddenItems.lua` | implemented (the header notes this was previously unreachable because `World:bgEventAt` only answered `BGEVENT_READ`) |
| Item ball (`Route25Protein`) | `src/import/RomExtractorGen2.lua:2968` (`OBJECTTYPE_ITEMBALL`) | implemented |
| Trainer sight lines / `OBJECTTYPE_TRAINER` sight radius | `src/world/gen2/Trainers.lua:98` `Trainers.sees` | implemented |
| `loadtrainer` / `startbattle` / `winlosstext` / `reloadmapafterbattle` / `dontrestartmapmusic` / `endifjustbattled` | `src/script/gen2/Vm.lua` | implemented |
| Prize money = base x level x 4 (Misty 4700G etc.) | `src/battle/gen2/Prize.lua:12` (documents the `ld c, 4` loop), `Prize.reward` at `:82` | implemented, incl. Amulet Coin and Mom's savings split |
| CUT gate on HIVEBADGE + cut-tree collision | `src/world/gen2/FieldMoves.lua:440` `badgeGate` / `:452`; `src/world/gen2/Permissions.lua:130` `CUT_TREE`, `:152` `CheckCutCollision` set | implemented |
| SURF gate on FOGBADGE | `src/world/gen2/FieldMoves.lua:482` | implemented |
| FLY gate on STORMBADGE + flypoint table | `src/world/gen2/FieldMoves.lua:342` `FieldMoves.FLYPOINTS`, `:501`; `src/world/gen2/World.lua:4284` (`_FlyMap`) | implemented |
| `special BillsGrandfather` (party pick for the stone chain) | `src/script/gen2/Specials.lua:1267` | implemented |
| `special FadeOutMusic` / `FadeOutToBlack` / `FadeInFromBlack` / `ReloadSpritesNoPalettes` / `RestartMapMusic` (Route 24 grunt exit, gym grunt scene) | `src/script/gen2/Specials.lua:999`, `:1001`, `:1025`, `:1059`, `:1066` | implemented |
| `showemote`, `applymovement` (incl. `big_step`, `jump_step`, `fix_facing`, `set_sliding`, `slow_step`), `turnobject`, `disappear`/`appear` | `src/script/gen2/Vm.lua`, `src/script/gen2/Movement.lua` | implemented |
| Kanto Gen 2 wild tables (`kanto_grass`/`kanto_water`, Gold/Silver split on Route 9) | extracted by `src/import/RomExtractorGen2.lua`; consumed by `src/battle/gen2/Encounter.lua` | implemented - version split comes from the ROM, so it is correct by construction |
| End-to-end driver coverage for this stretch | `tests/drivers/gold_*.lua` (25 drivers: boot, walk, warp, trainer, battle, roamers, ice path, etc.) | missing - no Kanto / Cerulean / Power Plant driver exists |

## 6. Unresolved / verify by hand

- **Cut tree positions.** The walkthrough says "Cut the tree at the entrance" (Route 9) and
  "Cut the tree above Pat" (Route 25). Cut trees are block data in `maps/Route9.blk` /
  `maps/Route25.blk`, not events, so no coordinate for them appears anywhere in the asm text.
  A bot needs the decoded block map (or the port's `Permissions.isCutTree` over the loaded
  collision) to find them. The Protein ball at `32,4` sitting two cells above Pat at `31,7`
  is consistent with the walkthrough's claim, but the tree cell itself is unverified here.
- **Kevin's battle is omitted from the walkthrough.** The text says only "that guy will give
  you a Nugget". `TrainerCooltrainermKevin` gives the NUGGET and then immediately battles you
  with L38 RHYHORN / L35 CHARMELEON / L35 WARTORTLE. Treat the walkthrough as incomplete here,
  not the asm.
- **Wild lists are abridged in the walkthrough.** Route 24 also has VENONAT / SUNKERN /
  ODDISH / VENOMOTH, and Route 25 also has PIDGEY / PIDGEOTTO / VENONAT / WEEPINBELL /
  ODDISH / VENOMOTH, none of which the FAQ lists. Route 5's own table (PIDGEY / BELLSPROUT /
  ABRA / ODDISH / GLOOM) is not listed at all.
- **"Surf down the river ... and you'll be at the Power Plant."** The Power Plant door is
  `warp_event 3, 9` on `ROUTE_10_NORTH`, and the water table for both `ROUTE_9` and
  `ROUTE_10_NORTH` exists, so surfing is clearly the route - but the exact water path across
  the Route 9 / Route 10 North connection boundary is block data and was not traced.
- **EXP values.** Every per-mon EXP number in the walkthrough (e.g. "Level 42 Golduck
  (1566 EXP)") depends on the player's own level and participation; nothing in
  `data/trainers/parties.asm` carries them. Money values were all reproduced from
  `data/trainers/attributes.asm` base reward x last-mon level x 4 and check out.
- **"the 11th gym badge".** The asm has no badge counter tied to this; `ENGINE_CASCADEBADGE`
  is just one bit in `constants/engine_flags.asm:48`. The ordinal is walkthrough prose.
- **Route 5 "Day Care Center from Red, Blue and Yellow".** The building is
  `ROUTE_5_CLEANSE_TAG_HOUSE` and its sign at `10,11` reads "House for Sale... Nobody lives
  here." Nothing in Gen 2 calls it a Day Care; that identification is the FAQ's own history
  note. Also note the sign and the door share the tile `10,11`, so an A-press there may hit
  either depending on facing - worth verifying against the port's bg-event-vs-warp priority.
- **`POWERPLANT_GYM_GUIDE3` / `PowerPlantGymGuide4Script` naming mismatch** in
  `maps/PowerPlant.asm` (there is no `PowerPlantGymGuide3Script`). Harmless, but a
  label-driven bot should not assume the const and script numbers line up.

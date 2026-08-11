# Section 07 - Burned Tower and Ecruteak City Gym

Source: `../section-07-burned-tower-and-ecruteak-city-gym.txt`
Maps covered: `ROUTE_37`, `ECRUTEAK_CITY`, `ECRUTEAK_POKECENTER_1F`, `DANCE_THEATER`,
`ECRUTEAK_ITEMFINDER_HOUSE`, `BILLS_FAMILYS_HOUSE`, `BURNED_TOWER_1F`,
`BURNED_TOWER_B1F`, `ECRUTEAK_GYM` (plus one line on `ECRUTEAK_TIN_TOWER_ENTRANCE`,
which this section only unlocks).
Badges / key milestones in this section: FOGBADGE (`ENGINE_FOGBADGE`), HM03 SURF,
ITEMFINDER, EEVEE, TM30 SHADOW BALL, TIME CAPSULE (`ENGINE_TIME_CAPSULE`),
Ecruteak fly point, the three roaming beasts (`EVENT_RELEASED_THE_BEASTS`).

Note on naming: pokegold's `map_const` rows carry no `MAP_` prefix, so the
constants below are written exactly as `constants/map_constants.asm` spells them.

Note on coordinates: every table below is transcribed verbatim from the map asm.
`warp_event` / `coord_event` / `bg_event` / `object_event` all take `x, y` as
their first two arguments (see the macro comments in `macros/scripts/maps.asm`),
even though the macros emit `y` first. Coordinates are 16x16 walk cells, origin
top-left, so a `map_const W, H` map spans `x = 0 .. 2W-1`, `y = 0 .. 2H-1`.

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 0 | `VIOLET_CITY` | `maps/VioletCity.asm` | (carried in from section 06) | south to `ROUTE_36` | Heal after Sudowoodo; swap Togepi for Sudowoodo. Belongs to section 06. |
| 1 | `ROUTE_36` | `maps/Route36.asm` | west from Violet City | north connection to `ROUTE_37` | Pass-through only in this section; Route 36's own items/trainers are section 06's. |
| 2 | `ROUTE_37` | `maps/Route37.asm` | south connection from `ROUTE_36` | north connection to `ECRUTEAK_CITY` | Twins Ann & Anne, Psychic Greg, three apricorn trees, Sunny (Sundays). |
| 3 | `ECRUTEAK_CITY` | `maps/EcruteakCity.asm` | south connection from `ROUTE_37` | warp 6 (Pokecenter) | First arrival; sets `ENGINE_FLYPOINT_ECRUTEAK`. |
| 4 | `ECRUTEAK_POKECENTER_1F` | `maps/EcruteakPokecenter1F.asm` | Ecruteak warp 6 at (23,27) | same warp | Bill cutscene, Time Capsule, heal, deposit apricorns/berries. |
| 5 | `ROUTE_37` -> `ROUTE_36` -> `NATIONAL_PARK` -> `ROUTE_35` -> `GOLDENROD_CITY` | - | biking back south | - | Backtrack for the apricorn trees and Bill's Eevee. Only Route 37 is owned here. |
| 6 | `BILLS_FAMILYS_HOUSE` | `maps/BillsFamilysHouse.asm` | Goldenrod warp 4 at (5,25) | same warp | `givepoke EEVEE, 20`. |
| 7 | `ECRUTEAK_CITY` | `maps/EcruteakCity.asm` | back north via Route 35/36/37 | warp 8 (Dance Theater) | Return with Eevee. |
| 8 | `DANCE_THEATER` | `maps/DanceTheater.asm` | Ecruteak warp 8 at (23,21) | warps 1/2 at (5,13)/(6,13) | Five Kimono Girls, then HM03 SURF from the gentleman. |
| 9 | `ECRUTEAK_ITEMFINDER_HOUSE` | `maps/EcruteakItemfinderHouse.asm` | Ecruteak warp 11 at (13,27) | warps 1/2 at (3,7)/(4,7) | ITEMFINDER for answering `yesorno` with YES. |
| 10 | `BURNED_TOWER_1F` | `maps/BurnedTower1F.asm` | Ecruteak warp 13 at (5,5) | warps 1/2 at (9,15)/(10,15) | Rival battle on entry; Rock Smash gates; drop to B1F. |
| 11 | `BURNED_TOWER_B1F` | `maps/BurnedTowerB1F.asm` | fall through a 1F pit | ladder at (7,15) | HP UP, TM ENDURE, and the `ReleaseTheBeasts` coord event. |
| 12 | `ECRUTEAK_GYM` | `maps/EcruteakGym.asm` | Ecruteak warp 10 at (6,27) | warps 1/2 at (4,17)/(5,17) | Four ghost trainers on the invisible floor, then Morty. |

Spill into the next section: after FOGBADGE the walkthrough points at Olivine
Lighthouse and at Union Cave for Lapras. `EcruteakGymMortyScript` also does
`setmapscene ECRUTEAK_TIN_TOWER_ENTRANCE, SCENE_ECRUTEAKTINTOWERENTRANCE_NOOP`,
which is what un-blocks Tin Tower - that map is the next section's problem.

---

## 2. Maps

### ROUTE_37

- Script: `maps/Route37.asm`
- Blocks: `maps/Route37.blk`
- Header: `data/maps/maps.asm:250` -> `TILESET_JOHTO`, `ROUTE`, `LANDMARK_ROUTE_37`,
  `MUSIC_ROUTE_36`, phone `FALSE`, `PALETTE_AUTO`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:229` -> `map_const ROUTE_37, 10, 9`
  (walk cells `x 0..19`, `y 0..17`)
- Connections: `data/maps/attributes.asm:211` -> north `EcruteakCity` (offset -5),
  south `Route36` (offset -10). No east/west.

**Warps** (`def_warp_events`)

Empty. Route 37 is reached only through map connections.

**Coord events** (`def_coord_events`)

Empty.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 5 | 3 | `BGEVENT_READ` | `Route37Sign` |
| 4 | 2 | `BGEVENT_ITEM` | `Route37HiddenEther` -> `hiddenitem ETHER, EVENT_ROUTE_37_HIDDEN_ETHER` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE37_WEIRD_TREE1` | `SPRITE_WEIRD_TREE` | 6 | 12 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerTwinsAnnandanne1` | -1 |
| `ROUTE37_WEIRD_TREE2` | `SPRITE_WEIRD_TREE` | 7 | 12 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerTwinsAnnandanne2` | -1 |
| `ROUTE37_YOUNGSTER` | `SPRITE_YOUNGSTER` | 9 | 6 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerPsychicGreg` | -1 |
| `ROUTE37_FRUIT_TREE1` | `SPRITE_FRUIT_TREE` | 13 | 5 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route37FruitTree1` | -1 |
| `ROUTE37_SUNNY` | `SPRITE_BUG_CATCHER` | 16 | 8 | `WANDER` (radius 1,1) | `OBJECTTYPE_SCRIPT` | `SunnyScript` | `EVENT_ROUTE_37_SUNNY_OF_SUNDAY` |
| `ROUTE37_FRUIT_TREE2` | `SPRITE_FRUIT_TREE` | 16 | 5 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route37FruitTree2` | -1 |
| `ROUTE37_FRUIT_TREE3` | `SPRITE_FRUIT_TREE` | 15 | 7 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route37FruitTree3` | -1 |

The two twin objects really are declared `SPRITE_WEIRD_TREE` with object consts
named `ROUTE37_WEIRD_TREE1/2`; `engine/events/std_scripts.asm` carries
`variablesprite SPRITE_WEIRD_TREE, SPRITE_SUDOWOODO`, so the sprite slot is
shared with Sudowoodo. Flagged under section 6 as well - see "Unresolved".

**Scripts of interest**

- `Route37SunnyCallback` (`MAPCALLBACK_OBJECTS`): `readvar VAR_WEEKDAY`,
  `ifequal SUNDAY` -> `appear ROUTE37_SUNNY`, otherwise `disappear ROUTE37_SUNNY`.
  This is the only reason Sunny exists on the map, so a bot must fake or wait
  for Sunday.
- `SunnyScript` (`4c:404d`): `checkevent EVENT_GOT_MAGNET_FROM_SUNNY` -> already
  done; else `readvar VAR_WEEKDAY`, `ifnotequal SUNDAY` -> refusal text; else
  `setevent EVENT_MET_SUNNY_OF_SUNDAY`, `verbosegiveitem MAGNET`,
  `setevent EVENT_GOT_MAGNET_FROM_SUNNY`.
- `TrainerTwinsAnnandanne1` / `TrainerTwinsAnnandanne2`: both use the *same*
  `EVENT_BEAT_TWINS_ANN_AND_ANNE` flag, so beating either twin marks both beaten
  and the second never battles. `EVENT_BEAT_TWINS_ANN_AND_ANNE2` exists in
  `constants/event_flags.asm:610` but nothing on this map references it.
- `Route37FruitTree1/2/3` -> `fruittree FRUITTREE_ROUTE_37_1/2/3`.
  `data/items/fruit_trees.asm:20-22` gives `RED_APRICORN`, `BLU_APRICORN`,
  `BLK_APRICORN` in that order.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ROUTE_37_SUNNY_OF_SUNDAY` | `constants/event_flags.asm:1277` | `Route37SunnyCallback` (`appear`/`disappear`) | Set = Sunny hidden. Object masks when the flag is SET (`CheckObjectFlag`, `engine/overworld/map_objects_2.asm:32`). |
| `EVENT_MET_SUNNY_OF_SUNDAY` | `constants/event_flags.asm:113` | `SunnyScript` | First-meeting text guard. |
| `EVENT_GOT_MAGNET_FROM_SUNNY` | `constants/event_flags.asm:114` | `SunnyScript` | One-time MAGNET. |
| `EVENT_ROUTE_37_HIDDEN_ETHER` | `constants/event_flags.asm:179` | `Route37HiddenEther` | Hidden ETHER at (4,2). |
| `EVENT_BEAT_TWINS_ANN_AND_ANNE` | `constants/event_flags.asm:609` | both twin `trainer` rows | One flag, two objects. |
| `EVENT_BEAT_PSYCHIC_GREG` | `constants/event_flags.asm:567` | `TrainerPsychicGreg` | - |
| `ENGINE_BIKE_SHOP_CALL_ENABLED` | `constants/engine_flags.asm:29` | set by `maps/GoldenrodBikeShop.asm:28`, cleared by `engine/phone/scripts/bike_shop.asm:3` | The "keep the bicycle" call the walkthrough hits here. |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `RED_APRICORN` | fruit tree (daily) | object (13,5) -> `Route37FruitTree1` -> `FRUITTREE_ROUTE_37_1` | none (daily reset) |
| `BLU_APRICORN` | fruit tree (daily) | object (16,5) -> `Route37FruitTree2` -> `FRUITTREE_ROUTE_37_2` | none |
| `BLK_APRICORN` | fruit tree (daily) | object (15,7) -> `Route37FruitTree3` -> `FRUITTREE_ROUTE_37_3` | none |
| `ETHER` | hidden | `bg_event 4, 2, BGEVENT_ITEM` | `EVENT_ROUTE_37_HIDDEN_ETHER` |
| `MAGNET` | Sunny, Sundays only | `SunnyScript` `verbosegiveitem MAGNET` | `EVENT_GOT_MAGNET_FROM_SUNNY` |

The walkthrough's "Hard Stone / Ice Berry / TM08 Rock Smash" for "Route 36 & 37"
are all on `ROUTE_36`, not Route 37. That map belongs to section 06.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `TWINS` / `ANNANDANNE1` | `TWINS` | `ANNANDANNE1` (`TwinsGroup` entry 2) | L16 CLEFAIRY (GROWL, ENCORE, DOUBLESLAP, METRONOME); L16 JIGGLYPUFF (SING, DEFENSE_CURL, POUND, DISABLE) | `TrainerTwinsAnnandanne1` | none |
| `TWINS` / `ANNANDANNE2` | `TWINS` | `ANNANDANNE2` (`TwinsGroup` entry 3) | L16 JIGGLYPUFF; L16 CLEFAIRY (same moves, reversed order) | `TrainerTwinsAnnandanne2` | none |
| `PSYCHIC_T` / `GREG` | `PSYCHIC_T` | `GREG` (`PsychicGroup` entry 5) | L17 DROWZEE (HYPNOSIS, DISABLE, DREAM_EATER) | `TrainerPsychicGreg` | none |

**Wild encounters**

`data/wild/johto_grass.asm:1959`, `def_grass_wildmons ROUTE_37`, encounter rate
10% morn / 10% day / 10% nite.

Gold (`IF DEF(_GOLD)`):

| slot | morn | day | nite |
|---|---|---|---|
| 1 | L13 PIDGEY | L13 PIDGEY | L13 SPINARAK |
| 2 | L15 STANTLER | L15 STANTLER | L15 STANTLER |
| 3 | L15 PIDGEY | L15 PIDGEY | L15 HOOTHOOT |
| 4 | L14 GROWLITHE | L14 GROWLITHE | L14 GROWLITHE |
| 5 | L15 PIDGEY | L15 PIDGEOTTO | L15 SPINARAK |
| 6 | L15 PIDGEY | L16 GROWLITHE | L15 SPINARAK |
| 7 | L15 PIDGEY | L16 GROWLITHE | L15 SPINARAK |

Silver (`ELIF DEF(_SILVER)`) swaps GROWLITHE -> VULPIX and SPINARAK -> LEDYBA
(morn) / HOOTHOOT (nite); slot 1 morn is L13 LEDYBA, slot 1 nite L13 HOOTHOOT.

Headbutt: `data/wild/treemon_maps.asm:18` -> `treemon_map ROUTE_37, TREEMON_SET_FOREST`.
Roaming beasts: `data/wild/roammon_maps.asm:27` -> `roam_map ROUTE_37, ROUTE_36, ROUTE_38, ROUTE_42`.
No water, no fishing.

---

### ECRUTEAK_CITY

- Script: `maps/EcruteakCity.asm`
- Blocks: `maps/EcruteakCity.blk`
- Header: `data/maps/maps.asm:173` -> `TILESET_JOHTO`, `TOWN`, `LANDMARK_ECRUTEAK_CITY`,
  `MUSIC_ECRUTEAK_CITY`, phone `FALSE`, `PALETTE_AUTO`, `FISHGROUP_POND`
- Dimensions: `constants/map_constants.asm:159` -> `map_const ECRUTEAK_CITY, 20, 18`
  (walk cells `x 0..39`, `y 0..35`)
- Connections: `data/maps/attributes.asm:147` -> south `Route37` (offset 5),
  west `Route38` (offset 5), east `Route42` (offset 9)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 35 | 26 | `ROUTE_42_ECRUTEAK_GATE` | 1 |
| 2 | 35 | 27 | `ROUTE_42_ECRUTEAK_GATE` | 2 |
| 3 | 18 | 11 | `ECRUTEAK_TIN_TOWER_ENTRANCE` | 1 |
| 4 | 20 | 2 | `ECRUTEAK_TIN_TOWER_BACK_ENTRANCE` | 1 |
| 5 | 20 | 3 | `ECRUTEAK_TIN_TOWER_BACK_ENTRANCE` | 2 |
| 6 | 23 | 27 | `ECRUTEAK_POKECENTER_1F` | 1 |
| 7 | 5 | 21 | `ECRUTEAK_LUGIA_SPEECH_HOUSE` | 1 |
| 8 | 23 | 21 | `DANCE_THEATER` | 1 |
| 9 | 29 | 21 | `ECRUTEAK_MART` | 2 |
| 10 | 6 | 27 | `ECRUTEAK_GYM` | 1 |
| 11 | 13 | 27 | `ECRUTEAK_ITEMFINDER_HOUSE` | 1 |
| 12 | 37 | 7 | `TIN_TOWER_1F` | 1 |
| 13 | 5 | 5 | `BURNED_TOWER_1F` | 1 |
| 14 | 0 | 18 | `ROUTE_38_ECRUTEAK_GATE` | 3 |
| 15 | 0 | 19 | `ROUTE_38_ECRUTEAK_GATE` | 4 |

**Coord events** (`def_coord_events`)

Empty.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 15 | 21 | `BGEVENT_READ` | `EcruteakCitySign` |
| 38 | 10 | `BGEVENT_READ` | `TinTowerSign` |
| 8 | 28 | `BGEVENT_READ` | `EcruteakGymSign` |
| 21 | 21 | `BGEVENT_READ` | `EcruteakDanceTheaterSign` |
| 2 | 10 | `BGEVENT_READ` | `BurnedTowerSign` |
| 24 | 27 | `BGEVENT_READ` | `EcruteakCityPokecenterSign` (`jumpstd PokecenterSignScript`) |
| 30 | 21 | `BGEVENT_READ` | `EcruteakCityMartSign` (`jumpstd MartSignScript`) |
| 23 | 14 | `BGEVENT_ITEM` | `EcruteakCityHiddenHyperPotion` -> `hiddenitem HYPER_POTION, EVENT_ECRUTEAK_CITY_HIDDEN_HYPER_POTION` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ECRUTEAKCITY_GRAMPS1` | `SPRITE_GRAMPS` | 18 | 15 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `EcruteakCityGramps1Script` | -1 |
| `ECRUTEAKCITY_GRAMPS2` | `SPRITE_GRAMPS` | 20 | 21 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `EcruteakCityGramps2Script` | -1 |
| `ECRUTEAKCITY_LASS1` | `SPRITE_LASS` | 21 | 29 | `WALK_LEFT_RIGHT` (2,0) | `OBJECTTYPE_SCRIPT` | `EcruteakCityLass1Script` | -1 |
| `ECRUTEAKCITY_LASS2` | `SPRITE_LASS` | 3 | 9 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `EcruteakCityLass2Script` | -1 |
| `ECRUTEAKCITY_FISHER` | `SPRITE_FISHER` | 9 | 22 | `WALK_LEFT_RIGHT` (1,0) | `OBJECTTYPE_SCRIPT` | `EcruteakCityFisherScript` | -1 |
| `ECRUTEAKCITY_YOUNGSTER` | `SPRITE_YOUNGSTER` | 10 | 14 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `EcruteakCityYoungsterScript` | -1 |

**Scripts of interest**

- `EcruteakCityFlypointCallback` (`MAPCALLBACK_NEWMAP`): a bare
  `setflag ENGINE_FLYPOINT_ECRUTEAK` / `endcallback`. Arriving on the map at all
  registers the fly point.
- `EcruteakCityLass2Script`: branches on `EVENT_RELEASED_THE_BEASTS` - a cheap,
  in-world way for a bot to confirm the Burned Tower cutscene fired.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_ECRUTEAK` | `constants/engine_flags.asm:86` | `EcruteakCityFlypointCallback` | Fly destination unlocked on first entry. |
| `EVENT_ECRUTEAK_CITY_HIDDEN_HYPER_POTION` | `constants/event_flags.asm:190` | `EcruteakCityHiddenHyperPotion` | Hidden HYPER POTION at (23,14). |
| `EVENT_RELEASED_THE_BEASTS` | `constants/event_flags.asm:132` | read here, written by `ReleaseTheBeasts` in `maps/BurnedTowerB1F.asm:64` | Beasts cutscene done. |
| `EVENT_JASMINE_RETURNED_TO_GYM` | `constants/event_flags.asm` | read by `EcruteakCityFisherScript` | Later-section state; not touched here. |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `HYPER_POTION` | hidden, needs ITEMFINDER to find comfortably | `bg_event 23, 14, BGEVENT_ITEM` | `EVENT_ECRUTEAK_CITY_HIDDEN_HYPER_POTION` |

**Trainers**

None on the overworld map.

**Wild encounters**

Grass: none (`data/wild/johto_grass.asm` has no `ECRUTEAK_CITY` entry).
Water: `data/wild/johto_water.asm:246` -> `def_water_wildmons ECRUTEAK_CITY`,
2% encounter rate, L20 POLIWAG / L15 POLIWAG / L20 POLIWHIRL. Reachable only
after SURF is usable, i.e. after Morty.
Fishing group `FISHGROUP_POND` (`data/maps/maps.asm:173`), see `data/wild/fish.asm`.
Headbutt: `data/wild/treemon_maps.asm:35` -> `TREEMON_SET_CITY`.

---

### ECRUTEAK_POKECENTER_1F

- Script: `maps/EcruteakPokecenter1F.asm`
- Blocks: none (`data/maps/attributes.asm` uses the shared Pokecenter layout)
- Header: `data/maps/maps.asm:167` -> `TILESET_POKECENTER`, `INDOOR`,
  `LANDMARK_ECRUTEAK_CITY`, `MUSIC_POKEMON_CENTER`, phone `FALSE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:153` -> `map_const ECRUTEAK_POKECENTER_1F, 5, 4`
- Scene var: `data/maps/scenes.asm:43` -> `scene_var ECRUTEAK_POKECENTER_1F, wEcruteakPokecenter1FSceneID`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `ECRUTEAK_CITY` | 6 |
| 2 | 4 | 7 | `ECRUTEAK_CITY` | 6 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

**Coord events / BG events**

Both empty.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ECRUTEAKPOKECENTER1F_NURSE` | `SPRITE_NURSE` | 3 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `EcruteakPokecenter1FNurseScript` | -1 |
| `ECRUTEAKPOKECENTER1F_POKEFAN_M` | `SPRITE_POKEFAN_M` | 7 | 6 | `SPINRANDOM_FAST` | `OBJECTTYPE_SCRIPT` | `EcruteakPokecenter1FPokefanMScript` | -1 |
| `ECRUTEAKPOKECENTER1F_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 1 | 4 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `EcruteakPokecenter1FCooltrainerFScript` | -1 |
| `ECRUTEAKPOKECENTER1F_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 7 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `EcruteakPokecenter1FGymGuideScript` | -1 |
| `ECRUTEAKPOKECENTER1F_BILL` | `SPRITE_BILL` | 0 | 7 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_ECRUTEAK_POKE_CENTER_BILL` |

**Scripts of interest**

- Scene table: `scene_script EcruteakPokecenter1FMeetBillScene, SCENE_ECRUTEAKPOKECENTER1F_MEET_BILL`
  (scene id 0, the wram default) then `..._NOOP` (scene id 1). Scene constants are
  generated positionally by the `def_scene_scripts` / `scene_script` macros in
  `macros/scripts/maps.asm:12-33`; there is no `SCENE_*` constants file.
- `EcruteakPokecenter1FMeetBillScene` -> `sdefer EcruteakPokcenter1FBillActivatesTimeCapsuleScript`
  (`52:4299`). This is the "you cannot move for a second" the walkthrough
  describes: it fires on map load, not on a coord trip-wire.
- `EcruteakPokcenter1FBillActivatesTimeCapsuleScript`:
  `appear ECRUTEAKPOKECENTER1F_BILL` ->
  `applymovement BILL` (UP x4, RIGHT x3, `turn_head UP`) and
  `applymovement PLAYER` (UP x3) -> two text blocks ->
  `applymovement BILL` (RIGHT, DOWN x4) -> `disappear` ->
  **`clearevent EVENT_MET_BILL`** -> `setflag ENGINE_TIME_CAPSULE` ->
  `setscene SCENE_ECRUTEAKPOKECENTER1F_NOOP`.

`EVENT_MET_BILL` is *set* by the new-game initialisation block in
`engine/events/std_scripts.asm` (the long `setevent` run around line 514), so
Bill's object in `BILLS_FAMILYS_HOUSE` is masked until this cutscene clears it.
Talking to Bill in Goldenrod is impossible before this scene runs - this is the
hard ordering constraint behind the walkthrough's backtrack.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ECRUTEAK_POKE_CENTER_BILL` | `constants/event_flags.asm:1205` | `appear`/`disappear` in the cutscene | Set = Bill hidden here. Set at new game. |
| `EVENT_MET_BILL` | `constants/event_flags.asm:1204` | cleared here; read by `BillsFamilysHouse` object row and `BillsMomScript` | Cleared = Bill visible in Goldenrod. |
| `ENGINE_TIME_CAPSULE` | `constants/engine_flags.asm:100` | set here | Time Capsule menu option. |

---

### DANCE_THEATER

- Script: `maps/DanceTheater.asm`
- Blocks: `maps/DanceTheater.blk`
- Header: `data/maps/maps.asm:169` -> `TILESET_TRADITIONAL_HOUSE`, `INDOOR`,
  `LANDMARK_ECRUTEAK_CITY`, `MUSIC_DANCING_HALL`, phone `FALSE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:155` -> `map_const DANCE_THEATER, 6, 7`
  (walk cells `x 0..11`, `y 0..13`)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 13 | `ECRUTEAK_CITY` | 8 |
| 2 | 6 | 13 | `ECRUTEAK_CITY` | 8 |

**Coord events**

Empty.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 5 | 6 | `BGEVENT_UP` | `DanceTheaterFancyPanel` |
| 6 | 6 | `BGEVENT_UP` | `DanceTheaterFancyPanel` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `DANCETHEATER_KIMONO_GIRL1` | `SPRITE_KIMONO_GIRL` | 0 | 2 | `SPINCOUNTERCLOCKWISE` | `OBJECTTYPE_TRAINER` (sight 0) | `TrainerKimonoGirlNaoko` | -1 |
| `DANCETHEATER_KIMONO_GIRL2` | `SPRITE_KIMONO_GIRL` | 2 | 1 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (sight 0) | `TrainerKimonoGirlSayo` | -1 |
| `DANCETHEATER_KIMONO_GIRL3` | `SPRITE_KIMONO_GIRL` | 6 | 2 | `SPINRANDOM_SLOW` | `OBJECTTYPE_TRAINER` (sight 0) | `TrainerKimonoGirlZuki` | -1 |
| `DANCETHEATER_KIMONO_GIRL4` | `SPRITE_KIMONO_GIRL` | 9 | 1 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (sight 0) | `TrainerKimonoGirlKuni` | -1 |
| `DANCETHEATER_KIMONO_GIRL5` | `SPRITE_KIMONO_GIRL` | 11 | 2 | `SPINCLOCKWISE` | `OBJECTTYPE_TRAINER` (sight 0) | `TrainerKimonoGirlMiki` | -1 |
| `DANCETHEATER_GENTLEMAN` | `SPRITE_GENTLEMAN` | 7 | 10 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `DanceTheaterSurfGuy` | -1 |
| `DANCETHEATER_RHYDON` | `SPRITE_RHYDON` | 6 | 8 | `POKEMON` | `OBJECTTYPE_SCRIPT` | `DanceTheaterRhydon` | -1 |
| `DANCETHEATER_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 10 | 10 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `DanceTheaterCooltrainerMScript` | -1 |
| `DANCETHEATER_GRANNY` | `SPRITE_GRANNY` | 3 | 6 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `DanceTheaterGrannyScript` | -1 |

All five Kimono Girls have **sight range 0** - they never initiate. A bot must
walk adjacent and press A on each one.

**Scripts of interest**

- `DanceTheaterSurfGuy` (`52:485c`): `faceplayer`, `opentext`,
  `writetext SurfGuyNeverLeftAScratchText`, then
  `checkevent EVENT_GOT_HM03_SURF` -> `SurfGuyAlreadyGaveSurf`, else five
  `checkevent` / `iffalse .KimonoGirlsUndefeated` in the order
  NAOKO, SAYO, ZUKI, KUNI, MIKI; all five set ->
  `.GetSurf` (`52:488f`): `verbosegiveitem HM_SURF`,
  `setevent EVENT_GOT_HM03_SURF`. Note there is no `iffalse` after
  `verbosegiveitem HM_SURF`, so a full bag still sets the flag - see "Unresolved".

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_KIMONO_GIRL_NAOKO` | `constants/event_flags.asm:744` | `TrainerKimonoGirlNaoko` | gate 1/5 for SURF |
| `EVENT_BEAT_KIMONO_GIRL_SAYO` | `:745` | `TrainerKimonoGirlSayo` | gate 2/5 |
| `EVENT_BEAT_KIMONO_GIRL_ZUKI` | `:746` | `TrainerKimonoGirlZuki` | gate 3/5 |
| `EVENT_BEAT_KIMONO_GIRL_KUNI` | `:747` | `TrainerKimonoGirlKuni` | gate 4/5 |
| `EVENT_BEAT_KIMONO_GIRL_MIKI` | `:748` | `TrainerKimonoGirlMiki` | gate 5/5 |
| `EVENT_GOT_HM03_SURF` | `constants/event_flags.asm:25` | `DanceTheaterSurfGuy` | HM03 in the bag |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `HM_SURF` | talk to the gentleman after all five Kimono Girls | `DanceTheaterSurfGuy.GetSurf` | `EVENT_GOT_HM03_SURF` |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`, `KimonoGirlGroup`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `KIMONO_GIRL` / `NAOKO` | `KIMONO_GIRL` | entry 2 "NAOKO" | L17 FLAREON (`TRAINERTYPE_NORMAL`) | `TrainerKimonoGirlNaoko` | none |
| `KIMONO_GIRL` / `SAYO` | `KIMONO_GIRL` | entry 3 "SAYO" | L17 ESPEON | `TrainerKimonoGirlSayo` | none |
| `KIMONO_GIRL` / `ZUKI` | `KIMONO_GIRL` | entry 4 "ZUKI" | L17 UMBREON | `TrainerKimonoGirlZuki` | none |
| `KIMONO_GIRL` / `KUNI` | `KIMONO_GIRL` | entry 5 "KUNI" | L17 VAPOREON | `TrainerKimonoGirlKuni` | none |
| `KIMONO_GIRL` / `MIKI` | `KIMONO_GIRL` | entry 6 "MIKI" | L17 JOLTEON | `TrainerKimonoGirlMiki` | none |

Constants at `constants/trainer_constants.asm:614-618`. All are
`TRAINERTYPE_NORMAL`, i.e. level-up movesets, no custom moves.

**Wild encounters**

None (indoor).

---

### ECRUTEAK_ITEMFINDER_HOUSE

- Script: `maps/EcruteakItemfinderHouse.asm`
- Blocks: none of its own
- Header: `data/maps/maps.asm:172` -> `TILESET_TRADITIONAL_HOUSE`, `INDOOR`,
  `LANDMARK_ECRUTEAK_CITY`, `MUSIC_ECRUTEAK_CITY`, phone `FALSE`, `PALETTE_DAY`
- Dimensions: `constants/map_constants.asm:158` -> `map_const ECRUTEAK_ITEMFINDER_HOUSE, 4, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `ECRUTEAK_CITY` | 11 |
| 2 | 4 | 7 | `ECRUTEAK_CITY` | 11 |

**Coord events**: empty.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 2 | 1 | `BGEVENT_READ` | `ItemFinderHouseRadio` (`jumpstd Radio2Script`) |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ECRUTEAKITEMFINDERHOUSE_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 2 | 3 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `EcruteakItemfinderGuy` | -1 |
| `ECRUTEAKITEMFINDERHOUSE_POKEDEX` | `SPRITE_POKEDEX` | 3 | 3 | `STILL` | `OBJECTTYPE_SCRIPT` | `EcruteakHistoryBook` | -1 |

**Scripts of interest**

- `EcruteakItemfinderGuy` (`52:588b`): `checkevent EVENT_GOT_ITEMFINDER` ->
  already done; else `writetext EcruteakItemfinderAdventureText`, `yesorno`,
  `iffalse .no`, then `verbosegiveitem ITEMFINDER`,
  `setevent EVENT_GOT_ITEMFINDER`. A bot must answer YES.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `ITEMFINDER` | answer YES to the cooltrainer | `EcruteakItemfinderGuy` | `EVENT_GOT_ITEMFINDER` (`constants/event_flags.asm:99`) |

---

### BILLS_FAMILYS_HOUSE

Not an Ecruteak map - it is in Goldenrod, warp 4 of `GOLDENROD_CITY` at (5,25).
Included because this section's Eevee comes from here and is ordering-locked by
the Ecruteak Pokecenter cutscene.

- Script: `maps/BillsFamilysHouse.asm`
- Header: `data/maps/maps.asm:273` -> `TILESET_HOUSE`, `INDOOR`,
  `LANDMARK_GOLDENROD_CITY`, `MUSIC_GOLDENROD_CITY`, phone `FALSE`, `PALETTE_DAY`
- Dimensions: `constants/map_constants.asm:251` -> `map_const BILLS_FAMILYS_HOUSE, 4, 4`

Do not confuse with `maps/BillsHouse.asm` (`BILLS_HOUSE`, Kanto Route 25,
`constants/map_constants.asm:197`) - that is Bill's grandfather and the
stone-for-showing-a-mon chain, nothing to do with Eevee.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `GOLDENROD_CITY` | 4 |
| 2 | 3 | 7 | `GOLDENROD_CITY` | 4 |

**Coord events**: empty.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `BillsHouseBookshelf2` (`jumpstd MagazineBookshelfScript`) |
| 1 | 1 | `BGEVENT_READ` | `BillsHouseBookshelf1` (`jumpstd PictureBookshelfScript`) |
| 7 | 1 | `BGEVENT_READ` | `BillsHouseRadio` (`jumpstd Radio2Script`) |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `BILLSFAMILYSHOUSE_BILL` | `SPRITE_BILL` | 2 | 3 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `BillScript` | `EVENT_MET_BILL` |
| `BILLSFAMILYSHOUSE_POKEFAN_F` | `SPRITE_POKEFAN_F` | 5 | 3 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `BillsMomScript` | -1 |
| `BILLSFAMILYSHOUSE_TWIN` | `SPRITE_TWIN` | 5 | 4 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `BillsYoungerSisterScript` | -1 |

**Scripts of interest**

- `BillScript` (`57:4bee`): `checkevent EVENT_GOT_EEVEE` -> done; else
  `writetext BillTakeThisEeveeText`, `yesorno`, `iffalse .Refused`,
  then `readvar VAR_PARTYCOUNT`, **`ifequal PARTY_LENGTH, .NoRoom`** -
  this is the walkthrough's "clear one Pokémon spot" - then
  `givepoke EEVEE, 20` and `setevent EVENT_GOT_EEVEE`.
- `BillsYoungerSisterScript`: `checkcellnum PHONE_BILL` / `askforphonenumber` /
  `addcellnum PHONE_BILL`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_MET_BILL` | `constants/event_flags.asm:1204` | object mask here; cleared by the Ecruteak Pokecenter cutscene | Set (new-game default) = Bill absent. |
| `EVENT_GOT_EEVEE` | `constants/event_flags.asm:88` | `BillScript` | One-time L20 EEVEE. |

**Items / Pokemon**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| EEVEE (L20) | `givepoke EEVEE, 20` after YES with a free party slot | `BillScript` | `EVENT_GOT_EEVEE` |

---

### BURNED_TOWER_1F

- Script: `maps/BurnedTower1F.asm`
- Blocks: `maps/BurnedTower1F.blk` (90 bytes = 10x9 blocks)
- Header: `data/maps/maps.asm:91` -> `TILESET_TOWER`, `DUNGEON`,
  `LANDMARK_BURNED_TOWER`, `MUSIC_BURNED_TOWER`, phone `FALSE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:78` -> `map_const BURNED_TOWER_1F, 10, 9`
  (walk cells `x 0..19`, `y 0..17`)
- Scene var: `data/maps/scenes.asm:48` -> `wBurnedTower1FSceneID`
- Scene ids (positional, from `def_scene_scripts`): 0 =
  `SCENE_BURNEDTOWER1F_RIVAL_BATTLE`, 1 = `SCENE_BURNEDTOWER1F_FIREBREATHER_DICK`,
  2 = `SCENE_BURNEDTOWER1F_NOOP`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 15 | `ECRUTEAK_CITY` | 13 |
| 2 | 10 | 15 | `ECRUTEAK_CITY` | 13 |
| 3 | 5 | 4 | `BURNED_TOWER_B1F` | 1 |
| 4 | 5 | 5 | `BURNED_TOWER_B1F` | 1 |
| 5 | 5 | 6 | `BURNED_TOWER_B1F` | 1 |
| 6 | 4 | 6 | `BURNED_TOWER_B1F` | 1 |
| 7 | 15 | 4 | `BURNED_TOWER_B1F` | 2 |
| 8 | 15 | 5 | `BURNED_TOWER_B1F` | 2 |
| 9 | 10 | 7 | `BURNED_TOWER_B1F` | 3 |
| 10 | 5 | 14 | `BURNED_TOWER_B1F` | 4 |
| 11 | 4 | 14 | `BURNED_TOWER_B1F` | 4 |
| 12 | 14 | 14 | `BURNED_TOWER_B1F` | 5 |
| 13 | 15 | 14 | `BURNED_TOWER_B1F` | 5 |
| 14 | 7 | 15 | `BURNED_TOWER_B1F` | 6 |

Warps 1/2 are the `WARP_CARPET_DOWN` doorway. Warps 3-13 are `PIT` tiles (one-way
falls). Warp 14 is the only `LADDER` and the only two-way link to B1F.

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_BURNEDTOWER1F_FIREBREATHER_DICK` (1) | 8 | 1 | `FirebreatherDickFight` | Ambush battle with Firebreather Dick. |

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 8 | 7 | `BGEVENT_ITEM` | `BurnedTower1FHiddenEther` -> `hiddenitem ETHER, EVENT_BURNED_TOWER_1F_HIDDEN_ETHER` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `BURNEDTOWER1F_FIREBREATHER_DICK` | `SPRITE_FISHER` | 8 | 3 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `FirebreatherDickPostBattle` | `EVENT_BURNED_TOWER_FIREBREATHER_DICK_NORMAL` |
| `BURNEDTOWER1F_FIREBREATHER_NED` | `SPRITE_FISHER` | 16 | 8 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerFirebreatherNed` | -1 |
| `BURNEDTOWER1F_ROCK1` | `SPRITE_ROCK` | 4 | 3 | `SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | `BurnedTower1FRock` | -1 |
| `BURNEDTOWER1F_ROCK2` | `SPRITE_ROCK` | 16 | 13 | `SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | `BurnedTower1FRock` | -1 |
| `BURNEDTOWER1F_RIVAL` | `SPRITE_RIVAL` | 9 | 12 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 3) | `ObjectEvent` | `EVENT_RIVAL_BURNED_TOWER` |
| `BURNEDTOWER1F_FIREBREATHER_DICK_ASHES` | `SPRITE_FISHER` | 8 | 2 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `FirebreatherDickPostBattle` | `EVENT_BURNED_TOWER_FIREBREATHER_DICK_ASHES` |
| `BURNEDTOWER1F_POKE_BALL1` | `SPRITE_POKE_BALL` | 15 | 2 | `STILL` | `OBJECTTYPE_ITEMBALL` | `BurnedTower1FBurnHeal` (`itemball BURN_HEAL, 1`) | `EVENT_BURNED_TOWER_1F_X_SPEED` |
| `BURNEDTOWER1F_POKE_BALL2` | `SPRITE_POKE_BALL` | 7 | 5 | `STILL` | `OBJECTTYPE_ITEMBALL` | `BurnedTower1FXSpeed` (`itemball X_SPEED, 1`) | `EVENT_BURNED_TOWER_1F_BURN_HEAL` |

The two item ball rows have their one-time flags crossed: the ball that gives
`BURN_HEAL` is masked by `EVENT_BURNED_TOWER_1F_X_SPEED` and vice versa. It is
harmless (each ball still disappears exactly once) but a bot reading flags to
decide "do I already have the Burn Heal" must use the *row's* flag, not the item
name.

**Derived collision map** (`maps/BurnedTower1F.blk` + `data/tilesets/tower_collision.asm`;
`.` floor, `#` wall, `O` pit/warp, `L` ladder, `v` door)

```
    0         1
    0123456789012345678
 1  ##........##....###
 2  ###..##...###...###
 3  #.#..#....#.....###
 4  #...O###...##.O####
 5  #...O#.#....#.O.###
 6  #..OO#.##...#..####
 7  #....#..#O..#..#.##
 8  #...##.####.#....##
 9  #...##..##..#....##
10  ##.###.....###...##
11  ##..########.#...##
12  ###..........##..##
13  #.............#..##
14  ###OO........OO.###
15  ##....L.vv......###
```
(column 0 and rows 0/16-17 are solid wall and are trimmed.)

**Scripts of interest**

- `BurnedTower1FRivalBattleScene` (scene 0, the wram default) ->
  `sdefer BurnedTower1FRivalBattleScript` (`42:4e40`). Scene scripts run at map
  load, so **the rival battle fires the moment you first walk in the front door**,
  with the player at (9,15) and the rival at (9,12) walking two steps DOWN to
  (9,14). It is not at the far end of a spiral.
- `BurnedTower1FRivalBattleScript`: `turnobject PLAYER, UP`,
  `showemote EMOTE_SHOCK`, `special FadeOutMusic`, rival turn/pause choreography,
  `applymovement BURNEDTOWER1F_RIVAL, BurnedTowerMovement_RivalWalksToPlayer`
  (DOWN, DOWN), `playmusic MUSIC_RIVAL_ENCOUNTER`, then the starter branch:
  `checkevent EVENT_GOT_TOTODILE_FROM_ELM` -> `loadtrainer RIVAL1, RIVAL1_3_CHIKORITA`;
  `checkevent EVENT_GOT_CHIKORITA_FROM_ELM` -> `loadtrainer RIVAL1, RIVAL1_3_CYNDAQUIL`;
  otherwise (player took Cyndaquil) `loadtrainer RIVAL1, RIVAL1_3_TOTODILE`.
  After: `playmusic MUSIC_RIVAL_AFTER`,
  `applymovement ... BurnedTowerMovement_RivalLeaves` (RIGHT, DOWN),
  `disappear BURNEDTOWER1F_RIVAL`,
  `setscene SCENE_BURNEDTOWER1F_FIREBREATHER_DICK`.
- `FirebreatherDickFight` (`42:4ec1`), reached by the (8,1) coord event once the
  scene is 1: `showemote`, `applymovement` (Dick steps UP),
  `loadtrainer FIREBREATHER, DICK`, `startbattle`; on a win
  `disappear ..._DICK` / `appear ..._DICK_ASHES`,
  `setevent EVENT_BEAT_FIREBREATHER_DICK`,
  `setscene SCENE_BURNEDTOWER1F_NOOP`,
  `clearevent EVENT_BURNED_TOWER_FIREBREATHER_DICK_NORMAL`,
  `setevent EVENT_BURNED_TOWER_FIREBREATHER_DICK_ASHES`.
- `BurnedTower1FRock` -> `jumpstd SmashRockScript`
  (`engine/events/std_scripts.asm:199`) -> `farsjump AskRockSmashScript`
  (`engine/events/overworld.asm:1365`) -> `callasm HasRockSmash`
  (`CheckPartyMove ROCK_SMASH`). **No badge is required for Rock Smash**, only a
  party member that knows the move.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_RIVAL_BURNED_TOWER` | `constants/event_flags.asm:1127` | masks the rival object; **set** by `UndergroundRivalBattleScript` in `maps/GoldenrodUndergroundSwitchRoomEntrances.asm:125` | If you fight the rival in the Goldenrod Underground first, that script also does `setmapscene BURNED_TOWER_1F, SCENE_BURNEDTOWER1F_FIREBREATHER_DICK` and the Burned Tower rival battle never happens. Do this section before the Underground. |
| `EVENT_BEAT_FIREBREATHER_DICK` | `:577` | `FirebreatherDickFight` | - |
| `EVENT_BEAT_FIREBREATHER_NED` | `:578` | `TrainerFirebreatherNed` | - |
| `EVENT_BURNED_TOWER_FIREBREATHER_DICK_NORMAL` | `:1286` | cleared after the fight | Masks the pre-fight Dick at (8,3). |
| `EVENT_BURNED_TOWER_FIREBREATHER_DICK_ASHES` | `:1287` | set at new game, cleared/set here | Masks the post-fight Dick at (8,2). |
| `EVENT_BURNED_TOWER_1F_HIDDEN_ETHER` | `:138` | `BurnedTower1FHiddenEther` | Hidden ETHER at (8,7). |
| `EVENT_BURNED_TOWER_1F_X_SPEED` | `:1013` | ball at (15,2) that gives BURN_HEAL | Crossed name. |
| `EVENT_BURNED_TOWER_1F_BURN_HEAL` | `:1014` | ball at (7,5) that gives X_SPEED | Crossed name. |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `BURN_HEAL` | item ball, NE pocket (15,2) | `BurnedTower1FBurnHeal` | `EVENT_BURNED_TOWER_1F_X_SPEED` |
| `X_SPEED` | item ball, mid-west (7,5) | `BurnedTower1FXSpeed` | `EVENT_BURNED_TOWER_1F_BURN_HEAL` |
| `ETHER` | hidden at (8,7) | `bg_event 8, 7, BGEVENT_ITEM` | `EVENT_BURNED_TOWER_1F_HIDDEN_ETHER` |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `RIVAL1` / `RIVAL1_3_CHIKORITA` | `RIVAL1` | `constants/trainer_constants.asm:56` | `Rival1Group` entry 7: L20 HAUNTER (LICK, SPITE, MEAN_LOOK, CURSE); L18 MAGNEMITE (TACKLE, THUNDERSHOCK, SUPERSONIC, SONICBOOM); L20 ZUBAT (LEECH_LIFE, SUPERSONIC, BITE, CONFUSE_RAY); L22 BAYLEEF (GROWL, REFLECT, RAZOR_LEAF, POISONPOWDER) | `BurnedTower1FRivalBattleScript` | none |
| `RIVAL1` / `RIVAL1_3_CYNDAQUIL` | `RIVAL1` | `:57` | `Rival1Group` entry 8: same first three, L22 QUILAVA (LEER, SMOKESCREEN, EMBER, QUICK_ATTACK) | same | none |
| `RIVAL1` / `RIVAL1_3_TOTODILE` | `RIVAL1` | `:58` | `Rival1Group` entry 9: same first three, L22 CROCONAW (LEER, RAGE, WATER_GUN, BITE) | same | none |
| `FIREBREATHER` / `DICK` | `FIREBREATHER` | `:479` | `FirebreatherGroup` entry 2: L17 CHARMELEON | `FirebreatherDickFight` | none |
| `FIREBREATHER` / `NED` | `FIREBREATHER` | `:480` | `FirebreatherGroup` entry 3: L15 KOFFING, L16 GROWLITHE, L15 KOFFING | `TrainerFirebreatherNed` | none |

The rival's mon is the starter that beats yours: player Totodile -> rival
Chikorita line, player Chikorita -> rival Cyndaquil line, player Cyndaquil ->
rival Totodile line.

**Wild encounters**

`data/wild/johto_grass.asm:285`, `def_grass_wildmons BURNED_TOWER_1F`,
4% / 4% / 4%. Identical morn/day/nite table:
L13 RATTATA, L14 KOFFING, L15 RATTATA, L14 ZUBAT, L16 KOFFING, L15 RATICATE,
L15 RATICATE. (The walkthrough's "Rattata / Zubat / Koffing" is correct as far
as it goes; Raticate is also in the table.)

---

### BURNED_TOWER_B1F

- Script: `maps/BurnedTowerB1F.asm`
- Blocks: `maps/BurnedTowerB1F.blk` (90 bytes = 10x9 blocks)
- Header: `data/maps/maps.asm:92` -> `TILESET_CAVE`, `CAVE`,
  `LANDMARK_BURNED_TOWER`, `MUSIC_BURNED_TOWER`, phone `TRUE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:79` -> `map_const BURNED_TOWER_B1F, 10, 9`
- Scene var: `data/maps/scenes.asm:49` -> `wBurnedTowerB1FSceneID`
- Scene ids: 0 = `SCENE_BURNEDTOWERB1F_RELEASE_THE_BEASTS`, 1 = `SCENE_BURNEDTOWERB1F_NOOP`
  (both scene scripts are `end`; the work is done by the coord event)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 3 | `BURNED_TOWER_1F` | 3 |
| 2 | 17 | 7 | `BURNED_TOWER_1F` | 7 |
| 3 | 10 | 8 | `BURNED_TOWER_1F` | 9 |
| 4 | 3 | 13 | `BURNED_TOWER_1F` | 10 |
| 5 | 17 | 14 | `BURNED_TOWER_1F` | 12 |
| 6 | 7 | 15 | `BURNED_TOWER_1F` | 14 |

Only warp 6 sits on a `LADDER` tile. Warps 1-5 are landing anchors for the 1F
pits; their own tiles are `FLOOR` or ledge tiles, so `CheckWarpCollision`
(`engine/overworld/tile_events.asm:1`) never fires on them and you cannot go back
up through them. **The ladder at (7,15) is the only exit from B1F.**

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_BURNEDTOWERB1F_RELEASE_THE_BEASTS` (0) | 9 | 5 | `ReleaseTheBeasts` | The Raikou/Entei/Suicune cutscene. |

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 2 | 13 | `BGEVENT_ITEM` | `BurnedTowerB1FHiddenUltraBall` -> `hiddenitem ULTRA_BALL, EVENT_BURNED_TOWER_B1F_HIDDEN_ULTRA_BALL` |
| 17 | 14 | `BGEVENT_ITEM` | `BurnedTowerB1FHiddenBurnHeal` -> `hiddenitem BURN_HEAL, EVENT_BURNED_TOWER_B1F_HIDDEN_BURN_HEAL` |
| 8 | 3 | `BGEVENT_ITEM` | `BurnedTowerB1FHiddenNugget` -> `hiddenitem NUGGET, EVENT_BURNED_TOWER_B1F_HIDDEN_NUGGET` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `BURNEDTOWERB1F_BOULDER` | `SPRITE_BOULDER` | 17 | 4 | `STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | `BurnedTowerB1FBoulder` (`jumpstd StrengthBoulderScript`) | -1 |
| `BURNEDTOWERB1F_RAIKOU1` | `SPRITE_GROWLITHE` | 10 | 3 | `POKEMON` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_BURNED_TOWER_B1F_BEASTS_1` |
| `BURNEDTOWERB1F_ENTEI1` | `SPRITE_GROWLITHE` | 8 | 4 | `POKEMON` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_BURNED_TOWER_B1F_BEASTS_1` |
| `BURNEDTOWERB1F_SUICUNE1` | `SPRITE_GROWLITHE` | 7 | 2 | `POKEMON` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_BURNED_TOWER_B1F_BEASTS_1` |
| `BURNEDTOWERB1F_RAIKOU2` | `SPRITE_GROWLITHE` | 10 | 3 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_BURNED_TOWER_B1F_BEASTS_2` |
| `BURNEDTOWERB1F_ENTEI2` | `SPRITE_GROWLITHE` | 8 | 4 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_BURNED_TOWER_B1F_BEASTS_2` |
| `BURNEDTOWERB1F_SUICUNE2` | `SPRITE_GROWLITHE` | 7 | 2 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_BURNED_TOWER_B1F_BEASTS_2` |
| `BURNEDTOWERB1F_POKE_BALL1` | `SPRITE_POKE_BALL` | 4 | 3 | `STILL` | `OBJECTTYPE_ITEMBALL` | `BurnedTowerB1FHPUp` (`itemball HP_UP`) | `EVENT_BURNED_TOWER_B1F_HP_UP` |
| `BURNEDTOWERB1F_POKE_BALL2` | `SPRITE_POKE_BALL` | 15 | 3 | `STILL` | `OBJECTTYPE_ITEMBALL` | `BurnedTowerB1FTMEndure` (`itemball TM_ENDURE`) | `EVENT_BURNED_TOWER_B1F_TM_ENDURE` |

The two `SPRITE_GROWLITHE` triples are the same three beasts drawn twice: the
`..._1` set (`SPRITEMOVEDATA_POKEMON`, coloured `PAL_NPC_BROWN/RED/BLUE`) is the
animated set, the `..._2` set (`STANDING_DOWN`, `PAL_NPC_EMOTE`) is the static
set. `EVENT_BURNED_TOWER_B1F_BEASTS_1` is **set** by the new-game init block in
`engine/events/std_scripts.asm:525`, so the static set is what you first see;
`ReleaseTheBeasts` does `appear`/`disappear` to swap them.

**Scripts of interest**

- `ReleaseTheBeasts` (`42:53c4`), triggered by the (9,5) coord event on scene 0:
  `playmusic MUSIC_NONE`, three `appear`/`disappear`/`cry` beats for RAIKOU,
  ENTEI, SUICUNE, then three `playsound SFX_WARP_FROM` + `applymovement`
  (`BurnedTowerRaikouMovement` right, `BurnedTowerEnteiMovement` down,
  `BurnedTowerSuicuneMovement` left) + `disappear`, then
  `special RestartMapMusic`, `setscene SCENE_BURNEDTOWERB1F_NOOP`,
  `setevent EVENT_RELEASED_THE_BEASTS`, **`special InitRoamMons`**.
- `UnusedEnteiScript` is marked `; unreferenced` - a `loadwildmon ENTEI, 40`
  encounter that never runs. Do not build a bot around it.
- `BurnedTowerB1FBoulder` -> `jumpstd StrengthBoulderScript` ->
  `farsjump AskStrengthScript` (`engine/events/overworld.asm:1001`), which needs
  STRENGTH (PLAINBADGE gated) - not obtainable in this section, and not needed
  for anything here.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_RELEASED_THE_BEASTS` | `constants/event_flags.asm:132` | set by `ReleaseTheBeasts`; read by `EcruteakCityLass2Script` | Cutscene done, roamers live. |
| `EVENT_BURNED_TOWER_B1F_BEASTS_1` | `:1260` | set at new game (`std_scripts.asm:525`), cleared by `appear` | Set = animated beasts hidden. |
| `EVENT_BURNED_TOWER_B1F_BEASTS_2` | `:1261` | set by `disappear` in the cutscene | Set = static beasts hidden. |
| `EVENT_BURNED_TOWER_B1F_HP_UP` | `:1015` | item ball (4,3) | - |
| `EVENT_BURNED_TOWER_B1F_TM_ENDURE` | `:1016` | item ball (15,3) | - |
| `EVENT_BURNED_TOWER_B1F_HIDDEN_ULTRA_BALL` | `:139` | bg event (2,13) | - |
| `EVENT_BURNED_TOWER_B1F_HIDDEN_BURN_HEAL` | `:140` | bg event (17,14) | - |
| `EVENT_BURNED_TOWER_B1F_HIDDEN_NUGGET` | `:141` | bg event (8,3) | - |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `HP_UP` | item ball at (4,3), right next to the warp-1 landing spot | `BurnedTowerB1FHPUp` | `EVENT_BURNED_TOWER_B1F_HP_UP` |
| `TM_ENDURE` | item ball at (15,3), east ledge pocket | `BurnedTowerB1FTMEndure` | `EVENT_BURNED_TOWER_B1F_TM_ENDURE` |
| `ULTRA_BALL` | hidden at (2,13) | bg event | `EVENT_BURNED_TOWER_B1F_HIDDEN_ULTRA_BALL` |
| `BURN_HEAL` | hidden at (17,14) | bg event | `EVENT_BURNED_TOWER_B1F_HIDDEN_BURN_HEAL` |
| `NUGGET` | hidden at (8,3) | bg event | `EVENT_BURNED_TOWER_B1F_HIDDEN_NUGGET` |

**Trainers**

None.

**Wild encounters**

`data/wild/johto_grass.asm:313`, `def_grass_wildmons BURNED_TOWER_B1F`,
6% / 6% / 6%.

| slot | morn | day | nite |
|---|---|---|---|
| 1 | L14 RATTATA | L14 RATTATA | L14 RATTATA |
| 2 | L14 KOFFING | L14 KOFFING | L14 KOFFING |
| 3 | L16 KOFFING | L16 KOFFING | L16 KOFFING |
| 4 | L16 RATTATA | L16 MAGMAR | L16 RATTATA |
| 5 | L15 ZUBAT | L15 ZUBAT | L15 ZUBAT |
| 6 | L14 MAGMAR | L14 RATTATA | L14 MAGMAR |
| 7 | L14 MAGMAR | L14 RATTATA | L14 MAGMAR |

**Movement note**: B1F is built on `HOP_*` ledge tiles (`data/tilesets/cave_collision.asm`).
Landing anchors (17,7) and (10,8) are themselves ledge tiles; walking off a ledge
tile in the ledge's direction becomes a two-cell jump
(`.TryJump` / `.ledge_table`, `engine/overworld/player_movement.asm:350-392`).
The route to the beasts is: fall through 1F's centre pit at (10,7) -> land at
B1F (10,8) -> walk UP to (10,7), (10,6) -> LEFT to (9,6) -> UP onto (9,5) ->
`ReleaseTheBeasts`.

---

### ECRUTEAK_GYM

- Script: `maps/EcruteakGym.asm`
- Blocks: `maps/EcruteakGym.blk` (45 bytes = 5x9 blocks)
- Header: `data/maps/maps.asm:171` -> `TILESET_TOWER`, `INDOOR`,
  `LANDMARK_ECRUTEAK_CITY`, `MUSIC_GYM`, phone `TRUE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:157` -> `map_const ECRUTEAK_GYM, 5, 9`
  (walk cells `x 0..9`, `y 0..17`)
- No scene scripts, no coord events.

**Warps** (`def_warp_events`) - 33 rows, almost all of them the invisible floor

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 17 | `ECRUTEAK_CITY` | 10 |
| 2 | 5 | 17 | `ECRUTEAK_CITY` | 10 |
| 3 | 4 | 14 | `ECRUTEAK_GYM` | 4 |
| 4 | 2 | 4 | `ECRUTEAK_GYM` | 3 |
| 5 | 3 | 4 | `ECRUTEAK_GYM` | 3 |
| 6 | 4 | 4 | `ECRUTEAK_GYM` | 3 |
| 7 | 4 | 5 | `ECRUTEAK_GYM` | 3 |
| 8 | 6 | 7 | `ECRUTEAK_GYM` | 3 |
| 9 | 7 | 4 | `ECRUTEAK_GYM` | 3 |
| 10 | 2 | 6 | `ECRUTEAK_GYM` | 3 |
| 11 | 3 | 6 | `ECRUTEAK_GYM` | 3 |
| 12 | 4 | 6 | `ECRUTEAK_GYM` | 3 |
| 13 | 5 | 6 | `ECRUTEAK_GYM` | 3 |
| 14 | 7 | 6 | `ECRUTEAK_GYM` | 3 |
| 15 | 7 | 7 | `ECRUTEAK_GYM` | 3 |
| 16 | 4 | 8 | `ECRUTEAK_GYM` | 3 |
| 17 | 5 | 8 | `ECRUTEAK_GYM` | 3 |
| 18 | 6 | 8 | `ECRUTEAK_GYM` | 3 |
| 19 | 7 | 8 | `ECRUTEAK_GYM` | 3 |
| 20 | 2 | 8 | `ECRUTEAK_GYM` | 3 |
| 21 | 2 | 9 | `ECRUTEAK_GYM` | 3 |
| 22 | 2 | 10 | `ECRUTEAK_GYM` | 3 |
| 23 | 2 | 11 | `ECRUTEAK_GYM` | 3 |
| 24 | 4 | 10 | `ECRUTEAK_GYM` | 3 |
| 25 | 5 | 10 | `ECRUTEAK_GYM` | 3 |
| 26 | 2 | 12 | `ECRUTEAK_GYM` | 3 |
| 27 | 3 | 12 | `ECRUTEAK_GYM` | 3 |
| 28 | 4 | 12 | `ECRUTEAK_GYM` | 3 |
| 29 | 5 | 12 | `ECRUTEAK_GYM` | 3 |
| 30 | 7 | 10 | `ECRUTEAK_GYM` | 3 |
| 31 | 7 | 11 | `ECRUTEAK_GYM` | 3 |
| 32 | 7 | 12 | `ECRUTEAK_GYM` | 3 |
| 33 | 7 | 13 | `ECRUTEAK_GYM` | 3 |

Every hole (warps 4-33) dumps you at warp 3, i.e. (4,14), just inside the door -
the walkthrough's "fall off the path anywhere and it'll drop you back to the gym
entrance". Warp 3's own destination (warp 4 at (2,4)) is never used, because
(4,14) is a `FLOOR` tile and `CheckWarpCollision` only fires on pit/warp
collisions.

**Coord events**: empty.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 3 | 15 | `BGEVENT_READ` | `EcruteakGymStatue` |
| 6 | 15 | `BGEVENT_READ` | `EcruteakGymStatue` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ECRUTEAKGYM_MORTY` | `SPRITE_MORTY` | 5 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `EcruteakGymMortyScript` | -1 |
| `ECRUTEAKGYM_SAGE1` | `SPRITE_SAGE` | 2 | 7 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerSageJeffrey` | -1 |
| `ECRUTEAKGYM_SAGE2` | `SPRITE_SAGE` | 3 | 13 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerSagePing` | -1 |
| `ECRUTEAKGYM_GRANNY1` | `SPRITE_GRANNY` | 7 | 5 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerMediumMartha` | -1 |
| `ECRUTEAKGYM_GRANNY2` | `SPRITE_GRANNY` | 7 | 9 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerMediumGrace` | -1 |
| `ECRUTEAKGYM_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 7 | 15 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `EcruteakGymGuideScript` | -1 |

**Derived collision map** (`maps/EcruteakGym.blk` + `data/tilesets/tower_collision.asm`;
`.` floor, `#` wall, `O` pit, `v` exit carpet)

```
    0123456789
 0  ##......##
 1  ##..M...##     M = Morty (5,1)
 2  ##......##
 3  ##......##
 4  ##OOO.O.##     (6,4) is a PIT with NO warp row -> safe to stand on
 5  ##..O..G##     G = Medium Martha (7,5)
 6  ##OOOO.O##
 7  ##J...F O##    J = Sage Jeffrey (2,7); F = (6,7) FLOOR with a stray warp row
 8  ##O.OOOO##
 9  ##O....G##     G = Medium Grace (7,9)
10  ##O.OO.O##
11  ##O....O##
12  ##OOOO.O##
13  ##P....O##     P = Sage Ping (3,13)
14  ##......##     (4,14) = warp 3, the landing tile for every hole
15  ##.##..##.     statues at (3,15) and (6,15)
16  ##........
17  ####vv####     exit at (4,17)/(5,17)
```
(rows 15-17 above are schematic for the statue/door area; the pit rows 4-13 are
exact.)

Two data quirks, both verified by diffing the warp rows against the block
collision:

- **(6,7) has a warp row but is a `FLOOR` tile**, so it never triggers. This is
  what makes the walkthrough's "go right 3" step from (3,7) land safely on (6,7).
- **(6,4) is a `PIT` tile with no warp row at all.** `CheckWarpCollision` sets
  carry, `GetDestinationWarpNumber` finds no match, `CheckWarpTile` returns no
  carry, so you simply stand on it. This is what makes "move up two squares to
  get past the platform" work. It looks like the (6,4) row was mistyped as (6,7).

**The verified zig-zag path** (every cell below is FLOOR unless noted):

`(4,17) -> (4,16) -> (4,15) -> (4,14) -> (4,13)` [face LEFT: **Sage Ping** at (3,13)]
`-> (5,13) -> (6,13) -> (6,12) -> (6,11) -> (6,10) -> (6,9)` [face RIGHT: **Medium Grace** at (7,9)]
`-> (5,9) -> (4,9) -> (3,9) -> (3,8) -> (3,7)` [face LEFT: **Sage Jeffrey** at (2,7)]
`-> (4,7) -> (5,7) -> (6,7) -> (6,6) -> (6,5)` [face RIGHT: **Medium Martha** at (7,5)]
`-> (6,4)` (the harmless pit) `-> (6,3) -> (5,3) -> (5,2)` [face UP: **Morty** at (5,1)]

**Scripts of interest**

- `EcruteakGymMortyScript` (`52:508f`): `checkevent EVENT_BEAT_MORTY` ->
  `.FightDone`; else `writetext MortyIntroText`,
  `winlosstext MortyWinLossText, 0`, `loadtrainer MORTY, MORTY1`, `startbattle`,
  `reloadmapafterbattle`, `setevent EVENT_BEAT_MORTY`,
  `writetext Text_ReceivedFogBadge`, `playsound SFX_GET_BADGE`,
  **`setflag ENGINE_FOGBADGE`**, `readvar VAR_BADGES`,
  `scall EcruteakGymActivateRockets`,
  `setmapscene ECRUTEAK_TIN_TOWER_ENTRANCE, SCENE_ECRUTEAKTINTOWERENTRANCE_NOOP`.
  Then `.FightDone` (`52:50bd`): `checkevent EVENT_GOT_TM30_SHADOW_BALL` ->
  `.GotShadowBall`; else it **force-sets all four gym trainer flags**
  (`EVENT_BEAT_SAGE_JEFFREY`, `EVENT_BEAT_SAGE_PING`, `EVENT_BEAT_MEDIUM_MARTHA`,
  `EVENT_BEAT_MEDIUM_GRACE`), then `verbosegiveitem TM_SHADOW_BALL`,
  `iffalse .NoRoomForShadowBall`, `setevent EVENT_GOT_TM30_SHADOW_BALL`.
  So TM30 is safely re-obtainable if the bag was full: the flag is only set on a
  successful give.
- `EcruteakGymActivateRockets`: `ifequal 7, .RadioTowerRockets` /
  `ifequal 6, .GoldenrodRockets` on `VAR_BADGES`. Irrelevant on a linear run
  (Fog is badge 4), but a bot that badge-skips can trip it.
- `EcruteakGymStatue`: `checkflag ENGINE_FOGBADGE` -> `GymStatue2Script` with
  `gettrainername STRING_BUFFER_4, MORTY, MORTY1`; else `GymStatue1Script`.
- `EcruteakGymGuideScript` branches on `EVENT_BEAT_MORTY`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_MORTY` | `constants/event_flags.asm:709` | `EcruteakGymMortyScript` | Badge fight done. |
| `ENGINE_FOGBADGE` | `constants/engine_flags.asm:41` | set here; read by `SurfFunction.TrySurf` (`engine/events/overworld.asm:340`), `TrySurfOW` (`:490`), `EcruteakGymStatue`, `EcruteakTinTowerEntranceSageScript` | Field SURF, obedience to L50, `data/types/badge_type_boosts.asm:6` GHOST boost. |
| `EVENT_GOT_TM30_SHADOW_BALL` | `constants/event_flags.asm:18` | `EcruteakGymMortyScript` | TM30 given. |
| `EVENT_BEAT_SAGE_JEFFREY` | `:522` | `TrainerSageJeffrey`, force-set by Morty | - |
| `EVENT_BEAT_SAGE_PING` | `:523` | `TrainerSagePing`, force-set by Morty | - |
| `EVENT_BEAT_MEDIUM_MARTHA` | `:930` | `TrainerMediumMartha`, force-set by Morty | - |
| `EVENT_BEAT_MEDIUM_GRACE` | `:931` | `TrainerMediumGrace`, force-set by Morty | - |
| `SCENE_ECRUTEAKTINTOWERENTRANCE_NOOP` | positional (id 1) in `maps/EcruteakTinTowerEntrance.asm` | `setmapscene` from Morty's script | Disables the Tin Tower sage-block coord events at (4,7) and (5,7). |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `TM_SHADOW_BALL` (TM30) | beat Morty, then keep talking | `EcruteakGymMortyScript.FightDone` | `EVENT_GOT_TM30_SHADOW_BALL` |
| FOGBADGE | beat Morty | `setflag ENGINE_FOGBADGE` | `EVENT_BEAT_MORTY` |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `SAGE` / `PING` | `SAGE` (`constants/trainer_constants.asm:579`) | `SageGroup` entry 6 "PING" | 5x L16 GASTLY, `TRAINERTYPE_NORMAL` | `TrainerSagePing` | none |
| `MEDIUM` / `GRACE` | `MEDIUM` (`:586`) | `MediumGroup` entry 2 "GRACE" | L20 HAUNTER, L20 HAUNTER | `TrainerMediumGrace` | none |
| `SAGE` / `JEFFREY` | `SAGE` (`:578`) | `SageGroup` entry 5 "JEFFREY" | L22 HAUNTER | `TrainerSageJeffrey` | none |
| `MEDIUM` / `MARTHA` | `MEDIUM` (`:585`) | `MediumGroup` entry 1 "MARTHA" | L18 GASTLY, L20 HAUNTER, L20 GASTLY | `TrainerMediumMartha` | none |
| `MORTY` / `MORTY1` | `MORTY` (`:36-37`) | `MortyGroup`, `TRAINERTYPE_MOVES` | L21 GASTLY (LICK, SPITE, MEAN_LOOK, CURSE); L21 HAUNTER (HYPNOSIS, MIMIC, CURSE, NIGHT_SHADE); L25 GENGAR (HYPNOSIS, SHADOW_BALL, MEAN_LOOK, DREAM_EATER); L23 HAUNTER (SPITE, MEAN_LOOK, MIMIC, NIGHT_SHADE) | `EcruteakGymMortyScript` | none |

`MortyGroup` sends the mons in file order: GASTLY 21, HAUNTER 21, GENGAR 25,
HAUNTER 23. The walkthrough's "L23 Haunter, L25 Gengar, L23 Haunter" ordering and
its "Level 23 Haunter" second slot do not match the asm - the second slot is
**level 21**, and Gengar comes third, not last.

**Wild encounters**

None (indoor).

---

### ECRUTEAK_TIN_TOWER_ENTRANCE (one line, unlocked here)

`maps/EcruteakTinTowerEntrance.asm` has
`coord_event 4, 7, SCENE_ECRUTEAKTINTOWERENTRANCE_SAGE_BLOCKS, EcruteakTinTowerEntranceSageBlocksLeft`
and `coord_event 5, 7, ..., ...SageBlocksRight`; Morty's `setmapscene` to the
NOOP scene is what stops the sages from side-stepping in front of you. Everything
past that door belongs to the next section.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Bill is not in Goldenrod | `maps/BillsFamilysHouse.asm` object row `EVENT_MET_BILL`; flag set at new game by `engine/events/std_scripts.asm` (init block) | Ecruteak Pokecenter cutscene | `EcruteakPokcenter1FBillActivatesTimeCapsuleScript` does `clearevent EVENT_MET_BILL` |
| No Eevee | `maps/BillsFamilysHouse.asm:BillScript` `readvar VAR_PARTYCOUNT` / `ifequal PARTY_LENGTH, .NoRoom` | a free party slot, and answer YES | `setevent EVENT_GOT_EEVEE` |
| No HM03 SURF | `maps/DanceTheater.asm:DanceTheaterSurfGuy` - five `checkevent EVENT_BEAT_KIMONO_GIRL_*` / `iffalse .KimonoGirlsUndefeated` | beat NAOKO, SAYO, ZUKI, KUNI, MIKI | `.GetSurf` -> `verbosegiveitem HM_SURF`, `setevent EVENT_GOT_HM03_SURF` |
| SURF unusable in the field | `engine/events/overworld.asm:340` (`SurfFunction.TrySurf`: `ld de, ENGINE_FOGBADGE` / `CheckBadge`) and `:490` (`TrySurfOW`: `CheckEngineFlag`) | FOGBADGE | `setflag ENGINE_FOGBADGE` in `EcruteakGymMortyScript` |
| Burned Tower 1F north half (Firebreather Dick coord event at (8,1), X SPEED at (7,5), hidden ETHER at (8,7)) and the centre pit at (10,7) that reaches the beasts | rock object at (4,3), `SPRITEMOVEDATA_SMASHABLE_ROCK` -> `BurnedTower1FRock` -> `jumpstd SmashRockScript` -> `AskRockSmashScript` -> `callasm HasRockSmash` (`CheckPartyMove ROCK_SMASH`) | a party mon that knows ROCK_SMASH. **No badge check.** | smash the rock |
| Burned Tower 1F east loop (BURN HEAL at (15,2), Firebreather Ned at (16,8), the (15,4)/(15,5) pits) | rock object at (16,13), same std script | ROCK_SMASH | smash the rock |
| Burned Tower B1F return to 1F | only `warp_event 7, 15` sits on a `LADDER` tile; warps 1-5 are on non-warp collisions so `CheckWarpCollision` (`engine/overworld/tile_events.asm:1`) rejects them | reach (7,15) | walk there |
| B1F boulder at (17,4) | `jumpstd StrengthBoulderScript` -> `AskStrengthScript` (`engine/events/overworld.asm:1001`) -> `callasm TryStrengthOW` | STRENGTH + PLAINBADGE | not obtainable in this section; nothing needed here is behind it |
| Ecruteak Gym invisible floor | 30 `warp_event` rows on `COLL_PIT` tiles, all pointing at warp 3 (4,14) | walk the exact zig-zag above | none - it is pure navigation |
| Rival battle in the Burned Tower | rival object masked by `EVENT_RIVAL_BURNED_TOWER`; `maps/GoldenrodUndergroundSwitchRoomEntrances.asm:125` sets it and `setmapscene BURNED_TOWER_1F, SCENE_BURNEDTOWER1F_FIREBREATHER_DICK` | do Burned Tower **before** the Goldenrod Underground rival fight | ordering only |
| Tin Tower | `maps/EcruteakTinTowerEntrance.asm` coord events (4,7)/(5,7) on `SCENE_ECRUTEAKTINTOWERENTRANCE_SAGE_BLOCKS` | FOGBADGE | `setmapscene ... NOOP` from `EcruteakGymMortyScript` |
| Bike shop "keep the bicycle" call | `engine/overworld/events.asm:1267 DoBikeStep` - needs `STATUSFLAGS2_BIKE_SHOP_CALL_F`, `wPlayerState == PLAYER_BIKE`, `GetMapPhoneService` == 0, and `wBikeStep` high byte >= `HIGH(1024)` | 1024 bike steps in phone-service territory | queues `SPECIALCALL_BIKESHOP`, then `engine/phone/scripts/bike_shop.asm` clears `ENGINE_BIKE_SHOP_CALL_ENABLED` |

---

## 4. Bot checklist

Preconditions carried in from section 06: Sudowoodo beaten/caught, bicycle owned
(`EVENT_GOT_BICYCLE`), `ENGINE_BIKE_SHOP_CALL_ENABLED` set.

1. `ROUTE_37`, walk from the `ROUTE_36` south connection. Optional: fight
   `TrainerTwinsAnnandanne1` at (6,12) (sight 1) - pre `EVENT_BEAT_TWINS_ANN_AND_ANNE`
   clear, post set (this also disables the twin at (7,12)).
2. `ROUTE_37` (9,6): fight `TrainerPsychicGreg` (sight 3). Post
   `EVENT_BEAT_PSYCHIC_GREG`.
3. `ROUTE_37`: talk to the fruit trees at (13,5), (16,5), (15,7) -> RED / BLU /
   BLK apricorn. Precondition: bag space. No flag; resets daily.
4. `ROUTE_37` (4,2): ITEMFINDER-less hidden `ETHER`, flag
   `EVENT_ROUTE_37_HIDDEN_ETHER`.
5. Optional, Sundays only: `ROUTE_37` (16,8) talk `SunnyScript` -> `MAGNET`.
   Precondition `VAR_WEEKDAY == SUNDAY`; post `EVENT_GOT_MAGNET_FROM_SUNNY`.
6. Walk north into `ECRUTEAK_CITY`. Postcondition `ENGINE_FLYPOINT_ECRUTEAK` set
   by `EcruteakCityFlypointCallback` (`MAPCALLBACK_NEWMAP`).
7. `ECRUTEAK_CITY` warp 6 at (23,27) -> `ECRUTEAK_POKECENTER_1F`. On map load the
   scene script fires (scene 0). Do not press anything for the length of the
   cutscene. Post: `EVENT_MET_BILL` **cleared**, `ENGINE_TIME_CAPSULE` set, scene
   -> 1. Then heal at the nurse (3,1) and deposit apricorns/berries at the PC.
8. Ride back south: `ROUTE_37` -> `ROUTE_36` -> `NATIONAL_PARK` -> `ROUTE_35` ->
   `GOLDENROD_CITY`. Somewhere in here the bike-shop call fires
   (`DoBikeStep`, 1024 bike steps).
9. `GOLDENROD_CITY` warp 4 at (5,25) -> `BILLS_FAMILYS_HOUSE`. Precondition:
   party count < 6. Talk to Bill at (2,3), answer YES. Post `EVENT_GOT_EEVEE`,
   L20 EEVEE in party.
10. Optional: talk to the twin at (5,4) to register `PHONE_BILL`.
11. Ride back north to `ECRUTEAK_CITY`.
12. `ECRUTEAK_CITY` warp 8 at (23,21) -> `DANCE_THEATER`.
13. In `DANCE_THEATER`, walk adjacent and press A on each Kimono Girl - they all
    have sight 0 and will not start a battle themselves:
    (0,2) NAOKO / FLAREON, (2,1) SAYO / ESPEON, (6,2) ZUKI / UMBREON,
    (9,1) KUNI / VAPOREON, (11,2) MIKI / JOLTEON. Each posts its own
    `EVENT_BEAT_KIMONO_GIRL_*`.
14. `DANCE_THEATER` (7,10): talk to the gentleman. Precondition: all five flags
    set and bag space for an HM. Post `EVENT_GOT_HM03_SURF` + `HM_SURF` in bag.
    Teach SURF now; it will not work in the field until step 24.
15. Leave via warp 1/2 at (5,13)/(6,13).
16. `ECRUTEAK_CITY` warp 11 at (13,27) -> `ECRUTEAK_ITEMFINDER_HOUSE`. Talk to
    (2,3), answer **YES** to the `yesorno`. Post `EVENT_GOT_ITEMFINDER`.
17. Optional: with ITEMFINDER, pick up the hidden `HYPER_POTION` at
    `ECRUTEAK_CITY` (23,14).
18. Heal, stock Escape Ropes / Repels / Great Balls, then `ECRUTEAK_CITY`
    warp 13 at (5,5) -> `BURNED_TOWER_1F`.
19. **On entry the rival scene fires immediately** (scene 0 ->
    `sdefer BurnedTower1FRivalBattleScript`). Precondition:
    `EVENT_RIVAL_BURNED_TOWER` **clear** (i.e. the Goldenrod Underground rival
    fight has not happened). Battle is `RIVAL1` /
    `RIVAL1_3_{CHIKORITA|CYNDAQUIL|TOTODILE}` chosen from
    `EVENT_GOT_TOTODILE_FROM_ELM` / `EVENT_GOT_CHIKORITA_FROM_ELM`.
    Post: rival disappears, scene -> `SCENE_BURNEDTOWER1F_FIREBREATHER_DICK`.
20. `BURNED_TOWER_1F`: walk (9,15) -> (9,14) -> row 13 west to (2,13), north up
    column 2/3 to the (4,3) rock. Use ROCK_SMASH on it (field move or
    `AskRockSmashScript` yes-prompt). This opens the whole north half.
21. Step on the (8,1) tile to trigger `FirebreatherDickFight`
    (`FIREBREATHER`/`DICK`, L17 CHARMELEON). Post `EVENT_BEAT_FIREBREATHER_DICK`,
    scene -> `SCENE_BURNEDTOWER1F_NOOP`.
22. Pick up `X_SPEED` at (7,5) and the hidden `ETHER` at (8,7). Then step onto
    the pit at (10,7) -> `BURNED_TOWER_B1F` warp 3 at (10,8).
23. `BURNED_TOWER_B1F`: walk UP to (10,7), (10,6), LEFT to (9,6), UP to (9,5).
    Precondition scene 0. This runs `ReleaseTheBeasts`. Post
    `EVENT_RELEASED_THE_BEASTS`, scene -> 1, `special InitRoamMons` seeds the
    three roamers.
24. Optional B1F loot: `NUGGET` hidden at (8,3). Then leave by the ladder at
    (7,15) (the only exit).
25. Optional, back on 1F: smash the (16,13) rock to open the east loop -
    `FIREBREATHER`/`NED` at (16,8) and the `BURN_HEAL` ball at (15,2).
26. Optional HP UP: from 1F step on any of the NW pits (5,4), (5,5), (5,6),
    (4,6) -> B1F (3,3), grab `HP_UP` at (4,3), hop the ledges south and out via
    the (7,15) ladder.
27. Leave `BURNED_TOWER_1F` via warp 1/2 at (9,15)/(10,15). Heal at the
    Pokecenter, save.
28. `ECRUTEAK_CITY` warp 10 at (6,27) -> `ECRUTEAK_GYM`. Walk the exact path in
    the ECRUTEAK_GYM section above. Fight, in order:
    `SAGE`/`PING` at (3,13), `MEDIUM`/`GRACE` at (7,9), `SAGE`/`JEFFREY` at
    (2,7), `MEDIUM`/`MARTHA` at (7,5).
29. Talk to Morty at (5,1) from (5,2). Battle `MORTY`/`MORTY1`. Post
    `EVENT_BEAT_MORTY`, `ENGINE_FOGBADGE` set,
    `setmapscene ECRUTEAK_TIN_TOWER_ENTRANCE, ...NOOP`.
30. Keep talking to Morty (same script, `.FightDone` arm) with bag space to get
    `TM_SHADOW_BALL`. Post `EVENT_GOT_TM30_SHADOW_BALL`. If the bag was full the
    flag is not set and the give can be retried.
31. Field SURF is now legal (`TrySurfOW` `CheckEngineFlag ENGINE_FOGBADGE`
    passes). The Ecruteak water encounter table (`ECRUTEAK_CITY`, 2%, POLIWAG /
    POLIWHIRL) becomes reachable.

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map/warp/bg/object tables decoded from the ROM (no hand-authored map data) | `src/import/RomExtractorGen2.lua` (`OBJECTTYPE_ITEMBALL`/`OBJECTTYPE_TRAINER` at :71, `readItemBall` at :2874-2969) | implemented |
| Warps triggered by pit/warp tile collision | `src/world/gen2/Permissions.lua:164` (cites `COLL_PIT` / `COLL_PIT_68` / `HI_NYBBLE_WARPS`, `CheckWarpCollision`) | implemented |
| Coord events gated on the map's scene id | `src/world/gen2/World.lua:5005 World:tryCoordScript` | implemented |
| Scene scripts run on map load; per-map scene ids saved | `src/world/gen2/World.lua:5021 World:trySceneScript`, `:1161 World:scene`, `:740/:746 setScene/setMapScene`, `src/core/gen2/Save.lua` | implemented |
| `sdefer` (the Bill and rival cutscenes) | `src/script/gen2/Vm.lua:92` - explicitly runs it inline instead of deferring past the map settle | partial (documented deviation; cutscene ordering may differ by a frame or two) |
| Object masking by event flag (`appear`/`disappear`, Bill, the beasts, the rival) | `src/script/gen2/Vm.lua` (`variablesprite` :353 etc.), `src/world/gen2/Npc.lua` | implemented |
| Trainer sight lines / walk-up battles | `src/world/gen2/Trainers.lua:98 Trainers.sees` | implemented |
| `loadtrainer` overriding the object's own trainer id (rival branch) | `src/script/gen2/Vm.lua:806` | implemented |
| `startbattle` result plumbing, incl. the `iftrue .next` arm this map uses | `src/script/gen2/Vm.lua:42`, `:602`, and the comment at `:825` which cites `maps/BurnedTower1F.asm` by name | implemented |
| `verbosegiveitem` (HM03, ITEMFINDER, TM30, MAGNET) | `src/script/gen2/Vm.lua:490` | implemented |
| `givepoke EEVEE, 20` | `src/script/gen2/Vm.lua:439` | implemented |
| Item balls | `src/import/RomExtractorGen2.lua:2874/2968` + object dispatch in `src/world/gen2/Events.lua` | implemented |
| Hidden items (`BGEVENT_ITEM` -> `hiddenitem`) and ITEMFINDER sweep | `src/world/gen2/HiddenItems.lua` | implemented |
| Fruit trees / apricorns | `src/script/gen2/Opcodes.lua:160` (`fruittree`), `src/core/gen2/Apricorns.lua` | implemented |
| Rock Smash field move (no badge) | `src/world/gen2/FieldMoves.lua` (badge table at :106-118, `ROCK_SMASH` has no badge entry) | implemented |
| SURF field move gated on FOGBADGE | `src/world/gen2/FieldMoves.lua:106` (`SURF = "FOG"`), `:477 SurfFunction`, `:663 trySurfOW` | implemented |
| Strength / PLAINBADGE (B1F boulder) | `src/world/gen2/FieldMoves.lua:108`, `:695 tryStrengthOW` | implemented |
| Badge flags and the L50 obedience/type-boost effects | `src/world/gen2/FieldMoves.lua:118` badge list; battle side in `src/battle/gen2/` | implemented |
| `special InitRoamMons` + roamer movement/encounters | `src/script/gen2/Specials.lua:1845`, `src/core/gen2/Roamers.lua`, driver `tests/drivers/gold_roamers.lua` | implemented |
| `special FadeOutMusic` / `RestartMapMusic` (both cutscenes) | `src/script/gen2/Specials.lua:1059`, `:1066` | implemented |
| `showemote`, `applymovement`, `turnobject`, `cry` choreography | `src/script/gen2/Vm.lua:961`, `src/script/gen2/Movement.lua` | implemented |
| Bike step counter / bike shop special call | `src/world/gen2/StepEvents.lua:48`, `:104-112`, `src/world/gen2/Bike.lua:4`, `src/world/gen2/World.lua:1992` (`specialphonecall`) | implemented |
| Time Capsule (`ENGINE_TIME_CAPSULE` is set, but the feature itself) | `src/script/gen2/Specials.lua:2215-2220` - `EnterTimeCapsule`, `TimeCapsule`, `CheckTimeCapsuleCompatibility` are all stubbed "link cable: no Time Capsule" | missing (flag set, menu inert) |
| Map callbacks (`MAPCALLBACK_NEWMAP` fly point, `MAPCALLBACK_OBJECTS` Sunny) | `src/world/gen2/World.lua` + driver `tests/drivers/gold_map_callbacks.lua` | implemented |
| A driver that actually walks Ecruteak / Burned Tower / the gym | none - the `tests/drivers/gold_*.lua` set covers boot, walk, warp, battle, roamers, but no Ecruteak route | missing |
| Ledge hops (`HOP_*`) as used all over Burned Tower B1F | not found in `src/world/gen2/Permissions.lua` or `Player.lua` under those names | unverified - grep for `HOP_` returned nothing; needs a hands-on check before a bot relies on B1F traversal |

---

## 6. Unresolved / verify by hand

1. **"Head left and all the way around the spiral and you will now fight your
   rival."** The asm disagrees. `BurnedTower1FRivalBattleScene` is scene 0 (the
   wram default) and `sdefer`s the battle script, so it runs on map load; the
   rival object sits at (9,12), three cells straight up from the (9,15) door, and
   walks two steps DOWN to meet you. The battle happens as soon as you step
   inside.
2. **"Equipping the TM Rock Smash will give you the HP Up at the northeastern
   part of the floor."** Conflated. The northeast item on 1F is a `BURN_HEAL`
   ball at (15,2) behind the (16,13) rock. The `HP_UP` is on B1F at (4,3),
   reached by falling through the northwest pits - which the walkthrough gets
   right later ("grab a HP Up by dropping down the northwest hole").
3. **Rock Smash is not optional if you want the beasts.** Flood-filling
   `maps/BurnedTower1F.blk` against `data/tilesets/tower_collision.asm` from the
   (9,15) door shows that with both rocks intact you can only reach the four
   northwest pits, the ladder, and the (4,14)/(5,14)/(14,14)/(15,14) pits - not
   the centre pit at (10,7), which is the only route to B1F's (9,5) beast
   trigger. This is a derived result, not a line of asm; worth confirming on
   hardware/emulator before a bot depends on it.
4. **Ecruteak Gym (6,7)** carries a `warp_event` row but its block collision is
   `FLOOR`, so the warp never fires. **(6,4)** is the mirror image: a `PIT` tile
   with no `warp_event` row, so you can stand on it. Both are consistent with the
   walkthrough's step counts working, and both look like one transposed row in
   the source data. Derived from the `.blk`; verify visually.
5. **Morty's party order.** The walkthrough lists "L21 Gastly, L23 Haunter, L25
   Gengar, L23 Haunter". `MortyGroup` in `data/trainers/parties.asm:35` is
   L21 GASTLY, **L21** HAUNTER, L25 GENGAR, L23 HAUNTER. The second Haunter is
   level 21, and its EXP figure in the walkthrough (567) is therefore suspect.
6. **`DanceTheaterSurfGuy.GetSurf` has no `iffalse` after
   `verbosegiveitem HM_SURF`.** Every other give in this section
   (`ITEMFINDER`, `TM_SHADOW_BALL`, the Bill's-grandpa stones) checks the return.
   If the bag genuinely cannot take an HM the flag would still be set. Whether
   the bag can ever be full for the HM pocket in GS is worth checking before a
   bot risks it - keep at least one free slot.
7. **Twins Ann & Anne share one flag.** Both objects use
   `EVENT_BEAT_TWINS_ANN_AND_ANNE`; `EVENT_BEAT_TWINS_ANN_AND_ANNE2`
   (`constants/event_flags.asm:610`) is defined but unreferenced by this map.
   A bot that expects two battles on Route 37 will hang.
8. **Route 37's twins are declared `SPRITE_WEIRD_TREE`** with object consts
   `ROUTE37_WEIRD_TREE1/2`, and `SPRITE_WEIRD_TREE` is `variablesprite`d to
   `SPRITE_SUDOWOODO` by the new-game init block. Transcribed verbatim from
   `maps/Route37.asm:237-238`; what actually renders on screen was not verified.
9. **Burned Tower 1F item ball flags are crossed** (`BURN_HEAL` ball carries
   `EVENT_BURNED_TOWER_1F_X_SPEED` and vice versa). Verbatim from
   `maps/BurnedTower1F.asm:311-312`. Functionally harmless, but do not infer the
   item from the flag name.
10. **Ledge (`HOP_*`) traversal on B1F** could not be found in the port. The asm
    side is `engine/overworld/player_movement.asm:350-392` (`.TryJump` /
    `.ledge_table`, a two-cell jump when leaving a ledge tile in its direction).
    Marked "unverified" in the port table above.
11. **`EcruteakGymActivateRockets`** branches on `VAR_BADGES == 6` / `== 7`. On a
    linear run Fog is the fourth badge so neither arm fires; a badge-skipping bot
    will trigger `GoldenrodRocketsScript` / `RadioTowerRocketsScript` out of
    order. Not exercised in this section.
12. **Walkthrough EXP and money figures** were not checked against
    `engine/battle/` at all; they are reproduced nowhere in this document for
    that reason.

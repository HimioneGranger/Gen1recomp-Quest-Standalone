# Section 12 - Team Rocket Radio Tower

Source: `../section-12-team-rocket-radio-tower.txt` (the FAQ's own heading is
"18 > Team Rocket Radio Tower")
Maps covered: `MAP_GOLDENROD_CITY`, `MAP_RADIO_TOWER_1F`, `MAP_RADIO_TOWER_2F`,
`MAP_RADIO_TOWER_3F`, `MAP_RADIO_TOWER_4F`, `MAP_RADIO_TOWER_5F`,
`MAP_GOLDENROD_UNDERGROUND`, `MAP_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES`,
`MAP_GOLDENROD_UNDERGROUND_WAREHOUSE`, `MAP_GOLDENROD_DEPT_STORE_B1F`

Badges / key milestones in this section:

- No badge. The section is bracketed by two key items and one story flag:
  `BASEMENT_KEY` (from the fake director, `RADIO_TOWER_5F`), `CARD_KEY` (from the
  real director, `GOLDENROD_UNDERGROUND_WAREHOUSE`), and
  `EVENT_CLEARED_RADIO_TOWER` + `RAINBOW_WING` (Gold) / `SILVER_WING` (Silver)
  from `RadioTower5FRocketBossScript`.
- The rival's fourth battle (`RIVAL1_4_*`) happens in the middle of it.
- Entry condition is the 7th badge, not any item: see section 3.

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `MAP_GOLDENROD_CITY` | `maps/GoldenrodCity.asm` | Fly (`ENGINE_FLYPOINT_GOLDENROD`, set by `GoldenrodCityFlypointCallback`) | warp 12 at (5,15) | Elm's phone call; city is full of Rockets |
| 2 | `MAP_RADIO_TOWER_1F` | `maps/RadioTower1F.asm` | warps 1/2 at (2,7)/(3,7) | warp 3 at (15,0) | first Grunt (`TrainerGruntM3`) |
| 3 | `MAP_RADIO_TOWER_2F` | `maps/RadioTower2F.asm` | warp 2 at (15,0) | warp 1 at (0,0) | four Grunts, head left |
| 4 | `MAP_RADIO_TOWER_3F` | `maps/RadioTower3F.asm` | warp 1 at (0,0) | warp 2 at (7,0) | two Grunts + Scientist Marc |
| 5 | `MAP_RADIO_TOWER_4F` | `maps/RadioTower4F.asm` | warp 2 at (9,0) | warp 1 at (0,0) | `TrainerGruntM10`, `TrainerScientistRich` |
| 6 | `MAP_RADIO_TOWER_5F` | `maps/RadioTower5F.asm` | warp 1 at (0,0) | warp 1 at (0,0) | `coord_event 0, 3` -> `FakeDirectorScript`, `EXECUTIVEM_3`, `BASEMENT_KEY` |
| 7 | `MAP_GOLDENROD_CITY` | `maps/GoldenrodCity.asm` | radio tower warp | warp 14 at (9,5) | "northwesternmost building" = north Underground entrance |
| 8 | `MAP_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` | `maps/GoldenrodUndergroundSwitchRoomEntrances.asm` | warp 8 at (20,29) | warp 7 at (21,25) | just the stairwell room on this pass |
| 9 | `MAP_GOLDENROD_UNDERGROUND` | `maps/GoldenrodUnderground.asm` | warp 1 at (3,2) | warp 3 at (18,6) | Pokemon Salon (haircut brothers); the locked door |
| 10 | `MAP_GOLDENROD_UNDERGROUND` (south half) | same file | warp 4 at (21,31) | warp 6 at (22,27) | the basement door is a same-map warp pair |
| 11 | `MAP_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` | `maps/GoldenrodUndergroundSwitchRoomEntrances.asm` | warp 1 at (23,3) | warps 2/3 at (22,10)/(23,10) | rival battle, three switch Grunts, two Burglars, the shutter puzzle |
| 12 | `MAP_GOLDENROD_UNDERGROUND_WAREHOUSE` | `maps/GoldenrodUndergroundWarehouse.asm` | warps 1/2 at (2,12)/(3,12) | warp 3 at (17,2) | three Grunts, Max Ether, TM35, the Director + `CARD_KEY` |
| 13 | `MAP_GOLDENROD_DEPT_STORE_B1F` | `maps/GoldenrodDeptStoreB1F.asm` | warp 1 at (17,2) | warp 1 back, or elevator warps 2/3 at (9,4)/(10,4) | Amulet Coin at (14,2) |
| 14 | `MAP_RADIO_TOWER_3F` | `maps/RadioTower3F.asm` | 2F warp 1 at (0,0) | warp 3 at (17,0) | `bg_event 14, 2, BGEVENT_UP, CardKeySlotScript`; `TrainerGruntM9` |
| 15 | `MAP_RADIO_TOWER_4F` | `maps/RadioTower4F.asm` | warp 4 at (17,0) | warp 3 at (12,0) | `TrainerGruntF4`, `TrainerExecutivem2` |
| 16 | `MAP_RADIO_TOWER_5F` | `maps/RadioTower5F.asm` | warp 2 at (12,0) | warp 2 at (12,0) | `TrainerExecutivef1`, then `coord_event 16, 5` -> `RadioTower5FRocketBossScript` |

Spill into the next section: the walkthrough's closing party-level lists and the
video link's mention of Route 44 belong to whatever section follows; nothing
after `RadioTower5FRocketBossScript` is covered here.

---

## 2. Maps

### MAP_GOLDENROD_CITY

- Script: `maps/GoldenrodCity.asm`
- Blocks: `maps/GoldenrodCity.blk`
- Header: `data/maps/maps.asm:269` -> `TILESET_JOHTO_MODERN`, `TOWN`,
  `LANDMARK_GOLDENROD_CITY`, `MUSIC_GOLDENROD_CITY`, phone `FALSE`,
  `PALETTE_AUTO`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:247` -> `map_const GOLDENROD_CITY, 20, 18`
- Connections: `data/maps/attributes.asm:139` -> north `ROUTE_35` (offset 5),
  south `ROUTE_34` (offset 5). No east/west.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 24 | 7 | `GOLDENROD_GYM` | 1 |
| 2 | 29 | 29 | `GOLDENROD_BIKE_SHOP` | 1 |
| 3 | 31 | 21 | `GOLDENROD_HAPPINESS_RATER` | 1 |
| 4 | 5 | 25 | `BILLS_FAMILYS_HOUSE` | 1 |
| 5 | 9 | 13 | `GOLDENROD_MAGNET_TRAIN_STATION` | 2 |
| 6 | 33 | 5 | `GOLDENROD_FLOWER_SHOP` | 1 |
| 7 | 15 | 27 | `GOLDENROD_POKECENTER_1F` | 1 |
| 8 | 33 | 9 | `GOLDENROD_PP_SPEECH_HOUSE` | 1 |
| 9 | 15 | 7 | `GOLDENROD_NAME_RATER` | 1 |
| 10 | 24 | 27 | `GOLDENROD_DEPT_STORE_1F` | 1 |
| 11 | 14 | 21 | `GOLDENROD_GAME_CORNER` | 1 |
| 12 | 5 | 15 | `RADIO_TOWER_1F` | 1 |
| 13 | 19 | 1 | `ROUTE_35_GOLDENROD_GATE` | 3 |
| 14 | 9 | 5 | `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` | 8 |
| 15 | 11 | 29 | `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` | 5 |

Warp 14 is the "northwesternmost building" the walkthrough sends you to for the
Basement Key trip; warp 15 is the southern Underground entrance.

**Coord events** (`def_coord_events`) - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 10 | 14 | `BGEVENT_READ` | `GoldenrodCityStationSign` |
| 4 | 17 | `BGEVENT_READ` | `GoldenrodCityRadioTowerSign` |
| 26 | 27 | `BGEVENT_READ` | `GoldenrodDeptStoreSign` |
| 26 | 9 | `BGEVENT_READ` | `GoldenrodGymSign` |
| 22 | 18 | `BGEVENT_READ` | `GoldenrodCitySign` |
| 28 | 30 | `BGEVENT_READ` | `GoldenrodCityBikeShopSign` |
| 16 | 22 | `BGEVENT_READ` | `GoldenrodCityGameCornerSign` |
| 12 | 7 | `BGEVENT_READ` | `GoldenrodCityNameRaterSign` |
| 8 | 6 | `BGEVENT_READ` | `GoldenrodCityUndergroundSignNorth` |
| 12 | 30 | `BGEVENT_READ` | `GoldenrodCityUndergroundSignSouth` |
| 16 | 27 | `BGEVENT_READ` | `GoldenrodCityPokecenterSign` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `GOLDENRODCITY_POKEFAN_M1` | `SPRITE_POKEFAN_M` | 7 | 18 | `STANDING_UP` | `SCRIPT` | `GoldenrodCityPokefanMScript` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `GOLDENRODCITY_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 30 | 17 | `WANDER` | `SCRIPT` | `GoldenrodCityYoungster1Script` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `GOLDENRODCITY_COOLTRAINER_F1` | `SPRITE_COOLTRAINER_F` | 12 | 16 | `STANDING_LEFT` | `SCRIPT` | `GoldenrodCityCooltrainerF1Script` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `GOLDENRODCITY_COOLTRAINER_F2` | `SPRITE_COOLTRAINER_F` | 20 | 26 | `WANDER` | `SCRIPT` | `GoldenrodCityCooltrainerF2Script` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `GOLDENRODCITY_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 19 | 17 | `WANDER` | `SCRIPT` | `GoldenrodCityYoungster2Script` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `GOLDENRODCITY_LASS` | `SPRITE_LASS` | 17 | 10 | `WALK_LEFT_RIGHT` | `SCRIPT` | `GoldenrodCityLassScript` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `GOLDENRODCITY_GRAMPS` | `SPRITE_GRAMPS` | 11 | 27 | `WALK_LEFT_RIGHT` | `SCRIPT` | `GoldenrodCityGrampsScript` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `GOLDENRODCITY_ROCKETSCOUT` | `SPRITE_ROCKET` | 4 | 16 | `STANDING_UP` | `SCRIPT` | `GoldenrodCityRocketScoutScript` | `EVENT_GOLDENROD_CITY_ROCKET_SCOUT` |
| `GOLDENRODCITY_ROCKET1` | `SPRITE_ROCKET` | 28 | 20 | `STANDING_UP` | `SCRIPT` | `GoldenrodCityRocket1Script` | `EVENT_GOLDENROD_CITY_ROCKET_TAKEOVER` |
| `GOLDENRODCITY_ROCKET2` | `SPRITE_ROCKET` | 8 | 15 | `STANDING_DOWN` | `SCRIPT` | `GoldenrodCityRocket2Script` | `EVENT_GOLDENROD_CITY_ROCKET_TAKEOVER` |
| `GOLDENRODCITY_ROCKET3` | `SPRITE_ROCKET` | 16 | 23 | `STANDING_RIGHT` | `SCRIPT` | `GoldenrodCityRocket3Script` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `GOLDENRODCITY_ROCKET4` | `SPRITE_ROCKET` | 29 | 20 | `STANDING_UP` | `SCRIPT` | `GoldenrodCityRocket4Script` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `GOLDENRODCITY_ROCKET5` | `SPRITE_ROCKET` | 29 | 7 | `STANDING_DOWN` | `SCRIPT` | `GoldenrodCityRocket5Script` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `GOLDENRODCITY_ROCKET6` | `SPRITE_ROCKET` | 30 | 10 | `STANDING_LEFT` | `SCRIPT` | `GoldenrodCityRocket6Script` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |

None of the city Rockets are trainers - they are all `jumptextfaceplayer`.

**Scripts of interest**

- `GoldenrodCityFlypointCallback` (`MAPCALLBACK_NEWMAP`): `setflag
  ENGINE_FLYPOINT_GOLDENROD` / `setflag ENGINE_REACHED_GOLDENROD`. This is why
  the walkthrough can say "fly to the city".

---

### MAP_RADIO_TOWER_1F

- Script: `maps/RadioTower1F.asm`
- Blocks: `maps/RadioTower1F.blk`
- Header: `data/maps/maps.asm:95` -> `TILESET_RADIO_TOWER`, `INDOOR`,
  `LANDMARK_RADIO_TOWER`, `RADIO_TOWER_MUSIC | MUSIC_GOLDENROD_CITY`, phone
  `TRUE`, `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:82` -> `map_const RADIO_TOWER_1F, 9, 4`
- Connections: none (`data/maps/attributes.asm:414`, environment byte `$00`)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `GOLDENROD_CITY` | 12 |
| 2 | 3 | 7 | `GOLDENROD_CITY` | 12 |
| 3 | 15 | 0 | `RADIO_TOWER_2F` | 2 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 3 | 0 | `BGEVENT_READ` | `RadioTower1FDirectory` |
| 13 | 0 | `BGEVENT_READ` | `RadioTower1FLuckyChannelSign` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `RADIOTOWER1F_RECEPTIONIST` | `SPRITE_RECEPTIONIST` | 5 | 6 | `STANDING_LEFT` | `SCRIPT` | `RadioTower1FReceptionistScript` | -1 |
| `RADIOTOWER1F_LASS` | `SPRITE_LASS` | 16 | 4 | `STANDING_LEFT` | `SCRIPT` | `RadioTower1FLassScript` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `RADIOTOWER1F_YOUNGSTER` | `SPRITE_YOUNGSTER` | 15 | 4 | `STANDING_RIGHT` | `SCRIPT` | `RadioTower1FYoungsterScript` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `RADIOTOWER1F_ROCKET` | `SPRITE_ROCKET` | 14 | 1 | `STANDING_DOWN` | `TRAINER` (sight 3) | `TrainerGruntM3` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `RADIOTOWER1F_LUCKYNUMBERMAN` | `SPRITE_GENTLEMAN` | 8 | 6 | `STANDING_UP` | `SCRIPT` | `RadioTower1FLuckyNumberManScript` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `RADIOTOWER1F_CARD_WOMAN` | `SPRITE_COOLTRAINER_F` | 12 | 6 | `STANDING_UP` | `SCRIPT` | `RadioTower1FRadioCardWomanScript` | `EVENT_GOLDENROD_CITY_CIVILIANS` |

**Scripts of interest**

- `RadioTower1FReceptionistScript` - `checkflag ENGINE_ROCKETS_IN_RADIO_TOWER`;
  if set, the "no tours today" line. Pure flavour, no gate.
- `TrainerGruntM3` - `trainer GRUNTM, GRUNTM_3, EVENT_BEAT_ROCKET_GRUNTM_3, ...`.
  Sight range 3 facing down from (14,1): he intercepts the walk to warp 3 at
  (15,0).
- `RadioTower1FRadioCardWomanScript` / `RadioTower1FLuckyNumberManScript` are the
  Radio Card quiz and the Lucky Number Show. Both are hidden while
  `EVENT_GOLDENROD_CITY_CIVILIANS` is set, i.e. for the whole of this section.

---

### MAP_RADIO_TOWER_2F

- Script: `maps/RadioTower2F.asm`
- Blocks: `maps/RadioTower2F.blk`
- Header: `data/maps/maps.asm:96` -> same row shape as 1F
- Dimensions: `constants/map_constants.asm:83` -> `map_const RADIO_TOWER_2F, 9, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 0 | `RADIO_TOWER_3F` | 1 |
| 2 | 15 | 0 | `RADIO_TOWER_1F` | 3 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 3 | 0 | `BGEVENT_READ` | `RadioTower2FSalesSign` |
| 5 | 0 | `BGEVENT_READ` | `RadioTower2FOaksPKMNTalkSign` |
| 9 | 1 | `BGEVENT_READ` | `RadioTower2FBookshelf` |
| 10 | 1 | `BGEVENT_READ` | `RadioTower2FBookshelf` |
| 11 | 1 | `BGEVENT_READ` | `RadioTower2FBookshelf` |
| 13 | 0 | `BGEVENT_READ` | `RadioTower2FPokemonRadioSign` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `RADIOTOWER2F_SUPER_NERD` | `SPRITE_SUPER_NERD` | 5 | 6 | `WALK_LEFT_RIGHT` | `SCRIPT` | `RadioTower2FSuperNerdScript` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `RADIOTOWER2F_TEACHER` | `SPRITE_TEACHER` | 13 | 2 | `WALK_LEFT_RIGHT` | `SCRIPT` | `RadioTower2FTeacherScript` | -1 |
| `RADIOTOWER2F_ROCKET1` | `SPRITE_ROCKET` | 1 | 4 | `STANDING_UP` | `TRAINER` (sight 3) | `TrainerGruntM4` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `RADIOTOWER2F_ROCKET2` | `SPRITE_ROCKET` | 8 | 4 | `STANDING_DOWN` | `TRAINER` (sight 3) | `TrainerGruntM5` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `RADIOTOWER2F_ROCKET3` | `SPRITE_ROCKET` | 4 | 1 | `STANDING_DOWN` | `TRAINER` (sight 2) | `TrainerGruntM6` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `RADIOTOWER2F_ROCKET_GIRL` | `SPRITE_ROCKET_GIRL` | 10 | 5 | `STANDING_UP` | `TRAINER` (sight 3) | `TrainerGruntF2` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `RADIOTOWER2F_BLACK_BELT1` | `SPRITE_BLACK_BELT` | 0 | 1 | `STANDING_DOWN` | `SCRIPT` | `RadioTower2FBlackBelt1Script` | `EVENT_RADIO_TOWER_BLACKBELT_BLOCKS_STAIRS` |
| `RADIOTOWER2F_BLACK_BELT2` | `SPRITE_BLACK_BELT` | 1 | 1 | `STANDING_DOWN` | `SCRIPT` | `RadioTower2FBlackBelt2Script` | `EVENT_RADIO_TOWER_CIVILIANS_AFTER` |
| `RADIOTOWER2F_JIGGLYPUFF` | `SPRITE_JIGGLYPUFF` | 12 | 1 | `POKEMON` | `SCRIPT` | `RadioTowerJigglypuff` | -1 |

**Scripts of interest**

- `RadioTower2FBlackBelt1Script` at (0,1) is the pre-takeover stairs blocker
  ("Authorized personnel only beyond this point"). `RadioTowerRocketsScript`
  (`engine/events/std_scripts.asm:255`) does `setevent
  EVENT_RADIO_TOWER_BLACKBELT_BLOCKS_STAIRS`, and a SET object event flag MASKS
  the object (`CheckObjectFlag`, `engine/overworld/map_objects_2.asm:32`), so
  during the takeover he is gone and warp 1 at (0,0) is walkable.
- Walkthrough order on this floor is `TrainerGruntF2` (10,5) -> `TrainerGruntM5`
  (8,4) -> `TrainerGruntM6` (4,1) -> `TrainerGruntM4` (1,4).

---

### MAP_RADIO_TOWER_3F

- Script: `maps/RadioTower3F.asm`
- Blocks: `maps/RadioTower3F.blk`
- Header: `data/maps/maps.asm:97`
- Dimensions: `constants/map_constants.asm:84` -> `map_const RADIO_TOWER_3F, 9, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 0 | `RADIO_TOWER_2F` | 1 |
| 2 | 7 | 0 | `RADIO_TOWER_4F` | 2 |
| 3 | 17 | 0 | `RADIO_TOWER_4F` | 4 |

Warp 3 is only reachable once the Card Key shutter is open.

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 3 | 0 | `BGEVENT_READ` | `RadioTower3FPersonnelSign` |
| 9 | 0 | `BGEVENT_READ` | `RadioTower3FPokemonMusicSign` |
| 14 | 2 | `BGEVENT_UP` | `CardKeySlotScript` |

`BGEVENT_UP` means the player must be FACING UP on the tile below (14,2) for the
press to register (`engine/overworld/events.asm:644` `.up` -> `.checkdir`
compares `wPlayerDirection & %1100` against `OW_UP`).

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `RADIOTOWER3F_SUPER_NERD` | `SPRITE_SUPER_NERD` | 7 | 4 | `STANDING_UP` | `SCRIPT` | `RadioTower3FSuperNerdScript` | `EVENT_RADIO_TOWER_CIVILIANS_AFTER` |
| `RADIOTOWER3F_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 3 | 4 | `SPINRANDOM_FAST` | `SCRIPT` | `RadioTower3FGymGuideScript` | -1 |
| `RADIOTOWER3F_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 11 | 3 | `WANDER` | `SCRIPT` | `RadioTower3FCooltrainerFScript` | -1 |
| `RADIOTOWER3F_ROCKET1` | `SPRITE_ROCKET` | 5 | 1 | `STANDING_RIGHT` | `TRAINER` (sight 2) | `TrainerGruntM7` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `RADIOTOWER3F_ROCKET2` | `SPRITE_ROCKET` | 6 | 2 | `STANDING_DOWN` | `TRAINER` (sight 3) | `TrainerGruntM8` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `RADIOTOWER3F_ROCKET3` | `SPRITE_ROCKET` | 16 | 6 | `STANDING_UP` | `TRAINER` (sight 3) | `TrainerGruntM9` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `RADIOTOWER3F_SCIENTIST` | `SPRITE_SCIENTIST` | 9 | 6 | `STANDING_UP` | `TRAINER` (sight 5) | `TrainerScientistMarc` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |

`TrainerGruntM9` at (16,6) sits behind the shutter: he is only reachable on the
second pass.

**Scripts of interest**

- `RadioTower3FCardKeyShutterCallback` (`callback MAPCALLBACK_TILES`, label at
  `43:5be1`): `checkevent EVENT_USED_THE_CARD_KEY_IN_THE_RADIO_TOWER`; if true,
  `changeblock 14, 2, $2a` (open shutter) and `changeblock 14, 4, $01` (floor).
  This is what makes the opening persist across map loads.
- `CardKeySlotScript` (`43:5c91`, exported with `::` so other maps can reach it):
  writes `RadioTower3FCardKeySlotText`, then `checkevent
  EVENT_USED_THE_CARD_KEY_IN_THE_RADIO_TOWER` (already used -> just close),
  else `checkitem CARD_KEY`. With the key: `InsertedTheCardKeyText`, `setevent
  EVENT_USED_THE_CARD_KEY_IN_THE_RADIO_TOWER`, `playsound SFX_ENTER_DOOR`, the
  same two `changeblock`s, `refreshmap`.
- `RadioTower3FCooltrainerFScript` - after `EVENT_CLEARED_RADIO_TOWER`,
  `verbosegiveitem TM_SUNNY_DAY` and `setevent
  EVENT_GOT_SUNNY_DAY_FROM_RADIO_TOWER`. The walkthrough does not mention this
  reward.

---

### MAP_RADIO_TOWER_4F

- Script: `maps/RadioTower4F.asm`
- Blocks: `maps/RadioTower4F.blk`
- Header: `data/maps/maps.asm:98`
- Dimensions: `constants/map_constants.asm:85` -> `map_const RADIO_TOWER_4F, 9, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 0 | `RADIO_TOWER_5F` | 1 |
| 2 | 9 | 0 | `RADIO_TOWER_3F` | 2 |
| 3 | 12 | 0 | `RADIO_TOWER_5F` | 2 |
| 4 | 17 | 0 | `RADIO_TOWER_3F` | 3 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 7 | 0 | `BGEVENT_READ` | `RadioTower4FProductionSign` |
| 15 | 0 | `BGEVENT_READ` | `RadioTower4FStudio2Sign` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `RADIOTOWER4F_FISHER` | `SPRITE_FISHER` | 6 | 4 | `STANDING_UP` | `SCRIPT` | `RadioTower4FFisherScript` | `EVENT_RADIO_TOWER_CIVILIANS_AFTER` |
| `RADIOTOWER4F_TEACHER` | `SPRITE_TEACHER` | 14 | 6 | `SPINRANDOM_SLOW` | `SCRIPT` | `RadioTower4FDJMaryScript` | -1 |
| `RADIOTOWER4F_GROWLITHE` | `SPRITE_GROWLITHE` | 12 | 7 | `POKEMON` | `SCRIPT` | `RadioTowerMeowth` | -1 |
| `RADIOTOWER4F_ROCKET1` | `SPRITE_ROCKET` | 5 | 6 | `SPINCLOCKWISE` | `TRAINER` (sight 3) | `TrainerGruntM10` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `RADIOTOWER4F_ROCKET2` | `SPRITE_ROCKET` | 14 | 1 | `STANDING_LEFT` (radius 2,0) | `TRAINER` (sight 2) | `TrainerExecutivem2` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `RADIOTOWER4F_ROCKET_GIRL` | `SPRITE_ROCKET_GIRL` | 12 | 4 | `STANDING_RIGHT` | `TRAINER` (sight 1) | `TrainerGruntF4` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `RADIOTOWER4F_SCIENTIST` | `SPRITE_SCIENTIST` | 4 | 2 | `STANDING_LEFT` | `TRAINER` (sight 4) | `TrainerScientistRich` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |

**Scripts of interest**

- `TrainerExecutivem2` at (14,1) guards warp 3 (12,0), the second route to 5F.
- `RadioTower4FDJMaryScript` - after `EVENT_CLEARED_RADIO_TOWER`,
  `verbosegiveitem PINK_BOW` and `setevent EVENT_GOT_PINK_BOW_FROM_MARY`. Another
  reward the walkthrough skips.

---

### MAP_RADIO_TOWER_5F

- Script: `maps/RadioTower5F.asm`
- Blocks: `maps/RadioTower5F.blk`
- Header: `data/maps/maps.asm:99`
- Dimensions: `constants/map_constants.asm:86` -> `map_const RADIO_TOWER_5F, 9, 4`

Scene ids come from this map's own `def_scene_scripts` block (`scene_script`
allocates them in order, `macros/scripts/maps.asm:25`):
`SCENE_RADIOTOWER5F_FAKE_DIRECTOR` = 0, `SCENE_RADIOTOWER5F_ROCKET_BOSS` = 1,
`SCENE_RADIOTOWER5F_NOOP` = 2. All three scene bodies are `end`; the work is
entirely in the coord events.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 0 | `RADIO_TOWER_4F` | 1 |
| 2 | 12 | 0 | `RADIO_TOWER_4F` | 3 |

**Coord events**

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_RADIOTOWER5F_FAKE_DIRECTOR` (0) | 0 | 3 | `FakeDirectorScript` | fake director battle, `BASEMENT_KEY` |
| `SCENE_RADIOTOWER5F_ROCKET_BOSS` (1) | 16 | 5 | `RadioTower5FRocketBossScript` | final Executive, tower cleared |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 3 | 0 | `BGEVENT_READ` | `RadioTower5FDirectorsOfficeSign` |
| 11 | 0 | `BGEVENT_READ` | `RadioTower5FStudio1Sign` |
| 15 | 0 | `BGEVENT_READ` | `RadioTower5FStudio1Sign` |
| 16 | 1 | `BGEVENT_READ` | `RadioTower5FBookshelf` |
| 17 | 1 | `BGEVENT_READ` | `RadioTower5FBookshelf` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `RADIOTOWER5F_DIRECTOR` | `SPRITE_GENTLEMAN` | 3 | 6 | `SPINRANDOM_SLOW` | `SCRIPT` | `Director` | -1 |
| `RADIOTOWER5F_ROCKET` | `SPRITE_ROCKET` | 13 | 5 | `STANDING_LEFT` | `SCRIPT` | `ObjectEvent` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `RADIOTOWER5F_ROCKET_GIRL` | `SPRITE_ROCKET_GIRL` | 17 | 2 | `STANDING_LEFT` | `TRAINER` (sight 1) | `TrainerExecutivef1` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `RADIOTOWER5F_ROCKER` | `SPRITE_ROCKER` | 13 | 5 | `STANDING_LEFT` | `SCRIPT` | `Ben` | `EVENT_RADIO_TOWER_CIVILIANS_AFTER` |

Note the deliberate coordinate collision at (13,5): the Rocket boss and DJ Ben
occupy the same cell, masked by complementary flags.

**Scripts of interest**

- `FakeDirectorScript` (`43:6748`) - `turnobject RADIOTOWER5F_DIRECTOR, UP`,
  `showemote EMOTE_SHOCK`, text, `applymovement RADIOTOWER5F_DIRECTOR,
  FakeDirectorMovement` (LEFT x3, UP x2, from (3,6) to (0,4)), `playmusic
  MUSIC_ROCKET_ENCOUNTER`, `winlosstext FakeDirectorWinText, 0`, `setlasttalked
  RADIOTOWER5F_DIRECTOR`, `loadtrainer EXECUTIVEM, EXECUTIVEM_3`, `startbattle`,
  `reloadmapafterbattle`, `verbosegiveitem BASEMENT_KEY`, `setscene
  SCENE_RADIOTOWER5F_ROCKET_BOSS`, `setevent EVENT_BEAT_ROCKET_EXECUTIVEM_3`.
  Note the `verbosegiveitem` result is not checked - there is no bag-full arm.
- `RadioTower5FRocketBossScript` (`43:67a5`) - `applymovement PLAYER` two steps
  LEFT (from (16,5) to (14,5)), `playmusic MUSIC_ROCKET_ENCOUNTER`, `turnobject
  RADIOTOWER5F_ROCKET, RIGHT`, `loadtrainer EXECUTIVEM, EXECUTIVEM_1`,
  `startbattle`, `reloadmapafterbattle`. Afterwards it fades out, disappears both
  Rockets, then does the whole flag cascade:

  ```
  setevent EVENT_BEAT_ROCKET_EXECUTIVEM_1
  setevent EVENT_CLEARED_RADIO_TOWER
  clearflag ENGINE_ROCKETS_IN_RADIO_TOWER
  setevent EVENT_GOLDENROD_CITY_ROCKET_SCOUT
  setevent EVENT_GOLDENROD_CITY_ROCKET_TAKEOVER
  setevent EVENT_RADIO_TOWER_ROCKET_TAKEOVER
  clearevent EVENT_MAHOGANY_MART_OWNERS
  clearflag ENGINE_ROCKETS_IN_MAHOGANY
  clearevent EVENT_GOLDENROD_CITY_CIVILIANS
  clearevent EVENT_RADIO_TOWER_CIVILIANS_AFTER
  setevent EVENT_BLACKTHORN_CITY_SUPER_NERD_BLOCKS_GYM
  clearevent EVENT_BLACKTHORN_CITY_SUPER_NERD_DOES_NOT_BLOCK_GYM
  ```

  Then `moveobject RADIOTOWER5F_DIRECTOR, 12, 0` / `appear` / `applymovement
  RadioTower5FDirectorWalksIn`, `checkver`: Silver takes `.SilverWing`
  (`verbosegiveitem SILVER_WING`, `setevent EVENT_GOT_SILVER_WING`), Gold falls
  through (`verbosegiveitem RAINBOW_WING`, `setevent EVENT_GOT_RAINBOW_WING`,
  `setevent EVENT_TEAM_ROCKET_DISBANDED`). Both arms `setscene
  SCENE_RADIOTOWER5F_NOOP` and end with `RadioTower5FDirectorWalksOut` +
  `disappear`.
- `Director` (the talk-to script) branches on `EVENT_CLEARED_RADIO_TOWER`.

---

### MAP_GOLDENROD_UNDERGROUND

- Script: `maps/GoldenrodUnderground.asm`
- Blocks: `maps/GoldenrodUnderground.blk`
- Header: `data/maps/maps.asm:123` -> `TILESET_GATE`, `DUNGEON`,
  `LANDMARK_GOLDENROD_CITY`, `MUSIC_UNION_CAVE`, phone `TRUE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:110` -> `map_const GOLDENROD_UNDERGROUND, 15, 18`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 2 | `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` | 7 |
| 2 | 3 | 34 | `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` | 4 |
| 3 | 18 | 6 | `GOLDENROD_UNDERGROUND` | 4 |
| 4 | 21 | 31 | `GOLDENROD_UNDERGROUND` | 3 |
| 5 | 22 | 31 | `GOLDENROD_UNDERGROUND` | 3 |
| 6 | 22 | 27 | `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` | 1 |

Warps 3/4/5 are a same-map pair: the Basement Key door at (18,6) drops you at
(21,31), and (22,27) is the stairs into the switch room proper.

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 18 | 6 | `BGEVENT_READ` | `BasementDoorScript` |
| 19 | 6 | `BGEVENT_READ` | `GoldenrodUndergroundNoEntrySign` |
| 6 | 13 | `BGEVENT_ITEM` | `hiddenitem PARLYZ_HEAL, EVENT_GOLDENROD_UNDERGROUND_HIDDEN_PARLYZ_HEAL` |
| 4 | 18 | `BGEVENT_ITEM` | `hiddenitem SUPER_POTION, EVENT_GOLDENROD_UNDERGROUND_HIDDEN_SUPER_POTION` |
| 17 | 8 | `BGEVENT_ITEM` | `hiddenitem ANTIDOTE, EVENT_GOLDENROD_UNDERGROUND_HIDDEN_ANTIDOTE` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `GOLDENRODUNDERGROUND_SUPER_NERD1` | `SPRITE_SUPER_NERD` | 5 | 31 | `STANDING_LEFT` | `TRAINER` (sight 3) | `TrainerSupernerdEric` | -1 |
| `GOLDENRODUNDERGROUND_SUPER_NERD2` | `SPRITE_SUPER_NERD` | 6 | 9 | `STANDING_UP` | `TRAINER` (sight 2) | `TrainerSupernerdTeru` | -1 |
| `GOLDENRODUNDERGROUND_SUPER_NERD3` | `SPRITE_SUPER_NERD` | 3 | 27 | `SPINRANDOM_FAST` | `TRAINER` (sight 2) | `TrainerPokemaniacIssac` | -1 |
| `GOLDENRODUNDERGROUND_SUPER_NERD4` | `SPRITE_SUPER_NERD` | 2 | 6 | `STANDING_RIGHT` | `TRAINER` (sight 3) | `TrainerPokemaniacDonald` | -1 |
| `GOLDENRODUNDERGROUND_POKE_BALL` | `SPRITE_POKE_BALL` | 7 | 25 | `STILL` | `ITEMBALL` | `itemball COIN_CASE` | `EVENT_GOLDENROD_UNDERGROUND_COIN_CASE` |
| `GOLDENRODUNDERGROUND_GRAMPS` | `SPRITE_GRAMPS` | 7 | 11 | `STANDING_LEFT` | `SCRIPT` | `BargainMerchantScript` | `EVENT_GOLDENROD_UNDERGROUND_GRAMPS` |
| `GOLDENRODUNDERGROUND_OLDER_HAIRCUT_BROTHER` | `SPRITE_SUPER_NERD` | 7 | 14 | `STANDING_LEFT` | `SCRIPT` | `OlderHaircutBrotherScript` | `EVENT_GOLDENROD_UNDERGROUND_OLDER_HAIRCUT_BROTHER` |
| `GOLDENRODUNDERGROUND_YOUNGER_HAIRCUT_BROTHER` | `SPRITE_SUPER_NERD` | 7 | 15 | `STANDING_LEFT` | `SCRIPT` | `YoungerHaircutBrotherScript` | `EVENT_GOLDENROD_UNDERGROUND_YOUNGER_HAIRCUT_BROTHER` |
| `GOLDENRODUNDERGROUND_GRANNY` | `SPRITE_GRANNY` | 7 | 21 | `STANDING_LEFT` | `SCRIPT` | `BitterMerchantScript` | `EVENT_GOLDENROD_UNDERGROUND_GRANNY` |

**Scripts of interest**

- `BasementDoorScript` (`46:429e`, exported `::`) - `checkevent
  EVENT_USED_BASEMENT_KEY` (already open -> "The door is open"), else `checkitem
  BASEMENT_KEY`; with the key: `playsound SFX_TRANSACTION`, `changeblock 18, 6,
  $2e` (unlocked door), `refreshmap`, `setevent EVENT_USED_BASEMENT_KEY`. Without
  it: "The door's locked..."
- `GoldenrodUndergroundCheckBasementKeyCallback` (`MAPCALLBACK_TILES`) re-locks
  the block on every map load until `EVENT_USED_BASEMENT_KEY` is set:
  `changeblock 18, 6, $3d`.
- `GoldenrodUndergroundResetSwitchesCallback` (`MAPCALLBACK_NEWMAP`) - clears
  `EVENT_SWITCH_1..3`, `EVENT_EMERGENCY_SWITCH`, `EVENT_DOOR_1_OPEN ..
  EVENT_DOOR_11_OPEN`, and `setval 0` / `writemem wUndergroundSwitchPositions`
  (`01:d6a8`). This is the "exit to the stairs then come back up so the switches
  are reset" step the walkthrough relies on. The warehouse map has an identical
  callback (`GoldenrodUndergroundWarehouseResetSwitchesCallback`).
- `OlderHaircutBrotherScript` / `YoungerHaircutBrotherScript` - the "Pokemon
  Salon" happiness boost. Day-gated by
  `GoldenrodUndergroundCheckDayOfWeekCallback` (`MAPCALLBACK_OBJECTS`): older
  brother TUE/THU/SAT (500), younger brother SUN/WED/FRI (300). Once per day via
  `ENGINE_GOLDENROD_UNDERGROUND_GOT_HAIRCUT`.

---

### MAP_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES

- Script: `maps/GoldenrodUndergroundSwitchRoomEntrances.asm`
- Blocks: `maps/GoldenrodUndergroundSwitchRoomEntrances.blk`
- Header: `data/maps/maps.asm:124` -> `TILESET_ELITE_FOUR_ROOM`, `DUNGEON`,
  `LANDMARK_GOLDENROD_CITY`, `MUSIC_UNION_CAVE`, phone `TRUE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:111` -> `map_const GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES, 15, 18`

Scene ids from this map's own block:
`SCENE_GOLDENRODUNDERGROUNDSWITCHROOMENTRANCES_RIVAL_BATTLE` = 0,
`..._NOOP` = 1.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 23 | 3 | `GOLDENROD_UNDERGROUND` | 6 |
| 2 | 22 | 10 | `GOLDENROD_UNDERGROUND_WAREHOUSE` | 1 |
| 3 | 23 | 10 | `GOLDENROD_UNDERGROUND_WAREHOUSE` | 2 |
| 4 | 5 | 25 | `GOLDENROD_UNDERGROUND` | 2 |
| 5 | 4 | 29 | `GOLDENROD_CITY` | 15 |
| 6 | 5 | 29 | `GOLDENROD_CITY` | 15 |
| 7 | 21 | 25 | `GOLDENROD_UNDERGROUND` | 1 |
| 8 | 20 | 29 | `GOLDENROD_CITY` | 14 |
| 9 | 21 | 29 | `GOLDENROD_CITY` | 14 |

**Coord events**

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `..._RIVAL_BATTLE` (0) | 19 | 4 | `UndergroundRivalScene1` | rival appears from (23,3), battle |
| `..._RIVAL_BATTLE` (0) | 19 | 5 | `UndergroundRivalScene2` | same, one row lower |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 16 | 1 | `BGEVENT_READ` | `Switch1Script` |
| 10 | 1 | `BGEVENT_READ` | `Switch2Script` |
| 2 | 1 | `BGEVENT_READ` | `Switch3Script` |
| 20 | 11 | `BGEVENT_READ` | `EmergencySwitchScript` |
| 8 | 9 | `BGEVENT_ITEM` | `hiddenitem MAX_POTION, EVENT_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES_HIDDEN_MAX_POTION` |
| 1 | 8 | `BGEVENT_ITEM` | `hiddenitem REVIVE, EVENT_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES_HIDDEN_REVIVE` |

The two hidden items are not mentioned by the walkthrough.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `..._PHARMACIST1` | `SPRITE_PHARMACIST` | 9 | 12 | `STANDING_RIGHT` | `TRAINER` (sight 2) | `TrainerBurglarDuncan` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `..._PHARMACIST2` | `SPRITE_PHARMACIST` | 4 | 8 | `STANDING_LEFT` | `TRAINER` (sight 2) | `TrainerBurglarEddie` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `..._ROCKET1` | `SPRITE_ROCKET` | 17 | 2 | `STANDING_DOWN` | `TRAINER` (sight 3) | `TrainerGruntM13` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `..._ROCKET2` | `SPRITE_ROCKET` | 11 | 2 | `STANDING_DOWN` | `TRAINER` (sight 3) | `TrainerGruntM11` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `..._ROCKET3` | `SPRITE_ROCKET` | 3 | 2 | `STANDING_DOWN` | `TRAINER` (sight 3) | `TrainerGruntM25` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `..._ROCKET_GIRL` | `SPRITE_ROCKET_GIRL` | 19 | 12 | `STANDING_DOWN` | `TRAINER` (sight 1) | `TrainerGruntF3` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `..._TEACHER` | `SPRITE_TEACHER` | 3 | 27 | `STANDING_DOWN` | `SCRIPT` | `GoldenrodUndergroundSwitchRoomEntrancesTeacherScript` | -1 |
| `..._SUPER_NERD` | `SPRITE_SUPER_NERD` | 19 | 27 | `STANDING_DOWN` | `SCRIPT` | `GoldenrodUndergroundSwitchRoomEntrancesSuperNerdScript` | -1 |
| `..._POKE_BALL1` | `SPRITE_POKE_BALL` | 1 | 12 | `STILL` | `ITEMBALL` | `itemball SMOKE_BALL` | `EVENT_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES_SMOKE_BALL` |
| `..._POKE_BALL2` | `SPRITE_POKE_BALL` | 14 | 9 | `STILL` | `ITEMBALL` | `itemball FULL_HEAL` | `EVENT_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES_FULL_HEAL` |
| `..._RIVAL` | `SPRITE_RIVAL` | 23 | 3 | `STANDING_DOWN` | `SCRIPT` | `ObjectEvent` | `EVENT_RIVAL_GOLDENROD_UNDERGROUND` |

**Scripts of interest - the shutter puzzle**

This is the load-bearing part of the section, and the asm behaves differently
from how the walkthrough describes it.

The eleven shutters are declared at the top of the file by the local
`ugdoor_def` macro (coordinates are `changeblock` coordinates, i.e. the same
cell units the script uses):

| door | x, y | closed block | open block | second half (x, y, closed, open) |
|---|---|---|---|---|
| 1 | 16, 6 | `$3e` | `$2d` | - |
| 2 | 10, 6 | `$3e` | `$2d` | - |
| 3 | 2, 6 | `$3e` | `$2d` | - |
| 4 | 2, 10 | `$3e` | `$2d` | - |
| 5 | 10, 10 | `$3e` | `$2d` | - |
| 6 | 16, 10 | `$3e` | `$2d` | - |
| 7 | 12, 6 | `$3f` | `$2a` | 12, 8, `$3d`, `$2d` |
| 8 | 6, 6 | `$3f` | `$2a` | 6, 8, `$3d`, `$2d` |
| 9 | 12, 10 | `$3f` | `$2a` | 12, 12, `$3d`, `$2d` |
| 10 | 6, 10 | `$3f` | `$2a` | 6, 12, `$3d`, `$2d` |
| 11 | 18, 10 | `$3f` | `$2a` | 18, 12, `$3d`, `$2d` |

`Switch1Script` / `Switch2Script` / `Switch3Script` each `readmem
wUndergroundSwitchPositions` (`01:d6a8`), `addval +N` when turning ON or
`addval -N` when turning OFF (N = 1, 2, 3 respectively), `writemem` it back,
set/clear `EVENT_SWITCH_N`, then `sjump
GoldenrodUndergroundSwitchRoomEntrances_UpdateDoors` (`46:4c57`).

`EmergencySwitchScript` at (20,11) is different: ON does `setval 7` (not an
add), sets `EVENT_EMERGENCY_SWITCH` and all three `EVENT_SWITCH_*`; OFF does
`setval 0` and clears all four.

`..._UpdateDoors` dispatches on the stored byte. Crucially each position only
touches SOME doors - the rest keep whatever state the previous position left
them in, which is the entire reason order matters:

| value | opens | closes | untouched |
|---|---|---|---|
| 0 | - | 1..11 | - |
| 1 | 1, 7, 10 | 6, 8, 9, 11 | 2, 3, 4, 5 |
| 2 | 2, 8, 9 | 5, 7, 10, 11 | 1, 3, 4, 6 |
| 3 | 3, 7, 10 | 4, 8, 9, 11 | 1, 2, 5, 6 |
| 4 | 4, 8, 9 | 3, 7, 10, 11 | 1, 2, 5, 6 |
| 5 | 5, 7, 10 | 2, 8, 9, 11 | 1, 3, 4, 6 |
| 6 | 6, 8, 9, 11 | 1, 7, 10 | 2, 3, 4, 5 |
| 7 (emergency) | 3, 5, 6, 8, 9, 11 | 1, 2, 4, 7, 10 | - | 

The emergency arm ends with `setval 6` / `writemem`, so the stored byte becomes
6 afterwards even though the door layout is the emergency one.

Consequences a bot needs (derived by tracing the table, from the reset state
where the stored byte is 0 and all doors closed):

- Flip 1, then 2, then 3 (values 1 -> 3 -> 6). Final open doors: 3, 6, 8, 9, 11.
  Door 8 at (6,6)/(6,8) is what lets you drop south from the switch-3 alcove to
  `TrainerBurglarEddie` at (4,8).
- From there flip 3 off then 2 off (values 6 -> 3 -> 1). Final open doors: 1, 3,
  7, 10. Door 7 at (12,6)/(12,8) is what opens the way to the Full Heal ball at
  (14,9).
- Reset (leave via a warp so the `MAPCALLBACK_NEWMAP` reset runs) and flip 3,
  then 2, then 1 (values 3 -> 5 -> 6). Final open doors: 3, 5, 6, 8, 9, 11 -
  the same set as 1/2/3 PLUS door 5 at (10,10). Door 5 is the one that opens the
  route south to `TrainerBurglarDuncan` (9,12), `TrainerGruntF3` (19,12) and the
  warehouse warps at (22,10)/(23,10).

So the walkthrough's "turn them on in the opposite direction" is correct in
effect, but the mechanism is not "order is remembered": the stored byte is a
plain SUM (1+2+3 = 3+2+1 = 6), and what differs is which doors the intermediate
positions left untouched.

`UndergroundRivalBattleScript` (`46:4a9e`):

```
checkevent EVENT_RIVAL_BURNED_TOWER
iftrue .Continue
setevent EVENT_RIVAL_BURNED_TOWER
setmapscene BURNED_TOWER_1F, SCENE_BURNEDTOWER1F_FIREBREATHER_DICK
.Continue:
playmusic MUSIC_RIVAL_ENCOUNTER
... setevent EVENT_RIVAL_GOLDENROD_UNDERGROUND
checkevent EVENT_GOT_TOTODILE_FROM_ELM -> loadtrainer RIVAL1, RIVAL1_4_CHIKORITA
checkevent EVENT_GOT_CHIKORITA_FROM_ELM -> loadtrainer RIVAL1, RIVAL1_4_CYNDAQUIL
else                                    -> loadtrainer RIVAL1, RIVAL1_4_TOTODILE
```

i.e. the rival's starter is the one with type advantage over yours, as usual.
`winlosstext UndergroundRivalWinText, UndergroundRivalLossText` - this battle is
LOSABLE (a real loss text exists), unlike the Executive fights.

---

### MAP_GOLDENROD_UNDERGROUND_WAREHOUSE

- Script: `maps/GoldenrodUndergroundWarehouse.asm`
- Blocks: `maps/GoldenrodUndergroundWarehouse.blk`
- Header: `data/maps/maps.asm:126` -> `TILESET_UNDERGROUND`, `DUNGEON`,
  `LANDMARK_GOLDENROD_CITY`, `MUSIC_UNION_CAVE`, phone `TRUE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:113` -> `map_const GOLDENROD_UNDERGROUND_WAREHOUSE, 10, 9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 12 | `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` | 2 |
| 2 | 3 | 12 | `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` | 3 |
| 3 | 17 | 2 | `GOLDENROD_DEPT_STORE_B1F` | 1 |

**Coord events** - none.
**BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `..._ROCKET1` | `SPRITE_ROCKET` | 9 | 8 | `STANDING_UP` | `TRAINER` (sight 3) | `TrainerGruntM24` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `..._ROCKET2` | `SPRITE_ROCKET` | 8 | 15 | `STANDING_UP` | `TRAINER` (sight 3) | `TrainerGruntM14` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `..._ROCKET3` | `SPRITE_ROCKET` | 14 | 3 | `STANDING_RIGHT` | `TRAINER` (sight 4) | `TrainerGruntM15` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `..._GENTLEMAN` | `SPRITE_GENTLEMAN` | 12 | 8 | `SPINRANDOM_SLOW` | `SCRIPT` | `GoldenrodUndergroundWarehouseDirectorScript` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `..._POKE_BALL1` | `SPRITE_POKE_BALL` | 18 | 15 | `STILL` | `ITEMBALL` | `itemball MAX_ETHER` | `EVENT_GOLDENROD_UNDERGROUND_WAREHOUSE_MAX_ETHER` |
| `..._POKE_BALL2` | `SPRITE_POKE_BALL` | 13 | 9 | `STILL` | `ITEMBALL` | `itemball TM_SLEEP_TALK` | `EVENT_GOLDENROD_UNDERGROUND_WAREHOUSE_TM_SLEEP_TALK` |

Note the Director object is masked by `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` the
same way the Grunts are: once the tower is cleared he is gone from here.

**Scripts of interest**

- `GoldenrodUndergroundWarehouseDirectorScript` (`46:598a`) - `checkevent
  EVENT_RECEIVED_CARD_KEY`; if not: `DirectorIntroText`, `verbosegiveitem
  CARD_KEY`, `setevent EVENT_RECEIVED_CARD_KEY`, `setevent
  EVENT_GOLDENROD_DEPT_STORE_B1F_LAYOUT_1`, `clearevent ..._LAYOUT_2`,
  `clearevent ..._LAYOUT_3`, `DirectorCardKeyText` ("Use that to open the
  shutters on 3F"), then `DirectorAfterText`. The `verbosegiveitem` result is
  again unchecked.

---

### MAP_GOLDENROD_DEPT_STORE_B1F

- Script: `maps/GoldenrodDeptStoreB1F.asm`
- Blocks: `maps/GoldenrodDeptStoreB1F.blk`
- Header: `data/maps/maps.asm:125` -> `TILESET_UNDERGROUND`, `DUNGEON`,
  `LANDMARK_GOLDENROD_CITY`, `MUSIC_GOLDENROD_CITY`, phone `TRUE`,
  `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:112` -> `map_const GOLDENROD_DEPT_STORE_B1F, 10, 9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 17 | 2 | `GOLDENROD_UNDERGROUND_WAREHOUSE` | 3 |
| 2 | 9 | 4 | `GOLDENROD_DEPT_STORE_ELEVATOR` | 1 |
| 3 | 10 | 4 | `GOLDENROD_DEPT_STORE_ELEVATOR` | 2 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `..._POKE_BALL1` | `SPRITE_POKE_BALL` | 10 | 15 | `STILL` | `ITEMBALL` | `itemball ETHER` | `EVENT_GOLDENROD_DEPT_STORE_B1F_ETHER` |
| `..._POKE_BALL2` | `SPRITE_POKE_BALL` | 14 | 2 | `STILL` | `ITEMBALL` | `itemball AMULET_COIN` | `EVENT_GOLDENROD_DEPT_STORE_B1F_AMULET_COIN` |
| `..._POKE_BALL3` | `SPRITE_POKE_BALL` | 6 | 3 | `STILL` | `ITEMBALL` | `itemball BURN_HEAL` | `EVENT_GOLDENROD_DEPT_STORE_B1F_BURN_HEAL` |
| `..._POKE_BALL4` | `SPRITE_POKE_BALL` | 15 | 15 | `STILL` | `ITEMBALL` | `itemball ULTRA_BALL` | `EVENT_GOLDENROD_DEPT_STORE_B1F_ULTRA_BALL` |
| `..._BLACK_BELT1` | `SPRITE_BLACK_BELT` | 9 | 10 | `WALK_UP_DOWN` | `SCRIPT` | `GoldenrodDeptStoreB1FBlackBelt1Script` | -1 |
| `..._BLACK_BELT2` | `SPRITE_BLACK_BELT` | 4 | 8 | `SPINRANDOM_SLOW` | `SCRIPT` | `GoldenrodDeptStoreB1FBlackBelt2Script` | -1 |
| `..._BLACK_BELT3` | `SPRITE_BLACK_BELT` | 6 | 13 | `WALK_LEFT_RIGHT` | `SCRIPT` | `GoldenrodDeptStoreB1FBlackBelt3Script` | -1 |
| `..._MACHOP` | `SPRITE_MACHOP` | 7 | 7 | `POKEMON` | `SCRIPT` | `GoldenrodDeptStoreB1FMachopScript` | -1 |

**Scripts of interest**

- `GoldenRodDeptStoreB1FClearBoxesCallback` (`MAPCALLBACK_TILES`) - `checkevent
  EVENT_RECEIVED_CARD_KEY` -> `changeblock 16, 4, $0d` (floor). Then the crate
  layout: `EVENT_GOLDENROD_DEPT_STORE_B1F_LAYOUT_2` -> `changeblock 4, 10, $0d`;
  `..._LAYOUT_3` -> `changeblock 10, 12, $0d`; default (LAYOUT_1) ->
  `changeblock 10, 8, $0d`.
- `GoldenRodDeptStoreUnblockCallback` (`MAPCALLBACK_NEWMAP`) - `clearevent
  EVENT_GOLDENROD_UNDERGROUND_WAREHOUSE_BLOCKED_OFF`. That event starts SET
  (`InitializeEventsScript`, `engine/events/std_scripts.asm:518`) and is what
  `GoldenrodDeptStoreElevatorScript` (`maps/GoldenrodDeptStoreElevator.asm:15`)
  checks before rotating the crate layout - so the layout only ever changes
  once you have entered B1F on foot from the warehouse.

**Flags and events (whole section)**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_ROCKETS_IN_RADIO_TOWER` | `constants/engine_flags.asm:28` | set by `RadioTowerRocketsScript`; cleared by `RadioTower5FRocketBossScript`; read by `RadioTower1FReceptionistScript`, `RadioTower2FTeacherScript`, `MahoganyRedGyaradosSpeechHouse`, `engine/phone/scripts/trainers.asm` | "the takeover arc is live"; also switches the radio programming |
| `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` | `constants/event_flags.asm:1136` | CLEARED by `RadioTowerRocketsScript`, SET again by `RadioTower5FRocketBossScript` | object mask for every Rocket trainer in this section; SET = hidden |
| `EVENT_GOLDENROD_CITY_ROCKET_TAKEOVER` | `:1135` | cleared by `GoldenrodRocketsScript` (6 badges), set by `RadioTower5FRocketBossScript` | the two earliest city Rockets |
| `EVENT_GOLDENROD_CITY_ROCKET_SCOUT` | `:1134` | set by `RadioTower5FRocketBossScript` | hides the scout at (4,16) once cleared |
| `EVENT_GOLDENROD_CITY_CIVILIANS` | `:1137` | set by `RadioTowerRocketsScript`, cleared by `RadioTower5FRocketBossScript` | SET hides the city + 1F/2F civilians for the whole section |
| `EVENT_RADIO_TOWER_CIVILIANS_AFTER` | `:1138` | set at `InitializeEventsScript`, cleared by `RadioTower5FRocketBossScript` | the "after" NPCs (Ben, 3F super nerd, 4F fisher, 2F black belt 2) |
| `EVENT_RADIO_TOWER_BLACKBELT_BLOCKS_STAIRS` | `:1139` | set by `RadioTowerRocketsScript` | SET removes the 2F stairs blocker, i.e. the takeover is what opens 3F |
| `EVENT_USED_THE_CARD_KEY_IN_THE_RADIO_TOWER` | `:46` | cleared by `RadioTowerRocketsScript`, set by `CardKeySlotScript`, read by `RadioTower3FCardKeyShutterCallback` and `RadioTower3FCooltrainerFScript` | the 3F shutter |
| `EVENT_CLEARED_RADIO_TOWER` | `:42` | set by `RadioTower5FRocketBossScript` | section-complete flag; gates the TM Sunny Day / Pink Bow rewards |
| `EVENT_USED_BASEMENT_KEY` | `:82` | set by `BasementDoorScript`, read by `GoldenrodUndergroundCheckBasementKeyCallback` | the Underground locked door |
| `EVENT_RECEIVED_CARD_KEY` | `:83` | set by `GoldenrodUndergroundWarehouseDirectorScript`, read by `GoldenRodDeptStoreB1FClearBoxesCallback` | one-shot on the Card Key |
| `EVENT_SWITCH_1/2/3`, `EVENT_EMERGENCY_SWITCH` | `:386-389` | the four switch scripts; cleared by both reset callbacks | which switch is lit |
| `EVENT_DOOR_1_OPEN .. EVENT_DOOR_11_OPEN` | `:390-400` | `..._UpdateDoors` `.OpenDoorN` / `.CloseDoorN`; replayed by `..._UpdateDoorPositionsCallback` (`MAPCALLBACK_TILES`) | per-shutter persistent state |
| `EVENT_RIVAL_GOLDENROD_UNDERGROUND` | `:1123` | set inside `UndergroundRivalBattleScript` | masks the rival object afterwards |
| `EVENT_RIVAL_BURNED_TOWER` | grep `constants/event_flags.asm` | set by `UndergroundRivalBattleScript` if not already | side effect: sets `BURNED_TOWER_1F` scene to `SCENE_BURNEDTOWER1F_FIREBREATHER_DICK` |
| `EVENT_GOLDENROD_DEPT_STORE_B1F_LAYOUT_1/2/3` | `:435-437` | director script, `GoldenrodDeptStoreElevatorScript` | which crate row is open on B1F |
| `EVENT_GOLDENROD_UNDERGROUND_WAREHOUSE_BLOCKED_OFF` | `:438` | set by `InitializeEventsScript`, cleared by `GoldenRodDeptStoreUnblockCallback` | freezes the crate rotation until you have walked B1F |
| `EVENT_TEAM_ROCKET_DISBANDED` | `:1283` | set by `RadioTower5FRocketBossScript` **only on the Gold branch**; also set in `maps/PewterCity.asm:51` | masks the `TIN_TOWER_1F` sage at (10,2) |
| `EVENT_GOT_RAINBOW_WING` / `EVENT_GOT_SILVER_WING` | `:129-130` | `RadioTower5FRocketBossScript` `checkver` arms | Gold vs Silver reward |
| `SCENE_RADIOTOWER5F_FAKE_DIRECTOR` = 0, `_ROCKET_BOSS` = 1, `_NOOP` = 2 | `maps/RadioTower5F.asm:9-11` | `setscene` in both coord scripts | which 5F cutscene is armed |
| `SCENE_GOLDENRODUNDERGROUNDSWITCHROOMENTRANCES_RIVAL_BATTLE` = 0, `_NOOP` = 1 | `maps/GoldenrodUndergroundSwitchRoomEntrances.asm:57-58` | `setscene` at the end of both rival scenes | one-shot rival trip-wire |
| `SPECIALCALL_WEIRDBROADCAST` = 4 | `constants/phone_constants.asm:48` | queued by `RadioTowerRocketsScript`; row 4 of `data/phone/special_calls.asm` is `SpecialCallOnlyWhenOutside, PHONECONTACT_ELM, ElmPhoneCallerScript`; consumed at `engine/phone/scripts/elm.asm:68` `.rocket` | Elm's call the walkthrough opens with. Only rings OUTDOORS. |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `BASEMENT_KEY` | `verbosegiveitem` after `EXECUTIVEM_3` | `FakeDirectorScript`, `maps/RadioTower5F.asm` | `EVENT_BEAT_ROCKET_EXECUTIVEM_3` (scene also advances) |
| `SMOKE_BALL` | ground ball at (1,12) | `GoldenrodUndergroundSwitchRoomEntrancesSmokeBall` | `EVENT_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES_SMOKE_BALL` |
| `FULL_HEAL` | ground ball at (14,9) | `GoldenrodUndergroundSwitchRoomEntrancesFullHeal` | `EVENT_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES_FULL_HEAL` |
| `MAX_POTION` | hidden at (8,9) | `bg_event 8, 9, BGEVENT_ITEM` | `EVENT_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES_HIDDEN_MAX_POTION` |
| `REVIVE` | hidden at (1,8) | `bg_event 1, 8, BGEVENT_ITEM` | `EVENT_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES_HIDDEN_REVIVE` |
| `MAX_ETHER` | ground ball at (18,15) | `GoldenrodUndergroundWarehouseMaxEther` | `EVENT_GOLDENROD_UNDERGROUND_WAREHOUSE_MAX_ETHER` |
| `TM_SLEEP_TALK` (TM35) | ground ball at (13,9) | `GoldenrodUndergroundWarehouseTMSleepTalk` | `EVENT_GOLDENROD_UNDERGROUND_WAREHOUSE_TM_SLEEP_TALK` |
| `CARD_KEY` | talk to Director at (12,8) | `GoldenrodUndergroundWarehouseDirectorScript` | `EVENT_RECEIVED_CARD_KEY` |
| `AMULET_COIN` | ground ball at (14,2) on B1F | `GoldenrodDeptStoreB1FAmuletCoin` | `EVENT_GOLDENROD_DEPT_STORE_B1F_AMULET_COIN` |
| `RAINBOW_WING` (Gold) / `SILVER_WING` (Silver) | director cutscene | `RadioTower5FRocketBossScript` `checkver` | `EVENT_GOT_RAINBOW_WING` / `EVENT_GOT_SILVER_WING` |
| `TM_SUNNY_DAY` (TM11) | talk 3F cooltrainer_f (11,3) after clearing | `RadioTower3FCooltrainerFScript` | `EVENT_GOT_SUNNY_DAY_FROM_RADIO_TOWER` |
| `PINK_BOW` | talk DJ Mary (14,6) after clearing | `RadioTower4FDJMaryScript` | `EVENT_GOT_PINK_BOW_FROM_MARY` |

TM numbering checked against `constants/item_constants.asm:219` (`TM01` =
`DYNAMICPUNCH`): `SUNNY_DAY` is TM11 and `SLEEP_TALK` is TM35.

**Trainers**

All parties from `data/trainers/parties.asm`; class group labels named in the
"party" column. Constants from `constants/trainer_constants.asm`.

| const | class | id | party (`data/trainers/parties.asm`) | script label | map |
|---|---|---|---|---|---|
| `GRUNTM_3` | `GRUNTM` | 3 | `GruntMGroup` "; GRUNTM (3)": 24 `RATICATE`, 24 `RATICATE` | `TrainerGruntM3` | `RADIO_TOWER_1F` (14,1) |
| `GRUNTF_2` | `GRUNTF` | 2 | `GruntFGroup` (2): 26 `ARBOK` | `TrainerGruntF2` | `RADIO_TOWER_2F` (10,5) |
| `GRUNTM_5` | `GRUNTM` | 5 | (5): 21 `RATTATA`, 21 `RATTATA`, 23 `RATTATA`, 23 `RATTATA`, 23 `RATTATA` | `TrainerGruntM5` | `RADIO_TOWER_2F` (8,4) |
| `GRUNTM_6` | `GRUNTM` | 6 | (6): 26 `ZUBAT`, 26 `ZUBAT` | `TrainerGruntM6` | `RADIO_TOWER_2F` (4,1) |
| `GRUNTM_4` | `GRUNTM` | 4 | (4): 23 `GRIMER`, 23 `GRIMER`, 25 `MUK` | `TrainerGruntM4` | `RADIO_TOWER_2F` (1,4) |
| `GRUNTM_8` | `GRUNTM` | 8 | (8): 26 `WEEZING` | `TrainerGruntM8` | `RADIO_TOWER_3F` (6,2) |
| `GRUNTM_7` | `GRUNTM` | 7 | (7): 23 `KOFFING`, 23 `GRIMER`, 23 `ZUBAT`, 23 `RATTATA` | `TrainerGruntM7` | `RADIO_TOWER_3F` (5,1) |
| `MARC` | `SCIENTIST` | 4 | `ScientistGroup` (4) "MARC": 27 `MAGNEMITE` x3 | `TrainerScientistMarc` | `RADIO_TOWER_3F` (9,6) |
| `GRUNTM_10` | `GRUNTM` | 10 | (10): 22 `ZUBAT`, 24 `GOLBAT`, 22 `GRIMER` | `TrainerGruntM10` | `RADIO_TOWER_4F` (5,6) |
| `RICH` | `SCIENTIST` | 5 | `ScientistGroup` (5) "RICH", `TRAINERTYPE_MOVES`: 30 `PORYGON` (Conversion, Conversion2, Recover, Tri Attack) | `TrainerScientistRich` | `RADIO_TOWER_4F` (4,2) |
| `EXECUTIVEM_3` | `EXECUTIVEM` | 3 | `ExecutiveMGroup` (3), `TRAINERTYPE_MOVES`: 30 `KOFFING` x3 (Tackle/Selfdestruct/Sludge/Smokescreen), 32 `WEEZING` (Tackle/Explosion/Sludge/Smokescreen), 30 `KOFFING`, 30 `KOFFING` (Tackle/Smog/Sludge/Smokescreen) | `FakeDirectorScript` (`loadtrainer`) | `RADIO_TOWER_5F` coord (0,3) |
| `RIVAL1_4_CHIKORITA` | `RIVAL1` | 10 | `Rival1Group` (10): 30 `GOLBAT`, 28 `MAGNEMITE`, 30 `HAUNTER`, 32 `SNEASEL`, 32 `MEGANIUM` | `UndergroundRivalBattleScript` | switch room coord (19,4)/(19,5) |
| `RIVAL1_4_CYNDAQUIL` | `RIVAL1` | 11 | (11): same first four, 32 `QUILAVA` | as above | as above |
| `RIVAL1_4_TOTODILE` | `RIVAL1` | 12 | (12): same first four, 32 `FERALIGATR` | as above | as above |
| `GRUNTM_13` | `GRUNTM` | 13 | (13): 27 `RATTATA` | `TrainerGruntM13` | switch room (17,2) |
| `GRUNTM_11` | `GRUNTM` | 11 | (11): 23 `MUK`, 23 `KOFFING`, 25 `RATTATA` | `TrainerGruntM11` | switch room (11,2) |
| `GRUNTM_25` | `GRUNTM` | 25 | (25): 24 `KOFFING`, 24 `MUK` | `TrainerGruntM25` | switch room (3,2) |
| `EDDIE` | `BURGLAR` | 2 | `BurglarGroup` (2) "EDDIE", `TRAINERTYPE_MOVES`: 26 `GROWLITHE` (Roar/Ember/Leer/Take Down), 24 `KOFFING` (Tackle/Smog/Sludge/Smokescreen) | `TrainerBurglarEddie` | switch room (4,8) |
| `DUNCAN` | `BURGLAR` | 1 | `BurglarGroup` (1) "DUNCAN": 23 `KOFFING`, 25 `MAGMAR`, 23 `KOFFING` | `TrainerBurglarDuncan` | switch room (9,12) |
| `GRUNTF_3` | `GRUNTF` | 3 | (3): 25 `GLOOM`, 25 `GLOOM` | `TrainerGruntF3` | switch room (19,12) |
| `GRUNTM_14` | `GRUNTM` | 14 | (14): 24 `RATICATE`, 24 `GOLBAT` | `TrainerGruntM14` | warehouse (8,15) |
| `GRUNTM_15` | `GRUNTM` | 15 | (15): 26 `GRIMER`, 23 `WEEZING` | `TrainerGruntM15` | warehouse (14,3) |
| `GRUNTM_24` | `GRUNTM` | 24 | (24): 25 `KOFFING`, 25 `KOFFING` | `TrainerGruntM24` | warehouse (9,8) |
| `GRUNTM_9` | `GRUNTM` | 9 | (9): 24 `RATICATE`, 26 `KOFFING` | `TrainerGruntM9` | `RADIO_TOWER_3F` (16,6), behind the shutter |
| `GRUNTF_4` | `GRUNTF` | 4 | (4): 21 `EKANS`, 23 `ODDISH`, 21 `EKANS`, 24 `GLOOM` | `TrainerGruntF4` | `RADIO_TOWER_4F` (12,4) |
| `EXECUTIVEM_2` | `EXECUTIVEM` | 2 | `ExecutiveMGroup` (2), `TRAINERTYPE_MOVES`: 36 `GOLBAT` (Leech Life/Bite/Confuse Ray/Wing Attack) | `TrainerExecutivem2` | `RADIO_TOWER_4F` (14,1) |
| `EXECUTIVEF_1` | `EXECUTIVEF` | 1 | `ExecutiveFGroup` (1), `TRAINERTYPE_MOVES`: 32 `ARBOK` (Wrap/Poison Sting/Bite/Glare), 32 `VILEPLUME` (Absorb/Sweet Scent/Sleep Powder/Acid), 32 `MURKROW` (Peck/Pursuit/Haze/Night Shade) | `TrainerExecutivef1` | `RADIO_TOWER_5F` (17,2) |
| `EXECUTIVEM_1` | `EXECUTIVEM` | 1 | `ExecutiveMGroup` (1), `TRAINERTYPE_MOVES`: 33 `HOUNDOUR` (Ember/Roar/Bite/Faint Attack), 33 `KOFFING` (Tackle/Sludge/Smokescreen/Haze), 35 `HOUNDOOM` (Ember/Smog/Bite/Faint Attack) | `RadioTower5FRocketBossScript` (`loadtrainer`) | `RADIO_TOWER_5F` coord (16,5) |

Also present but optional in this stretch (`MAP_GOLDENROD_UNDERGROUND`, all
`event flag -1` so always visible): `TrainerSupernerdEric` (`SUPER_NERD`,
`ERIC`), `TrainerSupernerdTeru` (`SUPER_NERD`, `TERU`),
`TrainerPokemaniacIssac`, `TrainerPokemaniacDonald`.

Neither Executive fight nor the fake director fight has a loss text
(`winlosstext ..., 0`), so a whiteout there is a normal blackout, not a scripted
loss. The rival fight DOES have one (`UndergroundRivalLossText`).

**Wild encounters**

None. Grepping `data/wild/johto_grass.asm`, `johto_water.asm`, `fish.asm` and
`treemons.asm` for `RADIO_TOWER` or `GOLDENROD` returns nothing: every map in
this section is `INDOOR` or `DUNGEON` with no wild table.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| The whole arc does not exist yet | `maps/*Gym.asm` `<Gym>ActivateRockets` -> `engine/events/std_scripts.asm:255 RadioTowerRocketsScript` (`40:41dc`) | `readvar VAR_BADGES` equals 7 immediately after a badge is set | Earn the 7th badge (normally Pryce's Glacierbadge). That script sets `ENGINE_ROCKETS_IN_RADIO_TOWER`, clears `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` (spawns every Grunt) and queues `SPECIALCALL_WEIRDBROADCAST`. `ifequal 6` instead runs `GoldenrodRocketsScript`, which only clears `EVENT_GOLDENROD_CITY_ROCKET_TAKEOVER`. |
| Elm's call never rings | `data/phone/special_calls.asm` row 4 = `SpecialCallOnlyWhenOutside` | Player must be on an outdoor map | Walk outside; the call is cosmetic, not a gate on anything |
| 2F -> 3F stairs (pre-takeover only) | `maps/RadioTower2F.asm` object `RADIOTOWER2F_BLACK_BELT1` at (0,1), masked by `EVENT_RADIO_TOWER_BLACKBELT_BLOCKS_STAIRS` | Flag must be SET for him to vanish (`CheckObjectFlag`, `engine/overworld/map_objects_2.asm`) | `RadioTowerRocketsScript` sets it |
| 3F -> 4F east stairs (warp 3 at (17,0)) and `TrainerGruntM9` | `maps/RadioTower3F.asm:127 CardKeySlotScript` (`43:5c91`) + `RadioTower3FCardKeyShutterCallback` (`43:5be1`) | `checkitem CARD_KEY`, and you must press A **facing up** on the tile below (14,2) because the bg event is `BGEVENT_UP` | `EVENT_USED_THE_CARD_KEY_IN_THE_RADIO_TOWER`, which rewrites blocks (14,2) and (14,4) |
| 5F Rocket boss unreachable on the first visit | `maps/RadioTower5F.asm` scene: `setscene SCENE_RADIOTOWER5F_ROCKET_BOSS` only at the end of `FakeDirectorScript` | Beat `EXECUTIVEM_3` | The (16,5) coord event only fires on scene 1 |
| Underground locked door at (18,6) | `maps/GoldenrodUnderground.asm:372 BasementDoorScript` (`46:429e`) + `GoldenrodUndergroundCheckBasementKeyCallback` | `checkitem BASEMENT_KEY` | `EVENT_USED_BASEMENT_KEY`; `changeblock 18, 6, $2e` |
| The eleven shutters in the switch room | `maps/GoldenrodUndergroundSwitchRoomEntrances.asm:346 ..._UpdateDoors` (`46:4c57`), driven by `wUndergroundSwitchPositions` (`01:d6a8`) | No item. A pure state puzzle over a single byte | See the position table in section 2. Resets to 0 on any `MAPCALLBACK_NEWMAP` of `GOLDENROD_UNDERGROUND` or `GOLDENROD_UNDERGROUND_WAREHOUSE`; the emergency switch at (20,11) forces the "everything useful open" layout |
| Rival ambush | `coord_event 19, 4 / 19, 5` on scene 0 | Walking onto either cell | Scene set to `..._NOOP` at the end of `UndergroundRivalScene1/2` |
| Dept store B1F crate layout | `GoldenRodDeptStoreB1FClearBoxesCallback` | `EVENT_RECEIVED_CARD_KEY` opens block (16,4); layout events pick one of three crate gaps | Card Key from the Director; the elevator only rotates the layout once `EVENT_GOLDENROD_UNDERGROUND_WAREHOUSE_BLOCKED_OFF` is cleared by walking into B1F |

No HM field move is required anywhere in this section - no Cut, Surf, Strength,
Whirlpool, Waterfall or Flash check appears in any of these maps.

---

## 4. Bot checklist

Coordinates are asm cell coordinates. "talk" means face the target and press A.

Pass 1 - Radio Tower up to the Basement Key:

1. `MAP_GOLDENROD_CITY`: precondition `ENGINE_ROCKETS_IN_RADIO_TOWER` set (7
   badges). Walk to (5,15), warp 12 -> `RADIO_TOWER_1F` (2,7).
2. `RADIO_TOWER_1F`: walk toward (15,0). `TrainerGruntM3` at (14,1) sights you
   (range 3, facing down). Battle `GRUNTM_3`. Post: `EVENT_BEAT_ROCKET_GRUNTM_3`.
3. Warp 3 at (15,0) -> `RADIO_TOWER_2F` (15,0).
4. `RADIO_TOWER_2F`: walk left. Fight in this order: `TrainerGruntF2` (10,5),
   `TrainerGruntM5` (8,4), `TrainerGruntM6` (4,1), `TrainerGruntM4` (1,4).
   Precondition for all: `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` clear.
5. Warp 1 at (0,0) -> `RADIO_TOWER_3F` (0,0).
6. `RADIO_TOWER_3F`: `TrainerGruntM8` (6,2), `TrainerGruntM7` (5,1),
   `TrainerScientistMarc` (9,6, sight 5). Do NOT try (14,2) yet - no Card Key.
7. Warp 2 at (7,0) -> `RADIO_TOWER_4F` (9,0).
8. `RADIO_TOWER_4F`: `TrainerGruntM10` (5,6), `TrainerScientistRich` (4,2).
9. Warp 1 at (0,0) -> `RADIO_TOWER_5F` (0,0). Walk DOWN to (0,3): coord event
   fires `FakeDirectorScript` on scene 0. Battle `EXECUTIVEM_3` (6 mons, four of
   them know Selfdestruct/Explosion). Post: `BASEMENT_KEY` in bag,
   `EVENT_BEAT_ROCKET_EXECUTIVEM_3`, 5F scene = 1.
10. Retrace: 5F warp 1 -> 4F warp 1 -> 4F warp 2 (9,0) -> 3F warp 2 -> 3F warp 1
    (0,0) -> 2F warp 1 -> 2F warp 2 (15,0) -> 1F warp 3 -> 1F warps 1/2 (2,7) ->
    `GOLDENROD_CITY` (5,15).

Pass 2 - Underground to the Card Key:

11. `GOLDENROD_CITY`: heal at warp 7 (15,27) if wanted. Walk to (9,5), warp 14 ->
    `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` (20,29).
12. Walk to (21,25), warp 7 -> `GOLDENROD_UNDERGROUND` (3,2).
13. Optional: haircut brothers at (7,14)/(7,15) (day-gated); Coin Case ball at
    (7,25) if not taken.
14. Walk to the tile below/beside (18,6) and A-press it: `BasementDoorScript`
    with `BASEMENT_KEY` -> `EVENT_USED_BASEMENT_KEY`. Then step onto (18,6) ->
    warp 3 -> `GOLDENROD_UNDERGROUND` (21,31).
15. Walk to (22,27), warp 6 -> `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES`
    (23,3). SAVE HERE (the walkthrough's advice; the rival battle is losable).
16. Walk west to (19,4) or (19,5): `UndergroundRivalScene1/2` fires on scene 0.
    Battle `RIVAL1`, member `RIVAL1_4_CHIKORITA` / `_CYNDAQUIL` / `_TOTODILE`
    picked by which starter you took. Post: `EVENT_RIVAL_GOLDENROD_UNDERGROUND`,
    scene -> 1. (Side effect: `EVENT_RIVAL_BURNED_TOWER` + Burned Tower scene.)
17. Fight `TrainerGruntM13` (17,2), `TrainerGruntM11` (11,2), `TrainerGruntM25`
    (3,2) - west along the top corridor.
18. Switch byte starts at 0. A-press `Switch1Script` at (16,1) -> ON (byte 1),
    then `Switch2Script` at (10,1) -> ON (byte 3), then `Switch3Script` at (2,1)
    -> ON (byte 6). Doors 3, 6, 8, 9, 11 now open.
19. Go south through door 8 at (6,6)/(6,8) to `TrainerBurglarEddie` at (4,8).
    Battle `BURGLAR EDDIE`.
20. A-press Switch3 (2,1) -> OFF (byte 3), then Switch2 (10,1) -> OFF (byte 1).
    Doors 1, 3, 7, 10 open. Take the `FULL_HEAL` ball at (14,9).
21. Leave and re-enter the map so `..._ResetSwitchesCallback` zeroes everything
    (e.g. warp 1 at (23,3) into `GOLDENROD_UNDERGROUND` and back through (22,27)).
22. Now A-press Switch3 (2,1) ON (byte 3), Switch2 (10,1) ON (byte 5), Switch1
    (16,1) ON (byte 6). Doors 3, 5, 6, 8, 9, 11 open - door 5 at (10,10) is the
    new one.
23. Go south through door 5 to `TrainerBurglarDuncan` (9,12), then east to
    `TrainerGruntF3` (19,12). Optionally the `SMOKE_BALL` ball at (1,12) and the
    two hidden items at (8,9) and (1,8).
24. Warps 2/3 at (22,10)/(23,10) -> `GOLDENROD_UNDERGROUND_WAREHOUSE` (2,12).
25. Warehouse: `TrainerGruntM14` (8,15), `MAX_ETHER` ball at (18,15),
    `TrainerGruntM15` (14,3). Optional side trip: warp 3 at (17,2) ->
    `GOLDENROD_DEPT_STORE_B1F` (17,2), take `AMULET_COIN` at (14,2), warp back.
26. `TrainerGruntM24` (9,8). Take `TM_SLEEP_TALK` (TM35) at (13,9). Talk to the
    Director at (12,8): `verbosegiveitem CARD_KEY`, post
    `EVENT_RECEIVED_CARD_KEY` + `EVENT_GOLDENROD_DEPT_STORE_B1F_LAYOUT_1`.
27. Exit back through warps 1/2 (2,12)/(3,12). If a shutter blocks the way out,
    A-press `EmergencySwitchScript` at (20,11) (forces doors 3,5,6,8,9,11 open).
    Then warp 1 at (23,3) or warps 8/9 at (20,29)/(21,29) to leave.

Pass 3 - retake the tower:

28. `GOLDENROD_CITY` -> `RADIO_TOWER_1F` (warp 12) -> 2F -> 3F as in steps 2-5.
29. `RADIO_TOWER_3F`: stand at (14,3) FACING UP and press A on (14,2)
    (`BGEVENT_UP`). `CardKeySlotScript` -> `EVENT_USED_THE_CARD_KEY_IN_THE_RADIO_TOWER`,
    blocks (14,2)/(14,4) rewritten.
30. Walk east/south to `TrainerGruntM9` at (16,6). Battle `GRUNTM_9`.
31. Warp 3 at (17,0) -> `RADIO_TOWER_4F` (17,0). Battle `TrainerGruntF4` (12,4),
    then `TrainerExecutivem2` (14,1) who guards warp 3.
32. Warp 3 at (12,0) -> `RADIO_TOWER_5F` (12,0). Battle `TrainerExecutivef1`
    (17,2).
33. Walk to (16,5): coord event on scene 1 fires `RadioTower5FRocketBossScript`.
    The script moves the PLAYER two cells left first. Battle `EXECUTIVEM_1`.
34. Post-conditions: `EVENT_CLEARED_RADIO_TOWER`, `ENGINE_ROCKETS_IN_RADIO_TOWER`
    cleared, all Rocket objects masked, civilians restored, Blackthorn gym
    blocker swapped, `RAINBOW_WING` (Gold) or `SILVER_WING` (Silver) received, 5F
    scene -> 2.
35. Optional pickups now unlocked: `TM_SUNNY_DAY` from the 3F cooltrainer at
    (11,3); `PINK_BOW` from DJ Mary at (14,6) on 4F.

---

## 5. Port coverage

The Gen 2 side of this repo is data-driven: maps, warps, coord events, bg events,
object events and scripts all come out of `src/import/RomExtractorGen2.lua` and
run through `src/script/gen2/Vm.lua`, so "implemented" below means the generic
machinery this section needs exists, not that anyone has walked the section.

| Beat | Port file | Status |
|---|---|---|
| Map/warp/object/bg/coord tables for all nine maps | `src/import/RomExtractorGen2.lua` (`def_*` readers), `src/world/gen2/Map.lua` | implemented (generic extractor; not spot-checked against these maps) |
| Coord-event trip-wires gated by scene id | `src/world/gen2/World.lua:5011` (`coordEvents` scan against `World:scene()`), `:5025` scene scripts | implemented |
| `setscene` / `checkmapscene` / `setmapscene`, scene persistence in the save | `src/script/gen2/Vm.lua:274`, `src/world/gen2/World.lua:740-748`, `src/core/gen2/Save.lua` `mapScenes` | implemented |
| Trainer sight range + approach + `startbattle` | `src/world/gen2/Trainers.lua`, `src/world/gen2/World.lua` `SEEN_BY_TRAINER_SCRIPT`, `src/script/gen2/Vm.lua:806/817` | implemented |
| `loadtrainer` for the three scripted Executive/rival fights | `src/script/gen2/Vm.lua:806` | implemented |
| Rival starter branch (`checkevent EVENT_GOT_*_FROM_ELM`) | `src/script/gen2/Vm.lua` `checkevent`/`iftrue` | implemented |
| Switch puzzle byte (`readmem`/`addval`/`writemem` on `wUndergroundSwitchPositions`) | `src/script/gen2/Vm.lua:706-740` (sparse WRAM store, explicitly documented for this map), persisted as `scriptMem` in `src/core/gen2/Save.lua:186` | implemented |
| Switch reset on map entry (`MAPCALLBACK_NEWMAP`) | `src/world/gen2/World.lua:5659` + assertion driver `tests/drivers/gold_map_callbacks.lua:59` which loads `GOLDENROD_UNDERGROUND` for real and checks all 15 events clear | implemented and covered by a driver |
| `changeblock` + `refreshmap` (shutters, basement door, dept store crates) | `src/script/gen2/Vm.lua:1002`, `:887`; `MAPCALLBACK_TILES` at `src/world/gen2/World.lua:5664` | implemented |
| `checkitem BASEMENT_KEY` / `checkitem CARD_KEY` | `src/script/gen2/Vm.lua:523` | implemented |
| **Card Key slot (`bg_event ... BGEVENT_UP`)** | `src/world/gen2/World.lua:5147` `World:bgEventAt` matches only `(ev.kind or 0) == 0`, i.e. `BGEVENT_READ` | **missing** - the directional bg-event arms (`BGEVENT_UP/DOWN/RIGHT/LEFT`, and `BGEVENT_IFSET`/`IFNOTSET`/`COPY`) are not dispatched, so `CardKeySlotScript` can never fire and the 3F shutter cannot be opened. This blocks pass 3 entirely. |
| **Ground item balls (`OBJECTTYPE_ITEMBALL`)** | extracted as `obj.itemball` (`src/import/RomExtractorGen2.lua:2968`) but nothing consumes it: `World:interact` (`src/world/gen2/World.lua:5257`) has arms for trainers, strength boulders, `scriptKey` NPCs, `BGEVENT_READ` and `BGEVENT_ITEM` only | **missing** - Smoke Ball, Full Heal, Max Ether, TM35 Sleep Talk and Amulet Coin are all unobtainable. `src/script/gen2/CallAsm.lua:547` stubs `TryReceiveItem` on the assumption this path exists. |
| Hidden items (`BGEVENT_ITEM`: Max Potion, Revive, and the three in `GOLDENROD_UNDERGROUND`) | `src/world/gen2/HiddenItems.lua`, wired at `src/world/gen2/World.lua:5285` | implemented |
| `verbosegiveitem` (Basement Key, Card Key, wings, TM Sunny Day, Pink Bow) | `src/script/gen2/Vm.lua:490` | implemented |
| `checkver` Gold/Silver split on the wing | `src/script/gen2/Vm.lua:774` | implemented |
| `disappear` / `appear` / `moveobject` / `applymovement` / `turnobject` / `showemote` for the 5F director cutscene | `src/script/gen2/Vm.lua:297-380` | implemented |
| `special FadeOutToBlack` / `FadeInFromBlack` / `ReloadSpritesNoPalettes` / `PlayMapMusic` / `FadeOutMusic` | `src/script/gen2/Specials.lua:999-1066` | implemented |
| Object masking by event flag (every Rocket in this section) | `src/world/gen2/Npc.lua` + the extracted `eventFlag` field | implemented (semantics: SET = hidden, per `CheckObjectFlag`) |
| Elm's `SPECIALCALL_WEIRDBROADCAST` call | `src/core/gen2/Phone.lua:392` (`[4] = { name = "SPECIALCALL_WEIRDBROADCAST", condition = "outside" }`), `src/script/gen2/Vm.lua:1364` `specialphonecall` | implemented |
| Radio programming change while `ENGINE_ROCKETS_IN_RADIO_TOWER` is set | `src/ui/gen2/Pokegear.lua:348`, `:1249` | implemented |
| Dept store elevator (`elevator` opcode + crate layout rotation) | `src/script/gen2/Vm.lua:1302`, `src/ui/gen2/ElevatorMenu.lua` | implemented |
| Haircut brothers / bargain + bitter merchants (day gating) | `src/script/gen2/Specials.lua` (`OlderHaircutBrother` / `YoungerHaircutBrother`), `src/ui/gen2/MartMenu.lua:170` (`MARTTYPE_BITTER`) | implemented |
| A scripted driver that walks this section | none (`tests/drivers/gold_*.lua` has no radio tower / underground runner) | missing |

---

## 6. Unresolved / verify by hand

1. **"He gives you a Clear Bell."** The asm does not give a Clear Bell here.
   `RadioTower5FRocketBossScript` (`maps/RadioTower5F.asm:122-139`) branches on
   `checkver`: Silver gets `SILVER_WING`, Gold gets `RAINBOW_WING`. The Clear
   Bell is a Crystal item and does not appear in this script. Treat the
   walkthrough line as wrong for Gold/Silver.
2. **Switch ordering explanation.** The walkthrough says the shutters remember
   the ORDER you flipped the switches in. `wUndergroundSwitchPositions` is a
   single byte that switches 1/2/3 add 1/2/3 to, so 1-2-3 and 3-2-1 both end at
   6. The observable difference comes from which doors the INTERMEDIATE positions
   left untouched (position 3 vs position 5 differ on door 5 at (10,10)). The
   end result the walkthrough describes is correct; the stated reason is not.
   The derivation above was done by hand from the `.PositionN` arms - worth
   re-checking on hardware or an emulator before a bot depends on it.
3. **Party orderings.** The walkthrough lists `GRUNTF_4` as
   Ekans/Ekans/Gloom/Oddish and `EXECUTIVEF_1` as Arbok/Murkrow/Vileplume. The
   asm orders are `21 EKANS, 23 ODDISH, 21 EKANS, 24 GLOOM` and
   `32 ARBOK, 32 VILEPLUME, 32 MURKROW`. Same mons, different send-out order; a
   bot that hard-codes lead expectations should use the asm order.
4. **"the northwesternmost building"** - resolved to `warp_event 9, 5,
   GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES, 8` and the adjacent
   `bg_event 8, 6 GoldenrodCityUndergroundSignNorth`, but the walkthrough never
   names it, so this is an inference from the map geometry rather than a quoted
   label.
5. **EXP and money figures** ("595 EXP", "960G", etc.) were not verified. Money
   is `base money x level` from the trainer class table, which was not opened;
   EXP depends on the player's party. Nothing in this document depends on them.
6. **`EVENT_TEAM_ROCKET_DISBANDED` is set only on the Gold branch** of
   `RadioTower5FRocketBossScript` (line 130), not on the Silver branch. Its only
   other consumers are `maps/PewterCity.asm:51` (also `setevent`) and the
   `TIN_TOWER_1F` sage object mask at `maps/TinTower1F.asm:56`. This looks
   intentional (Gold gets the Rainbow Wing and therefore Ho-Oh access), but it is
   an asymmetry a port could easily get wrong, so it is flagged rather than
   asserted.
7. **`verbosegiveitem` with no `iffalse`** in `FakeDirectorScript` (Basement Key)
   and `GoldenrodUndergroundWarehouseDirectorScript` (Card Key). If the Key
   Items pocket were full the scripts would continue as if the item had been
   given. Gen 2's Key Items pocket is large enough that this is presumably
   unreachable, but the guard genuinely is not there.
8. **Radio Tower 3F `TrainerGruntM9`** reacts with "Why did the shutter open?" and
   his after-battle text mentions the Underground, which confirms he is meant for
   the post-Card-Key pass; but nothing in the asm prevents reaching (16,6) some
   other way if the block edit were bypassed. Not verified against the `.blk`
   collision data.

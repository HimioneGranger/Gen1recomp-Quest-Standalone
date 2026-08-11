# Section 16 - Routes 45, 46, 26 and 27

Source: `../section-16-routes-45-46-26-and-27.txt`
Maps covered: `MAP_ROUTE_45`, `MAP_ROUTE_46`, `MAP_ROUTE_27`, `MAP_TOHJO_FALLS`,
`MAP_ROUTE_27_SANDSTORM_HOUSE`, `MAP_ROUTE_26`, `MAP_ROUTE_26_HEAL_HOUSE`,
`MAP_DAY_OF_WEEK_SIBLINGS_HOUSE`, `MAP_VICTORY_ROAD_GATE` (gate only)
Badges / key milestones in this section: no badge. The milestones are the
MASTER BALL and EVERSTONE from Prof. Elm, TM37 SANDSTORM, TM22 SOLARBEAM, the
Tohjo Falls MOON STONE, and the eight-badge check at the Victory Road gate that
opens the Pokemon League.

Coordinate convention reminder: `warp_event` / `bg_event` / `object_event` rows
are in map **cells** (16 px walk grid). `map_const NAME, W, H` in
`constants/map_constants.asm` is in **blocks** (32 px), so a map is `W*2` by
`H*2` cells. Route 45 is `10, 45` blocks = 20 x 90 cells, which is why object
rows there run to y = 82.

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `MAP_ROUTE_45` | `maps/Route45.asm` | south connection from `BLACKTHORN_CITY` (`data/maps/attributes.asm`: `connection north, BlackthornCity, BLACKTHORN_CITY, 0`) | west connection to `ROUTE_46` (offset 36); optional warp 1 to `DARK_CAVE_BLACKTHORN_ENTRANCE` | Descend the mountain road, three forks, six trainers, four item balls |
| 2 | `MAP_ROUTE_46` | `maps/Route46.asm` | east connection from `ROUTE_45` (offset -36) | south connection to `ROUTE_29` (offset -10) or warps 1/2 to `ROUTE_29_ROUTE_46_GATE`; warp 3 to `DARK_CAVE_VIOLET_ENTRANCE` | Camper Ted, Picnicker Erin, Hiker Bailey, Dire Hit, two fruit trees |
| 3 | `MAP_NEW_BARK_TOWN` | `maps/NewBarkTown.asm` | FLY | warp 1 to `ELMS_LAB`, warp 2 to `PLAYERS_HOUSE_1F`; east connection to `ROUTE_27` | Elm hands the MASTER BALL (needs RISINGBADGE) and the EVERSTONE (needs Togepi shown). Map tables for New Bark Town belong to section 00; only the two Elm scripts are transcribed below. |
| 4 | `MAP_ROUTE_27` | `maps/Route27.asm` | west connection from `NEW_BARK_TOWN` (offset 0) - the crossing itself is water, so SURF | warp 2 / warp 3 into `TOHJO_FALLS`; warp 1 into `ROUTE_27_SANDSTORM_HOUSE`; east connection to `ROUTE_26` (offset -45) | "First step into KANTO" coord event, Rare Candy, then the eastern trainer gauntlet |
| 5 | `MAP_TOHJO_FALLS` | `maps/TohjoFalls.asm` | `Route27` warp 2 (26, 5) -> Tohjo warp 1 | Tohjo warp 2 (25, 15) -> `Route27` warp 3 | Cross the falls; MOON STONE item ball the walkthrough does not mention |
| 6 | `MAP_ROUTE_27` | `maps/Route27.asm` | Tohjo warp 2 | east connection to `ROUTE_26` | Megan ambush on exit, Sandstorm house, Blake/Brian/Gilbert, whirlpool island (Jose + TM22), Reena |
| 7 | `MAP_ROUTE_27_SANDSTORM_HOUSE` | `maps/Route27SandstormHouse.asm` | `Route27` warp 1 (33, 7) | warps 1/2 back to `Route27` warp 1 | Happiness check -> TM37 SANDSTORM |
| 8 | `MAP_ROUTE_26` | `maps/Route26.asm` | west connection from `ROUTE_27` (offset 45) | warp 1 (7, 5) to `VICTORY_ROAD_GATE` warp 3 | Scott, Richard, heal house, Joyce, Ice Berry, Gaven, Jake, Max Elixer, Beth |
| 9 | `MAP_ROUTE_26_HEAL_HOUSE` | `maps/Route26HealHouse.asm` | `Route26` warp 2 (15, 57) | warps 1/2 back to `Route26` warp 2 | Free full heal, repeatable |
| 10 | `MAP_DAY_OF_WEEK_SIBLINGS_HOUSE` | `maps/DayOfWeekSiblingsHouse.asm` | `Route26` warp 3 (5, 71) | warps 1/2 back to `Route26` warp 3 | Monica's journal (the day-of-week sibling roster) |
| 11 | `MAP_VICTORY_ROAD_GATE` | `maps/VictoryRoadGate.asm` | `Route26` warp 1 | warps 5/6 to `VICTORY_ROAD` | Eight-badge check. Victory Road itself belongs to section 17; only the gate's badge check is transcribed here because it is this section's terminal gate. |

Spill-over note: `DARK_CAVE_BLACKTHORN_ENTRANCE` / `DARK_CAVE_VIOLET_ENTRANCE`
are the "left path" the walkthrough points at from Routes 45 and 46; they are
section 15's maps. Their return warps are `DarkCaveBlackthornEntrance.asm`
`warp_event 23, 3, ROUTE_45, 1` and `DarkCaveVioletEntrance.asm`
`warp_event 35, 33, ROUTE_46, 3`.

---

## 2. Maps

### MAP_ROUTE_45

- Script: `maps/Route45.asm`
- Blocks: `maps/Route45.blk`
- Header: `data/maps/maps.asm:185` -> `map Route45, TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_45, MUSIC_ROUTE_36, FALSE, PALETTE_AUTO, FISHGROUP_DRATINI_2`
- Dimensions: `constants/map_constants.asm:170` -> `map_const ROUTE_45, 10, 45` (20 x 90 cells)
- Connections (`data/maps/attributes.asm:243`): `connection north, BlackthornCity, BLACKTHORN_CITY, 0`; `connection west, Route46, ROUTE_46, 36`
- Symbols: `4d:4e75 Route45_MapScripts`, `4d:54ad Route45_MapEvents`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 5 | `DARK_CAVE_BLACKTHORN_ENTRANCE` | 1 |

**Coord events** (`def_coord_events`)

None. Route 45 has no trip-wires; every scripted beat is an A press.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 10 | 4 | `BGEVENT_READ` | `Route45Sign` ("ROUTE 45 / MOUNTAIN RD. AHEAD") |
| 13 | 80 | `BGEVENT_ITEM` | `Route45HiddenPpUp` -> `hiddenitem PP_UP, EVENT_ROUTE_45_HIDDEN_PP_UP` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE45_POKEFAN_M1` | `SPRITE_POKEFAN_M` | 10 | 16 | `STANDING_RIGHT` | `TRAINER` (sight 1) | `TrainerHikerErik` | -1 |
| `ROUTE45_POKEFAN_M2` | `SPRITE_POKEFAN_M` | 15 | 64 | `STANDING_RIGHT` | `TRAINER` (sight 2) | `TrainerHikerMichael` | -1 |
| `ROUTE45_POKEFAN_M3` | `SPRITE_POKEFAN_M` | 5 | 28 | `STANDING_LEFT` | `TRAINER` (sight 3) | `TrainerHikerParry` | -1 |
| `ROUTE45_POKEFAN_M4` | `SPRITE_POKEFAN_M` | 9 | 64 | `STANDING_LEFT` | `TRAINER` (sight 1) | `TrainerHikerTimothy` | -1 |
| `ROUTE45_BLACK_BELT` | `SPRITE_BLACK_BELT` | 11 | 50 | `SPINRANDOM_FAST` | `TRAINER` (sight 2) | `TrainerBlackbeltKenji` | -1 |
| `ROUTE45_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 17 | 18 | `STANDING_LEFT` | `TRAINER` (sight 1) | `TrainerCooltrainermRyan` | -1 |
| `ROUTE45_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 4 | 36 | `STANDING_RIGHT` | `TRAINER` (sight 3) | `TrainerCooltrainerfKelly` | -1 |
| `ROUTE45_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 16 | 82 | `STILL` | `SCRIPT` | `Route45FruitTree` (`fruittree FRUITTREE_ROUTE_45`) | -1 |
| `ROUTE45_POKE_BALL1` | `SPRITE_POKE_BALL` | 6 | 51 | `STILL` | `ITEMBALL` | `Route45XSpecial` (`itemball X_SPECIAL`) | `EVENT_ROUTE_45_X_SPECIAL` |
| `ROUTE45_POKE_BALL2` | `SPRITE_POKE_BALL` | 6 | 66 | `STILL` | `ITEMBALL` | `Route45Revive` (`itemball REVIVE`) | `EVENT_ROUTE_45_REVIVE` |
| `ROUTE45_POKE_BALL3` | `SPRITE_POKE_BALL` | 4 | 21 | `STILL` | `ITEMBALL` | `Route45Elixer` (`itemball ELIXER`) | `EVENT_ROUTE_45_ELIXER` |
| `ROUTE45_POKE_BALL4` | `SPRITE_POKE_BALL` | 8 | 33 | `STILL` | `ITEMBALL` | `Route45MaxPotion` (`itemball MAX_POTION`) | `EVENT_ROUTE_45_MAX_POTION` |

**Scripts of interest**

- `TrainerBlackbeltKenji` (`4d:4e77`). Header is
  `trainer BLACKBELT_T, KENJI3, EVENT_BEAT_BLACKBELT_KENJI, BlackbeltKenjiSeenText, BlackbeltKenjiBeatenText, 0, .Script`.
  Post-battle `.Script`: `endifjustbattled` / `opentext` /
  `checkevent EVENT_KENJI_READY_FOR_REMATCH` (rematch branch) /
  `checkcellnum PHONE_BLACKBELT_KENJI` (already registered -> jump to the
  "number accepted" std) / `checkevent EVENT_KENJI_ASKED_FOR_PHONE_NUMBER`.
  First pass sets `EVENT_KENJI_ASKED_FOR_PHONE_NUMBER` and calls
  `askforphonenumber PHONE_BLACKBELT_KENJI`; the return value is compared
  against `PHONE_CONTACTS_FULL` and `PHONE_CONTACT_REFUSED`. This is the
  walkthrough's "talk to him again and he will give you his phone number" -
  the number is offered on the **second** A press, not the first.
  `.WantsBattle` picks the rematch party by
  `checkevent EVENT_RESTORED_POWER_TO_KANTO` -> `KENJI2`, else
  `checkevent EVENT_BEAT_ELITE_FOUR` -> `KENJI1`, else `KENJI3`; then
  `loadtrainer` / `startbattle` / `reloadmapafterbattle` /
  `clearevent EVENT_KENJI_READY_FOR_REMATCH`.
- `TrainerHikerParry` (`4d:4f2d`) is the same shape with
  `PHONE_HIKER_PARRY`, `EVENT_PARRY_ASKED_FOR_PHONE_NUMBER`,
  `EVENT_PARRY_READY_FOR_REMATCH`, and `PARRY3` as the first-meeting party
  (`PARRY1` after the Elite Four, `PARRY2` after Kanto's power is restored).
  Note `gettrainername STRING_BUFFER_3, HIKER, PARRY1` - the displayed name is
  read off `PARRY1` even though the fight is `PARRY3`.
- `TrainerHikerErik`, `TrainerHikerMichael`, `TrainerHikerTimothy`,
  `TrainerCooltrainermRyan`, `TrainerCooltrainerfKelly`: plain
  `endifjustbattled` / `opentext` / `writetext ...AfterBattleText` /
  `waitbutton` / `closetext` / `end`. No flags beyond the `trainer` header's
  own beat flag.
- `Route45FruitTree` = `fruittree FRUITTREE_ROUTE_45`. Index 12 in
  `constants/script_constants.asm:218`; `data/items/fruit_trees.asm` row 12 is
  `MYSTERYBERRY` - the walkthrough's "Mystery Berry".
- `Route45HiddenPpUp` = `hiddenitem PP_UP, EVENT_ROUTE_45_HIDDEN_PP_UP`, at
  cell (13, 80). Not mentioned by the walkthrough at all.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_HIKER_ERIK` | `constants/event_flags.asm:824` | `trainer` header | set on win, hides the "!" re-challenge |
| `EVENT_BEAT_HIKER_MICHAEL` | `:825` | `trainer` header | as above |
| `EVENT_BEAT_HIKER_PARRY` | `:826` | `trainer` header | as above |
| `EVENT_BEAT_HIKER_TIMOTHY` | `:827` | `trainer` header | as above |
| `EVENT_BEAT_BLACKBELT_KENJI` | `:686` | `trainer` header | as above |
| `EVENT_BEAT_COOLTRAINERM_RYAN` | `:864` | `trainer` header | as above |
| `EVENT_BEAT_COOLTRAINERF_KELLY` | `:883` | `trainer` header | as above |
| `EVENT_KENJI_ASKED_FOR_PHONE_NUMBER` | `constants/event_flags.asm` | `TrainerBlackbeltKenji.Script` | gates the "ask again" wording |
| `EVENT_KENJI_READY_FOR_REMATCH` | `constants/event_flags.asm` | phone script sets, map script clears | rematch pending |
| `EVENT_PARRY_ASKED_FOR_PHONE_NUMBER` / `EVENT_PARRY_READY_FOR_REMATCH` | same | `TrainerHikerParry.Script` | same pair for Parry |
| `EVENT_RESTORED_POWER_TO_KANTO` | `:204` | read by both rematch scripts | selects the hardest rematch party |
| `EVENT_BEAT_ELITE_FOUR` | `:77` | read by both rematch scripts | selects the middle rematch party |
| `EVENT_ROUTE_45_X_SPECIAL` | `:1113` | item ball object | one-time pickup |
| `EVENT_ROUTE_45_REVIVE` | `:1114` | item ball object | one-time pickup |
| `EVENT_ROUTE_45_ELIXER` | `:1115` | item ball object | one-time pickup |
| `EVENT_ROUTE_45_MAX_POTION` | `:1116` | item ball object | one-time pickup |
| `EVENT_ROUTE_45_HIDDEN_PP_UP` | `:185` | `hiddenitem` | one-time hidden pickup |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `X_SPECIAL` | item ball at (6, 51) | `Route45XSpecial` | `EVENT_ROUTE_45_X_SPECIAL` |
| `REVIVE` | item ball at (6, 66) | `Route45Revive` | `EVENT_ROUTE_45_REVIVE` |
| `ELIXER` | item ball at (4, 21) | `Route45Elixer` | `EVENT_ROUTE_45_ELIXER` |
| `MAX_POTION` | item ball at (8, 33) | `Route45MaxPotion` | `EVENT_ROUTE_45_MAX_POTION` |
| `MYSTERYBERRY` | fruit tree at (16, 82) | `Route45FruitTree` / `FRUITTREE_ROUTE_45` | daily fruit-tree flag, not an `EVENT_*` |
| `PP_UP` | hidden, bg event (13, 80) | `Route45HiddenPpUp` | `EVENT_ROUTE_45_HIDDEN_PP_UP` |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `HIKER, ERIK` | `HIKER` (`$2c`) | 7 | `HikerGroup` "ERIK": 24 MACHOP, 27 GRAVELER, 27 MACHOP | `TrainerHikerErik` | no |
| `HIKER, MICHAEL` | `HIKER` | 8 | "MICHAEL": 25 GEODUDE, 25 GRAVELER, 25 GOLEM | `TrainerHikerMichael` | no |
| `HIKER, PARRY3` | `HIKER` | 20 | "PARRY": 29 ONIX | `TrainerHikerParry` | `PHONE_HIKER_PARRY`; `PARRY1` = 34 ONIX, `PARRY2` = 38 ONIX |
| `HIKER, TIMOTHY` | `HIKER` | 10 | "TIMOTHY" (`TRAINERTYPE_MOVES`): 27 DIGLETT (MAGNITUDE/DIG/SAND_ATTACK/SLASH), 27 DUGTRIO (same) | `TrainerHikerTimothy` | no |
| `BLACKBELT_T, KENJI3` | `BLACKBELT_T` (`$32`) | 8 | `BlackbeltGroup` "KENJI": 28 MACHOKE | `TrainerBlackbeltKenji` | `PHONE_BLACKBELT_KENJI` |
| `COOLTRAINERM, RYAN` | `COOLTRAINERM` (`$1b`) | 8 | "RYAN" (`TRAINERTYPE_MOVES`): 25 PIDGEOT (SAND_ATTACK/QUICK_ATTACK/WHIRLWIND/WING_ATTACK), 27 ELECTABUZZ (THUNDERPUNCH/LIGHT_SCREEN/SWIFT/SCREECH) | `TrainerCooltrainermRyan` | no |
| `COOLTRAINERF, KELLY` | `COOLTRAINERF` (`$1c`) | 7 | "KELLY": 27 MARILL, 24 WARTORTLE, 24 WARTORTLE | `TrainerCooltrainerfKelly` | no |

**Wild encounters**

`data/wild/johto_grass.asm:2236` `def_grass_wildmons ROUTE_45`, rates
`10 percent` morn/day/nite (identical slot lists across all three times):

- Gold: 23 GEODUDE, 23 GRAVELER, 24 GLIGAR, 20 TEDDIURSA, 25 GRAVELER,
  27 GRAVELER, 27 GRAVELER.
- Silver: 23 GEODUDE, 23 GRAVELER, 24 GRAVELER, 20 PHANPY, 25 GRAVELER,
  27 SKARMORY, 27 SKARMORY.

`data/wild/johto_water.asm:204` `def_water_wildmons ROUTE_45`, 2 percent:
20 MAGIKARP, 15 MAGIKARP, 5 MAGIKARP.

Fishing group `FISHGROUP_DRATINI_2` (`data/wild/fish.asm` `FishGroups` row 9).
Headbutt: `data/wild/treemon_maps.asm:26` -> `TREEMON_SET_CANYON`
(`data/wild/treemons.asm:73`: SPEAROW/AIPOM at level 10).

Roaming beast: `data/wild/roammon_maps.asm:33` `roam_map ROUTE_45, ROUTE_44, ROUTE_46`
- Route 45 is a roam map, so Entei/Raikou can appear in its grass.

---

### MAP_ROUTE_46

- Script: `maps/Route46.asm`
- Blocks: `maps/Route46.blk`
- Header: `data/maps/maps.asm:186` -> `map Route46, TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_46, MUSIC_ROUTE_36, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:171` -> `map_const ROUTE_46, 10, 18` (20 x 36 cells)
- Connections (`data/maps/attributes.asm:247`): `connection south, Route29, ROUTE_29, -10`; `connection east, Route45, ROUTE_45, -36`
- Symbols: `4d:555e Route46_MapScripts`, `4d:57c7 Route46_MapEvents`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 7 | 33 | `ROUTE_29_ROUTE_46_GATE` | 1 |
| 2 | 8 | 33 | `ROUTE_29_ROUTE_46_GATE` | 2 |
| 3 | 14 | 5 | `DARK_CAVE_VIOLET_ENTRANCE` | 3 |

**Coord events** (`def_coord_events`)

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 9 | 27 | `BGEVENT_READ` | `Route46Sign` ("ROUTE 46 / MOUNTAIN RD. AHEAD") |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE46_POKEFAN_M` | `SPRITE_POKEFAN_M` | 12 | 18 | `STANDING_LEFT` | `TRAINER` (sight 2) | `TrainerHikerBailey` | -1 |
| `ROUTE46_YOUNGSTER` | `SPRITE_YOUNGSTER` | 3 | 13 | `STANDING_RIGHT` | `TRAINER` (sight 4) | `TrainerCamperTed` | -1 |
| `ROUTE46_LASS` | `SPRITE_LASS` | 1 | 15 | `STANDING_RIGHT` | `TRAINER` (sight 4) | `TrainerPicnickerErin1` | -1 |
| `ROUTE46_FRUIT_TREE1` | `SPRITE_FRUIT_TREE` | 7 | 5 | `STILL` | `SCRIPT` | `Route46FruitTree1` (`fruittree FRUITTREE_ROUTE_46_1`) | -1 |
| `ROUTE46_FRUIT_TREE2` | `SPRITE_FRUIT_TREE` | 8 | 6 | `STILL` | `SCRIPT` | `Route46FruitTree2` (`fruittree FRUITTREE_ROUTE_46_2`) | -1 |
| `ROUTE46_POKE_BALL` | `SPRITE_POKE_BALL` | 0 | 12 | `STILL` | `ITEMBALL` | `Route46DireHit` (`itemball DIRE_HIT`) | `EVENT_ROUTE_46_DIRE_HIT` |

**Scripts of interest**

- `TrainerPicnickerErin1` (`4d:5574`), header
  `trainer PICNICKER, ERIN1, EVENT_BEAT_PICNICKER_ERIN, ...`. Same phone shape
  as Kenji/Parry: `checkcellnum PHONE_PICNICKER_ERIN`,
  `EVENT_ERIN_ASKED_FOR_PHONE_NUMBER`, `askforphonenumber PHONE_PICNICKER_ERIN`,
  `EVENT_ERIN_READY_FOR_REMATCH`; rematch parties `ERIN2` (after Elite Four)
  and `ERIN3` (after Kanto power restored).
- `TrainerCamperTed` (`4d:5560`) and `TrainerHikerBailey` (`4d:5602`) are plain
  after-battle text scripts.
- `Route46FruitTree1` = `FRUITTREE_ROUTE_46_1` = index 4 =
  `BERRY`; `Route46FruitTree2` = `FRUITTREE_ROUTE_46_2` = index 10 =
  `PRZCUREBERRY` (`data/items/fruit_trees.asm`). Those are the walkthrough's
  "Berry and PrzCure Berry".

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_HIKER_BAILEY` | `constants/event_flags.asm:828` | `trainer` header | set on win |
| `EVENT_BEAT_CAMPER_TED` | `:538` | `trainer` header | set on win |
| `EVENT_BEAT_PICNICKER_ERIN` | `:645` | `trainer` header | set on win |
| `EVENT_ERIN_ASKED_FOR_PHONE_NUMBER` / `EVENT_ERIN_READY_FOR_REMATCH` | `constants/event_flags.asm` | `TrainerPicnickerErin1.Script` | phone / rematch pair |
| `EVENT_ROUTE_46_DIRE_HIT` | `:1117` | item ball object | one-time pickup |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `DIRE_HIT` | item ball at (0, 12) | `Route46DireHit` | `EVENT_ROUTE_46_DIRE_HIT` |
| `BERRY` | fruit tree at (7, 5) | `Route46FruitTree1` | daily fruit-tree flag |
| `PRZCUREBERRY` | fruit tree at (8, 6) | `Route46FruitTree2` | daily fruit-tree flag |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `HIKER, BAILEY` | `HIKER` | 11 | `HikerGroup` "BAILEY": five 13 GEODUDE | `TrainerHikerBailey` | no |
| `CAMPER, TED` | `CAMPER` (`$36`) | 11 | `CamperGroup` "TED": 17 MANKEY | `TrainerCamperTed` | no |
| `PICNICKER, ERIN1` | `PICNICKER` (`$35`) | 10 | `PicnickerGroup` "ERIN": 16 PONYTA, 16 PONYTA | `TrainerPicnickerErin1` | `PHONE_PICNICKER_ERIN` |

**Wild encounters**

`data/wild/johto_grass.asm:2291` `def_grass_wildmons ROUTE_46`, `10 percent`
morn/day/nite, same for Gold and Silver:

- morn/day: 3 GEODUDE, 2 SPEAROW, 2 RATTATA, 2 GEODUDE, 3 SPEAROW,
  3 JIGGLYPUFF, 5 JIGGLYPUFF.
- nite: 3 GEODUDE, 3 RATTATA, 2 RATTATA, 2 GEODUDE, 4 GEODUDE, 3 JIGGLYPUFF,
  5 JIGGLYPUFF.

No water table. Fishing group `FISHGROUP_SHORE`. Headbutt:
`data/wild/treemon_maps.asm:27` -> `TREEMON_SET_CANYON`.
Roaming beast: `data/wild/roammon_maps.asm:34` `roam_map ROUTE_46, ROUTE_45, ROUTE_29`.

---

### MAP_NEW_BARK_TOWN (Elm's Lab beats only)

The New Bark Town / Elm's Lab map tables belong to section 00. What this
section needs is the two `ProfElmScript` branches the walkthrough triggers.

- `maps/ElmsLab.asm:50` `ProfElmScript`:
  `faceplayer` / `opentext` / `checkevent EVENT_GOT_SS_TICKET_FROM_ELM`
  (-> `ElmCheckMasterBall`) / `checkevent EVENT_BEAT_ELITE_FOUR`
  (-> `ElmGiveTicketScript`).
- `ElmCheckMasterBall`: `checkevent EVENT_GOT_MASTER_BALL_FROM_ELM` /
  `checkflag ENGINE_RISINGBADGE` -> `ElmGiveMasterBallScript`. **This is the
  actual gate on the Master Ball: the eighth Johto badge, not "eight badges"
  counted.** `constants/engine_flags.asm:45` is `ENGINE_RISINGBADGE`.
- `ElmGiveMasterBallScript` (`60:4268`): `verbosegiveitem MASTER_BALL` /
  `iffalse .notdone` / `setevent EVENT_GOT_MASTER_BALL_FROM_ELM`. A full bag
  means the flag is never set, so a bot must have a free slot.
- `ElmCheckEverstone`: `checkevent EVENT_GOT_EVERSTONE_FROM_ELM` /
  `checkevent EVENT_SHOWED_TOGEPI_TO_ELM` -> `ElmGiveEverstoneScript` /
  `checkevent EVENT_TOLD_ELM_ABOUT_TOGEPI_OVER_THE_PHONE`, then
  `setval TOGEPI` + `special FindPartyMonThatSpeciesYourTrainerID`, and the
  same for `TOGETIC`. That special is why the walkthrough tells you to
  **withdraw Togepi into the party first** - the check is a party scan, and it
  additionally requires the mon to be your own OT.
- `ShowElmTogepiScript` sets `EVENT_SHOWED_TOGEPI_TO_ELM` and falls into
  `ElmGiveEverstoneScript` (`60:424f`): `verbosegiveitem EVERSTONE` /
  `iffalse ElmScript_NoRoomForEverstone` / `setevent EVENT_GOT_EVERSTONE_FROM_ELM`.
- Mom's savings: `maps/PlayersHouse1F.asm:85` `MomScript`, `.BankOfMom` at
  line 115 runs `special BankOfMom`.

---

### MAP_ROUTE_27

- Script: `maps/Route27.asm`
- Blocks: `maps/Route27.blk`
- Header: `data/maps/maps.asm:473` -> `map Route27, TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_27, MUSIC_ROUTE_26, FALSE, PALETTE_AUTO, FISHGROUP_OCEAN`
- Dimensions: `constants/map_constants.asm:438` -> `map_const ROUTE_27, 40, 9` (80 x 18 cells)
- Connections (`data/maps/attributes.asm:170`): `connection west, NewBarkTown, NEW_BARK_TOWN, 0`; `connection east, Route26, ROUTE_26, -45`
- Scene var: `data/maps/scenes.asm:27` `scene_var ROUTE_27, wRoute27SceneID`
- Symbols: `4a:46ba Route27_MapScripts`, `4a:4cac Route27_MapEvents`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 33 | 7 | `ROUTE_27_SANDSTORM_HOUSE` | 1 |
| 2 | 26 | 5 | `TOHJO_FALLS` | 1 |
| 3 | 36 | 5 | `TOHJO_FALLS` | 2 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_ROUTE27_FIRST_STEP_INTO_KANTO` (0) | 18 | 10 | `FirstStepIntoKantoLeftScene` | fisher turns LEFT, `showemote EMOTE_SHOCK`, `applymovement ROUTE27_FISHER, Route27FisherStepLeftTwiceMovement` (two `step LEFT`) |
| `SCENE_ROUTE27_FIRST_STEP_INTO_KANTO` (0) | 19 | 10 | `FirstStepIntoKantoRightScene` | same but one `step LEFT` |

Both fall into `FirstStepIntoKantoScene_Continue`: `turnobject PLAYER, RIGHT`,
`writetext Route27FisherHeyText`, `writetext Route27FisherText` ("You've taken
your first step into KANTO"), then `setscene SCENE_ROUTE27_NOOP` (1) so it never
fires again. The scene constants are generated by the `def_scene_scripts` /
`scene_script` macros in `macros/scripts/maps.asm`; the sym table confirms
`SCENE_ROUTE27_FIRST_STEP_INTO_KANTO = 00` and `SCENE_ROUTE27_NOOP = 01`.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 25 | 7 | `BGEVENT_READ` | `TohjoFallsSign` ("TOHJO FALLS / The Link Between KANTO and JOHTO") |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE27_COOLTRAINER_M1` | `SPRITE_COOLTRAINER_M` | 49 | 7 | `STANDING_UP` | `TRAINER` (sight 3) | `TrainerCooltrainermBlake` | -1 |
| `ROUTE27_COOLTRAINER_M2` | `SPRITE_COOLTRAINER_M` | 58 | 6 | `STANDING_LEFT` | `TRAINER` (sight 5) | `TrainerCooltrainermBrian` | -1 |
| `ROUTE27_COOLTRAINER_F1` | `SPRITE_COOLTRAINER_F` | 72 | 11 | `STANDING_UP` | `TRAINER` (sight 5) | `TrainerCooltrainerfReena` | -1 |
| `ROUTE27_COOLTRAINER_F2` | `SPRITE_COOLTRAINER_F` | 37 | 6 | `SPINCLOCKWISE` | `TRAINER` (sight 2) | `TrainerCooltrainerfMegan` | -1 |
| `ROUTE27_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 64 | 7 | `STANDING_LEFT` | `TRAINER` (sight 5) | `TrainerPsychicGilbert` | -1 |
| `ROUTE27_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 58 | 13 | `STANDING_RIGHT` | `TRAINER` (sight 3) | `TrainerBirdKeeperJose2` | -1 |
| `ROUTE27_POKE_BALL1` | `SPRITE_POKE_BALL` | 60 | 12 | `STILL` | `ITEMBALL` | `Route27TMSolarbeam` (`itemball TM_SOLARBEAM`) | `EVENT_ROUTE_27_TM_SOLARBEAM` |
| `ROUTE27_POKE_BALL2` | `SPRITE_POKE_BALL` | 53 | 12 | `STILL` | `ITEMBALL` | `Route27RareCandy` (`itemball RARE_CANDY`) | `EVENT_ROUTE_27_RARE_CANDY` |
| `ROUTE27_FISHER` | `SPRITE_FISHER` | 21 | 10 | `SPINRANDOM_SLOW` | `SCRIPT` (sight 3) | `Route27FisherScript` (`jumptextfaceplayer Route27FisherText`) | -1 |

**Scripts of interest**

- `FirstStepIntoKantoLeftScene` (`4a:46c6`) / `FirstStepIntoKantoRightScene`
  (`4a:46d4`) - the only forced cutscene on this route, described above. It is
  a coord event on the two cells (18, 10) and (19, 10), so a bot that lands on
  Route 27 by surfing will cross it.
- `TrainerBirdKeeperJose2` (`4a:4706`), `trainer BIRD_KEEPER, JOSE2, EVENT_BEAT_BIRD_KEEPER_JOSE2, ...`,
  phone contact `PHONE_BIRDKEEPER_JOSE`, `EVENT_JOSE_ASKED_FOR_PHONE_NUMBER`,
  `EVENT_JOSE_READY_FOR_REMATCH`; rematch parties `JOSE1` (after Elite Four)
  and `JOSE3` (after Kanto power restored).
- `TrainerCooltrainerfReena` (`4a:47bc`), `trainer COOLTRAINERF, REENA1, ...`,
  phone contact `PHONE_COOLTRAINERF_REENA`; rematch parties `REENA2` / `REENA3`.
- `TrainerCooltrainermBlake` (`4a:4794`), `TrainerCooltrainermBrian`
  (`4a:47a8`), `TrainerPsychicGilbert` (`4a:46f2`),
  `TrainerCooltrainerfMegan` (`4a:484a`) - plain after-battle text.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `SCENE_ROUTE27_FIRST_STEP_INTO_KANTO` = 0 | generated in `maps/Route27.asm` (`def_scene_scripts`) | coord events; cleared by `setscene SCENE_ROUTE27_NOOP` | the Kanto welcome fires exactly once |
| `SCENE_ROUTE27_NOOP` = 1 | same | `FirstStepIntoKantoScene_Continue` | scene after the cutscene |
| `EVENT_BEAT_COOLTRAINERM_BLAKE` | `constants/event_flags.asm:867` | `trainer` header | set on win |
| `EVENT_BEAT_COOLTRAINERM_BRIAN` | `:868` | `trainer` header | set on win |
| `EVENT_BEAT_COOLTRAINERF_REENA` | `:886` | `trainer` header | set on win |
| `EVENT_BEAT_COOLTRAINERF_MEGAN` | `:887` | `trainer` header | set on win |
| `EVENT_BEAT_PSYCHIC_GILBERT` | `:572` | `trainer` header | set on win |
| `EVENT_BEAT_BIRD_KEEPER_JOSE2` | `:507` | `trainer` header | set on win |
| `EVENT_ROUTE_27_TM_SOLARBEAM` | `:1100` | item ball object | one-time pickup |
| `EVENT_ROUTE_27_RARE_CANDY` | `:1101` | item ball object | one-time pickup |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `TM_SOLARBEAM` (TM22) | item ball at (60, 12), on the island past the whirlpool | `Route27TMSolarbeam` | `EVENT_ROUTE_27_TM_SOLARBEAM` |
| `RARE_CANDY` | item ball at (53, 12), in the southern water | `Route27RareCandy` | `EVENT_ROUTE_27_RARE_CANDY` |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `COOLTRAINERF, MEGAN` | `COOLTRAINERF` | 11 | "MEGAN" (`TRAINERTYPE_MOVES`): 32 BULBASAUR (GROWL/LEECH_SEED/POISONPOWDER/RAZOR_LEAF), 32 IVYSAUR (same), 32 VENUSAUR (BODY_SLAM/SLEEP_POWDER/RAZOR_LEAF/SWEET_SCENT) | `TrainerCooltrainerfMegan` | no |
| `COOLTRAINERM, BLAKE` | `COOLTRAINERM` | 11 | "BLAKE" (`TRAINERTYPE_MOVES`): 33 MAGNETON (THUNDERBOLT/SUPERSONIC/SWIFT/SCREECH), 31 QUAGSIRE (WATER_GUN/SLAM/AMNESIA/EARTHQUAKE), 31 EXEGGCUTE (LEECH_SEED/CONFUSION/SLEEP_POWDER/SOLARBEAM) | `TrainerCooltrainermBlake` | no |
| `COOLTRAINERM, BRIAN` | `COOLTRAINERM` | 12 | "BRIAN" (`TRAINERTYPE_MOVES`): 35 SANDSLASH (SAND_ATTACK/POISON_STING/SLASH/SWIFT) | `TrainerCooltrainermBrian` | no |
| `PSYCHIC_T, GILBERT` | `PSYCHIC_T` (`$34`) | 10 | "GILBERT": 30 STARMIE, 30 EXEGGCUTE, 34 GIRAFARIG | `TrainerPsychicGilbert` | no |
| `BIRD_KEEPER, JOSE2` | `BIRD_KEEPER` (`$18`) | 14 | "JOSE": 35 FARFETCH_D | `TrainerBirdKeeperJose2` | `PHONE_BIRDKEEPER_JOSE` |
| `COOLTRAINERF, REENA1` | `COOLTRAINERF` | 10 | "REENA": 31 STARMIE, 33 NIDOQUEEN, 31 STARMIE | `TrainerCooltrainerfReena` | `PHONE_COOLTRAINERF_REENA` |

Note the party order for Reena is STARMIE / NIDOQUEEN / STARMIE in the asm; the
walkthrough lists it STARMIE / STARMIE / NIDOQUEEN.

**Wild encounters**

`data/wild/kanto_grass.asm:1172` `def_grass_wildmons ROUTE_27`, `10 percent`:

- Gold morn: 28 DODUO, 28 RATICATE, 30 DODUO, 28 QUAGSIRE, 32 PONYTA,
  30 SANDSLASH, 30 SANDSLASH.
- Gold day: 28 DODUO, 28 RATICATE, 30 DODUO, 30 RATICATE, 32 PONYTA,
  30 SANDSLASH, 30 SANDSLASH.
- Gold nite: 28 QUAGSIRE, 28 RATICATE, 30 QUAGSIRE, 30 RATICATE, 32 PONYTA,
  30 SANDSLASH, 30 SANDSLASH.
- Silver swaps DODRIO/ARBOK in for some of those; see the `ELIF DEF(_SILVER)`
  block at the same label.

`data/wild/kanto_water.asm:96` `def_water_wildmons ROUTE_27`, 6 percent:
20 TENTACOOL, 15 TENTACOOL, 20 TENTACRUEL.

Fishing group `FISHGROUP_OCEAN`. Headbutt:
`data/wild/treemon_maps.asm:8` -> `TREEMON_SET_FOREST` (Gold: CATERPIE /
METAPOD / EXEGGCUTE / BUTTERFREE common, PINECO in the rare table).

The walkthrough's Route 27 list omits Doduo's Gold-only DODRIO slots and does
not mention that ARBOK is Silver-only.

---

### MAP_TOHJO_FALLS

- Script: `maps/TohjoFalls.asm`
- Blocks: `maps/TohjoFalls.blk`
- Header: `data/maps/maps.asm:152` -> `map TohjoFalls, TILESET_CAVE, CAVE, LANDMARK_TOHJO_FALLS, MUSIC_UNION_CAVE, TRUE, PALETTE_NITE, FISHGROUP_LAKE`
  (`TRUE` in the phone slot = no phone calls inside)
- Dimensions: `constants/map_constants.asm:139` -> `map_const TOHJO_FALLS, 15, 9` (30 x 18 cells)
- Connections: none (`data/maps/attributes.asm:471` is a bare `map_attributes` row)
- Symbols: `47:4a20 TohjoFalls_MapScripts`, `47:4a24 TohjoFalls_MapEvents`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 13 | 15 | `ROUTE_27` | 2 |
| 2 | 25 | 15 | `ROUTE_27` | 3 |

**Coord events** / **BG events**

Both empty.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TOHJOFALLS_POKE_BALL` | `SPRITE_POKE_BALL` | 2 | 6 | `STILL` | `ITEMBALL` | `TohjoFallsMoonStone` (`itemball MOON_STONE`) | `EVENT_TOHJO_FALLS_MOON_STONE` |

**Scripts of interest**

`TohjoFallsMoonStone` (`47:4a22`) is the only script on the map. There is no
`def_scene_scripts` body and no callbacks - the whole map is terrain.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_TOHJO_FALLS_MOON_STONE` | `constants/event_flags.asm:1098` | item ball object | one-time pickup |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `MOON_STONE` | item ball at (2, 6) - across the water, west end | `TohjoFallsMoonStone` | `EVENT_TOHJO_FALLS_MOON_STONE` |

**Trainers**

None.

**Wild encounters**

`data/wild/kanto_grass.asm:199` `def_grass_wildmons TOHJO_FALLS`, encounter
rate 4 percent in Gold / 6 percent in Silver, identical morn/day/nite:
22 ZUBAT, 22 RATICATE, 22 GOLBAT, 21 SLOWPOKE, 20 RATTATA, 23 SLOWPOKE,
23 SLOWPOKE.

`data/wild/kanto_water.asm:103` `def_water_wildmons TOHJO_FALLS`, 4 percent:
20 GOLDEEN, 20 SLOWPOKE, 20 SEAKING.

Fishing group `FISHGROUP_LAKE`. No treemon map entry (it is a cave).

The walkthrough's list (Rattata / Slowpoke / Seaking) is a subset - ZUBAT,
GOLBAT, RATICATE and GOLDEEN are also here.

---

### MAP_ROUTE_27_SANDSTORM_HOUSE

- Script: `maps/Route27SandstormHouse.asm`
- Blocks: none (indoor, uses the shared house layout)
- Header: `data/maps/maps.asm:483` -> `map Route27SandstormHouse, TILESET_HOUSE, INDOOR, LANDMARK_ROUTE_27, MUSIC_AZALEA_TOWN, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:448` -> `map_const ROUTE_27_SANDSTORM_HOUSE, 4, 4` (8 x 8 cells)
- Symbols: `60:6352 SandstormHouseWoman`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `ROUTE_27` | 1 |
| 2 | 3 | 7 | `ROUTE_27` | 1 |

**Coord events**

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `SandstormHouseBookshelf` (`jumpstd MagazineBookshelfScript`) |
| 1 | 1 | `BGEVENT_READ` | `SandstormHouseBookshelf` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE27SANDSTORMHOUSE_GRANNY` | `SPRITE_GRANNY` | 2 | 4 | `STANDING_DOWN` | `SCRIPT` | `SandstormHouseWoman` | -1 |

**Scripts of interest**

`SandstormHouseWoman` (`60:6352`):

```
faceplayer / opentext
checkevent EVENT_GOT_TM37_SANDSTORM   ; iftrue .AlreadyGotItem
special GetFirstPokemonHappiness
writetext SandstormHouseWomanText1 / promptbutton
ifgreater 150 - 1, .Loyal             ; i.e. happiness >= 150
sjump .Disloyal
.Loyal: writetext SandstormHouseWomanLoyalText / promptbutton
        verbosegiveitem TM_SANDSTORM / iffalse .Done
        setevent EVENT_GOT_TM37_SANDSTORM
```

The precise gate is **happiness of the first non-egg party member >= 150**
(`ifgreater 150 - 1`), not "one of your Pokemon is happy" as the walkthrough
puts it - only the first party slot is read, by
`special GetFirstPokemonHappiness`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_GOT_TM37_SANDSTORM` | `constants/event_flags.asm:126` | `SandstormHouseWoman` | one-time; also short-circuits straight to the TM description text |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `TM_SANDSTORM` (TM37) | talk to the granny with a >= 150 happiness lead mon | `SandstormHouseWoman.Loyal` | `EVENT_GOT_TM37_SANDSTORM` |

---

### MAP_ROUTE_26

- Script: `maps/Route26.asm`
- Blocks: `maps/Route26.blk`
- Header: `data/maps/maps.asm:472` -> `map Route26, TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_26, MUSIC_ROUTE_26, FALSE, PALETTE_AUTO, FISHGROUP_OCEAN`
- Dimensions: `constants/map_constants.asm:437` -> `map_const ROUTE_26, 10, 54` (20 x 108 cells)
- Connections (`data/maps/attributes.asm:167`): `connection west, Route27, ROUTE_27, 45` (west only - the north end is the Victory Road gate warp, not a connection)
- Symbols: `4a:4000 Route26_MapScripts`, `4a:4638 Route26_MapEvents`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 7 | 5 | `VICTORY_ROAD_GATE` | 3 |
| 2 | 15 | 57 | `ROUTE_26_HEAL_HOUSE` | 1 |
| 3 | 5 | 71 | `DAY_OF_WEEK_SIBLINGS_HOUSE` | 1 |

**Coord events**

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 8 | 6 | `BGEVENT_READ` | `Route26Sign` ("ROUTE 26 / #MON LEAGUE RECEPTION GATE") |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE26_COOLTRAINER_M1` | `SPRITE_COOLTRAINER_M` | 11 | 16 | `STANDING_RIGHT` | `TRAINER` (sight 2) | `TrainerCooltrainermJake` | -1 |
| `ROUTE26_COOLTRAINER_M2` | `SPRITE_COOLTRAINER_M` | 9 | 38 | `STANDING_LEFT` | `TRAINER` (sight 5) | `TrainerCooltrainermGaven3` | -1 |
| `ROUTE26_COOLTRAINER_F1` | `SPRITE_COOLTRAINER_F` | 10 | 56 | `SPINRANDOM_FAST` | `TRAINER` (sight 3) | `TrainerCooltrainerfJoyce` | -1 |
| `ROUTE26_COOLTRAINER_F2` | `SPRITE_COOLTRAINER_F` | 5 | 8 | `STANDING_RIGHT` | `TRAINER` (sight 4) | `TrainerCooltrainerfBeth1` | -1 |
| `ROUTE26_YOUNGSTER` | `SPRITE_YOUNGSTER` | 13 | 79 | `STANDING_RIGHT` | `TRAINER` (sight 4) | `TrainerPsychicRichard` | -1 |
| `ROUTE26_FISHER` | `SPRITE_FISHER` | 10 | 92 | `STANDING_DOWN` | `TRAINER` (sight 3) | `TrainerFisherScott` | -1 |
| `ROUTE26_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 14 | 54 | `STILL` | `SCRIPT` | `Route26FruitTree` (`fruittree FRUITTREE_ROUTE_26`) | -1 |
| `ROUTE26_POKE_BALL` | `SPRITE_POKE_BALL` | 9 | 15 | `STILL` | `ITEMBALL` | `Route26MaxElixer` (`itemball MAX_ELIXER`) | `EVENT_ROUTE_26_MAX_ELIXER` |

The y coordinates run south (high) to north (low), which matches the
walkthrough's order exactly: Scott (92) -> Richard (79) -> Day-of-Week house
(71) -> heal house (57) -> Joyce (56) -> Ice Berry tree (54) -> Gaven (38) ->
Jake (16) -> Max Elixer (15) -> Beth (8) -> gate warp (5).

**Scripts of interest**

- `TrainerCooltrainermGaven3` (`4a:4016`), header
  `trainer COOLTRAINERM, GAVEN3, EVENT_BEAT_COOLTRAINERM_GAVEN, ...`. Phone
  contact `PHONE_COOLTRAINERM_GAVEN`; rematch parties `GAVEN1` (after Elite
  Four) and `GAVEN2` (after Kanto power restored). His after-battle text is the
  one that names Victory Road as the way to the League.
- `TrainerCooltrainerfBeth1` (`4a:40b8`), phone `PHONE_COOLTRAINERF_BETH`;
  rematch parties `BETH2` / `BETH3`.
- `TrainerCooltrainermJake` (`4a:4002`), `TrainerCooltrainerfJoyce`
  (`4a:40a4`), `TrainerPsychicRichard` (`4a:4146`), `TrainerFisherScott`
  (`4a:415a`) - plain after-battle text.
- `Route26FruitTree` = `FRUITTREE_ROUTE_26` = index 14 = `ICE_BERRY`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_FISHER_SCOTT` | `constants/event_flags.asm:605` | `trainer` header | set on win |
| `EVENT_BEAT_PSYCHIC_RICHARD` | `:571` | `trainer` header | set on win |
| `EVENT_BEAT_COOLTRAINERF_JOYCE` | `:884` | `trainer` header | set on win |
| `EVENT_BEAT_COOLTRAINERM_GAVEN` | `:866` | `trainer` header | set on win |
| `EVENT_BEAT_COOLTRAINERM_JAKE` | `:865` | `trainer` header | set on win |
| `EVENT_BEAT_COOLTRAINERF_BETH` | `:885` | `trainer` header | set on win |
| `EVENT_GAVEN_ASKED_FOR_PHONE_NUMBER` / `EVENT_GAVEN_READY_FOR_REMATCH` | `constants/event_flags.asm` | `TrainerCooltrainermGaven3.Script` | phone / rematch pair |
| `EVENT_BETH_ASKED_FOR_PHONE_NUMBER` / `EVENT_BETH_READY_FOR_REMATCH` | `constants/event_flags.asm` | `TrainerCooltrainerfBeth1.Script` | phone / rematch pair |
| `EVENT_ROUTE_26_MAX_ELIXER` | `:1099` | item ball object | one-time pickup |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `MAX_ELIXER` | item ball at (9, 15) | `Route26MaxElixer` | `EVENT_ROUTE_26_MAX_ELIXER` |
| `ICE_BERRY` | fruit tree at (14, 54) | `Route26FruitTree` / `FRUITTREE_ROUTE_26` | daily fruit-tree flag |

There is exactly **one** Max Elixer on Route 26. The walkthrough mentions it
twice ("grab the Max Elixir" then "you can also pick up an Max Elixir if you
take the jumps back to heal") - both refer to the same ball at (9, 15).

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `FISHER, SCOTT` | `FISHER` (`$25`) | 21 | `FisherGroup` "SCOTT": 30 QWILFISH, 30 QWILFISH, 34 SEAKING | `TrainerFisherScott` | no |
| `PSYCHIC_T, RICHARD` | `PSYCHIC_T` | 9 | "RICHARD": 36 ESPEON | `TrainerPsychicRichard` | no |
| `COOLTRAINERF, JOYCE` | `COOLTRAINERF` | 8 | "JOYCE" (`TRAINERTYPE_MOVES`): 36 PIKACHU (QUICK_ATTACK/DOUBLE_TEAM/THUNDERBOLT/THUNDER), 32 BLASTOISE (BITE/CURSE/SURF/RAIN_DANCE) | `TrainerCooltrainerfJoyce` | no |
| `COOLTRAINERM, GAVEN3` | `COOLTRAINERM` | 10 | "GAVEN" (`TRAINERTYPE_MOVES`): 32 VICTREEBEL (WRAP/TOXIC/ACID/RAZOR_LEAF), 32 **KINGLER** (BUBBLEBEAM/STOMP/GUILLOTINE/PROTECT), 32 FLAREON (SAND_ATTACK/QUICK_ATTACK/BITE/FIRE_SPIN) | `TrainerCooltrainermGaven3` | `PHONE_COOLTRAINERM_GAVEN` |
| `COOLTRAINERM, JAKE` | `COOLTRAINERM` | 9 | "JAKE" (`TRAINERTYPE_MOVES`): 33 PARASECT (LEECH_LIFE/SPORE/SLASH/SWORDS_DANCE), 35 GOLDUCK (CONFUSION/SCREECH/PSYCH_UP/FURY_SWIPES) | `TrainerCooltrainermJake` | no |
| `COOLTRAINERF, BETH1` | `COOLTRAINERF` | 9 | "BETH" (`TRAINERTYPE_MOVES`): 36 RAPIDASH (STOMP/FIRE_SPIN/FURY_ATTACK/AGILITY) | `TrainerCooltrainerfBeth1` | `PHONE_COOLTRAINERF_BETH` |

**Wild encounters**

`data/wild/kanto_grass.asm:1117` `def_grass_wildmons ROUTE_26`, `10 percent`:

- Gold morn: 28 DODUO, 28 SANDSLASH, 32 PONYTA, 30 DODUO, 30 DODRIO,
  30 RATICATE, 30 QUAGSIRE.
- Gold day: 28 DODUO, 28 SANDSLASH, 32 PONYTA, 30 DODUO, 30 RATICATE,
  30 DODRIO, 30 DODRIO.
- Gold nite: 28 RATICATE, 28 SANDSLASH, 32 PONYTA, 30 RATICATE, 30 QUAGSIRE,
  32 QUAGSIRE, 32 QUAGSIRE.
- Silver replaces SANDSLASH with RATICATE and DODRIO with ARBOK; see the
  `ELIF DEF(_SILVER)` block at the same label.

`data/wild/kanto_water.asm:89` `def_water_wildmons ROUTE_26`, 6 percent:
30 TENTACOOL, 25 TENTACOOL, 30 TENTACRUEL.

Fishing group `FISHGROUP_OCEAN`. Headbutt:
`data/wild/treemon_maps.asm:7` -> `TREEMON_SET_FOREST`.

Note SANDSLASH is Gold-only on Route 26; the walkthrough lists ARBOK, which is
the Silver slot.

---

### MAP_ROUTE_26_HEAL_HOUSE

- Script: `maps/Route26HealHouse.asm`
- Header: `data/maps/maps.asm:481` -> `map Route26HealHouse, TILESET_HOUSE, INDOOR, LANDMARK_ROUTE_26, MUSIC_AZALEA_TOWN, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:446` -> `map_const ROUTE_26_HEAL_HOUSE, 4, 4`
- Symbols: `60:60e6 Route26HealHouseTeacherScript`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `ROUTE_26` | 2 |
| 2 | 3 | 7 | `ROUTE_26` | 2 |

**Coord events**

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `Route26HealHouseBookshelf` (`jumpstd PictureBookshelfScript`) |
| 1 | 1 | `BGEVENT_READ` | `Route26HealHouseBookshelf` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE26HEALHOUSE_TEACHER` | `SPRITE_TEACHER` | 2 | 3 | `STANDING_DOWN` | `SCRIPT` | `Route26HealHouseTeacherScript` | -1 |

**Scripts of interest**

`Route26HealHouseTeacherScript` (`60:60e6`):
`faceplayer` / `opentext` / `writetext Route26HealHouseRestAWhileText` /
`waitbutton` / `closetext` / `special FadeOutToBlack` /
`special ReloadSpritesNoPalettes` / `playmusic MUSIC_HEAL` /
`special HealParty` / `pause 60` / `special FadeInFromBlack` /
`special RestartMapMusic` / `writetext Route26HealHouseKeepAtItText` / `end`.

**No flag guards this at all** - it is unconditional and repeatable, which is
what makes it a free Pokemon Center for a bot grinding Route 26.

---

### MAP_DAY_OF_WEEK_SIBLINGS_HOUSE

- Script: `maps/DayOfWeekSiblingsHouse.asm`
- Header: `data/maps/maps.asm:482` -> `map DayOfWeekSiblingsHouse, TILESET_HOUSE, INDOOR, LANDMARK_ROUTE_26, MUSIC_AZALEA_TOWN, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:447` -> `map_const DAY_OF_WEEK_SIBLINGS_HOUSE, 4, 4`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `ROUTE_26` | 3 |
| 2 | 3 | 7 | `ROUTE_26` | 3 |

**Coord events** / **BG events**

Both empty.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `DAYOFWEEKSIBLINGSHOUSE_POKEDEX` | `SPRITE_POKEDEX` | 3 | 3 | `STILL` | `SCRIPT` | `DayOfWeekSiblingsHousePokedexScript` | -1 |

**Scripts of interest**

`DayOfWeekSiblingsHousePokedexScript` is two nested `yesorno` prompts over
`DayOfWeekSiblingsHousePokedexText1/2/3`. Text 3 is Monica's roster, and it
matches the walkthrough exactly: Monday MONICA / ROUTE 40, Tuesday TUSCANY /
ROUTE 29, Wednesday WESLEY / LAKE OF RAGE, Thursday ARTHUR / ROUTE 36, and so
on. Pure text - no flags, no items.

---

### MAP_VICTORY_ROAD_GATE (badge check only)

Victory Road itself is section 17. Transcribed here because the gate is this
section's terminal blocker.

- Script: `maps/VictoryRoadGate.asm`
- Header: `data/maps/maps.asm:467` -> `map VictoryRoadGate, TILESET_GATE, GATE, LANDMARK_ROUTE_26, MUSIC_INDIGO_PLATEAU, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:433` -> `map_const VICTORY_ROAD_GATE, 10, 9`
- Symbols: `5f:4fdc VictoryRoadGateBadgeCheckScript`, `5f:4ff8 _VictoryRoadGateBadgeCheckScript.AllEightBadges`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 17 | 7 | `ROUTE_22` | 1 |
| 2 | 18 | 7 | `ROUTE_22` | 1 |
| 3 | 9 | 17 | `ROUTE_26` | 1 |
| 4 | 10 | 17 | `ROUTE_26` | 1 |
| 5 | 9 | 0 | `VICTORY_ROAD` | 1 |
| 6 | 10 | 0 | `VICTORY_ROAD` | 1 |
| 7 | 1 | 7 | `ROUTE_28` | 2 |
| 8 | 2 | 7 | `ROUTE_28` | 2 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_VICTORYROADGATE_BADGE_CHECK` (0) | 10 | 11 | `VictoryRoadGateBadgeCheckScript` | `turnobject PLAYER, LEFT` then the shared badge check |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VICTORYROADGATE_OFFICER` | `SPRITE_OFFICER` | 8 | 11 | `STANDING_RIGHT` | `SCRIPT` | `VictoryRoadGateOfficerScript` | -1 |
| `VICTORYROADGATE_BLACK_BELT1` | `SPRITE_BLACK_BELT` | 7 | 5 | `STANDING_RIGHT` | `SCRIPT` | `VictoryRoadGateLeftBlackBeltScript` | `EVENT_OPENED_MT_SILVER` |
| `VICTORYROADGATE_BLACK_BELT2` | `SPRITE_BLACK_BELT` | 12 | 5 | `STANDING_LEFT` | `SCRIPT` | `VictoryRoadGateRightBlackBeltScript` | `EVENT_FOUGHT_SNORLAX` |

**Scripts of interest**

`_VictoryRoadGateBadgeCheckScript`:

```
opentext / writetext VictoryRoadGateOfficerText / promptbutton
readvar VAR_BADGES
ifgreater NUM_JOHTO_BADGES - 1, .AllEightBadges   ; badges > 7
writetext VictoryRoadGateNotEnoughBadgesText / waitbutton / closetext
applymovement PLAYER, VictoryRoadGateStepDownMovement   ; one step DOWN
end
.AllEightBadges:
writetext VictoryRoadGateEightBadgesText / waitbutton / closetext
setscene SCENE_VICTORYROADGATE_NOOP
end
```

`readvar VAR_BADGES` is a **popcount of the Johto badge byte**, not a badge
index. `setscene SCENE_VICTORYROADGATE_NOOP` (1) permanently disarms the coord
event once you pass. The two black belts are hidden until
`EVENT_OPENED_MT_SILVER` / `EVENT_FOUGHT_SNORLAX`
(`constants/event_flags.asm:1265`, `:1266`), so on a first pass neither is
present.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| New Bark Town -> Route 27 crossing | `engine/events/overworld.asm` `TrySurfOW` (`ld de, ENGINE_FOGBADGE` / `ld d, SURF` / `CheckPartyMove`) | SURF in the party **and** FOGBADGE | Beat Morty (section 07) |
| Route 27 east-half water (Blake onward, Rare Candy) | same `TrySurfOW` | SURF + FOGBADGE | as above |
| Tohjo Falls falls | `engine/events/overworld.asm` `TryWaterfallOW` (`ld d, WATERFALL` / `CheckPartyMove` then `ld de, ENGINE_RISINGBADGE` / `CheckEngineFlag`) plus `CheckMapCanWaterfall` (must face UP and the tile above must pass `CheckWaterfallTile`, `home/map_objects.asm:185`, i.e. `COLL_WATERFALL` $33 or `COLL_CURRENT_DOWN` $3b) | WATERFALL + RISINGBADGE | Beat Clair (section 13) |
| Route 27 whirlpool (island with TM22 + Jose) | `engine/events/overworld.asm` `TryWhirlpoolOW` (`ld d, WHIRLPOOL` / `CheckPartyMove`, then `ld de, ENGINE_GLACIERBADGE` / `CheckEngineFlag`, then `TryWhirlpoolMenu`) | WHIRLPOOL + GLACIERBADGE | Beat Pryce (section 11) |
| Master Ball from Elm | `maps/ElmsLab.asm` `ElmCheckMasterBall` -> `checkflag ENGINE_RISINGBADGE` | RISINGBADGE set, `EVENT_GOT_MASTER_BALL_FROM_ELM` clear, and a free bag slot (`verbosegiveitem` `iffalse`) | Beat Clair |
| Everstone from Elm | `maps/ElmsLab.asm` `ElmCheckEverstone` -> `EVENT_SHOWED_TOGEPI_TO_ELM`, otherwise `setval TOGEPI` / `special FindPartyMonThatSpeciesYourTrainerID` (and `TOGETIC`), gated on `EVENT_TOLD_ELM_ABOUT_TOGEPI_OVER_THE_PHONE` | Togepi or Togetic **in the party**, hatched by you (OT check) | Withdraw it from the PC before talking |
| TM37 SANDSTORM | `maps/Route27SandstormHouse.asm` `SandstormHouseWoman` -> `special GetFirstPokemonHappiness` / `ifgreater 150 - 1` | first non-egg party member's happiness >= 150 | Walk/level/haircut the lead mon |
| Victory Road Gate | `maps/VictoryRoadGate.asm` `_VictoryRoadGateBadgeCheckScript` -> `readvar VAR_BADGES` / `ifgreater NUM_JOHTO_BADGES - 1` | all eight Johto badges | Fails soft: you get pushed one step DOWN by `VictoryRoadGateStepDownMovement`, the gate is not warp-locked |
| Route 45 / 46 Dark Cave side trips | plain warps, no check | - | none; the Dark Cave interior gates are section 15's |

Nothing on Routes 45, 46 or 26 is gated by an `EVENT_*` or a badge. Route 27 is
the only map in this section where a field move blocks forward progress.

---

## 4. Bot checklist

Preconditions for the whole section: eight Johto badges, SURF + WATERFALL +
WHIRLPOOL in the party, at least a few free bag slots.

Route 45 (entered from Blackthorn's south edge):

1. `MAP_ROUTE_45` - walk south from the north connection. Optional: warp 1 at
   (2, 5) into Dark Cave Blackthorn Entrance.
2. Item ball `ROUTE45_POKE_BALL3` at (4, 21) -> ELIXER. Post: `EVENT_ROUTE_45_ELIXER`.
3. Trainer `ROUTE45_POKEFAN_M3` at (5, 28), sight 3 -> Hiker Parry (`PARRY3`,
   29 ONIX). Post: `EVENT_BEAT_HIKER_PARRY`. Talk again twice for
   `PHONE_HIKER_PARRY`.
4. Trainer `ROUTE45_POKEFAN_M1` at (10, 16), sight 1 -> Hiker Erik.
   Post: `EVENT_BEAT_HIKER_ERIK`.
5. Trainer `ROUTE45_COOLTRAINER_M` at (17, 18), sight 1 -> Cooltrainer Ryan.
   Post: `EVENT_BEAT_COOLTRAINERM_RYAN`.
6. Item ball `ROUTE45_POKE_BALL4` at (8, 33) -> MAX_POTION.
   Post: `EVENT_ROUTE_45_MAX_POTION`.
7. Trainer `ROUTE45_COOLTRAINER_F` at (4, 36), sight 3 -> Cooltrainer Kelly.
   Post: `EVENT_BEAT_COOLTRAINERF_KELLY`.
8. Trainer `ROUTE45_BLACK_BELT` at (11, 50), sight 2, spins -> Blackbelt Kenji.
   Post: `EVENT_BEAT_BLACKBELT_KENJI`. Second talk sets
   `EVENT_KENJI_ASKED_FOR_PHONE_NUMBER` and offers `PHONE_BLACKBELT_KENJI`.
9. Item ball `ROUTE45_POKE_BALL1` at (6, 51) -> X_SPECIAL.
   Post: `EVENT_ROUTE_45_X_SPECIAL`.
10. Trainer `ROUTE45_POKEFAN_M4` at (9, 64), sight 1 -> Hiker Timothy.
    Post: `EVENT_BEAT_HIKER_TIMOTHY`.
11. Trainer `ROUTE45_POKEFAN_M2` at (15, 64), sight 2 -> Hiker Michael.
    Post: `EVENT_BEAT_HIKER_MICHAEL`. (The walkthrough never names him.)
12. Item ball `ROUTE45_POKE_BALL2` at (6, 66) -> REVIVE.
    Post: `EVENT_ROUTE_45_REVIVE`.
13. Hidden item: face the bg event at (13, 80), press A -> PP_UP.
    Post: `EVENT_ROUTE_45_HIDDEN_PP_UP`.
14. Fruit tree `ROUTE45_FRUIT_TREE` at (16, 82) -> MYSTERYBERRY (daily).
15. Cross the west connection into `MAP_ROUTE_46` (block offset 36).

Route 46:

16. Trainer `ROUTE46_POKEFAN_M` at (12, 18), sight 2 -> Hiker Bailey (five
    13 GEODUDE). Post: `EVENT_BEAT_HIKER_BAILEY`.
17. Trainer `ROUTE46_YOUNGSTER` at (3, 13), sight 4 -> Camper Ted.
    Post: `EVENT_BEAT_CAMPER_TED`.
18. Item ball `ROUTE46_POKE_BALL` at (0, 12) -> DIRE_HIT.
    Post: `EVENT_ROUTE_46_DIRE_HIT`.
19. Trainer `ROUTE46_LASS` at (1, 15), sight 4 -> Picnicker Erin.
    Post: `EVENT_BEAT_PICNICKER_ERIN`. Second talk offers `PHONE_PICNICKER_ERIN`.
20. Fruit trees at (7, 5) -> BERRY and (8, 6) -> PRZCUREBERRY (daily).
21. Optional warp 3 at (14, 5) -> Dark Cave Violet Entrance.
22. Exit south via warps 1/2 at (7, 33) / (8, 33) into
    `MAP_ROUTE_29_ROUTE_46_GATE`, or the south connection to Route 29.

New Bark Town:

23. FLY to `MAP_NEW_BARK_TOWN`; warp 1 at (6, 3) -> `MAP_ELMS_LAB`.
24. Talk to `ELMSLAB_ELM` at (5, 2). Pre: `ENGINE_RISINGBADGE` set,
    `EVENT_GOT_MASTER_BALL_FROM_ELM` clear, free bag slot.
    Post: `EVENT_GOT_MASTER_BALL_FROM_ELM`, MASTER_BALL in bag.
25. Withdraw Togepi/Togetic into the party at a PC, return to Elm, talk again.
    Post: `EVENT_SHOWED_TOGEPI_TO_ELM`, `EVENT_GOT_EVERSTONE_FROM_ELM`,
    EVERSTONE in bag.
26. Optional: `MAP_PLAYERS_HOUSE_1F` warp 2 at (13, 5), talk to Mom ->
    `MomScript.BankOfMom` -> `special BankOfMom` to withdraw savings.
27. Leave New Bark Town east; the connection to `MAP_ROUTE_27` is water. Use
    SURF (FOGBADGE required).

Route 27, first pass:

28. Walking onto cell (18, 10) or (19, 10) fires the coord event
    `FirstStepIntoKantoLeftScene` / `...RightScene`. It is unskippable; wait it
    out. Post: map scene = `SCENE_ROUTE27_NOOP`.
29. Optional: item ball `ROUTE27_POKE_BALL2` at (53, 12) -> RARE_CANDY, in the
    southern water. Post: `EVENT_ROUTE_27_RARE_CANDY`. (See section 6 - the
    walkthrough puts this before Tohjo Falls; the coordinate is well east of
    the west cave mouth.)
30. Warp 2 at (26, 5) -> `MAP_TOHJO_FALLS` warp 1.

Tohjo Falls:

31. Surf west, use WATERFALL facing UP where the tile above is `COLL_WATERFALL`.
    Requires RISINGBADGE.
32. Item ball `TOHJOFALLS_POKE_BALL` at (2, 6) -> MOON_STONE.
    Post: `EVENT_TOHJO_FALLS_MOON_STONE`.
33. Exit via warp 2 at (25, 15) -> `MAP_ROUTE_27` warp 3 (36, 5).

Route 27, second pass:

34. Trainer `ROUTE27_COOLTRAINER_F2` at (37, 6), sight 2, spins -> Cooltrainer
    Megan. Post: `EVENT_BEAT_COOLTRAINERF_MEGAN`.
35. Warp 1 at (33, 7) -> `MAP_ROUTE_27_SANDSTORM_HOUSE`. Talk to
    `ROUTE27SANDSTORMHOUSE_GRANNY` at (2, 4). Pre: lead party mon happiness
    >= 150 and a free bag slot. Post: `EVENT_GOT_TM37_SANDSTORM`, TM37 in bag.
36. Surf east. Trainer `ROUTE27_COOLTRAINER_M1` at (49, 7), sight 3 ->
    Cooltrainer Blake. Post: `EVENT_BEAT_COOLTRAINERM_BLAKE`.
37. Trainer `ROUTE27_COOLTRAINER_M2` at (58, 6), sight 5 -> Cooltrainer Brian.
    Post: `EVENT_BEAT_COOLTRAINERM_BRIAN`.
38. Trainer `ROUTE27_YOUNGSTER1` at (64, 7), sight 5 -> Psychic Gilbert.
    Post: `EVENT_BEAT_PSYCHIC_GILBERT`.
39. Surf south, use WHIRLPOOL on the whirlpool block (GLACIERBADGE required).
40. Trainer `ROUTE27_YOUNGSTER2` at (58, 13), sight 3 -> Bird Keeper Jose.
    Post: `EVENT_BEAT_BIRD_KEEPER_JOSE2`. Second talk offers
    `PHONE_BIRDKEEPER_JOSE`.
41. Item ball `ROUTE27_POKE_BALL1` at (60, 12) -> TM_SOLARBEAM.
    Post: `EVENT_ROUTE_27_TM_SOLARBEAM`.
42. Trainer `ROUTE27_COOLTRAINER_F1` at (72, 11), sight 5 -> Cooltrainer Reena.
    Post: `EVENT_BEAT_COOLTRAINERF_REENA`. Second talk offers
    `PHONE_COOLTRAINERF_REENA`.
43. East connection into `MAP_ROUTE_26` (block offset -45).

Route 26 (walk north, y decreasing):

44. Trainer `ROUTE26_FISHER` at (10, 92), sight 3 -> Fisher Scott.
    Post: `EVENT_BEAT_FISHER_SCOTT`.
45. Trainer `ROUTE26_YOUNGSTER` at (13, 79), sight 4 -> Psychic Richard.
    Post: `EVENT_BEAT_PSYCHIC_RICHARD`.
46. Optional: warp 3 at (5, 71) -> `MAP_DAY_OF_WEEK_SIBLINGS_HOUSE`, read the
    `SPRITE_POKEDEX` object at (3, 3) for Monica's roster. No flags.
47. Warp 2 at (15, 57) -> `MAP_ROUTE_26_HEAL_HOUSE`, talk to
    `ROUTE26HEALHOUSE_TEACHER` at (2, 3) for a free full heal. Repeatable, no
    flag.
48. Trainer `ROUTE26_COOLTRAINER_F1` at (10, 56), sight 3, spins -> Cooltrainer
    Joyce. Post: `EVENT_BEAT_COOLTRAINERF_JOYCE`.
49. Fruit tree `ROUTE26_FRUIT_TREE` at (14, 54) -> ICE_BERRY (daily).
50. Trainer `ROUTE26_COOLTRAINER_M2` at (9, 38), sight 5 -> Cooltrainer Gaven.
    Post: `EVENT_BEAT_COOLTRAINERM_GAVEN`. Second talk offers
    `PHONE_COOLTRAINERM_GAVEN`.
51. Trainer `ROUTE26_COOLTRAINER_M1` at (11, 16), sight 2 -> Cooltrainer Jake.
    Post: `EVENT_BEAT_COOLTRAINERM_JAKE`.
52. Item ball `ROUTE26_POKE_BALL` at (9, 15) -> MAX_ELIXER.
    Post: `EVENT_ROUTE_26_MAX_ELIXER`.
53. Trainer `ROUTE26_COOLTRAINER_F2` at (5, 8), sight 4 -> Cooltrainer Beth.
    Post: `EVENT_BEAT_COOLTRAINERF_BETH`. Second talk offers
    `PHONE_COOLTRAINERF_BETH`.
54. Warp 1 at (7, 5) -> `MAP_VICTORY_ROAD_GATE` warp 3.
55. In the gate, step onto (10, 11). Pre: `VAR_BADGES` >= 8. On pass the map
    scene becomes `SCENE_VICTORYROADGATE_NOOP` and warps 5/6 at (9, 0) /
    (10, 0) lead into `MAP_VICTORY_ROAD` (section 17).

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map blocks, warps, coord events, bg events, object events for every map here | `src/import/RomExtractorGen2.lua:787-980` (`warps` / `coordEvents` / `bgEvents` / `objects` readers), `src/world/gen2/Map.lua`, `src/world/gen2/World.lua:5013` (coord events), `:5257` (`World:interact`) | implemented, data-driven - nothing per-map is hand-written, so these routes come for free once the ROM is imported |
| Map connections (Blackthorn -> R45 -> R46, New Bark -> R27 -> R26) | `src/world/gen2/World.lua:407-430` | implemented |
| Overworld trainer struct, eyesight, battle, beat flag | `src/world/gen2/Trainers.lua`, `src/import/RomExtractorGen2.lua:2963-2968` (reads `OBJECTTYPE_TRAINER` headers), driver `tests/drivers/gold_trainer_smoke.lua` | implemented |
| Trainer parties incl. `TRAINERTYPE_MOVES` rows (Timothy, Ryan, Blake, Brian, Joyce, Gaven, Jake, Beth, Megan) | `src/world/gen2/Trainers.lua` party build over the extracted trainer table | implemented |
| Phone registration + rematch flags for Kenji, Parry, Erin, Jose, Reena, Gaven, Beth | `src/core/gen2/Phone.lua:427-455` (`Phone.REMATCH_EVENTS`, contacts 11/12/13/14/34/35/36 present) | implemented |
| `askforphonenumber` / `checkcellnum` opcodes | `src/script/gen2/Opcodes.lua:156`, `:47` | implemented |
| Fruit trees (Mystery Berry, Berry, PrzCure Berry, Ice Berry) | `src/script/gen2/Opcodes.lua:160` (`fruittree`), `src/core/gen2/Apricorns.lua:351-460` (item lookup, picked flag, daily reset) | implemented |
| Hidden item PP UP at Route 45 (13, 80) | `src/world/gen2/HiddenItems.lua`, consumed at `src/world/gen2/World.lua:5285` | implemented |
| **Item ball pickup** (all nine `OBJECTTYPE_ITEMBALL` objects in this section) | extractor stores `obj.itemball` (`src/import/RomExtractorGen2.lua:2968`) but nothing in `src/world/` reads it - `World:interact` only dispatches on `npc.def.trainer`, strength boulders, `npc.def.scriptKey` and `HiddenItems` | **missing** - walking up to a Poke Ball object and pressing A does nothing. This blocks ELIXER, MAX_POTION, X_SPECIAL, REVIVE, DIRE_HIT, RARE_CANDY, TM_SOLARBEAM, MOON_STONE, MAX_ELIXER |
| SURF gate (FOGBADGE) for the New Bark -> Route 27 crossing | `src/world/gen2/FieldMoves.lua:103-110` (`FieldMoves.BADGE.SURF = "FOG"`), driver `tests/drivers/gold_water_moves.lua` | implemented |
| WHIRLPOOL gate (GLACIERBADGE) + block replacement for the Route 27 island | `src/world/gen2/FieldMoves.lua:219-251`, `World:tryWhirlpoolOW`, driver `tests/drivers/gold_water_moves.lua` | implemented |
| WATERFALL climb (RISINGBADGE) in Tohjo Falls | `src/world/gen2/FieldMoves.lua:258-266`, `src/world/gen2/World.lua:4037-4046` (`runWaterfall` / `waterfallStep`), `:4217` (`tryWaterfallOW`), `src/world/gen2/Permissions.lua:136` (`COLL_WATERFALL` $33 + `COLL_CURRENT_DOWN` $3b) | implemented; **no driver** covers it (`gold_water_moves.lua` is SURF + WHIRLPOOL only) |
| Route 27 "first step into Kanto" coord event + scene | `src/world/gen2/World.lua:5013` (coord event scan), `:1161-1183` (`World:scene`), `src/script/gen2/Opcodes.lua:25` (`setscene`), `:122-123` (`showemote`, `turnobject`), `:110` (`applymovement`) | implemented |
| Pokegear region flip to Kanto after that scene | `src/ui/gen2/Pokegear.lua:1070`, `:1658` (region follows the player's landmark, `cp KANTO_LANDMARK`) | implemented |
| Sandstorm house happiness check | `src/script/gen2/Specials.lua:1506` (`GetFirstPokemonHappiness`), `src/script/gen2/Opcodes.lua:163` (`verbosegiveitem`), `src/core/gen2/Happiness.lua` | implemented |
| Route 26 heal house | `src/script/gen2/Specials.lua:450` (`HealParty`), `:999` (`FadeOutToBlack`), `:1025` (`ReloadSpritesNoPalettes`), `:1059` (`RestartMapMusic`) | implemented |
| Elm Master Ball / Everstone (`checkflag ENGINE_RISINGBADGE`, `FindPartyMonThatSpeciesYourTrainerID`) | `src/script/gen2/Specials.lua:1134`, `src/script/gen2/Opcodes.lua:163` | implemented |
| Mom's savings (`special BankOfMom`) | `src/ui/gen2/BankOfMom.lua` | implemented |
| Victory Road gate badge check (`readvar VAR_BADGES`) | `src/world/gen2/World.lua:117` (`VAR_BADGES = 0x07`), `:1240` (popcount read) | implemented |
| Roaming beasts on Routes 45/46 | `src/core/gen2/Roamers.lua`, driver `tests/drivers/gold_roamers.lua` | implemented |
| Wild encounter tables (grass morn/day/nite, water, fish, treemons) | `src/battle/gen2/Encounter.lua` over the extracted encounter tables | implemented |

---

## 6. Unresolved / verify by hand

1. **"Camper Quentin" does not exist in pokegold.** The walkthrough puts a
   Camper Quentin on Route 45 with 27 FEAROW / 30 PRIMEAPE / 30 TAUROS. There
   is no `QUENTIN` constant anywhere in the checkout
   (`grep -rn QUENTIN /Users/bryanbassett/Documents/development/pokegold` is
   empty), no camper object on `maps/Route45.asm`, and the only TAUROS line in
   `data/trainers/parties.asm` is a level 35 one in `CooltrainerMGroup` "SEAN".
   The Route 45 trainer the walkthrough is probably confusing this with is
   Hiker Michael (25 GEODUDE / 25 GRAVELER / 25 GOLEM), whom it never mentions.
2. **"A Revive and a Nugget" on Route 45.** There is no NUGGET on Route 45.
   The four item balls are X_SPECIAL, REVIVE, ELIXER and MAX_POTION, and the
   only hidden item is `hiddenitem PP_UP, EVENT_ROUTE_45_HIDDEN_PP_UP` at
   (13, 80). Treat "Nugget" as an error and pick up the PP UP instead.
3. **Route 27 Rare Candy placement.** The walkthrough says to surf "southeast
   of the cave entrance" *before* entering Tohjo Falls. The item ball is at
   cell (53, 12), which is east of the *eastern* Tohjo exit (36, 5) and far
   east of the western entrance (26, 5). Whether the southern water is
   continuous from the landing point (~x 18-21) all the way to x 53 was not
   verified - it would need reading `maps/Route27.blk` against the
   `TILESET_JOHTO` collision table. A bot should simply grab it on the way to
   Blake rather than trusting the stated ordering.
4. **Cooltrainer Gaven's second mon.** The walkthrough says Krabby; the asm
   says `db 32, KINGLER` in `CooltrainerMGroup` entry 10.
5. **Cooltrainer Reena's party order.** Walkthrough: STARMIE, STARMIE,
   NIDOQUEEN. Asm (`CooltrainerFGroup` entry 10): 31 STARMIE, 33 NIDOQUEEN,
   31 STARMIE.
6. **Hiker Erik's party order.** Walkthrough: Machop, Machop, Graveler. Asm
   (`HikerGroup` entry 7): 24 MACHOP, 27 GRAVELER, 27 MACHOP.
7. **Wild lists are incomplete in the walkthrough.** Route 46 also has
   JIGGLYPUFF (3 and 5); Tohjo Falls also has ZUBAT, GOLBAT, RATICATE and
   GOLDEEN; Route 26/27's ARBOK entries are Silver-only while SANDSLASH and
   DODRIO are the Gold slots. The walkthrough's per-route lists appear to be a
   Gold/Silver merge.
8. **Tohjo Falls MOON STONE is never mentioned.** `TohjoFallsMoonStone` at
   (2, 6) is the only object on the map.
9. **"Head down the other waterfall".** There is no downward WATERFALL move in
   the engine. Descending is a `COLL_CURRENT_DOWN` ($3b) tile that carries the
   surfing player; `CheckWaterfallTile` (`home/map_objects.asm:185`) accepts
   both `COLL_WATERFALL` and `COLL_CURRENT_DOWN` precisely so the climb loop
   keeps running. Whether the port's `World:waterfallStep` handles the descend
   direction as well as the climb was not verified.
10. **Kenji's phone number timing.** The walkthrough says "talk to him again
    and he will give you his phone number", which matches - but the asm needs
    *two* post-battle talks: the first sets
    `EVENT_KENJI_ASKED_FOR_PHONE_NUMBER` and runs `AskNumber1MScript`, and
    `askforphonenumber` only runs after that `scall` returns. Bots should
    budget two A-press cycles per phone trainer, not one.
11. The walkthrough's Route 45 "LEFT PATH ... Elixir ... one trainer (Hiker
    Parry)" reads as if the Elixir is inside Dark Cave. Both the Elixir
    (4, 21) and Parry (5, 28) are on Route 45 itself. There *is* a separate
    hidden Elixer inside Dark Cave (`maps/DarkCaveVioletEntrance.asm`
    `bg_event 26, 3, BGEVENT_ITEM, DarkCaveVioletEntranceHiddenElixer`), which
    belongs to section 15.

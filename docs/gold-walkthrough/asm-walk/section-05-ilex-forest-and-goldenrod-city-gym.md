# Section 05 - Ilex Forest and Goldenrod City Gym

Source: `../section-05-ilex-forest-and-goldenrod-city-gym.txt`

Maps covered: `AZALEA_TOWN` (west exit only), `ILEX_FOREST_AZALEA_GATE`,
`ILEX_FOREST`, `ROUTE_34_ILEX_FOREST_GATE`, `ROUTE_34`, `DAY_CARE`,
`GOLDENROD_CITY`, `GOLDENROD_POKECENTER_1F`, `GOLDENROD_DEPT_STORE_1F` ..
`GOLDENROD_DEPT_STORE_6F`, `BILLS_FAMILYS_HOUSE`,
`GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES`, `GOLDENROD_UNDERGROUND`,
`GOLDENROD_BIKE_SHOP`, `GOLDENROD_MAGNET_TRAIN_STATION`, `RADIO_TOWER_1F`,
`GOLDENROD_GAME_CORNER`, `GOLDENROD_GYM`.

Badges / key milestones in this section:

- Rival battle 2 (Azalea Town), `EVENT_RIVAL_AZALEA_TOWN`
- `HM_CUT` (HM01) from the charcoal master, `EVENT_GOT_HM01_CUT`
- `TM_HEADBUTT` (TM02), `TM_SWEET_SCENT` (TM12)
- `BICYCLE`, `COIN_CASE`, `ENGINE_RADIO_CARD`
- PLAINBADGE (`ENGINE_PLAINBADGE`) + `TM_ATTRACT` (TM45) from Whitney

Conventions used below are the ones in `_TEMPLATE.md`. Disassembly paths are
relative to the pokegold checkout root; port paths are relative to this repo
root. All coordinates are raw asm values (map coordinates, 2 per map block).

Note on `SCENE_*` names: pokegold has no `constants/map_scenes.asm`. The
`scene_script` macro (`macros/scripts/maps.asm`) defines each scene constant at
the point of use, so `SCENE_AZALEATOWN_RIVAL_BATTLE` is declared by
`maps/AzaleaTown.asm` itself.

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `AZALEA_TOWN` | `maps/AzaleaTown.asm` | out of `AZALEA_GYM` (warp 5 at 10,15) | warps 7/8 at (2,10)/(2,11) -> `ILEX_FOREST_AZALEA_GATE` 3/4 | heal, walk west, rival trip-wire at (5,10)/(5,11) |
| 2 | `ILEX_FOREST_AZALEA_GATE` | `maps/IlexForestAzaleaGate.asm` | warps 3/4 at (9,4)/(9,5) | warps 1/2 at (0,4)/(0,5) -> `ILEX_FOREST` 2/3 | gate house, two flavour NPCs |
| 3 | `ILEX_FOREST` | `maps/IlexForest.asm` | warps 2/3 at (3,42)/(3,43) | warp 1 at (1,5) -> `ROUTE_34_ILEX_FOREST_GATE` 3 | herd Farfetch'd, get HM01, cut the tree, TM02, Revive |
| 4 | `ROUTE_34_ILEX_FOREST_GATE` | `maps/Route34IlexForestGate.asm` | warps 3/4 at (4,7)/(5,7) | warps 1/2 at (4,0)/(5,0) -> `ROUTE_34` 1/2 | teacher hands over TM12 Sweet Scent |
| 5 | `ROUTE_34` | `maps/Route34.asm` | warps 1/2 at (13,37)/(14,37) | north map connection -> `GOLDENROD_CITY` (offset -5) | Samuel, Brandon, Ian, Gina, Keith, Todd; Day-Care |
| 6 | `DAY_CARE` | `maps/DayCare.asm` | `ROUTE_34` warps 3/4/5 at (11,14)/(11,15)/(13,15) | warps 1..4 back to `ROUTE_34` | deposit / breed, egg pickup |
| 7 | `GOLDENROD_CITY` | `maps/GoldenrodCity.asm` | south map connection from `ROUTE_34` (offset 5) | see the city's 15 warps | hub for everything below |
| 8 | `GOLDENROD_POKECENTER_1F` | `maps/GoldenrodPokecenter1F.asm` | city warp 7 at (15,27) | warps 1/2 at (3,7)/(4,7) | heal |
| 9 | `GOLDENROD_DEPT_STORE_1F`..`6F` | `maps/GoldenrodDeptStore1F.asm` .. `6F.asm` | city warp 10 at (24,27) | stairs / elevator | shopping, Sunday TM lady on 5F |
| 10 | `BILLS_FAMILYS_HOUSE` | `maps/BillsFamilysHouse.asm` | city warp 4 at (5,25) | warps 1/2 at (2,7)/(3,7) | Bill's phone number from the younger sister |
| 11 | `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` | `maps/GoldenrodUndergroundSwitchRoomEntrances.asm` | city warp 15 at (11,29) -> warp 5 at (4,29) | warp 4 at (5,25) -> `GOLDENROD_UNDERGROUND` 2 | the "house below Bill's" is the south underground stair |
| 12 | `GOLDENROD_UNDERGROUND` | `maps/GoldenrodUnderground.asm` | warp 2 at (3,34) | warp 1 at (3,2) -> switch-room warp 7 at (21,25) | Eric, Issac, Coin Case, salon, Teru, Donald, locked basement door |
| 13 | `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` (north half) | as above | warp 7 at (21,25) | warps 8/9 at (20,29)/(21,29) -> `GOLDENROD_CITY` 14 at (9,5) | come back up on the north side of town |
| 14 | `GOLDENROD_BIKE_SHOP` | `maps/GoldenrodBikeShop.asm` | city warp 2 at (29,29) | warps 1/2 at (2,7)/(3,7) | borrow the `BICYCLE` |
| 15 | `GOLDENROD_MAGNET_TRAIN_STATION` | `maps/GoldenrodMagnetTrainStation.asm` | city warp 5 at (9,13) | warps 1/2 at (8,17)/(9,17) | conductor flavour text, no train yet |
| 16 | `RADIO_TOWER_1F` | `maps/RadioTower1F.asm` | city warp 12 at (5,15) | warps 1/2 at (2,7)/(3,7) | Lucky Number man + Radio Card quiz |
| 17 | `GOLDENROD_GAME_CORNER` | `maps/GoldenrodGameCorner.asm` | city warp 11 at (14,21) | warps 1/2 at (2,13)/(3,13) | slots, prize corner (needs `COIN_CASE`) |
| 18 | `GOLDENROD_GYM` | `maps/GoldenrodGym.asm` | city warp 1 at (24,7) | warps 1/2 at (2,17)/(3,17) | Victoria, Samantha, Carrie, Bridget, Whitney |

Spills into the next section: after PLAINBADGE the walkthrough's next hop is
north out of Goldenrod through `ROUTE_35_GOLDENROD_GATE` (city warp 13 at
(19,1)); that map and Route 35 belong to the following section.

---

## 2. Maps

### MAP_AZALEA_TOWN (west exit / rival battle only)

- Script: `maps/AzaleaTown.asm`
- Blocks: `maps/AzaleaTown.blk`
- Header: `data/maps/maps.asm:232` -> `TILESET_JOHTO_MODERN, TOWN, LANDMARK_AZALEA_TOWN, MUSIC_AZALEA_TOWN, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:213` -> `map_const AZALEA_TOWN, 20, 9`
- Connections (`data/maps/attributes.asm:132`): west `Route34` (offset -18), east `Route33` (offset 0)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 15 | 9 | `AZALEA_POKECENTER_1F` | 1 |
| 2 | 21 | 13 | `CHARCOAL_KILN` | 1 |
| 3 | 21 | 5 | `AZALEA_MART` | 2 |
| 4 | 9 | 5 | `KURTS_HOUSE` | 1 |
| 5 | 10 | 15 | `AZALEA_GYM` | 1 |
| 6 | 31 | 7 | `SLOWPOKE_WELL_B1F` | 1 |
| 7 | 2 | 10 | `ILEX_FOREST_AZALEA_GATE` | 3 |
| 8 | 2 | 11 | `ILEX_FOREST_AZALEA_GATE` | 4 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_AZALEATOWN_RIVAL_BATTLE` | 5 | 10 | `AzaleaTownRivalBattleScene1` | rival is teleported to (11,11) first, then walks 6 left |
| `SCENE_AZALEATOWN_RIVAL_BATTLE` | 5 | 11 | `AzaleaTownRivalBattleScene2` | rival walks 6 left from his placed position |

**BG events** (`def_bg_events`) - the ones on the west path

| x | y | type | script/item |
|---|---|---|---|
| 3 | 9 | `BGEVENT_READ` | `AzaleaTownIlextForestSign` |
| 31 | 6 | `BGEVENT_ITEM` | `AzaleaTownHiddenFullHeal` (`FULL_HEAL`, `EVENT_AZALEA_TOWN_HIDDEN_FULL_HEAL`) |

(The other seven bg events - town sign, Kurt's house, gym, Slowpoke Well,
charcoal kiln, Pokecenter, mart - are listed verbatim in the asm and belong to
the previous section.)

**Object events** (`def_object_events`) - rival row only

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `AZALEATOWN_RIVAL` | `SPRITE_AZALEA_ROCKET` | 11 | 10 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_RIVAL_AZALEA_TOWN` |

`SPRITE_AZALEA_ROCKET` is remapped to `SPRITE_RIVAL` by
`variablesprite SPRITE_AZALEA_ROCKET, SPRITE_RIVAL` in
`maps/SlowpokeWellB1F.asm` (line 59), so the object draws as the rival.

**Scripts of interest**

- `AzaleaTownRivalBattleScene1` / `AzaleaTownRivalBattleScene2` ->
  `AzaleaTownRivalBattleScript`: `playmusic MUSIC_RIVAL_ENCOUNTER`, before-text,
  `setevent EVENT_RIVAL_AZALEA_TOWN`, then branches on the starter:
  `checkevent EVENT_GOT_TOTODILE_FROM_ELM` -> `loadtrainer RIVAL1, RIVAL1_2_CHIKORITA`;
  `checkevent EVENT_GOT_CHIKORITA_FROM_ELM` -> `RIVAL1_2_CYNDAQUIL`;
  otherwise (player took Cyndaquil) -> `RIVAL1_2_TOTODILE`.
  `winlosstext AzaleaTownRivalWinText, AzaleaTownRivalLossText`,
  `setlasttalked AZALEATOWN_RIVAL`, `startbattle`, `reloadmapafterbattle`.
- `.AfterBattle`: `MUSIC_RIVAL_AFTER`, after-text, rival walks 3 left,
  `disappear AZALEATOWN_RIVAL`, `setscene SCENE_AZALEATOWN_NOOP`.
- Arming: `maps/SlowpokeWellB1F.asm` (the Slowpoke Well clear scene) runs
  `setevent EVENT_CLEARED_SLOWPOKE_WELL`,
  `setmapscene AZALEA_TOWN, SCENE_AZALEATOWN_RIVAL_BATTLE`,
  `clearevent EVENT_ILEX_FOREST_APPRENTICE`,
  `clearevent EVENT_ILEX_FOREST_FARFETCHD_1`,
  `setevent EVENT_CHARCOAL_KILN_FARFETCH_D`,
  `setevent EVENT_CHARCOAL_KILN_APPRENTICE`. So the Ilex Forest Farfetch'd quest
  and the Azalea rival battle are both armed by clearing Slowpoke Well, not by
  the Hive Badge.
- `AzaleaTownFlypointCallback` (`MAPCALLBACK_NEWMAP`): `setflag ENGINE_FLYPOINT_AZALEA`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `SCENE_AZALEATOWN_RIVAL_BATTLE` | `maps/AzaleaTown.asm:17` (`scene_script`) | set by `maps/SlowpokeWellB1F.asm:58`, cleared to `SCENE_AZALEATOWN_NOOP` by `.AfterBattle` | trip-wire armed / disarmed |
| `EVENT_RIVAL_AZALEA_TOWN` | `constants/event_flags.asm:1121` | set by `AzaleaTownRivalBattleScript` | also the rival object's spawn flag |
| `EVENT_CLEARED_SLOWPOKE_WELL` | `constants/event_flags.asm` | read by `AzaleaTownGrampsScript` | prerequisite for this whole section |
| `ENGINE_FLYPOINT_AZALEA` | `constants/engine_flags.asm:82` | `AzaleaTownFlypointCallback` | Fly destination unlocked |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `RIVAL1` | `RIVAL1` | `RIVAL1_2_CHIKORITA` / `_CYNDAQUIL` / `_TOTODILE` (`constants/trainer_constants.asm:55-57`) | `Rival1Group` entries 4/5/6: L12 Gastly, L14 Zubat, L16 Bayleef / Quilava / Croconaw | `AzaleaTownRivalBattleScript` | none |

Note the asm order is Gastly, Zubat, starter; the walkthrough prints Gastly,
starter, Zubat. Trust the asm.

---

### MAP_ILEX_FOREST_AZALEA_GATE

- Script: `maps/IlexForestAzaleaGate.asm`
- Blocks: none (`maps/IlexForestAzaleaGate.blk` is absent; gate uses the shared gate blockset)
- Header: `data/maps/maps.asm:287` -> `TILESET_GATE, GATE, LANDMARK_ROUTE_34, MUSIC_ROUTE_36, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:265` -> `map_const ILEX_FOREST_AZALEA_GATE, 5, 4`
- Connections: none (indoor gate)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 4 | `ILEX_FOREST` | 2 |
| 2 | 0 | 5 | `ILEX_FOREST` | 3 |
| 3 | 9 | 4 | `AZALEA_TOWN` | 7 |
| 4 | 9 | 5 | `AZALEA_TOWN` | 8 |

**Coord events**: none. **BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ILEXFORESTAZALEAGATE_OFFICER` | `SPRITE_OFFICER` | 5 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `IlexForestAzaleaGateOfficerScript` | -1 |
| `ILEXFORESTAZALEAGATE_GRANNY` | `SPRITE_GRANNY` | 1 | 3 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `IlexForestAzaleaGateGrannyScript` | -1 |

Both are `jumptextfaceplayer` only. No gate guard, no badge check.

---

### MAP_ILEX_FOREST

- Script: `maps/IlexForest.asm`
- Blocks: `maps/IlexForest.blk` (405 bytes = 15 x 27)
- Header: `data/maps/maps.asm:122` -> `TILESET_FOREST, CAVE, LANDMARK_ILEX_FOREST, MUSIC_UNION_CAVE, FALSE, PALETTE_NITE, FISHGROUP_POND`
- Dimensions: `constants/map_constants.asm:109` -> `map_const ILEX_FOREST, 15, 27`
- Connections: none (`data/maps/attributes.asm:441` has no `connection` rows)
- Environment is `CAVE` and palette is `PALETTE_NITE`, so it renders dark all day; it is *not* a Flash map (no `EVENT_...FLASH` requirement anywhere in the file).

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 1 | 5 | `ROUTE_34_ILEX_FOREST_GATE` | 3 |
| 2 | 3 | 42 | `ILEX_FOREST_AZALEA_GATE` | 1 |
| 3 | 3 | 43 | `ILEX_FOREST_AZALEA_GATE` | 2 |

**Coord events**: `def_coord_events` is empty. The Farfetch'd chase is driven
entirely by talking to the object, not by stepping on tiles.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 3 | 17 | `BGEVENT_READ` | `IlexForestSignpost` |
| 27 | 1 | `BGEVENT_ITEM` | `IlexForestHiddenEther` -> `hiddenitem ETHER, EVENT_ILEX_FOREST_HIDDEN_ETHER` |
| 17 | 7 | `BGEVENT_ITEM` | `IlexForestHiddenSuperPotion` -> `hiddenitem SUPER_POTION, EVENT_ILEX_FOREST_HIDDEN_SUPER_POTION` |
| 9 | 17 | `BGEVENT_ITEM` | `IlexForestHiddenFullHeal` -> `hiddenitem FULL_HEAL, EVENT_ILEX_FOREST_HIDDEN_FULL_HEAL` |
| 8 | 22 | `BGEVENT_READ` | `IlexForestShrineScript` (the shrine the walkthrough calls "Ilex Forest Shrine") |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ILEXFOREST_FARFETCHD1` | `SPRITE_BIRD` | 14 | 31 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `FarfetchdPosition1` | `EVENT_ILEX_FOREST_FARFETCHD_1` |
| `ILEXFOREST_FARFETCHD2` | `SPRITE_BIRD` | 15 | 25 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `FarfetchdPosition2` | `EVENT_ILEX_FOREST_FARFETCHD_2` |
| `ILEXFOREST_FARFETCHD3` | `SPRITE_BIRD` | 20 | 24 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `FarfetchdPosition3` | `EVENT_ILEX_FOREST_FARFETCHD_3` |
| `ILEXFOREST_FARFETCHD4` | `SPRITE_BIRD` | 29 | 22 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `FarfetchdPosition4` | `EVENT_ILEX_FOREST_FARFETCHD_4` |
| `ILEXFOREST_FARFETCHD5` | `SPRITE_BIRD` | 28 | 31 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `FarfetchdPosition5` | `EVENT_ILEX_FOREST_FARFETCHD_5` |
| `ILEXFOREST_FARFETCHD6` | `SPRITE_BIRD` | 24 | 35 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `FarfetchdPosition6` | `EVENT_ILEX_FOREST_FARFETCHD_6` |
| `ILEXFOREST_FARFETCHD7` | `SPRITE_BIRD` | 22 | 31 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `FarfetchdPosition7` | `EVENT_ILEX_FOREST_FARFETCHD_7` |
| `ILEXFOREST_FARFETCHD8` | `SPRITE_BIRD` | 15 | 29 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `FarfetchdPosition8` | `EVENT_ILEX_FOREST_FARFETCHD_8` |
| `ILEXFOREST_FARFETCHD9` | `SPRITE_BIRD` | 10 | 35 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `FarfetchdPosition9` | `EVENT_ILEX_FOREST_FARFETCHD_9` |
| `ILEXFOREST_FARFETCHD10` | `SPRITE_BIRD` | 6 | 28 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `FarfetchdPosition10` | `EVENT_ILEX_FOREST_FARFETCHD_10` |
| `ILEXFOREST_YOUNGSTER` | `SPRITE_YOUNGSTER` | 7 | 28 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `IlexForestCharcoalApprenticeScript` | `EVENT_ILEX_FOREST_APPRENTICE` |
| `ILEXFOREST_BLACK_BELT` | `SPRITE_BLACK_BELT` | 5 | 28 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `IlexForestCharcoalMasterScript` | `EVENT_ILEX_FOREST_CHARCOAL_MASTER` |
| `ILEXFOREST_ROCKER` | `SPRITE_ROCKER` | 15 | 14 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `IlexForestHeadbuttGuyScript` | -1 |
| `ILEXFOREST_POKE_BALL` | `SPRITE_POKE_BALL` | 20 | 32 | `STILL` | `OBJECTTYPE_ITEMBALL` | `IlexForestRevive` (`itemball REVIVE`) | `EVENT_ILEX_FOREST_REVIVE` |

**Scripts of interest**

- `IlexForestCharcoalApprenticeScript` (object at 7,28): `checkevent EVENT_HERDED_FARFETCHD`
  picks the "please help" text vs the "thanks" text. Pure text, sets nothing.
- `FarfetchdPosition1`: no facing check. Talk once and it always runs
  `applymovement ILEXFOREST_FARFETCHD1, MovementData_Farfetchd_Pos1_Pos2`,
  `appear ILEXFOREST_FARFETCHD2`, `disappear ILEXFOREST_FARFETCHD1`.
- `FarfetchdPosition2`..`9`: each `scall FarfetchdCryAndCheckFacing`, which does
  `faceplayer` / cry / `readvar VAR_FACING`, then `ifequal <DIR>, ...` on the
  *player's* facing to decide which way the bird flees. The forward chain is the
  fall-through branch of each; the listed `ifequal` directions send it backwards.
  Concretely (fall-through = progress):
  - Pos2 -> Pos3, except facing `DOWN` -> Pos8
  - Pos3 -> Pos4, except `LEFT` -> Pos2
  - Pos4 -> Pos5, except `UP` -> Pos3
  - Pos5 -> Pos6, except `LEFT` -> Pos7, `UP`/`RIGHT` -> Pos4
  - Pos6 -> Pos7, except `RIGHT` -> Pos5
  - Pos7 -> Pos8, except `LEFT` -> Pos6, `DOWN` -> Pos5
  - Pos8 -> Pos9, except `RIGHT` -> Pos7, `UP`/`LEFT` -> Pos2
  - Pos9 -> Pos10 (**terminal**), except `RIGHT`/`DOWN` -> Pos8
- `FarfetchdPosition9` fall-through additionally runs
  `appear 13 ; ILEXFOREST_BLACK_BELT`, `setevent EVENT_CHARCOAL_KILN_BOSS`,
  `setevent EVENT_HERDED_FARFETCHD`. That `appear 13` is a raw object index, not
  the const - worth mirroring exactly in a port.
- `IlexForestCharcoalMasterScript` (object at 5,28): `checkevent EVENT_GOT_HM01_CUT`,
  else `verbosegiveitem HM_CUT`, `setevent EVENT_GOT_HM01_CUT`, then
  `setevent EVENT_ILEX_FOREST_FARFETCHD_10`, `setevent EVENT_ILEX_FOREST_APPRENTICE`,
  `setevent EVENT_ILEX_FOREST_CHARCOAL_MASTER`,
  `clearevent EVENT_CHARCOAL_KILN_FARFETCH_D`, `clearevent EVENT_CHARCOAL_KILN_APPRENTICE`,
  `clearevent EVENT_CHARCOAL_KILN_BOSS` - i.e. the trio moves back to the
  Charcoal Kiln in Azalea. Note this script has **no** `iffalse` bag-full guard
  around `verbosegiveitem HM_CUT`.
- `IlexForestHeadbuttGuyScript` (object at 15,14): `checkevent EVENT_GOT_TM02_HEADBUTT`,
  else `verbosegiveitem TM_HEADBUTT`, `iffalse .BagFull`, `setevent EVENT_GOT_TM02_HEADBUTT`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ILEX_FOREST_FARFETCHD_1`..`_10` | `constants/event_flags.asm` (`_10` at :1172) | spawn flags on the ten bird objects; moved by the chase scripts | exactly one is set at a time |
| `EVENT_HERDED_FARFETCHD` | `constants/event_flags.asm:50` | set by `FarfetchdPosition9` fall-through | chase complete |
| `EVENT_CHARCOAL_KILN_BOSS` | `constants/event_flags.asm:1177` | set by `FarfetchdPosition9`, cleared by `IlexForestCharcoalMasterScript` | kiln boss spawn |
| `EVENT_ILEX_FOREST_APPRENTICE` | `constants/event_flags.asm:1173` | cleared by `SlowpokeWellB1F`, set by the master script | apprentice spawn (inverted: set = hidden here) |
| `EVENT_ILEX_FOREST_CHARCOAL_MASTER` | `constants/event_flags.asm:1174` | set by the master script | master spawn |
| `EVENT_GOT_HM01_CUT` | `constants/event_flags.asm:23` | `IlexForestCharcoalMasterScript` | one-shot HM01 |
| `EVENT_GOT_TM02_HEADBUTT` | `constants/event_flags.asm:104` | `IlexForestHeadbuttGuyScript`; also read by `maps/GoldenrodDeptStore5F.asm` | one-shot TM02 and a Dept 5F stock switch |
| `EVENT_ILEX_FOREST_REVIVE` | `constants/event_flags.asm:1042` | item ball | one-shot |
| `EVENT_ILEX_FOREST_HIDDEN_ETHER` / `_SUPER_POTION` / `_FULL_HEAL` | `constants/event_flags.asm:146-148` | hidden items | one-shot |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `HM_CUT` (HM01) | talk to charcoal master at (5,28) after herding | `IlexForestCharcoalMasterScript` | `EVENT_GOT_HM01_CUT` |
| `TM_HEADBUTT` (TM02) | talk to rocker at (15,14) | `IlexForestHeadbuttGuyScript` | `EVENT_GOT_TM02_HEADBUTT` |
| `REVIVE` | item ball at (20,32) | `IlexForestRevive` | `EVENT_ILEX_FOREST_REVIVE` |
| `ETHER` | hidden at (27,1) | `IlexForestHiddenEther` | `EVENT_ILEX_FOREST_HIDDEN_ETHER` |
| `SUPER_POTION` | hidden at (17,7) | `IlexForestHiddenSuperPotion` | `EVENT_ILEX_FOREST_HIDDEN_SUPER_POTION` |
| `FULL_HEAL` | hidden at (9,17) | `IlexForestHiddenFullHeal` | `EVENT_ILEX_FOREST_HIDDEN_FULL_HEAL` |

**Trainers**: none. `def_object_events` has no `OBJECTTYPE_TRAINER` row.

**Wild encounters**

`data/wild/johto_grass.asm`, `def_grass_wildmons ILEX_FOREST`, rates
`4 percent` morn/day/nite:

| slot | morn (Gold) | day (Gold) | nite (both) |
|---|---|---|---|
| 1 | L5 Caterpie | L5 Caterpie | L5 Oddish |
| 2 | L6 Metapod | L6 Caterpie | L6 Oddish |
| 3 | L6 Caterpie | L5 Metapod | L6 Zubat |
| 4 | L5 Paras | L6 Metapod | L5 Paras |
| 5 | L5 Zubat | L5 Zubat | L5 Zubat |
| 6 | L6 Paras | L6 Paras | L6 Paras |
| 7 | L6 Paras | L6 Paras | L6 Paras |

Silver swaps Caterpie/Metapod for Weedle/Kakuna in the morn and day blocks
(the `ELIF DEF(_SILVER)` arm). The nite block is shared.

Water (`data/wild/johto_water.asm:51`, `def_water_wildmons ILEX_FOREST`,
`2 percent`): L15 Psyduck, L10 Psyduck, L15 Golduck.

Headbutt: `data/wild/treemon_maps.asm:40` -> `treemon_map ILEX_FOREST, TREEMON_SET_FOREST`.
`TreeMonSet_Forest` (Gold) common: 50% Caterpie, 15% Caterpie, 15% Metapod,
10% Exeggcute, 5% Exeggcute, 5% Butterfree - all level 10; rare swaps the two
15% slots for Pineco.

**The Cut tree**

`data/collision/field_move_blocks.asm` `.forest` lists exactly one cuttable
block for `TILESET_FOREST`: `db $0f, $17, 0` (facing block `$0f`, replacement
`$17`, animation 0). Scanning `maps/IlexForest.blk` (15 wide) for `$0f` finds a
single occurrence, block (4,12), i.e. **map coordinates x 8-9, y 24-25**. That
is the tree between the Farfetch'd/charcoal area in the south and the shrine
bg_event at (8,22) / the north half of the forest, and it is the only thing
standing between the player and warp 1 at (1,5).

---

### MAP_ROUTE_34_ILEX_FOREST_GATE

- Script: `maps/Route34IlexForestGate.asm`
- Blocks: none
- Header: `data/maps/maps.asm:288` -> `TILESET_GATE, GATE, LANDMARK_ROUTE_34, MUSIC_ROUTE_36, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:266` -> `map_const ROUTE_34_ILEX_FOREST_GATE, 5, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 0 | `ROUTE_34` | 1 |
| 2 | 5 | 0 | `ROUTE_34` | 2 |
| 3 | 4 | 7 | `ILEX_FOREST` | 1 |
| 4 | 5 | 7 | `ILEX_FOREST` | 1 |

**Coord events**: none. **BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE34ILEXFORESTGATE_TEACHER` | `SPRITE_TEACHER` | 9 | 3 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `Route34IlexForestGateTeacherScript` | -1 |
| `ROUTE34ILEXFORESTGATE_BUTTERFREE` | `SPRITE_BUTTERFREE` | 9 | 4 | `POKEMON` | `OBJECTTYPE_SCRIPT` | `Route34IlexForestGateButterfreeScript` | -1 |
| `ROUTE34ILEXFORESTGATE_LASS` | `SPRITE_LASS` | 3 | 4 | `WALK_UP_DOWN` | `OBJECTTYPE_SCRIPT` | `Route34IlexForestGateLassScript` | -1 |

**Scripts of interest**

- `Route34IlexForestGateTeacherScript`: `checkevent EVENT_GOT_TM12_SWEET_SCENT`,
  else `verbosegiveitem TM_SWEET_SCENT`, `iffalse .NoRoom`,
  `setevent EVENT_GOT_TM12_SWEET_SCENT`. The walkthrough calls her "the lady
  behind the counter"; she is at (9,3), the top-right of the gate.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `TM_SWEET_SCENT` (TM12) | talk to teacher at (9,3) | `Route34IlexForestGateTeacherScript` | `EVENT_GOT_TM12_SWEET_SCENT` (`constants/event_flags.asm:131`) |

---

### MAP_ROUTE_34

- Script: `maps/Route34.asm`
- Blocks: `maps/Route34.blk`
- Header: `data/maps/maps.asm:268` -> `TILESET_JOHTO_MODERN, ROUTE, LANDMARK_ROUTE_34, MUSIC_ROUTE_36, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:246` -> `map_const ROUTE_34, 10, 27`
- Connections (`data/maps/attributes.asm:198`): north `GoldenrodCity` (offset -5), east `AzaleaTown` (offset 18)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 13 | 37 | `ROUTE_34_ILEX_FOREST_GATE` | 1 |
| 2 | 14 | 37 | `ROUTE_34_ILEX_FOREST_GATE` | 2 |
| 3 | 11 | 14 | `DAY_CARE` | 1 |
| 4 | 11 | 15 | `DAY_CARE` | 2 |
| 5 | 13 | 15 | `DAY_CARE` | 3 |

**Coord events**: none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 12 | 6 | `BGEVENT_READ` | `Route34Sign` |
| 13 | 33 | `BGEVENT_READ` | `Route34TrainerTips` |
| 10 | 13 | `BGEVENT_READ` | `DayCareSign` |
| 8 | 32 | `BGEVENT_ITEM` | `Route34HiddenRareCandy` -> `hiddenitem RARE_CANDY, EVENT_ROUTE_34_HIDDEN_RARE_CANDY` |
| 17 | 19 | `BGEVENT_ITEM` | `Route34HiddenSuperPotion` -> `hiddenitem SUPER_POTION, EVENT_ROUTE_34_HIDDEN_SUPER_POTION` |

(`Route34IlexForestSign` exists in the file but is marked `; unreferenced`.)

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `ROUTE34_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 13 | 7 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 5 | `TrainerCamperTodd1` | -1 |
| `ROUTE34_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 15 | 33 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 2 | `TrainerYoungsterSamuel` | -1 |
| `ROUTE34_YOUNGSTER3` | `SPRITE_YOUNGSTER` | 17 | 22 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` | 3 | `TrainerYoungsterIan` | -1 |
| `ROUTE34_LASS` | `SPRITE_LASS` | 10 | 26 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 3 | `TrainerPicnickerGina1` | -1 |
| `ROUTE34_OFFICER` | `SPRITE_OFFICER` | 9 | 11 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `OfficerKeithScript` | -1 |
| `ROUTE34_POKEFAN_M` | `SPRITE_POKEFAN_M` | 19 | 28 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 2 | `TrainerPokefanmBrandon` | -1 |
| `ROUTE34_GRAMPS` | `SPRITE_GRAMPS` | 15 | 16 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `DayCareManScript_Outside` | `EVENT_DAY_CARE_MAN_ON_ROUTE_34` |
| `ROUTE34_DAY_CARE_MON_1` | `SPRITE_DAY_CARE_MON_1` | 14 | 18 | `POKEMON` | `OBJECTTYPE_SCRIPT` | 0 | `DayCareMon1Script` | `EVENT_DAY_CARE_MON_1` |
| `ROUTE34_DAY_CARE_MON_2` | `SPRITE_DAY_CARE_MON_2` | 17 | 19 | `POKEMON` | `OBJECTTYPE_SCRIPT` | 0 | `DayCareMon2Script` | `EVENT_DAY_CARE_MON_2` |
| `ROUTE34_COOLTRAINER_F1` | `SPRITE_COOLTRAINER_F` | 11 | 48 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 5 | `TrainerCooltrainerfIrene` | -1 |
| `ROUTE34_COOLTRAINER_F2` | `SPRITE_COOLTRAINER_F` | 3 | 48 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 3 | `TrainerCooltrainerfJenn` | -1 |
| `ROUTE34_COOLTRAINER_F3` | `SPRITE_COOLTRAINER_F` | 6 | 51 | `STANDING_UP` | `OBJECTTYPE_TRAINER` | 2 | `TrainerCooltrainerfKate` | -1 |

The three Cooltrainer F sisters sit at y 48-51, on the beach south-west of the
Ilex gate. That area is water-locked; reaching them needs SURF, which needs the
FOGBADGE. They are not part of this section's path.

**Scripts of interest**

- `Route34EggCheckCallback` (`MAPCALLBACK_OBJECTS`): reads
  `ENGINE_DAY_CARE_MAN_HAS_EGG` to decide whether the Day-Care man stands
  outside (`EVENT_DAY_CARE_MAN_ON_ROUTE_34`) or inside
  (`EVENT_DAY_CARE_MAN_IN_DAY_CARE`), then mirrors
  `ENGINE_DAY_CARE_MAN_HAS_MON` / `ENGINE_DAY_CARE_LADY_HAS_MON` onto
  `EVENT_DAY_CARE_MON_1` / `_2` (which are *hide* flags: set = hidden).
- `DayCareManScript_Outside`: `special DayCareManOutside` (the yes/no egg
  handoff), then `ifequal TRUE, .end_fail`, `clearflag ENGINE_DAY_CARE_MAN_HAS_EGG`,
  and walks him back inside with one of two movement scripts depending on
  `readvar VAR_FACING` (`RIGHT` uses the walk-around-player variant).
- `OfficerKeithScript`: `checktime NITE`, `iffalse .NoFight`. Night only, as the
  walkthrough says. Wins set `EVENT_BEAT_OFFICER_KEITH`. It is an
  `OBJECTTYPE_SCRIPT`, not a `trainer` row, so there is no sight-line trigger:
  the bot must talk to him.
- `TrainerCamperTodd1` / `TrainerPicnickerGina1`: full phone-number flow
  (`askforphonenumber PHONE_CAMPER_TODD` / `PHONE_PICNICKER_GINA`), with
  rematch parties gated on `ENGINE_FLYPOINT_CIANWOOD` / `ENGINE_FLYPOINT_BLACKTHORN`
  (Todd) and `ENGINE_FLYPOINT_MAHOGANY` / `EVENT_CLEARED_RADIO_TOWER` (Gina).
- `TrainerYoungsterSamuel`, `TrainerYoungsterIan`, `TrainerPokefanmBrandon`:
  plain `endifjustbattled` + after-text. **No phone number.**
- `TrainerCooltrainerfKate`: `verbosegiveitem SOFT_SAND`,
  `setevent EVENT_GOT_SOFT_SAND_FROM_KATE`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_DAY_CARE_MAN_HAS_EGG` | `constants/engine_flags.asm:10` | `Route34EggCheckCallback`, `DayCareEggCheckCallback`, `DayCareManScript_Outside` | egg is waiting; man stands outside at (15,16) |
| `ENGINE_DAY_CARE_MAN_HAS_MON` / `ENGINE_DAY_CARE_LADY_HAS_MON` | `constants/engine_flags.asm:11,13` | both egg-check callbacks | drives the two overworld Day-Care mon sprites |
| `EVENT_DAY_CARE_MAN_ON_ROUTE_34` | `constants/event_flags.asm:1160` | callbacks | outdoor Day-Care man spawn |
| `EVENT_BEAT_OFFICER_KEITH` | `constants/event_flags.asm` | `OfficerKeithScript` | one-shot night battle |
| `EVENT_GOT_SOFT_SAND_FROM_KATE` | `constants/event_flags.asm:121` | `TrainerCooltrainerfKate` | one-shot, needs SURF |
| `EVENT_ROUTE_34_HIDDEN_RARE_CANDY` / `_SUPER_POTION` | `constants/event_flags.asm:177,178` | hidden items | one-shot |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `SOFT_SAND` | beat Cooltrainer F Kate at (6,51) (SURF required) | `TrainerCooltrainerfKate` | `EVENT_GOT_SOFT_SAND_FROM_KATE` |
| `RARE_CANDY` | hidden at (8,32) | `Route34HiddenRareCandy` | `EVENT_ROUTE_34_HIDDEN_RARE_CANDY` |
| `SUPER_POTION` | hidden at (17,19) | `Route34HiddenSuperPotion` | `EVENT_ROUTE_34_HIDDEN_SUPER_POTION` |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `SAMUEL` | `YOUNGSTER` | YOUNGSTER (5) | L7 Rattata, L10 Sandshrew, L8 Spearow, L8 Spearow | `TrainerYoungsterSamuel` | none |
| `BRANDON` | `POKEFANM` | POKEFANM (7) | L13 Snubbull @ `BERRY` (`TRAINERTYPE_ITEM`) | `TrainerPokefanmBrandon` | none |
| `IAN` | `YOUNGSTER` | YOUNGSTER (6) | L10 Mankey, L12 Diglett | `TrainerYoungsterIan` | none |
| `GINA1` | `PICNICKER` | PICNICKER (2) | L9 Hoppip, L9 Hoppip, L12 Bulbasaur | `TrainerPicnickerGina1` | `PHONE_PICNICKER_GINA`; `GINA2`/`GINA3` rematches |
| `KEITH` | `OFFICER` | OFFICER (1) | L17 Growlithe | `OfficerKeithScript` | none; night only |
| `TODD1` | `CAMPER` | CAMPER (2) | L14 Psyduck | `TrainerCamperTodd1` | `PHONE_CAMPER_TODD`; `TODD2`/`TODD3` rematches |
| `IRENE` | `COOLTRAINERF` | - | see `data/trainers/parties.asm` | `TrainerCooltrainerfIrene` | SURF-gated beach |
| `JENN` | `COOLTRAINERF` | - | see `data/trainers/parties.asm` | `TrainerCooltrainerfJenn` | SURF-gated beach |
| `KATE` | `COOLTRAINERF` | - | see `data/trainers/parties.asm` | `TrainerCooltrainerfKate` | SURF-gated beach; gives `SOFT_SAND` |

**Wild encounters**

`data/wild/johto_grass.asm`, `def_grass_wildmons ROUTE_34`, rates
`10 percent` morn/day/nite; all three time blocks are identical:

L10 Drowzee, L11 Rattata, L12 Drowzee, L10 Abra, L13 Rattata, L10 Ditto, L10 Ditto.

Water (`data/wild/johto_water.asm:149`, `6 percent`): L20 Tentacool,
L15 Tentacool, L20 Tentacruel.

Headbutt: `data/wild/treemon_maps.asm:15` -> `treemon_map ROUTE_34, TREEMON_SET_FOREST`
(same table as Ilex Forest).

---

### MAP_DAY_CARE

- Script: `maps/DayCare.asm`
- Blocks: `maps/DayCare.blk`
- Header: `data/maps/maps.asm:289` -> `TILESET_HOUSE, INDOOR, LANDMARK_ROUTE_34, MUSIC_AZALEA_TOWN, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:267` -> `map_const DAY_CARE, 5, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 5 | `ROUTE_34` | 3 |
| 2 | 0 | 6 | `ROUTE_34` | 4 |
| 3 | 2 | 7 | `ROUTE_34` | 5 |
| 4 | 3 | 7 | `ROUTE_34` | 5 |

**Coord events**: none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `DayCareBookshelf` |
| 1 | 1 | `BGEVENT_READ` | `DayCareBookshelf` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `DAYCARE_GRAMPS` | `SPRITE_GRAMPS` | 2 | 3 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `DayCareManScript_Inside` | `EVENT_DAY_CARE_MAN_IN_DAY_CARE` |
| `DAYCARE_GRANNY` | `SPRITE_GRANNY` | 5 | 3 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `DayCareLadyScript` | -1 |

**Scripts of interest**

- `DayCareEggCheckCallback` (`MAPCALLBACK_OBJECTS`): mirror of the Route 34 one;
  moves the man in/out based on `ENGINE_DAY_CARE_MAN_HAS_EGG`.
- `DayCareManScript_Inside` -> `special DayCareMan`; `DayCareLadyScript` ->
  `special DayCareLady`, unless `ENGINE_DAY_CARE_MAN_HAS_EGG` is set, in which
  case she just says "Gramps was looking for you".

There is **no** PC object in `maps/DayCare.asm`. The walkthrough's quoted claim
that "there's a PC in the corner of the Daycare" is not backed by this map.

---

### MAP_GOLDENROD_CITY

- Script: `maps/GoldenrodCity.asm`
- Blocks: `maps/GoldenrodCity.blk`
- Header: `data/maps/maps.asm:269` -> `TILESET_JOHTO_MODERN, TOWN, LANDMARK_GOLDENROD_CITY, MUSIC_GOLDENROD_CITY, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:247` -> `map_const GOLDENROD_CITY, 20, 18`
- Connections (`data/maps/attributes.asm:139`): north `Route35` (offset 5), south `Route34` (offset 5)

**Warps**

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

**Coord events**: none.

**BG events**

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

No hidden items on this map.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `GOLDENRODCITY_POKEFAN_M1` | `SPRITE_POKEFAN_M` | 7 | 18 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `GoldenrodCityPokefanMScript` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `GOLDENRODCITY_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 30 | 17 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `GoldenrodCityYoungster1Script` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `GOLDENRODCITY_COOLTRAINER_F1` | `SPRITE_COOLTRAINER_F` | 12 | 16 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `GoldenrodCityCooltrainerF1Script` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `GOLDENRODCITY_COOLTRAINER_F2` | `SPRITE_COOLTRAINER_F` | 20 | 26 | `WANDER` (1,2) | `OBJECTTYPE_SCRIPT` | `GoldenrodCityCooltrainerF2Script` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `GOLDENRODCITY_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 19 | 17 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `GoldenrodCityYoungster2Script` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `GOLDENRODCITY_LASS` | `SPRITE_LASS` | 17 | 10 | `WALK_LEFT_RIGHT` (2,0) | `OBJECTTYPE_SCRIPT` | `GoldenrodCityLassScript` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `GOLDENRODCITY_GRAMPS` | `SPRITE_GRAMPS` | 11 | 27 | `WALK_LEFT_RIGHT` (1,0) | `OBJECTTYPE_SCRIPT` | `GoldenrodCityGrampsScript` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `GOLDENRODCITY_ROCKETSCOUT` | `SPRITE_ROCKET` | 4 | 16 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `GoldenrodCityRocketScoutScript` | `EVENT_GOLDENROD_CITY_ROCKET_SCOUT` |
| `GOLDENRODCITY_ROCKET1` | `SPRITE_ROCKET` | 28 | 20 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `GoldenrodCityRocket1Script` | `EVENT_GOLDENROD_CITY_ROCKET_TAKEOVER` |
| `GOLDENRODCITY_ROCKET2` | `SPRITE_ROCKET` | 8 | 15 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `GoldenrodCityRocket2Script` | `EVENT_GOLDENROD_CITY_ROCKET_TAKEOVER` |
| `GOLDENRODCITY_ROCKET3` | `SPRITE_ROCKET` | 16 | 23 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `GoldenrodCityRocket3Script` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `GOLDENRODCITY_ROCKET4` | `SPRITE_ROCKET` | 29 | 20 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `GoldenrodCityRocket4Script` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `GOLDENRODCITY_ROCKET5` | `SPRITE_ROCKET` | 29 | 7 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `GoldenrodCityRocket5Script` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `GOLDENRODCITY_ROCKET6` | `SPRITE_ROCKET` | 30 | 10 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `GoldenrodCityRocket6Script` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |

**Scripts of interest**

- `GoldenrodCityFlypointCallback` (`MAPCALLBACK_NEWMAP`):
  `setflag ENGINE_FLYPOINT_GOLDENROD`, `setflag ENGINE_REACHED_GOLDENROD`.
  Both fire on first entry, no conditions.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_GOLDENROD` | `constants/engine_flags.asm:84` | flypoint callback | Fly unlocked |
| `ENGINE_REACHED_GOLDENROD` | `constants/engine_flags.asm:31` | flypoint callback | gates the Rocket-takeover storyline elsewhere |
| `ENGINE_RADIO_CARD` | `constants/engine_flags.asm:4` | set by `RadioTower1FRadioCardWomanScript`; read by `GoldenrodCityCooltrainerF2Script` | Pokegear radio |
| `EVENT_GOLDENROD_CITY_CIVILIANS` | `constants/event_flags.asm` | spawn flag on the seven civilians | cleared during the Rocket takeover |

**Trainers**: none on the city map at this point in the game.

**Wild encounters**: none (`data/wild/treemon_maps.asm:33` ->
`treemon_map GOLDENROD_CITY, TREEMON_SET_NONE`; no `def_grass_wildmons` /
`def_water_wildmons` entry for `GOLDENROD_CITY`).

---

### MAP_BILLS_FAMILYS_HOUSE

- Script: `maps/BillsFamilysHouse.asm`
- Header: `data/maps/maps.asm:273` -> `TILESET_HOUSE, INDOOR, LANDMARK_GOLDENROD_CITY, MUSIC_GOLDENROD_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:251` -> `map_const BILLS_FAMILYS_HOUSE, 4, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `GOLDENROD_CITY` | 4 |
| 2 | 3 | 7 | `GOLDENROD_CITY` | 4 |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `BillsHouseBookshelf2` |
| 1 | 1 | `BGEVENT_READ` | `BillsHouseBookshelf1` |
| 7 | 1 | `BGEVENT_READ` | `BillsHouseRadio` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `BILLSFAMILYSHOUSE_BILL` | `SPRITE_BILL` | 2 | 3 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `BillScript` | `EVENT_MET_BILL` |
| `BILLSFAMILYSHOUSE_POKEFAN_F` | `SPRITE_POKEFAN_F` | 5 | 3 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `BillsMomScript` | -1 |
| `BILLSFAMILYSHOUSE_TWIN` | `SPRITE_TWIN` | 5 | 4 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `BillsYoungerSisterScript` | -1 |

**Scripts of interest**

- `BillsYoungerSisterScript` (the twin at 5,4 - the girl "closer to the door"):
  `checkcellnum PHONE_BILL`, else `askforphonenumber PHONE_BILL` /
  `addcellnum PHONE_BILL`. This is the only thing available in this section.
- `BillScript`: gives `EEVEE` at level 20 via `givepoke EEVEE, 20` +
  `setevent EVENT_GOT_EEVEE`, guarded by `readvar VAR_PARTYCOUNT` /
  `ifequal PARTY_LENGTH, .NoRoom`. Bill's object only spawns once
  `EVENT_MET_BILL` is set, which happens in Ecruteak - **not in this section**.
  `BillsMomScript` reads `EVENT_MET_BILL` too (note the two texts are wired
  backwards relative to their names in the asm: `iffalse .HaventMetBill`
  prints `BillsMomText_AfterEcruteak`).

---

### MAP_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES

- Script: `maps/GoldenrodUndergroundSwitchRoomEntrances.asm`
- Blocks: `maps/GoldenrodUndergroundSwitchRoomEntrances.blk`
- Header: `data/maps/maps.asm:124` -> `TILESET_ELITE_FOUR_ROOM, DUNGEON, LANDMARK_GOLDENROD_CITY, MUSIC_UNION_CAVE, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:111` -> `map_const GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES, 15, 18`

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
| `SCENE_GOLDENRODUNDERGROUNDSWITCHROOMENTRANCES_RIVAL_BATTLE` | 19 | 4 | `UndergroundRivalScene1` | later-game rival battle, not armed in this section |
| `SCENE_GOLDENRODUNDERGROUNDSWITCHROOMENTRANCES_RIVAL_BATTLE` | 19 | 5 | `UndergroundRivalScene2` | same |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 16 | 1 | `BGEVENT_READ` | `Switch1Script` |
| 10 | 1 | `BGEVENT_READ` | `Switch2Script` |
| 2 | 1 | `BGEVENT_READ` | `Switch3Script` |
| 20 | 11 | `BGEVENT_READ` | `EmergencySwitchScript` |
| 8 | 9 | `BGEVENT_ITEM` | `GoldenrodUndergroundSwitchRoomEntrancesHiddenMaxPotion` |
| 1 | 8 | `BGEVENT_ITEM` | `GoldenrodUndergroundSwitchRoomEntrancesHiddenRevive` |

**Object events** (all the Rocket/Burglar rows are gated on
`EVENT_RADIO_TOWER_ROCKET_TAKEOVER`, so during this section only the two
stairwell NPCs and the two item balls exist)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `..._TEACHER` | `SPRITE_TEACHER` | 3 | 27 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `GoldenrodUndergroundSwitchRoomEntrancesTeacherScript` | -1 |
| `..._SUPER_NERD` | `SPRITE_SUPER_NERD` | 19 | 27 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `GoldenrodUndergroundSwitchRoomEntrancesSuperNerdScript` | -1 |
| `..._POKE_BALL1` | `SPRITE_POKE_BALL` | 1 | 12 | `STILL` | `OBJECTTYPE_ITEMBALL` | `..._SmokeBall` | `EVENT_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES_SMOKE_BALL` |
| `..._POKE_BALL2` | `SPRITE_POKE_BALL` | 14 | 9 | `STILL` | `OBJECTTYPE_ITEMBALL` | `..._FullHeal` | `EVENT_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES_FULL_HEAL` |
| `..._PHARMACIST1/2`, `..._ROCKET1/2/3`, `..._ROCKET_GIRL` | - | (9,12) (4,8) (17,2) (11,2) (3,2) (19,12) | - | `OBJECTTYPE_TRAINER` | `TrainerBurglarDuncan`, `TrainerBurglarEddie`, `TrainerGruntM13`, `TrainerGruntM11`, `TrainerGruntM25`, `TrainerGruntF3` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `..._RIVAL` | `SPRITE_RIVAL` | 23 | 3 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_RIVAL_GOLDENROD_UNDERGROUND` |

The three `ugdoor` switch puzzles and the warehouse are also takeover-era
content. This section only walks through: city warp 15 -> (4,29), north to
warp 4 at (5,25) -> `GOLDENROD_UNDERGROUND`; and back up on the other side via
warp 7 at (21,25) -> warps 8/9 at (20/21,29) -> city warp 14 at (9,5).

---

### MAP_GOLDENROD_UNDERGROUND

- Script: `maps/GoldenrodUnderground.asm`
- Blocks: `maps/GoldenrodUnderground.blk`
- Header: `data/maps/maps.asm:123` -> `TILESET_GATE, DUNGEON, LANDMARK_GOLDENROD_CITY, MUSIC_UNION_CAVE, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
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

Warp 3 at (18,6) is the basement door; it is blocked until `BASEMENT_KEY`.

**Coord events**: none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 18 | 6 | `BGEVENT_READ` | `BasementDoorScript` |
| 19 | 6 | `BGEVENT_READ` | `GoldenrodUndergroundNoEntrySign` |
| 6 | 13 | `BGEVENT_ITEM` | `GoldenrodUndergroundHiddenParlyzHeal` (`PARLYZ_HEAL`, `EVENT_GOLDENROD_UNDERGROUND_HIDDEN_PARLYZ_HEAL`) |
| 4 | 18 | `BGEVENT_ITEM` | `GoldenrodUndergroundHiddenSuperPotion` (`SUPER_POTION`, `EVENT_GOLDENROD_UNDERGROUND_HIDDEN_SUPER_POTION`) |
| 17 | 8 | `BGEVENT_ITEM` | `GoldenrodUndergroundHiddenAntidote` (`ANTIDOTE`, `EVENT_GOLDENROD_UNDERGROUND_HIDDEN_ANTIDOTE`) |

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `GOLDENRODUNDERGROUND_SUPER_NERD1` | `SPRITE_SUPER_NERD` | 5 | 31 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSupernerdEric` | -1 |
| `GOLDENRODUNDERGROUND_SUPER_NERD2` | `SPRITE_SUPER_NERD` | 6 | 9 | `STANDING_UP` | `OBJECTTYPE_TRAINER` | 2 | `TrainerSupernerdTeru` | -1 |
| `GOLDENRODUNDERGROUND_SUPER_NERD3` | `SPRITE_SUPER_NERD` | 3 | 27 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 2 | `TrainerPokemaniacIssac` | -1 |
| `GOLDENRODUNDERGROUND_SUPER_NERD4` | `SPRITE_SUPER_NERD` | 2 | 6 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 3 | `TrainerPokemaniacDonald` | -1 |
| `GOLDENRODUNDERGROUND_POKE_BALL` | `SPRITE_POKE_BALL` | 7 | 25 | `STILL` | `OBJECTTYPE_ITEMBALL` | 0 | `GoldenrodUndergroundCoinCase` (`itemball COIN_CASE`) | `EVENT_GOLDENROD_UNDERGROUND_COIN_CASE` |
| `GOLDENRODUNDERGROUND_GRAMPS` | `SPRITE_GRAMPS` | 7 | 11 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | 0 | `BargainMerchantScript` | `EVENT_GOLDENROD_UNDERGROUND_GRAMPS` |
| `GOLDENRODUNDERGROUND_OLDER_HAIRCUT_BROTHER` | `SPRITE_SUPER_NERD` | 7 | 14 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | 0 | `OlderHaircutBrotherScript` | `EVENT_GOLDENROD_UNDERGROUND_OLDER_HAIRCUT_BROTHER` |
| `GOLDENRODUNDERGROUND_YOUNGER_HAIRCUT_BROTHER` | `SPRITE_SUPER_NERD` | 7 | 15 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | 0 | `YoungerHaircutBrotherScript` | `EVENT_GOLDENROD_UNDERGROUND_YOUNGER_HAIRCUT_BROTHER` |
| `GOLDENRODUNDERGROUND_GRANNY` | `SPRITE_GRANNY` | 7 | 21 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | 0 | `BitterMerchantScript` | `EVENT_GOLDENROD_UNDERGROUND_GRANNY` |

**Scripts of interest**

- `GoldenrodUndergroundResetSwitchesCallback` (`MAPCALLBACK_NEWMAP`): clears
  `EVENT_SWITCH_1..3`, `EVENT_EMERGENCY_SWITCH`, `EVENT_DOOR_1_OPEN`..`_11_OPEN`
  and zeroes `wUndergroundSwitchPositions`. Runs every entry.
- `GoldenrodUndergroundCheckBasementKeyCallback` (`MAPCALLBACK_TILES`): unless
  `EVENT_USED_BASEMENT_KEY`, `changeblock 18, 6, $3d` (locked door). This is the
  "door is locked" the walkthrough hits.
- `BasementDoorScript` (bg at 18,6): `checkitem BASEMENT_KEY` ->
  `changeblock 18, 6, $2e`, `refreshmap`, `setevent EVENT_USED_BASEMENT_KEY`.
  The `BASEMENT_KEY` is not obtainable in this section.
- `GoldenrodUndergroundCheckDayOfWeekCallback` (`MAPCALLBACK_OBJECTS`): the
  weekday schedule for the four shop NPCs -
  Sunday: younger barber + granny; Monday morn: gramps (bargain merchant);
  Tue/Thu: older barber; Wed/Fri: younger barber; Sat: older barber + granny.
- `BargainMerchantScript`: Monday `MORN` only, and only while
  `ENGINE_GOLDENROD_UNDERGROUND_MERCHANT_CLOSED` is clear ->
  `pokemart MARTTYPE_BARGAIN, 0`.
- `BitterMerchantScript`: Saturday or Sunday -> `pokemart MARTTYPE_BITTER, MART_UNDERGROUND`.
- `OlderHaircutBrotherScript` / `YoungerHaircutBrotherScript`: 500 / 300 money,
  one per day via `ENGINE_GOLDENROD_UNDERGROUND_GOT_HAIRCUT`,
  `special OlderHaircutBrother` / `YoungerHaircutBrother`.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `COIN_CASE` | item ball at (7,25) | `GoldenrodUndergroundCoinCase` | `EVENT_GOLDENROD_UNDERGROUND_COIN_CASE` (`constants/event_flags.asm:1043`) |
| `PARLYZ_HEAL` | hidden at (6,13) | `GoldenrodUndergroundHiddenParlyzHeal` | `EVENT_GOLDENROD_UNDERGROUND_HIDDEN_PARLYZ_HEAL` |
| `SUPER_POTION` | hidden at (4,18) | `GoldenrodUndergroundHiddenSuperPotion` | `EVENT_GOLDENROD_UNDERGROUND_HIDDEN_SUPER_POTION` |
| `ANTIDOTE` | hidden at (17,8) | `GoldenrodUndergroundHiddenAntidote` | `EVENT_GOLDENROD_UNDERGROUND_HIDDEN_ANTIDOTE` |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `ERIC` | `SUPER_NERD` | SUPER_NERD (2) | L11 Grimer, L11 Grimer | `TrainerSupernerdEric` | none |
| `ISSAC` | `POKEMANIAC` | POKEMANIAC (11) | L12 Lickitung (Lick, Supersonic, Cut) `TRAINERTYPE_MOVES` | `TrainerPokemaniacIssac` | none |
| `TERU` | `SUPER_NERD` | SUPER_NERD (10) | L7 Magnemite, L11 Voltorb, L7 Magnemite, L9 Magnemite | `TrainerSupernerdTeru` | none |
| `DONALD` | `POKEMANIAC` | POKEMANIAC (12) | L10 Slowpoke, L10 Slowpoke | `TrainerPokemaniacDonald` | none |

The walkthrough spells the Pokemaniac "Isaac"; the asm constant and party name
are `ISSAC` (two S). Its event flag is `EVENT_BEAT_POKEMANIAC_ISSAC`.

**Wild encounters**: none.

---

### MAP_GOLDENROD_BIKE_SHOP

- Script: `maps/GoldenrodBikeShop.asm`
- Header: `data/maps/maps.asm:271` -> `TILESET_CHAMPIONS_ROOM, INDOOR, LANDMARK_GOLDENROD_CITY, MUSIC_GOLDENROD_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:249` -> `map_const GOLDENROD_BIKE_SHOP, 4, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `GOLDENROD_CITY` | 2 |
| 2 | 3 | 7 | `GOLDENROD_CITY` | 2 |

**BG events**: nine `GoldenrodBikeShopBicycle` display signs at
(1,2), (0,3), (1,3), (0,5), (1,5), (0,6), (1,6), (6,6), (7,6).

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `GOLDENRODBIKESHOP_CLERK` | `SPRITE_CLERK` | 7 | 2 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `GoldenrodBikeShopClerkScript` | -1 |

**Scripts of interest**

- `GoldenrodBikeShopClerkScript`: `checkevent EVENT_GOT_BICYCLE`, else
  intro text + `yesorno`, `giveitem BICYCLE`, `itemnotify`,
  `setflag ENGINE_BIKE_SHOP_CALL_ENABLED`, `setevent EVENT_GOT_BICYCLE`.
  No badge, money or item prerequisite. Note it is a plain `giveitem`, not
  `verbosegiveitem`, and there is no bag-full branch.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `BICYCLE` | say YES to the clerk at (7,2) | `GoldenrodBikeShopClerkScript` | `EVENT_GOT_BICYCLE` (`constants/event_flags.asm:100`) |

---

### MAP_RADIO_TOWER_1F

- Script: `maps/RadioTower1F.asm`
- Blocks: `maps/RadioTower1F.blk`
- Header: `data/maps/maps.asm:95` -> `TILESET_RADIO_TOWER, INDOOR, LANDMARK_RADIO_TOWER, RADIO_TOWER_MUSIC | MUSIC_GOLDENROD_CITY, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:82` -> `map_const RADIO_TOWER_1F, 9, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `GOLDENROD_CITY` | 12 |
| 2 | 3 | 7 | `GOLDENROD_CITY` | 12 |
| 3 | 15 | 0 | `RADIO_TOWER_2F` | 2 |

**Coord events**: none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 3 | 0 | `BGEVENT_READ` | `RadioTower1FDirectory` |
| 13 | 0 | `BGEVENT_READ` | `RadioTower1FLuckyChannelSign` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `..._RECEPTIONIST` | `SPRITE_RECEPTIONIST` | 5 | 6 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `RadioTower1FReceptionistScript` | -1 |
| `..._LASS` | `SPRITE_LASS` | 16 | 4 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `RadioTower1FLassScript` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `..._YOUNGSTER` | `SPRITE_YOUNGSTER` | 15 | 4 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `RadioTower1FYoungsterScript` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `..._ROCKET` | `SPRITE_ROCKET` | 14 | 1 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerGruntM3` | `EVENT_RADIO_TOWER_ROCKET_TAKEOVER` |
| `..._GENTLEMAN` | `SPRITE_GENTLEMAN` | 8 | 6 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `RadioTower1FLuckyNumberManScript` | `EVENT_GOLDENROD_CITY_CIVILIANS` |
| `..._COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 12 | 6 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `RadioTower1FRadioCardWomanScript` | `EVENT_GOLDENROD_CITY_CIVILIANS` |

**Scripts of interest**

`RadioTower1FRadioCardWomanScript` (object at 12,6 - the woman on the right):
`checkflag ENGINE_RADIO_CARD` short-circuits. Otherwise a five-question
`yesorno` chain; a wrong answer jumps to `.WrongAnswer` and the whole quiz
restarts on the next talk. Required answers, straight off the `iffalse`/`iftrue`
branches:

| # | question text label | required answer | branch |
|---|---|---|---|
| 1 | `RadioTower1FRadioCardWomanQuestion1Text` (Town Map on Pokegear?) | YES | `iffalse .WrongAnswer` |
| 2 | `...Question2Text` (Nidorina female only?) | YES | `iffalse .WrongAnswer` |
| 3 | `...Question3Text` (Kurt uses Apricorn?) | NO | `iftrue .WrongAnswer` |
| 4 | `...Question4Text` (Magikarp learns no TM?) | YES | `iffalse .WrongAnswer` |
| 5 | `...Question5Text` (is MARIE the co-host?) | NO | `iftrue .WrongAnswer` |

On success: `getstring STRING_BUFFER_4, .RadioCardText` (`"RADIO CARD@"`),
`scall .ReceiveItem` (`jumpstd ReceiveItemScript`), then
`setflag ENGINE_RADIO_CARD`. The Radio Card is a Pokegear card flag, not a bag
item.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| Radio Card (Pokegear card) | pass the five-question quiz | `RadioTower1FRadioCardWomanScript` | `ENGINE_RADIO_CARD` (`constants/engine_flags.asm:4`) |

---

### MAP_GOLDENROD_GYM

- Script: `maps/GoldenrodGym.asm`
- Blocks: `maps/GoldenrodGym.blk`
- Header: `data/maps/maps.asm:270` -> `TILESET_ELITE_FOUR_ROOM, INDOOR, LANDMARK_GOLDENROD_CITY, MUSIC_GYM, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:248` -> `map_const GOLDENROD_GYM, 10, 9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 17 | `GOLDENROD_CITY` | 1 |
| 2 | 3 | 17 | `GOLDENROD_CITY` | 1 |

**Coord events**

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_GOLDENRODGYM_WHITNEY_STOPS_CRYING` | 8 | 5 | `WhitneyCriesScript` | Bridget walks over, `clearevent EVENT_MADE_WHITNEY_CRY`, `setscene SCENE_GOLDENRODGYM_NOOP` |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 1 | 15 | `BGEVENT_READ` | `GoldenrodGymStatue` |
| 4 | 15 | `BGEVENT_READ` | `GoldenrodGymStatue` |

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `GOLDENRODGYM_WHITNEY` | `SPRITE_WHITNEY` | 8 | 3 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `GoldenrodGymWhitneyScript` | -1 |
| `GOLDENRODGYM_LASS1` | `SPRITE_LASS` | 9 | 13 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 4 | `TrainerLassCarrie` | -1 |
| `GOLDENRODGYM_LASS2` | `SPRITE_LASS` | 9 | 6 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 1 | `TrainerLassBridget` | -1 |
| `GOLDENRODGYM_BEAUTY1` | `SPRITE_BEAUTY` | 0 | 2 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` | 3 | `TrainerBeautyVictoria` | -1 |
| `GOLDENRODGYM_BEAUTY2` | `SPRITE_BEAUTY` | 19 | 5 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` | 3 | `TrainerBeautySamantha` | -1 |
| `GOLDENRODGYM_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 5 | 15 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `GoldenrodGymGuideScript` | -1 |

**Scripts of interest**

`GoldenrodGymWhitneyScript` is a three-visit script; a bot must run it in order:

1. First talk (`EVENT_BEAT_WHITNEY` clear): before-text,
   `winlosstext WhitneyShouldntBeSoSeriousText, 0`,
   `loadtrainer WHITNEY, WHITNEY1`, `startbattle`, `reloadmapafterbattle`.
   On win it sets `EVENT_BEAT_WHITNEY`, `EVENT_MADE_WHITNEY_CRY`,
   `setscene SCENE_GOLDENRODGYM_WHITNEY_STOPS_CRYING`, and marks all four gym
   trainers beaten (`EVENT_BEAT_BEAUTY_VICTORIA`, `EVENT_BEAT_BEAUTY_SAMANTHA`,
   `EVENT_BEAT_LASS_CARRIE`, `EVENT_BEAT_LASS_BRIDGET`).
2. Falls into `.FightDone` immediately: `checkevent EVENT_MADE_WHITNEY_CRY`
   `iffalse .StoppedCrying`. While the flag is set, Whitney only prints
   `WhitneyYouMeanieText` and **gives nothing**.
3. Stepping on the coord event at **(8,5)** runs `WhitneyCriesScript`, which
   `clearevent EVENT_MADE_WHITNEY_CRY` and `setscene SCENE_GOLDENRODGYM_NOOP`.
   Talk to Whitney again -> `.StoppedCrying`: `setflag ENGINE_PLAINBADGE`,
   `readvar VAR_BADGES`, `scall GoldenrodGymActivateRockets`, then
   `verbosegiveitem TM_ATTRACT` guarded by `iffalse .NoRoomForAttract` and
   `setevent EVENT_GOT_TM45_ATTRACT`.

`GoldenrodGymActivateRockets`: `ifequal 7, .RadioTowerRockets`,
`ifequal 6, .GoldenrodRockets` on the post-badge count. With PLAINBADGE as the
third badge neither branch fires here.

`GoldenrodGymStatue`: `checkflag ENGINE_PLAINBADGE` -> `GymStatue2Script` with
`gettrainername STRING_BUFFER_4, WHITNEY, WHITNEY1`, else `GymStatue1Script`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_WHITNEY` | `constants/event_flags.asm:708` | `GoldenrodGymWhitneyScript`, `GoldenrodGymGuideScript` | battle done |
| `EVENT_MADE_WHITNEY_CRY` | `constants/event_flags.asm:49` | set by the win, cleared by `WhitneyCriesScript` | **blocks the badge** while set |
| `SCENE_GOLDENRODGYM_WHITNEY_STOPS_CRYING` | `maps/GoldenrodGym.asm:12` | `setscene` in the win path, `SCENE_GOLDENRODGYM_NOOP` after | arms the (8,5) trip-wire |
| `ENGINE_PLAINBADGE` | `constants/engine_flags.asm:40` | set in `.StoppedCrying`; read by `StrengthFunction.TryStrength` and `FlowerShopTeacherScript` | Strength field move + Squirtbottle |
| `EVENT_GOT_TM45_ATTRACT` | `constants/event_flags.asm:17` | `.StoppedCrying` | one-shot TM45 |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| PLAINBADGE | second talk after the cry scene | `GoldenrodGymWhitneyScript` `.StoppedCrying` | `ENGINE_PLAINBADGE` |
| `TM_ATTRACT` (TM45) | same conversation | `GoldenrodGymWhitneyScript` | `EVENT_GOT_TM45_ATTRACT` |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `VICTORIA` | `BEAUTY` | BEAUTY (1) | L9 Sentret, L13 Sentret, L17 Sentret | `TrainerBeautyVictoria` | none |
| `SAMANTHA` | `BEAUTY` | BEAUTY (2) | L16 Meowth (Scratch, Growl, Bite, Pay Day), L16 Meowth (Scratch, Growl, Bite, Slash) | `TrainerBeautySamantha` | none |
| `CARRIE` | `LASS` | LASS (1) | L18 Snubbull (Scary Face, Charm, Bite, Lick) | `TrainerLassCarrie` | none |
| `BRIDGET` | `LASS` | LASS (2) | L15 Jigglypuff x3 | `TrainerLassBridget` | none |
| `WHITNEY1` | `WHITNEY` | WHITNEY (1), `data/trainers/parties.asm:20` | L18 Clefairy (DoubleSlap, Mimic, Encore, Metronome), L20 Miltank (Rollout, Attract, Stomp, Milk Drink) | `GoldenrodGymWhitneyScript` | none |

---

### Supporting Goldenrod interiors (short form)

**`GOLDENROD_POKECENTER_1F`** (`maps/GoldenrodPokecenter1F.asm`, header
`data/maps/maps.asm:276`, `map_const GOLDENROD_POKECENTER_1F, 5, 4`):
warps (3,7)/(4,7) -> city 7, (0,7) -> `POKECENTER_2F` 1. Nurse at (3,1).

**`GOLDENROD_DEPT_STORE_1F`** (`maps/GoldenrodDeptStore1F.asm`, header
`data/maps/maps.asm:279`, `map_const GOLDENROD_DEPT_STORE_1F, 8, 4`):
warps (7,7)/(8,7) -> city 10, (15,0) -> 2F warp 2, (2,0) -> elevator warp 1.

Mart stock (`data/items/marts.asm`):

| floor | mart const | items |
|---|---|---|
| 2F | `MART_GOLDENROD_2F_1` / `_2` | `MartGoldenrod2F2`: Poke Ball, Great Ball, Escape Rope, Repel, Revive, Full Heal, Poke Doll, Flower Mail (plus the `_1` heal list) |
| 3F | `MART_GOLDENROD_3F` | X Speed, X Special, X Defend, X Attack, Dire Hit, Guard Spec., X Accuracy |
| 4F | `MART_GOLDENROD_4F` | Protein, Iron, Carbos, Calcium, **HP Up** |
| 5F | `MART_GOLDENROD_5F_1..4` | always TM41 ThunderPunch, TM48 Fire Punch, TM33 Ice Punch; **+ TM02 Headbutt once `EVENT_GOT_TM02_HEADBUTT`**, **+ TM08 Rock Smash once `EVENT_GOT_TM08_ROCK_SMASH`** (`GoldenrodDeptStore5FClerkScript` picks 1/2/3/4) |
| 6F | vending machines | `giveitem FRESH_WATER` / `SODA_POP` / `LEMONADE` (`maps/GoldenrodDeptStore6F.asm`) |

`GoldenrodDeptStore5F` also holds:
- `GoldenrodDeptStore5FCheckIfSundayCallback` (`MAPCALLBACK_OBJECTS`) -
  the receptionist at (7,5) only appears on `SUNDAY`.
- `GoldenrodDeptStore5FReceptionistScript`: Sunday only, one-shot via
  `ENGINE_GOLDENROD_DEPT_STORE_TM27_RETURN`. `special GetFirstPokemonHappiness`,
  then `>=150` -> `verbosegiveitem TM_RETURN` (TM27), `>=50` -> nothing,
  `<50` -> `verbosegiveitem TM_FRUSTRATION` (TM21). That is the walkthrough's
  "Sunday giveaway of TMs" and where TM21/TM27 come from.
- `Mike` at (6,3): NPC trade row 1 in `data/events/npc_trades.asm` -
  `npctrade TRADE_DIALOGSET_COLLECTOR, DROWZEE, MACHOP, "MUSCLE", $37, $66, GOLD_BERRY, 37460, "MIKE", TRADE_GENDER_EITHER`,
  i.e. give Drowzee, get Machop. That is the walkthrough's Machop-by-trading.

**`GOLDENROD_GAME_CORNER`** (`maps/GoldenrodGameCorner.asm`, header
`data/maps/maps.asm:286`, `map_const GOLDENROD_GAME_CORNER, 10, 7`):
warps (2,13)/(3,13) -> city 11. Prize prices are `DEF`s at the top of the file:

| prize | coins | const |
|---|---|---|
| Abra (L10) | 200 | `GOLDENRODGAMECORNER_ABRA_COINS` |
| Ekans (L10) | 700 | `GOLDENRODGAMECORNER_EKANS_COINS` (Gold; Silver sells Sandshrew at `..._SANDSHREW_COINS`, also 700) |
| Dratini (L10) | 2100 | `GOLDENRODGAMECORNER_DRATINI_COINS` |
| TM25 Thunder | 5500 | `GOLDENRODGAMECORNER_TM25_COINS` |
| TM14 Blizzard | 5500 | `GOLDENRODGAMECORNER_TM14_COINS` |
| TM38 Fire Blast | 5500 | `GOLDENRODGAMECORNER_TM38_COINS` |

Mon prizes check `readvar VAR_PARTYCOUNT` / `ifequal PARTY_LENGTH` and run
`special GameCornerPrizeMonCheckDex` before `givepoke`.

**`GOLDENROD_MAGNET_TRAIN_STATION`** (`maps/GoldenrodMagnetTrainStation.asm`,
header `data/maps/maps.asm:274`, `map_const GOLDENROD_MAGNET_TRAIN_STATION, 10, 9`):
warps (8,17)/(9,17) -> city 5; (6,5)/(11,5) -> `SAFFRON_MAGNET_TRAIN_STATION`
4/3. Coord event at (11,6) for `SCENE_GOLDENRODMAGNETTRAINSTATION_ARRIVE_FROM_SAFFRON`.
The conductor is `GoldenrodMagnetTrainStationOfficerScript` at (9,9).

**`GOLDENROD_FLOWER_SHOP`** (`maps/GoldenrodFlowerShop.asm`, city warp 6 at
(33,5)): `FlowerShopTeacherScript` gives `SQUIRTBOTTLE` gated on
`checkflag ENGINE_PLAINBADGE` + `EVENT_GOT_SQUIRTBOTTLE`. The walkthrough's
"Squirtwater" is this item, and it becomes available only **after** Whitney.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Azalea rival battle | `maps/AzaleaTown.asm` `def_coord_events` (5,10)/(5,11) + `SCENE_AZALEATOWN_RIVAL_BATTLE` | scene armed by `maps/SlowpokeWellB1F.asm:58` | clear Slowpoke Well; battle sets `EVENT_RIVAL_AZALEA_TOWN` and `setscene SCENE_AZALEATOWN_NOOP` |
| Farfetch'd quest exists at all | `maps/SlowpokeWellB1F.asm:60-63` (`clearevent EVENT_ILEX_FOREST_FARFETCHD_1`, `clearevent EVENT_ILEX_FOREST_APPRENTICE`) | `EVENT_CLEARED_SLOWPOKE_WELL` | same scene |
| Ilex Forest cut tree | block `$0f` at Ilex Forest block (4,12) = map (8-9, 24-25); `data/collision/field_move_blocks.asm` `.forest` | a party mon with `CUT` **and** `ENGINE_HIVEBADGE` | `engine/events/overworld.asm` `CutFunction.CheckAble` (`ld de, ENGINE_HIVEBADGE / call CheckBadge`) and `TryCutOW` (`CheckPartyMove` then `CheckEngineFlag ENGINE_HIVEBADGE`) |
| Getting HM01 in the first place | `maps/IlexForest.asm` `IlexForestCharcoalMasterScript`; the master object only spawns after `FarfetchdPosition9` runs `appear 13` + `setevent EVENT_CHARCOAL_KILN_BOSS` | complete the 9-step Farfetch'd herd | `EVENT_HERDED_FARFETCHD`, then `EVENT_GOT_HM01_CUT` |
| Whitney's badge | `maps/GoldenrodGym.asm` `GoldenrodGymWhitneyScript` `.FightDone` -> `checkevent EVENT_MADE_WHITNEY_CRY` `iffalse .StoppedCrying` | `EVENT_MADE_WHITNEY_CRY` must be **clear** | step on the coord event at (8,5) to run `WhitneyCriesScript` |
| Strength field move | `engine/events/overworld.asm` `StrengthFunction.TryStrength` (`ld de, ENGINE_PLAINBADGE / call CheckBadge`) | PLAINBADGE | beat Whitney and collect the badge |
| Squirtbottle | `maps/GoldenrodFlowerShop.asm` `FlowerShopTeacherScript` (`checkflag ENGINE_PLAINBADGE / iffalse .Lalala`) | PLAINBADGE | after Whitney; needed for Sudowoodo next section |
| Route 34 beach trainers + `SOFT_SAND` | water tiles between (3..11, 44..51); `SurfFunction.TrySurf` needs `ENGINE_FOGBADGE` | SURF + FOGBADGE | not reachable in this section |
| Goldenrod Underground basement door | `maps/GoldenrodUnderground.asm` `GoldenrodUndergroundCheckBasementKeyCallback` (`changeblock 18, 6, $3d`) and `BasementDoorScript` (`checkitem BASEMENT_KEY`) | `BASEMENT_KEY` | Rocket-takeover arc, not this section |
| Bill / Eevee | `maps/BillsFamilysHouse.asm` object flag `EVENT_MET_BILL` on `BILLSFAMILYSHOUSE_BILL` | meet Bill in Ecruteak | not this section - only the phone number is available now |
| Game Corner prizes | `maps/GoldenrodGameCorner.asm` prize vendors + coins | `COIN_CASE` | item ball at Goldenrod Underground (7,25) |
| Underground salon / bargain / bitter shops | `GoldenrodUndergroundCheckDayOfWeekCallback` + each script's `readvar VAR_WEEKDAY` | correct weekday (and `MORN` for the bargain merchant) | real-clock dependent |
| Officer Keith battle | `maps/Route34.asm` `OfficerKeithScript` `checktime NITE` | night | real-clock dependent |
| Fly to Goldenrod | `GoldenrodCityFlypointCallback` | none | fires on first map entry |

---

## 4. Bot checklist

Each row: map, target, intent, precondition, postcondition.

1. `AZALEA_TOWN` - walk to (5,10) or (5,11). Intent: walk (trip-wire).
   Pre: `SCENE_AZALEATOWN_RIVAL_BATTLE`. Post: rival battle
   (`RIVAL1`, id `RIVAL1_2_<not-your-starter>`), `EVENT_RIVAL_AZALEA_TOWN`,
   scene back to `SCENE_AZALEATOWN_NOOP`.
2. `AZALEA_TOWN` - warp 7 at (2,10). Intent: walk. Post: `ILEX_FOREST_AZALEA_GATE`.
3. `ILEX_FOREST_AZALEA_GATE` - warp 1 at (0,4). Post: `ILEX_FOREST` at (3,42).
4. `ILEX_FOREST` - walk to the apprentice `ILEXFOREST_YOUNGSTER` at (7,28),
   talk. Pre: `EVENT_ILEX_FOREST_APPRENTICE` clear (object visible). Post: none
   (text only).
5. `ILEX_FOREST` - talk to `ILEXFOREST_FARFETCHD1` at (14,31). Post: bird moves
   to (15,25), `EVENT_ILEX_FOREST_FARFETCHD_2`.
6. `ILEX_FOREST` - repeat: walk to the current bird, **face it from the side the
   fall-through branch wants**, talk. Use the Pos2..Pos9 table in the map section
   above; the safe rule is "never face the direction listed as a back-branch for
   that position". Coordinates: Pos2 (15,25), Pos3 (20,24), Pos4 (29,22),
   Pos5 (28,31), Pos6 (24,35), Pos7 (22,31), Pos8 (15,29), Pos9 (10,35).
   Post at Pos9 fall-through: `EVENT_HERDED_FARFETCHD`,
   `EVENT_CHARCOAL_KILN_BOSS`, bird at (6,28), master appears at (5,28).
7. `ILEX_FOREST` - grab the item ball at (20,32). Intent: walk onto / A.
   Post: `REVIVE`, `EVENT_ILEX_FOREST_REVIVE`.
8. `ILEX_FOREST` - talk to `ILEXFOREST_BLACK_BELT` at (5,28).
   Pre: `EVENT_HERDED_FARFETCHD`. Post: `HM_CUT`, `EVENT_GOT_HM01_CUT`,
   apprentice/master/bird despawn here and respawn in the Charcoal Kiln.
9. Teach `CUT` to a party mon (menu). Pre: `HM_CUT` in bag.
10. `ILEX_FOREST` - face the tree at map (8,24) (block (4,12)) and press A, or
    use CUT from the pack. Pre: `ENGINE_HIVEBADGE` + party mon with CUT.
    Post: block replaced with `$17`, path north opens.
11. `ILEX_FOREST` - optional: hidden Super Potion at (17,7), hidden Full Heal at
    (9,17), hidden Ether at (27,1); read the shrine bg at (8,22).
12. `ILEX_FOREST` - talk to `ILEXFOREST_ROCKER` at (15,14).
    Post: `TM_HEADBUTT`, `EVENT_GOT_TM02_HEADBUTT`.
13. `ILEX_FOREST` - warp 1 at (1,5). Post: `ROUTE_34_ILEX_FOREST_GATE` at (4,7).
14. `ROUTE_34_ILEX_FOREST_GATE` - talk to the teacher at (9,3).
    Post: `TM_SWEET_SCENT`, `EVENT_GOT_TM12_SWEET_SCENT`.
15. `ROUTE_34_ILEX_FOREST_GATE` - warp 1 at (4,0). Post: `ROUTE_34` at (13,37).
16. `ROUTE_34` - Youngster Samuel at (15,33), sight 2 facing random (spinner);
    battle. Post: `EVENT_BEAT_YOUNGSTER_SAMUEL`.
17. `ROUTE_34` - PokeFan M Brandon at (19,28), sight 2 facing LEFT.
    Post: `EVENT_BEAT_POKEFANM_BRANDON`.
18. `ROUTE_34` - Youngster Ian at (17,22), sight 3 facing DOWN.
    Post: `EVENT_BEAT_YOUNGSTER_IAN`. (No phone number - see Unresolved.)
19. `ROUTE_34` - Picnicker Gina at (10,26), sight 3 facing RIGHT.
    Post: `EVENT_BEAT_PICNICKER_GINA`; talk again for
    `askforphonenumber PHONE_PICNICKER_GINA`.
20. `ROUTE_34` - warp 3 at (11,14) into `DAY_CARE`; talk to the man at (2,3)
    and/or the lady at (5,3) to deposit. Post: `ENGINE_DAY_CARE_MAN_HAS_MON` /
    `ENGINE_DAY_CARE_LADY_HAS_MON`.
21. `ROUTE_34` - after walking, if `ENGINE_DAY_CARE_MAN_HAS_EGG`, the man stands
    at (15,16); talk and answer YES. Post: egg in party,
    `ENGINE_DAY_CARE_MAN_HAS_EGG` cleared.
22. `ROUTE_34` - optional night detour: Officer Keith at (9,11), talk.
    Pre: `checktime NITE`. Post: `EVENT_BEAT_OFFICER_KEITH`.
23. `ROUTE_34` - Camper Todd at (13,7), sight 5 facing LEFT.
    Post: `EVENT_BEAT_CAMPER_TODD`; talk again for
    `askforphonenumber PHONE_CAMPER_TODD`.
24. `ROUTE_34` - walk north off the top of the map. Post: `GOLDENROD_CITY`
    (connection offset -5), `ENGINE_FLYPOINT_GOLDENROD`, `ENGINE_REACHED_GOLDENROD`.
25. `GOLDENROD_CITY` - warp 7 at (15,27) to heal.
26. `GOLDENROD_CITY` - warp 10 at (24,27) for the Dept Store (optional).
27. `GOLDENROD_CITY` - warp 4 at (5,25) into `BILLS_FAMILYS_HOUSE`; talk to the
    twin at (5,4). Post: `PHONE_BILL` registered.
28. `GOLDENROD_CITY` - warp 15 at (11,29) -> switch-room (4,29); walk north to
    warp 4 at (5,25) -> `GOLDENROD_UNDERGROUND` at (3,34).
29. `GOLDENROD_UNDERGROUND` - Super Nerd Eric at (5,31) sight 3 facing LEFT.
    Post: `EVENT_BEAT_SUPER_NERD_ERIC`.
30. `GOLDENROD_UNDERGROUND` - Pokemaniac Issac at (3,27), sight 2, spins.
    Post: `EVENT_BEAT_POKEMANIAC_ISSAC`.
31. `GOLDENROD_UNDERGROUND` - item ball at (7,25). Post: `COIN_CASE`,
    `EVENT_GOLDENROD_UNDERGROUND_COIN_CASE`.
32. `GOLDENROD_UNDERGROUND` - Super Nerd Teru at (6,9), sight 2 facing UP.
    Post: `EVENT_BEAT_SUPER_NERD_TERU`.
33. `GOLDENROD_UNDERGROUND` - Pokemaniac Donald at (2,6), sight 3 facing RIGHT.
    Post: `EVENT_BEAT_POKEMANIAC_DONALD`.
34. `GOLDENROD_UNDERGROUND` - optional: read the basement door bg at (18,6)
    (locked; `BASEMENT_KEY` not available yet). Hidden items at (6,13), (4,18),
    (17,8).
35. `GOLDENROD_UNDERGROUND` - warp 1 at (3,2) -> switch-room (21,25) ->
    warp 8 at (20,29) -> `GOLDENROD_CITY` (9,5).
36. `GOLDENROD_CITY` - warp 2 at (29,29) into `GOLDENROD_BIKE_SHOP`; talk to the
    clerk at (7,2) and answer YES. Post: `BICYCLE`, `EVENT_GOT_BICYCLE`,
    `ENGINE_BIKE_SHOP_CALL_ENABLED`.
37. `GOLDENROD_CITY` - warp 5 at (9,13) for the train station (flavour only).
38. `GOLDENROD_CITY` - warp 12 at (5,15) into `RADIO_TOWER_1F`; talk to the
    woman at (12,6) and answer YES, YES, NO, YES, NO.
    Post: `ENGINE_RADIO_CARD`.
39. `GOLDENROD_CITY` - heal (warp 7), then warp 1 at (24,7) into `GOLDENROD_GYM`.
40. `GOLDENROD_GYM` - Beauty Victoria at (0,2), sight 3 facing DOWN.
    Post: `EVENT_BEAT_BEAUTY_VICTORIA`.
41. `GOLDENROD_GYM` - Beauty Samantha at (19,5), sight 3 facing DOWN.
    Post: `EVENT_BEAT_BEAUTY_SAMANTHA`.
42. `GOLDENROD_GYM` - Lass Carrie at (9,13), sight 4 facing RIGHT.
    Post: `EVENT_BEAT_LASS_CARRIE`.
43. `GOLDENROD_GYM` - Lass Bridget at (9,6), sight 1 facing LEFT.
    Post: `EVENT_BEAT_LASS_BRIDGET`.
44. `GOLDENROD_GYM` - talk to Whitney at (8,3). Post: `EVENT_BEAT_WHITNEY`,
    `EVENT_MADE_WHITNEY_CRY`, `SCENE_GOLDENRODGYM_WHITNEY_STOPS_CRYING`.
45. `GOLDENROD_GYM` - **walk onto (8,5)**. Intent: walk (trip-wire).
    Post: `WhitneyCriesScript`, `EVENT_MADE_WHITNEY_CRY` cleared,
    `SCENE_GOLDENRODGYM_NOOP`.
46. `GOLDENROD_GYM` - talk to Whitney at (8,3) again.
    Post: `ENGINE_PLAINBADGE`, `TM_ATTRACT`, `EVENT_GOT_TM45_ATTRACT`.
47. Optional after the badge: `GOLDENROD_CITY` warp 6 at (33,5) ->
    `GOLDENROD_FLOWER_SHOP`, talk to the teacher. Post: `SQUIRTBOTTLE`,
    `EVENT_GOT_SQUIRTBOTTLE` (needed for the next section's Sudowoodo).

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map headers / dimensions / connections for every map above | `src/import/RomExtractorGen2.lua` (`readMapGroupEntry`, `mapNameByIds`), `src/world/gen2/Map.lua` | implemented (generic, ROM-driven; nothing map-specific is hand-ported) |
| `def_warp_events` / `def_coord_events` / `def_bg_events` / `def_object_events` decode | `src/import/RomExtractorGen2.lua:804` (`coordEvents`), `:861`, `:974` | implemented |
| Coord-event trip-wires (Azalea rival, Whitney cries) | `src/world/gen2/World.lua:5013` (iterates `self.map.def.coordEvents`) | implemented |
| Scene ids / `setscene` / `setmapscene` | `src/script/gen2/Opcodes.lua` (`0x11`-`0x14`), `src/script/gen2/Vm.lua` | implemented |
| Script VM opcodes used by this section (`verbosegiveitem`, `loadtrainer`, `startbattle`, `winlosstext`, `setlasttalked`, `applymovement`, `moveobject`, `turnobject`, `appear`/`disappear`, `showemote`, `changeblock`, `refreshmap`, `givepoke`, `giveitem`, `checkcoins`/`takecoins`, `askforphonenumber`, `addcellnum`/`checkcellnum`, `giveegg`, `pokemart`, `fruittree`, `checktime`, `readvar`) | `src/script/gen2/Opcodes.lua`, `src/script/gen2/Vm.lua` | implemented (all present) |
| `readvar VAR_FACING` (the whole Farfetch'd branch logic) | `src/world/gen2/World.lua:95,1219` | implemented |
| Item balls / hidden items | `src/import/RomExtractorGen2.lua:2874,2882` (`readItemBall`, `hiddenitem`), `src/world/gen2/HiddenItems.lua` | implemented |
| Trainer sight lines and `trainer` struct | `src/world/gen2/Trainers.lua:98` (`Trainers.sees`), extractor `:2961` | implemented |
| CUT badge gate + A-press cut (`TryCutOW` / `CutFunction`) | `src/world/gen2/FieldMoves.lua:104` (`CUT = "HIVE"`), `:449`, `:609`; `src/world/gen2/World.lua:4203` (`World:tryCutOW`), `:3965` (`World:runCut`), `:3872` (`CutDownTreeOrGrass`) | implemented |
| STRENGTH badge gate (`PLAINBADGE`) | `src/world/gen2/FieldMoves.lua:108`, `:519` | implemented |
| Bicycle | `src/world/gen2/Bike.lua`, `src/world/gen2/World.lua:1790` | implemented |
| Coin Case / Game Corner slots and prizes | `src/core/gen2/CoinCase.lua`, `src/ui/gen2/SlotMachine.lua`, `src/ui/gen2/PrizeMenu.lua`, `src/script/gen2/Specials.lua:964` (`GameCornerPrizeMonCheckDex`) | implemented |
| Day-Care / breeding / egg handoff (`DayCareMan`, `DayCareLady`, `DayCareManOutside`, `DayCareMon1/2`) | `src/core/gen2/Breeding.lua`, `src/script/gen2/Specials.lua:526-596`, `src/ui/gen2/DayCareMenu.lua`; driver `tests/drivers/gold_egg_hatch.lua` | implemented |
| Phone numbers (Bill, Todd, Gina) | `src/core/gen2/Phone.lua`, `src/script/gen2/Opcodes.lua:156` | implemented |
| Pokegear Radio Card + radio channels | `src/ui/gen2/Pokegear.lua:39` (`{ id = "radio", ..., flag = "radio" }`), `:49` onward | implemented |
| Haircut brothers / weekday NPC schedule | `src/script/gen2/Specials.lua:1661-1662`, `src/world/gen2/World.lua:99` | implemented |
| NPC trade (Mike: Drowzee -> Machop) | `src/core/gen2/NpcTrade.lua`, `src/ui/gen2/TradeMenu.lua`, `src/ui/gen2/TradeAnim.lua` | implemented |
| Happiness -> TM27/TM21 Sunday lady | `src/core/gen2/Happiness.lua`, `src/script/gen2/Specials.lua:1506` (`GetFirstPokemonHappiness`) | implemented |
| Marts (`MARTTYPE_STANDARD` / `_BARGAIN` / `_BITTER`) | `src/ui/gen2/MartMenu.lua` | implemented (verify the bargain/bitter variants by hand - only the standard path has driver coverage) |
| Magnet train (locked here, station map only) | `src/core/gen2/MagnetTrain.lua`, `src/ui/gen2/MagnetTrainRide.lua` | implemented |
| End-to-end driver for this stretch | none - `tests/drivers/gold_*.lua` covers boot, walk, warp, battle, egg hatch, evolution, boulders (`gold_icepath_boulder.lua`), map callbacks | **missing** - there is no Ilex-Forest / Goldenrod driver; the Farfetch'd chase and the Whitney cry-then-badge sequence are unexercised |
| Farfetch'd chase specifically | no dedicated port file; runs on the generic VM | untested (no driver) |
| Whitney badge two-step (`EVENT_MADE_WHITNEY_CRY` + coord event) | generic VM + `World.lua:5013` | untested (no driver) |

---

## 6. Unresolved / verify by hand

Contradictions between the walkthrough text and `pokegold`:

1. **"Bug Catcher Wayne" in Ilex Forest does not exist in Gold.**
   `grep -rn WAYNE constants/ data/ maps/` returns only `BIKER DWAYNE` on
   `maps/Route8.asm`. `maps/IlexForest.asm` has **zero** `OBJECTTYPE_TRAINER`
   rows. Wayne (L8 Ledyba / L10 Paras) is Crystal-only content.
2. **"X Attack" and "Antidote" in Ilex Forest do not exist in Gold.**
   The only items on the map are the `REVIVE` item ball at (20,32) and hidden
   `ETHER` (27,1), `SUPER_POTION` (17,7), `FULL_HEAL` (9,17). The walkthrough's
   own item list ("HM01, Revive, TM02, TM12") also omits them, so the prose
   contradicts its own header. TM12 is in the gate map, not the forest.
3. **Ilex Forest species list.** The walkthrough lists Weedle (#013). In Gold
   the morn/day slots are Caterpie/Metapod (`IF DEF(_GOLD)`); Weedle/Kakuna is
   the `ELIF DEF(_SILVER)` arm. Oddish is nite-only. Metapod is Gold-only.
4. **"Youngster Ian will want to trade phone numbers with you."**
   `TrainerYoungsterIan.Script` in `maps/Route34.asm` is just
   `endifjustbattled` / `writetext YoungsterIanAfterText`. No `askforphonenumber`,
   no `PHONE_*` constant. The Route 34 phone trainers are Camper Todd and
   Picnicker Gina only.
5. **Rival party order.** The walkthrough prints Gastly / starter / Zubat; the
   asm (`Rival1Group` entries 4-6) is Gastly (12), Zubat (14), starter (16).
6. **"There's a PC in the corner of the Daycare."** `maps/DayCare.asm` has two
   bookshelf bg events and two NPC objects; no PC bg event or object.
7. **"Level 5: TM02, TM33, TM41, TM48"** is right in spirit but conditional:
   `MART_GOLDENROD_5F_1` (the default) is only TM41 ThunderPunch, TM48 Fire
   Punch, TM33 Ice Punch. TM02 Headbutt is added only after
   `EVENT_GOT_TM02_HEADBUTT`, and TM08 Rock Smash after
   `EVENT_GOT_TM08_ROCK_SMASH` (`GoldenrodDeptStore5FClerkScript`).
8. **Game Corner "Ekans/Sandshrew 700"** - the version split is real; Gold's
   branch (`.Gold_Ekans`) sells Ekans. `GOLDENRODGAMECORNER_SANDSHREW_COINS` is
   the Silver constant, also 700.
9. **"Get Eevee from Bill" is listed under Goldenrod** but `BILLSFAMILYSHOUSE_BILL`
   carries the object flag `EVENT_MET_BILL`, which is set in Ecruteak. Only
   `BillsYoungerSisterScript` (Bill's phone number) is reachable in this section.
10. **Prose ordering glitch in the walkthrough**: "Now head out of the gym and
    we'll hit the east side of town" appears before the gym is ever entered.
    Treat the bike shop / radio tower paragraphs as pre-gym.
11. **Whether the Azalea rival coord events at (5,10)/(5,11) can be walked
    around** was not verified - it needs a collision read of `maps/AzaleaTown.blk`
    plus the tileset collision table, which I did not decode. The two rows are
    the only trip-wires on the map, so a bot should assume they can be dodged
    and treat `EVENT_RIVAL_AZALEA_TOWN` as the real precondition for later
    content rather than relying on the walk-west path.
12. **Exact walkable route through the Farfetch'd chase** (which tile to stand
    on so the player's facing lands on the fall-through branch) was not derived;
    only the branch table was read from the asm. A bot needs the collision map
    of `maps/IlexForest.blk` to turn "face away from `<DIR>`" into concrete
    approach tiles.
13. **`data/wild/fish.asm`** was searched for `ILEX_FOREST` / `ROUTE_34` and has
    no per-map rows - fishing is selected by the header's `FISHGROUP_*`
    (`FISHGROUP_POND` for Ilex Forest, `FISHGROUP_SHORE` for Route 34). The
    per-group tables were not transcribed here.
14. **Exp/money numbers** quoted by the walkthrough (e.g. "You get: 960G") were
    not verified; they are computed at runtime from base exp and level, not
    stored in `data/trainers/parties.asm`.

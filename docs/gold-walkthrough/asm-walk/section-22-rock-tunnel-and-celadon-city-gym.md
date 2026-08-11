# Section 22 - Rock Tunnel and Celadon City Gym

Source: `../section-22-rock-tunnel-and-celadon-city-gym.txt`
(the FAQ numbers this chapter "28 > Rock Tunnel and Celadon City Gym"; the file
index is 22)

Maps covered: `MAP_POWER_PLANT`, `MAP_ROCK_TUNNEL_1F`, `MAP_ROCK_TUNNEL_B1F`,
`MAP_ROUTE_10_SOUTH`, `MAP_LAVENDER_TOWN`, `MAP_LAV_RADIO_TOWER_1F`,
`MAP_SOUL_HOUSE`, `MAP_ROUTE_8`, `MAP_ROUTE_8_SAFFRON_GATE`,
`MAP_SAFFRON_CITY`, `MAP_COPYCATS_HOUSE_1F`, `MAP_COPYCATS_HOUSE_2F`,
`MAP_VERMILION_CITY`, `MAP_POKEMON_FAN_CLUB`, `MAP_SAFFRON_MAGNET_TRAIN_STATION`,
`MAP_ROUTE_7_SAFFRON_GATE`, `MAP_ROUTE_7`, `MAP_CELADON_CITY`,
`MAP_CELADON_MANSION_1F`, `MAP_CELADON_MANSION_2F`, `MAP_CELADON_MANSION_3F`,
`MAP_CELADON_MANSION_ROOF`, `MAP_CELADON_MANSION_ROOF_HOUSE`,
`MAP_CELADON_DEPT_STORE_1F`..`6F`, `MAP_CELADON_GAME_CORNER`,
`MAP_CELADON_GAME_CORNER_PRIZE_ROOM`, `MAP_CELADON_CAFE`, `MAP_CELADON_GYM`

Badges / key milestones in this section:

- TM07 Zap Cannon from the Power Plant MANAGER (reward for `EVENT_RETURNED_MACHINE_PART`)
- EXPN CARD from the Lavender radio director (`ENGINE_EXPN_CARD`)
- LOST_ITEM -> PASS chain (Copycat / Pokemon Fan Club), unlocking the Magnet Train
- TM03 Curse (Celadon Mansion roof house, night only)
- Leftovers (Celadon Cafe trash can)
- **RAINBOWBADGE** + TM19 Giga Drain from ERIKA (`ENGINE_RAINBOWBADGE`)

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 0 | `ROUTE_9` / `ROUTE_10_NORTH` | `maps/Route10North.asm` | Route 9 south connection (`data/maps/attributes.asm` `connection south, Route10North, ROUTE_10_NORTH, 20`) | warp 2 at (3, 9) -> `POWER_PLANT` 1 | Surf east from Route 9 to the Power Plant. **Route 9 / Route 10 North belong to the previous section; only the hop is listed here.** |
| 1 | `POWER_PLANT` | `maps/PowerPlant.asm` | warp 1/2 at (2,17)/(3,17) from `ROUTE_10_NORTH` 2 | same warps back | Talk to `PowerPlantManager` (object at 14,10) for **TM07 Zap Cannon** |
| 2 | `ROUTE_10_NORTH` | `maps/Route10North.asm` | Power Plant warp | south connection to `ROUTE_10_SOUTH`, or `ROCK_TUNNEL_1F` via Route 9 warp 1 | Walk back to the Rock Tunnel mouth |
| 3 | `ROCK_TUNNEL_1F` | `maps/RockTunnel1F.asm` | warp 1 at (15,3) from `ROUTE_9` 1 | warp 2 at (11,25) -> `ROUTE_10_SOUTH` 1 | Flash through the tunnel; TM47 Steel Wing + Elixer here |
| 4 | `ROCK_TUNNEL_B1F` | `maps/RockTunnelB1F.asm` | 1F warps 3/4/5/6 | back up to 1F | Iron, PP Up, Revive, hidden Max Potion |
| 5 | `ROUTE_10_SOUTH` | `maps/Route10South.asm` | warp 1 at (6,1) from `ROCK_TUNNEL_1F` 2 | south connection to `LAVENDER_TOWN` | Hiker Jim + Pokefanm Robert |
| 6 | `LAVENDER_TOWN` | `maps/LavenderTown.asm` | north connection from `ROUTE_10_SOUTH` | warp 7 at (14,5) -> `LAV_RADIO_TOWER_1F` 1; west connection to `ROUTE_8` | Sets `ENGINE_FLYPOINT_LAVENDER`; radio tower / Soul House / Name Rater |
| 7 | `LAV_RADIO_TOWER_1F` | `maps/LavRadioTower1F.asm` | Lavender warp 7 | warps 1/2 at (2,7)/(3,7) back | Director (`LAVRADIOTOWER1F_GENTLEMAN`) gives the **EXPN CARD** |
| 8 | `ROUTE_8` | `maps/Route8.asm` | east connection from `LAVENDER_TOWN` | warps 1/2 at (4,4)/(4,5) -> `ROUTE_8_SAFFRON_GATE` 3/4 | Five trainers (2 Super Nerds, 3 Bikers) + PRZCUREBERRY tree |
| 9 | `SAFFRON_CITY` | `maps/SaffronCity.asm` | `ROUTE_8_SAFFRON_GATE` warps 1/2 | warp 8 at (9,11) -> `COPYCATS_HOUSE_1F` 1 | Heal, then visit the Copycat |
| 10 | `COPYCATS_HOUSE_1F` -> `2F` | `maps/CopycatsHouse1F.asm`, `maps/CopycatsHouse2F.asm` | 1F warp 3 at (2,0) -> `COPYCATS_HOUSE_2F` 1 | 2F warp 1 at (3,0) back | First `Copycat` talk sets `EVENT_MET_COPYCAT_FOUND_OUT_ABOUT_LOST_ITEM` |
| 11 | `VERMILION_CITY` | `maps/VermilionCity.asm` | Fly | warp 3 at (7,13) -> `POKEMON_FAN_CLUB` 1 | The CLEFAIRY-doll guy hands over `LOST_ITEM` |
| 12 | `POKEMON_FAN_CLUB` | `maps/PokemonFanClub.asm` | Vermilion warp 3 | warps 1/2 at (2,7)/(3,7) back | `PokemonFanClubClefairyGuyScript` -> `giveitem LOST_ITEM` |
| 13 | `SAFFRON_CITY` -> `COPYCATS_HOUSE_2F` | as above | Fly + warps | - | Return `LOST_ITEM`, receive `PASS` |
| 14 | `ROUTE_7_SAFFRON_GATE` | `maps/Route7SaffronGate.asm` | `SAFFRON_CITY` warps 10/11 at (0,24)/(0,25) | warps 1/2 at (0,4)/(0,5) -> `ROUTE_7` 1/2 | The "Pokedex as ID" guard |
| 15 | `ROUTE_7` | `maps/Route7.asm` | gate warps 1/2 at (15,6)/(15,7) | west connection to `CELADON_CITY` | No trainers; sealed Underground Path signs |
| 16 | `CELADON_CITY` | `maps/CeladonCity.asm` | east connection from `ROUTE_7` (`connection west, CeladonCity, CELADON_CITY, -5`) | nine warps, see below | Sets `ENGINE_FLYPOINT_CELADON` |
| 17 | `CELADON_MANSION_1F/2F/3F/ROOF/ROOF_HOUSE` | `maps/CeladonMansion*.asm` | city warps 2 (16,9) and 3/4 (16,3)/(17,3) | roof house warps | **TM03 Curse** (night), Game Freak dev room |
| 18 | `CELADON_DEPT_STORE_1F`..`6F` | `maps/CeladonDeptStore*.asm` | city warp 1 at (4,9) | store warps / elevator | Mart inventories |
| 19 | `CELADON_GAME_CORNER` / `..._PRIZE_ROOM` | `maps/CeladonGameCorner.asm`, `maps/CeladonGameCornerPrizeRoom.asm` | city warps 6 (18,19) and 7 (23,19) | back to city | Slots, then TM/mon prize counters |
| 20 | `CELADON_CAFE` | `maps/CeladonCafe.asm` | city warp 9 at (25,29) | warps 1/2 at (6,7)/(7,7) back | **Leftovers** from `bg_event 7, 1` trash can |
| 21 | `CELADON_GYM` | `maps/CeladonGym.asm` | city warp 8 at (10,29) | warps 1/2 at (4,17)/(5,17) back | Four trainers then **ERIKA** |

Spillover: the walkthrough's next beat (leaving Celadon westward toward Cycling
Road / Fuchsia) belongs to the following section and is not covered here.

---

## 2. Maps

### MAP_POWER_PLANT

- Script: `maps/PowerPlant.asm`
- Blocks: `maps/PowerPlant.blk`
- Header: `data/maps/maps.asm:214` -> `TILESET_FACILITY, INDOOR, LANDMARK_POWER_PLANT, MUSIC_VIRIDIAN_CITY, FALSE (no phone), PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:196` `map_const POWER_PLANT, 10, 9` (group `CERULEAN`, id 10)
- Attributes / border: `data/maps/attributes.asm:523` `map_attributes PowerPlant, POWER_PLANT, $00`; no connections

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 17 | `ROUTE_10_NORTH` | 2 |
| 2 | 3 | 17 | `ROUTE_10_NORTH` | 2 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_POWERPLANT_GUARD_GETS_PHONE_CALL` | 5 | 12 | `PowerPlantGuardPhoneScript` | Officer 1 gets the Cerulean call cutscene, then `setscene SCENE_POWERPLANT_NOOP` |

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `PowerPlantBookshelf` (`jumpstd DifficultBookshelfScript`) |
| 1 | 1 | `BGEVENT_READ` | `PowerPlantBookshelf` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `POWERPLANT_OFFICER1` | `SPRITE_OFFICER` | 4 | 14 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `PowerPlantOfficerScript` | -1 |
| `POWERPLANT_GYM_GUIDE1` | `SPRITE_GYM_GUIDE` | 2 | 9 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `PowerPlantGymGuide1Script` | -1 |
| `POWERPLANT_GYM_GUIDE2` | `SPRITE_GYM_GUIDE` | 6 | 11 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `PowerPlantGymGuide2Script` | -1 |
| `POWERPLANT_OFFICER2` | `SPRITE_OFFICER` | 9 | 3 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `PowerPlantOfficer2Script` | -1 |
| `POWERPLANT_GYM_GUIDE3` | `SPRITE_GYM_GUIDE` | 7 | 2 | `WALK_LEFT_RIGHT` (radius 1,0) | `OBJECTTYPE_SCRIPT` | `PowerPlantGymGuide4Script` | -1 |
| `POWERPLANT_MANAGER` | `SPRITE_FISHER` | 14 | 10 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `PowerPlantManager` | -1 |

**Scripts of interest**

- `PowerPlantManager` (`54:4dbd`). Branch order is: `checkevent EVENT_RETURNED_MACHINE_PART` -> `.ReturnedMachinePart`; else `checkitem MACHINE_PART` -> `.FoundMachinePart`; else `checkevent EVENT_MET_MANAGER_AT_POWER_PLANT` -> `.MetManager`; else the first-meeting text which does `setevent EVENT_MET_MANAGER_AT_POWER_PLANT`, `clearevent EVENT_CERULEAN_GYM_ROCKET`, `clearevent EVENT_FOUND_MACHINE_PART_IN_CERULEAN_GYM`, `setmapscene CERULEAN_GYM, SCENE_CERULEANGYM_GRUNT_RUNS_OUT`, `setscene SCENE_POWERPLANT_GUARD_GETS_PHONE_CALL`.
  `.FoundMachinePart` does `takeitem MACHINE_PART`, `setevent EVENT_RETURNED_MACHINE_PART`, `clearevent EVENT_SAFFRON_TRAIN_STATION_POPULATION`, `setevent EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH`, `setevent EVENT_ROUTE_24_ROCKET`, `setevent EVENT_RESTORED_POWER_TO_KANTO`, `clearevent EVENT_GOLDENROD_TRAIN_STATION_GENTLEMAN`, then falls through to `.ReturnedMachinePart`.
  `.ReturnedMachinePart` gates on `EVENT_GOT_TM07_ZAP_CANNON`; otherwise `verbosegiveitem TM_ZAP_CANNON` and `setevent EVENT_GOT_TM07_ZAP_CANNON`.

  **Bot note:** the section as written assumes `EVENT_RETURNED_MACHINE_PART` is
  already set from the previous section. If it is, the TM is one `A` press on
  the manager. If the part is still in the bag, the same talk both takes the
  part and awards the TM in one conversation.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_RETURNED_MACHINE_PART` | `constants/event_flags.asm:200` | set by `PowerPlantManager.FoundMachinePart`; read by every other NPC on this map, `LavRadioTower1FGentlemanScript`, `Copycat`, `CopycatsHouse1FPokefanFScript`, `PokemonFanClubClefairyGuyScript`, `Route7SaffronGuardScript`, `SaffronMagnetTrainStationGymGuideScript` | the master gate for this whole chapter |
| `EVENT_MET_MANAGER_AT_POWER_PLANT` | `constants/event_flags.asm:201` | set/read by `PowerPlantManager` | first-meeting bookkeeping |
| `EVENT_RESTORED_POWER_TO_KANTO` | `constants/event_flags.asm:204` | set by `PowerPlantManager.FoundMachinePart`; read by `SaffronMagnetTrainStationOfficerScript` | Magnet Train power gate |
| `EVENT_GOT_TM07_ZAP_CANNON` | `constants/event_flags.asm:222` | `PowerPlantManager` | one-time TM |
| `SCENE_POWERPLANT_NOOP` / `SCENE_POWERPLANT_GUARD_GETS_PHONE_CALL` | scene ids in `PowerPlant_MapScripts` `def_scene_scripts` | `setscene` in `PowerPlantManager`, coord event at (5,12) | scene 1 makes the (5,12) trip-wire live |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `TM_ZAP_CANNON` (TM07) | talk to `POWERPLANT_MANAGER` at (14,10) | `PowerPlantManager` -> `verbosegiveitem TM_ZAP_CANNON` | `EVENT_GOT_TM07_ZAP_CANNON` |

**Trainers** - none.

**Wild encounters** - none (INDOOR, no `def_grass_wildmons` entry).

---

### MAP_ROCK_TUNNEL_1F

- Script: `maps/RockTunnel1F.asm`
- Blocks: `maps/RockTunnel1F.blk`
- Header: `data/maps/maps.asm:156` -> `TILESET_DARK_CAVE, CAVE, LANDMARK_ROCK_TUNNEL, MUSIC_MT_MOON, TRUE (phone/"can be called from"), PALETTE_DARK, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:143` `map_const ROCK_TUNNEL_1F, 15, 18` (group `DUNGEONS`, id 78) -> 30 x 36 cells
- Attributes: `data/maps/attributes.asm:490` `map_attributes RockTunnel1F, ROCK_TUNNEL_1F, $09`; no connections
- `PALETTE_DARK` is what makes `FlashFunction` legal here (see section 3)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 15 | 3 | `ROUTE_9` | 1 |
| 2 | 11 | 25 | `ROUTE_10_SOUTH` | 1 |
| 3 | 5 | 3 | `ROCK_TUNNEL_B1F` | 3 |
| 4 | 15 | 9 | `ROCK_TUNNEL_B1F` | 2 |
| 5 | 27 | 3 | `ROCK_TUNNEL_B1F` | 4 |
| 6 | 27 | 13 | `ROCK_TUNNEL_B1F` | 1 |

**Coord events** - none (`def_coord_events` empty).

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 24 | 4 | `BGEVENT_ITEM` | `RockTunnel1FHiddenXAccuracy` -> `hiddenitem X_ACCURACY, EVENT_ROCK_TUNNEL_1F_HIDDEN_X_ACCURACY` |
| 21 | 15 | `BGEVENT_ITEM` | `RockTunnel1FHiddenXDefend` -> `hiddenitem X_DEFEND, EVENT_ROCK_TUNNEL_1F_HIDDEN_X_DEFEND` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROCKTUNNEL1F_POKE_BALL1` | `SPRITE_POKE_BALL` | 4 | 18 | `STILL` | `OBJECTTYPE_ITEMBALL` | `RockTunnel1FElixer` (`itemball ELIXER`) | `EVENT_ROCK_TUNNEL_1F_ELIXER` |
| `ROCKTUNNEL1F_POKE_BALL2` | `SPRITE_POKE_BALL` | 10 | 15 | `STILL` | `OBJECTTYPE_ITEMBALL` | `RockTunnel1FTMSteelWing` (`itemball TM_STEEL_WING`, `42:58df`) | `EVENT_ROCK_TUNNEL_1F_TM_STEEL_WING` |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `ELIXER` | ball at (4,18) | `RockTunnel1FElixer` | `EVENT_ROCK_TUNNEL_1F_ELIXER` |
| `TM_STEEL_WING` (TM47) | ball at (10,15) | `RockTunnel1FTMSteelWing` | `EVENT_ROCK_TUNNEL_1F_TM_STEEL_WING` |
| `X_ACCURACY` | hidden, face (24,4) | `bg_event` `BGEVENT_ITEM` | `EVENT_ROCK_TUNNEL_1F_HIDDEN_X_ACCURACY` |
| `X_DEFEND` | hidden, face (21,15) | `bg_event` `BGEVENT_ITEM` | `EVENT_ROCK_TUNNEL_1F_HIDDEN_X_DEFEND` |

**Trainers** - none.

**Wild encounters** - `data/wild/kanto_grass.asm`, `def_grass_wildmons ROCK_TUNNEL_1F`,
rates `6 percent, 6 percent, 6 percent` (morn/day/nite). All three time slots are
identical:

```
db 10, CUBONE
db 10, GEODUDE
db 12, MACHOP
db  8, ZUBAT
db 14, MACHOKE
db 13, CUBONE
db 13, CUBONE
```

---

### MAP_ROCK_TUNNEL_B1F

- Script: `maps/RockTunnelB1F.asm`
- Blocks: `maps/RockTunnelB1F.blk`
- Header: `data/maps/maps.asm:157` -> `TILESET_DARK_CAVE, CAVE, LANDMARK_ROCK_TUNNEL, MUSIC_MT_MOON, TRUE, PALETTE_DARK, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:144` `map_const ROCK_TUNNEL_B1F, 15, 18`
- Attributes: `data/maps/attributes.asm:491` `map_attributes RockTunnelB1F, ROCK_TUNNEL_B1F, $09`; no connections

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 3 | `ROCK_TUNNEL_1F` | 6 |
| 2 | 17 | 9 | `ROCK_TUNNEL_1F` | 4 |
| 3 | 23 | 3 | `ROCK_TUNNEL_1F` | 3 |
| 4 | 25 | 23 | `ROCK_TUNNEL_1F` | 5 |

**Coord events** - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 4 | 14 | `BGEVENT_ITEM` | `RockTunnelB1FHiddenMaxPotion` -> `hiddenitem MAX_POTION, EVENT_ROCK_TUNNEL_B1F_HIDDEN_MAX_POTION` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROCKTUNNELB1F_POKE_BALL1` | `SPRITE_POKE_BALL` | 7 | 25 | `STILL` | `OBJECTTYPE_ITEMBALL` | `RockTunnelB1FIron` (`42:5931`) | `EVENT_ROCK_TUNNEL_B1F_IRON` |
| `ROCKTUNNELB1F_POKE_BALL2` | `SPRITE_POKE_BALL` | 6 | 17 | `STILL` | `OBJECTTYPE_ITEMBALL` | `RockTunnelB1FPPUp` (`42:5933`) | `EVENT_ROCK_TUNNEL_B1F_PP_UP` |
| `ROCKTUNNELB1F_POKE_BALL3` | `SPRITE_POKE_BALL` | 15 | 2 | `STILL` | `OBJECTTYPE_ITEMBALL` | `RockTunnelB1FRevive` (`42:5935`) | `EVENT_ROCK_TUNNEL_B1F_REVIVE` |

**Wild encounters** - `data/wild/kanto_grass.asm`, `def_grass_wildmons ROCK_TUNNEL_B1F`,
rates `6 percent` in all three slots, and all three slots identical:

```
db 12, CUBONE
db 12, GEODUDE
db 16, ONIX
db 10, ZUBAT
db 14, MAROWAK
db 14, KANGASKHAN
db 14, KANGASKHAN
```

(Kangaskhan is a B1F-only slot 6/7 encounter - the walkthrough lists it under
"Rock Tunnel" generally.)

---

### MAP_ROUTE_10_SOUTH

- Script: `maps/Route10South.asm`
- Blocks: `maps/Route10South.blk`
- Header: `data/maps/maps.asm:380` -> `TILESET_KANTO, ROUTE, LANDMARK_ROUTE_10, MUSIC_ROUTE_3, FALSE, PALETTE_AUTO, FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:351` `map_const ROUTE_10_SOUTH, 10, 9` (group `LAVENDER`, id 3)
- Connections (`data/maps/attributes.asm`, `map_attributes Route10South, ROUTE_10_SOUTH, $2c`):
  `connection north, Route10North, ROUTE_10_NORTH, 0`, `connection south, LavenderTown, LAVENDER_TOWN, 0`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 6 | 1 | `ROCK_TUNNEL_1F` | 2 |

**Coord events** - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 5 | 3 | `BGEVENT_READ` | `Route10Sign` (`jumptext Route10SignText`) |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE10SOUTH_POKEFAN_M1` | `SPRITE_POKEFAN_M` | 17 | 3 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerHikerJim` (`50:574b`) | -1 |
| `ROUTE10SOUTH_POKEFAN_M2` | `SPRITE_POKEFAN_M` | 4 | 10 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerPokefanmRobert` (`50:575f`) | -1 |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `HIKER`, `JIM` | Hiker (`constants/trainer_constants.asm:453`) | JIM | `"JIM@", TRAINERTYPE_NORMAL` / `db 35, MACHAMP` (line 110) | `TrainerHikerJim`, flag `EVENT_BEAT_HIKER_JIM` (`constants/event_flags.asm:834`) | no |
| `POKEFANM`, `ROBERT` | Pokefanm (`:601`) | ROBERT | `"ROBERT@", TRAINERTYPE_ITEM` / `db 33, QUAGSIRE, BERRY` (line 2971) | `TrainerPokefanmRobert`, flag `EVENT_BEAT_POKEFANM_ROBERT` (`:726`) | no |

Class base rewards: Hiker `db 8`, Pokefanm `db 20` (`data/trainers/attributes.asm`).

**Wild encounters** - **none**. There is no `def_grass_wildmons ROUTE_10_SOUTH`
entry in `data/wild/kanto_grass.asm` (the grass patch is on `ROUTE_10_NORTH`).

---

### MAP_LAVENDER_TOWN

- Script: `maps/LavenderTown.asm`
- Blocks: `maps/LavenderTown.blk`
- Header: `data/maps/maps.asm:381` -> `TILESET_KANTO, TOWN, LANDMARK_LAVENDER_TOWN, MUSIC_LAVENDER_TOWN, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:352` `map_const LAVENDER_TOWN, 10, 9`
- Connections (`map_attributes LavenderTown, LAVENDER_TOWN, $2c`):
  `connection north, Route10South, ROUTE_10_SOUTH, 0`,
  `connection south, Route12, ROUTE_12, 0`,
  `connection west, Route8, ROUTE_8, 0`

**Callbacks**: `callback MAPCALLBACK_NEWMAP, LavenderTownFlypointCallback` ->
`setflag ENGINE_FLYPOINT_LAVENDER` (`constants/engine_flags.asm:73`).

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 5 | `LAVENDER_POKECENTER_1F` | 1 |
| 2 | 5 | 9 | `MR_FUJIS_HOUSE` | 1 |
| 3 | 3 | 13 | `LAVENDER_SPEECH_HOUSE` | 1 |
| 4 | 7 | 13 | `LAVENDER_NAME_RATER` | 1 |
| 5 | 1 | 5 | `LAVENDER_MART` | 2 |
| 6 | 13 | 11 | `SOUL_HOUSE` | 1 |
| 7 | 14 | 5 | `LAV_RADIO_TOWER_1F` | 1 |

**Coord events** - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 11 | 3 | `BGEVENT_READ` | `LavenderTownSign` |
| 15 | 7 | `BGEVENT_READ` | `KantoRadioStationSign` |
| 3 | 9 | `BGEVENT_READ` | `VolunteerPokemonHouseSign` |
| 15 | 13 | `BGEVENT_READ` | `SoulHouseSign` |
| 6 | 5 | `BGEVENT_READ` | `LavenderPokecenterSignText` (`jumpstd PokecenterSignScript`) |
| 2 | 5 | `BGEVENT_READ` | `LavenderMartSignText` (`jumpstd MartSignScript`) |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `LAVENDERTOWN_POKEFAN_M` | `SPRITE_POKEFAN_M` | 12 | 7 | `WALK_LEFT_RIGHT` (1,0) | `OBJECTTYPE_SCRIPT` | `LavenderTownPokefanMScript` | -1 |
| `LAVENDERTOWN_TEACHER` | `SPRITE_TEACHER` | 2 | 15 | `WALK_LEFT_RIGHT` (1,0) | `OBJECTTYPE_SCRIPT` | `LavenderTownTeacherScript` | -1 |
| `LAVENDERTOWN_GRAMPS` | `SPRITE_GRAMPS` | 14 | 12 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `LavenderTownGrampsScript` | -1 |
| `LAVENDERTOWN_YOUNGSTER` | `SPRITE_YOUNGSTER` | 6 | 11 | `WALK_LEFT_RIGHT` (1,0) | `OBJECTTYPE_SCRIPT` | `LavenderTownYoungsterScript` | -1 |

**Notes for the walkthrough's Lavender claims**

- Mr. Fuji is `MrFuji`, `object_event 4, 2, SPRITE_GRAMPS` in `maps/SoulHouse.asm:85`
  (warp 6 of Lavender Town), so the walkthrough is right that he is in the Soul
  House. `MR_FUJIS_HOUSE` (warp 2, `maps/MrFujisHouse.asm`) is the *Volunteer
  Pokemon House* and contains no Fuji object.
- Name Rater is warp 4 -> `LAVENDER_NAME_RATER` (`maps/LavenderNameRater.asm`).

**Wild encounters** - none in town.

---

### MAP_LAV_RADIO_TOWER_1F

- Script: `maps/LavRadioTower1F.asm`
- Header: `data/maps/maps.asm:389` -> `TILESET_RADIO_TOWER, INDOOR, LANDMARK_LAV_RADIO_TOWER, MUSIC_LAVENDER_TOWN, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:360` `map_const LAV_RADIO_TOWER_1F, 10, 4`
- Attributes: `data/maps/attributes.asm:620` `map_attributes LavRadioTower1F, LAV_RADIO_TOWER_1F, $00`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `LAVENDER_TOWN` | 7 |
| 2 | 3 | 7 | `LAVENDER_TOWN` | 7 |

**Coord events** - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 11 | 0 | `BGEVENT_READ` | `LavRadioTower1FDirectory` |
| 5 | 0 | `BGEVENT_READ` | `LavRadioTower1FPokeFluteSign` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `LAVRADIOTOWER1F_RECEPTIONIST` | `SPRITE_RECEPTIONIST` | 6 | 6 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `LavRadioTower1FReceptionistScript` | -1 |
| `LAVRADIOTOWER1F_OFFICER` | `SPRITE_OFFICER` | 15 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `LavRadioTower1FOfficerScript` | -1 |
| `LAVRADIOTOWER1F_SUPER_NERD1` | `SPRITE_SUPER_NERD` | 1 | 3 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `LavRadioTower1FSuperNerd1Script` | -1 |
| `LAVRADIOTOWER1F_GENTLEMAN` | `SPRITE_GENTLEMAN` | 9 | 1 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `LavRadioTower1FGentlemanScript` (`5d:479f`) | -1 |
| `LAVRADIOTOWER1F_SUPER_NERD2` | `SPRITE_SUPER_NERD` | 14 | 6 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `LavRadioTower1FSuperNerd2Script` | -1 |

**Scripts of interest**

- `LavRadioTower1FGentlemanScript`: `checkflag ENGINE_EXPN_CARD` -> already got
  it; else `checkevent EVENT_RETURNED_MACHINE_PART` -> `.ReturnedMachinePart`,
  which prints the thank-you, `getstring STRING_BUFFER_4, .expncardname`
  (`db "EXPN CARD@"`), `scall .receiveitem` (`jumpstd ReceiveItemScript`) and
  `setflag ENGINE_EXPN_CARD`. Note this is a **flag**, not a bag item - nothing
  enters the inventory.
- The upstairs floors are blocked by dialogue only (`LavRadioTower1FOfficerScript`
  is flavour text); the map has no warp to 2F.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_EXPN_CARD` | `constants/engine_flags.asm:7` | set by `LavRadioTower1FGentlemanScript`; read by the Pokegear radio | Kanto radio channels unlock |
| `EVENT_RETURNED_MACHINE_PART` | `constants/event_flags.asm:200` | read here | precondition for the gift |

---

### MAP_ROUTE_8

- Script: `maps/Route8.asm`
- Blocks: `maps/Route8.blk`
- Header: `data/maps/maps.asm:378` -> `TILESET_KANTO, ROUTE, LANDMARK_ROUTE_8, MUSIC_ROUTE_3, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:349` `map_const ROUTE_8, 20, 9`
- Connections (`map_attributes Route8, ROUTE_8, $2c`):
  `connection west, SaffronCity, SAFFRON_CITY, -9`, `connection east, LavenderTown, LAVENDER_TOWN, 0`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 4 | `ROUTE_8_SAFFRON_GATE` | 3 |
| 2 | 4 | 5 | `ROUTE_8_SAFFRON_GATE` | 4 |

**Coord events** - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 11 | 7 | `BGEVENT_READ` | `Route8UndergroundPathSign` |
| 10 | 5 | `BGEVENT_READ` | `Route8LockedDoor` ("It's locked...") |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE8_BIKER1` | `SPRITE_BIKER` | 10 | 8 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 5 | `TrainerBikerDwayne` | -1 |
| `ROUTE8_BIKER2` | `SPRITE_BIKER` | 10 | 9 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 5 | `TrainerBikerHarris` | -1 |
| `ROUTE8_BIKER3` | `SPRITE_BIKER` | 10 | 10 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 5 | `TrainerBikerZeke` | -1 |
| `ROUTE8_SUPER_NERD1` | `SPRITE_SUPER_NERD` | 20 | 6 | `STANDING_UP` | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerSupernerdSam` | -1 |
| `ROUTE8_SUPER_NERD2` | `SPRITE_SUPER_NERD` | 27 | 9 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerSupernerdTom` | -1 |
| `ROUTE8_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 33 | 5 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route8FruitTree` (`fruittree FRUITTREE_ROUTE_8`, `50:53ed`) | -1 |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `PRZCUREBERRY` | face the tree object at (33,5) and press A | `fruittree FRUITTREE_ROUTE_8` (`constants/script_constants.asm:233`), item from `data/items/fruit_trees.asm:30` `db PRZCUREBERRY ; ROUTE_8` | daily fruit-tree flag (`TryResetFruitTrees`), **not** a one-shot event flag |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `SUPER_NERD`, `TOM` | Super Nerd (`:417`) | TOM | `db 32, MAGNEMITE` x3 (parties.asm:2002) | `TrainerSupernerdTom`, `EVENT_BEAT_SUPER_NERD_TOM` (`:925`) | no |
| `SUPER_NERD`, `SAM` | Super Nerd (`:416`) | SAM | `db 34, GRIMER` / `db 34, MUK` (parties.asm:1996) | `TrainerSupernerdSam`, `EVENT_BEAT_SUPER_NERD_SAM` (`:924`) | no |
| `BIKER`, `ZEKE` | Biker (`:463`) | ZEKE | `db 32, KOFFING` x2 (parties.asm:2272) | `TrainerBikerZeke`, `EVENT_BEAT_BIKER_ZEKE` (`:557`) | no |
| `BIKER`, `HARRIS` | Biker (`:462`) | HARRIS | `db 34, FLAREON` (parties.asm:2267) | `TrainerBikerHarris`, `EVENT_BEAT_BIKER_HARRIS` (`:556`) | no |
| `BIKER`, `DWAYNE` | Biker (`:461`) | DWAYNE | `db 27/28/29/30, KOFFING` (parties.asm:2259) | `TrainerBikerDwayne`, `EVENT_BEAT_BIKER_DWAYNE` (`:555`) | no |

Class base rewards: Super Nerd `db 8`, Biker `db 8` (`data/trainers/attributes.asm`).

**Wild encounters** - `data/wild/kanto_grass.asm`, `def_grass_wildmons ROUTE_8`,
rates `10 percent` in all slots. Gold branch (`IF DEF(_GOLD)`):

| slot | morn | day | nite |
|---|---|---|---|
| 1 | 17 PIDGEOTTO | 17 PIDGEOTTO | 17 NOCTOWL |
| 2 | 19 PIDGEOTTO | 19 PIDGEOTTO | 20 HAUNTER |
| 3 | 15 ABRA | 15 ABRA | 15 ABRA |
| 4 | 18 GROWLITHE | 18 GROWLITHE | 19 NOCTOWL |
| 5 | 17 PIDGEOTTO | 17 PIDGEOTTO | 18 GROWLITHE |
| 6 | 15 KADABRA | 15 KADABRA | 15 KADABRA |
| 7 | 15 KADABRA | 15 KADABRA | 15 KADABRA |

---

### MAP_SAFFRON_CITY (transit + Copycat)

- Script: `maps/SaffronCity.asm`
- Header: `data/maps/maps.asm:490` -> `TILESET_KANTO, TOWN, LANDMARK_SAFFRON_CITY, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:454` `map_const SAFFRON_CITY, 20, 18`
- Connections: `connection north, Route5`, `connection south, Route6`,
  `connection west, Route7, ROUTE_7, 9`, `connection east, Route8, ROUTE_8, 9`

**Warps used by this section** (full table in `maps/SaffronCity.asm:269`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 6 | 8 | 3 | `SAFFRON_MAGNET_TRAIN_STATION` | 2 |
| 8 | 9 | 11 | `COPYCATS_HOUSE_1F` | 1 |
| 10 | 0 | 24 | `ROUTE_7_SAFFRON_GATE` | 3 |
| 11 | 0 | 25 | `ROUTE_7_SAFFRON_GATE` | 4 |
| 14 | 39 | 22 | `ROUTE_8_SAFFRON_GATE` | 1 |
| 15 | 39 | 23 | `ROUTE_8_SAFFRON_GATE` | 2 |

**Magnet train gate** (`maps/SaffronMagnetTrainStation.asm`,
`SaffronMagnetTrainStationOfficerScript`): `checkevent EVENT_RESTORED_POWER_TO_KANTO`
-> if clear, "train isn't operating"; if set, yes/no then `checkitem PASS` ->
if absent, "you don't have a PASS"; if present, movement + `setval TRUE` +
`special MagnetTrain` + `newloadmap MAPSETUP_TRAIN`.

---

### MAP_COPYCATS_HOUSE_1F

- Script: `maps/CopycatsHouse1F.asm`
- Header: `data/maps/maps.asm:499` -> `TILESET_PLAYERS_HOUSE, INDOOR, LANDMARK_SAFFRON_CITY, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:463` `map_const COPYCATS_HOUSE_1F, 4, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `SAFFRON_CITY` | 8 |
| 2 | 3 | 7 | `SAFFRON_CITY` | 8 |
| 3 | 2 | 0 | `COPYCATS_HOUSE_2F` | 1 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `COPYCATSHOUSE1F_POKEFAN_M` | `SPRITE_POKEFAN_M` | 2 | 3 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CopycatsHouse1FPokefanMScript` | -1 |
| `COPYCATSHOUSE1F_POKEFAN_F` | `SPRITE_POKEFAN_F` | 5 | 4 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `CopycatsHouse1FPokefanFScript` (branches on `EVENT_RETURNED_MACHINE_PART`) | -1 |
| `COPYCATSHOUSE1F_CLEFAIRY` | `SPRITE_CLEFAIRY` | 6 | 6 | `POKEMON` | `OBJECTTYPE_SCRIPT` | `CopycatsHouse1FBlisseyScript` | -1 |

---

### MAP_COPYCATS_HOUSE_2F

- Script: `maps/CopycatsHouse2F.asm`
- Header: `data/maps/maps.asm:500` -> `TILESET_PLAYERS_HOUSE, INDOOR, LANDMARK_SAFFRON_CITY, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:464` `map_const COPYCATS_HOUSE_2F, 5, 3`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 0 | `COPYCATS_HOUSE_1F` | 3 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `CopycatsHouse2FBookshelf` (`jumpstd PictureBookshelfScript`) |
| 1 | 1 | `BGEVENT_READ` | `CopycatsHouse2FBookshelf` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `COPYCATSHOUSE2F_COPYCAT` | `SPRITE_COPYCAT` | 4 | 3 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `Copycat` (`61:5235`) | -1 |
| `COPYCATSHOUSE2F_DODRIO` | `SPRITE_MOLTRES` | 6 | 4 | `POKEMON` | `OBJECTTYPE_SCRIPT` | `CopycatsDodrio` | -1 |
| `COPYCATSHOUSE2F_FAIRYDOLL` | `SPRITE_FAIRY` | 6 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CopycatsHouse2FDoll` | `EVENT_COPYCATS_HOUSE_2F_DOLL` |
| `COPYCATSHOUSE2F_MONSTERDOLL` | `SPRITE_MONSTER` | 2 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CopycatsHouse2FDoll` | -1 |
| `COPYCATSHOUSE2F_BIRDDOLL` | `SPRITE_BIRD` | 7 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CopycatsHouse2FDoll` | -1 |

**Scripts of interest** - `Copycat`, in check order:

1. `checkevent EVENT_GOT_PASS_FROM_COPYCAT` -> `.GotPass` (post-quest chatter)
2. `checkevent EVENT_RETURNED_LOST_ITEM_TO_COPYCAT` -> `.TryGivePassAgain`
   (the bag-was-full retry path)
3. `checkitem LOST_ITEM` -> `.ReturnLostItem`: `takeitem LOST_ITEM`,
   `setevent EVENT_RETURNED_LOST_ITEM_TO_COPYCAT`,
   `clearevent EVENT_COPYCATS_HOUSE_2F_DOLL` (the doll object reappears on her
   shelf), then falls into `.GivePass`
4. `.GivePass`: `verbosegiveitem PASS`, `iffalse .Cancel`,
   `setevent EVENT_GOT_PASS_FROM_COPYCAT`
5. Otherwise: spin-around movement, `variablesprite SPRITE_COPYCAT, SPRITE_CHRIS`
   + `special LoadUsedSpritesGFX` (the mimicry gag), then
   `checkevent EVENT_RETURNED_MACHINE_PART` -> `.TalkAboutLostItem`, which sets
   **`EVENT_MET_COPYCAT_FOUND_OUT_ABOUT_LOST_ITEM`**

Step 5 is mandatory before the Fan Club will hand over the doll.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_MET_COPYCAT_FOUND_OUT_ABOUT_LOST_ITEM` | `constants/event_flags.asm:206` | set by `Copycat.TalkAboutLostItem`; read by `PokemonFanClubClefairyGuyScript.MetCopycat` | unlocks the doll in Vermilion |
| `EVENT_RETURNED_LOST_ITEM_TO_COPYCAT` | `:207` | `Copycat` | doll handed back |
| `EVENT_GOT_PASS_FROM_COPYCAT` | `:208` | `Copycat` | PASS awarded |
| `EVENT_COPYCATS_HOUSE_2F_DOLL` | `:1301` | cleared by `Copycat.ReturnLostItem` | object visibility flag for the FAIRY doll at (6,1) |

---

### MAP_POKEMON_FAN_CLUB

- Script: `maps/PokemonFanClub.asm`
- Header: `data/maps/maps.asm:300` -> `TILESET_HOUSE, INDOOR, LANDMARK_VERMILION_CITY, MUSIC_VERMILION_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:277` `map_const POKEMON_FAN_CLUB, 5, 4` (group `VERMILION`, id 7)
- Attributes: `data/maps/attributes.asm:569` `map_attributes PokemonFanClub, POKEMON_FAN_CLUB, $00`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `VERMILION_CITY` | 3 |
| 2 | 3 | 7 | `VERMILION_CITY` | 3 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 7 | 0 | `BGEVENT_READ` | `PokemonFanClubListenSign` |
| 9 | 0 | `BGEVENT_READ` | `PokemonFanClubBraggingSign` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `POKEMONFANCLUB_CHAIRMAN` | `SPRITE_GENTLEMAN` | 3 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `PokemonFanClubChairmanScript` (RARE_CANDY) | -1 |
| `POKEMONFANCLUB_RECEPTIONIST` | `SPRITE_RECEPTIONIST` | 4 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `PokemonFanClubReceptionistScript` | -1 |
| `POKEMONFANCLUB_CLEFAIRY_GUY` | `SPRITE_FISHER` | 2 | 3 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `PokemonFanClubClefairyGuyScript` (`59:437b`) | -1 |
| `POKEMONFANCLUB_TEACHER` | `SPRITE_TEACHER` | 7 | 2 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `PokemonFanClubTeacherScript` | -1 |
| `POKEMONFANCLUB_FAIRY` | `SPRITE_FAIRY` | 2 | 4 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `PokemonFanClubClefairyDollScript` | `EVENT_VERMILION_FAN_CLUB_DOLL` |
| `POKEMONFANCLUB_ODDISH` | `SPRITE_ODDISH` | 7 | 3 | `POKEMON` | `OBJECTTYPE_SCRIPT` | `PokemonFanClubBayleefScript` | -1 |

**Scripts of interest** - `PokemonFanClubClefairyGuyScript` (`59:437b`):
`checkevent EVENT_GOT_LOST_ITEM_FROM_FAN_CLUB` -> done; else
`checkevent EVENT_RETURNED_MACHINE_PART` -> `.FoundClefairyDoll`, which then
`checkevent EVENT_MET_COPYCAT_FOUND_OUT_ABOUT_LOST_ITEM` -> `.MetCopycat`
(`59:439b`): `giveitem LOST_ITEM`, `iffalse .NoRoom`,
`disappear POKEMONFANCLUB_FAIRY`, `itemnotify`,
`setevent EVENT_GOT_LOST_ITEM_FROM_FAN_CLUB`.

Note this uses `giveitem`, not `verbosegiveitem`; the "received # DOLL" line is
written by the script itself (`PokemonFanClubPlayerReceivedDollText`).

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `LOST_ITEM` | talk to `POKEMONFANCLUB_CLEFAIRY_GUY` at (2,3) | `PokemonFanClubClefairyGuyScript.MetCopycat` | `EVENT_GOT_LOST_ITEM_FROM_FAN_CLUB` (`constants/event_flags.asm:209`) |
| `RARE_CANDY` | listen to the CHAIRMAN at (3,1), answer YES | `PokemonFanClubChairmanScript` | `EVENT_LISTENED_TO_FAN_CLUB_PRESIDENT` (`:211`) |

---

### MAP_ROUTE_7_SAFFRON_GATE

- Script: `maps/Route7SaffronGate.asm`
- Header: `data/maps/maps.asm:436` -> `TILESET_GATE, GATE, LANDMARK_ROUTE_7, MUSIC_ROUTE_3, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:404` `map_const ROUTE_7_SAFFRON_GATE, 5, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 4 | `ROUTE_7` | 1 |
| 2 | 0 | 5 | `ROUTE_7` | 2 |
| 3 | 9 | 4 | `SAFFRON_CITY` | 10 |
| 4 | 9 | 5 | `SAFFRON_CITY` | 11 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE7SAFFRONGATE_OFFICER` | `SPRITE_OFFICER` | 5 | 2 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route7SaffronGuardScript` | -1 |

**Scripts of interest** - `Route7SaffronGuardScript` is `faceplayer` + a
`checkevent EVENT_RETURNED_MACHINE_PART` two-way text switch. The "checks your
Pokedex as ID" line is `Route7SaffronGuardSeriousText`, flavour only. **There is
no coord event and no blocking movement here** - the guard does not gate the
gate.

---

### MAP_ROUTE_7

- Script: `maps/Route7.asm`
- Blocks: `maps/Route7.blk`
- Header: `data/maps/maps.asm:412` -> `TILESET_KANTO, ROUTE, LANDMARK_ROUTE_7, MUSIC_ROUTE_3, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:380` `map_const ROUTE_7, 10, 9` (group `CELADON`, id 1)
- Connections (`map_attributes Route7, ROUTE_7, $0f`):
  `connection west, CeladonCity, CELADON_CITY, -5`, `connection east, SaffronCity, SAFFRON_CITY, -9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 15 | 6 | `ROUTE_7_SAFFRON_GATE` | 1 |
| 2 | 15 | 7 | `ROUTE_7_SAFFRON_GATE` | 2 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 5 | 11 | `BGEVENT_READ` | `Route7UndergroundPathSign` (the "sealed indefinitely" flyer) |
| 6 | 9 | `BGEVENT_READ` | `Route7LockedDoor` |

**Object events** - `def_object_events` is empty. The walkthrough is correct
that Route 7 has no trainers.

**Wild encounters** - `data/wild/kanto_grass.asm`, `def_grass_wildmons ROUTE_7`,
rates `10 percent`. Gold branch:

| slot | morn | day | nite |
|---|---|---|---|
| 1 | 17 RATTATA | 17 RATTATA | 17 RATTATA |
| 2 | 17 SPEAROW | 17 SPEAROW | 17 MURKROW |
| 3 | 18 GROWLITHE | 18 GROWLITHE | 18 GROWLITHE |
| 4 | 19 RATICATE | 19 RATICATE | 19 RATICATE |
| 5 | 19 RATTATA | 19 RATTATA | 19 MURKROW |
| 6 | 15 RATTATA | 15 GROWLITHE | 15 HOUNDOUR |
| 7 | 15 RATTATA | 15 GROWLITHE | 15 HOUNDOUR |

(The Silver branch under `ELIF DEF(_SILVER)` is MEOWTH / VULPIX / PERSIAN.)

---

### MAP_CELADON_CITY

- Script: `maps/CeladonCity.asm`
- Blocks: `maps/CeladonCity.blk` (20 x 18 blocks, 360 bytes)
- Header: `data/maps/maps.asm:415` -> `TILESET_KANTO, TOWN, LANDMARK_CELADON_CITY, MUSIC_CELADON_CITY, FALSE, PALETTE_AUTO, FISHGROUP_NONE`
- Dimensions: `constants/map_constants.asm:383` `map_const CELADON_CITY, 20, 18` -> 40 x 36 cells
- Connections (`map_attributes CeladonCity, CELADON_CITY, $0f`):
  `connection west, Route16, ROUTE_16, 9`, `connection east, Route7, ROUTE_7, 5`

**Callbacks**: `callback MAPCALLBACK_NEWMAP, CeladonCityFlypointCallback` ->
`setflag ENGINE_FLYPOINT_CELADON` (`constants/engine_flags.asm:75`).

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 9 | `CELADON_DEPT_STORE_1F` | 1 |
| 2 | 16 | 9 | `CELADON_MANSION_1F` | 1 |
| 3 | 16 | 3 | `CELADON_MANSION_1F` | 3 |
| 4 | 17 | 3 | `CELADON_MANSION_1F` | 3 |
| 5 | 29 | 9 | `CELADON_POKECENTER_1F` | 1 |
| 6 | 18 | 19 | `CELADON_GAME_CORNER` | 1 |
| 7 | 23 | 19 | `CELADON_GAME_CORNER_PRIZE_ROOM` | 1 |
| 8 | 10 | 29 | `CELADON_GYM` | 1 |
| 9 | 25 | 29 | `CELADON_CAFE` | 1 |

Warps 3/4 at y=3 are the "hidden back door" the Youngster at (18,13) mentions.

**Coord events** - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 23 | 21 | `BGEVENT_READ` | `CeladonCitySign` |
| 11 | 31 | `BGEVENT_READ` | `CeladonGymSign` (ERIKA, "The Nature-Loving Princess") |
| 6 | 9 | `BGEVENT_READ` | `CeladonCityDeptStoreSign` |
| 13 | 9 | `BGEVENT_READ` | `CeladonCityMansionSign` |
| 19 | 21 | `BGEVENT_READ` | `CeladonCityGameCornerSign` |
| 29 | 21 | `BGEVENT_READ` | `CeladonCityTrainerTips` |
| 30 | 9 | `BGEVENT_READ` | `CeladonCityPokecenterSign` (`jumpstd PokecenterSignScript`) |
| 37 | 21 | `BGEVENT_ITEM` | `CeladonCityHiddenPpUp` (`4e:5b37`) -> `hiddenitem PP_UP, EVENT_CELADON_CITY_HIDDEN_PP_UP` |

The walkthrough's "head right to a dead end, press A and you'll get a random PP
Up" is this bg event at (37, 21). It is a fixed `PP_UP`, not random.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `CELADONCITY_FISHER` | `SPRITE_FISHER` | 26 | 11 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `CeladonCityFisherScript` | -1 |
| `CELADONCITY_POLIWAG` | `SPRITE_POLIWAG` | 27 | 11 | `POKEMON` | `OBJECTTYPE_SCRIPT` | `CeladonCityPoliwrath` | -1 |
| `CELADONCITY_TEACHER1` | `SPRITE_TEACHER` | 20 | 24 | `WALK_LEFT_RIGHT` (2,0) | `OBJECTTYPE_SCRIPT` | `CeladonCityTeacher1Script` | -1 |
| `CELADONCITY_GRAMPS1` | `SPRITE_GRAMPS` | 14 | 16 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CeladonCityGramps1Script` | -1 |
| `CELADONCITY_GRAMPS2` | `SPRITE_GRAMPS` | 8 | 31 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `CeladonCityGramps2Script` ("Only girls are allowed here!") | -1 |
| `CELADONCITY_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 18 | 13 | `WALK_LEFT_RIGHT` (2,0) | `OBJECTTYPE_SCRIPT` | `CeladonCityYoungster1Script` | -1 |
| `CELADONCITY_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 24 | 33 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `CeladonCityYoungster2Script` | -1 |
| `CELADONCITY_TEACHER2` | `SPRITE_TEACHER` | 6 | 14 | `WANDER` (2,2) | `OBJECTTYPE_SCRIPT` | `CeladonCityTeacher2Script` | -1 |
| `CELADONCITY_LASS` | `SPRITE_LASS` | 7 | 22 | `WALK_UP_DOWN` (0,2) | `OBJECTTYPE_SCRIPT` | `CeladonCityLassScript` | -1 |

The old man outside the gym is `CELADONCITY_GRAMPS2` at (8, 31).

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `PP_UP` | face (37,21), press A | `CeladonCityHiddenPpUp` bg event | `EVENT_CELADON_CITY_HIDDEN_PP_UP` (`constants/event_flags.asm:253`) |

**Wild encounters** - none (`FISHGROUP_NONE`, no grass entry).

---

### MAP_CELADON_MANSION_1F / 2F / 3F / ROOF / ROOF_HOUSE

- Scripts: `maps/CeladonMansion1F.asm`, `2F`, `3F`, `maps/CeladonMansionRoof.asm`, `maps/CeladonMansionRoofHouse.asm`
- Headers: `data/maps/maps.asm:423-427` -> all `TILESET_MANSION` except the roof
  house (`TILESET_HOUSE`), all `INDOOR, LANDMARK_CELADON_CITY, MUSIC_CELADON_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:391-395` -> 1F/2F/3F/ROOF `4, 5`; ROOF_HOUSE `4, 4`
- Attributes: `data/maps/attributes.asm:636-640` (roof is `$01`, the rest `$00`)

**Warps - 1F**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 6 | 9 | `CELADON_CITY` | 2 |
| 2 | 7 | 9 | `CELADON_CITY` | 2 |
| 3 | 3 | 0 | `CELADON_CITY` | 3 |
| 4 | 0 | 0 | `CELADON_MANSION_2F` | 1 |
| 5 | 7 | 0 | `CELADON_MANSION_2F` | 4 |

**Warps - 2F**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 0 | `CELADON_MANSION_1F` | 4 |
| 2 | 1 | 0 | `CELADON_MANSION_3F` | 2 |
| 3 | 6 | 0 | `CELADON_MANSION_3F` | 3 |
| 4 | 7 | 0 | `CELADON_MANSION_1F` | 5 |

**Warps - 3F**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 0 | `CELADON_MANSION_ROOF` | 1 |
| 2 | 1 | 0 | `CELADON_MANSION_2F` | 2 |
| 3 | 6 | 0 | `CELADON_MANSION_2F` | 3 |
| 4 | 7 | 0 | `CELADON_MANSION_ROOF` | 2 |

**Warps - ROOF**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 1 | 1 | `CELADON_MANSION_3F` | 1 |
| 2 | 6 | 1 | `CELADON_MANSION_3F` | 4 |
| 3 | 2 | 5 | `CELADON_MANSION_ROOF_HOUSE` | 1 |

**Warps - ROOF_HOUSE**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `CELADON_MANSION_ROOF` | 3 |
| 2 | 3 | 7 | `CELADON_MANSION_ROOF` | 3 |

**Object events - ROOF_HOUSE**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `CELADONMANSIONROOFHOUSE_PHARMACIST` | `SPRITE_PHARMACIST` | 3 | 2 | `STANDING_DOWN` (radius 0,2) | `OBJECTTYPE_SCRIPT` | `CeladonMansionRoofHousePharmacistScript` (`5e:5083`) | -1 |

**Scripts of interest** - `CeladonMansionRoofHousePharmacistScript`:
`checkevent EVENT_GOT_TM03_CURSE` -> `.GotCurse`; else intro text, then
**`checktime NITE`**; if false, "come back after sunset" and end; if true,
the Cycling Road story, `verbosegiveitem TM_CURSE`, `setevent EVENT_GOT_TM03_CURSE`.

**Object events - 3F** (the Game Freak dev room the walkthrough mentions):

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `CELADONMANSION3F_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 3 | 6 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `GameFreakGameDesignerScript` (diploma at full dex, `setevent EVENT_ENABLE_DIPLOMA_PRINTING`) | -1 |
| `CELADONMANSION3F_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 3 | 4 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `GameFreakGraphicArtistScript` | -1 |
| `CELADONMANSION3F_SUPER_NERD` | `SPRITE_SUPER_NERD` | 0 | 7 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `GameFreakProgrammerScript` | -1 |
| `CELADONMANSION3F_FISHER` | `SPRITE_FISHER` | 0 | 4 | `STANDING_UP` (radius 2,0) | `OBJECTTYPE_SCRIPT` | `GameFreakCharacterDesignerScript` | -1 |

**Object events - 1F**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `CELADONMANSION1F_GRANNY` | `SPRITE_GRANNY` | 1 | 5 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `CeladonMansionManager` | -1 |
| `CELADONMANSION1F_GROWLITHE1` | `SPRITE_GROWLITHE` | 2 | 6 | `POKEMON` | `OBJECTTYPE_SCRIPT` | `CeladonMansion1FMeowth` | -1 |
| `CELADONMANSION1F_CLEFAIRY` | `SPRITE_CLEFAIRY` | 3 | 4 | `POKEMON` | `OBJECTTYPE_SCRIPT` | `CeladonMansion1FClefairy` | -1 |
| `CELADONMANSION1F_GROWLITHE2` | `SPRITE_GROWLITHE` | 4 | 4 | `POKEMON` (radius 2,0) | `OBJECTTYPE_SCRIPT` | `CeladonMansion1FNidoranF` | -1 |

2F has `def_object_events` empty; its three bg events (PC at (0,3), meeting-room
sign at (5,8), bookshelf at (2,3)) are the whole floor.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `TM_CURSE` (TM03) | talk to the pharmacist at (3,2) in `CELADON_MANSION_ROOF_HOUSE` **at night** | `CeladonMansionRoofHousePharmacistScript` | `EVENT_GOT_TM03_CURSE` (`constants/event_flags.asm:217`) |

---

### MAP_CELADON_DEPT_STORE_1F..6F

- Scripts: `maps/CeladonDeptStore1F.asm` .. `6F.asm`, `maps/CeladonDeptStoreElevator.asm`
- Headers: `data/maps/maps.asm:416-422` -> `TILESET_MART, INDOOR, LANDMARK_CELADON_CITY, MUSIC_CELADON_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:384-390` -> each floor `8, 4`; elevator `2, 2`

**Warps - 1F**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 7 | 7 | `CELADON_CITY` | 1 |
| 2 | 8 | 7 | `CELADON_CITY` | 1 |
| 3 | 15 | 0 | `CELADON_DEPT_STORE_2F` | 2 |
| 4 | 2 | 0 | `CELADON_DEPT_STORE_ELEVATOR` | 1 |

**Marts** (`data/items/marts.asm`, referenced by `pokemart MARTTYPE_STANDARD, MART_*`)

| floor | mart label | contents |
|---|---|---|
| 2F clerk A | `MartCeladon2F1` (line 290) | POTION, SUPER_POTION, HYPER_POTION, MAX_POTION, REVIVE, SUPER_REPEL, MAX_REPEL |
| 2F clerk B | `MartCeladon2F2` (line 301) | POKE_BALL, GREAT_BALL, ULTRA_BALL, ESCAPE_ROPE, FULL_HEAL, ANTIDOTE, BURN_HEAL, ICE_HEAL, AWAKENING, PARLYZ_HEAL |
| 3F | `MartCeladon3F` (line 315) | TM_HIDDEN_POWER (TM10), TM_SUNNY_DAY (TM11), TM_PROTECT (TM17), TM_RAIN_DANCE (TM18), TM_SANDSTORM (TM37) |
| 4F | `MartCeladon4F` (line 324) | POKE_DOLL, LOVELY_MAIL, SURF_MAIL |
| 5F clerk A | `MartCeladon5F1` (line 331) | HP_UP, PROTEIN, IRON, CARBOS, CALCIUM |
| 5F clerk B | `MartCeladon5F2` (line 344) | X_ACCURACY, GUARD_SPEC, DIRE_HIT, X_ATTACK, X_DEFEND, X_SPEED, X_SPECIAL |
| 6F | none | four `BGEVENT_UP` vending machines at (8,1), (9,1), (10,1), (11,1) -> `CeladonDeptStore6FVendingMachine` |

This matches the walkthrough's floor list exactly.

---

### MAP_CELADON_GAME_CORNER / MAP_CELADON_GAME_CORNER_PRIZE_ROOM

- Scripts: `maps/CeladonGameCorner.asm`, `maps/CeladonGameCornerPrizeRoom.asm`
- Headers: `data/maps/maps.asm:430-431` -> `TILESET_GAME_CORNER, INDOOR, LANDMARK_CELADON_CITY`; Game Corner uses `MUSIC_GAME_CORNER`, the prize room `MUSIC_CELADON_CITY`
- Dimensions: `constants/map_constants.asm:398-399` -> `CELADON_GAME_CORNER 10, 7`; `CELADON_GAME_CORNER_PRIZE_ROOM 3, 3`

**Warps - Game Corner**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 14 | 13 | `CELADON_CITY` | 6 |
| 2 | 15 | 13 | `CELADON_CITY` | 6 |

**Warps - Prize Room**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 5 | `CELADON_CITY` | 7 |
| 2 | 3 | 5 | `CELADON_CITY` | 7 |

**BG events - Prize Room**

| x | y | type | script/item |
|---|---|---|---|
| 2 | 1 | `BGEVENT_READ` | `CeladonGameCornerPrizeRoomTMVendor` |
| 4 | 1 | `BGEVENT_READ` | `CeladonGameCornerPrizeRoomPokemonVendor` |

**Object events - Prize Room**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `CELADONGAMECORNERPRIZEROOM_GENTLEMAN` | `SPRITE_GENTLEMAN` | 0 | 2 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CeladonGameCornerPrizeRoomGentlemanScript` | -1 |
| `CELADONGAMECORNERPRIZEROOM_PHARMACIST` | `SPRITE_PHARMACIST` | 4 | 4 | `WALK_UP_DOWN` (0,1) | `OBJECTTYPE_SCRIPT` | `CeladonGameCornerPrizeRoomPharmacistScript` | -1 |

**Prize prices** - `EQU` constants at the top of `maps/CeladonGameCornerPrizeRoom.asm`:

| prize | constant | coins |
|---|---|---|
| `TM_DOUBLE_TEAM` (TM32) | `CELADONGAMECORNERPRIZEROOM_TM32_COINS` | 1500 |
| `TM_PSYCHIC_M` (TM29) | `CELADONGAMECORNERPRIZEROOM_TM29_COINS` | 3500 |
| `TM_HYPER_BEAM` (TM15) | `CELADONGAMECORNERPRIZEROOM_TM15_COINS` | 7500 |
| `MR__MIME` @ L15 | `CELADONGAMECORNERPRIZEROOM_MR_MIME_COINS` | 3333 |
| `EEVEE` @ L15 | `CELADONGAMECORNERPRIZEROOM_EEVEE_COINS` | 6666 |
| `PORYGON` @ L20 | `CELADONGAMECORNERPRIZEROOM_PORYGON_COINS` | 9999 |

Both vendors open with `checkitem COIN_CASE` / `iffalse CeladonPrizeRoom_NoCoinCase`.
The mon counter additionally does `readvar VAR_PARTYCOUNT` /
`ifequal PARTY_LENGTH, CeladonPrizeRoom_notenoughroom` before the purchase, then
`setval <species>` + `special GameCornerPrizeMonCheckDex` + `givepoke`.

---

### MAP_CELADON_CAFE

- Script: `maps/CeladonCafe.asm`
- Header: `data/maps/maps.asm:433` -> `TILESET_GAME_CORNER, INDOOR, LANDMARK_CELADON_CITY, MUSIC_CELADON_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:401` `map_const CELADON_CAFE, 6, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 6 | 7 | `CELADON_CITY` | 9 |
| 2 | 7 | 7 | `CELADON_CITY` | 9 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 5 | 0 | `BGEVENT_READ` | `EatathonContestPoster` |
| 7 | 1 | `BGEVENT_READ` | `CeladonCafeTrashcan` (`5e:648c`) |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `CELADONCAFE_SUPER_NERD` | `SPRITE_SUPER_NERD` | 9 | 3 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `CeladonCafeChef` | -1 |
| `CELADONCAFE_FISHER1` | `SPRITE_FISHER` | 4 | 6 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `CeladonCafeFisher1` | -1 |
| `CELADONCAFE_FISHER2` | `SPRITE_FISHER` | 1 | 7 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `CeladonCafeFisher2` | -1 |
| `CELADONCAFE_FISHER3` | `SPRITE_FISHER` | 1 | 2 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `CeladonCafeFisher3` | -1 |
| `CELADONCAFE_TEACHER` | `SPRITE_TEACHER` | 4 | 3 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `CeladonCafeTeacher` (`checkitem COIN_CASE` branch) | -1 |

**Scripts of interest** - `CeladonCafeTrashcan` (`maps/CeladonCafe.asm:91`):
`checkevent EVENT_FOUND_LEFTOVERS_IN_CELADON_CAFE` -> `.TrashEmpty`
(`jumpstd TrashCanScript`); else `giveitem LEFTOVERS`, `iffalse .PackFull`,
`getitemname STRING_BUFFER_3, LEFTOVERS`, `writetext FoundLeftoversText`,
`itemnotify`, `setevent EVENT_FOUND_LEFTOVERS_IN_CELADON_CAFE`. Note the flag is
only set on success, so a full pack is retryable.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `LEFTOVERS` | face (7,1) and press A | `CeladonCafeTrashcan` bg event | `EVENT_FOUND_LEFTOVERS_IN_CELADON_CAFE` (`constants/event_flags.asm:249`) |

---

### MAP_CELADON_GYM

- Script: `maps/CeladonGym.asm`
- Blocks: `maps/CeladonGym.blk`
- Header: `data/maps/maps.asm:432` -> `TILESET_TRAIN_STATION, INDOOR, LANDMARK_CELADON_CITY, MUSIC_GYM, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:400` `map_const CELADON_GYM, 5, 9` -> 10 x 18 cells
- Attributes: `data/maps/attributes.asm:645` `map_attributes CeladonGym, CELADON_GYM, $00`; no connections

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 17 | `CELADON_CITY` | 8 |
| 2 | 5 | 17 | `CELADON_CITY` | 8 |

**Coord events** - none (`def_coord_events` empty). There is no scripted
lock-in; the maze is pure geometry.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 3 | 15 | `BGEVENT_READ` | `CeladonGymStatue` |
| 6 | 15 | `BGEVENT_READ` | `CeladonGymStatue` |

`CeladonGymStatue` is `checkflag ENGINE_RAINBOWBADGE` -> `.Beaten`
(`gettrainername STRING_BUFFER_4, ERIKA, ERIKA1` + `jumpstd GymStatue2Script`),
else `jumpstd GymStatue1Script`. A cheap post-badge assertion for a bot.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `CELADONGYM_ERIKA` | `SPRITE_ERIKA` | 5 | 3 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CeladonGymErikaScript` (`5e:5e0b`) | -1 |
| `CELADONGYM_LASS1` | `SPRITE_LASS` | 7 | 8 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerLassMichelle` | -1 |
| `CELADONGYM_LASS2` | `SPRITE_LASS` | 2 | 8 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerPicnickerTanya` | -1 |
| `CELADONGYM_BEAUTY` | `SPRITE_BEAUTY` | 3 | 5 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerBeautyJulia` | -1 |
| `CELADONGYM_TWIN1` | `SPRITE_TWIN` | 4 | 10 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 1 | `TrainerTwinsJoAndZoe1` | -1 |
| `CELADONGYM_TWIN2` | `SPRITE_TWIN` | 5 | 10 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 1 | `TrainerTwinsJoAndZoe2` | -1 |

**Scripts of interest** - `CeladonGymErikaScript`:

```
faceplayer / opentext
checkflag ENGINE_RAINBOWBADGE   -> iftrue .FightDone
writetext ErikaBeforeBattleText / waitbutton / closetext
winlosstext ErikaBeatenText, 0
loadtrainer ERIKA, ERIKA1
startbattle
reloadmapafterbattle
setevent EVENT_BEAT_ERIKA
setevent EVENT_BEAT_LASS_MICHELLE
setevent EVENT_BEAT_PICNICKER_TANYA
setevent EVENT_BEAT_BEAUTY_JULIA
setevent EVENT_BEAT_TWINS_JO_AND_ZOE
writetext PlayerReceivedRainbowBadgeText / playsound SFX_GET_BADGE / waitsfx
setflag ENGINE_RAINBOWBADGE
.FightDone:
checkevent EVENT_GOT_TM19_GIGA_DRAIN -> iftrue .GotGigaDrain
writetext ErikaExplainTMText / promptbutton
verbosegiveitem TM_GIGA_DRAIN / iffalse .GotGigaDrain
setevent EVENT_GOT_TM19_GIGA_DRAIN
```

Two things a bot must know: beating Erika **retroactively sets all four minor
trainers' beaten flags**, so a rematch sweep is impossible after the leader; and
the TM is handed out in the same conversation, so a full bag silently skips it
and you must talk to her again.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_RAINBOWBADGE` | `constants/engine_flags.asm:50` | set by `CeladonGymErikaScript`; read by `CeladonGymStatue` | the badge itself |
| `EVENT_BEAT_ERIKA` | `constants/event_flags.asm:718` | set by `CeladonGymErikaScript` | leader cleared |
| `EVENT_BEAT_LASS_MICHELLE` | `:810` | `TrainerLassMichelle` / Erika script | gym trainer |
| `EVENT_BEAT_PICNICKER_TANYA` | `:654` | `TrainerPicnickerTanya` / Erika script | gym trainer |
| `EVENT_BEAT_BEAUTY_JULIA` | `:702` | `TrainerBeautyJulia` / Erika script | gym trainer |
| `EVENT_BEAT_TWINS_JO_AND_ZOE` | `:612` | both twin objects share this one flag | beating either twin clears both |
| `EVENT_GOT_TM19_GIGA_DRAIN` | `:219` | `CeladonGymErikaScript` | one-time TM |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `TM_GIGA_DRAIN` (TM19) | talk to ERIKA after the battle | `CeladonGymErikaScript` -> `verbosegiveitem TM_GIGA_DRAIN` | `EVENT_GOT_TM19_GIGA_DRAIN` |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `TWINS`, `JOANDZOE1` | Twins (`:625`) | JOANDZOE1 | `"JO & ZOE@", TRAINERTYPE_NORMAL` / `35 VICTREEBEL`, `35 VILEPLUME` (line 3090) | `TrainerTwinsJoAndZoe1` | no |
| `TWINS`, `JOANDZOE2` | Twins (`:626`) | JOANDZOE2 | `"JO & ZOE@", TRAINERTYPE_NORMAL` / `35 VILEPLUME`, `35 VICTREEBEL` (line 3096) | `TrainerTwinsJoAndZoe2` | no |
| `PICNICKER`, `TANYA` | Picnicker (`:544`) | TANYA | `37 EXEGGUTOR` (line 2688) | `TrainerPicnickerTanya` | no |
| `LASS`, `MICHELLE` | Lass (`:173`) | MICHELLE | `32 SKIPLOOM`, `33 HOPPIP`, `34 JUMPLUFF` (line 690) | `TrainerLassMichelle` | no |
| `BEAUTY`, `JULIA` | Beauty (`:241`) | JULIA | `32 PARAS`, `32 EXEGGCUTE`, `35 PARASECT` (line 1062) | `TrainerBeautyJulia` | no |
| `ERIKA`, `ERIKA1` | Erika (`:107`) | ERIKA1 | `TRAINERTYPE_MOVES` (line 331): `42 TANGELA` VINE_WHIP/BIND/GIGA_DRAIN/SLEEP_POWDER; `41 JUMPLUFF` MEGA_DRAIN/LEECH_SEED/COTTON_SPORE/GIGA_DRAIN; `46 VICTREEBEL` SUNNY_DAY/SYNTHESIS/ACID/RAZOR_LEAF; `46 BELLOSSOM` SUNNY_DAY/SYNTHESIS/PETAL_DANCE/SOLARBEAM | `CeladonGymErikaScript` | leader, no rematch here |

Erika's DVs: `data/trainers/dvs.asm:25` `dn 7, 8, 8, 8`.
Erika's class attributes (`data/trainers/attributes.asm:125`):
`db HYPER_POTION, NO_ITEM ; items`, `db 25 ; base reward`,
`AI_BASIC|AI_SETUP|AI_SMART|AI_AGGRESSIVE|AI_CAUTIOUS|AI_STATUS|AI_RISKY`,
`CONTEXT_USE | SWITCH_SOMETIMES`.

**Party order note**: `loadtrainer` sends mons out in the order written in
`parties.asm` - **Tangela, Jumpluff, Victreebel, Bellossom**. The walkthrough
lists Tangela / Victreebel / Bellossom / Jumpluff, which is not the lead order.

**Wild encounters** - none.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Rock Tunnel is pitch black | `data/maps/maps.asm:156-157` (`PALETTE_DARK`) + `engine/events/overworld.asm:271` `FlashFunction.CheckUseFlash` | `ENGINE_ZEPHYRBADGE` **and** `wTimeOfDayPalset == DARKNESS_PALSET` | use HM05 Flash from the party menu inside the tunnel; without the badge the routine returns `JUMPTABLE_EXIT` and nothing happens |
| Surf to reach the Power Plant / cross Route 10 water | `engine/events/overworld.asm:322` `SurfFunction`, badge check at `:340` `ld de, ENGINE_FOGBADGE` | `ENGINE_FOGBADGE` + a party mon that knows Surf | already held by this point in the walkthrough |
| Cut (any cut tree) | `engine/events/overworld.asm:133` `ld de, ENGINE_HIVEBADGE` in `CutFunction.CheckAble`, then `CheckMapForSomethingToCut` -> `CheckCutCollision` against `data/collision/field_move_blocks.asm` `CutTreeBlockPointers.kanto` (`$32/$33/$34/$35/$60` trees, `$0b` grass) | `ENGINE_HIVEBADGE` + Cut | not actually required in Celadon City - see below |
| TM07 Zap Cannon | `maps/PowerPlant.asm` `PowerPlantManager` | `EVENT_RETURNED_MACHINE_PART` (or `MACHINE_PART` in the bag) | return the part |
| EXPN CARD | `maps/LavRadioTower1F.asm` `LavRadioTower1FGentlemanScript` | `EVENT_RETURNED_MACHINE_PART` | same |
| `LOST_ITEM` from the Fan Club | `maps/PokemonFanClub.asm` `PokemonFanClubClefairyGuyScript.MetCopycat` | `EVENT_RETURNED_MACHINE_PART` **and** `EVENT_MET_COPYCAT_FOUND_OUT_ABOUT_LOST_ITEM` | talk to the Copycat once after returning the machine part |
| `PASS` from the Copycat | `maps/CopycatsHouse2F.asm` `Copycat.ReturnLostItem` | `LOST_ITEM` in the bag | hand it over |
| Magnet Train ride | `maps/SaffronMagnetTrainStation.asm` `SaffronMagnetTrainStationOfficerScript` | `EVENT_RESTORED_POWER_TO_KANTO` then `checkitem PASS` | both set by the machine-part / Copycat chains |
| TM03 Curse | `maps/CeladonMansionRoofHouse.asm` `CeladonMansionRoofHousePharmacistScript` | `checktime NITE` | come back after sunset |
| Game Corner prizes | `maps/CeladonGameCornerPrizeRoom.asm` both vendor scripts | `checkitem COIN_CASE`, then `checkcoins <price>`; mon counter also `readvar VAR_PARTYCOUNT != PARTY_LENGTH` | buy/win coins, keep a party slot free |
| RAINBOWBADGE | `maps/CeladonGym.asm` `CeladonGymErikaScript` | none beyond reaching Erika at (5,3) | win the battle |

**Celadon Gym is NOT Cut-gated in pokegold.** `maps/CeladonCity.blk` contains a
single kanto cut-tree block (`$60`) at block (14,17) = cell (28,34), in the
bottom-right of the map, nowhere near the gym. The gym door is the `DOOR`
quadrant of block `$12` at block (5,14) = cell (10,29)
(`data/tilesets/kanto_collision.asm` `tilecoll WALL, WALL, DOOR, WALL ; 12`),
and the cell directly below it, block (5,15) = `$79`
(`tilecoll FLOOR, FLOOR, FLOOR, WALL ; 79`), is walkable floor. Nothing between
the city and the gym requires Cut.

---

## 4. Bot checklist

| # | Map | Target | Intent | Precondition | Postcondition |
|---|---|---|---|---|---|
| 1 | `ROUTE_10_NORTH` | cell (3,9) | walk onto warp 2 | Surf usable (`ENGINE_FOGBADGE`) | in `POWER_PLANT` |
| 2 | `POWER_PLANT` | object `POWERPLANT_MANAGER` (14,10) | talk (face UP from (14,11)) | `EVENT_RETURNED_MACHINE_PART` or `MACHINE_PART` held | `EVENT_GOT_TM07_ZAP_CANNON`, `EVENT_RESTORED_POWER_TO_KANTO` |
| 3 | `POWER_PLANT` | cell (2,17) | walk onto warp 1 | - | in `ROUTE_10_NORTH` |
| 4 | `ROCK_TUNNEL_1F` | party menu | use FLASH | `ENGINE_ZEPHYRBADGE`, mon knows Flash | dark palette lifted |
| 5 | `ROCK_TUNNEL_1F` | cell (10,15) | walk onto item ball | `EVENT_ROCK_TUNNEL_1F_TM_STEEL_WING` clear | TM47 in bag, flag set |
| 6 | `ROCK_TUNNEL_1F` | cell (4,18) | walk onto item ball | `EVENT_ROCK_TUNNEL_1F_ELIXER` clear | ELIXER in bag |
| 7 | `ROCK_TUNNEL_1F` | cell (15,9) / (5,3) / (27,3) / (27,13) | warps 4/3/5/6 into B1F | - | in `ROCK_TUNNEL_B1F` |
| 8 | `ROCK_TUNNEL_B1F` | cells (7,25), (6,17), (15,2) | walk onto item balls | respective flags clear | IRON, PP_UP, REVIVE |
| 9 | `ROCK_TUNNEL_B1F` | cell (4,14) | face and press A | `EVENT_ROCK_TUNNEL_B1F_HIDDEN_MAX_POTION` clear | MAX_POTION |
| 10 | `ROCK_TUNNEL_1F` | cell (11,25) | warp 2 | - | in `ROUTE_10_SOUTH` at warp 1 (6,1) |
| 11 | `ROUTE_10_SOUTH` | object at (17,3) | battle `TrainerHikerJim` (sight 4, faces LEFT) | `EVENT_BEAT_HIKER_JIM` clear | flag set |
| 12 | `ROUTE_10_SOUTH` | object at (4,10) | battle `TrainerPokefanmRobert` (sight 2, faces LEFT) | `EVENT_BEAT_POKEFANM_ROBERT` clear | flag set |
| 13 | `ROUTE_10_SOUTH` | south edge | walk south | - | in `LAVENDER_TOWN`, `ENGINE_FLYPOINT_LAVENDER` set |
| 14 | `LAVENDER_TOWN` | cell (14,5) | warp 7 | - | in `LAV_RADIO_TOWER_1F` |
| 15 | `LAV_RADIO_TOWER_1F` | object at (9,1) | talk | `EVENT_RETURNED_MACHINE_PART` set, `ENGINE_EXPN_CARD` clear | `ENGINE_EXPN_CARD` set |
| 16 | `LAVENDER_TOWN` | west edge | walk west | - | in `ROUTE_8` |
| 17 | `ROUTE_8` | (27,9), (20,6), (10,10), (10,9), (10,8) | battle Tom, Sam, Zeke, Harris, Dwayne | respective `EVENT_BEAT_*` clear | flags set |
| 18 | `ROUTE_8` | object at (33,5) | face and press A | daily tree flag clear | `PRZCUREBERRY` |
| 19 | `ROUTE_8` | cell (4,4) | warp 1 | - | `ROUTE_8_SAFFRON_GATE` -> `SAFFRON_CITY` |
| 20 | `SAFFRON_CITY` | cell (9,11) | warp 8 | - | `COPYCATS_HOUSE_1F` |
| 21 | `COPYCATS_HOUSE_1F` | cell (2,0) | warp 3 | - | `COPYCATS_HOUSE_2F` |
| 22 | `COPYCATS_HOUSE_2F` | object `COPYCATSHOUSE2F_COPYCAT` (4,3) | talk | `EVENT_RETURNED_MACHINE_PART` set | `EVENT_MET_COPYCAT_FOUND_OUT_ABOUT_LOST_ITEM` |
| 23 | - | Fly to Vermilion | fly | `ENGINE_FLYPOINT_VERMILION` | in `VERMILION_CITY` |
| 24 | `VERMILION_CITY` | cell (7,13) | warp 3 | - | `POKEMON_FAN_CLUB` |
| 25 | `POKEMON_FAN_CLUB` | object at (2,3) | talk (face RIGHT from (1,3)) | step 22 done, bag has room | `LOST_ITEM`, `EVENT_GOT_LOST_ITEM_FROM_FAN_CLUB`, FAIRY object disappears |
| 26 | - | Fly to Saffron, re-enter Copycat 2F | fly + warps | - | back at (4,3) |
| 27 | `COPYCATS_HOUSE_2F` | Copycat | talk | `LOST_ITEM` held | `PASS`, `EVENT_GOT_PASS_FROM_COPYCAT`, `EVENT_RETURNED_LOST_ITEM_TO_COPYCAT` |
| 28 | `SAFFRON_CITY` | cell (0,24) | warp 10 | - | `ROUTE_7_SAFFRON_GATE` |
| 29 | `ROUTE_7_SAFFRON_GATE` | cell (0,4) | warp 1 | - | `ROUTE_7` (guard is not a blocker) |
| 30 | `ROUTE_7` | west edge | walk west | - | `CELADON_CITY`, `ENGINE_FLYPOINT_CELADON` set |
| 31 | `CELADON_CITY` | cell (16,3) | warp 3 (mansion back door) | - | `CELADON_MANSION_1F` at warp 3 |
| 32 | `CELADON_MANSION_1F/2F/3F` | warps 4 -> 2 -> 1 | climb to the roof | - | `CELADON_MANSION_ROOF` |
| 33 | `CELADON_MANSION_ROOF` | cell (2,5) | warp 3 | - | `CELADON_MANSION_ROOF_HOUSE` |
| 34 | `CELADON_MANSION_ROOF_HOUSE` | object at (3,2) | talk | `checktime NITE` true, `EVENT_GOT_TM03_CURSE` clear | TM03, flag set |
| 35 | `CELADON_CITY` | cell (25,29) | warp 9 | - | `CELADON_CAFE` |
| 36 | `CELADON_CAFE` | cell (7,1) | face UP and press A | `EVENT_FOUND_LEFTOVERS_IN_CELADON_CAFE` clear, bag room | `LEFTOVERS`, flag set |
| 37 | `CELADON_CITY` | cell (37,21) | face and press A | `EVENT_CELADON_CITY_HIDDEN_PP_UP` clear | `PP_UP` |
| 38 | `CELADON_CITY` | cell (10,29) | warp 8 | no field move needed | `CELADON_GYM` |
| 39 | `CELADON_GYM` | (4,10) and (5,10) | battle both twins | `EVENT_BEAT_TWINS_JO_AND_ZOE` clear (shared) | flag set after the first |
| 40 | `CELADON_GYM` | (2,8) | battle `TrainerPicnickerTanya` | `EVENT_BEAT_PICNICKER_TANYA` clear | flag set |
| 41 | `CELADON_GYM` | (7,8) | battle `TrainerLassMichelle` | `EVENT_BEAT_LASS_MICHELLE` clear | flag set |
| 42 | `CELADON_GYM` | (3,5) | battle `TrainerBeautyJulia` | `EVENT_BEAT_BEAUTY_JULIA` clear | flag set |
| 43 | `CELADON_GYM` | object `CELADONGYM_ERIKA` (5,3) | talk from (5,4) facing UP | `ENGINE_RAINBOWBADGE` clear | battle, then `ENGINE_RAINBOWBADGE`, `EVENT_BEAT_ERIKA`, all four minor flags |
| 44 | `CELADON_GYM` | Erika again if the bag was full | talk | `EVENT_GOT_TM19_GIGA_DRAIN` clear | `TM_GIGA_DRAIN` |
| 45 | `CELADON_GYM` | cell (4,17) | warp 1 | - | back in `CELADON_CITY` |

---

## 5. Port coverage

The Gen 2 port is data-driven: `src/import/RomExtractorGen2.lua` reads every map
header, `def_warp_events` / `def_coord_events` / `def_bg_events` /
`def_object_events` table and script pointer straight out of the ROM
(`RomExtractorGen2:readMapEvents`, line 782), so per-map coverage is not a
per-map Lua file. What follows is coverage of the *mechanics* this section
needs.

| Beat | Port file | Status |
|---|---|---|
| Map blocks, collision, warps, connections | `src/world/gen2/Map.lua`, `src/world/gen2/Permissions.lua` | implemented (generic) |
| Warp / object / bg / coord event extraction | `src/import/RomExtractorGen2.lua:782` `readMapEvents` | implemented |
| Script VM (`checkevent`, `setevent`, `checkflag`, `setflag`, `verbosegiveitem`, `giveitem`, `takeitem`, `loadtrainer`, `startbattle`, `winlosstext`, `applymovement`, `checktime`, `showemote`, `variablesprite`, `gettrainername`) | `src/script/gen2/Opcodes.lua`, `src/script/gen2/Vm.lua` | implemented |
| Item balls (`OBJECTTYPE_ITEMBALL`) | `src/world/gen2/Events.lua`, `src/world/gen2/Npc.lua` | implemented |
| Hidden items (`BGEVENT_ITEM` -> `hiddenitem`) | `src/world/gen2/HiddenItems.lua` | implemented (the header notes `World:bgEventAt` previously only answered `BGEVENT_READ`) |
| Fruit trees (`fruittree FRUITTREE_ROUTE_8`) | `src/core/gen2/Apricorns.lua` (`tryResetFruitTrees`, `treePicked`), VM `fruittree` branch `src/script/gen2/Vm.lua:1191` | implemented |
| Overworld trainers: eyesight, `trainer` struct, party build | `src/world/gen2/Trainers.lua` | implemented |
| Field moves Cut / Flash / Surf, badge order, `CutTreeBlockPointers` | `src/world/gen2/FieldMoves.lua` (`CUT = "HIVE"`, `FLASH = "ZEPHYR"`, `SURF = "FOG"`, `cutFromMenu`, `flashFromMenu`, `surfFromMenu`) | implemented |
| Badge storage incl. RAINBOWBADGE | `src/inventory/Badges.lua:12`, `src/ui/gen2/TrainerCard.lua:67` | implemented |
| Game Corner prize counters (TM + mon, coin case, party-full check) | `src/ui/gen2/PrizeMenu.lua`, `special GameCornerPrizeMonCheckDex` in `src/script/gen2/Specials.lua:964` | implemented |
| Slot machine (Celadon Game Corner floor) | `src/ui/gen2/SlotMachine.lua` | implemented |
| Magnet Train ride | `src/core/gen2/MagnetTrain.lua`, `src/ui/gen2/MagnetTrainRide.lua` | implemented |
| Pokegear radio / EXPN card channel gating | `src/ui/gen2/Pokegear.lua:810`, `:1095` | implemented |
| Marts (`pokemart MARTTYPE_STANDARD`) | `src/ui/gen2/MartMenu.lua` | implemented |
| Elevator (dept store) | `src/ui/gen2/ElevatorMenu.lua` | implemented |
| `special LoadUsedSpritesGFX` (the Copycat mimicry sprite swap) | `src/script/gen2/Specials.lua:1033` | implemented |
| `special Diploma` (mansion 3F) | `src/ui/gen2/Diploma.lua`, `src/script/gen2/Specials.lua:1853` | implemented; `special PrintDiploma` is a stub |
| Headless driver coverage for this stretch | `tests/drivers/gold_*.lua` | **missing** - all 25 gold drivers are Johto-side (`gold_walk_smoke.lua` runs New Bark -> Route 29); nothing exercises Rock Tunnel, Route 8/7, Celadon, or the Erika fight |

---

## 6. Unresolved / verify by hand

1. **"Head to the southwest part of town with a Pokemon that can use the HM01
   Cut and you'll arrive at Erika's gym."** Not supported by the asm. There is
   exactly one kanto cut-tree block in `maps/CeladonCity.blk` (`$60` at block
   (14,17) = cell (28,34)) and it is not on the path to the gym. The gym door is
   block `$12` at (5,14), approached from walkable block `$79` at (5,15). This
   looks like a carry-over from Red/Blue. Verify in-game before writing a Cut
   step into a driver.
2. **Route 7 wild list.** The walkthrough gives Pidgeotto / Vulpix / Meowth.
   `data/wild/kanto_grass.asm` `def_grass_wildmons ROUTE_7` in the `IF DEF(_GOLD)`
   branch is Rattata / Spearow / Growlithe / Raticate / Murkrow / Houndour;
   Meowth and Vulpix only appear in the `_SILVER` branch, and Pidgeotto appears
   on Route 8, not Route 7. Treat the FAQ list as Silver-flavoured.
3. **Rock Tunnel item list.** The walkthrough lists Iron, PP Up, Revive and TM47
   and omits the `ELIXER` ball at `ROCK_TUNNEL_1F` (4,18), the hidden
   `X_ACCURACY` at 1F (24,4), the hidden `X_DEFEND` at 1F (21,15) and the hidden
   `MAX_POTION` at B1F (4,14).
4. **Erika's held items.** The walkthrough says "three Full Restores".
   `data/trainers/attributes.asm:125` gives the Erika class
   `db HYPER_POTION, NO_ITEM`. The count of AI item uses is engine behaviour, not
   a party field; the item is a Hyper Potion, not a Full Restore.
5. **Erika's lead order.** `parties.asm:331` orders Tangela, Jumpluff,
   Victreebel, Bellossom; the walkthrough's strategy section is ordered Tangela,
   Victreebel, Bellossom, Jumpluff.
6. **Bellossom's Synthesis "heals half its health every turn".** `Synthesis`'s
   actual healing fraction is weather-dependent in the move effect
   (`engine/battle/effect_commands.asm`); not pinned down here.
7. **"Rail Pass" vs "Magnet Train Pass".** The walkthrough describes two
   separate rewards ("Rail Pass" first, then "Magnet Train Pass"). In the asm
   there is one item, `PASS`, given once by `Copycat.GivePass`; the "rail PASS"
   wording is just `CopycatText_Male_2` / `CopycatText_Male_3` flavour.
8. **"The Saffron City guard will check your Pokedex as ID."**
   `Route7SaffronGuardScript` has no `checkitem`, no coord event and no blocking
   movement - it is a two-branch text switch on `EVENT_RETURNED_MACHINE_PART`.
   The gate is passable regardless.
9. **"You can play slots in the middle of town"** - the slot machines'
   `def_object_events` / `def_bg_events` rows in `maps/CeladonGameCorner.asm`
   were not transcribed here (only its two warps); if a bot needs to sit at a
   specific machine, read that file.
10. **Exact experience and prize-money numbers** quoted by the walkthrough
    (e.g. "1447 EXP", "1120G") were not verified; they are computed at runtime
    from base stats and `data/trainers/attributes.asm` base rewards, not stored
    as table values.

# Section 29 - Routes 22-28

Source: `../section-29-routes-22-28.txt` (the FAQ numbers this chapter "35 > Routes 22-28")
Maps covered: `MAP_PALLET_TOWN`, `MAP_OAKS_LAB`, `MAP_VIRIDIAN_CITY`, `MAP_ROUTE_22`,
`MAP_VICTORY_ROAD_GATE`, `MAP_ROUTE_28`, `MAP_ROUTE_28_STEEL_WING_HOUSE`, and the
east edge of `MAP_SILVER_CAVE_OUTSIDE` (+ `MAP_SILVER_CAVE_POKECENTER_1F`).
Badges / key milestones in this section: no badge. The milestone is
`EVENT_OPENED_MT_SILVER`, set by Prof. Oak once `VAR_BADGES == NUM_BADGES` (16).
Items: TM42 Dream Eater, TM47 Steel Wing, hidden Rare Candy.

Two structural facts the walkthrough hides, both verified against the block data
and both load-bearing for a bot:

1. **Oak's line is not flavour - it is the gate.** `EVENT_OPENED_MT_SILVER`
   *removes* the black belt standing at `VICTORY_ROAD_GATE` (7,5). That NPC
   occupies the only tile joining the gate's central corridor to its western
   vestibule, i.e. to the two `ROUTE_28` warps. Until Oak sets the flag, Route 28
   and Mt. Silver are physically unreachable. See section 3.
2. **`object_event`'s trailing `EVENT_*` HIDES the object when the flag is SET.**
   `CheckObjectFlag` (`engine/overworld/map_objects_2.asm:32-61`) jumps to
   `.masked` when `EventFlagAction`/`CHECK_FLAG` returns non-zero. The macro
   comment in `macros/scripts/maps.asm:132` ("event flag: an `EVENT_*` constant,
   or -1 to always appear") does not state the polarity and is easy to read
   backwards. The port already has this right
   (`src/world/gen2/Events.lua:40-44`).

Coordinates below are walk cells (the raw numbers in the `warp_event` /
`bg_event` / `object_event` rows), origin top-left, x east, y south.

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 0 | `MAP_PALLET_TOWN` | `maps/PalletTown.asm` | Fly, `SPAWN_PALLET` = (5,6) (`data/maps/spawn_points.asm:14`) | warp 3 at (12,11) -> `OAKS_LAB` warp 1 | "fly back to Pallet Town" |
| 1 | `MAP_OAKS_LAB` | `maps/OaksLab.asm` | warp 1 at (4,11) (warp 2 at (5,11) is the twin tile) | same warps back to `PALLET_TOWN` warp 3 | talk to `Oak` at (4,2); with 16 badges this runs `.OpenMtSilver` and sets `EVENT_OPENED_MT_SILVER` |
| 2 | `MAP_VIRIDIAN_CITY` | `maps/ViridianCity.asm` | Fly, `SPAWN_VIRIDIAN` = (23,26) (`data/maps/spawn_points.asm:15`), which is the Pokecenter warp tile | west map edge, cells y=14..17 at x=0 | "fly back to Viridian City, and then head west to Route 22" |
| 2a | `MAP_VIRIDIAN_CITY` (Cut pocket) | same | Cut the tree at (8,22), approached from (9,22) facing LEFT | the same tile back east | the TM42 Dream Eater fisher at (6,23). The FAQ files this under "Items on Route 22"; it is **not** on Route 22 |
| 3 | `MAP_ROUTE_22` | `maps/Route22.asm` | east map edge at x=39, y=6..9 (`connection east, ViridianCity, VIRIDIAN_CITY, -4`) | warp 1 at (13,5) -> `VICTORY_ROAD_GATE` warp 1 | "keep heading north, west, then north" |
| 4 | `MAP_VICTORY_ROAD_GATE` | `maps/VictoryRoadGate.asm` | warp 1 at (17,7) (warp 2 at (18,7) is the twin) | warp 7 at (1,7) / warp 8 at (2,7) -> `ROUTE_28` warp 2 | "heading west instead of north" |
| 5 | `MAP_ROUTE_28` (main body) | `maps/Route28.asm` | warp 2 at (33,5) | west map edge at x=0, y=12..13 (`connection west, SilverCaveOutside, SILVER_CAVE_OUTSIDE, -9`) | "head west towards Mount Silver"; the Route 28 sign is read from (30,5) |
| 6 | `MAP_SILVER_CAVE_OUTSIDE` | `maps/SilverCaveOutside.asm` | east map edge at x=39, y=30..31 | warp 1 at (23,19) -> `SILVER_CAVE_POKECENTER_1F` warp 1 | "There's also a Pokémon Center here". Sets `ENGINE_FLYPOINT_SILVER_CAVE` on entry |
| 7 | `MAP_SILVER_CAVE_POKECENTER_1F` | `maps/SilverCavePokecenter1F.asm` | warp 1 at (3,7) (twin at (4,7)) | same | heal; the last Pokecenter before Mt. Silver |
| 8 | `MAP_SILVER_CAVE_OUTSIDE` (east shelf) | same | Cut (31,24) then Cut (34,23) | east map edge at x=39, y=21 | "cut the trees east" |
| 9 | `MAP_ROUTE_28` (isolated west strip) | `maps/Route28.asm` | west map edge at x=0, y=3 | warp 1 at (7,3) -> `ROUTE_28_STEEL_WING_HOUSE` warp 1 | the strip that holds the Steel Wing house door and the hidden Rare Candy |
| 10 | `MAP_ROUTE_28_STEEL_WING_HOUSE` | `maps/Route28SteelWingHouse.asm` | warp 1 at (2,7) (twin at (3,7)) | same | `Celebrity` at (2,3) gives TM47 Steel Wing |
| 11 | `MAP_SILVER_CAVE_OUTSIDE` warp 2 at (18,11) -> `SILVER_CAVE_ROOM_1` | `maps/SilverCaveRoom1.asm` | - | - | **next section** (Mt. Silver / Red). Stop here. |

The FAQ's chapter title says "Routes 22-28" but the prose never enters Route 23,
24, 25, 26 or 27. Routes 26/27 are section 16's, Route 23 is section 17/18's.

## 2. Maps

### MAP_PALLET_TOWN

- Script: `maps/PalletTown.asm` (included from `data/maps/scripts.asm:171`)
- Blocks: `maps/PalletTown.blk` (`data/maps/blocks.asm:88`)
- Header: `data/maps/maps.asm:312`
  `map PalletTown, TILESET_KANTO, TOWN, LANDMARK_PALLET_TOWN, MUSIC_PALLET_TOWN, FALSE, PALETTE_AUTO, FISHGROUP_OCEAN`
- Attributes: `data/maps/attributes.asm:271` `map_attributes PalletTown, PALLET_TOWN, $0f`
- Dimensions: `constants/map_constants.asm:288` `map_const PALLET_TOWN, 10, 9` -> 10x9 blocks = 20x18 cells. Group `PALLET` (13), map id 2.
- Connections: `connection north, Route1, ROUTE_1, 0`; `connection south, Route21, ROUTE_21, 0`
- Callbacks: `callback MAPCALLBACK_NEWMAP, PalletTownFlypointCallback` (sym `4e:46ac`) -> `setflag ENGINE_FLYPOINT_PALLET`

**Warps** (`def_warp_events`, `maps/PalletTown.asm:73-76`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 5 | `REDS_HOUSE_1F` | 1 |
| 2 | 13 | 5 | `BLUES_HOUSE` | 1 |
| 3 | 12 | 11 | `OAKS_LAB` | 1 |

**Coord events** - `def_coord_events` is empty.

**BG events** (`def_bg_events`, `maps/PalletTown.asm:80-84`)

| x | y | type | script/item |
|---|---|---|---|
| 7 | 9 | `BGEVENT_READ` | `PalletTownSign` (sym `4e:46b6`) |
| 3 | 5 | `BGEVENT_READ` | `RedsHouseSign` |
| 13 | 13 | `BGEVENT_READ` | `OaksLabSign` (sym `4e:46bc`) |
| 11 | 5 | `BGEVENT_READ` | `BluesHouseSign` |

**Object events** (`def_object_events`, `maps/PalletTown.asm:86-88`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `PALLETTOWN_TEACHER` | `SPRITE_TEACHER` | 3 | 8 | `SPRITEMOVEDATA_WANDER` (r 2,2) | `OBJECTTYPE_SCRIPT` | `PalletTownTeacherScript` | -1 |
| `PALLETTOWN_FISHER` | `SPRITE_FISHER` | 12 | 14 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (r 2,0) | `OBJECTTYPE_SCRIPT` | `PalletTownFisherScript` | -1 |

**Route from the Fly landing to the lab door** (BFS over `PalletTown.blk` +
`data/tilesets/kanto_collision.asm`): (5,6) -> (9,6) -> (9,12) -> (12,12) ->
(12,11). No ledges, no field moves.

---

### MAP_OAKS_LAB

- Script: `maps/OaksLab.asm` (`data/maps/scripts.asm:341`)
- Blocks: `maps/OaksLab.blk` (`data/maps/blocks.asm:892`)
- Header: `data/maps/maps.asm:316`
  `map OaksLab, TILESET_LAB, INDOOR, LANDMARK_PALLET_TOWN, MUSIC_POKEMON_TALK, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Attributes: `data/maps/attributes.asm:579` `map_attributes OaksLab, OAKS_LAB, $00`, no connections
- Dimensions: `constants/map_constants.asm:292` `map_const OAKS_LAB, 5, 6` -> 5x6 blocks = 10x12 cells. Group `PALLET` (13), map id 6.
- Callbacks / scene scripts: both empty (`OaksLabNoopScene` is marked unreferenced).

**Warps** (`maps/OaksLab.asm:260-262`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 11 | `PALLET_TOWN` | 3 |
| 2 | 5 | 11 | `PALLET_TOWN` | 3 |

**Coord events** - none.

**BG events** (`maps/OaksLab.asm:266-282`)

| x | y | type | script/item |
|---|---|---|---|
| 6,7,8,9 | 1 | `BGEVENT_READ` | `OaksLabBookshelf` -> `jumpstd DifficultBookshelfScript` |
| 0,1,2,3 | 7 | `BGEVENT_READ` | `OaksLabBookshelf` |
| 6,7,8,9 | 7 | `BGEVENT_READ` | `OaksLabBookshelf` |
| 4 | 0 | `BGEVENT_READ` | `OaksLabPoster1` |
| 5 | 0 | `BGEVENT_READ` | `OaksLabPoster2` |
| 9 | 3 | `BGEVENT_READ` | `OaksLabTrashcan` |
| 0 | 1 | `BGEVENT_READ` | `OaksLabPC` |

**Object events** (`maps/OaksLab.asm:284-288`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `OAKSLAB_OAK` | `SPRITE_OAK` | 4 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Oak` (sym `59:58c3`) | -1 |
| `OAKSLAB_SCIENTIST1` | `SPRITE_SCIENTIST` | 1 | 8 | `WALK_LEFT_RIGHT` (r 1,0), `PAL_NPC_BLUE` | `OBJECTTYPE_SCRIPT` | `OaksAssistant1Script` (sym `59:590a`) | -1 |
| `OAKSLAB_SCIENTIST2` | `SPRITE_SCIENTIST` | 8 | 9 | `WALK_UP_DOWN` (r 0,1), `PAL_NPC_BLUE` | `OBJECTTYPE_SCRIPT` | `OaksAssistant2Script` | -1 |
| `OAKSLAB_SCIENTIST3` | `SPRITE_SCIENTIST` | 1 | 4 | `WANDER` (r 1,1), `PAL_NPC_BLUE` | `OBJECTTYPE_SCRIPT` | `OaksAssistant3Script` | -1 |

Oak stands at (4,2); the player talks to him from (4,3) facing UP. Cell (4,3) is
`COLL_FLOOR` in `data/tilesets/lab_collision.asm`, and (4,11)/(5,11) are the
`WARP_CARPET_DOWN` pair, so the approach is a straight walk up the middle of the
room.

**Scripts of interest**

`Oak` (`maps/OaksLab.asm:15-54`, sym `59:58c3`) - the only script in this section
that writes a story flag:

```
faceplayer / opentext
checkevent EVENT_OPENED_MT_SILVER   ; already done -> .CheckPokedex
iftrue .CheckPokedex
checkevent EVENT_TALKED_TO_OAK_IN_KANTO
iftrue .CheckBadges
writetext OakWelcomeKantoText / promptbutton
setevent EVENT_TALKED_TO_OAK_IN_KANTO
.CheckBadges:
readvar VAR_BADGES
ifequal NUM_BADGES, .OpenMtSilver     ; 16
ifequal NUM_JOHTO_BADGES, .Complain   ; 8 -> "you're not collecting KANTO BADGES"
sjump .AhGood                         ; 9..15 -> "come see me when you get them all"
.OpenMtSilver:
writetext OakOpenMtSilverText / promptbutton
setevent EVENT_OPENED_MT_SILVER
sjump .CheckPokedex
.CheckPokedex:
writetext OakLabDexCheckText / waitbutton
special ProfOaksPCBoot
writetext OakLabGoodbyeText / waitbutton / closetext / end
```

Bot-relevant: the branch is `ifequal`, not `ifgreater`, and `VAR_BADGES` is the
**popcount of both badge bytes** (`engine/overworld/variables.asm` ->
`CountSetBits` over `wJohtoBadges` + `wKantoBadges`; the port mirrors this at
`src/world/gen2/World.lua:1240-1245`). So the flag is only set on a visit with
exactly 16 badges; 9-15 badges gives `.AhGood` and no flag. Every arm falls
through to `special ProfOaksPCBoot`, which prints the Pokedex rating - budget
several textbox advances for it.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_OPENED_MT_SILVER` | `constants/event_flags.asm:1265` | set by `Oak`; read by `Oak` and by the `VICTORYROADGATE_BLACK_BELT1` object row | **the section's gate.** While clear, the black belt at `VICTORY_ROAD_GATE` (7,5) exists and blocks the ROUTE_28 warps |
| `EVENT_TALKED_TO_OAK_IN_KANTO` | `constants/event_flags.asm:224` | set/read by `Oak` | first-visit greeting only, no gameplay effect |

---

### MAP_VIRIDIAN_CITY

- Script: `maps/ViridianCity.asm` (`data/maps/scripts.asm:168`)
- Blocks: `maps/ViridianCity.blk` (`data/maps/blocks.asm:235`)
- Header: `data/maps/maps.asm:457`
  `map ViridianCity, TILESET_KANTO, TOWN, LANDMARK_VIRIDIAN_CITY, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_AUTO, FISHGROUP_POND`
- Attributes: `data/maps/attributes.asm:259` `map_attributes ViridianCity, VIRIDIAN_CITY, $0f`
- Dimensions: `constants/map_constants.asm:423` `map_const VIRIDIAN_CITY, 20, 18` -> 20x18 blocks = 40x36 cells. Group `VIRIDIAN` (23), map id 3.
- Connections: `connection north, Route2, ROUTE_2, 5`; `connection south, Route1, ROUTE_1, 10`; `connection west, Route22, ROUTE_22, 4`
- Callbacks: `callback MAPCALLBACK_NEWMAP, ViridianCityFlypointCallback` (sym `4e:4005`) -> `setflag ENGINE_FLYPOINT_VIRIDIAN`

**Warps** (`maps/ViridianCity.asm:219-224`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 32 | 7 | `VIRIDIAN_GYM` | 1 |
| 2 | 21 | 9 | `VIRIDIAN_NICKNAME_SPEECH_HOUSE` | 1 |
| 3 | 23 | 15 | `TRAINER_HOUSE_1F` | 1 |
| 4 | 29 | 19 | `VIRIDIAN_MART` | 2 |
| 5 | 23 | 25 | `VIRIDIAN_POKECENTER_1F` | 1 |

**Coord events** - `def_coord_events` is empty.

**BG events** (`maps/ViridianCity.asm:228-234`)

| x | y | type | script/item |
|---|---|---|---|
| 17 | 17 | `BGEVENT_READ` | `ViridianCitySign` |
| 27 | 7 | `BGEVENT_READ` | `ViridianGymSign` |
| 19 | 1 | `BGEVENT_READ` | `ViridianCityWelcomeSign` |
| 21 | 15 | `BGEVENT_READ` | `TrainerHouseSign` |
| 24 | 25 | `BGEVENT_READ` | `ViridianCityPokecenterSign` -> `jumpstd PokecenterSignScript` |
| 30 | 19 | `BGEVENT_READ` | `ViridianCityMartSign` -> `jumpstd MartSignScript` |

**Object events** (`maps/ViridianCity.asm:236-240`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VIRIDIANCITY_GRAMPS1` | `SPRITE_GRAMPS` | 18 | 5 | `WANDER` (r 2,2) | `OBJECTTYPE_SCRIPT` | `ViridianCityCoffeeGramps` (sym `4e:4009`) | -1 |
| `VIRIDIANCITY_GRAMPS2` | `SPRITE_GRAMPS` | 30 | 8 | `STANDING_DOWN`, `PAL_NPC_BLUE` | `OBJECTTYPE_SCRIPT` | `ViridianCityGrampsNearGym` (sym `4e:401e`) | -1 |
| `VIRIDIANCITY_FISHER` | `SPRITE_FISHER` | 6 | 23 | `STANDING_DOWN`, `PAL_NPC_RED` | `OBJECTTYPE_SCRIPT` | `ViridianCityDreamEaterFisher` (sym `4e:4032`) | -1 |
| `VIRIDIANCITY_YOUNGSTER` | `SPRITE_YOUNGSTER` | 17 | 21 | `WANDER` (r 3,3), `PAL_NPC_GREEN` | `OBJECTTYPE_SCRIPT` | `ViridianCityYoungsterScript` (sym `4e:404d`) | -1 |

**Scripts of interest**

`ViridianCityDreamEaterFisher` (`maps/ViridianCity.asm:50-65`, sym `4e:4032`):

```
faceplayer / opentext
checkevent EVENT_GOT_TM42_DREAM_EATER
iftrue .GotDreamEater
writetext ViridianCityDreamEaterFisherText / promptbutton
verbosegiveitem TM_DREAM_EATER
iffalse .NoRoomForDreamEater      ; bag full -> flag NOT set, retryable
setevent EVENT_GOT_TM42_DREAM_EATER
.GotDreamEater: writetext ...GotDreamEaterText / waitbutton
.NoRoomForDreamEater: closetext / end
```

`TM_DREAM_EATER` is item `$ea` (`constants/item_constants.asm:263`, the 42nd
`add_tm` after `DEF TM01 EQU const_value` at line 219 - the two bare `const`
rows `ITEM_C3` and `ITEM_DC` do not consume TM numbers, which is why TM42 is
Dream Eater and TM47 is Steel Wing).

**Cut gate (verified from block data)**

`ViridianCity.blk` block (4,11) is `$34`, whose `tilecoll` row is
`CUT_TREE, FLOOR, WALL, WALL` (`data/tilesets/kanto_collision.asm`, block `34`),
so the `COLL_CUT_TREE` quadrant is the top-left = **cell (8,22)**. A BFS over the
collision grid says the fisher's pocket (x=4..7, y=22..26) has exactly one
non-ledge entrance and it is that tile. Route:

- Pokecenter door (23,25) -> step down to (23,26)
- (23,26) -> (14,26) -> (14,23) -> (10,23) -> (10,22) -> (9,22)
- face LEFT at (9,22), Cut (8,22)
- (8,22) -> (7,22) -> (6,22) -> (6,23) faces the fisher at... he *is* at (6,23);
  stand at (6,22) and face DOWN, or (7,23) and face LEFT.

The pocket's south edge (x=4..7, y=26) is `COLL_HOP_DOWN`, i.e. one-way out.

The only other `$34`/`$60`/`$32`/`$33`/`$35` block on this map is (7,2) =
cell (14,4), which is not on any route in this section.

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| TM42 Dream Eater | talk to the fisher at (6,23) after Cutting (8,22) | `ViridianCityDreamEaterFisher` | `EVENT_GOT_TM42_DREAM_EATER` (`constants/event_flags.asm:223`) |

**Trainers** - none on this map.

**Wild encounters** - `FISHGROUP_POND` per the header; no `def_grass_wildmons
VIRIDIAN_CITY` row is needed by this section.

---

### MAP_ROUTE_22

- Script: `maps/Route22.asm` (`data/maps/scripts.asm:169`) - 28 lines, one sign and one warp, nothing else
- Blocks: `maps/Route22.blk` (`data/maps/blocks.asm:310`, 180 bytes)
- Header: `data/maps/maps.asm:456`
  `map Route22, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_22, MUSIC_ROUTE_3, FALSE, PALETTE_AUTO, FISHGROUP_POND`
- Attributes: `data/maps/attributes.asm:264` `map_attributes Route22, ROUTE_22, $2c`
- Dimensions: `constants/map_constants.asm:422` `map_const ROUTE_22, 20, 9` -> 20x9 blocks = 40x18 cells. Group `VIRIDIAN` (23), map id 2.
- Connections: `connection east, ViridianCity, VIRIDIAN_CITY, -4` (only one). Crossing east from `(39, y)` lands on Viridian City `(0, y + 8)`; crossing west from Viridian `(0, y)` lands on Route 22 `(39, y - 8)`.
- Scene scripts / callbacks: both empty.

**Warps** (`maps/Route22.asm:19-20`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 13 | 5 | `VICTORY_ROAD_GATE` | 1 |

**Coord events** - none.

**BG events** (`maps/Route22.asm:24-25`)

| x | y | type | script/item |
|---|---|---|---|
| 15 | 7 | `BGEVENT_READ` | `VictoryRoadEntranceSign` (sym `4e:44f9`) - read from (14,7) facing RIGHT |

**Object events** - `def_object_events` is empty. **There are no trainers and no
item balls on Route 22**, which matches the FAQ. The FAQ's "Items on Route 22:
TM42 Dream Eater" is wrong; that TM is a Viridian City NPC gift (above).

**Traversal (verified by BFS over `Route22.blk` + `kanto_collision.asm`)**

The map is a set of shelves joined by one-way ledges. Entering from Viridian at
`(39, 6..9)`, the *only* path to the gate warp is:

```
(39,7) -> (35,7) -> (35,11)
(35,12) is COLL_HOP_DOWN  ->  hop to (35,14)          [ledge, one-way]
(35,14) -> (33,14) -> (33,13) -> (33,12)              [the one non-ledge gap]
(33,12) -> (33,11) grass -> (31,8) -> (31,7) -> (31,5) [the y=4..5 plaza]
(31,5) -> (18,5)
(18,6) is COLL_HOP_DOWN  ->  hop to (18,8)            [ledge, one-way]
(18,8) grass -> (18,12) -> (14,12) -> (14,8) -> (13,7) -> (13,6) -> (13,5) warp 1
```

Ledge semantics: a `COLL_HOP_*` tile is `LAND_TILE` and can be *walked onto*;
pressing the matching direction while standing on it jumps **two** cells, over
the wall beneath. There is no ledge-free route: `(18,7)` and `(35,13)` are
`COLL_WALL`.

Reachable tall grass in that component: `(18..21, 8..11)` and `(30..33, 8..11)`.
Surfable water adjacent to it: `(22..25, 6)` from the plaza row y=5, and
`(22..25, 9)` from the (22..25,10..11) shelf.

**Wild encounters** - `data/wild/kanto_grass.asm:1033`, `def_grass_wildmons ROUTE_22`,
encounter rate `10 percent` in all three time slots. Slot probabilities are
30/30/20/10/5/4/1 (`data/wild/probabilities.asm:6-15`).

| slot | morn | day | nite |
|---|---|---|---|
| 1 (30%) | L3 RATTATA | L3 RATTATA | L3 RATTATA |
| 2 (30%) | L3 SPEAROW | L3 SPEAROW | L3 RATTATA |
| 3 (20%) | L5 SPEAROW | L5 SPEAROW | L5 RATTATA |
| 4 (10%) | L4 DODUO | L4 DODUO | L4 RATTATA |
| 5 (5%) | L6 PONYTA | L6 PONYTA | L6 PONYTA |
| 6 (4%) | L7 FEAROW | L7 FEAROW | L7 RATTATA |
| 7 (1%) | L7 FEAROW | L7 FEAROW | L7 RATTATA |

Water (`data/wild/kanto_water.asm:68`, `def_water_wildmons ROUTE_22`, rate
`2 percent`, slot probabilities 60/30/10): L10 POLIWAG, L5 POLIWAG, L10 POLIWHIRL.
The FAQ's "#060 Poliwag (surfing)" is right; it omits Doduo, Ponyta and Fearow
from the grass list.

Fishing: `FISHGROUP_POND` (`data/wild/fish.asm:72-85`) - Old rod MAGIKARP/POLIWAG,
Good rod MAGIKARP/POLIWAG + a time group, Super rod POLIWAG/MAGIKARP + a time group.

Headbutt: Route 22 has **no** row in `data/wild/treemon_maps.asm`.

---

### MAP_VICTORY_ROAD_GATE

- Script: `maps/VictoryRoadGate.asm` (`data/maps/scripts.asm:452`)
- Blocks: `maps/VictoryRoadGate.blk` (`data/maps/blocks.asm:943`, 90 bytes)
- Header: `data/maps/maps.asm:467`
  `map VictoryRoadGate, TILESET_GATE, GATE, LANDMARK_ROUTE_26, MUSIC_INDIGO_PLATEAU, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
  (note the landmark is `LANDMARK_ROUTE_26`, not Route 22 or 28 - relevant if a
  bot keys anything off the Pokegear location readout)
- Attributes: `data/maps/attributes.asm:666` `map_attributes VictoryRoadGate, VICTORY_ROAD_GATE, $00`, no connections
- Dimensions: `constants/map_constants.asm:433` `map_const VICTORY_ROAD_GATE, 10, 9` -> 10x9 blocks = 20x18 cells. Group `VIRIDIAN` (23), map id 13.
- Scene variable: `data/maps/scenes.asm:16` `scene_var VICTORY_ROAD_GATE, wVictoryRoadGateSceneID` (sym `01:d6bf`)
- Scene scripts (`maps/VictoryRoadGate.asm:7-9`): `SCENE_VICTORYROADGATE_BADGE_CHECK` = 0 -> `VictoryRoadGateNoop1Scene` (bare `end`); `SCENE_VICTORYROADGATE_NOOP` = 1 -> `VictoryRoadGateNoop2Scene` (bare `end`). Both constants are minted by the `scene_script` macro's `scene_const` (`macros/scripts/maps.asm:12-33`), which is why grepping `constants/` for them finds nothing.

**Warps** (`maps/VictoryRoadGate.asm:101-109`)

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

**Coord events** (`maps/VictoryRoadGate.asm:111-112`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_VICTORYROADGATE_BADGE_CHECK` (0) | 10 | 11 | `VictoryRoadGateBadgeCheckScript` (sym `5f:4fdc`) | `turnobject PLAYER, LEFT` then the officer's speech; `< 8` Johto badges -> `applymovement PLAYER, VictoryRoadGateStepDownMovement` (one step DOWN); 8 badges -> `setscene SCENE_VICTORYROADGATE_NOOP` and the trip-wire never fires again |

A bot arriving from Route 22 (warp 1/2) never crosses (10,11): the east-west hall
is at y=5 and the badge check sits in the southern stub from Route 26. The check
is therefore *not* a gate on this section's route.

**BG events** - `def_bg_events` is empty.

**Object events** (`maps/VictoryRoadGate.asm:116-119`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VICTORYROADGATE_OFFICER` | `SPRITE_OFFICER` | 8 | 11 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `VictoryRoadGateOfficerScript` (sym `5f:4fe2`) | -1 |
| `VICTORYROADGATE_BLACK_BELT1` | `SPRITE_BLACK_BELT` | 7 | 5 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `VictoryRoadGateLeftBlackBeltScript` (sym `5f:5000`) | `EVENT_OPENED_MT_SILVER` |
| `VICTORYROADGATE_BLACK_BELT2` | `SPRITE_BLACK_BELT` | 12 | 5 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `VictoryRoadGateRightBlackBeltScript` (sym `5f:5003`) | `EVENT_FOUGHT_SNORLAX` |

**Geometry (from `VictoryRoadGate.blk` + `data/tilesets/gate_collision.asm`)**

The building is a plus: one 20-wide, **one-cell-tall** hall at y=5, a north stub
(x=8..11, y=0..4) to Victory Road, a south stub (x=8..11, y=6..17) to Route 26
with the officer's counter at y=10..13, and two 4-wide vestibules at y=6..7 -
west (x=0..3, the Route 28 warps) and east (x=16..19, the Route 22 warps).
Cells (7,5) and (12,5) are the only tiles joining the centre to the west and east
vestibules respectively, and each is exactly where a black belt stands.

BFS from the Route 22 warp (17,7), toggling the two NPCs:

| NPCs present | reach `ROUTE_28` warp (1,7) | reach Victory Road door (9,0) | reach badge coord (10,11) |
|---|---|---|---|
| neither | yes | yes | yes |
| left only (`EVENT_OPENED_MT_SILVER` clear) | **no** | yes | yes |
| right only (`EVENT_FOUGHT_SNORLAX` clear) | no | no | no |
| both | no | no | no |

**Trainers** - none.

---

### MAP_ROUTE_28

- Script: `maps/Route28.asm` (`data/maps/scripts.asm:131`) - one sign, one hidden item, no NPCs
- Blocks: `maps/Route28.blk` (`data/maps/blocks.asm:15`, 180 bytes)
- Header: `data/maps/maps.asm:396`
  `map Route28, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_28, MUSIC_INDIGO_PLATEAU, FALSE, PALETTE_AUTO, FISHGROUP_POND`
- Attributes: `data/maps/attributes.asm:174` `map_attributes Route28, ROUTE_28, $2c`
- Dimensions: `constants/map_constants.asm:366` `map_const ROUTE_28, 20, 9` -> 20x9 blocks = 40x18 cells. Group `SILVER` (19), map id 1.
- Connections: `connection west, SilverCaveOutside, SILVER_CAVE_OUTSIDE, -9`. Crossing west from `(0, y)` lands on Silver Cave Outside `(39, y + 18)`; crossing east from Silver Cave Outside `(39, y)` lands on Route 28 `(0, y - 18)`.
- Scene scripts / callbacks: both empty. **Route 28 has no flypoint callback** - the Fly destination near Mt. Silver is `SILVER_CAVE_OUTSIDE`.

**Warps** (`maps/Route28.asm:19-21`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 7 | 3 | `ROUTE_28_STEEL_WING_HOUSE` | 1 |
| 2 | 33 | 5 | `VICTORY_ROAD_GATE` | 7 |

**Coord events** - none.

**BG events** (`maps/Route28.asm:25-27`)

| x | y | type | script/item |
|---|---|---|---|
| 31 | 5 | `BGEVENT_READ` | `Route28Sign` (sym `4a:4d4d`) - read from (30,5) facing RIGHT |
| 25 | 2 | `BGEVENT_ITEM` | `Route28HiddenRareCandy` (sym `4a:4d50`) = `hiddenitem RARE_CANDY, EVENT_ROUTE_28_HIDDEN_RARE_CANDY` |

`RARE_CANDY` is item `$20` (`constants/item_constants.asm:40`). The hidden-item
row is three bytes (`dwb flag, item`), not a script; the port carries it on the
bg event as `hiddenItem = { item, event }` (`src/world/gen2/HiddenItems.lua:7-12`).

**Object events** - `def_object_events` is empty. No trainers, no item balls.

**Geometry: Route 28 is two disconnected halves**

BFS over `Route28.blk` from the Victory Road Gate landing (33,6):

- the **main body** reaches the sign approach (30,5) and the west edge only at
  y=12..13 -> Silver Cave Outside (39, 30..31);
- it does **not** reach (7,3), (25,3) or any of y=3..4.

BFS from the west edge at (0,3) - the **isolated north-west strip** -
reaches the house door (7,3) and the hidden-item approach (25,3), and then falls
one-way into the main body over the `COLL_HOP_DOWN` row at y=4 (x=4..9, landing
in the grass at y=6). So:

- entering the strip: only from `SILVER_CAVE_OUTSIDE (39,21)` -> `ROUTE_28 (0,3)`,
  which itself needs two Cuts (see below);
- inside the strip: (0,3) -> (5,3) -> (5,4) -> (7,4) -> north into the door (7,3);
  and (7,4) -> (21,4) -> (21,3) -> (25,3), then face UP for the hidden Rare Candy
  at (25,2);
- leaving the strip: hop any of the y=4 ledges (x=4..9) down into the main body,
  which is one-way. Re-entering means going round through Silver Cave Outside again.

Main-body route from the gate to Silver Cave Outside: (33,6) -> (28,6) -> (28,8),
hop (27,8)->(27,10), west along y=10 to (18,10) -> (18,9) -> (10,9) -> (10,10) ->
(8,10), hop (8,10)->(8,12), west along y=12 to (0,12).

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| Rare Candy | hidden, face (25,2) from (25,3) and press A, or use the Itemfinder | `Route28HiddenRareCandy` bg_event | `EVENT_ROUTE_28_HIDDEN_RARE_CANDY` (`constants/event_flags.asm:173`) |

The FAQ lists "Items: TM47 Steel Wing" for Route 28 and never mentions the Rare
Candy. TM47 is in the house, not on the route.

**Wild encounters** - `data/wild/kanto_grass.asm:1227`, `def_grass_wildmons ROUTE_28`,
rate `10 percent` all day. The table is `IF DEF(_GOLD) / ELIF DEF(_SILVER)`:

| slot | Gold morn/day | Gold nite | Silver morn/day | Silver nite |
|---|---|---|---|---|
| 1 (30%) | L39 TANGELA | L39 TANGELA | L39 TANGELA | L39 TANGELA |
| 2 (30%) | L40 PONYTA | L40 PONYTA | L40 PONYTA | L40 PONYTA |
| 3 (20%) | L40 URSARING | L40 URSARING | L40 DONPHAN | L40 DONPHAN |
| 4 (10%) | L42 RAPIDASH | L40 SNEASEL | L42 RAPIDASH | L40 SNEASEL |
| 5 (5%) | L41 DODUO | L42 RAPIDASH | L41 DODUO | L42 RAPIDASH |
| 6 (4%) | L43 DODRIO | L42 RAPIDASH | L43 DODRIO | L42 RAPIDASH |
| 7 (1%) | L43 DODRIO | L42 RAPIDASH | L43 DODRIO | L42 RAPIDASH |

So on **Gold** the FAQ's Donphan does not appear (Ursaring takes that slot), and
**Sneasel is nite-only**. Tangela is the 30% lead slot at every time of day,
which makes the FAQ's "consider catching a Tangela" cheap to satisfy.

Water (`data/wild/kanto_water.asm:110`, rate `2 percent`): L40 POLIWAG, L35
POLIWAG, L40 POLIWHIRL. Fishing: `FISHGROUP_POND`, same table as Route 22.
Headbutt: `data/wild/treemon_maps.asm:9` `treemon_map ROUTE_28, TREEMON_SET_NONE`
- headbutting a Route 28 tree yields nothing.

---

### MAP_ROUTE_28_STEEL_WING_HOUSE

- Script: `maps/Route28SteelWingHouse.asm` (`data/maps/scripts.asm:388`)
- Blocks: `data/maps/blocks.asm:181` (`Route28SteelWingHouse_Blocks`)
- Header: `data/maps/maps.asm:399`
  `map Route28SteelWingHouse, TILESET_HOUSE, INDOOR, LANDMARK_ROUTE_28, MUSIC_AZALEA_TOWN, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Attributes: `data/maps/attributes.asm:624`, no connections
- Dimensions: `constants/map_constants.asm:369` `map_const ROUTE_28_STEEL_WING_HOUSE, 4, 4` -> 8x8 cells. Group `SILVER` (19), map id 4.
- Scene scripts: one `scene_script Route28SteelWingHouseNoopScene` marked "unusable" in the source; body is a bare `end`.

**Warps** (`maps/Route28SteelWingHouse.asm:74-76`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `ROUTE_28` | 1 |
| 2 | 3 | 7 | `ROUTE_28` | 1 |

**Coord events** - none.

**BG events** (`maps/Route28SteelWingHouse.asm:80-82`)

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `CelebrityHouseBookshelf` -> `jumpstd MagazineBookshelfScript` |
| 1 | 1 | `BGEVENT_READ` | `CelebrityHouseBookshelf` |

**Object events** (`maps/Route28SteelWingHouse.asm:84-86`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE28STEELWINGHOUSE_CELEBRITY` | `SPRITE_COOLTRAINER_F` | 2 | 3 | `STANDING_DOWN`, `PAL_NPC_GREEN` | `OBJECTTYPE_SCRIPT` | `Celebrity` (sym `5c:4be9`) | -1 |
| `ROUTE28STEELWINGHOUSE_FEAROW` | `SPRITE_MOLTRES` | 6 | 5 | `SPRITEMOVEDATA_POKEMON`, `PAL_NPC_BROWN` | `OBJECTTYPE_SCRIPT` | `CelebritysFearow` (sym `5c:4c06`) | -1 |

The pet is a Fearow but reuses `SPRITE_MOLTRES` recoloured with `PAL_NPC_BROWN`;
`CelebritysFearow` does `cry FEAROW`. Worth knowing if a bot asserts on sprite ids.

**Scripts of interest**

`Celebrity` (`maps/Route28SteelWingHouse.asm:14-31`, sym `5c:4be9`):

```
faceplayer / opentext
checkevent EVENT_GOT_TM47_STEEL_WING
iftrue .AlreadyGotItem
writetext CelebrityText1 / promptbutton
verbosegiveitem TM_STEEL_WING
iffalse .Done                      ; bag full -> flag NOT set, retryable
setevent EVENT_GOT_TM47_STEEL_WING
.Done: closetext / end
```

Note the shape differs from the Dream Eater fisher: there is no "thanks" text
after a successful give, the script just closes.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| TM47 Steel Wing (`$ef`) | talk to `Celebrity` at (2,3) from (2,4) facing UP | `Celebrity` | `EVENT_GOT_TM47_STEEL_WING` (`constants/event_flags.asm:125`) |

---

### MAP_SILVER_CAVE_OUTSIDE (east edge only - the rest is the next section)

- Script: `maps/SilverCaveOutside.asm` (`data/maps/scripts.asm:124`)
- Blocks: `maps/SilverCaveOutside.blk` (`data/maps/blocks.asm:559`, 360 bytes)
- Header: `data/maps/maps.asm:397`
  `map SilverCaveOutside, TILESET_KANTO, TOWN, LANDMARK_SILVER_CAVE, MUSIC_INDIGO_PLATEAU, FALSE, PALETTE_AUTO, FISHGROUP_POND`
- Attributes: `data/maps/attributes.asm:164` `map_attributes SilverCaveOutside, SILVER_CAVE_OUTSIDE, $2c`
- Dimensions: `constants/map_constants.asm:367` `map_const SILVER_CAVE_OUTSIDE, 20, 18` -> 40x36 cells. Group `SILVER` (19), map id 2.
- Connections: `connection east, Route28, ROUTE_28, 9`
- Callbacks: `callback MAPCALLBACK_NEWMAP, SilverCaveOutsideFlypointCallback` (sym `49:5f1a`) -> `setflag ENGINE_FLYPOINT_SILVER_CAVE`. Spawn `SPAWN_MT_SILVER` = (23,20) (`data/maps/spawn_points.asm:39`), i.e. the tile below the Pokecenter door - this is the "fly back to the Pokémon Center on Route 28" the FAQ means.

**Warps** (`maps/SilverCaveOutside.asm:27-29`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 23 | 19 | `SILVER_CAVE_POKECENTER_1F` | 1 |
| 2 | 18 | 11 | `SILVER_CAVE_ROOM_1` | 1 |

**BG events** (`maps/SilverCaveOutside.asm:33-36`)

| x | y | type | script/item |
|---|---|---|---|
| 24 | 19 | `BGEVENT_READ` | `MtSilverPokecenterSign` (sym `49:5f1e`) |
| 17 | 13 | `BGEVENT_READ` | `MtSilverSign` (sym `49:5f21`) |
| 9 | 25 | `BGEVENT_ITEM` | `SilverCaveOutsideHiddenFullRestore` (sym `49:5f24`) = `hiddenitem FULL_RESTORE, EVENT_SILVER_CAVE_OUTSIDE_HIDDEN_FULL_RESTORE` (`constants/event_flags.asm:194`) - **next section's**, and not reachable from the east side without Surf |

**Coord events / object events** - both empty.

**The two Cut trees (verified from block data)**

`data/collision/field_move_blocks.asm:24-31`, `CutTreeBlockPointers.kanto`, lists
the cuttable blocks for `TILESET_KANTO`: `$0b -> $0a` (grass, animation 1) and
`$32 -> $6d`, `$33 -> $6c`, `$34 -> $6f`, `$35 -> $4c`, `$60 -> $6e` (trees,
animation 0). `SilverCaveOutside.blk` contains exactly two of them:

| block coord | block id | `tilecoll` row | `COLL_CUT_TREE` cell | replacement block |
|---|---|---|---|---|
| (17,11) | `$60` | `FLOOR, WALL, CUT_TREE, WALL` | **(34,23)** | `$6e` |
| (15,12) | `$35` | `FLOOR, CUT_TREE, WALL, FLOOR` | **(31,24)** | `$4c` |

BFS from the Route 28 landing (39,30):

- with no cuts: the Pokecenter door (23,19), the cave mouth (18,11) and the
  approach tile (30,24) are reachable; (39,21) is **not**;
- after cutting (31,24) only: (34,24) becomes reachable, (39,21) still not;
- after cutting both: (39,21) is reachable -> `ROUTE_28 (0,3)`.

Route from the Pokecenter door to the house, waypoint by waypoint:

```
(23,19) door -> (23,20) -> (25,20) -> (25,22) -> (30,22) -> (30,24)
face RIGHT, Cut (31,24)
(31,24) -> (31,25) -> (34,25) -> (34,24)
face UP, Cut (34,23)
(34,23) -> (34,21) -> (39,21) -> cross east -> ROUTE_28 (0,3)
(0,3) -> (5,3) -> (5,4) -> (7,4) -> face UP into warp 1 at (7,3)
```

---

### MAP_SILVER_CAVE_POKECENTER_1F

- Script: `maps/SilverCavePokecenter1F.asm` (`data/maps/scripts.asm:387`)
- Header: `data/maps/maps.asm:398`
  `map SilverCavePokecenter1F, TILESET_POKECENTER, INDOOR, LANDMARK_SILVER_CAVE, MUSIC_POKEMON_CENTER, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Attributes: `data/maps/attributes.asm:623`
- Dimensions: `constants/map_constants.asm:368` `map_const SILVER_CAVE_POKECENTER_1F, 5, 4` -> 10x8 cells. Group `SILVER` (19), map id 3.

**Warps** (`maps/SilverCavePokecenter1F.asm:33-36`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `SILVER_CAVE_OUTSIDE` | 1 |
| 2 | 4 | 7 | `SILVER_CAVE_OUTSIDE` | 1 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

**Object events** (`maps/SilverCavePokecenter1F.asm:42-44`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `SILVERCAVEPOKECENTER1F_NURSE` | `SPRITE_NURSE` | 3 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `SilverCavePokecenter1FNurseScript` (sym `5c:4b2b`) -> `jumpstd PokecenterNurseScript` | -1 |
| `SILVERCAVEPOKECENTER1F_GRANNY` | `SPRITE_GRANNY` | 1 | 5 | `STANDING_LEFT` (r 2,1) | `OBJECTTYPE_SCRIPT` | `SilverCavePokecenter1FGrannyScript` (sym `5c:4b2e`) | -1 |

No mart clerk on this map - the FAQ's "fly to Mahogany Town's Pokemart to buy
some" is correct precisely because there is nothing to buy here.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Route 28 / Mt. Silver | `maps/VictoryRoadGate.asm:118` object row `VICTORYROADGATE_BLACK_BELT1` at (7,5) + `engine/overworld/map_objects_2.asm:32` `CheckObjectFlag` | `EVENT_OPENED_MT_SILVER` set, which hides the NPC and frees the only tile between the gate's centre and its west vestibule | talk to `Oak` (`maps/OaksLab.asm:15`) with `VAR_BADGES == NUM_BADGES` (16; `constants/ram_constants.asm:273`) |
| Route 22 from the gate | `maps/VictoryRoadGate.asm:119` object row `VICTORYROADGATE_BLACK_BELT2` at (12,5) | `EVENT_FOUGHT_SNORLAX` (`constants/event_flags.asm:1266`) | set long before this section (Kanto). Listed because it uses the same mechanism and a bot that clears flags for testing will wall itself in |
| Victory Road Gate south corridor | `maps/VictoryRoadGate.asm:112` coord event (10,11) -> `VictoryRoadGateBadgeCheckScript` | `readvar VAR_BADGES` `ifgreater NUM_JOHTO_BADGES - 1` i.e. >= 8 badges | already satisfied; and the Route 22 -> Route 28 path never touches (10,11) |
| Dream Eater fisher (Viridian) | `data/collision/field_move_blocks.asm:24` `.kanto` block `$34` at Viridian block (4,11) -> `COLL_CUT_TREE` at cell (8,22) | HM01 Cut in the party **and** `ENGINE_HIVEBADGE` | `engine/events/overworld.asm:1741` `TryCutOW`: `CheckPartyMove CUT`, then `ld de, ENGINE_HIVEBADGE / call CheckEngineFlag`; failure runs `CantCutScript` |
| Steel Wing house / Route 28 west strip | two `COLL_CUT_TREE` cells on `SILVER_CAVE_OUTSIDE`: (31,24) (block `$35`) and (34,23) (block `$60`) | same Cut + `ENGINE_HIVEBADGE` check | as above. Both trees are required - cutting only (31,24) does not open (39,21) |
| Fly to Pallet / Viridian / Mt. Silver | `engine/events/overworld.asm:543-545` `FlyFunction.TryFly`: `ld de, ENGINE_STORMBADGE / call CheckBadge`, then `GetMapEnvironment` / `CheckOutdoorMap` | STORMBADGE + HM02 Fly + the destination's `ENGINE_FLYPOINT_*` bit | `ENGINE_FLYPOINT_PALLET` (`constants/engine_flags.asm:67`), `ENGINE_FLYPOINT_VIRIDIAN` (68), `ENGINE_FLYPOINT_SILVER_CAVE` (90), each set by that map's `MAPCALLBACK_NEWMAP` the first time you walk in |
| Surf (Route 22 / Route 28 water) | `engine/events/overworld.asm:340` and `:490`, `ld de, ENGINE_FOGBADGE` | FOGBADGE + HM03 Surf | optional in this section |
| Route 22 traversal | `Route22.blk` collision: `(35,12)` and `(18,6)` are `COLL_HOP_DOWN` with `COLL_WALL` beneath | ledge hopping (walk onto the ledge tile, then press the matching direction to jump two cells) | no item needed, but there is **no** ledge-free route to the gate warp |
| Route 28 west strip re-entry | `Route28.blk` y=4 ledge row (x=4..9) | one-way; falling off it drops you into the main body | re-enter via `SILVER_CAVE_OUTSIDE (39,21)` |

## 4. Bot checklist

Preconditions for the whole section: 16 badges, HM01 Cut + HIVEBADGE, HM02 Fly +
STORMBADGE, `EVENT_FOUGHT_SNORLAX` set, `ENGINE_FLYPOINT_PALLET` and
`ENGINE_FLYPOINT_VIRIDIAN` already visited.

| # | Map | Target | Intent | Precondition | Postcondition |
|---|---|---|---|---|---|
| 1 | anywhere outdoor | `SPAWN_PALLET` | Fly | STORMBADGE, `ENGINE_FLYPOINT_PALLET` | player at `PALLET_TOWN` (5,6) |
| 2 | `PALLET_TOWN` | (12,11) | walk (5,6)->(9,6)->(9,12)->(12,12)->(12,11) | - | warp to `OAKS_LAB` (4,11) |
| 3 | `OAKS_LAB` | (4,3) facing UP | walk, then talk to `OAKSLAB_OAK` | `VAR_BADGES == 16` | `EVENT_OPENED_MT_SILVER` set; expect `EVENT_TALKED_TO_OAK_IN_KANTO` on the first visit and a `ProfOaksPCBoot` dex-rating textbox chain |
| 4 | `OAKS_LAB` | (4,11) | walk into warp 1 | - | back on `PALLET_TOWN` (12,11) |
| 5 | anywhere outdoor | `SPAWN_VIRIDIAN` | Fly | `ENGINE_FLYPOINT_VIRIDIAN` | player at `VIRIDIAN_CITY` (23,26) |
| 6 (optional) | `VIRIDIAN_CITY` | (9,22) facing LEFT | walk (23,26)->(14,26)->(14,23)->(10,23)->(10,22)->(9,22), then Cut | Cut + HIVEBADGE, `EVENT_GOT_TM42_DREAM_EATER` clear | block at (8,22) replaced with `$6f` |
| 7 (optional) | `VIRIDIAN_CITY` | `VIRIDIANCITY_FISHER` at (6,23), talk from (6,22) facing DOWN | talk | bag has room | TM42 Dream Eater; `EVENT_GOT_TM42_DREAM_EATER` set |
| 8 | `VIRIDIAN_CITY` | west edge, x=0 at y=15 | walk (0,17)->(0,15) then step LEFT | - | map change to `ROUTE_22` (39,7) |
| 9 | `ROUTE_22` | (35,12) | walk (39,7)->(35,7)->(35,11)->(35,12) | - | standing on a `COLL_HOP_DOWN` tile |
| 10 | `ROUTE_22` | press DOWN | ledge hop | - | player at (35,14) |
| 11 | `ROUTE_22` | (33,12) | walk (35,14)->(33,14)->(33,13)->(33,12) | - | - |
| 12 | `ROUTE_22` | (31,5) | walk (33,12)->(33,11)->(31,11)->(31,8)->(31,7)->(31,6)->(31,5) - crosses the tall grass at (30..33, 8..11) | - | expect wild encounters, 10% per step in grass |
| 13 | `ROUTE_22` | (18,6) | walk west along y=5 to (18,5), then DOWN onto (18,6) | - | standing on a ledge tile |
| 14 | `ROUTE_22` | press DOWN | ledge hop | - | player at (18,8), in the west grass patch |
| 15 | `ROUTE_22` | (13,5) | walk (18,8)->(18,12)->(14,12)->(14,8)->(13,8)->(13,7)->(13,6)->(13,5) | - | warp to `VICTORY_ROAD_GATE` (17,7) |
| 16 | `VICTORY_ROAD_GATE` | (1,7) | walk (17,7)->(17,5)->west along y=5->(1,5)->(1,7) | `EVENT_OPENED_MT_SILVER` **and** `EVENT_FOUGHT_SNORLAX` set (both black belts hidden) | warp to `ROUTE_28` (33,5) |
| 17 | `ROUTE_28` | (0,12) | walk (33,5)->(33,6)->(28,6)->(28,8), hop (27,8)->(27,10), west y=10 to (18,10)->(18,9)->(10,9)->(10,10)->(8,10), hop ->(8,12), west to (0,12) | - | map change to `SILVER_CAVE_OUTSIDE` (39,30) |
| 18 | `SILVER_CAVE_OUTSIDE` | (23,20) | walk north-west to the Pokecenter door | - | `ENGINE_FLYPOINT_SILVER_CAVE` set by `MAPCALLBACK_NEWMAP` |
| 19 | `SILVER_CAVE_OUTSIDE` | (23,19) | step UP into warp 1 | - | `SILVER_CAVE_POKECENTER_1F` (3,7) |
| 20 | `SILVER_CAVE_POKECENTER_1F` | nurse at (3,1), talk from (3,2) facing UP | heal | - | party restored |
| 21 | `SILVER_CAVE_POKECENTER_1F` | (3,7) | step DOWN into warp 1 | - | `SILVER_CAVE_OUTSIDE` (23,19) |
| 22 | `SILVER_CAVE_OUTSIDE` | (30,24) facing RIGHT | walk (23,20)->(25,20)->(25,22)->(30,22)->(30,24), then Cut | Cut + HIVEBADGE | (31,24) replaced with `$4c` |
| 23 | `SILVER_CAVE_OUTSIDE` | (34,24) facing UP | walk (31,24)->(31,25)->(34,25)->(34,24), then Cut | Cut + HIVEBADGE | (34,23) replaced with `$6e` |
| 24 | `SILVER_CAVE_OUTSIDE` | (39,21) | walk (34,23)->(34,21)->(39,21), step RIGHT | - | map change to `ROUTE_28` (0,3) |
| 25 | `ROUTE_28` | (25,3) facing UP | walk (0,3)->(5,3)->(5,4)->(7,4)->(21,4)->(21,3)->(25,3), press A | `EVENT_ROUTE_28_HIDDEN_RARE_CANDY` clear | Rare Candy; flag set |
| 26 | `ROUTE_28` | (7,3) | walk back west along y=4 to (7,4), step UP | - | warp to `ROUTE_28_STEEL_WING_HOUSE` (2,7) |
| 27 | `ROUTE_28_STEEL_WING_HOUSE` | `Celebrity` at (2,3), talk from (2,4) facing UP | talk | bag has room, `EVENT_GOT_TM47_STEEL_WING` clear | TM47 Steel Wing; flag set |
| 28 | `ROUTE_28_STEEL_WING_HOUSE` | (2,7) | step DOWN into warp 1 | - | `ROUTE_28` (7,3) |
| 29 | `ROUTE_28` | any y=4 ledge (x=4..9) | walk to it and press DOWN | - | one-way drop into the Route 28 main body (grass at y=6) - the strip cannot be re-entered from here |
| 30 | - | shopping run | Fly to Mahogany, buy, Fly back to `SPAWN_MT_SILVER` | `ENGINE_FLYPOINT_SILVER_CAVE` set in step 18 | ready for `SILVER_CAVE_OUTSIDE` warp 2 at (18,11) - next section |

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map headers, dimensions, warps / coord / bg / object event tables for all of these maps | `src/import/RomExtractorGen2.lua:787-862` (`warps`, `coordEvents`, `bgEvents`, `objects`), consumed by `src/world/gen2/Map.lua` | implemented, and generic - no per-map work needed |
| Map connections and the offset landing maths | `src/world/gen2/Map.lua:71-92` `Map.connectionLanding` | implemented (same block-offset maths this doc's route uses) |
| `object_event` event-flag masking (the black-belt gate) | `src/world/gen2/Events.lua:40-44` `Events:objectVisible`, called from `src/world/gen2/World.lua:5106` and `:5122` | implemented, with the correct "flag set -> hidden" polarity |
| `Oak`'s opcode chain (`checkevent` / `readvar` / `setevent` / `special`) | `src/script/gen2/Vm.lua:187` (`checkevent`), `:670` (`readvar`), `src/world/gen2/World.lua:1240-1245` (`VAR_BADGES` = popcount of both badge bytes) | implemented |
| `special ProfOaksPCBoot` (the dex rating after every Oak conversation) | `src/script/gen2/Specials.lua:1778` `H.ProfOaksPCBoot` | implemented, including the `OakRatings` table and the fanfare wait |
| `verbosegiveitem` for TM42 / TM47, including the bag-full `iffalse` arm | `src/script/gen2/Vm.lua:490-498` | implemented |
| `hiddenitem` (Route 28 Rare Candy) via `BGEVENT_ITEM` | `src/world/gen2/HiddenItems.lua` (whole file), wired at `src/world/gen2/World.lua:30` and `:3423` | implemented |
| `jumpstd` for `PokecenterNurseScript` / `MagazineBookshelfScript` / `DifficultBookshelfScript` / `PokecenterSignScript` / `MartSignScript` | `src/script/gen2/Vm.lua:742-747` | implemented (std scripts are extracted and run through the same VM) |
| Cut: badge + party-move check, `CutTreeBlockPointers` lookup, block replacement | `src/world/gen2/FieldMoves.lua:101-107` (badge map), `:183-237` (`field_move_blocks.asm` transcribed), `:454`, `:605-619` | implemented |
| Fly: STORMBADGE check, flypoint table, `ENGINE_FLYPOINT_*` bits | `src/world/gen2/FieldMoves.lua:336-380` (`FLYPOINTS`, incl. `SPAWN_PALLET` 52, `SPAWN_VIRIDIAN` 53, `SPAWN_MT_SILVER` 75), `src/ui/TownMap.lua:146-208`, `src/world/gen2/World.lua:4292` | implemented |
| Scene scripts / `setscene` / coord-event dispatch (Victory Road Gate badge check) | `src/world/gen2/World.lua:470` (`mapScenes`), `:5013-5033` | implemented |
| `cry FEAROW` on the celebrity's pet | `src/script/gen2/Vm.lua:621` | implemented |
| **Ledge hopping (`COLL_HOP_DOWN` / `HOP_LEFT` / `HOP_RIGHT` / `HOP_DOWN_LEFT` / `HOP_DOWN_RIGHT`)** | `src/world/gen2/Player.lua:50-83` `Player:tryMove` - plain single-cell step, no `CheckLedge` equivalent; `src/world/gen2/Permissions.lua` maps `$a0..$a7` to `LAND` so the tiles are walkable but never jump | **missing.** Route 22 cannot be crossed without it: `(35,12)` and `(18,6)` are ledges over `COLL_WALL`, and there is no alternative route to the gate warp. Route 28's west strip also exits only by ledge |
| Route 22 / Route 28 / Silver Cave wild tables | generic (`data/wild/*` extracted by `RomExtractorGen2.lua`) | implemented as data; not separately verified for these three maps |
| A driver that walks any of this | `tests/drivers/gold_*.lua` (25 drivers; none touches Kanto or Mt. Silver) | missing |

## 6. Unresolved / verify by hand

- **"Items on Route 22: TM42 Dream Eater"** - the asm puts the Dream Eater NPC on
  `MAP_VIRIDIAN_CITY` at (6,23) (`maps/ViridianCity.asm:239`). `maps/Route22.asm`
  has an empty `def_object_events` and no item bg event at all. The FAQ's prose
  ("If you cut the tree to the west of Viridian City") is right; its item header
  is wrong.
- **"There's also a Pokémon Center here" (Route 28)** - there is no Pokecenter on
  `MAP_ROUTE_28`. The nearest one is `MAP_SILVER_CAVE_POKECENTER_1F`, entered from
  `MAP_SILVER_CAVE_OUTSIDE` warp 1 at (23,19), one map west.
- **"Items [Route 28]: TM47 Steel Wing"** - TM47 is inside
  `MAP_ROUTE_28_STEEL_WING_HOUSE`. Route 28 itself has one item, the hidden Rare
  Candy at (25,2), which the FAQ never mentions.
- **"#232 Donphan (Silver only)"** - correct as far as it goes, but the FAQ omits
  what Gold puts in that slot (Ursaring, 20%) and omits Doduo/Dodrio entirely.
  It also does not say Sneasel is nite-only.
- **Route 22 Pokemon list** - the FAQ lists only Spearow, Rattata and Poliwag.
  `data/wild/kanto_grass.asm:1033` also has Doduo (10%), Ponyta (5%) and Fearow
  (4%+1%) in the morn/day tables.
- **The FAQ's "keep heading north, west, then north"** is a fair prose summary but
  omits the two mandatory ledge hops. The waypoint list in section 4 was derived
  by BFS over `Route22.blk` against `data/tilesets/kanto_collision.asm` with the
  ledge rule "step onto a `COLL_HOP_*` tile, then a matching press moves two
  cells". That rule was inferred from the collision permission table
  (`$a0..$a7` are `LAND_TILE`) and from the fact that every ledge on these maps
  has `COLL_WALL` directly beyond it; the exact `DoPlayerMovement` ledge branch
  in `engine/overworld/player_movement.asm` was **not** read line by line.
  Worth confirming before a driver depends on the two-cell jump distance.
- **Route 28's "unreachable" rows** - `SILVER_CAVE_OUTSIDE`'s east edge is also
  walkable at y=14..18 and y=33..35, which map to `ROUTE_28` y=-4..0 and y=15..17.
  Those Route 28 rows are outside the component reachable from either the gate or
  the west strip, so they look like filler; not chased further.
- **Mt. Silver entry itself** - `maps/SilverCaveOutside.asm` has no coord event,
  no callback check and no NPC guarding warp 2 at (18,11), and
  `EVENT_OPENED_MT_SILVER` is referenced in exactly two places
  (`maps/OaksLab.asm:18,43` and `maps/VictoryRoadGate.asm:118`). So the flag gates
  the *corridor*, not the cave mouth. If a save is hacked past the gate NPC, the
  cave is open.
- **Party/level requirements** - the FAQ's "at least 10 Revives, 10 Hyper Potions,
  5 Escape Ropes, 5 Max Repels, and 50 Ultra Balls" is advice, not a coded gate.
  Nothing in the asm checks the bag here.

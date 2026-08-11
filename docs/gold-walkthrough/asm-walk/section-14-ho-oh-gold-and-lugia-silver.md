# Section 14 - Ho-Oh (Gold) and Lugia (Silver)

Source: `../section-14-ho-oh-gold-and-lugia-silver.txt`
Maps covered: `ECRUTEAK_TIN_TOWER_ENTRANCE`, `ECRUTEAK_TIN_TOWER_BACK_ENTRANCE`,
`TIN_TOWER_1F`, `TIN_TOWER_2F`, `TIN_TOWER_3F`, `TIN_TOWER_4F`, `TIN_TOWER_5F`,
`TIN_TOWER_6F`, `TIN_TOWER_7F`, `TIN_TOWER_8F`, `TIN_TOWER_9F`, `TIN_TOWER_ROOF`,
`ROUTE_41` (transit only), `WHIRL_ISLAND_NE`, `WHIRL_ISLAND_NW`, `WHIRL_ISLAND_SW`,
`WHIRL_ISLAND_SE`, `WHIRL_ISLAND_CAVE`, `WHIRL_ISLAND_B1F`, `WHIRL_ISLAND_B2F`,
`WHIRL_ISLAND_LUGIA_CHAMBER`

Badges / key milestones in this section: no badge is awarded here. The milestones
are `EVENT_FOUGHT_HO_OH` (Gold, Tin Tower Roof) and `EVENT_FOUGHT_LUGIA` (Silver,
Whirl Island Lugia Chamber). Both are one-shot: the callback that spawns the
legendary refuses to re-spawn it once the flag is set.

Version split, straight from the asm (both legendaries exist in both carts, only
the wing you own differs):

- `maps/RadioTower5F.asm` after the Rocket takeover runs `checkver` /
  `iftrue .SilverWing`. Gold (`checkver` false) gets `verbosegiveitem RAINBOW_WING`
  plus `setevent EVENT_GOT_RAINBOW_WING` and `setevent EVENT_TEAM_ROCKET_DISBANDED`;
  Silver gets `verbosegiveitem SILVER_WING` / `setevent EVENT_GOT_SILVER_WING`.
- `maps/PewterCity.asm` (`PewterCityGrampsScript`) is the mirror image and hands
  out the *other* wing in Kanto: Gold gets `SILVER_WING`, Silver gets
  `RAINBOW_WING` (and Silver's branch is the one that sets
  `EVENT_TEAM_ROCKET_DISBANDED` there).

So in Gold this section is Tin Tower / Ho-Oh; in Silver it is Whirl Islands /
Lugia; the other one is a Kanto-era return trip.

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `ECRUTEAK_CITY` | `maps/EcruteakCity.asm` | fly / Route 42 | warp 3 at (18,11) | Gold branch starts here, "go back to Ecruteak City" |
| 2 | `ECRUTEAK_TIN_TOWER_ENTRANCE` | `maps/EcruteakTinTowerEntrance.asm` | warp 1 (4,17) / warp 2 (5,17) | warp 3 (5,3) -> in-map warp 4 (17,15); then warp 5 (17,3) | "go into the Bell Tower entry house. Talk to the man and he'll let you through" |
| 3 | `ECRUTEAK_TIN_TOWER_BACK_ENTRANCE` | `maps/EcruteakTinTowerBackEntrance.asm` | warp 3 (2,4) | warp 1 (7,4) / warp 2 (7,5) -> `ECRUTEAK_CITY` warps 4/5 at (20,2)/(20,3) | "follow up the trail to the tower itself" |
| 4 | `ECRUTEAK_CITY` (north yard) | `maps/EcruteakCity.asm` | warps 4/5 | warp 12 at (37,7) | walk east to the tower door |
| 5 | `TIN_TOWER_1F` | `maps/TinTower1F.asm` | warp 1 (9,15) / warp 2 (10,15) | warp 3 (10,2) | "another bald man will let you through because you have the beautiful Rainbow Wing" |
| 6 | `TIN_TOWER_2F` | `maps/TinTower2F.asm` | warp 2 (10,2) | warp 1 (10,14) | "wild Rattatas will start converging on you like zombies" |
| 7 | `TIN_TOWER_3F` | `maps/TinTower3F.asm` | warp 1 (10,14) | warp 2 (16,2) | Full Heal grab |
| 8 | `TIN_TOWER_4F` | `maps/TinTower4F.asm` | warp 2 (16,2) | warp 1 (2,4), warp 3 (2,14) or warp 4 (17,15) | Ultra Ball / Escape Rope hop puzzle |
| 9 | `TIN_TOWER_5F` | `maps/TinTower5F.asm` | warps 2/3/4 | warp 1 (11,15) | Rare Candy |
| 10 | `TIN_TOWER_6F` | `maps/TinTower6F.asm` | warp 2 (11,15) | warp 1 (3,9) | bridge floor |
| 11 | `TIN_TOWER_7F` | `maps/TinTower7F.asm` | warp 1 (3,9) | warp 2 (10,15) (also in-map pair warp 3 (12,7) <-> warp 4 (8,3), and warp 5 (6,9) -> 9F) | Max Revive |
| 12 | `TIN_TOWER_8F` | `maps/TinTower8F.asm` | warp 1 (2,5) | warps 2-6 -> 9F | Max Elixer / Nugget / Full Restore |
| 13 | `TIN_TOWER_9F` | `maps/TinTower9F.asm` | warps 1/2/3/6/7 | warp 4 (7,9) | "go up the ladder, cross the planks down, then go up the ladder" |
| 14 | `TIN_TOWER_ROOF` | `maps/TinTowerRoof.asm` | warp 1 (9,13) | warp 1 back to 9F, or Escape Rope | level 40 Ho-Oh |
| 15 | `ROUTE_41` | `maps/Route41.asm` | surf south from Route 40 | warp 2 (36,19) | Silver branch: "surf southwest and west until you reach the northeast cave" |
| 16 | `WHIRL_ISLAND_NE` | `maps/WhirlIslandNE.asm` | warp 1 (3,13) | warp 2 (17,3) or warp 3 (13,11) | Flash, Ultra Ball |
| 17 | `WHIRL_ISLAND_B1F` | `maps/WhirlIslandB1F.asm` | warps 2/3 from NE | warp 7 (25,21) / warp 8 (13,27) to B2F | Escape Rope, Calcium, boulder |
| 18 | `WHIRL_ISLAND_NW` | `maps/WhirlIslandNW.asm` | warp 2 (5,3) from B1F warp 1 | warp 1 (5,7) to Route 41, warp 3 (3,15) to SW, warp 4 (7,15) to Cave | "head out the door to breathe" |
| 19 | `WHIRL_ISLAND_CAVE` | `maps/WhirlIslandCave.asm` | warp 2 (3,13) from NW | warp 1 (7,5) to B1F | short connector |
| 20 | `WHIRL_ISLAND_SW` | `maps/WhirlIslandSW.asm` | warps 2/3 from B1F, warp 4 from NW | warp 5 (17,15) to B2F, warp 1 (5,7) to Route 41 | Guard Spec |
| 21 | `WHIRL_ISLAND_SE` | `maps/WhirlIslandSE.asm` | warp 2 (5,3) from B1F warp 6 | warp 1 (5,13) to Route 41 | "go down out the door" |
| 22 | `WHIRL_ISLAND_B2F` | `maps/WhirlIslandB2F.asm` | warps 1/2 from B1F, warp 4 from SW | warp 3 (7,25) | Max Revive, waterfall descent |
| 23 | `WHIRL_ISLAND_LUGIA_CHAMBER` | `maps/WhirlIslandLugiaChamber.asm` | warp 1 (9,13) | warp 1 back to B2F, or Escape Rope | "surf north to Lugia" |

Spill-over: the walkthrough's Silver branch opens on Route 41 with Swimmer Kara
and the whirlpool tiles. Route 41 itself (its ten swimmers, the hidden Max Ether
at (9,35), the Olivine/Cianwood crossing) belongs to the earlier Olivine ->
Cianwood section; only its four island warps are treated here. The closing lines
("fly back to Blackthorn City" / "fly back to Mahogany Town") also belong to the
next section.

---

## 2. Maps

### MAP_ECRUTEAK_TIN_TOWER_ENTRANCE

- Script: `maps/EcruteakTinTowerEntrance.asm` (sym `52:4000 EcruteakTinTowerEntrance_MapScripts`, `52:4210 EcruteakTinTowerEntrance_MapEvents`)
- Blocks: `maps/EcruteakTinTowerEntrance.blk` (sym `37:452c EcruteakTinTowerEntrance_Blocks`)
- Header: `data/maps/maps.asm:165` -> `TILESET_TOWER, INDOOR, LANDMARK_ECRUTEAK_CITY, MUSIC_ECRUTEAK_CITY, phone FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:151` -> `map_const ECRUTEAK_TIN_TOWER_ENTRANCE, 10, 9`
- Connections: none (`data/maps/attributes.asm:495`, border block `$00`)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 17 | `ECRUTEAK_CITY` | 3 |
| 2 | 5 | 17 | `ECRUTEAK_CITY` | 3 |
| 3 | 5 | 3 | `ECRUTEAK_TIN_TOWER_ENTRANCE` | 4 |
| 4 | 17 | 15 | `ECRUTEAK_TIN_TOWER_ENTRANCE` | 3 |
| 5 | 17 | 3 | `ECRUTEAK_TIN_TOWER_BACK_ENTRANCE` | 3 |

Warps 3 and 4 are an in-map teleport pair: the map is one walled corridor drawn
in two halves, so the "trail" the walkthrough mentions is a warp, not a walk.

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_ECRUTEAKTINTOWERENTRANCE_SAGE_BLOCKS` (=0) | 4 | 7 | `EcruteakTinTowerEntranceSageBlocksLeft` (`52:400c`) | if `EVENT_ECRUTEAK_TIN_TOWER_ENTRANCE_SAGE_RIGHT` already set, no-op; else `applymovement SAGE2` one step LEFT, `moveobject SAGE1, 4, 6`, `appear SAGE1`, `disappear SAGE2` |
| `SCENE_ECRUTEAKTINTOWERENTRANCE_SAGE_BLOCKS` (=0) | 5 | 7 | `EcruteakTinTowerEntranceSageBlocksRight` (`52:4021`) | mirror image: `applymovement SAGE1` one step RIGHT, `moveobject SAGE2, 5, 6`, `appear SAGE2`, `disappear SAGE1` |

Scene ids are defined inline by the `def_scene_scripts` / `scene_script` macro
(`macros/scripts/maps.asm:12-35`), so `SAGE_BLOCKS` = 0 and `NOOP` = 1.

**BG events** (`def_bg_events`)

None.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ECRUTEAKTINTOWERENTRANCE_SAGE1` | `SPRITE_SAGE` | 4 | 6 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `EcruteakTinTowerEntranceSageScript` | `EVENT_ECRUTEAK_TIN_TOWER_ENTRANCE_SAGE_LEFT` |
| `ECRUTEAKTINTOWERENTRANCE_SAGE2` | `SPRITE_SAGE` | 5 | 6 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `EcruteakTinTowerEntranceSageScript` | `EVENT_ECRUTEAK_TIN_TOWER_ENTRANCE_SAGE_RIGHT` |
| `ECRUTEAKTINTOWERENTRANCE_SAGE3` | `SPRITE_SAGE` | 6 | 9 | `SPRITEMOVEDATA_WANDER` (radius 1,1) | `OBJECTTYPE_SCRIPT` | `EcruteakTinTowerEntranceWanderingSageScript` | -1 |
| `ECRUTEAKTINTOWERENTRANCE_GRAMPS` | `SPRITE_GRAMPS` | 3 | 11 | `SPRITEMOVEDATA_WANDER` (radius 1,1) | `OBJECTTYPE_SCRIPT` | `EcruteakTinTowerEntranceGrampsScript` | -1 |

Object visibility semantics (`engine/overworld/map_objects_2.asm:31 CheckObjectFlag`):
the object is masked (hidden) when its event flag is **set**, and `-1` means
"always appear".

**Scripts of interest**

- `EcruteakTinTowerEntranceSageScript` (`52:4037`): `faceplayer` / `opentext` /
  `checkflag ENGINE_FOGBADGE`. With the badge it prints
  `EcruteakTinTowerEntranceSageText_GotFogBadge` ("Please, go right through");
  without it, `EcruteakTinTowerEntranceSageText` ("TIN TOWER is off limits").
  Important: the sage script itself never opens the path. The physical block is
  the pair of sage objects standing on (4,6)/(5,6) plus the two coord events at
  y=7 that shuffle one of them into your lane.
- `EcruteakGymMortyScript` in `maps/EcruteakGym.asm:34` is what actually opens
  it: on receiving `ENGINE_FOGBADGE` it runs
  `setmapscene ECRUTEAK_TIN_TOWER_ENTRANCE, SCENE_ECRUTEAKTINTOWERENTRANCE_NOOP`,
  which retargets the coord events at (4,7)/(5,7) to a scene whose script is
  `end`. `EVENT_ECRUTEAK_TIN_TOWER_ENTRANCE_SAGE_LEFT` is additionally set at
  new-game init (`engine/events/std_scripts.asm:533`), so SAGE1 is hidden from
  the start and only SAGE2 exists until the coord events run.
- `EcruteakTinTowerEntranceWanderingSageScript`: `checkevent EVENT_GOT_RAINBOW_WING`
  swaps his line to "The TIN TOWER shook! A #MON must have returned to the top!"
  Pure flavour, useful as a bot assertion that the wing is in hand.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FOGBADGE` | `constants/engine_flags.asm:41` | read by `EcruteakTinTowerEntranceSageScript`; set by `maps/EcruteakGym.asm` | gates the sage dialogue and (via `setmapscene`) the blocking scene |
| `SCENE_ECRUTEAKTINTOWERENTRANCE_SAGE_BLOCKS` / `_NOOP` | inline in `maps/EcruteakTinTowerEntrance.asm:9-10` | `setmapscene` from Ecruteak Gym | 0 = sages step into your path, 1 = free passage |
| `EVENT_ECRUTEAK_TIN_TOWER_ENTRANCE_SAGE_LEFT` | `constants/event_flags.asm:1288` | set by `engine/events/std_scripts.asm:533`, read by `SageBlocksRight` | when set, SAGE1 is hidden |
| `EVENT_ECRUTEAK_TIN_TOWER_ENTRANCE_SAGE_RIGHT` | `constants/event_flags.asm:1289` | read by `SageBlocksLeft` | when set, SAGE2 is hidden |
| `EVENT_GOT_RAINBOW_WING` | `constants/event_flags.asm:129` | read here, set in `maps/RadioTower5F.asm:129` (Gold) / `maps/PewterCity.asm:50` (Silver) | wing possession |

**Items / Trainers / Wild encounters**

None on this map (no `def_grass_wildmons ECRUTEAK_TIN_TOWER_ENTRANCE` entry).

---

### MAP_ECRUTEAK_TIN_TOWER_BACK_ENTRANCE

- Script: `maps/EcruteakTinTowerBackEntrance.asm`
- Header: `data/maps/maps.asm:166` -> `TILESET_TRADITIONAL_HOUSE, INDOOR, LANDMARK_ECRUTEAK_CITY, MUSIC_ECRUTEAK_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:152` -> `map_const ECRUTEAK_TIN_TOWER_BACK_ENTRANCE, 4, 4`
- Connections: none (`data/maps/attributes.asm:496`)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 7 | 4 | `ECRUTEAK_CITY` | 4 |
| 2 | 7 | 5 | `ECRUTEAK_CITY` | 5 |
| 3 | 2 | 4 | `ECRUTEAK_TIN_TOWER_ENTRANCE` | 5 |

No coord events, bg events, object events, items, trainers or wild data.

---

### MAP_TIN_TOWER_1F

- Script: `maps/TinTower1F.asm` (sym `42:4b1b TinTower1F_MapScripts`, `42:4c6a TinTower1F_MapEvents`)
- Blocks: `maps/TinTower1F.blk`
- Header: `data/maps/maps.asm:82` -> `TILESET_TOWER, DUNGEON, LANDMARK_TIN_TOWER, MUSIC_TIN_TOWER, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:69` -> `map_const TIN_TOWER_1F, 10, 9`
- Connections: none (`data/maps/attributes.asm:401`)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 15 | `ECRUTEAK_CITY` | 12 |
| 2 | 10 | 15 | `ECRUTEAK_CITY` | 12 |
| 3 | 10 | 2 | `TIN_TOWER_2F` | 2 |

**Coord events / BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TINTOWER1F_SAGE` | `SPRITE_SAGE` | 10 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `TinTowerSageScript` (`42:4b1d`) | `EVENT_TEAM_ROCKET_DISBANDED` |

**Scripts of interest**

- `TinTowerSageScript` is only `jumptextfaceplayer TinTowerSageText` ("if I had
  what the #MON has... A RAINBOW WING!"). The gate is geometric, not scripted:
  the sage object sits exactly on warp 3 at (10,2), so while he is visible the
  stairs are unreachable. He is hidden the moment `EVENT_TEAM_ROCKET_DISBANDED`
  is set, which `maps/RadioTower5F.asm:130` does one opcode after
  `setevent EVENT_GOT_RAINBOW_WING`. That is the whole of the walkthrough's
  "another bald man will let you through because you have the Rainbow Wing".

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_TEAM_ROCKET_DISBANDED` | `constants/event_flags.asm:1283` | set by `maps/RadioTower5F.asm:130` (Gold) and `maps/PewterCity.asm:51` (Silver); read as the sage's object flag | while clear, the 1F stairs are body-blocked |

**Wild encounters**: none. `data/wild/johto_grass.asm` has no
`def_grass_wildmons TIN_TOWER_1F` (the block before `TIN_TOWER_2F` at line 61 is
`SPROUT_TOWER_3F`).

---

### MAP_TIN_TOWER_2F

- Script: `maps/TinTower2F.asm` (sym `42:4c8c`, events `42:4c8e`)
- Header: `data/maps/maps.asm:83` (same tileset/music/palette as 1F)
- Dimensions: `constants/map_constants.asm:70` -> `10, 9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 10 | 14 | `TIN_TOWER_3F` | 1 |
| 2 | 10 | 2 | `TIN_TOWER_1F` | 3 |

No coord events, bg events or object events.

**Wild encounters** (`data/wild/johto_grass.asm:61`, `def_grass_wildmons TIN_TOWER_2F`,
rates `2%/2%/2%` morn/day/nite):

| slot | morn | day | nite |
|---|---|---|---|
| 1 | L20 Rattata | L20 Rattata | L20 Gastly |
| 2 | L21 Rattata | L21 Rattata | L21 Gastly |
| 3 | L22 Rattata | L22 Rattata | L22 Gastly |
| 4 | L22 Rattata | L22 Rattata | L22 Rattata |
| 5 | L23 Rattata | L23 Rattata | L23 Rattata |
| 6 | L24 Rattata | L24 Rattata | L24 Rattata |
| 7 | L24 Rattata | L24 Rattata | L24 Rattata |

`TIN_TOWER_3F` through `TIN_TOWER_9F` (`data/wild/johto_grass.asm:89, 117, 145,
173, 201, 229, 257`) all repeat this identical table, so the whole tower is
Rattata by day and Rattata/Gastly at night at a 2% step rate. That is the
walkthrough's "zombies", and a Max Repel genuinely suppresses all of it (nothing
in the tower is above L24).

---

### MAP_TIN_TOWER_3F

- Script: `maps/TinTower3F.asm` (sym `42:4c9e`, events `42:4ca2`)
- Header: `data/maps/maps.asm:84`; Dimensions `constants/map_constants.asm:71` -> `10, 9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 10 | 14 | `TIN_TOWER_2F` | 1 |
| 2 | 16 | 2 | `TIN_TOWER_4F` | 2 |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TINTOWER3F_POKE_BALL` | `SPRITE_POKE_BALL` | 3 | 14 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `TinTower3FFullHeal` (`itemball FULL_HEAL`) | `EVENT_TIN_TOWER_3F_FULL_HEAL` |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `FULL_HEAL` | walk onto ball at (3,14) | `TinTower3FFullHeal` | `EVENT_TIN_TOWER_3F_FULL_HEAL` (`constants/event_flags.asm:1004`) |

---

### MAP_TIN_TOWER_4F

- Script: `maps/TinTower4F.asm` (sym `42:4cbf`, events `42:4cca`)
- Header: `data/maps/maps.asm:85`; Dimensions `constants/map_constants.asm:72` -> `10, 9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 4 | `TIN_TOWER_5F` | 2 |
| 2 | 16 | 2 | `TIN_TOWER_3F` | 2 |
| 3 | 2 | 14 | `TIN_TOWER_5F` | 3 |
| 4 | 17 | 15 | `TIN_TOWER_5F` | 4 |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 11 | 6 | `BGEVENT_ITEM` | `TinTower4FHiddenMaxPotion` (`42:4cc7`) -> `hiddenitem MAX_POTION, EVENT_TIN_TOWER_4F_HIDDEN_MAX_POTION` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TINTOWER4F_POKE_BALL1` | `SPRITE_POKE_BALL` | 14 | 10 | `STILL` | `ITEMBALL` | `TinTower4FUltraBall` (`itemball ULTRA_BALL`) | `EVENT_TIN_TOWER_4F_ULTRA_BALL` |
| `TINTOWER4F_POKE_BALL2` | `SPRITE_POKE_BALL` | 17 | 14 | `STILL` | `ITEMBALL` | `TinTower4FSuperPotion` (`itemball SUPER_POTION`) | `EVENT_TIN_TOWER_4F_SUPER_POTION` |
| `TINTOWER4F_POKE_BALL3` | `SPRITE_POKE_BALL` | 2 | 12 | `STILL` | `ITEMBALL` | `TinTower4FEscapeRope` (`itemball ESCAPE_ROPE`) | `EVENT_TIN_TOWER_4F_ESCAPE_ROPE` |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `ULTRA_BALL` | ball at (14,10) | `TinTower4FUltraBall` | `EVENT_TIN_TOWER_4F_ULTRA_BALL` (`event_flags.asm:1005`) |
| `SUPER_POTION` | ball at (17,14) | `TinTower4FSuperPotion` | `EVENT_TIN_TOWER_4F_SUPER_POTION` (`:1006`) |
| `ESCAPE_ROPE` | ball at (2,12) | `TinTower4FEscapeRope` | `EVENT_TIN_TOWER_4F_ESCAPE_ROPE` (`:1007`) |
| `MAX_POTION` | hidden, press A at (11,6) | bg_event -> `TinTower4FHiddenMaxPotion` | `EVENT_TIN_TOWER_4F_HIDDEN_MAX_POTION` (`:135`) |

---

### MAP_TIN_TOWER_5F

- Script: `maps/TinTower5F.asm` (sym `42:4d10`, events `42:4d1a`)
- Header: `data/maps/maps.asm:86`; Dimensions `constants/map_constants.asm:73` -> `10, 9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 11 | 15 | `TIN_TOWER_6F` | 2 |
| 2 | 2 | 4 | `TIN_TOWER_4F` | 1 |
| 3 | 2 | 14 | `TIN_TOWER_4F` | 3 |
| 4 | 17 | 15 | `TIN_TOWER_4F` | 4 |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 16 | 14 | `BGEVENT_ITEM` | `TinTower5FHiddenFullRestore` (`42:4d14`) -> `hiddenitem FULL_RESTORE, EVENT_TIN_TOWER_5F_HIDDEN_FULL_RESTORE` |
| 3 | 15 | `BGEVENT_ITEM` | `TinTower5FHiddenCarbos` (`42:4d17`) -> `hiddenitem CARBOS, EVENT_TIN_TOWER_5F_HIDDEN_CARBOS` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TINTOWER5F_POKE_BALL` | `SPRITE_POKE_BALL` | 9 | 9 | `STILL` | `ITEMBALL` | `TinTower5FRareCandy` (`itemball RARE_CANDY`) | `EVENT_TIN_TOWER_5F_RARE_CANDY` |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `RARE_CANDY` | ball at (9,9) | `TinTower5FRareCandy` | `EVENT_TIN_TOWER_5F_RARE_CANDY` (`:1008`) |
| `FULL_RESTORE` | hidden at (16,14) | bg_event | `EVENT_TIN_TOWER_5F_HIDDEN_FULL_RESTORE` (`:136`) |
| `CARBOS` | hidden at (3,15) | bg_event | `EVENT_TIN_TOWER_5F_HIDDEN_CARBOS` (`:137`) |

---

### MAP_TIN_TOWER_6F

- Script: `maps/TinTower6F.asm` (sym `42:4d4b`, events `42:4d4d`)
- Header: `data/maps/maps.asm:87`; Dimensions `constants/map_constants.asm:74` -> `10, 9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 9 | `TIN_TOWER_7F` | 1 |
| 2 | 11 | 15 | `TIN_TOWER_5F` | 1 |

No coord events, bg events or object events. In particular there is **no** item
on this floor, contrary to the walkthrough (see section 6).

---

### MAP_TIN_TOWER_7F

- Script: `maps/TinTower7F.asm` (sym `42:4d5d`, events `42:4d61`)
- Header: `data/maps/maps.asm:88`; Dimensions `constants/map_constants.asm:75` -> `10, 9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 9 | `TIN_TOWER_6F` | 1 |
| 2 | 10 | 15 | `TIN_TOWER_8F` | 1 |
| 3 | 12 | 7 | `TIN_TOWER_7F` | 4 |
| 4 | 8 | 3 | `TIN_TOWER_7F` | 3 |
| 5 | 6 | 9 | `TIN_TOWER_9F` | 5 |

Warps 3/4 are another in-map teleport pair (the walkthrough's "go through the
next two warps").

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TINTOWER7F_POKE_BALL` | `SPRITE_POKE_BALL` | 16 | 1 | `STILL` | `ITEMBALL` | `TinTower7FMaxRevive` (`itemball MAX_REVIVE`) | `EVENT_TIN_TOWER_7F_MAX_REVIVE` |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `MAX_REVIVE` | ball at (16,1) | `TinTower7FMaxRevive` | `EVENT_TIN_TOWER_7F_MAX_REVIVE` (`:1009`) |

---

### MAP_TIN_TOWER_8F

- Script: `maps/TinTower8F.asm` (sym `42:4d8d`, events `42:4d95`)
- Header: `data/maps/maps.asm:89`; Dimensions `constants/map_constants.asm:76` -> `10, 9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 5 | `TIN_TOWER_7F` | 2 |
| 2 | 2 | 11 | `TIN_TOWER_9F` | 1 |
| 3 | 16 | 7 | `TIN_TOWER_9F` | 2 |
| 4 | 10 | 3 | `TIN_TOWER_9F` | 3 |
| 5 | 14 | 15 | `TIN_TOWER_9F` | 6 |
| 6 | 6 | 9 | `TIN_TOWER_9F` | 7 |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TINTOWER8F_POKE_BALL1` | `SPRITE_POKE_BALL` | 7 | 13 | `STILL` | `ITEMBALL` | `TinTower8FNugget` (`itemball NUGGET`) | `EVENT_TIN_TOWER_8F_NUGGET` |
| `TINTOWER8F_POKE_BALL2` | `SPRITE_POKE_BALL` | 11 | 6 | `STILL` | `ITEMBALL` | `TinTower8FMaxElixer` (`itemball MAX_ELIXER`) | `EVENT_TIN_TOWER_8F_MAX_ELIXER` |
| `TINTOWER8F_POKE_BALL3` | `SPRITE_POKE_BALL` | 3 | 1 | `STILL` | `ITEMBALL` | `TinTower8FFullRestore` (`itemball FULL_RESTORE`) | `EVENT_TIN_TOWER_8F_FULL_RESTORE` |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `NUGGET` | ball at (7,13) | `TinTower8FNugget` | `EVENT_TIN_TOWER_8F_NUGGET` (`:1010`) |
| `MAX_ELIXER` | ball at (11,6) | `TinTower8FMaxElixer` | `EVENT_TIN_TOWER_8F_MAX_ELIXER` (`:1011`) |
| `FULL_RESTORE` | ball at (3,1) | `TinTower8FFullRestore` | `EVENT_TIN_TOWER_8F_FULL_RESTORE` (`:1012`) |

---

### MAP_TIN_TOWER_9F

- Script: `maps/TinTower9F.asm` (sym `42:4de0`, events `42:4e03`)
- Header: `data/maps/maps.asm:90`; Dimensions `constants/map_constants.asm:77` -> `10, 9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 12 | 3 | `TIN_TOWER_8F` | 2 |
| 2 | 2 | 5 | `TIN_TOWER_8F` | 3 |
| 3 | 12 | 7 | `TIN_TOWER_8F` | 4 |
| 4 | 7 | 9 | `TIN_TOWER_ROOF` | 1 |
| 5 | 16 | 7 | `TIN_TOWER_7F` | 5 |
| 6 | 6 | 13 | `TIN_TOWER_8F` | 5 |
| 7 | 8 | 13 | `TIN_TOWER_8F` | 6 |

No coord events, bg events or object events. The file carries two unreferenced
strings, `TinTower9FUnusedHoOhText` (`42:4de2`) and `TinTower9FUnusedLugiaText`
(`42:4df3`), leftovers from when the legendary stood on 9F.

---

### MAP_TIN_TOWER_ROOF

- Script: `maps/TinTowerRoof.asm` (sym `5b:68fa TinTowerRoof_MapScripts`, `5b:6945 TinTowerRoof_MapEvents`)
- Blocks: `maps/TinTowerRoof.blk` (sym `2b:62b9 TinTowerRoof_Blocks`)
- Header: `data/maps/maps.asm:344` -> `TILESET_TOWER, ROUTE, LANDMARK_TIN_TOWER, MUSIC_TIN_TOWER, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:318` -> `map_const TIN_TOWER_ROOF, 10, 9`.
  Note it lives in `newgroup FAST_SHIP` (group 15, map 12), **not** in the
  `newgroup DUNGEONS` block that holds `TIN_TOWER_1F..9F` (group 3, maps 4-12).
  A bot resolving map ids by group must not assume the roof follows 9F.
- Connections: none (`data/maps/attributes.asm:597`)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 13 | `TIN_TOWER_9F` | 4 |

**Coord events / BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TINTOWERROOF_HO_OH` | `SPRITE_HO_OH` | 9 | 5 | `SPRITEMOVEDATA_POKEMON`, palette `PAL_NPC_RED` | `OBJECTTYPE_SCRIPT` | `TinTowerHoOh` (`5b:6913`) | `EVENT_TIN_TOWER_ROOF_HO_OH` |

**Scripts of interest**

- `TinTowerRoofHoOhCallback` (`5b:68ff`), registered as
  `callback MAPCALLBACK_OBJECTS`:

  ```
  checkevent EVENT_FOUGHT_HO_OH
  iftrue .NoAppear
  checkitem RAINBOW_WING
  iftrue .Appear
  sjump .NoAppear
  ```

  So Ho-Oh spawns only while the `RAINBOW_WING` is **in the bag** and
  `EVENT_FOUGHT_HO_OH` is clear. A bot that stores the wing in the PC, or that
  has already triggered the encounter once, will find an empty roof.
- `TinTowerHoOh` (`5b:6913`): `faceplayer` / `opentext` / `writetext HoOhText`
  ("Shaoooh!") / `cry HO_OH` / `pause 15` / `closetext` /
  `setevent EVENT_FOUGHT_HO_OH` / `checkver` / `iftrue .Silver`.
  - Gold branch: `loadvar VAR_BATTLETYPE, BATTLETYPE_FORCEITEM`,
    `loadwildmon HO_OH, 40`, `startbattle`, `disappear TINTOWERROOF_HO_OH`,
    `reloadmapafterbattle`.
  - `.Silver` (`5b:6930`): identical but `loadwildmon HO_OH, 70`.

  Note that `setevent EVENT_FOUGHT_HO_OH` fires **before** the battle, so
  fleeing or blacking out still burns the encounter. This is exactly why the
  walkthrough insists on saving first: the only recovery is a reset.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_FOUGHT_HO_OH` | `constants/event_flags.asm:454` | read by the callback, set by `TinTowerHoOh` before `startbattle` | one-shot latch on the encounter |
| `EVENT_TIN_TOWER_ROOF_HO_OH` | `constants/event_flags.asm:1246` | the object's own visibility flag, toggled by `appear`/`disappear` in the callback | runtime spawn state |
| `RAINBOW_WING` (item, not a flag) | `constants/item_constants.asm` | `checkitem` in the callback | must be carried in the bag |
| `BATTLETYPE_FORCEITEM` | `constants/battle_constants.asm:101` | `loadvar VAR_BATTLETYPE`; consumed at `engine/battle/core.asm:5771` | guarantees Ho-Oh holds its `SACRED_ASH` |

**Battle data**

- `data/pokemon/base_stats/ho_oh.asm`: 106/130/90/90/110/154, FIRE/FLYING,
  **catch rate 3**, base exp 220, `db SACRED_ASH, SACRED_ASH ; items`,
  `GENDER_UNKNOWN`, `GROWTH_SLOW`.
- Level-up set (`data/pokemon/evos_attacks.asm:3324 HoOhEvosAttacks`):
  1 Sacred Fire, 11 Safeguard, 22 Gust, 33 Recover, 44 Fire Blast, 55 Sunny Day,
  66 Swift, 77 Whirlwind, 88 AncientPower, 99 Future Sight.
  A **level 40** Ho-Oh therefore knows **Sacred Fire, Safeguard, Gust, Recover**.
- Battle music: `engine/battle/start_battle.asm` has no legendary case, so this
  is `MUSIC_JOHTO_WILD_BATTLE` (or `..._NIGHT`). The music the walkthrough is
  praising is the map's own `MUSIC_TIN_TOWER`.

**Wild encounters**: none on the roof.

---

### MAP_ROUTE_41 (transit only)

- Script: `maps/Route41.asm`
- Header: `data/maps/maps.asm` (Route 41 row); attributes `data/maps/attributes.asm:227` -> border `$35`, `connection north, Route40, ROUTE_40, 15`, `connection west, CianwoodCity, CIANWOOD_CITY, 0`
- Dimensions: `constants/map_constants.asm:410` -> `map_const ROUTE_41, 25, 27`

**Warps** (`def_warp_events`) - the four island doors

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 12 | 17 | `WHIRL_ISLAND_NW` | 1 |
| 2 | 36 | 19 | `WHIRL_ISLAND_NE` | 1 |
| 3 | 12 | 37 | `WHIRL_ISLAND_SW` | 1 |
| 4 | 36 | 45 | `WHIRL_ISLAND_SE` | 1 |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 9 | 35 | `BGEVENT_ITEM` | `Route41HiddenMaxEther` -> `hiddenitem MAX_ETHER, EVENT_ROUTE_41_HIDDEN_MAX_ETHER` |

**Object events** (all `OBJECTTYPE_TRAINER`; sight range is the numeric column)

| const | sprite | x | y | movement | sight | script label |
|---|---|---|---|---|---|---|
| `ROUTE41_OLIVINE_RIVAL1` | `SPRITE_OLIVINE_RIVAL` | 32 | 6 | `SPINRANDOM_FAST` | 3 | `TrainerSwimmermCharlie` |
| `ROUTE41_OLIVINE_RIVAL2` | `SPRITE_OLIVINE_RIVAL` | 46 | 8 | `SPINRANDOM_FAST` | 3 | `TrainerSwimmermGeorge` |
| `ROUTE41_OLIVINE_RIVAL3` | `SPRITE_OLIVINE_RIVAL` | 20 | 26 | `SPINCOUNTERCLOCKWISE` | 3 | `TrainerSwimmermBerke` |
| `ROUTE41_OLIVINE_RIVAL4` | `SPRITE_OLIVINE_RIVAL` | 32 | 30 | `SPINCLOCKWISE` | 3 | `TrainerSwimmermKirk` |
| `ROUTE41_OLIVINE_RIVAL5` | `SPRITE_OLIVINE_RIVAL` | 19 | 46 | `SPINCOUNTERCLOCKWISE` | 3 | `TrainerSwimmermMathew` |
| `ROUTE41_SWIMMER_GIRL1` | `SPRITE_SWIMMER_GIRL` | 17 | 4 | `SPINRANDOM_FAST` | 3 | `TrainerSwimmerfKaylee` |
| `ROUTE41_SWIMMER_GIRL2` | `SPRITE_SWIMMER_GIRL` | 23 | 19 | `STANDING_UP` | 3 | `TrainerSwimmerfSusie` |
| `ROUTE41_SWIMMER_GIRL3` | `SPRITE_SWIMMER_GIRL` | 27 | 34 | `STANDING_LEFT` | 3 | `TrainerSwimmerfDenise` |
| `ROUTE41_SWIMMER_GIRL4` | `SPRITE_SWIMMER_GIRL` | 44 | 28 | `STANDING_RIGHT` | 4 | `TrainerSwimmerfKara` |
| `ROUTE41_SWIMMER_GIRL5` | `SPRITE_SWIMMER_GIRL` | 9 | 50 | `SPINRANDOM_FAST` | 2 | `TrainerSwimmerfWendy` |

**Trainers** (the one the walkthrough uses as a landmark)

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `SWIMMERF, KARA` | `SWIMMERF` (class 27, `constants/trainer_constants.asm:375`) | `KARA` (`:381`, 6th in class) | `SwimmerFGroup` entry 6 (`data/trainers/parties.asm:1811`): `TRAINERTYPE_NORMAL`, L20 STARYU, L20 STARMIE | `TrainerSwimmerfKara`, flag `EVENT_BEAT_SWIMMERF_KARA` | none |

"The whirlpool is just northwest of where you fought Swimmer Kara" therefore
means: northwest of Route 41 (44,28), i.e. the whirlpool guarding warp 2 at
(36,19) into `WHIRL_ISLAND_NE`.

**Wild encounters**: `data/wild/johto_water.asm:170` `def_water_wildmons ROUTE_41`,
6% encounter rate; Gold slots are L20 Tentacool / L20 Tentacruel / L20 Mantine
(Silver's third slot differs). Fish group is `FISHGROUP_WHIRL_ISLANDS` only
inside the islands, not on Route 41 itself.

---

### MAP_WHIRL_ISLAND_NE

- Script: `maps/WhirlIslandNE.asm` (sym `47:401c WhirlIslandNE_MapScripts`, `47:4020 WhirlIslandNE_MapEvents`)
- Blocks: `maps/WhirlIslandNE.blk`
- Header: `data/maps/maps.asm:137` -> `TILESET_DARK_CAVE, CAVE, LANDMARK_WHIRL_ISLANDS, MUSIC_UNION_CAVE, phone TRUE, PALETTE_DARK, FISHGROUP_WHIRL_ISLANDS`
- Dimensions: `constants/map_constants.asm:124` -> `map_const WHIRL_ISLAND_NE, 10, 9`
- Connections: none; border block `$09` (`data/maps/attributes.asm:456`)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 13 | `ROUTE_41` | 2 |
| 2 | 17 | 3 | `WHIRL_ISLAND_B1F` | 2 |
| 3 | 13 | 11 | `WHIRL_ISLAND_B1F` | 3 |

**Coord events / BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `WHIRLISLANDNE_POKE_BALL` | `SPRITE_POKE_BALL` | 11 | 11 | `STILL` | `ITEMBALL` | `WhirlIslandNEUltraBall` (`itemball ULTRA_BALL`) | `EVENT_WHIRL_ISLAND_NE_ULTRA_BALL` |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `ULTRA_BALL` | ball at (11,11) | `WhirlIslandNEUltraBall` | `EVENT_WHIRL_ISLAND_NE_ULTRA_BALL` (`event_flags.asm:1072`) |

**Wild encounters** (`data/wild/johto_grass.asm:1101`, 6%/6%/6%, identical morn/day/nite):
L22 Krabby, L23 Zubat, L24 Krabby, L22 Seel, L23 Golbat, L24 Seel, L24 Seel.
`WHIRL_ISLAND_NW` (`:1073`), `SW` (`:1129`), `CAVE` (`:1157`) and `SE` (`:1185`)
use the exact same table.

---

### MAP_WHIRL_ISLAND_NW

- Script: `maps/WhirlIslandNW.asm` (sym `47:4000`, events `47:4002`)
- Header: `data/maps/maps.asm:136` (same as NE)
- Dimensions: `constants/map_constants.asm:123` -> `5, 9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 7 | `ROUTE_41` | 1 |
| 2 | 5 | 3 | `WHIRL_ISLAND_B1F` | 1 |
| 3 | 3 | 15 | `WHIRL_ISLAND_SW` | 4 |
| 4 | 7 | 15 | `WHIRL_ISLAND_CAVE` | 2 |

No coord events, bg events, object events or items.

**Wild encounters**: `data/wild/johto_grass.asm:1073`, same L22-24
Krabby/Zubat/Seel/Golbat table as NE.

---

### MAP_WHIRL_ISLAND_CAVE

- Script: `maps/WhirlIslandCave.asm` (sym `47:4072`, events `47:4074`)
- Header: `data/maps/maps.asm:139`
- Dimensions: `constants/map_constants.asm:126` -> `5, 9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 7 | 5 | `WHIRL_ISLAND_B1F` | 9 |
| 2 | 3 | 13 | `WHIRL_ISLAND_NW` | 4 |

No coord events, bg events, object events or items. Wild table
`data/wild/johto_grass.asm:1157`, same as NE.

---

### MAP_WHIRL_ISLAND_SW

- Script: `maps/WhirlIslandSW.asm` (sym `47:4042`, events `47:4046`)
- Header: `data/maps/maps.asm:138`
- Dimensions: `constants/map_constants.asm:125` -> `10, 9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 7 | `ROUTE_41` | 3 |
| 2 | 17 | 3 | `WHIRL_ISLAND_B1F` | 5 |
| 3 | 3 | 3 | `WHIRL_ISLAND_B1F` | 4 |
| 4 | 3 | 15 | `WHIRL_ISLAND_NW` | 3 |
| 5 | 17 | 15 | `WHIRL_ISLAND_B2F` | 4 |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `WHIRLISLANDSW_POKE_BALL` | `SPRITE_POKE_BALL` | 15 | 2 | `STILL` | `ITEMBALL` | `WhirlIslandSWGuardSpec` (`itemball GUARD_SPEC`) | `EVENT_WHIRL_ISLAND_SW_GUARD_SPEC` |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `GUARD_SPEC` | ball at (15,2) | `WhirlIslandSWGuardSpec` | `EVENT_WHIRL_ISLAND_SW_GUARD_SPEC` (`:1073`) |

**Wild encounters**: grass `data/wild/johto_grass.asm:1129` (as NE); water
`data/wild/johto_water.asm:79` `def_water_wildmons WHIRL_ISLAND_SW`, 4% rate,
L20 Tentacool / L15 Horsea / L20 Tentacruel.

---

### MAP_WHIRL_ISLAND_SE

- Script: `maps/WhirlIslandSE.asm` (sym `47:4084`, events `47:4086`)
- Header: `data/maps/maps.asm:140`
- Dimensions: `constants/map_constants.asm:127` -> `5, 9`; border block `$0f`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 13 | `ROUTE_41` | 4 |
| 2 | 5 | 3 | `WHIRL_ISLAND_B1F` | 6 |

No coord events, bg events, object events or items. Wild table
`data/wild/johto_grass.asm:1185`, same as NE.

---

### MAP_WHIRL_ISLAND_B1F

- Script: `maps/WhirlIslandB1F.asm` (sym `47:4096 WhirlIslandB1F_MapScripts`, `47:40ae WhirlIslandB1F_MapEvents`)
- Blocks: `maps/WhirlIslandB1F.blk`
- Header: `data/maps/maps.asm:141` -> `TILESET_DARK_CAVE, CAVE, LANDMARK_WHIRL_ISLANDS, MUSIC_UNION_CAVE, TRUE, PALETTE_DARK, FISHGROUP_WHIRL_ISLANDS`
- Dimensions: `constants/map_constants.asm:128` -> `map_const WHIRL_ISLAND_B1F, 20, 18` (the big one)
- Connections: none; border block `$09`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 5 | `WHIRL_ISLAND_NW` | 2 |
| 2 | 35 | 3 | `WHIRL_ISLAND_NE` | 2 |
| 3 | 29 | 9 | `WHIRL_ISLAND_NE` | 3 |
| 4 | 9 | 31 | `WHIRL_ISLAND_SW` | 3 |
| 5 | 23 | 31 | `WHIRL_ISLAND_SW` | 2 |
| 6 | 31 | 29 | `WHIRL_ISLAND_SE` | 2 |
| 7 | 25 | 21 | `WHIRL_ISLAND_B2F` | 1 |
| 8 | 13 | 27 | `WHIRL_ISLAND_B2F` | 2 |
| 9 | 17 | 21 | `WHIRL_ISLAND_CAVE` | 1 |

**Coord events**: none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 30 | 4 | `BGEVENT_ITEM` | `WhirlIslandB1FHiddenRareCandy` (`47:40a5`) -> `hiddenitem RARE_CANDY, EVENT_WHIRL_ISLAND_B1F_HIDDEN_RARE_CANDY` |
| 36 | 18 | `BGEVENT_ITEM` | `WhirlIslandB1FHiddenUltraBall` (`47:40a8`) -> `hiddenitem ULTRA_BALL, EVENT_WHIRL_ISLAND_B1F_HIDDEN_ULTRA_BALL` |
| 2 | 23 | `BGEVENT_ITEM` | `WhirlIslandB1FHiddenFullRestore` (`47:40ab`) -> `hiddenitem FULL_RESTORE, EVENT_WHIRL_ISLAND_B1F_HIDDEN_FULL_RESTORE` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `WHIRLISLANDB1F_POKE_BALL1` | `SPRITE_POKE_BALL` | 7 | 13 | `STILL` | `ITEMBALL` | `WhirlIslandB1FFullRestore` | `EVENT_WHIRL_ISLAND_B1F_FULL_RESTORE` |
| `WHIRLISLANDB1F_POKE_BALL2` | `SPRITE_POKE_BALL` | 2 | 18 | `STILL` | `ITEMBALL` | `WhirlIslandB1FCarbos` | `EVENT_WHIRL_ISLAND_B1F_CARBOS` |
| `WHIRLISLANDB1F_POKE_BALL3` | `SPRITE_POKE_BALL` | 33 | 23 | `STILL` | `ITEMBALL` | `WhirlIslandB1FCalcium` | `EVENT_WHIRL_ISLAND_B1F_CALCIUM` |
| `WHIRLISLANDB1F_POKE_BALL4` | `SPRITE_POKE_BALL` | 17 | 8 | `STILL` | `ITEMBALL` | `WhirlIslandB1FNugget` | `EVENT_WHIRL_ISLAND_B1F_NUGGET` |
| `WHIRLISLANDB1F_POKE_BALL5` | `SPRITE_POKE_BALL` | 19 | 26 | `STILL` | `ITEMBALL` | `WhirlIslandB1FEscapeRope` | `EVENT_WHIRL_ISLAND_B1F_ESCAPE_ROPE` |
| `WHIRLISLANDB1F_BOULDER` | `SPRITE_BOULDER` | 23 | 26 | `SPRITEMOVEDATA_STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | `WhirlIslandB1FBoulder` (`47:40a2`, `jumpstd StrengthBoulderScript`) | -1 |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `FULL_RESTORE` | ball at (7,13) | `WhirlIslandB1FFullRestore` | `EVENT_WHIRL_ISLAND_B1F_FULL_RESTORE` (`:1074`) |
| `CARBOS` | ball at (2,18) | `WhirlIslandB1FCarbos` | `EVENT_WHIRL_ISLAND_B1F_CARBOS` (`:1075`) |
| `CALCIUM` | ball at (33,23) | `WhirlIslandB1FCalcium` | `EVENT_WHIRL_ISLAND_B1F_CALCIUM` (`:1076`) |
| `NUGGET` | ball at (17,8) | `WhirlIslandB1FNugget` | `EVENT_WHIRL_ISLAND_B1F_NUGGET` (`:1077`) |
| `ESCAPE_ROPE` | ball at (19,26) | `WhirlIslandB1FEscapeRope` | `EVENT_WHIRL_ISLAND_B1F_ESCAPE_ROPE` (`:1078`) |
| `RARE_CANDY` | hidden at (30,4) | bg_event | `EVENT_WHIRL_ISLAND_B1F_HIDDEN_RARE_CANDY` (`:161`) |
| `ULTRA_BALL` | hidden at (36,18) | bg_event | `EVENT_WHIRL_ISLAND_B1F_HIDDEN_ULTRA_BALL` (`:162`) |
| `FULL_RESTORE` | hidden at (2,23) | bg_event | `EVENT_WHIRL_ISLAND_B1F_HIDDEN_FULL_RESTORE` (`:163`) |

**Wild encounters**: `data/wild/johto_grass.asm:1213`, 6%: L23 Krabby, L24 Zubat,
L25 Krabby, L23 Seel, L24 Golbat, L25 Seel, L25 Seel (no morn/day/nite split).
No water table for B1F.

---

### MAP_WHIRL_ISLAND_B2F

- Script: `maps/WhirlIslandB2F.asm` (sym `47:413e WhirlIslandB2F_MapScripts`, `47:4146 WhirlIslandB2F_MapEvents`)
- Blocks: `maps/WhirlIslandB2F.blk`
- Header: `data/maps/maps.asm:142` (same as B1F)
- Dimensions: `constants/map_constants.asm:129` -> `map_const WHIRL_ISLAND_B2F, 10, 18`
- Connections: none; border block `$2e` (`data/maps/attributes.asm:461`)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 11 | 5 | `WHIRL_ISLAND_B1F` | 7 |
| 2 | 7 | 11 | `WHIRL_ISLAND_B1F` | 8 |
| 3 | 7 | 25 | `WHIRL_ISLAND_LUGIA_CHAMBER` | 1 |
| 4 | 13 | 31 | `WHIRL_ISLAND_SW` | 5 |

**Coord events / BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `WHIRLISLANDB2F_POKE_BALL1` | `SPRITE_POKE_BALL` | 10 | 11 | `STILL` | `ITEMBALL` | `WhirlIslandB2FFullRestore` | `EVENT_WHIRL_ISLAND_B2F_FULL_RESTORE` |
| `WHIRLISLANDB2F_POKE_BALL2` | `SPRITE_POKE_BALL` | 6 | 4 | `STILL` | `ITEMBALL` | `WhirlIslandB2FMaxRevive` | `EVENT_WHIRL_ISLAND_B2F_MAX_REVIVE` |
| `WHIRLISLANDB2F_POKE_BALL3` | `SPRITE_POKE_BALL` | 5 | 12 | `STILL` | `ITEMBALL` | `WhirlIslandB2FMaxElixer` | `EVENT_WHIRL_ISLAND_B2F_MAX_ELIXER` |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `FULL_RESTORE` | ball at (10,11) | `WhirlIslandB2FFullRestore` | `EVENT_WHIRL_ISLAND_B2F_FULL_RESTORE` (`:1079`) |
| `MAX_REVIVE` | ball at (6,4) | `WhirlIslandB2FMaxRevive` | `EVENT_WHIRL_ISLAND_B2F_MAX_REVIVE` (`:1080`) |
| `MAX_ELIXER` | ball at (5,12) | `WhirlIslandB2FMaxElixer` | `EVENT_WHIRL_ISLAND_B2F_MAX_ELIXER` (`:1081`) |

**Wild encounters**: grass `data/wild/johto_grass.asm:1241` (L23-25
Krabby/Zubat/Seel/Golbat, as B1F); water `data/wild/johto_water.asm:86`, 4%:
L15 Horsea / L20 Horsea / L20 Tentacruel.

The waterfall the walkthrough rides down is a `COLL_WATERFALL` ($33) tile in
`maps/WhirlIslandB2F.blk`, not a warp row: `engine/overworld/player_movement.asm`
`.CheckTile` / `.water_table` forces `DOWN` on that collision, so descending
needs no HM and no badge. Climbing back up does
(`WaterfallFunction.TryWaterfall`, `ENGINE_RISINGBADGE`).

---

### MAP_WHIRL_ISLAND_LUGIA_CHAMBER

- Script: `maps/WhirlIslandLugiaChamber.asm` (sym `47:4187 WhirlIslandLugiaChamber_MapScripts`, `47:41d1 WhirlIslandLugiaChamber_MapEvents`)
- Blocks: `maps/WhirlIslandLugiaChamber.blk` (sym `2b:717d WhirlIslandLugiaChamber_Blocks`)
- Header: `data/maps/maps.asm:143` -> `TILESET_DARK_CAVE, CAVE, LANDMARK_WHIRL_ISLANDS, MUSIC_UNION_CAVE, TRUE, PALETTE_DARK, FISHGROUP_WHIRL_ISLANDS`
- Dimensions: `constants/map_constants.asm:130` -> `map_const WHIRL_ISLAND_LUGIA_CHAMBER, 10, 9`
- Connections: none; border block `$0f`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 13 | `WHIRL_ISLAND_B2F` | 3 |

**Coord events / BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `WHIRLISLANDLUGIACHAMBER_LUGIA` | `SPRITE_LUGIA` | 9 | 5 | `SPRITEMOVEDATA_POKEMON`, palette `PAL_NPC_BLUE` | `OBJECTTYPE_SCRIPT` | `Lugia` (`47:41a0`) | `EVENT_WHIRL_ISLAND_LUGIA_CHAMBER_LUGIA` |

**Scripts of interest**

- `WhirlIslandLugiaChamberLugiaCallback` (`47:418c`), `callback MAPCALLBACK_OBJECTS`:
  `checkevent EVENT_FOUGHT_LUGIA` / `iftrue .NoAppear` / `checkitem SILVER_WING` /
  `iftrue .Appear` / `sjump .NoAppear`. Same shape as Ho-Oh's: the
  `SILVER_WING` must be in the bag.
- `Lugia` (`47:41a0`): `faceplayer` / `opentext` / `writetext LugiaText`
  ("Gyaaas!") / `cry LUGIA` / `pause 15` / `closetext` /
  `setevent EVENT_FOUGHT_LUGIA` / `checkver` / `iftrue .Silver`.
  - Gold branch: `BATTLETYPE_FORCEITEM`, `loadwildmon LUGIA, 70`.
  - `.Silver` branch: `BATTLETYPE_FORCEITEM`, `loadwildmon LUGIA, 40`.

  Note the level pairing is the inverse of Ho-Oh's: the legendary you meet
  *early* in your own version is level 40, the cross-version one is level 70.
  Again `setevent` precedes `startbattle`, so the encounter is spent the moment
  the text closes.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_FOUGHT_LUGIA` | `constants/event_flags.asm:455` | read by the callback, set by `Lugia` before `startbattle` | one-shot latch |
| `EVENT_WHIRL_ISLAND_LUGIA_CHAMBER_LUGIA` | `constants/event_flags.asm:1247` | object visibility, toggled by `appear`/`disappear` | runtime spawn state |
| `SILVER_WING` (item) | `constants/item_constants.asm` | `checkitem` in the callback | must be carried |
| `EVENT_GOT_SILVER_WING` | `constants/event_flags.asm:130` | set in `maps/RadioTower5F.asm:139` (Silver) / `maps/PewterCity.asm:34` (Gold) | wing acquisition |

**Battle data**

- `data/pokemon/base_stats/lugia.asm`: 106/90/130/110/90/154, PSYCHIC/FLYING,
  **catch rate 3**, base exp 220, `db NO_ITEM, NO_ITEM ; items` (so
  `BATTLETYPE_FORCEITEM` forces nothing here), `GENDER_UNKNOWN`, `GROWTH_SLOW`.
- Level-up set (`data/pokemon/evos_attacks.asm:3310 LugiaEvosAttacks`):
  1 Aeroblast, 11 Safeguard, 22 Gust, 33 Recover, 44 Hydro Pump, 55 Rain Dance,
  66 Swift, 77 Whirlwind, 88 AncientPower, 99 Future Sight.
  A **level 40** Lugia (Silver) knows **Aeroblast, Safeguard, Gust, Recover**.

**Wild encounters**: grass `data/wild/johto_grass.asm:1269`, 6%: L24 Krabby,
L25 Zubat, L26 Krabby, L24 Seel, L25 Golbat, L26 Seel, L26 Seel. Water
`data/wild/johto_water.asm:93`, 4%: L20 Horsea / L20 Tentacruel / L20 Seadra
(the Seadra the walkthrough lists).

**Fishing** (any Whirl Islands map, `FISHGROUP_WHIRL_ISLANDS`,
`data/wild/fish.asm:21` / `:162`):

| rod | slots |
|---|---|
| Old (`.WhirlIslands_Old`) | Magikarp L10 x2, Krabby L10 |
| Good (`.WhirlIslands_Good`) | Magikarp L20, Krabby L20 x2, `time_group 18` |
| Super (`.WhirlIslands_Super`) | Krabby L40, `time_group 19`, Kingler L40, Seadra L40 |

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Tin Tower path (Ecruteak entrance house) | `maps/EcruteakTinTowerEntrance.asm` coord events (4,7)/(5,7) under `SCENE_ECRUTEAKTINTOWERENTRANCE_SAGE_BLOCKS`; sage objects on (4,6)/(5,6) | Fog Badge | `maps/EcruteakGym.asm:34` runs `setmapscene ECRUTEAK_TIN_TOWER_ENTRANCE, SCENE_ECRUTEAKTINTOWERENTRANCE_NOOP` when `ENGINE_FOGBADGE` is granted |
| Tin Tower stairs (1F) | `maps/TinTower1F.asm:56` - the `TINTOWER1F_SAGE` object literally occupies warp 3 at (10,2) | `EVENT_TEAM_ROCKET_DISBANDED` clear = sage present | `maps/RadioTower5F.asm:130` sets it right after `verbosegiveitem RAINBOW_WING` |
| Ho-Oh spawn | `maps/TinTowerRoof.asm:TinTowerRoofHoOhCallback` | `RAINBOW_WING` in bag AND `EVENT_FOUGHT_HO_OH` clear | Gold: Radio Tower director. Silver: Pewter City gramps |
| Lugia spawn | `maps/WhirlIslandLugiaChamber.asm:WhirlIslandLugiaChamberLugiaCallback` | `SILVER_WING` in bag AND `EVENT_FOUGHT_LUGIA` clear | Silver: Radio Tower director. Gold: Pewter City gramps |
| Reaching Route 41 at all | `engine/events/overworld.asm:322 SurfFunction`, `.TrySurf` at `:339` (`ld de, ENGINE_FOGBADGE / call CheckBadge`); overworld path `:490` | SURF in party + `ENGINE_FOGBADGE` | beat Morty |
| Whirlpools around the islands | `engine/events/overworld.asm:1061 WhirlpoolFunction .TryWhirlpool` and `:1167 TryWhirlpoolOW` (`ld de, ENGINE_GLACIERBADGE / call CheckBadge` / `CheckEngineFlag`) | WHIRLPOOL in party + `ENGINE_GLACIERBADGE` (badge **7**, Pryce) | beat Pryce in Mahogany. Refusal line is `Script_MightyWhirlpool` |
| Darkness inside every Whirl Islands map | `engine/events/overworld.asm:271 FlashFunction .CheckUseFlash`: `ld de, ENGINE_ZEPHYRBADGE / farcall CheckBadge`, then `ld a, [wTimeOfDayPalset] / cp DARKNESS_PALSET` | FLASH in party + `ENGINE_ZEPHYRBADGE`; map header must be `PALETTE_DARK` (`data/maps/maps.asm:136-143`) | Falkner's badge. FLASH is refused outright on a lit map |
| Whirl Island B1F boulder | `maps/WhirlIslandB1F.asm:WhirlIslandB1FBoulder` -> `jumpstd StrengthBoulderScript` | STRENGTH usable | Olivine Cafe / Plain Badge chain (`ENGINE_PLAINBADGE`, `engine/events/overworld.asm:934 StrengthFunction`, badge check at `:941`) |
| Climbing back up the B2F waterfall | `engine/events/overworld.asm:611 WaterfallFunction .TryWaterfall` (`:618`) / `:683 TryWaterfallOW` (`:687`) (`ENGINE_RISINGBADGE`) | WATERFALL + badge 8 | Clair. Descending needs neither (`player_movement.asm` `.water_table` forces DOWN on `COLL_WATERFALL`) |

Nothing in this section gates on `VAR_BADGES` count, so "you'll need eight
badges for Whirlpool" is not what the code says (see section 6).

---

## 4. Bot checklist

Preconditions for the whole section: `ENGINE_FOGBADGE` set (Surf + Tin Tower
entrance), and for the Silver branch also `ENGINE_ZEPHYRBADGE` (Flash),
`ENGINE_GLACIERBADGE` (Whirlpool), `ENGINE_PLAINBADGE` (Strength). A party
member with SURF, one with FLASH, one with WHIRLPOOL, one with STRENGTH. Stock
about 30 `ULTRA_BALL` plus `REVIVE`/`HYPER_POTION`.

**Gold: Tin Tower / Ho-Oh**

| # | Map | Target | Intent | Precondition | Postcondition |
|---|---|---|---|---|---|
| 1 | `ECRUTEAK_CITY` | warp 3 (18,11) | walk | `ENGINE_FOGBADGE`, `EVENT_GOT_RAINBOW_WING` | in `ECRUTEAK_TIN_TOWER_ENTRANCE` |
| 2 | `ECRUTEAK_TIN_TOWER_ENTRANCE` | (4,7) or (5,7) | walk north | map scene == `_NOOP` (1) | no sage cutscene fires |
| 3 | same | warp 3 (5,3) | walk | - | teleported to (17,15) |
| 4 | same | warp 5 (17,3) | walk | - | in `ECRUTEAK_TIN_TOWER_BACK_ENTRANCE` |
| 5 | `ECRUTEAK_TIN_TOWER_BACK_ENTRANCE` | warp 1 (7,4) | walk south | - | back on `ECRUTEAK_CITY` at (20,2) |
| 6 | `ECRUTEAK_CITY` | warp 12 (37,7) | walk east | - | in `TIN_TOWER_1F` |
| 7 | `TIN_TOWER_1F` | warp 3 (10,2) | walk | `EVENT_TEAM_ROCKET_DISBANDED` set (sage gone) | `TIN_TOWER_2F` |
| 8 | `TIN_TOWER_2F` | warp 1 (10,14) | walk (Max Repel active) | - | `TIN_TOWER_3F` |
| 9 | `TIN_TOWER_3F` | ball (3,14) | walk onto | `EVENT_TIN_TOWER_3F_FULL_HEAL` clear | `FULL_HEAL`, flag set |
| 10 | `TIN_TOWER_3F` | warp 2 (16,2) | walk | - | `TIN_TOWER_4F` |
| 11 | `TIN_TOWER_4F` | balls (14,10), (17,14), (2,12); hidden (11,6) | walk on / press A | respective flags clear | `ULTRA_BALL`, `SUPER_POTION`, `ESCAPE_ROPE`, `MAX_POTION` |
| 12 | `TIN_TOWER_4F` | warp 1 (2,4) | walk | - | `TIN_TOWER_5F` |
| 13 | `TIN_TOWER_5F` | ball (9,9); hidden (16,14), (3,15) | walk on / press A | flags clear | `RARE_CANDY`, `FULL_RESTORE`, `CARBOS` |
| 14 | `TIN_TOWER_5F` | warp 1 (11,15) | walk | - | `TIN_TOWER_6F` |
| 15 | `TIN_TOWER_6F` | warp 1 (3,9) | walk | - | `TIN_TOWER_7F` |
| 16 | `TIN_TOWER_7F` | ball (16,1) | walk on | flag clear | `MAX_REVIVE` |
| 17 | `TIN_TOWER_7F` | warp 2 (10,15) | walk | - | `TIN_TOWER_8F` at (2,5) |
| 18 | `TIN_TOWER_8F` | balls (7,13), (11,6), (3,1) | walk on | flags clear | `NUGGET`, `MAX_ELIXER`, `FULL_RESTORE` |
| 19 | `TIN_TOWER_8F` | any of warps 2-6 | walk | - | `TIN_TOWER_9F` |
| 20 | `TIN_TOWER_9F` | warp 4 (7,9) | walk | - | `TIN_TOWER_ROOF` at (9,13) |
| 21 | `TIN_TOWER_ROOF` | - | **save** | - | restore point before the one-shot |
| 22 | `TIN_TOWER_ROOF` | `TINTOWERROOF_HO_OH` at (9,5) | talk (face north from (9,6)) | `RAINBOW_WING` in bag, `EVENT_FOUGHT_HO_OH` clear | `EVENT_FOUGHT_HO_OH` set, wild L40 Ho-Oh battle, holds `SACRED_ASH` |
| 23 | battle | throw `ULTRA_BALL` | weaken to red, prefer sleep/freeze | see catch math below | caught or reset to step 21 |
| 24 | `TIN_TOWER_ROOF` | `ESCAPE_ROPE` | use item | tileset is `TILESET_TOWER` | back outside |

**Silver: Whirl Islands / Lugia**

| # | Map | Target | Intent | Precondition | Postcondition |
|---|---|---|---|---|---|
| 1 | `OLIVINE_CITY` | - | fly | `ENGINE_FLYPOINT_OLIVINE` | at Olivine |
| 2 | `ROUTE_40`/`ROUTE_41` | south then west | surf | SURF + `ENGINE_FOGBADGE` | on Route 41 |
| 3 | `ROUTE_41` | whirlpool tile NW of (44,28) | press A -> `TryWhirlpoolOW` | WHIRLPOOL + `ENGINE_GLACIERBADGE` | whirlpool block replaced (`DisappearWhirlpool`) |
| 4 | `ROUTE_41` | warp 2 (36,19) | walk/surf onto | - | `WHIRL_ISLAND_NE` at (3,13) |
| 5 | `WHIRL_ISLAND_NE` | - | use FLASH | FLASH + `ENGINE_ZEPHYRBADGE`, map is `PALETTE_DARK` | cave lit |
| 6 | `WHIRL_ISLAND_NE` | ball (11,11) | walk on | flag clear | `ULTRA_BALL` |
| 7 | `WHIRL_ISLAND_NE` | warp 2 (17,3) or warp 3 (13,11) | walk | - | `WHIRL_ISLAND_B1F` at (35,3)/(29,9) |
| 8 | `WHIRL_ISLAND_B1F` | balls (17,8), (33,23), (19,26), (7,13), (2,18); hidden (30,4), (36,18), (2,23) | walk on / press A | flags clear | Nugget, Calcium, Escape Rope, Full Restore, Carbos, Rare Candy, Ultra Ball, Full Restore |
| 9 | `WHIRL_ISLAND_B1F` | boulder at (23,26) | push with STRENGTH | STRENGTH enabled | path opened |
| 10 | `WHIRL_ISLAND_SW` (via B1F warp 4/5) | ball (15,2) | walk on | flag clear | `GUARD_SPEC` |
| 11 | `WHIRL_ISLAND_B1F` | warp 8 (13,27) | walk | - | `WHIRL_ISLAND_B2F` at (7,11) |
| 12 | `WHIRL_ISLAND_B2F` | balls (6,4), (10,11), (5,12) | walk on | flags clear | `MAX_REVIVE`, `FULL_RESTORE`, `MAX_ELIXER` |
| 13 | `WHIRL_ISLAND_B2F` | surf south onto the `COLL_WATERFALL` tile | walk down | SURF only, no badge needed | carried to the lower pool |
| 14 | `WHIRL_ISLAND_B2F` | warp 3 (7,25) | walk | - | `WHIRL_ISLAND_LUGIA_CHAMBER` at (9,13) |
| 15 | `WHIRL_ISLAND_LUGIA_CHAMBER` | - | **save** | - | restore point |
| 16 | same | surf north to face `WHIRLISLANDLUGIACHAMBER_LUGIA` at (9,5) | talk | `SILVER_WING` in bag, `EVENT_FOUGHT_LUGIA` clear | `EVENT_FOUGHT_LUGIA` set, wild L40 Lugia battle |
| 17 | battle | throw `ULTRA_BALL` or `HEAVY_BALL` | weaken, prefer sleep/freeze | see catch math | caught or reset to step 15 |
| 18 | same | `ESCAPE_ROPE` | use item | `TILESET_DARK_CAVE` | back outside |

**Catch math a bot can plan against** (`engine/items/item_effects.asm PokeBallEffect`):

- Both legendaries have base catch rate 3.
- `UltraBallMultiplier` doubles it -> 6.
- Status bonus is added after the HP term, but only sleep and freeze actually
  apply: the `and` that tests for them leaves burn/poison/paralysis at 0
  (a documented cart bug the port reproduces, see
  `src/battle/gen2/Catching.lua`). So paralysis is worth nothing here; sleep or
  freeze is worth +10, which is larger than the entire ball-adjusted rate.
- `HeavyBallMultiplier` works off the Pokedex weight word, converted in-place to
  tenths of a kilogram. Lugia is `dw 1701, 4760` (476.0 lb -> 215.8 kg), which
  lands in the 204.8-307.2 kg bucket for **+20**, giving 23 versus the Ultra
  Ball's 6. Ho-Oh is `dw 1206, 4390` (439.0 lb -> 199.0 kg), which is above the
  102.4 kg light threshold but under 204.8 kg, so its bucket boost is **+0**:
  Heavy Ball leaves Ho-Oh at 3 and the Ultra Ball is strictly better.

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map headers / dimensions / warps / coord events / bg events / object events for every map here | `src/import/RomExtractorGen2.lua:804-862, :974` (generic per-map-group walk, `MAP_GROUP_COUNT = 26`) | implemented (data-driven, nothing map-specific needed) |
| `MAPCALLBACK_OBJECTS` (what spawns Ho-Oh / Lugia) | `src/world/gen2/World.lua:5694-5700`, `:5983` | implemented |
| `checkitem` / `appear` / `disappear` / `checkevent` used by both legendary callbacks | `src/script/gen2/Vm.lua:315, :323, :523`; `src/script/gen2/Opcodes.lua:0x21/0x6d/0x6e` | implemented |
| `checkver` version split (L40 vs L70) | `src/script/gen2/Vm.lua:774-778` (the comment there cites `WhirlIslandLugiaChamber` by name) | implemented |
| `loadwildmon` + `startbattle` legendary encounter | `src/script/gen2/Vm.lua:817, :836-856` | implemented |
| `BATTLETYPE_FORCEITEM` forcing Ho-Oh's `SACRED_ASH` | `src/world/gen2/World.lua:103-110, :4586` | implemented |
| `cry` / `pause` / `faceplayer` / `reloadmapafterbattle` in the encounter scripts | `src/script/gen2/Vm.lua:621, :886`; `src/script/gen2/Opcodes.lua:0x83, 0x8a, 0x6a, 0x5f` | implemented |
| Item balls (`OBJECTTYPE_ITEMBALL`) and hidden items (`BGEVENT_ITEM`) | `src/world/gen2/HiddenItems.lua`; `src/world/gen2/World.lua:1373, :5147-5280` | implemented |
| Whirlpool field move + `ENGINE_GLACIERBADGE` gate + block replacement | `src/world/gen2/FieldMoves.lua:109, :219, :247, :540-556, :626-641`; `src/world/gen2/Permissions.lua:129 isWhirlpool` | implemented |
| Flash + `ENGINE_ZEPHYRBADGE` + `PALETTE_DARK` / `DARKNESS_PALSET` | `src/world/gen2/FieldMoves.lua:105, :465-474`; `src/world/gen2/Palettes.lua:75-103` | implemented |
| Surf / Fly / Waterfall badge gates | `src/world/gen2/FieldMoves.lua:101-109` (`SURF = FOG`, `FLY = STORM`, `WATERFALL` via `World.lua:4219`) | implemented |
| Strength boulder (`jumpstd StrengthBoulderScript`, Whirl Island B1F) | `src/world/gen2/World.lua:4071-4088, :4234` | implemented |
| Scene scripts / `setmapscene` (the Ecruteak sage block) | `src/script/gen2/Opcodes.lua:0x12 setmapscene`; `src/world/gen2/World.lua:5013` (coord event scan) | implemented |
| **Forced-tile movement (`COLL_WATERFALL` riding down, `COLL_CURRENT_*`)** | no implementation found: `Permissions.lua:135` defines `isWaterfall` but nothing mirrors `player_movement.asm` `.CheckTile` / `.water_table`; a grep for `HI_NYBBLE_CURRENT` / forced direction over `src/world/gen2/*.lua` returns only `Bike.forcedDirection` | **missing** - the Whirl Island B2F waterfall descent to the Lugia Chamber has no forced-down step |
| **Apricorn ball multipliers (Heavy / Level / Lure / Fast / Moon / Love / Friend)** | `src/battle/gen2/Catching.lua:28-43` sets all of them to a flat `1`, with a comment that they "key off conditions the caller supplies"; no caller supplies them (grep for `HEAVY_BALL` outside that table finds nothing) | **missing** - the Heavy Ball advantage on Lugia is not reproduced, and the three documented ball bugs are not modelled either way |
| Ultra/Great ball multipliers and the two catch-rate cart bugs | `src/battle/gen2/Catching.lua:1-48, :60-80` | implemented (bugs deliberately preserved, `fixBugs` opt-out) |
| Headless driver for either legendary | `tests/drivers/gold_*.lua` has `gold_roamers.lua`, `gold_icepath_boulder.lua`, `gold_battle_smoke.lua` etc., but **no** Tin Tower or Whirl Islands driver | **missing** - nothing exercises the wing-in-bag callback path end to end |

---

## 6. Unresolved / verify by hand

1. **"You'll need eight badges in order to use Whirlpool."** The asm disagrees:
   `engine/events/overworld.asm:1077` (`WhirlpoolFunction.TryWhirlpool`) and
   `:1171` (`TryWhirlpoolOW`) both check `ENGINE_GLACIERBADGE`, which is badge 7
   (Pryce, Mahogany), not badge 8. Nothing reads `VAR_BADGES` for Whirlpool.
2. **Ho-Oh's moves.** The walkthrough says "Safeguard and Ancient Power (damage
   w/ stat boosts), Punishment, and Sacred Fire". `HoOhEvosAttacks`
   (`data/pokemon/evos_attacks.asm:3324`) gives a level 40 Ho-Oh
   **Sacred Fire, Safeguard, Gust, Recover**. AncientPower is learned at 88, and
   Punishment does not exist in Generation 2 (`constants/move_constants.asm` has
   no such constant). This reads like a Heart Gold / Soul Silver moveset.
3. **Tin Tower item list.** The walkthrough calls out a **PP Up** on the
   Ultra Ball floor, a **Max Potion then a Full Heal** on the bridge floor, and
   an **HP Up** near the end. The asm has, in those positions, `SUPER_POTION`
   (`TinTower4F.asm`, (17,14)), nothing at all on `TIN_TOWER_6F` (the file has an
   empty `def_object_events` and no bg events), and `NUGGET` / `FULL_RESTORE`
   on `TIN_TOWER_8F`. The `MAX_POTION` that does exist is the **hidden** item at
   (11,6) on 4F. No `PP_UP` or `HP_UP` appears in any `TinTower*.asm`. Treat the
   walkthrough's floor-by-floor item order as unreliable and use the tables in
   section 2.
4. **Whirl Islands item list.** The walkthrough lists "Max Revive x2"; the asm
   has exactly one `MAX_REVIVE`, on B2F at (6,4)
   (`EVENT_WHIRL_ISLAND_B2F_MAX_REVIVE`). It also omits the B1F Full Restore,
   Carbos and Nugget, the three B1F hidden items, and the B2F Full Restore and
   Max Elixer, all of which are real.
5. **Hop / ledge / bridge routing.** Every "jump left x5, down, right x2"
   instruction in the walkthrough is block-layout geometry that lives in the
   `.blk` files (`maps/TinTower4F.blk` .. `TinTower9F.blk`,
   `maps/WhirlIslandB1F.blk`, `WhirlIslandB2F.blk`), not in any asm text row. I
   did not decode the block data, so those step sequences are unverified. The
   warp tables in section 2 are the verified part; a bot should path to warp
   coordinates and let a collision-aware pathfinder handle the ledges.
6. **Whirlpool tile coordinates on Route 41.** "The whirlpool is just northwest
   of where you fought Swimmer Kara" could not be pinned to an asm row: the
   whirlpool tiles are `COLL_WHIRLPOOL` ($24) entries inside `maps/Route41.blk`,
   with no coordinate list anywhere in `maps/Route41.asm`. Kara's own position,
   (44,28), is verified.
7. **"The Ho-Oh in-game music."** There is no dedicated legendary battle theme in
   Gold/Silver: `engine/battle/start_battle.asm` selects
   `MUSIC_JOHTO_WILD_BATTLE` / `..._NIGHT` for a wild encounter and has no case
   for Ho-Oh or Lugia. The distinctive track is the map music
   `MUSIC_TIN_TOWER` (`data/maps/maps.asm:344`), which stops when the battle
   starts. Whirl Islands play `MUSIC_UNION_CAVE` (`:136-143`), so Lugia gets no
   special music at all.
8. **"About a 2% catch rate at low health."** I did not re-derive the shake
   check, only the rate formula; the numeric claim is unverified. The inputs are
   verified: base catch rate 3, Ultra Ball x2, sleep/freeze +10, and the two
   reproduced cart bugs in `PokeBallEffect`.
9. **Thard_Verad's Apriball note** checks out against the source, with one
   correction worth recording. `FastBallMultiplier`
   (`engine/items/item_effects.asm:986 FastBallMultiplier`) is documented in-file as buggy: it only
   matches the **first three** entries of `FleeMons`, which
   `data/wild/flee_mons.asm:4` shows are `MAGNEMITE`, `GRIMER`, `TANGELA` - so
   the correct species list is those three, and Raikou/Entei/Suicune (in
   `AlwaysFleeMons`) indeed get nothing. `LoveBallMultiplier` (`:921`) is
   commented "for the intended effect, this should be `ret z`", i.e. same gender
   rather than opposite. `MoonBallMultiplier` (`:875`) compares against
   `MOON_STONE_RED`, which is `BURN_HEAL` in Gen 2, so it never fires.
   `LevelBallMultiplier`, `LureBallMultiplier`, `HeavyBallMultiplier` and the
   Friend Ball happiness path (`:559`, `:622`) carry no bug comments.

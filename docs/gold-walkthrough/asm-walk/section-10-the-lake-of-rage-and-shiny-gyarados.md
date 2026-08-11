# Section 10 - The Lake of Rage and Shiny Gyarados

Source: `../section-10-the-lake-of-rage-and-shiny-gyarados.txt`
Maps covered: `MAP_ECRUTEAK_CITY` (fly-in only), `MAP_ROUTE_42_ECRUTEAK_GATE`,
`MAP_ROUTE_42`, `MAP_MAHOGANY_TOWN`, `MAP_MAHOGANY_MART_1F`,
`MAP_MAHOGANY_RED_GYARADOS_SPEECH_HOUSE`, `MAP_MAHOGANY_POKECENTER_1F`,
`MAP_ROUTE_43_MAHOGANY_GATE`, `MAP_ROUTE_43`, `MAP_ROUTE_43_GATE`,
`MAP_LAKE_OF_RAGE`, `MAP_LAKE_OF_RAGE_HIDDEN_POWER_HOUSE`,
`MAP_LAKE_OF_RAGE_MAGIKARP_HOUSE`

Badges / key milestones in this section: no badge. The milestones are
`ENGINE_FLYPOINT_MAHOGANY`, `ENGINE_FLYPOINT_LAKE_OF_RAGE`, catching or
defeating the Red Gyarados (`EVENT_LAKE_OF_RAGE_RED_GYARADOS`), the `RED_SCALE`,
and `EVENT_DECIDED_TO_HELP_LANCE`, which arms
`SCENE_MAHOGANYMART1F_LANCE_UNCOVERS_STAIRS` and opens the Team Rocket base in
the next section.

A note on coordinates: every table below is transcribed verbatim from the map's
`_MapEvents` block. `warp_event`, `coord_event`, `bg_event` and `object_event`
all use the same map coordinate space (the `object_event` macro in
`macros/scripts/maps.asm` adds the +4 border offset itself), so the numbers are
directly comparable. A map declared `map_const NAME, W, H` spans x in
`0 .. 2W-1` and y in `0 .. 2H-1`.

A note on the `event flag` column of `object_event`: `engine/overworld/map_objects_2.asm`
`CheckObjectFlag` masks (hides) the object when the flag is **set**, and `-1`
means always visible. So "set = gone".

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `MAP_ECRUTEAK_CITY` | `maps/EcruteakCity.asm` | Fly (`SPAWN_ECRUTEAK`, `data/maps/spawn_points.asm` `spawn ECRUTEAK_CITY, 23, 28`) | warp 1/2 at (35,26)/(35,27) -> `ROUTE_42_ECRUTEAK_GATE` 1/2 | "Fly to Ecruteak City, then head east onto Route 42" |
| 2 | `MAP_ROUTE_42_ECRUTEAK_GATE` | `maps/Route42EcruteakGate.asm` | warps 1/2 at (0,4)/(0,5) | warps 3/4 at (9,4)/(9,5) -> `ROUTE_42` 1/2 | gate hut between Ecruteak and Route 42 |
| 3 | `MAP_ROUTE_42` | `maps/Route42.asm` | warps 1/2 at (0,8)/(0,9) | east map connection -> `MAHOGANY_TOWN` | Ultra Ball, Surf the two lakes, Cut to the apricorn trees, Super Potion, three trainers |
| 4 | `MAP_MAHOGANY_TOWN` | `maps/MahoganyTown.asm` | west map connection from `ROUTE_42` | warp 5 at (9,1) -> `ROUTE_43_MAHOGANY_GATE` 3 | heal, Mahogany Mart, Red Gyarados speech house, blocked east exit |
| 5 | `MAP_ROUTE_43_MAHOGANY_GATE` | `maps/Route43MahoganyGate.asm` | warps 3/4 at (4,7)/(5,7) | warps 1/2 at (4,0)/(5,0) -> `ROUTE_43` 1/2 | gate hut north out of Mahogany |
| 6 | `MAP_ROUTE_43` | `maps/Route43.asm` | warps 1/2 at (9,51)/(10,51) | north map connection -> `LAKE_OF_RAGE` | five trainers, Max Ether, Bitter Berry tree, the Rocket toll gate you are told to walk around |
| 7 | `MAP_ROUTE_43_GATE` | `maps/Route43Gate.asm` | Route 43 warp 3 at (17,35) (southbound) or warps 4/5 at (17,31)/(18,31) (northbound) | mirrored warps | the 1000-yen Rocket shakedown the walkthrough tells you to skip |
| 8 | `MAP_LAKE_OF_RAGE` | `maps/LakeOfRage.asm` | south map connection from `ROUTE_43` | Fly out (`ENGINE_FLYPOINT_LAKE_OF_RAGE`) once Lance is talked to | Red Gyarados, Red Scale, Lance, Wesley of Wednesday, Max Ether, TM43 |
| 9 | `MAP_LAKE_OF_RAGE_HIDDEN_POWER_HOUSE` | `maps/LakeOfRageHiddenPowerHouse.asm` | Lake of Rage warp 1 at (7,3) | warps 1/2 at (2,7)/(3,7) | TM10 Hidden Power |
| 10 | `MAP_LAKE_OF_RAGE_MAGIKARP_HOUSE` | `maps/LakeOfRageMagikarpHouse.asm` | Lake of Rage warp 2 at (27,31) | warps 1/2 at (2,7)/(3,7) | Fishing Guru flavour; the Magikarp length contest only opens after `EVENT_CLEARED_ROCKET_HIDEOUT` |

Spill into the next section: after Lance is helped, `LakeOfRageLanceScript` does
`setmapscene MAHOGANY_MART_1F, SCENE_MAHOGANYMART1F_LANCE_UNCOVERS_STAIRS`, and
the walkthrough ends with "fly back to Mahogany Town". `MAP_MAHOGANY_MART_1F`'s
staircase scene, `MAP_TEAM_ROCKET_BASE_B1F..B3F` and `MAP_MAHOGANY_GYM` belong to
the next section; only the pieces of Mahogany Mart reachable *before* that are
documented here.

Also out of scope but named by the walkthrough: `maps/MrPokemonsHouse.asm`
`MrPokemonsHouse_MrPokemonScript.RedScale` is the `RED_SCALE` -> `EXP_SHARE`
trade (`checkitem RED_SCALE` / `verbosegiveitem EXP_SHARE` / `takeitem RED_SCALE`).
Mt. Mortar (`MOUNT_MORTAR_1F_OUTSIDE`, reached from Route 42 warps 3/4/5) is
explicitly deferred by the walkthrough.

---

## 2. Maps

### MAP_ECRUTEAK_CITY

Only the eastern exit matters here.

- Script: `maps/EcruteakCity.asm`
- Blocks: `maps/EcruteakCity.blk`
- Header: `data/maps/maps.asm:173` -> `map EcruteakCity, TILESET_JOHTO, TOWN, LANDMARK_ECRUTEAK_CITY, MUSIC_ECRUTEAK_CITY, FALSE, PALETTE_AUTO, FISHGROUP_POND`
- Dimensions: `constants/map_constants.asm:159` -> `map_const ECRUTEAK_CITY, 20, 18`
- Connections (`data/maps/attributes.asm:147`): south `ROUTE_37` (+5), west `ROUTE_38` (+5), east `ROUTE_42` (+9)
- Fly spawn: `data/maps/spawn_points.asm:35` -> `spawn ECRUTEAK_CITY, 23, 28`

**Warps** (the two this section uses, `maps/EcruteakCity.asm:229`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 35 | 26 | `ROUTE_42_ECRUTEAK_GATE` | 1 |
| 2 | 35 | 27 | `ROUTE_42_ECRUTEAK_GATE` | 2 |

---

### MAP_ROUTE_42_ECRUTEAK_GATE

- Script: `maps/Route42EcruteakGate.asm`
- Blocks: shared, `data/maps/blocks.asm` (no dedicated `.blk`)
- Header: `data/maps/maps.asm:71` -> `map Route42EcruteakGate, TILESET_GATE, GATE, LANDMARK_ROUTE_42, MUSIC_LAKE_OF_RAGE, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:59` -> `map_const ROUTE_42_ECRUTEAK_GATE, 5, 4`
- Connections: none (indoor gate)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 4 | `ECRUTEAK_CITY` | 1 |
| 2 | 0 | 5 | `ECRUTEAK_CITY` | 2 |
| 3 | 9 | 4 | `ROUTE_42` | 1 |
| 4 | 9 | 5 | `ROUTE_42` | 2 |

**Coord events** - none.
**BG events** - none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| (unnamed, index 2) | `SPRITE_OFFICER` | 5 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route42EcruteakGateOfficerScript` | -1 |

No gate check here: the officer is a `jumptextfaceplayer` only. This gate is
always open.

---

### MAP_ROUTE_42

- Script: `maps/Route42.asm` (symbol `Route42_MapEvents` = `4c:5e86`, `pokegold.sym:23813`)
- Blocks: `maps/Route42.blk`
- Header: `data/maps/maps.asm:72` -> `map Route42, TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_42, MUSIC_LAKE_OF_RAGE, FALSE, PALETTE_AUTO, FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:60` -> `map_const ROUTE_42, 30, 9` (x 0..59, y 0..17)
- Connections (`data/maps/attributes.asm:231`): west `ECRUTEAK_CITY` (-9), east `MAHOGANY_TOWN` (0)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 8 | `ROUTE_42_ECRUTEAK_GATE` | 3 |
| 2 | 0 | 9 | `ROUTE_42_ECRUTEAK_GATE` | 4 |
| 3 | 10 | 5 | `MOUNT_MORTAR_1F_OUTSIDE` | 1 |
| 4 | 28 | 9 | `MOUNT_MORTAR_1F_OUTSIDE` | 2 |
| 5 | 46 | 7 | `MOUNT_MORTAR_1F_OUTSIDE` | 3 |

**Coord events** - `def_coord_events` is empty. Nothing on Route 42 trips a scene.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 4 | 10 | `BGEVENT_READ` | `Route42Sign1` |
| 7 | 5 | `BGEVENT_READ` | `MtMortarSign1` |
| 45 | 9 | `BGEVENT_READ` | `MtMortarSign2` |
| 54 | 8 | `BGEVENT_READ` | `Route42Sign2` |
| 16 | 11 | `BGEVENT_ITEM` | `Route42HiddenMaxPotion` -> `hiddenitem MAX_POTION, EVENT_ROUTE_42_HIDDEN_MAX_POTION` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE42_FISHER` | `SPRITE_FISHER` | 40 | 10 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerFisherChris` | -1 |
| `ROUTE42_POKEFAN_M` | `SPRITE_POKEFAN_M` | 51 | 9 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerHikerBenjamin` | -1 |
| `ROUTE42_SUPER_NERD` | `SPRITE_SUPER_NERD` | 47 | 8 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerPokemaniacShane` | -1 |
| `ROUTE42_FRUIT_TREE1` | `SPRITE_FRUIT_TREE` | 27 | 16 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `Route42FruitTree1` -> `fruittree FRUITTREE_ROUTE_42_1` | -1 |
| `ROUTE42_FRUIT_TREE2` | `SPRITE_FRUIT_TREE` | 28 | 16 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `Route42FruitTree2` -> `fruittree FRUITTREE_ROUTE_42_2` | -1 |
| `ROUTE42_FRUIT_TREE3` | `SPRITE_FRUIT_TREE` | 29 | 16 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `Route42FruitTree3` -> `fruittree FRUITTREE_ROUTE_42_3` | -1 |
| `ROUTE42_POKE_BALL1` | `SPRITE_POKE_BALL` | 6 | 4 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `Route42UltraBall` -> `itemball ULTRA_BALL` | `EVENT_ROUTE_42_ULTRA_BALL` |
| `ROUTE42_POKE_BALL2` | `SPRITE_POKE_BALL` | 33 | 8 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `Route42SuperPotion` -> `itemball SUPER_POTION` | `EVENT_ROUTE_42_SUPER_POTION` |

**Scripts of interest**

- `TrainerFisherChris` - `trainer FISHER, CHRIS1, EVENT_BEAT_FISHER_CHRIS, ...`.
  After-battle branch is the standard phone-number ladder: `checkevent
  EVENT_CHRIS_READY_FOR_REMATCH` -> rematch; else `checkcellnum
  PHONE_FISHER_CHRIS`; else `setevent EVENT_CHRIS_ASKED_FOR_PHONE_NUMBER` and
  `askforphonenumber PHONE_FISHER_CHRIS`. The rematch arm picks `CHRIS2` if
  `EVENT_CLEARED_ROCKET_HIDEOUT` and `CHRIS3` if `EVENT_BEAT_ELITE_FOUR`; neither
  applies in this section.
- `TrainerPokemaniacShane`, `TrainerHikerBenjamin` - plain
  `endifjustbattled` / `writetext` / `end`, no flags beyond their
  `EVENT_BEAT_*`.
- `Route42UltraBall` / `Route42SuperPotion` - `itemball`; the one-time flag is
  the object's own event flag.
- `Route42HiddenMaxPotion` - `hiddenitem MAX_POTION, EVENT_ROUTE_42_HIDDEN_MAX_POTION`
  at (16,11). The walkthrough never mentions it.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ROUTE_42_ULTRA_BALL` | `constants/event_flags.asm:1108` | object row / `itemball` | set = ball at (6,4) already taken |
| `EVENT_ROUTE_42_SUPER_POTION` | `constants/event_flags.asm:1109` | object row / `itemball` | set = ball at (33,8) already taken |
| `EVENT_ROUTE_42_HIDDEN_MAX_POTION` | `constants/event_flags.asm:183` | `Route42HiddenMaxPotion` | set = hidden Max Potion consumed |
| `EVENT_BEAT_FISHER_CHRIS` | `constants/event_flags.asm:591` | `TrainerFisherChris` | set = Chris beaten |
| `EVENT_BEAT_POKEMANIAC_SHANE` | `constants/event_flags.asm:753` | `TrainerPokemaniacShane` | set = Shane beaten |
| `EVENT_BEAT_HIKER_BENJAMIN` | `constants/event_flags.asm:823` | `TrainerHikerBenjamin` | set = Benjamin beaten |
| `EVENT_CHRIS_ASKED_FOR_PHONE_NUMBER` / `EVENT_CHRIS_READY_FOR_REMATCH` | `constants/event_flags.asm` | `TrainerFisherChris.Script` | phone bookkeeping only |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `ULTRA_BALL` | item ball at (6,4) | `Route42UltraBall` | `EVENT_ROUTE_42_ULTRA_BALL` |
| `SUPER_POTION` | item ball at (33,8) | `Route42SuperPotion` | `EVENT_ROUTE_42_SUPER_POTION` |
| `MAX_POTION` | hidden at (16,11) | `bg_event 16, 11, BGEVENT_ITEM` | `EVENT_ROUTE_42_HIDDEN_MAX_POTION` |
| `PNK_APRICORN` | fruit tree (27,16) | `FRUITTREE_ROUTE_42_1`, `data/items/fruit_trees.asm:24` | daily reset, not an event flag |
| `GRN_APRICORN` | fruit tree (28,16) | `FRUITTREE_ROUTE_42_2`, `data/items/fruit_trees.asm:25` | daily reset |
| `YLW_APRICORN` | fruit tree (29,16) | `FRUITTREE_ROUTE_42_3`, `data/items/fruit_trees.asm:26` | daily reset |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `CHRIS1` | `FISHER` (0x25) | 7 | `FisherGroup` entry `; FISHER (7)` at `parties.asm:1537`: L18 `QWILFISH` | `TrainerFisherChris` | yes, `PHONE_FISHER_CHRIS`; `CHRIS2` (L23 Qwilfish) after `EVENT_CLEARED_ROCKET_HIDEOUT`, `CHRIS3` after `EVENT_BEAT_ELITE_FOUR` |
| `SHANE` | `POKEMANIAC` (0x1e) | 4 | `parties.asm:1097`: L16 `NIDORINA`, L16 `NIDORINO` | `TrainerPokemaniacShane` | no |
| `BENJAMIN` | `HIKER` (0x2c) | 6 | `parties.asm:2149`: L14 `DIGLETT`, L14 `GEODUDE`, L16 `DUGTRIO` | `TrainerHikerBenjamin` | no |

**Wild encounters**

`data/wild/johto_grass.asm:2125` `def_grass_wildmons ROUTE_42`, rates 10%/10%/10%
morn/day/nite. The table is `IF DEF(_GOLD)` / `ELIF DEF(_SILVER)` split, so the
walkthrough's "Mankey (Gold only)" is literally true:

| slot | morn (Gold) | day (Gold) | nite (Gold) |
|---|---|---|---|
| 1 | L15 `MANKEY` | L15 `MANKEY` | L15 `MANKEY` |
| 2 | L13 `MAREEP` | L13 `MAREEP` | L13 `MAREEP` |
| 3 | L14 `SPEAROW` | L14 `SPEAROW` | L14 `ZUBAT` |
| 4 | L16 `SPEAROW` | L16 `SPEAROW` | L16 `ZUBAT` |
| 5 | L15 `FLAAFFY` | L15 `FLAAFFY` | L15 `FLAAFFY` |
| 6 | L17 `FLAAFFY` | L17 `FLAAFFY` | L17 `FLAAFFY` |
| 7 | L17 `FLAAFFY` | L17 `FLAAFFY` | L17 `FLAAFFY` |

Silver swaps slot 1 `MANKEY` for L15 `MAREEP` and reorders; the rest is
identical.

Water (`data/wild/johto_water.asm:183`), 4% rate: L20 `GOLDEEN`, L15 `GOLDEEN`,
L20 `SEAKING`.

Fishing: header says `FISHGROUP_LAKE` -> `data/wild/fish.asm` `.Lake_Old`
(Magikarp/Magikarp/Goldeen L10), `.Lake_Good` (Magikarp/Goldeen/Goldeen L20 +
`time_group 4`), `.Lake_Super` (Goldeen L40 + `time_group 5` + Magikarp L40 +
Seaking L40).

Headbutt: `data/wild/treemon_maps.asm:23` -> `treemon_map ROUTE_42, TREEMON_SET_CANYON`.

Roamers: `data/wild/roammon_maps.asm:30` -> `roam_map ROUTE_42, ROUTE_43, ROUTE_44,
ROUTE_37, ROUTE_38`. A roaming beast can be on Route 42 or Route 43 while the
bot walks this section.

---

### MAP_MAHOGANY_TOWN

- Script: `maps/MahoganyTown.asm` (symbol `MahoganyTown_MapEvents` = `49:4e95`, `pokegold.sym:22738`)
- Blocks: `maps/MahoganyTown.blk`
- Header: `data/maps/maps.asm:74` -> `map MahoganyTown, TILESET_JOHTO, TOWN, LANDMARK_MAHOGANY_TOWN, MUSIC_CHERRYGROVE_CITY, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:62` -> `map_const MAHOGANY_TOWN, 10, 9` (x 0..19, y 0..17)
- Connections (`data/maps/attributes.asm:152`): north `ROUTE_43` (0), west `ROUTE_42` (0), east `ROUTE_44` (0)
- Fly spawn: `data/maps/spawn_points.asm:36` -> `spawn MAHOGANY_TOWN, 15, 14`
- Callback: `callback MAPCALLBACK_NEWMAP, MahoganyTownFlypointCallback` -> `setflag ENGINE_FLYPOINT_MAHOGANY`

**Scene scripts** (`def_scene_scripts`, ids assigned in order)

| id | constant | script |
|---|---|---|
| 0 | `SCENE_MAHOGANYTOWN_TRY_RAGECANDYBAR` | `MahoganyTownNoop1Scene` (`end`) |
| 1 | `SCENE_MAHOGANYTOWN_NOOP` | `MahoganyTownNoop2Scene` (`end`) |

Scene 0 is the new-game default and is what arms the two coord events below.
Only `RadioTowerRocketsScript` (`engine/events/std_scripts.asm:262`) ever moves
it to 1 - which is much later than this section.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 11 | 7 | `MAHOGANY_MART_1F` | 1 |
| 2 | 17 | 7 | `MAHOGANY_RED_GYARADOS_SPEECH_HOUSE` | 1 |
| 3 | 6 | 13 | `MAHOGANY_GYM` | 1 |
| 4 | 15 | 13 | `MAHOGANY_POKECENTER_1F` | 1 |
| 5 | 9 | 1 | `ROUTE_43_MAHOGANY_GATE` | 3 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_MAHOGANYTOWN_TRY_RAGECANDYBAR` | 19 | 8 | `MahoganyTownTryARageCandyBarScript` | RageCandyBar sales pitch, then you are shoved one step west |
| `SCENE_MAHOGANYTOWN_TRY_RAGECANDYBAR` | 19 | 9 | `MahoganyTownTryARageCandyBarScript` | same |

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 1 | 5 | `BGEVENT_READ` | `MahoganyTownSign` |
| 9 | 7 | `BGEVENT_READ` | `MahoganyTownRagecandybarSign` |
| 3 | 13 | `BGEVENT_READ` | `MahoganyGymSign` |
| 16 | 13 | `BGEVENT_READ` | `MahoganyTownPokecenterSign` (`jumpstd PokecenterSignScript`) |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MAHOGANYTOWN_POKEFAN_M` | `SPRITE_POKEFAN_M` | 19 | 8 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `MahoganyTownPokefanMScript` | `EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_EAST` |
| `MAHOGANYTOWN_GRAMPS` | `SPRITE_GRAMPS` | 6 | 9 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius x=1) | `OBJECTTYPE_SCRIPT` | `MahoganyTownGrampsScript` | -1 |
| `MAHOGANYTOWN_FISHER` | `SPRITE_FISHER` | 6 | 14 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `MahoganyTownFisherScript` | `EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_GYM` |
| `MAHOGANYTOWN_LASS` | `SPRITE_LASS` | 12 | 8 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `MahoganyTownLassScript` | `EVENT_MAHOGANY_MART_OWNERS` |

State during this section: `EVENT_MAHOGANY_MART_OWNERS` is **set** by
`InitializeEventsScript` (`engine/events/std_scripts.asm:501`), so the Lass at
(12,8) is not on the map yet - she only appears after
`maps/RadioTower5F.asm:107` / `maps/BlackthornGym1F.asm:53` clear it.
`EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_EAST` and
`EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_GYM` are **clear** at new game (nothing in
`InitializeEventsScript` sets them), so both the merchant at (19,8) and the
fisher at (6,14) are physically standing in the way.

**Scripts of interest**

- `MahoganyTownTryARageCandyBarScript` (symbol `49:4ac8`, `pokegold.sym:22705`) -
  `showemote EMOTE_SHOCK` on the merchant, `applymovement MAHOGANYTOWN_POKEFAN_M,
  MahoganyTownRageCandyBarMerchantBlocksYouMovement` (`step RIGHT`, `step DOWN`,
  `turn_head LEFT`), `follow PLAYER, MAHOGANYTOWN_POKEFAN_M`, `applymovement
  PLAYER, MahoganyTownPlayerStepLeftMovement` (`step LEFT`), `stopfollow`,
  `turnobject PLAYER, RIGHT`, `scall RageCandyBarMerchantScript`, then
  `MahoganyTownRageCandyBarMerchantReturnsMovement` (`step UP`, `turn_head
  DOWN`). It never calls `setscene`, so it fires **every** time the bot steps on
  (19,8)/(19,9). Buying does not unlock the east exit; only
  `RadioTowerRocketsScript`'s `setevent EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_EAST`
  + `setmapscene MAHOGANY_TOWN, SCENE_MAHOGANYTOWN_NOOP` does.
- `RageCandyBarMerchantScript` - `checkevent EVENT_CLEARED_ROCKET_HIDEOUT` ->
  "sold out"; otherwise `writetext RageCandyBarMerchantTryOneText`, `special
  PlaceMoneyTopRight`, `yesorno`, `checkmoney YOUR_MONEY,
  MAHOGANYTOWN_RAGECANDYBAR_PRICE`, `giveitem RAGECANDYBAR`, `takemoney
  YOUR_MONEY, 300`. `DEF MAHOGANYTOWN_RAGECANDYBAR_PRICE EQU 300` at
  `maps/MahoganyTown.asm:1`.
- `MahoganyTownGrampsScript` / `MahoganyTownFisherScript` - text only. The Gramps
  branches on `EVENT_CLEARED_ROCKET_HIDEOUT`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_MAHOGANY` | `constants/engine_flags.asm:87` | `MahoganyTownFlypointCallback` | set on first map load; Fly destination unlocked |
| `EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_EAST` | `constants/event_flags.asm:1272` | object row; set by `engine/events/std_scripts.asm:261` `RadioTowerRocketsScript` | clear = merchant stands at (19,8); the east exit to Route 44 is closed for this whole section |
| `EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_GYM` | `constants/event_flags.asm:1273` | object row; set by `maps/TeamRocketBaseB2F.asm:303` | clear = fisher at (6,14) blocks the Gym door at (6,13). Mahogany Gym is not enterable in this section |
| `EVENT_MAHOGANY_MART_OWNERS` | `constants/event_flags.asm:1240` | object rows; set at init, cleared in `RadioTower5F` / `BlackthornGym1F` | set = Lass and Mart Granny absent |
| `EVENT_CLEARED_ROCKET_HIDEOUT` | `constants/event_flags.asm:43` | read all over this section | clear for the whole of section 10 |
| `SCENE_MAHOGANYTOWN_TRY_RAGECANDYBAR` (=0) / `SCENE_MAHOGANYTOWN_NOOP` (=1) | exported by the `scene_script` macro in `macros/scripts/maps.asm` | `def_scene_scripts`, `setmapscene` | 0 for this section |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `RAGECANDYBAR` | bought for 300 from the merchant | `RageCandyBarMerchantScript.SellRageCandyBars` | none, repeatable until `EVENT_CLEARED_ROCKET_HIDEOUT` |

**Trainers** - none.

**Wild encounters** - none on the town map. `FISHGROUP_SHORE` per the header if
the bot fishes off the town's water.

---

### MAP_MAHOGANY_MART_1F (the "Grandma's shop" the walkthrough calls a house)

Only the pre-Lance state is in scope.

- Script: `maps/MahoganyMart1F.asm`
- Header: `data/maps/maps.asm:118` -> `map MahoganyMart1F, TILESET_TRADITIONAL_HOUSE, INDOOR, LANDMARK_MAHOGANY_TOWN, MUSIC_MAHOGANY_MART, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:105` -> `map_const MAHOGANY_MART_1F, 4, 4`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `MAHOGANY_TOWN` | 1 |
| 2 | 4 | 7 | `MAHOGANY_TOWN` | 1 |
| 3 | 7 | 3 | `TEAM_ROCKET_BASE_B1F` | 1 |

Warp 3 is the hidden staircase: `MahoganyMart1FStaircaseCallback`
(`MAPCALLBACK_TILES`) only does `changeblock 6, 2, $1e` once
`EVENT_UNCOVERED_STAIRCASE_IN_MAHOGANY_MART` is set, which is next section.

**Coord events** - none. **BG events** - none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MAHOGANYMART1F_PHARMACIST` | `SPRITE_PHARMACIST` | 4 | 3 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `MahoganyMart1FPharmacistScript` | `EVENT_TEAM_ROCKET_BASE_POPULATION` |
| `MAHOGANYMART1F_BLACK_BELT` | `SPRITE_BLACK_BELT` | 1 | 6 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `MahoganyMart1FBlackBeltScript` | `EVENT_TEAM_ROCKET_BASE_POPULATION` |
| `MAHOGANYMART1F_LANCE` | `SPRITE_LANCE` | 4 | 6 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_MAHOGANY_MART_LANCE_AND_DRAGONITE` |
| `MAHOGANYMART1F_DRAGONITE` | `SPRITE_DRAGON` | 3 | 6 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_MAHOGANY_MART_LANCE_AND_DRAGONITE` |
| `MAHOGANYMART1F_GRANNY` | `SPRITE_GRANNY` | 1 | 3 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `MahoganyMart1FGrannyScript` | `EVENT_MAHOGANY_MART_OWNERS` |

`EVENT_TEAM_ROCKET_BASE_POPULATION` is clear at new game, so the Pharmacist runs
`pokemart MARTTYPE_STANDARD, MART_MAHOGANY_1`. `MartMahogany1`
(`data/items/marts.asm:195`): `TINYMUSHROOM`, `SLOWPOKETAIL`, `POKE_BALL`,
`POTION`. `SLOWPOKETAIL`'s price is 9800 (`data/items/attributes.asm:215`,
`item_attribute 9800, HELD_NONE, ...`) - this is the walkthrough's "9800G
Slowpoketails". `EVENT_MAHOGANY_MART_LANCE_AND_DRAGONITE` is **set** by
`InitializeEventsScript`, so Lance and the Dragonite are not here yet;
`LakeOfRageLanceScript` clears it at the end of this section.

---

### MAP_MAHOGANY_RED_GYARADOS_SPEECH_HOUSE

- Script: `maps/MahoganyRedGyaradosSpeechHouse.asm`
- Header: `data/maps/maps.asm:68` -> `map MahoganyRedGyaradosSpeechHouse, TILESET_HOUSE, INDOOR, LANDMARK_MAHOGANY_TOWN, MUSIC_CHERRYGROVE_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:56` -> `map_const MAHOGANY_RED_GYARADOS_SPEECH_HOUSE, 4, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `MAHOGANY_TOWN` | 2 |
| 2 | 3 | 7 | `MAHOGANY_TOWN` | 2 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MAHOGANYREDGYARADOSSPEECHHOUSE_BLACK_BELT` | `SPRITE_BLACK_BELT` | 2 | 3 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `MahoganyRedGyaradosSpeechHouseBlackBeltScript` | -1 |
| `MAHOGANYREDGYARADOSSPEECHHOUSE_TEACHER` | `SPRITE_TEACHER` | 6 | 5 | `SPRITEMOVEDATA_WALK_UP_DOWN` (radius y=1) | `OBJECTTYPE_SCRIPT` | `MahoganyRedGyaradosSpeechHouseTeacherScript` | -1 |

Text only. The teacher branches on `checkflag ENGINE_ROCKETS_IN_RADIO_TOWER`.

---

### MAP_MAHOGANY_POKECENTER_1F

- Script: `maps/MahoganyPokecenter1F.asm`
- Header: `data/maps/maps.asm:70` -> `map MahoganyPokecenter1F, TILESET_POKECENTER, INDOOR, LANDMARK_MAHOGANY_TOWN, MUSIC_POKEMON_CENTER, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:58` -> `map_const MAHOGANY_POKECENTER_1F, 5, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `MAHOGANY_TOWN` | 4 |
| 2 | 4 | 7 | `MAHOGANY_TOWN` | 4 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| (index 2) | `SPRITE_NURSE` | 3 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `MahoganyPokecenter1FNurseScript` | -1 |
| (index 3) | `SPRITE_POKEFAN_M` | 7 | 2 | `SPRITEMOVEDATA_WANDER` (radius 1,1) | `OBJECTTYPE_SCRIPT` | `MahoganyPokecenter1FPokefanMScript` | -1 |
| (index 4) | `SPRITE_YOUNGSTER` | 1 | 3 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `MahoganyPokecenter1FYoungsterScript` | -1 |
| (index 5) | `SPRITE_COOLTRAINER_F` | 2 | 3 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `MahoganyPokecenter1FCooltrainerFScript` | -1 |

Heal target for a bot: talk to the nurse at (3,1) from (3,2).

---

### MAP_ROUTE_43_MAHOGANY_GATE

- Script: `maps/Route43MahoganyGate.asm`
- Header: `data/maps/maps.asm:239` -> `map Route43MahoganyGate, TILESET_GATE, GATE, LANDMARK_ROUTE_43, MUSIC_LAKE_OF_RAGE, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:219` -> `map_const ROUTE_43_MAHOGANY_GATE, 5, 4`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 0 | `ROUTE_43` | 1 |
| 2 | 5 | 0 | `ROUTE_43` | 2 |
| 3 | 4 | 7 | `MAHOGANY_TOWN` | 5 |
| 4 | 5 | 7 | `MAHOGANY_TOWN` | 5 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE43MAHOGANYGATE_OFFICER` | `SPRITE_OFFICER` | 0 | 4 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `Route43MahoganyGateOfficer` | -1 |

`Route43MahoganyGateOfficer` branches on `EVENT_CLEARED_ROCKET_HIDEOUT` for text
only. This gate never blocks.

---

### MAP_ROUTE_43

- Script: `maps/Route43.asm` (symbol `Route43_MapEvents` = `4d:4680`, `pokegold.sym:23879`)
- Blocks: `maps/Route43.blk`
- Header: `data/maps/maps.asm:241` -> `map Route43, TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_43, MUSIC_LAKE_OF_RAGE, FALSE, PALETTE_AUTO, FISHGROUP_POND`
- Dimensions: `constants/map_constants.asm:221` -> `map_const ROUTE_43, 10, 27` (x 0..19, y 0..53)
- Connections (`data/maps/attributes.asm:235`): north `LAKE_OF_RAGE` (-5), south `MAHOGANY_TOWN` (0)
- Callback: `callback MAPCALLBACK_NEWMAP, Route43CheckIfRocketsScene`

`Route43CheckIfRocketsScene`: `checkevent EVENT_CLEARED_ROCKET_HIDEOUT`; if
clear, `setmapscene ROUTE_43_GATE, SCENE_ROUTE43GATE_ROCKET_SHAKEDOWN`, else
`setmapscene ROUTE_43_GATE, SCENE_ROUTE43GATE_NOOP`. In this section the toll
scene is always armed.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 51 | `ROUTE_43_MAHOGANY_GATE` | 1 |
| 2 | 10 | 51 | `ROUTE_43_MAHOGANY_GATE` | 2 |
| 3 | 17 | 35 | `ROUTE_43_GATE` | 3 |
| 4 | 17 | 31 | `ROUTE_43_GATE` | 1 |
| 5 | 18 | 31 | `ROUTE_43_GATE` | 2 |

**Coord events** - `def_coord_events` is empty.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 13 | 3 | `BGEVENT_READ` | `Route43Sign1` |
| 11 | 49 | `BGEVENT_READ` | `Route43Sign2` |
| 16 | 38 | `BGEVENT_READ` | `Route43TrainerTips` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE43_SUPER_NERD1` | `SPRITE_SUPER_NERD` | 14 | 6 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerPokemaniacBen` | -1 |
| `ROUTE43_SUPER_NERD2` | `SPRITE_SUPER_NERD` | 13 | 20 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerPokemaniacBrent` | -1 |
| `ROUTE43_SUPER_NERD3` | `SPRITE_SUPER_NERD` | 13 | 7 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 2) | `TrainerPokemaniacRon` | -1 |
| `ROUTE43_FISHER` | `SPRITE_FISHER` | 4 | 16 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` (sight 4) | `TrainerFisherMarvin` | -1 |
| `ROUTE43_LASS` | `SPRITE_LASS` | 9 | 29 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerPicnickerTiffany` | -1 |
| `ROUTE43_YOUNGSTER` | `SPRITE_YOUNGSTER` | 15 | 43 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 5) | `TrainerCamperSpencer` | -1 |
| `ROUTE43_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 1 | 26 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `Route43FruitTree` -> `fruittree FRUITTREE_ROUTE_43` | -1 |
| `ROUTE43_POKE_BALL` | `SPRITE_POKE_BALL` | 12 | 32 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `Route43MaxEther` -> `itemball MAX_ETHER` | `EVENT_ROUTE_43_MAX_ETHER` |

Walking north from the Mahogany gate the y coordinates decrease, which gives the
walkthrough's order exactly: Spencer (y=43), Tiffany (y=29), Brent (y=20), Ron
(y=7), Ben (y=6). Marvin at (4,16) is the far-west detour.

**Scripts of interest**

- `TrainerPicnickerTiffany` - `trainer PICNICKER, TIFFANY3, EVENT_BEAT_PICNICKER_TIFFANY, ...`.
  Phone ladder on `PHONE_PICNICKER_TIFFANY`; rematch loads `TIFFANY1` after
  `EVENT_CLEARED_RADIO_TOWER` and `TIFFANY2` after `EVENT_BEAT_ELITE_FOUR`.
  Note the inversion: `TIFFANY3` (L20) is the *first* fight.
- `TrainerPokemaniacBrent` - `BRENT1` first; `BRENT2` after
  `EVENT_CLEARED_ROCKET_HIDEOUT`, `BRENT3` after `EVENT_BEAT_ELITE_FOUR`. Phone
  on `PHONE_POKEMANIAC_BRENT`.
- `TrainerCamperSpencer`, `TrainerPokemaniacBen`, `TrainerPokemaniacRon`,
  `TrainerFisherMarvin` - plain, no phone, no rematch.
- `Route43CheckIfRocketsScene` - the callback above; this is the only thing that
  arms the toll.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ROUTE_43_MAX_ETHER` | `constants/event_flags.asm:1110` | object row | set = ball at (12,32) taken |
| `EVENT_BEAT_CAMPER_SPENCER` | `constants/event_flags.asm:546` | `TrainerCamperSpencer` | |
| `EVENT_BEAT_PICNICKER_TIFFANY` | `constants/event_flags.asm:655` | `TrainerPicnickerTiffany` | |
| `EVENT_BEAT_POKEMANIAC_BRENT` | `constants/event_flags.asm:755` | `TrainerPokemaniacBrent` | |
| `EVENT_BEAT_POKEMANIAC_RON` | `constants/event_flags.asm:756` | `TrainerPokemaniacRon` | |
| `EVENT_BEAT_POKEMANIAC_BEN` | `constants/event_flags.asm:754` | `TrainerPokemaniacBen` | |
| `EVENT_BEAT_FISHER_MARVIN` | `constants/event_flags.asm:590` | `TrainerFisherMarvin` | |
| `EVENT_CLEARED_ROCKET_HIDEOUT` | `constants/event_flags.asm:43` | `Route43CheckIfRocketsScene` | clear here, so the gate toll is armed |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `MAX_ETHER` | item ball at (12,32) | `Route43MaxEther` | `EVENT_ROUTE_43_MAX_ETHER` |
| `BITTER_BERRY` | fruit tree at (1,26) | `FRUITTREE_ROUTE_43`, `data/items/fruit_trees.asm:11` | daily reset |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `SPENCER` | `CAMPER` (0x36) | 19 | `; CAMPER (19)` at `parties.asm:2817`: L17 `SANDSHREW`, L17 `SANDSLASH`, L19 `ZUBAT` | `TrainerCamperSpencer` | no |
| `TIFFANY3` | `PICNICKER` (0x35) | 20 | `; PICNICKER (20)` at `parties.asm:2693`, `TRAINERTYPE_MOVES`: L20 `CLEFAIRY` - `ENCORE`, `SING`, `DOUBLESLAP`, `MINIMIZE` | `TrainerPicnickerTiffany` | yes, `PHONE_PICNICKER_TIFFANY` |
| `BRENT1` | `POKEMANIAC` (0x1e) | 6 | `; POKEMANIAC (6)` at `parties.asm:1108`: L19 `LICKITUNG` | `TrainerPokemaniacBrent` | yes, `PHONE_POKEMANIAC_BRENT` |
| `RON` | `POKEMANIAC` | 7 | `parties.asm:1113`: L19 `NIDOKING` | `TrainerPokemaniacRon` | no |
| `BEN` | `POKEMANIAC` | 5 | `parties.asm:1103`: L19 `SLOWBRO` | `TrainerPokemaniacBen` | no |
| `MARVIN` | `FISHER` (0x25) | 6 | `; FISHER (6)` at `parties.asm:1529`: L10 `MAGIKARP`, L10 `GYARADOS`, L15 `MAGIKARP`, L15 `GYARADOS` | `TrainerFisherMarvin` | no |

**Wild encounters**

`data/wild/johto_grass.asm:2180` `def_grass_wildmons ROUTE_43`, rates 10%/10%/10%.
No version split.

| slot | morn | day | nite |
|---|---|---|---|
| 1 | L15 `FLAAFFY` | L15 `FLAAFFY` | L15 `FLAAFFY` |
| 2 | L15 `GIRAFARIG` | L15 `GIRAFARIG` | L15 `GIRAFARIG` |
| 3 | L17 `PIDGEOTTO` | L17 `PIDGEOTTO` | L17 `NOCTOWL` |
| 4 | L15 `MAREEP` | L15 `MAREEP` | L16 `VENONAT` |
| 5 | L16 `VENONAT` | L17 `FLAAFFY` | L15 `MAREEP` |
| 6 | L17 `PIDGEOTTO` | L17 `FLAAFFY` | L16 `VENONAT` |
| 7 | L17 `PIDGEOTTO` | L17 `FLAAFFY` | L16 `VENONAT` |

Water (`data/wild/johto_water.asm:190`), 2% rate: L20/L15/L10 `MAGIKARP`.
Fishing: `FISHGROUP_POND` -> `.Pond_Old` Magikarp/Magikarp/Poliwag L10,
`.Pond_Good` Magikarp/Poliwag/Poliwag L20 + `time_group 6`.
Headbutt: `data/wild/treemon_maps.asm:24` -> `TREEMON_SET_CANYON`.
Roamers: `data/wild/roammon_maps.asm:31` -> `roam_map ROUTE_43, ROUTE_42, ROUTE_44`.

---

### MAP_ROUTE_43_GATE (the Rocket toll booth)

- Script: `maps/Route43Gate.asm` (`Route43GateRocketTakeoverScript` = `53:5bb0`, `pokegold.sym:25377`)
- Blocks: shared, `data/maps/blocks.asm:206` `Route43Gate_Blocks`
- Header: `data/maps/maps.asm:240` -> `map Route43Gate, TILESET_GATE, GATE, LANDMARK_ROUTE_43, MUSIC_LAKE_OF_RAGE, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:220` -> `map_const ROUTE_43_GATE, 5, 4`
- Callback: `callback MAPCALLBACK_NEWMAP, Route43GateCheckIfRocketsCallback`

**Scene scripts**

| id | constant | script |
|---|---|---|
| 0 | `SCENE_ROUTE43GATE_ROCKET_SHAKEDOWN` | `Route43GateRocketShakedownScene` -> `sdefer Route43GateRocketTakeoverScript` |
| 1 | `SCENE_ROUTE43GATE_NOOP` | `Route43GateNoopScene` |

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 0 | `ROUTE_43` | 4 |
| 2 | 5 | 0 | `ROUTE_43` | 5 |
| 3 | 4 | 7 | `ROUTE_43` | 3 |
| 4 | 5 | 7 | `ROUTE_43` | 3 |

(Warp 4 also lands on Route 43 warp 3, not a separate one - transcribed as written.)

**Coord events** - none. **BG events** - none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE43GATE_OFFICER` | `SPRITE_OFFICER` | 0 | 4 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `OfficerScript_GuardWithSludgeBomb` | `EVENT_LAKE_OF_RAGE_CIVILIANS` |
| `ROUTE43GATE_ROCKET1` | `SPRITE_ROCKET` | 2 | 4 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `RocketScript_MakingABundle` | `EVENT_ROUTE_43_GATE_ROCKETS` |
| `ROUTE43GATE_ROCKET2` | `SPRITE_ROCKET` | 7 | 4 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `RocketScript_MakingABundle` | `EVENT_ROUTE_43_GATE_ROCKETS` |

`EVENT_LAKE_OF_RAGE_CIVILIANS` is **set** at new game
(`engine/events/std_scripts.asm:500`), so the officer with TM36 is **not here
during this section**; he only appears once `maps/TeamRocketBaseB2F.asm:305`
clears it. `EVENT_ROUTE_43_GATE_ROCKETS` is clear, so the two grunts are here;
`TeamRocketBaseB2F.asm:302` sets it later to remove them.

**Scripts of interest**

- `Route43GateRocketTakeoverScript` - `playmusic MUSIC_ROCKET_ENCOUNTER`,
  `readvar VAR_FACING`, `ifequal DOWN, RocketScript_Southbound`, `ifequal UP,
  RocketScript_Northbound`, otherwise `setscene SCENE_ROUTE43GATE_NOOP` and end.
- `RocketScript_Northbound` / `RocketScript_Southbound` - two grunts step in,
  `writetext RocketText_TollFee`, then `checkmoney YOUR_MONEY,
  ROUTE43GATE_TOLL - 1`; `HAVE_MORE` goes to `RocketScript_Toll*`, otherwise
  `RocketScript_YoureBroke*`. **Both arms run `takemoney YOUR_MONEY,
  ROUTE43GATE_TOLL`** - a bot with less than 1000 loses everything it has and
  still passes. `DEF ROUTE43GATE_TOLL EQU 1000` at `maps/Route43Gate.asm:1`.
  Both arms then `setscene SCENE_ROUTE43GATE_NOOP`, so the toll is charged once
  per `Route43CheckIfRocketsScene` re-arm (i.e. once per Route 43 map load).
- `OfficerScript_GuardWithSludgeBomb` - `verbosegiveitem TM_SLUDGE_BOMB` guarded
  by `EVENT_GOT_TM36_SLUDGE_BOMB`. Out of reach this section.

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `TM_SLUDGE_BOMB` (TM36) | talk to the officer | `OfficerScript_GuardWithSludgeBomb` | `EVENT_GOT_TM36_SLUDGE_BOMB` - **not obtainable in this section**, the officer is masked by `EVENT_LAKE_OF_RAGE_CIVILIANS` |

---

### MAP_LAKE_OF_RAGE

- Script: `maps/LakeOfRage.asm` (`LakeOfRage_MapEvents` = `49:5825`, `pokegold.sym:22807`; `LakeOfRageLanceScript` = `49:4f2e`; `RedGyarados` = `49:4f6f`; `WesleyScript` = `49:501a`)
- Blocks: `maps/LakeOfRage.blk`
- Header: `data/maps/maps.asm:242` -> `map LakeOfRage, TILESET_JOHTO, TOWN, LANDMARK_LAKE_OF_RAGE, MUSIC_LAKE_OF_RAGE, FALSE, PALETTE_AUTO, FISHGROUP_GYARADOS`
- Dimensions: `constants/map_constants.asm:222` -> `map_const LAKE_OF_RAGE, 20, 18` (x 0..39, y 0..35)
- Connections (`data/maps/attributes.asm:157`): south `ROUTE_43` (-5)
- Fly spawn: `data/maps/spawn_points.asm:37` -> `spawn LAKE_OF_RAGE, 21, 29`
- Callbacks: `MAPCALLBACK_NEWMAP` -> `LakeOfRageFlypointCallback` (`setflag
  ENGINE_FLYPOINT_LAKE_OF_RAGE`); `MAPCALLBACK_OBJECTS` -> `LakeOfRageWesleyCallback`

**Scene scripts** - `LakeOfRageNoop1Scene` / `LakeOfRageNoop2Scene`, both marked
`; unusable` in the source. Lake of Rage effectively has no scene variable;
`RedGyarados`'s `setscene 0` carries the comment saying so.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 7 | 3 | `LAKE_OF_RAGE_HIDDEN_POWER_HOUSE` | 1 |
| 2 | 27 | 31 | `LAKE_OF_RAGE_MAGIKARP_HOUSE` | 1 |

**Coord events** - `def_coord_events` is empty. Nothing here is a trip-wire; the
Gyarados and Lance are both talk-to objects.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 21 | 27 | `BGEVENT_READ` | `LakeOfRageSign` (this is the sign Lance is standing at) |
| 25 | 31 | `BGEVENT_READ` | `MagikarpHouseSignScript` |
| 11 | 28 | `BGEVENT_ITEM` | `LakeOfRageHiddenFullRestore` -> `hiddenitem FULL_RESTORE, EVENT_LAKE_OF_RAGE_HIDDEN_FULL_RESTORE` |
| 4 | 4 | `BGEVENT_ITEM` | `LakeOfRageHiddenRareCandy` -> `hiddenitem RARE_CANDY, EVENT_LAKE_OF_RAGE_HIDDEN_RARE_CANDY` |
| 35 | 5 | `BGEVENT_ITEM` | `LakeOfRageHiddenMaxPotion` -> `hiddenitem MAX_POTION, EVENT_LAKE_OF_RAGE_HIDDEN_MAX_POTION` |

The hidden Rare Candy at (4,4) is on the exact tile Wesley stands on
(`object_event 4, 4, SPRITE_SUPER_NERD ... WesleyScript`). On a Wednesday the NPC
is in the way of the Itemfinder tile.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `LAKEOFRAGE_LANCE` | `SPRITE_LANCE` | 21 | 28 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `LakeOfRageLanceScript` | `EVENT_LAKE_OF_RAGE_LANCE` |
| `LAKEOFRAGE_GRAMPS` | `SPRITE_GRAMPS` | 20 | 26 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `LakeOfRageGrampsScript` | -1 |
| `LAKEOFRAGE_SUPER_NERD1` | `SPRITE_SUPER_NERD` | 36 | 13 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `LakeOfRageSuperNerdScript` | -1 |
| `LAKEOFRAGE_COOLTRAINER_F1` | `SPRITE_COOLTRAINER_F` | 25 | 29 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius x=1) | `OBJECTTYPE_SCRIPT` | `LakeOfRageCooltrainerFScript` | -1 |
| `LAKEOFRAGE_FISHER1` | `SPRITE_FISHER` | 30 | 23 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerFisherAndre` | `EVENT_LAKE_OF_RAGE_CIVILIANS` |
| `LAKEOFRAGE_FISHER2` | `SPRITE_FISHER` | 24 | 26 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerFisherRaymond` | `EVENT_LAKE_OF_RAGE_CIVILIANS` |
| `LAKEOFRAGE_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 4 | 15 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerCooltrainermAaron` | `EVENT_LAKE_OF_RAGE_CIVILIANS` |
| `LAKEOFRAGE_COOLTRAINER_F2` | `SPRITE_COOLTRAINER_F` | 36 | 7 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 0) | `TrainerCooltrainerfLois` | `EVENT_LAKE_OF_RAGE_CIVILIANS` |
| `LAKEOFRAGE_GYARADOS` | `SPRITE_GYARADOS` | 18 | 22 | `SPRITEMOVEDATA_POKEMON` | `OBJECTTYPE_SCRIPT` | `RedGyarados` | `EVENT_LAKE_OF_RAGE_RED_GYARADOS` |
| `LAKEOFRAGE_WESLEY` | `SPRITE_SUPER_NERD` | 4 | 4 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `WesleyScript` | `EVENT_LAKE_OF_RAGE_WESLEY_OF_WEDNESDAY` |
| `LAKEOFRAGE_POKE_BALL1` | `SPRITE_POKE_BALL` | 7 | 10 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `LakeOfRageMaxEther` -> `itemball MAX_ETHER` | `EVENT_LAKE_OF_RAGE_MAX_ETHER` |
| `LAKEOFRAGE_POKE_BALL2` | `SPRITE_POKE_BALL` | 35 | 2 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `LakeOfRageTMDetect` -> `itemball TM_DETECT` | `EVENT_LAKE_OF_RAGE_TM_DETECT` |

Visibility during this section: `EVENT_LAKE_OF_RAGE_LANCE` is **set** at init
(`engine/events/std_scripts.asm:516`) so Lance is absent until the Gyarados
script's `appear LAKEOFRAGE_LANCE`. `EVENT_LAKE_OF_RAGE_CIVILIANS` is **set** at
init (`:500`), so **Andre, Raymond, Aaron and Lois are not on the map yet** -
they only turn up after the Rocket hideout. `EVENT_LAKE_OF_RAGE_RED_GYARADOS`
and `EVENT_LAKE_OF_RAGE_WESLEY_OF_WEDNESDAY` are clear at init, so the Gyarados
is present and Wesley is governed purely by the weekday callback.

**Scripts of interest**

- `LakeOfRageWesleyCallback` (`MAPCALLBACK_OBJECTS`) - `readvar VAR_WEEKDAY`,
  `ifequal WEDNESDAY, .WesleyAppears` -> `appear LAKEOFRAGE_WESLEY`; otherwise
  `disappear LAKEOFRAGE_WESLEY`.
- `RedGyarados` - the whole encounter:
  `opentext` / `writetext LakeOfRageGyaradosCryText` / `pause 15` /
  `cry GYARADOS` / `closetext`, then
  `loadwildmon GYARADOS, 30`,
  `loadvar VAR_BATTLETYPE, BATTLETYPE_FORCESHINY`,
  `startbattle`,
  `ifequal LOSE, .NotBeaten` (skip the disappear),
  `disappear LAKEOFRAGE_GYARADOS`,
  `reloadmapafterbattle`,
  `opentext` / **`giveitem RED_SCALE`** / `waitsfx` /
  `writetext LakeOfRageGotRedScaleText` / `playsound SFX_ITEM` / `waitsfx` /
  `itemnotify` / `closetext`,
  `setscene 0`, `appear LAKEOFRAGE_LANCE`, `end`.
  Two things a bot must know: the `giveitem RED_SCALE` has **no `iffalse`
  guard**, so a full bag silently eats the Red Scale; and the Red Scale and Lance
  arrive even on a loss, because the `.NotBeaten` label only skips the
  `disappear`.
- `LakeOfRageLanceScript` - `checkevent EVENT_REFUSED_TO_HELP_LANCE_AT_LAKE_OF_RAGE`
  -> `.AskAgainForHelp`. First pass: `writetext LakeOfRageLanceForcedToEvolveText`,
  `promptbutton`, `faceplayer`, `writetext LakeOfRageLanceIntroText`, `yesorno`.
  `iffalse .RefusedToHelp` -> `setevent EVENT_REFUSED_TO_HELP_LANCE_AT_LAKE_OF_RAGE`
  and stop. `.AgreedToHelp` ->
  `writetext LakeOfRageLanceRadioSignalText`, `playsound SFX_WARP_TO`,
  `applymovement LAKEOFRAGE_LANCE, LakeOfRageLanceTeleportIntoSkyMovement`
  (`teleport_from` = `$4c`, `macros/scripts/movement.asm:148`),
  `disappear LAKEOFRAGE_LANCE`,
  `clearevent EVENT_MAHOGANY_MART_LANCE_AND_DRAGONITE`,
  `setevent EVENT_DECIDED_TO_HELP_LANCE`,
  `setmapscene MAHOGANY_MART_1F, SCENE_MAHOGANYMART1F_LANCE_UNCOVERS_STAIRS`.
  **This is the section's terminal state change.** Saying no is recoverable - the
  `.AskAgainForHelp` arm re-asks.
- `WesleyScript` - `checkevent EVENT_GOT_BLACKBELT_FROM_WESLEY` ->
  `WesleyWednesdayScript`; `readvar VAR_WEEKDAY` / `ifnotequal WEDNESDAY` ->
  `WesleyNotWednesdayScript`; else `setevent EVENT_MET_WESLEY_OF_WEDNESDAY`,
  `verbosegiveitem BLACKBELT_I`, `iffalse WesleyDoneScript`, `setevent
  EVENT_GOT_BLACKBELT_FROM_WESLEY`. Guarded, so a full bag is safe here.
- `MagikarpHouseSignScript` - `writetext FishingGurusHouseSignText`, then
  `checkevent EVENT_CLEARED_ROCKET_HIDEOUT` -> `special MagikarpHouseSign`
  (the record board). Only text in this section.
- `LakeOfRageGrampsScript`, `LakeOfRageSuperNerdScript`,
  `LakeOfRageCooltrainerFScript` - the "something strange is going on" NPCs the
  walkthrough mentions; all branch on `EVENT_CLEARED_ROCKET_HIDEOUT` at most.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_LAKE_OF_RAGE` | `constants/engine_flags.asm:88` | `LakeOfRageFlypointCallback` | set on first entry |
| `EVENT_LAKE_OF_RAGE_RED_GYARADOS` | `constants/event_flags.asm:1267` | `RedGyarados` (`disappear`) | clear = the Gyarados object is on the water at (18,22) |
| `EVENT_LAKE_OF_RAGE_LANCE` | `constants/event_flags.asm:1142` | set by `InitializeEventsScript`; cleared by `RedGyarados`'s `appear`; set again by `LakeOfRageLanceScript`'s `disappear` | Lance is only talkable in the window between beating the Gyarados and agreeing to help |
| `EVENT_LAKE_OF_RAGE_CIVILIANS` | `constants/event_flags.asm:1239` | set at init; cleared in `maps/TeamRocketBaseB2F.asm:305` | set for this whole section: no Lake of Rage trainers |
| `EVENT_LAKE_OF_RAGE_WESLEY_OF_WEDNESDAY` | `constants/event_flags.asm:1278` | `LakeOfRageWesleyCallback` | driven by `VAR_WEEKDAY` on every map load |
| `EVENT_MET_WESLEY_OF_WEDNESDAY` | `constants/event_flags.asm:115` | `WesleyScript` | first-meeting text seen |
| `EVENT_GOT_BLACKBELT_FROM_WESLEY` | `constants/event_flags.asm:116` | `WesleyScript` | gift taken |
| `EVENT_REFUSED_TO_HELP_LANCE_AT_LAKE_OF_RAGE` | `constants/event_flags.asm:47` | `LakeOfRageLanceScript` | you said no; the re-ask arm |
| `EVENT_DECIDED_TO_HELP_LANCE` | `constants/event_flags.asm:105` | set by `LakeOfRageLanceScript`; read by `maps/MahoganyMart1F.asm:35,50` | **section complete** |
| `EVENT_MAHOGANY_MART_LANCE_AND_DRAGONITE` | `constants/event_flags.asm:1143` | set at init, cleared by `LakeOfRageLanceScript` | clear = Lance and Dragonite now stand in Mahogany Mart |
| `EVENT_LAKE_OF_RAGE_MAX_ETHER` | `constants/event_flags.asm:998` | object row | ball at (7,10) |
| `EVENT_LAKE_OF_RAGE_TM_DETECT` | `constants/event_flags.asm:999` | object row | ball at (35,2) |
| `EVENT_LAKE_OF_RAGE_HIDDEN_FULL_RESTORE` | `constants/event_flags.asm:191` | `LakeOfRageHiddenFullRestore` | hidden at (11,28) |
| `EVENT_LAKE_OF_RAGE_HIDDEN_RARE_CANDY` | `constants/event_flags.asm:192` | `LakeOfRageHiddenRareCandy` | hidden at (4,4) |
| `EVENT_LAKE_OF_RAGE_HIDDEN_MAX_POTION` | `constants/event_flags.asm:193` | `LakeOfRageHiddenMaxPotion` | hidden at (35,5) |
| `SCENE_MAHOGANYMART1F_LANCE_UNCOVERS_STAIRS` | `maps/MahoganyMart1F.asm` `def_scene_scripts` (id 1) | `setmapscene` in `LakeOfRageLanceScript` | arms the next section |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `RED_SCALE` | `giveitem` after the Gyarados battle | `RedGyarados` | none of its own; gated by `EVENT_LAKE_OF_RAGE_RED_GYARADOS` |
| `BLACKBELT_I` | Wesley, Wednesdays only | `WesleyScript` (`verbosegiveitem BLACKBELT_I`) | `EVENT_GOT_BLACKBELT_FROM_WESLEY` |
| `MAX_ETHER` | item ball at (7,10) | `LakeOfRageMaxEther` | `EVENT_LAKE_OF_RAGE_MAX_ETHER` |
| `TM_DETECT` (TM43) | item ball at (35,2) | `LakeOfRageTMDetect` | `EVENT_LAKE_OF_RAGE_TM_DETECT` |
| `FULL_RESTORE` | hidden at (11,28) | `bg_event 11, 28, BGEVENT_ITEM` | `EVENT_LAKE_OF_RAGE_HIDDEN_FULL_RESTORE` |
| `RARE_CANDY` | hidden at (4,4) | `bg_event 4, 4, BGEVENT_ITEM` | `EVENT_LAKE_OF_RAGE_HIDDEN_RARE_CANDY` |
| `MAX_POTION` | hidden at (35,5) | `bg_event 35, 5, BGEVENT_ITEM` | `EVENT_LAKE_OF_RAGE_HIDDEN_MAX_POTION` |

TM numbering, from the `add_tm` ladder in `constants/item_constants.asm:218-264`:
`TM_HIDDEN_POWER` is TM10 and `TM_DETECT` is TM43 (`__tmhm_value__` skips
`ITEM_C3` and `ITEM_DC`, which is why the item ids and TM numbers do not line up
one-for-one).

**Trainers** - none reachable in this section (all four are masked by
`EVENT_LAKE_OF_RAGE_CIVILIANS`). For completeness, once unmasked:
`FISHER ANDRE` (id 8, `parties.asm:1542`, L27 `GYARADOS`),
`FISHER RAYMOND` (id 9, `parties.asm:1547`, four L22 `MAGIKARP`),
`COOLTRAINERM AARON` (id 2, `parties.asm:749`, L24 `IVYSAUR`/`CHARMELEON`/`WARTORTLE`),
`COOLTRAINERF LOIS` (id 2, `parties.asm:875`, `TRAINERTYPE_MOVES`, L25 `SKIPLOOM`
and L25 `NINETALES`).

**Wild encounters**

There is **no** `def_grass_wildmons LAKE_OF_RAGE` entry in
`data/wild/johto_grass.asm` - the grass here is empty.

Water (`data/wild/johto_water.asm:253`): 4% in Gold, 6% in Silver;
L15 `MAGIKARP`, L10 `MAGIKARP`, L15 `GYARADOS`.

Fishing: header says `FISHGROUP_GYARADOS` -> `data/wild/fish.asm:132`
`.Gyarados_Old` / `.Gyarados_Good` / `.Gyarados_Super` are Magikarp in every
slot (the `time_group 14` / `time_group 15` slots aside). This is the "lake full
of Gyarados but nothing else" that Lance narrates.

Headbutt: `data/wild/treemon_maps.asm:37` -> `treemon_map LAKE_OF_RAGE, TREEMON_SET_FOREST`.

The Red Gyarados itself is **not** a wild-table roll: `loadwildmon GYARADOS, 30`
plus `BATTLETYPE_FORCESHINY`.

---

### MAP_LAKE_OF_RAGE_HIDDEN_POWER_HOUSE

- Script: `maps/LakeOfRageHiddenPowerHouse.asm` (`HiddenPowerGuy` = `53:54fd`, `pokegold.sym:25334`)
- Blocks: shared, `data/maps/blocks.asm:165`
- Header: `data/maps/maps.asm:237` -> `map LakeOfRageHiddenPowerHouse, TILESET_HOUSE, INDOOR, LANDMARK_LAKE_OF_RAGE, MUSIC_LAKE_OF_RAGE, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:217` -> `map_const LAKE_OF_RAGE_HIDDEN_POWER_HOUSE, 4, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `LAKE_OF_RAGE` | 1 |
| 2 | 3 | 7 | `LAKE_OF_RAGE` | 1 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `HiddenPowerHouseBookshelf` (`jumpstd DifficultBookshelfScript`) |
| 1 | 1 | `BGEVENT_READ` | `HiddenPowerHouseBookshelf` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `LAKEOFRAGEHIDDENPOWERHOUSE_FISHER` | `SPRITE_FISHER` | 2 | 3 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `HiddenPowerGuy` | -1 |

`HiddenPowerGuy`: `checkevent EVENT_GOT_TM10_HIDDEN_POWER` -> already-got text;
else `verbosegiveitem TM_HIDDEN_POWER`, `iffalse .Done`, `setevent
EVENT_GOT_TM10_HIDDEN_POWER`. Guarded, so a full bag is safe.

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `TM_HIDDEN_POWER` (TM10) | talk to the fisher at (2,3) | `HiddenPowerGuy` | `EVENT_GOT_TM10_HIDDEN_POWER` (`constants/event_flags.asm:97`) |

---

### MAP_LAKE_OF_RAGE_MAGIKARP_HOUSE

- Script: `maps/LakeOfRageMagikarpHouse.asm`
- Blocks: shared, `data/maps/blocks.asm:166`
- Header: `data/maps/maps.asm:238` -> `map LakeOfRageMagikarpHouse, TILESET_HOUSE, INDOOR, LANDMARK_LAKE_OF_RAGE, MUSIC_LAKE_OF_RAGE, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:218` -> `map_const LAKE_OF_RAGE_MAGIKARP_HOUSE, 4, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `LAKE_OF_RAGE` | 2 |
| 2 | 3 | 7 | `LAKE_OF_RAGE` | 2 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `MagikarpHouseBookshelf` |
| 1 | 1 | `BGEVENT_READ` | `MagikarpHouseBookshelf` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `LAKEOFRAGEMAGIKARPHOUSE_FISHING_GURU` | `SPRITE_FISHING_GURU` | 2 | 3 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `MagikarpLengthRaterScript` | -1 |

`MagikarpLengthRaterScript` in this section takes the
`EVENT_LAKE_OF_RAGE_EXPLAINED_WEIRD_MAGIKARP` path only: first talk sets that
flag and tells the lake's history, second talk gives the "men in black" line.
The measuring contest (`special CheckMagikarpLength`, `verbosegiveitem ETHER`)
sits behind `checkevent EVENT_CLEARED_ROCKET_HIDEOUT`, which is the next section
onwards.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Route 42's two lakes | `engine/events/overworld.asm:322` `SurfFunction` -> `.TrySurf`: `ld de, ENGINE_FOGBADGE` / `call CheckBadge` (`:50`), then `GetTilePermission` must be `WATER_TILE` | FOG BADGE + a party mon that knows SURF (`CheckPartyMove`, `:64`) | Morty, section 8 |
| The Route 42 cut trees in front of the apricorn trees | `engine/events/overworld.asm:117` `CutFunction` -> `.CheckAble`: `ld de, ENGINE_HIVEBADGE` / `CheckBadge`, then `CheckMapForSomethingToCut` | HIVE BADGE + a party mon that knows CUT | Bugsy, section 5. Tile positions are in `maps/Route42.blk`, not in any event table |
| Reaching the Red Gyarados at (18,22) | it is a water tile in the middle of `maps/LakeOfRage.blk`; no script gate | SURF | same as above |
| Mahogany east exit (to Route 44) | `maps/MahoganyTown.asm` `coord_event 19, 8` / `coord_event 19, 9` on `SCENE_MAHOGANYTOWN_TRY_RAGECANDYBAR`, plus the `MAHOGANYTOWN_POKEFAN_M` object at (19,8) with `EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_EAST` clear | none - it is unconditional | `engine/events/std_scripts.asm:261` `RadioTowerRocketsScript` (`setevent` + `setmapscene MAHOGANY_TOWN, SCENE_MAHOGANYTOWN_NOOP`). Far beyond this section. Buying a RageCandyBar does **not** help |
| Mahogany Gym door at (6,13) | `maps/MahoganyTown.asm` `object_event 6, 14, SPRITE_FISHER ... EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_GYM` (clear = NPC present, standing on the approach tile) | none | `maps/TeamRocketBaseB2F.asm:303` sets the flag after the hideout is cleared |
| Route 43 gate toll | `maps/Route43Gate.asm` scene 0 `Route43GateRocketShakedownScene` -> `sdefer Route43GateRocketTakeoverScript`, re-armed on every Route 43 load by `Route43CheckIfRocketsScene` | 1000 yen, or everything you have (`takemoney` runs in both branches) | not a hard gate - you always pass. `maps/TeamRocketBaseB2F.asm:302` removes the grunts permanently |
| Lance at (21,28) | `object_event ... EVENT_LAKE_OF_RAGE_LANCE`, set by `InitializeEventsScript` (`engine/events/std_scripts.asm:516`) | beat or catch the Red Gyarados | `RedGyarados`'s `appear LAKEOFRAGE_LANCE` |
| Wesley / `BLACKBELT_I` | `LakeOfRageWesleyCallback` (`MAPCALLBACK_OBJECTS`): `readvar VAR_WEEKDAY` / `ifequal WEDNESDAY` | the in-game day must be Wednesday | real clock; no in-game unlock |
| Lake of Rage trainers and the TM36 officer | `EVENT_LAKE_OF_RAGE_CIVILIANS`, set by `InitializeEventsScript:500` | - | `maps/TeamRocketBaseB2F.asm:305` `clearevent`. Not this section |
| Magikarp length contest / `ETHER` | `MagikarpLengthRaterScript`'s `checkevent EVENT_CLEARED_ROCKET_HIDEOUT` | Rocket hideout cleared | next section |
| Team Rocket base entrance | `MahoganyMart1FStaircaseCallback`'s `checkevent EVENT_UNCOVERED_STAIRCASE_IN_MAHOGANY_MART` -> `changeblock 6, 2, $1e` | Lance uncovers it | armed here by `setmapscene MAHOGANY_MART_1F, SCENE_MAHOGANYMART1F_LANCE_UNCOVERS_STAIRS` |

---

## 4. Bot checklist

Coordinates are map coordinates. "Talk" means face the tile and press A.

1. `MAP_ECRUTEAK_CITY` - Fly to `SPAWN_ECRUTEAK` (lands at 23,28).
   Pre: `ENGINE_FLYPOINT_ECRUTEAK`. Party must contain SURF and CUT users.
2. `MAP_ECRUTEAK_CITY` - walk to warp 1 (35,26) or 2 (35,27). Post: on
   `MAP_ROUTE_42_ECRUTEAK_GATE`.
3. `MAP_ROUTE_42_ECRUTEAK_GATE` - walk east to warp 3 (9,4) / 4 (9,5). Post: on
   `MAP_ROUTE_42` at (0,8)/(0,9).
4. `MAP_ROUTE_42` - walk to (6,4), talk to `ROUTE42_POKE_BALL1`.
   Pre: `EVENT_ROUTE_42_ULTRA_BALL` clear. Post: it is set, `ULTRA_BALL` in bag.
5. `MAP_ROUTE_42` - do **not** enter warps 3/4/5 (Mt. Mortar); the walkthrough
   defers them to the Waterfall trip.
6. `MAP_ROUTE_42` - use SURF to cross the first lake (badge: `ENGINE_FOGBADGE`).
7. `MAP_ROUTE_42` - use CUT on the tree(s) south of the lake (badge:
   `ENGINE_HIVEBADGE`), then talk to the fruit trees at (27,16), (28,16),
   (29,16). Post: `PNK_APRICORN`, `GRN_APRICORN`, `YLW_APRICORN`; each tree is
   bare until the next daily reset.
8. `MAP_ROUTE_42` - optional: Itemfinder / step on (16,11) for the hidden
   `MAX_POTION`. Post: `EVENT_ROUTE_42_HIDDEN_MAX_POTION`.
9. `MAP_ROUTE_42` - walk to (33,8), talk to `ROUTE42_POKE_BALL2`.
   Post: `EVENT_ROUTE_42_SUPER_POTION`, `SUPER_POTION` in bag.
10. `MAP_ROUTE_42` - SURF the second lake, then battle `ROUTE42_FISHER` at
    (40,10) (`FISHER CHRIS1`, L18 Qwilfish). Post: `EVENT_BEAT_FISHER_CHRIS`;
    optionally accept `PHONE_FISHER_CHRIS`.
11. `MAP_ROUTE_42` - battle `ROUTE42_SUPER_NERD` at (47,8) (`POKEMANIAC SHANE`).
    Post: `EVENT_BEAT_POKEMANIAC_SHANE`.
12. `MAP_ROUTE_42` - battle `ROUTE42_POKEFAN_M` at (51,9) (`HIKER BENJAMIN`).
    Post: `EVENT_BEAT_HIKER_BENJAMIN`.
13. `MAP_ROUTE_42` - walk east off the map edge (x > 59) into
    `MAP_MAHOGANY_TOWN`. Post: `ENGINE_FLYPOINT_MAHOGANY` set by
    `MahoganyTownFlypointCallback`.
14. `MAP_MAHOGANY_TOWN` - warp 4 (15,13) -> Pokecenter; talk to the nurse at
    (3,1) from (3,2); leave by warp 1/2.
15. `MAP_MAHOGANY_TOWN` - optional flavour: warp 1 (11,7) -> Mahogany Mart, talk
    to `MAHOGANYMART1F_PHARMACIST` at (4,3) for `MART_MAHOGANY_1` (the 9800-yen
    `SLOWPOKETAIL`). Warp 2 (17,7) -> Red Gyarados speech house.
16. `MAP_MAHOGANY_TOWN` - **avoid** (19,8) and (19,9) unless you want the
    RageCandyBar scene; it costs 300 and never opens the east exit. Do not try
    the Gym at (6,13): `MAHOGANYTOWN_FISHER` at (6,14) is in the way.
17. `MAP_MAHOGANY_TOWN` - walk to warp 5 (9,1). Post: on
    `MAP_ROUTE_43_MAHOGANY_GATE` at (4,7)/(5,7).
18. `MAP_ROUTE_43_MAHOGANY_GATE` - walk north to warp 1 (4,0) / 2 (5,0). Post:
    on `MAP_ROUTE_43` at (9,51)/(10,51). Loading Route 43 runs
    `Route43CheckIfRocketsScene`, which arms `SCENE_ROUTE43GATE_ROCKET_SHAKEDOWN`.
19. `MAP_ROUTE_43` - battle `ROUTE43_YOUNGSTER` at (15,43) (`CAMPER SPENCER`).
    Post: `EVENT_BEAT_CAMPER_SPENCER`.
20. `MAP_ROUTE_43` - do **not** enter warp 3 (17,35) or warps 4/5
    (17,31)/(18,31): those are the toll booth. Take the west/grass path instead.
21. `MAP_ROUTE_43` - optional: talk to the fruit tree at (1,26) for
    `BITTER_BERRY`; battle `ROUTE43_FISHER` at (4,16) (`FISHER MARVIN`). Post:
    `EVENT_BEAT_FISHER_MARVIN`.
22. `MAP_ROUTE_43` - battle `ROUTE43_LASS` at (9,29) (`PICNICKER TIFFANY3`, L20
    Clefairy). Post: `EVENT_BEAT_PICNICKER_TIFFANY`; optional phone.
23. `MAP_ROUTE_43` - talk to `ROUTE43_POKE_BALL` at (12,32). Post:
    `EVENT_ROUTE_43_MAX_ETHER`, `MAX_ETHER` in bag.
24. `MAP_ROUTE_43` - battle `ROUTE43_SUPER_NERD2` at (13,20) (`POKEMANIAC
    BRENT1`). Post: `EVENT_BEAT_POKEMANIAC_BRENT`; optional phone.
25. `MAP_ROUTE_43` - battle `ROUTE43_SUPER_NERD3` at (13,7) (`POKEMANIAC RON`)
    and `ROUTE43_SUPER_NERD1` at (14,6) (`POKEMANIAC BEN`). Post:
    `EVENT_BEAT_POKEMANIAC_RON`, `EVENT_BEAT_POKEMANIAC_BEN`.
26. `MAP_ROUTE_43` - walk north off the map edge (y < 0) into
    `MAP_LAKE_OF_RAGE`. Post: `ENGINE_FLYPOINT_LAKE_OF_RAGE`.
27. `MAP_LAKE_OF_RAGE` - CUT your way northwest; talk to
    `LAKEOFRAGE_POKE_BALL1` at (7,10). Post: `EVENT_LAKE_OF_RAGE_MAX_ETHER`.
28. `MAP_LAKE_OF_RAGE` - if `VAR_WEEKDAY == WEDNESDAY`, talk to
    `LAKEOFRAGE_WESLEY` at (4,4). Post: `EVENT_MET_WESLEY_OF_WEDNESDAY`,
    `EVENT_GOT_BLACKBELT_FROM_WESLEY`, `BLACKBELT_I` in bag. Then step on (4,4)
    for the hidden `RARE_CANDY`.
29. `MAP_LAKE_OF_RAGE` - warp 1 at (7,3) -> `MAP_LAKE_OF_RAGE_HIDDEN_POWER_HOUSE`;
    talk to the fisher at (2,3). Pre: `EVENT_GOT_TM10_HIDDEN_POWER` clear.
    Post: it is set, `TM_HIDDEN_POWER` in bag. Leave by (2,7)/(3,7).
30. `MAP_LAKE_OF_RAGE` - CUT northeast; talk to `LAKEOFRAGE_POKE_BALL2` at
    (35,2). Post: `EVENT_LAKE_OF_RAGE_TM_DETECT`, `TM_DETECT` (TM43) in bag.
    Optional hidden `MAX_POTION` at (35,5).
31. `MAP_LAKE_OF_RAGE` - optional hidden `FULL_RESTORE` at (11,28).
32. **Save.** Make sure the bag has a free slot: `RedGyarados`'s `giveitem
    RED_SCALE` is unguarded.
33. `MAP_LAKE_OF_RAGE` - SURF onto the lake and face `LAKEOFRAGE_GYARADOS` at
    (18,22); press A. Pre: `EVENT_LAKE_OF_RAGE_RED_GYARADOS` clear. The script
    runs `loadwildmon GYARADOS, 30` + `loadvar VAR_BATTLETYPE,
    BATTLETYPE_FORCESHINY`. Throw Great Balls; do not KO it if you want it.
    Post: `EVENT_LAKE_OF_RAGE_RED_GYARADOS` set (on a win or a catch),
    `RED_SCALE` in bag, `EVENT_LAKE_OF_RAGE_LANCE` cleared (Lance appears).
34. `MAP_LAKE_OF_RAGE` - walk to (21,29) and face north to talk to
    `LAKEOFRAGE_LANCE` at (21,28). Answer **YES** to `yesorno`.
    Post: `EVENT_DECIDED_TO_HELP_LANCE` set,
    `EVENT_MAHOGANY_MART_LANCE_AND_DRAGONITE` cleared, `MAHOGANY_MART_1F` scene
    set to `SCENE_MAHOGANYMART1F_LANCE_UNCOVERS_STAIRS`, Lance disappears.
    Answering NO sets `EVENT_REFUSED_TO_HELP_LANCE_AT_LAKE_OF_RAGE` and is
    recoverable by talking again.
35. Fly to `SPAWN_MAHOGANY` (lands at 15,14). Section complete; the next section
    starts at `MAP_MAHOGANY_MART_1F` warp 1 (11,7).

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map geometry, warps, coord/bg/object events for every map in this section | `src/import/RomExtractorGen2.lua:804-975` (`coordEvents`/`bgEvents`/`objects`), `src/world/gen2/Map.lua`, `src/world/gen2/World.lua:5013` (coord events), `:5148` (bg events) | implemented (data-driven from the ROM; nothing is hand-transcribed, so these tables come across as-is) |
| Map header fields (tileset/environment/landmark/music/palette/fish group) | `src/import/RomExtractorGen2.lua:741,965` | implemented |
| `MAPCALLBACK_NEWMAP` / `MAPCALLBACK_OBJECTS` (the two flypoint callbacks, `Route43CheckIfRocketsScene`, `LakeOfRageWesleyCallback`) | `src/script/gen2/Vm.lua` `runCallback`, `tests/gen2_map_callbacks_test.lua`, `tests/drivers/gold_map_callbacks.lua` | implemented |
| `ENGINE_FLYPOINT_MAHOGANY` / `ENGINE_FLYPOINT_LAKE_OF_RAGE` and Fly | `src/world/gen2/FieldMoves.lua:352-353` (`SPAWN_MAHOGANY` flag 72, `SPAWN_LAKE_OF_RAGE` flag 73) | implemented |
| `readvar VAR_WEEKDAY` (Wesley of Wednesday) | `src/world/gen2/World.lua` `World:weekday`, `src/script/gen2/Vm.lua` `readvar` | implemented |
| Fruit trees (`FRUITTREE_ROUTE_42_1/2/3`, `FRUITTREE_ROUTE_43`) with the daily reset | `src/core/gen2/Apricorns.lua:362` (the `BITTER_BERRY` row is `FRUITTREE_ROUTE_43`), `World:fruitTreeItem` / `fruitTreePick` | implemented |
| `itemball` / `hiddenitem` one-time flags | `src/script/gen2/CallAsm.lua`, `src/world/gen2/HiddenItems.lua` | implemented |
| Trainer objects, sight range, `loadtrainer` / `startbattle` | `src/world/gen2/Trainers.lua`, `src/script/gen2/Vm.lua` | implemented |
| Phone contacts for `FISHER CHRIS1`, `POKEMANIAC BRENT1`, `PICNICKER TIFFANY3` | `src/core/gen2/Phone.lua:201` (Chris, `ROUTE_42`), `:204` (Brent, `ROUTE_43`), `:207` (Tiffany, `ROUTE_43`) | implemented |
| Roaming beasts crossing Route 42/43 | `src/core/gen2/Roamers.lua:70-72` | implemented |
| RageCandyBar merchant scene (`showemote`, `applymovement`, `follow`/`stopfollow`, `checkmoney`/`takemoney`, `special PlaceMoneyTopRight`) | `src/script/gen2/Vm.lua` (all five opcodes present), `src/script/gen2/Specials.lua:1301` | implemented |
| Route 43 gate toll scene (`sdefer`, `readvar VAR_FACING`, `big_step` movement, `special RestartMapMusic`, `setscene`) | `src/script/gen2/Vm.lua`, `src/script/gen2/Specials.lua:1059` | implemented |
| Magikarp length rater (`special CheckMagikarpLength`, `MagikarpHouseSign`, `FindPartyMonThatSpecies`) | `src/script/gen2/Specials.lua:409,443,1124` | implemented (though the contest arm is gated behind `EVENT_CLEARED_ROCKET_HIDEOUT`, i.e. the next section) |
| Red Gyarados encounter plumbing (`loadwildmon`, `cry`, `startbattle`, `giveitem`, `itemnotify`, `appear`/`disappear`) | `src/script/gen2/Vm.lua`, `src/world/gen2/World.lua:4420` | implemented |
| **`BATTLETYPE_FORCESHINY` actually making the Red Gyarados shiny** | `src/world/gen2/World.lua:4591` sets `opts.battleType`, but `World:startBattle` (`:4420`) never reads it, and the wild mon is built by `Mon.new(data, id, wild.level or 5)` at `:4572` with `Mon.randomDVs()` | **missing** - the Lake of Rage Gyarados will be an ordinary blue L30 Gyarados except by 1-in-8192 luck. `World.lua:4576` handles `BATTLETYPE_FORCEITEM` only. The shiny *rendering* path is proven by `tests/drivers/gold_shiny_shots.lua`, which builds the mon with the `$EA`/`$AA` DVs by hand; nothing wires those DVs to the script opcode |
| `teleport_from` (`$4c`) - Lance's warp-into-the-sky animation | `src/script/gen2/Movement.lua` `decodeByte` has no case for `$4c`; it falls through to `{ kind = "nop" }` | partial - the script still runs and Lance still `disappear`s, so the flags are correct; only the animation is absent |
| Mahogany Mart `pokemart MARTTYPE_STANDARD, MART_MAHOGANY_1` | `src/ui/gen2/MartMenu.lua` + the extracted mart tables | implemented (not exercised by any `gold_*` driver for this map) |
| Any driver that plays this stretch | `tests/drivers/` has no `gold_lake_of_rage.lua` / `gold_route43.lua` | **missing** - no scripted run covers section 10 |

---

## 6. Unresolved / verify by hand

1. **"TM43 Secret Power"** - the walkthrough uses the HGSS move name. In
   Gold/Silver `LakeOfRageTMDetect` is `itemball TM_DETECT`, and the `add_tm`
   ladder in `constants/item_constants.asm:264` puts `DETECT` at TM43. The item
   is right, the move name in the FAQ is wrong.
2. **"Items found in Mahogany Town: TM16"** - there is no TM16 anywhere in
   `maps/MahoganyTown.asm`. TM16 is `ICY_WIND` (`constants/item_constants.asm:234`),
   which is Pryce's Gym reward - a different section, and unreachable here
   because `MAHOGANYTOWN_FISHER` blocks the Gym door.
3. **Camper Spencer's party** - the walkthrough says L17 Sandshrew / **L18**
   Sandslash / L19 Zubat. `data/trainers/parties.asm:2817` says L17 `SANDSHREW`,
   **L17** `SANDSLASH`, L19 `ZUBAT`. Trust the asm.
4. **"Wesley ... on the left path of Route 43"** - Wesley is not on Route 43 at
   all. `object_event 4, 4, SPRITE_SUPER_NERD ... WesleyScript` is on
   `MAP_LAKE_OF_RAGE`, in the far northwest corner behind the cut trees.
5. **"Max Ether ... to the right of Picnicker Tiffany"** - the ball is at
   (12,32) and Tiffany is at (9,29), so it is right *and* three rows south of
   her. Close but not the same row.
6. **Where the Cut trees are on Route 42 and Lake of Rage** - not in any event
   table. They are block ids inside `maps/Route42.blk` and `maps/LakeOfRage.blk`,
   read by `CheckMapForSomethingToCut` (`engine/events/overworld.asm`, called from
   `CutFunction.CheckAble`). A bot needs the block data, not the asm, to know
   which tiles to cut. Same for the exact water tiles a Surf entry point needs
   on Route 42 and Lake of Rage, and for the walkthrough's claim that Route 43's
   west grass path bypasses `ROUTE_43_GATE`.
7. **"Your Mom calls you"** on Route 43 - this is the generic
   `SPECIALCALL_*` / Mom-shopping call, not anything in `maps/Route43.asm`.
   There is no `specialphonecall` in the Route 43 script. Which call fires and
   when lives in `data/events/special_phone_calls.asm` and
   `src/core/gen2/MomShopping.lua`; not pinned down for this section.
8. **Fisher Marvin's fourth mon EXP** - the walkthrough leaves the L15 Gyarados
   EXP as "?". Nothing in the asm to resolve; it is a derived number.
9. **`LakeOfRage_MapScripts`'s two scene scripts are commented `; unusable`** and
   `RedGyarados` does `setscene 0` with the comment "Lake of Rage does not have a
   scene variable". Harmless on the cart, but a port that models `setscene` as a
   write to a per-map byte should confirm it does not corrupt a neighbouring
   map's scene.
10. **`Route43Gate` warp 4 (5,7) points at `ROUTE_43` warp 3**, the same as warp
    3 (4,7). Transcribed as written; if a bot walks out of the gate's
    bottom-right tile it lands on the same Route 43 warp as the bottom-left one.
11. **Gyarados loss path** - `RedGyarados`'s `ifequal LOSE, .NotBeaten` only
    skips the `disappear`; the `giveitem RED_SCALE` and `appear LAKEOFRAGE_LANCE`
    run either way. That reads like a cart quirk rather than a transcription
    error, but it has not been observed on hardware for this document.

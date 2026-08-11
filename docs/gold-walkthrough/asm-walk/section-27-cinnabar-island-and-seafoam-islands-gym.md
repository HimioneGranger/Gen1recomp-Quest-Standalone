# Section 27 - Cinnabar Island and Seafoam Islands Gym

Source: `../section-27-cinnabar-island-and-seafoam-islands-gym.txt`
(the FAQ numbers this chapter "33 > Cinnabar Island and Seafoam Islands Gym"; the
file index is 27)

Maps covered: `MAP_ROUTE_21`, `MAP_CINNABAR_ISLAND`, `MAP_CINNABAR_POKECENTER_1F`,
`MAP_ROUTE_20`, `MAP_SEAFOAM_GYM`

Badges / key milestones in this section:

- `ENGINE_FLYPOINT_CINNABAR` (set on first entry to Cinnabar Island)
- Blue's one-off speech on Cinnabar Island, which is what unlocks him in Viridian Gym
  (`clearevent EVENT_VIRIDIAN_GYM_BLUE`)
- Hidden RARE_CANDY on Cinnabar Island
- `EVENT_CINNABAR_ROCKS_CLEARED` (set silently by walking onto Route 20; this is what
  clears the boulders that seal Route 19 to the east)
- **VOLCANOBADGE** from BLAINE in the Seafoam Islands cave (`ENGINE_VOLCANOBADGE`,
  `EVENT_BEAT_BLAINE`)

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 0 | `PALLET_TOWN` | - | - | south connection to `ROUTE_21` (`data/maps/attributes.asm:270-272`) | **Pallet Town belongs to the previous section; only the hop south is listed here.** |
| 1 | `ROUTE_21` | `maps/Route21.asm` | north connection from `PALLET_TOWN` (`data/maps/attributes.asm:274-275`) | south connection to `CINNABAR_ISLAND` (`attributes.asm:277`) | Surf south. Three trainers: Nikki, Arnold, Seth |
| 2 | `CINNABAR_ISLAND` | `maps/CinnabarIsland.asm` | north connection from `ROUTE_21` (`attributes.asm:279-280`) | warp 1 at (11,11) -> `CINNABAR_POKECENTER_1F` 1; east connection to `ROUTE_20` (`attributes.asm:281`) | Sets `ENGINE_FLYPOINT_CINNABAR`; heal; talk to Blue; hidden RARE_CANDY |
| 3 | `CINNABAR_POKECENTER_1F` | `maps/CinnabarPokecenter1F.asm` | Cinnabar warp 1 | warps 1/2 at (3,7)/(4,7) back to `CINNABAR_ISLAND` 1 | Heal; the two flavour NPCs the walkthrough quotes ("a year since the volcano erupted", "BLAINE lives alone in the SEAFOAM ISLANDS cave") |
| 4 | `ROUTE_20` | `maps/Route20.asm` | west connection from `CINNABAR_ISLAND` (`attributes.asm:283-284`) | warp 1 at (38,7) -> `SEAFOAM_GYM` 1 | `MAPCALLBACK_NEWMAP` sets `EVENT_CINNABAR_ROCKS_CLEARED`; Swimmer Cameron at (12,13) |
| 5 | `SEAFOAM_GYM` | `maps/SeafoamGym.asm` | Route 20 warp 1 | warp 1 at (5,5) back to `ROUTE_20` 1 | BLAINE -> **VOLCANOBADGE** |

Spillover: Route 20 continues east past the gym to Swimmer Lori (45,13) and Swimmer
Nicole (52,8) and then over the `connection east, Route19, ROUTE_19, -9` boundary into
Fuchsia territory; the walkthrough does not visit them here and they belong to the
following section.

---

## 2. Maps

### MAP_ROUTE_21

- Script: `maps/Route21.asm`
- Blocks: `maps/Route21.blk`
- Header: `data/maps/maps.asm:198` -> `TILESET_KANTO, ROUTE, LANDMARK_ROUTE_21, MUSIC_ROUTE_3, FALSE (phone calls allowed), PALETTE_AUTO, FISHGROUP_OCEAN`
- Dimensions: `constants/map_constants.asm:182` `map_const ROUTE_21, 10, 18` (group `CINNABAR` = 6, map id 7). 10x18 blocks = 20x36 tile coordinates.
- Attributes / border: `data/maps/attributes.asm:274` `map_attributes Route21, ROUTE_21, $43`
- Connections: north `PALLET_TOWN` (offset 0), south `CINNABAR_ISLAND` (offset 0)
- Landmark position: `data/maps/landmarks.asm:96` `landmark 52, 120, Route21Name`

**Warps** (`def_warp_events`)

None (`def_warp_events` at `maps/Route21.asm:95` is empty).

**Coord events** (`def_coord_events`)

None (`maps/Route21.asm:97`).

**BG events** (`def_bg_events`)

None (`maps/Route21.asm:99`).

**Object events** (`def_object_events`, `maps/Route21.asm:101-104`)

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `ROUTE21_SWIMMER_GIRL` | `SPRITE_SWIMMER_GIRL` | 11 | 16 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSwimmerfNikki` | -1 (always) |
| `ROUTE21_SWIMMER_GUY` | `SPRITE_SWIMMER_GUY` | 2 | 30 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 4 | `TrainerSwimmermSeth` | -1 (always) |
| `ROUTE21_FISHER` | `SPRITE_FISHER` | 14 | 22 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` | 1 | `TrainerFisherArnold` | -1 (always) |

The walkthrough's order (Nikki, then the fisherman, then "head way left then down") is
exactly the y ordering 16 -> 22 -> 30, with Seth in the far south-west corner at x=2.

**Scripts of interest**

- `TrainerSwimmerfNikki` (`maps/Route21.asm:22`, sym `4e:4803`) -
  `trainer SWIMMERF, NIKKI, EVENT_BEAT_SWIMMERF_NIKKI, SwimmerfNikkiSeenText, SwimmerfNikkiBeatenText, 0, .Script`.
  The `0` is the loss-text slot (no whiteout text). `.Script` is `endifjustbattled` +
  one after-battle line; no items, no flags beyond the beat flag.
- `TrainerFisherArnold` (`maps/Route21.asm:33`, sym `4e:4817`) - same shape,
  `EVENT_BEAT_FISHER_ARNOLD`.
- `TrainerSwimmermSeth` (`maps/Route21.asm:11`, sym `4e:47ef`) - same shape,
  `EVENT_BEAT_SWIMMERM_SETH`.

There are no scene scripts and no callbacks on this map (`def_scene_scripts` /
`def_callbacks` at `maps/Route21.asm:7-9` are both empty).

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_SWIMMERF_NIKKI` | `constants/event_flags.asm:490` | `trainer` macro row, `maps/Route21.asm:23` | set once Nikki is beaten; suppresses re-battle |
| `EVENT_BEAT_FISHER_ARNOLD` | `constants/event_flags.asm:587` | `maps/Route21.asm:34` | as above |
| `EVENT_BEAT_SWIMMERM_SETH` | `constants/event_flags.asm:958` | `maps/Route21.asm:12` | as above |

**Items**

None on this map.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `SWIMMERF, NIKKI` | SWIMMERF ($27) | 17 | `; SWIMMERF (17)` at `parties.asm:1872`: L28 SEEL, L28 SEEL, L28 SEEL, L28 DEWGONG (`TRAINERTYPE_NORMAL`) | `TrainerSwimmerfNikki` | no |
| `FISHER, ARNOLD` | FISHER ($25) | 3 | `; FISHER (3)` at `parties.asm:1511`: L34 TENTACRUEL | `TrainerFisherArnold` | no |
| `SWIMMERM, SETH` | SWIMMERM ($26) | 18 | `; SWIMMERM (18)` at `parties.asm:1754`: L29 QUAGSIRE, L29 OCTILLERY, L32 QUAGSIRE | `TrainerSwimmermSeth` | no |

Payouts (base reward x last-mon level x 4, see section 3 for the citation):
Nikki 5 x 28 x 4 = **560**, Arnold 10 x 34 x 4 = **1360**, Seth 2 x 32 x 4 = **256**.
All three match the walkthrough exactly.
Base rewards: `data/trainers/attributes.asm:223` (Fisher, 10), `:229` (Swimmerm, 2),
`:235` (Swimmerf, 5).

**Wild encounters**

- Water (`data/wild/kanto_water.asm:61-66`), 6% rate: L35 TENTACOOL / L30 TENTACOOL / L35 TENTACRUEL.
- Grass (`data/wild/kanto_grass.asm:1005-1031`), 6/6/6% morn/day/nite. There *is* a
  grass table, on the small land tiles:
  - morn: 30 TANGELA, 25 TANGELA, 35 TANGELA, 20 TANGELA, 30 TANGELA, 28 MR__MIME, 28 MR__MIME
  - day: 30 TANGELA, 25 TANGELA, 35 TANGELA, 20 TANGELA, 28 MR__MIME, 30 MR__MIME, 30 MR__MIME
  - nite: 30 TANGELA, 25 TANGELA, 35 TANGELA, 20 TANGELA, 30 TANGELA, 28 MR__MIME, 28 MR__MIME
- Fishing: `FISHGROUP_OCEAN` (`data/wild/fish.asm:13`). Old rod `.Ocean_Old` (`:42`)
  MAGIKARP/MAGIKARP/TENTACOOL L10; Good rod `.Ocean_Good` (`:46`) MAGIKARP L20 /
  TENTACOOL L20 / CHINCHOU L20 / `time_group 2` = SHELLDER L20 day and nite
  (`fish.asm:214`); Super rod `.Ocean_Super` (`:51`) CHINCHOU L40 / `time_group 3` =
  SHELLDER L40 (`fish.asm:215`) / TENTACRUEL L40 / LANTURN L40.
- No headbutt tree rows and no rock smash on this map.

---

### MAP_CINNABAR_ISLAND

- Script: `maps/CinnabarIsland.asm`
- Blocks: `maps/CinnabarIsland.blk`
- Header: `data/maps/maps.asm:199` -> `TILESET_KANTO, TOWN, LANDMARK_CINNABAR_ISLAND, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_AUTO, FISHGROUP_OCEAN`
- Dimensions: `constants/map_constants.asm:183` `map_const CINNABAR_ISLAND, 10, 9` (group `CINNABAR` = 6, map id 8). 20x18 tile coordinates.
- Attributes / border: `data/maps/attributes.asm:279` `map_attributes CinnabarIsland, CINNABAR_ISLAND, $43`
- Connections: north `ROUTE_21` (offset 0), east `ROUTE_20` (offset 0)
- Landmark: `data/maps/landmarks.asm:95` `landmark 52, 132, CinnabarIslandName`
- Fly / respawn point: `data/maps/flypoints.asm:28` `db LANDMARK_CINNABAR_ISLAND, SPAWN_CINNABAR`;
  `data/maps/spawn_points.asm:24` `spawn CINNABAR_ISLAND, 11, 12`

**Warps** (`def_warp_events`, `maps/CinnabarIsland.asm:131-132`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 11 | 11 | `CINNABAR_POKECENTER_1F` | 1 |

**Coord events** (`def_coord_events`)

None (`maps/CinnabarIsland.asm:134`). Blue is a talk-to NPC, not a trip-wire.

**BG events** (`def_bg_events`, `maps/CinnabarIsland.asm:136-140`)

| x | y | type | script/item |
|---|---|---|---|
| 12 | 11 | `BGEVENT_READ` | `CinnabarIslandPokecenterSign` -> `jumpstd PokecenterSignScript` |
| 9 | 11 | `BGEVENT_READ` | `CinnabarIslandGymSign` -> "CINNABAR GYM has relocated to SEAFOAM ISLANDS. BLAINE" |
| 7 | 7 | `BGEVENT_READ` | `CinnabarIslandSign` -> town sign |
| 9 | 1 | `BGEVENT_ITEM` | `CinnabarIslandHiddenRareCandy` -> `hiddenitem RARE_CANDY, EVENT_CINNABAR_ISLAND_HIDDEN_RARE_CANDY` (sym `4e:49a2`) |

**Object events** (`def_object_events`, `maps/CinnabarIsland.asm:142-143`)

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `CINNABARISLAND_BLUE` | `SPRITE_BLUE` | 9 | 6 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | 0 | `CinnabarIslandBlue` | `EVENT_BLUE_IN_CINNABAR` |

**Scripts of interest**

- `CinnabarIslandFlypointCallback` (`maps/CinnabarIsland.asm:10`, sym `4e:4981`), wired
  as `callback MAPCALLBACK_NEWMAP` at `:8`. Body is exactly
  `setflag ENGINE_FLYPOINT_CINNABAR` / `endcallback`. Walking in once is the whole
  unlock for flying here.
- `CinnabarIslandBlue` (`maps/CinnabarIsland.asm:14`, sym `4e:4985`). Control flow, in
  order: `faceplayer`, `opentext`, `writetext CinnabarIslandBlueText`, `waitbutton`,
  `closetext`, `playsound SFX_WARP_TO`,
  `applymovement CINNABARISLAND_BLUE, CinnabarIslandBlueTeleport`,
  `disappear CINNABARISLAND_BLUE`, `clearevent EVENT_VIRIDIAN_GYM_BLUE`, `end`.
  - There is **no guard flag and no `iftrue`** at the top: the script is one-shot only
    because `disappear` sets the object's own `EVENT_BLUE_IN_CINNABAR` (see
    `Script_disappear` at `engine/overworld/scripting.asm:887`, `ld b, 1 ; set`).
  - `CinnabarIslandBlueTeleport` (`:38`) is a two-byte movement stream:
    `teleport_from` (`$4c`, `macros/scripts/movement.asm:148`) then `step_end`. That is
    the "levitates and flies off" the walkthrough describes.
  - `clearevent EVENT_VIRIDIAN_GYM_BLUE` is the load-bearing side effect: that flag is
    set at boot by `InitializeEventsScript` (`engine/events/std_scripts.asm:552`) and it
    hides both `VIRIDIANGYM_BLUE` and the Viridian gym guide
    (`maps/ViridianGym.asm:183-184`). **Talking to Blue here is the only thing that
    puts Blue in Viridian Gym.**
- `CinnabarIslandHiddenRareCandy` (`maps/CinnabarIsland.asm:35`) - a `hiddenitem`
  operand, not a script body: `dwb EVENT_CINNABAR_ISLAND_HIDDEN_RARE_CANDY, RARE_CANDY`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_CINNABAR` | `constants/engine_flags.asm:77` | set by `CinnabarIslandFlypointCallback` | Fly destination unlocked; also the wVisitedSpawns bit for respawn |
| `EVENT_BLUE_IN_CINNABAR` | `constants/event_flags.asm:1303` | *set* implicitly by `disappear CINNABARISLAND_BLUE`; read by `maps/ViridianCity.asm:37` and `maps/ViridianPokecenter1F.asm:18` for "Blue returned" dialogue | clear = Blue is standing on Cinnabar; set = you have heard the speech |
| `EVENT_VIRIDIAN_GYM_BLUE` | `constants/event_flags.asm:1304` | set at `engine/events/std_scripts.asm:552`; cleared by `CinnabarIslandBlue` | while set, Viridian Gym is empty |
| `EVENT_CINNABAR_ISLAND_HIDDEN_RARE_CANDY` | `constants/event_flags.asm:254` | the `hiddenitem` at `maps/CinnabarIsland.asm:36` | one-shot guard on the hidden candy |

Note: `EVENT_BLUE_IN_CINNABAR` is **not** in the `InitializeEventsScript` list, so it
starts clear and Blue is visible from the first time you reach the island.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `RARE_CANDY` | face tile (9,1) and press A (or ITEMFINDER) | `bg_event 9, 1, BGEVENT_ITEM, CinnabarIslandHiddenRareCandy` | `EVENT_CINNABAR_ISLAND_HIDDEN_RARE_CANDY` |

The walkthrough never mentions this candy.

**Trainers**

None.

**Wild encounters**

No `def_grass_wildmons`/`def_water_wildmons` row for `CINNABAR_ISLAND` in
`data/wild/kanto_grass.asm` or `data/wild/kanto_water.asm`. The surrounding water belongs
to Route 20 / Route 21. Fishing on the map's own water uses `FISHGROUP_OCEAN`
(`data/maps/maps.asm:199`).

---

### MAP_CINNABAR_POKECENTER_1F

- Script: `maps/CinnabarPokecenter1F.asm`
- Header: `data/maps/maps.asm:192` -> `TILESET_POKECENTER, INDOOR, LANDMARK_CINNABAR_ISLAND, MUSIC_POKEMON_CENTER, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:176` `map_const CINNABAR_POKECENTER_1F, 5, 4` (group `CINNABAR` = 6, map id 1)
- Attributes: `data/maps/attributes.asm:510` `map_attributes CinnabarPokecenter1F, CINNABAR_POKECENTER_1F, $00`; no connections

**Warps** (`def_warp_events`, `maps/CinnabarPokecenter1F.asm:38-41`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `CINNABAR_ISLAND` | 1 |
| 2 | 4 | 7 | `CINNABAR_ISLAND` | 1 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

**Coord events / BG events**

None (`maps/CinnabarPokecenter1F.asm:43`, `:45`).

**Object events** (`maps/CinnabarPokecenter1F.asm:47-50`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `CINNABARPOKECENTER1F_NURSE` | `SPRITE_NURSE` | 3 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CinnabarPokecenter1FNurseScript` -> `jumpstd PokecenterNurseScript` | -1 |
| `CINNABARPOKECENTER1F_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 7 | 6 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius x 2) | `OBJECTTYPE_SCRIPT` | `CinnabarPokecenter1FCooltrainerFScript` (BLAINE lives in the Seafoam cave) | -1 |
| `CINNABARPOKECENTER1F_FISHER` | `SPRITE_FISHER` | 2 | 4 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CinnabarPokecenter1FFisherScript` ("It's been a year since the volcano erupted.") | -1 |

Both flavour NPCs are unconditional `jumptextfaceplayer` - no flags, no branches. These
are the two people the walkthrough tells you to talk to.

---

### MAP_ROUTE_20

- Script: `maps/Route20.asm`
- Blocks: `maps/Route20.blk`
- Header: `data/maps/maps.asm:197` -> `TILESET_KANTO, ROUTE, LANDMARK_ROUTE_20, MUSIC_ROUTE_3, FALSE, PALETTE_AUTO, FISHGROUP_OCEAN`
- Dimensions: `constants/map_constants.asm:181` `map_const ROUTE_20, 30, 9` (group `CINNABAR` = 6, map id 6). 60x18 tile coordinates.
- Attributes / border: `data/maps/attributes.asm:283` `map_attributes Route20, ROUTE_20, $43`
- Connections: west `CINNABAR_ISLAND` (offset 0), east `ROUTE_19` (offset -9)
- Landmarks in view: `data/maps/landmarks.asm:93` Route 20, `:94` `SeafoamIslandsName`

**Warps** (`def_warp_events`, `maps/Route20.asm:116-117`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 38 | 7 | `SEAFOAM_GYM` | 1 |

**Coord events**

None (`maps/Route20.asm:119`).

**BG events** (`maps/Route20.asm:121-122`)

| x | y | type | script/item |
|---|---|---|---|
| 37 | 11 | `BGEVENT_READ` | `CinnabarGymSign` -> "CINNABAR GYM / LEADER: BLAINE" |

**Object events** (`maps/Route20.asm:124-127`)

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `ROUTE20_SWIMMER_GIRL1` | `SPRITE_SWIMMER_GIRL` | 52 | 8 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSwimmerfNicole` | -1 |
| `ROUTE20_SWIMMER_GIRL2` | `SPRITE_SWIMMER_GIRL` | 45 | 13 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSwimmerfLori` | -1 |
| `ROUTE20_SWIMMER_GUY` | `SPRITE_SWIMMER_GUY` | 12 | 13 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSwimmermCameron` | -1 |

Cameron at x=12 is the only one west of the gym door at x=38, which is why the
walkthrough sees "one trainer" on the way in. Lori (45) and Nicole (52) are east of it.

**Scripts of interest**

- `Route20ClearRocksCallback` (`maps/Route20.asm:12`, sym `4e:4cfa`), wired as
  `callback MAPCALLBACK_NEWMAP` at `:10`. Body is `setevent EVENT_CINNABAR_ROCKS_CLEARED`
  / `endcallback`. It fires silently the first time the map loads.
  Consumers: `Route19ClearRocksCallback` (`maps/Route19.asm:15`, sym `4e:4f09`, a
  `MAPCALLBACK_TILES` callback) draws six `changeblock ... $7a ; rock` blocks at
  (6,6), (8,6), (10,6), (12,8), (4,8), (10,10) **while the flag is clear**; the officer
  in `maps/Route19FuchsiaGate.asm:12` and the two fishers in `maps/Route19.asm:74`/`:90`
  swap dialogue on it.
- `TrainerSwimmermCameron` (`maps/Route20.asm:38`, sym `4e:4d26`) - plain trainer,
  `EVENT_BEAT_SWIMMERM_CAMERON`, `endifjustbattled` + one line.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_CINNABAR_ROCKS_CLEARED` | `constants/event_flags.asm:214` | set by `Route20ClearRocksCallback`; read by `maps/Route19.asm:16`, `:74`, `:90` and `maps/Route19FuchsiaGate.asm:12` | while clear, six rock blocks seal the Route 19 water path from the Fuchsia side |
| `EVENT_BEAT_SWIMMERM_CAMERON` | `constants/event_flags.asm:957` | `maps/Route20.asm:39` | beat flag |
| `EVENT_BEAT_SWIMMERF_NICOLE` | `constants/event_flags.asm:487` | `maps/Route20.asm:17` | beat flag (next section) |
| `EVENT_BEAT_SWIMMERF_LORI` | `constants/event_flags.asm:488` | `maps/Route20.asm:28` | beat flag (next section) |

**Items**

None on this map.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `SWIMMERM, CAMERON` | SWIMMERM ($26) | 17 | `; SWIMMERM (17)` at `parties.asm:1749`: L34 MARILL | `TrainerSwimmermCameron` | no |
| `SWIMMERF, NICOLE` | SWIMMERF ($27) | 14 | `; SWIMMERF (14)` at `parties.asm:1854`: L29 MARILL, L29 MARILL, L32 LAPRAS | `TrainerSwimmerfNicole` | no |
| `SWIMMERF, LORI` | SWIMMERF ($27) | 15 | `; SWIMMERF (15)` at `parties.asm:1861`: L32 STARMIE, L32 STARMIE | `TrainerSwimmerfLori` | no |

Cameron pays 2 x 34 x 4 = **272**, matching the walkthrough.

**Wild encounters**

- Water (`data/wild/kanto_water.asm:54-59`), 6% rate: L35 TENTACOOL / L30 TENTACOOL / L35 TENTACRUEL.
- No `def_grass_wildmons ROUTE_20` row exists in `data/wild/kanto_grass.asm` - there is
  no land grass on this route.
- Fishing: `FISHGROUP_OCEAN`, same three rod tables as Route 21 above.

---

### MAP_SEAFOAM_GYM

- Script: `maps/SeafoamGym.asm`
- Blocks: `maps/SeafoamGym.blk`
- Header: `data/maps/maps.asm:195` -> `TILESET_CAVE, INDOOR, LANDMARK_SEAFOAM_ISLANDS, MUSIC_GYM, TRUE (phone calls blocked), PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:179` `map_const SEAFOAM_GYM, 5, 4` (group `CINNABAR` = 6, map id 4). 10x8 tile coordinates - smaller than the 20x18 screen, which is the walkthrough's "this gym doesn't even fit the entire screen".
- Attributes / border: `data/maps/attributes.asm:513` `map_attributes SeafoamGym, SEAFOAM_GYM, $09`; no connections
- There is **no** `MAP_SEAFOAM_ISLANDS` dungeon in Gen 2 - `constants/map_constants.asm`
  has only `SEAFOAM_GYM` in the whole Seafoam family.

**Warps** (`def_warp_events`, `maps/SeafoamGym.asm:161-162`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 5 | `ROUTE_20` | 1 |

**Coord events**

None (`maps/SeafoamGym.asm:164`). The map does declare one scene script,
`scene_script SeafoamGymNoopScene` (`:7`), and the asm itself annotates it
`; unusable` - the body at `:11` is a bare `end`.

**BG events**

None (`maps/SeafoamGym.asm:166`).

**Object events** (`maps/SeafoamGym.asm:168-170`)

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `SEAFOAMGYM_BLAINE` | `SPRITE_BLAINE` | 5 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `SeafoamGymBlaineScript` | -1 (always present) |
| `SEAFOAMGYM_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 6 | 5 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | 0 | `SeafoamGymGuideScript` | `EVENT_SEAFOAM_GYM_GYM_GUIDE` |

**Scripts of interest**

- `SeafoamGymBlaineScript` (`maps/SeafoamGym.asm:14`, sym `53:516d`). Control flow:
  1. `faceplayer`, `opentext`
  2. `checkflag ENGINE_VOLCANOBADGE` / `iftrue .FightDone` - the entire re-talk guard is
     the badge engine flag, **not** an event flag.
  3. `writetext BlaineIntroText`, `waitbutton`, `closetext`
  4. `winlosstext BlaineWinLossText, 0` (no loss text)
  5. `loadtrainer BLAINE, BLAINE1`, `startbattle`
  6. `iftrue .ReturnAfterBattle` - i.e. if the battle result is non-zero (you lost /
     drew) it *skips* `appear SEAFOAMGYM_GYM_GUIDE`
  7. `appear SEAFOAMGYM_GYM_GUIDE` - clears `EVENT_SEAFOAM_GYM_GYM_GUIDE`, which is how
     the guide "comes in late"
  8. `.ReturnAfterBattle`: `reloadmapafterbattle`, `setevent EVENT_BEAT_BLAINE`,
     `opentext`, `writetext ReceivedVolcanoBadgeText`, `playsound SFX_GET_BADGE`,
     `waitsfx`, **`setflag ENGINE_VOLCANOBADGE`**, `writetext BlaineAfterBattleText`,
     `waitbutton`, `closetext`, `end`
  - No `verbosegiveitem` anywhere: **Blaine gives no TM**, only the badge.
  - Note the ordering quirk: `setevent EVENT_BEAT_BLAINE` / `setflag ENGINE_VOLCANOBADGE`
    are on the shared `.ReturnAfterBattle` path, reached whether or not you won, but
    `startbattle` does not return to the script on a whiteout, so in practice this is
    only reached after a win.
- `SeafoamGymGuideScript` (`maps/SeafoamGym.asm:46`, sym `53:51a3`) - branches on
  `EVENT_TALKED_TO_SEAFOAM_GYM_GUIDE_ONCE`, first line is the apology
  ("CINNABAR GYM was gone, so I didn't know where to find you"), then a second line
  forever after.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_VOLCANOBADGE` | `constants/engine_flags.asm:53` (Kanto badge 7; `wKantoBadges` bit 6 per `constants/ram_constants.asm:270`) | checked at `maps/SeafoamGym.asm:17`, set at `:34` | the badge itself; also gates the re-talk branch |
| `EVENT_BEAT_BLAINE` | `constants/event_flags.asm:721` | set at `maps/SeafoamGym.asm:29` | not read by any other map in the checkout; it is the record, not the gate |
| `EVENT_SEAFOAM_GYM_GYM_GUIDE` | `constants/event_flags.asm:1305` | set at boot (`engine/events/std_scripts.asm:553`), cleared by `appear` at `maps/SeafoamGym.asm:26` | while set, the guide object does not exist |
| `EVENT_TALKED_TO_SEAFOAM_GYM_GUIDE_ONCE` | `constants/event_flags.asm:212` | `maps/SeafoamGym.asm:49`, `:54` | first-talk vs repeat text |

What VOLCANOBADGE actually does mechanically: `data/types/badge_type_boosts.asm:19`
`db FIRE ; VOLCANOBADGE`, consumed by `DoBadgeTypeBoosts` (`engine/battle/misc.asm:146`,
called from `engine/battle/effect_commands.asm:1261`) - a +12.5% damage boost on the
player's FIRE-type moves. It grants no field move.

**Items**

None.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `BLAINE, BLAINE1` | BLAINE ($2e), `constants/trainer_constants.asm:469-470` | 1 | `BlaineGroup` (sym `0e:6e70`) at `parties.asm:2303`, `TRAINERTYPE_MOVES`: **L45 MAGCARGO** (CURSE, SMOG, FLAMETHROWER, ROCK_SLIDE), **L45 MAGMAR** (THUNDERPUNCH, FIRE_PUNCH, SUNNY_DAY, CONFUSE_RAY), **L50 RAPIDASH** (QUICK_ATTACK, FIRE_SPIN, FURY_ATTACK, FIRE_BLAST) | `SeafoamGymBlaineScript` | no rematch, no phone |

Class attributes (`data/trainers/attributes.asm:275-279`): AI items are
**`MAX_POTION, FULL_HEAL`** (not two Full Restores); base reward 25; AI mask
`AI_BASIC | AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_CAUTIOUS | AI_STATUS | AI_RISKY`,
`CONTEXT_USE | SWITCH_SOMETIMES`. Payout 25 x 50 x 4 = **5000**, matching the walkthrough.
`BLAINE` is in `KantoGymLeaders` (`data/trainers/leaders.asm`), so the battle uses the
gym-leader music and awards `HAPPINESS_GYMBATTLE`.

**Wild encounters**

None. The map is `INDOOR` with `TILESET_CAVE`; its `FISHGROUP_SHORE` header entry is the
default and has no reachable water.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Everything in this section is across open sea (Pallet -> Route 21 -> Cinnabar -> Route 20 -> gym door) | `engine/events/overworld.asm:469` `TrySurfOW` (walk-into-water path): `ld de, ENGINE_FOGBADGE` / `CheckEngineFlag` at `:490`, then `ld d, SURF` / `CheckPartyMove`. Menu path is `SurfFunction` `.TrySurf` at `:340` with the same `ENGINE_FOGBADGE`. `CheckBadge` itself is at `:50`. | FOGBADGE + a party mon that knows SURF | already held long before Kanto (Johto badge 4) |
| Fly to Cinnabar Island | `data/maps/flypoints.asm:28`; the flag is `ENGINE_FLYPOINT_CINNABAR`, set by `CinnabarIslandFlypointCallback` (`maps/CinnabarIsland.asm:10`) | STORMBADGE + FLY + having stood on Cinnabar Island once | walk in once |
| Blue is not in Viridian Gym | `maps/ViridianGym.asm:183-184` object rows carry `EVENT_VIRIDIAN_GYM_BLUE`, set at `engine/events/std_scripts.asm:552` | - | `clearevent EVENT_VIRIDIAN_GYM_BLUE` at the tail of `CinnabarIslandBlue` (`maps/CinnabarIsland.asm:23`) - **this section is a hard prerequisite for the Viridian Gym leader** |
| Route 19 (east of Route 20) is sealed by six boulder blocks | `maps/Route19.asm:15` `Route19ClearRocksCallback`, a `MAPCALLBACK_TILES` callback that lays `changeblock` rock blocks while `EVENT_CINNABAR_ROCKS_CLEARED` is clear | - | `setevent EVENT_CINNABAR_ROCKS_CLEARED` in `Route20ClearRocksCallback` (`maps/Route20.asm:13`), i.e. simply loading Route 20 once from the Cinnabar side |
| Blaine will not re-battle | `maps/SeafoamGym.asm:17` `checkflag ENGINE_VOLCANOBADGE` / `iftrue .FightDone` | - | none in vanilla; `.FightDone` is terminal |
| The gym guide does not exist until Blaine is beaten | object row event flag `EVENT_SEAFOAM_GYM_GYM_GUIDE` (`maps/SeafoamGym.asm:170`), set at `engine/events/std_scripts.asm:553` | beat Blaine | `appear SEAFOAMGYM_GYM_GUIDE` (`maps/SeafoamGym.asm:26`), only on the win branch |

Nothing in this section needs CUT, STRENGTH, WHIRLPOOL, WATERFALL, FLASH or a key item.

## 4. Bot checklist

Ordered, machine-actionable. `(g,m)` is `(map group, map id)` from
`constants/map_constants.asm`. All coordinates are the raw asm map-event values.

1. `PALLET_TOWN`: SURF south across the connection into `ROUTE_21 (6,7)`.
   Pre: FOGBADGE + SURF in the party. Post: none.
2. `ROUTE_21`: battle `TrainerSwimmerfNikki` at (11,16) - sight radius 3, so she will
   trigger on approach. Party L28 SEEL x3 + L28 DEWGONG. Post: `EVENT_BEAT_SWIMMERF_NIKKI`, +560 money.
3. `ROUTE_21`: battle `TrainerFisherArnold` at (14,22) - sight radius 1, faces up.
   Party L34 TENTACRUEL. Post: `EVENT_BEAT_FISHER_ARNOLD`, +1360 money.
4. `ROUTE_21`: surf west then south to `TrainerSwimmermSeth` at (2,30) - sight radius 4,
   faces right. Party L29 QUAGSIRE / L29 OCTILLERY / L32 QUAGSIRE.
   Post: `EVENT_BEAT_SWIMMERM_SETH`, +256 money.
   (Both trainers are avoidable - all three are `OBJECTTYPE_TRAINER` with a finite sight
   radius, none are on a coord event.)
5. `ROUTE_21`: continue south across the connection into `CINNABAR_ISLAND (6,8)`.
   Post: `MAPCALLBACK_NEWMAP` sets `ENGINE_FLYPOINT_CINNABAR`; respawn point becomes
   `SPAWN_CINNABAR` = (11,12).
6. `CINNABAR_ISLAND`: step on warp 1 at (11,11) -> `CINNABAR_POKECENTER_1F (6,1)`.
   Talk to `CINNABARPOKECENTER1F_NURSE` at (3,1) to heal. Optional: the two flavour NPCs
   at (7,6) and (2,4). Exit via warp 1/2 at (3,7)/(4,7).
7. `CINNABAR_ISLAND`: optional - face (9,1) and press A for the hidden **RARE_CANDY**.
   Pre: `EVENT_CINNABAR_ISLAND_HIDDEN_RARE_CANDY` clear + a free bag slot.
   Post: flag set. (Not in the walkthrough.)
8. `CINNABAR_ISLAND`: walk to `CINNABARISLAND_BLUE` at (9,6) and talk.
   Pre: `EVENT_BLUE_IN_CINNABAR` clear. Expect a long `writetext` (about 13 pages of
   `para` breaks - budget A presses accordingly), then `SFX_WARP_TO` + a `teleport_from`
   movement, then the object vanishes.
   Post: `EVENT_BLUE_IN_CINNABAR` set (via `disappear`), `EVENT_VIRIDIAN_GYM_BLUE`
   **cleared**. Do not skip this step: it is the only unlock for the Viridian Gym leader.
9. `CINNABAR_ISLAND`: optional signs at (12,11), (9,11), (7,7).
10. `CINNABAR_ISLAND`: SURF east across the connection into `ROUTE_20 (6,6)`.
    Post: `MAPCALLBACK_NEWMAP` sets `EVENT_CINNABAR_ROCKS_CLEARED` (silent; unseals
    Route 19 for the next section).
11. `ROUTE_20`: battle `TrainerSwimmermCameron` at (12,13) - sight radius 3.
    Party L34 MARILL. Post: `EVENT_BEAT_SWIMMERM_CAMERON`, +272 money.
12. `ROUTE_20`: optional sign at (37,11). Then step onto warp 1 at (38,7) ->
    `SEAFOAM_GYM (6,4)`.
13. `SEAFOAM_GYM`: walk to `SEAFOAMGYM_BLAINE` at (5,2) and talk.
    Pre: `ENGINE_VOLCANOBADGE` clear (otherwise you get `.FightDone` only).
    Battle: `loadtrainer BLAINE, BLAINE1` - L45 MAGCARGO / L45 MAGMAR / L50 RAPIDASH,
    AI holds MAX_POTION + FULL_HEAL.
    Post: `EVENT_BEAT_BLAINE` set, `EVENT_SEAFOAM_GYM_GYM_GUIDE` cleared (guide appears
    at (6,5)), **`ENGINE_VOLCANOBADGE` set**, +5000 money. No TM, no item.
14. `SEAFOAM_GYM`: optional - talk to `SEAFOAMGYM_GYM_GUIDE` at (6,5).
    Post: `EVENT_TALKED_TO_SEAFOAM_GYM_GUIDE_ONCE`.
15. `SEAFOAM_GYM`: exit via warp 1 at (5,5) back to `ROUTE_20` warp 1.

Follow-up (next section): Route 20 continues east past Lori (45,13) and Nicole (52,8)
into `ROUTE_19`, whose rock blocks are now gone because step 10 set
`EVENT_CINNABAR_ROCKS_CLEARED`.

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Kanto map headers, dimensions, connections, warp / coord / bg / object tables | `src/import/RomExtractorGen2.lua` (all 26 map groups, `MAP_GROUP_COUNT = 26` at `:47`, `MapGroupPointers` walk at `:728`) | implemented - fully data-driven, nothing Cinnabar-specific needed |
| `MAPCALLBACK_NEWMAP` (`CinnabarIslandFlypointCallback`, `Route20ClearRocksCallback`) | `src/world/gen2/World.lua:5659` `self:runMapCallback("MAPCALLBACK_NEWMAP")`, in `HandleNewMap` order (`:5646`) | implemented; asserted end-to-end by `tests/drivers/gold_map_callbacks.lua` |
| `MAPCALLBACK_TILES` + `changeblock` (the Route 19 rocks that this section unseals) | `src/world/gen2/World.lua:5662`; `changeblock` opcode at `src/script/gen2/Opcodes.lua:127` | implemented |
| `setflag ENGINE_FLYPOINT_CINNABAR` -> flyable | `src/world/gen2/FieldMoves.lua:367` (`LANDMARK_CINNABAR_ISLAND` / `SPAWN_CINNABAR` / flag 62), `World:setEngineFlag` at `src/world/gen2/World.lua:1326` | implemented |
| `checkevent` / `setevent` / `clearevent`, `checkflag` / `setflag` | `src/script/gen2/Vm.lua:187-229` | implemented - id-keyed stores, `engineFlags` kept separate from `wEventFlags` |
| `appear` / `disappear` writing the object's event flag (Blue vanishing, the guide arriving) | `src/script/gen2/Opcodes.lua:115-116`, handled in `src/script/gen2/Vm.lua` | implemented |
| Hidden item `BGEVENT_ITEM` (Cinnabar RARE_CANDY at 9,1) | `src/world/gen2/HiddenItems.lua` (`BGEVENT_ITEM = 7` at `:22`), extractor branch at `src/import/RomExtractorGen2.lua:2986` | implemented |
| `loadtrainer` / `startbattle` / `winlosstext` / `reloadmapafterbattle` / `endifjustbattled` (the whole Blaine script) | `src/script/gen2/Vm.lua:806`, `:817`, `:886`, `:918` | implemented, incl. the `iftrue` on `wBattleResult` that guards `appear SEAFOAMGYM_GYM_GUIDE` |
| Gym-leader battle music / victory music for BLAINE | `src/battle/gen2/BattleMusic.lua:21`, `src/battle/gen2/Battle.lua:82` (both list `BLAINE = true`) | implemented |
| Prize money = base x last-mon level x 4 (560 / 1360 / 256 / 272 / 5000) | `src/battle/gen2/Prize.lua` (header documents `ComputeTrainerReward` and the `ld c, 4` loop; `Prize.reward`) | implemented, incl. the Mom's-savings split |
| Trainer sight radii (3 / 4 / 1 on Route 21) | `src/world/gen2/Trainers.lua` | implemented |
| SURF gate on FOGBADGE + party move | `src/world/gen2/FieldMoves.lua:106` (`SURF = "FOG"`), `:481` `surfFromMenu`, `:678` overworld path | implemented; driven by `tests/drivers/gold_water_moves.lua` |
| Ocean wild/fish tables for Routes 20/21 | extracted by `src/import/RomExtractorGen2.lua`, consumed by `src/battle/gen2/Encounter.lua` | implemented - correct by construction from the ROM |
| Radio "Place & Name" un-hiding BLAINE after the Kanto badge sweep | `src/ui/gen2/Pokegear.lua:172` (`PNP_HIDDEN`), `:178` `PNP_HIDDEN_BEAT_KANTO`, `:1265` | implemented |
| `setflag ENGINE_VOLCANOBADGE` reaching the trainer card / `VAR_BADGES` count | `src/script/gen2/Vm.lua:208-229` writes `save.engineFlags[53]`; but `VAR_BADGES` (`src/world/gen2/World.lua:1243-1244`) counts `save.player.badges` + `save.player.kantoBadges`, and `src/ui/gen2/TrainerCard.lua:395` reads `player.badges`. Nothing in `src/` ever writes `player.kantoBadges` (only initialised at `src/core/gen2/Save.lua:119`). | **partial** - Blaine's own re-talk guard works (same `engineFlags` id is read back by `checkflag`), but the badge does not show on the trainer card and does not increment `VAR_BADGES` |
| `BadgeTypeBoosts` (VOLCANOBADGE = +12.5% FIRE damage) | no Gen 2 implementation - `grep -rn "badge" src/battle/gen2/` returns nothing; the only badge-boost code is the Gen 1 `src/battle/Damage.lua:35` | **missing** |
| `teleport_from` (`$4c`) movement for Blue's exit | `src/script/gen2/Movement.lua:22` `decodeByte` - `$4c` matches no family branch and falls through to `{ kind = "nop" }` | **partial** - Blue disappears with the sound but without the rise-and-vanish animation |
| End-to-end driver coverage for this stretch | `tests/drivers/gold_*.lua` (25 drivers, all Johto: boot, walk, warp, trainer, ice path, roamers, ...) | **missing** - no Cinnabar / Route 20 / Route 21 / Seafoam Gym driver exists |

## 6. Unresolved / verify by hand

- **Blaine's movesets in the walkthrough are not the pokegold movesets.** The FAQ
  describes Magcargo with Yawn / Recover / Overheat, Magmar with Confuse Ray, and
  Rapidash with Flare Blitz / Bounce. `data/trainers/parties.asm:2303-2308` gives
  MAGCARGO (CURSE, SMOG, FLAMETHROWER, ROCK_SLIDE), MAGMAR (THUNDERPUNCH, FIRE_PUNCH,
  SUNNY_DAY, CONFUSE_RAY) and RAPIDASH (QUICK_ATTACK, FIRE_SPIN, FURY_ATTACK,
  FIRE_BLAST). Only CONFUSE_RAY overlaps; Overheat, Flare Blitz, Bounce and Yawn do not
  exist in `constants/move_constants.asm` at all for this generation. **Species and
  levels match exactly** (L45 / L45 / L50), so treat the strategy prose as written
  against a different (modernised) build and the asm as authoritative.
- **"Blaine will have two Full Restores available."** `data/trainers/attributes.asm:276`
  is `db MAX_POTION, FULL_HEAL`. Two different items, neither of them a Full Restore.
  The count of *uses* is AI-driven, not a fixed two.
- **"You now have 15 badges!"** Nothing in the asm counts badges as an ordinal; Kanto
  gyms have no enforced order (`ENGINE_VOLCANOBADGE` is one bit,
  `constants/engine_flags.asm:53`). The 15 is walkthrough prose that assumes a specific
  visiting order.
- **Route 21 wild list is abridged in the walkthrough.** The FAQ lists Tentacool and
  Tangela. `data/wild/kanto_grass.asm:1005` also has **MR__MIME** in all three
  time slots, and `data/wild/kanto_water.asm:61` also has **TENTACRUEL**. Route 20's
  list is likewise incomplete (TENTACRUEL is there too).
- **"Surf south on Route 21 ... head way left then down."** The trainer coordinates
  confirm the shape of the route (16 -> 22 -> 30, then far west), but the actual walkable
  water path is block data in `maps/Route21.blk` and was not decoded here.
- **"You should see a small cave at the Seafoam Islands."** The only asm anchor is
  `warp_event 38, 7` on `maps/Route20.asm:117` plus `bg_event 37, 11` for the gym sign.
  The cave mouth graphic itself is block data in `maps/Route20.blk`; there is no
  Seafoam Islands dungeon map in Gen 2 (`constants/map_constants.asm` has only
  `SEAFOAM_GYM`), so the walkthrough's "Seafoam Islands" is a landmark name
  (`data/maps/landmarks.asm:94` `LANDMARK_SEAFOAM_ISLANDS`) rather than a walkable
  dungeon.
- **EXP figures.** The per-mon EXP numbers in the FAQ (600 for a L28 Seel, 1056 for a
  L28 Dewgong, 1492 for a L34 Tentacruel) are consistent with the vanilla
  `base_exp * level / 7` times the 1.5x trainer-battle bonus, but nothing in
  `data/trainers/parties.asm` stores them and they still vary with participation, so
  they are not reproducible from the asm as written. The **money** figures all reproduce
  exactly and are recorded above.
- **`EVENT_BEAT_BLAINE` has no reader.** Grepping `maps/`, `data/`, `engine/`, `home/`
  and `constants/` finds it only at its definition (`constants/event_flags.asm:721`) and
  its single `setevent` (`maps/SeafoamGym.asm:29`). If the port needs a "Blaine beaten"
  predicate for anything, `ENGINE_VOLCANOBADGE` is the flag the cart actually branches on.

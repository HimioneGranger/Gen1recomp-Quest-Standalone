# Section 24 - Snorlax and Pewter City Gym

Source: `../section-24-snorlax-and-pewter-city-gym.txt`
(the FAQ numbers this chapter "30 > Snorlax and Pewter City Gym"; the file index
is 24)

Maps covered: `MAP_ROUTE_19`, `MAP_ROUTE_19_FUCHSIA_GATE`, `MAP_VERMILION_CITY`,
`MAP_VERMILION_POKECENTER_1F`, `MAP_DIGLETTS_CAVE`, `MAP_ROUTE_2`,
`MAP_ROUTE_2_NUGGET_HOUSE`, `MAP_ROUTE_2_GATE`, `MAP_PEWTER_CITY`,
`MAP_PEWTER_POKECENTER_1F`, `MAP_PEWTER_GYM`

Badges / key milestones in this section:

- Level 50 **SNORLAX** caught in Vermilion City, holding LEFTOVERS
  (`BATTLETYPE_FORCEITEM`); clearing it opens the DIGLETT'S CAVE door
- **SILVER_WING** (Gold) / **RAINBOW_WING** (Silver) from the Pewter City gramps
- **NUGGET** from the Route 2 house
- CARBOS, DIRE_HIT, ELIXER, MAX_POTION item balls on Route 2
- **BOULDERBADGE** from BROCK (`ENGINE_BOULDERBADGE`)

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 0 | `FUCHSIA_CITY` | - | previous section | south connection, or `ROUTE_19_FUCHSIA_GATE` warps 1/2 at (4,0)/(5,0) | **Belongs to the previous section**; only the hop south is listed |
| 1 | `ROUTE_19_FUCHSIA_GATE` | `maps/Route19FuchsiaGate.asm` | warps 1/2 at (4,0)/(5,0) from `FUCHSIA_CITY` 10/11 | warps 3/4 at (4,7)/(5,7) -> `ROUTE_19` 1 | Officer explains why Route 19 is shut |
| 2 | `ROUTE_19` | `maps/Route19.asm` | warp 1 at (7,3) from the gate | dead end - back through warp 1 | **Blocked.** `Route19ClearRocksCallback` paints six boulders while `EVENT_CINNABAR_ROCKS_CLEARED` is clear |
| 3 | `VERMILION_CITY` | `maps/VermilionCity.asm` | FLY (`ENGINE_FLYPOINT_VERMILION`, set by `VermilionCityFlypointCallback`) | warp 10 at (34,7) -> `DIGLETTS_CAVE` 1 | Wake and battle the SNORLAX at (34,8) with the POKe FLUTE radio channel |
| 4 | `VERMILION_POKECENTER_1F` | `maps/VermilionPokecenter1F.asm` | city warp 2 at (9,5) | warps 1/2 at (3,7)/(4,7) back | Heal and withdraw the caught SNORLAX |
| 5 | `DIGLETTS_CAVE` | `maps/DiglettsCave.asm` | warp 1 at (3,33) from `VERMILION_CITY` 10 | warp 3 at (15,5) -> `ROUTE_2` 5 | Ladder chain 2->5, long cave, ladder 6->4, then the door |
| 6 | `ROUTE_2` | `maps/Route2.asm` | warp 5 at (12,7) from `DIGLETTS_CAVE` 3 | north connection to `PEWTER_CITY` | Carbos, Nugget house, Elixer, three Bug Catchers, two cut trees |
| 7 | `ROUTE_2_NUGGET_HOUSE` | `maps/Route2NuggetHouse.asm` | Route 2 warp 1 at (15,15) | warps 1/2 at (2,7)/(3,7) back | `Route2NuggetHouseFisherScript` -> `verbosegiveitem NUGGET` |
| 8 | `ROUTE_2_GATE` | `maps/Route2Gate.asm` | Route 2 warps 3/4 at (16,27)/(17,27) | warps 3/4 at (4,7)/(5,7) -> `ROUTE_2` 2 at (15,31) | The "route-changing house" that drops you further south on the same route |
| 9 | `PEWTER_CITY` | `maps/PewterCity.asm` | south connection from `ROUTE_2` (`connection north, PewterCity, PEWTER_CITY, -5`) | five warps, see below | Sets `ENGINE_FLYPOINT_PEWTER`; gramps hands over the wing |
| 10 | `PEWTER_POKECENTER_1F` | `maps/PewterPokecenter1F.asm` | city warp 4 at (13,25) | warps 1/2 at (3,7)/(4,7) back | Heal; `Chris` runs `trade NPC_TRADE_CHRIS` (GLOOM -> RAPIDASH) |
| 11 | `PEWTER_GYM` | `maps/PewterGym.asm` | city warp 2 at (16,17) | warps 1/2 at (4,13)/(5,13) back | Camper Jerry, then **BROCK** for the BOULDERBADGE |

Spillover: the FAQ's video-link header also names Tin Tower, Ho-Oh, Routes 1-4
and Pallet Town. Nothing in the prose of this section enters those maps - the
Routes 3/4 and Pallet beats belong to the following section and are not covered
here.

---

## 2. Maps

### MAP_ROUTE_19

- Script: `maps/Route19.asm`
- Blocks: `maps/Route19.blk`
- Header: `data/maps/maps.asm:196` -> `TILESET_KANTO, ROUTE, LANDMARK_ROUTE_19, MUSIC_ROUTE_3, FALSE (phone allowed), PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:180` `map_const ROUTE_19, 10, 18` (group `CINNABAR`, id 5) = 20 x 36 cells
- Attributes / border: `data/maps/attributes.asm:287` `map_attributes Route19, ROUTE_19, $43`
- Connections: `connection north, FuchsiaCity, FUCHSIA_CITY, 0`; `connection west, Route20, ROUTE_20, 9`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 7 | 3 | `ROUTE_19_FUCHSIA_GATE` | 3 |

**Coord events** (`def_coord_events`)

none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 11 | 13 | `BGEVENT_READ` | `Route19Sign` |
| 11 | 1 | `BGEVENT_READ` | `CarefulSwimmingSign` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE19_SWIMMER_GIRL` | `SPRITE_SWIMMER_GIRL` | 9 | 23 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 0) | `TrainerSwimmerfDawn` | -1 |
| `ROUTE19_SWIMMER_GUY1` | `SPRITE_SWIMMER_GUY` | 13 | 28 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerSwimmermHarold` | -1 |
| `ROUTE19_SWIMMER_GUY2` | `SPRITE_SWIMMER_GUY` | 11 | 17 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerSwimmermJerome` | -1 |
| `ROUTE19_SWIMMER_GUY3` | `SPRITE_SWIMMER_GUY` | 8 | 23 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` (sight 0) | `TrainerSwimmermTucker` | -1 |
| `ROUTE19_FISHER1` | `SPRITE_FISHER` | 9 | 5 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` (sight 1) | `Route19Fisher1Script` | -1 |
| `ROUTE19_FISHER2` | `SPRITE_FISHER` | 11 | 5 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius 1,0) | `OBJECTTYPE_SCRIPT` (sight 1) | `Route19Fisher2Script` | -1 |

**Scripts of interest**

- `Route19ClearRocksCallback` (`callback MAPCALLBACK_TILES`). `checkevent
  EVENT_CINNABAR_ROCKS_CLEARED` / `iftrue .Done`; otherwise it runs six
  `changeblock` writes that lay a rock block (`$7a`) over block coordinates
  `(6,6) (8,6) (10,6) (12,8) (4,8) (10,10)`. This is the wall the FAQ hits.
  Block coordinates, so the blocked cells are `x = 2*bx .. 2*bx+1`,
  `y = 2*by .. 2*by+1`.
- `Route19Fisher1Script` / `Route19Fisher2Script` both branch on
  `EVENT_CINNABAR_ROCKS_CLEARED` for flavour text only. Neither one clears the
  rocks - see "Blockers and gates".

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_CINNABAR_ROCKS_CLEARED` | `constants/event_flags.asm:214` | read by `Route19ClearRocksCallback`, `Route19Fisher1Script`, `Route19Fisher2Script`, `Route19FuchsiaGateOfficerScript`; **set** by `Route20ClearRocksCallback` (`maps/Route20.asm:13`, `MAPCALLBACK_NEWMAP`) | Route 19 stays blocked until the player has stood on Route 20, which is reached from the Cinnabar side (Pallet -> Route 21 -> Cinnabar -> Route 20) |

**Items** - none on this map.

**Trainers** - four Swimmers, all reachable only by Surf and all beyond the
boulders in the FAQ's play order; not part of this section's critical path.

---

### MAP_ROUTE_19_FUCHSIA_GATE

- Script: `maps/Route19FuchsiaGate.asm`
- Header: `data/maps/maps.asm:194` -> `TILESET_GATE, GATE, LANDMARK_ROUTE_19, MUSIC_ROUTE_3, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:178` `map_const ROUTE_19_FUCHSIA_GATE, 5, 4` (group `CINNABAR`, id 3)
- Attributes: `data/maps/attributes.asm:512` `map_attributes Route19FuchsiaGate, ROUTE_19_FUCHSIA_GATE, $00`; no connections

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 0 | `FUCHSIA_CITY` | 10 |
| 2 | 5 | 0 | `FUCHSIA_CITY` | 11 |
| 3 | 4 | 7 | `ROUTE_19` | 1 |
| 4 | 5 | 7 | `ROUTE_19` | 1 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE19FUCHSIAGATE_OFFICER` | `SPRITE_OFFICER` | 0 | 4 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `Route19FuchsiaGateOfficerScript` | -1 |

**Scripts of interest**

- `Route19FuchsiaGateOfficerScript`: `checkevent EVENT_CINNABAR_ROCKS_CLEARED`,
  two text branches. Pure flavour; the officer does not gate the warp.

---

### MAP_VERMILION_CITY

- Script: `maps/VermilionCity.asm`
- Blocks: `maps/VermilionCity.blk`
- Header: `data/maps/maps.asm:296` -> `TILESET_KANTO, TOWN, LANDMARK_VERMILION_CITY, MUSIC_VERMILION_CITY, FALSE, PALETTE_AUTO, FISHGROUP_OCEAN`
- Dimensions: `constants/map_constants.asm:273` `map_const VERMILION_CITY, 20, 18` (group `VERMILION`, id 3) = 40 x 36 cells
- Attributes: `data/maps/attributes.asm:342` `map_attributes VermilionCity, VERMILION_CITY, $43`
- Connections: `connection north, Route6, ROUTE_6, 5`; `connection east, Route11, ROUTE_11, 0`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 5 | `VERMILION_FISHING_SPEECH_HOUSE` | 1 |
| 2 | 9 | 5 | `VERMILION_POKECENTER_1F` | 1 |
| 3 | 7 | 13 | `POKEMON_FAN_CLUB` | 1 |
| 4 | 13 | 13 | `VERMILION_MAGNET_TRAIN_SPEECH_HOUSE` | 1 |
| 5 | 21 | 13 | `VERMILION_MART` | 2 |
| 6 | 21 | 17 | `VERMILION_DIGLETTS_CAVE_SPEECH_HOUSE` | 1 |
| 7 | 10 | 19 | `VERMILION_GYM` | 1 |
| 8 | 19 | 31 | `VERMILION_PORT_PASSAGE` | 1 |
| 9 | 20 | 31 | `VERMILION_PORT_PASSAGE` | 2 |
| 10 | 34 | 7 | `DIGLETTS_CAVE` | 1 |

**Coord events** (`def_coord_events`) - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 25 | 3 | `BGEVENT_READ` | `VermilionCitySign` |
| 5 | 19 | `BGEVENT_READ` | `VermilionGymSign` |
| 5 | 13 | `BGEVENT_READ` | `PokemonFanClubSign` |
| 33 | 9 | `BGEVENT_READ` | `VermilionCityDiglettsCaveSign` |
| 27 | 15 | `BGEVENT_READ` | `VermilionCityPortSign` |
| 10 | 5 | `BGEVENT_READ` | `VermilionCityPokecenterSign` (`jumpstd PokecenterSignScript`) |
| 22 | 13 | `BGEVENT_READ` | `VermilionCityMartSign` (`jumpstd MartSignScript`) |
| 12 | 19 | `BGEVENT_ITEM` | `VermilionCityHiddenFullHeal` -> `hiddenitem FULL_HEAL, EVENT_VERMILION_CITY_HIDDEN_FULL_HEAL` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VERMILIONCITY_TEACHER` | `SPRITE_TEACHER` | 18 | 9 | `SPRITEMOVEDATA_WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `VermilionCityTeacherScript` | -1 |
| `VERMILIONCITY_GRAMPS` | `SPRITE_GRAMPS` | 23 | 6 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `VermilionMachopOwner` | -1 |
| `VERMILIONCITY_MACHOP` | `SPRITE_MACHOP` | 26 | 7 | `SPRITEMOVEDATA_POKEMON` | `OBJECTTYPE_SCRIPT` | `VermilionMachop` | -1 |
| `VERMILIONCITY_SUPER_NERD` | `SPRITE_SUPER_NERD` | 14 | 16 | `SPRITEMOVEDATA_WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `VermilionCitySuperNerdScript` | -1 |
| `VERMILIONCITY_BIG_SNORLAX` | `SPRITE_BIG_SNORLAX` | 34 | 8 | `SPRITEMOVEDATA_BIGDOLLSYM` | `OBJECTTYPE_SCRIPT` | `VermilionSnorlax` | `EVENT_VERMILION_CITY_SNORLAX` |
| `VERMILIONCITY_POKEFAN_M` | `SPRITE_POKEFAN_M` | 31 | 12 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `VermilionGymBadgeGuy` | -1 |

Note the object-flag polarity (`CheckObjectFlag`,
`engine/overworld/map_objects_2.asm:32`): an object with an `EVENT_*` flag is
**masked when the flag is set**. So the SNORLAX is present only while
`EVENT_VERMILION_CITY_SNORLAX` is clear, and `disappear` is what sets it.

**Scripts of interest**

- `VermilionSnorlax` (`4f:5291`). `opentext` -> `special SnorlaxAwake` ->
  `iftrue .Awake`. Asleep branch writes `VermilionCitySnorlaxSleepingText` and
  ends. `.Awake` writes `VermilionCityRadioNearSnorlaxText`, `pause 15`,
  `cry SNORLAX`, then
  `loadvar VAR_BATTLETYPE, BATTLETYPE_FORCEITEM` /
  `loadwildmon SNORLAX, 50` / `startbattle` /
  `disappear VERMILIONCITY_BIG_SNORLAX` / `setevent EVENT_FOUGHT_SNORLAX` /
  `reloadmapafterbattle`.
  The `disappear` and `setevent` run **unconditionally after the battle**, so a
  fled-from or fainted Snorlax is still gone: catching it is a one-shot.
- `SnorlaxAwake` (`engine/events/specials.asm:358`, symbol `03:45d6`). Returns
  `TRUE` only when *both* hold:
  1. `[wMapMusic] == MUSIC_POKE_FLUTE_CHANNEL`;
  2. the player stands on one of `.ProximityCoords`
     (`engine/events/specials.asm:399`): `(33,8) (34,10) (35,10) (36,8) (36,9)`.
  The POKe FLUTE channel is the Pokegear radio at knob 78 / "20.0"
  (`engine/pokegear/pokegear.asm:1447`, `.PokeFluteRadio` at 1487): it needs
  **not-Johto** and `POKEGEAR_EXPN_CARD_F` in `wPokegearFlags`. Tuning the radio
  and closing the Pokegear leaves that song as `wMapMusic`.
- `VermilionGymBadgeGuy`: `checkevent EVENT_GOT_HP_UP_FROM_VERMILION_GUY`, then
  `readvar VAR_BADGES` with `ifequal NUM_BADGES` / `ifgreater 13` /
  `ifgreater 9`. `verbosegiveitem HP_UP` only at all 16 badges. Not this
  section's business, but a bot walking Vermilion will trip the text.
- `VermilionCityFlypointCallback` (`MAPCALLBACK_NEWMAP`):
  `setflag ENGINE_FLYPOINT_VERMILION`. This is what makes the FAQ's "fly back to
  Vermilion City" legal - it must already have been visited on foot.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_VERMILION_CITY_SNORLAX` | `constants/event_flags.asm:1298` | object flag on `VERMILIONCITY_BIG_SNORLAX`; set by `disappear` in `VermilionSnorlax` | clear = Snorlax on the map; set = gone, cave door walkable |
| `EVENT_FOUGHT_SNORLAX` | `constants/event_flags.asm:1266` | set by `VermilionSnorlax`; read by `VermilionPokecenter1FFishingGuruScript` (`maps/VermilionPokecenter1F.asm:18`) and used as the object flag of the right Black Belt in `maps/VictoryRoadGate.asm:119` | "the Snorlax encounter has happened" |
| `ENGINE_FLYPOINT_VERMILION` | `constants/engine_flags.asm:72` | `VermilionCityFlypointCallback` | Fly destination unlocked |
| `POKEGEAR_EXPN_CARD_F` | `constants/ram_constants.asm:280` | read by `.PokeFluteRadio` | without the EXPN CARD the flute channel is static and `SnorlaxAwake` can never be true |
| `EVENT_VERMILION_CITY_HIDDEN_FULL_HEAL` | `constants/event_flags.asm:252` | `VermilionCityHiddenFullHeal` | hidden FULL_HEAL at (12,19) |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `LEFTOVERS` | attached to the wild SNORLAX | `data/pokemon/base_stats/snorlax.asm:9` `db LEFTOVERS, LEFTOVERS` forced by `BATTLETYPE_FORCEITEM` (`engine/battle/core.asm:5771`) | - |
| `FULL_HEAL` | hidden | `bg_event 12, 19, BGEVENT_ITEM, VermilionCityHiddenFullHeal` | `EVENT_VERMILION_CITY_HIDDEN_FULL_HEAL` |

**Wild encounters** - the scripted SNORLAX is not a table entry; it is
`loadwildmon SNORLAX, 50`. Level 50 learnset from
`data/pokemon/evos_attacks.asm:1932`: the four most recent are SNORE (36),
REST (36), BODY_SLAM (43), ROLLOUT (50) - which is exactly the FAQ's "Rest" and
"Rollout". Catch rate 25, base exp 154 (`data/pokemon/base_stats/snorlax.asm`).

---

### MAP_VERMILION_POKECENTER_1F

- Script: `maps/VermilionPokecenter1F.asm`
- Header: `data/maps/maps.asm` (`VERMILION` group); dimensions
  `constants/map_constants.asm:275` `map_const VERMILION_POKECENTER_1F, 5, 4`

Only the one script matters here:

- `VermilionPokecenter1FFishingGuruScript`: `checkevent EVENT_FOUGHT_SNORLAX`,
  two text branches ("A sleeping #MON is lying in front of DIGLETT'S CAVE" ->
  after-text). It is a read-only confirmation that the Snorlax beat is done; the
  PC withdraw the FAQ asks for is the standard `POKECENTER_2F` / PC menu, not a
  map script.

---

### MAP_DIGLETTS_CAVE

- Script: `maps/DiglettsCave.asm`
- Blocks: `maps/DiglettsCave.blk` (180 bytes = 10 x 18 blocks)
- Header: `data/maps/maps.asm:153` -> `TILESET_CAVE, CAVE, LANDMARK_DIGLETTS_CAVE, MUSIC_MT_MOON, TRUE (no phone), PALETTE_NITE, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:140` `map_const DIGLETTS_CAVE, 10, 18` (group `DUNGEONS`, id 75) = 20 x 36 cells
- Attributes: `data/maps/attributes.asm:487` `map_attributes DiglettsCave, DIGLETTS_CAVE, $09`; no connections

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 33 | `VERMILION_CITY` | 10 |
| 2 | 5 | 31 | `DIGLETTS_CAVE` | 5 |
| 3 | 15 | 5 | `ROUTE_2` | 5 |
| 4 | 17 | 3 | `DIGLETTS_CAVE` | 6 |
| 5 | 17 | 33 | `DIGLETTS_CAVE` | 2 |
| 6 | 3 | 3 | `DIGLETTS_CAVE` | 4 |

Warps 2<->5 and 4<->6 are the two internal ladders. Reading `DiglettsCave.blk`
against `data/tilesets/kanto_collision.asm` (block `$1f`/`$1b` = ladder, `$24` =
door) the map is three disconnected pockets:

- pocket A (bottom-left, blocks (1,15)-(2,17)): warp 1 (VERMILION door) + warp 2
  (ladder);
- pocket B (the long cave): warp 5 at (17,33) up to warp 6 at (3,3);
- pocket C (top-right, blocks (7,1)-(8,3)): warp 4 (ladder) + warp 3 (ROUTE_2
  door).

So the traversal is: `(3,33)` -> ladder `(5,31)` -> emerge `(17,33)` -> walk the
long cave to `(3,3)` -> ladder -> emerge `(17,3)` -> door `(15,5)` -> Route 2
`(12,7)`. That is exactly the FAQ's "down the ladder, ride up, up that ladder,
exit the door".

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 6 | 11 | `BGEVENT_ITEM` | `DiglettsCaveHiddenMaxRevive` -> `hiddenitem MAX_REVIVE, EVENT_DIGLETTS_CAVE_HIDDEN_MAX_REVIVE` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `DIGLETTSCAVE_POKEFAN_M` | `SPRITE_POKEFAN_M` | 3 | 31 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `DiglettsCavePokefanMScript` | -1 |

**Trainers** - none, matching the FAQ.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `MAX_REVIVE` | hidden (ITEMFINDER / bump) | `bg_event 6, 11, BGEVENT_ITEM` | `EVENT_DIGLETTS_CAVE_HIDDEN_MAX_REVIVE` (`constants/event_flags.asm:228`) |

**Wild encounters** - `data/wild/kanto_grass.asm:5` `def_grass_wildmons
DIGLETTS_CAVE`, rates `4 / 2 / 8` percent (morn/day/nite). All three time slots
carry the same seven rows:

| slot | level | species |
|---|---|---|
| 1 | 15 | DIGLETT |
| 2 | 17 | DIGLETT |
| 3 | 19 | DIGLETT |
| 4 | 13 | DIGLETT |
| 5 | 19 | DUGTRIO |
| 6 | 24 | DUGTRIO |
| 7 | 29 | DUGTRIO |

The FAQ's "capture both Diglett and Dugtrio here" is correct, and night is the
best time (8% vs 2% by day).

The FAQ's "ride your bike" is legal here: `BikeFunction`'s `.CheckEnvironment`
(`engine/events/overworld.asm:1665`) allows outdoor maps, `CAVE` and `GATE`.

---

### MAP_ROUTE_2

- Script: `maps/Route2.asm`
- Blocks: `maps/Route2.blk` (270 bytes = 10 x 27 blocks)
- Header: `data/maps/maps.asm:455` -> `TILESET_KANTO, ROUTE, LANDMARK_ROUTE_2, MUSIC_ROUTE_2, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:421` `map_const ROUTE_2, 10, 27` (group `VIRIDIAN`, id 1) = 20 x 54 cells
- Attributes: `data/maps/attributes.asm:255` `map_attributes Route2, ROUTE_2, $0f`
- Connections: `connection north, PewterCity, PEWTER_CITY, -5`;
  `connection south, ViridianCity, VIRIDIAN_CITY, -5`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 15 | 15 | `ROUTE_2_NUGGET_HOUSE` | 1 |
| 2 | 15 | 31 | `ROUTE_2_GATE` | 3 |
| 3 | 16 | 27 | `ROUTE_2_GATE` | 1 |
| 4 | 17 | 27 | `ROUTE_2_GATE` | 2 |
| 5 | 12 | 7 | `DIGLETTS_CAVE` | 3 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 7 | 51 | `BGEVENT_READ` | `Route2Sign` |
| 11 | 9 | `BGEVENT_READ` | `Route2DiglettsCaveSign` |
| 7 | 23 | `BGEVENT_ITEM` | `Route2HiddenMaxEther` -> `hiddenitem MAX_ETHER, EVENT_ROUTE_2_HIDDEN_MAX_ETHER` |
| 4 | 14 | `BGEVENT_ITEM` | `Route2HiddenFullHeal` -> `hiddenitem FULL_HEAL, EVENT_ROUTE_2_HIDDEN_FULL_HEAL` |
| 4 | 27 | `BGEVENT_ITEM` | `Route2HiddenFullRestore` -> `hiddenitem FULL_RESTORE, EVENT_ROUTE_2_HIDDEN_FULL_RESTORE` |
| 11 | 30 | `BGEVENT_ITEM` | `Route2HiddenRevive` -> `hiddenitem REVIVE, EVENT_ROUTE_2_HIDDEN_REVIVE` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE2_BUG_CATCHER1` | `SPRITE_BUG_CATCHER` | 10 | 45 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 5) | `TrainerBugCatcherRob` | -1 |
| `ROUTE2_BUG_CATCHER2` | `SPRITE_BUG_CATCHER` | 5 | 5 | `SPRITEMOVEDATA_STANDING_RIGHT` (radius 1,0) | `OBJECTTYPE_TRAINER` (sight 4) | `TrainerBugCatcherEd` | -1 |
| `ROUTE2_BUG_CATCHER3` | `SPRITE_BUG_CATCHER` | 4 | 43 | `SPRITEMOVEDATA_STANDING_UP` (radius 1,0) | `OBJECTTYPE_TRAINER` (sight 5) | `TrainerBugCatcherDoug` | -1 |
| `ROUTE2_POKE_BALL1` | `SPRITE_POKE_BALL` | 0 | 29 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `Route2DireHit` (`itemball DIRE_HIT`) | `EVENT_ROUTE_2_DIRE_HIT` |
| `ROUTE2_POKE_BALL2` | `SPRITE_POKE_BALL` | 2 | 23 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `Route2MaxPotion` (`itemball MAX_POTION`) | `EVENT_ROUTE_2_MAX_POTION` |
| `ROUTE2_POKE_BALL3` | `SPRITE_POKE_BALL` | 19 | 2 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `Route2Carbos` (`itemball CARBOS`) | `EVENT_ROUTE_2_CARBOS` |
| `ROUTE2_POKE_BALL4` | `SPRITE_POKE_BALL` | 14 | 50 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `Route2Elixer` (`itemball ELIXER`) | `EVENT_ROUTE_2_ELIXER` |
| `ROUTE2_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 10 | 14 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `Route2FruitTree` (`fruittree FRUITTREE_ROUTE_2`) | -1 |

**Cut trees** (not asm rows - decoded from `maps/Route2.blk` against the
`CUT_TREE` entries of `data/tilesets/kanto_collision.asm`, which are blocks
`$00 $32 $33 $34 $35 $60`)

| block (bx,by) | block id | covered cells (x, y) | which FAQ beat |
|---|---|---|---|
| (2, 4) | `$32` | 4-5, 8-9 | near the Diglett's Cave door, not used by the FAQ |
| (7, 9) | `$32` | 14-15, 18-19 | "cut the tree to the south" (just below the Nugget house at (15,15)) |
| (5, 20) | `$34` | 10-11, 40-41 | not named by the FAQ |
| (6, 23) | `$34` | 12-13, 46-47 | not named by the FAQ |
| (6, 25) | `$34` | 12-13, 50-51 | "cut the tree just left of it" (immediately left of the Elixer at (14,50)) |

**Scripts of interest**

- `TrainerBugCatcherRob` / `TrainerBugCatcherEd` / `TrainerBugCatcherDoug`
  (`4d:5bc2`, `4d:5bd6`, `4d:5bea`): each is the plain `trainer CLASS, MEMBER,
  EVENT_*, seen, beaten, 0, .Script` header with an `endifjustbattled` +
  after-battle text body. No items, no flags beyond the beaten event.
- `Route2FruitTree`: `fruittree FRUITTREE_ROUTE_2` ->
  `data/items/fruit_trees.asm:28` `db PSNCUREBERRY`. This is the FAQ's
  "PSNCure Berry".

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ROUTE_2_DIRE_HIT` | `constants/event_flags.asm:1318` | item ball object flag | clear = ball present |
| `EVENT_ROUTE_2_MAX_POTION` | `constants/event_flags.asm:1319` | item ball object flag | clear = ball present |
| `EVENT_ROUTE_2_CARBOS` | `constants/event_flags.asm:1320` | item ball object flag | clear = ball present |
| `EVENT_ROUTE_2_ELIXER` | `constants/event_flags.asm:1321` | item ball object flag | clear = ball present |
| `EVENT_ROUTE_2_HIDDEN_MAX_ETHER` | `constants/event_flags.asm:237` | `Route2HiddenMaxEther` | hidden pickup |
| `EVENT_ROUTE_2_HIDDEN_FULL_HEAL` | `constants/event_flags.asm:238` | `Route2HiddenFullHeal` | hidden pickup |
| `EVENT_ROUTE_2_HIDDEN_FULL_RESTORE` | `constants/event_flags.asm:239` | `Route2HiddenFullRestore` | hidden pickup |
| `EVENT_ROUTE_2_HIDDEN_REVIVE` | `constants/event_flags.asm:240` | `Route2HiddenRevive` | hidden pickup |
| `EVENT_BEAT_BUG_CATCHER_ROB` | `constants/event_flags.asm:840` | `TrainerBugCatcherRob` | trainer beaten |
| `EVENT_BEAT_BUG_CATCHER_ED` | `constants/event_flags.asm:841` | `TrainerBugCatcherEd` | trainer beaten |
| `EVENT_BEAT_BUG_CATCHER_DOUG` | `constants/event_flags.asm:850` | `TrainerBugCatcherDoug` | trainer beaten |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `CARBOS` | item ball at (19,2) | `Route2Carbos` | `EVENT_ROUTE_2_CARBOS` |
| `MAX_POTION` | item ball at (2,23) | `Route2MaxPotion` | `EVENT_ROUTE_2_MAX_POTION` |
| `DIRE_HIT` | item ball at (0,29) | `Route2DireHit` | `EVENT_ROUTE_2_DIRE_HIT` |
| `ELIXER` | item ball at (14,50) | `Route2Elixer` | `EVENT_ROUTE_2_ELIXER` |
| `PSNCUREBERRY` | fruit tree object at (10,14) | `FRUITTREE_ROUTE_2`, `data/items/fruit_trees.asm:28` | daily reset, not an event flag |
| `MAX_ETHER` | hidden at (7,23) | bg_event | `EVENT_ROUTE_2_HIDDEN_MAX_ETHER` |
| `FULL_HEAL` | hidden at (4,14) | bg_event | `EVENT_ROUTE_2_HIDDEN_FULL_HEAL` |
| `FULL_RESTORE` | hidden at (4,27) | bg_event | `EVENT_ROUTE_2_HIDDEN_FULL_RESTORE` |
| `REVIVE` | hidden at (11,30) | bg_event | `EVENT_ROUTE_2_HIDDEN_REVIVE` |
| `NUGGET` | Route 2 Nugget House NPC | `Route2NuggetHouseFisherScript` | `EVENT_GOT_NUGGET_FROM_GUY` |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `ROB` (`constants/trainer_constants.asm:314`) | `BUG_CATCHER` | 2 | `BugCatcherGroup` "ROB" (`data/trainers/parties.asm:1416`): L32 BEEDRILL, L32 BUTTERFREE, `TRAINERTYPE_NORMAL` | `TrainerBugCatcherRob` | no |
| `DOUG` (`constants/trainer_constants.asm:324`) | `BUG_CATCHER` | 12 | `BugCatcherGroup` "DOUG" (`data/trainers/parties.asm:1482`): L34 ARIADOS | `TrainerBugCatcherDoug` | no |
| `ED` (`constants/trainer_constants.asm:315`) | `BUG_CATCHER` | 3 | `BugCatcherGroup` "ED" (`data/trainers/parties.asm:1422`): L30 BEEDRILL x3 | `TrainerBugCatcherEd` | no |

`BUG_CATCHER` base reward 4 (`data/trainers/attributes.asm:215`); prize =
base x last mon level (`ComputeTrainerReward`,
`engine/battle/read_trainer_party.asm:300`).

**Wild encounters** - `data/wild/kanto_grass.asm:259` `def_grass_wildmons
ROUTE_2`, rates `10 / 10 / 10`. Gold (`IF DEF(_GOLD)`):

| slot | morn | day | nite |
|---|---|---|---|
| 1 | L3 CATERPIE | L3 CATERPIE | L3 HOOTHOOT |
| 2 | L3 PIDGEY | L3 PIDGEY | L3 SPINARAK |
| 3 | L5 METAPOD | L5 METAPOD | L5 HOOTHOOT |
| 4 | L7 BUTTERFREE | L7 PIDGEY | L7 NOCTOWL |
| 5 | L7 PIDGEOTTO | L7 PIDGEOTTO | L7 ARIADOS |
| 6 | L4 PIKACHU | L4 PIKACHU | L4 PIKACHU |
| 7 | L4 PIKACHU | L4 PIKACHU | L4 PIKACHU |

(The Silver table under `ELIF DEF(_SILVER)` swaps the Caterpie line for
Weedle/Kakuna/Beedrill and Spinarak for Ledyba.)

---

### MAP_ROUTE_2_NUGGET_HOUSE

- Script: `maps/Route2NuggetHouse.asm`
- Header: `data/maps/maps.asm:465` -> `TILESET_HOUSE, INDOOR, LANDMARK_ROUTE_2, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:431` `map_const ROUTE_2_NUGGET_HOUSE, 4, 4`
- Attributes: `data/maps/attributes.asm:664`; no connections

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `ROUTE_2` | 1 |
| 2 | 3 | 7 | `ROUTE_2` | 1 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE2NUGGETHOUSE_FISHER` | `SPRITE_FISHER` | 2 | 4 | `SPRITEMOVEDATA_WALK_UP_DOWN` (radius 0,2) | `OBJECTTYPE_SCRIPT` | `Route2NuggetHouseFisherScript` | -1 |

**Scripts of interest**

- `Route2NuggetHouseFisherScript` (`5f:4e26`): `faceplayer` / `opentext` /
  `checkevent EVENT_GOT_NUGGET_FROM_GUY` -> `.GotNugget`; otherwise text,
  `promptbutton`, `verbosegiveitem NUGGET`, `iffalse .NoRoom`,
  `setevent EVENT_GOT_NUGGET_FROM_GUY`. A full bag skips the flag, so the gift
  is re-offerable.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_GOT_NUGGET_FROM_GUY` | `constants/event_flags.asm:199` | `Route2NuggetHouseFisherScript` | one-time NUGGET |

---

### MAP_ROUTE_2_GATE

- Script: `maps/Route2Gate.asm`
- Header: `data/maps/maps.asm:466` -> `TILESET_GATE, GATE, LANDMARK_ROUTE_2, MUSIC_ROUTE_2, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:432` `map_const ROUTE_2_GATE, 5, 4`
- Attributes: `data/maps/attributes.asm:665`; no connections

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 0 | `ROUTE_2` | 3 |
| 2 | 5 | 0 | `ROUTE_2` | 4 |
| 3 | 4 | 7 | `ROUTE_2` | 2 |
| 4 | 5 | 7 | `ROUTE_2` | 2 |

Both sides land back on Route 2 - this is the FAQ's "route-changing house...
You'll still be in Route 2". North side (y=0) <-> Route 2 (16,27)/(17,27);
south side (y=7) <-> Route 2 (15,31).

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE2GATE_SCIENTIST` | `SPRITE_SCIENTIST` | 6 | 4 | `SPRITEMOVEDATA_WALK_UP_DOWN` (radius 0,2) | `OBJECTTYPE_SCRIPT` | `Route2GateScientistScript` | -1 |

`Route2GateScientistScript` is `jumptextfaceplayer` only (Oak's aide flavour).

---

### MAP_PEWTER_CITY

- Script: `maps/PewterCity.asm`
- Blocks: `maps/PewterCity.blk`
- Header: `data/maps/maps.asm:322` -> `TILESET_KANTO, TOWN, LANDMARK_PEWTER_CITY, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:297` `map_const PEWTER_CITY, 20, 18` (group `PEWTER`, id 2) = 40 x 36 cells
- Attributes: `data/maps/attributes.asm:251` `map_attributes PewterCity, PEWTER_CITY, $0f`
- Connections: `connection south, Route2, ROUTE_2, 5`; `connection east, Route3, ROUTE_3, 5`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 29 | 13 | `PEWTER_NIDORAN_SPEECH_HOUSE` | 1 |
| 2 | 16 | 17 | `PEWTER_GYM` | 1 |
| 3 | 23 | 17 | `PEWTER_MART` | 2 |
| 4 | 13 | 25 | `PEWTER_POKECENTER_1F` | 1 |
| 5 | 7 | 29 | `PEWTER_SNOOZE_SPEECH_HOUSE` | 1 |

There is **no museum warp**: the FAQ's "they even filled the doorway in" is
literally true in the asm - the museum exists only as a sign.

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 25 | 23 | `BGEVENT_READ` | `PewterCitySign` |
| 11 | 17 | `BGEVENT_READ` | `PewterGymSign` |
| 15 | 9 | `BGEVENT_READ` | `PewterMuseumSign` ("closed for renovations") |
| 33 | 19 | `BGEVENT_READ` | `PewterCityMtMoonGiftShopSign` |
| 19 | 29 | `BGEVENT_READ` | `PewterCityWelcomeSign` |
| 14 | 25 | `BGEVENT_READ` | `PewterCityPokecenterSign` (`jumpstd PokecenterSignScript`) |
| 24 | 17 | `BGEVENT_READ` | `PewterCityMartSign` (`jumpstd MartSignScript`) |

No hidden items in Pewter City.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `PEWTERCITY_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 19 | 11 | `SPRITEMOVEDATA_WANDER` (2,2) | `OBJECTTYPE_SCRIPT` | `PewterCityCooltrainerFScript` | -1 |
| `PEWTERCITY_BUG_CATCHER` | `SPRITE_BUG_CATCHER` | 14 | 29 | `SPRITEMOVEDATA_WANDER` (2,2) | `OBJECTTYPE_SCRIPT` | `PewterCityBugCatcherScript` | -1 |
| `PEWTERCITY_GRAMPS` | `SPRITE_GRAMPS` | 29 | 17 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius 2,0) | `OBJECTTYPE_SCRIPT` | `PewterCityGrampsScript` | -1 |
| `PEWTERCITY_FRUIT_TREE1` | `SPRITE_FRUIT_TREE` | 32 | 3 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `PewterCityFruitTree1` (`fruittree FRUITTREE_PEWTER_CITY_1`) | -1 |
| `PEWTERCITY_FRUIT_TREE2` | `SPRITE_FRUIT_TREE` | 30 | 3 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `PewterCityFruitTree2` (`fruittree FRUITTREE_PEWTER_CITY_2`) | -1 |

**Scripts of interest**

- `PewterCityGrampsScript` (`4d:583e`). `faceplayer` / `opentext` / `checkver`
  / `iftrue .RainbowWing`. `checkver` leaves `GS_VERSION` in `wScriptVar`
  (0 = Gold, 1 = Silver), so:
  - **Gold**: `checkevent EVENT_GOT_SILVER_WING` -> `.GotSilverWing`; otherwise
    text, `promptbutton`, `verbosegiveitem SILVER_WING`,
    `setevent EVENT_GOT_SILVER_WING`. Note there is **no `iffalse` guard** on
    this `verbosegiveitem`: the flag is set whether or not the bag had room.
  - **Silver**: `checkevent EVENT_GOT_RAINBOW_WING` -> `.GotSilverWing`;
    otherwise `verbosegiveitem RAINBOW_WING`, `setevent EVENT_GOT_RAINBOW_WING`,
    `setevent EVENT_TEAM_ROCKET_DISBANDED`.
  This gramps is the *second* source for the wing pair: the Radio Tower director
  (`maps/RadioTower5F.asm:120-140`) gives the opposite one on the same
  `checkver` split.
- `PewterCityFlypointCallback` (`MAPCALLBACK_NEWMAP`):
  `setflag ENGINE_FLYPOINT_PEWTER`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_GOT_SILVER_WING` | `constants/event_flags.asm:130` | Gold branch of `PewterCityGrampsScript`; also `maps/RadioTower5F.asm:139` (Silver) | one-time |
| `EVENT_GOT_RAINBOW_WING` | `constants/event_flags.asm:129` | Silver branch of `PewterCityGrampsScript`; also `maps/RadioTower5F.asm:129` (Gold); read by `maps/EcruteakTinTowerEntrance.asm:62` | one-time; gates Tin Tower entry |
| `EVENT_TEAM_ROCKET_DISBANDED` | `constants/event_flags.asm:1283` | set by the Silver branch here | side effect of the Rainbow Wing gift |
| `ENGINE_FLYPOINT_PEWTER` | `constants/engine_flags.asm:69` | `PewterCityFlypointCallback` | Fly destination |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `SILVER_WING` (Gold) / `RAINBOW_WING` (Silver) | talk to `PEWTERCITY_GRAMPS` at (29,17) | `PewterCityGrampsScript` | `EVENT_GOT_SILVER_WING` / `EVENT_GOT_RAINBOW_WING` |
| `ICE_BERRY` | fruit tree at (32,3) | `FRUITTREE_PEWTER_CITY_1`, `data/items/fruit_trees.asm:31` | daily |
| `MINT_BERRY` | fruit tree at (30,3) | `FRUITTREE_PEWTER_CITY_2`, `data/items/fruit_trees.asm:32` | daily |

**Wild encounters** - none (TOWN, no grass table).

---

### MAP_PEWTER_POKECENTER_1F

- Script: `maps/PewterPokecenter1F.asm`
- Header: `data/maps/maps.asm:326` -> `TILESET_POKECENTER, INDOOR, LANDMARK_PEWTER_CITY, MUSIC_POKEMON_CENTER, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:301` `map_const PEWTER_POKECENTER_1F, 5, 4`
- Attributes: `data/maps/attributes.asm:583`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `PEWTER_CITY` | 4 |
| 2 | 4 | 7 | `PEWTER_CITY` | 4 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `PEWTERPOKECENTER1F_NURSE` | `SPRITE_NURSE` | 3 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `PewterPokecenter1FNurseScript` (`jumpstd PokecenterNurseScript`) | -1 |
| `PEWTERPOKECENTER1F_TEACHER` | `SPRITE_TEACHER` | 8 | 6 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `PewterPokecenter1FTeacherScript` | -1 |
| `PEWTERPOKECENTER1F_JIGGLYPUFF` | `SPRITE_JIGGLYPUFF` | 1 | 3 | `SPRITEMOVEDATA_POKEMON` | `OBJECTTYPE_SCRIPT` | `PewterJigglypuff` | -1 |
| `PEWTERPOKECENTER1F_BUG_CATCHER` | `SPRITE_BUG_CATCHER` | 2 | 3 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `PewterPokecenter1FBugCatcherScript` | -1 |
| `PEWTERPOKECENTER1F_CHRIS` | `SPRITE_POKEFAN_M` | 7 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Chris` | -1 |

**Scripts of interest**

- `Chris` (`5a:46f5`): `faceplayer` / `opentext` / `trade NPC_TRADE_CHRIS` /
  `waitbutton` / `closetext` / `end`. The trade row is
  `data/events/npc_trades.asm:18`:
  `npctrade TRADE_DIALOGSET_HAPPY, GLOOM, RAPIDASH, "RUNNY", $96, $66,
  BURNT_BERRY, 15616, "CHRIS", TRADE_GENDER_EITHER` - the player gives GLOOM and
  receives a RAPIDASH nicknamed RUNNY, DVs `$96/$66`, holding a BURNT_BERRY, OT
  "CHRIS" ID 15616. The FAQ's "trade a Gloom for a Rapidash" is exact. Note the
  NPC sprite is `SPRITE_POKEFAN_M`, not a lady.

---

### MAP_PEWTER_GYM

- Script: `maps/PewterGym.asm`
- Blocks: `maps/PewterGym.blk`
- Header: `data/maps/maps.asm:324` -> `TILESET_TOWER, INDOOR, LANDMARK_PEWTER_CITY, MUSIC_GYM, TRUE (no phone), PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:299` `map_const PEWTER_GYM, 5, 7` (group `PEWTER`, id 4) = 10 x 14 cells
- Attributes: `data/maps/attributes.asm:581` `map_attributes PewterGym, PEWTER_GYM, $00`; no connections

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 13 | `PEWTER_CITY` | 2 |
| 2 | 5 | 13 | `PEWTER_CITY` | 2 |

**Coord events** - none. There is no lock-in trip-wire in this gym.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 2 | 11 | `BGEVENT_READ` | `PewterGymStatue` |
| 7 | 11 | `BGEVENT_READ` | `PewterGymStatue` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `PEWTERGYM_BROCK` | `SPRITE_BROCK` | 5 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `PewterGymBrockScript` | -1 |
| `PEWTERGYM_YOUNGSTER` | `SPRITE_YOUNGSTER` | 2 | 5 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerCamperJerry` | -1 |
| `PEWTERGYM_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 6 | 11 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` (sight 1) | `PewterGymGuideScript` | -1 |

**Scripts of interest**

- `PewterGymBrockScript` (`5a:405f`). `faceplayer` / `opentext` /
  `checkflag ENGINE_BOULDERBADGE` / `iftrue .FightDone`. Otherwise:
  `writetext BrockIntroText`, `waitbutton`, `closetext`,
  `winlosstext BrockWinLossText, 0`, `loadtrainer BROCK, BROCK1`,
  `startbattle`, `reloadmapafterbattle`, `setevent EVENT_BEAT_BROCK`,
  **`setevent EVENT_BEAT_CAMPER_JERRY`**, then `opentext` /
  `writetext ReceivedBoulderBadgeText` / `playsound SFX_GET_BADGE` / `waitsfx` /
  `setflag ENGINE_BOULDERBADGE` / `writetext BrockBoulderBadgeText` /
  `waitbutton` / `closetext` / `end`.
  Two consequences for a bot: (1) Camper Jerry is optional - beating Brock marks
  him beaten; (2) the badge is a `setflag` on the ENGINE namespace, not an
  `EVENT_*`.
- `TrainerCamperJerry` (`5a:4093`): standard `trainer CAMPER, JERRY,
  EVENT_BEAT_CAMPER_JERRY, ...` header, sight range 3 facing right from (2,5).
- `PewterGymGuideScript`: `checkevent EVENT_BEAT_BROCK`, two text branches.
- `PewterGymStatue`: `checkflag ENGINE_BOULDERBADGE`; unbeaten -> `jumpstd
  GymStatue1Script`, beaten -> `gettrainername STRING_BUFFER_4, BROCK, BROCK1`
  then `jumpstd GymStatue2Script`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_BOULDERBADGE` | `constants/engine_flags.asm:47` (row `data/events/engine_flags.asm`, backed by `wKantoBadges`) | checked and set by `PewterGymBrockScript`; checked by `PewterGymStatue` | the gym's own re-entry guard, and the ROCK-type damage boost via `BadgeTypeBoosts` |
| `EVENT_BEAT_BROCK` | `constants/event_flags.asm:715` | set by `PewterGymBrockScript`; read by `PewterGymGuideScript` | gym cleared |
| `EVENT_BEAT_CAMPER_JERRY` | `constants/event_flags.asm:545` | `TrainerCamperJerry`, and also set by `PewterGymBrockScript` | trainer beaten / skipped |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `JERRY` (`constants/trainer_constants.asm:566`) | `CAMPER` | 18 | `CamperGroup` "JERRY" (`data/trainers/parties.asm:2811`): L37 SANDSLASH, `TRAINERTYPE_NORMAL` | `TrainerCamperJerry` | no |
| `BROCK1` (`constants/trainer_constants.asm:91`, class `BROCK` = 11 at line 90) | `BROCK` | 1 | `BrockGroup` (`data/trainers/parties.asm:270`, symbol `0e:5cda`), `TRAINERTYPE_MOVES` | `PewterGymBrockScript` | no phone |

`BrockGroup` party, in asm order:

| # | level | species | moves |
|---|---|---|---|
| 1 | 41 | GRAVELER | DEFENSE_CURL, ROCK_SLIDE, ROLLOUT, EARTHQUAKE |
| 2 | 41 | RHYHORN | FURY_ATTACK, SCARY_FACE, EARTHQUAKE, HORN_DRILL |
| 3 | 42 | OMASTAR | BITE, SURF, PROTECT, SPIKE_CANNON |
| 4 | 44 | ONIX | BIND, ROCK_SLIDE, BIDE, SANDSTORM |
| 5 | 42 | KABUTOPS | SLASH, SURF, ENDURE, GIGA_DRAIN |

Class attributes (`data/trainers/attributes.asm:101`): item1 `HYPER_POTION`,
base reward 25, AI `AI_BASIC | AI_SETUP | AI_SMART | AI_AGGRESSIVE |
AI_CAUTIOUS | AI_STATUS | AI_RISKY`, `CONTEXT_USE | SWITCH_SOMETIMES`. Camper
base reward 5 (`data/trainers/attributes.asm:323`).

**Wild encounters** - none.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Route 19 boulders | `maps/Route19.asm:Route19ClearRocksCallback` (`4e:4f09`), six `changeblock ... $7a` writes under `callback MAPCALLBACK_TILES` | `EVENT_CINNABAR_ROCKS_CLEARED` | Set only by `maps/Route20.asm:Route20ClearRocksCallback` (`MAPCALLBACK_NEWMAP`) - i.e. by reaching Route 20 from the Cinnabar side. Nothing in this section can clear it; the FAQ is right that you must turn around. |
| SNORLAX blocking the DIGLETT'S CAVE door | `maps/VermilionCity.asm` object at (34,8) with a `SPRITEMOVEDATA_BIGDOLLSYM` 2x2 footprint sitting directly under warp 10 at (34,7) | `EVENT_VERMILION_CITY_SNORLAX` clear = present | `disappear VERMILIONCITY_BIG_SNORLAX` at the end of `VermilionSnorlax`, which only runs after `startbattle` |
| SNORLAX will not wake | `engine/events/specials.asm:358 SnorlaxAwake` | `wMapMusic == MUSIC_POKE_FLUTE_CHANNEL` **and** player on one of (33,8), (34,10), (35,10), (36,8), (36,9) | Pokegear radio tuned to knob 78 / "20.0" |
| POKe FLUTE radio channel is static | `engine/pokegear/pokegear.asm:1487 .PokeFluteRadio` | not in Johto (`.InJohto`, landmark >= `KANTO_LANDMARK`) **and** `POKEGEAR_EXPN_CARD_F` set in `wPokegearFlags` | EXPN CARD, obtained earlier (Lavender radio director) |
| Route 2 cut trees | tileset collision `COLL_CUT_TREE` (`constants/collision_constants.asm:16`), tested by `CheckCutCollision` (`engine/overworld/tile_events.asm:76`) | HM01 CUT + `ENGINE_HIVEBADGE` (`engine/events/overworld.asm:133 CutFunction.CheckAble`) | already held long before this section |
| Diglett's Cave traversal | `maps/DiglettsCave.blk` geometry - the three pockets are joined only by warps 2<->5 and 6<->4 | none beyond walking | - |
| Pewter Gym re-fight | `maps/PewterGym.asm:PewterGymBrockScript` `checkflag ENGINE_BOULDERBADGE / iftrue .FightDone` | badge not yet held | one-shot |
| Pewter museum | no warp exists in `PewterCity_MapEvents`; only `bg_event 15, 9 PewterMuseumSign` | - | permanently closed in GS |

---

## 4. Bot checklist

Coordinates are asm cell coordinates. "clear" / "set" refer to event flags.

1. `ROUTE_19_FUCHSIA_GATE` -> `ROUTE_19`: walk warp 3/4 at (4,7)/(5,7).
   Precondition: none. Expect to be stopped; `EVENT_CINNABAR_ROCKS_CLEARED` is
   clear, so blocks `(6,6) (8,6) (10,6) (12,8) (4,8) (10,10)` are rock. Turn
   around through warp 1 at (7,3).
2. FLY to `VERMILION_CITY`. Precondition: `ENGINE_FLYPOINT_VERMILION` set.
3. Open the Pokegear, RADIO card, tune the knob to 78 ("20.0"). Precondition:
   `POKEGEAR_EXPN_CARD_F` set and the landmark is Kanto. Postcondition:
   `wMapMusic == MUSIC_POKE_FLUTE_CHANNEL`.
4. Close the Pokegear and walk to one of (33,8) / (34,10) / (35,10) / (36,8) /
   (36,9). Face `VERMILIONCITY_BIG_SNORLAX` at (34,8) and press A.
   Precondition: `EVENT_VERMILION_CITY_SNORLAX` clear.
   Effect: `SnorlaxAwake` returns TRUE -> wild L50 SNORLAX with LEFTOVERS forced.
5. Battle: catch or defeat. Either way, postcondition
   `EVENT_VERMILION_CITY_SNORLAX` set (object removed) and
   `EVENT_FOUGHT_SNORLAX` set. **Save before step 4** - a failed catch is not
   repeatable.
6. Optional: `VERMILION_CITY` warp 2 at (9,5) -> `VERMILION_POKECENTER_1F`, heal
   and withdraw SNORLAX; back out warps 1/2 at (3,7)/(4,7).
7. `VERMILION_CITY` warp 10 at (34,7) -> `DIGLETTS_CAVE` warp 1 at (3,33).
8. `DIGLETTS_CAVE`: walk (3,33) -> (5,31) (warp 2, ladder). Land at (17,33).
9. Walk the long cave (17,33) -> (3,3) (warp 6, ladder). Land at (17,3).
   Optional en route: hidden `MAX_REVIVE` at (6,11),
   flag `EVENT_DIGLETTS_CAVE_HIDDEN_MAX_REVIVE`.
10. Walk (17,3) -> (15,5) (warp 3, door) -> `ROUTE_2` warp 5 at (12,7).
11. `ROUTE_2`: item ball `ROUTE2_POKE_BALL3` at (19,2) = CARBOS.
    Precondition `EVENT_ROUTE_2_CARBOS` clear; postcondition set.
12. Warp 1 at (15,15) -> `ROUTE_2_NUGGET_HOUSE`. Talk to
    `ROUTE2NUGGETHOUSE_FISHER` at (2,4). Precondition
    `EVENT_GOT_NUGGET_FROM_GUY` clear and >=1 bag slot; postcondition set,
    NUGGET in bag. Exit warps 1/2 at (2,7)/(3,7).
13. Optional: fruit tree `ROUTE2_FRUIT_TREE` at (10,14) = PSNCUREBERRY (daily).
14. CUT the tree covering cells (14-15, 18-19). Precondition: HM01 in bag and
    `ENGINE_HIVEBADGE` set.
15. Warp 3/4 at (16,27)/(17,27) -> `ROUTE_2_GATE` -> warps 3/4 at (4,7)/(5,7) ->
    `ROUTE_2` warp 2 at (15,31). Still Route 2.
16. Item ball `ROUTE2_POKE_BALL4` at (14,50) = ELIXER.
    Flag `EVENT_ROUTE_2_ELIXER`.
17. CUT the tree covering cells (12-13, 50-51), then head north.
18. Battle `TrainerBugCatcherRob` - object at (10,45), facing left, sight 5.
    Party L32 BEEDRILL / L32 BUTTERFREE. Postcondition
    `EVENT_BEAT_BUG_CATCHER_ROB`.
19. Battle `TrainerBugCatcherDoug` - object at (4,43), facing up, sight 5.
    Party L34 ARIADOS. Postcondition `EVENT_BEAT_BUG_CATCHER_DOUG`.
20. Optional pickups on the way north: item ball at (0,29) = DIRE_HIT
    (`EVENT_ROUTE_2_DIRE_HIT`); item ball at (2,23) = MAX_POTION
    (`EVENT_ROUTE_2_MAX_POTION`); hidden MAX_ETHER at (7,23), hidden FULL_HEAL
    at (4,14), hidden FULL_RESTORE at (4,27), hidden REVIVE at (11,30).
21. Battle `TrainerBugCatcherEd` - object at (5,5), facing right, sight 4.
    Party L30 BEEDRILL x3. Postcondition `EVENT_BEAT_BUG_CATCHER_ED`.
22. Walk off the north edge of `ROUTE_2` into `PEWTER_CITY`
    (`connection north, PewterCity, PEWTER_CITY, -5`). Postcondition
    `ENGINE_FLYPOINT_PEWTER` set by `PewterCityFlypointCallback`.
23. Talk to `PEWTERCITY_GRAMPS` at (29,17) (he paces x 27..31 on y=17).
    Precondition `EVENT_GOT_SILVER_WING` clear (Gold).
    Postcondition: SILVER_WING in bag, `EVENT_GOT_SILVER_WING` set.
    On Silver: RAINBOW_WING, `EVENT_GOT_RAINBOW_WING` and
    `EVENT_TEAM_ROCKET_DISBANDED` set.
24. Optional: warp 4 at (13,25) -> `PEWTER_POKECENTER_1F`. Heal at
    `PEWTERPOKECENTER1F_NURSE` (3,1). Talk to `Chris` at (7,2) to trade a GLOOM
    for RAPIDASH "RUNNY". Optional: fruit trees at (32,3) = ICE_BERRY and
    (30,3) = MINT_BERRY.
25. `PEWTER_CITY` warp 2 at (16,17) -> `PEWTER_GYM` (arrive at warp 1, (4,13)).
26. Optional: battle `TrainerCamperJerry`, object at (2,5), facing right,
    sight 3. L37 SANDSLASH.
27. Talk to `PEWTERGYM_BROCK` at (5,1). Precondition `ENGINE_BOULDERBADGE`
    clear. Battle `loadtrainer BROCK, BROCK1` (5 mon, L41-44).
    Postconditions: `EVENT_BEAT_BROCK`, `EVENT_BEAT_CAMPER_JERRY`,
    `ENGINE_BOULDERBADGE`.
28. Exit warps 1/2 at (4,13)/(5,13) -> `PEWTER_CITY` warp 2; heal.

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| All maps / warps / objects / bg events for this section | `src/import/RomExtractorGen2.lua` (`MAP_GROUP_COUNT = 26`, line 47; the group walk at line 527) | implemented - every Kanto group is extracted, so these maps are data, not hand-ported code |
| `MAPCALLBACK_TILES` + `changeblock` (Route 19 boulders) | `src/script/gen2/Opcodes.lua:127` (`changeblock`), driver `tests/drivers/gold_map_callbacks.lua` | implemented |
| `special SnorlaxAwake` | `src/script/gen2/Specials.lua:1562` `H.SnorlaxAwake`, with `Specials.SNORLAX_PROXIMITY` transcribing `.ProximityCoords` and `Specials.POKE_FLUTE_SONG = "Music_PokeFluteChannel"`; hooks `currentMusic` / `playerCell` at `src/world/gen2/World.lua:2712` and `:2723` | implemented |
| POKe FLUTE radio channel (knob 78 / 20.0) + EXPN CARD gate | `src/ui/gen2/Pokegear.lua:812-815` (the `knob = 78` row, `ctx.inJohto` / `ctx.expnCard`) | implemented |
| `BATTLETYPE_FORCEITEM` -> Snorlax holds LEFTOVERS | `src/world/gen2/World.lua:111` and `:4576` | implemented |
| `loadwildmon` / `startbattle` / `reloadmapafterbattle` / `disappear` | `src/script/gen2/Vm.lua:806-841` | implemented |
| Catching a wild mon (Ultra Balls on Snorlax) | `src/battle/gen2/Catching.lua` | implemented |
| Trainer battles from `OBJECTTYPE_TRAINER` rows (Rob / Doug / Ed / Jerry) | `src/world/gen2/Trainers.lua`, `src/script/gen2/Vm.lua:806` (`loadtrainer`) | implemented |
| Gym leader script shape (`checkflag`/`winlosstext`/`setflag ENGINE_BOULDERBADGE`) | `src/script/gen2/Vm.lua:208` (`setflag`/`clearflag`), `src/world/gen2/World.lua:1296-1340` (`engineFlags`) | implemented |
| `BadgeTypeBoosts` - BOULDERBADGE boosting ROCK moves (`data/types/badge_type_boosts.asm`, `engine/battle/misc.asm:146 DoBadgeTypeBoosts`) | no match anywhere in `src/battle/gen2/` | **missing** (the Gen 1 port has its own badge table in `src/battle/Damage.lua:28`, but nothing in the Gen 2 battle path reads badges) |
| Item ball pickup (Route 2 CARBOS / DIRE_HIT / ELIXER / MAX_POTION) | extracted into `obj.itemball` at `src/import/RomExtractorGen2.lua:2874` and `:2968`, but no consumer exists in `src/world/gen2/`; `src/script/gen2/CallAsm.lua:550` stubs `TryReceiveItem` with "wItemBallItemID / wItemBallQuantity are set by a script path this port does not run" | **missing** |
| Hidden items (Diglett's Cave MAX_REVIVE, the four Route 2 hidden items, Vermilion FULL_HEAL) | `src/world/gen2/HiddenItems.lua`, wired at `src/world/gen2/World.lua:5291` and the ITEMFINDER path at `:3423` | implemented |
| `verbosegiveitem` (NUGGET, SILVER_WING/RAINBOW_WING) | `src/script/gen2/Opcodes.lua:163`, `src/script/gen2/Vm.lua:501` / `:1201` | implemented |
| `fruittree` (PSNCUREBERRY, ICE_BERRY, MINT_BERRY) | `src/script/gen2/Opcodes.lua:160`, `src/world/gen2/World.lua:1058` (`fruitTreeItem`) | implemented |
| `trade NPC_TRADE_CHRIS` (GLOOM -> RAPIDASH) | `src/core/gen2/NpcTrade.lua`, `src/script/gen2/Opcodes.lua:155` | implemented |
| `checkver` Gold/Silver split in `PewterCityGrampsScript` | `src/script/gen2/Vm.lua:774`, `src/world/gen2/World.lua:1287` (`gsVersion`) | implemented |
| `setflag ENGINE_FLYPOINT_PEWTER` / `_VERMILION` and Fly | `src/world/gen2/World.lua:5628` | implemented |
| CUT field move + HIVEBADGE check | `src/world/gen2/FieldMoves.lua` (badge table at lines 100-101) | implemented |
| Bike allowed in `CAVE` (Diglett's Cave) | `src/world/gen2/Bike.lua` | partial - the file exists and comments the `hiddenitem`/BICYCLE interaction, but the `.CheckEnvironment` outdoor/CAVE/GATE test was not located; verify before relying on it |
| `gettrainername` for the beaten-gym statue | `src/script/gen2/Vm.lua:407` | implemented |

---

## 6. Unresolved / verify by hand

- **Brock's party order.** The FAQ lists Graveler, Omastar, Rhyhorn, Onix,
  Kabutops. `data/trainers/parties.asm:270` `BrockGroup` is Graveler (41),
  **Rhyhorn (41), Omastar (42)**, Onix (44), Kabutops (42) - slots 2 and 3 are
  swapped relative to the FAQ. Levels and species set match.
- **All the FAQ's prize money figures are exactly 4x the asm value.**
  `ComputeTrainerReward` (`engine/battle/read_trainer_party.asm:300`) is
  `base reward x last mon level`, with no multiplier. Brock 25 x 42 = 1050 (FAQ
  says 4,200); Rob 4 x 32 = 128 (FAQ 512); Doug 4 x 34 = 136 (FAQ 544); Ed
  4 x 30 = 120 (FAQ 480); Jerry 5 x 37 = 185 (FAQ 740). The FAQ's EXP figures
  likewise do not come from GS. Treat the money/EXP numbers in this section as
  belonging to a different game (most likely HeartGold/SoulSilver, which the
  text references) and ignore them for a GS bot.
- **"Viridian Forest".** The FAQ says the Max Potion is "in Viridian Forest".
  There is no Viridian Forest map in `constants/map_constants.asm`; the
  MAX_POTION is `ROUTE2_POKE_BALL2` at (2,23) on `ROUTE_2`, in the area the
  forest used to occupy.
- **"the man just to the right of the Pokemart".** `PEWTERCITY_GRAMPS` spawns at
  (29,17) with a `WALK_LEFT_RIGHT` radius of 2 (so x 27..31); the mart door is
  warp 3 at (23,17). He is to the right of the mart but not adjacent.
- **"The Pokemon Center has a lady".** The trade NPC is `Chris`, sprite
  `SPRITE_POKEFAN_M` at (7,2). Male sprite, name CHRIS.
- **Which cut tree the FAQ means.** The two trees named in step 14 and step 17
  above are inferred from the block dump of `maps/Route2.blk` plus the item/warp
  positions; they are not labelled anywhere in asm. Three other `CUT_TREE`
  blocks exist on Route 2 (see the cut-tree table) and one of those may be the
  intended route instead. Verify with a real walk.
- **Diglett's Cave pocket connectivity.** The three-pocket reading is derived by
  hand from `maps/DiglettsCave.blk` block ids against
  `data/tilesets/kanto_collision.asm`; the per-tile collision of the "long cave"
  interior was not fully traced, only that every warp block is reachable within
  its pocket. The FAQ's described route is consistent with it.
- **"the route is cleared to Diglett's Cave and through Route 8".** Nothing in
  `maps/VermilionCity.asm` or `maps/Route11.asm` gates Route 11 / Route 8 on the
  Snorlax; the only thing `EVENT_FOUGHT_SNORLAX` unlocks outside Vermilion is the
  right-hand Black Belt object in `maps/VictoryRoadGate.asm:119`. The Snorlax
  blocks only the Diglett's Cave door tile at (34,7).
- **"Keep around those four Ultra Balls"** and the Rest/Thunder Wave catch
  advice are strategy, not asm; nothing enforces a ball count.
- **`src/world/gen2/Bike.lua` CAVE permission.** Marked partial in section 5 -
  the port file was read but the equivalent of `BikeFunction.CheckEnvironment`
  (`engine/events/overworld.asm:1665`) was not located, so "you can bike through
  Diglett's Cave in the port" is unverified.

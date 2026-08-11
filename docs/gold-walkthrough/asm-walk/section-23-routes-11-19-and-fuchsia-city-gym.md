# Section 23 - Routes 11-19 and Fuchsia City Gym

Source: `../section-23-routes-11-19-and-fuchsia-city-gym.txt`
Maps covered: `MAP_ROUTE_12`, `MAP_ROUTE_11`, `MAP_ROUTE_12_SUPER_ROD_HOUSE`,
`MAP_ROUTE_13`, `MAP_ROUTE_14`, `MAP_ROUTE_15`, `MAP_ROUTE_15_FUCHSIA_GATE`,
`MAP_FUCHSIA_CITY`, `MAP_FUCHSIA_POKECENTER_1F`, `MAP_ROUTE_16`,
`MAP_ROUTE_16_GATE`, `MAP_ROUTE_16_FUCHSIA_SPEECH_HOUSE`, `MAP_ROUTE_17`,
`MAP_ROUTE_17_ROUTE_18_GATE`, `MAP_ROUTE_18`, `MAP_FUCHSIA_GYM`

Badges / key milestones in this section:

- `ENGINE_SOULBADGE` (Kanto badge 5) from `FuchsiaGymJanineScript` in `maps/FuchsiaGym.asm`
- `EVENT_GOT_TM06_TOXIC` -> `TM_TOXIC` (item id `$c5`, `constants/item_constants.asm:226`)
- `EVENT_GOT_SUPER_ROD` -> `SUPER_ROD` from `maps/Route12SuperRodHouse.asm`
- `ENGINE_FLYPOINT_FUCHSIA` armed on first entry to `MAP_FUCHSIA_CITY`
- Cycling Road forced-bike state (`ENGINE_ALWAYS_ON_BIKE`, `ENGINE_DOWNHILL`)

Despite the section title, the walkthrough text never enters `MAP_ROUTE_19`
(see "Unresolved").

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `MAP_ROUTE_12` | `maps/Route12.asm` | Fly to Lavender Town, walk south (`LavenderTown` south connection, `data/maps/attributes.asm:339`) | west connection to `ROUTE_11` (offset 9) | Fisher Kyle, Fisher Martin |
| 2 | `MAP_ROUTE_11` | `maps/Route11.asm` | east connection from `ROUTE_12` (offset -9) | back east to `ROUTE_12` | Herman / Owen / Jason / Fidel, Berry + hidden Revive; Snorlax dead end at the west connection |
| 3 | `MAP_ROUTE_12` | `maps/Route12.asm` | east connection from `ROUTE_11` | warp 1 at (11, 33) | Fisher Stephen, then the Super Rod house |
| 4 | `MAP_ROUTE_12_SUPER_ROD_HOUSE` | `maps/Route12SuperRodHouse.asm` | `Route12` warp 1 | warps 1/2 back to `ROUTE_12` warp 1 | Super Rod |
| 5 | `MAP_ROUTE_12` | `maps/Route12.asm` | house warp | south connection to `ROUTE_13` (offset -20) | Fisher Barney, cut tree, Calcium ball |
| 6 | `MAP_ROUTE_13` | `maps/Route13.asm` | north connection from `ROUTE_12` (offset 20) | south connection to `ROUTE_14` (offset 0) | Perry, Bret, Joshua, Alex, Kenny |
| 7 | `MAP_ROUTE_14` | `maps/Route14.asm` | north connection from `ROUTE_13` | west connection to `ROUTE_15` (offset 9) | Trevor, Kim's trade, Carter, Roy; cut trees |
| 8 | `MAP_ROUTE_15` | `maps/Route15.asm` | east connection from `ROUTE_14` (offset -9) | warps 1/2 at (2, 4)/(2, 5) | PP Up, then six schoolboys/teachers |
| 9 | `MAP_ROUTE_15_FUCHSIA_GATE` | `maps/Route15FuchsiaGate.asm` | `Route15` warps 1/2 | warps 1/2 to `FUCHSIA_CITY` warps 8/9 | pass-through gate, no check |
| 10 | `MAP_FUCHSIA_CITY` | `maps/FuchsiaCity.asm` | gate warps 8/9 at (37, 22)/(37, 23) | Fly out (`ENGINE_FLYPOINT_FUCHSIA` now set) | Burnt Berry tree, closed Safari Zone, Pokecenter |
| 11 | `MAP_ROUTE_16` | `maps/Route16.asm` | Fly to Celadon, west connection (offset 9 from `CeladonCity`) | warps 2/3 at (14, 6)/(14, 7) | optional Cut tree; Cycling Road entrance |
| 12 | `MAP_ROUTE_16_GATE` | `maps/Route16Gate.asm` | `Route16` warps 2/3 | warps 1/2 at (0, 4)/(0, 5) -> `ROUTE_16` warps 4/5 | BICYCLE check coord event |
| 13 | `MAP_ROUTE_17` | `maps/Route17.asm` | `Route16` north connection (offset 0) | warps 1/2 at (17, 82)/(17, 83) | Riley, Glenn, Joel, Charles; forced downhill bike |
| 14 | `MAP_ROUTE_17_ROUTE_18_GATE` | `maps/Route17Route18Gate.asm` | `Route17` warps 1/2 | warps 3/4 at (9, 4)/(9, 5) -> `ROUTE_18` warps 1/2 | BICYCLE check coord event |
| 15 | `MAP_ROUTE_18` | `maps/Route18.asm` | gate warps 3/4 | east connection to `FUCHSIA_CITY` (offset -7) | Bird Keeper Bob, Bird Keeper Boris |
| 16 | `MAP_FUCHSIA_CITY` | `maps/FuchsiaCity.asm` | west connection from `ROUTE_18` (offset 7) | warp 5 at (19, 27), then warp 3 at (8, 27) | heal, then gym |
| 17 | `MAP_FUCHSIA_GYM` | `maps/FuchsiaGym.asm` | `FuchsiaCity` warp 3 | warps 1/2 at (4, 17)/(5, 17) | four Janine impostors + Janine, SOULBADGE, TM06 |

Spill-over note: the walkthrough's own Route 12 pass reaches the west connection
of `MAP_ROUTE_11` and stops at the Vermilion Snorlax. `MAP_VERMILION_CITY` and
the Snorlax event belong to a different section; only the blocker is documented
here (section 3).

---

## 2. Maps

### MAP_ROUTE_12

- Script: `maps/Route12.asm`
- Blocks: `maps/Route12.blk`
- Header: `data/maps/maps.asm:379` -> `map Route12, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_12, MUSIC_ROUTE_12, FALSE, PALETTE_AUTO, FISHGROUP_QWILFISH_NO_SWARM`
- Dimensions: `constants/map_constants.asm:350` -> `map_const ROUTE_12, 10, 27` (10x27 blocks = 20x54 walk cells)
- Attributes/connections: `data/maps/attributes.asm:328-331` -> `map_attributes Route12, ROUTE_12, $43`; north `LavenderTown` (0), south `Route13` (-20), west `Route11` (9)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 11 | 33 | `ROUTE_12_SUPER_ROD_HOUSE` | 1 |

**Coord events** (`def_coord_events`)

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 11 | 27 | `BGEVENT_READ` | `Route12Sign` |
| 13 | 9 | `BGEVENT_READ` | `FishingSpotSign` |
| 14 | 13 | `BGEVENT_ITEM` | `Route12HiddenElixer` -> `hiddenitem ELIXER, EVENT_ROUTE_12_HIDDEN_ELIXER` |

**Object events** (`def_object_events`) - `object_const_def` starts at 2 (`macros/scripts/maps.asm:9`), so `ROUTE12_FISHER1` = 2 ... `ROUTE12_POKE_BALL2` = 7

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE12_FISHER1` (2) | `SPRITE_FISHER` | 5 | 15 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerFisherMartin` | -1 |
| `ROUTE12_FISHER2` (3) | `SPRITE_FISHER` | 15 | 28 | `STANDING_UP` | `OBJECTTYPE_TRAINER`, sight 1 | `TrainerFisherStephen` | -1 |
| `ROUTE12_FISHER3` (4) | `SPRITE_FISHER` | 13 | 39 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerFisherBarney` | -1 |
| `ROUTE12_FISHER4` (5) | `SPRITE_FISHER` | 6 | 6 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerFisherKyle` | -1 |
| `ROUTE12_POKE_BALL1` (6) | `SPRITE_POKE_BALL` | 5 | 43 | `STILL` | `OBJECTTYPE_ITEMBALL` | `Route12Calcium` (`itemball CALCIUM`) | `EVENT_ROUTE_12_CALCIUM` |
| `ROUTE12_POKE_BALL2` (7) | `SPRITE_POKE_BALL` | 5 | 51 | `STILL` | `OBJECTTYPE_ITEMBALL` | `Route12Nugget` (`itemball NUGGET`) | `EVENT_ROUTE_12_NUGGET` |

**Cut trees** (block-level, not objects)

Scanned `maps/Route12.blk` against the `TILESET_KANTO` rows of
`data/collision/field_move_blocks.asm` (`CutTreeBlockPointers.kanto`), quadrant
taken from `data/tilesets/kanto_collision.asm`:

| block (bx, by) | block id | cut quadrant | walk cell to face |
|---|---|---|---|
| (3, 22) | `$35` | top-right | (7, 44) |
| (3, 24) | `$33` | bottom-right | (7, 49) |

The (7, 44) tree is the one guarding the Calcium ball at (5, 43).

**Scripts of interest**

- `TrainerFisherKyle` / `TrainerFisherMartin` / `TrainerFisherStephen` /
  `TrainerFisherBarney` - each is a bare `trainer FISHER, <NAME>, EVENT_BEAT_*,
  <seen>, <beaten>, 0, .Script`; `.Script` is `endifjustbattled / opentext /
  writetext <after> / waitbutton / closetext / end`. No flags beyond the beat
  event, no items, no movement.
- `Route12Calcium` / `Route12Nugget` - `itemball` rows; the object's own event
  flag is what makes them one-shot.
- `Route12HiddenElixer` - `hiddenitem ELIXER, EVENT_ROUTE_12_HIDDEN_ELIXER`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_FISHER_KYLE` | `constants/event_flags.asm` | `TrainerFisherKyle` | trainer already beaten |
| `EVENT_BEAT_FISHER_MARTIN` | `constants/event_flags.asm` | `TrainerFisherMartin` | trainer already beaten |
| `EVENT_BEAT_FISHER_STEPHEN` | `constants/event_flags.asm` | `TrainerFisherStephen` | trainer already beaten |
| `EVENT_BEAT_FISHER_BARNEY` | `constants/event_flags.asm` | `TrainerFisherBarney` | trainer already beaten |
| `EVENT_ROUTE_12_CALCIUM` | `constants/event_flags.asm:1323` | itemball object | ball consumed |
| `EVENT_ROUTE_12_NUGGET` | `constants/event_flags.asm:1324` | itemball object | ball consumed |
| `EVENT_ROUTE_12_HIDDEN_ELIXER` | `constants/event_flags.asm:243` | `Route12HiddenElixer` | hidden item taken |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `CALCIUM` | itemball behind the (7, 44) cut tree | `Route12Calcium` at object (5, 43) | `EVENT_ROUTE_12_CALCIUM` |
| `NUGGET` | itemball at (5, 51) | `Route12Nugget` | `EVENT_ROUTE_12_NUGGET` |
| `ELIXER` | hidden, face (14, 13) | `bg_event 14, 13, BGEVENT_ITEM` | `EVENT_ROUTE_12_HIDDEN_ELIXER` |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `KYLE` | `FISHER` | Fisher (4) | L28 Seaking, L31 Poliwhirl, L31 Seaking | `TrainerFisherKyle` | none |
| `MARTIN` | `FISHER` | Fisher (13) | L32 Remoraid, L32 Remoraid | `TrainerFisherMartin` | none |
| `STEPHEN` | `FISHER` | Fisher (14) | L25 Magikarp, L25 Magikarp, L31 Qwilfish, L31 Tentacruel | `TrainerFisherStephen` | none |
| `BARNEY` | `FISHER` | Fisher (15) | L30 Gyarados x3 | `TrainerFisherBarney` | none |

All four are `TRAINERTYPE_NORMAL` (no custom moves/items). `FISHER` base reward
is 10 (`data/trainers/attributes.asm:223`).

**Wild encounters**

- Grass: **none**. `ROUTE_12` has no `def_grass_wildmons` row in
  `data/wild/kanto_grass.asm`.
- Water (`data/wild/kanto_water.asm:33`): `def_water_wildmons ROUTE_12`,
  6% rate - L25 Tentacool, L25 Quagsire, L25 Tentacruel (no time split; water
  tables are single-slot-set).
- Fishing group `FISHGROUP_QWILFISH_NO_SWARM` (`data/wild/fish.asm:177-193`,
  the `.Qwilfish_NoSwarm_*` labels alias `.Qwilfish_*`):
  - Old: Magikarp 10 (70%+1), Magikarp 10 (85%+1), Tentacool 10
  - Good: Magikarp 20 (35%), Tentacool 20 (70%), Tentacool 20 (90%+1), `time_group 20` = Tentacool 20 day / Tentacool 20 nite
  - Super: Tentacool 40 (40%), `time_group 21` = Tentacool 40, Magikarp 40 (90%+1), Qwilfish 40

---

### MAP_ROUTE_11

- Script: `maps/Route11.asm`
- Blocks: `maps/Route11.blk`
- Header: `data/maps/maps.asm:295` -> `map Route11, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_11, MUSIC_ROUTE_12, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:272` -> `map_const ROUTE_11, 20, 9` (40x18 cells)
- Attributes/connections: `data/maps/attributes.asm:333-336` -> `$0f`; west `VermilionCity` (0), east `Route12` (-9)

**Warps** (`def_warp_events`)

None.

**Coord events** (`def_coord_events`)

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 3 | 7 | `BGEVENT_READ` | `Route11Sign` |
| 32 | 5 | `BGEVENT_ITEM` | `Route11HiddenRevive` -> `hiddenitem REVIVE, EVENT_ROUTE_11_HIDDEN_REVIVE` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE11_YOUNGSTER1` (2) | `SPRITE_YOUNGSTER` | 22 | 14 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerYoungsterOwen` | -1 |
| `ROUTE11_YOUNGSTER2` (3) | `SPRITE_YOUNGSTER` | 15 | 9 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerYoungsterJason` | -1 |
| `ROUTE11_YOUNGSTER3` (4) | `SPRITE_YOUNGSTER` | 29 | 7 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 1 | `TrainerPsychicHerman` | -1 |
| `ROUTE11_YOUNGSTER4` (5) | `SPRITE_YOUNGSTER` | 7 | 4 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerPsychicFidel` | -1 |
| `ROUTE11_FRUIT_TREE` (6) | `SPRITE_FRUIT_TREE` | 32 | 2 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route11FruitTree` (`fruittree FRUITTREE_ROUTE_11`) | -1 |

Note the two `PSYCHIC_T` trainers wear `SPRITE_YOUNGSTER`, not a psychic sprite.

**Scripts of interest**

- `Route11FruitTree` - single `fruittree FRUITTREE_ROUTE_11`.
  `data/items/fruit_trees.asm` gives index 24 (`$18`) = `BERRY`. Fruit trees
  are day-tracked, not one-shot events.
- `Route11HiddenRevive` - `hiddenitem REVIVE, EVENT_ROUTE_11_HIDDEN_REVIVE`,
  faced from cell (32, 5), directly below the fruit tree.
- The four trainer scripts are the plain `endifjustbattled` pattern.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_YOUNGSTER_OWEN` | `constants/event_flags.asm` | `TrainerYoungsterOwen` | trainer beaten |
| `EVENT_BEAT_YOUNGSTER_JASON` | `constants/event_flags.asm` | `TrainerYoungsterJason` | trainer beaten |
| `EVENT_BEAT_PSYCHIC_HERMAN` | `constants/event_flags.asm` | `TrainerPsychicHerman` | trainer beaten |
| `EVENT_BEAT_PSYCHIC_FIDEL` | `constants/event_flags.asm` | `TrainerPsychicFidel` | trainer beaten |
| `EVENT_ROUTE_11_HIDDEN_REVIVE` | `constants/event_flags.asm:245` | `Route11HiddenRevive` | hidden item taken |
| `FRUITTREE_ROUTE_11` | `constants/script_constants.asm:230` | `Route11FruitTree` | fruit tree slot 24 |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `BERRY` | talk to the tree object at (32, 2) | `Route11FruitTree` / `data/items/fruit_trees.asm` | none (daily tree, not an event flag) |
| `REVIVE` | hidden, face (32, 5) | `bg_event 32, 5, BGEVENT_ITEM` | `EVENT_ROUTE_11_HIDDEN_REVIVE` |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `HERMAN` | `PSYCHIC_T` | Psychic (3) | L30 Exeggcute, L30 Exeggcute, L30 Exeggutor | `TrainerPsychicHerman` | none |
| `OWEN` | `YOUNGSTER` | Youngster (11) | L35 Growlithe | `TrainerYoungsterOwen` | none |
| `JASON` | `YOUNGSTER` | Youngster (12) | L33 Sandslash, L33 Crobat | `TrainerYoungsterJason` | none |
| `FIDEL` | `PSYCHIC_T` | Psychic (4) | L34 Xatu | `TrainerPsychicFidel` | none |

Base rewards: `YOUNGSTER` 4 (`attributes.asm:133`), `PSYCHIC_T` 8 (`attributes.asm:313`).

**Wild encounters**

`data/wild/kanto_grass.asm:728` `def_grass_wildmons ROUTE_11`, 10%/10%/10%.
Morn, day and nite are the same seven slots:
L14 Drowzee, L15 Rattata, L15 Magnemite, L16 Drowzee, L16 Hypno, L16 Hypno, L16 Hypno.

No water table, no `def_grass_wildmons` time split. The walkthrough's species
list omits Magnemite.

---

### MAP_ROUTE_12_SUPER_ROD_HOUSE

- Script: `maps/Route12SuperRodHouse.asm`
- Header: `data/maps/maps.asm:391` -> `map Route12SuperRodHouse, TILESET_HOUSE, INDOOR, LANDMARK_ROUTE_12, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:362` -> `map_const ROUTE_12_SUPER_ROD_HOUSE, 4, 4`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `ROUTE_12` | 1 |
| 2 | 3 | 7 | `ROUTE_12` | 1 |

**Coord events** / **BG events**

None. (`SuperRodHouseBookshelf` exists in the file but is marked
`; unreferenced` - no bg_event points at it.)

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE12SUPERRODHOUSE_FISHING_GURU` (2) | `SPRITE_FISHING_GURU` | 5 | 3 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route12SuperRodHouseFishingGuruScript` | -1 |

**Scripts of interest**

`Route12SuperRodHouseFishingGuruScript` (`5d:4dc7` in
`pokegold-symbols/pokegold.sym`):

```
faceplayer / opentext
checkevent EVENT_GOT_SUPER_ROD
iftrue .GotSuperRod
writetext OfferSuperRodText
yesorno
iffalse .Refused                  ; "No" -> DontWantSuperRodText, closetext
writetext GiveSuperRodText
promptbutton
verbosegiveitem SUPER_ROD
iffalse .NoRoom                   ; bag full -> closetext, nothing set
setevent EVENT_GOT_SUPER_ROD
.GotSuperRod: writetext GaveSuperRodText / waitbutton / closetext / end
```

Bot-relevant: the `yesorno` must be answered **Yes**, and the KEY ITEMS pocket
must have room, or `EVENT_GOT_SUPER_ROD` never gets set and the script is
re-runnable.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_GOT_SUPER_ROD` | `constants/event_flags.asm:33` | `Route12SuperRodHouseFishingGuruScript` | Super Rod already handed over |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `SUPER_ROD` | talk to guru, answer Yes | `Route12SuperRodHouseFishingGuruScript` | `EVENT_GOT_SUPER_ROD` |

**Trainers** / **Wild encounters**

None.

---

### MAP_ROUTE_13

- Script: `maps/Route13.asm`
- Blocks: `maps/Route13.blk`
- Header: `data/maps/maps.asm:361` -> `map Route13, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_13, MUSIC_ROUTE_12, FALSE, PALETTE_AUTO, FISHGROUP_QWILFISH_NO_SWARM`
- Dimensions: `constants/map_constants.asm:333` -> `map_const ROUTE_13, 30, 9` (60x18 cells)
- Attributes/connections: `data/maps/attributes.asm:324-326` -> `$43`; north `Route12` (20), south `Route14` (0)

**Warps** / **Coord events**

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 29 | 13 | `BGEVENT_READ` | `Route13TrainerTips` ("Look! Right there, at the left side of the post.") |
| 41 | 11 | `BGEVENT_READ` | `Route13Sign` |
| 17 | 13 | `BGEVENT_READ` | `Route13DirectionsSign` |
| 30 | 13 | `BGEVENT_ITEM` | `Route13HiddenCalcium` -> `hiddenitem CALCIUM, EVENT_ROUTE_13_HIDDEN_CALCIUM` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE13_YOUNGSTER1` (2) | `SPRITE_YOUNGSTER` | 42 | 6 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerBirdKeeperPerry` | -1 |
| `ROUTE13_YOUNGSTER2` (3) | `SPRITE_YOUNGSTER` | 43 | 6 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerBirdKeeperBret` | -1 |
| `ROUTE13_POKEFAN_M1` (4) | `SPRITE_POKEFAN_M` | 32 | 8 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerPokefanmJoshua` | -1 |
| `ROUTE13_POKEFAN_M2` (5) | `SPRITE_POKEFAN_M` | 14 | 10 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerHikerKenny` | -1 |
| `ROUTE13_POKEFAN_M3` (6) | `SPRITE_POKEFAN_M` | 25 | 6 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerPokefanmAlex` | -1 |

Kenny is class `HIKER` but wears `SPRITE_POKEFAN_M`.

**Cut trees**

`maps/Route13.blk` block (22, 2) = `$34` (`CUT_TREE` in the top-left quadrant)
-> face walk cell (44, 4). Not mentioned by the walkthrough.

**Scripts of interest**

All five trainers use the plain `trainer <CLASS>, <NAME>, EVENT_BEAT_*, ...` +
`endifjustbattled` pattern. `Route13HiddenCalcium` is the only item.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_BIRD_KEEPER_PERRY` | `constants/event_flags.asm` | `TrainerBirdKeeperPerry` | trainer beaten |
| `EVENT_BEAT_BIRD_KEEPER_BRET` | `constants/event_flags.asm` | `TrainerBirdKeeperBret` | trainer beaten |
| `EVENT_BEAT_POKEFANM_JOSHUA` | `constants/event_flags.asm` | `TrainerPokefanmJoshua` | trainer beaten |
| `EVENT_BEAT_POKEFANM_ALEX` | `constants/event_flags.asm` | `TrainerPokefanmAlex` | trainer beaten |
| `EVENT_BEAT_HIKER_KENNY` | `constants/event_flags.asm` | `TrainerHikerKenny` | trainer beaten |
| `EVENT_ROUTE_13_HIDDEN_CALCIUM` | `constants/event_flags.asm:244` | `Route13HiddenCalcium` | hidden item taken |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `CALCIUM` | hidden, face (30, 13) (the sign at (29, 13) points at it) | `bg_event 30, 13, BGEVENT_ITEM` | `EVENT_ROUTE_13_HIDDEN_CALCIUM` |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `PERRY` | `BIRD_KEEPER` | BirdKeeper (15) | L34 Farfetch'd | `TrainerBirdKeeperPerry` | none |
| `BRET` | `BIRD_KEEPER` | BirdKeeper (16) | L32 Pidgeotto, L32 Fearow | `TrainerBirdKeeperBret` | none |
| `JOSHUA` | `POKEFANM` | PokefanM (4), `TRAINERTYPE_ITEM` | L23 Pikachu x6, each holding `BERRY` | `TrainerPokefanmJoshua` | none |
| `ALEX` | `POKEFANM` | PokefanM (12), `TRAINERTYPE_ITEM` | L29 Nidoking/`BERRY`, L29 Slowking/`BERRY`, L29 Seaking/`BERRY` | `TrainerPokefanmAlex` | none |
| `KENNY` | `HIKER` | Hiker (16) | L27 Sandslash, L29 Graveler, L31 Golem, L29 Graveler | `TrainerHikerKenny` | none |

Base rewards: `BIRD_KEEPER` 6, `POKEFANM` 20, `HIKER` 8.

**Wild encounters**

`data/wild/kanto_grass.asm:756` `def_grass_wildmons ROUTE_13`, 10%/10%/10%,
`_GOLD` arm:

- morn: L23 Nidorina, L23 Nidorino, L25 Pidgeotto, L22 Hoppip, L24 Hoppip, L22 Quagsire, L25 Chansey
- day: L23 Nidorina, L23 Nidorino, L25 Pidgeotto, L22 Hoppip, L24 Hoppip, L24 Hoppip, L25 Chansey
- nite: L23 Nidorina, L23 Nidorino, L25 Noctowl, L22 Quagsire, L24 Quagsire, L24 Quagsire, L25 Chansey

(`_SILVER` swaps the Nidorina/Nidorino order.)

Water: `data/wild/kanto_water.asm:40` `def_water_wildmons ROUTE_13`, 6% -
L25 Tentacool, L25 Quagsire, L25 Tentacruel. Fishing group
`FISHGROUP_QWILFISH_NO_SWARM` (same table as Route 12).

---

### MAP_ROUTE_14

- Script: `maps/Route14.asm`
- Blocks: `maps/Route14.blk`
- Header: `data/maps/maps.asm:362` -> `map Route14, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_14, MUSIC_ROUTE_12, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:334` -> `map_const ROUTE_14, 10, 18` (20x36 cells)
- Attributes/connections: `data/maps/attributes.asm:320-322` -> `$43`; north `Route13` (0), west `Route15` (9)

**Warps** / **Coord events** / **BG events**

None (all three tables are empty).

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE14_POKEFAN_M1` (2) | `SPRITE_POKEFAN_M` | 12 | 14 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerPokefanmCarter` | -1 |
| `ROUTE14_YOUNGSTER` (3) | `SPRITE_YOUNGSTER` | 11 | 27 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerBirdKeeperRoy` | -1 |
| `ROUTE14_POKEFAN_M2` (4) | `SPRITE_POKEFAN_M` | 5 | 9 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerPokefanmTrevor` | -1 |
| `ROUTE14_KIM` (5) | `SPRITE_TEACHER` | 7 | 5 | `WALK_LEFT_RIGHT` (radius 1,0) | `OBJECTTYPE_SCRIPT`, sight 4 | `Kim` | -1 |

**Cut trees**

From `maps/Route14.blk` against `CutTreeBlockPointers.kanto`:

| block (bx, by) | block id | cut quadrant | walk cell to face |
|---|---|---|---|
| (2, 4) | `$35` | top-right | (5, 8) |
| (5, 7) | `$35` | top-right | (11, 14) |
| (1, 12) | `$35` | top-right | (3, 24) |

(5, 8) is directly above Trevor at (5, 9) and opens the pocket that holds Kim.
(11, 14) sits beside Carter at (12, 14). (3, 24) is the tree on the way to the
west connection to Route 15.

**Scripts of interest**

- `Kim` - `faceplayer / opentext / trade NPC_TRADE_KIM / waitbutton / closetext /
  end`. `NPC_TRADE_KIM` is 5 (`constants/npc_trade_constants.asm:22`);
  `data/events/npc_trades.asm:19` ->
  `npctrade TRADE_DIALOGSET_NEWBIE, CHANSEY, AERODACTYL, "AEROY", $96, $66, GOLD_BERRY, 26491, "KIM", TRADE_GENDER_EITHER`.
  You hand over **Chansey**, you receive **Aerodactyl** nicknamed AEROY holding
  `GOLD_BERRY`, OT KIM / ID 26491, DVs `$96`/`$66`. One-shot, tracked in
  `wTradeFlags` by trade id, not by an `EVENT_*`.
- The three trainer scripts are the plain pattern.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_POKEFANM_CARTER` | `constants/event_flags.asm` | `TrainerPokefanmCarter` | trainer beaten |
| `EVENT_BEAT_BIRD_KEEPER_ROY` | `constants/event_flags.asm` | `TrainerBirdKeeperRoy` | trainer beaten |
| `EVENT_BEAT_POKEFANM_TREVOR` | `constants/event_flags.asm` | `TrainerPokefanmTrevor` | trainer beaten |
| `NPC_TRADE_KIM` | `constants/npc_trade_constants.asm:22` | `Kim` | trade slot 5, stored in `wTradeFlags` |

**Items**

None on this map.

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `TREVOR` | `POKEFANM` | PokefanM (6), `TRAINERTYPE_ITEM` | L33 Psyduck/`BERRY` | `TrainerPokefanmTrevor` | none |
| `CARTER` | `POKEFANM` | PokefanM (5), `TRAINERTYPE_ITEM` | L29 Bulbasaur/`BERRY`, L29 Charmander/`BERRY`, L29 Squirtle/`BERRY` | `TrainerPokefanmCarter` | none |
| `ROY` | `BIRD_KEEPER` | BirdKeeper (9) | L29 Fearow, L35 Fearow | `TrainerBirdKeeperRoy` | none |

**Wild encounters**

`data/wild/kanto_grass.asm:811` `def_grass_wildmons ROUTE_14`, 10%/10%/10%,
`_GOLD` arm:

- morn: L23 Nidorina, L23 Nidorino, L25 Pidgeotto, L24 Hoppip, L26 Skiploom, L22 Quagsire, L25 Chansey
- day: L23 Nidorina, L23 Nidorino, L25 Pidgeotto, L24 Hoppip, L26 Skiploom, L26 Skiploom, L25 Chansey
- nite: L23 Nidorina, L23 Nidorino, L25 Noctowl, L22 Quagsire, L24 Quagsire, L24 Quagsire, L25 Chansey

No water table for `ROUTE_14`. Fishing group `FISHGROUP_SHORE`.

---

### MAP_ROUTE_15

- Script: `maps/Route15.asm`
- Blocks: `maps/Route15.blk`
- Header: `data/maps/maps.asm:363` -> `map Route15, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_15, MUSIC_ROUTE_12, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:335` -> `map_const ROUTE_15, 20, 9` (40x18 cells)
- Attributes/connections: `data/maps/attributes.asm:316-318` -> `$0f`; west `FuchsiaCity` (-9), east `Route14` (-9)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 4 | `ROUTE_15_FUCHSIA_GATE` | 3 |
| 2 | 2 | 5 | `ROUTE_15_FUCHSIA_GATE` | 4 |

**Coord events**

None.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 19 | 9 | `BGEVENT_READ` | `Route15Sign` (documented lowercase-"Route 15" bug, `maps/Route15.asm:196`) |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE15_YOUNGSTER1` (2) | `SPRITE_YOUNGSTER` | 11 | 10 | `STANDING_UP` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerSchoolboyKipp` | -1 |
| `ROUTE15_YOUNGSTER2` (3) | `SPRITE_YOUNGSTER` | 11 | 11 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerSchoolboyTommy` | -1 |
| `ROUTE15_YOUNGSTER3` (4) | `SPRITE_YOUNGSTER` | 33 | 10 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerSchoolboyJohnny` | -1 |
| `ROUTE15_YOUNGSTER4` (5) | `SPRITE_YOUNGSTER` | 27 | 10 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerSchoolboyBilly` | -1 |
| `ROUTE15_TEACHER1` (6) | `SPRITE_TEACHER` | 30 | 12 | `STANDING_UP` | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerTeacherColette` | -1 |
| `ROUTE15_TEACHER2` (7) | `SPRITE_TEACHER` | 16 | 10 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerTeacherHillary` | -1 |
| `ROUTE15_POKE_BALL` (8) | `SPRITE_POKE_BALL` | 12 | 5 | `STILL` | `OBJECTTYPE_ITEMBALL` | `Route15PPUp` (`itemball PP_UP`) | `EVENT_ROUTE_15_PP_UP` |

**Cut trees**

None. `maps/Route15.blk` contains no `TILESET_KANTO` cut-tree block
(`$32`/`$33`/`$34`/`$35`/`$60`). See "Unresolved".

**Scripts of interest**

All six trainers are the plain pattern. `Route15PPUp` is `itemball PP_UP`.

Walkthrough fight order maps to: Johnny (33, 10) -> Colette (30, 12) ->
Billy (27, 10) -> Hillary (16, 10) -> Tommy (11, 11) -> Kipp (11, 10),
i.e. east to west along row y=10.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_SCHOOLBOY_JOHNNY` | `constants/event_flags.asm` | `TrainerSchoolboyJohnny` | trainer beaten |
| `EVENT_BEAT_TEACHER_COLETTE` | `constants/event_flags.asm` | `TrainerTeacherColette` | trainer beaten |
| `EVENT_BEAT_SCHOOLBOY_BILLY` | `constants/event_flags.asm` | `TrainerSchoolboyBilly` | trainer beaten |
| `EVENT_BEAT_TEACHER_HILLARY` | `constants/event_flags.asm` | `TrainerTeacherHillary` | trainer beaten |
| `EVENT_BEAT_SCHOOLBOY_TOMMY` | `constants/event_flags.asm` | `TrainerSchoolboyTommy` | trainer beaten |
| `EVENT_BEAT_SCHOOLBOY_KIP` | `constants/event_flags.asm` | `TrainerSchoolboyKipp` | trainer beaten (note the flag drops the second "p") |
| `EVENT_ROUTE_15_PP_UP` | `constants/event_flags.asm:1325` | itemball object | ball consumed |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `PP_UP` | itemball at (12, 5) | `Route15PPUp` | `EVENT_ROUTE_15_PP_UP` |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `JOHNNY` | `SCHOOLBOY` | Schoolboy (4) | L29 Bellsprout, L31 Weepinbell, L33 Victreebel | `TrainerSchoolboyJohnny` | none |
| `COLETTE` | `TEACHER` | Teacher (1) | L36 Clefairy | `TrainerTeacherColette` | none |
| `BILLY` | `SCHOOLBOY` | Schoolboy (9) | L27 Paras, L27 Paras, L27 Poliwhirl, L35 Ditto | `TrainerSchoolboyBilly` | none |
| `HILLARY` | `TEACHER` | Teacher (2) | L32 Aipom, L36 Cubone | `TrainerTeacherHillary` | none |
| `TOMMY` | `SCHOOLBOY` | Schoolboy (6) | L32 Xatu, L34 Alakazam | `TrainerSchoolboyTommy` | none |
| `KIPP` | `SCHOOLBOY` | Schoolboy (2) | L27 Voltorb, L27 Magnemite, L31 Voltorb, L31 Magneton | `TrainerSchoolboyKipp` | none |

Base rewards: `SCHOOLBOY` 8, `TEACHER` 18.

**Wild encounters**

`data/wild/kanto_grass.asm:866` `def_grass_wildmons ROUTE_15`, 10%/10%/10%,
`_GOLD` arm:

- morn: L23 Nidorina, L23 Nidorino, L25 Pidgeotto, L22 Hoppip, L24 Hoppip, L22 Quagsire, L25 Chansey
- day: L23 Nidorina, L23 Nidorino, L25 Pidgeotto, L22 Hoppip, L24 Hoppip, L24 Hoppip, L25 Chansey
- nite: L23 Nidorina, L23 Nidorino, L25 Noctowl, L22 Quagsire, L24 Quagsire, L24 Quagsire, L25 Chansey

---

### MAP_ROUTE_15_FUCHSIA_GATE

- Script: `maps/Route15FuchsiaGate.asm`
- Header: `data/maps/maps.asm:373` -> `map Route15FuchsiaGate, TILESET_GATE, GATE, LANDMARK_ROUTE_15, MUSIC_ROUTE_12, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:345` -> `map_const ROUTE_15_FUCHSIA_GATE, 5, 4`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 4 | `FUCHSIA_CITY` | 8 |
| 2 | 0 | 5 | `FUCHSIA_CITY` | 9 |
| 3 | 9 | 4 | `ROUTE_15` | 1 |
| 4 | 9 | 5 | `ROUTE_15` | 2 |

**Coord events** / **BG events**

None. This gate has **no** bicycle or badge check - it is free passage.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE15FUCHSIAGATE_OFFICER` (2) | `SPRITE_OFFICER` | 5 | 2 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route15FuchsiaGateOfficerScript` (`jumptextfaceplayer`) | -1 |

---

### MAP_FUCHSIA_CITY

- Script: `maps/FuchsiaCity.asm`
- Blocks: `maps/FuchsiaCity.blk`
- Header: `data/maps/maps.asm:365` -> `map FuchsiaCity, TILESET_KANTO, TOWN, LANDMARK_FUCHSIA_CITY, MUSIC_CELADON_CITY, FALSE, PALETTE_AUTO, FISHGROUP_GYARADOS`
- Dimensions: `constants/map_constants.asm:337` -> `map_const FUCHSIA_CITY, 20, 18` (40x36 cells)
- Attributes/connections: `data/maps/attributes.asm:291-294` -> `$0f`; south `Route19` (0), west `Route18` (7), east `Route15` (9)
- Fly spawn: `data/maps/spawn_points.asm:23` -> `spawn FUCHSIA_CITY, 19, 28`; `data/maps/flypoints.asm:27` -> `db LANDMARK_FUCHSIA_CITY, SPAWN_FUCHSIA`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 13 | `FUCHSIA_MART` | 2 |
| 2 | 22 | 13 | `SAFARI_ZONE_MAIN_OFFICE` | 1 |
| 3 | 8 | 27 | `FUCHSIA_GYM` | 1 |
| 4 | 11 | 27 | `BILLS_OLDER_SISTERS_HOUSE` | 1 |
| 5 | 19 | 27 | `FUCHSIA_POKECENTER_1F` | 1 |
| 6 | 27 | 27 | `SAFARI_ZONE_WARDENS_HOME` | 1 |
| 7 | 18 | 3 | `SAFARI_ZONE_FUCHSIA_GATE_BETA` | 3 (commented `; inaccessible` in the asm) |
| 8 | 37 | 22 | `ROUTE_15_FUCHSIA_GATE` | 1 |
| 9 | 37 | 23 | `ROUTE_15_FUCHSIA_GATE` | 2 |
| 10 | 7 | 35 | `ROUTE_19_FUCHSIA_GATE` | 1 |
| 11 | 8 | 35 | `ROUTE_19_FUCHSIA_GATE` | 2 |

Warp 7 is the "the door is gone" Safari Zone entrance: the warp row exists but
the block behind it is not walkable, which is why the walkthrough says the door
is missing.

**Coord events**

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 21 | 15 | `BGEVENT_READ` | `FuchsiaCitySign` |
| 5 | 29 | `BGEVENT_READ` | `FuchsiaGymSign` |
| 25 | 15 | `BGEVENT_READ` | `SafariZoneOfficeSign` |
| 27 | 29 | `BGEVENT_READ` | `WardensHomeSign` |
| 17 | 5 | `BGEVENT_READ` | `SafariZoneClosedSign` |
| 13 | 15 | `BGEVENT_READ` | `NoLitteringSign` |
| 20 | 27 | `BGEVENT_READ` | `FuchsiaCityPokecenterSign` (`jumpstd PokecenterSignScript`) |
| 6 | 13 | `BGEVENT_READ` | `FuchsiaCityMartSign` (`jumpstd MartSignScript`) |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `FUCHSIACITY_YOUNGSTER` (2) | `SPRITE_YOUNGSTER` | 23 | 18 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `FuchsiaCityYoungster` | -1 |
| `FUCHSIACITY_POKEFAN_M` (3) | `SPRITE_POKEFAN_M` | 13 | 8 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `FuchsiaCityPokefanM` | -1 |
| `FUCHSIACITY_TEACHER` (4) | `SPRITE_TEACHER` | 16 | 14 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `FuchsiaCityTeacher` | -1 |
| `FUCHSIACITY_FRUIT_TREE` (5) | `SPRITE_FRUIT_TREE` | 8 | 1 | `STILL` | `OBJECTTYPE_SCRIPT` | `FuchsiaCityFruitTree` (`fruittree FRUITTREE_FUCHSIA_CITY`) | -1 |

**Cut trees**

`maps/FuchsiaCity.blk`: block (8, 5) and block (9, 9), both `$60` (`CUT_TREE`
in the bottom-left quadrant) -> face walk cells (16, 11) and (18, 19). Neither
is required by this section.

**Scripts of interest**

- `FuchsiaCityFlypointCallback` (`4e:53c4`) - registered as
  `callback MAPCALLBACK_NEWMAP`; body is `setflag ENGINE_FLYPOINT_FUCHSIA /
  endcallback`. Runs on the first map load, so simply arriving unlocks Fly here.
- `FuchsiaCityFruitTree` - `fruittree FRUITTREE_FUCHSIA_CITY`.
  `data/items/fruit_trees.asm` slot 30 (`$1e`) = `BURNT_BERRY`, which is the
  walkthrough's "Burnt Berry in the northwest part of town" - the tree object at
  (8, 1) is the north-west corner of the map.
- `SafariZoneClosedSign` / `SafariZoneOfficeSign` - flavour text only; there is
  no event flag or script that ever reopens the Safari Zone.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_FUCHSIA` | `constants/engine_flags.asm:76` | `FuchsiaCityFlypointCallback` | Fuchsia becomes a Fly destination |
| `FRUITTREE_FUCHSIA_CITY` | `constants/script_constants.asm:236` | `FuchsiaCityFruitTree` | fruit tree slot 30 |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `BURNT_BERRY` | talk to the tree object at (8, 1) | `FuchsiaCityFruitTree` / `data/items/fruit_trees.asm` | none (daily tree) |

**Trainers**

None on the overworld map.

**Wild encounters**

No grass table. Water: `data/wild/kanto_water.asm:152`
`def_water_wildmons FUCHSIA_CITY`, 2% - L20 Magikarp, L15 Magikarp, L10 Magikarp.
Fishing group `FISHGROUP_GYARADOS` (`data/wild/fish.asm:132-145`):
Old rod Magikarp 10 x3; Good rod Magikarp 20 x3 + `time_group 14` (Gyarados 20);
Super rod Magikarp 40 (40%), `time_group 15` (Gyarados 40), Magikarp 40, Magikarp 40.

---

### MAP_FUCHSIA_POKECENTER_1F

- Script: `maps/FuchsiaPokecenter1F.asm`
- Header: `data/maps/maps.asm:370` -> `map FuchsiaPokecenter1F, TILESET_POKECENTER, INDOOR, LANDMARK_FUCHSIA_CITY, MUSIC_POKEMON_CENTER, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:342` -> `map_const FUCHSIA_POKECENTER_1F, 5, 4`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `FUCHSIA_CITY` | 5 |
| 2 | 4 | 7 | `FUCHSIA_CITY` | 5 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

Healing is `FuchsiaPokecenter1FNurseScript` -> `jumpstd PokecenterNurseScript`
(object const `FUCHSIAPOKECENTER1F_NURSE` = 2). The map also contains a
`FUCHSIAPOKECENTER1F_JANINE_IMPERSONATOR` NPC that spins and `variablesprite`s
itself into `SPRITE_JANINE` - flavour, no flags.

---

### MAP_ROUTE_16

- Script: `maps/Route16.asm`
- Blocks: `maps/Route16.blk`
- Header: `data/maps/maps.asm:413` -> `map Route16, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_16, MUSIC_ROUTE_3, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:381` -> `map_const ROUTE_16, 10, 9` (20x18 cells)
- Attributes/connections: `data/maps/attributes.asm:304-306` -> `$0f`; south `Route17` (0), east `CeladonCity` (-9)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 1 | `ROUTE_16_FUCHSIA_SPEECH_HOUSE` | 1 |
| 2 | 14 | 6 | `ROUTE_16_GATE` | 3 |
| 3 | 14 | 7 | `ROUTE_16_GATE` | 4 |
| 4 | 9 | 6 | `ROUTE_16_GATE` | 1 |
| 5 | 9 | 7 | `ROUTE_16_GATE` | 2 |

**Coord events**

None.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 5 | 5 | `BGEVENT_READ` | `CyclingRoadSign` |

**Object events**

None (`def_object_events` is empty).

**Cut trees**

`maps/Route16.blk` block (7, 2) = `$32` (`CUT_TREE` top-right) -> face walk
cell (15, 4). This is the tree the walkthrough calls "north of the
route-changing building". Cut trees are **not** persisted: leaving the map (for
example into `ROUTE_16_FUCHSIA_SPEECH_HOUSE`) reloads the block from
`Route16.blk` and the tree is back, which is exactly the behaviour the
walkthrough describes.

**Scripts of interest**

`Route16AlwaysOnBikeCallback` (`4e:5a8f`), a `MAPCALLBACK_NEWMAP` callback:

```
readvar VAR_YCOORD
ifless 5, .CanWalk
readvar VAR_XCOORD
ifgreater 13, .CanWalk
setflag ENGINE_ALWAYS_ON_BIKE
endcallback
.CanWalk:
clearflag ENGINE_ALWAYS_ON_BIKE
endcallback
```

So the north-west corner of Route 16 (`y < 5`, or `x > 13`) is walkable; the
rest of the map forces the bike. Because this is a `MAPCALLBACK_NEWMAP`, it only
re-evaluates on a map load, not while walking.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_ALWAYS_ON_BIKE` | `constants/engine_flags.asm:35` | `Route16AlwaysOnBikeCallback` | dismount, Surf and (via `BIKEFLAGS_ALWAYS_ON_BIKE_F`) some menu actions are refused |

**Wild encounters**

`data/wild/kanto_grass.asm:921` `def_grass_wildmons ROUTE_16`, 10%/10%/10%:

- morn/day (identical): L26 Grimer, L27 Fearow, L28 Grimer, L29 Fearow, L27 Slugma, L30 Muk, L30 Muk
- nite: L26 Grimer, L27 Grimer, L28 Grimer, L28 Murkrow, L27 Slugma, L30 Muk, L30 Muk

The walkthrough's "Fearow / Grimer" summary is the morn/day view; at night
Fearow is replaced by Grimer and Murkrow.

---

### MAP_ROUTE_16_GATE

- Script: `maps/Route16Gate.asm`
- Header: `data/maps/maps.asm:435` -> `map Route16Gate, TILESET_GATE, GATE, LANDMARK_ROUTE_16, MUSIC_ROUTE_3, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:403` -> `map_const ROUTE_16_GATE, 5, 4`
- Scene variable: `data/maps/scenes.asm:18` -> `scene_var ROUTE_16_GATE, wRoute16GateSceneID`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 4 | `ROUTE_16` | 4 |
| 2 | 0 | 5 | `ROUTE_16` | 5 |
| 3 | 9 | 4 | `ROUTE_16` | 2 |
| 4 | 9 | 5 | `ROUTE_16` | 3 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_ROUTE16GATE_BICYCLE_CHECK` (= 0) | 5 | 4 | `Route16GateBicycleCheck` | `checkitem BICYCLE`; on failure, shove the player one step RIGHT |
| `SCENE_ROUTE16GATE_BICYCLE_CHECK` (= 0) | 5 | 5 | `Route16GateBicycleCheck` | same |

`SCENE_ROUTE16GATE_BICYCLE_CHECK` is generated by the `scene_script` macro
(`macros/scripts/maps.asm:25`, which emits `scene_const` into a `const_def`
starting at 0), so its value is 0. Nothing anywhere calls `setmapscene` on this
map, so the scene never changes and the coord event fires on **every** pass.

**BG events**

None.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE16GATE_OFFICER` (2) | `SPRITE_OFFICER` | 5 | 2 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route16GateOfficerScript` | -1 |

**Scripts of interest**

`Route16GateBicycleCheck` (`5e:67cb`):

```
checkitem BICYCLE
iffalse .NoBicycle
end
.NoBicycle:
showemote EMOTE_SHOCK, ROUTE16GATE_OFFICER, 15
turnobject PLAYER, UP
opentext / writetext Route16GateCannotPassText / waitbutton / closetext
applymovement PLAYER, Route16GateCannotPassMovement   ; step RIGHT, turn_head LEFT
end
```

`checkitem` is a **bag** check, not a "is the bike out" check: the BICYCLE must
be in the pack, but the player does not have to be riding it to pass.

---

### MAP_ROUTE_16_FUCHSIA_SPEECH_HOUSE

- Script: `maps/Route16FuchsiaSpeechHouse.asm`
- Header: `data/maps/maps.asm:434` -> `map Route16FuchsiaSpeechHouse, TILESET_HOUSE, INDOOR, LANDMARK_ROUTE_16, MUSIC_CELADON_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:402` -> `map_const ROUTE_16_FUCHSIA_SPEECH_HOUSE, 4, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `ROUTE_16` | 1 |
| 2 | 3 | 7 | `ROUTE_16` | 1 |

**BG events**: (0, 1) and (1, 1), both `BGEVENT_READ` ->
`Route16FuchsiaSpeechHouseBookshelf` (`jumpstd PictureBookshelfScript`).

**Object events**: `ROUTE16FUCHSIASPEECHHOUSE_SUPER_NERD` (2),
`SPRITE_SUPER_NERD` at (2, 3), `STANDING_DOWN`, `OBJECTTYPE_SCRIPT`,
`Route16FuchsiaSpeechHouseSuperNerdScript` (text only).

This is the building whose entry/exit regrows the Route 16 cut tree.

---

### MAP_ROUTE_17

- Script: `maps/Route17.asm`
- Blocks: `maps/Route17.blk`
- Header: `data/maps/maps.asm:414` -> `map Route17, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_17, MUSIC_ROUTE_3, FALSE, PALETTE_AUTO, FISHGROUP_NONE`
- Dimensions: `constants/map_constants.asm:382` -> `map_const ROUTE_17, 10, 45` (20x90 cells)
- Attributes/connections: `data/maps/attributes.asm:300-302` -> `$43`; north `Route16` (0), east `Route18` (38)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 17 | 82 | `ROUTE_17_ROUTE_18_GATE` | 1 |
| 2 | 17 | 83 | `ROUTE_17_ROUTE_18_GATE` | 2 |

**Coord events**

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 12 | 5 | `BGEVENT_ITEM` | `Route17HiddenMaxEther` -> `hiddenitem MAX_ETHER, EVENT_ROUTE_17_HIDDEN_MAX_ETHER` |
| 8 | 77 | `BGEVENT_ITEM` | `Route17HiddenMaxElixer` -> `hiddenitem MAX_ELIXER, EVENT_ROUTE_17_HIDDEN_MAX_ELIXER` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE17_BIKER1` (2) | `SPRITE_BIKER` | 4 | 17 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerBikerRiley` | -1 |
| `ROUTE17_BIKER2` (3) | `SPRITE_BIKER` | 16 | 32 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerBikerJoel` | -1 |
| `ROUTE17_BIKER3` (4) | `SPRITE_BIKER` | 3 | 53 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerBikerGlenn` | -1 |
| `ROUTE17_BIKER4` (5) | `SPRITE_BIKER` | 6 | 80 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerBikerCharles` | -1 |

Note the y-order: Riley (17) -> Joel (32) -> Glenn (53) -> Charles (80). The
walkthrough fights Riley, Glenn, Joel, Charles; Joel at (16, 32) is on the right
bank (the walkthrough's "bridge across the river to the right") and Glenn at
(3, 53) is further down the left, so the asm ordering by y is
Riley -> Joel -> Glenn -> Charles.

**Scripts of interest**

`Route17AlwaysOnBikeCallback` (`4e:5822`), a `MAPCALLBACK_NEWMAP` callback:

```
setflag ENGINE_ALWAYS_ON_BIKE
setflag ENGINE_DOWNHILL
endcallback
```

Unconditional for the whole map. `ENGINE_DOWNHILL` is what
`engine/overworld/player_movement.asm:13` `.GetDPad` reads (the `bit
BIKEFLAGS_DOWNHILL_F, [hl]` at line 20): on a downhill map
a frame with **no** d-pad held is rewritten to `PAD_DOWN`, i.e. the bike coasts
south on its own; and `player_movement.asm:277-292` downgrades any non-DOWN bike
step from `STEP_BIKE` to `STEP_WALK`, which is the "uphill is slower" behaviour.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_ALWAYS_ON_BIKE` | `constants/engine_flags.asm:35` | `Route17AlwaysOnBikeCallback` | cannot dismount, cannot Surf |
| `ENGINE_DOWNHILL` | `constants/engine_flags.asm:36` | `Route17AlwaysOnBikeCallback` | idle frames auto-step DOWN |
| `EVENT_BEAT_BIKER_RILEY` / `_JOEL` / `_GLENN` / `_CHARLES` | `constants/event_flags.asm` | the four trainer scripts | trainers beaten |
| `EVENT_ROUTE_17_HIDDEN_MAX_ETHER` | `constants/event_flags.asm:246` | `Route17HiddenMaxEther` | hidden item taken |
| `EVENT_ROUTE_17_HIDDEN_MAX_ELIXER` | `constants/event_flags.asm:247` | `Route17HiddenMaxElixer` | hidden item taken |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `MAX_ETHER` | hidden, face (12, 5) | `bg_event 12, 5, BGEVENT_ITEM` | `EVENT_ROUTE_17_HIDDEN_MAX_ETHER` |
| `MAX_ELIXER` | hidden, face (8, 77) | `bg_event 8, 77, BGEVENT_ITEM` | `EVENT_ROUTE_17_HIDDEN_MAX_ELIXER` |

Neither is mentioned by the walkthrough.

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `RILEY` | `BIKER` | Biker (7) | L34 Weezing | `TrainerBikerRiley` | none |
| `GLENN` | `BIKER` | Biker (9) | L28 Koffing, L30 Magmar, L32 Weezing | `TrainerBikerGlenn` | none |
| `JOEL` | `BIKER` | Biker (8) | L32 Magmar, L32 Magmar | `TrainerBikerJoel` | none |
| `CHARLES` | `BIKER` | Biker (6) | L30 Koffing, L30 Charmeleon, L30 Weezing | `TrainerBikerCharles` | none |

`BIKER` base reward 8 (`attributes.asm:271`).

**Wild encounters**

`data/wild/kanto_grass.asm:949` `def_grass_wildmons ROUTE_17`, 10%/10%/10%
(this route's three time bands genuinely differ):

- morn: L28 Fearow, L27 Grimer, L29 Grimer, L30 Fearow, L29 Slugma, L32 Muk, L32 Muk
- day: L28 Fearow, L27 Slugma, L29 Grimer, L30 Fearow, L25 Slugma, L32 Muk, L32 Muk
- nite: L28 Grimer, L27 Grimer, L29 Grimer, L30 Muk, L29 Slugma, L32 Muk, L32 Muk

Fishing group is `FISHGROUP_NONE`.

---

### MAP_ROUTE_17_ROUTE_18_GATE

- Script: `maps/Route17Route18Gate.asm`
- Header: `data/maps/maps.asm:437` -> `map Route17Route18Gate, TILESET_GATE, GATE, LANDMARK_ROUTE_17, MUSIC_ROUTE_3, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:405` -> `map_const ROUTE_17_ROUTE_18_GATE, 5, 4`
- Scene variable: `data/maps/scenes.asm:19` -> `scene_var ROUTE_17_ROUTE_18_GATE, wRoute17Route18GateSceneID`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 4 | `ROUTE_17` | 1 |
| 2 | 0 | 5 | `ROUTE_17` | 2 |
| 3 | 9 | 4 | `ROUTE_18` | 1 |
| 4 | 9 | 5 | `ROUTE_18` | 2 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_ROUTE17ROUTE18GATE_BICYCLE_CHECK` (= 0) | 5 | 4 | `Route17Route18GateBicycleCheck` | `checkitem BICYCLE`; on failure, shove one step RIGHT |
| `SCENE_ROUTE17ROUTE18GATE_BICYCLE_CHECK` (= 0) | 5 | 5 | `Route17Route18GateBicycleCheck` | same |

**BG events**

None.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE17ROUTE18GATE_OFFICER` (2) | `SPRITE_OFFICER` | 5 | 2 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route17Route18GateOfficerScript` | -1 |

`Route17Route18GateBicycleCheck` (`5e:69ef`) is byte-for-byte the same shape as
the Route 16 one, with `Route17Route18GateCannotPassText`.

Important asymmetry for a bot: the shove movement is `step RIGHT`, so the check
only actually blocks the **west-to-east** direction (walking off Route 17 into
the gate at x=5). Coming from Route 18 you enter at x=9 and the coord event at
x=5 still fires, but the shove pushes you further right, back the way you came.

---

### MAP_ROUTE_18

- Script: `maps/Route18.asm`
- Blocks: `maps/Route18.blk`
- Header: `data/maps/maps.asm:364` -> `map Route18, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_18, MUSIC_ROUTE_3, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:336` -> `map_const ROUTE_18, 10, 9` (20x18 cells)
- Attributes/connections: `data/maps/attributes.asm:296-298` -> `$43`; west `Route17` (-38), east `FuchsiaCity` (-7)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 6 | `ROUTE_17_ROUTE_18_GATE` | 3 |
| 2 | 2 | 7 | `ROUTE_17_ROUTE_18_GATE` | 4 |

**Coord events**

None.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 9 | 5 | `BGEVENT_READ` | `Route18Sign` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE18_YOUNGSTER1` (2) | `SPRITE_YOUNGSTER` | 9 | 12 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerBirdKeeperBoris` | -1 |
| `ROUTE18_YOUNGSTER2` (3) | `SPRITE_YOUNGSTER` | 13 | 6 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerBirdKeeperBob` | -1 |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `BOB` | `BIRD_KEEPER` | BirdKeeper (11) | L34 Noctowl | `TrainerBirdKeeperBob` | none |
| `BORIS` | `BIRD_KEEPER` | BirdKeeper (10) | L30 Doduo, L28 Doduo, L32 Dodrio | `TrainerBirdKeeperBoris` | none |

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_BIRD_KEEPER_BOB` | `constants/event_flags.asm` | `TrainerBirdKeeperBob` | trainer beaten |
| `EVENT_BEAT_BIRD_KEEPER_BORIS` | `constants/event_flags.asm` | `TrainerBirdKeeperBoris` | trainer beaten |

**Items**

None.

**Wild encounters**

`data/wild/kanto_grass.asm:977` `def_grass_wildmons ROUTE_18`, 10%/10%/10%:

- morn/day (identical): L26 Grimer, L27 Fearow, L28 Grimer, L29 Fearow, L27 Slugma, L30 Muk, L30 Muk
- nite: L26 Grimer, L27 Grimer, L28 Grimer, L28 Muk, L27 Slugma, L30 Muk, L30 Muk

---

### MAP_FUCHSIA_GYM

- Script: `maps/FuchsiaGym.asm`
- Blocks: `maps/FuchsiaGym.blk`
- Header: `data/maps/maps.asm:368` -> `map FuchsiaGym, TILESET_LAB, INDOOR, LANDMARK_FUCHSIA_CITY, MUSIC_GYM, TRUE, PALETTE_DAY, FISHGROUP_SHORE` (the `TRUE` is the phone-service flag: phone calls are suppressed here)
- Dimensions: `constants/map_constants.asm:340` -> `map_const FUCHSIA_GYM, 5, 9` (10x18 cells)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 17 | `FUCHSIA_CITY` | 3 |
| 2 | 5 | 17 | `FUCHSIA_CITY` | 3 |

**Coord events**

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 3 | 15 | `BGEVENT_READ` | `FuchsiaGymStatue` |
| 6 | 15 | `BGEVENT_READ` | `FuchsiaGymStatue` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `FUCHSIAGYM_JANINE` (2) | `SPRITE_JANINE` | 1 | 10 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `FuchsiaGymJanineScript` | -1 |
| `FUCHSIAGYM_FUCHSIA_GYM_1` (3) | `SPRITE_FUCHSIA_GYM_1` | 5 | 7 | `SPINRANDOM_FAST` | `OBJECTTYPE_SCRIPT` | `LassAliceScript` | -1 |
| `FUCHSIAGYM_FUCHSIA_GYM_2` (4) | `SPRITE_FUCHSIA_GYM_2` | 5 | 11 | `SPINRANDOM_FAST` | `OBJECTTYPE_SCRIPT` | `LassLindaScript` | -1 |
| `FUCHSIAGYM_FUCHSIA_GYM_3` (5) | `SPRITE_FUCHSIA_GYM_3` | 9 | 4 | `SPINRANDOM_FAST` | `OBJECTTYPE_SCRIPT` | `PicnickerCindyScript` | -1 |
| `FUCHSIAGYM_FUCHSIA_GYM_4` (6) | `SPRITE_FUCHSIA_GYM_4` | 4 | 2 | `SPINRANDOM_FAST` | `OBJECTTYPE_SCRIPT` | `CamperBarryScript` | -1 |
| `FUCHSIAGYM_GYM_GUIDE` (7) | `SPRITE_GYM_GUIDE` | 7 | 15 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `FuchsiaGymGuideScript` | -1 |

Every gym trainer here is `OBJECTTYPE_SCRIPT`, **not** `OBJECTTYPE_TRAINER` -
there are no sight lines, so a bot must walk up and press A. The walkthrough's
route order matches: Linda (5, 11) -> Cindy (9, 4) -> Barry (4, 2) ->
Alice (5, 7) -> Janine (1, 10).

**Scripts of interest**

`LassAliceScript` / `LassLindaScript` / `PicnickerCindyScript` /
`CamperBarryScript` share one shape:

```
checkevent EVENT_BEAT_<NAME>
iftrue .Unmasked
applymovement <OBJ>, Movement_NinjaSpin      ; 13 turn_head steps
faceplayer
variablesprite SPRITE_FUCHSIA_GYM_n, SPRITE_LASS|SPRITE_YOUNGSTER
special LoadUsedSpritesGFX
.Unmasked:
faceplayer / opentext
checkevent EVENT_BEAT_<NAME>
iftrue .AfterScript
writetext <before> / waitbutton / closetext
winlosstext <beaten>, 0
loadtrainer <CLASS>, <NAME>
startbattle
iftrue .BecomesJanine                        ; wScriptVar != WIN
reloadmapafterbattle
setevent EVENT_BEAT_<NAME>
end
.BecomesJanine:
variablesprite SPRITE_FUCHSIA_GYM_n, SPRITE_JANINE
reloadmapafterbattle
end
```

`Script_startbattle` (`engine/overworld/scripting.asm:1065`) copies
`wBattleResult & ~BATTLERESULT_BITMASK` into `wScriptVar`, so `iftrue` after
`startbattle` means "did not win". Losing to an impostor leaves its beat-event
clear and repaints it as `SPRITE_JANINE`.

`FuchsiaGymJanineScript` (`5c:40d3`):

```
checkflag ENGINE_SOULBADGE
iftrue .FightDone
applymovement FUCHSIAGYM_JANINE, Movement_NinjaSpin
faceplayer / opentext
writetext JanineText_DisappointYou / waitbutton / closetext
winlosstext JanineText_ToughOne, 0
loadtrainer JANINE, JANINE1
startbattle
reloadmapafterbattle
setevent EVENT_BEAT_JANINE
setevent EVENT_BEAT_LASS_ALICE
setevent EVENT_BEAT_LASS_LINDA
setevent EVENT_BEAT_PICNICKER_CINDY
setevent EVENT_BEAT_CAMPER_BARRY
variablesprite SPRITE_FUCHSIA_GYM_1..3 -> SPRITE_LASS, _4 -> SPRITE_YOUNGSTER
special LoadUsedSpritesGFX
opentext / writetext Text_ReceivedSoulBadge / playsound SFX_GET_BADGE / waitsfx
setflag ENGINE_SOULBADGE
sjump .AfterBattle
.FightDone: faceplayer / opentext
.AfterBattle:
checkevent EVENT_GOT_TM06_TOXIC
iftrue .AfterTM
writetext JanineText_ToxicSpeech / promptbutton
verbosegiveitem TM_TOXIC
iffalse .AfterTM                              ; bag full -> no event set
setevent EVENT_GOT_TM06_TOXIC
.AfterTM: writetext JanineText_ApplyMyself / waitbutton / closetext / end
```

Three bot-critical facts:

1. There is **no** `iftrue` after Janine's `startbattle`. The badge, the four
   impostor beat-events and `ENGINE_SOULBADGE` are set unconditionally on the
   line after `reloadmapafterbattle`. Losing to Janine routes through
   `Script_reloadmapafterbattle` -> `Script_BattleWhiteout`
   (`engine/overworld/scripting.asm:1080-1090`) and the script never reaches
   those lines, so the flags are only ever set on a win.
2. Beating Janine retroactively sets `EVENT_BEAT_LASS_ALICE`,
   `EVENT_BEAT_LASS_LINDA`, `EVENT_BEAT_PICNICKER_CINDY` and
   `EVENT_BEAT_CAMPER_BARRY`, so the four impostors can be skipped entirely.
3. `TM_TOXIC` is handed out on a **separate** `checkevent` from the badge. If
   the TM pocket is full the badge is still awarded and the TM is retried the
   next time you talk to her.

`FuchsiaGymStatue` - `checkflag ENGINE_SOULBADGE / iftrue .Beaten /
jumpstd GymStatue1Script`, `.Beaten` does `gettrainername STRING_BUFFER_4,
JANINE, JANINE1 / jumpstd GymStatue2Script`.

`FuchsiaGymGuideScript` - `checkevent EVENT_BEAT_JANINE` picks between the two
guide texts.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_SOULBADGE` | `constants/engine_flags.asm:51`; storage `data/events/engine_flags.asm:59` (`engine_flag wKantoBadges, SOULBADGE`) | `FuchsiaGymJanineScript`, `FuchsiaGymStatue` | Kanto badge 5; also the "already beat this gym" gate |
| `EVENT_BEAT_JANINE` | `constants/event_flags.asm:719` | `FuchsiaGymJanineScript`, `FuchsiaGymGuideScript` | leader beaten |
| `EVENT_BEAT_LASS_ALICE` | `constants/event_flags.asm:804` | `LassAliceScript`, `FuchsiaGymJanineScript` | impostor beaten (or skipped via Janine) |
| `EVENT_BEAT_LASS_LINDA` | `constants/event_flags.asm:807` | `LassLindaScript`, `FuchsiaGymJanineScript` | impostor beaten |
| `EVENT_BEAT_PICNICKER_CINDY` | `constants/event_flags.asm:640` | `PicnickerCindyScript`, `FuchsiaGymJanineScript` | impostor beaten |
| `EVENT_BEAT_CAMPER_BARRY` | `constants/event_flags.asm:532` | `CamperBarryScript`, `FuchsiaGymJanineScript` | impostor beaten |
| `EVENT_GOT_TM06_TOXIC` | `constants/event_flags.asm:220` | `FuchsiaGymJanineScript` | TM06 already collected |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `TM_TOXIC` (TM06, item `$c5`) | `verbosegiveitem` after beating Janine | `FuchsiaGymJanineScript` | `EVENT_GOT_TM06_TOXIC` |
| SOULBADGE | `setflag ENGINE_SOULBADGE` | `FuchsiaGymJanineScript` | `ENGINE_SOULBADGE` itself |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `LINDA` | `LASS` | Lass (6) | L30 Bulbasaur, L32 Ivysaur, L34 Venusaur | `LassLindaScript` | none |
| `CINDY` | `PICNICKER` | Picnicker (5) | L36 Nidoqueen | `PicnickerCindyScript` | none |
| `BARRY` | `CAMPER` | Camper (5) | L36 Nidoking | `CamperBarryScript` | none |
| `ALICE` | `LASS` | Lass (3) | L30 Gloom, L34 Arbok, L30 Gloom | `LassAliceScript` | none |
| `JANINE1` | `JANINE` | Janine (1), `TRAINERTYPE_MOVES` | see below | `FuchsiaGymJanineScript` | none (`KantoGymLeaders` entry, `data/trainers/leaders.asm`) |

Janine's party in **ROM order** (`data/trainers/parties.asm`, Janine (1)):

| # | level | species | moves |
|---|---|---|---|
| 1 | 36 | Crobat | Screech, Supersonic, Confuse Ray, Wing Attack |
| 2 | 36 | Weezing | Smog, Sludge Bomb, Toxic, Explosion |
| 3 | 36 | Weezing | Smog, Sludge Bomb, Toxic, Explosion |
| 4 | 33 | Ariados | Scary Face, Giga Drain, String Shot, Night Shade |
| 5 | 39 | Venomoth | Foresight, Double Team, Gust, Psychic |

Base reward 25 (`data/trainers/attributes.asm:157`), last mon level 39 ->
4 x 25 x 39 = 3900G, matching the walkthrough.

**Wild encounters**

None (indoor).

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Cut trees on Routes 12 (cells (7,44), (7,49)), 13 ((44,4)), 14 ((5,8), (11,14), (3,24)), 16 ((15,4)), Fuchsia ((16,11), (18,19)) | `engine/events/overworld.asm:117` `CutFunction.CheckAble` (menu use, `03:47e1`) and `engine/events/overworld.asm:1741` `TryCutOW` (walk-into prompt, `03:5193`) | `CheckBadge ENGINE_HIVEBADGE` **and** a party member knowing `CUT` **and** `CheckMapForSomethingToCut` (facing collision `COLL_CUT_TREE` + block id in `CutTreeBlockPointers`) | Hive Badge, already held long before this section. Cut is not persisted: the block reverts on map reload. |
| Route 16 Gate, west-to-east | `maps/Route16Gate.asm:16` `Route16GateBicycleCheck` (`5e:67cb`), coord events at (5,4)/(5,5), scene 0 | `checkitem BICYCLE` (bag, not "riding") | Own the BICYCLE. There is no `setmapscene` for this map, so the check is permanent, not a one-shot cutscene. |
| Route 17/18 Gate | `maps/Route17Route18Gate.asm:16` `Route17Route18GateBicycleCheck` (`5e:69ef`), coord events at (5,4)/(5,5), scene 0 | `checkitem BICYCLE` | Own the BICYCLE |
| Route 17 forced bike / auto-scroll south | `maps/Route17.asm:13` `Route17AlwaysOnBikeCallback` sets `ENGINE_ALWAYS_ON_BIKE` + `ENGINE_DOWNHILL`; enforced by `engine/overworld/map_setup.asm:112` `.CheckForcedBiking` (forces `PLAYER_BIKE`), `engine/events/overworld.asm:1634` `.GetOffBike` (refuses dismount), `engine/events/overworld.asm:343` / `:498` (refuses Surf), `engine/overworld/player_movement.asm:13` `.GetDPad` (idle frame -> `PAD_DOWN`) | none - it is unconditional on this map | Leave the map |
| Route 16 partial forced bike | `maps/Route16.asm:7` `Route16AlwaysOnBikeCallback` | `VAR_YCOORD < 5` or `VAR_XCOORD > 13` clears the flag; anywhere else sets it | Only re-evaluated on `MAPCALLBACK_NEWMAP` |
| Snorlax at the Route 11 west connection | `maps/VermilionCity.asm:41` `VermilionSnorlax`, object at Vermilion City (34, 8), `EVENT_VERMILION_CITY_SNORLAX` | `special SnorlaxAwake` must return true (Pokegear radio Expn card tuned to the Poke Flute channel) before the L50 Snorlax battle triggers; otherwise only `VermilionCitySnorlaxSleepingText` | `EVENT_FOUGHT_SNORLAX` + `disappear VERMILIONCITY_BIG_SNORLAX`. Belongs to a later section; nothing in section 23 clears it. |
| Safari Zone | none - `maps/FuchsiaCity.asm` warp 7 at (18, 3) is commented `; inaccessible` and no script or flag ever opens it | n/a | never opens in Gold/Silver |

Nothing in this section gates on `ENGINE_SOULBADGE` itself; the badge is the
output, not a prerequisite.

---

## 4. Bot checklist

Coordinates are walk cells, the same units the asm tables use. "Object N" means
the `object_const_def` index in that map (starting at 2).

1. `MAP_LAVENDER_TOWN` -> Fly / walk south into `MAP_ROUTE_12` (north connection,
   offset 0). Pre: `ENGINE_FLYPOINT_LAVENDER`. Post: none.
2. `MAP_ROUTE_12`, walk to (6, 6) area, talk to object 5 (`TrainerFisherKyle`).
   Pre: `EVENT_BEAT_FISHER_KYLE` clear. Post: `EVENT_BEAT_FISHER_KYLE`.
3. `MAP_ROUTE_12`, object 2 at (5, 15) (`TrainerFisherMartin`), sight range 3
   facing DOWN - a bot walking south past x=5 will be challenged automatically.
   Post: `EVENT_BEAT_FISHER_MARTIN`.
4. Walk west off `MAP_ROUTE_12` -> `MAP_ROUTE_11` (offset 9).
5. `MAP_ROUTE_11`, object 4 at (29, 7) (`TrainerPsychicHerman`), sight 1.
   Post: `EVENT_BEAT_PSYCHIC_HERMAN`.
6. `MAP_ROUTE_11`, object 2 at (22, 14) (`TrainerYoungsterOwen`), sight 3,
   `SPINRANDOM_FAST`. Post: `EVENT_BEAT_YOUNGSTER_OWEN`.
7. `MAP_ROUTE_11`, object 3 at (15, 9) (`TrainerYoungsterJason`), sight 2.
   Post: `EVENT_BEAT_YOUNGSTER_JASON`.
8. `MAP_ROUTE_11`, talk to object 6 at (32, 2) -> `BERRY`. Pre: bag room.
   Post: fruit tree slot 24 marked used for the day.
9. `MAP_ROUTE_11`, stand at (32, 6) facing UP (or use ITEMFINDER) and press A on
   (32, 5) -> `REVIVE`. Post: `EVENT_ROUTE_11_HIDDEN_REVIVE`.
10. `MAP_ROUTE_11`, object 5 at (7, 4) (`TrainerPsychicFidel`), sight 3 facing
    LEFT. Post: `EVENT_BEAT_PSYCHIC_FIDEL`.
11. Do **not** continue west - the Vermilion Snorlax blocks it. Walk back east
    into `MAP_ROUTE_12`.
12. `MAP_ROUTE_12`, object 3 at (15, 28) (`TrainerFisherStephen`), sight 1
    facing UP. Post: `EVENT_BEAT_FISHER_STEPHEN`.
13. `MAP_ROUTE_12`, step on warp 1 at (11, 33) -> `MAP_ROUTE_12_SUPER_ROD_HOUSE`.
14. `MAP_ROUTE_12_SUPER_ROD_HOUSE`, talk to object 2 at (5, 3), answer **Yes**
    to the `yesorno`. Pre: `EVENT_GOT_SUPER_ROD` clear, KEY ITEMS room.
    Post: `EVENT_GOT_SUPER_ROD`, `SUPER_ROD` in bag.
15. Exit via warp 1/2 at (2, 7)/(3, 7) -> `MAP_ROUTE_12` warp 1.
16. `MAP_ROUTE_12`, object 4 at (13, 39) (`TrainerFisherBarney`), sight 3 facing
    LEFT. Post: `EVENT_BEAT_FISHER_BARNEY`.
17. `MAP_ROUTE_12`, face walk cell (7, 44) and use CUT. Pre: `ENGINE_HIVEBADGE`
    + party CUT. Post: block `$35` at block (3, 22) swapped for `$4c` (not
    persisted).
18. `MAP_ROUTE_12`, walk onto object 6 at (5, 43) -> `CALCIUM`.
    Post: `EVENT_ROUTE_12_CALCIUM`.
19. Optional: object 7 at (5, 51) -> `NUGGET` (`EVENT_ROUTE_12_NUGGET`);
    hidden `ELIXER` facing (14, 13) (`EVENT_ROUTE_12_HIDDEN_ELIXER`).
20. Walk south off `MAP_ROUTE_12` -> `MAP_ROUTE_13` (offset -20).
21. `MAP_ROUTE_13`, object 2 at (42, 6) (`TrainerBirdKeeperPerry`), sight 2.
    Post: `EVENT_BEAT_BIRD_KEEPER_PERRY`.
22. `MAP_ROUTE_13`, object 3 at (43, 6) (`TrainerBirdKeeperBret`), sight 2.
    Post: `EVENT_BEAT_BIRD_KEEPER_BRET`.
23. `MAP_ROUTE_13`, object 4 at (32, 8) (`TrainerPokefanmJoshua`), sight 3
    facing LEFT (six L23 Pikachu). Post: `EVENT_BEAT_POKEFANM_JOSHUA`.
24. Optional: hidden `CALCIUM` facing (30, 13) (`EVENT_ROUTE_13_HIDDEN_CALCIUM`).
25. `MAP_ROUTE_13`, object 6 at (25, 6) (`TrainerPokefanmAlex`), sight 4 facing
    RIGHT. Post: `EVENT_BEAT_POKEFANM_ALEX`.
26. `MAP_ROUTE_13`, object 5 at (14, 10) (`TrainerHikerKenny`), sight 4 facing
    LEFT. Post: `EVENT_BEAT_HIKER_KENNY`.
27. Walk south off `MAP_ROUTE_13` -> `MAP_ROUTE_14` (offset 0).
28. `MAP_ROUTE_14`, face (5, 8) and use CUT, then talk to object 4 at (5, 9)
    (`TrainerPokefanmTrevor`), sight 4 facing RIGHT.
    Post: `EVENT_BEAT_POKEFANM_TREVOR`.
29. `MAP_ROUTE_14`, talk to object 5 (`Kim`, patrols around (7, 5)).
    Pre: a Chansey in the party, trade 5 unset in `wTradeFlags`.
    Post: Chansey -> Aerodactyl "AEROY" holding `GOLD_BERRY`, OT KIM / 26491.
30. `MAP_ROUTE_14`, face (11, 14) and CUT, then object 2 at (12, 14)
    (`TrainerPokefanmCarter`), sight 4 facing RIGHT.
    Post: `EVENT_BEAT_POKEFANM_CARTER`.
31. `MAP_ROUTE_14`, object 3 at (11, 27) (`TrainerBirdKeeperRoy`), sight 3.
    Post: `EVENT_BEAT_BIRD_KEEPER_ROY`.
32. `MAP_ROUTE_14`, face (3, 24) and CUT, then walk west off the map ->
    `MAP_ROUTE_15` (offset 9).
33. `MAP_ROUTE_15`, walk onto object 8 at (12, 5) -> `PP_UP`.
    Post: `EVENT_ROUTE_15_PP_UP`.
34. `MAP_ROUTE_15`, fight east-to-west along y=10:
    object 4 (33, 10) Johnny, object 6 (30, 12) Colette, object 5 (27, 10)
    Billy, object 7 (16, 10) Hillary, object 3 (11, 11) Tommy,
    object 2 (11, 10) Kipp. Post: the six `EVENT_BEAT_*` flags.
35. `MAP_ROUTE_15`, warp 1/2 at (2, 4)/(2, 5) -> `MAP_ROUTE_15_FUCHSIA_GATE`
    warps 3/4; then gate warps 1/2 at (0, 4)/(0, 5) -> `MAP_FUCHSIA_CITY`
    warps 8/9 at (37, 22)/(37, 23). Post (on map load):
    `ENGINE_FLYPOINT_FUCHSIA` set by `FuchsiaCityFlypointCallback`.
36. `MAP_FUCHSIA_CITY`, talk to object 5 at (8, 1) -> `BURNT_BERRY`.
37. `MAP_FUCHSIA_CITY`, warp 5 at (19, 27) -> `MAP_FUCHSIA_POKECENTER_1F`, talk
    to object 2 to heal, exit via warp 1/2.
38. Optional Cycling Road detour. Fly to Celadon, walk west into `MAP_ROUTE_16`.
    Pre: `BICYCLE` in bag. `ENGINE_ALWAYS_ON_BIKE` is set on load unless the
    landing cell has `y < 5` or `x > 13`.
39. `MAP_ROUTE_16`, optional: face (15, 4) and CUT (regrows on any map reload).
40. `MAP_ROUTE_16`, warp 2/3 at (14, 6)/(14, 7) -> `MAP_ROUTE_16_GATE` warps 3/4.
    Walking left across (5, 4)/(5, 5) fires `Route16GateBicycleCheck`; with no
    BICYCLE the player is shoved one step RIGHT. Exit warps 1/2 at (0, 4)/(0, 5).
41. `MAP_ROUTE_16` -> walk south into `MAP_ROUTE_17` (offset 0).
    Post (on load): `ENGINE_ALWAYS_ON_BIKE` + `ENGINE_DOWNHILL`. Releasing the
    d-pad now auto-steps DOWN each frame.
42. `MAP_ROUTE_17`, object 2 at (4, 17) (`TrainerBikerRiley`), sight 4.
    Post: `EVENT_BEAT_BIKER_RILEY`.
43. `MAP_ROUTE_17`, object 3 at (16, 32) (`TrainerBikerJoel`), sight 3 - the
    right-bank bridge. Post: `EVENT_BEAT_BIKER_JOEL`.
44. `MAP_ROUTE_17`, object 4 at (3, 53) (`TrainerBikerGlenn`), sight 3.
    Post: `EVENT_BEAT_BIKER_GLENN`.
45. `MAP_ROUTE_17`, object 5 at (6, 80) (`TrainerBikerCharles`), sight 4 facing
    RIGHT. Post: `EVENT_BEAT_BIKER_CHARLES`.
46. Optional hidden items: face (12, 5) -> `MAX_ETHER`; face (8, 77) ->
    `MAX_ELIXER`.
47. `MAP_ROUTE_17`, warp 1/2 at (17, 82)/(17, 83) ->
    `MAP_ROUTE_17_ROUTE_18_GATE` warps 1/2, exit warps 3/4 at (9, 4)/(9, 5) ->
    `MAP_ROUTE_18` warps 1/2 at (2, 6)/(2, 7).
48. `MAP_ROUTE_18`, object 3 at (13, 6) (`TrainerBirdKeeperBob`), sight 3.
    Post: `EVENT_BEAT_BIRD_KEEPER_BOB`.
49. `MAP_ROUTE_18`, object 2 at (9, 12) (`TrainerBirdKeeperBoris`), sight 3.
    Post: `EVENT_BEAT_BIRD_KEEPER_BORIS`.
50. Walk east off `MAP_ROUTE_18` -> `MAP_FUCHSIA_CITY` (offset -7).
51. `MAP_FUCHSIA_CITY`, heal (warp 5), then warp 3 at (8, 27) ->
    `MAP_FUCHSIA_GYM` (enter at warps 1/2, (4, 17)/(5, 17)).
52. `MAP_FUCHSIA_GYM`, talk to object 4 at (5, 11) (`LassLindaScript`).
    Pre: `EVENT_BEAT_LASS_LINDA` clear. Post: `EVENT_BEAT_LASS_LINDA` on a win;
    on a loss the sprite becomes `SPRITE_JANINE` and the flag stays clear.
53. `MAP_FUCHSIA_GYM`, object 5 at (9, 4) (`PicnickerCindyScript`).
    Post: `EVENT_BEAT_PICNICKER_CINDY`.
54. `MAP_FUCHSIA_GYM`, object 6 at (4, 2) (`CamperBarryScript`).
    Post: `EVENT_BEAT_CAMPER_BARRY`.
55. `MAP_FUCHSIA_GYM`, object 3 at (5, 7) (`LassAliceScript`).
    Post: `EVENT_BEAT_LASS_ALICE`.
56. Steps 52-55 are **optional**: step 57 sets all four flags anyway.
57. `MAP_FUCHSIA_GYM`, talk to object 2 at (1, 10) (`FuchsiaGymJanineScript`).
    Pre: `ENGINE_SOULBADGE` clear. Post on win: `EVENT_BEAT_JANINE`,
    `EVENT_BEAT_LASS_ALICE`, `EVENT_BEAT_LASS_LINDA`,
    `EVENT_BEAT_PICNICKER_CINDY`, `EVENT_BEAT_CAMPER_BARRY`,
    `ENGINE_SOULBADGE`, then `verbosegiveitem TM_TOXIC` ->
    `EVENT_GOT_TM06_TOXIC` (only if the TM pocket has room; otherwise re-talk).
58. Exit via warps 1/2 at (4, 17)/(5, 17) -> `MAP_FUCHSIA_CITY` warp 3.

Prize money for every trainer above is
`4 x <class base reward> x <level of the trainer's LAST party mon>`
(`ComputeTrainerReward` in `engine/battle/read_trainer_party.asm:300` gives
`base x level`, and `engine/battle/core.asm:2341` adds that amount **four**
times via the `ld c, 4` loop). This reproduces every G figure in the
walkthrough exactly.

---

## 5. Port coverage

The Gen 2 side of this repo is data-driven: `src/import/RomExtractorGen2.lua`
reads each map's `def_warp_events` / `def_coord_events` / `def_bg_events` /
`def_object_events` tables and the script bytecode straight out of the ROM
(`readMapEvents`, `src/import/RomExtractorGen2.lua:787-980`), and
`src/script/gen2/Vm.lua` executes the original opcodes. So there is no
per-map hand-port to audit for this section; what matters is whether the
mechanics each beat needs are implemented.

| Beat | Port file | Status |
|---|---|---|
| Map geometry, warps, connections | `src/world/gen2/Map.lua`, `src/import/RomExtractorGen2.lua:787` | implemented (generic, all maps) |
| Coord-event trip-wires (both bike gates) | `src/world/gen2/World.lua:5006` `World:tryCoordScript` (matches x/y + `sceneId`) | implemented |
| `checkitem BICYCLE` | `src/script/gen2/Opcodes.lua:38` (`0x21 checkitem`), handled in `src/script/gen2/Vm.lua` | implemented |
| `showemote` / `turnobject` / `applymovement` refusal choreography | `src/script/gen2/Vm.lua:961`, `:302` | implemented |
| `ENGINE_ALWAYS_ON_BIKE` / `ENGINE_DOWNHILL` (Routes 16, 17) | `src/world/gen2/Bike.lua:30-31`, `src/world/gen2/World.lua:3437-3444`, `:5620` | implemented; `World:alwaysOnBike()` / `World:downhill()` read the same engine-flag store the map callbacks write |
| Downhill auto-step / slow uphill bike step | `src/world/gen2/Bike.lua:136-146` | implemented |
| `readvar VAR_XCOORD` / `VAR_YCOORD` (the Route 16 partial-bike callback) | `src/world/gen2/World.lua:1275-1280`, wired through `src/script/gen2/Vm.lua:670` | implemented |
| `MAPCALLBACK_NEWMAP` dispatch (Fuchsia flypoint, both bike callbacks) | `src/world/gen2/World.lua:5659` `runMapCallback("MAPCALLBACK_NEWMAP")` | implemented |
| CUT field move on `TILESET_KANTO` trees | `src/world/gen2/FieldMoves.lua:191-210` (`CUT_BLOCKS.TILESET_KANTO` transcribes all five kanto rows), badge gate at `:104` (`CUT = "HIVE"`) | implemented |
| Item balls (`OBJECTTYPE_ITEMBALL`) | `src/import/RomExtractorGen2.lua:2968` `readItemBall` | implemented |
| Hidden items (`BGEVENT_ITEM` / `hiddenitem`) | `src/world/gen2/HiddenItems.lua` | implemented |
| Fruit trees (Route 11 Berry, Fuchsia Burnt Berry) | `src/core/gen2/Apricorns.lua:378` (slot 24 `BERRY`), `:384` (slot 30 `BURNT_BERRY`); `fruittree` opcode at `src/script/gen2/Vm.lua:1191` | implemented |
| Kim's Chansey/Aerodactyl trade | `src/core/gen2/NpcTrade.lua` + `src/ui/gen2/TradeMenu.lua`; `trade` opcode at `src/script/gen2/Vm.lua:1292` | implemented (trade rows come from the extracted `data/generated/events.lua` `trades` table) |
| `verbosegiveitem` (Super Rod, TM06) | `src/script/gen2/Vm.lua:490-498` | implemented |
| Super Rod fishing tables | `src/world/gen2/World.lua:311` `ROD_INDEX`, `src/battle/gen2/Encounter.lua:110` | implemented |
| Trainer objects, sight lines, `loadtrainer` / `startbattle` | `src/world/gen2/Trainers.lua`, `src/script/gen2/Vm.lua:806`, `:817`, `src/world/gen2/World.lua:4529` | implemented |
| `variablesprite` + `special LoadUsedSpritesGFX` (the Janine impostor reveal) | `src/script/gen2/Vm.lua:353`, `src/script/gen2/Specials.lua:1033` | implemented |
| Badge award (`setflag ENGINE_SOULBADGE` into `wKantoBadges`) | `src/world/gen2/World.lua` engine-flag store (`save.engineFlags`), Kanto badges counted at `:1240-1245` | implemented (generic engine-flag path; not exercised by any Gold driver) |
| Prize money x4 loop | not located in `src/battle/gen2/Prize.lua` during this pass | unverified - see Unresolved |
| Any driver that walks this section | `tests/drivers/gold_*.lua` (24 files; none touches Routes 11-19 or Fuchsia) | missing |

Summary: every mechanic this section needs already exists in the port, but
nothing in `tests/drivers/` exercises Kanto's south-east loop, the Cycling Road
forced-bike state or the Fuchsia Gym impostor script. A `gold_cycling_road.lua`
and a `gold_fuchsia_gym.lua` driver would be the cheapest way to prove it.

---

## 6. Unresolved / verify by hand

1. **Route 19 is never visited.** The section is titled "Routes 11-19" but the
   text stops at Fuchsia City after Route 18. `MAP_ROUTE_19` and
   `MAP_ROUTE_19_FUCHSIA_GATE` exist (`constants/map_constants.asm:178-180`,
   `data/maps/attributes.asm:287`) and Fuchsia warps 10/11 at (7, 35)/(8, 35)
   lead there, but no walkthrough beat uses them.
2. **"Cut the tree on your way west" on Route 15.** `maps/Route15.blk` contains
   none of the five `TILESET_KANTO` cut-tree block ids. The nearest real cut
   tree on that path is the Route 14 one at walk cell (3, 24). The Route 15
   sentence is most likely a duplicate reference to it.
3. **Janine "Strategy VERSUS Espeon".** The walkthrough includes an Espeon
   strategy paragraph. Janine (1) in `data/trainers/parties.asm` has no Espeon:
   the five mons are Crobat, Weezing, Weezing, Ariados, Venomoth. The paragraph
   appears to be copy-paste residue from another gym.
4. **Party ordering differences.** The walkthrough lists several parties in a
   different order than the ROM. Confirmed divergences:
   Psychic Herman (asm: Exeggcute, Exeggcute, Exeggutor; guide: Exeggcute,
   Exeggutor, Exeggcute); Schoolboy Johnny (asm: Bellsprout, Weepinbell,
   Victreebel; guide: Bellsprout, Victreebel, Weepinbell); PokeFan Carter (asm:
   Bulbasaur, Charmander, Squirtle; guide: Bulbasaur, Squirtle, Charmander);
   Bird Keeper Boris (asm: L30 Doduo, L28 Doduo, L32 Dodrio; guide: L30 Doduo,
   L32 Dodrio, L28 Doduo); Biker Charles (asm: Koffing, Charmeleon, Weezing;
   guide: Koffing, Weezing, Charmeleon); Lass Linda (asm: Bulbasaur, Ivysaur,
   Venusaur; guide: Bulbasaur, Venusaur, Ivysaur); Janine (asm order given
   above). Levels and species sets always match; only the order differs, so
   lead-mon predictions from the guide are unreliable.
5. **Route 12 items.** The walkthrough lists only Calcium and the Super Rod.
   The map also has a `NUGGET` itemball at (5, 51) and a hidden `ELIXER` at
   (14, 13). Route 13's hidden `CALCIUM` at (30, 13) and Route 17's hidden
   `MAX_ETHER` / `MAX_ELIXER` are likewise unlisted.
6. **Route 17 fight order.** The guide's order (Riley, Glenn, Joel, Charles)
   does not match the map's y-order (Riley 17, Joel 32, Glenn 53, Charles 80).
   Since these are `OBJECTTYPE_TRAINER` objects with sight lines rather than
   scripted encounters, a bot coasting south will hit them in y-order, not the
   guide's order.
7. **Prize-money x4 in the port.** The disassembly's four-fold payout
   (`engine/battle/core.asm:2341`, the `ld c, 4` add loop) was not located in
   `src/battle/gen2/Prize.lua` during this pass. Worth a direct read before
   trusting any money-based bot assertion.
8. **Fuchsia City cut trees.** Blocks (8, 5) and (9, 9) of
   `maps/FuchsiaCity.blk` are `$60` cut trees (walk cells (16, 11) and
   (18, 19)). Neither is mentioned in the walkthrough and neither was traced to
   a reward; they may simply be scenery on the Safari Zone approach.
9. **Fuchsia warp 7 walkability.** `maps/FuchsiaCity.asm:135` marks the Safari
   Zone gate warp `; inaccessible` in a comment; the block data behind (18, 3)
   was not decoded to confirm the tile is impassable. The walkthrough's "even
   the door is gone" matches the comment, but the collision itself is unverified.

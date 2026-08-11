# Section 13 - Ice Path and Blackthorn City Gym

Source: `../section-13-ice-path-and-blackthorn-city-gym.txt`
(the FAQ's own internal heading for this block is `---- 19 > Ice Path and Blackthorn City Gym ----`)

Maps covered: `MAP_ROUTE_44`, `MAP_ICE_PATH_1F`, `MAP_ICE_PATH_B1F`,
`MAP_ICE_PATH_B2F_MAHOGANY_SIDE`, `MAP_ICE_PATH_B3F`,
`MAP_ICE_PATH_B2F_BLACKTHORN_SIDE`, `MAP_BLACKTHORN_CITY`,
`MAP_BLACKTHORN_POKECENTER_1F`, `MAP_BLACKTHORN_MART`, `MAP_BLACKTHORN_EMYS_HOUSE`,
`MAP_MOVE_DELETERS_HOUSE`, `MAP_BLACKTHORN_DRAGON_SPEECH_HOUSE`,
`MAP_BLACKTHORN_GYM_1F`, `MAP_BLACKTHORN_GYM_2F`, `MAP_DRAGONS_DEN_1F`,
`MAP_DRAGONS_DEN_B1F`

Badges / key milestones in this section:

- `EVENT_GOT_HM07_WATERFALL` (HM07 on `MAP_ICE_PATH_1F`)
- `EVENT_BEAT_CLAIR` (the battle is won, but **no badge yet**)
- `EVENT_DRAGONS_DEN_B1F_DRAGON_FANG` -> `ENGINE_RISINGBADGE` + `EVENT_GOT_TM24_DRAGONBREATH`
- `specialphonecall SPECIALCALL_MASTERBALL` queued (Elm's Master Ball call, redeemed next section)

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 0 | `MAP_MAHOGANY_TOWN` | (previous section) | Fly | east map connection | "fly back to Mahogany Town, heal, head east onto Route 44" |
| 1 | `MAP_ROUTE_44` | `maps/Route44.asm` | west connection from `MAHOGANY_TOWN` | warp 1 at (56, 7) | six trainers, Burnt Berry tree, two item balls |
| 2 | `MAP_ICE_PATH_1F` | `maps/IcePath1F.asm` | warp 1 (4, 19) from Route 44 | warp 3 (37, 5) | first ice maze, HM07 Waterfall |
| 3 | `MAP_ICE_PATH_B1F` | `maps/IcePathB1F.asm` | warp 1 (3, 15) | warp 2 (17, 3) | Strength boulder-into-hole puzzle |
| 4 | `MAP_ICE_PATH_B2F_MAHOGANY_SIDE` | `maps/IcePathB2FMahoganySide.asm` | warp 1 (17, 1), or drop through holes | warp 2 (9, 11) | Full Heal, Max Potion, hidden Carbos |
| 5 | `MAP_ICE_PATH_B3F` | `maps/IcePathB3F.asm` | warp 1 (3, 5) | warp 2 (15, 5) | Rock Smash the rock, Nevermeltice |
| 6 | `MAP_ICE_PATH_B2F_BLACKTHORN_SIDE` | `maps/IcePathB2FBlackthornSide.asm` | warp 2 (3, 3) | warp 1 (3, 15) | TM44 Rest, hidden Ice Heal |
| 7 | `MAP_ICE_PATH_B1F` (south region) | `maps/IcePathB1F.asm` | warp 8 (11, 27) | warp 7 (5, 25) | Iron at (5, 35), hidden Max Potion |
| 8 | `MAP_ICE_PATH_1F` (south region) | `maps/IcePath1F.asm` | warp 4 (37, 13) | warp 2 (36, 27) | PP Up at (32, 23), then out |
| 9 | `MAP_BLACKTHORN_CITY` | `maps/BlackthornCity.asm` | warp 7 (36, 9) | see below | heal, restock, Move Deleter, Emy's trade |
| 10 | `MAP_BLACKTHORN_POKECENTER_1F` | `maps/BlackthornPokecenter1F.asm` | city warp 5 (21, 29) | warp 1/2 | heal |
| 11 | `MAP_BLACKTHORN_MART` | `maps/BlackthornMart.asm` | city warp 4 (15, 29) | warp 1/2 | restock Ultra Balls |
| 12 | `MAP_BLACKTHORN_EMYS_HOUSE` | `maps/BlackthornEmysHouse.asm` | city warp 3 (29, 23) | warp 1/2 | Dragonair <-> Rhydon trade ("northeast house") |
| 13 | `MAP_MOVE_DELETERS_HOUSE` | `maps/MoveDeletersHouse.asm` | city warp 6 (9, 31) | warp 1/2 | delete HM moves ("house in the south") |
| 14 | `MAP_BLACKTHORN_GYM_1F` | `maps/BlackthornGym1F.asm` | city warp 1 (18, 11) | warp 1/2 (4/5, 17) | Paul, Mike, Lola, Clair |
| 15 | `MAP_BLACKTHORN_GYM_2F` | `maps/BlackthornGym2F.asm` | 1F warp 3 (1, 7) / warp 4 (7, 9) | holes and stairs | Cody, Fran, six-boulder puzzle |
| 16 | `MAP_DRAGONS_DEN_1F` | `maps/DragonsDen1F.asm` | city warp 8 (20, 1) | warp 3 (5, 15) | corridor + internal ladder pair |
| 17 | `MAP_DRAGONS_DEN_B1F` | `maps/DragonsDenB1F.asm` | warp 1 (20, 3) | same warp | Surf + Whirlpool to the Dragon Fang at (35, 16); Clair hands over `ENGINE_RISINGBADGE` |

Not covered here (next section): the walkthrough's last paragraph sends the player
back to `MAP_ELMS_LAB` for the Master Ball (`ElmGiveMasterBallScript`,
`maps/ElmsLab.asm`) and on toward the Pokemon League. The video-link header also
names Dark Cave, but the prose never enters `MAP_DARK_CAVE_BLACKTHORN_ENTRANCE`.

`MAP_BLACKTHORN_DRAGON_SPEECH_HOUSE` (city warp 2, (13, 21)) is on the map but the
walkthrough never enters it; it is documented below for completeness.

## 2. Maps

### MAP_ROUTE_44

- Script: `maps/Route44.asm` (`Route44_MapEvents` = `4d:4dd9` in `pokegold.sym`)
- Blocks: `maps/Route44.blk`
- Header: `data/maps/maps.asm:73` -> `TILESET_JOHTO`, `ROUTE`, `LANDMARK_ROUTE_44`,
  `MUSIC_LAKE_OF_RAGE`, phone `FALSE`, `PALETTE_AUTO`, `FISHGROUP_REMORAID`
- Dimensions: `constants/map_constants.asm:61` -> `map_const ROUTE_44, 30, 9`
  (so x in 0..59, y in 0..17)
- Connections: `data/maps/attributes.asm:239` -> west `MAHOGANY_TOWN` (offset 0),
  east `BLACKTHORN_CITY` (offset -9)
- Scene scripts: none (`def_scene_scripts` empty). Callbacks: none.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 56 | 7 | `ICE_PATH_1F` | 1 |

**Coord events** (`def_coord_events`)

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 53 | 7 | `BGEVENT_READ` | `Route44Sign1` ("ROUTE 44 / ICE PATH AHEAD") |
| 6 | 10 | `BGEVENT_READ` | `Route44Sign2` ("MAHOGANY TOWN - BLACKTHORN CITY") |
| 32 | 9 | `BGEVENT_ITEM` | `Route44HiddenElixer` -> `hiddenitem ELIXER, EVENT_ROUTE_44_HIDDEN_ELIXER` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `ROUTE44_FISHER1` | `SPRITE_FISHER` | 42 | 5 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 1 | `TrainerFisherWilton1` | -1 |
| `ROUTE44_FISHER2` | `SPRITE_FISHER` | 19 | 13 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 1 | `TrainerFisherEdgar` | -1 |
| `ROUTE44_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 10 | 9 | `SPINCLOCKWISE` | `OBJECTTYPE_TRAINER` | 3 | `TrainerPsychicPhil` | -1 |
| `ROUTE44_SUPER_NERD` | `SPRITE_SUPER_NERD` | 35 | 2 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 5 | `TrainerPokemaniacZach` | -1 |
| `ROUTE44_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 50 | 7 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 3 | `TrainerBirdKeeperVance1` | -1 |
| `ROUTE44_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 41 | 15 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 5 | `TrainerCooltrainermAllen` | -1 |
| `ROUTE44_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 31 | 14 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 5 | `TrainerCooltrainerfCybil` | -1 |
| `ROUTE44_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 9 | 5 | `STILL` | `OBJECTTYPE_SCRIPT` | 0 | `Route44FruitTree` | -1 |
| `ROUTE44_POKE_BALL1` | `SPRITE_POKE_BALL` | 30 | 8 | `STILL` | `OBJECTTYPE_ITEMBALL` | 0 | `Route44MaxRevive` | `EVENT_ROUTE_44_MAX_REVIVE` |
| `ROUTE44_POKE_BALL2` | `SPRITE_POKE_BALL` | 43 | 2 | `STILL` | `OBJECTTYPE_ITEMBALL` | 0 | `Route44UltraBall` | `EVENT_ROUTE_44_ULTRA_BALL` |

**Scripts of interest**

- `TrainerBirdKeeperVance1` / `.Script` - after the fight this is the phone-number
  script. `checkevent EVENT_VANCE_READY_FOR_REMATCH` -> rematch branch;
  `checkcellnum PHONE_BIRDKEEPER_VANCE` -> already registered; otherwise sets
  `EVENT_VANCE_ASKED_FOR_PHONE_NUMBER` and runs
  `askforphonenumber PHONE_BIRDKEEPER_VANCE`. The rematch branch picks
  `VANCE2` if `EVENT_BEAT_ELITE_FOUR` and `VANCE3` if
  `EVENT_RESTORED_POWER_TO_KANTO`, and clears `EVENT_VANCE_READY_FOR_REMATCH`.
- `TrainerFisherWilton1` / `.Script` - same shape with `PHONE_FISHER_WILTON`,
  `EVENT_WILTON_ASKED_FOR_PHONE_NUMBER`, `EVENT_WILTON_READY_FOR_REMATCH`,
  and `WILTON2` / `WILTON3` for the later fights. `FisherWiltonHugePoliwagText`
  is the "you made me lose a POLIWAG" line the walkthrough quotes.
- `Route44FruitTree` -> `fruittree FRUITTREE_ROUTE_44`. `FRUITTREE_ROUTE_44` is
  index 10 (`constants/script_constants.asm:222`) and
  `data/items/fruit_trees.asm:19` gives `BURNT_BERRY`.
- `Route44MaxRevive` -> `itemball MAX_REVIVE`, `Route44UltraBall` -> `itemball ULTRA_BALL`.
- The four one-line trainers (`TrainerPsychicPhil`, `TrainerFisherEdgar`,
  `TrainerCooltrainerfCybil`, `TrainerPokemaniacZach`, `TrainerCooltrainermAllen`)
  are `endifjustbattled / opentext / writetext ... / waitbutton / closetext / end`
  with no flag side effects beyond the `trainer` macro's own beaten flag.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_BIRD_KEEPER_VANCE` | `constants/event_flags.asm` | `trainer` macro row in `TrainerBirdKeeperVance1` | set once Vance is beaten |
| `EVENT_BEAT_PSYCHIC_PHIL` | same | `TrainerPsychicPhil` | " |
| `EVENT_BEAT_FISHER_WILTON` | same | `TrainerFisherWilton1` | " |
| `EVENT_BEAT_FISHER_EDGAR` | same | `TrainerFisherEdgar` | " |
| `EVENT_BEAT_COOLTRAINERF_CYBIL` | same | `TrainerCooltrainerfCybil` | " |
| `EVENT_BEAT_POKEMANIAC_ZACH` | same | `TrainerPokemaniacZach` | " |
| `EVENT_BEAT_COOLTRAINERM_ALLEN` | same | `TrainerCooltrainermAllen` | " |
| `EVENT_ROUTE_44_MAX_REVIVE` | `constants/event_flags.asm:1111` | itemball object | set -> ball gone |
| `EVENT_ROUTE_44_ULTRA_BALL` | `constants/event_flags.asm:1112` | itemball object | set -> ball gone |
| `EVENT_ROUTE_44_HIDDEN_ELIXER` | `constants/event_flags.asm:184` | `hiddenitem` bg event | one-shot hidden item |
| `EVENT_VANCE_ASKED_FOR_PHONE_NUMBER` / `EVENT_WILTON_ASKED_FOR_PHONE_NUMBER` | `constants/event_flags.asm` | trainer scripts | second-ask dialogue branch |
| `EVENT_VANCE_READY_FOR_REMATCH` / `EVENT_WILTON_READY_FOR_REMATCH` | same | phone system | rematch pending |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `BURNT_BERRY` | headbutt-free fruit tree at (9, 5) | `Route44FruitTree` / `FRUITTREE_ROUTE_44` | daily, not an event flag |
| `MAX_REVIVE` | item ball at (30, 8) | `Route44MaxRevive` | `EVENT_ROUTE_44_MAX_REVIVE` |
| `ULTRA_BALL` | item ball at (43, 2) | `Route44UltraBall` | `EVENT_ROUTE_44_ULTRA_BALL` |
| `ELIXER` | hidden, bg_event (32, 9) | `Route44HiddenElixer` | `EVENT_ROUTE_44_HIDDEN_ELIXER` |

**Trainers**

Party data all from `data/trainers/parties.asm`; classes from
`constants/trainer_constants.asm`.

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `PSYCHIC_T`, `PHIL` | `PsychicGroup` | PSYCHIC_T (8) | L24 `NATU` (Leer / Night Shade / Future Sight / Confuse Ray), **L26** `KADABRA` (Disable / Psybeam / Recover / Future Sight); `TRAINERTYPE_MOVES` | `TrainerPsychicPhil` | none |
| `FISHER`, `EDGAR` | `FisherGroup` | FISHER (11) | L25 `REMORAID` x2 (Lock-On / Psybeam / Aurora Beam / Bubblebeam); `TRAINERTYPE_MOVES` | `TrainerFisherEdgar` | none |
| `COOLTRAINERF`, `CYBIL` | `CooltrainerFGroup` | COOLTRAINERF (16) | L25 `BUTTERFREE` (Confusion / Sleep Powder / Whirlwind / Gust), L25 `BELLOSSOM` (Absorb / Stun Spore / Acid / SolarBeam); `TRAINERTYPE_MOVES` | `TrainerCooltrainerfCybil` | none |
| `COOLTRAINERM`, `ALLEN` | `CooltrainerMGroup` | COOLTRAINERM (19) | L27 `CHARMELEON` (Ember / Smokescreen / Rage / Scary Face); `TRAINERTYPE_MOVES` | `TrainerCooltrainermAllen` | none |
| `POKEMANIAC`, `ZACH` | `PokemaniacGroup` | POKEMANIAC (13) | L27 `RHYHORN`; `TRAINERTYPE_NORMAL` | `TrainerPokemaniacZach` | none |
| `FISHER`, `WILTON1` | `FisherGroup` | FISHER (10) | L23 `GOLDEEN`, L23 `GOLDEEN`, L25 `SEAKING`; `TRAINERTYPE_NORMAL` | `TrainerFisherWilton1` | `PHONE_FISHER_WILTON`; `WILTON2`/`WILTON3` post-game |
| `BIRD_KEEPER`, `VANCE1` | `BirdKeeperGroup` | BIRD_KEEPER (7) | L25 `PIDGEOTTO` x2; `TRAINERTYPE_NORMAL` | `TrainerBirdKeeperVance1` | `PHONE_BIRDKEEPER_VANCE`; `VANCE2`/`VANCE3` post-game |

**Wild encounters**

- Grass, `data/wild/johto_grass.asm:2208` `def_grass_wildmons ROUTE_44`, rates
  10/10/10 percent, and morn == day == nite:
  L23 `TANGELA`, L22 `WEEPINBELL`, L22 `BELLSPROUT`, L24 `LICKITUNG`,
  L24 `WEEPINBELL`, L26 `LICKITUNG`, L26 `LICKITUNG`.
- Water, `data/wild/johto_water.asm:197` `def_water_wildmons ROUTE_44`, 2 percent:
  L25 `POLIWAG`, L20 `POLIWAG`, L25 `POLIWHIRL`. This is the Poliwag the
  walkthrough's "Pokemon on Route 44" list means; it is Surf-only, not grass.
- Fishing group `FISHGROUP_REMORAID` (`data/maps/maps.asm:73`),
  `data/wild/fish.asm:195` `.Remoraid_Old/.Remoraid_Good/.Remoraid_Super`:
  Old = Magikarp/Magikarp/Poliwag L10; Good = Magikarp L20, Poliwag L20 x2,
  `time_group 6` (Poliwag L20); Super = Poliwag L40, `time_group 7`
  (Poliwag L40), Magikarp L40, `REMORAID` L40.

---

### MAP_ICE_PATH_1F

- Script: `maps/IcePath1F.asm` (`IcePath1F_MapEvents` = `46:613f`)
- Blocks: `maps/IcePath1F.blk`
- Header: `data/maps/maps.asm:131` -> `TILESET_ICE_PATH`, `CAVE`,
  `LANDMARK_ICE_PATH`, `MUSIC_DARK_CAVE`, phone `TRUE`, `PALETTE_NITE`,
  `FISHGROUP_DRATINI`
- Dimensions: `constants/map_constants.asm:118` -> `map_const ICE_PATH_1F, 20, 18`
- Attributes: `data/maps/attributes.asm:450`, no connections
- Scene scripts and callbacks: both empty

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 19 | `ROUTE_44` | 1 |
| 2 | 36 | 27 | `BLACKTHORN_CITY` | 7 |
| 3 | 37 | 5 | `ICE_PATH_B1F` | 1 |
| 4 | 37 | 13 | `ICE_PATH_B1F` | 7 |

**Coord events / BG events**

None.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ICEPATH1F_POKE_BALL1` | `SPRITE_POKE_BALL` | 31 | 7 | `STILL` | `OBJECTTYPE_ITEMBALL` | `IcePath1FHMWaterfall` | `EVENT_GOT_HM07_WATERFALL` |
| `ICEPATH1F_POKE_BALL2` | `SPRITE_POKE_BALL` | 32 | 23 | `STILL` | `OBJECTTYPE_ITEMBALL` | `IcePath1FPPUp` | `EVENT_ICE_PATH_1F_PP_UP` |

**Scripts of interest**

- `IcePath1FHMWaterfall` -> `itemball HM_WATERFALL`. Nothing gates it beyond
  reaching the tile; the badge check that makes the move usable is separate
  (see section 3).
- `IcePath1FPPUp` -> `itemball PP_UP`. This ball is in the *southern* region of
  1F, reached on the way back up from B1F warp 7, not on the way in.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `HM_WATERFALL` (HM07) | item ball at (31, 7) | `IcePath1FHMWaterfall` | `EVENT_GOT_HM07_WATERFALL` (`constants/event_flags.asm:1065`) |
| `PP_UP` | item ball at (32, 23) | `IcePath1FPPUp` | `EVENT_ICE_PATH_1F_PP_UP` (`:1066`) |

**Wild encounters**

`data/wild/johto_grass.asm:798` `def_grass_wildmons ICE_PATH_1F`, rates 2/2/2 percent.
Gold build (`IF DEF(_GOLD)`):

| slot | morn | day | nite |
|---|---|---|---|
| 1 | L21 `SWINUB` | L21 `SWINUB` | L21 `SWINUB` |
| 2 | L22 `GOLBAT` | L22 `GOLBAT` | L22 `GOLBAT` |
| 3 | L22 `ZUBAT` | L22 `ZUBAT` | L22 `ZUBAT` |
| 4 | L23 `SWINUB` | L23 `SWINUB` | L23 `SWINUB` |
| 5 | L22 `ZUBAT` | L22 `JYNX` | L22 `ZUBAT` |
| 6 | L22 `JYNX` | L20 `JYNX` | L22 `JYNX` |
| 7 | L22 `JYNX` | L20 `JYNX` | L22 `JYNX` |

Silver (`ELIF DEF(_SILVER)`) replaces slot 3 with L22 `DELIBIRD` in all three
time bands - that is the "Delibird (Silver only)" line in the walkthrough, and
it is a *slot swap*, not an extra entry.

---

### MAP_ICE_PATH_B1F

- Script: `maps/IcePathB1F.asm` (`IcePathB1F_MapEvents` = `46:61e7`,
  `IcePathB1FSetUpStoneTableCallback` = `46:6178`)
- Blocks: `maps/IcePathB1F.blk`
- Header: `data/maps/maps.asm:132` -> `TILESET_ICE_PATH`, `CAVE`,
  `LANDMARK_ICE_PATH`, `MUSIC_DARK_CAVE`, `TRUE`, `PALETTE_NITE`, `FISHGROUP_DRATINI`
- Dimensions: `constants/map_constants.asm:119` -> `map_const ICE_PATH_B1F, 10, 18`
- Callbacks: `callback MAPCALLBACK_CMDQUEUE, IcePathB1FSetUpStoneTableCallback`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp | note |
|---|---|---|---|---|---|
| 1 | 3 | 15 | `ICE_PATH_1F` | 3 | up to the north 1F region |
| 2 | 17 | 3 | `ICE_PATH_B2F_MAHOGANY_SIDE` | 1 | stairs down |
| 3 | 11 | 2 | `ICE_PATH_B2F_MAHOGANY_SIDE` | 3 | hole |
| 4 | 4 | 7 | `ICE_PATH_B2F_MAHOGANY_SIDE` | 4 | hole |
| 5 | 5 | 12 | `ICE_PATH_B2F_MAHOGANY_SIDE` | 5 | hole |
| 6 | 12 | 13 | `ICE_PATH_B2F_MAHOGANY_SIDE` | 6 | hole |
| 7 | 5 | 25 | `ICE_PATH_1F` | 4 | up to the south 1F region |
| 8 | 11 | 27 | `ICE_PATH_B2F_BLACKTHORN_SIDE` | 1 | |

**Coord events**

None.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 15 | 31 | `BGEVENT_ITEM` | `IcePathB1FHiddenMaxPotion` -> `hiddenitem MAX_POTION, EVENT_ICE_PATH_B1F_HIDDEN_MAX_POTION` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ICEPATHB1F_BOULDER1` | `SPRITE_BOULDER` | 11 | 7 | `STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | `IcePathB1FBoulder` | `EVENT_BOULDER_IN_ICE_PATH_1` |
| `ICEPATHB1F_BOULDER2` | `SPRITE_BOULDER` | 7 | 8 | `STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | `IcePathB1FBoulder` | `EVENT_BOULDER_IN_ICE_PATH_2` |
| `ICEPATHB1F_BOULDER3` | `SPRITE_BOULDER` | 8 | 9 | `STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | `IcePathB1FBoulder` | `EVENT_BOULDER_IN_ICE_PATH_3` |
| `ICEPATHB1F_BOULDER4` | `SPRITE_BOULDER` | 17 | 7 | `STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | `IcePathB1FBoulder` | `EVENT_BOULDER_IN_ICE_PATH_4` |
| `ICEPATHB1F_POKE_BALL` | `SPRITE_POKE_BALL` | 5 | 35 | `STILL` | `OBJECTTYPE_ITEMBALL` | `IcePathB1FIron` | `EVENT_ICE_PATH_B1F_IRON` |

**Scripts of interest**

- `IcePathB1FSetUpStoneTableCallback` writes a command queue with one
  `cmdqueue CMDQUEUE_STONETABLE, .StoneTable` entry. `.StoneTable` is the
  warp-id -> boulder-object -> script mapping:

  ```
  stonetable 3, ICEPATHB1F_BOULDER1, .Boulder1
  stonetable 4, ICEPATHB1F_BOULDER2, .Boulder2
  stonetable 5, ICEPATHB1F_BOULDER3, .Boulder3
  stonetable 6, ICEPATHB1F_BOULDER4, .Boulder4
  db -1
  ```

  So boulder N must be pushed onto warp N+2 - i.e. boulder 1 onto the hole at
  (11, 2), boulder 2 onto (4, 7), boulder 3 onto (5, 12), boulder 4 onto (12, 13).
- Each `.BoulderN` arm does `disappear ICEPATHB1F_BOULDERN` (which sets
  `EVENT_BOULDER_IN_ICE_PATH_N`) and `clearevent EVENT_BOULDER_IN_ICE_PATH_NA`
  (which makes the twin boulder object on `ICE_PATH_B2F_MAHOGANY_SIDE`
  *appear*), then falls into `.FinishBoulder`: `pause 30`,
  `scall .BoulderFallsThrough` (`playsound SFX_STRENGTH` + `earthquake 80`),
  then `IcePathBoulderFellThroughText` ("The boulder fell / through.").
- `IcePathB1FBoulder` -> `jumpstd StrengthBoulderScript` (the "may be able to
  push this with STRENGTH" prompt).

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BOULDER_IN_ICE_PATH_1..4` | `constants/event_flags.asm:1195-1198` | `.BoulderN` `disappear` | set -> that B1F boulder is gone (fell) |
| `EVENT_BOULDER_IN_ICE_PATH_1A..4A` | `constants/event_flags.asm:1199-1202` | `.BoulderN` `clearevent`; **set at new game** by the init list in `engine/events/std_scripts.asm` | clear -> the fallen boulder is now visible on B2F Mahogany Side |
| `EVENT_ICE_PATH_B1F_IRON` | `:1067` | itemball object | |
| `EVENT_ICE_PATH_B1F_HIDDEN_MAX_POTION` | `:158` | hidden bg event | |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `IRON` | item ball at (5, 35) | `IcePathB1FIron` | `EVENT_ICE_PATH_B1F_IRON` |
| `MAX_POTION` | hidden at (15, 31) | `IcePathB1FHiddenMaxPotion` | `EVENT_ICE_PATH_B1F_HIDDEN_MAX_POTION` |

**Wild encounters**

`data/wild/johto_grass.asm:853` `def_grass_wildmons ICE_PATH_B1F`, 2/2/2 percent -
byte-for-byte the same table as `ICE_PATH_1F` above (same levels, same Silver
Delibird swap).

---

### MAP_ICE_PATH_B2F_MAHOGANY_SIDE

- Script: `maps/IcePathB2FMahoganySide.asm` (`..._MapEvents` = `46:6287`)
- Blocks: `maps/IcePathB2FMahoganySide.blk`
- Header: `data/maps/maps.asm:133` -> `TILESET_ICE_PATH`, `CAVE`,
  `LANDMARK_ICE_PATH`, `MUSIC_DARK_CAVE`, `TRUE`, `PALETTE_NITE`, `FISHGROUP_DRATINI`
- Dimensions: `constants/map_constants.asm:120` -> `map_const ICE_PATH_B2F_MAHOGANY_SIDE, 10, 9`
- Scene scripts and callbacks: both empty

**Warps**

| idx | x | y | destination map | dest warp | note |
|---|---|---|---|---|---|
| 1 | 17 | 1 | `ICE_PATH_B1F` | 2 | stairs back up |
| 2 | 9 | 11 | `ICE_PATH_B3F` | 1 | ladder down |
| 3 | 11 | 4 | `ICE_PATH_B1F` | 3 | landing under hole 1 |
| 4 | 4 | 6 | `ICE_PATH_B1F` | 4 | landing under hole 2 |
| 5 | 4 | 12 | `ICE_PATH_B1F` | 5 | landing under hole 3 |
| 6 | 12 | 12 | `ICE_PATH_B1F` | 6 | landing under hole 4 |

**Coord events**

None.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 0 | 17 | `BGEVENT_ITEM` | `IcePathB2FMahoganySideHiddenCarbos` -> `hiddenitem CARBOS, EVENT_ICE_PATH_B2F_MAHOGANY_SIDE_HIDDEN_CARBOS` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ICEPATHB2FMAHOGANYSIDE_BOULDER1` | `SPRITE_BOULDER` | 11 | 3 | `STILL` | `OBJECTTYPE_SCRIPT` | `IcePathB2FMahoganySideBoulder` | `EVENT_BOULDER_IN_ICE_PATH_1A` |
| `ICEPATHB2FMAHOGANYSIDE_BOULDER2` | `SPRITE_BOULDER` | 4 | 7 | `STILL` | `OBJECTTYPE_SCRIPT` | same | `EVENT_BOULDER_IN_ICE_PATH_2A` |
| `ICEPATHB2FMAHOGANYSIDE_BOULDER3` | `SPRITE_BOULDER` | 3 | 12 | `STILL` | `OBJECTTYPE_SCRIPT` | same | `EVENT_BOULDER_IN_ICE_PATH_3A` |
| `ICEPATHB2FMAHOGANYSIDE_BOULDER4` | `SPRITE_BOULDER` | 12 | 13 | `STILL` | `OBJECTTYPE_SCRIPT` | same | `EVENT_BOULDER_IN_ICE_PATH_4A` |
| `ICEPATHB2FMAHOGANYSIDE_POKE_BALL1` | `SPRITE_POKE_BALL` | 8 | 9 | `STILL` | `OBJECTTYPE_ITEMBALL` | `IcePathB2FMahoganySideFullHeal` | `EVENT_ICE_PATH_B2F_MAHOGANY_SIDE_FULL_HEAL` |
| `ICEPATHB2FMAHOGANYSIDE_POKE_BALL2` | `SPRITE_POKE_BALL` | 0 | 2 | `STILL` | `OBJECTTYPE_ITEMBALL` | `IcePathB2FMahoganySideMaxPotion` | `EVENT_ICE_PATH_B2F_MAHOGANY_SIDE_MAX_POTION` |

**Scripts of interest**

- `IcePathB2FMahoganySideBoulder` -> `jumptext IcePathB2FMahoganySideBoulderText`
  ("It's immovably / imbedded in ice."). These boulders are `SPRITEMOVEDATA_STILL`,
  not `STRENGTH_BOULDER` - they are scenery once they land, and they are the
  reason the four B1F boulders are one-way.
- `IcePathB2FMahoganySideFullHeal` -> `itemball FULL_HEAL`. This is the Full Heal
  the walkthrough says to grab after dropping through a hole.
- `IcePathB2FMahoganySideMaxPotion` -> `itemball MAX_POTION` (the walkthrough's
  item list omits it).

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `FULL_HEAL` | item ball at (8, 9) | `IcePathB2FMahoganySideFullHeal` | `EVENT_ICE_PATH_B2F_MAHOGANY_SIDE_FULL_HEAL` (`:1068`) |
| `MAX_POTION` | item ball at (0, 2) | `IcePathB2FMahoganySideMaxPotion` | `EVENT_ICE_PATH_B2F_MAHOGANY_SIDE_MAX_POTION` (`:1069`) |
| `CARBOS` | hidden at (0, 17) | `IcePathB2FMahoganySideHiddenCarbos` | `EVENT_ICE_PATH_B2F_MAHOGANY_SIDE_HIDDEN_CARBOS` (`:159`) |

**Wild encounters**

`data/wild/johto_grass.asm:908`, 2/2/2 percent, one level higher than B1F:
morn L22 `SWINUB` / L23 `GOLBAT` / L23 `ZUBAT` / L24 `SWINUB` / L23 `ZUBAT` /
L23 `JYNX` / L23 `JYNX`; day swaps slots 5-7 to L23 `JYNX` / L21 `JYNX` / L21 `JYNX`;
nite matches morn. Silver replaces slot 3 with `DELIBIRD` at the same level.

---

### MAP_ICE_PATH_B3F

- Script: `maps/IcePathB3F.asm` (`IcePathB3F_MapEvents` = `46:632e`)
- Blocks: `maps/IcePathB3F.blk`
- Header: `data/maps/maps.asm:135` -> `TILESET_ICE_PATH`, `CAVE`,
  `LANDMARK_ICE_PATH`, `MUSIC_DARK_CAVE`, `TRUE`, `PALETTE_NITE`, `FISHGROUP_DRATINI`
- Dimensions: `constants/map_constants.asm:122` -> `map_const ICE_PATH_B3F, 10, 9`
- Scene scripts and callbacks: both empty

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 5 | `ICE_PATH_B2F_MAHOGANY_SIDE` | 2 |
| 2 | 15 | 5 | `ICE_PATH_B2F_BLACKTHORN_SIDE` | 2 |

**Coord events / BG events**

None.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ICEPATHB3F_POKE_BALL` | `SPRITE_POKE_BALL` | 5 | 7 | `STILL` | `OBJECTTYPE_ITEMBALL` | `IcePathB3FNevermeltice` | `EVENT_ICE_PATH_B3F_NEVERMELTICE` |
| `ICEPATHB3F_ROCK` | `SPRITE_ROCK` | 6 | 6 | `SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | `IcePathB3FRock` | -1 |

**Scripts of interest**

- `IcePathB3FRock` -> `jumpstd SmashRockScript`. The rock at (6, 6) sits between
  the ladder at (3, 5) and the Nevermeltice at (5, 7); no badge is required for
  ROCK SMASH, only the move in the party (`HasRockSmash` in
  `engine/events/overworld.asm` / `AskRockSmashScript`).
- `IcePathB3FNevermeltice` -> `itemball NEVERMELTICE`.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `NEVERMELTICE` | item ball at (5, 7) | `IcePathB3FNevermeltice` | `EVENT_ICE_PATH_B3F_NEVERMELTICE` (`:1071`) |

**Wild encounters**

`data/wild/johto_grass.asm:1018`, 2/2/2 percent, one level above B2F:
morn/nite L23 `SWINUB` / L24 `GOLBAT` / L24 `ZUBAT` / L25 `SWINUB` / L24 `ZUBAT` /
L24 `JYNX` / L24 `JYNX`; day swaps slots 5-7 to `JYNX` L24/L22/L22.

---

### MAP_ICE_PATH_B2F_BLACKTHORN_SIDE

- Script: `maps/IcePathB2FBlackthornSide.asm` (`..._MapEvents` = `46:6305`)
- Blocks: `maps/IcePathB2FBlackthornSide.blk`
- Header: `data/maps/maps.asm:134` -> `TILESET_ICE_PATH`, `CAVE`,
  `LANDMARK_ICE_PATH`, `MUSIC_DARK_CAVE`, `TRUE`, `PALETTE_NITE`, `FISHGROUP_DRATINI`
- Dimensions: `constants/map_constants.asm:121` -> `map_const ICE_PATH_B2F_BLACKTHORN_SIDE, 5, 9`
- Scene scripts and callbacks: both empty

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 15 | `ICE_PATH_B1F` | 8 |
| 2 | 3 | 3 | `ICE_PATH_B3F` | 2 |

**Coord events**

None.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 2 | 10 | `BGEVENT_ITEM` | `IcePathB2FBlackthornSideHiddenIceHeal` -> `hiddenitem ICE_HEAL, EVENT_ICE_PATH_B2F_BLACKTHORN_SIDE_HIDDEN_ICE_HEAL` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ICEPATHB2FBLACKTHORNSIDE_POKE_BALL` | `SPRITE_POKE_BALL` | 8 | 16 | `STILL` | `OBJECTTYPE_ITEMBALL` | `IcePathB2FBlackthornSideTMRest` | `EVENT_ICE_PATH_B2F_BLACKTHORN_SIDE_TM_REST` |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `TM_REST` (TM44) | item ball at (8, 16) | `IcePathB2FBlackthornSideTMRest` | `EVENT_ICE_PATH_B2F_BLACKTHORN_SIDE_TM_REST` (`:1070`) |
| `ICE_HEAL` | hidden at (2, 10) | `IcePathB2FBlackthornSideHiddenIceHeal` | `EVENT_ICE_PATH_B2F_BLACKTHORN_SIDE_HIDDEN_ICE_HEAL` (`:160`) |

**Wild encounters**

`data/wild/johto_grass.asm:963`, identical to `ICE_PATH_B2F_MAHOGANY_SIDE`.

---

### MAP_BLACKTHORN_CITY

- Script: `maps/BlackthornCity.asm` (`BlackthornCity_MapEvents` = `49:5e4f`,
  `BlackthornCityFlypointCallback` = `49:58f2`)
- Blocks: `maps/BlackthornCity.blk`
- Header: `data/maps/maps.asm:187` -> `TILESET_JOHTO`, `TOWN`,
  `LANDMARK_BLACKTHORN_CITY`, `MUSIC_AZALEA_TOWN`, phone `FALSE`,
  `PALETTE_AUTO`, `FISHGROUP_POND`
- Dimensions: `constants/map_constants.asm:172` -> `map_const BLACKTHORN_CITY, 20, 18`
- Connections: `data/maps/attributes.asm:160` -> south `ROUTE_45` (offset 0),
  west `ROUTE_44` (offset 9)
- Callbacks:
  - `MAPCALLBACK_NEWMAP, BlackthornCityFlypointCallback` -> `setflag ENGINE_FLYPOINT_BLACKTHORN`
  - `MAPCALLBACK_OBJECTS, BlackthornCitySantosCallback` -> `readvar VAR_WEEKDAY`,
    `appear`/`disappear BLACKTHORNCITY_SANTOS` on `SATURDAY`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 18 | 11 | `BLACKTHORN_GYM_1F` | 1 |
| 2 | 13 | 21 | `BLACKTHORN_DRAGON_SPEECH_HOUSE` | 1 |
| 3 | 29 | 23 | `BLACKTHORN_EMYS_HOUSE` | 1 |
| 4 | 15 | 29 | `BLACKTHORN_MART` | 2 |
| 5 | 21 | 29 | `BLACKTHORN_POKECENTER_1F` | 1 |
| 6 | 9 | 31 | `MOVE_DELETERS_HOUSE` | 1 |
| 7 | 36 | 9 | `ICE_PATH_1F` | 2 |
| 8 | 20 | 1 | `DRAGONS_DEN_1F` | 1 |

**Coord events**

None.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 34 | 24 | `BGEVENT_READ` | `BlackthornCitySign` |
| 17 | 13 | `BGEVENT_READ` | `BlackthornGymSign` |
| 7 | 31 | `BGEVENT_READ` | `MoveDeletersHouseSign` |
| 21 | 3 | `BGEVENT_READ` | `DragonDensSign` |
| 5 | 25 | `BGEVENT_READ` | `BlackthornCityTrainerTips` |
| 16 | 29 | `BGEVENT_READ` | `BlackthornCityMartSign` -> `jumpstd MartSignScript` |
| 22 | 29 | `BGEVENT_READ` | `BlackthornCityPokecenterSign` -> `jumpstd PokecenterSignScript` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `BLACKTHORNCITY_SUPER_NERD1` | `SPRITE_SUPER_NERD` | 18 | 12 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `BlackthornSuperNerdScript` | `EVENT_BLACKTHORN_CITY_SUPER_NERD_BLOCKS_GYM` |
| `BLACKTHORNCITY_SUPER_NERD2` | `SPRITE_SUPER_NERD` | 19 | 12 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `BlackthornSuperNerdScript` | `EVENT_BLACKTHORN_CITY_SUPER_NERD_DOES_NOT_BLOCK_GYM` |
| `BLACKTHORNCITY_GRAMPS1` | `SPRITE_GRAMPS` | 20 | 2 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `BlackthornGramps1Script` | `EVENT_BLACKTHORN_CITY_GRAMPS_BLOCKS_DRAGONS_DEN` |
| `BLACKTHORNCITY_GRAMPS2` | `SPRITE_GRAMPS` | 21 | 2 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `BlackthornGramps2Script` | `EVENT_BLACKTHORN_CITY_GRAMPS_NOT_BLOCKING_DRAGONS_DEN` |
| `BLACKTHORNCITY_BLACK_BELT` | `SPRITE_BLACK_BELT` | 24 | 31 | `WALK_LEFT_RIGHT` (radius 1) | `OBJECTTYPE_SCRIPT` | `BlackthornBlackBeltScript` | -1 |
| `BLACKTHORNCITY_COOLTRAINER_F1` | `SPRITE_COOLTRAINER_F` | 9 | 25 | `WALK_LEFT_RIGHT` (radius 2) | `OBJECTTYPE_SCRIPT` | `BlackthornCooltrainerF1Script` | -1 |
| `BLACKTHORNCITY_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 13 | 15 | `WALK_LEFT_RIGHT` (radius 1) | `OBJECTTYPE_SCRIPT` | `BlackthornYoungsterScript` | -1 |
| `BLACKTHORNCITY_SANTOS` | `SPRITE_YOUNGSTER` | 22 | 20 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `SantosScript` | `EVENT_BLACKTHORN_CITY_SANTOS_OF_SATURDAY` |
| `BLACKTHORNCITY_COOLTRAINER_F2` | `SPRITE_COOLTRAINER_F` | 35 | 19 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `BlackthornCooltrainerF2Script` | -1 |

**Scripts of interest**

- `BlackthornCityFlypointCallback` - `setflag ENGINE_FLYPOINT_BLACKTHORN`
  (`constants/engine_flags.asm:89`). Fires on `MAPCALLBACK_NEWMAP`, i.e. the
  first time the player walks out of the Ice Path.
- `BlackthornSuperNerdScript` - `checkevent EVENT_BEAT_CLAIR` -> `Text_ClairIsBeaten`;
  else `checkevent EVENT_CLEARED_RADIO_TOWER` -> `Text_ClairIsIn`; else
  `Text_ClairIsOut` ("Our GYM LEADER is training in the cave behind here").
  Both nerd objects share this script.
- `BlackthornGramps1Script` -> `BlackthornGrampsRefusesEntryText`
  ("Only dragon users are permitted to train here"). `BlackthornGramps2Script`
  -> `BlackthornGrampsGrantsEntryText` ("Since CLAIR ... has allowed it").
  These are the Dragon's Den doorman, one object per state.
- `SantosScript` - Saturday-only NPC, `verbosegiveitem SPELL_TAG`, guarded by
  `EVENT_MET_SANTOS_OF_SATURDAY` / `EVENT_GOT_SPELL_TAG_FROM_SANTOS`.
  Not mentioned by the walkthrough; free item for a bot that lands on Saturday.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_BLACKTHORN` | `constants/engine_flags.asm:89` | `BlackthornCityFlypointCallback` | Fly destination unlocked |
| `EVENT_BLACKTHORN_CITY_SUPER_NERD_BLOCKS_GYM` | `:1157` | `maps/RadioTower5F.asm:111` `setevent` | **set -> that object is hidden.** Set once the Radio Tower is cleared, which is what removes the blocker standing on (18, 12), the tile below the gym door |
| `EVENT_BLACKTHORN_CITY_SUPER_NERD_DOES_NOT_BLOCK_GYM` | `:1158` | set at new game (`engine/events/std_scripts.asm:460`), cleared by `maps/RadioTower5F.asm:112` | clear -> the non-blocking nerd stands beside the door at (19, 12) |
| `EVENT_BLACKTHORN_CITY_GRAMPS_BLOCKS_DRAGONS_DEN` | `:1262` | `maps/BlackthornGym1F.asm:54` `setevent` after beating Clair | set -> blocker at (20, 2) hidden |
| `EVENT_BLACKTHORN_CITY_GRAMPS_NOT_BLOCKING_DRAGONS_DEN` | `:1263` | set at new game (`std_scripts.asm:512`), cleared by `BlackthornGym1F.asm:55` | clear -> permissive gramps visible at (21, 2), path to (20, 1) open |
| `EVENT_CLEARED_RADIO_TOWER` | `:42` | read by `BlackthornSuperNerdScript` and `BlackthornBlackBeltScript` | |
| `EVENT_BLACKTHORN_CITY_SANTOS_OF_SATURDAY` | `:1279` | `BlackthornCitySantosCallback` | weekday visibility |

**Items**

None on the overworld map itself.

**Trainers**

None.

**Wild encounters**

Water only: `data/wild/johto_water.asm:264` `def_water_wildmons BLACKTHORN_CITY`,
4 percent: L15 `MAGIKARP`, L10 `MAGIKARP`, L5 `MAGIKARP`.
Fishing group `FISHGROUP_POND` (`data/wild/fish.asm:72`):
Old = Magikarp/Magikarp/Poliwag L10; Good = Magikarp L20, Poliwag L20 x2,
`time_group 6`; Super = Poliwag L40, `time_group 7`, Magikarp L40, Poliwag L40.

---

### MAP_BLACKTHORN_POKECENTER_1F

- Script: `maps/BlackthornPokecenter1F.asm`
- Header: `data/maps/maps.asm:183` -> `TILESET_POKECENTER`, `INDOOR`,
  `LANDMARK_BLACKTHORN_CITY`, `MUSIC_POKEMON_CENTER`, `FALSE`, `PALETTE_DAY`
- Dimensions: `constants/map_constants.asm:168` -> `map_const BLACKTHORN_POKECENTER_1F, 5, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `BLACKTHORN_CITY` | 5 |
| 2 | 4 | 7 | `BLACKTHORN_CITY` | 5 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `BLACKTHORNPOKECENTER1F_NURSE` | `SPRITE_NURSE` | 3 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `BlackthornPokecenter1FNurseScript` -> `jumpstd PokecenterNurseScript` | -1 |
| `BLACKTHORNPOKECENTER1F_GENTLEMAN` | `SPRITE_GENTLEMAN` | 5 | 3 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `BlackthornPokecenter1FGentlemanScript` | -1 |
| `BLACKTHORNPOKECENTER1F_TWIN` | `SPRITE_TWIN` | 1 | 4 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `BlackthornPokecenter1FTwinScript` | -1 |
| `BLACKTHORNPOKECENTER1F_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 7 | 6 | `WALK_LEFT_RIGHT` (radius 1) | `OBJECTTYPE_SCRIPT` | `BlackthornPokecenter1FCooltrainerMScript` -> `jumpstd HappinessCheckScript` | -1 |

No bg events, no coord events.

---

### MAP_BLACKTHORN_MART

- Script: `maps/BlackthornMart.asm`
- Header: `data/maps/maps.asm:182` -> `TILESET_MART`, `INDOOR`,
  `LANDMARK_BLACKTHORN_CITY`, `MUSIC_AZALEA_TOWN`, `FALSE`, `PALETTE_DAY`
- Dimensions: `constants/map_constants.asm:167` -> `map_const BLACKTHORN_MART, 6, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `BLACKTHORN_CITY` | 4 |
| 2 | 3 | 7 | `BLACKTHORN_CITY` | 4 |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `BLACKTHORNMART_CLERK` | `SPRITE_CLERK` | 1 | 3 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `BlackthornMartClerkScript` | -1 |
| `BLACKTHORNMART_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 7 | 6 | `WALK_LEFT_RIGHT` (radius 2) | `OBJECTTYPE_SCRIPT` | `BlackthornMartCooltrainerMScript` | -1 |
| `BLACKTHORNMART_BLACK_BELT` | `SPRITE_BLACK_BELT` | 5 | 2 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `BlackthornMartBlackBeltScript` | -1 |

**Scripts of interest**

`BlackthornMartClerkScript` -> `pokemart MARTTYPE_STANDARD, MART_BLACKTHORN`.
Inventory, `data/items/marts.asm:216` `MartBlackthorn` (`05:63d0`), 9 items:
`GREAT_BALL`, `ULTRA_BALL`, `HYPER_POTION`, `MAX_POTION`, `FULL_HEAL`,
`REVIVE`, `MAX_REPEL`, `X_DEFEND`, `X_ATTACK`.
This is where the walkthrough's "restock Ultra Balls" and "have a few Revives,
Full Heals, and Hyper Potions" shopping list is actually purchasable.

---

### MAP_BLACKTHORN_EMYS_HOUSE

- Script: `maps/BlackthornEmysHouse.asm`
- Header: `data/maps/maps.asm:181` -> `TILESET_HOUSE`, `INDOOR`,
  `LANDMARK_BLACKTHORN_CITY`, `MUSIC_AZALEA_TOWN`, `FALSE`, `PALETTE_DAY`
- Dimensions: `constants/map_constants.asm:166` -> `map_const BLACKTHORN_EMYS_HOUSE, 4, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `BLACKTHORN_CITY` | 3 |
| 2 | 3 | 7 | `BLACKTHORN_CITY` | 3 |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `EmysHouseBookshelf` -> `jumpstd MagazineBookshelfScript` |
| 1 | 1 | `BGEVENT_READ` | same |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `BLACKTHORNEMYSHOUSE_EMY` | `SPRITE_LASS` | 2 | 3 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `Emy` | -1 |

**Scripts of interest**

`Emy` -> `faceplayer / opentext / trade NPC_TRADE_EMY / waitbutton / closetext / end`.
`NPC_TRADE_EMY` is index 3 (`constants/npc_trade_constants.asm:20`) and its row in
`data/events/npc_trades.asm` is:

```
npctrade TRADE_DIALOGSET_NEWBIE, DRAGONAIR, RHYDON, "DON", $77, $66, BITTER_BERRY, 00283, "EMY", TRADE_GENDER_FEMALE
```

So: wants a **female** `DRAGONAIR`, gives `RHYDON` nicknamed "DON",
DVs `$77`/`$66`, holding a `BITTER_BERRY`, OT "EMY" ID 00283.
The walkthrough's "lady that would trade her Rhydon for a Dragonair" omits the
gender requirement, which is load-bearing for a bot.

---

### MAP_MOVE_DELETERS_HOUSE

- Script: `maps/MoveDeletersHouse.asm`
- Header: `data/maps/maps.asm:184` -> `TILESET_HOUSE`, `INDOOR`,
  `LANDMARK_BLACKTHORN_CITY`, `MUSIC_AZALEA_TOWN`, `FALSE`, `PALETTE_DAY`
- Dimensions: `constants/map_constants.asm:169` -> `map_const MOVE_DELETERS_HOUSE, 4, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `BLACKTHORN_CITY` | 6 |
| 2 | 3 | 7 | `BLACKTHORN_CITY` | 6 |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `MoveDeletersHouseBookshelf` -> `jumpstd DifficultBookshelfScript` |
| 1 | 1 | `BGEVENT_READ` | same |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MOVEDELETERSHOUSE_SUPER_NERD` | `SPRITE_SUPER_NERD` | 2 | 3 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `MoveDeleter` | -1 |

**Scripts of interest**

`MoveDeleter` -> `faceplayer / opentext / special MoveDeletion / waitbutton /
closetext / end`. The whole flow lives in `engine/events/move_deleter.asm`; the
script never writes `wScriptVar`.

---

### MAP_BLACKTHORN_DRAGON_SPEECH_HOUSE

Not visited by the walkthrough; included because it is city warp 2.

- Script: `maps/BlackthornDragonSpeechHouse.asm`
- Header: `data/maps/maps.asm:180` -> `TILESET_HOUSE`, `INDOOR`,
  `LANDMARK_BLACKTHORN_CITY`, `MUSIC_AZALEA_TOWN`, `FALSE`, `PALETTE_DAY`
- Dimensions: `constants/map_constants.asm:165` -> `map_const BLACKTHORN_DRAGON_SPEECH_HOUSE, 4, 4`

**Warps**: 1 = (2, 7) -> `BLACKTHORN_CITY` 2; 2 = (3, 7) -> `BLACKTHORN_CITY` 2.

**Object events**: `BLACKTHORNDRAGONSPEECHHOUSE_GRANNY` `SPRITE_GRANNY` at (2, 3),
`SPINRANDOM_SLOW`, `BlackthornDragonSpeechHouseGrannyScript` (CLAIR and LANCE
trained here); `BLACKTHORNDRAGONSPEECHHOUSE_EKANS` `SPRITE_EKANS` at (5, 5),
`SPRITEMOVEDATA_POKEMON`, `BlackthornDragonSpeechHouseDratiniScript`
(`cry DRATINI` - the sprite is EKANS but it is a Dratini).

---

### MAP_BLACKTHORN_GYM_1F

- Script: `maps/BlackthornGym1F.asm` (`BlackthornGym1F_MapEvents` = `53:4964`,
  `BlackthornGym1FBouldersCallback` = `53:4005`, `BlackthornGymClairScript` = `53:4024`)
- Blocks: `maps/BlackthornGym1F.blk`
- Header: `data/maps/maps.asm:178` -> `TILESET_ELITE_FOUR_ROOM`, `INDOOR`,
  `LANDMARK_BLACKTHORN_CITY`, `MUSIC_GYM`, phone `TRUE`, `PALETTE_DAY`
- Dimensions: `constants/map_constants.asm:163` -> `map_const BLACKTHORN_GYM_1F, 5, 9`
- Callbacks: `callback MAPCALLBACK_TILES, BlackthornGym1FBouldersCallback`

**Warps**

| idx | x | y | destination map | dest warp | note |
|---|---|---|---|---|---|
| 1 | 4 | 17 | `BLACKTHORN_CITY` | 1 | door |
| 2 | 5 | 17 | `BLACKTHORN_CITY` | 1 | door |
| 3 | 1 | 7 | `BLACKTHORN_GYM_2F` | 1 | stairs |
| 4 | 7 | 9 | `BLACKTHORN_GYM_2F` | 2 | stairs |
| 5 | 2 | 6 | `BLACKTHORN_GYM_2F` | 3 | landing under 2F hole at (2, 5) |
| 6 | 7 | 7 | `BLACKTHORN_GYM_2F` | 4 | landing under 2F hole at (8, 7) |
| 7 | 7 | 6 | `BLACKTHORN_GYM_2F` | 5 | landing under 2F hole at (8, 3) |

**Coord events**

None.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 3 | 15 | `BGEVENT_READ` | `BlackthornGymStatue` |
| 6 | 15 | `BGEVENT_READ` | `BlackthornGymStatue` |

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `BLACKTHORNGYM1F_CLAIR` | `SPRITE_CLAIR` | 5 | 3 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `BlackthornGymClairScript` | -1 |
| `BLACKTHORNGYM1F_COOLTRAINER_M1` | `SPRITE_COOLTRAINER_M` | 6 | 6 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` | 3 | `TrainerCooltrainermMike` | -1 |
| `BLACKTHORNGYM1F_COOLTRAINER_M2` | `SPRITE_COOLTRAINER_M` | 1 | 14 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` | 3 | `TrainerCooltrainermPaul` | -1 |
| `BLACKTHORNGYM1F_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 9 | 2 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` | 1 | `TrainerCooltrainerfLola` | -1 |
| `BLACKTHORNGYM1F_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 7 | 15 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `BlackthornGymGuideScript` | -1 |

**Scripts of interest**

- `BlackthornGym1FBouldersCallback` (`MAPCALLBACK_TILES`) - paints the fallen
  boulders that came through the 2F holes:

  ```
  checkevent EVENT_BOULDER_IN_BLACKTHORN_GYM_1 -> changeblock 8, 2, $3b
  checkevent EVENT_BOULDER_IN_BLACKTHORN_GYM_2 -> changeblock 2, 4, $3a
  checkevent EVENT_BOULDER_IN_BLACKTHORN_GYM_3 -> changeblock 8, 6, $3b
  ```

  (`Script_changeblock` adds 4 to both operands and then divides down to a block
  index, so these are block coordinates (4, 1), (1, 2) and (4, 3).)
- `BlackthornGymClairScript` (`53:4024`) - the single most important script in
  this section. Control flow:
  1. `checkflag ENGINE_RISINGBADGE` -> `.AlreadyGotBadge` (`53:4074`).
  2. `checkevent EVENT_BEAT_CLAIR` -> `.FightDone` (`53:4063`).
  3. Otherwise: `ClairIntroText`, `winlosstext ClairWinText, 0`,
     `loadtrainer CLAIR, CLAIR1`, `startbattle`, `reloadmapafterbattle`,
     `setevent EVENT_BEAT_CLAIR`, `ClairText_GoToDragonsDen`, then a block of
     bookkeeping:
     `setevent EVENT_BEAT_COOLTRAINERM_PAUL`, `..._CODY`, `..._MIKE`,
     `setevent EVENT_BEAT_COOLTRAINERF_FRAN`, `..._LOLA`
     (the five gym trainers are force-marked beaten),
     `clearevent EVENT_MAHOGANY_MART_OWNERS`,
     `setevent EVENT_BLACKTHORN_CITY_GRAMPS_BLOCKS_DRAGONS_DEN`,
     `clearevent EVENT_BLACKTHORN_CITY_GRAMPS_NOT_BLOCKING_DRAGONS_DEN`
     (this pair is what opens Dragon's Den). **No badge and no TM are given here.**
  4. `.FightDone`: `checkitem DRAGON_FANG` -> `.HasDragonFang`
     (`BlackthornGymClairText_Cheat`, "You did not get that at DRAGON'S DEN") ;
     else `ClairText_WhatsTheMatter`.
  5. `.AlreadyGotBadge`: `checkevent EVENT_GOT_TM24_DRAGONBREATH` -> `.GotTM24`
     (`BlackthornGymClairText_League`); else `verbosegiveitem TM_DRAGONBREATH`,
     `setevent EVENT_GOT_TM24_DRAGONBREATH`. This is the fallback path for a
     player whose bag was full in the Den.
- `BlackthornGymStatue` - `checkflag ENGINE_RISINGBADGE` -> `jumpstd GymStatue2Script`
  with `gettrainername STRING_BUFFER_4, CLAIR, CLAIR1`; else `jumpstd GymStatue1Script`.
- `BlackthornGymGuideScript` - branches on `EVENT_BEAT_CLAIR`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_CLAIR` | `constants/event_flags.asm:713` | set by `BlackthornGymClairScript` | battle won; badge still pending |
| `ENGINE_RISINGBADGE` | `constants/engine_flags.asm:45` | **set in `maps/DragonsDenB1F.asm`, not here** | the actual 8th badge |
| `EVENT_GOT_TM24_DRAGONBREATH` | `constants/event_flags.asm:21` | Den script, or the `.AlreadyGotBadge` fallback here | |
| `EVENT_BOULDER_IN_BLACKTHORN_GYM_1..3` | `:1192-1194` | 2F stone table `disappear`; read by the 1F tiles callback | set -> boulder has fallen; 1F block repainted |
| `EVENT_BEAT_COOLTRAINERM_PAUL` / `_CODY` / `_MIKE` | `:859-861` | `trainer` rows and the Clair script's bulk `setevent` | |
| `EVENT_BEAT_COOLTRAINERF_FRAN` / `_LOLA` | `:879-880` | same | |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `TM_DRAGONBREATH` (TM24) | Clair, only on the `.AlreadyGotBadge` re-talk path | `BlackthornGymClairScript.AlreadyGotBadge` | `EVENT_GOT_TM24_DRAGONBREATH` |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `COOLTRAINERM`, `PAUL` | `CooltrainerMGroup` | COOLTRAINERM (3) | L34 `DRATINI` x3; `TRAINERTYPE_NORMAL` | `TrainerCooltrainermPaul` | none |
| `COOLTRAINERM`, `MIKE` | same | COOLTRAINERM (5) | L37 `DRAGONAIR`; `TRAINERTYPE_NORMAL` | `TrainerCooltrainermMike` | none |
| `COOLTRAINERF`, `LOLA` | `CooltrainerFGroup` | COOLTRAINERF (4) | L34 `DRATINI`, L36 `DRAGONAIR`; `TRAINERTYPE_NORMAL` | `TrainerCooltrainerfLola` | none |
| `CLAIR`, `CLAIR1` | `ClairGroup` (`data/trainers/parties.asm:67`) | CLAIR (1); `TRAINERTYPE_MOVES` | L37 `DRAGONAIR` (Thunder Wave / Surf / Slam / Dragonbreath), L37 `DRAGONAIR` (Thunder Wave / Thunderbolt / Slam / Dragonbreath), L37 `DRAGONAIR` (Thunder Wave / Ice Beam / Slam / Dragonbreath), L40 `KINGDRA` (Smokescreen / Surf / Hyper Beam / Dragonbreath) | `BlackthornGymClairScript` | none |

Note the party **order**: the asm sends out three Dragonair first and Kingdra
last. The walkthrough lists Kingdra third.

**Wild encounters**

None (indoor).

---

### MAP_BLACKTHORN_GYM_2F

- Script: `maps/BlackthornGym2F.asm` (`BlackthornGym2F_MapEvents` = `53:4bc8`,
  `BlackthornGym2FSetUpStoneTableCallback` = `53:49dd`)
- Blocks: `maps/BlackthornGym2F.blk`
- Header: `data/maps/maps.asm:179` -> `TILESET_ELITE_FOUR_ROOM`, `INDOOR`,
  `LANDMARK_BLACKTHORN_CITY`, `MUSIC_GYM`, `TRUE`, `PALETTE_DAY`
- Dimensions: `constants/map_constants.asm:164` -> `map_const BLACKTHORN_GYM_2F, 5, 9`
- Callbacks: `callback MAPCALLBACK_CMDQUEUE, BlackthornGym2FSetUpStoneTableCallback`

**Warps**

| idx | x | y | destination map | dest warp | note |
|---|---|---|---|---|---|
| 1 | 1 | 7 | `BLACKTHORN_GYM_1F` | 3 | stairs |
| 2 | 7 | 9 | `BLACKTHORN_GYM_1F` | 4 | stairs |
| 3 | 2 | 5 | `BLACKTHORN_GYM_1F` | 5 | hole |
| 4 | 8 | 7 | `BLACKTHORN_GYM_1F` | 6 | hole |
| 5 | 8 | 3 | `BLACKTHORN_GYM_1F` | 7 | hole |

**Coord events / BG events**

None.

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `BLACKTHORNGYM2F_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 4 | 1 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 1 | `TrainerCooltrainermCody` | -1 |
| `BLACKTHORNGYM2F_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 4 | 11 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 1 | `TrainerCooltrainerfFran` | -1 |
| `BLACKTHORNGYM2F_BOULDER1` | `SPRITE_BOULDER` | 8 | 2 | `STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | 0 | `BlackthornGymBoulder` | `EVENT_BOULDER_IN_BLACKTHORN_GYM_1` |
| `BLACKTHORNGYM2F_BOULDER2` | `SPRITE_BOULDER` | 2 | 3 | `STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | 0 | `BlackthornGymBoulder` | `EVENT_BOULDER_IN_BLACKTHORN_GYM_2` |
| `BLACKTHORNGYM2F_BOULDER3` | `SPRITE_BOULDER` | 6 | 16 | `STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | 0 | `BlackthornGymBoulder` | `EVENT_BOULDER_IN_BLACKTHORN_GYM_3` |
| `BLACKTHORNGYM2F_BOULDER4` | `SPRITE_BOULDER` | 3 | 3 | `STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | 0 | `BlackthornGymBoulder` | -1 |
| `BLACKTHORNGYM2F_BOULDER5` | `SPRITE_BOULDER` | 6 | 1 | `STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | 0 | `BlackthornGymBoulder` | -1 |
| `BLACKTHORNGYM2F_BOULDER6` | `SPRITE_BOULDER` | 8 | 14 | `STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | 0 | `BlackthornGymBoulder` | -1 |

Three of the six boulders (4, 5, 6) carry **no** event flag and therefore never
disappear - they are the bridge-building boulders, not the hole-filling ones.

**Scripts of interest**

- `BlackthornGym2FSetUpStoneTableCallback` `.StoneTable`:

  ```
  stonetable 5, BLACKTHORNGYM2F_BOULDER1, .Boulder1   ; warp 5 = (8, 3)
  stonetable 3, BLACKTHORNGYM2F_BOULDER2, .Boulder2   ; warp 3 = (2, 5)
  stonetable 4, BLACKTHORNGYM2F_BOULDER3, .Boulder3   ; warp 4 = (8, 7)
  db -1
  ```

  Note the deliberately scrambled warp order: boulder 1 belongs in warp 5,
  boulder 2 in warp 3, boulder 3 in warp 4.
- Each arm does `disappear BLACKTHORNGYM2F_BOULDERn` (setting the matching
  `EVENT_BOULDER_IN_BLACKTHORN_GYM_n`) then `.Fall`: `pause 30`, `scall .FX`
  (`playsound SFX_STRENGTH`, `earthquake 80`), `BlackthornGym2FBoulderFellText`
  ("The boulder fell / through!").
- `BlackthornGymBoulder` -> `jumpstd StrengthBoulderScript` for all six.

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `COOLTRAINERM`, `CODY` | `CooltrainerMGroup` | COOLTRAINERM (4) | L34 `HORSEA`, L36 `SEADRA`; `TRAINERTYPE_NORMAL` | `TrainerCooltrainermCody` | none |
| `COOLTRAINERF`, `FRAN` | `CooltrainerFGroup` | COOLTRAINERF (3) | L37 `SEADRA`; `TRAINERTYPE_NORMAL` | `TrainerCooltrainerfFran` | none |

---

### MAP_DRAGONS_DEN_1F

- Script: `maps/DragonsDen1F.asm` (`DragonsDen1F_MapEvents` = `47:44c2`)
- Blocks: `maps/DragonsDen1F.blk`
- Header: `data/maps/maps.asm:150` -> `TILESET_CAVE`, `CAVE`,
  `LANDMARK_DRAGONS_DEN`, `MUSIC_DRAGONS_DEN`, `TRUE`, `PALETTE_NITE`,
  `FISHGROUP_DRATINI`
- Dimensions: `constants/map_constants.asm:137` -> `map_const DRAGONS_DEN_1F, 5, 9`
- Scene scripts, callbacks, coord events, bg events, object events: **all empty**

**Warps**

| idx | x | y | destination map | dest warp | note |
|---|---|---|---|---|---|
| 1 | 3 | 5 | `BLACKTHORN_CITY` | 8 | cave mouth |
| 2 | 3 | 3 | `DRAGONS_DEN_1F` | 4 | internal ladder, pairs with warp 4 |
| 3 | 5 | 15 | `DRAGONS_DEN_B1F` | 1 | the door down to the Den proper |
| 4 | 5 | 13 | `DRAGONS_DEN_1F` | 2 | internal ladder, pairs with warp 2 |

The "bodyguard in front of it" the walkthrough mentions is on
`MAP_BLACKTHORN_CITY`, not here - `BLACKTHORNCITY_GRAMPS1` at (20, 2).

---

### MAP_DRAGONS_DEN_B1F

- Script: `maps/DragonsDenB1F.asm` (`DragonsDenB1F_MapEvents` = `47:49da`,
  `DragonsDenB1FDragonFangScript` = `47:44fa`)
- Blocks: `maps/DragonsDenB1F.blk`
- Header: `data/maps/maps.asm:151` -> `TILESET_JOHTO`, `CAVE`,
  `LANDMARK_DRAGONS_DEN`, `MUSIC_DRAGONS_DEN`, phone `TRUE`, `PALETTE_NITE`,
  `FISHGROUP_DRATINI`
- Dimensions: `constants/map_constants.asm:138` -> `map_const DRAGONS_DEN_B1F, 20, 18`
- Attributes: `data/maps/attributes.asm:470`, no connections
- Callbacks: `callback MAPCALLBACK_NEWMAP, DragonsDenB1FCheckRivalCallback`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 20 | 3 | `DRAGONS_DEN_1F` | 3 |

**Coord events**

None.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 18 | 24 | `BGEVENT_READ` | `DragonShrineSignpost` |
| 31 | 4 | `BGEVENT_ITEM` | `DragonsDenB1FHiddenRevive` -> `hiddenitem REVIVE, EVENT_DRAGONS_DEN_B1F_HIDDEN_REVIVE` |
| 21 | 17 | `BGEVENT_ITEM` | `DragonsDenB1FHiddenMaxPotion` -> `hiddenitem MAX_POTION, EVENT_DRAGONS_DEN_B1F_HIDDEN_MAX_POTION` |
| 31 | 15 | `BGEVENT_ITEM` | `DragonsDenB1FHiddenMaxElixer` -> `hiddenitem MAX_ELIXER, EVENT_DRAGONS_DEN_B1F_HIDDEN_MAX_ELIXER` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `DRAGONSDENB1F_POKE_BALL1` | `SPRITE_POKE_BALL` | 35 | 16 | `STILL` | `OBJECTTYPE_SCRIPT` | `DragonsDenB1FDragonFangScript` | `EVENT_DRAGONS_DEN_B1F_DRAGON_FANG` |
| `DRAGONSDENB1F_CLAIR` | `SPRITE_CLAIR` | 35 | 22 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_DRAGONS_DEN_CLAIR` |
| `DRAGONSDENB1F_RIVAL` | `SPRITE_RIVAL` | 20 | 23 | `WANDER` (radius 2, 2) | `OBJECTTYPE_SCRIPT` | `DragonsDenB1FRivalScript` | `EVENT_RIVAL_DRAGONS_DEN` |

Note the Dragon Fang object is `OBJECTTYPE_SCRIPT`, **not** `OBJECTTYPE_ITEMBALL` -
it runs a full script, so a bot cannot treat it as a plain pickup.

**Scripts of interest**

- `DragonsDenB1FDragonFangScript` (`47:44fa`) - the badge handoff:
  1. `giveitem DRAGON_FANG`; `iffalse .BagFullDragonFang` (`47:4558`, which prints
     `Text_FoundDragonFang` + `Text_NoRoomForDragonFang` and ends **without**
     setting anything - a full bag here loses the whole scene until you return).
  2. `disappear DRAGONSDENB1F_POKE_BALL1` (sets `EVENT_DRAGONS_DEN_B1F_DRAGON_FANG`),
     `Text_FoundDragonFang`, `playsound SFX_ITEM`, `itemnotify`.
  3. `readvar VAR_FACING`; `ifequal RIGHT, .next` -> `moveobject DRAGONSDENB1F_CLAIR, 34, 21`
     (Clair spawns one cell over when the player grabbed the Fang facing right).
  4. `appear DRAGONSDENB1F_CLAIR` (clears `EVENT_DRAGONS_DEN_CLAIR`),
     `applymovement DRAGONSDENB1F_CLAIR, MovementDragonsDen_ClairWalksToYou`
     (four `step UP`), `turnobject PLAYER, DOWN`.
  5. `ClairText_GiveDragonbreathDragonDen`,
     `DragonShrinePlayerReceivedRisingBadgeText`, `playsound SFX_GET_BADGE`,
     **`setflag ENGINE_RISINGBADGE`**, `specialphonecall SPECIALCALL_MASTERBALL`,
     `DragonShrineRisingBadgeExplanationText`,
     `verbosegiveitem TM_DRAGONBREATH, 1`, `setevent EVENT_GOT_TM24_DRAGONBREATH`,
     `ClairText_CollectedAllBadges` (the "go to NEW BARK TOWN then SURF east"
     directions), then `applymovement ... MovementDragonsDen_ClairWalksAway`
     (four `step DOWN`) and `disappear DRAGONSDENB1F_CLAIR`.
- `DragonsDenB1FCheckRivalCallback` - `checkevent EVENT_BEAT_RIVAL_IN_MT_MOON`,
  then `readvar VAR_WEEKDAY` and appears the rival only on `TUESDAY` or
  `THURSDAY`. Mt. Moon is post-Elite-Four, so the rival is **never** present
  during this section; `DragonsDenB1FRivalScript` is a talk-only scene guarded by
  `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1`.
- `DragonShrineSignpost` - Gold/Silver has no separate Dragon Shrine map; the
  shrine is only this signpost at (18, 24).

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_DRAGONS_DEN_B1F_DRAGON_FANG` | `constants/event_flags.asm:1097` | `disappear` in the Fang script | set -> Fang taken, scene done |
| `EVENT_DRAGONS_DEN_CLAIR` | `:1146` | set at new game (`std_scripts.asm`), cleared by `appear`, re-set by the closing `disappear` | Clair's cutscene object |
| `ENGINE_RISINGBADGE` | `constants/engine_flags.asm:45` | `setflag` here | 8th badge; also the Waterfall gate |
| `EVENT_GOT_TM24_DRAGONBREATH` | `constants/event_flags.asm:21` | `setevent` here | |
| `SPECIALCALL_MASTERBALL` | `constants/phone_constants.asm:52` | `specialphonecall` here; consumed by `ElmPhoneCallerScript` (`engine/phone/scripts/elm.asm:70` `.gift`) | queues Elm's call; the ball itself is `ElmGiveMasterBallScript` in `maps/ElmsLab.asm`, gated on `checkflag ENGINE_RISINGBADGE` |
| `EVENT_RIVAL_DRAGONS_DEN` | `:1128` | callback | rival hidden until post-Mt.-Moon Tue/Thu |
| `EVENT_DRAGONS_DEN_B1F_HIDDEN_REVIVE` / `_MAX_POTION` / `_MAX_ELIXER` | `:170-172` | hidden bg events | |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `DRAGON_FANG` | `giveitem` from the object at (35, 16) | `DragonsDenB1FDragonFangScript` | `EVENT_DRAGONS_DEN_B1F_DRAGON_FANG` |
| `TM_DRAGONBREATH` (TM24) | `verbosegiveitem` from Clair right after | same | `EVENT_GOT_TM24_DRAGONBREATH` |
| `REVIVE` | hidden at (31, 4) | `DragonsDenB1FHiddenRevive` | `EVENT_DRAGONS_DEN_B1F_HIDDEN_REVIVE` |
| `MAX_POTION` | hidden at (21, 17) | `DragonsDenB1FHiddenMaxPotion` | `EVENT_DRAGONS_DEN_B1F_HIDDEN_MAX_POTION` |
| `MAX_ELIXER` | hidden at (31, 15) | `DragonsDenB1FHiddenMaxElixer` | `EVENT_DRAGONS_DEN_B1F_HIDDEN_MAX_ELIXER` |

**Wild encounters**

- Water: `data/wild/johto_water.asm:121` `def_water_wildmons DRAGONS_DEN_B1F`,
  4 percent: L15 `MAGIKARP`, L10 `MAGIKARP`, L10 `DRATINI`. There is no grass
  table for this map; the walkthrough's "Magikarp / Dratini" list is Surf-only.
- Fishing group `FISHGROUP_DRATINI` (`data/maps/maps.asm:151`),
  `data/wild/fish.asm:87`: Old = Magikarp L10 x3; Good = Magikarp L20 x3 +
  `time_group 8` (Dratini L20); Super = Magikarp L40, `time_group 9`
  (Dratini L40), Magikarp L40, `DRAGONAIR` L40.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Blackthorn Gym door at (18, 11) | `maps/BlackthornCity.asm` object `BLACKTHORNCITY_SUPER_NERD1` standing on (18, 12) with flag `EVENT_BLACKTHORN_CITY_SUPER_NERD_BLOCKS_GYM` | that event **set** (object hidden) | `maps/RadioTower5F.asm:111-112` sets `EVENT_BLACKTHORN_CITY_SUPER_NERD_BLOCKS_GYM` and clears `..._DOES_NOT_BLOCK_GYM` when the Radio Tower is cleared. Previous section's work; a bot arriving here without it is stuck at the gym door |
| Dragon's Den entrance at (20, 1) | `maps/BlackthornCity.asm` object `BLACKTHORNCITY_GRAMPS1` standing on (20, 2) with flag `EVENT_BLACKTHORN_CITY_GRAMPS_BLOCKS_DRAGONS_DEN` | that event **set** (object hidden) | `maps/BlackthornGym1F.asm:54-55` inside `BlackthornGymClairScript`, immediately after `setevent EVENT_BEAT_CLAIR` |
| Ice Path B1F -> Blackthorn side | `maps/IcePathB1F.asm` `IcePathB1FSetUpStoneTableCallback.StoneTable`; the four `SPRITEMOVEDATA_STRENGTH_BOULDER` objects | HM04 STRENGTH usable = `ENGINE_PLAINBADGE` (`engine/events/overworld.asm:941` `StrengthFunction.TryStrength` -> `CheckBadge`) plus a party member that knows the move | push boulder N onto warp N+2 (see the map block above). No script check gates the route - it is the `.blk` geometry plus the four boulders |
| Ice Path B3F Nevermeltice at (5, 7) | `maps/IcePathB3F.asm` object `ICEPATHB3F_ROCK` at (6, 6), `SPRITEMOVEDATA_SMASHABLE_ROCK`, `jumpstd SmashRockScript` | ROCK SMASH in the party; **no badge check** (`HasRockSmash` only calls `CheckPartyMove`) | smash it |
| Dragon's Den B1F, reaching the Dragon Fang | whirlpool block in `maps/DragonsDenB1F.blk`; `data/collision/field_move_blocks.asm:52` `WhirlpoolBlockPointers.johto` = facing block `$07` -> replacement `$36` | SURF (`ENGINE_FOGBADGE`, `engine/events/overworld.asm:340`) and WHIRLPOOL (`ENGINE_GLACIERBADGE`, `:1077` `WhirlpoolFunction.TryWhirlpool`) | the one `$07` block on this map is block (5, 10) = walk cells x 10-11, y 20-21 |
| Waterfall as a field move | `engine/events/overworld.asm:611` `WaterfallFunction` -> `:618 ld de, ENGINE_RISINGBADGE / farcall CheckBadge` | `ENGINE_RISINGBADGE` | granted by `DragonsDenB1FDragonFangScript`, i.e. HM07 picked up in the Ice Path is unusable for the whole of this section |
| Rising Badge itself | `maps/BlackthornGym1F.asm` `BlackthornGymClairScript` deliberately does **not** `setflag ENGINE_RISINGBADGE` | beating Clair is not sufficient | `maps/DragonsDenB1F.asm` `DragonsDenB1FDragonFangScript` |
| Master Ball from Elm | `maps/ElmsLab.asm:60` `checkflag ENGINE_RISINGBADGE / iftrue ElmGiveMasterBallScript` | `ENGINE_RISINGBADGE` | `specialphonecall SPECIALCALL_MASTERBALL` from the Den queues the phone call; the item is picked up in Elm's Lab (next section) |
| Dragon Fang bag space | `DragonsDenB1FDragonFangScript` `giveitem DRAGON_FANG / iffalse .BagFullDragonFang` | free bag slot | a full bag silently aborts the entire badge scene; the walkthrough's "deposit any extraneous items" advice is load bearing here |

## 4. Bot checklist

Coordinates are asm map coordinates (`object_event` / `warp_event` values).
"Pre" = precondition flag, "Post" = postcondition flag.

1. `MAP_MAHOGANY_TOWN` - Fly, heal, walk east across the map connection to
   `MAP_ROUTE_44`. Pre: `EVENT_CLEARED_RADIO_TOWER` (else the Blackthorn gym stays
   blocked later).
2. `MAP_ROUTE_44` - battle `TrainerPsychicPhil` at (10, 9), sight 3.
   Post: `EVENT_BEAT_PSYCHIC_PHIL`.
3. `MAP_ROUTE_44` - walk to (9, 5) and talk to `ROUTE44_FRUIT_TREE`
   -> `BURNT_BERRY`.
4. `MAP_ROUTE_44` - walk to (30, 8), pick up `Route44MaxRevive`
   (`MAX_REVIVE`, not Max Repel). Post: `EVENT_ROUTE_44_MAX_REVIVE`.
5. `MAP_ROUTE_44` - battle `TrainerFisherEdgar` at (19, 13),
   `TrainerCooltrainerfCybil` at (31, 14), `TrainerCooltrainermAllen` at (41, 15).
6. `MAP_ROUTE_44` - pick up `Route44UltraBall` at (43, 2).
   Post: `EVENT_ROUTE_44_ULTRA_BALL`. Optional: hidden `ELIXER` at (32, 9).
7. `MAP_ROUTE_44` - battle `TrainerPokemaniacZach` at (35, 2),
   `TrainerFisherWilton1` at (42, 5) (register `PHONE_FISHER_WILTON`),
   `TrainerBirdKeeperVance1` at (50, 7) (register `PHONE_BIRDKEEPER_VANCE`).
8. Party check before the cave: needs STRENGTH (`ENGINE_PLAINBADGE` already held)
   and ROCK SMASH. All five Ice Path maps are `PALETTE_NITE`
   (`data/maps/maps.asm:131-135`), not `PALETTE_DARK`
   (`constants/map_data_constants.asm:38`, which is what
   `DarkCaveBlackthornEntrance` uses at `data/maps/maps.asm:149`), so FLASH is
   not required.
9. `MAP_ROUTE_44` (56, 7) -> warp 1 -> `MAP_ICE_PATH_1F` (4, 19).
10. `MAP_ICE_PATH_1F` - slide to (31, 7), take `IcePath1FHMWaterfall`.
    Post: `EVENT_GOT_HM07_WATERFALL`. The move is unusable until step 30.
11. `MAP_ICE_PATH_1F` (37, 5) -> warp 3 -> `MAP_ICE_PATH_B1F` (3, 15).
12. `MAP_ICE_PATH_B1F` - use STRENGTH, push `ICEPATHB1F_BOULDER1` from (11, 7)
    onto warp 3 at (11, 2). Post: `EVENT_BOULDER_IN_ICE_PATH_1` set,
    `EVENT_BOULDER_IN_ICE_PATH_1A` cleared.
13. Push `ICEPATHB1F_BOULDER2` from (7, 8) onto warp 4 at (4, 7).
    Post: `EVENT_BOULDER_IN_ICE_PATH_2` / `_2A`.
14. Push `ICEPATHB1F_BOULDER3` from (8, 9) onto warp 5 at (5, 12).
    Post: `EVENT_BOULDER_IN_ICE_PATH_3` / `_3A`.
15. Push `ICEPATHB1F_BOULDER4` from (17, 7) onto warp 6 at (12, 13).
    Post: `EVENT_BOULDER_IN_ICE_PATH_4` / `_4A`.
    (STRENGTH must be re-activated after every map load - `ResetBikeFlags`.)
16. Drop through any hole, or take warp 2 at (17, 3) ->
    `MAP_ICE_PATH_B2F_MAHOGANY_SIDE` (17, 1).
17. `MAP_ICE_PATH_B2F_MAHOGANY_SIDE` - pick up `FULL_HEAL` at (8, 9) and
    `MAX_POTION` at (0, 2); optional hidden `CARBOS` at (0, 17).
18. Warp 2 at (9, 11) -> `MAP_ICE_PATH_B3F` (3, 5).
19. `MAP_ICE_PATH_B3F` - ROCK SMASH `ICEPATHB3F_ROCK` at (6, 6), take
    `NEVERMELTICE` at (5, 7). Post: `EVENT_ICE_PATH_B3F_NEVERMELTICE`.
20. Warp 2 at (15, 5) -> `MAP_ICE_PATH_B2F_BLACKTHORN_SIDE` (3, 3).
21. Take `TM_REST` (TM44) at (8, 16). Post:
    `EVENT_ICE_PATH_B2F_BLACKTHORN_SIDE_TM_REST`. Optional hidden `ICE_HEAL` at (2, 10).
22. Warp 1 at (3, 15) -> `MAP_ICE_PATH_B1F` (11, 27) (south region).
23. Take `IRON` at (5, 35). Post: `EVENT_ICE_PATH_B1F_IRON`. Optional hidden
    `MAX_POTION` at (15, 31).
24. Warp 7 at (5, 25) -> `MAP_ICE_PATH_1F` (37, 13) (south region).
25. Take `PP_UP` at (32, 23). Post: `EVENT_ICE_PATH_1F_PP_UP`.
26. Warp 2 at (36, 27) -> `MAP_BLACKTHORN_CITY` (36, 9).
    Post: `ENGINE_FLYPOINT_BLACKTHORN` (via `MAPCALLBACK_NEWMAP`).
27. `MAP_BLACKTHORN_CITY` (21, 29) -> Pokecenter, heal. (15, 29) -> Mart,
    buy from `MartBlackthorn`. Optional (29, 23) Emy trade (needs a **female**
    Dragonair), (9, 31) Move Deleter.
28. `MAP_BLACKTHORN_CITY` (18, 11) -> `MAP_BLACKTHORN_GYM_1F` (4, 17).
    Pre: `EVENT_BLACKTHORN_CITY_SUPER_NERD_BLOCKS_GYM` set.
29. Gym: battle `TrainerCooltrainermPaul` (1, 14), take warp 3 at (1, 7) to 2F;
    battle `TrainerCooltrainerfFran` (4, 11) and `TrainerCooltrainermCody` (4, 1);
    push `BLACKTHORNGYM2F_BOULDER2` (2, 3) onto warp 3 (2, 5),
    `BLACKTHORNGYM2F_BOULDER3` (6, 16) onto warp 4 (8, 7),
    `BLACKTHORNGYM2F_BOULDER1` (8, 2) onto warp 5 (8, 3); use boulders 4, 5, 6
    ((3, 3), (6, 1), (8, 14)) as bridge pieces. Back on 1F battle
    `TrainerCooltrainermMike` (6, 6) and `TrainerCooltrainerfLola` (9, 2).
    All five are force-set by the Clair script anyway, so a bot may skip them.
30. Talk to `BLACKTHORNGYM1F_CLAIR` at (5, 3) -> `loadtrainer CLAIR, CLAIR1`.
    Post: `EVENT_BEAT_CLAIR`, plus `EVENT_BLACKTHORN_CITY_GRAMPS_BLOCKS_DRAGONS_DEN`
    set and `..._NOT_BLOCKING_DRAGONS_DEN` cleared. **No badge yet.**
31. Bag check: at least one free slot (see the `.BagFullDragonFang` trap).
32. `MAP_BLACKTHORN_CITY` (20, 1) -> `MAP_DRAGONS_DEN_1F` (3, 5).
    Ladder (3, 3) -> (5, 13), then (5, 15) -> `MAP_DRAGONS_DEN_B1F` (20, 3).
33. `MAP_DRAGONS_DEN_B1F` - SURF, dissolve the whirlpool at walk cells
    (10-11, 20-21), surf east to (35, 16) and take the Dragon Fang.
    Post: `EVENT_DRAGONS_DEN_B1F_DRAGON_FANG`, `ENGINE_RISINGBADGE`,
    `EVENT_GOT_TM24_DRAGONBREATH`, `SPECIALCALL_MASTERBALL` queued.
    Optional hidden items at (31, 4), (21, 17), (31, 15).
34. Exit via warp 1 at (20, 3). WATERFALL is now usable. The Elm phone call
    fires outside; the Master Ball pickup in `MAP_ELMS_LAB` is the next section.

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map headers, dimensions, warps/coord/bg/object event tables for every map above | `src/import/RomExtractorGen2.lua` (`warps`, `coordEvents`, `bgEvents`, `objects` at lines 787-862, consumed at 973-975) | implemented (data-driven from the ROM, so no per-map porting is needed) |
| Map script execution (`checkevent`, `setevent`, `giveitem`, `verbosegiveitem`, `loadtrainer`, `startbattle`, `applymovement`, `moveobject`, `changeblock`, `earthquake`, `writecmdqueue`, `trade`, `specialphonecall`) | `src/script/gen2/Vm.lua` (490, 806, 1002, 1044, 1292, 1364, 1445) | implemented |
| Ice Path B1F stone table (boulder -> hole -> fall) | `src/world/gen2/CmdQueue.lua:212-222` (`ICE_PATH_B1F`, warps 2-5 zero-based against objects 2-5, events 1805-1808) | implemented; covered by `tests/drivers/gold_icepath_boulder.lua` and `tests/drivers/gold_map_callbacks.lua:167` |
| Blackthorn Gym 2F stone table | `src/world/gen2/CmdQueue.lua:227-230` (warps 5/3/4 -> objects 4/5/6, matching the scrambled asm order) | implemented; no dedicated driver |
| Blackthorn Gym 1F `MAPCALLBACK_TILES` fallen-boulder `changeblock` | `src/script/gen2/Vm.lua:1002` | implemented (generic `changeblock`) |
| STRENGTH badge gate + `ResetBikeFlags` clearing STRENGTH on every map load | `src/world/gen2/FieldMoves.lua:108` (`STRENGTH = "PLAIN"`), `src/world/gen2/World.lua:5610-5613` | implemented |
| WHIRLPOOL badge gate + block replacement | `src/world/gen2/FieldMoves.lua:109,247,540-556,624` | implemented |
| WATERFALL badge gate (`ENGINE_RISINGBADGE`) | `src/world/gen2/FieldMoves.lua:110,253-266,528-538` | implemented |
| ROCK SMASH (`HasRockSmash` inversion) | `src/script/gen2/CallAsm.lua:344-350` | implemented |
| **Ice tile sliding (`STEP_ICE`)** | `src/world/gen2/Permissions.lua:128,142` defines `ICE = {0x23, 0x2b}` but the only caller is `src/world/gen2/FieldMoves.lua:169`; there is no `STEP_ICE` arm in `World:movePlayer` (`src/world/gen2/World.lua:5876`) and no `CheckStandingOnIce` equivalent anywhere in `src/` | **missing** - this is the single biggest gap for this section, because every Ice Path floor is an ice-slide maze. A bot can push boulders but cannot traverse the mazes as the cart does |
| `ENGINE_FLYPOINT_BLACKTHORN` / Fly to Blackthorn | `src/world/gen2/FieldMoves.lua:354` (`LANDMARK_BLACKTHORN_CITY`, `SPAWN_BLACKTHORN`, flag 74) | implemented |
| Emy's NPC trade (`NPC_TRADE_EMY`, female Dragonair) | `src/core/gen2/NpcTrade.lua` (gender check at :91-93), `src/script/gen2/Vm.lua:1292` `trade` opcode | implemented |
| Move Deleter (`special MoveDeletion`) | `src/script/gen2/Specials.lua:637` `H.MoveDeletion`, `src/ui/gen2/MoveDeleter.lua` | implemented |
| Blackthorn Mart (`pokemart MARTTYPE_STANDARD, MART_BLACKTHORN`) | `src/ui/gen2/MartMenu.lua` + extractor mart tables | implemented (generic) |
| Vance / Wilton phone registration and rematch | `src/core/gen2/Phone.lua:210-215` (ids 32 and 33), rematch flags at `:451-452` | implemented |
| `specialphonecall SPECIALCALL_MASTERBALL` -> Elm's call | `src/script/gen2/Vm.lua:1364-1371`, `src/core/gen2/Phone.lua:402-403` (`[8] = SPECIALCALL_MASTERBALL`, condition `outside`, `ElmPhoneCallerScript`) | implemented |
| Rising Badge on the trainer card / badge list | `src/ui/gen2/TrainerCard.lua:64,74`, `src/world/gen2/FieldMoves.lua:118` | implemented |
| Clair battle, gym leader music / party | generic battle path `src/battle/gen2/Battle.lua` + extracted `data/trainers/parties.asm` | implemented (generic); no Blackthorn-specific driver exists under `tests/drivers/gold_*.lua` |
| End-to-end scripted run of this section | - | **missing** - the only relevant driver is `tests/drivers/gold_icepath_boulder.lua`, which teleports directly to `ICE_PATH_B1F` (9, 2) and tests one boulder |

## 6. Unresolved / verify by hand

- **"Max Repel" on Route 44.** The walkthrough says "then the item east of that
  trainer (Max Repel)". The asm item ball at (30, 8) is
  `Route44MaxRevive: itemball MAX_REVIVE`. There is no Max Repel object on
  `MAP_ROUTE_44`; Max Repel is a Blackthorn Mart stock item
  (`data/items/marts.asm:224`). Treat the walkthrough as wrong.
- **Route 44 item list.** The section header lists only "Burnt Berry, Ultra Ball"
  but the map also has the Max Revive ball and a hidden Elixer at (32, 9).
- **Psychic Phil's Kadabra level.** Walkthrough says Level 24; `data/trainers/parties.asm`
  PSYCHIC_T (8) says `db 26, KADABRA`. The Natu is L24 in both.
- **"Protein" in the Ice Path.** The walkthrough's final Ice Path paragraph says
  "Go up even more steps to get the Protein, then slide down at the very left to
  grab a PP Up." No `PROTEIN` appears in any of the five Ice Path map files, and
  the walkthrough's own item list for the Ice Path does not include it. The only
  vitamins in the Ice Path are `IRON` (B1F, (5, 35)) and the hidden `CARBOS`
  (B2F Mahogany Side, (0, 17)). Unresolved.
- **Ice Path item list omissions.** The asm additionally has `MAX_POTION` (item
  ball, B2F Mahogany Side (0, 2)), hidden `MAX_POTION` (B1F (15, 31)), hidden
  `CARBOS` (B2F Mahogany (0, 17)) and hidden `ICE_HEAL` (B2F Blackthorn (2, 10)).
- **Ice maze direction strings.** Every "right, down, right, down" style route in
  the walkthrough is a property of the `.blk` block layout and the ice-tile
  collision values, not of any table in the map asm. None of them were verified;
  a bot must derive them from `maps/IcePath*.blk` plus `CheckIceTile`
  (`engine/overworld/player_movement.asm:274`).
- **Boulder push counts.** Likewise, "move the bottom boulder right, then 6
  squares down..." for both the Ice Path B1F and Blackthorn Gym 2F puzzles is
  block-geometry, not script data. What *is* pinned down is the required
  destination warp for each boulder (see the two stone tables above); the paths
  between were not verified.
- **Dragon's Den whirlpool.** The walkthrough says "Make sure you have ... Surf
  and Waterfall". The Den needs SURF and **WHIRLPOOL**; there is no waterfall
  block on `MAP_DRAGONS_DEN_B1F` and Waterfall is not even usable until the badge
  this trip awards. The single whirlpool block (`$07` in `TILESET_JOHTO`) is at
  block (5, 10) of `maps/DragonsDenB1F.blk`; whether that is the only crossing
  the route needs was not verified beyond the block scan.
- **Clair's party order.** Walkthrough lists Dragonair, Dragonair, Kingdra,
  Dragonair. `ClairGroup` in `data/trainers/parties.asm:67` is Dragonair,
  Dragonair, Dragonair, Kingdra.
- **Fisher Edgar's Remoraid levels.** Walkthrough says two Level 25 Remoraid;
  the asm agrees, but note both carry `LOCK_ON / PSYBEAM / AURORA_BEAM /
  BUBBLEBEAM` rather than default moves.
- **"use the warps to return to the entrance".** The 1F <-> 2F warp pairs
  (1F 3/4 <-> 2F 1/2, 1F 5/6/7 <-> 2F 3/4/5) are transcribed above, but which
  combination the walkthrough means by "use the warps" is ambiguous.
- **Money rewards.** The G values in the walkthrough (832G, 1000G, 1200G, ...)
  come from `base money x level`, computed at runtime in
  `engine/battle/`; no static table was located, so none were verified.
- **Section numbering.** The file is `section-13-*` but its own heading reads
  `---- 19 > Ice Path and Blackthorn City Gym ----`. Assumed to be the FAQ's
  internal chapter number, not a different section.

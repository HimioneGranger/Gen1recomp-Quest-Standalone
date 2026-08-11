# Section 17 - Victory Road

Source: `../section-17-victory-road.txt` (the FAQ numbers this chapter "23 > Victory Road")
Maps covered: `MAP_VICTORY_ROAD`, `MAP_VICTORY_ROAD_GATE` (entry gate, badge check)
Badges / key milestones in this section: no badge. Milestones are the fifth and
final `RIVAL1` battle (`EVENT_RIVAL_VICTORY_ROAD`), TM26 Earthquake, and the
north exit onto Route 23 / Indigo Plateau.

Important structural fact the walkthrough hides: **Gold/Silver Victory Road is a
single 10x36-block map**, not three floors. What the FAQ calls "first / second /
third floor" are three vertically stacked regions of the same map joined by
`warp_event` rows whose destination map is `VICTORY_ROAD` itself. Every "ladder"
and the "hole" are self-warps inside `maps/VictoryRoad.asm`.

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 0 | `MAP_VICTORY_ROAD_GATE` | `maps/VictoryRoadGate.asm` | gate warps 3/4 at (9,17)/(10,17), arriving from Route 26 (`maps/Route26.asm:397` warps to `VICTORY_ROAD_GATE, 3`) | gate warps 5/6 at (9,0)/(10,0) -> `VICTORY_ROAD` warp 1 | 8-badge check at coord event (10,11); belongs to the previous section but is the only door in |
| 1 | `MAP_VICTORY_ROAD` (entrance region, y 48..71) | `maps/VictoryRoad.asm` | warp 1 at (9,67) | warp 2, the ladder at (1,49) | "Head up the stairway and up the cliff"; Full Heal (15,48) and Max Revive (12,48) sit here, plus the hidden Full Heal at (3,65) |
| 2 | `MAP_VICTORY_ROAD` (mid region, y 32..43) | same | warp 3 at (1,35) | warp 4, the ladder at (13,31) | "second floor" - X Special at (7,38), then "up along the path ... another ladder" |
| 3 | `MAP_VICTORY_ROAD` (top region, y 5..21) | same | warp 5 at (13,17) | warp 7, the ladder at (17,19) | "Save when you get to the third floor. Go up the cliff to your left, go down the ladder" |
| 4 | `MAP_VICTORY_ROAD` (Full Restore shelf, y 28..34) | same | warp 6 at (17,33) | one-way `HOP_DOWN` ledge row y=34, x=16..19, landing on y=36 | "grab the Full Restore, and jump down" |
| 5 | `MAP_VICTORY_ROAD` (mid region again) | same | ledge landing (x,36) | warp 4 at (13,31) | "Head back up the ladder to the third floor" |
| 6 | `MAP_VICTORY_ROAD` (top region) | same | warp 5 at (13,17) | coord events at (12,8) / (13,8) | rival ambush, `VictoryRoadRivalLeft` / `VictoryRoadRivalRight` |
| 7 | `MAP_VICTORY_ROAD` (TM pocket, y 26..30) | same | warp 8, the `COLL_PIT` at (0,11) | warp 8's landing is warp 9 at (0,27); leave by `HOP_RIGHT` at (8,28)->(10,28) or `HOP_DOWN` at (2,30)/(3,30)->y=32 | "go left instead of out the door, and fall down the hole to get TM26 Earthquake" |
| 8 | `MAP_VICTORY_ROAD` exit | same | corridor x=12..13 at y=7..8, x=11..14 at y=6 | warp 10 at (13,5) -> `ROUTE_23` warp 3 | leave the dungeon |
| 9 | `MAP_ROUTE_23` | `maps/Route23.asm` | warp 3 at (9,13) | - | **next section** (Indigo Plateau / Pokemon League). `Route23FlypointCallback` sets `ENGINE_FLYPOINT_INDIGO_PLATEAU` on arrival. Stop here. |

## 2. Maps

### MAP_VICTORY_ROAD

- Script: `maps/VictoryRoad.asm` (included from `data/maps/scripts.asm:24`)
- Blocks: `maps/VictoryRoad.blk` (360 bytes; `data/maps/blocks.asm:962`)
- Header: `data/maps/maps.asm:160`
  `map VictoryRoad, TILESET_CAVE, CAVE, LANDMARK_VICTORY_ROAD, MUSIC_VICTORY_ROAD, TRUE, PALETTE_NITE, FISHGROUP_SHORE`
  (per the `map` macro at the head of `data/maps/maps.asm`: tileset, environment,
  location, music, phone-service flag TRUE = phone calls suppressed, time-of-day
  palette, fishing group.)
- Attributes: `data/maps/attributes.asm:494` `map_attributes VictoryRoad, VICTORY_ROAD, $1d` - border block `$1d`, and **no `connection` rows follow**, so the map has no overworld connections.
- Dimensions: `constants/map_constants.asm:147` `map_const VICTORY_ROAD, 10, 36` -> 10x36 blocks = **20x72 walk cells**. Group `DUNGEONS` (group 3), map id 82.
- Scene variable: `data/maps/scenes.asm:60` `scene_var VICTORY_ROAD, wVictoryRoadSceneID` (sym `01:d6eb`)
- Callbacks: `def_callbacks` is empty - no `MAPCALLBACK_*` for this map.
- Connections: none.

**Warps** (`def_warp_events`, transcribed from `maps/VictoryRoad.asm:242-252`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 67 | `VICTORY_ROAD_GATE` | 5 |
| 2 | 1 | 49 | `VICTORY_ROAD` | 3 |
| 3 | 1 | 35 | `VICTORY_ROAD` | 2 |
| 4 | 13 | 31 | `VICTORY_ROAD` | 5 |
| 5 | 13 | 17 | `VICTORY_ROAD` | 4 |
| 6 | 17 | 33 | `VICTORY_ROAD` | 7 |
| 7 | 17 | 19 | `VICTORY_ROAD` | 6 |
| 8 | 0 | 11 | `VICTORY_ROAD` | 9 |
| 9 | 0 | 27 | `VICTORY_ROAD` | 8 |
| 10 | 13 | 5 | `ROUTE_23` | 3 |

Self-warp pairs, as a bot should read them: 2<->3, 4<->5, 6<->7, 8->9.
Warp 8's tile is `COLL_PIT` and warp 9's tile is plain `COLL_FLOOR`, so **warp 9
never fires**: the hole at (0,11) is one-way down to (0,27). (Tile kinds verified
below.)

**Coord events** (`def_coord_events`, `maps/VictoryRoad.asm:254-256`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_VICTORYROAD_RIVAL_BATTLE` (0) | 12 | 8 | `VictoryRoadRivalLeft` (sym `42:59ba`) | rival is teleported to (18,11), walks LEFTx6 + UPx2 to (12,9), battle, then leaves DOWNx2 + RIGHTx6 |
| `SCENE_VICTORYROAD_RIVAL_BATTLE` (0) | 13 | 8 | `VictoryRoadRivalRight` (sym `42:59dd`) | rival walks from (18,13) UPx2 + LEFTx5 + UPx2 to (13,9), battle, then leaves DOWNx2 + RIGHTx5 + DOWNx2 |

These two tiles are the entire width of the corridor that leads to the exit
(y=8 is walkable only at x=6,7 and x=12,13), so the ambush is unavoidable.

**BG events** (`def_bg_events`, `maps/VictoryRoad.asm:258-260`)

| x | y | type | script/item |
|---|---|---|---|
| 3 | 29 | `BGEVENT_ITEM` | `VictoryRoadHiddenMaxPotion` = `hiddenitem MAX_POTION, EVENT_VICTORY_ROAD_HIDDEN_MAX_POTION` |
| 3 | 65 | `BGEVENT_ITEM` | `VictoryRoadHiddenFullHeal` = `hiddenitem FULL_HEAL, EVENT_VICTORY_ROAD_HIDDEN_FULL_HEAL` |

Both target tiles are `COLL_WALL`, i.e. the player stands next to them and
presses A into the wall. (3,29) is faced from (2,29), (4,29) or (3,28);
(3,65) is faced from (2,65), (4,65), (3,64) or (3,66).

**Object events** (`def_object_events`, `maps/VictoryRoad.asm:262-268`)

Column order follows the `object_event` macro in `macros/scripts/maps.asm:113`:
x, y, sprite, movement, radius x, radius y, hour1, hour2, palette, type, sight,
script, event flag.

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VICTORYROAD_RIVAL` | `SPRITE_RIVAL` | 18 | 13 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` (shared ROM0 stub, sym `00:2812`) | `EVENT_RIVAL_VICTORY_ROAD` |
| `VICTORYROAD_POKE_BALL1` | `SPRITE_POKE_BALL` | 3 | 28 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `VictoryRoadTMEarthquake` = `itemball TM_EARTHQUAKE` | `EVENT_VICTORY_ROAD_TM_EARTHQUAKE` |
| `VICTORYROAD_POKE_BALL2` | `SPRITE_POKE_BALL` | 12 | 48 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `VictoryRoadMaxRevive` = `itemball MAX_REVIVE` | `EVENT_VICTORY_ROAD_MAX_REVIVE` |
| `VICTORYROAD_POKE_BALL3` | `SPRITE_POKE_BALL` | 18 | 29 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `VictoryRoadFullRestore` = `itemball FULL_RESTORE` | `EVENT_VICTORY_ROAD_FULL_RESTORE` |
| `VICTORYROAD_POKE_BALL4` | `SPRITE_POKE_BALL` | 15 | 48 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `VictoryRoadFullHeal` = `itemball FULL_HEAL` | `EVENT_VICTORY_ROAD_FULL_HEAL` |
| `VICTORYROAD_POKE_BALL5` | `SPRITE_POKE_BALL` | 7 | 38 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `VictoryRoadXSpecial` = `itemball X_SPECIAL` | `EVENT_VICTORY_ROAD_X_SPECIAL` |

All rows use radius 0,0, hours -1,-1 (always present), palette 0, sight 0.

Object-flag polarity (this bites bot authors): `CheckObjectFlag` in
`engine/overworld/map_objects_2.asm:32` masks an object when its event flag is
**set**, and shows it when the flag is clear or is `-1`. `Script_appear` clears
the flag, `Script_disappear` sets it (`engine/overworld/scripting.asm:879-897`).
`InitializeEventsScript` in `engine/events/std_scripts.asm:521` sets
`EVENT_RIVAL_VICTORY_ROAD` at new game, so the rival object starts hidden and is
only revealed by the `appear` inside the ambush script.

**Derived collision map** (not verbatim asm - built by decoding
`maps/VictoryRoad.blk` through `data/tilesets/cave_collision.asm` and
`data/collision/collision_permissions.asm`, with the quadrant index
`(x & 1) + 2 * (y & 1)` taken from `GetCoordTileCollision` in
`home/map.asm:2065`). It is included because Victory Road is the one map in this
section where "which tile can I stand on" is the whole problem.

Verification: all ten `warp_event` tiles land on the expected collision
(`WARP_CARPET_DOWN`, six `LADDER`, `PIT`, `FLOOR`, `CAVE`) and all six
`object_event` tiles land on walkable tiles, so the decode is aligned.

Legend: `.` floor, `#` wall (impassable), `^` `COLL_UP_WALL` (walkable, but you
cannot step *down* into it and cannot step *up* off it), `L` ladder, `P` pit,
`C` cave exit, `W` warp carpet (needs a DOWN press), `<` `HOP_LEFT`,
`>` `HOP_RIGHT`, `v` `HOP_DOWN` (all three are walkable land; pressing the
matching direction while standing on one jumps two tiles - see `.TryJump` and
`.ledge_table` in `engine/overworld/player_movement.asm:354-391`, which reads the
tile the player is **standing on**, not the tile ahead).

```
    01234567890123456789
  0 ....................
  1 ....................
  2 ....................
  3 ....................
  4 ....................
  5 #############C######
  6 ###########....#####
  7 ############..######
  8 ######..####..######
  9 #####....##....#####
 10 ......##...........#
 11 P....####...........
 12 ...######^^^^^^^^#..
 13 #########........#..
 14 #^^^^^^##........#..
 15 #......##..#####.#..
 16 #......##..#........
 17 ###.#..##..#.L..####
 18 #...#......#####..##
 19 #...##########...L##
 20 ##......>#.......###
 21 ###.....>#.....#####
 22 ####################
 23 ####################
 24 ####################
 25 ####################
 26 #...################
 27 .......#############
 28 ........>#...#######
 29 ...#....>#....####.#
 30 ##vv..#####...####..
 31 ###########..L###...
 32 ##..########..##....
 33 ....########..##.L..
 34 ..#^^^^^^^^#...#vvvv
 35 .L#........#...#####
 36 ..#........#........
 37 ..###.###..##.......
 38 ......#<#...^^^^^#..
 39 #..#..#<#........#..
 40 ##....#<#........#..
 41 ####..#<#####.####..
 42 #######.............
 43 ##########........##
 44 ####################
 45 ####################
 46 ####################
 47 ####################
 48 ....########.##..###
 49 .L..########.###..##
 50 #.....####........##
 51 #......#####..#....#
 52 #...#^^^^^^^^^^^^#..
 53 #...#............#..
 54 ##..#............#..
 55 ##..###.###..##.##..
 56 ##........#..##.....
 57 ##........#..##....#
 58 ##.##^^####..#######
 59 ##..#..####..#######
 60 ##vv#...^^...#######
 61 #####........#######
 62 ##..#........######^
 63 ##..###.###########.
 64 #....#..##.....####.
 65 #..#....#......####.
 66 ##............###^..
 67 ######...W##.####...
 68 #######^^#^^^^^^....
 69 #######.............
 70 ^^^^^^..............
 71 ....................
```

One-way transitions a bot must respect (all derived from the grid above):

- (0,11) `PIT` -> (0,27). No route back up from (0,27); the return is a ledge.
- (8,28) or (8,29) `HOP_RIGHT` + RIGHT -> (10,28) / (10,29), which reaches the (13,31) ladder. This is the short way out of the TM pocket.
- (2,30) or (3,30) `HOP_DOWN` + DOWN -> (2,32) / (3,32), which drops into the pocket that holds the (1,35) ladder. This is the long way out of the TM pocket.
- (16..19, 34) `HOP_DOWN` + DOWN -> (16..19, 36). This is the only exit from the Full Restore shelf, and it is why the FAQ says "jump down".
- (8,20) or (8,21) `HOP_RIGHT` + RIGHT -> (10,20) / (10,21) in the top region.
- Rows of `^` (`COLL_UP_WALL`) are walkable dead strips: you may enter them from the side or from below and leave sideways or downward, never upward, and you can never step down onto one.

**Scripts of interest**

- `VictoryRoadRivalLeft` (`maps/VictoryRoad.asm:22`, sym `42:59ba`)
  `moveobject VICTORYROAD_RIVAL, 18, 11` / `turnobject PLAYER, DOWN` /
  `showemote EMOTE_SHOCK, PLAYER, 15` / `special FadeOutMusic` / `pause 15` /
  `appear VICTORYROAD_RIVAL` / `applymovement` `VictoryRoadRivalBattleApproachMovement1`
  (LEFT x6, UP x2) / `scall VictoryRoadRivalNext` /
  `applymovement VictoryRoadRivalBattleExitMovement1` (DOWN x2, RIGHT x6) /
  `disappear VICTORYROAD_RIVAL` / `setscene SCENE_VICTORYROAD_NOOP` /
  `playmapmusic` / `end`.
- `VictoryRoadRivalRight` (`maps/VictoryRoad.asm:37`, sym `42:59dd`) - identical
  except there is no `moveobject` (he starts at his object_event position 18,13),
  the approach is `VictoryRoadRivalBattleApproachMovement2` (UP x2, LEFT x5,
  UP x2) and the exit is `VictoryRoadRivalBattleExitMovement2` (DOWN x2,
  RIGHT x5, DOWN x2).
- `VictoryRoadRivalNext` (`maps/VictoryRoad.asm:51`, sym `42:59fc`) - the shared
  body. `turnobject PLAYER, DOWN`, `playmusic MUSIC_RIVAL_ENCOUNTER`, text
  `VictoryRoadRivalBeforeText`, then `setevent EVENT_RIVAL_VICTORY_ROAD`
  (**before** the battle, so a reset or blackout mid-battle still leaves the
  object hidden), then a three-way starter branch:
  - `checkevent EVENT_GOT_TOTODILE_FROM_ELM` -> `.GotTotodile` -> `loadtrainer RIVAL1, RIVAL1_5_CHIKORITA`
  - `checkevent EVENT_GOT_CHIKORITA_FROM_ELM` -> `.GotChikorita` -> `loadtrainer RIVAL1, RIVAL1_5_CYNDAQUIL`
  - fall-through (player picked Cyndaquil) -> `loadtrainer RIVAL1, RIVAL1_5_TOTODILE`

  Each arm runs `winlosstext VictoryRoadRivalDefeatText, VictoryRoadRivalVictoryText`,
  `setlasttalked VICTORYROAD_RIVAL`, `startbattle`, `dontrestartmapmusic`,
  `reloadmapafterbattle`, then `.AfterBattle`: `playmusic MUSIC_RIVAL_AFTER` and
  `VictoryRoadRivalAfterText`.
- `VictoryRoadTMEarthquake` / `MaxRevive` / `FullRestore` / `FullHeal` /
  `XSpecial` (`maps/VictoryRoad.asm:97-110`) - each is a bare
  `itemball <ITEM>` (two bytes: item, quantity 1; `macros/scripts/maps.asm:155`),
  not bytecode. Do not try to disassemble them.
- `VictoryRoadHiddenMaxPotion` / `VictoryRoadHiddenFullHeal`
  (`maps/VictoryRoad.asm:112-116`) - `hiddenitem item, flag`, three bytes laid
  down as `dwb flag, item` (`macros/scripts/maps.asm:165`).

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_RIVAL_VICTORY_ROAD` | `constants/event_flags.asm:1124` | set by `InitializeEventsScript` (`engine/events/std_scripts.asm:521`) and again by `VictoryRoadRivalNext`; cleared by the `appear` in the ambush scripts | set = rival object masked. Postcondition of the ambush. |
| `EVENT_VICTORY_ROAD_TM_EARTHQUAKE` | `constants/event_flags.asm:1092` | itemball object flag | set once TM26 is taken |
| `EVENT_VICTORY_ROAD_MAX_REVIVE` | `constants/event_flags.asm:1093` | itemball object flag | set once Max Revive is taken |
| `EVENT_VICTORY_ROAD_FULL_RESTORE` | `constants/event_flags.asm:1094` | itemball object flag | set once Full Restore is taken |
| `EVENT_VICTORY_ROAD_FULL_HEAL` | `constants/event_flags.asm:1095` | itemball object flag | set once Full Heal is taken |
| `EVENT_VICTORY_ROAD_X_SPECIAL` | `constants/event_flags.asm:1096` | itemball object flag | set once X Special is taken |
| `EVENT_VICTORY_ROAD_HIDDEN_MAX_POTION` | `constants/event_flags.asm:168` | `hiddenitem` operand at bg (3,29) | set once dug up |
| `EVENT_VICTORY_ROAD_HIDDEN_FULL_HEAL` | `constants/event_flags.asm:169` | `hiddenitem` operand at bg (3,65) | set once dug up |
| `EVENT_GOT_TOTODILE_FROM_ELM` (`:37`), `EVENT_GOT_CHIKORITA_FROM_ELM` (`:38`) | `constants/event_flags.asm` | read by `VictoryRoadRivalNext` | selects which of the three rival parties loads. `EVENT_GOT_CYNDAQUIL_FROM_ELM` (`:36`) is never read here; Cyndaquil is the fall-through case |
| `SCENE_VICTORYROAD_RIVAL_BATTLE` = 0 | defined inline by the `scene_script` macro (`macros/scripts/maps.asm:25`, `const_def` starting at 0) via `maps/VictoryRoad.asm:11` | compared by both coord events | the scene the map starts a new game on |
| `SCENE_VICTORYROAD_NOOP` = 1 | same, `maps/VictoryRoad.asm:12` | written by `setscene` at the end of both ambush scripts | rival ambush disarmed |

Both scene scripts (`VictoryRoadNoop1Scene`, `VictoryRoadNoop2Scene`) are a bare
`end`; the scene id only gates the coord events.

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `TM_EARTHQUAKE` (TM26 - counted off the `add_tm` list in `constants/item_constants.asm:218-246`) | Poke Ball at (3,28), only reachable through the pit at (0,11) | `VictoryRoadTMEarthquake` | `EVENT_VICTORY_ROAD_TM_EARTHQUAKE` |
| `MAX_REVIVE` | Poke Ball at (12,48) | `VictoryRoadMaxRevive` | `EVENT_VICTORY_ROAD_MAX_REVIVE` |
| `FULL_RESTORE` | Poke Ball at (18,29), reached by ladder warp 7 -> (17,33) then north | `VictoryRoadFullRestore` | `EVENT_VICTORY_ROAD_FULL_RESTORE` |
| `FULL_HEAL` | Poke Ball at (15,48) | `VictoryRoadFullHeal` | `EVENT_VICTORY_ROAD_FULL_HEAL` |
| `X_SPECIAL` | Poke Ball at (7,38), standing on the `HOP_LEFT` column; walk north from (7,42) | `VictoryRoadXSpecial` | `EVENT_VICTORY_ROAD_X_SPECIAL` |
| `MAX_POTION` | hidden, face the wall at (3,29) | `bg_event 3, 29, BGEVENT_ITEM` | `EVENT_VICTORY_ROAD_HIDDEN_MAX_POTION` |
| `FULL_HEAL` (second one) | hidden, face the wall at (3,65) | `bg_event 3, 65, BGEVENT_ITEM` | `EVENT_VICTORY_ROAD_HIDDEN_FULL_HEAL` |

**Trainers**

There are no `OBJECTTYPE_TRAINER` objects on this map. The single battle is a
scripted `loadtrainer` with no `EVENT_BEAT_*` flag of its own.

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `RIVAL1_5_CHIKORITA` | `RIVAL1` (trainer class 9, `constants/trainer_constants.asm:51`) | 13th member of the class | `Rival1Group` "RIVAL1 (13)" (`data/trainers/parties.asm:164`, sym `0e:5a92` for the group) | `VictoryRoadRivalNext.GotTotodile` (sym `42:5a27`) | none |
| `RIVAL1_5_CYNDAQUIL` | `RIVAL1` | 14th | `Rival1Group` "RIVAL1 (14)" (`data/trainers/parties.asm:174`) | `VictoryRoadRivalNext.GotChikorita` (sym `42:5a37`) | none |
| `RIVAL1_5_TOTODILE` | `RIVAL1` | 15th | `Rival1Group` "RIVAL1 (15)" (`data/trainers/parties.asm:184`) | fall-through arm of `VictoryRoadRivalNext` | none |

Parties, verbatim (`TRAINERTYPE_MOVES`, name string `"?@"`):

RIVAL1 (13) - loaded when the player chose Totodile:

```
db 34, SNEASEL,    QUICK_ATTACK, SCREECH, FAINT_ATTACK, FURY_CUTTER
db 36, GOLBAT,     LEECH_LIFE, BITE, CONFUSE_RAY, WING_ATTACK
db 35, MAGNETON,   THUNDERSHOCK, SONICBOOM, THUNDER_WAVE, SWIFT
db 35, HAUNTER,    MEAN_LOOK, CURSE, SHADOW_BALL, CONFUSE_RAY
db 35, KADABRA,    DISABLE, PSYBEAM, RECOVER, FUTURE_SIGHT
db 38, MEGANIUM,   REFLECT, RAZOR_LEAF, POISONPOWDER, BODY_SLAM
```

RIVAL1 (14) - loaded when the player chose Chikorita:

```
db 34, SNEASEL,    QUICK_ATTACK, SCREECH, FAINT_ATTACK, FURY_CUTTER
db 36, GOLBAT,     LEECH_LIFE, BITE, CONFUSE_RAY, WING_ATTACK
db 35, MAGNETON,   THUNDERSHOCK, SONICBOOM, THUNDER_WAVE, SWIFT
db 35, HAUNTER,    MEAN_LOOK, CURSE, SHADOW_BALL, CONFUSE_RAY
db 35, KADABRA,    DISABLE, PSYBEAM, RECOVER, FUTURE_SIGHT
db 38, TYPHLOSION, SMOKESCREEN, EMBER, QUICK_ATTACK, FLAME_WHEEL
```

RIVAL1 (15) - loaded when the player chose Cyndaquil:

```
db 34, SNEASEL,    QUICK_ATTACK, SCREECH, FAINT_ATTACK, FURY_CUTTER
db 36, GOLBAT,     LEECH_LIFE, BITE, CONFUSE_RAY, WING_ATTACK
db 34, MAGNETON,   THUNDERSHOCK, SONICBOOM, THUNDER_WAVE, SWIFT
db 35, HAUNTER,    MEAN_LOOK, CURSE, SHADOW_BALL, CONFUSE_RAY
db 35, KADABRA,    DISABLE, PSYBEAM, RECOVER, FUTURE_SIGHT
db 38, FERALIGATR, RAGE, WATER_GUN, SCARY_FACE, SLASH
```

Note the send-out order: Sneasel, Golbat, Magneton, Haunter, Kadabra, starter.
The FAQ lists the starter fourth; the asm puts it last.

**Wild encounters**

`data/wild/kanto_grass.asm:144` `def_grass_wildmons VICTORY_ROAD` (Victory Road
lives in the Kanto grass table even though it is Johto-side).

Encounter rates: `db 6 percent, 6 percent, 6 percent` (morn / day / nite - all
equal). Slot weights come from `GrassMonProbTable`
(`data/wild/probabilities.asm:6`): 30 / 30 / 20 / 10 / 5 / 4 / 1 percent.

Gold (`IF DEF(_GOLD)`), identical for morn, day and nite:

| slot | % | level | species |
|---|---|---|---|
| 1 | 30 | 32 | `GRAVELER` |
| 2 | 30 | 32 | `GOLBAT` |
| 3 | 20 | 33 | `URSARING` |
| 4 | 10 | 34 | `ONIX` |
| 5 | 5 | 36 | `ONIX` |
| 6 | 4 | 35 | `RHYHORN` |
| 7 | 1 | 35 | `RHYHORN` |

Silver (`ELIF DEF(_SILVER)`) is the same table with slot 3 replaced by
`db 33, DONPHAN`.

No water, fishing, headbutt or rock-smash data: there is no `VICTORY_ROAD` row in
`data/wild/kanto_water.asm`, `data/wild/johto_water.asm`, `data/wild/fish.asm` or
`data/wild/treemons.asm`, and the decoded collision map contains no water tiles.
The `FISHGROUP_SHORE` in the header is therefore unreachable. No roamer either
(`VICTORY_ROAD` is absent from `data/wild/roammon_maps.asm`).

### MAP_VICTORY_ROAD_GATE

Included here because it is the only entrance and it carries the badge gate. The
NPC beats themselves belong to the previous / later sections.

- Script: `maps/VictoryRoadGate.asm` (`data/maps/scripts.asm:452`)
- Blocks: `maps/VictoryRoadGate.blk` (`data/maps/blocks.asm:943`)
- Header: `data/maps/maps.asm:467`
  `map VictoryRoadGate, TILESET_GATE, GATE, LANDMARK_ROUTE_26, MUSIC_INDIGO_PLATEAU, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Attributes: `data/maps/attributes.asm:666`, border block `$00`, no connections.
- Dimensions: `constants/map_constants.asm:433` `map_const VICTORY_ROAD_GATE, 10, 9` -> 20x18 cells. Group `VIRIDIAN` (group 23), map id 13.
- Scene variable: `data/maps/scenes.asm:16` `scene_var VICTORY_ROAD_GATE, wVictoryRoadGateSceneID` (sym `01:d6bf`)

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

Cross-checked from the other side: `maps/Route22.asm:20` warps to
`VICTORY_ROAD_GATE, 1`, `maps/Route26.asm:397` warps to `VICTORY_ROAD_GATE, 3`,
`maps/Route28.asm:21` warps to `VICTORY_ROAD_GATE, 7`.

**Coord events**

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_VICTORYROADGATE_BADGE_CHECK` (0) | 10 | 11 | `VictoryRoadGateBadgeCheckScript` (sym `5f:4fdc`) | turns the player LEFT and falls into `_VictoryRoadGateBadgeCheckScript` |

**BG events**: none.

**Object events** (`maps/VictoryRoadGate.asm:116-119`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VICTORYROADGATE_OFFICER` | `SPRITE_OFFICER` | 8 | 11 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `VictoryRoadGateOfficerScript` | `-1` (always present) |
| `VICTORYROADGATE_BLACK_BELT1` | `SPRITE_BLACK_BELT` | 7 | 5 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `VictoryRoadGateLeftBlackBeltScript` | `EVENT_OPENED_MT_SILVER` |
| `VICTORYROADGATE_BLACK_BELT2` | `SPRITE_BLACK_BELT` | 12 | 5 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `VictoryRoadGateRightBlackBeltScript` | `EVENT_FOUGHT_SNORLAX` |

**Derived collision map** (same method, `data/tilesets/gate_collision.asm`;
`c` = `COLL_COUNTER`, a wall):

```
    01234567890123456789
  0 #########DD#########
  1 ########....########
  2 ########....########
  3 ########....########
  4 ########....########
  5 ....................
  6 ....####....####....
  7 .WW.####....####.WW.
  8 ########....########
  9 ########....########
 10 ########cc..########
 11 ########.c.c########
 12 ########.c..########
 13 ########cc..########
 14 ########....########
 15 ########....########
 16 ########....########
 17 ########.WW.########
```

Row 11 is walkable only at x=8 (where the officer stands) and x=10, so
**(10,11) is a mandatory chokepoint**: the badge check cannot be walked around.

**Scripts of interest**

- `_VictoryRoadGateBadgeCheckScript` (`maps/VictoryRoadGate.asm:25`, sym `5f:4fe3`):
  `writetext VictoryRoadGateOfficerText`, `promptbutton`, `readvar VAR_BADGES`,
  `ifgreater NUM_JOHTO_BADGES - 1, .AllEightBadges`. On failure it prints
  `VictoryRoadGateNotEnoughBadgesText` and `applymovement PLAYER,
  VictoryRoadGateStepDownMovement` (one `step DOWN`, pushing the player back
  south). On success it prints `VictoryRoadGateEightBadgesText` and
  `setscene SCENE_VICTORYROADGATE_NOOP`, permanently disarming the coord event.
- `VictoryRoadGateOfficerScript` (`maps/VictoryRoadGate.asm:23`) - `faceplayer`
  then the same body, so talking to the officer also opens the gate.

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Entry to Victory Road | `maps/VictoryRoadGate.asm:19` `VictoryRoadGateBadgeCheckScript` / `_VictoryRoadGateBadgeCheckScript` | `readvar VAR_BADGES` then `ifgreater NUM_JOHTO_BADGES - 1` (that is, badge count must be >= 8). `NUM_JOHTO_BADGES` = 8 (`constants/ram_constants.asm:260`). `VAR_BADGES` resolves to `.CountBadges` in `engine/overworld/variables.asm:80`, which is `CountSetBits` over **two** bytes (`wBadges`, b = 2), i.e. Johto **and** Kanto badges together | own all eight Johto badges. The script then sets `SCENE_VICTORYROADGATE_NOOP`, so the check runs at most once |
| Physical block west to Route 28 | `maps/VictoryRoadGate.asm:118` object `VICTORYROADGATE_BLACK_BELT1` at (7,5), masked when `EVENT_OPENED_MT_SILVER` is set | row 5 is the only east-west corridor in the gate and he stands in it | out of scope here (Mt. Silver, later section) |
| Physical block east to Route 22 | `maps/VictoryRoadGate.asm:119` object `VICTORYROADGATE_BLACK_BELT2` at (12,5), masked when `EVENT_FOUGHT_SNORLAX` is set | same corridor | out of scope here (Kanto, later section) |
| Rival ambush before the exit | `maps/VictoryRoad.asm:255-256` coord events at (12,8) and (13,8), gated on `SCENE_VICTORYROAD_RIVAL_BATTLE` | those two tiles are the whole corridor to the exit at (13,5) | win the battle; the script then runs `setscene SCENE_VICTORYROAD_NOOP` |
| TM26 Earthquake | geometry only, no flag: (3,28) is inside the y=26..30 pocket whose only entrance is the `COLL_PIT` at (0,11) | reach the top region first (so: beat the ladders, not the rival) | none |
| Full Restore | geometry only: (18,29) is on a shelf whose only entrance is warp 7 (17,19) -> (17,33) | reach the top region | none |

Field moves: **none required**. There is no `COLL_CUT_TREE`, no water, no
strength boulder and no whirlpool anywhere in the decoded map, and the header
palette is `PALETTE_NITE`, not `PALETTE_DARK`, so **Flash is not needed** either.
The FAQ's "no puzzles to solve now" is accurate.

## 4. Bot checklist

Coordinates are map cells `(x, y)` on the named map. "step" means walk onto the
tile; ladders and the pit fire on arrival (`Permissions.isImmediateWarp`
equivalent: `COLL_LADDER` = `$72` and `COLL_PIT` = `$60` are warp collisions),
while the entrance carpet at (9,67) fires on a DOWN press.

1. `MAP_VICTORY_ROAD_GATE`: from the Route 26 door at (9,17)/(10,17) walk north along x=10. Precondition: 8 Johto badges. Step (10,11) -> `VictoryRoadGateBadgeCheckScript` fires. Postcondition: `wVictoryRoadGateSceneID` = `SCENE_VICTORYROADGATE_NOOP`. If badges < 8 the script pushes you one step DOWN and you cannot pass.
2. `MAP_VICTORY_ROAD_GATE`: step (9,0) or (10,0) -> warp to `MAP_VICTORY_ROAD` (9,67).
3. `MAP_VICTORY_ROAD` entrance region. Waypoints that were checked against the
   collision map: (9,66) -> west along y=66 to (7,66) -> north x=7 through
   y=65,64 to (7,63) -> (7,62) -> east along y=62 to (11,62)/(12,62) -> north
   x=11/12 through y=61..55 -> (11,54) -> the long y=53/54 corridor (x=5..16).
4. Max Revive and Full Heal: from the y=53/54 corridor go east to (15,54) ->
   (15,55) -> (15,56) -> east along y=56 to (18,56) -> north along x=18 through
   y=55,54,53,52 to (18,51) -> west along y=51 to (15,51) -> (15,50) -> (16,50)
   -> (16,49) -> (16,48), press A facing LEFT
   into (15,48) -> Full Heal (`EVENT_VICTORY_ROAD_FULL_HEAL`). Then west along
   y=50 to (12,50) -> (12,49) -> press A facing UP into (12,48) -> Max Revive
   (`EVENT_VICTORY_ROAD_MAX_REVIVE`).
5. Optional hidden Full Heal: face the wall at (3,65) from (2,65), (4,65),
   (3,64) or (3,66) and press A. Postcondition
   `EVENT_VICTORY_ROAD_HIDDEN_FULL_HEAL`.
6. Back along the y=53/54 corridor to its west end, (3,53) -> (2,52) -> (2,51)
   -> (2,50) -> (1,49); the ladder fires on arrival -> warp 2 -> (1,35).
7. X Special. Verified chain from the ladder landing: (1,35) -> (1,36) -> (1,37)
   -> (1,38) -> east along y=38 to (5,38) -> (5,37) -> (5,36) -> east along y=36
   to (9,36)/(10,36) -> (9,37)/(10,37) -> (9,38)/(10,38) -> south through
   y=39,40 (x=9..16 is open) -> (13,41) -> (13,42) -> west along y=42 to (7,42)
   -> north along x=7 (the `HOP_LEFT` column is walkable) through y=41,40,39 to
   (7,38). Press A -> X Special. Postcondition `EVENT_VICTORY_ROAD_X_SPECIAL`.
   Do **not** press LEFT while on that column (it triggers a two-tile jump into
   a wall column).
8. To the (13,31) ladder: back to (7,42) -> east along y=42 to (18,42) -> north
   along x=18 through y=41,40,39,38 to (18,37) -> west along y=37 then y=36 to
   (13,36) -> north (13,35), (13,34), (13,33), (13,32) -> step (13,31) -> warp 4
   -> arrive (13,17). Note you cannot climb x=13 straight up from y=41: (13,38)
   is `COLL_UP_WALL` and blocks the step up out of it, and the x=11 column walls
   off the y=34..36 strip on its west side.
9. Optional Full Restore detour. The verified chain from the ladder to (17,19) is:
   (13,17) -> (13,16) -> east along y=16 to (16,16) -> (16,15) -> (16,14) ->
   west along y=14 to (9,14)/(10,14) -> south x=9/10 through y=15,16,17 to
   (9,18)/(10,18) -> west along y=18 to (5,18) -> (5,17) -> (5,16) -> west along
   y=16 to (3,16) -> (3,17) -> (3,18) -> (3,19) -> (3,20) -> east along y=20 to
   (8,20) -> **press RIGHT to hop the ledge**, landing (10,20) -> east/north to
   (16,19) -> (17,19). On the cart that `HOP_RIGHT` is the only way into the
   (17,19) pocket. Step (17,19) -> warp 7 -> arrive (17,33). Walk north along
   x=17..19 to (18,29), press A -> Full Restore. Postcondition
   `EVENT_VICTORY_ROAD_FULL_RESTORE`. Return to y=34 (x=16..19) and press DOWN to
   hop the ledge, landing on y=36 - which is already the y=36 corridor, so go
   west to (13,36) and north to (13,31), warp 4, back to (13,17).
10. From (13,17): (13,16) -> east along y=16 to (18,16) -> north along x=18
    through (18,15), (18,14), (18,13) (the rival's masked object tile), (18,12)
    to (18,11) -> west along y=11 to (13,11) -> north (13,10), (13,9) to (13,8).
11. Step (12,8) or (13,8) -> rival ambush. Precondition `wVictoryRoadSceneID` = 0. Battle `RIVAL1` member 13/14/15 depending on the starter events. Postconditions: `EVENT_RIVAL_VICTORY_ROAD` set, `wVictoryRoadSceneID` = `SCENE_VICTORYROAD_NOOP`.
12. TM26 detour. The x=6,7 wall pair on y=10 and the x=5..8 wall run on y=11 mean
    you cannot walk straight west; the verified chain is (9,11) -> (9,10) ->
    (8,10) -> (8,9) -> west along y=9 to (5,9) -> (5,10) -> west along y=10 to
    (0,10) -> (0,11), the `COLL_PIT`, which fires on arrival -> land at (0,27).
    Then (0,28) -> east along y=28 to (2,28), press A facing RIGHT into the ball
    object at (3,28) -> TM26 Earthquake (`EVENT_VICTORY_ROAD_TM_EARTHQUAKE`).
    Optionally step to (2,29) and press A facing RIGHT into the wall at (3,29)
    -> hidden Max Potion (`EVENT_VICTORY_ROAD_HIDDEN_MAX_POTION`).
13. Leave the pocket: east along y=28 to (7,28) -> step onto (8,28), the
    `HOP_RIGHT` tile -> press RIGHT to hop to (10,28) -> (10,29) -> east to
    (12,29) -> (12,30) -> (12,31) -> step (13,31) -> warp 4 -> (13,17).
    (Alternative, longer: stand on (2,30) or (3,30) and press DOWN, landing at
    y=32, which drops you back in the (1,35) ladder pocket and forces a full
    re-cross of the middle region via steps 7 and 8.)
14. Repeat step 10 to return to the exit corridor. The coord events no longer fire.
15. Walk (13,7) -> (13,6) -> step (13,5) (`COLL_CAVE`) -> warp 10 -> `MAP_ROUTE_23` (9,13). End of section.

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map header, dimensions, warps, coord events, bg events, object events for any Gold map | `src/import/RomExtractorGen2.lua` (map event reader at lines 785-865, `extractMaps` from 866) | implemented - data driven off the ROM, so `VICTORY_ROAD` needs no hand port |
| `OBJECTTYPE_ITEMBALL` item data extraction | `src/import/RomExtractorGen2.lua:2968` (`obj.itemball = readItemBall(...)`) | implemented (extraction only) |
| **Picking up a Poke Ball object** (all five Victory Road items) | `src/world/gen2/World.lua:5257` `World:interact` | **missing** - the A-press path handles trainers, strength boulders, `scriptKey` NPCs, `BGEVENT_READ` signs, `BGEVENT_ITEM` hidden items and the tile-collision field moves. Nothing consumes `obj.itemball`, and an itemball object has no `scriptKey`, so the press falls through |
| Hidden items (`BGEVENT_ITEM`, the two here) | `src/world/gen2/HiddenItems.lua`, used at `src/world/gen2/World.lua:5290` | implemented |
| Ladder / cave / pit warps | `src/world/gen2/Permissions.lua:162` `isWarpCollision` (covers `$60` PIT and the `$7x` block) and `isImmediateWarp` | implemented - the (0,11) hole and all six ladders work |
| Warp carpet needing a direction press (the (9,67) entrance) | `src/world/gen2/Permissions.lua:170` `CARPET_DIR` | implemented |
| Walkability from `CollisionPermissionTable` | `src/world/gen2/Permissions.lua:11` (256-entry table), `src/world/gen2/Map.lua:59` | implemented |
| **Ledge hops** (`COLL_HOP_LEFT/RIGHT/DOWN`, five of them in this map) | - | **missing** - no `$a0..$a7` handling anywhere under `src/world/gen2/`. The tiles are LAND in the port's permission table, so a bot can walk over them freely. Net effect: the one-way ledges become two-way, and the Full Restore shelf / TM pocket exits behave differently from the cart |
| **Directional side walls** (`COLL_UP_WALL`, heavily used here) | `src/world/gen2/FieldMoves.lua:313` `BLOCKED_BY` | partial - the `$b0..$b7` table exists but is only consulted by `FieldMoves.directionBlocked` for surf/field-move refusals. There is no port equivalent of `GetMovementPermissions` (`home/map.asm:1868`), so `UP_WALL` does not restrict ordinary walking |
| Coord events gated on the map scene | `src/world/gen2/World.lua:5007` `World:tryCoordScript`, scene storage at `World.lua:740` / `World:scene` at 1161 | implemented |
| Scene scripts / `setscene` persistence across save | `src/world/gen2/World.lua:558-584`, `src/core/gen2/Save.lua` | implemented |
| Rival ambush opcodes (`moveobject`, `turnobject`, `showemote`, `appear`, `disappear`, `applymovement`, `scall`, `setscene`, `playmapmusic`, `playmusic`, `winlosstext`, `setlasttalked`, `loadtrainer`, `startbattle`, `dontrestartmapmusic`, `reloadmapafterbattle`) | `src/script/gen2/Opcodes.lua` (table), `src/script/gen2/Vm.lua` (`moveobject` 337, `showemote` 961, `loadtrainer` 806, `winlosstext` 918, `reloadmapafterbattle` 886) | implemented |
| `special FadeOutMusic` | `src/script/gen2/Specials.lua:1066` | implemented |
| `VAR_BADGES` (the gate check) | `src/world/gen2/World.lua:1240` - counts `player.badges` + `player.kantoBadges`, matching `CountSetBits` over two bytes | implemented |
| Object masking by event flag | `src/import/RomExtractorGen2.lua` object `eventFlag` field; `src/world/gen2/Npc.lua` | partial - the flag is extracted, but confirm the mask polarity (hidden when **set**) matches `CheckObjectFlag`; not verified in this pass |
| Wild encounters for this map | `src/import/RomExtractorGen2.lua:3720` (`JohtoGrassWildMons` / `KantoGrassWildMons`), `src/battle/gen2/Encounter.lua` | implemented |
| Battle music landmark split | `src/battle/gen2/BattleMusic.lua:45-56` explicitly names the Victory Road landmark boundary | implemented |
| A driver that walks Victory Road | - | **missing** - no `tests/drivers/gold_*.lua` mentions Victory Road |

## 6. Unresolved / verify by hand

- **Rival Magneton level.** The FAQ says "Level 34 Magneton". The asm has 35 in
  RIVAL1 (13) and RIVAL1 (14) and 34 only in RIVAL1 (15), the Feraligatr set
  loaded when the player picked Cyndaquil. The FAQ appears to have been written
  from one playthrough.
- **Rival party order.** The FAQ lists the starter evolution fourth. The asm
  order is Sneasel, Golbat, Magneton, Haunter, Kadabra, starter (starter last).
- **"You get: 2280G"** and the per-mon EXP figures were not verified; base money
  for the `RIVAL1` class lives in the trainer class attribute table, which was
  not opened for this pass.
- **Wild list.** The FAQ lists only Golbat, Graveler, Rhyhorn and "Donphan
  (Silver only)". The asm table also carries Onix (two slots, L34 and L36) and,
  in Gold, Ursaring at L33 in the slot Silver gives to Donphan.
- **Item list.** The FAQ's item list omits the hidden Max Potion at (3,29) and
  does not distinguish the itemball Full Heal at (15,48) from the hidden Full
  Heal at (3,65).
- **"Head up the stairway"** - there is no `COLL_STAIRCASE` in the decoded
  Victory Road map. What the FAQ calls stairways and cliffs are ordinary floor
  plus the `COLL_UP_WALL` strips; the only vertical transitions are the six
  ladders, the pit and the five ledges.
- **"Head back up the ladder to get back to the third floor"** (after TM26).
  There is no ladder inside the TM pocket. The two ways out are the `HOP_RIGHT`
  at (8,28)/(8,29) into the x=10..13 corridor that reaches the (13,31) ladder,
  and the `HOP_DOWN` at (2,30)/(3,30) into the (1,35) pocket. The checklist above
  prefers the first; which one the FAQ author meant is not recoverable from the
  text.
- **X Special tile.** The Poke Ball at (7,38) sits on a `COLL_HOP_LEFT` tile with
  `COLL_WALL` on both sides and above. Ledge tiles are `LAND_TILE` in
  `CollisionPermissionTable`, so the column x=7, y=38..41 is walkable from
  (7,42) upward and the ball is reachable; but this should be confirmed on
  hardware or in an emulator, because it is the one placement in this map that
  looks like a mistake rather than a design.
- **The gate's black belts as physical blockers.** The claim that
  `VICTORYROADGATE_BLACK_BELT1` at (7,5) and `BLACK_BELT2` at (12,5) block the
  only east-west corridor is inferred from the decoded gate collision (row 5 is
  the sole corridor and rows 4/6 are walls beside it) plus the fact that NPCs are
  solid. It is not stated in any script, and it belongs to later sections
  (Route 28 / Route 22) rather than this one.
- **Object flag polarity in the port** was not tested; see the Port coverage row.

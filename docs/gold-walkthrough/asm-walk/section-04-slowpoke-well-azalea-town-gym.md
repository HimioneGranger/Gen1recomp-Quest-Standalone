# Section 04 - Slowpoke Well & Azalea Town Gym

Source: `../section-04-slowpoke-well-azalea-town-gym.txt`
Maps covered: `MAP_AZALEA_TOWN`, `MAP_KURTS_HOUSE`, `MAP_AZALEA_POKECENTER_1F`,
`MAP_SLOWPOKE_WELL_B1F`, `MAP_SLOWPOKE_WELL_B2F` (off-route, Surf-only),
`MAP_AZALEA_GYM`. `MAP_AZALEA_MART` is referenced for its stock only
(`data/items/marts.asm` `MartAzalea`); its map file was not transcribed.
Badges / key milestones in this section: **HIVEBADGE** (`ENGINE_HIVEBADGE`),
`EVENT_CLEARED_SLOWPOKE_WELL`, `EVENT_BEAT_BUGSY`, `TM_FURY_CUTTER` (TM49),
`LURE_BALL`, `SUPER_POTION`, `WHT_APRICORN`, hidden `FULL_HEAL`. Clearing the
well is what unlocks the Gym door and arms the Azalea rival battle for the next
section.

Coordinate convention throughout: the raw asm x/y from
`warp_event` / `coord_event` / `bg_event` / `object_event`, i.e. walk cells
(two 8x8 tiles per side, two cells per map block). `macros/scripts/maps.asm`
adds the +4 border internally; the numbers below are the pre-border values as
written in the map file.

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `MAP_AZALEA_TOWN` | `maps/AzaleaTown.asm` | west edge of Route 33 (`connection east, Route33, ROUTE_33, 0` in `data/maps/attributes.asm`) | warp 4, `warp_event 9, 5, KURTS_HOUSE, 1` | Rocket guard is standing on the well; head west then north to Kurt's house |
| 2 | `MAP_KURTS_HOUSE` | `maps/KurtsHouse.asm` | warp 1 (`3, 7`) | warps 1/2 (`3, 7` / `4, 7`) back to `AZALEA_TOWN` warp 4 | `Kurt1` first-visit arm: Kurt storms off to the well and sets `EVENT_AZALEA_TOWN_SLOWPOKETAIL_ROCKET`, which hides the guard |
| 3 | `MAP_AZALEA_POKECENTER_1F` | `maps/AzaleaPokecenter1F.asm` | `AZALEA_TOWN` warp 1 (`15, 9`) | warps 1/2 (`3, 7` / `4, 7`) | "heal at the Pokemon Center" |
| 4 | `MAP_AZALEA_TOWN` | `maps/AzaleaTown.asm` | Pokecenter warp | warp 6, `warp_event 31, 7, SLOWPOKE_WELL_B1F, 1` | walk east to the now-unguarded well |
| 5 | `MAP_SLOWPOKE_WELL_B1F` | `maps/SlowpokeWellB1F.asm` | warp 1 (`17, 15`) | **scripted** `warp KURTS_HOUSE, 3, 3` at the end of `TrainerGruntM1.Script` | four Rocket grunts, Super Potion, tailless Slowpoke |
| 6 | `MAP_KURTS_HOUSE` | `maps/KurtsHouse.asm` | script warp to `3, 3` | warps 1/2 | `Kurt1.ClearedSlowpokeWell` -> free `LURE_BALL` |
| 7 | `MAP_AZALEA_TOWN` | `maps/AzaleaTown.asm` | Kurt's House warp | fruit tree object at `8, 2`, then warp 1 (Pokecenter) | `WHT_APRICORN` from `WhiteApricornTree` / `FRUITTREE_AZALEA_TOWN`, then heal |
| 8 | `MAP_AZALEA_GYM` | `maps/AzaleaGym.asm` | `AZALEA_TOWN` warp 5, `warp_event 10, 15, AZALEA_GYM, 1` | warps 1/2 (`4, 15` / `5, 15`) | five gym trainers + Bugsy -> HIVEBADGE + TM49 |

Off-route in this section: `MAP_SLOWPOKE_WELL_B2F` (`maps/SlowpokeWellB2F.asm`)
hangs off `SLOWPOKE_WELL_B1F` warp 2 at `7, 11`, but the only land approach to
that ladder is across water (see the derived grid under B1F) - it is a Surf
return trip, not part of this visit, and holds the King's Rock and TM Rain Dance.

Spills into the next section: `AzaleaTown_MapEvents` has
`coord_event 5, 10` / `coord_event 5, 11` for `SCENE_AZALEATOWN_RIVAL_BATTLE`.
`TrainerGruntM1.Script` arms that scene with
`setmapscene AZALEA_TOWN, SCENE_AZALEATOWN_RIVAL_BATTLE`, so the rival ambush
fires the first time you walk west toward the Ilex Forest gate. That battle and
Ilex Forest belong to section 05.

## 2. Maps

### MAP_AZALEA_TOWN

- Script: `maps/AzaleaTown.asm`
- Blocks: `maps/AzaleaTown.blk`
- Header: `data/maps/maps.asm:232` -> `TILESET_JOHTO_MODERN`, `TOWN`,
  `LANDMARK_AZALEA_TOWN`, `MUSIC_AZALEA_TOWN`, phone `FALSE`, `PALETTE_AUTO`,
  `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:213` -> `map_const AZALEA_TOWN, 20, 9`
  (20x9 blocks = 40x18 walk cells)
- Connections (`data/maps/attributes.asm:132`): `map_attributes AzaleaTown, AZALEA_TOWN, $05`,
  `connection west, Route34, ROUTE_34, -18`, `connection east, Route33, ROUTE_33, 0`
- Scene var: `data/maps/scenes.asm:37` -> `scene_var AZALEA_TOWN, wAzaleaTownSceneID`
- Spawn / fly landing: `data/maps/spawn_points.asm:31` -> `spawn AZALEA_TOWN, 15, 10`;
  flypoint row `data/maps/flypoints.asm:8` -> `db LANDMARK_AZALEA_TOWN, SPAWN_AZALEA`
- Map scripts: `def_scene_scripts` = `AzaleaTownNoop1Scene` (`SCENE_AZALEATOWN_NOOP` = 0),
  `AzaleaTownNoop2Scene` (`SCENE_AZALEATOWN_RIVAL_BATTLE` = 1);
  `def_callbacks` = `callback MAPCALLBACK_NEWMAP, AzaleaTownFlypointCallback`

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
| `SCENE_AZALEATOWN_RIVAL_BATTLE` | 5 | 10 | `AzaleaTownRivalBattleScene1` | rival ambush, approach from the east; next section |
| `SCENE_AZALEATOWN_RIVAL_BATTLE` | 5 | 11 | `AzaleaTownRivalBattleScene2` | same battle, second entry row; next section |

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 19 | 9 | `BGEVENT_READ` | `AzaleaTownSign` |
| 10 | 9 | `BGEVENT_READ` | `KurtsHouseSign` |
| 14 | 15 | `BGEVENT_READ` | `AzaleaGymSign` |
| 29 | 7 | `BGEVENT_READ` | `SlowpokeWellSign` |
| 19 | 13 | `BGEVENT_READ` | `CharcoalKilnSign` |
| 16 | 9 | `BGEVENT_READ` | `AzaleaTownPokecenterSign` (`jumpstd PokecenterSignScript`) |
| 22 | 5 | `BGEVENT_READ` | `AzaleaTownMartSign` (`jumpstd MartSignScript`) |
| 3 | 9 | `BGEVENT_READ` | `AzaleaTownIlextForestSign` |
| 31 | 6 | `BGEVENT_ITEM` | `AzaleaTownHiddenFullHeal` -> `hiddenitem FULL_HEAL, EVENT_AZALEA_TOWN_HIDDEN_FULL_HEAL` |

**Object events** (`def_object_events`) - `object_const_def` is `const_def 2`, so
the first const is 2 and row N carries const N+1.

| const | sprite | x | y | movement (radius x,y / hours / pal) | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| 2 `AZALEATOWN_AZALEA_ROCKET1` | `SPRITE_AZALEA_ROCKET` | 31 | 9 | `STANDING_DOWN` 0,0 / -1,-1 / 0 | `OBJECTTYPE_SCRIPT`, 0 | `AzaleaTownRocket1Script` | `EVENT_AZALEA_TOWN_SLOWPOKETAIL_ROCKET` |
| 3 `AZALEATOWN_GRAMPS` | `SPRITE_GRAMPS` | 21 | 9 | `WANDER` 1,2 / -1,-1 / 0 | `OBJECTTYPE_SCRIPT`, 0 | `AzaleaTownGrampsScript` | -1 |
| 4 `AZALEATOWN_TEACHER` | `SPRITE_TEACHER` | 15 | 13 | `WALK_UP_DOWN` 0,2 / -1,-1 / `PAL_NPC_BLUE` | `OBJECTTYPE_SCRIPT`, 0 | `AzaleaTownTeacherScript` | -1 |
| 5 `AZALEATOWN_YOUNGSTER` | `SPRITE_YOUNGSTER` | 7 | 9 | `WALK_LEFT_RIGHT` 1,0 / -1,-1 / `PAL_NPC_GREEN` | `OBJECTTYPE_SCRIPT`, 0 | `AzaleaTownYoungsterScript` | -1 |
| 6 `AZALEATOWN_SLOWPOKE1` | `SPRITE_SLOWPOKE` | 8 | 17 | `STILL` | `OBJECTTYPE_SCRIPT`, 0 | `AzaleaTownSlowpokeScript` | `EVENT_AZALEA_TOWN_SLOWPOKES` |
| 7 `AZALEATOWN_SLOWPOKE2` | `SPRITE_SLOWPOKE` | 18 | 9 | `STILL` | `OBJECTTYPE_SCRIPT`, 0 | `AzaleaTownSlowpokeScript` | `EVENT_AZALEA_TOWN_SLOWPOKES` |
| 8 `AZALEATOWN_SLOWPOKE3` | `SPRITE_SLOWPOKE` | 29 | 9 | `STILL` | `OBJECTTYPE_SCRIPT`, 0 | `AzaleaTownSlowpokeScript` | `EVENT_AZALEA_TOWN_SLOWPOKES` |
| 9 `AZALEATOWN_SLOWPOKE4` | `SPRITE_SLOWPOKE` | 15 | 15 | `STILL` | `OBJECTTYPE_SCRIPT`, 0 | `AzaleaTownSlowpokeScript` | `EVENT_AZALEA_TOWN_SLOWPOKES` |
| 10 `AZALEATOWN_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 8 | 2 | `STILL` | `OBJECTTYPE_SCRIPT`, 0 | `WhiteApricornTree` | -1 |
| 11 `AZALEATOWN_RIVAL` | `SPRITE_AZALEA_ROCKET` | 11 | 10 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT`, 0 | `ObjectEvent` | `EVENT_RIVAL_AZALEA_TOWN` |
| 12 `AZALEATOWN_AZALEA_ROCKET3` | `SPRITE_AZALEA_ROCKET` | 10 | 16 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT`, 0 | `AzaleaTownRocket2Script` | `EVENT_SLOWPOKE_WELL_ROCKETS` |

`SPRITE_AZALEA_ROCKET` (`constants/sprite_constants.asm:156`, id `$f6`) is a
variable sprite. `engine/events/std_scripts.asm:539` seeds it as
`variablesprite SPRITE_AZALEA_ROCKET, SPRITE_ROCKET`; `TrainerGruntM1.Script`
in `maps/SlowpokeWellB1F.asm` re-points it with
`variablesprite SPRITE_AZALEA_ROCKET, SPRITE_RIVAL`, which is why const 11 draws
as the rival even though the row names the Rocket slot.

**Derived walkability** (from `maps/AzaleaTown.blk` + `data/tilesets/johto_modern_collision.asm`
+ `data/collision/collision_permissions.asm`; `.` land, `#` wall, `h` ledge hop,
`W` warp tile, columns are x, rows are y)

```
    0123456789012345678901234567890123456789
  0 ###############################.........
  1 ######....#####################.........
  2 ######....#####################.........
  3 ######....##############################
  4 ######..################################
  5 ######..#W###########W######......######
  6 ######hhh.hh########....####..###.######
  7 #########.##########....####.##W#.######
  8 ##...#......######............#.#.######
  9 ######....#.###W##.#..............######
 10 ##W.........................hhh.hh######
 11 ##W.....................#######.########
 12 ######..######......########......######
 13 ######..######.....##W######............
 14 ######..######..........####............
 15 ######..##W####.........####............
 16 ######..............####################
 17 ######..............####################
```

Two chokepoints matter: `31, 9` is the only walkable cell that reaches `31, 8`
and then the well ladder at `31, 7`, and `10, 16` is the only walkable cell
adjacent to the Gym door at `10, 15` (`9, 15`, `11, 15` and `10, 14` are all
wall). The two Rocket objects sit exactly on those cells.

**Scripts of interest**

- `AzaleaTownFlypointCallback` - `MAPCALLBACK_NEWMAP`; `setflag ENGINE_FLYPOINT_AZALEA`,
  `endcallback`. Entering the map once is enough to register the fly point.
- `AzaleaTownRocket1Script` / `AzaleaTownRocket2Script` -
  `jumptextfaceplayer AzaleaTownRocket1Text` / `...Rocket2Text`. Pure flavour;
  neither one gates anything by script. They block by standing on tiles.
- `AzaleaTownGrampsScript` - `checkevent EVENT_CLEARED_SLOWPOKE_WELL` /
  `iftrue .ClearedWell`, then one of `AzaleaTownGrampsTextBefore` /
  `AzaleaTownGrampsTextAfter`. Cheap read-only probe of well state.
- `WhiteApricornTree` - `fruittree FRUITTREE_AZALEA_TOWN`.
  `constants/script_constants.asm:226` gives `FRUITTREE_AZALEA_TOWN ; 14` (hex),
  and `data/items/fruit_trees.asm:23` is `db WHT_APRICORN ; AZALEA_TOWN`.
  Once-per-day, tracked by the fruit-tree daily bit, not by an `EVENT_*`.
- `AzaleaTownHiddenFullHeal` - `hiddenitem FULL_HEAL, EVENT_AZALEA_TOWN_HIDDEN_FULL_HEAL`;
  reached by facing the wall cell `31, 6` from `31, 7`/`31, 5` neighbours.
- `AzaleaTownRivalBattleScene1` / `...Scene2` / `AzaleaTownRivalBattleScript` -
  next section. For completeness they `setevent EVENT_RIVAL_AZALEA_TOWN`,
  branch on `EVENT_GOT_TOTODILE_FROM_ELM` / `EVENT_GOT_CHIKORITA_FROM_ELM`,
  `loadtrainer RIVAL1, RIVAL1_2_TOTODILE|RIVAL1_2_CHIKORITA|RIVAL1_2_CYNDAQUIL`,
  and end with `setscene SCENE_AZALEATOWN_NOOP`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_AZALEA` | `constants/engine_flags.asm:82` | set by `AzaleaTownFlypointCallback` | Fly destination unlocked on first entry |
| `EVENT_AZALEA_TOWN_SLOWPOKETAIL_ROCKET` | `constants/event_flags.asm:1180` | set by `Kurt1` (first-visit arm) and read by `KurtsGranddaughter.Lonely` | **set = the well guard at `31, 9` is hidden**; this is the well gate |
| `EVENT_SLOWPOKE_WELL_ROCKETS` | `constants/event_flags.asm:1182` | set by the `disappear` calls in `TrainerGruntM1.Script` | **set = the Rocket at `10, 16` is hidden**; this is the Gym gate |
| `EVENT_AZALEA_TOWN_SLOWPOKES` | `constants/event_flags.asm:1179` | `clearevent` in `TrainerGruntM1.Script` | cleared = the four town Slowpoke appear |
| `EVENT_CLEARED_SLOWPOKE_WELL` | `constants/event_flags.asm:52` | set in `TrainerGruntM1.Script`; read by `AzaleaTownGrampsScript`, `Kurt1`, `KurtsGranddaughter`, `KurtsHouseKurtCallback` | the section-4 milestone flag |
| `EVENT_RIVAL_AZALEA_TOWN` | `constants/event_flags.asm:1121` | set by `AzaleaTownRivalBattleScript` | next section |
| `EVENT_AZALEA_TOWN_HIDDEN_FULL_HEAL` | `constants/event_flags.asm:187` | `hiddenitem` | one-shot hidden item |
| `SCENE_AZALEATOWN_NOOP` = 0, `SCENE_AZALEATOWN_RIVAL_BATTLE` = 1 | generated by `scene_script` in `macros/scripts/maps.asm:25` (`scene_const` + `EXPORT`) | `setscene` / `setmapscene` | scene id in `wAzaleaTownSceneID` |

Object visibility semantics, since everything above depends on it:
`engine/overworld/scripting.asm:879` `Script_appear` calls
`ApplyEventActionAppearDisappear` with `b = 0 ; clear`, and `:887`
`Script_disappear` with `b = 1 ; set`. **An object's `EVENT_*` flag SET means the
object is hidden.**

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `WHT_APRICORN` | talk to the tree object at `8, 2` | `WhiteApricornTree` -> `fruittree FRUITTREE_AZALEA_TOWN`, `data/items/fruit_trees.asm:23` | none (daily respawn) |
| `FULL_HEAL` | hidden, face `31, 6` | `AzaleaTownHiddenFullHeal` bg_event | `EVENT_AZALEA_TOWN_HIDDEN_FULL_HEAL` |

Azalea Mart stock (`data/items/marts.asm:71`, `MartAzalea`, 9 items):
`CHARCOAL`, `POKE_BALL`, `POTION`, `SUPER_POTION`, `ESCAPE_ROPE`, `REPEL`,
`ANTIDOTE`, `PARLYZ_HEAL`, `FLOWER_MAIL`.

**Trainers**

None on this map in this section (the rival at const 11 is section 05).

**Wild encounters**

`AZALEA_TOWN` has no entry in `data/wild/johto_grass.asm` or
`data/wild/johto_water.asm`. Fishing group is `FISHGROUP_SHORE`
(`data/maps/maps.asm:232`); headbutt set is
`data/wild/treemon_maps.asm:31` -> `treemon_map AZALEA_TOWN, TREEMON_SET_FOREST`.

---

### MAP_KURTS_HOUSE

- Script: `maps/KurtsHouse.asm`
- Blocks: `maps/KurtsHouse.blk`
- Header: `data/maps/maps.asm:229` -> `TILESET_TRADITIONAL_HOUSE`, `INDOOR`,
  `LANDMARK_AZALEA_TOWN`, `MUSIC_AZALEA_TOWN`, phone `FALSE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:210` -> `map_const KURTS_HOUSE, 8, 4`
- Connections: none (indoor)
- Map scripts: no scene scripts; `callback MAPCALLBACK_OBJECTS, KurtsHouseKurtCallback`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `AZALEA_TOWN` | 4 |
| 2 | 4 | 7 | `AZALEA_TOWN` | 4 |

**Coord events** (`def_coord_events`) - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 6 | 1 | `BGEVENT_READ` | `KurtsHouseRadio` (`jumpstd Radio2Script`) |
| 8 | 0 | `BGEVENT_READ` | `KurtsHouseOakPhoto` |
| 9 | 0 | `BGEVENT_READ` | `KurtsHouseOakPhoto` |
| 5 | 1 | `BGEVENT_READ` | `KurtsHouseBookshelf` (`jumpstd DifficultBookshelfScript`) |
| 2 | 1 | `BGEVENT_READ` | `KurtsHouseBookshelf` |
| 3 | 1 | `BGEVENT_READ` | `KurtsHouseBookshelf` |
| 4 | 1 | `BGEVENT_READ` | `KurtsHouseCelebiStatue` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| 2 `KURTSHOUSE_KURT1` | `SPRITE_KURT` | 3 | 2 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT`, 0 | `Kurt1` | `EVENT_KURTS_HOUSE_KURT_1` |
| 3 `KURTSHOUSE_TWIN` | `SPRITE_TWIN` | 5 | 3 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT`, 0 | `KurtsGranddaughter` | -1 |
| 4 `KURTSHOUSE_SLOWPOKE` | `SPRITE_SLOWPOKE` | 6 | 3 | `STILL` | `OBJECTTYPE_SCRIPT`, 0 | `KurtsHouseSlowpoke` | `EVENT_KURTS_HOUSE_SLOWPOKE` |
| 5 `KURTSHOUSE_KURT2` | `SPRITE_KURT` | 14 | 3 | `STANDING_UP` | `OBJECTTYPE_SCRIPT`, 0 | `Kurt1` | `EVENT_KURTS_HOUSE_KURT_2` |

Both Kurt objects run the same `Kurt1` script; the callback picks which one is
visible.

**Derived walkability** (`maps/KurtsHouse.blk` + `data/tilesets/traditional_house_collision.asm`)

```
    0123456789012345
  0 ################
  1 #######...######
  2 #...........####
  3 .......##...#...
  4 .......##...#...
  5 ................
  6 ................
  7 ...WW...........
```

The post-well script warp lands you on `3, 3`, one cell south of `KURTSHOUSE_KURT1`
at `3, 2`, who faces down. Talk immediately, no walking required.

**Scripts of interest**

- `KurtsHouseKurtCallback` (`MAPCALLBACK_OBJECTS`) -
  `checkevent EVENT_CLEARED_SLOWPOKE_WELL` / `iffalse .Done`;
  then `checkflag ENGINE_KURT_MAKING_BALLS` / `iftrue .MakingBalls`.
  Not making balls: `disappear KURTSHOUSE_KURT2`, `appear KURTSHOUSE_KURT1`.
  Making balls: `disappear KURTSHOUSE_KURT1`, `appear KURTSHOUSE_KURT2`
  (he moves to the workshop at `14, 3`).
- `Kurt1` - three arms, tested in this order:
  1. `checkevent EVENT_KURT_GAVE_YOU_LURE_BALL` / `iftrue .GotLureBall`
  2. `checkevent EVENT_CLEARED_SLOWPOKE_WELL` / `iftrue .ClearedSlowpokeWell`
  3. fallthrough = **first visit**: `writetext KurtsHouseKurtMakingBallsMustWaitText`,
     `special FadeOutMusic`, `setevent EVENT_AZALEA_TOWN_SLOWPOKETAIL_ROCKET`,
     `readvar VAR_FACING` / `ifequal UP, .RunAround`, `turnobject PLAYER, DOWN`,
     `playsound SFX_FLY`,
     `applymovement KURTSHOUSE_KURT1, KurtsHouseKurtExitHouseMovement`
     (5x `big_step DOWN`; the `.RunAround` variant is
     `KurtsHouseKurtGoAroundPlayerThenExitHouseMovement`, `big_step RIGHT` then
     5x `big_step DOWN`), `disappear KURTSHOUSE_KURT1`, `special RestartMapMusic`.
     **This single `setevent` is what removes the well guard.**
  - `.ClearedSlowpokeWell`: `writetext KurtsHouseKurtHonoredToMakeBallsText`,
    `promptbutton`, `verbosegiveitem LURE_BALL`, `iffalse .NoRoomForBall`,
    `setevent EVENT_KURT_GAVE_YOU_LURE_BALL`, then falls into `.GotLureBall`.
  - `.GotLureBall`: the apricorn loop. Checks `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_2`,
    `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1`, then the seven
    `EVENT_GAVE_KURT_<colour>_APRICORN` in order RED, BLU, YLW, GRN, WHT, BLK, PNK;
    if none, `checkitem` the seven apricorns, `special SelectApricornForKurt`,
    set the matching event, `setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1`,
    `setflag ENGINE_KURT_MAKING_BALLS`. WHT -> `verbosegiveitem FAST_BALL`
    (`.GiveFastBall`) the next day. Only one apricorn is held at a time, which
    is exactly the reader comment quoted in the walkthrough.
- `KurtsGranddaughter` - branch order `EVENT_FAST_SHIP_FIRST_TIME`,
  `EVENT_CLEARED_SLOWPOKE_WELL`, `EVENT_AZALEA_TOWN_SLOWPOKETAIL_ROCKET`. Read-only.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_KURTS_HOUSE_KURT_1` | `constants/event_flags.asm:1248` | `disappear`/`appear` in `Kurt1` + callback | set = house Kurt hidden (he is at the well) |
| `EVENT_KURTS_HOUSE_KURT_2` | `constants/event_flags.asm:1249` | callback; also `setevent` in `engine/events/std_scripts.asm:531` | set = workshop Kurt hidden |
| `EVENT_KURTS_HOUSE_SLOWPOKE` | `constants/event_flags.asm:1183` | `clearevent` in `TrainerGruntM1.Script` | cleared = the family Slowpoke is back |
| `EVENT_KURT_GAVE_YOU_LURE_BALL` | `constants/event_flags.asm:62` | set in `Kurt1.ClearedSlowpokeWell` | free ball already taken |
| `EVENT_GAVE_KURT_WHT_APRICORN` | `constants/event_flags.asm:263` | `Kurt1.Wht` / cleared in `.GiveFastBall` | apricorn currently in Kurt's hands |
| `ENGINE_KURT_MAKING_BALLS` | `constants/engine_flags.asm:97` (`wDailyFlags1`) | `setflag` in `.GaveKurtApricorns`, read by the callback and every `.Give*Ball` arm | the day-long wait; cleared by the daily reset, not by a script |
| `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1` / `_2` | `constants/event_flags.asm:5` / `:6` | `Kurt1` | per-visit conversation state, wiped on map reload |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `LURE_BALL` | talk to Kurt after clearing the well | `Kurt1.ClearedSlowpokeWell` -> `verbosegiveitem LURE_BALL` | `EVENT_KURT_GAVE_YOU_LURE_BALL` |
| `FAST_BALL` | give Kurt the `WHT_APRICORN`, return a day later | `Kurt1.GiveFastBall` -> `verbosegiveitem FAST_BALL` | clears `EVENT_GAVE_KURT_WHT_APRICORN` |

**Trainers** - none. **Wild encounters** - none (indoor).

---

### MAP_AZALEA_POKECENTER_1F

- Script: `maps/AzaleaPokecenter1F.asm`
- Blocks: not present in `maps/` (shared Pokecenter layout)
- Header: `data/maps/maps.asm:226` -> `TILESET_POKECENTER`, `INDOOR`,
  `LANDMARK_AZALEA_TOWN`, `MUSIC_POKEMON_CENTER`, phone `FALSE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:207` -> `map_const AZALEA_POKECENTER_1F, 5, 4`
- Map scripts: `def_scene_scripts` = `AzaleaPokecenter1FNoopScene` (marked `; unusable`)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `AZALEA_TOWN` | 1 |
| 2 | 4 | 7 | `AZALEA_TOWN` | 1 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

**Coord events** / **BG events** - none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| 2 `AZALEAPOKECENTER1F_NURSE` | `SPRITE_NURSE` | 3 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT`, 0 | `AzaleaPokecenter1FNurseScript` (`jumpstd PokecenterNurseScript`) | -1 |
| 3 `AZALEAPOKECENTER1F_GENTLEMAN` | `SPRITE_GENTLEMAN` | 9 | 6 | `WALK_UP_DOWN` 0,1 | `OBJECTTYPE_SCRIPT`, 0 | `AzaleaPokecenter1FGentlemanScript` | -1 |
| 4 `AZALEAPOKECENTER1F_FISHING_GURU` | `SPRITE_FISHING_GURU` | 6 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT`, 0 | `AzaleaPokecenter1FFishingGuruScript` | -1 |
| 5 `AZALEAPOKECENTER1F_POKEFAN_F` | `SPRITE_POKEFAN_F` | 1 | 4 | `WANDER` 1,2 | `OBJECTTYPE_SCRIPT`, 0 | `AzaleaPokecenter1FPokefanFScript` | -1 |

Healing is `jumpstd PokecenterNurseScript`; no flags are touched.

---

### MAP_SLOWPOKE_WELL_B1F

- Script: `maps/SlowpokeWellB1F.asm`
- Blocks: `maps/SlowpokeWellB1F.blk`
- Header: `data/maps/maps.asm:110` -> `TILESET_CAVE`, `CAVE`,
  `LANDMARK_SLOWPOKE_WELL`, `MUSIC_DARK_CAVE`, phone `TRUE`, `PALETTE_NITE`,
  `FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:97` -> `map_const SLOWPOKE_WELL_B1F, 10, 9`
  (20x18 walk cells)
- Connections: none
- Map scripts: `def_scene_scripts` and `def_callbacks` are both empty

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 17 | 15 | `AZALEA_TOWN` | 6 |
| 2 | 7 | 11 | `SLOWPOKE_WELL_B2F` | 1 |

**Coord events** / **BG events** - none. Nothing trips automatically on this map;
every beat is a trainer sight-line or an A press.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement / pal | type, sight | script label | event flag |
|---|---|---|---|---|---|---|---|
| 2 `SLOWPOKEWELLB1F_ROCKET1` | `SPRITE_ROCKET` | 14 | 8 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER`, 1 | `TrainerGruntM29` | `EVENT_SLOWPOKE_WELL_ROCKETS` |
| 3 `SLOWPOKEWELLB1F_ROCKET2` | `SPRITE_ROCKET` | 5 | 2 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER`, 1 | `TrainerGruntM1` | `EVENT_SLOWPOKE_WELL_ROCKETS` |
| 4 `SLOWPOKEWELLB1F_ROCKET3` | `SPRITE_ROCKET` | 5 | 6 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER`, 2 | `TrainerGruntM2` | `EVENT_SLOWPOKE_WELL_ROCKETS` |
| 5 `SLOWPOKEWELLB1F_ROCKET_GIRL` | `SPRITE_ROCKET_GIRL` | 13 | 2 | `STANDING_DOWN` / `PAL_NPC_RED` | `OBJECTTYPE_TRAINER`, 2 | `TrainerGruntF1` | `EVENT_SLOWPOKE_WELL_ROCKETS` |
| 6 `SLOWPOKEWELLB1F_SLOWPOKE1` | `SPRITE_SLOWPOKE` | 7 | 4 | `STILL` / `PAL_NPC_RED` | `OBJECTTYPE_SCRIPT`, 0 | `SlowpokeWellB1FSlowpokeWithMailScript` | `EVENT_SLOWPOKE_WELL_SLOWPOKES` |
| 7 `SLOWPOKEWELLB1F_SLOWPOKE2` | `SPRITE_SLOWPOKE` | 6 | 2 | `STILL` / `PAL_NPC_RED` | `OBJECTTYPE_SCRIPT`, 0 | `SlowpokeWellB1FTaillessSlowpokeScript` | `EVENT_SLOWPOKE_WELL_SLOWPOKES` |
| 8 `SLOWPOKEWELLB1F_KURT` | `SPRITE_KURT` | 16 | 14 | `STANDING_UP` | `OBJECTTYPE_SCRIPT`, 0 | `SlowpokeWellB1FKurtScript` | `EVENT_SLOWPOKE_WELL_KURT` |
| 9 `SLOWPOKEWELLB1F_BOULDER` | `SPRITE_BOULDER` | 3 | 2 | `STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT`, 0 | `SlowpokeWellB1FBoulder` (`jumpstd StrengthBoulderScript`) | -1 |
| 10 `SLOWPOKEWELLB1F_POKE_BALL` | `SPRITE_POKE_BALL` | 10 | 3 | `STILL` | `OBJECTTYPE_ITEMBALL`, 0 | `SlowpokeWellB1FSuperPotion` (`itemball SUPER_POTION`) | `EVENT_SLOWPOKE_WELL_B1F_SUPER_POTION` |

**Derived walkability** (`maps/SlowpokeWellB1F.blk` + `data/tilesets/cave_collision.asm`
+ `data/collision/collision_permissions.asm`; `~` = water, `L` = ladder/warp)

```
    01234567890123456789
  1 .################...
  2 .#......#......##...
  3 .#..#...#......##...
  4 .#.#....#......##...
  5 .#.#....###.##.##...
  6 .#..#.......#...#...
  7 .##.##########..#...
  8 .#..#####....#..#...
  9 .#.######....#..#...
 10 .#.##........#..#...
 11 .#.##..L.#####..###.
 12 .#~~#....#~~~~....#.
 13 .#~~###.##~~~~....#.
 14 .#~~~~~~##~~~~....#.
 15 .#~~~~~~##~~~~...L#.
```

Route through the well, matching the walkthrough beat for beat:
`17, 15` (entry ladder) -> Kurt at `16, 14` -> north up the `14-15` column to
`14, 8`/`15, 8` where `TrainerGruntM29` sees you -> continue north to the top
room `9..14, 2..4`, where `TrainerGruntF1` at `13, 2` faces down with sight 2 ->
Super Potion ball at `10, 3` -> back east/down through the gap at `11, 5` into
the long row-6 corridor -> west to `TrainerGruntM2` at `5, 6` (faces right,
sight 2) -> Slowpoke with mail at `7, 4`, tailless Slowpoke at `6, 2` ->
`TrainerGruntM1` at `5, 2` (faces down, sight 1).

The B2F ladder at `7, 11` sits in a chamber walled off along row 7 and reachable
only from `7, 13`, whose only non-wall neighbour outside the chamber is the water
at `7, 14`. **B2F is Surf-only**; the water is also the only route down from the
land at `2, 11`.

**Scripts of interest**

- `SlowpokeWellB1FKurtScript` - `jumptextfaceplayer SlowpokeWellB1FKurtText`.
  Flavour only; Kurt does not gate anything here.
- `TrainerGruntM29` - `trainer GRUNTM, GRUNTM_29, EVENT_BEAT_ROCKET_GRUNTM_29, GruntM29SeenText, GruntM29BeatenText, 0, .Script`;
  `.Script` is `endifjustbattled` + `GruntM29AfterBattleText`. Talking again is
  the "they're chopping off Slowpoke tails" line the walkthrough mentions.
- `TrainerGruntF1` - `trainer GRUNTF, GRUNTF_1, EVENT_BEAT_ROCKET_GRUNTF_1, ...`,
  same `endifjustbattled` shape.
- `TrainerGruntM2` - `trainer GRUNTM, GRUNTM_2, EVENT_BEAT_ROCKET_GRUNTM_2, ...`,
  same shape.
- `TrainerGruntM1` - **the section's payload.**
  `trainer GRUNTM, GRUNTM_1, EVENT_BEAT_ROCKET_GRUNTM_1, GruntM1SeenText, GruntM1BeatenText, 0, .Script`.
  `.Script` has no `endifjustbattled`, so it runs immediately after the win:
  `writetext TrainerGruntM1WhenTalkText`, `special FadeOutToBlack`,
  `special ReloadSpritesNoPalettes`,
  `disappear` on consts 2/3/4/5 (all four share `EVENT_SLOWPOKE_WELL_ROCKETS`,
  so this is the flag that clears the Gym door in town), `pause 15`,
  `special FadeInFromBlack`, `disappear SLOWPOKEWELLB1F_KURT`,
  `moveobject SLOWPOKEWELLB1F_KURT, 11, 6`, `appear SLOWPOKEWELLB1F_KURT`,
  `applymovement SLOWPOKEWELLB1F_KURT, KurtSlowpokeWellVictoryMovementData`
  (4x `step LEFT`, `step UP`, 3x `step_sleep 8`, `step LEFT`, 2x `step UP`,
  3x `step_sleep 8`, `turn_head LEFT`), `turnobject PLAYER, RIGHT`,
  `writetext KurtLeaveSlowpokeWellText`, then the flag block:
  ```
  setevent   EVENT_CLEARED_SLOWPOKE_WELL
  variablesprite SPRITE_AZALEA_ROCKET, SPRITE_RIVAL
  setmapscene AZALEA_TOWN, SCENE_AZALEATOWN_RIVAL_BATTLE
  clearevent EVENT_ILEX_FOREST_APPRENTICE
  clearevent EVENT_ILEX_FOREST_FARFETCHD_1
  setevent   EVENT_CHARCOAL_KILN_FARFETCH_D
  setevent   EVENT_CHARCOAL_KILN_APPRENTICE
  setevent   EVENT_SLOWPOKE_WELL_SLOWPOKES
  setevent   EVENT_SLOWPOKE_WELL_KURT
  clearevent EVENT_AZALEA_TOWN_SLOWPOKES
  clearevent EVENT_KURTS_HOUSE_SLOWPOKE
  clearevent EVENT_KURTS_HOUSE_KURT_1
  ```
  then `special FadeOutToWhite`, `special HealParty`, `pause 15`,
  `warp KURTS_HOUSE, 3, 3`, `end`. Note the free party heal, and note that the
  Ilex Forest Farfetch'd quest is armed here, not in Ilex Forest.
- `SlowpokeWellB1FSlowpokeWithMailScript` - `faceplayer`, `cry SLOWPOKE`,
  `SlowpokeWellB1FSlowpokeWithMailText`, `yesorno` / `iftrue .ReadMail` ->
  `SlowpokeWellB1FSlowpokeMailText`. No flag, no item, purely optional.
- `SlowpokeWellB1FSuperPotion` - `itemball SUPER_POTION`, guarded by
  `EVENT_SLOWPOKE_WELL_B1F_SUPER_POTION`.
- `SlowpokeWellB1FBoulder` - `jumpstd StrengthBoulderScript`; needs Strength,
  which is not obtainable in this section.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_ROCKET_GRUNTM_29` | `constants/event_flags.asm:792` | `TrainerGruntM29` | grunt 1 beaten |
| `EVENT_BEAT_ROCKET_GRUNTF_1` | `constants/event_flags.asm:796` | `TrainerGruntF1` | grunt 2 beaten |
| `EVENT_BEAT_ROCKET_GRUNTM_2` | `constants/event_flags.asm:765` | `TrainerGruntM2` | grunt 3 beaten |
| `EVENT_BEAT_ROCKET_GRUNTM_1` | `constants/event_flags.asm:764` | `TrainerGruntM1` | grunt 4 (leader) beaten |
| `EVENT_SLOWPOKE_WELL_ROCKETS` | `constants/event_flags.asm:1182` | set via the four `disappear` calls | hides the well grunts **and** the Azalea Gym blocker |
| `EVENT_SLOWPOKE_WELL_SLOWPOKES` | `constants/event_flags.asm:1181` | `setevent` in `TrainerGruntM1.Script` | hides the two well Slowpoke |
| `EVENT_SLOWPOKE_WELL_KURT` | `constants/event_flags.asm:1250` | `setevent` in `TrainerGruntM1.Script` | hides well Kurt |
| `EVENT_CLEARED_SLOWPOKE_WELL` | `constants/event_flags.asm:52` | set here | section milestone |
| `EVENT_SLOWPOKE_WELL_B1F_SUPER_POTION` | `constants/event_flags.asm:1027` | itemball | Super Potion taken |
| `EVENT_ILEX_FOREST_APPRENTICE` / `EVENT_ILEX_FOREST_FARFETCHD_1` | `constants/event_flags.asm:1173` / `:1163` | `clearevent` here | Farfetch'd quest NPCs become visible in Ilex Forest (section 05) |
| `EVENT_CHARCOAL_KILN_FARFETCH_D` / `EVENT_CHARCOAL_KILN_APPRENTICE` | `constants/event_flags.asm:1175` / `:1176` | `setevent` here | they leave the Charcoal Kiln |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `SUPER_POTION` | ball at `10, 3` | `SlowpokeWellB1FSuperPotion` | `EVENT_SLOWPOKE_WELL_B1F_SUPER_POTION` |

**Trainers**

Money = `base reward` x level of the last enemy mon x 4. The x4 is
`engine/battle/read_trainer_party.asm:300` `ComputeTrainerReward`
(`base * wCurPartyLevel`) followed by the `ld c, 4` add loop and two
unconditional `call .DoubleReward` at `engine/battle/core.asm:2340-2361`.
`GRUNTM` / `GRUNTF` base reward is 10 (`data/trainers/attributes.asm:185`, `:395`).

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `GRUNTM_29` | `GRUNTM` | `constants/trainer_constants.asm:289` | `GruntMGroup` "GRUNT@", `TRAINERTYPE_NORMAL`: L9 `RATTATA`, L9 `RATTATA` | `TrainerGruntM29` | no (360 = 10x9x4) |
| `GRUNTF_1` | `GRUNTF` | `constants/trainer_constants.asm:648` | `GruntFGroup` "GRUNT@", `TRAINERTYPE_NORMAL`: L9 `ZUBAT`, L11 `EKANS` | `TrainerGruntF1` | no (440 = 10x11x4) |
| `GRUNTM_2` | `GRUNTM` | `constants/trainer_constants.asm:262` | `GruntMGroup` "GRUNT@", `TRAINERTYPE_NORMAL`: L7 `RATTATA`, L9 `ZUBAT`, L9 `ZUBAT` | `TrainerGruntM2` | no (360 = 10x9x4) |
| `GRUNTM_1` | `GRUNTM` | `constants/trainer_constants.asm:261` | `GruntMGroup` "GRUNT@", `TRAINERTYPE_NORMAL`: L14 `KOFFING` | `TrainerGruntM1` | no (560 = 10x14x4) |

**Wild encounters**

- Grass/cave, `data/wild/johto_grass.asm:582` `def_grass_wildmons SLOWPOKE_WELL_B1F`,
  `db 2 percent, 2 percent, 2 percent` - **identical morn/day/nite lists**:
  L5 `ZUBAT`, L6 `ZUBAT`, L7 `ZUBAT`, L6 `SLOWPOKE`, L8 `ZUBAT`, L8 `SLOWPOKE`,
  L8 `SLOWPOKE`.
- Water, `data/wild/johto_water.asm:33` `def_water_wildmons SLOWPOKE_WELL_B1F`,
  `db 2 percent`: L15 `SLOWPOKE`, L20 `SLOWPOKE`, L10 `SLOWPOKE`.
- Fishing: `FISHGROUP_LAKE` (`data/wild/fish.asm:14`) ->
  `.Lake_Old` L10 `MAGIKARP`/`MAGIKARP`/`GOLDEEN`, `.Lake_Good` L20
  `MAGIKARP`/`GOLDEEN`/`GOLDEEN` + `time_group 4`, `.Lake_Super` L40
  `GOLDEEN`/`time_group 5`/`MAGIKARP`/`SEAKING`.
- Headbutt: `data/wild/treemon_maps.asm:47` -> `treemon_map SLOWPOKE_WELL_B1F, TREEMON_SET_ROCK`
  (rock smash set; no headbutt trees underground).

---

### MAP_SLOWPOKE_WELL_B2F (off-route, Surf-gated)

- Script: `maps/SlowpokeWellB2F.asm`
- Blocks: `maps/SlowpokeWellB2F.blk`
- Header: `data/maps/maps.asm:111` -> `TILESET_CAVE`, `CAVE`,
  `LANDMARK_SLOWPOKE_WELL`, `MUSIC_DARK_CAVE`, phone `TRUE`, `PALETTE_NITE`,
  `FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:98` -> `map_const SLOWPOKE_WELL_B2F, 10, 9`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 11 | `SLOWPOKE_WELL_B1F` | 2 |

**Coord events** / **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| 2 `SLOWPOKEWELLB2F_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 5 | 4 | `WANDER` 1,2 | `OBJECTTYPE_SCRIPT`, 1 | `SlowpokeWellB2FGymGuideScript` | -1 |
| 3 `SLOWPOKEWELLB2F_POKE_BALL` | `SPRITE_POKE_BALL` | 15 | 5 | `STILL` | `OBJECTTYPE_ITEMBALL`, 0 | `SlowpokeWellB2FTMRainDance` (`itemball TM_RAIN_DANCE`) | `EVENT_SLOWPOKE_WELL_B2F_TM_RAIN_DANCE` |

`SlowpokeWellB2FGymGuideScript`: `checkevent EVENT_GOT_KINGS_ROCK_IN_SLOWPOKE_WELL`
/ `iftrue .GotKingsRock`, else `verbosegiveitem KINGS_ROCK`, `iffalse .NoRoom`,
`setevent EVENT_GOT_KINGS_ROCK_IN_SLOWPOKE_WELL`
(`constants/event_flags.asm:124`).

Wild: `data/wild/johto_grass.asm:610` L19-23 `ZUBAT`/`SLOWPOKE`/`GOLBAT`
(same three time slots); `data/wild/johto_water.asm:40` is `4 percent` in Gold
(`IF DEF(_GOLD)`) / `2 percent` in Silver, L15 `SLOWPOKE`, L20 `SLOWPOKE`,
L20 `SLOWBRO`.

---

### MAP_AZALEA_GYM

- Script: `maps/AzaleaGym.asm`
- Blocks: `maps/AzaleaGym.blk`
- Header: `data/maps/maps.asm:230` -> `TILESET_ELITE_FOUR_ROOM`, `INDOOR`,
  `LANDMARK_AZALEA_TOWN`, `MUSIC_GYM`, phone `TRUE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:211` -> `map_const AZALEA_GYM, 5, 8`
  (10x16 walk cells)
- Map scripts: `def_scene_scripts` and `def_callbacks` are both empty

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 15 | `AZALEA_TOWN` | 5 |
| 2 | 5 | 15 | `AZALEA_TOWN` | 5 |

**Coord events** - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 3 | 13 | `BGEVENT_READ` | `AzaleaGymStatue` |
| 6 | 13 | `BGEVENT_READ` | `AzaleaGymStatue` |

`AzaleaGymStatue`: `checkflag ENGINE_HIVEBADGE` / `iftrue .Beaten`;
unbeaten -> `jumpstd GymStatue1Script`, beaten ->
`gettrainername STRING_BUFFER_4, BUGSY, BUGSY1` + `jumpstd GymStatue2Script`.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement / pal | type, sight | script label | event flag |
|---|---|---|---|---|---|---|---|
| 2 `AZALEAGYM_BUGSY` | `SPRITE_BUGSY` | 5 | 7 | `SPINRANDOM_SLOW` / `PAL_NPC_GREEN` | `OBJECTTYPE_SCRIPT`, 0 | `AzaleaGymBugsyScript` | -1 |
| 3 `AZALEAGYM_BUG_CATCHER1` | `SPRITE_BUG_CATCHER` | 5 | 3 | `SPINRANDOM_FAST` / `PAL_NPC_BROWN` | `OBJECTTYPE_TRAINER`, 2 | `TrainerBugCatcherBenny` | -1 |
| 4 `AZALEAGYM_BUG_CATCHER2` | `SPRITE_BUG_CATCHER` | 8 | 8 | `STANDING_DOWN` / `PAL_NPC_BROWN` | `OBJECTTYPE_TRAINER`, 3 | `TrainerBugCatcherAl` | -1 |
| 5 `AZALEAGYM_BUG_CATCHER3` | `SPRITE_BUG_CATCHER` | 0 | 2 | `STANDING_DOWN` / `PAL_NPC_BROWN` | `OBJECTTYPE_TRAINER`, 3 | `TrainerBugCatcherJosh` | -1 |
| 6 `AZALEAGYM_TWIN1` | `SPRITE_TWIN` | 4 | 10 | `STANDING_DOWN` / `PAL_NPC_RED` | `OBJECTTYPE_TRAINER`, 1 | `TrainerTwinsAmyandmay1` | -1 |
| 7 `AZALEAGYM_TWIN2` | `SPRITE_TWIN` | 5 | 10 | `STANDING_DOWN` / `PAL_NPC_RED` | `OBJECTTYPE_TRAINER`, 1 | `TrainerTwinsAmyandmay2` | -1 |
| 8 `AZALEAGYM_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 7 | 13 | `STANDING_DOWN` / `PAL_NPC_RED` | `OBJECTTYPE_SCRIPT`, 0 | `AzaleaGymGuideScript` | -1 |

None of the gym objects carry an event flag, so they are always drawn; being
"beaten" is entirely the `trainer` macro's own `EVENT_BEAT_*` check.

**Derived walkability** (`maps/AzaleaGym.blk` + `data/tilesets/elite_four_room_collision.asm`)

```
    0123456789
  0 ##########
  1 ##########
  2 ..........
  3 ..........
  4 ..##..##..
  5 ..#....#..
  6 .#..##..#.
  7 .#......#.
  8 ..#....#..
  9 ..##..##..
 10 ..........
 11 ..........
 12 ##.#..#.##
 13 ##.#..#.##
 14 ###.....##
 15 ###.WW..##
```

It is a spiral. Entry `4, 15` / `5, 15` -> `4, 14`..`7, 14` -> the two
entry stalks at columns 4-5 and 7 -> the row 10/11 ring -> up either side
column (0-1 or 8-9) -> row 2/3 -> in at `4, 4` / `5, 4` -> `4, 5`..`6, 5` ->
`3, 6` -> `3, 7` -> Bugsy at `5, 7`.

Derived from the grid plus the sight fields: only the **twins** sit on the
straight-line path (`4, 11` and `5, 11` are their sight cells), and even they
are dodgeable by taking the column-7 stalk from `7, 14` up to `7, 11`. Josh's
sight covers `0, 3`-`0, 5` so the left column is his; Al's covers `8, 9`-`8, 11`
so the column-8 approach is his; column 9 is clear all the way from row 11 to
row 3. Benny spins (`SPINRANDOM_FAST`, sight 2) at `5, 3`, so crossing row 2/3
near column 5 is a coin flip rather than a guarantee.

**Scripts of interest**

- `AzaleaGymBugsyScript` -
  `faceplayer`, `opentext`, `checkevent EVENT_BEAT_BUGSY` / `iftrue .FightDone`;
  otherwise `BugsyText_INeverLose`,
  `winlosstext BugsyText_ResearchIncomplete, 0` (no loss text - losing is a
  whiteout), `loadtrainer BUGSY, BUGSY1`, `startbattle`, `reloadmapafterbattle`,
  `setevent EVENT_BEAT_BUGSY`, `Text_ReceivedHiveBadge`,
  `playsound SFX_GET_BADGE`, `waitsfx`, **`setflag ENGINE_HIVEBADGE`**,
  `readvar VAR_BADGES`, `scall AzaleaGymActivateRockets`.
  `.FightDone`: `checkevent EVENT_GOT_TM49_FURY_CUTTER` / `iftrue .GotFuryCutter`,
  then - and this is the bot-relevant part -
  ```
  setevent EVENT_BEAT_TWINS_AMY_AND_MAY
  setevent EVENT_BEAT_BUG_CATCHER_BENNY
  setevent EVENT_BEAT_BUG_CATCHER_AL
  setevent EVENT_BEAT_BUG_CATCHER_JOSH
  ```
  so beating Bugsy retroactively marks the five gym trainers beaten. Then
  `BugsyText_HiveBadgeSpeech`, `promptbutton`,
  `verbosegiveitem TM_FURY_CUTTER`, `iffalse .NoRoomForFuryCutter`,
  `setevent EVENT_GOT_TM49_FURY_CUTTER`, `BugsyText_FuryCutterSpeech`.
- `AzaleaGymActivateRockets` - `ifequal 7, .RadioTowerRockets`,
  `ifequal 6, .GoldenrodRockets`, `end`. `VAR_BADGES`
  (`constants/script_constants.asm:55`, id 7) is the badge count, which is 2
  right after HIVEBADGE, so **this scall is a no-op at Bugsy**; it is the shared
  gym-clear hook that only fires at the 6th and 7th badge.
- `TrainerTwinsAmyandmay1` / `TrainerTwinsAmyandmay2` - both use
  `EVENT_BEAT_TWINS_AMY_AND_MAY`, so you fight **one** twin, whichever spots you
  first, and the other drops to her after-battle line.
- `TrainerBugCatcherBenny` / `...Al` / `...Josh` - plain
  `trainer BUG_CATCHER, <id>, EVENT_BEAT_BUG_CATCHER_<id>, ...` with
  `endifjustbattled` after-scripts.
- `AzaleaGymGuideScript` - `checkevent EVENT_BEAT_BUGSY`; the pre-battle text is
  the "bug Pokemon don't like fire, flying-type moves are super-effective" hint.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_BUGSY` | `constants/event_flags.asm:707` | `AzaleaGymBugsyScript` | leader beaten |
| `ENGINE_HIVEBADGE` | `constants/engine_flags.asm:39` (`wJohtoBadges`, `data/events/engine_flags.asm:47`) | `setflag` here; read by `CutFunction.CheckAble`, `TryCutOW`, `AzaleaGymStatue`, `engine/battle/core.asm:6566` (obedience) | **the badge that enables field Cut and L30 obedience** |
| `EVENT_GOT_TM49_FURY_CUTTER` | `constants/event_flags.asm:15` | `AzaleaGymBugsyScript` | TM49 already handed over |
| `EVENT_BEAT_TWINS_AMY_AND_MAY` | `constants/event_flags.asm:608` | both twin objects; force-set by `.FightDone` | one flag, two objects |
| `EVENT_BEAT_BUG_CATCHER_BENNY` | `constants/event_flags.asm:843` | `TrainerBugCatcherBenny`; force-set by `.FightDone` | |
| `EVENT_BEAT_BUG_CATCHER_AL` | `constants/event_flags.asm:844` | `TrainerBugCatcherAl`; force-set by `.FightDone` | |
| `EVENT_BEAT_BUG_CATCHER_JOSH` | `constants/event_flags.asm:845` | `TrainerBugCatcherJosh`; force-set by `.FightDone` | |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `TM_FURY_CUTTER` (TM49) | Bugsy hands it over after the badge speech | `AzaleaGymBugsyScript.FightDone` -> `verbosegiveitem TM_FURY_CUTTER` | `EVENT_GOT_TM49_FURY_CUTTER` |

**Trainers**

Base rewards: `BUG_CATCHER` 4 (`data/trainers/attributes.asm:215`),
`TWINS` 5 (`:365`), `BUGSY` 25 (`:17`). Money = base x last-mon level x 4.

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `AMYANDMAY1` | `TWINS` | `constants/trainer_constants.asm:621` | `TwinsGroup` TWINS(1) "AMY & MAY@", `TRAINERTYPE_NORMAL`: L10 `SPINARAK`, L10 `LEDYBA` | `TrainerTwinsAmyandmay1` | no (200 = 5x10x4) |
| `AMYANDMAY2` | `TWINS` | `constants/trainer_constants.asm:624` | `TwinsGroup` TWINS(4) "AMY & MAY@", `TRAINERTYPE_NORMAL`: L10 `LEDYBA`, L10 `SPINARAK` | `TrainerTwinsAmyandmay2` | no (200) |
| `JOSH` | `BUG_CATCHER` | `constants/trainer_constants.asm:319` | `BugCatcherGroup` BUG_CATCHER(7) "JOSH@", `TRAINERTYPE_NORMAL`: L13 `PARAS` | `TrainerBugCatcherJosh` | no (208 = 4x13x4) |
| `BENNY` | `BUG_CATCHER` | `constants/trainer_constants.asm:317` | `BugCatcherGroup` BUG_CATCHER(5) "BENNY@", `TRAINERTYPE_NORMAL`: L7 `WEEDLE`, L9 `KAKUNA`, L12 `BEEDRILL` | `TrainerBugCatcherBenny` | no (192 = 4x12x4) |
| `AL` | `BUG_CATCHER` | `constants/trainer_constants.asm:318` | `BugCatcherGroup` BUG_CATCHER(6) "AL@", `TRAINERTYPE_NORMAL`: L12 `CATERPIE`, L12 `WEEDLE` | `TrainerBugCatcherAl` | no (192 = 4x12x4) |
| `BUGSY1` | `BUGSY` (class 3, `constants/trainer_constants.asm:33`) | `:34` | `BugsyGroup` "BUGSY@", **`TRAINERTYPE_MOVES`**: L14 `METAPOD` (`TACKLE`, `STRING_SHOT`, `HARDEN`), L14 `KAKUNA` (`POISON_STING`, `STRING_SHOT`, `HARDEN`), L16 `SCYTHER` (`QUICK_ATTACK`, `LEER`, `FURY_CUTTER`) | `AzaleaGymBugsyScript` | no (1600 = 25x16x4) |

Bugsy's AI/items row (`data/trainers/attributes.asm:17`): `NO_ITEM, NO_ITEM`,
`AI_BASIC | AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_CAUTIOUS | AI_STATUS | AI_RISKY`,
`CONTEXT_USE | SWITCH_SOMETIMES`. Bug Catchers are `AI_BASIC | AI_SETUP | AI_STATUS`;
Twins are `NO_AI` with `SWITCH_OFTEN`.

**Wild encounters** - none (indoor).

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Rocket standing on the Slowpoke Well approach | `maps/AzaleaTown.asm` object const 2 at `31, 9`, flag `EVENT_AZALEA_TOWN_SLOWPOKETAIL_ROCKET`. `31, 9` is the only walkable neighbour of `31, 8`, which is the only walkable neighbour of the ladder at `31, 7` (derived from `maps/AzaleaTown.blk` + `data/tilesets/johto_modern_collision.asm`) | talk to Kurt once | `Kurt1` first-visit arm runs `setevent EVENT_AZALEA_TOWN_SLOWPOKETAIL_ROCKET`, which hides him (`Script_disappear` semantics, `engine/overworld/scripting.asm:887`) |
| Rocket standing on the Azalea Gym door | `maps/AzaleaTown.asm` object const 12 at `10, 16`, flag `EVENT_SLOWPOKE_WELL_ROCKETS`. `10, 16` is the only walkable neighbour of the gym warp at `10, 15` | clear Slowpoke Well | the four `disappear SLOWPOKEWELLB1F_ROCKET*` calls in `maps/SlowpokeWellB1F.asm` `TrainerGruntM1.Script` set that shared flag |
| Slowpoke Well B2F (King's Rock, TM Rain Dance) | `maps/SlowpokeWellB1F.asm` warp 2 at `7, 11`; the chamber's only outside neighbour is water at `7, 14` (derived from `maps/SlowpokeWellB1F.blk` + `data/tilesets/cave_collision.asm` + `data/collision/collision_permissions.asm`) | Surf (`ENGINE_FOGBADGE` + HM03) | out of section - Fog Badge is Morty |
| Boulder at Slowpoke Well `3, 2` | `SlowpokeWellB1FBoulder` -> `jumpstd StrengthBoulderScript` | Strength | out of section; nothing behind it is required |
| Field Cut (leaving Azalea west for Ilex Forest) | `engine/events/overworld.asm` `CutFunction.CheckAble` (`ld de, ENGINE_HIVEBADGE` / `call CheckBadge` / `jr c, .nohivebadge`, sym `03:47e1`) and `TryCutOW` (`CheckPartyMove` with `CUT`, then `ld de, ENGINE_HIVEBADGE` / `CheckEngineFlag`, sym `03:5193`) | HIVEBADGE **and** a party member that knows CUT | HIVEBADGE from `AzaleaGymBugsyScript`; HM01 itself comes from the Charcoal Kiln / Ilex Forest chain in section 05 |
| Pokemon obedience above L30 | `engine/battle/core.asm:6566` masks `(1 << ZEPHYRBADGE) | (1 << HIVEBADGE) | ...` | HIVEBADGE | same |
| Bugsy himself | `AzaleaGymBugsyScript` has no `checkevent` guard before the battle | nothing - the five gym trainers are optional | `.FightDone` force-sets all four of their beat events afterwards |

## 4. Bot checklist

Coordinates are `x, y` as written in the asm. "warp N" means the Nth
`warp_event` row of the source map.

1. `MAP_AZALEA_TOWN`, walk in from the Route 33 east connection. Post: engine
   flag `ENGINE_FLYPOINT_AZALEA` set by `AzaleaTownFlypointCallback`
   (`MAPCALLBACK_NEWMAP`). No input needed.
2. `MAP_AZALEA_TOWN`, walk to `9, 5` and step on it -> warp 4 ->
   `MAP_KURTS_HOUSE` `3, 7`. Pre: none.
3. `MAP_KURTS_HOUSE`, walk to `3, 3`, face UP, press A on object const 2
   (`KURTSHOUSE_KURT1`, `3, 2`). Pre: `EVENT_CLEARED_SLOWPOKE_WELL` clear and
   `EVENT_KURT_GAVE_YOU_LURE_BALL` clear. Post:
   `EVENT_AZALEA_TOWN_SLOWPOKETAIL_ROCKET` set, `EVENT_KURTS_HOUSE_KURT_1` set
   (Kurt walks out). If the player is facing UP when the script starts, Kurt
   takes the `.RunAround` movement instead - same result, one extra step.
4. `MAP_KURTS_HOUSE`, step on `3, 7` or `4, 7` -> `MAP_AZALEA_TOWN` warp 4 (`9, 5`).
5. Optional heal: `MAP_AZALEA_TOWN` `15, 9` -> `MAP_AZALEA_POKECENTER_1F`;
   talk to object const 2 at `3, 1` (`jumpstd PokecenterNurseScript`); leave via
   `3, 7`.
6. `MAP_AZALEA_TOWN`, walk east along row 10 to `31, 10`, north to `31, 9`
   (now empty), `31, 8`, then step on `31, 7` -> warp 6 -> `MAP_SLOWPOKE_WELL_B1F`
   `17, 15`. Optional: from `31, 7` face UP and press A for the hidden
   `FULL_HEAL` at `31, 6` (post: `EVENT_AZALEA_TOWN_HIDDEN_FULL_HEAL`).
7. `MAP_SLOWPOKE_WELL_B1F`, optional A on const 8 (`16, 14`, Kurt).
8. Walk north along column 15 to `15, 8`. Trigger: const 2 `TrainerGruntM29`
   (sight 1, faces right). Battle `GRUNTM` / `GRUNTM_29` (L9 Rattata x2).
   Post: `EVENT_BEAT_ROCKET_GRUNTM_29`. Optional A again for the after-battle text.
9. Continue north column 14 to `14, 4`, then west into the top room. Trigger:
   const 5 `TrainerGruntF1` at `13, 2` (sight 2, faces down) from `13, 3` or
   `13, 4`. Battle `GRUNTF` / `GRUNTF_1` (L9 Zubat, L11 Ekans). Post:
   `EVENT_BEAT_ROCKET_GRUNTF_1`.
10. Walk to `11, 3` -> `10, 3`, press A on const 10 -> `SUPER_POTION`. Post:
    `EVENT_SLOWPOKE_WELL_B1F_SUPER_POTION`.
11. Go to `11, 4` -> `11, 5` -> `11, 6`, then west along row 6. Trigger: const 4
    `TrainerGruntM2` at `5, 6` (sight 2, faces right) from `7, 6` or `6, 6`.
    Battle `GRUNTM` / `GRUNTM_2` (L7 Rattata, L9 Zubat, L9 Zubat). Post:
    `EVENT_BEAT_ROCKET_GRUNTM_2`.
12. Optional: `7, 5` face UP, A on const 6 at `7, 4` (Slowpoke with mail,
    `yesorno` -> read). No flag.
13. Walk to `5, 3`. Trigger: const 3 `TrainerGruntM1` at `5, 2` (sight 1, faces
    down). Battle `GRUNTM` / `GRUNTM_1` (L14 Koffing). Post:
    `EVENT_BEAT_ROCKET_GRUNTM_1`, then `.Script` runs with no `endifjustbattled`,
    so the whole cutscene plays automatically and ends with
    `special HealParty` + `warp KURTS_HOUSE, 3, 3`. Post-flags to assert:
    `EVENT_CLEARED_SLOWPOKE_WELL`, `EVENT_SLOWPOKE_WELL_ROCKETS`,
    `EVENT_SLOWPOKE_WELL_SLOWPOKES`, `EVENT_SLOWPOKE_WELL_KURT`,
    `EVENT_CHARCOAL_KILN_FARFETCH_D`, `EVENT_CHARCOAL_KILN_APPRENTICE`;
    cleared: `EVENT_AZALEA_TOWN_SLOWPOKES`, `EVENT_KURTS_HOUSE_SLOWPOKE`,
    `EVENT_KURTS_HOUSE_KURT_1`, `EVENT_ILEX_FOREST_APPRENTICE`,
    `EVENT_ILEX_FOREST_FARFETCHD_1`; scene: `AZALEA_TOWN` -> `SCENE_AZALEATOWN_RIVAL_BATTLE`.
14. `MAP_KURTS_HOUSE` at `3, 3`, face UP, A on const 2. Pre:
    `EVENT_CLEARED_SLOWPOKE_WELL` set, `EVENT_KURT_GAVE_YOU_LURE_BALL` clear.
    Post: `LURE_BALL` in bag, `EVENT_KURT_GAVE_YOU_LURE_BALL` set. The script
    then falls straight into the apricorn prompt - answer no unless you want to
    hand over the White Apricorn you have not picked yet.
15. Leave via `3, 7`; in `MAP_AZALEA_TOWN` walk to `8, 3`, face UP, A on const 10
    at `8, 2` -> `WHT_APRICORN` (daily). Optional: return to Kurt and give it
    (`special SelectApricornForKurt`, post: `EVENT_GAVE_KURT_WHT_APRICORN` +
    `ENGINE_KURT_MAKING_BALLS`), then come back a real in-game day later for
    `FAST_BALL`.
16. Optional heal at the Pokecenter (`15, 9`).
17. `MAP_AZALEA_TOWN`, walk to `10, 17` -> `10, 16` (now empty) -> step on
    `10, 15` -> warp 5 -> `MAP_AZALEA_GYM` `4, 15`.
18. `MAP_AZALEA_GYM`: optional A on const 8 at `7, 13` for the type hint.
    Walk `4, 14` -> `4, 13` -> `4, 12` -> `4, 11`. Trigger: const 6
    `TrainerTwinsAmyandmay1` at `4, 10` (sight 1). Battle `TWINS` / `AMYANDMAY1`
    (L10 Spinarak, L10 Ledyba). Post: `EVENT_BEAT_TWINS_AMY_AND_MAY`, which also
    retires const 7.
19. West along row 11 to `0, 11`, north up column 0 to `0, 5`. Trigger: const 5
    `TrainerBugCatcherJosh` at `0, 2` (sight 3, faces down). Battle
    `BUG_CATCHER` / `JOSH` (L13 Paras). Post: `EVENT_BEAT_BUG_CATCHER_JOSH`.
20. North to `0, 3`, east along row 3 toward `4, 3`. Trigger: const 3
    `TrainerBugCatcherBenny` at `5, 3` (sight 2, spins). Battle
    `BUG_CATCHER` / `BENNY` (L7 Weedle, L9 Kakuna, L12 Beedrill). Post:
    `EVENT_BEAT_BUG_CATCHER_BENNY`.
21. East along row 2/3 to column 8-9, south to `8, 11`. Trigger: const 4
    `TrainerBugCatcherAl` at `8, 8` (sight 3, faces down). Battle
    `BUG_CATCHER` / `AL` (L12 Caterpie, L12 Weedle). Post:
    `EVENT_BEAT_BUG_CATCHER_AL`.
22. Route into the middle: `4, 3` or `5, 3` row -> `4, 4` -> `4, 5` -> `3, 5` ->
    `3, 6` -> `3, 7` -> `4, 7`, face RIGHT, A on const 2 at `5, 7`. Pre:
    `EVENT_BEAT_BUGSY` clear. Battle `BUGSY` / `BUGSY1` (L14 Metapod, L14 Kakuna,
    L16 Scyther). Post: `EVENT_BEAT_BUGSY`, `ENGINE_HIVEBADGE`, then the same
    conversation continues and yields `TM_FURY_CUTTER` +
    `EVENT_GOT_TM49_FURY_CUTTER` and force-sets the four gym-trainer events.
    A bot that wants the badge fast can skip steps 19-21 entirely.
23. Leave via `4, 15` / `5, 15`. Next section starts when you walk west and hit
    `coord_event 5, 10` / `5, 11`.

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map data for all six maps (blocks, connections, warps, coord/bg/object events, `scriptKey`) | `src/import/RomExtractorGen2.lua` (`self:write("maps", out)`, line 987), consumed by `src/world/gen2/Map.lua` | implemented - `docs/gold-phase1.md` states all 368 maps extract |
| Collision / walkability (`COLL_*` quads, block -> cell) | `src/world/gen2/Map.lua` `Map:cellCollision`, `src/world/gen2/Permissions.lua` | implemented (quad order `ly*2 + lx` matches `gfx/tilesets.asm` `tilecoll`) |
| Warps between these maps | `src/world/gen2/World.lua` + `Map:warpAt`; driver `tests/drivers/gold_warp_scene.lua` | implemented |
| Map callbacks (`MAPCALLBACK_NEWMAP` flypoint, `MAPCALLBACK_OBJECTS` Kurt swap) | `src/world/gen2/World.lua`, driver `tests/drivers/gold_map_callbacks.lua` | implemented |
| Script VM opcodes used here (`checkevent`/`setevent`/`clearevent`, `checkflag`/`setflag`, `readvar`, `scall`, `jumpstd`, `special`, `warp`, `setscene`/`setmapscene`, `loadtrainer`/`startbattle`/`winlosstext`/`endifjustbattled`, `applymovement`, `moveobject`, `showemote`, `variablesprite`, `verbosegiveitem`, `yesorno`, `checkitem`, `promptbutton`, `fruittree`) | `src/script/gen2/Opcodes.lua`, `src/script/gen2/Vm.lua` | implemented - every opcode in this section's scripts has a row and a VM arm |
| Specials used here (`FadeOutToBlack`, `FadeInFromBlack`, `FadeOutToWhite`, `ReloadSpritesNoPalettes`, `HealParty`, `SelectApricornForKurt`, `FadeOutMusic`/`RestartMapMusic`) | `src/script/gen2/Specials.lua` | implemented (spot-checked `FadeOutToBlack`, `ReloadSpritesNoPalettes`, `HealParty`, `SelectApricornForKurt`) |
| Trainer sight lines / approach walk (the four grunts, the five gym trainers) | `src/world/gen2/Trainers.lua` (`Trainers.sees`, `Trainers.approach`), wired at `src/world/gen2/World.lua:5212-5264`; driver `tests/drivers/gold_trainer_smoke.lua` | implemented |
| Trainer parties + class attributes | `src/import/RomExtractorGen2.lua` (trainers), `src/world/gen2/Trainers.lua`, `src/battle/gen2/Battle.lua` (`BUGSY` in the gym-leader set, line 85) | implemented |
| Prize money (base x level x 4, Mom's split) | `src/battle/gen2/Prize.lua` | implemented, and it ports the `ld c, 4` loop and `.DoubleReward` faithfully |
| Badge storage + `VAR_BADGES` count | `src/core/gen2/Save.lua` (`player.badges`, `player.kantoBadges`), `src/world/gen2/World.lua:1241-1244`, `World:engineFlags` (`:1304`) | implemented |
| Cut gate on `ENGINE_HIVEBADGE` | `src/world/gen2/FieldMoves.lua` (`FieldMoves.BADGE.CUT = "HIVE"`, `cutFromMenu`, the overworld ask path) | implemented |
| Fly point `ENGINE_FLYPOINT_AZALEA` | `src/world/gen2/FieldMoves.lua:347` (`LANDMARK_AZALEA_TOWN` / `SPAWN_AZALEA` / flag 67) | implemented |
| Hidden item at `31, 6` (`BGEVENT_ITEM`) | `src/world/gen2/HiddenItems.lua` | implemented (module exists and the extractor carries `hiddenItem = { item, event }`); not exercised by any Azalea driver |
| Kurt / apricorn conversation, `ENGINE_KURT_MAKING_BALLS` day wait, Lure Ball, Fast Ball | `src/core/gen2/Apricorns.lua` | implemented at the model level; the file is written against `maps/KurtsHouse.asm` directly and lists `FRUITTREE_AZALEA_TOWN` -> `WHT_APRICORN` at index `0x14` |
| Item balls (`OBJECTTYPE_ITEMBALL`: Super Potion at B1F `10, 3`, TM Rain Dance at B2F `15, 5`) | extracted by `src/import/RomExtractorGen2.lua:2968`; **no runtime handler found in `src/world/gen2/World.lua`** | **missing** - the object data is there, nothing picks it up |
| `fruittree` at runtime (White Apricorn tree object) | opcode row exists (`src/script/gen2/Opcodes.lua`, `[0x9a]`) and `Vm.lua` references it; the daily-tree store is described in `src/core/gen2/Apricorns.lua` (`save.fruitTrees`) | partial - modelled, not verified end to end in a driver |
| Wild encounters for Slowpoke Well (grass 3-slot time split, water, fishing) | `src/import/RomExtractorGen2.lua` (Encounters), `src/battle/gen2/Encounter.lua` | implemented per `docs/gold-phase1.md`; not verified for this map specifically |
| A driver that walks any part of this section | none - `tests/drivers/gold_*.lua` has nothing matching azalea / slowpoke / kurt / bugsy | **missing** |

## 6. Unresolved / verify by hand

- **Bug Catcher Al's prize.** The walkthrough says 200G. The asm gives
  4 (`data/trainers/attributes.asm:215`) x 12 (last mon, L12 Weedle) x 4 = **192G**.
  Every other figure in the section matches the formula exactly
  (360 / 440 / 360 / 560 / 200 / 208 / 192 / 1600), so this looks like a
  walkthrough typo, not a special case.
- **Bugsy's gender.** The walkthrough says "Bugsy and her apprentices" and
  "she may have the Bug Pokemon". `AzaleaGymGuideText` in `maps/AzaleaGym.asm`
  says "BUGSY's young, but **his** knowledge of bug #MON is for real". The asm
  wins.
- **"Liz the Picnicker calls about Moo Moo Milk."** `LizPhoneCallerScript`
  (`engine/phone/scripts/trainers.asm:234-254`) only does
  `PhoneScript_GreetPhone_Female`, a `checkflag ENGINE_FLYPOINT_GOLDENROD`
  rematch gate, `PhoneScript_Random2` and `Phone_GenericCall_Female` /
  `Phone_CheckIfUnseenRare_Female`. There is no Moo Moo Milk text in her script,
  and no `MOOMOO` string turned up anywhere under `engine/phone/`. The generic
  call pool may contain such a line, but it is not attributable to Liz from the
  map/phone scripts - unresolved.
- **"TM49" listed under *Items found in Azalea Town*.** TM49 is
  `verbosegiveitem TM_FURY_CUTTER` inside `AzaleaGymBugsyScript`, i.e. found in
  `MAP_AZALEA_GYM`, not on the town map. Cosmetic, but a bot indexing by map
  should not look for it outdoors.
- **Battle order inside Slowpoke Well.** The walkthrough's "move on up the
  stairs", "head down the stairs" prose does not correspond to any `LADDER` or
  `STAIRCASE` collision inside B1F - the only two ladder cells are the two warps
  (`17, 15` and `7, 11`). The trainer order it describes (M29 -> F1 -> M2 -> M1)
  does match the geometry, so the "stairs" are just prose for the corridors.
- **`SLOWPOKE_WELL_B2F` reachability.** I derived "Surf only" from
  `maps/SlowpokeWellB1F.blk` decoded against `data/tilesets/cave_collision.asm`
  and `data/collision/collision_permissions.asm`; no script or engine check
  states it. If a future reader wants a stronger citation, it would have to come
  from the block data, not from an `EVENT_*`.
- **Gym-trainer skippability.** The claim that Josh, Al and (via the column-7
  stalk) the twins can be walked past is derived from `maps/AzaleaGym.blk` plus
  each object's sight field, not asserted anywhere in the asm. The retroactive
  `setevent` block in `AzaleaGymBugsyScript.FightDone` is direct asm evidence
  that skipping them is an anticipated state, but the exact dodge path should be
  confirmed in-game before a driver depends on it.
- **`variablesprite SPRITE_AZALEA_ROCKET, SPRITE_RIVAL`.** This is why
  `AZALEATOWN_RIVAL` is declared with `SPRITE_AZALEA_ROCKET` in
  `maps/AzaleaTown.asm`. It also means consts 2 and 12 on that map would draw as
  the rival if they were still visible after the well is cleared - they are not,
  because both are hidden by then. Worth a look if a port ever renders them.

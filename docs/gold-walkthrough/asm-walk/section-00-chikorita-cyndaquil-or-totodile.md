# Section 00 - Chikorita, Cyndaquil, or Totodile?

Source: `../section-00-chikorita-cyndaquil-or-totodile.txt`
Maps covered: `MAP_PLAYERS_HOUSE_2F`, `MAP_PLAYERS_HOUSE_1F`, `MAP_NEW_BARK_TOWN`, `MAP_ELMS_LAB`
Badges / key milestones in this section: no badge. Milestones are the new-game
clock set, the #GEAR from Mom (`ENGINE_POKEGEAR`), the first rival encounter,
and the starter (`EVENT_GOT_A_POKEMON_FROM_ELM`), which is what un-gates the
walk west out of New Bark Town.

Coordinate note: every `warp_event` / `coord_event` / `bg_event` /
`object_event` x,y below is copied verbatim from the map asm. Those are 0-based
walk-grid cells (2 per map block, so a `W`-block-wide map runs x = 0..2W-1),
which is the same grid `src/world/gen2/Map.lua` calls a cell.

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 0 | (no map) | `engine/menus/intro_menu.asm` `NewGame` / `OakSpeech`, `engine/rtc/timeset.asm` `InitClock` | title screen -> NEW GAME | `InitializeWorld` -> `SPAWN_HOME` | "Choose new game and start… Professor Oak will ask you the time… he asks you what your name is" |
| 1 | `MAP_PLAYERS_HOUSE_2F` | `maps/PlayersHouse2F.asm` | spawn `SPAWN_HOME` at (3,3), `data/maps/spawn_points.asm` | warp 1 at (7,0) | "You are in your room at the beginning. Exit the room" |
| 2 | `MAP_PLAYERS_HOUSE_1F` | `maps/PlayersHouse1F.asm` | warp 3 at (9,0) | warp 1 (6,7) or warp 2 (7,7) | "you will meet your mom… You get the Pokegear… input the day of the week" |
| 3 | `MAP_NEW_BARK_TOWN` | `maps/NewBarkTown.asm` | warp 2 at (13,5) | warp 1 at (6,3) | "Leave your house and head left to Professor Elm's lab. Notice the guy standing left of it" (rival at (3,2)) |
| 4 | `MAP_ELMS_LAB` | `maps/ElmsLab.asm` | warp 1 (4,11) / warp 2 (5,11) | warp 1/2 back to New Bark Town | "go into Elm's lab… You get to pick your starter Pokémon" |
| 5 | `MAP_NEW_BARK_TOWN` | `maps/NewBarkTown.asm` | warp 1 at (6,3) | west connection to `ROUTE_29` (`data/maps/attributes.asm`) | section ends here; the walk west to Route 29 / Cherrygrove belongs to section 01 |

## 2. Maps

### MAP_PLAYERS_HOUSE_2F

- Script: `maps/PlayersHouse2F.asm`
- Blocks: `maps/PlayersHouse2F.blk`
- Header (`data/maps/maps.asm:478`): `map PlayersHouse2F, TILESET_PLAYERS_ROOM, INDOOR, LANDMARK_NEW_BARK_TOWN, MUSIC_NEW_BARK_TOWN, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:443`): `map_const PLAYERS_HOUSE_2F, 4, 3` (4x3 blocks = 8x6 cells)
- Connections: none (indoor)
- Scene var: `wPlayersHouse2FSceneID` is *not* in `data/maps/scenes.asm`; the map has an empty `def_scene_scripts`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 7 | 0 | `PLAYERS_HOUSE_1F` | 3 |

**Coord events** (`def_coord_events`)

None (the block is empty).

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 2 | 1 | `BGEVENT_UP` | `PlayersHousePCScript` |
| 3 | 1 | `BGEVENT_READ` | `PlayersHouseRadioScript` |
| 5 | 1 | `BGEVENT_READ` | `PlayersHouseBookshelfScript` |
| 6 | 0 | `BGEVENT_IFSET` | `PlayersHousePosterScript` (guarded by `EVENT_PLAYERS_ROOM_POSTER`) |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `PLAYERSHOUSE2F_CONSOLE` | `SPRITE_CONSOLE` | 4 | 2 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `PlayersHouseGameConsoleScript` | `EVENT_PLAYERS_HOUSE_2F_CONSOLE` |
| `PLAYERSHOUSE2F_DOLL_1` | `SPRITE_DOLL_1` | 4 | 4 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `PlayersHouseDoll1Script` | `EVENT_PLAYERS_HOUSE_2F_DOLL_1` |
| `PLAYERSHOUSE2F_DOLL_2` | `SPRITE_DOLL_2` | 5 | 4 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `PlayersHouseDoll2Script` | `EVENT_PLAYERS_HOUSE_2F_DOLL_2` |
| `PLAYERSHOUSE2F_BIG_DOLL` | `SPRITE_BIG_DOLL` | 0 | 1 | `SPRITEMOVEDATA_BIGDOLL` | `OBJECTTYPE_SCRIPT` | `PlayersHouseBigDollScript` | `EVENT_PLAYERS_HOUSE_2F_BIG_DOLL` |

**Scripts of interest**

- `PlayersHouse2FInitializeRoomCallback` (`callback MAPCALLBACK_NEWMAP`): runs
  `special ToggleDecorationsVisibility`, sets
  `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_8` (read by `engine/phone/scripts/mom.asm`),
  then `checkevent EVENT_INITIALIZED_EVENTS` -> if clear,
  `jumpstd InitializeEventsScript`. This is the one-time world seeding for a new
  game: `engine/events/std_scripts.asm:438` sets ~70 `EVENT_*` bits including
  `EVENT_COP_IN_ELMS_LAB` (which *hides* the officer), `EVENT_RIVAL_CHERRYGROVE_CITY`,
  `EVENT_ROUTE_30_YOUNGSTER_JOEY`, and finally `EVENT_INITIALIZED_EVENTS`
  (`engine/events/std_scripts.asm:557`) so it never runs again.
- `PlayersHouse2FSetUpTileDecorationsCallback` (`callback MAPCALLBACK_TILES`):
  `special ToggleMaptileDecorations`.
- `PlayersHouseRadioScript`: three-branch. Before `EVENT_GOT_A_POKEMON_FROM_ELM`
  it plays `MUSIC_POKEMON_TALK`, prints four texts and sets
  `EVENT_LISTENED_TO_INITIAL_RADIO`; after that flag it prints only
  `PlayersRadioText4`; after `EVENT_GOT_A_POKEMON_FROM_ELM` it becomes the normal
  `jumpstd Radio1Script`. Purely flavour, no gate.
- `PlayersHousePCScript`: `special PlayersHousePC`, `iftrue .Warp` -> `warp NONE, 0, 0`
  (the "leave the PC by warping in place" reload).

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_INITIALIZED_EVENTS` | `constants/event_flags.asm:63` | read by `PlayersHouse2FInitializeRoomCallback`, set by `InitializeEventsScript` | first-load-only world seed; must be clear on a fresh save |
| `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_8` | `constants/event_flags.asm` | set here, read by `engine/phone/scripts/mom.asm:13` | "player is at home right now" |
| `EVENT_LISTENED_TO_INITIAL_RADIO` | `constants/event_flags.asm:468` | `PlayersHouseRadioScript` | shortens the radio text on repeat |
| `EVENT_PLAYERS_ROOM_POSTER` | `constants/event_flags.asm:378` | `conditional_event` in `PlayersHousePosterScript` | decoration present |

**Items**: none on this map.

**Trainers**: none.

**Wild encounters**: none (indoor).

### MAP_PLAYERS_HOUSE_1F

- Script: `maps/PlayersHouse1F.asm`
- Blocks: `maps/PlayersHouse1F.blk`
- Header (`data/maps/maps.asm:477`): `map PlayersHouse1F, TILESET_PLAYERS_HOUSE, INDOOR, LANDMARK_NEW_BARK_TOWN, MUSIC_NEW_BARK_TOWN, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:442`): `map_const PLAYERS_HOUSE_1F, 5, 4` (10x8 cells)
- Connections: none (indoor)
- Scene var: `wPlayersHouse1FSceneID` (`data/maps/scenes.asm:30`). Scene ids come
  from declaration order in `def_scene_scripts` (`macros/scripts/maps.asm:25`):
  `SCENE_PLAYERSHOUSE1F_MEET_MOM` = 0, `SCENE_PLAYERSHOUSE1F_NOOP` = 1. A new game
  zeroes the scene, so scene 0 is live on the first visit.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 6 | 7 | `NEW_BARK_TOWN` | 2 |
| 2 | 7 | 7 | `NEW_BARK_TOWN` | 2 |
| 3 | 9 | 0 | `PLAYERS_HOUSE_2F` | 1 |

**Coord events** (`def_coord_events`)

None. The Mom cutscene is a **scene script**, not a coord event: `scene_script
PlayersHouse1FMeetMomScene, SCENE_PLAYERSHOUSE1F_MEET_MOM` -> `sdefer MeetMomScript`,
so it fires on map entry from the stairs while the scene id is still 0.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `PlayersHouse1FStoveScript` |
| 1 | 1 | `BGEVENT_READ` | `PlayersHouse1FSinkScript` |
| 2 | 1 | `BGEVENT_READ` | `PlayersHouse1FFridgeScript` |
| 4 | 1 | `BGEVENT_READ` | `PlayersHouse1FTVScript` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `PLAYERSHOUSE1F_MOM1` | `SPRITE_MOM` | 7 | 3 | `SPRITEMOVEDATA_STANDING_LEFT` (time `-1`) | `OBJECTTYPE_SCRIPT` | `MomScript` | `EVENT_PLAYERS_HOUSE_MOM_1` |
| `PLAYERSHOUSE1F_MOM2` | `SPRITE_MOM` | 2 | 2 | `SPRITEMOVEDATA_STANDING_UP` (time `MORN`) | `OBJECTTYPE_SCRIPT` | `MomScript` | `EVENT_PLAYERS_HOUSE_MOM_2` |
| `PLAYERSHOUSE1F_MOM3` | `SPRITE_MOM` | 7 | 3 | `SPRITEMOVEDATA_STANDING_LEFT` (time `DAY`) | `OBJECTTYPE_SCRIPT` | `MomScript` | `EVENT_PLAYERS_HOUSE_MOM_2` |
| `PLAYERSHOUSE1F_MOM4` | `SPRITE_MOM` | 0 | 2 | `SPRITEMOVEDATA_STANDING_UP` (time `NITE`) | `OBJECTTYPE_SCRIPT` | `MomScript` | `EVENT_PLAYERS_HOUSE_MOM_2` |

Note the object flags are inverted relative to intuition: a *set* event flag hides
the object. Mom1 is the cutscene Mom (visible while `EVENT_PLAYERS_HOUSE_MOM_1`
is clear); `MeetMomScript` ends by setting `EVENT_PLAYERS_HOUSE_MOM_1` and
clearing `EVENT_PLAYERS_HOUSE_MOM_2`, which swaps in the three time-of-day Moms
on the next map load.

**Scripts of interest**

- `MeetMomScript` (the whole Pokegear beat, `maps/PlayersHouse1F.asm:21`):
  1. `applymovement PLAYER, PlayersHouseDownstairsMovement` (one `step DOWN`, i.e. off the stair tile).
  2. `playmusic MUSIC_MOM`, `turnobject PLAYERSHOUSE1F_MOM1, UP`, `showemote EMOTE_SHOCK, PLAYERSHOUSE1F_MOM1, 15`.
  3. `applymovement PLAYERSHOUSE1F_MOM1, MomWalksToPlayerMovement` (`slow_step RIGHT, RIGHT, UP`: (7,3) -> (9,2), beside the player at (9,1)).
  4. `writetext ElmsLookingForYouText`, `getstring STRING_BUFFER_4, PokegearName` ("#GEAR"), `scall PlayersHouse1FReceiveItemStd` -> `jumpstd ReceiveItemScript` (`engine/events/std_scripts.asm:656`).
  5. `setflag ENGINE_POKEGEAR`, `setflag ENGINE_PHONE_CARD`, `addcellnum PHONE_MOM`.
  6. `setscene SCENE_PLAYERSHOUSE1F_NOOP`, `setevent EVENT_PLAYERS_HOUSE_MOM_1`, `clearevent EVENT_PLAYERS_HOUSE_MOM_2`.
  7. `special SetDayOfWeek`, then the DST loop: `IsItDSTText` -> `yesorno` -> `special InitialSetDSTFlag` / `special InitialClearDSTFlag`, each confirmed by a second `yesorno` that loops back to `.SetDayOfWeek` on "no".
  8. Phone-instructions branch (`.KnowPhone` / `.ExplainPhone`, both fall into `.FinishPhone`), then `applymovement PLAYERSHOUSE1F_MOM1, MomWalksBackMovement` and `special RestartMapMusic`.
  Crucially the #GEAR is **not** an inventory item: it is two engine flags. There
  is no `giveitem` in this script.
- `MomScript` (talking to Mom afterwards): checks, in order,
  `EVENT_FIRST_TIME_BANKING_WITH_MOM` -> `EVENT_TALKED_TO_MOM_AFTER_MYSTERY_EGG_QUEST`
  -> `EVENT_GAVE_MYSTERY_EGG_TO_ELM` -> `EVENT_GOT_A_POKEMON_FROM_ELM`; in this
  section all four are clear so it prints `HurryUpElmIsWaitingText`. The
  `special BankOfMom` path is not reachable yet.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_POKEGEAR` | `constants/engine_flags.asm:8` | set by `MeetMomScript` | Pokegear menu becomes usable |
| `ENGINE_PHONE_CARD` | `constants/engine_flags.asm:6` | set by `MeetMomScript` | Pokegear PHONE card unlocked |
| `EVENT_PLAYERS_HOUSE_MOM_1` | `constants/event_flags.asm:1129` | set by `MeetMomScript` | hides the cutscene Mom |
| `EVENT_PLAYERS_HOUSE_MOM_2` | `constants/event_flags.asm:1130` | cleared by `MeetMomScript` | reveals the time-of-day Moms |
| `SCENE_PLAYERSHOUSE1F_MEET_MOM` (0) / `SCENE_PLAYERSHOUSE1F_NOOP` (1) | `maps/PlayersHouse1F.asm:9-10` | `setscene` at step 6 | scene 0 must be live exactly once |
| `PHONE_MOM` | `constants/phone_constants.asm` (via `addcellnum`) | `MeetMomScript` | Mom's number in the Pokegear |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| POKEGEAR (not an item - `ENGINE_POKEGEAR` + `ENGINE_PHONE_CARD`) | Mom cutscene | `MeetMomScript` | `EVENT_PLAYERS_HOUSE_MOM_1` / `SCENE_PLAYERSHOUSE1F_NOOP` |

**Trainers**: none.

**Wild encounters**: none (indoor).

### MAP_NEW_BARK_TOWN

- Script: `maps/NewBarkTown.asm`
- Blocks: `maps/NewBarkTown.blk`
- Header (`data/maps/maps.asm:475`): `map NewBarkTown, TILESET_JOHTO, TOWN, LANDMARK_NEW_BARK_TOWN, MUSIC_NEW_BARK_TOWN, FALSE, PALETTE_AUTO, FISHGROUP_OCEAN`
- Dimensions (`constants/map_constants.asm:440`): `map_const NEW_BARK_TOWN, 10, 9` (20x18 cells)
- Connections (`data/maps/attributes.asm:119-121`): `map_attributes NewBarkTown, NEW_BARK_TOWN, $05`, `connection west, Route29, ROUTE_29, 0`, `connection east, Route27, ROUTE_27, 0`
- Scene var: `wNewBarkTownSceneID` (`data/maps/scenes.asm:28`).
  `SCENE_NEWBARKTOWN_TEACHER_STOPS_YOU` = 0, `SCENE_NEWBARKTOWN_NOOP` = 1.
- Fly point / spawn: `NewBarkTownFlypointCallback` sets `ENGINE_FLYPOINT_NEW_BARK`
  (`constants/engine_flags.asm:79`) on every `MAPCALLBACK_NEWMAP`, and also
  `clearevent EVENT_FIRST_TIME_BANKING_WITH_MOM`. `SPAWN_NEW_BARK` is
  (13,6) in `data/maps/spawn_points.asm:27`.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 6 | 3 | `ELMS_LAB` | 1 |
| 2 | 13 | 5 | `PLAYERS_HOUSE_1F` | 1 |
| 3 | 3 | 11 | `PLAYERS_NEIGHBORS_HOUSE` | 1 |
| 4 | 11 | 13 | `ELMS_HOUSE` | 1 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_NEWBARKTOWN_TEACHER_STOPS_YOU` (0) | 1 | 8 | `NewBarkTown_TeacherStopsYouScene1` | teacher walks 4x LEFT to (2,8), `follow`s the player and drags them back 4x RIGHT |
| `SCENE_NEWBARKTOWN_TEACHER_STOPS_YOU` (0) | 1 | 9 | `NewBarkTown_TeacherStopsYouScene2` | same, 5 steps, teacher ends at (1,8) facing DOWN |

These two cells are the entire west-exit gate. There is no coord event on the
east side.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 8 | 8 | `BGEVENT_READ` | `NewBarkTownSign` |
| 11 | 5 | `BGEVENT_READ` | `NewBarkTownPlayersHouseSign` |
| 3 | 3 | `BGEVENT_READ` | `NewBarkTownElmsLabSign` |
| 9 | 13 | `BGEVENT_READ` | `NewBarkTownElmsHouseSign` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `NEWBARKTOWN_TEACHER` | `SPRITE_TEACHER` | 6 | 8 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `NewBarkTownTeacherScript` | `-1` (always visible) |
| `NEWBARKTOWN_FISHER` | `SPRITE_FISHER` | 12 | 9 | `SPRITEMOVEDATA_WALK_UP_DOWN`, `PAL_NPC_GREEN` | `OBJECTTYPE_SCRIPT` | `NewBarkTownFisherScript` | `-1` |
| `NEWBARKTOWN_RIVAL` | `SPRITE_RIVAL` | 3 | 2 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `NewBarkTownRivalScript` | `EVENT_RIVAL_NEW_BARK_TOWN` |

**Scripts of interest**

- `NewBarkTownRivalScript` (the "he'll push you out of the way" beat): no
  `faceplayer`. Prints `NewBarkTownRivalText1` ("So this is the famous ELM #MON
  LAB…"), `turnobject NEWBARKTOWN_RIVAL, LEFT`, prints `NewBarkTownRivalText2`,
  then `follow PLAYER, NEWBARKTOWN_RIVAL` +
  `applymovement PLAYER, NewBarkTown_RivalPushesYouAwayMovement` (`turn_head UP`,
  `step DOWN`), `stopfollow`, `turnobject NEWBARKTOWN_RIVAL, DOWN`,
  `playsound SFX_TACKLE`, `applymovement PLAYER, NewBarkTown_RivalShovesYouOutMovement`
  (`fix_facing`, `jump_step DOWN`), and the rival steps RIGHT back to (3,2).
  **It sets no flag** - it is repeatable and skippable. `EVENT_RIVAL_NEW_BARK_TOWN`
  is only set much later, at `maps/MrPokemonsHouse.asm:122`.
- `NewBarkTown_TeacherStopsYouScene1/2`: the "It's dangerous to go out without a
  #MON!" block. Ends with `special RestartMapMusic` and does **not** change the
  scene, so it re-fires every time you step on (1,8)/(1,9) until the scene id is
  changed from Elm's Lab.
- `NewBarkTownTeacherScript`: four-way text branch on
  `EVENT_TALKED_TO_MOM_AFTER_MYSTERY_EGG_QUEST` / `EVENT_GAVE_MYSTERY_EGG_TO_ELM` /
  `EVENT_GOT_A_POKEMON_FROM_ELM`; flavour only.
- `NewBarkTownFlypointCallback`: `setflag ENGINE_FLYPOINT_NEW_BARK` on first entry.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `SCENE_NEWBARKTOWN_TEACHER_STOPS_YOU` (0) | `maps/NewBarkTown.asm:8` | cleared to `SCENE_NEWBARKTOWN_NOOP` by `ElmDirectionsScript`'s `setmapscene NEW_BARK_TOWN, SCENE_NEWBARKTOWN_NOOP` | the west-exit gate |
| `EVENT_RIVAL_NEW_BARK_TOWN` | `constants/event_flags.asm:1119` | set at `maps/MrPokemonsHouse.asm:122` | rival object hidden once set; clear (visible) all through this section |
| `ENGINE_FLYPOINT_NEW_BARK` | `constants/engine_flags.asm:79` | `NewBarkTownFlypointCallback` | Fly destination registered |
| `EVENT_FIRST_TIME_BANKING_WITH_MOM` | `constants/event_flags.asm` | cleared by `NewBarkTownFlypointCallback` | not reachable this section |

**Items**: none. See "Unresolved" for the Everstone.

**Trainers**: none. The rival encounter here is a conversation, not a battle.

**Wild encounters**

- No `def_grass_wildmons NEW_BARK_TOWN` entry exists in `data/wild/johto_grass.asm`.
- Water (`data/wild/johto_water.asm:211`): `def_water_wildmons NEW_BARK_TOWN`,
  `db 6 percent`, `db 20, TENTACOOL` / `db 15, TENTACOOL` / `db 20, TENTACRUEL`.
  Needs Surf, unreachable this section.
- Fishing: the header's `FISHGROUP_OCEAN` selects
  `data/wild/fish.asm` `.Ocean_Old` (Magikarp 10 / Magikarp 10 / Tentacool 10),
  `.Ocean_Good`, `.Ocean_Super`. No rod yet.
- Headbutt: `data/wild/treemon_maps.asm:28` `treemon_map NEW_BARK_TOWN, TREEMON_SET_CITY`
  -> `data/wild/treemons.asm:18` `TreeMonSet_City` (Venonat/Abra/Venomoth common,
  Venonat/Magnemite/Abra/Venomoth rare, all L15). Needs TM02, far later.

### MAP_ELMS_LAB

- Script: `maps/ElmsLab.asm`
- Blocks: `maps/ElmsLab.blk`
- Header (`data/maps/maps.asm:476`): `map ElmsLab, TILESET_LAB, INDOOR, LANDMARK_NEW_BARK_TOWN, MUSIC_PROF_ELM, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:441`): `map_const ELMS_LAB, 5, 6` (10x12 cells)
- Connections: none (indoor)
- Scene var: `wElmsLabSceneID` (`data/maps/scenes.asm:29`). Declaration order
  gives `SCENE_ELMSLAB_MEET_ELM` = 0, `SCENE_ELMSLAB_CANT_LEAVE` = 1,
  `SCENE_ELMSLAB_NOOP` = 2, `SCENE_ELMSLAB_MEET_OFFICER` = 3,
  `SCENE_ELMSLAB_UNUSED` = 4, `SCENE_ELMSLAB_AIDE_GIVES_POTION` = 5,
  `SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS` = 6 (the last one is a bare
  `scene_const`, no script row).

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 11 | `NEW_BARK_TOWN` | 1 |
| 2 | 5 | 11 | `NEW_BARK_TOWN` | 1 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_ELMSLAB_CANT_LEAVE` (1) | 4 | 6 | `LabTryToLeaveScript` | Elm turns DOWN, `LabWhereGoingText`, `applymovement PLAYER, ElmsLab_CantLeaveMovement` (one `step UP`) |
| `SCENE_ELMSLAB_CANT_LEAVE` (1) | 5 | 6 | `LabTryToLeaveScript` | same |
| `SCENE_ELMSLAB_MEET_OFFICER` (3) | 4 | 5 | `MeetCopScript` | post-theft, next section |
| `SCENE_ELMSLAB_MEET_OFFICER` (3) | 5 | 5 | `MeetCopScript2` | post-theft, next section |
| `SCENE_ELMSLAB_AIDE_GIVES_POTION` (5) | 4 | 8 | `AideScript_WalkPotion1` | aide walks 2x RIGHT, gives POTION, walks back |
| `SCENE_ELMSLAB_AIDE_GIVES_POTION` (5) | 5 | 8 | `AideScript_WalkPotion2` | aide walks 3x RIGHT, gives POTION, walks back |
| `SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS` (6) | 4 | 8 | `AideScript_WalkBalls1` | 5x POKE_BALL, next section |
| `SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS` (6) | 5 | 8 | `AideScript_WalkBalls2` | 5x POKE_BALL, next section |

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 2 | 1 | `BGEVENT_READ` | `ElmsLabHealingMachine` |
| 6 | 1 | `BGEVENT_READ` | `ElmsLabBookshelf` |
| 7 | 1 | `BGEVENT_READ` | `ElmsLabBookshelf` |
| 8 | 1 | `BGEVENT_READ` | `ElmsLabBookshelf` |
| 9 | 1 | `BGEVENT_READ` | `ElmsLabBookshelf` |
| 0 | 7 | `BGEVENT_READ` | `ElmsLabTravelTip1` |
| 1 | 7 | `BGEVENT_READ` | `ElmsLabTravelTip2` |
| 2 | 7 | `BGEVENT_READ` | `ElmsLabTravelTip3` |
| 3 | 7 | `BGEVENT_READ` | `ElmsLabTravelTip4` |
| 6 | 7 | `BGEVENT_READ` | `ElmsLabBookshelf` |
| 7 | 7 | `BGEVENT_READ` | `ElmsLabBookshelf` |
| 8 | 7 | `BGEVENT_READ` | `ElmsLabBookshelf` |
| 9 | 7 | `BGEVENT_READ` | `ElmsLabBookshelf` |
| 9 | 3 | `BGEVENT_READ` | `ElmsLabTrashcan` |
| 5 | 0 | `BGEVENT_READ` | `ElmsLabWindow` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ELMSLAB_ELM` | `SPRITE_ELM` | 5 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `ProfElmScript` | `-1` |
| `ELMSLAB_ELMS_AIDE` | `SPRITE_SCIENTIST` | 2 | 9 | `SPRITEMOVEDATA_SPINRANDOM_SLOW`, `PAL_NPC_BLUE` | `OBJECTTYPE_SCRIPT` | `ElmsAideScript` | `EVENT_ELMS_AIDE_IN_LAB` |
| `ELMSLAB_POKE_BALL1` | `SPRITE_POKE_BALL` | 6 | 3 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `CyndaquilPokeBallScript` | `EVENT_CYNDAQUIL_POKEBALL_IN_ELMS_LAB` |
| `ELMSLAB_POKE_BALL2` | `SPRITE_POKE_BALL` | 7 | 3 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `TotodilePokeBallScript` | `EVENT_TOTODILE_POKEBALL_IN_ELMS_LAB` |
| `ELMSLAB_POKE_BALL3` | `SPRITE_POKE_BALL` | 8 | 3 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `ChikoritaPokeBallScript` | `EVENT_CHIKORITA_POKEBALL_IN_ELMS_LAB` |
| `ELMSLAB_OFFICER` | `SPRITE_OFFICER` | 5 | 3 | `SPRITEMOVEDATA_STANDING_UP`, `PAL_NPC_BLUE` | `OBJECTTYPE_SCRIPT` | `CopScript` | `EVENT_COP_IN_ELMS_LAB` |

The ball order on screen is left-to-right **Cyndaquil (6,3), Totodile (7,3),
Chikorita (8,3)** - not the Pokedex order the walkthrough's title uses. The
officer is hidden all through this section because `InitializeEventsScript`
*sets* `EVENT_COP_IN_ELMS_LAB` (`engine/events/std_scripts.asm:469`).

**Scripts of interest**

- `ElmsLabMeetElmScene` (scene 0) -> `sdefer ElmsLabWalkUpToElmScript`:
  `applymovement PLAYER, ElmsLab_WalkUpToElmMovement` (nine `step UP` then
  `turn_head RIGHT`, i.e. from the door at (4,11) up to (4,2) beside Elm at
  (5,2)), `turnobject ELMSLAB_ELM, LEFT`, `writetext ElmText_Intro` (the Mr.
  Pokemon errand speech), then `setscene SCENE_ELMSLAB_CANT_LEAVE`.
- `CyndaquilPokeBallScript` / `TotodilePokeBallScript` / `ChikoritaPokeBallScript`:
  identical shape. `checkevent EVENT_GOT_A_POKEMON_FROM_ELM` -> if set, just
  `LookAtElmPokeBallScript`. Otherwise `turnobject ELMSLAB_ELM, DOWN`,
  `reanchormap`, `pokepic <SPECIES>`, `cry <SPECIES>`, `closepokepic`,
  `writetext Take<Species>Text`, `yesorno`; `iffalse DidntChooseStarterScript`
  (fully cancellable, nothing is written). On yes:
  `disappear ELMSLAB_POKE_BALL<n>`, `setevent EVENT_GOT_<SPECIES>_FROM_ELM`,
  `ChoseStarterText`, `getmonname STRING_BUFFER_3`, `ReceivedStarterText`,
  `playsound SFX_CAUGHT_MON`, then **`givepoke <SPECIES>, 5, BERRY`** - level 5,
  holding a BERRY. Finally an `applymovement` that walks the player to (5,3),
  directly below Elm, and `sjump ElmDirectionsScript`:
  - Cyndaquil: `readvar VAR_FACING` / `ifequal RIGHT, ElmDirectionsScript` (skips the walk if you took it from the left side), else `AfterCyndaquilMovement` = LEFT, UP.
  - Totodile: `AfterTotodileMovement` = LEFT, LEFT, UP.
  - Chikorita: `AfterChikoritaMovement` = LEFT, LEFT, LEFT, UP.
- `ElmDirectionsScript` - the one script that opens the section up:
  `turnobject PLAYER, UP`, three Elm texts, `addcellnum PHONE_ELM`,
  `playsound SFX_REGISTER_PHONE_NUMBER`, then
  `setevent EVENT_GOT_A_POKEMON_FROM_ELM`,
  `setevent EVENT_RIVAL_CHERRYGROVE_CITY`,
  `setscene SCENE_ELMSLAB_AIDE_GIVES_POTION`,
  `setmapscene NEW_BARK_TOWN, SCENE_NEWBARKTOWN_NOOP`.
  That last opcode is what removes the teacher gate.
- `AideScript_GivePotion` (reached by the (4,8)/(5,8) coord events once the scene
  is 5): `writetext AideText_GiveYouPotion`, `verbosegiveitem POTION`,
  `AideText_AlwaysBusy`, `setscene SCENE_ELMSLAB_NOOP`. One-shot, gated by the
  scene id rather than an event flag.
- `LabTryToLeaveScript`: the "you cannot walk out yet" push-back described above.
- `ElmsLabHealingMachine` (bg_event at (2,1)): before
  `EVENT_GOT_A_POKEMON_FROM_ELM` it just prints text; after, it offers a
  `yesorno` -> `special HealParty`, `setval HEALMACHINE_ELMS_LAB`,
  `special HealMachineAnim`. Free healing point for a bot from this section on.
- `ProfElmScript`: long check chain. In this section every branch falls through
  to `writetext ElmText_LetYourMonBattleIt` (after the starter) or
  `ElmDescribesMrPokemonScript`. The `ElmGiveEverstoneScript` arm needs
  `EVENT_SHOWED_TOGEPI_TO_ELM`; the Master Ball arm needs `ENGINE_RISINGBADGE`;
  the S.S. Ticket arm needs `EVENT_BEAT_ELITE_FOUR`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_GOT_A_POKEMON_FROM_ELM` | `constants/event_flags.asm:35` | set by `ElmDirectionsScript`; read by the ball scripts, `MomScript`, `NewBarkTownTeacherScript`, `PlayersHouseRadioScript`, `ElmsLabHealingMachine` | the section's terminal flag |
| `EVENT_GOT_CYNDAQUIL_FROM_ELM` | `constants/event_flags.asm:36` | `CyndaquilPokeBallScript` | which starter (Totodile/Chikorita variants are the next two consts) |
| `EVENT_CYNDAQUIL_POKEBALL_IN_ELMS_LAB` | `constants/event_flags.asm:993` | `disappear ELMSLAB_POKE_BALL1` | ball object removed |
| `EVENT_TOTODILE_POKEBALL_IN_ELMS_LAB` | `constants/event_flags.asm:994` | `disappear ELMSLAB_POKE_BALL2` | ball object removed |
| `EVENT_CHIKORITA_POKEBALL_IN_ELMS_LAB` | `constants/event_flags.asm:995` | `disappear ELMSLAB_POKE_BALL3` | ball object removed |
| `EVENT_COP_IN_ELMS_LAB` | `constants/event_flags.asm:1188` | set by `InitializeEventsScript`, cleared at `maps/MrPokemonsHouse.asm:127` | officer hidden this section |
| `EVENT_ELMS_AIDE_IN_LAB` | `constants/event_flags.asm:1187` | cleared at `maps/VioletPokecenter1F.asm:31`, set at `engine/phone/scripts/elm.asm:85` | aide visible (flag clear) this section |
| `EVENT_RIVAL_CHERRYGROVE_CITY` | `constants/event_flags.asm` | set by `InitializeEventsScript` and again by `ElmDirectionsScript` | Cherrygrove rival still hidden |
| `EVENT_GOT_EVERSTONE_FROM_ELM` | `constants/event_flags.asm:95` | `ElmGiveEverstoneScript` | **not reachable in this section** |
| `SCENE_ELMSLAB_*` | `maps/ElmsLab.asm:11-17` | `setscene` / `setmapscene` | drives every coord event on the map |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `POTION` | walk onto (4,8) or (5,8) on the way out after picking a starter | `AideScript_GivePotion` (`verbosegiveitem POTION`) | `SCENE_ELMSLAB_AIDE_GIVES_POTION` -> `SCENE_ELMSLAB_NOOP` |
| starter, L5, holding `BERRY` | `givepoke` in the chosen ball script | `CyndaquilPokeBallScript` / `TotodilePokeBallScript` / `ChikoritaPokeBallScript` | `EVENT_GOT_<SPECIES>_FROM_ELM` + `EVENT_GOT_A_POKEMON_FROM_ELM` |
| `EVERSTONE` | Elm, **after** showing him a hatched Togepi | `ElmGiveEverstoneScript` (`maps/ElmsLab.asm:341`) | `EVENT_GOT_EVERSTONE_FROM_ELM` |
| `POKE_BALL` x5 | aide, after the Mystery Egg hand-off | `AideScript_GiveYouBalls` | `SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS` -> `SCENE_ELMSLAB_NOOP` |

**Trainers**: none. No `loadtrainer` / `startbattle` anywhere in
`maps/ElmsLab.asm`, `maps/NewBarkTown.asm`, `maps/PlayersHouse1F.asm` or
`maps/PlayersHouse2F.asm`.

**Wild encounters**: none (indoor).

**Starter data** (`data/pokemon/evos_attacks.asm`, checked against the
walkthrough's claims - all three match)

| species | evolves | L5 known moves | later moves the FAQ names |
|---|---|---|---|
| `CHIKORITA` | `EVOLVE_LEVEL, 16, BAYLEEF`; Bayleef `EVOLVE_LEVEL, 32, MEGANIUM` | TACKLE (1), GROWL (1) | RAZOR_LEAF 8, REFLECT 12, POISONPOWDER 15, SYNTHESIS 22, BODY_SLAM 29, LIGHT_SCREEN 36, SAFEGUARD 43, SOLARBEAM 50 |
| `CYNDAQUIL` | `EVOLVE_LEVEL, 14, QUILAVA`; Quilava `EVOLVE_LEVEL, 36, TYPHLOSION` | TACKLE (1), LEER (1) | SMOKESCREEN 6, EMBER 12, QUICK_ATTACK 19, FLAME_WHEEL 27, SWIFT 36, FLAMETHROWER 46 |
| `TOTODILE` | `EVOLVE_LEVEL, 18, CROCONAW`; Croconaw `EVOLVE_LEVEL, 30, FERALIGATR` | SCRATCH (1), LEER (1) | RAGE 7, WATER_GUN 13, BITE 20, SCARY_FACE 27, SLASH 35, SCREECH 43, HYDRO_PUMP 52 |

Note the FAQ's move lists are aspirational (they mix level-up moves with HM03 /
HM04). At the moment you receive it the starter knows exactly its two level-1
moves; Cyndaquil does **not** have Ember yet at L5.

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Clock must be set before the world exists | `engine/menus/intro_menu.asm:494` `OakSpeech` -> `farcall InitClock` (`engine/rtc/timeset.asm:4`); default hour is 10 (`ld a, 10 ; default hour = 10 AM`) | hour then minute then a `YesNoBox` confirm each | answering "yes" to both confirmations |
| Player must be named | `engine/menus/intro_menu.asm` `NamePlayer` -> `ShowPlayerNamingChoices` / `StorePlayerName` | pick a preset or type a name | any accepted name |
| Cannot walk out of Elm's Lab before the errand speech ends | `maps/ElmsLab.asm` coord events (4,6) and (5,6) under `SCENE_ELMSLAB_CANT_LEAVE`, script `LabTryToLeaveScript` | scene id must leave 1 | `ElmDirectionsScript`'s `setscene SCENE_ELMSLAB_AIDE_GIVES_POTION` - i.e. take a starter |
| Cannot leave New Bark Town west toward Route 29 | `maps/NewBarkTown.asm` coord events (1,8) and (1,9) under `SCENE_NEWBARKTOWN_TEACHER_STOPS_YOU`, scripts `NewBarkTown_TeacherStopsYouScene1/2` | scene id must leave 0 | `ElmDirectionsScript`'s `setmapscene NEW_BARK_TOWN, SCENE_NEWBARKTOWN_NOOP` |
| Aide's Potion is scene-gated, not flag-gated | `maps/ElmsLab.asm` coord events (4,8)/(5,8), `AideScript_GivePotion` | be on scene 5 and step on x=4 or 5, y=8 | script itself does `setscene SCENE_ELMSLAB_NOOP` |
| Everstone (listed by the FAQ under New Bark Town) | `maps/ElmsLab.asm:63,338-347` `ElmCheckEverstone` / `ElmGiveEverstoneScript` | `EVENT_SHOWED_TOGEPI_TO_ELM`, which needs a hatched Togepi in the party (`special FindPartyMonThatSpeciesYourTrainerID`) | many sections later |

No HM field-move gate applies in this section: nothing under
`engine/overworld/` (cut/surf/strength/whirlpool/waterfall/flash/fly) is
consulted between the bedroom and the starter.

## 4. Bot checklist

| # | Map | Target | Intent | Precondition | Postcondition |
|---|---|---|---|---|---|
| 1 | - (main menu) | NEW GAME | menu select | fresh save | `NewGame` runs `ResetWRAM` |
| 2 | - (`InitClock`) | hour, then minute, then yes/no per field | menu | in `OakSpeech` | RTC base written; default hour 10 |
| 3 | - (`NamePlayer`) | any name | naming screen | after `OakText6` | `wPlayerName` set |
| 4 | `PLAYERS_HOUSE_2F` | spawn (3,3) | - | `SPAWN_HOME` | `MAPCALLBACK_NEWMAP` runs `InitializeEventsScript` once; `EVENT_INITIALIZED_EVENTS` set |
| 5 | `PLAYERS_HOUSE_2F` | warp 1 at (7,0) | walk onto | - | now on `PLAYERS_HOUSE_1F` warp 3 (9,0) |
| 6 | `PLAYERS_HOUSE_1F` | (scene 0 auto-fires) | wait / mash A through `MeetMomScript` | `wPlayersHouse1FSceneID` == 0 | `ENGINE_POKEGEAR`, `ENGINE_PHONE_CARD`, `PHONE_MOM`, `EVENT_PLAYERS_HOUSE_MOM_1`, scene -> 1 |
| 6a | `PLAYERS_HOUSE_1F` | DST `yesorno` pair | answer, then confirm | inside `MeetMomScript` | answering "no" to the confirm loops back to `.SetDayOfWeek` - a bot must confirm, not just answer |
| 7 | `PLAYERS_HOUSE_1F` | warp 1 (6,7) or warp 2 (7,7) | walk onto | - | `NEW_BARK_TOWN` at warp 2 (13,5) |
| 8 | `NEW_BARK_TOWN` | object `NEWBARKTOWN_RIVAL` at (3,2) | talk (optional) | rival visible while `EVENT_RIVAL_NEW_BARK_TOWN` clear | pushed one cell DOWN + a `jump_step DOWN`; **no flag set**, skippable |
| 9 | `NEW_BARK_TOWN` | warp 1 at (6,3) | walk onto | avoid (1,8)/(1,9) until step 12 | `ELMS_LAB` at warp 1 (4,11) |
| 10 | `ELMS_LAB` | (scene 0 auto-fires) | wait / mash A | `wElmsLabSceneID` == 0 | player auto-walked to (4,2); scene -> 1 (`CANT_LEAVE`) |
| 11 | `ELMS_LAB` | ball object: (6,3) Cyndaquil / (7,3) Totodile / (8,3) Chikorita | face + A, answer **yes** to `yesorno` | `EVENT_GOT_A_POKEMON_FROM_ELM` clear | starter L5 w/ BERRY in party; `EVENT_GOT_<SP>_FROM_ELM`; ball disappears; auto-walk to (5,3); `ElmDirectionsScript` runs -> `EVENT_GOT_A_POKEMON_FROM_ELM`, `PHONE_ELM`, `ELMS_LAB` scene -> 5, `NEW_BARK_TOWN` scene -> 1 |
| 12 | `ELMS_LAB` | (4,8) or (5,8) | walk onto on the way out | scene == 5 | `POTION` in bag; scene -> 2 (`NOOP`) |
| 13 | `ELMS_LAB` | bg_event (2,1) | face UP + A -> yes (optional) | `EVENT_GOT_A_POKEMON_FROM_ELM` set | party healed (`special HealParty`) |
| 14 | `ELMS_LAB` | warp 1 (4,11) or warp 2 (5,11) | walk onto | - | `NEW_BARK_TOWN` (6,3) |
| 15 | `NEW_BARK_TOWN` | west edge past (1,8)/(1,9) | walk west | `NEW_BARK_TOWN` scene == 1 | crosses the `connection west, Route29` into `ROUTE_29` - section 01 |

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Title -> NEW GAME -> Oak speech -> name pick -> naming screen -> bedroom | `src/ui/gen2/TitleState.lua`, `src/ui/gen2/MainMenu.lua`, `src/ui/gen2/OakSpeech.lua`, `src/ui/gen2/NamePick.lua`, `src/ui/gen2/NamingScreen.lua`; asserted end-to-end by `tests/drivers/gold_boot_smoke.lua` | implemented |
| `InitClock` (the "what time is it?" / minute screens) | none - `src/ui/gen2/OakSpeech.lua:3` says outright "Gender select / InitClock are Crystal-later" | **missing** (bot step 2 has no screen to drive) |
| `SPAWN_HOME` start at `PLAYERS_HOUSE_2F` (3,3) | `src/world/gen2/World.lua:228-232` (`START_MAP = "PLAYERS_HOUSE_2F"`, cites `data/maps/spawn_points.asm`) | implemented |
| Map load, warps, collision, connections | `src/world/gen2/Map.lua`, `src/world/gen2/World.lua`; `tests/drivers/gold_walk_smoke.lua`, `tests/drivers/gold_warp_scene.lua` (asserts the New Bark door lands on `ELMS_LAB`) | implemented |
| Scene scripts + coord events (the mechanism every gate in this section uses) | `src/world/gen2/World.lua:5011-5035` (`coordEvents` scan filtered by `self:scene()`, `sceneScripts` lookup), extracted by `src/import/RomExtractorGen2.lua:804-977` | implemented |
| `MAPCALLBACK_NEWMAP` / `MAPCALLBACK_TILES`, `ToggleDecorationsVisibility`, `ToggleMaptileDecorations` | `src/script/gen2/Specials.lua:489-505`, `tests/drivers/gold_map_callbacks.lua`, `tests/gen2_map_callbacks_test.lua` | implemented |
| `MeetMomScript` (emote, follow-free walk-in, `yesorno` under a prompt, mid-scene object swap) | driven by the VM; regression driver `tests/drivers/gold_mom_scene.lua` exists specifically for this scene; the Mom object-swap timing is commented at `src/world/gen2/World.lua:558-568,730` | implemented |
| `special SetDayOfWeek` / `InitialSetDSTFlag` / `InitialClearDSTFlag` | `src/script/gen2/Specials.lua:836-860` | partial - the flags/RTC fields are written from the host clock, but no day-of-week picker UI is drawn, so the player never chooses |
| Teacher west-exit gate | `tests/drivers/gold_teacher_scene.lua` (asserts `follow` drags the player back and she stands beside them) | implemented |
| Rival push-out (`follow` + `jump_step` + `SFX_TACKLE`) | VM ops `follow`/`stopfollow` (`src/script/gen2/Opcodes.lua:117-118`), movement in `src/script/gen2/Movement.lua` | partial - opcodes present, no driver covering `NewBarkTownRivalScript` specifically |
| Starter pick: `pokepic`, `cry`, `yesorno`, `disappear`, `givepoke SP, 5, BERRY` | `src/script/gen2/Opcodes.lua:91-92,51`; `src/script/gen2/Vm.lua:386-394` (`pokepic` -> `showPicFn`), `:439-445` (`givepoke` -> `givePokeFn` with species/level/held item) | partial - all opcodes implemented, but no driver or test in `tests/drivers/gold_*.lua` walks the Elm's Lab starter choice end to end |
| `verbosegiveitem POTION` (aide) | `src/script/gen2/Vm.lua:490-510` (received text, SFX, "put in the ITEM POCKET") | implemented |
| `addcellnum PHONE_MOM` / `PHONE_ELM`, Pokegear phone card | `src/script/gen2/Vm.lua:611`, `src/core/gen2/Phone.lua:137,146`, `src/ui/gen2/Pokegear.lua` | implemented |
| `special HealParty` / `HealMachineAnim` (lab healing machine) | `src/script/gen2/Specials.lua:456` | implemented |
| `special PlayersHousePC` + `warp NONE, 0, 0` | `src/script/gen2/Specials.lua:467-487`, `src/ui/gen2/PcMenu.lua` | implemented |
| `special NameRival` (fires next section, from `CopScript`) | `src/script/gen2/Specials.lua:825-828` -> `World:nameRival` (`src/world/gen2/World.lua:4931`) | implemented |
| Event-flag bitfield semantics (set flag = object hidden) | `src/world/gen2/Events.lua` (header comment cites `CheckObjectFlag` in `map_objects_2.asm`) | implemented |

## 6. Unresolved / verify by hand

- **Everstone.** The FAQ lists "Everstone" under "Items found in New Bark Town".
  There is no Everstone item ball, hidden item or bg_event on `MAP_NEW_BARK_TOWN`,
  `MAP_ELMS_LAB`, `MAP_PLAYERS_HOUSE_1F` or `MAP_PLAYERS_HOUSE_2F`. The only New
  Bark Town Everstone is `ElmGiveEverstoneScript` (`maps/ElmsLab.asm:338-347`),
  which requires `EVENT_SHOWED_TOGEPI_TO_ELM` - a hatched Togepi shown to Elm,
  many sections later. Treat the FAQ line as forward-looking, not as an item to
  collect here.
- **"Pokegear" as an item.** The FAQ says "You get the Pokegear". In the asm it is
  `setflag ENGINE_POKEGEAR` + `setflag ENGINE_PHONE_CARD`, with the item name
  faked through `getstring STRING_BUFFER_4, PokegearName` ("#GEAR") into the
  standard `ReceiveItemScript` text. Nothing enters the bag - a bot must not
  check inventory for it.
- **"Professor Oak will ask you the time. First answer what hour it is and what
  minute it is."** `InitClock` (`engine/rtc/timeset.asm`) is reached from
  `OakSpeech` *before* any Oak text is printed (`farcall InitClock` is the first
  instruction of `OakSpeech`), so the clock screen actually comes first and Oak's
  greeting second. The FAQ's ordering is the reverse.
- **"even if you don't have the GBA on, the time will keep running"** - an RTC
  hardware claim, nothing in the disassembly to cite; ignore.
- **East exit toward Route 27.** `data/maps/attributes.asm:121` gives New Bark Town
  a `connection east, Route27, ROUTE_27, 0`, and unlike the west side there is
  *no* coord event guarding it. Whether a bot can actually walk east before
  getting Surf depends on the shoreline tiles in `maps/NewBarkTown.blk`, which I
  did not decode. Verify by hand before relying on the west gate as the only exit
  block.
- **Teacher gate coverage.** Only (1,8) and (1,9) carry coord events. If the map's
  west connection strip is reachable at any other y, the gate has a hole. I read
  the coord table but not the collision data, so this is unverified.
- **Rival battle.** The FAQ says only that he pushes you; confirmed - there is no
  `loadtrainer`/`startbattle` in `NewBarkTownRivalScript`. The first rival battle
  is not in this section.

# Section 03 - Ruins of Alph and Union Cave

Source: `../section-03-ruins-of-alph-and-union-cave.txt`
Maps covered: `MAP_VIOLET_POKECENTER_1F`, `MAP_ROUTE_36_RUINS_OF_ALPH_GATE`,
`MAP_RUINS_OF_ALPH_OUTSIDE`, `MAP_RUINS_OF_ALPH_KABUTO_CHAMBER`,
`MAP_RUINS_OF_ALPH_INNER_CHAMBER`, `MAP_RUINS_OF_ALPH_RESEARCH_CENTER`,
`MAP_RUINS_OF_ALPH_AERODACTYL_CHAMBER` (Surf-gated), `MAP_ROUTE_32_RUINS_OF_ALPH_GATE`,
`MAP_ROUTE_32`, `MAP_ROUTE_32_POKECENTER_1F`, `MAP_UNION_CAVE_1F`,
`MAP_UNION_CAVE_B1F`, `MAP_UNION_CAVE_B2F` (Strength/Surf-gated), `MAP_ROUTE_33`

Badges / key milestones in this section:

- Togepi EGG from Elm's Aide (`EVENT_GOT_TOGEPI_EGG_FROM_ELMS_AIDE`) - this is the
  real unlock for the section: it flips Route 32's scene off the blocking one.
- First Unown puzzle solved (`EVENT_SOLVED_KABUTO_PUZZLE`,
  `ENGINE_UNLOCKED_UNOWNS_A_TO_K`) - makes Unown spawnable at all.
- UNOWN #DEX mode (`ENGINE_UNOWN_DEX`) from the Research Center.
- MIRACLE_SEED, TM05 ROAR, OLD_ROD, POISON_BARB (Friday), TM39 SWIFT.
- No badge is earned in this stretch. The section ends walking west out of
  Route 33 into Azalea Town.

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `MAP_VIOLET_CITY` | `maps/VioletCity.asm` | leaving Violet Gym (warp 2 at 18,17) | warp 5 at `31, 25` -> `VIOLET_POKECENTER_1F` 1 | Elm phones about "something important at the Pokemon Center" |
| 2 | `MAP_VIOLET_POKECENTER_1F` | `maps/VioletPokecenter1F.asm` | warp 1/2 at `3, 7` / `4, 7` | same warps back to `VIOLET_CITY` 5 | take the Togepi EGG from Elm's Aide |
| 3 | `MAP_VIOLET_CITY` | `maps/VioletCity.asm` | back out of the Center | **west connection** -> `Route36` (offset 0) | "head west ... until you enter Route 36" |
| 4 | `MAP_ROUTE_36` | `maps/Route36.asm` | Violet City west connection | warp 3/4 at `47, 13` / `48, 13` -> `ROUTE_36_RUINS_OF_ALPH_GATE` 1/2 | pass through; the Sudowoodo tree at `35, 9` is a later section |
| 5 | `MAP_ROUTE_36_RUINS_OF_ALPH_GATE` | `maps/Route36RuinsOfAlphGate.asm` | warp 1/2 at `4, 0` / `5, 0` | warp 3/4 at `4, 7` / `5, 7` -> `RUINS_OF_ALPH_OUTSIDE` 9 | "the route-changing station" |
| 6 | `MAP_RUINS_OF_ALPH_OUTSIDE` | `maps/RuinsOfAlphOutside.asm` | warp 9 at `7, 5` | warp 2 at `14, 7` -> `RUINS_OF_ALPH_KABUTO_CHAMBER` 1 | "enter the first cave on the right" |
| 7 | `MAP_RUINS_OF_ALPH_KABUTO_CHAMBER` | `maps/RuinsOfAlphKabutoChamber.asm` | warp 1/2 at `3, 9` / `4, 9` | warp 3/4 at `3, 3` / `4, 3` -> `RUINS_OF_ALPH_INNER_CHAMBER` 4/5 (the floor holes) | solve the Kabuto puzzle, fall through |
| 8 | `MAP_RUINS_OF_ALPH_INNER_CHAMBER` | `maps/RuinsOfAlphInnerChamber.asm` | warps 4/5 at `15, 3` / `16, 3` | warp 1 at `10, 13` -> `RUINS_OF_ALPH_OUTSIDE` 5 | catch Unown; "the lower passageway eventually leads up to a ladder" |
| 9 | `MAP_RUINS_OF_ALPH_OUTSIDE` | `maps/RuinsOfAlphOutside.asm` | warp 5 at `10, 13` | coord_event at `11, 14` or `10, 15` -> scientist cutscene -> warp 6 at `17, 11` | 3+ Unown letters caught -> assistant walks you to the lab |
| 10 | `MAP_RUINS_OF_ALPH_RESEARCH_CENTER` | `maps/RuinsOfAlphResearchCenter.asm` | warp 1/2 at `2, 7` / `3, 7` | same warps -> `RUINS_OF_ALPH_OUTSIDE` 6 | UNOWN #DEX upgrade (`ENGINE_UNOWN_DEX`) |
| 11 | `MAP_RUINS_OF_ALPH_OUTSIDE` | `maps/RuinsOfAlphOutside.asm` | warp 6 at `17, 11` | warp 10/11 at `13, 20` / `13, 21` -> `ROUTE_32_RUINS_OF_ALPH_GATE` 1/2 | "go south, and then east ... another route changing house" |
| 12 | `MAP_ROUTE_32_RUINS_OF_ALPH_GATE` | `maps/Route32RuinsOfAlphGate.asm` | warp 1/2 at `0, 4` / `0, 5` | warp 3/4 at `9, 4` / `9, 5` -> `ROUTE_32` 2/3 | "Welcome to Route 32" |
| 13 | `MAP_ROUTE_32` | `maps/Route32.asm` | warp 2/3 at `4, 2` / `4, 3` | warp 4 at `6, 79` -> `UNION_CAVE_1F` 4 | the whole trainer gauntlet; detours north into Violet City (connection) for the PRZCureBerry tree and to warp 1 at `11, 73` for the Pokemon Center |
| 14 | `MAP_ROUTE_32_POKECENTER_1F` | `maps/Route32Pokecenter1F.asm` | warp 1/2 at `3, 7` / `4, 7` | same warps -> `ROUTE_32` 1 | heal; Fishing Guru hands over the OLD_ROD |
| 15 | `MAP_UNION_CAVE_1F` | `maps/UnionCave1F.asm` | warp 4 at `17, 3` | warp 1 at `5, 19` -> `UNION_CAVE_B1F` 3 | "go up and down the ladder" |
| 16 | `MAP_UNION_CAVE_B1F` | `maps/UnionCaveB1F.asm` | warp 3 at `7, 19` | warp 4 at `3, 33` -> `UNION_CAVE_1F` 2 | TM39 SWIFT at `2, 16`, X DEFEND at `17, 23` |
| 17 | `MAP_UNION_CAVE_1F` | `maps/UnionCave1F.asm` | warp 2 at `3, 33` | warp 3 at `17, 31` -> `ROUTE_33` 1 | Awakening at `12, 33`, Firebreather Ray at `16, 31`, out the east door |
| 18 | `MAP_ROUTE_33` | `maps/Route33.asm` | warp 1 at `11, 9` | **west connection** -> `AzaleaTown` (offset 0) | PSNCureBerry tree, Hiker Anthony, then into Azalea Town |

Deferred re-visits the walkthrough flags but does not do yet:

- `RUINS_OF_ALPH_AERODACTYL_CHAMBER` (outside warp 4 at `16, 33`) needs Surf across
  the outside water.
- `UNION_CAVE_B2F` (B1F warp 5 at `17, 31`) needs the Strength boulder at B1F
  `7, 10` and gives the Friday-only Lapras.
- `UNION_CAVE_B1F` warps 1/2 at `3, 3` / `3, 11` lead back out to
  `RUINS_OF_ALPH_OUTSIDE` warps 7/8 (`6, 19`, `6, 27`) - "the entrance to more of
  the Ruins of Alph" the walkthrough mentions.

Spill into the next section: Route 33's west connection lands in Azalea Town; stop
there.

---

## 2. Maps

### MAP_VIOLET_POKECENTER_1F

Only the EGG beat is in scope here; Violet City itself belongs to section 02.

- Script: `maps/VioletPokecenter1F.asm`
- Header: `data/maps/maps.asm:256` -> `TILESET_POKECENTER, INDOOR,
  LANDMARK_VIOLET_CITY, MUSIC_POKEMON_CENTER, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm` group `VIOLET` (10), id 6, `5, 4`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `VIOLET_CITY` | 5 |
| 2 | 4 | 7 | `VIOLET_CITY` | 5 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VIOLETPOKECENTER1F_NURSE` | `SPRITE_NURSE` | 3 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `VioletPokecenterNurse` | -1 |
| `VIOLETPOKECENTER1F_SUPER_NERD` | `SPRITE_SUPER_NERD` | 7 | 6 | `WALK_LEFT_RIGHT` | `OBJECTTYPE_SCRIPT` | `VioletPokecenter1FSuperNerdScript` | -1 |
| `VIOLETPOKECENTER1F_GENTLEMAN` | `SPRITE_GENTLEMAN` | 1 | 4 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `VioletPokecenter1FGentlemanScript` | -1 |
| `VIOLETPOKECENTER1F_YOUNGSTER` | `SPRITE_YOUNGSTER` | 8 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `VioletPokecenter1FYoungsterScript` | -1 |
| `VIOLETPOKECENTER1F_ELMS_AIDE` | `SPRITE_SCIENTIST` | 4 | 3 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `VioletPokecenter1F_ElmsAideScript` | `EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER` |

**Scripts of interest**

- `VioletPokecenter1F_ElmsAideScript` - `faceplayer` / `opentext`; if
  `EVENT_REFUSED_TO_TAKE_EGG_FROM_ELMS_AIDE` it re-asks with a different text.
  `yesorno`; on yes it reads `VAR_PARTYCOUNT` and bails to `.PartyFull` at
  `PARTY_LENGTH`, otherwise `giveegg TOGEPI, EGG_LEVEL`, then
  `setevent EVENT_GOT_TOGEPI_EGG_FROM_ELMS_AIDE`,
  `clearevent EVENT_ELMS_AIDE_IN_LAB`, `clearevent EVENT_TOGEPI_HATCHED`, and
  crucially `setmapscene ROUTE_32, SCENE_ROUTE32_OFFER_SLOWPOKETAIL`. It then
  branches on `VAR_FACING` (`UP` -> walk around the player) and `disappear`s.
- The aide only exists because `engine/phone/scripts/elm.asm:84` (`ElmPhoneCallerScript`
  `.assistant`) does `clearevent EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER` /
  `setevent EVENT_ELMS_AIDE_IN_LAB`. That call is armed by
  `maps/VioletGym.asm:38` `specialphonecall SPECIALCALL_ASSISTANT` after Falkner.
  `engine/events/std_scripts.asm:468` sets `EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER`
  at new game, and a set object event flag means the object is hidden
  (`Script_appear` clears, `Script_disappear` sets - `engine/overworld/scripting.asm:879-898`).

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER` | `constants/event_flags.asm:1186` | set by `InitializeEventsScript`, cleared by Elm's `.assistant` phone call | aide object visible only while CLEAR |
| `EVENT_REFUSED_TO_TAKE_EGG_FROM_ELMS_AIDE` | `constants/event_flags.asm:53` | `VioletPokecenter1F_ElmsAideScript` | second-ask text |
| `EVENT_GOT_TOGEPI_EGG_FROM_ELMS_AIDE` | `constants/event_flags.asm:54` | set here; read by `Route32CooltrainerMScript` | precondition for the Miracle Seed |
| `EVENT_TOGEPI_HATCHED` | `constants/event_flags.asm:93` | cleared here | egg-hatch bookkeeping |
| `SPECIALCALL_ASSISTANT` | `constants/phone_constants.asm:47` | `maps/VioletGym.asm:38` | the phone call that spawns the aide |

---

### MAP_ROUTE_36_RUINS_OF_ALPH_GATE

- Script: `maps/Route36RuinsOfAlphGate.asm`
- Header: `data/maps/maps.asm:262` -> `TILESET_GATE, GATE, LANDMARK_ROUTE_36,
  MUSIC_ROUTE_36, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm` group `VIOLET` (10), id 16, `5, 4`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 0 | `ROUTE_36` | 3 |
| 2 | 5 | 0 | `ROUTE_36` | 4 |
| 3 | 4 | 7 | `RUINS_OF_ALPH_OUTSIDE` | 9 |
| 4 | 5 | 7 | `RUINS_OF_ALPH_OUTSIDE` | 9 |

**BG events**: none. **Coord events**: none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE36RUINSOFALPHGATE_OFFICER` | `SPRITE_OFFICER` | 0 | 4 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `Route36RuinsOfAlphGateOfficerScript` | -1 |
| `ROUTE36RUINSOFALPHGATE_GRAMPS` | `SPRITE_GRAMPS` | 7 | 5 | `WANDER` (r 1,2) | `OBJECTTYPE_SCRIPT` | `Route36RuinsOfAlphGateGrampsScript` | -1 |

Both are `jumptextfaceplayer` only - no flags, no gate. The gate is walk-through.

---

### MAP_RUINS_OF_ALPH_OUTSIDE

- Script: `maps/RuinsOfAlphOutside.asm`
- Blocks: `maps/RuinsOfAlphOutside.blk`
- Header: `data/maps/maps.asm:100` -> `TILESET_JOHTO, ROUTE, LANDMARK_RUINS_OF_ALPH,
  MUSIC_UNION_CAVE, FALSE, PALETTE_AUTO, FISHGROUP_POND`
- Dimensions: `constants/map_constants.asm:87` group `DUNGEONS` (3), id 22,
  `map_const RUINS_OF_ALPH_OUTSIDE, 10, 18` (10x18 blocks = 20x36 cells)
- Connections: none (`data/maps/attributes.asm` `map_attributes RuinsOfAlphOutside,
  RUINS_OF_ALPH_OUTSIDE, $05` has no `connection` rows). Every exit is a warp.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 17 | `RUINS_OF_ALPH_HO_OH_CHAMBER` | 1 |
| 2 | 14 | 7 | `RUINS_OF_ALPH_KABUTO_CHAMBER` | 1 |
| 3 | 2 | 29 | `RUINS_OF_ALPH_OMANYTE_CHAMBER` | 1 |
| 4 | 16 | 33 | `RUINS_OF_ALPH_AERODACTYL_CHAMBER` | 1 |
| 5 | 10 | 13 | `RUINS_OF_ALPH_INNER_CHAMBER` | 1 |
| 6 | 17 | 11 | `RUINS_OF_ALPH_RESEARCH_CENTER` | 1 |
| 7 | 6 | 19 | `UNION_CAVE_B1F` | 1 |
| 8 | 6 | 27 | `UNION_CAVE_B1F` | 2 |
| 9 | 7 | 5 | `ROUTE_36_RUINS_OF_ALPH_GATE` | 3 |
| 10 | 13 | 20 | `ROUTE_32_RUINS_OF_ALPH_GATE` | 1 |
| 11 | 13 | 21 | `ROUTE_32_RUINS_OF_ALPH_GATE` | 2 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_RUINSOFALPHOUTSIDE_GET_UNOWN_DEX` (1) | 11 | 14 | `RuinsOfAlphOutsideScientistScene1` | scientist turns UP, player DOWN, then the shared cutscene |
| `SCENE_RUINSOFALPHOUTSIDE_GET_UNOWN_DEX` (1) | 10 | 15 | `RuinsOfAlphOutsideScientistScene2` | scientist turns LEFT, player RIGHT, then the shared cutscene |

Scene ids are declared inline by `scene_script` (see `macros/scripts/maps.asm:12-33`):
`SCENE_RUINSOFALPHOUTSIDE_NOOP` = 0, `SCENE_RUINSOFALPHOUTSIDE_GET_UNOWN_DEX` = 1.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 16 | 8 | `BGEVENT_READ` | `RuinsOfAlphOutsideMysteryChamberSign` |
| 12 | 16 | `BGEVENT_READ` | `RuinsOfAlphSign` |
| 18 | 12 | `BGEVENT_READ` | `RuinsOfAlphResearchCenterSign` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `RUINSOFALPHOUTSIDE_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 4 | 20 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerPsychicNathan` | -1 |
| `RUINSOFALPHOUTSIDE_SCIENTIST` | `SPRITE_SCIENTIST` | 11 | 15 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `RuinsOfAlphOutsideScientistScript` | `EVENT_RUINS_OF_ALPH_OUTSIDE_SCIENTIST` |

Note: the `object_const_def` block declares five consts (`YOUNGSTER1`, `SCIENTIST`,
`FISHER`, `YOUNGSTER2`, `YOUNGSTER3`) but only two `object_event` rows exist. The
last three consts are dead in Gold.

**Scripts of interest**

- `RuinsOfAlphOutsideScientistCallback` (`callback MAPCALLBACK_OBJECTS`) - the
  whole gate for the #DEX upgrade:
  `checkflag ENGINE_UNOWN_DEX` -> if true, `.NoScientist`;
  `checkevent EVENT_MADE_UNOWN_APPEAR_IN_RUINS` -> if false, `.NoScientist`;
  otherwise `readvar VAR_UNOWNCOUNT` / `ifgreater 2, .YesScientist`.
  `.YesScientist` does `appear RUINSOFALPHOUTSIDE_SCIENTIST` +
  `setscene SCENE_RUINSOFALPHOUTSIDE_GET_UNOWN_DEX`; `.NoScientist` does
  `disappear` + `setscene SCENE_RUINSOFALPHOUTSIDE_NOOP`.
  **"At least three different Unown" in the walkthrough is exactly `ifgreater 2`.**
- `RuinsOfAlphOutsideScientistSceneContinue` - text, `playmusic MUSIC_SHOW_ME_AROUND`,
  `follow RUINSOFALPHOUTSIDE_SCIENTIST, PLAYER`, `applymovement` along
  `RuinsOfAlphOutsideScientistWalkToLabMovement`
  (`RIGHT RIGHT RIGHT RIGHT UP UP RIGHT RIGHT UP UP`), `disappear`, `stopfollow`,
  `applymovement PLAYER, RuinsOfAlphOutsidePlayerEnterLabMovement` (`UP`),
  `setmapscene RUINS_OF_ALPH_RESEARCH_CENTER, SCENE_RUINSOFALPHRESEARCHCENTER_GET_UNOWN_DEX`,
  `warpcheck`. The player is walked into warp 6 by the script; a bot does not
  need to drive that step itself.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_RUINS_OF_ALPH_OUTSIDE_SCIENTIST` | `constants/event_flags.asm:1189` | set by `InitializeEventsScript` (`engine/events/std_scripts.asm:470`), toggled by the map callback | scientist hidden while SET |
| `EVENT_MADE_UNOWN_APPEAR_IN_RUINS` | `constants/event_flags.asm:55` | set by `RuinsOfAlphInnerChamberStrangePresenceScript` | precondition for the scientist |
| `ENGINE_UNOWN_DEX` | `constants/engine_flags.asm:21` | set by `RuinsOfAlphResearchCenterGetUnownDexScript` | once set the scientist never reappears |
| `VAR_UNOWNCOUNT` | `constants/script_constants.asm:62` (`0e`) | read here and in the Research Center | distinct Unown forms recorded |
| `SCENE_RUINSOFALPHOUTSIDE_*` | inline `scene_script` rows | callback / coord events | 0 = noop, 1 = run the scientist scene |

**Wild encounters**

`data/wild/johto_grass.asm:388` `def_grass_wildmons RUINS_OF_ALPH_OUTSIDE`, rate
`4 percent` for all three windows; morn/day/nite are identical:
`20 NATU, 22 NATU, 18 NATU, 24 NATU, 20 SMEARGLE, 22 SMEARGLE, 22 SMEARGLE`.

`data/wild/johto_water.asm:5` `def_water_wildmons RUINS_OF_ALPH_OUTSIDE`, rate
`2 percent`: `15 WOOPER, 20 QUAGSIRE, 15 QUAGSIRE`. This is the Wooper the
walkthrough points at, and it needs Surf.

Fishing group is `FISHGROUP_POND` (`data/wild/fish.asm:15` -> `.Pond_Old`:
`MAGIKARP 10, MAGIKARP 10, POLIWAG 10`).

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `NATHAN` | `PSYCHIC_T` | 1 | `PsychicGroup` `; PSYCHIC_T (1)` (line 2512): `26 GIRAFARIG` | `TrainerPsychicNathan` (`EVENT_BEAT_PSYCHIC_NATHAN`) | none |

Level 26 at this point in the game - the walkthrough silently skips him, and a bot
routed through `4, 20` will get pulled into a very lopsided fight. Sight range is 1.

`TrainerSuperNerdEricUnused` is present in the file but marked `; unreferenced`.

---

### MAP_RUINS_OF_ALPH_KABUTO_CHAMBER

- Script: `maps/RuinsOfAlphKabutoChamber.asm`
- Blocks: `maps/RuinsOfAlphPuzzleChamber.blk` (shared by all four chambers)
- Header: `data/maps/maps.asm:102` -> `TILESET_RUINS_OF_ALPH, DUNGEON,
  LANDMARK_RUINS_OF_ALPH, MUSIC_UNION_CAVE, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
  (phone service flag TRUE = phone calls suppressed)
- Dimensions: `constants/map_constants.asm:89` group `DUNGEONS` (3), id 24, `4, 5`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 9 | `RUINS_OF_ALPH_OUTSIDE` | 2 |
| 2 | 4 | 9 | `RUINS_OF_ALPH_OUTSIDE` | 2 |
| 3 | 3 | 3 | `RUINS_OF_ALPH_INNER_CHAMBER` | 4 |
| 4 | 4 | 3 | `RUINS_OF_ALPH_INNER_CHAMBER` | 5 |

Warps 3/4 are the holes in the floor; they are only reachable after the puzzle.

**Coord events**: none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 2 | 3 | `BGEVENT_READ` | `RuinsOfAlphKabutoChamberAncientReplica` |
| 5 | 3 | `BGEVENT_READ` | `RuinsOfAlphKabutoChamberAncientReplica` |
| 3 | 2 | `BGEVENT_UP` | `RuinsOfAlphKabutoChamberPuzzle` |
| 4 | 2 | `BGEVENT_UP` | `RuinsOfAlphKabutoChamberDescriptionSign` |

`BGEVENT_UP` means the player must be standing below the tile and facing UP. The
puzzle panel is the LEFT of the two (`3, 2`) - the walkthrough's "go up to the left
panel" is literal.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `RUINSOFALPHKABUTOCHAMBER_RECEPTIONIST` | `SPRITE_RECEPTIONIST` | 5 | 5 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `RuinsOfAlphKabutoChamberReceptionistScript` | `EVENT_RUINS_OF_ALPH_KABUTO_CHAMBER_RECEPTIONIST` |

Only ONE NPC is defined here. The walkthrough says "talk to the two people inside";
the asm has a single receptionist.

**Scripts of interest**

- `RuinsOfAlphKabutoChamberHiddenDoorsCallback` (`callback MAPCALLBACK_TILES`) -
  `checkevent EVENT_SOLVED_KABUTO_PUZZLE`; if false it patches the floor closed with
  `changeblock 2, 2, $01` (left floor) and `changeblock 4, 2, $02` (right floor).
  The `.blk` itself already contains the holes.
- `RuinsOfAlphKabutoChamberPuzzle` - `reanchormap`, `setval UNOWNPUZZLE_KABUTO`,
  `special UnownPuzzle`, `closetext`, `iftrue .PuzzleComplete`.
  `.PuzzleComplete` runs, in order:
  `setevent EVENT_RUINS_OF_ALPH_INNER_CHAMBER_TOURISTS` (this HIDES the three
  tourists - a set object flag means hidden),
  `setevent EVENT_SOLVED_KABUTO_PUZZLE`,
  `setflag ENGINE_UNLOCKED_UNOWNS_A_TO_K`,
  `setevent EVENT_RUINS_OF_ALPH_KABUTO_CHAMBER_RECEPTIONIST` (hides the receptionist),
  `setmapscene RUINS_OF_ALPH_INNER_CHAMBER, SCENE_RUINSOFALPHINNERCHAMBER_STRANGE_PRESENCE`,
  `earthquake 30`, `showemote EMOTE_SHOCK, PLAYER, 15`,
  `changeblock 2, 2, $18` / `changeblock 4, 2, $19` (the holes),
  `refreshmap`, `playsound SFX_STRENGTH`, `earthquake 80`, `warpcheck`.
  `warpcheck` is what drops the player through - no manual walk needed.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_SOLVED_KABUTO_PUZZLE` | `constants/event_flags.asm:334` | this script / the tiles callback | floor stays open once set |
| `ENGINE_UNLOCKED_UNOWNS_A_TO_K` | `constants/engine_flags.asm:56` | this script; read by `CheckUnownLetter` (`engine/battle/core.asm:6219`) and `ChooseWildEncounter` (`engine/overworld/wildmons.asm:341`) | letters A-K become catchable (`data/wild/unlocked_unowns.asm` `.Set_A_K`) |
| `EVENT_RUINS_OF_ALPH_KABUTO_CHAMBER_RECEPTIONIST` | `constants/event_flags.asm:1264` | this script | receptionist hidden once SET |
| `EVENT_RUINS_OF_ALPH_INNER_CHAMBER_TOURISTS` | `constants/event_flags.asm:1191` | this script | the three Inner Chamber NPCs hidden once SET |

Sibling puzzles, for completeness (same shape, different flags):

| chamber | asm | puzzle const | sets | unlocks |
|---|---|---|---|---|
| Ho-Oh | `maps/RuinsOfAlphHoOhChamber.asm` | `UNOWNPUZZLE_HO_OH` | `EVENT_SOLVED_HO_OH_PUZZLE` | `ENGINE_UNLOCKED_UNOWNS_X_TO_Z` |
| Omanyte | `maps/RuinsOfAlphOmanyteChamber.asm` | `UNOWNPUZZLE_OMANYTE` | `EVENT_SOLVED_OMANYTE_PUZZLE` | `ENGINE_UNLOCKED_UNOWNS_L_TO_R` |
| Aerodactyl | `maps/RuinsOfAlphAerodactylChamber.asm` | `UNOWNPUZZLE_AERODACTYL` | `EVENT_SOLVED_AERODACTYL_PUZZLE` (`constants/event_flags.asm:336`) | `ENGINE_UNLOCKED_UNOWNS_S_TO_W` |

---

### MAP_RUINS_OF_ALPH_AERODACTYL_CHAMBER

The Surf-gated puzzle the walkthrough defers. Included because it is the one place
the section names a field-move requirement.

- Script: `maps/RuinsOfAlphAerodactylChamber.asm`
- Header: `data/maps/maps.asm:104` -> `TILESET_RUINS_OF_ALPH, DUNGEON,
  LANDMARK_RUINS_OF_ALPH, MUSIC_UNION_CAVE, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:91` group `DUNGEONS` (3), id 26, `4, 5`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 9 | `RUINS_OF_ALPH_OUTSIDE` | 4 |
| 2 | 4 | 9 | `RUINS_OF_ALPH_OUTSIDE` | 4 |
| 3 | 3 | 3 | `RUINS_OF_ALPH_INNER_CHAMBER` | 8 |
| 4 | 4 | 3 | `RUINS_OF_ALPH_INNER_CHAMBER` | 9 |

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 2 | 3 | `BGEVENT_READ` | `RuinsOfAlphAerodactylChamberAncientReplica` |
| 5 | 3 | `BGEVENT_READ` | `RuinsOfAlphAerodactylChamberAncientReplica` |
| 3 | 2 | `BGEVENT_UP` | `RuinsOfAlphAerodactylChamberPuzzle` |
| 4 | 2 | `BGEVENT_UP` | `RuinsOfAlphAerodactylChamberDescriptionSign` |

**Object events**: `def_object_events` is empty. No receptionist here.

---

### MAP_RUINS_OF_ALPH_INNER_CHAMBER

- Script: `maps/RuinsOfAlphInnerChamber.asm`
- Blocks: `maps/RuinsOfAlphInnerChamber.blk`
- Header: `data/maps/maps.asm:105` -> `TILESET_RUINS_OF_ALPH, DUNGEON,
  LANDMARK_RUINS_OF_ALPH, MUSIC_RUINS_OF_ALPH_INTERIOR, TRUE, PALETTE_DAY,
  FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:92` group `DUNGEONS` (3), id 27, `10, 14`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 10 | 13 | `RUINS_OF_ALPH_OUTSIDE` | 5 |
| 2 | 3 | 15 | `RUINS_OF_ALPH_HO_OH_CHAMBER` | 3 |
| 3 | 4 | 15 | `RUINS_OF_ALPH_HO_OH_CHAMBER` | 4 |
| 4 | 15 | 3 | `RUINS_OF_ALPH_KABUTO_CHAMBER` | 3 |
| 5 | 16 | 3 | `RUINS_OF_ALPH_KABUTO_CHAMBER` | 4 |
| 6 | 3 | 21 | `RUINS_OF_ALPH_OMANYTE_CHAMBER` | 3 |
| 7 | 4 | 21 | `RUINS_OF_ALPH_OMANYTE_CHAMBER` | 4 |
| 8 | 15 | 24 | `RUINS_OF_ALPH_AERODACTYL_CHAMBER` | 3 |
| 9 | 16 | 24 | `RUINS_OF_ALPH_AERODACTYL_CHAMBER` | 4 |

Falling through the Kabuto holes lands you at `15, 3` / `16, 3`; the ladder out is
warp 1 at `10, 13`.

**Coord events**: none. The "strange presence" fires from the scene script, not a
coord event.

**BG events** (`def_bg_events`) - 26 identical `BGEVENT_READ,
RuinsOfAlphInnerChamberStatue` rows at:
`(2,3) (5,3) (8,3) (11,3) (14,3) (17,3) (2,8) (5,8) (8,8) (11,8) (14,8) (17,8)
(2,13) (17,13) (2,18) (5,18) (8,18) (11,18) (14,18) (17,18) (2,24) (5,24) (8,24)
(11,24) (14,24) (17,24)`. All flavour text; none are items.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `RUINSOFALPHINNERCHAMBER_FISHER` | `SPRITE_FISHER` | 3 | 7 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `RuinsOfAlphInnerChamberFisherScript` | `EVENT_RUINS_OF_ALPH_INNER_CHAMBER_TOURISTS` |
| `RUINSOFALPHINNERCHAMBER_TEACHER` | `SPRITE_TEACHER` | 14 | 13 | `WANDER` (r 1,1) | `OBJECTTYPE_SCRIPT` | `RuinsOfAlphInnerChamberTeacherScript` | `EVENT_RUINS_OF_ALPH_INNER_CHAMBER_TOURISTS` |
| `RUINSOFALPHINNERCHAMBER_GRAMPS` | `SPRITE_GRAMPS` | 11 | 19 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `RuinsOfAlphInnerChamberGrampsScript` | `EVENT_RUINS_OF_ALPH_INNER_CHAMBER_TOURISTS` |

All three share one flag, so they are all present before any puzzle is solved and
all vanish the moment one is.

**Scripts of interest**

- `RuinsOfAlphInnerChamberStrangePresenceScene` - `sdefer
  RuinsOfAlphInnerChamberStrangePresenceScript`. The deferred script prints
  "There is a strange presence here...", then
  `setscene SCENE_RUINSOFALPHINNERCHAMBER_NOOP` and
  `setevent EVENT_MADE_UNOWN_APPEAR_IN_RUINS`. Scene ids: `NOOP` = 0,
  `STRANGE_PRESENCE` = 1.

**Wild encounters**

`data/wild/johto_grass.asm:416` `def_grass_wildmons RUINS_OF_ALPH_INNER_CHAMBER`,
rate `6 percent` all windows, all 21 slots `db 5, UNOWN`. The level is always 5,
identical morn/day/nite.

Two gates sit on top of that table:

- `ChooseWildEncounter` (`engine/overworld/wildmons.asm:337-347`): after the species
  is picked, `cp UNOWN` / `ld a, [wUnlockedUnowns]` / `and a` / `jr z, .nowildbattle` -
  with no puzzle solved, `wUnlockedUnowns` is 0 and Unown encounters are silently
  cancelled, so the Inner Chamber has zero encounters before a puzzle.
- `CheckUnownLetter` (`engine/battle/core.asm:6219`) re-rolls the form against
  `UnlockedUnownLetterSets` (`data/wild/unlocked_unowns.asm`), so with only the
  Kabuto puzzle solved you can only ever meet A-K (11 letters), which is more than
  the 3 the scientist needs.

`NUM_UNOWN EQU 26` (`constants/pokemon_constants.asm:308`) - see
"Unresolved" for the walkthrough's "28 forms" claim.

---

### MAP_RUINS_OF_ALPH_RESEARCH_CENTER

- Script: `maps/RuinsOfAlphResearchCenter.asm`
- Blocks: `maps/RuinsOfAlphResearchCenter.blk`
- Header: `data/maps/maps.asm:106` -> `TILESET_FACILITY, INDOOR,
  LANDMARK_RUINS_OF_ALPH, MUSIC_UNION_CAVE, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:93` group `DUNGEONS` (3), id 28, `4, 4`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `RUINS_OF_ALPH_OUTSIDE` | 6 |
| 2 | 3 | 7 | `RUINS_OF_ALPH_OUTSIDE` | 6 |

**Coord events**: none (the cutscene is a `scene_script` + `sdefer`).

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 6 | 5 | `BGEVENT_READ` | `RuinsOfAlphResearchCenterBookshelf` |
| 3 | 4 | `BGEVENT_READ` | `RuinsOfAlphResearchCenterComputer` |
| 7 | 1 | `BGEVENT_READ` | `RuinsOfAlphResearchCenterPrinter` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `RUINSOFALPHRESEARCHCENTER_SCIENTIST1` | `SPRITE_SCIENTIST` | 4 | 5 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `RuinsOfAlphResearchCenterScientist1Script` | -1 |
| `RUINSOFALPHRESEARCHCENTER_SCIENTIST2` | `SPRITE_SCIENTIST` | 5 | 2 | `WANDER` (r 2,1) | `OBJECTTYPE_SCRIPT` | `RuinsOfAlphResearchCenterScientist2Script` | -1 |
| `RUINSOFALPHRESEARCHCENTER_SCIENTIST3` | `SPRITE_SCIENTIST` | 2 | 5 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `RuinsOfAlphResearchCenterScientist3Script` | `EVENT_RUINS_OF_ALPH_RESEARCH_CENTER_SCIENTIST` |

**Scripts of interest**

- `RuinsOfAlphResearchCenterScientistCallback` (`callback MAPCALLBACK_OBJECTS`) -
  `checkscene` / `ifequal SCENE_RUINSOFALPHRESEARCHCENTER_GET_UNOWN_DEX, .ShowScientist`;
  `.ShowScientist` does `moveobject RUINSOFALPHRESEARCHCENTER_SCIENTIST3, 3, 7` (onto
  the doorway) and `appear`. So scientist 3 is teleported onto the entrance tile for
  the cutscene, not spawned at his listed `2, 5`.
- `RuinsOfAlphResearchCenterGetUnownDexScript` (`sdefer` from the scene) -
  `applymovement` to the computer (`UP UP LEFT`, `turn_head UP`), a run of
  `playsound`/`pause` beats, text, then `setflag ENGINE_UNOWN_DEX`, more text,
  `applymovement` away, `setscene SCENE_RUINSOFALPHRESEARCHCENTER_NOOP`,
  `special RestartMapMusic`. **No item is added to the bag** - the "Unown Pokedex"
  the walkthrough lists is an engine flag, not an inventory item.
- `RuinsOfAlphResearchCenterPrinter` / `...Computer` / `...Scientist3Script` - all
  gate their good branch on `readvar VAR_UNOWNCOUNT` / `ifequal NUM_UNOWN`, i.e. all
  26 forms. `EVENT_RUINS_OF_ALPH_RESEARCH_CENTER_SCIENTIST` short-circuits the check
  (`.SkipChecking`) while scientist 3 is still hidden.
- `RuinsOfAlphResearchCenterScientist1Script` / `...Scientist2Script` - pure text,
  branching on `ENGINE_UNOWN_DEX` and `EVENT_MADE_UNOWN_APPEAR_IN_RUINS`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_UNOWN_DEX` | `constants/engine_flags.asm:21` | set here; read by the outside callback and the Pokedex | the section's "Unown Pokedex" reward |
| `EVENT_RUINS_OF_ALPH_RESEARCH_CENTER_SCIENTIST` | `constants/event_flags.asm:1190` | set by `InitializeEventsScript` (`engine/events/std_scripts.asm:471`), cleared by `appear` in the callback | scientist 3 hidden while SET |
| `SCENE_RUINSOFALPHRESEARCHCENTER_GET_UNOWN_DEX` | inline `scene_script` (= 1) | set remotely by `RuinsOfAlphOutsideScientistSceneContinue` | arms the cutscene on entry |

---

### MAP_ROUTE_32_RUINS_OF_ALPH_GATE

- Script: `maps/Route32RuinsOfAlphGate.asm`
- Header: `data/maps/maps.asm:258` -> `TILESET_GATE, GATE, LANDMARK_ROUTE_32,
  MUSIC_ROUTE_30, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:237` group `VIOLET` (10), id 12, `5, 4`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 4 | `RUINS_OF_ALPH_OUTSIDE` | 10 |
| 2 | 0 | 5 | `RUINS_OF_ALPH_OUTSIDE` | 11 |
| 3 | 9 | 4 | `ROUTE_32` | 2 |
| 4 | 9 | 5 | `ROUTE_32` | 3 |

**Coord events / BG events**: none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE32RUINSOFALPHGATE_OFFICER` | `SPRITE_OFFICER` | 5 | 2 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route32RuinsOfAlphGateOfficerScript` | -1 |
| `ROUTE32RUINSOFALPHGATE_POKEFAN_M` | `SPRITE_POKEFAN_M` | 8 | 2 | `WALK_UP_DOWN` (r 0,1) | `OBJECTTYPE_SCRIPT` | `Route32RuinsOfAlphGatePokefanMScript` | -1 |
| `ROUTE32RUINSOFALPHGATE_YOUNGSTER` | `SPRITE_YOUNGSTER` | 1 | 6 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `Route32RuinsOfAlphGateYoungsterScript` | -1 |

All `jumptextfaceplayer`. No gate.

---

### MAP_ROUTE_32

- Script: `maps/Route32.asm`
- Blocks: `maps/Route32.blk`
- Header: `data/maps/maps.asm:247` -> `TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_32,
  MUSIC_ROUTE_30, FALSE, PALETTE_AUTO, FISHGROUP_QWILFISH`
- Dimensions: `constants/map_constants.asm:226` group `VIOLET` (10), id 1,
  `map_const ROUTE_32, 10, 45` (10x45 blocks = 20x90 cells - by far the longest map
  in this section)
- Connections (`data/maps/attributes.asm`): `connection north, VioletCity,
  VIOLET_CITY, 0` and `connection south, Route33, ROUTE_33, 0`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 11 | 73 | `ROUTE_32_POKECENTER_1F` | 1 |
| 2 | 4 | 2 | `ROUTE_32_RUINS_OF_ALPH_GATE` | 3 |
| 3 | 4 | 3 | `ROUTE_32_RUINS_OF_ALPH_GATE` | 4 |
| 4 | 6 | 79 | `UNION_CAVE_1F` | 4 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_ROUTE32_COOLTRAINER_M_BLOCKS` (0) | 18 | 8 | `Route32CooltrainerMStopsYouScene` | turns both parties, text, `follow PLAYER, ROUTE32_COOLTRAINER_M`, `applymovement PLAYER, Movement_Route32CooltrainerMPushesYouBackToViolet` (`UP UP`), `stopfollow`, `turnobject PLAYER, DOWN`, `scall Route32CooltrainerMContinueScene`, then resets him with `DOWN` then `RIGHT` |
| `SCENE_ROUTE32_OFFER_SLOWPOKETAIL` (1) | 7 | 71 | `Route32WannaBuyASlowpokeTailScript` | `turnobject ROUTE32_FISHER4, DOWN` / `turnobject PLAYER, UP` then falls into `_OfferToSellSlowpokeTail` |

Scene ids from the inline `scene_script` rows: `SCENE_ROUTE32_COOLTRAINER_M_BLOCKS`
= 0 (the default, since scene bytes start at 0),
`SCENE_ROUTE32_OFFER_SLOWPOKETAIL` = 1, `SCENE_ROUTE32_NOOP` = 2.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 13 | 5 | `BGEVENT_READ` | `Route32Sign` |
| 9 | 1 | `BGEVENT_READ` | `Route32RuinsSign` |
| 10 | 84 | `BGEVENT_READ` | `Route32UnionCaveSign` |
| 12 | 73 | `BGEVENT_READ` | `Route32PokecenterSign` (`jumpstd PokecenterSignScript`) |
| 12 | 67 | `BGEVENT_ITEM` | `Route32HiddenGreatBall` -> `hiddenitem GREAT_BALL, EVENT_ROUTE_32_HIDDEN_GREAT_BALL` |
| 11 | 40 | `BGEVENT_ITEM` | `Route32HiddenSuperPotion` -> `hiddenitem SUPER_POTION, EVENT_ROUTE_32_HIDDEN_SUPER_POTION` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE32_FISHER1` | `SPRITE_FISHER` | 8 | 49 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerFisherJustin` | -1 |
| `ROUTE32_FISHER2` | `SPRITE_FISHER` | 12 | 56 | `STANDING_UP` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerFisherRalph1` | -1 |
| `ROUTE32_FISHER3` | `SPRITE_FISHER` | 6 | 48 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerFisherHenry` | -1 |
| `ROUTE32_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 13 | 23 | `STANDING_UP` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerYoungsterAlbert` | -1 |
| `ROUTE32_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 4 | 65 | `SPINCLOCKWISE` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerYoungsterGordon` | -1 |
| `ROUTE32_YOUNGSTER3` | `SPRITE_YOUNGSTER` | 1 | 56 | `STANDING_UP` | `OBJECTTYPE_TRAINER` (sight 4) | `TrainerCamperRoland` | -1 |
| `ROUTE32_LASS1` | `SPRITE_LASS` | 10 | 30 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerPicnickerLiz1` | -1 |
| `ROUTE32_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 19 | 8 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `Route32CooltrainerMScript` | -1 |
| `ROUTE32_YOUNGSTER4` | `SPRITE_YOUNGSTER` | 11 | 82 | `STANDING_UP` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerBirdKeeperPeter` | -1 |
| `ROUTE32_FISHER4` | `SPRITE_FISHER` | 7 | 70 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `SlowpokeTailSalesmanScript` | `EVENT_SLOWPOKE_WELL_ROCKETS` |
| `ROUTE32_POKE_BALL1` | `SPRITE_POKE_BALL` | 6 | 53 | `STILL` | `OBJECTTYPE_ITEMBALL` | `Route32GreatBall` (`itemball GREAT_BALL`) | `EVENT_ROUTE_32_GREAT_BALL` |
| `ROUTE32_FISHER5` | `SPRITE_FISHER` | 15 | 13 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `Route32RoarTMGuyScript` | -1 |
| `ROUTE32_FRIEDA` | `SPRITE_LASS` | 12 | 67 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `FriedaScript` | `EVENT_ROUTE_32_FRIEDA_OF_FRIDAY` |
| `ROUTE32_POKE_BALL2` | `SPRITE_POKE_BALL` | 3 | 30 | `STILL` | `OBJECTTYPE_ITEMBALL` | `Route32Potion` (`itemball POTION`) | `EVENT_ROUTE_32_POTION` |

**Scripts of interest**

- `Route32FriedaCallback` (`callback MAPCALLBACK_OBJECTS`) - `readvar VAR_WEEKDAY` /
  `ifequal FRIDAY, .FriedaAppears`; otherwise `disappear ROUTE32_FRIEDA`. She is a
  hard weekday gate, and she stands on the same cell (`12, 67`) as the hidden Great
  Ball.
- `FriedaScript` - if `EVENT_GOT_POISON_BARB_FROM_FRIEDA` -> Friday chat; else
  `readvar VAR_WEEKDAY` / `ifnotequal FRIDAY, .NotFriday`; else
  `setevent EVENT_MET_FRIEDA_OF_FRIDAY`, `verbosegiveitem POISON_BARB`,
  `iffalse .Done` (bag full), `setevent EVENT_GOT_POISON_BARB_FROM_FRIEDA`.
- `Route32CooltrainerMScript` / `Route32CooltrainerMContinueScene` - the Miracle Seed
  decision tree, in asm order:
  `checkevent EVENT_GOT_MIRACLE_SEED_IN_ROUTE_32` -> `.GotMiracleSeed` (thanks text);
  `checkflag ENGINE_ZEPHYRBADGE` -> if false `.DontHaveZephyrBadge` ("have you gone
  to the GYM");
  `checkevent EVENT_GOT_TOGEPI_EGG_FROM_ELMS_AIDE` -> if true `.GiveMiracleSeed`,
  else "the aide is waiting at the #MON CENTER".
  `.GiveMiracleSeed` -> `verbosegiveitem MIRACLE_SEED`, `iffalse .BagFull`,
  `setevent EVENT_GOT_MIRACLE_SEED_IN_ROUTE_32`.
  So the Miracle Seed needs BOTH `ENGINE_ZEPHYRBADGE` and the Togepi egg.
- `Route32RoarTMGuyScript` - `checkevent EVENT_GOT_TM05_ROAR`,
  `verbosegiveitem TM_ROAR`, `setevent EVENT_GOT_TM05_ROAR`. Unconditional otherwise.
- `SlowpokeTailSalesmanScript` / `_OfferToSellSlowpokeTail` - first thing it does is
  `setscene SCENE_ROUTE32_NOOP`, so the `7, 71` trip-wire fires exactly once.
  `yesorno`: "yes" gives the mocking `Text_ThoughtKidsWereLoaded`, nothing is bought
  or given either way. There is no purchase path in the asm.
- `TrainerFisherRalph1` / `TrainerPicnickerLiz1` - both are phone-number trainers.
  After the battle: `checkevent EVENT_*_READY_FOR_REMATCH` -> `.Rematch`;
  `checkcellnum PHONE_FISHER_RALPH` / `PHONE_PICNICKER_LIZ` -> already registered;
  `checkevent EVENT_*_ASKED_FOR_PHONE_NUMBER` -> ask again; otherwise
  `setevent EVENT_*_ASKED_FOR_PHONE_NUMBER` then
  `askforphonenumber PHONE_FISHER_RALPH` with `PHONE_CONTACTS_FULL` /
  `PHONE_CONTACT_REFUSED` branches. **You must talk to them a second time after the
  battle** to get the number, exactly as the walkthrough says.
  Rematch parties escalate: Ralph -> `RALPH2` after `ENGINE_FLYPOINT_ECRUTEAK`,
  `RALPH3` after `ENGINE_FLYPOINT_LAKE_OF_RAGE`; Liz -> `LIZ2` after
  `ENGINE_FLYPOINT_ECRUTEAK`, `LIZ3` after `EVENT_CLEARED_ROCKET_HIDEOUT`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_GOT_MIRACLE_SEED_IN_ROUTE_32` | `constants/event_flags.asm:102` | `Route32CooltrainerMScript` | one-time |
| `ENGINE_ZEPHYRBADGE` | `constants/engine_flags.asm:38` | read by the same script | Miracle Seed precondition |
| `EVENT_GOT_TM05_ROAR` | `constants/event_flags.asm:87` | `Route32RoarTMGuyScript` | one-time |
| `EVENT_MET_FRIEDA_OF_FRIDAY` | `constants/event_flags.asm:107` | `FriedaScript` | intro-text-only |
| `EVENT_GOT_POISON_BARB_FROM_FRIEDA` | `constants/event_flags.asm:108` | `FriedaScript` | one-time |
| `EVENT_ROUTE_32_FRIEDA_OF_FRIDAY` | `constants/event_flags.asm:1274` | `Route32FriedaCallback` | object hidden while SET (non-Friday) |
| `EVENT_ROUTE_32_GREAT_BALL` | `constants/event_flags.asm:1105` | itemball at `6, 53` | one-time |
| `EVENT_ROUTE_32_POTION` | `constants/event_flags.asm:1106` | itemball at `3, 30` | one-time |
| `EVENT_ROUTE_32_HIDDEN_GREAT_BALL` | `constants/event_flags.asm:175` | hidden item at `12, 67` | one-time |
| `EVENT_ROUTE_32_HIDDEN_SUPER_POTION` | `constants/event_flags.asm:176` | hidden item at `11, 40` | one-time |
| `EVENT_SLOWPOKE_WELL_ROCKETS` | `constants/event_flags.asm:1182` | gates `ROUTE32_FISHER4` | salesman disappears once Slowpoke Well is cleared |
| `PHONE_FISHER_RALPH` / `PHONE_PICNICKER_LIZ` | `constants/phone_constants.asm:20-21` | `askforphonenumber` | contact slots 17 / 18 |
| `VAR_WEEKDAY` | `constants/script_constants.asm:59` (`0b`) | Frieda callback and script | `FRIDAY` |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `MIRACLE_SEED` | talk to `ROUTE32_COOLTRAINER_M` at `19, 8` | `Route32CooltrainerMScript` `.GiveMiracleSeed` | `EVENT_GOT_MIRACLE_SEED_IN_ROUTE_32` |
| `TM_ROAR` (TM05) | talk to `ROUTE32_FISHER5` at `15, 13` | `Route32RoarTMGuyScript` | `EVENT_GOT_TM05_ROAR` |
| `POISON_BARB` | talk to Frieda at `12, 67` on a Friday | `FriedaScript` | `EVENT_GOT_POISON_BARB_FROM_FRIEDA` |
| `GREAT_BALL` | itemball at `6, 53` | `Route32GreatBall` | `EVENT_ROUTE_32_GREAT_BALL` |
| `POTION` | itemball at `3, 30` | `Route32Potion` | `EVENT_ROUTE_32_POTION` |
| `GREAT_BALL` (hidden) | hidden at `12, 67` | `Route32HiddenGreatBall` | `EVENT_ROUTE_32_HIDDEN_GREAT_BALL` |
| `SUPER_POTION` (hidden) | hidden at `11, 40` | `Route32HiddenSuperPotion` | `EVENT_ROUTE_32_HIDDEN_SUPER_POTION` |
| `OLD_ROD` | `ROUTE_32_POKECENTER_1F`, see below | `Route32Pokecenter1FFishingGuruScript` | `EVENT_GOT_OLD_ROD` |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `ALBERT` | `YOUNGSTER` | 3 | `YoungsterGroup` `; YOUNGSTER (3)` line 351: `6 RATTATA`, `8 ZUBAT` | `TrainerYoungsterAlbert` (`EVENT_BEAT_YOUNGSTER_ALBERT`) | none |
| `LIZ1` | `PICNICKER` | 1 | `PicnickerGroup` `; PICNICKER (1)` line 2584: `9 NIDORAN_F` | `TrainerPicnickerLiz1` (`EVENT_BEAT_PICNICKER_LIZ`) | `PHONE_PICNICKER_LIZ`; `LIZ2` `15 WEEPINBELL / 15 NIDORINA`, `LIZ3` `19 WEEPINBELL / 19 NIDORINO / 21 NIDOQUEEN` |
| `JUSTIN` | `FISHER` | 1 | `FisherGroup` `; FISHER (1)` line 1498: `5 MAGIKARP`, `5 MAGIKARP`, `15 MAGIKARP`, `5 MAGIKARP` | `TrainerFisherJustin` (`EVENT_BEAT_FISHER_JUSTIN`) | none |
| `HENRY` | `FISHER` | 5 | `FisherGroup` `; FISHER (5)` line 1523: `8 POLIWAG`, `8 POLIWAG` | `TrainerFisherHenry` (`EVENT_BEAT_FISHER_HENRY`) | none |
| `RALPH1` | `FISHER` | 2 | `FisherGroup` `; FISHER (2)` line 1506: `10 GOLDEEN` | `TrainerFisherRalph1` (`EVENT_BEAT_FISHER_RALPH`) | `PHONE_FISHER_RALPH`; `RALPH2` `17 GOLDEEN`, `RALPH3` `17 QWILFISH / 19 GOLDEEN` |
| `ROLAND` | `CAMPER` | 1 | `CamperGroup` `; CAMPER (1)` line 2705: `9 NIDORAN_M` | `TrainerCamperRoland` (`EVENT_BEAT_CAMPER_ROLAND`) | none |
| `GORDON` | `YOUNGSTER` | 4 | `YoungsterGroup` `; YOUNGSTER (4)` line 357: `10 WOOPER` | `TrainerYoungsterGordon` (`EVENT_BEAT_YOUNGSTER_GORDON`) | none |
| `PETER` | `BIRD_KEEPER` | 13 | `BirdKeeperGroup` `; BIRD_KEEPER (13)` line 598: `6 PIDGEY`, `6 PIDGEY`, `8 SPEAROW` | `TrainerBirdKeeperPeter` (`EVENT_BEAT_BIRD_KEEPER_PETER`) | none |

All eight parties are `TRAINERTYPE_NORMAL` (level + species only, no custom moves or
held items).

**Wild encounters**

`data/wild/johto_grass.asm:1711` `def_grass_wildmons ROUTE_32`, rate
`10 percent` all windows. **Gold** branch (`IF DEF(_GOLD)`):

- morn: `6 BELLSPROUT, 4 RATTATA, 6 MAREEP, 6 HOPPIP, 6 RATTATA, 4 WOOPER, 4 ZUBAT`
- day: `6 BELLSPROUT, 4 RATTATA, 6 MAREEP, 6 HOPPIP, 6 RATTATA, 8 RATTATA, 8 RATTATA`
- nite: `6 WOOPER, 4 RATTATA, 6 BELLSPROUT, 6 MAREEP, 8 WOOPER, 8 ZUBAT, 8 ZUBAT`

Silver swaps the `RATTATA` in slot 2 for `EKANS`. **Wooper is a morn-or-nite mon in
Gold** - it does not appear in the day table at all, which is why the walkthrough
says "Wooper will be a bit harder to find than Bellsprout".

`data/wild/johto_water.asm:142` `def_water_wildmons ROUTE_32`, rate `6 percent`:
`15 TENTACOOL, 20 QUAGSIRE, 20 TENTACRUEL` (Surf only).

Fishing group `FISHGROUP_QWILFISH` (`data/wild/fish.asm:22`); `.Qwilfish_Old`
(line 178) is `MAGIKARP 10, MAGIKARP 10, TENTACOOL 10` - the Old Rod here gives no
Qwilfish.

---

### MAP_ROUTE_32_POKECENTER_1F

- Script: `maps/Route32Pokecenter1F.asm`
- Header: `data/maps/maps.asm:259` -> `TILESET_POKECENTER, INDOOR,
  LANDMARK_ROUTE_32, MUSIC_POKEMON_CENTER, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:238` group `VIOLET` (10), id 13, `5, 4`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `ROUTE_32` | 1 |
| 2 | 4 | 7 | `ROUTE_32` | 1 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

**Coord events / BG events**: none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE32POKECENTER1F_NURSE` | `SPRITE_NURSE` | 3 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route32Pokecenter1FNurseScript` (`jumpstd PokecenterNurseScript`) | -1 |
| `ROUTE32POKECENTER1F_FISHING_GURU` | `SPRITE_FISHING_GURU` | 1 | 4 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route32Pokecenter1FFishingGuruScript` | -1 |
| `ROUTE32POKECENTER1F_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 6 | 2 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route32Pokecenter1FCooltrainerFScript` | -1 |

**Scripts of interest**

- `Route32Pokecenter1FFishingGuruScript` - `checkevent EVENT_GOT_OLD_ROD` ->
  `.GotOldRod`; else text, `yesorno`, `iffalse .Refused`, then
  `verbosegiveitem OLD_ROD`, text, `setevent EVENT_GOT_OLD_ROD`.
  Note: unlike most gift NPCs there is **no `iffalse` bag-full guard after the
  `verbosegiveitem`** - the flag is set unconditionally on the yes path.
  Answering "no" is recoverable (`.Refused` sets nothing).

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `OLD_ROD` | talk to the Fishing Guru at `1, 4`, answer YES | `Route32Pokecenter1FFishingGuruScript` | `EVENT_GOT_OLD_ROD` (`constants/event_flags.asm:31`) |

---

### MAP_UNION_CAVE_1F

- Script: `maps/UnionCave1F.asm`
- Blocks: `maps/UnionCave1F.blk`
- Header: `data/maps/maps.asm:107` -> `TILESET_CAVE, CAVE, LANDMARK_UNION_CAVE,
  MUSIC_UNION_CAVE, TRUE, PALETTE_NITE, FISHGROUP_LAKE`
  The palette is `PALETTE_NITE`, not `PALETTE_DARK` - **Union Cave is not a dark
  cave and never needs FLASH**, despite Firebreather Ray's "if it's light, a cave
  isn't scary" line.
- Dimensions: `constants/map_constants.asm:94` group `DUNGEONS` (3), id 29, `10, 18`
- Connections: none (`map_attributes UnionCave1F, UNION_CAVE_1F, $09`)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 19 | `UNION_CAVE_B1F` | 3 |
| 2 | 3 | 33 | `UNION_CAVE_B1F` | 4 |
| 3 | 17 | 31 | `ROUTE_33` | 1 |
| 4 | 17 | 3 | `ROUTE_32` | 4 |

**Coord events**: none. **BG events**: none (`UnionCave1FUnusedSign` exists in the
file but is marked `; unreferenced`).

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `UNIONCAVE1F_POKEFAN_M1` | `SPRITE_POKEFAN_M` | 4 | 4 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerHikerDaniel` | -1 |
| `UNIONCAVE1F_SUPER_NERD` | `SPRITE_SUPER_NERD` | 4 | 21 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 2) | `TrainerPokemaniacLarry` | -1 |
| `UNIONCAVE1F_POKEFAN_M2` | `SPRITE_POKEFAN_M` | 15 | 8 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerHikerRussell` | -1 |
| `UNIONCAVE1F_FISHER1` | `SPRITE_FISHER` | 16 | 31 | `STANDING_UP` | `OBJECTTYPE_TRAINER` (sight 4) | `TrainerFirebreatherRay` | -1 |
| `UNIONCAVE1F_FISHER2` | `SPRITE_FISHER` | 15 | 15 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (sight 2) | `TrainerFirebreatherBill` | -1 |
| `UNIONCAVE1F_POKE_BALL1` | `SPRITE_POKE_BALL` | 17 | 21 | `STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCave1FGreatBall` (`itemball GREAT_BALL`) | `EVENT_UNION_CAVE_1F_GREAT_BALL` |
| `UNIONCAVE1F_POKE_BALL2` | `SPRITE_POKE_BALL` | 4 | 2 | `STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCave1FPotion` (`itemball POTION`) | `EVENT_UNION_CAVE_1F_POTION` |
| `UNIONCAVE1F_POKE_BALL3` | `SPRITE_POKE_BALL` | 4 | 17 | `STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCave1FXAttack` (`itemball X_ATTACK`) | `EVENT_UNION_CAVE_1F_X_ATTACK` |
| `UNIONCAVE1F_POKE_BALL4` | `SPRITE_POKE_BALL` | 12 | 33 | `STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCave1FAwakening` (`itemball AWAKENING`) | `EVENT_UNION_CAVE_1F_AWAKENING` |

**Scripts of interest**

Every trainer script here is the plain `endifjustbattled / opentext / writetext /
waitbutton / closetext / end` shape. No flags beyond the `EVENT_BEAT_*` in the
`trainer` macro, no items, no rematch.

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `GREAT_BALL` | itemball at `17, 21` | `UnionCave1FGreatBall` | `EVENT_UNION_CAVE_1F_GREAT_BALL` (`constants/event_flags.asm:1019`) |
| `POTION` | itemball at `4, 2` | `UnionCave1FPotion` | `EVENT_UNION_CAVE_1F_POTION` (:1020) |
| `X_ATTACK` | itemball at `4, 17` | `UnionCave1FXAttack` | `EVENT_UNION_CAVE_1F_X_ATTACK` (:1021) |
| `AWAKENING` | itemball at `12, 33` | `UnionCave1FAwakening` | `EVENT_UNION_CAVE_1F_AWAKENING` (:1022) |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `DANIEL` | `HIKER` | 18 | `HikerGroup` `; HIKER (18)` line 2229: `11 ONIX` | `TrainerHikerDaniel` (`EVENT_BEAT_HIKER_DANIEL`) | none |
| `RUSSELL` | `HIKER` | 2 | `HikerGroup` `; HIKER (2)` line 2123: `4 GEODUDE`, `6 GEODUDE`, `8 GEODUDE` | `TrainerHikerRussell` (`EVENT_BEAT_HIKER_RUSSELL`) | none |
| `BILL` | `FIREBREATHER` | 5 | `FirebreatherGroup` `; FIREBREATHER (5)` line 2359: `6 KOFFING`, `6 KOFFING` | `TrainerFirebreatherBill` (`EVENT_BEAT_FIREBREATHER_BILL`) | none |
| `LARRY` | `POKEMANIAC` | 1 | `PokemaniacGroup` `; POKEMANIAC (1)` line 1081: `10 SLOWPOKE` | `TrainerPokemaniacLarry` (`EVENT_BEAT_POKEMANIAC_LARRY`) | none |
| `RAY` | `FIREBREATHER` | 7 | `FirebreatherGroup` `; FIREBREATHER (7)` line 2371: `9 VULPIX` | `TrainerFirebreatherRay` (`EVENT_BEAT_FIREBREATHER_RAY`) | none |

**Wild encounters**

`data/wild/johto_grass.asm:444` `def_grass_wildmons UNION_CAVE_1F`, rate
`6 percent` all windows. **Gold** branch, identical morn/day/nite:
`6 GEODUDE, 6 SANDSHREW, 5 ZUBAT, 4 RATTATA, 7 ZUBAT, 6 ONIX, 6 ONIX`.
(Silver replaces `SANDSHREW` with a second `RATTATA`.)
Note `SANDSHREW` and `ONIX` are in the table but not in the walkthrough's list.

`data/wild/johto_water.asm:12` `def_water_wildmons UNION_CAVE_1F`, rate
`2 percent`: `15 WOOPER, 20 QUAGSIRE, 15 QUAGSIRE`.

Fishing group `FISHGROUP_LAKE` (`data/wild/fish.asm:14`); `.Lake_Old` (line 57)
`MAGIKARP 10, MAGIKARP 10, GOLDEEN 10`.

---

### MAP_UNION_CAVE_B1F

- Script: `maps/UnionCaveB1F.asm`
- Blocks: `maps/UnionCaveB1F.blk`
- Header: `data/maps/maps.asm:108` -> `TILESET_CAVE, CAVE, LANDMARK_UNION_CAVE,
  MUSIC_UNION_CAVE, TRUE, PALETTE_NITE, FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:95` group `DUNGEONS` (3), id 30, `10, 18`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 3 | `RUINS_OF_ALPH_OUTSIDE` | 7 |
| 2 | 3 | 11 | `RUINS_OF_ALPH_OUTSIDE` | 8 |
| 3 | 7 | 19 | `UNION_CAVE_1F` | 1 |
| 4 | 3 | 33 | `UNION_CAVE_1F` | 2 |
| 5 | 17 | 31 | `UNION_CAVE_B2F` | 1 |

**Coord events / BG events**: none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `UNIONCAVEB1F_POKEFAN_M1` | `SPRITE_POKEFAN_M` | 10 | 4 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerHikerPhillip` | -1 |
| `UNIONCAVEB1F_POKEFAN_M2` | `SPRITE_POKEFAN_M` | 17 | 10 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerHikerLeonard` | -1 |
| `UNIONCAVEB1F_SUPER_NERD1` | `SPRITE_SUPER_NERD` | 5 | 32 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerPokemaniacAndrew` | -1 |
| `UNIONCAVEB1F_SUPER_NERD2` | `SPRITE_SUPER_NERD` | 17 | 30 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerPokemaniacCalvin` | -1 |
| `UNIONCAVEB1F_POKE_BALL1` | `SPRITE_POKE_BALL` | 2 | 16 | `STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCaveB1FTMSwift` (`itemball TM_SWIFT`) | `EVENT_UNION_CAVE_B1F_TM_SWIFT` |
| `UNIONCAVEB1F_BOULDER` | `SPRITE_BOULDER` | 7 | 10 | `STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | `UnionCaveB1FBoulder` (`jumpstd StrengthBoulderScript`) | -1 |
| `UNIONCAVEB1F_POKE_BALL2` | `SPRITE_POKE_BALL` | 17 | 23 | `STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCaveB1FXDefend` (`itemball X_DEFEND`) | `EVENT_UNION_CAVE_B1F_X_DEFEND` |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `TM_SWIFT` (TM39) | itemball at `2, 16` | `UnionCaveB1FTMSwift` | `EVENT_UNION_CAVE_B1F_TM_SWIFT` (`constants/event_flags.asm:1023`) |
| `X_DEFEND` | itemball at `17, 23` | `UnionCaveB1FXDefend` | `EVENT_UNION_CAVE_B1F_X_DEFEND` (:1024) |

**Trainers** (all beyond the walkthrough's current route; they sit on the B2F path)

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `PHILLIP` | `HIKER` | 3 | `; HIKER (3)` line 2130: `23 GEODUDE`, `23 GEODUDE`, `23 GRAVELER` | `TrainerHikerPhillip` | none |
| `LEONARD` | `HIKER` | 4 | `; HIKER (4)` line 2137: `23 GEODUDE`, `25 MACHOP` | `TrainerHikerLeonard` | none |
| `ANDREW` | `POKEMANIAC` | 2 | `; POKEMANIAC (2)` line 1086: `24 MAROWAK`, `24 MAROWAK` | `TrainerPokemaniacAndrew` | none |
| `CALVIN` | `POKEMANIAC` | 3 | `; POKEMANIAC (3)` line 1092: `26 KANGASKHAN` | `TrainerPokemaniacCalvin` | none |

Level 23-26 - a bot at the walkthrough's level 15-17 must NOT wander into these. The
TM Swift / X Defend route (`7, 19` -> `2, 16` -> `17, 23` -> `3, 33`) keeps clear of
Phillip (`10, 4`) and Leonard (`17, 10`) but passes near Calvin (`17, 30`, sight 3)
on the way to X Defend at `17, 23`.

**Wild encounters**

`data/wild/johto_grass.asm:499` `def_grass_wildmons UNION_CAVE_B1F`, rate
`6 percent`. Gold branch, identical morn/day/nite:
`8 GEODUDE, 8 SANDSHREW, 7 ZUBAT, 8 ONIX, 9 ZUBAT, 6 RATTATA, 6 RATTATA`.
`data/wild/johto_water.asm:19`, rate `2 percent`:
`15 WOOPER, 20 QUAGSIRE, 15 QUAGSIRE`.

---

### MAP_UNION_CAVE_B2F

Out of the walkthrough's current route (needs Strength for the B1F boulder), but it
is the map the section explicitly says to come back to.

- Script: `maps/UnionCaveB2F.asm`
- Blocks: `maps/UnionCaveB2F.blk`
- Header: `data/maps/maps.asm:109` -> `TILESET_CAVE, CAVE, LANDMARK_UNION_CAVE,
  MUSIC_UNION_CAVE, TRUE, PALETTE_NITE, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:96` group `DUNGEONS` (3), id 31, `10, 18`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 3 | `UNION_CAVE_B1F` | 5 |

**Coord events / BG events**: none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `UNIONCAVEB2F_ROCKER` | `SPRITE_ROCKER` | 17 | 23 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 5) | `TrainerCooltrainermNick` | -1 |
| `UNIONCAVEB2F_COOLTRAINER_F1` | `SPRITE_COOLTRAINER_F` | 5 | 13 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerCooltrainerfGwen` | -1 |
| `UNIONCAVEB2F_COOLTRAINER_F2` | `SPRITE_COOLTRAINER_F` | 3 | 28 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 2) | `TrainerCooltrainerfEmma` | -1 |
| `UNIONCAVEB2F_POKE_BALL1` | `SPRITE_POKE_BALL` | 16 | 2 | `STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCaveB2FElixer` | `EVENT_UNION_CAVE_B2F_ELIXER` |
| `UNIONCAVEB2F_POKE_BALL2` | `SPRITE_POKE_BALL` | 12 | 19 | `STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCaveB2FHyperPotion` | `EVENT_UNION_CAVE_B2F_HYPER_POTION` |
| `UNIONCAVEB2F_LAPRAS` | `SPRITE_SURF` | 11 | 31 | `SWIM_WANDER` (r 1,1) | `OBJECTTYPE_SCRIPT` | `UnionCaveLapras` | `EVENT_UNION_CAVE_B2F_LAPRAS` |

**Scripts of interest**

- `UnionCaveB2FLaprasCallback` (`callback MAPCALLBACK_OBJECTS`) -
  `checkflag ENGINE_UNION_CAVE_LAPRAS` -> if true `.NoAppear`;
  `readvar VAR_WEEKDAY` / `ifequal FRIDAY, .Appear`; else `disappear`.
- `UnionCaveLapras` - `faceplayer`, `cry LAPRAS`, `loadwildmon LAPRAS, 20`,
  `startbattle`, `disappear`, `setflag ENGINE_UNION_CAVE_LAPRAS`,
  `reloadmapafterbattle`. **Level 20, once per week only if you fail to catch it -
  no, once ever**: `ENGINE_UNION_CAVE_LAPRAS` (`constants/engine_flags.asm:107`) is
  set unconditionally after the battle. The Lapras is on water, so Surf is needed to
  reach `11, 31`.

**Trainers**

| const | class | id | party | script label |
|---|---|---|---|---|
| `NICK` | `COOLTRAINERM` | 1 | `CooltrainerMGroup` `; COOLTRAINERM (1)` line 740, `TRAINERTYPE_MOVES`: `26 CHARMANDER` (EMBER/SMOKESCREEN/RAGE/SCARY_FACE), `26 SQUIRTLE` (WITHDRAW/WATER_GUN/BITE/CURSE), `26 BULBASAUR` (LEECH_SEED/POISONPOWDER/SLEEP_POWDER/RAZOR_LEAF) | `TrainerCooltrainermNick` |
| `GWEN` | `COOLTRAINERF` | 1 | `CooltrainerFGroup` `; COOLTRAINERF (1)` line 865: `26 EEVEE`, `22 FLAREON`, `22 VAPOREON`, `22 JOLTEON` | `TrainerCooltrainerfGwen` |
| `EMMA` | `COOLTRAINERF` | 15 | line 954: `28 POLIWHIRL` | `TrainerCooltrainerfEmma` |

**Wild encounters**

`data/wild/johto_grass.asm:554`, rate `4 percent`, identical morn/day/nite:
`22 ZUBAT, 22 RATICATE, 22 GOLBAT, 21 GEODUDE, 20 RATTATA, 23 ONIX, 23 ONIX`.
`data/wild/johto_water.asm:26`, rate `4 percent`:
`15 TENTACOOL, 20 QUAGSIRE, 20 TENTACRUEL`.

---

### MAP_ROUTE_33

- Script: `maps/Route33.asm`
- Blocks: `maps/Route33.blk`
- Header: `data/maps/maps.asm:231` -> `TILESET_JOHTO_MODERN, ROUTE,
  LANDMARK_ROUTE_33, MUSIC_ROUTE_30, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:212` group `AZALEA` (8), id 6, `10, 9`
- Connections (`data/maps/attributes.asm`): `connection north, Route32, ROUTE_32, 0`
  and `connection west, AzaleaTown, AZALEA_TOWN, 0`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 11 | 9 | `UNION_CAVE_1F` | 3 |

**Coord events**: none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 11 | 11 | `BGEVENT_READ` | `Route33Sign` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE33_POKEFAN_M` | `SPRITE_POKEFAN_M` | 6 | 13 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (sight 2) | `TrainerHikerAnthony` | -1 |
| `ROUTE33_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 14 | 16 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route33FruitTree` (`fruittree FRUITTREE_ROUTE_33`) | -1 |

**Scripts of interest**

- `TrainerHikerAnthony` - same phone shape as Ralph/Liz:
  `EVENT_ANTHONY_READY_FOR_REMATCH` -> `.Rematch`;
  `checkcellnum PHONE_HIKER_ANTHONY`; `EVENT_ANTHONY_ASKED_FOR_PHONE_NUMBER`;
  `askforphonenumber PHONE_HIKER_ANTHONY`. Rematch escalates to `ANTHONY1` after
  `ENGINE_FLYPOINT_OLIVINE` and `ANTHONY3` after `EVENT_CLEARED_RADIO_TOWER`.
- `Route33FruitTree` - `fruittree FRUITTREE_ROUTE_33` (`constants/script_constants.asm:212`,
  index `06`); `data/items/fruit_trees.asm` row 6 is `db PSNCUREBERRY ; ROUTE_33`.

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `PSNCUREBERRY` | headbutt-style fruit tree object at `14, 16` | `Route33FruitTree` / `data/items/fruit_trees.asm` `; ROUTE_33` | none - fruit trees respawn on a timer, tracked in `wFruitTreeFlags`, not an `EVENT_*` |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `ANTHONY2` | `HIKER` | 5 | `HikerGroup` `; HIKER (5)` line 2143: `11 GEODUDE`, `11 MACHOP` | `TrainerHikerAnthony` (`EVENT_BEAT_HIKER_ANTHONY`) | `PHONE_HIKER_ANTHONY` (slot 19); `ANTHONY1` `16 GEODUDE / 18 MACHAMP`, `ANTHONY3` `25 GRAVELER / 27 GRAVELER / 29 MACHOKE` |

**Wild encounters**

`data/wild/johto_grass.asm:1766` `def_grass_wildmons ROUTE_33`, rate `10 percent`.
**Gold** branch:

- morn: `6 HOPPIP, 7 RATTATA, 6 SPEAROW, 6 RATTATA, 8 HOPPIP, 4 ZUBAT, 4 ZUBAT`
- day: `6 HOPPIP, 7 RATTATA, 6 SPEAROW, 6 RATTATA, 8 HOPPIP, 8 RATTATA, 8 RATTATA`
- nite: `6 ZUBAT, 7 RATTATA, 6 RATTATA, 6 RATTATA, 8 ZUBAT, 8 ZUBAT, 8 ZUBAT`

Silver replaces the slot-2 `RATTATA` with `EKANS`. No water table.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Route 32 south is soft-blocked at the top | `maps/Route32.asm` `coord_event 18, 8, SCENE_ROUTE32_COOLTRAINER_M_BLOCKS, Route32CooltrainerMStopsYouScene` | scene byte for `ROUTE_32` must not be 0 | `maps/VioletPokecenter1F.asm` `setmapscene ROUTE_32, SCENE_ROUTE32_OFFER_SLOWPOKETAIL` when you take the Togepi EGG. Until then the coord event fires every time and `applymovement PLAYER, Movement_Route32CooltrainerMPushesYouBackToViolet` (`UP UP`) shoves you back toward Violet |
| Elm's Aide does not exist yet | `engine/events/std_scripts.asm:468` sets `EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER`; `engine/phone/scripts/elm.asm:84` clears it | Falkner must be beaten so `maps/VioletGym.asm:38` `specialphonecall SPECIALCALL_ASSISTANT` arms the call, then the call must actually land | after the phone call, `VIOLETPOKECENTER1F_ELMS_AIDE` appears at `4, 3` |
| Miracle Seed | `maps/Route32.asm` `Route32CooltrainerMScript` | `ENGINE_ZEPHYRBADGE` AND `EVENT_GOT_TOGEPI_EGG_FROM_ELMS_AIDE` | both true -> `.GiveMiracleSeed` |
| Kabuto chamber floor | `maps/RuinsOfAlphKabutoChamber.asm` `RuinsOfAlphKabutoChamberHiddenDoorsCallback` (`MAPCALLBACK_TILES`) | `EVENT_SOLVED_KABUTO_PUZZLE` | solve `special UnownPuzzle` with `setval UNOWNPUZZLE_KABUTO` from the `BGEVENT_UP` at `3, 2` |
| Unown do not spawn at all | `engine/overworld/wildmons.asm:341-347` `cp UNOWN` / `ld a, [wUnlockedUnowns]` / `and a` / `jr z, .nowildbattle` | at least one `ENGINE_UNLOCKED_UNOWNS_*` bit set | solve any chamber puzzle |
| Only some Unown letters spawn | `engine/battle/core.asm:6219` `CheckUnownLetter` vs `data/wild/unlocked_unowns.asm` | the letter must be in an unlocked set | Kabuto -> A-K, Omanyte -> L-R, Aerodactyl -> S-W, Ho-Oh -> X-Z |
| Unown #DEX scientist | `maps/RuinsOfAlphOutside.asm` `RuinsOfAlphOutsideScientistCallback` | `ENGINE_UNOWN_DEX` clear AND `EVENT_MADE_UNOWN_APPEAR_IN_RUINS` set AND `VAR_UNOWNCOUNT > 2` | catch three distinct Unown forms, then walk onto `11, 14` or `10, 15` |
| Aerodactyl chamber | reachable only across the Ruins Outside water; `engine/events/overworld.asm:490` `ld de, ENGINE_FOGBADGE` / `call CheckEngineFlag`, then `ld d, SURF` / `call CheckPartyMove` | FOGBADGE + a party member knowing SURF | Chuck's badge, later game |
| Union Cave B1F boulder at `7, 10` | `maps/UnionCaveB1F.asm` `UnionCaveB1FBoulder` -> `jumpstd StrengthBoulderScript` -> `engine/events/std_scripts.asm:197` `farsjump AskStrengthScript` -> `engine/events/overworld.asm:1033` `TryStrengthOW`: `ld d, STRENGTH` / `CheckPartyMove`, then `ld de, ENGINE_PLAINBADGE` / `CheckEngineFlag` | PLAINBADGE + STRENGTH in the party | Whitney's badge + HM04 |
| Union Cave Lapras | `maps/UnionCaveB2F.asm` `UnionCaveB2FLaprasCallback` | `VAR_WEEKDAY == FRIDAY` and `ENGINE_UNION_CAVE_LAPRAS` clear | real-world Friday, once ever |
| Frieda / POISON_BARB | `maps/Route32.asm` `Route32FriedaCallback` + `FriedaScript` | `VAR_WEEKDAY == FRIDAY` | real-world Friday |
| Route 36 Sudowoodo | `maps/Route36.asm` `object_event 35, 9, SPRITE_WEIRD_TREE, ... SudowoodoScript, EVENT_ROUTE_36_SUDOWOODO` | out of scope for this section - the walkthrough says "ignore that for now" | next section |
| FLASH | **not required** - `data/maps/maps.asm:107-109` give all three Union Cave floors `PALETTE_NITE`, not `PALETTE_DARK` | none | n/a |

---

## 4. Bot checklist

Coordinates are `x, y` in the map's own cell space, as written in the asm.

1. `VIOLET_CITY` -> step onto warp 5 at `31, 25`.
   pre: `EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER` CLEAR (Elm's call landed).
   post: on `VIOLET_POKECENTER_1F`.
2. `VIOLET_POKECENTER_1F` -> talk to `VIOLETPOKECENTER1F_ELMS_AIDE` at `4, 3`,
   answer YES.
   pre: `VAR_PARTYCOUNT < PARTY_LENGTH`.
   post: `EVENT_GOT_TOGEPI_EGG_FROM_ELMS_AIDE` set; `ROUTE_32` scene =
   `SCENE_ROUTE32_OFFER_SLOWPOKETAIL`.
3. `VIOLET_POKECENTER_1F` -> heal at `VIOLETPOKECENTER1F_NURSE` (`3, 1`), buy balls
   at `VIOLET_MART` (Violet City warp 1 at `9, 17`). Then exit west out of Violet
   City on the map connection into `ROUTE_36`.
4. `ROUTE_36` -> walk to warp 3/4 at `47, 13` / `48, 13`.
   avoid: `object_event 35, 9` Sudowoodo, and trainers at `20, 12` / `31, 14`.
   post: `ROUTE_36_RUINS_OF_ALPH_GATE`.
5. `ROUTE_36_RUINS_OF_ALPH_GATE` -> warp 3/4 at `4, 7` / `5, 7`.
   post: `RUINS_OF_ALPH_OUTSIDE` at warp 9 (`7, 5`).
6. `RUINS_OF_ALPH_OUTSIDE` -> walk to warp 2 at `14, 7`.
   avoid: `TrainerPsychicNathan` at `4, 20` (L26 Girafarig, sight 1) - it is far
   south of this path, so no detour is needed.
   post: `RUINS_OF_ALPH_KABUTO_CHAMBER`.
7. `RUINS_OF_ALPH_KABUTO_CHAMBER` -> stand at `3, 3` facing UP, press A on the
   `BGEVENT_UP` at `3, 2`. Solve the sliding puzzle
   (`special UnownPuzzle`, `setval UNOWNPUZZLE_KABUTO`).
   post: `EVENT_SOLVED_KABUTO_PUZZLE`, `ENGINE_UNLOCKED_UNOWNS_A_TO_K`,
   `EVENT_RUINS_OF_ALPH_INNER_CHAMBER_TOURISTS`,
   `EVENT_RUINS_OF_ALPH_KABUTO_CHAMBER_RECEPTIONIST`, `RUINS_OF_ALPH_INNER_CHAMBER`
   scene = `SCENE_RUINSOFALPHINNERCHAMBER_STRANGE_PRESENCE`; `warpcheck` drops you
   through warp 3/4 into the Inner Chamber at `15, 3` / `16, 3`.
8. `RUINS_OF_ALPH_INNER_CHAMBER` -> the deferred scene prints "strange presence".
   post: `EVENT_MADE_UNOWN_APPEAR_IN_RUINS`; scene reset to
   `SCENE_RUINSOFALPHINNERCHAMBER_NOOP`.
9. `RUINS_OF_ALPH_INNER_CHAMBER` -> grind grass encounters (rate `6 percent`,
   always `5 UNOWN`, letters A-K) and CATCH three distinct letters.
   post: `VAR_UNOWNCOUNT >= 3`.
10. `RUINS_OF_ALPH_INNER_CHAMBER` -> warp 1 at `10, 13`.
    post: `RUINS_OF_ALPH_OUTSIDE` at `10, 13`; `RuinsOfAlphOutsideScientistCallback`
    runs on load and `appear`s the scientist + sets the scene.
11. `RUINS_OF_ALPH_OUTSIDE` -> step to `10, 15` (or `11, 14`).
    pre: `VAR_UNOWNCOUNT > 2`, `ENGINE_UNOWN_DEX` clear.
    post: cutscene runs; the script `applymovement`s you into the Research Center.
    Do not drive movement during this - it uses `follow` / `stopfollow` / `warpcheck`.
12. `RUINS_OF_ALPH_RESEARCH_CENTER` -> the scene fires on entry; press through.
    post: `ENGINE_UNOWN_DEX` set; scene reset to
    `SCENE_RUINSOFALPHRESEARCHCENTER_NOOP`.
13. `RUINS_OF_ALPH_RESEARCH_CENTER` -> warp 1/2 at `2, 7` / `3, 7` back outside, then
    walk south-east to warp 10/11 at `13, 20` / `13, 21`.
    post: `ROUTE_32_RUINS_OF_ALPH_GATE`.
14. `ROUTE_32_RUINS_OF_ALPH_GATE` -> warp 3/4 at `9, 4` / `9, 5`.
    post: `ROUTE_32` at `4, 2` / `4, 3`.
15. `ROUTE_32` -> optional: north connection into Violet City for the
    `VioletCityFruitTree` at Violet City `14, 29` (PRZCUREBERRY,
    `data/items/fruit_trees.asm` `; VIOLET_CITY`).
16. `ROUTE_32` -> talk to `ROUTE32_COOLTRAINER_M` at `19, 8`.
    pre: `ENGINE_ZEPHYRBADGE` set AND `EVENT_GOT_TOGEPI_EGG_FROM_ELMS_AIDE` set.
    post: `MIRACLE_SEED` in bag, `EVENT_GOT_MIRACLE_SEED_IN_ROUTE_32`.
17. `ROUTE_32` -> talk to `ROUTE32_FISHER5` at `15, 13`.
    post: `TM_ROAR`, `EVENT_GOT_TM05_ROAR`.
18. `ROUTE_32` -> battle `TrainerYoungsterAlbert` (object at `13, 23`, sight 3).
    post: `EVENT_BEAT_YOUNGSTER_ALBERT`.
19. `ROUTE_32` -> pick up the `POTION` itemball at `3, 30`.
    post: `EVENT_ROUTE_32_POTION`.
20. `ROUTE_32` -> battle `TrainerPicnickerLiz1` (object at `10, 30`, sight 1), then
    TALK TO HER AGAIN.
    post: `EVENT_BEAT_PICNICKER_LIZ`, `EVENT_LIZ_ASKED_FOR_PHONE_NUMBER`, then
    `PHONE_PICNICKER_LIZ` registered via `askforphonenumber`.
21. `ROUTE_32` -> hidden `SUPER_POTION` at `11, 40` (`BGEVENT_ITEM`, needs the
    ITEMFINDER-style bump or a direct A press on the tile).
    post: `EVENT_ROUTE_32_HIDDEN_SUPER_POTION`.
22. `ROUTE_32` -> battle `TrainerFisherJustin` (`8, 49`, sight 1), then
    `TrainerFisherHenry` (`6, 48`, sight 1), then `TrainerFisherRalph1`
    (`12, 56`, sight 3) and talk to Ralph again for `PHONE_FISHER_RALPH`.
23. `ROUTE_32` -> battle `TrainerCamperRoland` (`1, 56`, sight 4).
24. `ROUTE_32` -> pick up the `GREAT_BALL` itemball at `6, 53`.
    post: `EVENT_ROUTE_32_GREAT_BALL`.
25. `ROUTE_32` -> battle `TrainerYoungsterGordon` (`4, 65`, `SPINCLOCKWISE`, sight 3).
26. `ROUTE_32` -> hidden `GREAT_BALL` at `12, 67`; on a Friday `ROUTE32_FRIEDA`
    stands there, talk to her for `POISON_BARB`.
    post: `EVENT_ROUTE_32_HIDDEN_GREAT_BALL`; optionally
    `EVENT_GOT_POISON_BARB_FROM_FRIEDA`.
27. `ROUTE_32` -> step onto `7, 71` to fire `Route32WannaBuyASlowpokeTailScript`
    (pre: scene == `SCENE_ROUTE32_OFFER_SLOWPOKETAIL`); answer either way.
    post: scene = `SCENE_ROUTE32_NOOP`, one-shot done.
28. `ROUTE_32` -> warp 1 at `11, 73` into `ROUTE_32_POKECENTER_1F`; heal at `3, 1`;
    talk to the Fishing Guru at `1, 4` and answer YES.
    post: `OLD_ROD`, `EVENT_GOT_OLD_ROD`.
29. `ROUTE_32` -> battle `TrainerBirdKeeperPeter` (`11, 82`, sight 3), then warp 4 at
    `6, 79`.
    post: `UNION_CAVE_1F` at `17, 3`.
30. `UNION_CAVE_1F` -> `POTION` itemball at `4, 2`; battle `TrainerHikerDaniel`
    (`4, 4`, `SPINRANDOM_FAST`, sight 1).
    post: `EVENT_UNION_CAVE_1F_POTION`, `EVENT_BEAT_HIKER_DANIEL`.
31. `UNION_CAVE_1F` -> battle `TrainerHikerRussell` (`15, 8`, sight 3) and
    `TrainerFirebreatherBill` (`15, 15`, sight 2).
32. `UNION_CAVE_1F` -> `X_ATTACK` itemball at `4, 17`; `GREAT_BALL` itemball at
    `17, 21`; battle `TrainerPokemaniacLarry` (`4, 21`, sight 2).
    post: `EVENT_UNION_CAVE_1F_X_ATTACK`, `EVENT_UNION_CAVE_1F_GREAT_BALL`,
    `EVENT_BEAT_POKEMANIAC_LARRY`.
33. `UNION_CAVE_1F` -> warp 1 at `5, 19`.
    post: `UNION_CAVE_B1F` at `7, 19`.
34. `UNION_CAVE_B1F` -> `TM_SWIFT` itemball at `2, 16`, then `X_DEFEND` itemball at
    `17, 23`.
    avoid: `TrainerHikerPhillip` `10, 4`, `TrainerHikerLeonard` `17, 10`,
    `TrainerPokemaniacCalvin` `17, 30` (sight 3), `TrainerPokemaniacAndrew` `5, 32` -
    all L23-26.
    post: `EVENT_UNION_CAVE_B1F_TM_SWIFT`, `EVENT_UNION_CAVE_B1F_X_DEFEND`.
35. `UNION_CAVE_B1F` -> warp 4 at `3, 33`.
    post: `UNION_CAVE_1F` at `3, 33`.
36. `UNION_CAVE_1F` -> `AWAKENING` itemball at `12, 33`; battle
    `TrainerFirebreatherRay` (`16, 31`, sight 4); warp 3 at `17, 31`.
    post: `EVENT_UNION_CAVE_1F_AWAKENING`, `EVENT_BEAT_FIREBREATHER_RAY`,
    on `ROUTE_33` at `11, 9`.
37. `ROUTE_33` -> `Route33FruitTree` at `14, 16` for `PSNCUREBERRY`.
38. `ROUTE_33` -> battle `TrainerHikerAnthony` (`6, 13`, `SPINRANDOM_FAST`, sight 2),
    then talk again for `PHONE_HIKER_ANTHONY`.
    post: `EVENT_BEAT_HIKER_ANTHONY`, `EVENT_ANTHONY_ASKED_FOR_PHONE_NUMBER`.
39. `ROUTE_33` -> walk west across the map connection into `AZALEA_TOWN`.
    Section ends here.

Deferred steps (record as TODO, do not attempt this pass):

- `RUINS_OF_ALPH_OUTSIDE` warp 4 at `16, 33` (Aerodactyl puzzle) - needs SURF +
  `ENGINE_FOGBADGE`.
- `UNION_CAVE_B1F` boulder at `7, 10` -> `UNION_CAVE_B2F` - needs STRENGTH +
  `ENGINE_PLAINBADGE`; then the Friday Lapras at B2F `11, 31` (needs SURF).

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map data (warps / coord / bg / object events) for every map in this section | `src/import/RomExtractorGen2.lua` (`MapGroupPointers` walk, per-map `def_*` header parse around lines 878-987), consumed by `src/world/gen2/Map.lua` and `src/world/gen2/World.lua` | implemented - maps are extracted generically from the ROM, so nothing here is hand-authored per map |
| Warps / map connections | `src/world/gen2/World.lua`, `src/world/gen2/BorderFill.lua` | implemented |
| Coord-event trip-wires and `scene` bytes | `src/world/gen2/World.lua:5013` (coord event scan), `src/script/gen2/Vm.lua:274-296` (`setscene`, `checkscene`, `setmapscene`, `checkmapscene`) | implemented |
| Map callbacks (`MAPCALLBACK_OBJECTS` / `MAPCALLBACK_TILES`) - Frieda, Lapras, Ruins scientist, Kabuto floor | `src/world/gen2/World.lua:5659-5700` (`runMapCallback`, documented ordering at 5980-5984), `src/script/gen2/Vm.lua:1002` (`changeblock`) | implemented; driver `tests/drivers/gold_map_callbacks.lua` exercises callbacks generally, but not these maps specifically |
| `verbosegiveitem` / `giveitem` (Miracle Seed, TM05, Poison Barb, Old Rod) | `src/script/gen2/Vm.lua:490-498` | implemented |
| Itemballs (`OBJECTTYPE_ITEMBALL`) | `src/world/gen2/World.lua` object handling | implemented |
| Hidden items (`BGEVENT_ITEM` / `hiddenitem`) | `src/world/gen2/HiddenItems.lua`, `src/import/RomExtractorGen2.lua` | implemented |
| `giveegg` (Togepi EGG) + hatching | `src/script/gen2/Vm.lua:453`, `src/core/gen2/Breeding.lua`; driver `tests/drivers/gold_egg_hatch.lua` | implemented |
| Phone: `askforphonenumber` / `checkcellnum`, Ralph/Liz/Anthony contacts | `src/script/gen2/Vm.lua` (op present), `src/core/gen2/Phone.lua:172-179` has `[17] FISHER/RALPH1 ROUTE_32`, `[18] PICNICKER/LIZ1 ROUTE_32`, `[19] HIKER/ANTHONY2 ROUTE_33` | implemented |
| Elm's `SPECIALCALL_ASSISTANT` call that spawns the aide | `src/core/gen2/Phone.lua` | partial - the contact table is present; I did not find a `SPECIALCALL_*` special-call scheduler, so verify by hand that the aide actually appears |
| Unown puzzle (`special UnownPuzzle`, `setval UNOWNPUZZLE_*`) | `src/script/gen2/Specials.lua:919` (`H.UnownPuzzle`), UI in `src/ui/gen2/UnownPuzzle.lua` | implemented |
| Unown letter unlock sets / `wUnlockedUnowns` / letter-from-DVs | `src/core/gen2/Unown.lua` (ports `GetUnownLetter`, `CheckUnownLetter`, `UnlockedUnownLetterSets`, `NUM_UNOWN = 26`, `ENGINE_UNOWN_DEX = 12`) | implemented |
| `ChooseWildEncounter` cancelling Unown when `wUnlockedUnowns == 0` | `src/battle/gen2/Encounter.lua` | partial - `Encounter.lua` handles grass/water/fish tables; I did not verify the Unown short-circuit lives there. Verify by hand |
| Unown #DEX mode / Unown printer | `src/ui/gen2/PokedexMenu.lua`, `src/ui/gen2/UnownPrinter.lua` | implemented |
| Wild encounters, morn/day/nite split, encounter rates | `src/battle/gen2/Encounter.lua` | implemented |
| Fishing (Old Rod, fish groups) | `src/battle/gen2/Encounter.lua:79-111` (`Encounter.fish`, `Encounter.fishSlot`, map `fishGroup`) | implemented |
| Fruit trees (`fruittree FRUITTREE_ROUTE_33` -> PSNCUREBERRY) | `src/script/gen2/Vm.lua` (`fruittree` op), `src/core/gen2/Apricorns.lua:360` (`"PSNCUREBERRY", -- 06 FRUITTREE_ROUTE_33`) | implemented |
| Strength boulder (`jumpstd StrengthBoulderScript` -> `TryStrengthOW`) | `src/world/gen2/FieldMoves.lua:684-689` (documents the 0/1/2 `wScriptVar` result), badge map at :104-110 (`STRENGTH = "PLAIN"`) | implemented; driver `tests/drivers/gold_icepath_boulder.lua` covers a different map |
| Surf / FOGBADGE gate for the Aerodactyl chamber | `src/world/gen2/FieldMoves.lua:106` (`SURF = "FOG"`) | implemented |
| `ENGINE_UNION_CAVE_LAPRAS` flag id | `src/core/gen2/Apricorns.lua:84` (`{ id = 88, name = "ENGINE_UNION_CAVE_LAPRAS" }`) | implemented |
| `VAR_WEEKDAY` gating (Frieda, Lapras) | `src/script/gen2/Specials.lua`, `src/world/gen2/World.lua` | implemented |
| Ruins of Alph radio station (213.5) | `src/ui/gen2/Pokegear.lua:85, 799-802` (`UNOWN_RADIO`, landmark-gated to `LANDMARK_RUINS_OF_ALPH`) | implemented |
| Mom's shopping (Super Potion / Repel) | `src/core/gen2/MomShopping.lua`; asm table `data/items/mom_phone.asm` | implemented |
| End-to-end driver for this section | none | **missing** - `tests/drivers/gold_*.lua` has no Ruins of Alph, Route 32, Union Cave or Route 33 driver. The nearest are `gold_walk_smoke.lua` and `gold_trainer_smoke.lua` |

---

## 6. Unresolved / verify by hand

1. **"Repel" on Route 32.** The walkthrough lists Repel among Route 32 items and says
   "Take the left path and get the Repel". `maps/Route32.asm` has no `REPEL` anywhere.
   The only pickups on that fork are the `POTION` itemball at `3, 30` and the hidden
   `SUPER_POTION` at `11, 40`. The Repel the player actually ends up with almost
   certainly comes from `data/items/mom_phone.asm` `MomItems_2` (`momitem 4000, 270,
   MOM_ITEM, REPEL`), which fits the walkthrough's own "Mom will buy something once
   your savings reach certain thresholds" paragraph. Treat the Route 32 Repel as a
   walkthrough error.

2. **Ekans on Routes 32 and 33.** The walkthrough lists `#023 Ekans` for both routes.
   `data/wild/johto_grass.asm` puts `EKANS` only in the `ELIF DEF(_SILVER)` branches;
   the `IF DEF(_GOLD)` branches have `RATTATA` in that slot. This section's encounter
   list is Silver's, not Gold's.

3. **"Unown in its 28 forms ... plus two punctuation marks (? and !)."**
   `constants/pokemon_constants.asm:308` is `DEF NUM_UNOWN EQU const_value - 1 ; 26`,
   and the form constants stop at `UNOWN_Z`. The `?` and `!` forms are a Gen 3
   addition. The Research Center printer/computer both check `ifequal NUM_UNOWN`, so
   the completion target in Gold is 26.

4. **"Talk to the two people inside" the Kabuto chamber.**
   `maps/RuinsOfAlphKabutoChamber.asm` defines exactly one `object_event`
   (`RUINSOFALPHKABUTOCHAMBER_RECEPTIONIST` at `5, 5`). There is no second NPC.

5. **`RuinsOfAlphOutside` declares five object consts but only two objects.**
   `RUINSOFALPHOUTSIDE_FISHER`, `_YOUNGSTER2` and `_YOUNGSTER3` have no
   `object_event` row. Either dead constants or a Crystal-era leftover; a port that
   indexes objects by const must not assume the list is dense.

6. **Route 32 grass Pokemon the walkthrough omits.** It lists Rattata, Ekans, Zubat,
   Bellsprout, Mareep, Hoppip, Wooper. The Gold table also never yields Ekans (see 2),
   and Wooper is morn/nite only - the day table has no Wooper at all. Similarly Union
   Cave 1F/B1F contain `SANDSHREW` and `ONIX` in Gold, neither of which the
   walkthrough's Union Cave list mentions.

7. **"Some rando fisher will give you an Old Rod" - order.** The walkthrough puts the
   Old Rod after Frieda and the Slowpoke-tail salesman. The Fishing Guru is inside
   `ROUTE_32_POKECENTER_1F` (`1, 4`), reached by warp 1 at Route 32 `11, 73`, which is
   south of Frieda (`12, 67`) and the salesman coord event (`7, 71`). Order is
   consistent, but the guru is indoors, not "on the route".

8. **"X Attack below Bill" / "the item to the far left ... a Potion".**
   Firebreather Bill is at `15, 15`; the X Attack is at `4, 17` and the Potion at
   `4, 2`. Both are far to the WEST, not directly below/left of Bill. The prose
   directions are loose; use the coordinates.

9. **`SPECIALCALL_*` scheduling in the port.** I could not find the mechanism that
   arms and delivers `SPECIALCALL_ASSISTANT` (`maps/VioletGym.asm:38` ->
   `engine/phone/scripts/elm.asm` `.assistant`) in this repo. `src/core/gen2/Phone.lua`
   has the contact table but the special-call queue was not located. Without it,
   `EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER` never clears, the aide never appears,
   and Route 32 stays permanently blocked by the `18, 8` coord event - the single
   hardest failure mode for a bot in this section.

10. **The Unown short-circuit in `ChooseWildEncounter`.** `engine/overworld/wildmons.asm:341-347`
    cancels the encounter entirely when `wUnlockedUnowns == 0`. I confirmed
    `src/core/gen2/Unown.lua` ports the letter sets and `CheckUnownLetter`, but did
    not confirm `src/battle/gen2/Encounter.lua` reproduces the "no puzzle solved ->
    no encounter at all" branch. If it does not, a bot could meet Unown in the Inner
    Chamber before solving any puzzle.

11. **`Route32Pokecenter1FFishingGuruScript` has no bag-full guard.** Unlike
    `Route32CooltrainerMScript` and `FriedaScript`, it does not `iffalse` after
    `verbosegiveitem OLD_ROD` before `setevent EVENT_GOT_OLD_ROD`. If the KEY ITEMS
    pocket were full the flag would be set without the rod. This is asm behaviour,
    not a port bug - flagged so nobody "fixes" it.

12. **Union Cave Lapras is once-ever, not once-weekly.** `UnionCaveLapras` sets
    `ENGINE_UNION_CAVE_LAPRAS` after `startbattle` regardless of outcome, and
    `UnionCaveB2FLaprasCallback` checks that flag before the weekday check. The
    walkthrough's "only appears on Friday" is right about the weekday but does not
    mention that fleeing or fainting loses it permanently.

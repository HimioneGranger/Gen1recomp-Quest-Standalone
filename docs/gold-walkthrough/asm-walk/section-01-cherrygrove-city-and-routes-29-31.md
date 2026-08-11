# Section 01 - Cherrygrove City and Routes 29-31

Source: `../section-01-cherrygrove-city-and-routes-29-31.txt`
Maps covered: `MAP_ROUTE_29`, `MAP_ROUTE_29_ROUTE_46_GATE`, `MAP_ROUTE_46`,
`MAP_CHERRYGROVE_CITY`, `MAP_CHERRYGROVE_POKECENTER_1F`, `MAP_CHERRYGROVE_MART`,
`MAP_GUIDE_GENTS_HOUSE`, `MAP_CHERRYGROVE_GYM_SPEECH_HOUSE`,
`MAP_CHERRYGROVE_EVOLUTION_SPEECH_HOUSE`, `MAP_ROUTE_30`,
`MAP_ROUTE_30_BERRY_HOUSE`, `MAP_MR_POKEMONS_HOUSE`, `MAP_ROUTE_31`,
`MAP_ROUTE_31_VIOLET_GATE`, plus the return leg through `MAP_NEW_BARK_TOWN`,
`MAP_ELMS_LAB` and `MAP_PLAYERS_HOUSE_1F` (those three are first visited in the
previous section; only the beats this section's text drives are transcribed
here).

Badges / key milestones in this section:

- No badge. The section ends at the Violet City gate.
- `ENGINE_MAP_CARD` (Pokegear MAP card, Guide Gent tour).
- `ENGINE_POKEDEX` (Prof. Oak, Mr. Pokemon's House).
- `MYSTERY_EGG` obtained, then handed to Elm (`EVENT_GAVE_MYSTERY_EGG_TO_ELM`,
  the single biggest content switch in the section - it opens Poke Ball sales,
  the Route 29 catch tutorial, the Route 30 trainers and the Bank of Mom).
- Rival battle 1 in Cherrygrove City (`RIVAL1`, level 5 starter).
- `ENGINE_FLYPOINT_CHERRYGROVE`, and `blackoutmod CHERRYGROVE_CITY`.

Coordinate convention: every `warp_event` / `coord_event` / `bg_event` /
`object_event` row below is copied verbatim from the map asm. Those x/y are map
cell coordinates starting at 0 (`macros/scripts/maps.asm` adds the +4 border
offset when it assembles the row, so the asm number is the one a bot wants).
Map width/height in `constants/map_constants.asm` is in **blocks**, i.e. half
the cell count in each axis - `ROUTE_29` at `30, 9` is 60x18 cells, which is why
its object x values run up to 53.

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `MAP_ELMS_LAB` | `maps/ElmsLab.asm` | (already inside, previous section) | warps 1/2 at (4,11)/(5,11) -> `NEW_BARK_TOWN` warp 1 | Aide's `SCENE_ELMSLAB_AIDE_GIVES_POTION` coord event hands over a POTION on the way out |
| 2 | `MAP_NEW_BARK_TOWN` | `maps/NewBarkTown.asm` | lab door | west edge connection | "Head west onto Route 29" |
| 3 | `MAP_ROUTE_29` | `maps/Route29.asm` | east connection from New Bark | west connection to Cherrygrove | grinding, BERRY tree, POTION ball |
| 4 | `MAP_ROUTE_29_ROUTE_46_GATE` | `maps/Route29Route46Gate.asm` | Route 29 warp 1 at (27,1) | gate warps 1/2 -> Route 46 | optional detour "to the north is Route 46" |
| 5 | `MAP_ROUTE_46` | `maps/Route46.asm` | gate warps 1/2 at (7,33)/(8,33) | back through the gate | optional Rattata / Geodude hunting |
| 6 | `MAP_CHERRYGROVE_CITY` | `maps/CherrygroveCity.asm` | east connection from Route 29 | north connection to Route 30 | Guide Gent tour -> MAP CARD; Pokemon Center heal |
| 7 | `MAP_CHERRYGROVE_POKECENTER_1F` | `maps/CherrygrovePokecenter1F.asm` | city warp 2 at (29,3) | pokecenter warps 1/2 | heal |
| 8 | `MAP_ROUTE_30` | `maps/Route30.asm` | south connection from Cherrygrove | warp 2 at (17,5) | north to Mr. Pokemon; berry house; hidden POTION |
| 9 | `MAP_ROUTE_30_BERRY_HOUSE` | `maps/Route30BerryHouse.asm` | Route 30 warp 1 at (7,39) | house warps 1/2 | free BERRY from the Pokefan |
| 10 | `MAP_MR_POKEMONS_HOUSE` | `maps/MrPokemonsHouse.asm` | Route 30 warp 2 at (17,5) | house warps 1/2 | MYSTERY EGG + POKEDEX + Elm's panic call |
| 11 | `MAP_CHERRYGROVE_CITY` (2nd) | `maps/CherrygroveCity.asm` | south connection from Route 30 | east side, past (33,6)/(33,7) | rival battle trip-wire on the way out |
| 12 | `MAP_ROUTE_29` (2nd) | `maps/Route29.asm` | west connection | east connection | walk back to New Bark |
| 13 | `MAP_ELMS_LAB` (2nd) | `maps/ElmsLab.asm` | New Bark warp 1 at (6,3) | lab warps 1/2 | cop names the rival; give Elm the egg; aide gives 5 POKE BALLs |
| 14 | `MAP_PLAYERS_HOUSE_1F` | `maps/PlayersHouse1F.asm` | New Bark warp 2 at (13,5) | house warps 1/2 | Mom starts saving money (`special BankOfMom`) |
| 15 | `MAP_ROUTE_29` (3rd) | `maps/Route29.asm` | east connection | west connection | catch tutorial fires at (53,8)/(53,9) |
| 16 | `MAP_ROUTE_46` (2nd, optional) | `maps/Route46.asm` | via the gate | via the gate | catch a Rattata |
| 17 | `MAP_CHERRYGROVE_CITY` (3rd) | `maps/CherrygroveCity.asm` | east connection | north connection | heal, buy POKE BALLs (mart list now `MART_CHERRYGROVE_DEX`) |
| 18 | `MAP_ROUTE_30` (2nd) | `maps/Route30.asm` | south connection | north connection | Joey, Mikey, Don on the **west** fork |
| 19 | `MAP_ROUTE_31` | `maps/Route31.asm` | south connection from Route 30 | warps 1/2 at (4,6)/(4,7) | Wade, ANTIDOTE, POKE BALL, BITTER BERRY, Dark Cave mouth |
| 20 | `MAP_ROUTE_31_VIOLET_GATE` | `maps/Route31VioletGate.asm` | Route 31 warps 1/2 | gate warps 1/2 -> `VIOLET_CITY` warps 8/9 | "through the house-ish entry, and into Violet City" |

Spill-over: the text's last paragraph enters `MAP_VIOLET_CITY`
(`maps/VioletCity.asm`, header `data/maps/maps.asm`, connection
`connection east, Route31, ROUTE_31, 9` in `data/maps/attributes.asm`) and points
at Sprout Tower. Violet City belongs to the next section and is not transcribed
here. `MAP_DARK_CAVE_VIOLET_ENTRANCE` is likewise only touched at its mouth (see
the Route 31 block and section 3).

---

## 2. Maps

### MAP_ROUTE_29

- Script: `maps/Route29.asm`
- Blocks: `maps/Route29.blk`
- Header: `data/maps/maps.asm` ->
  `map Route29, TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_29, MUSIC_ROUTE_29, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm` -> `map_const ROUTE_29, 30, 9` (60x18 cells)
- Connections (`data/maps/attributes.asm`, `map_attributes Route29, ROUTE_29, $05`):
  north `Route46` (offset 10), west `CherrygroveCity` (0), east `NewBarkTown` (0)
- Scenes (implicit ordinals from `def_scene_scripts`): `SCENE_ROUTE29_NOOP` = 0,
  `SCENE_ROUTE29_CATCH_TUTORIAL` = 1

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 27 | 1 | `ROUTE_29_ROUTE_46_GATE` | 3 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_ROUTE29_CATCH_TUTORIAL` | 53 | 8 | `Route29Tutorial1` (`4a:4d98`) | DUDE catch demo, north lane |
| `SCENE_ROUTE29_CATCH_TUTORIAL` | 53 | 9 | `Route29Tutorial2` (`4a:4dce`) | DUDE catch demo, south lane |

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 51 | 7 | `BGEVENT_READ` | `Route29Sign1` |
| 3 | 5 | `BGEVENT_READ` | `Route29Sign2` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE29_COOLTRAINER_M1` | `SPRITE_COOLTRAINER_M` | 50 | 12 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `CatchingTutorialDudeScript` (`4a:4e1c`) | -1 |
| `ROUTE29_YOUNGSTER` | `SPRITE_YOUNGSTER` | 27 | 16 | `SPRITEMOVEDATA_WALK_UP_DOWN` (radius y 1) | `OBJECTTYPE_SCRIPT` | `Route29YoungsterScript` | -1 |
| `ROUTE29_TEACHER1` | `SPRITE_TEACHER` | 15 | 11 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius x 1) | `OBJECTTYPE_SCRIPT` | `Route29TeacherScript` | -1 |
| `ROUTE29_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 12 | 2 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `Route29FruitTree` (`4a:4eb4`) | -1 |
| `ROUTE29_FISHER` | `SPRITE_FISHER` | 25 | 3 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `Route29FisherScript` | -1 |
| `ROUTE29_COOLTRAINER_M2` | `SPRITE_COOLTRAINER_M` | 13 | 4 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route29CooltrainerMScript` | -1 |
| `ROUTE29_TUSCANY` | `SPRITE_TEACHER` | 29 | 12 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `TuscanyScript` (`4a:4e74`) | `EVENT_ROUTE_29_TUSCANY_OF_TUESDAY` |
| `ROUTE29_POKE_BALL` | `SPRITE_POKE_BALL` | 48 | 2 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `Route29Potion` (`4a:4eb6`) | `EVENT_ROUTE_29_POTION` |

**Scripts of interest**

- `Route29TuscanyCallback` (`MAPCALLBACK_OBJECTS`): `checkflag ENGINE_ZEPHYRBADGE`;
  without the badge it `disappear ROUTE29_TUSCANY` unconditionally. With the badge
  it `readvar VAR_WEEKDAY` and only `appear`s her on `TUESDAY`. So the walkthrough's
  "Pink Bow" is **not** obtainable in this section - it needs ZEPHYRBADGE first.
- `Route29Tutorial1` / `Route29Tutorial2`: `turnobject`, `showemote EMOTE_SHOCK`,
  `applymovement DudeMovementData1a/2a`, `setevent EVENT_DUDE_TALKED_TO_YOU`,
  `yesorno`. On yes: `follow ROUTE29_COOLTRAINER_M1, PLAYER`,
  `applymovement DudeMovementData1b/2b`, `stopfollow`, `loadwildmon RATTATA, 5`,
  `catchtutorial BATTLETYPE_TUTORIAL`, then `setscene SCENE_ROUTE29_NOOP` and
  `setevent EVENT_LEARNED_TO_CATCH_POKEMON`. On no (`Script_RefusedTutorial1/2`)
  the scene is still cleared, so a bot that declines does not get stuck.
- `CatchingTutorialDudeScript`: repeatable demo. Requires `VAR_BOXSPACE != 0`,
  `EVENT_LEARNED_TO_CATCH_POKEMON` clear and `EVENT_GAVE_MYSTERY_EGG_TO_ELM` set.
- `Route29Potion`: `itemball POTION`, one-shot on `EVENT_ROUTE_29_POTION`.
- `Route29FruitTree`: `fruittree FRUITTREE_ROUTE_29` -> `BERRY`
  (`data/items/fruit_trees.asm`, first row).

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `SCENE_ROUTE29_CATCH_TUTORIAL` | implicit ordinal 1, `maps/Route29.asm` | set by `ElmAfterTheftScript` (`setmapscene ROUTE_29, ...`) | tutorial trip-wire armed only after the egg is delivered |
| `EVENT_DUDE_TALKED_TO_YOU` | `constants/event_flags.asm:74` | `Route29Tutorial1/2` | demo started |
| `EVENT_LEARNED_TO_CATCH_POKEMON` | `constants/event_flags.asm:75` | `Route29Tutorial1/2`, `CatchingTutorialDudeScript` | demo finished |
| `EVENT_ROUTE_29_POTION` | `constants/event_flags.asm:1102` | `itemball` | ball taken (object hidden when set) |
| `EVENT_ROUTE_29_TUSCANY_OF_TUESDAY` | `constants/event_flags.asm:1275` | `Route29TuscanyCallback` | Tuscany visible when **clear** |
| `EVENT_MET_TUSCANY_OF_TUESDAY` / `EVENT_GOT_PINK_BOW_FROM_TUSCANY` | `constants/event_flags.asm:109,110` | `TuscanyScript` | one-shot PINK BOW |
| `ENGINE_ZEPHYRBADGE` | `constants/engine_flags.asm:38` | `Route29TuscanyCallback` | gate on Tuscany appearing at all |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `POTION` | item ball at (48,2) | `Route29Potion` | `EVENT_ROUTE_29_POTION` |
| `BERRY` | fruit tree at (12,2) | `Route29FruitTree` / `FRUITTREE_ROUTE_29` | daily, not an event flag |
| `PINK_BOW` | Tuscany at (29,12) | `TuscanyScript`, `verbosegiveitem PINK_BOW` | `EVENT_GOT_PINK_BOW_FROM_TUSCANY`; needs ZEPHYRBADGE **and** `VAR_WEEKDAY == TUESDAY` |

**Trainers**

None (the DUDE is `OBJECTTYPE_SCRIPT`; his battle is `catchtutorial`, not a trainer).

**Wild encounters**

`data/wild/johto_grass.asm`, `def_grass_wildmons ROUTE_29`, rates
`10 percent, 10 percent, 10 percent`:

- morn / day (identical): 2 PIDGEY, 3 SENTRET, 3 PIDGEY, 2 SENTRET, 4 RATTATA, 4 PIDGEY, 4 PIDGEY
- nite: 2 HOOTHOOT, 3 HOOTHOOT, 3 HOOTHOOT, 2 RATTATA, 4 RATTATA, 4 HOOTHOOT, 4 HOOTHOOT

No `def_water_wildmons ROUTE_29`. Fishing group `FISHGROUP_SHORE`
(`data/wild/fish.asm` `.Shore_Old/Good/Super`: MAGIKARP/KRABBY).

### MAP_ROUTE_29_ROUTE_46_GATE

- Script: `maps/Route29Route46Gate.asm`
- Blocks: shared `maps/NorthSouthGate.blk` (`data/maps/blocks.asm:213`)
- Header: `map Route29Route46Gate, TILESET_GATE, GATE, LANDMARK_ROUTE_29, MUSIC_ROUTE_29, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const ROUTE_29_ROUTE_46_GATE, 5, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 0 | `ROUTE_46` | 1 |
| 2 | 5 | 0 | `ROUTE_46` | 2 |
| 3 | 4 | 7 | `ROUTE_29` | 1 |
| 4 | 5 | 7 | `ROUTE_29` | 1 |

**Coord events** / **BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE29ROUTE46GATE_OFFICER` | `SPRITE_OFFICER` | 0 | 4 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `Route29Route46GateOfficerScript` | -1 |
| `ROUTE29ROUTE46GATE_YOUNGSTER` | `SPRITE_YOUNGSTER` | 6 | 4 | `SPRITEMOVEDATA_WALK_UP_DOWN` | `OBJECTTYPE_SCRIPT` | `Route29Route46GateYoungsterScript` | -1 |

Both are `jumptextfaceplayer` only - nothing blocks.

### MAP_ROUTE_46

- Script: `maps/Route46.asm`
- Blocks: `maps/Route46.blk`
- Header: `map Route46, TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_46, MUSIC_ROUTE_36, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `map_const ROUTE_46, 10, 18` (20x36 cells)
- Connections: south `Route29` (offset -10), east `Route45` (-36)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 7 | 33 | `ROUTE_29_ROUTE_46_GATE` | 1 |
| 2 | 8 | 33 | `ROUTE_29_ROUTE_46_GATE` | 2 |
| 3 | 14 | 5 | `DARK_CAVE_VIOLET_ENTRANCE` | 3 |

**Coord events**: none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 9 | 27 | `BGEVENT_READ` | `Route46Sign` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE46_POKEFAN_M` | `SPRITE_POKEFAN_M` | 12 | 18 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 2) | `TrainerHikerBailey` | -1 |
| `ROUTE46_YOUNGSTER` | `SPRITE_YOUNGSTER` | 3 | 13 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` (sight 4) | `TrainerCamperTed` | -1 |
| `ROUTE46_LASS` | `SPRITE_LASS` | 1 | 15 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` (sight 4) | `TrainerPicnickerErin1` | -1 |
| `ROUTE46_FRUIT_TREE1` | `SPRITE_FRUIT_TREE` | 7 | 5 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `Route46FruitTree1` | -1 |
| `ROUTE46_FRUIT_TREE2` | `SPRITE_FRUIT_TREE` | 8 | 6 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `Route46FruitTree2` | -1 |
| `ROUTE46_POKE_BALL` | `SPRITE_POKE_BALL` | 0 | 12 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `Route46DireHit` | `EVENT_ROUTE_46_DIRE_HIT` |

**Trainers** (all three are far above the walkthrough's level range at this point,
and all three stand at y <= 18, i.e. past the ledges at the north end of the map)

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `BAILEY` | `HIKER` (`$2c`) | 11th in class | `HikerGroup` "BAILEY": 5x L13 GEODUDE | `TrainerHikerBailey` | no |
| `TED` | `CAMPER` (`$36`) | 11th in class | `CamperGroup` "TED": L17 MANKEY | `TrainerCamperTed` | no |
| `ERIN1` | `PICNICKER` (`$35`) | 10th in class | `PicnickerGroup` "ERIN": L16 PONYTA, L16 PONYTA | `TrainerPicnickerErin1` | phone `PHONE_PICNICKER_ERIN`, rematch gated on `EVENT_BEAT_ELITE_FOUR` / `EVENT_RESTORED_POWER_TO_KANTO` |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `DIRE_HIT` | item ball at (0,12) | `Route46DireHit` | `EVENT_ROUTE_46_DIRE_HIT` |
| `BERRY` | tree at (7,5) | `FRUITTREE_ROUTE_46_1` | daily |
| `PRZCUREBERRY` | tree at (8,6) | `FRUITTREE_ROUTE_46_2` | daily |

**Wild encounters** (`def_grass_wildmons ROUTE_46`, 10/10/10 percent)

- morn / day: 3 GEODUDE, 2 SPEAROW, 2 RATTATA, 2 GEODUDE, 3 SPEAROW, 3 JIGGLYPUFF, 5 JIGGLYPUFF
- nite: 3 GEODUDE, 3 RATTATA, 2 RATTATA, 2 GEODUDE, 4 GEODUDE, 3 JIGGLYPUFF, 5 JIGGLYPUFF

The walkthrough's "better chance of finding a Rattata" is true only at night
(2 of 7 slots vs 1 of 7 by day); by day the slot is a single level-2 RATTATA.

### MAP_CHERRYGROVE_CITY

- Script: `maps/CherrygroveCity.asm`
- Blocks: `maps/CherrygroveCity.blk`
- Header: `map CherrygroveCity, TILESET_JOHTO, TOWN, LANDMARK_CHERRYGROVE_CITY, MUSIC_CHERRYGROVE_CITY, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `map_const CHERRYGROVE_CITY, 20, 9` (40x18 cells)
- Connections (`map_attributes CherrygroveCity, CHERRYGROVE_CITY, $35`):
  north `Route30` (offset 5), east `Route29` (0)
- Spawn: `data/maps/spawn_points.asm` -> `spawn CHERRYGROVE_CITY, 29, 4`;
  fly point `data/maps/flypoints.asm` -> `db LANDMARK_CHERRYGROVE_CITY, SPAWN_CHERRYGROVE`
- Scenes: `SCENE_CHERRYGROVECITY_NOOP` = 0, `SCENE_CHERRYGROVECITY_MEET_RIVAL` = 1

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 23 | 3 | `CHERRYGROVE_MART` | 2 |
| 2 | 29 | 3 | `CHERRYGROVE_POKECENTER_1F` | 1 |
| 3 | 17 | 7 | `CHERRYGROVE_GYM_SPEECH_HOUSE` | 1 |
| 4 | 25 | 9 | `GUIDE_GENTS_HOUSE` | 1 |
| 5 | 31 | 11 | `CHERRYGROVE_EVOLUTION_SPEECH_HOUSE` | 1 |

**Coord events**

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_CHERRYGROVECITY_MEET_RIVAL` | 33 | 6 | `CherrygroveRivalSceneNorth` (`48:4479`) | rival walks in and battles |
| `SCENE_CHERRYGROVECITY_MEET_RIVAL` | 33 | 7 | `CherrygroveRivalSceneSouth` (`48:4475`) | same, after `moveobject CHERRYGROVECITY_RIVAL, 39, 7` |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 30 | 8 | `BGEVENT_READ` | `CherrygroveCitySign` |
| 23 | 9 | `BGEVENT_READ` | `GuideGentsHouseSign` |
| 24 | 3 | `BGEVENT_READ` | `CherrygroveCityMartSign` |
| 30 | 3 | `BGEVENT_READ` | `CherrygroveCityPokecenterSign` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `CHERRYGROVECITY_GRAMPS` | `SPRITE_GRAMPS` | 32 | 6 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CherrygroveCityGuideGent` (`48:43de`) | `EVENT_GUIDE_GENT_IN_HIS_HOUSE` |
| `CHERRYGROVECITY_RIVAL` | `SPRITE_RIVAL` | 39 | 6 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_RIVAL_CHERRYGROVE_CITY` |
| `CHERRYGROVECITY_TEACHER` | `SPRITE_TEACHER` | 27 | 12 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` | `OBJECTTYPE_SCRIPT` | `CherrygroveTeacherScript` | -1 |
| `CHERRYGROVECITY_YOUNGSTER` | `SPRITE_YOUNGSTER` | 23 | 7 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` | `OBJECTTYPE_SCRIPT` | `CherrygroveYoungsterScript` | -1 |
| `CHERRYGROVECITY_FISHER` | `SPRITE_FISHER` | 7 | 12 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `MysticWaterGuy` | -1 |

Object visibility rule (verified in `engine/overworld/map_objects_2.asm`
`CheckObjectFlag` and `engine/overworld/scripting.asm`
`ApplyEventActionAppearDisappear`): an object is **masked when its event flag is
SET**. `appear` clears the flag, `disappear` sets it.

**Scripts of interest**

- `CherrygroveCityFlypointCallback` (`MAPCALLBACK_NEWMAP`):
  `setflag ENGINE_FLYPOINT_CHERRYGROVE`. Entering the map once is enough.
- `CherrygroveCityGuideGent` (`48:43de`): `yesorno`. On yes it
  `playmusic MUSIC_SHOW_ME_AROUND`, `follow CHERRYGROVECITY_GRAMPS, PLAYER`, then
  five `applymovement GuideGentMovement1..5` legs (Pokecenter -> Mart -> Route 30 ->
  sea -> his house), `getstring STRING_BUFFER_4, "MAP CARD"`,
  `jumpstd ReceiveItemScript`, **`setflag ENGINE_MAP_CARD`**, `stopfollow`,
  `applymovement GuideGentMovement6`, `disappear CHERRYGROVECITY_GRAMPS`
  (-> sets `EVENT_GUIDE_GENT_IN_HIS_HOUSE`) and
  `clearevent EVENT_GUIDE_GENT_VISIBLE_IN_CHERRYGROVE` (-> makes the indoor gramps
  in `GuideGentsHouse.asm` appear). Declining leaves everything unchanged and he
  can be re-asked.
- `CherrygroveRivalSceneNorth` / `...South` (`48:4479` / `48:4475`):
  `special FadeOutMusic`, `appear CHERRYGROVECITY_RIVAL`,
  `applymovement CherrygroveCity_RivalWalksToYou` (5x `step LEFT`),
  `playmusic MUSIC_RIVAL_ENCOUNTER`, then the starter fork -
  `checkevent EVENT_GOT_TOTODILE_FROM_ELM` -> `RIVAL1_1_CHIKORITA`,
  `checkevent EVENT_GOT_CHIKORITA_FROM_ELM` -> `RIVAL1_1_CYNDAQUIL`,
  otherwise `RIVAL1_1_TOTODILE`. Always
  `loadvar VAR_BATTLETYPE, BATTLETYPE_CANLOSE`, so losing does not black you out.
  After either outcome: `applymovement PLAYER, CherrygroveCity_RivalPushesYouOutOfTheWay`
  (`big_step DOWN`), `applymovement CHERRYGROVECITY_RIVAL, CherrygroveCity_RivalExitsStageLeft`,
  `disappear CHERRYGROVECITY_RIVAL`, `setscene SCENE_CHERRYGROVECITY_NOOP`,
  `special HealParty`.
- `MysticWaterGuy` at (7,12): free `MYSTIC_WATER` via `verbosegiveitem`, one-shot on
  `EVENT_GOT_MYSTIC_WATER_IN_CHERRYGROVE`. The walkthrough never mentions it.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_MAP_CARD` | `constants/engine_flags.asm:5` | `CherrygroveCityGuideGent` | Pokegear MAP card; `CherrygroveTeacherScript` reads it |
| `ENGINE_FLYPOINT_CHERRYGROVE` | `constants/engine_flags.asm:80` | map callback | Fly destination unlocked on first entry |
| `ENGINE_POKEDEX` | `constants/engine_flags.asm:20` | set in `MrPokemonsHouse_OakScript`, read by `CherrygroveYoungsterScript` | dex owned |
| `EVENT_GUIDE_GENT_IN_HIS_HOUSE` | `constants/event_flags.asm:1184` | `disappear` at end of tour | outdoor gramps hidden when set |
| `EVENT_GUIDE_GENT_VISIBLE_IN_CHERRYGROVE` | `constants/event_flags.asm:1185` | set at new game by `InitializeEventsScript`, cleared at end of tour | indoor gramps hidden while set |
| `EVENT_RIVAL_CHERRYGROVE_CITY` | `constants/event_flags.asm:1120` | set by `InitializeEventsScript` and `ElmDirectionsScript`; cleared by `appear` in the scene | rival object hidden until the scene runs |
| `SCENE_CHERRYGROVECITY_MEET_RIVAL` | ordinal 1, `maps/CherrygroveCity.asm` | armed by `MrPokemonsHouse_OakScript` (`setmapscene CHERRYGROVE_CITY, ...`) | rival trip-wire only after the Pokedex |
| `EVENT_GOT_MYSTIC_WATER_IN_CHERRYGROVE` | `constants/event_flags.asm:86` | `MysticWaterGuy` | one-shot |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| MAP CARD (`ENGINE_MAP_CARD`, not a bag item) | finish the Guide Gent tour | `CherrygroveCityGuideGent` | engine flag, not an event |
| `MYSTIC_WATER` | talk to the fisher at (7,12) | `MysticWaterGuy` | `EVENT_GOT_MYSTIC_WATER_IN_CHERRYGROVE` |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `RIVAL1_1_CHIKORITA` / `RIVAL1_1_CYNDAQUIL` / `RIVAL1_1_TOTODILE` | `RIVAL1` (class 9) | 1 / 2 / 3 | `Rival1Group` entries 1-3: a single level 5 starter | `CherrygroveRivalSceneNorth` / `...South` | one-off |

Prize money: `data/trainers/attributes.asm` "Rival1" `db 15 ; base reward`;
`ComputeTrainerReward` (`engine/battle/read_trainer_party.asm:300`) is
`base * level of the last mon`, and `engine/battle/core.asm:2340-2361` pays that
amount **four times** (`ld c, 4` loop across Mom's account and the wallet).
15 * 5 * 4 = 300, which is exactly the walkthrough's "You get: 300G".

**Wild encounters**

No `def_grass_wildmons CHERRYGROVE_CITY` and no water table. Surf/fish only via
`FISHGROUP_SHORE`.

### MAP_CHERRYGROVE_POKECENTER_1F

- Script: `maps/CherrygrovePokecenter1F.asm`
- Blocks: shared `maps/Pokecenter1F.blk` (`data/maps/blocks.asm:363`)
- Header: `map CherrygrovePokecenter1F, TILESET_POKECENTER, INDOOR, LANDMARK_CHERRYGROVE_CITY, MUSIC_POKEMON_CENTER, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const CHERRYGROVE_POKECENTER_1F, 5, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `CHERRYGROVE_CITY` | 2 |
| 2 | 4 | 7 | `CHERRYGROVE_CITY` | 2 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `CHERRYGROVEPOKECENTER1F_NURSE` | `SPRITE_NURSE` | 3 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CherrygrovePokecenter1FNurseScript` (`jumpstd PokecenterNurseScript`) | -1 |
| `CHERRYGROVEPOKECENTER1F_FISHER` | `SPRITE_FISHER` | 2 | 3 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `CherrygrovePokecenter1FFisherScript` | -1 |
| `CHERRYGROVEPOKECENTER1F_GENTLEMAN` | `SPRITE_GENTLEMAN` | 8 | 6 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `CherrygrovePokecenter1FGentlemanScript` | -1 |
| `CHERRYGROVEPOKECENTER1F_TEACHER` | `SPRITE_TEACHER` | 1 | 6 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `CherrygrovePokecenter1FTeacherScript` | -1 |

No coord or bg events. Heal = talk to the nurse at (3,1) from (3,2).

### MAP_CHERRYGROVE_MART

- Script: `maps/CherrygroveMart.asm`
- Blocks: shared `maps/Mart.blk` (`data/maps/blocks.asm:334`)
- Header: `map CherrygroveMart, TILESET_MART, INDOOR, LANDMARK_CHERRYGROVE_CITY, MUSIC_CHERRYGROVE_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const CHERRYGROVE_MART, 6, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `CHERRYGROVE_CITY` | 1 |
| 2 | 3 | 7 | `CHERRYGROVE_CITY` | 1 |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `CHERRYGROVEMART_CLERK` | `SPRITE_CLERK` | 1 | 3 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `CherrygroveMartClerkScript` | -1 |
| `CHERRYGROVEMART_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 7 | 6 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` | `OBJECTTYPE_SCRIPT` | `CherrygroveMartCooltrainerMScript` | -1 |
| `CHERRYGROVEMART_YOUNGSTER` | `SPRITE_YOUNGSTER` | 2 | 5 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CherrygroveMartYoungsterScript` | -1 |

**Scripts of interest**

`CherrygroveMartClerkScript`: `checkevent EVENT_GAVE_MYSTERY_EGG_TO_ELM`.
False -> `pokemart MARTTYPE_STANDARD, MART_CHERRYGROVE`; true ->
`pokemart MARTTYPE_STANDARD, MART_CHERRYGROVE_DEX`.

`data/items/marts.asm`:
- `MartCherrygrove`: POTION, ANTIDOTE, PARLYZ_HEAL, AWAKENING
- `MartCherrygroveDex`: POKE_BALL, POTION, ANTIDOTE, PARLYZ_HEAL, AWAKENING

This is the asm behind the walkthrough's "Don't bother trying to get Pokeballs
because they aren't being sold just yet."

### MAP_GUIDE_GENTS_HOUSE

- Script: `maps/GuideGentsHouse.asm`
- Blocks: shared `maps/House1.blk` (`data/maps/blocks.asm:198-201`)
- Header: `map GuideGentsHouse, TILESET_HOUSE, INDOOR, LANDMARK_CHERRYGROVE_CITY, MUSIC_CHERRYGROVE_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const GUIDE_GENTS_HOUSE, 4, 4`

**Warps**: 1 (2,7) and 2 (3,7), both -> `CHERRYGROVE_CITY` warp 4.

**BG events**: (0,1) and (1,1) `BGEVENT_READ` `GuideGentsHouseBookshelf`.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `GUIDEGENTSHOUSE_GRAMPS` | `SPRITE_GRAMPS` | 2 | 3 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `GuideGentsHouseGuideGent` | `EVENT_GUIDE_GENT_VISIBLE_IN_CHERRYGROVE` |

### MAP_CHERRYGROVE_GYM_SPEECH_HOUSE

- Script: `maps/CherrygroveGymSpeechHouse.asm`; blocks shared `maps/House1.blk`
- Header: `map CherrygroveGymSpeechHouse, TILESET_HOUSE, INDOOR, LANDMARK_CHERRYGROVE_CITY, MUSIC_CHERRYGROVE_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const CHERRYGROVE_GYM_SPEECH_HOUSE, 4, 4`
- Warps: 1 (2,7), 2 (3,7) -> `CHERRYGROVE_CITY` warp 3
- BG: (0,1), (1,1) `PictureBookshelfScript`
- Objects: `CHERRYGROVEGYMSPEECHHOUSE_POKEFAN_M` at (2,3), `..._BUG_CATCHER` at (5,5); both plain `jumptextfaceplayer`, no flags

### MAP_CHERRYGROVE_EVOLUTION_SPEECH_HOUSE

- Script: `maps/CherrygroveEvolutionSpeechHouse.asm`; blocks shared `maps/House1.blk`
- Header: `map CherrygroveEvolutionSpeechHouse, TILESET_HOUSE, INDOOR, LANDMARK_CHERRYGROVE_CITY, MUSIC_CHERRYGROVE_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const CHERRYGROVE_EVOLUTION_SPEECH_HOUSE, 4, 4`
- Warps: 1 (2,7), 2 (3,7) -> `CHERRYGROVE_CITY` warp 5
- BG: (0,1), (1,1) `MagazineBookshelfScript`
- Objects: `..._LASS` at (3,5), `..._YOUNGSTER` at (2,5); both `opentext/writetext`
  only (note: no `faceplayer`, so they must be talked to from the side they face)

### MAP_ROUTE_30

- Script: `maps/Route30.asm`
- Blocks: `maps/Route30.blk`
- Header: `map Route30, TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_30, MUSIC_ROUTE_30, FALSE, PALETTE_AUTO, FISHGROUP_POND`
- Dimensions: `map_const ROUTE_30, 10, 27` (20x54 cells; y grows southward, so
  Cherrygrove is at high y and Route 31 at y=0)
- Connections (`map_attributes Route30, ROUTE_30, $05`): north `Route31` (-10),
  south `CherrygroveCity` (-5)
- Scenes: none (`def_scene_scripts` is empty). No callbacks.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 7 | 39 | `ROUTE_30_BERRY_HOUSE` | 1 |
| 2 | 17 | 5 | `MR_POKEMONS_HOUSE` | 1 |

**Coord events**: none. The "you can't pass that area just yet" block is done
with objects, not a coord event (see gates).

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 9 | 43 | `BGEVENT_READ` | `Route30Sign` |
| 13 | 29 | `BGEVENT_READ` | `MrPokemonsHouseDirectionsSign` |
| 15 | 5 | `BGEVENT_READ` | `MrPokemonsHouseSign` |
| 3 | 21 | `BGEVENT_READ` | `Route30TrainerTips` |
| 14 | 9 | `BGEVENT_ITEM` | `Route30HiddenPotion` (`4a:55a2`) = `hiddenitem POTION, EVENT_ROUTE_30_HIDDEN_POTION` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE30_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 5 | 26 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `YoungsterJoey_ImportantBattleScript` | `EVENT_ROUTE_30_BATTLE` |
| `ROUTE30_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 6 | 29 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 4) | `TrainerYoungsterJoey` (`4a:54c5`) | `EVENT_ROUTE_30_YOUNGSTER_JOEY` |
| `ROUTE30_YOUNGSTER3` | `SPRITE_YOUNGSTER` | 5 | 23 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER` (sight 1) | `TrainerYoungsterMikey` (`4a:5553`) | -1 |
| `ROUTE30_BUG_CATCHER` | `SPRITE_BUG_CATCHER` | 4 | 7 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerBugCatcherDon` (`4a:5567`) | -1 |
| `ROUTE30_YOUNGSTER4` | `SPRITE_YOUNGSTER` | 7 | 31 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` | `OBJECTTYPE_SCRIPT` | `Route30YoungsterScript` | -1 |
| `ROUTE30_MONSTER1` | `SPRITE_MONSTER` | 5 | 24 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_ROUTE_30_BATTLE` |
| `ROUTE30_MONSTER2` | `SPRITE_MONSTER` | 5 | 25 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_ROUTE_30_BATTLE` |
| `ROUTE30_FRUIT_TREE1` | `SPRITE_FRUIT_TREE` | 5 | 39 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `Route30FruitTree1` (`4a:559e`) | -1 |
| `ROUTE30_FRUIT_TREE2` | `SPRITE_FRUIT_TREE` | 11 | 5 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `Route30FruitTree2` (`4a:55a0`) | -1 |
| `ROUTE30_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 2 | 13 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route30CooltrainerFScript` | -1 |

**Scripts of interest**

- `YoungsterJoey_ImportantBattleScript` (the three objects flagged
  `EVENT_ROUTE_30_BATTLE` at (5,24), (5,25), (5,26)): a cutscene, not a battle -
  `playmusic MUSIC_JOHTO_TRAINER_BATTLE`, two `applymovement` lunges, "Leave me
  alone!", `special RestartMapMusic`, `end`. While the flag is clear these three
  objects occupy the west lane at x=5, which is what stops the player walking north
  on the left fork.
- `TrainerYoungsterJoey`: `trainer YOUNGSTER, JOEY1, EVENT_BEAT_YOUNGSTER_JOEY, ...`
  then the phone chain - `checkcellnum PHONE_YOUNGSTER_JOEY`,
  `EVENT_JOEY_ASKED_FOR_PHONE_NUMBER`, `askforphonenumber PHONE_YOUNGSTER_JOEY`.
  Rematches pick `JOEY2` (`ENGINE_FLYPOINT_GOLDENROD`) or `JOEY3`
  (`ENGINE_FLYPOINT_OLIVINE`).
- `TrainerYoungsterMikey`, `TrainerBugCatcherDon`: plain `trainer` + `endifjustbattled`.
- `Route30YoungsterScript` at (7,31): text switches on `EVENT_GAVE_MYSTERY_EGG_TO_ELM`.
- `Route30HiddenPotion`: `hiddenitem POTION, EVENT_ROUTE_30_HIDDEN_POTION` - a
  `BGEVENT_ITEM` bg event, so it is picked up by pressing A on (14,9), not by
  stepping on it.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ROUTE_30_BATTLE` | `constants/event_flags.asm:1206` | **set** by `ElmAfterTheftScript` | when set, the three blockers vanish and the west fork opens |
| `EVENT_ROUTE_30_YOUNGSTER_JOEY` | `constants/event_flags.asm:1207` | set at new game by `InitializeEventsScript` (`engine/events/std_scripts.asm:476`), **cleared** by `ElmAfterTheftScript` | Joey the trainer only exists after the egg hand-in |
| `EVENT_BEAT_YOUNGSTER_JOEY` / `..._MIKEY` / `EVENT_BEAT_BUG_CATCHER_DON` | `constants/event_flags.asm:963,964,839` | `trainer` macro | battle already won |
| `EVENT_ROUTE_30_HIDDEN_POTION` | `constants/event_flags.asm:174` | `hiddenitem` | hidden POTION taken |
| `EVENT_GOT_BERRY_FROM_ROUTE_30_HOUSE` | `constants/event_flags.asm:48` | `Route30BerryHousePokefanMScript` | free BERRY taken |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `POTION` | hidden, press A facing (14,9) | `Route30HiddenPotion` bg event | `EVENT_ROUTE_30_HIDDEN_POTION` |
| `BERRY` | tree at (5,39) | `FRUITTREE_ROUTE_30_1` | daily |
| `PSNCUREBERRY` | tree at (11,5) | `FRUITTREE_ROUTE_30_2` | daily |
| `BERRY` | Pokefan inside the berry house | `Route30BerryHousePokefanMScript` (`62:455c`) | `EVENT_GOT_BERRY_FROM_ROUTE_30_HOUSE` |
| `MYSTERY_EGG`, POKEDEX | Mr. Pokemon's House (below) | | |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `JOEY1` | `YOUNGSTER` (`$10`) | 1 | `YoungsterGroup` (1) "JOEY": L4 RATTATA | `TrainerYoungsterJoey` | yes, `PHONE_YOUNGSTER_JOEY`; `JOEY2` = L15 RATTATA, `JOEY3` = L21 RATICATE (TAIL_WHIP, QUICK_ATTACK, HYPER_FANG, SCARY_FACE) |
| `MIKEY` | `YOUNGSTER` | 2 | `YoungsterGroup` (2) "MIKEY": **L2 PIDGEY, L4 RATTATA** | `TrainerYoungsterMikey` | no |
| `DON` | `BUG_CATCHER` (`$18`) | 1 | `BugCatcherGroup` (1) "DON": L3 CATERPIE, L3 CATERPIE | `TrainerBugCatcherDon` | no |

Base rewards: YOUNGSTER `db 4`, BUG_CATCHER `db 4`
(`data/trainers/attributes.asm`), paid 4x -> Joey 4*4*4 = 64G, Mikey 4*4*4 = 64G,
Don 4*3*4 = 48G. All three match the walkthrough.

**Wild encounters** (`def_grass_wildmons ROUTE_30`, 10/10/10 percent; the file is
`IF DEF(_GOLD) ... ELIF DEF(_SILVER)`)

Gold:
- morn: 2 PIDGEY, 3 CATERPIE, 4 CATERPIE, 4 METAPOD, 4 PIDGEY, 4 PIDGEY, 4 PIDGEY
- day: 2 PIDGEY, 3 CATERPIE, 4 PIDGEY, 4 METAPOD, 4 CATERPIE, 5 METAPOD, 5 METAPOD
- nite: 3 SPINARAK, 3 RATTATA, 4 HOOTHOOT, 4 RATTATA, 4 HOOTHOOT, 4 HOOTHOOT, 4 HOOTHOOT

Silver (for contrast, since the walkthrough lists both): LEDYBA/WEEDLE/KAKUNA in
the morn/day rows, HOOTHOOT/RATTATA at nite.

Water (`data/wild/johto_water.asm`, `def_water_wildmons ROUTE_30`, 2 percent):
20 POLIWAG, 15 POLIWAG, 20 POLIWHIRL - surf only, so not reachable in this section.
Fishing group `FISHGROUP_POND` (`.Pond_Old`: MAGIKARP/POLIWAG).

### MAP_ROUTE_30_BERRY_HOUSE

- Script: `maps/Route30BerryHouse.asm`; blocks shared `maps/House1.blk`
- Header: `map Route30BerryHouse, TILESET_HOUSE, INDOOR, LANDMARK_ROUTE_30, MUSIC_CHERRYGROVE_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const ROUTE_30_BERRY_HOUSE, 4, 4`

**Warps**: 1 (2,7), 2 (3,7) -> `ROUTE_30` warp 1.
**BG events**: (0,1), (1,1) `MagazineBookshelfScript`.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE30BERRYHOUSE_POKEFAN_M` | `SPRITE_POKEFAN_M` | 2 | 3 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route30BerryHousePokefanMScript` (`62:455c`) | -1 |

Script: `checkevent EVENT_GOT_BERRY_FROM_ROUTE_30_HOUSE`; if clear,
`verbosegiveitem BERRY` then set the event.

### MAP_MR_POKEMONS_HOUSE

- Script: `maps/MrPokemonsHouse.asm`
- Blocks: `maps/MrPokemonsHouse.blk` (`data/maps/blocks.asm:940`)
- Header: `map MrPokemonsHouse, TILESET_FACILITY, INDOOR, LANDMARK_ROUTE_30, MUSIC_CHERRYGROVE_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const MR_POKEMONS_HOUSE, 4, 4`
- Scenes: `SCENE_MRPOKEMONSHOUSE_MEET_MR_POKEMON` = 0,
  `SCENE_MRPOKEMONSHOUSE_NOOP` = 1

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `ROUTE_30` | 2 |
| 2 | 3 | 7 | `ROUTE_30` | 2 |

**Coord events**: none - the cutscene is a **scene script**
(`scene_script MrPokemonsHouseMeetMrPokemonScene, SCENE_MRPOKEMONSHOUSE_MEET_MR_POKEMON`
-> `sdefer MrPokemonsHouseMrPokemonEventScript`), so it fires on map load.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `MrPokemonsHouse_ForeignMagazines` |
| 1 | 1 | `BGEVENT_READ` | `MrPokemonsHouse_ForeignMagazines` |
| 6 | 1 | `BGEVENT_READ` | `MrPokemonsHouse_BrokenComputer` |
| 7 | 1 | `BGEVENT_READ` | `MrPokemonsHouse_BrokenComputer` |
| 6 | 4 | `BGEVENT_READ` | `MrPokemonsHouse_StrangeCoins` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MRPOKEMONSHOUSE_GENTLEMAN` | `SPRITE_GENTLEMAN` | 3 | 5 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `MrPokemonsHouse_MrPokemonScript` | -1 |
| `MRPOKEMONSHOUSE_OAK` | `SPRITE_OAK` | 6 | 5 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_MR_POKEMONS_HOUSE_OAK` |

**Scripts of interest**

- `MrPokemonsHouseMrPokemonEventScript` (`62:464e`): `showemote EMOTE_SHOCK`,
  `applymovement PLAYER, MrPokemonsHouse_PlayerWalksToMrPokemon`
  (`step RIGHT`, `step UP`), `giveitem MYSTERY_EGG`, `itemnotify`,
  `setevent EVENT_GOT_MYSTERY_EGG_FROM_MR_POKEMON`,
  **`blackoutmod CHERRYGROVE_CITY`** (respawn point moves), then falls into the Oak script.
- `MrPokemonsHouse_OakScript` (`62:46c1`): `playmusic MUSIC_PROF_OAK`,
  `applymovement MRPOKEMONSHOUSE_OAK, MrPokemonsHouse_OakWalksToPlayer`,
  **`setflag ENGINE_POKEDEX`**, `disappear MRPOKEMONSHOUSE_OAK`,
  `special HealParty` (Mr. Pokemon's free heal the walkthrough mentions), then the
  whole post-visit world state:
  - `setevent EVENT_RIVAL_NEW_BARK_TOWN`
  - `setscene SCENE_MRPOKEMONSHOUSE_NOOP`
  - `setmapscene CHERRYGROVE_CITY, SCENE_CHERRYGROVECITY_MEET_RIVAL`
  - `setmapscene ELMS_LAB, SCENE_ELMSLAB_MEET_OFFICER`
  - `specialphonecall SPECIALCALL_ROBBED`
  - `clearevent EVENT_COP_IN_ELMS_LAB` (cop appears)
  - starter fork: sets `EVENT_TOTODILE_POKEBALL_IN_ELMS_LAB` /
    `EVENT_CHIKORITA_POKEBALL_IN_ELMS_LAB` / `EVENT_CYNDAQUIL_POKEBALL_IN_ELMS_LAB`
    (which ball is *missing* in the lab afterwards).
- `MrPokemonsHouse_MrPokemonScript`: repeat talk. Also the RED_SCALE ->
  `EXP_SHARE` trade, far outside this section.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_GOT_MYSTERY_EGG_FROM_MR_POKEMON` | `constants/event_flags.asm:39` | this scene | egg in bag |
| `ENGINE_POKEDEX` | `constants/engine_flags.asm:20` | `MrPokemonsHouse_OakScript` | dex owned |
| `EVENT_MR_POKEMONS_HOUSE_OAK` | `constants/event_flags.asm:1131` | `disappear MRPOKEMONSHOUSE_OAK` | Oak gone |
| `SPECIALCALL_ROBBED` | `constants/phone_constants.asm:46` | queued here, delivered by `ElmPhoneCallerScript` `.disaster` (`engine/phone/scripts/elm.asm:75`) | that call also does `setevent EVENT_ELM_CALLED_ABOUT_STOLEN_POKEMON` |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `MYSTERY_EGG` | scene on entry | `giveitem MYSTERY_EGG` in `MrPokemonsHouseMrPokemonEventScript` | `EVENT_GOT_MYSTERY_EGG_FROM_MR_POKEMON` |
| POKEDEX (`ENGINE_POKEDEX`) | same scene | `MrPokemonsHouse_OakScript` | engine flag |

### MAP_ROUTE_31

- Script: `maps/Route31.asm`
- Blocks: `maps/Route31.blk`
- Header: `map Route31, TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_31, MUSIC_ROUTE_30, FALSE, PALETTE_AUTO, FISHGROUP_POND`
- Dimensions: `map_const ROUTE_31, 20, 9` (40x18 cells)
- Connections: south `Route30` (offset 10), west `VioletCity` (-9)
- Callbacks: `callback MAPCALLBACK_NEWMAP, Route31CheckMomCallCallback`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 6 | `ROUTE_31_VIOLET_GATE` | 3 |
| 2 | 4 | 7 | `ROUTE_31_VIOLET_GATE` | 4 |
| 3 | 34 | 5 | `DARK_CAVE_VIOLET_ENTRANCE` | 1 |

**Coord events**: none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 7 | 5 | `BGEVENT_READ` | `Route31Sign` |
| 31 | 5 | `BGEVENT_READ` | `DarkCaveSign` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE31_FISHER` | `SPRITE_FISHER` | 17 | 7 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route31MailRecipientScript` | -1 |
| `ROUTE31_YOUNGSTER` | `SPRITE_YOUNGSTER` | 9 | 5 | `SPRITEMOVEDATA_WANDER` (radius 1,1) | `OBJECTTYPE_SCRIPT` | `Route31YoungsterScript` | -1 |
| `ROUTE31_BUG_CATCHER` | `SPRITE_BUG_CATCHER` | 18 | 15 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerBugCatcherWade1` (`4a:5a01`) | -1 |
| `ROUTE31_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 33 | 8 | `SPRITEMOVEDATA_WANDER` (radius 1,1) | `OBJECTTYPE_SCRIPT` | `Route31CooltrainerMScript` | -1 |
| `ROUTE31_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 16 | 7 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `Route31FruitTree` (`4a:5b18`) | -1 |
| `ROUTE31_POKE_BALL1` | `SPRITE_POKE_BALL` | 29 | 5 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `Route31Antidote` (`4a:5b1a`) | `EVENT_ROUTE_31_ANTIDOTE` |
| `ROUTE31_POKE_BALL2` | `SPRITE_POKE_BALL` | 21 | 13 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `Route31PokeBall` (`4a:5b1c`) | `EVENT_ROUTE_31_POKE_BALL` |

**Scripts of interest**

- `Route31CheckMomCallCallback` (`MAPCALLBACK_NEWMAP`):
  `checkevent EVENT_TALKED_TO_MOM_AFTER_MYSTERY_EGG_QUEST`; if **false**,
  `specialphonecall SPECIALCALL_WORRIED`. A bot that skips the Bank of Mom talk
  gets a scripted call the first time it walks onto Route 31.
- `TrainerBugCatcherWade1`: `trainer BUG_CATCHER, WADE1, EVENT_BEAT_BUG_CATCHER_WADE, ...`,
  phone chain on `PHONE_BUG_CATCHER_WADE`, rematches `WADE2` / `WADE3` gated on
  `ENGINE_FLYPOINT_GOLDENROD` / `ENGINE_FLYPOINT_MAHOGANY`.
- `Route31MailRecipientScript` at (17,7): the Kenya / SPEAROW-with-mail sidequest
  (`EVENT_GOT_KENYA` -> `checkpokemail` -> `verbosegiveitem TM_NIGHTMARE`). Kenya
  comes from Goldenrod, so this is dormant in this section.
- `Route31YoungsterScript`: the FALKNER / Violet Gym hint.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ROUTE_31_ANTIDOTE` | `constants/event_flags.asm:1103` | `itemball` | ball at (29,5) taken |
| `EVENT_ROUTE_31_POKE_BALL` | `constants/event_flags.asm:1104` | `itemball` | ball at (21,13) taken |
| `EVENT_BEAT_BUG_CATCHER_WADE` | `constants/event_flags.asm:842` | `trainer` macro | Wade beaten |
| `EVENT_TALKED_TO_MOM_AFTER_MYSTERY_EGG_QUEST` | `constants/event_flags.asm:73` | read by the map callback, set by `MomScript` | suppresses the "worried Mom" call |
| `SPECIALCALL_WORRIED` | `constants/phone_constants.asm:51` | map callback | queued call |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `ANTIDOTE` | item ball at (29,5), just west of the Dark Cave mouth | `Route31Antidote` | `EVENT_ROUTE_31_ANTIDOTE` |
| `POKE_BALL` | item ball at (21,13) | `Route31PokeBall` | `EVENT_ROUTE_31_POKE_BALL` |
| `BITTER_BERRY` | tree at (16,7) | `FRUITTREE_ROUTE_31` (`data/items/fruit_trees.asm`) | daily |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `WADE1` | `BUG_CATCHER` (`$18`) | 4 | `BugCatcherGroup` (4) "WADE": L2 CATERPIE, L2 CATERPIE, L3 WEEDLE, L2 CATERPIE | `TrainerBugCatcherWade1` | yes, `PHONE_BUG_CATCHER_WADE` |

Reward 4 (base) * 2 (last mon level) * 4 = 32G, matching the walkthrough.

**Wild encounters** (`def_grass_wildmons ROUTE_31`, 10/10/10 percent, Gold arm)

- morn: 3 PIDGEY, 4 CATERPIE, 3 BELLSPROUT, 5 METAPOD, 5 CATERPIE, 5 METAPOD, 5 METAPOD
- day: 3 PIDGEY, 4 CATERPIE, 3 BELLSPROUT, 5 METAPOD, 5 CATERPIE, 6 METAPOD, 6 METAPOD
- nite: 4 SPINARAK, 4 RATTATA, 3 BELLSPROUT, 5 RATTATA, 5 HOOTHOOT, 5 HOOTHOOT, 5 HOOTHOOT

Water (`def_water_wildmons ROUTE_31`, 2 percent): 20 POLIWAG, 15 POLIWAG,
20 POLIWHIRL. Fishing group `FISHGROUP_POND`.

### MAP_ROUTE_31_VIOLET_GATE

- Script: `maps/Route31VioletGate.asm`; blocks shared `maps/EastWestGate.blk`
  (`data/maps/blocks.asm:280`)
- Header: `map Route31VioletGate, TILESET_GATE, GATE, LANDMARK_ROUTE_31, MUSIC_ROUTE_30, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const ROUTE_31_VIOLET_GATE, 5, 4`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 4 | `VIOLET_CITY` | 8 |
| 2 | 0 | 5 | `VIOLET_CITY` | 9 |
| 3 | 9 | 4 | `ROUTE_31` | 1 |
| 4 | 9 | 5 | `ROUTE_31` | 2 |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE31VIOLETGATE_OFFICER` | `SPRITE_OFFICER` | 5 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route31VioletGateOfficerScript` | -1 |
| `ROUTE31VIOLETGATE_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 1 | 2 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `Route31VioletGateCooltrainerFScript` | -1 |

Nothing blocks; both NPCs are `jumptextfaceplayer`.

### Return-leg maps

Only the beats this section's text drives are transcribed. The first visit to all
three belongs to the previous section.

#### MAP_NEW_BARK_TOWN

- Script: `maps/NewBarkTown.asm`; blocks `maps/NewBarkTown.blk`
- Header: `map NewBarkTown, TILESET_JOHTO, TOWN, LANDMARK_NEW_BARK_TOWN, MUSIC_NEW_BARK_TOWN, FALSE, PALETTE_AUTO, FISHGROUP_OCEAN`
- Dimensions: `map_const NEW_BARK_TOWN, 10, 9`; connections west `Route29` (0),
  east `Route27` (0)
- Callback `NewBarkTownFlypointCallback`: `setflag ENGINE_FLYPOINT_NEW_BARK` and
  `clearevent EVENT_FIRST_TIME_BANKING_WITH_MOM`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 6 | 3 | `ELMS_LAB` | 1 |
| 2 | 13 | 5 | `PLAYERS_HOUSE_1F` | 1 |
| 3 | 3 | 11 | `PLAYERS_NEIGHBORS_HOUSE` | 1 |
| 4 | 11 | 13 | `ELMS_HOUSE` | 1 |

**Coord events**

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_NEWBARKTOWN_TEACHER_STOPS_YOU` (=0) | 1 | 8 | `NewBarkTown_TeacherStopsYouScene1` | teacher drags you back (`follow` + `applymovement`) |
| `SCENE_NEWBARKTOWN_TEACHER_STOPS_YOU` | 1 | 9 | `NewBarkTown_TeacherStopsYouScene2` | same, other lane |

`ElmDirectionsScript` does `setmapscene NEW_BARK_TOWN, SCENE_NEWBARKTOWN_NOOP`, so
once a starter is in hand the west exit at x=1 is free. `NEWBARKTOWN_RIVAL`
(object at (3,2), flag `EVENT_RIVAL_NEW_BARK_TOWN`) is un-hidden by
`MrPokemonsHouse_OakScript` - he shoves the player away from the lab window.

#### MAP_ELMS_LAB

- Script: `maps/ElmsLab.asm`; blocks `maps/ElmsLab.blk`
- Header: `map ElmsLab, TILESET_LAB, INDOOR, LANDMARK_NEW_BARK_TOWN, MUSIC_PROF_ELM, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const ELMS_LAB, 5, 6`
- Scenes (ordinals): `SCENE_ELMSLAB_MEET_ELM` 0, `SCENE_ELMSLAB_CANT_LEAVE` 1,
  `SCENE_ELMSLAB_NOOP` 2, `SCENE_ELMSLAB_MEET_OFFICER` 3, `SCENE_ELMSLAB_UNUSED` 4,
  `SCENE_ELMSLAB_AIDE_GIVES_POTION` 5, `SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS` 6
  (the last is a bare `scene_const` - a scene id with no scene script, only coord
  events)

**Warps**: 1 (4,11), 2 (5,11) -> `NEW_BARK_TOWN` warp 1.

**Coord events** (the ones this section fires)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_ELMSLAB_MEET_OFFICER` | 4 | 5 | `MeetCopScript` | walk-up then `CopScript` |
| `SCENE_ELMSLAB_MEET_OFFICER` | 5 | 5 | `MeetCopScript2` | `step LEFT` first, then the same |
| `SCENE_ELMSLAB_AIDE_GIVES_POTION` | 4 | 8 | `AideScript_WalkPotion1` | `verbosegiveitem POTION` |
| `SCENE_ELMSLAB_AIDE_GIVES_POTION` | 5 | 8 | `AideScript_WalkPotion2` | same |
| `SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS` | 4 | 8 | `AideScript_WalkBalls1` | `giveitem POKE_BALL, 5` |
| `SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS` | 5 | 8 | `AideScript_WalkBalls2` | same |
| `SCENE_ELMSLAB_CANT_LEAVE` | 4/5 | 6 | `LabTryToLeaveScript` | pushes the player back up (pre-starter) |

**Object events** (relevant rows)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ELMSLAB_ELM` | `SPRITE_ELM` | 5 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `ProfElmScript` | -1 |
| `ELMSLAB_ELMS_AIDE` | `SPRITE_SCIENTIST` | 2 | 9 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `ElmsAideScript` | `EVENT_ELMS_AIDE_IN_LAB` |
| `ELMSLAB_OFFICER` | `SPRITE_OFFICER` | 5 | 3 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `CopScript` (`60:4366`) | `EVENT_COP_IN_ELMS_LAB` |

**Scripts of interest**

- `CopScript` (`60:4366`): `special NameRival` (this is the "name your rival"
  prompt), then `applymovement OfficerLeavesMovement`, `disappear ELMSLAB_OFFICER`,
  `setscene SCENE_ELMSLAB_NOOP`.
- `ElmAfterTheftScript` (`60:41f1`), reached from `ProfElmScript` when
  `EVENT_GOT_MYSTERY_EGG_FROM_MR_POKEMON` is set: `checkitem MYSTERY_EGG`,
  `takeitem MYSTERY_EGG`, `setevent EVENT_GAVE_MYSTERY_EGG_TO_ELM`,
  `setmapscene ROUTE_29, SCENE_ROUTE29_CATCH_TUTORIAL`,
  `clearevent EVENT_ROUTE_30_YOUNGSTER_JOEY`, `setevent EVENT_ROUTE_30_BATTLE`,
  `setscene SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS`. This one script is what turns on
  the rest of the section.
- `AideScript_GiveYouBalls` (`60:4317`): `giveitem POKE_BALL, 5`, `itemnotify`,
  `setscene SCENE_ELMSLAB_NOOP`.

#### MAP_PLAYERS_HOUSE_1F

- Script: `maps/PlayersHouse1F.asm`; blocks `maps/PlayersHouse1F.blk`
- Dimensions: `map_const PLAYERS_HOUSE_1F, 5, 4`
- Warps: 1 (6,7), 2 (7,7) -> `NEW_BARK_TOWN` warp 2; 3 (9,0) -> `PLAYERS_HOUSE_2F` 1

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `PLAYERSHOUSE1F_MOM1` | `SPRITE_MOM` | 7 | 3 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `MomScript` (`60:56cb`) | `EVENT_PLAYERS_HOUSE_MOM_1` |
| `PLAYERSHOUSE1F_MOM2` | `SPRITE_MOM` | 2 | 2 | `SPRITEMOVEDATA_STANDING_UP` (hours `-1, MORN`) | `OBJECTTYPE_SCRIPT` | `MomScript` | `EVENT_PLAYERS_HOUSE_MOM_2` |
| `PLAYERSHOUSE1F_MOM3` | `SPRITE_MOM` | 7 | 3 | `SPRITEMOVEDATA_STANDING_LEFT` (hours `-1, DAY`) | `OBJECTTYPE_SCRIPT` | `MomScript` | `EVENT_PLAYERS_HOUSE_MOM_2` |
| `PLAYERSHOUSE1F_MOM4` | `SPRITE_MOM` | 0 | 2 | `SPRITEMOVEDATA_STANDING_UP` (hours `-1, NITE`) | `OBJECTTYPE_SCRIPT` | `MomScript` | `EVENT_PLAYERS_HOUSE_MOM_2` |

Mom's position depends on the time of day - a bot must find her, not assume (7,3).

`MomScript` (`60:56cb`): with `EVENT_GAVE_MYSTERY_EGG_TO_ELM` set it runs
`.GaveMysteryEgg` -> `setevent EVENT_FIRST_TIME_BANKING_WITH_MOM`,
`setevent EVENT_TALKED_TO_MOM_AFTER_MYSTERY_EGG_QUEST`, `special BankOfMom`.
That is the walkthrough's "talk to your mom, who will save your money", and it is
also what silences the Route 31 `SPECIALCALL_WORRIED` callback.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Cannot leave New Bark Town westward before a starter | `maps/NewBarkTown.asm:NewBarkTown_TeacherStopsYouScene1/2` at coord events (1,8)/(1,9), scene `SCENE_NEWBARKTOWN_TEACHER_STOPS_YOU` | a starter | `maps/ElmsLab.asm:ElmDirectionsScript` -> `setmapscene NEW_BARK_TOWN, SCENE_NEWBARKTOWN_NOOP` |
| Cannot leave the lab before a starter | `maps/ElmsLab.asm:LabTryToLeaveScript`, coord events (4,6)/(5,6) under `SCENE_ELMSLAB_CANT_LEAVE` | a starter | same `ElmDirectionsScript`, via `setscene SCENE_ELMSLAB_AIDE_GIVES_POTION` |
| Route 30 west fork blocked by "the two boys battling" | `maps/Route30.asm` object rows at (5,24), (5,25), (5,26), all flagged `EVENT_ROUTE_30_BATTLE`; objects are visible while the flag is **clear** (`engine/overworld/map_objects_2.asm:CheckObjectFlag`) | deliver the MYSTERY EGG | `maps/ElmsLab.asm:ElmAfterTheftScript` -> `setevent EVENT_ROUTE_30_BATTLE` (hides them) and `clearevent EVENT_ROUTE_30_YOUNGSTER_JOEY` (spawns Joey the trainer) |
| Rival battle before leaving Cherrygrove east | `maps/CherrygroveCity.asm` coord events (33,6)/(33,7) under `SCENE_CHERRYGROVECITY_MEET_RIVAL` | none - it is `BATTLETYPE_CANLOSE`, so a loss still advances | armed by `maps/MrPokemonsHouse.asm:MrPokemonsHouse_OakScript` (`setmapscene CHERRYGROVE_CITY, ...`); cleared by the scene's own `setscene SCENE_CHERRYGROVECITY_NOOP` |
| Cop cutscene in Elm's Lab | `maps/ElmsLab.asm` coord events (4,5)/(5,5) under `SCENE_ELMSLAB_MEET_OFFICER` -> `CopScript` (`special NameRival`) | walk to y=5 | `setscene SCENE_ELMSLAB_NOOP` at the end of `CopScript` |
| POKE BALLs not for sale | `maps/CherrygroveMart.asm:CherrygroveMartClerkScript` (`checkevent EVENT_GAVE_MYSTERY_EGG_TO_ELM`) -> `MART_CHERRYGROVE` vs `MART_CHERRYGROVE_DEX` in `data/items/marts.asm` | deliver the egg | `ElmAfterTheftScript` |
| Catch tutorial cannot fire yet | `maps/Route29.asm` coord events (53,8)/(53,9) need scene `SCENE_ROUTE29_CATCH_TUTORIAL` | deliver the egg | `ElmAfterTheftScript` -> `setmapscene ROUTE_29, SCENE_ROUTE29_CATCH_TUTORIAL` |
| Dark Cave is unusable (the walkthrough's "wait for Flash") | `engine/events/overworld.asm:FlashFunction/.CheckUseFlash`: `ld de, ENGINE_ZEPHYRBADGE / farcall CheckBadge / jr c, .nozephyrbadge`, then `wTimeOfDayPalset == DARKNESS_PALSET` | ZEPHYRBADGE **and** HM05 Flash in the party | Violet Gym, next sections. The cave itself is enterable (`Route31` warp 3 at (34,5)) - it is just black |
| Tuscany / PINK BOW not obtainable | `maps/Route29.asm:Route29TuscanyCallback` - `checkflag ENGINE_ZEPHYRBADGE`, else `disappear`; then `VAR_WEEKDAY == TUESDAY` | ZEPHYRBADGE + Tuesday | later section |
| Mom's "worried" call | `maps/Route31.asm:Route31CheckMomCallCallback` - fires `SPECIALCALL_WORRIED` unless `EVENT_TALKED_TO_MOM_AFTER_MYSTERY_EGG_QUEST` | not a blocker, but an unavoidable interruption | talk to Mom (`MomScript`) before entering Route 31 |

---

## 4. Bot checklist

Preconditions in brackets, postconditions after the arrow.

1. `ELMS_LAB` - walk to (4,8) or (5,8). [scene `SCENE_ELMSLAB_AIDE_GIVES_POTION`]
   -> aide script runs, POTION in bag, `setscene SCENE_ELMSLAB_NOOP`.
2. `ELMS_LAB` - warp out at (4,11)/(5,11) -> `NEW_BARK_TOWN` warp 1 (6,3).
3. `NEW_BARK_TOWN` - walk west past x=1. [`SCENE_NEWBARKTOWN_NOOP`] -> Route 29
   (west connection).
4. `ROUTE_29` - walk west along y=11..13. Optional: face (12,2) and press A ->
   BERRY (`fruittree`, daily); face/step on (48,2) and press A -> POTION,
   sets `EVENT_ROUTE_29_POTION`.
5. `ROUTE_29` - grind wild encounters (10% step rate, `def_grass_wildmons ROUTE_29`)
   to the walkthrough's level 8.
6. `ROUTE_29` -> `CHERRYGROVE_CITY` (west connection). -> map callback sets
   `ENGINE_FLYPOINT_CHERRYGROVE`.
7. `CHERRYGROVE_CITY` - talk to `CHERRYGROVECITY_GRAMPS` at (32,6), answer YES.
   [`EVENT_GUIDE_GENT_IN_HIS_HOUSE` clear] -> follow tour, MAP CARD,
   `setflag ENGINE_MAP_CARD`, gramps disappears.
8. `CHERRYGROVE_CITY` - warp 2 at (29,3) -> Pokecenter; talk to nurse at (3,1)
   from (3,2) -> party healed. Exit warps 1/2 at (3,7)/(4,7).
9. `CHERRYGROVE_CITY` - walk north out of the map (north connection, offset 5) ->
   `ROUTE_30`, arriving at high y.
10. `ROUTE_30` - warp 1 at (7,39) -> berry house; talk to the Pokefan at (2,3)
    -> BERRY, `EVENT_GOT_BERRY_FROM_ROUTE_30_HOUSE`. Exit warps 1/2 at (2,7)/(3,7).
11. `ROUTE_30` - face (11,5) press A -> PSNCUREBERRY (daily). Face (14,9) press A
    -> hidden POTION, `EVENT_ROUTE_30_HIDDEN_POTION`.
12. `ROUTE_30` - take the **east** fork north to warp 2 at (17,5) ->
    `MR_POKEMONS_HOUSE`.
13. `MR_POKEMONS_HOUSE` - the scene fires on load
    (`SCENE_MRPOKEMONSHOUSE_MEET_MR_POKEMON`). Just advance text.
    -> `MYSTERY_EGG`, `EVENT_GOT_MYSTERY_EGG_FROM_MR_POKEMON`,
    `blackoutmod CHERRYGROVE_CITY`, `ENGINE_POKEDEX`, party healed,
    `SPECIALCALL_ROBBED` queued, `EVENT_COP_IN_ELMS_LAB` cleared,
    `SCENE_CHERRYGROVECITY_MEET_RIVAL` and `SCENE_ELMSLAB_MEET_OFFICER` armed.
14. Walk out (warps 1/2 at (2,7)/(3,7)) and take a few overworld steps ->
    Elm's phone call (`engine/phone/scripts/elm.asm` `.disaster`) ->
    `EVENT_ELM_CALLED_ABOUT_STOLEN_POKEMON`.
15. `ROUTE_30` south -> `CHERRYGROVE_CITY`. Heal at the Pokecenter.
16. `CHERRYGROVE_CITY` - walk east through x=33 on row 6 or 7. -> rival scene,
    battle `RIVAL1` id 1/2/3 by starter (level 5, `BATTLETYPE_CANLOSE`), then
    `special HealParty`, `SCENE_CHERRYGROVECITY_NOOP`.
17. `CHERRYGROVE_CITY` east -> `ROUTE_29` east -> `NEW_BARK_TOWN`.
18. `NEW_BARK_TOWN` - warp 1 at (6,3) -> `ELMS_LAB`. Step onto (4,5) or (5,5)
    [`SCENE_ELMSLAB_MEET_OFFICER`] -> `CopScript`, `special NameRival` prompt,
    officer leaves, `SCENE_ELMSLAB_NOOP`.
19. `ELMS_LAB` - talk to `ELMSLAB_ELM` at (5,2). [`MYSTERY_EGG` in bag]
    -> `ElmAfterTheftScript`: egg taken, `EVENT_GAVE_MYSTERY_EGG_TO_ELM`,
    Route 29 tutorial armed, Route 30 blockers removed, Joey spawned,
    `SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS`.
20. `ELMS_LAB` - walk to (4,8) or (5,8) -> aide gives 5 POKE BALLs.
21. `NEW_BARK_TOWN` - warp 2 at (13,5) -> `PLAYERS_HOUSE_1F`; talk to Mom
    (position depends on time of day: (7,3) by day, (2,2) morn, (0,2) nite)
    -> `EVENT_TALKED_TO_MOM_AFTER_MYSTERY_EGG_QUEST`,
    `EVENT_FIRST_TIME_BANKING_WITH_MOM`, Bank of Mom menu.
22. `ROUTE_29` - step on (53,8) or (53,9) -> catch tutorial. YES runs the demo
    (`loadwildmon RATTATA, 5` + `catchtutorial`); NO also clears the scene.
23. Optional `ROUTE_46`: `ROUTE_29` warp 1 at (27,1) -> gate warp 3, gate warps
    1/2 at (4,0)/(5,0) -> Route 46 (7,33)/(8,33). Hunt RATTATA (night has two
    RATTATA slots). Grab DIRE_HIT at (0,12). Avoid the three trainers - they are
    L13-L17 and far above the party.
24. `CHERRYGROVE_CITY` - heal; optionally buy POKE BALLs (`MART_CHERRYGROVE_DEX`
    is live now) via warp 1 at (23,3).
25. `ROUTE_30` - take the **west** fork north. Trainers in walk order:
    `TrainerYoungsterJoey` at (6,29) sight 4, `TrainerYoungsterMikey` at (5,23)
    sight 1, `TrainerBugCatcherDon` at (4,7) sight 3.
    -> `EVENT_BEAT_YOUNGSTER_JOEY`, `EVENT_BEAT_YOUNGSTER_MIKEY`,
    `EVENT_BEAT_BUG_CATCHER_DON`. Joey will ask for a phone number.
26. `ROUTE_30` north (y -> 0) -> `ROUTE_31`. -> map callback: if Mom was not
    talked to, `SPECIALCALL_WORRIED` is queued.
27. `ROUTE_31` - item ball at (29,5) -> ANTIDOTE. Sign at (31,5) is the Dark Cave
    sign; the cave warp is at (34,5) - **skip it**, no Flash.
28. `ROUTE_31` - `TrainerBugCatcherWade1` at (18,15), sight 3 (approach from below).
    -> `EVENT_BEAT_BUG_CATCHER_WADE`, phone number offer.
29. `ROUTE_31` - item ball at (21,13) -> POKE BALL. Tree at (16,7) -> BITTER BERRY.
30. `ROUTE_31` - warps 1/2 at (4,6)/(4,7) -> `ROUTE_31_VIOLET_GATE` warps 3/4;
    cross to gate warps 1/2 at (0,4)/(0,5) -> `VIOLET_CITY` warps 8/9.
    **End of section.**

---

## 5. Port coverage

The Gen 2 port is data-driven: `src/import/RomExtractorGen2.lua` reads map headers,
warps, coord events, bg events, object events, trainer structs and encounter tables
out of the ROM, and `src/world/gen2/World.lua` + `src/script/gen2/Vm.lua` replay
them. So coverage below is per-mechanic, not per-map.

| Beat | Port file | Status |
|---|---|---|
| Map headers / warps / connections / coord events / bg events / objects | `src/import/RomExtractorGen2.lua`, `src/world/gen2/Map.lua`, `src/world/gen2/World.lua` (`self.map.def.coordEvents` at World.lua:5013) | implemented |
| Scene scripts + `setscene` / `setmapscene` | `src/script/gen2/Vm.lua` (`setmapscene` at Vm.lua:279), `src/world/gen2/World.lua` (`s.sceneId` match at World.lua:5033) | implemented |
| Object visibility from `EVENT_*` (`appear` / `disappear`, the Route 30 blockers, the rival, the cop) | `src/world/gen2/Events.lua`, `src/world/gen2/World.lua` | implemented |
| `follow` / `stopfollow` (Guide Gent tour, catch-tutorial DUDE, New Bark teacher) | `src/script/gen2/Vm.lua:982` | implemented; driver `tests/drivers/gold_teacher_scene.lua` asserts the follow leg |
| Overworld trainer sight + battle + beat flag | `src/world/gen2/Trainers.lua`, `src/world/gen2/World.lua` | implemented; driver `tests/drivers/gold_trainer_smoke.lua` runs the **Route 30 bug catcher** end to end |
| Trainer phone numbers / rematch chain (Joey, Wade) | `src/core/gen2/Phone.lua`, `src/script/gen2/Vm.lua` (`askforphonenumber`, `checkcellnum`) | implemented (not audited against this section's specific rematch gates) |
| `specialphonecall` queue + Elm's `SPECIALCALL_ROBBED` / Mom's `SPECIALCALL_WORRIED` | `src/script/gen2/Vm.lua:1364`, `src/core/gen2/Phone.lua` | implemented |
| Catch tutorial (`catchtutorial BATTLETYPE_TUTORIAL`) | `src/core/gen2/CatchTutorial.lua`, `src/core/gen2/AutoInput.lua`, `src/script/gen2/Vm.lua` | implemented |
| Fruit trees (Route 29/30/31/46 berries) | `src/script/gen2/Vm.lua:1191` (inlines `FruitTreeScript` because the extractor cannot reach it), `src/core/gen2/Apricorns.lua` | implemented |
| Hidden items (`BGEVENT_ITEM`, Route 30's POTION) | `src/world/gen2/HiddenItems.lua`, dispatch at `src/world/gen2/World.lua:5291-5296` | implemented |
| **Item balls** (`OBJECTTYPE_ITEMBALL`: Route 29 POTION, Route 31 ANTIDOTE + POKE BALL, Route 46 DIRE HIT) | extracted into `obj.itemball` at `src/import/RomExtractorGen2.lua:2968`; **nothing consumes it** - the A-press dispatch at `src/world/gen2/World.lua:5265-5296` only handles trainer, strength boulder, `scriptKey`, then hidden items, and `itemball` appears nowhere else in `src/` | **missing** - every ground item ball in this section is un-takeable |
| `verbosegiveitem` / `giveitem` / `itemnotify` (egg, Poke Balls, berries, MYSTIC WATER) | `src/script/gen2/Vm.lua` | implemented |
| `pokemart` + the `MART_CHERRYGROVE` / `MART_CHERRYGROVE_DEX` switch | `src/ui/gen2/MartMenu.lua`, `src/script/gen2/Vm.lua` | implemented (the switch itself is just a `checkevent`, so it follows for free) |
| `special BankOfMom` (Mom saving money) | `src/ui/gen2/BankOfMom.lua`, `src/script/gen2/Specials.lua` | implemented; driver `tests/drivers/gold_mom_scene.lua` covers the `MeetMomScript` cutscene, not the banking talk |
| `special NameRival` (cop scene) | `src/script/gen2/Specials.lua`, `src/ui/gen2/NamingScreen.lua` | implemented |
| `setflag ENGINE_POKEDEX` / `ENGINE_FLYPOINT_*` / `ENGINE_ZEPHYRBADGE` | `src/script/gen2/Vm.lua:208`, `src/world/gen2/World.lua:1304-1339` (`save.engineFlags`) | implemented |
| **`setflag ENGINE_MAP_CARD` reaching the Pokegear** | written to `save.engineFlags` (World.lua:1325); `src/ui/gen2/Pokegear.lua:935` reads `save.pokegearFlags` with keys `map` / `radio` / `phone`, and no code in the repo writes `pokegearFlags` outside tests and `tests/drivers/gold_menu_shots.lua` | **partial** - the Guide Gent's reward is recorded but the MAP card will not appear on the Pokegear |
| Time-of-day wild tables (morn/day/nite split, per-time rate) | `src/battle/gen2/Encounter.lua` | implemented |
| Fishing groups (`FISHGROUP_SHORE` / `FISHGROUP_POND`) | `src/battle/gen2/Encounter.lua:81-99` | implemented |
| Water encounters (Route 30/31 Poliwag) | `src/battle/gen2/Encounter.lua` | implemented but unreachable in this section (needs Surf) |
| Flash / `ENGINE_ZEPHYRBADGE` gate on Dark Cave | `src/world/gen2/FieldMoves.lua` | implemented |
| `blackoutmod CHERRYGROVE_CITY` | `src/script/gen2/Vm.lua`, `src/world/gen2/World.lua` | implemented |
| Route 29 Tuscany weekday/badge callback | `src/world/gen2/World.lua` map callbacks; asserted by `tests/drivers/gold_map_callbacks.lua:118-158` | implemented |
| New Bark -> Route 29 edge crossing | `tests/drivers/gold_walk_smoke.lua` | implemented (driver walks bedroom -> Route 29) |
| Cherrygrove City itself (guide tour, rival scene, Pokecenter) | no dedicated driver found under `tests/drivers/gold_*.lua` | untested |

---

## 6. Unresolved / verify by hand

1. **Route 30 "Antidote" does not exist.** The walkthrough says "Just above the
   house is an Antidote". `maps/Route30.asm` has no `OBJECTTYPE_ITEMBALL` object
   at all; the only ground item is the hidden `POTION` at bg event (14,9)
   (`Route30HiddenPotion`). The ANTIDOTE is on Route 31, item ball at (29,5).
2. **Route 31 "Potion" is an Antidote.** The walkthrough says "grab that Potion to
   the left of [Dark Cave]". The ball west of the Dark Cave mouth (34,5) is at
   (29,5) and is `itemball ANTIDOTE`. There is no POTION object on Route 31.
3. **Youngster Mikey's party.** The walkthrough says "Level 2 Rattata / Level 4
   Rattata". `data/trainers/parties.asm` `YoungsterGroup` (2) "MIKEY" is
   `db 2, PIDGEY` / `db 4, RATTATA`.
4. **Hoppip on Route 29.** Listed by the walkthrough (#187), absent from
   `def_grass_wildmons ROUTE_29`. Hoppip's first Johto grass appearance is
   Route 32.
5. **Zubat and Poliwag on Routes 30/31.** Listed by the walkthrough. Poliwag is
   in `data/wild/johto_water.asm` (surf, 2% rate) and in `.Pond_*` fishing, not in
   grass. Zubat is not in either route's grass table at any time of day - it is a
   Dark Cave mon.
6. **Weedle / Kakuna on Routes 30-31 in a Gold run.** The walkthrough lists them
   for both routes; in `data/wild/johto_grass.asm` those slots are inside the
   `ELIF DEF(_SILVER)` arm. A Gold cart gets CATERPIE / METAPOD instead. The
   walkthrough's own "(Silver only)" / "(Gold only)" notes are right for Ledyba
   and Spinarak but not applied to Weedle/Kakuna.
7. **"Pink Bow" listed as a Route 29 item.** Reachable only with
   `ENGINE_ZEPHYRBADGE` **and** `VAR_WEEKDAY == TUESDAY`
   (`Route29TuscanyCallback`), so it cannot be collected during this section.
8. **Onix in Violet City / TM31 / PRZCure Berry.** Listed in the walkthrough's
   Violet City preamble; `maps/VioletCity.asm` was not opened (next section owns
   it) so none of it is verified here.
9. **"You get: 300G / 64G / 48G / 32G".** Verified indirectly: reward =
   `base_reward * last mon level` (`engine/battle/read_trainer_party.asm:300`
   `ComputeTrainerReward`) paid four times by the `ld c, 4` loop in
   `engine/battle/core.asm:2340-2361`. All four figures match. Worth a hand-check
   in an emulator if a bot budgets money precisely, because the split between
   `wMomsMoney` and `wMoney` depends on `wMomSavingMoney`, i.e. on whether the
   player has done step 21.
10. **`EVENT_ROUTE_30_BATTLE` as a physical block.** The three objects at
    (5,24)/(5,25)/(5,26) are what the walkthrough calls "You can't pass that area
    just yet". Confirmed that they exist and vanish on
    `ElmAfterTheftScript`, but whether that column of three fully seals the west
    lane depends on `maps/Route30.blk` collision, which was not decoded. Verify in
    game if a bot pathfinder wants to rely on it.
11. **MAP CARD on the Pokegear in this port.** See section 5 - the flag is stored
    under `save.engineFlags` while the Pokegear reads `save.pokegearFlags`. No
    bridge was found by grep; if one exists it is somewhere the string
    `pokegearFlags` does not appear.

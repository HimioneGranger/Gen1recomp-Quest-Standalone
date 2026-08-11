# Section 19 - S.S. Aqua and Vermilion City Gym

Source: `../section-19-s-s-aqua-and-vermilion-city-gym.txt`
Maps covered: `NEW_BARK_TOWN`, `ELMS_LAB`, `OLIVINE_PORT_PASSAGE`, `OLIVINE_PORT`,
`FAST_SHIP_1F`, `FAST_SHIP_CABINS_NNW_NNE_NE`, `FAST_SHIP_CABINS_SW_SSW_NW`,
`FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN`, `FAST_SHIP_B1F`, `VERMILION_PORT`,
`VERMILION_PORT_PASSAGE`, `VERMILION_CITY`, `POKEMON_FAN_CLUB`, `VERMILION_GYM`
Badges / key milestones in this section: S.S. TICKET from Prof. Elm, first Kanto
crossing on the Fast Ship, METAL COAT from the grandpa on the S.S. Aqua,
`ENGINE_FLYPOINT_VERMILION`, RARE CANDY from the Fan Club Chairman,
**THUNDERBADGE** (`ENGINE_THUNDERBADGE`) from Lt. Surge.

This section begins immediately after the Hall of Fame. `maps/HallOfFame.asm`
`HallOfFameEnterScript` is what arms it: it sets `EVENT_BEAT_ELITE_FOUR`, sets
`EVENT_OLIVINE_PORT_SPRITES_BEFORE_HALL_OF_FAME` (hiding the "no entry" sailor
pair), clears `EVENT_OLIVINE_PORT_SPRITES_AFTER_HALL_OF_FAME` (revealing the
boarding sailor), and, if `EVENT_GOT_SS_TICKET_FROM_ELM` is still clear, queues
`specialphonecall SPECIALCALL_SSTICKET` (the Elm call the walkthrough mentions).

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `NEW_BARK_TOWN` | `maps/NewBarkTown.asm` | post-credits respawn | warp 1 `(6,3)` -> `ELMS_LAB` 1 | Elm phones you to come back |
| 2 | `ELMS_LAB` | `maps/ElmsLab.asm` | warp 1/2 `(4,11)`/`(5,11)` | same warps back to `NEW_BARK_TOWN` 1 | talk to `ProfElmScript` -> `ElmGiveTicketScript` -> S.S. TICKET |
| 3 | `OLIVINE_CITY` | `maps/OlivineCity.asm` | Fly (`ENGINE_FLYPOINT_OLIVINE`) | warp 10 `(19,27)` / warp 11 `(20,27)` -> `OLIVINE_PORT_PASSAGE` 1/2 | "go south from the Pokemon Center" to the port entrance |
| 4 | `OLIVINE_PORT_PASSAGE` | `maps/OlivinePortPassage.asm` | warps 1/2 `(15,0)`/`(16,0)` | warp 3 `(15,4)` -> warp 4 `(3,2)`, then warp 5 `(3,14)` -> `OLIVINE_PORT` 1 | "take the stairs down twice" |
| 5 | `OLIVINE_PORT` | `maps/OlivinePort.asm` | warp 1 `(11,7)` | coord_event `(7,15)` -> `OlivinePortWalkUpToShipScript` -> `warp FAST_SHIP_1F, 25, 1` | show the S.S. TICKET, board |
| 6 | `FAST_SHIP_1F` | `maps/FastShip1F.asm` | scripted warp to `(25,1)` | 12 warps (see below) | ship deck hub; grandpa bumps you at `(24,6)`/`(25,6)` |
| 7 | `FAST_SHIP_CABINS_NNW_NNE_NE` | `maps/FastShipCabins_NNW_NNE_NE.asm` | 1F warps 2/3/4 (`(27,8)`, `(23,8)`, `(19,8)`) | same | Hiker Noland; later the lazy Sailor Stanly |
| 8 | `FAST_SHIP_CABINS_SW_SSW_NW` | `maps/FastShipCabins_SW_SSW_NW.asm` | 1F warps 5/6/7 (`(15,8)`, `(15,15)`, `(19,15)`) | same | your cabin + healing bed; Firebreather Lyle |
| 9 | `FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN` | `maps/FastShipCabins_SE_SSE_CaptainsCabin.asm` | 1F warps 8/9/10 (`(23,15)`, `(27,15)`, `(3,13)`) | same | PoKeFan Colin + Twins; grandpa; captain's cabin + granddaughter |
| 10 | `FAST_SHIP_B1F` | `maps/FastShipB1F.asm` | 1F warps 11/12 (`(6,12)`, `(30,14)`) | same | on-duty sailor blocks; Fritz, Jeff, Debra |
| 11 | `VERMILION_PORT` | `maps/VermilionPort.asm` | `FastShip1FSailor1Script` -> `warp VERMILION_PORT, 7, 17` | warp 1 `(9,5)` -> `VERMILION_PORT_PASSAGE` 5 | ship docks in Kanto |
| 12 | `VERMILION_PORT_PASSAGE` | `maps/VermilionPortPassage.asm` | warp 5 `(3,14)` | warp 4 `(3,2)` -> warp 3 `(15,4)`, then warps 1/2 `(15,0)`/`(16,0)` -> `VERMILION_CITY` 8/9 | "down the stairs, then up the stairs and out the door" |
| 13 | `VERMILION_CITY` | `maps/VermilionCity.asm` | warps 8/9 `(19,31)`/`(20,31)` | warp 3 `(7,13)`, warp 7 `(10,19)` | first look at Kanto |
| 14 | `POKEMON_FAN_CLUB` | `maps/PokemonFanClub.asm` | warp 1/2 `(2,7)`/`(3,7)` | same | Chairman's speech -> RARE CANDY |
| 15 | `VERMILION_GYM` | `maps/VermilionGym.asm` | warps 1/2 `(4,17)`/`(5,17)` | same | Vincent, Horton, Gregory, then Lt. Surge -> THUNDERBADGE |

Spill-over note: the walkthrough's closing line ("Congrats on your first badge in
Kanto") ends the section; Saffron City / Route 6 are handled by the next
section's agent. `VERMILION_CITY` connects `north Route6 (+5)` and
`east Route11 (0)` (`data/maps/attributes.asm:342-344`), and warp 10 `(34,7)` to
`DIGLETTS_CAVE` sits behind the sleeping Snorlax; none of those are used here.

---

## 2. Maps

### MAP_ELMS_LAB

- Script: `maps/ElmsLab.asm`
- Blocks: `maps/ElmsLab.blk`
- Header: `data/maps/maps.asm:476` -> `map ElmsLab, TILESET_LAB, INDOOR, LANDMARK_NEW_BARK_TOWN, MUSIC_PROF_ELM, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:441` `map_const ELMS_LAB, 5, 6` (10 x 12 cells)
- Connections: none (indoor)

Only the S.S. TICKET beat is in scope. Full warp/object tables for the early-game
scenes belong to section 1; the rows below are the ones this section touches.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 11 | `NEW_BARK_TOWN` | 1 |
| 2 | 5 | 11 | `NEW_BARK_TOWN` | 1 |

**Object events** (`def_object_events`) - relevant row only

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ELMSLAB_ELM` | `SPRITE_ELM` | 5 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `ProfElmScript` | `-1` |

**Scripts of interest**

- `ProfElmScript` (`maps/ElmsLab.asm:50`, sym `60:427b` for `ElmGiveTicketScript`).
  First two opcodes after `faceplayer`/`opentext` are the ticket gate:
  `checkevent EVENT_GOT_SS_TICKET_FROM_ELM` / `iftrue ElmCheckMasterBall`, then
  `checkevent EVENT_BEAT_ELITE_FOUR` / `iftrue ElmGiveTicketScript`. So the ticket
  is handed out on the first post-Hall-of-Fame conversation and never again.
- `ElmGiveTicketScript`: `writetext ElmGiveTicketText1` ->
  `verbosegiveitem S_S_TICKET` -> `setevent EVENT_GOT_SS_TICKET_FROM_ELM` ->
  `writetext ElmGiveTicketText2` -> `closetext` / `end`.
  Note there is **no** `iffalse` bag-full guard on this `verbosegiveitem`, unlike
  every other Elm gift in the same file - the flag is set unconditionally.
- `engine/phone/scripts/elm.asm:69` `ElmPhoneCallerScript` routes
  `SPECIALCALL_SSTICKET` to `.gift`, which prints `ElmPhoneGiftText` and clears
  the pending call with `specialphonecall SPECIALCALL_NONE`. The call is only the
  nudge; it does not give the item.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_ELITE_FOUR` | `constants/event_flags.asm:77` | set by `maps/HallOfFame.asm:33`; read by `ProfElmScript` | precondition for the ticket |
| `EVENT_GOT_SS_TICKET_FROM_ELM` | `constants/event_flags.asm:45` | set by `ElmGiveTicketScript`; read by `ProfElmScript` and `HallOfFame.asm:41` | one-time ticket guard |
| `SPECIALCALL_SSTICKET` | `constants/phone_constants.asm:49` | queued by `HallOfFame.asm:43`, consumed in `engine/phone/scripts/elm.asm` | the phone nudge; ignorable |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `S_S_TICKET` | talk to Elm | `ElmGiveTicketScript` `verbosegiveitem S_S_TICKET` | `EVENT_GOT_SS_TICKET_FROM_ELM` |

### MAP_OLIVINE_PORT_PASSAGE

- Script: `maps/OlivinePortPassage.asm`
- Blocks: `maps/PortPassage.blk` (shared with `VermilionPortPassage`; there is no
  `OlivinePortPassage.blk`)
- Header: `data/maps/maps.asm:340` -> `map OlivinePortPassage, TILESET_UNDERGROUND, INDOOR, LANDMARK_OLIVINE_CITY, MUSIC_VIOLET_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:314` `map_const OLIVINE_PORT_PASSAGE, 10, 9` (20 x 18 cells)
- Connections: none

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 15 | 0 | `OLIVINE_CITY` | 10 |
| 2 | 16 | 0 | `OLIVINE_CITY` | 11 |
| 3 | 15 | 4 | `OLIVINE_PORT_PASSAGE` | 4 |
| 4 | 3 | 2 | `OLIVINE_PORT_PASSAGE` | 3 |
| 5 | 3 | 14 | `OLIVINE_PORT` | 1 |

**Coord events** - none.

**BG events** - none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `OLIVINEPORTPASSAGE_POKEFAN_M` | `SPRITE_POKEFAN_M` | 17 | 1 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `OlivinePortPassagePokefanMScript` | `EVENT_OLIVINE_PORT_PASSAGE_POKEFAN_M` |

The Pokefan is hidden at new game (`InitializeEventsScript`,
`engine/events/std_scripts.asm:530` sets the flag) and revealed by
`VermilionPortLeaveShipScript` (`clearevent EVENT_OLIVINE_PORT_PASSAGE_POKEFAN_M`)
once you have made the crossing once. His text is the Monday/Friday schedule.

### MAP_OLIVINE_PORT

- Script: `maps/OlivinePort.asm`
- Blocks: `maps/OlivinePort.blk`
- Header: `data/maps/maps.asm:333` -> `map OlivinePort, TILESET_PORT, ROUTE, LANDMARK_OLIVINE_CITY, MUSIC_VIOLET_CITY, FALSE, PALETTE_AUTO, FISHGROUP_OCEAN`
- Dimensions: `constants/map_constants.asm:307` `map_const OLIVINE_PORT, 10, 18` (20 x 36 cells)
- Attributes: `data/maps/attributes.asm:586` `map_attributes OlivinePort, OLIVINE_PORT, $0a` - no connections

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 11 | 7 | `OLIVINE_PORT_PASSAGE` | 5 |
| 2 | 7 | 23 | `FAST_SHIP_1F` | 1 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_OLIVINEPORT_ASK_ENTER_SHIP` (0) | 7 | 15 | `OlivinePortWalkUpToShipScript` (sym `5b:407d`) | boarding prompt + ticket check |

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 1 | 22 | `BGEVENT_ITEM` | `OlivinePortHiddenProtein` -> `hiddenitem PROTEIN, EVENT_OLIVINE_PORT_HIDDEN_PROTEIN` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `OLIVINEPORT_SAILOR1` | `SPRITE_SAILOR` | 7 | 23 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `OlivinePortSailorAtGangwayScript` | `EVENT_OLIVINE_PORT_SAILOR_AT_GANGWAY` |
| `OLIVINEPORT_SAILOR2` | `SPRITE_SAILOR` | 7 | 15 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `OlivinePortSailorBeforeHOFScript` | `EVENT_OLIVINE_PORT_SPRITES_BEFORE_HALL_OF_FAME` |
| `OLIVINEPORT_SAILOR3` | `SPRITE_SAILOR` | 6 | 15 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `OlivinePortSailorAfterHOFScript` | `EVENT_OLIVINE_PORT_SPRITES_AFTER_HALL_OF_FAME` |
| `OLIVINEPORT_FISHING_GURU1` | `SPRITE_FISHING_GURU` | 4 | 14 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `OlivinePortFishingGuru1Script` | `EVENT_OLIVINE_PORT_SPRITES_BEFORE_HALL_OF_FAME` |
| `OLIVINEPORT_FISHING_GURU2` | `SPRITE_FISHING_GURU` | 13 | 14 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `OlivinePortFishingGuru2Script` | `EVENT_OLIVINE_PORT_SPRITES_BEFORE_HALL_OF_FAME` |
| `OLIVINEPORT_YOUNGSTER` | `SPRITE_YOUNGSTER` | 4 | 15 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `OlivinePortYoungsterScript` | `EVENT_OLIVINE_PORT_SPRITES_AFTER_HALL_OF_FAME` |
| `OLIVINEPORT_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 11 | 15 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `OlivinePortCooltrainerFScript` | `EVENT_OLIVINE_PORT_SPRITES_AFTER_HALL_OF_FAME` |

Object event flags hide when **set**. Post-Hall-of-Fame, `SAILOR2` and the two
fishing gurus are gone and `SAILOR3` / youngster / cooltrainer are present.

**Scripts of interest**

- `OlivinePortWalkUpToShipScript` (coord event at `(7,15)`): turns `SAILOR3`
  right, bails via `.skip` if either `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1` or
  `_2` is set, else asks `OlivinePortAskBoardText` with `yesorno`.
  If `EVENT_FAST_SHIP_FIRST_TIME` is **clear** it jumps straight past the
  weekday gate (`.FirstTime`) - the maiden voyage sails any day.
  Otherwise `readvar VAR_WEEKDAY`: `SUNDAY`/`SATURDAY` -> `.NextShipMonday`,
  `TUESDAY`/`WEDNESDAY`/`THURSDAY` -> `.NextShipFriday`. So from Olivine the ship
  sails **Monday and Friday**.
  Then `checkitem S_S_TICKET`; `iffalse .NoTicket`. On success it sets
  `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_2`, walks the player 7 steps down
  (`OlivinePortApproachFastShipFirstTimeMovement`) and `sjump`s into
  `OlivinePortSailorAtGangwayScript`.
- `OlivinePortSailorAtGangwayScript`: `disappear OLIVINEPORT_SAILOR1`, one step
  down, `special FadeOutToWhite`, then the passenger-roster bookkeeping.
  On repeat trips only (`checkevent EVENT_FAST_SHIP_FIRST_TIME` / `iffalse
  .FirstTime`) it does `clearevent EVENT_FAST_SHIP_PASSENGERS_EASTBOUND`,
  `setevent EVENT_FAST_SHIP_PASSENGERS_WESTBOUND` and clears the eight
  eastbound `EVENT_BEAT_*` rematch flags. Always:
  `clearevent EVENT_FAST_SHIP_DESTINATION_OLIVINE`,
  `appear OLIVINEPORT_SAILOR1`,
  `setmapscene FAST_SHIP_1F, SCENE_FASTSHIP1F_ENTER_SHIP`,
  `warp FAST_SHIP_1F, 25, 1`.
- `OlivinePortLeaveShipScript` (scene `SCENE_OLIVINEPORT_LEAVE_SHIP`, 1): the
  arrival cutscene for the return trip - one step up, `appear` the sailor,
  `setscene SCENE_OLIVINEPORT_ASK_ENTER_SHIP`,
  `setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1`, `blackoutmod OLIVINE_CITY`.

**Wild encounters**

`data/wild/johto_water.asm:278` `def_water_wildmons OLIVINE_PORT`, encounter rate
`2 percent`: `20 TENTACOOL / 15 TENTACOOL / 20 TENTACRUEL`.
Fishing group `FISHGROUP_OCEAN` (`data/wild/fish.asm:13`, `.Ocean_*` at lines
42-55). No grass, no headbutt table.

### MAP_FAST_SHIP_1F

- Script: `maps/FastShip1F.asm`
- Blocks: `maps/FastShip1F.blk`
- Header: `data/maps/maps.asm:335` -> `map FastShip1F, TILESET_LIGHTHOUSE, INDOOR, LANDMARK_FAST_SHIP, MUSIC_SS_AQUA, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:309` `map_const FAST_SHIP_1F, 16, 9` (32 x 18 cells)
- Connections: none

Scene ids are declared inline by `scene_script` (`macros/scripts/maps.asm:25`):
`SCENE_FASTSHIP1F_NOOP` = 0, `SCENE_FASTSHIP1F_ENTER_SHIP` = 1,
`SCENE_FASTSHIP1F_MEET_GRANDPA` = 2.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 25 | 1 | `FAST_SHIP_1F` | -1 (arrival tile only) |
| 2 | 27 | 8 | `FAST_SHIP_CABINS_NNW_NNE_NE` | 1 |
| 3 | 23 | 8 | `FAST_SHIP_CABINS_NNW_NNE_NE` | 2 |
| 4 | 19 | 8 | `FAST_SHIP_CABINS_NNW_NNE_NE` | 3 |
| 5 | 15 | 8 | `FAST_SHIP_CABINS_SW_SSW_NW` | 1 |
| 6 | 15 | 15 | `FAST_SHIP_CABINS_SW_SSW_NW` | 2 |
| 7 | 19 | 15 | `FAST_SHIP_CABINS_SW_SSW_NW` | 4 |
| 8 | 23 | 15 | `FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN` | 1 |
| 9 | 27 | 15 | `FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN` | 3 |
| 10 | 3 | 13 | `FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN` | 5 |
| 11 | 6 | 12 | `FAST_SHIP_B1F` | 1 |
| 12 | 30 | 14 | `FAST_SHIP_B1F` | 2 |

Warp 5 `(15,8)` is "your cabin" (the one with the healing bed). Warp 10 `(3,13)`
is the staircase to the captain's cabin.

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_FASTSHIP1F_MEET_GRANDPA` (2) | 24 | 6 | `WorriedGrandpaSceneLeft` (sym `5b:495d`) | grandpa runs in and bumps you |
| `SCENE_FASTSHIP1F_MEET_GRANDPA` (2) | 25 | 6 | `WorriedGrandpaSceneRight` | `moveobject FASTSHIP1F_GENTLEMAN, 20, 6` then falls through into `WorriedGrandpaSceneLeft` |

**BG events** - none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `FASTSHIP1F_SAILOR1` | `SPRITE_SAILOR` | 25 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `FastShip1FSailor1Script` | `-1` |
| `FASTSHIP1F_SAILOR2` | `SPRITE_SAILOR` | 14 | 7 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `FastShip1FSailor2Script` | `-1` |
| `FASTSHIP1F_SAILOR3` | `SPRITE_SAILOR` | 22 | 17 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius 2,0) | `OBJECTTYPE_SCRIPT` | `FastShip1FSailor3Script` | `-1` |
| `FASTSHIP1F_GENTLEMAN` | `SPRITE_GENTLEMAN` | 19 | 6 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_FAST_SHIP_1F_GENTLEMAN` |

**Scripts of interest**

- `FastShip1FEnterShipScript` (sym `5b:48ad`, scene 1, run via `sdefer`): sailor
  steps aside, player walks 2 down, sailor steps back and blocks the door,
  `playsound SFX_BOAT`, `earthquake 30`,
  `blackoutmod FAST_SHIP_CABINS_SW_SSW_NW` (your blackout respawn becomes your
  cabin), `clearevent EVENT_FAST_SHIP_HAS_ARRIVED`. Then
  `checkevent EVENT_FAST_SHIP_FIRST_TIME` / `iftrue .SkipGrandpa`: on the first
  crossing it sets `SCENE_FASTSHIP1F_MEET_GRANDPA`, otherwise
  `SCENE_FASTSHIP1F_NOOP`.
- `WorriedGrandpaSceneLeft`: `appear FASTSHIP1F_GENTLEMAN`, four `big_step RIGHT`,
  `playsound SFX_TACKLE`, knocks the player one step right,
  `writetext FastShip1FGrandpaText` ("My granddaughter is missing!"), then the
  gentleman runs off, `disappear`s and the scene is reset to
  `SCENE_FASTSHIP1F_NOOP`. Purely informational - it sets no quest flag.
- `FastShip1FSailor1Script` (the door guard at `(25,2)`): if
  `EVENT_FAST_SHIP_HAS_ARRIVED` is clear it just says "en route", branching on
  `EVENT_FAST_SHIP_DESTINATION_OLIVINE` for the destination name. Once arrived it
  runs `.LetThePlayerOut` (`readvar VAR_FACING`, two step-up variants), then
  `setevent EVENT_VERMILION_PORT_SAILOR_AT_GANGWAY` (note: **set** hides that
  object), `setmapscene VERMILION_PORT, SCENE_VERMILIONPORT_LEAVE_SHIP` and
  `warp VERMILION_PORT, 7, 17`. The Olivine-bound mirror is `._Olivine` ->
  `warp OLIVINE_PORT, 7, 23`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_FAST_SHIP_FIRST_TIME` | `constants/event_flags.asm:57` | set by `VermilionPortLeaveShipScript`; read by both port scripts, `FastShip1FEnterShipScript`, `FastShip1FSailor2Script`, `SSAquaCaptain`, `FastShipBed`, `FastShipB1FSailorScript` | "the maiden crossing is finished"; gates the weekday schedule and the grandpa quest |
| `EVENT_FAST_SHIP_HAS_ARRIVED` | `constants/event_flags.asm:58` | cleared on boarding, set by `SSAquaMetalCoatAndDocking` / `FastShipBed.CanArrive`; read by `FastShip1FSailor1Script` | the door guard will only let you off once this is set |
| `EVENT_FAST_SHIP_DESTINATION_OLIVINE` | `constants/event_flags.asm:56` | cleared at Olivine, set at Vermilion | which port the ship is heading for |
| `EVENT_FAST_SHIP_1F_GENTLEMAN` | `constants/event_flags.asm:1230` | set at new game (`std_scripts.asm:497`), `appear`/`disappear` in `WorriedGrandpaSceneLeft` | grandpa sprite visibility |

### MAP_FAST_SHIP_CABINS_NNW_NNE_NE

- Script: `maps/FastShipCabins_NNW_NNE_NE.asm`
- Blocks: `maps/FastShipCabins_NNW_NNE_NE.blk`
- Header: `data/maps/maps.asm:336` -> `map FastShipCabins_NNW_NNE_NE, TILESET_LIGHTHOUSE, INDOOR, LANDMARK_FAST_SHIP, MUSIC_SS_AQUA, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:310` `map_const FAST_SHIP_CABINS_NNW_NNE_NE, 4, 16` (8 x 32 cells)
- Layout: three stacked sub-rooms, `y` 0-11, 12-23, 24-31.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 0 | `FAST_SHIP_1F` | 2 |
| 2 | 2 | 12 | `FAST_SHIP_1F` | 3 |
| 3 | 2 | 24 | `FAST_SHIP_1F` | 4 |

**Coord events** - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 6 | 13 | `BGEVENT_READ` | `FastShipCabins_NNW_NNE_NETrashcan` (`jumpstd TrashCanScript`) |
| 7 | 19 | `BGEVENT_READ` | `FastShipCabins_NNW_NNE_NETrashcan` |
| 7 | 31 | `BGEVENT_READ` | `FastShipCabins_NNW_NNE_NETrashcan` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `..._COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 4 | 3 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 2 | `TrainerCooltrainermSean` | `EVENT_FAST_SHIP_PASSENGERS_EASTBOUND` |
| `..._COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 1 | 5 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` | 3 | `TrainerCooltrainerfCarol` | `EVENT_FAST_SHIP_PASSENGERS_EASTBOUND` |
| `..._SUPER_NERD` | `SPRITE_SUPER_NERD` | 1 | 5 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` | 3 | `TrainerPokemaniacEthan` | `EVENT_FAST_SHIP_PASSENGERS_WESTBOUND` |
| `..._POKEFAN_M` | `SPRITE_POKEFAN_M` | 4 | 17 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` | 3 | `TrainerHikerNoland` | `EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP` |
| `..._SAILOR` | `SPRITE_SAILOR` | 4 | 26 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | 0 | `FastShipLazySailorScript` | `EVENT_FAST_SHIP_CABINS_NNW_NNE_NE_SAILOR` |
| `..._GENTLEMAN` | `SPRITE_GENTLEMAN` | 7 | 30 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_TRAINER` | 1 | `TrainerGentlemanEdward` | `EVENT_FAST_SHIP_PASSENGERS_EASTBOUND` |
| `..._PHARMACIST` | `SPRITE_PHARMACIST` | 2 | 30 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` | 4 | `TrainerBurglarCorey` | `EVENT_FAST_SHIP_PASSENGERS_WESTBOUND` |

On the maiden voyage only `EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP` is clear, so
Hiker Noland is the only trainer visible on this map - exactly what the
walkthrough describes.

**Scripts of interest**

- `FastShipLazySailorScript` (sym `5b:4d68`): not a `trainer` object, a scripted
  battle. `playmusic MUSIC_HIKER_ENCOUNTER` -> `SailorStanlySeenText` ->
  `winlosstext SailorStanlyBeatenText, 0` -> `loadtrainer SAILOR, STANLY` ->
  `startbattle` -> `reloadmap` -> `special HealParty` ->
  `setevent EVENT_BEAT_SAILOR_STANLY` -> after-battle text ->
  `setevent EVENT_FAST_SHIP_LAZY_SAILOR` ->
  `setmapscene FAST_SHIP_B1F, SCENE_FASTSHIPB1F_NOOP` (this is what unblocks
  B1F) -> `readvar VAR_FACING`, walk him out, `disappear`.
  Note `special HealParty` fires unconditionally after the fight.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | notes |
|---|---|---|---|---|---|
| `HIKER, NOLAND` | `HIKER` (`$2c`) | 14 | `; HIKER (14) db "NOLAND@", TRAINERTYPE_NORMAL` -> L31 `SANDSLASH`, L33 `GOLEM` | `TrainerHikerNoland` | flag `EVENT_BEAT_HIKER_NOLAND` |
| `SAILOR, STANLY` | `SAILOR` (`$28`) | 9 | `; SAILOR (9) db "STANLY@", TRAINERTYPE_NORMAL` -> L31 `MACHOP`, L33 `MACHOKE`, L26 `PSYDUCK` | `FastShipLazySailorScript` | scripted `loadtrainer`, not an `OBJECTTYPE_TRAINER` |

### MAP_FAST_SHIP_CABINS_SW_SSW_NW

- Script: `maps/FastShipCabins_SW_SSW_NW.asm`
- Blocks: `maps/FastShipCabins_SW_SSW_NW.blk`
- Header: `data/maps/maps.asm:337` -> `map FastShipCabins_SW_SSW_NW, TILESET_LIGHTHOUSE, INDOOR, LANDMARK_FAST_SHIP, MUSIC_SS_AQUA, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:311` `map_const FAST_SHIP_CABINS_SW_SSW_NW, 4, 16` (8 x 32 cells)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 0 | `FAST_SHIP_1F` | 5 |
| 2 | 2 | 19 | `FAST_SHIP_1F` | 6 |
| 3 | 3 | 19 | `FAST_SHIP_1F` | 6 |
| 4 | 2 | 31 | `FAST_SHIP_1F` | 7 |
| 5 | 3 | 31 | `FAST_SHIP_1F` | 7 |

**Coord events** - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 7 | 1 | `BGEVENT_READ` | `FastShipBed` (sym `5b:521b`) |
| 7 | 2 | `BGEVENT_READ` | `FastShipBed` |
| 7 | 7 | `BGEVENT_READ` | `FastShipCabinsNorthwestCabinTrashcan` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `..._FISHER` | `SPRITE_FISHER` | 1 | 15 | `SPRITEMOVEDATA_SPINCOUNTERCLOCKWISE` | `OBJECTTYPE_TRAINER` | 2 | `TrainerFirebreatherLyle` | `EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP` |
| `..._BUG_CATCHER` | `SPRITE_BUG_CATCHER` | 6 | 15 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 2 | `TrainerBugCatcherKen` | `EVENT_FAST_SHIP_PASSENGERS_WESTBOUND` |
| `..._BEAUTY` | `SPRITE_BEAUTY` | 1 | 26 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 3 | `TrainerBeautyCassie` | `EVENT_FAST_SHIP_PASSENGERS_EASTBOUND` |
| `..._ROCKER` | `SPRITE_ROCKER` | 3 | 28 | `SPRITEMOVEDATA_SPINCOUNTERCLOCKWISE` | `OBJECTTYPE_TRAINER` | 2 | `TrainerGuitaristClyde` | `EVENT_FAST_SHIP_PASSENGERS_WESTBOUND` |

**Scripts of interest**

- `FastShipBed` (bg_event at `(7,1)` / `(7,2)`, warp-1 sub-room = your cabin):
  text, `FadeOutToBlack`, `ReloadSpritesNoPalettes`, `special HealParty`,
  `playmusic MUSIC_HEAL`, `pause 60`, `RestartMapMusic`, `FadeInFromBlack`.
  Then a docking check: skip if `EVENT_FAST_SHIP_HAS_ARRIVED`; otherwise
  `checkevent EVENT_FAST_SHIP_FOUND_GIRL` **or**
  `checkevent EVENT_FAST_SHIP_FIRST_TIME` -> `.CanArrive`, which plays
  `SFX_ELEVATOR_END`, prints the arrival text and
  `setevent EVENT_FAST_SHIP_HAS_ARRIVED`.
  **Bot-relevant**: on the maiden voyage, sleeping in the bed does *not* dock the
  ship, because both `EVENT_FAST_SHIP_FOUND_GIRL` and `EVENT_FAST_SHIP_FIRST_TIME`
  are still clear. You must finish the granddaughter errand.

**Trainers**

| const | class | id | party | script label | notes |
|---|---|---|---|---|---|
| `FIREBREATHER, LYLE` | `FIREBREATHER` (`$30`) | 8 | `; FIREBREATHER (8) db "LYLE@", TRAINERTYPE_NORMAL` -> L28 `KOFFING`, L31 `FLAREON`, L28 `KOFFING` | `TrainerFirebreatherLyle` | flag `EVENT_BEAT_FIREBREATHER_LYLE` |

### MAP_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN

- Script: `maps/FastShipCabins_SE_SSE_CaptainsCabin.asm`
- Blocks: `maps/FastShipCabins_SE_SSE_CaptainsCabin.blk`
- Header: `data/maps/maps.asm:338` -> `map FastShipCabins_SE_SSE_CaptainsCabin, TILESET_LIGHTHOUSE, INDOOR, LANDMARK_FAST_SHIP, MUSIC_SS_AQUA, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:312` `map_const FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN, 5, 17` (10 x 34 cells)
- Layout: sub-room 1 `y` 0-11 (Colin + Twins), sub-room 2 `y` 12-23 (grandpa),
  sub-room 3 `y` 24-33 (captain's cabin).

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `FAST_SHIP_1F` | 8 |
| 2 | 3 | 7 | `FAST_SHIP_1F` | 8 |
| 3 | 2 | 19 | `FAST_SHIP_1F` | 9 |
| 4 | 3 | 19 | `FAST_SHIP_1F` | 9 |
| 5 | 2 | 33 | `FAST_SHIP_1F` | 10 |
| 6 | 3 | 33 | `FAST_SHIP_1F` | 10 |

**Coord events** - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 4 | 25 | `BGEVENT_READ` | `FastShipCaptainsCabinTrashcan` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `..._CAPTAIN` | `SPRITE_CAPTAIN` | 3 | 25 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `SSAquaCaptain` | `-1` |
| `..._GENTLEMAN` | `SPRITE_GENTLEMAN` | 2 | 17 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | 0 | `SSAquaGrandpa` (sym `5b:561b`) | `EVENT_FAST_SHIP_CABINS_SE_SSE_GENTLEMAN` |
| `..._TWIN1` | `SPRITE_TWIN` | 3 | 17 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_SCRIPT` | 0 | `SSAquaGranddaughterAfter` | `EVENT_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN_TWIN_1` |
| `..._TWIN2` | `SPRITE_TWIN` | 2 | 25 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_SCRIPT` | 0 | `SSAquaGranddaughterBefore` | `EVENT_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN_TWIN_2` |
| `..._POKEFAN_M1` | `SPRITE_POKEFAN_M` | 5 | 6 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 5 | `TrainerPokefanmColin` | `EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP` |
| `..._TWIN3` | `SPRITE_TWIN` | 2 | 4 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER` | 1 | `TrainerTwinsMegandpeg1` | `EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP` |
| `..._TWIN4` | `SPRITE_TWIN` | 3 | 4 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER` | 1 | `TrainerTwinsMegandpeg2` | `EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP` |
| `..._SUPER_NERD1` | `SPRITE_SUPER_NERD` | 5 | 5 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 5 | `TrainerPsychicRodney` | `EVENT_FAST_SHIP_PASSENGERS_EASTBOUND` |
| `..._POKEFAN_M2` | `SPRITE_POKEFAN_M` | 2 | 3 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER` | 3 | `TrainerPokefanmJeremy` | `EVENT_FAST_SHIP_PASSENGERS_WESTBOUND` |
| `..._POKEFAN_F` | `SPRITE_POKEFAN_F` | 5 | 5 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 1 | `TrainerPokefanfGeorgia` | `EVENT_FAST_SHIP_PASSENGERS_WESTBOUND` |
| `..._SUPER_NERD2` | `SPRITE_SUPER_NERD` | 1 | 15 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_TRAINER` | 2 | `TrainerSupernerdShawn` | `EVENT_FAST_SHIP_PASSENGERS_EASTBOUND` |

**Scripts of interest**

- `SSAquaGrandpa` (talk to `..._GENTLEMAN` at `(2,17)`): 
  `checkevent EVENT_GOT_METAL_COAT_FROM_GRANDPA_ON_SS_AQUA` -> `SSAquaGotMetalCoat`;
  `checkevent EVENT_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN_TWIN_2` (i.e. the
  granddaughter object is *hidden* = already found) -> `SSAquaFoundGranddaughter`;
  otherwise the "I can't find my granddaughter" text plus
  `setmapscene FAST_SHIP_1F, SCENE_FASTSHIP1F_NOOP`.
- `SSAquaGranddaughterBefore` (talk to `..._TWIN2` at `(2,25)` in the captain's
  cabin) - the payoff scene: `FadeOutToBlack`, `disappear` TWIN2, teleport the
  player with `SSAquaCaptainsCabinWarpsToGrandpasCabinMovement`
  (`big_step RIGHT` + six `big_step UP`), `moveobject TWIN1, 3, 19` + `appear`,
  `showemote EMOTE_SHOCK` on the gentleman, dialogue, then
  `setevent EVENT_VERMILION_PORT_SAILOR_AT_GANGWAY`,
  `setmapscene FAST_SHIP_1F, SCENE_FASTSHIP1F_NOOP`,
  `sjump SSAquaMetalCoatAndDocking`.
- `SSAquaMetalCoatAndDocking` (sym `5b:5633`): `verbosegiveitem METAL_COAT`,
  `iffalse .NoRoom`, `setevent EVENT_GOT_METAL_COAT_FROM_GRANDPA_ON_SS_AQUA`,
  then `playsound SFX_ELEVATOR_END`, `pause 30`, arrival text,
  `setevent EVENT_FAST_SHIP_HAS_ARRIVED`, `setevent EVENT_FAST_SHIP_FOUND_GIRL`.
  **This is the docking trigger for the maiden voyage.** A full bag skips the
  item but still docks the ship.

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `METAL_COAT` | finish the granddaughter errand | `SSAquaMetalCoatAndDocking` / `SSAquaFoundGranddaughter` `verbosegiveitem METAL_COAT` | `EVENT_GOT_METAL_COAT_FROM_GRANDPA_ON_SS_AQUA` |

**Trainers**

| const | class | id | party | script label | notes |
|---|---|---|---|---|---|
| `POKEFANM, COLIN` | `POKEFANM` (`$3b`) | 9 | `; POKEFANM (9) db "COLIN@", TRAINERTYPE_ITEM` -> L32 `DELIBIRD` holding `BERRY` | `TrainerPokefanmColin` | `EVENT_BEAT_POKEFANM_COLIN` |
| `TWINS, MEGANDPEG1` | `TWINS` (`$3d`) | 7 | `; TWINS (7) db "MEG & PEG@", TRAINERTYPE_NORMAL` -> L31 `TEDDIURSA`, L31 `PHANPY` | `TrainerTwinsMegandpeg1` | shares flag `EVENT_BEAT_TWINS_MEG_AND_PEG` |
| `TWINS, MEGANDPEG2` | `TWINS` (`$3d`) | 8 | `; TWINS (8)` -> L31 `PHANPY`, L31 `TEDDIURSA` | `TrainerTwinsMegandpeg2` | same flag - beating either removes both |

### MAP_FAST_SHIP_B1F

- Script: `maps/FastShipB1F.asm`
- Blocks: `maps/FastShipB1F.blk`
- Header: `data/maps/maps.asm:339` -> `map FastShipB1F, TILESET_LIGHTHOUSE, INDOOR, LANDMARK_FAST_SHIP, MUSIC_SS_AQUA, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:313` `map_const FAST_SHIP_B1F, 16, 8` (32 x 16 cells)

Scene ids: `SCENE_FASTSHIPB1F_SAILOR_BLOCKS` = 0, `SCENE_FASTSHIPB1F_NOOP` = 1.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 11 | `FAST_SHIP_1F` | 11 |
| 2 | 31 | 13 | `FAST_SHIP_1F` | 12 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_FASTSHIPB1F_SAILOR_BLOCKS` (0) | 30 | 7 | `FastShipB1FSailorBlocksLeft` | if `EVENT_FAST_SHIP_B1F_SAILOR_RIGHT` set -> no-op; else move sailor2 left, `moveobject FASTSHIPB1F_SAILOR1, 30, 6` + `appear`, `disappear` sailor2 |
| `SCENE_FASTSHIPB1F_SAILOR_BLOCKS` (0) | 31 | 7 | `FastShipB1FSailorBlocksRight` | mirror: `moveobject FASTSHIPB1F_SAILOR2, 31, 6` + `appear`, `disappear` sailor1 |

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 27 | 9 | `BGEVENT_READ` | `FastShipB1FTrashcan` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `FASTSHIPB1F_SAILOR1` | `SPRITE_SAILOR` | 30 | 6 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `FastShipB1FSailorScript` | `EVENT_FAST_SHIP_B1F_SAILOR_LEFT` |
| `FASTSHIPB1F_SAILOR2` | `SPRITE_SAILOR` | 31 | 6 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `FastShipB1FSailorScript` | `EVENT_FAST_SHIP_B1F_SAILOR_RIGHT` |
| `FASTSHIPB1F_SAILOR3` | `SPRITE_SAILOR` | 9 | 11 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSailorJeff` | `EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP` |
| `FASTSHIPB1F_LASS` | `SPRITE_LASS` | 6 | 4 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` | 1 | `TrainerPicnickerDebra` | `EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP` |
| `FASTSHIPB1F_SUPER_NERD` | `SPRITE_SUPER_NERD` | 26 | 9 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 1 | `TrainerJugglerFritz` | `EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP` |
| `FASTSHIPB1F_SAILOR4` | `SPRITE_SAILOR` | 17 | 4 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 4 | `TrainerSailorGarrett` | `EVENT_FAST_SHIP_PASSENGERS_EASTBOUND` |
| `FASTSHIPB1F_FISHER` | `SPRITE_FISHER` | 25 | 8 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` | 3 | `TrainerFisherJonah` | `EVENT_FAST_SHIP_PASSENGERS_EASTBOUND` |
| `FASTSHIPB1F_BLACK_BELT` | `SPRITE_BLACK_BELT` | 15 | 11 | `SPRITEMOVEDATA_SPINCLOCKWISE` | `OBJECTTYPE_TRAINER` | 3 | `TrainerBlackbeltWai` | `EVENT_FAST_SHIP_PASSENGERS_EASTBOUND` |
| `FASTSHIPB1F_SAILOR5` | `SPRITE_SAILOR` | 23 | 4 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 4 | `TrainerSailorKenneth` | `EVENT_FAST_SHIP_PASSENGERS_WESTBOUND` |
| `FASTSHIPB1F_TEACHER` | `SPRITE_TEACHER` | 9 | 11 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` | 3 | `TrainerTeacherShirley` | `EVENT_FAST_SHIP_PASSENGERS_WESTBOUND` |
| `FASTSHIPB1F_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 14 | 9 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_TRAINER` | 1 | `TrainerSchoolboyNate` | `EVENT_FAST_SHIP_PASSENGERS_WESTBOUND` |
| `FASTSHIPB1F_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 14 | 11 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 1 | `TrainerSchoolboyRicky` | `EVENT_FAST_SHIP_PASSENGERS_WESTBOUND` |

**Scripts of interest**

- `FastShipB1FSailorScript` (sym `5b:5e37`), shared by both blocking sailors:
  - `checkevent EVENT_FAST_SHIP_FIRST_TIME` / `iftrue .FirstTime` -> on repeat
    trips he just gives directions and does not block the story.
  - `checkevent EVENT_FAST_SHIP_LAZY_SAILOR` / `iftrue .LazySailor` -> thanks you;
    if `EVENT_FAST_SHIP_FOUND_GIRL` is still clear he also prints
    `FastShipB1FOnDutySailorSawLittleGirlText` (the "a little girl went by" hint).
  - `checkevent EVENT_FAST_SHIP_INFORMED_ABOUT_LAZY_SAILOR` / `iftrue
    .AlreadyInformed`.
  - First talk: prints the request, `setevent
    EVENT_FAST_SHIP_INFORMED_ABOUT_LAZY_SAILOR` and
    `clearevent EVENT_FAST_SHIP_CABINS_NNW_NNE_NE_SAILOR` - **this is what spawns
    the lazy sailor** in the NNW/NNE/NE cabins map.
- The physical block is the sailor object standing on `(30,6)` or `(31,6)`; the
  coord events at `(30,7)`/`(31,7)` shuffle whichever sailor is active onto the
  tile you approached. Once `FastShipLazySailorScript` runs
  `setmapscene FAST_SHIP_B1F, SCENE_FASTSHIPB1F_NOOP`, the coord events stop
  firing and only one of the two tiles stays occupied.

**Trainers**

| const | class | id | party | script label | notes |
|---|---|---|---|---|---|
| `SAILOR, JEFF` | `SAILOR` (`$28`) | 6 | `; SAILOR (6) db "JEFF@", TRAINERTYPE_NORMAL` -> L32 `RATICATE`, L32 `RATICATE` | `TrainerSailorJeff` | `EVENT_BEAT_SAILOR_JEFF` |
| `PICNICKER, DEBRA` | `PICNICKER` (`$35`) | 8 | `; PICNICKER (8) db "DEBRA@", TRAINERTYPE_NORMAL` -> L33 `SEAKING` | `TrainerPicnickerDebra` | `EVENT_BEAT_PICNICKER_DEBRA` |
| `JUGGLER, FRITZ` | `JUGGLER` (`$31`) | 2 | `; JUGGLER (2) db "FRITZ@", TRAINERTYPE_NORMAL` -> L29 `MR__MIME`, L29 `MAGMAR`, L29 `MACHOKE` | `TrainerJugglerFritz` | `EVENT_BEAT_JUGGLER_FRITZ` |

Note the party order in the asm is Mr. Mime, **Magmar**, Machoke - the
walkthrough lists Mr. Mime, Machoke, Magmar.

### MAP_VERMILION_PORT

- Script: `maps/VermilionPort.asm`
- Blocks: `maps/VermilionPort.blk`
- Header: `data/maps/maps.asm:334` -> `map VermilionPort, TILESET_PORT, ROUTE, LANDMARK_VERMILION_CITY, MUSIC_VERMILION_CITY, FALSE, PALETTE_AUTO, FISHGROUP_OCEAN`
- Dimensions: `constants/map_constants.asm:308` `map_const VERMILION_PORT, 10, 18` (20 x 36 cells)
- Attributes: `data/maps/attributes.asm:587` `map_attributes VermilionPort, VERMILION_PORT, $0a` - no connections
- Callback: `callback MAPCALLBACK_NEWMAP, VermilionPortFlypointCallback` ->
  `setflag ENGINE_FLYPOINT_VERMILION`

Scene ids: `SCENE_VERMILIONPORT_ASK_ENTER_SHIP` = 0,
`SCENE_VERMILIONPORT_LEAVE_SHIP` = 1.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 5 | `VERMILION_PORT_PASSAGE` | 5 |
| 2 | 7 | 17 | `FAST_SHIP_1F` | 1 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_VERMILIONPORT_ASK_ENTER_SHIP` (0) | 7 | 11 | `VermilionPortWalkUpToShipScript` | boarding prompt on the way back to Johto |

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 16 | 13 | `BGEVENT_ITEM` | `VermilionPortHiddenIron` -> `hiddenitem IRON, EVENT_VERMILION_PORT_HIDDEN_IRON` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VERMILIONPORT_SAILOR1` | `SPRITE_SAILOR` | 7 | 17 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `VermilionPortSailorAtGangwayScript` | `EVENT_VERMILION_PORT_SAILOR_AT_GANGWAY` |
| `VERMILIONPORT_SAILOR2` | `SPRITE_SAILOR` | 6 | 11 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `VermilionPortSailorScript` | `-1` |
| `VERMILIONPORT_SUPER_NERD` | `SPRITE_SUPER_NERD` | 11 | 11 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius 2,0) | `OBJECTTYPE_SCRIPT` | `VermilionPortSuperNerdScript` | `-1` |

**Scripts of interest**

- `VermilionPortLeaveShipScript` (sym `5b:450e`, scene 1, `sdefer`): the arrival
  cutscene. One `step UP`, `appear VERMILIONPORT_SAILOR1`,
  `setscene SCENE_VERMILIONPORT_ASK_ENTER_SHIP`, then the end-of-voyage
  bookkeeping:
  `setevent EVENT_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN_TWIN_1`,
  `setevent EVENT_FAST_SHIP_CABINS_SE_SSE_GENTLEMAN` (grandpa and granddaughter
  vanish from the ship for good),
  `setevent EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP` (the eight maiden-voyage
  trainers never appear again),
  `clearevent EVENT_OLIVINE_PORT_PASSAGE_POKEFAN_M`,
  `setevent EVENT_FAST_SHIP_FIRST_TIME`,
  `setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1`,
  `blackoutmod VERMILION_CITY`.
- `VermilionPortWalkUpToShipScript` / `VermilionPortSailorScript`:
  `readvar VAR_WEEKDAY`; `MONDAY`/`TUESDAY` -> `.NextShipWednesday`,
  `THURSDAY`/`FRIDAY`/`SATURDAY` -> `.NextShipSunday`. So from Vermilion the ship
  sails **Wednesday and Sunday**, matching the walkthrough. There is no
  first-time bypass on this side. Boarding sets
  `EVENT_FAST_SHIP_PASSENGERS_EASTBOUND`, clears `..._WESTBOUND`, clears the ten
  westbound `EVENT_BEAT_*` flags, sets
  `EVENT_FAST_SHIP_DESTINATION_OLIVINE`, `setmapscene FAST_SHIP_1F,
  SCENE_FASTSHIP1F_ENTER_SHIP`, `warp FAST_SHIP_1F, 25, 1`.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `IRON` | hidden, face `(16,13)` | `VermilionPortHiddenIron` | `EVENT_VERMILION_PORT_HIDDEN_IRON` |

**Wild encounters**

`data/wild/kanto_water.asm:166` `def_water_wildmons VERMILION_PORT`, rate
`2 percent`: `35 TENTACOOL / 30 TENTACOOL / 35 TENTACRUEL`. Fishing
`FISHGROUP_OCEAN`.

### MAP_VERMILION_PORT_PASSAGE

- Script: `maps/VermilionPortPassage.asm`
- Blocks: `maps/PortPassage.blk` (shared)
- Header: `data/maps/maps.asm:341` -> `map VermilionPortPassage, TILESET_UNDERGROUND, INDOOR, LANDMARK_VERMILION_CITY, MUSIC_VERMILION_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:315` `map_const VERMILION_PORT_PASSAGE, 10, 9` (20 x 18 cells)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 15 | 0 | `VERMILION_CITY` | 8 |
| 2 | 16 | 0 | `VERMILION_CITY` | 9 |
| 3 | 15 | 4 | `VERMILION_PORT_PASSAGE` | 4 |
| 4 | 3 | 2 | `VERMILION_PORT_PASSAGE` | 3 |
| 5 | 3 | 14 | `VERMILION_PORT` | 1 |

**Coord events** - none. **BG events** - none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VERMILIONPORTPASSAGE_TEACHER` | `SPRITE_TEACHER` | 17 | 1 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `VermilionPortPassageTeacherScript` | `-1` |

### MAP_VERMILION_CITY

- Script: `maps/VermilionCity.asm`
- Blocks: `maps/VermilionCity.blk`
- Header: `data/maps/maps.asm:296` -> `map VermilionCity, TILESET_KANTO, TOWN, LANDMARK_VERMILION_CITY, MUSIC_VERMILION_CITY, FALSE, PALETTE_AUTO, FISHGROUP_OCEAN`
- Dimensions: `constants/map_constants.asm:273` `map_const VERMILION_CITY, 20, 18` (40 x 36 cells)
- Attributes: `data/maps/attributes.asm:342` `map_attributes VermilionCity, VERMILION_CITY, $43`
- Connections: `connection north, Route6, ROUTE_6, 5`; `connection east, Route11, ROUTE_11, 0`
- Callback: `callback MAPCALLBACK_NEWMAP, VermilionCityFlypointCallback` ->
  `setflag ENGINE_FLYPOINT_VERMILION`

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

**Coord events** - none.

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
| `VERMILIONCITY_TEACHER` | `SPRITE_TEACHER` | 18 | 9 | `SPRITEMOVEDATA_WANDER` (radius 1,1) | `OBJECTTYPE_SCRIPT` | `VermilionCityTeacherScript` | `-1` |
| `VERMILIONCITY_GRAMPS` | `SPRITE_GRAMPS` | 23 | 6 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `VermilionMachopOwner` | `-1` |
| `VERMILIONCITY_MACHOP` | `SPRITE_MACHOP` | 26 | 7 | `SPRITEMOVEDATA_POKEMON` | `OBJECTTYPE_SCRIPT` | `VermilionMachop` | `-1` |
| `VERMILIONCITY_SUPER_NERD` | `SPRITE_SUPER_NERD` | 14 | 16 | `SPRITEMOVEDATA_WANDER` (radius 1,1) | `OBJECTTYPE_SCRIPT` | `VermilionCitySuperNerdScript` | `-1` |
| `VERMILIONCITY_BIG_SNORLAX` | `SPRITE_BIG_SNORLAX` | 34 | 8 | `SPRITEMOVEDATA_BIGDOLLSYM` | `OBJECTTYPE_SCRIPT` | `VermilionSnorlax` | `EVENT_VERMILION_CITY_SNORLAX` |
| `VERMILIONCITY_POKEFAN_M` | `SPRITE_POKEFAN_M` | 31 | 12 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `VermilionGymBadgeGuy` | `-1` |

**Scripts of interest**

- `VermilionGymBadgeGuy` at `(31,12)`: `readvar VAR_BADGES`,
  `ifequal NUM_BADGES, .AllBadges` (16 badges -> `verbosegiveitem HP_UP`,
  `EVENT_GOT_HP_UP_FROM_VERMILION_GUY`), `ifgreater 13`, `ifgreater 9` for the
  intermediate lines. Not reachable this section.
- `VermilionSnorlax` at `(34,8)`: `special SnorlaxAwake`; asleep unless the
  Poke Flute radio channel is playing. Awake -> `loadvar VAR_BATTLETYPE,
  BATTLETYPE_FORCEITEM`, `loadwildmon SNORLAX, 50`, `startbattle`,
  `setevent EVENT_FOUGHT_SNORLAX`. Gates warp 10 to `DIGLETTS_CAVE`; out of scope
  here but it is the reason the east side is closed.
- The **cut tree**: `maps/VermilionCity.blk` block index `(6,9)` holds
  `TILESET_KANTO` block `$35`, whose collision quad is
  `tilecoll FLOOR, CUT_TREE, WALL, FLOOR` (`data/tilesets/kanto_collision.asm`
  row `$35`). That puts the cuttable tile at cell **`(13,18)`**, replacement
  block `$4c`, animation `0` (`data/collision/field_move_blocks.asm:31`). It is
  the only cut tree on the map. The hidden Full Heal bg_event at `(12,19)` is the
  `WALL` quadrant of the same block.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `FULL_HEAL` | hidden, face `(12,19)` | `VermilionCityHiddenFullHeal` | `EVENT_VERMILION_CITY_HIDDEN_FULL_HEAL` |
| `HP_UP` | all 16 badges (not this section) | `VermilionGymBadgeGuy` `.AllBadges` | `EVENT_GOT_HP_UP_FROM_VERMILION_GUY` |

**Wild encounters**

`data/wild/kanto_water.asm:138` `def_water_wildmons VERMILION_CITY`, rate
`6 percent`: `35 TENTACOOL / 30 TENTACOOL / 35 TENTACRUEL`. Fishing
`FISHGROUP_OCEAN` (`data/wild/fish.asm` `.Ocean_Old/Good/Super`, lines 42-55).
No entry in `kanto_grass.asm` and no `treemons.asm` row.

### MAP_POKEMON_FAN_CLUB

- Script: `maps/PokemonFanClub.asm`
- Blocks: `maps/PokemonFanClub.blk`
- Header: `data/maps/maps.asm:300` -> `map PokemonFanClub, TILESET_HOUSE, INDOOR, LANDMARK_VERMILION_CITY, MUSIC_VERMILION_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:277` `map_const POKEMON_FAN_CLUB, 5, 4` (10 x 8 cells)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `VERMILION_CITY` | 3 |
| 2 | 3 | 7 | `VERMILION_CITY` | 3 |

**Coord events** - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 7 | 0 | `BGEVENT_READ` | `PokemonFanClubListenSign` |
| 9 | 0 | `BGEVENT_READ` | `PokemonFanClubBraggingSign` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `POKEMONFANCLUB_CHAIRMAN` | `SPRITE_GENTLEMAN` | 3 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `PokemonFanClubChairmanScript` (sym `59:4340`) | `-1` |
| `POKEMONFANCLUB_RECEPTIONIST` | `SPRITE_RECEPTIONIST` | 4 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `PokemonFanClubReceptionistScript` | `-1` |
| `POKEMONFANCLUB_CLEFAIRY_GUY` | `SPRITE_FISHER` | 2 | 3 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `PokemonFanClubClefairyGuyScript` | `-1` |
| `POKEMONFANCLUB_TEACHER` | `SPRITE_TEACHER` | 7 | 2 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `PokemonFanClubTeacherScript` | `-1` |
| `POKEMONFANCLUB_FAIRY` | `SPRITE_FAIRY` | 2 | 4 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `PokemonFanClubClefairyDollScript` | `EVENT_VERMILION_FAN_CLUB_DOLL` |
| `POKEMONFANCLUB_ODDISH` | `SPRITE_ODDISH` | 7 | 3 | `SPRITEMOVEDATA_POKEMON` | `OBJECTTYPE_SCRIPT` | `PokemonFanClubBayleefScript` | `-1` |

**Scripts of interest**

- `PokemonFanClubChairmanScript`: `checkevent
  EVENT_LISTENED_TO_FAN_CLUB_PRESIDENT` -> `.HeardSpeech`;
  `checkevent EVENT_LISTENED_TO_FAN_CLUB_PRESIDENT_BUT_BAG_WAS_FULL` ->
  `.HeardSpeechButBagFull` (skips the speech, retries the gift). Otherwise
  `yesorno` on `...DidYouVisitToHearAboutMyMonText`; **answering No** goes to
  `.NotListening` and gives nothing. Yes -> the Rapidash speech ->
  `verbosegiveitem RARE_CANDY`, `iffalse .BagFull`,
  `setevent EVENT_LISTENED_TO_FAN_CLUB_PRESIDENT`.
  (Nothing in this file ever *sets*
  `EVENT_LISTENED_TO_FAN_CLUB_PRESIDENT_BUT_BAG_WAS_FULL`; it is only read.)
- `PokemonFanClubClefairyGuyScript` handles the `LOST_ITEM` / Copycat doll chain
  (`EVENT_RETURNED_MACHINE_PART`, `EVENT_MET_COPYCAT_FOUND_OUT_ABOUT_LOST_ITEM`,
  `EVENT_GOT_LOST_ITEM_FROM_FAN_CLUB`) - a later section.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `RARE_CANDY` | answer "Yes" and sit through the speech | `PokemonFanClubChairmanScript` `verbosegiveitem RARE_CANDY` | `EVENT_LISTENED_TO_FAN_CLUB_PRESIDENT` |

### MAP_VERMILION_GYM

- Script: `maps/VermilionGym.asm`
- Blocks: `maps/VermilionGym.blk`
- Header: `data/maps/maps.asm:304` -> `map VermilionGym, TILESET_GAME_CORNER, INDOOR, LANDMARK_VERMILION_CITY, MUSIC_GYM, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:281` `map_const VERMILION_GYM, 5, 9` (10 x 18 cells)
- No scene scripts, no callbacks, no coord events.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 17 | `VERMILION_CITY` | 7 |
| 2 | 5 | 17 | `VERMILION_CITY` | 7 |

**Coord events** - none. (The Gen 1 trash-can/switch puzzle is gone - the guide
NPC even lampshades it in `VermilionGymGuideText`.)

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 1 | 7 | `BGEVENT_READ` | `VermilionGymTrashCan` |
| 3 | 7 | `BGEVENT_READ` | `VermilionGymTrashCan` |
| 5 | 7 | `BGEVENT_READ` | `VermilionGymTrashCan` |
| 7 | 7 | `BGEVENT_READ` | `VermilionGymTrashCan` |
| 9 | 7 | `BGEVENT_READ` | `VermilionGymTrashCan` |
| 1 | 9 | `BGEVENT_READ` | `VermilionGymTrashCan` |
| 3 | 9 | `BGEVENT_READ` | `VermilionGymTrashCan` |
| 5 | 9 | `BGEVENT_READ` | `VermilionGymTrashCan` |
| 7 | 9 | `BGEVENT_READ` | `VermilionGymTrashCan` |
| 9 | 9 | `BGEVENT_READ` | `VermilionGymTrashCan` |
| 1 | 11 | `BGEVENT_READ` | `VermilionGymTrashCan` |
| 3 | 11 | `BGEVENT_READ` | `VermilionGymTrashCan` |
| 5 | 11 | `BGEVENT_READ` | `VermilionGymTrashCan` |
| 7 | 11 | `BGEVENT_READ` | `VermilionGymTrashCan` |
| 9 | 11 | `BGEVENT_READ` | `VermilionGymTrashCan` |
| 3 | 15 | `BGEVENT_READ` | `VermilionGymStatue` |
| 6 | 15 | `BGEVENT_READ` | `VermilionGymStatue` |

`VermilionGymStatue`: `checkflag ENGINE_THUNDERBADGE` -> if set,
`gettrainername STRING_BUFFER_4, LT_SURGE, LT_SURGE1` + `jumpstd GymStatue2Script`,
else `jumpstd GymStatue1Script`.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `VERMILIONGYM_SURGE` | `SPRITE_SURGE` | 5 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `VermilionGymSurgeScript` (sym `59:4bfc`) | `-1` |
| `VERMILIONGYM_GENTLEMAN` | `SPRITE_GENTLEMAN` | 8 | 8 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 4 | `TrainerGentlemanGregory` | `-1` |
| `VERMILIONGYM_ROCKER` | `SPRITE_ROCKER` | 4 | 7 | `SPRITEMOVEDATA_STANDING_DOWN` (radius x 3) | `OBJECTTYPE_TRAINER` | 3 | `TrainerGuitaristVincent` | `-1` |
| `VERMILIONGYM_SUPER_NERD` | `SPRITE_SUPER_NERD` | 0 | 10 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 4 | `TrainerJugglerHorton` | `-1` |
| `VERMILIONGYM_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 7 | 15 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 1 | `VermilionGymGuideScript` | `-1` |

**Scripts of interest**

- `VermilionGymSurgeScript`: `checkflag ENGINE_THUNDERBADGE` / `iftrue
  .FightDone`; else `LtSurgeIntroText`, `winlosstext LtSurgeWinLossText, 0`,
  `loadtrainer LT_SURGE, LT_SURGE1`, `startbattle`, `reloadmapafterbattle`,
  then `setevent EVENT_BEAT_LTSURGE` **and**
  `setevent EVENT_BEAT_GENTLEMAN_GREGORY`,
  `setevent EVENT_BEAT_GUITARIST_VINCENT`,
  `setevent EVENT_BEAT_JUGGLER_HORTON` - beating Surge retroactively clears the
  three gym trainers, so a bot may legally skip them. Then
  `ReceivedThunderBadgeText`, `playsound SFX_GET_BADGE`, `waitsfx`,
  `setflag ENGINE_THUNDERBADGE`, `LtSurgeThunderBadgeText`.
  There is no TM award in this gym script.
- `VermilionGymGuideScript` branches on `EVENT_BEAT_LTSURGE`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_THUNDERBADGE` | `constants/engine_flags.asm:49` | set by `VermilionGymSurgeScript`; read there and by `VermilionGymStatue` | the section's terminal milestone |
| `EVENT_BEAT_LTSURGE` | `constants/event_flags.asm:717` | set by `VermilionGymSurgeScript`; read by `VermilionGymGuideScript` | post-win dialogue switch |
| `EVENT_BEAT_GUITARIST_VINCENT` / `EVENT_BEAT_JUGGLER_HORTON` / `EVENT_BEAT_GENTLEMAN_GREGORY` | `constants/event_flags.asm` | set by each `trainer` macro and also by Surge's script | trainer already-beaten guards |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `GUITARIST, VINCENT` | `GUITARIST` (`$2b`) | 2 | `; GUITARIST (2) db "VINCENT@", TRAINERTYPE_NORMAL` -> L27 `MAGNEMITE`, L33 `VOLTORB`, L32 `MAGNEMITE`, L32 `MAGNEMITE` | `TrainerGuitaristVincent` | none |
| `JUGGLER, HORTON` | `JUGGLER` (`$31`) | 3 | `; JUGGLER (3) db "HORTON@", TRAINERTYPE_NORMAL` -> 4x L33 `ELECTRODE` | `TrainerJugglerHorton` | none |
| `GENTLEMAN, GREGORY` | `GENTLEMAN` (`$20`) | 3 | `; GENTLEMAN (3) db "GREGORY@", TRAINERTYPE_NORMAL` -> L37 `PIKACHU`, L33 `FLAAFFY` | `TrainerGentlemanGregory` | none |
| `LT_SURGE, LT_SURGE1` | `LT_SURGE` (`$13`) | 1 | `data/trainers/parties.asm:289-296`, `TRAINERTYPE_MOVES`: L44 `RAICHU` (Thunder Wave / Quick Attack / Thunderbolt / Thunder); L40 `ELECTRODE` (Screech / Double Team / Swift / Explosion); L40 `MAGNETON` (Lock-On / Double Team / Swift / Zap Cannon); L40 `ELECTRODE` (same set); L46 `ELECTABUZZ` (Quick Attack / ThunderPunch / Light Screen / Thunder) | `VermilionGymSurgeScript` | none |

Party **order** is Raichu, Electrode, Magneton, Electrode, Electabuzz - the
walkthrough lists Raichu, Magneton, Electabuzz, Electrode, Electrode.

**Wild encounters** - none (indoor).

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Elm will not hand over the ticket | `maps/ElmsLab.asm` `ProfElmScript` `checkevent EVENT_BEAT_ELITE_FOUR` | Hall of Fame done | `maps/HallOfFame.asm:33` `setevent EVENT_BEAT_ELITE_FOUR` |
| Cannot board the Fast Ship | `maps/OlivinePort.asm` `OlivinePortWalkUpToShipScript` / `OlivinePortSailorAfterHOFScript` `checkitem S_S_TICKET`, `iffalse .NoTicket` | `S_S_TICKET` in the bag | `ElmGiveTicketScript` |
| Boarding sailor absent before HOF | `maps/OlivinePort.asm` object rows with `EVENT_OLIVINE_PORT_SPRITES_AFTER_HALL_OF_FAME`; the pre-HOF sailor's `OlivinePortSailorBeforeHOFScript` says "you're not allowed in" | Hall of Fame done | `HallOfFame.asm:38` `clearevent EVENT_OLIVINE_PORT_SPRITES_AFTER_HALL_OF_FAME` |
| Ship only sails on certain days (repeat trips) | `OlivinePortWalkUpToShipScript` `readvar VAR_WEEKDAY` (Mon/Fri from Olivine); `VermilionPortWalkUpToShipScript` (Wed/Sun from Vermilion) | correct weekday | maiden voyage bypasses via `checkevent EVENT_FAST_SHIP_FIRST_TIME` / `iffalse .FirstTime` |
| Sailor blocks the B1F corridor | `maps/FastShipB1F.asm` coord events `(30,7)`/`(31,7)` -> `FastShipB1FSailorBlocksLeft/Right` plus the physical object at `(30,6)`/`(31,6)`; `FastShipB1FSailorScript` | find and beat the lazy sailor | `FastShipLazySailorScript` -> `setevent EVENT_FAST_SHIP_LAZY_SAILOR` + `setmapscene FAST_SHIP_B1F, SCENE_FASTSHIPB1F_NOOP` |
| Lazy sailor does not exist yet | object flag `EVENT_FAST_SHIP_CABINS_NNW_NNE_NE_SAILOR`, set at new game (`engine/events/std_scripts.asm:499`) | talk to the on-duty sailor first | `FastShipB1FSailorScript` `clearevent EVENT_FAST_SHIP_CABINS_NNW_NNE_NE_SAILOR` |
| Ship will not dock (maiden voyage) | `maps/FastShip1F.asm` `FastShip1FSailor1Script` `checkevent EVENT_FAST_SHIP_HAS_ARRIVED`; `FastShipBed` `.CanArrive` needs `EVENT_FAST_SHIP_FOUND_GIRL` or `EVENT_FAST_SHIP_FIRST_TIME` | finish the granddaughter errand | `SSAquaMetalCoatAndDocking` `setevent EVENT_FAST_SHIP_HAS_ARRIVED` / `EVENT_FAST_SHIP_FOUND_GIRL` |
| Chairman's Rare Candy | `maps/PokemonFanClub.asm` `PokemonFanClubChairmanScript` `yesorno` -> `.NotListening` | answer **Yes** | `setevent EVENT_LISTENED_TO_FAN_CLUB_PRESIDENT` |
| Cut tree in Vermilion City | tile collision `CUT_TREE` at cell `(13,18)` + `data/collision/field_move_blocks.asm:31` `db $35, $4c, 0`; `engine/events/overworld.asm:133` `CheckAble` requires `ENGINE_HIVEBADGE`, `:169` `CheckMapForSomethingToCut` | HM01 CUT + HIVEBADGE | already held long before Kanto. **Does not gate the gym** - see section 6 |
| Snorlax blocks `DIGLETTS_CAVE` (warp 10, `(34,7)`) | `maps/VermilionCity.asm` `VermilionSnorlax` `special SnorlaxAwake` | Poke Flute radio channel | out of scope for this section |
| Lt. Surge re-battle refused | `VermilionGymSurgeScript` `checkflag ENGINE_THUNDERBADGE` -> `.FightDone` | - | one-shot badge |

---

## 4. Bot checklist

1. `NEW_BARK_TOWN` -> walk to `(6,3)`, warp 1, enter `ELMS_LAB`.
   Pre: `EVENT_BEAT_ELITE_FOUR` set. (An `SPECIALCALL_SSTICKET` phone call may
   fire on the way; answering it is optional.)
2. `ELMS_LAB` -> walk to `(5,3)` and face up to talk to `ELMSLAB_ELM` at `(5,2)`.
   Intent: talk. Pre: `EVENT_BEAT_ELITE_FOUR`, `!EVENT_GOT_SS_TICKET_FROM_ELM`.
   Post: `EVENT_GOT_SS_TICKET_FROM_ELM`, bag holds `S_S_TICKET`.
3. Fly to `OLIVINE_CITY`; walk to warp 10 `(19,27)` -> `OLIVINE_PORT_PASSAGE`.
4. `OLIVINE_PORT_PASSAGE`: warp 3 `(15,4)` -> lands at warp 4 `(3,2)`; then walk
   to warp 5 `(3,14)` -> `OLIVINE_PORT` warp 1 at `(11,7)`.
5. `OLIVINE_PORT`: walk onto `(7,15)`. Intent: walk (coord event).
   Post: yes/no prompt -> answer **Yes**; `checkitem S_S_TICKET` passes; the
   script auto-walks you 7 south and warps you to `FAST_SHIP_1F (25,1)`.
   Post-flags: `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_2`,
   `!EVENT_FAST_SHIP_DESTINATION_OLIVINE`, scene `FAST_SHIP_1F` = 1.
   (Alternative: talk to `OLIVINEPORT_SAILOR3` at `(6,15)` for the same flow.)
6. `FAST_SHIP_1F`: the boarding cutscene runs on entry (scene 1). Then walk south
   to `(24,6)` or `(25,6)`. Intent: walk (coord event `WorriedGrandpaSceneLeft`).
   Post: scene -> `SCENE_FASTSHIP1F_NOOP`; nothing else changes.
7. `FAST_SHIP_1F` warp 3 at `(23,8)` -> `FAST_SHIP_CABINS_NNW_NNE_NE (2,12)`.
   Battle `TrainerHikerNoland` at `(4,17)` (sight 3, faces up).
   Post: `EVENT_BEAT_HIKER_NOLAND`.
8. Back to 1F; warp 5 at `(15,8)` -> `FAST_SHIP_CABINS_SW_SSW_NW (2,0)`; face the
   bed bg_event at `(7,1)`/`(7,2)` to heal (`FastShipBed` -> `special HealParty`).
   Do **not** expect the ship to dock yet.
9. 1F warp 6 at `(15,15)` -> `..._SW_SSW_NW (2,19)`. Battle
   `TrainerFirebreatherLyle` at `(1,15)`. Post: `EVENT_BEAT_FIREBREATHER_LYLE`.
10. 1F warp 8 at `(23,15)` -> `..._SE_SSE (2,7)`. Battle `TrainerPokefanmColin`
    at `(5,6)` and the twins at `(2,4)`/`(3,4)`.
    Post: `EVENT_BEAT_POKEFANM_COLIN`, `EVENT_BEAT_TWINS_MEG_AND_PEG`.
11. 1F warp 9 at `(27,15)` -> `..._SE_SSE (2,19)`. Talk to `SSAquaGrandpa` at
    `(2,17)`. Post: `setmapscene FAST_SHIP_1F, SCENE_FASTSHIP1F_NOOP` (flavour
    only; the errand is not flagged here).
12. 1F warp 12 at `(30,14)` -> `FAST_SHIP_B1F (31,13)`. Walk north onto `(31,7)`
    (or `(30,7)`). Intent: walk (coord event) -> a sailor moves in front of you.
    Talk to him. Post: `EVENT_FAST_SHIP_INFORMED_ABOUT_LAZY_SAILOR` set,
    `EVENT_FAST_SHIP_CABINS_NNW_NNE_NE_SAILOR` cleared.
13. Back to 1F; warp 4 at `(19,8)` -> `..._NNW_NNE_NE (2,24)`. Talk to the sailor
    at `(4,26)`. Intent: talk -> forced battle `SAILOR STANLY`.
    Post: `EVENT_BEAT_SAILOR_STANLY`, `EVENT_FAST_SHIP_LAZY_SAILOR`,
    `FAST_SHIP_B1F` scene -> `SCENE_FASTSHIPB1F_NOOP`, party healed.
14. `FAST_SHIP_B1F` again (1F warp 12 -> `(31,13)`): the corridor is now passable.
    Battle `TrainerJugglerFritz` at `(26,9)`, `TrainerSailorJeff` at `(9,11)`,
    `TrainerPicnickerDebra` at `(6,4)`.
15. `FAST_SHIP_B1F` warp 1 at `(5,11)` -> `FAST_SHIP_1F (6,12)`; then 1F warp 10
    at `(3,13)` -> `..._SE_SSE (2,33)`, the captain's cabin.
16. Talk to the granddaughter (`..._TWIN2`) at `(2,25)`. Intent: talk.
    Pre: `!EVENT_FAST_SHIP_CABINS_SE_SSE_CAPTAINS_CABIN_TWIN_2`.
    Post: teleport cutscene, `verbosegiveitem METAL_COAT`,
    `EVENT_GOT_METAL_COAT_FROM_GRANDPA_ON_SS_AQUA`,
    `EVENT_FAST_SHIP_HAS_ARRIVED`, `EVENT_FAST_SHIP_FOUND_GIRL`,
    `EVENT_VERMILION_PORT_SAILOR_AT_GANGWAY`, 1F scene -> NOOP.
    You end up standing in the grandpa's sub-room; leave via warp 3/4 `(2,19)`/`(3,19)`.
17. `FAST_SHIP_1F`: walk to `(25,3)` and talk to `FASTSHIP1F_SAILOR1` at `(25,2)`.
    Pre: `EVENT_FAST_SHIP_HAS_ARRIVED`.
    Post: `warp VERMILION_PORT, 7, 17`, `VERMILION_PORT` scene ->
    `SCENE_VERMILIONPORT_LEAVE_SHIP`.
18. `VERMILION_PORT`: the arrival scene runs (one step up). Post-flags include
    `EVENT_FAST_SHIP_FIRST_TIME`, `EVENT_FAST_SHIP_PASSENGERS_FIRST_TRIP`,
    `blackoutmod VERMILION_CITY`, `ENGINE_FLYPOINT_VERMILION` (map callback).
    Optional: face `(16,13)` for the hidden `IRON`.
19. Walk to warp 1 `(9,5)` -> `VERMILION_PORT_PASSAGE (3,14)`; warp 4 `(3,2)` ->
    warp 3 `(15,4)`; walk to warps 1/2 `(15,0)`/`(16,0)` -> `VERMILION_CITY`
    `(19,31)`/`(20,31)`.
20. `VERMILION_CITY` -> warp 3 at `(7,13)` -> `POKEMON_FAN_CLUB (2,7)`. Talk to
    the chairman at `(3,1)`; answer **Yes**.
    Post: `EVENT_LISTENED_TO_FAN_CLUB_PRESIDENT`, bag holds `RARE_CANDY`.
21. Optional: `VERMILION_POKECENTER_1F` via warp 2 `(9,5)` to heal.
22. Optional: face cell `(13,18)` and use CUT (needs `ENGINE_HIVEBADGE`), then
    face `(12,19)` for the hidden `FULL_HEAL`.
23. `VERMILION_CITY` warp 7 at `(10,19)` -> `VERMILION_GYM (4,17)`.
24. Gym: `TrainerGuitaristVincent` at `(4,7)` (sight 3, faces down),
    `TrainerJugglerHorton` at `(0,10)` (sight 4, faces right),
    `TrainerGentlemanGregory` at `(8,8)` (sight 4, faces left).
    All three are optional - Surge's win script sets their flags.
25. Walk to `(5,3)` and talk to `VERMILIONGYM_SURGE` at `(5,2)`.
    Pre: `!ENGINE_THUNDERBADGE`. Intent: talk -> battle `LT_SURGE, LT_SURGE1`.
    Post: `EVENT_BEAT_LTSURGE`, `EVENT_BEAT_GENTLEMAN_GREGORY`,
    `EVENT_BEAT_GUITARIST_VINCENT`, `EVENT_BEAT_JUGGLER_HORTON`,
    `ENGINE_THUNDERBADGE`. **Section complete.**

---

## 5. Port coverage

Everything in this section is data-driven: the Gen 2 side of this repo extracts
map headers, blocks, warps, coord/bg/object events and scene scripts generically
(`src/import/RomExtractorGen2.lua:804-977`) and runs the scripts through
`src/script/gen2/Vm.lua`. There is no per-map hand-port for any of these maps, so
"implemented" below means the generic mechanism exists and the ROM data drives
it, not that the beat has been played through.

| Beat | Port file | Status |
|---|---|---|
| Map load: blocks, collision quads, warps by cell | `src/world/gen2/Map.lua` | implemented (generic) |
| Warp / coord / bg event dispatch | `src/world/gen2/World.lua:5013` (coord), `:5148` (bg), `:1183` + `:5026` (scene scripts) | implemented (generic) |
| `verbosegiveitem` (S.S. TICKET, METAL COAT, RARE CANDY) | `src/script/gen2/Vm.lua:490-522` | implemented |
| `checkitem S_S_TICKET` boarding gate | `src/script/gen2/Vm.lua:523` | implemented |
| `loadtrainer` / `startbattle` (Stanly, Lt. Surge) | `src/script/gen2/Vm.lua:806`, `:918` (`winlosstext`) | implemented |
| `OBJECTTYPE_TRAINER` sight lines (ship + gym trainers) | `src/world/gen2/Trainers.lua:98` `Trainers.sees` | implemented |
| `TRAINERTYPE_MOVES` parties (Lt. Surge) and `TRAINERTYPE_ITEM` (Colin) | `src/import/RomExtractorGen2.lua:3900-3968` | implemented |
| `setmapscene` / `sdefer` scene plumbing (ports, ship, B1F) | `src/script/gen2/Vm.lua:92`, `:279` | implemented |
| `moveobject` + `appear` sailor-shuffle on B1F | `src/script/gen2/Vm.lua:337-350` (the comment calls out exactly this pattern) | implemented |
| `showemote` (grandpa's `!`) and `earthquake` (boarding) | `src/script/gen2/Vm.lua:961`, `:1799` | implemented |
| `blackoutmod` (cabin / Vermilion respawn) | `src/script/gen2/Vm.lua:1136` | implemented |
| `special HealParty` (bed, post-Stanly), `FadeOutToWhite/Black`, `ReloadSpritesNoPalettes`, `RestartMapMusic` | `src/script/gen2/Specials.lua:450`, `:998`, `:1025`, `:1059` | implemented |
| `specialphonecall SPECIALCALL_SSTICKET` | `src/script/gen2/Vm.lua:1364`; roster entry `src/core/gen2/Phone.lua:395` (`[5] = SPECIALCALL_SSTICKET`, condition `anywhere`) | implemented |
| CUT on the Vermilion tree (`TILESET_KANTO` `$35` -> `$4c`, anim 0) | `src/world/gen2/FieldMoves.lua:191-208`, `:242` | implemented |
| Hidden items (`PROTEIN`, `IRON`, `FULL_HEAL`) | `src/world/gen2/HiddenItems.lua:64`, `:112` | implemented |
| `ENGINE_FLYPOINT_VERMILION` from the map callback | `src/world/gen2/FieldMoves.lua:361` (`LANDMARK_VERMILION_CITY` -> `SPAWN_VERMILION`, flag 57) | implemented |
| `readvar VAR_BADGES` (Vermilion badge guy) | `src/world/gen2/World.lua:117`, `:1240` | implemented |
| `special SnorlaxAwake` | `src/script/gen2/Specials.lua:1562` | implemented |
| Water encounters / `FISHGROUP_OCEAN` at the ports | `src/battle/gen2/Encounter.lua` | not verified in this pass - no port-specific check was run |
| A driver that exercises the crossing end to end | `tests/drivers/gold_*.lua` | **missing** - no `gold_fastship_*`, `gold_vermilion_*` or `gold_surge_*` driver exists |
| Any hand-ported script for these 14 maps | - | **missing by design**; all behaviour comes from the extracted ROM script bytes |

Note: the many `Vermilion*` hits under `src/world/OverworldController.lua` and
`src/world/FieldDefaults.lua` are the **Gen 1** (pokered) Vermilion Gym trash-can
puzzle. That puzzle does not exist in Gold, and none of that code is on the Gen 2
path.

---

## 6. Unresolved / verify by hand

- **"cut down the tree blocking the gym" is wrong.** `maps/VermilionCity.blk` has
  exactly one cuttable block, `$35` at block `(6,9)`, whose `CUT_TREE` quadrant is
  cell `(13,18)`. The gym door is the `DOOR` quadrant of block `$12` at
  `(5,9)` = cell `(10,19)`, and the tiles south of it (`(10,20)`, `(11,20)`,
  `(12,20)`) are all `FLOOR`. Walking a straight path from the port entrance to
  the gym door never touches the tree. Cutting it only opens cell `(13,18)`, which
  is beside the hidden `FULL_HEAL` at `(12,19)`. Verified against
  `data/tilesets/kanto_collision.asm` rows `$12`, `$35`, `$4c`, `$31`.
- **"Meal Coat"** in the walkthrough's item list is a typo for `METAL_COAT`
  (`SSAquaMetalCoatAndDocking`). No `MEAL_*` item exists.
- **Lt. Surge's party order** in the walkthrough (Raichu, Magneton, Electabuzz,
  Electrode, Electrode) does not match `data/trainers/parties.asm:289-296`
  (Raichu, Electrode, Magneton, Electrode, Electabuzz).
- **Juggler Fritz's party order**: asm is Mr. Mime / Magmar / Machoke; the
  walkthrough says Mr. Mime / Machoke / Magmar.
- **"Lt. Surge has a Full Restore"** - the party entry is `TRAINERTYPE_MOVES`,
  which carries **no** held item. Gym-leader item use is AI behaviour
  (`data/trainers/attributes.asm` / the trainer-class AI item list), which was not
  opened in this pass. Verify before relying on it.
- **Prize money figures** ("You get: 1056G", "4600G", "???G" for Colin) are not
  stored anywhere in the asm as literals - Gen 2 computes them from base money x
  level. Not reproduced here.
- **EXP values** quoted per Pokemon are party- and level-dependent runtime
  calculations, not table data. Not reproduced here.
- **`EVENT_LISTENED_TO_FAN_CLUB_PRESIDENT_BUT_BAG_WAS_FULL`** is read by
  `PokemonFanClubChairmanScript` but is never `setevent`'d anywhere in
  `maps/PokemonFanClub.asm`. Either it is set elsewhere (nothing found by grep) or
  it is dead in this revision; a full-bag player appears to have to sit through
  the Rapidash speech again.
- **"Note the new Pokemon music for Kanto"**: the Vermilion maps use
  `MUSIC_VERMILION_CITY` (`data/maps/maps.asm:296`). Whether that is the "Kanto
  remix" the walkthrough means was not checked against the audio engine.
- The walkthrough's cabin-by-cabin narration ("two cabins to the right", "the
  cabin next to yours") was reconciled against the 1F warp `x` positions
  (north row `x` = 27/23/19/15, south row `x` = 15/19/23/27) and is consistent,
  but the prose ordering of trainers within `FAST_SHIP_B1F` ("head left, then
  down") was not re-walked tile by tile.

# Section 09 - Olivine City Gym

Source: `../section-09-olivine-city-gym.txt`
Maps covered: `MAP_GOLDENROD_CITY` (fly stop, optional), `MAP_GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` (transit), `MAP_GOLDENROD_UNDERGROUND`, `MAP_OLIVINE_CITY`, `MAP_OLIVINE_LIGHTHOUSE_1F` .. `MAP_OLIVINE_LIGHTHOUSE_6F`, `MAP_OLIVINE_GYM`
Badges / key milestones in this section: **MINERALBADGE** (`ENGINE_MINERALBADGE`), `EVENT_BEAT_JASMINE`, `TM_IRON_TAIL` (TM23), `EVENT_JASMINE_RETURNED_TO_GYM` (set on Lighthouse 6F, the gate for the gym even existing), the 6th-badge Rocket trigger (`GoldenrodRocketsScript`).

This section assumes the player already has the SECRETPOTION from Cianwood (section 8) and
`ENGINE_STORMBADGE` (Chuck), which is what makes `FLY` usable at all.

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `GOLDENROD_CITY` (optional) | `maps/GoldenrodCity.asm` | Fly (`SPAWN_GOLDENROD`, `ENGINE_FLYPOINT_GOLDENROD`) | warp 15 at (11, 29) -> `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` warp 5 | Only if raising an Eevee: buy the 500 haircut for happiness |
| 2 | `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` | `maps/GoldenrodUndergroundSwitchRoomEntrances.asm` | warp 5 at (4, 29) / warp 6 at (5, 29) | warp 4 at (5, 25) -> `GOLDENROD_UNDERGROUND` warp 2 | Pure transit corridor to the salon |
| 3 | `GOLDENROD_UNDERGROUND` | `maps/GoldenrodUnderground.asm` | warp 2 at (3, 34) | back out the way in, then Fly | Talk to the *older* Haircut Brother at (7, 14), pay 500, happiness bump |
| 4 | `OLIVINE_CITY` | `maps/OlivineCity.asm` | Fly (`SPAWN_OLIVINE`, `ENGINE_FLYPOINT_OLIVINE`) | warp 9 at (29, 27) -> `OLIVINE_LIGHTHOUSE_1F` warp 1 | Head for the lighthouse |
| 5 | `OLIVINE_LIGHTHOUSE_1F` -> `2F` -> `3F` -> `4F` -> `3F` -> `4F` -> `5F` -> `6F` | `maps/OlivineLighthouse[1-6]F.asm` | ladders + one floor pit ("fall to the left of that one lass") | same ladders/pits back down | Hand Jasmine the SECRETPOTION |
| 6 | `OLIVINE_LIGHTHOUSE_6F` | `maps/OlivineLighthouse6F.asm` | warp 1 at (9, 15) from 5F warp 1 | warp 1 at (9, 15) back to 5F | `OlivineLighthouseJasmine` -> `EVENT_JASMINE_RETURNED_TO_GYM`, `clearevent EVENT_OLIVINE_GYM_JASMINE` |
| 7 | `OLIVINE_CITY` | `maps/OlivineCity.asm` | `OLIVINE_LIGHTHOUSE_1F` warps 1/2 at (10, 17)/(11, 17) | warp 2 at (10, 11) -> `OLIVINE_GYM` warp 1 | Walk to the gym door |
| 8 | `OLIVINE_GYM` | `maps/OlivineGym.asm` | warps 1/2 at (4, 15)/(5, 15) | same warps back to `OLIVINE_CITY` warp 2 | Beat Jasmine, take MINERALBADGE + TM23 |

Spill into the next section: the walkthrough offers "fly to Ecruteak and go through the Lake of
Rage" as an alternative to fighting Jasmine now. `MAP_LAKE_OF_RAGE` and the Route 42/43 chain
belong to the next section; nothing in this section's asm depends on them.

---

## 2. Maps

### MAP_GOLDENROD_UNDERGROUND

- Script: `maps/GoldenrodUnderground.asm` (`46:4900 GoldenrodUnderground_MapEvents`, `46:4129 OlderHaircutBrotherScript`)
- Blocks: `maps/GoldenrodUnderground.blk`
- Header: `data/maps/maps.asm:123` -> `map GoldenrodUnderground, TILESET_GATE, DUNGEON, LANDMARK_GOLDENROD_CITY, MUSIC_UNION_CAVE, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:110` -> `map_const GOLDENROD_UNDERGROUND, 15, 18` (map group 1, the `newgroup OLIVINE` group, map id 45 - it is *not* in the Goldenrod group)
- Attributes: `data/maps/attributes.asm:442` -> `map_attributes GoldenrodUnderground, GOLDENROD_UNDERGROUND, $00` (no connections)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 2 | `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` | 7 |
| 2 | 3 | 34 | `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` | 4 |
| 3 | 18 | 6 | `GOLDENROD_UNDERGROUND` | 4 |
| 4 | 21 | 31 | `GOLDENROD_UNDERGROUND` | 3 |
| 5 | 22 | 31 | `GOLDENROD_UNDERGROUND` | 3 |
| 6 | 22 | 27 | `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` | 1 |

**Coord events** (`def_coord_events`) - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 18 | 6 | `BGEVENT_READ` | `BasementDoorScript` |
| 19 | 6 | `BGEVENT_READ` | `GoldenrodUndergroundNoEntrySign` |
| 6 | 13 | `BGEVENT_ITEM` | `GoldenrodUndergroundHiddenParlyzHeal` (`hiddenitem PARLYZ_HEAL, EVENT_GOLDENROD_UNDERGROUND_HIDDEN_PARLYZ_HEAL`) |
| 4 | 18 | `BGEVENT_ITEM` | `GoldenrodUndergroundHiddenSuperPotion` (`hiddenitem SUPER_POTION, EVENT_GOLDENROD_UNDERGROUND_HIDDEN_SUPER_POTION`) |
| 17 | 8 | `BGEVENT_ITEM` | `GoldenrodUndergroundHiddenAntidote` (`hiddenitem ANTIDOTE, EVENT_GOLDENROD_UNDERGROUND_HIDDEN_ANTIDOTE`) |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `GOLDENRODUNDERGROUND_SUPER_NERD1` | `SPRITE_SUPER_NERD` | 5 | 31 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerSupernerdEric` | -1 |
| `GOLDENRODUNDERGROUND_SUPER_NERD2` | `SPRITE_SUPER_NERD` | 6 | 9 | `STANDING_UP` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerSupernerdTeru` | -1 |
| `GOLDENRODUNDERGROUND_SUPER_NERD3` | `SPRITE_SUPER_NERD` | 3 | 27 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerPokemaniacIssac` | -1 |
| `GOLDENRODUNDERGROUND_SUPER_NERD4` | `SPRITE_SUPER_NERD` | 2 | 6 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerPokemaniacDonald` | -1 |
| `GOLDENRODUNDERGROUND_POKE_BALL` | `SPRITE_POKE_BALL` | 7 | 25 | `STILL` | `OBJECTTYPE_ITEMBALL` | `GoldenrodUndergroundCoinCase` (`itemball COIN_CASE`) | `EVENT_GOLDENROD_UNDERGROUND_COIN_CASE` |
| `GOLDENRODUNDERGROUND_GRAMPS` | `SPRITE_GRAMPS` | 7 | 11 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `BargainMerchantScript` | `EVENT_GOLDENROD_UNDERGROUND_GRAMPS` |
| `GOLDENRODUNDERGROUND_OLDER_HAIRCUT_BROTHER` | `SPRITE_SUPER_NERD` | 7 | 14 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `OlderHaircutBrotherScript` | `EVENT_GOLDENROD_UNDERGROUND_OLDER_HAIRCUT_BROTHER` |
| `GOLDENRODUNDERGROUND_YOUNGER_HAIRCUT_BROTHER` | `SPRITE_SUPER_NERD` | 7 | 15 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `YoungerHaircutBrotherScript` | `EVENT_GOLDENROD_UNDERGROUND_YOUNGER_HAIRCUT_BROTHER` |
| `GOLDENRODUNDERGROUND_GRANNY` | `SPRITE_GRANNY` | 7 | 21 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `BitterMerchantScript` | `EVENT_GOLDENROD_UNDERGROUND_GRANNY` |

Object-event visibility convention (verified in `engine/overworld/scripting.asm:879-898`): `appear`
*clears* the flag and `disappear` *sets* it, so **an object is on the map only while its event flag
is clear.**

**Scripts of interest**

- `GoldenrodUndergroundCheckDayOfWeekCallback` (`callback MAPCALLBACK_OBJECTS`): `readvar VAR_WEEKDAY`
  and appear/disappear the four merchants. Who is standing there:
  - Sunday: younger brother + granny
  - Monday: gramps only, and only during `MORN` (`checktime MORN`)
  - Tuesday / Thursday: **older brother**
  - Wednesday / Friday: younger brother
  - Saturday: older brother + granny

  The walkthrough's "500 haircut" therefore only exists on **Tuesday, Thursday or Saturday**.
- `OlderHaircutBrotherScript` (`46:4129`): `readvar VAR_WEEKDAY`, bails to
  `GoldenrodUndergroundScript_ShopClosed` unless TUE/THU/SAT. Then
  `checkflag ENGINE_GOLDENROD_UNDERGROUND_GOT_HAIRCUT` (one cut per day, cleared by the daily
  reset), `yesorno`, `checkmoney YOUR_MONEY, 500`, `special OlderHaircutBrother`, then
  `takemoney YOUR_MONEY, 500`. `DEF GOLDENRODUNDERGROUND_OLDER_HAIRCUT_PRICE EQU 500` is at the top
  of the file. The special returns 0/1 (cancel or Egg) or 2/3/4, which the script mirrors into
  `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1/2/3` just to pick which of three "looks happier" lines to
  print.
- `special OlderHaircutBrother` -> `engine/events/haircut.asm:15` -> `HaircutOrGrooming`, weighted
  roll over `HappinessData_OlderHaircutBrother` (`data/events/happiness_probabilities.asm:1`):
  30% -> `HAPPINESS_OLDERCUT1`, 50%+1 -> `HAPPINESS_OLDERCUT2`, remainder -> `HAPPINESS_OLDERCUT3`.
  The actual deltas are `data/events/happiness_changes.asm:13-15`:
  `+1/+1/+1`, `+3/+3/+1`, `+5/+5/+2` (columns are happiness <100 / <200 / otherwise).
  The younger brother (300, SUN/WED/FRI) rolls 60%+1 / 30% / rest for `+1/+1/+1`, `+3/+3/+1`,
  `+10/+10/+4` - **its jackpot row is strictly better than the older brother's**, which the
  walkthrough does not mention.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_GOLDENROD_UNDERGROUND_GOT_HAIRCUT` (id 89) | `constants/engine_flags.asm` | checked+set by both `*HaircutBrotherScript` | one haircut per day, either brother |
| `EVENT_GOLDENROD_UNDERGROUND_OLDER_HAIRCUT_BROTHER` (0x754) | `constants/event_flags.asm:1270` | day-of-week callback | clear = older brother is standing at (7, 14) |
| `EVENT_GOLDENROD_UNDERGROUND_YOUNGER_HAIRCUT_BROTHER` (0x755) | `constants/event_flags.asm` | day-of-week callback | clear = younger brother at (7, 15) |
| `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1/2/3` (0x000-0x002) | `constants/event_flags.asm:5-7` | haircut scripts | scratch, do not persist |

**Items** - nothing the walkthrough takes here; the Coin Case itemball and the three hidden items
belong to earlier sections.

**Trainers** - the four in the table above are optional and already beaten by this point in a
linear run.

**Wild encounters** - none (indoor `DUNGEON`, no entry in `data/wild/johto_grass.asm`).

---

### MAP_OLIVINE_CITY

- Script: `maps/OlivineCity.asm` (`49:4463 OlivineCity_MapEvents`)
- Blocks: `maps/OlivineCity.blk`
- Header: `data/maps/maps.asm:63` -> `map OlivineCity, TILESET_JOHTO, TOWN, LANDMARK_OLIVINE_CITY, MUSIC_VIOLET_CITY, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:52` -> `map_const OLIVINE_CITY, 20, 18` (group 1, id 14)
- Connections: `data/maps/attributes.asm:143-145` -> north `Route39` (`ROUTE_39`, offset 5), west `Route40` (`ROUTE_40`, offset 9). No south/east.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 13 | 21 | `OLIVINE_POKECENTER_1F` | 1 |
| 2 | 10 | 11 | `OLIVINE_GYM` | 1 |
| 3 | 25 | 11 | `OLIVINE_TIMS_HOUSE` | 1 |
| 4 | 0 | 0 | `OLIVINE_HOUSE_BETA` | 1 (marked `; inaccessible` in the asm) |
| 5 | 29 | 11 | `OLIVINE_PUNISHMENT_SPEECH_HOUSE` | 1 |
| 6 | 13 | 15 | `OLIVINE_GOOD_ROD_HOUSE` | 1 |
| 7 | 7 | 21 | `OLIVINE_CAFE` | 1 |
| 8 | 19 | 17 | `OLIVINE_MART` | 2 |
| 9 | 29 | 27 | `OLIVINE_LIGHTHOUSE_1F` | 1 |
| 10 | 19 | 27 | `OLIVINE_PORT_PASSAGE` | 1 |
| 11 | 20 | 27 | `OLIVINE_PORT_PASSAGE` | 2 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_OLIVINECITY_RIVAL_ENCOUNTER` (= 0) | 13 | 12 | `OlivineCityRivalSceneTop` | rival cutscene, ends with `setscene SCENE_OLIVINECITY_NOOP` |
| `SCENE_OLIVINECITY_RIVAL_ENCOUNTER` (= 0) | 13 | 13 | `OlivineCityRivalSceneBottom` | same, mirrored movement |

Scene ids come from the `scene_script` macro's own `const_def` (`macros/scripts/maps.asm:12-36`):
`SCENE_OLIVINECITY_RIVAL_ENCOUNTER` = 0, `SCENE_OLIVINECITY_NOOP` = 1. By this section the scene is
already 1 (the rival scene fires on the *first* Olivine visit, section 8), so both trip-wires are
inert and a bot may walk x=13 freely.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 17 | 11 | `BGEVENT_READ` | `OlivineCitySign` |
| 20 | 24 | `BGEVENT_READ` | `OlivineCityPortSign` |
| 7 | 11 | `BGEVENT_READ` | `OlivineGymSign` |
| 30 | 28 | `BGEVENT_READ` | `OlivineLighthouseSign` |
| 14 | 21 | `BGEVENT_READ` | `OlivineCityPokecenterSign` (`jumpstd PokecenterSignScript`) |
| 20 | 17 | `BGEVENT_READ` | `OlivineCityMartSign` (`jumpstd MartSignScript`) |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `OLIVINECITY_SAILOR1` | `SPRITE_SAILOR` | 26 | 27 | `WALK_UP_DOWN` (0,1) | `OBJECTTYPE_SCRIPT` | `OlivineCitySailor1Script` | -1 |
| `OLIVINECITY_STANDING_YOUNGSTER` | `SPRITE_YOUNGSTER` | 20 | 13 | `WALK_LEFT_RIGHT` (1,0) | `OBJECTTYPE_SCRIPT` | `OlivineCityStandingYoungsterScript` | -1 |
| `OLIVINECITY_SAILOR2` | `SPRITE_SAILOR` | 17 | 21 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `OlivineCitySailor2Script` | -1 |
| `OLIVINECITY_OLIVINE_RIVAL` | `SPRITE_OLIVINE_RIVAL` | 10 | 11 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_RIVAL_OLIVINE_CITY` |

Note the rival object sits **on the gym door tile** (10, 11). `InitializeEventsScript`
(`engine/events/std_scripts.asm:520`) sets `EVENT_RIVAL_OLIVINE_CITY` at new game, so he is hidden
except during the cutscene, and the door is walkable.

**Scripts of interest**

- `OlivineCityFlypointCallback` (`callback MAPCALLBACK_NEWMAP`): `setflag ENGINE_FLYPOINT_OLIVINE`
  (engine flag id 70). This is what makes "fly straight back to Olivine City" legal; it was already
  set in section 8.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_OLIVINE` (id 70) | `constants/engine_flags.asm:85` | set by `OlivineCityFlypointCallback` | Olivine selectable on the Fly map |
| `ENGINE_FLYPOINT_GOLDENROD` (id 69) | `constants/engine_flags.asm:84` | set by `maps/GoldenrodCity.asm:24` | Goldenrod selectable on the Fly map |
| `EVENT_RIVAL_OLIVINE_CITY` | `constants/event_flags.asm` | set by `InitializeEventsScript`, `appear`/`disappear` in the scene scripts | clear = rival standing on the gym door |

**Items** - none taken in this section.

**Trainers** - none on the overworld map.

**Wild encounters** - `data/wild/johto_water.asm:239`:

```
def_water_wildmons OLIVINE_CITY
db 6 percent ; encounter rate
db 20, TENTACOOL
db 15, TENTACOOL
db 20, TENTACRUEL
```

No grass table (`data/wild/johto_grass.asm` has no `OLIVINE` entry). Fish group is
`FISHGROUP_SHORE` per the header row.

---

### MAP_OLIVINE_LIGHTHOUSE_1F .. 6F

- Scripts: `maps/OlivineLighthouse1F.asm` ... `maps/OlivineLighthouse6F.asm`
- Blocks: `maps/OlivineLighthouse[1-6]F.blk`
- Header: `data/maps/maps.asm:112-117`. 1F-5F are
  `TILESET_LIGHTHOUSE, DUNGEON, LANDMARK_LIGHTHOUSE, MUSIC_LIGHTHOUSE, FALSE, PALETTE_DAY, FISHGROUP_SHORE`;
  **6F swaps the music to `MUSIC_VIOLET_CITY`** (line 117), which is a cheap way for a bot to
  confirm it reached the top.
- Dimensions: `constants/map_constants.asm:99-104` -> every floor is `10, 9` blocks = 20 x 18 tiles
  (group 1, ids 34-39).
- Attributes: `data/maps/attributes.asm:436` (6F) and neighbours - `$00`, no connections.

**Warps** - transcribed verbatim, all six floors.

`OLIVINE_LIGHTHOUSE_1F`:

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 10 | 17 | `OLIVINE_CITY` | 9 |
| 2 | 11 | 17 | `OLIVINE_CITY` | 9 |
| 3 | 3 | 11 | `OLIVINE_LIGHTHOUSE_2F` | 1 |
| 4 | 16 | 13 | `OLIVINE_LIGHTHOUSE_2F` | 3 |
| 5 | 17 | 13 | `OLIVINE_LIGHTHOUSE_2F` | 4 |

`OLIVINE_LIGHTHOUSE_2F`:

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 11 | `OLIVINE_LIGHTHOUSE_1F` | 3 |
| 2 | 5 | 3 | `OLIVINE_LIGHTHOUSE_3F` | 2 |
| 3 | 16 | 13 | `OLIVINE_LIGHTHOUSE_1F` | 4 |
| 4 | 17 | 13 | `OLIVINE_LIGHTHOUSE_1F` | 5 |
| 5 | 16 | 11 | `OLIVINE_LIGHTHOUSE_3F` | 4 |
| 6 | 17 | 11 | `OLIVINE_LIGHTHOUSE_3F` | 5 |

`OLIVINE_LIGHTHOUSE_3F`:

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 13 | 3 | `OLIVINE_LIGHTHOUSE_4F` | 1 |
| 2 | 5 | 3 | `OLIVINE_LIGHTHOUSE_2F` | 2 |
| 3 | 9 | 5 | `OLIVINE_LIGHTHOUSE_4F` | 4 |
| 4 | 16 | 11 | `OLIVINE_LIGHTHOUSE_2F` | 5 |
| 5 | 17 | 11 | `OLIVINE_LIGHTHOUSE_2F` | 6 |
| 6 | 16 | 9 | `OLIVINE_LIGHTHOUSE_4F` | 5 |
| 7 | 17 | 9 | `OLIVINE_LIGHTHOUSE_4F` | 6 |
| 8 | 8 | 3 | `OLIVINE_LIGHTHOUSE_4F` | 7 |
| 9 | 9 | 3 | `OLIVINE_LIGHTHOUSE_4F` | 8 |

`OLIVINE_LIGHTHOUSE_4F`:

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 13 | 3 | `OLIVINE_LIGHTHOUSE_3F` | 1 |
| 2 | 3 | 5 | `OLIVINE_LIGHTHOUSE_5F` | 2 |
| 3 | 9 | 7 | `OLIVINE_LIGHTHOUSE_5F` | 3 |
| 4 | 9 | 5 | `OLIVINE_LIGHTHOUSE_3F` | 3 |
| 5 | 16 | 9 | `OLIVINE_LIGHTHOUSE_3F` | 6 |
| 6 | 17 | 9 | `OLIVINE_LIGHTHOUSE_3F` | 7 |
| 7 | 8 | 3 | `OLIVINE_LIGHTHOUSE_3F` | 8 |
| 8 | 9 | 3 | `OLIVINE_LIGHTHOUSE_3F` | 9 |
| 9 | 16 | 7 | `OLIVINE_LIGHTHOUSE_5F` | 4 |
| 10 | 17 | 7 | `OLIVINE_LIGHTHOUSE_5F` | 5 |

`OLIVINE_LIGHTHOUSE_5F`:

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 15 | `OLIVINE_LIGHTHOUSE_6F` | 1 |
| 2 | 3 | 5 | `OLIVINE_LIGHTHOUSE_4F` | 2 |
| 3 | 9 | 7 | `OLIVINE_LIGHTHOUSE_4F` | 3 |
| 4 | 16 | 7 | `OLIVINE_LIGHTHOUSE_4F` | 9 |
| 5 | 17 | 7 | `OLIVINE_LIGHTHOUSE_4F` | 10 |
| 6 | 16 | 5 | `OLIVINE_LIGHTHOUSE_6F` | 2 |
| 7 | 17 | 5 | `OLIVINE_LIGHTHOUSE_6F` | 3 |

`OLIVINE_LIGHTHOUSE_6F`:

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 15 | `OLIVINE_LIGHTHOUSE_5F` | 1 |
| 2 | 16 | 5 | `OLIVINE_LIGHTHOUSE_5F` | 6 |
| 3 | 17 | 5 | `OLIVINE_LIGHTHOUSE_5F` | 7 |

**Which warps are ladders and which are pits.** Derived by decoding each floor's `.blk` against
`data/tilesets/lighthouse_collision.asm`. Block `$3a` and `$31` carry `LADDER` in their bottom-right
tile; block `$28` is `tilecoll FLOOR, FLOOR, PIT, PIT`, i.e. its two bottom tiles drop you a floor.

| floor | tile | block | kind | goes to |
|---|---|---|---|---|
| 1F | (10, 17), (11, 17) | `$2e` bottom tiles `WARP_CARPET_DOWN` | exit door | `OLIVINE_CITY` |
| 1F | (3, 11) | `$3a` | ladder UP | 2F (3, 11) |
| 2F | (3, 11) | `$31` | ladder DOWN | 1F (3, 11) |
| 2F | (5, 3) | `$3a` | ladder UP | 3F (5, 3) |
| 2F | (16, 13), (17, 13) | `$28` | **PIT** | 1F (16, 13) / (17, 13) |
| 3F | (5, 3) | `$31` | ladder DOWN | 2F (5, 3) |
| 3F | (13, 3) | `$3a` | ladder UP | 4F (13, 3) |
| 3F | (9, 5) | `$3a` | ladder UP | 4F (9, 5) |
| 3F | (16, 11), (17, 11) | `$28` | **PIT** | 2F (16, 11) / (17, 11) |
| 4F | (13, 3) | `$31` | ladder DOWN | 3F (13, 3) |
| 4F | (9, 5) | `$31` | ladder DOWN | 3F (9, 5) |
| 4F | (3, 5) | `$3a` | ladder UP | 5F (3, 5) |
| 4F | (9, 7) | `$3a` | ladder UP | 5F (9, 7) |
| 4F | (8, 3), (9, 3) | `$28` | **PIT** | 3F (8, 3) / (9, 3) |
| 4F | (16, 9), (17, 9) | `$28` | **PIT** | 3F (16, 9) / (17, 9) |
| 5F | (3, 5) | `$31` | ladder DOWN | 4F (3, 5) |
| 5F | (9, 7) | `$31` | ladder DOWN | 4F (9, 7) |
| 5F | (9, 15) | `$3a` | ladder UP | 6F (9, 15) |
| 5F | (16, 7), (17, 7) | `$28` | **PIT** | 4F (16, 7) / (17, 7) |
| 6F | (9, 15) | `$31` | ladder DOWN | 5F (9, 15) |
| 6F | (16, 5), (17, 5) | `$28` | **PIT** | 5F (16, 5) / (17, 5) |

The pit destination coordinates always match the pit's own coordinates on the floor below - the
warp row on the lower floor exists purely as a landing slot and its own destination is never
triggered (the landing tile is plain `FLOOR`).

**Coord events** - none on any floor.

**BG events** - only 5F: `bg_event 3, 13, BGEVENT_ITEM, OlivineLighthouse5FHiddenHyperPotion`.

**Object events** (trainers a bot will be forced into on the climb)

| floor | const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| 1F | - | `SPRITE_SAILOR` | 8 | 2 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `OlivineLighthouse1FSailorScript` | -1 |
| 1F | - | `SPRITE_POKEFAN_F` | 16 | 9 | `WALK_UP_DOWN` (0,2) | `OBJECTTYPE_SCRIPT` | `OlivineLighthouse1FPokefanFScript` | -1 |
| 2F | - | `SPRITE_SAILOR` | 9 | 3 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerSailorHuey` | -1 |
| 2F | - | `SPRITE_GENTLEMAN` | 17 | 8 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerGentlemanAlfred` | -1 |
| 3F | - | `SPRITE_SAILOR` | 9 | 2 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 1 | `TrainerSailorTerrell` | -1 |
| 3F | - | `SPRITE_GENTLEMAN` | 13 | 5 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerGentlemanPreston` | -1 |
| 3F | - | `SPRITE_YOUNGSTER` | 3 | 9 | `STANDING_UP` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerBirdKeeperTheo` | -1 |
| 3F | - | `SPRITE_POKE_BALL` | 8 | 2 | `STILL` | `OBJECTTYPE_ITEMBALL` | `OlivineLighthouse3FEther` | `EVENT_OLIVINE_LIGHTHOUSE_3F_ETHER` |
| 4F | - | `SPRITE_SAILOR` | 7 | 14 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerSailorKent` | -1 |
| 4F | - | `SPRITE_LASS` | 11 | 2 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 1 | `TrainerLassConnie` | -1 |
| 5F | - | `SPRITE_SAILOR` | 8 | 11 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerSailorErnest` | -1 |
| 5F | - | `SPRITE_YOUNGSTER` | 8 | 3 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerBirdKeeperDenis` | -1 |
| 5F | - | `SPRITE_POKE_BALL` | 15 | 12 | `STILL` | `OBJECTTYPE_ITEMBALL` | `OlivineLighthouse5FRareCandy` | `EVENT_OLIVINE_LIGHTHOUSE_5F_RARE_CANDY` |
| 5F | - | `SPRITE_POKE_BALL` | 6 | 15 | `STILL` | `OBJECTTYPE_ITEMBALL` | `OlivineLighthouse5FGreatBall` | `EVENT_OLIVINE_LIGHTHOUSE_5F_GREAT_BALL` |
| 5F | - | `SPRITE_POKE_BALL` | 2 | 13 | `STILL` | `OBJECTTYPE_ITEMBALL` | `OlivineLighthouse5FTMSwagger` | `EVENT_OLIVINE_LIGHTHOUSE_5F_TM_SWAGGER` |

`TrainerLassConnie` at 4F (11, 2) is "that one lass". The pit at 4F (8, 3) / (9, 3) is the tile
pair immediately left-and-below her, which matches the walkthrough's "falling to the left of that
one lass".

**6F object events** (`def_object_events`, `maps/OlivineLighthouse6F.asm:270-273`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `OLIVINELIGHTHOUSE6F_JASMINE` | `SPRITE_JASMINE` | 8 | 8 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `OlivineLighthouseJasmine` | `EVENT_OLIVINE_LIGHTHOUSE_JASMINE` (0x6d2) |
| `OLIVINELIGHTHOUSE6F_MONSTER` | `SPRITE_MONSTER` | 9 | 8 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `OlivineLighthouseAmphy` | -1 |
| `OLIVINELIGHTHOUSE6F_POKE_BALL` | `SPRITE_POKE_BALL` | 3 | 4 | `STILL` | `OBJECTTYPE_ITEMBALL` | `OlivineLighthouse6FSuperPotion` (`itemball SUPER_POTION`) | `EVENT_OLIVINE_LIGHTHOUSE_6F_SUPER_POTION` (0x668) |

**Scripts of interest**

- `OlivineLighthouseJasmine` (`44:6ccd`, `maps/OlivineLighthouse6F.asm:11`):
  1. `faceplayer` / `opentext`
  2. `checkitem SECRETPOTION` -> `.BroughtSecretpotion` (`44:6ce7`). Without the potion it falls
     into the `EVENT_JASMINE_EXPLAINED_AMPHYS_SICKNESS` (0x37) branch and just repeats the request.
  3. `.BroughtSecretpotion`: `writetext JasmineCureAmphyText`, `yesorno`. **`iffalse .Refused`** -
     answering No leaves everything unset and the gym stays empty, so a bot must answer Yes.
  4. `takeitem SECRETPOTION`, a long cutscene (`turnobject`, `playmusic MUSIC_HEAL`,
     `special RestartMapMusic`, `cry AMPHAROS`, `special FadeOutToWhite` / `FadeInFromWhite`).
  5. **`setevent EVENT_JASMINE_RETURNED_TO_GYM`** (0x20) and
     **`clearevent EVENT_OLIVINE_GYM_JASMINE`** (0x6d3) - this pair is the entire gate on the gym.
  6. `readvar VAR_FACING` picks one of three exit movements
     (`OlivineLighthouseJasmineLeaves{Up,Down,Right}Movement`) then `disappear OLIVINELIGHTHOUSE6F_JASMINE`.
- `OlivineLighthouseAmphy`: cosmetic; branches on `EVENT_JASMINE_RETURNED_TO_GYM` for the healthy
  cry.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_JASMINE_RETURNED_TO_GYM` (0x20) | `constants/event_flags.asm:41` | set by `OlivineLighthouseJasmine`; read by `OlivineGymGuideScript` and `maps/EcruteakCity.asm:47` | the section's real progress bit |
| `EVENT_OLIVINE_GYM_JASMINE` (0x6d3) | `constants/event_flags.asm:1141` | set at new game by `InitializeEventsScript` (`engine/events/std_scripts.asm:511`), cleared by `OlivineLighthouseJasmine` | clear = Jasmine is standing in her gym |
| `EVENT_OLIVINE_LIGHTHOUSE_JASMINE` (0x6d2) | `constants/event_flags.asm:1140` | `disappear` at the end of the cure | set = she has left the lighthouse |
| `EVENT_JASMINE_EXPLAINED_AMPHYS_SICKNESS` (0x37) | `constants/event_flags.asm:64` | `OlivineLighthouseJasmine` | first-visit text latch only |

**Items** - `SECRETPOTION` is consumed (`takeitem SECRETPOTION`). Nothing is given.

**Wild encounters** - none on any lighthouse floor (indoor `DUNGEON`, no table).

---

### MAP_OLIVINE_GYM

- Script: `maps/OlivineGym.asm` (`51:410e OlivineGym_MapScripts`, `51:4507 OlivineGym_MapEvents`)
- Blocks: `maps/OlivineGym.blk` (`2b:7c7b OlivineGym_Blocks`)
- Header: `data/maps/maps.asm:51` -> `map OlivineGym, TILESET_CHAMPIONS_ROOM, INDOOR, LANDMARK_OLIVINE_CITY, MUSIC_GYM, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:40` -> `map_const OLIVINE_GYM, 5, 8` = 10 x 16 tiles (group 1, id 2)
- Attributes: `data/maps/attributes.asm:473` -> `map_attributes OlivineGym, OLIVINE_GYM, $00`, no connections
- `def_scene_scripts` and `def_callbacks` are both **empty** - no scene variable, no map callbacks.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 15 | `OLIVINE_CITY` | 2 |
| 2 | 5 | 15 | `OLIVINE_CITY` | 2 |

**Coord events** (`def_coord_events`) - **none**. There is no trip-wire in this gym; every
interaction is a `faceplayer` talk.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 3 | 13 | `BGEVENT_READ` | `OlivineGymStatue` |
| 6 | 13 | `BGEVENT_READ` | `OlivineGymStatue` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `OLIVINEGYM_JASMINE` | `SPRITE_JASMINE` | 5 | 3 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT`, `PAL_NPC_RED` | `OlivineGymJasmineScript` | `EVENT_OLIVINE_GYM_JASMINE` |
| `OLIVINEGYM_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 7 | 13 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT`, `PAL_NPC_RED` | `OlivineGymGuideScript` | -1 |

The walkthrough's "there are no apprentices of any kind" is literally true in the asm: the object
table has exactly two rows and neither is `OBJECTTYPE_TRAINER`.

**Walkable shape** (decoded from `maps/OlivineGym.blk` against
`data/tilesets/champions_room_collision.asm`, `.` = FLOOR, `#` = WALL, `W` = `WARP_CARPET_DOWN`,
`U` = `UP_WALL`; x across 0..9, y down 0..15):

```
 y0  # # # # # # # # # #
 y1  # # # # # # # # # #
 y2  # # # U U U U # # #
 y3  # # # . . . . # # #
 y4  # # # . . . . # # #
 y5  # # # # . . # # # #
 y6  # # # # . . # # # #
 y7  # # # . . . . # # #
 y8  # # . . . . . . # #
 y9  # # # # . . # # # #
y10  # # # . . . . # # #
y11  # # # . . . . # # #
y12  # # . # . . # . # #
y13  # # . # . . # . # #
y14  # . . . . . . . . #
y15  # . . . W W . . . #
```

Columns x=4 and x=5 are floor from y=14 straight up to y=3, so a bot can enter at (4, 15) or
(5, 15) and hold UP to reach Jasmine at (5, 3) with no turns. The two statues are the wall tiles at
(3, 13) and (6, 13); the gym guide stands at (7, 13), reachable from (7, 14).

**Scripts of interest**

- `OlivineGymJasmineScript` (`51:4110`, `maps/OlivineGym.asm:10`). Opcode-by-opcode:

  ```
  faceplayer / opentext
  checkevent EVENT_BEAT_JASMINE -> iftrue .FightDone
  writetext Jasmine_SteelTypeIntro / waitbutton / closetext
  winlosstext Jasmine_BetterTrainer, 0
  loadtrainer JASMINE, JASMINE1
  startbattle
  reloadmapafterbattle
  setevent EVENT_BEAT_JASMINE
  opentext / writetext Text_ReceivedMineralBadge
  playsound SFX_GET_BADGE / waitsfx
  setflag ENGINE_MINERALBADGE
  readvar VAR_BADGES
  scall OlivineGymActivateRockets
  .FightDone:
  checkevent EVENT_GOT_TM23_IRON_TAIL -> iftrue .GotIronTail
  writetext Jasmine_BadgeSpeech / promptbutton
  verbosegiveitem TM_IRON_TAIL
  iffalse .NoRoomForIronTail
  setevent EVENT_GOT_TM23_IRON_TAIL
  writetext Jasmine_IronTailSpeech / waitbutton / closetext / end
  ```

  Two bot-relevant consequences: (a) `winlosstext ..., 0` means there is **no loss-warp script**,
  losing just blacks you out normally; (b) if the bag has no room in the TM pocket,
  `verbosegiveitem` returns false and `EVENT_GOT_TM23_IRON_TAIL` is **not** set - re-talking to
  Jasmine retries the give from `.FightDone`. Keep TM room free.

- `OlivineGymActivateRockets` (`51:4159`): the `scall`ed tail, dispatching on the `readvar
  VAR_BADGES` value that was just pushed:

  ```
  ifequal 7, .RadioTowerRockets   -> jumpstd RadioTowerRocketsScript
  ifequal 6, .GoldenrodRockets    -> jumpstd GoldenrodRocketsScript
  end
  ```

  `VAR_BADGES` is `CountSetBits` over the two `wBadges` bytes
  (`engine/overworld/variables.asm:80-86`), so it counts Johto **and** Kanto badges. Since
  `setflag ENGINE_MINERALBADGE` runs first, MINERALBADGE is included in the count. On the
  walkthrough's route (Zephyr, Hive, Plain, Fog, Storm, Mineral) the count is **6** and
  `GoldenrodRocketsScript` fires: `clearevent EVENT_GOLDENROD_CITY_ROCKET_TAKEOVER`
  (`engine/events/std_scripts.asm:251-253`), which makes the two Rocket grunts appear in Goldenrod
  City at (28, 20) and (8, 15) (`maps/GoldenrodCity.asm:376-377`). Every gym carries the same
  `scall` (`maps/VioletGym.asm:31`, `maps/MahoganyGym.asm:34`, ...), so whichever gym hands you
  badge 6 is the one that arms the Rockets - beating Jasmine *before* Chuck simply moves the
  trigger to Chuck.

- `OlivineGymGuideScript` (`51:4168`): three-way on `EVENT_BEAT_JASMINE`, then
  `EVENT_JASMINE_RETURNED_TO_GYM`. Text only, no flags written.
- `OlivineGymStatue` (`51:418a`): `checkflag ENGINE_MINERALBADGE`, `jumpstd GymStatue1Script`
  before, `gettrainername STRING_BUFFER_4, JASMINE, JASMINE1` + `jumpstd GymStatue2Script` after.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_OLIVINE_GYM_JASMINE` (0x6d3) | `constants/event_flags.asm:1141` | set by `InitializeEventsScript`; cleared by `OlivineLighthouseJasmine` | **precondition**: while set, the gym is empty and unbeatable |
| `EVENT_BEAT_JASMINE` (0x4c1) | `constants/event_flags.asm:710` | set by `OlivineGymJasmineScript` | postcondition of the battle |
| `ENGINE_MINERALBADGE` (engine flag id 30) | `constants/engine_flags.asm:42`, `data/events/engine_flags.asm:50` (`engine_flag wJohtoBadges, MINERALBADGE`) | `setflag` here, `checkflag` in `OlivineGymStatue` | the badge bit; `MINERALBADGE` bit index in `wJohtoBadges` is `constants/ram_constants.asm:256` |
| `EVENT_GOT_TM23_IRON_TAIL` (0x0d) | `constants/event_flags.asm:19` | `OlivineGymJasmineScript` | one-time TM guard |
| `EVENT_JASMINE_RETURNED_TO_GYM` (0x20) | `constants/event_flags.asm:41` | read by `OlivineGymGuideScript` | flavour only inside the gym |
| `EVENT_GOLDENROD_CITY_ROCKET_TAKEOVER` (0x6cd) | `constants/event_flags.asm` | cleared by `GoldenrodRocketsScript` | side effect of reaching 6 badges |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `TM_IRON_TAIL` (TM23, item id `$d6`, `constants/item_constants.asm:243`) | `verbosegiveitem` after the battle | `OlivineGymJasmineScript` | `EVENT_GOT_TM23_IRON_TAIL` |
| 3500 prize money | battle reward | see below | - |

Prize money check: `TrainerClassAttributes` for Jasmine (`data/trainers/attributes.asm`, the sixth
gym-leader block) is `db HYPER_POTION, NO_ITEM ; items` and `db 25 ; base reward`.
`ComputeTrainerReward` (`engine/battle/read_trainer_party.asm:300-317`) sets
`wBattleReward = 25 * wCurPartyLevel` = `25 * 35` = **875**, and the payout loop in
`engine/battle/core.asm:2340-2360` adds `wBattleReward` **four times** (`ld c, 4`). 875 x 4 =
**3500**, which matches the walkthrough exactly. (Note Jasmine's AI holds a `HYPER_POTION`.)

Badge effect check: `BadgeStatBoosts` (`engine/battle/core.asm:6533-6588`) - the comment block
states "MineralBadge: Defense", and the code deliberately swaps the PlainBadge and MineralBadge
bits before the every-other-badge walk, boosting the stat at `wBattleMonDefense` by 1/8
(`BoostStat`). Separately `data/types/badge_type_boosts.asm:7` maps MINERALBADGE to `STEEL` for the
type-matching trainer-card/boost table. So the walkthrough's "raises your Pokemon's defense
slightly" is correct.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `JASMINE` / `JASMINE1` | `JASMINE` (trainer class 6, `constants/trainer_constants.asm:42-43`) | 1 | `JasmineGroup` (`0e:5a42`, `data/trainers/parties.asm:53`) | `OlivineGymJasmineScript` | none (gym leaders have no phone row) |

`JasmineGroup`, verbatim (`TRAINERTYPE_MOVES`):

```
db "JASMINE@", TRAINERTYPE_MOVES
db 30, MAGNEMITE,  THUNDERBOLT, SUPERSONIC, SONICBOOM, THUNDER_WAVE
db 30, MAGNEMITE,  THUNDERBOLT, SUPERSONIC, SONICBOOM, THUNDER_WAVE
db 35, STEELIX,    SCREECH, SUNNY_DAY, ROCK_THROW, IRON_TAIL
db -1 ; end
```

EXP check against the walkthrough's numbers: trainer EXP is `base * level / 7 * 3 / 2`.
Magnemite base exp 89 (`data/pokemon/base_stats/magnemite.asm:8`) -> `89*30/7 = 381`, `*3/2 = 571`.
Steelix base exp 196 (`data/pokemon/base_stats/steelix.asm:8`) -> `196*35/7 = 980`, `*3/2 = 1470`.
Both match.

**Wild encounters** - none (`INDOOR`).

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Jasmine is not in her gym | `maps/OlivineGym.asm:212` object row, event flag `EVENT_OLIVINE_GYM_JASMINE`; visibility semantics in `engine/overworld/scripting.asm:879-898` | flag must be **clear** | `clearevent EVENT_OLIVINE_GYM_JASMINE` at `maps/OlivineLighthouse6F.asm:69` |
| Jasmine will not leave the lighthouse | `maps/OlivineLighthouse6F.asm:14` `checkitem SECRETPOTION` | `SECRETPOTION` in the bag (from the Cianwood Pharmacy, section 8) | hand it over and answer **Yes** to `JasmineCureAmphyText` (`yesorno` at line 29; `iffalse .Refused` aborts the whole scene) |
| Cannot Fly to Olivine / Goldenrod | `engine/events/overworld.asm:544-547` (`FlyFunction.TryFly` -> `ld de, ENGINE_STORMBADGE` / `call CheckBadge`), mirrored in the port at `src/world/gen2/FieldMoves.lua:107` (`FLY = "STORM"`), plus `ENGINE_FLYPOINT_OLIVINE` (id 70) / `ENGINE_FLYPOINT_GOLDENROD` (id 69) set by each town's `MAPCALLBACK_NEWMAP` (`maps/OlivineCity.asm:22`, `maps/GoldenrodCity.asm:24`) | `ENGINE_STORMBADGE` + having visited the town on foot | both already true entering this section |
| Haircut unavailable | `OlderHaircutBrotherScript` `readvar VAR_WEEKDAY` + `GoldenrodUndergroundCheckDayOfWeekCallback` | in-game weekday must be TUE/THU/SAT for the 500 brother | wait for the day, or use the younger brother SUN/WED/FRI for 300 |
| Second haircut same day | `checkflag ENGINE_GOLDENROD_UNDERGROUND_GOT_HAIRCUT` (engine flag 89) | flag clear | daily reset |
| 4F of the lighthouse is a dead end from the (13, 3) ladder | geometry: 4F pit at (8, 3)/(9, 3), block `$28` in `maps/OlivineLighthouse4F.blk`, warps 7/8 | must step into the pit and re-climb via 3F warp 3 at (9, 5) | no flag, purely navigational |
| No TM pocket room | `verbosegiveitem TM_IRON_TAIL` -> `iffalse .NoRoomForIronTail` (`maps/OlivineGym.asm:35-36`) | free TM slot | drop a TM and re-talk to Jasmine |

Nothing in this section requires `CUT`, `SURF`, `STRENGTH`, `WHIRLPOOL`, `WATERFALL` or `FLASH`.

---

## 4. Bot checklist

Optional Eevee-happiness detour (steps 1-5) can be skipped entirely.

1. **Fly** to `SPAWN_GOLDENROD`. Precondition: `ENGINE_STORMBADGE` set and `ENGINE_FLYPOINT_GOLDENROD` (id 69) set. Postcondition: on `GOLDENROD_CITY`.
2. `GOLDENROD_CITY`: walk to (11, 29), step onto warp 15. Postcondition: on `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES` at warp 5 (4, 29).
3. `GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES`: walk to (5, 25), step onto warp 4. Postcondition: on `GOLDENROD_UNDERGROUND` at warp 2 (3, 34).
4. `GOLDENROD_UNDERGROUND`: precondition `VAR_WEEKDAY in {TUESDAY, THURSDAY, SATURDAY}` and `ENGINE_GOLDENROD_UNDERGROUND_GOT_HAIRCUT` clear and money >= 500. Walk to (6, 14) and face RIGHT (the brother stands at (7, 14) facing left); talk. Answer **Yes**, pick the Eevee. Postcondition: `ENGINE_GOLDENROD_UNDERGROUND_GOT_HAIRCUT` set, money -500, Eevee happiness +1/+3/+5.
5. Retrace warps out (warp 2 at (3, 34) -> switch-room warp 5/6 at (4, 29)/(5, 29) -> `GOLDENROD_CITY`).
6. **Fly** to `SPAWN_OLIVINE`. Precondition: `ENGINE_FLYPOINT_OLIVINE` (id 70). Postcondition: on `OLIVINE_CITY`.
7. `OLIVINE_CITY`: walk to (29, 27), step onto warp 9. Postcondition: on `OLIVINE_LIGHTHOUSE_1F` at warp 1 (10, 17).
8. `1F`: walk to (3, 11), step on ladder-up. -> `2F` (3, 11).
9. `2F`: walk to (5, 3), ladder-up. -> `3F` (5, 3). (Sailor Huey (9, 3) and Gentleman Alfred (17, 8) are already beaten; their `EVENT_BEAT_*` flags guard re-battle.)
10. `3F`: walk to (13, 3), ladder-up. -> `4F` (13, 3).
11. `4F`: walk to the pit at (8, 3) or (9, 3) - "left of Lass Connie at (11, 2)". Step in. -> `3F` (8, 3)/(9, 3).
12. `3F`: walk to (9, 5), ladder-up. -> `4F` (9, 5).
13. `4F`: walk to (9, 7), ladder-up. -> `5F` (9, 7). (Alternative: 4F (3, 5) -> 5F (3, 5).)
14. `5F`: walk to (9, 15), ladder-up. -> `6F` (9, 15). Confirm arrival by `MUSIC_VIOLET_CITY` playing (6F is the only lighthouse floor with it).
15. `6F`: precondition `SECRETPOTION` in bag and `EVENT_OLIVINE_LIGHTHOUSE_JASMINE` clear. Walk to (8, 9) and face UP (Jasmine at (8, 8) faces down) and talk. Answer **Yes** to `JasmineCureAmphyText`. Sit through ~120 frames of cutscene (`pause 60`, `pause 15`, several `pause 10`). Postcondition: `SECRETPOTION` removed, `EVENT_JASMINE_RETURNED_TO_GYM` set, `EVENT_OLIVINE_GYM_JASMINE` **cleared**, `EVENT_OLIVINE_LIGHTHOUSE_JASMINE` set.
16. Descend: `6F` pit at (16, 5)/(17, 5) -> `5F`; `5F` pit at (16, 7)/(17, 7) -> `4F`; `4F` pit at (16, 9)/(17, 9) -> `3F`; `3F` pit at (16, 11)/(17, 11) -> `2F`; `2F` pit at (16, 13)/(17, 13) -> `1F`. Then `1F` (10, 17)/(11, 17) facing DOWN -> `OLIVINE_CITY` warp 9 at (29, 27).
17. `OLIVINE_CITY`: (optional) heal at the Pokecenter, warp 1 at (13, 21). Save before the gym.
18. `OLIVINE_CITY`: walk to (10, 11), step onto warp 2. Postcondition: on `OLIVINE_GYM` at warp 1 (4, 15).
19. `OLIVINE_GYM`: (optional) talk to the guide by walking to (7, 14) and facing UP.
20. `OLIVINE_GYM`: hold UP along x=5 from (5, 14) to (5, 4), face UP, talk to Jasmine at (5, 3). Precondition: `EVENT_OLIVINE_GYM_JASMINE` clear, `EVENT_BEAT_JASMINE` clear, a free TM slot. Battle `loadtrainer JASMINE, JASMINE1`.
21. Win. Postconditions in order: `EVENT_BEAT_JASMINE` set -> `ENGINE_MINERALBADGE` set -> money +3500 -> `VAR_BADGES` re-read -> if it equals 6, `EVENT_GOLDENROD_CITY_ROCKET_TAKEOVER` cleared (Rockets appear in Goldenrod) -> `verbosegiveitem TM_IRON_TAIL` -> `EVENT_GOT_TM23_IRON_TAIL` set.
22. Leave via (4, 15)/(5, 15) facing DOWN -> `OLIVINE_CITY` warp 2 (10, 11).

Battle notes for the driver: lead a Fire or Fighting attacker; both Magnemite carry
`THUNDER_WAVE` (paralysis risk) and `SONICBOOM` (fixed 20 damage, ignores type - it will connect on
a Ground type); Steelix has `IRON_TAIL` and `SUNNY_DAY` (which boosts your own Fire moves too).

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map headers, blocks, warps, coord/bg/object events for all of these maps | `src/import/RomExtractorGen2.lua` (`readItemBall` ~line 2875, object/trainer struct decode ~line 2961) | implemented (data-driven from ROM, no hand-ported Olivine map) |
| Script opcodes used by `OlivineGymJasmineScript` (`faceplayer`, `checkevent`, `winlosstext`, `loadtrainer`, `startbattle`, `reloadmapafterbattle`, `setflag`, `readvar`, `scall`, `verbosegiveitem`, `jumpstd`, `gettrainername`) | `src/script/gen2/Vm.lua` (`faceplayer` L164, `gettrainername` L407, `verbosegiveitem` L490, `jumpstd` L742, `loadtrainer` L806, `winlosstext` L918); opcode table `src/script/gen2/Opcodes.lua` | implemented |
| `VAR_BADGES` (`CountSetBits` over Johto+Kanto) | `src/world/gen2/World.lua:1240-1245` | implemented |
| Fly gate + flypoint engine flags | `src/world/gen2/FieldMoves.lua:103-130`, `FLYPOINTS` L340-368 (`OLIVINE` flag 70, `GOLDENROD` flag 69) | implemented |
| Pit / warp-carpet collision (the lighthouse climb) | `src/world/gen2/Permissions.lua:162-180` (`COLL_PIT` 0x60 / 0x68 and the `$7x` warp nybble; carpet direction table) | implemented |
| Haircut brothers (weighted roll + happiness deltas) | `src/script/gen2/Specials.lua:1577-1615` (`HAIRCUT_TABLES`), `src/core/gen2/Happiness.lua:79-84` | implemented |
| Trainer prize money incl. the x4 payout loop | `src/battle/gen2/Prize.lua` (header comment cites `ld c, 4`) | implemented |
| Gym-leader battle music for `JASMINE` | `src/battle/gen2/BattleMusic.lua:25`, `src/battle/gen2/Battle.lua:86` | implemented |
| Eevee -> Espeon/Umbreon (`EVOLVE_HAPPINESS`, `HAPPINESS_TO_EVOLVE` 220, `TR_MORNDAY`/`TR_NITE`) | `src/core/gen2/Evolution.lua:40-52,143` | implemented |
| Trainer card badge display | `src/ui/gen2/TrainerCard.lua`; leader palette list at `src/import/RomExtractorGen2.lua:4982` | implemented |
| **`BadgeStatBoosts`** - the MINERALBADGE +1/8 Defense (and the PlainBadge/MineralBadge bit swap) | nothing found. `grep -i badge src/battle/gen2/` returns no hits; the only badge-boost code in the repo is Gen 1's (`src/battle/Damage.lua:24`, `src/battle/BattleState.lua:439`) | **missing** |
| **`BadgeTypeBoosts`** (`data/types/badge_type_boosts.asm`, MINERALBADGE -> STEEL) | no hits for `BadgeTypeBoosts` anywhere in `src/` | **missing** |
| A driver that walks the lighthouse or fights a gym leader | `tests/drivers/gold_*.lua` - `gold_trainer_smoke.lua` and `gold_battle_smoke.lua` exist but neither names Olivine or Jasmine | **missing** (no section-9 driver) |

---

## 6. Unresolved / verify by hand

- **"Climb up the Olivine Lighthouse in the EXACT same way you came up."** The ladder/pit graph in
  section 2 is fully decoded from the `.blk` files and `data/tilesets/lighthouse_collision.asm`, but
  I did **not** flood-fill each floor to prove the specific walking path between a ladder and the
  next pit. Steps 8-14 of the checklist are the geometrically obvious route (and the pit at 4F
  (8, 3)/(9, 3) really is left of Lass Connie at (11, 2)), but the intermediate tile-by-tile route
  on 3F, 4F and 5F should be confirmed in-game before a driver hard-codes it.
- **"Talk to the man who is running the second/middle shop."** The asm has four merchant objects in
  one column at x=7: gramps y=11, older brother y=14, younger brother y=15, granny y=21, and
  `GoldenrodUndergroundCheckDayOfWeekCallback` hides most of them on any given day. "Middle" is
  therefore day-dependent; the unambiguous identifier is the **500 price**
  (`GOLDENRODUNDERGROUND_OLDER_HAIRCUT_PRICE`), i.e. the older brother at (7, 14), available
  TUE/THU/SAT only. The walkthrough does not mention the weekday restriction at all.
- **"Eevee's happiness meter should get a nice boost."** The older brother's roll is +1 (30%),
  +3 (50%) or +5 (20%) at happiness < 200. The younger brother's top roll is +10. The walkthrough's
  implied "500 is the better option" is not supported by
  `data/events/happiness_probabilities.asm` / `data/events/happiness_changes.asm`.
- **"Say Yes to the fact that Ampharos will be cured by the medicine."** Confirmed as a hard
  requirement (`yesorno` / `iffalse .Refused` at `maps/OlivineLighthouse6F.asm:29-30`), but note the
  refusal path is *recoverable*: it sets nothing, so the player can simply talk again.
- **EXP values (571 / 1470)** are reproduced by the standard trainer formula from the base-exp bytes
  I read, but I did not open the EXP-award routine itself to confirm the `*3/2` trainer multiplier
  in this disassembly; treat those two numbers as arithmetic agreement rather than a code citation.
- **`data/trainers/attributes.asm` Jasmine row**: the file has no per-class labels, only ordered
  comment headers. I identified Jasmine's row by the `; Jasmine` comment (sixth block, `db 25 ;
  base reward`, `db HYPER_POTION, NO_ITEM`). If that comment ever drifts from the class order in
  `constants/trainer_constants.asm`, the 3500 derivation drifts with it.
- The walkthrough's "you can go to the Lake of Rage first" branch is out of scope here; nothing in
  the Olivine Gym asm checks for it.

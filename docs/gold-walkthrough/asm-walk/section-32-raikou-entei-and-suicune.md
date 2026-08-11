# Section 32 - Raikou, Entei, and Suicune

Source: `../section-32-raikou-entei-and-suicune.txt`
Maps covered: `MAP_ROUTE_29`, `MAP_ROUTE_30`, `MAP_ROUTE_31`, `MAP_ROUTE_32`,
`MAP_ROUTE_33`, `MAP_ROUTE_34`, `MAP_ROUTE_35`, `MAP_ROUTE_36`, `MAP_ROUTE_37`,
`MAP_ROUTE_38`, `MAP_ROUTE_39`, `MAP_ROUTE_42`, `MAP_ROUTE_43`, `MAP_ROUTE_44`,
`MAP_ROUTE_45`, `MAP_ROUTE_46` (the sixteen `RoamMaps` entries), plus
`MAP_VIOLET_CITY` as the Fly anchor the walkthrough names.
Badges / key milestones in this section: none. The milestone is three catches:
`RAIKOU`, `ENTEI`, `SUICUNE`. Every one of them clears its own roam slot
permanently.

This section is a *mechanic*, not a walk. There is no scripted trigger anywhere
on these sixteen maps that has anything to do with the beasts; the entire
feature lives in `engine/overworld/wildmons.asm`,
`engine/battle/core.asm` and `data/wild/roammon_maps.asm`. Section 2 therefore
opens with a "roam engine" block before the per-map blocks, because that block
is the part a bot actually has to implement.

---

## 1. Route order

The walkthrough gives a policy, not an itinerary: cross route boundaries as fast
as possible, because every crossing is one `UpdateRoamMons` call. The named
concrete loop is the Violet City / Route 36 hub.

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 0 | `MAP_BURNED_TOWER_B1F` | `maps/BurnedTowerB1F.asm` | (earlier section) | (earlier section) | `special InitRoamMons` at `ReleaseTheBeasts` is the only thing that ever creates the three roamers. Out of scope here; owned by the Burned Tower section. |
| 1 | `MAP_VIOLET_CITY` | `maps/VioletCity.asm` | Fly (`MAPSETUP_TELEPORT`) | west connection | "fly to Violet City, then stay on a bike and keep switching between Routes 35, 36, and 37". Note the Fly itself runs `JumpRoamMons`, i.e. it *scatters* the beasts before the loop starts. |
| 2 | `MAP_ROUTE_36` | `maps/Route36.asm` | west connection from Violet City | south / north connections | Route 36 is the four-way roam junction (`ROUTE_35`, `ROUTE_31`, `ROUTE_32`, `ROUTE_37`) and the only map with a direct edge to Violet City. |
| 3 | `MAP_ROUTE_35` | `maps/Route35.asm` | south connection from Route 36 | north connection back | Half of the "left right left right" oscillation. Each crossing = one `UpdateRoamMons`. |
| 4 | `MAP_ROUTE_37` | `maps/Route37.asm` | north connection from Route 36 | south connection back | Other half of the oscillation, and Entei's starting route. |
| 5 | `MAP_ROUTE_42` | `maps/Route42.asm` | west connection from Ecruteak City | east connection to Mahogany Town | "go to Route 42 with the Max Repel". Raikou's starting route, the other four-way roam junction, and it carries a free `ULTRA_BALL` item ball. |
| - | `MAP_SILVER_CAVE_OUTSIDE` / `MAP_SILVER_CAVE_ROOM_*` | `maps/SilverCaveOutside.asm` etc. | - | - | "sharing EXP at Mount Silver" to raise the False Swipe Scyther. Mount Silver belongs to a later section; only the level ceiling (see section 3) matters here. |

Spill-over note: the walkthrough's Master Ball aside points at the Elm /
Radio Tower reward, and its Scyther training points at Mount Silver. Both are
other sections' maps; nothing about them is transcribed here.

---

## 2. Maps

### The roam engine (not a map)

This is the part of the section that is code rather than map data. Everything
below was read out of the files named.

**State: `roam_struct`** (`macros/ram.asm`, 7 bytes each, three of them)

| field | symbol (Raikou slot) | address | meaning |
|---|---|---|---|
| Species | `wRoamMon1Species` | `01:dd1a` | `0` once caught or defeated, which is what retires the slot forever |
| Level | `wRoamMon1Level` | `01:dd1b` | always 40, never changes (no EXP in the struct) |
| MapGroup | `wRoamMon1MapGroup` | `01:dd1c` | `GROUP_N_A` when retired |
| MapNumber | `wRoamMon1MapNumber` | `01:dd1d` | `MAP_N_A` when retired |
| HP | `wRoamMon1HP` | `01:dd1e` | **one byte**; `0` means "stats not rolled yet" |
| DVs | `wRoamMon1DVs` | `01:dd1f` | rolled once, on the first encounter, then kept |

Entei is slot 2 (`wRoamMon2Species` `01:dd21`), Suicune slot 3
(`wRoamMon3Species` `01:dd28`). Slot order is load bearing:
`CheckEncounterRoamMon` indexes the structs by a random 0..2 and
`GetRoamMonHP` walks them by species.

Player-position backup: `wRoamMons_CurMapGroup` `01:dd30`,
`wRoamMons_LastMapGroup` `01:dd32` (`_BackUpMapIndices`, `0a:6942`).

**Creation: `InitRoamMons`** (`engine/overworld/wildmons.asm:488`, `0a:67d7`)

Called exactly once, from `maps/BurnedTowerB1F.asm:65`, at the tail of
`ReleaseTheBeasts` right after `setscene SCENE_BURNEDTOWERB1F_NOOP` and
`setevent EVENT_RELEASED_THE_BEASTS`. It writes:

| slot | species | level | starting map |
|---|---|---|---|
| 1 | `RAIKOU` | 40 | `MAP_ROUTE_42` (`GROUP_ROUTE_42`) |
| 2 | `ENTEI` | 40 | `MAP_ROUTE_37` (`GROUP_ROUTE_37`) |
| 3 | `SUICUNE` | 40 | `MAP_ROUTE_38` (`GROUP_ROUTE_38`) |

HP is written as `0` (`xor a ; generate new stats`).

**The map graph: `RoamMaps`** (`data/wild/roammon_maps.asm`, `0a:695b`,
`NUM_ROAMMON_MAPS` = 16). Transcribed verbatim:

| start map | reachable maps |
|---|---|
| `ROUTE_29` | `ROUTE_30`, `ROUTE_46` |
| `ROUTE_30` | `ROUTE_29`, `ROUTE_31` |
| `ROUTE_31` | `ROUTE_30`, `ROUTE_32`, `ROUTE_36` |
| `ROUTE_32` | `ROUTE_36`, `ROUTE_31`, `ROUTE_33` |
| `ROUTE_33` | `ROUTE_32`, `ROUTE_34` |
| `ROUTE_34` | `ROUTE_33`, `ROUTE_35` |
| `ROUTE_35` | `ROUTE_34`, `ROUTE_36` |
| `ROUTE_36` | `ROUTE_35`, `ROUTE_31`, `ROUTE_32`, `ROUTE_37` |
| `ROUTE_37` | `ROUTE_36`, `ROUTE_38`, `ROUTE_42` |
| `ROUTE_38` | `ROUTE_37`, `ROUTE_39`, `ROUTE_42` |
| `ROUTE_39` | `ROUTE_38` |
| `ROUTE_42` | `ROUTE_43`, `ROUTE_44`, `ROUTE_37`, `ROUTE_38` |
| `ROUTE_43` | `ROUTE_42`, `ROUTE_44` |
| `ROUTE_44` | `ROUTE_42`, `ROUTE_43`, `ROUTE_45` |
| `ROUTE_45` | `ROUTE_44`, `ROUTE_46` |
| `ROUTE_46` | `ROUTE_45`, `ROUTE_29` |

The file's own comment: "Notably missing are Route 40 and Route 41, which are
water routes." That is the walkthrough's "the exceptions are Routes 40 and 41".

**Movement: `UpdateRoamMons`** (`engine/overworld/wildmons.asm:578`, `0a:6859`)

`.Update` per live beast, then `_BackUpMapIndices`. One random byte does double
duty:

- `and %00011111`; if the result is zero (1 in 32) it calls `JumpRoamMon`
  instead, i.e. a completely random `RoamMaps` entry.
- otherwise `and %11` of that same masked value is the connection index. An
  index `>=` the entry's connection count re-rolls, and so does a candidate
  equal to `wRoamMons_LastMapGroup`/`wRoamMons_LastMapNumber`, which is the map
  the player was on *before* the one they are on now. That last check is what
  stops a beast shadowing a player who paces one boundary.

Because the jump test and the index share one byte, they are not independent
rolls.

**When `UpdateRoamMons` runs** (`data/maps/setup_scripts.asm`)

| map setup script | contains `UpdateRoamMons`? | reached by |
|---|---|---|
| `MapSetupScript_Connection` | yes (line 93) | walking across a map connection, `engine/overworld/events.asm:1013 reloadend MAPSETUP_CONNECTION` |
| `MapSetupScript_Train` | yes (line 121) | magnet train, and everything that falls into it |
| `MapSetupScript_Door` | yes, by falling through into `_Train` | normal door/stair warps, `engine/overworld/events.asm:993`; Dig / Escape Rope, `engine/events/overworld.asm:836` |
| `MapSetupScript_Fall` | yes, by falling through `_Door` into `_Train` | hole falls |
| `MapSetupScript_Warp` | **no** | `warp` script opcode (`engine/overworld/scripting.asm:1958`), whiteout (`engine/events/whiteout.asm:21`), new game |
| `MapSetupScript_ReloadMap` | no | `reloadmap` |
| `MapSetupScript_Teleport` | no, runs `JumpRoamMons` instead (line 29) | Fly (`engine/events/overworld.asm:604`), Teleport (`:921`) |

So the walkthrough's "they change route when you change route or enter/exit a
city, cave, or building" is exactly right: connections and door warps both
update. A scripted `warp` does not.

**Scattering: `JumpRoamMons`** (`:677`, `0a:68e0`) / `JumpRoamMon` (`:710`,
`0a:6919`). Picks a uniformly random `RoamMaps` entry, re-rolling only while it
lands on the player's own current map. Two callers:

- `MapSetupScript_Teleport` (Fly / Teleport). This is the walkthrough's "Flying
  will reset the roaming legendary's location".
- `engine/menus/intro_menu.asm:283`, `farcall JumpRoamMons`, on **Continue**.
  Loading a save scatters all three.

**Meeting one: `CheckEncounterRoamMon`** (`:531`, `0a:681a`), called from the
very top of `ChooseWildEncounter` (`0a:66ab`), which itself is called from
`TryWildEncounter` (`0a:6643`) *after* the map's encounter-rate roll has already
passed. Order of gates:

1. `CheckOnWater` -> on water, no roamer. (Suicune cannot be met while surfing.)
2. One random byte, `cp 100` -> 100/256 pass.
3. `and %00000011`, `jr z` -> 3/4 of those pass. Running total 75/256, about
   29.3%, which the asm comments itself.
4. `dec a` -> slot 0, 1 or 2, evenly.
5. That one slot's stored map group/number must equal the player's. There is
   **no re-roll onto another beast**, so two beasts on your route still get one
   roll each.
6. On success: `wTempWildMonSpecies` = the beast, `wCurPartyLevel` = 40,
   `wBattleType` = `BATTLETYPE_ROAMING`, and `ChooseWildEncounter` returns carry
   straight to `.startwildbattle`, skipping the map's own slot table entirely. A
   roamer *replaces* the normal encounter.

**Sweet Scent is a separate, better door.** `engine/events/sweet_scent.asm:31`
`SweetScentEncounter` runs `CanEncounterWildMon`, then only checks that
`GetMapEncounterRate` is **nonzero** (`ld a, b / and a / jr z`), then calls
`ChooseWildEncounter` directly. It never performs the percentage roll and never
reaches `CheckRepelEffect`. So every Sweet Scent use in grass on a roam route is
a guaranteed encounter with a flat ~9.8% chance (1/3 of 75/256) of being the
specific beast standing there. The walkthrough does not mention this.

**Battle behaviour** (`engine/battle/core.asm`)

- DVs, `:5832`-`:5870`: if the struct's HP byte is nonzero the stored DVs are
  reused, otherwise fresh DVs are rolled and written back. A beast you chase all
  game is one individual.
- HP, `:6068`-`:6090`: same test. Zero takes `.InitRoamHP`, which writes the
  mon's full HP into the struct on the *first* encounter. Non-zero loads the
  stored value into `wEnemyMonHP + 1`. This is the walkthrough's "once you've
  weakened a legendary once, it will remain at that HP". The comment notes only
  the low byte is stored because Raikou and Entei are under 256 HP at level 40.
- `TryEnemyFlee` (`:711`, `0f:44fa`), called at the head of the enemy's half of
  the turn in both orders (`Battle_EnemyFirst:823`, `Battle_PlayerFirst:885`).
  It bails (beast stays) only if: trainer battle, `SUBSTATUS_CANT_RUN` on the
  player (Mean Look / Spider Web), a live `wEnemyWrapCount`, or the enemy is
  `FRZ` or asleep. Otherwise `AlwaysFleeMons` (`data/wild/flee_mons.asm`,
  `0f:4568`) is exactly `RAIKOU, ENTEI, SUICUNE` and it flees with no roll at
  all. This is "the roaming legendaries will all run after one attack or one
  ball throw": a failed ball sets `wBattlePlayerAction = BATTLEPLAYERACTION_USEITEM`,
  `DetermineMoveOrder` sends it to `.player_first`, and `Battle_PlayerFirst`
  still reaches `call TryEnemyFlee`.
  Note **paralysis does not stop the flee**; only sleep and freeze do.
- `BattleEnd_HandleRoamMons` (`:8237`, `0f:76ac`): on `WIN` (which covers a
  catch) it zeroes HP, sets the map pair to `GROUP_N_A` / `MAP_N_A` and zeroes
  the species, retiring the slot. On anything else it banks `wEnemyMonHP + 1`
  into the struct and calls `UpdateRoamMons`. Its `.not_roaming` tail is the
  other half: after **any** other wild battle, `BattleRandom and $f` gives a
  1-in-16 chance the beasts move anyway.

**Tracking: `FindNest`** (`engine/overworld/wildmons.asm:28`, `0a:6560`). Its
`.RoamMon1/.RoamMon2/.RoamMon3` tails append the roamer's current map to the
nest list whenever `wNamedObjectIndex` matches the slot's species, and only for
the Johto pass (`ld a, e / and a / jr nz, .kanto` returns before them). The one
caller is `engine/pokegear/pokegear.asm:2430`, inside `Pokedex_GetArea`
(`24:5c7f`), i.e. the **Pokedex AREA screen**, which is drawn with the Pokegear
town-map engine and headed `<MON>'S NEST`. See section 6 for the wording
mismatch with the walkthrough.

**Catch rate** (`engine/items/item_effects.asm`, `PokeBallEffect` `03:6926`)

- All three beasts have `db 3 ; catch rate`
  (`data/pokemon/base_stats/raikou.asm`, `entei.asm`, `suicune.asm`).
- `MASTER_BALL` short-circuits to `.catch_without_fail` before any multiplier.
- `UltraBallMultiplier` (`03:6c92`) is `sla b`, a flat x2 -> effective 6.
- `FastBallMultiplier` (`03:6dbc`) carries a documented bug: it is *intended* to
  x4 anything in the three `FleeMons` tables, but the `jr nz, .next` where the
  author meant `jr nz, .loop` limits it to the **first three entries of
  `SometimesFleeMons`** (Magnemite, Grimer, Tangela). Fast Balls are worthless
  on the beasts in Gold/Silver.
- Status: the `.statuscheck` block is also buggy. `+10` for `FRZ`/`SLP` works;
  the `BRN`/`PSN`/`PAR` `+5` branch is unreachable because the `ld a,
  [wEnemyMonStatus]` reload is commented out. **Paralysis gives no catch bonus
  at all**, which contradicts the walkthrough's "asleep or paralyzed".

---

### Roam map set (the other twelve)

These twelve maps carry no roamer-specific script or object; they matter only as
graph nodes and as places to stand in grass. Header rows are from
`data/maps/maps.asm`, dimensions from `constants/map_constants.asm`.

| Map constant | asm file | group | W x H (blocks) | tileset / environment / music | header line |
|---|---|---|---|---|---|
| `MAP_ROUTE_29` | `maps/Route29.asm` | `NEW_BARK` | 30 x 9 | `TILESET_JOHTO` / `ROUTE` / `MUSIC_ROUTE_29` | `data/maps/maps.asm:474` |
| `MAP_ROUTE_30` | `maps/Route30.asm` | `CHERRYGROVE` | 10 x 27 | `TILESET_JOHTO` / `ROUTE` / `MUSIC_ROUTE_30` | `:508` |
| `MAP_ROUTE_31` | `maps/Route31.asm` | `CHERRYGROVE` | 20 x 9 | `TILESET_JOHTO` / `ROUTE` / `MUSIC_ROUTE_30` | `:509` |
| `MAP_ROUTE_32` | `maps/Route32.asm` | `VIOLET` | 10 x 45 | `TILESET_JOHTO` / `ROUTE` / `MUSIC_ROUTE_30` | `:247` |
| `MAP_ROUTE_33` | `maps/Route33.asm` | `AZALEA` | 10 x 9 | `TILESET_JOHTO_MODERN` / `ROUTE` / `MUSIC_ROUTE_30` | `:231` |
| `MAP_ROUTE_34` | `maps/Route34.asm` | `GOLDENROD` | 10 x 27 | `TILESET_JOHTO_MODERN` / `ROUTE` / `MUSIC_ROUTE_36` | `:268` |
| `MAP_ROUTE_38` | `maps/Route38.asm` | `OLIVINE` | 20 x 9 | `TILESET_JOHTO` / `ROUTE` / `MUSIC_ROUTE_37` | `:61` |
| `MAP_ROUTE_39` | `maps/Route39.asm` | `OLIVINE` | 10 x 18 | `TILESET_JOHTO` / `ROUTE` / `MUSIC_ROUTE_37` | `:62` |
| `MAP_ROUTE_43` | `maps/Route43.asm` | `LAKE_OF_RAGE` | 10 x 27 | `TILESET_JOHTO` / `ROUTE` / `MUSIC_LAKE_OF_RAGE` | `:241` |
| `MAP_ROUTE_44` | `maps/Route44.asm` | `MAHOGANY` | 30 x 9 | `TILESET_JOHTO` / `ROUTE` / `MUSIC_LAKE_OF_RAGE` | `:73` |
| `MAP_ROUTE_45` | `maps/Route45.asm` | `BLACKTHORN` | 10 x 45 | `TILESET_JOHTO` / `ROUTE` / `MUSIC_ROUTE_36` | `:185` |
| `MAP_ROUTE_46` | `maps/Route46.asm` | `BLACKTHORN` | 10 x 18 | `TILESET_JOHTO` / `ROUTE` / `MUSIC_ROUTE_36` | `:186` |

Excluded on purpose, and confirmed absent from `RoamMaps`:
`MAP_ROUTE_40` (`maps/Route40.asm`, `CIANWOOD`, 10 x 18,
`data/maps/maps.asm:442`) and `MAP_ROUTE_41` (`maps/Route41.asm`, `CIANWOOD`,
25 x 27, `:443`).

---

### MAP_VIOLET_CITY

- Script: `maps/VioletCity.asm`
- Header: `data/maps/maps.asm:251` -> `TILESET_JOHTO`, `TOWN`,
  `LANDMARK_VIOLET_CITY`, `MUSIC_VIOLET_CITY`, phone `FALSE`, `PALETTE_AUTO`,
  `FISHGROUP_POND`
- Dimensions: `constants/map_constants.asm:230`, `map_const VIOLET_CITY, 20, 18`
- Connections (`data/maps/attributes.asm:127`): south `Route32` (`ROUTE_32`, 0),
  **west `Route36` (`ROUTE_36`, 0)**, east `Route31` (`ROUTE_31`, 9)

Included only because it is the walkthrough's Fly anchor and the one city with a
direct edge onto a roam route. It is not itself a roam map, so arriving here
never gives a beast encounter; it only ticks `UpdateRoamMons` on the way in and
out.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 17 | `VIOLET_MART` | 2 |
| 2 | 18 | 17 | `VIOLET_GYM` | 1 |
| 3 | 30 | 17 | `EARLS_POKEMON_ACADEMY` | 1 |
| 4 | 3 | 15 | `VIOLET_NICKNAME_SPEECH_HOUSE` | 1 |
| 5 | 31 | 25 | `VIOLET_POKECENTER_1F` | 1 |
| 6 | 21 | 29 | `VIOLET_KYLES_HOUSE` | 1 |
| 7 | 23 | 5 | `SPROUT_TOWER_1F` | 1 |
| 8 | 39 | 24 | `ROUTE_31_VIOLET_GATE` | 1 |
| 9 | 39 | 25 | `ROUTE_31_VIOLET_GATE` | 2 |

Every one of these nine is a door warp, i.e. `MAPSETUP_DOOR`, i.e. one
`UpdateRoamMons` in and one on the way out. Stepping in and out of the Pokecenter
is a legal, very short roam tick.

**Coord events** (`def_coord_events`): none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 24 | 20 | `BGEVENT_READ` | `VioletCitySign` |
| 15 | 17 | `BGEVENT_READ` | `VioletGymSign` |
| 24 | 8 | `BGEVENT_READ` | `SproutTowerSign` |
| 27 | 17 | `BGEVENT_READ` | `EarlsPokemonAcademySign` |
| 32 | 25 | `BGEVENT_READ` | `VioletCityPokecenterSign` |
| 10 | 17 | `BGEVENT_READ` | `VioletCityMartSign` |
| 37 | 14 | `BGEVENT_ITEM` | `VioletCityHiddenHyperPotion` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| (1) | `SPRITE_FISHER` | 13 | 16 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `VioletCityEarlScript` | `EVENT_VIOLET_CITY_EARL` |
| (2) | `SPRITE_LASS` | 28 | 28 | `WANDER` | `OBJECTTYPE_SCRIPT` | `VioletCityLassScript` | -1 |
| (3) | `SPRITE_SUPER_NERD` | 24 | 14 | `WANDER` | `OBJECTTYPE_SCRIPT` | `VioletCitySuperNerdScript` | -1 |
| (4) | `SPRITE_GRAMPS` | 17 | 20 | `WALK_LEFT_RIGHT` | `OBJECTTYPE_SCRIPT` | `VioletCityGrampsScript` | -1 |
| (5) | `SPRITE_YOUNGSTER` | 5 | 18 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `VioletCityYoungsterScript` | -1 |
| (6) | `SPRITE_FRUIT_TREE` | 14 | 29 | `STILL` | `OBJECTTYPE_SCRIPT` | `VioletCityFruitTree` | -1 |
| (7) | `SPRITE_POKE_BALL` | 4 | 1 | `STILL` | `OBJECTTYPE_ITEMBALL` | `VioletCityPPUp` | `EVENT_VIOLET_CITY_PP_UP` |
| (8) | `SPRITE_POKE_BALL` | 35 | 5 | `STILL` | `OBJECTTYPE_ITEMBALL` | `VioletCityRareCandy` | `EVENT_VIOLET_CITY_RARE_CANDY` |

**Wild encounters**: none relevant (town, no grass on the walked path).

---

### MAP_ROUTE_36

- Script: `maps/Route36.asm`
- Header: `data/maps/maps.asm:249` -> `TILESET_JOHTO`, `ROUTE`,
  `LANDMARK_ROUTE_36`, `MUSIC_ROUTE_36`, phone `FALSE`, `PALETTE_AUTO`,
  `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:228`, `map_const ROUTE_36, 30, 9`
- Connections (`data/maps/attributes.asm:206`): north `Route37` (`ROUTE_37`, 10),
  south `Route35` (`ROUTE_35`, 0), east `VioletCity` (`VIOLET_CITY`, 0)
- Roam edges (`RoamMaps`): `ROUTE_35`, `ROUTE_31`, `ROUTE_32`, `ROUTE_37`. One
  of the two four-way junctions, so a beast standing here has the widest spread.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 18 | 8 | `ROUTE_36_NATIONAL_PARK_GATE` | 3 |
| 2 | 18 | 9 | `ROUTE_36_NATIONAL_PARK_GATE` | 4 |
| 3 | 47 | 13 | `ROUTE_36_RUINS_OF_ALPH_GATE` | 1 |
| 4 | 48 | 13 | `ROUTE_36_RUINS_OF_ALPH_GATE` | 2 |

**Coord events** (`def_coord_events`): none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 29 | 1 | `BGEVENT_READ` | `Route36TrainerTips2` |
| 45 | 11 | `BGEVENT_READ` | `RuinsOfAlphNorthSign` |
| 55 | 7 | `BGEVENT_READ` | `Route36Sign` |
| 21 | 7 | `BGEVENT_READ` | `Route36TrainerTips1` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE36_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 20 | 12 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER` (sight 2) | `TrainerPsychicMark` | -1 |
| `ROUTE36_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 31 | 14 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` (sight 5) | `TrainerSchoolboyAlan1` | -1 |
| `ROUTE36_WEIRD_TREE` | `SPRITE_WEIRD_TREE` | 35 | 9 | `SUDOWOODO` | `OBJECTTYPE_SCRIPT` | `SudowoodoScript` | `EVENT_ROUTE_36_SUDOWOODO` |
| `ROUTE36_LASS1` | `SPRITE_LASS` | 51 | 8 | `WALK_LEFT_RIGHT` | `OBJECTTYPE_SCRIPT` | `Route36LassScript` | -1 |
| `ROUTE36_FISHER` | `SPRITE_FISHER` | 44 | 9 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `Route36RockSmashGuyScript` | -1 |
| `ROUTE36_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 21 | 4 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route36FruitTree` (`FRUITTREE_ROUTE_36`) | -1 |
| `ROUTE36_ARTHUR` | `SPRITE_YOUNGSTER` | 46 | 6 | `WANDER` | `OBJECTTYPE_SCRIPT` | `ArthurScript` | `EVENT_ROUTE_36_ARTHUR_OF_THURSDAY` |

**Scripts of interest**

- `Route36ArthurCallback` (`MAPCALLBACK_OBJECTS`): `readvar VAR_WEEKDAY`,
  `ifequal THURSDAY` -> `appear ROUTE36_ARTHUR`, else `disappear`. Irrelevant to
  the beasts but it is the map's only callback, so a bot that emulates map
  callbacks must run it.
- `SudowoodoScript`: the one thing on this map that can physically block the
  Route 36 loop. `checkitem SQUIRTBOTTLE`; without it the tree just shakes and
  the tile stays solid. With it: `loadwildmon SUDOWOODO, 20`, `startbattle`,
  `setevent EVENT_FOUGHT_SUDOWOODO`, then `disappear ROUTE36_WEIRD_TREE` on
  either branch (`DidntCatchSudowoodo` also disappears it). Once
  `EVENT_ROUTE_36_SUDOWOODO` is cleared the tile is free for good.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ROUTE_36_SUDOWOODO` | `constants/event_flags.asm:1178` | `object_event` visibility; cleared by `disappear` in `SudowoodoScript` | while set, x=35,y=9 is impassable |
| `EVENT_FOUGHT_SUDOWOODO` | `constants/event_flags.asm` | set in `WateredWeirdTreeScript` | gates the Rock Smash gift and the lass's line |
| `EVENT_ROUTE_36_ARTHUR_OF_THURSDAY` | `constants/event_flags.asm` | `Route36ArthurCallback` | day-of-week NPC |

**Wild encounters** (`data/wild/johto_grass.asm`, `def_grass_wildmons ROUTE_36`,
rates `10 percent` morn/day/nite, Gold column)

| slot | morn | day | nite |
|---|---|---|---|
| 1 | 12 `NIDORAN_M` | 12 `NIDORAN_M` | 12 `NIDORAN_M` |
| 2 | 12 `NIDORAN_F` | 12 `NIDORAN_F` | 12 `NIDORAN_F` |
| 3 | 13 `PIDGEY` | 14 `PIDGEY` | 13 `HOOTHOOT` |
| 4 | 13 `GROWLITHE` | 13 `GROWLITHE` | 13 `GROWLITHE` |
| 5 | 13 `STANTLER` | 13 `STANTLER` | 13 `STANTLER` |
| 6 | 15 `PIDGEY` | 15 `GROWLITHE` | 15 `HOOTHOOT` |
| 7 | 15 `PIDGEY` | 15 `GROWLITHE` | 15 `HOOTHOOT` |

(Silver swaps `GROWLITHE` for `VULPIX` and reverses the Nidoran pair.) Max wild
level 15, which matters for the Max Repel plan in section 3.

---

### MAP_ROUTE_35

- Script: `maps/Route35.asm`
- Header: `data/maps/maps.asm:248` -> `TILESET_JOHTO`, `ROUTE`,
  `LANDMARK_ROUTE_35`, `MUSIC_ROUTE_36`, phone `FALSE`, `PALETTE_AUTO`,
  `FISHGROUP_POND`
- Dimensions: `constants/map_constants.asm:227`, `map_const ROUTE_35, 10, 18`
- Connections (`data/maps/attributes.asm:202`): north `Route36` (`ROUTE_36`, 0),
  south `GoldenrodCity` (`GOLDENROD_CITY`, -5)
- Roam edges: `ROUTE_34`, `ROUTE_35` -> `ROUTE_34`, `ROUTE_36`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 33 | `ROUTE_35_GOLDENROD_GATE` | 1 |
| 2 | 10 | 33 | `ROUTE_35_GOLDENROD_GATE` | 2 |
| 3 | 3 | 5 | `ROUTE_35_NATIONAL_PARK_GATE` | 3 |

**Coord events** (`def_coord_events`): none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 1 | 7 | `BGEVENT_READ` | `Route35Sign` |
| 11 | 31 | `BGEVENT_READ` | `Route35Sign` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| (1) | `SPRITE_YOUNGSTER` | 3 | 19 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER` (4) | `TrainerCamperIvan` | -1 |
| (2) | `SPRITE_YOUNGSTER` | 8 | 20 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (3) | `TrainerCamperElliot` | -1 |
| (3) | `SPRITE_LASS` | 7 | 20 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (3) | `TrainerPicnickerBrooke` | -1 |
| (4) | `SPRITE_LASS` | 11 | 24 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` (3) | `TrainerPicnickerKim` | -1 |
| (5) | `SPRITE_YOUNGSTER` | 14 | 28 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (0) | `TrainerBirdKeeperBryan` | -1 |
| (6) | `SPRITE_FISHER` | 2 | 10 | `SPINCOUNTERCLOCKWISE` | `OBJECTTYPE_TRAINER` (2) | `TrainerFirebreatherWalt` | -1 |
| (7) | `SPRITE_BUG_CATCHER` | 16 | 7 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (3) | `TrainerBugCatcherArnie` | -1 |
| (8) | `SPRITE_SUPER_NERD` | 5 | 10 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (2) | `TrainerJugglerIrwin` | -1 |
| (9) | `SPRITE_OFFICER` | 5 | 6 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `TrainerOfficerDirk` | -1 |
| (10) | `SPRITE_FRUIT_TREE` | 2 | 25 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route35FruitTree` (`FRUITTREE_ROUTE_35`) | -1 |
| (11) | `SPRITE_POKE_BALL` | 13 | 16 | `STILL` | `OBJECTTYPE_ITEMBALL` | `Route35TMRollout` (`TM_ROLLOUT`) | `EVENT_ROUTE_35_TM_ROLLOUT` |

**Scripts of interest**

- `TrainerOfficerDirk` (`maps/Route35.asm:223`): an `OBJECTTYPE_SCRIPT`, not a
  sight trainer. `checktime NITE` -> only battles at night, guarded by
  `EVENT_BEAT_OFFICER_DIRK`, `loadtrainer OFFICER, DIRK`. A bot oscillating
  Route 35 / Route 36 at night will be pulled into this battle once. Note that
  a normal wild-or-trainer battle is *not* wasted time: `BattleEnd_HandleRoamMons`'s
  `.not_roaming` tail moves the beasts 1 time in 16.

**Wild encounters** (`data/wild/johto_grass.asm`, `def_grass_wildmons ROUTE_35`,
rates `10 percent` all three, Gold column)

| slot | morn | day | nite |
|---|---|---|---|
| 1 | 12 `NIDORAN_M` | 12 `NIDORAN_M` | 12 `NIDORAN_M` |
| 2 | 12 `NIDORAN_F` | 12 `NIDORAN_F` | 12 `NIDORAN_F` |
| 3 | 14 `DROWZEE` | 14 `DROWZEE` | 14 `DROWZEE` |
| 4 | 10 `ABRA` | 10 `ABRA` | 10 `ABRA` |
| 5 | 14 `PIDGEY` | 14 `PIDGEY` | 14 `HOOTHOOT` |
| 6 | 10 `DITTO` | 10 `DITTO` | 10 `DITTO` |
| 7 | 12 `YANMA` | 12 `YANMA` | 12 `YANMA` |

Max wild level 14.

---

### MAP_ROUTE_37

- Script: `maps/Route37.asm`
- Header: `data/maps/maps.asm:250` -> `TILESET_JOHTO`, `ROUTE`,
  `LANDMARK_ROUTE_37`, `MUSIC_ROUTE_36`, phone `FALSE`, `PALETTE_AUTO`,
  `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:229`, `map_const ROUTE_37, 10, 9`
- Connections (`data/maps/attributes.asm:211`): north `EcruteakCity`
  (`ECRUTEAK_CITY`, -5), south `Route36` (`ROUTE_36`, -10)
- Roam edges: `ROUTE_36`, `ROUTE_38`, `ROUTE_42`. Entei's starting map.

**Warps** (`def_warp_events`): **none**. Route 37 is reached only by connection,
which makes it the cheapest possible `UpdateRoamMons` tick in the loop: one step
across the boundary and one step back.

**Coord events** (`def_coord_events`): none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 5 | 3 | `BGEVENT_READ` | `Route37Sign` |
| 4 | 2 | `BGEVENT_ITEM` | `Route37HiddenEther` (`hiddenitem ETHER, EVENT_ROUTE_37_HIDDEN_ETHER`) |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE37_WEIRD_TREE1` | `SPRITE_WEIRD_TREE` | 6 | 12 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (1) | `TrainerTwinsAnnandanne1` | -1 |
| `ROUTE37_WEIRD_TREE2` | `SPRITE_WEIRD_TREE` | 7 | 12 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (1) | `TrainerTwinsAnnandanne2` | -1 |
| `ROUTE37_YOUNGSTER` | `SPRITE_YOUNGSTER` | 9 | 6 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` (3) | `TrainerPsychicGreg` | -1 |
| `ROUTE37_FRUIT_TREE1` | `SPRITE_FRUIT_TREE` | 13 | 5 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route37FruitTree1` (`FRUITTREE_ROUTE_37_1`) | -1 |
| `ROUTE37_SUNNY` | `SPRITE_BUG_CATCHER` | 16 | 8 | `WANDER` | `OBJECTTYPE_SCRIPT` | `SunnyScript` | `EVENT_ROUTE_37_SUNNY_OF_SUNDAY` |
| `ROUTE37_FRUIT_TREE2` | `SPRITE_FRUIT_TREE` | 16 | 5 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route37FruitTree2` (`FRUITTREE_ROUTE_37_2`) | -1 |
| `ROUTE37_FRUIT_TREE3` | `SPRITE_FRUIT_TREE` | 15 | 7 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route37FruitTree3` (`FRUITTREE_ROUTE_37_3`) | -1 |

**Scripts of interest**

- `Route37SunnyCallback` (`MAPCALLBACK_OBJECTS`): `readvar VAR_WEEKDAY`,
  `ifequal SUNDAY` -> `appear ROUTE37_SUNNY`, else `disappear`.
- `SunnyScript`: `verbosegiveitem MAGNET` guarded by
  `EVENT_GOT_MAGNET_FROM_SUNNY` and `EVENT_MET_SUNNY_OF_SUNDAY`.

**Wild encounters** (`data/wild/johto_grass.asm`, `def_grass_wildmons ROUTE_37`,
rates `10 percent` all three, Gold column)

| slot | morn | day | nite |
|---|---|---|---|
| 1 | 13 `PIDGEY` | 13 `PIDGEY` | 13 `SPINARAK` |
| 2 | 15 `STANTLER` | 15 `STANTLER` | 15 `STANTLER` |
| 3 | 15 `PIDGEY` | 15 `PIDGEY` | 15 `HOOTHOOT` |
| 4 | 14 `GROWLITHE` | 14 `GROWLITHE` | 14 `GROWLITHE` |
| 5 | 15 `PIDGEY` | 15 `PIDGEOTTO` | 15 `SPINARAK` |
| 6 | 15 `PIDGEY` | 16 `GROWLITHE` | 15 `SPINARAK` |
| 7 | 15 `PIDGEY` | 16 `GROWLITHE` | 15 `SPINARAK` |

Max wild level 16.

---

### MAP_ROUTE_42

- Script: `maps/Route42.asm`
- Header: `data/maps/maps.asm:72` -> `TILESET_JOHTO`, `ROUTE`,
  `LANDMARK_ROUTE_42`, `MUSIC_LAKE_OF_RAGE`, phone `FALSE`, `PALETTE_AUTO`,
  `FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:60`, `map_const ROUTE_42, 30, 9`
- Connections (`data/maps/attributes.asm:231`): west `EcruteakCity`
  (`ECRUTEAK_CITY`, -9), east `MahoganyTown` (`MAHOGANY_TOWN`, 0)
- Roam edges: `ROUTE_43`, `ROUTE_44`, `ROUTE_37`, `ROUTE_38`. The other four-way
  junction, and Raikou's starting map. This is the walkthrough's Max Repel spot.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 8 | `ROUTE_42_ECRUTEAK_GATE` | 3 |
| 2 | 0 | 9 | `ROUTE_42_ECRUTEAK_GATE` | 4 |
| 3 | 10 | 5 | `MOUNT_MORTAR_1F_OUTSIDE` | 1 |
| 4 | 28 | 9 | `MOUNT_MORTAR_1F_OUTSIDE` | 2 |
| 5 | 46 | 7 | `MOUNT_MORTAR_1F_OUTSIDE` | 3 |

**Coord events** (`def_coord_events`): none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 4 | 10 | `BGEVENT_READ` | `Route42Sign1` |
| 7 | 5 | `BGEVENT_READ` | `MtMortarSign1` |
| 45 | 9 | `BGEVENT_READ` | `MtMortarSign2` |
| 54 | 8 | `BGEVENT_READ` | `Route42Sign2` |
| 16 | 11 | `BGEVENT_ITEM` | `Route42HiddenMaxPotion` (`hiddenitem MAX_POTION, EVENT_ROUTE_42_HIDDEN_MAX_POTION`) |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| (1) | `SPRITE_FISHER` | 40 | 10 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` (1) | `TrainerFisherChris` | -1 |
| (2) | `SPRITE_POKEFAN_M` | 51 | 9 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (3) | `TrainerHikerBenjamin` | -1 |
| (3) | `SPRITE_SUPER_NERD` | 47 | 8 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` (3) | `TrainerPokemaniacShane` | -1 |
| (4) | `SPRITE_FRUIT_TREE` | 27 | 16 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route42FruitTree1` (`FRUITTREE_ROUTE_42_1`) | -1 |
| (5) | `SPRITE_FRUIT_TREE` | 28 | 16 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route42FruitTree2` (`FRUITTREE_ROUTE_42_2`) | -1 |
| (6) | `SPRITE_FRUIT_TREE` | 29 | 16 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route42FruitTree3` (`FRUITTREE_ROUTE_42_3`) | -1 |
| (7) | `SPRITE_POKE_BALL` | 6 | 4 | `STILL` | `OBJECTTYPE_ITEMBALL` | `Route42UltraBall` (`itemball ULTRA_BALL`) | `EVENT_ROUTE_42_ULTRA_BALL` |
| (8) | `SPRITE_POKE_BALL` | 33 | 8 | `STILL` | `OBJECTTYPE_ITEMBALL` | `Route42SuperPotion` (`itemball SUPER_POTION`) | `EVENT_ROUTE_42_SUPER_POTION` |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `ULTRA_BALL` | item ball at x=6, y=4 | `Route42UltraBall` | `EVENT_ROUTE_42_ULTRA_BALL` |
| `SUPER_POTION` | item ball at x=33, y=8 | `Route42SuperPotion` | `EVENT_ROUTE_42_SUPER_POTION` |
| `MAX_POTION` | hidden, x=16, y=11 | `Route42HiddenMaxPotion` | `EVENT_ROUTE_42_HIDDEN_MAX_POTION` |

**Wild encounters** (`data/wild/johto_grass.asm`, `def_grass_wildmons ROUTE_42`,
rates `10 percent` all three, Gold column)

| slot | morn | day | nite |
|---|---|---|---|
| 1 | 15 `MANKEY` | 15 `MANKEY` | 15 `MANKEY` |
| 2 | 13 `MAREEP` | 13 `MAREEP` | 13 `MAREEP` |
| 3 | 14 `SPEAROW` | 14 `SPEAROW` | 14 `ZUBAT` |
| 4 | 16 `SPEAROW` | 16 `SPEAROW` | 16 `ZUBAT` |
| 5 | 15 `FLAAFFY` | 15 `FLAAFFY` | 15 `FLAAFFY` |
| 6 | 17 `FLAAFFY` | 17 `FLAAFFY` | 17 `FLAAFFY` |
| 7 | 17 `FLAAFFY` | 17 `FLAAFFY` | 17 `FLAAFFY` |

Max wild level 17. Every grass slot on this map is below 39, which is precisely
why the walkthrough's Max Repel plan works here (section 3).

---

### Trainers on the four detailed maps

Constants from `constants/trainer_constants.asm`, parties from
`data/trainers/parties.asm` (group and index in the file's own comment).

| const | class | id | party (`data/trainers/parties.asm`) | script label | map |
|---|---|---|---|---|---|
| `MARK` | `PSYCHIC_T` | `PSYCHIC_T (7)` | 13 `ABRA` (Teleport, Flash), 13 `ABRA` (Teleport, Flash), 15 `KADABRA` (Teleport, Kinesis, Confusion) | `TrainerPsychicMark` | Route 36 |
| `ALAN1` | `SCHOOLBOY` | `SCHOOLBOY (3)` | 16 `TANGELA` | `TrainerSchoolboyAlan1` | Route 36 |
| `IVAN` | `CAMPER` | `CAMPER (3)` | 10 `DIGLETT`, 10 `ZUBAT`, 14 `DIGLETT` | `TrainerCamperIvan` | Route 35 |
| `ELLIOT` | `CAMPER` | `CAMPER (4)` | 13 `SANDSHREW`, 15 `MARILL` | `TrainerCamperElliot` | Route 35 |
| `BROOKE` | `PICNICKER` | `PICNICKER (3)` | 16 `PIKACHU` (ThunderShock, Growl, Quick Attack, Double Team) | `TrainerPicnickerBrooke` | Route 35 |
| `KIM` | `PICNICKER` | `PICNICKER (4)` | 15 `VULPIX` | `TrainerPicnickerKim` | Route 35 |
| `BRYAN` | `BIRD_KEEPER` | `BIRD_KEEPER (3)` | 12 `PIDGEY`, 14 `PIDGEOTTO` | `TrainerBirdKeeperBryan` | Route 35 |
| `WALT` | `FIREBREATHER` | `FIREBREATHER (6)` | 11 `MAGMAR`, 13 `MAGMAR` | `TrainerFirebreatherWalt` | Route 35 |
| `ARNIE1` | `BUG_CATCHER` | `BUG_CATCHER (8)` | 15 `VENONAT` | `TrainerBugCatcherArnie` | Route 35 |
| `IRWIN1` | `JUGGLER` | `JUGGLER (1)` | 2 / 6 / 10 / 14 `VOLTORB` | `TrainerJugglerIrwin` | Route 35 |
| `DIRK` | `OFFICER` | (see `OfficerGroup`) | night only | `TrainerOfficerDirk` | Route 35 |
| `ANNANDANNE1` | `TWINS` | `TWINS (2)` | 16 `CLEFAIRY` (Growl, Encore, DoubleSlap, Metronome), 16 `JIGGLYPUFF` (Sing, Defense Curl, Pound, Disable) | `TrainerTwinsAnnandanne1` | Route 37 |
| `ANNANDANNE2` | `TWINS` | `TWINS (3)` | same two, order swapped | `TrainerTwinsAnnandanne2` | Route 37 |
| `GREG` | `PSYCHIC_T` | `PSYCHIC_T (5)` | 17 `DROWZEE` (Hypnosis, Disable, Dream Eater) | `TrainerPsychicGreg` | Route 37 |
| `CHRIS1` | `FISHER` | `FISHER (7)` | 18 `QWILFISH` | `TrainerFisherChris` | Route 42 |
| `BENJAMIN` | `HIKER` | `HIKER (6)` | 14 `DIGLETT`, 14 `GEODUDE`, 16 `DUGTRIO` | `TrainerHikerBenjamin` | Route 42 |
| `SHANE` | `POKEMANIAC` | `POKEMANIAC (4)` | 16 `NIDORINA`, 16 `NIDORINO` | `TrainerPokemaniacShane` | Route 42 |

All of these are one-and-done (`EVENT_BEAT_*` in the `trainer` macro row). By
this point in the game they are already beaten and are not obstacles.

---

### The beasts as battle opponents

`data/pokemon/base_stats/{raikou,entei,suicune}.asm`, level from
`InitRoamMons`, moves from `data/pokemon/evos_attacks.asm` (last four learned at
or before 40).

| species | types | base HP/Atk/Def/Spe/SpA/SpD | catch rate | level 40 moveset |
|---|---|---|---|---|
| `RAIKOU` | Electric | 90 / 85 / 75 / 115 / 115 / 100 | 3 | `LEER`, `THUNDERSHOCK`, `ROAR`, `QUICK_ATTACK` |
| `ENTEI` | Fire | 115 / 115 / 85 / 100 / 90 / 75 | 3 | `LEER`, `EMBER`, `ROAR`, `FIRE_SPIN` |
| `SUICUNE` | Water | 100 / 75 / 115 / 85 / 90 / 115 | 3 | `LEER`, `WATER_GUN`, `ROAR`, `GUST` |

All three know **Roar**. `BattleCommand_ForceSwitch`'s wild-target branch
(`engine/battle/effect_commands.asm:4913`, `.force_player_switch` at `:5010`
-> `.wild_succeed_playeristarget` at `:5041`) compares
`wCurPartyLevel` against `wBattleMonLevel` and, when the wild level is greater
or equal, succeeds unconditionally: `wForcedSwitch` = TRUE and `wBattleResult` =
DRAW, ending the battle on the spot. Against a lead at level 40 or below that is
a guaranteed battle-ender if the beast picks Roar. The DRAW result then routes
through `BattleEnd_HandleRoamMons`'s non-WIN arm, so the beast keeps its damage
and moves.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| The beasts do not exist at all | `maps/BurnedTowerB1F.asm:65` `special InitRoamMons`, guarded by `coord_event 9, 5, SCENE_BURNEDTOWERB1F_RELEASE_THE_BEASTS, ReleaseTheBeasts` | walk the Burned Tower B1F trigger | `EVENT_RELEASED_THE_BEASTS` set, `SCENE_BURNEDTOWERB1F_NOOP` |
| No roamer on water | `engine/overworld/wildmons.asm:534` `CheckEncounterRoamMon` `call CheckOnWater / jr z, .DontEncounterRoamMon` | be on a land tile | none, this is absolute |
| No roamer off the sixteen routes | `data/wild/roammon_maps.asm` `RoamMaps` + the map compare in `CheckEncounterRoamMon:546` | stand on the beast's stored map | none |
| No roamer where there is no wild table | `engine/overworld/wildmons.asm:270` `LoadWildMonDataPointer` returning nc -> `.nowildbattle` before `CheckEncounterRoamMon` runs | map must have grass/water data | none |
| No roamer in the Bug Contest | `engine/overworld/events.asm:1194` `ChooseWildEncounter_BugContest` never calls `CheckEncounterRoamMon` | leave the contest | none |
| Route 36 tile x=35, y=9 blocked | `maps/Route36.asm` `SudowoodoScript`, `checkitem SQUIRTBOTTLE` | `SQUIRTBOTTLE` in bag, then win/lose/flee the level 20 Sudowoodo | `EVENT_ROUTE_36_SUDOWOODO` cleared by `disappear` |
| Beast escapes after one player action | `engine/battle/core.asm:711` `TryEnemyFlee` + `data/wild/flee_mons.asm` `AlwaysFleeMons` | trap it: `SUBSTATUS_CANT_RUN` (Mean Look / Spider Web), a live `wEnemyWrapCount`, or inflict `SLP` / `FRZ` | any one of those four makes `TryEnemyFlee` return no-carry |
| Repel filters the *wild*, not the beast | `engine/overworld/wildmons.asm:366` `CheckRepelEffect`: `ld a, [wCurPartyLevel] / cp [hl] / jr nc, .encounter` where `hl` is the first non-fainted party mon's level | roamer level is 40, so the lead must be **level 40 or lower** or the roamer is repelled too | Route 42 grass tops out at level 17, so a level 39 lead plus `MAX_REPEL` (250 steps, `engine/items/item_effects.asm:2058`) blocks every normal encounter and passes the beast. A level 41+ lead blocks the beast as well. |
| Fast Ball does nothing here | `engine/items/item_effects.asm:986` `FastBallMultiplier`, documented bug (`jr nz, .next` instead of `jr nz, .loop`) | use `ULTRA_BALL` (x2, `03:6c92`) or `MASTER_BALL` (short-circuit) | none, the bug is in the shipped ROM |
| Paralysis gives no catch bonus | `engine/items/item_effects.asm:344` `.statuscheck`, the `ld a, [wEnemyMonStatus]` reload is commented out | `SLP` or `FRZ` only (+10 to the rate) | none |
| Ultra Ball / Max Repel supply | `data/items/marts.asm:216 MartBlackthorn`, `:384 MartIndigoPlateau` | money | both marts stock `ULTRA_BALL` and `MAX_REPEL` |

Nothing in this section is badge- or HM-gated on its own. The HMs needed to
reach individual roam routes (Surf for Route 41's neighbours, Whirlpool, etc.)
belong to their own sections; all sixteen roam maps are walkable by the time the
beasts are loose.

---

## 4. Bot checklist

Preconditions for the whole section: `EVENT_RELEASED_THE_BEASTS` set,
`save.roamers` (port) / the three `roam_struct`s (cart) populated, `BICYCLE` in
the bag, `SQUIRTBOTTLE` already used on Route 36.

1. **Locate.** Map `MAP_*` any, action: open Pokedex -> select `RAIKOU` /
   `ENTEI` / `SUICUNE` -> AREA. Precondition: species is in the *seen* dex
   (set by the first encounter, not by the Burned Tower cutscene).
   Postcondition: the blinking nest icon is the beast's current map
   (`FindNest.RoamMon1/2/3`). If the species is retired the icon is absent.
2. **Anchor.** Fly to `MAP_VIOLET_CITY`. Warning: the Fly itself runs
   `JumpRoamMons`, so any location read from step 1 is stale afterwards. Do step
   1 *after* the Fly, not before.
3. **Oscillate (cheap ticks).** From Violet City walk west onto `MAP_ROUTE_36`
   (connection, `data/maps/attributes.asm:209`). Then repeat: step north onto
   `MAP_ROUTE_37` and back, step south onto `MAP_ROUTE_35` and back. Each single
   boundary crossing is one `MapSetupScript_Connection` and therefore one
   `UpdateRoamMons`. Route 37 has zero warps, so the boundary step is the only
   thing that happens there.
4. **Alternative tick.** Any door warp works too: on `MAP_VIOLET_CITY` step onto
   warp 5 (x=31, y=25, `VIOLET_POKECENTER_1F`) and back out. That is
   `MAPSETUP_DOOR` -> `MapSetupScript_Train` -> `UpdateRoamMons`, and it also
   heals.
5. **Fish for the encounter.** Stand in grass on the map the beast is on and
   walk. Each step that passes `CanEncounterWildMon` and the map's 10% rate roll
   then has a 75/256 roamer roll, of which 1/3 selects your beast.
   Postcondition: `wBattleType = BATTLETYPE_ROAMING`.
6. **Better: Sweet Scent.** Same tile, use `SWEET_SCENT`. It skips the 10% roll
   and the repel check entirely (`engine/events/sweet_scent.asm:31`), so every
   use is an encounter and ~9.8% of uses are the specific beast. This is the
   highest-throughput option and the walkthrough does not mention it.
7. **Repel filter (optional).** Lead a party mon of level 39 or 40 (a raised
   Scyther works; it learns `FALSE_SWIPE` at level 18 per
   `data/pokemon/evos_attacks.asm:1674`, and at 39 its auto-generated four are
   False Swipe / Agility / Wing Attack / Slash). Use `MAX_REPEL` (250 steps).
   Precondition: lead level <= 40. Postcondition: only the level 40 beast can
   still trigger.
8. **Save.** Before every encounter. Battle outcomes are irreversible: a `WIN`
   retires the slot for the rest of the file.
9. **In battle, turn 1 only.** Options, in order of value:
   - `MASTER_BALL` -> guaranteed, but there is only one and there are three
     beasts.
   - Trap first (`MEAN_LOOK` / `SPIDER_WEB`, or a wrap move), which makes
     `TryEnemyFlee` return no-carry and buys unlimited turns. This is the only
     way to legitimately chip HP and land status.
   - Otherwise: one `FALSE_SWIPE` (leaves 1 HP, banked into the struct for next
     time) **or** one `ULTRA_BALL`. Either way the beast is gone at the end of
     the turn.
   - Do not count on `Roar`: if the beast picks it against a lead of level 40 or
     lower the battle ends immediately as a DRAW.
10. **After the battle.** `BattleEnd_HandleRoamMons` has already banked HP and
    moved the beast. Return to step 1.
11. **Repeat per beast.** Three independent slots. Retiring one does not affect
    the other two; their `RoamMaps` walk is unchanged.

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| `roam_struct` on the save (species/level/map/hp/dvs, three slots in Raikou/Entei/Suicune order) | `src/core/gen2/Roamers.lua:41-47`, `:184-217` | implemented |
| `InitRoamMons` reachable through the real special dispatch | `src/script/gen2/Specials.lua:1843-1848`, `src/core/gen2/Roamers.lua:196` | implemented |
| `RoamMaps` graph, all 16 rows, Routes 40/41 excluded | `src/core/gen2/Roamers.lua:58-75` | implemented, but hardcoded: `Roamers.mapTable` looks for `encounters.roamMaps` and the extractor does not emit it yet (`:77-85`) |
| `.Update` shared-byte jump/index roll, last-map re-roll | `src/core/gen2/Roamers.lua:142-158` | implemented |
| `JumpRoamMon` random entry, re-roll off the player's map | `src/core/gen2/Roamers.lua:117-126` | implemented |
| `_BackUpMapIndices` | `src/core/gen2/Roamers.lua:223-234` | implemented |
| `UpdateRoamMons` on `CONNECTION` / `DOOR` / `FALL` / `TRAIN` | `src/world/gen2/World.lua:211-215` (`MAPSETUP_ROAM_UPDATE`), `:2626-2633` | implemented, and the set matches `data/maps/setup_scripts.asm` exactly |
| `JumpRoamMons` on `TELEPORT` (Fly / Teleport) | `src/world/gen2/World.lua:215`, `:2617-2624` | implemented |
| `JumpRoamMons` on **Continue** (`engine/menus/intro_menu.asm:283`) | - | **missing**: `Roamers.jumpAll` has exactly one caller, `roamMonsBeforeLoad`, which is keyed on `MAPSETUP_TELEPORT`. Loading a save does not scatter the beasts. |
| `CheckEncounterRoamMon` (water gate, 100/256, `and %11`, slot map compare, no re-roll) | `src/core/gen2/Roamers.lua:288-301`; called from `src/world/gen2/World.lua:3043` and `:3790` | implemented |
| Roamer check ordered **after** the map's encounter-rate roll | `src/world/gen2/World.lua:3043` vs `:3053-3060` | **partial**: the port runs `Roamers.checkEncounter` *before* `Encounter.triggers`, so a beast can appear on a step whose 10% roll would have failed. The asm order is `TryWildEncounter.EncounterRate` -> `ChooseWildEncounter` -> `CheckEncounterRoamMon`. Beast encounter rate is inflated by roughly 1/rate. |
| Sweet Scent path also consults the roamers, and skips the rate roll | `src/world/gen2/World.lua:3785-3796` | implemented, and the "nonzero rate only" check at `:3786` matches `engine/events/sweet_scent.asm:38` |
| `CheckRepelEffect` (lead level vs `wCurPartyLevel`) | - | **missing**: `save.repelSteps` counts down in `src/world/gen2/StepEvents.lua:98-101` and prints the wore-off text, but nothing in `World:tryWildEncounter` consults it. The walkthrough's Max Repel plan is a no-op in the port today. |
| DV roll on first encounter, DVs kept afterwards | `src/core/gen2/Roamers.lua:311-328` | implemented |
| HP banked in a single byte, reloaded on the next encounter | `src/core/gen2/Roamers.lua:182`, `:311-328`, `:341-354` | implemented |
| `BattleEnd_HandleRoamMons` WIN/caught retires the slot | `src/core/gen2/Roamers.lua:345-350`, wired at `src/world/gen2/World.lua:4475-4478` | implemented |
| `.not_roaming` 1-in-16 drift after any other wild battle | `src/core/gen2/Roamers.lua:359-363` | implemented |
| `AlwaysFleeMons` / `OftenFleeMons` / `SometimesFleeMons` and the shared roll byte | `src/core/gen2/Roamers.lua:370-380`, `src/battle/gen2/Battle.lua:1639-1651` | implemented |
| Sleep / freeze suppress the flee | `src/battle/gen2/Battle.lua:1641-1642` | implemented |
| `SUBSTATUS_CANT_RUN` (Mean Look) and `wEnemyWrapCount` suppress the flee | - | **missing**, and the port says so itself at `src/battle/gen2/Battle.lua:1632-1635`. There is currently no way to trap a beast, which removes the only legitimate multi-turn strategy. |
| Failed ball still costs the turn, so the beast flees | `src/ui/gen2/BattleState.lua:900-903` -> `Battle:takeTurn{kind="item"}` -> `Battle:tryEnemyFlee` (`:1877`) | implemented |
| `MASTER_BALL` never fails; `ULTRA_BALL` x2 | `src/battle/gen2/Catching.lua:29-30`, `:62-63` | implemented |
| `FastBallMultiplier` bug (x4 only for Magnemite/Grimer/Tangela) | `src/battle/gen2/Catching.lua:39` (`FAST_BALL = 1`) | **partial**: the port is correct for the beasts (flat x1) but drops the x4 the three buggy species do get |
| Pokedex AREA screen shows the roamer's current map (`FindNest.RoamMon1/2/3`) | `src/ui/TownMap.lua:167-198` | **missing**: nest mode scans only the map wild-slot tables for the species; there is no roamer branch, so a located beast never appears on the AREA map |
| `BattleCommand_ForceSwitch` (Roar from a wild beast ends the battle as a DRAW) | - | **missing**: `EFFECT_FORCE_SWITCH` exists only as an AI scoring hook (`src/battle/gen2/Ai.lua:559`); there is no effect handler, so a roamer's Roar does not end the battle |
| Headless coverage | `tests/gen2_world_test.lua:2203-2271`, `tests/gen2_roamers_test.lua`, `tests/drivers/gold_roamers.lua` | implemented: the driver runs the real `InitRoamMons` special, asserts the three starting routes, and exercises `MAPSETUP_DOOR` ticks |

---

## 6. Unresolved / verify by hand

1. **"They will show up on the map in Pokegear."** The only caller of `FindNest`
   is `engine/pokegear/pokegear.asm:2430`, inside `Pokedex_GetArea` (`24:5c7f`),
   whose header string is `'S NEST` (`.PlaceString_MonsNest`). That is the
   **Pokedex AREA** screen, which is *drawn* with the Pokegear town map code but
   is not reached from the Pokegear menu. Nothing in `_TownMap`
   (`engine/pokegear/pokegear.asm:1709`) plots roamers. Treat the walkthrough's
   wording as loose.
2. **"After the initial encounter ... they will show up."** `FindNest` itself has
   no "encountered" gate; it only compares `wNamedObjectIndex` with the slot's
   species. The real gate is that you must be able to select the species in the
   Pokedex at all, i.e. it must be SEEN. I could not find anything in
   `maps/BurnedTowerB1F.asm` that marks the three as seen during
   `ReleaseTheBeasts` (it only `appear`s sprites and plays cries), so in practice
   the first battle is what unlocks the AREA view. Not proven by a single
   `SetSeenMon` call; worth a hardware check.
3. **"asleep or paralyzed."** Sleep and freeze are worth `+10` to the catch rate
   (`engine/items/item_effects.asm:344`). Paralysis is worth **nothing** because
   of the commented-out `ld a, [wEnemyMonStatus]` reload in the same block, which
   the file itself flags as a bug. The advice is half wrong on the cart.
4. **"they occasionally will jump a few routes."** The asm's only "jump" is the
   1-in-32 `and %00011111 / jr z, JumpRoamMon` branch inside `.Update`, which is
   not "a few routes" but a uniformly random one of the sixteen. The observed
   behaviour matches loosely; the mechanism does not.
5. **"as quickly as every 10 seconds."** No timer anywhere in the roam code. Roam
   movement is purely event-driven (map setup scripts and battle ends). The ten
   seconds is a human estimate of how long two boundary crossings take.
6. **Roar vs the level-39 Scyther plan.** `BattleCommand_ForceSwitch`'s wild
   branch reads `wCurPartyLevel` for the *wild* mon's level and compares it with
   `wBattleMonLevel`; at 40 vs 39 it takes `.wild_succeed_playeristarget`
   unconditionally. I did not trace whether `wCurPartyLevel` is still the wild
   level at that point after a mid-battle player switch (several routines write
   that variable), so the "guaranteed Roar" claim is asserted from the code as
   written and should be confirmed on hardware before a bot relies on it.
7. **Bike and encounter rate.** The walkthrough leans on biking. `CanEncounterWildMon`
   (`engine/overworld/events.asm:1164`) and `GetMapEncounterRate` have no bicycle
   term, so the bike changes travel speed only, not encounter odds. Stated here
   because the opposite is widely believed.
8. **Suicune's starting route vs the walkthrough's framing.** `InitRoamMons`
   places Suicune on `ROUTE_38`, not at the Tin Tower or Route 42. The section
   text never states a starting route, so there is no contradiction, but a bot
   that assumes "Suicune is the one you chase last" has no asm basis for it.
9. **Route dimensions vs event coordinates.** `map_const` widths/heights are in
   blocks; `warp_event` / `object_event` / `bg_event` coordinates are in the
   2x-finer walk grid (e.g. `ROUTE_35` is 10 x 18 blocks and carries a warp at
   y=33). Every coordinate in this document is the raw asm value, unconverted.

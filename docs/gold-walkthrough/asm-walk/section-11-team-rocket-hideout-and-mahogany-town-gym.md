# Section 11 - Team Rocket Hideout and Mahogany Town Gym

Source: `../section-11-team-rocket-hideout-and-mahogany-town-gym.txt`
(the FAQ's own heading is "17 > Team Rocket Hideout and Mahogany Town Gym")

Maps covered: `MAP_MAHOGANY_TOWN`, `MAP_MAHOGANY_POKECENTER_1F`, `MAP_MAHOGANY_MART_1F`,
`MAP_TEAM_ROCKET_BASE_B1F`, `MAP_TEAM_ROCKET_BASE_B2F`, `MAP_TEAM_ROCKET_BASE_B3F`,
`MAP_MAHOGANY_GYM`

Badges / key milestones in this section:

- `EVENT_UNCOVERED_STAIRCASE_IN_MAHOGANY_MART` - the hideout entrance exists
- `EVENT_LEARNED_SLOWPOKETAIL`, `EVENT_LEARNED_RATICATE_TAIL` - Giovanni's-office door
- `EVENT_LEARNED_HAIL_GIOVANNI` - transmitter-room door
- `EVENT_GOT_HM06_WHIRLPOOL` (HM06 = `HM_WHIRLPOOL`)
- `EVENT_CLEARED_ROCKET_HIDEOUT` + `clearflag ENGINE_ROCKET_SIGNAL_ON_CH20`
- `ENGINE_GLACIERBADGE` (GLACIERBADGE, badge 7) + `EVENT_GOT_TM16_ICY_WIND` (TM16 = `TM_ICY_WIND`)

Entry precondition, set in the previous section: `maps/LakeOfRage.asm`
`LakeOfRageLanceScript.AgreedToHelp` runs
`clearevent EVENT_MAHOGANY_MART_LANCE_AND_DRAGONITE`,
`setevent EVENT_DECIDED_TO_HELP_LANCE`,
`setmapscene MAHOGANY_MART_1F, SCENE_MAHOGANYMART1F_LANCE_UNCOVERS_STAIRS`.
Without that scene set, the mart is an ordinary shop and there is no staircase.

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `MAP_MAHOGANY_TOWN` | `maps/MahoganyTown.asm` | from Route 43 gate (warp 5, `9,1`) or fly point `ENGINE_FLYPOINT_MAHOGANY` | warp 4 `15,13` -> Pokecenter, warp 1 `11,7` -> Mart | "Heal at the Pokemon Center and withdraw your Gyarados" |
| 2 | `MAP_MAHOGANY_POKECENTER_1F` | `maps/MahoganyPokecenter1F.asm` | warp 1/2 `3,7` / `4,7` | same | heal / PC withdraw |
| 3 | `MAP_MAHOGANY_MART_1F` | `maps/MahoganyMart1F.asm` | warp 1/2 `3,7` / `4,7` | warp 3 `7,3` | Lance's Dragonite Hyper Beams the shop open, uncovers the staircase |
| 4 | `MAP_TEAM_ROCKET_BASE_B1F` | `maps/TeamRocketBaseB1F.asm` | warp 1 `27,2` | warp 2 `3,14` | security cameras, GruntM16, Scientist Jed, secret switch, 3 item balls |
| 5 | `MAP_TEAM_ROCKET_BASE_B2F` (bottom region) | `maps/TeamRocketBaseB2F.asm` | warp 1 `3,14` | warp 5 `27,14` | Lance heals you; GruntM19 then GruntM17 |
| 6 | `MAP_TEAM_ROCKET_BASE_B3F` (right region) | `maps/TeamRocketBaseB3F.asm` | warp 4 `27,14` | warp 2 `27,2` | Lance's two-password speech, 4 item balls, Ross / GruntF5 / Mitch / GruntM28, both passwords |
| 7 | `MAP_TEAM_ROCKET_BASE_B2F` (top region) | `maps/TeamRocketBaseB2F.asm` | warp 3 `27,2` | warp 2 `3,2` | walk left past GruntM18 |
| 8 | `MAP_TEAM_ROCKET_BASE_B3F` (left region) | `maps/TeamRocketBaseB3F.asm` | warp 1 `3,2` | warp 3 `3,6` | rival cutscene, password door, ExecutiveM 4, Murkrow gives HAIL GIOVANNI |
| 9 | `MAP_TEAM_ROCKET_BASE_B2F` (TM room) | `maps/TeamRocketBaseB2F.asm` | warp 4 `3,6` | warp 4 `3,6` | "the second stairs that you did NOT come out of" - TM46 Thief at `3,10` |
| 10 | back through 8 -> 7 -> 6 -> 5 | | | | "Head back the way you came, past the spinning Team Rocket member" |
| 11 | `MAP_TEAM_ROCKET_BASE_B2F` (transmitter room) | `maps/TeamRocketBaseB2F.asm` | password door at `14,12` / `15,12` | warp 1 `3,14` (then B1F warp panel `5,15`) | ExecutiveF 2 ambush, 3 Electrode, HM06 Whirlpool from Lance |
| 12 | `MAP_MAHOGANY_TOWN` | `maps/MahoganyTown.asm` | Mart warps 1/2 | warp 3 `6,13` | heal, then the gym |
| 13 | `MAP_MAHOGANY_GYM` | `maps/MahoganyGym.asm` | warp 1/2 `4,17` / `5,17` | same | five ice-puzzle trainers, then Pryce -> GLACIERBADGE + TM16 |

Spill into the next section: the last paragraph ("You can now use Whirlpool, once you
find that in a dark cavern") points at `MAP_ICE_PATH_1F` / `MAP_ICE_PATH_B2F_MAHOGANY_SIDE`.
Not covered here.

---

## 2. Maps

### MAP_MAHOGANY_TOWN

- Script: `maps/MahoganyTown.asm`
- Blocks: `maps/MahoganyTown.blk`
- Header: `data/maps/maps.asm:74` -> `map MahoganyTown, TILESET_JOHTO, TOWN, LANDMARK_MAHOGANY_TOWN, MUSIC_CHERRYGROVE_CITY, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm` -> `map_const MAHOGANY_TOWN, 10, 9` (group `MAHOGANY` = 2, map id 7); 10x9 blocks = 20x18 map cells
- Connections: `data/maps/attributes.asm:152-155` -> north `Route43`, west `Route42`, east `Route44`
- Scene ids (declared inline by `scene_script`): `SCENE_MAHOGANYTOWN_TRY_RAGECANDYBAR` = 0, `SCENE_MAHOGANYTOWN_NOOP` = 1
- Callback: `MAPCALLBACK_NEWMAP, MahoganyTownFlypointCallback` -> `setflag ENGINE_FLYPOINT_MAHOGANY`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 11 | 7 | `MAHOGANY_MART_1F` | 1 |
| 2 | 17 | 7 | `MAHOGANY_RED_GYARADOS_SPEECH_HOUSE` | 1 |
| 3 | 6 | 13 | `MAHOGANY_GYM` | 1 |
| 4 | 15 | 13 | `MAHOGANY_POKECENTER_1F` | 1 |
| 5 | 9 | 1 | `ROUTE_43_MAHOGANY_GATE` | 3 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_MAHOGANYTOWN_TRY_RAGECANDYBAR` (0) | 19 | 8 | `MahoganyTownTryARageCandyBarScript` | merchant steps in front of you and pitches a RAGECANDYBAR |
| `SCENE_MAHOGANYTOWN_TRY_RAGECANDYBAR` (0) | 19 | 9 | `MahoganyTownTryARageCandyBarScript` | same |

The script never calls `setscene`, so the pitch re-fires every time you cross x=19
until `RadioTowerRocketsScript` (`engine/events/std_scripts.asm:263`) runs
`setmapscene MAHOGANY_TOWN, SCENE_MAHOGANYTOWN_NOOP`.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 1 | 5 | `BGEVENT_READ` | `MahoganyTownSign` |
| 9 | 7 | `BGEVENT_READ` | `MahoganyTownRagecandybarSign` |
| 3 | 13 | `BGEVENT_READ` | `MahoganyGymSign` |
| 16 | 13 | `BGEVENT_READ` | `MahoganyTownPokecenterSign` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MAHOGANYTOWN_POKEFAN_M` | `SPRITE_POKEFAN_M` | 19 | 8 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `MahoganyTownPokefanMScript` | `EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_EAST` |
| `MAHOGANYTOWN_GRAMPS` | `SPRITE_GRAMPS` | 6 | 9 | `WALK_LEFT_RIGHT` (radius 1,0) | `OBJECTTYPE_SCRIPT` | `MahoganyTownGrampsScript` | -1 |
| `MAHOGANYTOWN_FISHER` | `SPRITE_FISHER` | 6 | 14 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `MahoganyTownFisherScript` | `EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_GYM` |
| `MAHOGANYTOWN_LASS` | `SPRITE_LASS` | 12 | 8 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `MahoganyTownLassScript` | `EVENT_MAHOGANY_MART_OWNERS` |

Object-event flag polarity (verified in `engine/overworld/map_objects_2.asm`
`CheckObjectFlag`): the flag being **set** masks (hides) the object; `-1` means
always visible. So `EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_GYM` clear = the fisher
stands on `6,14`, one cell south of the gym warp at `6,13`, blocking it. That flag
is set by `RocketBaseElectrodeScript` at the end of the hideout, which is the real
gate on the Mahogany gym (see section 3).

### MAP_MAHOGANY_POKECENTER_1F

- Script: `maps/MahoganyPokecenter1F.asm`
- Header: `data/maps/maps.asm:70` -> `TILESET_POKECENTER, INDOOR, LANDMARK_MAHOGANY_TOWN, MUSIC_POKEMON_CENTER, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const MAHOGANY_POKECENTER_1F, 5, 4` (group 2, map id 3)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `MAHOGANY_TOWN` | 4 |
| 2 | 4 | 7 | `MAHOGANY_TOWN` | 4 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

No coord events, no bg events. Nurse is `MAHOGANYPOKECENTER1F_NURSE`
`SPRITE_NURSE` at `3,1`, script `MahoganyPokecenter1FNurseScript` ->
`jumpstd PokecenterNurseScript`.

### MAP_MAHOGANY_MART_1F

- Script: `maps/MahoganyMart1F.asm` (`45:4000 MahoganyMart1F_MapScripts`)
- Blocks: shares `maps/GiftShop.blk` (`data/maps/blocks.asm:700` -> `MahoganyMart1F_Blocks: MountMoonGiftShop_Blocks: INCBIN "maps/GiftShop.blk"`)
- Header: `data/maps/maps.asm:118` -> `TILESET_TRADITIONAL_HOUSE, INDOOR, LANDMARK_MAHOGANY_TOWN, MUSIC_MAHOGANY_MART, TRUE (no phone), PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const MAHOGANY_MART_1F, 4, 4` (group `DUNGEONS` = 3, map id 40)
- Scene ids: `SCENE_MAHOGANYMART1F_NOOP` = 0, `SCENE_MAHOGANYMART1F_LANCE_UNCOVERS_STAIRS` = 1
- Callback: `MAPCALLBACK_TILES, MahoganyMart1FStaircaseCallback` - if `EVENT_UNCOVERED_STAIRCASE_IN_MAHOGANY_MART` is set, `changeblock 6, 2, $1e ; stairs`

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `MAHOGANY_TOWN` | 1 |
| 2 | 4 | 7 | `MAHOGANY_TOWN` | 1 |
| 3 | 7 | 3 | `TEAM_ROCKET_BASE_B1F` | 1 |

`def_coord_events` and `def_bg_events` are both empty.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MAHOGANYMART1F_PHARMACIST` | `SPRITE_PHARMACIST` | 4 | 3 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `MahoganyMart1FPharmacistScript` | `EVENT_TEAM_ROCKET_BASE_POPULATION` |
| `MAHOGANYMART1F_BLACK_BELT` | `SPRITE_BLACK_BELT` | 1 | 6 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `MahoganyMart1FBlackBeltScript` | `EVENT_TEAM_ROCKET_BASE_POPULATION` |
| `MAHOGANYMART1F_LANCE` | `SPRITE_LANCE` | 4 | 6 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_MAHOGANY_MART_LANCE_AND_DRAGONITE` |
| `MAHOGANYMART1F_DRAGONITE` | `SPRITE_DRAGON` | 3 | 6 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_MAHOGANY_MART_LANCE_AND_DRAGONITE` |
| `MAHOGANYMART1F_GRANNY` | `SPRITE_GRANNY` | 1 | 3 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `MahoganyMart1FGrannyScript` | `EVENT_MAHOGANY_MART_OWNERS` |

**Scripts of interest**

`MahoganyMart1FLanceUncoversStaircaseScript` (`45:4046`), reached as
`scene_script ... SCENE_MAHOGANYMART1F_LANCE_UNCOVERS_STAIRS` via `sdefer`, so it
fires on map entry without any player input:

1. Dragonite `big_step LEFT / big_step RIGHT` into the Black Belt, `disappear MAHOGANYMART1F_DRAGONITE`
2. Lance walks over (`MahoganyMart1FLanceApproachPlayerMovement`), `follow MAHOGANYMART1F_LANCE, PLAYER`, shoves the pharmacist aside
3. `changeblock 6, 2, $1e` + `refreshmap` + `setevent EVENT_UNCOVERED_STAIRCASE_IN_MAHOGANY_MART`
4. `disappear MAHOGANYMART1F_LANCE`, `setscene SCENE_MAHOGANYMART1F_NOOP`

`changeblock`'s operands are **map cell coordinates**, not block coordinates
(`Script_changeblock` at `engine/overworld/scripting.asm:2031` adds 4 to each and
calls `GetBlockLocation`, which halves them - `home/map.asm:2099`). `6,2` is
therefore block (3,1), covering cells (6..7, 2..3); block `$1e` in
`data/tilesets/traditional_house_collision.asm` is `FLOOR, FLOOR, FLOOR, LADDER`,
putting the LADDER on cell `7,3` - exactly the warp row above.

Marts: `MahoganyMart1FPharmacistScript` -> `pokemart MARTTYPE_STANDARD, MART_MAHOGANY_1`
(closed once `EVENT_DECIDED_TO_HELP_LANCE` is set),
`MahoganyMart1FGrannyScript` -> `pokemart MARTTYPE_STANDARD, MART_MAHOGANY_2`.

### MAP_TEAM_ROCKET_BASE_B1F

- Script: `maps/TeamRocketBaseB1F.asm` (`45:430c TeamRocketBaseB1F_MapScripts`)
- Blocks: `maps/TeamRocketBaseB1F.blk`
- Header: `data/maps/maps.asm:119` -> `TILESET_UNDERGROUND, DUNGEON, LANDMARK_MAHOGANY_TOWN, MUSIC_ROCKET_HIDEOUT, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const TEAM_ROCKET_BASE_B1F, 15, 9` (group 3, map id 41) = 30x18 cells
- Scene ids: `SCENE_TEAMROCKETBASEB1F_TRAPS` = 0 (the only one)
- Callback: `MAPCALLBACK_OBJECTS, TeamRocketBaseB1FHideSecurityGruntCallback` -> `disappear TEAMROCKETBASEB1F_ROCKET1` (the camera grunt is parked off-screen at `0,0` and teleported in by `moveobject`)

The whole floor is one connected walkable region (flood-filled from
`maps/TeamRocketBaseB1F.blk` against `data/tilesets/underground_collision.asm`).

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 27 | 2 | `MAHOGANY_MART_1F` | 3 |
| 2 | 3 | 14 | `TEAM_ROCKET_BASE_B2F` | 1 |
| 3 | 5 | 15 | `TEAM_ROCKET_BASE_B1F` | 4 |
| 4 | 25 | 2 | `TEAM_ROCKET_BASE_B1F` | 3 |

Warps 3 and 4 are the warp panel pair Scientist Jed describes: cell `5,15` has
collision `WARP_PANEL` and dumps you at `25,2`, two cells from the exit ladder.

**Coord events** (`def_coord_events`) - all on scene `SCENE_TEAMROCKETBASEB1F_TRAPS` (0)

Security cameras (each triggers `GRUNTM_20` then `GRUNTM_21`):

| x | y | script label | guarding statue (bg_event) |
|---|---|---|---|
| 24 | 2 | `SecurityCamera1a` | `24,1` |
| 24 | 3 | `SecurityCamera1b` | `24,1` |
| 6 | 2 | `SecurityCamera2a` | `6,1` |
| 6 | 3 | `SecurityCamera2b` | `6,1` |
| 24 | 6 | `SecurityCamera3a` | `24,5` |
| 24 | 7 | `SecurityCamera3b` | `24,5` |
| 22 | 16 | `SecurityCamera4` | `22,15` |
| 8 | 16 | `SecurityCamera5` | `8,15` |

Exploding-trap tiles (each is a one-shot wild battle with
`loadvar VAR_BATTLETYPE, BATTLETYPE_TRAP`):

| x | y | script | mon |
|---|---|---|---|
| 2 | 7 | `ExplodingTrap1` | `KoffingExplodingTrap` - KOFFING L21 |
| 3 | 7 | `ExplodingTrap2` | `VoltorbExplodingTrap` - VOLTORB L23 |
| 4 | 7 | `ExplodingTrap3` | `GeodudeExplodingTrap` - GEODUDE L21 |
| 1 | 8 | `ExplodingTrap4` | VOLTORB L23 |
| 3 | 8 | `ExplodingTrap5` | GEODUDE L21 |
| 5 | 8 | `ExplodingTrap6` | KOFFING L21 |
| 3 | 9 | `ExplodingTrap7` | VOLTORB L23 |
| 4 | 9 | `ExplodingTrap8` | KOFFING L21 |
| 1 | 10 | `ExplodingTrap9` | KOFFING L21 |
| 2 | 10 | `ExplodingTrap10` | VOLTORB L23 |
| 3 | 10 | `ExplodingTrap11` | GEODUDE L21 |
| 5 | 10 | `ExplodingTrap12` | GEODUDE L21 |
| 2 | 11 | `ExplodingTrap13` | GEODUDE L21 |
| 4 | 11 | `ExplodingTrap14` | KOFFING L21 |
| 1 | 12 | `ExplodingTrap15` | VOLTORB L23 |
| 2 | 12 | `ExplodingTrap16` | KOFFING L21 |
| 4 | 12 | `ExplodingTrap17` | VOLTORB L23 |
| 5 | 12 | `ExplodingTrap18` | GEODUDE L21 |
| 1 | 13 | `ExplodingTrap19` | GEODUDE L21 |
| 3 | 13 | `ExplodingTrap20` | VOLTORB L23 |
| 4 | 13 | `ExplodingTrap21` | KOFFING L21 |
| 5 | 13 | `ExplodingTrap22` | VOLTORB L23 |

Safe cells inside the 5x7 trap field (x 1..5, y 7..13) are exactly those with no
row above: `(1,7)`, `(5,7)`, `(2,8)`, `(4,8)`, `(1,9)`, `(2,9)`, `(5,9)`, `(4,10)`,
`(1,11)`, `(3,11)`, `(5,11)`, `(3,12)`, `(2,13)`. `(3,11)` is also the hidden REVIVE.
That is the "zig-zag" the walkthrough describes.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 19 | 11 | `BGEVENT_READ` | `TeamRocketBaseB1FSecretSwitch` |
| 24 | 1 | `BGEVENT_UP` | `TeamRocketBaseB1FSecurityCamera` |
| 6 | 1 | `BGEVENT_UP` | `TeamRocketBaseB1FSecurityCamera` |
| 8 | 15 | `BGEVENT_UP` | `TeamRocketBaseB1FSecurityCamera` |
| 22 | 15 | `BGEVENT_UP` | `TeamRocketBaseB1FSecurityCamera` |
| 24 | 5 | `BGEVENT_UP` | `TeamRocketBaseB1FSecurityCamera` |
| 20 | 11 | `BGEVENT_READ` | `TeamRocketBaseB1FBookshelf` (`jumpstd TeamRocketOathScript`) |
| 21 | 11 | `BGEVENT_READ` | `TeamRocketBaseB1FBookshelf` |
| 3 | 11 | `BGEVENT_ITEM` | `TeamRocketBaseB1FHiddenRevive` -> `hiddenitem REVIVE, EVENT_TEAM_ROCKET_BASE_B1F_HIDDEN_REVIVE` |

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `TEAMROCKETBASEB1F_ROCKET1` | `SPRITE_ROCKET` | 0 | 0 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `ObjectEvent` | `EVENT_TEAM_ROCKET_BASE_SECURITY_GRUNTS` |
| - | `SPRITE_ROCKET` | 2 | 4 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 3 | `TrainerGruntM16` | `EVENT_TEAM_ROCKET_BASE_POPULATION` |
| - | `SPRITE_SCIENTIST` | 18 | 12 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 3 | `TrainerScientistJed` | `EVENT_TEAM_ROCKET_BASE_POPULATION` |
| `TEAMROCKETBASEB1F_POKE_BALL1` | `SPRITE_POKE_BALL` | 27 | 6 | `STILL` | `OBJECTTYPE_ITEMBALL` | 0 | `TeamRocketBaseB1FHyperPotion` | `EVENT_TEAM_ROCKET_BASE_B1F_HYPER_POTION` |
| `TEAMROCKETBASEB1F_POKE_BALL2` | `SPRITE_POKE_BALL` | 14 | 15 | `STILL` | `OBJECTTYPE_ITEMBALL` | 0 | `TeamRocketBaseB1FNugget` | `EVENT_TEAM_ROCKET_BASE_B1F_NUGGET` |
| `TEAMROCKETBASEB1F_POKE_BALL3` | `SPRITE_POKE_BALL` | 21 | 12 | `STILL` | `OBJECTTYPE_ITEMBALL` | 0 | `TeamRocketBaseB1FXAccuracy` | `EVENT_TEAM_ROCKET_BASE_B1F_X_ACCURACY` |

**Scripts of interest**

- `SecurityCamera1a` .. `SecurityCamera5`: `checkevent EVENT_SECURITY_CAMERA_n` -> bail;
  `PlaySecurityCameraSounds` (6x `SFX_LICK`); `checkevent EVENT_TEAM_ROCKET_BASE_POPULATION`
  -> bail (never true, see below); `showemote EMOTE_SHOCK, PLAYER`;
  `playmusic MUSIC_ROCKET_ENCOUNTER`; `moveobject TEAMROCKETBASEB1F_ROCKET1, <x>, <y>`;
  `appear`; `applymovement SecurityCameraMovement*`; `scall TrainerCameraGrunt1`;
  repeat for `TrainerCameraGrunt2`; `setevent EVENT_SECURITY_CAMERA_n`.
  Both grunt scripts use `loadtrainer` + `startbattle` directly (no `trainer` macro,
  so no per-trainer beat flag) - the same two teams are re-fought at every camera.
- `TeamRocketBaseB1FSecretSwitch` (`45:4757`): if `EVENT_TURNED_OFF_SECURITY_CAMERAS`
  is already set, prints "the switch is turned off"; otherwise
  `playsound SFX_TALLY` and sets
  `EVENT_TURNED_OFF_SECURITY_CAMERAS` + `EVENT_SECURITY_CAMERA_1..5` in one go.
  Cell `19,11` is a wall, read from `19,12` facing up.
- `TrainerScientistJed` -> `.Script` after-battle text tells you about the warp panel.
- `TrainerGruntM16` -> after-battle text about the traps.

**Flags and events** (B1F)

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_SECURITY_CAMERA_1` .. `_5` | `constants/event_flags.asm:403-407` | set by each camera script and by the switch | camera n is spent |
| `EVENT_TURNED_OFF_SECURITY_CAMERAS` | `event_flags.asm:402` | `TeamRocketBaseB1FSecretSwitch`, `RocketBaseElectrodeScript` | switch state only |
| `EVENT_TEAM_ROCKET_BASE_SECURITY_GRUNTS` | `event_flags.asm:1147` | `disappear`/`appear` of `TEAMROCKETBASEB1F_ROCKET1` | ambush grunt visibility |
| `EVENT_TEAM_ROCKET_BASE_POPULATION` | `event_flags.asm:1148` | read by 8 camera scripts, shared visibility flag of 11 base NPCs | **never set anywhere in the ROM** - grep confirms no `setevent`/`disappear` on it, so those `checkevent` arms are dead and the base NPCs never vanish |
| `EVENT_TEAM_ROCKET_BASE_B1F_HYPER_POTION` / `_NUGGET` / `_X_ACCURACY` | `event_flags.asm:1034-1036` | `itemball` | item ball taken |
| `EVENT_TEAM_ROCKET_BASE_B1F_HIDDEN_REVIVE` | `event_flags.asm:144` | `hiddenitem` | hidden REVIVE at `3,11` taken |
| `EVENT_EXPLODING_TRAP_1..22` | `constants/event_flags.asm` | each `ExplodingTrapN` | trap spent |

**Items** (B1F)

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `HYPER_POTION` | item ball at `27,6` | `TeamRocketBaseB1FHyperPotion` | `EVENT_TEAM_ROCKET_BASE_B1F_HYPER_POTION` |
| `NUGGET` | item ball at `14,15` | `TeamRocketBaseB1FNugget` | `EVENT_TEAM_ROCKET_BASE_B1F_NUGGET` |
| `X_ACCURACY` | item ball at `21,12` | `TeamRocketBaseB1FXAccuracy` | `EVENT_TEAM_ROCKET_BASE_B1F_X_ACCURACY` |
| `REVIVE` | hidden, face cell `3,11` | `bg_event 3, 11, BGEVENT_ITEM` | `EVENT_TEAM_ROCKET_BASE_B1F_HIDDEN_REVIVE` |

**Trainers** (B1F)

| const | class | id | party (`data/trainers/parties.asm`) | script label | notes |
|---|---|---|---|---|---|
| `GRUNTM`, `GRUNTM_16` | `GRUNTM` (`$1f`) | 16 | RATTATA 16, RATTATA 16, RATTATA 16, RATTATA 16 | `TrainerGruntM16` | `EVENT_BEAT_ROCKET_GRUNTM_16`, sight 3 |
| `SCIENTIST`, `JED` | `SCIENTIST` (`$0e`) | 3 | MAGNEMITE 20 x3 | `TrainerScientistJed` | `EVENT_BEAT_SCIENTIST_JED`, sight 3 |
| `GRUNTM`, `GRUNTM_20` | `GRUNTM` | 20 | DROWZEE 17, ZUBAT 19 | `TrainerCameraGrunt1` | no beat flag, repeats per camera |
| `GRUNTM`, `GRUNTM_21` | `GRUNTM` | 21 | ZUBAT 16, GRIMER 17, RATTATA 18 | `TrainerCameraGrunt2` | no beat flag, repeats per camera |

**Wild encounters**: none. `TEAM_ROCKET_BASE_B1F` has no entry in
`data/wild/johto_grass.asm`, `johto_water.asm`, `fish.asm` or `treemons.asm`. The
only wild battles are the `loadwildmon` traps above and the three Electrode on B2F.

### MAP_TEAM_ROCKET_BASE_B2F

- Script: `maps/TeamRocketBaseB2F.asm` (`45:4c2b TeamRocketBaseB2F_MapScripts`)
- Blocks: `maps/TeamRocketBaseB2F.blk`
- Header: `data/maps/maps.asm:120` -> `TILESET_FACILITY, DUNGEON, LANDMARK_MAHOGANY_TOWN, MUSIC_ROCKET_HIDEOUT, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const TEAM_ROCKET_BASE_B2F, 15, 9` (group 3, map id 42) = 30x18 cells
- Scene ids: `SCENE_TEAMROCKETBASEB2F_LANCE_HEALS` = 0, `..._ROCKET_BOSS` = 1, `..._ELECTRODES` = 2, `..._NOOP` = 3
- Callback: `MAPCALLBACK_TILES, TeamRocketBaseB2FTransmitterDoorCallback` - if `EVENT_OPENED_DOOR_TO_ROCKET_HIDEOUT_TRANSMITTER`, `changeblock 14, 12, $07 ; floor`

Walkable regions (flood fill of `maps/TeamRocketBaseB2F.blk` against
`data/tilesets/facility_collision.asm`) - this floor is four disconnected rooms:

| region | contents |
|---|---|
| top corridor | warp 2 `3,2`, warp 3 `27,2`, GruntM18 `2,1` |
| transmitter room | boss coord `14,11`/`15,11`, Electrodes `7,5`/`7,7`/`7,9` and `22,5`/`22,7`/`22,9`; sealed until the password door opens |
| TM room | warp 4 `3,6`, TM_THIEF item ball `3,10` |
| bottom corridor | warp 1 `3,14` (to B1F), warp 5 `27,14`, Lance heal coords, GruntM19 `21,14`, GruntM17 `25,13` |

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 14 | `TEAM_ROCKET_BASE_B1F` | 2 |
| 2 | 3 | 2 | `TEAM_ROCKET_BASE_B3F` | 1 |
| 3 | 27 | 2 | `TEAM_ROCKET_BASE_B3F` | 2 |
| 4 | 3 | 6 | `TEAM_ROCKET_BASE_B3F` | 3 |
| 5 | 27 | 14 | `TEAM_ROCKET_BASE_B3F` | 4 |

**Coord events**

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `LANCE_HEALS` (0) | 5 | 14 | `LanceHealsScript1` | face UP, then `LanceHealsCommon` |
| `LANCE_HEALS` (0) | 4 | 13 | `LanceHealsScript2` | face RIGHT, then `LanceHealsCommon` |
| `ROCKET_BOSS` (1) | 14 | 11 | `RocketBaseBossFLeft` | Executive F ambush (Lance spawns at `9,13`) |
| `ROCKET_BOSS` (1) | 15 | 11 | `RocketBaseBossFRight` | same, actors nudged one cell right |
| `ELECTRODES` (2) | 14 | 12 | `RocketBaseCantLeaveScript` | shoves you back into the room |
| `ELECTRODES` (2) | 15 | 12 | `RocketBaseCantLeaveScript` | same |
| `ELECTRODES` (2) | 12 | 3 | `RocketBaseLancesSideScript` | "Leave this side to me", step LEFT |
| `ELECTRODES` (2) | 12 | 10 | `RocketBaseLancesSideScript` | same |
| `ELECTRODES` (2) | 12 | 11 | `RocketBaseLancesSideScript` | same |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 14 | 12 | `BGEVENT_IFNOTSET` | `conditional_event EVENT_OPENED_DOOR_TO_ROCKET_HIDEOUT_TRANSMITTER, TeamRocketBaseB2FLockedDoor.Script` |
| 15 | 12 | `BGEVENT_IFNOTSET` | same |
| 12..17, 4 and 9; 12, 5..8; 17, 5..8 (20 cells) | | `BGEVENT_READ` | `TeamRocketBaseB2FTransmitterScript` |
| 26 | 7 | `BGEVENT_ITEM` | `TeamRocketBaseB2FHiddenFullHeal` -> `hiddenitem FULL_HEAL, EVENT_TEAM_ROCKET_BASE_B2F_HIDDEN_FULL_HEAL` |

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `TEAMROCKETBASEB2F_ROCKET1` | `SPRITE_ROCKET` | 20 | 16 | `STANDING_UP` | `SCRIPT` | 0 | `ObjectEvent` | `EVENT_TEAM_ROCKET_BASE_B2F_GRUNT_WITH_EXECUTIVE` |
| `TEAMROCKETBASEB2F_ROCKET_GIRL` | `SPRITE_ROCKET_GIRL` | 20 | 16 | `STANDING_UP` | `SCRIPT` | 0 | `ObjectEvent` | `EVENT_TEAM_ROCKET_BASE_B2F_EXECUTIVE` |
| `TEAMROCKETBASEB2F_LANCE` | `SPRITE_LANCE` | 5 | 13 | `STANDING_DOWN` | `SCRIPT` | 0 | `ObjectEvent` | `EVENT_TEAM_ROCKET_BASE_B2F_LANCE` |
| `TEAMROCKETBASEB2F_DRAGON` | `SPRITE_DRAGON` | 9 | 13 | `STANDING_RIGHT` | `SCRIPT` | 0 | `ObjectEvent` | `EVENT_TEAM_ROCKET_BASE_B2F_DRAGONITE` |
| `TEAMROCKETBASEB2F_ELECTRODE1` | `SPRITE_VOLTORB` | 7 | 5 | `POKEMON` | `SCRIPT` | 0 | `RocketElectrode1` | `EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_1` |
| `TEAMROCKETBASEB2F_ELECTRODE2` | `SPRITE_VOLTORB` | 7 | 7 | `POKEMON` | `SCRIPT` | 0 | `RocketElectrode2` | `EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_2` |
| `TEAMROCKETBASEB2F_ELECTRODE3` | `SPRITE_VOLTORB` | 7 | 9 | `POKEMON` | `SCRIPT` | 0 | `RocketElectrode3` | `EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_3` |
| `TEAMROCKETBASEB2F_ELECTRODE4` | `SPRITE_VOLTORB` | 22 | 5 | `POKEMON` | `SCRIPT` | 0 | `ObjectEvent` | `EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_1` |
| `TEAMROCKETBASEB2F_ELECTRODE5` | `SPRITE_VOLTORB` | 22 | 7 | `POKEMON` | `SCRIPT` | 0 | `ObjectEvent` | `EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_2` |
| `TEAMROCKETBASEB2F_ELECTRODE6` | `SPRITE_VOLTORB` | 22 | 9 | `POKEMON` | `SCRIPT` | 0 | `ObjectEvent` | `EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_3` |
| `TEAMROCKETBASEB2F_ROCKET2` | `SPRITE_ROCKET` | 25 | 13 | `STANDING_DOWN` | `TRAINER` | 3 | `TrainerGruntM17` | `EVENT_TEAM_ROCKET_BASE_POPULATION` |
| `TEAMROCKETBASEB2F_ROCKET3` | `SPRITE_ROCKET` | 2 | 1 | `STANDING_RIGHT` | `TRAINER` | 3 | `TrainerGruntM18` | `EVENT_TEAM_ROCKET_BASE_POPULATION` |
| `TEAMROCKETBASEB2F_ROCKET4` | `SPRITE_ROCKET` | 21 | 14 | `STANDING_LEFT` | `TRAINER` | 4 | `TrainerGruntM19` | `EVENT_TEAM_ROCKET_BASE_POPULATION` |
| `TEAMROCKETBASEB2F_POKE_BALL` | `SPRITE_POKE_BALL` | 3 | 10 | `STILL` | `ITEMBALL` | 0 | `TeamRocketBaseB2FTMThief` | `EVENT_TEAM_ROCKET_BASE_B2F_TM_THIEF` |

The Electrodes on the right (`22,5/7/9`) mirror the left three and share their flags;
`RocketElectrodeN` disappears both of a pair, so Lance's three "count" without ever
being battled.

**Scripts of interest**

- `LanceHealsCommon` (`45:4d4c`): `special FadeOutToWhite`, `playsound SFX_FULL_HEAL`,
  `special HealParty`, `special FadeInFromWhite`,
  `setscene SCENE_TEAMROCKETBASEB2F_ROCKET_BOSS`,
  `setevent EVENT_LANCE_HEALED_YOU_IN_TEAM_ROCKET_BASE`, then `readvar VAR_FACING`
  picks one of two exit movements and `disappear TEAMROCKETBASEB2F_LANCE`.
  **This is a hard ordering dependency**: the boss ambush coord events only exist
  on scene 1, so the transmitter room cannot be entered until Lance has healed you.
- `TeamRocketBaseB2FLockedDoor` (`45:4e8f`): `conditional_event` on
  `EVENT_OPENED_DOOR_TO_ROCKET_HIDEOUT_TRANSMITTER`; `.Script` checks
  `EVENT_LEARNED_HAIL_GIOVANNI`. If known: `playsound SFX_ENTER_DOOR`,
  `changeblock 14, 12, $07`, `refreshmap`, `setevent EVENT_OPENED_DOOR_TO_ROCKET_HIDEOUT_TRANSMITTER`.
- `RocketBaseBossFScript` (`45:4c67`): cutscene, then
  `loadtrainer EXECUTIVEF, EXECUTIVEF_2` + `startbattle`;
  sets `EVENT_TEAM_ROCKET_BASE_B2F_EXECUTIVE`, `..._GRUNT_WITH_EXECUTIVE`,
  `..._LANCE`, `EVENT_BEAT_ROCKET_EXECUTIVEF_2`; then
  `setscene SCENE_TEAMROCKETBASEB2F_ELECTRODES`, `clearevent EVENT_TEAM_ROCKET_BASE_B2F_LANCE`
  (re-showing Lance), the Electrode briefing, `disappear TEAMROCKETBASEB2F_LANCE`.
- `RocketElectrode1/2/3`: `cry ELECTRODE`, `loadwildmon ELECTRODE, 23`, `startbattle`.
  `iftrue TeamRocketBaseB2FReloadMap` covers the "you lost/fled" path. After all three
  events are set, the player is auto-walked out by
  `RocketBasePlayerLeavesElectrodesMovement1/2/3` into `RocketBaseElectrodeScript`.
  No `BATTLETYPE_*` is armed here, so these are catchable ordinary wild battles.
- `RocketBaseElectrodeScript` (`45:4e3c`) - the section's payoff:
  `verbosegiveitem HM_WHIRLPOOL`, `setevent EVENT_GOT_HM06_WHIRLPOOL`, then
  `setevent EVENT_CLEARED_ROCKET_HIDEOUT`,
  `clearflag ENGINE_ROCKET_SIGNAL_ON_CH20`,
  `setevent EVENT_ROUTE_43_GATE_ROCKETS`,
  `setevent EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_GYM` (hides the fisher -> gym opens),
  `setscene SCENE_TEAMROCKETBASEB2F_NOOP`,
  `clearevent EVENT_LAKE_OF_RAGE_CIVILIANS`,
  `setevent EVENT_TURNED_OFF_SECURITY_CAMERAS` + `EVENT_SECURITY_CAMERA_1..5`.

**Items** (B2F)

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `TM_THIEF` (TM46) | item ball at `3,10` (TM room) | `TeamRocketBaseB2FTMThief` | `EVENT_TEAM_ROCKET_BASE_B2F_TM_THIEF` |
| `FULL_HEAL` | hidden, face cell `26,7` | `bg_event 26, 7, BGEVENT_ITEM` | `EVENT_TEAM_ROCKET_BASE_B2F_HIDDEN_FULL_HEAL` |
| `HM_WHIRLPOOL` (HM06) | `verbosegiveitem` from Lance | `RocketBaseElectrodeScript` | `EVENT_GOT_HM06_WHIRLPOOL` |

TM numbering check: `constants/item_constants.asm` `add_tm THIEF ; ee` is the 46th
`add_tm` (the `const ITEM_C3` / `const ITEM_DC` holes do not consume TM numbers), so
TM46 = Thief, matching the walkthrough. `add_tm ICY_WIND ; cf` is the 16th = TM16.

**Trainers** (B2F)

| const | class | id | party | script label | sight |
|---|---|---|---|---|---|
| `GRUNTM_17` | `GRUNTM` | 17 | GOLBAT 18 | `TrainerGruntM17` | 3 |
| `GRUNTM_18` | `GRUNTM` | 18 | RATTATA 17, ZUBAT 17, RATTATA 17 | `TrainerGruntM18` | 3 |
| `GRUNTM_19` | `GRUNTM` | 19 | VENONAT 18, VENONAT 18 | `TrainerGruntM19` | 4 |
| `EXECUTIVEF_2` | `EXECUTIVEF` (`$37`) | 2 | ARBOK 23 (WRAP/LEER/POISON_STING/BITE), GLOOM 23 (ABSORB/SWEET_SCENT/SLEEP_POWDER/ACID), MURKROW 25 (PECK/PURSUIT/HAZE/-) | `RocketBaseBossFScript` | cutscene |

**Wild encounters**: none in the tables; only `loadwildmon ELECTRODE, 23` x3.

### MAP_TEAM_ROCKET_BASE_B3F

- Script: `maps/TeamRocketBaseB3F.asm` (`45:5c8c TeamRocketBaseB3F_MapScripts`)
- Blocks: `maps/TeamRocketBaseB3F.blk`
- Header: `data/maps/maps.asm:121` -> `TILESET_FACILITY, DUNGEON, LANDMARK_MAHOGANY_TOWN, MUSIC_ROCKET_HIDEOUT, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const TEAM_ROCKET_BASE_B3F, 15, 9` (group 3, map id 43) = 30x18 cells
- Scene ids: `SCENE_TEAMROCKETBASEB3F_LANCE_GETS_PASSWORD` = 0, `..._RIVAL_ENCOUNTER` = 1, `..._ROCKET_BOSS` = 2, `..._NOOP` = 3
- Callback: `MAPCALLBACK_TILES, TeamRocketBaseB3FCheckGiovanniDoorCallback` - if `EVENT_OPENED_DOOR_TO_GIOVANNIS_OFFICE`, `changeblock 10, 8, $07 ; floor`

Walkable regions (same flood-fill method):

| region | contents |
|---|---|
| left | warp 1 `3,2`, warp 3 `3,6`, rival coord `8,10` |
| Giovanni's office | boss coords `10,8`/`11,8`, ExecutiveM `8,3`, Murkrow `7,2`; sealed until both passwords |
| right / main | warp 2 `27,2`, warp 4 `27,14`, Lance `25,14`, GruntF5 `21,7`, GruntM28 `5,15`, Ross `25,12`, Mitch `14,15`, all four item balls |

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 2 | `TEAM_ROCKET_BASE_B2F` | 2 |
| 2 | 27 | 2 | `TEAM_ROCKET_BASE_B2F` | 3 |
| 3 | 3 | 6 | `TEAM_ROCKET_BASE_B2F` | 4 |
| 4 | 27 | 14 | `TEAM_ROCKET_BASE_B2F` | 5 |

**Coord events**

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `ROCKET_BOSS` (2) | 10 | 8 | `RocketBaseBossLeft` | auto-walk `UP UP UP LEFT LEFT`, then `RocketBaseBoss` |
| `ROCKET_BOSS` (2) | 11 | 8 | `RocketBaseBossRight` | auto-walk `UP UP LEFT UP LEFT LEFT`, then `RocketBaseBoss` |
| `RIVAL_ENCOUNTER` (1) | 8 | 10 | `RocketBaseRival` | rival cutscene, no battle |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 10 | 9 | `BGEVENT_IFNOTSET` | `conditional_event EVENT_OPENED_DOOR_TO_GIOVANNIS_OFFICE, TeamRocketBaseB3FLockedDoor.Script` |
| 11 | 9 | `BGEVENT_IFNOTSET` | same |
| 10..13, 1 | | `BGEVENT_READ` | `TeamRocketBaseB3FOathScript` (`jumpstd TeamRocketOathScript`) |
| 4..7, 13 | | `BGEVENT_READ` | `TeamRocketBaseB3FOathScript` |

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `TEAMROCKETBASEB3F_LANCE` | `SPRITE_LANCE` | 25 | 14 | `STANDING_DOWN` | `SCRIPT` | 0 | `LanceGetPasswordScript` | `EVENT_TEAM_ROCKET_BASE_B3F_LANCE_PASSWORDS` |
| `TEAMROCKETBASEB3F_ROCKET1` | `SPRITE_ROCKET` | 8 | 3 | `STANDING_UP` | `SCRIPT` | 0 | `ObjectEvent` | `EVENT_TEAM_ROCKET_BASE_B3F_EXECUTIVE` |
| `TEAMROCKETBASEB3F_MOLTRES` | `SPRITE_MOLTRES` | 7 | 2 | `POKEMON` | `SCRIPT` | 0 | `RocketBaseMurkrow` | `EVENT_TEAM_ROCKET_BASE_POPULATION` |
| `TEAMROCKETBASEB3F_ROCKET_GIRL` | `SPRITE_ROCKET_GIRL` | 21 | 7 | `STANDING_UP` | `TRAINER` | **0** | `SlowpokeTailGrunt` | `EVENT_TEAM_ROCKET_BASE_POPULATION` |
| `TEAMROCKETBASEB3F_ROCKET2` | `SPRITE_ROCKET` | 5 | 15 | `SPINRANDOM_FAST` | `TRAINER` | 3 | `RaticateTailGrunt` | `EVENT_TEAM_ROCKET_BASE_POPULATION` |
| `TEAMROCKETBASEB3F_SCIENTIST1` | `SPRITE_SCIENTIST` | 25 | 12 | `STANDING_LEFT` | `TRAINER` | 4 | `TrainerScientistRoss` | `EVENT_TEAM_ROCKET_BASE_POPULATION` |
| `TEAMROCKETBASEB3F_SCIENTIST2` | `SPRITE_SCIENTIST` | 14 | 15 | `STANDING_UP` | `TRAINER` | 3 | `TrainerScientistMitch` | `EVENT_TEAM_ROCKET_BASE_POPULATION` |
| `TEAMROCKETBASEB3F_ROCKET3` | `SPRITE_ROCKET` | 24 | 14 | `STANDING_DOWN` | `SCRIPT` | 0 | `TeamRocketBaseB3FRocketScript` | `EVENT_TEAM_ROCKET_BASE_POPULATION` |
| `TEAMROCKETBASEB3F_RIVAL` | `SPRITE_RIVAL` | 4 | 5 | `STANDING_DOWN` | `SCRIPT` | 0 | `ObjectEvent` | `EVENT_RIVAL_TEAM_ROCKET_BASE` |
| `TEAMROCKETBASEB3F_POKE_BALL1` | `SPRITE_POKE_BALL` | 1 | 12 | `STILL` | `ITEMBALL` | 0 | `TeamRocketBaseB3FFullHeal` | `EVENT_TEAM_ROCKET_BASE_B3F_FULL_HEAL` |
| `TEAMROCKETBASEB3F_POKE_BALL2` | `SPRITE_POKE_BALL` | 3 | 12 | `STILL` | `ITEMBALL` | 0 | `TeamRocketBaseB3FDireHit` | `EVENT_TEAM_ROCKET_BASE_B3F_DIRE_HIT` |
| `TEAMROCKETBASEB3F_POKE_BALL3` | `SPRITE_POKE_BALL` | 28 | 9 | `STILL` | `ITEMBALL` | 0 | `TeamRocketBaseB3FProtein` | `EVENT_TEAM_ROCKET_BASE_B3F_PROTEIN` |
| `TEAMROCKETBASEB3F_POKE_BALL4` | `SPRITE_POKE_BALL` | 17 | 2 | `STILL` | `ITEMBALL` | 0 | `TeamRocketBaseB3FIceHeal` | `EVENT_TEAM_ROCKET_BASE_B3F_ICE_HEAL` |

The Murkrow the walkthrough talks to is the object using `SPRITE_MOLTRES` at `7,2`;
its script is `RocketBaseMurkrow` and its text says MURKROW. The sprite constant is
the generic large-bird overworld sprite, not a Moltres encounter.

**Scripts of interest**

- `LanceGetPasswordScript` (`45:5cb4`): both the `sdefer` scene script for scene 0
  and the Lance object's own script. Runs on entry to the right region, prints
  `LanceGetPasswordText`, `disappear TEAMROCKETBASEB3F_LANCE` (which sets
  `EVENT_TEAM_ROCKET_BASE_B3F_LANCE_PASSWORDS`), `setscene SCENE_TEAMROCKETBASEB3F_RIVAL_ENCOUNTER`.
- `SlowpokeTailGrunt` -> `trainer GRUNTF, GRUNTF_5, EVENT_BEAT_ROCKET_GRUNTF_5, ...`;
  `GruntF5Script` (the after-battle arm) does `setevent EVENT_LEARNED_SLOWPOKETAIL`.
  **Sight range 0** - she never initiates; the bot must walk up and talk, then talk
  a second time for the password.
- `RaticateTailGrunt` -> `trainer GRUNTM, GRUNTM_28, EVENT_BEAT_ROCKET_GRUNTM_28, ...`;
  `GruntM28Script` does `setevent EVENT_LEARNED_RATICATE_TAIL`. Sight 3,
  `SPINRANDOM_FAST` (the "spinning Team Rocket member").
- `TeamRocketBaseB3FLockedDoor` (`45:5da9`): `.Script` requires
  `EVENT_LEARNED_SLOWPOKETAIL` **and** `EVENT_LEARNED_RATICATE_TAIL`; on success
  `changeblock 10, 8, $07`, `refreshmap`, `setevent EVENT_OPENED_DOOR_TO_GIOVANNIS_OFFICE`.
- `RocketBaseRival` (`45:5cd1`): `appear TEAMROCKETBASEB3F_RIVAL`, walk-in, dialogue,
  `applymovement PLAYER, RocketBaseRivalShovesPlayerMovement` (a `big_step RIGHT`
  with `fix_facing`), `disappear`, `setscene SCENE_TEAMROCKETBASEB3F_ROCKET_BOSS`.
  No battle - matches the walkthrough ("He can't battle you though").
- `RocketBaseBoss` (`45:5d0e`): `loadtrainer EXECUTIVEM, EXECUTIVEM_4`, `startbattle`,
  `setevent EVENT_BEAT_ROCKET_EXECUTIVEM_4`, long exit movement,
  `disappear TEAMROCKETBASEB3F_ROCKET1`, `setscene SCENE_TEAMROCKETBASEB3F_NOOP`.
- `RocketBaseMurkrow` (`45:5d49`): text, then `setevent EVENT_LEARNED_HAIL_GIOVANNI`.

**Items** (B3F)

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `FULL_HEAL` | item ball `1,12` | `TeamRocketBaseB3FFullHeal` | `EVENT_TEAM_ROCKET_BASE_B3F_FULL_HEAL` |
| `DIRE_HIT` | item ball `3,12` | `TeamRocketBaseB3FDireHit` | `EVENT_TEAM_ROCKET_BASE_B3F_DIRE_HIT` |
| `PROTEIN` | item ball `28,9` | `TeamRocketBaseB3FProtein` | `EVENT_TEAM_ROCKET_BASE_B3F_PROTEIN` |
| `ICE_HEAL` | item ball `17,2` | `TeamRocketBaseB3FIceHeal` | `EVENT_TEAM_ROCKET_BASE_B3F_ICE_HEAL` |

**Trainers** (B3F)

| const | class | id | party | script label | sight |
|---|---|---|---|---|---|
| `SCIENTIST`, `ROSS` | `SCIENTIST` (`$0e`) | 1 | KOFFING 22, KOFFING 22 | `TrainerScientistRoss` | 4 |
| `SCIENTIST`, `MITCH` | `SCIENTIST` | 2 | DITTO 24 | `TrainerScientistMitch` | 3 |
| `GRUNTF`, `GRUNTF_5` | `GRUNTF` (`$42`) | 5 | EKANS 18 (WRAP/LEER/POISON_STING/BITE), GLOOM 18 (ABSORB/SWEET_SCENT/STUN_SPORE/SLEEP_POWDER) | `SlowpokeTailGrunt` | 0 |
| `GRUNTM`, `GRUNTM_28` | `GRUNTM` (`$1f`) | 28 | RATICATE 19 | `RaticateTailGrunt` | 3 |
| `EXECUTIVEM`, `EXECUTIVEM_4` | `EXECUTIVEM` (`$33`) | 4 | ZUBAT 22, RATICATE 24, KOFFING 22 | `RocketBaseBoss` | cutscene |

**Wild encounters**: none.

### MAP_MAHOGANY_GYM

- Script: `maps/MahoganyGym.asm` (`51:536c MahoganyGym_MapScripts`)
- Blocks: `maps/MahoganyGym.blk`
- Header: `data/maps/maps.asm:69` -> `map MahoganyGym, TILESET_ELITE_FOUR_ROOM, INDOOR, LANDMARK_MAHOGANY_TOWN, MUSIC_GYM, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `map_const MAHOGANY_GYM, 5, 9` (group 2, map id 2) = 10x18 cells
- `def_scene_scripts` and `def_callbacks` are both **empty**

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 17 | `MAHOGANY_TOWN` | 3 |
| 2 | 5 | 17 | `MAHOGANY_TOWN` | 3 |

`def_coord_events` is empty.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 3 | 15 | `BGEVENT_READ` | `MahoganyGymStatue` |
| 6 | 15 | `BGEVENT_READ` | `MahoganyGymStatue` |

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `MAHOGANYGYM_PRYCE` | `SPRITE_PRYCE` | 5 | 3 | `STANDING_DOWN` | `SCRIPT` | 0 | `MahoganyGymPryceScript` | -1 |
| `MAHOGANYGYM_BEAUTY1` | `SPRITE_BEAUTY` | 4 | 6 | `STANDING_DOWN` | `TRAINER` | 1 | `TrainerSkierRoxanne` | -1 |
| `MAHOGANYGYM_ROCKER1` | `SPRITE_ROCKER` | 0 | 17 | `STANDING_UP` | `TRAINER` | 1 | `TrainerBoarderRonald` | -1 |
| `MAHOGANYGYM_BEAUTY2` | `SPRITE_BEAUTY` | 9 | 17 | `STANDING_UP` | `TRAINER` | 1 | `TrainerSkierClarissa` | -1 |
| `MAHOGANYGYM_ROCKER2` | `SPRITE_ROCKER` | 5 | 9 | `STANDING_DOWN` | `TRAINER` | 1 | `TrainerBoarderBrad` | -1 |
| `MAHOGANYGYM_ROCKER3` | `SPRITE_ROCKER` | 2 | 4 | `SPINRANDOM_FAST` | `TRAINER` | 1 | `TrainerBoarderDouglas` | -1 |
| `MAHOGANYGYM_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 7 | 15 | `STANDING_DOWN` | `SCRIPT` | 0 | `MahoganyGymGuideScript` | -1 |

**Ice-floor map**, decoded from `maps/MahoganyGym.blk` against
`data/tilesets/elite_four_room_collision.asm`. `I` = `COLL_ICE` (`$23`),
`.` = walkable floor, `#` = wall, `v` = warp carpet:

```
    x0123456789
 y0 ##########
 y1 ##########
 y2 .IIIII.I#I
 y3 IIIIIIII#I
 y4 I#I.I.IIII
 y5 I#IIII.III
 y6 I#IIIIIIII
 y7 I#II.IIII.
 y8 .IIIIIII#I
 y9 IIIIIIII#I
y10 I#.II.III.
y11 I#IIIII.II
y12 I#IIIIII#I
y13 I#I.II.I#I
y14 I#.#..#.#I
y15 I#.#..#.#I
y16 .I......I.
y17 II..vv..II
```

Sliding rule (`engine/overworld/player_movement.asm`): `CheckIceTile` on the tile
you land on -> `STEP_ICE`; `.CheckForced` / `CheckStandingOnIce` re-injects the same
d-pad direction, so a single press slides until you land on a non-ice tile, hit a
wall, or hit an NPC.

Simulating that rule against the grid above (NPCs treated as blockers) reproduces
the walkthrough's directions exactly:

| from | press | lands on | who |
|---|---|---|---|
| `4,17` (warp) | `UP` | `4,16` | - |
| `4,16` | `LEFT`, `LEFT`, `LEFT` | `3,16` -> `2,16` -> `0,16` | faces Boarder Ronald `0,17` |
| `0,16` | `UP`,`UP`,`RIGHT`,`DOWN`,`LEFT` | `0,8` -> `0,2` -> `6,2` -> `6,5` -> `2,5` | faces Boarder Douglas `2,4` |
| `2,5` | `DOWN`,`RIGHT` | `2,10` -> `5,10` | faces Boarder Brad `5,9` |
| `5,10` | `RIGHT`,`DOWN` | `9,10` -> `9,16` | faces Skier Clarissa `9,17` |
| `9,16` | `UP`,`UP`,`LEFT` | `9,10` -> `9,7` -> `4,7` | faces Skier Roxanne `4,6` |
| `4,7` | `DOWN` | `4,14` | back toward the exit |
| `2,14` ("just left of the left pillar", pillar block at `3,14`/`3,15`) | `UP`,`UP`,`RIGHT`,`DOWN`,`LEFT`,`UP`,`RIGHT` | `2,10` -> `2,5` -> `6,5` -> `6,13` -> `3,13` -> `3,4` -> `5,4` | standing directly below Pryce `5,3` |

Reaching `2,14` from the entrance: `UP` (to `4,16`), `LEFT` (`3,16`), `LEFT`
(`2,16`), `UP` (`2,15`), `UP` (`2,14`) - `2,15`/`2,16`/`2,14` are ordinary floor,
not ice, so those are single steps.

**Scripts of interest**

`MahoganyGymPryceScript` (`51:536e`):

1. `checkevent EVENT_BEAT_PRYCE` -> `.FightDone`
2. `writetext PryceText_Intro`; `winlosstext PryceText_Impressed, 0`;
   `loadtrainer PRYCE, PRYCE1`; `startbattle`; `reloadmapafterbattle`
3. `setevent EVENT_BEAT_PRYCE`; `Text_ReceivedGlacierBadge`;
   `playsound SFX_GET_BADGE`; `setflag ENGINE_GLACIERBADGE`
4. `readvar VAR_BADGES`; `scall MahoganyGymActivateRockets` -
   `ifequal 7, .RadioTowerRockets` / `ifequal 6, .GoldenrodRockets`.
   Badge count is read **after** GLACIERBADGE is set, so the normal route
   (Glacier as the 7th badge) takes `jumpstd RadioTowerRocketsScript`
   (`engine/events/std_scripts.asm:255`), which sets
   `ENGINE_ROCKETS_IN_RADIO_TOWER`, `EVENT_GOLDENROD_CITY_CIVILIANS`,
   `EVENT_RADIO_TOWER_BLACKBELT_BLOCKS_STAIRS`,
   `EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_EAST`,
   `specialphonecall SPECIALCALL_WEIRDBROADCAST`, and
   `setmapscene MAHOGANY_TOWN, SCENE_MAHOGANYTOWN_NOOP`.
   Skipping Jasmine first (Glacier as the 6th) takes
   `GoldenrodRocketsScript` instead, which only clears
   `EVENT_GOLDENROD_CITY_ROCKET_TAKEOVER`.
5. `.FightDone`: if `EVENT_GOT_TM16_ICY_WIND` is set -> farewell text. Otherwise
   `setevent EVENT_BEAT_SKIER_ROXANNE / _CLARISSA / _BOARDER_RONALD / _BRAD / _DOUGLAS`
   (so the five gym trainers never battle again), `PryceText_GlacierBadgeSpeech`,
   `verbosegiveitem TM_ICY_WIND`, `setevent EVENT_GOT_TM16_ICY_WIND`.

`MahoganyGymStatue`: `checkflag ENGINE_GLACIERBADGE`; before the badge
`jumpstd GymStatue1Script`, after it `gettrainername STRING_BUFFER_4, PRYCE, PRYCE1`
+ `jumpstd GymStatue2Script`.

**Flags and events** (gym)

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_PRYCE` | `constants/event_flags.asm:712` | `MahoganyGymPryceScript` | leader beaten |
| `EVENT_GOT_TM16_ICY_WIND` | `event_flags.asm:20` | `MahoganyGymPryceScript` | TM handed over |
| `ENGINE_GLACIERBADGE` | `constants/engine_flags.asm:44` | set here; read by `WhirlpoolFunction` and `MahoganyGymStatue` | badge 7 |
| `EVENT_BEAT_SKIER_ROXANNE`, `_CLARISSA`, `EVENT_BEAT_BOARDER_RONALD`, `_BRAD`, `_DOUGLAS` | `constants/event_flags.asm` | the five `trainer` macros, force-set by Pryce | gym trainer beaten |

**Trainers** (gym)

| const | class | id | party (`data/trainers/parties.asm`) | script label |
|---|---|---|---|---|
| `BOARDER`, `RONALD` | `BOARDER` (`$3a`) | 1 | SEEL 24, DEWGONG 25, SEEL 24 | `TrainerBoarderRonald` |
| `BOARDER`, `BRAD` | `BOARDER` | 2 | SWINUB 26, SWINUB 26 | `TrainerBoarderBrad` |
| `BOARDER`, `DOUGLAS` | `BOARDER` | 3 | SHELLDER 24, CLOYSTER 25, SHELLDER 24 | `TrainerBoarderDouglas` |
| `SKIER`, `ROXANNE` | `SKIER` (`$21`) | 1 | JYNX 28 | `TrainerSkierRoxanne` |
| `SKIER`, `CLARISSA` | `SKIER` | 2 | DEWGONG 28 | `TrainerSkierClarissa` |
| `PRYCE`, `PRYCE1` | `PRYCE` (`$05`) | 1 | SEEL 27 (HEADBUTT/ICY_WIND/AURORA_BEAM/REST), DEWGONG 29 (HEADBUTT/ICY_WIND/AURORA_BEAM/REST), PILOSWINE 31 (ICY_WIND/FURY_ATTACK/MIST/BLIZZARD) | `MahoganyGymPryceScript` |

**Wild encounters**: none.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Hideout entrance does not exist | `maps/MahoganyMart1F.asm:MahoganyMart1FStaircaseCallback` + `MahoganyMart1FLanceUncoversStaircaseScript` (`45:4046`) | `EVENT_UNCOVERED_STAIRCASE_IN_MAHOGANY_MART` for the block; the cutscene needs `SCENE_MAHOGANYMART1F_LANCE_UNCOVERS_STAIRS` | `maps/LakeOfRage.asm:LakeOfRageLanceScript.AgreedToHelp` (previous section) |
| Camera grunt ambushes | `maps/TeamRocketBaseB1F.asm:SecurityCamera1a..5` | `EVENT_SECURITY_CAMERA_n` clear | beat both grunts at that camera, or press the switch at `19,11` (`TeamRocketBaseB1FSecretSwitch`, `45:4757`) |
| Exploding floor traps | `maps/TeamRocketBaseB1F.asm:ExplodingTrap1..22` | `EVENT_EXPLODING_TRAP_n` clear | step on the tile once (or route around; safe cells listed above) |
| B2F transmitter room sealed (block) | `maps/TeamRocketBaseB2F.asm:TeamRocketBaseB2FLockedDoor` (`45:4e8f`) + `TeamRocketBaseB2FTransmitterDoorCallback` | `EVENT_LEARNED_HAIL_GIOVANNI` | talk to the Murkrow object at B3F `7,2` (`RocketBaseMurkrow`, `45:5d49`) after beating ExecutiveM 4 |
| B2F boss ambush will not fire | `maps/TeamRocketBaseB2F.asm` coord events on `SCENE_TEAMROCKETBASEB2F_ROCKET_BOSS` | map scene must be 1 | trip `LanceHealsScript1/2` at `5,14` or `4,13` first |
| B3F Giovanni's office sealed | `maps/TeamRocketBaseB3F.asm:TeamRocketBaseB3FLockedDoor` (`45:5da9`) + `TeamRocketBaseB3FCheckGiovanniDoorCallback` | `EVENT_LEARNED_SLOWPOKETAIL` **and** `EVENT_LEARNED_RATICATE_TAIL` | beat `GRUNTF_5` at `21,7` then talk again; beat `GRUNTM_28` at `5,15` then talk again |
| Cannot leave the Electrode room | `maps/TeamRocketBaseB2F.asm:RocketBaseCantLeaveScript` / `RocketBaseLancesSideScript` | scene `SCENE_TEAMROCKETBASEB2F_ELECTRODES` | faint all three left-hand Electrodes |
| Mahogany Gym door blocked | `maps/MahoganyTown.asm` object `SPRITE_FISHER` at `6,14` gated on `EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_GYM`; visibility rule in `engine/overworld/map_objects_2.asm:CheckObjectFlag` | flag set = NPC hidden | `RocketBaseElectrodeScript` (`45:4e3c`) sets it when the hideout is cleared |
| Whirlpool unusable in the field | `engine/events/overworld.asm:WhirlpoolFunction.TryWhirlpool` (`03:4da0`, `ld de, ENGINE_GLACIERBADGE / call CheckBadge`) and `TryWhirlpoolOW` (`03:4e41`, `CheckPartyMove WHIRLPOOL` then `CheckEngineFlag ENGINE_GLACIERBADGE`) | GLACIERBADGE + a party member that knows WHIRLPOOL | beat Pryce |
| Rage Candy Bar merchant trip-wire | `maps/MahoganyTown.asm` coord events `19,8`/`19,9` on scene 0 | scene `SCENE_MAHOGANYTOWN_TRY_RAGECANDYBAR` | only cleared later, by `RadioTowerRocketsScript` `setmapscene MAHOGANY_TOWN, SCENE_MAHOGANYTOWN_NOOP` |

---

## 4. Bot checklist

Coordinates are `(x, y)` map cells as written in the asm. "talk" = face the target
and press A.

1. `MAHOGANY_TOWN`: warp 4 at `(15,13)` -> `MAHOGANY_POKECENTER_1F`; talk to nurse at `(3,1)`. Pre: none. Post: party healed.
2. `MAHOGANY_TOWN`: warp 1 at `(11,7)` -> `MAHOGANY_MART_1F`. Pre: `EVENT_DECIDED_TO_HELP_LANCE` set and map scene = 1. Post: `MahoganyMart1FLanceUncoversStaircaseScript` runs unattended; wait for `EVENT_UNCOVERED_STAIRCASE_IN_MAHOGANY_MART`.
3. `MAHOGANY_MART_1F`: walk to `(7,3)` -> `TEAM_ROCKET_BASE_B1F` warp 1, arriving at `(27,2)`.
4. B1F: walk west along y=2. Crossing `(24,2)` or `(24,3)` fires `SecurityCamera1a/1b` -> battle `GRUNTM_20` then `GRUNTM_21`. Post: `EVENT_SECURITY_CAMERA_1`.
5. B1F: item ball at `(27,6)` = HYPER_POTION. Post: `EVENT_TEAM_ROCKET_BASE_B1F_HYPER_POTION`.
6. B1F: continue west; `(6,2)`/`(6,3)` fires camera 2, `(24,6)`/`(24,7)` camera 3, `(22,16)` camera 4, `(8,16)` camera 5. Each is the same two grunts.
7. B1F: talk to `GRUNTM_16` at `(2,4)` (sight 3, faces RIGHT - approaching from the east triggers him). Post: `EVENT_BEAT_ROCKET_GRUNTM_16`.
8. B1F: cross the trap field x1..5 / y7..13 using only the safe cells listed in section 2, or accept the one-shot `BATTLETYPE_TRAP` battles. Optional: hidden REVIVE by facing `(3,11)`.
9. B1F: battle `SCIENTIST JED` at `(18,12)` (sight 3, faces LEFT). Post: `EVENT_BEAT_SCIENTIST_JED`. Talk again for the warp-panel hint.
10. B1F: stand at `(19,12)`, face UP, press A on the bg event at `(19,11)`. Post: `EVENT_TURNED_OFF_SECURITY_CAMERAS` + `EVENT_SECURITY_CAMERA_1..5`.
11. B1F: item balls `(21,12)` = X_ACCURACY, `(14,15)` = NUGGET.
12. B1F: walk to `(3,14)` -> `TEAM_ROCKET_BASE_B2F` arriving at `(3,14)`.
13. B2F: step on `(5,14)` or `(4,13)`. Pre: map scene 0. Post: party healed, `EVENT_LANCE_HEALED_YOU_IN_TEAM_ROCKET_BASE`, scene -> 1.
14. B2F: battle `GRUNTM_19` at `(21,14)` (sight 4, faces LEFT), then `GRUNTM_17` at `(25,13)` (sight 3, faces DOWN).
15. B2F: walk to `(27,14)` -> `TEAM_ROCKET_BASE_B3F` arriving at `(27,14)`. Pre: none. Post: `LanceGetPasswordScript` auto-runs, scene -> 1, `EVENT_TEAM_ROCKET_BASE_B3F_LANCE_PASSWORDS`.
16. B3F: item balls `(28,9)` = PROTEIN, `(17,2)` = ICE_HEAL.
17. B3F: battle `SCIENTIST ROSS` at `(25,12)` (sight 4, faces LEFT).
18. B3F: walk to `(21,8)` and talk UP to `GRUNTF_5` at `(21,7)` - **sight 0, she will not initiate**. Post: `EVENT_BEAT_ROCKET_GRUNTF_5`; talk again -> `EVENT_LEARNED_SLOWPOKETAIL`.
19. B3F: battle `SCIENTIST MITCH` at `(14,15)` (sight 3, faces UP).
20. B3F: battle `GRUNTM_28` at `(5,15)` (sight 3, spinning). Post: `EVENT_BEAT_ROCKET_GRUNTM_28`; talk again -> `EVENT_LEARNED_RATICATE_TAIL`.
21. B3F: item balls `(3,12)` = DIRE_HIT, `(1,12)` = FULL_HEAL.
22. B3F: walk to `(27,2)` -> `TEAM_ROCKET_BASE_B2F` arriving at `(27,2)`.
23. B2F top corridor: walk west along y=1..2; battle `GRUNTM_18` at `(2,1)` (sight 3, faces RIGHT).
24. B2F: walk to `(3,2)` -> `TEAM_ROCKET_BASE_B3F` arriving at `(3,2)`.
25. B3F left region: walk to `(8,10)`. Pre: scene 1. Post: rival cutscene, no battle, scene -> 2, `EVENT_RIVAL_TEAM_ROCKET_BASE` set by `disappear`.
26. B3F: stand at `(10,10)` or `(11,10)`, face UP, press A on the bg event at `(10,9)`/`(11,9)`. Pre: both password events. Post: `EVENT_OPENED_DOOR_TO_GIOVANNIS_OFFICE`, block at `(10,8)` becomes floor.
27. B3F: step onto `(10,8)` or `(11,8)`. Pre: scene 2. Post: auto-walk, battle `EXECUTIVEM_4`, `EVENT_BEAT_ROCKET_EXECUTIVEM_4`, scene -> 3.
28. B3F: talk to the bird object at `(7,2)`. Post: `EVENT_LEARNED_HAIL_GIOVANNI`.
29. B3F: walk to `(3,6)` -> `TEAM_ROCKET_BASE_B2F` arriving at `(3,6)`; item ball `(3,10)` = TM_THIEF (TM46). Return via `(3,6)`.
30. Back-track: B3F `(3,2)` -> B2F `(3,2)`; B2F top corridor east to `(27,2)` -> B3F `(27,2)`; B3F right region south to `(27,14)` -> B2F `(27,14)`; walk west to the door.
31. B2F: stand at `(14,13)`/`(15,13)`, face UP, press A on `(14,12)`/`(15,12)`. Pre: `EVENT_LEARNED_HAIL_GIOVANNI`. Post: `EVENT_OPENED_DOOR_TO_ROCKET_HIDEOUT_TRANSMITTER`, block becomes floor.
32. B2F: step onto `(14,11)` or `(15,11)`. Pre: scene 1. Post: `EXECUTIVEF_2` battle, `EVENT_BEAT_ROCKET_EXECUTIVEF_2`, scene -> 2, Lance briefing.
33. B2F: talk to the three left Electrodes at `(7,5)`, `(7,7)`, `(7,9)`. Each is a wild ELECTRODE L23 that may Selfdestruct. Do **not** walk east past x=12 (`RocketBaseLancesSideScript` bounces you back). Post: three `EVENT_TEAM_ROCKET_BASE_B2F_ELECTRODE_n`.
34. After the third, `RocketBaseElectrodeScript` auto-runs: accept `HM_WHIRLPOOL`. Post: `EVENT_GOT_HM06_WHIRLPOOL`, `EVENT_CLEARED_ROCKET_HIDEOUT`, `EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_GYM`, `clearflag ENGINE_ROCKET_SIGNAL_ON_CH20`, scene -> 3.
35. Exit: B2F `(3,14)` -> B1F `(3,14)`; B1F warp panel `(5,15)` -> `(25,2)`; `(27,2)` -> mart; mart `(3,7)`/`(4,7)` -> town.
36. `MAHOGANY_TOWN`: heal at the Pokecenter, then warp 3 at `(6,13)` -> `MAHOGANY_GYM`, arriving at `(4,17)`/`(5,17)`. Pre: `EVENT_MAHOGANY_TOWN_POKEFAN_M_BLOCKS_GYM` set (otherwise the fisher stands on `(6,14)`).
37. Gym: `UP`, `LEFT`, `LEFT`, `LEFT` -> `(0,16)`, Boarder Ronald spots you from `(0,17)`.
38. Gym: `UP`,`UP`,`RIGHT`,`DOWN`,`LEFT` -> `(2,5)`, Boarder Douglas at `(2,4)`. Talk again for the Pryce-waterfall line.
39. Gym: `DOWN`,`RIGHT` -> `(5,10)`, Boarder Brad at `(5,9)`.
40. Gym: `RIGHT`,`DOWN` -> `(9,16)`, Skier Clarissa at `(9,17)`.
41. Gym: `UP`,`UP`,`LEFT` -> `(4,7)`, Skier Roxanne at `(4,6)`.
42. Gym: `DOWN` -> `(4,14)`, then walk to `(2,14)`.
43. Gym: from `(2,14)`: `UP`,`UP`,`RIGHT`,`DOWN`,`LEFT`,`UP`,`RIGHT` -> `(5,4)`. Talk UP to Pryce at `(5,3)`.
44. Battle `PRYCE1`. Post: `EVENT_BEAT_PRYCE`, `ENGINE_GLACIERBADGE`, the five gym-trainer beat flags, `EVENT_GOT_TM16_ICY_WIND`, and (at 7 badges) `RadioTowerRocketsScript`.
45. Gym: leave via `(4,17)`/`(5,17)`.

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map headers / warps / coord events / bg events / objects for all six maps | `src/import/RomExtractorGen2.lua`, `src/world/gen2/Map.lua` | implemented (generic extraction, nothing map-specific needed) |
| Map scenes + `sdefer` scene scripts | `src/world/gen2/World.lua` (`World:scene`, `mapScenes`), `src/script/gen2/Vm.lua` (`sdefer`, `setscene`, `setmapscene`) | implemented |
| Coord-event trip-wires | `src/world/gen2/World.lua` (coord event dispatch) | implemented |
| `changeblock` (mart staircase, both password doors) | `src/script/gen2/Vm.lua:1006` - the comment cites `MahoganyMart1F`'s `changeblock 6, 2, $1e` and cell `(7,3)` by name | implemented |
| `BGEVENT_IFNOTSET` / `conditional_event` (both password doors) | `src/world/gen2/World.lua:5147 World:bgEventAt` only matches `(ev.kind or 0) == 0`; `src/world/gen2/HiddenItems.lua` handles kind 7 | **missing** - pressing A on the transmitter door or Giovanni's door does nothing in the port |
| Ice sliding (`STEP_ICE`, `CheckStandingOnIce` forced d-pad) | `src/world/gen2/Permissions.lua:128 ICE` exists but is only consumed by `FieldMoves.canEncounterWildMon`; `World:movePlayer` picks step frames from `Bike.stepFrames` only | **missing** - Mahogany Gym floor behaves as ordinary floor, so the puzzle and the trainer sight lines are wrong |
| Trainer sight range / approach | `src/world/gen2/Trainers.lua` (`Trainers.sees`, `Trainers.approach`) | implemented (`sight 0` on GruntF5 falls out naturally) |
| `itemball` / `hiddenitem` | `src/script/gen2/CallAsm.lua`, `src/world/gen2/HiddenItems.lua` | implemented |
| `verbosegiveitem HM_WHIRLPOOL` | `src/script/gen2/Vm.lua`, `src/script/gen2/Opcodes.lua` | implemented |
| Whirlpool field move + GLACIERBADGE gate | `src/world/gen2/FieldMoves.lua:109` (`WHIRLPOOL = "GLACIER"`), `.somethingToWhirlpool`, `.whirlpoolFromMenu`, `.tryWhirlpoolOW`, `WHIRLPOOL_BLOCKS` | implemented |
| `loadwildmon` + `BATTLETYPE_TRAP` | `src/world/gen2/World.lua:4587` (names "TRAP 9 (the Rocket base)"), `src/script/gen2/Vm.lua:699` | implemented |
| `special HealParty` / `FadeOutToWhite` / `FadeInFromWhite` / `PlayMapMusic` / `ReloadSpritesNoPalettes` / `FadeOutToBlack` / `FadeInFromBlack` / `RestartMapMusic` / `FadeOutMusic` | `src/script/gen2/Specials.lua:450, 992-1066` | implemented |
| `moveobject` / `appear` / `disappear` / `applymovement` / `follow` / `showemote` | `src/script/gen2/Vm.lua`, `src/script/gen2/Movement.lua`, `src/world/gen2/World.lua` | implemented |
| `jumpstd` (`TeamRocketOathScript`, `GymStatue1/2Script`, `PokecenterSignScript`, `RadioTowerRocketsScript`) | `src/script/gen2/Vm.lua:742`, `data/generated/std_scripts.lua` via `World.lua:635` | implemented (generic) |
| `readvar VAR_BADGES` for `MahoganyGymActivateRockets` | `src/world/gen2/World.lua:117,1240` | implemented |
| `specialphonecall SPECIALCALL_WEIRDBROADCAST` | `src/script/gen2/Vm.lua:1364` stores the id; `src/core/gen2/Phone.lua` delivers | implemented |
| `ENGINE_ROCKET_SIGNAL_ON_CH20` radio behaviour | `src/ui/gen2/Pokegear.lua:816-821, 1097` | implemented |
| Driver coverage for this stretch | `tests/drivers/gold_*.lua` - none touches Mahogany, the hideout or Pryce (`gold_icepath_boulder.lua` is the only Mahogany-adjacent one, and it is Ice Path boulders) | **missing** |

The two "missing" rows are the blocking ones: without `BGEVENT_IFNOTSET` the
hideout cannot be completed, and without ice sliding the gym cannot be crossed.

---

## 6. Unresolved / verify by hand

- **Floor labels in the walkthrough are wrong past the first password.** It says
  "go up the stairs at the upper-right part of the floor, then head left on Negative
  Floor 2 ... Head up the stairs to Negative Floor 1. Head right and then before you
  reach the locked door, your rival will come." The rival coord event
  (`8,10`) and Giovanni's office are both on **B3F**, not B1F. The route is
  B3F(right) -> B2F(top) -> B3F(left). Verified by flood-filling
  `maps/TeamRocketBaseB2F.blk` / `maps/TeamRocketBaseB3F.blk`: the four B2F warps
  and four B3F warps sit in disconnected rooms, and B2F warp 2 `(3,2)` reaches
  B3F `(3,2)` which is the region containing `8,10`.
- **Boarder Ronald's party order.** Walkthrough lists Seel 24 / Seel 24 / Dewgong 25;
  `data/trainers/parties.asm` `BOARDER (1)` is SEEL 24, DEWGONG 25, SEEL 24.
  Same three mon, different lead order. Same class of discrepancy for
  `GRUNTM_18` (walkthrough Rattata/Rattata/Zubat, asm Rattata/Zubat/Rattata).
- **Item list is incomplete.** The walkthrough's "Items in the Team Rocket Hideout"
  block lists six; the asm has ten: the six named plus `FULL_HEAL` and `DIRE_HIT`
  item balls on B3F (mentioned later in the prose) and two hidden items the
  walkthrough never mentions - `REVIVE` at B1F `(3,11)` and `FULL_HEAL` at B2F
  `(26,7)`.
- **"Every time you pass one of those statues, two Team Rocket grunts will fight
  you"** is right, but the walkthrough implies only two statues on the first floor.
  There are five (`bg_event` at `24,1`, `6,1`, `24,5`, `8,15`, `22,15`) with eight
  trigger cells, i.e. up to ten grunt battles if none are skipped.
- **`EVENT_TEAM_ROCKET_BASE_POPULATION` is dead.** It is the shared visibility flag
  of eleven base NPCs and is read by all eight `SecurityCamera*` scripts, but a
  full-tree grep finds no `setevent`, `clearevent` or `disappear` that writes it.
  Those `checkevent ... iftrue NoSecurityCamera` arms therefore never take, and the
  Rocket NPCs stay on the maps forever - including after the hideout is cleared.
  Flagged in case a bot author expects the base to empty out.
- **Lance's three right-hand Electrodes are never battled.** `RocketElectrodeN`
  disappears both members of a mirrored pair, and the objects at `22,5`/`22,7`/`22,9`
  point at the no-op `ObjectEvent` script. The walkthrough's "Lance runs to the right
  to take the Electrodes on the right" is flavour; the game just hides them.
- **Exact reachability of `19,11` (the secret switch)** was checked by collision
  (`19,11` is a WALL, `19,12` is FLOOR and in the single B1F region), but the
  in-game facing direction for the `BGEVENT_READ` was not observed running - the
  bg event type is `BGEVENT_READ`, not `BGEVENT_UP`, so any adjacent facing should
  work; worth confirming on hardware if a driver misses it.
- The gym slide table in section 2 was produced by simulating
  `engine/overworld/player_movement.asm`'s ice rule against the decoded
  `maps/MahoganyGym.blk`, treating NPCs as blockers. It reproduces every direction
  string in the walkthrough, but it has not been executed in an emulator.

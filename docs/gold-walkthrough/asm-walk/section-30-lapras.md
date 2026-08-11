# Section 30 - Lapras

Source: `../section-30-lapras.txt`
Maps covered: `MAP_UNION_CAVE_1F`, `MAP_UNION_CAVE_B1F`, `MAP_UNION_CAVE_B2F`
(approach only: `MAP_ROUTE_32`, whose warp into the cave is cited but which
belongs to section 03)
Badges / key milestones in this section: no badge. The milestone is the **static
level-20 Lapras** on Union Cave B2F, which only exists on a Friday and only once
per in-game day (`ENGINE_UNION_CAVE_LAPRAS`). Five optional trainers
(Andrew, Calvin, Nick, Gwen, Emma) and two item balls sit on the way in.

This is a *revisit* section: Union Cave 1F/B1F were first walked in section 03.
Everything here is reachable only with Surf, i.e. after the Fog Badge.

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `MAP_ROUTE_32` | `maps/Route32.asm` | walked south from Violet City (`connection south, Route32, ROUTE_32, 0` in `data/maps/attributes.asm`) | `warp_event  6, 79, UNION_CAVE_1F, 4` | "head to Violet City and then go south through Route 32 into Union Cave" |
| 2 | `MAP_UNION_CAVE_1F` | `maps/UnionCave1F.asm` | warp 4 at `17, 3` (from Route 32) | `warp_event  3, 33, UNION_CAVE_B1F, 4` | walk past Daniel / Russell / Bill, surf the south-west lake, take the bottom-left ladder |
| 3 | `MAP_UNION_CAVE_B1F` | `maps/UnionCaveB1F.asm` | warp 4 at `3, 33` | `warp_event 17, 31, UNION_CAVE_B2F, 1` | Pokemaniac Andrew stands at `5, 32` right next to the arrival ladder; surf east to Calvin at `17, 30`, then the ladder beside him |
| 4 | `MAP_UNION_CAVE_B2F` | `maps/UnionCaveB2F.asm` | warp 1 at `5, 3` | same warp back up, or Escape Rope / Dig | Hyper Potion, Nick, Gwen, Emma, then the Lapras object at `11, 31` |

The walkthrough ends inside Union Cave B2F ("You can then use Escape Rope to
leave Union Cave"); it does not spill into a neighbouring section's map.

## 2. Maps

### MAP_UNION_CAVE_1F

- Script: `maps/UnionCave1F.asm`
- Blocks: `maps/UnionCave1F.blk`
- Header: `data/maps/maps.asm:107` -> `map UnionCave1F, TILESET_CAVE, CAVE, LANDMARK_UNION_CAVE, MUSIC_UNION_CAVE, TRUE, PALETTE_NITE, FISHGROUP_LAKE`
  (the `TRUE` field is the phone-service flag: **no phone calls in Union Cave**)
- Dimensions: `constants/map_constants.asm:94` -> `map_const UNION_CAVE_1F, 10, 18` (10x18 blocks = 20x36 walk cells)
- Attributes: `data/maps/attributes.asm:426` -> `map_attributes UnionCave1F, UNION_CAVE_1F, $09`
- Connections: none (no `connection` rows follow the attributes line)
- Map group: `MapGroup_Dungeons` (`data/maps/maps.asm:77`)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 19 | `UNION_CAVE_B1F` | 3 |
| 2 | 3 | 33 | `UNION_CAVE_B1F` | 4 |
| 3 | 17 | 31 | `ROUTE_33` | 1 |
| 4 | 17 | 3 | `ROUTE_32` | 4 |

**Coord events** (`def_coord_events`)

None - the block is empty.

**BG events** (`def_bg_events`)

None. (`UnionCave1FUnusedSign` / `UnionCave1FUnusedSignText` exist in the file
but are marked `; unreferenced` and are not in any `bg_event` row.)

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `UNIONCAVE1F_POKEFAN_M1` | `SPRITE_POKEFAN_M` | 4 | 4 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER`, sight 1 | `TrainerHikerDaniel` | -1 |
| `UNIONCAVE1F_SUPER_NERD` | `SPRITE_SUPER_NERD` | 4 | 21 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerPokemaniacLarry` | -1 |
| `UNIONCAVE1F_POKEFAN_M2` | `SPRITE_POKEFAN_M` | 15 | 8 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerHikerRussell` | -1 |
| `UNIONCAVE1F_FISHER1` | `SPRITE_FISHER` | 16 | 31 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerFirebreatherRay` | -1 |
| `UNIONCAVE1F_FISHER2` | `SPRITE_FISHER` | 15 | 15 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerFirebreatherBill` | -1 |
| `UNIONCAVE1F_POKE_BALL1` | `SPRITE_POKE_BALL` | 17 | 21 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCave1FGreatBall` | `EVENT_UNION_CAVE_1F_GREAT_BALL` |
| `UNIONCAVE1F_POKE_BALL2` | `SPRITE_POKE_BALL` | 4 | 2 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCave1FPotion` | `EVENT_UNION_CAVE_1F_POTION` |
| `UNIONCAVE1F_POKE_BALL3` | `SPRITE_POKE_BALL` | 4 | 17 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCave1FXAttack` | `EVENT_UNION_CAVE_1F_X_ATTACK` |
| `UNIONCAVE1F_POKE_BALL4` | `SPRITE_POKE_BALL` | 12 | 33 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCave1FAwakening` | `EVENT_UNION_CAVE_1F_AWAKENING` |

**Scripts of interest**

- `UnionCave1F_MapScripts` - `def_scene_scripts` and `def_callbacks` are both
  empty. Nothing on 1F is time- or flag-gated; the floor is pure walking.
- `PokemaniacLarryAfterBattleText` and `FirebreatherBillAfterBattleText` are the
  in-game hints the walkthrough is acting on: *"Every Friday, you can hear
  #MON roars from deep inside the cave."* and *"On weekends, you can hear
  strange roars from deep in the cave."* Only Larry's Friday line matches the
  code (see B2F callback below).

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_UNION_CAVE_1F_GREAT_BALL` | `constants/event_flags.asm` | itemball object row | set once the ball is taken; masks the object |
| `EVENT_UNION_CAVE_1F_POTION` | `constants/event_flags.asm` | itemball object row | same |
| `EVENT_UNION_CAVE_1F_X_ATTACK` | `constants/event_flags.asm` | itemball object row | same |
| `EVENT_UNION_CAVE_1F_AWAKENING` | `constants/event_flags.asm` | itemball object row | same |
| `EVENT_BEAT_HIKER_DANIEL`, `EVENT_BEAT_HIKER_RUSSELL`, `EVENT_BEAT_POKEMANIAC_LARRY`, `EVENT_BEAT_FIREBREATHER_BILL`, `EVENT_BEAT_FIREBREATHER_RAY` | `constants/event_flags.asm` | 3rd argument of each `trainer` macro row | set = already beaten, no eyesight trigger |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `GREAT_BALL` | item ball at 17,21 | `UnionCave1FGreatBall` (`itemball GREAT_BALL`) | `EVENT_UNION_CAVE_1F_GREAT_BALL` |
| `POTION` | item ball at 4,2 | `UnionCave1FPotion` | `EVENT_UNION_CAVE_1F_POTION` |
| `X_ATTACK` | item ball at 4,17 | `UnionCave1FXAttack` | `EVENT_UNION_CAVE_1F_X_ATTACK` |
| `AWAKENING` | item ball at 12,33 | `UnionCave1FAwakening` | `EVENT_UNION_CAVE_1F_AWAKENING` |

**Trainers** (all optional on this pass; the walkthrough only mentions walking past them)

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `HIKER`, `DANIEL` | `HIKER` | `DANIEL` | `"DANIEL@"` | `TrainerHikerDaniel` | phone service disabled on this map (`TRUE` in the header) |
| `HIKER`, `RUSSELL` | `HIKER` | `RUSSELL` | `"RUSSELL@"` | `TrainerHikerRussell` | as above |
| `POKEMANIAC`, `LARRY` | `POKEMANIAC` | `LARRY` | `"LARRY@"` | `TrainerPokemaniacLarry` | as above |
| `FIREBREATHER`, `BILL` | `FIREBREATHER` | `BILL` | `"BILL@"` | `TrainerFirebreatherBill` | as above |
| `FIREBREATHER`, `RAY` | `FIREBREATHER` | `RAY` | `"RAY@"` | `TrainerFirebreatherRay` | as above |

(Party rows for these five were not transcribed - they belong to section 03 and
the walkthrough tells the bot to walk past them, not fight them.)

**Wild encounters**

Grass/cave, `data/wild/johto_grass.asm:444` `def_grass_wildmons UNION_CAVE_1F`,
rate `6 percent` for morn/day/nite alike. Gold list (identical across all three
time slots):

| slot | level | species |
|---|---|---|
| 1 | 6 | `GEODUDE` |
| 2 | 6 | `SANDSHREW` (Silver: `RATTATA`) |
| 3 | 5 | `ZUBAT` |
| 4 | 4 | `RATTATA` |
| 5 | 7 | `ZUBAT` |
| 6 | 6 | `ONIX` |
| 7 | 6 | `ONIX` |

Water, `data/wild/johto_water.asm:12` `def_water_wildmons UNION_CAVE_1F`, rate
`2 percent`: `15 WOOPER`, `20 QUAGSIRE`, `15 QUAGSIRE`.

Fishing group is `FISHGROUP_LAKE` (header row).

### MAP_UNION_CAVE_B1F

- Script: `maps/UnionCaveB1F.asm`
- Blocks: `maps/UnionCaveB1F.blk`
- Header: `data/maps/maps.asm:108` -> `map UnionCaveB1F, TILESET_CAVE, CAVE, LANDMARK_UNION_CAVE, MUSIC_UNION_CAVE, TRUE, PALETTE_NITE, FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:95` -> `map_const UNION_CAVE_B1F, 10, 18`
- Attributes: `data/maps/attributes.asm:427` -> `map_attributes UnionCaveB1F, UNION_CAVE_B1F, $09`
- Connections: none
- Symbols: `44:5415 UnionCaveB1F_MapScripts`, `44:56df UnionCaveB1F_MapEvents` (`pokegold.sym`)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 3 | `RUINS_OF_ALPH_OUTSIDE` | 7 |
| 2 | 3 | 11 | `RUINS_OF_ALPH_OUTSIDE` | 8 |
| 3 | 7 | 19 | `UNION_CAVE_1F` | 1 |
| 4 | 3 | 33 | `UNION_CAVE_1F` | 2 |
| 5 | 17 | 31 | `UNION_CAVE_B2F` | 1 |

**Coord events** (`def_coord_events`)

None.

**BG events** (`def_bg_events`)

None.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `UNIONCAVEB1F_POKEFAN_M1` | `SPRITE_POKEFAN_M` | 10 | 4 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER`, sight 1 | `TrainerHikerPhillip` | -1 |
| `UNIONCAVEB1F_POKEFAN_M2` | `SPRITE_POKEFAN_M` | 17 | 10 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerHikerLeonard` | -1 |
| `UNIONCAVEB1F_SUPER_NERD1` | `SPRITE_SUPER_NERD` | 5 | 32 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerPokemaniacAndrew` | -1 |
| `UNIONCAVEB1F_SUPER_NERD2` | `SPRITE_SUPER_NERD` | 17 | 30 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerPokemaniacCalvin` | -1 |
| `UNIONCAVEB1F_POKE_BALL1` | `SPRITE_POKE_BALL` | 2 | 16 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCaveB1FTMSwift` | `EVENT_UNION_CAVE_B1F_TM_SWIFT` |
| `UNIONCAVEB1F_BOULDER` | `SPRITE_BOULDER` | 7 | 10 | `SPRITEMOVEDATA_STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | `UnionCaveB1FBoulder` | -1 |
| `UNIONCAVEB1F_POKE_BALL2` | `SPRITE_POKE_BALL` | 17 | 23 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCaveB1FXDefend` | `EVENT_UNION_CAVE_B1F_X_DEFEND` |

**Scripts of interest**

- `UnionCaveB1F_MapScripts` - both `def_scene_scripts` and `def_callbacks` are
  empty. Nothing on B1F is gated.
- `TrainerPokemaniacAndrew` (`44:5417`) -
  `trainer POKEMANIAC, ANDREW, EVENT_BEAT_POKEMANIAC_ANDREW, PokemaniacAndrewSeenText, PokemaniacAndrewBeatenText, 0, .Script`.
  `.Script` is the boilerplate after-battle path:
  `endifjustbattled / opentext / writetext PokemaniacAndrewAfterBattleText / waitbutton / closetext / end`.
  No flags beyond the beaten flag, no items, no warps.
- `TrainerPokemaniacCalvin` (`44:542b`) - identical shape with
  `EVENT_BEAT_POKEMANIAC_CALVIN` and `PokemaniacCalvinAfterBattleText`
  ("You demonstrated on me!" is `PokemaniacCalvinBeatenText`, matching the
  walkthrough quote).
- `UnionCaveB1FBoulder` - `jumpstd StrengthBoulderScript`. Not on the
  walkthrough's path to Lapras (it sits at `7, 10`, up near the Ruins of Alph
  ladders), but it is the one Strength-gated object on the floor.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_POKEMANIAC_ANDREW` | `constants/event_flags.asm:751` | `TrainerPokemaniacAndrew` | set after the win; suppresses the eyesight trigger |
| `EVENT_BEAT_POKEMANIAC_CALVIN` | `constants/event_flags.asm:752` | `TrainerPokemaniacCalvin` | same |
| `EVENT_BEAT_HIKER_PHILLIP`, `EVENT_BEAT_HIKER_LEONARD` | `constants/event_flags.asm` | the two Hiker `trainer` rows | not on the Lapras path |
| `EVENT_UNION_CAVE_B1F_TM_SWIFT` | `constants/event_flags.asm` | itemball object row | one-time TM_SWIFT |
| `EVENT_UNION_CAVE_B1F_X_DEFEND` | `constants/event_flags.asm` | itemball object row | one-time X_DEFEND |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `TM_SWIFT` | item ball at 2,16 | `UnionCaveB1FTMSwift` | `EVENT_UNION_CAVE_B1F_TM_SWIFT` |
| `X_DEFEND` | item ball at 17,23 | `UnionCaveB1FXDefend` | `EVENT_UNION_CAVE_B1F_X_DEFEND` |

Neither is mentioned by the walkthrough; both are on the way to the B2F ladder.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `POKEMANIAC`, `ANDREW` | `POKEMANIAC` (`$1e`, `constants/trainer_constants.asm:245`) | `ANDREW` (id 2) | `"ANDREW@", TRAINERTYPE_NORMAL` at `data/trainers/parties.asm:1086`: L24 `MAROWAK`, L24 `MAROWAK` | `TrainerPokemaniacAndrew` | no phone (map header phone flag `TRUE`) |
| `POKEMANIAC`, `CALVIN` | `POKEMANIAC` | `CALVIN` (id 3) | `"CALVIN@", TRAINERTYPE_NORMAL` at `data/trainers/parties.asm:1092`: L26 `KANGASKHAN` | `TrainerPokemaniacCalvin` | no phone |
| `HIKER`, `PHILLIP` | `HIKER` | `PHILLIP` | `"PHILLIP@"` | `TrainerHikerPhillip` | off-path |
| `HIKER`, `LEONARD` | `HIKER` | `LEONARD` | `"LEONARD@"` | `TrainerHikerLeonard` | off-path |

`TRAINERTYPE_NORMAL` means level+species only: no custom moves, no held items.

Prize money: `POKEMANIAC` base reward is `db 15` (`data/trainers/attributes.asm:179`
`; Pokemaniac`). `ComputeTrainerReward` (`engine/battle/read_trainer_party.asm:300`)
computes `base * wCurPartyLevel` where the level is the **last** party row, and
`WinTrainerBattle` (`engine/battle/core.asm:2292`) pays that out four times
(`ld c, 4` at the `.okay` loop). So Andrew = 15*24*4 = **1440**, Calvin =
15*26*4 = **1560** - both match the walkthrough exactly.

**Wild encounters**

Grass/cave, `data/wild/johto_grass.asm:499` `def_grass_wildmons UNION_CAVE_B1F`,
rate `6 percent` morn/day/nite. Gold list (same in all three slots):

| slot | level | species |
|---|---|---|
| 1 | 8 | `GEODUDE` |
| 2 | 8 | `SANDSHREW` (Silver: `RATTATA`) |
| 3 | 7 | `ZUBAT` |
| 4 | 8 | `ONIX` |
| 5 | 9 | `ZUBAT` |
| 6 | 6 | `RATTATA` |
| 7 | 6 | `RATTATA` |

Water, `data/wild/johto_water.asm:19`, rate `2 percent`: `15 WOOPER`,
`20 QUAGSIRE`, `15 QUAGSIRE`.

### MAP_UNION_CAVE_B2F

This is the section's real content.

- Script: `maps/UnionCaveB2F.asm`
- Blocks: `maps/UnionCaveB2F.blk` (`2b:466d UnionCaveB2F_Blocks`)
- Header: `data/maps/maps.asm:109` -> `map UnionCaveB2F, TILESET_CAVE, CAVE, LANDMARK_UNION_CAVE, MUSIC_UNION_CAVE, TRUE, PALETTE_NITE, FISHGROUP_SHORE`
  (note: **`FISHGROUP_SHORE` here, not `FISHGROUP_LAKE` like the two floors above**)
- Dimensions: `constants/map_constants.asm:96` -> `map_const UNION_CAVE_B2F, 10, 18` (20x36 walk cells)
- Attributes: `data/maps/attributes.asm:428` -> `map_attributes UnionCaveB2F, UNION_CAVE_B2F, $09`
- Connections: none
- Symbols: `44:5759 UnionCaveB2F_MapScripts`, `44:575e UnionCaveB2FLaprasCallback`, `44:5770 UnionCaveLapras`, `44:59cb UnionCaveB2F_MapEvents`, `25:595d UnionCaveB2F_MapAttributes`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 3 | `UNION_CAVE_B1F` | 5 |

One warp. There is no second exit: leaving is either back up this ladder, or
Escape Rope / Dig (the walkthrough's suggestion).

**Coord events** (`def_coord_events`)

None - the block is empty. Nothing on B2F is a trip-wire; every event is an
object you walk into the sight line of or press A on.

**BG events** (`def_bg_events`)

None.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `UNIONCAVEB2F_ROCKER` | `SPRITE_ROCKER` | 17 | 23 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 5, `PAL_NPC_RED` | `TrainerCooltrainermNick` | -1 |
| `UNIONCAVEB2F_COOLTRAINER_F1` | `SPRITE_COOLTRAINER_F` | 5 | 13 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER`, sight 1, `PAL_NPC_RED` | `TrainerCooltrainerfGwen` | -1 |
| `UNIONCAVEB2F_COOLTRAINER_F2` | `SPRITE_COOLTRAINER_F` | 3 | 28 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 2, `PAL_NPC_RED` | `TrainerCooltrainerfEmma` | -1 |
| `UNIONCAVEB2F_POKE_BALL1` | `SPRITE_POKE_BALL` | 16 | 2 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCaveB2FElixer` | `EVENT_UNION_CAVE_B2F_ELIXER` |
| `UNIONCAVEB2F_POKE_BALL2` | `SPRITE_POKE_BALL` | 12 | 19 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `UnionCaveB2FHyperPotion` | `EVENT_UNION_CAVE_B2F_HYPER_POTION` |
| `UNIONCAVEB2F_LAPRAS` | `SPRITE_SURF` | 11 | 31 | `SPRITEMOVEDATA_SWIM_WANDER`, radius x=1 y=1, `PAL_NPC_BLUE` | `OBJECTTYPE_SCRIPT` | `UnionCaveLapras` | `EVENT_UNION_CAVE_B2F_LAPRAS` |

Notes a bot needs:

- Lapras uses `SPRITE_SURF` (`constants/sprite_constants.asm:87`, id 53) - the
  same overworld sprite the player rides. It is not a Lapras sprite.
- `SPRITEMOVEDATA_SWIM_WANDER` with radius 1,1 means the object **drifts within
  one cell of `11, 31`**. A driver must not hard-code an exact tile to face; it
  should walk to the neighbourhood and press A at whichever adjacent water cell
  the sprite is occupying.
- Its event flag is `EVENT_UNION_CAVE_B2F_LAPRAS`. `CheckObjectFlag`
  (`engine/overworld/map_objects_2.asm:31`) masks an object when the flag is
  **set**, so "Lapras present" = flag clear.

**Scripts of interest**

`UnionCaveB2F_MapScripts` (`44:5759`)

```
	def_scene_scripts          ; empty
	def_callbacks
	callback MAPCALLBACK_OBJECTS, UnionCaveB2FLaprasCallback
```

`UnionCaveB2FLaprasCallback` (`44:575e`) - the whole Friday rule, six opcodes:

```
	checkflag ENGINE_UNION_CAVE_LAPRAS
	iftrue .NoAppear
	readvar VAR_WEEKDAY
	ifequal FRIDAY, .Appear
.NoAppear:
	disappear UNIONCAVEB2F_LAPRAS
	endcallback
.Appear:
	appear UNIONCAVEB2F_LAPRAS
	endcallback
```

Control flow, spelled out:

1. `checkflag ENGINE_UNION_CAVE_LAPRAS` - a **daily** engine flag
   (`constants/engine_flags.asm:107`, in the `wDailyFlags2` block; bit
   `DAILYFLAGS2_UNION_CAVE_LAPRAS_F` = 1, `constants/ram_constants.asm:315`).
   Set means "already caught/fought it today" -> `.NoAppear`.
2. `readvar VAR_WEEKDAY` (`constants/script_constants.asm:59`, id `$0b`) then
   `ifequal FRIDAY` (`constants/ram_constants.asm:218`, `FRIDAY` = 5, Sunday-based).
   Only Friday reaches `.Appear`.
3. `appear` clears the object's event flag (`Script_appear`,
   `engine/overworld/scripting.asm:879`, `ld b, 0 ; clear`); `disappear` sets it
   (`Script_disappear`, `:887`, `ld b, 1 ; set`).

Because the callback is `MAPCALLBACK_OBJECTS`, it re-runs on **every map load**
of B2F (`engine/overworld/map_setup.asm:81` `farcall LoadObjectMasks` follows
it). So a bot that walks out and back in on a non-Friday will find Lapras gone.

`UnionCaveLapras` (`44:5770`) - the encounter itself:

```
	faceplayer
	cry LAPRAS
	loadwildmon LAPRAS, 20
	startbattle
	disappear UNIONCAVEB2F_LAPRAS
	setflag ENGINE_UNION_CAVE_LAPRAS
	reloadmapafterbattle
	end
```

Load-bearing details:

- `loadwildmon LAPRAS, 20` - a level **20 wild** Lapras, matching the
  walkthrough. There is no `writevar VAR_BATTLETYPE` here, so unlike Ho-Oh /
  Lugia / the Red Gyarados this is an **ordinary wild battle**: no forced item,
  no forced shiny, no `BATTLETYPE_CANLOSE` mercy.
- `disappear` and `setflag` run **unconditionally after the battle**, with no
  `iffalse` / `checkflag` guard on the outcome. So Lapras is consumed for the
  day whether you caught it, KO'd it, ran, or blacked out mid-battle. That is
  exactly why the walkthrough says to save first - a soft reset is the only
  recovery.
- `setflag ENGINE_UNION_CAVE_LAPRAS` is the daily flag, not a permanent event.
  `CheckDailyResetTimer` (`engine/overworld/time.asm:88`) zeroes `wDailyFlags1`
  and `wDailyFlags2` whole once a day has elapsed, so it comes back next Friday.

`TrainerCooltrainermNick` (`44:577f`), `TrainerCooltrainerfGwen` (`44:5793`),
`TrainerCooltrainerfEmma` (`44:57a7`) - all three are the plain
`trainer <class>, <id>, EVENT_BEAT_*, <seen>, <beaten>, 0, .Script` shape with
an `endifjustbattled / opentext / writetext ...AfterBattleText / waitbutton /
closetext / end` follow-up. No items, no warps, no flags beyond their own
`EVENT_BEAT_*`.

`CooltrainerfEmmaAfterBattleText` is the in-map hint for the whole section:
*"Just once a week, a #MON comes to the water's edge. / I wanted to see that
#MON..."*

`UnionCaveB2FElixer` = `itemball ELIXER`; `UnionCaveB2FHyperPotion` =
`itemball HYPER_POTION` (`macros/scripts/maps.asm:155`, two raw bytes
`db item, quantity`, not bytecode).

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_UNION_CAVE_LAPRAS` | `constants/engine_flags.asm:107` (backed by `data/events/engine_flags.asm:117` -> `wDailyFlags2` bit `DAILYFLAGS2_UNION_CAVE_LAPRAS_F`) | read by `UnionCaveB2FLaprasCallback`, set by `UnionCaveLapras` | "Lapras already used up today". Cleared wholesale by `CheckDailyResetTimer` (`engine/overworld/time.asm:88-97`) |
| `EVENT_UNION_CAVE_B2F_LAPRAS` | `constants/event_flags.asm:1282` | written by the callback's `appear`/`disappear` | object visibility mask. **Clear = visible** (`engine/overworld/map_objects_2.asm:31` `CheckObjectFlag`) |
| `VAR_WEEKDAY` | `constants/script_constants.asm:59` (`$0b`) | `readvar` in the callback | `wCurDay`, 0 = `SUNDAY` .. 6 = `SATURDAY`; `FRIDAY` = 5 (`constants/ram_constants.asm:218`) |
| `EVENT_BEAT_COOLTRAINERM_NICK` | `constants/event_flags.asm:857` | `TrainerCooltrainermNick` | beaten flag |
| `EVENT_BEAT_COOLTRAINERF_GWEN` | `constants/event_flags.asm:877` | `TrainerCooltrainerfGwen` | beaten flag |
| `EVENT_BEAT_COOLTRAINERF_EMMA` | `constants/event_flags.asm:891` | `TrainerCooltrainerfEmma` | beaten flag |
| `EVENT_UNION_CAVE_B2F_ELIXER` | `constants/event_flags.asm:1025` | itemball object row | one-time |
| `EVENT_UNION_CAVE_B2F_HYPER_POTION` | `constants/event_flags.asm:1026` | itemball object row | one-time |

There are no `SCENE_*` values on this map: `def_scene_scripts` is empty, so
`wMapScene` is never consulted here.

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `ELIXER` | item ball at 16,2 | `UnionCaveB2FElixer` (`itemball ELIXER`) | `EVENT_UNION_CAVE_B2F_ELIXER` |
| `HYPER_POTION` | item ball at 12,19 | `UnionCaveB2FHyperPotion` (`itemball HYPER_POTION`) | `EVENT_UNION_CAVE_B2F_HYPER_POTION` |

The walkthrough names only the Hyper Potion ("Land on the right side to grab a
Hyper Potion"). The Elixer at `16, 2` sits near the arrival ladder at `5, 3` and
is never mentioned - free pickup for a bot on the way in.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `COOLTRAINERM`, `NICK` | `COOLTRAINERM` (`$1b`, `constants/trainer_constants.asm:184`) | `NICK` (id 1) | `"NICK@", TRAINERTYPE_MOVES` at `data/trainers/parties.asm:742` | `TrainerCooltrainermNick` | no phone (map phone flag `TRUE`) |
| `COOLTRAINERF`, `GWEN` | `COOLTRAINERF` (`$1c`, `:205`) | `GWEN` (id 1) | `"GWEN@", TRAINERTYPE_NORMAL` at `:867` | `TrainerCooltrainerfGwen` | no phone |
| `COOLTRAINERF`, `EMMA` | `COOLTRAINERF` | `EMMA` (id 15) | `"EMMA@", TRAINERTYPE_NORMAL` at `:954` | `TrainerCooltrainerfEmma` | no phone |

Parties verbatim:

`NICK` (`TRAINERTYPE_MOVES` - custom movesets, no items):

| # | level | species | moves |
|---|---|---|---|
| 1 | 26 | `CHARMANDER` | `EMBER`, `SMOKESCREEN`, `RAGE`, `SCARY_FACE` |
| 2 | 26 | `SQUIRTLE` | `WITHDRAW`, `WATER_GUN`, `BITE`, `CURSE` |
| 3 | 26 | `BULBASAUR` | `LEECH_SEED`, `POISONPOWDER`, `SLEEP_POWDER`, `RAZOR_LEAF` |

`GWEN` (`TRAINERTYPE_NORMAL`):

| # | level | species |
|---|---|---|
| 1 | 26 | `EEVEE` |
| 2 | 22 | `FLAREON` |
| 3 | 22 | `VAPOREON` |
| 4 | 22 | `JOLTEON` |

`EMMA` (`TRAINERTYPE_NORMAL`): L28 `POLIWHIRL`, single mon.

Prize money (`base * last-party-level * 4`, see the B1F note): `COOLTRAINERM`
and `COOLTRAINERF` both have `db 12 ; base reward`
(`data/trainers/attributes.asm:161` `; Cooltrainerm`, `:167` `; Cooltrainerf`).
Nick = 12*26*4 = **1248**, Gwen = 12*22*4 = **1056** (last row is the L22
Jolteon), Emma = 12*28*4 = **1344**. All three match the walkthrough.

AI: both Cooltrainer classes carry the full
`AI_BASIC | AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_CAUTIOUS | AI_STATUS | AI_RISKY`
set and `SWITCH_SOMETIMES`; Pokemaniac is the weaker
`AI_BASIC | AI_SETUP | AI_OFFENSIVE | AI_AGGRESSIVE | AI_STATUS`. None of the
five hold items (`db NO_ITEM, NO_ITEM`).

**Wild encounters**

Grass/cave, `data/wild/johto_grass.asm:554` `def_grass_wildmons UNION_CAVE_B2F`,
rate `4 percent`. This table is **not** split by version, and all three
time-of-day slots are identical:

| slot | level | species |
|---|---|---|
| 1 | 22 | `ZUBAT` |
| 2 | 22 | `RATICATE` |
| 3 | 22 | `GOLBAT` |
| 4 | 21 | `GEODUDE` |
| 5 | 20 | `RATTATA` |
| 6 | 23 | `ONIX` |
| 7 | 23 | `ONIX` |

Water (the surf legs the walkthrough spends most of its time on),
`data/wild/johto_water.asm:26` `def_water_wildmons UNION_CAVE_B2F`, rate
`4 percent` (double the 1F/B1F water rate):

| slot | level | species |
|---|---|---|
| 1 | 15 | `TENTACOOL` |
| 2 | 20 | `QUAGSIRE` |
| 3 | 20 | `TENTACRUEL` |

Fishing group is `FISHGROUP_SHORE` (`data/maps/maps.asm:109`). No headbutt or
rock-smash tables apply - it is a cave with no trees.

The walkthrough's Max Repel advice: `REPEL_STEPS` in the port mirrors
`RepelEffect / SuperRepelEffect / MaxRepelEffect`; MAX_REPEL is 250 steps. With
the B2F encounters capped at level 23 and the lead mon typically above that,
Repel suppresses essentially all of the grass rolls.

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Cannot cross any of the water on 1F / B1F / B2F | `engine/events/overworld.asm:322` `SurfFunction.TrySurf` (`ld de, ENGINE_FOGBADGE / call CheckBadge / jr c, .nofogbadge`), and the walk-into-water path `TrySurfOW` at `:469` | **Fog Badge** plus a party mon that knows `SURF` | beat Morty in Ecruteak Gym (section 07) |
| Lapras object is absent 6 days out of 7 | `maps/UnionCaveB2F.asm:15` `UnionCaveB2FLaprasCallback` -> `readvar VAR_WEEKDAY / ifequal FRIDAY` | in-game weekday must equal `FRIDAY` (`constants/ram_constants.asm:218`, value 5) | set the GB clock / wait for Friday. Re-checked on every B2F map load (`MAPCALLBACK_OBJECTS`) |
| Lapras is absent again after one encounter | same callback, first two opcodes: `checkflag ENGINE_UNION_CAVE_LAPRAS / iftrue .NoAppear`; the flag is set by `UnionCaveLapras` | flag must be clear | `CheckDailyResetTimer` (`engine/overworld/time.asm:88`) zeroes `wDailyFlags1`+`wDailyFlags2` once a real day has passed |
| Lapras is consumed even on a failed attempt | `UnionCaveLapras`: `startbattle` is followed unconditionally by `disappear` + `setflag` - no `iffalse` on `wBattleResult` | none - this is the failure mode, not a gate | save before pressing A; soft-reset on a bad outcome |
| Only one way out of B2F | `maps/UnionCaveB2F.asm` `def_warp_events` has exactly one row (`5, 3 -> UNION_CAVE_B1F, 5`) | - | Escape Rope / Dig short-circuits the return walk (B2F's tileset is `TILESET_CAVE`) |
| Boulder at B1F `7, 10` | `UnionCaveB1FBoulder` -> `jumpstd StrengthBoulderScript` | Strength / Plain Badge | not on the Lapras path; noted for completeness |

Nothing in this section checks a badge count, a key item, or an `EVENT_*`
story flag. The only two real gates are **Surf** and **Friday**.

## 4. Bot checklist

Preconditions for the whole section: Fog Badge, a party mon with `SURF`, the
in-game weekday equal to `FRIDAY`, `ENGINE_UNION_CAVE_LAPRAS` clear, several
Ultra Balls, a status move (Sleep/Paralysis) and a **save written immediately
before the Lapras press**.

| # | Map | Target | Input intent | Precondition | Postcondition |
|---|---|---|---|---|---|
| 1 | `MAP_ROUTE_32` | warp at `6, 79` | walk onto the warp | on Route 32 | now in `MAP_UNION_CAVE_1F` at `17, 3` (warp 4) |
| 2 | `MAP_UNION_CAVE_1F` | - | use `MAX_REPEL` from the pack | have one | 250 steps of encounter suppression |
| 3 | `MAP_UNION_CAVE_1F` | avoid sight lines of `UNIONCAVE1F_POKEFAN_M2` (`15, 8`, sight 3, facing left) and `UNIONCAVE1F_FISHER2` (`15, 15`, sight 2, spinner) | walk south-west | - | `EVENT_BEAT_*` untouched if avoided; the spinner is not reliably avoidable, budget for the battle |
| 4 | `MAP_UNION_CAVE_1F` | south-west water | press A facing water, or walk into it (`TrySurfOW`) | Fog Badge + `SURF` | `wPlayerState = PLAYER_SURF` |
| 5 | `MAP_UNION_CAVE_1F` | warp 2 at `3, 33` | step onto it | - | now in `MAP_UNION_CAVE_B1F` at `3, 33` (warp 4) |
| 6 | `MAP_UNION_CAVE_B1F` | `UNIONCAVEB1F_SUPER_NERD1` at `5, 32` (facing left, sight 3) | walk into the sight line / talk | - | battle Pokemaniac Andrew (2x L24 Marowak); sets `EVENT_BEAT_POKEMANIAC_ANDREW`, +1440 |
| 7 | `MAP_UNION_CAVE_B1F` | surf east along the y~30 water | walk east on water | surfing | reach the eastern shelf |
| 8 | `MAP_UNION_CAVE_B1F` | `UNIONCAVEB1F_SUPER_NERD2` at `17, 30` (facing left, sight 3) | walk into the sight line | - | battle Pokemaniac Calvin (L26 Kangaskhan); sets `EVENT_BEAT_POKEMANIAC_CALVIN`, +1560 |
| 9 | `MAP_UNION_CAVE_B1F` | optional item ball `17, 23` | press A | `EVENT_UNION_CAVE_B1F_X_DEFEND` clear | `X_DEFEND` in bag, flag set |
| 10 | `MAP_UNION_CAVE_B1F` | warp 5 at `17, 31` | step onto it | - | now in `MAP_UNION_CAVE_B2F` at `5, 3`; `MAPCALLBACK_OBJECTS` runs `UnionCaveB2FLaprasCallback` |
| 11 | `MAP_UNION_CAVE_B2F` | **assert** `UNIONCAVEB2F_LAPRAS` is present | read the object list | weekday == FRIDAY and `ENGINE_UNION_CAVE_LAPRAS` clear | if absent, abort the run - nothing later will fix it |
| 12 | `MAP_UNION_CAVE_B2F` | item ball `16, 2` | press A | `EVENT_UNION_CAVE_B2F_ELIXER` clear | `ELIXER` in bag (walkthrough omits this one) |
| 13 | `MAP_UNION_CAVE_B2F` | surf south from the entrance shelf | walk south on water | surfing | approach the y~19-23 shelves |
| 14 | `MAP_UNION_CAVE_B2F` | item ball `12, 19` (right-hand shore) | land, press A | `EVENT_UNION_CAVE_B2F_HYPER_POTION` clear | `HYPER_POTION` in bag |
| 15 | `MAP_UNION_CAVE_B2F` | `UNIONCAVEB2F_ROCKER` at `17, 23` (facing left, sight 5 - the longest on the floor) | walk into the sight line | - | battle Cooltrainer Nick (L26 Charmander/Squirtle/Bulbasaur, custom moves); sets `EVENT_BEAT_COOLTRAINERM_NICK`, +1248 |
| 16 | `MAP_UNION_CAVE_B2F` | cross to the left shore, head north to `UNIONCAVEB2F_COOLTRAINER_F1` at `5, 13` (spinner, sight 1) | walk adjacent | - | battle Cooltrainer Gwen (L26 Eevee, L22 Flareon/Vaporeon/Jolteon); sets `EVENT_BEAT_COOLTRAINERF_GWEN`, +1056 |
| 17 | `MAP_UNION_CAVE_B2F` | walk the left path south to `UNIONCAVEB2F_COOLTRAINER_F2` at `3, 28` (facing down, sight 2) | walk into the sight line | - | battle Cooltrainer Emma (L28 Poliwhirl); sets `EVENT_BEAT_COOLTRAINERF_EMMA`, +1344 |
| 18 | `MAP_UNION_CAVE_B2F` | **save** | open menu -> SAVE | Lapras still present | recoverable checkpoint |
| 19 | `MAP_UNION_CAVE_B2F` | surf east/south-east from `3, 28` toward `11, 31` | walk on water | surfing | the Lapras object drifts within +/-1 cell of `11, 31` (`SWIM_WANDER`, radius 1,1) - re-scan its live position each step |
| 20 | `MAP_UNION_CAVE_B2F` | press A facing `UNIONCAVEB2F_LAPRAS` | talk | object present | `UnionCaveLapras` runs: `cry LAPRAS`, `loadwildmon LAPRAS, 20`, `startbattle` |
| 21 | battle | L20 wild Lapras | inflict sleep/paralysis, chip to yellow/red, throw `ULTRA_BALL`s | - | on any exit: `disappear` + `setflag ENGINE_UNION_CAVE_LAPRAS`, then `reloadmapafterbattle` |
| 22 | - | verify Lapras in party/box | read party | - | if not caught, **reload the step-18 save**; do not walk out and back in, the callback will not re-place it |
| 23 | `MAP_UNION_CAVE_B2F` | use `ESCAPE_ROPE` | pack -> use | in a cave tileset | back at the last Pokemon Center door |

Sight-line arithmetic for steps 6/8/15/16/17: `Trainers.sees` in the port
(`src/world/gen2/Trainers.lua:98`) is the transcription of `home/trainers.asm` -
the NPC must be facing the player's direction and the Chebyshev-free straight
distance must be `<= sight`.

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Union Cave 1F/B1F/B2F map data (headers, blocks, warps, objects) | `src/import/RomExtractorGen2.lua` (generic map/manifest extraction; per-map entries land in the private `data/generated/` cache) | implemented - data-driven, no per-map code |
| `MAPCALLBACK_OBJECTS` dispatch on map load | `src/world/gen2/World.lua:5700` (`self:runMapCallback("MAPCALLBACK_OBJECTS")`, deliberately *before* the sprite rebuild) | implemented |
| `readvar VAR_WEEKDAY` | `src/world/gen2/World.lua:101` (`VAR_WEEKDAY = 0x0b`) and `:1222` (`if varId == VAR_WEEKDAY then return self:weekday() end`) | implemented |
| `checkflag` / `setflag` on `ENGINE_*` | `src/script/gen2/Vm.lua:195` / `:208` | implemented |
| `ENGINE_UNION_CAVE_LAPRAS` as a daily flag | `src/core/gen2/Apricorns.lua:84` (`{ id = 88, name = "ENGINE_UNION_CAVE_LAPRAS" }` in the wDailyFlags1/2 id list) and `:344` (`save.dailyFlags = {}` on the daily wipe) | implemented |
| `appear` / `disappear` object masking | `src/script/gen2/Opcodes.lua:115-116`, consumed by the World object rebuild | implemented |
| `cry` | `src/script/gen2/Vm.lua:621` | implemented |
| `loadwildmon` + `startbattle` + `reloadmapafterbattle` (the whole static-encounter shape) | `src/script/gen2/Vm.lua:836`, `:817`, `:886` | implemented |
| Wild catch rate / Ultra Ball / status bonus | `src/battle/gen2/Catching.lua` (transcribes `PokeBallEffect`, including the two cart bugs) | implemented |
| Water encounter tables while surfing | `src/world/gen2/FieldMoves.lua:175` ("standing in a cave rolls the grass list; surfing rolls the water" ...) + `src/battle/gen2/Encounter.lua` | implemented |
| Surf gate on `ENGINE_FOGBADGE` | `src/world/gen2/FieldMoves.lua:106` (`SURF = "FOG"`) and `FieldMoves.surfFromMenu` at `:481` | implemented |
| Trainer eyesight approach + battle | `src/world/gen2/Trainers.lua:98` (`Trainers.sees`), `src/world/gen2/World.lua:5212` / `:5227` / `:5242` | implemented |
| Trainer prize money (base x level x 4, Mom's split) | `src/battle/gen2/Prize.lua:82` (`Prize.reward`), `:92` (`Prize.rewardLevel`) | implemented - and it already documents the `ld c, 4` that makes the walkthrough's figures right |
| Repel step counting (the Max Repel advice) | `src/world/gen2/World.lua:317` (`REPEL_STEPS = { REPEL = 100, SUPER_REPEL = 200, MAX_REPEL = 250 }`), `:3366` | implemented |
| **Item ball pickup** (`OBJECTTYPE_ITEMBALL`, i.e. the B2F Elixer / Hyper Potion and every ball on 1F/B1F) | extractor stores the item at `src/import/RomExtractorGen2.lua:2969` (`obj.itemball = readItemBall(...)`) and deliberately assigns **no** `scriptKey`; `World:talk` only dispatches on `npc.def.scriptKey` (`src/world/gen2/World.lua:5276`) | **missing** - no consumer of `obj.itemball` exists anywhere under `src/`. Pressing A on a Poke Ball object currently does nothing |
| Escape Rope from a cave | `src/ui/PartyMenu.lua:634` is the Gen 1 DIG/ESCAPE_ROPE path; no Gen 2 equivalent found under `src/core/gen2/` or `src/world/gen2/` | **unverified / likely missing for Gen 2** - a driver should warp out manually |
| A driver exercising the weekday-gated `MAPCALLBACK_OBJECTS` shape | `tests/drivers/gold_map_callbacks.lua:117-156` covers the same pattern on Route 29 (Tuscany, Tuesday) | implemented for the pattern, **not** for Union Cave B2F specifically - no `tests/drivers/gold_*` driver mentions Union Cave or Lapras |

Honest summary: everything the Lapras encounter itself needs is in place
(callback dispatch, weekday var, daily flags, `loadwildmon`/`startbattle`,
catching). The two gaps that would bite a bot on this route are **item balls
are not pickable** and **no Gen 2 Escape Rope**, neither of which blocks Lapras.

## 6. Unresolved / verify by hand

- **"Lapras only appears on Friday" vs. the 1F NPC hints.** The code checks
  exactly `FRIDAY` (`UnionCaveB2FLaprasCallback`). But
  `FirebreatherBillAfterBattleText` on 1F says *"On weekends, you can hear
  strange roars from deep in the cave"* while `PokemaniacLarryAfterBattleText`
  says *"Every Friday"*. Larry is right, Bill's line is flavour that contradicts
  the callback. The walkthrough follows Larry and is correct.
- **"once you've gotten HM Surf".** The asm imposes no HM/badge check on the
  Lapras callback or on `UnionCaveLapras`; Surf is a *reachability* requirement
  (B2F's Lapras sits at `11, 31` surrounded by water and the approach legs on
  1F/B1F cross water), enforced only by `SurfFunction.TrySurf`'s
  `ENGINE_FOGBADGE` check. The walkthrough's phrasing implies a scripted gate
  that does not exist.
- **EXP figures.** The walkthrough quotes per-mon EXP (637 for a L24 Marowak,
  975 for a L26 Kangaskhan, 355/511/924/928/933/786, and two "?" entries). EXP
  is computed at runtime from base EXP x level, not stored per trainer, so none
  of these could be pinned to a table row. They are plausible but unverified
  here; `data/pokemon/base_stats/*.asm` would be the place to check.
- **Party ordering.** The walkthrough lists Nick as Charmander / Bulbasaur /
  Squirtle and Gwen as Eevee / Vaporeon / Jolteon / Flareon. `parties.asm` has
  Nick as Charmander / **Squirtle** / **Bulbasaur** (`:742`) and Gwen as Eevee /
  **Flareon** / **Vaporeon** / **Jolteon** (`:867`). The sets match; the order
  does not. A bot planning lead matchups should use the asm order (it is also
  what decides the prize level: Gwen's last row is Jolteon L22).
- **"Head almost all the way through till you see the guy on the cliff still
  spinning around, which is the third trainer that you spot."** Read against the
  1F object table this is `UNIONCAVE1F_FISHER2` (Firebreather Bill,
  `15, 15`, `SPRITEMOVEDATA_SPINRANDOM_FAST`), with Hiker Daniel (`4, 4`) and
  Hiker Russell (`15, 8`) as the first two. That reading is an inference from
  coordinates and movement data, not something the asm states; the exact walking
  order depends on the `.blk` layout, which was not decoded here.
- **Which 1F ladder the walkthrough means.** "Down and to the left is a lake.
  Surf past it and head down the ladder" is read as 1F warp 2 (`3, 33` ->
  `UNION_CAVE_B1F` warp 4 at `3, 33`), because Andrew stands at B1F `5, 32`,
  immediately beside that arrival point. 1F warp 1 (`5, 19` -> B1F warp 3 at
  `7, 19`) would land nowhere near him. Verify against the block layout if a
  driver's pathing disagrees.
- **B2F "right side" / "left side" landings.** The prose distinguishes a right
  and a left shore; the object coordinates (`12, 19` Hyper Potion and `17, 23`
  Nick on the right, `5, 13` Gwen and `3, 28` Emma on the left) are consistent
  with that, but the actual water/land split comes from `UnionCaveB2F.blk`,
  which was not decoded.
- **Elixer at B2F `16, 2`.** Present in the asm, absent from the walkthrough.
  Not a contradiction, just an omission worth picking up.

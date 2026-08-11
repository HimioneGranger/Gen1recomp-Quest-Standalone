# Section 02 - Sprout Tower and Violet City Gym

Source: `../section-02-sprout-tower-and-violet-city-gym.txt`
Maps covered: `MAP_SPROUT_TOWER_1F`, `MAP_SPROUT_TOWER_2F`, `MAP_SPROUT_TOWER_3F`,
`MAP_VIOLET_CITY`, `MAP_VIOLET_POKECENTER_1F`, `MAP_VIOLET_GYM`
Badges / key milestones in this section: HM05 Flash (`EVENT_GOT_HM05_FLASH`),
the Sprout Tower rival cutscene (`EVENT_RIVAL_SPROUT_TOWER`), ZEPHYRBADGE
(`ENGINE_ZEPHYRBADGE`, `EVENT_BEAT_FALKNER`), TM31 Mud-Slap
(`EVENT_GOT_TM31_MUD_SLAP`).

All map constants below use the `MAP_*` spelling that both
`constants/map_constants.asm` and this port's map ids use; the port's
`World:setMap` takes exactly the bare constant name (`"SPROUT_TOWER_1F"`), which
is what `tools/rom_manifest_gold.json` -> `constants.mapGroups` stores.

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `MAP_SPROUT_TOWER_1F` | `maps/SproutTower1F.asm` | `MAP_VIOLET_CITY` warp 7 at (23,5) -> 1F warp 1 (9,15) | 1F warp 3 (6,4) -> 2F warp 1 | "Head up the stairs to Floor 2." |
| 2 | `MAP_SPROUT_TOWER_2F` | `maps/SproutTower2F.asm` | 2F warp 1 (6,4) | 2F warp 3 (17,3) -> 1F warp 5 | Sage Nico at (14,4), then "down the stairs" |
| 3 | `MAP_SPROUT_TOWER_1F` | `maps/SproutTower1F.asm` | 1F warp 5 (17,3) | 1F warp 4 (2,6) -> 2F warp 2 | Parlyz Heal ball at (16,7), then Sage Chow at (2,1) |
| 4 | `MAP_SPROUT_TOWER_2F` | `maps/SproutTower2F.asm` | 2F warp 2 (2,6) | 2F warp 4 (10,14) -> 3F warp 1 | X Defend ball at (3,1), Sage Edmond at (3,15) |
| 5 | `MAP_SPROUT_TOWER_3F` | `maps/SproutTower3F.asm` | 3F warp 1 (10,14) | 3F warp 1 (10,14) -> 2F warp 4 | Potion, Jin/Neal/Troy, rival cutscene, Sage Li, HM05, Escape Rope |
| 6 | `MAP_SPROUT_TOWER_2F` -> `MAP_SPROUT_TOWER_1F` | as above | 2F warp 4 / 1F warps 3-5 | 1F warp 1 (9,15) or warp 2 (10,15) -> `MAP_VIOLET_CITY` warp 7 | "Get out of the tower" (Escape Rope also legal: the tower is `DUNGEON`) |
| 7 | `MAP_VIOLET_CITY` | `maps/VioletCity.asm` | city warp 7 (23,5) | city warp 5 (31,25) | "go back to the Pokemon Center of Violet City" |
| 8 | `MAP_VIOLET_POKECENTER_1F` | `maps/VioletPokecenter1F.asm` | PC warp 1 (3,7) | PC warp 1/2 (3,7)/(4,7) | Heal at the nurse before the gym |
| 9 | `MAP_VIOLET_CITY` | `maps/VioletCity.asm` | city warp 5 (31,25) | city warp 2 (18,17) | "head northwest in the city to the Violet City Gym" |
| 10 | `MAP_VIOLET_GYM` | `maps/VioletGym.asm` | gym warp 1 (4,15) | gym warp 1/2 (4,15)/(5,15) -> `MAP_VIOLET_CITY` warp 2 | Abe, Rod, Falkner, ZEPHYRBADGE + TM31 |
| 11 | `MAP_VIOLET_CITY` | `maps/VioletCity.asm` | city warp 2 (18,17) | (section ends) | Section closes with the badge in hand |

Spills into the next section: beating Falkner runs `specialphonecall
SPECIALCALL_ASSISTANT` (`maps/VioletGym.asm`), whose Elm phone script
(`engine/phone/scripts/elm.asm`, `.assistant`) clears
`EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER` so the aide appears in
`MAP_VIOLET_POKECENTER_1F` with the Togepi egg, and sets
`SCENE_ROUTE32_OFFER_SLOWPOKETAIL` when the egg is taken. That whole beat
belongs to the next section; it is listed here only because the trigger lives
in this section's gym script.

## 2. Maps

### MAP_SPROUT_TOWER_1F

- Script: `maps/SproutTower1F.asm`
- Blocks: `maps/SproutTower1F.blk` (`data/maps/blocks.asm` -> `SproutTower1F_Blocks`)
- Header: `data/maps/maps.asm:79` -> `TILESET_TOWER`, `DUNGEON`,
  `LANDMARK_SPROUT_TOWER`, `MUSIC_SPROUT_TOWER`, phone `FALSE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions / attributes: `constants/map_constants.asm:66`
  (`map_const SPROUT_TOWER_1F, 10, 8`) = 20x16 cells;
  `data/maps/attributes.asm:398` (`map_attributes SproutTower1F, SPROUT_TOWER_1F, $00`)
- Connections: none (indoor/dungeon)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 15 | `VIOLET_CITY` | 7 |
| 2 | 10 | 15 | `VIOLET_CITY` | 7 |
| 3 | 6 | 4 | `SPROUT_TOWER_2F` | 1 |
| 4 | 2 | 6 | `SPROUT_TOWER_2F` | 2 |
| 5 | 17 | 3 | `SPROUT_TOWER_2F` | 3 |

**Coord events** (`def_coord_events`)

None (`def_coord_events` is empty).

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 7 | 15 | `BGEVENT_READ` | `SproutTower1FStatue` |
| 12 | 15 | `BGEVENT_READ` | `SproutTower1FStatue` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `SPROUTTOWER1F_SAGE1` | `SPRITE_SAGE` | 7 | 4 | `SPRITEMOVEDATA_STANDING_DOWN`, radius 0/0, pal `PAL_NPC_BLUE` | `OBJECTTYPE_SCRIPT`, sight 0 | `SproutTower1FSage1Script` | -1 |
| `SPROUTTOWER1F_SAGE2` | `SPRITE_SAGE` | 6 | 7 | `SPRITEMOVEDATA_WANDER`, radius 1/1, pal `PAL_NPC_BLUE` | `OBJECTTYPE_SCRIPT`, sight 0 | `SproutTower1FSage2Script` | -1 |
| `SPROUTTOWER1F_GRANNY` | `SPRITE_GRANNY` | 11 | 12 | `SPRITEMOVEDATA_STANDING_LEFT`, radius 0/0 | `OBJECTTYPE_SCRIPT`, sight 0 | `SproutTower1FGrannyScript` | -1 |
| `SPROUTTOWER1F_TEACHER` | `SPRITE_TEACHER` | 9 | 9 | `SPRITEMOVEDATA_STANDING_UP`, radius 0/0 | `OBJECTTYPE_SCRIPT`, sight 0 | `SproutTower1FTeacherScript` | -1 |
| `SPROUTTOWER1F_SAGE3` | `SPRITE_SAGE` | 2 | 1 | `SPRITEMOVEDATA_STANDING_RIGHT`, radius 0/0, pal `PAL_NPC_BLUE` | `OBJECTTYPE_TRAINER`, sight 1 | `TrainerSageChow` | -1 |
| `SPROUTTOWER1F_POKE_BALL` | `SPRITE_POKE_BALL` | 16 | 7 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL`, sight 0 | `SproutTower1FParlyzHeal` | `EVENT_SPROUT_TOWER_1F_PARLYZ_HEAL` |

**Scripts of interest**

- `TrainerSageChow` (`42:400e`): `trainer SAGE, CHOW, EVENT_BEAT_SAGE_CHOW,
  SageChowSeenText, SageChowBeatenText, 0, .Script`. Loss text is `0`. The
  after-battle arm `.Script` (`42:401a`) is `endifjustbattled` then a single
  `writetext SageChowAfterBattleText`.
- `SproutTower1FParlyzHeal` (`42:4022`): a bare `itemball PARLYZ_HEAL` - two raw
  bytes, **not** bytecode. Pickup is engine-side (`FindItemInBallScript`), gated
  on `EVENT_SPROUT_TOWER_1F_PARLYZ_HEAL`.
- Sage1/Sage2/Granny/Teacher are all `jumptextfaceplayer` one-liners; nothing to
  gate on.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_SAGE_CHOW` (1041) | `constants/event_flags.asm:518` | `TrainerSageChow` header word | Set once beaten; suppresses re-battle and the eyesight trigger |
| `EVENT_SPROUT_TOWER_1F_PARLYZ_HEAL` (1607) | `constants/event_flags.asm:1000` | object-event flag on `SPROUTTOWER1F_POKE_BALL` | Set = ball is gone (`CheckObjectFlag`, `engine/overworld/map_objects_2.asm`) |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `PARLYZ_HEAL` | Poke Ball object at (16,7) | `SproutTower1FParlyzHeal` (`itemball PARLYZ_HEAL`) | `EVENT_SPROUT_TOWER_1F_PARLYZ_HEAL` |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `SAGE`, `CHOW` | `SAGE` (38) | `CHOW` (1) | `SageGroup` "CHOW" (`0e:7324` group base): L3 Bellsprout x3, `TRAINERTYPE_NORMAL` | `TrainerSageChow` | none |

Prize money: `data/trainers/attributes.asm` "Sage" base reward `8`;
`ComputeTrainerReward` x last party level (3) x4 in `WinTrainerBattle` = 96.

**Wild encounters**

None. `data/wild/johto_grass.asm` has **no** `def_grass_wildmons SPROUT_TOWER_1F`
entry; only 2F and 3F have tables. 1F has no grass/water/fish/headbutt data.

---

### MAP_SPROUT_TOWER_2F

- Script: `maps/SproutTower2F.asm`
- Blocks: `maps/SproutTower2F.blk`
- Header: `data/maps/maps.asm:80` -> `TILESET_TOWER`, `DUNGEON`,
  `LANDMARK_SPROUT_TOWER`, `MUSIC_SPROUT_TOWER`, `FALSE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions / attributes: `constants/map_constants.asm:67`
  (`map_const SPROUT_TOWER_2F, 10, 8`) = 20x16 cells;
  `data/maps/attributes.asm:399`
- Connections: none

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 6 | 4 | `SPROUT_TOWER_1F` | 3 |
| 2 | 2 | 6 | `SPROUT_TOWER_1F` | 4 |
| 3 | 17 | 3 | `SPROUT_TOWER_1F` | 5 |
| 4 | 10 | 14 | `SPROUT_TOWER_3F` | 1 |

**Coord events** (`def_coord_events`)

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 12 | 15 | `BGEVENT_READ` | `SproutTower2FStatue` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `SPROUTTOWER2F_SAGE1` | `SPRITE_SAGE` | 14 | 4 | `SPRITEMOVEDATA_SPINRANDOM_FAST`, radius 0/0, pal `PAL_NPC_BLUE` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerSageNico` | -1 |
| `SPROUTTOWER2F_SAGE2` | `SPRITE_SAGE` | 3 | 15 | `SPRITEMOVEDATA_STANDING_UP`, radius 0/0, pal `PAL_NPC_BLUE` | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerSageEdmond` | -1 |
| `SPROUTTOWER2F_POKE_BALL` | `SPRITE_POKE_BALL` | 3 | 1 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL`, sight 0 | `SproutTower2FXDefend` | `EVENT_SPROUT_TOWER_2F_X_DEFEND` |

**Scripts of interest**

- `TrainerSageNico` (`42:4280`) and `TrainerSageEdmond` (`42:4294`): identical
  shape to Chow - `trainer` header, `.Script` = `endifjustbattled` + one
  `writetext`.
- `SproutTower2FXDefend` (`42:42ab`): `itemball X_DEFEND`. Note the item is
  **X Defend**, not X Accuracy.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_SAGE_NICO` (1042) | `constants/event_flags.asm:519` | `TrainerSageNico` | Beaten once |
| `EVENT_BEAT_SAGE_EDMOND` (1047) | `constants/event_flags.asm:524` | `TrainerSageEdmond` | Beaten once |
| `EVENT_SPROUT_TOWER_2F_X_DEFEND` (1608) | `constants/event_flags.asm:1001` | object-event flag | Ball taken |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `X_DEFEND` | Poke Ball object at (3,1) | `SproutTower2FXDefend` | `EVENT_SPROUT_TOWER_2F_X_DEFEND` |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `SAGE`, `NICO` | `SAGE` | `NICO` (2) | `SageGroup` "NICO": L3 Bellsprout x3 | `TrainerSageNico` | none |
| `SAGE`, `EDMOND` | `SAGE` | `EDMOND` (7) | `SageGroup` "EDMOND": L3 Bellsprout x3 | `TrainerSageEdmond` | none |

Both pay 8 x 3 x 4 = 96.

**Wild encounters**

`data/wild/johto_grass.asm:5` `def_grass_wildmons SPROUT_TOWER_2F`, rates
`2 percent / 2 percent / 2 percent` (morn/day/nite):

- morn: L3 Rattata, L4 Rattata, L5 Rattata, L3 Rattata, L6 Rattata, L5 Rattata, L5 Rattata
- day: identical to morn
- nite: L3 Gastly, L4 Gastly, L5 Gastly, L3 Rattata, L6 Gastly, L5 Rattata, L5 Rattata

No water/fish/headbutt entry for this map.

---

### MAP_SPROUT_TOWER_3F

- Script: `maps/SproutTower3F.asm`
- Blocks: `maps/SproutTower3F.blk`
- Header: `data/maps/maps.asm:81` -> `TILESET_TOWER`, `DUNGEON`,
  `LANDMARK_SPROUT_TOWER`, `MUSIC_SPROUT_TOWER`, `FALSE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions / attributes: `constants/map_constants.asm:68`
  (`map_const SPROUT_TOWER_3F, 10, 8`) = 20x16 cells;
  `data/maps/attributes.asm:400`
- Connections: none
- Scene variable: `data/maps/scenes.asm:47` -> `wSproutTower3FSceneID`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 10 | 14 | `SPROUT_TOWER_2F` | 4 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_SPROUTTOWER3F_RIVAL_ENCOUNTER` (0) | 11 | 9 | `SproutTower3FRivalScene` | The elder/rival cutscene; ends with `setscene SCENE_SPROUTTOWER3F_NOOP` |

The two `SCENE_SPROUTTOWER3F_*` constants are generated inline by the
`scene_script` macro (`macros/scripts/maps.asm`, `scene_const`) in
`maps/SproutTower3F.asm:12-13`: index 0 = `SCENE_SPROUTTOWER3F_RIVAL_ENCOUNTER`,
index 1 = `SCENE_SPROUTTOWER3F_NOOP`. Both scene *scripts* are bare `end`
stubs; the scene id exists only to arm/disarm the coord event. The scene starts
at 0 on a new game, so the trip-wire is live on first entry.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 8 | 1 | `BGEVENT_READ` | `SproutTower3FStatue` |
| 11 | 1 | `BGEVENT_READ` | `SproutTower3FStatue` |
| 9 | 0 | `BGEVENT_READ` | `SproutTower3FPainting` |
| 10 | 0 | `BGEVENT_READ` | `SproutTower3FPainting` |
| 5 | 15 | `BGEVENT_READ` | `SproutTower3FStatue` |
| 14 | 15 | `BGEVENT_READ` | `SproutTower3FStatue` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `SPROUTTOWER3F_SAGE1` | `SPRITE_SAGE` | 8 | 13 | `SPRITEMOVEDATA_STANDING_RIGHT`, pal `PAL_NPC_BLUE` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerSageJin` | -1 |
| `SPROUTTOWER3F_SAGE2` | `SPRITE_SAGE` | 8 | 8 | `SPRITEMOVEDATA_STANDING_DOWN`, pal `PAL_NPC_BLUE` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerSageTroy` | -1 |
| `SPROUTTOWER3F_SAGE3` | `SPRITE_SAGE` | 10 | 2 | `SPRITEMOVEDATA_STANDING_DOWN`, pal `PAL_NPC_BLUE` | `OBJECTTYPE_SCRIPT`, sight 0 | `SageLiScript` | -1 |
| `SPROUTTOWER3F_SAGE4` | `SPRITE_SAGE` | 11 | 11 | `SPRITEMOVEDATA_STANDING_LEFT`, pal `PAL_NPC_BLUE` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerSageNeal` | -1 |
| `SPROUTTOWER3F_POKE_BALL1` | `SPRITE_POKE_BALL` | 6 | 14 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `SproutTower3FPotion` | `EVENT_SPROUT_TOWER_3F_POTION` |
| `SPROUTTOWER3F_POKE_BALL2` | `SPRITE_POKE_BALL` | 14 | 1 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `SproutTower3FEscapeRope` | `EVENT_SPROUT_TOWER_3F_ESCAPE_ROPE` |
| `SPROUTTOWER3F_RIVAL` | `SPRITE_RIVAL` | 10 | 4 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT`, sight 0 | `ObjectEvent` (the shared ROM0 stub) | `EVENT_RIVAL_SPROUT_TOWER` |

Object-flag polarity, confirmed in `engine/overworld/map_objects_2.asm`
(`CheckObjectFlag`): the object is **masked when its event flag is SET**.
`EVENT_RIVAL_SPROUT_TOWER` therefore starts *clear* (rival visible) and the
cutscene's `disappear SPROUTTOWER3F_RIVAL` sets it
(`Script_disappear` -> `ApplyEventActionAppearDisappear`, `b = 1`,
`engine/overworld/scripting.asm:887`).

**Scripts of interest**

- `SproutTower3FRivalScene` (`42:444b`), fired by the coord event at (11,9):
  `turnobject PLAYER, UP`; `showemote EMOTE_SHOCK, PLAYER, 15`;
  `special FadeOutMusic`; two rounds of `playsound SFX_TACKLE` +
  `playsound SFX_ELEVATOR` + `earthquake 79` + `pause 15`;
  `applymovement PLAYER, SproutTower3FPlayerApproachesRivalMovement` (four
  `step UP`, so the player ends at (11,5));
  `applymovement SPROUTTOWER3F_RIVAL, SproutTower3FRivalApproachesElderMovement`
  (one `step UP`, rival (10,4) -> (10,3));
  `writetext SproutTowerElderLecturesRivalText`;
  `showemote EMOTE_SHOCK, SPROUTTOWER3F_RIVAL, 15`;
  `turnobject SPROUTTOWER3F_RIVAL, DOWN`;
  `applymovement SPROUTTOWER3F_RIVAL, SproutTower3FRivalLeavesElderMovement`
  (`step RIGHT`, `step DOWN`); `playmusic MUSIC_RIVAL_ENCOUNTER`;
  two more `writetext`s; `playsound SFX_WARP_TO`; `special FadeOutToBlack`;
  `special ReloadSpritesNoPalettes`; `disappear SPROUTTOWER3F_RIVAL`;
  `waitsfx`; `special FadeInFromBlack`; `setscene SCENE_SPROUTTOWER3F_NOOP`;
  `special RestartMapMusic`; `end`.
  **No battle.** This is a pure cutscene - the rival is not fought here.
- `SageLiScript` (`42:44aa`): `faceplayer`, `opentext`,
  `checkevent EVENT_GOT_HM05_FLASH` / `iftrue .GotFlash`. First-time arm:
  `writetext SageLiSeenText`, `winlosstext SageLiBeatenText, 0`,
  `loadtrainer SAGE, LI`, `startbattle`, `reloadmapafterbattle`,
  `writetext SageLiTakeThisFlashText`, `promptbutton`,
  `verbosegiveitem HM_FLASH`, `setevent EVENT_GOT_HM05_FLASH`,
  `setevent EVENT_BEAT_SAGE_LI`, `writetext SageLiFlashExplanationText`, `end`.
  `.GotFlash` (`42:44d5`) is a single `writetext SageLiAfterBattleText`.
  Note the flag order: the HM is given *before* both events are set, and
  `verbosegiveitem`'s failure return is **not** checked here (unlike Falkner's
  TM), so a full bag at this point loses the HM.
- `TrainerSageJin` (`42:44db`), `TrainerSageTroy` (`42:44ef`),
  `TrainerSageNeal` (`42:4503`): standard `trainer` headers + `endifjustbattled`
  after-battle text.
- `SproutTower3FPotion` (`42:451d`) = `itemball POTION`;
  `SproutTower3FEscapeRope` (`42:451f`) = `itemball ESCAPE_ROPE`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_SAGE_JIN` (1043) | `constants/event_flags.asm:520` | `TrainerSageJin` | Beaten |
| `EVENT_BEAT_SAGE_TROY` (1044) | `constants/event_flags.asm:521` | `TrainerSageTroy` | Beaten |
| `EVENT_BEAT_SAGE_NEAL` (1048) | `constants/event_flags.asm:525` | `TrainerSageNeal` | Beaten |
| `EVENT_BEAT_SAGE_LI` (1049) | `constants/event_flags.asm:526` | set by `SageLiScript` after the battle | Set only on the HM-giving pass; Li is an `OBJECTTYPE_SCRIPT`, not a trainer object, so this flag does not gate re-battle - `EVENT_GOT_HM05_FLASH` does |
| `EVENT_GOT_HM05_FLASH` (20) | `constants/event_flags.asm:27` | read+written by `SageLiScript` | The real "tower cleared" flag |
| `EVENT_RIVAL_SPROUT_TOWER` (1732) | `constants/event_flags.asm:1126` | object-event flag; set by `disappear` in the cutscene; also `setevent` in `maps/HallOfFame.asm:35` | Clear = rival still standing at (10,4) |
| `EVENT_SPROUT_TOWER_3F_POTION` (1609) | `constants/event_flags.asm:1002` | object-event flag | Ball taken |
| `EVENT_SPROUT_TOWER_3F_ESCAPE_ROPE` (1610) | `constants/event_flags.asm:1003` | object-event flag | Ball taken |
| `SCENE_SPROUTTOWER3F_RIVAL_ENCOUNTER` = 0 | `maps/SproutTower3F.asm:12` (macro-generated) | `wSproutTower3FSceneID` (`data/maps/scenes.asm:47`) | Coord event live |
| `SCENE_SPROUTTOWER3F_NOOP` = 1 | `maps/SproutTower3F.asm:13` | `setscene` at the end of the cutscene; `setmapscene` in `maps/HallOfFame.asm:39` | Coord event dead |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `POTION` | Poke Ball at (6,14) | `SproutTower3FPotion` | `EVENT_SPROUT_TOWER_3F_POTION` |
| `ESCAPE_ROPE` | Poke Ball at (14,1) | `SproutTower3FEscapeRope` | `EVENT_SPROUT_TOWER_3F_ESCAPE_ROPE` |
| `HM_FLASH` (HM05) | `verbosegiveitem` from Sage Li after his battle | `SageLiScript` | `EVENT_GOT_HM05_FLASH` |

`HM_FLASH` is the fifth `add_hm` in `constants/item_constants.asm`
(CUT, FLY, SURF, STRENGTH, **FLASH**, WHIRLPOOL, WATERFALL), i.e. HM05.

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `SAGE`, `JIN` | `SAGE` | `JIN` (3) | `SageGroup` "JIN": L6 Bellsprout | `TrainerSageJin` | none |
| `SAGE`, `TROY` | `SAGE` | `TROY` (4) | `SageGroup` "TROY": L7 Bellsprout, L7 Hoothoot | `TrainerSageTroy` | none |
| `SAGE`, `NEAL` | `SAGE` | `NEAL` (8) | `SageGroup` "NEAL": L6 Bellsprout | `TrainerSageNeal` | none |
| `SAGE`, `LI` | `SAGE` | `LI` (9) | `SageGroup` "LI": L7 Bellsprout, L7 Bellsprout, L10 Hoothoot | `SageLiScript` (`loadtrainer`, not an `OBJECTTYPE_TRAINER`) | none |

Prize money (base 8 x last party level x 4): Jin 192, Neal 192, Troy 224,
Li 320. All `TRAINERTYPE_NORMAL` (no explicit moves; movesets come from level-up
data). Class DVs `dn 9, 8, 8, 8` (`data/trainers/dvs.asm:61`).

**Wild encounters**

`data/wild/johto_grass.asm:33` `def_grass_wildmons SPROUT_TOWER_3F` - byte for
byte identical to the 2F table: rates 2/2/2 percent, morn+day all Rattata L3-L6,
nite Gastly L3-L6 mixed with Rattata L3/L5/L5. No water/fish/headbutt entry.

---

### MAP_VIOLET_CITY

- Script: `maps/VioletCity.asm`
- Blocks: `maps/VioletCity.blk` (`data/maps/blocks.asm:532`)
- Header: `data/maps/maps.asm:251` -> `TILESET_JOHTO`, `TOWN`,
  `LANDMARK_VIOLET_CITY`, `MUSIC_VIOLET_CITY`, phone `FALSE`, `PALETTE_AUTO`,
  `FISHGROUP_POND`
- Dimensions / attributes: `constants/map_constants.asm:230`
  (`map_const VIOLET_CITY, 20, 18`) = 40x36 cells;
  `data/maps/attributes.asm:127` (`map_attributes VioletCity, VIOLET_CITY, $05`)
- Connections (`data/maps/attributes.asm:127-130`):
  south `Route32`/`ROUTE_32` offset 0, west `Route36`/`ROUTE_36` offset 0,
  east `Route31`/`ROUTE_31` offset 9. No north connection.

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

**Coord events** (`def_coord_events`)

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 24 | 20 | `BGEVENT_READ` | `VioletCitySign` |
| 15 | 17 | `BGEVENT_READ` | `VioletGymSign` |
| 24 | 8 | `BGEVENT_READ` | `SproutTowerSign` |
| 27 | 17 | `BGEVENT_READ` | `EarlsPokemonAcademySign` |
| 32 | 25 | `BGEVENT_READ` | `VioletCityPokecenterSign` (`jumpstd PokecenterSignScript`) |
| 10 | 17 | `BGEVENT_READ` | `VioletCityMartSign` (`jumpstd MartSignScript`) |
| 37 | 14 | `BGEVENT_ITEM` | `VioletCityHiddenHyperPotion` = `hiddenitem HYPER_POTION, EVENT_VIOLET_CITY_HIDDEN_HYPER_POTION` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VIOLETCITY_EARL` | `SPRITE_FISHER` | 13 | 16 | `SPRITEMOVEDATA_SPINRANDOM_SLOW`, pal `PAL_NPC_GREEN` | `OBJECTTYPE_SCRIPT` | `VioletCityEarlScript` | `EVENT_VIOLET_CITY_EARL` |
| `VIOLETCITY_LASS` | `SPRITE_LASS` | 28 | 28 | `SPRITEMOVEDATA_WANDER`, radius 2/2, pal `PAL_NPC_GREEN` | `OBJECTTYPE_SCRIPT` | `VioletCityLassScript` | -1 |
| `VIOLETCITY_SUPER_NERD` | `SPRITE_SUPER_NERD` | 24 | 14 | `SPRITEMOVEDATA_WANDER`, radius 1/2, pal `PAL_NPC_RED` | `OBJECTTYPE_SCRIPT` | `VioletCitySuperNerdScript` | -1 |
| `VIOLETCITY_GRAMPS` | `SPRITE_GRAMPS` | 17 | 20 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT`, radius 1/0 | `OBJECTTYPE_SCRIPT` | `VioletCityGrampsScript` | -1 |
| `VIOLETCITY_YOUNGSTER` | `SPRITE_YOUNGSTER` | 5 | 18 | `SPRITEMOVEDATA_SPINRANDOM_SLOW`, pal `PAL_NPC_GREEN` | `OBJECTTYPE_SCRIPT` | `VioletCityYoungsterScript` | -1 |
| `VIOLETCITY_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 14 | 29 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `VioletCityFruitTree` = `fruittree FRUITTREE_VIOLET_CITY` | -1 |
| `VIOLETCITY_POKE_BALL1` | `SPRITE_POKE_BALL` | 4 | 1 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `VioletCityPPUp` | `EVENT_VIOLET_CITY_PP_UP` |
| `VIOLETCITY_POKE_BALL2` | `SPRITE_POKE_BALL` | 35 | 5 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `VioletCityRareCandy` | `EVENT_VIOLET_CITY_RARE_CANDY` |

**Scripts of interest**

- `VioletCityFlypointCallback` (`48:4c6d`), registered as
  `callback MAPCALLBACK_NEWMAP`: a single `setflag ENGINE_FLYPOINT_VIOLET`
  then `endcallback`. Entering the map at all unlocks Fly to Violet.
- `VioletCityEarlScript`: spins, `faceplayer`,
  `writetext Text_EarlAsksIfYouBeatFalkner`, `yesorno`. Answering **yes** is
  the `.PointlessJump` arm (one line of text, no state change). Answering **no**
  is `.FollowEarl`: `playmusic MUSIC_SHOW_ME_AROUND`,
  `follow VIOLETCITY_EARL, PLAYER`, a long
  `VioletCityFollowEarl_MovementData` walk to the academy door,
  `stopfollow`, `disappear VIOLETCITY_EARL`,
  `clearevent EVENT_EARLS_ACADEMY_EARL`. A bot that does not want to be
  dragged across the map should answer **yes**, or simply not talk to him.
- The four remaining townsfolk are `jumptextfaceplayer` one-liners.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_VIOLET` (66) | `constants/engine_flags.asm:81` | `VioletCityFlypointCallback` | Fly destination unlocked on first map load |
| `EVENT_VIOLET_CITY_EARL` (1738) | `constants/event_flags.asm:1132` | object-event flag; set by `disappear` in `.FollowEarl` | Clear = Earl still outside |
| `EVENT_VIOLET_CITY_PP_UP` (1603) | `constants/event_flags.asm:996` | object-event flag | Ball taken |
| `EVENT_VIOLET_CITY_RARE_CANDY` (1604) | `constants/event_flags.asm:997` | object-event flag | Ball taken |
| `EVENT_VIOLET_CITY_HIDDEN_HYPER_POTION` (176) | `constants/event_flags.asm:186` | `hiddenitem` operand at bg_event (37,14) | Hidden item taken |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `PP_UP` | Poke Ball at (4,1) | `VioletCityPPUp` | `EVENT_VIOLET_CITY_PP_UP` |
| `RARE_CANDY` | Poke Ball at (35,5) | `VioletCityRareCandy` | `EVENT_VIOLET_CITY_RARE_CANDY` |
| `HYPER_POTION` | Hidden, A-press or Itemfinder on (37,14) | `VioletCityHiddenHyperPotion` | `EVENT_VIOLET_CITY_HIDDEN_HYPER_POTION` |
| berry | `fruittree FRUITTREE_VIOLET_CITY` at (14,29) | `VioletCityFruitTree` | daily reset, not an `EVENT_*` |

None of these four are mentioned by the walkthrough section; they are listed
because a bot walking this map will pass them.

**Trainers**

None on the overworld map.

**Wild encounters**

- Grass: no `def_grass_wildmons VIOLET_CITY` entry in `data/wild/johto_grass.asm`.
- Water (`data/wild/johto_water.asm:225`): rate `2 percent`, L20 Poliwag,
  L15 Poliwag, L20 Poliwhirl - Surf only, i.e. not reachable in this section.
- Fishing group `FISHGROUP_POND` (`data/maps/maps.asm:251`), table in
  `data/wild/fish.asm`.

---

### MAP_VIOLET_POKECENTER_1F

- Script: `maps/VioletPokecenter1F.asm`
- Blocks: shared `VioletPokecenter1F_Blocks` label in `data/maps/blocks.asm:351`
  (same blockset as the other Pokecenter 1Fs; no dedicated `.blk`)
- Header: `data/maps/maps.asm:256` -> `TILESET_POKECENTER`, `INDOOR`,
  `LANDMARK_VIOLET_CITY`, `MUSIC_POKEMON_CENTER`, `FALSE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions / attributes: `constants/map_constants.asm:235`
  (`map_const VIOLET_POKECENTER_1F, 5, 4`) = 10x8 cells;
  `data/maps/attributes.asm:538`
- Connections: none

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `VIOLET_CITY` | 5 |
| 2 | 4 | 7 | `VIOLET_CITY` | 5 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

**Coord events** / **BG events**: both empty.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VIOLETPOKECENTER1F_NURSE` | `SPRITE_NURSE` | 3 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `VioletPokecenterNurse` (`jumpstd PokecenterNurseScript`) | -1 |
| `VIOLETPOKECENTER1F_SUPER_NERD` | `SPRITE_SUPER_NERD` | 7 | 6 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT`, radius 1/0, pal `PAL_NPC_GREEN` | `OBJECTTYPE_SCRIPT` | `VioletPokecenter1FSuperNerdScript` | -1 |
| `VIOLETPOKECENTER1F_GENTLEMAN` | `SPRITE_GENTLEMAN` | 1 | 4 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `VioletPokecenter1FGentlemanScript` | -1 |
| `VIOLETPOKECENTER1F_YOUNGSTER` | `SPRITE_YOUNGSTER` | 8 | 1 | `SPRITEMOVEDATA_STANDING_DOWN`, pal `PAL_NPC_RED` | `OBJECTTYPE_SCRIPT` | `VioletPokecenter1FYoungsterScript` | -1 |
| `VIOLETPOKECENTER1F_ELMS_AIDE` | `SPRITE_SCIENTIST` | 4 | 3 | `SPRITEMOVEDATA_STANDING_DOWN`, pal `PAL_NPC_BLUE` | `OBJECTTYPE_SCRIPT` | `VioletPokecenter1F_ElmsAideScript` | `EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER` |

**Scripts of interest**

- `VioletPokecenterNurse` -> `jumpstd PokecenterNurseScript`: the only beat the
  walkthrough uses here ("go back to the Pokemon Center to heal").
- `VioletPokecenter1F_ElmsAideScript` is **not** reachable during this section:
  `EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER` is set at new game
  (`engine/events/std_scripts.asm:468`), which masks the object, and is only
  cleared by Elm's `.assistant` phone call
  (`engine/phone/scripts/elm.asm:84`) queued by beating Falkner. It gives
  `giveegg TOGEPI, EGG_LEVEL` and belongs to the next section.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ELMS_AIDE_IN_VIOLET_POKEMON_CENTER` (1792) | `constants/event_flags.asm:1186` | set in `engine/events/std_scripts.asm:468`, cleared in `engine/phone/scripts/elm.asm:84` | Set = aide hidden. Stays set for the whole of this section |

**Items / Trainers / Wild encounters**: none.

---

### MAP_VIOLET_GYM

- Script: `maps/VioletGym.asm`
- Blocks: `maps/VioletGym.blk` (`data/maps/blocks.asm:734`)
- Header: `data/maps/maps.asm:253` -> `TILESET_ELITE_FOUR_ROOM`, `INDOOR`,
  `LANDMARK_VIOLET_CITY`, `MUSIC_GYM`, phone `TRUE`, `PALETTE_DAY`,
  `FISHGROUP_SHORE`
- Dimensions / attributes: `constants/map_constants.asm:232`
  (`map_const VIOLET_GYM, 5, 8`) = 10x16 cells;
  `data/maps/attributes.asm:535`
- Connections: none

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 15 | `VIOLET_CITY` | 2 |
| 2 | 5 | 15 | `VIOLET_CITY` | 2 |

**Coord events** (`def_coord_events`)

None. There is no scripted trip-wire in the gym; Abe and Rod fire off eyesight
alone.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 3 | 13 | `BGEVENT_READ` | `VioletGymStatue` |
| 6 | 13 | `BGEVENT_READ` | `VioletGymStatue` |

`VioletGymStatue` branches on `checkflag ENGINE_ZEPHYRBADGE`: unbeaten ->
`jumpstd GymStatue1Script`; beaten -> `gettrainername STRING_BUFFER_4, FALKNER,
FALKNER1` + `jumpstd GymStatue2Script`. Reading it is a cheap way for a bot to
confirm the badge landed.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VIOLETGYM_FALKNER` | `SPRITE_FALKNER` | 5 | 1 | `SPRITEMOVEDATA_STANDING_DOWN`, radius 0/0, pal `PAL_NPC_BLUE` | `OBJECTTYPE_SCRIPT`, sight 0 | `VioletGymFalknerScript` | -1 |
| `VIOLETGYM_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 7 | 6 | `SPRITEMOVEDATA_STANDING_LEFT`, radius 2/0, pal `PAL_NPC_BLUE` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerBirdKeeperRod` | -1 |
| `VIOLETGYM_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 2 | 10 | `SPRITEMOVEDATA_STANDING_RIGHT`, radius 2/0, pal `PAL_NPC_BLUE` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerBirdKeeperAbe` | -1 |
| `VIOLETGYM_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 7 | 13 | `SPRITEMOVEDATA_STANDING_DOWN`, radius 0/0, pal `PAL_NPC_RED` | `OBJECTTYPE_SCRIPT`, sight 0 | `VioletGymGuideScript` | -1 |

Walking in at (4,15)/(5,15) and heading north, **Abe** (facing right at y=10) is
met before **Rod** (facing left at y=6), which is the order the walkthrough
gives even though it names Abe first and Rod second.

**Scripts of interest**

- `VioletGymFalknerScript` (`56:412f`):
  `faceplayer`, `opentext`, `checkevent EVENT_BEAT_FALKNER` /
  `iftrue .FightDone`. First pass: `writetext FalknerIntroText`,
  `winlosstext FalknerWinLossText, 0`, `loadtrainer FALKNER, FALKNER1`,
  `startbattle`, `reloadmapafterbattle`, `setevent EVENT_BEAT_FALKNER`,
  `writetext ReceivedZephyrBadgeText`, `playsound SFX_GET_BADGE`, `waitsfx`,
  **`setflag ENGINE_ZEPHYRBADGE`**, `readvar VAR_BADGES`,
  `scall VioletGymActivateRockets`.
  Then `.FightDone` (`56:4159`): `checkevent EVENT_GOT_TM31_MUD_SLAP` /
  `iftrue .SpeechAfterTM`; otherwise
  `setevent EVENT_BEAT_BIRD_KEEPER_ROD`, `setevent EVENT_BEAT_BIRD_KEEPER_ABE`
  (the two gym trainers are force-flagged so they never re-trigger),
  `setmapscene ELMS_LAB, SCENE_ELMSLAB_NOOP`,
  `specialphonecall SPECIALCALL_ASSISTANT`,
  `writetext FalknerZephyrBadgeText`, `promptbutton`,
  `verbosegiveitem TM_MUD_SLAP`, `iffalse .NoRoomForMudSlap`,
  `setevent EVENT_GOT_TM31_MUD_SLAP`, `writetext FalknerTMMudSlapText`.
  Unlike Sage Li, this one **does** check `verbosegiveitem`'s return, so a full
  bag leaves `EVENT_GOT_TM31_MUD_SLAP` clear and the TM is offered again on the
  next talk.
- `VioletGymActivateRockets` (`56:4185`): `ifequal 7, .RadioTowerRockets`,
  `ifequal 6, .GoldenrodRockets` against the `VAR_BADGES` count. With one badge
  this is a no-op; it exists so that a late Violet clear still arms the Rocket
  arcs.
- `TrainerBirdKeeperRod` (`56:4194`), `TrainerBirdKeeperAbe` (`56:41a8`):
  standard `trainer` headers + `endifjustbattled` after-battle text.
- `VioletGymGuideScript`: branches on `EVENT_BEAT_FALKNER`; pure text.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_FALKNER` (1213) | `constants/event_flags.asm:706` | read+written by `VioletGymFalknerScript`; read by `VioletGymGuideScript` | The gym-cleared flag |
| `ENGINE_ZEPHYRBADGE` (26) | `constants/engine_flags.asm:38` | `setflag` in `VioletGymFalknerScript`; `checkflag` in `VioletGymStatue`; `CheckBadge` in `engine/events/overworld.asm` | The badge bit. Gates out-of-battle Flash and the Gen 2 attack boost (`engine/battle/core.asm:6566`) |
| `EVENT_GOT_TM31_MUD_SLAP` (8) | `constants/event_flags.asm:14` | `VioletGymFalknerScript` | TM31 collected |
| `EVENT_BEAT_BIRD_KEEPER_ROD` (1019) | `constants/event_flags.asm:494` | `TrainerBirdKeeperRod`; also force-set by `VioletGymFalknerScript.FightDone` | Beaten |
| `EVENT_BEAT_BIRD_KEEPER_ABE` (1020) | `constants/event_flags.asm:495` | `TrainerBirdKeeperAbe`; also force-set by `.FightDone` | Beaten |
| `SCENE_ELMSLAB_NOOP` | `maps/ElmsLab.asm` (macro-generated) | `setmapscene ELMS_LAB, ...` in `.FightDone` | Disarms the lab's remaining scene script |
| `SPECIALCALL_ASSISTANT` | `constants/phone_constants.asm:47` | `specialphonecall` in `.FightDone`; consumed by `ElmPhoneCallerScript` (`engine/phone/scripts/elm.asm:67`) | Queues the Togepi-egg phone call |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| ZEPHYRBADGE | Automatic on beating Falkner | `VioletGymFalknerScript` (`setflag ENGINE_ZEPHYRBADGE`) | `ENGINE_ZEPHYRBADGE` |
| `TM_MUD_SLAP` (TM31) | `verbosegiveitem` after the badge text | `VioletGymFalknerScript.FightDone` | `EVENT_GOT_TM31_MUD_SLAP` |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `BIRD_KEEPER`, `ROD` | `BIRD_KEEPER` (18) | `ROD` (1) | `BirdKeeperGroup` "ROD" (`0e:5f05` group base): L7 Pidgey, L7 Pidgey, `TRAINERTYPE_NORMAL` | `TrainerBirdKeeperRod` | none |
| `BIRD_KEEPER`, `ABE` | `BIRD_KEEPER` | `ABE` (2) | `BirdKeeperGroup` "ABE": L9 Spearow, `TRAINERTYPE_NORMAL` | `TrainerBirdKeeperAbe` | none |
| `FALKNER`, `FALKNER1` | `FALKNER` (1) | `FALKNER1` (1) | `FalknerGroup` (`0e:59c2`), `TRAINERTYPE_MOVES`: L7 Pidgey (TACKLE, MUD_SLAP), L9 Pidgeotto (TACKLE, MUD_SLAP, GUST) | `VioletGymFalknerScript` (`loadtrainer`) | listed in `data/trainers/leaders.asm:8` |

Prize money: Bird Keeper base 6 (`data/trainers/attributes.asm`) -> Rod
6 x 7 x 4 = 168, Abe 6 x 9 x 4 = 216. Falkner base 25 -> 25 x 9 x 4 = 900.
Falkner DVs `dn 9, 10, 7, 7` (`data/trainers/dvs.asm:5`); Bird Keeper
`dn 9, 8, 8, 8` (line 28).

**Wild encounters**

None (indoor gym).

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Sprout Tower 3F rival cutscene fires before you can reach Sage Li | `maps/SproutTower3F.asm` `coord_event 11, 9, SCENE_SPROUTTOWER3F_RIVAL_ENCOUNTER, SproutTower3FRivalScene` | Standing on (11,9) while `wSproutTower3FSceneID` == 0 | The scene's own `setscene SCENE_SPROUTTOWER3F_NOOP`. Not a hard block - the tile is on the only path north |
| HM05 Flash | `maps/SproutTower3F.asm:SageLiScript` | Beat `SAGE, LI` (`loadtrainer` + `startbattle`) | `verbosegiveitem HM_FLASH` + `setevent EVENT_GOT_HM05_FLASH` |
| Using Flash outside battle | `engine/events/overworld.asm` `FlashFunction.CheckUseFlash` (`03:48f1`): `ld de, ENGINE_ZEPHYRBADGE` / `farcall CheckBadge` / `jr c, .nozephyrbadge` | `ENGINE_ZEPHYRBADGE` set **and** `wTimeOfDayPalset == DARKNESS_PALSET` | Beat Falkner. Note the second half: even with the badge, Flash is refused on any map that is not a dark cave (`.notadarkcave` -> `FieldMoveFailed`) |
| ZEPHYRBADGE attack boost / obedience | `engine/battle/core.asm:6566` (the `and` mask that starts `(1 << ZEPHYRBADGE)`) | badge bit | Beat Falkner |
| Gym trainers Abe and Rod | `maps/VioletGym.asm` object events, `OBJECTTYPE_TRAINER` sight 3 on shared rows | eyesight only; they do **not** physically block the aisle | Beating them, or `EVENT_BEAT_BIRD_KEEPER_*` being force-set by `VioletGymFalknerScript.FightDone` |
| Falkner re-battle | `maps/VioletGym.asm:VioletGymFalknerScript` `checkevent EVENT_BEAT_FALKNER` / `iftrue .FightDone` | none | one-shot |
| Sage Li re-battle | `maps/SproutTower3F.asm:SageLiScript` `checkevent EVENT_GOT_HM05_FLASH` / `iftrue .GotFlash` | none | one-shot, keyed on the HM flag rather than on `EVENT_BEAT_SAGE_LI` |
| Sprout Tower is a `DUNGEON` | `data/maps/maps.asm:79-81` | - | `ESCAPE_ROPE` and Dig work here, which is what the walkthrough's "you may use that to get out of the tower" relies on |

Nothing in this section is gated on a field move, a key item, or an NPC standing
on a tile. The only hard requirement is winning battles.

## 4. Bot checklist

Coordinates are asm map cells. Port driver form:
`world:setMap("<MAP_CONST>", x, y, facing)`, as in
`tests/drivers/gold_walk_smoke.lua:58`.

| # | Map | Target | Intent | Precondition | Postcondition |
|---|---|---|---|---|---|
| 1 | `SPROUT_TOWER_1F` | warp 1 (9,15) | enter from `VIOLET_CITY` (23,5) | - | on 1F |
| 2 | `SPROUT_TOWER_1F` | (6,4) | walk onto warp 3 | - | on `SPROUT_TOWER_2F` at (6,4) |
| 3 | `SPROUT_TOWER_2F` | `SPROUTTOWER2F_SAGE1` at (14,4), sight 3 wide facing spin | step into his line, battle | `EVENT_BEAT_SAGE_NICO` clear | `EVENT_BEAT_SAGE_NICO` set |
| 4 | `SPROUT_TOWER_2F` | (17,3) | walk onto warp 3 | - | on `SPROUT_TOWER_1F` at (17,3) |
| 5 | `SPROUT_TOWER_1F` | ball at (16,7) | face + A | `EVENT_SPROUT_TOWER_1F_PARLYZ_HEAL` clear | `PARLYZ_HEAL` in bag, flag set |
| 6 | `SPROUT_TOWER_1F` | `SPROUTTOWER1F_SAGE3` at (2,1), facing RIGHT, sight 1 | step to (3,1), battle | `EVENT_BEAT_SAGE_CHOW` clear | `EVENT_BEAT_SAGE_CHOW` set |
| 7 | `SPROUT_TOWER_1F` | (2,6) | walk onto warp 4 | - | on `SPROUT_TOWER_2F` at (2,6) |
| 8 | `SPROUT_TOWER_2F` | ball at (3,1) | face + A | `EVENT_SPROUT_TOWER_2F_X_DEFEND` clear | `X_DEFEND` in bag, flag set |
| 9 | `SPROUT_TOWER_2F` | `SPROUTTOWER2F_SAGE2` at (3,15), facing UP, sight 4 | approach from above, battle | `EVENT_BEAT_SAGE_EDMOND` clear | `EVENT_BEAT_SAGE_EDMOND` set |
| 10 | `SPROUT_TOWER_2F` | (10,14) | walk onto warp 4 | - | on `SPROUT_TOWER_3F` at (10,14) |
| 11 | `SPROUT_TOWER_3F` | ball at (6,14) | face + A | `EVENT_SPROUT_TOWER_3F_POTION` clear | `POTION` in bag, flag set |
| 12 | `SPROUT_TOWER_3F` | `SPROUTTOWER3F_SAGE1` at (8,13), facing RIGHT, sight 3 | battle | `EVENT_BEAT_SAGE_JIN` clear | `EVENT_BEAT_SAGE_JIN` set |
| 13 | `SPROUT_TOWER_3F` | `SPROUTTOWER3F_SAGE4` at (11,11), facing LEFT, sight 3 | battle | `EVENT_BEAT_SAGE_NEAL` clear | `EVENT_BEAT_SAGE_NEAL` set |
| 14 | `SPROUT_TOWER_3F` | `SPROUTTOWER3F_SAGE2` at (8,8), facing DOWN, sight 2 | battle | `EVENT_BEAT_SAGE_TROY` clear | `EVENT_BEAT_SAGE_TROY` set |
| 15 | `SPROUT_TOWER_3F` | (11,9) | walk onto the coord event | scene id == `SCENE_SPROUTTOWER3F_RIVAL_ENCOUNTER` (0) | cutscene runs; player ends at (11,5); `EVENT_RIVAL_SPROUT_TOWER` set; scene id -> 1 |
| 16 | `SPROUT_TOWER_3F` | `SPROUTTOWER3F_SAGE3` at (10,2) | face + A, battle `SAGE, LI` | `EVENT_GOT_HM05_FLASH` clear; **bag must have room for an HM** | `HM_FLASH`, `EVENT_GOT_HM05_FLASH`, `EVENT_BEAT_SAGE_LI` |
| 17 | `SPROUT_TOWER_3F` | ball at (14,1) | face + A | `EVENT_SPROUT_TOWER_3F_ESCAPE_ROPE` clear | `ESCAPE_ROPE` in bag, flag set |
| 18 | `SPROUT_TOWER_3F` | (10,14) | warp 1, then 2F warp 1/2/3 down to 1F, then 1F warp 1 (9,15) | - | back on `VIOLET_CITY` at (23,5) |
| 19 | `VIOLET_CITY` | (31,25) | walk onto warp 5 | - | on `VIOLET_POKECENTER_1F` at (3,7) |
| 20 | `VIOLET_POKECENTER_1F` | `VIOLETPOKECENTER1F_NURSE` at (3,1) | face + A, accept heal | - | party healed |
| 21 | `VIOLET_POKECENTER_1F` | (3,7) | warp 1 | - | back on `VIOLET_CITY` at (31,25) |
| 22 | `VIOLET_CITY` | (18,17) | walk onto warp 2 | - | on `VIOLET_GYM` at (4,15) |
| 23 | `VIOLET_GYM` | `VIOLETGYM_YOUNGSTER2` at (2,10), facing RIGHT, sight 3 | enter his row, battle Abe | `EVENT_BEAT_BIRD_KEEPER_ABE` clear | flag set |
| 24 | `VIOLET_GYM` | `VIOLETGYM_YOUNGSTER1` at (7,6), facing LEFT, sight 3 | enter his row, battle Rod | `EVENT_BEAT_BIRD_KEEPER_ROD` clear | flag set |
| 25 | `VIOLET_GYM` | (4,15) -> `VIOLET_CITY` -> (31,25) PC | optional re-heal before the leader | - | party healed |
| 26 | `VIOLET_GYM` | `VIOLETGYM_FALKNER` at (5,1) | face + A, battle | `EVENT_BEAT_FALKNER` clear | `EVENT_BEAT_FALKNER`, `ENGINE_ZEPHYRBADGE`, Rod/Abe flags force-set, `SCENE_ELMSLAB_NOOP`, `SPECIALCALL_ASSISTANT` queued |
| 27 | `VIOLET_GYM` | same NPC, second talk if bag was full | face + A | `EVENT_GOT_TM31_MUD_SLAP` clear | `TM_MUD_SLAP`, `EVENT_GOT_TM31_MUD_SLAP` |
| 28 | `VIOLET_GYM` | bg_event (3,13) or (6,13) | face + A (verification only) | - | `GymStatue2Script` text = badge confirmed |

Optional pickups on the way through, none of which the walkthrough mentions:
`VIOLET_CITY` PP Up (4,1), Rare Candy (35,5), hidden Hyper Potion (37,14),
berry tree (14,29).

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map load, block grid, warps for all six maps (data-driven from the ROM) | `src/world/gen2/Map.lua`, `src/import/RomExtractorGen2.lua` (`readMapGroupEntry`, `mapNameByIds`) | implemented - ids are the same `MAP_*` names, see `tools/rom_manifest_gold.json` -> `constants.mapGroups` |
| `MAPCALLBACK_NEWMAP` -> `setflag ENGINE_FLYPOINT_VIOLET` | `src/world/gen2/World.lua` (callback dispatch), driver `tests/drivers/gold_map_callbacks.lua` | implemented |
| Fly point 66 = Violet | `src/world/gen2/FieldMoves.lua:346` (`{ landmark = "LANDMARK_VIOLET_CITY", spawn = "SPAWN_VIOLET", flag = 66 }`) | implemented |
| Script VM for every `maps/*.asm` script in this section | `src/script/gen2/Vm.lua`, `src/script/gen2/Opcodes.lua` | implemented - scripts are disassembled from the ROM, not hand-ported, so `SageLiScript` / `VioletGymFalknerScript` run as-is |
| `coord_event` + scene ids (the 3F rival trip-wire) | `src/world/gen2/World.lua:5013` (coord event scan), `:1183` / `:5026` (scene scripts) | implemented |
| Cutscene opcodes used by `SproutTower3FRivalScene` (`showemote`, `earthquake`, `applymovement`, `turnobject`, `disappear`, `setscene`, `playmusic`) | `src/script/gen2/Opcodes.lua:122/125`, `src/world/gen2/World.lua:1006/1528/647`, `src/script/gen2/Movement.lua` | implemented |
| `special FadeOutMusic` / `FadeOutToBlack` / `ReloadSpritesNoPalettes` / `FadeInFromBlack` / `RestartMapMusic` | `src/script/gen2/Specials.lua` | implemented |
| Object masking by event flag (rival, item balls) | `src/world/gen2/Events.lua` (`objectVisible`), documented against `CheckObjectFlag` | implemented |
| Trainer objects: eyesight, approach walk, seen text, battle, beat flag | `src/world/gen2/Trainers.lua`, `src/world/gen2/World.lua:5205-5253`, driver `tests/drivers/gold_trainer_smoke.lua` | implemented |
| `loadtrainer` / `startbattle` for Sage Li and Falkner | `src/script/gen2/Vm.lua`, `src/battle/gen2/Battle.lua` | implemented |
| Gym leader battle music | `src/battle/gen2/BattleMusic.lua:24` (`FALKNER = true`) | implemented |
| Prize money (Falkner 900 = 25 x 9 x 4) | `src/battle/gen2/Prize.lua`, `tests/gen2_prize_test.lua` | implemented |
| `setflag ENGINE_ZEPHYRBADGE` (id 26) and `readvar VAR_BADGES` | `src/script/gen2/Vm.lua:670`, `src/world/gen2/World.lua:117/1240`, `tests/gen2_world_test.lua:1783` | implemented |
| Flash badge gate (`FlashFunction.CheckUseFlash`) | `src/world/gen2/FieldMoves.lua:105` (`FLASH = "ZEPHYR"`), `tests/gen2_world_test.lua:755-781` | implemented, including the "refused before the darkness check" ordering |
| `verbosegiveitem` (HM05, TM31) incl. the `iffalse` no-room arm | `src/script/gen2/Vm.lua:490-500` | implemented |
| Hidden item at Violet City (37,14) | `src/world/gen2/HiddenItems.lua`, `src/world/gen2/World.lua:5285` | implemented |
| Berry tree `fruittree FRUITTREE_VIOLET_CITY` | `src/script/gen2/CallAsm.lua:75-77`, `src/core/gen2/Apricorns.lua:363` | implemented |
| `specialphonecall SPECIALCALL_ASSISTANT` | `src/script/gen2/Opcodes.lua:161`, `src/core/gen2/Phone.lua:390` | implemented |
| `giveegg TOGEPI` (Elm's aide, next section's payoff) | `src/script/gen2/Vm.lua:453`, driver `tests/drivers/gold_egg_hatch.lua` | implemented |
| Earl's `follow` / `stopfollow` escort | `src/script/gen2/Vm.lua:982` | implemented |
| **Poke Ball item pickup (`OBJECTTYPE_ITEMBALL`)** - Parlyz Heal, X Defend, Potion, Escape Rope, PP Up, Rare Candy | `src/import/RomExtractorGen2.lua:2969` writes `obj.itemball`; **nothing in `src/` reads it**, and `World:interact()` (`src/world/gen2/World.lua:5257`) has no itemball branch (trainer / strength boulder / `scriptKey` / bg sign / hidden item only). `src/script/gen2/CallAsm.lua:550` stubs `TryReceiveItem` out on purpose | **missing** - the balls render and are masked correctly, but pressing A on one does nothing. Every item ball in this section is unobtainable in the port today |
| Hand-ported per-map Lua for Sprout Tower / Violet Gym | none - by design | n/a (the port runs the ROM's own bytecode) |

## 6. Unresolved / verify by hand

1. **"X Accuracy" in the Sprout Tower item list.** The walkthrough's header
   lists Escape Rope, HM05, Parlyz Heal, Potion, **X Accuracy**, and the prose
   says "grab that X Defense above you". The asm has exactly one such ball,
   `SproutTower2FXDefend` = `itemball X_DEFEND` at 2F (3,1). There is no
   `X_ACCURACY` anywhere in `maps/SproutTower*.asm`. The header list is wrong;
   the prose is right.

2. **"Go up to the item to the right of the monk. In reality, it is a...
   Level 3 Rattata"** and the follow-up "Go back to the Rattata you faced
   before, and now it's an Escape Rope." Nothing in `maps/SproutTower3F.asm`
   supports this. The object at (14,1) is a plain
   `object_event ... OBJECTTYPE_ITEMBALL, 0, SproutTower3FEscapeRope,
   EVENT_SPROUT_TOWER_3F_ESCAPE_ROPE` whose script label is a bare
   `itemball ESCAPE_ROPE`. There is no `wildbattle`, no `loadwildmon`, no
   second object at that cell, and no branch on `EVENT_GOT_HM05_FLASH` anywhere
   near it. This looks like the walkthrough importing the Gen 1 Rocket Hideout
   Voltorb trick. **Treat the ball at (14,1) as an ordinary Escape Rope.**

3. **"Pokemon found in Sprout Tower: Rattata, Bellsprout, Gastly."**
   `data/wild/johto_grass.asm` gives Rattata (morn/day) and Gastly + Rattata
   (nite) for `SPROUT_TOWER_2F` and `SPROUT_TOWER_3F`, and **no table at all**
   for `SPROUT_TOWER_1F`. Bellsprout is not a Sprout Tower wild encounter; the
   Bellsprouts are the sages' party members.

4. **Sage Li's party order.** The walkthrough lists L7 Bellsprout, L10 Hoothoot,
   L7 Bellsprout. `data/trainers/parties.asm` `SageGroup` "LI" is
   `db 7, BELLSPROUT / db 7, BELLSPROUT / db 10, HOOTHOOT` - the Hoothoot is
   last, not second. The 320G figure the walkthrough quotes only works with the
   asm order, since `ComputeTrainerReward` uses the level of the **last** party
   row (8 x 10 x 4 = 320).

5. **Walkthrough trainer order in the gym.** The text says "Head up to fight
   your trainer battles first. Bird Keeper Abe ... Head up the path to the
   second trainer. Bird Keeper Rod." Geometrically that is correct (Abe at
   y=10 is south of Rod at y=6), but be aware the *object const* order in the
   file is Rod first (`VIOLETGYM_YOUNGSTER1`), Abe second
   (`VIOLETGYM_YOUNGSTER2`), which is the opposite of the walk order. Do not
   index trainers by object const when following the prose.

6. **"You'll need the 1st badge to use it [Flash]".** True but incomplete:
   `FlashFunction.CheckUseFlash` (`engine/events/overworld.asm`, `03:48f1`)
   requires `ENGINE_ZEPHYRBADGE` **and** `wTimeOfDayPalset == DARKNESS_PALSET`.
   With the badge, on any non-dark map, the move still fails through
   `.notadarkcave` -> `FieldMoveFailed`. A bot should not treat "have badge" as
   "Flash will work here".

7. **EXP values.** The walkthrough quotes per-Pokemon EXP figures (54, 108, 126,
   217, ...). Those are computed from base experience and level at runtime
   (`engine/battle/experience.asm` / `data/pokemon/base_stats/`), not stored
   anywhere as a per-trainer constant, so they were not verified against a
   single asm line here. The **money** figures were: all seven quoted values
   match `base reward x last party level x 4`.

8. **"you should be around an hour into the game now"** and the video link -
   prose, nothing to resolve.

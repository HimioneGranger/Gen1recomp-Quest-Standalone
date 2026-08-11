# Section 26 - Mount Moon and Routes 1-4

Source: `../section-26-mount-moon-and-routes-1-4.txt` (walkthrough heading "32 > Mount Moon and Routes 1-4")
Maps covered: `MAP_ROUTE_3`, `MAP_MOUNT_MOON`, `MAP_MOUNT_MOON_SQUARE`, `MAP_MOUNT_MOON_GIFT_SHOP`, `MAP_ROUTE_4`, `MAP_VIRIDIAN_CITY`, `MAP_TRAINER_HOUSE_1F`, `MAP_TRAINER_HOUSE_B1F`, `MAP_ROUTE_1`, `MAP_PALLET_TOWN`, `MAP_OAKS_LAB`
Badges / key milestones in this section: no badge. The milestones are `EVENT_BEAT_RIVAL_IN_MT_MOON` (the last mandatory Silver fight, and the unlock for both rival re-encounters), `ENGINE_FLYPOINT_VIRIDIAN` and `ENGINE_FLYPOINT_PALLET` (Fly targets), `EVENT_TALKED_TO_OAK_IN_KANTO` (Oak's Kanto-badge conversation, which later opens Mt. Silver via `EVENT_OPENED_MT_SILVER`), plus the `HP_UP` item ball on Route 4.

Note on paths: everything under `maps/`, `data/`, `constants/`, `engine/`, `macros/` is relative to the pokegold checkout at `/Users/bryanbassett/Documents/development/pokegold`. Everything under `src/` and `tests/` is relative to this repo root. Addresses are `bank:addr` from `/Users/bryanbassett/Documents/development/pokegold-symbols/pokegold.sym`.

---

## 1. Route order

The section starts with the player already standing on Route 3 (arriving from Pewter City, which belongs to the previous section) and ends by handing off to Route 21 (next section).

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `MAP_ROUTE_3` | `maps/Route3.asm` | west connection from `PEWTER_CITY` (`data/maps/attributes.asm:377`) | warp 1 at (52, 1) -> `MOUNT_MOON` warp 1 | four trainers east: Warren, Jimmy, Otis, Burt |
| 2 | `MAP_ROUTE_3` -> Pewter and back | - | - | - | walkthrough tells the player to heal at the Pewter Pokemon Center and save before Mt. Moon (no asm gate; pure advice) |
| 3 | `MAP_MOUNT_MOON` | `maps/MountMoon.asm` | warp 1 at (3, 3) | see below | mandatory rival battle, fired by `scene_script MountMoonRivalEncounterScene, SCENE_MOUNTMOON_RIVAL_BATTLE` |
| 4 | `MAP_MOUNT_MOON` (north lane) | `maps/MountMoon.asm` | warp 3 at (13, 3) -> warp 7 at (25, 3) | warp 5 at (25, 5) -> `MOUNT_MOON_SQUARE` warp 1 | "go right from your Rival battle, up the ladder, and then out" |
| 5 | `MAP_MOUNT_MOON_SQUARE` | `maps/MountMoonSquare.asm` | warp 1 at (20, 5) | warp 3 at (13, 7) -> gift shop; warp 2 at (22, 11) -> `MOUNT_MOON` warp 6 | the outdoor shop and the Monday-night Clefairy dance |
| 6 | `MAP_MOUNT_MOON_GIFT_SHOP` | `maps/MountMoonGiftShop.asm` | warp 1 (3, 7) / warp 2 (4, 7) | either warp -> `MOUNT_MOON_SQUARE` warp 3 | "a shop outside that sells Fresh Water, Soda Pop, and Lemonade" (`MART_MT_MOON`) |
| 7 | `MAP_MOUNT_MOON` (south lane) | `maps/MountMoon.asm` | warp 6 at (25, 15) | warp 8 at (25, 13) -> warp 4 at (15, 11), then warp 2 at (15, 15) | "go down into another cave entrance and down the ladder, you'll make your way through" |
| 8 | `MAP_ROUTE_4` | `maps/Route4.asm` | warp 1 at (2, 5) from `MOUNT_MOON` warp 2 | east connection to `CERULEAN_CITY` (not taken here) | three trainers: Hope, Hank, Sharon; `HP_UP` item ball at (26, 3) |
| 9 | `MAP_VIRIDIAN_CITY` | `maps/ViridianCity.asm` | walkthrough routes Fly -> Pewter -> `ROUTE_2` -> `VIRIDIAN_FOREST` -> Viridian (those two maps belong to a neighbouring section) | warp 3 at (23, 15) -> `TRAINER_HOUSE_1F` | Trainer House daily battle |
| 10 | `MAP_TRAINER_HOUSE_1F` | `maps/TrainerHouse1F.asm` | warp 1/2 at (2, 13)/(3, 13) | warp 3 at (8, 2) -> `TRAINER_HOUSE_B1F` warp 1 | "simply go downstairs in that house" |
| 11 | `MAP_TRAINER_HOUSE_B1F` | `maps/TrainerHouseB1F.asm` | warp 1 at (9, 4) | same warp back up | coord_event at (7, 3) runs `TrainerHouseReceptionistScript`, the once-a-day CAL battle |
| 12 | `MAP_ROUTE_1` | `maps/Route1.asm` | north connection from `VIRIDIAN_CITY` (`data/maps/attributes.asm:267`) | south connection to `PALLET_TOWN` | Bitter Berry fruit tree, Schoolboy Danny, Cooltrainerf Quinn |
| 13 | `MAP_PALLET_TOWN` | `maps/PalletTown.asm` | north connection from `ROUTE_1` | warp 3 at (12, 11) -> `OAKS_LAB` warp 1 | Oak's badge conversation; sets `ENGINE_FLYPOINT_PALLET` |
| 14 | `MAP_OAKS_LAB` | `maps/OaksLab.asm` | warp 1 at (4, 11) / warp 2 at (5, 11) | either warp -> `PALLET_TOWN` warp 3 | "Talk with Professor Oak in his lab" |
| 15 | hand-off | - | - | south connection from `PALLET_TOWN` to `ROUTE_21` (`data/maps/attributes.asm:273`) | "Now, surf south onto Route 21" - Route 21 belongs to the next section; stopping here. |

`ROUTE_2` and `VIRIDIAN_FOREST` are named in the walkthrough only as the walking route from Pewter back to Viridian; they are not covered here.

---

## 2. Maps

### MAP_ROUTE_3

- Script: `maps/Route3.asm` (`Route3_MapEvents` = `50:514b`)
- Blocks: `maps/Route3.blk`
- Header: `data/maps/maps.asm:321` -> `map Route3, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_3, MUSIC_ROUTE_3, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:296` -> `map_const ROUTE_3, 30, 9` (30x9 blocks = 60x18 walk cells), group `PEWTER`
- Connections: `data/maps/attributes.asm:377` -> west `PewterCity` (offset -5), east `Route4` (offset 0). No north/south.
- Scene scripts: none (`def_scene_scripts` is empty). Callbacks: none.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 52 | 1 | `MOUNT_MOON` | 1 |

**Coord events** (`def_coord_events`)

None.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 49 | 13 | `BGEVENT_READ` | `Route3MtMoonSquareSign` -> `Route3MtMoonSquareSignText` ("MT.MOON SQUARE / Just go up the stairs.") |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE3_FISHER1` | `SPRITE_FISHER` | 26 | 12 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerFirebreatherOtis` (`50:4f26`) | -1 |
| `ROUTE3_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 11 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 2 | `TrainerYoungsterWarren` (`50:4f3a`) | -1 |
| `ROUTE3_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 20 | 4 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerYoungsterJimmy` (`50:4f4e`) | -1 |
| `ROUTE3_FISHER2` | `SPRITE_FISHER` | 49 | 5 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerFirebreatherBurt` (`50:4f62`) | -1 |

Column order comes from `macros/scripts/maps.asm:113` (`object_event x, y, sprite, movement, radius_x, radius_y, hour1, hour2, palette, type, sight_range, script, event_flag`). All four here have radius 0/0 and hour limits `-1, -1` (always present).

**Scripts of interest**

- `TrainerFirebreatherOtis` / `TrainerYoungsterWarren` / `TrainerYoungsterJimmy` / `TrainerFirebreatherBurt`: each is a plain `trainer CLASS, ID, EVENT_BEAT_*, SeenText, BeatenText, 0, .Script` header. `.Script` is `endifjustbattled / opentext / writetext <After>Text / waitbutton / closetext / end`. No items, no flags beyond the trainer's own beaten flag, no warps.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_FIREBREATHER_OTIS` | `constants/event_flags.asm:576` | `trainer` header | set on win; trainer will not re-challenge |
| `EVENT_BEAT_FIREBREATHER_BURT` | `constants/event_flags.asm:579` | `trainer` header | same |
| `EVENT_BEAT_YOUNGSTER_WARREN` | `constants/event_flags.asm:971` | `trainer` header | same |
| `EVENT_BEAT_YOUNGSTER_JIMMY` | `constants/event_flags.asm:972` | `trainer` header | same |

**Items**

None on this map.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `WARREN` | `YOUNGSTER` | YOUNGSTER (9), line 386 | L35 FEAROW (`TRAINERTYPE_NORMAL`) | `TrainerYoungsterWarren` | none |
| `JIMMY` | `YOUNGSTER` | YOUNGSTER (10), line 391 | L33 RATICATE, L33 ARBOK | `TrainerYoungsterJimmy` | none |
| `OTIS` | `FIREBREATHER` | FIREBREATHER (1), line 2334 | L29 MAGMAR, L32 WEEZING, L29 MAGMAR | `TrainerFirebreatherOtis` | none |
| `BURT` | `FIREBREATHER` | FIREBREATHER (4), line 2353 | L32 KOFFING, L32 SLUGMA | `TrainerFirebreatherBurt` | none |

All four are `TRAINERTYPE_NORMAL`, i.e. level+species only, moves come from the learnset.

**Wild encounters**

`data/wild/kanto_grass.asm:314` `def_grass_wildmons ROUTE_3`, rates `10 percent, 10 percent, 10 percent` (morn/day/nite). The table is version-split:

- `IF DEF(_GOLD)` - morn/day: L5 SPEAROW, L5 RATTATA, L8 SPEAROW, L6 JIGGLYPUFF, L10 RATTATA, L8 SPEAROW, L8 SPEAROW; nite: L5 RATTATA, L5 ZUBAT, L8 RATTATA, L6 JIGGLYPUFF, L10 RATTATA, L8 RATTATA, L8 RATTATA.
- `ELIF DEF(_SILVER)` - morn/day: L5 SPEAROW, L5 RATTATA, L8 EKANS, L6 JIGGLYPUFF, L10 ARBOK, L8 SPEAROW, L8 SPEAROW; nite: L5 RATTATA, L5 ZUBAT, L8 EKANS, L6 JIGGLYPUFF, L10 ARBOK, L8 RATTATA, L8 RATTATA.

The walkthrough's "Rattata / Ekans / Arbok" is the **Silver** column. On Gold there is no Ekans or Arbok on Route 3. See section 6.

No water/fishing/headbutt entry for `ROUTE_3` in `data/wild/kanto_water.asm` or `data/wild/treemons.asm`.

---

### MAP_MOUNT_MOON

- Script: `maps/MountMoon.asm` (`MountMoon_MapEvents` = `42:587e`, `MountMoonRivalBattleScript` = `42:55b0`)
- Blocks: `maps/MountMoon.blk`
- Header: `data/maps/maps.asm:154` -> `map MountMoon, TILESET_CAVE, CAVE, LANDMARK_MT_MOON, MUSIC_MT_MOON, TRUE, PALETTE_NITE, FISHGROUP_SHORE` (the `TRUE` column is the phone/"requires flash-style" fixed palette flag position in the `map` macro; palette is `PALETTE_NITE`, so the cave is dark-toned regardless of clock)
- Dimensions: `constants/map_constants.asm:141` -> `map_const MOUNT_MOON, 15, 9` (15x9 blocks = 30x18 walk cells), group `CERULEAN`-adjacent index 76 in its group listing
- Attributes: `data/maps/attributes.asm:488` -> `map_attributes MountMoon, MOUNT_MOON, $09`. **No connections** - the map is entered and left only through warps.
- Scene var: `data/maps/scenes.asm:46` -> `wMountMoonSceneID`

**Scene scripts** (`def_scene_scripts`, ids allocated from 0 by `macros/scripts/maps.asm:12`)

| scene id | constant | script |
|---|---|---|
| 0 | `SCENE_MOUNTMOON_RIVAL_BATTLE` | `MountMoonRivalEncounterScene` -> `sdefer MountMoonRivalBattleScript` |
| 1 | `SCENE_MOUNTMOON_NOOP` | `MountMoonNoopScene` -> `end` |

Nothing in the game sets scene 0; it is the power-on default, so the very first entry to Mt. Moon fires the rival cutscene. `RunSceneScript` is polled in `engine/overworld/events.asm:256`, after `CheckTrainerEvent` and `CheckTileEvent`, so it lands on the first player-event poll after the warp completes.

**Callbacks**: none.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 3 | `ROUTE_3` | 1 |
| 2 | 15 | 15 | `ROUTE_4` | 1 |
| 3 | 13 | 3 | `MOUNT_MOON` | 7 |
| 4 | 15 | 11 | `MOUNT_MOON` | 8 |
| 5 | 25 | 5 | `MOUNT_MOON_SQUARE` | 1 |
| 6 | 25 | 15 | `MOUNT_MOON_SQUARE` | 2 |
| 7 | 25 | 3 | `MOUNT_MOON` | 3 |
| 8 | 25 | 13 | `MOUNT_MOON` | 4 |

Warps 3<->7 and 4<->8 are the two internal ladder pairs. Read as a graph:
`ROUTE_3 -(1)- (3,3) ... (13,3) -(3/7)- (25,3) ... (25,5) -(5)- SQUARE`
and `SQUARE -(2/6)- (25,15) ... (25,13) -(8/4)- (15,11) ... (15,15) -(2)- ROUTE_4`.

**Coord events**: none. **BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MOUNTMOON_RIVAL` | `SPRITE_RIVAL` | 7 | 3 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT`, sight 0 | `ObjectEvent` (the shared ROM0 stub) | `EVENT_MT_MOON_RIVAL` |

Flag semantics (`engine/overworld/scripting.asm:879-898`): `appear` clears the object's event flag, `disappear` sets it. `EVENT_MT_MOON_RIVAL` therefore starts **clear** = rival visible, and `disappear MOUNTMOON_RIVAL` at the end of the cutscene sets it = rival gone forever.

**Scripts of interest**

`MountMoonRivalBattleScript` (`42:55b0`), reached through `sdefer` from scene 0:

1. `turnobject PLAYER, RIGHT`, `showemote EMOTE_SHOCK, PLAYER, 15`, `special FadeOutMusic`, `pause 15`.
2. `applymovement MOUNTMOON_RIVAL, MountMoonRivalMovementBefore` = three `step LEFT` (rival walks from (7,3) toward the player at the (3,3) entrance).
3. `playmusic MUSIC_RIVAL_ENCOUNTER`, `opentext`, `writetext MountMoonRivalTextBefore`, `waitbutton`, `closetext`.
4. Starter branch:
   - `checkevent EVENT_GOT_TOTODILE_FROM_ELM` -> `.Totodile` -> `loadtrainer RIVAL2, RIVAL2_1_CHIKORITA`
   - `checkevent EVENT_GOT_CHIKORITA_FROM_ELM` -> `.Chikorita` -> `loadtrainer RIVAL2, RIVAL2_1_CYNDAQUIL`
   - fallthrough (player took Cyndaquil) -> `loadtrainer RIVAL2, RIVAL2_1_TOTODILE`
   Note the label names describe the *player's* starter; the constant names describe the *rival's*. Each arm does `winlosstext MountMoonRivalTextWin, MountMoonRivalTextLoss`, `setlasttalked MOUNTMOON_RIVAL`, `startbattle`, `dontrestartmapmusic`, `reloadmapafterbattle`.
5. `.FinishBattle`: `playmusic MUSIC_RIVAL_AFTER`, after-text, `turnobject PLAYER, UP`, `turnobject PLAYER, RIGHT`, `applymovement MOUNTMOON_RIVAL, MountMoonRivalMovementAfter` (`RIGHT, RIGHT, DOWN x5`), `disappear MOUNTMOON_RIVAL`, `setscene SCENE_MOUNTMOON_NOOP`, `setevent EVENT_BEAT_RIVAL_IN_MT_MOON`, `playmapmusic`, `end`.

The battle is unavoidable: there is no `iftrue` skip and no branch that reaches the rest of the map without running it, because the scene id is 0 until `setscene` runs at the very end of the script.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_MT_MOON_RIVAL` | `constants/event_flags.asm:1308` | object row; `disappear` in `MountMoonRivalBattleScript` | clear = rival object on the map |
| `EVENT_BEAT_RIVAL_IN_MT_MOON` | `constants/event_flags.asm:456` | set here; read by `maps/DragonsDenB1F.asm:13` and `maps/IndigoPlateauPokecenter1F.asm:45,67` | unlocks both post-game rival re-encounters |
| `EVENT_GOT_TOTODILE_FROM_ELM` | `constants/event_flags.asm:37` | read here | selects rival party |
| `EVENT_GOT_CHIKORITA_FROM_ELM` | `constants/event_flags.asm:38` | read here | selects rival party |
| `SCENE_MOUNTMOON_RIVAL_BATTLE` = 0 | `maps/MountMoon.asm:6` (allocated by `def_scene_scripts`) | `wMountMoonSceneID` | 0 = cutscene armed |
| `SCENE_MOUNTMOON_NOOP` = 1 | `maps/MountMoon.asm:7` | `setscene` at end of script | 1 = cutscene spent |

**Items**: none on this map.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `RIVAL2_1_CHIKORITA` | `RIVAL2` (`constants/trainer_constants.asm:424`) | RIVAL2 (1), line 2042 | L41 SNEASEL (Quick Attack, Screech, Faint Attack, Fury Cutter); L42 GOLBAT (Leech Life, Bite, Confuse Ray, Wing Attack); L41 MAGNETON (ThunderShock, SonicBoom, Thunder Wave, Swift); L43 GENGAR (Mean Look, Curse, Shadow Ball, Confuse Ray); L43 ALAKAZAM (Disable, Recover, Future Sight, Psychic); **L45 MEGANIUM** (Razor Leaf, PoisonPowder, Body Slam, Light Screen) | `MountMoonRivalBattleScript` `.Totodile` | rematch at Indigo Plateau / Dragon's Den, see gates |
| `RIVAL2_1_CYNDAQUIL` | `RIVAL2` | RIVAL2 (2), line 2052 | same first five, **L45 TYPHLOSION** (SmokeScreen, Quick Attack, Flame Wheel, Swift) | `.Chikorita` | same |
| `RIVAL2_1_TOTODILE` | `RIVAL2` | RIVAL2 (3), line 2062 | same first five, **L45 FERALIGATR** (Rage, Water Gun, Scary Face, Slash) | fallthrough | same |

`TRAINERTYPE_MOVES`, so the four move slots above are exactly what the rival fields. `RIVAL2_2_*` (rows 4-6, levels 45-50 with Crobat) are the Indigo Plateau rematch parties, not this fight.

**Wild encounters**

`data/wild/kanto_grass.asm:33` `def_grass_wildmons MOUNT_MOON`, rates `6 percent, 6 percent, 6 percent`.

- `IF DEF(_GOLD)` - identical morn/day/nite: L6 ZUBAT, L8 GEODUDE, L8 SANDSHREW, L12 PARAS, L10 SANDSLASH, L8 CLEFAIRY, L8 CLEFAIRY.
- `ELIF DEF(_SILVER)` - L6 ZUBAT, L8 GEODUDE, L8 ZUBAT, L12 PARAS, L10 GEODUDE, L8 CLEFAIRY, L8 CLEFAIRY.

The walkthrough's "Zubat / Parus [sic, Paras] / Geodude" is a subset of both columns. Gold additionally has Sandshrew and Sandslash, and both versions have a 2-slot Clefairy line the walkthrough does not mention.

---

### MAP_MOUNT_MOON_SQUARE

- Script: `maps/MountMoonSquare.asm` (`MountMoonSquare_MapEvents` = `5b:6827`, `ClefairyDance` = `5b:676a`)
- Blocks: `maps/MountMoonSquare.blk`
- Header: `data/maps/maps.asm:342` -> `map MountMoonSquare, TILESET_KANTO, ROUTE, LANDMARK_MT_MOON, MUSIC_MT_MOON_SQUARE, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:316` -> `map_const MOUNT_MOON_SQUARE, 15, 9` (30x18 walk cells), group `FAST_SHIP`
- Attributes: `data/maps/attributes.asm:595` -> `$2d`, no connections
- Scene var: `data/maps/scenes.asm:66` -> `wMountMoonSquareSceneID`

**Scene scripts**

| scene id | constant | script |
|---|---|---|
| 0 | `SCENE_MOUNTMOONSQUARE_CLEFAIRY_DANCE` | `MountMoonSquareNoopScene` -> `end` (the constant only exists to name the coord_event's scene, the scene script itself is a no-op and the id is never changed) |

**Callbacks**

- `MAPCALLBACK_NEWMAP` -> `MountMoonSquareDisappearMoonStoneCallback`: `setevent EVENT_MOUNT_MOON_SQUARE_HIDDEN_MOON_STONE` / `endcallback`. Every fresh entry re-hides the Moon Stone.
- `MAPCALLBACK_OBJECTS` -> `MountMoonSquareDisappearRockCallback`: `disappear MOUNTMOONSQUARE_ROCK` / `endcallback`. The smashable rock is hidden on every object refresh; it exists on-screen only during the dance cutscene, which `appear`s it mid-script.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 20 | 5 | `MOUNT_MOON` | 5 |
| 2 | 22 | 11 | `MOUNT_MOON` | 6 |
| 3 | 13 | 7 | `MOUNT_MOON_GIFT_SHOP` | 1 |

**Coord events**

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_MOUNTMOONSQUARE_CLEFAIRY_DANCE` (0) | 7 | 11 | `ClefairyDance` (`5b:676a`) | the Monday-night Clefairy cutscene; always armed because the scene id is never advanced |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 7 | 7 | `BGEVENT_ITEM` | `MountMoonSquareHiddenMoonStone` (`5b:67e8`) = `hiddenitem MOON_STONE, EVENT_MOUNT_MOON_SQUARE_HIDDEN_MOON_STONE` |
| 17 | 7 | `BGEVENT_READ` | `DontLitterSign` -> `DontLitterSignText` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MOUNTMOONSQUARE_FAIRY1` | `SPRITE_FAIRY` | 6 | 6 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT`, sight 0 | `ObjectEvent` | `EVENT_MT_MOON_SQUARE_CLEFAIRY` |
| `MOUNTMOONSQUARE_FAIRY2` | `SPRITE_FAIRY` | 7 | 6 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT`, sight 0 | `ObjectEvent` | `EVENT_MT_MOON_SQUARE_CLEFAIRY` |
| `MOUNTMOONSQUARE_ROCK` | `SPRITE_ROCK` | 7 | 7 | `SPRITEMOVEDATA_SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT`, sight 0 | `MtMoonSquareRock` (`5b:67ee`) = `jumpstd SmashRockScript` | `EVENT_MT_MOON_SQUARE_ROCK` |

**Scripts of interest**

`ClefairyDance` - the whole cutscene is guarded by three conditions in a row, all of which must pass:

```
checkflag ENGINE_MT_MOON_SQUARE_CLEFAIRY   ; iftrue .NoDancing  (once per save)
readvar VAR_WEEKDAY / ifnotequal MONDAY, .NoDancing
checktime NITE / iffalse .NoDancing
```

Then: `appear` both fairies, `applymovement PLAYER, PlayerWalksUpToDancingClefairies` (one `step UP`, so the player ends on (7, 10)), `pause 15`, `appear MOUNTMOONSQUARE_ROCK`, a long `follow`/`applymovement`/`cry CLEFAIRY` dance across `ClefairyDanceStep1..7`, `showemote EMOTE_SHOCK` when the Clefairy notice the player, `applymovement ... ClefairyFleeMovement`, `disappear` both fairies, `stopfollow`, then the payoff:

```
clearevent EVENT_MOUNT_MOON_SQUARE_HIDDEN_MOON_STONE
setflag ENGINE_MT_MOON_SQUARE_CLEFAIRY
```

So the Moon Stone at bg_event (7, 7) becomes takeable, but the rock object was `appear`ed onto that exact cell during the cutscene and is only cleared by `MAPCALLBACK_OBJECTS` on the next map load. That is the asm behind Thard_Verad's "Bring Rock Smash": you either smash the rock at (7, 7) in the same visit, or leave and come back (the `MAPCALLBACK_NEWMAP` callback then re-sets the Moon Stone flag and re-hides the item, so leaving loses it). See section 6.

`MtMoonSquareRock` -> `jumpstd SmashRockScript` (`engine/events/std_scripts.asm:199`) -> `farsjump AskRockSmashScript` (`engine/events/overworld.asm:1365`), which is `callasm HasRockSmash` (`engine/events/overworld.asm:1386`: `ld d, ROCK_SMASH / call CheckPartyMove`) then a yes/no prompt. **No badge check** - Rock Smash in Gen 2 is TM08, not an HM.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_MOUNT_MOON_SQUARE_HIDDEN_MOON_STONE` | `constants/event_flags.asm:236` | set by `MAPCALLBACK_NEWMAP`; cleared at the end of `ClefairyDance`; consumed by `hiddenitem` | set = Moon Stone not present |
| `EVENT_MT_MOON_SQUARE_CLEFAIRY` | `constants/event_flags.asm:1307` | object rows; `appear`/`disappear` in `ClefairyDance` | clear = the two Clefairy are on the map (only during the cutscene) |
| `EVENT_MT_MOON_SQUARE_ROCK` | `constants/event_flags.asm:1306` | object row; `disappear` in the OBJECTS callback, `appear` mid-cutscene | clear = rock is standing on (7, 7) |
| `ENGINE_MT_MOON_SQUARE_CLEFAIRY` | `constants/engine_flags.asm:106` | `checkflag`/`setflag` in `ClefairyDance` | set = the dance has been seen once and will never replay |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `MOON_STONE` | hidden item on (7, 7), only after the Clefairy dance clears its flag | `bg_event 7, 7, BGEVENT_ITEM, MountMoonSquareHiddenMoonStone` | `EVENT_MOUNT_MOON_SQUARE_HIDDEN_MOON_STONE` |

**Trainers**: none. **Wild encounters**: no `MOUNT_MOON_SQUARE` entry in `data/wild/kanto_grass.asm` or `kanto_water.asm`.

---

### MAP_MOUNT_MOON_GIFT_SHOP

- Script: `maps/MountMoonGiftShop.asm` (`MountMoonGiftShop_MapEvents` = `5b:68b6`, `MountMoonGiftShopClerkScript` = `5b:6877`)
- Blocks: `data/maps/blocks.asm:701` -> `INCBIN "maps/GiftShop.blk"` (shared blocks file, no `MountMoonGiftShop.blk`)
- Header: `data/maps/maps.asm:343` -> `map MountMoonGiftShop, TILESET_TRADITIONAL_HOUSE, INDOOR, LANDMARK_MT_MOON, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:317` -> `map_const MOUNT_MOON_GIFT_SHOP, 4, 4` (8x8 walk cells)
- Attributes: `data/maps/attributes.asm:596` -> `$00`, no connections
- No scene scripts, no callbacks.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `MOUNT_MOON_SQUARE` | 3 |
| 2 | 4 | 7 | `MOUNT_MOON_SQUARE` | 3 |

**Coord events**: none. **BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MOUNTMOONGIFTSHOP_GRAMPS1` | `SPRITE_GRAMPS` | 4 | 3 | `SPRITEMOVEDATA_STANDING_DOWN`, hours `-1, MORN` | `OBJECTTYPE_SCRIPT` | `MountMoonGiftShopClerkScript` | -1 |
| `MOUNTMOONGIFTSHOP_GRAMPS2` | `SPRITE_GRAMPS` | 1 | 2 | `SPRITEMOVEDATA_STANDING_RIGHT`, hours `-1, DAY` | `OBJECTTYPE_SCRIPT` | `MountMoonGiftShopClerkScript` | -1 |
| `MOUNTMOONGIFTSHOP_LASS1` | `SPRITE_LASS` | 1 | 6 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius 1,0), hours `-1, MORN` | `OBJECTTYPE_SCRIPT` | `MountMoonGiftShopLassScript` | -1 |
| `MOUNTMOONGIFTSHOP_LASS2` | `SPRITE_LASS` | 5 | 4 | `SPRITEMOVEDATA_WALK_UP_DOWN` (radius 0,1), hours `-1, DAY` | `OBJECTTYPE_SCRIPT` | `MountMoonGiftShopLassScript` | -1 |

The `hour1 = -1` form means `hour2` is a time-of-day mask (`macros/scripts/maps.asm:123`). **There is no NITE clerk**: at night the shop is unattended, which the walkthrough does not mention.

**Scripts of interest**

`MountMoonGiftShopClerkScript`: `faceplayer / opentext / pokemart MARTTYPE_STANDARD, MART_MT_MOON / closetext / end`.

**Items** (`MartMtMoon`, `data/items/marts.asm:374`, 6 items)

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `POKE_DOLL` | bought | `MartMtMoon` | - |
| `FRESH_WATER` | bought | `MartMtMoon` | - |
| `SODA_POP` | bought | `MartMtMoon` | - |
| `LEMONADE` | bought | `MartMtMoon` | - |
| `REPEL` | bought | `MartMtMoon` | - |
| `PORTRAITMAIL` | bought | `MartMtMoon` | - |

The walkthrough names only Fresh Water / Soda Pop / Lemonade; the other three are real and in the same list.

**Trainers**: none. **Wild encounters**: none.

---

### MAP_ROUTE_4

- Script: `maps/Route4.asm` (`Route4_MapEvents` = `50:5338`)
- Blocks: `maps/Route4.blk`
- Header: `data/maps/maps.asm:216` -> `map Route4, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_4, MUSIC_ROUTE_3, FALSE, PALETTE_AUTO, FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:198` -> `map_const ROUTE_4, 20, 9` (40x18 walk cells), group `CERULEAN`
- Connections: `data/maps/attributes.asm:381` -> west `Route3` (offset 0), east `CeruleanCity` (offset -5)
- No scene scripts, no callbacks.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 5 | `MOUNT_MOON` | 2 |

**Coord events**: none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 3 | 7 | `BGEVENT_READ` | `MtMoonSquareSign` -> `MtMoonSquareSignText` |
| 10 | 3 | `BGEVENT_ITEM` | `Route4HiddenUltraBall` (`50:51d2`) = `hiddenitem ULTRA_BALL, EVENT_ROUTE_4_HIDDEN_ULTRA_BALL` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE4_YOUNGSTER` | `SPRITE_YOUNGSTER` | 17 | 9 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerBirdKeeperHank` (`50:5191`) | -1 |
| `ROUTE4_LASS1` | `SPRITE_LASS` | 10 | 8 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER`, sight 5 | `TrainerPicnickerHope` (`50:51a5`) | -1 |
| `ROUTE4_LASS2` | `SPRITE_LASS` | 21 | 6 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerPicnickerSharon` (`50:51b9`) | -1 |
| `ROUTE4_POKE_BALL` | `SPRITE_POKE_BALL` | 26 | 3 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `Route4HPUp` (`50:51d0`) = `itemball HP_UP` | `EVENT_ROUTE_4_HP_UP` |

**Scripts of interest**

All three trainer scripts are the standard `endifjustbattled / opentext / writetext <After>Text / waitbutton / closetext / end`. `Route4HPUp` is not bytecode at all - `itemball HP_UP` is two raw bytes (`macros/scripts/maps.asm`, `dwb`-style), read by the engine's item-ball path rather than the script VM.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_BIRD_KEEPER_HANK` | `constants/event_flags.asm:501` | `trainer` header | set on win |
| `EVENT_BEAT_PICNICKER_HOPE` | `constants/event_flags.asm:641` | `trainer` header | set on win |
| `EVENT_BEAT_PICNICKER_SHARON` | `constants/event_flags.asm:642` | `trainer` header | set on win |
| `EVENT_ROUTE_4_HP_UP` | `constants/event_flags.asm:1322` | item-ball object row | set = ball already taken (object hidden) |
| `EVENT_ROUTE_4_HIDDEN_ULTRA_BALL` | `constants/event_flags.asm:241` | `hiddenitem` | set = Ultra Ball already found |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `HP_UP` | walk onto / face and A the Poke Ball object at (26, 3) | `object_event ... OBJECTTYPE_ITEMBALL, 0, Route4HPUp` | `EVENT_ROUTE_4_HP_UP` |
| `ULTRA_BALL` | hidden, face (10, 3) and press A, or Itemfinder | `bg_event 10, 3, BGEVENT_ITEM, Route4HiddenUltraBall` | `EVENT_ROUTE_4_HIDDEN_ULTRA_BALL` |

The walkthrough lists only the HP Up.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `HOPE` | `PICNICKER` | PICNICKER (6), line 2611 | L34 FLAAFFY | `TrainerPicnickerHope` | none |
| `HANK` | `BIRD_KEEPER` | BIRD_KEEPER (8), line 569 | L12 PIDGEY, L34 PIDGEOT | `TrainerBirdKeeperHank` | none |
| `SHARON` | `PICNICKER` | PICNICKER (7), line 2616 | L31 FURRET, L33 RAPIDASH | `TrainerPicnickerSharon` | none |

All `TRAINERTYPE_NORMAL`. The L12 Pidgey in Hank's party is not a typo in the walkthrough; it really is level 12.

**Wild encounters**

- Grass: `data/wild/kanto_grass.asm:369` `def_grass_wildmons ROUTE_4`, rates `10/10/10 percent`.
  - `IF DEF(_GOLD)` - morn/day: L5 SPEAROW, L5 RATTATA, L8 SPEAROW, L6 JIGGLYPUFF, L10 RATTATA, L8 SPEAROW, L8 SPEAROW; nite: L5 SPEAROW, L5 ZUBAT, L8 RATTATA, L6 JIGGLYPUFF, L10 RATTATA, L8 RATTATA, L8 RATTATA.
  - `ELIF DEF(_SILVER)` - morn/day: L5 SPEAROW, L5 RATTATA, L8 EKANS, L6 JIGGLYPUFF, L10 ARBOK, L8 SPEAROW, L8 SPEAROW; nite: L5 RATTATA, L5 ZUBAT, L8 EKANS, L6 JIGGLYPUFF, L10 ARBOK, L8 RATTATA, L8 RATTATA.
  The walkthrough's "Rattata / Spearow / Arbok" is the Silver column again.
- Water: `data/wild/kanto_water.asm:5` `def_water_wildmons ROUTE_4`, 4 percent: L10 GOLDEEN, L5 GOLDEEN, L10 SEAKING.
- Fishing group `FISHGROUP_LAKE` from the map header.

---

### MAP_VIRIDIAN_CITY

- Script: `maps/ViridianCity.asm` (`ViridianCity_MapEvents` = `4e:4486`)
- Blocks: `maps/ViridianCity.blk`
- Header: `data/maps/maps.asm:457` -> `map ViridianCity, TILESET_KANTO, TOWN, LANDMARK_VIRIDIAN_CITY, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_AUTO, FISHGROUP_POND`
- Dimensions: `constants/map_constants.asm:423` -> `map_const VIRIDIAN_CITY, 20, 18` (40x36 walk cells), group `VIRIDIAN`
- Connections: `data/maps/attributes.asm:259` -> north `Route2` (offset 5), south `Route1` (offset 10), west `Route22` (offset 4)
- Spawn: `data/maps/spawn_points.asm:15` -> `spawn VIRIDIAN_CITY, 23, 26`; flypoint `data/maps/flypoints.asm:19` -> `db LANDMARK_VIRIDIAN_CITY, SPAWN_VIRIDIAN`

**Scene scripts**: none. **Callbacks**: `MAPCALLBACK_NEWMAP` -> `ViridianCityFlypointCallback` = `setflag ENGINE_FLYPOINT_VIRIDIAN / endcallback`.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 32 | 7 | `VIRIDIAN_GYM` | 1 |
| 2 | 21 | 9 | `VIRIDIAN_NICKNAME_SPEECH_HOUSE` | 1 |
| 3 | 23 | 15 | `TRAINER_HOUSE_1F` | 1 |
| 4 | 29 | 19 | `VIRIDIAN_MART` | 2 |
| 5 | 23 | 25 | `VIRIDIAN_POKECENTER_1F` | 1 |

The Trainer House (23, 15) is exactly 10 cells due north of the Pokemon Center (23, 25), which is the walkthrough's "north from the Pokemon Center".

**Coord events**: none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 17 | 17 | `BGEVENT_READ` | `ViridianCitySign` |
| 27 | 7 | `BGEVENT_READ` | `ViridianGymSign` |
| 19 | 1 | `BGEVENT_READ` | `ViridianCityWelcomeSign` |
| 21 | 15 | `BGEVENT_READ` | `TrainerHouseSign` |
| 24 | 25 | `BGEVENT_READ` | `ViridianCityPokecenterSign` (`jumpstd PokecenterSignScript`) |
| 30 | 19 | `BGEVENT_READ` | `ViridianCityMartSign` (`jumpstd MartSignScript`) |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VIRIDIANCITY_GRAMPS1` | `SPRITE_GRAMPS` | 18 | 5 | `SPRITEMOVEDATA_WANDER` (radius 2,2) | `OBJECTTYPE_SCRIPT` | `ViridianCityCoffeeGramps` | -1 |
| `VIRIDIANCITY_GRAMPS2` | `SPRITE_GRAMPS` | 30 | 8 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `ViridianCityGrampsNearGym` | -1 |
| `VIRIDIANCITY_FISHER` | `SPRITE_FISHER` | 6 | 23 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `ViridianCityDreamEaterFisher` (`4e:4032`) | -1 |
| `VIRIDIANCITY_YOUNGSTER` | `SPRITE_YOUNGSTER` | 17 | 21 | `SPRITEMOVEDATA_WANDER` (radius 3,3) | `OBJECTTYPE_SCRIPT` | `ViridianCityYoungsterScript` | -1 |

**Scripts of interest**

- `ViridianCityFlypointCallback` - runs on `MAPCALLBACK_NEWMAP`, so simply *entering* Viridian City registers it as a Fly destination.
- `ViridianCityDreamEaterFisher` (`4e:4032`) - `faceplayer / opentext / checkevent EVENT_GOT_TM42_DREAM_EATER / iftrue .GotDreamEater / writetext ... / promptbutton / verbosegiveitem TM_DREAM_EATER / iffalse .NoRoomForDreamEater / setevent EVENT_GOT_TM42_DREAM_EATER`. A free TM42 the walkthrough never mentions.
- `ViridianCityGrampsNearGym` - branches on `EVENT_BLUE_IN_CINNABAR`; flavour only.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_VIRIDIAN` | `constants/engine_flags.asm:68` | set by `ViridianCityFlypointCallback` | Fly target unlocked on first visit |
| `EVENT_GOT_TM42_DREAM_EATER` | `constants/event_flags.asm:223` | `ViridianCityDreamEaterFisher` | one-time TM |
| `EVENT_BLUE_IN_CINNABAR` | `constants/event_flags.asm:1303` | read only, here | selects the gym gramps' text |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `TM_DREAM_EATER` (TM42) | talk to `VIRIDIANCITY_FISHER` at (6, 23) | `ViridianCityDreamEaterFisher`, `verbosegiveitem` | `EVENT_GOT_TM42_DREAM_EATER` |

**Trainers**: none on the overworld map.

**Wild encounters**: `data/wild/kanto_water.asm:124` `def_water_wildmons VIRIDIAN_CITY`, 2 percent (surf only). No grass entry for `VIRIDIAN_CITY`.

---

### MAP_TRAINER_HOUSE_1F

- Script: `maps/TrainerHouse1F.asm` (`TrainerHouse1F_MapEvents` = `5f:48f9`)
- Blocks: `maps/TrainerHouse1F.blk`
- Header: `data/maps/maps.asm:460` -> `map TrainerHouse1F, TILESET_HOUSE, INDOOR, LANDMARK_VIRIDIAN_CITY, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:425` -> `map_const TRAINER_HOUSE_1F, 5, 7` (10x14 walk cells)
- Attributes: `data/maps/attributes.asm:659` -> `$00`, no connections
- No scene scripts, no callbacks.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 13 | `VIRIDIAN_CITY` | 3 |
| 2 | 3 | 13 | `VIRIDIAN_CITY` | 3 |
| 3 | 8 | 2 | `TRAINER_HOUSE_B1F` | 1 |

**Coord events**: none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 5 | 0 | `BGEVENT_READ` | `TrainerHouseSign1` |
| 7 | 0 | `BGEVENT_READ` | `TrainerHouseSign2` |
| 7 | 10 | `BGEVENT_READ` | `TrainerHouseIllegibleBook` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TRAINERHOUSE1F_RECEPTIONIST` | `SPRITE_RECEPTIONIST` | 0 | 11 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `TrainerHouse1FReceptionistScript` | -1 |
| `TRAINERHOUSE1F_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 7 | 11 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `TrainerHouse1FCooltrainerMScript` | -1 |
| `TRAINERHOUSE1F_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 6 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` (radius 2,0) | `OBJECTTYPE_SCRIPT` | `TrainerHouse1FCooltrainerFScript` | -1 |
| `TRAINERHOUSE1F_YOUNGSTER` | `SPRITE_YOUNGSTER` | 4 | 8 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius 2,0) | `OBJECTTYPE_SCRIPT` | `TrainerHouse1FYoungsterScript` | -1 |
| `TRAINERHOUSE1F_GENTLEMAN` | `SPRITE_GENTLEMAN` | 2 | 4 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `TrainerHouse1FGentlemanScript` | -1 |

Every 1F NPC is `jumptextfaceplayer` flavour. Nothing here gates the basement.

---

### MAP_TRAINER_HOUSE_B1F

- Script: `maps/TrainerHouseB1F.asm` (`TrainerHouseB1F_MapEvents` = `5f:4b97`, `TrainerHouseReceptionistScript` = `5f:4965`)
- Blocks: `maps/TrainerHouseB1F.blk`
- Header: `data/maps/maps.asm:461` -> `map TrainerHouseB1F, TILESET_FACILITY, INDOOR, LANDMARK_VIRIDIAN_CITY, MUSIC_VIRIDIAN_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:426` -> `map_const TRAINER_HOUSE_B1F, 5, 8` (10x16 walk cells)
- Attributes: `data/maps/attributes.asm:660` -> `$00`, no connections
- Scene var: `data/maps/scenes.asm:15` -> `wTrainerHouseB1FSceneID`

**Scene scripts**

| scene id | constant | script |
|---|---|---|
| 0 | `SCENE_TRAINERHOUSEB1F_ASK_BATTLE` | `TrainerHouseB1FNoopScene` -> `end` (the id only exists to arm the coord_event; it is never changed) |

**Callbacks**: none.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 4 | `TRAINER_HOUSE_1F` | 3 |

**Coord events**

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_TRAINERHOUSEB1F_ASK_BATTLE` (0) | 7 | 3 | `TrainerHouseReceptionistScript` (`5f:4965`) | the once-a-day CAL battle |

The bot walks in at (9, 4) and must reach (7, 3) - two cells left and one up. That is the walkthrough's "head left after you go downstairs and the lady will talk to you".

**BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TRAINERHOUSEB1F_RECEPTIONIST` | `SPRITE_RECEPTIONIST` | 7 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` (stub - she is only reachable through the coord_event) | -1 |
| `TRAINERHOUSEB1F_CHRIS` | `SPRITE_CHRIS` | 6 | 11 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | -1 |

`TRAINERHOUSEB1F_CHRIS` is the opponent sprite in the battle room; `setlasttalked TRAINERHOUSEB1F_CHRIS` points the battle at it.

**Scripts of interest**

`TrainerHouseReceptionistScript`:

1. `turnobject PLAYER, UP`, `opentext`.
2. `checkflag ENGINE_FOUGHT_IN_TRAINER_HALL_TODAY` -> `iftrue .FoughtTooManyTimes` (refusal text, `applymovement PLAYER, Movement_TrainerHouseTurnBack`).
3. `special TrainerHouse` (`engine/events/specials.asm:454`: reads `sMysteryGiftTrainerHouseFlag` into `wScriptVar`). True -> name from `gettrainername STRING_BUFFER_3, CAL, CAL2`; false -> `CAL, CAL3`.
4. `yesorno`. No -> `.Declined`. Yes -> `setflag ENGINE_FOUGHT_IN_TRAINER_HALL_TODAY`, text, `applymovement PLAYER, Movement_EnterTrainerHouseBattleRoom` (`LEFT x3, DOWN x8, LEFT, turn_head RIGHT`).
5. `special TrainerHouse` again. True -> `loadtrainer CAL, CAL2`; false -> `.NoSpecialBattle` -> `loadtrainer CAL, CAL3`. Both arms `winlosstext TrainerHouseB1FCalBeatenText, 0`, `setlasttalked TRAINERHOUSEB1F_CHRIS`, `startbattle`, `reloadmapafterbattle`.
6. `.End`: `applymovement PLAYER, Movement_ExitTrainerHouseBattleRoom`.

`CAL, CAL2` is the only trainer in the game whose party is **not** read from `data/trainers/parties.asm`: `engine/battle/read_trainer_party.asm:17-22` branches to `.cal2` and reads `sMysteryGiftTrainer` out of SRAM, and `GetTrainerName` (same file, line 326) reads `sMysteryGiftPartnerName`. With no Mystery Gift ever performed the flag is 0 and the game always fights `CAL3`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FOUGHT_IN_TRAINER_HALL_TODAY` | `constants/engine_flags.asm:104` | `checkflag`/`setflag` here | set = already battled today; cleared by the daily reset |
| `SCENE_TRAINERHOUSEB1F_ASK_BATTLE` = 0 | `maps/TrainerHouseB1F.asm:7` | `wTrainerHouseB1FSceneID` | always 0, so the coord_event is always armed |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `CAL3` | `CAL` (`constants/trainer_constants.asm:73`) | CAL (3), line 222 | L50 MEGANIUM, L50 TYPHLOSION, L50 FERALIGATR (`TRAINERTYPE_NORMAL`) | `TrainerHouseReceptionistScript` `.NoSpecialBattle` | once per day |
| `CAL2` | `CAL` | CAL (2), line 214 - **dead data** | table row is L30 BAYLEEF/QUILAVA/CROCONAW, but `ReadTrainerParty` never reaches it; the real party comes from `sMysteryGiftTrainer` | `TrainerHouseReceptionistScript` main arm | Mystery Gift only |

The walkthrough's "Level 50 Meganium / Typhlosion / Feraligatr" is `CAL3`, and its Thard_Verad note ("Cal is a placeholder; if you Mystery Gift with anyone, they can show up") is exactly the `CAL2` branch.

---

### MAP_ROUTE_1

- Script: `maps/Route1.asm` (`Route1_MapEvents` = `4e:4675`)
- Blocks: `maps/Route1.blk`
- Header: `data/maps/maps.asm:311` -> `map Route1, TILESET_KANTO, ROUTE, LANDMARK_ROUTE_1, MUSIC_ROUTE_1, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:287` -> `map_const ROUTE_1, 10, 18` (20x36 walk cells), group `PALLET`
- Connections: `data/maps/attributes.asm:267` -> north `ViridianCity` (offset -10), south `PalletTown` (offset 0)
- No scene scripts, no callbacks, **no warps** (connections only).

**Coord events**: none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 7 | 27 | `BGEVENT_READ` | `Route1Sign` -> `Route1SignText` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE1_YOUNGSTER` | `SPRITE_YOUNGSTER` | 7 | 17 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER`, sight 3 | `TrainerSchoolboyDanny` (`4e:4531`) | -1 |
| `ROUTE1_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 3 | 26 | `SPRITEMOVEDATA_STANDING_RIGHT` (radius 1,0) | `OBJECTTYPE_TRAINER`, sight 4 | `TrainerCooltrainerfQuinn` (`4e:4545`) | -1 |
| `ROUTE1_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 3 | 7 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | `Route1FruitTree` (`4e:455c`) = `fruittree FRUITTREE_ROUTE_1` | -1 |

**Scripts of interest**

`Route1FruitTree` is one command: `fruittree FRUITTREE_ROUTE_1` (`constants/script_constants.asm:232`). The item comes from `FruitTreeItems` (`data/items/fruit_trees.asm`), whose `ROUTE_1` row is `db BITTER_BERRY`. This is the walkthrough's "Item on Route 1: Bitter Berry" - it is a **fruit tree**, not a ground item, so it is a daily respawn rather than a one-time pickup (`engine/events/fruit_trees.asm`, `TryResetFruitTrees`).

Both trainer scripts are the standard `endifjustbattled` after-battle text.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_SCHOOLBOY_DANNY` | `constants/event_flags.asm:621` | `trainer` header | set on win |
| `EVENT_BEAT_COOLTRAINERF_QUINN` | `constants/event_flags.asm:890` | `trainer` header | set on win |

The fruit tree's picked state is **not** an `EVENT_*` - it is a per-tree bit in the fruit-tree flag array with a daily reset (see `engine/events/fruit_trees.asm`).

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `BITTER_BERRY` | face the tree object at (3, 7) and press A | `Route1FruitTree` -> `FruitTreeItems` row `ROUTE_1` | daily per-tree flag, not an event flag |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `DANNY` | `SCHOOLBOY` | SCHOOLBOY (5), line 435 | L31 JYNX, L31 ELECTABUZZ, L31 MAGMAR | `TrainerSchoolboyDanny` | none |
| `QUINN` | `COOLTRAINERF` | COOLTRAINERF (14), line 948 | L38 IVYSAUR, L38 STARMIE | `TrainerCooltrainerfQuinn` | none |

**Wild encounters**

`data/wild/kanto_grass.asm:231` `def_grass_wildmons ROUTE_1`, rates `10/10/10 percent`. **No version split.**

- morn/day: L2 PIDGEY, L2 RATTATA, L3 SENTRET, L3 PIDGEY, L6 FURRET, L4 PIDGEY, L4 PIDGEY.
- nite: L2 HOOTHOOT, L2 RATTATA, L3 RATTATA, L3 HOOTHOOT, L6 RATTATA, L4 HOOTHOOT, L4 HOOTHOOT.

The walkthrough's "Pidgey / Furret" is the morn/day column minus Rattata and Sentret; at night there is no Pidgey or Furret at all.

---

### MAP_PALLET_TOWN

- Script: `maps/PalletTown.asm` (`PalletTown_MapEvents` = `4e:47aa`)
- Blocks: `maps/PalletTown.blk`
- Header: `data/maps/maps.asm:312` -> `map PalletTown, TILESET_KANTO, TOWN, LANDMARK_PALLET_TOWN, MUSIC_PALLET_TOWN, FALSE, PALETTE_AUTO, FISHGROUP_OCEAN`
- Dimensions: `constants/map_constants.asm:288` -> `map_const PALLET_TOWN, 10, 9` (20x18 walk cells), group `PALLET`
- Connections: `data/maps/attributes.asm:271` -> north `Route1` (offset 0), south `Route21` (offset 0)
- Spawn: `data/maps/spawn_points.asm:14` -> `spawn PALLET_TOWN, 5, 6`; flypoint `data/maps/flypoints.asm:18` -> `db LANDMARK_PALLET_TOWN, SPAWN_PALLET`

**Scene scripts**: none. **Callbacks**: `MAPCALLBACK_NEWMAP` -> `PalletTownFlypointCallback` = `setflag ENGINE_FLYPOINT_PALLET / endcallback`. This is the asm behind "You can now fly to Pallet Town" - it fires the moment the map loads, before any NPC is talked to.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 5 | `REDS_HOUSE_1F` | 1 |
| 2 | 13 | 5 | `BLUES_HOUSE` | 1 |
| 3 | 12 | 11 | `OAKS_LAB` | 1 |

**Coord events**: none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 7 | 9 | `BGEVENT_READ` | `PalletTownSign` |
| 3 | 5 | `BGEVENT_READ` | `RedsHouseSign` |
| 13 | 13 | `BGEVENT_READ` | `OaksLabSign` |
| 11 | 5 | `BGEVENT_READ` | `BluesHouseSign` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `PALLETTOWN_TEACHER` | `SPRITE_TEACHER` | 3 | 8 | `SPRITEMOVEDATA_WANDER` (radius 2,2) | `OBJECTTYPE_SCRIPT` | `PalletTownTeacherScript` | -1 |
| `PALLETTOWN_FISHER` | `SPRITE_FISHER` | 12 | 14 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius 2,0) | `OBJECTTYPE_SCRIPT` | `PalletTownFisherScript` | -1 |

Both are `jumptextfaceplayer` flavour.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_PALLET` | `constants/engine_flags.asm:67` | set by `PalletTownFlypointCallback` | Fly target unlocked on first visit |

**Items**: none. **Trainers**: none.

**Wild encounters**: `data/wild/kanto_water.asm:117` `def_water_wildmons PALLET_TOWN`, 6 percent: L35 TENTACOOL, L30 TENTACOOL, L35 TENTACRUEL. No grass entry. Fishing group `FISHGROUP_OCEAN`.

---

### MAP_OAKS_LAB

- Script: `maps/OaksLab.asm` (`OaksLab_MapEvents` = `59:5f33`, `Oak` = `59:58c3`)
- Blocks: `maps/OaksLab.blk`
- Header: `data/maps/maps.asm:316` -> `map OaksLab, TILESET_LAB, INDOOR, LANDMARK_PALLET_TOWN, MUSIC_POKEMON_TALK, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:291` -> `map_const OAKS_LAB, 5, 6` (10x12 walk cells)
- No connections. `OaksLabNoopScene` exists but is marked `; unreferenced`; `def_scene_scripts` is empty and there are no callbacks.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 11 | `PALLET_TOWN` | 3 |
| 2 | 5 | 11 | `PALLET_TOWN` | 3 |

**Coord events**: none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 6,7,8,9 | 1 | `BGEVENT_READ` | `OaksLabBookshelf` (`jumpstd DifficultBookshelfScript`) |
| 0,1,2,3 | 7 | `BGEVENT_READ` | `OaksLabBookshelf` |
| 6,7,8,9 | 7 | `BGEVENT_READ` | `OaksLabBookshelf` |
| 4 | 0 | `BGEVENT_READ` | `OaksLabPoster1` |
| 5 | 0 | `BGEVENT_READ` | `OaksLabPoster2` |
| 9 | 3 | `BGEVENT_READ` | `OaksLabTrashcan` |
| 0 | 1 | `BGEVENT_READ` | `OaksLabPC` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `OAKSLAB_OAK` | `SPRITE_OAK` | 4 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Oak` (`59:58c3`) | -1 |
| `OAKSLAB_SCIENTIST1` | `SPRITE_SCIENTIST` | 1 | 8 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius 1,0) | `OBJECTTYPE_SCRIPT` | `OaksAssistant1Script` | -1 |
| `OAKSLAB_SCIENTIST2` | `SPRITE_SCIENTIST` | 8 | 9 | `SPRITEMOVEDATA_WALK_UP_DOWN` (radius 0,1) | `OBJECTTYPE_SCRIPT` | `OaksAssistant2Script` | -1 |
| `OAKSLAB_SCIENTIST3` | `SPRITE_SCIENTIST` | 1 | 4 | `SPRITEMOVEDATA_WANDER` (radius 1,1) | `OBJECTTYPE_SCRIPT` | `OaksAssistant3Script` | -1 |

**Scripts of interest**

`Oak` (`59:58c3`):

```
faceplayer / opentext
checkevent EVENT_OPENED_MT_SILVER   ; iftrue .CheckPokedex
checkevent EVENT_TALKED_TO_OAK_IN_KANTO ; iftrue .CheckBadges
writetext OakWelcomeKantoText / promptbutton / setevent EVENT_TALKED_TO_OAK_IN_KANTO
.CheckBadges:
  readvar VAR_BADGES
  ifequal NUM_BADGES, .OpenMtSilver        ; 16
  ifequal NUM_JOHTO_BADGES, .Complain      ; 8 (i.e. zero Kanto badges)
  sjump .AhGood                            ; 9..15 badges
.OpenMtSilver: writetext OakOpenMtSilverText / promptbutton / setevent EVENT_OPENED_MT_SILVER / sjump .CheckPokedex
.Complain:     writetext OakNoKantoBadgesText / promptbutton / sjump .CheckPokedex
.AhGood:       writetext OakYesKantoBadgesText / promptbutton / sjump .CheckPokedex
.CheckPokedex: writetext OakLabDexCheckText / waitbutton / special ProfOaksPCBoot / writetext OakLabGoodbyeText / waitbutton / closetext / end
```

`VAR_BADGES` = `constants/script_constants.asm:55`. `NUM_JOHTO_BADGES`, `NUM_KANTO_BADGES` and `NUM_BADGES = NUM_JOHTO_BADGES + NUM_KANTO_BADGES` are at `constants/ram_constants.asm:260,272,273`. The walkthrough's "He notices your Kanto badges. He tells you that he'll give you a prize if you get all the badges" is the `.AhGood` arm; the actual prize is the Mt. Silver unlock in `.OpenMtSilver`, which needs all 16.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_TALKED_TO_OAK_IN_KANTO` | `constants/event_flags.asm:224` | set on the first `Oak` conversation | skips the welcome text afterwards |
| `EVENT_OPENED_MT_SILVER` | `constants/event_flags.asm:1265` | set when `VAR_BADGES == NUM_BADGES` | Mt. Silver / the Red fight opens |

**Items**: none. **Trainers**: none. **Wild encounters**: none.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Mt. Moon rival battle is unavoidable | `maps/MountMoon.asm` `MountMoonRivalEncounterScene` / `MountMoonRivalBattleScript` (`42:55b0`), armed by `wMountMoonSceneID == SCENE_MOUNTMOON_RIVAL_BATTLE` (0) | be able to win a 6-mon L41-45 fight | `setscene SCENE_MOUNTMOON_NOOP` + `setevent EVENT_BEAT_RIVAL_IN_MT_MOON` at the end of the script. Losing does not set the flag; the scene id is unchanged so the fight re-arms on re-entry. |
| Mt. Moon Square Moon Stone | `maps/MountMoonSquare.asm` `MountMoonSquareDisappearMoonStoneCallback` (sets `EVENT_MOUNT_MOON_SQUARE_HIDDEN_MOON_STONE` on every `MAPCALLBACK_NEWMAP`) | see the Clefairy dance | `ClefairyDance` `clearevent EVENT_MOUNT_MOON_SQUARE_HIDDEN_MOON_STONE`. Leaving the map re-sets it. |
| Clefairy dance itself | `maps/MountMoonSquare.asm` `ClefairyDance` head | `ENGINE_MT_MOON_SQUARE_CLEFAIRY` clear **and** `VAR_WEEKDAY == MONDAY` **and** `checktime NITE` | one-shot: the script `setflag ENGINE_MT_MOON_SQUARE_CLEFAIRY` at the end |
| Rock on the Moon Stone tile | `maps/MountMoonSquare.asm` `MtMoonSquareRock` -> `engine/events/std_scripts.asm:199 SmashRockScript` -> `engine/events/overworld.asm:1365 AskRockSmashScript` / `HasRockSmash` (line 1386) | `ROCK_SMASH` on a party member (`CheckPartyMove`) - **no badge check** | teach TM08 to anything |
| Trainer House CAL, once per day | `maps/TrainerHouseB1F.asm` `TrainerHouseReceptionistScript` `checkflag ENGINE_FOUGHT_IN_TRAINER_HALL_TODAY` | flag clear | the game's daily flag reset clears `ENGINE_FOUGHT_IN_TRAINER_HALL_TODAY` |
| Trainer House opponent identity | `engine/events/specials.asm:454 TrainerHouse` reading `sMysteryGiftTrainerHouseFlag`; party via `engine/battle/read_trainer_party.asm:17` | Mystery Gift performed | not reachable without a second cartridge; falls back to `CAL3` |
| Fly back to Pewter/Pallet/Viridian | `engine/events/overworld.asm:544 FlyFunction .TryFly` -> `ld de, ENGINE_STORMBADGE / call CheckBadge` **plus** the destination's own `ENGINE_FLYPOINT_*` | Storm Badge + having visited the town | `ViridianCityFlypointCallback` / `PalletTownFlypointCallback` set their flags on `MAPCALLBACK_NEWMAP` |
| Surf south from Pallet to Route 21 (next section) | `engine/events/overworld.asm:338 SurfFunction .TrySurf` -> `ld de, ENGINE_FOGBADGE / call CheckBadge` | Fog Badge + a party member that knows Surf | out of scope here |
| Indigo Plateau rival re-encounter | `maps/IndigoPlateauPokecenter1F.asm:45,67` `PlateauRivalBattle1/2` | `EVENT_BEAT_RIVAL_IN_MT_MOON` set, `ENGINE_INDIGO_PLATEAU_RIVAL_FIGHT` clear, `VAR_WEEKDAY` not SUNDAY/TUESDAY/THURSDAY/FRIDAY/SATURDAY (so Monday or Wednesday) | matches the walkthrough exactly |
| Dragon's Den rival sighting | `maps/DragonsDenB1F.asm:12` `DragonsDenB1FCheckRivalCallback` | `EVENT_BEAT_RIVAL_IN_MT_MOON` set and `VAR_WEEKDAY == TUESDAY` or `THURSDAY` | matches the walkthrough exactly |

Nothing in this section requires a badge, an HM or a key item to pass through. The only hard stop is the Mt. Moon rival battle.

---

## 4. Bot checklist

Coordinates are asm walk cells `(x, y)` on the named map.

1. `ROUTE_3` - enter from the west connection from `PEWTER_CITY`. Walk east.
2. `ROUTE_3` - trainer `ROUTE3_YOUNGSTER1` at (11, 2), sight 3 downward-ish (`STANDING_DOWN`, range 2). Precondition: `EVENT_BEAT_YOUNGSTER_WARREN` clear. Intent: battle (L35 Fearow). Postcondition: `EVENT_BEAT_YOUNGSTER_WARREN` set.
3. `ROUTE_3` - trainer `ROUTE3_YOUNGSTER2` at (20, 4), `STANDING_RIGHT`, sight 3. Battle (L33 Raticate, L33 Arbok). Post: `EVENT_BEAT_YOUNGSTER_JIMMY`.
4. `ROUTE_3` - trainer `ROUTE3_FISHER1` at (26, 12), `STANDING_UP`, sight 2. Battle (L29 Magmar, L32 Weezing, L29 Magmar). Post: `EVENT_BEAT_FIREBREATHER_OTIS`.
5. `ROUTE_3` - trainer `ROUTE3_FISHER2` at (49, 5), `SPINRANDOM_FAST`, sight 3. Battle (L32 Koffing, L32 Slugma). Post: `EVENT_BEAT_FIREBREATHER_BURT`.
6. `ROUTE_3` - optional: read the sign at (49, 13). Then heal (walkthrough advice, no flag) and save.
7. `ROUTE_3` - step on warp 1 at (52, 1). Postcondition: player on `MOUNT_MOON` at (3, 3).
8. `MOUNT_MOON` - do nothing; the scene script fires. Precondition: `wMountMoonSceneID == 0`, `EVENT_MT_MOON_RIVAL` clear. Intent: battle `RIVAL2` with the party chosen by `EVENT_GOT_TOTODILE_FROM_ELM` / `EVENT_GOT_CHIKORITA_FROM_ELM`. Postcondition: `EVENT_BEAT_RIVAL_IN_MT_MOON` set, `EVENT_MT_MOON_RIVAL` set, `wMountMoonSceneID = 1`.
9. Optional detour: `MOUNT_MOON` (13, 3) warp 3 -> lands at (25, 3); walk to (25, 5) warp 5 -> `MOUNT_MOON_SQUARE` (20, 5).
10. `MOUNT_MOON_SQUARE` - (13, 7) warp 3 -> `MOUNT_MOON_GIFT_SHOP`. Talk to the clerk (`(4, 3)` in MORN, `(1, 2)` in DAY - **no clerk at NITE**) to open `MART_MT_MOON`. Exit at (3, 7) or (4, 7).
11. `MOUNT_MOON_SQUARE` optional, Monday night only: walk onto (7, 11) to trip `ClefairyDance`. Preconditions: `ENGINE_MT_MOON_SQUARE_CLEFAIRY` clear, `VAR_WEEKDAY == MONDAY`, `checktime NITE` true. Postcondition: `ENGINE_MT_MOON_SQUARE_CLEFAIRY` set, `EVENT_MOUNT_MOON_SQUARE_HIDDEN_MOON_STONE` cleared. Then, **without leaving the map**, face (7, 7); if the rock object is there, use Rock Smash (requires `ROCK_SMASH` in the party), then press A on (7, 7) to take `MOON_STONE`.
12. `MOUNT_MOON_SQUARE` - (22, 11) warp 2 -> `MOUNT_MOON` (25, 15). Walk to (25, 13) warp 8 -> lands at (15, 11). Walk to (15, 15) warp 2 -> `ROUTE_4` (2, 5).
13. `ROUTE_4` - trainer `ROUTE4_LASS1` at (10, 8), `STANDING_LEFT`, sight 5. Battle (L34 Flaaffy). Post: `EVENT_BEAT_PICNICKER_HOPE`.
14. `ROUTE_4` - trainer `ROUTE4_YOUNGSTER` at (17, 9), `STANDING_DOWN`, sight 3. Battle (L12 Pidgey, L34 Pidgeot). Post: `EVENT_BEAT_BIRD_KEEPER_HANK`.
15. `ROUTE_4` - trainer `ROUTE4_LASS2` at (21, 6), `STANDING_RIGHT`, sight 4. Battle (L31 Furret, L33 Rapidash). Post: `EVENT_BEAT_PICNICKER_SHARON`.
16. `ROUTE_4` - item ball `ROUTE4_POKE_BALL` at (26, 3). Intent: take `HP_UP`. Precondition: `EVENT_ROUTE_4_HP_UP` clear. Postcondition: set.
17. `ROUTE_4` - optional hidden item: face (10, 3), press A -> `ULTRA_BALL`. Post: `EVENT_ROUTE_4_HIDDEN_ULTRA_BALL`.
18. Travel to `VIRIDIAN_CITY` (Fly needs `ENGINE_STORMBADGE` and the destination flypoint; the walkthrough's route is Fly to Pewter, then `ROUTE_2` south through `VIRIDIAN_FOREST`). Entering Viridian sets `ENGINE_FLYPOINT_VIRIDIAN`.
19. `VIRIDIAN_CITY` - optional: talk to `VIRIDIANCITY_FISHER` at (6, 23) for `TM_DREAM_EATER`. Precondition: `EVENT_GOT_TM42_DREAM_EATER` clear and pack room. Post: set.
20. `VIRIDIAN_CITY` - warp 3 at (23, 15) -> `TRAINER_HOUSE_1F` (2, 13). Then warp 3 at (8, 2) -> `TRAINER_HOUSE_B1F` (9, 4).
21. `TRAINER_HOUSE_B1F` - walk to (7, 3) to trip the coord_event. Precondition: `ENGINE_FOUGHT_IN_TRAINER_HALL_TODAY` clear. Answer YES. Intent: battle `CAL, CAL3` (L50 Meganium / Typhlosion / Feraligatr). Postcondition: `ENGINE_FOUGHT_IN_TRAINER_HALL_TODAY` set. The script walks the player in and out with `applymovement`; do not fight the movement.
22. Return to `VIRIDIAN_CITY` and cross the south connection into `ROUTE_1`.
23. `ROUTE_1` - fruit tree object at (3, 7). Face it, press A -> `BITTER_BERRY`. Daily respawn.
24. `ROUTE_1` - trainer `ROUTE1_YOUNGSTER` at (7, 17), `SPINRANDOM_FAST`, sight 3. Battle (L31 Jynx, L31 Electabuzz, L31 Magmar). Post: `EVENT_BEAT_SCHOOLBOY_DANNY`.
25. `ROUTE_1` - trainer `ROUTE1_COOLTRAINER_F` at (3, 26), `STANDING_RIGHT`, sight 4. Battle (L38 Ivysaur, L38 Starmie). Post: `EVENT_BEAT_COOLTRAINERF_QUINN`.
26. `ROUTE_1` - south connection into `PALLET_TOWN`. Postcondition on map load: `ENGINE_FLYPOINT_PALLET` set.
27. `PALLET_TOWN` - warp 3 at (12, 11) -> `OAKS_LAB` (4, 11).
28. `OAKS_LAB` - talk to `OAKSLAB_OAK` at (4, 2). Postcondition: `EVENT_TALKED_TO_OAK_IN_KANTO` set; if `VAR_BADGES == 16`, also `EVENT_OPENED_MT_SILVER`.
29. Exit to `PALLET_TOWN` and head south to the `ROUTE_21` connection (Surf, `ENGINE_FOGBADGE`) - next section.

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Kanto map geometry, warps, connections, bg/coord/object rows | `src/import/RomExtractorGen2.lua` (extracts all map events), `src/world/gen2/Map.lua`, `src/world/gen2/World.lua` | implemented (generic - every map in the ROM comes through the same path, no per-map Kanto code needed) |
| Scene scripts / `wMapSceneID` (Mt. Moon rival, Trainer House coord_event) | `src/world/gen2/World.lua:1175-1183` (`GetMapSceneID` port), `:5014-5040` (coord event and scene script lookup) | implemented |
| `sdefer` timing for the Mt. Moon rival cutscene | `src/script/gen2/Vm.lua:92-93` | partial - the comment says "sdefer queues after the map settles in retail; run immediately here", so the rival scene starts a frame or two earlier than the cart. Cosmetic for a bot, visible in a screenshot diff. |
| Map callbacks (`MAPCALLBACK_NEWMAP` / `MAPCALLBACK_OBJECTS`) - the flypoint setters and the Mt. Moon Square rock/moon-stone callbacks | `src/world/gen2/World.lua:5969`, driver `tests/drivers/gold_map_callbacks.lua` | implemented, with an assertion driver |
| `appear` / `disappear` object visibility via the event bitfield | `src/world/gen2/Events.lua` (header comment cites `CheckObjectFlag`) | implemented |
| Overworld trainers: `trainer` struct, eyesight, party build | `src/world/gen2/Trainers.lua`, `src/world/gen2/World.lua:5257-5264`, driver `tests/drivers/gold_trainer_smoke.lua` | implemented |
| `loadtrainer` / `startbattle` / `winlosstext` / `setlasttalked` (the rival and CAL fights) | `src/script/gen2/Opcodes.lua:99,100,105,109`, `src/script/gen2/Vm.lua:806` | implemented |
| Trainer House daily CAL battle + Mystery Gift fallback | `src/world/gen2/TrainerHouse.lua` | implemented (deliberately answers `CAL3`; Mystery Gift is out of scope, documented in the file header) |
| Cutscene opcodes used by `ClefairyDance` and the rival scene: `showemote`, `follow`, `stopfollow`, `cry`, `moveobject`, `applymovement` | `src/script/gen2/Opcodes.lua:117-137`, `src/script/gen2/Vm.lua:961`, `src/script/gen2/Movement.lua` | implemented |
| `checktime` / `VAR_WEEKDAY` (the Monday-night Clefairy guard) | `src/script/gen2/Vm.lua:784`, `src/core/gen2/BugContest.lua:112` (`weekday`) | implemented |
| Hidden items (`BGEVENT_ITEM`: Mt. Moon Square Moon Stone, Route 4 Ultra Ball) | `src/world/gen2/HiddenItems.lua`, wired at `src/world/gen2/World.lua:5291` | implemented |
| Item balls (`OBJECTTYPE_ITEMBALL`: the Route 4 HP Up) | extracted at `src/import/RomExtractorGen2.lua:2968-2969` as `obj.itemball`; **nothing reads it** - `World:interact` (`src/world/gen2/World.lua:5257`) only dispatches `npc.def.trainer`, strength boulders, `npc.def.scriptKey`, bg events and hidden items | **missing** - a bot cannot pick up the Route 4 HP Up in this port today |
| Fruit trees (`fruittree FRUITTREE_ROUTE_1` -> Bitter Berry) | `src/core/gen2/Apricorns.lua` (`FruitTreeItems` table, per-tree flag, `tryResetFruitTrees`), `src/script/gen2/Vm.lua:1191` | implemented |
| `pokemart` / `MART_MT_MOON` | `src/script/gen2/Vm.lua:597`, `src/ui/gen2/MartMenu.lua:336-348` | implemented (list comes from the extracted `data/generated/marts.lua`) |
| `verbosegiveitem` (Viridian TM42) | `src/script/gen2/Vm.lua:490-498` | implemented |
| Rock Smash on the Mt. Moon Square rock | `src/world/gen2/FieldMoves.lua` (comment at :588 lists `ROCK_SMASH` among the field moves); the strength-boulder equivalent is special-cased in `World:interact` | partial - `jumpstd SmashRockScript` is a `farsjump` into ASM, so there is no bytecode for the extractor to find. `World:interact` has an explicit arm for strength boulders (`World.isStrengthBoulder`) but **no equivalent arm for `SPRITEMOVEDATA_SMASHABLE_ROCK`**, so pressing A on the Mt. Moon Square rock reaches a nil `scriptKey`. Verify by hand. |
| Fly / flypoints (`ENGINE_FLYPOINT_PALLET` = 52, `ENGINE_FLYPOINT_VIRIDIAN` = 53) | `src/world/gen2/FieldMoves.lua:342-370` (both Kanto rows present) | implemented |
| Kanto wild tables (Gold vs Silver split) | extracted by `src/import/RomExtractorGen2.lua` from the ROM, so whichever cart was imported is what you get | implemented (no version conditional needed - the ROM already picked) |

---

## 6. Unresolved / verify by hand

1. **Rival party order contradicts the walkthrough.** The walkthrough lists Sneasel, Golbat, *Starter Evolution*, Magneton, Gengar, Alakazam. `data/trainers/parties.asm:2042-2069` lists Sneasel(41), Golbat(42), Magneton(41), Gengar(43), Alakazam(43), **starter last at level 45**. The walkthrough's per-mon strategy text is still correct; only the ordering is wrong. Levels and species otherwise match.
2. **Route 3 and Route 4 wild lists in the walkthrough are the Silver tables.** `data/wild/kanto_grass.asm:314` and `:369` both have `IF DEF(_GOLD) / ELIF DEF(_SILVER)` arms. Ekans and Arbok only exist in the `_SILVER` arm. On Gold, Route 3 is Spearow/Rattata/Jigglypuff (+Zubat at nite) and Route 4 is the same. The walkthrough is titled for Gold but quoted the Silver data.
3. **Mt. Moon wild list is incomplete in the walkthrough.** Gold also has L8 SANDSHREW, L10 SANDSLASH and two L8 CLEFAIRY slots (`data/wild/kanto_grass.asm:33`). The Clefairy slots mean Clefairy can be caught in the cave at any time, independent of the Monday-night dance.
4. **Route 1 wild list is incomplete and time-dependent.** The walkthrough lists Pidgey and Furret; the nite column (`data/wild/kanto_grass.asm:250`) has neither - it is Hoothoot and Rattata only.
5. **"Bitter Berry" on Route 1 is a fruit tree, not a ground item.** `Route1FruitTree` = `fruittree FRUITTREE_ROUTE_1`, and `data/items/fruit_trees.asm` row `ROUTE_1` is `BITTER_BERRY`. It respawns daily rather than being a one-time pickup, which the walkthrough's "Item on Route 1" phrasing implies.
6. **The two Mt. Moon routes described in the walkthrough could not be verified against the collision map.** The warp graph in section 2 is exact, but which of warps 2/3/4 are reachable from the (3, 3) entrance without passing through the Square depends on `maps/MountMoon.blk` collision, which was not decoded here. The walkthrough's "either way, you end up in the same spot" is consistent with warps 4<->8 and 6 meeting on the (25, 13)/(25, 15) side, but confirm by walking it.
7. **"Bring Rock Smash" for the Clefairy Moon Stone.** The asm supports the claim indirectly: `MountMoonSquareDisappearRockCallback` hides `MOUNTMOONSQUARE_ROCK` on every `MAPCALLBACK_OBJECTS`, `ClefairyDance` `appear`s it at (7, 7) mid-cutscene, and (7, 7) is exactly the `BGEVENT_ITEM` tile the dance unlocks. Whether the rock actually blocks the tile-facing A press (as opposed to being walkable) was not verified; the item could also be reachable by facing (7, 7) from an adjacent cell. Verify in-game.
8. **`ULTRA_BALL` at Route 4 (10, 3) and `TM_DREAM_EATER` in Viridian are absent from the walkthrough.** Both are real (`maps/Route4.asm` bg_event, `maps/ViridianCity.asm` `ViridianCityDreamEaterFisher`). Not a contradiction, just an omission worth carrying into a completionist route.
9. **Mt. Moon Gift Shop has no NITE clerk.** Both `SPRITE_GRAMPS` rows are gated `-1, MORN` and `-1, DAY`. A bot that arrives at night finds no shop, which the walkthrough does not warn about.
10. **`ROUTE_3` warp position vs. its sign.** The only warp is at (52, 1) but the "MT.MOON SQUARE / Just go up the stairs" sign is at (49, 13), twelve cells south. That is what the file says; it reads oddly and is worth an eyeball on the rendered map.
11. **Port: `OBJECTTYPE_ITEMBALL` pickup is unimplemented** (see section 5). The Route 4 HP Up is the first item ball this section needs, and `World:interact` has no arm for it. Confirmed by reading `src/world/gen2/World.lua:5257-5310` and grepping the whole `src/` tree for `itemball` (only the extractor and one comment in `src/script/gen2/CallAsm.lua:547` mention it).
12. **Port: smashable-rock objects have no interact arm** (see section 5). Same class of gap as the item ball, but lower stakes because the only rock in this section is optional.

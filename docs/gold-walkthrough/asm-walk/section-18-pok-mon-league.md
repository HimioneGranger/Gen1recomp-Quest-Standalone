# Section 18 - Pokémon League

Source: `../section-18-pok-mon-league.txt`
Maps covered: `MAP_ROUTE_23`, `MAP_INDIGO_PLATEAU_POKECENTER_1F`, `MAP_WILLS_ROOM`,
`MAP_KOGAS_ROOM`, `MAP_BRUNOS_ROOM`, `MAP_KARENS_ROOM`, `MAP_LANCES_ROOM`,
`MAP_HALL_OF_FAME`
Badges / key milestones in this section: no badge. `ENGINE_FLYPOINT_INDIGO_PLATEAU`
(fly point), `EVENT_BEAT_ELITE_4_WILL/KOGA/BRUNO/KAREN`,
`EVENT_BEAT_CHAMPION_LANCE`, `EVENT_BEAT_ELITE_FOUR`, `STATUSFLAGS_HALL_OF_FAME_F`
(Hall of Fame induction -> credits -> post-game respawn at `SPAWN_NEW_BARK`).

All eight maps live in map group `INDIGO` (group 16, `constants/map_constants.asm:321`).

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 0 | `MAP_VICTORY_ROAD` | `maps/VictoryRoad.asm` | (previous section) | warp 10 at `(13, 5)` -> `ROUTE_23` warp 3 | Victory Road's north exit; the walkthrough opens already standing on the Plateau approach |
| 1 | `MAP_ROUTE_23` | `maps/Route23.asm` | warps 3/4 at `(9, 13)`/`(10, 13)` from Victory Road | warps 1/2 at `(9, 5)`/`(10, 5)` -> `INDIGO_PLATEAU_POKECENTER_1F` warps 1/2 | "Route 32 is very short, and you'll immediately be at the Pokémon League building" (the FAQ means Route **23**). `MAPCALLBACK_NEWMAP` registers the fly point here |
| 2 | `MAP_INDIGO_PLATEAU_POKECENTER_1F` | `maps/IndigoPlateauPokecenter1F.asm` | warps 1/2 at `(5, 13)`/`(6, 13)` | warp 4 at `(14, 3)` -> `WILLS_ROOM` warp 1 | Heal (nurse, left), buy (clerk, right), optional Abra teleport home, optional Mon/Wed rival ambush, then through the north door |
| 3 | `MAP_WILLS_ROOM` | `maps/WillsRoom.asm` | warp 1 at `(5, 17)` | warps 2/3 at `(4, 2)`/`(5, 2)` -> `KOGAS_ROOM` warps 1/2 | Elite Four 1 - Will |
| 4 | `MAP_KOGAS_ROOM` | `maps/KogasRoom.asm` | warps 1/2 at `(4, 17)`/`(5, 17)` | warps 3/4 at `(4, 2)`/`(5, 2)` -> `BRUNOS_ROOM` warps 1/2 | Elite Four 2 - Koga |
| 5 | `MAP_BRUNOS_ROOM` | `maps/BrunosRoom.asm` | warps 1/2 at `(4, 17)`/`(5, 17)` | warps 3/4 at `(4, 2)`/`(5, 2)` -> `KARENS_ROOM` warps 1/2 | Elite Four 3 - Bruno |
| 6 | `MAP_KARENS_ROOM` | `maps/KarensRoom.asm` | warps 1/2 at `(4, 17)`/`(5, 17)` | warps 3/4 at `(4, 2)`/`(5, 2)` -> `LANCES_ROOM` warps 1/2 | Elite Four 4 - Karen |
| 7 | `MAP_LANCES_ROOM` | `maps/LancesRoom.asm` | warps 1/2 at `(4, 23)`/`(5, 23)` | scripted `warp HALL_OF_FAME, 4, 13` at the tail of `LancesRoomLanceScript` (warps 3/4 at `(4, 0)`/`(5, 0)` are the same door) | Champion Lance, then the Mary / Prof. Oak cutscene |
| 8 | `MAP_HALL_OF_FAME` | `maps/HallOfFame.asm` | scripted warp to `(4, 13)` | `halloffame` -> `Credits` -> title screen | Induction, credits, "The End" |

Post-credits: `engine/menus/intro_menu.asm` `.SpawnAfterE4` sends the next CONTINUE
to `SPAWN_NEW_BARK`, not to the saved position. That is the start of the Kanto
half and belongs to the next section.

---

## 2. Maps

### MAP_ROUTE_23

- Script: `maps/Route23.asm`
- Blocks: `maps/Route23.blk`
- Header (`data/maps/maps.asm:349`): `map Route23, TILESET_KANTO, TOWN, LANDMARK_ROUTE_23, MUSIC_INDIGO_PLATEAU, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:322` -> `map_const ROUTE_23, 10, 9` (10 x 9 blocks = 20 x 18 tiles)
- Attributes: `data/maps/attributes.asm:397` -> `map_attributes Route23, ROUTE_23, $0f`, **no connections** (despite `TOWN` environment)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 5 | `INDIGO_PLATEAU_POKECENTER_1F` | 1 |
| 2 | 10 | 5 | `INDIGO_PLATEAU_POKECENTER_1F` | 2 |
| 3 | 9 | 13 | `VICTORY_ROAD` | 10 |
| 4 | 10 | 13 | `VICTORY_ROAD` | 10 |

**Coord events** - none (`def_coord_events` is empty).

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 11 | 7 | `BGEVENT_READ` | `IndigoPlateauSign` (`IndigoPlateauSignText`) |

**Object events** - none (`def_object_events` is empty).

**Scripts of interest**

- `Route23FlypointCallback` (`50:5888`), registered as `callback MAPCALLBACK_NEWMAP`.
  Body is two opcodes: `setflag ENGINE_FLYPOINT_INDIGO_PLATEAU` / `endcallback`.
  This is the whole of the walkthrough's "You'll now be able to fly to this
  location directly", and it is also the gate on the Kanto half of the Fly map
  (see section 5 - Blockers).
- `IndigoPlateauSign` -> `jumptext IndigoPlateauSignText`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_INDIGO_PLATEAU` | `constants/engine_flags.asm:78` | set by `Route23FlypointCallback` | after one step onto Route 23, Fly to Indigo Plateau is available; also unlocks the Kanto Fly map |

**Items** - none.

**Trainers** - none.

**Wild encounters** - none. `ROUTE_23` has no entry in `data/wild/johto_grass.asm`,
`data/wild/kanto_grass.asm`, `data/wild/johto_water.asm` or
`data/wild/kanto_water.asm` (grepped; `kanto_grass.asm` jumps
`ROUTE_22` -> `ROUTE_24`). The header's `FISHGROUP_SHORE` is the header default and
there is no water to fish from.

---

### MAP_INDIGO_PLATEAU_POKECENTER_1F

- Script: `maps/IndigoPlateauPokecenter1F.asm`
- Blocks: `maps/IndigoPlateauPokecenter1F.blk`
- Header (`data/maps/maps.asm:350`): `map IndigoPlateauPokecenter1F, TILESET_POKECENTER, INDOOR, LANDMARK_INDIGO_PLATEAU, MUSIC_INDIGO_PLATEAU, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:323` -> `map_const INDIGO_PLATEAU_POKECENTER_1F, 9, 7` (18 x 14 tiles)
- Attributes: `data/maps/attributes.asm:598`, border `$00`, no connections

`object_const_def` order (the ids `moveobject` / `applymovement` / `appear` take):

```
0 INDIGOPLATEAUPOKECENTER1F_NURSE
1 INDIGOPLATEAUPOKECENTER1F_CLERK
2 INDIGOPLATEAUPOKECENTER1F_COOLTRAINER_M
3 INDIGOPLATEAUPOKECENTER1F_RIVAL
4 INDIGOPLATEAUPOKECENTER1F_GRAMPS
5 INDIGOPLATEAUPOKECENTER1F_ABRA
```

(the macro is `const_def 2`, so the emitted numbers start at 2)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 13 | `ROUTE_23` | 1 |
| 2 | 6 | 13 | `ROUTE_23` | 2 |
| 3 | 0 | 13 | `POKECENTER_2F` | 1 |
| 4 | 14 | 3 | `WILLS_ROOM` | 1 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_INDIGOPLATEAUPOKECENTER1F_RIVAL_BATTLE` (= 0) | 16 | 4 | `PlateauRivalBattle1` (`5a:48ff`) | rival walks up from the left column and blocks you |
| `SCENE_INDIGOPLATEAUPOKECENTER1F_RIVAL_BATTLE` (= 0) | 17 | 4 | `PlateauRivalBattle2` (`5a:4940`) | same fight, approached from the right column |

**BG events** - none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `..._NURSE` | `SPRITE_NURSE` | 3 | 7 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `IndigoPlateauPokecenter1FNurseScript` | -1 |
| `..._CLERK` | `SPRITE_CLERK` | 11 | 7 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `IndigoPlateauPokecenter1FClerkScript` | -1 |
| `..._COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 11 | 11 | `SPRITEMOVEDATA_WANDER` (radius 2,2) | `OBJECTTYPE_SCRIPT` | `IndigoPlateauPokecenter1FCooltrainerMScript` | -1 |
| `..._RIVAL` | `SPRITE_RIVAL` | 16 | 9 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_INDIGO_PLATEAU_POKECENTER_RIVAL` |
| `..._GRAMPS` | `SPRITE_GRAMPS` (`PAL_NPC_BLUE`) | 1 | 9 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `TeleportGuyScript` | `EVENT_TELEPORT_GUY` |
| `..._ABRA` | `SPRITE_JYNX` (`PAL_NPC_BROWN`) | 0 | 9 | `SPRITEMOVEDATA_POKEMON` | `OBJECTTYPE_SCRIPT` | `AbraScript` | `EVENT_TELEPORT_GUY` |

Note the last row: the "Abra" the walkthrough names is declared with
`SPRITE_JYNX` (`constants/sprite_constants.asm:122`; `data/sprites/sprite_mons.asm`
maps that slot to `JYNX`). Its script is `AbraScript`, which does
`cry ABRA`. Verbatim from the file, not a typo of mine.

An object's event flag hides it when the flag is **set** (`Script_disappear`
sets, `Script_appear` clears - `engine/overworld/scripting.asm:879-898`).
`EVENT_INDIGO_PLATEAU_POKECENTER_RIVAL` is set on New Game by
`engine/events/std_scripts.asm:556` (the `EVENT_INITIALIZED_EVENTS` block), so
the rival starts hidden. `EVENT_TELEPORT_GUY` is not in that block, so the old
man and his Pokémon are visible from the first visit.

**Scripts of interest**

- `IndigoPlateauPokecenter1FPrepareElite4Callback` (`5a:48b6`), a
  `callback MAPCALLBACK_NEWMAP`. **This is the single most important script in
  the section for a bot**: every time you set foot in the lobby it resets the
  whole Elite Four run.

  ```
  setmapscene WILLS_ROOM,   SCENE_WILLSROOM_LOCK_DOOR
  setmapscene KOGAS_ROOM,   SCENE_KOGASROOM_LOCK_DOOR
  setmapscene BRUNOS_ROOM,  SCENE_BRUNOSROOM_LOCK_DOOR
  setmapscene KARENS_ROOM,  SCENE_KARENSROOM_LOCK_DOOR
  setmapscene LANCES_ROOM,  SCENE_LANCESROOM_LOCK_DOOR
  setmapscene HALL_OF_FAME, SCENE_HALLOFFAME_ENTER
  clearevent EVENT_{WILLS,KOGAS,BRUNOS,KARENS,LANCES}_ROOM_ENTRANCE_CLOSED
  clearevent EVENT_{WILLS,KOGAS,BRUNOS,KARENS,LANCES}_ROOM_EXIT_OPEN
  clearevent EVENT_BEAT_ELITE_4_WILL / _KOGA / _BRUNO / _KAREN
  clearevent EVENT_BEAT_CHAMPION_LANCE
  setevent   EVENT_LANCES_ROOM_OAK_AND_MARY   ; hide Oak + Mary again
  endcallback
  ```

  Consequences: the five `EVENT_BEAT_ELITE_4_*` flags are **not** durable
  progress markers - they only survive within one uninterrupted run. The durable
  "I beat the League" flag is `EVENT_BEAT_ELITE_FOUR`, set in `HallOfFameEnterScript`.
- `PlateauRivalBattle1` / `PlateauRivalBattle2` -> `PlateauRivalBattleCommon`.
  Guards, in order:
  1. `checkevent EVENT_BEAT_RIVAL_IN_MT_MOON` / `iffalse` -> done (so this only
     ever fires post-game, after the Mt. Moon rematch),
  2. `checkflag ENGINE_INDIGO_PLATEAU_RIVAL_FIGHT` / `iftrue` -> done (once a day),
  3. `readvar VAR_WEEKDAY` with `ifequal SUNDAY / TUESDAY / THURSDAY / FRIDAY /
     SATURDAY` -> done. **Only Monday and Wednesday.**

  Then `moveobject`/`appear` the rival, `showemote EMOTE_SHOCK`,
  `special FadeOutMusic`, a 5-step `applymovement`, `playmusic MUSIC_RIVAL_ENCOUNTER`,
  `setevent EVENT_INDIGO_PLATEAU_POKECENTER_RIVAL`, then a starter-dependent
  `loadtrainer RIVAL2, RIVAL2_2_*` + `startbattle`. Afterwards
  `PlateauRivalPostBattle` plays `MUSIC_RIVAL_AFTER`, walks him off with
  `disappear`, and `setflag ENGINE_INDIGO_PLATEAU_RIVAL_FIGHT`.
- `IndigoPlateauPokecenter1FNurseScript` -> `jumpstd PokecenterNurseScript` (free heal).
- `IndigoPlateauPokecenter1FClerkScript` -> `pokemart MARTTYPE_STANDARD, MART_INDIGO_PLATEAU`.
- `TeleportGuyScript` (`5a:49e5`): `yesorno`; on yes, `playsound SFX_WARP_TO`,
  `special FadeOutToWhite`, `warp NEW_BARK_TOWN, 13, 6`. The walkthrough's "Abra
  will teleport you back" lands you in **New Bark Town**, specifically, not
  "back to Johto" generically.
- `AbraScript`: text + `cry ABRA`, nothing else.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_INDIGO_PLATEAU_POKECENTER_RIVAL` | `constants/event_flags.asm:1309` | set by `std_scripts.asm:556` on New Game and by `PlateauRivalBattleCommon`; cleared by `appear` | hides the rival object |
| `EVENT_TELEPORT_GUY` | `constants/event_flags.asm:1310` | set by `HallOfFameEnterScript` | after the Hall of Fame the old man **and** his Pokémon vanish; the ride home is a pre-champion service only |
| `EVENT_BEAT_RIVAL_IN_MT_MOON` | `constants/event_flags.asm:456` | read by both `PlateauRivalBattle*` | precondition for the lobby ambush |
| `ENGINE_INDIGO_PLATEAU_RIVAL_FIGHT` | `constants/engine_flags.asm:111` (in the `wDailyFlags2` block) | read/set by `PlateauRivalBattle*` | daily one-shot; cleared with the rest of the daily flags at midnight |
| `SCENE_INDIGOPLATEAUPOKECENTER1F_RIVAL_BATTLE` | the map's own `def_scene_scripts` (value 0) | coord events | see the quirk note below |

Scene quirk worth knowing: this map declares exactly one scene script, so
`SCENE_INDIGOPLATEAUPOKECENTER1F_RIVAL_BATTLE == 0`, which is also the default
value of `wMapScenes` for the map. `PlateauRivalPostBattle`'s
`setscene SCENE_INDIGOPLATEAUPOKECENTER1F_RIVAL_BATTLE` therefore writes 0 over
0 and the two coord events stay armed forever. The real one-shot guards are
`ENGINE_INDIGO_PLATEAU_RIVAL_FIGHT` and the weekday check.

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `ULTRA_BALL`, `MAX_REPEL`, `HYPER_POTION`, `MAX_POTION`, `FULL_RESTORE`, `REVIVE`, `FULL_HEAL` | bought | `MartIndigoPlateau` (`data/items/marts.asm:384`, symbol `05:645a`), opened by `IndigoPlateauPokecenter1FClerkScript` | n/a |

This is where the walkthrough's "ten Hyper Potions, ten Revives, ten Full Heals"
shopping list is actually satisfiable - the mart carries all three plus Full
Restore.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `RIVAL2` | `RIVAL2` (`$2a`) | `RIVAL2_2_CHIKORITA` / `RIVAL2_2_CYNDAQUIL` / `RIVAL2_2_TOTODILE` (chosen by which starter the player took: `checkevent EVENT_GOT_TOTODILE_FROM_ELM` -> Chikorita team, `EVENT_GOT_CHIKORITA_FROM_ELM` -> Cyndaquil team, else Totodile team) | `Rival2Group` entries 4/5/6 | `PlateauRivalBattleCommon` | daily, Mon/Wed only, post Mt. Moon |

`Rival2Group` (4)-(6), all `TRAINERTYPE_MOVES`:
`45 SNEASEL`, `48 CROBAT`, `45 MAGNETON`, `46 GENGAR`, `46 ALAKAZAM`, and then
`50 MEGANIUM` / `50 TYPHLOSION` / `50 FERALIGATR` respectively. The walkthrough
does not mention this fight at all - a bot that walks the lobby on a Monday
will hit it whether or not it planned to.

**Wild encounters** - none (indoor).

---

### MAP_WILLS_ROOM

- Script: `maps/WillsRoom.asm`
- Blocks: `maps/WillsRoom.blk`
- Header (`data/maps/maps.asm:351`): `map WillsRoom, TILESET_ELITE_FOUR_ROOM, INDOOR, LANDMARK_INDIGO_PLATEAU, MUSIC_INDIGO_PLATEAU, TRUE, PALETTE_DAY, FISHGROUP_SHORE` (the `TRUE` is the phone-service flag: **no phone calls** in any Elite Four room)
- Dimensions: `constants/map_constants.asm:324` -> `map_const WILLS_ROOM, 5, 9` (10 x 18 tiles)
- Attributes: `data/maps/attributes.asm:599`, border `$00`, no connections

`object_const_def`: `WILLSROOM_WILL` (emitted id 2).

Scene ids from the map's own `def_scene_scripts`:
`SCENE_WILLSROOM_LOCK_DOOR = 0`, `SCENE_WILLSROOM_NOOP = 1`.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 17 | `INDIGO_PLATEAU_POKECENTER_1F` | 4 |
| 2 | 4 | 2 | `KOGAS_ROOM` | 1 |
| 3 | 5 | 2 | `KOGAS_ROOM` | 2 |

**Coord events** - none. The door-lock cutscene is a **scene script**, not a
coord event: `scene_script WillsRoomLockDoorScene, SCENE_WILLSROOM_LOCK_DOOR`
fires on map load via `sdefer`.

**BG events** - none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `WILLSROOM_WILL` | `SPRITE_WILL` (`PAL_NPC_RED`) | 5 | 7 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `WillScript_Battle` | -1 |

**Scripts of interest**

- `WillsRoomDoorLocksBehindYouScript` (`5a:4d8c`), deferred by the scene script:
  `applymovement PLAYER, WillsRoom_EnterMovement` (4 x `step UP`, so you enter at
  `(5, 17)` and end at `(5, 13)`), `reanchormap $85`, `playsound SFX_STRENGTH`,
  `earthquake 80`, `changeblock 4, 14, $2a` (wall), `refreshmap`,
  `setscene SCENE_WILLSROOM_NOOP`, `setevent EVENT_WILLS_ROOM_ENTRANCE_CLOSED`.
  `changeblock` operands are in the same tile space as warps but are halved
  internally (`Script_changeblock` adds 4 then `GetBlockLocation` shifts right,
  `home/map.asm:2099`), so `4, 14` is the block covering tiles `(4..5, 14..15)` -
  the corridor square immediately below where the walk-in leaves you. That is
  what makes the walkthrough's "You can't go back to the Pokémon Center to heal
  between battles" literally true.
- `WillsRoomDoorsCallback`, `callback MAPCALLBACK_TILES`: re-applies
  `changeblock 4, 14, $2a` while `EVENT_WILLS_ROOM_ENTRANCE_CLOSED` is set and
  `changeblock 4, 2, $16` (open door) while `EVENT_WILLS_ROOM_EXIT_OPEN` is set,
  so the room's geometry survives a battle reload.
- `WillScript_Battle` (`5a:4da4`): `faceplayer`, `opentext`,
  `checkevent EVENT_BEAT_ELITE_4_WILL` / `iftrue WillScript_AfterBattle`,
  `writetext WillScript_WillBeforeText`, `winlosstext WillScript_WillBeatenText, 0`,
  `loadtrainer WILL, WILL1`, `startbattle`, `reloadmapafterbattle`,
  `setevent EVENT_BEAT_ELITE_4_WILL`, defeat text, `playsound SFX_ENTER_DOOR`,
  `changeblock 4, 2, $16` (open the north door), `refreshmap`,
  `setevent EVENT_WILLS_ROOM_EXIT_OPEN`.

  Note there is **no `winlosstext` loss branch** (the second operand is `0`) and
  no `BATTLETYPE_CANLOSE`: losing to any Elite Four member is an ordinary
  blackout, which is why the FAQ says "If you lose, you have to start all over".

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_WILLS_ROOM_ENTRANCE_CLOSED` | `constants/event_flags.asm:440` | set by `WillsRoomDoorLocksBehindYouScript`, read by `WillsRoomDoorsCallback`, cleared by the lobby callback | south door sealed |
| `EVENT_WILLS_ROOM_EXIT_OPEN` | `constants/event_flags.asm:441` | set by `WillScript_Battle`, read by `WillsRoomDoorsCallback`, cleared by the lobby callback | north door open -> `(4, 2)` / `(5, 2)` are walkable warps |
| `EVENT_BEAT_ELITE_4_WILL` | `constants/event_flags.asm:980` | set by `WillScript_Battle`, cleared by the lobby callback | run-local "Will is done" |
| `SCENE_WILLSROOM_LOCK_DOOR` / `SCENE_WILLSROOM_NOOP` | this map's `def_scene_scripts` (0 / 1) | `setmapscene` from the lobby; `setscene` in the lock script | 0 = play the seal-in cutscene on entry |

**Items** - none.

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `WILL1` | `WILL` (`$b`) | 1 | `WillGroup` (`data/trainers/parties.asm:197`, symbol `0e:5bf4`) | `WillScript_Battle` | none |

`WillGroup`, `TRAINERTYPE_MOVES`, in **send-out order**:

| # | lvl | species | moves |
|---|---|---|---|
| 1 | 40 | `XATU` | Quick Attack, Future Sight, Confuse Ray, Psychic |
| 2 | 41 | `JYNX` | DoubleSlap, Lovely Kiss, Ice Punch, Psychic |
| 3 | 41 | `EXEGGUTOR` | Reflect, Leech Seed, Egg Bomb, Psychic |
| 4 | 41 | `SLOWBRO` | Curse, Amnesia, Body Slam, Psychic |
| 5 | 42 | `XATU` | Quick Attack, Future Sight, Confuse Ray, Psychic |

Class attributes (`data/trainers/attributes.asm`, `; Will` block):
items `MAX_POTION, NO_ITEM`; base reward 25; DVs `atk 13 / def 12 / spd 13 / spc 13`
(`data/trainers/dvs.asm:15`). Money = base reward x level of the last enemy mon
(`ComputeTrainerReward`, `engine/battle/read_trainer_party.asm:300`) = **25 x 42 = 1050**.

**Wild encounters** - none.

---

### MAP_KOGAS_ROOM

- Script: `maps/KogasRoom.asm`
- Blocks: `maps/KogasRoom.blk`
- Header (`data/maps/maps.asm:352`): `map KogasRoom, TILESET_ELITE_FOUR_ROOM, INDOOR, LANDMARK_INDIGO_PLATEAU, MUSIC_INDIGO_PLATEAU, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:325` -> `map_const KOGAS_ROOM, 5, 9`
- Attributes: `data/maps/attributes.asm:600`, border `$00`

`object_const_def`: `KOGASROOM_KOGA`.
Scenes: `SCENE_KOGASROOM_LOCK_DOOR = 0`, `SCENE_KOGASROOM_NOOP = 1`.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 17 | `WILLS_ROOM` | 2 |
| 2 | 5 | 17 | `WILLS_ROOM` | 3 |
| 3 | 4 | 2 | `BRUNOS_ROOM` | 1 |
| 4 | 5 | 2 | `BRUNOS_ROOM` | 2 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `KOGASROOM_KOGA` | `SPRITE_KOGA` (`PAL_NPC_BLUE`) | 5 | 7 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `KogaScript_Battle` | -1 |

**Scripts of interest**

Structurally identical to Will's room: `KogasRoomDoorLocksBehindYouScript`
(4 x `step UP`, `changeblock 4, 14, $2a`, `setevent EVENT_KOGAS_ROOM_ENTRANCE_CLOSED`,
`setscene SCENE_KOGASROOM_NOOP`), `KogasRoomDoorsCallback` (`MAPCALLBACK_TILES`),
and `KogaScript_Battle` (`5a:5006`) -> `loadtrainer KOGA, KOGA1` /
`setevent EVENT_BEAT_ELITE_4_KOGA` / `changeblock 4, 2, $16` /
`setevent EVENT_KOGAS_ROOM_EXIT_OPEN`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_KOGAS_ROOM_ENTRANCE_CLOSED` | `constants/event_flags.asm:442` | lock script / tiles callback | south door sealed |
| `EVENT_KOGAS_ROOM_EXIT_OPEN` | `constants/event_flags.asm:443` | `KogaScript_Battle` / tiles callback | north door open |
| `EVENT_BEAT_ELITE_4_KOGA` | `constants/event_flags.asm:981` | `KogaScript_Battle` | run-local |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `KOGA1` | `KOGA` (`$f`) | 1 | `KogaGroup` (`data/trainers/parties.asm:249`, symbol `0e:5c89`) | `KogaScript_Battle` | none |

| # | lvl | species | moves |
|---|---|---|---|
| 1 | 40 | `ARIADOS` | Double Team, Spider Web, Baton Pass, Giga Drain |
| 2 | 41 | `VENOMOTH` | Supersonic, Gust, Psychic, Toxic |
| 3 | 43 | `FORRETRESS` | Protect, Swift, Explosion, Spikes |
| 4 | 42 | `MUK` | Minimize, Acid Armor, Sludge Bomb, Toxic |
| 5 | 44 | `CROBAT` | Double Team, Quick Attack, Wing Attack, Toxic |

Class attributes (`; Koga`): items `FULL_HEAL, FULL_RESTORE` (the walkthrough's
"three Full Restores" is HGSS; in GS the AI holds **one** Full Heal and **one**
Full Restore per class-attribute slot); base reward 25; DVs `13/12/13/13`
(`data/trainers/dvs.asm:19`). Money = 25 x 44 = **1100**.

**Wild encounters** - none.

---

### MAP_BRUNOS_ROOM

- Script: `maps/BrunosRoom.asm`
- Blocks: `maps/BrunosRoom.blk`
- Header (`data/maps/maps.asm:353`): `map BrunosRoom, TILESET_ELITE_FOUR_ROOM, INDOOR, LANDMARK_INDIGO_PLATEAU, MUSIC_INDIGO_PLATEAU, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:326` -> `map_const BRUNOS_ROOM, 5, 9`
- Attributes: `data/maps/attributes.asm:601`, border `$00`

`object_const_def`: `BRUNOSROOM_BRUNO`.
Scenes: `SCENE_BRUNOSROOM_LOCK_DOOR = 0`, `SCENE_BRUNOSROOM_NOOP = 1`.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 17 | `KOGAS_ROOM` | 3 |
| 2 | 5 | 17 | `KOGAS_ROOM` | 4 |
| 3 | 4 | 2 | `KARENS_ROOM` | 1 |
| 4 | 5 | 2 | `KARENS_ROOM` | 2 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `BRUNOSROOM_BRUNO` | `SPRITE_BRUNO` (`PAL_NPC_BROWN`) | 5 | 7 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `BrunoScript_Battle` | -1 |

**Scripts of interest** - `BrunosRoomDoorLocksBehindYouScript`,
`BrunosRoomDoorsCallback`, `BrunoScript_Battle` (`5a:5271`); same shape as Will's
room, with `loadtrainer BRUNO, BRUNO1` and
`setevent EVENT_BEAT_ELITE_4_BRUNO` / `EVENT_BRUNOS_ROOM_EXIT_OPEN`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BRUNOS_ROOM_ENTRANCE_CLOSED` | `constants/event_flags.asm:444` | lock script / tiles callback | south door sealed |
| `EVENT_BRUNOS_ROOM_EXIT_OPEN` | `constants/event_flags.asm:445` | `BrunoScript_Battle` / tiles callback | north door open |
| `EVENT_BEAT_ELITE_4_BRUNO` | `constants/event_flags.asm:982` | `BrunoScript_Battle` | run-local |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `BRUNO1` | `BRUNO` (`$d`) | 1 | `BrunoGroup` (`data/trainers/parties.asm:229`, symbol `0e:5c3d`) | `BrunoScript_Battle` | none |

| # | lvl | species | moves |
|---|---|---|---|
| 1 | 42 | `HITMONTOP` | Pursuit, Quick Attack, Dig, Detect |
| 2 | 42 | `HITMONLEE` | Swagger, Double Kick, Hi Jump Kick, Foresight |
| 3 | 42 | `HITMONCHAN` | ThunderPunch, Ice Punch, Fire Punch, Mach Punch |
| 4 | 43 | `ONIX` | Bind, Earthquake, Sandstorm, Rock Slide |
| 5 | 46 | `MACHAMP` | Rock Slide, Foresight, Vital Throw, Cross Chop |

Class attributes (`; Bruno`): items `MAX_POTION, NO_ITEM`; base reward 25; DVs
`13/12/13/13` (`data/trainers/dvs.asm:17`). Money = 25 x 46 = **1150**.

**Wild encounters** - none.

---

### MAP_KARENS_ROOM

- Script: `maps/KarensRoom.asm`
- Blocks: `maps/KarensRoom.blk`
- Header (`data/maps/maps.asm:354`): `map KarensRoom, TILESET_ELITE_FOUR_ROOM, INDOOR, LANDMARK_INDIGO_PLATEAU, MUSIC_INDIGO_PLATEAU, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:327` -> `map_const KARENS_ROOM, 5, 9`
- Attributes: `data/maps/attributes.asm:602`, border `$00`

`object_const_def`: `KARENSROOM_KAREN`.
Scenes: `SCENE_KARENSROOM_LOCK_DOOR = 0`, `SCENE_KARENSROOM_NOOP = 1`.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 17 | `BRUNOS_ROOM` | 3 |
| 2 | 5 | 17 | `BRUNOS_ROOM` | 4 |
| 3 | 4 | 2 | `LANCES_ROOM` | 1 |
| 4 | 5 | 2 | `LANCES_ROOM` | 2 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `KARENSROOM_KAREN` | `SPRITE_KAREN` (`PAL_NPC_RED`) | 5 | 7 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `KarenScript_Battle` | -1 |

**Scripts of interest** - `KarensRoomDoorLocksBehindYouScript`,
`KarensRoomDoorsCallback`, `KarenScript_Battle` (`5a:549a`) with
`loadtrainer KAREN, KAREN1`, `setevent EVENT_BEAT_ELITE_4_KAREN`,
`changeblock 4, 2, $16`, `setevent EVENT_KARENS_ROOM_EXIT_OPEN`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_KARENS_ROOM_ENTRANCE_CLOSED` | `constants/event_flags.asm:446` | lock script / tiles callback | south door sealed |
| `EVENT_KARENS_ROOM_EXIT_OPEN` | `constants/event_flags.asm:447` | `KarenScript_Battle` / tiles callback | north door open |
| `EVENT_BEAT_ELITE_4_KAREN` | `constants/event_flags.asm:983` | `KarenScript_Battle` | run-local |

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `KAREN1` | `KAREN` (`$e`) | 1 | `KarenGroup` (`data/trainers/parties.asm:239`, symbol `0e:5c63`) | `KarenScript_Battle` | none |

| # | lvl | species | moves |
|---|---|---|---|
| 1 | 42 | `UMBREON` | Sand-Attack, Confuse Ray, Faint Attack, Mean Look |
| 2 | 42 | `VILEPLUME` | Stun Spore, Acid, Moonlight, Petal Dance |
| 3 | 45 | `GENGAR` | Lick, Spite, Curse, Destiny Bond |
| 4 | 44 | `MURKROW` | Quick Attack, Whirlwind, Pursuit, Faint Attack |
| 5 | 47 | `HOUNDOOM` | Roar, Pursuit, Flamethrower, Crunch |

Class attributes (`; Karen`): items `FULL_HEAL, MAX_POTION` - **no Full Restore**,
contra the walkthrough; base reward 25; DVs `atk 7 / def 15 / spd 13 / spc 15`
(`data/trainers/dvs.asm:18`, the only Elite Four member with a different DV row).
Money = 25 x 47 = **1175**.

**Wild encounters** - none.

---

### MAP_LANCES_ROOM

- Script: `maps/LancesRoom.asm`
- Blocks: `maps/LancesRoom.blk`
- Header (`data/maps/maps.asm:355`): `map LancesRoom, TILESET_CHAMPIONS_ROOM, INDOOR, LANDMARK_INDIGO_PLATEAU, MUSIC_INDIGO_PLATEAU, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:328` -> `map_const LANCES_ROOM, 5, 12` (10 x 24 tiles - the tallest room in the run)
- Attributes: `data/maps/attributes.asm:603`, border `$00`

`object_const_def`: `LANCESROOM_LANCE`, `LANCESROOM_MARY`, `LANCESROOM_OAK`.
Scenes: `SCENE_LANCESROOM_LOCK_DOOR = 0`, `SCENE_LANCESROOM_APPROACH_LANCE = 1`.
Note this map's second scene is **not** a noop-by-name: it is the state in which
the two coord events are live.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 23 | `KARENS_ROOM` | 3 |
| 2 | 5 | 23 | `KARENS_ROOM` | 4 |
| 3 | 4 | 0 | `HALL_OF_FAME` | 1 |
| 4 | 5 | 0 | `HALL_OF_FAME` | 2 |

**Coord events** (`def_coord_events`)

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_LANCESROOM_APPROACH_LANCE` (= 1) | 4 | 5 | `Script_ApproachLanceFromLeft` (`5a:5716`) | `FadeOutMusic`, walk `UP UP UP` + face right, fall into `LancesRoomLanceScript` |
| `SCENE_LANCESROOM_APPROACH_LANCE` (= 1) | 5 | 5 | `Script_ApproachLanceFromRight` (`5a:5720`) | `FadeOutMusic`, walk `UP LEFT UP UP` + face right, then the same |

**BG events** - none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `LANCESROOM_LANCE` | `SPRITE_LANCE` | 5 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `LancesRoomLanceScript` | -1 |
| `LANCESROOM_MARY` | `SPRITE_TEACHER` (`PAL_NPC_GREEN`) | 4 | 7 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_LANCES_ROOM_OAK_AND_MARY` |
| `LANCESROOM_OAK` | `SPRITE_OAK` | 4 | 7 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_LANCES_ROOM_OAK_AND_MARY` |

Mary and Oak share the same spawn tile `(4, 7)` and the same hide flag; both are
`appear`ed one at a time during the cutscene.

**Scripts of interest**

- `LancesRoomDoorLocksBehindYouScript` (`5a:56ff`): 4 x `step UP` from
  `(4|5, 23)` to y = 19, `reanchormap $85`, `SFX_STRENGTH`, `earthquake 80`,
  `changeblock 4, 22, $34` (wall - the champion's-room tileset uses a different
  wall block id than the Elite Four rooms' `$2a`), `refreshmap`,
  `setscene SCENE_LANCESROOM_APPROACH_LANCE`,
  `setevent EVENT_LANCES_ROOM_ENTRANCE_CLOSED`.
- `LancesRoomLanceScript` (`5a:5727`), the section's climax:
  `turnobject LANCESROOM_LANCE, LEFT`, intro text,
  `winlosstext LanceBattleWinText, 0`, `setlasttalked LANCESROOM_LANCE`,
  `loadtrainer CHAMPION, LANCE`, `startbattle`, `dontrestartmapmusic`,
  `reloadmapafterbattle`, `setevent EVENT_BEAT_CHAMPION_LANCE`, after-battle
  text, `SFX_ENTER_DOOR`, `changeblock 4, 0, $0b` (open the north door),
  `setevent EVENT_LANCES_ROOM_ENTRANCE_CLOSED` (again - the script re-sets the
  entrance flag here, it does not clear it), then
  `musicfadeout MUSIC_BEAUTY_ENCOUNTER, 16` and the cutscene:
  `appear LANCESROOM_MARY` -> `LancesRoomMovementData_MaryRushesIn` ->
  `appear LANCESROOM_OAK` -> `LancesRoomMovementData_OakWalksIn` ->
  `follow`/`stopfollow` pairs -> Mary's interview attempt -> Lance leads the
  player north (`follow LANCESROOM_LANCE, PLAYER`,
  `LancesRoomMovementData_LanceLeadsPlayerToHallOfFame`), `disappear` both, then
  `special FadeOutToWhite` and `warp HALL_OF_FAME, 4, 13`.

  This is the only exit that matters: warps 3/4 exist but the script drives the
  transition itself.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_LANCES_ROOM_ENTRANCE_CLOSED` | `constants/event_flags.asm:448` | lock script + `LancesRoomLanceScript`; read by `LancesRoomDoorsCallback` | south door sealed |
| `EVENT_LANCES_ROOM_EXIT_OPEN` | `constants/event_flags.asm:449` | read by `LancesRoomDoorsCallback`; cleared by the lobby callback | **never set by this map** - the north door is opened by a direct `changeblock 4, 0, $0b` in the battle script, and the flag only matters if you re-enter the map |
| `EVENT_BEAT_CHAMPION_LANCE` | `constants/event_flags.asm:984` | set by `LancesRoomLanceScript`, cleared by the lobby callback | run-local |
| `EVENT_LANCES_ROOM_OAK_AND_MARY` | `constants/event_flags.asm:1281` | set on New Game (`std_scripts.asm:523`) and by the lobby callback; cleared by `appear` during the cutscene | hides Mary and Oak until the champion falls |
| `SCENE_LANCESROOM_APPROACH_LANCE` | this map's `def_scene_scripts` (= 1) | `setscene` at the end of the lock script | arms the two coord events at y = 5 |

**Items** - none.

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `LANCE` | `CHAMPION` (`$10`) | 1 | `ChampionGroup` (`data/trainers/parties.asm:259`, symbol `0e:5cae`) | `LancesRoomLanceScript` | none |

| # | lvl | species | moves |
|---|---|---|---|
| 1 | 44 | `GYARADOS` | Flail, Rain Dance, Surf, Hyper Beam |
| 2 | 47 | `DRAGONITE` | Thunder Wave, Twister, Thunder, Hyper Beam |
| 3 | 47 | `DRAGONITE` | Thunder Wave, Twister, Blizzard, Hyper Beam |
| 4 | 46 | `AERODACTYL` | Wing Attack, AncientPower, Rock Slide, Hyper Beam |
| 5 | 46 | `CHARIZARD` | Flamethrower, Wing Attack, Slash, Hyper Beam |
| 6 | 50 | `DRAGONITE` | Fire Blast, Safeguard, Outrage, Hyper Beam |

Class attributes (`; Champion`): items `FULL_HEAL, FULL_RESTORE`; base reward 25;
DVs `13/12/13/13` (`data/trainers/dvs.asm:20`). Money = 25 x 50 = **1250**.
`data/trainers/leaders.asm:20` lists `CHAMPION`, but the file's own comment notes
`CHAMPION` and `RED` are unused for the leader battle-music check.

**Wild encounters** - none.

---

### MAP_HALL_OF_FAME

- Script: `maps/HallOfFame.asm`
- Blocks: `maps/HallOfFame.blk`
- Header (`data/maps/maps.asm:356`): `map HallOfFame, TILESET_ICE_PATH, INDOOR, LANDMARK_INDIGO_PLATEAU, MUSIC_NEW_BARK_TOWN, TRUE, PALETTE_DAY, FISHGROUP_SHORE` (yes: `TILESET_ICE_PATH` and the New Bark Town theme)
- Dimensions: `constants/map_constants.asm:329` -> `map_const HALL_OF_FAME, 5, 7` (10 x 14 tiles)
- Attributes: `data/maps/attributes.asm:604`, border `$00`

`object_const_def`: `HALLOFFAME_LANCE`.
Scenes: `SCENE_HALLOFFAME_ENTER = 0`, `SCENE_HALLOFFAME_NOOP = 1`.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 13 | `LANCES_ROOM` | 3 |
| 2 | 5 | 13 | `LANCES_ROOM` | 4 |

**Coord events** - none (the induction is a scene script). **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `HALLOFFAME_LANCE` | `SPRITE_LANCE` | 4 | 12 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | -1 |

**Scripts of interest**

- `HallOfFameEnterScript` (`5a:5cff`), deferred from
  `scene_script HallOfFameEnterScene, SCENE_HALLOFFAME_ENTER`. In order:
  `follow HALLOFFAME_LANCE, PLAYER`,
  `applymovement HALLOFFAME_LANCE, HallOfFame_WalkUpWithLance` (8 x `step UP`,
  1 x `step RIGHT`, `turn_head LEFT`), `stopfollow`, Lance's speech,
  `applymovement PLAYER, HallOfFame_SlowlyApproachMachine` (one `slow_step UP`),
  `setscene SCENE_HALLOFFAME_NOOP`, then the state writes:

  ```
  setval HEALMACHINE_HALL_OF_FAME        ; constants/script_constants.asm:295
  special HealMachineAnim
  setevent EVENT_BEAT_ELITE_FOUR         ; constants/event_flags.asm:77
  setevent EVENT_TELEPORT_GUY            ; removes the Abra ride home
  setevent EVENT_RIVAL_SPROUT_TOWER
  clearevent EVENT_RED_IN_MT_SILVER      ; Red becomes available later
  setevent EVENT_OLIVINE_PORT_SPRITES_BEFORE_HALL_OF_FAME
  clearevent EVENT_OLIVINE_PORT_SPRITES_AFTER_HALL_OF_FAME
  setmapscene SPROUT_TOWER_3F, SCENE_SPROUTTOWER3F_NOOP
  special HealParty
  checkevent EVENT_GOT_SS_TICKET_FROM_ELM / iftrue .SkipPhoneCall
  specialphonecall SPECIALCALL_SSTICKET  ; constants/phone_constants.asm:49
  halloffame
  ```

  So the S.S. Ticket call from Elm is queued **here**, and the Kanto half of the
  game is switched on by this one script.
- `halloffame` ($9f) -> `Script_halloffame` (`engine/overworld/scripting.asm:2207`)
  -> `HallOfFame` (`21:640a`, `engine/events/halloffame.asm:3`):
  fade out music, `wSpawnAfterChampion = SPAWN_LANCE`,
  `set STATUSFLAGS_HALL_OF_FAME_F`, bump `wHallOfFameCount` (capped at
  `HOF_MASTER_COUNT = 200`), `farcall SaveGameData`, `GetHallOfFameParty`,
  `AddHallOfFameEntry`, `AnimateHallOfFame`, then `jp Credits` with the
  **pre-set** copy of `wStatusFlags` (which is why a first-time champion cannot
  hold B to skip the roll).
- After the credits, `ReturnFromCredits` (`engine/overworld/scripting.asm:2216`)
  ends the script and returns `MAPSTATUS_DONE`; the game goes to the title
  screen. On the next CONTINUE, `engine/menus/intro_menu.asm:296` `.SpawnAfterE4`
  sets `wDefaultSpawnpoint = SPAWN_NEW_BARK` and enters via `MAPSETUP_WARP` -
  the walkthrough's "the game isn't actually over".

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_ELITE_FOUR` | `constants/event_flags.asm:77` | set by `HallOfFameEnterScript` | the durable "League cleared" flag; the five `EVENT_BEAT_ELITE_4_*` flags are wiped by the lobby callback and must not be used for this |
| `EVENT_TELEPORT_GUY` | `constants/event_flags.asm:1310` | set here | Abra ride home disappears |
| `EVENT_RED_IN_MT_SILVER` | `constants/event_flags.asm:1284` | set on New Game (`std_scripts.asm:526`), **cleared** here | Red can now exist at Mt. Silver once the rest of his gate is met |
| `EVENT_RIVAL_SPROUT_TOWER` / `SCENE_SPROUTTOWER3F_NOOP` | `constants/event_flags.asm:1126` / Sprout Tower 3F's scenes | set here | post-game Sprout Tower state |
| `EVENT_OLIVINE_PORT_SPRITES_BEFORE_HALL_OF_FAME` / `_AFTER_HALL_OF_FAME` | `constants/event_flags.asm:1241-1242` | flipped here | Olivine Port repopulates for the Fast Ship |
| `EVENT_GOT_SS_TICKET_FROM_ELM` | `constants/event_flags.asm:45` | read here | if unset, `specialphonecall SPECIALCALL_SSTICKET` queues Elm's call (`engine/phone/scripts/elm.asm:69`) |
| `STATUSFLAGS_HALL_OF_FAME_F` | `constants/ram_constants.asm` | set by `HallOfFame::` | unlocks the Kanto Pokégear map, gates credit skipping |
| `SCENE_HALLOFFAME_ENTER` / `_NOOP` | this map's `def_scene_scripts` (0 / 1) | `setmapscene` from the lobby callback; `setscene` mid-script | 0 = play the induction |

**Items** - none. **Trainers** - none. **Wild encounters** - none.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Entry to Victory Road (and therefore to this whole section) | `maps/VictoryRoadGate.asm:_VictoryRoadGateBadgeCheckScript` - `readvar VAR_BADGES` / `ifgreater NUM_JOHTO_BADGES - 1, .AllEightBadges` | all 8 Johto badges | `.AllEightBadges` does `setscene SCENE_VICTORYROADGATE_NOOP`; otherwise you get `applymovement PLAYER, VictoryRoadGateStepDownMovement` and are pushed back. **This gate belongs to the previous section**, listed here only because it is the precondition for everything below |
| Fly to Indigo Plateau | `maps/Route23.asm:Route23FlypointCallback` | one `MAPCALLBACK_NEWMAP` on Route 23 | `setflag ENGINE_FLYPOINT_INDIGO_PLATEAU` |
| No retreat once inside an Elite Four room | `maps/WillsRoom.asm:WillsRoomDoorLocksBehindYouScript` (and the Koga/Bruno/Karen/Lance twins) - `changeblock 4, 14, $2a` (Lance: `changeblock 4, 22, $34`) plus `EVENT_*_ROOM_ENTRANCE_CLOSED` re-applied by each map's `MAPCALLBACK_TILES` | none - it is unconditional on entry | never, within a run. The lobby's `MAPCALLBACK_NEWMAP` clears the flags, but you can only reach the lobby by finishing or blacking out |
| Each room's north door | `WillScript_Battle` / `KogaScript_Battle` / `BrunoScript_Battle` / `KarenScript_Battle` - `changeblock 4, 2, $16` + `setevent EVENT_*_ROOM_EXIT_OPEN`, replayed by the map's `MAPCALLBACK_TILES` | beat that member | door block becomes `$16` (open) and warps at `(4, 2)`/`(5, 2)` become reachable |
| Lance's north door | `maps/LancesRoom.asm:LancesRoomLanceScript` - `changeblock 4, 0, $0b` | beat Lance | opened, but the script warps you through immediately anyway |
| Approaching Lance at all | `def_coord_events` at `(4, 5)` / `(5, 5)` gated on `SCENE_LANCESROOM_APPROACH_LANCE` | that scene is only set at the end of `LancesRoomDoorLocksBehindYouScript` | walking in through warp 1/2 always sets it; a bot teleported straight to y < 5 would skip the fight |
| Lobby rival ambush | `maps/IndigoPlateauPokecenter1F.asm:PlateauRivalBattle1/2` | `EVENT_BEAT_RIVAL_IN_MT_MOON` set, `ENGINE_INDIGO_PLATEAU_RIVAL_FIGHT` clear, `VAR_WEEKDAY` in {MONDAY, WEDNESDAY} | not a progress gate - a hazard. Avoid tiles `(16, 4)` / `(17, 4)` if the run cannot afford a level-45-50 six-mon fight |
| No HM field move is required anywhere in this section | grep: no `Route23`/Elite Four map references any `engine/overworld/` field-move script; the walkthrough's "you do NOT need to have every HM" is correct | - | - |

---

## 4. Bot checklist

Coordinates are the raw asm map coordinates (tile grid, origin top-left, before
the +4 border offset the object/warp readers apply).

| # | Map | Target | Intent | Precondition | Postcondition |
|---|---|---|---|---|---|
| 1 | `VICTORY_ROAD` | warp at `(13, 5)` | walk onto warp | 8 Johto badges (already spent at `VictoryRoadGate`) | on `ROUTE_23` at warp 3 `(9, 13)` |
| 2 | `ROUTE_23` | any tile (map load) | step | - | `ENGINE_FLYPOINT_INDIGO_PLATEAU` set |
| 3 | `ROUTE_23` | `(9, 5)` or `(10, 5)` | walk onto warp | - | in `INDIGO_PLATEAU_POKECENTER_1F` at `(5, 13)`/`(6, 13)`; the `MAPCALLBACK_NEWMAP` resets all Elite Four scenes/flags |
| 4 | `INDIGO_PLATEAU_POKECENTER_1F` | `INDIGOPLATEAUPOKECENTER1F_NURSE` at `(3, 7)` | talk (A, facing up from `(3, 8)`) | - | party healed (`jumpstd PokecenterNurseScript`) |
| 5 | `INDIGO_PLATEAU_POKECENTER_1F` | `INDIGOPLATEAUPOKECENTER1F_CLERK` at `(11, 7)` | talk, buy | money | stock Hyper Potion / Full Heal / Revive / Full Restore from `MartIndigoPlateau` |
| 6 | `INDIGO_PLATEAU_POKECENTER_1F` | avoid `(16, 4)` and `(17, 4)` | pathing constraint | only matters if `EVENT_BEAT_RIVAL_IN_MT_MOON` is set and today is Mon/Wed | skipping avoids `RIVAL2_2_*` |
| 7 | `INDIGO_PLATEAU_POKECENTER_1F` | warp at `(14, 3)` | walk onto warp | - | in `WILLS_ROOM` at `(5, 17)`; scene 0 fires `WillsRoomDoorLocksBehindYouScript` |
| 8 | `WILLS_ROOM` | (automatic) | wait out `applymovement` | - | player at `(5, 13)`, `EVENT_WILLS_ROOM_ENTRANCE_CLOSED` set, scene = 1 |
| 9 | `WILLS_ROOM` | `WILLSROOM_WILL` at `(5, 7)` | walk to `(5, 8)`, face up, A | - | win -> `EVENT_BEAT_ELITE_4_WILL`, `EVENT_WILLS_ROOM_EXIT_OPEN` |
| 10 | `WILLS_ROOM` | `(4, 2)` or `(5, 2)` | walk onto warp | `EVENT_WILLS_ROOM_EXIT_OPEN` | in `KOGAS_ROOM` at `(4, 17)`/`(5, 17)` |
| 11 | `KOGAS_ROOM` | `KOGASROOM_KOGA` at `(5, 7)` | walk to `(5, 8)`, face up, A | door-lock cutscene done (player at `(4|5, 13)`) | `EVENT_BEAT_ELITE_4_KOGA`, `EVENT_KOGAS_ROOM_EXIT_OPEN` |
| 12 | `KOGAS_ROOM` | `(4, 2)` / `(5, 2)` | walk onto warp | exit open | in `BRUNOS_ROOM` at `(4, 17)`/`(5, 17)` |
| 13 | `BRUNOS_ROOM` | `BRUNOSROOM_BRUNO` at `(5, 7)` | talk | cutscene done | `EVENT_BEAT_ELITE_4_BRUNO`, `EVENT_BRUNOS_ROOM_EXIT_OPEN` |
| 14 | `BRUNOS_ROOM` | `(4, 2)` / `(5, 2)` | walk onto warp | exit open | in `KARENS_ROOM` at `(4, 17)`/`(5, 17)` |
| 15 | `KARENS_ROOM` | `KARENSROOM_KAREN` at `(5, 7)` | talk | cutscene done | `EVENT_BEAT_ELITE_4_KAREN`, `EVENT_KARENS_ROOM_EXIT_OPEN` |
| 16 | `KARENS_ROOM` | `(4, 2)` / `(5, 2)` | walk onto warp | exit open | in `LANCES_ROOM` at `(4, 23)`/`(5, 23)` |
| 17 | `LANCES_ROOM` | (automatic) | wait out `applymovement` | - | player at `(4|5, 19)`, `EVENT_LANCES_ROOM_ENTRANCE_CLOSED` set, scene = `SCENE_LANCESROOM_APPROACH_LANCE` |
| 18 | `LANCES_ROOM` | walk to `(4, 5)` (or `(5, 5)`) | walk onto coord event | scene = 1 | `Script_ApproachLanceFromLeft/Right` -> Champion battle vs `CHAMPION`/`LANCE` |
| 19 | `LANCES_ROOM` | (automatic) | hold A through the Mary / Oak cutscene | won | `EVENT_BEAT_CHAMPION_LANCE`, then `warp HALL_OF_FAME, 4, 13` |
| 20 | `HALL_OF_FAME` | (automatic) | hold A through Lance's speech | scene = `SCENE_HALLOFFAME_ENTER` | `EVENT_BEAT_ELITE_FOUR`, `EVENT_TELEPORT_GUY`, S.S. Ticket call queued if needed, `halloffame` runs |
| 21 | (screens) | Hall of Fame roster -> credits -> "The End" | wait; B skips **only** if `STATUSFLAGS_HALL_OF_FAME_F` was already set before this induction | - | back to title; save has been written by `SaveGameData` inside the ceremony |
| 22 | (title) | CONTINUE | select | `wSpawnAfterChampion == SPAWN_LANCE` | game resumes at `SPAWN_NEW_BARK`, not at Indigo Plateau |

Bot notes:

- Do **not** re-enter `INDIGO_PLATEAU_POKECENTER_1F` mid-run to heal. You cannot
  (the doors are sealed), and if some other path got you there, its
  `MAPCALLBACK_NEWMAP` wipes `EVENT_BEAT_ELITE_4_*` and re-arms all five
  door-lock scenes, restarting the gauntlet from Will.
- Every fight uses `winlosstext <win>, 0` - no loss branch, no
  `BATTLETYPE_CANLOSE` - so a loss is a full blackout to the last Pokémon Center.
- After each `startbattle` the scripts run `reloadmapafterbattle`, which re-runs
  the map's `MAPCALLBACK_TILES` and therefore restores both the sealed south door
  and (once its flag is set) the opened north door.

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map/warp/coord/object tables for all 8 maps | extracted generically by `src/import/RomExtractorGen2.lua` into the Gold cache and read by `src/world/gen2/World.lua` + `src/world/gen2/Map.lua` | implemented (data-driven; nothing map-specific is hand-written) |
| `MAPCALLBACK_NEWMAP` / `MAPCALLBACK_TILES` dispatch (the lobby reset, the door callbacks) | `src/world/gen2/World.lua`, asserted end-to-end by `tests/drivers/gold_map_callbacks.lua` | implemented |
| `changeblock` / `refreshmap` door swaps | `src/world/gen2/World.lua:1454` (`World:changeBlock`), `src/script/gen2/Opcodes.lua` | implemented |
| `reanchormap` | `src/script/gen2/Vm.lua:166` - grouped with `opentext`/`closetext` as a no-op | partial (the camera re-anchor the cart does after the wall drops is not reproduced; cosmetic, but the seal-in frame may differ) |
| `earthquake 80` shake | `src/script/gen2/Vm.lua:1044` -> `earthquakeFn`, `World:earthquake` (`src/world/gen2/World.lua:1537`) | implemented |
| Scene scripts / `sdefer` (all five door locks, the Hall of Fame induction) | `src/script/gen2/Vm.lua:92` - `sdefer` is executed **immediately** rather than deferred until the map settles | partial (ordering deviation, called out in the source comment) |
| `setmapscene` / `setscene` | `src/script/gen2/Opcodes.lua`, `World:mapSceneOf` (`src/world/gen2/World.lua:1179`) | implemented |
| `loadtrainer` / `startbattle` / `winlosstext` / `reloadmapafterbattle` | `src/script/gen2/Vm.lua`, `src/battle/gen2/Battle.lua`, `src/world/gen2/Trainers.lua` | implemented |
| Trainer party data (`WillGroup` … `ChampionGroup`), class DVs, class items | extracted by `src/import/RomExtractorGen2.lua` (`TrainerGroups`, ~line 3871) | implemented (data-driven) |
| AI item use (Koga/Lance Full Restore, Will/Bruno Max Potion, Karen Full Heal) | `src/battle/gen2/Ai.lua:1369-1375`, `src/battle/gen2/Battle.lua:1747` | implemented |
| Prize money `base x last level` | `src/battle/gen2/Prize.lua` (`Prize.rewardLevel`), used at `src/battle/gen2/Battle.lua:1438` | implemented |
| `pokemart MARTTYPE_STANDARD, MART_INDIGO_PLATEAU` | `src/script/gen2/Vm.lua:597`, `src/ui/gen2/MartMenu.lua`, mart tables extracted at `src/import/RomExtractorGen2.lua:2582` | implemented |
| `jumpstd PokecenterNurseScript` (lobby heal) | `src/script/gen2/Vm.lua` `jumpstd` + std-script table | implemented |
| `TeleportGuyScript` warp to New Bark Town, `AbraScript` `cry ABRA` | generic `warp`/`yesorno`/`cry` opcodes | implemented (data-driven) |
| `halloffame` opcode -> induction bookkeeping | `src/script/gen2/Opcodes.lua:171`, `src/script/gen2/Vm.lua:1382`, `src/world/gen2/World.lua:2374` (`World:hallOfFame`), `src/core/gen2/HallOfFame.lua` (`induct`, `bumpCount`, `buildParty`) | implemented |
| Hall of Fame roster screen + credits, first-time-champion skip lockout | `src/ui/gen2/HallOfFame.lua`, `src/ui/gen2/Credits.lua`; eyeball driver `tests/drivers/gold_halloffame_shots.lua` | implemented |
| `wSpawnAfterChampion` -> post-credits respawn at `SPAWN_NEW_BARK` | `src/core/gen2/HallOfFame.lua:51` (`POST_CREDITS_SPAWN`) and `:254` (`consumePostGameSpawn`) | **partial** - the logic exists and is unit-tested (`tests/gen2_halloffame_test.lua:164`), but grepping `src/` finds **no caller**: nothing on the CONTINUE path consumes it, so a port save resumes where it stood rather than at New Bark Town |
| `specialphonecall SPECIALCALL_SSTICKET` from the induction | `src/script/gen2/Vm.lua` (`specialphonecall`), `src/core/gen2/Phone.lua:394` (`SPECIALCALL_SSTICKET`, id 5) | implemented |
| `ENGINE_FLYPOINT_INDIGO_PLATEAU` -> Fly menu + Kanto map unlock | `src/world/gen2/FieldMoves.lua:368` (`SPAWN_INDIGO`, flag 63), `:414` (Kanto half gate) | implemented |
| `ENGINE_INDIGO_PLATEAU_RIVAL_FIGHT` daily reset | `src/core/gen2/Apricorns.lua:88` (`DAILY_ENGINE_FLAGS`, id 92) | implemented |
| A Gold-side driver that actually walks Route 23 -> Hall of Fame | none found (`tests/drivers/gold_*.lua` has boot/walk/battle/HOF-screen drivers but no League run; `tests/drivers/bot_route.lua` and `tests/parity_lance.lua` are the **Gen 1** Kanto Elite Four) | missing |

---

## 6. Unresolved / verify by hand

1. **"Route 32 is very short, and you'll immediately be at the Pokémon League
   building."** The map between Victory Road and the Plateau is `MAP_ROUTE_23`
   (`constants/map_constants.asm:322`), not Route 32 (which is south of Violet
   City). Walkthrough typo.
2. **The walkthrough is describing HeartGold/SoulSilver parties, not Gold.** Four
   concrete divergences, all verified against `data/trainers/parties.asm`:
   - Will's send-out order is Xatu, Jynx, **Exeggutor, Slowbro**, Xatu; the FAQ
     lists Slowbro third and Exeggutor fifth.
   - Koga's order is Ariados, **Venomoth, Forretress**, Muk, Crobat; the FAQ
     swaps 2 and 3.
   - Bruno's order is Hitmontop, **Hitmonlee, Hitmonchan**, Onix, Machamp; the
     FAQ swaps 2 and 3.
   - Karen and Lance match in order and level.
3. **Prize money.** The FAQ's 4200 / 4400 / 4600 / 4700 / 5000 G are 100 x the
   last mon's level (HGSS). GS pays `base reward x level`
   (`ComputeTrainerReward`, `engine/battle/read_trainer_party.asm:300`) with a
   base reward of 25 for every one of these classes
   (`data/trainers/attributes.asm`), i.e. **1050 / 1100 / 1150 / 1175 / 1250 G**.
   The EXP figures quoted per Pokémon were not checked against
   `data/pokemon/base_stats/` and should be treated as HGSS numbers too.
4. **Held items and AI items.** "Koga has three Full Restores", "Karen has one
   Full Restore", "Lance has three Full Restores", "Houndoom holding a Sitrus
   Berry", "One of the Dragonites may be holding a Sitrus Berry". In GS these
   parties are `TRAINERTYPE_MOVES`, which carries **no held item field at all**,
   and the AI's item pool is the two-byte class row: Will `MAX_POTION, NO_ITEM`;
   Bruno `MAX_POTION, NO_ITEM`; Karen `FULL_HEAL, MAX_POTION` (no Full Restore);
   Koga `FULL_HEAL, FULL_RESTORE`; Champion `FULL_HEAL, FULL_RESTORE`. Sitrus
   Berry does not exist in Gen 2.
5. **Move names.** "Dragon Rush" (Lance's Dragonites) is a Gen 4 move; the GS
   Dragonites run Thunder Wave / Twister / Thunder or Blizzard / Hyper Beam, and
   the level-50 one runs Fire Blast / Safeguard / Outrage / Hyper Beam. Lugia's
   "Aero Blast" and Donphan/Sudowoodo suggestions in the sample lineup are fine
   as species, but none of that is asm-checkable.
6. **"Routes 46 and 47 aren't bad, either."** `ROUTE_47` does not exist in
   pokegold (`constants/map_constants.asm` has `ROUTE_45` and `ROUTE_46` and then
   moves on). Route 47/48 are HGSS additions.
7. **"You can go back to the Move Deleter in Blackthorn City."** There is a
   `maps/MoveDeletersHouse.asm` reached from `maps/BlackthornCity.asm`; I did not
   read its script, so the claim is plausible but unverified here.
8. **"If you trade a Red Scale to Mr. Pokémon, he will give you EXP Share."**
   `maps/MrPokemonsHouse.asm` does `checkitem RED_SCALE` (line 53),
   `verbosegiveitem EXP_SHARE` (line 72), `takeitem RED_SCALE` (line 74), so the
   claim holds; the surrounding flag guards were not read (out of scope).
9. **The "Abra" sprite.** `maps/IndigoPlateauPokecenter1F.asm:324` declares
   `SPRITE_JYNX` for the object whose script is `AbraScript` and whose cry is
   `cry ABRA`. There is no `SPRITE_ABRA` in `constants/sprite_constants.asm`.
   Whether this renders as a Jynx on hardware, or whether some `variablesprite`
   elsewhere rewrites it, was not chased down - no `variablesprite` targeting
   `SPRITE_JYNX` appears in `engine/events/std_scripts.asm`'s init block.
10. **`EVENT_LANCES_ROOM_EXIT_OPEN` is never set.** `LancesRoomDoorsCallback`
    reads it, the lobby callback clears it, but no script in the tree sets it
    (grepped `maps/`). The champion's north door is opened by a bare
    `changeblock 4, 0, $0b`, which does not survive a map reload. Harmless in
    practice because the script warps you out immediately, but a bot that
    somehow re-enters Lance's room post-battle will find the door shut again.
11. **`setevent EVENT_LANCES_ROOM_ENTRANCE_CLOSED` appears twice**: once in
    `LancesRoomDoorLocksBehindYouScript` (correct) and again immediately after
    the champion's after-battle text in `LancesRoomLanceScript`. The second one
    looks like it was meant to be the `EXIT_OPEN` set in item 10; recorded as
    observed, not corrected.
12. **The lobby's redundant `setscene`.** `PlateauRivalPostBattle` sets the scene
    to `SCENE_INDIGOPLATEAUPOKECENTER1F_RIVAL_BATTLE`, which is 0, which is the
    map's only scene and its default. Whether this was intended to disarm the
    coord events (it does not) is a judgement call; the effective guards are the
    engine flag and the weekday check.
13. **"Fully heal your Pokémon and save after every trainer battle."** There is
    no heal source inside the sealed rooms - no nurse object, no
    `special HealParty` until `HallOfFameEnterScript`. The advice is about bag
    items, and the asm agrees that nothing else is available.

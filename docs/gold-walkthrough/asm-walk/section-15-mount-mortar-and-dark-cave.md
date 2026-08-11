# Section 15 - Mount Mortar and Dark Cave

Source: `../section-15-mount-mortar-and-dark-cave.txt`
Maps covered: `MAP_MOUNT_MORTAR_1F_OUTSIDE`, `MAP_MOUNT_MORTAR_1F_INSIDE`,
`MAP_MOUNT_MORTAR_2F_INSIDE`, `MAP_MOUNT_MORTAR_B1F`,
`MAP_DARK_CAVE_BLACKTHORN_ENTRANCE`, `MAP_DARK_CAVE_VIOLET_ENTRANCE`.
Touched in passing (owned by neighbouring sections): `MAP_MAHOGANY_TOWN`,
`MAP_ROUTE_42`, `MAP_BLACKTHORN_CITY`, `MAP_ROUTE_45`, `MAP_ROUTE_31`,
`MAP_ROUTE_46`.

Badges / key milestones in this section: **no badge**. The milestones are
`EVENT_BEAT_BLACKBELT_KIYO` + `EVENT_GOT_TYROGUE_FROM_KIYO` (a free level 10
`TYROGUE`, the only one in the game) and `EVENT_GOT_BLACKGLASSES_IN_DARK_CAVE`.
Everything else here is optional loot. Nothing in this section gates any later
section.

A note on coordinates: every table below is transcribed verbatim from the map's
`_MapEvents` block in the named `maps/*.asm` file. `warp_event`, `coord_event`,
`bg_event` and `object_event` all share one coordinate space (the
`object_event` macro in `macros/scripts/maps.asm` applies the +4 border offset
itself), so the numbers are directly comparable. A map declared
`map_const NAME, W, H` spans x in `0 .. 2W-1` and y in `0 .. 2H-1`.

A note on the `event flag` column of `object_event`:
`engine/overworld/map_objects_2.asm` `CheckObjectFlag` **hides** the object when
the flag is set, and `-1` means always visible. So for a Poke Ball, "flag set =
already taken = gone".

A note on darkness: all six maps in this section are `PALETTE_DARK` in
`data/maps/maps.asm`. `engine/tilesets/timeofday_pals.asm`
`ReplaceTimeOfDayPals` (`23:43e9`) sends `PALETTE_DARK` down `.NeedsFlash`,
which writes `DARKNESS_PALSET` unless `STATUSFLAGS_FLASH_F` is set in
`wStatusFlags`. That bit is set by `BlindingFlash` (`engine/events/field_moves.asm`)
and cleared by `ResetFlashIfOutOfCave` (`home/flag.asm`, `00:2f1d`) on any map
whose `wEnvironment` is `ROUTE` or `TOWN`. **A bot must re-cast Flash every time
it re-enters, including after every Fly.**

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `MAP_MAHOGANY_TOWN` | `data/maps/maps.asm:74`, `data/maps/spawn_points.asm` `spawn MAHOGANY_TOWN, 15, 14` | Fly (`ENGINE_FLYPOINT_MAHOGANY`) | west map connection -> `ROUTE_42` | heal, buy Max Repels / Escape Ropes, drop to 5 party members so Tyrogue fits |
| 2 | `MAP_ROUTE_42` | `maps/Route42.asm` | east connection from Mahogany, or warps 1/2 at (0,8)/(0,9) from the Ecruteak gate | warp 3 (10,5) west entrance, warp 4 (28,9) middle entrance, warp 5 (46,7) east entrance -> `MOUNT_MORTAR_1F_OUTSIDE` warps 1/2/3 | "three cave entrances to Mt. Mortar" |
| 3 | `MAP_MOUNT_MORTAR_1F_OUTSIDE` | `maps/MountMortar1FOutside.asm` | warps 1/2/3 at (3,33)/(17,33)/(37,33) | warp 4 (17,5) -> 2F after Waterfall; warp 7 (17,29) -> B1F | all three Route 42 doors land on this one map; the Surf lake and the waterfall live here |
| 4 | `MAP_MOUNT_MORTAR_1F_INSIDE` | `maps/MountMortar1FInside.asm` | 1F Outside warps 5/6 (11,21)/(29,21) or 8/9 (7,13)/(33,13) | warp 5 (3,19) -> B1F; warp 6 (9,9) -> 2F | the "giant room" with the Strength boulder, Escape Rope and Hyper Potion |
| 5 | `MAP_MOUNT_MORTAR_2F_INSIDE` | `maps/MountMortar2FInside.asm` | warp 1 (17,33) from 1F Outside warp 4 (top of the waterfall) | warp 2 (3,5) -> `MOUNT_MORTAR_1F_INSIDE` warp 6 | Rare Candy, Max Potion, TM40, Dragon Scale, Elixer, Escape Rope, hidden Full Restore |
| 6 | `MAP_MOUNT_MORTAR_B1F` | `maps/MountMortarB1F.asm` | warp 1 (3,3) from 1F Inside warp 5 | Escape Rope, or Strength the boulder at (9,10) and take warp 2 (19,29) -> 1F Outside warp 7 | **Blackbelt Kiyo, then the free Tyrogue** |
| 7 | `MAP_BLACKTHORN_CITY` | `data/maps/maps.asm:187`, `data/maps/spawn_points.asm` `spawn BLACKTHORN_CITY, 21, 30` | Fly (`ENGINE_FLYPOINT_BLACKTHORN`) | south map connection (`data/maps/attributes.asm:161` `connection south, Route45, ROUTE_45, 0`) | heal, then head south |
| 8 | `MAP_ROUTE_45` | `maps/Route45.asm` | north connection from Blackthorn | warp 1 (2,5) -> `DARK_CAVE_BLACKTHORN_ENTRANCE` warp 1 | "enter the Dark Cave to the left before there are even any jumps" |
| 9 | `MAP_DARK_CAVE_BLACKTHORN_ENTRANCE` | `maps/DarkCaveBlackthornEntrance.asm` | warp 1 (23,3) | warp 2 (3,25) -> `DARK_CAVE_VIOLET_ENTRANCE` warp 2 | Blackglasses NPC, Revive, TM13 Snore, Wobbuffet |
| 10 | `MAP_DARK_CAVE_VIOLET_ENTRANCE` | `maps/DarkCaveVioletEntrance.asm` | warp 2 (17,1) | warp 1 (3,15) -> `ROUTE_31` warp 3 | "surf down, rock smash the rock, grab the Potion, head out onto Route 31" |
| 11 | `MAP_ROUTE_31` | `maps/Route31.asm` | warp 3 (34,5) | Fly back to Blackthorn | walkthrough exit |

Spill into the next section: the walkthrough's video links name Blackthorn Gym,
Route 45/46, Tohjo Falls, Routes 26/27, Victory Road and the Elite Four, but its
**prose** stops at "head back south to actually take Route 45". `MAP_ROUTE_45`
proper, `MAP_ROUTE_46`, `MAP_BLACKTHORN_GYM` and everything past them belong to
the next section; only the Route 45 warp that reaches Dark Cave is documented
here.

`MAP_DARK_CAVE_VIOLET_ENTRANCE` is also reachable from `ROUTE_46` warp 3 at
(14,5) (-> Dark Cave warp 3 at (35,33)) and from `ROUTE_31` warp 3; the earlier
sections that visit Route 31 already touch the north end of this map. This
section only walks it top-to-bottom-left, from the Blackthorn side out to
Route 31.

---

## 2. Maps

### MAP_MOUNT_MORTAR_1F_OUTSIDE

- Script: `maps/MountMortar1FOutside.asm`
- Blocks: `maps/MountMortar1FOutside.blk`
- Header: `data/maps/maps.asm:127` -> `TILESET_DARK_CAVE`, `CAVE`,
  `LANDMARK_MT_MORTAR`, `MUSIC_UNION_CAVE`, phone `TRUE`, `PALETTE_DARK`,
  `FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:114` `map_const MOUNT_MORTAR_1F_OUTSIDE, 20, 18`
  (x 0..39, y 0..35), map id 49, group 3
- Attributes: `data/maps/attributes.asm:446`, border block `$09`, **no connections**
- Map events block: `MountMortar1FOutside_MapEvents` = `46:5db9`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 33 | `ROUTE_42` | 3 |
| 2 | 17 | 33 | `ROUTE_42` | 4 |
| 3 | 37 | 33 | `ROUTE_42` | 5 |
| 4 | 17 | 5 | `MOUNT_MORTAR_2F_INSIDE` | 1 |
| 5 | 11 | 21 | `MOUNT_MORTAR_1F_INSIDE` | 1 |
| 6 | 29 | 21 | `MOUNT_MORTAR_1F_INSIDE` | 2 |
| 7 | 17 | 29 | `MOUNT_MORTAR_B1F` | 2 |
| 8 | 7 | 13 | `MOUNT_MORTAR_1F_INSIDE` | 3 |
| 9 | 33 | 13 | `MOUNT_MORTAR_1F_INSIDE` | 4 |

**Coord events** (`def_coord_events`)

`def_coord_events` is **empty**. No scripted trip-wires anywhere in Mt. Mortar.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 25 | 22 | `BGEVENT_ITEM` | `MountMortar1FOutsideHiddenHyperPotion` -> `hiddenitem HYPER_POTION, EVENT_MOUNT_MORTAR_1F_OUTSIDE_HIDDEN_HYPER_POTION` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MOUNTMORTAR1FOUTSIDE_POKE_BALL1` | `SPRITE_POKE_BALL` | 13 | 15 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `MountMortar1FOutsideEther` (`itemball ETHER`) | `EVENT_MOUNT_MORTAR_1F_OUTSIDE_ETHER` |
| `MOUNTMORTAR1FOUTSIDE_POKE_BALL2` | `SPRITE_POKE_BALL` | 31 | 18 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `MountMortar1FOutsideGuardSpec` (`itemball GUARD_SPEC`) | `EVENT_MOUNT_MORTAR_1F_OUTSIDE_REVIVE` |

Note the flag/item mismatch on the second ball: the item is `GUARD_SPEC` but the
flag is named `..._REVIVE`. That is verbatim from the disassembly - the label
name is cosmetic, the flag bit is what matters.

**Scripts of interest**

- `MountMortar1FOutsideEther` / `MountMortar1FOutsideGuardSpec` - bare
  `itemball ITEM` rows (two bytes, no bytecode). Picked up by the shared
  `FindItemInBallScript` path, not by a per-map script.
- `MountMortar1FOutsideHiddenHyperPotion` - `hiddenitem` data behind a
  `BGEVENT_ITEM` row; A-pressed on (25,22) or found by the ITEMFINDER.

**Wild encounters**

`data/wild/johto_grass.asm:686` `def_grass_wildmons MOUNT_MORTAR_1F_OUTSIDE`,
encounter rate `6 percent` for all three of morn/day/nite, and **all three
slot lists are identical**:

| slot | lvl | species |
|---|---|---|
| 1 | 13 | ZUBAT |
| 2 | 15 | ZUBAT |
| 3 | 14 | MACHOP |
| 4 | 14 | RATTATA |
| 5 | 14 | GEODUDE |
| 6 | 16 | RATTATA |
| 7 | 15 | MARILL |

`data/wild/johto_water.asm:58` `def_water_wildmons MOUNT_MORTAR_1F_OUTSIDE`,
rate `4 percent`: 20 GOLDEEN / 15 GOLDEEN / 20 SEAKING.

Fishing: `FISHGROUP_LAKE`, `data/wild/fish.asm:57` - Old rod MAGIKARP 10 /
GOLDEEN 10; Good rod MAGIKARP 20 / GOLDEEN 20 / `time_group 4`; Super rod
GOLDEEN 40 / `time_group 5` / MAGIKARP 40 / SEAKING 40.

No headbutt or rock-smash table (`data/wild/treemon_maps.asm` does not list this
map).

---

### MAP_MOUNT_MORTAR_1F_INSIDE

- Script: `maps/MountMortar1FInside.asm`
- Blocks: `maps/MountMortar1FInside.blk`
- Header: `data/maps/maps.asm:128` -> `TILESET_DARK_CAVE`, `CAVE`,
  `LANDMARK_MT_MORTAR`, `MUSIC_UNION_CAVE`, phone `TRUE`, `PALETTE_DARK`,
  `FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:115` `map_const MOUNT_MORTAR_1F_INSIDE, 20, 27`
  (x 0..39, y 0..53), map id 50, group 3
- Attributes: `data/maps/attributes.asm:447`, border block `$09`, **no connections**
- Map events block: `MountMortar1FInside_MapEvents` = `46:5e19`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 11 | 47 | `MOUNT_MORTAR_1F_OUTSIDE` | 5 |
| 2 | 29 | 47 | `MOUNT_MORTAR_1F_OUTSIDE` | 6 |
| 3 | 5 | 39 | `MOUNT_MORTAR_1F_OUTSIDE` | 8 |
| 4 | 33 | 41 | `MOUNT_MORTAR_1F_OUTSIDE` | 9 |
| 5 | 3 | 19 | `MOUNT_MORTAR_B1F` | 1 |
| 6 | 9 | 9 | `MOUNT_MORTAR_2F_INSIDE` | 2 |

**Coord events** - empty.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 31 | 9 | `BGEVENT_ITEM` | `MountMortar1FInsideHiddenMaxRepel` -> `hiddenitem MAX_REPEL, EVENT_MOUNT_MORTAR_1F_INSIDE_HIDDEN_MAX_REPEL` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MOUNTMORTAR1FINSIDE_BOULDER` | `SPRITE_BOULDER` | 21 | 43 | `SPRITEMOVEDATA_STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | `MountMortar1FBoulder` (`jumpstd StrengthBoulderScript`) | `-1` |
| `MOUNTMORTAR1FINSIDE_POKE_BALL1` | `SPRITE_POKE_BALL` | 33 | 22 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `MountMortar1FInsideEscapeRope` (`itemball ESCAPE_ROPE`) | `EVENT_MOUNT_MORTAR_1F_INSIDE_ESCAPE_ROPE` |
| `MOUNTMORTAR1FINSIDE_POKE_BALL2` | `SPRITE_POKE_BALL` | 16 | 10 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `MountMortar1FInsideMaxRevive` (`itemball MAX_REVIVE`) | `EVENT_MOUNT_MORTAR_1F_INSIDE_MAX_REVIVE` |
| `MOUNTMORTAR1FINSIDE_POKE_BALL3` | `SPRITE_POKE_BALL` | 12 | 21 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `MountMortar1FInsideHyperPotion` (`itemball HYPER_POTION`) | `EVENT_MOUNT_MORTAR_1F_INSIDE_HYPER_POTION` |

**Scripts of interest**

- `MountMortar1FBoulder` - one line: `jumpstd StrengthBoulderScript`.
  `engine/events/std_scripts.asm:196` `StrengthBoulderScript: farsjump AskStrengthScript`
  (`03:4d4e`). See section 3 for the gate.

**Wild encounters**

`data/wild/johto_grass.asm:714` `def_grass_wildmons MOUNT_MORTAR_1F_INSIDE`,
rate `6 percent` morn/day/nite, all three lists identical:

| slot | lvl | species |
|---|---|---|
| 1 | 13 | GEODUDE |
| 2 | 13 | MACHOP |
| 3 | 15 | GEODUDE |
| 4 | 14 | RATTATA |
| 5 | 15 | MACHOP |
| 6 | 14 | ZUBAT |
| 7 | 14 | ZUBAT |

**There is no `def_water_wildmons MOUNT_MORTAR_1F_INSIDE`** in
`data/wild/johto_water.asm` - only 1F Outside, 2F Inside and B1F have water
tables. Fishing group is still `FISHGROUP_LAKE`.

---

### MAP_MOUNT_MORTAR_2F_INSIDE

- Script: `maps/MountMortar2FInside.asm`
- Blocks: `maps/MountMortar2FInside.blk`
- Header: `data/maps/maps.asm:129` -> `TILESET_DARK_CAVE`, `CAVE`,
  `LANDMARK_MT_MORTAR`, `MUSIC_UNION_CAVE`, phone `TRUE`, `PALETTE_DARK`,
  `FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:116` `map_const MOUNT_MORTAR_2F_INSIDE, 20, 18`
  (x 0..39, y 0..35), map id 51, group 3
- Attributes: `data/maps/attributes.asm:448`, border block `$09`, **no connections**
- Map events block: `MountMortar2FInside_MapEvents` = `46:5e87`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 17 | 33 | `MOUNT_MORTAR_1F_OUTSIDE` | 4 |
| 2 | 3 | 5 | `MOUNT_MORTAR_1F_INSIDE` | 6 |

**Coord events** - empty.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 19 | 6 | `BGEVENT_ITEM` | `MountMortar2FInsideHiddenFullRestore` -> `hiddenitem FULL_RESTORE, EVENT_MOUNT_MORTAR_2F_INSIDE_HIDDEN_FULL_RESTORE` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MOUNTMORTAR2FINSIDE_POKE_BALL1` | `SPRITE_POKE_BALL` | 31 | 23 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `MountMortar2FInsideMaxPotion` (`itemball MAX_POTION`) | `EVENT_MOUNT_MORTAR_2F_INSIDE_MAX_POTION` |
| `MOUNTMORTAR2FINSIDE_POKE_BALL2` | `SPRITE_POKE_BALL` | 2 | 24 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `MountMortar2FInsideRareCandy` (`itemball RARE_CANDY`) | `EVENT_MOUNT_MORTAR_2F_INSIDE_RARE_CANDY` |
| `MOUNTMORTAR2FINSIDE_POKE_BALL3` | `SPRITE_POKE_BALL` | 19 | 17 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `MountMortar2FInsideTMDefenseCurl` (`itemball TM_DEFENSE_CURL`) | `EVENT_MOUNT_MORTAR_2F_INSIDE_TM_DEFENSE_CURL` |
| `MOUNTMORTAR2FINSIDE_POKE_BALL4` | `SPRITE_POKE_BALL` | 14 | 5 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `MountMortar2FInsideDragonScale` (`itemball DRAGON_SCALE`) | `EVENT_MOUNT_MORTAR_2F_INSIDE_DRAGON_SCALE` |
| `MOUNTMORTAR2FINSIDE_POKE_BALL5` | `SPRITE_POKE_BALL` | 8 | 9 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `MountMortar2FInsideElixer` (`itemball ELIXER`) | `EVENT_MOUNT_MORTAR_2F_INSIDE_ELIXER` |
| `MOUNTMORTAR2FINSIDE_POKE_BALL6` | `SPRITE_POKE_BALL` | 28 | 5 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `MountMortar2FInsideEscapeRope` (`itemball ESCAPE_ROPE`) | `EVENT_MOUNT_MORTAR_2F_INSIDE_ESCAPE_ROPE` |

`TM_DEFENSE_CURL` is **TM40** by the `add_tm` ordering in
`constants/item_constants.asm:261`. The walkthrough calls it "TM40 Aerial Ace",
which is the HGSS remake's TM40 - see section 6.

**Wild encounters**

`data/wild/johto_grass.asm:742` `def_grass_wildmons MOUNT_MORTAR_2F_INSIDE`,
rate `6 percent` morn/day/nite, all three lists identical - this is the floor
the walkthrough's "Raticate / Machoke / Graveler" list is drawn from:

| slot | lvl | species |
|---|---|---|
| 1 | 31 | GRAVELER |
| 2 | 32 | MACHOKE |
| 3 | 31 | GEODUDE |
| 4 | 30 | RATICATE |
| 5 | 28 | MACHOP |
| 6 | 30 | GOLBAT |
| 7 | 30 | GOLBAT |

`data/wild/johto_water.asm:65` `def_water_wildmons MOUNT_MORTAR_2F_INSIDE`,
rate `2 percent`: 20 GOLDEEN / 25 GOLDEEN / 25 SEAKING.

---

### MAP_MOUNT_MORTAR_B1F

- Script: `maps/MountMortarB1F.asm`
- Blocks: `maps/MountMortarB1F.blk`
- Header: `data/maps/maps.asm:130` -> `TILESET_DARK_CAVE`, `CAVE`,
  `LANDMARK_MT_MORTAR`, `MUSIC_UNION_CAVE`, phone `TRUE`, `PALETTE_DARK`,
  `FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:117` `map_const MOUNT_MORTAR_B1F, 20, 18`
  (x 0..39, y 0..35), map id 52, group 3
- Attributes: `data/maps/attributes.asm:449`, border block `$09`, **no connections**
- Map events block: `MountMortarB1F_MapEvents` = `46:60f0`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 3 | `MOUNT_MORTAR_1F_INSIDE` | 5 |
| 2 | 19 | 29 | `MOUNT_MORTAR_1F_OUTSIDE` | 7 |

**Coord events** - empty. Kiyo is a talk-to trigger, not a trip-wire.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 4 | 6 | `BGEVENT_ITEM` | `MountMortarB1FHiddenMaxRevive` -> `hiddenitem MAX_REVIVE, EVENT_MOUNT_MORTAR_B1F_HIDDEN_MAX_REVIVE` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MOUNTMORTARB1F_POKE_BALL1` | `SPRITE_POKE_BALL` | 31 | 17 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `MountMortarB1FHyperPotion` (`itemball HYPER_POTION`) | `EVENT_MOUNT_MORTAR_B1F_HYPER_POTION` |
| `MOUNTMORTARB1F_POKE_BALL2` | `SPRITE_POKE_BALL` | 4 | 16 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `MountMortarB1FFullHeal` (`itemball FULL_HEAL`) | `EVENT_MOUNT_MORTAR_B1F_FULL_HEAL` |
| `MOUNTMORTARB1F_BOULDER` | `SPRITE_BOULDER` | 9 | 10 | `SPRITEMOVEDATA_STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | `MountMortarB1FBoulder` (`jumpstd StrengthBoulderScript`) | `-1` |
| `MOUNTMORTARB1F_KIYO` | `SPRITE_BLACK_BELT` | 13 | 4 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT`, palette `PAL_NPC_BROWN` | `MountMortarB1FKiyoScript` | `-1` |

**Scripts of interest**

`MountMortarB1FKiyoScript` (`46:5eec`) - the whole point of this section. Note
it is `OBJECTTYPE_SCRIPT`, **not** `OBJECTTYPE_TRAINER`: Kiyo has no `trainer`
header, no sight range, and never walks up to you. He must be talked to.

```
faceplayer
opentext
checkevent EVENT_GOT_TYROGUE_FROM_KIYO     ; iftrue -> .GotTyrogue (46:5f27)
checkevent EVENT_BEAT_BLACKBELT_KIYO       ; iftrue -> .BeatKiyo   (46:5f0d)
writetext MountMortarB1FKiyoIntroText
waitbutton
closetext
winlosstext MountMortarB1FKiyoWinText, 0
loadtrainer BLACKBELT_T, KIYO
startbattle
reloadmapafterbattle
setevent EVENT_BEAT_BLACKBELT_KIYO
opentext
.BeatKiyo:
writetext MountMortarB1FTyrogueRewardText
promptbutton
waitsfx
readvar VAR_PARTYCOUNT
ifequal PARTY_LENGTH, .NoRoom              ; 46:5f2d
writetext MountMortarB1FReceiveMonText
playsound SFX_CAUGHT_MON
waitsfx
givepoke TYROGUE, 10
setevent EVENT_GOT_TYROGUE_FROM_KIYO
.GotTyrogue:
writetext MountMortarB1FKiyoGotTyrogueText
waitbutton
closetext
end
```

Bot-relevant control flow:

- The battle is unconditional on first talk (no `checkevent` guard before
  `loadtrainer`), and the win-flag write is **after** `startbattle`, so a
  blackout means the whole script re-runs from the top.
- `readvar VAR_PARTYCOUNT` / `ifequal PARTY_LENGTH` is the "you have no room"
  branch. `PARTY_LENGTH` is 6. **If the party is full, `EVENT_BEAT_BLACKBELT_KIYO`
  is already set but `EVENT_GOT_TYROGUE_FROM_KIYO` is not**, so re-talking
  re-enters at `.BeatKiyo` and offers the Tyrogue again. This is why the
  walkthrough tells you to free a slot in advance - but it is recoverable, not
  missable.
- `givepoke TYROGUE, 10` - level 10, no held item, no nickname prompt in this
  form of the opcode.

`MountMortarB1FBoulder` - `jumpstd StrengthBoulderScript`, same as 1F Inside.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_BLACKBELT_KIYO` | `constants/event_flags.asm:684` | set by `MountMortarB1FKiyoScript` after `startbattle` | Kiyo will not fight again |
| `EVENT_GOT_TYROGUE_FROM_KIYO` | `constants/event_flags.asm:106` | set by `MountMortarB1FKiyoScript` after `givepoke` | the Tyrogue is banked; the script becomes pure flavour |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `KIYO` (`constants/trainer_constants.asm:500`) | `BLACKBELT_T` | 6th entry of `BlackbeltGroup` | `data/trainers/parties.asm:2455` `; BLACKBELT_T (6)` `db "KIYO@", TRAINERTYPE_NORMAL` / `db 34, HITMONLEE` / `db 34, HITMONCHAN` | `MountMortarB1FKiyoScript` | none - no `trainer` header, so no phone number, no rematch |

`TRAINERTYPE_NORMAL` means **no custom moves and no held items**: both mons use
their level-34 learnset defaults. The walkthrough's "816G" prize and the
1012/1020 EXP figures were not verified against `data/trainers/attributes.asm` -
see section 6.

**Wild encounters**

`data/wild/johto_grass.asm:770` `def_grass_wildmons MOUNT_MORTAR_B1F`, rate
`6 percent` morn/day/nite, all three lists identical:

| slot | lvl | species |
|---|---|---|
| 1 | 15 | ZUBAT |
| 2 | 17 | ZUBAT |
| 3 | 16 | RATTATA |
| 4 | 16 | MACHOP |
| 5 | 16 | GEODUDE |
| 6 | 16 | RATICATE |
| 7 | 16 | RATICATE |

`data/wild/johto_water.asm:72` `def_water_wildmons MOUNT_MORTAR_B1F`, rate
`2 percent`: 20 GOLDEEN / 15 GOLDEEN / 20 SEAKING.

---

### MAP_DARK_CAVE_BLACKTHORN_ENTRANCE

- Script: `maps/DarkCaveBlackthornEntrance.asm`
- Blocks: `maps/DarkCaveBlackthornEntrance.blk`
- Header: `data/maps/maps.asm:149` -> `TILESET_DARK_CAVE`, `CAVE`,
  `LANDMARK_DARK_CAVE`, `MUSIC_DARK_CAVE`, phone `TRUE`, `PALETTE_DARK`,
  `FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:136` `map_const DARK_CAVE_BLACKTHORN_ENTRANCE, 15, 18`
  (x 0..29, y 0..35), map id 71, group 3
- Attributes: `data/maps/attributes.asm:468`, border block `$09`, **no connections**
- Map events block: `DarkCaveBlackthornEntrance_MapEvents` = `47:4489`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 23 | 3 | `ROUTE_45` | 1 |
| 2 | 3 | 25 | `DARK_CAVE_VIOLET_ENTRANCE` | 2 |

**Coord events** - empty.

**BG events** - `def_bg_events` is **empty**. No signs, no hidden items.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `DARKCAVEBLACKTHORNENTRANCE_PHARMACIST` | `SPRITE_PHARMACIST` | 7 | 3 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `DarkCaveBlackthornEntrancePharmacistScript` | `-1` |
| `DARKCAVEBLACKTHORNENTRANCE_POKE_BALL1` | `SPRITE_POKE_BALL` | 21 | 24 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `DarkCaveBlackthornEntranceRevive` (`itemball REVIVE`) | `EVENT_DARK_CAVE_BLACKTHORN_ENTRANCE_REVIVE` |
| `DARKCAVEBLACKTHORNENTRANCE_POKE_BALL2` | `SPRITE_POKE_BALL` | 7 | 22 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `DarkCaveBlackthornEntranceTMSnore` (`itemball TM_SNORE`) | `EVENT_DARK_CAVE_BLACKTHORN_ENTRANCE_TM_SNORE` |

`TM_SNORE` is **TM13** by the `add_tm` ordering in
`constants/item_constants.asm:233`, which matches the walkthrough's "TM 13".

**Scripts of interest**

`DarkCaveBlackthornEntrancePharmacistScript` (`47:436c`):

```
faceplayer
opentext
checkevent EVENT_GOT_BLACKGLASSES_IN_DARK_CAVE  ; iftrue -> .GotBlackglasses (47:4381)
writetext DarkCaveBlackthornEntrancePharmacistText1
promptbutton
verbosegiveitem BLACKGLASSES
iffalse .PackFull                                ; 47:4385
setevent EVENT_GOT_BLACKGLASSES_IN_DARK_CAVE
.GotBlackglasses:
writetext DarkCaveBlackthornEntrancePharmacistText2
waitbutton
.PackFull:
closetext
end
```

Bot-relevant: `verbosegiveitem` returns 0 when the pack is full, and the
`setevent` is **after** the give, so a full item pocket leaves the flag clear
and the NPC re-offers. Not missable. The NPC spins
(`SPRITEMOVEDATA_SPINRANDOM_SLOW`), so the bot must stand adjacent and press A;
`faceplayer` handles the turn.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_GOT_BLACKGLASSES_IN_DARK_CAVE` | `constants/event_flags.asm:123` | `DarkCaveBlackthornEntrancePharmacistScript` | BLACKGLASSES banked; NPC becomes flavour text |
| `EVENT_DARK_CAVE_BLACKTHORN_ENTRANCE_REVIVE` | `constants/event_flags.asm:1090` | object visibility mask | set = ball already taken |
| `EVENT_DARK_CAVE_BLACKTHORN_ENTRANCE_TM_SNORE` | `constants/event_flags.asm:1091` | object visibility mask | set = TM13 already taken |

**Wild encounters**

`data/wild/johto_grass.asm:1545` `def_grass_wildmons DARK_CAVE_BLACKTHORN_ENTRANCE`,
rate `4 percent` morn/day/nite, all three lists identical - this is the
walkthrough's Wobbuffet spot:

| slot | lvl | species |
|---|---|---|
| 1 | 23 | GEODUDE |
| 2 | 23 | ZUBAT |
| 3 | 25 | GRAVELER |
| 4 | 20 | WOBBUFFET |
| 5 | 25 | WOBBUFFET |
| 6 | 23 | GOLBAT |
| 7 | 23 | GOLBAT |

`data/wild/johto_water.asm:114` `def_water_wildmons DARK_CAVE_BLACKTHORN_ENTRANCE`,
rate `2 percent`: 15 MAGIKARP / 10 MAGIKARP / 5 MAGIKARP.

No `treemon_map` row for this map - **rock smash here yields nothing**, and
there are no smashable rock objects on it either.

---

### MAP_DARK_CAVE_VIOLET_ENTRANCE

- Script: `maps/DarkCaveVioletEntrance.asm`
- Blocks: `maps/DarkCaveVioletEntrance.blk`
- Header: `data/maps/maps.asm:148` -> `TILESET_DARK_CAVE`, `CAVE`,
  `LANDMARK_DARK_CAVE`, `MUSIC_DARK_CAVE`, phone `TRUE`, `PALETTE_DARK`,
  `FISHGROUP_LAKE`
- Dimensions: `constants/map_constants.asm:135` `map_const DARK_CAVE_VIOLET_ENTRANCE, 20, 18`
  (x 0..39, y 0..35), map id 70, group 3
- Attributes: `data/maps/attributes.asm:467`, border block `$09`, **no connections**
- Map events block: `DarkCaveVioletEntrance_MapEvents` = `47:42f5`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 15 | `ROUTE_31` | 3 |
| 2 | 17 | 1 | `DARK_CAVE_BLACKTHORN_ENTRANCE` | 2 |
| 3 | 35 | 33 | `ROUTE_46` | 3 |

**Coord events** - empty.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 26 | 3 | `BGEVENT_ITEM` | `DarkCaveVioletEntranceHiddenElixer` -> `hiddenitem ELIXER, EVENT_DARK_CAVE_VIOLET_ENTRANCE_HIDDEN_ELIXER` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `DARKCAVEVIOLETENTRANCE_POKE_BALL1` | `SPRITE_POKE_BALL` | 6 | 8 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `DarkCaveVioletEntrancePotion` (`itemball POTION`) | `EVENT_DARK_CAVE_VIOLET_ENTRANCE_POTION` |
| `DARKCAVEVIOLETENTRANCE_ROCK1` | `SPRITE_ROCK` | 16 | 14 | `SPRITEMOVEDATA_SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | `DarkCaveVioletEntranceRock` (`jumpstd SmashRockScript`) | `-1` |
| `DARKCAVEVIOLETENTRANCE_ROCK2` | `SPRITE_ROCK` | 27 | 6 | `SPRITEMOVEDATA_SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | `DarkCaveVioletEntranceRock` | `-1` |
| `DARKCAVEVIOLETENTRANCE_ROCK3` | `SPRITE_ROCK` | 7 | 14 | `SPRITEMOVEDATA_SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | `DarkCaveVioletEntranceRock` | `-1` |
| `DARKCAVEVIOLETENTRANCE_ROCK4` | `SPRITE_ROCK` | 36 | 31 | `SPRITEMOVEDATA_SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | `DarkCaveVioletEntranceRock` | `-1` |
| `DARKCAVEVIOLETENTRANCE_POKE_BALL2` | `SPRITE_POKE_BALL` | 36 | 22 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `DarkCaveVioletEntranceFullHeal` (`itemball FULL_HEAL`) | `EVENT_DARK_CAVE_VIOLET_ENTRANCE_FULL_HEAL` |
| `DARKCAVEVIOLETENTRANCE_POKE_BALL3` | `SPRITE_POKE_BALL` | 35 | 9 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `DarkCaveVioletEntranceHyperPotion` (`itemball HYPER_POTION`) | `EVENT_DARK_CAVE_VIOLET_ENTRANCE_HYPER_POTION` |

Note the four rocks all share one script label; the smash `disappear LAST_TALKED`
in `RockSmashScript` acts on `hLastTalked`, so they are independent objects
despite the shared pointer. Rocks have **no event flag** (`-1`) - they come back
on every map reload.

**Scripts of interest**

`DarkCaveVioletEntranceRock` - `jumpstd SmashRockScript`
(`engine/events/std_scripts.asm:199` -> `farsjump AskRockSmashScript`, `03:4f60`).
`AskRockSmashScript` calls `HasRockSmash` (`03:4f7f`), which is **inverted**
(`wScriptVar = 1` when the party does NOT know ROCK SMASH); on 0 it prompts
yes/no and falls into `RockSmashScript` (`03:4f35`):
`playsound SFX_STRENGTH` / `earthquake 84` / `applymovementlasttalked MovementData_RockSmash`
/ `disappear LAST_TALKED` / `callasm RockMonEncounter` / `randomwildmon` /
`startbattle`.

**Wild encounters**

`data/wild/johto_grass.asm:1517` `def_grass_wildmons DARK_CAVE_VIOLET_ENTRANCE`,
rate `4 percent` morn/day/nite, all three lists identical:

| slot | lvl | species |
|---|---|---|
| 1 | 3 | GEODUDE |
| 2 | 2 | ZUBAT |
| 3 | 2 | GEODUDE |
| 4 | 4 | GEODUDE |
| 5 | 3 | ZUBAT |
| 6 | 4 | ZUBAT |
| 7 | 4 | DUNSPARCE |

`data/wild/johto_water.asm:107` `def_water_wildmons DARK_CAVE_VIOLET_ENTRANCE`,
rate `2 percent`: 15 MAGIKARP / 10 MAGIKARP / 5 MAGIKARP.

**Rock smash encounters** - this map IS in `data/wild/treemon_maps.asm:46`
`RockMonMaps`: `treemon_map DARK_CAVE_VIOLET_ENTRANCE, TREEMON_SET_ROCK`.
`RockMonEncounter` (`2e:63a1`) rolls `RandomRange 10 < 4` (a 40% chance) and then
`SelectTreeMon` over `data/wild/treemons.asm:91` `TreeMonSet_Rock`:
90% KRABBY lvl 15, 10% SHUCKLE lvl 15. **This is the only Shuckle source in
Johto reachable in this section**, and the walkthrough does not mention it.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Darkness on all six maps | `engine/tilesets/timeofday_pals.asm` `ReplaceTimeOfDayPals` (`23:43e9`) `.NeedsFlash` -> `DARKNESS_PALSET`, because `data/maps/maps.asm` lines 127-130 / 148-149 all say `PALETTE_DARK` | FLASH cast, i.e. `STATUSFLAGS_FLASH_F` set in `wStatusFlags` | `engine/events/overworld.asm` `FlashFunction.CheckUseFlash` (`03:48f1`): `ENGINE_ZEPHYRBADGE` **and** `wTimeOfDayPalset == DARKNESS_PALSET`. The bit is cleared by `home/flag.asm` `ResetFlashIfOutOfCave` (`00:2f1d`) on any `ROUTE`/`TOWN` map, so **re-cast after every exit and every Fly** |
| Mt. Mortar middle entrance (`ROUTE_42` warp 4 at (28,9)) | terrain: the tile is across water on Route 42 | SURF | `engine/events/overworld.asm` `SurfFunction` (`03:493b`), `.TrySurf` arm / `TrySurfOW` (`03:4a06`): `ENGINE_FOGBADGE` + a party member knowing SURF |
| The lake and the waterfall between 1F Outside and 2F | terrain on `MountMortar1FOutside.blk`; the only route to warp 4 at (17,5) | SURF, then WATERFALL | `WaterfallFunction.TryWaterfall` (`03:4af6`) / `TryWaterfallOW` (`03:4b5f`): `ENGINE_RISINGBADGE`, then `CheckMapCanWaterfall` - **player must be facing UP and the tile ABOVE (`wTileUp`) must be a waterfall tile** |
| `MOUNTMORTAR1FINSIDE_BOULDER` at (21,43) | `MountMortar1FBoulder` -> `jumpstd StrengthBoulderScript` -> `AskStrengthScript` (`03:4d4e`) | STRENGTH toggled on | `TryStrengthOW` (`03:4d7b`): party knows STRENGTH **and** `ENGINE_PLAINBADGE` **and** `BIKEFLAGS_STRENGTH_ACTIVE_F` set. `StrengthFunction.TryStrength` (`03:4cf1`) only checks the badge. Note `ResetBikeFlags` clears the active bit on **every map load** - Strength must be re-activated per floor |
| `MOUNTMORTARB1F_BOULDER` at (9,10) | `MountMortarB1FBoulder`, same std script | STRENGTH | as above. This is the walkthrough's "move the rock with HM Strength to get out"; the alternative is an Escape Rope |
| Kiyo's Tyrogue | `MountMortarB1FKiyoScript` `readvar VAR_PARTYCOUNT` / `ifequal PARTY_LENGTH, .NoRoom` | 5 or fewer party members | free a slot and re-talk; `EVENT_BEAT_BLACKBELT_KIYO` stays set so the battle is not repeated |
| Dark Cave water crossings (both entrances) | terrain | SURF | `ENGINE_FOGBADGE` as above |
| `DARKCAVEVIOLETENTRANCE_ROCK1..4` | `DarkCaveVioletEntranceRock` -> `jumpstd SmashRockScript` -> `AskRockSmashScript` (`03:4f60`) | a party member knowing ROCK SMASH (TM08) | `HasRockSmash` (`03:4f7f`) - **no badge check at all** for Rock Smash |
| Fly between Mahogany and Blackthorn | `engine/events/overworld.asm:545` (the `.TryFly` arm of the Fly jumptable) `ld de, ENGINE_STORMBADGE` | `ENGINE_STORMBADGE` + the destination's `ENGINE_FLYPOINT_*` (`constants/engine_flags.asm:87`, `:89`) | both flypoints are set by visiting the towns in earlier sections |

Badge constants used above: `ENGINE_ZEPHYRBADGE` (`constants/engine_flags.asm:38`),
`ENGINE_PLAINBADGE` (`:40`), `ENGINE_FOGBADGE` (`:41`), `ENGINE_STORMBADGE`
(`:43`), `ENGINE_RISINGBADGE` (`:45`). All are checked through
`engine/events/overworld.asm` `CheckBadge` (line 50), which prints
"Badge required" and returns carry.

**Nothing in this section gates anything else.** Both Mt. Mortar and Dark Cave
are entirely optional; a bot that skips them loses only items, the Tyrogue and
the Blackglasses.

---

## 4. Bot checklist

Preconditions for the whole section: `ENGINE_ZEPHYRBADGE`, `ENGINE_FOGBADGE`,
`ENGINE_PLAINBADGE`, `ENGINE_RISINGBADGE`, `ENGINE_STORMBADGE`; party members
knowing FLASH, SURF, STRENGTH, WATERFALL (and ROCK SMASH for step 26); party
count <= 5 before step 20.

| # | Map | Target | Intent | Precondition | Postcondition |
|---|---|---|---|---|---|
| 1 | `MAHOGANY_TOWN` | spawn (15,14) | Fly in, heal, buy MAX_REPEL / ESCAPE_ROPE | `ENGINE_FLYPOINT_MAHOGANY` | party healthy, bag stocked |
| 2 | `MAHOGANY_TOWN` | west map connection | walk west | - | on `ROUTE_42` |
| 3 | `ROUTE_42` | warp 3 at (10,5) | step onto warp (west entrance) | - | on `MOUNT_MORTAR_1F_OUTSIDE` at (3,33) |
| 4 | `MOUNT_MORTAR_1F_OUTSIDE` | - | use FLASH from the PACK/party menu | `ENGINE_ZEPHYRBADGE`, map palset is `DARKNESS_PALSET` | `STATUSFLAGS_FLASH_F` set |
| 5 | `MOUNT_MORTAR_1F_OUTSIDE` | - | use MAX_REPEL | bag has one | encounters suppressed |
| 6 | `MOUNT_MORTAR_1F_OUTSIDE` | object at (13,15) | walk onto / A-press the Poke Ball | `EVENT_MOUNT_MORTAR_1F_OUTSIDE_ETHER` clear | ETHER in bag, flag set |
| 7 | `MOUNT_MORTAR_1F_OUTSIDE` | object at (31,18) | pick up Poke Ball | `EVENT_MOUNT_MORTAR_1F_OUTSIDE_REVIVE` clear | GUARD_SPEC in bag, flag set |
| 8 | `MOUNT_MORTAR_1F_OUTSIDE` | bg event (25,22) | face the tile, press A | `EVENT_MOUNT_MORTAR_1F_OUTSIDE_HIDDEN_HYPER_POTION` clear | HYPER_POTION in bag, flag set |
| 9 | `MOUNT_MORTAR_1F_OUTSIDE` | warp 5 at (11,21) | step on warp | - | on `MOUNT_MORTAR_1F_INSIDE` at (11,47) |
| 10 | `MOUNT_MORTAR_1F_INSIDE` | - | re-cast FLASH only if it was lost (it is not - cave to cave keeps the bit) | - | - |
| 11 | `MOUNT_MORTAR_1F_INSIDE` | object at (33,22) | pick up Poke Ball | `EVENT_MOUNT_MORTAR_1F_INSIDE_ESCAPE_ROPE` clear | ESCAPE_ROPE in bag |
| 12 | `MOUNT_MORTAR_1F_INSIDE` | object at (12,21) | pick up Poke Ball | `EVENT_MOUNT_MORTAR_1F_INSIDE_HYPER_POTION` clear | HYPER_POTION in bag |
| 13 | `MOUNT_MORTAR_1F_INSIDE` | boulder at (21,43) | activate STRENGTH from the party menu, then push | `ENGINE_PLAINBADGE`, party knows STRENGTH | `BIKEFLAGS_STRENGTH_ACTIVE_F` set, boulder movable |
| 14 | `MOUNT_MORTAR_1F_INSIDE` | warp 1 at (11,47) | back out | - | on `MOUNT_MORTAR_1F_OUTSIDE` at (11,21) |
| 15 | `MOUNT_MORTAR_1F_OUTSIDE` | the lake | walk into water / A-press facing water -> SURF | `ENGINE_FOGBADGE` | `wPlayerState = PLAYER_SURF` |
| 16 | `MOUNT_MORTAR_1F_OUTSIDE` | the waterfall tile | face **UP** at the waterfall, press A -> WATERFALL | `ENGINE_RISINGBADGE`, `CheckMapCanWaterfall` passes | climbed |
| 17 | `MOUNT_MORTAR_1F_OUTSIDE` | warp 4 at (17,5) | step on warp | - | on `MOUNT_MORTAR_2F_INSIDE` at (17,33) |
| 18 | `MOUNT_MORTAR_2F_INSIDE` | objects at (31,23), (2,24), (19,17), (14,5), (8,9), (28,5) | pick up all six Poke Balls | matching `EVENT_MOUNT_MORTAR_2F_INSIDE_*` clear | MAX_POTION, RARE_CANDY, TM_DEFENSE_CURL (TM40), DRAGON_SCALE, ELIXER, ESCAPE_ROPE |
| 19 | `MOUNT_MORTAR_2F_INSIDE` | bg event (19,6) | face, press A | `EVENT_MOUNT_MORTAR_2F_INSIDE_HIDDEN_FULL_RESTORE` clear | FULL_RESTORE in bag |
| 20 | `MOUNT_MORTAR_2F_INSIDE` | warp 2 at (3,5) | step on warp | - | on `MOUNT_MORTAR_1F_INSIDE` at (9,9) |
| 21 | `MOUNT_MORTAR_1F_INSIDE` | object at (16,10) | pick up Poke Ball | `EVENT_MOUNT_MORTAR_1F_INSIDE_MAX_REVIVE` clear | MAX_REVIVE in bag |
| 22 | `MOUNT_MORTAR_1F_INSIDE` | bg event (31,9) | face, press A | `EVENT_MOUNT_MORTAR_1F_INSIDE_HIDDEN_MAX_REPEL` clear | MAX_REPEL in bag |
| 23 | `MOUNT_MORTAR_1F_INSIDE` | warp 5 at (3,19) | step on warp | - | on `MOUNT_MORTAR_B1F` at (3,3) |
| 24 | `MOUNT_MORTAR_B1F` | bg (4,6), objects (4,16) and (31,17) | pick up hidden MAX_REVIVE, FULL_HEAL, HYPER_POTION | matching `EVENT_MOUNT_MORTAR_B1F_*` clear | three items |
| 25 | `MOUNT_MORTAR_B1F` | `MOUNTMORTARB1F_KIYO` at (13,4) | stand adjacent, press A | party count <= 5, `EVENT_GOT_TYROGUE_FROM_KIYO` clear | battle `BLACKBELT_T`/`KIYO` (L34 HITMONLEE, L34 HITMONCHAN) -> `EVENT_BEAT_BLACKBELT_KIYO` |
| 26 | `MOUNT_MORTAR_B1F` | Kiyo (same object, script continues) | press A through the reward text | party count <= 5 | `givepoke TYROGUE, 10`, `EVENT_GOT_TYROGUE_FROM_KIYO` set |
| 27 | `MOUNT_MORTAR_B1F` | - | use ESCAPE_ROPE (or STRENGTH the boulder at (9,10) then warp 2 at (19,29)) | ESCAPE_ROPE in bag | out of the cave |
| 28 | anywhere outdoors | `SPAWN_BLACKTHORN` | Fly to Blackthorn, heal | `ENGINE_STORMBADGE`, `ENGINE_FLYPOINT_BLACKTHORN` | at Blackthorn spawn (21,30); **`STATUSFLAGS_FLASH_F` is now cleared** |
| 29 | `BLACKTHORN_CITY` | south map connection | walk south | - | on `ROUTE_45` |
| 30 | `ROUTE_45` | warp 1 at (2,5) | step on warp | - | on `DARK_CAVE_BLACKTHORN_ENTRANCE` at (23,3) |
| 31 | `DARK_CAVE_BLACKTHORN_ENTRANCE` | - | use FLASH again | `ENGINE_ZEPHYRBADGE` | `STATUSFLAGS_FLASH_F` set |
| 32 | `DARK_CAVE_BLACKTHORN_ENTRANCE` | water in the middle of the map | SURF | `ENGINE_FOGBADGE` | crossing possible |
| 33 | `DARK_CAVE_BLACKTHORN_ENTRANCE` | `DARKCAVEBLACKTHORNENTRANCE_PHARMACIST` at (7,3) | stand adjacent, press A | `EVENT_GOT_BLACKGLASSES_IN_DARK_CAVE` clear, item pocket has room | BLACKGLASSES, flag set |
| 34 | `DARK_CAVE_BLACKTHORN_ENTRANCE` | objects at (7,22) and (21,24) | pick up both Poke Balls | matching events clear | TM_SNORE (TM13), REVIVE |
| 35 | `DARK_CAVE_BLACKTHORN_ENTRANCE` | warp 2 at (3,25) | step on warp | - | on `DARK_CAVE_VIOLET_ENTRANCE` at (17,1) |
| 36 | `DARK_CAVE_VIOLET_ENTRANCE` | water below (17,1) | SURF down | `ENGINE_FOGBADGE` | - |
| 37 | `DARK_CAVE_VIOLET_ENTRANCE` | rock at (16,14) or (7,14) | face rock, press A, answer yes | party knows ROCK_SMASH | rock gone; 40% chance of a KRABBY/SHUCKLE L15 battle |
| 38 | `DARK_CAVE_VIOLET_ENTRANCE` | object at (6,8) | pick up Poke Ball | `EVENT_DARK_CAVE_VIOLET_ENTRANCE_POTION` clear | POTION in bag |
| 39 | `DARK_CAVE_VIOLET_ENTRANCE` | warp 1 at (3,15) | step on warp | - | on `ROUTE_31` at (34,5); **FLASH bit cleared** |
| 40 | `ROUTE_31` | - | Fly back to Blackthorn, heal | - | section complete |

Optional extras this route skips, with their coordinates if a completionist bot
wants them: `DARK_CAVE_VIOLET_ENTRANCE` objects at (36,22) FULL_HEAL and (35,9)
HYPER_POTION plus the hidden ELIXER bg at (26,3) - all three sit on the
north-east lobe of the map that the earlier Route 31 section already reaches.

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map headers / dimensions for all six maps | `tools/rom_manifest_gold.json` (e.g. `MOUNT_MORTAR_1F_OUTSIDE` 20x18 group 3 map 49, `DARK_CAVE_BLACKTHORN_ENTRANCE` 15x18 group 3 map 71), read by `src/import/RomExtractorGen2.lua` | implemented (extracted from ROM, no hand-ported map file needed) |
| Warp / coord / bg / object event tables | `src/import/RomExtractorGen2.lua` (`warps`, `coordEvents`, `bgEvents`, `objects` around lines 787-862) -> `src/world/gen2/Map.lua` | implemented |
| `PALETTE_DARK` -> `DARKNESS_PALSET` and the FLASH override | `src/world/gen2/Palettes.lua`, asserted by `tests/gen2_palettes_test.lua:118-129` (`dark cave` / `dark cave with flash`) | implemented |
| `ResetFlashIfOutOfCave` (FLASH dies on ROUTE/TOWN) | `src/world/gen2/World.lua:5622-5625` | implemented |
| FLASH / SURF / WATERFALL / STRENGTH badge gates | `src/world/gen2/FieldMoves.lua:105-110` (`FLASH=ZEPHYR`, `SURF=FOG`, `STRENGTH=PLAIN`, `WATERFALL=RISING`), `FieldMoves.flashFromMenu` / `surfFromMenu` / `waterfallFromMenu` / `strengthFromMenu` | implemented |
| `CheckMapCanWaterfall` (facing UP, `wTileUp`) and the climb loop | `src/world/gen2/FieldMoves.lua:253-266`, `src/world/gen2/World.lua:4030-4046` `runWaterfall` / `waterfallStep`, `World:tryWaterfallOW` (4217) | implemented |
| Strength boulder push (`StrengthBoulderScript` -> `AskStrengthScript`) | `src/world/gen2/World.lua:5268-5274` (the boulder arm of `World:interact`), `World:tryStrengthOW`, driver `tests/drivers/gold_icepath_boulder.lua` | implemented |
| `BIKEFLAGS_STRENGTH_ACTIVE_F` cleared on map load | `src/world/gen2/World.lua:5611-5613` | implemented |
| Hidden items (`BGEVENT_ITEM` / `hiddenitem`) | `src/world/gen2/HiddenItems.lua`, wired at `src/world/gen2/World.lua:5290-5296` | implemented |
| `verbosegiveitem BLACKGLASSES` (the Dark Cave pharmacist) | `src/script/gen2/Vm.lua:490-510`, hook `World.lua:831` `giveItem` | implemented |
| `givepoke TYROGUE, 10` (Kiyo's reward) | `src/script/gen2/Vm.lua:439-445`, hook `World.lua:812` `givePoke` | implemented |
| `readvar VAR_PARTYCOUNT` (Kiyo's "no room" branch) | `src/world/gen2/World.lua:112` `VAR_PARTYCOUNT = 0x01`, read at `World.lua:1225` | implemented |
| `loadtrainer` / `startbattle` / `winlosstext` / `reloadmapafterbattle` | `src/script/gen2/Vm.lua:806`, `:817`, `:886`, `:918`; `src/world/gen2/Trainers.lua`; driver `tests/drivers/gold_trainer_smoke.lua` | implemented |
| Tyrogue's three-way stat evolution (what the reward mon becomes) | `src/core/gen2/Evolution.lua:71`, asserted by `tests/gen2_evolution_test.lua:347-357` | implemented |
| Repel / Max Repel step counter | `src/world/gen2/World.lua:3382` `World:useRepel`, `src/ui/gen2/PackMenu.lua:199-206` | implemented |
| **Picking up a Poke Ball (`OBJECTTYPE_ITEMBALL`)** | extracted into `obj.itemball` by `src/import/RomExtractorGen2.lua:2968-2969`, but `World:interact` (`src/world/gen2/World.lua:5256-5310`) has arms for trainer, boulder, `scriptKey`, `BGEVENT_READ` and `BGEVENT_ITEM` **and no itemball arm**; `CallAsm.lua:551` stubs `TryReceiveItem` out | **missing** - all 15 Poke Balls in this section are unobtainable in the port today |
| **ROCK SMASH as a field move** | `src/script/gen2/CallAsm.lua:346-350` implements `HasRockSmash`, but line 526 stubs `RockMonEncounter` with the note "ROCK SMASH has no field-move path yet; RockMonMaps is unported"; `World:interact`'s tile-event chain (`World.lua:5301-5308`) lists cut / whirlpool / waterfall / headbutt / surf and **not** rock smash, and nothing in `src/` references `SPRITEMOVEDATA_SMASHABLE_ROCK` | **missing** - the four Dark Cave Violet rocks cannot be broken, and the Krabby/Shuckle table is unreachable |
| **ESCAPE_ROPE / DIG as a field item** | `src/world/gen2/World.lua:3293-3302` `World:useFieldItem` handles ITEMFINDER, BICYCLE, SACRED_ASH, repels, trophy boxes and rods only. (Gen 1's path exists at `src/ui/BagMenu.lua:231-240`, but that is the Red/Blue engine, not the Gen 2 one.) | **missing** - the walkthrough's "use one of the Escape Ropes to get out" has no port path; the Strength-boulder exit at B1F (9,10) does work |
| Fly to Mahogany / Blackthorn | `src/world/gen2/FieldMoves.lua:394-440` `hasVisitedSpawn` / `flyPoints`, `flyFromMenu` (504) | implemented |
| Wild encounter tables (grass + water + fishing) for these maps | extracted; `src/world/gen2/FieldMoves.lua:162-177` `canEncounterWildMon` / `encounterTable` | implemented (not separately verified against these six maps) |

No driver in `tests/drivers/gold_*.lua` visits Mt. Mortar or Dark Cave.

---

## 6. Unresolved / verify by hand

1. **The walkthrough's Mt. Mortar item list is the HGSS list, not the GS list.**
   It names Carbos, Escape Rope x2, Full Restore, Hyper Potion x2, Max Ether,
   Max Potion, Max Revive, PP Up, Rare Candy, Dragon Scale and "TM40 Aerial
   Ace". What is actually in `maps/MountMortar*.asm` is: ETHER, GUARD_SPEC,
   hidden HYPER_POTION (1F Outside); ESCAPE_ROPE, MAX_REVIVE, HYPER_POTION,
   hidden MAX_REPEL (1F Inside); MAX_POTION, RARE_CANDY, TM_DEFENSE_CURL,
   DRAGON_SCALE, ELIXER, ESCAPE_ROPE, hidden FULL_RESTORE (2F Inside);
   HYPER_POTION, FULL_HEAL, hidden MAX_REVIVE (B1F). **No CARBOS, no PP_UP, no
   MAX_ETHER, no IRON anywhere in Mt. Mortar.** TM40 is the right *number* but
   the move is DEFENSE_CURL (`constants/item_constants.asm:261`); Aerial Ace is
   a Gen 3 move that does not exist in this disassembly.
2. **"grab the free Iron on the cliff" (1F Inside, after coming down from 2F).**
   There is no IRON object on any Mt. Mortar map. The nearest items to warp 6 at
   (9,9) are the MAX_REVIVE ball at (16,10) and the hidden MAX_REPEL bg event at
   (31,9). Treat "Iron" as an HGSS-only pickup.
3. **"surf clockwise around and reach a Hyper Potion and a Max Ether."** There is
   no MAX_ETHER in Mt. Mortar. If the intended floor is B1F (the ladder from the
   central entrance) the pair is HYPER_POTION (31,17) + FULL_HEAL (4,16); if 2F,
   the closest analogue is ELIXER (8,9). Which one the author meant could not be
   determined from the asm.
4. **Kiyo's prize money and EXP yields.** The walkthrough gives 816G and
   1012/1020 EXP. `data/trainers/parties.asm` only carries the class, name, type
   byte and party; the money formula lives in the battle engine's
   `data/trainers/attributes.asm` base-money table times level, which was not
   opened for this document. The party itself is verified: L34 HITMONLEE, L34
   HITMONCHAN, `TRAINERTYPE_NORMAL` (default moves, no held items).
5. **"a giant room where you can zig zag around ... and get two items, to include
   a Hyper Potion and Escape Rope."** `MOUNT_MORTAR_1F_INSIDE` actually holds
   *three* balls (ESCAPE_ROPE (33,22), MAX_REVIVE (16,10), HYPER_POTION (12,21))
   plus a hidden MAX_REPEL - but MAX_REVIVE and the hidden item sit on the
   section of the map only reachable from 2F, which is presumably why the
   walkthrough counts two.
6. **"The west entrance and east entrance lead to each other."** All three Route
   42 doors land on the same map, `MOUNT_MORTAR_1F_OUTSIDE`; the west/east link
   runs through `MOUNT_MORTAR_1F_INSIDE` via warp pairs 5/6 (at y=21) and 8/9
   (at y=13). The blk files were not decoded, so the exact walkable path between
   any two of these warps is not verified here - only the warp graph is.
7. **Dark Cave Pokemon list.** The walkthrough lists Zubat, Golbat, Geodude,
   Graveler, Magikarp and Wobbuffet - that is the `DARK_CAVE_BLACKTHORN_ENTRANCE`
   table exactly. It omits DUNSPARCE, which is slot 7 of
   `DARK_CAVE_VIOLET_ENTRANCE` and is on the map the route exits through.
8. **Dark Cave item list.** The walkthrough lists Blackglasses, Full Heal, Hyper
   Potion, Revive and TM13. The Full Heal (36,22) and Hyper Potion (35,9) are on
   `DARK_CAVE_VIOLET_ENTRANCE`'s north-east lobe, which this route does not pass
   through; the hidden ELIXER at (26,3) is not mentioned at all. The POTION at
   (6,8) is named in the prose but missing from the list.
9. **The Shuckle/Krabby rock-smash table** (`data/wild/treemon_maps.asm:46`,
   `data/wild/treemons.asm:91`) is real and reachable at
   `DARK_CAVE_VIOLET_ENTRANCE`, but the walkthrough never mentions it. Worth
   flagging to a bot author as a cheap Shuckle source.
10. **`MOUNT_MORTAR_1F_OUTSIDE` object 2 flag naming.** The item is
    `GUARD_SPEC` but the event flag is `EVENT_MOUNT_MORTAR_1F_OUTSIDE_REVIVE`
    (`constants/event_flags.asm:1053`). Verbatim from the disassembly; not a
    transcription error here, but it will look like one to anyone grepping by
    item name.
11. **Mahogany Town and Blackthorn City interiors** (Poke Center, Mart, gym) were
    not opened for this document - only their `data/maps/maps.asm` header rows
    and `data/maps/spawn_points.asm` entries. Those maps belong to neighbouring
    sections.

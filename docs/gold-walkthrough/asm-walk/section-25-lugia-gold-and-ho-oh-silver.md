# Section 25 - Lugia (Gold) and Ho-Oh (Silver)

Source: `../section-25-lugia-gold-and-ho-oh-silver.txt`
Maps covered: `ROUTE_41`, `WHIRL_ISLAND_NE`, `WHIRL_ISLAND_NW`, `WHIRL_ISLAND_SW`,
`WHIRL_ISLAND_SE`, `WHIRL_ISLAND_CAVE`, `WHIRL_ISLAND_B1F`, `WHIRL_ISLAND_B2F`,
`WHIRL_ISLAND_LUGIA_CHAMBER`, `ECRUTEAK_CITY`, `ECRUTEAK_TIN_TOWER_ENTRANCE`,
`ECRUTEAK_TIN_TOWER_BACK_ENTRANCE`, `TIN_TOWER_1F` .. `TIN_TOWER_9F`,
`TIN_TOWER_ROOF`
Badges / key milestones in this section: no badges. The milestone is catching the
*other* version mascot post-Elite-Four - `EVENT_FOUGHT_LUGIA` /
`EVENT_FOUGHT_HO_OH`, armed by the wing the Pewter City gramps hands over
(`maps/PewterCity.asm`, `PewterCityGrampsScript`).

This section is two mutually exclusive branches. The walkthrough labels them
"Whirl Islands - Gold Version" and "Tin Tower - Silver Version", and the asm
agrees: `Script_checkver` (`engine/overworld/scripting.asm:1471`) returns
`GS_VERSION` (`constants/misc_constants.asm:21-23`: 0 = Gold, 1 = Silver), so on
each mascot the `checkver / iftrue .Silver` pair picks the level. In Gold, Lugia
is **level 70** and Ho-Oh was already caught at level 40; in Silver it is the
mirror image.

---

## 1. Route order

The walkthrough opens on the Magnet Train back to Johto - that hop belongs to the
neighbouring Kanto section, and the only thing this section needs from it is that
the player already holds the version-opposite wing.

**Gold branch (Lugia, Whirl Islands)**

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `OLIVINE_CITY` | (fly target) | Fly | west connection to `ROUTE_40` (`data/maps/attributes.asm:145`) | "Fly to Olivine City" |
| 2 | `ROUTE_40` | `data/maps/attributes.asm:223` | east connection from Olivine | south connection to `ROUTE_41` (`attributes.asm:224`) | surf southwest |
| 3 | `ROUTE_41` | `maps/Route41.asm` | north connection from Route 40 | `warp_event 36, 19` (warp 2) | "surf southwest and west until you reach the northeast cave", clearing whirlpools |
| 4 | `WHIRL_ISLAND_NE` | `maps/WhirlIslandNE.asm` | warp 1 `(3, 13)` | warp 2 `(17, 3)` or warp 3 `(13, 11)` | Flash, ledges, `ULTRA_BALL` at `(11, 11)` |
| 5 | `WHIRL_ISLAND_B1F` | `maps/WhirlIslandB1F.asm` | warp 2 `(35, 3)` / warp 3 `(29, 9)` | warp 7 `(25, 21)` or warp 8 `(13, 27)` | ledge chain, `ESCAPE_ROPE` at `(19, 26)`, `CALCIUM` at `(33, 23)` |
| 6 | `WHIRL_ISLAND_CAVE` | `maps/WhirlIslandCave.asm` | B1F warp 9 `(17, 21)` -> Cave warp 1 `(7, 5)` | Cave warp 2 `(3, 13)` -> `WHIRL_ISLAND_NW` | "head out the door to breathe, but that's pointless" |
| 7 | `WHIRL_ISLAND_SW` | `maps/WhirlIslandSW.asm` | B1F warp 4 `(9, 31)` / warp 5 `(23, 31)` | warp 5 `(17, 15)` -> B2F warp 4 | `GUARD_SPEC` at `(15, 2)` |
| 8 | `WHIRL_ISLAND_B2F` | `maps/WhirlIslandB2F.asm` | warp 1 `(11, 5)` from B1F warp 7 | warp 3 `(7, 25)` | `MAX_REVIVE` `(6, 4)`, waterfall descent, "head left and through the door" |
| 9 | `WHIRL_ISLAND_LUGIA_CHAMBER` | `maps/WhirlIslandLugiaChamber.asm` | warp 1 `(9, 13)` | Escape Rope (environment is `CAVE`) | surf north to Lugia at `(9, 5)` |

**Silver branch (Ho-Oh, Tin Tower)**

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `ECRUTEAK_CITY` | `maps/EcruteakCity.asm` | Fly | warp 3 `(18, 11)` | "Go back to Ecruteak City" |
| 2 | `ECRUTEAK_TIN_TOWER_ENTRANCE` | `maps/EcruteakTinTowerEntrance.asm` | warp 1 `(4, 17)` / warp 2 `(5, 17)` | warp 3 `(5, 3)` -> warp 4 `(17, 15)`, then warp 5 `(17, 3)` | "the Bell Tower entry house. Talk to the man" |
| 3 | `ECRUTEAK_TIN_TOWER_BACK_ENTRANCE` | `maps/EcruteakTinTowerBackEntrance.asm` | warp 3 `(2, 4)` | warp 1 `(7, 4)` / warp 2 `(7, 5)` -> `ECRUTEAK_CITY` warps 4/5 `(20, 2)` `(20, 3)` | "follow up the trail to the tower itself" |
| 4 | `ECRUTEAK_CITY` (north strip) | `maps/EcruteakCity.asm` | warps 4/5 | warp 12 `(37, 7)` | walk east along the fenced strip to Tin Tower |
| 5 | `TIN_TOWER_1F` | `maps/TinTower1F.asm` | warp 1 `(9, 15)` / warp 2 `(10, 15)` | warp 3 `(10, 2)` | "another bald man will let you through" - the sage occupies the stair tile |
| 6 | `TIN_TOWER_2F` | `maps/TinTower2F.asm` | warp 2 `(10, 2)` | warp 1 `(10, 14)` | "wild Rattatas will start converging on you" |
| 7 | `TIN_TOWER_3F` | `maps/TinTower3F.asm` | warp 1 `(10, 14)` | warp 2 `(16, 2)` | `FULL_HEAL` at `(3, 14)`, jump-ledge puzzle |
| 8 | `TIN_TOWER_4F` | `maps/TinTower4F.asm` | warp 2 `(16, 2)` | warps 1 `(2, 4)`, 3 `(2, 14)`, 4 `(17, 15)` | `ULTRA_BALL`, `SUPER_POTION`, `ESCAPE_ROPE` |
| 9 | `TIN_TOWER_5F` | `maps/TinTower5F.asm` | warps 2/3/4 | warp 1 `(11, 15)` | `RARE_CANDY` at `(9, 9)` |
| 10 | `TIN_TOWER_6F` | `maps/TinTower6F.asm` | warp 2 `(11, 15)` | warp 1 `(3, 9)` | "go up and you'll get a Max Potion" (see Unresolved) |
| 11 | `TIN_TOWER_7F` | `maps/TinTower7F.asm` | warp 1 `(3, 9)` | warp 2 `(10, 15)`, plus in-floor warp pair 3/4 and warp 5 to 9F | `MAX_REVIVE` at `(16, 1)`; "go through the next two warps" |
| 12 | `TIN_TOWER_8F` | `maps/TinTower8F.asm` | warp 1 `(2, 5)` | warps 2-6 into 9F | `NUGGET`, `MAX_ELIXER`, `FULL_RESTORE` |
| 13 | `TIN_TOWER_9F` | `maps/TinTower9F.asm` | warps 1/2/3/5/6/7 from 7F+8F | warp 4 `(7, 9)` | "cross the planks down, then go up the ladder" |
| 14 | `TIN_TOWER_ROOF` | `maps/TinTowerRoof.asm` | warp 1 `(9, 13)` | back down warp 1 then Escape Rope | level-70 Ho-Oh at `(9, 5)` |

The walkthrough's closing line ("ride the Magnet Train back to Kanto and fly back
to Pewter City") hands off to the next section; nothing on that hop is resolved
here.

---

## 2. Maps

### ROUTE_41

- Script: `maps/Route41.asm`
- Blocks: `maps/Route41.blk`
- Header: `data/maps/maps.asm:443` -> `TILESET_JOHTO`, `ROUTE`, `LANDMARK_ROUTE_41`, `MUSIC_ROUTE_36`, phone `FALSE`, `PALETTE_AUTO`, `FISHGROUP_OCEAN`
- Dimensions: `constants/map_constants.asm:410` -> `map_const ROUTE_41, 25, 27` (group 22 `CIANWOOD`, map 2)
- Connections (`data/maps/attributes.asm:227-229`): north `Route40`, west `CianwoodCity`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 12 | 17 | `WHIRL_ISLAND_NW` | 1 |
| 2 | 36 | 19 | `WHIRL_ISLAND_NE` | 1 |
| 3 | 12 | 37 | `WHIRL_ISLAND_SW` | 1 |
| 4 | 36 | 45 | `WHIRL_ISLAND_SE` | 1 |

**Coord events**: none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 9 | 35 | `BGEVENT_ITEM` | `Route41HiddenMaxEther` -> `hiddenitem MAX_ETHER, EVENT_ROUTE_41_HIDDEN_MAX_ETHER` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE41_OLIVINE_RIVAL1` | `SPRITE_OLIVINE_RIVAL` | 32 | 6 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (sight 3) | `TrainerSwimmermCharlie` | -1 |
| `ROUTE41_OLIVINE_RIVAL2` | `SPRITE_OLIVINE_RIVAL` | 46 | 8 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (3) | `TrainerSwimmermGeorge` | -1 |
| `ROUTE41_OLIVINE_RIVAL3` | `SPRITE_OLIVINE_RIVAL` | 20 | 26 | `SPINCOUNTERCLOCKWISE` | `OBJECTTYPE_TRAINER` (3) | `TrainerSwimmermBerke` | -1 |
| `ROUTE41_OLIVINE_RIVAL4` | `SPRITE_OLIVINE_RIVAL` | 32 | 30 | `SPINCLOCKWISE` | `OBJECTTYPE_TRAINER` (3) | `TrainerSwimmermKirk` | -1 |
| `ROUTE41_OLIVINE_RIVAL5` | `SPRITE_OLIVINE_RIVAL` | 19 | 46 | `SPINCOUNTERCLOCKWISE` | `OBJECTTYPE_TRAINER` (3) | `TrainerSwimmermMathew` | -1 |
| `ROUTE41_SWIMMER_GIRL1` | `SPRITE_SWIMMER_GIRL` | 17 | 4 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (3) | `TrainerSwimmerfKaylee` | -1 |
| `ROUTE41_SWIMMER_GIRL2` | `SPRITE_SWIMMER_GIRL` | 23 | 19 | `STANDING_UP` | `OBJECTTYPE_TRAINER` (3) | `TrainerSwimmerfSusie` | -1 |
| `ROUTE41_SWIMMER_GIRL3` | `SPRITE_SWIMMER_GIRL` | 27 | 34 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` (3) | `TrainerSwimmerfDenise` | -1 |
| `ROUTE41_SWIMMER_GIRL4` | `SPRITE_SWIMMER_GIRL` | 44 | 28 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER` (4) | `TrainerSwimmerfKara` | -1 |
| `ROUTE41_SWIMMER_GIRL5` | `SPRITE_SWIMMER_GIRL` | 9 | 50 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` (2) | `TrainerSwimmerfWendy` | -1 |

Note the sight ranges: Kara is `4`, the widest on the route, which is why the
walkthrough uses her as the landmark for the northeast whirlpool ("the whirlpool
is just northwest of where you fought Swimmer Kara"). Her object sits at
`(44, 28)`; the trainer flag is `EVENT_BEAT_SWIMMERF_KARA`, so once beaten she is
still standing there (`event flag` on the row is `-1`, i.e. never masked) and
still walks into your path - the walkthrough's joke about swimmer stamina is
literally the object table.

**Scripts of interest**

- `TrainerSwimmerfKara` - `trainer SWIMMERF, KARA, EVENT_BEAT_SWIMMERF_KARA, ...`.
  Post-battle it only prints `SwimmerfKaraAfterBattleText` ("I heard roars from
  deep inside the ISLANDS"). No flag beyond the beat flag, no gate.

**Whirlpools**: they are *map blocks*, not events. `data/collision/field_move_blocks.asm:48-55`
gives `WhirlpoolBlockPointers` -> `TILESET_JOHTO` -> `db $07, $36, 0` (facing
block `$07`, replacement `$36`, animation type 0). A bot that wants the whirlpool
coordinates has to scan `maps/Route41.blk` for block id `$07`; the collision
value under it is `COLL_WHIRLPOOL` `$24` (`constants/collision_constants.asm:27`,
tested by `CheckWhirlpoolTile`, `home/map_objects.asm:176-183`).

**Wild encounters**

- Surfing, `data/wild/johto_water.asm:170-181`, `def_water_wildmons ROUTE_41`,
  encounter rate `6 percent`. Gold: `20 TENTACOOL`, `20 TENTACRUEL`, `20 MANTINE`.
  Silver: `20 TENTACOOL`, `20 TENTACRUEL`, `15 TENTACOOL`.
- Fishing: header fish group is `FISHGROUP_OCEAN` (`data/wild/fish.asm:13`,
  `.Ocean_Old/.Ocean_Good/.Ocean_Super`).
- The walkthrough's Max Repel advice is aimed squarely at this 6% table.

---

### WHIRL_ISLAND_NE

- Script: `maps/WhirlIslandNE.asm`
- Blocks: `maps/WhirlIslandNE.blk`
- Header: `data/maps/maps.asm:137` -> `TILESET_DARK_CAVE`, `CAVE`, `LANDMARK_WHIRL_ISLANDS`, `MUSIC_UNION_CAVE`, phone `TRUE`, `PALETTE_DARK`, `FISHGROUP_WHIRL_ISLANDS`
- Dimensions: `constants/map_constants.asm:124` -> `map_const WHIRL_ISLAND_NE, 10, 9` (group 3 `DUNGEONS`, map 59)
- Connections: none (island interior).

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 13 | `ROUTE_41` | 2 |
| 2 | 17 | 3 | `WHIRL_ISLAND_B1F` | 2 |
| 3 | 13 | 11 | `WHIRL_ISLAND_B1F` | 3 |

**Coord events**: none. **BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `WHIRLISLANDNE_POKE_BALL` | `SPRITE_POKE_BALL` | 11 | 11 | `STILL` | `OBJECTTYPE_ITEMBALL` | `WhirlIslandNEUltraBall` (`47:401e`) | `EVENT_WHIRL_ISLAND_NE_ULTRA_BALL` |

`WhirlIslandNEUltraBall` is a bare `itemball ULTRA_BALL`.

---

### WHIRL_ISLAND_NW

- Script: `maps/WhirlIslandNW.asm` - no scripts at all, warps only
- Blocks: `maps/WhirlIslandNW.blk`
- Header: `data/maps/maps.asm:136`, same row shape as NE
- Dimensions: `constants/map_constants.asm:123` -> `5, 9` (group 3, map 58)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 7 | `ROUTE_41` | 1 |
| 2 | 5 | 3 | `WHIRL_ISLAND_B1F` | 1 |
| 3 | 3 | 15 | `WHIRL_ISLAND_SW` | 4 |
| 4 | 7 | 15 | `WHIRL_ISLAND_CAVE` | 2 |

No coord events, bg events or objects.

---

### WHIRL_ISLAND_SW

- Script: `maps/WhirlIslandSW.asm`
- Blocks: `maps/WhirlIslandSW.blk`
- Header: `data/maps/maps.asm:138`
- Dimensions: `constants/map_constants.asm:125` -> `10, 9` (group 3, map 60)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 7 | `ROUTE_41` | 3 |
| 2 | 17 | 3 | `WHIRL_ISLAND_B1F` | 5 |
| 3 | 3 | 3 | `WHIRL_ISLAND_B1F` | 4 |
| 4 | 3 | 15 | `WHIRL_ISLAND_NW` | 3 |
| 5 | 17 | 15 | `WHIRL_ISLAND_B2F` | 4 |

**Coord events**: none. **BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `WHIRLISLANDSW_POKE_BALL` | `SPRITE_POKE_BALL` | 15 | 2 | `STILL` | `OBJECTTYPE_ITEMBALL` | `WhirlIslandSWGuardSpec` (`47:4044`) | `EVENT_WHIRL_ISLAND_SW_GUARD_SPEC` |

`itemball GUARD_SPEC` - the walkthrough's "Guard Specs".

**Wild encounters**: surfing, `data/wild/johto_water.asm:79-84`,
`def_water_wildmons WHIRL_ISLAND_SW`, rate `4 percent`: `20 TENTACOOL`,
`15 HORSEA`, `20 TENTACRUEL`.

---

### WHIRL_ISLAND_SE

- Script: `maps/WhirlIslandSE.asm` - warps only
- Blocks: `maps/WhirlIslandSE.blk`
- Header: `data/maps/maps.asm:140`
- Dimensions: `constants/map_constants.asm:127` -> `5, 9` (group 3, map 62)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 13 | `ROUTE_41` | 4 |
| 2 | 5 | 3 | `WHIRL_ISLAND_B1F` | 6 |

No coord events, bg events or objects. No water encounter table.

---

### WHIRL_ISLAND_CAVE

- Script: `maps/WhirlIslandCave.asm` - warps only
- Blocks: `maps/WhirlIslandCave.blk`
- Header: `data/maps/maps.asm:139`
- Dimensions: `constants/map_constants.asm:126` -> `5, 9` (group 3, map 61)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 7 | 5 | `WHIRL_ISLAND_B1F` | 9 |
| 2 | 3 | 13 | `WHIRL_ISLAND_NW` | 4 |

This is the "you can now head out the door to breathe, but that's pointless" room:
it is a pure corridor between B1F and the NW island.

---

### WHIRL_ISLAND_B1F

- Script: `maps/WhirlIslandB1F.asm` (`47:4096` `WhirlIslandB1F_MapScripts`)
- Blocks: `maps/WhirlIslandB1F.blk` (`2b:6f61 WhirlIslandB1F_Blocks`)
- Header: `data/maps/maps.asm:141`
- Dimensions: `constants/map_constants.asm:128` -> `20, 18` (group 3, map 63)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 5 | 5 | `WHIRL_ISLAND_NW` | 2 |
| 2 | 35 | 3 | `WHIRL_ISLAND_NE` | 2 |
| 3 | 29 | 9 | `WHIRL_ISLAND_NE` | 3 |
| 4 | 9 | 31 | `WHIRL_ISLAND_SW` | 3 |
| 5 | 23 | 31 | `WHIRL_ISLAND_SW` | 2 |
| 6 | 31 | 29 | `WHIRL_ISLAND_SE` | 2 |
| 7 | 25 | 21 | `WHIRL_ISLAND_B2F` | 1 |
| 8 | 13 | 27 | `WHIRL_ISLAND_B2F` | 2 |
| 9 | 17 | 21 | `WHIRL_ISLAND_CAVE` | 1 |

**Coord events**: none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 30 | 4 | `BGEVENT_ITEM` | `WhirlIslandB1FHiddenRareCandy` -> `hiddenitem RARE_CANDY, EVENT_WHIRL_ISLAND_B1F_HIDDEN_RARE_CANDY` |
| 36 | 18 | `BGEVENT_ITEM` | `WhirlIslandB1FHiddenUltraBall` -> `hiddenitem ULTRA_BALL, EVENT_WHIRL_ISLAND_B1F_HIDDEN_ULTRA_BALL` |
| 2 | 23 | `BGEVENT_ITEM` | `WhirlIslandB1FHiddenFullRestore` -> `hiddenitem FULL_RESTORE, EVENT_WHIRL_ISLAND_B1F_HIDDEN_FULL_RESTORE` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `WHIRLISLANDB1F_POKE_BALL1` | `SPRITE_POKE_BALL` | 7 | 13 | `STILL` | `OBJECTTYPE_ITEMBALL` | `WhirlIslandB1FFullRestore` | `EVENT_WHIRL_ISLAND_B1F_FULL_RESTORE` |
| `WHIRLISLANDB1F_POKE_BALL2` | `SPRITE_POKE_BALL` | 2 | 18 | `STILL` | `OBJECTTYPE_ITEMBALL` | `WhirlIslandB1FCarbos` | `EVENT_WHIRL_ISLAND_B1F_CARBOS` |
| `WHIRLISLANDB1F_POKE_BALL3` | `SPRITE_POKE_BALL` | 33 | 23 | `STILL` | `OBJECTTYPE_ITEMBALL` | `WhirlIslandB1FCalcium` | `EVENT_WHIRL_ISLAND_B1F_CALCIUM` |
| `WHIRLISLANDB1F_POKE_BALL4` | `SPRITE_POKE_BALL` | 17 | 8 | `STILL` | `OBJECTTYPE_ITEMBALL` | `WhirlIslandB1FNugget` | `EVENT_WHIRL_ISLAND_B1F_NUGGET` |
| `WHIRLISLANDB1F_POKE_BALL5` | `SPRITE_POKE_BALL` | 19 | 26 | `STILL` | `OBJECTTYPE_ITEMBALL` | `WhirlIslandB1FEscapeRope` | `EVENT_WHIRL_ISLAND_B1F_ESCAPE_ROPE` |
| `WHIRLISLANDB1F_BOULDER` | `SPRITE_BOULDER` | 23 | 26 | `SPRITEMOVEDATA_STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | `WhirlIslandB1FBoulder` (`jumpstd StrengthBoulderScript`) | -1 |

The boulder at `(23, 26)` sits two tiles east of the Escape Rope ball and is the
only Strength object in the dungeon. The walkthrough never mentions it.

**Wild encounters**: grass/cave-floor, `data/wild/johto_grass.asm:1213-1239`,
`def_grass_wildmons WHIRL_ISLAND_B1F`, rates `6 percent` for all three times of
day, and the morn/day/nite slot lists are identical:
`23 KRABBY`, `24 ZUBAT`, `25 KRABBY`, `23 SEEL`, `24 GOLBAT`, `25 SEEL`, `25 SEEL`.
No water table for B1F.

---

### WHIRL_ISLAND_B2F

- Script: `maps/WhirlIslandB2F.asm`
- Blocks: `maps/WhirlIslandB2F.blk`
- Header: `data/maps/maps.asm:142`
- Dimensions: `constants/map_constants.asm:129` -> `10, 18` (group 3, map 64)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 11 | 5 | `WHIRL_ISLAND_B1F` | 7 |
| 2 | 7 | 11 | `WHIRL_ISLAND_B1F` | 8 |
| 3 | 7 | 25 | `WHIRL_ISLAND_LUGIA_CHAMBER` | 1 |
| 4 | 13 | 31 | `WHIRL_ISLAND_SW` | 5 |

**Coord events**: none. **BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `WHIRLISLANDB2F_POKE_BALL1` | `SPRITE_POKE_BALL` | 10 | 11 | `STILL` | `OBJECTTYPE_ITEMBALL` | `WhirlIslandB2FFullRestore` | `EVENT_WHIRL_ISLAND_B2F_FULL_RESTORE` |
| `WHIRLISLANDB2F_POKE_BALL2` | `SPRITE_POKE_BALL` | 6 | 4 | `STILL` | `OBJECTTYPE_ITEMBALL` | `WhirlIslandB2FMaxRevive` | `EVENT_WHIRL_ISLAND_B2F_MAX_REVIVE` |
| `WHIRLISLANDB2F_POKE_BALL3` | `SPRITE_POKE_BALL` | 5 | 12 | `STILL` | `OBJECTTYPE_ITEMBALL` | `WhirlIslandB2FMaxElixer` | `EVENT_WHIRL_ISLAND_B2F_MAX_ELIXER` |

`(6, 4)` is the single `MAX_REVIVE` in the whole Whirl Islands (see Unresolved
for the walkthrough's "Max Revive x2").

**Wild encounters**

- Floor: `data/wild/johto_grass.asm:1241-1267`, rate `6 percent`, identical to B1F
  (`23 KRABBY / 24 ZUBAT / 25 KRABBY / 23 SEEL / 24 GOLBAT / 25 SEEL / 25 SEEL`).
- Water: `data/wild/johto_water.asm:86-91`, rate `4 percent`: `15 HORSEA`,
  `20 HORSEA`, `20 TENTACRUEL`.

The "two items on the cliff but you can't reach those" line matches the two balls
on the west shelf (`(5, 12)` Max Elixer and `(10, 11)` Full Restore are reachable
from the other side of the floor; exactly which two the FAQ means is a `.blk`
question, see Unresolved).

---

### WHIRL_ISLAND_LUGIA_CHAMBER

- Script: `maps/WhirlIslandLugiaChamber.asm` (`47:418c` callback, `47:41a0 Lugia`)
- Blocks: `maps/WhirlIslandLugiaChamber.blk` (`2b:717d`)
- Header: `data/maps/maps.asm:143` -> `TILESET_DARK_CAVE`, `CAVE`, `LANDMARK_WHIRL_ISLANDS`, `MUSIC_UNION_CAVE`, phone `TRUE`, `PALETTE_DARK`, `FISHGROUP_WHIRL_ISLANDS`
- Dimensions: `constants/map_constants.asm:130` -> `10, 9` (group 3, map 65)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 13 | `WHIRL_ISLAND_B2F` | 3 |

**Coord events**: none. **BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `WHIRLISLANDLUGIACHAMBER_LUGIA` | `SPRITE_LUGIA` | 9 | 5 | `SPRITEMOVEDATA_POKEMON` | `OBJECTTYPE_SCRIPT`, palette `PAL_NPC_BLUE` | `Lugia` | `EVENT_WHIRL_ISLAND_LUGIA_CHAMBER_LUGIA` |

**Scripts of interest**

- `WhirlIslandLugiaChamberLugiaCallback` - `callback MAPCALLBACK_OBJECTS`.
  `checkevent EVENT_FOUGHT_LUGIA / iftrue .NoAppear`, then
  `checkitem SILVER_WING / iftrue .Appear`, else `.NoAppear`. So Lugia is on the
  map **only while the SILVER_WING is in the bag and the fight has not happened**.
  The wing is a `checkitem`, not an event - selling or storing it makes Lugia
  vanish again.
- `Lugia` (`47:41a0`) - `faceplayer`, `opentext`, `writetext LugiaText`
  ("Gyaaas!"), `cry LUGIA`, `pause 15`, `closetext`,
  **`setevent EVENT_FOUGHT_LUGIA`**, `checkver`, `iftrue .Silver`.
  - Gold arm: `loadvar VAR_BATTLETYPE, BATTLETYPE_FORCEITEM`,
    `loadwildmon LUGIA, 70`, `startbattle`,
    `disappear WHIRLISLANDLUGIACHAMBER_LUGIA`, `reloadmapafterbattle`, `end`.
  - `.Silver`: identical but `loadwildmon LUGIA, 40`.
  - `EVENT_FOUGHT_LUGIA` is set **before** the battle, so fleeing, fainting or
    knocking it out all consume the encounter. This is exactly why the
    walkthrough insists on saving first: there is no re-arm path in the asm.
  - `BATTLETYPE_FORCEITEM` (`constants/battle_constants.asm:101`) makes
    `InitEnemyMon`'s `.WildItem` arm hand over `wBaseItem1` unconditionally
    (`engine/battle/core.asm:5765-5773`). Lugia's `data/pokemon/base_stats/lugia.asm`
    row is `db NO_ITEM, NO_ITEM`, so it holds nothing - the forced-item type is
    inherited boilerplate here.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_FOUGHT_LUGIA` | `constants/event_flags.asm:455` | read by the callback, set by `Lugia` before `startbattle` | one-shot. Once set, Lugia never reappears |
| `EVENT_WHIRL_ISLAND_LUGIA_CHAMBER_LUGIA` | `constants/event_flags.asm:1247` | the object row's mask flag, driven by `appear`/`disappear` | object visibility only |
| `EVENT_GOT_SILVER_WING` | `constants/event_flags.asm:130` | set by `PewterCityGrampsScript` (Gold) / `RadioTower5F` (Silver) | prerequisite for holding `SILVER_WING` |

**Wild encounters**

- Floor: `data/wild/johto_grass.asm:1269-1295`, rate `6 percent`:
  `24 KRABBY`, `25 ZUBAT`, `26 KRABBY`, `24 SEEL`, `25 GOLBAT`, `26 SEEL`, `26 SEEL`.
- Water: `data/wild/johto_water.asm:93-98`, rate `4 percent`: `20 HORSEA`,
  `20 TENTACRUEL`, `20 SEADRA`. This is the only Seadra slot in the dungeon, and
  it is on the water directly in front of Lugia.

**Catch math** (`data/pokemon/base_stats/lugia.asm`): `db 3 ; catch rate`.
`UltraBallMultiplier` doubles it to 6; `HeavyBallMultiplier`
(`engine/items/item_effects.asm:752`) adds a flat offset by dex weight, and
Lugia's dex weight is `4760` tenths of a pound = 216 kg
(`data/pokemon/dex_entries/gold/lugia.asm`), which lands in the `+20` bracket ->
effective 23. Thard_Verad's tip in the FAQ is correct and is worth ~4x the Ultra
Ball rate.

---

### ECRUTEAK_CITY (transit only)

- Script: `maps/EcruteakCity.asm`
- Header: `data/maps/maps.asm:173` -> `TILESET_JOHTO`, `TOWN`, `LANDMARK_ECRUTEAK_CITY`, `MUSIC_ECRUTEAK_CITY`, phone `FALSE`, `PALETTE_AUTO`, `FISHGROUP_POND`
- Dimensions: `constants/map_constants.asm:159` -> `20, 18` (group 4, map 9)

**Warps** (only the rows this section uses)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 3 | 18 | 11 | `ECRUTEAK_TIN_TOWER_ENTRANCE` | 1 |
| 4 | 20 | 2 | `ECRUTEAK_TIN_TOWER_BACK_ENTRANCE` | 1 |
| 5 | 20 | 3 | `ECRUTEAK_TIN_TOWER_BACK_ENTRANCE` | 2 |
| 12 | 37 | 7 | `TIN_TOWER_1F` | 1 |
| 13 | 5 | 5 | `BURNED_TOWER_1F` | 1 |

There is a `bg_event 38, 10, BGEVENT_READ, TinTowerSign` next to the tower door.

---

### ECRUTEAK_TIN_TOWER_ENTRANCE

- Script: `maps/EcruteakTinTowerEntrance.asm`
- Blocks: `maps/EcruteakTinTowerEntrance.blk`
- Header: `data/maps/maps.asm:165` -> `TILESET_TOWER`, `INDOOR`, `LANDMARK_ECRUTEAK_CITY`, `MUSIC_ECRUTEAK_CITY`, phone `FALSE`, `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:151` -> `10, 9` (group 4, map 1)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 17 | `ECRUTEAK_CITY` | 3 |
| 2 | 5 | 17 | `ECRUTEAK_CITY` | 3 |
| 3 | 5 | 3 | `ECRUTEAK_TIN_TOWER_ENTRANCE` | 4 |
| 4 | 17 | 15 | `ECRUTEAK_TIN_TOWER_ENTRANCE` | 3 |
| 5 | 17 | 3 | `ECRUTEAK_TIN_TOWER_BACK_ENTRANCE` | 3 |

Warps 3 and 4 are a self-referential pair: the map holds two disconnected
corridors and the "walk up the stairs" is a same-map teleport from `(5, 3)` to
`(17, 15)`.

**Coord events**

| scene | x | y | script label | effect |
|---|---|---|---|---|
| `SCENE_ECRUTEAKTINTOWERENTRANCE_SAGE_BLOCKS` (0) | 4 | 7 | `EcruteakTinTowerEntranceSageBlocksLeft` (`52:400c`) | sage 2 side-steps LEFT, sage 1 is `moveobject`d to `(4, 6)` and `appear`ed, sage 2 `disappear`s |
| `SCENE_ECRUTEAKTINTOWERENTRANCE_SAGE_BLOCKS` (0) | 5 | 7 | `EcruteakTinTowerEntranceSageBlocksRight` (`52:4021`) | mirror image, sage 2 ends at `(5, 6)` |

Scene ids come from the `scene_script` macro's inline `const` block
(`macros/scripts/maps.asm:12-33`): `SAGE_BLOCKS` = 0, `NOOP` = 1. Both scene
bodies are `end`; the scene id exists only to arm/disarm the two coord events.

**BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ECRUTEAKTINTOWERENTRANCE_SAGE1` | `SPRITE_SAGE` | 4 | 6 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `EcruteakTinTowerEntranceSageScript` (`52:4037`) | `EVENT_ECRUTEAK_TIN_TOWER_ENTRANCE_SAGE_LEFT` |
| `ECRUTEAKTINTOWERENTRANCE_SAGE2` | `SPRITE_SAGE` | 5 | 6 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `EcruteakTinTowerEntranceSageScript` | `EVENT_ECRUTEAK_TIN_TOWER_ENTRANCE_SAGE_RIGHT` |
| `ECRUTEAKTINTOWERENTRANCE_SAGE3` | `SPRITE_SAGE` | 6 | 9 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `EcruteakTinTowerEntranceWanderingSageScript` (`52:404b`) | -1 |
| `ECRUTEAKTINTOWERENTRANCE_GRAMPS` | `SPRITE_GRAMPS` | 3 | 11 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `EcruteakTinTowerEntranceGrampsScript` | -1 |

Object rows are masked when their flag is **set** (`CheckObjectFlag`,
`engine/overworld/map_objects_2.asm:32-61`: `EventFlagAction`/`CHECK_FLAG`
non-zero -> `.masked`). `InitializeEventsScript`
(`engine/events/std_scripts.asm:438`, line 533) does
`setevent EVENT_ECRUTEAK_TIN_TOWER_ENTRANCE_SAGE_LEFT` at new game, so on a fresh
save only SAGE2 at `(5, 6)` is standing there.

**Scripts of interest**

- `EcruteakTinTowerEntranceSageScript` - `faceplayer`, `opentext`,
  `checkflag ENGINE_FOGBADGE`, `iftrue .BlockPassage_GotFogBadge`. Both arms are
  pure text (`EcruteakTinTowerEntranceSageText` vs `..._GotFogBadge`); **the
  script never opens the path**.
- The actual unblock is `maps/EcruteakGym.asm:34`:
  `setmapscene ECRUTEAK_TIN_TOWER_ENTRANCE, SCENE_ECRUTEAKTINTOWERENTRANCE_NOOP`,
  run in the same block as `setflag ENGINE_FOGBADGE` after beating Morty. With
  the scene at `NOOP` the two coord events no longer match and the sage never
  steps into the doorway. By section 25 the player has all 16 badges, so this is
  already open - the walkthrough's "talk to the man and he'll let you through" is
  flavour text, not a required action.
- `EcruteakTinTowerEntranceWanderingSageScript` - `checkevent EVENT_GOT_RAINBOW_WING`;
  the post-wing line is "The TIN TOWER shook! A #MON must have returned to the
  top!". This is the only in-map confirmation that Ho-Oh is now spawnable.

---

### ECRUTEAK_TIN_TOWER_BACK_ENTRANCE

- Script: `maps/EcruteakTinTowerBackEntrance.asm` - warps only, no scripts
- Blocks: `maps/EcruteakTinTowerBackEntrance.blk`
- Header: `data/maps/maps.asm:166` -> `TILESET_TRADITIONAL_HOUSE`, `INDOOR`, `LANDMARK_ECRUTEAK_CITY`, `MUSIC_ECRUTEAK_CITY`, phone `FALSE`, `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:152` -> `4, 4` (group 4, map 2)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 7 | 4 | `ECRUTEAK_CITY` | 4 |
| 2 | 7 | 5 | `ECRUTEAK_CITY` | 5 |
| 3 | 2 | 4 | `ECRUTEAK_TIN_TOWER_ENTRANCE` | 5 |

---

### TIN_TOWER_1F

- Script: `maps/TinTower1F.asm` (`42:4b1d TinTowerSageScript`)
- Blocks: `maps/TinTower1F.blk`
- Header: `data/maps/maps.asm:82` -> `TILESET_TOWER`, `DUNGEON`, `LANDMARK_TIN_TOWER`, `MUSIC_TIN_TOWER`, phone `FALSE`, `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:69` -> `10, 9` (group 3, map 4)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 15 | `ECRUTEAK_CITY` | 12 |
| 2 | 10 | 15 | `ECRUTEAK_CITY` | 12 |
| 3 | 10 | 2 | `TIN_TOWER_2F` | 2 |

**Coord events**: none. **BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TINTOWER1F_SAGE` | `SPRITE_SAGE` | 10 | 2 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `TinTowerSageScript` | `EVENT_TEAM_ROCKET_DISBANDED` |

**This is the real gate for the whole Silver branch.** The sage's coordinates are
`(10, 2)`, byte-for-byte the coordinates of warp 3. While the object is visible
the stair tile is occupied and 2F is unreachable. The object is masked - i.e. the
sage disappears - when `EVENT_TEAM_ROCKET_DISBANDED`
(`constants/event_flags.asm:1283`) is **set**, and that flag is only ever set by
the two Rainbow Wing hand-offs:

- `maps/RadioTower5F.asm:124-130` (Gold): `verbosegiveitem RAINBOW_WING` (124),
  `setevent EVENT_GOT_RAINBOW_WING` (129), `setevent EVENT_TEAM_ROCKET_DISBANDED` (130).
- `maps/PewterCity.asm:42-51` `.RainbowWing` (Silver): the gramps gives
  `RAINBOW_WING` (49), `setevent EVENT_GOT_RAINBOW_WING` (50),
  `setevent EVENT_TEAM_ROCKET_DISBANDED` (51).

So the walkthrough's "another bald man will let you through because you have the
beautiful Rainbow Wing" is literally true, but the mechanism is a masked object
keyed on `EVENT_TEAM_ROCKET_DISBANDED`, not a `checkitem RAINBOW_WING`.

**Wild encounters**: none - `TIN_TOWER_1F` has no `def_grass_wildmons` row
(`data/wild/johto_grass.asm` starts the tower at `TIN_TOWER_2F`, line 61).

---

### TIN_TOWER_2F

- Script: `maps/TinTower2F.asm` - warps only
- Blocks: `maps/TinTower2F.blk`
- Header: `data/maps/maps.asm:83`; Dimensions `constants/map_constants.asm:70` -> `10, 9` (group 3, map 5)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 10 | 14 | `TIN_TOWER_3F` | 1 |
| 2 | 10 | 2 | `TIN_TOWER_1F` | 3 |

**Wild encounters**: `data/wild/johto_grass.asm:61-87`,
`def_grass_wildmons TIN_TOWER_2F`, rates `2 percent` morn/day/nite.

- morn/day: `20 RATTATA`, `21 RATTATA`, `22 RATTATA`, `22 RATTATA`, `23 RATTATA`, `24 RATTATA`, `24 RATTATA`
- nite: `20 GASTLY`, `21 GASTLY`, `22 GASTLY`, `22 RATTATA`, `23 RATTATA`, `24 RATTATA`, `24 RATTATA`

Every floor 2F..9F carries the identical table (checked 2F at line 61 and 9F at
line 257). The walkthrough only lists Rattata; Gastly at night is real.

---

### TIN_TOWER_3F

- Script: `maps/TinTower3F.asm`; Blocks `maps/TinTower3F.blk`
- Header: `data/maps/maps.asm:84`; Dimensions `constants/map_constants.asm:71` -> `10, 9` (group 3, map 6)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 10 | 14 | `TIN_TOWER_2F` | 1 |
| 2 | 16 | 2 | `TIN_TOWER_4F` | 2 |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TINTOWER3F_POKE_BALL` | `SPRITE_POKE_BALL` | 3 | 14 | `STILL` | `OBJECTTYPE_ITEMBALL` | `TinTower3FFullHeal` | `EVENT_TIN_TOWER_3F_FULL_HEAL` |

Matches the walkthrough's "hop left for a Full Heal".

---

### TIN_TOWER_4F

- Script: `maps/TinTower4F.asm`; Blocks `maps/TinTower4F.blk`
- Header: `data/maps/maps.asm:85`; Dimensions `constants/map_constants.asm:72` -> `10, 9` (group 3, map 7)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 4 | `TIN_TOWER_5F` | 2 |
| 2 | 16 | 2 | `TIN_TOWER_3F` | 2 |
| 3 | 2 | 14 | `TIN_TOWER_5F` | 3 |
| 4 | 17 | 15 | `TIN_TOWER_5F` | 4 |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 11 | 6 | `BGEVENT_ITEM` | `TinTower4FHiddenMaxPotion` -> `hiddenitem MAX_POTION, EVENT_TIN_TOWER_4F_HIDDEN_MAX_POTION` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TINTOWER4F_POKE_BALL1` | `SPRITE_POKE_BALL` | 14 | 10 | `STILL` | `OBJECTTYPE_ITEMBALL` | `TinTower4FUltraBall` (`42:4cc1`) | `EVENT_TIN_TOWER_4F_ULTRA_BALL` |
| `TINTOWER4F_POKE_BALL2` | `SPRITE_POKE_BALL` | 17 | 14 | `STILL` | `OBJECTTYPE_ITEMBALL` | `TinTower4FSuperPotion` | `EVENT_TIN_TOWER_4F_SUPER_POTION` |
| `TINTOWER4F_POKE_BALL3` | `SPRITE_POKE_BALL` | 2 | 12 | `STILL` | `OBJECTTYPE_ITEMBALL` | `TinTower4FEscapeRope` | `EVENT_TIN_TOWER_4F_ESCAPE_ROPE` |

---

### TIN_TOWER_5F

- Script: `maps/TinTower5F.asm`; Blocks `maps/TinTower5F.blk`
- Header: `data/maps/maps.asm:86`; Dimensions `constants/map_constants.asm:73` -> `10, 9` (group 3, map 8)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 11 | 15 | `TIN_TOWER_6F` | 2 |
| 2 | 2 | 4 | `TIN_TOWER_4F` | 1 |
| 3 | 2 | 14 | `TIN_TOWER_4F` | 3 |
| 4 | 17 | 15 | `TIN_TOWER_4F` | 4 |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 16 | 14 | `BGEVENT_ITEM` | `TinTower5FHiddenFullRestore` -> `hiddenitem FULL_RESTORE, EVENT_TIN_TOWER_5F_HIDDEN_FULL_RESTORE` |
| 3 | 15 | `BGEVENT_ITEM` | `TinTower5FHiddenCarbos` -> `hiddenitem CARBOS, EVENT_TIN_TOWER_5F_HIDDEN_CARBOS` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TINTOWER5F_POKE_BALL` | `SPRITE_POKE_BALL` | 9 | 9 | `STILL` | `OBJECTTYPE_ITEMBALL` | `TinTower5FRareCandy` (`42:4d12`) | `EVENT_TIN_TOWER_5F_RARE_CANDY` |

---

### TIN_TOWER_6F

- Script: `maps/TinTower6F.asm` - warps only, no items, no objects
- Blocks: `maps/TinTower6F.blk`
- Header: `data/maps/maps.asm:87`; Dimensions `constants/map_constants.asm:74` -> `10, 9` (group 3, map 9)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 9 | `TIN_TOWER_7F` | 1 |
| 2 | 11 | 15 | `TIN_TOWER_5F` | 1 |

The walkthrough's "go up and you'll get a Max Potion ... left across the upper
bridge to get a Full Heal" floor has **no item balls and no bg events at all** in
pokegold. See Unresolved.

---

### TIN_TOWER_7F

- Script: `maps/TinTower7F.asm`; Blocks `maps/TinTower7F.blk`
- Header: `data/maps/maps.asm:88`; Dimensions `constants/map_constants.asm:75` -> `10, 9` (group 3, map 10)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 9 | `TIN_TOWER_6F` | 1 |
| 2 | 10 | 15 | `TIN_TOWER_8F` | 1 |
| 3 | 12 | 7 | `TIN_TOWER_7F` | 4 |
| 4 | 8 | 3 | `TIN_TOWER_7F` | 3 |
| 5 | 6 | 9 | `TIN_TOWER_9F` | 5 |

Warps 3/4 are the in-floor pair the walkthrough calls "go through the next two
warps".

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TINTOWER7F_POKE_BALL` | `SPRITE_POKE_BALL` | 16 | 1 | `STILL` | `OBJECTTYPE_ITEMBALL` | `TinTower7FMaxRevive` | `EVENT_TIN_TOWER_7F_MAX_REVIVE` |

---

### TIN_TOWER_8F

- Script: `maps/TinTower8F.asm`; Blocks `maps/TinTower8F.blk`
- Header: `data/maps/maps.asm:89`; Dimensions `constants/map_constants.asm:76` -> `10, 9` (group 3, map 11)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 5 | `TIN_TOWER_7F` | 2 |
| 2 | 2 | 11 | `TIN_TOWER_9F` | 1 |
| 3 | 16 | 7 | `TIN_TOWER_9F` | 2 |
| 4 | 10 | 3 | `TIN_TOWER_9F` | 3 |
| 5 | 14 | 15 | `TIN_TOWER_9F` | 6 |
| 6 | 6 | 9 | `TIN_TOWER_9F` | 7 |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TINTOWER8F_POKE_BALL1` | `SPRITE_POKE_BALL` | 7 | 13 | `STILL` | `OBJECTTYPE_ITEMBALL` | `TinTower8FNugget` | `EVENT_TIN_TOWER_8F_NUGGET` |
| `TINTOWER8F_POKE_BALL2` | `SPRITE_POKE_BALL` | 11 | 6 | `STILL` | `OBJECTTYPE_ITEMBALL` | `TinTower8FMaxElixer` | `EVENT_TIN_TOWER_8F_MAX_ELIXER` |
| `TINTOWER8F_POKE_BALL3` | `SPRITE_POKE_BALL` | 3 | 1 | `STILL` | `OBJECTTYPE_ITEMBALL` | `TinTower8FFullRestore` | `EVENT_TIN_TOWER_8F_FULL_RESTORE` |

---

### TIN_TOWER_9F

- Script: `maps/TinTower9F.asm` (`42:4de0 TinTower9F_MapScripts`) - no callbacks,
  no objects; carries two unreferenced texts `TinTower9FUnusedHoOhText` /
  `TinTower9FUnusedLugiaText`
- Blocks: `maps/TinTower9F.blk` (`2b:625f`)
- Header: `data/maps/maps.asm:90`; Dimensions `constants/map_constants.asm:77` -> `10, 9` (group 3, map 12)

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 12 | 3 | `TIN_TOWER_8F` | 2 |
| 2 | 2 | 5 | `TIN_TOWER_8F` | 3 |
| 3 | 12 | 7 | `TIN_TOWER_8F` | 4 |
| 4 | 7 | 9 | `TIN_TOWER_ROOF` | 1 |
| 5 | 16 | 7 | `TIN_TOWER_7F` | 5 |
| 6 | 6 | 13 | `TIN_TOWER_8F` | 5 |
| 7 | 8 | 13 | `TIN_TOWER_8F` | 6 |

Warp 4 at `(7, 9)` is the only exit to the roof.

---

### TIN_TOWER_ROOF

- Script: `maps/TinTowerRoof.asm` (`5b:68ff` callback, `5b:6913 TinTowerHoOh`)
- Blocks: `maps/TinTowerRoof.blk` (`2b:62b9`)
- Header: `data/maps/maps.asm:344` -> `TILESET_TOWER`, **`ROUTE`**, `LANDMARK_TIN_TOWER`, `MUSIC_TIN_TOWER`, phone `FALSE`, `PALETTE_AUTO`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:318` -> `10, 9`, and note the group:
  `TIN_TOWER_ROOF` is map 12 of **group 15 (`FAST_SHIP`)**, not group 3 with the
  rest of the tower.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 13 | `TIN_TOWER_9F` | 4 |

**Coord events**: none. **BG events**: none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `TINTOWERROOF_HO_OH` | `SPRITE_HO_OH` | 9 | 5 | `SPRITEMOVEDATA_POKEMON` | `OBJECTTYPE_SCRIPT`, palette `PAL_NPC_RED` | `TinTowerHoOh` | `EVENT_TIN_TOWER_ROOF_HO_OH` |

**Scripts of interest**

- `TinTowerRoofHoOhCallback` - `callback MAPCALLBACK_OBJECTS`:
  `checkevent EVENT_FOUGHT_HO_OH / iftrue .NoAppear`, then
  `checkitem RAINBOW_WING / iftrue .Appear`. Same shape as Lugia's: the wing must
  be **in the bag**, not merely once-received.
- `TinTowerHoOh` (`5b:6913`) - text "Shaoooh!", `cry HO_OH`, `pause 15`,
  `setevent EVENT_FOUGHT_HO_OH` **before** the fight, `checkver / iftrue .Silver`.
  - Gold arm: `loadwildmon HO_OH, 40`.
  - `.Silver`: `loadwildmon HO_OH, 70` - the level the walkthrough quotes.
  - Both arms run `loadvar VAR_BATTLETYPE, BATTLETYPE_FORCEITEM` first, and
    Ho-Oh's base row is `db SACRED_ASH, SACRED_ASH`
    (`data/pokemon/base_stats/ho_oh.asm:9`), so **Ho-Oh always holds a SACRED_ASH**.
    That is a guaranteed item a bot should strip before/after the catch.

**Escape Rope caveat**: `EscapeRopeFunction` -> `.CheckCanDig`
(`engine/events/overworld.asm:724-754`) only succeeds when
`GetMapEnvironment` is `CAVE` or `DUNGEON`. `TIN_TOWER_ROOF` is `ROUTE`, so the
walkthrough is right that you must go back down to 9F first. Every Whirl Island
map including `WHIRL_ISLAND_LUGIA_CHAMBER` is `CAVE`, so the rope works on the
spot there.

**Catch math**: Ho-Oh's catch rate is also `3`
(`data/pokemon/base_stats/ho_oh.asm:7`). Its dex weight is `4390`
(`data/pokemon/dex_entries/gold/ho_oh.asm`) = 199 kg, which falls in the
`HeavyBallMultiplier` "add 0" bracket - so unlike Lugia, a Heavy Ball is *worse*
than an Ultra Ball on Ho-Oh.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Reaching Route 41 at all | `SurfFunction.TrySurf`, `engine/events/overworld.asm:322` (badge test at `:340`) | `ENGINE_FOGBADGE` + a party member that knows `SURF` | Fog Badge (Morty) |
| Whirlpools guarding the Whirl Islands | `WhirlpoolFunction` `engine/events/overworld.asm:1061` (badge test at `:1077`) and `TryWhirlpoolOW` `:1167` (badge test at `:1171`) | `ENGINE_GLACIERBADGE` + `WHIRLPOOL` in the party | Glacier Badge (Pryce, badge 7) - **not** eight badges, see Unresolved |
| Darkness inside every Whirl Island map | `FlashFunction.CheckUseFlash`, `engine/events/overworld.asm:271` | `ENGINE_ZEPHYRBADGE` + `FLASH`, and `wTimeOfDayPalset == DARKNESS_PALSET` (the map header's `PALETTE_DARK`) | Zephyr Badge. Flash is *refused* on any non-dark map, so a bot must only try it inside |
| Climbing back up the B2F waterfall | `WaterfallFunction` `engine/events/overworld.asm:611` (badge test at `:618`) and `TryWaterfallOW` `:683` (badge test at `:687`); direction check `CheckMapCanWaterfall` (must face UP, `wTileUp` is a waterfall tile) | `ENGINE_RISINGBADGE` + `WATERFALL` | Rising Badge (Clair). Descending needs nothing - only the UP direction is gated |
| B1F boulder at `(23, 26)` | `WhirlIslandB1FBoulder` -> `jumpstd StrengthBoulderScript` | `STRENGTH` + `ENGINE_PLAINBADGE` | optional; not on the Lugia path |
| Lugia not on the map | `WhirlIslandLugiaChamberLugiaCallback` | `checkitem SILVER_WING` true **and** `EVENT_FOUGHT_LUGIA` clear | `EVENT_GOT_SILVER_WING` via `PewterCityGrampsScript` (Gold) or `RadioTower5F` (Silver) - and keep the wing in the bag |
| Ho-Oh not on the map | `TinTowerRoofHoOhCallback` | `checkitem RAINBOW_WING` true **and** `EVENT_FOUGHT_HO_OH` clear | `EVENT_GOT_RAINBOW_WING` via `RadioTower5F` (Gold) or `PewterCityGrampsScript` `.RainbowWing` (Silver) |
| Tin Tower stairs to 2F | `TinTower1F` object row: sage stands on `(10, 2)`, masked by `EVENT_TEAM_ROCKET_DISBANDED` | flag must be **set** | `setevent EVENT_TEAM_ROCKET_DISBANDED` in `maps/RadioTower5F.asm:130` or `maps/PewterCity.asm:51` |
| Tin Tower entrance corridor | `coord_event 4, 7` / `5, 7` under `SCENE_ECRUTEAKTINTOWERENTRANCE_SAGE_BLOCKS` | scene must be `NOOP` | `maps/EcruteakGym.asm:34` `setmapscene ... SCENE_ECRUTEAKTINTOWERENTRANCE_NOOP` on the Fog Badge |
| One-shot mascot | `Lugia` / `TinTowerHoOh` set `EVENT_FOUGHT_LUGIA` / `EVENT_FOUGHT_HO_OH` **before** `startbattle` | n/a | none. Save-before-fight is the only recovery |

---

## 4. Bot checklist

**Preconditions for either branch**: 8 Johto badges (Zephyr, Fog, Plain, Glacier,
Rising in particular), party moves `SURF`, `WHIRLPOOL`, `FLASH`, `WATERFALL`
(`STRENGTH` optional), the version-opposite wing in the bag, a stack of
`ULTRA_BALL` (`HEAVY_BALL` for Lugia), and a save immediately before the mascot.

**Gold branch - Lugia**

| # | Map | Target | Intent | Precondition | Postcondition |
|---|---|---|---|---|---|
| 1 | any | Olivine City | fly | `ENGINE_FLYPOINT_OLIVINE` | on `OLIVINE_CITY` |
| 2 | `OLIVINE_CITY` | west edge | walk, then surf | `ENGINE_FOGBADGE` + `SURF` | on `ROUTE_40` |
| 3 | `ROUTE_40` | south edge | surf | - | on `ROUTE_41` |
| 4 | `ROUTE_41` | any block id `$07` (`TILESET_JOHTO` whirlpool) | face it, press A -> `TryWhirlpoolOW` | `ENGINE_GLACIERBADGE` + `WHIRLPOOL` | block replaced with `$36` for this map session only (`DisappearWhirlpool` writes the map buffer, not the save) |
| 5 | `ROUTE_41` | `(36, 19)` warp 2 | walk onto | whirlpools cleared | on `WHIRL_ISLAND_NE` at `(3, 13)` |
| 6 | `WHIRL_ISLAND_NE` | menu | use `FLASH` | `ENGINE_ZEPHYRBADGE`, map palette `PALETTE_DARK` | cave lit |
| 7 | `WHIRL_ISLAND_NE` | object `WHIRLISLANDNE_POKE_BALL` `(11, 11)` | walk onto / A | `EVENT_WHIRL_ISLAND_NE_ULTRA_BALL` clear | `ULTRA_BALL` in bag, flag set |
| 8 | `WHIRL_ISLAND_NE` | warp 2 `(17, 3)` (or warp 3 `(13, 11)`) | walk onto | - | `WHIRL_ISLAND_B1F` `(35, 3)` / `(29, 9)` |
| 9 | `WHIRL_ISLAND_B1F` | `(19, 26)` | pick up | `EVENT_WHIRL_ISLAND_B1F_ESCAPE_ROPE` clear | `ESCAPE_ROPE` in bag |
| 10 | `WHIRL_ISLAND_B1F` | `(33, 23)` | pick up | `EVENT_WHIRL_ISLAND_B1F_CALCIUM` clear | `CALCIUM` in bag |
| 11 | `WHIRL_ISLAND_B1F` | optional `(30, 4)`, `(36, 18)`, `(2, 23)` | face + A (hidden) | matching `EVENT_..._HIDDEN_*` clear | Rare Candy / Ultra Ball / Full Restore |
| 12 | `WHIRL_ISLAND_B1F` | warp 4 `(9, 31)` or warp 5 `(23, 31)` | walk onto | - | `WHIRL_ISLAND_SW` |
| 13 | `WHIRL_ISLAND_SW` | `(15, 2)` | pick up | `EVENT_WHIRL_ISLAND_SW_GUARD_SPEC` clear | `GUARD_SPEC` in bag |
| 14 | `WHIRL_ISLAND_B1F` | warp 7 `(25, 21)` | walk onto | - | `WHIRL_ISLAND_B2F` `(11, 5)` |
| 15 | `WHIRL_ISLAND_B2F` | `(6, 4)` | pick up | `EVENT_WHIRL_ISLAND_B2F_MAX_REVIVE` clear | `MAX_REVIVE` in bag |
| 16 | `WHIRL_ISLAND_B2F` | waterfall block, moving DOWN | surf south over it | `SURF` only (no badge for descent) | lower B2F pool |
| 17 | `WHIRL_ISLAND_B2F` | warp 3 `(7, 25)` | walk onto | - | `WHIRL_ISLAND_LUGIA_CHAMBER` `(9, 13)` |
| 18 | `WHIRL_ISLAND_LUGIA_CHAMBER` | - | **SAVE** | - | recoverable |
| 19 | `WHIRL_ISLAND_LUGIA_CHAMBER` | object at `(9, 5)` | surf north, A | `SILVER_WING` in bag, `EVENT_FOUGHT_LUGIA` clear | `EVENT_FOUGHT_LUGIA` set, wild Lugia Lv70 (Gold) / Lv40 (Silver) |
| 20 | battle | - | weaken, status, throw balls | catch rate 3 (Ultra 6, Heavy 23) | Lugia caught, `disappear` + `reloadmapafterbattle` |
| 21 | `WHIRL_ISLAND_LUGIA_CHAMBER` | bag | use `ESCAPE_ROPE` | environment `CAVE` | back at last Pokecenter spawn |

**Silver branch - Ho-Oh**

| # | Map | Target | Intent | Precondition | Postcondition |
|---|---|---|---|---|---|
| 1 | any | Ecruteak City | fly | `ENGINE_FLYPOINT_ECRUTEAK` | on `ECRUTEAK_CITY` |
| 2 | `ECRUTEAK_CITY` | warp 3 `(18, 11)` | walk onto | - | `ECRUTEAK_TIN_TOWER_ENTRANCE` `(4, 17)` |
| 3 | `ECRUTEAK_TIN_TOWER_ENTRANCE` | `(4, 7)` / `(5, 7)` | walk through | map scene must be `NOOP` (Fog Badge) | no coord event fires |
| 4 | `ECRUTEAK_TIN_TOWER_ENTRANCE` | warp 3 `(5, 3)` | walk onto | - | same map, `(17, 15)` |
| 5 | `ECRUTEAK_TIN_TOWER_ENTRANCE` | warp 5 `(17, 3)` | walk onto | - | `ECRUTEAK_TIN_TOWER_BACK_ENTRANCE` `(2, 4)` |
| 6 | `ECRUTEAK_TIN_TOWER_BACK_ENTRANCE` | warp 1 `(7, 4)` | walk onto | - | `ECRUTEAK_CITY` `(20, 2)` |
| 7 | `ECRUTEAK_CITY` | warp 12 `(37, 7)` | walk east then onto | - | `TIN_TOWER_1F` `(9, 15)` |
| 8 | `TIN_TOWER_1F` | warp 3 `(10, 2)` | walk onto | `EVENT_TEAM_ROCKET_DISBANDED` **set** (sage masked) | `TIN_TOWER_2F` `(10, 2)` |
| 9 | `TIN_TOWER_2F` | warp 1 `(10, 14)` | walk onto | - | `TIN_TOWER_3F` |
| 10 | `TIN_TOWER_3F` | `(3, 14)` then warp 2 `(16, 2)` | pick up, walk onto | `EVENT_TIN_TOWER_3F_FULL_HEAL` clear | `FULL_HEAL`; `TIN_TOWER_4F` |
| 11 | `TIN_TOWER_4F` | `(14, 10)`, `(17, 14)`, `(2, 12)`, hidden `(11, 6)` | pick up | matching flags clear | Ultra Ball, Super Potion, Escape Rope, hidden Max Potion |
| 12 | `TIN_TOWER_4F` | warp 1 `(2, 4)` / 3 `(2, 14)` / 4 `(17, 15)` | walk onto | - | `TIN_TOWER_5F` |
| 13 | `TIN_TOWER_5F` | `(9, 9)`, hidden `(16, 14)` and `(3, 15)` | pick up | matching flags clear | Rare Candy, Full Restore, Carbos |
| 14 | `TIN_TOWER_5F` | warp 1 `(11, 15)` | walk onto | - | `TIN_TOWER_6F` `(11, 15)` |
| 15 | `TIN_TOWER_6F` | warp 1 `(3, 9)` | walk onto | - | `TIN_TOWER_7F` `(3, 9)` |
| 16 | `TIN_TOWER_7F` | `(16, 1)`; warps 3 `(12, 7)` / 4 `(8, 3)` | pick up, hop the pair | `EVENT_TIN_TOWER_7F_MAX_REVIVE` clear | `MAX_REVIVE` |
| 17 | `TIN_TOWER_7F` | warp 2 `(10, 15)` | walk onto | - | `TIN_TOWER_8F` `(2, 5)` |
| 18 | `TIN_TOWER_8F` | `(7, 13)`, `(11, 6)`, `(3, 1)` | pick up | matching flags clear | Nugget, Max Elixer, Full Restore |
| 19 | `TIN_TOWER_8F` | warp 2 `(2, 11)` (or 3/4/5/6) | walk onto | - | `TIN_TOWER_9F` |
| 20 | `TIN_TOWER_9F` | warp 4 `(7, 9)` | walk onto | - | `TIN_TOWER_ROOF` `(9, 13)` |
| 21 | `TIN_TOWER_ROOF` | - | **SAVE** | - | recoverable |
| 22 | `TIN_TOWER_ROOF` | object at `(9, 5)` | walk up, A | `RAINBOW_WING` in bag, `EVENT_FOUGHT_HO_OH` clear | `EVENT_FOUGHT_HO_OH` set, wild Ho-Oh Lv70 (Silver) / Lv40 (Gold) holding `SACRED_ASH` |
| 23 | battle | - | weaken, status, Ultra Balls | catch rate 3; Heavy Ball gives no bonus here | Ho-Oh caught |
| 24 | `TIN_TOWER_9F` | warp 1 on the roof, then bag | descend, use `ESCAPE_ROPE` | roof is `ROUTE` environment - rope fails there | back at spawn |

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map headers, warps, coord/bg/object events for all of these maps | `src/import/RomExtractorGen2.lua` (walks all 26 map groups, `MAP_GROUP_COUNT` at line 47), consumed by `src/world/gen2/Map.lua` / `World.lua` | implemented (generic - no map-specific code, so these maps come in with everything else) |
| `MAPCALLBACK_OBJECTS` (the Lugia / Ho-Oh appear-check) | `src/world/gen2/World.lua:5700` `runMapCallback("MAPCALLBACK_OBJECTS")`; regression driver `tests/drivers/gold_map_callbacks.lua` | implemented |
| Object masking by event flag (`CheckObjectFlag`) - the Tin Tower 1F sage, every item ball | `src/world/gen2/World.lua:5106,5122` `events:objectVisible(obj.eventFlag)` | implemented |
| `checkver` version split (Lv70 vs Lv40 mascot) | `src/script/gen2/Vm.lua:774-783`; opcode table `src/script/gen2/Opcodes.lua:29` | implemented (comments even cite `WhirlIslandLugiaChamber` by name) |
| `loadwildmon` / `startbattle` / `reloadmapafterbattle` | `src/script/gen2/Opcodes.lua:98-101`, `src/script/gen2/Vm.lua:817-896` | implemented |
| `BATTLETYPE_FORCEITEM` -> Ho-Oh's guaranteed `SACRED_ASH` | `src/world/gen2/World.lua:107-111` and `:4571-4579` | implemented |
| Whirlpool field move, badge gate and block replacement | `src/world/gen2/FieldMoves.lua:109` (`WHIRLPOOL = "GLACIER"`), `:219` `WHIRLPOOL_BLOCKS`, `:247` `somethingToWhirlpool`, `:542` `whirlpoolFromMenu`, `:626` `tryWhirlpoolOW` | implemented |
| Flash + `PALETTE_DARK` darkness | `src/world/gen2/FieldMoves.lua:105,468`; `src/world/gen2/Palettes.lua:53,75-103` | implemented |
| Waterfall (up-only gate, `RISINGBADGE`) | `src/world/gen2/FieldMoves.lua:110,258,646` | implemented |
| Hidden items (`hiddenitem` bg events) | `src/world/gen2/HiddenItems.lua`, `src/world/gen2/World.lua:1373,5286` | implemented |
| Catch rate formula incl. the two cart bugs | `src/battle/gen2/Catching.lua:1-90` | implemented |
| **Heavy Ball weight bonus** (the FAQ's Lugia tip) | `src/battle/gen2/Catching.lua:36` - `HEAVY_BALL = 1`, a flat multiplier with a comment saying the specialty balls "key off conditions the caller supplies", and no dex-weight lookup anywhere | **missing** - a Heavy Ball currently behaves as a plain Poke Ball on Lugia |
| Magnet Train hop that opens the section | `src/core/gen2/MagnetTrain.lua` | implemented (not re-verified for this section) |
| Escape Rope environment check (`CAVE`/`DUNGEON` only, roof excluded) | not located in `src/world/gen2/` or `src/battle/gen2/` by grep | **unverified** - could not find an `EscapeRopeFunction` equivalent; a bot should not assume the roof refusal is modelled |
| Hand-ported scripts for these specific maps | none - grep for `whirl`/`tintower`/`lugia`/`hooh` across `src/` returns only battle-anim and title-screen hits | not applicable (all script bodies are extracted, run through `src/script/gen2/Vm.lua`) |

---

## 6. Unresolved / verify by hand

1. **"You'll need eight badges in order to use Whirlpool."** The asm gates
   Whirlpool on `ENGINE_GLACIERBADGE` alone (`engine/events/overworld.asm:1077`
   and `:1171`), i.e. seven badges. Eight is wrong, though harmless in practice
   for a post-game section.
2. **Whirl Islands item list.** The FAQ lists Calcium, Escape Rope, Guard Specs,
   Max Revive x2, Ultra Ball. The asm has *one* Max Revive in the entire dungeon
   (`WhirlIslandB2FMaxRevive` at B2F `(6, 4)`) and additionally a `FULL_RESTORE`,
   `CARBOS`, `NUGGET` on B1F, a second `FULL_RESTORE` and a `MAX_ELIXER` on B2F,
   plus three hidden items on B1F that the FAQ never mentions. The walkthrough's
   two "grab the Max Revive" beats cannot both be the B2F ball; the first one is
   unlocatable.
3. **Tin Tower item list.** The FAQ names a PP Up, an HP Up, a Max Potion item
   ball, and a second Full Heal. None exist in pokegold: there is no `PP_UP` or
   `HP_UP` anywhere in `maps/TinTower*.asm`, the only Max Potion is the *hidden*
   `TinTower4FHiddenMaxPotion` at `(11, 6)`, and the only Full Heal is
   `TinTower3FFullHeal`. Conversely the FAQ omits `SUPER_POTION` (4F),
   `NUGGET`/`FULL_RESTORE` (8F) and the three hidden items on 4F/5F. The list
   looks like it was written against a different version of the game.
4. **"On the next level, go up and you'll get a Max Potion ... Full Heal"** places
   two items on the 6F-shaped floor; `maps/TinTower6F.asm` has an empty
   `def_bg_events` and an empty `def_object_events`. Not locatable.
5. **Ho-Oh's moveset.** The FAQ says "Safeguard and Ancient Power ..., Punishment,
   and Sacred Fire". `PUNISHMENT` does not exist in Gen 2 at all
   (`data/pokemon/evos_attacks.asm:3324-3336` is the whole learnset). Derived
   from that table plus `FillMoves` (`engine/pokemon/evolve.asm:478`, which keeps
   the last four moves learnable at or below the level), a level-70 Ho-Oh should
   have `RECOVER`, `FIRE_BLAST`, `SUNNY_DAY`, `SWIFT`, and a level-40 one
   `SACRED_FIRE`, `SAFEGUARD`, `GUST`, `RECOVER`. Worth confirming in-engine
   before a bot plans around Sacred Fire; the `FillMoves` derivation is mine, not
   a literal table in the asm.
6. **Lugia's Pokemon list at the Whirl Islands.** The FAQ lists Zubat, Seel,
   Krabby, Horsea, Seadra and omits `GOLBAT` (in every grass slot 5),
   `TENTACOOL` / `TENTACRUEL` (SW and B2F water). Seadra only appears in
   `WHIRL_ISLAND_LUGIA_CHAMBER`'s water table.
7. **"Swimmer Kara" as a whirlpool landmark.** Her object is at `(44, 28)` on
   Route 41; the whirlpool "just northwest" of her is a `.blk` block, not an
   event, so the exact coordinate could not be pinned from the asm text. A bot
   must scan `maps/Route41.blk` for `TILESET_JOHTO` block `$07`.
8. **The Whirl Islands ledge/jump routing** ("leap the ledge to the right on that
   bike", "two items on the cliff but you can't reach those") is entirely block
   and collision data in `maps/WhirlIsland*.blk`. None of it is expressible from
   the event tables; a bot needs the decoded block/collision grid.
9. **The Tin Tower jump-platform routing** (the long "left x5, down, right x2 ..."
   sequences) is likewise `.blk` data. Only the warp endpoints above are asm
   facts.
10. **"go into the Bell Tower entry house"** - the map, the sign and every text
    string in pokegold call it TIN TOWER (`TinTowerSign`,
    `EcruteakTinTowerEntranceSageText`). "Bell Tower" is the post-GS rename.
11. **Escape Rope on the port.** Could not find the port's equivalent of
    `EscapeRopeFunction`'s `CAVE`/`DUNGEON` environment check, so I cannot say
    whether the port correctly refuses the rope on `TIN_TOWER_ROOF`.

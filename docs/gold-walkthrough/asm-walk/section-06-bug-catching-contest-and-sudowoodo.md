# Section 06 - Bug Catching Contest and Sudowoodo

Source: `../section-06-bug-catching-contest-and-sudowoodo.txt`
Maps covered: `MAP_GOLDENROD_FLOWER_SHOP`, `MAP_ROUTE_35_GOLDENROD_GATE`, `MAP_ROUTE_35`,
`MAP_ROUTE_35_NATIONAL_PARK_GATE`, `MAP_NATIONAL_PARK`, `MAP_NATIONAL_PARK_BUG_CONTEST`,
`MAP_ROUTE_36_NATIONAL_PARK_GATE`, `MAP_ROUTE_36`, `MAP_ROUTE_37` (listed by the
walkthrough header, never entered by its route)

Badges / key milestones in this section:

- SQUIRTBOTTLE (key item) - gated behind `ENGINE_PLAINBADGE`, i.e. Whitney must already
  be beaten before this section can be started at all.
- Bug-Catching Contest run (Tue/Thu/Sat only) - SUN STONE / EVERSTONE / GOLD BERRY / BERRY.
- `EVENT_FOUGHT_SUDOWOODO` - the single event that unblocks Route 36 west<->east, which
  is the only land route between Goldenrod and Violet through Route 36.
- TM08 ROCK SMASH (`EVENT_GOT_TM08_ROCK_SMASH`), TM04 ROLLOUT, TM28 DIG, QUICK CLAW.
- No badge is earned in this section.

Everything in this file was transcribed from files that were opened; nothing is
reconstructed from memory. Symbol addresses are `bank:addr` from
`pokegold-symbols/pokegold.sym`.

---

## 1. Route order

The walkthrough's own prose is out of order in one place: it opens by collecting the
SQUIRTBOTTLE in Goldenrod, then much later describes Floria running off to fetch it.
In pokegold the SQUIRTBOTTLE has no Route 36 precondition at all (see
"Unresolved / verify by hand"), so the opening order is the one a bot should follow.

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `MAP_GOLDENROD_FLOWER_SHOP` | `maps/GoldenrodFlowerShop.asm` | `GOLDENROD_CITY` warp 6 @ (33, 5) | warp 1/2 @ (2,7)/(3,7) -> `GOLDENROD_CITY` 6 | Talk to the teacher for the SQUIRTBOTTLE |
| 2 | `MAP_ROUTE_35_GOLDENROD_GATE` | `maps/Route35GoldenrodGate.asm` | `GOLDENROD_CITY` warp 13 @ (19, 1) -> gate warp 3 | warp 1/2 @ (4,0)/(5,0) -> `ROUTE_35` 1/2 | Randy hands over Kenya the SPEAROW with FLOWER MAIL |
| 3 | `MAP_ROUTE_35` | `maps/Route35.asm` | gate warp @ (9,33)/(10,33) | warp 3 @ (3, 5) -> `ROUTE_35_NATIONAL_PARK_GATE` 3 | Six trainers + Officer Dirk, walk north |
| 4 | `MAP_ROUTE_35_NATIONAL_PARK_GATE` | `maps/Route35NationalParkGate.asm` | warp 3/4 @ (3,7)/(4,7) | warp 1/2 @ (3,0)/(4,0) -> `NATIONAL_PARK` 3/4 | Contest officer; optional entry to the Contest |
| 5 | `MAP_NATIONAL_PARK_BUG_CONTEST` | `maps/NationalParkBugContest.asm` | script `warp NATIONAL_PARK_BUG_CONTEST, 10, 47` from the south gate (or `33, 18` from the north gate) | contest timer / balls exhausted, or either gate | Optional Tue/Thu/Sat Contest |
| 6 | `MAP_NATIONAL_PARK` | `maps/NationalPark.asm` | warp 3/4 @ (10,47)/(11,47) | warp 1/2 @ (33,18)/(33,19) -> `ROUTE_36_NATIONAL_PARK_GATE` 1/2 | QUICK CLAW, Beverly, Jack, Krise, William, TM28 DIG |
| 7 | `MAP_ROUTE_36_NATIONAL_PARK_GATE` | `maps/Route36NationalParkGate.asm` | warp 1/2 @ (0,4)/(0,5) | warp 3/4 @ (9,4)/(9,5) -> `ROUTE_36` 1/2 | Contest results / prize holding |
| 8 | `MAP_ROUTE_36` | `maps/Route36.asm` | warp 1/2 @ (18,8)/(18,9) | south connection @ y=17 -> `ROUTE_35`; later east connection -> `VIOLET_CITY` | Ice Berry, Psychic Mark, Schoolboy Alan, Sudowoodo, TM08 |
| 9 | `MAP_ROUTE_35` (again) | `maps/Route35.asm` | north connection from `ROUTE_36` (offset 0) | back north to `ROUTE_36` | Cut the tree, Bug Catcher Arnie, Bird Keeper Bryan, TM04 ROLLOUT |
| 10 | `MAP_ROUTE_36` (again) | `maps/Route36.asm` | north connection from `ROUTE_35` | **east connection -> `VIOLET_CITY`** | Sudowoodo cleared, then east into Violet City |

Spills into the next section: step 10's east connection
(`connection east, VioletCity, VIOLET_CITY, 0` in `data/maps/attributes.asm`) drops the
player into `MAP_VIOLET_CITY`, which belongs to a neighbouring section. Route 37
(`MAP_ROUTE_37`, north connection off Route 36 with offset 10) is named in this section's
header but the walkthrough never routes into it; its data is recorded below for
completeness because the item list ("Blk/Blu/Red Apricorn", "Ice Berry") mixes 36 and 37.

---

## 2. Maps

### MAP_GOLDENROD_FLOWER_SHOP

- Script: `maps/GoldenrodFlowerShop.asm`
- Blocks: `maps/GoldenrodFlowerShop.blk`
- Header (`data/maps/maps.asm:275`): `TILESET_HOUSE, INDOOR, LANDMARK_GOLDENROD_CITY, MUSIC_GOLDENROD_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:253` -> `map_const GOLDENROD_FLOWER_SHOP, 4, 4`
- Connections: none (indoor)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `GOLDENROD_CITY` | 6 |
| 2 | 3 | 7 | `GOLDENROD_CITY` | 6 |

**Coord events** (`def_coord_events`) - none.

**BG events** (`def_bg_events`) - none. (`FlowerShopShelf1`, `FlowerShopShelf2`,
`FlowerShopRadio` exist in the file but are marked `; unreferenced`.)

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `GOLDENRODFLOWERSHOP_TEACHER` | `SPRITE_TEACHER` | 2 | 4 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `FlowerShopTeacherScript` | -1 |
| `GOLDENRODFLOWERSHOP_FLORIA` | `SPRITE_LASS` | 5 | 6 | `SPRITEMOVEDATA_WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `FlowerShopFloriaScript` | -1 |

**Scripts of interest**

- `FlowerShopTeacherScript` (`57:52d1`) - `checkevent EVENT_GOT_SQUIRTBOTTLE` /
  `iftrue .Lalala`; then `checkflag ENGINE_PLAINBADGE` / `iffalse .Lalala`. Only with the
  badge and without the event does it `faceplayer` / `opentext` /
  `writetext GoldenrodFlowerShopTeacherBetterThanWhitneyText` / `promptbutton` /
  `verbosegiveitem SQUIRTBOTTLE` / `setevent EVENT_GOT_SQUIRTBOTTLE`. **Note the bug in
  the cart**: there is no `iffalse` after `verbosegiveitem`, so a full PACK still sets
  `EVENT_GOT_SQUIRTBOTTLE` and the item is lost. A bot must have a free KEY ITEM slot.
- `FlowerShopFloriaScript` (`57:52f4`) - pure flavour, branches on `ENGINE_PLAINBADGE`.
  Gives nothing.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_GOT_SQUIRTBOTTLE` | `constants/event_flags.asm:101` | read+written by `FlowerShopTeacherScript` | one-shot; set even on a full bag |
| `ENGINE_PLAINBADGE` | `constants/engine_flags.asm:40` | read by `FlowerShopTeacherScript`, `FlowerShopFloriaScript` | Whitney's badge is the hard precondition for the whole section |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `SQUIRTBOTTLE` | talk to teacher at (2,4) | `FlowerShopTeacherScript` `verbosegiveitem` | `EVENT_GOT_SQUIRTBOTTLE` |

**Trainers** - none.

**Wild encounters** - none (indoor).

---

### MAP_ROUTE_35_GOLDENROD_GATE

- Script: `maps/Route35GoldenrodGate.asm`
- Blocks: no `.blk` in `maps/` for this map (gate maps of this group share generated
  attributes; `data/maps/attributes.asm:542` carries `map_attributes Route35GoldenrodGate, ROUTE_35_GOLDENROD_GATE, $00`)
- Header (`data/maps/maps.asm:260`): `TILESET_GATE, GATE, LANDMARK_ROUTE_35, MUSIC_ROUTE_36, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:239` -> `map_const ROUTE_35_GOLDENROD_GATE, 5, 4`
- Connections: none. `GATE` environment is why the walkthrough's "ride your bike through"
  works.

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 0 | `ROUTE_35` | 1 |
| 2 | 5 | 0 | `ROUTE_35` | 2 |
| 3 | 4 | 7 | `GOLDENROD_CITY` | 13 |
| 4 | 5 | 7 | `GOLDENROD_CITY` | 13 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE35GOLDENRODGATE_RANDY` | `SPRITE_OFFICER` | 0 | 4 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `RandyScript` | -1 |
| `ROUTE35GOLDENRODGATE_POKEFAN_F` | `SPRITE_POKEFAN_F` | 6 | 4 | `SPRITEMOVEDATA_WALK_UP_DOWN` (0,1) | `OBJECTTYPE_SCRIPT` | `Route35GoldenrodGatePokefanFScript` | -1 |

**Scripts of interest**

- `RandyScript` (`56:59ce`) - four-way branch, checked in this order:
  `EVENT_GOT_HP_UP_FROM_RANDY` -> `.gothpup`; `EVENT_GAVE_KENYA` -> `.questcomplete`
  (`verbosegiveitem HP_UP`, `setevent EVENT_GOT_HP_UP_FROM_RANDY`);
  `EVENT_GOT_KENYA` -> `.alreadyhavekenya`; otherwise the offer. On YES it prints thanks,
  then `readvar VAR_PARTYCOUNT` / `ifequal PARTY_LENGTH, .partyfull`. Only with a free
  slot does it run `givepoke SPEAROW, 10, NO_ITEM, GiftSpearowName, GiftSpearowOTName`,
  `givepokemail GiftSpearowMail`, `setevent EVENT_GOT_KENYA`.
  - `GiftSpearowMail` = `FLOWER_MAIL`, text `"DARK CAVE leads / to another road"`.
  - `GiftSpearowName` = `KENYA`, `GiftSpearowOTName` = `RANDY`.
  - The delivery target (`EVENT_GAVE_KENYA`) is on Route 31, i.e. a later section.
- `Route35GoldenrodGatePokefanFScript` - flavour, branches on `EVENT_FOUGHT_SUDOWOODO`;
  its pre-Sudowoodo text is the in-game hint that the SQUIRTBOTTLE is what wakes the tree.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_GOT_KENYA` | `constants/event_flags.asm:89` | `RandyScript` | Spearow accepted |
| `EVENT_GAVE_KENYA` | `constants/event_flags.asm:90` | read here, set on Route 31 | enables the HP UP reward |
| `EVENT_GOT_HP_UP_FROM_RANDY` | `constants/event_flags.asm:91` | `RandyScript` | reward taken |
| `EVENT_FOUGHT_SUDOWOODO` | `constants/event_flags.asm:51` | read here | flavour only on this map |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| SPEAROW "KENYA" (lv 10) + `FLOWER_MAIL` | say YES to Randy with a party slot free | `RandyScript` `givepoke` / `givepokemail` | `EVENT_GOT_KENYA` |
| `HP_UP` | return after delivering to Route 31 | `RandyScript` `.questcomplete` | `EVENT_GOT_HP_UP_FROM_RANDY` |

**Trainers** - none. **Wild encounters** - none.

---

### MAP_ROUTE_35

- Script: `maps/Route35.asm`
- Blocks: `maps/Route35.blk` (180 bytes = 10 x 18 blocks)
- Header (`data/maps/maps.asm:248`): `TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_35, MUSIC_ROUTE_36, FALSE, PALETTE_AUTO, FISHGROUP_POND`
- Dimensions: `constants/map_constants.asm:227` -> `map_const ROUTE_35, 10, 18` (so cell
  coordinates run 0..19 in x and 0..35 in y)
- Connections (`data/maps/attributes.asm:202`): north `ROUTE_36` offset 0, south
  `GOLDENROD_CITY` offset -5

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 33 | `ROUTE_35_GOLDENROD_GATE` | 1 |
| 2 | 10 | 33 | `ROUTE_35_GOLDENROD_GATE` | 2 |
| 3 | 3 | 5 | `ROUTE_35_NATIONAL_PARK_GATE` | 3 |

**Coord events** - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 1 | 7 | `BGEVENT_READ` | `Route35Sign` |
| 11 | 31 | `BGEVENT_READ` | `Route35Sign` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE35_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 3 | 19 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER` sight 4 | `TrainerCamperIvan` | -1 |
| `ROUTE35_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 8 | 20 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` sight 3 | `TrainerCamperElliot` | -1 |
| `ROUTE35_LASS1` | `SPRITE_LASS` | 7 | 20 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` sight 3 | `TrainerPicnickerBrooke` | -1 |
| `ROUTE35_LASS2` | `SPRITE_LASS` | 11 | 24 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` sight 3 | `TrainerPicnickerKim` | -1 |
| `ROUTE35_YOUNGSTER3` | `SPRITE_YOUNGSTER` | 14 | 28 | `STANDING_DOWN` | `OBJECTTYPE_TRAINER` sight 0 | `TrainerBirdKeeperBryan` | -1 |
| `ROUTE35_FISHER` | `SPRITE_FISHER` | 2 | 10 | `SPINCOUNTERCLOCKWISE` | `OBJECTTYPE_TRAINER` sight 2 | `TrainerFirebreatherWalt` | -1 |
| `ROUTE35_BUG_CATCHER` | `SPRITE_BUG_CATCHER` | 16 | 7 | `STANDING_DOWN` (radius 2,0) | `OBJECTTYPE_TRAINER` sight 3 | `TrainerBugCatcherArnie` | -1 |
| `ROUTE35_SUPER_NERD` | `SPRITE_SUPER_NERD` | 5 | 10 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` sight 2 | `TrainerJugglerIrwin` | -1 |
| `ROUTE35_OFFICER` | `SPRITE_OFFICER` | 5 | 6 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `TrainerOfficerDirk` | -1 |
| `ROUTE35_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 2 | 25 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route35FruitTree` (`4b:5c07`) | -1 |
| `ROUTE35_POKE_BALL` | `SPRITE_POKE_BALL` | 13 | 16 | `STILL` | `OBJECTTYPE_ITEMBALL` | `Route35TMRollout` (`4b:5c05`) | `EVENT_ROUTE_35_TM_ROLLOUT` |

**Scripts of interest**

- `TrainerOfficerDirk` - **not** an `OBJECTTYPE_TRAINER` object. It is a plain script that
  runs `checktime NITE` / `iffalse .NotNight` first, so Dirk only battles at night. Then
  `checkevent EVENT_BEAT_OFFICER_DIRK`, `playmusic MUSIC_OFFICER_ENCOUNTER`,
  `winlosstext OfficerDirkBeatenText, 0`, `loadtrainer OFFICER, DIRK`, `startbattle`,
  `reloadmapafterbattle`, `setevent EVENT_BEAT_OFFICER_DIRK`. A daytime bot will get
  `OfficerDirkPrettyToughText` and no battle.
- `TrainerJugglerIrwin` / `TrainerBugCatcherArnie` - standard phone trainers. After the
  win, `checkcellnum PHONE_JUGGLER_IRWIN` / `PHONE_BUG_CATCHER_ARNIE`, then
  `setevent EVENT_IRWIN_ASKED_FOR_PHONE_NUMBER` / `EVENT_ARNIE_ASKED_FOR_PHONE_NUMBER`
  and `askforphonenumber`. The walkthrough's "head back to Arnie and talk to her for her
  phone number" is this second talk.
  Rematch tiers: Irwin uses `EVENT_CLEARED_RADIO_TOWER` -> `IRWIN3`,
  `ENGINE_FLYPOINT_CIANWOOD` -> `IRWIN2`, else `IRWIN1`. Arnie uses
  `ENGINE_FLYPOINT_BLACKTHORN` -> `ARNIE3`, `ENGINE_FLYPOINT_LAKE_OF_RAGE` -> `ARNIE2`,
  else `ARNIE1`.
- `Route35TMRollout` -> `itemball TM_ROLLOUT`. `Route35FruitTree` -> `fruittree FRUITTREE_ROUTE_35`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_PICNICKER_KIM` / `_CAMPER_ELLIOT` / `_PICNICKER_BROOKE` / `_CAMPER_IVAN` / `_JUGGLER_IRWIN` / `_FIREBREATHER_WALT` / `_BUG_CATCHER_ARNIE` / `_BIRD_KEEPER_BRYAN` | `constants/event_flags.asm` | `trainer` macro rows | per-trainer defeated bits |
| `EVENT_BEAT_OFFICER_DIRK` | `constants/event_flags.asm` | `TrainerOfficerDirk` | set by hand, not by the `trainer` macro |
| `EVENT_ROUTE_35_TM_ROLLOUT` | `constants/event_flags.asm:1107` | item ball object | TM04 taken |
| `EVENT_IRWIN_ASKED_FOR_PHONE_NUMBER`, `EVENT_IRWIN_READY_FOR_REMATCH` | `constants/event_flags.asm` | Irwin script | phone state machine |
| `EVENT_ARNIE_ASKED_FOR_PHONE_NUMBER`, `EVENT_ARNIE_READY_FOR_REMATCH` | `constants/event_flags.asm` | Arnie script | phone state machine |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `TM_ROLLOUT` (TM04, `constants/item_constants.asm:223`) | item ball at cell (13, 16) | `Route35TMRollout` | `EVENT_ROUTE_35_TM_ROLLOUT` |
| `MYSTERYBERRY` | fruit tree object at (2, 25) | `FRUITTREE_ROUTE_35` -> `data/items/fruit_trees.asm:14` | daily reset (`Apricorns`/`TryResetFruitTrees` equivalent) |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `KIM` | `PICNICKER` (0x35) | 4 | `parties.asm:2601` `KIM` - lv15 VULPIX | `TrainerPicnickerKim` | no |
| `ELLIOT` | `CAMPER` (0x36) | 4 | `parties.asm:2722` `ELLIOT` - lv13 SANDSHREW, lv15 MARILL | `TrainerCamperElliot` | no |
| `BROOKE` | `PICNICKER` (0x35) | 3 | `parties.asm:2596` `BROOKE` `TRAINERTYPE_MOVES` - lv16 PIKACHU (THUNDERSHOCK, GROWL, QUICK_ATTACK, DOUBLE_TEAM) | `TrainerPicnickerBrooke` | no |
| `IVAN` | `CAMPER` (0x36) | 3 | `parties.asm:2715` `IVAN` - lv10 DIGLETT, lv10 ZUBAT, lv14 DIGLETT | `TrainerCamperIvan` | no |
| `IRWIN1` | `JUGGLER` (0x31) | 1 | `parties.asm:2384` `IRWIN` - lv2/6/10/14 VOLTORB | `TrainerJugglerIrwin` | yes (`PHONE_JUGGLER_IRWIN`); IRWIN2 `parties.asm:2407`, IRWIN3 `parties.asm:2415` |
| `WALT` | `FIREBREATHER` (0x30) | 6 | `parties.asm:2365` `WALT` - lv11 MAGMAR, lv13 MAGMAR | `TrainerFirebreatherWalt` | no |
| `DIRK` | `OFFICER` (0x41) | 2 | `parties.asm:3172` `DIRK` - lv14 GROWLITHE, lv14 GROWLITHE | `TrainerOfficerDirk` | night only |
| `ARNIE1` | `BUG_CATCHER` (0x24) | 8 | `parties.asm:1455` `ARNIE` - lv15 VENONAT | `TrainerBugCatcherArnie` | yes (`PHONE_BUG_CATCHER_ARNIE`); ARNIE2 `parties.asm:1487`, ARNIE3 `parties.asm:1492` (lv28 VENOMOTH w/ moves) |
| `BRYAN` | `BIRD_KEEPER` (0x18) | 3 | `parties.asm:534` `BRYAN` - lv12 PIDGEY, lv14 PIDGEOTTO | `TrainerBirdKeeperBryan` | no |

**Wild encounters** - `data/wild/johto_grass.asm`, `def_grass_wildmons ROUTE_35`,
rates 10/10/10 percent (morn/day/nite). Gold table:

| slot | morn | day | nite |
|---|---|---|---|
| 1 | 12 NIDORAN_M | 12 NIDORAN_M | 12 NIDORAN_M |
| 2 | 12 NIDORAN_F | 12 NIDORAN_F | 12 NIDORAN_F |
| 3 | 14 DROWZEE | 14 DROWZEE | 14 DROWZEE |
| 4 | 10 ABRA | 10 ABRA | 10 ABRA |
| 5 | 14 PIDGEY | 14 PIDGEY | 14 HOOTHOOT |
| 6 | 10 DITTO | 10 DITTO | 10 DITTO |
| 7 | 12 YANMA | 12 YANMA | 12 YANMA |

(Silver swaps slots 1/2 to NIDORAN_F/NIDORAN_M.)

Water (`data/wild/johto_water.asm:156` `def_water_wildmons ROUTE_35`): 4 percent -
20 PSYDUCK, 15 PSYDUCK, 20 GOLDUCK. Fishing group is `FISHGROUP_POND`
(`data/wild/fish.asm:15`). Headbutt: `data/wild/treemon_maps.asm:16` ->
`TREEMON_SET_FOREST` (`data/wild/treemons.asm:34`; Gold common CATERPIE/METAPOD/
EXEGGCUTE/BUTTERFREE, rare adds PINECO). Swarm: `data/wild/swarm_grass.asm:6` is the
YANMA swarm table for `ROUTE_35`.

**Cut tree** - `maps/Route35.blk` has exactly one cuttable block: block id `$5b` at block
(8, 3), i.e. walk cells x 16-17, y 6-7. `data/collision/field_move_blocks.asm:14` gives
`db $5b, $3c, 0` for `TILESET_JOHTO`. That is the tree the walkthrough tells the player to
cut, and Bug Catcher Arnie at (16, 7) sits immediately behind it. Route 36, Route 37 and
National Park have **no** cuttable blocks (National Park's `.park` entry in
`field_move_blocks.asm` is only the two grass ids `$13` and `$03`).

---

### MAP_ROUTE_35_NATIONAL_PARK_GATE

- Script: `maps/Route35NationalParkGate.asm`
- Blocks: `maps/Route35NationalParkGate.blk`
- Header (`data/maps/maps.asm:261`): `TILESET_GATE, INDOOR, LANDMARK_ROUTE_35, MUSIC_GOLDENROD_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:240` -> `map_const ROUTE_35_NATIONAL_PARK_GATE, 4, 4`
- Connections: none

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 0 | `NATIONAL_PARK` | 3 |
| 2 | 4 | 0 | `NATIONAL_PARK` | 4 |
| 3 | 3 | 7 | `ROUTE_35` | 3 |
| 4 | 4 | 7 | `ROUTE_35` | 3 |

**Coord events** - none. The map instead uses scene scripts:

| scene id | value | script | effect |
|---|---|---|---|
| `SCENE_ROUTE35NATIONALPARKGATE_NOOP` | 0 | `Route35NationalParkGateNoop1Scene` | `end` |
| `SCENE_ROUTE35NATIONALPARKGATE_UNUSED` | 1 | `Route35NationalParkGateNoop2Scene` | `end` |
| `SCENE_ROUTE35NATIONALPARKGATE_LEAVE_CONTEST_EARLY` | 2 | `Route35NationalParkGateLeaveContestEarlyScene` | `sdefer Route35NationalParkGateLeavingContestEarlyScript` |

(The `SCENE_*` names are generated by the `scene_script` macro,
`macros/scripts/maps.asm:25`, in the order they appear in this file - there is no
separate constants file for them.)

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 5 | 0 | `BGEVENT_READ` | `BugCatchingContestExplanationSign` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE35NATIONALPARKGATE_OFFICER1` | `SPRITE_OFFICER` | 2 | 1 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route35OfficerScriptContest` (`56:5e0c`) | `EVENT_ROUTE_35_NATIONAL_PARK_GATE_OFFICER_CONTEST_DAY` |
| `ROUTE35NATIONALPARKGATE_YOUNGSTER` | `SPRITE_YOUNGSTER` | 6 | 5 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `Route35NationalParkGateYoungsterScript` | `EVENT_ROUTE_35_NATIONAL_PARK_GATE_YOUNGSTER` |
| `ROUTE35NATIONALPARKGATE_OFFICER2` | `SPRITE_OFFICER` | 0 | 3 | `STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `Route35NationalParkGateOfficerScript` | `EVENT_ROUTE_35_NATIONAL_PARK_GATE_OFFICER_NOT_CONTEST_DAY` |

**Callbacks**

- `MAPCALLBACK_NEWMAP` -> `Route35NationalParkGateCheckIfContestRunningCallback`:
  `checkflag ENGINE_BUG_CONTEST_TIMER` -> `setscene SCENE_..._LEAVE_CONTEST_EARLY`,
  else `setscene SCENE_..._NOOP`.
- `MAPCALLBACK_OBJECTS` -> `Route35NationalParkGateCheckIfContestAvailableCallback`
  (`56:5db8`): `readvar VAR_WEEKDAY`; `TUESDAY`/`THURSDAY`/`SATURDAY` ->
  `appear OFFICER1`, `disappear YOUNGSTER`, `disappear OFFICER2`. Otherwise
  `checkflag ENGINE_BUG_CONTEST_TIMER` (mid-contest keeps the contest officer), else the
  non-contest pair appears.

**Scripts of interest**

- `Route35OfficerScriptContest` (`56:5e0c`) - the entry point. Order of checks:
  1. `readvar VAR_WEEKDAY`; SUNDAY/MONDAY/WEDNESDAY/FRIDAY -> `Route35NationalParkGate_NoContestToday`.
  2. `checkflag ENGINE_DAILY_BUG_CONTEST` -> `Route35NationalParkGate_ContestIsOver`.
  3. `yesorno`. NO -> `Route35NationalParkGate_DeclinedToParticipate`.
  4. `readvar VAR_PARTYCOUNT` / `ifgreater 1, Route35NationalParkGate_LeaveTheRestBehind`.
     With more than one mon it needs box space (`readvar VAR_BOXSPACE`, `ifequal 0` ->
     `_NoRoomInBox`), rejects an EGG lead (`special CheckFirstMonIsEgg`) and rejects a
     fainted lead (`special ContestDropOffMons` -> `iftrue _FirstMonIsFainted`), then
     `setevent EVENT_LEFT_MONS_WITH_CONTEST_OFFICER`.
  5. `Route35NationalParkGate_OkayToProceed`: `setflag ENGINE_BUG_CONTEST_TIMER`,
     `special PlayMapMusic`, park ball text, `special GiveParkBalls`,
     `special FadeOutToWhite`, `special SelectRandomBugContestContestants`,
     `warp NATIONAL_PARK_BUG_CONTEST, 10, 47`.
- `Route35NationalParkGateLeavingContestEarlyScript` - runs when re-entering this gate
  while `ENGINE_BUG_CONTEST_TIMER` is set. `readvar VAR_CONTESTMINUTES` /
  `addval 1` / `getnum STRING_BUFFER_3`, `yesorno`. YES ->
  `jumpstd BugContestResultsWarpScript`. NO -> `warp NATIONAL_PARK_BUG_CONTEST, 10, 47`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_BUG_CONTEST_TIMER` | `constants/engine_flags.asm:26` | set by the officer, cleared by `BugContestResultsScript` | "contest in progress" |
| `ENGINE_DAILY_BUG_CONTEST` | `constants/engine_flags.asm:98` | set by `BugContestResultsScript` | "already ran today" |
| `EVENT_LEFT_MONS_WITH_CONTEST_OFFICER` | `constants/event_flags.asm:439` | officer / results script | party is being held |
| `EVENT_ROUTE_35_NATIONAL_PARK_GATE_OFFICER_CONTEST_DAY` / `_NOT_CONTEST_DAY` / `_YOUNGSTER` | `constants/event_flags.asm:1255-1256` (+ youngster) | `MAPCALLBACK_OBJECTS` | which NPC is visible |
| `VAR_WEEKDAY` | `constants/script_constants.asm` (`; 0b`) | callback + officer | 0=Sunday .. 6=Saturday |
| `VAR_CONTESTMINUTES` | `constants/script_constants.asm:65` (`; 11`) | early-exit script | minutes left |

**Items** - park balls only (see the Contest map). **Trainers** - none.

---

### MAP_NATIONAL_PARK

- Script: `maps/NationalPark.asm`
- Blocks: `maps/NationalPark.blk` (540 bytes = 20 x 27 blocks)
- Header (`data/maps/maps.asm:93`): `TILESET_PARK, ROUTE, LANDMARK_NATIONAL_PARK, MUSIC_NATIONAL_PARK, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:80` -> `map_const NATIONAL_PARK, 20, 27` (cells
  0..39 x, 0..53 y)
- Connections: none (`data/maps/attributes.asm:412` has no `connection` rows). Both exits
  are warps.

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 33 | 18 | `ROUTE_36_NATIONAL_PARK_GATE` | 1 |
| 2 | 33 | 19 | `ROUTE_36_NATIONAL_PARK_GATE` | 2 |
| 3 | 10 | 47 | `ROUTE_35_NATIONAL_PARK_GATE` | 1 |
| 4 | 11 | 47 | `ROUTE_35_NATIONAL_PARK_GATE` | 2 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 14 | 44 | `BGEVENT_READ` | `NationalParkRelaxationSquareSign` |
| 27 | 31 | `BGEVENT_READ` | `NationalParkBattleNoticeSign` |
| 6 | 47 | `BGEVENT_ITEM` | `NationalParkHiddenFullHeal` -> `hiddenitem FULL_HEAL, EVENT_NATIONAL_PARK_HIDDEN_FULL_HEAL` |
| 12 | 4 | `BGEVENT_READ` | `NationalParkTrainerTipsSign` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `NATIONALPARK_LASS1` | `SPRITE_LASS` | 15 | 24 | `WALK_LEFT_RIGHT` (1,0) | `OBJECTTYPE_SCRIPT` | `NationalParkLassScript` | -1 |
| `NATIONALPARK_POKEFAN_F1` | `SPRITE_POKEFAN_F` | 14 | 4 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `NationalParkPokefanFScript` | -1 |
| `NATIONALPARK_TEACHER1` | `SPRITE_TEACHER` | 27 | 40 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `NationalParkTeacher1Script` (`43:4008`) | -1 |
| `NATIONALPARK_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 11 | 41 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `NationalParkYoungster1Script` | -1 |
| `NATIONALPARK_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 10 | 41 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `NationalParkYoungster2Script` | -1 |
| `NATIONALPARK_TEACHER2` | `SPRITE_TEACHER` | 17 | 41 | `WANDER` (1,2) | `OBJECTTYPE_SCRIPT` | `NationalParkTeacher2Script` | -1 |
| `NATIONALPARK_PERSIAN` | `SPRITE_GROWLITHE` | 26 | 40 | `POKEMON` | `OBJECTTYPE_SCRIPT` | `NationalParkPersian` | -1 |
| `NATIONALPARK_YOUNGSTER3` | `SPRITE_YOUNGSTER` | 27 | 23 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` sight 3 | `TrainerSchoolboyJack1` | -1 |
| `NATIONALPARK_POKEFAN_F2` | `SPRITE_POKEFAN_F` | 18 | 29 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` sight 2 | `TrainerPokefanfBeverly1` | -1 |
| `NATIONALPARK_POKEFAN_M` | `SPRITE_POKEFAN_M` | 16 | 9 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` sight 2 | `TrainerPokefanmWilliam` | -1 |
| `NATIONALPARK_LASS2` | `SPRITE_LASS` | 8 | 14 | `SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` sight 3 | `TrainerLassKrise` | -1 |
| `NATIONALPARK_POKE_BALL1` | `SPRITE_POKE_BALL` | 35 | 12 | `STILL` | `OBJECTTYPE_ITEMBALL` | `NationalParkParlyzHeal` (`43:418f`) | `EVENT_NATIONAL_PARK_PARLYZ_HEAL` |
| `NATIONALPARK_GAMEBOY_KID` | `SPRITE_GAMEBOY_KID` | 26 | 6 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `NationalParkGameboyKidScript` | -1 |
| `NATIONALPARK_POKE_BALL2` | `SPRITE_POKE_BALL` | 1 | 43 | `STILL` | `OBJECTTYPE_ITEMBALL` | `NationalParkTMDig` (`43:4191`) | `EVENT_NATIONAL_PARK_TM_DIG` |

**Scripts of interest**

- `NationalParkTeacher1Script` (`43:4008`) - the walkthrough's "lady on the bench".
  `checkevent EVENT_GOT_QUICK_CLAW` / `iftrue .GotQuickClaw`; else text,
  `verbosegiveitem QUICK_CLAW`, `iffalse .NoRoom`, `setevent EVENT_GOT_QUICK_CLAW`.
  Unlike the flower shop teacher this one **does** guard the `setevent` with `iffalse`.
- `TrainerSchoolboyJack1` - phone trainer (`PHONE_SCHOOLBOY_JACK`). Rematch tiers:
  `EVENT_CLEARED_RADIO_TOWER` -> `JACK3`, `ENGINE_FLYPOINT_OLIVINE` -> `JACK2`, else `JACK1`.
- `TrainerPokefanfBeverly1` - phone trainer (`PHONE_POKEFAN_BEVERLY`), female std scripts
  (`AskNumber1FScript` etc). Rematch tiers: `EVENT_CLEARED_RADIO_TOWER` -> `BEVERLY3`,
  `ENGINE_FLYPOINT_MAHOGANY` -> `BEVERLY2`, else `BEVERLY1`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_GOT_QUICK_CLAW` | `constants/event_flags.asm:96` | `NationalParkTeacher1Script` | one-shot gift |
| `EVENT_NATIONAL_PARK_PARLYZ_HEAL` | `constants/event_flags.asm:1017` | item ball | ball taken |
| `EVENT_NATIONAL_PARK_TM_DIG` | `constants/event_flags.asm:1018` | item ball | ball taken |
| `EVENT_NATIONAL_PARK_HIDDEN_FULL_HEAL` | `constants/event_flags.asm:142` | `hiddenitem` | hidden item taken |
| `EVENT_BEAT_SCHOOLBOY_JACK`, `EVENT_BEAT_POKEFANF_BEVERLY`, `EVENT_BEAT_POKEFANM_WILLIAM`, `EVENT_BEAT_LASS_KRISE` | `constants/event_flags.asm` | `trainer` rows | defeated bits |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `QUICK_CLAW` | talk to teacher at (27, 40) | `NationalParkTeacher1Script` | `EVENT_GOT_QUICK_CLAW` |
| `PARLYZ_HEAL` | item ball at (35, 12) | `NationalParkParlyzHeal` | `EVENT_NATIONAL_PARK_PARLYZ_HEAL` |
| `TM_DIG` (TM28) | item ball at (1, 43) | `NationalParkTMDig` | `EVENT_NATIONAL_PARK_TM_DIG` |
| `FULL_HEAL` | hidden, bg_event at (6, 47) | `NationalParkHiddenFullHeal` | `EVENT_NATIONAL_PARK_HIDDEN_FULL_HEAL` |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `BEVERLY1` | `POKEFANF` (0x3e) | 1 | `parties.asm:3115` `BEVERLY` `TRAINERTYPE_ITEM` - lv14 SNUBBULL @ BERRY | `TrainerPokefanfBeverly1` | yes (`PHONE_POKEFAN_BEVERLY`); BEVERLY2 `parties.asm:3125`, BEVERLY3 `parties.asm:3130` |
| `JACK1` | `SCHOOLBOY` (0x17) | 1 | `parties.asm:409` `JACK` - lv12 ODDISH, lv15 VOLTORB | `TrainerSchoolboyJack1` | yes (`PHONE_SCHOOLBOY_JACK`); JACK2 `parties.asm:484`, JACK3 `parties.asm:490` |
| `KRISE` | `LASS` (0x19) | 4 | `parties.asm:658` `KRISE` - lv12 ODDISH, lv15 CUBONE | `TrainerLassKrise` | no |
| `WILLIAM` | `POKEFANM` (0x3b) | 1 | `parties.asm:2961` `WILLIAM` `TRAINERTYPE_ITEM` - lv14 RAICHU @ BERRY | `TrainerPokefanmWilliam` | no |

**Wild encounters** - `data/wild/johto_grass.asm`, `def_grass_wildmons NATIONAL_PARK`,
rates 10/10/10 percent. Gold table:

| slot | morn | day | nite |
|---|---|---|---|
| 1 | 10 CATERPIE | 10 CATERPIE | 10 HOOTHOOT |
| 2 | 10 METAPOD | 10 METAPOD | 10 HOOTHOOT |
| 3 | 12 CATERPIE | 11 SUNKERN | 12 HOOTHOOT |
| 4 | 12 PIDGEY | 12 PIDGEY | 12 HOOTHOOT |
| 5 | 10 PIDGEY | 13 SUNKERN | 10 HOOTHOOT |
| 6 | 14 PIDGEY | 14 PIDGEY | 14 HOOTHOOT |
| 7 | 14 PIDGEY | 14 PIDGEY | 14 HOOTHOOT |

(Silver uses WEEDLE/KAKUNA in slots 1-3 morn. The nite block is shared by both versions.)
No `NATIONAL_PARK` entry exists in `data/wild/johto_water.asm`, `data/wild/treemon_maps.asm`
or `data/wild/swarm_grass.asm`. The rare bugs the walkthrough lists (Scyther, Pinsir,
Paras, Venonat, Butterfree, Beedrill) are **Contest-only**; see below.

---

### MAP_NATIONAL_PARK_BUG_CONTEST

- Script: `maps/NationalParkBugContest.asm`
- Blocks: none of its own; `data/maps/attributes.asm:413` gives
  `map_attributes NationalParkBugContest, NATIONAL_PARK_BUG_CONTEST, $00` and the map is a
  same-geometry twin of National Park.
- Header (`data/maps/maps.asm:94`): `TILESET_PARK, ROUTE, LANDMARK_NATIONAL_PARK, MUSIC_BUG_CATCHING_CONTEST, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:81` -> `map_const NATIONAL_PARK_BUG_CONTEST, 20, 27`
- Connections: none

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 33 | 18 | `ROUTE_36_NATIONAL_PARK_GATE` | 1 |
| 2 | 33 | 19 | `ROUTE_36_NATIONAL_PARK_GATE` | 1 |
| 3 | 10 | 47 | `ROUTE_35_NATIONAL_PARK_GATE` | 1 |
| 4 | 11 | 47 | `ROUTE_35_NATIONAL_PARK_GATE` | 1 |

(Warps 2 and 4 point at dest warp 1, not 2 - that is what the file says.)

**Coord events** - none.

**BG events** - same four rows as National Park, aimed at the `...BugContest...` copies:
(14,44) Relaxation Square sign, (27,31) Battle Notice sign, (6,47) `BGEVENT_ITEM`
`hiddenitem FULL_HEAL, EVENT_NATIONAL_PARK_HIDDEN_FULL_HEAL` (the same flag as the normal
map), (12,4) Trainer Tips sign.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `..._YOUNGSTER1` | `SPRITE_YOUNGSTER` | 19 | 29 | `WANDER` (2,2) | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant1AScript` | `EVENT_BUG_CATCHING_CONTESTANT_1A` |
| `..._YOUNGSTER2` | `SPRITE_YOUNGSTER` | 28 | 22 | `WANDER` (2,2) | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant2AScript` | `..._2A` |
| `..._ROCKER` | `SPRITE_ROCKER` | 9 | 18 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant3AScript` | `..._3A` |
| `..._POKEFAN_M` | `SPRITE_POKEFAN_M` | 7 | 13 | `WALK_UP_DOWN` (1,0) | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant4AScript` | `..._4A` |
| `..._YOUNGSTER3` | `SPRITE_YOUNGSTER` | 23 | 9 | `SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant5AScript` | `..._5A` |
| `..._YOUNGSTER4` | `SPRITE_YOUNGSTER` | 27 | 13 | `WANDER` (3,3) | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant6AScript` | `..._6A` |
| `..._LASS` | `SPRITE_LASS` | 7 | 23 | `WALK_LEFT_RIGHT` (2,0) | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant7AScript` | `..._7A` |
| `..._YOUNGSTER5` | `SPRITE_YOUNGSTER` | 11 | 27 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant8AScript` | `..._8A` |
| `..._YOUNGSTER6` | `SPRITE_YOUNGSTER` | 16 | 8 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant9AScript` | `..._9A` |
| `..._YOUNGSTER7` | `SPRITE_YOUNGSTER` | 17 | 34 | `WANDER` (3,3) | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant10AScript` | `..._10A` |
| `..._POKE_BALL1` | `SPRITE_POKE_BALL` | 35 | 12 | `STILL` | `OBJECTTYPE_ITEMBALL` | `NationalParkBugContestParlyzHeal` | `EVENT_NATIONAL_PARK_PARLYZ_HEAL` |
| `..._POKE_BALL2` | `SPRITE_POKE_BALL` | 1 | 43 | `STILL` | `OBJECTTYPE_ITEMBALL` | `NationalParkBugContestTMDig` | `EVENT_NATIONAL_PARK_TM_DIG` |

**Scripts of interest**

- Every `BugCatchingContestantNAScript` is `faceplayer / opentext / writetext / waitbutton
  / closetext / end` - flavour only, no branching. The `B` variants in the north gate are
  the ones that branch on `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1` (set by
  `BugContestResults_FirstPlace`) to say "you won".
- The battle path is `BugCatchingContestBattleScript::`
  (`engine/events/bug_contest/contest.asm:9`): `loadvar VAR_BATTLETYPE, BATTLETYPE_CONTEST`,
  `randomwildmon`, `startbattle`, `reloadmapafterbattle`, `readmem wParkBallsRemaining`,
  `iffalse BugCatchingContestOutOfBallsScript`.
- `GiveParkBalls` (`engine/events/bug_contest/contest.asm:1`) clears `wContestMon`, writes
  `BUG_CONTEST_BALLS` into `wParkBallsRemaining` and `farcall StartBugContestTimer`.

**Contest constants** (`constants/script_constants.asm`)

| constant | line | value |
|---|---|---|
| `BUG_CONTEST_BALLS` | 283 | 20 |
| `BUG_CONTEST_MINUTES` | 284 | 20 |
| `BUG_CONTEST_PLAYER` | 286 | 1 |
| `NUM_BUG_CONTESTANTS` | 287 | 10 (not counting the player) |
| `VAR_CONTESTMINUTES` | 65 | var id 0x11 |

**Contest wild table** - `data/wild/bug_contest_mons.asm`, label `ContestMons`
(`25:7bb8`). This table replaces National Park's grass entirely for the duration:

| % | species | min lv | max lv |
|---|---|---|---|
| 20 | CATERPIE | 7 | 18 |
| 20 | WEEDLE | 7 | 18 |
| 10 | METAPOD | 9 | 18 |
| 10 | KAKUNA | 9 | 18 |
| 5 | BUTTERFREE | 12 | 15 |
| 5 | BEEDRILL | 12 | 15 |
| 10 | VENONAT | 10 | 16 |
| 10 | PARAS | 10 | 17 |
| 5 | SCYTHER | 13 | 14 |
| 5 | PINSIR | 13 | 14 |
| -1 (terminator row) | VENOMOTH | 30 | 40 |

**Scoring** - `ContestScore` (`04:7cbc`, `engine/events/bug_contest/judging.asm`) sums:
`MaxHP * 4` (high byte only), then Attack, Defense, Speed, SpclAtk, SpclDef, then a DV
bonus assembled from bit 1 of each DV nibble, then `remaining HP / 8`, then `+1` if the
mon is holding an item. Five of the ten AI contestants are rolled by
`ComputeAIContestantScores`, each picking one of three canned mon/score pairs from
`BugContestantPointers` (`data/events/bug_contest_winners.asm`) with a 0..7 random
perturbation. `DetermineContestWinners` keeps a 3-deep podium.

**Prizes** - `BugContestResultsScript` (`40:420e`, `engine/events/std_scripts.asm:275`):

| place | item | no-room fallback flag |
|---|---|---|
| 1st | `SUN_STONE` | `EVENT_CONTEST_OFFICER_HAS_SUN_STONE` |
| 2nd | `EVERSTONE` | `EVENT_CONTEST_OFFICER_HAS_EVERSTONE` |
| 3rd | `GOLD_BERRY` | `EVENT_CONTEST_OFFICER_HAS_GOLD_BERRY` |
| consolation | `BERRY` | `EVENT_CONTEST_OFFICER_HAS_BERRY` |

First place also sets `EVENT_TEMPORARY_UNTIL_MAP_RELOAD_1`. The tail of the script clears
`ENGINE_BUG_CONTEST_TIMER`, sets all twenty `EVENT_BUG_CATCHING_CONTESTANT_*` flags, sets
`ENGINE_DAILY_BUG_CONTEST`, and resets both gate scenes to their NOOP.

---

### MAP_ROUTE_36_NATIONAL_PARK_GATE

- Script: `maps/Route36NationalParkGate.asm`
- Blocks: `maps/Route36NationalParkGate.blk`
- Header (`data/maps/maps.asm:263`): `TILESET_GATE, INDOOR, LANDMARK_ROUTE_36, MUSIC_GOLDENROD_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:242` -> `map_const ROUTE_36_NATIONAL_PARK_GATE, 5, 4`
- Connections: none

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 4 | `NATIONAL_PARK` | 1 |
| 2 | 0 | 5 | `NATIONAL_PARK` | 2 |
| 3 | 9 | 4 | `ROUTE_36` | 1 |
| 4 | 9 | 5 | `ROUTE_36` | 2 |

**Coord events** - none. Scene scripts (same three-slot shape as the south gate):
`SCENE_ROUTE36NATIONALPARKGATE_NOOP` (0), `..._UNUSED` (1),
`..._LEAVE_CONTEST_EARLY` (2) -> `sdefer Route36NationalParkGateLeavingContestEarlyScript`.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 6 | 0 | `BGEVENT_READ` | `BugCatchingContestExplanationSign` (the label defined in `maps/Route35NationalParkGate.asm`) |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE36NATIONALPARKGATE_OFFICER1` | `SPRITE_OFFICER` | 0 | 3 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route36OfficerScriptContest` (`56:67cc`) | `EVENT_ROUTE_36_NATIONAL_PARK_GATE_OFFICER_CONTEST_DAY` |
| `..._YOUNGSTER1` | `SPRITE_YOUNGSTER` | 2 | 5 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant1BScript` | `EVENT_BUG_CATCHING_CONTESTANT_1B` |
| `..._YOUNGSTER2` | `SPRITE_YOUNGSTER` | 4 | 5 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant2BScript` | `..._2B` |
| `..._ROCKER` | `SPRITE_ROCKER` | 2 | 6 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant3BScript` | `..._3B` |
| `..._POKEFAN_M` | `SPRITE_POKEFAN_M` | 6 | 5 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant4BScript` | `..._4B` |
| `..._YOUNGSTER3` | `SPRITE_YOUNGSTER` | 2 | 7 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant5BScript` | `..._5B` |
| `..._YOUNGSTER4` | `SPRITE_YOUNGSTER` | 5 | 6 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant6BScript` | `..._6B` |
| `..._LASS` | `SPRITE_LASS` | 3 | 6 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant7BScript` | `..._7B` |
| `..._YOUNGSTER5` | `SPRITE_YOUNGSTER` | 4 | 7 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant8BScript` | `..._8B` |
| `..._YOUNGSTER6` | `SPRITE_YOUNGSTER` | 6 | 7 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant9BScript` | `..._9B` |
| `..._YOUNGSTER7` | `SPRITE_YOUNGSTER` | 6 | 6 | `STANDING_UP` | `OBJECTTYPE_SCRIPT` | `BugCatchingContestant10BScript` | `..._10B` |
| `ROUTE36NATIONALPARKGATE_OFFICER2` | `SPRITE_OFFICER` | 3 | 2 | `STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route36NationalParkGateOfficerScript` | `EVENT_ROUTE_36_NATIONAL_PARK_GATE_OFFICER_NOT_CONTEST_DAY` |

**Callbacks**

- `MAPCALLBACK_NEWMAP` -> `Route36NationalParkGateCheckIfContestRunningCallback`
  (same shape as the south gate).
- `MAPCALLBACK_OBJECTS` -> `Route36NationalParkGateCheckIfContestAvailableCallback`
  (`56:6710`): first `checkevent EVENT_WARPED_FROM_ROUTE_35_NATIONAL_PARK_GATE` -> return
  unchanged (this is how the awards ceremony keeps the contest officer standing there when
  you finished from the *south* gate). Then weekday / `ENGINE_BUG_CONTEST_TIMER`, same as
  the south gate.

**Scripts of interest**

- `Route36OfficerScriptContest` (`56:67cc`) - same structure as the south gate's officer
  but warps to `NATIONAL_PARK_BUG_CONTEST, 33, 18` and, if `ENGINE_DAILY_BUG_CONTEST` is
  already set, falls into `Route36Officer_ContestHasConcluded`, which is the **prize
  holding desk**: it checks `EVENT_CONTEST_OFFICER_HAS_SUN_STONE`, then `_EVERSTONE`, then
  `_GOLD_BERRY`, then `_BERRY`, `verbosegiveitem`s the first one it finds and clears that
  event. A bot that won with a full PACK collects here.
- `Route36NationalParkGateLeavingContestEarlyScript` - the finish-now flow.
  `special FadeOutToBlack`, `.CopyContestants` (turns each unset `..._NA` flag into an
  `appear` of the matching `B` object), `disappear OFFICER1` / `appear OFFICER2`,
  `applymovement PLAYER, Route36NationalParkGatePlayerWaitWithContestantsMovement`
  (`big_step DOWN`, `big_step RIGHT`, `turn_head UP`), then
  `jumpstd BugContestResultsScript`.

---

### MAP_ROUTE_36

- Script: `maps/Route36.asm`
- Blocks: `maps/Route36.blk` (270 bytes = 30 x 9 blocks)
- Header (`data/maps/maps.asm:249`): `TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_36, MUSIC_ROUTE_36, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:228` -> `map_const ROUTE_36, 30, 9` (cells
  0..59 x, 0..17 y)
- Connections (`data/maps/attributes.asm:206`): north `ROUTE_37` offset 10, south
  `ROUTE_35` offset 0, east `VIOLET_CITY` offset 0

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 18 | 8 | `ROUTE_36_NATIONAL_PARK_GATE` | 3 |
| 2 | 18 | 9 | `ROUTE_36_NATIONAL_PARK_GATE` | 4 |
| 3 | 47 | 13 | `ROUTE_36_RUINS_OF_ALPH_GATE` | 1 |
| 4 | 48 | 13 | `ROUTE_36_RUINS_OF_ALPH_GATE` | 2 |

**Coord events** - none. (Sudowoodo is an object, not a trip-wire.)

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 29 | 1 | `BGEVENT_READ` | `Route36TrainerTips2` |
| 45 | 11 | `BGEVENT_READ` | `RuinsOfAlphNorthSign` |
| 55 | 7 | `BGEVENT_READ` | `Route36Sign` |
| 21 | 7 | `BGEVENT_READ` | `Route36TrainerTips1` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE36_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 20 | 12 | `STANDING_RIGHT` | `OBJECTTYPE_TRAINER` sight 2 | `TrainerPsychicMark` | -1 |
| `ROUTE36_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 31 | 14 | `STANDING_LEFT` | `OBJECTTYPE_TRAINER` sight 5 | `TrainerSchoolboyAlan1` | -1 |
| `ROUTE36_WEIRD_TREE` | `SPRITE_WEIRD_TREE` | 35 | 9 | `SPRITEMOVEDATA_SUDOWOODO` | `OBJECTTYPE_SCRIPT` | `SudowoodoScript` (`4b:61aa`) | `EVENT_ROUTE_36_SUDOWOODO` |
| `ROUTE36_LASS1` | `SPRITE_LASS` | 51 | 8 | `WALK_LEFT_RIGHT` (2,0) | `OBJECTTYPE_SCRIPT` | `Route36LassScript` (`4b:621e`) | -1 |
| `ROUTE36_FISHER` | `SPRITE_FISHER` | 44 | 9 | `STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `Route36RockSmashGuyScript` (`4b:61f7`) | -1 |
| `ROUTE36_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 21 | 4 | `STILL` | `OBJECTTYPE_SCRIPT` | `Route36FruitTree` (`4b:631a`) | -1 |
| `ROUTE36_ARTHUR` | `SPRITE_YOUNGSTER` | 46 | 6 | `WANDER` (1,1) | `OBJECTTYPE_SCRIPT` | `ArthurScript` (`4b:62d4`) | `EVENT_ROUTE_36_ARTHUR_OF_THURSDAY` |

**Callbacks**

- `MAPCALLBACK_OBJECTS` -> `Route36ArthurCallback` (`4b:619e`): `readvar VAR_WEEKDAY`,
  `ifequal THURSDAY, .ArthurAppears` (-> `appear ROUTE36_ARTHUR`), otherwise
  `disappear ROUTE36_ARTHUR`.

**Scripts of interest**

- `SudowoodoScript` (`4b:61aa`) - the gate of this section.
  `checkitem SQUIRTBOTTLE` / `iftrue .Fight`. Without it: `waitsfx`,
  `playsound SFX_SANDSTORM`, `applymovement ROUTE36_WEIRD_TREE, SudowoodoShakeMovement`
  (`tree_shake`), `end` - the tree just wobbles and stays solid.
  With it: `writetext UseSquirtbottleText`, `yesorno`, `iffalse DidntUseSquirtbottleScript`.
- `WateredWeirdTreeScript::` (`4b:61c1`) - exported so that using the SQUIRTBOTTLE from the
  PACK reaches the same body (`engine/events/squirtbottle.asm` does
  `farsjump WateredWeirdTreeScript`). Body: text, shake, `SudowoodoAttackedText`,
  **`loadwildmon SUDOWOODO, 20`**, `startbattle`, `setevent EVENT_FOUGHT_SUDOWOODO`,
  `ifequal DRAW, DidntCatchSudowoodo`, `disappear ROUTE36_WEIRD_TREE`,
  `variablesprite SPRITE_WEIRD_TREE, SPRITE_TWIN`, `reloadmapafterbattle`.
  Note the ordering: `EVENT_FOUGHT_SUDOWOODO` is set **before** the DRAW check, so a run
  or a KO still clears the road and still unlocks TM08.
- `DidntCatchSudowoodo` (`4b:61e9`) - `reloadmapafterbattle`,
  `applymovement ROUTE36_WEIRD_TREE, WeirdTreeMovement_Flee` (two `fast_jump_step UP`),
  `disappear`, `variablesprite`, `special LoadUsedSpritesGFX`.
- `_Squirtbottle` (`14:4763`, `engine/events/squirtbottle.asm`) - the PACK path.
  `.CheckCanUseSquirtbottle` requires `wMapGroup == GROUP_ROUTE_36`,
  `wMapNumber == MAP_ROUTE_36`, `GetFacingObject` to succeed, and that object's movement
  data to be `SPRITEMOVEDATA_SUDOWOODO`. Anything else prints
  `_SquirtbottleNothingText`.
- `Route36RockSmashGuyScript` (`4b:61f7`) - `checkevent EVENT_GOT_TM08_ROCK_SMASH` ->
  `.AlreadyGotRockSmash`; `checkevent EVENT_FOUGHT_SUDOWOODO` -> `.ClearedSudowoodo`
  (`verbosegiveitem TM_ROCK_SMASH`, `iffalse .NoRoomForTM`,
  `setevent EVENT_GOT_TM08_ROCK_SMASH`). Before Sudowoodo it just prints
  `RockSmashGuyText1`.
- `ArthurScript` (`4b:62d4`) - `checkevent EVENT_GOT_HARD_STONE_FROM_ARTHUR` ->
  `.AlreadyGotStone`; `readvar VAR_WEEKDAY` / `ifnotequal THURSDAY, ArthurNotThursdayScript`;
  else `setevent EVENT_MET_ARTHUR_OF_THURSDAY`, `verbosegiveitem HARD_STONE`,
  `iffalse .BagFull`, `setevent EVENT_GOT_HARD_STONE_FROM_ARTHUR`.
- `Route36LassScript` (`4b:621e`) - flavour, branches on `EVENT_FOUGHT_SUDOWOODO`. This is
  the girl at (51, 8). She is **not** Floria and gives nothing.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_ROUTE_36_SUDOWOODO` | `constants/event_flags.asm:1178` | object visibility flag; cleared by `disappear` in `WateredWeirdTreeScript` | tree present on the map |
| `EVENT_FOUGHT_SUDOWOODO` | `constants/event_flags.asm:51` | set by `WateredWeirdTreeScript`; read by the Rock Smash guy, the Route 36 lass, the Route 35 gate pokefan | **the** progress flag of this section |
| `EVENT_GOT_TM08_ROCK_SMASH` | `constants/event_flags.asm:84` | `Route36RockSmashGuyScript` | TM08 taken |
| `EVENT_ROUTE_36_ARTHUR_OF_THURSDAY` | `constants/event_flags.asm:1276` | `Route36ArthurCallback` | Arthur visible |
| `EVENT_MET_ARTHUR_OF_THURSDAY` | `constants/event_flags.asm:111` | `ArthurScript` | first-meeting text |
| `EVENT_GOT_HARD_STONE_FROM_ARTHUR` | `constants/event_flags.asm:112` | `ArthurScript` | HARD STONE taken |
| `EVENT_BEAT_PSYCHIC_MARK`, `EVENT_BEAT_SCHOOLBOY_ALAN` | `constants/event_flags.asm` | `trainer` rows | defeated bits |
| `EVENT_ALAN_ASKED_FOR_PHONE_NUMBER`, `EVENT_ALAN_READY_FOR_REMATCH` | `constants/event_flags.asm` | Alan script | phone state machine |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `ICE_BERRY` | fruit tree object at (21, 4) | `FRUITTREE_ROUTE_36` -> `data/items/fruit_trees.asm:16` | daily |
| `TM_ROCK_SMASH` (TM08) | talk to the fisher at (44, 9) after Sudowoodo | `Route36RockSmashGuyScript` | `EVENT_GOT_TM08_ROCK_SMASH` |
| `HARD_STONE` | talk to Arthur at (46, 6) on a Thursday | `ArthurScript` | `EVENT_GOT_HARD_STONE_FROM_ARTHUR` |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `MARK` | `PSYCHIC_T` (0x34) | 7 | `parties.asm:2545` `MARK` `TRAINERTYPE_MOVES` - lv13 ABRA (TELEPORT, FLASH), lv13 ABRA (TELEPORT, FLASH), lv15 KADABRA (TELEPORT, KINESIS, CONFUSION) | `TrainerPsychicMark` | no |
| `ALAN1` | `SCHOOLBOY` (0x17) | 3 | `parties.asm:423` `ALAN` - lv16 TANGELA | `TrainerSchoolboyAlan1` | yes (`PHONE_SCHOOLBOY_ALAN`); ALAN2 `parties.asm:496`, ALAN3 `parties.asm:502` |

**Wild** - `data/wild/johto_grass.asm`, `def_grass_wildmons ROUTE_36`, 10/10/10 percent.
Gold:

| slot | morn | day | nite |
|---|---|---|---|
| 1 | 12 NIDORAN_M | 12 NIDORAN_M | 12 NIDORAN_M |
| 2 | 12 NIDORAN_F | 12 NIDORAN_F | 12 NIDORAN_F |
| 3 | 13 PIDGEY | 14 PIDGEY | 13 HOOTHOOT |
| 4 | 13 GROWLITHE | 13 GROWLITHE | 13 GROWLITHE |
| 5 | 13 STANTLER | 13 STANTLER | 13 STANTLER |
| 6 | 15 PIDGEY | 15 GROWLITHE | 15 HOOTHOOT |
| 7 | 15 PIDGEY | 15 GROWLITHE | 15 HOOTHOOT |

(Silver substitutes VULPIX for GROWLITHE and swaps the NIDORAN order.) No `ROUTE_36`
entry in `johto_water.asm`. Headbutt: `data/wild/treemon_maps.asm:17` -> `TREEMON_SET_FOREST`.
`ROUTE_36` is a roam node in `data/wild/roammon_maps.asm:26` with four exits
(`ROUTE_35, ROUTE_31, ROUTE_32, ROUTE_37`).

---

### MAP_ROUTE_37 (header-listed only; not entered by this walkthrough section)

- Script: `maps/Route37.asm`, Blocks: `maps/Route37.blk`
- Header (`data/maps/maps.asm:250`): `TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_37, MUSIC_ROUTE_36, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:229` -> `map_const ROUTE_37, 10, 9`
- Connections (`data/maps/attributes.asm:211`): north `ECRUTEAK_CITY` offset -5,
  south `ROUTE_36` offset -10
- **Warps: `def_warp_events` is empty.** Route 37 is reached only by connection.
- BG events: (5,3) `BGEVENT_READ` `Route37Sign`; (4,2) `BGEVENT_ITEM`
  `Route37HiddenEther` -> `hiddenitem ETHER, EVENT_ROUTE_37_HIDDEN_ETHER`.
- Objects: Twins Ann & Anne at (6,12) and (7,12) (`ANNANDANNE1` / `ANNANDANNE2`, both
  sharing `EVENT_BEAT_TWINS_ANN_AND_ANNE`), Psychic Greg at (9,6), three fruit trees at
  (13,5) `FRUITTREE_ROUTE_37_1` = `RED_APRICORN`, (16,5) `_2` = `BLU_APRICORN`,
  (15,7) `_3` = `BLK_APRICORN` (`data/items/fruit_trees.asm:20-22`), and Sunny of Sunday
  at (16,8) behind `EVENT_ROUTE_37_SUNNY_OF_SUNDAY` (gift `MAGNET`,
  `EVENT_GOT_MAGNET_FROM_SUNNY`).
- Callback: `MAPCALLBACK_OBJECTS` -> `Route37SunnyCallback` (weekday == SUNDAY).
- Wild: `data/wild/johto_grass.asm` `def_grass_wildmons ROUTE_37`, 10/10/10; Gold nite
  slot 1/5/6/7 are SPINARAK 13/15/15/15, Silver morn is LEDYBA - this is where the
  walkthrough's "Ledyba (Silver only, morning only) / Spinarak (Gold only, night only)"
  actually lives.

---

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| SQUIRTBOTTLE not obtainable | `maps/GoldenrodFlowerShop.asm:FlowerShopTeacherScript` (`57:52d1`) - `checkflag ENGINE_PLAINBADGE` / `iffalse .Lalala` | Plain Badge (Whitney) | beat Whitney; talk to the teacher at (2,4) |
| Sudowoodo blocks Route 36 | `maps/Route36.asm:SudowoodoScript` (`4b:61aa`) - the object at cell (35,9) with `SPRITEMOVEDATA_SUDOWOODO` is a solid NPC; the script's `checkitem SQUIRTBOTTLE` / `iftrue .Fight` is the only way past | SQUIRTBOTTLE in the PACK | `EVENT_FOUGHT_SUDOWOODO` set by `WateredWeirdTreeScript` (`4b:61c1`); the `disappear` runs on any outcome except a draw-flee, and the flee path disappears it too |
| SQUIRTBOTTLE from the PACK does nothing elsewhere | `engine/events/squirtbottle.asm:_Squirtbottle` (`14:4763`) `.CheckCanUseSquirtbottle` | map must be `ROUTE_36` and the faced object must carry `SPRITEMOVEDATA_SUDOWOODO` | face the tree first |
| TM08 ROCK SMASH withheld | `maps/Route36.asm:Route36RockSmashGuyScript` (`4b:61f7`) - `checkevent EVENT_FOUGHT_SUDOWOODO` | Sudowoodo dealt with | talk to the fisher at (44, 9) |
| East side of Route 35 (Arnie, Bryan, TM04) | `maps/Route35.blk` block `$5b` at block (8,3) = cells x16-17 y6-7; `data/collision/field_move_blocks.asm:14` | CUT, which needs `ENGINE_HIVEBADGE` (`engine/events/overworld.asm:133` `CutFunction.CheckAble`) and a party mon that knows CUT | Azalea's badge + HM01; or enter from Route 36 via the south connection, which is what the walkthrough does |
| Bug Contest closed | `maps/Route35NationalParkGate.asm:Route35OfficerScriptContest` (`56:5e0c`) and `maps/Route36NationalParkGate.asm:Route36OfficerScriptContest` (`56:67cc`) - `readvar VAR_WEEKDAY`, four `ifequal` bail-outs, plus `checkflag ENGINE_DAILY_BUG_CONTEST` | Tuesday, Thursday or Saturday, and not already run today | set the RTC weekday; `ENGINE_DAILY_BUG_CONTEST` clears on the daily reset |
| Contest entry refused | same scripts - `readvar VAR_PARTYCOUNT` / `VAR_BOXSPACE` / `special CheckFirstMonIsEgg` / `special ContestDropOffMons` | lead mon is not an EGG, is not fainted, and there is party-or-box room for a caught bug | reorder the party, heal, free a box slot |
| Kenya not given | `maps/Route35GoldenrodGate.asm:RandyScript` (`56:59ce`) - `readvar VAR_PARTYCOUNT` / `ifequal PARTY_LENGTH, .partyfull` | fewer than 6 party mons | deposit one |
| Arthur / Sunny absent | `Route36ArthurCallback` (`4b:619e`) / `Route37SunnyCallback` - `MAPCALLBACK_OBJECTS` + `VAR_WEEKDAY` | Thursday / Sunday | RTC weekday |
| Officer Dirk will not battle | `maps/Route35.asm:TrainerOfficerDirk` - `checktime NITE` / `iffalse .NotNight` | night time of day | wait, or set the RTC |

---

## 4. Bot checklist

Coordinates are `(x, y)` walk cells as written in the asm. "talk" means stand adjacent
facing the target and press A.

1. `MAP_GOLDENROD_CITY` -> warp 6 at (33, 5). Pre: `ENGINE_PLAINBADGE` set. Post: on
   `MAP_GOLDENROD_FLOWER_SHOP`.
2. `MAP_GOLDENROD_FLOWER_SHOP`: talk to `GOLDENRODFLOWERSHOP_TEACHER` at (2, 4).
   Pre: `!EVENT_GOT_SQUIRTBOTTLE` and a free KEY ITEM slot. Post:
   `EVENT_GOT_SQUIRTBOTTLE`, SQUIRTBOTTLE in the PACK.
3. Exit via warp 1 (2, 7) -> `MAP_GOLDENROD_CITY` warp 6. Walk to (19, 1), warp 13 ->
   `MAP_ROUTE_35_GOLDENROD_GATE` warp 3.
4. Optional: talk to `ROUTE35GOLDENRODGATE_RANDY` at (0, 4), answer YES.
   Pre: `VAR_PARTYCOUNT < 6`. Post: `EVENT_GOT_KENYA`, lv10 SPEAROW "KENYA" with
   `FLOWER_MAIL` in the last party slot.
5. Warp 1 at (4, 0) -> `MAP_ROUTE_35` warp 1 (lands at (9, 33)).
6. `MAP_ROUTE_35`, walk north. Battle, in the walkthrough's order:
   Kim (11, 24), Elliot (8, 20), Brooke (7, 20), Ivan (3, 19), Irwin (5, 10),
   Walt (2, 10). Post: `EVENT_BEAT_*` for each. Sight ranges are 3/3/3/4/2/2.
7. Optional, night only: talk to `ROUTE35_OFFICER` at (5, 6). Pre: `checktime NITE` true
   and `!EVENT_BEAT_OFFICER_DIRK`. Post: `EVENT_BEAT_OFFICER_DIRK`.
8. Walk to (3, 5), warp 3 -> `MAP_ROUTE_35_NATIONAL_PARK_GATE` warp 3.
9. Optional Contest: on a Tue/Thu/Sat with `!ENGINE_DAILY_BUG_CONTEST`, talk to
   `ROUTE35NATIONALPARKGATE_OFFICER1` at (2, 1) and answer YES. Post:
   `ENGINE_BUG_CONTEST_TIMER` set, 20 PARK BALLs, warp to
   `MAP_NATIONAL_PARK_BUG_CONTEST` (10, 47). Finish by re-entering either gate and
   answering YES, or by running the timer/balls out. Post: `ENGINE_DAILY_BUG_CONTEST`,
   prize per placing, `ENGINE_BUG_CONTEST_TIMER` cleared.
10. Warp 1 at (3, 0) -> `MAP_NATIONAL_PARK` warp 3 (lands at (10, 47)).
11. `MAP_NATIONAL_PARK`: talk to `NATIONALPARK_TEACHER1` at (27, 40).
    Pre: `!EVENT_GOT_QUICK_CLAW`, PACK room. Post: `EVENT_GOT_QUICK_CLAW`.
12. Optional: item ball at (1, 43) -> `TM_DIG`, flag `EVENT_NATIONAL_PARK_TM_DIG`.
    Hidden `FULL_HEAL` at bg (6, 47), flag `EVENT_NATIONAL_PARK_HIDDEN_FULL_HEAL`.
    Item ball at (35, 12) -> `PARLYZ_HEAL`, flag `EVENT_NATIONAL_PARK_PARLYZ_HEAL`.
13. Battle Beverly (18, 29), Jack (27, 23), Krise (8, 14), William (16, 9).
14. Walk to (33, 18), warp 1 -> `MAP_ROUTE_36_NATIONAL_PARK_GATE` warp 1.
    If a prize was held: talk to `ROUTE36NATIONALPARKGATE_OFFICER1` at (0, 3) with
    `ENGINE_DAILY_BUG_CONTEST` set to collect it.
15. Warp 3 at (9, 4) -> `MAP_ROUTE_36` warp 1 (lands at (18, 8)).
16. `MAP_ROUTE_36`: fruit tree at (21, 4) -> `ICE_BERRY`. Battle Psychic Mark at (20, 12).
17. Leave south (`ROUTE_36` south connection, offset 0) into `MAP_ROUTE_35`'s north edge.
18. `MAP_ROUTE_35` east side: CUT the tree at block (8, 3) (cells x16-17, y6-7).
    Pre: `ENGINE_HIVEBADGE` + a mon knowing CUT. Then battle Arnie at (16, 7) and
    Bryan at (14, 28), and take the item ball at (13, 16) -> `TM_ROLLOUT`
    (`EVENT_ROUTE_35_TM_ROLLOUT`). Talk to Arnie a second time for
    `PHONE_BUG_CATCHER_ARNIE`.
19. Return north to `MAP_ROUTE_36`. Battle Schoolboy Alan at (31, 14); talk again for
    `PHONE_SCHOOLBOY_ALAN`.
20. Walk to face `ROUTE36_WEIRD_TREE` at (35, 9) and press A. Pre: SQUIRTBOTTLE in the
    PACK (`checkitem`). Answer YES. A lv20 SUDOWOODO wild battle starts
    (`loadwildmon SUDOWOODO, 20`). Post: `EVENT_FOUGHT_SUDOWOODO` set regardless of
    outcome; `EVENT_ROUTE_36_SUDOWOODO` cleared, sprite swapped to `SPRITE_TWIN`.
21. Talk to `ROUTE36_FISHER` at (44, 9). Pre: `EVENT_FOUGHT_SUDOWOODO`, PACK room.
    Post: `EVENT_GOT_TM08_ROCK_SMASH`, TM08 ROCK SMASH.
22. Optional, Thursday only: talk to `ROUTE36_ARTHUR` at (46, 6). Post:
    `EVENT_MET_ARTHUR_OF_THURSDAY`, `EVENT_GOT_HARD_STONE_FROM_ARTHUR`, HARD STONE.
23. Continue east past x=59 on the `ROUTE_36` east connection into `MAP_VIOLET_CITY`
    (next section).

---

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map geometry, warps, bg/object events for all nine maps | `src/import/RomExtractorGen2.lua` (extracted into the cache), consumed by `src/world/gen2/World.lua` / `Map.lua` | implemented (data-driven; nothing map-specific is hand written) |
| Script bytecode for every label above (`FlowerShopTeacherScript`, `RandyScript`, `SudowoodoScript`, `Route36RockSmashGuyScript`, `ArthurScript`, both contest officers, `BugContestResultsScript`) | `src/script/gen2/Vm.lua` + extracted bytecode | implemented - the opcodes these scripts use (`checkevent`, `checkflag`, `checkitem`, `verbosegiveitem`, `givepoke`, `givepokemail`, `loadwildmon`, `variablesprite`, `appear`/`disappear`, `setscene`, `sdefer`, `askforphonenumber`, `checkcellnum`, `checktime`, `fruittree`) all have branches in `Vm.lua` / `Opcodes.lua` |
| `VAR_WEEKDAY` (Arthur, Sunny, contest days) | `src/world/gen2/World.lua:1201` `World:weekday`, `World.lua:101` `VAR_WEEKDAY = 0x0b` | implemented |
| `MAPCALLBACK_OBJECTS` day-of-week NPC swaps | `src/world/gen2/World.lua:5991` `World:runMapCallback`, called from `World.lua:5700` | implemented; assertion driver `tests/drivers/gold_map_callbacks.lua` exists but does **not** cover Route 36 / Route 37 / either park gate |
| Bug Catching Contest rules, timer, park balls, scoring, AI contestants, prizes | `src/core/gen2/BugContest.lua` (815 lines; transcribed from `bug_contest/judging.asm`, `contest.asm`, `contest_2.asm`, `caught_mon.asm`, `bug_contest_mons.asm`) | implemented - `BugContest.score`, `rollContestant`, `judge`, `prizeFor`, `pickContestants`, `dropOffMons`, `returnMons`, `start/stop/tickTimer`, `chooseWild` |
| Contest comparison / debug UI | `src/ui/gen2/ContestMenu.lua` | implemented (a comparison screen, not the cart's HUD) |
| Contest super-tall-grass doubled encounter rate | `src/world/gen2/Permissions.lua:85` `SUPER_TALL_GRASS`, `BugContest.encounterRate` | implemented |
| Squirtbottle field check | `src/script/gen2/CallAsm.lua:411` `H.CheckCanUseSquirtbottle` (registered as `"14:4786"`), tested in `tests/gen2_callasm_test.lua:224-244` | implemented |
| **Using the SQUIRTBOTTLE from the PACK** | `src/world/gen2/World.lua:3294` `World:useFieldItem` | **missing** - the dispatch has arms only for `ITEMFINDER`, `BICYCLE`, `SACRED_ASH`, repels, trophy boxes and rods. There is no `SQUIRTBOTTLE` arm, so `_Squirtbottle` is unreachable from the PACK. The talk-to-the-tree path (`SudowoodoScript`'s `checkitem`) still works, which is the route the walkthrough takes |
| **Item ball pickup** (TM04 on Route 35, TM28 DIG and PARLYZ HEAL in National Park) | extractor reads them (`src/import/RomExtractorGen2.lua:2969` `obj.itemball = readItemBall(...)`) but `src/world/gen2/World.lua:5257` `World:interact` only dispatches on `npc.def.trainer`, strength boulders, `npc.def.scriptKey`, bg events and hidden items | **missing** - `OBJECTTYPE_ITEMBALL` objects have no `scriptKey` by design, and nothing consumes `obj.itemball`. A bot cannot pick up any of this section's three item balls |
| Hidden item (National Park FULL HEAL, Route 37 ETHER) | `src/world/gen2/HiddenItems.lua`, wired into `World:interact` | implemented |
| Fruit trees (MYSTERYBERRY, ICE BERRY, the Route 37 apricorns) | `src/core/gen2/Apricorns.lua` + the VM's `fruittree` branch | implemented |
| Overworld trainers, sight ranges, `loadtrainer` / `startbattle` | `src/world/gen2/Trainers.lua`, `src/battle/gen2/Battle.lua` | implemented |
| Phone numbers and rematch tiers (Irwin, Arnie, Jack, Beverly, Alan) | `src/core/gen2/Phone.lua` (Jack, Beverly, Irwin, Arnie, Alan all have callee/caller script keys and `..._READY_FOR_REMATCH` event ids) | implemented |
| Kenya the SPEAROW + FLOWER MAIL | `src/core/gen2/Mail.lua` + `Vm.lua:439` `givepoke` / `Vm.lua:462` `givepokemail` | implemented (extractor resolves `cmd.mail`) |
| CUT field move + `ENGINE_HIVEBADGE` gate + the Route 35 tree block | `src/world/gen2/FieldMoves.lua:104` (`CUT = "HIVE"`), `FieldMoves.somethingToCut`, `World:tryCutOW` | implemented |
| Sudowoodo wild battle + DRAW-flee branch | `src/script/gen2/Vm.lua:44` (DRAW), `Vm.lua:836` `loadwildmon`, `World.lua:5067` (`variablesprite` with a raw sprite id) | implemented |
| Driver / regression coverage for this specific stretch | `tests/drivers/gold_*.lua` | **missing** - there is no driver that walks Route 35 -> National Park -> Route 36, runs a contest, or fights Sudowoodo. `tests/gen2_contest_test.lua` covers the contest rules headlessly; `tests/gen2_callasm_test.lua` covers only the Squirtbottle facing check |

---

## 6. Unresolved / verify by hand

1. **"Talk to Floria... while she goes away to get the Squirtbottle."** No such script
   exists in pokegold. `maps/GoldenrodFlowerShop.asm` has a `GOLDENRODFLOWERSHOP_FLORIA`
   object at (5, 6) whose `FlowerShopFloriaScript` only prints text, and the girl on
   Route 36 at (51, 8) is an anonymous `ROUTE36_LASS1` running `Route36LassScript`, which
   also only prints text. The SQUIRTBOTTLE comes from `FlowerShopTeacherScript` gated on
   `ENGINE_PLAINBADGE` alone, with no Route 36 precondition. The described sequence looks
   like Crystal behaviour that leaked into a Gold/Silver walkthrough.
2. **Contest Pokemon list.** The walkthrough lists "Caterpie/Weedle, Nincada, Scyther,
   Pinsir, Volbeat, Wurmple" at "Levels 28-31". `data/wild/bug_contest_mons.asm` has
   CATERPIE, WEEDLE, METAPOD, KAKUNA, BUTTERFREE, BEEDRILL, VENONAT, PARAS, SCYTHER,
   PINSIR at levels 7-18 (plus VENOMOTH 30-40 on the `-1` terminator row, which is never
   selected). NINCADA, VOLBEAT and WURMPLE do not exist in Gen 2 at all. Treat the
   walkthrough's list and levels as wrong for this game.
3. **"20 Sport Balls."** The item is `PARK_BALL` (`constants/item_constants.asm:185`),
   given by `special GiveParkBalls`, count `BUG_CONTEST_BALLS = 20`. "Sport Ball" is the
   Gen 3+ name.
4. **"If you win the contest, you can win a Shiny Stone!"** First place gives `SUN_STONE`
   (`BugContestResults_FirstPlace`, `engine/events/std_scripts.asm:346`). The
   walkthrough's own item list ("Sun Stone (1st Prize)") agrees; the prose line does not.
   There is no Shiny Stone in Gen 2.
5. **"If you catch a Scyther at full HP, it may be worth around 342 points."** Not
   verifiable from the asm without a concrete mon: `ContestScore` (`04:7cbc`) is
   `MaxHP*4 + Atk + Def + Spe + SpA + SpD + DVbonus + HP/8 + heldItem`, all taken from the
   high byte of each stat word. The walkthrough's qualitative claim ("score takes HP into
   consideration") is confirmed; the specific number is not checked here.
6. **National Park species list.** The walkthrough lists Butterfree, Weedle, Kakuna,
   Beedrill, Paras, Venonat, Scyther and Pinsir as "found in National Park". None of them
   appear in `def_grass_wildmons NATIONAL_PARK`; they are Contest-only
   (`data/wild/bug_contest_mons.asm`). Sunkern, Caterpie, Metapod, Pidgey and Hoothoot are
   the only real National Park grass encounters in Gold.
7. **"Routes 36 & 37" item and species lists are merged.** Everything the walkthrough
   attributes to "Routes 36 & 37" except the ICE BERRY, HARD STONE and TM08 actually lives
   on Route 37 (`RED_APRICORN`, `BLU_APRICORN`, `BLK_APRICORN`; Ledyba/Spinarak/Pidgeotto),
   which this section never enters. Vulpix/Growlithe and Stantler appear on both routes.
8. **"Route 35 & National Park" item list omits the hidden FULL HEAL** at National Park
   bg (6, 47) and lists no hidden items at all. Not a contradiction, just incomplete.
9. **"Head back to Arnie and talk to *her*."** `BUG_CATCHER, ARNIE1` uses the male phone
   std scripts (`AskNumber1MScript`, `RegisteredNumberMScript`). Cosmetic only.
10. **"Then, we're ready to head into Route 35 after Liz's offer for a rematch on Route
    32."** Liz's rematch is a phone event outside this section's maps; no code on any map
    in this section references it, so it was not resolved here.
11. **`EVENT_FOUGHT_SUDOWOODO` is set before the DRAW check** in
    `WateredWeirdTreeScript`, and both the win branch and `DidntCatchSudowoodo` run
    `disappear ROUTE36_WEIRD_TREE`. So the walkthrough's "catch it or else" is a
    preference, not a gate - fainting or fleeing still opens the road and still unlocks
    TM08. Worth confirming in-game that a *black-out* mid-battle does not leave a
    half-applied state, which the asm alone cannot answer.
12. **`MAP_NATIONAL_PARK_BUG_CONTEST` warps 2 and 4 point at destination warp 1**, not 2,
    in `maps/NationalParkBugContest.asm:228,230`. Transcribed verbatim; a bot pathing off
    those rows should expect the asymmetry rather than assume a typo.

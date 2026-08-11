# Section 08 - Olivine Lighthouse and Cianwood City Gym

Source: `../section-08-olivine-lighthouse-and-cianwood-city-gym.txt`

Maps covered: `MAP_ROUTE_38_ECRUTEAK_GATE`, `MAP_ROUTE_38`, `MAP_ROUTE_39`,
`MAP_ROUTE_39_BARN`, `MAP_ROUTE_39_FARMHOUSE`, `MAP_OLIVINE_CITY`,
`MAP_OLIVINE_POKECENTER_1F`, `MAP_OLIVINE_GOOD_ROD_HOUSE`, `MAP_OLIVINE_CAFE`,
`MAP_OLIVINE_MART`, `MAP_OLIVINE_LIGHTHOUSE_1F` .. `MAP_OLIVINE_LIGHTHOUSE_6F`,
`MAP_ROUTE_40`, `MAP_ROUTE_41`, `MAP_CIANWOOD_CITY`, `MAP_MANIAS_HOUSE`,
`MAP_CIANWOOD_PHARMACY`, `MAP_CIANWOOD_PHOTO_STUDIO`,
`MAP_CIANWOOD_POKECENTER_1F`, `MAP_CIANWOOD_LUGIA_SPEECH_HOUSE`,
`MAP_CIANWOOD_GYM`

Badges / key milestones in this section: **Storm Badge** (`ENGINE_STORMBADGE`,
badge 5, from `CianwoodGymChuckScript`). Other milestones, in the order the
walkthrough hits them: `EVENT_GOT_GOOD_ROD`, `EVENT_GOT_HM04_STRENGTH`
(HM04 = the Cianwood Gym boulder puzzle and every later Strength rock),
`EVENT_JASMINE_EXPLAINED_AMPHYS_SICKNESS` (the flag that unlocks the Cianwood
pharmacist), `EVENT_GOT_SHUCKIE`, `EVENT_GOT_SECRETPOTION_FROM_PHARMACY`,
`EVENT_BEAT_CHUCK`, `EVENT_GOT_TM01_DYNAMICPUNCH`, `EVENT_GOT_HM02_FLY`, and
the two fly-point engine flags `ENGINE_FLYPOINT_OLIVINE` /
`ENGINE_FLYPOINT_CIANWOOD`.

Coordinate note: every `warp_event` / `coord_event` / `bg_event` /
`object_event` x,y below is copied verbatim from the map asm. Those are 0-based
walk-grid cells (2 per map block, so a `W`-block-wide map runs x = 0..2W-1),
the same grid `src/world/gen2/Map.lua` calls a cell.

---

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 1 | `MAP_ROUTE_38_ECRUTEAK_GATE` | `maps/Route38EcruteakGate.asm` | warp 3/4 at (9,4)/(9,5) from `ECRUTEAK_CITY` warps 14/15 | warp 1/2 at (0,4)/(0,5) | "Well, go through the building into Route 38" |
| 2 | `MAP_ROUTE_38` | `maps/Route38.asm` | warp 1/2 at (35,8)/(35,9) | west connection to `ROUTE_39` (`data/maps/attributes.asm:215`) | "You're heading west. There are trainers" - Toby, Harry, Dana, Valerie, Chad, plus the Berry tree |
| 3 | `MAP_ROUTE_39` | `maps/Route39.asm` | east connection from `ROUTE_38` | south connection to `OLIVINE_CITY` (`data/maps/attributes.asm:219`) | "Welcome to Route 39! It's the home of Moo Moo Farm" - Norman, Derek, Ruth, Eugene, Mint Berry |
| 3a | `MAP_ROUTE_39_BARN` | `maps/Route39Barn.asm` | Route 39 warp 1 at (1,3) | warp 1/2 at (3,7)/(4,7) | "you will first have to feed berries to their Miltank" |
| 3b | `MAP_ROUTE_39_FARMHOUSE` | `maps/Route39Farmhouse.asm` | Route 39 warp 2 at (5,3) | warp 1/2 at (2,7)/(3,7) | Moomoo Milk at 500 gold; TM13 SNORE once the Miltank is healed |
| 4 | `MAP_OLIVINE_CITY` | `maps/OlivineCity.asm` | north connection from `ROUTE_39` (`data/maps/attributes.asm:143`) | warp 9 at (29,27) | "As soon as you enter Olivine City and, when you are about to pass by the gym your rival will appear" - `coord_event` at (13,12)/(13,13) |
| 4a | `MAP_OLIVINE_GOOD_ROD_HOUSE` | `maps/OlivineGoodRodHouse.asm` | Olivine warp 6 at (13,15) | warp 1/2 at (2,7)/(3,7) | "Talk to the fisherman and he will give you a Good Rod" |
| 4b | `MAP_OLIVINE_POKECENTER_1F` | `maps/OlivinePokecenter1F.asm` | Olivine warp 1 at (13,21) | warp 1/2 at (3,7)/(4,7) | "Then heal at the Pokémon Center" |
| 4c | `MAP_OLIVINE_CAFE` | `maps/OlivineCafe.asm` | Olivine warp 7 at (7,21) | warp 1/2 at (2,7)/(3,7) | "talk to the sailor at the table for HM04 Strength!" |
| 5 | `MAP_OLIVINE_LIGHTHOUSE_1F` | `maps/OlivineLighthouse1F.asm` | Olivine warp 9 at (29,27) | warp 3 at (3,11) | "go up the Olivine City Lighthouse in the southeast part of town (not the dock)" |
| 6 | `MAP_OLIVINE_LIGHTHOUSE_2F` | `maps/OlivineLighthouse2F.asm` | warp 1 at (3,11) | warp 2 at (5,3) | Gentleman Alfred, Sailor Huey |
| 7 | `MAP_OLIVINE_LIGHTHOUSE_3F` | `maps/OlivineLighthouse3F.asm` | warp 2 at (5,3) | warp 1 at (13,3) | Bird Keeper Theo, Gentleman Preston, Ether |
| 8 | `MAP_OLIVINE_LIGHTHOUSE_4F` | `maps/OlivineLighthouse4F.asm` | warp 1 at (13,3) | warp 2 at (3,5) | Lass Connie, Sailor Kent, "hole next to Lass Connie" = warps 7/8 at (8,3)/(9,3) |
| 9 | `MAP_OLIVINE_LIGHTHOUSE_5F` | `maps/OlivineLighthouse5F.asm` | warp 2 at (3,5) | warp 1 at (9,15) | TM34 Swagger, Rare Candy, Great Ball, Bird Keeper Denis, Sailor Ernest |
| 10 | `MAP_OLIVINE_LIGHTHOUSE_6F` | `maps/OlivineLighthouse6F.asm` | warp 1 at (9,15) | warps 2/3 at (16,5)/(17,5) - the right-wall drop chain | "Talk to the person on that level, and it is Gym Leader Jasmine" |
| 11 | `MAP_OLIVINE_CITY` | `maps/OlivineCity.asm` | lighthouse 1F warps 1/2 at (10,17)/(11,17) | west connection to `ROUTE_40` (`data/maps/attributes.asm:145`) | heal, restock at the Mart (warp 8 at (19,17)), teach HM03 Surf |
| 12 | `MAP_ROUTE_40` | `maps/Route40.asm` | east connection from `OLIVINE_CITY` | south connection to `ROUTE_41` (`data/maps/attributes.asm:223`) | "activate Surf by clicking A at the water" - Simon, Elaine, Paula, Randall |
| 13 | `MAP_ROUTE_41` | `maps/Route41.asm` | north connection from `ROUTE_40` | west connection to `CIANWOOD_CITY` (`data/maps/attributes.asm:227`) | the nine open-sea swimmers; the four Whirl Islands warps are optional detours |
| 14 | `MAP_CIANWOOD_CITY` | `maps/CianwoodCity.asm` | east connection from `ROUTE_41` (`data/maps/attributes.asm:136`) | warp 2 at (8,43) | "You will reach land after that battle. Welcome to Cianwood City." |
| 14a | `MAP_CIANWOOD_POKECENTER_1F` | `maps/CianwoodPokecenter1F.asm` | Cianwood warp 3 at (23,43) | warp 1/2 at (3,7)/(4,7) | "Heal at the Pokémon Center and clear a space so you can acquire another Pokémon" |
| 14b | `MAP_MANIAS_HOUSE` | `maps/ManiasHouse.asm` | Cianwood warp 1 at (17,41) | warp 1/2 at (2,7)/(3,7) | "a PokeManiac will give you Level 15 Shuckie the Shuckle" |
| 14c | `MAP_CIANWOOD_PHARMACY` | `maps/CianwoodPharmacy.asm` | Cianwood warp 4 at (15,47) | warp 1/2 at (2,7)/(3,7) | "It's the Pharmacy. A guy inside the house, wearing sunglasses will give you some medicine" |
| 14d | `MAP_CIANWOOD_PHOTO_STUDIO` | `maps/CianwoodPhotoStudio.asm` | Cianwood warp 5 at (9,31) | warp 1/2 at (2,7)/(3,7) | "he will offer to take pictures of your Pokémon" (optional) |
| 15 | `MAP_CIANWOOD_GYM` | `maps/CianwoodGym.asm` | Cianwood warp 2 at (8,43) | warp 1/2 at (4,17)/(5,17) | "face Chuck, the fighting gym leader" -> Storm Badge + TM01 |
| 16 | `MAP_CIANWOOD_CITY` | `maps/CianwoodCity.asm` | gym warp 1/2 | (section ends) | "Talk to the lady outside the gym and she will give you HM02 Fly" |

Spills into the next section: the walkthrough's last line, "You'll want to
return to Olivine now so that you can give the medicine to Jasmine and the
Ampharos", starts the Olivine Gym / `MAP_OLIVINE_GYM` beat. The Secretpotion
hand-off itself is `OlivineLighthouseJasmine` on `MAP_OLIVINE_LIGHTHOUSE_6F`
(documented below, because the flag it clears is what makes Jasmine appear in
the gym), but the gym fight belongs to section 09. Likewise the walkthrough's
"Items found in Olivine City: … TM23" is Jasmine's TM in `maps/OlivineGym.asm`,
not anything reachable on `MAP_OLIVINE_CITY`.

## 2. Maps

### MAP_ROUTE_38_ECRUTEAK_GATE

- Script: `maps/Route38EcruteakGate.asm`
- Blocks: none (no `.blk`; gate maps share `TILESET_GATE` layout)
- Header (`data/maps/maps.asm:58`): `map Route38EcruteakGate, TILESET_GATE, GATE, LANDMARK_ROUTE_38, MUSIC_ROUTE_37, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:47`): `map_const ROUTE_38_ECRUTEAK_GATE, 5, 4` (5x4 blocks = 10x8 cells)
- Attributes (`data/maps/attributes.asm:480`): no connections
- Scene var: none (empty `def_scene_scripts`)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 0 | 4 | `ROUTE_38` | 1 |
| 2 | 0 | 5 | `ROUTE_38` | 2 |
| 3 | 9 | 4 | `ECRUTEAK_CITY` | 14 |
| 4 | 9 | 5 | `ECRUTEAK_CITY` | 15 |

**Coord events** - none.

**BG events** - none.

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE38ECRUTEAKGATE_OFFICER` | `SPRITE_OFFICER` | 5 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `Route38EcruteakGateOfficerScript` | -1 |

The officer is `jumptextfaceplayer` only. Nothing here blocks passage.

---

### MAP_ROUTE_38

- Script: `maps/Route38.asm`
- Blocks: `maps/Route38.blk`
- Header (`data/maps/maps.asm:61`): `map Route38, TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_38, MUSIC_ROUTE_37, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:50`): `map_const ROUTE_38, 20, 9` (40x18 cells)
- Connections (`data/maps/attributes.asm:215`): west `Route39` / `ROUTE_39` offset 0; east `EcruteakCity` / `ECRUTEAK_CITY` offset -5
- Scene var: none

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 35 | 8 | `ROUTE_38_ECRUTEAK_GATE` | 1 |
| 2 | 35 | 9 | `ROUTE_38_ECRUTEAK_GATE` | 2 |

**Coord events** - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 33 | 7 | `BGEVENT_READ` | `Route38Sign` |
| 5 | 13 | `BGEVENT_READ` | `Route38TrainerTips` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `ROUTE38_STANDING_YOUNGSTER1` | `SPRITE_YOUNGSTER` | 4 | 1 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSchoolboyChad1` | -1 |
| `ROUTE38_LASS` | `SPRITE_LASS` | 15 | 3 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 2 | `TrainerLassDana1` | -1 |
| `ROUTE38_STANDING_YOUNGSTER2` | `SPRITE_YOUNGSTER` | 15 | 10 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 2 | `TrainerBirdKeeperToby` | -1 |
| `ROUTE38_BEAUTY` | `SPRITE_BEAUTY` | 9 | 6 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER` | 2 | `TrainerBeautyValerie` | -1 |
| `ROUTE38_SAILOR` | `SPRITE_SAILOR` | 25 | 5 | `SPRITEMOVEDATA_SPINCLOCKWISE` | `OBJECTTYPE_TRAINER` | 2 | `TrainerSailorHarry` | -1 |
| `ROUTE38_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 12 | 10 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | 0 | `Route38FruitTree` | -1 |

**Scripts of interest**

- `Route38FruitTree`: single opcode `fruittree FRUITTREE_ROUTE_38`.
  `data/items/fruit_trees.asm:6` maps that index to `BERRY`. This is the
  walkthrough's "Go left and you'll get a Berry".
- `TrainerLassDana1.Script`: after the win it runs the standard phone-number
  offer. `checkevent EVENT_DANA_READY_FOR_REMATCH` -> rematch arm;
  `checkcellnum PHONE_LASS_DANA` -> already registered; otherwise it prints
  `LassDanaMoomooMilkText`, sets `EVENT_DANA_ASKED_FOR_PHONE_NUMBER`, and calls
  `askforphonenumber PHONE_LASS_DANA`. The rematch arm picks the party by
  progress: `checkevent EVENT_CLEARED_RADIO_TOWER` -> `LASS, DANA3`, else
  `checkflag ENGINE_FLYPOINT_CIANWOOD` -> `LASS, DANA2`, else `LASS, DANA1`.
  Note that flag: the moment a bot walks into Cianwood in this section, Dana's
  rematch upgrades to `DANA2`.
- `TrainerSchoolboyChad1.Script`: same shape, `PHONE_SCHOOLBOY_CHAD`, rematch
  tier keyed on `EVENT_CLEARED_RADIO_TOWER` -> `CHAD3`, else
  `checkflag ENGINE_FLYPOINT_MAHOGANY` -> `CHAD2`, else `CHAD1`.
- Toby, Valerie and Harry are plain `endifjustbattled / opentext / writetext /
  waitbutton / closetext / end` after-battle scripts. No flags beyond their own
  `EVENT_BEAT_*`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_BIRD_KEEPER_TOBY` | `constants/event_flags.asm` (via `trainer` macro) | `TrainerBirdKeeperToby` | set on win; suppresses the sight-range trigger |
| `EVENT_BEAT_SAILOR_HARRY` | as above | `TrainerSailorHarry` | as above |
| `EVENT_BEAT_LASS_DANA` | as above | `TrainerLassDana1` | as above |
| `EVENT_BEAT_SCHOOLBOY_CHAD` | as above | `TrainerSchoolboyChad1` | as above |
| `EVENT_BEAT_BEAUTY_VALERIE` | as above | `TrainerBeautyValerie` | as above |
| `EVENT_DANA_ASKED_FOR_PHONE_NUMBER` | `constants/event_flags.asm` | `TrainerLassDana1.Script` | second-ask text branch |
| `EVENT_DANA_READY_FOR_REMATCH` | `constants/event_flags.asm` | set by the phone (`src/core/gen2/Phone.lua` mirrors `data/phone/`), cleared by `.DanaRematch` | rematch gate |
| `EVENT_CHAD_ASKED_FOR_PHONE_NUMBER` / `EVENT_CHAD_READY_FOR_REMATCH` | `constants/event_flags.asm` | `TrainerSchoolboyChad1.Script` | as above |
| `ENGINE_FLYPOINT_CIANWOOD` | `constants/engine_flags.asm:83` | set by `CianwoodCityFlypointCallback`, read by `.DanaRematch` | rematch tier switch |
| `ENGINE_FLYPOINT_MAHOGANY` | `constants/engine_flags.asm` | read by `.ChadRematch` | rematch tier switch |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `BERRY` | headbutt-free fruit tree, press A facing it | `Route38FruitTree` / `FRUITTREE_ROUTE_38` (`data/items/fruit_trees.asm:6`) | none - refreshes daily (`engine/events/fruit_trees.asm`) |

**Trainers**

| const | class | id | party (`data/trainers/parties.asm`) | script label | rematch/phone |
|---|---|---|---|---|---|
| `TOBY` | `BIRD_KEEPER` | 5 | `BirdKeeperGroup` "TOBY", `TRAINERTYPE_NORMAL`: 15 DODUO, 16 DODUO, 17 DODUO | `TrainerBirdKeeperToby` | no |
| `HARRY` | `SAILOR` | 10 | `SailorGroup` "HARRY", `TRAINERTYPE_NORMAL`: 19 WOOPER | `TrainerSailorHarry` | no |
| `DANA1` | `LASS` | 10 | `LassGroup` "DANA", `TRAINERTYPE_MOVES`: 18 FLAAFFY (TACKLE, GROWL, THUNDERSHOCK, THUNDER_WAVE), 18 PSYDUCK (SCRATCH, TAIL_WHIP, DISABLE, CONFUSION) | `TrainerLassDana1` | `PHONE_LASS_DANA`; `DANA2` = LASS 14 (21 FLAAFFY / 21 PSYDUCK), `DANA3` = LASS 15 (29 PSYDUCK / 29 AMPHAROS) |
| `VALERIE` | `BEAUTY` | 16 | `BeautyGroup` "VALERIE", `TRAINERTYPE_MOVES`: 17 HOPPIP (SYNTHESIS, TAIL_WHIP, TACKLE, POISONPOWDER), 17 SKIPLOOM (SYNTHESIS, TAIL_WHIP, TACKLE, STUN_SPORE) | `TrainerBeautyValerie` | no |
| `CHAD1` | `SCHOOLBOY` | 10 | `SchoolboyGroup` "CHAD", `TRAINERTYPE_NORMAL`: 19 MR__MIME | `TrainerSchoolboyChad1` | `PHONE_SCHOOLBOY_CHAD`; `CHAD2` = SCHOOLBOY 17, `CHAD3` = SCHOOLBOY 18 |

**Wild encounters**

`data/wild/johto_grass.asm:2014`, `def_grass_wildmons ROUTE_38`, rates
`10 percent, 10 percent, 10 percent` (morn/day/nite). Gold build
(`IF DEF(_GOLD)`):

- morn and day, in slot order: 16 RATTATA, 16 RATICATE, 16 MAGNEMITE,
  16 FARFETCH_D, 13 MILTANK, 13 TAUROS, 13 SNUBBULL
- nite: identical except slot 4 is 16 RATTATA instead of FARFETCH_D

Silver swaps RATTATA for MEOWTH in slots 1 and (at night) 4. Headbutt:
`data/wild/treemon_maps.asm:19` `treemon_map ROUTE_38, TREEMON_SET_FOREST`.

---

### MAP_ROUTE_39

- Script: `maps/Route39.asm`
- Blocks: `maps/Route39.blk`
- Header (`data/maps/maps.asm:62`): `map Route39, TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_39, MUSIC_ROUTE_37, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:51`): `map_const ROUTE_39, 10, 18` (20x36 cells)
- Connections (`data/maps/attributes.asm:219`): south `OlivineCity` / `OLIVINE_CITY` offset -5; east `Route38` / `ROUTE_38` offset 0
- Scene var: none

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 1 | 3 | `ROUTE_39_BARN` | 1 |
| 2 | 5 | 3 | `ROUTE_39_FARMHOUSE` | 1 |

**Coord events** - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 5 | 31 | `BGEVENT_READ` | `Route39TrainerTips` |
| 9 | 5 | `BGEVENT_READ` | `MoomooFarmSign` |
| 15 | 7 | `BGEVENT_READ` | `Route39Sign` |
| 5 | 13 | `BGEVENT_ITEM` | `Route39HiddenNugget` -> `hiddenitem NUGGET, EVENT_ROUTE_39_HIDDEN_NUGGET` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `ROUTE39_SAILOR` | `SPRITE_SAILOR` | 13 | 29 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 5 | `TrainerSailorEugene` | -1 |
| `ROUTE39_POKEFAN_M` | `SPRITE_POKEFAN_M` | 11 | 19 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 4 | `TrainerPokefanmDerek` | -1 |
| `ROUTE39_POKEFAN_F` | `SPRITE_POKEFAN_F` | 13 | 22 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 5 | `TrainerPokefanfRuth` | -1 |
| `ROUTE39_MILTANK1` | `SPRITE_TAUROS` | 3 | 12 | `SPRITEMOVEDATA_POKEMON` | `OBJECTTYPE_SCRIPT` | 0 | `Route39Miltank` | -1 |
| `ROUTE39_MILTANK2` | `SPRITE_TAUROS` | 6 | 11 | `SPRITEMOVEDATA_POKEMON` | `OBJECTTYPE_SCRIPT` | 0 | `Route39Miltank` | -1 |
| `ROUTE39_MILTANK3` | `SPRITE_TAUROS` | 4 | 15 | `SPRITEMOVEDATA_POKEMON` | `OBJECTTYPE_SCRIPT` | 0 | `Route39Miltank` | -1 |
| `ROUTE39_MILTANK4` | `SPRITE_TAUROS` | 8 | 13 | `SPRITEMOVEDATA_POKEMON` | `OBJECTTYPE_SCRIPT` | 0 | `Route39Miltank` | -1 |
| `ROUTE39_PSYCHIC_NORMAN` | `SPRITE_YOUNGSTER` | 13 | 6 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 3 | `TrainerPsychicNorman` | -1 |
| `ROUTE39_FRUIT_TREE` | `SPRITE_FRUIT_TREE` | 9 | 3 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_SCRIPT` | 0 | `Route39FruitTree` | -1 |

**Scripts of interest**

- `Route39FruitTree`: `fruittree FRUITTREE_ROUTE_39` ->
  `data/items/fruit_trees.asm:18` = `MINT_BERRY`. This is the walkthrough's
  "grab the Mint Berry".
- `TrainerPokefanmDerek.Script`: phone registration for
  `PHONE_POKEFANM_DEREK`; rematch tier is `EVENT_BEAT_ELITE_FOUR` -> `DEREK3`,
  else `checkflag ENGINE_FLYPOINT_LAKE_OF_RAGE` -> `DEREK2`, else `DEREK1`.
- Ruth, Eugene and Norman are plain after-battle scripts.

**Flags and events** - trainer `EVENT_BEAT_*` bits plus
`EVENT_ROUTE_39_HIDDEN_NUGGET` (`constants/event_flags.asm:180`),
`EVENT_DEREK_ASKED_FOR_PHONE_NUMBER` / `EVENT_DEREK_READY_FOR_REMATCH`.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `MINT_BERRY` | fruit tree at (9,3) | `Route39FruitTree` | none (daily) |
| `NUGGET` | hidden, stand on/face (5,13) and press A | `Route39HiddenNugget` bg_event | `EVENT_ROUTE_39_HIDDEN_NUGGET` |

The walkthrough does not mention the Nugget.

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `NORMAN` | `PSYCHIC_T` | 6 | `PsychicGroup` "NORMAN", `TRAINERTYPE_MOVES`: 17 SLOWPOKE (TACKLE, GROWL, WATER_GUN, -), 20 SLOWPOKE (CURSE, BODY_SLAM, WATER_GUN, CONFUSION) | `TrainerPsychicNorman` | no |
| `DEREK1` | `POKEFANM` | 2 | `PokefanMGroup` "DEREK", `TRAINERTYPE_ITEM`: 17 PIKACHU holding BERRY | `TrainerPokefanmDerek` | `PHONE_POKEFANM_DEREK`; `DEREK2` = POKEFANM 10 (19 PIKACHU/BERRY), `DEREK3` = POKEFANM 11 (36 PIKACHU/BERRY) |
| `RUTH` | `POKEFANF` | 2 | `PokefanFGroup` "RUTH", `TRAINERTYPE_ITEM`: 17 PIKACHU holding BERRY | `TrainerPokefanfRuth` | no |
| `EUGENE` | `SAILOR` | 1 | `SailorGroup` "EUGENE", `TRAINERTYPE_NORMAL`: 17 POLIWHIRL, 17 RATICATE, 19 KRABBY | `TrainerSailorEugene` | no |

**Wild encounters**

`data/wild/johto_grass.asm:2069`, `def_grass_wildmons ROUTE_39`. Gold rates are
`2 percent, 2 percent, 10 percent` (Silver: 2/2/2 - Gold gets a much higher
night rate here).

- morn and day: 16 RATTATA, 17 RATICATE, 16 MAGNEMITE, 16 FARFETCH_D,
  15 MILTANK, 15 TAUROS, 15 TAUROS
- nite: slot 4 becomes 16 RATTATA

Headbutt: `data/wild/treemon_maps.asm:20` `TREEMON_SET_FOREST`.

---

### MAP_ROUTE_39_BARN

- Script: `maps/Route39Barn.asm`
- Blocks: `maps/Route39Barn.blk`
- Header (`data/maps/maps.asm:59`): `map Route39Barn, TILESET_TRADITIONAL_HOUSE, INDOOR, LANDMARK_ROUTE_39, MUSIC_ECRUTEAK_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:48`): `map_const ROUTE_39_BARN, 4, 4`
- Connections (`data/maps/attributes.asm:481`): none

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `ROUTE_39` | 1 |
| 2 | 4 | 7 | `ROUTE_39` | 1 |

**Coord events / BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE39BARN_TWIN1` | `SPRITE_TWIN` | 2 | 3 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT` | `Route39BarnTwin1Script` | -1 |
| `ROUTE39BARN_TWIN2` | `SPRITE_TWIN` | 4 | 3 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `Route39BarnTwin2Script` | -1 |
| `ROUTE39BARN_MOOMOO` | `SPRITE_TAUROS` | 3 | 3 | `SPRITEMOVEDATA_POKEMON` | `OBJECTTYPE_SCRIPT` | `MoomooScript` | -1 |

**Scripts of interest**

- `MoomooScript` (`pokegold.sym` 51:4c80). Control flow, verbatim from the
  opcodes:
  1. `checkevent EVENT_HEALED_MOOMOO` -> `.HappyCow` (just a cry) if set.
  2. Otherwise print `MoomooWeakMooText`, `setval MILTANK`,
     `special PlaySlowCry`, print `Route39BarnItsCryIsWeakText`.
  3. `checkevent EVENT_TALKED_TO_FARMER_ABOUT_MOOMOO` -> `.GiveBerry`.
     **This is the gate.** Until you have talked to
     `PokefanM_DairyFarmer` in the farmhouse, the Miltank will not accept a
     Berry at all.
  4. `.GiveBerry`: `yesorno`, `checkitem BERRY`, `takeitem BERRY`,
     `readmem wMooMooBerries`, `addval 1`, `writemem wMooMooBerries`, then
     `ifequal 3` / `ifequal 5` / `ifequal 7` for the three progress texts.
     At **7** berries it plays `MUSIC_HEAL` and
     `setevent EVENT_HEALED_MOOMOO`.
- `Route39BarnTwin1Script` / `Route39BarnTwin2Script`: text only, branch on
  `EVENT_HEALED_MOOMOO`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_TALKED_TO_FARMER_ABOUT_MOOMOO` | `constants/event_flags.asm:72` | set by `PokefanM_DairyFarmer`, read by `MoomooScript` | must be set before any Berry is accepted |
| `EVENT_HEALED_MOOMOO` | `constants/event_flags.asm:70` | set by `MoomooScript.SevenBerries` | unlocks Moomoo Milk sales and TM13 |
| `wMooMooBerries` | WRAM counter, written via `writemem` | `MoomooScript` | 0..7; 7 is the finish line |

---

### MAP_ROUTE_39_FARMHOUSE

- Script: `maps/Route39Farmhouse.asm`
- Blocks: none
- Header (`data/maps/maps.asm:60`): `map Route39Farmhouse, TILESET_HOUSE, INDOOR, LANDMARK_ROUTE_39, MUSIC_ECRUTEAK_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:49`): `map_const ROUTE_39_FARMHOUSE, 4, 4`
- Connections (`data/maps/attributes.asm:482`): none

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 2 | 7 | `ROUTE_39` | 2 |
| 2 | 3 | 7 | `ROUTE_39` | 2 |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `FarmhouseBookshelf` |
| 1 | 1 | `BGEVENT_READ` | `FarmhouseBookshelf` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE39FARMHOUSE_POKEFAN_M` | `SPRITE_POKEFAN_M` | 3 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `PokefanM_DairyFarmer` | -1 |
| `ROUTE39FARMHOUSE_POKEFAN_F` | `SPRITE_POKEFAN_F` | 5 | 4 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `PokefanF_SnoreFarmer` | -1 |

**Scripts of interest**

- `PokefanM_DairyFarmer`: `checkevent EVENT_HEALED_MOOMOO` -> the Moomoo Milk
  shop (`FarmerMScript_SellMilk`). Otherwise prints `FarmerMText_SickCow` and
  `setevent EVENT_TALKED_TO_FARMER_ABOUT_MOOMOO`. **Talk to him before going to
  the barn.**
- `FarmerMScript_SellMilk`: `checkitem MOOMOO_MILK` -> refuse if you already
  hold one; else `yesorno`, `checkmoney YOUR_MONEY, 500`
  (`DEF ROUTE39FARMHOUSE_MILK_PRICE EQU 500` at line 1),
  `giveitem MOOMOO_MILK`, `takemoney YOUR_MONEY, 500`. One at a time.
- `PokefanF_SnoreFarmer` (`pokegold.sym` 51:4ee3):
  `checkevent EVENT_GOT_TM13_SNORE_FROM_MOOMOO_FARM` -> speech only;
  `checkevent EVENT_HEALED_MOOMOO` -> `verbosegiveitem TM_SNORE` then
  `setevent EVENT_GOT_TM13_SNORE_FROM_MOOMOO_FARM`.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `TM_SNORE` (TM13) | talk to `ROUTE39FARMHOUSE_POKEFAN_F` after `EVENT_HEALED_MOOMOO` | `FarmerFScript_GiveSnore` | `EVENT_GOT_TM13_SNORE_FROM_MOOMOO_FARM` (`constants/event_flags.asm:71`) |
| `MOOMOO_MILK` | buy for 500 from `ROUTE39FARMHOUSE_POKEFAN_M` after `EVENT_HEALED_MOOMOO` | `FarmerMScript_SellMilk` | repeatable, but only one in the bag at a time |

---

### MAP_OLIVINE_CITY

- Script: `maps/OlivineCity.asm`
- Blocks: `maps/OlivineCity.blk`
- Header (`data/maps/maps.asm:63`): `map OlivineCity, TILESET_JOHTO, TOWN, LANDMARK_OLIVINE_CITY, MUSIC_VIOLET_CITY, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:52`): `map_const OLIVINE_CITY, 20, 18` (40x36 cells)
- Connections (`data/maps/attributes.asm:143`): north `Route39` / `ROUTE_39` offset 5; west `Route40` / `ROUTE_40` offset 9
- Scene var: `wOlivineCitySceneID` (`data/maps/scenes.asm:40`). Scene ids come
  from the map's own `def_scene_scripts` block: `SCENE_OLIVINECITY_RIVAL_ENCOUNTER`
  = 0 (the default on a new game), `SCENE_OLIVINECITY_NOOP` = 1.
- Spawn (`data/maps/spawn_points.asm:34`): `spawn OLIVINE_CITY, 13, 22`.
  Fly point `LANDMARK_OLIVINE_CITY` -> `SPAWN_OLIVINE` (`data/maps/flypoints.asm:11`).

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
| `SCENE_OLIVINECITY_RIVAL_ENCOUNTER` (0) | 13 | 12 | `OlivineCityRivalSceneTop` | rival cut-scene, north variant |
| `SCENE_OLIVINECITY_RIVAL_ENCOUNTER` (0) | 13 | 13 | `OlivineCityRivalSceneBottom` | rival cut-scene, south variant |

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 17 | 11 | `BGEVENT_READ` | `OlivineCitySign` |
| 20 | 24 | `BGEVENT_READ` | `OlivineCityPortSign` |
| 7 | 11 | `BGEVENT_READ` | `OlivineGymSign` |
| 30 | 28 | `BGEVENT_READ` | `OlivineLighthouseSign` |
| 14 | 21 | `BGEVENT_READ` | `OlivineCityPokecenterSign` |
| 20 | 17 | `BGEVENT_READ` | `OlivineCityMartSign` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `OLIVINECITY_SAILOR1` | `SPRITE_SAILOR` | 26 | 27 | `SPRITEMOVEDATA_WALK_UP_DOWN` (radius 0,1) | `OBJECTTYPE_SCRIPT` | `OlivineCitySailor1Script` | -1 |
| `OLIVINECITY_STANDING_YOUNGSTER` | `SPRITE_YOUNGSTER` | 20 | 13 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius 1,0) | `OBJECTTYPE_SCRIPT` | `OlivineCityStandingYoungsterScript` | -1 |
| `OLIVINECITY_SAILOR2` | `SPRITE_SAILOR` | 17 | 21 | `SPRITEMOVEDATA_WANDER` (radius 1,1) | `OBJECTTYPE_SCRIPT` | `OlivineCitySailor2Script` | -1 |
| `OLIVINECITY_OLIVINE_RIVAL` | `SPRITE_OLIVINE_RIVAL` | 10 | 11 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `ObjectEvent` | `EVENT_RIVAL_OLIVINE_CITY` |

The rival object sits on the gym door tile and is **masked** while
`EVENT_RIVAL_OLIVINE_CITY` is set (`CheckObjectFlag`,
`engine/overworld/map_objects_2.asm:32` - a set flag hides the object).
`InitializeEventsScript` sets it on a new game
(`engine/events/std_scripts.asm:520`), so the rival is invisible until the
scene's `appear` clears it.

**Scripts of interest**

- `OlivineCityFlypointCallback` (`callback MAPCALLBACK_NEWMAP`,
  `pokegold.sym` 49:400f): a single `setflag ENGINE_FLYPOINT_OLIVINE`.
  Walking into Olivine at all registers the fly point.
- `OlivineCityRivalSceneTop` (`pokegold.sym` 49:4013) and
  `OlivineCityRivalSceneBottom` (49:404b). Both:
  `turnobject PLAYER, LEFT` / `showemote EMOTE_SHOCK, PLAYER, 15` /
  `special FadeOutMusic` / `pause 15` / `playsound SFX_ENTER_DOOR` /
  `appear OLIVINECITY_OLIVINE_RIVAL` /
  `applymovement OLIVINECITY_OLIVINE_RIVAL, <approach>` /
  `playmusic MUSIC_RIVAL_ENCOUNTER` / `writetext OlivineCityRivalText` /
  `applymovement PLAYER, <step aside>` /
  `applymovement OLIVINECITY_OLIVINE_RIVAL, <leaves>` /
  `setscene SCENE_OLIVINECITY_NOOP` / `disappear OLIVINECITY_OLIVINE_RIVAL` /
  `special RestartMapMusic` /
  `variablesprite SPRITE_OLIVINE_RIVAL, SPRITE_SWIMMER_GUY` /
  `special LoadUsedSpritesGFX`.
  **There is no battle.** The walkthrough is right: he only talks.
  The `variablesprite` at the end is load-bearing - it re-points the
  `SPRITE_OLIVINE_RIVAL` slot at `SPRITE_SWIMMER_GUY`, which is why the Route 40
  and Route 41 swimmers use `SPRITE_OLIVINE_RIVAL` in their `object_event` rows.
  Movements: top variant approach `DOWN, RIGHT, RIGHT`, player steps
  `DOWN` + `turn_head UP`, rival leaves `RIGHT x6, UP x6`. Bottom variant
  approach `DOWN, DOWN, RIGHT, RIGHT`, player steps `UP` + `turn_head DOWN`,
  rival leaves `RIGHT x6, UP x5`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_OLIVINE` | `constants/engine_flags.asm:85` | `OlivineCityFlypointCallback` | Fly destination unlocked on first entry |
| `EVENT_RIVAL_OLIVINE_CITY` | `constants/event_flags.asm:1125` | set by `InitializeEventsScript`, cleared by `appear`, re-set by `disappear` | hides the rival object outside the scene |
| `SCENE_OLIVINECITY_RIVAL_ENCOUNTER` = 0 | `maps/OlivineCity.asm:9` (`scene_script`) | `wOlivineCitySceneID` | default; arms the two coord events |
| `SCENE_OLIVINECITY_NOOP` = 1 | `maps/OlivineCity.asm:10` | `setscene` in both scene scripts | disarms them permanently |

**Items** - none on the overworld map itself. The section's three Olivine items
come from interiors: `GOOD_ROD` (Good Rod House), `HM_STRENGTH` (Cafe), and
TM23 from Jasmine in the gym (section 09).

**Trainers** - none.

**Wild encounters** - `data/wild/johto_water.asm:239`,
`def_water_wildmons OLIVINE_CITY`, rate `6 percent`: 20 TENTACOOL,
15 TENTACOOL, 20 TENTACRUEL. Fishing group is `FISHGROUP_SHORE`
(`data/maps/maps.asm:63`); with the Good Rod that is
`data/wild/fish.asm` `.Shore_Good`: 35% MAGIKARP 20, 35% KRABBY 20,
20%+1 KRABBY 20, remainder `time_group 0` = CORSOLA 20 by day / STARYU 20 at
night (`data/wild/fish.asm:212`). No grass table exists for Olivine City.

---

### MAP_OLIVINE_GOOD_ROD_HOUSE

- Script: `maps/OlivineGoodRodHouse.asm`
- Header (`data/maps/maps.asm:55`): `map OlivineGoodRodHouse, TILESET_HOUSE, INDOOR, LANDMARK_OLIVINE_CITY, MUSIC_VIOLET_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:44`): `map_const OLIVINE_GOOD_ROD_HOUSE, 4, 4`
- Attributes (`data/maps/attributes.asm:477`): no connections

**Warps**: 1 (2,7) -> `OLIVINE_CITY` 6; 2 (3,7) -> `OLIVINE_CITY` 6.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `OLIVINEGOODRODHOUSE_FISHING_GURU` | `SPRITE_FISHING_GURU` | 2 | 3 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `GoodRodGuru` | -1 |

**Scripts of interest**

- `GoodRodGuru` (`pokegold.sym` 51:46fc): `checkevent EVENT_GOT_GOOD_ROD` ->
  already-got text; otherwise `writetext OfferGoodRodText`, `yesorno`,
  **iffalse -> refusal, no item**, then `verbosegiveitem GOOD_ROD` and
  `setevent EVENT_GOT_GOOD_ROD`. A bot must answer YES.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `GOOD_ROD` | talk, answer YES | `GoodRodGuru` | `EVENT_GOT_GOOD_ROD` (`constants/event_flags.asm:32`) |

---

### MAP_OLIVINE_CAFE

- Script: `maps/OlivineCafe.asm`
- Blocks: `maps/OlivineCafe.blk`
- Header (`data/maps/maps.asm:56`): `map OlivineCafe, TILESET_GAME_CORNER, INDOOR, LANDMARK_OLIVINE_CITY, MUSIC_VIOLET_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:45`): `map_const OLIVINE_CAFE, 4, 4`
- Attributes (`data/maps/attributes.asm:478`): no connections

**Warps**: 1 (2,7) -> `OLIVINE_CITY` 7; 2 (3,7) -> `OLIVINE_CITY` 7.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `OLIVINECAFE_SAILOR` | `SPRITE_SAILOR` | 4 | 3 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_SCRIPT` | `OlivineCafeStrengthSailorScript` | -1 |
| `OLIVINECAFE_FISHING_GURU` | `SPRITE_FISHING_GURU` | 1 | 5 | `SPRITEMOVEDATA_WALK_UP_DOWN` (radius 0,1) | `OBJECTTYPE_SCRIPT` | `OlivineCafeFishingGuruScript` | -1 |

**Scripts of interest**

- `OlivineCafeStrengthSailorScript` (`pokegold.sym` 51:48a2):
  `checkevent EVENT_GOT_HM04_STRENGTH` -> already-got text; else
  `writetext OlivineCafeStrengthSailorText`, `promptbutton`,
  `verbosegiveitem HM_STRENGTH`, `setevent EVENT_GOT_HM04_STRENGTH`.
  **No prerequisite at all** - no badge check, no event check. The sailor's own
  text is the reminder that using Strength in the field needs Goldenrod's badge,
  but the HM itself is unconditional.
- `OlivineCafeFishingGuruScript`: flavour text warning about the Route 41
  whirlpools.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `HM_STRENGTH` (HM04) | talk to the sailor at (4,3) | `OlivineCafeStrengthSailorScript` | `EVENT_GOT_HM04_STRENGTH` (`constants/event_flags.asm:26`) |

---

### MAP_OLIVINE_POKECENTER_1F

- Script: `maps/OlivinePokecenter1F.asm`
- Header (`data/maps/maps.asm:50`): `map OlivinePokecenter1F, TILESET_POKECENTER, INDOOR, LANDMARK_OLIVINE_CITY, MUSIC_POKEMON_CENTER, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:39`): `map_const OLIVINE_POKECENTER_1F, 5, 4`

**Warps**: 1 (3,7) -> `OLIVINE_CITY` 1; 2 (4,7) -> `OLIVINE_CITY` 1;
3 (0,7) -> `POKECENTER_2F` 1.

**Object events**

| const | sprite | x | y | movement | type | script label |
|---|---|---|---|---|---|---|
| `OLIVINEPOKECENTER1F_NURSE` | `SPRITE_NURSE` | 3 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `OlivinePokecenter1FNurseScript` (`jumpstd PokecenterNurseScript`) |
| `OLIVINEPOKECENTER1F_FISHING_GURU` | `SPRITE_FISHING_GURU` | 8 | 4 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` | `OBJECTTYPE_SCRIPT` | `jumpstd HappinessCheckScript` |
| `OLIVINEPOKECENTER1F_FISHER` | `SPRITE_FISHER` | 2 | 3 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `OlivinePokecenter1FFisherScript` |
| `OLIVINEPOKECENTER1F_TEACHER` | `SPRITE_TEACHER` | 7 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `OlivinePokecenter1FTeacherScript` |

The happiness-check guru at (8,4) is worth knowing about: it is the standard
`HappinessCheckScript` and the closest one to Shuckie.

---

### MAP_OLIVINE_MART

- Script: `maps/OlivineMart.asm`
- Header (`data/maps/maps.asm:57`): `map OlivineMart, TILESET_MART, INDOOR, LANDMARK_OLIVINE_CITY, MUSIC_VIOLET_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:46`): `map_const OLIVINE_MART, 6, 4`
- **Warps**: 1 (2,7) -> `OLIVINE_CITY` 8; 2 (3,7) -> `OLIVINE_CITY` 8.
- `OlivineMartClerkScript`: `pokemart MARTTYPE_STANDARD, MART_OLIVINE`.
  `MartOlivine` (`data/items/marts.asm:168`), 9 items: GREAT_BALL,
  SUPER_POTION, HYPER_POTION, ANTIDOTE, PARLYZ_HEAL, AWAKENING, ICE_HEAL,
  SUPER_REPEL, SURF_MAIL. This is the walkthrough's "restock on items, like
  Great Balls".

---

### MAP_OLIVINE_LIGHTHOUSE_1F .. 6F

All six floors share:

- Header (`data/maps/maps.asm:112-117`):
  `map OlivineLighthouseNF, TILESET_LIGHTHOUSE, DUNGEON, LANDMARK_LIGHTHOUSE, MUSIC_LIGHTHOUSE, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
  - **exception**: 6F uses `MUSIC_VIOLET_CITY`, not `MUSIC_LIGHTHOUSE`
    (`data/maps/maps.asm:117`).
- Dimensions (`constants/map_constants.asm:99-104`):
  `map_const OLIVINE_LIGHTHOUSE_NF, 10, 9` for all six (20x18 cells).
- Attributes (`data/maps/attributes.asm:431-436`): no connections.
- No scene vars, no callbacks, no coord events on any floor.

Floor-to-floor structure, from the six `def_warp_events` blocks. There are two
vertical routes: the interior stairs (varying coordinates) and a right-wall
column at x = 16/17 that the walkthrough calls "the holes on the right side of
every floor". Each right-wall pair is mirrored at identical coordinates on the
floor it links to.

| from | at (x,y) | to | dest warp | role |
|---|---|---|---|---|
| 1F w3 | 3,11 | 2F | 1 | stairs up |
| 1F w4/w5 | 16,13 / 17,13 | 2F | 3 / 4 | right-wall pair |
| 2F w2 | 5,3 | 3F | 2 | stairs up |
| 2F w3/w4 | 16,13 / 17,13 | 1F | 4 / 5 | right-wall drop to 1F |
| 2F w5/w6 | 16,11 / 17,11 | 3F | 4 / 5 | right-wall pair |
| 3F w1 | 13,3 | 4F | 1 | stairs up |
| 3F w3 | 9,5 | 4F | 4 | stairs |
| 3F w4/w5 | 16,11 / 17,11 | 2F | 5 / 6 | right-wall drop to 2F |
| 3F w6/w7 | 16,9 / 17,9 | 4F | 5 / 6 | right-wall pair |
| 3F w8/w9 | 8,3 / 9,3 | 4F | 7 / 8 | the pair the 4F "hole next to Connie" lands on |
| 4F w2 | 3,5 | 5F | 2 | stairs up |
| 4F w3 | 9,7 | 5F | 3 | stairs |
| 4F w7/w8 | 8,3 / 9,3 | 3F | 8 / 9 | **the hole beside Lass Connie** - drops next to Sailor Terrell and the Ether |
| 4F w9/w10 | 16,7 / 17,7 | 5F | 4 / 5 | right-wall pair |
| 5F w1 | 9,15 | 6F | 1 | stairs up to Jasmine |
| 5F w4/w5 | 16,7 / 17,7 | 4F | 9 / 10 | right-wall drop to 4F |
| 5F w6/w7 | 16,5 / 17,5 | 6F | 2 / 3 | right-wall pair |
| 6F w2/w3 | 16,5 / 17,5 | 5F | 6 / 7 | start of the descent chain out |

Descent chain the walkthrough describes, in order:
6F (16,5) -> 5F (16,5); walk to 5F (16,7) -> 4F (16,7); walk to 4F (16,9) ->
3F (16,9); walk to 3F (16,11) -> 2F (16,11); walk to 2F (16,13) ->
1F (16,13); then 1F warp 1/2 at (10,17)/(11,17) back to Olivine.

#### MAP_OLIVINE_LIGHTHOUSE_1F

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 10 | 17 | `OLIVINE_CITY` | 9 |
| 2 | 11 | 17 | `OLIVINE_CITY` | 9 |
| 3 | 3 | 11 | `OLIVINE_LIGHTHOUSE_2F` | 1 |
| 4 | 16 | 13 | `OLIVINE_LIGHTHOUSE_2F` | 3 |
| 5 | 17 | 13 | `OLIVINE_LIGHTHOUSE_2F` | 4 |

**Coord events / BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `OLIVINELIGHTHOUSE1F_SAILOR` | `SPRITE_SAILOR` | 8 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `OlivineLighthouse1FSailorScript` | -1 |
| `OLIVINELIGHTHOUSE1F_POKEFAN_F` | `SPRITE_POKEFAN_F` | 16 | 9 | `SPRITEMOVEDATA_WALK_UP_DOWN` (radius 0,2) | `OBJECTTYPE_SCRIPT` | `OlivineLighthouse1FPokefanFScript` | -1 |

No trainers, no items, no gate on 1F.

#### MAP_OLIVINE_LIGHTHOUSE_2F

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 11 | `OLIVINE_LIGHTHOUSE_1F` | 3 |
| 2 | 5 | 3 | `OLIVINE_LIGHTHOUSE_3F` | 2 |
| 3 | 16 | 13 | `OLIVINE_LIGHTHOUSE_1F` | 4 |
| 4 | 17 | 13 | `OLIVINE_LIGHTHOUSE_1F` | 5 |
| 5 | 16 | 11 | `OLIVINE_LIGHTHOUSE_3F` | 4 |
| 6 | 17 | 11 | `OLIVINE_LIGHTHOUSE_3F` | 5 |

**Coord events / BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `OLIVINELIGHTHOUSE2F_SAILOR` | `SPRITE_SAILOR` | 9 | 3 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSailorHuey` | -1 |
| `OLIVINELIGHTHOUSE2F_GENTLEMAN` | `SPRITE_GENTLEMAN` | 17 | 8 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 3 | `TrainerGentlemanAlfred` | -1 |

**Scripts of interest**

- `TrainerSailorHuey.Script`: phone registration for `PHONE_SAILOR_HUEY`
  (`EVENT_HUEY_ASKED_FOR_PHONE_NUMBER`), rematch keyed on
  `EVENT_BEAT_ELITE_FOUR` -> `HUEY3`, else `EVENT_CLEARED_RADIO_TOWER` ->
  `HUEY2`, else `HUEY1`. The walkthrough's mention of a Liz phone call here is
  ambient phone traffic, not this script.

**Trainers**

| const | class | id | party | script label | rematch/phone |
|---|---|---|---|---|---|
| `ALFRED` | `GENTLEMAN` | 5 | `GentlemanGroup` "ALFRED", `TRAINERTYPE_NORMAL`: 20 NOCTOWL | `TrainerGentlemanAlfred` | no |
| `HUEY1` | `SAILOR` | 2 | `SailorGroup` "HUEY", `TRAINERTYPE_NORMAL`: 18 POLIWAG, 18 POLIWHIRL | `TrainerSailorHuey` | `PHONE_SAILOR_HUEY`; `HUEY2` = SAILOR 11 (28 POLIWHIRL x2), `HUEY3` = SAILOR 12 (34 POLIWHIRL, 34 POLIWRATH) |

#### MAP_OLIVINE_LIGHTHOUSE_3F

**Warps**

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

**Coord events / BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `OLIVINELIGHTHOUSE3F_SAILOR` | `SPRITE_SAILOR` | 9 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER` | 1 | `TrainerSailorTerrell` | -1 |
| `OLIVINELIGHTHOUSE3F_GENTLEMAN` | `SPRITE_GENTLEMAN` | 13 | 5 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 4 | `TrainerGentlemanPreston` | -1 |
| `OLIVINELIGHTHOUSE3F_YOUNGSTER` | `SPRITE_YOUNGSTER` | 3 | 9 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` | 3 | `TrainerBirdKeeperTheo` | -1 |
| `OLIVINELIGHTHOUSE3F_POKE_BALL` | `SPRITE_POKE_BALL` | 8 | 2 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | 0 | `OlivineLighthouse3FEther` (`itemball ETHER`) | `EVENT_OLIVINE_LIGHTHOUSE_3F_ETHER` |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `ETHER` | item ball at (8,2), reached by dropping through 4F (8,3)/(9,3) | `OlivineLighthouse3FEther` | `EVENT_OLIVINE_LIGHTHOUSE_3F_ETHER` (`constants/event_flags.asm:1029`) |

**Trainers**

| const | class | id | party | script label |
|---|---|---|---|---|
| `THEO` | `BIRD_KEEPER` | 4 | `TRAINERTYPE_NORMAL`: 17 PIDGEY, 15 PIDGEY, 19 PIDGEY, 15 PIDGEY, 15 PIDGEY | `TrainerBirdKeeperTheo` |
| `PRESTON` | `GENTLEMAN` | 1 | `TRAINERTYPE_NORMAL`: 18 GROWLITHE, 18 GROWLITHE | `TrainerGentlemanPreston` |
| `TERRELL` | `SAILOR` | 3 | `TRAINERTYPE_NORMAL`: 20 POLIWHIRL | `TrainerSailorTerrell` |

Sight range 1 on Terrell is why the walkthrough hits him only after dropping
down beside him.

#### MAP_OLIVINE_LIGHTHOUSE_4F

**Warps**

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

**Coord events / BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `OLIVINELIGHTHOUSE4F_SAILOR` | `SPRITE_SAILOR` | 7 | 14 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSailorKent` | -1 |
| `OLIVINELIGHTHOUSE4F_LASS` | `SPRITE_LASS` | 11 | 2 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_TRAINER` | 1 | `TrainerLassConnie` | -1 |

Connie stands at (11,2); the drop-down warps 7/8 at (8,3)/(9,3) are the
"hole next to Lass Connie" in the walkthrough.

**Trainers**

| const | class | id | party | script label |
|---|---|---|---|---|
| `CONNIE1` | `LASS` | 5 | `TRAINERTYPE_NORMAL`: 21 MARILL | `TrainerLassConnie` |
| `KENT` | `SAILOR` | 4 | `TRAINERTYPE_MOVES`: 18 KRABBY (BUBBLE, LEER, VICEGRIP, HARDEN), 20 KRABBY (BUBBLEBEAM, LEER, VICEGRIP, HARDEN) | `TrainerSailorKent` |

#### MAP_OLIVINE_LIGHTHOUSE_5F

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 15 | `OLIVINE_LIGHTHOUSE_6F` | 1 |
| 2 | 3 | 5 | `OLIVINE_LIGHTHOUSE_4F` | 2 |
| 3 | 9 | 7 | `OLIVINE_LIGHTHOUSE_4F` | 3 |
| 4 | 16 | 7 | `OLIVINE_LIGHTHOUSE_4F` | 9 |
| 5 | 17 | 7 | `OLIVINE_LIGHTHOUSE_4F` | 10 |
| 6 | 16 | 5 | `OLIVINE_LIGHTHOUSE_6F` | 2 |
| 7 | 17 | 5 | `OLIVINE_LIGHTHOUSE_6F` | 3 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 3 | 13 | `BGEVENT_ITEM` | `OlivineLighthouse5FHiddenHyperPotion` -> `hiddenitem HYPER_POTION, EVENT_OLIVINE_LIGHTHOUSE_5F_HIDDEN_HYPER_POTION` |

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `OLIVINELIGHTHOUSE5F_SAILOR` | `SPRITE_SAILOR` | 8 | 11 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSailorErnest` | -1 |
| `OLIVINELIGHTHOUSE5F_YOUNGSTER` | `SPRITE_YOUNGSTER` | 8 | 3 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 4 | `TrainerBirdKeeperDenis` | -1 |
| `OLIVINELIGHTHOUSE5F_POKE_BALL1` | `SPRITE_POKE_BALL` | 15 | 12 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | 0 | `OlivineLighthouse5FRareCandy` (`itemball RARE_CANDY`) | `EVENT_OLIVINE_LIGHTHOUSE_5F_RARE_CANDY` |
| `OLIVINELIGHTHOUSE5F_POKE_BALL2` | `SPRITE_POKE_BALL` | 6 | 15 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | 0 | `OlivineLighthouse5FGreatBall` (`itemball GREAT_BALL`) | `EVENT_OLIVINE_LIGHTHOUSE_5F_GREAT_BALL` |
| `OLIVINELIGHTHOUSE5F_POKE_BALL3` | `SPRITE_POKE_BALL` | 2 | 13 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | 0 | `OlivineLighthouse5FTMSwagger` (`itemball TM_SWAGGER`, `pokegold.sym` 44:6aea) | `EVENT_OLIVINE_LIGHTHOUSE_5F_TM_SWAGGER` |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `TM_SWAGGER` (TM34) | item ball at (2,13) | `OlivineLighthouse5FTMSwagger` | `EVENT_OLIVINE_LIGHTHOUSE_5F_TM_SWAGGER` (`constants/event_flags.asm:1032`) |
| `RARE_CANDY` | item ball at (15,12) | `OlivineLighthouse5FRareCandy` | `EVENT_OLIVINE_LIGHTHOUSE_5F_RARE_CANDY` (:1030) |
| `GREAT_BALL` | item ball at (6,15) | `OlivineLighthouse5FGreatBall` | `EVENT_OLIVINE_LIGHTHOUSE_5F_GREAT_BALL` (:1031) |
| `HYPER_POTION` | hidden at (3,13) | `OlivineLighthouse5FHiddenHyperPotion` | `EVENT_OLIVINE_LIGHTHOUSE_5F_HIDDEN_HYPER_POTION` (:143) |

The hidden Hyper Potion is one cell east of the TM34 ball and is not mentioned
in the walkthrough.

**Trainers**

| const | class | id | party | script label |
|---|---|---|---|---|
| `DENIS` | `BIRD_KEEPER` | 6 | `TRAINERTYPE_NORMAL`: 18 SPEAROW, 20 FEAROW, 18 SPEAROW | `TrainerBirdKeeperDenis` |
| `ERNEST` | `SAILOR` | 5 | `TRAINERTYPE_NORMAL`: 18 MACHOP, 18 MACHOP, 18 POLIWHIRL | `TrainerSailorErnest` |

Note the party order: the asm has Denis as SPEAROW / FEAROW / SPEAROW; the
walkthrough lists Spearow, Spearow, Fearow.

#### MAP_OLIVINE_LIGHTHOUSE_6F

**Warps**

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 9 | 15 | `OLIVINE_LIGHTHOUSE_5F` | 1 |
| 2 | 16 | 5 | `OLIVINE_LIGHTHOUSE_5F` | 6 |
| 3 | 17 | 5 | `OLIVINE_LIGHTHOUSE_5F` | 7 |

**Coord events / BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `OLIVINELIGHTHOUSE6F_JASMINE` | `SPRITE_JASMINE` | 8 | 8 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `OlivineLighthouseJasmine` | `EVENT_OLIVINE_LIGHTHOUSE_JASMINE` |
| `OLIVINELIGHTHOUSE6F_MONSTER` | `SPRITE_MONSTER` | 9 | 8 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `OlivineLighthouseAmphy` | -1 |
| `OLIVINELIGHTHOUSE6F_POKE_BALL` | `SPRITE_POKE_BALL` | 3 | 4 | `SPRITEMOVEDATA_STILL` | `OBJECTTYPE_ITEMBALL` | `OlivineLighthouse6FSuperPotion` (`itemball SUPER_POTION`) | `EVENT_OLIVINE_LIGHTHOUSE_6F_SUPER_POTION` |

`EVENT_OLIVINE_LIGHTHOUSE_JASMINE` is **not** set by
`InitializeEventsScript`, so Jasmine is visible from the start; the script's
own `disappear` sets it once she leaves.

**Scripts of interest**

- `OlivineLighthouseJasmine` (`pokegold.sym` 44:6ccd). Three arms:
  1. `checkitem SECRETPOTION` -> `.BroughtSecretpotion` (the cure scene).
  2. Otherwise `checkevent EVENT_JASMINE_EXPLAINED_AMPHYS_SICKNESS` ->
     `.ExplainedSickness` (short reminder text).
  3. First visit: `writetext JasmineCianwoodPharmacyText`, `promptbutton`,
     **`setevent EVENT_JASMINE_EXPLAINED_AMPHYS_SICKNESS`**, then the reminder.
     This flag is the whole point of the lighthouse climb: it is what
     `CianwoodPharmacist` checks before it will hand over the Secretpotion.
  4. `.BroughtSecretpotion`: `yesorno` (NO -> `.Refused`, nothing lost), then
     `takeitem SECRETPOTION`, the healing cut-scene (`playmusic MUSIC_HEAL`,
     `cry AMPHAROS`, `special FadeOutToWhite` / `FadeInFromWhite`), then
     **`setevent EVENT_JASMINE_RETURNED_TO_GYM`** and
     **`clearevent EVENT_OLIVINE_GYM_JASMINE`** (the latter un-masks her object
     in `maps/OlivineGym.asm`; `InitializeEventsScript` sets it at
     `engine/events/std_scripts.asm:511`). Finally it branches on
     `readvar VAR_FACING` (DOWN / RIGHT / other) to pick one of three exit
     movement scripts and `disappear OLIVINELIGHTHOUSE6F_JASMINE`.
- `OlivineLighthouseAmphy`: `checkevent EVENT_JASMINE_RETURNED_TO_GYM` picks
  the weak cry (`special PlaySlowCry`) or the healthy one.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_JASMINE_EXPLAINED_AMPHYS_SICKNESS` | `constants/event_flags.asm:64` | set by `OlivineLighthouseJasmine`, read by `CianwoodPharmacist` | **hard gate** on the Secretpotion |
| `EVENT_JASMINE_RETURNED_TO_GYM` | `constants/event_flags.asm:41` | set after the cure | gates the Olivine Gym fight (section 09) |
| `EVENT_OLIVINE_GYM_JASMINE` | `constants/event_flags.asm:1141` | set by `InitializeEventsScript`, cleared here | while set, Jasmine's gym object is masked |
| `EVENT_OLIVINE_LIGHTHOUSE_JASMINE` | `constants/event_flags.asm:1140` | set by `disappear` at the end | removes her from 6F afterwards |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `SUPER_POTION` | item ball at (3,4), west of Jasmine | `OlivineLighthouse6FSuperPotion` | `EVENT_OLIVINE_LIGHTHOUSE_6F_SUPER_POTION` (`constants/event_flags.asm:1033`) |

---

### MAP_ROUTE_40

- Script: `maps/Route40.asm`
- Blocks: `maps/Route40.blk`
- Header (`data/maps/maps.asm:442`): `map Route40, TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_40, MUSIC_ROUTE_36, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:409`): `map_const ROUTE_40, 10, 18` (20x36 cells)
- Connections (`data/maps/attributes.asm:223`): south `Route41` / `ROUTE_41` offset -15; east `OlivineCity` / `OLIVINE_CITY` offset -9
- Scene var: none
- Callback: `callback MAPCALLBACK_OBJECTS, Route40MonicaCallback`

**Warps** - **none**. Route 40 is reached and left purely by map connections.

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 16 | 8 | `BGEVENT_READ` | `Route40Sign` |
| 11 | 7 | `BGEVENT_ITEM` | `Route40HiddenHyperPotion` -> `hiddenitem HYPER_POTION, EVENT_ROUTE_40_HIDDEN_HYPER_POTION` |

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `ROUTE40_OLIVINE_RIVAL1` | `SPRITE_OLIVINE_RIVAL` | 14 | 15 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 4 | `TrainerSwimmermSimon` | -1 |
| `ROUTE40_OLIVINE_RIVAL2` | `SPRITE_OLIVINE_RIVAL` | 18 | 30 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 5 | `TrainerSwimmermRandall` | -1 |
| `ROUTE40_SWIMMER_GIRL1` | `SPRITE_SWIMMER_GIRL` | 3 | 19 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 4 | `TrainerSwimmerfElaine` | -1 |
| `ROUTE40_SWIMMER_GIRL2` | `SPRITE_SWIMMER_GIRL` | 10 | 25 | `SPRITEMOVEDATA_SPINCLOCKWISE` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSwimmerfPaula` | -1 |
| `ROUTE40_ROCK1` | `SPRITE_ROCK` | 12 | 8 | `SPRITEMOVEDATA_SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | 0 | `Route40Rock` (`jumpstd SmashRockScript`) | -1 |
| `ROUTE40_ROCK2` | `SPRITE_ROCK` | 11 | 7 | `SPRITEMOVEDATA_SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | 0 | `Route40Rock` | -1 |
| `ROUTE40_ROCK3` | `SPRITE_ROCK` | 13 | 6 | `SPRITEMOVEDATA_SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | 0 | `Route40Rock` | -1 |
| `ROUTE40_LASS` | `SPRITE_LASS` | 13 | 10 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `Route40Lass1Script` | -1 |
| `ROUTE40_MONICA` | `SPRITE_BEAUTY` | 10 | 6 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius 1,0) | `OBJECTTYPE_SCRIPT` | 0 | `MonicaScript` | `EVENT_ROUTE_40_MONICA_OF_MONDAY` |

Note `ROCK2` and the hidden Hyper Potion share the cell (11,7): smash the rock,
then dig up the item.

**Scripts of interest**

- `Route40MonicaCallback` (`pokegold.sym` 4c:4ecf):
  `readvar VAR_WEEKDAY / ifequal MONDAY, .MonicaAppears`; otherwise
  `disappear ROUTE40_MONICA`. Purely day-of-week.
- `MonicaScript`: `checkevent EVENT_GOT_SHARP_BEAK_FROM_MONICA` -> chat;
  else `readvar VAR_WEEKDAY / ifnotequal MONDAY` -> chat; else
  `setevent EVENT_MET_MONICA_OF_MONDAY`, `verbosegiveitem SHARP_BEAK`,
  `setevent EVENT_GOT_SHARP_BEAK_FROM_MONICA`.
- `Route40Rock`: `jumpstd SmashRockScript` ->
  `farsjump AskRockSmashScript` (`engine/events/std_scripts.asm:199`).

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `HYPER_POTION` | hidden at (11,7) | `Route40HiddenHyperPotion` bg_event | `EVENT_ROUTE_40_HIDDEN_HYPER_POTION` (`constants/event_flags.asm:181`) |
| `SHARP_BEAK` | talk to Monica at (10,6), Mondays only | `MonicaScript` | `EVENT_GOT_SHARP_BEAK_FROM_MONICA` (:120) |

Neither is in the walkthrough.

**Trainers**

| const | class | id | party | script label |
|---|---|---|---|---|
| `SIMON` | `SWIMMERM` | 2 | `TRAINERTYPE_NORMAL`: 20 TENTACOOL, 20 TENTACOOL | `TrainerSwimmermSimon` |
| `RANDALL` | `SWIMMERM` | 3 | `TRAINERTYPE_NORMAL`: 18 SHELLDER, 20 WARTORTLE, 18 SHELLDER | `TrainerSwimmermRandall` |
| `ELAINE` | `SWIMMERF` | 1 | `TRAINERTYPE_NORMAL`: 21 STARYU | `TrainerSwimmerfElaine` |
| `PAULA` | `SWIMMERF` | 2 | `TRAINERTYPE_NORMAL`: 19 STARYU, 19 SHELLDER | `TrainerSwimmerfPaula` |

**Wild encounters**

- Water (`data/wild/johto_water.asm:163`), `def_water_wildmons ROUTE_40`,
  rate `6 percent`: 20 TENTACOOL, 15 TENTACOOL, 20 TENTACRUEL. Same in Gold and
  Silver.
- Fishing group `FISHGROUP_SHORE` (`data/maps/maps.asm:442`).
- Rock smash: `data/wild/treemon_maps.asm:45`
  `treemon_map ROUTE_40, TREEMON_SET_ROCK` (in the `RockMonMaps` table).
  `TreeMonSet_Rock` (`data/wild/treemons.asm:91`): 90 KRABBY 15, 10 SHUCKLE 15.
  **This is where the walkthrough's Shuckle for this stretch actually comes
  from**, not from a water slot.
- Headbutt: `data/wild/treemon_maps.asm:21` `TREEMON_SET_NONE`.

---

### MAP_ROUTE_41

- Script: `maps/Route41.asm`
- Blocks: `maps/Route41.blk`
- Header (`data/maps/maps.asm:443`): `map Route41, TILESET_JOHTO, ROUTE, LANDMARK_ROUTE_41, MUSIC_ROUTE_36, FALSE, PALETTE_AUTO, FISHGROUP_OCEAN`
- Dimensions (`constants/map_constants.asm:410`): `map_const ROUTE_41, 25, 27` (50x54 cells)
- Connections (`data/maps/attributes.asm:227`): north `Route40` / `ROUTE_40` offset 15; west `CianwoodCity` / `CIANWOOD_CITY` offset 0
- Scene var: none, no callbacks

**Warps** (`def_warp_events`) - all four are the Whirl Islands, optional in
this section:

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 12 | 17 | `WHIRL_ISLAND_NW` | 1 |
| 2 | 36 | 19 | `WHIRL_ISLAND_NE` | 1 |
| 3 | 12 | 37 | `WHIRL_ISLAND_SW` | 1 |
| 4 | 36 | 45 | `WHIRL_ISLAND_SE` | 1 |

**Coord events** - none.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 9 | 35 | `BGEVENT_ITEM` | `Route41HiddenMaxEther` -> `hiddenitem MAX_ETHER, EVENT_ROUTE_41_HIDDEN_MAX_ETHER` |

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `ROUTE41_OLIVINE_RIVAL1` | `SPRITE_OLIVINE_RIVAL` | 32 | 6 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSwimmermCharlie` | -1 |
| `ROUTE41_OLIVINE_RIVAL2` | `SPRITE_OLIVINE_RIVAL` | 46 | 8 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSwimmermGeorge` | -1 |
| `ROUTE41_OLIVINE_RIVAL3` | `SPRITE_OLIVINE_RIVAL` | 20 | 26 | `SPRITEMOVEDATA_SPINCOUNTERCLOCKWISE` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSwimmermBerke` | -1 |
| `ROUTE41_OLIVINE_RIVAL4` | `SPRITE_OLIVINE_RIVAL` | 32 | 30 | `SPRITEMOVEDATA_SPINCLOCKWISE` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSwimmermKirk` | -1 |
| `ROUTE41_OLIVINE_RIVAL5` | `SPRITE_OLIVINE_RIVAL` | 19 | 46 | `SPRITEMOVEDATA_SPINCOUNTERCLOCKWISE` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSwimmermMathew` | -1 |
| `ROUTE41_SWIMMER_GIRL1` | `SPRITE_SWIMMER_GIRL` | 17 | 4 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSwimmerfKaylee` | -1 |
| `ROUTE41_SWIMMER_GIRL2` | `SPRITE_SWIMMER_GIRL` | 23 | 19 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSwimmerfSusie` | -1 |
| `ROUTE41_SWIMMER_GIRL3` | `SPRITE_SWIMMER_GIRL` | 27 | 34 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 3 | `TrainerSwimmerfDenise` | -1 |
| `ROUTE41_SWIMMER_GIRL4` | `SPRITE_SWIMMER_GIRL` | 44 | 28 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 4 | `TrainerSwimmerfKara` | -1 |
| `ROUTE41_SWIMMER_GIRL5` | `SPRITE_SWIMMER_GIRL` | 9 | 50 | `SPRITEMOVEDATA_SPINRANDOM_FAST` | `OBJECTTYPE_TRAINER` | 2 | `TrainerSwimmerfWendy` | -1 |

All ten are plain `endifjustbattled` after-battle scripts - no phone numbers,
no rematch tiers on this route.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `MAX_ETHER` | hidden at (9,35) | `Route41HiddenMaxEther` | `EVENT_ROUTE_41_HIDDEN_MAX_ETHER` (`constants/event_flags.asm:182`) |

**Trainers**

| const | class | id | party | script label |
|---|---|---|---|---|
| `CHARLIE` | `SWIMMERM` | 4 | 21 SHELLDER, 19 TENTACOOL, 19 TENTACRUEL | `TrainerSwimmermCharlie` |
| `GEORGE` | `SWIMMERM` | 5 | 16 TENTACOOL, 17 TENTACOOL, 16 TENTACOOL, 19 STARYU, 17 TENTACOOL, 19 REMORAID | `TrainerSwimmermGeorge` |
| `BERKE` | `SWIMMERM` | 6 | 23 QWILFISH | `TrainerSwimmermBerke` |
| `KIRK` | `SWIMMERM` | 7 | 20 GYARADOS, 20 GYARADOS | `TrainerSwimmermKirk` |
| `MATHEW` | `SWIMMERM` | 8 | 23 KRABBY | `TrainerSwimmermMathew` |
| `KAYLEE` | `SWIMMERF` | 3 | 18 GOLDEEN, 20 GOLDEEN, 20 SEAKING | `TrainerSwimmerfKaylee` |
| `SUSIE` | `SWIMMERF` | 4 | `TRAINERTYPE_MOVES`: 20 PSYDUCK (SCRATCH, TAIL_WHIP, DISABLE, CONFUSION), 22 GOLDEEN (PECK, TAIL_WHIP, SUPERSONIC, HORN_ATTACK) | `TrainerSwimmerfSusie` |
| `DENISE` | `SWIMMERF` | 5 | 22 SEEL | `TrainerSwimmerfDenise` |
| `KARA` | `SWIMMERF` | 6 | 20 STARYU, 20 STARMIE | `TrainerSwimmerfKara` |
| `WENDY` | `SWIMMERF` | 7 | `TRAINERTYPE_MOVES`: 21 HORSEA (BUBBLE, SMOKESCREEN, LEER, WATER_GUN), 21 HORSEA (DRAGON_RAGE, SMOKESCREEN, LEER, WATER_GUN) | `TrainerSwimmerfWendy` |

All except Kaylee are named by the walkthrough.

**Wild encounters**

- Water (`data/wild/johto_water.asm:170`), `def_water_wildmons ROUTE_41`,
  rate `6 percent`. Gold: 20 TENTACOOL, 20 TENTACRUEL, **20 MANTINE**.
  Silver: 20 TENTACOOL, 20 TENTACRUEL, 15 TENTACOOL. This is the one place in
  the section where the version split matters for the Pokedex.
- Fishing group `FISHGROUP_OCEAN` (`data/maps/maps.asm:443`). Good Rod
  (`.Ocean_Good`, `data/wild/fish.asm:45`): 35% MAGIKARP 20, 35% TENTACOOL 20,
  20%+1 CHINCHOU 20, remainder `time_group 2` = SHELLDER 20 day or night.
- Headbutt: `TREEMON_SET_NONE`. Rock smash: Route 41 is **not** in
  `RockMonMaps`, and `Route41Rock` in the map asm is marked `; unreferenced`.

---

### MAP_CIANWOOD_CITY

- Script: `maps/CianwoodCity.asm`
- Blocks: `maps/CianwoodCity.blk`
- Header (`data/maps/maps.asm:444`): `map CianwoodCity, TILESET_JOHTO, TOWN, LANDMARK_CIANWOOD_CITY, MUSIC_ECRUTEAK_CITY, FALSE, PALETTE_AUTO, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:411`): `map_const CIANWOOD_CITY, 15, 27` (30x54 cells)
- Connections (`data/maps/attributes.asm:136`): east `Route41` / `ROUTE_41` offset 0
- Scene var: none
- Callback: `callback MAPCALLBACK_NEWMAP, CianwoodCityFlypointCallback`
- Spawn (`data/maps/spawn_points.asm:32`): `spawn CIANWOOD_CITY, 23, 44`.
  Fly point `LANDMARK_CIANWOOD_CITY` -> `SPAWN_CIANWOOD` (`data/maps/flypoints.asm:12`).

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 17 | 41 | `MANIAS_HOUSE` | 1 |
| 2 | 8 | 43 | `CIANWOOD_GYM` | 1 |
| 3 | 23 | 43 | `CIANWOOD_POKECENTER_1F` | 1 |
| 4 | 15 | 47 | `CIANWOOD_PHARMACY` | 1 |
| 5 | 9 | 31 | `CIANWOOD_PHOTO_STUDIO` | 1 |
| 6 | 15 | 37 | `CIANWOOD_LUGIA_SPEECH_HOUSE` | 1 |

The walkthrough's "To the left of the Pokémon Center is a house where a
PokeManiac..." is Mania's House at (17,41), left of the Pokecenter at (23,43).
"the building below that. It's the Pharmacy" is warp 4 at (15,47).

**Coord events** - none. Nothing scripted fires on entry.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 20 | 34 | `BGEVENT_READ` | `CianwoodCitySign` |
| 7 | 45 | `BGEVENT_READ` | `CianwoodGymSign` |
| 24 | 43 | `BGEVENT_READ` | `CianwoodPokecenterSign` |
| 19 | 47 | `BGEVENT_READ` | `CianwoodPharmacySign` |
| 8 | 32 | `BGEVENT_READ` | `CianwoodPhotoStudioSign` |
| 8 | 16 | `BGEVENT_ITEM` | `CianwoodCityHiddenRevive` -> `hiddenitem REVIVE, EVENT_CIANWOOD_CITY_HIDDEN_REVIVE` |
| 5 | 29 | `BGEVENT_ITEM` | `CianwoodCityHiddenMaxEther` -> `hiddenitem MAX_ETHER, EVENT_CIANWOOD_CITY_HIDDEN_MAX_ETHER` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `CIANWOODCITY_STANDING_YOUNGSTER` | `SPRITE_YOUNGSTER` | 21 | 37 | `SPRITEMOVEDATA_WANDER` (radius 2,2) | `OBJECTTYPE_SCRIPT` | `CianwoodCityYoungster` | -1 |
| `CIANWOODCITY_POKEFAN_M` | `SPRITE_POKEFAN_M` | 17 | 31 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `CianwoodCityPokefanM` | -1 |
| `CIANWOODCITY_LASS` | `SPRITE_LASS` | 14 | 42 | `SPRITEMOVEDATA_WALK_UP_DOWN` (radius 0,2) | `OBJECTTYPE_SCRIPT` | `CianwoodCityLass` | -1 |
| `CIANWOODCITY_ROCK1` | `SPRITE_ROCK` | 8 | 16 | `SPRITEMOVEDATA_SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | `CianwoodCityRock` | -1 |
| `CIANWOODCITY_ROCK2` | `SPRITE_ROCK` | 11 | 15 | `SPRITEMOVEDATA_SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | `CianwoodCityRock` | -1 |
| `CIANWOODCITY_ROCK3` | `SPRITE_ROCK` | 6 | 24 | `SPRITEMOVEDATA_SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | `CianwoodCityRock` | -1 |
| `CIANWOODCITY_ROCK4` | `SPRITE_ROCK` | 5 | 29 | `SPRITEMOVEDATA_SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | `CianwoodCityRock` | -1 |
| `CIANWOODCITY_ROCK5` | `SPRITE_ROCK` | 10 | 27 | `SPRITEMOVEDATA_SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | `CianwoodCityRock` | -1 |
| `CIANWOODCITY_ROCK6` | `SPRITE_ROCK` | 7 | 17 | `SPRITEMOVEDATA_SMASHABLE_ROCK` | `OBJECTTYPE_SCRIPT` | `CianwoodCityRock` | -1 |
| `CIANWOODCITY_POKEFAN_F` | `SPRITE_POKEFAN_F` | 10 | 46 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius 1,0) | `OBJECTTYPE_SCRIPT` | `CianwoodCityChucksWife` | -1 |

Note both hidden items sit on rock cells: the Revive shares (8,16) with ROCK1,
the Max Ether shares (5,29) with ROCK4.

**Scripts of interest**

- `CianwoodCityFlypointCallback` (`pokegold.sym` 48:58df):
  `setflag ENGINE_FLYPOINT_CIANWOOD`.
- `CianwoodCityChucksWife` (`pokegold.sym` 48:58e3):
  `checkevent EVENT_GOT_HM02_FLY` -> chat; else print
  `ChucksWifeEasierToFlyText`, then `checkevent EVENT_BEAT_CHUCK`:
  - not set -> `ChucksWifeBeatChuckText`, end. **She will not hand over Fly
    before Chuck is beaten.**
  - set -> `verbosegiveitem HM_FLY`, `setevent EVENT_GOT_HM02_FLY`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_CIANWOOD` | `constants/engine_flags.asm:83` | `CianwoodCityFlypointCallback` | set on arrival; also bumps Route 38 Dana's rematch tier |
| `EVENT_GOT_HM02_FLY` | `constants/event_flags.asm:24` | `CianwoodCityChucksWife` | one-time |
| `EVENT_BEAT_CHUCK` | `constants/event_flags.asm:711` | set by `CianwoodGymChuckScript` | precondition for HM02 |
| `EVENT_CIANWOOD_CITY_HIDDEN_REVIVE` | `constants/event_flags.asm:188` | `CianwoodCityHiddenRevive` | one-time |
| `EVENT_CIANWOOD_CITY_HIDDEN_MAX_ETHER` | `constants/event_flags.asm:189` | `CianwoodCityHiddenMaxEther` | one-time |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `HM_FLY` (HM02) | talk to `CIANWOODCITY_POKEFAN_F` at (10,46) after `EVENT_BEAT_CHUCK` | `CianwoodCityChucksWife` | `EVENT_GOT_HM02_FLY` |
| `REVIVE` | hidden at (8,16) | `CianwoodCityHiddenRevive` | `EVENT_CIANWOOD_CITY_HIDDEN_REVIVE` |
| `MAX_ETHER` | hidden at (5,29) | `CianwoodCityHiddenMaxEther` | `EVENT_CIANWOOD_CITY_HIDDEN_MAX_ETHER` |

**Wild encounters**

- Water (`data/wild/johto_water.asm:232`), `def_water_wildmons CIANWOOD_CITY`,
  rate `6 percent`: 20 TENTACOOL, 15 TENTACOOL, 20 TENTACRUEL.
- Rock smash: `data/wild/treemon_maps.asm:44`
  `treemon_map CIANWOOD_CITY, TREEMON_SET_ROCK`, i.e. the same 90 KRABBY 15 /
  10 SHUCKLE 15 table as Route 40. Six smashable rocks are on the map.
- Headbutt: `TREEMON_SET_NONE` (`data/wild/treemon_maps.asm:32`).
- Fishing group `FISHGROUP_SHORE`.

---

### MAP_MANIAS_HOUSE

- Script: `maps/ManiasHouse.asm`
- Header (`data/maps/maps.asm:445`): `map ManiasHouse, TILESET_HOUSE, INDOOR, LANDMARK_CIANWOOD_CITY, MUSIC_ECRUTEAK_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:412`): `map_const MANIAS_HOUSE, 4, 4`
- Attributes (`data/maps/attributes.asm:651`): no connections

**Warps**: 1 (2,7) -> `CIANWOOD_CITY` 1; 2 (3,7) -> `CIANWOOD_CITY` 1.

**Coord events / BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `MANIASHOUSE_ROCKER` | `SPRITE_ROCKER` | 2 | 4 | `SPRITEMOVEDATA_SPINRANDOM_SLOW` | `OBJECTTYPE_SCRIPT` | `ManiaScript` | -1 |

**Scripts of interest**

- `ManiaScript` (`pokegold.sym` 5d:4f6d):
  1. `checkevent EVENT_MANIA_TOOK_SHUCKIE_OR_LET_YOU_KEEP_HIM` -> happiness
     speech, done forever.
  2. `checkevent EVENT_GOT_SHUCKIE` -> `.alreadyhaveshuckie`, which checks
     `checkflag ENGINE_GOT_SHUCKIE_TODAY` (`constants/engine_flags.asm:102`);
     if that daily flag is clear he asks for Shuckie back
     (`.returnshuckie`).
  3. First time: `writetext ManiaText_AskLookAfterShuckle`, `yesorno`,
     **`special GiveShuckle`** (`iffalse .partyfull`), then
     `setevent EVENT_GOT_SHUCKIE`.
  4. `.returnshuckie`: `special ReturnShuckie` and a five-way `ifequal` on
     `SHUCKIE_WRONG_MON` / `SHUCKIE_REFUSED` / `SHUCKIE_HAPPY` /
     `SHUCKIE_FAINTED` (constants in `constants/script_constants.asm`).
     `SHUCKIE_HAPPY` is the "it likes you enough, keep it" arm the
     walkthrough's Thard_Verad note describes, and it also sets
     `EVENT_MANIA_TOOK_SHUCKIE_OR_LET_YOU_KEEP_HIM`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_GOT_SHUCKIE` | `constants/event_flags.asm:78` | `ManiaScript` | Shuckie is in your party |
| `EVENT_MANIA_TOOK_SHUCKIE_OR_LET_YOU_KEEP_HIM` | `constants/event_flags.asm:79` | `.returnshuckie` arms | the encounter is finished |
| `ENGINE_GOT_SHUCKIE_TODAY` | `constants/engine_flags.asm:102` | daily flag, read by `.alreadyhaveshuckie` | he will not ask for it back on the day you got it |

**Items** - Shuckie is a party member, not a bag item. A bot must have a free
party slot: `GiveShuckle` returns false and the script prints
`ManiaText_PartyFull` otherwise. This is what "clear a space so you can acquire
another Pokémon" means.

---

### MAP_CIANWOOD_PHARMACY

- Script: `maps/CianwoodPharmacy.asm`
- Header (`data/maps/maps.asm:448`): `map CianwoodPharmacy, TILESET_HOUSE, INDOOR, LANDMARK_CIANWOOD_CITY, MUSIC_ECRUTEAK_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:415`): `map_const CIANWOOD_PHARMACY, 4, 4`
- Attributes (`data/maps/attributes.asm:654`): no connections
- Scene scripts: one entry, `scene_script CianwoodPharmacyNoopScene ; unusable`
  (a bare `end`, and no scene var row exists in `data/maps/scenes.asm`)

**Warps**: 1 (2,7) -> `CIANWOOD_CITY` 4; 2 (3,7) -> `CIANWOOD_CITY` 4.

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 0 | 1 | `BGEVENT_READ` | `CianwoodPharmacyBookshelf` |
| 1 | 1 | `BGEVENT_READ` | `CianwoodPharmacyBookshelf` |

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `CIANWOODPHARMACY_PHARMACIST` | `SPRITE_PHARMACIST` | 2 | 3 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CianwoodPharmacist` | -1 |

**Scripts of interest**

- `CianwoodPharmacist` (`pokegold.sym` 5d:5a9a):
  `checkevent EVENT_GOT_SECRETPOTION_FROM_PHARMACY / iftrue .Mart`, then
  **`checkevent EVENT_JASMINE_EXPLAINED_AMPHYS_SICKNESS / iffalse .Mart`**.
  Only with that flag set does it run `giveitem SECRETPOTION`,
  `playsound SFX_KEY_ITEM`, `itemnotify`,
  `setevent EVENT_GOT_SECRETPOTION_FROM_PHARMACY`. Otherwise it just opens the
  shop: `pokemart MARTTYPE_PHARMACY, MART_CIANWOOD` -> `MartCianwood`
  (`data/items/marts.asm:84`): POTION, SUPER_POTION, HYPER_POTION, FULL_HEAL,
  REVIVE.

  **Gate for a bot**: you must talk to Jasmine on Lighthouse 6F *before* the
  pharmacist will give you anything. Skipping the lighthouse and sailing
  straight to Cianwood silently gets you a shop menu and no Secretpotion.

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `SECRETPOTION` | talk to the pharmacist with `EVENT_JASMINE_EXPLAINED_AMPHYS_SICKNESS` set | `CianwoodPharmacist` | `EVENT_GOT_SECRETPOTION_FROM_PHARMACY` (`constants/event_flags.asm:44`) |

---

### MAP_CIANWOOD_PHOTO_STUDIO

- Script: `maps/CianwoodPhotoStudio.asm`
- Header (`data/maps/maps.asm:449`): `map CianwoodPhotoStudio, TILESET_HOUSE, INDOOR, LANDMARK_CIANWOOD_CITY, MUSIC_ECRUTEAK_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:416`): `map_const CIANWOOD_PHOTO_STUDIO, 4, 4`
- **Warps**: 1 (2,7) -> `CIANWOOD_CITY` 5; 2 (3,7) -> `CIANWOOD_CITY` 5.
- Object: `CIANWOODPHOTOSTUDIO_FISHING_GURU`, `SPRITE_FISHING_GURU`, (2,3),
  `SPRITEMOVEDATA_STANDING_DOWN`, `OBJECTTYPE_SCRIPT`,
  `CianwoodPhotoStudioFishingGuruScript`.
- `CianwoodPhotoStudioFishingGuruScript`: `yesorno` then `special PhotoStudio`.
  Purely optional (Game Boy Printer flavour); no flags, no items.

---

### MAP_CIANWOOD_POKECENTER_1F

- Script: `maps/CianwoodPokecenter1F.asm`
- Header (`data/maps/maps.asm:447`): `map CianwoodPokecenter1F, TILESET_POKECENTER, INDOOR, LANDMARK_CIANWOOD_CITY, MUSIC_POKEMON_CENTER, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:414`): `map_const CIANWOOD_POKECENTER_1F, 5, 4`

**Warps**: 1 (3,7) -> `CIANWOOD_CITY` 3; 2 (4,7) -> `CIANWOOD_CITY` 3;
3 (0,7) -> `POKECENTER_2F` 1.

**Object events**

| const | sprite | x | y | movement | type | script label |
|---|---|---|---|---|---|---|
| `CIANWOODPOKECENTER1F_NURSE` | `SPRITE_NURSE` | 3 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `jumpstd PokecenterNurseScript` |
| `CIANWOODPOKECENTER1F_LASS` | `SPRITE_LASS` | 1 | 5 | `SPRITEMOVEDATA_WALK_UP_DOWN` | `OBJECTTYPE_SCRIPT` | `CianwoodPokecenter1FLassScript` |
| `CIANWOODPOKECENTER1F_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 5 | 3 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `CianwoodGymGuideScript` |

`CianwoodGymGuideScript` branches on `EVENT_BEAT_CHUCK`. The gym guide lives in
the Pokecenter here, not inside the gym.

---

### MAP_CIANWOOD_LUGIA_SPEECH_HOUSE

- Script: `maps/CianwoodLugiaSpeechHouse.asm`
- Header (`data/maps/maps.asm:450`): `map CianwoodLugiaSpeechHouse, TILESET_HOUSE, INDOOR, LANDMARK_CIANWOOD_CITY, MUSIC_ECRUTEAK_CITY, FALSE, PALETTE_DAY, FISHGROUP_SHORE`
- Dimensions (`constants/map_constants.asm:417`): `map_const CIANWOOD_LUGIA_SPEECH_HOUSE, 4, 4`
- **Warps**: 1 (2,7) -> `CIANWOOD_CITY` 6; 2 (3,7) -> `CIANWOOD_CITY` 6.
- Objects: `CIANWOODLUGIASPEECHHOUSE_TEACHER` (`SPRITE_TEACHER`, 2,4),
  `..._LASS` (`SPRITE_LASS`, 6,5, `WALK_LEFT_RIGHT`),
  `..._TWIN` (`SPRITE_TWIN`, 0,2). BG events: bookshelf at (0,1) and (1,1).
  All `jumptextfaceplayer` - Lugia lore, no flags. Optional.

---

### MAP_CIANWOOD_GYM

- Script: `maps/CianwoodGym.asm`
- Blocks: `maps/CianwoodGym.blk`
- Header (`data/maps/maps.asm:446`): `map CianwoodGym, TILESET_TOWER, INDOOR, LANDMARK_CIANWOOD_CITY, MUSIC_GYM, TRUE, PALETTE_DAY, FISHGROUP_SHORE`
  (the `TRUE` is the phone-service flag)
- Dimensions (`constants/map_constants.asm:413`): `map_const CIANWOOD_GYM, 5, 9` (10x18 cells)
- Attributes (`data/maps/attributes.asm:652`): no connections
- Scene var: none, no callbacks, no coord events

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 17 | `CIANWOOD_CITY` | 2 |
| 2 | 5 | 17 | `CIANWOOD_CITY` | 2 |

**BG events**

| x | y | type | script/item |
|---|---|---|---|
| 3 | 15 | `BGEVENT_READ` | `CianwoodGymStatue` |
| 6 | 15 | `BGEVENT_READ` | `CianwoodGymStatue` |

**Object events**

| const | sprite | x | y | movement | type | sight | script label | event flag |
|---|---|---|---|---|---|---|---|---|
| `CIANWOODGYM_CHUCK` | `SPRITE_CHUCK` | 4 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | 0 | `CianwoodGymChuckScript` | -1 |
| `CIANWOODGYM_BLACK_BELT1` | `SPRITE_BLACK_BELT` | 2 | 12 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 3 | `TrainerBlackbeltYoshi` | -1 |
| `CIANWOODGYM_BLACK_BELT2` | `SPRITE_BLACK_BELT` | 7 | 12 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 3 | `TrainerBlackbeltLao` | -1 |
| `CIANWOODGYM_BLACK_BELT3` | `SPRITE_BLACK_BELT` | 3 | 9 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_TRAINER` | 2 | `TrainerBlackbeltNob` | -1 |
| `CIANWOODGYM_BLACK_BELT4` | `SPRITE_BLACK_BELT` | 5 | 5 | `SPRITEMOVEDATA_STANDING_LEFT` | `OBJECTTYPE_TRAINER` | 1 | `TrainerBlackbeltLung` | -1 |
| `CIANWOODGYM_BOULDER1` | `SPRITE_BOULDER` | 5 | 1 | `SPRITEMOVEDATA_STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | 0 | `CianwoodGymBoulder` | -1 |
| `CIANWOODGYM_BOULDER2` | `SPRITE_BOULDER` | 3 | 7 | `SPRITEMOVEDATA_STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | 0 | `CianwoodGymBoulder` | -1 |
| `CIANWOODGYM_BOULDER3` | `SPRITE_BOULDER` | 4 | 7 | `SPRITEMOVEDATA_STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | 0 | `CianwoodGymBoulder` | -1 |
| `CIANWOODGYM_BOULDER4` | `SPRITE_BOULDER` | 5 | 7 | `SPRITEMOVEDATA_STRENGTH_BOULDER` | `OBJECTTYPE_SCRIPT` | 0 | `CianwoodGymBoulder` | -1 |

The puzzle the walkthrough describes is `BOULDER2`/`BOULDER3`/`BOULDER4`, the
row at y = 7, x = 3/4/5. `BOULDER1` at (5,1) is Chuck's prop: he throws it as
part of his intro. Blackbelt Lung at (5,5) is behind the boulder row - the
walkthrough's "Use Strength to push your way to the last trainer before the gym
leader".

**Scripts of interest**

- `CianwoodGymChuckScript` (`pokegold.sym` 5d:5304):
  1. `checkevent EVENT_BEAT_CHUCK / iftrue .FightDone`.
  2. Intro: `writetext ChuckIntroText1`, `turnobject CIANWOODGYM_CHUCK, RIGHT`,
     `writetext ChuckIntroText2`,
     `applymovement CIANWOODGYM_BOULDER1, CianwoodGymMovement_ChuckChucksBoulder`
     (`set_sliding / big_step LEFT / big_step UP / fast_jump_step RIGHT /
     remove_sliding`), `playsound SFX_STRENGTH`, `earthquake 80`,
     `disappear CIANWOODGYM_BOULDER1`, `writetext ChuckIntroText3`.
  3. `winlosstext ChuckLossText, 0`, `loadtrainer CHUCK, CHUCK1`,
     `startbattle`, `reloadmapafterbattle`, `setevent EVENT_BEAT_CHUCK`.
  4. `writetext GetStormBadgeText`, `playsound SFX_GET_BADGE`,
     **`setflag ENGINE_STORMBADGE`**, then
     `readvar VAR_BADGES / scall CianwoodGymActivateRockets`.
     `CianwoodGymActivateRockets`: `ifequal 7, .RadioTowerRockets`,
     `ifequal 6, .GoldenrodRockets` (`jumpstd GoldenrodRocketsScript` /
     `RadioTowerRocketsScript`). With Storm as your 5th badge neither fires;
     it only matters if you took Chuck out of order.
  5. `.FightDone`: `checkevent EVENT_GOT_TM01_DYNAMICPUNCH / iftrue`, else
     **`setevent EVENT_BEAT_BLACKBELT_YOSHI` / `..._LAO` / `..._NOB` /
     `..._LUNG`**, then `verbosegiveitem TM_DYNAMICPUNCH` and
     `setevent EVENT_GOT_TM01_DYNAMICPUNCH`.

     **Bot-critical**: collecting the TM marks all four Blackbelts as beaten.
     Fight them *before* Chuck or their EXP and money are gone.
- `CianwoodGymBoulder`: `jumpstd StrengthBoulderScript` ->
  `farsjump AskStrengthScript` (`engine/events/std_scripts.asm:196`,
  `engine/events/overworld.asm:1001`). That script calls `TryStrengthOW`
  (`engine/events/overworld.asm:1038`), which needs a party mon knowing
  `STRENGTH` **and** `ENGINE_PLAINBADGE`.
- `CianwoodGymStatue`: `checkflag ENGINE_STORMBADGE` -> `GymStatue2Script` with
  `gettrainername STRING_BUFFER_4, CHUCK, CHUCK1`, else `GymStatue1Script`.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_BEAT_CHUCK` | `constants/event_flags.asm:711` | `CianwoodGymChuckScript` | badge earned; unlocks HM02 from Chuck's wife |
| `ENGINE_STORMBADGE` | `constants/engine_flags.asm:43` | `setflag` after the win | Fly's field gate (`engine/events/overworld.asm:545`), obedience up to L70 |
| `EVENT_GOT_TM01_DYNAMICPUNCH` | `constants/event_flags.asm:16` | `.FightDone` | one-time |
| `EVENT_BEAT_BLACKBELT_YOSHI/LAO/NOB/LUNG` | `constants/event_flags.asm` | set en masse by `.FightDone` | see the warning above |
| `ENGINE_PLAINBADGE` | `constants/engine_flags.asm:40` | read by `TryStrengthOW` | needed to shift the three boulders |

**Items**

| item | how obtained | source | one-time flag |
|---|---|---|---|
| `TM_DYNAMICPUNCH` (TM01) | talk to Chuck after the battle | `CianwoodGymChuckScript.FightDone` | `EVENT_GOT_TM01_DYNAMICPUNCH` |

**Trainers**

| const | class | id | party | script label |
|---|---|---|---|---|
| `YOSHI` | `BLACKBELT_T` | 2 | `TRAINERTYPE_MOVES`: 27 HITMONLEE (DOUBLE_KICK, MEDITATE, JUMP_KICK, FOCUS_ENERGY) | `TrainerBlackbeltYoshi` |
| `LAO` | `BLACKBELT_T` | 4 | `TRAINERTYPE_MOVES`: 27 HITMONCHAN (COMET_PUNCH, THUNDERPUNCH, ICE_PUNCH, FIRE_PUNCH) | `TrainerBlackbeltLao` |
| `NOB` | `BLACKBELT_T` | 5 | `TRAINERTYPE_MOVES`: 25 MACHOP (LEER, FOCUS_ENERGY, KARATE_CHOP, SEISMIC_TOSS), 25 MACHOKE (LEER, KARATE_CHOP, SEISMIC_TOSS, ROCK_SLIDE) | `TrainerBlackbeltNob` |
| `LUNG` | `BLACKBELT_T` | 7 | `TRAINERTYPE_NORMAL`: 23 MANKEY, 23 MANKEY, 25 PRIMEAPE | `TrainerBlackbeltLung` |
| `CHUCK1` | `CHUCK` | 1 | `ChuckGroup`, `TRAINERTYPE_MOVES`: 27 PRIMEAPE (LEER, RAGE, KARATE_CHOP, FURY_SWIPES), 30 POLIWRATH (HYPNOSIS, MIND_READER, SURF, DYNAMICPUNCH) | `CianwoodGymChuckScript` |

**Wild encounters** - none (indoor).

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Reaching Route 40's sea and therefore Route 41 / Cianwood | `engine/events/overworld.asm:490` `TrySurfOW` and `:340` `SurfFunction.TrySurf` - `ld de, ENGINE_FOGBADGE / call CheckBadge` | Fog Badge + a party mon that knows `SURF` (`CheckPartyMove`) | Fog Badge is Morty's, earned in section 07. HM03 SURF comes from the Route 42 / Sudowoodo beat |
| Cianwood Gym boulders at (3,7)/(4,7)/(5,7) | `CianwoodGymBoulder` -> `jumpstd StrengthBoulderScript` -> `engine/events/overworld.asm:1001` `AskStrengthScript` / `:1038` `TryStrengthOW` | `ENGINE_PLAINBADGE` **and** a party mon knowing `STRENGTH` | Plain Badge from Whitney (earlier section); HM04 from `OlivineCafeStrengthSailorScript` in this section |
| Secretpotion from the Cianwood pharmacist | `maps/CianwoodPharmacy.asm:CianwoodPharmacist` - `checkevent EVENT_JASMINE_EXPLAINED_AMPHYS_SICKNESS / iffalse .Mart` | that flag | talk to Jasmine on `MAP_OLIVINE_LIGHTHOUSE_6F` (`OlivineLighthouseJasmine`) |
| HM02 Fly from Chuck's wife | `maps/CianwoodCity.asm:CianwoodCityChucksWife` - `checkevent EVENT_BEAT_CHUCK` | Chuck beaten | `CianwoodGymChuckScript` |
| Using Fly in the field | `engine/events/overworld.asm:545` `FlyFunction.TryFly` - `ld de, ENGINE_STORMBADGE` | Storm Badge | the same gym win |
| Route 41 whirlpool tiles (Whirl Islands access only) | `engine/events/overworld.asm:1077` `WhirlpoolFunction.TryWhirlpool` / `:1171` `TryWhirlpoolOW` - `ld de, ENGINE_GLACIERBADGE` | Glacier Badge + `WHIRLPOOL` | Pryce, much later. **Not** required to reach Cianwood - the walkthrough's route only passes whirlpools, it never crosses one |
| Moomoo Farm berry feeding | `maps/Route39Barn.asm:MoomooScript` - `checkevent EVENT_TALKED_TO_FARMER_ABOUT_MOOMOO` | talk to `PokefanM_DairyFarmer` first | `PokefanM_DairyFarmer` sets it unconditionally |
| TM13 SNORE | `maps/Route39Farmhouse.asm:FarmerFScript_GiveSnore` - `checkevent EVENT_HEALED_MOOMOO` | 7 Berries fed to Moomoo | `MoomooScript.SevenBerries` |
| Shuckie | `maps/ManiasHouse.asm:ManiaScript` - `special GiveShuckle` returns false on a full party | one free party slot | box a mon at the Pokecenter first |
| Olivine rival cut-scene | `coord_event 13,12` / `13,13` gated on `SCENE_OLIVINECITY_RIVAL_ENCOUNTER` (`wOlivineCitySceneID` = 0) | none - it is unavoidable if you walk those cells | `setscene SCENE_OLIVINECITY_NOOP` at the end of either scene script |

Nothing in this section blocks the *walk* into Olivine City or up the
lighthouse. The only true forward gates are Surf (to leave Olivine westward),
the Jasmine-then-pharmacist flag chain, and Strength for the gym boulders.

## 4. Bot checklist

Preconditions carried in from earlier sections: `ENGINE_FOGBADGE`,
`ENGINE_PLAINBADGE`, `ENGINE_HIVEBADGE`, a mon that can learn `SURF`, a mon
that can learn `STRENGTH`, and ideally a stack of `BERRY` for Moomoo.

| # | Map | Target | Intent | Precondition | Postcondition |
|---|---|---|---|---|---|
| 1 | `ECRUTEAK_CITY` | warps 14/15 | walk in | - | on `ROUTE_38_ECRUTEAK_GATE` |
| 2 | `ROUTE_38_ECRUTEAK_GATE` | warp 1 (0,4) or 2 (0,5) | walk west | - | on `ROUTE_38` at (35,8)/(35,9) |
| 3 | `ROUTE_38` | `ROUTE38_STANDING_YOUNGSTER2` (15,10) | battle | - | `EVENT_BEAT_BIRD_KEEPER_TOBY` |
| 4 | `ROUTE_38` | `ROUTE38_FRUIT_TREE` (12,10) | press A facing it | - | `BERRY` in bag |
| 5 | `ROUTE_38` | `ROUTE38_SAILOR` (25,5) | battle | - | `EVENT_BEAT_SAILOR_HARRY` |
| 6 | `ROUTE_38` | `ROUTE38_LASS` (15,3) | battle, then talk again, answer YES | - | `EVENT_BEAT_LASS_DANA`, `PHONE_LASS_DANA` registered |
| 7 | `ROUTE_38` | `ROUTE38_BEAUTY` (9,6) | battle | - | `EVENT_BEAT_BEAUTY_VALERIE` |
| 8 | `ROUTE_38` | `ROUTE38_STANDING_YOUNGSTER1` (4,1) | battle, talk again for the number | - | `EVENT_BEAT_SCHOOLBOY_CHAD` |
| 9 | `ROUTE_38` | west edge | walk west (connection) | - | on `ROUTE_39` |
| 10 | `ROUTE_39` | `ROUTE39_PSYCHIC_NORMAN` (13,6) | battle | - | `EVENT_BEAT_PSYCHIC_NORMAN` |
| 11 | `ROUTE_39` | `ROUTE39_FRUIT_TREE` (9,3) | press A | - | `MINT_BERRY` |
| 12 | `ROUTE_39` | (5,13) | press A (hidden) | - | `NUGGET`, `EVENT_ROUTE_39_HIDDEN_NUGGET` |
| 13 | `ROUTE_39` | warp 2 (5,3) -> farmhouse, `ROUTE39FARMHOUSE_POKEFAN_M` (3,2) | talk | - | `EVENT_TALKED_TO_FARMER_ABOUT_MOOMOO` |
| 14 | `ROUTE_39_BARN` (via Route 39 warp 1 at (1,3)) | `ROUTE39BARN_MOOMOO` (3,3) | talk, YES, x7 with a `BERRY` each time | step 13 done, 7 `BERRY` in bag | `wMooMooBerries` = 7, `EVENT_HEALED_MOOMOO` |
| 15 | `ROUTE_39_FARMHOUSE` | `ROUTE39FARMHOUSE_POKEFAN_F` (5,4) | talk | `EVENT_HEALED_MOOMOO` | `TM_SNORE`, `EVENT_GOT_TM13_SNORE_FROM_MOOMOO_FARM` |
| 16 | `ROUTE_39` | `ROUTE39_POKEFAN_M` (11,19), `ROUTE39_POKEFAN_F` (13,22), `ROUTE39_SAILOR` (13,29) | battle each | - | three `EVENT_BEAT_*` |
| 17 | `ROUTE_39` | south edge | walk south (connection) | - | on `OLIVINE_CITY`, `ENGINE_FLYPOINT_OLIVINE` set by the NEWMAP callback |
| 18 | `OLIVINE_CITY` | (13,12) or (13,13) | walk onto the cell | `wOlivineCitySceneID` == 0 | rival scene runs; scene -> 1; `SPRITE_OLIVINE_RIVAL` re-pointed to `SPRITE_SWIMMER_GUY` |
| 19 | `OLIVINE_CITY` | warp 6 (13,15) -> `OLIVINEGOODRODHOUSE_FISHING_GURU` (2,3) | talk, answer YES | - | `GOOD_ROD`, `EVENT_GOT_GOOD_ROD` |
| 20 | `OLIVINE_CITY` | warp 1 (13,21) | heal | - | party healed; spawn point already (13,22) |
| 21 | `OLIVINE_CITY` | warp 7 (7,21) -> `OLIVINECAFE_SAILOR` (4,3) | talk | - | `HM_STRENGTH`, `EVENT_GOT_HM04_STRENGTH` |
| 22 | (menu) | any eligible mon | teach `STRENGTH` from HM04 | - | Strength usable once `ENGINE_PLAINBADGE` is held |
| 23 | `OLIVINE_CITY` | warp 9 (29,27) | walk in | - | on `OLIVINE_LIGHTHOUSE_1F` |
| 24 | `OLIVINE_LIGHTHOUSE_1F` | warp 3 (3,11) | stairs | - | `OLIVINE_LIGHTHOUSE_2F` (3,11) |
| 25 | `OLIVINE_LIGHTHOUSE_2F` | `..._GENTLEMAN` (17,8), `..._SAILOR` (9,3) | battle both; talk to Huey again for his number | - | `EVENT_BEAT_GENTLEMAN_ALFRED`, `EVENT_BEAT_SAILOR_HUEY` |
| 26 | `OLIVINE_LIGHTHOUSE_2F` | warp 2 (5,3) | stairs | - | `OLIVINE_LIGHTHOUSE_3F` (5,3) |
| 27 | `OLIVINE_LIGHTHOUSE_3F` | `..._YOUNGSTER` (3,9), `..._GENTLEMAN` (13,5) | battle | - | `EVENT_BEAT_BIRD_KEEPER_THEO`, `EVENT_BEAT_GENTLEMAN_PRESTON` |
| 28 | `OLIVINE_LIGHTHOUSE_3F` | warp 1 (13,3) | stairs | - | `OLIVINE_LIGHTHOUSE_4F` (13,3) |
| 29 | `OLIVINE_LIGHTHOUSE_4F` | `..._LASS` (11,2), `..._SAILOR` (7,14) | battle | - | `EVENT_BEAT_LASS_CONNIE`, `EVENT_BEAT_SAILOR_KENT` |
| 30 | `OLIVINE_LIGHTHOUSE_4F` | warp 2 (3,5) | stairs | - | `OLIVINE_LIGHTHOUSE_5F` (3,5) |
| 31 | `OLIVINE_LIGHTHOUSE_5F` | item ball (2,13) | press A | - | `TM_SWAGGER`, `EVENT_OLIVINE_LIGHTHOUSE_5F_TM_SWAGGER` |
| 32 | `OLIVINE_LIGHTHOUSE_5F` | (3,13) | press A (hidden) | - | `HYPER_POTION` |
| 33 | `OLIVINE_LIGHTHOUSE_5F` | `..._YOUNGSTER` (8,3) | battle | - | `EVENT_BEAT_BIRD_KEEPER_DENIS` |
| 34 | `OLIVINE_LIGHTHOUSE_5F` | item ball (15,12) | press A | - | `RARE_CANDY` |
| 35 | `OLIVINE_LIGHTHOUSE_5F` | warp 4 (16,7) | drop to 4F | - | `OLIVINE_LIGHTHOUSE_4F` (16,7) |
| 36 | `OLIVINE_LIGHTHOUSE_4F` | warp 7 (8,3) or 8 (9,3) | drop to 3F | - | `OLIVINE_LIGHTHOUSE_3F` (8,3)/(9,3) |
| 37 | `OLIVINE_LIGHTHOUSE_3F` | `..._SAILOR` (9,2) | battle | - | `EVENT_BEAT_SAILOR_TERRELL` |
| 38 | `OLIVINE_LIGHTHOUSE_3F` | item ball (8,2) | press A | - | `ETHER` |
| 39 | `OLIVINE_LIGHTHOUSE_3F` | warp 1 (13,3), then 4F warp 2 (3,5) | back up to 5F | - | on 5F |
| 40 | `OLIVINE_LIGHTHOUSE_5F` | `..._SAILOR` (8,11) | battle | - | `EVENT_BEAT_SAILOR_ERNEST` |
| 41 | `OLIVINE_LIGHTHOUSE_5F` | item ball (6,15) | press A | - | `GREAT_BALL` |
| 42 | `OLIVINE_LIGHTHOUSE_5F` | warp 1 (9,15) | stairs | - | `OLIVINE_LIGHTHOUSE_6F` (9,15) |
| 43 | `OLIVINE_LIGHTHOUSE_6F` | `OLIVINELIGHTHOUSE6F_JASMINE` (8,8) | talk | no `SECRETPOTION` in bag | **`EVENT_JASMINE_EXPLAINED_AMPHYS_SICKNESS`** |
| 44 | `OLIVINE_LIGHTHOUSE_6F` | item ball (3,4) | press A | - | `SUPER_POTION` |
| 45 | `OLIVINE_LIGHTHOUSE_6F` .. `1F` | (16,5) -> (16,7) -> (16,9) -> (16,11) -> (16,13) | walk the right-wall drop chain | - | back on `OLIVINE_LIGHTHOUSE_1F` |
| 46 | `OLIVINE_LIGHTHOUSE_1F` | warp 1 (10,17) | exit | - | `OLIVINE_CITY` (29,27) |
| 47 | `OLIVINE_CITY` | warp 1 (13,21) | heal | - | - |
| 48 | (menu) | a water mon | teach `SURF` (HM03) | HM03 in bag | Surf usable (`ENGINE_FOGBADGE` already held) |
| 49 | `OLIVINE_CITY` | warp 8 (19,17) | buy `GREAT_BALL` etc. | money | - |
| 50 | `OLIVINE_CITY` | west edge | walk west (connection) | - | on `ROUTE_40` |
| 51 | `ROUTE_40` | face the sea, press A / use SURF | start surfing | `ENGINE_FOGBADGE` + `SURF` | `PLAYER_SURF` |
| 52 | `ROUTE_40` | (14,15), (3,19), (10,25), (18,30) | battle Simon, Elaine, Paula, Randall | - | four `EVENT_BEAT_SWIMMER*` |
| 53 | `ROUTE_40` | (11,7) rock then (11,7) hidden | Rock Smash, then press A | `ROCK_SMASH` | `HYPER_POTION`; the rock roll can also yield 10% SHUCKLE 15 |
| 54 | `ROUTE_40` | south edge | swim south (connection) | - | on `ROUTE_41` |
| 55 | `ROUTE_41` | (46,8) George, (44,28) Kara, (32,6) Charlie, (9,50) Wendy, (23,19) Susie, (20,26) Berke, (27,34) Denise, (32,30) Kirk, (19,46) Mathew, (17,4) Kaylee | battle as encountered | - | ten `EVENT_BEAT_SWIMMER*` |
| 56 | `ROUTE_41` | (9,35) | press A (hidden) | - | `MAX_ETHER` |
| 57 | `ROUTE_41` | west edge | swim west (connection) | - | on `CIANWOOD_CITY`; `ENGINE_FLYPOINT_CIANWOOD` set |
| 58 | `CIANWOOD_CITY` | warp 3 (23,43) | heal, deposit a mon to free a party slot | - | party size < 6 |
| 59 | `CIANWOOD_CITY` | warp 1 (17,41) -> `MANIASHOUSE_ROCKER` (2,4) | talk, answer YES | free party slot | `EVENT_GOT_SHUCKIE`, L15 SHUCKLE "SHUCKIE" holding `BERRY`, OT MANIA |
| 60 | `CIANWOOD_CITY` | warp 4 (15,47) -> `CIANWOODPHARMACY_PHARMACIST` (2,3) | talk | **`EVENT_JASMINE_EXPLAINED_AMPHYS_SICKNESS`** | `SECRETPOTION`, `EVENT_GOT_SECRETPOTION_FROM_PHARMACY` |
| 61 | `CIANWOOD_CITY` | (8,16) and (5,29) | Rock Smash the rock, press A | `ROCK_SMASH` | `REVIVE`, `MAX_ETHER` |
| 62 | `CIANWOOD_CITY` | warp 2 (8,43) | enter gym | - | on `CIANWOOD_GYM` (4,17) |
| 63 | `CIANWOOD_GYM` | (2,12) Yoshi, (7,12) Lao | battle both | - | `EVENT_BEAT_BLACKBELT_YOSHI`, `..._LAO` |
| 64 | `CIANWOOD_GYM` | (3,9) Nob | battle | - | `EVENT_BEAT_BLACKBELT_NOB` |
| 65 | `CIANWOOD_GYM` | boulders at (3,7),(4,7),(5,7) | use Strength, push a lane open | `ENGINE_PLAINBADGE` + `STRENGTH` | path north |
| 66 | `CIANWOOD_GYM` | (5,5) Lung | battle | - | `EVENT_BEAT_BLACKBELT_LUNG` |
| 67 | `CIANWOOD_CITY` | warp 3 | heal, save | - | - |
| 68 | `CIANWOOD_GYM` | `CIANWOODGYM_CHUCK` (4,1) | talk -> battle | all four blackbelts already beaten | `EVENT_BEAT_CHUCK`, `ENGINE_STORMBADGE`, 3000 gold |
| 69 | `CIANWOOD_GYM` | `CIANWOODGYM_CHUCK` | talk again | `EVENT_BEAT_CHUCK` | `TM_DYNAMICPUNCH`, `EVENT_GOT_TM01_DYNAMICPUNCH` |
| 70 | `CIANWOOD_CITY` | `CIANWOODCITY_POKEFAN_F` (10,46) | talk | `EVENT_BEAT_CHUCK` | `HM_FLY`, `EVENT_GOT_HM02_FLY` |
| 71 | (menu) | a flying-capable mon | teach `FLY` | `ENGINE_STORMBADGE` | fly available; section ends, next section flies back to Olivine |

## 5. Port coverage

The Gen 2 port is engine-level and data-driven: every map header, `.blk`,
warp/coord/bg/object table and script bytecode in this section is read out of
the ROM by `src/import/RomExtractorGen2.lua` (`readMapEvents` at lines 785-862,
map records written at 973-976) rather than hand-transcribed, so "implemented"
below means the *opcodes and specials these particular scripts use* are
implemented, not that anyone has walked the maps.

| Beat | Port file | Status |
|---|---|---|
| Map headers, warps, coord events, bg events, object events for all 21 maps | `src/import/RomExtractorGen2.lua`, `src/world/gen2/Map.lua`, `src/world/gen2/World.lua` | implemented (generic, ROM-driven) |
| `MAPCALLBACK_NEWMAP` fly-point callbacks (`OlivineCityFlypointCallback`, `CianwoodCityFlypointCallback`) | `src/world/gen2/World.lua`, driver `tests/drivers/gold_map_callbacks.lua` | implemented |
| `MAPCALLBACK_OBJECTS` weekday callback (`Route40MonicaCallback`) | `src/world/gen2/World.lua` + `readvar VAR_WEEKDAY` in `src/script/gen2/Opcodes.lua` | implemented |
| Scene scripts / `setscene` / coord-event trip-wires (the Olivine rival) | `src/world/gen2/World.lua` (`mapScenes`, `setScene`, `setMapScene`), `src/script/gen2/Vm.lua` | implemented |
| Rival cut-scene opcodes: `showemote`, `applymovement`, `appear`/`disappear`, `variablesprite`, `special LoadUsedSpritesGFX`, `special FadeOutMusic`/`RestartMapMusic` | `src/script/gen2/Opcodes.lua`, `src/script/gen2/Movement.lua`, `src/script/gen2/Specials.lua` | implemented |
| Trainer objects, sight ranges, `loadtrainer`/`startbattle`/`winlosstext` | `src/world/gen2/Trainers.lua`, `src/script/gen2/Vm.lua`, driver `tests/drivers/gold_trainer_smoke.lua` | implemented |
| Phone registration and rematch tiers (Dana, Chad, Derek, Huey) | `src/core/gen2/Phone.lua`; `checkcellnum` / `askforphonenumber` in `src/script/gen2/Opcodes.lua` | implemented |
| Item balls (`OBJECTTYPE_ITEMBALL`) and hidden items (`BGEVENT_ITEM`) | `src/world/gen2/World.lua` (bg-event jumptable), `src/world/gen2/HiddenItems.lua` | implemented |
| Fruit trees (`fruittree FRUITTREE_ROUTE_38/39`) | `fruittree` opcode in `src/script/gen2/Opcodes.lua` | implemented |
| Moomoo Farm berry counter (`readmem`/`addval`/`writemem wMooMooBerries`) | `src/script/gen2/Vm.lua:711` and `:1657` (`scriptMem`), persisted by `src/core/gen2/Save.lua:187` | implemented - the port names this exact WRAM slot |
| `verbosegiveitem` / `giveitem` / `takeitem` / `checkitem` / `itemnotify` (Good Rod, HM04, TM13, Secretpotion, HM02, TM01) | `src/script/gen2/Opcodes.lua` | implemented |
| Moomoo Milk purchase (`checkmoney` / `takemoney` / `giveitem`) | `src/script/gen2/Opcodes.lua` | implemented |
| Marts: `MARTTYPE_STANDARD` (`MART_OLIVINE`) and `MARTTYPE_PHARMACY` (`MART_CIANWOOD`) | `src/ui/gen2/MartMenu.lua` (`PHARMACY` table at :212) | implemented |
| Shuckie: `special GiveShuckle` / `special ReturnShuckie`, OT MANIA id 518, happiness arms, `ENGINE_GOT_SHUCKIE_TODAY` | `src/script/gen2/Specials.lua:1191` onward | implemented |
| Cianwood photo studio `special PhotoStudio` | `src/script/gen2/Specials.lua:2122`, `src/ui/gen2/PhotoStudio.lua` | implemented |
| Jasmine cure scene: `special PlaySlowCry`, `special FadeOutToWhite`/`FadeInFromWhite`, `cry AMPHAROS`, `readvar VAR_FACING` branch | `src/script/gen2/Specials.lua` (998, 1000, 1079), `src/script/gen2/Opcodes.lua` | implemented |
| Surf field move + `ENGINE_FOGBADGE` gate | `src/world/gen2/FieldMoves.lua` (`surfFromMenu`, `TrySurfOW` port), driver `tests/drivers/gold_water_moves.lua` (its `WHIRL` fixture is literally `ROUTE_41` (22,11)) | implemented |
| Strength field move + `ENGINE_PLAINBADGE` gate + `STRENGTH_BOULDER` pushing | `src/world/gen2/FieldMoves.lua` (`strengthFromMenu`, the 3-way `TryStrengthOW` result at :689), driver `tests/drivers/gold_icepath_boulder.lua` | implemented |
| Fly field move + `ENGINE_STORMBADGE` gate, fly points | `src/world/gen2/FieldMoves.lua:330` (`flypoints.asm` transcribed), `:504` `flyFromMenu` | implemented |
| Whirlpool + `ENGINE_GLACIERBADGE` gate (Route 41 flavour, Whirl Islands) | `src/world/gen2/FieldMoves.lua:542`, `:625` | implemented |
| Badge award: `setflag ENGINE_STORMBADGE`, `readvar VAR_BADGES`, `scall` into `GoldenrodRocketsScript`/`RadioTowerRocketsScript` | `src/script/gen2/Opcodes.lua` (`setflag`, `checkflag`), `src/script/gen2/Vm.lua` | implemented |
| Chuck's boulder throw: `earthquake 80`, `set_sliding`/`big_step`/`fast_jump_step` | `earthquake` in `src/script/gen2/Opcodes.lua`, movement verbs in `src/script/gen2/Movement.lua` | implemented |
| Water wild encounters for Route 40 / 41 / Olivine / Cianwood, Gold-vs-Silver Mantine split | `src/battle/gen2/Encounter.lua`, tables from `RomExtractorGen2.lua` | implemented |
| Good Rod fishing (`FISHGROUP_SHORE` / `FISHGROUP_OCEAN`, `TimeFishGroups`) | `src/battle/gen2/Encounter.lua` (`Encounter.fish`), extractor `readRod` | implemented |
| Headbutt trees on Route 38/39 (`TREEMON_SET_FOREST`) | `src/battle/gen2/Encounter.lua:114` onward, `RomExtractorGen2.lua:3780` | implemented |
| **Rock Smash wild encounters (`RockMonMaps` -> `TREEMON_SET_ROCK`, i.e. Shuckle/Krabby on Route 40 and Cianwood City)** | `src/script/gen2/CallAsm.lua:526` explicitly stubs `RockMonEncounter` with "ROCK SMASH has no field-move path yet; RockMonMaps is unported"; `RomExtractorGen2.lua` extracts `TreeMonMaps` only | **missing** |
| Roaming / phone-call flavour beats the walkthrough mentions (Arnie, Liz, Todd, Mom's doll) | `src/core/gen2/Phone.lua` (incoming/special call machinery), `src/core/gen2/MomShopping.lua` | implemented (generic); no per-call verification done for this section |
| Any driver that actually walks Route 38 -> Cianwood end to end | - | **missing** - no `tests/drivers/gold_*` covers this stretch. `gold_water_moves.lua` touches `ROUTE_41` (22,11) only as a whirlpool fixture |

## 6. Unresolved / verify by hand

1. **"Beauty Olivia" on Route 38.** The walkthrough says "Now move southward
   now to face Beauty Olivia." There is no `OLIVIA` in
   `constants/trainer_constants.asm` (the `BEAUTY` class runs VICTORIA,
   SAMANTHA, JULIE, JACLYN, BRENDA, CASSIE, CAROLINE, CARLENE, JESSICA,
   RACHAEL, ANGELICA, KENDRA, VERONICA, JULIA, THERESA, VALERIE), no `OLIVIA`
   string in `data/trainers/parties.asm`, and `maps/Route38.asm` has exactly
   five trainer objects. This trainer does not exist in pokegold.
2. **"#100 Voltorb" listed under "Pokémon found in Olivine City".** Olivine
   City has no grass encounter table at all, and its water table
   (`data/wild/johto_water.asm:239`) is TENTACOOL / TENTACOOL / TENTACRUEL.
   Voltorb is not reachable on this map by any table I could find. Unverified.
3. **"#213 Shuckle" listed under Route 40 *and* Route 41.** Route 40 is correct
   but by Rock Smash, not by surfing: `data/wild/treemon_maps.asm:45` puts it
   in `RockMonMaps` with `TREEMON_SET_ROCK` (10% SHUCKLE 15). Route 41 is
   **not** in `RockMonMaps`, has `TREEMON_SET_NONE` for headbutt, and its
   `Route41Rock` script is marked `; unreferenced` in the asm. Shuckle appears
   unobtainable on Route 41.
4. **Swimmer Charlie's second Pokemon.** Walkthrough: "Level 21 Tentacool".
   `data/trainers/parties.asm` `SwimmerMGroup` "CHARLIE" (`SWIMMERM` 4) reads
   `db 21, SHELLDER / db 19, TENTACOOL / db 19, TENTACRUEL`. Level 19, not 21.
5. **Bird Keeper Denis's party order.** Walkthrough lists Spearow, Spearow,
   Fearow; the asm order is `18 SPEAROW / 20 FEAROW / 18 SPEAROW`.
6. **Swimmer Kaylee** (`SWIMMERF` 3, 18 GOLDEEN / 20 GOLDEEN / 20 SEAKING) at
   `ROUTE_41` (17,4) is a real trainer the walkthrough never mentions.
7. **Whether the x = 16/17 lighthouse pairs are one-way holes or two-way
   passages.** The warp tables are symmetric (every pair points back at the
   coordinates it came from), so warp data alone cannot tell you. Whichever it
   is lives in the block collision for `TILESET_LIGHTHOUSE` and the `.blk`
   files, which I did not decode. The walkthrough treats them as one-way drops
   and the geometry is consistent with that, but treat "can I climb back up
   through (16,7)?" as unverified.
8. **"You can avoid fighting the next trainer" (Bird Keeper Theo, 3F).** Theo
   has sight range 3 at (3,9); whether a walkable lane exists outside that
   cone depends on the 3F `.blk`, not the object table.
9. **The exact spot the walkthrough means by "Now, swim south onto Route 41"
   and the "left side / right side" split.** Route 41's two branches are
   geometry in `maps/Route41.blk`; the object coordinates above are the only
   hard data. A bot should path by trainer coordinates rather than by the
   prose.
10. **Phone-call timing claims** ("Arnie calls again", "Liz then calls you
    about her Nidoran", "Todd will now call", "Mom calls saying she bought you
    an adorable doll"). These come from `CheckPhoneCall` in
    `engine/overworld/time.asm` plus `data/phone/*.asm`, not from any script in
    these maps, and the walkthrough's own quoted note says the caller and topic
    are random. Nothing in this section's asm schedules them.
11. **"3000G" from Chuck.** Prize money is computed from the trainer class base
    in `data/trainers/attributes.asm` times the last mon's level, not written
    anywhere in `maps/CianwoodGym.asm`. I did not verify the arithmetic.
12. **"TM23" under "Items found in Olivine City".** TM23 is Jasmine's gym
    reward in `maps/OlivineGym.asm`, which belongs to section 09; nothing on
    `MAP_OLIVINE_CITY` itself yields it.

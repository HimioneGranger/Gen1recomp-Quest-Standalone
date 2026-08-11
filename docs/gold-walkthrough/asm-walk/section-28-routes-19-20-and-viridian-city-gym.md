# Section 28 - Routes 19-20 and Viridian City Gym

Source: `../section-28-routes-19-20-and-viridian-city-gym.txt` (the FAQ numbers this chapter "34 > Routes 19-20 and Viridian City Gym")
Maps covered: `MAP_ROUTE_20`, `MAP_ROUTE_19`, `MAP_ROUTE_19_FUCHSIA_GATE`, `MAP_VIRIDIAN_CITY`, `MAP_VIRIDIAN_POKECENTER_1F`, `MAP_VIRIDIAN_GYM`
Badges / key milestones in this section: EARTHBADGE (`ENGINE_EARTHBADGE`) from Blue in Viridian Gym, `EVENT_BEAT_BLUE`, five optional Swimmer battles on Routes 19/20. This is the 16th badge, which is what `maps/OaksLab.asm` reads to open Mt. Silver in a later section.

Map group / id pairs a bot needs (from `constants/map_constants.asm`):

| Map constant | group | id |
|---|---|---|
| `MAP_ROUTE_19_FUCHSIA_GATE` | 6 (`CINNABAR`, `constants/map_constants.asm:175`) | 3 |
| `MAP_ROUTE_19` | 6 | 5 |
| `MAP_ROUTE_20` | 6 | 6 |
| `MAP_VIRIDIAN_CITY` | 23 (`VIRIDIAN`, `constants/map_constants.asm:420`) | 3 |
| `MAP_VIRIDIAN_GYM` | 23 | 4 |
| `MAP_VIRIDIAN_POKECENTER_1F` | 23 | 9 |

Coordinate convention reminder: `warp_event` / `coord_event` / `bg_event` / `object_event` all take `x, y` in map cell coordinates, 0-based from the top-left (`macros/scripts/maps.asm:63`, `:79`, `:97`, `:113`). A map that is `W, H` blocks is `2W, 2H` cells. `changeblock` also takes cell coordinates and halves them internally (`engine/overworld/scripting.asm:2030` `Script_changeblock`, `home/map.asm:2099` `GetBlockLocation`).

## 1. Route order

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|
| 0 | `MAP_SEAFOAM_GYM` | `maps/SeafoamGym.asm` (previous section) | - | its exit warp back to Route 20 warp 1 | Blaine's gym sits on Route 20; the previous section ends there |
| 1 | `MAP_ROUTE_20` | `maps/Route20.asm` | Seafoam Gym exit -> Route 20 warp 1 `(38, 7)`, or the west connection from Cinnabar Island | east map connection to Route 19 (`data/maps/attributes.asm:285`, offset -9) | "East on Route 20 and to Route 19 are optional ... Surf down and right to face the swimmer in the water" (Lori, then Nicole) |
| 2 | `MAP_ROUTE_19` | `maps/Route19.asm` | west map connection from Route 20 (`data/maps/attributes.asm:289`, offset 9) | Fly (walkthrough), or warp 1 `(7, 3)` -> `ROUTE_19_FUCHSIA_GATE` warp 3, or the north connection to Fuchsia City | "You'll find a drowning guy next to a girl" (Tucker, Dawn, then Jerome). "Fly back to Viridian City instead" |
| 2a | `MAP_ROUTE_19_FUCHSIA_GATE` | `maps/Route19FuchsiaGate.asm` | Route 19 warp 1 | warps 1/2 `(4, 0)` / `(5, 0)` -> `FUCHSIA_CITY` warps 10 / 11 | Only referenced by the walkthrough's "blocked ... south of Fuchsia City" line; see section 6 |
| 3 | `MAP_VIRIDIAN_CITY` | `maps/ViridianCity.asm` | Fly (`ENGINE_FLYPOINT_VIRIDIAN`, spawn `(23, 26)`) | warp 5 `(23, 25)` -> Pokecenter; warp 1 `(32, 7)` -> gym | "fly back to Viridian City ... First, heal at the Pokémon Center" |
| 4 | `MAP_VIRIDIAN_POKECENTER_1F` | `maps/ViridianPokecenter1F.asm` | Viridian warp 5 | warps 1/2 `(3, 7)` / `(4, 7)` -> Viridian warp 5 | Heal before and after Blue |
| 5 | `MAP_VIRIDIAN_GYM` | `maps/ViridianGym.asm` | Viridian warp 1 `(32, 7)` | warps 1/2 `(4, 17)` / `(5, 17)` -> Viridian warp 1 | "GYM LEADER BLUE ... You get: Earth Badge, 5,800G" |

Spillover: the closing line "There are still a few things you can do before you clear Kanto" points at `maps/OaksLab.asm:26` (`readvar VAR_BADGES` / `ifequal NUM_BADGES, .OpenMtSilver`), which belongs to the next section. Nothing past the Viridian Gym exit is described here.

## 2. Maps

### MAP_ROUTE_20

- Script: `maps/Route20.asm`
- Blocks: `maps/Route20.blk` (`data/maps/blocks.asm:118` `Route20_Blocks`)
- Header: `data/maps/maps.asm:197` -> `TILESET_KANTO`, `ROUTE`, `LANDMARK_ROUTE_20`, `MUSIC_ROUTE_3`, phone `FALSE`, `PALETTE_AUTO`, `FISHGROUP_OCEAN`
- Dimensions: `constants/map_constants.asm:181` `map_const ROUTE_20, 30, 9` (30x9 blocks = 60x18 cells)
- Connections: `data/maps/attributes.asm:283-285` - west `CinnabarIsland` (`CINNABAR_ISLAND`, offset 0), east `Route19` (`ROUTE_19`, offset -9). No north/south.
- Map events block: `Route20_MapEvents`, sym `4e:4ecd`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 38 | 7 | `SEAFOAM_GYM` | 1 |

**Coord events** (`def_coord_events`) - none (`def_coord_events` is empty).

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 37 | 11 | `BGEVENT_READ` | `CinnabarGymSign` (sym `4e:4d3a`) -> `CinnabarGymSignText` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE20_SWIMMER_GIRL1` | `SPRITE_SWIMMER_GIRL` | 52 | 8 | `SPRITEMOVEDATA_SPINRANDOM_FAST` (radius 0,0) | `OBJECTTYPE_TRAINER`, sight 3, `PAL_NPC_GREEN` | `TrainerSwimmerfNicole` (sym `4e:4cfe`) | -1 (always present) |
| `ROUTE20_SWIMMER_GIRL2` | `SPRITE_SWIMMER_GIRL` | 45 | 13 | `SPRITEMOVEDATA_SPINRANDOM_FAST` (radius 0,0) | `OBJECTTYPE_TRAINER`, sight 3, `PAL_NPC_GREEN` | `TrainerSwimmerfLori` (sym `4e:4d12`) | -1 |
| `ROUTE20_SWIMMER_GUY` | `SPRITE_SWIMMER_GUY` | 12 | 13 | `SPRITEMOVEDATA_SPINRANDOM_FAST` (radius 0,0) | `OBJECTTYPE_TRAINER`, sight 3, `PAL_NPC_RED` | `TrainerSwimmermCameron` (sym `4e:4d26`) | -1 |

**Scripts of interest**

- `Route20_MapScripts` (`maps/Route20.asm:6`): no scene scripts; one callback, `callback MAPCALLBACK_NEWMAP, Route20ClearRocksCallback`.
- `Route20ClearRocksCallback` (`maps/Route20.asm:12`, sym `4e:4cfa`): two opcodes, `setevent EVENT_CINNABAR_ROCKS_CLEARED` then `endcallback`. This is the single most load-bearing fact on this map: merely *entering* Route 20 for the first time permanently clears the Route 19 boulders. There is no other setter of that flag anywhere in `maps/`.
- The three trainer scripts are the stock pattern: `trainer <CLASS>, <ID>, <EVENT>, SeenText, BeatenText, 0, .Script`, and `.Script` is `endifjustbattled / opentext / writetext <AfterBattleText> / waitbutton / closetext / end`. No items, no flags beyond the trainer's own beat flag.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_CINNABAR_ROCKS_CLEARED` | `constants/event_flags.asm:214` | set by `Route20ClearRocksCallback`; read by `Route19ClearRocksCallback`, `Route19Fisher1Script`, `Route19Fisher2Script`, `Route19FuchsiaGateOfficerScript` | Once set, the six Route 19 boulder blocks are never placed |
| `EVENT_BEAT_SWIMMERF_NICOLE` | `constants/event_flags.asm:487` | `TrainerSwimmerfNicole` | One-time battle |
| `EVENT_BEAT_SWIMMERF_LORI` | `constants/event_flags.asm:488` | `TrainerSwimmerfLori` | One-time battle |
| `EVENT_BEAT_SWIMMERM_CAMERON` | `constants/event_flags.asm:957` | `TrainerSwimmermCameron` | One-time battle; the walkthrough never mentions him |

**Items** - none on this map (the only `bg_event` is a readable sign; no `hiddenitem`, no item balls).

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `SWIMMERF` / `LORI` | 27 (`constants/trainer_constants.asm:375`) | LORI = `SwimmerFGroup` entry 15 | `data/trainers/parties.asm:1781` `SwimmerFGroup` (sym `0e:69c7`), `TRAINERTYPE_NORMAL`: L32 STARMIE, L32 STARMIE | `TrainerSwimmerfLori` | none (no `phone_call` / rematch entry) |
| `SWIMMERF` / `NICOLE` | 27 | NICOLE = `SwimmerFGroup` entry 14 | `TRAINERTYPE_NORMAL`: L29 MARILL, L29 MARILL, L32 LAPRAS | `TrainerSwimmerfNicole` | none |
| `SWIMMERM` / `CAMERON` | 26 (`constants/trainer_constants.asm:352`) | CAMERON = `SwimmerMGroup` entry 17 | `data/trainers/parties.asm:1640` `SwimmerMGroup` (sym `0e:68a8`), `TRAINERTYPE_NORMAL`: L34 MARILL | `TrainerSwimmermCameron` | none |

Prize money: `data/trainers/attributes.asm:227` gives class Swimmerm base reward 2, `:233` gives Swimmerf base reward 5, no held items. `engine/battle/read_trainer_party.asm:300` `ComputeTrainerReward` = base x level of the last mon, and `engine/battle/core.asm:2340-2362` pays that quarter out four times, so the wallet figure is `4 x base x level`: Lori and Nicole `4 x 5 x 32 = 640` (matches the FAQ), Cameron `4 x 2 x 34 = 272`.

**Wild encounters**

- Surfing: `data/wild/kanto_water.asm:54` `def_water_wildmons ROUTE_20`, encounter rate `6 percent`: L35 TENTACOOL, L30 TENTACOOL, L35 TENTACRUEL. No morn/day/nite split (water tables have a single slot list).
- No entry in `data/wild/kanto_grass.asm` (the map has no grass), none in `data/wild/treemons.asm`.
- Fishing: header fish group is `FISHGROUP_OCEAN` (`data/maps/maps.asm:197`), `data/wild/fish.asm` `.Ocean_Old` / `.Ocean_Good` / `.Ocean_Super` (lines 42-55): Old = MAGIKARP/MAGIKARP/TENTACOOL L10; Good = MAGIKARP L20, TENTACOOL L20, CHINCHOU L20, time group 2; Super = CHINCHOU L40, time group 3, TENTACRUEL L40, LANTURN L40.

### MAP_ROUTE_19

- Script: `maps/Route19.asm`
- Blocks: `maps/Route19.blk` (`data/maps/blocks.asm:48` `Route19_Blocks`)
- Header: `data/maps/maps.asm:196` -> `TILESET_KANTO`, `ROUTE`, `LANDMARK_ROUTE_19`, `MUSIC_ROUTE_3`, phone `FALSE`, `PALETTE_AUTO`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:180` `map_const ROUTE_19, 10, 18` (10x18 blocks = 20x36 cells)
- Connections: `data/maps/attributes.asm:287-289` - north `FuchsiaCity` (`FUCHSIA_CITY`, offset 0), west `Route20` (`ROUTE_20`, offset 9). No south/east.
- Map events block: `Route19_MapEvents`, sym `4e:535c`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 7 | 3 | `ROUTE_19_FUCHSIA_GATE` | 3 |

**Coord events** (`def_coord_events`) - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 11 | 13 | `BGEVENT_READ` | `Route19Sign` (sym `4e:4fa0`) -> `Route19SignText` |
| 11 | 1 | `BGEVENT_READ` | `CarefulSwimmingSign` (sym `4e:4fa3`) -> `CarefulSwimmingSignText` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE19_SWIMMER_GIRL` | `SPRITE_SWIMMER_GIRL` | 9 | 23 | `SPRITEMOVEDATA_STANDING_LEFT` (radius 0,0) | `OBJECTTYPE_TRAINER`, sight **0**, `PAL_NPC_GREEN` | `TrainerSwimmerfDawn` (sym `4e:4f28`) | -1 |
| `ROUTE19_SWIMMER_GUY1` | `SPRITE_SWIMMER_GUY` | 13 | 28 | `SPRITEMOVEDATA_SPINRANDOM_FAST` (radius 0,0) | `OBJECTTYPE_TRAINER`, sight 3, `PAL_NPC_RED` | `TrainerSwimmermHarold` (sym `4e:4f3c`) | -1 |
| `ROUTE19_SWIMMER_GUY2` | `SPRITE_SWIMMER_GUY` | 11 | 17 | `SPRITEMOVEDATA_SPINRANDOM_FAST` (radius 0,0) | `OBJECTTYPE_TRAINER`, sight 3, `PAL_NPC_RED` | `TrainerSwimmermJerome` (sym `4e:4f50`) | -1 |
| `ROUTE19_SWIMMER_GUY3` | `SPRITE_SWIMMER_GUY` | 8 | 23 | `SPRITEMOVEDATA_STANDING_UP` (radius 0,0) | `OBJECTTYPE_TRAINER`, sight **0**, `PAL_NPC_RED` | `TrainerSwimmermTucker` (sym `4e:4f64`) | -1 |
| `ROUTE19_FISHER1` | `SPRITE_FISHER` | 9 | 5 | `SPRITEMOVEDATA_STANDING_DOWN` (radius 0,0) | `OBJECTTYPE_SCRIPT` (sight field 1, unused) | `Route19Fisher1Script` (sym `4e:4f78`) | -1 |
| `ROUTE19_FISHER2` | `SPRITE_FISHER` | 11 | 5 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius 1,0) | `OBJECTTYPE_SCRIPT` (sight field 1, unused) | `Route19Fisher2Script` (sym `4e:4f8c`) | -1 |

Note for a bot: Tucker `(8, 23)` and Dawn `(9, 23)` both have sight range 0, so they never initiate a battle by line of sight. They must be talked to, which is exactly the walkthrough's "Talk to the guy for a battle" / "talk to the girl to battle her". Harold and Jerome have sight 3 and will pull the player in.

**Scripts of interest**

- `Route19_MapScripts` (`maps/Route19.asm:9`): no scene scripts; one callback, `callback MAPCALLBACK_TILES, Route19ClearRocksCallback`.
- `Route19ClearRocksCallback` (`maps/Route19.asm:15`, sym `4e:4f09`): `checkevent EVENT_CINNABAR_ROCKS_CLEARED` / `iftrue .Done`, otherwise six `changeblock` calls writing block `$7a` (a rock) at cells `(6, 6)`, `(8, 6)`, `(10, 6)`, `(12, 8)`, `(4, 8)`, `(10, 10)` - i.e. blocks `(3, 3)`, `(4, 3)`, `(5, 3)`, `(6, 4)`, `(2, 4)`, `(5, 5)`. Block `$7a` in `data/tilesets/kanto_collision.asm:123` is `tilecoll WALL, WALL, WALL, WALL`, so all four quadrants are solid; these are impassable terrain, not Strength boulders. Because this is `MAPCALLBACK_TILES` it re-runs on every map load, and because `EVENT_CINNABAR_ROCKS_CLEARED` is set by simply walking onto Route 20, by the time this section runs the rocks are already gone.
- `Route19Fisher1Script` / `Route19Fisher2Script` (`maps/Route19.asm:71` / `:87`): `faceplayer / opentext / checkevent EVENT_CINNABAR_ROCKS_CLEARED / iftrue .RocksCleared`. Flavor only, no flags written, no items.
- The four trainer scripts follow the same `endifjustbattled` pattern as Route 20's.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `EVENT_CINNABAR_ROCKS_CLEARED` | `constants/event_flags.asm:214` | read by `Route19ClearRocksCallback` and both Fisher scripts | Gate on whether the north half of Route 19 is walkable |
| `EVENT_BEAT_SWIMMERF_DAWN` | `constants/event_flags.asm:485` | `TrainerSwimmerfDawn` | One-time battle |
| `EVENT_BEAT_SWIMMERM_HAROLD` | `constants/event_flags.asm:941` | `TrainerSwimmermHarold` | One-time battle; not mentioned by the walkthrough |
| `EVENT_BEAT_SWIMMERM_JEROME` | `constants/event_flags.asm:954` | `TrainerSwimmermJerome` | One-time battle |
| `EVENT_BEAT_SWIMMERM_TUCKER` | `constants/event_flags.asm:955` | `TrainerSwimmermTucker` | One-time battle |

**Items** - none. Both `bg_event`s are `BGEVENT_READ` signs; there is no `hiddenitem` and no item ball on this map.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `SWIMMERM` / `TUCKER` | 26 | `SwimmerMGroup` entry 15 | `TRAINERTYPE_NORMAL`: L30 SHELLDER, L34 CLOYSTER | `TrainerSwimmermTucker` | none |
| `SWIMMERF` / `DAWN` | 27 | `SwimmerFGroup` entry 12 | `TRAINERTYPE_NORMAL`: L34 SEAKING | `TrainerSwimmerfDawn` | none |
| `SWIMMERM` / `JEROME` | 26 | `SwimmerMGroup` entry 14 | `TRAINERTYPE_NORMAL`: L26 SEADRA, L28 TENTACOOL, L30 TENTACRUEL, L28 GOLDEEN | `TrainerSwimmermJerome` | none |
| `SWIMMERM` / `HAROLD` | 26 | `SwimmerMGroup` entry 1 | `TRAINERTYPE_NORMAL`: L32 REMORAID, L30 SEADRA | `TrainerSwimmermHarold` | none |

Prize money using the same `4 x base x last-mon level` rule: Tucker `4 x 2 x 34 = 272`, Dawn `4 x 5 x 34 = 680`, Jerome `4 x 2 x 28 = 224`, Harold `4 x 2 x 30 = 240`. The first three match the FAQ exactly.

**Wild encounters**

- Surfing: `data/wild/kanto_water.asm:47` `def_water_wildmons ROUTE_19`, encounter rate `6 percent`: L35 TENTACOOL, L30 TENTACOOL, L35 TENTACRUEL.
- No grass table, no headbutt table.
- Fishing: `FISHGROUP_SHORE` (`data/maps/maps.asm:196`), `data/wild/fish.asm` `.Shore_Old` / `.Shore_Good` / `.Shore_Super` (lines 28-40): Old = MAGIKARP/MAGIKARP/KRABBY L10; Good = MAGIKARP L20, KRABBY L20 (x2), time group 0; Super = KRABBY L40, time group 1, KRABBY L40, KINGLER L40.

### MAP_ROUTE_19_FUCHSIA_GATE

Included because the walkthrough's "blocked by those boulders south of Fuchsia City" line points at it. The walkthrough never actually enters it.

- Script: `maps/Route19FuchsiaGate.asm`
- Blocks: `maps/Route19FuchsiaGate.blk` (`data/maps/blocks.asm:204` `Route19FuchsiaGate_Blocks`)
- Header: `data/maps/maps.asm:194` -> `TILESET_GATE`, `GATE`, `LANDMARK_ROUTE_19`, `MUSIC_ROUTE_3`, phone `FALSE`, `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:178` `map_const ROUTE_19_FUCHSIA_GATE, 5, 4` (10x8 cells)
- Connections: none (`data/maps/attributes.asm:512` has no connection rows)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 0 | `FUCHSIA_CITY` | 10 |
| 2 | 5 | 0 | `FUCHSIA_CITY` | 11 |
| 3 | 4 | 7 | `ROUTE_19` | 1 |
| 4 | 5 | 7 | `ROUTE_19` | 1 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `ROUTE19FUCHSIAGATE_OFFICER` | `SPRITE_OFFICER` | 0 | 4 | `SPRITEMOVEDATA_STANDING_RIGHT` (radius 0,0) | `OBJECTTYPE_SCRIPT`, `PAL_NPC_BLUE` | `Route19FuchsiaGateOfficerScript` | -1 |

**Scripts of interest**

- `Route19FuchsiaGateOfficerScript` (`maps/Route19FuchsiaGate.asm:9`): `faceplayer / opentext / checkevent EVENT_CINNABAR_ROCKS_CLEARED / iftrue .RocksCleared`, then one of two texts. He is at `(0, 4)`, off to the side of the `(4, ...)` / `(5, ...)` walkway, so he blocks nothing. There is no coord event and no movement-blocking script in this gate: the officer is flavor, and the actual road closure is the `changeblock` rocks on Route 19 itself.

### MAP_VIRIDIAN_CITY

- Script: `maps/ViridianCity.asm`
- Blocks: `maps/ViridianCity.blk` (`data/maps/blocks.asm:235` `ViridianCity_Blocks`)
- Header: `data/maps/maps.asm:457` -> `TILESET_KANTO`, `TOWN`, `LANDMARK_VIRIDIAN_CITY`, `MUSIC_VIRIDIAN_CITY`, phone `FALSE`, `PALETTE_AUTO`, `FISHGROUP_POND`
- Dimensions: `constants/map_constants.asm:423` `map_const VIRIDIAN_CITY, 20, 18` (40x36 cells)
- Connections: `data/maps/attributes.asm:259-261` - north `Route2` (`ROUTE_2`, offset 5), south `Route1` (`ROUTE_1`, offset 10), west `Route22` (`ROUTE_22`, offset 4). No east.
- Map events block: `ViridianCity_MapEvents`, sym `4e:4486`
- Fly target: `data/maps/flypoints.asm:19` `db LANDMARK_VIRIDIAN_CITY, SPAWN_VIRIDIAN`; `data/maps/spawn_points.asm:15` `spawn VIRIDIAN_CITY, 23, 26` (the Pokecenter doorstep)

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 32 | 7 | `VIRIDIAN_GYM` | 1 |
| 2 | 21 | 9 | `VIRIDIAN_NICKNAME_SPEECH_HOUSE` | 1 |
| 3 | 23 | 15 | `TRAINER_HOUSE_1F` | 1 |
| 4 | 29 | 19 | `VIRIDIAN_MART` | 2 |
| 5 | 23 | 25 | `VIRIDIAN_POKECENTER_1F` | 1 |

**Coord events** (`def_coord_events`) - none.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 17 | 17 | `BGEVENT_READ` | `ViridianCitySign` |
| 27 | 7 | `BGEVENT_READ` | `ViridianGymSign` (sym `4e:4053`) - "LEADER: ... The rest of the text is illegible" |
| 19 | 1 | `BGEVENT_READ` | `ViridianCityWelcomeSign` |
| 21 | 15 | `BGEVENT_READ` | `TrainerHouseSign` |
| 24 | 25 | `BGEVENT_READ` | `ViridianCityPokecenterSign` (`jumpstd PokecenterSignScript`) |
| 30 | 19 | `BGEVENT_READ` | `ViridianCityMartSign` (`jumpstd MartSignScript`) |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VIRIDIANCITY_GRAMPS1` | `SPRITE_GRAMPS` | 18 | 5 | `SPRITEMOVEDATA_WANDER` (radius 2,2) | `OBJECTTYPE_SCRIPT` | `ViridianCityCoffeeGramps` | -1 |
| `VIRIDIANCITY_GRAMPS2` | `SPRITE_GRAMPS` | 30 | 8 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT`, `PAL_NPC_BLUE` | `ViridianCityGrampsNearGym` (sym `4e:401e`) | -1 |
| `VIRIDIANCITY_FISHER` | `SPRITE_FISHER` | 6 | 23 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT`, `PAL_NPC_RED` | `ViridianCityDreamEaterFisher` (sym `4e:4032`) | -1 |
| `VIRIDIANCITY_YOUNGSTER` | `SPRITE_YOUNGSTER` | 17 | 21 | `SPRITEMOVEDATA_WANDER` (radius 3,3) | `OBJECTTYPE_SCRIPT`, `PAL_NPC_GREEN` | `ViridianCityYoungsterScript` | -1 |

**Scripts of interest**

- `ViridianCityFlypointCallback` (`maps/ViridianCity.asm:13`, sym `4e:4005`), hooked as `callback MAPCALLBACK_NEWMAP`: `setflag ENGINE_FLYPOINT_VIRIDIAN / endcallback`. A bot cannot Fly here until it has physically entered Viridian City once.
- `ViridianCityGrampsNearGym` (`maps/ViridianCity.asm:34`): `checkevent EVENT_BLUE_IN_CINNABAR`; if true, the "Are you going to battle the LEADER?" line. This is a free read-out of whether Blue has been moved into the gym - see the gate table.
- `ViridianCityDreamEaterFisher` (`maps/ViridianCity.asm:50`): `checkevent EVENT_GOT_TM42_DREAM_EATER / iftrue .GotDreamEater`, else `writetext ... / promptbutton / verbosegiveitem TM_DREAM_EATER / iffalse .NoRoomForDreamEater / setevent EVENT_GOT_TM42_DREAM_EATER`. The walkthrough never mentions this; it is a free TM on the map the walkthrough tells you to fly to.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_FLYPOINT_VIRIDIAN` | `constants/engine_flags.asm:68` | set by `ViridianCityFlypointCallback` | Precondition for the walkthrough's "fly back to Viridian City" |
| `EVENT_BLUE_IN_CINNABAR` | `constants/event_flags.asm:1303` | read by `ViridianCityGrampsNearGym` and `ViridianPokecenter1FCooltrainerMScript`; it is also `CINNABARISLAND_BLUE`'s object event flag | While clear, Blue is standing on Cinnabar Island and has not yet moved to the gym |
| `EVENT_GOT_TM42_DREAM_EATER` | `constants/event_flags.asm:223` | `ViridianCityDreamEaterFisher` | One-time TM42 |

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|
| `TM_DREAM_EATER` (TM42) | Talk to `VIRIDIANCITY_FISHER` at `(6, 23)` | `ViridianCityDreamEaterFisher` `verbosegiveitem` | `EVENT_GOT_TM42_DREAM_EATER` |

**Trainers** - none on the overworld map.

**Wild encounters** - no `kanto_grass.asm` or `kanto_water.asm` entry for `VIRIDIAN_CITY`. Fishing group is `FISHGROUP_POND` (`data/maps/maps.asm:457`).

### MAP_VIRIDIAN_POKECENTER_1F

- Script: `maps/ViridianPokecenter1F.asm`
- Blocks: `data/maps/blocks.asm:361` `ViridianPokecenter1F_Blocks`
- Header: `data/maps/maps.asm:463` -> `TILESET_POKECENTER`, `INDOOR`, `LANDMARK_VIRIDIAN_CITY`, `MUSIC_POKEMON_CENTER`, phone `FALSE`, `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:429` `map_const VIRIDIAN_POKECENTER_1F, 5, 4` (10x8 cells)
- Connections: none
- Respawn point: `data/maps/spawn_points.asm:12` `spawn VIRIDIAN_POKECENTER_1F, 5, 3`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 3 | 7 | `VIRIDIAN_CITY` | 5 |
| 2 | 4 | 7 | `VIRIDIAN_CITY` | 5 |
| 3 | 0 | 7 | `POKECENTER_2F` | 1 |

**Coord events** - none. **BG events** - none.

**Object events**

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VIRIDIANPOKECENTER1F_NURSE` | `SPRITE_NURSE` | 3 | 1 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT` | `ViridianPokecenter1FNurseScript` | -1 |
| `VIRIDIANPOKECENTER1F_COOLTRAINER_M` | `SPRITE_COOLTRAINER_M` | 8 | 4 | `SPRITEMOVEDATA_WALK_LEFT_RIGHT` (radius 1,0) | `OBJECTTYPE_SCRIPT`, `PAL_NPC_RED` | `ViridianPokecenter1FCooltrainerMScript` | -1 |
| `VIRIDIANPOKECENTER1F_COOLTRAINER_F` | `SPRITE_COOLTRAINER_F` | 5 | 3 | `SPRITEMOVEDATA_STANDING_UP` | `OBJECTTYPE_SCRIPT`, `PAL_NPC_BLUE` | `ViridianPokecenter1FCooltrainerFScript` | -1 |
| `VIRIDIANPOKECENTER1F_BUG_CATCHER` | `SPRITE_BUG_CATCHER` | 1 | 6 | `SPRITEMOVEDATA_STANDING_RIGHT` | `OBJECTTYPE_SCRIPT`, `PAL_NPC_GREEN` | `ViridianPokecenter1FBugCatcherScript` | -1 |

**Scripts of interest**

- `ViridianPokecenter1FNurseScript` (`maps/ViridianPokecenter1F.asm:12`): `jumpstd PokecenterNurseScript` (`engine/events/std_scripts.asm:54`). This is the "heal at the Pokémon Center" beat, both before and after Blue.
- `ViridianPokecenter1FCooltrainerMScript` (`maps/ViridianPokecenter1F.asm:15`): another `checkevent EVENT_BLUE_IN_CINNABAR` read-out ("There are no GYM TRAINERS at the VIRIDIAN GYM"), which corroborates the walkthrough's "There aren't any other trainers in this gym".

### MAP_VIRIDIAN_GYM

- Script: `maps/ViridianGym.asm`
- Blocks: `maps/ViridianGym.blk` (`data/maps/blocks.asm:877` `ViridianGym_Blocks`)
- Header: `data/maps/maps.asm:458` -> `TILESET_TRAIN_STATION`, `INDOOR`, `LANDMARK_VIRIDIAN_CITY`, `MUSIC_GYM`, phone `TRUE`, `PALETTE_DAY`, `FISHGROUP_SHORE`
- Dimensions: `constants/map_constants.asm:424` `map_const VIRIDIAN_GYM, 5, 9` (10x18 cells)
- Connections: none (`data/maps/attributes.asm:657`)
- Map events block: `ViridianGym_MapEvents`, sym `5f:43de`

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|
| 1 | 4 | 17 | `VIRIDIAN_CITY` | 1 |
| 2 | 5 | 17 | `VIRIDIAN_CITY` | 1 |

**Coord events** (`def_coord_events`) - none. There is no trip-wire in this gym; Blue is a pure talk-to trigger.

**BG events** (`def_bg_events`)

| x | y | type | script/item |
|---|---|---|---|
| 3 | 13 | `BGEVENT_READ` | `ViridianGymStatue` (sym `5f:4047`) |
| 6 | 13 | `BGEVENT_READ` | `ViridianGymStatue` |

**Object events** (`def_object_events`)

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|
| `VIRIDIANGYM_BLUE` | `SPRITE_BLUE` | 5 | 3 | `SPRITEMOVEDATA_STANDING_DOWN` (radius 0,0) | `OBJECTTYPE_SCRIPT`, palette 0 | `ViridianGymBlueScript` (sym `5f:4002`) | `EVENT_VIRIDIAN_GYM_BLUE` |
| `VIRIDIANGYM_GYM_GUIDE` | `SPRITE_GYM_GUIDE` | 7 | 13 | `SPRITEMOVEDATA_STANDING_DOWN` | `OBJECTTYPE_SCRIPT`, `PAL_NPC_BLUE` | `ViridianGymGuideScript` (sym `5f:4033`) | `EVENT_VIRIDIAN_GYM_BLUE` |

Both objects carry `EVENT_VIRIDIAN_GYM_BLUE` as their event flag, so while that flag is **set** the gym is completely empty. `EVENT_VIRIDIAN_GYM_BLUE` is set by `InitializeEventsScript` at new game (`engine/events/std_scripts.asm:438`, the `setevent` on line 552) and is cleared only by `CinnabarIslandBlue`.

**Scripts of interest**

- `ViridianGymBlueScript` (`maps/ViridianGym.asm:10`, sym `5f:4002`), the whole badge beat, in order:
  1. `faceplayer` / `opentext`
  2. `checkflag ENGINE_EARTHBADGE` / `iftrue .FightDone` (sym `5f:402d`) - repeat visits get `LeaderBlueEpilogueText` only
  3. `writetext LeaderBlueBeforeText` / `waitbutton` / `closetext`
  4. `winlosstext LeaderBlueWinText, 0` (loss text pointer 0 = use the default)
  5. `loadtrainer BLUE, BLUE1` / `startbattle` / `reloadmapafterbattle`
  6. `setevent EVENT_BEAT_BLUE`
  7. `opentext` / `writetext Text_ReceivedEarthBadge` / `playsound SFX_GET_BADGE` / `waitsfx`
  8. `setflag ENGINE_EARTHBADGE`
  9. `writetext LeaderBlueAfterText` / `waitbutton` / `closetext` / `end`

  No `verbosegiveitem`: unlike Johto leaders, the Kanto leaders in GSC hand out no TM. The badge itself is the only reward besides money.
- `ViridianGymGuideScript` (`maps/ViridianGym.asm:39`, sym `5f:4033`): `checkevent EVENT_BEAT_BLUE / iftrue .ViridianGymGuideWinScript`. Pure flavor, no `learnmove`, no items.
- `ViridianGymStatue` (`maps/ViridianGym.asm:55`, sym `5f:4047`): `checkflag ENGINE_EARTHBADGE / iftrue .Beaten`; before the badge, `jumpstd GymStatue1Script` (`engine/events/std_scripts.asm:638`), after it `gettrainername STRING_BUFFER_4, BLUE, BLUE1` then `jumpstd GymStatue2Script` (`:646`). A cheap read-back a bot can use to confirm the badge landed.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|
| `ENGINE_EARTHBADGE` | `constants/engine_flags.asm:54` (in `wKantoBadges`) | read by `ViridianGymBlueScript` and `ViridianGymStatue`; set by `ViridianGymBlueScript` | The 16th badge. Post-condition of this section |
| `EVENT_BEAT_BLUE` | `constants/event_flags.asm:722` | set by `ViridianGymBlueScript`, read by `ViridianGymGuideScript` | Set *before* the badge flag, between `reloadmapafterbattle` and `playsound` |
| `EVENT_VIRIDIAN_GYM_BLUE` | `constants/event_flags.asm:1304` | set by `InitializeEventsScript` (`engine/events/std_scripts.asm:552`); cleared by `CinnabarIslandBlue` (`maps/CinnabarIsland.asm:23`) | While set, both gym objects are absent. This is the real gate on the whole section |
| `EVENT_BLUE_IN_CINNABAR` | `constants/event_flags.asm:1303` | object flag of `CINNABARISLAND_BLUE` (`maps/CinnabarIsland.asm:143`), set by that script's `disappear` | Once set, Blue is gone from Cinnabar and (necessarily) present in the gym |

**Items** - none. No item balls, no `hiddenitem`, no TM reward.

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|
| `BLUE` / `BLUE1` | 40 (`constants/trainer_constants.asm:640`) | `BLUE1` (`:641`) | `data/trainers/parties.asm:3154` `BlueGroup` (sym `0e:75ff`), `TRAINERTYPE_MOVES` | `ViridianGymBlueScript` | none (no phone entry; the map header's phone column is `TRUE` but no `phone_call` targets him) |

`BlueGroup` party, verbatim:

| # | level | species | moves |
|---|---|---|---|
| 1 | 56 | PIDGEOT | QUICK_ATTACK, WHIRLWIND, WING_ATTACK, MIRROR_MOVE |
| 2 | 54 | ALAKAZAM | DISABLE, RECOVER, PSYCHIC_M, REFLECT |
| 3 | 56 | RHYDON | FURY_ATTACK, SANDSTORM, ROCK_SLIDE, EARTHQUAKE |
| 4 | 58 | GYARADOS | TWISTER, HYDRO_PUMP, RAIN_DANCE, HYPER_BEAM |
| 5 | 58 | EXEGGUTOR | SUNNY_DAY, LEECH_SEED, EGG_BOMB, SOLARBEAM |
| 6 | 58 | ARCANINE | ROAR, SWIFT, FLAMETHROWER, EXTREMESPEED |

Class attributes (`data/trainers/attributes.asm:383`): items `FULL_RESTORE, FULL_RESTORE` (the AI will use two Full Restores), base reward 25, AI `AI_BASIC | AI_SETUP | AI_SMART | AI_AGGRESSIVE | AI_CAUTIOUS | AI_STATUS | AI_RISKY`, `CONTEXT_USE | SWITCH_SOMETIMES`. Payout `4 x 25 x 58 = 5800`, matching the FAQ. `BLUE` is listed in `KantoGymLeaders` (`data/trainers/leaders.asm:31`), which is what selects the gym-leader battle/victory music and awards `HAPPINESS_GYMBATTLE`.

Walkthrough claims worth flagging against the party data: Pidgeot's flying move is `WING_ATTACK`, not Air Slash (which does not exist in Gen 2); Exeggutor's moves are `SUNNY_DAY, LEECH_SEED, EGG_BOMB, SOLARBEAM`, so it has neither Psychic nor Hypnosis; Arcanine's switch move is `ROAR`, Pidgeot's is `WHIRLWIND`.

**Wild encounters** - none (indoor map).

## 3. Blockers and gates

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|
| Reaching Routes 19/20 at all | `engine/events/overworld.asm:322` `SurfFunction` -> `.TrySurf` (`ld de, ENGINE_FOGBADGE / call CheckBadge`), and the tile-facing path `engine/events/overworld.asm:469` `TrySurfOW` (`ENGINE_FOGBADGE` via `CheckEngineFlag`, then `CheckPartyMove` for `SURF`) | FOGBADGE + a party member knowing SURF | Both routes are open water; without Surf there is no approach |
| Boulders across northern Route 19 | `maps/Route19.asm:15` `Route19ClearRocksCallback`, six `changeblock ..., $7a` under `checkevent EVENT_CINNABAR_ROCKS_CLEARED`; block `$7a` is `WALL` on all four quadrants (`data/tilesets/kanto_collision.asm:123`) | `EVENT_CINNABAR_ROCKS_CLEARED` | Set unconditionally by `maps/Route20.asm:12` `Route20ClearRocksCallback` on `MAPCALLBACK_NEWMAP`, i.e. by setting foot on Route 20 |
| Blue is not in the Viridian Gym | Object event flag `EVENT_VIRIDIAN_GYM_BLUE` on both `maps/ViridianGym.asm:183-184` objects; set at new game by `engine/events/std_scripts.asm:552` inside `InitializeEventsScript` | Flag must be **clear** | `maps/CinnabarIsland.asm:14` `CinnabarIslandBlue`: talk to Blue on Cinnabar Island; the script runs `disappear CINNABARISLAND_BLUE` (setting `EVENT_BLUE_IN_CINNABAR`) then `clearevent EVENT_VIRIDIAN_GYM_BLUE`. This happens in an earlier section, but a bot that skipped it will find an empty gym |
| Flying to Viridian City | `maps/ViridianCity.asm:13` `ViridianCityFlypointCallback` (`setflag ENGINE_FLYPOINT_VIRIDIAN`), plus `engine/events/overworld.asm:529` `FlyFunction` (`ld de, ENGINE_STORMBADGE`) and the landmark row `data/maps/flypoints.asm:19` | STORMBADGE + a party member knowing FLY + Viridian visited once on foot | Walk into Viridian City once (Route 1 north, Route 2 south, or Route 22 east). Otherwise reach the gym overland |
| Re-fighting Blue | `maps/ViridianGym.asm:13` `checkflag ENGINE_EARTHBADGE / iftrue .FightDone` | - | Not possible; the battle is one-shot and there is no rematch or phone entry |
| (Next section) Mt. Silver | `maps/OaksLab.asm:26` `readvar VAR_BADGES / ifequal NUM_BADGES, .OpenMtSilver` -> `setevent EVENT_OPENED_MT_SILVER` | All 16 badges, EARTHBADGE last | Beating Blue here is what satisfies it |

Note on the Route 19 approach: the officer in `maps/Route19FuchsiaGate.asm` never blocks a tile, and `maps/Route19.asm` has no coord events. There is no NPC blocker anywhere in this section - every obstacle is either terrain (`changeblock`) or a hidden object (`EVENT_VIRIDIAN_GYM_BLUE`).

## 4. Bot checklist

Preconditions for the whole section: `ENGINE_FOGBADGE` + SURF in party, `EVENT_VIRIDIAN_GYM_BLUE` clear, `ENGINE_FLYPOINT_VIRIDIAN` set (or an overland plan to Viridian).

| # | Map | Target | Input intent | Precondition | Postcondition |
|---|---|---|---|---|---|
| 1 | `MAP_ROUTE_20` | anywhere on the map | enter the map (warp from Seafoam Gym warp 1 at `(38, 7)`, or the Cinnabar Island east connection) | - | `EVENT_CINNABAR_ROCKS_CLEARED` set by `Route20ClearRocksCallback` |
| 2 | `MAP_ROUTE_20` | `ROUTE20_SWIMMER_GIRL2` at `(45, 13)` | surf into her sight cone (range 3) or talk | `EVENT_BEAT_SWIMMERF_LORI` clear | battle Lori (2x L32 STARMIE); `EVENT_BEAT_SWIMMERF_LORI` set, +640 |
| 3 | `MAP_ROUTE_20` | `ROUTE20_SWIMMER_GIRL1` at `(52, 8)` | surf into sight (range 3) or talk | `EVENT_BEAT_SWIMMERF_NICOLE` clear | battle Nicole (L29 MARILL, L29 MARILL, L32 LAPRAS); flag set, +640 |
| 3b | `MAP_ROUTE_20` | `ROUTE20_SWIMMER_GUY` at `(12, 13)` | optional, west end, skipped by the FAQ | `EVENT_BEAT_SWIMMERM_CAMERON` clear | battle Cameron (L34 MARILL); flag set, +272 |
| 4 | `MAP_ROUTE_20` -> `MAP_ROUTE_19` | east map edge | surf east across the connection (offset -9) | - | now on `MAP_ROUTE_19` |
| 5 | `MAP_ROUTE_19` | `ROUTE19_SWIMMER_GUY3` at `(8, 23)` | **talk** (sight 0, will not initiate) | `EVENT_BEAT_SWIMMERM_TUCKER` clear | battle Tucker (L30 SHELLDER, L34 CLOYSTER); flag set, +272 |
| 6 | `MAP_ROUTE_19` | `ROUTE19_SWIMMER_GUY3` again | talk | `EVENT_BEAT_SWIMMERM_TUCKER` set | `SwimmermTuckerAfterBattleText` (the "drowning" line) |
| 7 | `MAP_ROUTE_19` | `ROUTE19_SWIMMER_GIRL` at `(9, 23)` | **talk** (sight 0) | `EVENT_BEAT_SWIMMERF_DAWN` clear | battle Dawn (L34 SEAKING); flag set, +680 |
| 8 | `MAP_ROUTE_19` | `ROUTE19_SWIMMER_GUY2` at `(11, 17)` | surf north into sight (range 3) or talk | `EVENT_BEAT_SWIMMERM_JEROME` clear | battle Jerome (L26 SEADRA, L28 TENTACOOL, L30 TENTACRUEL, L28 GOLDEEN); flag set, +224 |
| 8b | `MAP_ROUTE_19` | `ROUTE19_SWIMMER_GUY1` at `(13, 28)` | optional, south-east, not in the FAQ | `EVENT_BEAT_SWIMMERM_HAROLD` clear | battle Harold (L32 REMORAID, L30 SEADRA); flag set, +240 |
| 9 | `MAP_ROUTE_19` -> `MAP_VIRIDIAN_CITY` | Pokegear map -> Fly -> Viridian | use FLY | `ENGINE_STORMBADGE`, FLY in party, `ENGINE_FLYPOINT_VIRIDIAN` | player at `VIRIDIAN_CITY (23, 26)` (`data/maps/spawn_points.asm:15`) |
| 10 | `MAP_VIRIDIAN_CITY` | warp 5 at `(23, 25)` | step onto the warp | - | in `MAP_VIRIDIAN_POKECENTER_1F` |
| 11 | `MAP_VIRIDIAN_POKECENTER_1F` | `VIRIDIANPOKECENTER1F_NURSE` at `(3, 1)` | talk, accept heal | - | party healed (`PokecenterNurseScript`) |
| 11b | `MAP_VIRIDIAN_CITY` | `VIRIDIANCITY_FISHER` at `(6, 23)` | talk (optional, not in the FAQ) | `EVENT_GOT_TM42_DREAM_EATER` clear, bag space | receive `TM_DREAM_EATER`; flag set |
| 12 | `MAP_VIRIDIAN_CITY` | warp 1 at `(32, 7)` | step onto the warp | - | in `MAP_VIRIDIAN_GYM` at `(4, 17)` / `(5, 17)` |
| 13 | `MAP_VIRIDIAN_GYM` | `VIRIDIANGYM_GYM_GUIDE` at `(7, 13)` | talk (optional) | `EVENT_VIRIDIAN_GYM_BLUE` clear | advice text only |
| 14 | `MAP_VIRIDIAN_GYM` | save | save the game (the FAQ says so explicitly) | - | - |
| 15 | `MAP_VIRIDIAN_GYM` | `VIRIDIANGYM_BLUE` at `(5, 3)`, approach from below | talk | `EVENT_VIRIDIAN_GYM_BLUE` clear, `ENGINE_EARTHBADGE` clear | battle `BLUE / BLUE1` (6 mons, L54-58, 2 Full Restores); on win `EVENT_BEAT_BLUE` set, `ENGINE_EARTHBADGE` set, +5800 |
| 16 | `MAP_VIRIDIAN_GYM` | `VIRIDIANGYM_BLUE` again | talk | `ENGINE_EARTHBADGE` set | `LeaderBlueEpilogueText` ("You'd better not lose until I beat you") |
| 17 | `MAP_VIRIDIAN_GYM` | `bg_event (3, 13)` or `(6, 13)` | read the statue | `ENGINE_EARTHBADGE` set | `GymStatue2Script` with Blue's name - a cheap badge assertion |
| 18 | `MAP_VIRIDIAN_GYM` -> `MAP_VIRIDIAN_CITY` -> Pokecenter | warp 1/2 `(4, 17)` / `(5, 17)`, then Viridian warp 5 | walk, warp, heal | - | 16 badges, section complete |

## 5. Port coverage

| Beat | Port file | Status |
|---|---|---|
| Map header, blocks, warps, coord/bg/object events for all six maps | `src/import/RomExtractorGen2.lua:782` `readMapEvents`, `:899` (map assembly) | implemented - the tables are read out of the ROM generically, so no per-map data is hand-written |
| `MAPCALLBACK_NEWMAP` / `MAPCALLBACK_TILES` dispatch (needed for both rock callbacks and the Viridian fly point) | `src/world/gen2/World.lua:5659`, `:5664` | implemented |
| `changeblock` (Route 19 boulders) | `src/script/gen2/Vm.lua:1002` (halves x/y to block coords, calls `changeBlockFn`) | implemented |
| `setevent` / `clearevent` / `checkevent`, object-event hide flags | `src/world/gen2/Events.lua`, `src/script/gen2/Vm.lua` | implemented |
| `setflag` / `checkflag` on `ENGINE_*` (EARTHBADGE, FLYPOINT_VIRIDIAN) | `src/script/gen2/Vm.lua:212-223`, `:1584` | implemented |
| Surf field move + FOGBADGE check | `src/world/gen2/FieldMoves.lua:101` (badge table), `:482` (`SurfFunction` port) | implemented |
| Fly field move + STORMBADGE + flypoint gating | `src/world/gen2/FieldMoves.lua:501-505` | implemented |
| Trainer sight cones / `OBJECTTYPE_TRAINER` (sight 3 swimmers, sight 0 Tucker and Dawn) | `src/world/gen2/Trainers.lua:98` `Trainers.sees` | implemented |
| `SPRITEMOVEDATA_SPINRANDOM_FAST` swimmers | `src/world/gen2/Npc.lua:23`, `:37`, `:68` | implemented |
| `loadtrainer` / `startbattle` / `winlosstext` / `reloadmapafterbattle` / `endifjustbattled` | `src/script/gen2/Vm.lua`, `src/script/gen2/Opcodes.lua` | implemented |
| Prize money, including the 4x split and Bank of Mom | `src/battle/gen2/Prize.lua:82` `Prize.reward`, `:181` (four quarters) | implemented |
| Gym-leader battle/victory music via `GymLeaders` / `KantoGymLeaders` | `src/battle/gen2/BattleMusic.lua:15-33` | implemented |
| Kanto badge page on the trainer card (EARTHBADGE displayed) | `src/ui/gen2/TrainerCard.lua:90`, `:161` | implemented |
| `verbosegiveitem` (TM42 in Viridian City) | `src/script/gen2/Vm.lua` (`verbosegiveitem`) | implemented |
| A driver that actually plays this stretch (Routes 19/20 surf trainers, Blue) | none - `tests/drivers/` has `gold_trainer_smoke.lua`, `gold_water_moves.lua`, `gold_map_callbacks.lua`, but nothing that reaches Kanto Route 19/20 or Viridian Gym | missing |
| Section-specific regression coverage for `EVENT_CINNABAR_ROCKS_CLEARED` sequencing | not found by grep in `tests/` | missing |

Every "implemented" row above is a generic engine capability, not a hand-port of these maps. Nothing in `src/` names `ROUTE_19`, `ROUTE_20` or `VIRIDIAN_GYM` (the only grep hits are `src/save_convert/data/event_flags_yellow.lua`, which is Gen 1 save conversion data and unrelated). So this section should work if the extractor and VM work, but it has never been exercised end to end.

## 6. Unresolved / verify by hand

1. **The walkthrough's boulder claim contradicts the asm.** "You can't go further north because you'll be blocked by those boulders south of Fuchsia City" is only true while `EVENT_CINNABAR_ROCKS_CLEARED` is clear. `maps/Route20.asm:12` `Route20ClearRocksCallback` sets that event on `MAPCALLBACK_NEWMAP` with no condition at all, and the walkthrough routes the player through Route 20 to reach Route 19. By the time the player is standing on Route 19 the six `changeblock` rocks are never placed, so northern Route 19 and the Fuchsia gate at `(7, 3)` are open. Treat the FAQ line as stale prose, not a gate. (What is genuinely true is that the FAQ's suggested Fly is faster than swimming back.)
2. **Route 19's north connection vs. the gate warp.** `data/maps/attributes.asm:288` declares `connection north, FuchsiaCity, FUCHSIA_CITY, 0`, and there is *also* a warp to `ROUTE_19_FUCHSIA_GATE`. I did not decode `maps/Route19.blk` to determine whether the top block row is actually walkable, so I cannot say whether the north connection is reachable or purely decorative. Verify by hand before a bot relies on either route out.
3. **Two trainers the walkthrough omits.** `TrainerSwimmermCameron` on Route 20 at `(12, 13)` (L34 MARILL) and `TrainerSwimmermHarold` on Route 19 at `(13, 28)` (L32 REMORAID, L30 SEADRA) both exist with sight range 3. The FAQ says "that's all the trainers" for Route 19, which is wrong. A bot surfing the full map will get pulled into both.
4. **Blue's move set does not match the FAQ's strategy text.** The FAQ names Air Slash (Pidgeot) and Psychic + Hypnosis (Exeggutor); `data/trainers/parties.asm:3154` gives Pidgeot `QUICK_ATTACK, WHIRLWIND, WING_ATTACK, MIRROR_MOVE` and Exeggutor `SUNNY_DAY, LEECH_SEED, EGG_BOMB, SOLARBEAM`. Air Slash does not exist in Gen 2. Do not build AI expectations from the FAQ prose here.
5. **The FAQ's "Blue is one of only two trainers tougher than Champion Lance"** is a subjective claim with no asm counterpart; nothing in `data/trainers/` ranks trainers.
6. **`EVENT_VIRIDIAN_GYM_BLUE` is set in a prior section.** The walkthrough never mentions meeting Blue on Cinnabar Island, but `maps/CinnabarIsland.asm:23` is the only `clearevent` for that flag anywhere in the tree. If an earlier section's document does not cover `CinnabarIslandBlue`, this is an orphaned precondition and a bot will find an empty Viridian Gym with no in-game hint beyond `ViridianCityGrampsNearGym`.
7. **Blue's map header sets the phone column to `TRUE`** (`data/maps/maps.asm:458`, the `ViridianGym` row). I found no `phone_call` or rematch entry naming `BLUE`, so I believe this is inert, but I did not exhaustively read `data/phone/`.

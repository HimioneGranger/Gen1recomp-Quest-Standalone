# Pokemon Gold: Gen 2 import, colour, menus, saving and battles

Support for a canonical **Pokemon Gold** ROM
(SHA-1 `d8b8a3600a465308c9953dfa04f0081c05bdcb94`, 2 MiB). Gen 2 extraction
and overworld are separate from Red/Blue/Yellow -- never branched into
`RomExtractor.lua` / Gen 1 `Map.lua`.

## Pipeline

| Piece | Role |
| --- | --- |
| `src/import/Rom.lua` (`decompressLz3`) | Gen 2 graphics compression (`home/decompress.asm`) |
| `tools/make_gold_manifest.py` → `tools/rom_manifest_gold.json` | pret/pokegold constants + `pokegold.sym` |
| `src/import/RomExtractorGen2.lua` | Gen 2 extract (dispatched from `RomImporter` when `version == "gold"`) |
| `src/core/GameVersion.lua` | `gold` entry (`gold/` cache, `_gold` saves) |
| `src/world/gen2/` | COLL_* world, NPCs, events, roofs |
| `src/script/gen2/` | Opcodes + talk-oriented VM over extracted cmds |
| `src/core/Game2.lua` | Gold's service owner (the Gen 2 peer of `src/core/Game.lua`): boot cinema, intro menu, world, START menu |
| `src/core/gen2/Save.lua` | `save_gold.lua`, beside the Gen 1 saves |
| `src/ui/gen2/` | Intro menu, naming keyboard, START menu + every submenu, battle screen |
| `src/battle/gen2/` | Damage, stats/experience, HP bar, turn engine, catching, encounters |
| `src/render/GbcPalette.lua` | One shader: a 4-shade sheet through a GBC palette |

## What extracts

| Area | Status |
| --- | --- |
| Constants | species/map/tileset/move/type/sprite/environment/palette/fish orders |
| Font | `Font` (1bpp ink-on-transparent), `FontExtra` + `Frames` borders at $79–$7E, `FontBattleExtra` |
| Tilesets | lz3 GFX → PNG; raw Meta (128×16) + Coll (128×4 COLL_* quads); Anim/PalMap pointers |
| Roofs | 5 roof sheets + `MapGroupRoofs` (runtime: outdoor tilesets only) |
| Maps | all 368: blocks, connections, warps, coord/bg/object events (+ `scriptKey`) |
| Pokemon | `BaseData` (32B), names, front/back pics, plus Unown's 26 letter forms from `UnownPicPointers` |
| Items | Names, prices, pockets, held effects, field/battle use, descriptions, TM/HM numbers and the move each teaches |
| Marts | `Marts`' 34 shelves in MART_* order plus `BargainShopData`'s own item/price rows (`marts.lua`) |
| Overworld sprites | `OverworldSprites` → PNG sheets + `sprites.lua` |
| Scripts / text | disassembled cmds + decoded strings (`scripts.lua` / `text.lua`) |
| Initial events | `InitializeEventsScript` → `initial_events.lua` |
| Title | Tilemap + GBC tint; cloud band; Ho-Oh frames 1–5; trail; copyright splash |
| Oak speech | `_OakText1–7`, `PokemonProfPic` / `CalPic`, Marill front; `oak_speech.lua` |
| Pokemon / trainer pics | lz3 + column-major → row (`ImageWriter.columnsToRows`) |
| Audio | banks dumped to `programs.bin`; Gen 2 ChipSynth driver (`runtime = true`) |
| Palettes | `TilesetBGPalette`, `EnvironmentColorsPointers`, `MapObjectPals`, `RoofPals`, mon/trainer/HP-bar/exp-bar palettes, per-tileset `PalMap` |
| Moves | `Moves` + names + descriptions, effect names, real percentages |
| Type chart | `TypeMatchups` (plus the Foresight rows) and `TypeNames` with physical/special |
| Pokemon | Base stats, evolutions and level-up moves (`EvosAttacks`), TM/HM lists, growth rates, egg groups, gender ratio |
| Encounters | Grass (three time-of-day slot lists), water, fishing groups, headbutt tree sets |
| Trainers | Every class's parties with moves/items, class names, attributes, `TrainerEncounterMusic` |
| Pokedex | Entries (kind, height, weight, text) + the New and A-Z orderings |
| Landmarks | Town-map positions and names, plus `SpawnPoints` |
| Icons | Party-menu mon icons and the species → icon map |
| Menu / HUD gfx | Naming-screen chrome, battle HUD border and bar tiles, exp bar |
| Intro movie | The three acts' composed backgrounds, sprite sheets and fire frames |
| Battle anims | all 428 scripts, 188 objects, 185 framesets, 216 OAM sets, 40 object sheets, the six OBJ palettes |
| Field anims | stubs |

Verified against a real Gold ROM: New Bark Town warps/objects/connections
match `pokegold/maps/NewBarkTown.asm`. Retail EVENT_* numeric ids differ
from pret’s current `const_def` order -- always take flags from the cart.

## Play

Launcher → Gold tab → Play opens `Game2` (`src/core/Game2.lua`):

- Copyright → GameFreak Presents → GS intro stub → title (colored tilemap,
  scrolling clouds, Ho-Oh flap, trails) → Oak speech (Marill cry + shrink)
  → name pick → `src/world/gen2/World`
- Drivers (`POKEPORT_DRIVER`) skip cinema straight to the map
- New Bark Town with Johto tileset + roof overlay (outdoors only)
- Walk on `COLL_*` permissions; doors / stairs / carpets
- Elm's lab: scene walk-in, starter balls (`givepoke` + cutscene moves),
  Elm phone number, aide Potion on exit (`verbosegiveitem`)
- Connected neighbor strips + seamless edge crossings (Route 29 / 27)
- Survey zoom (`-` / `=` / wheel / `4`)
- Chris + map/neighbor NPCs; `SPRITEMOVEDATA_*` walk / spin / stand
- New-game flags hide story NPCs (e.g. lab cop)
- A: talk to facing NPC or read `BGEVENT_READ` signs via Gen 2 VM + TextBox

Escape is START, not quit: quitting is the START menu's QUIT row and the
intro menu's EXIT GAME.  Title / map music and script SFX/cries use the Gen 2
channel driver.

## Colour

Gen 2 is CGB-native, so colour is part of a tile's identity rather than a tint
over a 4-shade image.  `engine/gfx/color.asm` LoadMapPals is ported whole in
`src/world/gen2/Palettes.lua`:

1. the clock hour picks a daytime (`engine/rtc/rtc.asm` TimesOfDay), which a
   map's own `PALETTE_*` can override (`ReplaceTimeOfDayPals`)
2. `EnvironmentColorsPointers[environment][daytime]` names eight entries in the
   shared `TilesetBGPalette` pool
3. outdoors only, `RoofPals[mapGroup]` overwrites `PAL_BG_ROOF` colours 1-2 --
   one roof tile sheet, a different colour per town
4. each tile's slot comes from its tileset's `PalMap`, and each OW sprite's OBJ
   palette from `MapObjectPals[daytime]` plus its own `PAL_OW_*`

The map bake runs one shader pass per BG slot (eight per map) rather than one
per tile, and re-bakes when the clock rolls into a new daytime.
`POKEPORT_GOLD_HOUR=21` pins the hour for screenshots.

## Still to do

About fifty of AI_Smart's seventy per-effect handlers are unwritten, fishing
and headbutt have engine support but no input path, and Mart, the summary
screen, `.sav` interchange, Silver and mod-replaceable Gen 2 screens are all
still open.

## Verify

```sh
python3 tools/make_gold_manifest.py
for t in rom_lz3 gen2_world gen2_audio gen2_oak_speech gen2_vm \
         gen2_palettes gen2_battle gen2_menus gen2_save; do
  luajit tests/${t}_test.lua
done
POKEPORT_IMPORT_TRACE=1 POKEPORT_IMPORT_ROM=/path/to/pokegold.gbc \
  POKEPORT_IMPORT_ONLY=1 POKEPORT_FORCE_IMPORT=1 POKEPORT_GAME=gold love .
POKEPORT_GAME=gold love .
# copyright → GF presents → GS intro → title → CONTINUE/NEW GAME/OPTION
# → Oak → name → the bedroom.  START opens the menu; grass starts a battle.

# Screenshot drivers (need a display):
POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_menu_shots.lua love .
POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_palette_shots.lua love .
POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_battle_smoke.lua love .
POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_transition_shots.lua love .
POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_teacher_scene.lua love .
POKEPORT_GAME=gold POKEPORT_BOOT_CINEMA=1 \
  POKEPORT_DRIVER=tests/drivers/gold_boot_smoke.lua love .
```

`POKEPORT_IMPORT_TRACE=1` prints each of the 26 stages as it starts, and a
headless import that fails now says so and exits non-zero rather than sitting
in an error state that looks exactly like a hang.

A Gold cache without `palettes.lua`, `moves.lua`, `encounters.lua`,
`trainers.lua`, `pokedex.lua`, `landmarks.lua`, `icons.lua`, `menu_gfx.lua`,
`intro.lua`, `std_scripts.lua` or `battle/hud/*.png` needs a re-import -- as
does one whose back pics are still the front pic's size rather than 48x48 (see
below), and one whose trainer classes have no `encounterMusic` (the sixth
pass added `TrainerEncounterMusic` to the manifest, so the manifest has to be
regenerated as well).  So does one whose `text.lua` has no `labels` table: that
is the by-name seed for the text no script pointer reaches (the Day-Care and
breeding block, the mart conversation, the Hall of Fame headers), and it needs
a regenerated manifest too, because the seed reads those symbols by name.

## Traps this port has already fallen into

Worth knowing before touching the extractor:

- **Back pics are always 6x6 (48x48).**  `BASE_PIC_SIZE`'s low nibble describes
  the *front* pic only, so decoding a back at it reads the wrong tile count in
  the wrong number of columns and produces garbage.
- **`#`, `<POKE>` and `<PKMN>` have no font tile.**  They are compression bytes
  ($54/$24/$4a) that PlaceString expands; the manifest charmap has to expand
  them or "#DEX" renders as "DEX".
- **FishGroups has no row for FISHGROUP_NONE**, so a group's row is its id minus
  one.  Walking the constant list from the top reads every row shifted.
- **Trainer groups have no end marker** -- the next group's label follows
  immediately -- so a party scan needs the class's own member list to bound it.
- **Pokedex entries are spread over four banks** and the cart derives the bank
  arithmetically; take each species' own symbol instead.
- **`EvosAttacksPointers` is `dw`, not `dba`**: the blobs share the table's bank.
- Item ids past NUM_ITEMS (the TMs and HMs) have no ItemNames row; their name is
  their TM number.
- **`TrainerClassAttributes` rows are SEVEN bytes**, not eight:
  `NUM_TRAINER_ATTRIBUTES` is `_RS` after three `rb` and two `rw`.  An
  eight-byte stride walks one byte further off with every class, so the AI
  flags come out as noise for everything past the first trainer -- and it
  produces plausible values rather than an error, which is how it survived two
  passes.  The row is {item1, item2, baseMoney, aiLo, aiHi, switchLo,
  switchHi}: the base money is byte THREE.
- **`dba_pic` does not store the real bank.**  For the three "Pics" sections
  that sit above the 8-bit-friendly range it writes `$13`, `$14` or `$1f`, and
  `FixPicBank` (engine/gfx/load_pics.asm) maps those back to `$1f`, `$20` and
  `$2e`.  Any table of pic pointers -- `PokemonPicPointers`,
  `UnownPicPointers`, `TrainerPicPointers` -- needs that mapping, or the read
  lands in a completely different bank.
- **A pic can run over the top of its bank.**  `GetLZByte` bumps the bank and
  drops back to `$4000` when the read pointer passes `$8000`, so a compressed
  pic near the top of a bank keeps going into the next one; slicing only to
  `$8000` stops short of nine of the Unown letters.
- **`BattleAnimObjects` rows are SIX bytes**, because `BATTLEANIMOBJ_LENGTH` is
  `_RS - 1` -- the struct's runtime INDEX byte is not in the table.
- **Unown has no `PokemonPicPointers` row of its own**; its twenty-six forms
  come out of `UnownPicPointers` instead, and letter A stands in for the
  species.

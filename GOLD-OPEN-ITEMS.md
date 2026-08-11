# Gold port: what is still open after the 2026-08-09 asm parity runs

Two multi-agent runs diffed the Gold port against the `pokegold` disassembly
(`../pokegold`) and fixed what diverged. Round 1 confirmed 51 defects across 14
paired clusters; round 2 confirmed 41 more across 13, including one crash. A
third round (2026-08-10) closed the mod-API boundary: see "The 2026-08-10
mod-API round" below for what that opened and closed.

Every tier is green at the end of all three: `run_engine` 131/131, `run_tests`
ALL TESTS PASSED, `run_modkit` 6/6, `run_save_editor_tests` 650/0,
`run_link_tests` ALL PASSED.

This file records only what is NOT done, so nobody re-derives it. It is a
working handoff doc in the shape of `KANTO-CONTINUE.md`, not user documentation.

## Do this first or none of it is visible

**Re-import the Gold cache.** Seven fixes live in the extractor and the manifest
tool, so they do nothing until the ROM is re-imported. This was verified still
outstanding on 2026-08-10: the default identity's
`gold/data/generated/menu_gfx.lua` has no `trainerPics` key at all, so a trainer
battle still opens on the mon rather than the trainer even though the Lua half
is fixed and correct.

- trainer frontpics (`TrainerPicPointers` walk in `extractMenuGfx`), which is
  the missing trainer intro image at the start of a trainer battle. The Lua
  side is now right and re-import is the ONLY thing left: `Trainers.lookup`
  returns a numeric `class` (36) beside a `classId` (`BUG_CATCHER`), and both
  `menu_gfx.trainerPics` and `palettes.trainers` are keyed by the constant, so
  the lookup had to move to `classId`. On a cache that carries the pics the
  frontpic renders in the class's own palette.
- egg assets: `battle/front/egg.png` and `menu/egg_hatch.png`, feeding the
  hatch cutscene and the summary screen's egg page. A fallback landed in the
  meantime (`ICON_EGG` frame 0, which resolves to a real 16x16 frame), so the
  egg page draws SOMETHING on a stale cache; `tools/rom_manifest_gold.json`
  carries `EggPic` at `[20, 31363]` and that stream decompresses to exactly 400
  bytes (a 5x5-tile pic), so a fresh import takes the real path.
- the Pokegear phone icon. `_LoadFontsExtra` (`engine/gfx/load_font.asm:8-15`)
  puts `FontsExtra_SolidBlackAndUpArrowGFX` at `$60`/`$61` and
  `PokegearPhoneIconGFX` at `$62`, ON TOP of `FontExtra`'s BOLD_A/B/C.
  `src/import/RomExtractorGen2.lua:342-356` reads `FontExtra` straight in and
  then blits only `Frames` over `$79-$7E`, so `$62` is still a bold "C" -- which
  is what the new caller box draws where the telephone glyph belongs. Fix is two
  files: add the two GFX symbols to `tools/rom_manifest_gold.json`, then blit
  them at `$60`/`$61`/`$62` in the loop that already handles `Frames`.
- `PREDEFPAL_UNOWN_PUZZLE = 76`, which is why the Ruins of Alph puzzle rendered
  grayscale instead of brown
- the tilemap pad `0x7f -> 0x4f` in `readTilemapRLE` / `readFlatTilemap`
- held-item icons (`HeldItemIcons` in the manifest, `out.heldItem` in
  `extractIcons`), which is the held-item marker in the party menu
- the NPC-trade rows' `item` field, which is what made the Violet City Onix's
  Bitter Berry print as "83"

## Open: real unknowns, each needs a cache and a driver run

1. **Magnet train renders a blank field.** Pushing `World:magnetTrain` directly
   shows nothing for 90+ frames (see shot `03-magnet-train.png`). The screen's
   surround is correct now; what was never investigated is whether
   `drawBackground` needs setup that the direct push skips. This cannot be
   settled by reading source.

2. **The NPC that introduces Unown never appears.** Round 1 could not produce a
   port ref that diverges from the asm, so it is filed `cannot_locate`, not
   fixed. The cart chain is: solve a chamber puzzle, then
   `setmapscene RUINS_OF_ALPH_INNER_CHAMBER, SCENE_RUINSOFALPHINNERCHAMBER_STRANGE_PRESENCE`
   from `maps/RuinsOfAlphKabutoChamber.asm`. Walk that chain live rather than
   statically: the static read came back clean twice.

3. **Two pic sites still resolve an Unown off the species.**
   `src/ui/gen2/PhotoStudio.lua:102` and `src/ui/gen2/EvolutionAnim.lua:460` use
   `def.spriteFront` without going through `Unown.formSprite`. For EvolutionAnim
   this is almost certainly dead (Unown does not evolve). For PhotoStudio it is
   genuinely unclear: the cart's `engine/events/print_photo.asm` does not call
   `GetUnownLetter` at all, so the port may already match. Check before changing.

4. **Unown dex registration on obtain paths.** `engine/pokemon/evolve.asm:310`
   runs `GetUnownLetter` then `callfar UpdateUnownDex` after
   `SetSeenAndCaughtMon`, guarded by `cp UNOWN`. That is dex bookkeeping, not
   rendering, and it was never audited across every path that gives the player a
   mon. `GetUnownLetter` has 20 call sites on the cart; the port covers the pic
   ones.

## The 2026-08-10 mod-API round

Six lanes closed the Gen 1 / Gen 2 mod-API boundary and a batch of reported
gameplay bugs. What that round **closed**, so nobody re-opens it:

- Fifteen seams that had a Gen 2 site but no entry in the parity gate are now
  listed and asserted: the four `intro.oak_speech.*` events plus the
  `intro.oak_speech.build` hook, `battle.overlay`,
  `battle.low_health_alarm`, `battle.catch_exp`, `pokemon.sprite`,
  `input.step`, `input.pointer`, `render.zones`, `render.compose`,
  `render.letterbox`, `render.hud`. Five more (`intro.boot.*`) are listed as
  Gen 2-only. `tests/engine/gate_gen2_mod_api.lua` is 893/893.
- Two registries un-gated on Gold after their consumer landed:
  `battle_sprite_scales` (`src/ui/gen2/BattleState.lua:imageScale`) and
  `render_pipelines` (`src/core/Game2.lua:load` installs
  `src/render/Pipelines.lua` on the merged dataset after `mods:load`). Both
  keep the SHARED Gen 1 target, so one mod record serves both games. 40 of the
  46 registries are now available on Gold.
- `hook:render.zones` came off the `gate_meta_coverage.lua` DEBT ledger, which
  is now four entries, all M7/M12 link and give-mon seams.

What that round **left open**, each verified on 2026-08-10:

1. **`render_pipelines`' `drawWorld` half is inert on Gold.** Gold's overworld
   draws straight to the window rather than into a canvas the way
   `src/world/OverworldController.lua` hands one to `Pipelines.drawWorld`, so a
   drawWorld-only pipeline renders nothing. It is not left switched on
   pretending: `Game2:load` retires a restored level for one and re-applies
   Tilt from the option the exclusion just cleared, leaving
   `options.pipelines` untouched so the mode returns the day Gold grows a world
   canvas. Related: `Pipelines.rows` is read only from
   `src/ui/OptionsMenu.lua`, so a pipeline on Gold has a hotkey and no OPTION
   row.

2. **`transitions` stays gated and should.** `src/ui/gen2/BattleTransition.lua`
   keys `STYLES` as a boolean SET of the four cart wipes (`spin`, `speckle`,
   `zoom`, `sine`), not the `{ frames, draw, sound, flash }` record the
   registry carries, and there is no styleDef lookup a mod id could reach --
   a registered style would fail the membership test and fall back to vanilla.
   Un-gating it before that changes would be the silent no-op the routing table
   exists to prevent. Same for `rulesets`, `field`, `text_pointers`,
   `link_fields` and `map_scripts`; `docs/mod-api-gen2-compat.md` carries the
   per-registry reason.

3. **`src/core/Game2.lua:joystickremoved` is half of Gen 1's.**
   `src/core/Game.lua:867` does `self:recoverInput("joystickremoved", joystick)`
   AND `TouchControls:joystickremoved()`; Game2 does only the pad half, so a
   controller unplugged mid-hold leaves Gold's Input state stranded and a held
   direction walks forever. It was a total noop before, so this is not a
   regression -- it is a seam finished halfway. One line.

4. **`Game2` noops five joystick callbacks.** `joystickpressed`,
   `joystickreleased`, `joystickaxis`, `joystickhat` and `joystickadded` are
   assigned `noop`, so a stick with no SDL game-controller-database entry
   reaches neither Input nor `GamepadMap.RAW_BUTTON_BINDINGS` on Gold. Gen 1
   handles all four (`src/core/Game.lua:764-797`). A DualSense is
   SDL-recognized and takes the gamepad path, so this is not the reported
   SELECT bug -- it is the raw-stick fallback.

5. **`Game2:gamepadpressed` has no SELECT-held guard.** Gen 1
   (`src/core/Game.lua:686-694`) suppresses the shoulder GAME SPEED cycle while
   SELECT is held, because Select+L is a display chord on NX. Harmless today
   (Gold has no display chord) but the two paths have diverged.

6. **`hideCallerBox`'s fallback path skips the screen seams.**
   `src/script/gen2/CallAsm.lua:217-231` pops through `stack:pop` when the
   caller box is top (which it always is on a normal call, since `PhoneRing`
   runs `closetext` before `InitCallReceiveDelay`) but falls back to a bare
   `table.remove(states, index)` otherwise, which raises neither `exit` nor
   `screen.popped`. Only a mod screen pushed over the box can reach it, and
   then a listener that saw `screen.pushed` never sees the pop.

7. **`src/core/gen2/Roamers.lua:338` says the wrong thing.** Its comment says
   "the shared `encounter.species` hook still runs downstream and is where a
   mod changes what appears". It does not: `World:tryWildEncounter` calls
   `startBattle` on a roamer hit and RETURNS before it reaches
   `World:rollEncounter`. The doc's partial-coverage list is right and the
   comment is wrong; correct the comment, not the doc.

8. **`src/world/gen2/World.lua:4318` still calls the pack's SEL row something
   "this port has not built".** The pack submenu now offers SEL. Stale comment.

Three partial coverages that are documented and still true, repeated here
because "the hook exists" is not "the hook sees everything":
`encounter.roll` / `encounter.species` are not wired into `World:tryHeadbutt`,
`World:rockMonEncounter` or the roamer path; `src/ui/gen2/BattleState.lua`
builds a flat `opts` for `Catching.attempt` with no `data` in it, so a
mod-registered ball is readable through `Catching.recordFor` but is not
resolved at the real throw site; and no Gen 2 UI file reads
`Battle.statusRecordFor(data, status).hudLabel`, so a mod status shows no label
in the battle HUD, the party menu or the summary page.

## Open: cleanups declined on purpose

These were skipped with reasons during the wiring pass. They are listed so the
reasons survive, not because they are pending work.

1. **`Vm:showRaw(body, stay)`** was proposed and declined. `showRawHeld` in
   `Specials.lua` already answers the text lookahead correctly, so this trades
   one working shape for another.

2. **`tests/drivers/gold_egg_hatch.lua` summary push** was declined as
   redundant: `gold_egg_hatch_shots.lua` already photographs both the cutscene
   and the summary page.

3. **Two `Battle.lua` divergences** were filed as notes by the file's own owner
   rather than fixed, because no reported symptom drives either: text printed
   for an already-statused target, and Future Sight taking STAB, type
   effectiveness and weather. Both are real divergences from the cart. Fix them
   when something actually depends on them.

## Reported, investigated, and NOT defects: do not re-chase these

Each of these came in as a bug report and came back disproved against the asm.
Re-opening one costs another full investigation, so the reasoning is kept here.

- **SFX pointer table misalignment.** The table is aligned end to end. 188 `dba`
  rows with no skips or padding, 188 constants, verified through the manifest
  scraper, the extractor's `*3` stride, and 8 ids spot-checked against the live
  cache. Two things that look like misalignment are how the cart is built:
  `SFX_GET_EGG_UNUSED` and `SFX_GET_EGG` both point at `Sfx_GetEgg`, and
  `Sfx_ReadText` / `Sfx_ReadText2` share one header address. **Do not repoint,
  re-stride, or add an offset to the SFX, music, or cry tables.**

- **Bind letting you pick other moves.** This is Gen 1 behavior and does not
  hold for Gen 2. `BattleCommand_TrapTarget` (`effect_commands.asm:5568-5605`)
  writes only the TARGET's wrap count and trapping move. It touches nothing on
  the user, so the user is free to switch moves. The port is correct. The real
  Gen 2 move locks (Rollout, Thrash, Petal Dance) were genuinely missing and
  have been added.

- **The Slowpoke Tail salesman not blocking progression.** He is Route 32's
  `FISHER4` at (7,70), not an Azalea Town object, and the cart's refusal arm
  only prints. `_OfferToSellSlowpokeTail` runs `setscene SCENE_ROUTE32_NOOP`
  first, so the coord event never fires again. There is no pushback to port.

- **The rival being named BLUE.** Not reproducible. The whole chain is intact:
  special 36 resolves to `H.NameRival`, `NamingScreen:accept` hands the typed
  string through, and BLUE is the Gen 1 default that Gold never reaches. A
  separate real defect on this seam (the rival being pre-named SILVER before the
  officer asks, and the blank-entry fallback) was found and fixed.

- **Not Very Effective dealing 0 damage**, **status not shown in the battle
  UI**, and **the Pokedex missing from the Start Menu** all came back
  `already_fixed`: the damage floor is `MIN_DAMAGE` added after the cap and
  before the type multiply, the HUD prints the status tag where the level goes,
  and the menu row is gated on `save.engineFlags[11]` correctly.

## Standing risks, not breakage

- **Four Gold test files are wired into no runner**, so a regression in them
  will not turn `run_tests.lua` red: `gold_flag_names_test`,
  `gold_route_validate_test`, `gen2_pokegear_unlock_test`,
  `gen2_save_export_test`. All four pass standalone. The first two are the
  pre-run route validators documented in `KANTO-CONTINUE.md`; the last two need
  a `GOLD_CACHE` and are excluded by an in-file comment. This is deliberate, but
  it is a coverage hole and worth knowing.

- **`mods/` must stay clean.** The 2026-08-10 round left temporary probe mods
  behind mid-run (`mods/tmp_menus`, `mods/zz_verify_seams`); both are gone now
  and `mods/` holds only `example_mew_starter`, `example_silly_oak`, `examples`
  and `nuzlocke`. A stray `mods/tmp_*` loads on every Gold boot and changes what
  a driver measures. `mods/example_silly_oak` carries only a `.modkitignore` and
  warns "manifest.json does not exist" on every boot; that is pre-existing
  (27 Jul) and unrelated.

- **`tests/drivers/gold_opaque_surround.lua` is stale.** It reads
  `game.stack._items`; `src/core/StateStack.lua` has only `.states`. That branch
  is covered instead by `gold_center_pc` and the letterbox-per-frame count in
  `gold_frame_seams`.

- **`luac` on this machine is Lua 5.5**, so `luac -p` is a weak proxy for the
  LuaJIT/5.1 semantics this engine targets. Use `luajit -b <file> /dev/null` for
  a real syntax gate.

- **`docs/rfcs/0001-surfing-pikachu-sprite.md` and `0002-screen-render-visible.md`
  are deleted** in the working tree, and both are still referenced by name from
  live modkit case files that pass. Those deletions predate both parity runs.
  Worth resolving before a commit.

## The failure mode that actually bit, worth remembering

Round 1 reported the Yes/No dialogue fix as landed. It was not. Two of its three
lanes wrote their half, and the third left the hook closure at
`World.lua:828` declared as `function(body, onDone)`, so the third argument
`Vm:resume` passes was silently discarded and the entire `stay` implementation
in `World:showText` and `World:askYesNo` was dead code. Lua drops extra
arguments without complaint, so nothing failed and every suite stayed green.

Round 2 caught it only because an investigator probed the boundary empirically
instead of reading both sides and assuming they met. When work is split across
agents by file, **the seams between the files are where the bugs live**, and a
green suite does not prove a seam is connected.

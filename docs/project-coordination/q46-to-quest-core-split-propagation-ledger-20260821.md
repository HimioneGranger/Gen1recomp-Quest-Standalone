# Q46 to Quest/Core split propagation ledger

## Result

The split worktree started clean at
`14930a5965382ee01a4d84a205c2a9c9a44c122c`. The authoritative Q46 source
was clean at `072706245779ae664a995c9dc7d2acafaae982c0`. Their merge base is
`1c8ba5cd103f31dde7b436f6f5857d3caf44930f`.

At split checkpoint `cea13f54`, every tracked path had the same content as
Q46. The only later tracked change is this ledger. The Q46 worktree stayed
unchanged. The four Q46 split commits are patch-equivalent to the target's
existing split commits:

| Q46 commit | Existing target commit | Result |
|---|---|---|
| `4261702e` | `a12d74aa` | Exact patch already present |
| `9a9f0c85` | `48bef560` | Exact patch already present |
| `cf4443e1` | `1f80f5bb` | Exact patch already present |
| `fefa8b3f` | `14930a59` | Exact patch already present |

All other Q46 commits through `07270624` were propagated in their original
order as commits `72e96e26..cea13f54`.

## Test codes

- `T`: exact tracked-tree match between split `cea13f54` and Q46 `07270624`.
- `P`: all 51 changed Lua files parsed; all 36 focused changed-path tests passed.
- `H`: host boundary, display, lifecycle, import, Android extension, OpenXR,
  SAF/focus, and host-adapter tests passed.
- `Q`: Quest profile, flavor, panel, diagnostic, launch-progress, loading,
  preview, and Load Report tests passed.
- `E`: each added portable engine test passed. The full suite was 191/193 on
  WSL. The two unchanged failures are recorded under Blockers.
- `M`: modkit was 15/15; the grayscale Python tests were 2/2.
- `B`: accepted-baseline gate was 9/9.
- `A`: four offline APK builds and package proofs passed.
- `D`: ancestry, content, protected-path, and `git diff --check` audit.

## Path-by-path ledger

### Shared compatibility interface and launcher consumers

| Source commit/path | Class | Target layer | Decision | Test | Final status |
|---|---|---|---|---|---|
| `548c2f66,07270624` `src/core/PlatformProfile.lua` | shared compatibility interface | portable profile policy | Propagate inactive T-Shift and V-Curve filters without changing saved values | `P,Q,T` | Exact at `cea13f54` |
| `548c2f66` `src/import/LauncherSettings.lua` | shared compatibility interface | launcher settings | Propagate Quest defaults and filtering | `P,Q,T` | `72e96e26` |
| `548c2f66` `src/import/LauncherView.lua` | shared compatibility interface | launcher view | Propagate bounded launcher behavior | `P,Q,T` | `72e96e26` |
| `548c2f66,3cfc9d6c` `src/import/QuestLaunchProgress.lua` | shared compatibility interface | launcher-to-host handoff | Propagate bounded progress evidence hooks | `P,Q,T` | `72e96e26,ce9e874b` |
| `548c2f66,9a9f0c85` `src/import/RomImporter.lua` | shared compatibility interface | portable importer boundary | Propagate launcher fix; keep existing split host boundary | `P,H,Q,T` | `72e96e26`; split patch already present |
| `548c2f66` `src/ui/OptionsMenu.lua` | shared compatibility interface | Gen 1 menu consumer | Propagate Quest row filters | `P,Q,T` | `72e96e26` |
| `548c2f66` `src/ui/TitleState.lua` | shared compatibility interface | Gen 1 title consumer | Propagate Quest paper surround | `P,Q,T` | `72e96e26` |
| `548c2f66` `src/ui/gen2/OptionsMenu.lua` | shared compatibility interface | Gen 2 menu consumer | Propagate Quest row filters | `P,Q,T` | `72e96e26` |
| `548c2f66,3cfc9d6c` `src/ui/kit/Loader.lua` | shared compatibility interface | shared loader | Propagate launcher and V8 loading ownership | `P,Q,T` | `72e96e26,ce9e874b` |
| `548c2f66,3cfc9d6c` `tests/engine/quest_launch_progress_test.lua` | shared compatibility interface | launcher contract test | Propagate | `P,Q,T` | Passing |
| `548c2f66,07270624` `tests/engine/quest_settings_profile_test.lua` | shared compatibility interface | profile/menu contract test | Propagate | `P,Q,T` | Passing |
| `9a9f0c85` `main.lua` | shared compatibility interface | host bootstrap/lifecycle consumer | Keep patch-equivalent split implementation | `H,T` | Already present via `48bef560` |
| `9a9f0c85` `mobile/android/love/src/jni/love/src/common/android.cpp` | shared compatibility interface | Android host API | Keep patch-equivalent split implementation | `H,A,T` | Already present via `48bef560` |
| `9a9f0c85` `mobile/android/love/src/jni/love/src/common/android.h` | shared compatibility interface | Android host API | Keep patch-equivalent split implementation | `H,A,T` | Already present via `48bef560` |
| `9a9f0c85` `mobile/android/love/src/jni/love/src/modules/system/System.cpp` | shared compatibility interface | LÖVE system boundary | Keep patch-equivalent split implementation | `H,A,T` | Already present via `48bef560` |
| `9a9f0c85` `mobile/android/love/src/jni/love/src/modules/system/System.h` | shared compatibility interface | LÖVE system boundary | Keep patch-equivalent split implementation | `H,A,T` | Already present via `48bef560` |
| `9a9f0c85` `mobile/android/love/src/jni/love/src/modules/system/wrap_System.cpp` | shared compatibility interface | Lua system binding | Keep patch-equivalent split implementation | `H,A,T` | Already present via `48bef560` |
| `9a9f0c85` `mobile/android/love/src/main/java/org/love2d/android/GameActivity.java` | shared compatibility interface | generic Android host | Keep patch-equivalent split implementation | `H,A,T` | Already present via `48bef560` |
| `9a9f0c85` `src/core/HostBootstrap.lua` | shared compatibility interface | portable host interface | Keep patch-equivalent split implementation | `H,T` | Already present via `48bef560` |
| `9a9f0c85` `src/core/HostDisplay.lua` | shared compatibility interface | portable host interface | Keep patch-equivalent split implementation | `H,T` | Already present via `48bef560` |
| `9a9f0c85` `src/core/HostLifecycle.lua` | shared compatibility interface | portable host interface | Keep patch-equivalent split implementation | `H,T` | Already present via `48bef560` |
| `9a9f0c85` `src/core/ImportHost.lua` | shared compatibility interface | portable import interface | Keep patch-equivalent split implementation | `H,T` | Already present via `48bef560` |
| `9a9f0c85` `src/core/Platform.lua` | shared compatibility interface | portable platform interface | Keep patch-equivalent split implementation | `H,T` | Already present via `48bef560` |
| `9a9f0c85` `tests/engine/android_host_extension_test.lua` | shared compatibility interface | Android boundary test | Keep patch-equivalent test | `H,T` | Passing |
| `9a9f0c85` `tests/engine/host_boundary_test.lua` | shared compatibility interface | boundary test | Keep patch-equivalent test | `H,T` | Passing |
| `9a9f0c85` `tests/engine/host_display_test.lua` | shared compatibility interface | display test | Keep patch-equivalent test | `H,T` | Passing |
| `9a9f0c85` `tests/engine/host_lifecycle_test.lua` | shared compatibility interface | lifecycle test | Keep patch-equivalent test | `H,T` | Passing |
| `9a9f0c85` `tests/engine/import_host_test.lua` | shared compatibility interface | import test | Keep patch-equivalent test | `H,T` | Passing |
| `fefa8b3f` `scripts/test.sh` | shared compatibility interface | verification entry point | Keep patch-equivalent gate registration | `B,D,T` | Already present via `14930a59` |
| `fefa8b3f` `scripts/verify_accepted_baseline.sh` | shared compatibility interface | recovery gate | Keep patch-equivalent script | `B,D,T` | Already present via `14930a59` |
| `fefa8b3f` `tests/accepted_baseline_gate_test.sh` | shared compatibility interface | recovery test | Keep patch-equivalent test | `B,D,T` | Passing 9/9 |

### Quest-only adapter, host, and presentation

| Source commit/path | Class | Target layer | Decision | Test | Final status |
|---|---|---|---|---|---|
| `4261702e` `src/host/android/QuestOpenXRDisplay.lua` | Quest-only adapter/host | Android OpenXR backend | Keep patch-equivalent versioned API | `H,Q,T` | Already present via `a12d74aa` |
| `4261702e` `tests/engine/quest_openxr_display_test.lua` | Quest-only adapter/host | OpenXR contract test | Keep patch-equivalent test | `H,Q,T` | Passing |
| `cf4443e1` `mobile/android/love/src/questVr/java/org/love2d/android/QuestGameActivity.java` | Quest-only adapter/host | Quest activity | Keep patch-equivalent adapter binding | `H,A,T` | Already present via `1f80f5bb` |
| `cf4443e1` `src/quest/compat/HostAdapterV1.lua` | Quest-only adapter/host | Quest compatibility adapter | Keep patch-equivalent adapter | `H,Q,T` | Already present via `1f80f5bb` |
| `cf4443e1,357a5a36` `tests/engine/quest_android_flavor_isolation_test.lua` | Quest-only adapter/host | flavor boundary test | Keep base and propagate diagnostic additions | `H,Q,A,T` | `b265a2da`; passing |
| `cf4443e1` `tests/engine/quest_host_adapter_test.lua` | Quest-only adapter/host | adapter contract test | Keep patch-equivalent test | `H,Q,T` | Passing |
| `357a5a36,f7499d12,3cfc9d6c,45fd358c` `mobile/android/love/src/jni/questxr_bridge/questxr_bridge.c` | Quest-only adapter/host | native OpenXR host | Propagate diagnostics, bounded exit evidence, loading ownership, and shared gaze-35 placement | `H,Q,A,T` | `b265a2da,d9a65982,ce9e874b,441225d0` |
| `357a5a36,f7499d12` `tests/engine/quest_boundary_diagnostic_contract_test.lua` | Quest-only adapter/host | boundary diagnostic test | Propagate | `H,Q,T` | Passing |
| `357a5a36,3cfc9d6c,45fd358c` `tests/engine/quest_panel_placement_contract_test.lua` | Quest-only adapter/host | panel contract test | Propagate shared gaze-35 placement | `H,Q,T` | Passing |
| `3cfc9d6c` `assets/logo/gen1recomp_unplugged.png` | Quest-only adapter/host | loading source asset | Propagate source asset | `Q,A,T` | `ce9e874b` |
| `3cfc9d6c,430b7315` `scripts/render_quest_loading_preview.py` | Quest-only adapter/host | deterministic preview tool | Propagate V8 renderer | `Q,T` | `ce9e874b,2f12795e` |
| `3cfc9d6c,430b7315` `src/ui/kit/QuestLoadingScreen.lua` | Quest-only adapter/host | Quest loading presentation | Propagate V8 loading-screen ownership | `P,Q,A,T` | `ce9e874b,2f12795e` |
| `3cfc9d6c,430b7315` `tests/engine/quest_loading_screen_test.lua` | Quest-only adapter/host | loading contract test | Propagate | `P,Q,T` | Passing |
| `430b7315` `assets/logo/gen1recomp_unplugged_tight.png` | Quest-only adapter/host | approved V8 loading asset | Propagate latest asset | `Q,A,T` | `2f12795e` |
| `430b7315` `tests/engine/quest_loading_preview_contract_test.py` | Quest-only adapter/host | preview contract test | Propagate | `Q,T` | Passing |

### Portable core and upstream parity

| Source commit/path | Class | Target layer | Decision | Test | Final status |
|---|---|---|---|---|---|
| `548c2f66,6f5101b6` `src/mods/ManagerState.lua` | portable core | mod manager | Propagate launcher policy and draw-color reset | `P,E,M,T` | `72e96e26,853de9b3` |
| `e7898df2,300ee6a6` `src/inventory/ItemEffects.lua` | portable core | inventory | Propagate nil TM/HM guard and translated stat text | `P,E,T` | `0e56898e,12627a5d` |
| `e7898df2` `tests/engine/item_tmhm_nil_test.lua` | portable core | inventory test | Propagate | `E,T` | Passing |
| `dd606600` `src/core/SaveData.lua` | portable core | save data | Propagate binding preservation; do not overwrite saved values | `P,E,T` | `3a5fed3a` |
| `c521ed69` `tests/engine/playthrough_fresh_binding_test.lua` | portable core | save test | Propagate | `E,T` | Passing |
| `2bace9db,54d614cd` `src/ui/BoxMenu.lua` | portable core | PC UI | Propagate Pikachu release fix and ROM text | `P,E,T` | `d59024b3,5fab9861` |
| `2bace9db` `tests/engine/pikachu_unhappy_release_crash.lua` | portable core | PC test | Propagate | `E,T` | Passing |
| `2956f5d3,758ae966,57bf20b4` `src/battle/BattleState.lua` | portable core | battle | Propagate drain cleanup and translated status labels | `P,E,T` | `7f874c55,dbaa0874,ca6afcae` |
| `2956f5d3` `tests/engine/battle_checkpoint_boundary.lua` | portable core | battle test | Propagate | `E,T` | Passing |
| `eb4117a2` `src/ui/BagMenu.lua` | portable core | bag UI | Propagate item-use hook | `P,E,M,T` | `1b5adb59` |
| `eb4117a2` `tests/engine/item_use_hook.lua` | portable core | hook test | Propagate | `E,M,T` | Passing |
| `e161cc7f` `src/mods/Schemas.lua` | portable core | shared mod schema | Propagate map-object Pokemon validation | `P,E,M,T` | `543e1c7a` |
| `e161cc7f` `tests/engine/map_object_pokemon_ref_test.lua` | portable core | schema test | Propagate | `E,M,T` | Passing |
| `f0b7edcc` `src/ui/SlotMachine.lua` | portable core | game UI | Propagate ROM text routing | `P,E,T` | `e95405c5` |
| `1d66f71b` `tests/engine/slot_machine_lined_up_romtext.lua` | portable core | UI test | Propagate | `E,T` | Passing |
| `54d614cd` `tests/engine/pc_release.lua` | portable core | PC regression test | Propagate | `E,T` | Passing |
| `e84d467c` `src/ui/ShopMenu.lua` | portable core | shop UI | Propagate ROM price text | `P,E,T` | `15ee643f` |
| `e84d467c` `tests/engine/shop_price_romtext.lua` | portable core | shop test | Propagate | `E,T` | Passing |
| `9c5768d3` `src/link/LinkBattle.lua` | portable core | link battle | Propagate ROM intro text | `P,E,T` | `d6c3b3af` |
| `9c5768d3` `tests/engine/link_battle_intro_romtext.lua` | portable core | link test | Propagate | `E,T` | Passing |
| `2aae05b9,c0ece427` `src/world/OverworldController.lua` | portable core | world | Propagate ROM field text and poison phase parity | `P,E,T` | `eb1a6bd4,0a456809` |
| `2aae05b9` `tests/engine/overworld_field_item_romtext.lua` | portable core | world test | Propagate | `E,T` | Passing |
| `2d9b9307` `data/scripts/story2.lua` | portable core | Gen 1 script data | Propagate museum translation | `P,E,A,T` | `961f905e` |
| `2d9b9307` `tests/engine/museum_1f_clerk_translation_test.lua` | portable core | script test | Propagate | `E,T` | Passing |
| `57bf20b4` `src/battle/Status.lua` | portable core | status registry | Propagate translatable abbreviations | `P,E,T` | `ca6afcae` |
| `57bf20b4` `src/ui/PartyMenu.lua` | portable core | party UI | Propagate status labels | `P,E,T` | `ca6afcae` |
| `57bf20b4` `src/ui/SummaryMenu.lua` | portable core | summary UI | Propagate status labels | `P,E,T` | `ca6afcae` |
| `57bf20b4` `tests/engine/status_abbreviation_translation_test.lua` | portable core | status test | Propagate | `E,T` | Passing |
| `300ee6a6` `src/battle/TrainerAI.lua` | portable core | battle AI text | Propagate translated stat-rise text | `P,E,T` | `12627a5d` |
| `300ee6a6` `tests/engine/stat_rise_message_translation_test.lua` | portable core | battle test | Propagate | `E,T` | Passing |
| `c0ece427` `tests/parity_field_poison_phase.lua` | portable core | parity test | Propagate | `E,T` | Passing |
| `6f5101b6` `tests/engine/manager_state_draw_color_reset.lua` | portable core | mod manager test | Propagate | `E,M,T` | Passing |
| `a41dc652` `tests/modkit/test_grayscale_cutoff.py` | portable core | modkit test | Propagate | `M,T` | Passing 2/2 |
| `a41dc652` `tools/modkit.py` | portable core | modkit tool | Propagate grayscale cutoff fix | `M,T` | `425faee4` |
| `3fb4fc83` `tests/engine/ledge_stepframes_timing.lua` | portable core | world timing test | Propagate | `E,T` | Passing |
| `3935c0b4` `src/ui/Diploma.lua` | portable core | Gen 1 UI | Propagate diploma rendering | `P,E,A,T` | `ce3e2c7c` |
| `3935c0b4` `tests/engine/diploma_test.lua` | portable core | UI test | Propagate | `E,T` | Passing |

### Durable evidence, packaging-only data, and exclusions

| Source commit/path | Class | Target layer | Decision | Test | Final status |
|---|---|---|---|---|---|
| `548c2f66` `docs/project-coordination/unplugged-app-repair-candidate-20260821.md` | generated or packaging-only | durable recovery record | Propagate source provenance | `D,T` | `72e96e26` |
| `548c2f66,3cfc9d6c,1d9053f7,0bfdc360` `docs/quest-launcher8-unplugged-parity-ledger.md` | generated or packaging-only | durable parity ledger | Propagate all Q46 records; do not copy old APKs | `D,T` | Exact at `cea13f54` |
| `9a9f0c85,fefa8b3f` `docs/quest-openxr-backend.md` | generated or packaging-only | host boundary documentation | Keep patch-equivalent record | `D,T` | Already present via split commits |
| `357a5a36,f7499d12` `docs/project-coordination/quest-panel-boundary-candidate-20260821.md` | generated or packaging-only | durable Quest evidence | Propagate bounded diagnostic record | `D,T` | `b265a2da,d9a65982` |
| `ad7ccf64` `docs/project-coordination/q46-defect-owner-test-matrix-20260821.md` | generated or packaging-only | durable owner/test map | Propagate | `D,T` | `0162ce44` |
| Q46 `.gradle/`, `.gradle-user-home/`, `.verification-*` | generated or packaging-only | local cache/evidence | Exclude; not tracked source and not portable | `D` | Not copied |
| Q46 `artifacts/**`, `dist/android/**` | generated or packaging-only | prior APK/device evidence | Exclude; preserve in Q46 only | `D` | Not copied |
| External DRAMALESS renderer/mod paths and artifacts | DRAMALESS-owned and excluded | DRAMALESS worktree/mod package | Exclude by owner boundary | `D` | No DRAMALESS path changed or copied |
| Earlier Q46 APK candidates named in the parity ledger | obsolete/superseded | packaging evidence | Keep hashes in durable history; do not promote or copy binaries | `D` | Superseded by fresh split candidates |

## Fresh offline candidate proof

Candidate directory:
`dist/android/candidates/q46-sync-cea13f54-20260821-001`.

Two independently created fixed-metadata archives had 469 entries and the
same SHA-256:
`68b2db666facdcf17f2e1f1027fe2c82991d5e4b790a8e4bdd1140c2672701a1`.
Each entry matched the Git blob at split checkpoint `cea13f54`. Every APK has
that exact `game.love`.

| Candidate | Package | SHA-256 |
|---|---|---|
| Normal no-record | `com.theboisclub.pokemonred` | `e7d66c61dc05e5c48d54e80f6c278ebb058521ff62487b6c002288e25539bddc` |
| Test no-record | `com.theboisclub.pokemonred.test` | `440d3ad38b10e8e64871ce821e848d1f0d89bcb5fb38e1862e3be4bc6d6e7c91` |
| Diagnostic no-record | `com.theboisclub.pokemonred.diagnostic` | `578050fa0802a4689950e6549eef90f280c7fe98d487154c64a5667c81b70430` |
| Record Test | `com.theboisclub.pokemonred.recordtest` | `713da0a49545ac9a2db0e86fa4450141c5415bb3246bf06bd20df3e4a6532d4d` |

All four are version `0.1.81` / code `181`, min/target SDK `24/34`, use
`org.love2d.android.QuestGameActivity`, set
`SDL_ENV.POKEPORT_QUEST_PROFILE=1`, omit `RECORD_AUDIO`, and contain six
ARM64 ELF libraries. Each archive has 439 safe unique entries, passes 4-byte
ZIP alignment, and verifies with APK Signature Scheme v2 and one debug signer.
The signer certificate SHA-256 is
`b1aa77b295eaaba52867af6dc7f9a2813590031208e93218d1c62b66c6c97291`.

## Preserved blockers

The full WSL engine run passed 191 of 193 suites. The two failures are unchanged
from split checkpoint `14930a59` and Q46; none of their source or test paths
changed in this propagation:

- `tests/engine/quit_thread_shutdown.lua`: its static source pattern no longer
  matches the current `main.lua` shape. Owner: portable engine lifecycle test.
- `tests/engine/title_zone_seams.lua`: its static extraction pattern no longer
  matches the current `src/render/Renderer.lua` shape. Owner: portable renderer
  test. DRAMALESS is not the owner.

No device, install, launch, ADB, headset, import, push, merge, rebase, amend,
release, dependency install, or network action occurred.

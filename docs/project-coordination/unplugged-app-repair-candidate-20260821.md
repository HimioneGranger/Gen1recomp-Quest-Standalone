# Unplugged app repair candidate — 2026-08-21

## Scope and recovery point

- Workspace: `Gen1recomp-Unplugged-App-Repair-Candidate-20260821`.
- Branch: `codex/unplugged-app-repair-candidate-20260821`.
- HEAD and exact base: `1c8ba5cd103f31dde7b436f6f5857d3caf44930f`.
- Start state: clean. No commit, stage, ref, remote, worktree, install, ADB,
  device, or release-signing action was done.
- Ownership: app launcher, app presentation, host handoff, and tests only.
  The DRAMALESS/Q42 renderer, shaders, sky, clouds, sun, moon, reflections,
  world geometry, models, crop/game quad, and mod assets remain external-owned.
  Black columns inside the DRAMALESS game quad remain external-owned.

## Authorized evidence

- Capture part 1, `00:00–00:45`: Launcher settings and Quest menu state.
- Capture part 1, about `00:45`: Play is selected.
- Capture part 1, about `00:49–01:45`: opening/title content appears with a
  white outer environment and black columns inside the game quad. No visible
  app-owned launch-progress frame occurs between Play and the opening route.
- Q43 recording, sampled from `00:00–02:20`: DRAMALESS world/game rendering is
  present. It supplies boundary evidence only; this lane did not change it.
- The dispatcher evidence audit was read in place. No recording, contact sheet,
  logcat, ROM, save, private app data, signing data, or protected content was
  copied into the worktree.

## Claim-to-test map

| Claim | App layer | Proof |
|---|---|---|
| Quest Play shows animated lightning before boot | `RomImporter`, `LauncherView`, `QuestLaunchProgress`, `Loader` | `quest_launch_progress_test`: 18/18; actual Quest route bindings, at least four distinct time-sampled bolt states, bounded completion |
| Red, Blue, and Yellow titles use Quest paper surround | Gen 1 `TitleState` plus `Renderer` | `quest_settings_profile_test`: route/source assertion; `title_fill_scale`: 8/8 |
| Yellow and Gold opening routes keep paper/sky surround | Existing opening states and Gen 2 widescreen title compositor | `quest_settings_profile_test`: all exposed opening state assertions; `title_fill_scale`: 8/8 |
| T-shift and V Curved are hidden on Quest | Profile filter at launcher, Gen 1 menu, Gen 2 menu, and mod manager consumers | `quest_settings_profile_test`: 80/80; source-consumer checks; supported row retained |
| Saved choices are preserved | Filters do not call setters or default writers | Profile test and source review; only absent values use existing defaults |
| Quest profile and package inputs are active | SDL flavor metadata and Diagnostic Gradle inputs | `quest_android_flavor_isolation`, `android_build_variant_output`, APK manifest and BuildConfig checks |
| Async SAF/mod return and lifecycle/focus remain intact | Existing importer and focus routes | `quest_saf_focus_recovery`: 15/15; Android pick 9/9; Android mod/save pick 14/14; mod bundle 42/42; modal focus 24/24; focus reset 3/3 |
| Tracked pointer/input and panel contracts remain intact | Launcher pointer and Quest host contracts | `quest_openxr_display`: 38/38; `quest_panel_placement_contract`: 5/5; launcher Gold touch rows 22/22 |
| Immersive handoff and exit ownership remain app-owned | Quest activity/host flavor and bounded launcher handoff | Quest flavor isolation, OpenXR display, launch-progress route test, successful native APK build |
| Variant labels, package, profile, and no-record inputs are correct | Gradle variant and manifest | Package `com.theboisclub.pokemonred.diagnostic`; label `Gen 1 Recomp Unplugged Diagnostic`; flavor `questVrNoRecord`; Quest profile value `1` |

## Verification

- Full Lua engine runner: 169/172 suites passed. Three existing Windows-shell
  harness failures remain: `build_zip_pipe_guard`, `quit_thread_shutdown`, and
  `title_zone_seams`. The changed suites pass when run directly.
- Focused app/Quest checks: 278/278 assertions passed across launch progress,
  profile/settings, SAF/focus, Android pick/import, mod bundle, modal input,
  focus reset, title scale, panel placement, OpenXR display, and Gold touch rows.
- Modkit runner: 15/15 suites passed.
- Python ROM-data CLI: 2/4 passed. Two existing failures compare `/` with
  Windows `\` path separators. No ROM data was generated.
- Changed Lua parse/static check: all 12 changed or added Lua files passed
  LuaJIT bytecode parsing. `git diff --check` has no whitespace error.
- Gradle `testQuestVrNoRecordDebugUnitTest assembleQuestVrNoRecordDebug`:
  successful, 57 actionable tasks (9 executed, 48 up-to-date); Java unit-test
  source is absent for this variant. The NDK built the ARM64 Quest libraries.
- Gradle lint is not runnable offline because the approved cache does not
  contain `com.android.tools.lint:lint-gradle:31.1.1`. No network or dependency
  update was used.

## Candidate APK provenance

- Artifact: `dist/android/candidates/Gen1recomp-Unplugged-Diagnostic-questVrNoRecord-debug-src-323458fd3eda.apk`.
- APK SHA-256: `88ebc69a055d36555a8565553d6d84c24dc73dab34f5fa6d0c8a3d7fbbf0f175`.
- Sidecar: same path with `.sha256` appended.
- Signature: task-local standard Android debug signing; APK Signature Scheme v2;
  one signer. No release keystore was read or used.
- Packaged-source digest: `323458fd3eda46805c8b43d8507dd5c9f0a5d738b0f2b15e05b6553cb8b60254`.
- Deterministic `game.love`: 462 sorted entries; two independent archives have
  SHA-256 `74902ace48d0591c6c92c4e4a1da25a5d1a26949abdadc60321986ec55d5683f`.
- All 462 packaged files match the final app source byte for byte. The APK is
  newer than the newest packaged source file.
- Identity: version `0.1.81` / code `181`, min SDK 24, target SDK 34,
  `QuestGameActivity`, Quest profile metadata `1`, Diagnostic true, no-record.
- Native payload: six ARM64-only ELF64/AArch64 libraries. Dynamic symbols were
  available in all six. Standard 4-byte ZIP alignment and APK signature verify.
- No protected-content path name was found in the APK or `game.love` entry list.
  Generated ROM data and protected content are absent.

## Remaining headset-only risks

- A headset must prove visible lightning frames survive the real Quest
  compositor and frame timing.
- A headset must prove Red, Blue, Yellow, and Gold opening/title surrounds at
  the available aspect ratios and letterbox states.
- A headset must prove all launcher and in-game menu paths hide only T-shift
  and V Curved, while existing choices and other supported rows remain intact.
- DRAMALESS/Q42 behavior, including inner game-quad black columns, needs proof
  in its owner lane and is not a claim of this candidate.

## Coordinator commit map

1. Launcher handoff: `QuestLaunchProgress`, `RomImporter`, `LauncherView`,
   `Loader`, and `quest_launch_progress_test`.
2. Quest presentation/settings: `PlatformProfile`, `TitleState`, the four menu
   consumers, and `quest_settings_profile_test`.
3. Coordination records: this report and the parity ledger update.

The ignored APK, checksum sidecar, local Gradle cache, local Android debug home,
and verification extracts are candidate build artifacts. Do not commit them.

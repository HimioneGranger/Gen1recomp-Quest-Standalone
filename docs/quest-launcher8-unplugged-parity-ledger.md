# Quest Launcher 8 to Unplugged parity ledger

## Result

The clean Unplugged baseline at `c4f06e96` contains the launcher-owned Quest
presentation and settings behavior. The rebuilt Diagnostic APK contains the
same source files byte for byte. Live evidence later proved that the installed
APK also matches that artifact. The remaining defect was product-profile
activation: it depended on the optional OpenXR panel FFI backend succeeding.
The Quest Android flavor now selects the profile directly through SDL manifest
environment metadata. Generic Android remains unchanged.

The isolated app-repair candidate at `1c8ba5cd` adds a bounded Quest-only
launcher handoff with six animated lightning states, makes Gen 1 title states
use the same Quest paper surround as the opening states, and hides the inactive
T-shift and V Curved mod rows at all launcher and in-game schema consumers.
These filters do not change saved values.

The world spawn correction, companion placement, and physical Pokédex are not
launcher features. They are DRAMALESS Q42 features. They must stay in the mod.

## Evidence

- Clean baseline: `c4f06e96`.
- Isolated audit branch: `codex/launcher8-deep-parity-20260820`.
- Preserved installed payload:
  `Gen1recomp-Quest-Standalone/artifacts-installed-original.apk`.
  Its `game.love` SHA-256 is
  `9D22E08F13DB418E091A6E4952301F3C9EAE57700BB58D869FC6F81550F88899`.
- Rebuilt clean Diagnostic payload:
  `Gen1recomp-Unplugged-Baseline-Integration/dist/android/debug/diagnostic/`
  `gen1recomp-unplugged-diagnostic-app-questVr-noRecord-debug.apk`.
  Its `game.love` SHA-256 is
  `9B6C84F6D0176825EA7303DD20BE864E7A3F56E4C528B2C20C1F6E2FC6FEBF7A`.
- The rebuilt APK copies of `Renderer.lua`, `TouchControls.lua`,
  `LauncherSettings.lua`, and `SaveData.lua` match baseline source SHA-256
  values exactly.
- DRAMALESS evidence: `Gen1Recomp-Mods/DRAMALESS_q42.zip`, manifest version
  `2.0.0-quest.42-pokedex-render-stability-test`.
- Headset evidence: the user reports black ROM-loading side bars, the wrong
  spawn facing, a companion overlap, and no physical Pokédex in the currently
  running Diagnostic session.

## Launcher-owned behavior

| Behavior | Historical or accepted source | Clean source | Rebuilt APK | State |
|---|---|---|---|---|
| Normal, Test, and Diagnostic identities | Accepted Unplugged build flow | Present | Present | Found |
| Quest product-profile activation | Quest flavor identity | `SDL_ENV.POKEPORT_QUEST_PROFILE=1`; independent of panel FFI | Flavor manifest | Fixed in this branch |
| White or palette-paper surround for all opening states | Accepted Quest presentation rule | Present in Gen 1 and Gen 2 opening states and `Renderer.lua` | Exact source match | Found; activation fixed |
| No Android phone touch overlay in Quest | Accepted Quest rule | `TouchControls` returns inactive for Quest | Exact source match | Found |
| Hide Video Mode | Quest has no desktop window mode | Hidden in launcher and game menus | Exact source match | Found |
| Hide Orientation | Quest owns immersive orientation | Hidden in launcher and game menus | Exact source match | Found |
| Hide Touch Pad | Quest uses tracked controllers | Hidden in launcher and game menus | Exact source match | Found |
| Hide Vibration | This row controls phone overlay haptics | Hidden in launcher and game menus | Exact source match | Found |
| Keep supported graphics and game controls | Launcher 8 feature set | Present; exact list below | Exact source match | Found |
| Advanced color default | New user-approved Unplugged default | `redpp`, label `ADVANCED` | Exact source match | New approved |
| Center shared room panel at gaze height | User-approved panel raise; headset retest pending | Shared offset `0.0 m` | Native source build | New candidate |
| Import and lifecycle recovery | Accepted Unplugged repairs | Present in baseline commits | Built in all variants | Found; device proof pending |
| Do not stop spawn for a mod-set-only report | Launcher 8 headset flow; 2026-08-20 capture exposed the regression | Quest suppresses only the informational mod-diff page; recovery and quarantine reports remain | Focused policy test | Repaired |
| Visible animated Quest launch progress | Capture part 1 has no app progress frame between Play and opening | Quest-only 0.75-second launcher-compositor handoff; six bolt states at 12 Hz | Four or more distinct sampled states; packaged source exact | Repaired; headset proof pending |
| Gen 1 title paper surround | Accepted Quest presentation rule | `TitleState` selects Quest paper letterbox fill | Red, Blue, and Yellow title route static/fixture test | Repaired; headset proof pending |
| Hide inactive T-shift and V Curved rows | Q42 handoff: these flat-pipeline rows do not affect the Quest compositor | Filtered in launcher, both game option menus, and mod manager | Focused profile and source-consumer tests | Repaired; saved choices preserved |

### Supported launcher rows retained on Quest

Text Speed, Battle Animation, Battle Style, Battle Layout, Battle Size,
Battle Background, UI Layout, Music Volume, SFX Volume, Music Filter,
Performance, Colors, Tilt, Void Fill, Faithful Ratio, Maximum FPS, Overworld
Speed, Battle Speed, Menu Speed, and Reset Rebinds.

### Supported in-game rows retained on Quest

The launcher rows remain available where applicable. The in-game menu also
keeps Ruleset, Zoom, Mods, Controls, Date Format, and Time Format.

### Core defaults

| Setting | Default |
|---|---|
| Text speed | Medium (`3`) |
| Battle animation | On |
| Battle style | Shift |
| Battle layout | Original |
| Battle size | Fixed |
| Battle background | White or palette paper |
| UI layout | Centered |
| Ruleset | Gen 1 faithful |
| Music, SFX, Pikachu volume | `7` |
| Performance | Auto |
| Colors | Advanced (`redpp`) |
| Tilt, zoom, GBC FX | Off (`0`) |
| Void fill | Trees |
| Faithful ratio | Off (`0`) |
| Maximum FPS | `60` |
| Overworld, battle, menu speed | `1x` |

The portable core still stores phone and desktop defaults for cross-platform
compatibility. Quest hides or disables the unsupported controls at runtime.
Existing player settings are preserved. Missing values receive defaults.

## DRAMALESS-owned behavior

| Behavior | Q42 evidence | State |
|---|---|---|
| Turn the initial first-person view by 180 degrees | `FirstPerson.takeQuestSpawnYawOffset()` returns `math.pi`; `VR.lua` consumes it once | Present in Q42; activation and headset proof pending |
| Place Yellow Pikachu beside the player | `placeQuestSpawnPartner()` moves an overlapping follower to the player's right | Present in Q42; activation and headset proof pending |
| Physical chest Pokédex | `Pokedex.lua` and `VR.lua` own the chest pose, either-hand grab, hand transfer, trigger open/close, menu input, throw, ground contact, and rear camera | Present in Q42; headset proof pending |
| DRAMALESS Quest defaults | `QuestDefaults.lua` seeds absent values only | Present in Q42; fresh-profile proof pending |
| Intro/game-surface black columns inside the white room panel | 2026-08-20 capture proves the outer Quest surround is white while the columns remain inside Q42's cropped quad | DRAMALESS `VR.lua` owns the game-surface crop and geometry | Missing; route to Q42 repair |

Q42 defaults are: grid off, curve off, real-time day/night sync, full water,
high shadows, anti-aliasing off, full render scale, Far render distance,
Smooth Turn on, 90 Hz, silhouettes on, invert Y off, battle background off,
and 2D battle cards on. Its VR compatibility value remains internal.

## Excluded behavior

- Do not copy the old monolithic `src/quest/dramaless` implementation into
  the portable core. Q42 is the current owner.
- Do not expose phone VR, anti-aliasing, Video Mode, Orientation, Touch Pad,
  or phone Vibration rows on Quest.
- Do not overwrite an existing player's saved choices to force defaults.
- Do not treat the black-bar headset report as proof of a source regression.
  The 2026-08-20 video proves the Quest profile is active because its outer
  surround is white. The remaining black columns are inside DRAMALESS's
  cropped game quad, not the launcher surround.
- Do not make the app select Stationary or Roomscale. The Quest host creates
  only OpenXR LOCAL and VIEW spaces and calls no Guardian boundary API. The
  captured log records the Quest OS changing `Roomscale -> Stationary` after
  an explicit `createNewActiveStationary` action; it records no app-triggered
  `Stationary -> Roomscale` transition.

## Open acceptance gates

1. Run the candidate on a headset and confirm that several lightning states
   are visible after Play and before the opening route.
2. Run fresh Red, Blue, Yellow, and Gold openings and titles at wide and narrow
   aspect ratios. Confirm a white or palette-paper outer surround and no phone
   touch controls.
3. Import and activate Q42. Confirm its manifest version in the mod list.
4. Confirm the 180-degree spawn correction, companion placement, and Pokédex.
5. If a failure remains, collect the exact Diagnostic log and package/payload
   identity from that run before another source change.

No device action was done during this audit.

## Portable upstream parity propagation — 2026-08-21

### Recovery point and source provenance

- Target workspace: local worktree
  `Gen1recomp-Unplugged-Corrected-Split-Candidate-20260821`.
- Target branch: `codex/unplugged-corrected-split-candidate-20260821`.
- Verified clean target start: `3cfc9d6c65954ec22308f6cb1ee5af2734dba3ed`.
- Latest launcher checkpoint at that start: `3cfc9d6c`,
  `feat(quest): propagate source-matched launcher screen`, on top of the
  corrected split and the recorded launcher/app repair chain.
- Canonical approved local-object snapshot:
  `codex/upstream-parity-batch2-20260820` at
  `3197ac955af9ba41591bd74d8e098295f125a535`.
- Canonical inventory:
  `docs/project-coordination/upstream-parity-ledger.md` at that snapshot.
  The inventory file itself was not replayed.
- The versioned host boundary series was already patch-equivalent:
  canonical `2d85eabc`, `b17f6c91`, and `8800521b` map to target
  `4261702e`, `9a9f0c85`, and `cf4443e1`.

### Applied portable source and test map

All source commits below are local equivalents already approved by the
canonical ledger. Target commits preserve the same small logical order.

| Approved upstream item or chain | Canonical local equivalent | Corrected-split target commit or commits |
|---|---|---|
| `2da2168d` | `5bdddf22` | `e7898df2` |
| `142d1358` | `341256e5`, `6e265d89` | `dd606600`, `c521ed69` |
| `abe176b2` | `3a58c773` | `2bace9db` |
| `881670db` | `ddefe423`, `964fa4b7` | `2956f5d3`, `758ae966` |
| `f62b1268` | `89285465` | `eb4117a2` |
| `455ff21a` | `2d506f8e` | `e161cc7f` |
| `17fbf6ce` | `3f9ac63f`, `14207f5d` | `f0b7edcc`, `1d66f71b` |
| `34c4481f` | `1c48f5db` | `54d614cd` |
| `2279617b` | `362843c3` | `e84d467c` |
| `8f88d01c` | `58927a28` | `9c5768d3` |
| `bff40a5d` portable field-message subset | `71e24327` | `2aae05b9` |
| `72c244b4`, `fbdfc1c0` | `b98227d6` | `2d9b9307` |
| `99849581`, `08518099` | `ce6adc91` | `57bf20b4` |
| `24d0c652` → `9423337b` → `d6ddf23f` | `b7ab6b6d` | `300ee6a6` |
| `abf95ce1` | `0cba40b4` | `c0ece427` |
| `b20b1370` | `8bc1e2d3` | `6f5101b6` |
| `667267d9` | `da50be1d` | `a41dc652` |
| `f1388279` | `8d037237` | `3fb4fc83` |
| `f5b8b6c8` approved Diploma subset only | `3197ac95` source/test subset | `3935c0b4` |

The exact approved Diploma source blob is
`ddcd6c738d83a3d9434feca01128c7347e775bb6`. The target blob matches it.
The seven inventory items recorded as exact already-equivalent deletions or
snapshots (`d38faab0`, `0aab11b6`, `a68c47e7`, `dfc216f9`, `a3bbd78e`,
`871087a1`, and `99806ead`) remain inherited from the accepted baseline; no
replay was needed.

### Exclusions preserved

- C2 `43957922`, C7 `f6a03594`, and C8 `90163a3f` remain blocked and were
  not replayed.
- For C9, only the independently approved Diploma source/test subset was
  replayed. `TownMap.lua`, `TradeAnim.lua`, `PaletteFX.lua`, and
  `version_blink_test.lua` remain deferred and unchanged.
- The deferred Softboiled field-action hunk and all other inventory items
  marked deferred, blocked, Gen 2-only, platform-only, prerequisite-sensitive,
  superseded, or build/release/docs-only remain out.
- Quest-only/OpenXR/native presentation, SAF/lifecycle, launcher and loading
  screen, host-adapter versioning, Android flavor/package identity, renderer,
  DRAMALESS, and protected package boundaries are unchanged. The only narrow
  boundary update is the approved portable `src/mods/Schemas.lua` map-object
  Pokemon validation, covered by its 6/6 focused regression. This protected
  boundary statement applies to the portable replay through `1d9053f7`. The
  later target-owned V8 launcher checkpoint is recorded separately below.

### Target verification before APK assembly

- Focused portable: 18 Lua files passed 145/145 checks; the synthetic
  grayscale cutoff Python module passed 2/2 tests.
- Exact neutral host: eight suites passed 140/140 counted checks;
  `android_host_extension_test.lua` also passed.
- Modkit: 15/15 suites passed. Launcher mod-bundle import passed 42/42.
- Quest/launcher contracts passed: flavor isolation, boundary diagnostics
  6/6, environment capability, host adapter 7/7, launch progress 23/23,
  load-report profile, loading screen 1471/1471, OpenXR display 39/39,
  panel placement 5/5, SAF/focus 15/15, settings profile 80/80, Android variant
  output 3/3, Gold launcher rows 22/22, modal focus 24/24, Android pick 9/9,
  Android mod/save pick 14/14, and focus reset 3/3.
- Full engine: target 190/193 suites; exact clean start `3cfc9d6c` 175/178.
  Both have the same three Windows/source-shape failures:
  `build_zip_pipe_guard_bug774`, `quit_thread_shutdown`, and
  `title_zone_seams`. All 15 added suites pass.
- Diagnostic package-only passed through Git Bash and skipped Gradle/signing.
- `git diff --check 3cfc9d6c..3935c0b4` passed. The tracked replay boundary is
  portable source/tests only. Protected-path scans found no prohibited edit.
- Through portable integration commit `1d9053f7`, no network, install, ADB,
  headset, ROM, save, private-data, push, merge, publish, release-signing, or
  device action occurred. The later packaging network exception is recorded
  below.

### Final launcher checkpoint and package records

- While package verification was in progress, the target branch received
  target-owned commit `430b731553c4089e65e23a9505c78bf5ee811259`,
  `feat(quest): approve V8 loading screen`. It is patch-identical to local
  launcher-audit commit `e19fa704b9545ae9963477a12f839a881a840441`;
  both have stable patch ID
  `714e7ba4aa96fd780b2d3dab6a08d08d34a89957`. It is not an upstream parity
  replay and does not change any portable mapping above.
- V8 verification: loading screen 4158/4158 checks; deterministic Python
  preview contract passed; launch progress 23/23; load-report profile passed;
  settings profile 80/80; panel placement 5/5; flavor isolation passed.
- Exact APK build HEAD: `430b731553c4089e65e23a9505c78bf5ee811259`.
  JDK 17.0.20 and direct local Gradle 8.5 ran the final app tasks in offline
  mode. Both `questVrNoRecordDebug` and the discovered recording flavor
  `questVrRecordDebug` assembled successfully. Their app unit-test sources are
  absent, so both unit-test tasks reported `NO-SOURCE`.
- Candidate directory:
  `dist/android/candidates/portable-parity-430b7315-20260821-001`.
- No-record APK SHA-256:
  `1aeb54cde1ea99b906e25da9659a90dba5a1694bac90746736f4369811d0de3c`.
- Record APK SHA-256:
  `10b5c611010a32a7ab70c9ae97bdac2052756c926e3f6c6332c61dd0af4023e3`.
- Both APKs embed source payload SHA-256
  `f7ffd764d4a50afb8feeec4ee68fb8e71e8f133f1a94105a9e569438af977412`.
  All 469 payload entries match the exact build-HEAD worktree. The two APKs
  have identical portable payloads and native libraries. Only `classes5.dex`
  differs for compiled `questVrNoRecord` versus `questVrRecord` identity.
- Both are Diagnostic `com.theboisclub.pokemonred.diagnostic` version
  `0.1.81` / code `181`, labeled `Gen 1 Recomp Unplugged Diagnostic`, with
  `QuestGameActivity`, Quest profile metadata value `1`, and ARM64-only six
  ELF64/AArch64 libraries.
- Both archives have 439 safe, unique entries and standard 4-byte ZIP
  alignment. The optional strict 16 KiB page-alignment check did not pass, so
  no 16 KiB alignment claim is made.
- APK Signature Scheme v2 verified with one debug signer. Certificate SHA-256
  `b1aa77b295eaaba52867af6dc7f9a2813590031208e93218d1c62b66c6c97291`
  matches both checked prior corrected-split artifacts.
- Final full engine: 190/193 suites. The same three exact baseline failures
  remain and V8 loading passes 4158/4158.
- A failed wrapper attempt downloaded the Gradle 8.5 distribution from
  `services.gradle.org` before project configuration despite `--offline`, then
  stopped because its task-local cache lacked Android Gradle Plugin 8.1.1.
  No accepted build input came from that attempt and it made no remote write.
  The accepted builds used direct local Gradle and local dependencies in
  offline mode. No other network action occurred.
- No install, ADB, headset, ROM, save, private-data, push, merge, publish,
  release-signing, or device action occurred.

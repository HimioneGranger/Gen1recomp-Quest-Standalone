# Quest 3 Port Debug and Milestone Log

This log records device-tested behavior for the `quest-openxr` branch. It is
based on checked source, builds, ADB logs, and physical Quest 3 tests; it does
not claim that the port is complete.

## Repository and commit location

- Active checkout: `E:\Gen1QuestVR\gen1recomp`
- Branch: `quest-openxr`
- Remote: `origin = https://github.com/bryanthaboi/gen1recomp.git`
- `quest-openxr` tracks `origin/dev` and is 10 commits ahead at `05c1d77`.
- Milestones are local Git commits. They have not been pushed to upstream, a
  fork, or any other hosting service.
- The prior checkout under `F:\CodexProjects\Gen1RecompQuest3-work` was
  copied, not destructively moved. `E:` is now the active source workspace.

## Tested hardware and toolchain

- Meta Quest 3; ADB serial `2G0YC1ZFB608RH`
- Android package `com.theboisclub.pokemonred`
- JDK 17.0.20+8; Android API/build-tools 34; NDK 25.2.9519653
- Device iteration ABI: `arm64-v8a`
- ABI-injected debug APKs require `adb install -t -r`.

## Milestones

| Commit | Milestone | Evidence |
|---|---|---|
| `271193c` | Phase 1 architecture audit | Source inventory and dependency classification recorded. |
| `9e45b75` | Stock Android baseline | Stock Android APK built before XR changes. |
| `ce944b7` | Quest loader seam | Quest-specific flavor/native seam isolated. |
| `dd35ca3` | Quest manifest | Head tracking and launcher metadata merged. |
| `568994d` | Importer panel mode | Existing ROM/mod import workflow retained. |
| `9b89fb8` | Immersive diagnostics | Quest experiments isolated from stock paths. |
| `ae2a8cb` | Native OpenXR quad | Quest displayed a dark-blue 1024x768 quad. |
| `c5668e0` | Live launcher bridge | Launcher reached the quad; capture still needed stabilization. |
| `05c1d77` | Stable launcher milestone | Fixed-size capture, persistent GPU texture, stable memory, and non-flashing launcher verified on-device. |

## Debug chronology and conclusions

### Immersive startup

- Immersive VR without an immediate OpenXR session left Quest on Meta's
  purple/blue loading environment.
- Meta can pause the ordinary SDL presentation path before Lua/mod startup is
  usable for session bootstrap.
- Conclusion: native Android OpenXR startup must begin from the Activity
  lifecycle before depending on Lua or mod initialization.

### Native bootstrap

- The bridge creates the Android OpenXR instance/session, private GLES 3
  context, reference spaces, 1024x768 quad swapchain, and frame loop.
- A zero-layer frame did not dismiss loading; a real quad layer produced the
  visible dark-blue panel.
- Logs verified framebuffer status `0x8CD5`, successful `xrEndFrame`, and a
  focused session.

### Launcher memory failure

- The initial live path called `love.graphics.captureScreenshot` on the
  4128x2208 Quest window at up to 15 Hz. One RGBA frame is roughly 36 MiB
  before extra copies.
- Logs showed `oom_reaper`, the LMK notifier, and memory pressure. No Java
  exception or native fatal signal occurred.
- Fix: GPU-scale the SDL back buffer, read only 1024x768, and exchange two
  reusable native buffers.
- Memory then remained approximately 180-215 MiB PSS during extended tests.

### Launcher flashing

- Direct writes to runtime-owned swapchain textures flashed visibly.
- Fix: upload new panel data into a persistent GLES texture and draw it into
  each acquired OpenXR image.
- Compositor captures also exposed intermittent all-black frames. The capture
  boundary now rejects effectively blank frames and preserves the last valid
  image.
- Physical result: launcher visible and non-flashing.

### Placement experiments

- `VIEW` space is reliable and keeps the launcher visible, but follows head
  movement.
- Direct `LOCAL` space could be stationary but flashed or disappeared after
  startup/recenter changes.
- Delayed anchoring and a VIEW-space counter-transform were not reliable over
  repeated launches.
- Current verified configuration deliberately uses `VIEW`. Room-stationary
  placement remains unfinished and must not replace it without repeated tests.

## Current verified state

- Native OpenXR session starts and stays focused at 90 Hz.
- Live launcher is visible in both eyes, updates, and does not flash.
- Launcher follows head movement by design for the current reliable build.
- Process remains alive without the prior low-memory kill.
- ROM and installed mod data remain outside Git and outside the APK.
- Android ROM/mod import remains intact.
- Quest Touch controller navigation is the next milestone.

## Repeatable build and install

```powershell
$env:JAVA_HOME='E:\Gen1QuestVR\jdk-17.0.20+8'
$env:ANDROID_HOME='F:\CodexProjects\Gen1RecompQuest3-work\toolchain\android-sdk'
$env:ANDROID_SDK_ROOT=$env:ANDROID_HOME
$env:GRADLE_USER_HOME='F:\CodexProjects\Gen1RecompQuest3-work\toolchain\.gradle'
Set-Location E:\Gen1QuestVR\gen1recomp\mobile\android
.\gradlew.bat --no-daemon '-Pandroid.injected.build.abi=arm64-v8a' assembleQuestVrNoRecordDebug
```

Output:

```text
E:\Gen1QuestVR\gen1recomp\mobile\android\app\build\outputs\apk\questVrNoRecord\debug\app-questVr-noRecord-debug.apk
```

```powershell
adb install -t -r app-questVr-noRecord-debug.apk
adb shell am force-stop com.theboisclub.pokemonred
adb shell am start -n com.theboisclub.pokemonred/org.love2d.android.GameActivity
```

When Lua/assets change, regenerate or update
`mobile/android/app/src/embed/assets/game.love` before Gradle packaging. Gradle
does not infer changes in source files outside that already-zipped payload.

## Best practices established

- Keep Quest work on `quest-openxr`; preserve stock Android/desktop paths.
- Commit device-tested milestones and record limitations explicitly.
- Clear logcat before tests and retain the exact APK path.
- Verify logs, memory, and the physical headset view. Logs alone did not expose
  visual flashing.
- Preserve the last known-good path while testing alternatives.
- Treat `game.love` packaging as a separate required step.
- Never package ROMs, generated ROM assets, or user mod state.
- Prefer fixed buffers and persistent GPU resources on Quest.
- A successful `xrEndFrame` does not prove that a layer is visible.

## Next milestone

Add Quest Touch input for launcher navigation/activation, then verify launching
the legally imported Yellow ROM and transitioning into Dramatic Shape VR.
Touch/mobile and desktop input paths must remain intact.

## 2026-08-09 — Touch input and gameplay OpenXR handoff

### Quest Touch input

- Added an OpenXR action set for the Oculus Touch interaction profile.
- Either thumbstick emits directional launcher navigation events.
- A, X, and either trigger emit Select; B and Y emit Back.
- The OpenXR thread writes edge-triggered events into a mutex-protected
  bitmask. LÖVE polls that bitmask on its own update thread and routes events
  through the existing keyboard handlers. No Lua callback crosses threads.
- Device logs verified native detection and Lua dispatch for directions,
  Select, and Back.
- Physical result: controller input successfully selected and launched Yellow.
- Remaining launcher issue: the user cannot see the keyboard-focus highlight
  move. Navigation/activation works, so this is a focus-ring visibility or
  captured-frame presentation defect rather than a missing input event.

### Frozen launcher after Yellow launch

- Initial symptom: Yellow audio and gameplay started, but the VR quad retained
  a still launcher image.
- The first suspected cause was the blank-frame guard sampling only the left
  edge. It was replaced with a grid across the full 1024x768 capture.
- Logs then proved the game backbuffer was genuinely blank while Dramatic
  Shape reported `xrInitializeLoaderKHR` failure.
- Root cause: the floating launcher and Dramatic Shape attempted to own
  independent OpenXR sessions in the same Android process. The launcher
  session remained active when the mod tried to initialize its gameplay path.

### Explicit session handoff

- Added exported native shutdown/request status functions for the launcher
  OpenXR loop.
- Dramatic Shape now requests launcher shutdown, waits for complete native
  cleanup, reuses the process's initialized Android loader, then creates its
  gameplay session bound to LÖVE's EGL/GLES context.
- The Quest payload refreshes only
  `mods/DRAMATIC_SHAPE/lib/VRXR.lua` from the matched embedded transport file.
  ROMs, saves, settings, manifest, and all other mod files remain untouched.
- Dramatic Shape milestone commit: `cc02738` on its local `quest-openxr`
  branch. It has not been pushed.
- Physical result: Yellow reaches its main menu and, after continuing, loads
  into the voxel renderer. This is the first verified end-to-end transition
  from the floating VR launcher into Dramatic Shape gameplay.

### Newly observed rendering defects

- Yellow appears overexposed in voxel rendering.
- Some distant buildings did not load or render.
- These are recorded as gameplay-rendering defects; neither is treated as a
  successful final visual result.

### Current verified state

- Stable, non-flashing, head-relative floating launcher.
- Quest Touch events reach the existing launcher input path.
- Yellow can be launched without touch-screen controls.
- Launcher OpenXR session shuts down and Dramatic Shape takes ownership.
- Yellow main menu displays and gameplay enters voxel rendering.
- No ROM or commercial game asset is packaged or committed.

### Next milestone

Make the launcher focus highlight visibly track controller navigation, then
diagnose voxel exposure and distance/building population independently. Keep
the verified OpenXR handoff unchanged while isolating those rendering issues.

## 2026-08-09 — High-visibility launcher focus candidate

- Root UI behavior: controller directions changed `Kit.focusId`, and Select
  activated the focused control, but the existing 1-2 px white focus outline
  was not perceptible after the launcher was scaled into the Quest quad.
- Added an opt-in post-render focus cursor: a 5 px yellow rounded outline with
  an 8 px black contrast border around the current focus rectangle.
- It appears only after launcher keyboard/controller navigation is armed.
  Touch, mouse, modals, loader overlays, and gameplay paths are unchanged.
- ARM64 `questVrNoRecordDebug` build completed and installed successfully.
- Status: awaiting physical headset verification; do not mark this visual fix
  complete until the user confirms the yellow cursor appears and moves.

## Publication checkpoint

- Prepared the source for the user-owned GitHub repository
  `HimioneGranger/Gen1recomp-Quest-Standalone`.
- Added `QUEST_PROJECT_STATUS.md` as the concise status/documentation index.
- Added `.envignore` and explicitly kept ROMs, generated game data, saves,
  packaged LÖVE payloads, APKs, signing material, environment files, local
  toolchains, and caches outside publication scope.
- A tracked-file and secret-pattern audit found no tracked ROM, save, APK,
  keystore, or environment file. No ROM or generated commercial game data is
  authorized for commit or push.
- Gen1Recomp and Dramatic Shape retain separate Git histories. They are
  published to the standalone repository as `quest-openxr` and
  `dramatic-shape-quest-openxr`, respectively; neither upstream `origin`
  remote is replaced.
- Publication completed to
  `https://github.com/HimioneGranger/Gen1recomp-Quest-Standalone`.
- Remote branch tips at publication:
  - Gen1Recomp `quest-openxr`: `989b1741e024e7001d1e0c432c5e2886b2a6e647`
  - Dramatic Shape `dramatic-shape-quest-openxr`:
    `cc02738aa6e315164a7777a9df69213dd4d191f4`
- The user's initial one-line `main` commit was preserved. `quest-openxr` was
  set as GitHub's default branch so the complete project status and safety
  documentation appear on the repository landing page.

## 2026-08-09 — Controller, launcher presentation, anchoring, and Pokédex

### Gameplay input and automatic VR transition

- Verified in the headset that A/X act as Game Boy A, B/Y act as Game Boy B,
  the left stick walks, and triggers reach the title screen as Start. Yellow
  reaches its main menu and continuing enters voxel gameplay.
- Quest startup now selects Dramatic Shape's STANDARD VR mode automatically
  when the native launcher is active. Existing diorama choices remain
  available; desktop behavior is unchanged.
- Corrected launcher-to-gameplay shutdown to request session exit, wait for
  `XR_SESSION_STATE_STOPPING`, call `xrEndSession`, and then destroy resources.
  The shared EGL display is deliberately not terminated during handoff.

### Focus input oscillation and invisible selector

- Physical symptom: the launcher selector appeared not to move and flashed
  irregularly. Logs proved `Kit.focusId` did move, sometimes many times in a
  second.
- Root input cause: both Touch thumbsticks could alternately win a per-frame
  magnitude comparison. Diagonal gestures also favored X before considering
  the dominant axis.
- Native input now locks to the first stick moved until that stick returns to
  center, emits one event per flick, and resolves diagonals by dominant axis.
- Root visual cause: Android back-buffer capture intermittently returned blank
  or previous frames. A selector drawn into the LÖVE window therefore could
  disappear even while focus state changed correctly.
- Final solution: LÖVE sends the current normalized focus rectangle to the
  native bridge. The OpenXR quad shader draws the selector independently of
  panel capture. User verification: a thin bright-green border is steady and
  moves exactly with controller navigation. This issue is **resolved**.

### Room anchor and Quest recenter

- Re-enabled a room-stationary launcher after a short startup stabilization
  window. The reliable compositor path is retained: the local anchor is
  transformed into VIEW coordinates for quad submission each frame.
- Added handling for `XR_TYPE_EVENT_DATA_REFERENCE_SPACE_CHANGE_PENDING`.
  Holding the Meta button now discards the old anchor and places the launcher
  ahead in the newly centered reference space.
- First recenter test permanently copied a small head roll into the panel.
  Screenshots `20260809-181913` and `20260809-181925` documented the difference.
  Anchoring now extracts yaw only and discards pitch/roll. User verification:
  room anchoring and Meta-button recenter both work; the level correction is
  installed and passed startup after one clean relaunch.

### Pokédex screen alignment

- Replaced the wide mirror/UV approximation with a dedicated 320x288,
  `dpiscale=1` canvas populated from the isolated 160x144 framebuffer region.
  This removed right-eye/unused framebuffer leakage and made menus readable.
- A remaining narrow dark strip at the Pokédex screen's left edge was measured
  from screenshot `20260809-182952`. The device pose and stereo cameras were
  left unchanged; only the display UV was trimmed by 5.5% on the left.
- User verification: **Pokédex screen is fixed**.

### Rendering observations corrected

- The earlier overexposure report was caused by a user-selected Dramatic Shape
  color mode, not the Quest renderer. It is removed from the defect list.
- A distant building appeared missing in one early test. It has not been
  reproduced or cleared and remains an observation requiring map coverage.

### Intermittent startup/loading failure

- Repeated symptom after install, relaunch, or sleep: Quest remains on its
  immersive loading screen while the process and native OpenXR frame loop are
  alive. In affected runs no controller events arrive. A force-stop followed
  by a launcher start usually recovers immediately.
- Separate background/sleep logs previously captured
  `pthread_mutex_lock called on a destroyed mutex` and AudioTrack `SIGABRT`.
  This points to an SDL/OpenAL/activity-lifecycle problem distinct from panel
  rendering.
- This issue is **open** and is now the highest-priority reliability defect.
  It must be profiled by OpenXR session state, Android activity focus, audio
  lifecycle, mod loading, and first voxel-map construction timings.

### Packaging/build incidents during this milestone

- The packaging helper required UTF-8 mode under Python 3.8; without it the
  Yellow metadata manifest failed decoding under Windows cp1252.
- Git for Windows lacked the `zip` utility in this host environment. The old
  `game.love` had already been removed before that failure, so a clean staging
  payload was rebuilt and archived with JDK `jar`, explicitly excluding
  `data/generated` and `assets/generated`. Archive inspection confirmed no
  generated ROM data was included.
- All ARM64 `questVrNoRecordDebug` builds after these corrections completed
  successfully and installed with `adb install -t -r`.

### Milestone commits

- Gen1Recomp `quest-openxr`: `87a0026` — launcher controller debounce, native
  green focus overlay, room anchor/recenter, yaw-only leveling, and updated
  status/build/debug documentation.
- Dramatic Shape `quest-openxr`: `889c9a7` — Quest gameplay controls, automatic
  VR startup, framebuffer-region helpers, and verified Pokédex alignment.

## 2026-08-09 — Initial-load evidence and PotatoVoxel audit

### Quest recording

- Retrieved `/sdcard/Oculus/VideoShots/com.oculus.vrshell-20260809-183916-0.mp4`
  into the untracked local evidence folder `E:\Gen1QuestVR\quest-recordings`.
- Duration: 88.976 seconds; 1920x1080 HEVC at 30 fps with AAC audio.
- A four-second contact sheet shows launcher, Yellow intro, temporary 2D
  overworld, then progressively populated voxel frames. The visible delay is
  therefore partly asynchronous geometry population, not one monolithic
  blocked loader. The recording and extracted frames remain excluded from Git.

### Additional launch-block cause

- A clean ADB-start profile at 18:54:59 never entered the application. Meta's
  system logged `common_system_dialog_app_launch_blocked_controller_required`.
- This is a distinct pre-process failure: an ADB/Monkey launch can be blocked
  when no tracked controller is awake. It explains some apparent immersive
  loading failures but not the SDL/OpenAL suspend crashes or in-game voxel
  population delay.
- Future timing runs must begin with an awake tracked controller or a manual
  library launch; otherwise they do not measure application startup.

### PotatoVoxel checked-source comparison

- Audited `ShaneMcGovernIE/potato_voxel` main at `bbbe877` (v1.3.0). It is a
  fork of Dramatic Shape 1.6.2, declares conflicts with `DRAMATIC_SHAPE`, and
  omits VR/OpenXR. The two mods must not be enabled together.
- The repository contains no software license and states its upstream also
  carries no license. Performance concepts may be independently implemented,
  but source must not be copied into this public project without permission.
- Current Dramatic Shape 1.8.2 already has cooperative coroutine meshing,
  per-frame urgent/idle/covered budgets, neighbor prefetch, live-map eviction,
  Android-reduced forest atmosphere, and shared VR shadow work. Re-adding
  PotatoVoxel's older versions of these would be a regression risk.
- Potato-only candidates not present in current Dramatic Shape:
  persistent fingerprinted disk mesh cache and cache prebuild; indexed mesh
  payloads; 75/50/33% internal render scales; cheaper distant-tree geometry;
  conservative low-power effect presets and extra diagnostics.
- Ranked plan: (1) independently design a cache compatible with the current
  1.8.2 mesher and Android save root; (2) profile Quest eye rendering before
  adding an optional internal render scale; (3) evaluate cheaper distant
  forests only after the unconfirmed missing-building observation is resolved.

## 2026-08-09 — Rejected 75% eye-resolution experiment

- Tested a Quest-only 0.75 internal scale for both voxel eye canvases while
  retaining the runtime-recommended OpenXR swapchain size and using the
  existing blit for upscale. No camera, stereo, input, launcher, or geometry
  behavior was changed.
- On-headset result: initial population felt no faster and possibly slower;
  the image was slightly blurrier and exhibited a visible shimmer artifact.
- Telemetry during population showed severe missed-frame intervals (commonly
  18–49 FPS, later roughly 31–38 FPS) and GPU utilization reaching 98%.
  Captured process memory was about 1,675,848 KB PSS / 1,768,360 KB RSS,
  including 731,564 KB graphics and 358,360 KB native heap. EGL tracking fell
  to 89,928 KB, only about 54 MB below the prior full-resolution capture, while
  GL tracking remained 327,116 KB.
- Conclusion: eye-buffer memory and raw fragment resolution are not the main
  initial-population bottleneck. The visual regression is unacceptable and
  the experiment was fully reverted without a source commit. A restored
  full-resolution ARM64 APK was rebuilt and installed successfully.
- Next profiling should instrument mesh queue length, geometry generation,
  native allocations, GPU upload time, and mesh lifetime/eviction. Persistent
  caching or indexed geometry should be considered only after those counters
  identify the dominant cost.

## 2026-08-09 — Rejected connected-map streaming experiment

- Tested a deliberately narrow Quest-only distance constraint at the mesher's
  existing whole-map boundary. The current map remained complete; connected
  neighbours were requested and retained only within sixteen tiles of their
  world-space rectangles. No chunking or mesher redesign was attempted.
- The first installed APK did not exercise the change because the writable mod
  refresh list carried only `VRXR.lua`, `VR.lua`, and `VRGL.lua`. A corrected
  test temporarily refreshed `ViewBox.lua` and `VoxelScene.lua` as well, and a
  runtime trace verified that the constrained implementation was active.
- User testing found a noticeable performance improvement, confirming that
  connected-map geometry contributes materially to the load, but the reduced
  visible world/draw distance was too dramatic. Preserving the broad view is a
  project requirement and worth the performance cost.
- The experiment was rejected without a source commit. A one-time restoration
  APK rewrote the original wide-view files into the writable mod; Quest logged
  `Dramatic Shape wide-view restoration installed`. It was then replaced by a
  permanent normal APK with the restoration hook removed. Both repositories
  returned exactly to their pre-experiment source state.
- Future performance work must retain the connected scenery. Priorities are
  mesh/vertex representation, GPU upload cost, shadow workload, and measured
  mesh lifetime—not more aggressive world visibility cuts.

## 2026-08-09 — Indexed full-view mesh optimization

- Added temporary per-map Quest diagnostics around the existing cooperative
  FFI mesh builder. The baseline path stored every quad as six complete,
  unindexed vertices even though each face has only four distinct corners.
- Baseline examples: Route 2 full emitted 3,820,770 terrain vertices and took
  about 5,335 ms of wall-clock sliced generation plus 188 ms upload on its
  first recorded build; Viridian Forest emitted 3,750,006 vertices and took
  about 4,197 ms generation plus 93 ms upload.
- Reworked only the FFI/GPU sink to retain four vertices per quad and submit
  the unchanged `1,2,3,1,3,4` triangles through a 32-bit LÖVE vertex map. The
  pure-Lua/table geometry path used by headless tests remains unchanged.
- Indexed Route 2 emitted 2,547,180 vertices plus 3,820,770 indices and took
  about 4,927 ms generation plus 120 ms upload. Indexed Viridian Forest
  emitted 2,500,004 vertices plus 3,750,006 indices and took about 3,811 ms
  generation plus 82 ms upload. This preserved the complete connected view.
- After the user's longer indexed run through repeated transitions to Viridian
  Forest, memory was about 1,340,325 KB PSS / 1,431,148 KB RSS with 633,092 KB
  graphics. The earlier extended unindexed run measured about 1,546,022 KB PSS
  / 1,641,144 KB RSS with 738,252 KB graphics. Cached-map sets were not exactly
  identical, so these are directional rather than laboratory-perfect figures.
- User also found Viridian Forest FX visually unsuitable and disproportionately
  expensive on Quest, and disabled it. Treat Forest FX as a separate
  Quest-default policy issue; it is not part of the indexed-mesh change.

## 2026-08-09 - Forest verification and Indigo Plateau policy

- The user completed a broad indexed-mesh traversal: repeated building
  transitions, Viridian Forest entry, walking throughout the forest, and a
  save created inside Viridian Forest. No indexed-mesh rendering corruption
  was reported, and the user described the resulting gameplay as smooth.
- Forest FX was physically judged both unattractive and disproportionately
  expensive on Quest. Quest now presents `OFF` as the default/fallback rung;
  desktop remains `FULL` and ordinary Android remains `LOW`. Persisted strings
  (`off`/`low`) remain valid, so an explicit existing choice is not overwritten.
- The first launch after installing this payload remained in immersive loading.
  Logs showed a live launcher producing frames and repeatedly rejecting blank
  captures, with no crash and no mod/gameplay OpenXR handoff yet. A clean
  force-stop/relaunch first entered the mod screen abnormally with a visible
  mouse cursor; a user restart recovered normally. Keep this evidence under
  the existing intermittent-startup defect rather than attributing it to the
  not-yet-loaded Forest setting.
- Source inspection found that the expensive scenery adjacent to
  `INDIGO_PLATEAU` is the long outdoor `ROUTE_23` map toward Victory Road, not
  half of a Victory Road cave floor. Literal half-map terrain streaming would
  require a new chunk mesh/cache/invalidation design.
- A narrow Quest-only candidate instead defers only the south-connected Route
  23 neighbour while the player remains in the northern half of Indigo
  Plateau. Entering the southern half requests the existing complete body mesh
  through the established asynchronous builder. No gameplay map loading,
  collision, transitions, other neighbours, or desktop/ordinary Android paths
  change. Awaiting physical verification at Indigo Plateau.
- After installing that candidate, the user loaded the Viridian Forest save,
  walked through Route 2 and back to Viridian City, and reported normal smooth
  operation. The process remained alive with no fatal exception, mesh-build
  failure, integration-install failure, ANR, or memory kill in the captured
  log window. Post-walk memory was 1,262,183 KB PSS / 1,354,564 KB RSS, with
  573,740 KB graphics. This is a useful general regression pass but does not
  exercise the Indigo-specific branch.

## 2026-08-09 - Wilds of Kanto compatibility test

- Audited user-supplied `Wilds.of.Kanto.v1.12.1.zip` before installation. It is
  an API-2 content mod (`overworld_wild_spawns`), contains no native DLL/SO
  payload, declares no conflicts, and explicitly adapts its native
  `SpriteRenderer` entities to Dramatic Shape's voxel/depth/grass path.
- The archive is asset-heavy: 18,199,093 bytes, roughly 14,000 sprite assets,
  SHA-256 `423AAA5F00F08C671826C5F53407A1E23FCD7BCD0CF355BF902A253C58CB0ED0`.
  Copied unchanged to Quest Downloads for installation through the normal mod
  importer; no ROM, save, Dramatic Shape asset, or private app file changed.
- During installation navigation, the native green focus ring moved from Play
  Yellow to the Mods puzzle-piece tab, but A still launched Yellow. Root cause:
  `PanelBridge` called `Kit.navigate` directly, bypassing
  `LauncherView.keypressed`, so the visible focus moved while `_ringArmed`
  remained false and Enter retained its legacy Play shortcut. Quest directions
  initially appeared to require routing through `love.keypressed`; that first
  hypothesis was subsequently rejected by device testing (next bullet).
- The first attempted fix routed directions back through `love.keypressed` and
  immediately regressed native-ring/icon alignment without fixing activation;
  it was rejected and reverted. The corrected candidate preserves the proven
  direct `Kit.navigate` path and changes only launcher confirmation: when
  `QUEST_PANEL_ACTIVE` is true, Enter activates `Kit.focusId` regardless of the
  desktop `_ringArmed` compatibility flag. Awaiting physical verification.
- Live reproduction then proved the focus model and activation were moving
  through real controls (`tab-mods`, `tab-find`, `idx-add`, `idx-close`), while
  native capture simultaneously logged repeated rejected blank frames. The
  native focus rectangle had been updated even when its corresponding panel
  frame was rejected, placing a current ring over a stale launcher image.
  `questxr_capture_panel_gl` now reports acceptance, and `PanelBridge` commits
  the matching focus rectangle only after a successful panel capture. Awaiting
  physical confirmation that image and ring remain synchronized.
- That synchronization candidate made physical ring alignment worse and was
  immediately rejected. The native capture ABI and original focus/capture
  ordering were restored. Future launcher-image work must use a controlled
  frame source rather than coupling focus publication to the current blank
  heuristic.
- The validated one-time installer completed Wilds of Kanto 1.12.1 in about
  24.5 seconds and the mod defaulted enabled. Yellow loaded the Viridian Forest
  save and audio/gameplay continued, but the headset display was black. Wilds
  logged six spawned entities; three immediately failed its Dramatic Shape
  world-billboard contract with `pose() returned nil sprite` and selected the
  spatial-overlay emergency path. No fatal exception was logged. Treat 1.12.1
  as Quest-incompatible pending adapter investigation. A one-time validated
  uninstall rollback was prepared; the original ZIP remains in Downloads and
  on the host, while Dramatic Shape, ROM data, and saves are not removed.
- The rollback payload ran successfully on-device and logged `Wilds of Kanto
  rolled back after black VR output`. The user then confirmed that full 6DoF
  voxel rendering returned. This isolates the flat/head-tracked screen failure
  to the Wilds compatibility test rather than the base Quest OpenXR handoff.
- Wilds 1.12.1 is therefore classified as incompatible with the current Quest
  voxel adapter. Its temporary automatic installer/uninstaller and bundled ZIP
  were removed from the clean APK payload after recovery. The user's original
  ZIP remains untouched in Quest Downloads and on the host for future audit;
  it is not enabled or copied into the app's mod directory.
- A clean ARM64 debug APK was rebuilt after removing the 18.2 MB test archive
  and all automatic Wilds install/rollback logic. The embedded `game.love`
  payload fell from about 16.6 MB compressed to 3.2 MB and was inspected to
  confirm no Wilds archive entry remained. The APK installed as an update with
  app data preserved. Fresh startup logs show the OpenXR session, Touch action
  attachment, live launcher capture, and Dramatic Shape integration install;
  they contain no Wilds installation or rollback event.

## 2026-08-09 - Launcher focus/image synchronization investigation

- After the clean post-Wilds baseline was installed, the launcher still had
  the unresolved focus defect: the native green ring could move while the
  launcher image remained stale, and confirming the apparent Mods icon did
  not reliably open the Mods panel.
- A first focused experiment disabled the native overlay ring and drew a thin
  green cursor directly into LÖVE's captured launcher frame. This guaranteed
  that cursor and controls came from one image, but physical testing showed it
  reintroduced the old flashing highlighter and did not work. The user rejected
  it immediately, and all three Lua changes specific to that experiment were
  reverted before the next build.
- Source tracing confirmed the split-generation failure: Lua published the
  native focus rectangle before native capture decided whether to accept or
  reject the corresponding SDL back buffer. A rejected blank frame therefore
  retained old pixels while displaying a newer focus rectangle.
- The current candidate retains the previously steady native green ring and
  changes the capture ABI so pixels and their computed focus rectangle are
  committed together under `questxr_panel_mutex`, immediately before the same
  panel-generation increment. A rejected frame now changes neither pixels nor
  focus. The ARM64 APK compiled and installed successfully. Physical validation
  of steadiness, alignment, Mods activation, and return navigation is pending;
  this candidate is intentionally uncommitted until that test passes.
- Physical testing reported the same failure with that atomic candidate. Live
  logs nevertheless proved that accepted panel generations continued, focus
  reached `tab-mods`, and confirm event `0x10` reached Lua. The failure is now
  isolated after input/focus resolution: the generic one-frame `_activateId`
  did not execute the focused tab's deferred draw-time closure.
- The next narrow candidate directly calls the existing `_switchTab` action
  when Quest confirms one of the five permanent top-level `tab-*` focus IDs.
  It does not special-case Play or Mods content controls; those continue using
  the shared activation path. Confirm-focus logging was added for the physical
  test. This candidate is unverified and uncommitted.
- The user recorded the failure. The synchronized 26-second Quest capture is
  preserved locally as `debug-media/launcher-mods-232501.mp4` (with the longer
  app capture beside it). It visibly shows the native ring moving across the
  small top tabs while the complete Yellow panel remains unchanged. At
  `23:25:18.448`, logs record `Quest confirm focus=tab-mods`; accepted panel
  generations continue afterward, proving this is not missing controller input
  or a stopped capture thread.
- Direct switching inside `LauncherView.keypressed` still did not change the
  visible panel. The next candidate moves permanent top-tab confirmation to a
  handler installed in `main.lua`, beside the actual live `Importer` reference.
  `PanelBridge` invokes it before the ordinary key fallback and logs both the
  chosen tab and whether the owner handled the event. This avoids transient
  immediate-mode activation and also provides decisive runtime evidence.
- The owner-level device test produced decisive confirmation: logs show
  `Quest confirm focus=tab-mods`, `Quest owner switched tab=mods`, and
  `handled=true`, followed by hundreds of accepted panel generations, while
  the headset still displayed the Yellow panel. Input, focus, and launcher
  model activation are therefore functioning; the displayed pixels are stale.
- Native inspection found the capture bridge queried LÖVE's bound read/draw
  framebuffer IDs but then ignored `old_read` and always blitted from Android
  framebuffer 0. On this GLES path, framebuffer 0 can contain the last
  presented Android surface while LÖVE's current draw is in its own display or
  MSAA framebuffer. The next candidate blits from the framebuffer LÖVE left
  bound and logs the source IDs once. This is unverified and uncommitted.
- Physical testing still showed no visual tab change. Logs again proved the
  owner switched to Mods and handled confirm. The next instrumentation logs
  each launcher tab actually entering `LauncherView.draw` and a sampled pixel
  fingerprint every 30 accepted captures. This will distinguish a draw/model
  reset from stale GL readback or stale native texture upload without another
  speculative capture-source change.
- The evidence build identified the exact mismatch. `LauncherView.draw` logged
  Yellow, native capture logged `readFbo=0 drawFbo=1`, and accepted generations
  1, 30, and 60 all had the identical sampled fingerprint `1dc1c3f0` even as
  focus moved. LÖVE renders the current frame to draw framebuffer 1 while read
  framebuffer 0 retains the stale presented Yellow image. The fix now binds
  LÖVE's saved draw framebuffer as `GL_READ_FRAMEBUFFER` for the blit, then
  restores both bindings. Awaiting physical verification that Mods becomes
  visible and its ring/action remain aligned.
- The first draw-framebuffer build produced a severely incomplete launcher;
  the user captured it and the image is preserved as
  `debug-media/draw-fbo-failure-234442.jpg`. It contains the field background,
  native focus rectangle, one horizontal rule, and clipped footer text, but no
  completed controls. This proves draw framebuffer 1 is live but was copied
  while LÖVE still held most UI work in its renderer batch. `PanelBridge` now
  calls `love.graphics.flushBatch()` immediately before the native blit. The
  live-FBO choice remains; only capture timing changes.
- Physical testing showed the flush did not restore the missing controls. The
  draw-FBO experiment was therefore rejected and reverted to framebuffer 0 to
  restore the last complete launcher presentation. The two pre-present sources
  have now been characterized: FBO 0 is complete but can be stale; FBO 1 is
  current but not the final composed window. The next implementation must
  capture after LÖVE presents, not choose between these two incomplete timing
  points.
- Source inspection located that safe point in LÖVE's OpenGL
  `Graphics::present`: it calls `flushStreamDraws()`, `endPass()`, and binds the
  completed default FBO immediately before `window->swapBuffers()`. The current
  candidate moves fixed-buffer capture there. Lua posts a throttled request and
  matching focus rectangle; native present fulfills it after composition and
  before swap. It retains the 1024x768 double buffers and does not allocate
  full-resolution screenshot objects. Awaiting physical verification.
- Post-present device logs then proved `LauncherView.draw` changed from Yellow
  to Mods while generations 30 through 180 retained fingerprint `1dc1c3f0`.
  Even after LÖVE's wrapper bound its completed default target, raw GLES state
  remained `readFbo=0 drawFbo=1`; the candidate was still selecting stale READ
  FBO 0. Capture now selects saved DRAW FBO 1 at the post-compose hook. This is
  materially different from the rejected draw-time FBO-1 experiment because
  `flushStreamDraws()` and `endPass()` have completed first.
- Physical testing rejected post-compose DRAW FBO 1 as currently blitted: it
  returned the same severely cropped/zoomed presentation as the earlier live
  FBO experiment. The post-present timing made the target complete but did not
  make its dimensions/layout equivalent to the full Android pixel extent used
  by the blit. Capture source was immediately restored to READ FBO 0 so the
  headset is not left on a broken launcher. Any future FBO-1 test must first
  query and use its real viewport/attachment dimensions; do not reuse the
  window's 4128x2208 pixel extent.
- The normal complete FBO-0 presentation was rebuilt and installed; the user
  confirmed the launcher was restored and Mods remained visually stale. The
  next safe diagnostic keeps FBO 0 active while logging FBO 1's GL viewport,
  attachment type, and attachment object ID at the post-compose hook. It does
  not display or blit from FBO 1.
- Safe measurement reported `readFbo=0 drawFbo=1`, viewport 4128x2208, with
  DRAW color attachment type `GL_TEXTURE` (`0x1702`), object 23. The viewport
  therefore matches the Android pixel extent; the next safe probe queries the
  texture attachment's actual level-0 storage dimensions and sample count.
- The level-0 texture-size probe used desktop GL queries unavailable in this
  GLES header set and failed at compile time; no APK was produced or installed.
  Re-examining the partial screenshot identified an unpreserved GL state with a
  closer visual match: `glBlitFramebuffer` obeys `GL_SCISSOR_TEST`, and the
  bridge never disabled it. The next candidate uses post-compose DRAW FBO 1,
  saves/disables the scissor for the full-panel blit, then restores both its
  enable state and box. This also preserves LÖVE's renderer state.
- Physical testing showed the scissor-corrected DRAW-FBO build was still not
  the normal launcher. Scissor clipping was therefore rejected as the primary
  cause, and capture was restored to READ FBO 0 immediately. Do not test DRAW
  FBO 1 again without a different resolved-source design.
- After restoring the normal playable build, the next isolated design avoids
  both window FBOs: Quest launcher drawing targets a fixed 1024x768 LÖVE Canvas,
  flushes it, captures that exact bound Canvas into the existing fixed native
  buffers, then draws the same Canvas to Android. This adds one small persistent
  GPU target, performs no full-resolution screenshot allocation, and makes the
  Android and OpenXR launcher pixels share one explicit source.
- Physical verification confirmed that the explicit Canvas solved the stale
  launcher: the displayed image now changes with navigation and every on-screen
  button is selectable. The first Canvas build appeared vertically inverted
  while the independently rendered native focus ring remained correctly placed.
  The bridge now flips only the bound-Canvas source during the GPU blit, leaving
  focus coordinates unchanged. The user confirmed the resulting launcher is
  upright, its green focus ring is aligned and movable, and all buttons are
  selectable. This is the verified launcher capture/input baseline.

## 2026-08-10 - Dramatic Shape licensing preservation checkpoint

- Local Git history shows an MIT `LICENSE` was added at Dramatic Shape commit
  `e3c13ed` and deleted at `442e9d2`, the same commit that changed the manifest
  from 1.6.1 to 1.6.2. Tag 1.8.2 therefore has no explicit license file.
- To avoid publicly redistributing the legally uncertain post-1.6.1 source,
  the `dramatic-shape-quest-openxr` branch was deleted from the public
  `quest-standalone` remote. The Gen1Recomp `main` and `quest-openxr` branches
  were not changed.
- The complete local Dramatic Shape branch history through `901f739` remains
  available in the working clone and in the verified offline bundle
  `dist/DramaticShapeVoxelMod-quest-openxr-local-backup.bundle`. Experimental
  local ZIPs remain private and must not be published unless licensing is
  clarified. The branch can be restored from the bundle if written permission
  is obtained.

## 2026-08-09 - Recurring immersive-loading stall during launcher testing

- The owner-level launcher build again remained on Meta's immersive loading
  screen immediately after install/start. This recurrence is frequent enough
  to remain a release-blocking issue rather than incidental test friction.
- The captured stalled state is not a crash or Lua startup failure. PID 22674
  remained the top activity; OpenXR context/session creation, `xrBeginSession`,
  first `xrEndFrame`, fixed-buffer capture, and Dramatic Shape deployment all
  completed. Accepted panel generations advanced past 300 while the headset
  continued displaying Meta's loading environment.
- No Quest controller event reached the app during this stalled window. This
  combination points to a session that is nominally running/submitting but
  never compositor-visible/focused. Existing logs record only READY/begin, so
  the next diagnostic must record every OpenXR session-state transition and
  `XrFrameState.shouldRender` before adding a bounded recovery watchdog.
- Rapid debug APK replacement/force-stop may increase reproduction frequency,
  but prior sleep and ordinary relaunch reports show it is not sufficient as
  the sole explanation. Recovery must be valid for normal standalone use.
- A clean force-stop, three-second cooldown, and relaunch reproduced the same
  loading screen while startup and accepted panel generations again advanced.
  The next build logs every session-state transition and `shouldRender` change.
  It also follows the OpenXR frame contract by ending `shouldRender=false`
  frames with zero layers instead of acquiring/submitting the launcher quad.
- The diagnostic build then launched successfully and the user confirmed the
  launcher was visible. Its state trace progressed IDLE (1), READY (2),
  SYNCHRONIZED (3), VISIBLE (4), and FOCUSED (5); `shouldRender` was true and
  accepted panel generations advanced. This is one successful recovery, not
  yet proof that the intermittent loading defect is fixed. Retain the tracing
  and repeat cold-start, rapid-relaunch, and suspend/resume tests before
  promoting the zero-layer handling as the complete solution.
## 2026-08-10 - Dramaless Shape 1.6.4 transition started

- Preserved the physically verified launcher baseline in commit `1bdd56a`,
  then created the isolated `dramaless-1.6.4-integration` branch.
- Pinned the official Dramaless Shape `v1.6.4` release at commit
  `3e7138a31f9d0ca608aba7d0adf9f8ca9b610161`. The release fixes the 1.6.3
  first/third-person softlock and explicitly says not to continue using 1.6.3.
- Dramaless uses mod id `DRAMALESS_SHAPE` and declares hard conflicts with
  `DRAMATIC_SHAPE` and `TERRARIUM`; only Dramaless will be enabled for the
  transition test.
- Narrowed Android startup injection to `VRXR.lua`, `VR.lua`, and `VRGL.lua`
  under `mods/DRAMALESS_SHAPE`. The old six-file injection must not be reused:
  Dramaless 1.6.4 has its own asynchronous `ChunkMesher.lua`, performance
  policy, and `VoxelScene.lua`, and it has no `ForestAtmos.lua`.
- The existing Dramatic Shape working tree and offline bundle remain unchanged
  as a private behavioral reference. No ROM, save, or generated game data was
  added to source or packaging.
- First headset launch reached Yellow's animated title sequence, proving the
  game and Dramaless installation loaded rather than crashing. The screenshot
  showed the green launcher focus ring stranded to the left of the game panel.
  Root cause: `Kit.focusId` remained globally visible after `Importer` handed
  off to `Game`. The transition now explicitly retires launcher focus in
  `bootGame`, and `PanelBridge.focusRect` reports no ring outside the launcher.
- The next headset test removed the ring but Yellow ignored every later title
  press. QuestXR logs proved repeated `0x10` confirm edges reached Lua. The
  bridge had synthesized `love.keypressed("return")` without a matching release,
  so Gen1Recomp's per-source input state accepted the first intro-skip edge and
  treated A as permanently held. Non-launcher native events now synthesize a
  complete press/release tap; `Input:step` preserves its queued edge while
  permitting the next physical press to become a new edge.
- Button taps then advanced through Yellow into the overworld, but neither
  thumbstick could move the player. Menu input needs edges; overworld movement
  reads held direction state. The native launcher session now publishes a
  separate held-direction mask, and `PanelBridge` presses/releases directional
  keys as that mask changes while retaining edge-only navigation in launcher UI.
- Physical verification then confirmed controls work through the title menu and
  in the overworld. The first Dramaless import attempt reported that the ZIP
  could not be opened and the app lost immersive focus. Our generated Git
  archive was structurally valid but wrapped all files under a
  `DRAMALESS_SHAPE/` directory. Replaced it with the publisher's official
  `DRAMALESS_SHAPE_1-6-4-hotfix.zip`, whose `manifest.json` is at archive root
  (SHA-256 `8B073FE0A97DB8EEB10CFA0A3B9F7D52767217780BD251F885326745C838CFB9`).
- The official archive subsequently installed and reached both Yellow's menus
  and overworld, but controls degraded during play. Input traces showed the
  original native arbitration releasing one stick and then allowing the other
  to become the emulated d-pad owner. Small right-stick movements could
  therefore steal movement from the left controller. Launcher and gameplay
  d-pad input are now left-stick-only; the right stick remains available to
  Dramaless for VR camera/look controls.
- The repeated `lib/Diorama.lua is missing` error was not a damaged official
  archive. Startup was overwriting Dramaless 1.6.4's `VR.lua` with the previous
  1.8.2-era Quest conductor, which requires later Diorama/Horde modules absent
  from 1.6.4. The Quest override is now based directly on Dramaless 1.6.4's
  conductor, with only Android support and immersive-launch defaults added;
  the Android `VRXR.lua` and `VRGL.lua` transports remain separate overrides.
  The Dramaless license is retained beside the adapted source.

## 2026-08-10 - Kanto in First Person 1.60.0 added to compatibility scope

- User supplied `kanto-first-person-1_60_0.zip` (mod id `ds_fp_ceiling`,
  SHA-256 `B54B28271918AAAB9A11CED66247898E51CFF5E5F03D3530FF3B81BB3B25AF29`).
  No ROM data is present according to its documentation.
- Source inspection confirms it recognizes `DRAMALESS_SHAPE`, explicitly lists
  1.6.4 as a tested base, loads before the renderer at priority 10, and claims
  compatibility with Wilds of Kanto. It patches Dramaless `VoxelScene.lua`,
  `FirstPerson.lua`, and related private modules through guarded text anchors;
  it must therefore be tested as an adapter, not merged wholesale into the
  Quest renderer.
- The archive was copied unchanged to Quest Downloads for launcher installation
  testing. Its most expensive effects (forest canopy, weather, particles,
  extended terrain, and fast chunk building) require Quest-specific performance
  profiling after basic three-mod startup and VR handoff are verified.
- First Dramaless 1.6.4 headset run successfully entered gameplay VR in
  Viridian, confirming the Android OpenXR handoff. Its stock Pokedex capture
  sampled the full wide Android mirror, shifting the GB image left and leaving
  a dark strip on the right. Restored the verified Quest region-copy path and
  narrow left-padding UV crop in the 1.6.4-based conductor; physical placement
  and stereo eye cameras remain unchanged.
- Headset follow-up found the corrected screen slightly oversized at its left
  edge. Reduced the UV crop from 5.5% to 3.5%; this retains the Android padding
  correction while restoring more of the source image and reducing its scale.
- Further headset evidence isolated battle zoom to the handheld screen, not the
  VR battle camera. The capture had hard-coded the classic 160x144 dimensions,
  while the active WIDE battle UI is 304x144. It now reads `Renderer:uiSize()`
  and captures the exact active UI letterbox; arbitrary UV cropping is removed.
- Menu side bars and continued battle zoom showed that active dimensions alone
  were insufficient: the final compositor uses `Renderer:uiScale()`, with a
  fractional override when `uiFill` is active, rather than always using
  `fitScale()`. The Pokedex crop now mirrors those exact end-frame scale rules.
- User clarified that the black bars exist on the large paused desktop stream
  itself and that the handheld remains zoomed. This proves the fundamental
  source was wrong: `dexScreen` photographed the previous desktop mirror frame,
  which is the left-eye VR view, not the game UI. Replaced framebuffer capture
  with direct composition from `Renderer.canvas` into a fixed 320x288 device
  texture. Classic UI fills it exactly; wide 304x144 battles are aspect-fitted
  with the entire battle visible.
- Headset verification showed the direct `Renderer.canvas` texture completely
  black: that canvas does not retain the finished palette/composite at the VR
  update seam. Restored the prior framebuffer-region path as the playable
  fallback and added change-only logs for framebuffer size, active UI size,
  final UI scale/fill state, and the exact GL source rectangle. Capture errors
  are now surfaced to QuestXR logcat rather than swallowed by `pcall`.
- A full-left-eye experiment was rejected on-headset because it made the normal
  composition substantially worse; it was reverted in `90d42ef`. Screenshots
  of the restored framebuffer-region path show only narrow symmetric side bars
  on the large flat UI panel, while the handheld Load Report was already close.
  The initial 4% handheld trim targeted the wrong surface and was removed.
  `updateQuad` now uses `Renderer:uiSize()` and `Renderer:uiScale()` instead of
  Dramaless's fixed `BattleScene.letterbox()`: this follows stepped-down classic
  UI scale and the 304x144 wide-battle surface without arbitrary zoom.
- Full-device screenshots verified Load Report as correctly framed, dialog as
  correct except for narrow symmetric side columns, and wide battle as readable
  but horizontally forced against the device edges. Pokedex presentation is now
  state-specific: only a top-of-stack `TextBox` trims 4% per side; Load Report
  remains untouched; 304x144 battle capture is aspect-fitted into the 320x288
  device texture with dark top/bottom padding rather than stretched or cropped.
- Product decision: the Pokedex screen is contextual UI rather than a permanent
  exploration prop. The clean-eye mirror experiments (`ea5b8a7`, `69d12e9`)
  were reverted after showing inversion, missing 2D UI, and extra GPU/memory
  cost. The physical device remains in the tracked hand, but its screen lights
  only while `uiShowing()` is true (menus, dialog/text, battle UI, and
  transitions). Ordinary exploration draws the dark-screen prop and performs
  no handheld capture.
- Clarification: battle must show the same continuously updating composed mirror
  feed as menus/dialog, not an aspect-fitted intermediate image. Removed the
  two-canvas presentation pass that raised UI-active canvas switches to 16-18
  and could look static. Lit states now blit the framebuffer region directly
  into the device texture every frame; a 3% symmetric source trim removes the
  remaining inner black bezels. Exploration still keeps the physical device
  with its screen dark and performs no capture.
- The restored live battle screenshot proved the feed updates, but its normal
  160x144 source crop cuts the staged player's and opponent's sprites at the
  left/right edges. Battle now widens the centred live source rectangle by 50%
  (clamped to the framebuffer), with no bezel trim, effectively zooming out the
  fixed battle feed. Dialog/menu capture retains its verified crop unchanged.

## 2026-08-10 - Kanto First Person Quest performance baseline

- User reports that Kanto in First Person provides the desired visual direction
  but is too expensive on Quest. A repeatable Pallet-to-Viridian walk will be
  used as the baseline before changing visual features.
- Added a Quest-only ten-second sampler to the Dramaless VR conductor. Reports
  include average/p50/p95/p99/worst frame interval, missed 72 Hz counts,
  >20 ms and >33.3 ms counts, current draw/canvas/shader switches, and texture
  memory. This is intentionally light enough to leave enabled during video.
- Planned ablations keep route, save, view direction, and movement comparable.
  Test the stock visual set first, then likely high-cost groups independently:
  FAST CHUNKS, particles/weather, extended terrain and mountain/tree geometry,
  clouds/sky, and forest canopy/vines/shafts. Preserve interiors, horizon art,
  and first-person presentation unless measurements specifically implicate them.
- Deferred follow-up: assess an attributed MIT-licensed Quest performance fork
  of Wilds of Kanto (`YoDrehDenSwagAuf/overworld-spawn-mod`). Preserve its MIT
  notice and audit/exclude separately licensed third-party sprites and assets.
  Keep it isolated from the current Dramaless/Pokedex performance pass.
- Combined indexed-terrain/Pokedex candidate headset validation used a
  371-second Pallet-to-Viridian route plus interiors, battle, forest scenery,
  settings, and extra voxel viewing angles. Sampled video frames showed no
  indexed-mesh corruption or missing terrain. The final retained PERF10 windows
  averaged 18.28 ms and 19.10 ms with 352-372 draws and 257.1 MB of textures;
  all sampled frames remained outside the 13.89 ms 72 Hz budget. Indexed terrain
  is retained, but Kanto First Person draw/feature cost needs the next isolated
  optimization pass. Preserve the full PERF10 stream before the next route.
- Added bounded persistent PERF10 capture to the Quest Dramaless conductor.
  Every ten-second window is still emitted to logcat and is now appended to
  `quest_perf10.log` in the LÖVE save directory with a UTC session marker,
  session-relative window number, and uptime. At 1 MiB the prior file rotates
  to `quest_perf10.previous.log`. This preserves complete routes across Android
  logcat rollover and app shutdown without changing rendering or mod options.
- ARM64 `questVrNoRecordDebug` build succeeded and installed as an update. The
  embedded `src/quest/dramaless/VR.lua` was extracted back from the signed APK
  and verified to contain the persistent logger. APK SHA-256:
  `E541D419A559A3EF25D4E429EEF22353EA9C0D88CE26CEB3B3BE5557E2F8290F`.
  Saves, imported ROM content, and separately installed mods were preserved.
- First verification exposed two packaging/retrieval details before a new route
  was accepted. The standard Android payload list does not include Quest's
  external `lib/VRXR.lua` and `lib/VRGL.lua`; recreating `game.love` without
  explicitly restoring them left the old installed Dramaless conductor active.
  Both verified Quest-native transports were restored to the payload, after
  which logcat confirmed `PERF10 persistent log: quest_perf10.log` from the new
  conductor. The file is created under Android app-specific external storage,
  where scoped-storage SELinux rules prevent direct ADB reads despite matching
  UID ownership. On each new gameplay session the conductor now replays the
  bounded saved history between `PERF_HISTORY_BEGIN/END` markers into QuestXR
  logcat. Rotation was tightened to 256 KiB, retaining many hours of ten-second
  samples while keeping replay safely bounded. No broad storage permission was
  added.

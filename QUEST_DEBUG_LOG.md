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
- Completed the first fully persistent controlled baseline. The 133.978-second
  video covers Pallet Town, Route 1, a battle, Viridian, the northward
  gate/loading seam, entry into Viridian Forest, and multiple canopy angles.
  Settled forest windows averaged
  24.42-28.04 ms with 340-392 draws and 273.0 MB textures; battle/load windows
  averaged 35.28-78.98 ms and contained worst frames up to 903.37 ms. User
  clarification: the earlier bad forest-FX report applied to Dramatic Shape,
  not the current Dramaless + Kanto First Person stack; current forest
  performance feels acceptable. Cancel the forest-effects ablation and retain
  those visuals. Transition-time mesh queue/build/upload/cache instrumentation
  is the next active target.
## 2026-08-10 - Transition mesh trace and Quest pacing candidate

- Added source-guarded `MESHJOB` queue/start/finish diagnostics to the
  Dramaless `ChunkMesher` adapter. The first Pallet load proved that the
  current map was followed immediately by costly speculative neighbours:
  `PALLET_TOWN full` 1581 ms, `ROUTE_21 body` 1833 ms, `ROUTE_1 body`
  993 ms, `CINNABAR_ISLAND body` 2582 ms, and `VIRIDIAN_CITY body` 3218 ms.
- A controlled Pallet -> Red's House -> Pallet -> Route 1 run isolated the
  transition. `REDS_HOUSE_1F full` needed only 113 ms. `ROUTE_1 full` needed
  2140 ms, then optional `PALLET_TOWN body`, `ROUTE_22 body`, and
  `ROUTE_2 body` consumed another 8940 ms. During that optional burst the
  ten-second performance window averaged 134.50 ms/frame, with an 839.80 ms
  worst frame. This identifies eager neighbour mesh construction as a major
  transition hitch; it does not implicate current Dramaless forest visuals.
- Added a Quest-only pacing candidate without removing maps, shortening draw
  distance, or changing mesh results: urgent/current-map slice 12 -> 6 ms,
  optional-neighbour slice 5 -> 1 ms, and fade/covered slice 30 -> 10 ms.
  The exact-source guard refuses unknown Dramaless layouts.
- Reproduced the recurring Meta loading-screen failure after controllers were
  reactivated. Logs showed `RequiresControllersLaunchInterceptor` followed by
  overlapping immersive/single-instance tasks. A normal force-stop relaunch
  reused the bad task, while a cold clear-task component launch recovered the
  launcher without clearing application data. This is a recovery procedure,
  not yet a permanent lifecycle fix.

### Pacing candidate rejected

- Physical validation reported no perceptible transition improvement. The
  attempted comparison reused already-cached Pallet/Route meshes, so it could
  not establish a favorable timing result; the nominally smaller budgets also
  left the initial job resume counts effectively unchanged, consistent with
  coarse yield points inside mesh construction.
- The same run regressed the Pokédex feed to a black box and unexpectedly began
  at 2x game speed. No Lua, shader, canvas, or OpenGL error was logged. Repeated
  `start=true` gameplay input events were recorded and are a possible cause of
  the setting change, but causation is not established.
- Rejected the pacing constants and added a one-time source-guarded migration
  that restores the installed mesher to the prior 12/5/30 ms values. Preserve
  the indexed-mesh optimization and diagnostics while investigating a design
  that defers or cancels irrelevant neighbour jobs at the queue-policy level.

## 2026-08-10 - First/third-person neighbour streaming candidate

- Scope decision: Quest optimization now targets the intended first- and
  third-person experience. Top-down voxel views may later need a different
  streaming policy because they can expose a much wider area at once.
- Added a Quest-only, exact-source-guarded `VoxelScene` adapter. It preserves
  the complete neighbor/live set and all rendering behavior, but requests an
  uncached neighbor body only when that map's world-space bounds come within
  384 pixels (24 movement tiles) of the player. Already cached meshes remain
  drawable. The current map is still always requested urgently.
- This is intended to admit directly connected Route 1 and Route 21 while the
  player is in Pallet, but defer Viridian City and Cinnabar Island until the
  player approaches through their connecting routes. `STREAM` admit/defer
  transitions are logged once per state change for physical verification.
- Candidate status: source complete; APK build and headset validation pending.

### First streaming hardware result and radius revision

- Pallet correctly admitted Route 21 and Route 1 while deferring Cinnabar and
  Viridian. Initial queued maps fell from five to three, mesh work from about
  10.2 to 4.5 seconds, texture residency from 202.5 to 78.4 MB, and settled
  frame averages from roughly 25-35 to 18.3-18.4 ms. The retained Route/Kanto
  First Person scenery still showed the road, trainers, mountains, and skyline.
- The Pallet -> Route 1 -> Viridian -> Route 23 run proved admission followed
  player distance, but exposed obvious ground pop-in on transitions, especially
  Route 23. Route 23 was admitted only about 1.2 seconds before entry and its
  body needed 6.74 seconds; other large bodies ranged from 8.16 to 13.69
  seconds when competing with urgent current-map work.
- Revised the preload radius from 384 to 640 pixels (24 to 40 movement tiles),
  retaining the performance-oriented policy while giving large maps roughly
  fourteen additional seconds at observed walking speed. The adapter migrates
  the already-patched installed Dramaless source exactly once.

### Distance streaming rejected after 640-pixel validation

- Hardware validation found Viridian and Route 23 pop-in improved at 640, but
  Route 2 ground pop-in worsened and traversal stutter became nearly
  continuous. The user separately observed that Route 2's left-side tree
  pop-in improved, confirming earlier admission benefits that scenery even
  though the map as a whole did not arrive coherently.
  Logs confirmed the larger radius merely moved expensive construction into
  active walking: Viridian body 7.03 s, Route 22 body 5.00 s, Route 2 body
  17.54 s, Viridian full 7.87 s, and Route 23 body 4.02 s after waiting 7.06 s
  behind earlier work. Ten-second frame averages remained about 39-59 ms.
- Conclusion: one distance threshold cannot provide both early complete ground
  and smooth traversal while meshes are rebuilt every process. Smaller radii
  visibly pop; larger radii continuously contend with rendering.
- Rejected distance streaming and converted its source-guarded adapter into a
  one-time rollback that restores Dramaless's standard neighbor request loop.
  Next design target is an independently implemented persistent indexed-mesh
  cache, so construction cost is paid once rather than rescheduled.

## 2026-08-10 - Persistent indexed terrain cache rejected

- Milestone `8f2bf13` added a versioned raw indexed-buffer cache and passed its
  initial cold/warm integrity checks. Five cold misses stored successfully and
  the warm run hit all five entries. Warm mesh-job time changed from 1858.55 to
  1047.91 ms for Pallet, 1515.06 to 996.58 ms for Route 1, 2343.61 to 328.43 ms
  for Route 21, 7047.37 to 2602.40 ms for Viridian, and 1310.76 to 856.78 ms for
  Cinnabar. GPU upload of Viridian's 1,268,780 vertices remained expensive.
- Hardware visual inspection then found that Pallet Town's tree trunks were
  absent on the warm run. A cache hit bypassed the complete Dramaless geometry
  pass; that pass has side effects beyond returning terrain/water buffers, so
  replaying only those buffers is not semantically complete for Kanto First
  Person scenery.
- Reverted milestone `8f2bf13` in `e80b609`. Do not restore this whole-pass
  cache unless every side output/object hook is identified and either replayed
  or separated from the terrain builder. The known-complete indexed mesher and
  standard neighbor policy remain the playable baseline.
- Repacked the reverted source, explicitly restored `lib/VRXR.lua` and
  `lib/VRGL.lua`, validated the built APK contained neither `MeshCache.lua` nor
  generated ROM data, and installed it as an update without clearing app data.
  ARM64 `questVrNoRecordDebug` build passed; installed APK SHA-256:
  `24983D47562BE203480C7C8F3D0899C53E6E7C0CC1D10EC8F2FF348E43587A0E`.
- The automated restart used for the warm test also reproduced the existing
  immersive loading-screen/input race: OpenXR rendered zero game draws while
  controller profiles repeatedly disconnected/reconnected. Restarting while a
  controller was actively tracked restored the launcher. This was independent
  of the missing-trunk cache regression.

### Cache rollback migration correction

- The first reverted APK removed the cache adapter from `game.love`, but the
  installed Dramaless mesher had already been rewritten in writable mod state.
  Its indexed/traced marker caused the older adapter to accept that stale mixed
  source, leaving the cache-bypassing geometry path active and disrupting the
  Dramaless/VR gameplay pipeline.
- Added an exact, one-time source migration to `IndexMesherPatch.lua`. When the
  rejected cache marker is present it removes the payload exposure, cache
  import, and cache-first job block before accepting the indexed/traced mesher.
  Device startup confirmed: `Dramaless indexed and traced; rejected persistent
  cache removed mesher ready` and the Quest OpenXR transport remained installed.
- Corrected ARM64 APK SHA-256:
  `7CD12423D2339750F4704A88BBBB45D552B53B849220AA69A274344DF342DAC4`.
  Hardware validation passed: gameplay entered VR voxel mode, Pallet tree trunks
  returned, Quest controls worked, and Cinnabar loaded. Route 1 was briefly
  choppy when its standard uncached neighboring meshes rebuilt; returning to
  Pallet recovered. This is the retained completeness-first baseline.

## 2026-08-10 - Route 2 neighbor priority candidate

- Hardware report tied aggressive north Route 2 tree pop-in to the westbound
  Indigo Plateau road. Trace confirmed the Route 1 neighbor queue built
  `PALLET_TOWN body`, then costly `ROUTE_22 body` (4530.67 ms), and only then
  `ROUTE_2 body`. Route 2 waited 8347.40 ms and finished 12609.24 ms after its
  request, matching the visible late tree arrival.
- Added a narrow, source-guarded priority request: when `ROUTE_2` is present in
  the neighbor set it is requested once immediately before the unchanged
  standard loop. Mesher job deduplication keeps one body job; every neighbor is
  still requested and retained, with no draw-distance or geometry change.
- ARM64 candidate installed with APK SHA-256
  `8695AFE4EB886C717AD0E77DDA0BD701BE2D264B9610F90369EA7A8E0CF2E928`.
  Startup reached the launcher even after the controllers had slept.
- Controlled Pallet -> Route 1 -> Viridian -> immediate Route 2 test passed.
  User assessment: time-to-pop was only slightly better, but the slowdown during
  pop-in was noticeably better. Trace verified `ROUTE_2 body` moved ahead of
  Pallet/Route 22: wait fell from 8347.40 to 3477.21 ms and total queue-to-finish
  fell from 12609.24 to 8183.01 ms, making it available about 4.43 seconds
  earlier. Remaining costs are `ROUTE_1 full` (3253.46 ms), `ROUTE_2 body`
  (4705.80 ms), and on entry `ROUTE_2 full` (11254.10 ms).
- Follow-up clarified that the most conspicuous pop-in is specifically the row
  of trees on the left beside the Victory Road/Route 22 boundary. Those trees
  appeared slightly faster with this candidate, confirming Route 2 priority
  materially gates that visible boundary even though it looks westbound.
- Retain the priority correction. The next optimization must reduce Route 2's
  own complete-mesh construction/draw cost without bypassing Kanto First Person
  object side effects or reintroducing terrain/tree pop from distance culling.

## 2026-08-10 - Route 2 geometry phase profile

- Added diagnostics-only phase markers to the exact-source indexed mesher;
  rendering, queue order, geometry, budgets, and draw distance were unchanged.
  First split showed Route 2 body at 9014.73 ms: 2207.20 ms auxiliary object
  preparation, 6671.57 ms geometry, and 135.57 ms GPU upload. Full was
  12094.20 ms: 11867.84 ms geometry and 226.10 ms upload. Shader/GPU upload is
  therefore not the primary loading bottleneck.
- Finer hardware trace separated `runGeometry`: Route 2 body spent 82.25 ms in
  tiles/structures, 79.52 ms in ordinary object quads, and 2532.60 ms expanding
  round-tree stamps. Full spent 190.98 ms in tiles, 182.70 ms in objects, and
  13174.88 ms in tree stamps. The map contains 16,924 object quads and 862
  repeated round-tree stamps; stamps consumed about 94% of body geometry and
  97% of full geometry in this run.
- BuildBudget already samples its cheap `tick()` clock check once per 32 calls.
  Calling it less often would not remove the repeated tree expansion and risks
  longer visible frame stalls, so that shortcut was rejected without a build.
- User accepted a longer load in exchange for fewer runtime pop-ins, provided a
  loading screen and progress bar are shown. Required design is save-aware, not
  Pallet-specific: after the selected save constructs its overworld state, read
  its actual map/player position, build the current full mesh first, then its
  live neighbors in distance order, and derive progress from required completed
  jobs. A Route 2/forest/interior save must automatically prepare its own set.
  Call this `Preparing VR world`, not shader compilation.
## 2026-08-10 — Location-aware startup preload and Route 2 full-mesh target

- Replaced the unreadably small preload diagnostic with a scalable classic
  handheld-style loading card: four-tone LCD palette, large nearest-filtered
  title/map text, double frame, and a chunky segmented progress meter. It is
  drawn entirely in code and adds no copyrighted or external artwork.
- Added a ROM-free `Preparing VR world` handoff before gameplay OpenXR starts.
  It derives a nearest-first outdoor corridor from the selected save instead
  of assuming a fixed starting town, with four connection hops, a 12-map cap,
  a 90-second safety timeout, and visible progress.
- Pallet test completed 11 required meshes in 19.01 seconds: Pallet full plus
  Route 1, Route 21, Viridian, Cinnabar, Route 2, Route 22, Route 20, Pewter,
  Route 23, and Route 19 bodies. The user reported less-janky initial walking
  and slightly smoother transitions.
- Route 2 trees still popped in. Logs identified the exact remaining cause:
  its preloaded body mesh was ready, but promotion to the full border-ring mesh
  began only on entry and took 11.74 seconds. During that interval the runtime
  fell well below frame rate and the user saw slight continuous stutter.
- Next candidate treats Route 2 as a measured exception: whenever it is in the
  location-derived startup corridor or normal two-hop neighbourhood, request
  its full mesh early with masks computed from Route 2's own connection graph.
  Other regional maps remain body-only to bound time and memory.
- End-of-session safety snapshot: headset battery 7%, weak 5 V / 0.9 A USB
  charging, battery 43 C, XR runtime about 49 C. The app was force-stopped so
  the headset could cool and charge.

## 2026-08-10 - Saffron save-aware preload verification

- Imported the separate 100% test save and loaded into Saffron City. The
  location-aware planner correctly selected Saffron plus Route 5, Route 6,
  Route 7, Route 8, Cerulean, Vermilion, Celadon, Lavender, Route 24, Route 4,
  and Route 9. Route 2 was correctly absent because it was not near this save.
- All 12 required jobs completed in 36.52 seconds. Saffron's full mesh took
  16.12 seconds and Celadon's body mesh was the largest warm job at 7.98
  seconds. Moving out of and back into Saffron provided an additional live
  transition sample without breaking the world load.
- The user reported that the `PREPARING VR WORLD` title looked doubled. The
  loading card intentionally drew a two-pixel title shadow, so that decorative
  duplicate was removed; the title is now rendered once for clean VR legibility.
- The first incremental APK rebuild silently retained the old embedded game
  archive despite the corrected source. Inspection inside the APK exposed two
  title draws, so a clean rebuild was performed and the packaged archive was
  checked before installation. The corrected APK contains one title draw and
  no shadow expression; headset testing confirmed the loading title is clean.
- The lower `LOADING MAP DATA` caption remained too thin at headset distance.
  It now uses a larger medium-weight raster size and remains a single draw, so
  legibility improves without reintroducing offset ghosting.
- Headset verification accepted the enlarged status caption as much better;
  the classic loading-card presentation is now considered complete.

## 2026-08-10 - Saffron to Celadon performance sample

- The user walked west from Saffron through Route 7 into Celadon and reported
  slight stuttering. Route 7 full geometry completed in 2.62 seconds and its
  gate in 34 ms. On first Celadon entry, the startup preload's body-only warm
  mesh was insufficient: `CELADON_CITY full` queued urgently and took 8.71
  seconds across 160 resumptions. The associated ten-second window averaged
  57.48 ms, with a 563.57 ms worst frame.
- After the build completed, Celadon generally ran at 35-40 ms per frame
  (roughly 25-29 FPS) with recurring approximately 90-120 ms tail spikes.
  Texture accounting stabilized near 238.3 MB, but Android reported about
  2.01 GB total PSS: approximately 769 MB Graphics, 285 MB native heap, and
  850 MB Unknown. No app crash or out-of-memory exception occurred.
- At capture time the headset was USB-powered but only 12% charged, and the
  battery sensor reported 55.0 C. The app was force-stopped for a mandatory
  cool/charge break. Do not continue hardware profiling until temperature and
  charge recover.
- Next design question: selectively promote a small number of expensive major
  cities in the save-aware corridor from body-only to full preload, while
  reducing or releasing other warm meshes so the existing memory pressure is
  not made worse. Celadon provides the first measured candidate.

## 2026-08-10 - Bounded major-location and interior preload candidate

- Checked Dramaless 1.6.4's actual `ChunkMesher` cache lifecycle before
  changing policy. It retains only the current and previous live map sets and
  releases GPU meshes plus Structures analysis outside them. A destination
  city temporarily needs both its body variant (while visible as neighbour
  scenery) and full variant (when current), explaining the measured Celadon
  overlap.
- Startup now selects at most one nearby major fly destination for a full
  preload, ranked by checked map area. The cap is one; it does not bake every
  Saffron-adjacent city. The preload log records the selected `full=` id so the
  Celadon choice and timing can be verified on hardware.
- Seamless travel starts one closest major destination's full mesh per source
  map, excluding the map just left. This applies the same policy to all eleven
  vanilla fly towns/Indigo Plateau without hard-coding a playthrough route.
- Warp events now prepare exactly one resolved destination during the covered
  transition and temporarily pin only source plus destination. Because this is
  derived from the engine's checked warp destination, it covers ordinary
  interiors, Silph floors, caves, ships, and mod-authored interiors without an
  incomplete name list.
- Added a source-guarded `ChunkMesher.dropBody(mapId)` adapter. Once a promoted
  destination's full mesh is current, it releases only the redundant body and
  body-water GPU slots; the full mesh and shared analysis remain. This bounds
  the temporary dual-variant cost and leaves normal current/previous-live
  eviction authoritative.
- This is a candidate pending cooled-headset validation. Required evidence is
  Saffron startup selecting Celadon, Celadon entry avoiding the 8.71-second
  urgent build, body-release diagnostics, memory below/equal to the prior
  roughly 2.01 GB peak, and working enter/exit transitions for a representative
  interior.

## 2026-08-11 - Pokédex selector visibility and accepted framing

- A verified full Quest payload was used as the packaging base so the earlier
  incomplete-intermediate-APK regression could not recur. No ROM or generated
  game data was packaged.
- Reducing the classic menu/dialog source crop from 3.5% to 1% restored the
  left-edge selector arrow. A headset screenshot then confirmed that applying
  that crop only on the left displaced the feed toward the right.
- The classic source now uses a symmetric 1% horizontal crop. Battles retain
  their uncropped path; loading/report rendering and physical Pokédex placement
  are unchanged.
- Device result: selector arrow visible and framing accepted by the user as
  sufficient. Any additional Pokédex sizing/alignment work is now low-priority
  polish unless required UI becomes hidden.

## 2026-08-10/11 - Side Door integration and Quest modal-input defect

- The standalone `Dramaless Side Door Fix` package was transferred to the
  headset and appeared in the launcher. Its experimental-mod confirmation
  dialog exposed a shared Quest launcher defect: the green focus border could
  highlight `Enable` or `Update`, but A/Trigger did not activate that focused
  modal button. The visual focus and the launcher's action target were not
  equivalent inside this modal path.
- Checked source identified the cause in `RomImporter:keypressed`: the modal
  guard returned before `LauncherView.keypressed` could route Quest's native
  focus/confirm input. A narrow Quest-only candidate now forwards input through
  the existing launcher focus handler before the guard. It remains uncommitted
  and is **not present in the currently installed APK** pending regression
  coverage for Enable, Update, release notes, details, Escape/Back, and normal
  desktop pointer/keyboard behavior.
- The user was able to enable Side Door Fix through a workaround, but three
  headset screenshots showed that the first placement candidate did not add
  usable doors at the recorded locations. Development and validation of that
  standalone mod have been moved to the separate Side Door Fix task/repository;
  this main project retains only the launcher-integration finding.

## 2026-08-10/11 - Incomplete intermediate APK regression and recovery

- During an attempt to package the Quest modal candidate, Gradle's canonical
  `build/outputs` APK remained the previous verified 55.6 MB file while a new
  roughly 22.7 MB APK appeared only under `build/intermediates/apk`. That
  intermediate package was mistakenly treated as installable output.
- Installing the intermediate APK regressed the Pokédex/load-report framing:
  report text became small and compressed near the upper-left because its
  embedded `game.love` came from an older/incomplete Quest payload. The APK's
  SHA-256 was
  `62ED0B956F12EEAF1C89E17CBA806AA25ADF745A6C2F6BD18A1A6B9FC78F62A1`.
- Recovery was immediate: reinstalled the last verified canonical output APK
  (SHA-256
  `F9FBFB2A9F8011F338D44AB05E08B219EADBE383A5597451877C0B54E123C8C3`).
  The launcher, destination-aware preload, indexed Dramaless renderer, and
  previously approved Pokédex/load-report presentation returned.
- Subsequent Pokédex builds were made by extracting that verified APK's full
  `game.love`, replacing only `src/quest/dramaless/VR.lua`, checking that no
  `data/generated` or `assets/generated` entries existed, rebuilding through
  the canonical Gradle output task, inspecting the packaged Lua entry, and
  only then installing. Do not install APKs from `build/intermediates`.
- Current installed/output APK after accepted centering has SHA-256
  `96D2B7C0218D34B36A07DAA31EF69AA3EC3675F261B3C0057A087042C3CE0F56`
  and is 55,885,323 bytes. Install succeeded without replacing user saves or
  writable installed mods.

## 2026-08-11 - Quest mod-modal regression coverage

- Added a headless launcher seam test for the Quest-only modal input bridge.
  It exercises confirm and directional input for experimental confirmation,
  version selection, release notes, and mod details; checks the existing
  Escape/Back close precedence; and proves desktop unarmed Enter remains
  unchanged.
- Result: 20/20 checks passed using the local LÖVE runtime. The source change
  remains limited to forwarding Quest focus keys through the existing
  `LauncherView.keypressed` handler before `RomImporter`'s modal guard returns.
- Next checkpoint is canonical full-payload packaging and physical validation
  of Enable, Update (when available), Back, and ordinary launcher navigation.

## 2026-08-11 - Quest mod-modal device verification

- Built the canonical `questVrNoRecordDebug` output from the verified full
  payload and inspected its embedded archive before installation. The Quest
  modal bridge and accepted symmetric Pokédex crop were present; generated ROM
  data was absent. Candidate SHA-256:
  `D08A72D213F424EE89C68C50018CE385FA0CBF85A548DB71376C890B0C6846D2`.
- Installation and immersive relaunch succeeded. Physical headset testing
  confirmed that the green highlighter moves within the mod dialog and the
  highlighted control now performs the corresponding action. The functional
  experimental-mod dialog blocker is resolved.
- Visual cleanup of the native highlighter remains desirable but does not
  prevent use. It is ranked as low-priority polish above further Pokédex sizing.

## 2026-08-11 - Wild Skies first-stage compatibility sample

- Tested the intended visual baseline (Dramaless Shape, Kanto First Person,
  and Wilds of Kanto) with Wild Skies added. Dramatic Sky Ride, HGSS Sprites,
  Crystal 251, and Side Door Fix were excluded so Wild Skies was the only new
  variable. Route: Saffron -> Route 7 -> Celadon -> Celadon Mart 1F -> Celadon.
- User observed no unusual performance or visual problems. App frame-count
  telemetry yielded roughly 29.5-31.3 rendered frames/second over successive
  500/1000-frame intervals, consistent with or slightly above the earlier
  approximately 25-29 FPS Celadon sample rather than a new regression.
- Post-route memory was 1,923,876 KB total PSS (about 1.92 GB), including
  717,528 KB Graphics. The previous Celadon sample was about 2.01 GB PSS.
  These are single samples, not proof that Wild Skies reduces memory, but they
  show no new memory-pressure step. No crash, ANR, OOM, or trim-memory event
  was logged.
- Battery moved from 77%/38 C before the run to 74%/43 C afterward while USB
  powered. This remained below the earlier 55 C stress sample.
- One nonfatal Wilds of Kanto occupancy-conflict warning appeared on Route 7;
  wild spawning and map travel continued. Treat separately from Wild Skies.
- Result: Wild Skies passes initial Quest compatibility/performance testing.
  Next controlled variable is Dramatic Sky Ride added to this same stack.

## 2026-08-11 - Dramatic Sky Ride deferred on Quest

- Added Dramatic Sky Ride 0.1.5 to the accepted Wild Skies stack and repeated
  Saffron -> Route 7 -> Celadon -> Celadon Mart 1F -> Celadon. Mod diagnostics
  confirmed it was enabled and recorded progression discoveries for every map.
- Frame-count telemetry was approximately 31.3 FPS initially, 27.6 FPS through
  the next interval, and 26.5 FPS across the Celadon-heavy interval. The
  equivalent Wild Skies-only intervals were approximately 31.3, 29.5, and
  30.5 FPS, indicating a modest but measurable cost in the relevant scene.
- Post-route memory was 1,940,874 KB total PSS and 733,712 KB Graphics: about
  17 MB total and 16 MB graphics above the preceding Wild Skies-only sample.
  Temperature moved from 42 C to 45 C. No crash, ANR, OOM, or mod error was
  observed.
- The 3D flight experience does work in VR and the user flew around the map.
  Vertical control is inaccessible: DSR polls standard LÖVE `triggerright` /
  `triggerleft` axes for climb/descent, while the Quest OpenXR bridge currently
  maps either trigger to Start, opening the game menu instead. Enabling both
  `MANUAL ALTITUDE` and `CAMERA ALTITUDE` and using right-stick vertical look
  also produced no altitude change; DSR observes the flat voxel camera pitch,
  not the Quest head-pose path used by the current VR integration.
- With measurable cost and no usable vertical flight control, Dramatic Sky
  Ride is disabled/deferred. Revisit with a generic raw OpenXR trigger-state
  bridge (without hard-coding this mod) and, if desired, a VR-head-pitch input
  surface. Then repeat the same performance sample before deciding whether the
  immersive flight benefit justifies the approximately four-FPS Celadon cost.

## 2026-08-11 - Crystal 251 and Wild Skies Quest compatibility run

- Copied only the user's legally supplied ROM files from `D:\baseroms` to the
  app-private external `baseroms` directory on the Quest. No ROM content was
  added to the APK or Git. Crystal 251 automatically imported the supplied
  Crystal Rev 1 ROM through the existing import workflow.
- The first Crystal attempt remained flat because Dramaless Shape was installed
  but disabled. Re-enabling Dramaless restored the voxel/VR pipeline; this was
  configuration state, not a Crystal incompatibility.
- The initial flat attempt also had one B-button failure. Android input events
  still reached the Quest bridge, and a force-stop/relaunch recovered it. In
  the clean retry, all controls including B remained functional for the entire
  Saffron City -> Route 8 -> Lavender Town traversal.
- The enabled stack was Dramaless Shape 1.6.4, Kanto First Person, Wilds of
  Kanto, Wild Skies 1.6.3, and Crystal 251 0.10.1. Voxel rendering remained
  active and Wild Skies visibly rendered Generation II flyers. Logs identified
  Natu, Yanma, and Hoppip, plus Pidgey from Generation I.
- One generic Generation I flyer was observed. Wild Skies logged no missing
  flyer sprite warning, so the sample does not identify it conclusively beyond
  the repeated Pidgey spawns. Separately, Wilds of Kanto explicitly lacked
  pre-registered overworld sprites for Murkrow and Houndour and used its
  fallback IDs. Keep those ground-spawn fallbacks separate from Wild Skies.
- Post-route memory was 2,014,242 KB total PSS (about 2.01 GB), including
  766,476 KB Graphics. Battery was 45% and 47 C. No crash, ANR, OOM, or
  low-memory kill appeared in the clean sample.
- Result: Crystal 251 plus the accepted Dramaless/Kanto/Wilds/Wild Skies stack
  passes this extended first compatibility run. Missing Murkrow/Houndour
  overworld registrations and the single intermittent generic flyer remain
  visual follow-ups, not blockers.

## 2026-08-11 - Crystal gameplay-state stress pass

- Continued the same Crystal 251 stack without restarting and exercised an
  interior round trip, world return, wild battle, menu/Pokédex use, and
  subsequent overworld travel. Physical testing confirmed that A, B, triggers,
  and both thumbsticks remained responsive through every state change.
- Device logs confirm Lavender Town -> Pokémon Tower 1F -> Lavender Town ->
  Route 12, followed by a Wilds of Kanto Slowpoke battle and a normal `win`
  completion. Wild Skies continued spawning flyers afterward, demonstrating
  that both gameplay and mod update loops survived the battle transition.
- No crash, ANR, OOM, trim-memory event, or low-memory kill appeared. The user
  observed only occasional slowdowns.
- Post-test memory rose to 2,310,408 KB total PSS (about 2.31 GB), including
  893,764 KB Graphics. Battery was 35%, USB powered through a weak charger, and
  the reported temperature was 50 C. Compared with the preceding traversal's
  roughly 2.01 GB/766 MB Graphics/47 C sample, the higher retained resource
  footprint and temperature are plausible contributors to the intermittent
  slowdown and warrant a longer memory/thermal optimization pass.
- Additional nonfatal asset evidence: Wild Skies rendered Skarmory and Gligar;
  Wilds of Kanto reported a missing Yanma overworld registration in addition to
  the previously recorded Murkrow and Houndour fallbacks.
- Result: controls and gameplay-state transitions pass; sustained memory,
  graphics allocation, and thermal behavior—not functional input—are now the
  primary concern for this stack.

## 2026-08-11 - Bounded Quest UI and route-memory candidate

- Audited the retained-resource paths against the 2.31 GB stress sample. The
  Quest Pokédex capture and mirror replaced resized canvases without explicitly
  releasing their old GPU objects, and VR shutdown/invalidation did not release
  every owned capture target. Added a small ownership helper and now release
  superseded/teardown canvases immediately rather than waiting for Android's
  eventual Lua/graphics finalizer.
- Dramaless intentionally retains the current and previous complete mesh live
  sets so a door into an interior can return to its outdoor neighbourhood
  without a flat rebuild flash. That same extra history is redundant after a
  seamless route/town crossing: the new connected live set already contains
  the map behind the player. Added a source-guarded `dropPrevious` seam and call
  it only for connection crossings and Fly. Ordinary doors, caves, towers,
  elevators, and other warp returns keep the warm-history behavior.
- Offline tests passed: Quest canvas ownership `12/12`; history adapter `6/6`;
  the complete adapter still applies exactly to checked Dramaless Shape 1.6.4
  and produces compilable Lua.
- Reproduced the known ABI-injected Gradle trap: the ARM64 intermediate updated
  while the canonical output stayed at the old `D08A...` hash. That intermediate
  was rejected. A forced multi-ABI canonical rebuild then succeeded.
- Verified candidate APK SHA-256:
  `B013F36302DE4BB0DD82317C4E99C80B25EE53F06BD4634863DD5DB4236E2DDA`
  (52,815,428 bytes). APK Signature Scheme v2 passes; its embedded `game.love`
  hash is `E6770E0AC9EE0F747591795DFC842168D17D06608F0CFF543CD86CB7028C965D`.
  The payload has 367 entries, exactly one copy of each changed Quest file, and
  no generated ROM/cache paths.
- The headset was shut down, so the candidate was built but not installed.
  Exact ordinary-play validation is in `QUEST_MEMORY_CANDIDATE_TEST.md`.

## 2026-08-11 - Gen 2 priority pivot

- Made upstream's *Preparing Your Mod For Gen 2* guide the top priority.
- Created isolated branch `quest-gen2` and merged upstream `ae6cac89` while
  retaining the prior playable Quest branch. The merge preserves Quest
  launcher/OpenXR handoff and adds the parallel Gold boot path.
- Audited the active mod stack with `tools/modkit.py gen2check`. All current
  mods correctly remain Gen 1-only; none was falsely relabelled compatible.
  Dramaless, Kanto First Person, Wilds of Kanto, and Wild Skies require real
  Gen 2 ports. Crystal 251 duplicates native Gold functionality and contains
  fatal Gen 1-only imports, so it should remain Gen 1-only by default.
- Built a ROM-free Gold-capable Quest baseline. APK SHA-256 is
  `A5D42655FDBA228AC480FF10625EC5DEEA20FCE69B71C2845FB44A6E2942E6C9`;
  signature, embedded payload identity, ARM64/OpenXR libraries, and absence of
  generated ROM/cache data were verified.
- Next physical checkpoint is importing a legally obtained Gold ROM and
  proving launcher -> Gold -> gameplay on Quest with incompatible mods skipped.

## 2026-08-11 - Official v0.1.78 beta integration

- Fetched signed upstream tag `v0.1.78` at `2fabc038` and created isolated
  branch `quest-gen2-beta-v0.1.78` from the completed rehearsal branch.
- The tag merged cleanly with no launcher, importer, Android, or OpenXR source
  conflicts. Its Gen 2 engine is descended from the rehearsed `ae6cac89`
  revision; only iOS release metadata was newly applied by this merge.
- Result: the preparation matched the released beta as intended. Quest keeps
  upstream's launcher and Gold implementation, adding only its platform input,
  panel capture, lifecycle, and XR handoff behavior.

## 2026-08-11 - v0.1.78 physical Quest regression

- The installed Quest APK matched the current beta candidate byte-for-byte:
  SHA-256 `899339B1101158007DED6D8B359135CB92FF8134813857A3E369AFDFF3BCFF29`
  (58,594,191 bytes). The pre-test installed APK was pulled to the local
  rollback-artifact directory before testing.
- Launcher, loader, Yellow handoff and Dramaless voxel entry all passed.
- User physically confirmed stereo/6DoF, recenter, Touch controls, menu/Pokédex,
  building transition and general traversal. Log events independently showed
  Start, A and B state changes.
- A 15-second headset sleep/wake cycle returned directly to voxel gameplay in
  the same process (`pid 20798`), with no crash, ANR, OOM or low-memory event.
- Initial/warmed voxel samples remained slow: averages around 35–40 ms/frame,
  median about 33–35 ms, with periodic 78–125 ms spikes. Memory was about
  2.03–2.06 GB total PSS with 775–783 MB graphics and 243 MB logged textures.
  Temperature rose from 42 C to 47 C during the run.
- Menu/Pokédex presentation reached about 13.4–13.6 ms/frame with only 51–55
  draw calls versus roughly 700+ in voxel scenes. This demonstrates that the
  OpenXR transport can meet the 72 Hz budget and strongly implicates voxel
  world draw/streaming load as the primary performance blocker.
- Resume returned to voxel, but its steady frame time returned to roughly
  36–38 ms and logged texture allocation rose to 278 MB. Continue with
  rendering/streaming profiling before declaring release-quality performance.

## 2026-08-11 - Dedicated Dramaless Quest fork baseline

- Created separate local repository `E:\Gen1QuestVR\Dramaless-Quest` from
  upstream tag `v1.6.4` (`3e7138a`) on branch `quest-vr`. Its upstream remote
  is named `upstream`, preventing an accidental default push to the creator's
  repository.
- Imported the exact physically validated Quest conductor and OpenXR/GLES
  transports. Moved `CanvasLifetime` and `StreamingPolicy` into the mod
  namespace so those helpers no longer depend on private host source paths.
- Manifest version is `1.6.4-quest.1` and explicitly targets `games: ["gen1"]`.
  `gen2check` therefore rejects Gold as intended; no false Gen 2 claim was made.
- Added attribution/compatibility notes, `.envignore`, and a deterministic
  Quest ZIP packager. Two consecutive builds produced identical SHA-256
  `B09878B4DE4B161CAC593BC4877E09E8CFCDAEEBAD5AD7D3C029C24E8370ED1C`
  (1,497,238 bytes), with canonical paths and no ROM/save/generated data.
- Fork commits: `edc0afc` (Quest baseline) and `6606c44` (reproducible package).
  Candidate copied to Quest Downloads as
  `IMPORT_ME__DRAMALESS_QUEST_1.6.4-q1.zip`; physical import validation remains.
- The host still owns source-guarded `ChunkMesher`/`VoxelScene` adapters for
  the first milestone. Move those reviewed changes into the fork before
  removing the host installer behavior.

## 2026-08-11 - Dramaless Quest 1.6.4-quest.1 physical import check

- User imported the deterministic `DRAMALESS_SHAPE-1.6.4-quest.1` package and
  confirmed the normal Yellow path: launcher, game handoff, voxel world and
  ordinary rendering all loaded successfully.
- The retained Quest log contained no Gen1Recomp fatal exception, ANR,
  low-memory kill or new OpenXR failure during the reported run.
- Warm voxel `PERF10` windows remained between 34.56 and 38.66 ms/frame, with
  roughly 502-705 draw calls, six canvases, ten shaders and 277.1 MB of logged
  textures. This matches the already-known world-rendering bottleneck rather
  than indicating a regression caused by extracting the VR transport into the
  dedicated mod fork.
- Result: the reproducible fork package passes its first physical Yellow/voxel
  checkpoint. Next engineering milestone is to move the reviewed
  `ChunkMesher`/`VoxelScene` adaptations out of the host installer and into the
  fork behind exact-source tests, then profile world draw work independently.

## 2026-08-11 - Dramaless Quest update-channel isolation

- Physical testing revealed that the launcher still offered an update to the
  regular Dramaless package. Root cause was the Quest manifest inheriting
  `github: artyrambles/DRAMALESS_SHAPE`; update discovery therefore queried
  upstream's ordinary release feed for the shared `DRAMALESS_SHAPE` mod id.
- Released local candidate `1.6.4-quest.2` with the inherited GitHub update
  field removed. The shared mod id remains unchanged for dependency, conflict
  and save continuity. A Quest-specific feed can be added after the fork has a
  stable public release repository.
- The deterministic replacement ZIP is 1,497,799 bytes with SHA-256
  `40BCC8DFBBF2F79F793E6DE1FD5652B3FFBBB360C8599DACE07EFB84A2B2C876`.
  Two consecutive builds were byte-identical, and the packager now rejects a
  future accidental reintroduction of a `github` field.
- Copied to the headset as
  `Download/IMPORT_ME__DRAMALESS_QUEST_1.6.4-q2.zip`; import and launcher update
  indicator validation are pending.

## 2026-08-11 - Dramaless quality baseline correction

- User reported that all recent Yellow voxel tests, including the retained
  34.56-38.66 ms/frame sample, were run at `RES: FULL` and `SHADOWS: HIGH`.
- These numbers remain a useful maximum-quality/worst-case baseline, but they
  must not be used as the Quest-tuned performance result. Dramaless documents
  render scale as quadratic: `1/2` shades roughly one quarter as many scene
  pixels as `FULL`. `LOW` shadows also use a smaller map, one sample, no
  neighbouring-map casters and an every-other-frame moving redraw.
- Next controlled comparison is the same save/location and traversal at
  `RES: 1/2`, `SHADOWS: LOW`, leaving every other mod and option unchanged.
  Compare visual clarity, frame time, draw count and texture allocation before
  changing streaming or geometry code further.

## 2026-08-11 - B/cancel lost while changing Dramaless quality

- While attempting to change the controlled performance settings, the user
  could not exit with B and had to quit the application.
- Retained logs showed no crash or ANR. After restart, OpenXR reacquired both
  Touch controllers and emitted the B-class `0x20` event normally, alongside
  stick and confirm events. This rules out a persistent controller/hardware
  failure and makes menu-state routing or a lost release/ownership transition
  the leading suspect.
- Do not count the interrupted run as the `1/2` + `LOW` performance sample.
  Next isolation pass: verify B once at the Yellow title/start menu, then open
  the Dramaless settings, change only the two quality rows, and verify B again.
  If only the second check fails, capture the active screen stack and input
  dispatch around that settings exit.

## 2026-08-11 - Saffron 1/2 resolution and low-shadow comparison

- Completed a two-minute physical run at `RES: 1/2` and `SHADOWS: LOW`. The
  route was Saffron, Silph Co. 1F, Route 8 and its gate, Lavender, then back
  toward Route 8. It exercised an interior warp, major outdoor connections
  and the same connection chain in both directions.
- Initial regional work remained extremely expensive: the first two `PERF10`
  windows averaged 116.82 and 67.99 ms/frame while Celadon, Cerulean,
  Vermilion and a full Celadon mesh were generated. Individual active mesh
  jobs took approximately 1.46-9.91 seconds despite cooperative yielding.
- Once that queue settled, quiet/warm windows improved to roughly 28.73-35.60
  ms/frame. Transition-driven background queues raised other windows to
  44.56-53.70 ms/frame. Draw counts remained approximately 433-736, showing
  that lowering pixel/shadow quality does not reduce CPU draw submission.
- Returning from Lavender requeued Route 8 and nearby route bodies, exposing
  duplicated/repeated connection work as a concrete optimization target.
- End-of-run memory was 1,812,088 KB total PSS and 655,084 KB graphics, down
  from the prior FULL/HIGH baseline's roughly 2.03-2.06 GB PSS and 775-783 MB
  graphics. Battery moved from 70% to 68% and temperature from 45 C to 47 C.
- Conclusion: `1/2` + `LOW` is the correct Quest default candidate and gives a
  meaningful memory/fill-rate benefit, but mesh generation, over-eager major
  location preloading and hundreds of world draw submissions are now the
  dominant performance targets. Do not sacrifice more image quality before
  reducing that CPU/streaming work.

## 2026-08-11 - Reversible connection-history candidate

- Root cause of the Route 8/Lavender return rebuild was the Quest conductor
  calling `dropPrevious()` for every seamless outdoor connection. The new live
  set retained the map directly behind the player, but not all completed and
  queued bodies from its neighborhood; reversing direction therefore rebuilt
  useful work.
- Changed the bounded policy to retain Dramaless's existing one-generation
  history for walking connections and ordinary warps. Fly alone clears the
  previous set because its origin is geographically unrelated. Memory remains
  bounded to the current and previous neighborhoods rather than an unbounded
  travel cache.
- Added policy checks for connection, warp and Fly behavior. The isolated LOVE
  test process exited successfully. Dramaless Quest package
  `1.6.4-quest.3` built twice byte-identically: 1,498,443 bytes, SHA-256
  `B7094D6C0D0FADD15E009C0EE676C56DF8AD1D9BB07CBF2F1C5633B95B4C49F9`.
- Canonical multi-ABI APK build passed. The APK is 58,594,191 bytes, SHA-256
  `C7F56539E0360D01DA05ED139FC8D5D30B2B0F9B9E8DD72CB0B715783B2C967B`;
  embedded `game.love` SHA-256 is
  `C89D28E7BF53607D9103200092B27ECB9A99068167D53C540316A4BCCFB2F08B`.
  Archive inspection confirmed the new policy and zero generated ROM-data
  entries.
- Installed the APK as an update without clearing app data and copied q3 to
  Quest Downloads. Physical Route 8 -> Lavender -> Route 8 comparison and
  end-of-run memory measurement remain pending.

## 2026-08-12 - Official v0.1.79 integration candidate

- Fetched signed tag `v0.1.79` at `04490c9b` and created isolated branch
  `quest-gen2-beta-v0.1.79` from the v0.1.78 Quest line.
- The merge completed cleanly. Upstream Gen 2, UI, checkpoint/mod-option
  storage and Android TLS changes coexist with the Quest OpenXR activity hooks
  and the Dramaless OptionsMenu wrapper seam.
- A clean ROM-free multi-ABI build passed all 58 tasks. APK SHA-256 is
  `813418E5C48D66EB2EB6E5D60CDDCEDF1D21317734F1A98B6F1EA262278D7867`;
  embedded payload SHA-256 is
  `5F1610A7909E650BBF2C6DF25D2EED00C2DC7FFA3ACD70F52FA2623ADC1972CC`.
- Archive inspection confirmed ARM64 OpenXR, v0.1.79 source, retained-history
  integration and no generated ROM data. v0.1.78 remains the rollback build
  until the complete physical Quest regression passes.

## 2026-08-12 - v0.1.79 Route 8 return and mod-options cancel test

- Physical Quest test reached Lavender and returned to Route 8 under Dramaless
  Quest `1.6.4-quest.3`. Lavender's neighborhood queued once; the return to
  Route 8 produced no second queue or mesh rebuild. This validates the bounded
  retained-history policy for the tested reversal.
- Warm ten-second windows after background work settled averaged approximately
  29.81-32.52 ms/frame. Transition/background work reached 37.26-46.38
  ms/frame, with roughly 445-634 draws and 215.6 MB reported texture use.
- B still failed specifically inside Mod Manager -> Dramaless Shape -> OPTIONS.
  This is not a controller-wide failure. The engine screen consumes a queued
  `wasPressed("b")` edge, while Quest also exposes a reliable held state.
- Built Dramaless Quest `1.6.4-quest.4` with a narrowly scoped Android-only,
  edge-latched held-B fallback on the schema-driven mod-options page. It cannot
  back through multiple screens on one hold and does not change desktop or
  gameplay input. Deterministic ZIP is 1,499,018 bytes, SHA-256
  `96BE19281DE160C934E45F2662FFD90320A3C5D14163BDB010113C9566CF86D1`.
  Physical validation is pending.

## 2026-08-12 - Mod Manager-wide B scope correction

- User clarified that B fails throughout the complete Mod Manager, not only
  Dramaless's schema-driven OPTIONS page. Quest.4 was therefore superseded
  before validation.
- Dramaless Quest `1.6.4-quest.5` applies the same Android-only held-state
  fallback at ManagerState scope. Its latch returns exactly one manager level
  per press and permits B to close the root manager without affecting gameplay.
- Deterministic ZIP is 1,499,092 bytes, SHA-256
  `37A22B0C8FEDC26843D1790278B5C34A6951A987D34D1151BEC4C6ED824AA430`.
  Copied to Quest Downloads as
  `IMPORT_ME__DRAMALESS_QUEST_1.6.4-q5.zip`; physical validation is pending.

## 2026-08-12 - Quest Mod Manager B/cancel validated

- The visible `NO CHANGES` notice proved that physical Quest B was arriving in
  ManagerState as START, whose normal manager action is apply/restart status.
- Dramaless Quest `1.6.4-quest.6` intercepts that routed START edge only while
  ManagerState owns input and treats it as Back. Gameplay and non-manager
  controls remain unchanged; the held-state latch still prevents one hold from
  crossing multiple menu levels.
- Physical Quest test passed through the real hierarchy: Dramaless -> Mods ->
  Options. Each B press returned exactly one screen. The Mod Manager cancel
  regression is resolved for the v0.1.79 candidate.
- q6 deterministic ZIP is 1,499,394 bytes with SHA-256
  `59192098948328E95762B3528D26C2EBCB941D9D2B93CD09092885D13DC9CABA`.

## 2026-08-12 - Controller wake and short suspend/resume pass

- In active voxel gameplay, both controllers were left idle until timed out.
  Picking them back up restored movement, A, B and snap turning without the
  historical immersive-loading stall.
- A deliberate 30-second headset sleep/wake and an immediate accidental second
  pause/resume both returned successfully with gameplay responsive.
- Post-resume logs show continued QuestXR `PERF10` output and controller
  reacquisition, with no fatal exception or ANR. Subsequent warm windows were
  approximately 30.57-35.47 ms/frame.
- This validates short lifecycle recovery for v0.1.79/q6. Long-duration sleep
  remains a distinct test and is not implied by this result.

## 2026-08-12 - Long suspend/resume pass

- The v0.1.79/q6 candidate successfully resumed after a 10+ minute headset
  sleep. This closes the planned long-duration companion to the prior
  controller-timeout, rapid-resume and 30-second suspend tests.
- No long-sleep loading-screen stall was observed. Lifecycle validation is now
  complete for this candidate; promotion remains pending only on the separate
  loader-logo integration handoff and physical presentation check.

## 2026-08-12 - Full-color VR Unplugged loader approved

- Replaced the muted pixel-art loader mark with the full-color blue/yellow
  transparent `Gen1Recomp++ VR Unplugged` logo and linear downsampling.
- Restored the brighter approved loading-card palette sampled from its preview:
  cream `#FFF4C2`, gold `#F6C445`, navy `#102A56`, and blue `#3B82D0`.
- Map name, segmented preload progress and bold status text remain unchanged;
  no streaming, OpenXR or lifecycle logic was modified.
- The ROM-free APK installed successfully and the user completed the physical
  headset appearance check. APK SHA-256 is
  `A25CA14F5354E0815461C76593C3227DDD17281C05BD3ECC35E61877D7275039`;
  embedded payload SHA-256 is
  `C44A77CE8F4F2FD948A5CF6445213D1A811A7FB12D1CD93C1785FC56DFB5412D`.
- Combined with Dramaless Quest q6 and completed short/long lifecycle tests,
  this promotes v0.1.79 as the current known-good Quest baseline.

## 2026-08-12 - Stock Gold import and flat Quest baseline

- User supplied a legally obtained USA/Europe Pokémon Gold ROM in a local ZIP.
  The archive SHA-256 is
  `ACA99B47E5BF1E9BC7EA5F0BDE0A2F0FEB0E3345D27B3D1F7BCBD41C88826383`;
  extracted 2 MiB ROM SHA-256 is
  `FB0016D27B1E5374E1EC9FCAD60E6628D8646103B5313CA683417F52B97E7E4E`.
- Copied the ROM only to external Quest storage under `/sdcard/baseroms/`.
  It was not added to the APK, repository, build stage or documentation.
- The v0.1.79 launcher detected and offered the ROM for import. The user
  completed the import manually, disabled every mod, and confirmed Gold loads
  and runs normally in flat mode.
- This passes the stock Gold import/boot baseline. It does not validate Gold
  voxel rendering, Dramaless compatibility, VR presentation, long gameplay,
  battles, saves or lifecycle recovery yet.

## 2026-08-12 - Stock Gold functional regression pass

- With all mods disabled, the user completed the requested Gold foundation
  route successfully: created an in-game save, quit to the launcher, continued
  the save, entered/exited a building, completed a wild-battle check, verified
  movement/A/B/Start/Select, resumed after a 30-second headset suspend, saved
  again and restarted successfully.
- This validates stock flat Gold save persistence, basic controls, an interior
  transition, battle entry/operation and short lifecycle recovery on Quest.
- The Gen 2 foundation is ready for the next stage: source-audit Dramaless
  against Gold's public/shared render seams before enabling or adapting voxel
  VR. Long-duration Gold play, long suspend and broader map coverage remain
  later reliability tests rather than blockers for beginning that audit.

## 2026-08-12 - v0.1.79 Pokédex battle-feed regression

- User clarified that the battle UI and information remain visible and usable.
  The compromised element is the Pokédex's view of the 3D battle itself, not
  access to battle commands or status information.
- Reclassified as lower-medium presentation work: below loading/suspend
  reliability and sustained world performance, but above pixel-perfect sizing.
- Next investigation should capture a screenshot plus logs at battle entry and
  distinguish an incorrect 3D camera feed from crop/framing distortion.
## 2026-08-12 - Dramaless Quest display-rate candidate

- Audited 1GenPokemonVR `v0.2.46` as clean-room research; its original Quest
  additions have no outbound license and no source was copied.
- Added independent `XR_FB_display_refresh_rate` capability detection and
  request handling to Dramaless Quest `1.6.4-quest.7`.
- Added `DISPLAY RATE` choices for 72/80/90/120 Hz with 90 Hz as the balanced
  default. The runtime-reported list is authoritative and unsupported choices
  fall back to the nearest rate; absence of the extension leaves the runtime
  default unchanged.
- Requests wait until `xrBeginSession` has completed and are applied live when
  the setting changes. Unsupported sessions are attempted once, not per frame.
- Updated the APK-side conductor and protected a newly imported q7 transport
  from being downgraded by an older embedded transport during launcher handoff.
- The q7 package built twice byte-identically: 1,501,135 bytes, SHA-256
  `4DA129EDC54E059B05728D839C5F6781AC9382F6821C165E86FDB817FA3D862C`.
- Physical Quest validation remains required before promotion.

## 2026-08-12 - Overnight flat-mode lifecycle recovery

- User reported that the application woke and ran normally after remaining
  asleep since the previous night while it was outside the voxel renderer.
- This is positive evidence for long-duration Android/app lifecycle recovery
  in the flat non-voxel path. It does not independently validate restoration
  of the Dramaless voxel renderer or an active gameplay OpenXR session.
- No forced quit, reinstall, or headset reboot was reported for this wake.
## 2026-08-12 - Dramaless q7 startup regression and q8 correction

- Physical import failed twice. Logcat identified the deterministic error at
  `mods/DRAMALESS_SHAPE/main.lua:547`: `VR.refreshRate` was nil while building
  the mod-options schema.
- Root cause: the installed APK refreshed q7's writable `VR.lua` with its older
  embedded conductor before mod initialization. The old conductor did not yet
  define the new display-rate setting.
- Dramaless `1.6.4-quest.8` now supplies a backward-compatible setting
  definition from `main.lua`, preventing startup failure under the older APK.
- Corrected package copied to Quest Downloads. SHA-256:
  `B526E2FF31AD7F862C67C72F3762B265D2130155EEF7518DB07E40D33C0BE2F5`.
- q8 should load under the existing APK; the display-rate runtime request still
  requires the matching rebuilt APK conductor before that feature is validated.

### q8 load and matching APK

- User confirmed q8 loads successfully and `DISPLAY RATE` is visible in the
  Dramaless options, closing the q7 settings-schema startup regression.
- Rebuilt the canonical `questVrNoRecordDebug` output with the matching tracked
  conductor and q8 `VRXR.lua`. All 58 Gradle tasks passed.
- Inspected the final `build/outputs` APK, not an intermediate: all three
  refresh markers are embedded and no generated ROM-data paths are present.
- APK: 59,766,935 bytes, SHA-256
  `0101E8B60C3F24921F993887B8A0E099B61259E3809F5CD71256B9DC777FF7E3`.
- Embedded `game.love`: 5,656,067 bytes, SHA-256
  `3D663D53DA2D75E34C3D3EF5588FAE63E7E246D21EB863838B484BCE0B9B939B`.
- Installed as an update with app data preserved. Runtime acceptance of 90 Hz
  remains the next physical/log validation checkpoint.

### 72 Hz control test and q9 diagnostics

- User selected `72 HZ`, but VrApi continued reporting `FPS=.../90`,
  `DR90/91`, and Android measured the display at `90.00 Hz`. The options row
  therefore works, but live OpenXR rate control is not yet validated and must
  not be marked complete.
- Added q9 diagnostics for the setting transition, extension availability,
  supported runtime rates, request result, and post-request runtime rate.
- q9 ZIP: 1,501,884 bytes, SHA-256
  `3837AB9BAEFA4C8F8DA80B9003A196965D94CFE1219D397E901341AAD7818F05`.
- Rebuilt all 58 Gradle tasks successfully and inspected the final APK plus
  embedded `game.love`; neither contains ROM/save/generated-data paths.
- Diagnostic APK: 59,765,447 bytes, SHA-256
  `2395B973D251D64E8B090695DA97209CFF595F579E766BD60885F8B5F9B9D8B6`.
- Embedded `game.love`: 5,648,974 bytes, SHA-256
  `AFD785DAC1CC6EBD5591D21069B9B3721C238FFB2E37BCE52B19335F572395EC`.
- Copied q9 to Quest Downloads and installed the matching APK as an update,
  preserving app data. Physical import/load at 72 Hz is the next checkpoint.

### q10 display-rate control physically validated

- q9 proved that Quest exposed `XR_FB_display_refresh_rate` and all required
  entry points, but `xrEnumerateDisplayRefreshRatesFB` returned a zero count.
  This prevented the request even though the request function was available.
- q10 treats enumeration as advisory in that case: it requests the selected
  known numeric rate directly and preserves OpenXR's authoritative result.
- Physical q10 trace at startup:
  - extension ready;
  - setting transition `nil -> 72`;
  - empty enumeration detected;
  - direct 72 Hz request accepted.
- The immediate `xrGetDisplayRefreshRateFB` query still reported 90 Hz because
  the runtime applies the accepted change asynchronously. Subsequent VrApi
  telemetry switched from `/90` to `/72` and remained there, with `DR72/73`.
  This is definitive compositor-level validation that the option works.
- q10 ZIP: 1,502,084 bytes, SHA-256
  `B7D9C26AF6353C91620B130AE70F6833A193FD74C05301C1FCE73E8912223ACD`.
- Matching APK: 59,765,575 bytes, SHA-256
  `BEDFAF850BB9C7B2F37DD0715F9FD3EC240CE459D363BB02D6970F816CEC208B`.
- Observed gameplay delivery remained workload-bound, commonly around
  38-41 FPS with periodic hitches, but the compositor target and stale-frame
  budget dropped from 90 to 72 Hz as intended. Refresh control is complete;
  renderer performance remains a separate optimization track.

## 2026-08-12 - Dynamic Cries 1.4.3 optional-mod audit

- Audited the original `Dynamic_Cries_v1.4.3.zip` as an optional immersion mod,
  not a Quest fork or bundled project dependency.
- Original ZIP: 335,643,271 bytes. SHA-256:
  `103C08E40DB8A9B82ACC5E0D6B88F9CFA36F6566CA3A63364F3C7400A2708404`.
- Manifest declares API 2 and both `gen1` and `gen2`. Package contains pure Lua,
  configuration, and audio: no DLL/SO/executable, FFI, APK, ROM, or save data.
- Payload contains 3,438 WAV files and approximately 417.8 MB of uncompressed
  audio. It replaces cry playback through public content registration plus
  guarded `Sound.playCry`/`Sound.playPikaCry` wrappers.
- Audio sources are loaded lazily and cached per selected cry. Expected steady
  CPU cost is low, but import/storage cost and long-session audio-cache growth
  require physical measurement before recommending it.
- Upload was attempted unchanged, but no ADB device was connected. Retry after
  the charged Quest reconnects; do not add this payload to the APK or Git.

## 2026-08-12 - Upstream engine/API extraction, PRs 1-4

- Re-audited the integration branch against official `dev` at `c3136bf8`
  (the `v0.1.80` source head used for extraction). The monolithic Quest diff
  remains unsuitable for upstream because it mixes generic engine seams,
  Android/OpenXR code, launcher policy, and mod-specific rendering changes.
- Submitted four isolated, ROM-free upstream pull requests:
  - [#1199](https://github.com/bryanthaboi/gen1recomp/pull/1199), commit
    `1642113d`: route existing generic launcher focus through modal controls.
  - [#1200](https://github.com/bryanthaboi/gen1recomp/pull/1200), commit
    `c2d9af69`: optional `HostDisplay` lifecycle with a no-op vanilla backend.
  - [#1201](https://github.com/bryanthaboi/gen1recomp/pull/1201), commit
    `0aab11b6`: generic updater `payloadHost` compatibility contract.
  - [#1202](https://github.com/bryanthaboi/gen1recomp/pull/1202), commit
    `ee00728e`: protected Android host-library and lifecycle extension hooks.
- PR 4 preserves SDL's required native-library invariant: `liblove.so` remains
  the final/main shared object, while an optional flavor may insert libraries
  after LÖVE's dependencies and before `liblove`.
- Stock `assembleEmbedNoRecordDebug` passed from source in 7m40s. The resulting
  18,770,257-byte APK has SHA-256
  `F523FABDDB04F3299FFBF324A0F43516324CC8520FF86F96364FB9EE0523C78D`.
  Archive inspection found only `libc++_shared.so`, `libmpg123.so`,
  `libopenal.so`, and `liblove.so` for ARM64, ARMv7, and debug x86_64. It
  contains no Quest/OpenXR native payload.
- The new Android host-extension contract test passed. The complete Windows
  engine run remained at 157/160 suites. The failures are the established,
  unrelated `build_zip_pipe_guard_bug774`, `quit_thread_shutdown`, and
  `title_zone_seams` environment/baseline failures; no new suite failed.
- Non-product issues encountered and resolved during verification:
  - Git worktree creation and Gradle's external cache initially hit managed
    filesystem permission errors; both succeeded after the explicitly scoped
    approvals.
  - The first static test searched for the substring `quest`, which also
    matched ordinary words such as `request`; it was corrected to reject only
    concrete `QuestActivity`/`QuestBridge` class references.
  - Android compilation emitted the existing SDL/LÖVE/third-party deprecation
    warnings but no new Java or native error.

## 2026-08-12 - PR 5 Quest/OpenXR backend extraction started

- Created isolated stacked branch `upstream-quest-openxr-backend` at
  `d2d2c428`, based on Android seam `ee00728e` plus the `HostDisplay`
  prerequisite. No PR 5 code has been submitted or promoted yet.
- Audit found three boundaries that must be corrected before submission:
  - the prototype compiles `questxr_bridge.c` directly into shared `liblove`,
    so stock Android is not physically isolated from Quest symbols;
  - shared `GameActivity` declares/calls Quest JNI methods, even when runtime
    bootstrap metadata is disabled;
  - `src/quest/PanelBridge.lua` combines native panel/input transport with
    Dramaless conductor installation, mesher patches, and streaming policy.
- Planned correction: a Quest-only Android/LÖVE flavor, activity subclass, and
  separate `libquestxr.so`; a small engine-facing host adapter; and no
  Dramaless, Kanto, ROM, save, loading-policy, or commercial-asset content in
  the backend PR.
- PR 5 remains gated on a ROM-free ARM64 build, stock-APK comparison, and the
  physical Quest launcher/stereo/6DoF/recenter/input/suspend/handoff matrix.
- GitHub CLI authentication expired while checking live PR review state
  (`HTTP 401`). Local commits and submitted PR URLs are verified, but current
  merge/review/check status must be refreshed after `gh auth login` rather than
  guessed in project documentation.

## 2026-08-12 - PR 5 backend implementation and full local review

- Completed the isolated implementation candidate on
  `upstream-quest-openxr-backend` at `4e16cd77`. It now contains a Quest-only
  Android flavor/activity, separate `libquestxr.so`, optional engine-facing
  `HostDisplay` provider, fixed launcher panel transport, Touch input, and the
  launcher-to-gameplay session handoff. No Dramaless/Kanto policy, ROM, save,
  generated cache, or commercial asset is part of the candidate.
- Stock Android remains a no-op consumer of the generic seams. Archive and ELF
  inspection confirmed that neither stock `GameActivity` nor stock
  `liblove.so` contains Quest/OpenXR references or dynamic symbols.
- A clean build exposed an Android Gradle Plugin behavior missed by incremental
  builds: product-flavor `abiFilters` merged with the default ABI set instead
  of replacing it, so Quest native tasks were still being scheduled for ARMv7
  and x86_64. The build was stopped before accepting that artifact. PR 5 now
  uses the variant API to set the Quest external-native-build ABI set to only
  `arm64-v8a`; a regression test and Gradle dry run verify the replacement.
- A second source-level comparison against the proven integration backend found
  missing generic lifecycle protections. The candidate now handles
  `shouldRender == false`, requests session exit and completes the STOPPING
  transition, applies room anchoring/recenter with yaw-only leveling, emits one
  launcher navigation edge per left-stick flick, reserves the right stick for
  gameplay camera use, and never calls process-wide `eglTerminate` on SDL's
  shared display. Cross-thread lifecycle state now uses C11 atomics.
- The canonical packager required three host-only accommodations: a temporary
  wrapper to the real Python executable because Git Bash selected the disabled
  Windows Store shim, `PYTHONUTF8=1` because the host Python defaulted to
  CP1252, and a temporary `zip` wrapper backed by installed 7-Zip. These helpers
  were removed after packaging and were never committed.

### Verification results

- Focused suites all passed: Android host extension; `HostDisplay` 23/23;
  launcher modal focus 24/24; Quest display provider 9/9; Android flavor
  isolation; and source whitespace validation.
- Complete Windows engine run: 161/164 suites passed. The only failures remain
  the established host/baseline cases `build_zip_pipe_guard_bug774`,
  `quit_thread_shutdown`, and `title_zone_seams`; no PR 5 suite failed.
- Clean command:
  `gradlew.bat --no-daemon clean assembleEmbedNoRecordDebug assembleQuestVrNoRecordDebug --console=plain`.
  It completed 119 tasks successfully in 11m28s using JDK 17.0.20+8,
  Android SDK/API 34, NDK 25.2.9519653, and the repository Gradle wrapper.
- Stock APK: 22,984,342 bytes, SHA-256
  `F03F2708108540186CD53A9F1126953F0F020EF06F9CD26A30B0A80A428F7FFD`.
  It contains ARM64, ARMv7, and x86_64 LÖVE dependencies and no Quest/OpenXR
  archive entry.
- Quest APK: 24,028,171 bytes, SHA-256
  `32B762518036DE87C283DA6AD1870CEF74C585B0972EBFB967C4E9B224AF88F0`.
  It contains only ARM64 native libraries, including `libopenxr_loader.so` and
  `libquestxr.so`, launches `QuestGameActivity`, declares Quest head tracking,
  and uses minSdk 24 / targetSdk 34.
- Both APKs contain the identical 4,278,077-byte `assets/game.love`, SHA-256
  `023D8BF58D09100E943160BAE8DDB16DB3CE3974053DB7D010AF7C1E0FF0B4CB`.
  Its 499 entries include Yellow and Gold import manifests but zero generated
  payloads, ROM/save files, or bundled mods.
- `libquestxr.so` was verified as ELF64 AArch64. Its exports are limited to the
  Quest activity lifecycle, panel capture/input/handoff surface, and status
  getters; OpenXR functions are resolved from the runtime loader rather than
  left as unresolved link dependencies.
- ADB starts successfully with the project-local Android home, but currently
  reports no connected device. Physical validation is the remaining gate; the
  branch must not be described as submitted or release-qualified before it.

## 2026-08-12 - PR 5 physical pointer/loading/handoff milestone

- Installed the evolving PR 5 `questVrNoRecordDebug` APK with `adb install -r`
  on the Quest 3, preserving imported ROM data, saves, settings, and mods.
- Replaced the unreliable launcher focus-image experiments with a native
  right-Touch aim ray that drives the launcher's existing virtual-pointer and
  button paths. The visible compositor target is a crisp small white circle;
  the prior halo and duplicate software cursor are removed.
- Moved panel capture to a generic optional LÖVE presented-frame observer. It
  captures after batched draws finish and before SDL swaps, while the stock
  Android observer remains null. Raw GLES texture, framebuffer, pack, active
  texture, and scissor state are restored after capture.
- A physical test exposed a visibility override: Lua correctly hid the pointer
  on game frames, but native ray tracking re-enabled it whenever the controller
  was aimed at the retained panel. The compositor now updates ray coordinates
  only while Lua's launcher-only visibility flag is enabled.
- The first loading-card retest showed no card because the launcher log proved
  Dramaless `1.6.4-quest.13` was still installed; q14 had only been copied to
  Downloads. After importing q14, logs confirmed
  `loaded mod DRAMALESS_SHAPE 1.6.4-quest.14` and the colored GBC loading card
  returned.
- Route 8 physical timing: final save load at `22:56:51.439`; gameplay OpenXR
  request at `22:57:21.838` (30.4 seconds); launcher session released at
  `22:57:21.880`; gameplay startup completed at `22:57:21.956`; gameplay
  reached FOCUSED at `22:57:22.905`.
- User-confirmed pass: selector absent after Yellow starts, loading card
  visible during mesh preparation, and automatic entry into immersive voxel
  VR. This proves the earlier 30-second flat interval was the intentional
  save-aware preload gate, not a stale loading-screen lock.
- Engine milestone commit: `f9e8088b` on
  `upstream-quest-openxr-backend`.
- Dramaless milestone commit: `309f4df` on `quest-vr`.
- Validated APK SHA-256:
  `7BE8565B7C7344D83954ACD79139FB8F1D37E65CD245F83F035AAEE928F6EF23`.
- Validated q14 ZIP SHA-256:
  `1588EFCBE4985AD220D26F70BFA01AFBD80A35BD82E92FFFDAA6E92809CACC67`.
- Remaining gate: long suspend/resume, controller-sleep, repeated cold handoff,
  map-transition, and quit soak. The earlier destroyed-mutex abort remains in
  regression coverage, but is now classified as an old-build risk not
  reproduced by the current resume and clean-exit probes.

## 2026-08-12 - PR 5 AudioTrack lifecycle crash audit

- Re-read the saved crash evidence in
  `logs/crystal251-b-button-freeze-logcat.txt`. The abort belonged to the old
  `org.love2d.android.GameActivity` host, not the current Quest-specific host.
  Android switched from the game to Quest Home at `02:45:10.531`, logged a
  duplicate finish request at `02:45:10.548`, and the process's `AudioTrack`
  thread hit `pthread_mutex_lock called on a destroyed mutex` at
  `02:45:11.194`.
- Audited the current activity, SDL, OpenAL, and QuestXR teardown paths. SDL
  joins its native thread before `nativeQuit`; LÖVE OpenAL stops its pool thread
  before destroying the context/device; and the Quest bridge joins its own
  bootstrap thread before deleting Android references. QuestXR uses
  process-lifetime static mutexes and does not call `pthread_mutex_destroy`.
  There is not enough evidence to justify a speculative native teardown patch.
- Ran a controlled background/resume probe on the installed `f9e8088b`/q14
  candidate. PID `8995` survived more than 60 seconds in Quest Home and resumed
  under `org.love2d.android.QuestGameActivity`; no `FORTIFY`, destroyed-mutex,
  `SIGABRT`, or app-process-death event appeared.
- Result: the historical crash is **not reproduced on the current build by one
  controlled cycle**. Keep it in lifecycle soak coverage rather than marking
  it fixed. Android's normal screenshot command produced a zero-byte capture
  for the immersive layer; the user supplied the missing headset-eye check and
  confirmed the app returned to the voxel world. The first current-build cycle
  therefore passed process, audio, activity, and immersive-visual recovery.
- Immediately followed with three automated 10-second Quest Home/resume
  cycles. PID `8995` survived every background and resumed checkpoint. The
  bounded log contained three SDL pause callbacks, three resume callbacks,
  zero activity destruction, and zero fatal/audio/mutex/ANR/process-death
  signatures.
- After each relaunch, Horizon OS briefly recreated and then stopped the SDL
  Android surface. This matches its OpenXR handoff behavior rather than an
  activity teardown: `dumpsys activity` continued to identify the same
  `QuestGameActivity` record and process. Final in-headset voxel visibility and
  controller response were the acceptance check for the three-cycle soak.
- User-confirmed final pass: voxel rendering remained visible and controller
  input responded after the third cycle. Together with the earlier 60+ second
  cycle, the current `f9e8088b`/q14 candidate has four successful
  background/resume recoveries and no reproduction of the historical
  destroyed-mutex `AudioTrack` abort.

## 2026-08-12 - Clean shutdown and cold-start probe

- The user saved and selected Quest's system **Quit** action while the current
  `f9e8088b`/q14 build was in voxel gameplay. OpenXR reached `STOPPING` and
  `IDLE`; SDL paused and destroyed its surface; AAudio stopped; QuestXR logged
  `Android OpenXR context bridge released`; and the app called
  `System.exit(0)`.
- Zygote explicitly reported `Process 8995 exited cleanly (0)`. No `FORTIFY`,
  destroyed-mutex, fatal signal, tombstone, or ANR occurred. ActivityManager's
  later cached-process “has died” message is normal exit bookkeeping in this
  trace, not the historical SIGABRT.
- AAudio received a brief `requestStart` after `onDestroy` and roughly 32 ms
  before process exit. It succeeded and did not race into a crash. Preserve
  this as a shutdown-soak observation; do not patch it without reproduction or
  stronger ownership evidence.
- Cold launch created new PID `12514` and successfully initialized
  `QuestGameActivity`, SDL, the generic host display bridge, QuestXR bootstrap,
  Touch actions, first OpenXR frame, room-anchored launcher panel, post-present
  capture, and advancing live-panel generations. No fatal/OOM/stuck-start
  signature was logged. The user confirmed that the launcher was visible and
  the white controller pointer moved, completing the physical cold-start check.
- The user then selected Yellow and loaded the save. The colored loading path
  completed, immersive voxel rendering appeared, and gameplay controller input
  behaved as intended.
- Exact cold handoff timing: launcher handoff request `23:26:06.865`; launcher
  session ended `23:26:06.884`; Dramaless confirmed launcher session release
  `23:26:06.898`; gameplay OpenXR startup complete `23:26:06.966`; gameplay
  session FOCUSED `23:26:07.059`. The same PID `12514` remained alive and the
  request-to-FOCUSED ownership swap took approximately 194 ms.
- Post-handoff scan: zero `FORTIFY`, destroyed-mutex, fatal-signal, ANR, OOM,
  or app-process-death signatures. This completes one clean Quit -> true cold
  launcher -> Yellow -> loading -> immersive voxel -> working-controls pass.

## 2026-08-13 - PR 5 generic Pokedex frame-capture restoration

- Regression: after migrating to the isolated PR 5 host backend, immersive
  voxel rendering and controls worked but the physical Pokedex display stayed
  dark. Dramaless still defined its existing `captureDexFrame` implementation;
  the old Quest-patched engine callback after `Game:draw()` was no longer
  invoked.
- Engine fix: commit `b7fba361` emits the generic, observation-only
  `render.frame_drawn` event after each completed Lua draw and before host
  capture or ordinary `love.graphics.present()`. The default path has no
  subscriber and remains a guarded no-op. Observers cannot replace or veto
  vanilla presentation.
- Mod fix: Dramaless commit `b05b2f24` / `1.6.4-quest.15` subscribes only to
  completed `kind == "game"` frames and calls its existing Pokedex capture.
  The legacy callback remains for compatibility with older Quest APKs.
- Verification: the focused platform lifecycle test passed 14/14, the
  Dramaless Quest input contract passed, and `VR.lua` passed syntax checking.
  The broader engine run passed 160/164 suites; the four remaining failures
  were existing Windows/static-harness cases unrelated to this event. The
  broader modkit run passed 14/15; its remaining `gen2check.lua` failure was a
  Windows child-LuaJIT invocation problem.
- Packaging: the first q15 APK used a newly generated debug key and Android
  safely rejected `adb install -r` with
  `INSTALL_FAILED_UPDATE_INCOMPATIBLE`; the installed q14 app and data were not
  altered. The APK was then signed with the matching existing debug keystore
  (`C:\Users\I5 Gaming\.android\debug.keystore`, certificate SHA-256
  `253a30fbc7131d0970800a800a5d77fc49cbc00c8b5e4e9e5dc259854b1c4075`)
  and the in-place update succeeded with app data preserved.
- Physical pass: device logs confirmed
  `DRAMALESS_SHAPE 1.6.4-quest.15` in PID `15729`; the user then confirmed
  **Pokedex screen is back**. No Pokedex-capture exception, GL error, fatal
  signal, ANR, or OOM appeared in the checked interval.
- Performance remains separate. A subsequent controlled exterior walking
  sample was taken while the contextual Pokedex feed was inactive and still
  showed the repeating dips. The q15 sample averaged 28.63 FPS (30 median,
  18 p10, 15 minimum), with 27.63 ms average application frame time and
  approximately 2.285 GB PSS. This assigns the walking hitches to the stereo
  world/streaming workload rather than continuous Pokedex capture.
- Validated APK SHA-256:
  `8342334C3F6ED5D77A64E253FF86EB56355264D6B8CDC43ECEC296E88CBBB84E`.
- Validated q15 ZIP SHA-256:
  `E899C0B36530AC69FCBC8D5469F57FCCD025E0DA082574D61C1A733280E856CC`.

## 2026-08-13 - q16 immersive resolution and shadow comparison

- Source inspection found that Dramaless's existing `RES` option affected the
  flat renderer but was ignored by immersive VR: both VoxelScene eyes always
  received the OpenXR runtime's full recommended dimensions.
- Dramaless commit `d51b41b` / `1.6.4-quest.16` applies `Quality.scale()` to
  only the two intermediate eye canvases. Swapchain dimensions, submitted
  image rectangles, FOV, poses, and the existing GLES upscale remain
  unchanged. `FULL` retains the validated rendering path.
- Physical proof at `RES: 1/2`: device trace reported
  `eye RES 1/2 render=840x880 swapchain=1680x1760`. The warm 30-second sample
  averaged 30.07 FPS (32 median, 22 p10, 16 minimum), 25.53 ms application
  frame time, and approximately 2.009 GB PSS. This saved about 275 MB versus
  q15 full resolution, but the user found the loss of sharpness clearly
  visible.
- A controlled 94.6-second Saffron -> Route 8 -> Lavender -> Route 8 run then
  used `RES: FULL`, `SHADOWS: LOW`. It averaged 28.59 FPS (30 median, 18 p10,
  11 minimum), 23.85 ms application frame time, approximately 73% GPU load,
  and 2.257 GB PSS. No capture, GL, fatal, ANR, or OOM signature occurred.
- Compared with the earlier full/high q15 frame sample, full/low reduced
  average application frame time from 27.63 to 23.85 ms (about 13.7%) without
  reducing image sharpness. Whole-route FPS remained limited by transition
  and streaming hitches rather than steady shadow cost.
- User decision: prefer `RES: FULL` plus `SHADOWS: LOW` over the half-resolution
  alternative. Treat that combination as the current Quest 3 performance
  default. Keep `RES: 1/2` as an optional low-memory mode.
- Next performance target: instrument and reduce map-transition/streaming tail
  latency without shortening the accepted view distance or globally reducing
  resolution.
- Validated q16 ZIP SHA-256:
  `87F194FD0A290F2D88076E8EBF42020D7113B7636C72DC7C4929324945E519CB`.

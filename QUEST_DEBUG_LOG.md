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
E:\Gen1QuestVR\gen1recomp\mobile\android\app\build\intermediates\apk\questVrNoRecord\debug\app-questVr-noRecord-debug.apk
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

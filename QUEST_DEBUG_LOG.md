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

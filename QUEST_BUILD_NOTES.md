# Quest port: stock Android build notes

Audit/build date: 2026-08-09. Branch: `quest-openxr`, based on `origin/dev` commit `943ba5d`.

## Source-selected toolchain

| Item | Value |
|---|---|
| LÖVE / love-android | 11.5 / vendored love-android tag 11.5a |
| Gradle wrapper | 8.1 (`gradle-8.1-bin.zip`) |
| Android Gradle Plugin | 8.1.1 |
| JDK | 17 exactly (project prerequisite) |
| compileSdk | 34 |
| targetSdk | 34 |
| minSdk | 16 |
| NDK | 25.2.9519653 |
| Native build | ndk-build via `love/src/jni/Android.mk` |
| Release/default ABIs | `armeabi-v7a`, `arm64-v8a` |
| Debug extra ABI | `x86_64` |
| Graphics | SDL2 + EGL + OpenGL ES through LÖVE |
| Application ID | `com.theboisclub.pokemonred` |
| Variant | `embedNoRecordDebug` |

## Exact stock commands

On the project's supported Unix-like shell (Linux/macOS, or Git Bash on Windows):

```sh
export ANDROID_SDK_ROOT=/path/to/android-sdk
export ANDROID_HOME="$ANDROID_SDK_ROOT"
scripts/build_android.sh
```

The script writes `mobile/android/local.properties`, packages the game, and runs:

```sh
cd mobile/android
./gradlew --no-daemon assembleEmbedNoRecordDebug
```

Expected APK locations:

```text
mobile/android/app/build/outputs/apk/embedNoRecord/debug/*.apk
dist/android/debug/*.apk
```

The packaging-only reproduction used in this workspace was:

```sh
PYTHONUTF8=1 scripts/build_android.sh --package-only
```

Result: **PASS**. It produced a roughly 3 MiB `app/src/embed/assets/game.love`, validated that no generated ROM data was present, and confirmed the save editor, launcher UI kit, and Yellow import manifest were packaged. No ROM was used.

## Packaging process

1. Rewrite `gradle.properties` branding/version fields and trim microphone/legacy-storage permissions.
2. Validate the Yellow ROM extraction manifest by expected ROM SHA-1 metadata. The manifest is extraction metadata, not ROM data.
3. ZIP application Lua/assets/tools/manifests into `game.love` while excluding `data/generated`, `assets/generated`, Git metadata and desktop metadata.
4. Gate the archive against generated ROM data and verify required launcher/save-editor/manifest entries.
5. Optionally stamp an `X.Y.Z` engine version into the archive copy only.
6. Build love-android's embedded, no-recording debug APK with Gradle/ndk-build.
7. Copy the resulting APK to `dist/android/debug`.

## Build reproduction status

**PASS.** After the user accepted Google's Android SDK license, a portable toolchain was installed in the workspace and the unmodified stock APK was compiled successfully. Installed components:

```text
platforms;android-34
build-tools;34.0.0
platform-tools
ndk;25.2.9519653
```

Host JDK: Microsoft OpenJDK `17.0.20+8`. Google command-line tools archive: `commandlinetools-win-15859902_latest.zip`, verified against Google's published SHA-256 `90ae805d20434428bffcb699c290860f19bb5f66a67e6b330067e3de801fb04a`.

The successful native build used a temporary `Q:` mapping of the workspace so Gradle and ndk-build saw space-free source and SDK paths:

```bat
subst Q: C:\Users\I5 Gaming\Documents\Codex\2026-08-09\referenced-chatgpt-conversation-this-is-an
set JAVA_HOME=Q:\work\toolchain\jdk\jdk-17.0.20+8
set ANDROID_SDK_ROOT=Q:\work\toolchain\android-sdk
Q:
cd \work\gen1recomp\mobile\android
gradlew.bat --no-daemon assembleEmbedNoRecordDebug
```

Result: `BUILD SUCCESSFUL in 7m 22s` (56 tasks). Warnings were deprecations and warnings from vendored SDL/LÖVE third-party sources; no source modification was required.

APK verification:

| Property | Verified value |
|---|---|
| Filename | `app-embed-noRecord-debug.apk` |
| Size | 21,751,653 bytes |
| SHA-256 | `df7fb9aa4f49b636c56e2f64a5c9eec4c2cf592c70c0060ff91139a863f432ea` |
| Package | `com.theboisclub.pokemonred` |
| Version | `11.5a` / code 32 |
| minSdk / targetSdk / compileSdk | 16 / 34 / 34 |
| GLES declaration | OpenGL ES 2.0 (`0x20000`) |
| Native ABIs in APK | `arm64-v8a`, `armeabi-v7a`, `x86_64` |
| ARM64 libraries | `liblove.so`, `libopenal.so`, `libmpg123.so`, `libc++_shared.so` |
| Embedded payload | `assets/game.love` present |
| Signing | Valid debug signing; APK Signature Scheme v1 and v2 verified |

This is a stock Android debug APK, not a Quest/OpenXR APK. Its successful ARM64 build establishes the required pre-XR baseline.

## First Quest build seam

A separate `quest` Android product flavor now inherits the ROM-free embedded
payload while raising only that flavor's `minSdk` to 24. It depends on Khronos'
official `openxr_loader_for_android:1.1.60` AAR; the stock `embed` flavor does
not. A small JNI bridge, linked into the existing `liblove.so`, exposes the
Java VM, Activity/application context, and current EGL display/context/config
needed by an Android OpenXR backend. No rendering loop or speculative engine
rewrite is included in this milestone.

Reproduction command:

```bat
gradlew.bat --no-daemon :love:externalNativeBuildEmbedDebug assembleQuestNoRecordDebug assembleEmbedNoRecordDebug --rerun-tasks
```

Both variants passed in the same invocation. Verification results:

| Variant | ARM64 LÖVE | ARM64 OpenXR loader | Size | SHA-256 |
|---|---:|---:|---:|---|
| Quest debug | yes | yes | 52,652,180 bytes | `a808aa05d52fa813f8cac0c86118dae39baa46122aeffe745a28bbd17b2f6866` |
| Stock embed debug | yes | no | 21,753,987 bytes | `33d9954ef933efa2f1f9f62c3ec09cc6c040c8a1a776be8d636016840086be38` |

The ARM64 `liblove.so` dynamic symbol table was also checked for all six bridge
exports, including the JNI Activity setter and the EGL/context accessors.

## Quest package handoff

The Quest manifest merge was validated after adding the required VR
head-tracking feature and Quest launcher category. The merged manifest also
contains the OpenXR runtime broker permission/queries contributed by the
Khronos loader AAR.

The Android backend is maintained on the Dramatic Shape `quest-openxr` branch
at commit `80f2251`. It keeps the Windows DLL/WGL path intact and adds Android
loader initialization, `XR_KHR_android_create_instance`,
`XR_KHR_opengl_es_enable`, EGL graphics binding, and OpenGL ES swapchain image
handling. All modified Lua files passed a Lua 5.1 syntax parse (with the
existing LuaJIT `LL`/`ULL` numeric suffixes normalized for that parser).

Final handoff artifacts:

| Artifact | Size | SHA-256 |
|---|---:|---|
| `gen1recomp-quest-openxr-debug.apk` | 52,654,343 bytes | `cc2957ff2864a9efc27ea54a79b6ac61da777d9b77e7378310bfad111111b227` |
| `DRAMATIC_SHAPE-1.8.2-quest-openxr.zip` | 8,363,093 bytes | `60d6a32e103f610e49f5c8c54ff8bc6c9445d44bd9fff3b594e1d321cc95494a` |

The mod remains a separate importable ZIP by design. This preserves the stock
Android mod installer and avoids fusing writable mod state into `game.love`.
The APK and mod contain no Pokémon ROM or generated ROM data.

Physical Quest validation is pending. `adb devices -l` successfully started
the Android debug bridge but reported no attached device. The next step
requires a Quest 3 with developer mode enabled, a data-capable USB cable, and
the in-headset USB debugging authorization accepted.

## Known host-specific issue investigated

The checkout path contains spaces. `scripts/build_android.sh` already handles this for ndk-build by making an incremental, space-free shadow copy with `rsync`. The packaging step itself works from the spaced source path. On this managed Windows workspace, Unix directory creation was restricted even where files were writable; existing directories and small local wrappers were used only to reproduce packaging. This is an execution-environment constraint, not a source defect.

## Current Quest device workspace

The active Quest checkout was copied to `E:\Gen1QuestVR\gen1recomp` to keep
continuing source and build output on the selected drive. The earlier `F:`
checkout was not deleted. Current device-debug milestones and evidence are in
`QUEST_DEBUG_LOG.md`.

Milestone `05c1d77` is a local commit on `quest-openxr`; it has not been pushed
to the configured upstream remote. The current installable APK is emitted under
`app/build/outputs/apk/questVrNoRecord/debug/` and must be installed with
`adb install -t -r`. Do not use the similarly named file under
`app/build/intermediates/apk/`: Gradle can leave that older intermediate in
place after the final `outputs` APK has changed.

## Quest Touch and gameplay-session handoff build

The controller/gameplay milestone uses the same ARM64-only debug command:

```powershell
$env:JAVA_HOME='E:\Gen1QuestVR\jdk-17.0.20+8'
$env:ANDROID_HOME='F:\CodexProjects\Gen1RecompQuest3-work\toolchain\android-sdk'
$env:ANDROID_SDK_ROOT=$env:ANDROID_HOME
$env:GRADLE_USER_HOME='F:\CodexProjects\Gen1RecompQuest3-work\toolchain\.gradle'
Set-Location E:\Gen1QuestVR\gen1recomp\mobile\android
.\gradlew.bat --no-daemon '-Pandroid.injected.build.abi=arm64-v8a' assembleQuestVrNoRecordDebug
```

Before Gradle, Lua changes must be written into
`app/src/embed/assets/game.love`. This build also places the matched Dramatic
Shape `lib/VRXR.lua` transport in that payload. At Android startup it refreshes
only the installed mod's VR transport so the native launcher bridge and mod
use the same handoff contract. The mod remains separately installed and its
manifest/assets/settings remain outside the APK.

Relevant versions and packaging properties remain:

| Property | Value |
|---|---|
| Build variant | `questVrNoRecordDebug` |
| Injected ABI | `arm64-v8a` |
| Java | Temurin/OpenJDK 17.0.20+8 |
| Android SDK | Existing command-line SDK on `F:` |
| NDK | 25.2.9519653 |
| Gradle | Wrapper 8.1 |
| compileSdk / targetSdk | 34 / 34 |
| Quest minSdk | 24 |
| XR graphics API | OpenGL ES via EGL and `XR_KHR_opengl_es_enable` |
| XR runtime | Khronos Android OpenXR loader 1.1.60 / Meta runtime |

The launcher session uses a private GLES context for its quad. On gameplay
start it fully releases its session, swapchain, spaces, and instance. Dramatic
Shape then creates the gameplay session against LÖVE's EGL/GLES context. A
second simultaneous session is not supported by this design.

Physical Quest verification on 2026-08-09:

- Touch input selected and launched Yellow.
- Yellow displayed its main menu.
- Continuing entered Dramatic Shape voxel rendering.
- Subsequent verification resolved launcher focus visibility, controller
  oscillation, room anchoring/recenter, and Pokédex left-edge alignment.
- Overexposure was a Dramatic Shape color-mode setting, not a renderer defect.
- Open defects are intermittent immersive-loading startup, suspend/resume
  lifecycle crashes, slow first load, and an unconfirmed distant-building
  observation. See `QUEST_DEBUG_LOG.md`.

## Current Windows packaging fallback

The canonical source packaging command remains:

```powershell
$env:PYTHONUTF8='1'
& 'C:\Program Files\Git\bin\bash.exe' scripts/build_android.sh --package-only
```

On this host, Git Bash has no `zip` executable. For the current development
build a clean staging tree was assembled from the same audited payload list and
archived with JDK 17 `jar`. Both `data/generated` and `assets/generated` were
excluded and archive inspection returned no generated-data entries. Only the
three matched Dramatic Shape Quest transport files (`VRXR.lua`, `VR.lua`, and
`VRGL.lua`) are embedded for startup refresh; user ROMs, saves, mod manifests,
settings, and assets remain external.

## 2026-08-11 Gen 2 priority baseline

Upstream Gen 2 commit `ae6cac89` was merged on isolated branch `quest-gen2`.
The Windows-safe clean-stage/JDK `jar` fallback packed the stock source set,
including `tools/rom_manifest_gold.json`, while excluding both generated-data
trees. The full canonical build command was used without ABI injection:

```powershell
$env:JAVA_HOME='E:\Gen1QuestVR\jdk-17.0.20+8'
$env:ANDROID_SDK_ROOT='F:\CodexProjects\Gen1RecompQuest3-work\toolchain\android-sdk'
$env:ANDROID_HOME=$env:ANDROID_SDK_ROOT
$env:GRADLE_USER_HOME='F:\CodexProjects\Gen1RecompQuest3-work\toolchain\.gradle'
Set-Location E:\Gen1QuestVR\gen1recomp\mobile\android
.\gradlew.bat --no-daemon assembleQuestVrNoRecordDebug
```

Gradle completed 58 tasks successfully in 19 seconds. The resulting APK is
61,646,052 bytes with SHA-256
`A5D42655FDBA228AC480FF10625EC5DEEA20FCE69B71C2845FB44A6E2942E6C9`.
Its embedded payload exactly matches SHA-256
`7CFA91CA26F7DD6CBC563E63595881F0998DDE4547844B9E84A4A062596C3AB5`.
APK v2 signing passed. ARM64-v8a, armeabi-v7a, and x86_64 `liblove.so` builds
are present, and the OpenXR loader is packaged for those ABIs (plus its AAR's
x86 loader). No generated ROM/cache entry is present.

## 2026-08-12 official v0.1.79 Quest integration build

Official tag `v0.1.79` (`04490c9b`) was merged without conflicts on isolated
branch `quest-gen2-beta-v0.1.79`. A clean payload excluded `data/generated`
and `assets/generated`. The canonical build command was:

```powershell
$env:JAVA_HOME='E:\Gen1QuestVR\jdk-17.0.20+8'
$env:ANDROID_SDK_ROOT='E:\Gen1QuestVR\android-sdk'
$env:ANDROID_HOME=$env:ANDROID_SDK_ROOT
$env:GRADLE_USER_HOME='E:\Gen1QuestVR\.gradle'
Set-Location E:\Gen1QuestVR\gen1recomp\mobile\android
.\gradlew.bat --no-daemon assembleQuestVrNoRecordDebug --rerun-tasks
```

All 58 tasks passed. The 58,613,359-byte APK has SHA-256
`813418E5C48D66EB2EB6E5D60CDDCEDF1D21317734F1A98B6F1EA262278D7867`.
Its embedded `game.love` exactly matches staged payload SHA-256
`5F1610A7909E650BBF2C6DF25D2EED00C2DC7FFA3ACD70F52FA2623ADC1972CC`.
Inspection confirmed the ARM64 OpenXR loader, v0.1.79 `DateTime.lua`, Quest
Dramaless integration and Gold manifest, with no generated ROM-data trees.

### Promoted full-color loader build

The physically approved presentation rebuild embeds the full-color VR
Unplugged logo and bright GBC loading-card palette without changing preload or
XR logic. Final APK SHA-256 is
`A25CA14F5354E0815461C76593C3227DDD17281C05BD3ECC35E61877D7275039`;
embedded `game.love` SHA-256 is
`C44A77CE8F4F2FD948A5CF6445213D1A811A7FB12D1CD93C1785FC56DFB5412D`.
Archive inspection found no `data/generated` or `assets/generated` entries.

## 2026-08-12 clean PR 5 stock/Quest comparison

The isolated upstream backend candidate was built from
`E:\Gen1QuestVR\upstream-pr5-quest-backend` at `4e16cd77`. Before the final
build, the Android variant API was used to replace rather than merge the Quest
native ABI set; Gradle dry-run output then contained only ARM64 Quest native
tasks.

The canonical ROM-free payload was produced first with:

```powershell
$env:PYTHONUTF8='1'
& 'C:\Program Files\Git\bin\bash.exe' scripts/build_android.sh --package-only
```

On this Windows host, temporary untracked Python and `zip` command wrappers
were needed for Git Bash. The Python wrapper selected the installed interpreter
instead of the disabled Windows Store shim, and the `zip` wrapper called the
installed 7-Zip binary. Both were deleted after packaging.

The final clean build used:

```powershell
$env:JAVA_HOME='F:\CodexProjects\Gen1RecompQuest3-work\toolchain\jdk\jdk-17.0.20+8'
$env:ANDROID_SDK_ROOT='F:\CodexProjects\Gen1RecompQuest3-work\toolchain\android-sdk'
$env:ANDROID_HOME=$env:ANDROID_SDK_ROOT
$env:GRADLE_USER_HOME='F:\CodexProjects\Gen1RecompQuest3-work\toolchain\.gradle'
Set-Location E:\Gen1QuestVR\upstream-pr5-quest-backend\mobile\android
.\gradlew.bat --no-daemon clean assembleEmbedNoRecordDebug assembleQuestVrNoRecordDebug --console=plain
```

Result: `BUILD SUCCESSFUL in 11m 28s`, 119 tasks, with 118 executed and one
up-to-date. The SDK metadata warning and vendored SDL/LÖVE compiler warnings
were non-fatal; there was no Java, Lua, native compile, or link failure.

| Property | Stock `embedNoRecordDebug` | Quest `questVrNoRecordDebug` |
|---|---|---|
| APK size | 22,984,342 bytes | 24,028,171 bytes |
| APK SHA-256 | `F03F2708108540186CD53A9F1126953F0F020EF06F9CD26A30B0A80A428F7FFD` | `32B762518036DE87C283DA6AD1870CEF74C585B0972EBFB967C4E9B224AF88F0` |
| minSdk / targetSdk | 16 / 34 | 24 / 34 |
| Activity | stock `GameActivity` | flavor-only `QuestGameActivity` |
| Native ABIs | ARM64, ARMv7, x86_64 | ARM64 only |
| Quest libraries | none | `libopenxr_loader.so`, `libquestxr.so` |
| Graphics path | stock SDL/EGL/GLES | SDL/EGL/GLES plus OpenXR GLES swapchains |

Both archives contain the identical 4,278,077-byte `assets/game.love` with
SHA-256
`023D8BF58D09100E943160BAE8DDB16DB3CE3974053DB7D010AF7C1E0FF0B4CB`.
Inspection found 499 payload entries, the required Yellow and Gold importer
manifests, and zero generated data, ROM/save files, or bundled mods.

The Quest manifest contains the OpenXR runtime-broker declarations, headtracking
feature, and Oculus VR launcher category. Its native archive contains only
ARM64 `libc++_shared`, LÖVE, mpg123, OpenAL, Khronos OpenXR loader, and
`libquestxr`. ELF inspection verified `libquestxr.so` as AArch64 and confirmed
that stock and Quest `liblove.so` export no Quest/OpenXR surface.

The final local artifacts remain under each variant's canonical
`mobile/android/app/build/outputs/apk/.../debug/` directory. An identical Quest
copy is preserved at
`E:\Gen1QuestVR\artifacts\upstream-pr5-4e16cd77\Gen1Recomp-Quest-PR5-4e16cd77-debug.apk`;
its size and SHA-256 were rechecked after copying. These are local debug builds,
not release artifacts. Physical installation is pending because
`adb devices -l` currently reports no connected headset.

## 2026-08-12 physically validated PR 5 pointer/handoff APK

The follow-up build at engine commit `f9e8088b` used the same JDK, SDK, NDK,
Gradle home, ARM64-only `questVrNoRecordDebug` flavor, and canonical output
path described above. The focused incremental command was:

```powershell
$env:JAVA_HOME='F:\CodexProjects\Gen1RecompQuest3-work\toolchain\jdk\jdk-17.0.20+8'
$env:ANDROID_HOME='F:\CodexProjects\Gen1RecompQuest3-work\toolchain\android-sdk'
$env:ANDROID_SDK_ROOT=$env:ANDROID_HOME
$env:GRADLE_USER_HOME='F:\CodexProjects\Gen1RecompQuest3-work\toolchain\.gradle'
Set-Location E:\Gen1QuestVR\upstream-pr5-quest-backend\mobile\android
.\gradlew.bat :app:assembleQuestVrNoRecordDebug
```

Gradle completed 54 tasks successfully in 27 seconds. The APK SHA-256 is
`7BE8565B7C7344D83954ACD79139FB8F1D37E65CD245F83F035AAEE928F6EF23`.
It was installed with `adb install -r`, preserving app data. The paired
Dramaless q14 ZIP SHA-256 is
`1588EFCBE4985AD220D26F70BFA01AFBD80A35BD82E92FFFDAA6E92809CACC67`.

Quest 3 physical testing confirmed a live room-anchored launcher, controller
ray selection, pointer removal at Yellow handoff, the restored save-aware
loading card, clean launcher session release, automatic gameplay OpenXR
startup, and a FOCUSED immersive voxel session. Longer lifecycle/quit soak is
still required before a release build.

### 2026-08-12 current-build lifecycle probe

A controlled Quest Home/background test was run against the same installed
`f9e8088b`/q14 candidate. The running process was PID `8995` before the test,
remained PID `8995` after more than 60 seconds away from the app, and resumed
as `org.love2d.android.QuestGameActivity`. Logcat contained no `FORTIFY`,
destroyed-mutex, `SIGABRT`, or app-process-death event.

The historical `AudioTrack` crash is therefore not reproduced by this first
current-build probe. Its saved evidence came from the former
`org.love2d.android.GameActivity` build: Android moved that activity behind
Quest Home at `02:45:10.531`, issued a duplicate finish at `02:45:10.548`, and
the `AudioTrack` thread aborted at `02:45:11.194`. The current source does not
destroy an audio mutex in the Quest bridge; final host cleanup joins the
QuestXR bootstrap thread before releasing its Android references. Longer and
repeated lifecycle/quit soak remains required. The Android screenshot API
returned an empty capture for the immersive layer, but the user then confirmed
in-headset that the resumed app was back in the immersive voxel world. The
single-cycle background/resume probe therefore passed both process safety and
visual recovery.

A follow-up automated soak ran three additional Quest Home/resume cycles with
10 seconds backgrounded per cycle. Every checkpoint retained PID `8995`.
Logcat recorded exactly three SDL pause and three resume callbacks, zero
activity-destroy callbacks, and zero `FORTIFY`, destroyed-mutex, fatal-signal,
ANR, or app-process-death events. Quest's shell then stopped the temporary SDL
surface after each relaunch while retaining the immersive activity/OpenXR
ownership; final headset-eye and controller-response confirmation is pending.
The user then confirmed that the voxel world remained visible and controller
input responded. The three-cycle soak therefore passed process, activity,
audio, immersive-display, and controller recovery.

### Clean exit and first cold relaunch

The user saved in-game and selected Quest's system **Quit** action. OpenXR
transitioned through `STOPPING` to `IDLE`, SDL destroyed its surface, AAudio
stopped, the QuestXR Android bridge was released, and Android logged
`System.exit called, status: 0` followed by `Process 8995 exited cleanly (0)`.
There was no `FORTIFY`, destroyed-mutex, fatal signal, tombstone, or ANR. The
generic ActivityManager `has died: cch+5 CEM` bookkeeping line is not a crash
in this trace; the explicit zero exit status and absence of a fatal signature
distinguish it from the historical abort.

One shutdown-order observation remains in soak coverage: after `onDestroy`
and bridge release, the AAudio stream briefly received `requestStart` about 10
ms before the native main thread called `System.exit(0)`. It did not fail and
does not justify a speculative fix, but future clean-exit repetitions should
continue checking this interval.

A subsequent cold `am start -W` created fresh PID `12514`. The Quest activity,
SDL JNI, generic `HostDisplay`, QuestXR bootstrap, Touch launcher actions,
launcher OpenXR session, anchored panel, post-present capture, and live panel
generations all initialized successfully. No crash, ANR, OOM, or stuck-start
signature appeared. The user confirmed in-headset that the launcher was visible
and the white controller pointer moved, completing cold-start launcher
acceptance.

The user then selected Yellow, loaded the saved game, observed the colored
preparation path, entered immersive voxel VR, and confirmed gameplay controls
behaved as intended. The same PID `12514` survived the entire
launcher-to-gameplay transition. The launcher handoff was requested at
`23:26:06.865`, its session ended at `23:26:06.884`, Dramaless reported the
launcher session released at `23:26:06.898`, gameplay OpenXR startup completed
at `23:26:06.966`, and the gameplay session reached `FOCUSED` at
`23:26:07.059`. The ownership swap took about 194 ms from request to FOCUSED,
with no fatal, mutex, ANR, OOM, or process-death signature.

## 2026-08-13 q15 Pokedex frame-event build

The q15 engine payload was packed from PR 5 commit `b7fba361`. On Windows the
payload packer required UTF-8 mode because the Yellow manifest contains UTF-8
text:

```powershell
$env:PYTHONUTF8='1'
# Run the existing PR 5 Quest payload-packaging command.
```

The Android build used JDK 17 at `E:\Gen1QuestVR\jdk-17.0.20+8`, Android SDK
API 34 and NDK `25.2.9519653` from
`F:\CodexProjects\Gen1RecompQuest3-work\toolchain\android-sdk`, and Gradle task
`:app:assembleQuestVrNoRecordDebug`. Gradle completed all 54 tasks successfully
in 39 seconds. Inspection confirmed an ARM64-v8a-only APK containing
`libquestxr.so`, `liblove.so`, the generic `render.frame_drawn` event in
`game.love`, and 499 payload entries. It contained no ROM, generated ROM data,
save, `data/generated`, or `assets/generated` entry.

The first locally signed output used a fresh
`E:\Gen1QuestVR\.android-user\debug.keystore`. Android rejected the in-place
update with `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, as expected for a different
signing identity, and preserved the installed app and data. The installed q14
APK was then pulled and verified at SHA-256
`7BE8565B7C7344D83954ACD79139FB8F1D37E65CD245F83F035AAEE928F6EF23`.
Its signing certificate SHA-256 was
`253a30fbc7131d0970800a800a5d77fc49cbc00c8b5e4e9e5dc259854b1c4075`,
matching `C:\Users\I5 Gaming\.android\debug.keystore`.

Re-signing with that existing key produced
`E:\Gen1QuestVR\dist\Gen1Recomp-Quest-PokedexFrameEvent-q15-signed.apk`,
SHA-256
`8342334C3F6ED5D77A64E253FF86EB56355264D6B8CDC43ECEC296E88CBBB84E`.
`adb install -r` then succeeded and preserved app data. The paired imported mod
was `E:\Gen1QuestVR\Dramaless-Quest\dist\DRAMALESS_SHAPE-1.6.4-quest.15.zip`,
SHA-256
`E899C0B36530AC69FCBC8D5469F57FCCD025E0DA082574D61C1A733280E856CC`.
Quest logs confirmed q15 loaded in PID `15729`, and the user physically
confirmed the Pokedex display was restored.

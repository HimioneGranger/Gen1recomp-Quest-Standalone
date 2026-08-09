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
to the configured upstream remote. The ABI-injected APK is emitted under
`app/build/intermediates/apk/questVrNoRecord/debug/` and must be installed with
`adb install -t -r`.

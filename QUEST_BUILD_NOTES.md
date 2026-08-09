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

## Known host-specific issue investigated

The checkout path contains spaces. `scripts/build_android.sh` already handles this for ndk-build by making an incremental, space-free shadow copy with `rsync`. The packaging step itself works from the spaced source path. On this managed Windows workspace, Unix directory creation was restricted even where files were writable; existing directories and small local wrappers were used only to reproduce packaging. This is an execution-environment constraint, not a source defect.

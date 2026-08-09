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

The host initially had neither Java nor an Android SDK/NDK. Full Gradle compilation has therefore not yet run. The required Android SDK components are:

```text
platforms;android-34
build-tools;34.0.0
platform-tools
ndk;25.2.9519653
```

JDK 17 and Android command-line tools can be installed portably. However, installing SDK/NDK packages with `sdkmanager` requires the human SDK license acceptance. That is a genuine user-interaction checkpoint and cannot be recorded as accepted by an automated agent. After acceptance, rerun the stock command above, inspect the APK with `apkanalyzer`/`unzip` for `lib/arm64-v8a`, and record the exact APK filename, size and checksums here before any XR code change.

## Known host-specific issue investigated

The checkout path contains spaces. `scripts/build_android.sh` already handles this for ndk-build by making an incremental, space-free shadow copy with `rsync`. The packaging step itself works from the spaced source path. On this managed Windows workspace, Unix directory creation was restricted even where files were writable; existing directories and small local wrappers were used only to reproduce packaging. This is an execution-environment constraint, not a source defect.

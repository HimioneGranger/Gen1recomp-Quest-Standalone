# Quest release checklist

Use this checklist for every public VR Unplugged APK. It separates code review,
package verification, and headset validation so either partner can take over
without guessing what has already happened.

## 1. Prepare

- [ ] Create `release/<version>` from the current `quest-stable` branch.
- [ ] Merge the intended upstream Gen1Recomp tag and resolve conflicts without
      dropping the packaged Quest display backend or completed-frame hook.
- [ ] Update the version, release notes, README download name, and launcher
      branding.
- [ ] Confirm `git status` contains no ROM, save, generated cache, signing key,
      or unrelated local experiment.

Package the ROM-free payload:

```sh
scripts/build_android.sh --version X.Y.Z --package-only
```

Build the ARM64 Quest release variant:

```sh
cd mobile/android
./gradlew :app:assembleQuestVrNoRecordRelease
```

The Gradle output is unsigned. Align and sign it with the existing
upgrade-compatible project key. Store that key outside the repository and
never paste its password into an issue, pull request, workflow log, or chat.

## 2. Verify the APK

- [ ] Package is `com.theboisclub.pokemonred`.
- [ ] Version name and code match the release.
- [ ] Label is `Gen1Recomp VR Unplugged` and the current logo is present.
- [ ] Minimum SDK is 24 and the only native ABI is `arm64-v8a`.
- [ ] `libquestxr.so` and `libopenxr_loader.so` are present.
- [ ] `assets/game.love` reports the release engine version.
- [ ] No `.gb`, `.gbc`, `.sav`, `.srm`, `data/generated`, or
      `assets/generated` content is present.
- [ ] `apksigner verify --verbose --print-certs` passes and the certificate
      matches the previous public APK.
- [ ] Record the final APK SHA-256 in the release notes.

## 3. Physical Quest 3 smoke test

- [ ] Install with `adb install -r`; existing app data is retained.
- [ ] Launcher is upright, room-anchored, readable, and responsive.
- [ ] Both Touch controllers can point, select a game, and open launcher tabs.
- [ ] Import works with a supported user-provided ROM.
- [ ] Vanilla gameplay starts and returns/ends cleanly.
- [ ] A current Quest gameplay mod completes launcher-to-gameplay OpenXR
      handoff and reaches a focused stereo session.
- [ ] Suspend/resume, controller sleep/wake, and quit show no crash or stuck
      OpenXR session.
- [ ] Capture the tested refresh rate, graphics preset, FPS/frame time, and any
      visible hitching in the release pull request.

Use `docs/quest-openxr-backend.md` for the validated backend boundaries and
known lifecycle risks.

## 4. Publish

- [ ] The release pull request is approved and all required checks are green.
- [ ] Tag the exact reviewed commit as `vX.Y.Z-quest`.
- [ ] Upload one APK named
      `Gen1Recomp-VR-Unplugged-vX.Y.Z-Quest.apk`.
- [ ] Release notes identify supported hardware, known limitations, install
      steps, SHA-256, and the ROM-free/legal boundary.
- [ ] Test the public README download link in a signed-out browser.
- [ ] Have the second partner install the public asset before announcing it.

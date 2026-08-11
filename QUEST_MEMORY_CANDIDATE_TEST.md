# Quest memory candidate — physical validation

Candidate source commits:

- `d52f780` — eagerly release superseded Quest capture/mirror canvases;
- `2e08cfd` — release the extra previous mesh neighbourhood after seamless
  route/town crossings and Fly, while preserving warm door/interior returns.

Candidate APK:

`mobile/android/app/build/outputs/apk/questVrNoRecord/debug/app-questVr-noRecord-debug.apk`

- bytes: `52,815,428`
- SHA-256: `B013F36302DE4BB0DD82317C4E99C80B25EE53F06BD4634863DD5DB4236E2DDA`
- embedded `game.love` SHA-256:
  `E6770E0AC9EE0F747591795DFC842168D17D06608F0CFF543CD86CB7028C965D`

The build passed APK Signature Scheme v2 verification. Its 367-entry LÖVE
payload contains no `data/generated/` or `assets/generated/` paths. The
candidate has not been installed because the headset was shut down.

## One ordinary-play validation loop

There is no special loading-screen wait in this test.

1. Charge the Quest, connect its data cable, accept USB debugging, and confirm
   it appears under `adb devices -l`.
2. Install only the canonical output above:

   `adb install -t -r E:\Gen1QuestVR\gen1recomp\mobile\android\app\build\outputs\apk\questVrNoRecord\debug\app-questVr-noRecord-debug.apk`

   `-r` preserves the app data, imported ROM caches, saves, and writable mods.
3. Start the same accepted stack: Dramaless Shape 1.6.4, Kanto First Person,
   Wilds of Kanto 1.12.1, Wild Skies 1.6.3, and Crystal 251 0.10.1. Leave
   Dramatic Sky Ride disabled. Add the separate sprite-provider ZIPs only when
   testing their visuals; they are not inside this APK.
4. Play normally from Route 8 through Lavender to Route 12. A seamless map
   crossing should log `VRMEM released previous mesh set via=connection`.
   Confirm no terrain disappears or flashes at either seam.
5. Enter Pokémon Tower and immediately leave. Ordinary door warps should not
   log that `VRMEM` release and the outdoor return should remain warm—this is
   the immersion behavior deliberately preserved.
6. Open and close the Pokédex, enter one battle, and open/close the Pokédex or
   party UI again. Confirm the Pokédex framing, game speed, head tracking, and
   all controls remain normal.
7. Continue for 10–15 minutes across at least two more route/town seams. The
   test is useful as normal play; no stationary loading-screen loop is needed.

## Capture after the loop

Run these before force-stopping the app:

`adb shell dumpsys meminfo com.theboisclub.pokemonred`

`adb logcat -d | findstr /C:"VRMEM" /C:"PERF10" /C:"Pokedex capture" /C:"FATAL EXCEPTION" /C:"OutOfMemory"`

Pass conditions:

- normal stereo/OpenXR presentation and controls;
- no missing terrain or new flat fallback at seamless crossings;
- warm Pokémon Tower exit remains intact;
- Pokédex and battle framing remain correct;
- no crash, ANR, OOM, Lua error, or persistent 2× game-speed state;
- `VRMEM` appears for route/town seams (and Fly if exercised), not ordinary
  door/interior warps;
- graphics/total PSS and `PERF10 tex=` settle instead of rising after every
  repeated UI/state transition. Compare against the prior 2,310,408 KB total
  PSS / 893,764 KB Graphics stress sample, but treat one run as directional
  evidence rather than an absolute threshold.

Physical headset validation is the only remaining gate for these two commits.

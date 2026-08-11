# Quest regional-streaming candidate — physical validation

Source commit: `bc2e2092` (`quest: bound regional streaming warmup`)

Canonical APK:

`mobile/android/app/build/outputs/apk/questVrNoRecord/debug/app-questVr-noRecord-debug.apk`

- bytes: `58,384,739`
- SHA-256: `71021D8979CDF15149BD214BD3CB709568B759F4C1A8479ED71F18A91F2CD809`
- embedded `game.love` SHA-256:
  `E1D0AD04E2525FD8C25894437D54D0DA8EE50EAB19783E39469EFB4265A5D9F6`
- stamped engine: `0.1.78`

The APK passed Android APK Signature Scheme v2 verification. Its LÖVE payload
contains the Gen 2 beta, the bounded-streaming policy, and the independent
Dramaless lifetime adapter. It contains no generated ROM data or ROM binaries.

## What changed

- Regional warmup is limited to one connection hop and six maps total.
- Only one nearby map receives the expensive full chunk warmup.
- A major connection is eligible for proactive warmup only within 512 world
  pixels (about 32 walking cells).
- The mesh-lifetime adapter is applied independently of the indexed-sink
  adapter, so an indexed rendering mismatch cannot silently disable history,
  body-release, or warm-live APIs.
- Seamless route/town crossings and Fly discard the superseded mesh set. Door
  and interior warps retain it for a warm return.

## Short headset test

There is no need to watch or wait on the loading screen for this test.

1. Install the APK with `adb install -t -r <apk>`. The `-r` flag preserves app
   data, imported ROM caches, saves, and launcher-managed mods.
2. Launch normally. Keep the launcher-updated HGSS Visual Overhaul 0.2.5 and
   the usual Crystal 251, Dramaless Shape, Kanto First Person, Wilds of Kanto,
   and Wild Skies stack enabled.
3. Load the Saffron save. Confirm the Pokédex, game speed, tracking, and
   controls are normal before walking.
4. Walk east from Saffron through the gate to Route 8, then continue into
   Lavender. A brief one-time warmup is acceptable; sustained stuttering is
   not.
5. In Lavender, turn around once and cross back toward Route 8 if battery and
   time permit. Then leave the game running and collect the capture below.

## Expected log evidence

At VR startup:

`VRSTREAM policy hops=1 cap=6 majorDistance=512 historyAPI=true bodyAPI=true warmAPI=true`

The Saffron preload should report no more than six required maps. The previous
build required 12 and took 50.86 seconds in the profiled Saffron session.

The Route 8/Lavender outdoor seam should report:

`VRMEM released previous mesh set via=connection`

The Saffron gate door warp should not release the previous set. Once the player
is in Lavender, distant Saffron should no longer receive proactive major-map
warmup.

Capture before force-stopping:

`adb shell dumpsys meminfo com.theboisclub.pokemonred`

`adb logcat -d | findstr /C:"VRSTREAM" /C:"VRPRELOAD" /C:"VRMEM" /C:"PERF10" /C:"FATAL EXCEPTION" /C:"OutOfMemory"`

For comparison, the previous HGSS-enabled Route 8/Lavender run reached
2,047,616 KB total PSS and 787,984 KB Graphics, with no OOM or thermal
throttling. This candidate should reduce startup work and stop retaining every
previous outdoor region; one short run is directional evidence rather than an
absolute memory threshold.

Physical headset validation is the remaining gate.

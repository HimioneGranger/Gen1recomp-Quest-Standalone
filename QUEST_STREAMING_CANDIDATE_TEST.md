# Quest Gen 2 streaming/launcher candidate — physical validation

Source tip: `287879a4` (`quest: restore left-stick launcher navigation`)

The candidate includes the bounded-streaming work beginning at `bc2e2092`, the
atomic Quest payload/transport refresh at `2aa5253e`, and the left-stick-only
launcher correction at `287879a4`.

Canonical APK:

`mobile/android/app/build/outputs/apk/questVrNoRecord/debug/app-questVr-noRecord-debug.apk`

- bytes: `58,594,071`
- SHA-256: `EC7167DC0EEABA0D2BDA01DD8083B325166B85F9C48C1854AEF02E2F09403027`
- embedded `game.love` SHA-256:
  `260D9C464BBDFAF4C7F0CF8E029BF6B7BAA3170E20B2A4237467DB16D3E4499C`
- stamped engine: `0.1.78`

The APK passed Android APK Signature Scheme v2 verification. Its LÖVE payload
contains the Gen 2 beta, the bounded-streaming policy, the current Quest
launcher/conductor seams, `lib/VRXR.lua`, and `lib/VRGL.lua`. It contains no
generated ROM data, ROM binaries, saves, or mod artwork.

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
- Quest startup refreshes the current conductor and mesher adapters even when
  an optional packaged transport is absent. This fixes the stale writable
  conductor that kept showing the old 12-map warmup.
- Launcher direction edges and gameplay held movement both use the left Touch
  thumbstick. The right stick remains reserved for VR camera control.
- The temporary Quest-only thick yellow pointer experiment was removed; the
  launcher retains its existing appearance.

## Short headset test

1. Install with `adb install -t -r <apk>`. The `-r` flag preserves app data,
   imported ROM caches, saves, and launcher-managed mods. The exact candidate
   above was installed successfully on Quest 3 `2G0YC1ZFB608RH`.
2. Launch normally. Keep HGSS Visual Overhaul 0.3.0 and the usual Crystal 251,
   Dramaless Shape, Kanto First Person, Wilds of Kanto, and Wild Skies stack
   enabled.
3. On the launcher, move the **left** stick in all four directions and confirm
   that the focused tab/control changes. The right stick must not navigate the
   menu. Move down to the Gold ROM row and confirm with A.
4. Load the Saffron save. Confirm the Pokédex, game speed, tracking, and
   controls are normal before walking.
5. Walk east from Saffron through the gate to Route 8, then continue into
   Lavender. A brief one-time warmup is acceptable; sustained stuttering is
   not.
6. In Lavender, turn around once and cross back toward Route 8 if battery and
   time permit. Then leave the game running and collect the capture below.

## Expected evidence

At VR startup:

`VRSTREAM policy hops=1 cap=6 majorDistance=512 historyAPI=true bodyAPI=true warmAPI=true`

The Saffron preload should report no more than six required maps. The first
physical run displayed five stages, replacing the stale 12-stage load. The old
12-map build took 50.86 seconds in the profiled Saffron session.

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

Physical headset validation of left-stick launcher navigation and game handoff
is the remaining gate.

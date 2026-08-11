# Gen1Recomp Quest Standalone — Project Status

Last updated: 2026-08-09

Published repository:
`https://github.com/HimioneGranger/Gen1recomp-Quest-Standalone`

## Goal and legal boundary

This branch ports Gen1Recomp plus the separately installed Dramatic Shape
voxel mod to a native Android ARM64 APK for Meta Quest 3. The target is
standalone OpenXR play with no Windows PC, SteamVR, Link, Virtual Desktop, or
PC present while playing.

The repository and APK contain no Pokémon ROM, extracted ROM cache, save, or
commercial game asset. The existing importer remains the only supported path:
the player supplies a legally obtained canonical ROM, which Gen1Recomp
verifies before generating private app data on the device.

## Repository layout and branches

- Gen1Recomp checkout: `E:\Gen1QuestVR\gen1recomp`
- Gen1Recomp branch: `quest-openxr`, based on upstream `dev`
- Dramatic Shape checkout: `E:\Gen1QuestVR\DramaticShapeVoxelMod`
- Dramatic Shape branch: `quest-openxr`, based on upstream `master`
- Quest work is isolated from the upstream desktop and stock Android paths.

The Dramatic Shape source remains a separate repository. The Quest APK carries
only matched integration source files (`VRXR.lua`, `VR.lua`, `VRGL.lua`, the
indexed `ChunkMesher.lua`, and current Quest policy candidates) so an already
installed copy of the mod can use the Quest backend. It does not bundle the
mod's assets or user configuration.

For the user-owned standalone GitHub repository, the two independent histories
are published as separate branches rather than combining upstream projects or
vendoring one into the other:

- `quest-openxr` — Gen1Recomp Quest application and documentation
- `dramatic-shape-quest-openxr` — Dramatic Shape Quest backend

The original upstream `origin` remotes remain unchanged in both checkouts.

## Current working-tree state

- Last pushed Gen1Recomp milestone: `89974f6`; last pushed Dramatic Shape
  milestone: `901f739`.
- Gen1Recomp currently has uncommitted documentation, launcher confirmation,
  panel-bridge deployment, and atomic native panel/focus capture changes.
- Dramatic Shape currently has uncommitted Quest-default Forest FX and targeted
  Indigo Plateau/Route 23 policy candidates. The Indigo behavior has not been
  exercised at Indigo Plateau and must not be described or committed as
  device-verified.
- The installed APK is a development test build containing those candidates.
  No post-`89974f6`/`901f739` changes have been pushed.

## Completed milestones

1. Audited Gen1Recomp, LÖVE/LuaJIT, love-android, SDL/EGL/GLES, native loading,
   Android packaging, Dramatic Shape's Win32/OpenGL/OpenXR path, and platform
   replacement requirements.
2. Reproduced the stock Android build before XR changes and documented the
   SDK, NDK, Gradle, ABI, API levels, graphics path, and packaging commands.
3. Added a separate Quest Android flavor with official Khronos Android OpenXR
   loader integration, Quest manifest metadata, and ARM64 packaging.
4. Created an Activity-started native OpenXR bootstrap so Meta's immersive
   loading environment receives frames before Lua/mod startup.
5. Displayed the existing launcher in a stereoscopic OpenXR quad without
   replacing its ROM/mod import workflow.
6. Replaced full-resolution screenshots with fixed 1024x768 double buffers,
   preventing the observed Android low-memory kill.
7. Eliminated panel flashing by copying through a persistent GLES texture and
   rejecting genuinely empty SDL transition frames.
8. Added OpenXR Touch actions and a thread-safe native-to-Lua event bridge.
   Either stick navigates; A/X/triggers select; B/Y go back.
9. Added an explicit OpenXR ownership handoff: the launcher destroys its
   session and resources, then Dramatic Shape creates the gameplay session
   against LÖVE's EGL/GLES context.
10. Verified physically on Quest 3 that Touch input launches Yellow, Yellow's
    main menu displays, and continuing enters Dramatic Shape voxel rendering.

## Current device-verified behavior

- The APK installs and launches as an immersive Quest application.
- The floating launcher is visible in both eyes, stable, and non-flashing.
- The launcher is room-anchored after startup. Quest Meta-button recenter
  repositions it ahead, and yaw-only anchoring prevents permanent head tilt.
- Touch controller events reach the existing launcher input handlers and can
  launch the imported Yellow ROM.
- A thin green native OpenXR focus border was previously verified steady and
  responsive, but later Mods-navigation testing exposed that it could advance
  over a stale captured launcher image. The current atomic image/focus update
  candidate is installed and awaiting device verification.
- Yellow displays its main menu and transitions into voxel gameplay.
- A/X, B/Y, triggers/Start, and left-stick movement are device-verified.
- The launcher-to-gameplay OpenXR session handoff succeeds.
- The process no longer reproduces the earlier launcher memory kill.
- The first-person Pokédex screen is readable and its left-edge misalignment
  has been physically verified fixed.

## Open defects

- The native launcher now uses an explicit 1024x768 LÖVE Canvas as the shared
  Android/OpenXR capture source. Physical testing confirmed an upright, stable
  launcher with an aligned movable green focus ring and every on-screen button
  selectable. This replaces the stale default-framebuffer capture path for the
  launcher while preserving the normal post-present path for other panels.
- Intermittently after install, restart, or sleep, the app remains on Quest's
  immersive loading screen with no OpenXR controller events. A force-stop and
  relaunch usually recovers. This is the current highest-priority defect.
- Sleep/background lifecycle has produced destroyed-mutex and AudioTrack abort
  logs and needs a deliberate suspend/resume fix.
- Initial Yellow/mod/voxel loading is visibly slow and is awaiting a timed
  device profile to separate asset, shader, and map-mesh work.
- Quest video evidence shows a 2D-to-partial-to-complete voxel population
  sequence. Current Dramatic Shape already builds meshes cooperatively; the
  leading improvement candidate is a new persistent disk mesh cache.
- Some distant buildings were missing during the first verified voxel test.
- Possible stereo/world offset in first person still needs a controlled
  two-eye validation; screenshots alone are left-eye views.
- Performance, thermals, long-session stability, save/load, suspend/resume,
  and broad map coverage have not yet passed a release test matrix.

## Low-priority polish

- Pokédex sizing and framing: the current symmetric 1% horizontal crop is
  device-accepted, centered, and keeps the menu selector arrow visible. Defer
  any further bezel, scale, or per-screen alignment tuning unless it blocks
  gameplay or hides required UI.

## Key local commits

Gen1Recomp `quest-openxr`:

- `271193c` — Phase 1 architecture audit
- `9e45b75` — stock Android baseline
- `ae2a8cb` — native Quest OpenXR bootstrap layer
- `c5668e0` — live launcher fixed-buffer bridge
- `05c1d77` — stable non-flashing launcher panel
- `37a1fcd` — device-debug documentation
- `f9a26ca` — Touch input and launcher-to-voxel OpenXR handoff
- `989b174` — documented public Quest standalone checkpoint and `.envignore`
- `87a0026` — stable native focus, controller debounce, room anchor/recenter,
  and current device-debug documentation
- `89974f6` — deploy indexed Quest terrain mesher

Dramatic Shape `quest-openxr`:

- `80f2251` — Android OpenXR EGL/GLES backend
- `c5eba44` — Android OpenXR startup tracing
- `cc02738` — release launcher session and assume gameplay ownership
- `889c9a7` — automatic Quest VR, gameplay input tracing, isolated Pokédex
  capture/alignment, and Android framebuffer helpers
- `901f739` — indexed Quest terrain meshes while preserving the broad view

## Build output

The current development APK is produced at:

```text
mobile/android/app/build/outputs/apk/questVrNoRecord/debug/app-questVr-noRecord-debug.apk
```

It is intentionally ignored by Git. Exact build and install commands are in
`QUEST_BUILD_NOTES.md`.

## Documentation index

- `QUEST_PORT_AUDIT.md` — checked-source architecture and dependency audit
- `QUEST_BUILD_NOTES.md` — reproducible stock/Quest build environment
- `QUEST_DEBUG_LOG.md` — chronological device evidence, failures, fixes, and
  remaining work
- `.envignore` and `.gitignore` — publication and packaging exclusions

## Immediate next steps

1. Exercise the now-selectable Mods screen with a compatible user-supplied mod,
   including install, enable/disable, launch, and Back behavior.
2. Device-test the narrow Indigo Plateau/Route 23 deferred-neighbour policy.
3. Profile and fix intermittent startup and slow initial Yellow/voxel loading.
4. Fix SDL/OpenAL suspend/resume lifecycle crashes.
5. Determine whether missing distant buildings are culling, asset population,
   shader failure, or a distance/LOD configuration issue.
6. Run a controlled stereo alignment and long-session/thermal test.
7. Commit only device-verified fixes as separate milestones and keep the debug
   log current.

# Gen1Recomp Quest Standalone — Project Status

Last updated: 2026-08-12

## Current authoritative snapshot

The current integration branch is `quest-gen2-beta-v0.1.79`; the latest prior
documentation reconciliation is `fb67a16b`. The validated runtime baseline is
the v0.1.79 ROM-free Quest
APK plus Dramaless Quest `1.6.4-quest.6`; subsequent q10 work also physically
validated selectable Quest compositor refresh rates. The older branch and
commit descriptions later in this file are retained as historical milestones,
not as the current working-tree state.

The upstream-release gate is approximately 75%. Four generic changes have been submitted
independently against official development source:

- [#1199](https://github.com/bryanthaboi/gen1recomp/pull/1199): launcher modal
  focus routing (`1642113d`).
- [#1200](https://github.com/bryanthaboi/gen1recomp/pull/1200): optional
  `HostDisplay` lifecycle (`c2d9af69`).
- [#1201](https://github.com/bryanthaboi/gen1recomp/pull/1201): updater
  `payloadHost` compatibility (`0aab11b6`).
- [#1202](https://github.com/bryanthaboi/gen1recomp/pull/1202): Android native
  host lifecycle seam (`ee00728e`).

PR 5 is a locally verified work-in-progress candidate on isolated branch
`upstream-quest-openxr-backend` at `4e16cd77`. It extracts the Quest activity,
flavor, native OpenXR library, and generic display transport from the
prototype while keeping stock Android physically isolated. It is not
submitted, merged, device-validated, or release-qualified yet.
Live GitHub PR state could not be refreshed because the local GitHub CLI login
expired; documentation deliberately does not infer review or merge results.

Known active issues are:

- PR 5 still requires a physical Quest matrix: cold launcher, stable room
  anchor/recenter, Touch navigation/selection, Yellow handoff, stereo/6DoF,
  controller wake, suspend/resume, and clean exit/relaunch.
- Gold flat mode is validated, but Gold voxel/VR remains unimplemented.
- The Pokédex battle information is usable, but its 3D battle view remains a
  lower-medium presentation regression.
- Sustained voxel performance remains workload-bound with occasional hitches;
  long-session memory/thermal work and broad-map validation remain open.
- Dynamic Cries remains an optional, unbundled test candidate; its upload was
  deferred when ADB was disconnected.

The integration worktree also contains unrelated, untracked portal/MR
prototype files under `src/quest/dramaless/experimental/` and
`tests/engine/quest_portal_mode_prototype_test.lua`. They are intentionally
preserved and excluded from upstream extraction/documentation commits.

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
- Current integration branch: `quest-gen2-beta-v0.1.79`
- Clean upstream extraction worktrees: `upstream-pr1-focus` through
  `upstream-pr5-quest-backend`, each on its matching isolated topic branch.
- Active approved Dramaless fork: `E:\Gen1QuestVR\Dramaless-Quest`
- Approved Kanto fork: `E:\Gen1QuestVR\Kanto-First-Person-Quest`
- Historical Dramatic Shape checkout: `E:\Gen1QuestVR\DramaticShapeVoxelMod`
- Quest work is isolated from the upstream desktop and stock Android paths.

The Dramatic Shape source remains a separate repository. The Quest APK carries
only matched integration source files (`VRXR.lua`, `VR.lua`, `VRGL.lua`, the
indexed `ChunkMesher.lua`, and current Quest policy candidates) so an already
installed copy of the mod can use the Quest backend. It does not bundle the
mod's assets or user configuration.

For the user-owned standalone GitHub repository, independent histories and
approved mod forks remain separate rather than combining upstream projects or
vendoring them into the engine:

- `quest-openxr` — Gen1Recomp Quest application and documentation
- `dramatic-shape-quest-openxr` — Dramatic Shape Quest backend

The original upstream `origin` remotes remain unchanged in both checkouts.

## Current working-tree state

- Integration source and documentation are on `quest-gen2-beta-v0.1.79`.
- PR 5 source is isolated in `E:\Gen1QuestVR\upstream-pr5-quest-backend` on
  `upstream-quest-openxr-backend`; its worktree is clean at `f9e8088b`.
- The integration checkout retains unrelated untracked portal/MR prototype
  files. They remain intentionally excluded from these commits.
- The PR 5 APK is installed and physically validated through launcher pointer,
  Yellow launch, save-aware q14 loading card, automatic OpenXR ownership
  handoff, and immersive voxel entry. Its SHA-256 is
  `7BE8565B7C7344D83954ACD79139FB8F1D37E65CD245F83F035AAEE928F6EF23`.

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
- A right-Touch ray drives a crisp small white native selector. Normal launcher
  buttons and mod-manager actions are selectable. The selector is explicitly
  launcher-only and is physically verified absent from Yellow, the loading
  card, and immersive gameplay.
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
- An old `GameActivity` build produced a destroyed-mutex abort on its
  `AudioTrack` thread while Android finished it behind Quest Home. Source audit
  found no matching mutex destruction in the current Quest bridge, and a first
  controlled current-build cycle kept the same PID alive for more than 60
  seconds with no `FORTIFY`, `SIGABRT`, or process death, and the user confirmed
  that it returned to immersive voxel VR. Treat this as an unreproduced
  historical release risk pending repeated/long lifecycle and clean-quit soak,
  not as a proven current defect or a reason for a speculative audio rewrite.
  Three further automated 10-second Home/resume cycles also retained the same
  process with no activity destruction or fatal signature. The user confirmed
  voxel visibility and working controller input afterward, completing the
  repeated-resume acceptance check.
- The first current-build clean system Quit also passed: OpenXR, SDL surface,
  audio, and the QuestXR Android bridge shut down before a clean process exit
  status of zero. A fresh cold launch then initialized the full native launcher
  pipeline under a new PID with no fatal or stuck-start signature. Physical
  testing confirmed a visible launcher and working white controller pointer.
  The ensuing Yellow launch also completed the colored loading path, automatic
  immersive voxel transition, and functional gameplay controls under the same
  PID. Launcher-to-gameplay OpenXR ownership moved from request to FOCUSED in
  about 194 ms with no fatal signature.
- Initial Yellow/mod/voxel loading remains slow, but it is no longer ambiguous:
  q14 displays real map/mesh progress on the colored GBC loading card. A Route
  8 physical sample spent 30.4 seconds between final save load and OpenXR
  startup request, then entered immersive VR automatically.
- Quest video evidence shows a 2D-to-partial-to-complete voxel population
  sequence. Current Dramatic Shape already builds meshes cooperatively; the
  leading improvement candidate is a new persistent disk mesh cache.
- Some distant buildings were missing during the first verified voxel test.
- Possible stereo/world offset in first person still needs a controlled
  two-eye validation; screenshots alone are left-eye views.
- Performance, thermals, long-session stability, save/load, suspend/resume,
  and broad map coverage have not yet passed a release test matrix.
- Quest experimental-mod dialogs now route focus confirmation correctly. The
  fix has 20 passing regression checks across all four modal types and desktop
  behavior, and physical headset testing confirmed that the highlighted modal
  control performs its matching action.
- Never deploy `build/intermediates/apk` artifacts. One such APK contained an
  incomplete/older `game.love` and visibly regressed the Pokédex. Only the
  verified canonical `build/outputs/apk/questVrNoRecord/debug` APK is a
  deployment candidate.

## Low-priority polish

- Crystal 251 0.10.1 is device-verified with Dramaless Shape, Kanto First
  Person, Wilds of Kanto, and Wild Skies through Saffron -> Route 8 -> Lavender.
  Gen II flyers render and controls remained stable. Wilds of Kanto still uses
  fallback overworld IDs for Murkrow, Houndour, and Yanma; investigate those
  sprite registrations later. A follow-up interior/battle/menu stress pass also
  preserved all controls, but post-test memory reached about 2.31 GB PSS with
  894 MB Graphics at 50 C. Long-session allocation and thermal optimization is
  the next performance priority for this expanded mod stack.

- A first bounded-memory candidate is built, source-tested, payload-audited,
  and signature-verified. It explicitly releases resized Quest UI/mirror
  canvases and drops only redundant previous mesh neighbourhoods after
  seamless crossings/Fly; warm interior return meshes remain unchanged.
  Candidate SHA-256 is
  `B013F36302DE4BB0DD82317C4E99C80B25EE53F06BD4634863DD5DB4236E2DDA`.
  Physical headset validation remains and is documented in
  `QUEST_MEMORY_CANDIDATE_TEST.md`.

- Dramatic Sky Ride 0.1.5 is deferred: it was stable but reduced the measured
  Celadon interval from about 30.5 to 26.5 FPS. Its 3D flight works in VR, but
  altitude control does not: Quest triggers currently map to Start rather than
  LÖVE trigger axes, and camera-altitude does not receive Quest head pitch.
  Revisit with a generic raw OpenXR trigger/head-pitch input surface, then
  reassess whether flight is worth the measured cost. Keep it disabled now.
- Launcher modal highlighter appearance/alignment can be cleaned up further.
  Input and activation are device-verified functional; rank this above Pokédex
  presentation polish but below gameplay, loading, lifecycle, and performance
  defects.
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

1. Run PR 5's remaining suspend/resume, controller-sleep, repeated-handoff,
   map-transition, and quit soak matrix; prioritize the prior destroyed-mutex
   quit abort.
2. Repeat the clean stock-versus-Quest audit at `f9e8088b`, then decide whether
   the backend branch is ready to submit upstream.
3. Device-test `QUEST_MEMORY_CANDIDATE_TEST.md`, including seamless crossings,
   a warm Tower/interior return, Pokédex/battle resize transitions, and final
   memory/thermal capture.
4. Profile and fix intermittent startup and slow initial Yellow/voxel loading.
5. Fix remaining SDL/OpenAL suspend/resume lifecycle crashes.
6. Continue battle-view, distance/LOD, stereo-alignment, long-session, and
   broad-map validation after the upstream backend gate.

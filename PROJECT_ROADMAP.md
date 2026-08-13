# Gen1Recomp Quest VR — Master Roadmap

Last reconciled: 2026-08-13

This is the single checkbox list for the project. Percentages are estimates of
the work completed for that item, including required physical headset testing.
An item is checked only when it is complete enough to rely on; a successful
prototype alone does not count as 100%.

## At a glance

- **Standalone Quest VR core:** 90%
- **Current v0.1.79 integration:** 100% (promotable Quest baseline)
- **Stable Dramaless + Kanto experience:** 92% (Dramaless q3 core and Kanto q7
  are accepted; Route 8, Route 12 and an unaffected Route 5 battle passed.
  Rollback, isolated performance and minor first-battle-frame polish remain)
- **Dramaless 2.0 Quest migration:** 96% (q3 passed the complete core physical
  matrix and is the accepted comparison baseline; retained transition continuity
  and Kanto compatibility work are tracked separately)
- **Battle Art 1.8.6 transition/precache integration:** 10% (scope,
  provenance and maintainer guidance recorded; source audit pending)
- **Performance and lifecycle hardening:** 70%
- **Gen 2 engine readiness:** 90%
- **Gen 2 voxel/VR gameplay:** 10%
- **Side Door Fix:** 35%
- **Gen 2/HGSS sprite-provider work:** 86%
- **Portal/MR modes:** 10%
- **PCVR release path:** 15%
- **Upstream engine/API contribution gate:** 70%
- **Overall playable Quest release:** **80%**
- **Whole long-term vision, including Gen 2, MR and PCVR:** **46%**

## Release gate — Upstream engine and API contributions (70%)

Quest is not considered ready for an official release until its reusable host
changes have been split into reviewable pull requests, accepted upstream, and
regression-tested without changing vanilla desktop or stock Android behavior.
`UPSTREAM_PR_ROADMAP.md` is the authoritative PR breakdown and acceptance
matrix.

- [x] Establish the ownership boundary: engine/API changes go upstream;
  Dramaless and Kanto-specific changes remain in their approved Quest forks.
- [x] Inventory the current Quest branch against official `v0.1.79` and reject
  a monolithic PR (it mixes launcher, updater, Android, OpenXR and mod code).
- [ ] Rebase each proposed change onto the current official development base
  (`v0.1.80` / `c3136bf8` is now the first clean extraction base).
- [x] Submit platform-neutral launcher modal focus/navigation fix with headless
  vanilla-compatibility tests: upstream PR
  [#1199](https://github.com/bryanthaboi/gen1recomp/pull/1199).
- [x] Submit a generic native-panel/capture host lifecycle API without Quest
  globals and with a no-op default implementation: upstream PR
  [#1200](https://github.com/bryanthaboi/gen1recomp/pull/1200).
- [x] Submit a generic updater `payloadHost` compatibility contract that keeps
  vanilla `love` payload behavior and prevents mixed native/Lua packages:
  upstream PR [#1201](https://github.com/bryanthaboi/gen1recomp/pull/1201).
- [x] Submit generic Android lifecycle/native-extension seams with no-op stock
  behavior: upstream PR [#1202](https://github.com/bryanthaboi/gen1recomp/pull/1202).
  The stock `embed/noRecord` APK build and native-library inventory passed.
- [x] Extract the optional OpenXR Quest flavor/backend into a clean dedicated
  branch that consumes the generic seams and contains no ROMs, saves, mods or
  commercial assets.
- [x] Physically smoke-test that isolated backend: stable room-anchored
  launcher, recenter, controller ray pointer, live panel refresh, Yellow
  handoff, stereo voxel rendering, Touch controls and restored generic frame
  capture all passed.
- [ ] Complete the clean-source audit and submit the optional OpenXR Quest
  flavor/backend separately from the generic engine APIs.
- [ ] Run the complete upstream ROM-free CI suite for every PR.
- [ ] Build and smoke-test vanilla desktop and stock Android for every affected
  PR; compare launcher, import, update and gameplay behavior to upstream.
- [ ] Build the ROM-free ARM64 Quest APK and complete the physical headset
  regression matrix after the PR stack is combined.
- [ ] Obtain upstream review/acceptance or revise the API until maintainers are
  satisfied; do not describe downstream prototypes as official support.
- [ ] Update the Quest integration branch to consume accepted APIs and remove
  duplicated downstream engine patches.

Completion condition: accepted upstream engine/API changes preserve vanilla
behavior, the downstream mod forks contain all mod-specific adaptations, and a
fresh official-source build passes desktop, stock Android and physical Quest
regression testing.

## Priority 1 — Validate the official v0.1.79 build (100%)

- [x] Preserve the fully validated `v0.1.78` APK as the rollback baseline.
- [x] Fetch official signed `v0.1.79` source tag (`04490c9b`).
- [x] Merge it into isolated `quest-gen2-beta-v0.1.79` branch without conflicts.
- [x] Build and inspect a ROM-free multi-ABI Quest APK.
- [x] Import Dramaless Quest `1.6.4-quest.3` and run the physical regression.
- [x] Verify Route 8 -> Lavender -> Route 8 avoids a second mesh rebuild.
- [x] Validate Dramaless Quest `1.6.4-quest.6` B/cancel across Mod Manager.
- [x] Validate controller sleep/wake and two short headset suspend/resume cycles.
- [x] Validate a 10+ minute headset suspend/resume cycle.
- [x] Integrate and physically approve the full-color VR Unplugged loading card.
- [x] Fetch official signed `v0.1.78` source tag.
- [x] Merge it into isolated `quest-gen2-beta-v0.1.78` branch.
- [x] Confirm zero launcher/Android/OpenXR merge conflicts.
- [x] Build `questVrNoRecordDebug` successfully.
- [x] Preserve upstream launcher and Gold implementation rather than replacing them.
- [x] Install the beta-integrated APK without clearing saves/mods.
- [x] Confirm launcher image, thin green focus ring and controller navigation.
- [x] Launch Yellow and enter Dramaless voxel VR.
- [x] Verify stereo, 6DoF, recenter, Touch controls and snap turning.
- [x] Verify Pokédex during exploration, dialogue, menu and battle.
- [x] Test a building transition, route transition and battle.
- [x] Test controller sleep/wake and headset suspend/resume.
- [x] Capture logs, memory, GPU allocation, temperature and battery state.
- [x] Tag and preserve the validated APK/mod combination as the rollback build.

Functional regression result: pass. Performance result: fail for release
quality—the voxel overworld remains around 36–40 ms/frame while menu/Pokédex
presentation reaches roughly 13.4–13.6 ms/frame. Treat world rendering and
streaming as the next blocker, not the OpenXR transport.

Completion condition: the official beta passes the ordinary Yellow VR test
route on physical Quest hardware without a new blocker.

## Priority 2 — Establish official Quest mod forks (90%)

- [x] Receive written permission from Kanto in First Person creator `briddsy`.
- [x] Receive written permission/blessing from Dramaless creator Stahltier.
- [x] Archive screenshots, hashes, dates and scope in `docs/permissions/`.
- [x] Clone a pristine Dramaless upstream mirror.
- [x] Create a dedicated Dramaless Quest fork/repository and `quest-vr` branch.
- [x] Create dedicated public `Kanto-First-Person-Quest` repository with
  isolated `quest-vr` default branch and preserved upstream remote/history.
- [x] Preserve upstream licenses, credits and inherited third-party notices.
- [x] Clearly label builds as Quest-maintained and not headset-tested upstream.
- [x] Move validated VR conductor helpers into the mod; retain a defined native host boundary.
- [x] Add reproducible packaging scripts and version the APK/mod compatibility pair.
- [x] Physically import `1.6.4-quest.1` and verify Yellow reaches the voxel world.
- [ ] Add automatic upstream comparison notes for each new Dramaless release.

## Priority 3 — Dramaless VR maintenance and 2.0 acceptance (88%)

- [x] Port OpenXR session creation to standalone Android/Quest.
- [x] Render stereoscopic Quest frames with head tracking and 6DoF.
- [x] Implement launcher-to-game XR session handoff.
- [x] Implement Touch-controller launcher and gameplay mappings.
- [x] Implement room anchoring and Quest recenter response.
- [x] Restore stable thin green launcher focus ring.
- [x] Fix major Pokédex alignment/capture regressions to a usable state.
- [x] Add Quest canvas lifetime cleanup and route-history release seams.
- [x] Rebase the Quest adapter onto stable Dramaless `v1.6.4` in the dedicated fork.
- [x] Add Quest-selectable 72/80/90/120 Hz presentation-rate control.
- [x] Physically prove 72 Hz through OpenXR acceptance and compositor `/72`
  plus `DR72/73` telemetry (`1.6.4-quest.10`).
- [x] Handle Quest's empty refresh-rate enumeration without disabling the
  authoritative direct OpenXR request.
- [x] Restore generic completed-frame capture after the isolated backend
  migration (`1.6.4-quest.15`); physical Pokédex rendering passed.
- [x] Make the existing `RES` option control the immersive eye canvases and
  physically compare full versus half resolution (`1.6.4-quest.16`).
- [x] Choose `RES: FULL`, `SHADOWS: LOW` as the current Quest 3 quality
  baseline; keep `RES: 1/2` only as an optional low-memory profile.
- [x] Build deterministic `1.6.4-quest.17` with self-contained indexed meshing,
  bounded route history and observation-only transition diagnostics.
- [x] Cold-load and physically validate q17: version, Full eye dimensions,
  72 Hz, immersive startup and Saffron/Lavender reversal all passed.
- [x] Diagnose q17's missing records as a mod-sandbox logger visibility defect
  and build q18 with an explicit native VRXR trace sink.
- [x] Preserve q18 at rollback tag `quest-vr-q18` and immutable ZIP SHA-256
  `1EE7E4F1556ECF618E7EDDACB0CFDD18B55B54B71ECC790286BF15A6A114ACB9`.
- [x] Merge the Quest adapter onto official Dramaless 2.0 in isolated branch
  `quest-vr-2.0` without changing launcher or APK source.
- [x] Pass the 2.0 Lua, Mod API 2 manifest, Quest input/loading/streaming,
  battle-provider, packaging and deterministic-archive gates.
- [x] Commit/tag candidate `00c4d4c` / `quest-vr-2.0-q1-candidate` and copy
  `DRAMALESS_SHAPE-2.0.0-quest.1.zip` to Quest Downloads.
- [x] Complete the q1 first physical probe: launcher/loading/OpenXR/audio
  passed; reject it after `Mat4.fromQuat` disabled the voxel pipeline and
  produced a black immersive frame.
- [x] Restore q18's three pure OpenXR pose helpers (`fromQuat`, `transpose`,
  `fovProjection`) in q2, add numerical tests, commit `811f7e1`, package
  deterministically and verify the ZIP in Quest Downloads.
- [x] Complete the q2 first visual probe: voxel rendering returned, but reject
  q2 because `Voxel3D` discarded OpenXR's per-eye matrices and produced a
  severely misaligned/disorienting stereo view.
- [x] Restore q18's narrow raw-matrix camera branch in q3, add a regression
  contract, commit/tag `1b3ac8c` / `quest-vr-2.0-q3-candidate`, package it
  deterministically and verify the exact ZIP hash in Quest Downloads.
- [x] Complete q3 physical acceptance: aligned stereo voxel, controls,
  recenter, controller wake, Pokedex, battle, transition, clean Quit and cold
  relaunch.
- [x] Prove preserved `VRSTREAM`/`MESHJOB2` diagnostics on the q3 physical
  transition instead of spending a separate release cycle on q18.
- [ ] Make Quest integration seams patchable without copying whole upstream files.
- [ ] Add automated checks for expected Dramaless source versions/functions.
- [ ] Perform the complete physical regression matrix after every update.

## Priority 3A — Restore Kanto First Person on Dramaless 2.0 (96%)

This begins immediately after q3's clean-Quit/cold-launch gate and precedes
Battle Art tuning. Kanto is part of the intended first-person experience; its
walls, ceilings, backdrops, doors and related presentation must function before
performance work measures the combined stack.

- [x] Confirm the scope is the entire Kanto patch, not only background art:
  q3 currently has no Kanto walls or ceilings either.
- [x] Identify the deliberate refusal in Kanto 1.60.0's strict `TESTED` table;
  Dramaless `2.0.0-quest.3` reduces to the unlisted base `2.0.0` and returns
  before writing any patch payload.
- [x] Compare every guarded Kanto splice anchor against Dramaless 2.0 q3 in the
  approved Kanto Quest fork; do not simply whitelist the version.
- [x] Replace or adapt only the smallest incompatible seams, add automated
  no-write/failure/rollback tests, and preserve Kanto's safe refusal behavior.
- [x] Reject `1.60.0-quest.2` at the physical import gate: the Quest importer
  could not mount its PowerShell-written flat-root ZIP even though host ZIP and
  desktop PhysicsFS validation passed. Do not retry q2.
- [x] Repackage unchanged audited source as `1.60.0-quest.3` under one
  `ds_fp_ceiling/` root with deterministic 7-Zip metadata, ROM/save/cache
  guards, and a focused in-memory PhysicsFS manifest test. Archive SHA-256 is
  `A14BE932462D7237266A3D843B6127CD31643547B47E7CC5A31F620A4F477F57`.
- [x] Reject q3 after the physical Quest importer still could not mount its
  Windows/FAT-origin ZIP; prove the untouched official Unix-origin archive
  reaches manifest validation on the same APK.
- [x] Package deterministic Unix-origin `1.60.0-quest.4`, SHA-256
  `C7C0D75912B6BC9AC96A15C0BDCEF785E49C37CC6CE81D73FD6ECB898C9C385D`;
  prove Android can mount it, install it, and load its `2.0.0` patch.
- [x] Physically confirm Kanto's intended presentation is restored and pass a
  Saffron City -> Silph Co. interior -> Saffron City round trip without a Lua
  error or lifecycle failure.
- [x] Physically prove a route transition and correctly centered
  Pokedex/dialogue capture under q4.
- [x] Reproduce q4's Route 8 battle occlusion in two captures, isolate it to
  the optional Kanto flora injection in Dramaless 2.0's dedicated battle
  provider, and build deterministic q5 with fresh-install and q4-migration
  contracts. SHA-256:
  `25C71C812F020AABA4F29004A0607E7209727D359B894B643C9D907F3A7F96C7`.
- [x] Reject q5 physically: logs prove its flora-hook cleanup ran, but the
  same Route 8 obstruction remained. The lifted host terrain—not the optional
  support draw—is the blocker.
- [x] Build deterministic q6 using Dramaless's existing per-arena wide camera
  for Route 8 only, restore battle tree supports, and prove fresh apply,
  q5 migration, idempotence and byte-exact rollback. SHA-256:
  `1FF5532A6B642E7DB30655B760A496F1C5A641C93EEB6B576E4D4D357AE4F87A`.
- [x] Physically validate q6's Route 8 camera: the user reports the view is
  perfect, while logs prove the wide-camera patch and restored tree supports
  loaded before a successful Route 8 voxel-arena start.
- [x] Diagnose the distinct Route 12 defect from live device/source evidence:
  the map reuses a land arena at `(0,73)` even for the water-heavy section south
  of Lavender. Verify `(10,4)` is a complete 3x6 water arena using temporary,
  unshipped map metadata from the user's authorized Yellow ROM.
- [x] Build deterministic q7 with only the Route 12 water-stage/wide-camera
  override added to accepted q6; prove fresh apply, q6 migration, idempotence,
  byte-exact rollback and package safety. SHA-256:
  `9A67A4190C646EE37692A6FA6C600B7D0E26099052D7C8C4E5E538C7E1F61D68`.
- [x] Physically validate q7 on Route 12: the user reports the corrected water
  stage and clear wide camera work perfectly. Preserve exact artifact SHA-256
  `9A67A4190C646EE37692A6FA6C600B7D0E26099052D7C8C4E5E538C7E1F61D68`
  under tag `kanto-quest-1.60.0-q7-route12-accepted`.
- [x] Reconfirm under q7 that Route 8 remains correctly staged; the user
  explicitly clarified that Route 8 was not broken by the Route 12 change.
- [x] Complete the broader q7 arena regression. An unaffected Route 5 battle
  kept its correct world stage, stereo and gameplay; its handheld Pokédex
  initially retained one exploration frame but refreshed to the live battle
  UI on the next menu change. Classify that as separate low-priority capture
  timing polish, promote q7 as known-good, and retain q6 as an archival
  rollback.
- [ ] Complete a clean explicit REMOVE PATCH rollback on Quest.
- [ ] Measure Dramaless + Kanto alone before attributing the current full-stack
  36-38 FPS / ~2.1 GB PSS / ~714 MB graphics sample to Kanto itself.

## Priority 3B — Battle Art 1.8.6 transition and precache integration (10%)

This starts after the Dramaless 2.0 q3 physical gate and Kanto 2.0 compatibility
restoration. It remains ahead
of new visual polish, Gen 2 voxel work, Portal/MR and PCVR because it directly
targets the current release blocker: route/town transition hitching and pop-in.
It does not outrank restoring the required first-person stack correctly.

- [x] Record absol89's approval/coordination and guidance as implementation
  provenance; retain upstream credits and license notices.
- [x] Select Battle Art `1.8.6` commit `0649420` as the only source baseline;
  reject older `1.8.0`/`1.8.4` code as implementation input.
- [ ] Audit the active Quest branches, dirty files, current Dramaless 2.0
  cache/streaming code and existing Battle Art workspace before editing.
- [ ] Fetch/verify exact commit `0649420` and record its full commit identity.
- [ ] Identify the exact statement at `VoxelScene.lua` line 499 in that commit,
  its ownership/lifecycle effect, and why absol89 found that commenting it out
  reduced transition hitch time.
- [ ] Compare it against Quest `VoxelScene`, `ChunkMesher`, `TerrainAtlas`,
  destination preload, neighbor history, invalidation and bounded retention.
- [x] Capture the first q3 physical continuity symptom and its source boundary:
  Route 8's urgent full mesh took about 2.9 seconds after re-entry, while
  neighboring authored figures bypass both the neighbor-terrain readiness and
  render-distance gates. This is a transition/render-visibility mismatch, not
  an OpenXR regression.
- [ ] Implement the smallest safe transition change first, with cold/missing
  destination fallback and no loss of terrain continuity; ensure actors are
  not exposed where their supporting neighbor terrain is unavailable.
- [ ] Port only useful current Battle Art precaching behavior and rewrite it
  for Gen1Recomp Mod API 2/current I/O API; do not restore unrestricted legacy
  filesystem access.
- [ ] Keep RAM/GPU caches bounded and destination-aware; never retain the whole
  world permanently or package ROM-derived cache data/private artwork.
- [ ] Keep StadiumBattleFX 2.0 as importer/battle host and lifecycle owner;
  Battle Art exposes only modular arena/art providers through its API.
- [ ] Add focused transition, destination-precache, invalidation, retention,
  cold fallback, I/O compliance, package-safety and vanilla/non-VR tests.
- [ ] Run Lua syntax, relevant automated tests, Mod API 2 checks, package audit
  and two-build deterministic archive validation.
- [ ] Build a clearly named headset candidate while keeping q18 and 2.0 q1 as
  rollbacks; compare the same route against the accepted q1 baseline.
- [ ] Record transition hitch/pop-in, FPS and frame time, PSS/graphics memory,
  stability and the memory/pop-in tradeoff. Claim improvement only from device
  evidence.

Completion condition: exact upstream provenance and line behavior are
documented, the smallest safe current-API implementation passes desktop/
non-VR/package tests, Stadium ownership remains modular, and a matched Quest 3
run proves the result without replacing the rollback build prematurely.

## Priority 4 — Reliability, loading and performance (70%)

- [x] Replace the original always-load-everything behavior with bounded streaming.
- [x] Add location-aware preload and route/town transition preparation.
- [x] Improve initial traversal and several Viridian/Route 23 transitions.
- [x] Add clearer classic-style VR loading presentation.
- [x] Improve loading text legibility.
- [x] Release superseded Quest canvases instead of waiting for garbage collection.
- [x] Drop redundant previous route history after safe connection/Fly transitions.
- [ ] Eliminate intermittent immersive loading-screen stalls.
- [x] Confirm controller wake/reactivation no longer stalls in the v0.1.79/q6 test.
- [x] Confirm short and 10+ minute suspend/resume recovery on v0.1.79/q6.
- [ ] Prevent occasional strange boot into mod screen with mouse cursor.
- [ ] Profile and reduce sustained ~2.0–2.3 GB memory use and large graphics allocation.
- [x] Compare full and half immersive resolution on physical Quest. Half saved
  roughly 275 MB and was slightly smoother but visibly blurred the image.
- [x] Compare `SHADOWS: HIGH` and `LOW`; accept `RES: FULL`, `SHADOWS: LOW` as
  the sharper Quest 3 baseline while targeting CPU mesh/draw work.
- [x] Instrument q17 mesh jobs with queue wait, coroutine-active time, phase
  timing, budget overruns, cancellation and real map-entry queue snapshots.
- [x] Validate that q17 is active: device logs proved its installed/loaded
  version, Full eye dimensions, 72 Hz and requested physical traversal.
- [ ] Prove q18's corrected `VRSTREAM`/`MESHJOB2` transport on one transition,
  then repeat the benchmark only if the short trace lacks enough phase data.
- [ ] After the valid q17 Full/Low run, test Full/Off as the next matched shadow
  comparison; adopt it only if the visual loss is acceptable and measurable.
- [ ] Reduce thermal slowdown during long mod-heavy sessions.
- [ ] Revisit Route 2/Victory Road tree pop-in without restoring constant stutter.
- [ ] Profile Indigo Plateau/Victory Road loading and add safe regional preloading.
- [ ] Validate Saffron, Celadon, Lavender, forests, caves and major interiors.
- [ ] Run a 30–60 minute traversal/battle/suspend stress test.
- [ ] Compare matched 72 Hz and 90 Hz traversal runs for frame pacing,
  temperature, battery drain and visual comfort; choose the Quest default.
- [ ] Investigate why the current heavy Route 8/mod-stack workload delivers
  roughly 38–41 application FPS even with the compositor correctly at 72 Hz.
- [x] Select Dramaless 2.0 `R.DIST: MEDIUM` (`32`) as the provisional Quest 3
  visual/performance sweet spot from the user's q3 traversal.
- [ ] Repeat a matched `FULL` (`-1`, internally 128) versus `MEDIUM` (`32`)
  traversal after Kanto 2.0 compatibility is restored; the first observation
  changed settings mid-run and crossed maps, so it is not a clean A/B result.

Current checkpoint: Dramaless 2.0 q3 restores direct OpenXR per-eye matrix
composition, passed all automated/package gates and passed the complete physical
core matrix. Android recorded its final test exit as `EXIT_SELF`/status `0`, and
a new process cold-loaded q3 back into voxel. q3 is now the accepted core
comparison baseline; q18 remains the immutable emergency rollback while Kanto
2.0 compatibility is restored.

## Priority 5 — Quest controls and launcher polish (92%)

- [x] Support Touch buttons, triggers and thumbsticks.
- [x] Fix launcher focus movement and selection targeting.
- [x] Make mod-management modal buttons selectable on Quest.
- [x] Correct upside-down/super-zoomed launcher capture regressions.
- [x] Anchor launcher in space and follow Quest recentering.
- [x] Preserve the upstream launcher instead of maintaining an independent launcher.
- [x] Replace the unreliable moving focus-ring interaction with a native
  controller-ray pointer, fresh captured frames and working activation.
- [x] Hide the white launcher pointer after Yellow takes over gameplay.
- [ ] Recheck every modal on the combined clean backend: import, update,
  enable, disable, delete and file picker.
- [ ] Test delayed launcher interaction after leaving it idle.
- [ ] Low priority: visually refine focus-ring alignment and thickness.
- [ ] Low priority: polish slight launcher tilt after recenter.

## Priority 6 — Pokédex and flat-feed presentation (78%)

- [x] Restore usable exploration/dialogue/menu feed.
- [x] Fix the major dark-strip/misalignment defect.
- [x] Make the selector arrow visible.
- [x] Center the current usable capture closely enough for play.
- [x] Turn the screen off when no dialogue/text/menu feed is needed without hiding the device.
- [x] Restore the Pokédex feed after the isolated host-backend migration using
  a generic no-op-by-default completed-frame event.
- [x] Verify current fixes survived v0.1.79 and q15 on physical Quest.
- [ ] Retest capture after the next stable Dramaless update.
- [ ] **Lower-medium priority:** repair the compromised v0.1.79 Pokédex view
  of the 3D battle; battle UI and information remain visible and usable.
- [ ] Improve battle framing, which has repeatedly appeared too zoomed.
- [ ] Remove remaining black side bars/bezels without losing capture.
- [ ] Ensure battle mirror/feed activates consistently.
- [ ] Low priority: eliminate the occasional stale exploration frame held at
  battle entry. Route 5 physical testing proved the feed refreshes correctly
  on the next UI change, so this does not block Kanto q7 acceptance.
- [ ] Measure whether mirroring causes a meaningful performance cost.
- [ ] Low priority: final pixel-perfect centering and sizing.

## Priority 7 — Gen 2 readiness and Gold (70% engine / 10% VR)

- [x] Follow upstream's Preparing Your Mod for Gen 2 guide.
- [x] Merge the parallel `Game2`, Gen 2 world, battle and VM implementation.
- [x] Preserve upstream Gold launcher/import workflow.
- [x] Package the Gold manifest without ROM/generated data.
- [x] Run initial `gen2check` audits on the active mod stack.
- [x] Keep incompatible Gen 1-only mods skipped rather than falsely claiming support.
- [x] Import a legally obtained supported Gold ROM on Quest.
- [x] Validate launcher → Gold → flat gameplay on Quest with mods disabled.
- [x] Verify saves, controls, a battle, an interior and short suspend/resume in stock Gold.
- [ ] Acquire/use standalone LuaJIT and rerun complete member-coverage `gen2check` audits.
- [ ] Design the Dramaless Gen 2 renderer port using public/shared Gen 2 seams.
- [ ] Decide which Kanto First Person camera behavior is generation-independent.
- [ ] Port Wilds/Wild Skies only where features make sense for Gold.
- [ ] Keep Crystal 251 Gen 1-only unless a nonduplicated feature is deliberately redesigned.

## Priority 8 — Kanto in First Person Quest fork (68%)

Release-follow-up rank: immediate Priority 3A after the Dramaless q3 core gate.
Physical testing confirmed the strict refusal removes the entire Kanto
presentation—not only backgrounds—so it must precede Battle Art performance
tuning. General Kanto enhancements below remain Priority 8.

- [x] Run Kanto First Person successfully with Dramaless on Quest.
- [x] Obtain explicit creator permission for a Quest fork and optimization.
- [x] Identify first/third-person as the intended primary experience.
- [x] Confirm standard third-person is explicitly disabled while VR is active.
- [x] Create the formal Quest fork and retain creator attribution.
- [x] Sync the creator's official 1.60.0 release-package source as a separate
  provenance commit because its Git tag still identifies 1.57.2 internally.
- [x] Add ROM/save/cache/credential packaging guards and a reproducible
  `1.60.0-quest.1` package script.
- [x] Diagnose missing Dramaless 2.0 backgrounds/ceilings: Kanto 1.60.0's
  strict tested-version gate sees base version `2.0.0`, does not list it, and
  intentionally performs no patch writes. This is not a hidden 2.0 setting.
- [x] Validate Kanto's guarded patch anchors against Dramaless 2.0 q3 in the
  approved Kanto Quest fork, extend the tested-version contract only after its
  tests pass. q2 now awaits physical backdrops/ceilings validation without
  altering q3.
- [ ] Rebase current Quest compatibility changes onto that fork.
- [ ] Fix Dramaless third-person mode in ordinary opaque VR.
- [ ] Add optional visible/hidden/automatic trainer presentation.
- [ ] Profile Kanto-specific performance costs independently of Dramaless.
- [ ] Separate Kanto-only authored content from reusable camera behavior.
- [ ] Decide whether any camera layer is appropriate for Gen 2.

## Priority 9 — Gen 2/HGSS sprite provider (86%)

- [x] Create isolated Crystal ROM sprite-provider project.
- [x] Avoid distributing ROM data or Pokémon artwork.
- [x] Diagnose Murkrow, Houndour and Yanma fallback registrations.
- [ ] Fix the Wild Skies flying-Yanma model contract: provider `0.1.3` supplies
  imported Crystal `193-yanma.png`, but Wild Skies `1.8.0` renders it as a giant
  vertically stretched/repeated billboard. Audit image dimensions, frame/UV
  interpretation and scale without bundling Pokémon artwork.
- [x] Diagnose secondary-Flying species being classified as generic `MON` sprites.
- [x] Implement the `0.1.4` systemic flyer correction.
- [x] Package clearly named Quest import ZIP.
- [x] Add provider/runtime tests and documentation.
- [x] Receive and archive permission from LucianoNeo for a credited Quest-performance fork.
- [ ] Audit HGSS Sprites v0.3.0 code license and every bundled asset's provenance.
- [ ] Create the isolated **private** HGSS Quest fork only after the license/asset audit.
- [ ] Keep its repository, Git history, packages and assets outside this public project.
- [ ] Configure no public remote, public CI artifact or automatic release path.
- [ ] Import/enable `IMPORT_ME__NO_MORE_RHYDON_FLYERS__v0.1.4.zip` and restart.
- [ ] Confirm Xatu/Delibird and other affected Gen 2 flyers use Crystal-derived art.
- [ ] Confirm Pidgeotto/Spearow/Doduo use installed HGSS icons.
- [ ] Confirm Hoppip and other correctly classified controls remain unchanged.
- [ ] Confirm Murkrow/Houndour/Yanma ground spawns no longer use fallbacks.
- [ ] Measure provider/HGSS-specific stutter.
- [ ] Publish only after explicit authorization for a remote repository/release.

## Priority 10 — Side Door Fix (35%)

- [x] Create separate Side Door Fix repository/tool.
- [x] Detect/report candidate side entrances without changing warps.
- [x] Test generic geometry and document why it covered valid doors.
- [x] Restore the known-good Dramaless build after rejected experiments.
- [x] Perform clean-room behavioral comparison against Dramatic Shape 1.8.2.
- [x] Confirm 1.8.2 does not expose a reusable automatic side-door rule.
- [x] Identify Kanto's depth-aware pass as the safer permitted integration point.
- [ ] Implement explicit Route 7 and Route 8 outward-door prototype in Kanto fork.
- [ ] Confirm it never changes collision, warps or interior geometry.
- [ ] Add the west-Celadon entrance after Route 7/8 pass.
- [ ] Convert successful placements into authored metadata.
- [ ] Decide whether safe automatic detection is possible; otherwise keep authoring tool/manual list.
- [ ] Package and physically validate the standalone mod.

## Priority 11 — Mod-stack compatibility (75%)

- [x] Validate Dramaless + Kanto First Person + Wilds of Kanto.
- [x] Validate Wild Skies and observe worthwhile flying encounters.
- [x] Validate Crystal 251 flat/voxel gameplay with controls surviving transitions and battle.
- [x] Upload/test additional sky mods and identify Dramatic Sky Ride altitude/control limitations.
- [x] Preserve the user ROM-import and mod-import workflow.
- [x] Retest the accepted stack under v0.1.79; the q16/q17-attempt logs show
  Wilds of Kanto and Wild Skies active across Route 8 and Lavender.
- [ ] Decide whether Dramatic Sky Ride remains disabled/deferred.
- [ ] Revisit HGSS Sprites compatibility after provider validation.
- [ ] Test Wilds/Wild Skies after the next stable Dramaless merge.
- [ ] Retest Wild Skies after the Yanma provider/consumer contract fix and use
  the preserved Route 8 screenshots as the visual regression reference.
- [x] Maintain a machine-readable known-good mod/version matrix in
  `../mod-update-status.json`, with the human checklist in
  `../MOD_UPDATE_CHECKLIST.md`.
- [ ] Explore an existing MMO/co-op mod for Quest after core reliability is stable.
- [ ] Revisit overworld-spawn optimization fork idea later.
- [ ] Revisit Stadium Model Viewer/Pokédex presentation later.

## Priority 12 — Portal and mixed-reality modes (10%, deferred)

- [x] Define Portal MR, Diorama MR, Room Battle and Portal Battle concepts.
- [x] Prioritize Portal Mode before full Diorama MR.
- [x] Create isolated, unhooked `PortalMode.lua` state/geometry prototype.
- [x] Add prototype notes and tests without touching production packaging.
- [ ] Get ordinary opaque third-person VR working first.
- [ ] Implement world-locked forward/back portal boundary.
- [ ] Add reliable exit and deliberate recenter controls.
- [ ] Add trainer visible/hidden/auto-hide choices.
- [ ] Add native Quest passthrough backend.
- [ ] Add Touch placement, rotation and scale controls.
- [ ] Prototype room-scale and portal battle layouts.
- [ ] Add scene/floor awareness only as a later enhancement.
- [ ] Low priority: hand tracking, gaze input and direct manipulation.

## Priority 13 — PCVR support (15%, after Quest stabilization)

- [x] Preserve Dramaless's experimental Windows OpenXR code as reference.
- [x] Plan a shared VR layer with separate Quest and Windows backends.
- [x] Avoid baking Android/EGL assumptions into shared camera/UI behavior.
- [ ] Extract and document the shared VR camera, stereo, UI and locomotion contract.
- [ ] Refresh/build a Windows x64 OpenXR native backend.
- [ ] Test SteamVR OpenXR runtime.
- [ ] Test Meta PC OpenXR runtime.
- [ ] Add Windows controller bindings and recenter behavior.
- [ ] Match Quest Pokédex, battle and comfort behavior.
- [ ] Test multiple GPU vendors/drivers and desktop OpenGL contexts.
- [ ] Package a PCVR beta and collect broader community testing.

## Priority 14 — Clean-room competitive feature pass (35%)

- [x] Audit `1GenPokemonVr` at revision `9a90448` and document its legal boundary.
- [x] Confirm its inherited and original VR additions are not licensed for
  verbatim reuse; keep all work clean-room and behavior-based.
- [x] Record comparative strengths in `QUEST_1GENPOKEMONVR_AUDIT.md`.
- [x] Complete the first clean-room feature milestone: working Quest display
  refresh-rate selection, physically verified at 72 Hz.
- [x] Add a clean-room native controller ray pointer with live-frame launcher
  activation; no source from the unlicensed comparison project was copied.
- [ ] Add gaze fallback and drag scrolling to the working ray pointer.
- [ ] Add Quest render-scale and draw-distance presets tied to measured budgets.
- [ ] Evaluate directional/chunk culling against our location-aware streamer.
- [ ] Improve layered battle presentation without regressing Pokédex UI.
- [ ] Harden atomic SAF/mod imports and low-memory ZIP handling.
- [ ] Revisit PCVR controller profiles only during the PCVR phase.

## Priority 15 — Quest 2 feasibility and reduced-quality profile (0%, lowest priority)

This begins only after the Quest 3 standalone release and PCVR release are
stable. Quest 2 support is a feasibility goal, not a release promise: its lower
CPU/GPU and memory headroom may require visual compromises that are not worth
maintaining.

- [ ] Obtain a physical Quest 2 for profiling and regression testing.
- [ ] Establish a Quest 2 stock/flat baseline before attempting voxel VR.
- [ ] Measure memory, GPU allocation, thermals and sustained frame delivery.
- [ ] Create a separate auto-detected `QUEST 2` quality profile without
  reducing Quest 3 defaults.
- [ ] Test substantially lower render scale, shadows, draw distance, active
  chunks, model density, effects and mirror/Pokédex resolution.
- [ ] Prefer 72 Hz and conservative thermal settings unless measurements prove
  another target viable.
- [ ] Test the minimum essential stack first: Dramaless plus Kanto First Person.
- [ ] Add Wilds of Kanto and other mods individually only if headroom remains.
- [ ] Decide whether the result is playable and maintainable; document Quest 2
  as unsupported if acceptable comfort and stability cannot be reached.

## Completed foundation

- [x] Audit Gen1Recomp/LÖVE, Android, ARM64, SDL/EGL, graphics and mod loading.
- [x] Reproduce the stock Android build.
- [x] Build and install a native ARM64 Quest APK.
- [x] Implement Android OpenXR loader and native Quest bridge.
- [x] Reach stereoscopic voxel gameplay with head tracking on Quest.
- [x] Reach functional Touch gameplay controls.
- [x] Preserve ROM-free APK distribution and legal user import workflow.
- [x] Move active workspace/build storage to `E:`/larger drives.
- [x] Create milestone commits, debug log, build notes and rollback points.
- [x] Push the main Quest work to the user's GitHub repository.
- [x] Archive written permission for the two primary mod forks.
- [x] Isolate the generic PR 5 Quest/OpenXR backend and physically validate its
  launcher, pointer, recenter, Yellow handoff, voxel controls and frame-capture
  paths.
- [x] Establish the q16 Quest 3 visual baseline: full resolution, low shadows.

## Active checkpoint — Dramaless 2.0 q3 physical acceptance (100%)

- [x] Move the four-vertex/six-index terrain sink into the approved Dramaless
  fork instead of relying on an older engine-side adapter.
- [x] Move bounded warm/history APIs and Route 2 priority into the fork.
- [x] Add observation-only mesh-job and map-entry diagnostics.
- [x] Pass both focused Quest contracts and deterministic ROM-free packaging.
- [x] Copy `DRAMALESS_SHAPE-1.6.4-quest.17.zip` to Quest Downloads.
- [x] Detect and document that the first headset attempt retained q16; do not
  count its 25.02 FPS partial sample as q17 evidence.
- [x] Charge the headset and cold-launch q17.
- [x] Confirm q17 version, Full eye dimensions, 72 Hz and immersive traversal.
- [x] Complete the matched Full/Low traversal; preserve its frame, memory,
  battery and thermal evidence without claiming an idle-confounded comparison.
- [x] Fix the sandboxed observer transport in deterministic q18 and copy it to
  Quest Downloads.
- [x] Freeze q18 as the rollback tag/artifact rather than overwriting it.
- [x] Merge official Dramaless 2.0 and the q18 Quest line in isolated commit
  `00c4d4c`; no launcher/APK source changed.
- [x] Pass automated tests and reproducibly package/stage 2.0 q1 on Quest.
- [x] Confirm q1 launcher and colored loading handoff worked; OpenXR started,
  audio continued, but the voxel pipeline disabled on missing pose math.
- [x] Diagnose the exact log failure and stage q2 with all `VRRig` matrix
  dependencies present and covered by a numerical test.
- [x] Import q2; confirm the launcher/loading/OpenXR handoff reaches voxel.
- [x] Reject q2 after its first voxel view proved badly misaligned between the
  eyes; retain the screenshot and do not ask the user to walk in that build.
- [x] Stage q3 with direct OpenXR `projection * view` per eye and no changes to
  the launcher, APK, controllers, streaming, flat camera, or battle camera.
- [x] Import q3; confirm the launcher remains stable, upright and clickable.
- [x] Confirm q3 cold-loads as fresh PID `15300` and Yellow enters comfortably
  aligned immersive stereo voxel VR at full 1680x1760 resolution per eye.
- [x] Confirm q3 controls/head tracking and verify Quest recenter keeps the
  world level, centered and stereo-aligned.
- [x] Pass q3 controller sleep/wake: controls resume, voxel remains active and
  the loading-screen freeze does not recur.
- [x] Confirm q3 Pokedex contextual capture turns on for menu/dialogue and is
  acceptably centered.
- [x] Confirm the formerly zoomed/misaligned Pokedex battle feed is correctly
  framed under Dramaless 2.0 q3; close the lingering sizing defect.
- [x] Pass q3 battle regression: view/UI present, controls remain functional
  during and after battle, and exploration stereo restores normally.
- [x] Fix the localized Route 8 world battle-camera obstruction with Kanto q6's
  per-arena wide rig; physically accepted without changing the fixed Pokedex
  battle feed or the global battle camera.
- [x] Physically validate q7's separate Route 12 water-stage correction; the
  user reports the corrected environment/camera works perfectly.
- [x] Reconfirm Route 8 and an unaffected Route 5 battle under q7. The main
  battle view, stereo and gameplay passed; the Pokédex's initial stale frame
  refreshed on the next UI change. Promote q7 and retain q6 as an archival
  Route 8 rollback.
- [x] Confirm one route/town transition and one building entry/exit without a
  loading freeze, input loss or stereo regression.
- [x] Confirm clean Quit and cold relaunch: PID `15300` exited itself with status
  `0`; fresh PID `20179` loaded q3, completed the launcher-to-gameplay OpenXR
  handoff and reached voxel on Route 8.
- [x] Pass route/town transition lifecycle on q3: no loading freeze, input or
  stereo loss. Retain visible actors through missing/distance-culled terrain as
  the medium-high Battle Art/streaming continuity defect above.
- [x] Pass q3 building entry/exit independently; the retained continuity issue
  is outdoor terrain/actor presentation rather than general warp lifecycle.
- [x] Retain logs and prove `VRSTREAM`/`MESHJOB2` across the transition.
- [x] Promote q3 as the core comparison baseline; retain q18 as the immutable
  emergency rollback because no launch, input, lifecycle or stereo regression
  appears.

## Waiting on outside events or user hardware

- [x] User completed q3 clean Quit/cold relaunch; Android exit history and the
  fresh q3 process confirm the complete physical core matrix passed.
- [x] Battle Art source/guidance target selected: version `1.8.6`, commit
  `0649420`, with permission to reuse useful current precaching behavior.
- [ ] Dramaless public fork destination created/approved; the Kanto Quest fork
  already exists.

## Suggested execution order

1. Restore Kanto First Person's complete guarded patch on Dramaless 2.0 q3 in
   the approved Kanto Quest fork and physically validate the combined stack.
2. Audit exact Battle Art 1.8.6 commit `0649420`, explain `VoxelScene.lua`
   line 499, and compare its current precacher with the q3 bounded streamer.
3. Implement/test the smallest safe transition change, then only the useful
   current-API precaching pieces; keep StadiumBattleFX 2.0 modular.
4. Run a matched physical transition benchmark and retain q18 until device
   evidence proves hitch/pop-in improvement without unacceptable memory cost.
5. Use the q3/Battle Art trace evidence to identify any remaining dominant
   mesh cost; repeat the full Saffron/Lavender route only if needed.
6. Run Full/Off as the remaining shadow comparison only after transition work;
   keep it only if the measured gain earns the visual loss.
7. Finish the clean PR 5 source audit, full vanilla regression matrix and
   upstream submission without moving mod-specific code into the engine.
8. Eliminate intermittent immersive loading stalls and continue lifecycle soak.
9. Rebase current Quest compatibility changes into the formal Kanto fork and
   profile its costs independently.
10. Add gaze fallback/drag scrolling to the already-working ray pointer only
   after core performance and release gates.
12. Validate sprite provider 0.1.4 and the Route 7/8 side-door prototype in
   their dedicated tasks.
13. Track later Dramaless/Battle Art releases, then begin Gen 2 voxel
   renderer work after the Gen 1 baseline holds.
14. Resume Portal/MR, then PCVR; evaluate Quest 2 only after PCVR release.

## How to use this file

- Check a box only when its completion condition is met.
- Update the percentage whenever a meaningful milestone lands.
- Link new specialized task logs here instead of creating competing master lists.
- If a task regresses, uncheck it; a previously working result is evidence, not a guarantee.
- Keep ROMs, extracted game data, saves and commercial assets out of Git/releases.
- Keep the private HGSS derivative entirely outside this public repository and APK.

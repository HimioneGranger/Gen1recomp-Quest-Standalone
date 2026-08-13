# Gen1Recomp Quest VR — Master Roadmap

Last reconciled: 2026-08-13

This is the single checkbox list for the project. Percentages are estimates of
the work completed for that item, including required physical headset testing.
An item is checked only when it is complete enough to rely on; a successful
prototype alone does not count as 100%.

## At a glance

- **Standalone Quest VR core:** 90%
- **Current v0.1.79 integration:** 100% (promotable Quest baseline)
- **Stable Dramaless + Kanto experience:** 80%
- **Dramaless q18 streaming milestone:** 90% (q17 route passed; q18 trace proof pending)
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

## Priority 3 — Dramaless VR maintenance (82%)

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
- [ ] Import q18 and prove `VRSTREAM`/`MESHJOB2` on one physical transition.
- [ ] Track `battle-art-merge` / `1.6.5.PRE` without using it as stable yet.
- [ ] Adapt VR capture to new battle-art, voxel-precache, mesh and loading systems.
- [ ] Make Quest integration seams patchable without copying whole upstream files.
- [ ] Add automated checks for expected Dramaless source versions/functions.
- [ ] Perform the complete physical regression matrix after every update.

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

Current checkpoint: q17 passed a charged cold physical route, but its observer
could not see the engine's function-valued logger inside the mod sandbox. q18
routes the same records through the already-working native VRXR trace channel,
passed contracts/syntax/deterministic packaging, and is in Quest Downloads.
Import q18, cold-load it, and cross one map boundary while logs are retained.

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

- [x] Run Kanto First Person successfully with Dramaless on Quest.
- [x] Obtain explicit creator permission for a Quest fork and optimization.
- [x] Identify first/third-person as the intended primary experience.
- [x] Confirm standard third-person is explicitly disabled while VR is active.
- [x] Create the formal Quest fork and retain creator attribution.
- [x] Sync the creator's official 1.60.0 release-package source as a separate
  provenance commit because its Git tag still identifies 1.57.2 internally.
- [x] Add ROM/save/cache/credential packaging guards and a reproducible
  `1.60.0-quest.1` package script.
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
- [ ] Maintain a machine-readable known-good mod/version matrix.
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

## Active checkpoint — q18 transition profiler (90%)

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
- [ ] Import/cold-load q18 and prove `VRSTREAM`/`MESHJOB2` across one boundary.
- [ ] Identify the dominant mesh phase from the corrected records.
- [ ] Implement only the evidence-backed optimization, then rerun the route.

## Waiting on outside events or user hardware

- [ ] Quest connected, awake and USB debugging authorized for the short q18
  import/cold-load/one-transition trace proof.
- [ ] Next stable Dramaless release/tag identified before rebasing the stable fork.
- [ ] `battle-art-merge` declared stable or explicitly selected for an experimental build.
- [ ] Dramaless public fork destination created/approved; the Kanto Quest fork
  already exists.

## Suggested execution order

1. Import and cold-load q18, then prove its native structured trace on one map
   transition.
2. Use the q18 phase evidence to identify the dominant mesh cost; repeat the
   full Saffron/Lavender route only if the short trace is insufficient.
3. Run Full/Off next as the requested shadow comparison, after Full/Low is
   valid, and keep the visual/performance tradeoff only if it earns its cost.
4. Implement and retest the smallest evidence-backed streaming optimization.
5. Finish the clean PR 5 source audit, full vanilla regression matrix and
   upstream submission without moving mod-specific code into the engine.
6. Eliminate intermittent immersive loading stalls and continue lifecycle soak.
7. Rebase current Quest compatibility changes into the formal Kanto fork and
   profile its costs independently.
8. Add gaze fallback/drag scrolling to the already-working ray pointer only
   after core performance and release gates.
9. Validate sprite provider 0.1.4 and the Route 7/8 side-door prototype in
   their dedicated tasks.
10. Track the next stable Dramaless/battle-art release, then begin Gen 2 voxel
   renderer work after the Gen 1 baseline holds.
11. Resume Portal/MR, then PCVR; evaluate Quest 2 only after PCVR release.

## How to use this file

- Check a box only when its completion condition is met.
- Update the percentage whenever a meaningful milestone lands.
- Link new specialized task logs here instead of creating competing master lists.
- If a task regresses, uncheck it; a previously working result is evidence, not a guarantee.
- Keep ROMs, extracted game data, saves and commercial assets out of Git/releases.
- Keep the private HGSS derivative entirely outside this public repository and APK.

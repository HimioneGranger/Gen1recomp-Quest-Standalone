# Gen1Recomp Quest VR — Master Roadmap

Last reconciled: 2026-08-12

This is the single checkbox list for the project. Percentages are estimates of
the work completed for that item, including required physical headset testing.
An item is checked only when it is complete enough to rely on; a successful
prototype alone does not count as 100%.

## At a glance

- **Standalone Quest VR core:** 82%
- **Current v0.1.79 integration:** 98% (short lifecycle regression passed)
- **Stable Dramaless + Kanto experience:** 73%
- **Performance and lifecycle hardening:** 63%
- **Gen 2 engine readiness:** 70%
- **Gen 2 voxel/VR gameplay:** 10%
- **Side Door Fix:** 35%
- **Gen 2/HGSS sprite-provider work:** 86%
- **Portal/MR modes:** 10%
- **PCVR release path:** 15%
- **Overall playable Quest release:** **76%**
- **Whole long-term vision, including Gen 2, MR and PCVR:** **43%**

## Priority 1 — Validate the official v0.1.79 build (98%)

- [x] Preserve the fully validated `v0.1.78` APK as the rollback baseline.
- [x] Fetch official signed `v0.1.79` source tag (`04490c9b`).
- [x] Merge it into isolated `quest-gen2-beta-v0.1.79` branch without conflicts.
- [x] Build and inspect a ROM-free multi-ABI Quest APK.
- [x] Import Dramaless Quest `1.6.4-quest.3` and run the physical regression.
- [x] Verify Route 8 -> Lavender -> Route 8 avoids a second mesh rebuild.
- [x] Validate Dramaless Quest `1.6.4-quest.6` B/cancel across Mod Manager.
- [x] Validate controller sleep/wake and two short headset suspend/resume cycles.
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

## Priority 2 — Establish official Quest mod forks (56%)

- [x] Receive written permission from Kanto in First Person creator `briddsy`.
- [x] Receive written permission/blessing from Dramaless creator Stahltier.
- [x] Archive screenshots, hashes, dates and scope in `docs/permissions/`.
- [x] Clone a pristine Dramaless upstream mirror.
- [x] Create a dedicated Dramaless Quest fork/repository and `quest-vr` branch.
- [ ] Create a dedicated Kanto in First Person Quest fork/repository and branch.
- [x] Preserve upstream licenses, credits and inherited third-party notices.
- [x] Clearly label builds as Quest-maintained and not headset-tested upstream.
- [x] Move validated VR conductor helpers into the mod; retain a defined native host boundary.
- [x] Add reproducible packaging scripts and version the APK/mod compatibility pair.
- [x] Physically import `1.6.4-quest.1` and verify Yellow reaches the voxel world.
- [ ] Add automatic upstream comparison notes for each new Dramaless release.

## Priority 3 — Dramaless VR maintenance (70%)

- [x] Port OpenXR session creation to standalone Android/Quest.
- [x] Render stereoscopic Quest frames with head tracking and 6DoF.
- [x] Implement launcher-to-game XR session handoff.
- [x] Implement Touch-controller launcher and gameplay mappings.
- [x] Implement room anchoring and Quest recenter response.
- [x] Restore stable thin green launcher focus ring.
- [x] Fix major Pokédex alignment/capture regressions to a usable state.
- [x] Add Quest canvas lifetime cleanup and route-history release seams.
- [x] Rebase the Quest adapter onto stable Dramaless `v1.6.4` in the dedicated fork.
- [ ] Track `battle-art-merge` / `1.6.5.PRE` without using it as stable yet.
- [ ] Adapt VR capture to new battle-art, voxel-precache, mesh and loading systems.
- [ ] Make Quest integration seams patchable without copying whole upstream files.
- [ ] Add automated checks for expected Dramaless source versions/functions.
- [ ] Perform the complete physical regression matrix after every update.

## Priority 4 — Reliability, loading and performance (63%)

- [x] Replace the original always-load-everything behavior with bounded streaming.
- [x] Add location-aware preload and route/town transition preparation.
- [x] Improve initial traversal and several Viridian/Route 23 transitions.
- [x] Add clearer classic-style VR loading presentation.
- [x] Improve loading text legibility.
- [x] Release superseded Quest canvases instead of waiting for garbage collection.
- [x] Drop redundant previous route history after safe connection/Fly transitions.
- [ ] Eliminate intermittent immersive loading-screen stalls.
- [x] Confirm controller wake/reactivation no longer stalls in the v0.1.79/q6 test.
- [ ] Make suspend/resume reliable after short and long sleep.
- [ ] Prevent occasional strange boot into mod screen with mouse cursor.
- [ ] Profile and reduce sustained ~2.0–2.3 GB memory use and large graphics allocation.
- [x] Compare FULL/HIGH against `1/2`/LOW on physical Quest; keep the lower
  preset as the Quest default candidate while targeting CPU mesh/draw work.
- [ ] Reduce thermal slowdown during long mod-heavy sessions.
- [ ] Revisit Route 2/Victory Road tree pop-in without restoring constant stutter.
- [ ] Profile Indigo Plateau/Victory Road loading and add safe regional preloading.
- [ ] Validate Saffron, Celadon, Lavender, forests, caves and major interiors.
- [ ] Run a 30–60 minute traversal/battle/suspend stress test.

## Priority 5 — Quest controls and launcher polish (85%)

- [x] Support Touch buttons, triggers and thumbsticks.
- [x] Fix launcher focus movement and selection targeting.
- [x] Make mod-management modal buttons selectable on Quest.
- [x] Correct upside-down/super-zoomed launcher capture regressions.
- [x] Anchor launcher in space and follow Quest recentering.
- [x] Preserve the upstream launcher instead of maintaining an independent launcher.
- [ ] Recheck every modal in v0.1.78: import, update, enable, disable, delete and file picker.
- [ ] Test delayed launcher interaction after leaving it idle.
- [ ] Low priority: visually refine focus-ring alignment and thickness.
- [ ] Low priority: polish slight launcher tilt after recenter.

## Priority 6 — Pokédex and flat-feed presentation (72%)

- [x] Restore usable exploration/dialogue/menu feed.
- [x] Fix the major dark-strip/misalignment defect.
- [x] Make the selector arrow visible.
- [x] Center the current usable capture closely enough for play.
- [x] Turn the screen off when no dialogue/text/menu feed is needed without hiding the device.
- [ ] Verify current fixes survived v0.1.78 and the next Dramaless update.
- [ ] **Medium priority:** repair the broken v0.1.79 Pokédex battle feed and
  keep battle information readable; diagnose capture activation/framing first.
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
- [ ] Import a legally obtained supported Gold ROM on Quest.
- [ ] Validate launcher → Gold → flat gameplay on Quest.
- [ ] Verify saves, controls, battles, interiors and suspend/resume in Gold.
- [ ] Acquire/use standalone LuaJIT and rerun complete member-coverage `gen2check` audits.
- [ ] Design the Dramaless Gen 2 renderer port using public/shared Gen 2 seams.
- [ ] Decide which Kanto First Person camera behavior is generation-independent.
- [ ] Port Wilds/Wild Skies only where features make sense for Gold.
- [ ] Keep Crystal 251 Gen 1-only unless a nonduplicated feature is deliberately redesigned.

## Priority 8 — Kanto in First Person Quest fork (55%)

- [x] Run Kanto First Person successfully with Dramaless on Quest.
- [x] Obtain explicit creator permission for a Quest fork and optimization.
- [x] Identify first/third-person as the intended primary experience.
- [x] Confirm standard third-person is explicitly disabled while VR is active.
- [ ] Create the formal Quest fork and retain creator attribution.
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

## Priority 11 — Mod-stack compatibility (70%)

- [x] Validate Dramaless + Kanto First Person + Wilds of Kanto.
- [x] Validate Wild Skies and observe worthwhile flying encounters.
- [x] Validate Crystal 251 flat/voxel gameplay with controls surviving transitions and battle.
- [x] Upload/test additional sky mods and identify Dramatic Sky Ride altitude/control limitations.
- [x] Preserve the user ROM-import and mod-import workflow.
- [ ] Retest accepted stack under v0.1.78.
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

## Waiting on outside events or user hardware

- [ ] Quest connected, awake and USB debugging authorized for beta regression.
- [ ] Legally obtained supported Gold ROM available for Gold import test.
- [ ] Next stable Dramaless release/tag identified before rebasing the stable fork.
- [ ] `battle-art-merge` declared stable or explicitly selected for an experimental build.
- [ ] Kanto/Dramaless remote fork repositories created or destination names approved.

## Suggested execution order

1. Complete the v0.1.78 physical Quest regression.
2. Establish the two official Quest mod forks and reproducible packages.
3. Fix loading/suspend/controller-wake reliability.
4. Validate sprite provider 0.1.4 in its dedicated task.
5. Build the targeted Route 7/8 side-door prototype in its dedicated task.
6. Run the Gold flat-game baseline.
7. Rebase VR onto the next stable Dramaless release and monitor its merge branch.
8. Finish sustained performance/thermal hardening.
9. Begin Gen 2 voxel renderer work only after Gold flat play is proven.
10. Resume Portal/MR, then PCVR, after the stable Quest release is dependable.

## How to use this file

- Check a box only when its completion condition is met.
- Update the percentage whenever a meaningful milestone lands.
- Link new specialized task logs here instead of creating competing master lists.
- If a task regresses, uncheck it; a previously working result is evidence, not a guarantee.
- Keep ROMs, extracted game data, saves and commercial assets out of Git/releases.
- Keep the private HGSS derivative entirely outside this public repository and APK.

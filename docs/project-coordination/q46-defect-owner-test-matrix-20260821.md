# Q46 defect-to-owner/test matrix

Recorded: 2026-08-21
Integration owner: `pokemon-q46-integration-build-r1`
App base: clean `45fd358cf51eb90a35a9a164879d85be64200d9c`
DRAMALESS base: clean Q45 identity repair `d4f620554d0f39255bf4a661f79df396896d75a9`
Finalized paired evidence: `artifacts/q45-device-acceptance-20260821T123923329Z-003`

## Evidence rules

- `Direct` means the finalized MP4 or its aligned log proves the stated fact.
- `User report` means the capture ledger records the user's observation, but the saved pair does not prove the full defect or its exact time.
- Fixed 2 fps sequence timestamps identify captured frames. They do not prove runtime speed.
- Host tests and package proofs do not establish Quest acceptance.
- No item can use Ultra Cloud C2 until every device gate reports `READY`.

## Matrix

| # | Defect or integration item | Evidence and current diagnosis | Source owner | Focused acceptance test | Entry state |
|---:|---|---|---|---|---|
| 1 | Eliminate duplicate loading-screen presentation. | **User report.** Sampled frames do not prove both presentations. App source has one bounded Quest launcher handoff in `QuestLaunchProgress`; native/launcher ownership must be traced before change. | App/launcher | Contract proves one presentation owner and one start-to-game transition; loading suite and four-flavor package checks. | Diagnose, then smallest app change. |
| 2 | Mirror crescent to the opposite orientation and keep Water consistent. | **Direct:** crescent exists in outdoor frames. **User report:** required side is opposite. Sky and Water are DRAMALESS-owned and must share the same body transform. | DRAMALESS Sky/Water | Shared crescent-orientation contract checks Sky and Water use one mirrored phase/body transform; shader/package tests. | Ready for isolated repair. |
| 3 | Remove gray strip on signs. | **Direct:** gray sign/bar geometry is present in frames 46-57. Whether each gray state is wrong remains the user's acceptance judgment. Q44 sign glass exclusion exists and must be checked for a missed geometry path. | DRAMALESS scene/sign geometry | Content-neutral sign fixture proves no glass/gray-strip draw while approved facade courses remain; scene and mesh-budget regressions. | Diagnose captured path, then repair. |
| 4 | Restore approved Pokedex chest anchor. | **User report.** Logs prove the Pokedex render path was active, not that the anchor was correct. Compare Q45 anchor math with the last approved anchor checkpoint; do not guess a new pose. | DRAMALESS Pokedex | Exact approved anchor constants and standing/seated world-transform contract; no full-HMD lock; recall and drop tests unchanged. | Evidence comparison required before edit. |
| 5 | Keep Pokedex visible on grab; preserve atomic transfer and right-stick recall. | **User report.** The aligned log has repeated `pokedex-capture` and `pokedex-draw` records, but sampled video does not prove the grab transition. Current placement can clear the frame when a pose is temporarily absent. | DRAMALESS Pokedex/input | Atomic stowed-to-held transfer test has no frame with neither owner; bounded pose-loss fallback; right-stick recall, drop, and session-reset regressions. | Ready for focused state-machine repair after trace correlation. |
| 6 | Diagnose/fix brief full black frames. | **User report.** Final ledger found no near-black sampled frame. Potential app surface/lifecycle and DRAMALESS canvas-state owners remain unproved. | Joint diagnosis; one final owner after evidence | Log/window correlation plus render-state fault injection; prove every submitted XR frame has a valid presentation source or explicit retained prior frame. | Block code change until root cause is proved. |
| 7 | Diagnose/fix collapse to a small central game square with black surround. | **Repeated user report.** Sampled sequence does not prove an occurrence. Likely viewport/canvas/reference-space class, but ownership is not yet proved. | Joint diagnosis; app compositor is primary suspect | Resize/surface/re-entry state-machine contract; repeated transition test proves full panel extent and no stale viewport/scissor/canvas. | Block code change until root cause is proved. |
| 8 | Diagnose/fix slowdown and severe-slowdown windows. | **User report.** Fixed-rate MP4 timestamps cannot prove speed. Aligned logs are the only timing source. High-frequency per-frame Q45 diagnostics are a candidate cost and require measured correlation. | Joint profiling; DRAMALESS trace owner if confirmed | Parse aligned frame timing and event rates; bounded diagnostic cadence test; host stress budget; new Quest proof remains a device gate. | Diagnose from aligned logs before edit. |
| 9 | Integrate universal collision-safe adjacent companion spawn. | **User report** triggered the repair; no captured tile proof. Released clean DRAMALESS commit `637048569f03a4ee8169fcf00164fbc867587fa9` descends from Q45 `d4f6205`. It rejects player tiles, collision, doors, warps, NPCs, moving targets, and companions. | Released DRAMALESS companion owner; Q46 integrates exact commit | Existing invariant covers all lifecycle entries, four cardinal patterns, occupied/hazard cells, prior-safe/defer fallback, and Yellow; full DRAMALESS suite. | `READY`; integrate exact released commit. |
| 10 | Hide inactive T-Shift and V-Curve in launcher settings, Gen1, Gen2, and mod manager while preserving values. | **Direct:** frames 50-56 show both rows. Current shared filter rejects normalized `tshift` and `vcurved`, but the captured `V-CURVE` normalizes to `vcurve`; this is an exact parity gap. Four consumers already call the shared filter. | App/launcher | Shared-key/label variants for `tshift`, `vcurve`, and legacy `vcurved`; four consumer contracts; saved values byte-identical; desktop rows unchanged. | `READY` for narrow shared-filter repair. |
| 11 | Integrate panel gaze line at 35% from top. | Released clean app checkpoint `45fd358c`; exact shared offset `-0.174375 m`; focused contract and four APK variants passed. It supersedes halfway and 40%. | Released app panel owner | Existing exact geometry contract plus panel, OpenXR, loading, flavor, and package gates. | `READY`; already present in app base. |
| 12 | Integrate Ultra Cloud C2 only if every gate is ready. | Gate verdict is **NOT READY**. Clean source `c82c3e64`, compatibility `b7d9c687`, deterministic package `6535FC65...`, and independent host review pass, but paired-headset GLES, stereo, tint, real Water reflection, and configured-refresh performance evidence is absent. | Ultra Cloud owner; Q46 must not mutate it | Sole `-003` headset execution plan and all stated device gates. | `BLOCKED`; exclude from Q46 and ledger exact blocker. |
| 13 | Reflect characters, NPCs, companions, and Pokemon in Water through existing cast-reflection architecture. | New requirement. DRAMALESS `VoxelScene` already has a reflection-only cast pass and terrain-depth occlusion comments/contracts. Coverage of every dynamic sprite class and real Quest cost is not yet proved. | DRAMALESS scene/Water | One reflection-only submission for each dynamic class; correct terrain/water occlusion; zero duplicate main-scene draw; draw/triangle budget instrumentation; full host suite. Device frame-time proof remains explicit. | Implement only through existing cast pass; final acceptance keeps device-performance gate. |

## Cross-item order and ownership gates

1. Preserve the finalized Q45 MP4, aligned log, marker, ledgers, installed APK copy, and hashes unchanged.
2. Commit this matrix before implementation.
3. Repair app-owned items in the current clean app worktree. Do not import DRAMALESS source into the app.
4. Continue DRAMALESS only from released clean commit `637048569f03a4ee8169fcf00164fbc867587fa9` in its released worktree. Keep one owner for `Sky`, `Water`, `Pokedex`, `VoxelScene`, and shared render state.
5. Do not integrate Ultra Cloud C2. Record it as a blocker without copying its code or package.
6. Do not claim fixes for items 6-8 from source suspicion. Require aligned-log or executable-test evidence that identifies the owner.
7. Package only after focused repairs, full host suites, secret/static/protected-content scans, deterministic twin proof, and clean commits pass.
8. Produce one new non-overwriting Q46 candidate directory. Keep all Q45 and prior Cloud/panel candidate directories unchanged.

## Required final pair ledger fields

- App and DRAMALESS commit, parent, branch, and clean-state proof.
- Four app-variant names, package IDs, source payload hashes, APK hashes, signer identity, and instrumentation hash.
- DRAMALESS ZIP and deterministic-twin hash, source-to-package proof, inventory count, identity, version, and schema.
- Exact item-by-item inclusion, exclusion, host proof, device-only gate, rollback point, and evidence classification.
- Static, secret, protected-content, archive-safety, ROM/save/private-data, and diff checks.
- Explicit statement that no install, launch, import, enable, input, push, merge, publication, or release occurred.

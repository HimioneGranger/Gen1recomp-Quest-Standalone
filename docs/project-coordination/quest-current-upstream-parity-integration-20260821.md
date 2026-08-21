# Quest current-upstream parity integration

Date: 2026-08-21

Status: integration in progress; host-only; no device or external action is
authorized.

## Goal and ownership

This branch integrates the applicable current-upstream Gen 1 behavior into the
Quest compatibility-split successor. It preserves the stronger Quest launcher,
compatibility adapters, package identities, Quest UI, Android/OpenXR behavior,
mod hooks, loading screen, and current repairs.

- Canonical repository: `Documents\Gen1recomp-Quest-Standalone`, outside
  OneDrive.
- Task worktree: `Documents\Gen1recomp-Current-Upstream-Parity-Integration`,
  outside OneDrive.
- Task branch: `codex/quest-current-upstream-parity-20260821`.
- Branch start and Q47 app source:
  `b08e28b1e5ddee46767cae7dc168a4c09903692b`.
- Q47 compatibility base:
  `b7d9c6872bdfd8c089fb1e6912263eb00f2f6eae`.
- Q46 split-repair input:
  `5b7ce94f4d3a653bb7449ac4c746af9247c2819b`.
- Sanitized remote pull-request commit:
  `32313b8c4b1561441590d9f7e333844467084036` at
  `origin/codex/quest-core-split-sync-candidate-20260820`.
- Accepted Quest baseline:
  `c4f06e9641d445fb63418f0f9a2c9defcd99b185`.
- Audited upstream head:
  `d191aaa34d987866521d76e2e2b8f7bfb3067227` at `upstream/dev`.
- Audit evidence: untracked, preserved file
  `Documents\Gen1recomp-Upstream-Parity-Batch2\docs\project-coordination\quest-split-current-upstream-parity-audit-20260821.md`.

The audit enumerates 222 patch-unique upstream non-merge commits. It classifies
4 as portable Gen 1, 75 as prerequisite-sensitive applicable Gen 1, and 1 as a
true mixed conflict. This integration owns those 79 applicable items and the
applicable Gen 1 subset of the mixed item. Gen 2-only, platform-only, release,
build-only, and unrelated documentation changes remain outside this branch.

## Safety and preservation boundaries

- Do not work on `quest-stable`.
- Do not fetch, push, modify the draft pull request, merge, release, publish,
  install, launch, use a headset, or delete evidence.
- Do not copy the external DRAMALESS source into app history.
- Do not add a ROM, save, generated ROM data, APK, AAB, signing key,
  certificate, capture, private path, credential, or secret.
- Keep package identity, Quest flavors, ARM64/OpenXR packaging, SAF lifecycle,
  launcher focus, host adapters, loading screen, and compositor contracts.
- Prefer existing stronger Quest behavior when upstream behavior is weaker.
- Every batch must record its upstream SHA and exact imported path set, run its
  focused gates, pass `git diff --check`, and end in a commit.

## Baseline verification

At branch start:

- WSL LuaJIT engine: 195/195 suites passed.
- WSL LuaJIT Modkit: 15/15 suites passed.
- Accepted-baseline gate self-test: 9/9 passed.
- Git-for-Windows ancestry gate: passed for
  `c4f06e9641d445fb63418f0f9a2c9defcd99b185`.
- Native Windows LuaJIT engine: 194/195 because its `io.popen` resolves the
  POSIX `find` command in `build_zip_pipe_guard_bug774.lua` to Windows
  `find.exe`. The same unmodified suite passes under WSL. This is a host shell
  condition, not a product failure.

## Dependency and batch order

The audit lane contract controls the semantic order. The working order is:

1. Mod sandbox and API foundation M1, including the interleaved M8 device-power
   prerequisite `e44769a4` before the steps bridge.
2. M8 foundation through the source context for C7 and cadence prerequisite
   `a94fecfe`; then apply C7 and portable escort item C2 `43957922`.
3. Portable C8 and the open C9 TownMap, TradeAnim, and PaletteFX subsets after
   their focused presentation tests exist.
4. Remaining M8 gameplay and shared mod behaviors, split into complete Gen 1
   source/test units.
5. Save lifecycle M2, audio M3, extraction/catalog M4, renderer M5, link M6,
   and launcher M7 in their audited internal order.
6. Required-import foundation `542856c8` and `c48fc57`, followed by N1
   `2d28d18b`, `911e11a3`, `c465f580`, `c0bd4a35`, and `decaa006`.
7. N2 shared hook and Gen 1 subset.
8. X1 mixed commit split by owner: keep only applicable portable
   accelerometer behavior and any already-authorized Gen 1/Quest-compatible
   audio or launcher correction. Exclude Gen 2 and non-Quest platform changes.

## Completed batches

### Batch 1: sandbox, device, steps, and opaque storage foundation

Audit lanes: M1 and interleaved M8 prerequisite.

Upstream sources, in dependency order:

- `83682f011df5039c4ea7042141590d38ca7e21d5`
- `e44769a48a4e885ff0522dd0ca6e694464237288`
- `bde606f966ca5f58e351889a38d6427b50cc6f79`
- `9fab992d425305f3d1dc41eb0eb48162c1fcb541`
- `fb738fa1cee883ad15b0333235b5e4c6d1b9a1d9`

Exact inspected path set:

```text
CONTRIBUTING-mods.md
docs/modding.md
docs/new-features.md
docs/rfcs/0003-playthrough-storage.md
docs/rfcs/0008-device-power-info.md
docs/rfcs/0009-step-bridge-permission.md
src/mods/AssetTransform.lua
src/mods/Loader.lua
src/mods/ManagerState.lua
src/mods/Manifest.lua
src/mods/Runtime.lua
src/mods/SafePath.lua
src/mods/Sandbox.lua
src/mods/Steps.lua
src/mods/Storage.lua
tests/integration/title_checkpoint_cold_start.lua
tests/mod_loader_tests.lua
tests/mod_manifest_tests.lua
tests/mod_render_tests.lua
tests/modkit/cases/checkpoints.lua
tests/modkit/cases/device_power_info.lua
tests/modkit/cases/platform_lifecycle_hooks.lua
tests/modkit/cases/sandbox.lua
tests/modkit/cases/steps_bridge.lua
tests/modkit/cases/storage.lua
tests/modkit/cases/title_playthrough_context.lua
tests/modkit_tests.lua
```

The transient upstream `mod-sandbox-notice.txt` and private absolute-path
symlink `mods/timekeepers_hut` are absent from `upstream/dev` and were not
imported.

Focused verification:

- ROM-free Modkit: 18/18 suites passed, including new sandbox, device-power,
  steps, storage, checkpoint, and Quest lifecycle-hook coverage.
- `tests/mod_manifest_tests.lua`: 99/99 passed.
- `tests/mod_render_tests.lua`: 58/58 passed.
- Cold-start checkpoint integration: capture and resume passed.
- Legacy `tests/mod_loader_tests.lua` and direct `tests/modkit_tests.lua` need
  generated ROM data or prior aggregate initialization in this checkout. They
  stopped at that existing boundary; no generated or private data was created.
- Staged diff and whitespace checks passed.

### Batch 2: shared Gen 1 test and scripted-step stability

Audit lane: M8.

Upstream source:
`52e36ad7e4a22b9fce2abbad8eeb754339085cf6`.

Exact imported path set:

```text
src/ui/OakSpeech.lua
src/world/OverworldController.lua
tests/integration/title_checkpoint_cold_start.lua
tests/mod_link_tests.lua
tests/parity_yellow_pallet_pikachu.lua
tests/run_tests.lua
```

The Gen 2 source and all Gen 2 tests in the mixed upstream commit were not
imported. The listed Gen 1 source and shared fixture behavior was already in
the Q47 successor or Batch 1. Applying the filtered upstream patch produced no
new source or test delta. Commit `347a7dce` is the durable equivalence and test
record only.

Focused verification:

- Minimal Oak intro construction with no sprite table: passed.
- Cold-start checkpoint capture and resume: passed.
- Timing parity: 163/163 passed.
- Title fill, cycle, and zone seams: 8/8, 104/104, and 82/82 passed.
- ROM-backed link and Yellow Pallet aggregate cases remain unavailable because
  this worktree has no generated private ROM data.
- Staged diff and whitespace checks passed.

### Batch 3: Gen 1 story, world, and Yellow companion repairs

Audit lanes: M8 and portable C7.

Upstream sources, in dependency order:

- `37051a26b5b5732cc845441dbd66d1916a6925fb` world/story subset
- `f6a035947f7593baad6a9afca3b1157bfc76004a`

Exact imported path set:

```text
data/scripts/oaks_lab.lua
data/scripts/oaks_lab_yellow.lua
data/scripts/story.lua
data/scripts/story2.lua
data/scripts/story4.lua
data/scripts/story5.lua
src/world/NPC.lua
src/world/OverworldController.lua
src/world/PikachuFollower.lua
tests/engine/nurse_bow_bug995.lua
tests/engine/pewter_pikachu_content_translation_test.lua
tests/parity_B.lua
tests/parity_yellow_disabled_pikachu.lua
```

Battle, save, renderer, unrelated UI, Gen 2 source, and Gen 2 test paths from
the upstream bundle remain outside this batch. The C7 fallback is applied only
after its Pewter rest-scene source context exists. The added ROM-free
translation regression proves both affected interaction entry points.

Focused verification:

- WSL LuaJIT engine: 196/196 suites passed.
- C7 Pewter translation: 9/9 passed inside the engine tier.
- Updated Nurse Joy behavior: 25/25 passed.
- All Quest host, compositor, OpenXR, loading-screen, panel, SAF, settings,
  flavor, and lifecycle suites inside the engine tier passed.
- ROM-backed aggregate parity files remain unavailable because no generated
  private ROM data exists.
- Staged diff and whitespace checks passed.

## Final acceptance

The final branch must be clean and contain reviewable batch commits. Required
gates are focused tests per batch, full engine, full Modkit, accepted-baseline,
Android host and Quest contracts, deterministic packaging contracts, secret
scan, ROM/save scan, private-path scan, protected-content scan, provenance
comparison, `git diff --check`, and a final diff review against the Q47 source.
ROM-data suites remain skipped unless generated private ROM data is already
present; this task must not create it.

## Recovery point

Current recovery point: Batch 3 follows equivalence record `347a7dce`. Resume
with the next separated Gen 1 subsystem inside
`37051a26b5b5732cc845441dbd66d1916a6925fb`; do not replay its Gen 2 bundle.

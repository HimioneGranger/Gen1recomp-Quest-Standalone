# Quest current-upstream parity integration

Date: 2026-08-21

Status: integration in progress; host-only; no device or external action is
authorized.

## Goal and ownership

This branch integrates the applicable current-upstream Gen 1 behavior into the
Quest compatibility-split successor. It preserves the stronger Quest launcher,
compatibility adapters, package identities, Quest UI, Android/OpenXR behavior,
mod hooks, loading screen, and current repairs.

- Canonical repository: `C:\Users\bolay\Documents\Gen1recomp-Quest-Standalone`.
- Task worktree:
  `C:\Users\bolay\Documents\Gen1recomp-Current-Upstream-Parity-Integration`.
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
  `C:\Users\bolay\Documents\Gen1recomp-Upstream-Parity-Batch2\docs\project-coordination\quest-split-current-upstream-parity-audit-20260821.md`.

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

1. Portable world and presentation items whose prerequisites already exist:
   C7, C8, and the open C9 TownMap, TradeAnim, and PaletteFX subsets.
2. Mod sandbox and API foundation M1.
3. M8 foundation through cadence prerequisite `a94fecfe`, then portable escort
   item C2 `43957922`.
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

## Final acceptance

The final branch must be clean and contain reviewable batch commits. Required
gates are focused tests per batch, full engine, full Modkit, accepted-baseline,
Android host and Quest contracts, deterministic packaging contracts, secret
scan, ROM/save scan, private-path scan, protected-content scan, provenance
comparison, `git diff --check`, and a final diff review against the Q47 source.
ROM-data suites remain skipped unless generated private ROM data is already
present; this task must not create it.

## Recovery point

Current recovery point: this ledger on top of
`b08e28b1e5ddee46767cae7dc168a4c09903692b`. No upstream source item has been
integrated yet.

# Current upstream parity: final split-integration handoff

## Result

The Gen 1 Current Upstream Parity inventory is complete through upstream
endpoint `d191aaa34d987866521d76e2e2b8f7bfb3067227`. The exact non-merge
range `2b6473ae..d191aaa` has 184 rows and zero unclassified or unexplained
deferred rows.

## Canonical state

- Isolated workspace:
  `C:\\Users\\bolay\\Documents\\Gen1recomp-Current-Upstream-Parity-Continuation-20260822`.
- Start checkpoint: `b538373987d12d642c2979a72ad367a693cfa955`.
- Final source batch at that checkpoint: explicit launcher update checks for
  `5c1837b1eb61ca3501f47c443e44e8c38cd2cd53`.
- The final non-merge rows after the Gen 1 charge hook are fully classified:
  `bb0f1564` is Gold-only/inapplicable; `5c1837b1` is applied with the
  LauncherView optimization already equivalent.

## Preserved boundaries

Quest launcher, XR/OpenXR, compact labels, compatibility adapters, mods,
Android flavor and package identity, UI behavior, and all Q47 work remain
outside the final source batch except for the deliberate opt-in update change
in `src/import/RomImporter.lua`. No device, APK, network, merge, release, or
repository migration action was done.

Protected worktrees were read-only before work and must remain untouched:

- `C:\\Users\\bolay\\Documents\\Gen1recomp-Quest-Standalone` at
  `3a5ce828cdf3a660509d4c785727be834cd2a95d`, with its pre-existing untracked
  `artifacts-installed-original.apk` residue.
- `C:\\Users\\bolay\\Documents\\Gen1recomp-Current-Upstream-Parity-Integration`
  at `617902357f4353dfd9ee28bfc6250b6aba13cce2`, with its pre-existing ten
  tracked/untracked recovery residues.

## Verification

- Final launcher/Quest contracts: 20/20, 100/100, and load-report passed.
- Full Modkit: 23/23 passed.
- Full engine: 220/222 passed; two known Windows-only Unix-tool assumptions
  remain (`build_zip_pipe_guard_bug774`, `luajit_source_limits_test`).
- LuaJIT parsed 1549 tracked Lua files. Three Lua 5.3-only vendor/test files
  require a Lua 5.3 parser for a complete cross-version syntax gate.

## Next action

Do not replay further upstream rows for this endpoint. If a later upstream
endpoint is selected, start a new audited range from `d191aaa` and preserve
this completed ledger as the zero-gap baseline.

# Optional Quest OpenXR host backend

The `questVr` Android product flavor packages an optional native OpenXR host
that presents the existing Gen1Recomp launcher on a room-anchored quad. It is
an adapter around the ordinary launcher, not a second launcher implementation.
The desktop and stock Android variants neither compile nor package this host.

## Boundaries

- `HostBootstrap`, `HostDisplay`, `HostLifecycle`, and `ImportHost` are neutral,
  versioned API v1 boundaries. They contain no Quest or OpenXR policy.
- A packaged Android flavor can return one exact Lua adapter name through
  `love.system.getHostModule()`. Standard Android returns an empty name.
- `src/core/HostDisplay.lua` remains a generic no-op interface unless a host
  adapter installs a backend. The older packaged-display detector remains as
  a temporary rollback fallback until physical verification passes.
- `src/host/android/QuestOpenXRDisplay.lua` converts Quest Touch input into the
  launcher's existing virtual-pointer and button paths, and submits completed
  launcher-frame metadata to the native host.
- `libquestxr.so` owns the launcher OpenXR session, room anchor, controller-ray
  projection, thin focus border, and compositor pointer.
- LÖVE exposes one optional Android presented-frame observer. Its default is
  null and it contains no Quest or OpenXR dependency.
- A gameplay VR mod may use `QUEST_PANEL_ACTIVE` only as a capability signal:
  keep the panel session alive while preparing, then request the established
  launcher-to-gameplay OpenXR handoff. Stereo rendering remains mod policy.

The compositor pointer is launcher-only. Lua explicitly enables it for a
launcher frame; live native ray tracking may update coordinates only while
that visibility flag is enabled. This prevents the launcher selector from
appearing over a game frame or a mod-owned preparation card.

## Accepted-baseline sync gate

Do not classify a Quest/core integration branch as merge-ready until it passes
the non-device accepted-baseline gate:

```sh
scripts/verify_accepted_baseline.sh <accepted-baseline-ref>
```

The caller must explicitly supply the latest accepted Unplugged baseline as a
local branch, tag, or commit. The script resolves that value and `HEAD` to
commits, then uses Git ancestry to verify that the baseline is contained in
the candidate. It exits `1` when the candidate is stale or has diverged. It
exits `2` when the ref is missing, invalid, or cannot be resolved.

The verifier does not fetch or select a baseline. Fetch the trusted baseline
first when its local ref may be stale. CI must use a full-history checkout or
fetch the explicitly selected commit before it runs the command. For example:

```sh
git fetch origin <accepted-baseline-ref>
scripts/verify_accepted_baseline.sh FETCH_HEAD
```

`scripts/test.sh` runs the verifier's ROM-free functional suite, but that suite
does not select the accepted product baseline. The explicit command above is
the required merge-readiness gate.

## Physical validation — 2026-08-12

A Quest 3 test with Dramaless Shape `1.6.4-quest.14` passed the complete path:

1. launcher displayed upright and room-anchored;
2. Touch ray moved a crisp white selector and activated Yellow;
3. selector disappeared when launcher UI ended;
4. the mod's save-aware loading card updated on the retained panel;
5. launcher OpenXR exited and released its session cleanly;
6. gameplay OpenXR started and reached FOCUSED automatically.

The validated debug APK SHA-256 was
`7BE8565B7C7344D83954ACD79139FB8F1D37E65CD245F83F035AAEE928F6EF23`.
It was built as `questVrNoRecordDebug` and installed with `adb install -r`,
preserving app data.

## Generic completed-frame observer validation - 2026-08-13

Commit `b7fba361` adds the observation-only `render.frame_drawn` event after a
completed Lua draw and before host capture or ordinary presentation. The event
does not alter the frame, block presentation, or contain Quest/OpenXR policy;
with no subscribers it is a guarded no-op for vanilla and stock Android.

Dramaless Shape `1.6.4-quest.15` used this seam to restore its existing Pokedex
capture after the isolated backend removed the former Quest-specific global
callback from `main.lua`. On Quest 3, device logs confirmed q15 loaded in PID
`15729`, and the user physically confirmed that the Pokedex screen was
rendering again. No capture exception, GL error, fatal signal, ANR, or OOM was
observed in the validation interval.

The paired APK SHA-256 was
`8342334C3F6ED5D77A64E253FF86EB56355264D6B8CDC43ECEC296E88CBBB84E`.
The paired Dramaless q15 ZIP SHA-256 was
`E899C0B36530AC69FCBC8D5469F57FCCD025E0DA082574D61C1A733280E856CC`.
Sustained voxel frame rate remains a separate workload/performance issue and
is not classified as resolved by this presentation-seam test.

## Remaining validation

- Long suspend/resume and controller-sleep soak.
- Repeated launcher/gameplay handoffs and map transitions.
- Quit-path stress testing. One earlier build observed a native
  `pthread_mutex_lock called on a destroyed mutex` abort during shutdown; do
  not promote the backend until that race is reproduced or cleared by a
  sufficiently long lifecycle test.

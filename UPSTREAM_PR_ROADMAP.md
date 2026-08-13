# Upstream Quest Contribution Roadmap

Last audited: 2026-08-13
Comparison base: official `v0.1.79` (`04490c9b`)  
Integration branch at audit: `quest-gen2-beta-v0.1.79`

Current upstream extraction base: official `dev` at `c3136bf8` (`v0.1.80`
source head). PR 1 was submitted as
[#1199](https://github.com/bryanthaboi/gen1recomp/pull/1199) from commit
`1642113d`.

## Objective and boundary

Move reusable engine and host APIs into Gen1Recomp through small pull requests
that preserve vanilla behavior. Quest-specific OpenXR code may use those APIs,
but gameplay/rendering adaptations belonging to Dramaless Shape or Kanto in
First Person remain in their separately approved forks.

This branch is not suitable for a single pull request. Its diff combines
launcher input, updater policy, Android lifecycle code, an OpenXR bridge,
vendored headers, loading presentation, and mod-specific streaming/rendering.
Each item below must be reconstructed from the official development base and
must pass its own regression gate.

## Ownership rules

| Change | Destination | Rule |
|---|---|---|
| Platform-neutral input, lifecycle, panel/capture and extension APIs | Official Gen1Recomp PR | No Quest dependency in the default path; tested no-op behavior |
| Android build flavor and optional OpenXR host backend | Official PR only if maintainers accept platform support | Feature-gated; stock `embed` package remains unchanged |
| Dramaless VR conductor, voxel meshing, streaming and Pokédex capture policy | Dramaless Quest fork | Never bundled into an engine/API PR |
| Kanto camera/content/performance adaptations | Kanto First Person Quest fork | Never bundled into an engine/API PR |
| ROMs, saves, extracted caches and commercial assets | Nowhere | Never committed, packaged or attached to a PR |

## Proposed PR stack

### PR 1 — Generic focus navigation and modal activation

Status: **submitted upstream** as
[#1199](https://github.com/bryanthaboi/gen1recomp/pull/1199). The submitted
scope is deliberately smaller than the original proposal: it fixes routing of
the existing generic focus handler through mod dialogs and adds 24 ROM-free
checks. Optional focus visuals and broader host configuration remain future
work rather than being bundled into this bug fix.

Current evidence lives in `src/ui/kit/Kit.lua`, `src/import/LauncherView.lua`,
`src/import/RomImporter.lua`, and
`tests/engine/launcher_quest_modal_input_test.lua`. The current implementation
is not upstream-ready because behavior is keyed from global
`QUEST_PANEL_ACTIVE` and Quest-specific drawing is mixed into generic widgets.

Extract a host-neutral controller/focus API. The launcher should receive an
input capability or mode through an explicit interface, while desktop
keyboard/mouse defaults remain byte-for-byte equivalent in behavior. Keep the
focus visualization optional and themeable.

Acceptance:

- Headless tests cover tab movement, modal Enable/Update/Cancel, delayed
  activation and focus loss/restoration.
- Existing mouse hover/click, Enter shortcut, Escape and keyboard navigation
  tests remain green.
- Manual vanilla desktop launcher smoke test shows no new cursor/ring unless a
  controller-focus host explicitly enables it.

### PR 2 — Native panel/capture host interface

Status: **submitted upstream** as
[#1200](https://github.com/bryanthaboi/gen1recomp/pull/1200) from commit
`c2d9af69`. It introduces a generic optional `HostDisplay` lifecycle with
no-op vanilla behavior and no Quest/OpenXR dependencies. The stock
`assembleEmbedNoRecordDebug` Android build passed from source.

Current evidence lives in `main.lua`, `src/quest/PanelBridge.lua`, and the
Android `Graphics::present` hook. The current implementation directly imports
Quest code from `main.lua`, overrides `love.graphics.getDimensions` during a
draw, and calls a Quest symbol for every Android presentation. Those are useful
prototype results, not the desired public API.

Introduce a small optional host interface with no-op defaults for lifecycle,
input polling, panel capture and final-frame capture. Ordinary game/launcher
code should talk only to that interface. Backend registration must occur at
startup and must not require Quest globals.

Acceptance:

- Unit tests prove the absent backend is a no-op and does not alter draw order,
  canvas ownership, dimensions or screenshots.
- A fake backend test proves lifecycle and capture callbacks fire exactly once
  at documented points.
- Vanilla desktop and stock Android launcher/gameplay render identically in a
  manual smoke test.

### PR 3 — Engine payload compatibility contract

Status: **submitted upstream** as
[#1201](https://github.com/bryanthaboi/gen1recomp/pull/1201) from commit
`0aab11b6`. The generic `payloadHost` family complements the existing numeric
shell contract. Missing fields default to `love`, so old and current vanilla
payloads retain their behavior; specialized hosts explicitly opt into their
own family and cannot mount or delete another family's payload.

Current evidence lives in `src/update/Boot.lua`. The prototype correctly
prevents an incompatible generic Lua payload from being mounted over a paired
Quest native binary, but the policy is tied to `QUEST_PANEL_ACTIVE`.

Replace that global with a generic native-host compatibility identifier or
capability supplied by the packaged application. Document when an engine
payload may replace Lua modules and test both compatible and incompatible
hosts.

Acceptance:

- Pure tests cover ordinary desktop, network-disabled hosts, compatible native
  hosts and incompatible native/Lua pairs.
- Vanilla updater behavior is unchanged when no compatibility constraint is
  registered.

### PR 4 — Android native-extension lifecycle seam

Status: **submitted upstream** as
[#1202](https://github.com/bryanthaboi/gen1recomp/pull/1202) from commit
`ee00728e`. `GameActivity` now exposes protected no-op host library and
lifecycle hooks while preserving `liblove.so` as SDL's final/main library.
The stock `assembleEmbedNoRecordDebug` build passed, and APK inspection found
only the existing LÖVE libraries for ARM64, ARMv7 and debug x86_64—no Quest or
OpenXR payload.

Current evidence lives in `GameActivity.java` and `Android.mk`. The prototype
always calls a Quest JNI symbol from the shared activity and always compiles the
Quest bridge into `liblove`; only bootstrap is manifest-gated. Replace this
with an optional extension mechanism or a fully flavor-scoped source/library.

Acceptance:

- `assembleEmbedNoRecordDebug` succeeds without OpenXR headers, loader or Quest
  native symbols in its dependency/package graph.
- Activity creation, SAF ROM/mod import, pause/resume, audio and normal SDL
  lifecycle pass on stock Android.
- Extension callbacks are invoked only for the explicitly enabled flavor.

### PR 5 — Optional Quest/OpenXR Android backend

Status: **isolated and physically smoke-tested; not yet submitted upstream**.
The clean branch is `upstream-quest-openxr-backend` at `3b618679`. It has
passed stable launcher-panel presentation, room anchoring/recenter, Touch ray
pointer activation, live-frame handoff, Yellow -> immersive voxel startup,
gameplay controls, a true cold launcher handoff, short and 10+ minute resume
checks, and the generic completed-frame Pokédex restoration. It still needs a
final clean-source/stock-behavior audit, the complete regression matrix below,
and upstream-ready documentation before submission.

Current evidence lives in the `quest`/`questVr` Gradle flavors, their manifests,
`questxr_bridge.c`, Khronos headers and the loader dependency. Submit only after
PRs 2 and 4 establish accepted host seams. Prefer the official Khronos loader
dependency/source arrangement accepted by upstream rather than an unexplained
large generated-header diff.

Acceptance:

- ROM-free ARM64 Quest APK builds reproducibly from documented SDK/NDK/Gradle
  versions.
- `embed` output is unaffected and contains no OpenXR loader or Quest metadata.
- Quest checks cover launcher stereo panel, 6DoF, recenter, Touch input,
  suspend/resume, controller sleep/wake and clean launcher-to-game handoff.
- Failure to initialize OpenXR produces a clear recoverable path or diagnostic,
  not a loading-screen hang.

## Changes explicitly excluded from upstream engine PRs

- `src/quest/dramaless/**` and its mesher/streaming/history policies.
- Quest-specific Pokédex composition and battle-camera tuning.
- Save-location-aware voxel preloading and the VR loading-card artwork/policy.
- Kanto First Person camera behavior or authored map/content adaptations.
- Recommended mod packs, mod defaults and mod-specific performance presets.

These belong in the approved mod forks and should consume stable engine APIs.

## Required test matrix

| Gate | Every PR | Combined Quest stack |
|---|---:|---:|
| Upstream ROM-free `scripts/test.sh` / equivalent Windows suites | Yes | Yes |
| New focused headless unit tests | Yes | Yes |
| Vanilla desktop launcher/import/update/game smoke | If affected | Yes |
| Stock Android `assembleEmbedNoRecordDebug` | If Android/shared code affected | Yes |
| Stock Android device/emulator lifecycle + SAF import | If Android/shared code affected | Yes |
| Quest ARM64 ROM-free build/package inspection | Backend PR only | Yes |
| Physical Quest 3 stereo, 6DoF, recenter and Touch input | Backend PR only | Yes |
| Controller sleep/wake and 10+ minute suspend/resume | Backend PR only | Yes |
| Dramaless and Kanto fork compatibility | No | Yes |

All ROM-dependent physical tests use user-supplied legally obtained ROMs outside
Git and release artifacts. Test reports record the engine commit, mod package
version/hash, APK hash, device/runtime version and observed result.

## Working procedure

1. Fetch the current official development branch and record its commit.
2. Create one clean topic branch per PR from that commit; never submit the
   existing integration branch as a whole.
3. Reimplement or cherry-pick only the minimal relevant behavior, then remove
   Quest names from generic APIs.
4. Add the regression test before or with the implementation.
5. Run the relevant matrix and attach exact commands/results to the PR.
6. Request upstream review; revise the interface rather than working around
   review concerns downstream.
7. After acceptance, rebase the Quest integration branch onto the accepted API
   and delete the superseded engine patch.

## Immediate next action

Audit the isolated PR 5 branch against its clean upstream base, rerun the full
ROM-free engine and stock Android matrix, inspect the stock `embed` package for
XR metadata/libraries, and finish the remaining physical lifecycle checks.
Then prepare the upstream description and request review without including any
Dramaless, Kanto, ROM, save, cache or commercial-asset content.

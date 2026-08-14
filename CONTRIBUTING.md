# Working together

This repository is the Quest-facing integration of Gen1Recomp. Keep changes
small, visible, and easy for the other maintainer to pick up. An issue records
the decision; a branch contains the work; a pull request is the handoff.

## Start here

1. Pick or open an issue and write the intended outcome in one sentence.
2. Assign one driver and add the other partner as reviewer.
3. Branch from `quest-stable` using `feature/<topic>`, `fix/<topic>`, or
   `release/<version>`.
4. Make one concern per pull request. Draft pull requests are encouraged for
   work that needs early testing or design input.
5. Complete the pull request template, including the Quest test and
   performance sections when they apply.
6. Merge only after the required automated checks pass and the reviewer can
   reproduce the result.

## Work lanes

| Lane | Main paths | Handoff requirement |
| --- | --- | --- |
| Quest/OpenXR host | `mobile/android/app/src/questVr/`, `mobile/android/love/src/questVr/`, `src/host/android/`, `src/core/HostDisplay.lua` | ROM-free tests plus Quest 3 smoke test |
| Launcher/import | `src/import/`, `src/ui/`, `main.lua` | Test Red/Blue/Yellow selection; include Gold when touched |
| Engine/gameplay | `src/core/`, `src/world/`, `src/battle/` | Targeted test plus `scripts/test.sh --quick` |
| Mods and compatibility | `src/mods/`, `mods/`, `tools/modkit.py` | Follow `CONTRIBUTING-mods.md`; state API compatibility |
| Release/docs | `scripts/build_android.sh`, `.github/workflows/`, `README.md`, `docs/` | Follow `docs/quest-release-checklist.md` |

Changes may cross lanes, but the pull request must name the affected lanes so
the right person reviews each boundary.

`quest-openxr` preserves the earlier experimental mesher and panel work. Treat
it as a research/archive branch; do not use it as the base for public releases.

## Local checks

Run the smallest relevant test while developing, then the ROM-free suite
before handoff:

```sh
luajit tests/engine/host_display_test.lua
luajit tests/engine/android_host_extension_test.lua
luajit tests/engine/quest_android_flavor_isolation_test.lua
scripts/test.sh --quick
```

The complete runner may skip ROM-backed tiers when no private imported cache
exists. That is expected. Never add a ROM, save, generated cache, APK signing
key, or locally built package to Git.

For changes that touch Quest rendering, input, lifecycle, or handoff, also
install the APK on a physical Quest 3 and record the result in the pull
request. Emulator-only validation is not enough for those paths.

## Review and ownership

- The driver owns implementation, tests, and a concise handoff note.
- The reviewer owns reproducing the important behavior, not rewriting the
  driver's work in the review thread.
- Use review comments for code-specific decisions and issues for follow-up
  scope. Resolve a thread only when the code or the recorded decision answers
  it.
- If a change affects the upstream project, mod authors, or a published API,
  link the permission or coordination thread in the pull request without
  copying private conversation contents.

## Performance note

Every Quest-facing pull request labels its expected cost as **negligible**,
**low**, **medium**, or **high**, then includes a before/after measurement when
the cost is not negligible. Record the tested scene, headset refresh rate,
average FPS or frame time, and any visible hitching. If measurement is not yet
possible, say so and keep the pull request in draft.

## Releases

Release preparation happens on `release/<version>`. The release owner follows
[`docs/quest-release-checklist.md`](docs/quest-release-checklist.md), and the
other partner independently checks the APK identity, version, signer, and
download link before the release is announced.

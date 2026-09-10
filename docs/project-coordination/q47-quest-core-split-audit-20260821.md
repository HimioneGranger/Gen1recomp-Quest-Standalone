# Q47 Quest core-split integration audit

## Result

Merge commit `1eb0880aaf88ed4f579fcc818be60d3e1656bc46` joins clean split
checkpoint `e901fc00159c85ec92306487612871a6bb8f835c` and the complete
zero-gap parity endpoint `77c59d21802f7ab1b948e578f9fce88f65a3469d`.
The merge is reviewable and retains the versioned portable host boundary,
Quest/OpenXR behavior, Q46/Q47 repairs, V8 loading, 35-percent panel
placement, compact labels, package identities, mods, and portable behavior.

## Reference audit

| Reference | Classification | Evidence |
|---|---|---|
| `codex/launcher8-deep-parity-20260820` | stronger equivalent | V8 commit `430b7315` is patch-identical to `e19fa704` (stable patch ID `e97493097e0775e80bc67613a399a9ac80f7c692`). |
| `codex/quest-core-split-sync-candidate-20260820` | present | `e901fc00` is the first parent. |
| `codex/unplugged-app-repair-candidate-20260821` | present | `548c2f66` is ancestor of the merge. |
| `codex/quest-display-name` | stronger equivalent | exact normal/Test/Diagnostic labels and package IDs are enforced by the 15-check Android contract and APK manifests. |
| completed parity branch | present | `77c59d21` is the second parent; every committed parity item is reachable by ancestry. |

No relevant committed launcher, Quest, boundary, label, or adapter item is
unclassified. The only ledger change is the reviewed one-line private-path
sanitization in `docs/quest-launcher8-unplugged-parity-ledger.md`.

## Verification

- Focused host, lifecycle, launcher, display, settings, flavor, adapter,
  SAF, loading, V8, and panel checks: passed. Key counts: host boundary 24/24,
  Quest settings 100/100, loading 4158/4158, launch progress 23/23, panel 7/7.
- Full Modkit: 23/23 suites passed.
- Full engine: 220/222 suites passed. The two known Windows Unix-harness
  exceptions are `build_zip_pipe_guard_bug774` and `title_zone_seams`.
  Equivalent checks confirmed Unix script presence, ZIP pipe guard source,
  and Quest title-zone condition. ROM CLI and title checkpoint shell probes
  also remain Windows path/command harness exceptions; no source defect was
  found.
- LuaJIT list parse: 1549/1552 tracked Lua files passed. The remaining three
  are Lua 5.3+ save-vendor/oracle files and require a Lua 5.3+ parser.
- `git diff --check`, merge-delta secret/private-data scan, and merge-delta
  ROM/save/protected-content scan: clean.

## Preserved worktrees

The canonical damaged parity worktree, dirty split worktree, completed parity
worktree, and Q47 preflight worktree were inspected only. The dirty split's
untracked device-cutover directory was not copied or staged.

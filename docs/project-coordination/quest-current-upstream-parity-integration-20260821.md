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

### Batch 4: Gen 1 boot facing and rival music entry points

Audit lane: M8, separated Gen 1 core subset of the mixed upstream bundle.

Upstream source:
`37051a26b5b5732cc845441dbd66d1916a6925fb`.

Exact imported path set:

```text
src/core/ChipSynth.lua
src/core/Music.lua
src/core/SaveData.lua
tests/engine/rival_music_start_channels.lua
```

The batch sets the Red and Blue upstairs new-game facing direction, preserves
the Yellow default, and supports the alternate Gen 1 rival-music channel entry
points without mutating the shared audio registry definition. Gen 2 source and
tests from the upstream bundle remain excluded.

Focused verification:

- Rival entry-point and same-song dedupe regression: 10/10 passed.
- Chip analog path: 8/8 passed.
- Music volume-hook state: 6/6 passed.
- Resume music and map fade: 13/13 and 11/11 passed.
- Trainer battle theme: 18/18 passed.
- Fresh and restored playthrough identity: 4/4 and 18/18 passed.
- Red, Blue, Yellow, and explicit custom new-game facing checks: 4/4 passed.
- WSL LuaJIT engine: 197/197 suites passed, including all Quest contract
  suites and the new regression.
- Staged diff and whitespace checks passed.

### Batch 5: Gen 1 story command bridges

Audit lane: M8, dependent Gen 1 command subset of the mixed upstream bundle.

Upstream source:
`37051a26b5b5732cc845441dbd66d1916a6925fb`.

Exact imported path set:

```text
src/script/Commands.lua
tests/engine/story_command_bridges.lua
```

This completes the command-side dependencies for the Oak, rival-music, and
Yellow Pikachu script paths from Batches 3 and 4. It forwards all music cue
options and preserves the existing one-transition music hold.

Focused verification:

- Story command bridge regression: 11/11 passed.
- Yellow Oak starter regression: 24/24 passed.
- Rival start-channel regression: 10/10 passed.
- Pewter Pikachu translation regression: 9/9 passed.
- Staged diff and whitespace checks passed.

### Batch 6: Gen 1 named ROM text and hidden-item save state

Audit lane: M8, separated Gen 1 text/save/menu subset of the mixed upstream
bundle.

Upstream source:
`37051a26b5b5732cc845441dbd66d1916a6925fb`.

Exact imported path set:

```text
src/core/RomText.lua
src/render/TextBox.lua
src/save_convert/GenSave.lua
src/save_convert/SaveConvert.lua
src/save_convert/data/hidden_items.lua
src/save_convert/data/hidden_items_yellow.lua
src/ui/StartMenu.lua
tests/engine/open_menu_bugs_949_1149.lua
```

This imports named translated ROM tokens, the Gen 1 hidden-item SRAM mapping
for Red/Blue and Yellow, and the empty-party start-menu behavior. It does not
import any Gen 2 codec or menu path.

Focused verification:

- Open-menu, named-token, and hidden-item codec regression: 5/5 passed.
- Status and stat-rise translation regressions: 10/10 and 6/6 passed.
- Launcher modal-focus regression: 24/24 passed.
- Generated-data save-conversion suites were skipped at their existing ROM
  boundary; this batch did not create generated data.
- Staged diff and whitespace checks passed.

### Batch 7: Gen 1 battle queue, damage, and move-learning parity

Audit lane: M8, separated Gen 1 battle subset of the mixed upstream bundle.

Upstream source:
`37051a26b5b5732cc845441dbd66d1916a6925fb`.

Exact imported path set:

```text
src/battle/BattleState.lua
src/battle/EffectRegistry.lua
src/battle/MoveEffects.lua
src/battle/Status.lua
src/pokemon/Evolution.lua
src/ui/MoveLearnMenu.lua
tests/parity_applying_attack_anim.lua
tests/run_tests.lua
```

This unit imports only Gen 1 battle behavior. It preserves the Quest battle
auxiliary action and current transition, rendering, and checkpoint repairs.

Focused verification:

- Disable same-turn behavior: 25/25 passed.
- Multi-hit HP drain: 18/18 passed.
- Quest battle-menu auxiliary action: 13/13 passed.
- Battle checkpoint boundary: 21/21 passed.
- Evolution cancel and hold-B suites: 8/8 and 15/15 passed.
- Text-choice overlap and fanfare hold: 10/10 and 18/18 passed.
- Status and stat-rise translation: 10/10 and 6/6 passed.
- WSL LuaJIT engine: 199/199 suites passed, including all Quest contracts.
- ROM-backed applying-attack and aggregate damage cases remain unavailable
  because no generated private ROM data exists.
- Staged diff and whitespace checks passed.

### Batch 8: Gen 1 Yellow follower and item-menu behavior

Audit lane: M8, separated Gen 1 item/menu subset of the mixed upstream bundle.

Upstream source:
`37051a26b5b5732cc845441dbd66d1916a6925fb`.

Exact integrated path set:

```text
src/inventory/ItemEffects.lua
src/ui/BagMenu.lua
src/ui/BoxMenu.lua
src/ui/PartyMenu.lua
src/ui/ShopMenu.lua
tests/engine/pewter_pikachu_flute.lua
```

The ItemEffects, PartyMenu, and ShopMenu source patch is byte-equivalent to
the filtered upstream patch, with stable patch ID
`35a78d52d77d5b631b55240b135f2561e1a5ecb7`. BagMenu was adapted inside the
existing `item.use` mod-hook wrapper. BoxMenu imports the missing sleeping
starter deposit refusal. Its Yellow release behavior was already present from
`2bace9dbfd7c686543f9fbbff43af387b23e2bb6`; the stronger crash fix and ROM
text routing from `54d614cd60e3bef647f2653c6a02778413093a37` were retained instead of the
weaker upstream hunk.

Focused verification:

- Pewter Pikachu flute flow: 7/7 passed.
- Item-use mod hook: 7/7 passed.
- Evolution stone and rare-candy bag behavior: 8/8 and 20/20 passed.
- Party field-move ordering: 6/6 passed.
- Yellow Pikachu release crash repair: 3/3 passed.
- Shop price ROM text and menu row layout: 4/4 and 28/28 passed.
- Pewter Pikachu translation regression: 9/9 passed.
- Staged diff and whitespace checks passed.

### Batch 9: Gen 1 title sprite palette behavior

Audit lane: M8, final separated Gen 1 presentation subset of the mixed
upstream bundle.

Upstream source:
`37051a26b5b5732cc845441dbd66d1916a6925fb`.

Exact imported path set:

```text
src/render/SpriteRenderer.lua
src/ui/TitleState.lua
```

The filtered source patch is byte-equivalent to upstream, with stable patch
ID `d089cffa88937efe4cc20f541a977c66cdfd0b98`. The title reuses the Gen 1
object-palette image path while all Quest compositor, loading-screen, and
profile behavior remains unchanged.

Focused verification:

- Title fill, cycle, and zone seams: 8/8, 104/104, and 82/82 passed.
- Advanced palette map: 21/21 passed.
- Render-compose seam: 5/5 passed.
- Quest compositor geometry: 14/14 passed.
- Quest loading screen: 4158/4158 passed.
- WSL LuaJIT engine after all split subsets: 200/200 suites passed.
- Staged diff and whitespace checks passed.

The applicable Gen 1 subset of `37051a26` is now complete. The excluded paths
are exactly `src/core/Game2.lua`, `src/core/gen2/ItemEffects.lua`,
`src/ui/gen2/EvolutionAnim.lua`, and
`tests/engine/gen2_sun_stone_bug1219.lua`; they are Gen 2-only.

### Batch 10: ordinary NPC cadence prerequisite

Audit lane: M8 prerequisite for portable C2.

Upstream source:
`a94fecfec8c8a853cb20cca0d97446d933387e8d`.

Exact imported path set:

```text
src/world/NPC.lua
tests/engine/npc_walk_cadence.lua
```

Only the audited cadence prerequisite was extracted from the multi-issue
upstream bundle. The NPC source patch is byte-equivalent to its upstream path;
all unrelated battle, link, launcher, renderer, UI-kit, story, and Gen 2 work
from that commit remains deferred to its owning lane.

Focused verification:

- Ordinary and synchronized NPC cadence: 8/8 passed.
- Timing parity: 163/163 passed.
- Turn-in-place timing: 28/28 passed.
- Warp sprite visibility: 19/19 passed.
- Staged diff and whitespace checks passed.

### Batch 11: portable synchronized escort behavior

Audit lane: portable C2 after its cadence prerequisite.

Upstream source:
`43957922260143126967aadb021cbb007e04ef34`.

Exact imported path set:

```text
data/scripts/story2.lua
data/scripts/story5.lua
tests/drivers/escort_lockstep_test.lua
tests/parity_escort_lockstep.lua
```

The full audited four-path unit is byte-equivalent to the upstream patch. Oak
and the Pewter youngster temporarily use the player's step cadence and restore
the normal NPC cadence when their escort ends.

Focused verification:

- Ordinary and synchronized NPC cadence: 8/8 passed.
- Timing parity: 163/163 passed.
- Pewter Pikachu world companion regression: 9/9 passed.
- The upstream visual driver is preserved but was not launched.
- The full-map parity scenario remains at the generated-ROM-data boundary;
  this task did not create private data.
- Staged diff and whitespace checks passed.

### Batch 12: sandboxed legacy-mod compatibility

Audit lane: M8 prerequisite for the network/job compatibility chain.

Upstream source:
`43cbc554c3badce4bf466a3f922cb9dba92e829b`.

Exact imported path set:

```text
CONTRIBUTING-mods.md
docs/modding.md
docs/new-features.md
src/mods/LegacyCompat.lua
src/mods/Loader.lua
src/mods/Sandbox.lua
tests/fs_io.lua
tests/modkit/cases/sandbox.lua
```

The complete filtered feature patch is byte-equivalent to upstream. Legacy
APIs now use sandboxed compatibility stand-ins; no host path, process, URL,
environment, or engine lifecycle capability is exposed.

Focused verification:

- Sandbox compatibility: 97/97 passed.
- Full Modkit: 18/18 suites passed.
- Quest platform lifecycle hooks inside Modkit: 14/14 passed.
- Staged diff and whitespace checks passed.

### Batch 13: permission-gated mod fetch and compute jobs

Audit lane: M8 network/job core, split from launcher-owned paths.

Upstream source:
`5198b35945be11a9713a512dbb6924564850773e`.

Exact imported path set:

```text
CONTRIBUTING-mods.md
docs/modding.md
docs/new-features.md
src/core/HostShell.lua
src/mods/Job.lua
src/mods/Loader.lua
src/mods/Manifest.lua
src/mods/Net.lua
src/mods/Sandbox.lua
src/mods/job_worker.lua
tests/modkit/cases/mod_fetch.lua
tests/modkit/cases/mod_job.lua
```

This is the byte-equivalent mod-core subset. It restricts curl protocols,
keeps raw threads blocked, gives mods opaque per-owner handles, and gates
network and background compute by declared permissions. LauncherView,
RomImporter, ExtractThread, RomManifest, and UI-kit paths remain deferred to
their launcher/import owners; no Quest launcher code changed in this batch.

Focused verification:

- Permission-gated mod fetch: 36/36 passed without a network request.
- Permission-gated mod jobs: 23/23 passed.
- Full Modkit: 20/20 suites passed.
- Sandbox compatibility: 97/97 passed.
- Quest platform lifecycle hooks: 14/14 passed.
- Staged diff and whitespace checks passed.

### Batch 14: sandbox TLS compatibility bridge

Audit lane: M8 TLS follow-up for LegacyCompat.

Upstream sources, in dependency order:

- `18d61779eb84fe80b167f3ff53dc7263c0af119d`
- `ef208035ec5a509f7c0f89aff611b85fe2007fcf`

Exact imported path set:

```text
main.lua
src/mods/LegacyCompat.lua
src/net/Gen1Tls.lua
tests/modkit/cases/sandbox.lua
```

The second source corrects the first source's UTF-16 file to valid UTF-8. The
bridge keeps Android/Quest's existing `love.system.tls*` functions when they
are present and only tries the optional desktop library otherwise. Clipboard,
URL, process, raw FFI, and other host capabilities remain blocked from mods.

Focused verification:

- Sandbox compatibility: 98/98 passed.
- Host boundary: 25/25 passed.
- Android host extension: passed.
- Quest host adapter: 7/7 passed.
- Quest platform lifecycle hooks: 14/14 passed.
- Corrected Gen1Tls module load: passed.
- Staged diff and whitespace checks passed.

### Batch 15: declared log reporting and final M1 sandbox guards

Audit lanes: M1 plus its M8 size correction.

Upstream sources, in dependency order:

- `cf335f67dea01099febbeddf5e02a3f1e0986991`
- `39df5bdfa6858efe11fe5a66473fb56aea9aa27a`
- `2b5229e73f5145fd8b1f4de4fe938b61d6d6ad44`
- `b739fa76c0fde6ab4dc89257b3272414ac3ae838`

Exact integrated path set:

```text
docs/modding.md
src/core/HostShell.lua
src/mods/Loader.lua
src/mods/Manifest.lua
src/mods/Net.lua
src/mods/Sandbox.lua
src/net/Fetch.lua
src/net/fetch_worker.lua
tests/modkit/cases/mod_postlog.lua
tests/modkit/cases/sandbox.lua
```

The code and tests apply the audited upstream hunks. Documentation was resolved
against this branch's newer layout: the detailed `postLog` contract is present
and states the corrected 512 KiB ceiling. Its one manifest-table row remains
deferred until that table arrives with the required-import foundation. Log
destinations are fixed by manifest, https-only, response-blind, and permission
gated. `jit.util` stays blocked, and raw threads require the compute permission.

Focused verification:

- Declared one-way log reporting: 27/27 passed without a network request.
- Mod fetch and job regression: 36/36 and 23/23 passed.
- Sandbox guards: 99/99 passed.
- Manifest validation: 99/99 passed.
- Full Modkit: 21/21 suites passed.
- Quest platform lifecycle hooks: 14/14 passed.
- Staged diff and whitespace checks passed.

### Batch 16: Gen 1 save recovery and editor lifecycle

Audit lane: M2, in upstream dependency order.

Upstream sources:

- `df0be1cba67441a19f7b5dd937058043794efd1c`
- `8dfbd1daae8f4628e2025e28e3e9eede6ffd37fa`
- `3a997e8a62cc4f20f7a3978841f0dcd409edd683`
- `f06c4d45845382a9c2573f2a88b67e10decebc5f`
- `b29b6fd7bd3fbfab1083aaee4ab6dea1af7f7652`
- `393a1013e4b3af0a85705f191200552a37377fe7`

Exact integrated path set:

```text
main.lua
src/core/Data.lua
src/core/SaveData.lua
tests/engine/save_editor_lifecycle.lua
tests/engine/save_slots.lua
tests/save_editor_mod_tests.lua
tools/save-editor/App.lua
tools/save-editor/Catalog.lua
tools/save-editor/Ops.lua
```

The first source is a mixed Gold-editor, launcher, updater, and save-editor
commit. Only its shared nil-safe event-directory handling and safe test
teardown apply here. Gold editor support, all Gen 2 source and tests, launcher
and updater changes, packaging additions, and removal of the split app's
explicit Gold-editor refusal remain excluded. From `8dfbd1da`, only the Gen 1
slot-registry recovery applies. `androidcrash.log` was not imported, changed,
or deleted; the Gen 2 PartyMenu and test hunks remain excluded.

The later M2 fixes clear generated data and flat editor modules after close,
reload data when the selected Gen 1 version changes, tolerate mobile hosts
without `io.popen`, and skip undefined move catalog entries. Recovery scans
existing slot files and rebuilds only `options.lua` metadata. It does not
rewrite a save. The implementation uses the audited upstream behavior with a
ROM-free Gen 1 regression companion.

Focused verification:

- In-memory Gen 1 slot migration, recovery, selection, and deletion: 90/90
  passed; no save file was created on disk.
- ROM-free editor unload, mobile event scrape, cross-version reload contract,
  and undefined move handling: 14/14 passed.
- The generated-data save-editor tier remains at its existing private ROM-data
  boundary and was not enabled.
- Staged secret, private-path, whitespace, and diff checks passed.

### Batch 17: ordered move audio and movie orientation

Audit lane: M3, foundation then replay correction.

Upstream sources, in dependency order:

- `cfa8406306d8c3e06339a4f7a6ed9ac1269a5214`
- `25ec896545ff282e009f2c06fe24c72bf8ea217c`

Exact integrated path set:

```text
src/core/ChipAudio.lua
src/core/ChipSynth.lua
src/core/Sound.lua
src/ui/EvolutionState.lua
src/ui/TradeAnim.lua
tests/drivers/evolution_flip_bug1412_test.lua
tests/drivers/leer_sound_bug1414_test.lua
tests/engine/move_sfx_channel_gate_bug844.lua
tests/engine/presentation_sprite_mirror_bug1412.lua
```

`ChipAudio.lua`, `ChipSynth.lua`, `Sound.lua`, and `TradeAnim.lua` are
byte-identical to the corrected upstream state at `25ec8965`. Both upstream
driver blobs are byte-identical to `cfa84063`. The EvolutionState mirror hunk
is exact; this branch keeps its stronger, already-tested evolution timing
model instead of replacing it with upstream's older timing loop.

Move SFX now track each software channel. A disjoint modified sound keeps its
plain opening until an occupied channel releases, lower-priority takeovers
stop only superseded sources, and an equal-id cached replay remains playing.
Evolution and trade front sprites use the movie-specific mirrored orientation.
No Quest audio host, OpenXR, lifecycle, surround, package, or launcher path
changed. The two interactive driver files were preserved but not launched.

Focused verification:

- Move channel arbitration, plain opening, and equal-id replay: 25/25 passed.
- Chip analog audio: 8/8 passed.
- ROM-free evolution and trade sprite orientation: 9/9 passed.
- Trade sequence and evolution cancel behavior: 9/9 and 15/15 passed.
- Fanfare hold and stereo effect routing: 18/18 and 7/7 passed.
- Host lifecycle and Quest host adapter: 19/19 and 7/7 passed.
- Mod audio, including silent failure isolation: 116/116 passed.
- Staged secret, private-path, whitespace, and diff checks passed.

### Batch 18: Gen 1 grass equivalence and Surfing Pikachu source

Audit lane: M4, with the Gen 1 subset separated from mixed Gen 2 paths.

Upstream sources, in dependency order:

- `286988a1e378a7f28d7a5676e84f44c50a4f495a`
- `f0d3c014a794dbae23d7376eca93449be42cc716`

Exact integrated path set:

```text
src/core/Game.lua
src/core/Music.lua
src/ui/SurfingMinigame.lua
tests/engine/surfing_m4_contract.lua
tests/test_surfing_minigame.lua
tools/build_rom_data.py
```

The final SurfingMinigame source and its upstream unit test are byte-identical
to `f0d3c014`. The fixed-speed Game hunk, safe headless Music guard, Music
pitch control, and guarded Yellow asset-extraction hunk match their audited
upstream sources. The extractor source reads authorized user ROM bytes only
during a later import and writes no generated or protected content in this
integration.

The Gen 1 entity-bound grass overdraw from `286988a1` was already present in
the Q47 successor. `TileRenderer.lua` differs from that upstream state only by
blank lines, and the flat and tilted Overworld grass blocks are semantically
identical. They were proved and left unchanged. Gen 2 encounter, schema,
extractor, world, fishing, Game Corner, Gold manifest, and Gen 2 test paths
remain excluded. `SpriteRenderer`'s Gen 2 object-palette/quad extension also
remains excluded. No manifest or generated asset changed.

Focused verification:

- Surfing Pikachu state machine, physics, landing, scoring, recovery,
  frame-rate consistency, and fixed speed: passed all 13 scenarios.
- ROM-free extraction, fixed-speed, Music, and flat/tilted grass contracts:
  11/11 passed.
- Builder CLI routing under the repository's WSL/POSIX test shell: 4/4 passed.
- Python syntax compilation: passed.
- Gen 1 Red, Blue, and Yellow manifest blobs remained unchanged at
  `b8233558`, `753db374`, and `9fa9e696`.
- Native Windows ran the same CLI test as 2/4 because its path separator is
  `\\` while the existing test pins `/`; WSL passed the unchanged test.
- No ROM, save, generated asset, manifest payload, or protected content was
  created or staged.
- Staged secret, private-path, whitespace, and diff checks passed.

### Batch 19: extended WIDE battle HUD and menu composition

Audit lane: M5a, before viewport and world-renderer changes.

Upstream sources, in dependency order:

- `530f2bdd1562b5280880694d2d2c4eb680d10d68`
- `90eb53b00c46b9b08aba4c991188297af67b08cf`
- `524138ff271cff89873ab4dec499f6dea5f15351`

Exact integrated path set:

```text
src/battle/BattleState.lua
src/battle/WideBattle.lua
src/core/Game.lua
src/core/SaveData.lua
src/import/LauncherSettings.lua
src/render/Renderer.lua
src/ui/OptionsMenu.lua
tests/drivers/fixed_extended_world_bag_overlay_test.lua
tests/engine/battle_fixed_menu_scale.lua
tests/engine/extended_battle_hud_contract.lua
tests/engine/quest_settings_profile_test.lua
tests/engine/wide_battle_shake_bug562.lua
tests/mod_ui_tests.lua
```

The optional EXTENDED HUD keeps the battle scene on its native WIDE canvas
and moves only approved status and text regions to physical-window anchors.
The standard HUD remains the default. Unsupported combinations fall back to
STANDARD, and WIDE + FILL + EXTENDED keeps the authored WHITE background.
Opaque classic menus now retain the WIDE battle presentation below them.

The upstream visual driver is byte-identical to `90eb53b0`, but it was not
launched. The shake fixture hunk is exact. Renderer integration is semantic
because Q47 has later Quest compositor behavior: its `questLetterboxWhite`
exception and mobile faithful-ratio lock remain intact. The Quest settings
profile now proves that BATTLE HUD remains reachable in both launcher and
in-game settings. No OpenXR, Android host, package, launcher profile, panel,
or compatibility-adapter behavior was removed or reduced.

Focused verification:

- Extended battle scaling, menu ownership, WIDE layout, and shake: 108/108
  passed.
- ROM-free extended-HUD activation, option normalization, stack, and anchor
  contracts: 30/30 passed.
- Quest compositor geometry and panel placement: 21/21 passed.
- Quest settings profile and faithful-ratio mobile behavior: 122/122 passed.
- Save-option write/read recovery: 26/26 passed.
- Total focused checks: 307/307 passed.
- The changed option-row section of the monolithic mod UI test passed; its
  later private generated-data tier stopped at the existing missing
  `data/generated/field.lua` boundary. No generated data was created.
- The visual driver was preserved as evidence and was not launched.
- Staged secret, private-path, whitespace, and diff checks passed.

### Batch 20: Gen 1 OS-independent game viewport

Audit lane: M5b, after the extended WIDE HUD and before world overdraw.

Upstream sources, in dependency order:

- `1f3d13adaf048626527fcec90d2c909d5c12c3f1`
- `a542ed90bae3f6ab4f7592bb381173b838433c3d` (source-limit gate only)

Exact integrated path set:

```text
docs/modding.md
main.lua
src/core/Game.lua
src/core/SafeArea.lua
src/core/TouchControls.lua
src/render/GameViewport.lua
src/render/Renderer.lua
src/ui/kit/Layout.lua
src/world/OverworldController.lua
tests/engine/luajit_source_limits_test.lua
tests/engine/render_viewport.lua
```

`GameViewport.lua` is byte-identical to `1f3d13ad`, and the LuaJIT
source-limit gate is byte-identical to `a542ed90`. The viewport is inactive
and allocation-free without a mod subscriber. When requested, it maps Gen 1
rendering, safe-area geometry, world pipelines, UI layout, and pointer-local
coordinates into the reserved rectangle, then restores full-window Quest
chrome and touch-control space.

This is the audited mixed split: the shared and Gen 1 parts apply, while
`Game2.lua`, Gen 2 BattleTransition, Gen 2 World, and the Gen 2 compatibility
document remain excluded. The upstream viewport test is unchanged except that
its source-order assertion names only `Game.lua`. The unrelated launcher,
updater, and Gen 2 World rewrites in `a542ed90` also remain excluded.

Q47's newer `HostDisplay.render` ownership is preserved. Viewport reset was
added before each editor, touch-editor, and Quest launcher host render without
restoring upstream's older begin/end wrapper. No Quest compositor, panel,
OpenXR, Android host, package, launcher profile, or compatibility-adapter path
was removed or reduced.

Focused verification:

- Reserved, full-window capture, pointer-local, safe-area, target, reset, and
  Gen 1 render-order viewport contract: passed.
- LuaJIT source compilation and strict local-limit meta-gate: 369/369 passed.
- Safe-area and touch orientation/pad/second-screen contracts: 48/48 passed.
- Host display: 34/34 passed.
- Quest compositor geometry and panel placement: 21/21 passed.
- UI layout and Quest launcher panel reflow: 198/198 passed.
- Full Modkit: 21/21 suites passed, including pointer input 68/68.
- Staged secret, private-path, whitespace, and diff checks passed.

### Batch 21: visible-cell tall-grass overdraw

Audit lane: M5c, after viewport composition and before color-mode filtering.

Upstream source:

- `def967a8f8023eb7896999a066d7ff3a83bfe7bc`

Exact integrated path set:

```text
src/render/TileRenderer.lua
src/world/OverworldController.lua
tests/engine/grass_overdraw_pass.lua
tests/engine/surfing_m4_contract.lua
```

`TileRenderer.lua` is byte-identical to the audited upstream commit. It
records each visible grass cell once, uses one shader-backed SpriteBatch on
DMG/SGB, uses pre-keyed per-cell draws on GBC, preserves post-zone palette
replay, and releases both its batch and cell cache.

The flat Gen 1 world now draws that pass once after all sprites. The tilted
Quest path injects the same visible cells into its depth-sorted billboard
queue, so grass occludes by world foot position without attaching duplicate
patches to individual entities. The change preserves the current viewport,
tilt, shake, neighboring-map ghost, pipeline, and Quest compositor behavior.

Focused verification:

- Runtime grass collection, batch, camera, GBC replay, and release: 12/12
  passed.
- Flat and tilted integration source contract: 13/13 passed.
- LuaJIT source compilation: 369/369 passed.
- Advanced Gen 1 palette and render-compose seam: 26/26 passed.
- Quest compositor geometry and panel placement: 21/21 passed.
- Total focused checks: 441/441 passed.
- Staged secret, private-path, whitespace, and diff checks passed.

### Batch 22: mode-aware true-color rendering

Audit lane: M5d, final ordered M5 renderer checkpoint.

Upstream source:

- `f7bdaa81f8b29f1e515161b1e5478b8b56fe9374`

Exact integrated path set:

```text
src/battle/BattleState.lua
src/render/PaletteFX.lua
src/render/Renderer.lua
src/render/SpriteRenderer.lua
tests/mod_graphics_tests.lua
```

The audited shared and Gen 1 hunks now honor full-color battle and world art
only when the active palette mode supports it. In Gen 1, ADVANCED keeps the
unquantized asset. Forced mono and other non-authorized modes quantize it
through the normal palette path and do not splice shader-free rectangles into
the final zone list.

The direct Gen 2 BattleState hunk and `tests/gen2_big_object_test.lua` remain
excluded. The shared PaletteFX helper retains its upstream generation-aware
compatibility branch, but no Gen 2 state, UI, world, package, or test path was
changed. Q47's stronger ADVANCED default remains unchanged. The graphics test
sets its local-palette fixture to SGB explicitly so that the Quest default does
not hide that independent registry contract; it also supplies the no-grass
method required by the preceding visible-cell renderer checkpoint.

Focused verification:

- Full mod graphics, including true-color quantization and ADVANCED exemption:
  191/191 passed.
- LuaJIT source compilation: 369/369 passed.
- Advanced Gen 1 palette and render-compose seam: 26/26 passed.
- Quest compositor geometry and panel placement: 21/21 passed.
- Quest settings profile and faithful-ratio mobile behavior: 122/122 passed.
- Total focused checks: 729/729 passed.
- Staged secret, private-path, whitespace, and diff checks passed.

### Batch 23: bounded link wire and failure containment

Audit lane: M6, the dedicated link protocol and transport unit.

Upstream source:

- `7b1e796c4872962d3fdd038aa8b136d118840ae5`

Exact integrated path set:

```text
README.md
docs/link-security.md
src/core/Game.lua
src/link/Handshake.lua
src/link/Json.lua
src/link/LinkBattle.lua
src/link/Net.lua
src/link/Protocol.lua
src/link/Session.lua
src/link/Wire.lua
tests/engine/link_desync_fixture.lua
tests/engine/link_game_containment.lua
tests/engine/link_hostile_fixture.lua
tests/engine/link_session.lua
tests/link_desync_fuzz.lua
tests/link_hostile.lua
tests/run_link_tests.lua
```

The security document, Handshake, Json, Net, Protocol, Session, Wire, link
session test, hostile corpus, and link runner are byte-identical to the
audited commit. Session is now the single typed-message boundary. Wire rebuilds
bounded messages, malformed input is dropped, Json depth and length are
bounded for link callers, Net caps receive buffers and per-frame reads, and
protocol conversion keeps its independent gameplay clamps.

The four diverged paths were integrated semantically. The Quest README keeps
its VR content and adds the security-model link. Game keeps all current speed,
viewport, Quest, and mod behavior while containing transport or linked-state
throws only during an active link. LinkBattle keeps the successor's current
replacement behavior and receives only the finite integer RNG seed guard. The
mutation fuzz keeps the successor's current drive path while adding the
audited hostile-field sanitization runs.

No real socket, relay, external host, or network connection was used. The
upstream full link runner reached the existing private generated-data boundary
at missing `data/generated/constants.lua` before running. It was not weakened
or redirected. Two ROM-free wrappers seed the existing public fixture data for
the same hostile corpus and deterministic lockstep/mutation fuzz; they do not
write generated data.

Focused verification:

- Typed session, ordering, lifecycle, malformed-message, and source boundary:
  87/87 passed.
- Hostile corpus: 1,023 messages, 0 failures.
- Deterministic lockstep fuzz: 20 runs and 146 turns, 0 failures.
- Sanitized mutation fuzz: 5 runs, 0 failures.
- Game transport/state containment and non-link loud failure: 12/12 passed.
- LuaJIT source compilation: 370/370 passed.
- Full Modkit: 21/21 suites passed, including link desync 40/40.
- Staged secret, private-path, whitespace, and diff checks passed.

### Batch 24: per-game launcher mod enablement

Audit lane: M7 launcher foundation.

Upstream source:

- `941181d31c817525e690bd771649be19f70f1319`

Exact integrated path set:

```text
docs/launcher.md
docs/mod-api-gen2-compat.md
docs/preparing-your-mod-for-gen2.md
src/core/SaveData.lua
src/import/LauncherView.lua
src/import/RomImporter.lua
src/mods/LauncherMods.lua
src/mods/Loader.lua
src/mods/ManagerState.lua
tests/engine/launcher_mods_tests.lua
tests/engine/mod_targets_tests.lua
tests/mod_ui_tests.lua
```

The audited patch applied as one exact unit: its stable patch id is
`cd521277bd4da43097ffaefc7bf5ce668a1918a7` both at the upstream source and
in the successor index. The destination blobs still contain the existing Q47
launcher, Quest profile, SAF, lifecycle, compatibility, and mod-sandbox work.
The two Gen 2-named documents describe the shared cross-game mod target
contract; no Gen 2 runtime path was added.

Existing shared choices now migrate once to explicit per-game answers. The
launcher renders a separate accessible checkbox for each supported game, and
the launcher, loader, and in-game manager use the same version scope. Removing
a mod clears both legacy and per-game flags.

Focused verification:

- Launcher mod list, scope, status, and migration: 118/118 passed.
- Mod target and enablement contract: 70/70 passed.
- Quest launcher focus, touch, modal, text, row, reflow, scroll, profile, SAF,
  launch-progress, and lifecycle checks: 536 checks plus 3 contract drivers
  passed.
- Full Modkit: 21/21 suites passed.
- The direct `tests/mod_ui_tests.lua` run reached the existing private
  generated-data boundary at missing `data/generated/field.lua`; its changed
  per-game assertion is covered by the ROM-free launcher and target suites.
- Staged secret, private-path, protected-artifact, binary, whitespace, and
  diff checks passed.

### Batch 25: launcher profiles and dependency resolution

Audit lane: M7, dependent on Batch 24.

Upstream source:

- `500d8c2c078e8512c94148a89627dfb52a8d1a1a`

Audited integrated path set:

```text
src/import/LauncherView.lua
src/import/RomImporter.lua
src/mods/LauncherMods.lua
src/mods/Manifest.lua
src/mods/ModIndex.lua
tests/mod_manifest_tests.lua
tests/mod_ui_tests.lua
```

Quest adaptation test:

```text
tests/engine/launcher_profile_dependency_test.lua
```

The Manifest, ModIndex, and two upstream test patches have the exact source
stable patch ids. LauncherView has the same 716 ordered changed lines as the
audited patch; three-way hunk grouping differs only because the successor
already has the Q47 launcher architecture. LauncherMods preserves the current
bounded install-progress callback while also returning the validated manifest.
RomImporter keeps Q47's coroutine-based picker and SAF path and performs the
new dependency check on both its synchronous inbox path and its task-owned
asynchronous direct-package path.

Profiles can now be applied, captured, duplicated, renamed, deleted, and kept
in sync with per-game choices. Dependency specifications accept validated
repository hints. The launcher reports missing, incompatible, direct-conflict,
and reverse-conflict conditions and can resolve an authorized dependency
through the existing asynchronous mod update path. No dependency, URL, socket,
or network action was started during integration or testing.

Focused verification:

- Launcher list and target contracts: 118/118 and 70/70 passed.
- Manifest and dependency resolver: 107/107 passed.
- Profile mutation and Q47 asynchronous dependency check: 15/15 passed.
- LuaJIT source compilation: 370/370 passed.
- Quest launcher focus, touch, modal, text, row, reflow, scroll, profile, SAF,
  launch-progress, and lifecycle checks: 536 checks plus 3 contract drivers
  passed.
- Full Modkit: 21/21 suites passed.
- The direct `tests/mod_ui_tests.lua` run remains behind the missing private
  `data/generated/field.lua` boundary. Its new profile assertions are repeated
  in the ROM-free focused test without creating generated data.
- Staged secret, private-path, protected-artifact, binary, whitespace, and
  diff checks passed.

### Batch 26: version-aware launcher conflicts

Audit lane: M7.

Upstream source:

- `b8ec4fe6b5fe4df48926e316ed4e89efd97bf0a5`

Exact integrated path set:

```text
src/mods/LauncherMods.lua
tests/mod_manifest_tests.lua
```

The staged patch has the same 57 ordered changed lines and the same 55-line
stat as the audited source. The three-way test context also contained an
unchanged, intervening Gen 2 scoped-dependency block from the source parent;
that block was not part of this commit's patch and was not imported. The
existing Gen 1 dependency and conflict tests remain in place.

Direct and reverse conflict reports now apply a declared semantic-version
range to the installed target. Unversioned conflicts keep their prior meaning.

Focused verification:

- Manifest, dependency, forward-range, and reverse-range contract: 112/112
  passed.
- Profile and dependency launcher seam: 15/15 passed.
- LuaJIT source compilation: 370/370 passed.
- Staged secret, private-path, protected-artifact, binary, whitespace, and
  diff checks passed.

### Batch 27: touch skins and Skin Studio

Audit lane: M7, ordered skin foundation.

Upstream source:

- `3cca70608f2093198ebd88f4d71074a7f0dd351d`

Audited integrated path set:

```text
assets/skins/gb_anim/README.md
assets/skins/gb_anim/img/gb_a_b.png
assets/skins/gb_anim/img/gb_back.png
assets/skins/gb_anim/img/gb_down.png
assets/skins/gb_anim/img/gb_left.png
assets/skins/gb_anim/img/gb_right.png
assets/skins/gb_anim/img/gb_start_select.png
assets/skins/gb_anim/img/gb_up.png
assets/skins/gb_anim/img/gbc_a.png
assets/skins/gb_anim/img/gbc_b.png
assets/skins/gb_anim/img/gbc_back.png
assets/skins/gb_anim/img/gbc_down.png
assets/skins/gb_anim/img/gbc_left.png
assets/skins/gb_anim/img/gbc_right.png
assets/skins/gb_anim/img/gbc_start_select.png
assets/skins/gb_anim/img/gbc_up.png
assets/skins/gb_anim/img/menu.png
assets/skins/gb_anim/img/rotate.png
assets/skins/gb_anim/overlay.cfg
assets/skins/tv_crt/README.md
assets/skins/tv_crt/img/tv-integer.png
assets/skins/tv_crt/overlay.cfg
docs/new-features.md
docs/skin-studio.md
main.lua
src/core/Game.lua
src/core/SkinZip.lua
src/core/TouchControls.lua
src/core/TouchSkin.lua
src/import/LauncherSettings.lua
src/import/LauncherView.lua
src/import/RomImporter.lua
src/render/Renderer.lua
src/ui/SkinStudio.lua
src/ui/TouchControlsEditor.lua
tests/drivers/launcher_skins_tab_shot.lua
tests/drivers/skin_studio_author_tv.lua
tests/drivers/skin_studio_play_test.lua
tests/drivers/skin_studio_shot.lua
tests/drivers/touch_skin_editor_shot.lua
tests/drivers/touch_skin_shot.lua
tests/drivers/tv_skin_shot.lua
tests/engine/launcher_skins_tab.lua
tests/engine/skin_studio_test.lua
tests/engine/touch_skin_test.lua
```

Quest integration paths:

```text
.gitattributes
tests/engine/quest_settings_profile_test.lua
```

Thirty-three audited result blobs remain exact, including all 18 CC-BY-4.0
PNG assets, the complete SkinZip, TouchSkin, and SkinStudio modules, both core
skin/studio tests, and all seven visual drivers. The `gb_anim` descriptor's
CRLF bytes were normalized to LF through a scoped Git attribute; its text is
unchanged. The two attribution files now state that line-ending normalization
explicitly.

The semantic merge preserves Q47's immediate-mode launcher header, Quest
focus and touch dispatch, async/SAF importer, HostDisplay routes, renderer
repairs, viewport ownership, link containment, speed categories, and current
feature documentation. It adds the audited game dropdown and skins route
without importing the source parent's unrelated cached-header implementation.
The flat-display skin feature is gated out of the Quest launcher and tab
cycler. A skin saved by another build is ignored on Quest, so it cannot crop
or decorate the OpenXR compositor. Desktop and flat-mobile builds retain the
full bezel, viewport, hotkey, archive, editor, export, and studio behavior.

Focused verification:

- RetroArch/native parsing, bounds, hotkeys, input, viewport, export, and
  archive safety: 118/118 passed.
- Skin Studio model and authoring: 93/93 passed.
- Launcher skin import, route, and Quest gating: 22/22 passed.
- Quest settings and saved-skin isolation: 95/95 passed.
- Renderer, faithful-ratio, touch, safe-area, Quest host, compositor, panel,
  and OpenXR contracts: 193 checks plus the render-viewport driver passed.
- Quest/current launcher focus, touch, modal, text, row, reflow, scrolling,
  SAF, launch, and lifecycle checks: 444 checks plus 3 contract drivers passed.
- LuaJIT source compilation: 373/373 passed.
- Full Modkit: 21/21 suites passed.
- The seven LÖVE visual drivers were preserved as exact source blobs but were
  not launched, as required by the no-launch boundary.
- Staged secret, private-path, protected-artifact, authorized-binary,
  whitespace, and diff checks passed.

### Batch 28: Skin Studio orientation and aspect correction

Audit lane: M7, direct Skin Studio follow-up.

Upstream source:

- `675971068e5e129eaf99db74a7ebb71492a3d834`

Audited integrated path set:

```text
docs/skin-studio.md
src/core/TouchSkin.lua
src/import/RomImporter.lua
src/mods/ModIndex.lua
src/ui/SkinStudio.lua
tests/engine/skin_studio_test.lua
tests/engine/touch_skin_test.lua
```

`TouchSkin.lua`, `ModIndex.lua`, and both focused test files have exact
upstream result blobs. The narrow `RomImporter.lua` merge replaces only the
old category/tag discovery heuristic with the already-integrated `ModTargets`
contract. `SkinStudio.lua` keeps the current immediate-mode and Quest-safe
foundation. The documentation keeps the current drag-and-drop art workflow.

The correction preserves explicit RetroArch design aspect ratios, keeps
controls round when a full-screen overlay is letterboxed, supports matching
portrait and landscape pages during play, and lets the studio lock a page or
temporarily disable canvas matching. The Batch 27 Quest gates still prevent a
saved skin from changing the OpenXR compositor.

Focused verification:

- Touch skin and Skin Studio: 142/142 and 108/108 passed.
- Launcher skin route and Quest saved-skin isolation: 22/22 and 95/95 passed.
- Mod target and launcher filtering: 70/70 and 118/118 passed; the feed-index
  contract driver passed.
- Renderer/viewport, faithful ratio, safe area, touch orientation, Quest host,
  compositor, panel, and OpenXR contracts: 190 counted checks plus the render
  viewport driver passed.
- LuaJIT source compilation: 373/373 passed.
- No visual LÖVE driver was launched. The preserved root runtime residues were
  not changed by this batch.
- Staged secret, private-path, protected-artifact, binary, whitespace, and
  diff checks passed.

### Batch 29: mod-index download metrics and trending

Audit lane: M7.

Upstream source:

- `bd1046f3983552b0594e11131ce1a7f0069a0a55`

Audited integrated path set:

```text
docs/new-features.md
src/import/LauncherView.lua
src/import/RomImporter.lua
src/mods/ModIndex.lua
src/mods/ModUpdate.lua
tests/drivers/launcher_find_downloads_shot.lua
tests/drivers/launcher_find_real_index.lua
tests/engine/launcher_mod_downloads.lua
tests/engine/mod_index_tests.lua
tests/engine/mod_update_tests.lua
```

`ModIndex.lua`, `ModUpdate.lua`, and all five test/driver files have exact
upstream result blobs. The Q47 launcher merge keeps immediate-mode focus,
touch, modal, paging, reflow, profile, skin, and cartridge-dropdown behavior.
The importer merge keeps its asynchronous fetch pump, SAF, and lifecycle
recovery. The upstream README sentence was excluded: the current README has
the same trust warning in professional wording and retains the approved Quest
and package-identity description.

The index cache now accepts backward-compatible scalar counts and structured
total/recent metrics, records release dates without inventing unknown dates,
and exposes Most-downloaded and FIND-only Trending sorts. A Trending choice
degrades to Most-downloaded in the installed-mod panel.

Focused verification:

- Network-stubbed download metrics: 24/24 passed.
- Mod target, launcher mod, and profile seams: 203/203 passed.
- Q47 launcher focus, touch, modal, text, reflow, page, and narrow-column
  regressions: 325 counted checks plus the touch-dispatch driver passed.
- Quest settings and launch lifecycle: 106/106 passed.
- LuaJIT source compilation: 373/373 passed.
- The mod-index and mod-update contract drivers passed. Neither LÖVE driver
  was launched; the real-index driver remains source-only because it can use
  the network.
- Staged secret, private-path, protected-artifact, binary, whitespace, and
  diff checks passed.

### Audited M7 non-applicable item

Source `58714690027cd3f92ecca8d2a88572bb909818e9` changes only two comments in
`main.lua` to avoid false positives in `skin_studio_image_import.lua`. That
triggering test belongs to the omitted `4e1ab187` image-picker batch and is not
present in this successor. The source has no runtime delta and no applicable
failing gate here, so it remains deferred rather than creating a comment-only
parity commit.

### Batch 30: title multi-box palette seam

Audit lane: portable C8, dependency-safe title subset.

Upstream source:

- `90163a3ff28e1ef2def72c0078f02e1f96e658c9`

Audited integrated path set:

```text
src/ui/TitleState.lua
tests/engine/title_zone_seams.lua
```

The focused 26-line test hunk matches upstream inside the current Q47 fixture.
`TitleState.lua` ports the multi-box palette-zone behavior into Q47's stronger
object-palette path;
the obsolete upstream sprite-replay helper is not restored because Q47 now
uses `SpriteRenderer.obpImage` directly.

The source commit's `StartMenu.lua` and `ui_layout_option.lua` hunks remain
dependency-deferred. They assume the static kept-open SAVE panel introduced by
audited M8 sources `0f8f6d0e` and `dbecc345`. Adding only `holdsUIAnchors` to
the current one-shot TextBox would satisfy the fixture without reproducing the
overlapping-menu behavior. Apply that field with its real foundation later.

Focused verification:

- Title zones, fill scale, and title cycle: 200/200 passed.
- Current UI-layout behavior: 20/20 passed.
- Quest settings and title-surround profile: 95/95 plus the load-report
  profile driver passed.
- Staged secret, private-path, protected-artifact, binary, whitespace, and
  diff checks passed.

### Batch 31: Gen 1 Town Map blink cadence

Audit lane: portable C9 TownMap subset.

Upstream source:

- `f5b8b6c85fb20b91de53f5f8ab274a3c799fb287`

Audited integrated path set:

```text
src/ui/TownMap.lua
tests/engine/town_map_blink_test.lua
```

The Gen 1 Town Map now uses a 50-frame cycle. Grid cursors and Pokédex nest
markers draw for frames 0 through 24 and hide for frames 25 through 49. Player
markers remain static in both background and stale-asset grid paths. The list
cursor and list player marker also remain static, matching the RBY fly list.

The upstream `GameVersion` import and all generation-2 branches were excluded:
this successor path is the Gen 1 owner, and adding the shared version switch
would cross the compatibility split. The mixed `version_blink_test.lua` visual
driver was also excluded because it switches to Gold, needs a live ROM/app
session, and checks only counter wrap. The new ROM-free engine test instruments
the actual draw calls at frames 0, 24, 25, and 49 and across the full cycle.
The source commit's PaletteFX, Diploma, TradeAnim, and Diploma-test paths remain
outside this narrow TownMap batch.

Focused verification:

- ROM-free draw and counter contract: 37/37 passed, including exact 25/25
  cursor/nest duty, static player/list markers, and 49-to-0 wrap.
- Direct TownMap LuaJIT bytecode compilation passed; strict source compilation:
  373/373 passed.
- Quest settings profile: 95/95 passed; the Quest load-report profile driver
  passed.
- No app or visual driver was launched and no network was used. The four
  preserved root residues retained identical SHA-256 hashes and timestamps.
- Staged scope/provenance, secret, private-path, protected-artifact, binary,
  whitespace, and diff checks passed.

### Batch 32: Gen 1 trade-cable geometry and fallback rendering

Audit lane: portable C9 TradeAnim subset.

Upstream source:

- `f5b8b6c85fb20b91de53f5f8ab274a3c799fb287`

Audited integrated path set:

```text
src/ui/TradeAnim.lua
tests/engine/trade_cable_geometry.lua
```

The `TradeAnim.lua` patch is byte-equivalent to the upstream path delta, with
stable patch ID `e96f2051a1d50a82cfaebcaf35e8d1d8d7c34b42`. Horizontal cable
art is cropped to the requested span instead of shifting outside it. The
8-pixel cable-segment asset is the first fallback, the solid rectangle remains
the final ROM-free fallback, and the right vertical cable now meets its corner
at `x=112`.

The new ROM-free engine test drives the real left and right Game Boy draw
methods with synthetic art. It proves both cropped widths, all 22 segment
fallback positions, the four vertical-segment positions, and the rectangle
fallback width. The TownMap subset is already complete in Batch 31. PaletteFX
remains the next isolated C9 unit. Diploma is not part of this batch. The mixed
visual driver remains excluded because it switches to Gold and needs a live
ROM/app session.

Focused verification:

- Trade cable geometry and fallbacks: 18/18 passed.
- Existing trade sequence, ROM-art import, and presentation mirror contracts:
  64/64 passed.
- Direct TradeAnim LuaJIT compilation passed.
- Quest settings profile: 95/95 passed.
- No app or visual driver was launched and no network was used. The four
  preserved root residues retained identical SHA-256 hashes.
- Staged scope/provenance, whitespace, and diff checks passed.

### Batch 33: stale palette guard and C9 Diploma reconciliation

Audit lane: portable C9 PaletteFX subset and final C9 equivalence proof.

Upstream source:

- `f5b8b6c85fb20b91de53f5f8ab274a3c799fb287`

Audited integrated path set:

```text
src/render/PaletteFX.lua
src/ui/Diploma.lua
tests/engine/diploma_test.lua
tests/engine/palette_missing_table.lua
```

The one-line `PaletteFX.lua` delta is byte-equivalent to upstream, with stable
patch ID `c243b1d74ca920eced4d1367c549c5ba108e8343`. A stale or partial
palette pack can no longer index a missing named-palette table. Q47's stronger
ADVANCED default, mode-aware true-color gates, sprite redraw pass, animated
HP-bar palette input, and Quest profile remain unchanged.

`Diploma.lua` was already exact at upstream result blob
`ddcd6c738d83a3d9434feca01128c7347e775bb6`. Its current ROM-free test is
stronger than the upstream test: it checks the ornate frame, circle asset,
player art and coordinates, all nine frame quads, palette, opacity, and
dismissal. It remains unchanged. The mixed `version_blink_test.lua` driver is
excluded because it switches to Gold and needs a live ROM/app session. With
the TownMap and TradeAnim batches, every applicable Gen 1 path in C9 is now
reconciled.

Focused verification:

- Missing/complete palette-table behavior: 3/3 passed.
- Advanced palette map and title palette seams: 109/109 passed.
- Full mod graphics, including Q47 true-color behavior: 191/191 passed.
- Diploma layout, art, palette, and dismissal: 12/12 passed.
- Direct PaletteFX LuaJIT compilation passed.
- Quest settings profile: 95/95 passed.
- No app or visual driver was launched and no network was used. The four
  preserved root residues retained identical SHA-256 hashes.
- Staged scope/provenance, whitespace, and diff checks passed.

### Batch 34: opt-in final-frame output hook

Audit lane: M8 render-output API.

Upstream source:

- `09204daa2807a3d84c009c263de4d314a9e94b50`

Exact imported/adapted path set:

```text
docs/modding.md
src/render/Renderer.lua
tests/mod_graphics_tests.lua
```

The Gen 1 output hook is integrated after Q47's present pipelines and before
GBCFX. It allocates a full-window canvas only when `render.output` exists and
`render.output_enabled` returns true. A handler receives the final composite
and fitted viewport metrics and can take ownership by returning true. The
earlier `render.compose` path still has precedence. The merge keeps Q47's
GameViewport target, reserved-window capture, Quest compositor, HostDisplay,
panel placement, true-color, battle-surround, and lifecycle behavior.

Excluded upstream paths are `src/core/Game2.lua`,
`tests/engine/gen2_render_output_seam.lua`, the Gen 2 gate change, and the Gen 2
compatibility-document change. They are Gen 2-only. No platform or launcher
path changed.

Focused verification:

- Full mod graphics, including the three new disabled/enabled output-hook
  checks: 194/194 passed.
- Q47 render viewport driver passed.
- Quest compositor geometry, panel placement, and settings profile: 116/116
  passed.
- Direct Renderer LuaJIT compilation passed.
- No app was launched and no network was used. The four protected runtime
  residues remained untracked and unchanged.
- Staged scope/provenance, whitespace, and diff checks passed.

### Batch 35: portable cache and cold-start test guards

Audit lane: M8 test/runtime portability.

Upstream source:

- `35d44efb8b5c993f9ffa523637540c71df3c2496`

Exact imported/adapted path set:

```text
src/import/CacheFs.lua
src/import/RomImporter.lua
tests/integration/title_checkpoint_cold_start.lua
```

CacheFs now avoids native PhysFS FFI discovery on UWP and under the table-backed
headless filesystem. The cold-start fixture accepts both Lua 5.1/LuaJIT's
numeric `os.execute` success and newer Lua's boolean success. The upstream
optional dependency-check guard is applied to both the synchronous and
asynchronous Q47 mod-import paths, preserving SAF and bounded progress work.

The upstream `.gitignore` addition for `/options.lua*` is intentionally
excluded. This worktree's four protected runtime residues must remain visible
as untracked recovery evidence; hiding them would weaken the recorded
preservation boundary. Q47's stronger signing-secret ignore rules remain.

Focused verification:

- WSL cold-start capture and independent resume both passed.
- Headless, Blue mount, and Red migration CacheFs contracts: 25/25 passed.
- Launcher profile/dependency, launcher mods, and Quest SAF recovery: 148/148
  passed.
- Direct CacheFs and RomImporter LuaJIT compilation passed.
- No app was launched and no network was used. The four protected residues
  remained visible, untracked, and unchanged.
- Staged scope/provenance, whitespace, and diff checks passed.

### Batch 36: game-scoped mod dependencies

Audit lane: M8 shared manifest and loader behavior.

Upstream source:

- `dfeacc36b06892d116864e9b72f609ce3e54d4f0`

Exact imported/adapted path set:

```text
CONTRIBUTING-mods.md
docs/modding.md
src/mods/LauncherMods.lua
src/mods/Loader.lua
src/mods/Manifest.lua
src/mods/ModTargets.lua
tests/mod_manifest_tests.lua
```

Structured hard and optional dependency entries can now declare `games` and a
dependency-level `game_version`. Manifest validation normalizes the game list;
the loader applies the same predicate to blocking, cycle detection, and order;
and the Q47 launcher applies it to status and dependency-resolution panels. A
Gen 2-only dependency no longer blocks a dual-generation mod on Red, Blue, or
Yellow. Existing per-game enablement, forced-run warnings, semantic-version
conflicts, profiles, asynchronous install, and Quest launcher behavior remain.

Excluded paths are `.gitignore`, all three Linux/AppImage scripts, both Gen 2
guide/reference edits, and `tools/modkit.py`. The first would hide broad zip
and protected option residues; the scripts are unrelated Linux platform policy;
and the remaining changes only alter the Gen 2 static checker or Gen 2 docs.

Focused verification:

- Manifest, loader, scoped dependency, and conflict behavior: 119/119 passed.
- Launcher mod and profile/dependency contracts: 133/133 passed.
- Full ROM-free Modkit: 21/21 suites passed.
- Direct compilation of all four changed Lua modules passed.
- No app was launched and no network was used. The four protected runtime
  residues remained untracked and unchanged.
- Staged scope/provenance, whitespace, and diff checks passed.

### Batch 37: deferred trainer preparation and battle-local party scope

Audit lane: M8 public trainer-battle API.

Upstream source:

- `a77210799f6feee7f57df7cf37626de16e492a93`

Exact imported/adapted path set:

```text
docs/modding.md
docs/rfcs/0010-trainer-battle-party-scope.md
src/battle/BattleState.lua
src/core/BattleCheckpoint.lua
src/ui/PartyMenu.lua
src/world/OverworldController.lua
tests/engine/trainer_battle_party_scope.lua
tests/modkit/cases/checkpoints.lua
tests/modkit/cases/trainer_before_battle.lua
```

The cold no-hook path starts a trainer battle once. A claiming public hook can
defer construction and invoke a one-shot continuation with ordered save-party
indices. The battle builds a local view of the original Pokémon records without
replacing or reordering the save party. Initial send, menus, voluntary/forced
replacement, exhaustion, EXP and EXP.ALL traversal, and party balls use the
view. Invalid scopes use the full party.

Checkpoint capture stores the normalized indices. Restore validates the active
battler, participants, and leveled-up references against the scope, rebuilds
the view, and remains compatible with old unscoped checkpoints. Q47's battle
auxiliary action, screen construction, Quest menu behavior, and link outcome
contract remain. The Gen 2 compatibility-document edit is excluded because Gen
2 has no matching deferred preparation boundary.

Focused verification:

- Party identity, menus, replacement, exhaustion, experience, invalid fallback,
  and link outcome: 19/19 passed.
- Public deferred hook and one-shot continuation: 11/11 passed.
- Public checkpoint suite, including 10 new scoped checks: 69/69 passed.
- Existing battle checkpoint, auxiliary action, and party field-move order:
  40/40 passed.
- Full ROM-free Modkit: 22/22 suites passed.
- Quest settings profile: 95/95 passed; direct changed-source compilation
  passed.
- No app was launched and no network was used. Protected residues remained
  untracked and unchanged.
- Staged scope/provenance, whitespace, and diff checks passed.

### Batch 38: deferred trainer cancellation hardening

Audit lane: M8 direct trainer-scope hardening.

Upstream source:

- `407f649e9dd97d500b14d6ea5dae7e4ef671829a`

Exact imported/adapted path set:

```text
docs/modding.md
docs/rfcs/0010-trainer-battle-party-scope.md
src/battle/BattleState.lua
src/ui/BagMenu.lua
src/world/OverworldController.lua
tests/engine/trainer_battle_party_scope.lua
tests/engine/trainer_talk_sting_bug764.lua
tests/modkit/cases/trainer_before_battle.lua
```

The retained continuation can now cancel without constructing a battle or
writing defeated-trainer state. A cancelled sight encounter is latched only at
the current player cell to prevent immediate reacquisition; movement clears it,
and a new overworld entry always resets it. Cancellation remains one-shot.
Malformed constructor options fall back to the full party. In-battle item
target selection now receives the battle and therefore uses the same scoped
party view as switch menus.

All upstream paths are applicable Gen 1/shared paths and are represented. The
merge preserves Q47's existing item-use hook wrapper, overworld lifecycle,
checkpoint behavior, Quest menu/input behavior, and link outcome repair.

Focused verification:

- Trainer party scope, including bag targeting and malformed options: 22/22
  passed.
- Talk/sight sting, cancellation latch, movement release, and lifecycle reset:
  24/24 passed.
- Public defer/resume/cancel one-shot contract: 15/15 passed.
- Existing item-use mod hook: 7/7 passed.
- Quest settings profile: 95/95 passed; direct changed-source compilation
  passed.
- No app was launched and no network was used. Protected residues remained
  untracked and unchanged.
- Staged scope/provenance, whitespace, and diff checks passed.

### Batch 39: contextual Gen 1 field items

Audit lane: M8 public world API.

Upstream source:

- `dcc388a94218b0724264ec7d51f95346e2a30eeb`

Exact imported/adapted path set:

```text
docs/modding.md
src/world/OverworldController.lua
src/world/WorldAPI.lua
tests/modkit/cases/world_field_items.lua
```

The public Gen 1 world facade lists bicycle and fishing actions only when the
live idle-world, inventory, terrain, surfing, and forced-bike rules allow them.
Execution delegates to new world-owned bicycle and fishing entry points, so
mods do not reproduce music, dialogue, collision, or encounter behavior.
Invalid, stale, unowned, and busy requests return a reason without state change.

The Gen 2 WorldAPI, Gen2Compat coverage table, Gen 2 docs, and their test half
are excluded as Gen 2-only. The focused test is the extracted Gen 1 half of the
mixed upstream test. Q47 world, music, item hooks, lifecycle, and Quest input
contracts remain.

Focused verification:

- Contextual bicycle/fishing discovery, execution, rejection, and busy state:
  11/11 passed.
- Existing world party reorder and item-use hook: 18/18 passed.
- Quest settings profile: 95/95 passed.
- Direct OverworldController and WorldAPI compilation passed.
- No app was launched and no network was used. Protected residues remained
  untracked and unchanged.
- Staged scope/provenance, whitespace, and diff checks passed.

### Batch 40: full-color Gen 1 trainer portraits

Audit lane: M8 Gen 1 trainer-registry and presentation subset.

Upstream source:

- `c8f6c7241b64e318034fc5c668f8d6f78cc32e5b`

Exact imported/adapted path set:

```text
docs/modding/reference/registries.md
src/battle/BattleState.lua
src/mods/Schemas.lua
src/ui/OakSpeech.lua
tests/engine/trainer_true_color.lua
tests/mod_battle_tests.lua
tests/mod_graphics_tests.lua
```

Gen 1 trainer records can declare `trueColor`. Battle portraits and Oak intro
trainer art preserve full-color pixels in color modes, while ordinary portraits
keep the active palette conversion. A `basePic` reuse inherits the base flag,
and an explicit false overrides it. The registry schema and generated reference
describe the field.

Gen2Compat, the Gen 2 BattleState implementation, Gen 2 registry fields, and
the Gen 2 half of the upstream focused test are excluded as Gen 2-only. Q47's
mode-aware true-color gate remains stronger: monochrome modes still quantize
full-color art.

Focused verification:

- Gen 1 schema, inheritance, explicit false, and OakSpeech propagation: 11/11
  passed.
- Full mod graphics, including three trainer-pixel assertions: 197/197 passed.
- Quest settings profile: 95/95 passed.
- Direct changed-source compilation passed.
- Direct `tests/mod_battle_tests.lua` remains at its existing generated-ROM-data
  boundary; its four new assertions are covered by the ROM-free focused test.
- No app was launched and no network was used. Protected residues remained
  untracked and unchanged.
- Staged scope/provenance, whitespace, and diff checks passed.

### Batch 41: Gen 1 charge-decision hook

Audit lane: remaining M8 shared battle API; Gen 1 subset of the mixed source.

Upstream source:

- `4b0496bad1a9110d5aad3b5be551664098c28ec0`
- `bb0f156497e7ad73c5a0553f9b724cac3dffeb0e` (Gold-only test follow-up)

Applied path set:

```text
src/battle/BattleState.lua
tests/engine/battle_charge_required.lua
```

Gen 1 charge-capable moves now offer the guarded public
`battle.charge_required` hook on their initial turn. A hook can return `false`
to resolve SolarBeam through the normal damage path without creating a charge
continuation. The unsubscribed path does not dispatch `Runtime.call`, and Fly
continues to preserve its normal charge state. Gold implementation and
Gold-only continuation coverage from the upstream mixed source remain
inapplicable to this Gen 1 parity lane.

Focused verification:

- New ROM-free Gen 1 charge contract: 13/13 passed.
- Direct `BattleState.lua` LuaJIT bytecode compilation passed.
- Existing full-color trainer regression: 11/11 passed.
- Quest settings profile: 100/100 passed.
- `git diff --check` passed.

### Batch 41 r4 gate record

The completed r4 evidence is reused. No broad search and no full Batch 41
suite was repeated because this batch changes only the Gen 1 charge seam.
The final full engine, Modkit, Lua parse, diff, secret/private-data, and
protected-residue gates remain mandatory after the final later change.

### Continuation row classifications

| Upstream row | Classification | Exact path/scope evidence |
|---|---|---|
| `c0ad6d0328708d3eec6f8a9fdc4c57e031a33ce1` | Inapplicable | Changes only `mobile/ios/app-repo.json`; iOS package-repository metadata is outside the Gen 1 Quest split. |
| `c9d67582aeac84ce2583e9654089c748856d4f74` | Inapplicable | Changes only `mobile/ios/app-repo.json`; same iOS-only scope. |
| `4b0496bad1a9110d5aad3b5be551664098c28ec0` | Applied | Gen 1 `src/battle/BattleState.lua` subset committed in Batch 41; `src/battle/gen2/Battle.lua` is Gen 2-only. |
| `bb0f156497e7ad73c5a0553f9b724cac3dffeb0e` | Inapplicable | Changes only Gold continuation assertions in `tests/engine/battle_charge_required.lua`; the Gen 1 focused contract is present. |

## Final acceptance

The final branch must be clean and contain reviewable batch commits. Required
gates are focused tests per batch, full engine, full Modkit, accepted-baseline,
Android host and Quest contracts, deterministic packaging contracts, secret
scan, ROM/save scan, private-path scan, protected-content scan, provenance
comparison, `git diff --check`, and a final diff review against the Q47 source.
ROM-data suites remain skipped unless generated private ROM data is already
present; this task must not create it.

## Recovery point

Current recovery point: Batch 41 integrates the Gen 1 charge-decision subset
of `4b0496ba`. Resume with the next unclassified row after this source in the
exact `2b6473ae..d191aaa` non-merge inventory. Keep the C8 SAVE-panel field
deferred until the `0f8f6d0e` and `dbecc345` menu foundation is integrated and
tested.

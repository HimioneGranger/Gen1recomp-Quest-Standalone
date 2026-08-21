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

## Final acceptance

The final branch must be clean and contain reviewable batch commits. Required
gates are focused tests per batch, full engine, full Modkit, accepted-baseline,
Android host and Quest contracts, deterministic packaging contracts, secret
scan, ROM/save scan, private-path scan, protected-content scan, provenance
comparison, `git diff --check`, and a final diff review against the Q47 source.
ROM-data suites remain skipped unless generated private ROM data is already
present; this task must not create it.

## Recovery point

Current recovery point: Batch 20 completes the Gen 1 viewport split while
preserving Quest host ownership. Resume with M5c full-screen grass overdraw.

# Quest Gen 2 Priority Audit

Date: 2026-08-11

Source of truth: upstream `origin/dev` / `origin/g2` commit `ae6cac89`
(`G2 support`) and the upstream guide, *Preparing your mod for Gen 2*.

## Priority decision

Gen 2 readiness supersedes the prior performance, door, HGSS-polish, and
multiplayer backlog. The existing Quest fork predated the entire parallel Gold
runtime: it had no `Game2`, Gen 2 world/battle/script VM, `Gen2Compat`, or
manifest game targeting. Adding `games = ["gen2"]` to mods on that baseline
would therefore have been false compatibility.

The upstream Gen 2 engine was merged into an isolated `quest-gen2` branch at
commit `098bf7b5`. The prior playable/memory-candidate branch remains intact.
The only source conflict was `main.lua`; resolution preserves Quest launcher
capture/session handoff and upstream Gold boot/platform hooks. Gold was also
added to the Quest launcher's native focus-confirm allow-list.

## Guide requirements now present

- `src/core/Game2.lua`
- `src/world/gen2/World.lua`
- `src/battle/gen2/Battle.lua` and Gen 2 UI battle state
- `src/script/gen2/Vm.lua`
- `src/mods/Gen2Compat.lua`
- manifest `games` / legacy `gen2compat` targeting and dependency propagation
- `tools/modkit.py gen2check`
- shared `mod.game`, `mod.world`, registry, hook, and event surfaces
- loader-side Gen 1 require interposition on a Gold boot

## Initial strict install-set scan

Every current mod correctly fails the first gate with `MK400`: none claims a
Gen 2 game. This means a Gold boot skips them instead of running misleading
Gen 1 patches against inactive modules. Do not bypass that protection with
`TRY HERE ANYWAY` during baseline validation.

### Needs substantial Gen 2 implementation

- **Dramaless Shape 1.6.4**: private engine hooks across Gen 1 game, world,
  map, options, and battle paths; a Gen 1 `StartMenu` literal; many unresolved
  module-value flows. Gold uses a different world/battle implementation, so
  this is a real renderer port, not a manifest edit.
- **Kanto First Person 1.60.0**: reads Gen 1 map/data/save lighting state and
  depends on the Dramaless rendering path. Its Kanto-specific content may also
  be inapplicable to Johto. Keep skipped until the Gold voxel backend exists.
- **Wilds of Kanto 1.12.1**: follower upvalue surgery, raw facade access,
  Gen 1 version allow-lists, Gen 1 battle factories, and world-controller
  monkey patches. Migrate to named follower/encounter/world seams.
- **Wild Skies 1.6.3**: reads Gen 1 world/map/encounter state and monkey-patches
  connection traversal. Migrate to shared events/hooks after the base renderer.
- **Crystal 251 0.10.1**: three fatal Gen 1-only sites were found before member
  coverage: `src.script.Commands` in daycare/sanctuaries plus many Gen 1
  Summary/Naming/BattleState paths. Gold already supplies native Gen 2 species,
  mechanics, screens, and scripts, so this overhaul should normally remain a
  Gen 1-only mod rather than be forced onto Gold.

### Small, but not yet honestly verified on Gold

- **Crystal 251 ROM Sprite Provider 0.1.2**
- **Pidgey Flyer Provider 0.1.0**
- **HGSS Quest Cache Bridge 0.1.0**
- **Side Door Fix authoring build 0.1.10-dev**

These have no fatal engine-module finding beyond `MK400` in the first static
pass, but they depend on mod exports, cache layout, sprite registries, or a
Gen 1-only hard dependency. They must remain Gen 1-only until boot/runtime
tests prove their exact Gold behavior. Side Door Fix is blocked transitively by
Dramaless Shape.

## Checker limitation encountered

The Windows environment currently lacks a standalone `luajit.exe`, so
`gen2check` fell back to parsing the adapter source and could not resolve
member-by-member coverage rows. The manifest, Gen 1-only module, screen-id,
version-gate, and static unresolved findings remain valid. Before declaring a
mod clean, rerun with `MODKIT_LUAJIT` pointing to a real LuaJIT executable and
require both zero findings and zero unresolved notes, then boot it on Gold.

## Required order

1. Build and physically validate Gold import/boot on Quest with existing mods
   skipped.
2. Port the Dramaless overworld renderer to the shared/public Gen 2 surfaces.
3. Reassess Kanto First Person applicability; separate Kanto-only content from
   generation-agnostic camera behavior.
4. Migrate Wilds/Wild Skies away from Gen 1 factories and monkey patches.
5. Evaluate the small providers individually and add `games` only after real
   Gold tests.
6. Keep Crystal 251 Gen 1-only unless a specific non-duplicated feature is
   deliberately redesigned for native Gold.

## ROM-free Quest baseline build

The merged engine was packaged and compiled before any mod was marked as Gold
compatible. The payload contains `Game2`, the Gen 2 world/battle/script
implementations, `Gen2Compat`, and `tools/rom_manifest_gold.json`. Archive and
APK inspection found no generated ROM/cache content.

Build result (2026-08-11):

- variant: `questVrNoRecordDebug`
- APK: `mobile/android/app/build/outputs/apk/questVrNoRecord/debug/app-questVr-noRecord-debug.apk`
- size: 61,646,052 bytes
- SHA-256: `A5D42655FDBA228AC480FF10625EC5DEEA20FCE69B71C2845FB44A6E2942E6C9`
- embedded `game.love` SHA-256: `7CFA91CA26F7DD6CBC563E63595881F0998DDE4547844B9E84A4A062596C3AB5`
- embedded payload matched the audited candidate byte-for-byte
- APK Signature Scheme v2 verification: passed
- ARM64 `liblove.so` and `libopenxr_loader.so`: present

Physical Gold import/boot remains intentionally pending. It requires a legally
obtained supported Gold ROM and the connected Quest; no ROM is part of this
artifact.

No ROM data, generated cache, or Pokémon artwork may enter Git or the APK.

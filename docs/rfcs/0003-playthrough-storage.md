# RFC 0003 — Playthrough-scoped mod storage

## Status

Proposed. Engine: `SaveData.lua`, `SaveSerializer.lua`, `Storage.lua`,
`Loader.lua`. Tests: `playthrough_identity.lua`, `storage.lua`, the existing
save-slot and mod-save suites.

## Motivation

`mod.save` intentionally lives inside the normal progress record. That is the
right home for quest state, but not for independent tool data such as replay
captures, checkpoint histories, or recovery records: writing it would require a
normal Pokémon SAVE, and storing copies of progress beneath `save.modData` would
recursively embed the save that contains them.

Mods also cannot safely infer which launcher slot or portable filesystem backs
the active playthrough. Direct filesystem access would expose private paths and
make isolation dependent on engine implementation details.

## The decision it extends

Extends the per-mod persistence contract documented in `docs/modding.md` and the
wiki's Save Model. `mod.save` and `mod.options` keep their existing behavior.

## The exact API delta

Backward-compatible, additive-only. `Loader:_api` binds a new `mod.storage`
facade to the calling mod id. Mods receive logical keys and either decoded table
values or exact opaque byte strings, never filesystem handles or physical paths.

### Lazy opaque playthrough identity

`SaveData.ensurePlaythroughId(save[, fs]) -> id | nil` allocates an opaque
32-hex-character identity without consuming gameplay RNG. It is called only when
`mod.storage` or `mod.checkpoints` first needs a scope; New Game, ordinary SAVE,
and ordinary load remain byte-compatible when no caller uses either API.

The id is stored in `save.meta.playthroughId` after allocation. Until the next
ordinary SAVE writes it into progress, a mapping in `options.lua` keeps legacy
saves stable by game version and active launcher slot (or the legacy flat-save
scope). A newly created playthrough never adopts the previous playthrough's
mapping for that slot.

`SaveData.persistenceFs([fs])` is engine-only routing used by the storage
implementation. It follows the same standard/portable backend as progress and
honors injected test filesystems; it is not exposed on the mod object.

### `mod.storage:context(game)`

Returns:

```lua
{ engineVersion = "0.9.0", gameVersion = "red", playthroughId = "..." }
```

or `nil, code, message`. `engineVersion` is warning-grade compatibility metadata;
the context intentionally omits launcher slot ids and paths.

### `mod.storage:write(game, key, value)`

Accepts a data-only table and returns `true`, or
`false, code, message`. Keys are nonempty slash-separated segments containing
letters, digits, underscore, or dash. Empty segments, leading/trailing slash,
`.`/`..`, and other characters are rejected.

The engine encodes deterministically, stages and decodes a `.tmp` witness,
preserves the previous valid generation, writes and decodes the main record,
then rolls the verified bytes to `.bak`. A failed stage or replacement leaves a
verified prior generation readable.

### `mod.storage:read(game, key)`

Returns a freshly decoded table, or `nil, code, message`. It tries main, staged,
then backup data. A valid staged/backup value is returned and promoted
best-effort; corrupt bytes are never executed.

### `mod.storage:writeBytes(game, key, bytes)`

Accepts a Lua string containing opaque bytes and returns `true`, or
`false, code, message`. Empty strings are valid. Payloads are limited to 512
MiB per key. The engine writes the supplied bytes exactly as received, without
decoding, compression, checksums, or an engine-defined envelope. The consuming
mod owns semantic validation of its format.

Byte records use private `.bin`, `.bin.tmp`, and `.bin.bak` witnesses. A staged
and replacement write is read back and compared byte-for-byte before it is
committed. A failed write leaves the previous verified generation readable.
Byte storage never passes its payload to the Lua serializer, loader, or module
resolver.

Table and byte records share one logical key namespace and a key has one type.
Writing one type over the other returns `type_conflict`; callers must delete the
key before changing its type. `mod.storage:selected(game)` exposes the same
`readBytes` and `writeBytes` operations for the selected playthrough facade.

### `mod.storage:list(game[, prefix])`

Returns sorted logical keys beneath a valid prefix, an exact key when the prefix
names one, or `nil, code, message`. Physical witness filenames are hidden.

### `mod.storage:delete(game, key)`

Deletes only that key's main, backup, and staged witnesses. Returns `true`, or
`false, code, message`.

### Scope and errors

Physical records are scoped as:

`persistence root / mod_storage / game version / playthrough id / mod id`

Stable error codes are `not_in_playthrough`, `storage_unavailable`,
`invalid_key`, `encode_failed`, `invalid_bytes`, `size_limit`, `type_conflict`,
`type_mismatch`, `write_failed`, `verify_failed`, and `not_found`. Ordinary
data and I/O failures are return values, not callback-terminating errors.

The restricted serializer's recursive writer runs outside LuaJIT traces. A
1,000-process GC stress regression found compiled recursion could intermittently
drop a newly inserted nested identity entry and produce undecodable bytes; save
encoding is infrequent and I/O-bound, so interpreter execution is the safe
boundary.

## Migration note for existing mods

**Nothing.** No API is removed, no manifest field changes, and no storage path or
playthrough id is created unless a mod invokes `mod.storage` or
`mod.checkpoints`. Existing save bytes remain unchanged on the no-caller path.
Existing files outside the scoped storage contract are not imported; a caller
must rebuild them through `writeBytes`.

## Parity tests

- **No-mod:** New Game plus ordinary save/load creates no identity or storage
  file; the existing save-slot and mod-save suites remain green.
- **Engine identity:** lazy allocation, save/load preservation, stable legacy
  mapping, fresh-playthrough replacement, and version/slot isolation.
- **Public Mod API:** two real API-2 entry chunks prove data-only roundtrip,
  opaque byte roundtrip including NUL bytes, no execution, size/type rejection,
  deterministic listing, key rejection, mod/game/playthrough isolation,
  corrupt-main recovery, failure retention, selected-playthrough access, exact
  delete, and no-mod no-write.

## Deprecation etiquette

Nothing deprecated. The additions are one bound public facade and engine-private
persistence/identity helpers.

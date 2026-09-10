# RFC 0009 — Permission-gated step bridge for sandboxed mods

## Status

Proposed. Engine: `Steps.lua` (new), `Loader.lua`, `Manifest.lua`,
`Sandbox.lua`. Test: `tests/modkit/cases/steps_bridge.lua`. Issue: #1186.

## Motivation

The iOS and Android builds count the player's real-world steps natively
(#452, #489), exposed to Lua as `love.system.syncHealthSteps()` and
delivered as `steps_pending.json` in the save-directory root. The sandbox
correctly blocks both — `love.system` also launches URLs, and the file API
names paths — but that leaves the bridge with no consumer: the mod that
step counting was built for (Pokéwalker, steps→EXP) can no longer be
written.

## The decision it extends

Extends the mod sandbox in `src/mods/Sandbox.lua` (blocked host modules
stay blocked; legitimate operations receive narrow engine-owned facades)
and the permission model `network` established: a `manifest.json`
permission the player sees in the mod manager that genuinely gates a
capability.

## The exact API delta

A new manifest permission token, `steps`, and a `mod.steps` facade:

- `mod.steps:available() -> boolean` — whether this build carries the
  native bridge. Answers `false` without the permission, so a probe stays
  quiet.
- `mod.steps:sync() -> boolean` — asks the platform to refresh its count
  (async; the OS consent sheet still appears on first use, exactly as
  before the sandbox). `false` when there is no bridge.
- `mod.steps:poll() -> { steps = n, from = iso?, to = iso? } | nil` — the
  next delivery for this mod, engine-consumed from the pending file. Each
  permissioned mod receives its own copy of a delivery.

Without the permission, `sync` and `poll` raise an error naming the
missing permission, the way the network gate does. The engine owns the
pending file: mods never learn its name or location, and only the three
contract fields travel. No new event, hook, or registry names.

## Migration note for existing mods

Mods that called `love.system.syncHealthSteps()` and read
`steps_pending.json` themselves add `"steps"` to `permissions` and switch
to `mod.steps:sync()` / `mod.steps:poll()`. No other mod changes.

## Parity tests

- **No mod:** with nothing installed the bridge is never called and a
  pending file on disk is left untouched.
- **Mod API:** a fixture mod with the permission syncs and receives a
  delivery through the public loader; two permissioned mods both receive
  the same walk; a second poll returns nil.
- **No permission:** `available()` is false and the acting calls name the
  missing permission; the sandbox suite keeps proving direct
  `love.system` access is refused.
- **Malformed delivery:** a bad or empty pending file is dropped whole
  rather than crashing a poll (the native anchor only advances on a
  successful sync, so nothing is lost).

## Deprecation etiquette

Nothing deprecated. The facade is additive; the sandbox's `love.system`
and `love.filesystem` blocks remain in force.

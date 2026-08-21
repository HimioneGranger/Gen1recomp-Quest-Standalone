# RFC 0008 — Read-only device power information for sandboxed mods

## Status

Proposed. Engine: `Loader.lua`, `Sandbox.lua`. Test:
`tests/modkit/cases/device_power_info.lua`.

## Motivation

A handheld UI mod can show the player's battery state and warn before power
loss. The sandbox correctly removes `love.system` because that module also
launches URLs and exposes other host operations, but it leaves no scoped way
to read the harmless power values that LÖVE already provides.

## The decision it extends

Extends the mod sandbox in `src/mods/Sandbox.lua`: blocked host modules stay
blocked while legitimate operations receive narrow engine-owned facades.

## The exact API delta

Add `mod.device:powerInfo() -> state, percent`.

The engine calls `love.system.getPowerInfo()` outside the mod sandbox and
returns only its first two values. `state` is one of LÖVE's standard power
states. `percent` is `0` through `100` or `nil`. When the platform has no
power-information backend, the result is `"unknown", nil`.

No permission grants access to `love.system`; URL launching, clipboard access,
OS identification, and the module table itself remain unavailable.

## Migration note for existing mods

Mods that used `love.system.getPowerInfo()` replace that call with
`mod.device:powerInfo()`. No other mod changes.

## Parity tests

- **No mod:** loading no mods does not call the platform power backend.
- **Mod API:** a fixture mod loaded through the public loader receives state
  and percentage through `mod.device`, while the existing sandbox suite keeps
  proving that direct `love.system` access is refused.
- **Unavailable backend:** the public facade returns `"unknown", nil` rather
  than inventing battery data or failing mod load.

## Deprecation etiquette

Nothing deprecated. The facade is additive; the sandbox's `love.system` block
remains in force.

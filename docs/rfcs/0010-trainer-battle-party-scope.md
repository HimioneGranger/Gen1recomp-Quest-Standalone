# RFC 0010: Deferred trainer preparation and battle-local party scope

## Status

Proposed.

## Motivation

Challenge mods can need the player to choose an eligible subset of the save
party before a trainer battle. Replacing `game.save.party` is unsafe because it
changes authoritative save state and can strand excluded Pokémon after a
failure.

## Contract

Gen 1 exposes `trainer.before_battle` after challenge text and before battle
construction:

```lua
mod.hooks:wrap("trainer.before_battle", function(next, game, context, continue)
  -- context = { trainerClass, partyIndex, mapId, npcId }
  -- Return true only when the battle is deferred.
  -- continue() uses the full party.
  -- continue({ playerPartyIndices = { 2, 4, 5 } }) selects a local view.
end)
```

The continuation is one-shot. With no subscriber, the engine does not allocate
context and starts the battle once through the normal path. An ordered list of
unique, one-based indices builds `battle.playerParty` from the original Pokémon
records. Invalid, empty, duplicate, sparse, or out-of-range lists use the full
party.

The local view controls initial send, party menus, voluntary and forced
replacement, exhaustion, experience traversal, EXP.ALL counts, and party-ball
presentation. It does not reorder or replace the save party. Trainer battle
checkpoints store the index list, validate every party reference against it,
and rebuild the view before restoring battlers. Older checkpoints without a
scope remain compatible.

Wild, Safari, link, demo, and no-mod battles are unchanged. The API sets no
maximum, chooses no members, and includes no challenge policy. Gen 2 does not
implement this deferred preparation boundary.

## Verification

- The no-hook path starts once without a scope.
- A sandboxed mod can defer and resume once through public APIs.
- Engine tests cover identity, menus, replacement, exhaustion, experience,
  invalid fallback, and link-outcome preservation.
- Checkpoint tests cover scoped capture/restore, invalid references, and old
  checkpoint compatibility.

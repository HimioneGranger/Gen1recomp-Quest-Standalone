# Gen 2 link play: what it takes

This is a design document, not a feature announcement. Gold cannot link today
and nothing in this document changes that on its own. What it does is state
honestly what Gen 2 link play requires, where the Gen 1 protocol in `src/link/`
stops working on a Gen 2 record, what the cart itself did, and which pieces of
the work are self-contained enough to have been built already.

The short version: the transport, the handshake and the fingerprint are
generation-agnostic or nearly so, and those are done. The party wire format is
half done (a codec exists, nothing sends it). The trade session, the trade UI
and the lockstep battle are not started, and each is a real piece of work.

Read `docs/mod-api-gen2-compat.md` beside this: it is the reference for what a
Gold mod may touch, and the link fingerprint's whole job is to hash exactly that
surface.

## 1. What Gen 1 link play is

`src/link/` is nine files and about four thousand lines:

| File | Job |
| --- | --- |
| `Net.lua` | lua-enet transport, LAN host/join plus a relay for online play. JSON messages, no game types. |
| `CodeEntry.lua` | the online join code widget. |
| `Handshake.lua` | the `hello` both peers exchange and the compatibility verdict drawn from the two of them. |
| `Fingerprint.lua` | a deterministic digest of the link surface: the slice of merged Data whose value decides whether two lockstep simulations stay identical. |
| `Protocol.lua` | mon serialization, the record-subset negotiation, and the trade session state machine. |
| `LinkState.lua` | the LINK menu, pairing, and the trade/battle hand-off. |
| `LinkBattle.lua` | lockstep battle: both machines run `src/battle/BattleState.lua` from mirrored perspectives on a shared seed, exchanging one action per turn and a per-turn state hash. |
| `Tournament.lua` | bracketed online play over the relay. |
| `Json.lua` | the encoder the wire and several unrelated callers share. |

Only three of those nine are shaped around Gen 1 game content: `Fingerprint`,
`Protocol` and `LinkBattle`. `Net`, `Json`, `CodeEntry` and most of `Handshake`
never look at a Pokemon.

## 2. What the cart did

pokegold's link code is `engine/link/link.asm` (2508 lines), and it is worth
being precise about, because several of the port's design questions have a cart
answer.

**Three rooms, one wire.** `wLinkMode` is `LINK_TIMECAPSULE`,
`LINK_TRADECENTER` or `LINK_COLOSSEUM` (`constants/serial_constants.asm`).
`LinkCommunications` branches once, at the top, on whether the mode is the Time
Capsule: `Gen2ToGen1LinkComms` for the Time Capsule and `Gen2ToGen2LinkComms`
for everything else (`engine/link/link.asm:33`). Everything after that branch is
shared -- the same byte exchange serves trading and battling, and the mode only
decides what is in the buffer and what the game does afterwards.

**What crosses the wire, in order** (`Gen2ToGen2LinkComms`,
`engine/link/link.asm:202`):

1. `SERIAL_RN_PREAMBLE_LENGTH + SERIAL_RNS_LENGTH` bytes: the shared battle
   RNG state. Seven preamble bytes and ten seeds.
2. `SERIAL_PREAMBLE_LENGTH + NAME_LENGTH + (1 + PARTY_LENGTH + 1) + 2 +
   (PARTYMON_STRUCT_LENGTH + NAME_LENGTH * 2) * PARTY_LENGTH + 3` bytes: the
   player name, the party count and species list, the **trainer ID**, six party
   structs, six OT names and six nicknames.
3. `SERIAL_PATCH_LIST_LENGTH` bytes: the patch list (see below).
4. In the Trade Center only, the mail block: six mail messages then six mail
   metadata structs (`Link_PrepPartyData_Gen2`, `engine/link/link.asm:810`).

**The shared PRNG is the whole trick behind lockstep.** `_BattleRandom`
(`engine/battle/core.asm:6650`) refuses the normal RNG whenever `wLinkMode` is
non-zero and pulls from `wLinkBattleRNs` instead: ten seeds, each advanced by
`a[n+1] = (a[n] * 5 + 1) % 256` when the stream runs out, with the count in
`wLinkBattleRNCount`. Both machines exchange those ten bytes once, before the
battle, and never again -- the external-clock side adopts the internal-clock
side's numbers (`Link_CopyRandomNumbers`, `engine/link/link.asm:1115`). The port
does the same thing with a Park-Miller stream seeded by the host
(`LinkBattle.makeRng`), which is the same idea in a different arithmetic.

**The patch list exists because the wire has reserved bytes.**
`SERIAL_NO_DATA_BYTE` (`$fe`) may not appear in the payload, so
`FixDataForLinkTransfer` (`engine/link/link.asm:556`) walks the party block,
replaces every `$fe` with `$ff`, and records the offsets it touched in a
200-byte list that ships alongside. Mail gets its own smaller version of this in
`Link_PrepPartyData_Gen2`. The port's wire is JSON over enet and has no reserved
bytes, so this whole mechanism has no analogue and needs none. It is worth
knowing about only so nobody reimplements it by accident.

**The Time Capsule is the cart's own answer to a cross-generation link.**
`CheckTimeCapsuleCompatibility` (`engine/link/link.asm:1970`) refuses the party
outright for exactly three reasons, and returns which one in `wScriptVar`:

1. a species at or above `JOHTO_POKEMON` (`constants/pokemon_constants.asm:168`,
   the 152 boundary),
2. a move above `STRUGGLE`, i.e. any move Gen 1 does not have,
3. any party member holding mail.

If the party passes, `Link_PrepPartyData_Gen1` (`engine/link/link.asm:640`)
rewrites every mon into the 44-byte `REDMON_STRUCT_LENGTH` layout:
`ConvertMon_2to1` remaps the species index through `Pokered_MonIndices`
(`engine/link/time_capsule_2.asm:1`), the Special stat is recomputed from
`KantoMonSpecials` because Gen 1 has one Special and Gen 2 has two, and
Magnemite and Magneton are shipped as pure Electric because their typing changed
(`engine/link/link.asm:731`). Coming the other way, `Link_ConvertPartyStruct1to2`
(`engine/link/link.asm:930`) reads the Gen 1 catch rate byte as the held item
slot -- garbage, which is why `TimeCapsule_ReplaceTeruSama`
(`engine/link/link.asm:1078`) maps the handful of catch rates that collide with
real items through `data/items/catch_rate_items.asm` and turns everything else
into a Berry. `ValidateOTTrademon` (`engine/link/time_capsule.asm:1`) then
re-checks the incoming mon's types against the local base data and refuses
anything that does not agree, with Magnemite and Magneton carved out again.

The lesson the port should take from all of that: a cross-generation link is not
a compatibility mode, it is a lossy conversion with a validator on each end, and
the cart wrote roughly 400 lines for it. Refusing the pairing is the honest
default until somebody wants to write those 400 lines.

## 3. Where the Gen 1 protocol breaks on a Gen 2 record

`Protocol.packMon` / `Protocol.unpackMon` are shaped around
`src/pokemon/Pokemon.lua`. Against `src/battle/gen2/Mon.lua`, every one of these
is wrong:

| Gen 1 assumption | Gen 2 reality | Where |
| --- | --- | --- |
| `mon.exp` | `mon.experience` | `Mon.new`, `Mon.gainExperience` |
| five DVs including `special` | four rolled DVs (`attack`/`defense`/`speed`/`special`) with `hp` **derived** from their low bits | `Mon.hpDV` |
| `special` is one stat | `specialAttack` and `specialDefense` are two stats off one DV | `Mon.stats` |
| `statExp` has five words | five words still, but the fifth feeds both special stats | `Mon.stats` |
| no held item | `mon.item` decides damage, healing and flinching | `src/battle/gen2/Battle.lua` `heldEffect` |
| stats recomputed with `src/pokemon/Stats.lua` | must go through `Mon.stats`, which is a different formula shape | `Mon.stats` |
| exp curve via `src/pokemon/Growth.lua` (code) | curve coefficients are **data**, at `data.pokemon.growthRates` | `Mon.experienceForLevel` |
| `mon.status` is `"SLP"` / `"PSN"` / `"BRN"` / `"PAR"` / `"FRZ"` | `"sleep"` / `"poison"` / `"burn"` / `"paralyze"` / `"freeze"` / `"toxic"` | `src/battle/Status.lua:62` vs `src/battle/gen2/Battle.lua:65` |
| `mv.ppUps` | Gen 2 has no PP Ups modelled yet; moves carry `id`, `pp`, `maxPp` | `Mon.movesAtLevel` |
| nothing else on the mon | `happiness`, `pokerus`, `caughtLevel`, `isEgg`/`eggSteps`, and the derived `shiny` / `gender` / `unownLetter` | `Mon.new` |
| mail does not exist | mail is a **separate** block keyed by party slot, not a mon field | `src/core/gen2/Mail.lua:84`, and the cart agrees (`Link_PrepPartyData_Gen2`) |

The status spelling is the sharpest of these. `packMon` puts `mon.status` on the
wire verbatim and `unpackMon` keeps it verbatim, so a shared codec would move
`"PSN"` onto a Gold party where nothing recognises it -- a mon that arrives
"poisoned" and never takes poison damage. Any Gen 2 codec has to be a separate
function with the generation baked into it, not a Gen 1 function with extra
optional keys.

Two things are *not* a problem, and it is worth saying so:

- **Species and move ids are shared name spaces.** Both generations key
  `data.pokemon` and `data.moves` by the same `TOTODILE` / `TACKLE` strings, so
  the wire never needs the cart's index remap (`ConvertMon_2to1`). Ids, not
  bytes, is what makes the port's protocol simpler than the cable's.
- **The derived fields do not travel.** `shiny`, `gender` and `unownLetter` are
  all functions of the DVs (`Mon.isShiny`, `Mon.gender`, `Unown.letterFromDVs`),
  so the receiver recomputes them and a tampered packet cannot claim a shiny it
  did not roll. Same reasoning as `unpackMon` recomputing stats.

`LinkBattle.lua` breaks in a larger way. It calls
`BattleState.makeBattler`, `src/battle/TurnOrder.lua` and Gen 1's damage
pipeline directly. Gold's battle is `src/battle/gen2/Battle.lua`, a different
object with a different event shape. The one piece of good news is that
`Battle.new` already takes `opts.random` (`src/battle/gen2/Battle.lua:220`) --
the injection seam a lockstep battle needs is there and does not have to be cut.

## 4. The wire format for Gen 2

Message types stay the ones `Protocol.lua` already documents (`hello`,
`records`, `party`, `pick`, `confirm`, `action`, `event`, `bye`). Gen 2 adds
fields, never renames -- the same rule the mod seams follow.

**`hello`** gains one field, `generation` (1 or 2). A peer that omits it is
generation 1 by construction: no released build has ever had Gen 2 link, so
absent means Red/Blue/Yellow. This is implemented.

**`party`** carries a list of packed mons whose shape is the Gen 2 one:

```
{ species, level, experience, hp, status, nickname,
  dvs = { attack, defense, speed, special },   -- hp derived
  statExp = { hp, attack, defense, speed, special },
  moves = { { id, pp } ... },
  item, happiness, pokerus, caughtLevel,
  ot, otId, isEgg, eggSteps, extra }
```

and, in a trade, a parallel `mail` array indexed by the same wire position --
separate exactly as `Link_PrepPartyData_Gen2` keeps it separate, because mail is
SRAM the cart copies out of `sPartyMail`, not part of the party struct. The
codec for the mon half is implemented; the mail half is not.

**`records`** gains a third map, `heldItems`, beside `pokemon` and `moves`, so a
subset trade can refuse a mon whose held item the other game would rebuild
differently. Implemented.

**`action` / `event`** for a lockstep Gen 2 battle are not designed here, because
the design is downstream of a decision nobody has made yet: whether
`src/battle/gen2/Battle.lua` grows a "replay these two actions" entry point or
whether the link battle drives it through the same UI path a local battle uses.
Guessing at a message shape before that is exactly the half-built protocol this
document is meant to avoid.

## 5. The fingerprint on Gold

The fingerprint is the one part of the design that is fully answerable today,
because it depends only on what a Gold mod can reach, and `src/mods/Schemas.lua`
answers that exhaustively.

The Gen 1 surface is species, moves, the type chart, statuses, move effects,
constants and mod-declared link fields. The Gen 2 surface is the same idea over
different tables, plus one registry Gen 1 does not have:

| What | Gen 1 | Gen 2 | Why it is surface |
| --- | --- | --- | --- |
| species | `data.pokemon` | `data.pokemon` (Gen 2 shape) | base stats decide every damage roll; `evolutions` decides what a traded mon becomes |
| exp curves | code (`src/pokemon/Growth.lua`) | `data.pokemon.growthRates` | the level a traded mon's experience buys |
| moves | `data.moves` | `data.moves`, **plus `effectChance`** | Gen 2 stores the secondary-effect odds per move rather than per effect |
| type chart | `data.type_chart` | same, **plus `foresightMatchups`** | Foresight rewrites Ghost's immunities mid-battle |
| statuses | `data.statuses` | `data.gen2Statuses` | `statPenalty`, `cureOnSwitch`, `beforeMovePriority` |
| move effects | `data.move_effects` | `data.gen2MoveEffects` | which effect is primary, secondary, or accuracy-checked |
| held items | -- | `data.gen2HeldItems` | Leftovers, King's Rock, the type boosters: pure battle math, and the item travels with a traded mon |
| link fields | `data.link_fields` | none (gated) | a mod-declared extra mon field; see below |

Deliberately **not** hashed on either generation, and the reasoning is the same
in both:

- Names, dex entries, learnsets, TM/HM lists, sprite paths and `source`. None of
  them changes a battle turn or a trade rebuild, and sprite paths differ between
  two identical installs.
- `catchRate` (#511). A ball thrown in a link battle is refused; hashing it split
  Red/Blue from Yellow over two bytes.
- Balls and item effects. Link battles allow no bag items on either cart.
- `data.gen2Constants`. It is the ROM's ordered name lists -- `mapOrder`,
  `spriteOrder`, `speciesOrder`, `heldEffectOrder` -- and it is an *index* space.
  Every dispatch in the Gen 2 simulation goes by name (`Battle.heldEffect`
  compares `record.heldEffect` strings, `moveEffectRecordFor` keys by
  `EFFECT_*`), so reordering a constants list moves no battle math. Hashing it
  would split two peers over a list neither of them dispatches on.
- Breeding data (`eggGroups`, `eggMoves`, `eggSteps`). The Day-Care is local.
  There is no link breeding and an egg's contents are decided before it is
  traded.
- Everything in the Gen 2-only registries that is not `held_items`:
  `phone_contacts`, `decorations`, `apricorns`, `landmarks`, `radio_channels`.
  None of them can be observed from inside a link session.

`genderRatio` **is** hashed, unlike anything in the breeding block, because Gen 2
has Attract and a gender disagreement is a battle-math disagreement.

`link_fields` stays gated on Gen 2 (`Schemas.GEN2`). It is a mod's declaration
that an extra mon field must survive the wire, and it can only be un-gated once
there is a Gen 2 mon wire format with a session behind it. A registry that hashes
into the fingerprint but that no packer reads would be a lie the fingerprint
tells.

The hook keeps its Gen 1 name and its Gen 1 arity. `link.fingerprint` is called
as `(data, mods)` on both generations, and the generation is captured in the
vanilla closure rather than passed as a third argument -- a Gen 1 mod that wraps
the hook and forwards `nxt(data, mods)` therefore works verbatim on Gold, which
a third argument would have quietly broken.

## 6. Cross-generation pairing

`Handshake.checkCompat` refuses a pairing whose two `generation` fields differ,
with reason `generation_mismatch`, before any other check. This is deliberately
a refusal and not a Time Capsule: section 2 costs roughly 400 lines of lossy
conversion plus two validators, and shipping a menu that pairs a Gold game with a
Red one and then rebuilds a Cyndaquil as whatever species index 155 happens to
be in Red would be worse than refusing.

If somebody does want the Time Capsule later, the cart's own rules are the spec,
and the port has an advantage the cart did not: ids rather than indices, so
`ConvertMon_2to1`'s remap table is unnecessary. What remains is real work:
refuse species above the Kanto 151, refuse moves Gen 1 lacks, refuse held items
and mail, fold `specialAttack`/`specialDefense` back into one Special
(`KantoMonSpecials`, `data/pokemon/gen1_base_special.asm`), and re-validate types
on arrival with Magnemite and Magneton carved out.

## 7. What is built, and what is left

**Built (this change).**

- `Fingerprint.generationOf(data)`: reads `data.type_chart.generation`, then the
  presence of the Gen 2-only Data namespaces, so the digest never has to be told
  which game it is running in.
- A Gen 2 link surface in `Fingerprint.lua`, tagged `[gen2]` so a Gen 2 digest
  can never collide with a Gen 1 one, covering the table in section 5.
- `Fingerprint.records(data, kind, generation)` for `pokemon`, `moves` and
  `held_items` on Gold, which is what a subset trade negotiates on.
- `Handshake.hello` carries `generation`; `checkCompat` refuses a cross-generation
  pairing; `describe` explains it in the screen's own voice.
- `held_items` counts as link surface for `Handshake.linkModified`, so a Gold mod
  that gives Leftovers a different heal is correctly locked out of online play.
  `growth_rates` counts too, and for a reason worth stating: a curve is an
  `expForLevel` function, so the fingerprint serializes it as `?` and cannot
  hash it at all. `Mon.growthFor` prefers the merged registry over the
  extractor's coefficient rows, so a mod declaring `affects_link = false` could
  otherwise rewrite every curve -- changing what level a traded mon's experience
  buys -- and be caught by neither the digest nor the online gate.
- `Protocol.packMon2` / `unpackMon2`: the Gen 2 party-struct codec, with the
  receiver recomputing stats, experience, shininess and gender from real species
  data the way `unpackMon` does. Nothing sends it yet.
- `Protocol.recordsMessage` and `eligibleParty` understand held items, and
  `TradeSession:_negotiate` builds our own side of the comparison by calling
  `recordsMessage` rather than open-coding a subset of it. That is not a
  refactor: the open-coded version left `heldItems` off our side only, and both
  held-item arms of `eligibleParty` are guarded on our own map, so the whole
  check was unreachable from the only caller that matters.

**Not built.** Sized as honestly as I can:

| Piece | Size | Why it is not here |
| --- | --- | --- |
| Mail on the wire | small (1-2 days) | needs `Mail.state(save).party` packed as a parallel array and the receiver writing it into its own slot; no consumer until the trade session exists |
| Gen 2 trade session | medium (about a week) | `TradeSession` is generic in shape but `apply` calls `src/world/PikachuFollower`, Gen 1 pokedex fields and Gen 1 trade evolutions; Gold needs `src/core/gen2/TradeAnim.lua`, `src/core/gen2/Evolution.lua` (`EVOLVE_TRADE`) and the Gen 2 pokedex |
| Gold LINK menu and trade UI | medium (about a week) | Gold's menus are `src/ui/gen2/`, its text box is Gen 2 chrome, and the Cable Club script needs the receptionist path; `LinkState.lua` draws with Gen 1 `TextBox` throughout |
| Gen 2 lockstep battle | large (several weeks) | needs a deterministic-replay entry point into `src/battle/gen2/Battle.lua`, a Gen 2 action/event encoding, and a state hash over a much larger volatile-status set than Gen 1's; the `opts.random` seam exists, nothing else does |
| Time Capsule | large | section 6 |
| `link_fields` on Gen 2 | small, but blocked | needs the trade session first |

The order matters: mail, session and UI are the trade half and can ship without
the battle half, exactly as the cart's Trade Center and Colosseum are separate
rooms. A Gold LINK menu that offers only TRADE is a complete feature. A Gold
LINK menu that offers BATTLE before the lockstep battle exists is the failure
this document was written to prevent.

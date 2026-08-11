# ASM Walk output format

Every `section-NN-*.md` in this folder follows the structure below. The goal is a
single place a bot author can look at to answer "for this stretch of the
walkthrough, which maps, warps, objects, scripts, flags, items and trainers are
involved, and where in the pokegold disassembly do they live?"

Conventions:

- Disassembly paths are written relative to the pokegold checkout root, e.g.
  `maps/NewBarkTown.asm`, `data/maps/maps.asm`, `constants/event_flags.asm`.
- Port paths are written relative to this repo root, e.g. `src/world/gen2/Map.lua`.
- Coordinates are the raw asm values (map-block coordinates as written in the
  `warp_event` / `object_event` / `bg_event` rows), not screen pixels.
- Anything not verified by opening the file is omitted rather than guessed. If a
  walkthrough claim could not be located in the asm, it goes under
  "Unresolved / verify by hand".

---

# Section NN - <title>

Source: `../section-NN-<slug>.txt`
Maps covered: `MAP_A`, `MAP_B`, ...
Badges / key milestones in this section: ...

## 1. Route order

Ordered list of map transitions the walkthrough takes, one row per hop.

| # | Map constant | asm file | Enter via | Leaves via | Why (walkthrough beat) |
|---|---|---|---|---|---|

## 2. Maps

Repeat this block per map.

### MAP_<NAME>

- Script: `maps/<Name>.asm`
- Blocks: `maps/<Name>.blk` (if present)
- Header: `data/maps/maps.asm` -> tileset, environment, location, music, phone, palette
- Dimensions / attributes: `constants/map_constants.asm` (`map_const <NAME>, W, H`)
- Connections: north/south/east/west map constants

**Warps** (`def_warp_events`)

| idx | x | y | destination map | dest warp |
|---|---|---|---|---|

**Coord events** (`def_coord_events`) - the scripted trip-wires a bot will hit

| scene | x | y | script label | effect |
|---|---|---|---|---|

**BG events** (`def_bg_events`) - signs, hidden items

| x | y | type | script/item |
|---|---|---|---|

**Object events** (`def_object_events`) - NPCs, item balls, trainers

| const | sprite | x | y | movement | type | script label | event flag |
|---|---|---|---|---|---|---|---|

**Scripts of interest**

For each script label the walkthrough actually depends on: label, a short prose
summary of what the opcodes do, and the flags/items/battles it touches. Cite the
label name so it can be grepped.

**Flags and events**

| constant | defined in | read/written by | meaning for a bot |
|---|---|---|---|

Include `EVENT_*` (`constants/event_flags.asm`), `ENGINE_*`
(`constants/engine_flags.asm`), and any `SCENE_*` values
(`constants/map_setup_constants.asm` / the map's own `object_const_def` block).

**Items**

| item | how obtained | source (label / bg_event / hidden) | one-time flag |
|---|---|---|---|

**Trainers**

| const | class | id | party (`data/trainers/parties.asm` label) | script label | rematch/phone |
|---|---|---|---|---|---|

**Wild encounters**

Table entry in `data/wild/johto_grass.asm` / `johto_water.asm` /
`kanto_grass.asm` / `kanto_water.asm`, plus fishing (`data/wild/fish.asm`),
headbutt (`data/wild/treemons.asm`) and rock smash where relevant. Note the
morn/day/nite split.

## 3. Blockers and gates

What actually stops forward progress in this section, and the precise check.

| Gate | Enforced by (file:label) | Requirement | Unlock condition |
|---|---|---|---|

Cover badge checks, HM field-move checks (`engine/overworld/`), key items,
`EVENT_*` guards, and NPC-blocked tiles.

## 4. Bot checklist

The machine-actionable version: an ordered list of steps a scripted playthrough
would execute. Each step names the map, the target coordinates or object const,
the input intent (talk / walk / use item / battle), the precondition flag and the
postcondition flag. Keep it literal enough that someone can turn a row into a
driver command without reopening the asm.

## 5. Port coverage

Where this section's mechanics land in this repo, and what is missing.

| Beat | Port file | Status |
|---|---|---|

## 6. Unresolved / verify by hand

Anything the walkthrough asserts that could not be pinned to a specific asm
location, plus any contradictions found between the two.

#!/usr/bin/env python3
"""Blockset explorer: what is in a tileset's blockset, what is free, and what
new 32x32 blocks can be built out of the 8x8 tiles it already owns.

Developer-only, like tools/build_data.py.  Reads the generated cache
(data/generated/tilesets.lua, data/generated/maps.lua and the tileset PNGs
under assets/generated/tilesets/); writes nothing back into it.

A block is 4x4 = 16 tiles of 8x8, matching pokered's blockdata (16 bytes per
block, see data/tilesets/*_blockset.bst).  Map blockdata stores a block index
in one byte, so a tileset can never hold more than 256 blocks: the interesting
budget is the free slots between the blocks a tileset ships and that ceiling,
not the raw combination count.  Exhaustive enumeration is not a thing you can
run -- OVERWORLD has 93 distinct tiles, so 93^16 is about 3.3e31 blocks -- so
the generator recombines under constraints learned from the real blocks
instead.  --mode exhaustive exists to show the wall rather than to hit it.

Usage:
  python3 tools/blockgen.py --list
  python3 tools/blockgen.py --tileset OVERWORLD
  python3 tools/blockgen.py --tileset OVERWORLD --sheet /tmp/blocks.png
  python3 tools/blockgen.py --tileset CAVERN --mode exhaustive
"""

import argparse
import collections
import hashlib
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TILESETS_LUA = os.path.join(ROOT, "data/generated/tilesets.lua")
MAPS_LUA = os.path.join(ROOT, "data/generated/maps.lua")

BLOCK_TILES = 4          # a block is 4x4 tiles
TILE_PX = 8
# The engine has no block ceiling: src/world/Map.lua indexes tilesetDef.blocks
# as a plain Lua array and never masks the id, and mods register tilesets with
# arbitrary block lists (src/mods/Schemas.lua). 256 is the ROM's limit, not
# ours -- map blockdata on the cart is one byte per block, so only blocks
# IMPORTED from a ROM are bound by it. Kept here to report parity headroom.
ROM_BLOCK_LIMIT = 256
BLOCK_LIMIT = ROM_BLOCK_LIMIT


# ----------------------------------------------------------------- lua parsing
# The generated caches are plain nested table literals (numbers, strings,
# booleans, `key = value`), so a small recursive-descent reader beats shelling
# out to luajit and keeps this runnable with no interpreter installed.

_TOKEN = re.compile(r"""
    (?P<ws>\s+|--[^\n]*)
  | (?P<str>"(?:[^"\\]|\\.)*")
  | (?P<num>-?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?)
  | (?P<name>[A-Za-z_][A-Za-z_0-9]*)
  | (?P<punct>[{}\[\]=,;])
""", re.X)


def _tokenize(text):
    pos, n, out = 0, len(text), []
    while pos < n:
        m = _TOKEN.match(text, pos)
        if not m:
            raise ValueError("lua parse: stuck at %r" % text[pos:pos + 40])
        pos = m.end()
        if m.lastgroup != "ws":
            out.append((m.lastgroup, m.group()))
    return out


def parse_lua(text):
    """Parse `return { ... }`.  Array parts come back as lists, keyed parts as
    dicts; a table with both is returned as a dict with integer keys."""
    toks = _tokenize(text)
    i = 0
    if toks and toks[0] == ("name", "return"):
        i = 1

    def value(i):
        kind, tok = toks[i]
        if kind == "num":
            return (float(tok) if ("." in tok or "e" in tok.lower()) else int(tok)), i + 1
        if kind == "str":
            return tok[1:-1].encode().decode("unicode_escape"), i + 1
        if kind == "name":
            if tok == "true":
                return True, i + 1
            if tok == "false":
                return False, i + 1
            if tok == "nil":
                return None, i + 1
            raise ValueError("lua parse: bare name %r" % tok)
        if tok == "{":
            return table(i + 1)
        raise ValueError("lua parse: unexpected %r" % tok)

    def table(i):
        arr, dct = [], {}
        while True:
            kind, tok = toks[i]
            if tok == "}":
                return (dct if dct else arr) if not (dct and arr) else _merge(arr, dct), i + 1
            if tok in (",", ";"):
                i += 1
                continue
            # `key = v` or `["key"] = v`
            if kind == "name" and toks[i + 1][1] == "=":
                k = tok
                v, i = value(i + 2)
                dct[k] = v
                continue
            if tok == "[":
                k, i = value(i + 1)
                assert toks[i][1] == "]" and toks[i + 1][1] == "="
                v, i = value(i + 2)
                dct[k] = v
                continue
            v, i = value(i)
            arr.append(v)

    def _merge(arr, dct):
        out = dict(dct)
        for n, v in enumerate(arr, 1):
            out[n] = v
        return out

    v, _ = value(i)
    return v


# ------------------------------------------------------------------ tile art
def load_tiles(record):
    """Slice a tileset PNG into 8x8 tiles, indexed the way the block data
    indexes them (row-major, tilesPerRow per row).  Returns None when Pillow is
    missing, so the structural half of this script still runs."""
    try:
        from PIL import Image
    except ImportError:
        return None
    path = os.path.join(ROOT, record["image"])
    if not os.path.exists(path):
        return None
    img = Image.open(path).convert("RGB")
    per_row = record["tilesPerRow"]
    rows = img.height // TILE_PX
    tiles = {}
    for idx in range(rows * per_row):
        tx, ty = (idx % per_row) * TILE_PX, (idx // per_row) * TILE_PX
        tiles[idx] = img.crop((tx, ty, tx + TILE_PX, ty + TILE_PX))
    return tiles


def tile_hash(tile):
    return hashlib.blake2b(tile.tobytes(), digest_size=8).hexdigest()


def edges(tile):
    """(top, bottom, left, right) pixel-row/column signatures.  Two tiles butt
    together seamlessly when the facing edges match, which is what makes a
    recombined block read as deliberate rather than as noise."""
    px = tile.load()
    w, h = tile.size
    top = bytes(v for x in range(w) for v in px[x, 0])
    bot = bytes(v for x in range(w) for v in px[x, h - 1])
    left = bytes(v for y in range(h) for v in px[0, y])
    right = bytes(v for y in range(h) for v in px[w - 1, y])
    return top, bot, left, right


# ------------------------------------------------------------- categorisation
def categorise(record, tiles):
    """Tag every tile id the blockset actually uses.  Roles come from the
    tileset metadata the extractor already carries (walkable / grass / door /
    warp / counter); everything else is scenery.  Visual duplicates are folded
    into one class so 'make unique' means unique art, not unique index."""
    used = sorted({t for blk in record["blocks"] for t in blk})
    walkable = set(record.get("walkable") or [])
    doors = set(record.get("doorTiles") or [])
    warps = set(record.get("warpTiles") or [])
    counters = set(record.get("counterTiles") or [])
    grass = record.get("grassTile")

    role = {}
    for t in used:
        if t == grass:
            role[t] = "grass"
        elif t in doors:
            role[t] = "door"
        elif t in warps:
            role[t] = "warp"
        elif t in counters:
            role[t] = "counter"
        elif t in walkable:
            role[t] = "walkable"
        else:
            role[t] = "scenery"

    # visual identity classes: distinct ids whose art is byte-identical
    art_class, alias = {}, {}
    if tiles:
        for t in used:
            if t in tiles:
                art_class.setdefault(tile_hash(tiles[t]), []).append(t)
        for ids in art_class.values():
            for t in ids:
                alias[t] = ids[0]
    else:
        alias = {t: t for t in used}

    return used, role, alias, art_class


# ------------------------------------------------------------------- analysis
def blocks_in_use(maps, tileset_name):
    """Block indices any map on this tileset actually places.  A block that no
    map references is already a free slot in everything but name."""
    seen = set()
    maps_on = 0
    for rec in maps.values():
        if not isinstance(rec, dict) or rec.get("tileset") != tileset_name:
            continue
        maps_on += 1
        for b in rec.get("blocks") or []:
            seen.add(b)
    return seen, maps_on


def canon(block, alias):
    """Identity of a block by art, not by tile index."""
    return tuple(alias.get(t, t) for t in block)


def learn_constraints(blocks, alias):
    """What the real blocks permit: which tiles appear at each of the 16
    positions, and which tiles ever sit directly right of / below which."""
    pos_vocab = [set() for _ in range(16)]
    right_of = collections.defaultdict(set)
    below = collections.defaultdict(set)
    for blk in blocks:
        a = [alias.get(t, t) for t in blk]
        for i, t in enumerate(a):
            pos_vocab[i].add(t)
            r, c = divmod(i, BLOCK_TILES)
            if c + 1 < BLOCK_TILES:
                right_of[t].add(a[i + 1])
            if r + 1 < BLOCK_TILES:
                below[t].add(a[i + BLOCK_TILES])
    return pos_vocab, right_of, below


def fill_tiles(blocks, alias, share=0.04):
    """The tiles a blockset uses as background.  Anything holding more than
    `share` of all tile slots across the real blocks is fill: grass, path,
    interior floor.  Used to score structure, since a block made only of these
    is a texture swatch, not a block worth a slot."""
    counts = collections.Counter(alias.get(t, t) for blk in blocks for t in blk)
    total = sum(counts.values())
    return {t for t, n in counts.items() if n / total > share}


def render_block(block, tiles):
    """A block's 32x32 pixels, for comparing what a block LOOKS like rather
    than which indices it happens to name.  Two blocks built from different
    ids whose art is identical render identical here, which index-space
    distance cannot see."""
    from PIL import Image
    px = BLOCK_TILES * TILE_PX
    img = Image.new("RGB", (px, px))
    for i, t in enumerate(block):
        art = tiles.get(t)
        if art is None:
            continue
        r, c = divmod(i, BLOCK_TILES)
        img.paste(art, (c * TILE_PX, r * TILE_PX))
    return img


def score_block(block, alias, fill):
    """How much structure a block carries.  Distinct art plus non-fill tiles,
    with a hard floor: a block that is almost entirely one tile is a swatch."""
    a = [alias.get(t, t) for t in block]
    distinct = len(set(a))
    non_fill = sum(1 for t in a if t not in fill)
    dominant = collections.Counter(a).most_common(1)[0][1]
    if distinct < 3 or non_fill == 0 or dominant >= 14:
        return 0
    return non_fill * 2 + distinct


def tile_diff_table(tiles, ids):
    """Pixel differences between every pair of tiles, once.

    Two blocks differ by exactly the sum of their per-slot tile differences, so
    this turns a 1024-pixel comparison per block pair into 16 lookups.  That is
    the difference between this finishing and not: 400 blocks needs millions of
    pair comparisons, and pure Python cannot walk 1024 pixels that many times."""
    raw = {t: tiles[t].tobytes() for t in ids if t in tiles}
    table = {}
    for a in raw:
        ra = raw[a]
        row = table.setdefault(a, {})
        for b in raw:
            if b in row:
                continue
            rb = raw[b]
            d = sum(1 for i in range(0, len(ra), 3) if ra[i:i + 3] != rb[i:i + 3])
            row[b] = d
            table.setdefault(b, {})[a] = d
    return table


def too_close(cand, kept, table, budget):
    """True when `cand` is within `budget` differing pixels of anything kept.
    Accumulates per slot and bails the moment a block is provably far enough,
    so the common case costs a handful of lookups rather than 16."""
    for other in kept:
        total = 0
        for x, y in zip(cand, other):
            if x != y:
                total += table.get(x, {}).get(y, TILE_PX * TILE_PX)
                if total >= budget:
                    break
        if total < budget:
            return True
    return False


def generate(blocks, alias, limit, tiles=None, seed=0, min_distance=6,
             attempts_per=200, oversample=8, min_pixel_diff=0.12):
    """Sample blocks the real blockset's own rules permit: a tile may only sit
    at a position it is observed at, and only next to / below tiles it is
    observed next to / below.

    Sampling is randomised rather than depth-first on purpose.  A sorted DFS
    walks the lexicographically first prefix to exhaustion, so its first
    hundred results are one corner with the last tile wiggling -- technically
    unique, useless as art.  Random restarts spread over the space, and
    min_distance (tiles differing from every block already kept, the blockset's
    included) is what stops near-duplicates coming back under a new index."""
    import random
    rng = random.Random(seed)
    pos_vocab, right_of, below = learn_constraints(blocks, alias)
    fill = fill_tiles(blocks, alias)
    existing = [canon(b, alias) for b in blocks]
    existing_set = set(existing)
    out, seen = [], set()
    kept = list(existing)

    def far_enough(cand):
        for other in kept:
            if sum(1 for a, b in zip(cand, other) if a != b) < min_distance:
                return False
        return True

    def sample():
        """One randomised walk with backtracking; None if it paints itself in.
        `tried` mirrors `cur` so a position never re-picks a tile that already
        led to a dead end on this walk."""
        cur, tried = [], []
        while len(cur) < 16:
            i = len(cur)
            r, c = divmod(i, BLOCK_TILES)
            cand = set(pos_vocab[i])
            if c > 0:
                cand &= right_of.get(cur[i - 1], set())
            if r > 0:
                cand &= below.get(cur[i - BLOCK_TILES], set())
            if i == len(tried):
                tried.append(set())
            cand -= tried[i]
            if not cand:
                if i == 0:
                    return None
                tried.pop()
                cur.pop()
                continue
            pick = rng.choice(sorted(cand))
            tried[i].add(pick)
            cur.append(pick)
        return tuple(cur)

    # Oversample into a pool, rank by structure, then take the best that are
    # visually far enough apart.  Filling greedily in sample order instead is
    # what produced a sheet of grass swatches: every one of them cleared a
    # 6-tile index distance by swapping interchangeable background, which is
    # not a difference anybody can see.
    pool, tries = [], 0
    want = limit * oversample
    while len(pool) < want and tries < want * attempts_per:
        tries += 1
        cand = sample()
        if cand is None or cand in existing_set or cand in seen:
            continue
        seen.add(cand)
        pool.append(cand)

    scored = [(score_block(c, alias, fill), c) for c in pool]
    scored = [(s, c) for s, c in scored if s > 0]
    scored.sort(key=lambda sc: -sc[0])

    table = tile_diff_table(tiles, {t for b in pool for t in b} |
                            {t for b in existing for t in b}) if tiles else None
    budget = int(min_pixel_diff * (BLOCK_TILES * TILE_PX) ** 2)
    stats = {"pool": len(pool), "swatches": len(pool) - len(scored),
             "too_similar": 0, "budget_px": budget, "asked": limit}
    for _score, cand in scored:
        if len(out) >= limit:
            break
        if table is not None:
            if too_close(cand, kept, table, budget):
                stats["too_similar"] += 1
                continue
        elif not far_enough(cand):
            stats["too_similar"] += 1
            continue
        kept.append(cand)
        out.append(list(cand))
    stats["short_by"] = max(0, limit - len(out))
    return out, stats


def exhaustive_estimate(used_by_role):
    """The user's original plan, priced.  Not run: printed."""
    rows = []
    for role, ids in sorted(used_by_role.items()):
        k = len(ids)
        rows.append((role, k, k ** 16))
    return rows


# --------------------------------------------------------------------- output
def write_sheet(path, blocks, tiles, cols=8, scale=3, number=True):
    """Contact sheet, numbered the way the blockset viewer numbers the real
    blocks so a block can be named in conversation.  Indices are into the
    generated run, not into the tileset: they only mean anything for the same
    --seed."""
    from PIL import Image, ImageDraw
    if not blocks:
        return False
    px = BLOCK_TILES * TILE_PX
    rows = (len(blocks) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * (px + 2), rows * (px + 2)), (24, 24, 24))
    for n, blk in enumerate(blocks):
        bx, by = (n % cols) * (px + 2), (n // cols) * (px + 2)
        for i, t in enumerate(blk):
            art = tiles.get(t)
            if art is None:
                continue
            r, c = divmod(i, BLOCK_TILES)
            sheet.paste(art, (bx + c * TILE_PX, by + r * TILE_PX))
    if scale > 1:
        sheet = sheet.resize((sheet.width * scale, sheet.height * scale), Image.NEAREST)
    if number:
        draw = ImageDraw.Draw(sheet)
        for n in range(len(blocks)):
            bx = (n % cols) * (px + 2) * scale
            by = (n // cols) * (px + 2) * scale
            label = str(n)
            w = 6 * len(label) + 2
            draw.rectangle([bx, by, bx + w, by + 10], fill=(20, 20, 20))
            draw.text((bx + 2, by + 1), label, fill=(255, 255, 255))
    sheet.save(path)
    return True


def report(name, record, maps, args):
    blocks = record["blocks"]
    tiles = load_tiles(record)
    used, role, alias, art_class = categorise(record, tiles)
    placed, maps_on = blocks_in_use(maps, name)

    by_role = collections.defaultdict(list)
    for t in used:
        by_role[role[t]].append(t)

    dup_ids = sum(len(v) - 1 for v in art_class.values()) if tiles else 0
    distinct_art = len(art_class) if tiles else len(used)

    print("%s  (%s)" % (name, record.get("image", "no image")))
    print("  blocks shipped      %d  (%d under the ROM's 256-block addressing"
          % (len(blocks), ROM_BLOCK_LIMIT - len(blocks)))
    print("                      limit; the engine itself has no ceiling)")
    print("  8x8 tiles referenced %d  (%d distinct by art, %d are duplicate ids)"
          % (len(used), distinct_art, dup_ids))
    print("  categories          " + ", ".join(
        "%s=%d" % (r, len(v)) for r, v in sorted(by_role.items())))
    print("  maps on this tileset %d, placing %d distinct blocks"
          % (maps_on, len(placed)))

    never = [i for i in range(len(blocks)) if i not in placed]
    print("  blocks no map places %d%s" % (
        len(never), ("  -> " + ", ".join(map(str, never[:16])) + ("..." if len(never) > 16 else ""))
        if never else ""))

    if args.mode == "exhaustive":
        print("\n  exhaustive enumeration, per category (this is the wall):")
        for r, k, total in exhaustive_estimate(by_role):
            print("    %-9s %2d tiles -> %d^16 = %.3g blocks" % (r, k, k, total))
        print("    at 1e9 blocks/sec the smallest of those still outlives the sun.")
        return

    budget_n = args.limit if args.limit else (BLOCK_LIMIT - len(blocks))
    made, gstats = generate(blocks, alias, budget_n, tiles=tiles, seed=args.seed,
                            min_distance=args.min_distance,
                            min_pixel_diff=args.min_pixel_diff,
                            oversample=args.oversample)
    print("\n  generated %d of the %d asked for, from a pool of %d"
          % (len(made), gstats["asked"], gstats["pool"]))
    print("    %d rejected as texture swatches (no structure)" % gstats["swatches"])
    print("    %d rejected as within %d differing pixels of a block already kept"
          % (gstats["too_similar"], gstats["budget_px"]))
    if gstats["short_by"]:
        print("    SHORT BY %d: the pool ran out before the quota filled. Raise"
              % gstats["short_by"])
        print("    --oversample, or lower --min-pixel-diff to accept closer blocks.")
    # Reproducibility: same cache + same flags must give the same blocks, so
    # print a digest of exactly that rather than asking anyone to trust it.
    digest = hashlib.sha256(
        ("%s|%d|%d|%.4f|%d|" % (name, args.seed, budget_n, args.min_pixel_diff,
                                args.oversample)
         + ";".join(",".join(map(str, b)) for b in made)).encode()).hexdigest()
    print("    digest %s  (seed %d, oversample %d, min-pixel-diff %.2f)"
          % (digest[:16], args.seed, args.oversample, args.min_pixel_diff))
    if made:
        print("  first three, as tile indices:")
        for blk in made[:3]:
            for r in range(BLOCK_TILES):
                print("    " + " ".join("%3d" % t for t in blk[r * 4:r * 4 + 4]))
            print()
    if args.sheet and tiles and made:
        if write_sheet(args.sheet, made[:args.sheet_count], tiles, cols=args.cols):
            print("  contact sheet: %s (%d blocks)" % (args.sheet, min(len(made), args.sheet_count)))
    elif args.sheet and not tiles:
        print("  (no contact sheet: Pillow or the tileset PNG is missing)")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--tileset", help="tileset id, e.g. OVERWORLD")
    ap.add_argument("--list", action="store_true", help="list tilesets and exit")
    ap.add_argument("--mode", choices=["adjacency", "exhaustive"], default="adjacency")
    ap.add_argument("--limit", type=int, default=0,
                    help="cap generated blocks (default: the free slots up to 256)")
    ap.add_argument("--sheet", help="write a PNG contact sheet of generated blocks")
    ap.add_argument("--sheet-count", type=int, default=64)
    ap.add_argument("--cols", type=int, default=8)
    ap.add_argument("--seed", type=int, default=0,
                    help="fixed by default: the same cache and flags always give the same blocks")
    ap.add_argument("--oversample", type=int, default=8,
                    help="candidates sampled per block kept")
    ap.add_argument("--min-pixel-diff", type=float, default=0.12,
                    help="fraction of the 32x32 pixels that must differ from every kept block")
    ap.add_argument("--min-distance", type=int, default=6,
                    help="tiles that must differ from every block already kept")
    args = ap.parse_args()

    for p in (TILESETS_LUA, MAPS_LUA):
        if not os.path.exists(p):
            sys.exit("missing %s -- import a ROM first (scripts/setup.sh --rom ...)" % p)

    tilesets = parse_lua(open(TILESETS_LUA).read())
    maps = parse_lua(open(MAPS_LUA).read())

    if args.list or not args.tileset:
        print("%-14s %7s %7s %7s" % ("tileset", "blocks", "free", "tiles"))
        for name in sorted(tilesets):
            rec = tilesets[name]
            used = {t for blk in rec["blocks"] for t in blk}
            print("%-14s %7d %7d %7d"
                  % (name, len(rec["blocks"]), BLOCK_LIMIT - len(rec["blocks"]), len(used)))
        return

    name = args.tileset.upper()
    if name not in tilesets:
        sys.exit("unknown tileset %r (try --list)" % args.tileset)
    report(name, tilesets[name], maps, args)


if __name__ == "__main__":
    main()

-- Gold Phase 1: Rom.decompressLz3 ports pokegold's home/decompress.asm
-- ("lz3") byte-for-byte.  There is no bundled Gold ROM to decompress real
-- pics against, so this instead hand-assembles small compressed streams for
-- every command (LZ_LITERAL/ITERATE/ALTERNATE/ZERO/REPEAT/FLIP/REVERSE, plus
-- LZ_LONG and the 7-bit/15-bit lookback forms) and checks the decoded bytes
-- against what the disassembly says each one does; cross-checked against
-- tools/lzcompress.c's --uncompress reference path.
-- Self-contained: `luajit tests/rom_lz3_test.lua`; also dofile'd by
-- tests/run_tests.lua.
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("rom lz3 decompress")
local same = S.same

local Rom = require("src.import.Rom")

local function decompress(bytes)
  return Rom.decompressLz3(bytes)
end

-- LZ_LITERAL: cmd=0, length=4
same(decompress({ 0x03, 0x11, 0x22, 0x33, 0x44, 0xFF }),
  { 0x11, 0x22, 0x33, 0x44 }, "literal")

-- LZ_ITERATE: cmd=1, length=5, one repeated byte
same(decompress({ 0x24, 0x7A, 0xFF }),
  { 0x7A, 0x7A, 0x7A, 0x7A, 0x7A }, "iterate")

-- LZ_ALTERNATE: cmd=2, length=5, two alternating bytes (starts with the
-- first byte, per home/decompress.asm's .Alt / .anext1)
same(decompress({ 0x44, 0x01, 0x02, 0xFF }),
  { 1, 2, 1, 2, 1 }, "alternate")

-- LZ_ZERO: cmd=3, length=6
same(decompress({ 0x65, 0xFF }),
  { 0, 0, 0, 0, 0, 0 }, "zero")

-- LZ_REPEAT with a 15-bit positive offset from the start of the output
-- (literal 4 bytes, then repeat all 4 from offset 0)
same(decompress({
  0x03, 0xAA, 0xBB, 0xCC, 0xDD,
  0x83, 0x00, 0x00,
  0xFF,
}), { 0xAA, 0xBB, 0xCC, 0xDD, 0xAA, 0xBB, 0xCC, 0xDD }, "repeat (positive offset)")

-- LZ_REPEAT with a 7-bit negative offset that overlaps the bytes it is
-- still writing -- an RLE-style self-extending repeat (Decompress's .Repeat
-- reads with [hli], so the source pointer walks forward into freshly
-- written output exactly like this).
same(decompress({
  0x00, 0x05,        -- literal: {5}
  0x84, 0x80,         -- repeat length 5, offset magnitude 0 (from the byte just written)
  0xFF,
}), { 5, 5, 5, 5, 5, 5 }, "repeat (self-overlapping negative offset)")

-- LZ_FLIP: bit-reverses each copied byte
same(decompress({
  0x00, 0xB0,          -- literal: {0xB0} (1011 0000)
  0xA0, 0x80,           -- flip length 1, offset magnitude 0
  0xFF,
}), { 0xB0, 0x0D }, "flip (0xB0 reversed is 0x0D)")

-- LZ_REVERSE: copies backwards from the offset
same(decompress({
  0x02, 0x01, 0x02, 0x03,  -- literal: {1, 2, 3}
  0xC2, 0x80,               -- reverse length 3, offset magnitude 0
  0xFF,
}), { 1, 2, 3, 3, 2, 1 }, "reverse")

-- LZ_LONG: 111xxxyy yyyyyyyy extends ITERATE past the 5-bit short length
-- (here length 40, encoded as 39 = 0x27 with no high bits set)
same(decompress({ 0xE4, 0x27, 0x09, 0xFF }),
  (function()
    local out = {}
    for _ = 1, 40 do out[#out + 1] = 0x09 end
    return out
  end)(), "long-form iterate")

-- A string input (not a pre-split byte array) must work the same way as
-- Rom.decompressPic accepts, per the task's "array OR string" contract.
same(decompress(string.char(0x03, 0x01, 0x02, 0x03, 0x04, 0xFF)),
  { 1, 2, 3, 4 }, "string input")

S.finish()

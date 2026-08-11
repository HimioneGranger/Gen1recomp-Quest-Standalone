-- The new-game seed has to fill wVariableSprites, not just the event flags.
--
--   luajit tests/gen2_variable_sprites_test.lua
--
-- Found by the Gold route bot (tests/drivers/gold_bot.lua): it walked to the
-- Sudowoodo on Route 36 with the SQUIRTBOTTLE in the bag, faced (35,9), pressed
-- A and nothing happened -- because there was nothing there.
--
-- SPRITE_WEIRD_TREE is $f4, and everything from $f0 up is a wVariableSprites
-- SLOT rather than a sheet (constants/sprite_constants.asm:147).  An object
-- carrying one is extracted with a NUMBER in `sprite`, World:resolveSprite
-- answers nil until the slot is filled, and World:pooledNpc spawns nothing --
-- which is faithful, because on the cart the slots are filled by
-- InitializeEventsScript, whose last nine commands are `variablesprite`.
--
-- The port's seed replayed that script's `setevent` list and dropped the rest,
-- so a new game had no Sudowoodo -- and therefore no TM08 ROCK SMASH, no
-- Burned Tower, no Morty, no FOGBADGE and no SURF -- plus no Olivine rival, no
-- Azalea Rocket, no Fuchsia Gym Janines, no Copycat and no Janine
-- impersonator.
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 variable sprites")
local check, eq = S.check, S.eq

local World = require("src.world.gen2.World")

-- The recovery path, in isolation: given the seed's flag list and a scripts
-- table containing the script those flags came from, find its variablesprite
-- rows.  This is what lets a cache written before the extractor learned to
-- record them still put the tree on the map.
do
  local w = setmetatable({
    initialEvents = { 10, 20, 30 },
    scripts = {
      -- A decoy with some of the flags and a sprite row: must NOT match.
      ["a:1"] = {
        { op = "setevent", event = 10 },
        { op = "variablesprite", args = { 4, 99 } },
      },
      -- The real one: every seed flag, then the sprite assignments.
      ["b:1"] = {
        { op = "setevent", event = 10 },
        { op = "setevent", event = 20 },
        { op = "setevent", event = 30 },
        { op = "variablesprite", args = { 4, 55 } },   -- SPRITE_WEIRD_TREE
        { op = "variablesprite", args = { 5, 56 } },
        { op = "end" },
      },
    },
  }, { __index = World })

  local rows = w:findInitialSprites()
  eq(#rows, 2, "found both variablesprite rows")
  local bySlot = {}
  for _, row in ipairs(rows) do bySlot[row.slot] = row.sprite end
  eq(bySlot[4], 55, "slot 4 ($f4 SPRITE_WEIRD_TREE) takes its sprite")
  eq(bySlot[5], 56, "slot 5 too")
  check(bySlot[4] ~= 99, "the decoy script, which lacks two of the flags, lost")
end

-- No seed list means no guessing: a cache with no flags must not match some
-- arbitrary script that happens to contain a variablesprite.
do
  local w = setmetatable({
    initialEvents = {},
    scripts = { ["a:1"] = { { op = "variablesprite", args = { 4, 99 } } } },
  }, { __index = World })
  eq(#w:findInitialSprites(), 0, "an empty seed list matches nothing")
end

-- resolveSprite is the half that reads it back, and the reason an unfilled
-- slot is invisible rather than merely wrong.
do
  local w = setmetatable({
    variableSprites = {},
    constants = { spriteOrder = { [55] = "SPRITE_SUDOWOODO" } },
  }, { __index = World })
  eq(w:resolveSprite(0xf4), nil, "an unfilled slot resolves to nothing")
  w.variableSprites[0xf4 - 0xf0] = 55
  eq(w:resolveSprite(0xf4), "SPRITE_SUDOWOODO", "a filled slot names a sheet")
  eq(w:resolveSprite("SPRITE_NURSE"), "SPRITE_NURSE",
     "an ordinary sprite name passes straight through")
end

S.finish()

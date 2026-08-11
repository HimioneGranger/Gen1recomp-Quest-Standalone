-- Does pret's EVENT_* numbering actually match the cart's?
--
--   luajit tests/gold_flag_names_test.lua
--
-- tests/drivers/gold/flag_names.lua lets the Gold bot route assert
-- postconditions by name (EVENT_BEAT_FALKNER rather than 1213).  That is only
-- sound if pret's const_def order in constants/event_flags.asm is the order the
-- retail ROM's scripts use -- and src/import/RomExtractorGen2.lua:3234 says
-- outright that it may not be, which is why extractInitialEvents reads the ids
-- off the cart rather than hardcoding them.
--
-- That warning is exactly what makes this test necessary: the two orderings
-- being equal is a fact about today's pokegold, not a guarantee.  The check
-- replays pret's InitializeEventsScript body name-by-name against the ids the
-- extractor pulled from the ROM for the same script.  They cover ids from 37 to
-- 1915 across every const_next region, so agreement across all of them is
-- strong evidence for the whole table, not just its head.
--
-- If pret renumbers, this goes red and the fix is to regenerate:
--   luajit tools/goldwalk/gen_flags.lua
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gold flag names")
local check, eq = S.check, S.eq

local names = dofile("tests/drivers/gold/flag_names.lua")

check(names.events.EVENT_BEAT_FALKNER ~= nil, "EVENT_* table is populated")
check(names.engine.ENGINE_ZEPHYRBADGE ~= nil, "ENGINE_* table is populated")

-- The eight Johto badges are consecutive bits of wJohtoBadges.  Note the order
-- is the BITFIELD's, not the order a player earns them: MINERALBADGE (Jasmine)
-- sits at bit 4 and STORMBADGE (Chuck) at bit 5, while the walkthrough beats
-- Chuck first and Jasmine second (asm-walk sections 08 then 09).  A route that
-- assumed "5th gym beaten == bit 5" would gate Surf and Fly on the wrong bit,
-- so pin the layout rather than just the presence.
local badges = {
  "ENGINE_ZEPHYRBADGE", "ENGINE_HIVEBADGE", "ENGINE_PLAINBADGE",
  "ENGINE_FOGBADGE", "ENGINE_MINERALBADGE", "ENGINE_STORMBADGE",
  "ENGINE_GLACIERBADGE", "ENGINE_RISINGBADGE",
}
for i = 2, #badges do
  eq(names.engine[badges[i]], names.engine[badges[i - 1]] + 1,
     badges[i] .. " follows " .. badges[i - 1])
end

-- ---------------------------------------------------------------------------
-- The cart cross-check
-- ---------------------------------------------------------------------------
-- Needs both a Gold cache (for the ROM-derived ids) and a pokegold checkout
-- (for the names).  Either missing degrades to the fixture checks above rather
-- than failing, the same way tests/gen2_map_callbacks_test.lua handles it.

local cache = os.getenv("GOLD_CACHE")
if not cache then
  cache = (os.getenv("HOME") or "") .. "/Library/Application Support/LOVE/gold-dev/gold"
end
local POKEGOLD = os.getenv("POKEGOLD") or "../pokegold"

local initialPath = cache .. "/data/generated/initial_events.lua"
local stdScripts  = POKEGOLD .. "/engine/events/std_scripts.asm"

local function readable(path)
  local fh = io.open(path, "r")
  if not fh then return false end
  fh:close()
  return true
end

if not readable(initialPath) then
  check(true, "gold cache absent : name table checked, cart cross-check SKIPPED")
  S.finish()
  return
end
if not readable(stdScripts) then
  check(true, "pokegold absent : name table checked, cart cross-check SKIPPED")
  S.finish()
  return
end

local Flags = dofile("tools/goldwalk/flags.lua")
local romIds = assert(loadfile(initialPath))().flags
local pretNames = Flags.setEventsOf(stdScripts, "InitializeEventsScript")

eq(#pretNames, #romIds,
   "InitializeEventsScript sets the same number of flags in pret and the cart")

local mismatches, span = {}, { lo = math.huge, hi = -math.huge }
for i, name in ipairs(pretNames) do
  local want, got = names.events[name], romIds[i]
  if got then
    span.lo, span.hi = math.min(span.lo, got), math.max(span.hi, got)
  end
  if want ~= got then
    mismatches[#mismatches + 1] =
      ("#%d %s pret=%s cart=%s"):format(i, name, tostring(want), tostring(got))
  end
end

if #mismatches > 0 then
  -- Print the first few: the whole list is one-per-flag noise, and the head is
  -- enough to see whether it is a wholesale shift or a single retired const.
  for i = 1, math.min(5, #mismatches) do print("  " .. mismatches[i]) end
end
eq(#mismatches, 0,
   ("pret numbering == cart numbering across ids %d..%d")
     :format(span.lo, span.hi))

S.finish()

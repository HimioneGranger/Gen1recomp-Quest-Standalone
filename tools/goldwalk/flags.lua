-- const_def parser for the pokegold constant files.
--
-- The Gold bot's route (tests/drivers/gold/route.lua) asserts postconditions by
-- EVENT_* / ENGINE_* name, but nothing in the extracted cache carries those
-- names: the port stores flags as the bare numeric ids the cart's scripts use
-- (src/world/gen2/Events.lua keys a bitfield by id, and Vm passes `setflag`
-- operands straight through).  This turns pret's `const_def` blocks back into
-- name -> id so a route row can say EVENT_BEAT_FALKNER and mean something.
--
-- Whether that mapping is LEGITIMATE is a real question and not an assumption:
-- src/import/RomExtractorGen2.lua:3234 warns that "Retail Gold's numeric EVENT_*
-- values differ from pret's current const_def order", which is why
-- extractInitialEvents reads the ids off the cart instead of hardcoding them.
-- tests/gold_flag_names_test.lua settles it empirically every run, by replaying
-- pret's InitializeEventsScript against the ids the extractor pulled from the
-- ROM.  As of this writing all 108 agree, spanning ids 37..1915, so the
-- orderings are the same file -- but the test is what keeps that true, and a
-- future pret renumber turns into a red test rather than a bot that walks into
-- Sprout Tower checking the wrong bit.
--
--   local Flags = dofile("tools/goldwalk/flags.lua")
--   local byName, byId = Flags.parse("../pokegold/constants/event_flags.asm")

local Flags = {}

-- rgbds const_def semantics, only the four directives these two files use:
--   const_def [N]   start numbering at N (0 when omitted)
--   const NAME      assign the current number, then advance
--   const_skip [N]  advance N (default 1) without naming -- a retired flag,
--                   and skipping it wrongly would shift every later id by one
--   const_next N    jump the counter to N outright (the files use this to
--                   start each WRAM region on a round number)
function Flags.parse(path)
  local fh = assert(io.open(path, "r"), "cannot open " .. path)
  local byName, byId, n = {}, {}, 0
  for raw in fh:lines() do
    -- Strip trailing comments first, so `const_skip ; unused` reads as a bare
    -- skip and not as skip-nothing.
    local line = raw:gsub(";.*", "")
    if line:match("const_def") then
      n = tonumber(line:match("const_def%s+(%d+)")) or 0
    elseif line:match("const_skip") then
      n = n + (tonumber(line:match("const_skip%s+(%d+)")) or 1)
    elseif line:match("const_next") then
      n = tonumber(line:match("const_next%s+(%d+)")) or n
    else
      local name = line:match("^%s*const%s+([%w_]+)")
      if name then
        byName[name] = n
        byId[n] = name
        n = n + 1
      end
    end
  end
  fh:close()
  return byName, byId
end

-- The setevent list of one label in an .asm file, in source order.  Used only
-- by the verification test, which needs pret's InitializeEventsScript body to
-- line up against the ids the extractor read out of the cart.
function Flags.setEventsOf(path, label)
  local fh = assert(io.open(path, "r"), "cannot open " .. path)
  local names, inside = {}, false
  for line in fh:lines() do
    if line:match("^" .. label .. ":") then
      inside = true
    elseif inside then
      local ev = line:match("^%s*setevent%s+([%w_]+)")
      if ev then
        names[#names + 1] = ev
      elseif line:match("^%s*end") or line:match("^[%a_][%w_]*:") then
        break                              -- next label: the body is over
      end
    end
  end
  fh:close()
  return names
end

return Flags

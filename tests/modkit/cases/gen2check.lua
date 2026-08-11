-- T4: `modkit gen2check`, the tool that answers whether a mod runs on a Gen 2
-- game and how far it gets (tools/modkit.py, MK4xx).
--
-- Every fixture below is generated FROM the engine: the module with no
-- adapter, the member the coverage table calls absent and the screen id with
-- a Gen 2 twin are all read out of src/mods/Gen2Compat.lua and
-- src/ui/Screens.lua at run time.  A case that spelled them out would pass
-- against a stale adapter, which is the one thing this tool must never do.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")

local isWindows = package.config:sub(1, 1) == "\\"

-- luajit's pclose drops the exit status, so the shell reports it in-band
-- (tests/modkit_tests.lua uses the same shape)
local function run(command)
  if isWindows then
    command = 'cmd /v:on /c "' .. command .. ' 2>&1 & echo EXIT:!errorlevel!"'
  else
    command = command .. ' 2>&1; echo "EXIT:$?"'
  end
  local pipe = io.popen(command)
  local output = pipe:read("*a")
  pipe:close()
  return output, tonumber(output:match("EXIT:(%d+)%s*$")) or -1
end

local python = isWindows and "python" or "python3"
if not run(python .. " --version"):find("Python 3", 1, true) then
  T.check(true, "python3 is absent: gen2check not exercised")
  T.finish("gen2check")
  return
end

-- ------- what to write the fixtures against, taken from the engine

local Gen2Compat = require("src.mods.Gen2Compat")
local Screens = require("src.ui.Screens")

local names = {}
for name in pairs(Gen2Compat.ADAPTERS) do names[#names + 1] = name end
table.sort(names)

-- written onto the running game and never onto the module table, which is
-- what MK410 is about; read from the Gen 1 source, as the tool does
local function instanceField(module, member)
  local handle = io.open(module:gsub("%.", "/") .. ".lua", "r")
  if not handle then return false end
  local body = handle:read("*a")
  handle:close()
  if not body:find("self%." .. member .. "%s*=[^=]") then return false end
  if body:find("function%s+%w+[%.:]" .. member .. "%s*%(") then return false end
  for owner in body:gmatch("[\n%s]([%a_][%w_]*)%." .. member .. "%s*=[^=]") do
    if owner ~= "self" then return false end
  end
  return true
end

-- an adapted alias plus a member it backs: the shape a mod may hold and read
local aliasName, backedMember
-- a member the adapter deliberately does not carry, whatever module it is on
local absentName, absentMember
-- a facade member the Gen 1 module only writes onto the running game, which
-- an entry chunk cannot have on a Gen 2 boot
local liveName, liveMember
for _, name in ipairs(names) do
  local row = Gen2Compat.coverage and Gen2Compat.coverage(name)
  local members = row and row.members or {}
  local sorted = {}
  for member in pairs(members) do sorted[#sorted + 1] = member end
  table.sort(sorted)
  for _, member in ipairs(sorted) do
    if not member:find("[%.%s]") then
      if members[member] == "absent" and not absentMember then
        absentName, absentMember = name, member
      end
      if members[member] == "backed" and row.kind == "alias"
          and not backedMember then
        aliasName, backedMember = name, member
      end
      if members[member] == "backed" and row.kind == "facade"
          and not liveMember and instanceField(name, member) then
        liveName, liveMember = name, member
      end
    end
  end
end
T.check(aliasName ~= nil, "the adapter aliases at least one module")
T.check(absentMember ~= nil, "the coverage table names at least one absent "
  .. "member")

-- A member that really closes over a local, and a local declared in the same
-- Gen 2 file that it does NOT close over: the two answers the upvalue check
-- has to tell apart, both read out of the engine.
local landName, landMember, landUpvalue
local strayUpvalue
for _, name in ipairs(names) do
  local row = Gen2Compat.coverage and Gen2Compat.coverage(name)
  if row and row.kind == "alias" and row.target and not landMember then
    local ok, adapter = pcall(Gen2Compat.resolve, name)
    local sorted = {}
    if ok and type(adapter) == "table" then
      for member in pairs(adapter) do sorted[#sorted + 1] = member end
    end
    table.sort(sorted)
    for _, member in ipairs(sorted) do
      local value = adapter[member]
      if type(value) == "function" and not landMember then
        local held, index = {}, 1
        while true do
          local up = debug.getupvalue(value, index)
          if not up then break end
          held[up] = true
          if up:match("^%a[%w_]*$") and up ~= "_ENV" and not landUpvalue then
            landName, landMember, landUpvalue = name, member, up
          end
          index = index + 1
        end
        if landUpvalue then
          local handle = io.open(row.target:gsub("%.", "/") .. ".lua", "r")
          local body = handle and handle:read("*a") or ""
          if handle then handle:close() end
          for local_ in body:gmatch("\nlocal%s+([%a_][%w_]*)") do
            if not held[local_] and not strayUpvalue then
              strayUpvalue = local_
            end
          end
        end
      end
    end
  end
end

-- a Gen 1 screen id whose Gen 2 twin carries the prefix
local twin
for _, id in ipairs(Screens.GEN2_IDS) do
  local bare = id:gsub("^Gen2", "")
  local handle = io.open("src/ui/" .. bare .. ".lua", "r")
  if handle then handle:close() end
  if not twin and handle then twin = bare end
end
T.check(twin ~= nil, "at least one screen id exists in both generations")

-- ------- fixtures on disk, because the tool reads a mod directory

local tmp = os.tmpname()
os.remove(tmp)
local root = (isWindows and tmp:gsub("\\", "/") or tmp) .. "_gen2check"
run((isWindows and "mkdir " or "mkdir -p ") .. ("%q"):format(root))

local function write(dir, files)
  run((isWindows and "mkdir " or "mkdir -p ")
    .. ("%q"):format(root .. "/" .. dir))
  for name, body in pairs(files) do
    local handle = assert(io.open(root .. "/" .. dir .. "/" .. name, "w"))
    handle:write(body)
    handle:close()
  end
  return root .. "/" .. dir
end

local function manifest(id, extra)
  return ('{ "id": "%s", "name": "%s", "version": "1.0.0", "api": 2, '
    .. '"entry": "main.lua", "description": "gen2check fixture"%s }')
    :format(id, id, extra or "")
end

local GEN2 = ', "gen2compat": true, "games": ["gen1", "gen2"]'

local clean = write("gen2_clean", {
  ["manifest.json"] = manifest("gen2_clean", GEN2),
  ["main.lua"] = ([[
local mod = ...
local M = require("%s")
local held = M.%s
mod.exports.held = held ~= nil
]]):format(aliasName, backedMember),
})

local unflagged = write("gen2_unflagged", {
  ["manifest.json"] = manifest("gen2_unflagged"),
  ["main.lua"] = "local mod = ...\n",
})

local absent = write("gen2_absent", {
  ["manifest.json"] = manifest("gen2_absent", GEN2),
  ["main.lua"] = ([[
local mod = ...
local M = require("%s")
M.%s(mod)
]]):format(absentName, absentMember),
})

local patterns = write("gen2_patterns", {
  ["manifest.json"] = manifest("gen2_patterns", GEN2),
  ["main.lua"] = ([[
local mod = ...
local M = require("%s")
local function patchUpvalue(fn, name, value)
  local i = 1
  while true do
    local found = debug.getupvalue(fn, i)
    if not found then return false end
    if found == name then debug.setupvalue(fn, i, value) return true end
    i = i + 1
  end
end
patchUpvalue(M.%s, "gen2checkNoSuchUpvalue", 1)
mod.events:on("screen.pushed", function(ev)
  if ev.screenId == "%s" then mod.exports.saw = true end
end)
]]):format(aliasName, backedMember, twin),
})

local held = liveMember and write("gen2_held", {
  ["manifest.json"] = manifest("gen2_held", GEN2),
  ["main.lua"] = ([[
local mod = ...
local G = require("%s")
local captured = G.%s
mod.events:on("game.ready", function()
  mod.exports.live = G.%s ~= nil
end)
mod.exports.captured = captured ~= nil
]]):format(liveName, liveMember, liveMember),
})

-- every shape the scan has to follow to reach one unbacked member: a wrapper
-- the mod requires through, an inline require, a bracket index and a local hop
local reaches = write("gen2_reaches", {
  ["manifest.json"] = manifest("gen2_reaches", GEN2),
  ["main.lua"] = ([[
local mod = ...
local function tryRequire(path)
  local ok, m = pcall(require, path)
  if ok then return m end
end
local W = tryRequire("%s")
W.%s(mod)
require("%s").%s(mod)
local B = require("%s")
B["%s"](mod)
local H = B
H.%s(mod)
]]):format(absentName, absentMember, absentName, absentMember,
           absentName, absentMember, absentMember),
})

-- a module name this scan cannot tie to a require: it must say so, never
-- pass the file in silence
local opaque = write("gen2_opaque", {
  ["manifest.json"] = manifest("gen2_opaque", GEN2),
  ["main.lua"] = ([[
local mod = ...
local CANDIDATES = { "%s" }
mod.exports.names = CANDIDATES
]]):format(absentName),
})

-- an upvalue that is really an upvalue of the resolved function, and one that
-- is only a file-local of the same module
local lands = landUpvalue and write("gen2_lands", {
  ["manifest.json"] = manifest("gen2_lands", GEN2),
  ["main.lua"] = ([[
local mod = ...
local M = require("%s")
debug.setupvalue(M.%s, "%s", nil)
]]):format(landName, landMember, landUpvalue),
})

local stray = strayUpvalue and write("gen2_stray", {
  ["manifest.json"] = manifest("gen2_stray", GEN2),
  ["main.lua"] = ([[
local mod = ...
local M = require("%s")
debug.setupvalue(M.%s, "%s", nil)
]]):format(landName, landMember, strayUpvalue),
})

-- the screen id on a line carrying no screen-shaped word, which is the
-- example the docs give
local screenId = write("gen2_screen_id", {
  ["manifest.json"] = manifest("gen2_screen_id", GEN2),
  ["main.lua"] = ([[
local mod = ...
mod.exports.pick = function(id)
  if id == "%s" then return true end
end
]]):format(twin),
})

-- one statement binding two requires: each name takes the value in its own
-- slot, or neither does.  Both names reach the same unbacked member, so a
-- scan that paired them by position reports two and one that guessed reports
-- one against a name it invented.
local pairs_one = write("gen2_pairs_one", {
  ["manifest.json"] = manifest("gen2_pairs_one", GEN2),
  ["main.lua"] = ([[
local mod = ...
local A, B = require("%s"), require("%s")
A.%s(mod)
B.%s(mod)
]]):format(absentName, absentName, absentMember, absentMember),
})

-- the same mod with the requires on their own lines: two mods that differ
-- only in line breaks must not get opposite verdicts
local pairs_lines = write("gen2_pairs_lines", {
  ["manifest.json"] = manifest("gen2_pairs_lines", GEN2),
  ["main.lua"] = ([[
local mod = ...
local A = require("%s")
local B = require("%s")
A.%s(mod)
B.%s(mod)
]]):format(absentName, absentName, absentMember, absentMember),
})

-- a mod helper that only ever puts its second parameter in the VALUE slot:
-- it names no upvalue, so its call sites are unresolved, never MK407
local valueSlot = write("gen2_value_slot", {
  ["manifest.json"] = manifest("gen2_value_slot", GEN2),
  ["main.lua"] = ([[
local mod = ...
local M = require("%s")
local function applyPatches(fn, label)
  debug.setupvalue(fn, 1, label)
end
applyPatches(M.%s, "gen2checkNotAnUpvalue")
]]):format(aliasName, backedMember),
})

-- a module name assembled from two literals: the fragment binds to no engine
-- module, and every reach off it has to say so
local head, tail = absentName:match("^(.*%.)([^.]+)$")
local truncated = head and write("gen2_truncated", {
  ["manifest.json"] = manifest("gen2_truncated", GEN2),
  ["main.lua"] = ([[
local mod = ...
local M = require("%s" .. "%s")
M.%s(mod)
]]):format(head, tail, absentMember),
})

-- the same concatenation starting with a literal, which a lookahead on the
-- first token alone lets through
local root_, rest = absentName:match("^(src)(%..*)$")
local concat = root_ and write("gen2_concat", {
  ["manifest.json"] = manifest("gen2_concat", GEN2),
  ["main.lua"] = ([[
local mod = ...
local M = require("%s" .. "%s")
M.%s(mod)
]]):format(root_, rest, absentMember),
})

-- a bound module read as a value: parked on a table, delegated to through a
-- metatable, handed to a call.  The module escapes the scan at each one.
local valueRead = write("gen2_value_read", {
  ["manifest.json"] = manifest("gen2_value_read", GEN2),
  ["main.lua"] = ([[
local mod = ...
local M = require("%s")
local proxy = setmetatable({}, { __index = M })
mod.exports.proxy = proxy
mod.exports.parked = M
]]):format(absentName),
})

-- rawget/rawset skip the facade's metatable, so mod state stashed this way
-- lands on the adapter table and not on the Gen 2 module behind it
local rawReach = write("gen2_raw_reach", {
  ["manifest.json"] = manifest("gen2_raw_reach", GEN2),
  ["main.lua"] = ([[
local mod = ...
local M = require("%s")
rawset(M, "gen2checkState", {})
mod.exports.state = rawget(M, "gen2checkState")
]]):format(aliasName),
})

local function gen2check(dir, extra)
  return run(("%s tools/modkit.py gen2check %q %s")
    :format(python, dir, extra or ""))
end

-- ------- a mod that only reads what the adapter backs

local out, code = gen2check(clean)
T.eq(code, 0, "a mod inside the adapter's coverage exits 0: " .. out)
T.check(out:find("will load", 1, true) ~= nil,
  "the clean fixture's verdict is 'will load': " .. out)

-- ------- the manifest gate, which decides before a line of the mod runs

out, code = gen2check(unflagged)
T.eq(code, 1, "a mod claiming no Gen 2 game fails the check")
T.check(out:find("MK400", 1, true) ~= nil, "MK400 names the manifest: " .. out)
T.check(out:find("will not work", 1, true) ~= nil,
  "and the verdict says so: " .. out)

-- ------- a member the adapter refuses to invent

out, code = gen2check(absent)
T.eq(code, 1, "calling an unbacked member fails the check")
T.check(out:find("MK404", 1, true) ~= nil, "MK404 names the member: " .. out)
T.check(out:find(absentMember, 1, true) ~= nil,
  "and quotes it by name: " .. out)

-- ------- the two shapes no adapter can fix

out, code = gen2check(patterns)
T.eq(code, 1, "upvalue surgery with no target on Gold fails the check")
T.check(out:find("MK407", 1, true) ~= nil,
  "MK407 names the upvalue that does not exist: " .. out)
T.check(out:find("MK409", 1, true) ~= nil,
  "MK409 names the Gen 1 screen id: " .. out)
T.check(out:find("Gen2" .. twin, 1, true) ~= nil,
  "and gives the Gen 2 spelling of it: " .. out)

-- ------- the entry chunk holding a member of a game that is not up yet

if held then
  out = gen2check(held)
  T.check(out:find("MK410", 1, true) ~= nil,
    "MK410 names the file-scope read: " .. out)
  T.check(select(2, out:gsub("MK410", "")) == 1,
    "and only the file-scope one, not the read inside the handler: " .. out)
end

-- ------- the reaches a scan that only saw `X = require(...)` used to miss

out, code = gen2check(reaches)
T.eq(code, 1, "an unbacked member reached through a wrapper fails: " .. out)
T.eq(select(2, out:gsub("MK404", "")), 4,
  "the wrapper, the inline require, the bracket index and the local hop each "
  .. "come back: " .. out)

-- ------- and what it still cannot follow says so out loud

out = gen2check(opaque)
T.check(out:find("unresolved", 1, true) ~= nil,
  "a module name the scan cannot tie to a require is reported unresolved, "
  .. "not passed over: " .. out)

-- ------- upvalue surgery, told apart by what the function really closes over

if lands then
  out, code = gen2check(lands)
  T.check(out:find("lands as it does on Gen 1", 1, true) ~= nil,
    "a real upvalue of the resolved function is reported as landing: " .. out)
  T.check(out:find("MK407", 1, true) == nil,
    "and raises nothing: " .. out)
end

if stray then
  out, code = gen2check(stray)
  T.check(out:find("MK407", 1, true) ~= nil,
    "a file-local that is not an upvalue of the function is MK407: " .. out)
  T.check(out:find("lands as it does on Gen 1", 1, true) == nil,
    "and is never reported as landing: " .. out)
end

-- ------- the screen id with no screen-shaped word beside it

out = gen2check(screenId)
T.check(out:find("MK409", 1, true) ~= nil,
  "MK409 reads the id itself, not the line around it: " .. out)
T.check(out:find("Gen2" .. twin, 1, true) ~= nil,
  "and gives the Gen 2 spelling: " .. out)

-- ------- names and values of one assignment, paired by position

out, code = gen2check(pairs_one)
T.eq(code, 1, "two names bound to two requires in one statement fail: " .. out)
T.eq(select(2, out:gsub("MK404", "")), 2,
  "each name carries its own require's module, so both reaches come back: "
  .. out)
local lines, code2 = gen2check(pairs_lines)
T.eq(code2, code, "the same mod with the requires on separate lines gets the "
  .. "same exit: " .. out .. lines)
T.eq(select(2, lines:gsub("MK404", "")), 2,
  "and the same findings, since only the line breaks moved: " .. lines)

-- ------- a helper whose second parameter is a value, not an upvalue name

out, code = gen2check(valueSlot)
T.check(out:find("MK407", 1, true) == nil,
  "a helper that names no upvalue is never read as upvalue surgery: " .. out)
T.check(out:find("unresolved", 1, true) ~= nil,
  "and its call sites come back unresolved rather than silent: " .. out)

-- ------- a module name this scan resolved but cannot map to a module

if truncated then
  out, code = gen2check(truncated)
  T.check(out:find("neither an adapter nor a module", 1, true) ~= nil,
    "a require built from two literals cannot pass in silence: " .. out)
end

if concat then
  out, code = gen2check(concat)
  T.check(out:find("building a require name at runtime", 1, true) ~= nil,
    "a concatenation starting with a literal is still dynamic: " .. out)
end

-- ------- a bound module read as a value rather than indexed

out, code = gen2check(valueRead)
T.check(out:find("read as a value", 1, true) ~= nil,
  "a module parked on a table or delegated to is reported unresolved: " .. out)

-- ------- rawget/rawset, which never see the module behind the facade

out, code = gen2check(rawReach)
T.check(out:find("rawset", 1, true) ~= nil,
  "rawset onto an engine module earns its own note: " .. out)
T.check(out:find("rawget", 1, true) ~= nil,
  "and so does rawget off one: " .. out)

-- ------- the machine-readable form one CI step reads

out, code = run(("%s tools/modkit.py --json gen2check %q %q")
  :format(python, clean, unflagged))
T.eq(code, 1, "the batch fails when any mod in it fails")
T.check(out:find('"verdict": "will load"', 1, true) ~= nil,
  "the JSON carries a verdict per mod: " .. out)
T.check(out:find('"ok": false', 1, true) ~= nil,
  "and one ok for the batch: " .. out)

-- ------- every adapted name is served, so requiring one is never MK402

local requires = { "local mod = ..." }
for _, name in ipairs(names) do
  requires[#requires + 1] = ("require(%q)"):format(name)
end
local served = write("gen2_served", {
  ["manifest.json"] = manifest("gen2_served", GEN2),
  ["main.lua"] = table.concat(requires, "\n") .. "\n",
})
out = gen2check(served)
T.check(out:find("MK402", 1, true) == nil,
  "no adapted module is reported as unserved: " .. out)

run((isWindows and "rmdir /s /q " or "rm -rf ") .. ("%q"):format(root))

T.finish("gen2check")

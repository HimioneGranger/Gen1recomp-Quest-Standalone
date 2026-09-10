-- Source file LuaJIT limits gate.
-- Verifies that every game engine source file compiles cleanly under
-- LuaJIT without exceeding LuaJIT's strict 200 local variables per-scope limit,
-- 60 upvalue limit, or bytecode compiler limits.
--   luajit tests/engine/luajit_source_limits_test.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local check, eq = T.check, T.eq

-- Find all .lua files in a directory recursively.
local function findLuaFiles(dir, out)
  out = out or {}
  local p = io.popen("find " .. dir .. " -type f -name '*.lua'")
  if p then
    for line in p:lines() do
      out[#out + 1] = line
    end
    p:close()
  end
  table.sort(out)
  return out
end

local files = findLuaFiles("src")
findLuaFiles("tools/save-editor", files)
files[#files + 1] = "main.lua"
files[#files + 1] = "conf.lua"

check(#files > 50, "discovered project source files (found " .. tostring(#files) .. ")")

for _, path in ipairs(files) do
  local f = assert(io.open(path, "rb"), "could not open " .. path)
  local source = f:read("*a")
  f:close()

  -- Compile through LuaJIT loadstring: detects 'main function has more than 200 local variables'
  -- or 'function has more than 200 local variables' across any function scope in the file.
  local chunk, err = loadstring(source, "@" .. path)
  check(chunk ~= nil, path .. " compiles under LuaJIT: " .. tostring(err))
end

-- Meta-test: prove that exceeding 200 locals fails the gate
do
  local overflowLocals = {}
  for i = 1, 201 do overflowLocals[i] = "v" .. i end
  local badCode = "local " .. table.concat(overflowLocals, ", ")
  local chunk, err = loadstring(badCode, "@overflow_test.lua")
  check(chunk == nil, "LuaJIT strictly rejects chunks exceeding 200 locals")
  check(tostring(err):find("200 local variables", 1, true) ~= nil, "error message specifies 200 local variable limit")
end

T.finish("luajit_source_limits")

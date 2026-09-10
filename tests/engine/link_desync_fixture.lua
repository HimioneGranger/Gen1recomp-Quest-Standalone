-- ROM-free entry point for deterministic lockstep and mutation fuzzing.
--   luajit tests/engine/link_desync_fixture.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

love = require("tests.love_stub")

local Data = require("src.core.Data")
local fixture = require("tests.fixture_data").load()
for key, value in pairs(fixture) do Data[key] = value end

arg = { "20", "1", "5" }
assert(dofile("tests/link_desync_fuzz.lua"))

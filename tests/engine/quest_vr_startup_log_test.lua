-- Optional Quest diagnostics must never disable the VR render pipeline after
-- a successful launcher-to-gameplay OpenXR handoff.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")

local handle = assert(io.open("src/quest/dramaless/VR.lua", "rb"))
local source = handle:read("*a")
handle:close()

T.check(loadstring(source) ~= nil, "Quest VR conductor compiles")

local start = assert(source:find("if VRXR.start(qw, qh) then", 1, true))
local finish = assert(source:find("else", start, true))
local startup = source:sub(start, finish - 1)

T.check(startup:find('local log = rawget(_G, "QUEST_XR_LOG")', 1, true) ~= nil,
  "startup obtains the optional Quest log sink locally")
T.check(startup:find("if log then", 1, true) ~= nil,
  "startup guards the optional Quest log sink")
T.check(startup:find("VRSTREAM policy", 1, true) ~= nil,
  "the guarded startup diagnostic remains available")

T.finish("Quest VR startup log guard")

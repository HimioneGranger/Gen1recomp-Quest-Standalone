-- Optional native-host display lifecycle. The default path is inert; a fake
-- backend proves callback order and arguments without graphics or a ROM.
--   luajit tests/engine/host_display_test.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local check, eq = T.check, T.eq
local HostDisplay = require("src.core.HostDisplay")

-- Vanilla: no backend, no state requirement, and no invented return value.
HostDisplay.setBackend(nil)
eq(HostDisplay.update(1 / 60), nil, "default update is a no-op")
eq(HostDisplay.beginFrame("game", {}), nil, "default beginFrame is a no-op")
eq(HostDisplay.endFrame("game", {}), nil, "default endFrame is a no-op")

-- Bad installation fails at the boundary instead of producing a later frame
-- error whose source is difficult for a native host to diagnose.
local ok, err = pcall(HostDisplay.setBackend, function() end)
check(not ok, "non-table backend is rejected")
check(tostring(err):find("table or nil", 1, true) ~= nil,
  "backend type error explains the accepted shape")

local calls = {}
local subject = { tag = "launcher-instance" }
local fake = {}
function fake:update(dt)
  calls[#calls + 1] = { "update", self, dt }
  return "updated"
end
function fake:beginFrame(kind, gotSubject)
  calls[#calls + 1] = { "begin", self, kind, gotSubject }
  return "begun"
end
function fake:endFrame(kind, gotSubject)
  calls[#calls + 1] = { "end", self, kind, gotSubject }
  return "ended"
end

HostDisplay.setBackend(fake)
eq(HostDisplay.update(0.25), "updated", "update return is forwarded")
eq(HostDisplay.beginFrame("launcher", subject), "begun",
  "beginFrame return is forwarded")
eq(HostDisplay.endFrame("launcher", subject), "ended",
  "endFrame return is forwarded")
eq(#calls, 3, "each lifecycle callback fires exactly once")
eq(calls[1][1], "update", "update is first")
eq(calls[1][2], fake, "update receives the backend as self")
eq(calls[1][3], 0.25, "update receives dt")
eq(calls[2][1], "begin", "beginFrame precedes endFrame")
eq(calls[2][3], "launcher", "beginFrame receives the frame kind")
eq(calls[2][4], subject, "beginFrame receives the drawn subject")
eq(calls[3][1], "end", "endFrame is last")
eq(calls[3][3], "launcher", "endFrame receives the frame kind")
eq(calls[3][4], subject, "endFrame receives the drawn subject")

-- Every callback is optional. Replacing and clearing a backend must not retain
-- callbacks from the old host across a restart or test process.
local partialCalls = 0
HostDisplay.setBackend({
  endFrame = function() partialCalls = partialCalls + 1 end,
})
eq(HostDisplay.update(1), nil, "missing optional update remains a no-op")
eq(HostDisplay.beginFrame("editor", {}), nil,
  "missing optional beginFrame remains a no-op")
HostDisplay.endFrame("editor", {})
eq(partialCalls, 1, "present optional callback still runs")

HostDisplay.setBackend(nil)
HostDisplay.endFrame("game", {})
eq(partialCalls, 1, "clearing backend detaches old callbacks")

T.finish("host display")

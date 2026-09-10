-- ROM-free contract for the versioned host lifecycle boundary.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local check, eq = T.check, T.eq
local HostLifecycle = require("src.core.HostLifecycle")

eq(HostLifecycle.API_VERSION, 1, "lifecycle API is versioned")
check(not pcall(HostLifecycle.setBackend, {}),
  "missing lifecycle version is rejected")
check(not pcall(HostLifecycle.setBackend, { apiVersion = 7 }),
  "unknown lifecycle version is rejected")

local calls = {}
local backend = { apiVersion = 1 }
function backend:focus(value) calls[#calls + 1] = { "focus", value } end
function backend:visible(value) calls[#calls + 1] = { "visible", value } end
function backend:handoff(target, context)
  calls[#calls + 1] = { "handoff", target, context }
end
function backend:mustExit() return self.terminal == true end
function backend:shutdown() calls[#calls + 1] = { "shutdown" } end

local context = { reason = "return" }
HostLifecycle.setBackend(backend)
HostLifecycle.focus(false)
HostLifecycle.focus(true)
HostLifecycle.visible(false)
HostLifecycle.visible(true)
HostLifecycle.handoff("launcher", context)
check(not HostLifecycle.mustExit(), "host exit is false until requested")
backend.terminal = true
check(HostLifecycle.mustExit(), "terminal host exit is forwarded")
HostLifecycle.shutdown()
eq(#calls, 6, "each lifecycle edge is delivered once")
eq(calls[1][2], false, "focus loss is preserved")
eq(calls[2][2], true, "focus gain is preserved")
eq(calls[3][2], false, "visibility loss is preserved")
eq(calls[4][2], true, "visibility gain is preserved")
eq(calls[5][1], "handoff", "handoff is delivered")
eq(calls[5][2], "launcher", "handoff target is preserved")
eq(calls[5][3], context, "handoff context identity is preserved")
eq(calls[6][1], "shutdown", "shutdown is delivered")

HostLifecycle.setBackend(nil)
eq(HostLifecycle.focus(true), nil, "default lifecycle is inert")
eq(HostLifecycle.visible(true), nil, "default visibility is inert")
eq(HostLifecycle.handoff("launcher"), nil, "default handoff is inert")
eq(HostLifecycle.mustExit(), false, "default host exit is false")
eq(HostLifecycle.shutdown(), nil, "default shutdown is inert")

T.finish("host lifecycle")

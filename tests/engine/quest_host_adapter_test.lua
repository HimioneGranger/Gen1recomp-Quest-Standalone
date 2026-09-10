-- ROM-free Quest binding contract. Provider stubs prevent native or FFI loads.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local check, eq = T.check, T.eq
local HostDisplay = require("src.core.HostDisplay")

local providerName = "src.host.android.QuestOpenXRDisplay"
local adapterName = "src.quest.compat.HostAdapterV1"
local savedProvider = package.loaded[providerName]
local savedAdapter = package.loaded[adapterName]

local function loadWith(provider)
  HostDisplay.setBackend(nil)
  package.loaded[providerName] = provider
  package.loaded[adapterName] = nil
  return require(adapterName)
end

local updates = 0
local backend = {
  apiVersion = 1,
  update = function(_, dt) updates = updates + dt end,
}
local Adapter = loadWith({ detect = function() return backend end })
eq(Adapter.apiVersion, 1, "Quest adapter uses bootstrap API v1")
eq(Adapter.install(), true, "Quest adapter installs an available backend")
HostDisplay.update(0.25)
eq(updates, 0.25, "Quest adapter installs the exact detected display backend")

Adapter = loadWith({ detect = function() return nil end })
check(not pcall(Adapter.install), "missing Quest backend fails closed")

Adapter = loadWith({ detect = function() error("detect failed") end })
local detected, detectError = pcall(Adapter.install)
check(not detected and tostring(detectError):find("detect failed", 1, true),
  "Quest detection failure is reported and fails closed")

Adapter = loadWith({ detect = function() return { apiVersion = 2 } end })
check(not pcall(Adapter.install), "unknown display API version fails closed")

Adapter = loadWith({ detect = function() return {} end })
check(not pcall(Adapter.install), "missing display API version fails closed")

HostDisplay.setBackend(nil)
package.loaded[providerName] = savedProvider
package.loaded[adapterName] = savedAdapter

T.finish("Quest host adapter")

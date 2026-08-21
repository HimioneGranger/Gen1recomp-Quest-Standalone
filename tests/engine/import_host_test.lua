-- ROM-free contract for the versioned import host boundary.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local check, eq = T.check, T.eq
local ImportHost = require("src.core.ImportHost")

eq(ImportHost.API_VERSION, 1, "import host API is versioned")
check(not pcall(ImportHost.setBackend, {}),
  "missing import host version is rejected")
check(not pcall(ImportHost.setBackend, { apiVersion = 2 }),
  "unknown import host version is rejected")

local calls = {}
local backend = { apiVersion = 1 }
function backend:capabilities()
  return { open = true, result = true, save = true, handoff = true }
end
function backend:requestOpen(kind)
  calls[#calls + 1] = { "open", kind }
  return "truthy"
end
function backend:openKinds() return "rom,mod,sav,required_import,skin" end
function backend:takeOpenResult() return "staged/picked_rom.gb" end
function backend:takeOpenError() return "cancelled" end
function backend:requestSave(name, dir)
  calls[#calls + 1] = { "save", name, dir }
  return true
end
function backend:requestHandoff(target, context)
  calls[#calls + 1] = { "handoff", target, context }
  return true
end

ImportHost.setBackend(backend)
local caps = ImportHost.capabilities()
check(caps.open and caps.result and caps.save and caps.handoff,
  "backend capabilities are normalized and forwarded")
eq(ImportHost.requestOpen("rom"), true, "open result is a literal boolean")
eq(ImportHost.openKinds(), "rom,mod,sav,required_import,skin",
  "kinds are forwarded")
eq(ImportHost.takeOpenResult(), "staged/picked_rom.gb", "result is forwarded")
eq(ImportHost.takeOpenError(), "cancelled", "error is forwarded")
check(ImportHost.requestSave("export.sav", "staging"), "save is forwarded")
local context = { version = "red" }
check(ImportHost.requestHandoff("game", context), "handoff is forwarded")
eq(calls[1][2], "rom", "open kind is preserved")
eq(calls[2][2], "export.sav", "save name is preserved")
eq(calls[3][3], context, "handoff context identity is preserved")

ImportHost.setBackend({
  apiVersion = 1,
  capabilities = function()
    return { open = 1, result = "yes", save = {}, handoff = false }
  end,
})
local invalidCapabilities = ImportHost.capabilities()
check(not invalidCapabilities.open and not invalidCapabilities.result
    and not invalidCapabilities.save and not invalidCapabilities.handoff,
  "truthy non-boolean capabilities fail closed")

ImportHost.setBackend({
  apiVersion = 1,
  capabilities = function() error("capability failure") end,
})
invalidCapabilities = ImportHost.capabilities()
check(not invalidCapabilities.open and not invalidCapabilities.result
    and not invalidCapabilities.save and not invalidCapabilities.handoff,
  "failed capability reports fail closed")

ImportHost.setBackend(nil)
local oldLove = rawget(_G, "love")
_G.love = { system = {} }
check(not ImportHost.capabilities().open, "default without native picker is inert")
check(not ImportHost.requestOpen("rom"), "missing native picker returns false")
eq(ImportHost.takeOpenResult(), nil, "missing result bridge returns nil")
eq(ImportHost.takeOpenError(), nil, "missing error bridge returns nil")

local HostBootstrap = require("src.core.HostBootstrap")
eq(HostBootstrap.API_VERSION, 1, "bootstrap API is versioned")
eq(HostBootstrap.install(), false, "missing discovery is benign")
love.system.getHostModule = function() return "bad/module" end
check(not pcall(HostBootstrap.install), "invalid module name is rejected")
love.system.getHostModule = function() return "tests.missing_host_adapter" end
check(not pcall(HostBootstrap.install), "missing advertised adapter is rejected")
package.preload["tests.invalid_host_adapter"] = function()
  return { apiVersion = 2, install = function() return true end }
end
love.system.getHostModule = function() return "tests.invalid_host_adapter" end
check(not pcall(HostBootstrap.install), "unknown adapter API version is rejected")
package.preload["tests.failed_host_adapter"] = function()
  return { apiVersion = 1, install = function() return false end }
end
love.system.getHostModule = function() return "tests.failed_host_adapter" end
check(not pcall(HostBootstrap.install), "adapter install failure is rejected")
local installed = 0
package.preload["tests.valid_host_adapter"] = function()
  return {
    apiVersion = 1,
    install = function()
      installed = installed + 1
      return true
    end,
  }
end
love.system.getHostModule = function() return "tests.valid_host_adapter" end
check(HostBootstrap.install(), "bootstrap installs a negotiated adapter")
check(HostBootstrap.install(), "bootstrap installation is idempotent")
eq(installed, 1, "bootstrap adapter installs once")

package.preload["tests.invalid_host_adapter"] = nil
package.preload["tests.failed_host_adapter"] = nil
package.preload["tests.valid_host_adapter"] = nil
package.loaded["tests.invalid_host_adapter"] = nil
package.loaded["tests.failed_host_adapter"] = nil
package.loaded["tests.valid_host_adapter"] = nil
_G.love = oldLove
ImportHost.setBackend(nil)

T.finish("import host")

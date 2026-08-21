-- Neutral package bootstrap. A native host may name one Lua adapter module.
-- The portable runtime neither knows nor guesses which host owns that module.
local HostBootstrap = { API_VERSION = 1 }

local installed = false

function HostBootstrap.install()
  if installed then return true end
  local system = rawget(_G, "love") and love.system
  local discover = system and system.getHostModule
  if type(discover) ~= "function" then return false end
  local ok, moduleName = pcall(discover)
  if not ok or type(moduleName) ~= "string" or moduleName == "" then
    return false
  end
  if not moduleName:match("^[%w_%.]+$") then
    error("native host returned an invalid module name", 2)
  end
  local adapter = require(moduleName)
  if type(adapter) ~= "table" or adapter.apiVersion ~= HostBootstrap.API_VERSION
      or type(adapter.install) ~= "function" then
    error("native host module has an unsupported bootstrap API", 2)
  end
  if adapter.install() ~= true then
    error("native host module installation failed", 2)
  end
  installed = true
  return true
end

return HostBootstrap

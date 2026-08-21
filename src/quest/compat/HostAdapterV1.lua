-- Quest flavor binding for the neutral bootstrap API v1. The existing
-- packaged display provider remains the sole owner of Quest detection and its
-- compatibility capability signal.
local Provider = require("src.host.android.QuestOpenXRDisplay")

local Adapter = { apiVersion = 1 }

function Adapter.install()
  local ok, backend = pcall(Provider.detect)
  if not ok then
    error("Quest display detection failed: " .. tostring(backend), 2)
  end
  if type(backend) ~= "table" then
    error("Quest display backend is unavailable", 2)
  end
  require("src.core.HostDisplay").setBackend(backend)
  return true
end

return Adapter

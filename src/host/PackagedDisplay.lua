-- Detect an optional display backend supplied by a packaged native host.
-- Providers must remain inert when their matching native library is absent.
local PackagedDisplay = {}

local providers = {
  "src.host.android.QuestOpenXRDisplay",
}

function PackagedDisplay.detect()
  for _, moduleName in ipairs(providers) do
    local ok, provider = pcall(require, moduleName)
    if ok and type(provider) == "table" and type(provider.detect) == "function" then
      local detected, backend = pcall(provider.detect)
      if detected and backend ~= nil then return backend end
    end
  end
end

return PackagedDisplay

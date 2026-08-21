-- Product-profile gates for settings that are meaningful only on a flat
-- phone or desktop display. The Quest Android flavor sets
-- POKEPORT_QUEST_PROFILE through SDL_ENV manifest metadata before Lua starts.
-- The verified OpenXR bridge signal remains a compatibility fallback, but a
-- missing or delayed panel FFI backend must not turn a Quest build into a
-- generic Android profile. Generic Android remains unchanged.

local PlatformProfile = {}

function PlatformProfile.isQuestStandalone()
  local forced = os.getenv("POKEPORT_QUEST_PROFILE")
  if forced == "1" then return true end
  if forced == "0" then return false end
  return rawget(_G, "QUEST_PANEL_ACTIVE") == true
end

-- These two legacy DRAMALESS option rows control flat render pipelines that
-- are inactive in the Quest compositor.  Match stable keys first and labels as
-- a compatibility fallback.  Filtering never mutates the saved value.
function PlatformProfile.optionRowSupported(row)
  if not PlatformProfile.isQuestStandalone() then return true end
  row = type(row) == "table" and row or {}
  local value = tostring(row.id or row.key or row.label or ""):lower()
  value = value:gsub("[^%w]", "")
  return value ~= "tshift" and value ~= "vcurved"
end

return PlatformProfile

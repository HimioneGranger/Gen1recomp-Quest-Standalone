-- Product-profile gates for settings that are meaningful only on a flat
-- phone or desktop display. The Quest Standalone package identifies itself
-- through its verified OpenXR bridge. Generic Android remains unchanged.

local PlatformProfile = {}

function PlatformProfile.isQuestStandalone()
  local forced = os.getenv("POKEPORT_QUEST_PROFILE")
  if forced == "1" then return true end
  if forced == "0" then return false end
  return rawget(_G, "QUEST_PANEL_ACTIVE") == true
end

return PlatformProfile

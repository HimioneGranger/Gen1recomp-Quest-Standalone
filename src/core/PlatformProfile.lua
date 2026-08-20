-- Product-profile gates for settings that are meaningful only on a flat
-- phone or desktop display. The Quest Standalone package is an immersive
-- Android product, so Android selects this profile unless a developer
-- explicitly disables it for a non-Quest Android test run.

local PlatformProfile = {}

function PlatformProfile.isQuestStandalone()
  local forced = os.getenv("POKEPORT_QUEST_PROFILE")
  if forced == "1" then return true end
  if forced == "0" then return false end
  return love and love.system and love.system.getOS
    and love.system.getOS() == "Android"
end

return PlatformProfile

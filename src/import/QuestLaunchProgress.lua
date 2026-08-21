-- Quest launcher-to-game handoff state.
--
-- Booting the selected game is synchronous. Keep the launcher compositor
-- alive for a short, bounded interval first so the headset receives several
-- real loading frames instead of jumping from Play to the opening movie.

local QuestLaunchProgress = {}

QuestLaunchProgress.DURATION = 0.75
QuestLaunchProgress.STEPS = 10

local DESTINATIONS = {
  red = "Pallet Town",
  blue = "Pallet Town",
  yellow = "Pallet Town",
  gold = "New Bark Town",
}

function QuestLaunchProgress.start(version, questActive)
  if not questActive then return nil end
  return {
    version = version,
    destination = DESTINATIONS[tostring(version or ""):lower()] or "Pallet Town",
    elapsed = 0,
  }
end

function QuestLaunchProgress.advance(state, dt)
  if not state then return true end
  state.elapsed = math.max(0, state.elapsed + math.max(0, tonumber(dt) or 0))
  return state.elapsed >= QuestLaunchProgress.DURATION
end

function QuestLaunchProgress.spec(state)
  if not state then return nil end
  local progress = math.min(1, state.elapsed / QuestLaunchProgress.DURATION)
  local complete = math.min(QuestLaunchProgress.STEPS,
    math.floor(progress * QuestLaunchProgress.STEPS + 0.00001))
  return {
    questLoading = true,
    title = "Opening " .. tostring(state.version or "game"),
    detail = "Preparing the Quest session",
    destination = state.destination,
    progress = progress,
    completed = complete,
    total = QuestLaunchProgress.STEPS,
    accessibilityLabel = ("Loading %s, %d percent, %d of %d")
      :format(state.destination, math.floor(progress * 100 + 0.5),
        complete, QuestLaunchProgress.STEPS),
  }
end

return QuestLaunchProgress

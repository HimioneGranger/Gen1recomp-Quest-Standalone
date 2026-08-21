-- Quest launcher-to-game handoff state.
--
-- Booting the selected game is synchronous.  Keep the launcher compositor
-- alive for a short, bounded interval first so the headset receives several
-- real progress frames instead of jumping from Play to the opening movie.

local QuestLaunchProgress = {}

QuestLaunchProgress.DURATION = 0.75
QuestLaunchProgress.FRAMES = 6

function QuestLaunchProgress.start(version, questActive)
  if not questActive then return nil end
  return { version = version, elapsed = 0, frame = 1 }
end

function QuestLaunchProgress.advance(state, dt)
  if not state then return true end
  state.elapsed = math.max(0, state.elapsed + math.max(0, tonumber(dt) or 0))
  state.frame = math.floor(state.elapsed * 12) % QuestLaunchProgress.FRAMES + 1
  return state.elapsed >= QuestLaunchProgress.DURATION
end

function QuestLaunchProgress.spec(state)
  if not state then return nil end
  return {
    title = "OPENING " .. tostring(state.version or "GAME"):upper(),
    detail = "Preparing the Quest session",
    lightning = true,
    animationTime = state.elapsed,
    animationFrame = state.frame,
  }
end

return QuestLaunchProgress

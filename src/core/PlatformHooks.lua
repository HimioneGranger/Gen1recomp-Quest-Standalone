-- Generic process-lifecycle mod hooks so a platform-specific launcher
-- integration (a native shell embedding this engine, e.g. wrapping the
-- window in a platform UI) can live entirely in a mod instead of
-- hand-patching main.lua, which every other engine change also touches.
-- See docs/modding.md's "Process-lifecycle hooks" section.
local ModRuntime = require("src.mods.Runtime")

local PlatformHooks = {}

function PlatformHooks.update(game, dt)
  return ModRuntime.call("core.update", function(g, d) g:update(d) end, game, dt)
end

-- Observation-only seam after a complete Lua draw has been submitted but
-- before the packaged host finalizes/captures it and love.graphics.present
-- swaps the default framebuffer. A second-screen or accessibility mod can
-- copy that finished composition without patching main.lua; with no listener
-- the wants guard makes this a no-op.
function PlatformHooks.frameDrawn(kind, subject)
  if not ModRuntime.wants("render.frame_drawn") then return end
  ModRuntime.emit("render.frame_drawn", { kind = kind, subject = subject })
end

function PlatformHooks.quitToLauncher(vanilla)
  return ModRuntime.call("core.quit_to_launcher", vanilla)
end

return PlatformHooks

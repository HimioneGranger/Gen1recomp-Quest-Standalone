-- core.update / core.quit_to_launcher through the public mod API: a
-- platform-launcher integration can pause the simulation and veto the
-- return-to-launcher decision from a mod, with no main.lua patch.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local PlatformHooks = require("src.core.PlatformHooks")

local FIXTURE = {
  ["mods/fix_platform_bridge/manifest.json"] = [[{
    "id": "fix_platform_bridge",
    "name": "Fixture Platform Bridge",
    "version": "1.0.0",
    "entry": "main.lua",
    "api": 2
  }]],
  ["mods/fix_platform_bridge/main.lua"] = [[
    local mod = ...
    local paused = false
    local extraPolls = 0
    mod.hooks:wrap("core.update", function(nextFn, game, dt)
      extraPolls = extraPolls + 1
      if not paused then nextFn(game, dt) end
    end)
    local vetoQuit = false
    mod.hooks:wrap("core.quit_to_launcher", function(nextFn)
      if vetoQuit then return false end
      return nextFn()
    end)
    local frames = {}
    mod.events:on("render.frame_drawn", function(frame)
      frames[#frames + 1] = frame
    end)
    -- test-only knobs on mod.exports: a sandboxed mod has no shared _G to
    -- smuggle them through (src/mods/Sandbox.lua)
    mod.exports.setPaused = function(v) paused = v end
    mod.exports.extraPolls = function() return extraPolls end
    mod.exports.setVetoQuit = function(v) vetoQuit = v end
    mod.exports.frames = frames
  ]],
}

-- core.update: a subscriber can pause (skip vanilla) and still run every frame
do
  local run = T.sdk.loadMods({ "mods/fix_platform_bridge" },
    { fs = T.sdk.memfs(FIXTURE) })
  T.eq(#run.errors, 0,
    "the fixture mod loads clean (" .. tostring(run.errors[1]) .. ")")

  local bridge = run.loader.exports.fix_platform_bridge
  local calls = 0
  local fakeGame = { update = function(self, dt) calls = calls + 1 end }

  bridge.setPaused(false)
  PlatformHooks.update(fakeGame, 1 / 60)
  T.eq(calls, 1, "unpaused: vanilla Game:update runs")
  T.eq(bridge.extraPolls(), 1,
    "the subscriber's wrapper runs every frame")

  bridge.setPaused(true)
  PlatformHooks.update(fakeGame, 1 / 60)
  T.eq(calls, 1, "paused: vanilla Game:update is skipped")
  T.eq(bridge.extraPolls(), 2,
    "the subscriber keeps polling every frame while paused")

  run.release()
end

-- render.frame_drawn: observers receive the exact completed frame identity.
-- They do not wrap, replace, or veto the draw path.
do
  local run = T.sdk.loadMods({ "mods/fix_platform_bridge" },
    { fs = T.sdk.memfs(FIXTURE) })
  T.eq(#run.errors, 0,
    "the fixture mod loads clean (" .. tostring(run.errors[1]) .. ")")

  local bridge = run.loader.exports.fix_platform_bridge
  local subject = { tag = "finished-game-frame" }
  PlatformHooks.frameDrawn("game", subject)
  T.eq(#bridge.frames, 1,
    "one post-draw event is emitted for one completed frame")
  T.eq(bridge.frames[1].kind, "game",
    "post-draw event identifies the frame kind")
  T.eq(bridge.frames[1].subject, subject,
    "post-draw event carries the exact drawn subject")

  run.release()
  -- No live listener: the public call remains a safe vanilla no-op.
  T.eq(PlatformHooks.frameDrawn("game", subject), nil,
    "post-draw seam is inert without a subscriber")
end

-- core.quit_to_launcher: a subscriber can veto without the vanilla
-- condition ever running, or pass it through unchanged
do
  local run = T.sdk.loadMods({ "mods/fix_platform_bridge" },
    { fs = T.sdk.memfs(FIXTURE) })
  T.eq(#run.errors, 0,
    "the fixture mod loads clean (" .. tostring(run.errors[1]) .. ")")

  local bridge = run.loader.exports.fix_platform_bridge
  bridge.setVetoQuit(true)
  local vanillaCalls = 0
  local vetoed = PlatformHooks.quitToLauncher(function()
    vanillaCalls = vanillaCalls + 1
    return true
  end)
  T.eq(vetoed, false, "a subscriber can veto the return-to-launcher decision")
  T.eq(vanillaCalls, 0, "a veto never evaluates the vanilla condition")
  bridge.setVetoQuit(false)

  local passed = PlatformHooks.quitToLauncher(function() return true end)
  T.eq(passed, true, "with no veto, the vanilla decision passes through unchanged")

  run.release()
end

T.finish("platform_lifecycle_hooks")

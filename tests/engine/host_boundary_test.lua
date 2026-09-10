-- ROM-free source contract for the portable host boundary.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local check = T.check

local function read(path)
  local file = assert(io.open(path, "rb"))
  local value = file:read("*a")
  file:close()
  return value
end

local portablePaths = {
  "main.lua",
  -- LauncherView is a shared UI consumer. It may select Quest-compatible
  -- launcher behavior, but its neutral import boundary is checked below.
  "src/import/RomImporter.lua",
  "src/core/HostBootstrap.lua",
  "src/core/HostDisplay.lua",
  "src/core/HostLifecycle.lua",
  "src/core/ImportHost.lua",
}

for _, path in ipairs(portablePaths) do
  local lower = read(path):lower()
  check(not lower:match("%f[%w]quest%f[%W]")
      and not lower:match("%f[%w]openxr%f[%W]")
      and not lower:match("%f[%w]vrapi%f[%W]")
      and not lower:match("%f[%w]ovr%f[%W]")
      and not lower:find("src.quest", 1, true)
      and not lower:find("src/quest", 1, true)
      and not lower:find("src.host.android", 1, true)
      and not lower:find("src/host/android", 1, true),
    path .. " stays free of packaged-host policy")
end

for _, path in ipairs({
  "main.lua",
  "src/import/LauncherView.lua",
  "src/import/RomImporter.lua",
  "src/core/Platform.lua",
}) do
  local source = read(path)
  check(not source:match("love%.system%.pickFile")
      and not source:match("love%.system%.getPickedFile")
      and not source:match("love%.system%.getPickError")
      and not source:match("love%.system%.pickFileKinds")
      and not source:match("love%.system%.createFile"),
    path .. " uses the neutral import boundary")
end

local main = read("main.lua")
local bootstrap = assert(main:find('require("src.core.HostBootstrap").install()',
  1, true))
local fallback = assert(main:find("HostDisplay.installPackagedBackend()", 1, true))
check(bootstrap < fallback, "neutral bootstrap precedes the temporary fallback")
local fallbackGate = assert(main:find("if not require", 1, true))
check(fallbackGate < bootstrap and bootstrap < fallback,
  "packaged display is used only when host discovery is absent")

for _, kind in ipairs({ "editor", "touch_editor", "launcher", "game" }) do
  local render = assert(main:find('HostDisplay.render("' .. kind .. '"', 1, true))
  local drawn = assert(main:find('PlatformHooks.frameDrawn("' .. kind .. '"',
    render, true))
  check(render < drawn, kind .. " draw stays inside host finalization")
end
local gameRender = assert(main:find('HostDisplay.render("game"', 1, true))
local gameDrawn = assert(main:find('PlatformHooks.frameDrawn("game"', gameRender, true))
local screenshot = assert(main:find("love.graphics.captureScreenshot", gameDrawn, true))
check(gameRender < gameDrawn and gameDrawn < screenshot,
  "frame-drawn and screenshot order is preserved inside game render")

local mustExit = assert(main:find("HostLifecycle.mustExit()", 1, true))
local quitDecision = assert(main:find("PlatformHooks.quitToLauncher", mustExit, true))
local handoff = assert(main:find('HostLifecycle.handoff("launcher")', quitDecision, true))
local restart = assert(main:find('require("src.core.HostShell").restart()', handoff, true))
local shutdown = assert(main:find("HostLifecycle.shutdown()", restart, true))
check(mustExit < quitDecision and quitDecision < handoff and handoff < restart
    and restart < shutdown,
  "terminal lifecycle waits until launcher-return can no longer abort quit")

local display = read("src/core/HostDisplay.lua")
check(display:find("function HostDisplay.installPackagedBackend()", 1, true),
  "temporary packaged display fallback remains available")
check(not display:find("ownsPacing", 1, true),
  "portable display boundary does not take pacing ownership")

local importer = read("src/import/RomImporter.lua")
local safArm = assert(importer:find("self.safPickerActive = true", 1, true))
local modPick = assert(importer:find('if not pickFile("mod") then', safArm, true))
check(safArm < modPick, "SAF quit guard is armed before the mod picker call")
check(importer:find("local modWorker = self.modWorker", 1, true),
  "mod worker retention remains intact")
check(importer:find("ImportHost.takeOpenResult()", 1, true) and
      importer:find("ImportHost.takeOpenError()", 1, true),
  "direct-result picker polling uses the neutral boundary")

local activity = read(
  "mobile/android/love/src/main/java/org/love2d/android/GameActivity.java")
local activityLower = activity:lower()
check(not activityLower:match("%f[%w]quest%f[%W]")
    and not activityLower:match("%f[%w]openxr%f[%W]")
    and not activityLower:match("%f[%w]vrapi%f[%W]")
    and not activityLower:match("%f[%w]ovr%f[%W]"),
  "standard Android activity stays host-neutral")

T.finish("host boundary")

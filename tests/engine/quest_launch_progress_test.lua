package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
love = love or require("tests.love_stub")

local Progress = require("src.import.QuestLaunchProgress")
local Loader = require("src.ui.kit.Loader")

local function read(path)
  local file = assert(io.open(path, "rb"))
  local value = assert(file:read("*a"))
  file:close()
  return value
end

T.check(read("src/import/RomImporter.lua"):find(
  'require("src.import.QuestLaunchProgress").start', 1, true),
  "the real Play route starts the Quest progress state")
T.check(read("src/import/LauncherView.lua"):find(
  'QuestLaunchProgress").spec', 1, true),
  "the real launcher compositor consumes the progress state")

T.eq(Progress.start("yellow", false), nil,
  "generic Android does not gain the Quest handoff")
local state = Progress.start("yellow", true)
T.check(state ~= nil, "Quest Play enters the visible handoff")

local seen = {}
for _, dt in ipairs({ 0.00, 0.09, 0.09, 0.09, 0.09, 0.09 }) do
  T.check(not Progress.advance(state, dt), "early sample remains visible")
  local spec = Progress.spec(state)
  T.check(spec.lightning, "actual handoff requests lightning")
  local frame, offset = Loader.lightningState(spec.animationTime, spec.animationFrame)
  seen[frame .. ":" .. offset] = true
end
local count = 0
for _ in pairs(seen) do count = count + 1 end
T.check(count >= 4, "multiple time samples advance through different bolt states")
T.check(Progress.advance(state, 1), "bounded handoff eventually boots")

T.finish("quest launch progress")

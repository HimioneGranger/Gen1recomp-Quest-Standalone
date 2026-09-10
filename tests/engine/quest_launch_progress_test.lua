package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
love = love or require("tests.love_stub")

local Progress = require("src.import.QuestLaunchProgress")
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

local previousProgress = -1
for _, dt in ipairs({ 0.00, 0.09, 0.09, 0.09, 0.09, 0.09 }) do
  T.check(not Progress.advance(state, dt), "early sample remains visible")
  local spec = Progress.spec(state)
  T.check(spec.lightning == nil, "actual handoff does not request lightning")
  T.check(spec.progress >= previousProgress,
    "actual handoff reports monotonic progress")
  previousProgress = spec.progress
end
T.check(Progress.advance(state, 1), "bounded handoff eventually boots")

T.finish("quest launch progress")

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local Progress = require("src.import.QuestLaunchProgress")
local Screen = require("src.ui.kit.QuestLoadingScreen")

local function read(path)
  local file = assert(io.open(path, "rb"))
  local value = assert(file:read("*a"))
  file:close()
  return value
end

local function zone(layout, id)
  for _, value in ipairs(layout.zones) do
    if value.id == id then return value end
  end
end

T.check(read("src/import/RomImporter.lua"):find(
  'require("src.import.QuestLaunchProgress").start', 1, true),
  "the real Play route starts the Quest loading state")
T.check(read("src/import/LauncherView.lua"):find(
  'QuestLaunchProgress").spec', 1, true),
  "the launcher compositor consumes the Quest loading state")
T.check(read("src/ui/kit/Loader.lua"):find(
  'src.ui.kit.QuestLoadingScreen', 1, true),
  "the blocking loader uses the dedicated Quest renderer")

T.eq(Progress.start("yellow", false), nil,
  "generic Android keeps the existing direct handoff")
local state = Progress.start("yellow", true)
T.check(state ~= nil, "Quest Play enters the visible handoff")
local spec = Progress.spec(state)
T.check(spec.questLoading, "the handoff requests the Pokemon loading screen")
T.check(spec.accessibilityLabel:find("Loading Pallet Town", 1, true),
  "the loading state keeps a meaningful accessibility label")
T.check(not Progress.advance(state, 0.25), "an early sample stays visible")
T.check(Progress.advance(state, 1), "the preserved bounded handoff boots")

local function measured(line, size)
  return #line * size * 0.52, size
end

local layout = Screen.layout("Pallet Town", 0.7, 10, measured)
T.eq(layout.logo.x, Screen.REFERENCE_W / 4,
  "the logo is horizontally centered in the left half")
T.eq(layout.logo.y, Screen.REFERENCE_H / 2,
  "the logo is vertically centered in the left half")
T.eq(Screen.PROTECTED_MARGIN, 14,
  "all measured foreground exclusions use the required breathing margin")
T.eq(layout.loadingCopy, "LOADING MAP DATA - 70%  (7 / 10)",
  "the loading copy remains unchanged")
T.eq(#layout.background, Screen.MOTIF_COUNT,
  "V8 removes exactly the six user-marked motifs")
T.eq(Screen.V4_MOTIF_COUNT, 32,
  "V8 preserves the remaining original composition boundary")

local half = Screen.REFERENCE_W / 2
local leftCount, rightBlueCount = 0, 0
local leftSizes, leftColors = {}, {}
for _, ball in ipairs(layout.background) do
  if ball.x < half then
    leftCount = leftCount + 1
    leftSizes[ball.r], leftColors[ball.color] = true, true
  elseif ball.color == "blue" then
    rightBlueCount = rightBlueCount + 1
  end
end
T.check(leftCount >= 15,
  "V8 preserves the left-heavy balance after marked removals")
T.eq(rightBlueCount, 5,
  "V7 leaves the unmarked right-half blue motifs unchanged")
local leftSizeCount, leftColorCount = 0, 0
for _ in pairs(leftSizes) do leftSizeCount = leftSizeCount + 1 end
for _ in pairs(leftColors) do leftColorCount = leftColorCount + 1 end
T.check(leftSizeCount >= 5, "left-half outlines use varied sizes")
T.eq(leftColorCount, 3, "left-half outlines use red, blue, and yellow")

for _, removed in ipairs({
  { 911, 198, 13, "blue" },
  { 916, 357, 22, "blue" },
  { 930, 550, 15, "blue" },
  { 1373, 91, 13, "yellow" },
  { 1061, 766, 13, "yellow" },
  { 610, 150, 16, "yellow" },
}) do
  for _, anchor in ipairs(Screen.motifAnchors) do
    T.check(not (anchor[1] == removed[1] and anchor[2] == removed[2]),
      "V8 excludes each user-marked motif")
  end
end

for _, ball in ipairs(layout.background) do
  for _, clear in ipairs(layout.zones) do
    T.check(not Screen.intersectsBall(clear, ball),
      ("background ball stays outside the %s clear zone"):format(clear.id))
  end
end
for i, ball in ipairs(layout.background) do
  for j = i + 1, #layout.background do
    T.check(not Screen.ballsOverlap(ball, layout.background[j]),
      ("background motifs %d and %d do not collide"):format(i, j))
  end
end

local destinationZones = {}
for wordCount, name in ipairs({
  "Pallet Town",
  "Seafoam Islands Lower",
  "Pokemon Mansion Basement Floor",
  "Silph Company Executive Meeting Room",
}) do
  wordCount = wordCount + 1
  local named = Screen.layout(name, 0.7, 10, measured)
  local destinationZone = zone(named, "destination")
  destinationZones[#destinationZones + 1] = destinationZone
  T.eq(table.concat(named.destinationLines, " "), name,
    name .. " is not changed or skewed by layout")
  T.check(#named.destinationLines <= 2,
    name .. " fits in at most two centered lines")
  T.check(destinationZone.w >= #name * 10,
    name .. " has a measured live-text clear zone")
  for _, ball in ipairs(named.background) do
    for _, clear in ipairs(named.zones) do
      T.check(not Screen.intersectsBall(clear, ball),
        ("%d-word destination avoids the %s foreground zone")
          :format(wordCount, clear.id))
    end
  end
  for i, ball in ipairs(named.background) do
    for j = i + 1, #named.background do
      T.check(not Screen.ballsOverlap(ball, named.background[j]),
        ("%d-word destination keeps motifs %d and %d collision-free")
          :format(wordCount, i, j))
    end
  end
  T.eq(#named.background, Screen.MOTIF_COUNT,
    name .. " preserves the deterministic motif count")
  T.same(named.background,
    Screen.layout(name, 0.7, 10, measured).background,
    name .. " has deterministic seeded placement")
end
T.check(destinationZones[1].w ~= destinationZones[2].w
    and destinationZones[2].w ~= destinationZones[3].w,
  "destination protection adapts to measured two- through five-word bounds")

for i, ball in ipairs(layout.progressBalls) do
  if i % 2 == 1 then
    T.eq(ball.top, "red", "odd progress ball has a red top")
    T.eq(ball.bottom, "white", "odd progress ball has a white bottom")
  else
    T.eq(ball.top, "blue", "even progress ball has a blue top")
    T.eq(ball.bottom, "yellow", "even progress ball has a yellow bottom")
  end
  T.eq(ball.center, "white", "each progress ball has a white center dot")
end

local loadingSources = table.concat({
  read("src/import/QuestLaunchProgress.lua"),
  read("src/ui/kit/QuestLoadingScreen.lua"),
  read("src/ui/kit/Loader.lua"),
}, "\n"):lower()
T.check(not loadingSources:find("lightning", 1, true),
  "loading source has no lightning decoration")
T.check(not loadingSources:find("bolt", 1, true),
  "loading source has no bolt asset or drawing path")

T.finish("Quest loading screen")

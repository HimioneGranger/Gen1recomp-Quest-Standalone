-- The Quest room panel is shared by launcher, loading, and game presentation.
-- Self-contained: luajit tests/engine/quest_panel_placement_contract_test.lua
local function read(path)
  local file = assert(io.open(path, "rb"))
  local value = file:read("*a")
  file:close()
  return value
end

local function check(value, message)
  assert(value, message)
end

local bridge = read("mobile/android/love/src/jni/questxr_bridge/questxr_bridge.c")

local panelHeightSource = bridge:match(
  "layer%.size%.height%s*=%s*([%d%.]+)f;")
assert(panelHeightSource, "submitted panel height is declared in source")
local panelHeight = tonumber(panelHeightSource)
local offsetName, panelOffset = bridge:match(
  "const float ([%w_]+vertical_offset_m)%s*=%s*([%-]?[%d%.]+)f;")
assert(panelOffset, "shared panel vertical offset is declared in source")
panelOffset = tonumber(panelOffset)

local expectedOffset = -panelHeight * (0.50 - 0.35)
check(math.abs(panelOffset - expectedOffset) < 1e-9,
  "panel moves down by exactly 15 percent of its displayed physical height")

local gazeFractionFromTop = (panelOffset + panelHeight / 2) / panelHeight
check(math.abs(gazeFractionFromTop - 0.35) < 1e-9,
  "forward gaze intersects the displayed panel at 35 percent from the top")

local startupUse = "panel_pose.position.y = " .. offsetName .. ";"
local anchorUse = "panel_pose.position.y += " .. offsetName .. ";"
check(bridge:find(startupUse, 1, true),
  "view-space startup panel uses the shared vertical offset")
check(bridge:find(anchorUse, 1, true),
  "anchored room panel uses the same shared vertical offset")
local _, offsetUseCount = bridge:gsub(offsetName, "")
check(offsetUseCount == 3,
  "one declaration is shared by exactly the startup and room-anchor paths")
check(bridge:find("layer.pose = submitted_panel_pose;", 1, true),
  "all submitted panel content uses one shared pose")
check(bridge:find("questxr_project_ray", 1, true) and
      bridge:find("submitted_panel_pose", 1, true),
  "controller pointing follows the moved shared panel")

print("quest_panel_placement_contract_test: 7 checks passed")

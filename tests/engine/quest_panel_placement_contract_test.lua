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

check(bridge:find("launcher_panel_gaze_top_third_offset_m = -0.19375f", 1, true),
  "panel offset targets the upper third of the 1.1625 m panel")
check(bridge:find("panel_pose.position.y = launcher_panel_gaze_top_third_offset_m;", 1, true),
  "view-space startup panel uses the shared downward offset")
check(bridge:find("panel_pose.position.y +=%s+launcher_panel_gaze_top_third_offset_m"),
  "anchored room panel keeps the same downward offset")
check(bridge:find("layer.pose = submitted_panel_pose;", 1, true),
  "all submitted panel content uses one shared pose")
check(bridge:find("questxr_project_ray", 1, true) and
      bridge:find("submitted_panel_pose", 1, true),
  "controller pointing follows the moved shared panel")

print("quest_panel_placement_contract_test: 5 checks passed")

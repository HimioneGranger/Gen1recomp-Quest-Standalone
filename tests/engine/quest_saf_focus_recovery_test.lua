local function read(path)
  local file = assert(io.open(path, "rb"))
  local value = file:read("*a")
  file:close()
  return value
end

local checks = 0
local function check(value, message)
  checks = checks + 1
  assert(value, message)
end

local host = read("mobile/android/love/src/main/java/org/love2d/android/GameActivity.java")
local activity = read("mobile/android/love/src/questVr/java/org/love2d/android/QuestGameActivity.java")
local bridge = read("mobile/android/love/src/jni/questxr_bridge/questxr_bridge.c")

check(host:find("onHostFilePickerReturned", 1, true), "base host exposes SAF return hook")
check(activity:find("nativeQuestXrMarkSafReturn", 1, true), "Quest host marks SAF return")
check(activity:find("onQuestXrSafPoseReady", 1, true), "Quest host receives pose-ready callback")
check(not activity:find("moveToFront", 1, true), "Quest host does not force task ordering")
check(bridge:find("questxr_saf_return_generation", 1, true), "native bridge records SAF generation")
check(bridge:find("questxr_notify_activity_saf_pose_ready", 1, true), "native bridge notifies pose readiness")
check(bridge:find("saf_generation != seen_saf_generation && ray_active", 1, true),
  "native bridge requires a returned tracked ray before release")

print(("quest_saf_focus_recovery_test: %d checks passed"):format(checks))

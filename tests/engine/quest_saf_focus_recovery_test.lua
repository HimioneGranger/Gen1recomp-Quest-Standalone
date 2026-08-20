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
local main = read("main.lua")
local importer = read("src/import/RomImporter.lua")

check(host:find("onHostFilePickerReturned", 1, true), "base host exposes SAF return hook")
check(activity:find("nativeQuestXrMarkSafReturn", 1, true), "Quest host marks SAF return")
check(activity:find("onQuestXrSessionFocused", 1, true),
  "Quest host provides the native session-focus callback")
check(activity:find("onQuestXrSafPoseReady", 1, true), "Quest host receives pose-ready callback")
check(not activity:find("moveToFront", 1, true), "Quest host does not force task ordering")
check(bridge:find("questxr_saf_return_generation", 1, true), "native bridge records SAF generation")
check(bridge:find("questxr_notify_activity_saf_pose_ready", 1, true), "native bridge notifies pose readiness")
check(bridge:find('"onQuestXrSessionFocused", "()V"', 1, true),
  "native bridge callback name matches the Quest host")
check(bridge:find("saf_generation != seen_saf_generation && ray_active", 1, true)
   or bridge:find("saf_pose_pending_generation != 0", 1, true),
  "native bridge requires a returned tracked ray before release")
check(main:find("shouldDeferAndroidSafQuit", 1, true),
  "LÖVE loop recognizes the Quest SAF-return quit event")
check(main:find("Importer.safPickerActive", 1, true),
  "quit deferral covers the full native-picker return handoff")
check(main:find("if Importer.safPickerActive then return true end", 1, true),
  "quit deferral is armed before DocumentsUI can enqueue its shutdown")
check(importer:find("local modWorker = self.modWorker", 1, true),
  "completed mod worker is retained locally for its final status check")
check(importer:find("self.modWorker == modWorker and coroutine.status(modWorker)", 1, true),
  "completed mod worker never calls coroutine.status on cleared state")

print(("quest_saf_focus_recovery_test: %d checks passed"):format(checks))

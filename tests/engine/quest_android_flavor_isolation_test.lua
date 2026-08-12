-- The optional Quest backend must stay out of stock Android source/package paths.
-- Self-contained: luajit tests/engine/quest_android_flavor_isolation_test.lua
local function read(path)
  local f = assert(io.open(path, "rb"))
  local value = f:read("*a")
  f:close()
  return value
end

local function check(value, message)
  if not value then error(message, 2) end
end

local app = read("mobile/android/app/build.gradle")
local love = read("mobile/android/love/build.gradle")
local activity = read(
  "mobile/android/love/src/main/java/org/love2d/android/GameActivity.java")
local questActivity = read(
  "mobile/android/love/src/questVr/java/org/love2d/android/QuestGameActivity.java")
local loveMake = read("mobile/android/love/src/jni/love/Android.mk")
local questMake = read("mobile/android/love/src/jni/questxr_bridge/Android.mk")

check(app:find("questVrImplementation", 1, true),
  "OpenXR loader dependency is scoped to questVr")
check(not app:find("implementation 'org.khronos.openxr", 1, true),
  "OpenXR loader is not a global app dependency")
check(love:find("arguments 'QUEST_XR=1'", 1, true),
  "only the questVr library flavor enables native XR compilation")
check(not activity:find("Quest", 1, true) and not activity:find("OpenXR", 1, true),
  "shared GameActivity has no Quest/OpenXR references")
check(questActivity:find('return new String[] { "questxr" };', 1, true),
  "Quest activity opts into its separate native library")
check(not loveMake:find("questxr", 1, true),
  "liblove does not compile or include the Quest bridge")
check(questMake:find("ifeq ($(QUEST_XR),1)", 1, true),
  "Quest native module is guarded by the flavor build argument")
check(questMake:find("LOCAL_MODULE := questxr", 1, true),
  "Quest bridge builds as a separate shared library")

print("quest_android_flavor_isolation_test: ok")

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
local questNative = read(
  "mobile/android/love/src/jni/questxr_bridge/questxr_bridge.c")
local questManifest = read(
  "mobile/android/app/src/questVr/AndroidManifest.xml")

check(app:find("questVrImplementation", 1, true),
  "OpenXR loader dependency is scoped to questVr")
check(app:find("abiFilters 'arm64-v8a'", 1, true),
  "Quest application packaging is ARM64-only")
local _, appAbiCount = app:gsub("abiFilters 'arm64%-v8a'", "")
local _, loveAbiCount = love:gsub("abiFilters 'arm64%-v8a'", "")
check(appAbiCount == 1 and loveAbiCount == 1,
  "both Quest application and native library flavors are ARM64-only")
check(love:find("withFlavor('mode', 'questVr')", 1, true) and
      love:find("variant.externalNativeBuild.abiFilters.set(['arm64-v8a'])", 1, true),
  "merged Quest native variants override inherited stock ABI filters")
check(not app:find("implementation 'org.khronos.openxr", 1, true),
  "OpenXR loader is not a global app dependency")
check(love:find("arguments 'QUEST_XR=1'", 1, true),
  "only the questVr library flavor enables native XR compilation")
check(not activity:find("Quest", 1, true) and not activity:find("OpenXR", 1, true),
  "shared GameActivity has no Quest/OpenXR references")
check(questActivity:find('return new String[] { "questxr" };', 1, true),
  "Quest activity opts into its separate native library")
check(questActivity:find("protected void onHostDestroy()", 1, true) and
      questActivity:find("nativeQuestXrDestroy();", 1, true),
  "Quest activity releases the native host from the generic destroy hook")
check(not loveMake:find("questxr", 1, true),
  "liblove does not compile or include the Quest bridge")
check(questMake:find("ifeq ($(QUEST_XR),1)", 1, true),
  "Quest native module is guarded by the flavor build argument")
check(questMake:find("LOCAL_MODULE := questxr", 1, true),
  "Quest bridge builds as a separate shared library")
check(not questNative:find("Java_org_love2d_android_GameActivity", 1, true),
  "native bridge exports no JNI entry point for stock GameActivity")
check(questNative:find("pthread_join(questxr_bootstrap_thread", 1, true) and
      not questNative:find("pthread_detach", 1, true),
  "destroy can join the bootstrap before releasing Android context")
check(questNative:find("static atomic_int questxr_bootstrap_started", 1, true) and
      questNative:find("static atomic_int questxr_bootstrap_shutdown_requested", 1, true) and
      questNative:find("static atomic_int questxr_bootstrap_stopped", 1, true),
  "cross-thread bootstrap lifecycle flags use C11 atomics")
check(questNative:find("xrRequestExitSession(session)", 1, true) and
      questNative:find("XR_SESSION_STATE_STOPPING", 1, true),
  "launcher handoff exits and ends the running OpenXR session cleanly")
check(questNative:find("if (!frame.shouldRender)", 1, true),
  "OpenXR frames honor shouldRender before acquiring a swapchain image")
check(questNative:find("XR_TYPE_EVENT_DATA_REFERENCE_SPACE_CHANGE_PENDING", 1, true) and
      questNative:find("const int room_anchor_enabled = 1", 1, true),
  "launcher anchoring follows Quest recenter events")
check(not questNative:find("eglTerminate(display)", 1, true),
  "Quest handoff does not terminate SDL/Love's process-wide EGL display")
check(not questManifest:find("QUEST_XR_BOOTSTRAP", 1, true),
  "Quest manifest has no obsolete metadata gate")

print("quest_android_flavor_isolation_test: ok")

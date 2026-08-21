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
local loveGraphics = read(
  "mobile/android/love/src/jni/love/src/modules/graphics/opengl/Graphics.cpp")
local questMake = read("mobile/android/love/src/jni/questxr_bridge/Android.mk")
local questNative = read(
  "mobile/android/love/src/jni/questxr_bridge/questxr_bridge.c")
local questDisplay = read("src/host/android/QuestOpenXRDisplay.lua")
local questAdapter = read("src/quest/compat/HostAdapterV1.lua")
local questManifest = read(
  "mobile/android/app/src/questVr/AndroidManifest.xml")

check(questManifest:find('android:name="SDL_ENV.POKEPORT_QUEST_PROFILE"', 1, true) and
      questManifest:find('android:value="1"', 1, true),
  "Quest flavor selects its Lua product profile without panel FFI")

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
check(activity:find("protected String getHostModule()", 1, true) and
      activity:find('return "";', 1, true),
  "standard Android returns no host adapter")
check(questActivity:find('return new String[] { "questxr" };', 1, true),
  "Quest activity opts into its separate native library")
check(questActivity:find("protected String getHostModule()", 1, true) and
      questActivity:find('return "src.quest.compat.HostAdapterV1";', 1, true),
  "Quest activity selects the exact API v1 host adapter")
check(questAdapter:find("apiVersion = 1", 1, true) and
      questAdapter:find("QuestOpenXRDisplay", 1, true) and
      not questAdapter:find("ImportHost", 1, true) and
      not questAdapter:find("HostLifecycle", 1, true),
  "first Quest adapter installs only the existing display backend")
check(questActivity:find("protected void onHostDestroy()", 1, true) and
      questActivity:find("nativeQuestXrDestroy();", 1, true),
  "Quest activity releases the native host from the generic destroy hook")
check(not loveMake:find("questxr", 1, true),
  "liblove does not compile or include the Quest bridge")
check(loveGraphics:find("love_android_set_presented_frame_observer", 1, true) and
      loveGraphics:find("androidPresentedFrameObserver = nullptr", 1, true) and
      not loveGraphics:find("questxr", 1, true),
  "stock Android presentation exposes a no-op generic optional host observer")
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
check(questNative:find("XR_REFERENCE_SPACE_TYPE_LOCAL", 1, true) and
      questNative:find("XR_REFERENCE_SPACE_TYPE_VIEW", 1, true) and
      not questNative:find("XR_REFERENCE_SPACE_TYPE_STAGE", 1, true) and
      not questNative:find("xrRequestBoundaryVisibilityMETA", 1, true),
  "Quest host uses local/view tracking and never requests a Guardian boundary mode")
check(not questNative:find("eglTerminate(display)", 1, true),
  "Quest handoff does not terminate SDL/Love's process-wide EGL display")
check(questNative:find("uniform vec4 focusRect", 1, true) and
      questNative:find("vec4(0.15,1.0,0.30,1.0)", 1, true),
  "Quest compositor draws the thin green launcher focus border")
check(questNative:find("questxr_request_panel_capture", 1, true) and
      questNative:find("love_android_host_presented_frame", 1, true) and
      questNative:find("love_android_set_presented_frame_observer", 1, true) and
      questNative:find('dlopen("liblove.so", RTLD_NOW)', 1, true),
  "Quest panel pixels are captured only from the completed presented frame")
check(questNative:find("GL_ACTIVE_TEXTURE", 1, true) and
      questNative:find("GL_TEXTURE_BINDING_2D", 1, true) and
      questNative:find("old_scissor", 1, true),
  "Quest panel capture restores raw GL state hidden from LÖVE's state cache")
check(questNative:find("questxr_poll_pointer_axes", 1, true) and
      questNative:find("left_stick.isActive", 1, true),
  "Quest launcher exposes continuous Touch stick axes to its virtual pointer")
check(questNative:find('"/user/hand/left/input/aim/pose"', 1, true) and
      questNative:find('"/user/hand/right/input/aim/pose"', 1, true) and
      questNative:find("left_pointer_pose_action", 1, true) and
      questNative:find("right_pointer_pose_action", 1, true) and
      questNative:find("xrCreateActionSpace", 1, true) and
      questNative:find("questxr_poll_pointer_position", 1, true),
  "Quest launcher projects both native Touch aim poses onto its room panel")
check(questNative:find("Only one", 1, true) and
      questNative:find("hover owner exists", 1, true) and
      questNative:find("active_pointer_hand", 1, true),
  "Quest launcher has one deterministic pointing owner and one Select event")
check(questNative:find("uniform vec3 pointerState", 1, true) and
      questNative:find("questxr_set_panel_pointer", 1, true) and
      questNative:find("int panel_requested = panel_pointer[2] > 0.5f;", 1, true) and
      questNative:find("if (panel_requested && native_ray_active)", 1, true) and
      questNative:find("panel_pointer[2] = 0.0f;", 1, true) and
      questNative:find("vec2(textureSize(panel,0))", 1, true) and
      questNative:find("smoothstep(3.5-aa,3.5+aa,r)", 1, true) and
      not questNative:find("float shadow=", 1, true) and
      not questNative:find("float ring=", 1, true),
  "Quest compositor renders a crisp launcher-only selector without a halo or ring")
check(questNative:find("XrCompositionLayerProjection", 1, true)
      and questNative:find("end.layerCount = submitted_layer_count", 1, true)
      and questNative:find("white environment submit rejected; reverting to one panel layer", 1, true)
      and not questNative:find("laser_swapchain", 1, true)
      and not questNative:find("XR_COMPOSITION_LAYER_BLEND_TEXTURE_SOURCE_ALPHA_BIT", 1, true),
  "Quest submit list uses only a guarded core background plus the validated panel")
check(questNative:find("environment probe extensions", 1, true)
      and questNative:find("xrEnumerateInstanceExtensionProperties", 1, true)
      and questNative:find("xrGetSystemProperties", 1, true)
      and questNative:find("xrEnumerateEnvironmentBlendModes", 1, true)
      and questNative:find("xrEnumerateViewConfigurationViews", 1, true)
      and questNative:find("white environment renderer armed", 1, true)
      and questNative:find("xrLocateViews", 1, true)
      and questNative:find("background_layer.viewCount = 2", 1, true),
  "Quest white environment uses the probed core stereo projection contract")
check(not questNative:find("XR_KHR_COMPOSITION_LAYER_EQUIRECT_EXTENSION_NAME,", 1, true)
      and not questNative:find("XR_KHR_COMPOSITION_LAYER_CUBE_EXTENSION_NAME,", 1, true),
  "Quest white environment enables no equirect or cube extension")
check(questNative:find("questxr_get_application_vm", 1, true) and
      questNative:find("questxr_get_application_context", 1, true),
  "Quest gameplay backends can inherit the Android OpenXR loader context")
check(questDisplay:find("_G.QUEST_PANEL_ACTIVE = true", 1, true),
  "Quest display advertises the panel handoff capability to gameplay mods")
check(not questManifest:find("QUEST_XR_BOOTSTRAP", 1, true),
  "Quest manifest has no obsolete metadata gate")
check(questManifest:find('android:launchMode="singleTask"', 1, true) and
      questManifest:find('tools:replace="android:launchMode"', 1, true),
  "Quest host reuses the Horizon OS immersive-launch task without changing stock Android")

print("quest_android_flavor_isolation_test: ok")

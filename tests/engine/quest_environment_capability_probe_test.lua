-- The Environment Renderer Test uses only the core stereo projection contract
-- proven on device. It must keep the panel-only path as its immediate fallback.
-- Self-contained: luajit tests/engine/quest_environment_capability_probe_test.lua
local function read(path)
  local f = assert(io.open(path, "rb"))
  local value = f:read("*a")
  f:close()
  return value
end

local function check(value, message)
  if not value then error(message, 2) end
end

local bridge = read("mobile/android/love/src/jni/questxr_bridge/questxr_bridge.c")

check(bridge:find("environment probe extensions", 1, true)
    and bridge:find("xrEnumerateInstanceExtensionProperties", 1, true)
    and bridge:find("XR_KHR_COMPOSITION_LAYER_EQUIRECT_EXTENSION_NAME", 1, true)
    and bridge:find("XR_KHR_COMPOSITION_LAYER_EQUIRECT2_EXTENSION_NAME", 1, true)
    and bridge:find("XR_KHR_COMPOSITION_LAYER_CUBE_EXTENSION_NAME", 1, true),
  "probe records available full-environment extension types")
check(bridge:find("xrGetSystemProperties", 1, true)
    and bridge:find("maxLayers=%u", 1, true)
    and bridge:find("xrEnumerateEnvironmentBlendModes", 1, true)
    and bridge:find("xrEnumerateViewConfigurationViews", 1, true)
    and bridge:find("projectionViews=%u", 1, true),
  "probe records layer budget, blend mode, and primary stereo view contract")
check(bridge:find("white_environment_eligible = max_layer_count >= 2", 1, true)
    and bridge:find("projection_view_count == 2", 1, true)
    and bridge:find("projection_config_valid", 1, true)
    and bridge:find("XrCompositionLayerProjection", 1, true)
    and bridge:find("xrLocateViews", 1, true)
    and bridge:find("located_view_count == 2", 1, true)
    and bridge:find("XR_VIEW_STATE_POSITION_VALID_BIT", 1, true)
    and bridge:find("XR_VIEW_STATE_ORIENTATION_VALID_BIT", 1, true),
  "white surround activates only for two valid stereo projection views")
check(bridge:find("background_info.usageFlags = XR_SWAPCHAIN_USAGE_COLOR_ATTACHMENT_BIT", 1, true)
    and bridge:find("glClearColor(1.0f, 1.0f, 1.0f, 1.0f)", 1, true)
    and bridge:find("background_layer.viewCount = 2", 1, true)
    and bridge:find("layers[0] = (const XrCompositionLayerBaseHeader *) &background_layer", 1, true)
    and bridge:find("layers[1] = (const XrCompositionLayerBaseHeader *) &layer", 1, true),
  "white projection background is opaque and ordered before the validated panel")
check(bridge:find("background_frame_ready = 0", 1, true)
    and bridge:find("white environment acquire failed", 1, true)
    and bridge:find("white environment wait failed", 1, true)
    and bridge:find("white environment render/release failed", 1, true)
    and bridge:find("white environment submit rejected; reverting to one panel layer", 1, true)
    and bridge:find("end.layerCount = submitted_layer_count", 1, true),
  "every environment failure reverts to the known-good panel-only submit")
check(not bridge:find("XrCompositionLayerEquirect", 1, true)
    and not bridge:find("XrCompositionLayerCube", 1, true)
    and not bridge:find("laser_swapchain", 1, true)
    and not bridge:find("XR_COMPOSITION_LAYER_BLEND_TEXTURE_SOURCE_ALPHA_BIT", 1, true),
  "renderer uses no equirect, cube, laser, or alpha-layer workaround")

print("quest_environment_capability_probe_test: ok")

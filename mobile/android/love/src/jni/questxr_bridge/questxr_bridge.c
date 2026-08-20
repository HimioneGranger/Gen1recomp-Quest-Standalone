#include <jni.h>
#include <EGL/egl.h>
#include <GLES3/gl3.h>
#include <android/log.h>
#include <dlfcn.h>
#include <math.h>
#include <pthread.h>
#include <stdbool.h>
#include <stdatomic.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define XR_USE_PLATFORM_ANDROID
#define XR_USE_GRAPHICS_API_OPENGL_ES
#define XR_NO_PROTOTYPES
#include <openxr/openxr.h>
#include <openxr/openxr_platform.h>

#if defined(__GNUC__)
#define QUESTXR_EXPORT __attribute__((visibility("default")))
#else
#define QUESTXR_EXPORT
#endif

static JavaVM *questxr_vm;
static jobject questxr_activity;
static pthread_t questxr_bootstrap_thread;
static atomic_int questxr_bootstrap_started;
static int questxr_bootstrap_joinable;
static atomic_int questxr_bootstrap_shutdown_requested;
static atomic_int questxr_bootstrap_stopped = 1;
// Incremented by the Quest activity for every result from Android DocumentsUI.
// It carries no file name, path, or content; the native thread uses it only to
// bound post-return action/pose diagnostics.
static atomic_uint questxr_saf_return_generation;
static pthread_mutex_t questxr_panel_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t questxr_input_mutex = PTHREAD_MUTEX_INITIALIZER;
static uint32_t questxr_input_events;
static float questxr_pointer_x;
static float questxr_pointer_y;
static float questxr_ray_pointer_x;
static float questxr_ray_pointer_y;
static int questxr_ray_pointer_active;
static unsigned char *questxr_panel_rgba;
static unsigned char *questxr_panel_spare;
static uint64_t questxr_panel_generation;
static float questxr_focus_rect[4] = {-1.0f, -1.0f, 0.0f, 0.0f};
static float questxr_pending_focus_rect[4] = {-1.0f, -1.0f, 0.0f, 0.0f};
static float questxr_panel_pointer[3] = {-1.0f, -1.0f, 0.0f};
static int questxr_panel_capture_requested;
static EGLContext questxr_capture_context = EGL_NO_CONTEXT;
static GLuint questxr_capture_texture;
static GLuint questxr_capture_fbo;
typedef void (GL_APIENTRYP QuestxrBlitFramebufferProc)(
    GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLbitfield, GLenum);
static QuestxrBlitFramebufferProc questxr_gl_blit_framebuffer;
typedef void (*QuestxrPresentedFrameObserver)(int, int);
typedef void (*QuestxrSetPresentedFrameObserver)(QuestxrPresentedFrameObserver);
static void *questxr_love_handle;
static int questxr_present_observer_registered;

enum {
    QUESTXR_INPUT_UP = 1u << 0,
    QUESTXR_INPUT_DOWN = 1u << 1,
    QUESTXR_INPUT_LEFT = 1u << 2,
    QUESTXR_INPUT_RIGHT = 1u << 3,
    QUESTXR_INPUT_SELECT = 1u << 4,
    QUESTXR_INPUT_BACK = 1u << 5,
};

static void questxr_queue_input(uint32_t events) {
    if (!events) return;
    pthread_mutex_lock(&questxr_input_mutex);
    questxr_input_events |= events;
    pthread_mutex_unlock(&questxr_input_mutex);
}

static void questxr_set_pointer_axes(float x, float y) {
    pthread_mutex_lock(&questxr_input_mutex);
    questxr_pointer_x = x;
    questxr_pointer_y = y;
    pthread_mutex_unlock(&questxr_input_mutex);
}

static void questxr_set_ray_pointer(float x, float y, int active) {
    pthread_mutex_lock(&questxr_input_mutex);
    questxr_ray_pointer_x = x;
    questxr_ray_pointer_y = y;
    questxr_ray_pointer_active = active;
    pthread_mutex_unlock(&questxr_input_mutex);
}

static float questxr_dot(XrVector3f a, XrVector3f b) {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

#define XR_LOG(...) __android_log_print(ANDROID_LOG_INFO, "QuestXR", __VA_ARGS__)
#define XR_FAIL(message) do { XR_LOG("native bootstrap failed: %s", message); goto done; } while (0)

// The Android host must not assume that a resumed or window-focused activity
// can read Quest controller actions. This callback is made only after the
// OpenXR runtime sends XR_SESSION_STATE_FOCUSED.
static void questxr_notify_activity_session_focused(JNIEnv *env) {
    if (!env || !questxr_activity) return;
    jclass activity_class = (*env)->GetObjectClass(env, questxr_activity);
    if (!activity_class) return;
    jmethodID method = (*env)->GetMethodID(env, activity_class,
        "onQuestXrSessionFocused", "()V");
    if (method) {
        (*env)->CallVoidMethod(env, questxr_activity, method);
        if ((*env)->ExceptionCheck(env)) (*env)->ExceptionClear(env);
    }
    (*env)->DeleteLocalRef(env, activity_class);
}

// Android considers the picker return complete before Quest makes the tracked
// aim actions active again. Notify the host only after normal action sync and
// locate work has produced a valid ray; this never creates an input event.
static void questxr_notify_activity_saf_pose_ready(JNIEnv *env) {
    if (!env || !questxr_activity) return;
    jclass activity_class = (*env)->GetObjectClass(env, questxr_activity);
    if (!activity_class) return;
    jmethodID method = (*env)->GetMethodID(env, activity_class,
        "onQuestXrSafPoseReady", "()V");
    if (method) {
        (*env)->CallVoidMethod(env, questxr_activity, method);
        if ((*env)->ExceptionCheck(env)) (*env)->ExceptionClear(env);
    }
    (*env)->DeleteLocalRef(env, activity_class);
}

static GLuint questxr_compile_shader(GLenum type, const char *source) {
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    GLint compiled = GL_FALSE;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if (!compiled) {
        char log[512] = {0};
        glGetShaderInfoLog(shader, sizeof(log), NULL, log);
        XR_LOG("panel shader compile failed: %s", log);
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

static XrVector3f questxr_rotate_vector(XrQuaternionf q, XrVector3f v) {
    XrVector3f t = {
        2.0f * (q.y * v.z - q.z * v.y),
        2.0f * (q.z * v.x - q.x * v.z),
        2.0f * (q.x * v.y - q.y * v.x),
    };
    XrVector3f result = {
        v.x + q.w * t.x + (q.y * t.z - q.z * t.y),
        v.y + q.w * t.y + (q.z * t.x - q.x * t.z),
        v.z + q.w * t.z + (q.x * t.y - q.y * t.x),
    };
    return result;
}

static XrQuaternionf questxr_multiply_quaternions(
    XrQuaternionf a, XrQuaternionf b) {
    XrQuaternionf result = {
        a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
        a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
        a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
        a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,
    };
    return result;
}

static XrPosef questxr_compose_poses(XrPosef parent, XrPosef child) {
    XrVector3f offset = questxr_rotate_vector(
        parent.orientation, child.position);
    XrPosef result = {
        questxr_multiply_quaternions(parent.orientation, child.orientation),
        {
            parent.position.x + offset.x,
            parent.position.y + offset.y,
            parent.position.z + offset.z,
        },
    };
    return result;
}

typedef struct QuestxrRayHit {
    int active;
    float u;
    float v;
    uint64_t location_flags;
} QuestxrRayHit;

// Project one tracked Touch aim pose onto the same panel pose used by the
// compositor. This gives the selected hand's Lua cursor and its visible panel
// endpoint one source of truth.
static QuestxrRayHit questxr_project_ray(PFN_xrLocateSpace locate_space,
    XrSpace pointer_space, int pose_active, XrSpace view_space,
    XrTime display_time, XrPosef panel_pose) {
    QuestxrRayHit result = {0, 0.0f, 0.0f, 0};
    if (!pose_active || pointer_space == XR_NULL_HANDLE) return result;
    XrSpaceLocation aim = { XR_TYPE_SPACE_LOCATION };
    if (XR_FAILED(locate_space(pointer_space, view_space, display_time, &aim))
            || !(aim.locationFlags & XR_SPACE_LOCATION_POSITION_VALID_BIT)
            || !(aim.locationFlags & XR_SPACE_LOCATION_ORIENTATION_VALID_BIT))
        return result;
    result.location_flags = aim.locationFlags;
    XrVector3f direction = questxr_rotate_vector(
        aim.pose.orientation, (XrVector3f) {0.0f, 0.0f, -1.0f});
    XrVector3f normal = questxr_rotate_vector(
        panel_pose.orientation, (XrVector3f) {0.0f, 0.0f, 1.0f});
    XrVector3f to_panel = {
        panel_pose.position.x - aim.pose.position.x,
        panel_pose.position.y - aim.pose.position.y,
        panel_pose.position.z - aim.pose.position.z,
    };
    float denominator = questxr_dot(direction, normal);
    if (fabsf(denominator) <= 0.0001f) return result;
    float distance = questxr_dot(to_panel, normal) / denominator;
    if (distance <= 0.0f) return result;
    XrVector3f hit_delta = {
        aim.pose.position.x + direction.x * distance - panel_pose.position.x,
        aim.pose.position.y + direction.y * distance - panel_pose.position.y,
        aim.pose.position.z + direction.z * distance - panel_pose.position.z,
    };
    XrVector3f right = questxr_rotate_vector(panel_pose.orientation,
        (XrVector3f) {1.0f, 0.0f, 0.0f});
    XrVector3f up = questxr_rotate_vector(panel_pose.orientation,
        (XrVector3f) {0.0f, 1.0f, 0.0f});
    result.u = questxr_dot(hit_delta, right) / 1.55f + 0.5f;
    result.v = questxr_dot(hit_delta, up) / 1.1625f + 0.5f;
    result.active = result.u >= 0.0f && result.u <= 1.0f
                 && result.v >= 0.0f && result.v <= 1.0f;
    return result;
}

static void *questxr_native_bootstrap(void *unused) {
    (void) unused;
    questxr_bootstrap_stopped = 0;
    JNIEnv *env = NULL;
    int attached = 0;
    EGLDisplay display = EGL_NO_DISPLAY;
    EGLContext context = EGL_NO_CONTEXT;
    EGLSurface surface = EGL_NO_SURFACE;
    void *loader = NULL;
    XrInstance instance = XR_NULL_HANDLE;
    XrSession session = XR_NULL_HANDLE;
    XrSpace space = XR_NULL_HANDLE;
    XrSpace view_space = XR_NULL_HANDLE;
    XrSwapchain quad_swapchain = XR_NULL_HANDLE;
    XrSwapchain background_swapchains[2] = {
        XR_NULL_HANDLE, XR_NULL_HANDLE
    };
    XrActionSet action_set = XR_NULL_HANDLE;
    XrAction left_stick_action = XR_NULL_HANDLE;
    XrAction right_stick_action = XR_NULL_HANDLE;
    XrAction left_select_action = XR_NULL_HANDLE;
    XrAction right_select_action = XR_NULL_HANDLE;
    XrAction back_action = XR_NULL_HANDLE;
    XrAction left_pointer_pose_action = XR_NULL_HANDLE;
    XrAction right_pointer_pose_action = XR_NULL_HANDLE;
    XrSpace left_pointer_space = XR_NULL_HANDLE;
    XrSpace right_pointer_space = XR_NULL_HANDLE;
    XrSwapchainImageOpenGLESKHR *quad_images = NULL;
    uint32_t quad_image_count = 0;
    XrSwapchainImageOpenGLESKHR *background_images[2] = { NULL, NULL };
    uint32_t background_image_counts[2] = { 0, 0 };
    uint32_t background_widths[2] = { 0, 0 };
    uint32_t background_heights[2] = { 0, 0 };
    GLuint quad_fbo = 0;
    GLuint background_fbo = 0;
    GLuint panel_texture = 0;
    GLuint panel_program = 0;
    GLuint panel_vbo = 0;
    uint64_t uploaded_panel_generation = 0;
    int running = 0;
    int white_environment_enabled = 0;
    int white_environment_eligible = 0;
    int white_environment_wait_logged = 0;
    uint32_t max_layer_count = 0;
    XrViewConfigurationView projection_config_views[2] = {0};
    uint32_t projection_view_count = 0;
    int projection_config_valid = 0;
    uint64_t submitted_frames = 0;
    PFN_xrGetInstanceProcAddr get_proc = NULL;
    PFN_xrInitializeLoaderKHR xrInitializeLoaderKHR = NULL;
    PFN_xrEnumerateInstanceExtensionProperties xrEnumerateInstanceExtensionProperties = NULL;
    PFN_xrCreateInstance xrCreateInstance = NULL;
    PFN_xrGetSystem xrGetSystem = NULL;
    PFN_xrGetSystemProperties xrGetSystemProperties = NULL;
    PFN_xrEnumerateEnvironmentBlendModes xrEnumerateEnvironmentBlendModes = NULL;
    PFN_xrEnumerateViewConfigurationViews xrEnumerateViewConfigurationViews = NULL;
    PFN_xrGetOpenGLESGraphicsRequirementsKHR xrGetOpenGLESGraphicsRequirementsKHR = NULL;
    PFN_xrCreateSession xrCreateSession = NULL;
    PFN_xrCreateReferenceSpace xrCreateReferenceSpace = NULL;
    PFN_xrLocateSpace xrLocateSpace = NULL;
    PFN_xrLocateViews xrLocateViews = NULL;
    PFN_xrPollEvent xrPollEvent = NULL;
    PFN_xrBeginSession xrBeginSession = NULL;
    PFN_xrEndSession xrEndSession = NULL;
    PFN_xrRequestExitSession xrRequestExitSession = NULL;
    PFN_xrWaitFrame xrWaitFrame = NULL;
    PFN_xrBeginFrame xrBeginFrame = NULL;
    PFN_xrEndFrame xrEndFrame = NULL;
    PFN_xrDestroySpace xrDestroySpace = NULL;
    PFN_xrDestroySession xrDestroySession = NULL;
    PFN_xrDestroyInstance xrDestroyInstance = NULL;
    PFN_xrEnumerateSwapchainFormats xrEnumerateSwapchainFormats = NULL;
    PFN_xrCreateSwapchain xrCreateSwapchain = NULL;
    PFN_xrEnumerateSwapchainImages xrEnumerateSwapchainImages = NULL;
    PFN_xrAcquireSwapchainImage xrAcquireSwapchainImage = NULL;
    PFN_xrWaitSwapchainImage xrWaitSwapchainImage = NULL;
    PFN_xrReleaseSwapchainImage xrReleaseSwapchainImage = NULL;
    PFN_xrDestroySwapchain xrDestroySwapchain = NULL;
    PFN_xrStringToPath xrStringToPath = NULL;
    PFN_xrCreateActionSet xrCreateActionSet = NULL;
    PFN_xrCreateAction xrCreateAction = NULL;
    PFN_xrSuggestInteractionProfileBindings xrSuggestInteractionProfileBindings = NULL;
    PFN_xrAttachSessionActionSets xrAttachSessionActionSets = NULL;
    PFN_xrSyncActions xrSyncActions = NULL;
    PFN_xrGetActionStateBoolean xrGetActionStateBoolean = NULL;
    PFN_xrGetActionStateVector2f xrGetActionStateVector2f = NULL;
    PFN_xrGetActionStatePose xrGetActionStatePose = NULL;
    PFN_xrCreateActionSpace xrCreateActionSpace = NULL;
    PFN_xrDestroyActionSet xrDestroyActionSet = NULL;

    if (!questxr_vm || !questxr_activity) XR_FAIL("Android context unavailable");
    if ((*questxr_vm)->GetEnv(questxr_vm, (void **) &env, JNI_VERSION_1_6) != JNI_OK) {
        if ((*questxr_vm)->AttachCurrentThread(questxr_vm, &env, NULL) != JNI_OK)
            XR_FAIL("could not attach bootstrap thread");
        attached = 1;
    }

    display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if (display == EGL_NO_DISPLAY || !eglInitialize(display, NULL, NULL))
        XR_FAIL("eglInitialize");
    const EGLint config_attrs[] = {
        EGL_RENDERABLE_TYPE, EGL_OPENGL_ES3_BIT,
        EGL_SURFACE_TYPE, EGL_PBUFFER_BIT,
        EGL_RED_SIZE, 8, EGL_GREEN_SIZE, 8, EGL_BLUE_SIZE, 8, EGL_ALPHA_SIZE, 8,
        EGL_NONE
    };
    EGLConfig config = NULL;
    EGLint config_count = 0;
    if (!eglChooseConfig(display, config_attrs, &config, 1, &config_count)
            || config_count != 1) XR_FAIL("eglChooseConfig");
    const EGLint context_attrs[] = { EGL_CONTEXT_CLIENT_VERSION, 3, EGL_NONE };
    context = eglCreateContext(display, config, EGL_NO_CONTEXT, context_attrs);
    const EGLint surface_attrs[] = { EGL_WIDTH, 16, EGL_HEIGHT, 16, EGL_NONE };
    surface = eglCreatePbufferSurface(display, config, surface_attrs);
    if (context == EGL_NO_CONTEXT || surface == EGL_NO_SURFACE
            || !eglMakeCurrent(display, surface, surface, context))
        XR_FAIL("private GLES context");

    loader = dlopen("libopenxr_loader.so", RTLD_NOW | RTLD_LOCAL);
    if (!loader) XR_FAIL(dlerror());
    get_proc = (PFN_xrGetInstanceProcAddr) dlsym(loader, "xrGetInstanceProcAddr");
    if (!get_proc) XR_FAIL("xrGetInstanceProcAddr");

#define XR_PROC(scope, name) \
    if (XR_FAILED(get_proc(scope, #name, (PFN_xrVoidFunction *) &name)) || !name) \
        XR_FAIL(#name)
    XR_PROC(XR_NULL_HANDLE, xrEnumerateInstanceExtensionProperties);
    XR_PROC(XR_NULL_HANDLE, xrInitializeLoaderKHR);
    XrLoaderInitInfoAndroidKHR loader_info = { XR_TYPE_LOADER_INIT_INFO_ANDROID_KHR };
    loader_info.applicationVM = questxr_vm;
    loader_info.applicationContext = questxr_activity;
    if (XR_FAILED(xrInitializeLoaderKHR((const XrLoaderInitInfoBaseHeaderKHR *) &loader_info)))
        XR_FAIL("xrInitializeLoaderKHR");

    // Capability-only probe for a future full-environment renderer. It does
    // not enable an extension, allocate an environment swapchain, or change
    // the verified single-panel submission path.
    uint32_t extension_count = 0;
    int supports_equirect = 0;
    int supports_equirect2 = 0;
    int supports_cube = 0;
    int supports_opaque = 0;
    if (XR_SUCCEEDED(xrEnumerateInstanceExtensionProperties(
            NULL, 0, &extension_count, NULL)) && extension_count > 0) {
        XrExtensionProperties *extension_properties = (XrExtensionProperties *)
            calloc(extension_count, sizeof(XrExtensionProperties));
        if (extension_properties) {
            for (uint32_t i = 0; i < extension_count; i++)
                extension_properties[i].type = XR_TYPE_EXTENSION_PROPERTIES;
            if (XR_SUCCEEDED(xrEnumerateInstanceExtensionProperties(
                    NULL, extension_count, &extension_count, extension_properties))) {
                for (uint32_t i = 0; i < extension_count; i++) {
                    const char *name = extension_properties[i].extensionName;
                    supports_equirect |= strcmp(name,
                        XR_KHR_COMPOSITION_LAYER_EQUIRECT_EXTENSION_NAME) == 0;
                    supports_equirect2 |= strcmp(name,
                        XR_KHR_COMPOSITION_LAYER_EQUIRECT2_EXTENSION_NAME) == 0;
                    supports_cube |= strcmp(name,
                        XR_KHR_COMPOSITION_LAYER_CUBE_EXTENSION_NAME) == 0;
                }
            }
            free(extension_properties);
        }
    }
    XR_LOG("environment probe extensions count=%u equirect=%d equirect2=%d cube=%d; panel submit remains one layer",
        extension_count, supports_equirect, supports_equirect2, supports_cube);

    XR_PROC(XR_NULL_HANDLE, xrCreateInstance);
    const char *extensions[] = {
        XR_KHR_ANDROID_CREATE_INSTANCE_EXTENSION_NAME,
        XR_KHR_OPENGL_ES_ENABLE_EXTENSION_NAME,
    };
    XrInstanceCreateInfoAndroidKHR android_info = {
        XR_TYPE_INSTANCE_CREATE_INFO_ANDROID_KHR
    };
    android_info.applicationVM = questxr_vm;
    android_info.applicationActivity = questxr_activity;
    XrInstanceCreateInfo instance_info = { XR_TYPE_INSTANCE_CREATE_INFO };
    instance_info.next = &android_info;
    strcpy(instance_info.applicationInfo.applicationName, "Gen1Recomp Quest Bootstrap");
    strcpy(instance_info.applicationInfo.engineName, "LOVE");
    instance_info.applicationInfo.apiVersion = XR_CURRENT_API_VERSION;
    instance_info.enabledExtensionCount = 2;
    instance_info.enabledExtensionNames = extensions;
    if (XR_FAILED(xrCreateInstance(&instance_info, &instance)))
        XR_FAIL("xrCreateInstance");

    XR_PROC(instance, xrGetSystem);
    XR_PROC(instance, xrGetSystemProperties);
    XR_PROC(instance, xrEnumerateEnvironmentBlendModes);
    XR_PROC(instance, xrEnumerateViewConfigurationViews);
    XR_PROC(instance, xrGetOpenGLESGraphicsRequirementsKHR);
    XR_PROC(instance, xrCreateSession);
    XR_PROC(instance, xrCreateReferenceSpace);
    XR_PROC(instance, xrLocateSpace);
    XR_PROC(instance, xrLocateViews);
    XR_PROC(instance, xrPollEvent);
    XR_PROC(instance, xrBeginSession);
    XR_PROC(instance, xrEndSession);
    XR_PROC(instance, xrRequestExitSession);
    XR_PROC(instance, xrWaitFrame);
    XR_PROC(instance, xrBeginFrame);
    XR_PROC(instance, xrEndFrame);
    XR_PROC(instance, xrDestroySpace);
    XR_PROC(instance, xrDestroySession);
    XR_PROC(instance, xrDestroyInstance);
    XR_PROC(instance, xrEnumerateSwapchainFormats);
    XR_PROC(instance, xrCreateSwapchain);
    XR_PROC(instance, xrEnumerateSwapchainImages);
    XR_PROC(instance, xrAcquireSwapchainImage);
    XR_PROC(instance, xrWaitSwapchainImage);
    XR_PROC(instance, xrReleaseSwapchainImage);
    XR_PROC(instance, xrDestroySwapchain);
    XR_PROC(instance, xrStringToPath);
    XR_PROC(instance, xrCreateActionSet);
    XR_PROC(instance, xrCreateAction);
    XR_PROC(instance, xrSuggestInteractionProfileBindings);
    XR_PROC(instance, xrAttachSessionActionSets);
    XR_PROC(instance, xrSyncActions);
    XR_PROC(instance, xrGetActionStateBoolean);
    XR_PROC(instance, xrGetActionStateVector2f);
    XR_PROC(instance, xrGetActionStatePose);
    XR_PROC(instance, xrCreateActionSpace);
    XR_PROC(instance, xrDestroyActionSet);

    XrSystemGetInfo system_info = { XR_TYPE_SYSTEM_GET_INFO };
    system_info.formFactor = XR_FORM_FACTOR_HEAD_MOUNTED_DISPLAY;
    XrSystemId system_id = XR_NULL_SYSTEM_ID;
    if (XR_FAILED(xrGetSystem(instance, &system_info, &system_id))) XR_FAIL("xrGetSystem");
    XrSystemProperties system_properties = { XR_TYPE_SYSTEM_PROPERTIES };
    if (XR_SUCCEEDED(xrGetSystemProperties(instance, system_id, &system_properties))) {
        max_layer_count = system_properties.graphicsProperties.maxLayerCount;
        XR_LOG("environment probe system maxLayers=%u maxSwapchain=%ux%u",
            system_properties.graphicsProperties.maxLayerCount,
            system_properties.graphicsProperties.maxSwapchainImageWidth,
            system_properties.graphicsProperties.maxSwapchainImageHeight);
    } else {
        XR_LOG("environment probe xrGetSystemProperties failed");
    }
    uint32_t blend_mode_count = 0;
    if (XR_SUCCEEDED(xrEnumerateEnvironmentBlendModes(instance, system_id,
            XR_VIEW_CONFIGURATION_TYPE_PRIMARY_STEREO, 0, &blend_mode_count, NULL))) {
        XrEnvironmentBlendMode blend_modes[8] = {0};
        if (blend_mode_count > 0 && blend_mode_count <= 8
                && XR_SUCCEEDED(xrEnumerateEnvironmentBlendModes(instance, system_id,
                    XR_VIEW_CONFIGURATION_TYPE_PRIMARY_STEREO, blend_mode_count,
                    &blend_mode_count, blend_modes))) {
            for (uint32_t i = 0; i < blend_mode_count; i++)
                supports_opaque |= blend_modes[i] == XR_ENVIRONMENT_BLEND_MODE_OPAQUE;
        }
        XR_LOG("environment probe primary-stereo blendModes=%u opaque=%d",
            blend_mode_count, supports_opaque);
    } else {
        XR_LOG("environment probe xrEnumerateEnvironmentBlendModes failed");
    }
    if (XR_SUCCEEDED(xrEnumerateViewConfigurationViews(instance, system_id,
            XR_VIEW_CONFIGURATION_TYPE_PRIMARY_STEREO, 0, &projection_view_count, NULL))) {
        int queried_views = projection_view_count == 2;
        if (queried_views) {
            for (uint32_t i = 0; i < projection_view_count; i++)
                projection_config_views[i].type = XR_TYPE_VIEW_CONFIGURATION_VIEW;
            queried_views = XR_SUCCEEDED(xrEnumerateViewConfigurationViews(instance,
                system_id, XR_VIEW_CONFIGURATION_TYPE_PRIMARY_STEREO,
                projection_view_count, &projection_view_count, projection_config_views));
        }
        XR_LOG("environment probe primary-stereo projectionViews=%u queried=%d",
            projection_view_count, queried_views);
        projection_config_valid = queried_views;
    } else {
        XR_LOG("environment probe xrEnumerateViewConfigurationViews failed");
    }
    white_environment_eligible = max_layer_count >= 2 && supports_opaque
        && projection_view_count == 2 && projection_config_valid;
    XrGraphicsRequirementsOpenGLESKHR requirements = {
        XR_TYPE_GRAPHICS_REQUIREMENTS_OPENGL_ES_KHR
    };
    if (XR_FAILED(xrGetOpenGLESGraphicsRequirementsKHR(instance, system_id, &requirements)))
        XR_FAIL("xrGetOpenGLESGraphicsRequirementsKHR");

    XrActionSetCreateInfo action_set_info = { XR_TYPE_ACTION_SET_CREATE_INFO };
    strcpy(action_set_info.actionSetName, "launcher");
    strcpy(action_set_info.localizedActionSetName, "Launcher controls");
    action_set_info.priority = 0;
    if (XR_FAILED(xrCreateActionSet(instance, &action_set_info, &action_set)))
        XR_FAIL("xrCreateActionSet");
#define CREATE_ACTION(handle, internal_name, label, action_type) do { \
    XrActionCreateInfo info = { XR_TYPE_ACTION_CREATE_INFO }; \
    info.actionType = action_type; \
    strcpy(info.actionName, internal_name); \
    strcpy(info.localizedActionName, label); \
    if (XR_FAILED(xrCreateAction(action_set, &info, &handle))) \
        XR_FAIL("xrCreateAction(" internal_name ")"); \
} while (0)
    CREATE_ACTION(left_stick_action, "left_stick", "Left stick", XR_ACTION_TYPE_VECTOR2F_INPUT);
    CREATE_ACTION(right_stick_action, "right_stick", "Right stick", XR_ACTION_TYPE_VECTOR2F_INPUT);
    // Keep each hand's Select action separate. The active pointing hand is the
    // only hand allowed to activate a launcher control in a frame.
    CREATE_ACTION(left_select_action, "left_select", "Left select", XR_ACTION_TYPE_BOOLEAN_INPUT);
    CREATE_ACTION(right_select_action, "right_select", "Right select", XR_ACTION_TYPE_BOOLEAN_INPUT);
    CREATE_ACTION(back_action, "back", "Back", XR_ACTION_TYPE_BOOLEAN_INPUT);
    CREATE_ACTION(left_pointer_pose_action, "left_pointer_pose", "Left pointer pose",
                  XR_ACTION_TYPE_POSE_INPUT);
    CREATE_ACTION(right_pointer_pose_action, "right_pointer_pose", "Right pointer pose",
                  XR_ACTION_TYPE_POSE_INPUT);
#undef CREATE_ACTION
    XrPath touch_profile = XR_NULL_PATH;
    XrPath binding_paths[10] = {0};
    const char *binding_names[10] = {
        "/user/hand/left/input/thumbstick",
        "/user/hand/right/input/thumbstick",
        "/user/hand/left/input/x/click",
        "/user/hand/right/input/a/click",
        "/user/hand/left/input/trigger/value",
        "/user/hand/right/input/trigger/value",
        "/user/hand/left/input/y/click",
        "/user/hand/right/input/b/click",
        "/user/hand/left/input/aim/pose",
        "/user/hand/right/input/aim/pose",
    };
    if (XR_FAILED(xrStringToPath(instance,
            "/interaction_profiles/oculus/touch_controller", &touch_profile)))
        XR_FAIL("xrStringToPath(touch profile)");
    for (uint32_t i = 0; i < 10; i++) {
        if (XR_FAILED(xrStringToPath(instance, binding_names[i], &binding_paths[i])))
            XR_FAIL("xrStringToPath(binding)");
    }
    XrActionSuggestedBinding bindings[] = {
        { left_stick_action, binding_paths[0] },
        { right_stick_action, binding_paths[1] },
        { left_select_action, binding_paths[2] },
        { right_select_action, binding_paths[3] },
        { left_select_action, binding_paths[4] },
        { right_select_action, binding_paths[5] },
        { back_action, binding_paths[6] },
        { back_action, binding_paths[7] },
        { left_pointer_pose_action, binding_paths[8] },
        { right_pointer_pose_action, binding_paths[9] },
    };
    XrInteractionProfileSuggestedBinding suggested = {
        XR_TYPE_INTERACTION_PROFILE_SUGGESTED_BINDING
    };
    suggested.interactionProfile = touch_profile;
    suggested.countSuggestedBindings = sizeof(bindings) / sizeof(bindings[0]);
    suggested.suggestedBindings = bindings;
    if (XR_FAILED(xrSuggestInteractionProfileBindings(instance, &suggested)))
        XR_FAIL("xrSuggestInteractionProfileBindings");

    XrGraphicsBindingOpenGLESAndroidKHR binding = {
        XR_TYPE_GRAPHICS_BINDING_OPENGL_ES_ANDROID_KHR
    };
    binding.display = display;
    binding.config = config;
    binding.context = context;
    XrSessionCreateInfo session_info = { XR_TYPE_SESSION_CREATE_INFO };
    session_info.next = &binding;
    session_info.systemId = system_id;
    if (XR_FAILED(xrCreateSession(instance, &session_info, &session)))
        XR_FAIL("xrCreateSession");
    XrSessionActionSetsAttachInfo attach_info = {
        XR_TYPE_SESSION_ACTION_SETS_ATTACH_INFO
    };
    attach_info.countActionSets = 1;
    attach_info.actionSets = &action_set;
    if (XR_FAILED(xrAttachSessionActionSets(session, &attach_info)))
        XR_FAIL("xrAttachSessionActionSets");
    XrActionSpaceCreateInfo pointer_space_info = {
        XR_TYPE_ACTION_SPACE_CREATE_INFO
    };
    pointer_space_info.action = left_pointer_pose_action;
    pointer_space_info.poseInActionSpace.orientation.w = 1.0f;
    if (XR_FAILED(xrCreateActionSpace(session, &pointer_space_info,
                                      &left_pointer_space)))
        XR_FAIL("xrCreateActionSpace(left pointer)");
    pointer_space_info.action = right_pointer_pose_action;
    if (XR_FAILED(xrCreateActionSpace(session, &pointer_space_info,
                                      &right_pointer_space)))
        XR_FAIL("xrCreateActionSpace(right pointer)");
    XR_LOG("Quest Touch launcher actions attached");
    XrReferenceSpaceCreateInfo space_info = { XR_TYPE_REFERENCE_SPACE_CREATE_INFO };
    space_info.referenceSpaceType = XR_REFERENCE_SPACE_TYPE_LOCAL;
    space_info.poseInReferenceSpace.orientation.w = 1.0f;
    if (XR_FAILED(xrCreateReferenceSpace(session, &space_info, &space)))
        XR_FAIL("xrCreateReferenceSpace(local)");
    space_info.referenceSpaceType = XR_REFERENCE_SPACE_TYPE_VIEW;
    if (XR_FAILED(xrCreateReferenceSpace(session, &space_info, &view_space)))
        XR_FAIL("xrCreateReferenceSpace(view)");

    uint32_t format_count = 0;
    if (XR_FAILED(xrEnumerateSwapchainFormats(session, 0, &format_count, NULL))
            || format_count == 0) XR_FAIL("xrEnumerateSwapchainFormats");
    int64_t *formats = (int64_t *) calloc(format_count, sizeof(int64_t));
    if (!formats) XR_FAIL("swapchain format allocation");
    if (XR_FAILED(xrEnumerateSwapchainFormats(
            session, format_count, &format_count, formats))) {
        free(formats);
        XR_FAIL("xrEnumerateSwapchainFormats values");
    }
    int64_t quad_format = formats[0];
    for (uint32_t i = 0; i < format_count; i++) {
        if (formats[i] == GL_SRGB8_ALPHA8 || formats[i] == GL_RGBA8) {
            quad_format = formats[i];
            break;
        }
    }
    free(formats);
    XrSwapchainCreateInfo swapchain_info = { XR_TYPE_SWAPCHAIN_CREATE_INFO };
    swapchain_info.usageFlags = XR_SWAPCHAIN_USAGE_COLOR_ATTACHMENT_BIT
                              | XR_SWAPCHAIN_USAGE_SAMPLED_BIT;
    swapchain_info.format = quad_format;
    swapchain_info.sampleCount = 1;
    swapchain_info.width = 1024;
    swapchain_info.height = 768;
    swapchain_info.faceCount = 1;
    swapchain_info.arraySize = 1;
    swapchain_info.mipCount = 1;
    if (XR_FAILED(xrCreateSwapchain(session, &swapchain_info, &quad_swapchain)))
        XR_FAIL("xrCreateSwapchain(quad)");
    if (XR_FAILED(xrEnumerateSwapchainImages(
            quad_swapchain, 0, &quad_image_count, NULL)) || quad_image_count == 0)
        XR_FAIL("xrEnumerateSwapchainImages count");
    quad_images = (XrSwapchainImageOpenGLESKHR *)
        calloc(quad_image_count, sizeof(XrSwapchainImageOpenGLESKHR));
    if (!quad_images) XR_FAIL("quad image allocation");
    for (uint32_t i = 0; i < quad_image_count; i++)
        quad_images[i].type = XR_TYPE_SWAPCHAIN_IMAGE_OPENGL_ES_KHR;
    if (XR_FAILED(xrEnumerateSwapchainImages(
            quad_swapchain, quad_image_count, &quad_image_count,
            (XrSwapchainImageBaseHeader *) quad_images)))
        XR_FAIL("xrEnumerateSwapchainImages values");

    // The white surround is a standard stereo projection layer. It is kept
    // deliberately tiny because every texel has the same opaque white value;
    // the projection layer maps it across each eye's full FOV. This avoids an
    // equirect/cube extension and prevents an unbounded second scene buffer.
    if (white_environment_eligible) {
        int background_setup_ok = 1;
        for (uint32_t eye = 0; eye < 2; eye++) {
            background_widths[eye] = projection_config_views[eye].maxImageRectWidth < 16
                ? projection_config_views[eye].maxImageRectWidth : 16;
            background_heights[eye] = projection_config_views[eye].maxImageRectHeight < 16
                ? projection_config_views[eye].maxImageRectHeight : 16;
            if (background_widths[eye] == 0 || background_heights[eye] == 0) {
                XR_LOG("white environment has no usable projection extent eye=%u", eye);
                background_setup_ok = 0;
                break;
            }
            XrSwapchainCreateInfo background_info = { XR_TYPE_SWAPCHAIN_CREATE_INFO };
            background_info.usageFlags = XR_SWAPCHAIN_USAGE_COLOR_ATTACHMENT_BIT;
            background_info.format = quad_format;
            background_info.sampleCount = 1;
            background_info.width = background_widths[eye];
            background_info.height = background_heights[eye];
            background_info.faceCount = 1;
            background_info.arraySize = 1;
            background_info.mipCount = 1;
            if (XR_FAILED(xrCreateSwapchain(session, &background_info,
                                             &background_swapchains[eye]))) {
                XR_LOG("white environment swapchain create failed eye=%u", eye);
                background_setup_ok = 0;
                break;
            }
            if (XR_FAILED(xrEnumerateSwapchainImages(background_swapchains[eye], 0,
                    &background_image_counts[eye], NULL))
                    || background_image_counts[eye] == 0) {
                XR_LOG("white environment image count failed eye=%u", eye);
                background_setup_ok = 0;
                break;
            }
            background_images[eye] = (XrSwapchainImageOpenGLESKHR *) calloc(
                background_image_counts[eye], sizeof(XrSwapchainImageOpenGLESKHR));
            if (!background_images[eye]) {
                XR_LOG("white environment image allocation failed eye=%u", eye);
                background_setup_ok = 0;
                break;
            }
            for (uint32_t image = 0; image < background_image_counts[eye]; image++)
                background_images[eye][image].type = XR_TYPE_SWAPCHAIN_IMAGE_OPENGL_ES_KHR;
            if (XR_FAILED(xrEnumerateSwapchainImages(background_swapchains[eye],
                    background_image_counts[eye], &background_image_counts[eye],
                    (XrSwapchainImageBaseHeader *) background_images[eye]))) {
                XR_LOG("white environment image enumeration failed eye=%u", eye);
                background_setup_ok = 0;
                break;
            }
        }
        if (background_setup_ok) {
            glGenFramebuffers(1, &background_fbo);
            if (background_fbo) {
                white_environment_enabled = 1;
                XR_LOG("white environment renderer armed views=2 size=%ux%u,%ux%u",
                    background_widths[0], background_heights[0],
                    background_widths[1], background_heights[1]);
            }
        }
        if (!white_environment_enabled) {
            XR_LOG("white environment renderer unavailable; keeping one panel layer");
            for (uint32_t eye = 0; eye < 2; eye++) {
                free(background_images[eye]);
                background_images[eye] = NULL;
                if (background_swapchains[eye] != XR_NULL_HANDLE) {
                    xrDestroySwapchain(background_swapchains[eye]);
                    background_swapchains[eye] = XR_NULL_HANDLE;
                }
            }
        }
    } else {
        XR_LOG("white environment renderer unsupported; keeping one panel layer");
    }
    glGenFramebuffers(1, &quad_fbo);
    glGenTextures(1, &panel_texture);
    glBindTexture(GL_TEXTURE_2D, panel_texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, 1024, 768, 0,
                 GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    const char *vertex_source =
        "#version 300 es\n"
        "layout(location=0) in vec2 position;\n"
        "layout(location=1) in vec2 uv;\n"
        "out vec2 texcoord;\n"
        "void main(){ gl_Position=vec4(position,0.0,1.0); texcoord=uv; }\n";
    const char *fragment_source =
        "#version 300 es\n"
        "precision mediump float;\n"
        "in vec2 texcoord; layout(location=0) out vec4 color;\n"
        "uniform sampler2D panel;\n"
        "uniform vec4 focusRect;\n"
        "uniform vec3 pointerState;\n"
        "void main(){\n"
        " color=texture(panel,texcoord);\n"
        " if(focusRect.x>=0.0){\n"
        "  vec2 p=texcoord-focusRect.xy; vec2 s=focusRect.zw;\n"
        "  float inside=step(0.0,p.x)*step(0.0,p.y)*step(p.x,s.x)*step(p.y,s.y);\n"
        "  float edge=inside*(1.0-step(0.005,min(min(p.x,p.y),min(s.x-p.x,s.y-p.y))));\n"
        "  color=mix(color,vec4(0.15,1.0,0.30,1.0),edge);\n"
        " }\n"
        " if(pointerState.z>0.5){\n"
        "  vec2 d=(texcoord-pointerState.xy)*vec2(textureSize(panel,0));\n"
        "  float r=length(d);\n"
        "  float aa=max(fwidth(r),0.65);\n"
        "  float dot=1.0-smoothstep(3.5-aa,3.5+aa,r);\n"
        "  color=mix(color,vec4(1.0,1.0,1.0,1.0),dot);\n"
        " }\n"
        "}\n";
    GLuint vertex_shader = questxr_compile_shader(GL_VERTEX_SHADER, vertex_source);
    GLuint fragment_shader = questxr_compile_shader(GL_FRAGMENT_SHADER, fragment_source);
    if (!vertex_shader || !fragment_shader) XR_FAIL("panel shaders");
    panel_program = glCreateProgram();
    glAttachShader(panel_program, vertex_shader);
    glAttachShader(panel_program, fragment_shader);
    glLinkProgram(panel_program);
    glDeleteShader(vertex_shader);
    glDeleteShader(fragment_shader);
    GLint linked = GL_FALSE;
    glGetProgramiv(panel_program, GL_LINK_STATUS, &linked);
    if (!linked) XR_FAIL("panel shader link");
    glUseProgram(panel_program);
    glUniform1i(glGetUniformLocation(panel_program, "panel"), 0);
    const GLfloat panel_vertices[] = {
        -1.f, -1.f, 0.f, 0.f,  1.f, -1.f, 1.f, 0.f,
        -1.f,  1.f, 0.f, 1.f,  1.f,  1.f, 1.f, 1.f,
    };
    glGenBuffers(1, &panel_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, panel_vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(panel_vertices), panel_vertices, GL_STATIC_DRAW);
    XR_LOG("native bootstrap session created");

    XrPosef panel_pose = {0};
    panel_pose.orientation.w = 1.0f;
    panel_pose.position.z = -1.35f;
    int panel_anchored = 0;
    const int room_anchor_enabled = 1;
    uint64_t anchor_after_frame = 180;
    int exit_requested = 0;
    int active_pointer_hand = 0; // 1 left, 2 right; right wins an exact first-frame tie.
    float last_left_u = 0.0f, last_left_v = 0.0f;
    float last_right_u = 0.0f, last_right_v = 0.0f;
    int had_left_ray = 0, had_right_ray = 0;
    unsigned int seen_saf_generation = atomic_load(&questxr_saf_return_generation);
    unsigned int diagnostic_saf_generation = 0;
    uint64_t diagnostic_last_frame = 0;
    int diagnostic_last_sync = -1;
    int diagnostic_last_left_pose = -1;
    int diagnostic_last_right_pose = -1;
    int diagnostic_last_left_hit = -1;
    int diagnostic_last_right_hit = -1;
    int diagnostic_last_owner = -1;
    uint64_t diagnostic_last_compositor_frame = 0;
    uint64_t diagnostic_last_panel_generation = (uint64_t) -1;
    int diagnostic_last_panel_requested = -1;
    int diagnostic_last_panel_effective = -1;
    unsigned int saf_pose_pending_generation = 0;

    for (;;) {
        unsigned int saf_generation = atomic_load(&questxr_saf_return_generation);
        if (saf_generation != seen_saf_generation) {
            seen_saf_generation = saf_generation;
            diagnostic_saf_generation = saf_generation;
            diagnostic_last_frame = 0;
            diagnostic_last_sync = -1;
            diagnostic_last_left_pose = -1;
            diagnostic_last_right_pose = -1;
            diagnostic_last_left_hit = -1;
            diagnostic_last_right_hit = -1;
            diagnostic_last_owner = -1;
            diagnostic_last_compositor_frame = 0;
            diagnostic_last_panel_generation = (uint64_t) -1;
            diagnostic_last_panel_requested = -1;
            diagnostic_last_panel_effective = -1;
            saf_pose_pending_generation = saf_generation;
            XR_LOG("SAF action diagnostics armed generation=%u", saf_generation);
        }
        if (questxr_bootstrap_shutdown_requested && !exit_requested) {
            XR_LOG("launcher OpenXR handoff requested");
            if (running && xrRequestExitSession) {
                XrResult exit_result = xrRequestExitSession(session);
                if (XR_FAILED(exit_result)) {
                    XR_LOG("xrRequestExitSession failed: %d", exit_result);
                    goto done;
                }
                exit_requested = 1;
                XR_LOG("launcher OpenXR exit requested");
            } else {
                goto done;
            }
        }
        XrEventDataBuffer event = { XR_TYPE_EVENT_DATA_BUFFER };
        while (xrPollEvent(instance, &event) == XR_SUCCESS) {
            if (event.type == XR_TYPE_EVENT_DATA_SESSION_STATE_CHANGED) {
                XrEventDataSessionStateChanged *changed =
                    (XrEventDataSessionStateChanged *) &event;
                if (changed->state == XR_SESSION_STATE_READY && !running) {
                    XrSessionBeginInfo begin = { XR_TYPE_SESSION_BEGIN_INFO };
                    begin.primaryViewConfigurationType =
                        XR_VIEW_CONFIGURATION_TYPE_PRIMARY_STEREO;
                    if (XR_SUCCEEDED(xrBeginSession(session, &begin))) {
                        running = 1;
                        XR_LOG("native bootstrap session running");
                    }
                } else if (changed->state == XR_SESSION_STATE_FOCUSED) {
                    XR_LOG("native OpenXR session focused");
                    questxr_notify_activity_session_focused(env);
                } else if (changed->state == XR_SESSION_STATE_STOPPING && running) {
                    xrEndSession(session);
                    running = 0;
                    if (exit_requested) {
                        XR_LOG("launcher OpenXR session ended for handoff");
                        goto done;
                    }
                } else if (changed->state == XR_SESSION_STATE_EXITING
                        || changed->state == XR_SESSION_STATE_LOSS_PENDING) {
                    goto done;
                }
            } else if (event.type ==
                       XR_TYPE_EVENT_DATA_REFERENCE_SPACE_CHANGE_PENDING) {
                // Quest emits this after a Meta-button recenter. Reacquire the
                // settled pose in the new LOCAL space rather than preserving
                // the old room anchor.
                panel_anchored = 0;
                anchor_after_frame = submitted_frames + 30;
                XR_LOG("launcher recenter requested by reference-space change");
            }
            event.type = XR_TYPE_EVENT_DATA_BUFFER;
            event.next = NULL;
        }
        if (!running) { usleep(1000); continue; }
        XrFrameState frame = { XR_TYPE_FRAME_STATE };
        XrResult frame_result = xrWaitFrame(session, NULL, &frame);
        if (XR_FAILED(frame_result)) {
            XR_LOG("xrWaitFrame failed: %d", frame_result);
            break;
        }
        frame_result = xrBeginFrame(session, NULL);
        if (XR_FAILED(frame_result)) {
            XR_LOG("xrBeginFrame failed: %d", frame_result);
            break;
        }
        // Input actions must be synchronized for every begun frame, including
        // frames where the runtime temporarily says not to render. DocumentsUI
        // returns can begin in that state; skipping this work left a focused
        // launcher with stale poses until the user pressed a trigger.
        XrActiveActionSet active_action_set = { action_set, XR_NULL_PATH };
        XrActionsSyncInfo sync_info = { XR_TYPE_ACTIONS_SYNC_INFO };
        sync_info.countActiveActionSets = 1;
        sync_info.activeActionSets = &active_action_set;
        int left_pointer_pose_active = 0;
        int right_pointer_pose_active = 0;
        int left_select_pressed = 0;
        int right_select_pressed = 0;
        uint32_t input_events = 0;
        XrResult action_sync_result = xrSyncActions(session, &sync_info);
        int action_sync_ok = XR_SUCCEEDED(action_sync_result);
        if (action_sync_ok) {
            XrActionStateGetInfo state_info = { XR_TYPE_ACTION_STATE_GET_INFO };
            XrActionStateVector2f left_stick = { XR_TYPE_ACTION_STATE_VECTOR2F };
            XrActionStateVector2f right_stick = { XR_TYPE_ACTION_STATE_VECTOR2F };
            state_info.action = left_stick_action;
            xrGetActionStateVector2f(session, &state_info, &left_stick);
            state_info.action = right_stick_action;
            xrGetActionStateVector2f(session, &state_info, &right_stick);
            XrActionStatePose pointer_pose_state = {
                XR_TYPE_ACTION_STATE_POSE
            };
            state_info.action = left_pointer_pose_action;
            if (XR_SUCCEEDED(xrGetActionStatePose(
                    session, &state_info, &pointer_pose_state)))
                left_pointer_pose_active = pointer_pose_state.isActive;
            pointer_pose_state = (XrActionStatePose) { XR_TYPE_ACTION_STATE_POSE };
            state_info.action = right_pointer_pose_action;
            if (XR_SUCCEEDED(xrGetActionStatePose(
                    session, &state_info, &pointer_pose_state)))
                right_pointer_pose_active = pointer_pose_state.isActive;
            static bool stick_emitted = false;
            float x = left_stick.isActive ? left_stick.currentState.x : 0.0f;
            float y = left_stick.isActive ? left_stick.currentState.y : 0.0f;
            questxr_set_pointer_axes(x, y);
            float magnitude2 = x * x + y * y;
            int new_direction = 0;
            // The right stick belongs to VR camera controls. Launcher
            // navigation uses one left-stick edge per deliberate flick.
            if (magnitude2 > 0.1225f && !stick_emitted) {
                if (fabsf(x) >= fabsf(y)) {
                    if (x > 0.35f) new_direction = QUESTXR_INPUT_RIGHT;
                    else if (x < -0.35f) new_direction = QUESTXR_INPUT_LEFT;
                } else {
                    if (y > 0.35f) new_direction = QUESTXR_INPUT_UP;
                    else if (y < -0.35f) new_direction = QUESTXR_INPUT_DOWN;
                }
            }
            if (new_direction) {
                input_events |= (uint32_t) new_direction;
                stick_emitted = true;
            } else if (magnitude2 < 0.04f) {
                stick_emitted = false;
            }
            XrActionStateBoolean button = { XR_TYPE_ACTION_STATE_BOOLEAN };
            state_info.action = left_select_action;
            if (XR_SUCCEEDED(xrGetActionStateBoolean(session, &state_info, &button)) &&
                    button.isActive && button.changedSinceLastSync && button.currentState)
                left_select_pressed = 1;
            button = (XrActionStateBoolean) { XR_TYPE_ACTION_STATE_BOOLEAN };
            state_info.action = right_select_action;
            if (XR_SUCCEEDED(xrGetActionStateBoolean(session, &state_info, &button)) &&
                    button.isActive && button.changedSinceLastSync && button.currentState)
                right_select_pressed = 1;
            button = (XrActionStateBoolean) { XR_TYPE_ACTION_STATE_BOOLEAN };
            state_info.action = back_action;
            if (XR_SUCCEEDED(xrGetActionStateBoolean(session, &state_info, &button)) &&
                    button.isActive && button.changedSinceLastSync && button.currentState)
                input_events |= QUESTXR_INPUT_BACK;
        }
        // Quest may recenter LOCAL space during the first focused frames. Keep
        // the panel in VIEW space briefly, then capture the settled head pose
        // so the room-space anchor does not jump out of view after startup.
        if (room_anchor_enabled && !panel_anchored &&
                submitted_frames >= anchor_after_frame) {
            XrSpaceLocation head = { XR_TYPE_SPACE_LOCATION };
            if (XR_SUCCEEDED(xrLocateSpace(view_space, space,
                                           frame.predictedDisplayTime, &head)) &&
                    (head.locationFlags & XR_SPACE_LOCATION_POSITION_VALID_BIT) &&
                    (head.locationFlags & XR_SPACE_LOCATION_ORIENTATION_VALID_BIT)) {
                // Keep the room panel level: recenter poses may contain a few
                // degrees of transient head pitch or roll, so preserve yaw.
                XrQuaternionf q = head.pose.orientation;
                float yaw = atan2f(2.0f * (q.w * q.y + q.x * q.z),
                                   1.0f - 2.0f * (q.y * q.y + q.z * q.z));
                XrQuaternionf yaw_orientation = {
                    0.0f, sinf(yaw * 0.5f), 0.0f, cosf(yaw * 0.5f)
                };
                panel_pose = head.pose;
                panel_pose.orientation = yaw_orientation;
                XrVector3f forward = {0.0f, 0.0f, -1.35f};
                XrVector3f offset = questxr_rotate_vector(
                    yaw_orientation, forward);
                panel_pose.position.x += offset.x;
                panel_pose.position.y += offset.y;
                panel_pose.position.z += offset.z;
                panel_anchored = 1;
                XR_LOG("launcher panel anchored in local space");
            }
        }
        XrPosef submitted_panel_pose = panel_pose;
        if (panel_anchored) {
            // Quest's compositor intermittently drops LOCAL-space quad layers.
            // Express the fixed local anchor in VIEW coordinates each frame so
            // presentation stays on its stable path without following the head.
            XrSpaceLocation local_in_view = { XR_TYPE_SPACE_LOCATION };
            if (XR_SUCCEEDED(xrLocateSpace(space, view_space,
                                           frame.predictedDisplayTime,
                                           &local_in_view)) &&
                    (local_in_view.locationFlags &
                     XR_SPACE_LOCATION_POSITION_VALID_BIT) &&
                    (local_in_view.locationFlags &
                     XR_SPACE_LOCATION_ORIENTATION_VALID_BIT)) {
                submitted_panel_pose = questxr_compose_poses(
                    local_in_view.pose, panel_pose);
            }
        }
        // Both Touch aim poses are projected onto the same panel. Only one
        // hover owner exists: the hand whose hit point moved most recently.
        // A same-frame first movement uses right as the documented stable tie.
        QuestxrRayHit left_ray = questxr_project_ray(xrLocateSpace,
            left_pointer_space, left_pointer_pose_active, view_space,
            frame.predictedDisplayTime, submitted_panel_pose);
        QuestxrRayHit right_ray = questxr_project_ray(xrLocateSpace,
            right_pointer_space, right_pointer_pose_active, view_space,
            frame.predictedDisplayTime, submitted_panel_pose);
        if (saf_pose_pending_generation != 0
                && (left_ray.active || right_ray.active)) {
            // Do not reuse the hand owner from before DocumentsUI. The first
            // valid returned pose starts normal latest-movement arbitration.
            active_pointer_hand = 0;
            had_left_ray = 0;
            had_right_ray = 0;
            XR_LOG("SAF tracked poses ready generation=%u",
                saf_pose_pending_generation);
            questxr_notify_activity_saf_pose_ready(env);
            saf_pose_pending_generation = 0;
        }
        float left_delta = left_ray.active && had_left_ray
            ? fabsf(left_ray.u - last_left_u) + fabsf(left_ray.v - last_left_v) : 1.0f;
        float right_delta = right_ray.active && had_right_ray
            ? fabsf(right_ray.u - last_right_u) + fabsf(right_ray.v - last_right_v) : 1.0f;
        int left_moved = left_ray.active && (!had_left_ray || left_delta > 0.001f);
        int right_moved = right_ray.active && (!had_right_ray || right_delta > 0.001f);
        if (left_moved && right_moved) {
            active_pointer_hand = left_delta > right_delta ? 1 : 2;
        } else if (left_moved) {
            active_pointer_hand = 1;
        } else if (right_moved) {
            active_pointer_hand = 2;
        } else if ((active_pointer_hand == 1 && !left_ray.active)
                || (active_pointer_hand == 2 && !right_ray.active)
                || active_pointer_hand == 0) {
            active_pointer_hand = right_ray.active ? 2 : (left_ray.active ? 1 : 0);
        }
        if (left_ray.active) {
            last_left_u = left_ray.u; last_left_v = left_ray.v; had_left_ray = 1;
        } else {
            had_left_ray = 0;
        }
        if (right_ray.active) {
            last_right_u = right_ray.u; last_right_v = right_ray.v; had_right_ray = 1;
        } else {
            had_right_ray = 0;
        }
        QuestxrRayHit active_ray = active_pointer_hand == 1 ? left_ray : right_ray;
        questxr_set_ray_pointer(active_ray.u, active_ray.v, active_ray.active);
        // Emit only post-SAF state transitions (and a sparse heartbeat). This
        // tells us whether the common return failure is sync, inactive pose,
        // invalid locate, or ownership without logging user file data.
        if (diagnostic_saf_generation != 0
                && (diagnostic_last_sync != action_sync_ok
                    || diagnostic_last_left_pose != left_pointer_pose_active
                    || diagnostic_last_right_pose != right_pointer_pose_active
                    || diagnostic_last_left_hit != left_ray.active
                    || diagnostic_last_right_hit != right_ray.active
                    || diagnostic_last_owner != active_pointer_hand
                    || submitted_frames - diagnostic_last_frame >= 180)) {
            XR_LOG("SAF action state gen=%u sync=%d result=%d render=%d leftPose=%d rightPose=%d leftHit=%d rightHit=%d leftFlags=0x%llx rightFlags=0x%llx owner=%d",
                diagnostic_saf_generation, action_sync_ok, action_sync_result,
                frame.shouldRender ? 1 : 0, left_pointer_pose_active,
                right_pointer_pose_active, left_ray.active, right_ray.active,
                (unsigned long long) left_ray.location_flags,
                (unsigned long long) right_ray.location_flags,
                active_pointer_hand);
            diagnostic_last_frame = submitted_frames;
            diagnostic_last_sync = action_sync_ok;
            diagnostic_last_left_pose = left_pointer_pose_active;
            diagnostic_last_right_pose = right_pointer_pose_active;
            diagnostic_last_left_hit = left_ray.active;
            diagnostic_last_right_hit = right_ray.active;
            diagnostic_last_owner = active_pointer_hand;
        }
        if ((left_select_pressed && active_pointer_hand == 1)
                || (right_select_pressed && active_pointer_hand == 2)) {
            // OR the event once: simultaneous triggers cannot double-activate.
            input_events |= QUESTXR_INPUT_SELECT;
        } else if (left_select_pressed || right_select_pressed) {
            XR_LOG("launcher select ignored: no active pointing hand");
        }
        if (input_events) {
            questxr_queue_input(input_events);
            XR_LOG("Quest Touch input events=0x%x hand=%d", input_events,
                   active_pointer_hand);
        }
        if (!frame.shouldRender) {
            XrFrameEndInfo idle_end = { XR_TYPE_FRAME_END_INFO };
            idle_end.displayTime = frame.predictedDisplayTime;
            idle_end.environmentBlendMode = XR_ENVIRONMENT_BLEND_MODE_OPAQUE;
            frame_result = xrEndFrame(session, &idle_end);
            if (XR_FAILED(frame_result)) {
                XR_LOG("idle xrEndFrame failed: %d", frame_result);
                break;
            }
            continue;
        }
        if (submitted_frames == 0) XR_LOG("native first frame begun");
        int background_frame_ready = 0;
        XrView located_views[2] = {
            { XR_TYPE_VIEW }, { XR_TYPE_VIEW }
        };
        if (white_environment_enabled) {
            XrViewLocateInfo view_locate_info = { XR_TYPE_VIEW_LOCATE_INFO };
            view_locate_info.viewConfigurationType =
                XR_VIEW_CONFIGURATION_TYPE_PRIMARY_STEREO;
            view_locate_info.displayTime = frame.predictedDisplayTime;
            view_locate_info.space = space;
            XrViewState view_state = { XR_TYPE_VIEW_STATE };
            uint32_t located_view_count = 0;
            frame_result = xrLocateViews(session, &view_locate_info, &view_state,
                2, &located_view_count, located_views);
            int valid_views = XR_SUCCEEDED(frame_result) && located_view_count == 2
                && (view_state.viewStateFlags & XR_VIEW_STATE_POSITION_VALID_BIT)
                && (view_state.viewStateFlags & XR_VIEW_STATE_ORIENTATION_VALID_BIT);
            for (uint32_t eye = 0; valid_views && eye < 2; eye++) {
                XrFovf fov = located_views[eye].fov;
                valid_views = isfinite(fov.angleLeft) && isfinite(fov.angleRight)
                    && isfinite(fov.angleUp) && isfinite(fov.angleDown)
                    && fov.angleLeft < fov.angleRight
                    && fov.angleDown < fov.angleUp;
            }
            if (!valid_views) {
                if (!white_environment_wait_logged) {
                    XR_LOG("white environment views unavailable result=%d count=%u flags=0x%llx; one panel layer this frame",
                        frame_result, located_view_count,
                        (unsigned long long) view_state.viewStateFlags);
                    white_environment_wait_logged = 1;
                }
            } else {
                white_environment_wait_logged = 0;
                background_frame_ready = 1;
                for (uint32_t eye = 0; eye < 2; eye++) {
                    uint32_t background_image_index = 0;
                    XrSwapchainImageAcquireInfo background_acquire = {
                        XR_TYPE_SWAPCHAIN_IMAGE_ACQUIRE_INFO
                    };
                    XrSwapchainImageWaitInfo background_wait = {
                        XR_TYPE_SWAPCHAIN_IMAGE_WAIT_INFO
                    };
                    background_wait.timeout = XR_INFINITE_DURATION;
                    frame_result = xrAcquireSwapchainImage(background_swapchains[eye],
                        &background_acquire, &background_image_index);
                    if (XR_FAILED(frame_result)) {
                        XR_LOG("white environment acquire failed eye=%u result=%d; disabling", eye,
                            frame_result);
                        background_frame_ready = 0;
                        white_environment_enabled = 0;
                        break;
                    }
                    frame_result = xrWaitSwapchainImage(background_swapchains[eye],
                        &background_wait);
                    if (XR_FAILED(frame_result)) {
                        XR_LOG("white environment wait failed eye=%u result=%d; disabling", eye,
                            frame_result);
                        XrSwapchainImageReleaseInfo abandoned = {
                            XR_TYPE_SWAPCHAIN_IMAGE_RELEASE_INFO
                        };
                        xrReleaseSwapchainImage(background_swapchains[eye], &abandoned);
                        background_frame_ready = 0;
                        white_environment_enabled = 0;
                        break;
                    }
                    glBindFramebuffer(GL_FRAMEBUFFER, background_fbo);
                    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                        GL_TEXTURE_2D,
                        background_images[eye][background_image_index].image, 0);
                    glViewport(0, 0, background_widths[eye], background_heights[eye]);
                    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
                    glClear(GL_COLOR_BUFFER_BIT);
                    GLenum background_status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
                    GLenum background_error = glGetError();
                    glFinish();
                    glBindFramebuffer(GL_FRAMEBUFFER, 0);
                    XrSwapchainImageReleaseInfo background_release = {
                        XR_TYPE_SWAPCHAIN_IMAGE_RELEASE_INFO
                    };
                    frame_result = xrReleaseSwapchainImage(background_swapchains[eye],
                        &background_release);
                    if (background_status != GL_FRAMEBUFFER_COMPLETE
                            || background_error != GL_NO_ERROR
                            || XR_FAILED(frame_result)) {
                        XR_LOG("white environment render/release failed eye=%u fbo=0x%x gl=0x%x result=%d; disabling",
                            eye, background_status, background_error, frame_result);
                        background_frame_ready = 0;
                        white_environment_enabled = 0;
                        break;
                    }
                }
            }
        }
        uint32_t image_index = 0;
        XrSwapchainImageAcquireInfo acquire = {
            XR_TYPE_SWAPCHAIN_IMAGE_ACQUIRE_INFO
        };
        XrSwapchainImageWaitInfo wait = { XR_TYPE_SWAPCHAIN_IMAGE_WAIT_INFO };
        wait.timeout = XR_INFINITE_DURATION;
        frame_result = xrAcquireSwapchainImage(
            quad_swapchain, &acquire, &image_index);
        if (XR_FAILED(frame_result)) {
            XR_LOG("xrAcquireSwapchainImage failed: %d", frame_result);
            break;
        }
        frame_result = xrWaitSwapchainImage(quad_swapchain, &wait);
        if (XR_FAILED(frame_result)) {
            XR_LOG("xrWaitSwapchainImage failed: %d", frame_result);
            break;
        }
        glBindFramebuffer(GL_FRAMEBUFFER, quad_fbo);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                               GL_TEXTURE_2D, quad_images[image_index].image, 0);
        glViewport(0, 0, 1024, 768);
        float focus_rect[4];
        float panel_pointer[3];
        pthread_mutex_lock(&questxr_panel_mutex);
        uint64_t panel_generation = questxr_panel_generation;
        memcpy(focus_rect, questxr_focus_rect, sizeof(focus_rect));
        memcpy(panel_pointer, questxr_panel_pointer, sizeof(panel_pointer));
        if (questxr_panel_rgba && uploaded_panel_generation != panel_generation) {
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, panel_texture);
            glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 1024, 768,
                            GL_RGBA, GL_UNSIGNED_BYTE, questxr_panel_rgba);
            uploaded_panel_generation = panel_generation;
        }
        pthread_mutex_unlock(&questxr_panel_mutex);
        pthread_mutex_lock(&questxr_input_mutex);
        // Lua owns whether this frame is launcher UI or gameplay. Keep the
        // native ray's high-rate coordinates only while Lua has explicitly
        // enabled the panel pointer; otherwise a tracked controller would
        // resurrect the launcher selector over Yellow and the preload card.
        int native_ray_active = questxr_ray_pointer_active;
        int panel_requested = panel_pointer[2] > 0.5f;
        if (panel_requested && native_ray_active) {
            panel_pointer[0] = questxr_ray_pointer_x;
            panel_pointer[1] = questxr_ray_pointer_y;
            panel_pointer[2] = 1.0f;
        } else if (panel_requested) {
            // DocumentsUI can return before Quest restores an aim pose. Do
            // not keep the last selector dot visible during that interval:
            // it is a stale position, not a live hit. The next real ray
            // restores the dot at its matching endpoint without a trigger.
            panel_pointer[2] = 0.0f;
        }
        pthread_mutex_unlock(&questxr_input_mutex);
        // This is the last state before the stable, single Quad layer is
        // drawn. It distinguishes a Lua-visible pointer request from the
        // pointer that the native compositor will actually submit, without
        // logging file data or controller coordinates.
        int panel_effective = panel_pointer[2] > 0.5f;
        int diagnostic_compositor_sample = diagnostic_saf_generation != 0
            && (diagnostic_last_panel_generation != panel_generation
                || diagnostic_last_panel_requested != panel_requested
                || diagnostic_last_panel_effective != panel_effective
                || submitted_frames - diagnostic_last_compositor_frame >= 120);
        if (diagnostic_compositor_sample) {
            XR_LOG("SAF compositor state gen=%u panelGen=%llu uploadedGen=%llu requested=%d effective=%d nativeRay=%d render=%d",
                diagnostic_saf_generation,
                (unsigned long long) panel_generation,
                (unsigned long long) uploaded_panel_generation,
                panel_requested, panel_effective, native_ray_active,
                frame.shouldRender ? 1 : 0);
            diagnostic_last_compositor_frame = submitted_frames;
            diagnostic_last_panel_generation = panel_generation;
            diagnostic_last_panel_requested = panel_requested;
            diagnostic_last_panel_effective = panel_effective;
        }
        if (uploaded_panel_generation) {
            glUseProgram(panel_program);
            glUniform4fv(glGetUniformLocation(panel_program, "focusRect"),
                         1, focus_rect);
            glUniform3fv(glGetUniformLocation(panel_program, "pointerState"),
                         1, panel_pointer);
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, panel_texture);
            glBindBuffer(GL_ARRAY_BUFFER, panel_vbo);
            glEnableVertexAttribArray(0);
            glEnableVertexAttribArray(1);
            glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE,
                                  4 * sizeof(GLfloat), (const void *) 0);
            glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE,
                                  4 * sizeof(GLfloat),
                                  (const void *) (2 * sizeof(GLfloat)));
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        } else {
            glClearColor(0.04f, 0.08f, 0.22f, 1.0f);
            glClear(GL_COLOR_BUFFER_BIT);
        }
        if (submitted_frames == 0)
            XR_LOG("native quad framebuffer status=0x%x glError=0x%x",
                   glCheckFramebufferStatus(GL_FRAMEBUFFER), glGetError());
        glFinish();
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        XrSwapchainImageReleaseInfo release = {
            XR_TYPE_SWAPCHAIN_IMAGE_RELEASE_INFO
        };
        frame_result = xrReleaseSwapchainImage(quad_swapchain, &release);
        if (XR_FAILED(frame_result)) {
            XR_LOG("xrReleaseSwapchainImage failed: %d", frame_result);
            break;
        }

        XrCompositionLayerQuad layer = { XR_TYPE_COMPOSITION_LAYER_QUAD };
        layer.space = view_space;
        layer.eyeVisibility = XR_EYE_VISIBILITY_BOTH;
        layer.pose = submitted_panel_pose;
        layer.size.width = 1.55f;
        layer.size.height = 1.1625f;
        layer.subImage.swapchain = quad_swapchain;
        layer.subImage.imageRect.extent.width = 1024;
        layer.subImage.imageRect.extent.height = 768;
        // The surround uses only the core stereo projection contract verified
        // by the capability probe. It is not a custom laser/equirect/cube
        // layer. If view or swapchain work fails, submit the original panel
        // layer by itself for this frame.
        XrCompositionLayerProjectionView background_views[2] = {
            { XR_TYPE_COMPOSITION_LAYER_PROJECTION_VIEW },
            { XR_TYPE_COMPOSITION_LAYER_PROJECTION_VIEW }
        };
        XrCompositionLayerProjection background_layer = {
            XR_TYPE_COMPOSITION_LAYER_PROJECTION
        };
        uint32_t submitted_layer_count = 1;
        const XrCompositionLayerBaseHeader *layers[2] = {
            (const XrCompositionLayerBaseHeader *) &layer, NULL
        };
        if (background_frame_ready) {
            background_layer.space = space;
            background_layer.viewCount = 2;
            background_layer.views = background_views;
            for (uint32_t eye = 0; eye < 2; eye++) {
                background_views[eye].pose = located_views[eye].pose;
                background_views[eye].fov = located_views[eye].fov;
                background_views[eye].subImage.swapchain = background_swapchains[eye];
                background_views[eye].subImage.imageRect.extent.width =
                    (int32_t) background_widths[eye];
                background_views[eye].subImage.imageRect.extent.height =
                    (int32_t) background_heights[eye];
            }
            layers[0] = (const XrCompositionLayerBaseHeader *) &background_layer;
            layers[1] = (const XrCompositionLayerBaseHeader *) &layer;
            submitted_layer_count = 2;
        }
        XrFrameEndInfo end = { XR_TYPE_FRAME_END_INFO };
        end.displayTime = frame.predictedDisplayTime;
        end.environmentBlendMode = XR_ENVIRONMENT_BLEND_MODE_OPAQUE;
        end.layerCount = submitted_layer_count;
        end.layers = layers;
        if (submitted_frames == 0) XR_LOG("native first xrEndFrame entering");
        frame_result = xrEndFrame(session, &end);
        if (XR_FAILED(frame_result)) {
            XR_LOG("xrEndFrame failed layers=%u result=%d", submitted_layer_count,
                frame_result);
            if (submitted_layer_count == 2) {
                // xrEndFrame is one call per frame, so retrying the single
                // layer in this frame is invalid. Disable the new path and
                // resume with the exact known-good panel submission next frame.
                white_environment_enabled = 0;
                XR_LOG("white environment submit rejected; reverting to one panel layer");
                continue;
            }
            break;
        }
        if (diagnostic_compositor_sample) {
            XR_LOG("SAF compositor submitted gen=%u layers=%u result=%d",
                diagnostic_saf_generation, submitted_layer_count, frame_result);
        }
        submitted_frames++;
        if (submitted_frames == 1)
            XR_LOG("native bootstrap submitted first frame");
        if (panel_generation && submitted_frames % 180 == 0)
            XR_LOG("native panel live generation=%llu",
                   (unsigned long long) panel_generation);
    }

done:
    if (panel_vbo) glDeleteBuffers(1, &panel_vbo);
    if (panel_program) glDeleteProgram(panel_program);
    if (panel_texture) glDeleteTextures(1, &panel_texture);
    if (quad_fbo) glDeleteFramebuffers(1, &quad_fbo);
    if (background_fbo) glDeleteFramebuffers(1, &background_fbo);
    if (quad_images) free(quad_images);
    for (uint32_t eye = 0; eye < 2; eye++) {
        free(background_images[eye]);
        if (background_swapchains[eye] != XR_NULL_HANDLE && xrDestroySwapchain)
            xrDestroySwapchain(background_swapchains[eye]);
    }
    if (quad_swapchain != XR_NULL_HANDLE && xrDestroySwapchain)
        xrDestroySwapchain(quad_swapchain);
    if (left_pointer_space != XR_NULL_HANDLE && xrDestroySpace)
        xrDestroySpace(left_pointer_space);
    if (right_pointer_space != XR_NULL_HANDLE && xrDestroySpace)
        xrDestroySpace(right_pointer_space);
    if (view_space != XR_NULL_HANDLE && xrDestroySpace) xrDestroySpace(view_space);
    if (space != XR_NULL_HANDLE && xrDestroySpace) xrDestroySpace(space);
    if (session != XR_NULL_HANDLE && xrDestroySession) xrDestroySession(session);
    if (action_set != XR_NULL_HANDLE && xrDestroyActionSet)
        xrDestroyActionSet(action_set);
    if (instance != XR_NULL_HANDLE && xrDestroyInstance) xrDestroyInstance(instance);
    if (loader) dlclose(loader);
    if (display != EGL_NO_DISPLAY) {
        eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
        if (surface != EGL_NO_SURFACE) eglDestroySurface(display, surface);
        if (context != EGL_NO_CONTEXT) eglDestroyContext(display, context);
        // EGLDisplay is process-global and is also owned by SDL/LÖVE. Calling
        // eglTerminate here can invalidate gameplay during launcher handoff.
    }
    if (attached) (*questxr_vm)->DetachCurrentThread(questxr_vm);
    questxr_set_pointer_axes(0.0f, 0.0f);
    questxr_set_ray_pointer(0.0f, 0.0f, 0);
    questxr_bootstrap_stopped = 1;
    questxr_bootstrap_started = 0;
    XR_LOG("native bootstrap stopped");
    return NULL;
}

QUESTXR_EXPORT void questxr_log(const char *message) {
    __android_log_print(ANDROID_LOG_INFO, "QuestXR",
                        "%s", message != NULL ? message : "(null)");
}

QUESTXR_EXPORT uint32_t questxr_poll_input(void) {
    pthread_mutex_lock(&questxr_input_mutex);
    uint32_t events = questxr_input_events;
    questxr_input_events = 0;
    pthread_mutex_unlock(&questxr_input_mutex);
    return events;
}

// Lua uses this read-only generation to correlate its visible cursor and UI
// dispatch state with the native SAF pose diagnostics. It never carries picker
// content and it cannot alter input or Android focus.
QUESTXR_EXPORT unsigned int questxr_poll_saf_generation(void) {
    return atomic_load(&questxr_saf_return_generation);
}

QUESTXR_EXPORT void questxr_request_launcher_shutdown(void) {
    questxr_bootstrap_shutdown_requested = 1;
}

QUESTXR_EXPORT int questxr_launcher_stopped(void) {
    return questxr_bootstrap_stopped;
}

QUESTXR_EXPORT void questxr_poll_pointer_axes(float *x, float *y) {
    pthread_mutex_lock(&questxr_input_mutex);
    if (x) *x = questxr_pointer_x;
    if (y) *y = questxr_pointer_y;
    pthread_mutex_unlock(&questxr_input_mutex);
}

QUESTXR_EXPORT void questxr_poll_pointer_position(float *x, float *y,
                                                  int *active) {
    pthread_mutex_lock(&questxr_input_mutex);
    if (x) *x = questxr_ray_pointer_x;
    if (y) *y = questxr_ray_pointer_y;
    if (active) *active = questxr_ray_pointer_active;
    pthread_mutex_unlock(&questxr_input_mutex);
}

// The virtual pointer is compositor metadata, not part of the captured LÖVE
// pixels. Updating it independently lets Touch movement stay smooth even
// while the relatively expensive launcher framebuffer capture is throttled.
QUESTXR_EXPORT void questxr_set_panel_pointer(float x, float y, int visible) {
    static int visible_logged;
    pthread_mutex_lock(&questxr_panel_mutex);
    questxr_panel_pointer[0] = x;
    questxr_panel_pointer[1] = y;
    questxr_panel_pointer[2] = visible ? 1.0f : 0.0f;
    pthread_mutex_unlock(&questxr_panel_mutex);
    if (visible && !visible_logged) {
        visible_logged = 1;
        XR_LOG("compositor launcher pointer visible at %.3f,%.3f", x, y);
    }
}

QUESTXR_EXPORT void love_android_host_presented_frame(int width, int height);

// libquestxr is intentionally isolated from liblove. Register through
// liblove's generic optional host API after Lua is running, which also avoids
// relying on RTLD_DEFAULT visibility between Android shared libraries.
static void questxr_register_present_observer(void) {
    if (questxr_present_observer_registered) return;
    if (!questxr_love_handle) {
        questxr_love_handle = dlopen("liblove.so", RTLD_NOW);
    }
    if (!questxr_love_handle) {
        static int load_failure_logged;
        if (!load_failure_logged) {
            load_failure_logged = 1;
            XR_LOG("panel observer registration waiting for liblove: %s", dlerror());
        }
        return;
    }
    dlerror();
    QuestxrSetPresentedFrameObserver setter =
        (QuestxrSetPresentedFrameObserver) dlsym(
            questxr_love_handle, "love_android_set_presented_frame_observer");
    const char *error = dlerror();
    if (error || !setter) {
        static int symbol_failure_logged;
        if (!symbol_failure_logged) {
            symbol_failure_logged = 1;
            XR_LOG("panel observer registration unavailable: %s",
                   error ? error : "missing setter");
        }
        return;
    }
    setter(love_android_host_presented_frame);
    questxr_present_observer_registered = 1;
    XR_LOG("post-present panel observer registered");
}

// Queue metadata during the engine's generic endFrame callback. The pixels
// cannot be read there because LÖVE still owns unflushed batched draws.
QUESTXR_EXPORT void questxr_request_panel_capture(float focus_x, float focus_y,
                                                  float focus_width,
                                                  float focus_height) {
    questxr_register_present_observer();
    pthread_mutex_lock(&questxr_panel_mutex);
    questxr_pending_focus_rect[0] = focus_x;
    questxr_pending_focus_rect[1] = focus_y;
    questxr_pending_focus_rect[2] = focus_width;
    questxr_pending_focus_rect[3] = focus_height;
    questxr_panel_capture_requested = 1;
    pthread_mutex_unlock(&questxr_panel_mutex);
}

// Scale LÖVE's completed back buffer on its own GLES context and read only the
// 1024x768 panel. Two fixed buffers avoid full-resolution screenshots and
// allocation churn on the Quest's memory-constrained foreground process.
QUESTXR_EXPORT void questxr_capture_panel_gl(int width, int height,
                                             float focus_x, float focus_y,
                                             float focus_width,
                                             float focus_height) {
    if (width <= 0 || height <= 0 || !questxr_bootstrap_started) return;
    EGLContext current_context = eglGetCurrentContext();
    if (current_context == EGL_NO_CONTEXT) return;
    const size_t size = 1024u * 768u * 4u;
    if (!questxr_panel_spare) questxr_panel_spare = (unsigned char *) malloc(size);
    if (!questxr_panel_spare) return;

    if (questxr_capture_context != current_context) {
        questxr_capture_context = current_context;
        questxr_capture_texture = 0;
        questxr_capture_fbo = 0;
    }
    GLint old_read = 0, old_draw = 0, old_pack = 4;
    GLboolean old_scissor = glIsEnabled(GL_SCISSOR_TEST);
    glGetIntegerv(GL_READ_FRAMEBUFFER_BINDING, &old_read);
    glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING, &old_draw);
    glGetIntegerv(GL_PACK_ALIGNMENT, &old_pack);
    if (!questxr_capture_texture) {
        // Raw GL calls share LÖVE's render context, whose state cache cannot
        // see changes made here. Restore every binding exactly or LÖVE may
        // skip a later bind it believes is redundant and keep drawing with
        // this capture texture, freezing the launcher pixels after frame one.
        GLint old_active_texture = GL_TEXTURE0;
        GLint old_texture_2d = 0;
        glGetIntegerv(GL_ACTIVE_TEXTURE, &old_active_texture);
        glActiveTexture(GL_TEXTURE0);
        glGetIntegerv(GL_TEXTURE_BINDING_2D, &old_texture_2d);
        if (!questxr_gl_blit_framebuffer) {
            questxr_gl_blit_framebuffer = (QuestxrBlitFramebufferProc)
                eglGetProcAddress("glBlitFramebuffer");
        }
        if (!questxr_gl_blit_framebuffer) {
            XR_LOG("panel capture glBlitFramebuffer unavailable");
            glBindTexture(GL_TEXTURE_2D, (GLuint) old_texture_2d);
            glActiveTexture((GLenum) old_active_texture);
            return;
        }
        glGenTextures(1, &questxr_capture_texture);
        glBindTexture(GL_TEXTURE_2D, questxr_capture_texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, 1024, 768, 0,
                     GL_RGBA, GL_UNSIGNED_BYTE, NULL);
        glGenFramebuffers(1, &questxr_capture_fbo);
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, questxr_capture_fbo);
        glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                               GL_TEXTURE_2D, questxr_capture_texture, 0);
        if (glCheckFramebufferStatus(GL_DRAW_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            XR_LOG("panel capture framebuffer incomplete");
            questxr_capture_texture = 0;
            questxr_capture_fbo = 0;
            glBindFramebuffer(GL_READ_FRAMEBUFFER, (GLuint) old_read);
            glBindFramebuffer(GL_DRAW_FRAMEBUFFER, (GLuint) old_draw);
            glBindTexture(GL_TEXTURE_2D, (GLuint) old_texture_2d);
            glActiveTexture((GLenum) old_active_texture);
            return;
        }
        glBindTexture(GL_TEXTURE_2D, (GLuint) old_texture_2d);
        glActiveTexture((GLenum) old_active_texture);
        XR_LOG("native fixed-buffer panel capture ready");
    }

    glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, questxr_capture_fbo);
    if (old_scissor) glDisable(GL_SCISSOR_TEST);
    questxr_gl_blit_framebuffer(0, 0, width, height, 0, 0, 1024, 768,
                                GL_COLOR_BUFFER_BIT, GL_LINEAR);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, questxr_capture_fbo);
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(0, 0, 1024, 768, GL_RGBA, GL_UNSIGNED_BYTE,
                 questxr_panel_spare);
    glPixelStorei(GL_PACK_ALIGNMENT, old_pack);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, (GLuint) old_read);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, (GLuint) old_draw);
    if (old_scissor) glEnable(GL_SCISSOR_TEST);

    // SDL's Android back buffer can briefly be empty between surface/present
    // transitions. Never replace a valid VR panel with one of those frames.
    uint64_t brightness = 0;
    uint32_t samples = 0;
    // Sample a grid across the image. The old first-column-only check treated
    // Yellow's black game border as an empty SDL frame and froze the last
    // launcher image forever.
    for (uint32_t y = 16; y < 768; y += 32) {
        for (uint32_t x = 16; x < 1024; x += 32) {
            const unsigned char *sample = questxr_panel_spare +
                ((size_t) y * 1024u + x) * 4u;
            brightness += sample[0] + sample[1] + sample[2];
            samples++;
        }
    }
    if (samples && brightness / samples < 2u) {
        static uint32_t rejected_frames = 0;
        rejected_frames++;
        if (rejected_frames == 1 || rejected_frames % 60 == 0)
            XR_LOG("rejected blank launcher capture count=%u", rejected_frames);
        return;
    }

    pthread_mutex_lock(&questxr_panel_mutex);
    unsigned char *old_front = questxr_panel_rgba;
    questxr_panel_rgba = questxr_panel_spare;
    questxr_panel_spare = old_front;
    questxr_focus_rect[0] = focus_x;
    questxr_focus_rect[1] = focus_y;
    questxr_focus_rect[2] = focus_width;
    questxr_focus_rect[3] = focus_height;
    questxr_panel_generation++;
    pthread_mutex_unlock(&questxr_panel_mutex);
}

// Generic optional Android-host presentation observer. libquestxr registers
// this callback only in the Quest flavor. At this point Graphics::present has
// flushed/endPass'd and rebound the completed default framebuffer, while SDL
// has not swapped it away yet.
QUESTXR_EXPORT void love_android_host_presented_frame(int width, int height) {
    static int observer_logged;
    float focus[4];
    pthread_mutex_lock(&questxr_panel_mutex);
    int requested = questxr_panel_capture_requested;
    if (requested) {
        memcpy(focus, questxr_pending_focus_rect, sizeof(focus));
        questxr_panel_capture_requested = 0;
    }
    pthread_mutex_unlock(&questxr_panel_mutex);
    if (requested) {
        if (!observer_logged) {
            observer_logged = 1;
            XR_LOG("post-present panel capture active");
        }
        questxr_capture_panel_gl(width, height,
                                 focus[0], focus[1], focus[2], focus[3]);
    }
}

JNIEXPORT void JNICALL
Java_org_love2d_android_QuestGameActivity_nativeQuestXrSetActivity(
    JNIEnv *env, jclass clazz, jobject activity) {
    (void) clazz;
    if (questxr_bootstrap_joinable && !questxr_bootstrap_started) {
        pthread_join(questxr_bootstrap_thread, NULL);
        questxr_bootstrap_joinable = 0;
    }
    if ((*env)->GetJavaVM(env, &questxr_vm) != JNI_OK) {
        questxr_vm = NULL;
        return;
    }
    if (questxr_activity != NULL) {
        (*env)->DeleteGlobalRef(env, questxr_activity);
    }
    questxr_activity = (*env)->NewGlobalRef(env, activity);
    __android_log_print(ANDROID_LOG_INFO, "QuestXR",
                        "Android OpenXR context bridge ready");
}

JNIEXPORT void JNICALL
Java_org_love2d_android_QuestGameActivity_nativeQuestXrStartBootstrap(
    JNIEnv *env, jclass clazz) {
    (void) env;
    (void) clazz;
    if (questxr_bootstrap_started) return;
    questxr_bootstrap_shutdown_requested = 0;
    questxr_bootstrap_started = 1;
    if (pthread_create(&questxr_bootstrap_thread, NULL,
                       questxr_native_bootstrap, NULL) != 0) {
        questxr_bootstrap_started = 0;
        XR_LOG("native bootstrap failed: pthread_create");
        return;
    }
    questxr_bootstrap_joinable = 1;
    XR_LOG("native bootstrap thread started");
}

JNIEXPORT void JNICALL
Java_org_love2d_android_QuestGameActivity_nativeQuestXrMarkSafReturn(
    JNIEnv *env, jclass clazz) {
    (void) env;
    (void) clazz;
    unsigned int generation = atomic_fetch_add(
        &questxr_saf_return_generation, 1) + 1;
    XR_LOG("SAF action diagnostics marked generation=%u", generation);
}

JNIEXPORT void JNICALL
Java_org_love2d_android_QuestGameActivity_nativeQuestXrDestroy(
    JNIEnv *env, jclass clazz) {
    (void) clazz;
    questxr_bootstrap_shutdown_requested = 1;
    if (questxr_bootstrap_joinable) {
        pthread_join(questxr_bootstrap_thread, NULL);
        questxr_bootstrap_joinable = 0;
    }
    if (questxr_activity != NULL) {
        (*env)->DeleteGlobalRef(env, questxr_activity);
        questxr_activity = NULL;
    }
    questxr_vm = NULL;
    XR_LOG("Android OpenXR context bridge released");
}

QUESTXR_EXPORT void *questxr_get_application_vm(void) {
    return questxr_vm;
}

QUESTXR_EXPORT void *questxr_get_application_context(void) {
    return questxr_activity;
}

QUESTXR_EXPORT void *questxr_get_egl_display(void) {
    return eglGetCurrentDisplay();
}

QUESTXR_EXPORT void *questxr_get_egl_context(void) {
    return eglGetCurrentContext();
}

QUESTXR_EXPORT void *questxr_get_egl_config(void) {
    EGLDisplay display = eglGetCurrentDisplay();
    EGLContext context = eglGetCurrentContext();
    EGLint config_id = 0;
    EGLConfig config = NULL;
    EGLint count = 0;
    if (display == EGL_NO_DISPLAY || context == EGL_NO_CONTEXT ||
        !eglQueryContext(display, context, EGL_CONFIG_ID, &config_id)) {
        return NULL;
    }
    EGLint attrs[] = { EGL_CONFIG_ID, config_id, EGL_NONE };
    if (!eglChooseConfig(display, attrs, &config, 1, &count) || count != 1) {
        return NULL;
    }
    return config;
}

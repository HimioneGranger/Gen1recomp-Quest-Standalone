#include <jni.h>
#include <EGL/egl.h>
#include <GLES3/gl3.h>
#include <android/log.h>
#include <dlfcn.h>
#include <pthread.h>
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
static int questxr_bootstrap_started;
static pthread_mutex_t questxr_panel_mutex = PTHREAD_MUTEX_INITIALIZER;
static unsigned char *questxr_panel_rgba;
static unsigned char *questxr_panel_spare;
static uint64_t questxr_panel_generation;
static EGLContext questxr_capture_context = EGL_NO_CONTEXT;
static GLuint questxr_capture_texture;
static GLuint questxr_capture_fbo;
typedef void (GL_APIENTRYP QuestxrBlitFramebufferProc)(
    GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLbitfield, GLenum);
static QuestxrBlitFramebufferProc questxr_gl_blit_framebuffer;

#define XR_LOG(...) __android_log_print(ANDROID_LOG_INFO, "QuestXR", __VA_ARGS__)
#define XR_FAIL(message) do { XR_LOG("native bootstrap failed: %s", message); goto done; } while (0)

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

static void *questxr_native_bootstrap(void *unused) {
    (void) unused;
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
    XrSwapchainImageOpenGLESKHR *quad_images = NULL;
    uint32_t quad_image_count = 0;
    GLuint quad_fbo = 0;
    GLuint panel_texture = 0;
    GLuint panel_program = 0;
    GLuint panel_vbo = 0;
    uint64_t uploaded_panel_generation = 0;
    int running = 0;
    uint64_t submitted_frames = 0;
    PFN_xrGetInstanceProcAddr get_proc = NULL;
    PFN_xrInitializeLoaderKHR xrInitializeLoaderKHR = NULL;
    PFN_xrCreateInstance xrCreateInstance = NULL;
    PFN_xrGetSystem xrGetSystem = NULL;
    PFN_xrGetOpenGLESGraphicsRequirementsKHR xrGetOpenGLESGraphicsRequirementsKHR = NULL;
    PFN_xrCreateSession xrCreateSession = NULL;
    PFN_xrCreateReferenceSpace xrCreateReferenceSpace = NULL;
    PFN_xrLocateSpace xrLocateSpace = NULL;
    PFN_xrPollEvent xrPollEvent = NULL;
    PFN_xrBeginSession xrBeginSession = NULL;
    PFN_xrEndSession xrEndSession = NULL;
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
    XR_PROC(XR_NULL_HANDLE, xrInitializeLoaderKHR);
    XrLoaderInitInfoAndroidKHR loader_info = { XR_TYPE_LOADER_INIT_INFO_ANDROID_KHR };
    loader_info.applicationVM = questxr_vm;
    loader_info.applicationContext = questxr_activity;
    if (XR_FAILED(xrInitializeLoaderKHR((const XrLoaderInitInfoBaseHeaderKHR *) &loader_info)))
        XR_FAIL("xrInitializeLoaderKHR");

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
    XR_PROC(instance, xrGetOpenGLESGraphicsRequirementsKHR);
    XR_PROC(instance, xrCreateSession);
    XR_PROC(instance, xrCreateReferenceSpace);
    XR_PROC(instance, xrLocateSpace);
    XR_PROC(instance, xrPollEvent);
    XR_PROC(instance, xrBeginSession);
    XR_PROC(instance, xrEndSession);
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

    XrSystemGetInfo system_info = { XR_TYPE_SYSTEM_GET_INFO };
    system_info.formFactor = XR_FORM_FACTOR_HEAD_MOUNTED_DISPLAY;
    XrSystemId system_id = XR_NULL_SYSTEM_ID;
    if (XR_FAILED(xrGetSystem(instance, &system_info, &system_id))) XR_FAIL("xrGetSystem");
    XrGraphicsRequirementsOpenGLESKHR requirements = {
        XR_TYPE_GRAPHICS_REQUIREMENTS_OPENGL_ES_KHR
    };
    if (XR_FAILED(xrGetOpenGLESGraphicsRequirementsKHR(instance, system_id, &requirements)))
        XR_FAIL("xrGetOpenGLESGraphicsRequirementsKHR");

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
        "void main(){ color=texture(panel,texcoord); }\n";
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
    const int room_anchor_enabled = 0;

    for (;;) {
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
                } else if (changed->state == XR_SESSION_STATE_STOPPING && running) {
                    xrEndSession(session);
                    running = 0;
                } else if (changed->state == XR_SESSION_STATE_EXITING
                        || changed->state == XR_SESSION_STATE_LOSS_PENDING) {
                    goto done;
                }
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
        // Quest may recenter LOCAL space during the first focused frames. Keep
        // the panel in VIEW space briefly, then capture the settled head pose
        // so the room-space anchor does not jump out of view after startup.
        if (room_anchor_enabled && !panel_anchored && submitted_frames >= 450) {
            XrSpaceLocation head = { XR_TYPE_SPACE_LOCATION };
            if (XR_SUCCEEDED(xrLocateSpace(view_space, space,
                                           frame.predictedDisplayTime, &head)) &&
                    (head.locationFlags & XR_SPACE_LOCATION_POSITION_VALID_BIT) &&
                    (head.locationFlags & XR_SPACE_LOCATION_ORIENTATION_VALID_BIT)) {
                panel_pose = head.pose;
                XrVector3f forward = {0.0f, 0.0f, -1.35f};
                XrVector3f offset = questxr_rotate_vector(
                    head.pose.orientation, forward);
                panel_pose.position.x += offset.x;
                panel_pose.position.y += offset.y;
                panel_pose.position.z += offset.z;
                panel_anchored = 1;
                XR_LOG("launcher panel anchored in local space");
            }
        }
        if (submitted_frames == 0) XR_LOG("native first frame begun");
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
        pthread_mutex_lock(&questxr_panel_mutex);
        uint64_t panel_generation = questxr_panel_generation;
        if (questxr_panel_rgba && uploaded_panel_generation != panel_generation) {
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, panel_texture);
            glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 1024, 768,
                            GL_RGBA, GL_UNSIGNED_BYTE, questxr_panel_rgba);
            uploaded_panel_generation = panel_generation;
        }
        pthread_mutex_unlock(&questxr_panel_mutex);
        if (uploaded_panel_generation) {
            glUseProgram(panel_program);
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
        XrCompositionLayerQuad layer = { XR_TYPE_COMPOSITION_LAYER_QUAD };
        layer.space = view_space;
        layer.eyeVisibility = XR_EYE_VISIBILITY_BOTH;
        layer.pose = submitted_panel_pose;
        layer.size.width = 1.55f;
        layer.size.height = 1.1625f;
        layer.subImage.swapchain = quad_swapchain;
        layer.subImage.imageRect.extent.width = 1024;
        layer.subImage.imageRect.extent.height = 768;
        const XrCompositionLayerBaseHeader *layers[] = {
            (const XrCompositionLayerBaseHeader *) &layer
        };
        XrFrameEndInfo end = { XR_TYPE_FRAME_END_INFO };
        end.displayTime = frame.predictedDisplayTime;
        end.environmentBlendMode = XR_ENVIRONMENT_BLEND_MODE_OPAQUE;
        end.layerCount = 1;
        end.layers = layers;
        if (submitted_frames == 0) XR_LOG("native first xrEndFrame entering");
        frame_result = xrEndFrame(session, &end);
        if (XR_FAILED(frame_result)) {
            XR_LOG("xrEndFrame failed: %d", frame_result);
            break;
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
    if (quad_images) free(quad_images);
    if (quad_swapchain != XR_NULL_HANDLE && xrDestroySwapchain)
        xrDestroySwapchain(quad_swapchain);
    if (view_space != XR_NULL_HANDLE && xrDestroySpace) xrDestroySpace(view_space);
    if (space != XR_NULL_HANDLE && xrDestroySpace) xrDestroySpace(space);
    if (session != XR_NULL_HANDLE && xrDestroySession) xrDestroySession(session);
    if (instance != XR_NULL_HANDLE && xrDestroyInstance) xrDestroyInstance(instance);
    if (loader) dlclose(loader);
    if (display != EGL_NO_DISPLAY) {
        eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
        if (surface != EGL_NO_SURFACE) eglDestroySurface(display, surface);
        if (context != EGL_NO_CONTEXT) eglDestroyContext(display, context);
        eglTerminate(display);
    }
    if (attached) (*questxr_vm)->DetachCurrentThread(questxr_vm);
    XR_LOG("native bootstrap stopped");
    return NULL;
}

QUESTXR_EXPORT void questxr_log(const char *message) {
    __android_log_print(ANDROID_LOG_INFO, "QuestXR",
                        "%s", message != NULL ? message : "(null)");
}

// Scale LÖVE's completed back buffer on its own GLES context and read only the
// 1024x768 panel. Two fixed buffers avoid full-resolution screenshots and
// allocation churn on the Quest's memory-constrained foreground process.
QUESTXR_EXPORT void questxr_capture_panel_gl(int width, int height) {
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
    if (!questxr_capture_texture) {
        if (!questxr_gl_blit_framebuffer) {
            questxr_gl_blit_framebuffer = (QuestxrBlitFramebufferProc)
                eglGetProcAddress("glBlitFramebuffer");
        }
        if (!questxr_gl_blit_framebuffer) {
            XR_LOG("panel capture glBlitFramebuffer unavailable");
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
            glBindFramebuffer(GL_FRAMEBUFFER, 0);
            return;
        }
        XR_LOG("native fixed-buffer panel capture ready");
    }

    GLint old_read = 0, old_draw = 0, old_pack = 4;
    glGetIntegerv(GL_READ_FRAMEBUFFER_BINDING, &old_read);
    glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING, &old_draw);
    glGetIntegerv(GL_PACK_ALIGNMENT, &old_pack);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, questxr_capture_fbo);
    questxr_gl_blit_framebuffer(0, 0, width, height, 0, 0, 1024, 768,
                                GL_COLOR_BUFFER_BIT, GL_LINEAR);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, questxr_capture_fbo);
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(0, 0, 1024, 768, GL_RGBA, GL_UNSIGNED_BYTE,
                 questxr_panel_spare);
    glPixelStorei(GL_PACK_ALIGNMENT, old_pack);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, (GLuint) old_read);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, (GLuint) old_draw);

    // SDL's Android back buffer can briefly be empty between surface/present
    // transitions. Never replace a valid VR panel with one of those frames.
    uint64_t brightness = 0;
    uint32_t samples = 0;
    for (size_t pixel = 0; pixel < 1024u * 768u; pixel += 1024u) {
        const unsigned char *sample = questxr_panel_spare + pixel * 4u;
        brightness += sample[0] + sample[1] + sample[2];
        samples++;
    }
    if (samples && brightness / samples < 6u) {
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
    questxr_panel_generation++;
    pthread_mutex_unlock(&questxr_panel_mutex);
}

JNIEXPORT void JNICALL
Java_org_love2d_android_QuestGameActivity_nativeQuestXrSetActivity(
    JNIEnv *env, jclass clazz, jobject activity) {
    (void) clazz;
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
    questxr_bootstrap_started = 1;
    if (pthread_create(&questxr_bootstrap_thread, NULL,
                       questxr_native_bootstrap, NULL) != 0) {
        questxr_bootstrap_started = 0;
        XR_LOG("native bootstrap failed: pthread_create");
        return;
    }
    pthread_detach(questxr_bootstrap_thread);
    XR_LOG("native bootstrap thread started");
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

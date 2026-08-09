#include <jni.h>
#include <EGL/egl.h>
#include <android/log.h>

#if defined(__GNUC__)
#define QUESTXR_EXPORT __attribute__((visibility("default")))
#else
#define QUESTXR_EXPORT
#endif

static JavaVM *questxr_vm;
static jobject questxr_activity;

QUESTXR_EXPORT void questxr_log(const char *message) {
    __android_log_print(ANDROID_LOG_INFO, "QuestXR",
                        "%s", message != NULL ? message : "(null)");
}

JNIEXPORT void JNICALL
Java_org_love2d_android_GameActivity_nativeQuestXrSetActivity(
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

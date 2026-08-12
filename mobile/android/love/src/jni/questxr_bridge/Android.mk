LOCAL_PATH := $(call my-dir)

ifeq ($(QUEST_XR),1)
include $(CLEAR_VARS)

LOCAL_MODULE := questxr
LOCAL_SRC_FILES := questxr_bridge.c
LOCAL_CFLAGS := -g -DGL_GLEXT_PROTOTYPES -fvisibility=hidden
LOCAL_C_INCLUDES := $(LOCAL_PATH)/third_party/prefab/modules/headers/include
LOCAL_LDLIBS := -landroid -ldl -llog -lEGL -lGLESv3

include $(BUILD_SHARED_LIBRARY)
endif

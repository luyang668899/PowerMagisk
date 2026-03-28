LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := zygisk_example
LOCAL_SRC_FILES := src/main.cpp
LOCAL_CXXFLAGS := -std=c++17
LOCAL_LDLIBS := -llog
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_PATH := $(LOCAL_PATH)/lib/$(TARGET_ARCH_ABI)
include $(BUILD_SHARED_LIBRARY)

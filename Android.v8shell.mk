LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SHARED_LIBRARIES := libstlport
include external/stlport/libstlport.mk

LOCAL_SRC_FILES:= samples/shell.cc
LOCAL_MODULE := v8shell

LOCAL_CPP_EXTENSION := .cc

LOCAL_STATIC_LIBRARIES := libv8
LOCAL_SHARED_LIBRARIES += liblog

LOCAL_MODULE_TAGS := optional

LOCAL_C_INCLUDES += $(LOCAL_PATH)/include

include $(BUILD_EXECUTABLE)

##
LOCAL_PATH := $(call my-dir)
# libv8.so
# ===================================================
include $(CLEAR_VARS)

# Set up the target identity
LOCAL_MODULE := libv8
LOCAL_MODULE_CLASS := STATIC_LIBRARIES
intermediates := $(call local-intermediates-dir)

PRIVATE_CLEAN_FILES := $(HOST_OUT)/bin/mksnapshot \
    $(HOST_OUT)/obj/EXECUTABLES/mksnapshot_intermediates

# Android.v8common.mk defines common V8_LOCAL_SRC_FILES
# and V8_LOCAL_JS_LIBRARY_FILES
V8_LOCAL_SRC_FILES :=
V8_LOCAL_JS_LIBRARY_FILES :=
include $(LOCAL_PATH)/Android.v8common.mk

# Target can only be linux
V8_LOCAL_SRC_FILES += \
  src/platform-linux.cc \
  src/platform-posix.cc

LOCAL_SRC_FILES := $(V8_LOCAL_SRC_FILES)

LOCAL_JS_LIBRARY_FILES := $(addprefix $(LOCAL_PATH)/, $(V8_LOCAL_JS_LIBRARY_FILES))

# Copy js2c.py to intermediates directory and invoke there to avoid generating
# jsmin.pyc in the source directory
JS2C_PY := $(intermediates)/js2c.py $(intermediates)/jsmin.py
$(JS2C_PY): $(intermediates)/%.py : $(LOCAL_PATH)/tools/%.py | $(ACP)
	@echo "Copying $@"
	$(copy-file-to-target)

# Generate libraries.cc
GEN1 := $(intermediates)/libraries.cc $(intermediates)/libraries-empty.cc
$(GEN1): SCRIPT := $(intermediates)/js2c.py
$(GEN1): $(LOCAL_JS_LIBRARY_FILES) $(JS2C_PY)
	@echo "Generating libraries.cc"
	@mkdir -p $(dir $@)
	python $(SCRIPT) $(GEN1) CORE $(LOCAL_JS_LIBRARY_FILES)
V8_GENERATED_LIBRARIES := $(intermediates)/libraries.cc

LOCAL_GENERATED_SOURCES += $(V8_GENERATED_LIBRARIES)

# Generate snapshot.cc
ifeq ($(ENABLE_V8_SNAPSHOT),true)
SNAP_GEN := $(intermediates)/snapshot.cc
MKSNAPSHOT := $(HOST_OUT_EXECUTABLES)/mksnapshot
$(SNAP_GEN): PRIVATE_CUSTOM_TOOL = $(MKSNAPSHOT) $(SNAP_GEN)
$(SNAP_GEN): $(MKSNAPSHOT)
	$(transform-generated-source)
LOCAL_GENERATED_SOURCES += $(SNAP_GEN)
else
LOCAL_SRC_FILES += \
  src/snapshot-empty.cc
endif

# The -fvisibility=hidden option below prevents exporting of symbols from
# libv8.a in libwebcore.so.  That reduces size of libwebcore.so by 500k.
LOCAL_CFLAGS += \
	-Wno-endif-labels \
	-Wno-import \
	-Wno-format \
	-fno-exceptions \
	-fvisibility=hidden \
	-DENABLE_DEBUGGER_SUPPORT \
	-DENABLE_LOGGING_AND_PROFILING \
	-DENABLE_VMSTATE_TRACKING \
	-DV8_NATIVE_REGEXP

ifeq ($(TARGET_ARCH),arm)
	LOCAL_CFLAGS += -DARM -DV8_TARGET_ARCH_ARM
endif

ifeq ($(DEBUG_V8),true)
	LOCAL_CFLAGS += -DDEBUG -UNDEBUG
endif

LOCAL_C_INCLUDES += bionic/libc/include $(LOCAL_PATH)/src

include $(BUILD_STATIC_LIBRARY)

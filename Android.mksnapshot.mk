##
# mksnapshot
# ===================================================

ifneq (,$(filter $(mksnapshot_arch),$(V8_SUPPORTED_ARCH)))

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

# Set up the target identity
LOCAL_IS_HOST_MODULE := true
LOCAL_MODULE := v8_mksnapshot.$(mksnapshot_arch)
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_TAGS = optional
LOCAL_MULTILIB := $(mksnapshot_multilib)
generated_sources := $(call local-generated-sources-dir)

V8_LOCAL_JS_LIBRARY_FILES :=
V8_LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES :=
include $(LOCAL_PATH)/Android.v8common.mk

LOCAL_SRC_FILES += \
  src/mksnapshot.cc \
  src/snapshot-empty.cc

ifneq (,$(filter $(HOST_ARCH),x86 x86_64))
LOCAL_SRC_FILES += src/base/atomicops_internals_x86_gcc.cc
endif

ifeq ($(HOST_OS),linux)
LOCAL_SRC_FILES += \
  src/base/platform/platform-linux.cc \
  src/base/platform/platform-posix.cc
endif
ifeq ($(HOST_OS),darwin)
LOCAL_SRC_FILES += \
  src/base/platform/platform-macos.cc \
  src/base/platform/platform-posix.cc
endif

LOCAL_JS_LIBRARY_FILES := $(addprefix $(LOCAL_PATH)/, $(V8_LOCAL_JS_LIBRARY_FILES))
LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES := $(addprefix $(LOCAL_PATH)/, $(V8_LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES))

# Copy js2c.py to generated sources directory and invoke there to avoid
# generating jsmin.pyc in the source directory
JS2C_PY := $(generated_sources)/js2c.py $(generated_sources)/jsmin.py
$(JS2C_PY): $(generated_sources)/%.py : $(LOCAL_PATH)/tools/%.py | $(ACP)
	@echo "Copying $@"
	$(copy-file-to-target)

# Generate libraries.cc
GEN3 := $(generated_sources)/libraries.cc
$(GEN3): SCRIPT := $(generated_sources)/js2c.py
$(GEN3): $(LOCAL_JS_LIBRARY_FILES) $(JS2C_PY)
	@echo "Generating libraries.cc"
	@mkdir -p $(dir $@)
	python $(SCRIPT) $@ CORE off $(LOCAL_JS_LIBRARY_FILES)
LOCAL_GENERATED_SOURCES := $(generated_sources)/libraries.cc

# Generate experimental-libraries.cc
GEN4 := $(generated_sources)/experimental-libraries.cc
$(GEN4): SCRIPT := $(generated_sources)/js2c.py
$(GEN4): $(LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES) $(JS2C_PY)
	@echo "Generating experimental-libraries.cc"
	@mkdir -p $(dir $@)
	python $(SCRIPT) $@ EXPERIMENTAL off $(LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES)
LOCAL_GENERATED_SOURCES += $(generated_sources)/experimental-libraries.cc

LOCAL_CFLAGS := \
	-Wno-endif-labels \
	-Wno-import \
	-Wno-format \
	-ansi \
	-fno-rtti \
	-DENABLE_DEBUGGER_SUPPORT \
	-DENABLE_LOGGING_AND_PROFILING \
	-DENABLE_VMSTATE_TRACKING \
	-DV8_NATIVE_REGEXP \
	-DV8_LIBRT_NOT_AVAILABLE \
	-Wno-unused-parameter \
	-std=gnu++0x

LOCAL_CFLAGS_v8_target_arm += -DV8_TARGET_ARCH_ARM -O0
LOCAL_CFLAGS_v8_target_arm64 += -DV8_TARGET_ARCH_ARM64

ifeq ($(ARCH_ARM_HAVE_VFP),true)
    LOCAL_CFLAGS_v8_target_arm += -DCAN_USE_VFP_INSTRUCTIONS -DCAN_USE_ARMV7_INSTRUCTIONS
endif

LOCAL_CFLAGS_v8_target_mips += -DV8_TARGET_ARCH_MIPS \
	-DCAN_USE_FPU_INSTRUCTIONS \
	-Umips \
	-finline-limit=64 \
	-fno-strict-aliasing

LOCAL_CFLAGS_v8_target_mips64 += -DV8_TARGET_ARCH_MIPS64 \
	-Umips \
	-finline-limit=64 \
	-fno-strict-aliasing

LOCAL_CFLAGS_v8_target_x86 += -DV8_TARGET_ARCH_IA32
LOCAL_CFLAGS_v8_target_x86_64 += -DV8_TARGET_ARCH_X64

ifeq ($(DEBUG_V8),true)
	LOCAL_CFLAGS += -DDEBUG -UNDEBUG
endif

# LOCAL_SRC_FILES_arch only applies to target modules, but we want them
# for a host module, so append them manually
LOCAL_SRC_FILES += $(v8_local_src_files_$(mksnapshot_arch))
LOCAL_CFLAGS += $(LOCAL_CFLAGS_v8_target_$(mksnapshot_arch))

LOCAL_C_INCLUDES += $(LOCAL_PATH)/src

# This is on host.
LOCAL_LDLIBS := -lpthread

LOCAL_SHARED_LIBRARIES := libicuuc-host libicui18n-host

LOCAL_STATIC_LIBRARIES := liblog

include $(BUILD_HOST_EXECUTABLE)
else
$(warning mksnapshot.$(mksnapshot_arch): architecture $(mksnapshot_arch) not supported)
endif

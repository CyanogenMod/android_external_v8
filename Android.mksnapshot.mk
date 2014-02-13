##
# mksnapshot
# ===================================================

ifneq (,$(filter $(mksnapshot_arch),$(V8_SUPPORTED_ARCH)))

LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

# Set up the target identity
LOCAL_IS_HOST_MODULE := true
LOCAL_MODULE := mksnapshot.$(mksnapshot_arch)
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_TAGS = optional
generated_sources := $(call local-generated-sources-dir)


V8_LOCAL_JS_LIBRARY_FILES :=
V8_LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES :=
include $(LOCAL_PATH)/Android.v8common.mk

LOCAL_SRC_FILES += \
  src/mksnapshot.cc \
  src/snapshot-empty.cc

LOCAL_SRC_FILES_arm += src/arm/simulator-arm.cc

LOCAL_SRC_FILES_mips += src/mips/simulator-mips.cc


ifeq ($(HOST_ARCH),x86)
LOCAL_SRC_FILES += src/atomicops_internals_x86_gcc.cc
endif

ifeq ($(HOST_OS),linux)
LOCAL_SRC_FILES += \
  src/platform-linux.cc \
  src/platform-posix.cc
endif
ifeq ($(HOST_OS),darwin)
LOCAL_SRC_FILES += \
  src/platform-macos.cc \
  src/platform-posix.cc
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
	python $(SCRIPT) $(GEN3) CORE off $(LOCAL_JS_LIBRARY_FILES)
LOCAL_GENERATED_SOURCES := $(generated_sources)/libraries.cc

# Generate experimental-libraries.cc
GEN4 := $(generated_sources)/experimental-libraries.cc
$(GEN4): SCRIPT := $(generated_sources)/js2c.py
$(GEN4): $(LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES) $(JS2C_PY)
	@echo "Generating experimental-libraries.cc"
	@mkdir -p $(dir $@)
	python $(SCRIPT) $(GEN4) EXPERIMENTAL off $(LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES)
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
	-Wno-unused-parameter

LOCAL_CFLAGS_arm += -DV8_TARGET_ARCH_ARM

ifeq ($(ARCH_ARM_HAVE_VFP),true)
    LOCAL_CFLAGS_arm += -DCAN_USE_VFP_INSTRUCTIONS -DCAN_USE_ARMV7_INSTRUCTIONS
endif

LOCAL_CFLAGS_mips += -DV8_TARGET_ARCH_MIPS
LOCAL_CFLAGS_mips += -DCAN_USE_FPU_INSTRUCTIONS
LOCAL_CFLAGS_mips += -Umips
LOCAL_CFLAGS_mips += -finline-limit=64
LOCAL_CFLAGS_mips += -fno-strict-aliasing

LOCAL_CFLAGS_x86 += -DV8_TARGET_ARCH_IA32

ifeq ($(DEBUG_V8),true)
	LOCAL_CFLAGS += -DDEBUG -UNDEBUG
endif

# LOCAL_SRC_FILES_arch only applies to target modules, but we want them
# for a host module, so append them manually
LOCAL_SRC_FILES += $(LOCAL_SRC_FILES_$(mksnapshot_arch))
LOCAL_CFLAGS += $(LOCAL_CFLAGS_$(mksnapshot_arch))

LOCAL_C_INCLUDES := $(LOCAL_PATH)/src

# This is on host.
LOCAL_LDLIBS := -lpthread

LOCAL_STATIC_LIBRARIES := liblog

include $(BUILD_HOST_EXECUTABLE)
else
$(warning mksnapshot.$(mksnapshot_arch): architecture $(mksnapshot_arch) not supported)
endif

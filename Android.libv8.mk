##
LOCAL_PATH := $(call my-dir)
# libv8.so
# ===================================================
include $(CLEAR_VARS)

LOCAL_CXX_STL := libc++

ifeq ($(TARGET_ARCH),mips)
       LOCAL_MIPS_MODE=mips
endif

# Set up the target identity
LOCAL_MODULE := libv8
LOCAL_MODULE_CLASS := STATIC_LIBRARIES
generated_sources := $(call local-generated-sources-dir)

LOCAL_MULTILIB := both

# Android.v8common.mk defines V8_LOCAL_JS_LIBRARY_FILES, LOCAL_SRC_FILES,
# LOCAL_CFLAGS, LOCAL_SRC_FILES_arch, and LOCAL_CFLAGS_arch
V8_LOCAL_JS_LIBRARY_FILES :=
V8_LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES :=
include $(LOCAL_PATH)/Android.v8common.mk

# Target can only be linux
LOCAL_SRC_FILES += \
  src/base/platform/platform-linux.cc \
  src/base/platform/platform-posix.cc

LOCAL_SRC_FILES_x86 += src/base/atomicops_internals_x86_gcc.cc
LOCAL_SRC_FILES_x86_64 += src/base/atomicops_internals_x86_gcc.cc

LOCAL_JS_LIBRARY_FILES := $(addprefix $(LOCAL_PATH)/, $(V8_LOCAL_JS_LIBRARY_FILES))
LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES := $(addprefix $(LOCAL_PATH)/, $(V8_LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES))

# Copy js2c.py to generated sources directory and invoke there to avoid
# generating jsmin.pyc in the source directory
JS2C_PY := $(generated_sources)/js2c.py $(generated_sources)/jsmin.py
$(JS2C_PY): $(generated_sources)/%.py : $(LOCAL_PATH)/tools/%.py | $(ACP)
	@echo "Copying $@"
	$(copy-file-to-target)

# Generate libraries.cc
GEN1 := $(generated_sources)/libraries.cc
$(GEN1): SCRIPT := $(generated_sources)/js2c.py
$(GEN1): $(LOCAL_JS_LIBRARY_FILES) $(JS2C_PY)
	@echo "Generating libraries.cc"
	@mkdir -p $(dir $@)
	python $(SCRIPT) $@ CORE off $(LOCAL_JS_LIBRARY_FILES)
V8_GENERATED_LIBRARIES := $(generated_sources)/libraries.cc

# Generate experimental-libraries.cc
GEN2 := $(generated_sources)/experimental-libraries.cc
$(GEN2): SCRIPT := $(generated_sources)/js2c.py
$(GEN2): $(LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES) $(JS2C_PY)
	@echo "Generating experimental-libraries.cc"
	@mkdir -p $(dir $@)
	python $(SCRIPT) $@ EXPERIMENTAL off $(LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES)
V8_GENERATED_LIBRARIES += $(generated_sources)/experimental-libraries.cc

LOCAL_GENERATED_SOURCES += $(V8_GENERATED_LIBRARIES)

# Generate snapshot.cc
ifeq ($(ENABLE_V8_SNAPSHOT),true)

SNAP_GEN := $(generated_sources)/snapshot_$(TARGET_ARCH).cc
MKSNAPSHOT := $(HOST_OUT_EXECUTABLES)/v8_mksnapshot.$(TARGET_ARCH)
$(SNAP_GEN): PRIVATE_CUSTOM_TOOL = $(HOST_OUT_EXECUTABLES)/v8_mksnapshot.$(TARGET_ARCH) --log-snapshot-positions --logfile $(dir $@)/v8-snapshot_$(TARGET_ARCH).log $@
$(SNAP_GEN): $(MKSNAPSHOT)
	$(transform-generated-source)
LOCAL_GENERATED_SOURCES_$(TARGET_ARCH) += $(SNAP_GEN)

ifdef TARGET_2ND_ARCH
SNAP_GEN := $(generated_sources)/snapshot_$(TARGET_2ND_ARCH).cc
MKSNAPSHOT := $(HOST_OUT_EXECUTABLES)/v8_mksnapshot.$(TARGET_2ND_ARCH)
$(SNAP_GEN): PRIVATE_CUSTOM_TOOL = $(HOST_OUT_EXECUTABLES)/v8_mksnapshot.$(TARGET_2ND_ARCH) --log-snapshot-positions --logfile $(dir $@)/v8-snapshot_$(TARGET_2ND_ARCH).log $@
$(SNAP_GEN): $(MKSNAPSHOT)
	$(transform-generated-source)
LOCAL_GENERATED_SOURCES_$(TARGET_2ND_ARCH) += $(SNAP_GEN)
endif # TARGET_2ND_ARCH

else
LOCAL_SRC_FILES += \
  src/snapshot-empty.cc
endif # ENABLE_V8_SNAPSHOT

# The -fvisibility=hidden option below prevents exporting of symbols from
# libv8.a.
LOCAL_CFLAGS += \
	-Wno-endif-labels \
	-Wno-import \
	-Wno-format \
	-fno-exceptions \
	-fvisibility=hidden \
	-DENABLE_DEBUGGER_SUPPORT \
	-DENABLE_LOGGING_AND_PROFILING \
	-DENABLE_VMSTATE_TRACKING \
	-DV8_NATIVE_REGEXP \
	-Wno-unused-parameter \
	-std=gnu++0x

LOCAL_CFLAGS_arm += -DV8_TARGET_ARCH_ARM
LOCAL_CFLAGS_arm64 += -DV8_TARGET_ARCH_ARM64

# atomicops_internals_arm64_gcc.h:77:49: error:
# expected compatible register, symbol or integer in range [0, 4095]
LOCAL_CLANG_CFLAGS_arm64 += -no-integrated-as

LOCAL_CFLAGS_mips += -DV8_TARGET_ARCH_MIPS \
	-Umips \
	-finline-limit=64 \
	-fno-strict-aliasing
LOCAL_CFLAGS_mips64 += -DV8_TARGET_ARCH_MIPS64 \
	-Umips \
	-finline-limit=64 \
	-fno-strict-aliasing

LOCAL_CFLAGS_x86 += -DV8_TARGET_ARCH_IA32
LOCAL_CFLAGS_x86_64 += -DV8_TARGET_ARCH_X64

ifeq ($(DEBUG_V8),true)
	LOCAL_CFLAGS += -DDEBUG -UNDEBUG
endif

ifdef TARGET_2ND_ARCH
LOCAL_SRC_FILES_$(TARGET_2ND_ARCH) += $(v8_local_src_files_$(TARGET_2ND_ARCH))
endif

LOCAL_SRC_FILES_$(TARGET_ARCH) += $(v8_local_src_files_$(TARGET_ARCH))

LOCAL_SHARED_LIBRARIES += libicuuc libicui18n

LOCAL_C_INCLUDES += $(LOCAL_PATH)/src

LOCAL_MODULE_TARGET_ARCH_WARN := $(V8_SUPPORTED_ARCH)

LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/include

include $(BUILD_STATIC_LIBRARY)

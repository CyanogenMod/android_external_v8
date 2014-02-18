##
LOCAL_PATH := $(call my-dir)
# libv8.so
# ===================================================
include $(CLEAR_VARS)

include external/stlport/libstlport.mk

ifeq ($(TARGET_ARCH),mips)
       LOCAL_MIPS_MODE=mips
endif

# Set up the target identity
LOCAL_MODULE := libv8
LOCAL_MODULE_CLASS := STATIC_LIBRARIES
generated_sources := $(call local-generated-sources-dir)

# Android.v8common.mk defines V8_LOCAL_JS_LIBRARY_FILES, LOCAL_SRC_FILES,
# LOCAL_CFLAGS, LOCAL_SRC_FILES_arch, and LOCAL_CFLAGS_arch
V8_LOCAL_JS_LIBRARY_FILES :=
V8_LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES :=
include $(LOCAL_PATH)/Android.v8common.mk

# Target can only be linux
LOCAL_SRC_FILES += \
  src/platform-linux.cc \
  src/platform-posix.cc

LOCAL_SRC_FILES_x86 += src/atomicops_internals_x86_gcc.cc

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
	python $(SCRIPT) $(GEN1) CORE off $(LOCAL_JS_LIBRARY_FILES)
V8_GENERATED_LIBRARIES := $(generated_sources)/libraries.cc

# Generate experimental-libraries.cc
GEN2 := $(generated_sources)/experimental-libraries.cc
$(GEN2): SCRIPT := $(generated_sources)/js2c.py
$(GEN2): $(LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES) $(JS2C_PY)
	@echo "Generating experimental-libraries.cc"
	@mkdir -p $(dir $@)
	python $(SCRIPT) $(GEN2) EXPERIMENTAL off $(LOCAL_JS_EXPERIMENTAL_LIBRARY_FILES)
V8_GENERATED_LIBRARIES += $(generated_sources)/experimental-libraries.cc

LOCAL_GENERATED_SOURCES += $(V8_GENERATED_LIBRARIES)

# Generate snapshot.cc
ifeq ($(ENABLE_V8_SNAPSHOT),true)

SNAP_GEN := $(generated_sources)/snapshot_$(TARGET_ARCH).cc
MKSNAPSHOT := $(HOST_OUT_EXECUTABLES)/mksnapshot.$(TARGET_ARCH)
$(SNAP_GEN): PRIVATE_CUSTOM_TOOL = $(MKSNAPSHOT) --logfile $(generated_sources)/v8.log $(SNAP_GEN)
$(SNAP_GEN): $(MKSNAPSHOT)
	$(transform-generated-source)
LOCAL_GENERATED_SOURCES_$(TARGET_ARCH) += $(SNAP_GEN)

ifdef TARGET_2ND_ARCH
SNAP_GEN := $(generated_sources)/snapshot_$(TARGET_2ND_ARCH).cc
MKSNAPSHOT := $(HOST_OUT_EXECUTABLES)/mksnapshot.$(TARGET_2ND_ARCH)
$(SNAP_GEN): PRIVATE_CUSTOM_TOOL = $(MKSNAPSHOT) --logfile $(generated_sources)/v8.log $(SNAP_GEN)
$(SNAP_GEN): $(MKSNAPSHOT)
	$(transform-generated-source)
LOCAL_GENERATED_SOURCES_$(TARGET_2ND_ARCH) += $(SNAP_GEN)
endif # TARGET_2ND_ARCH

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
	-DV8_NATIVE_REGEXP \
	-Wno-unused-parameter

LOCAL_CFLAGS_arm += -DARM -DV8_TARGET_ARCH_ARM

LOCAL_CFLAGS_mips += -DV8_TARGET_ARCH_MIPS
LOCAL_CFLAGS_mips += -Umips
LOCAL_CFLAGS_mips += -finline-limit=64
LOCAL_CFLAGS_mips += -fno-strict-aliasing

LOCAL_CFLAGS_x86 += -DV8_TARGET_ARCH_IA32

ifeq ($(DEBUG_V8),true)
	LOCAL_CFLAGS += -DDEBUG -UNDEBUG
endif

LOCAL_C_INCLUDES += $(LOCAL_PATH)/src

LOCAL_MODULE_TARGET_ARCH_WARN := $(V8_SUPPORTED_ARCH)

include $(BUILD_STATIC_LIBRARY)

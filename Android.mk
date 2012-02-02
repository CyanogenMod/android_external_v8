##
##
## Copyright 2009, The Android Open Source Project
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##

BASE_PATH := $(call my-dir)
include $(CLEAR_VARS)

# Build libv8 and v8shell
ifeq ($(TARGET_ARCH),arm)
    ifneq ($(strip $(ARCH_ARM_HAVE_ARMV7A)),true)
        $(error V8 requires ARM v7)
    endif

    ENABLE_V8_SNAPSHOT = true
    include $(BASE_PATH)/Android.mksnapshot.mk
    include $(BASE_PATH)/Android.libv8.mk
    include $(BASE_PATH)/Android.v8shell.mk
endif

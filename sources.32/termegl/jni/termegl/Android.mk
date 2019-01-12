LOCAL_PATH := $(call my-dir)
include $(call my-dir)/../../board.tmp

include $(CLEAR_VARS)

# Include libpython3.7dm.so

include $(CLEAR_VARS)
LOCAL_MODULE    := python3.7m
LOCAL_SRC_FILES := ../../prebuilt/$(TARGET_ARCH_ABI)/libpython3.7m.so

include $(PREBUILT_SHARED_LIBRARY)


include $(CLEAR_VARS)
LOCAL_MODULE    := termegl
LOCAL_SRC_FILES := jniapi.cpp
LOCAL_CFLAGS := -fPIC -fexceptions -funwind-tables
LOCAL_LDFLAGS := -fPIE -Wl,--no-merge-exidx-entries

LOCAL_CFLAGS += -I/data/data/u.root/usr/include/python3.7
LOCAL_CFLAGS += -I.

# -- cpython --
LOCAL_JNI_SHARED_LIBRARIES:= python3.7m
LOCAL_CFLAGS += -I$(SDK)/build.32/cpython
LOCAL_CFLAGS += -I$(SDK)/build.32/$(P3D)/thirdparty/android-libs-armv7a/python37/include/python3.7m

# -- libtuio --
LOCAL_CFLAGS += -I$(SDK)/build.32/libtuio
LOCAL_CFLAGS += -I$(SDK)/build.32/libtuio/oscpack


LOCAL_LDLIBS := -lz -ldl -lc -lm -llog -landroid -lEGL -lGLESv2
#-lGLESv1_CM
LOCAL_LDLIBS += -L$(LOCAL_PATH)/../../prebuilt/$(TARGET_ARCH_ABI) -lpython3.7m

#LOCAL_LDLIBS += -lGLESv2
#LOCAL_LDLIBS += -lGLESv3

include $(BUILD_SHARED_LIBRARY)

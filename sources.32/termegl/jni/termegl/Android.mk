LOCAL_PATH := $(call my-dir)
include $(call my-dir)/../../board.tmp

LOCAL_CPP_FEATURES := rtti
LOCAL_CPP_FEATURES := exceptions
include $(CLEAR_VARS)


# Include libpython3.7dm.so

include $(CLEAR_VARS)
LOCAL_MODULE    := python3.7m
LOCAL_SRC_FILES := ../../prebuilt/armeabi-v7a/libpython3.7m.so
LOCAL_EXPORT_CFLAGS := -I/data/data/u.r/usr/include/python3.7 -I.

# -- cpython --
LOCAL_EXPORT_CFLAGS +=-I$(SDK)/build.32/cpython
LOCAL_EXPORT_CFLAGS +=-I$(SDK)/build.32/$(P3D)/thirdparty/android-libs-armv7a/python37/include/python3.7m

# -- libtuio --
LOCAL_EXPORT_CFLAGS +=-I$(SDK)/build.32/libtuio
LOCAL_EXPORT_CFLAGS +=-I$(SDK)/build.32/libtuio/oscpack

include $(PREBUILT_SHARED_LIBRARY)


include $(CLEAR_VARS)
LOCAL_MODULE    := termegl
LOCAL_SRC_FILES := jniapi.cpp common.cpp termExec.cpp
LOCAL_CFLAGS := -fexceptions -funwind-tables
LOCAL_LDFLAGS := -Wl,--no-merge-exidx-entries

LOCAL_LDLIBS := -lz -ldl -lc -lm -llog -lEGL -landroid -lEGL -lGLESv1_CM
#LOCAL_LDLIBS := -lz -ldl -lc -lm -llog -lEGL -landroid -lGLESv2
#LOCAL_LDLIBS := -lz -ldl -lc -lm -llog -lEGL -landroid -lGLESv3

#LOCAL_SHARED_LIBRARIES := python3.7dm crystax pandagles
LOCAL_SHARED_LIBRARIES := python3.7m
# pandagles
#LOCAL_STATIC_LIBRARIES := android_native_app_glue
include $(BUILD_SHARED_LIBRARY)

#$(call import-module,android/native_app_glue)

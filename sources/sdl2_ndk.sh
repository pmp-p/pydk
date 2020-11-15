#!/bin/bash
ROOT=$(pwd)

DL="$PYDK/src/SDL2"

mkdir -p "$DL"

function do_build {
    ndk-build \
 APP_PLATFORM=${APP_PLATFORM} APP_ABI=${APP_ABI} \
 NDK_PROJECT_PATH=. \
 APP_BUILD_SCRIPT=Android.mk \
 APP_ALLOW_MISSING_DEPS=true \
 PREFIX=${PREFIX} \
 CFLAGS=-fPIC "$@"
}

function do_patch {
    cd ${ROOT}

    if [ -f $1/patched ]
    then
        echo " * $1 done"
    else
        wget -c $2 -O$DL/$1.tar.gz
        tar xfz "$DL/$1.tar.gz"
        if $3
        then
            cd $1
            cat >> Android.mk <<PATCH

include \$(CLEAR_VARS)
LOCAL_MODULE := SDL2
LOCAL_SRC_FILES := \$(PREFIX)/lib/libSDL2.so
LOCAL_EXPORT_C_INCLUDES := \$(PREFIX)/include/SDL2
include \$(PREBUILT_SHARED_LIBRARY)

PATCH
            cd ${ROOT}
        fi
        touch $1/patched
    fi
}


TARGET=SDL2-2.0.12
BUILD=${ROOT}/${TARGET}

do_patch ${TARGET} https://www.libsdl.org/release/${TARGET}.tar.gz false

do_build -C $BUILD

cp -vf $BUILD/libs/${APP_ABI}/libSDL2.so $PREFIX/lib/
cp -vf $BUILD/libs/${APP_ABI}/libhidapi.so $PREFIX/lib/
mkdir -p $PREFIX/include/SDL2
cp -f ${TARGET}/include/*h $PREFIX/include/SDL2/



# SDL_image
TARGET=SDL2_image-2.0.5
BUILD=${ROOT}/${TARGET}

do_patch ${TARGET} https://www.libsdl.org/projects/SDL_image/release/${TARGET}.tar.gz true

do_build SUPPORT_JPG=true SUPPORT_PNG=true SUPPORT_WEBP=true -C $BUILD
cp -vf $BUILD/SDL_image.h $PREFIX/include/SDL2/
cp -vf $BUILD/libs/${APP_ABI}/libSDL2_image.so $PREFIX/lib/


# SDL_ttf

TARGET=SDL2_ttf-2.0.15
BUILD=${ROOT}/${TARGET}

do_patch ${TARGET} https://www.libsdl.org/projects/SDL_ttf/release/${TARGET}.tar.gz true

do_build -C $BUILD

cp -vf $BUILD/SDL_ttf.h $PREFIX/include/SDL2/
cp -vf $BUILD/libs/${APP_ABI}/libSDL2_ttf.so $PREFIX/lib/


TARGET=SDL2_mixer-2.0.4
BUILD=${ROOT}/${TARGET}
do_patch ${TARGET} https://www.libsdl.org/projects/SDL_mixer/release/${TARGET}.tar.gz true

do_build -C $BUILD

cp -vf $BUILD/libs/${APP_ABI}/libSDL2_mixer.so  $PREFIX/lib/
cp -vf $BUILD/libs/${APP_ABI}/libmpg123.so  $PREFIX/lib/
cp -vf ${TARGET}/*.h $PREFIX/include/SDL2/


























#

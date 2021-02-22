#!/bin/bash
ROOT=$(pwd)

SDLKEY="-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.0.4 (GNU/Linux)
Comment: For info see http://www.gnupg.org

mQGiBDpWOb0RBADQwd3d9mzt6KzqlsgXf9mikBuMbpKzYs1SBKYpdzUs9sRY0CnH
vCQTrL5sI57yKLnqEl6SbIiE75ZwrSWwvUDFFTh35Jew5nPZwv64en2kw2y4qrnJ
kBZCHDSU4KgfUZtoJ25Tmeru5MLNbXxCOoMszO5L5OchwMrGMtmFLRA/bwCgy5Th
d1/vJo+bej9tbgv++SJ05o0D/3MPK7EBoxWkQ0I+ScqOsvSMRQXWc/hXy4lyIp8e
xJByBApkv0LiiT3KlPpq/K2gTlDlCZ/JTt6Rv8Ug0g47R3a0aoz9kfc15UjHdiap
UOfF9MWmmbw59Lyx6+y2e0/C5xWzNOR1G4G5y4RZL/GXrp67xz/0fEhI85R+eASq
AEfSBAC5ZxwnBwyl+h+PXeJYKrPQjSUlgtSAkKp7PNBywwlue1LcSb7j4cc+cmgH
QMVuM883LPE59btNzFTAZjlzzIMiaXf5h9EkDARTGQ1wFiO3V5vIbVLh4kAoNfpT
egy7bYn3UrlbKg3V2DbCdEXm1zQufZzK7T0yenA5Ps8xXX7mNrQhU2FtIExhbnRp
bmdhIDxzbG91a2VuQGxpYnNkbC5vcmc+iFcEExECABcFAjpWOb0FCwcKAwQDFQMC
AxYCAQIXgAAKCRAwpZN3p3Y75t9RAJ48WI+nOPes0WK7t381Ij4JfSYxWQCgjpMa
Dg3/ah23HZhYtTKtHUzD9zi5AQ0EOlY5wxAEAPvjB0B5RNAj8hBF/Lq78w5rJ1/f
5RqWXmdfxApuEE/9OEFXUSUXms9f/IWvySdyf48Pk4t2h8b8i7F0f3R+tcCp6m0P
t1BSNHYumfmtonTy5FHqpwBVlEi7I0s5mD3kxO+k8PQbATHH5smFnoz2UTc+MzQj
UdtTzXUkUgqvf9zTAAMGA/9Y/h6rhi3YYXeI6SmbXqcmzsQKzaWVhLew67szejnY
sKIJ1ja4MefYlthCXgmIBriNftxIGtBI0Pcmzwpn0eknRNK6NgpmESbGKCWh59Je
iAK5hdBPe47LSFVct5zSO9vQhRDyLzhzPPtB3XeoKTUkLWxBSLbeZVwcHPIK/wLa
l4hGBBgRAgAGBQI6VjnDAAoJEDClk3endjvmxmUAn3Ne6Z3UULpie8RJP15RBt6K
2MWFAJ9hK/Ls/FeBJ9d50qxmYdZ2RrTXNg==
=toqC
-----END PGP PUBLIC KEY BLOCK-----"




if [ -f $PREFIX/lib/libSDL2_mixer.so ]
then
    echo " * SDL2 already built"
else
    echo " * building SDL2"

DL="$PYDK/src/SDL2"

mkdir -p "$DL"

function do_build {
    ndk-build \
 APP_PLATFORM=${APP_PLATFORM} APP_ABI=${APP_ABI} \
 NDK_PROJECT_PATH=. \
 APP_BUILD_SCRIPT=Android.mk \
 APP_ALLOW_MISSING_DEPS=true \
 APP_PREFIX=${PREFIX} \
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
LOCAL_SRC_FILES := \$(APP_PREFIX)/lib/libSDL2.so
LOCAL_EXPORT_C_INCLUDES := \$(APP_PREFIX)/include/SDL2
include \$(PREBUILT_SHARED_LIBRARY)

PATCH
            cd ${ROOT}
        fi
        touch $1/patched
    fi
}


TARGET=SDL2-2.0.14
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

fi









#

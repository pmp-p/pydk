#!/bin/sh

if false; then
# python 3.7.x
    export PYMINOR=7
    export PYVER=${PYMAJOR}.${PYMINOR}.5
    export OPENSSL_VERSION="1.0.2t"
else
# python 3.8.x
    export PYMINOR=8
    export PYVER=${PYMAJOR}.${PYMINOR}.2
    export OPENSSL_VERSION="1.1.1d"
fi


export HOST_TRIPLET=x86_64-linux-gnu
export HOST_TAG=linux-x86_64
export ENV=aosp
export CMAKE_VERSION=3.10.3
export ARCHITECTURES=${ARCHITECTURES:-"armeabi-v7a arm64-v8a x86 x86_64"}

export ANDROID_HOME=${ANDROID_HOME:-$(pwd)/android-sdk}
export NDK_HOME=${NDK_HOME:-${ANDROID_HOME}/ndk-bundle}
export ANDROID_NDK_HOME=${NDK_HOME}

export DN=org.${DN}

export PYMAJOR=3

#UNITS="unit"

UNITS=""


export LIBPYTHON=libpython${PYMAJOR}.${PYMINOR}.so


# above are the defaults, can be overridden via CONFIG

if [ -f "CONFIG" ]
then
pwd
    . $(pwd)/CONFIG
fi


PATCHELF_URL="URL https://github.com/NixOS/patchelf/archive/0.10.tar.gz"
PATCHELF_HASH="URL_HASH SHA256=b3cb6bdedcef5607ce34a350cf0b182eb979f8f7bc31eae55a93a70a3f020d13"

ADBFS_URL="GIT_REPOSITORY https://github.com/spion/adbfs-rootless.git"
ADBFS_HASH="GIT_TAG ba64c22dbd373499eea9c9a9d2a9dd1cd25c33e1 # 14 july 2019"


# optionnal urls for sources packages
if [ -f "CACHE_URL" ]
then
    . $(pwd)/CACHE_URL
fi

#base python
UNITS="unit bzip2 lzma libffi sqlite3 openssl python3"

#extra
UNITS="$UNITS freetype2 harfbuzz ft2_hb bullet3 openal ogg vorbis panda3d"



OLD_PATH=$PATH
ORIGIN=$(pwd)
ROOT="${ORIGIN}/${ENV}"
HOST="${ORIGIN}/${ENV}/host"
BUILD_PREFIX="${ROOT}/build"
BUILD_SRC=${ROOT}/src


export PYTHONPYCACHEPREFIX=${ROOT}/pycache
mkdir -p ${PYTHONPYCACHEPREFIX}


export SUPPORT=${ORIGIN}/sources.${ENV}

PYSRC="${BUILD_SRC}/python3-prefix/src/python3"
PATCHELF_SRC="${BUILD_SRC}/patchelf-prefix/src/patchelf"
ADBFS_SRC="${BUILD_SRC}/adbfs-prefix/src/adbfs"
LZMA_SRC="${BUILD_SRC}/lzma-prefix/src/lzma"

export CMAKE=${ROOT}/bin/cmake

export APK=/data/data/${DN}.${APP}


if [ -f "${SUPPORT}/cross_pip.aosp.sh" ]
then
    UNITS="$UNITS cross_pip"
else
    echo "
    ********************************************************************************
    cross-pip not found ${SUPPORT}/cross_pip.aosp.sh
    cross-modules wont't run, that means disabling *any* extra dynamic python module
    ********************************************************************************
    "
fi


if grep "^Pkg.Revision = 20" $NDK_HOME/source.properties
then
    echo NDK 20+ found
else
    echo "
WARNING:

Only NDK 20 has been tested and is expected to be found in :
   NDK_HOME=$NDK_HOME or ANDROID_HOME=${ANDROID_HOME} + ndk-bundle

press <enter> to continue anyway
"
    read cont
fi

. sources/python_host.sh


# build order
export UNITS

# "gmake" args for CI
export JFLAGS

#"configure" args for CI
export CNF

#function step {
step () {
    if $CI
    then
        echo
        echo "== CI $1: now in $3-$2 =="
    else
        if echo  $STEP|grep -q rue
        then
            echo "$1: paused in $3-$2  press <enter> to continue"
            read cont
        fi
    fi
}

#function do_steps {
do_steps () {
    for unit in ${UNITS}
    do
        step ${unit} $1 pre
        ${unit}_$1 $QUIET
        step ${unit} $1 post
    done
}


# == create a cmake project for the purpose of downloading sources
# == building host python, patchelf and adbfs


cd "${ROOT}"

# because libpython is shared
export LD_LIBRARY_PATH=${HOST}/lib64:${HOST}/lib:$LD_LIBRARY_PATH
export PATH=${HOST}/bin:${ROOT}/bin:$PATH


for unit in $UNITS
do
    echo -n "  +  $unit from : "
    egrep 'URL |GIT' ${SUPPORT}/${unit}.aosp.sh|grep -v ^# |cut -d' ' -f 3-|cut -f1 -d\"
    #echo
    . ${SUPPORT}/${unit}.aosp.sh
done


if [ -f CMakeLists.txt ]
then
    echo " * using previous CMakeLists.txt in $(pwd)"
else

cat > CMakeLists.txt <<END

cmake_minimum_required(VERSION 3.10.2)

project(${ENV})

include(ExternalProject)

set(_downloadOptions SHOW_PROGRESS)

ExternalProject_Add(
    patchelf
    ${PATCHELF_URL}
    ${PATCHELF_HASH}

    DOWNLOAD_NO_PROGRESS ${CI}

    PATCH_COMMAND "./bootstrap.sh"
    CONFIGURE_COMMAND sh -c "cd ${PATCHELF_SRC} && ./configure --prefix=${HOST}"
    BUILD_COMMAND sh -c "cd ${PATCHELF_SRC} && make"
    INSTALL_COMMAND sh -c "cd ${PATCHELF_SRC} && make install"
)

# license BSD https://github.com/spion/adbfs-rootless/blob/master/license

ExternalProject_Add(
    adbfs
    ${ADBFS_URL}
    ${ADBFS_HASH}

    DOWNLOAD_NO_PROGRESS ${CI}

    CONFIGURE_COMMAND sh -c "mkdir -p ${HOST}/bin"
    BUILD_COMMAND sh -c "cd ${ADBFS_SRC} && make"
    INSTALL_COMMAND sh -c "cd ${ADBFS_SRC} && cp -vf adbfs ${HOST}/bin/"
)

END

    #
    do_steps host_cmake

    cd ${BUILD_SRC}
    if $CI
    then
        if $CMAKE .. >/dev/null && make ${JFLAGS} >/dev/null
        then
            echo
        else
            echo "ERROR : cmake externals"
            exit 1
        fi
    else
        if $CMAKE .. && make ${JFLAGS}
        then
            echo
        else
            echo "ERROR : cmake externals"
            exit 1
        fi
    fi
    echo "  -> host tools now in CMAKE_INSTALL_PREFIX=${HOST}"
fi


# == can't save space here with patching an existing host source python tree after a cleanup
# == because we may need a full sourcetree+host python too for some complex libs (eg Panda3D )

do_steps patch


cd ${ROOT}

PrepareBuild () {
    cd ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}

    echo " * building $1 for target ${PLATFORM_TRIPLET}"

    mkdir -p $1-${ANDROID_NDK_ABI_NAME}
    cd $1-${ANDROID_NDK_ABI_NAME}
}

Building () {
    PrepareBuild $1
    /bin/cp -aRfxp ${BUILD_SRC}/$1-prefix/src/$1/. ./
}

std_make () {
    if make ${JFLAGS} install |egrep -v "libtool|install"
    then
        echo "make $1 : installed"
    else
        echo "ERROR: make $1"
        exit 1
    fi
}

echo
echo "ARCHITECTURES=[$ARCHITECTURES]"
echo

for ANDROID_NDK_ABI_NAME in $ARCHITECTURES
do
    if echo $ARCHITECTURES|grep -q hostonly
    then
        break
    fi
    unset NDK_PREFIX

    export TOOLCHAIN=$NDK_HOME/toolchains/llvm/prebuilt/$HOST_TAG

    cd ${ROOT}

    mkdir -p ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}

    if cd ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}
    then
        echo "Current architecture : $ANDROID_NDK_ABI_NAME"
    else
        echo "bad arch"
        continue
    fi

    TARGET_ARCH_ABI=$ANDROID_NDK_ABI_NAME

    # except for armv7
    ABI=android

    case "$ANDROID_NDK_ABI_NAME" in
        armeabi-v7a)
            PLATFORM_TRIPLET=armv7a-linux-androideabi
            ARCH=armv7a
            ABI=androideabi
            API=19
            BITS=32
            export NDK_PREFIX="arm-linux-androideabi"
            ;;
        arm64-v8a)
            PLATFORM_TRIPLET=aarch64-linux-android
            ARCH=aarch64
            API=21
            BITS=64
            ;;
        x86)
            PLATFORM_TRIPLET=i686-linux-android
            ARCH=i686
            API=19
            BITS=32
            ;;
        x86_64)
            PLATFORM_TRIPLET=x86_64-linux-android
            ARCH=x86_64
            API=21
            BITS=64
            ;;
    esac

    export APKUSR=${ROOT}/apkroot-${ANDROID_NDK_ABI_NAME}/usr

    export PKG_CONFIG_PATH=${APKUSR}/lib/pkgconfig

    # for disposal of things we don't want to land in prebuilt folder
    export DISPOSE=${ROOT}/apkroot-${ANDROID_NDK_ABI_NAME}-discard

    mkdir -p ${APKUSR} ${DISPOSE}

    export CC=$TOOLCHAIN/bin/${PLATFORM_TRIPLET}${API}-clang
    export CXX=$TOOLCHAIN/bin/${PLATFORM_TRIPLET}${API}-clang++

    BUILD_TYPE=$PLATFORM_TRIPLET

    if echo $NDK_PREFIX|grep -q abi
    then
        PLATFORM_TRIPLET=$NDK_PREFIX
    else
        NDK_PREFIX=$PLATFORM_TRIPLET
    fi

    export LD=$TOOLCHAIN/bin/${NDK_PREFIX}-ld
    export READELF=$TOOLCHAIN/bin/${NDK_PREFIX}-readelf
    export AR=$TOOLCHAIN/bin/${NDK_PREFIX}-ar
    export AS=$TOOLCHAIN/bin/${NDK_PREFIX}-as
    export RANLIB=$TOOLCHAIN/bin/${NDK_PREFIX}-ranlib
    export STRIP=$TOOLCHAIN/bin/${NDK_PREFIX}-strip

    # == eventually restore full PLATFORM_TRIPLET

    export PLATFORM_TRIPLET=${BUILD_TYPE}

    # == set up the basic cmake toolchain

#TODO: ANDROID_ARM_NEON

    cat > ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/toolchain.cmake <<END
set(ANDROID_NDK_ROOT ${NDK_HOME})
set(ANDROID_NDK ${NDK_HOME})
set(ANDROID_NATIVE_API_LEVEL ${API})
set(ANDROID_PLATFORM_LEVEL ${API})
set(ANDROID_PLATFORM "android-${API}")
set(ANDROID_ARCH ${ANDROID_NDK_ABI_NAME})
set(ANDROID_ABI ${ANDROID_NDK_ABI_NAME})
set(CMAKE_CROSSCOMPILING ON)
set(CMAKE_FIND_LIBRARY_PREFIXES lib)
set(CMAKE_FIND_LIBRARY_SUFFIXES .so)

#unset(CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES)
#unset(CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES)

set(BZIP2_LIBRARIES "${APKUSR}/lib/libbz2.a")
set(BZIP2_INCLUDE_DIR "${APKUSR}/include")

set(HARFBUZZ_INCLUDE_DIRS "${APKUSR}/include/harfbuzz")
set(HARFBUZZ_LIBRARIES "${APKUSR}/lib/libharfbuzz.so")

set(HARFBUZZ_INCLUDE_DIR "${APKUSR}/include/harfbuzz")
set(HARFBUZZ_LIBRARY "${APKUSR}/lib/libharfbuzz.so")

set(OGG_INCLUDE_DIRS "${APKUSR}/include")
set(OGG_LIBRARIES "${APKUSR}/lib/libogg.so")



set(CMAKE_CONFIGURATION_TYPES "Release")
set(CMAKE_BUILD_TYPE "Release")
END


    # == that env file can be handy for debugging compile failures.
    export ACMAKE="$CMAKE -DANDROID_ABI=${ANDROID_NDK_ABI_NAME}\
 -DCMAKE_TOOLCHAIN_FILE=${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/toolchain.cmake\
 -DCMAKE_INSTALL_PREFIX=${APKUSR}"

    cat > $ROOT/${ANDROID_NDK_ABI_NAME}.sh <<END
#!/bin/sh
export ANDROID_NDK_HOME=${NDK_HOME}
export STRIP=$STRIP
export READELF=$READELF
export AR=$AR
export AS=$AS
export LD=$LD
export CXX=$CXX
export CC=$CC
export RANLIB=$RANLIB

export PATH=${HOST}/bin:${ROOT}/bin:/bin:/usr/bin:/usr/local/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH

END

    # == a shell for one arch, with a ready to use cmake cross compile command
    cat > $ORIGIN/shell.${ANDROID_NDK_ABI_NAME}.sh <<END
#!/bin/sh
. $ROOT/${ANDROID_NDK_ABI_NAME}.sh

. ${ROOT}/bin/activate

export PKG_CONFIG_PATH=${APKUSR}/lib/pkgconfig

export PS1="[PyDK:$ANDROID_NDK_ABI_NAME] \w \$ "

acmake () {
        reset
        echo "  == cmake for target ${ANDROID_NDK_ABI_NAME} =="
        ${ACMAKE} "\$@"
}

END



    grep -v 'Using custom NDK path'  ${NDK_HOME}/build/cmake/android.toolchain.cmake >> ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/toolchain.cmake

    # == building bzip2

    # == building xz liblzma

    # == building libffi

    # == building openssl

    # == building python

    do_steps crosscompile
done


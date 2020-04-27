#!/bin/sh

echo "Guessing shell, only bash would reply :"
if sh -version 2>/dev/null
then
    echo found bash
    NOBASH=false
else
    NOBASH=true
    echo "not bash, those previously rising errors are ash/sh/dash/... flavours"
fi

PYMINOR_DEFAULT=8

export PYMAJOR=3
export PYMINOR=${PYMINOR:-$PYMINOR_DEFAULT}

if echo $PYMINOR |grep -q 7
then
# python 3.7.x
    export PYVER=${PYMAJOR}.${PYMINOR}.5
    export OPENSSL_VERSION="1.0.2t"
else
# python 3.8.x
    export PYVER=${PYMAJOR}.${PYMINOR}.2
    export OPENSSL_VERSION="1.1.1f"
fi


export HOST_TRIPLET=x86_64-linux-gnu
export HOST_TAG=linux-x86_64
export CMAKE_VERSION=3.10.3
OLD_PATH=$PATH
export ORIGIN=$(pwd)
export HOST="${ORIGIN}/host"
export BUILD_SRC=${ORIGIN}/src

export LIBPYTHON=libpython${PYMAJOR}.${PYMINOR}.so

export ARCHITECTURES=${ARCHITECTURES:-"armeabi-v7a arm64-v8a x86 x86_64 wasm"}

#UNITS="unit"
UNITS=""


# select a place for android build
export ENV=aosp
ROOT="${ORIGIN}/${ENV}"
BUILD_PREFIX="${ROOT}/build"


# ndk specific
export ANDROID_HOME=${ANDROID_HOME:-$(pwd)/android-sdk}
export NDK_HOME=${NDK_HOME:-${ANDROID_HOME}/ndk-bundle}
export ANDROID_NDK_HOME=${NDK_HOME}


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



export PYTHONPYCACHEPREFIX=${ORIGIN}/pycache
mkdir -p ${PYTHONPYCACHEPREFIX}


export SUPPORT=${ORIGIN}/sources.${ENV}

PYSRC="${BUILD_SRC}/python3-prefix/src/python3"
PATCHELF_SRC="${BUILD_SRC}/patchelf-prefix/src/patchelf"
ADBFS_SRC="${BUILD_SRC}/adbfs-prefix/src/adbfs"
LZMA_SRC="${BUILD_SRC}/lzma-prefix/src/lzma"

export CMAKE=${ROOT}/bin/cmake


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


if grep "^Pkg.Revision = 21" $NDK_HOME/source.properties
then
    echo NDK 21+ found
else
    echo "
WARNING:

Only NDK 21 has been tested and is expected to be found in :
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
    egrep 'URL |GIT' ${SUPPORT}/${unit}.${ENV}.sh|grep -v ^# |cut -d' ' -f 3-|cut -f1 -d\"
    echo
    . ${SUPPORT}/${unit}.${ENV}.sh
done

cd ${BUILD_SRC}

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
        if $CMAKE . >/dev/null && make ${JFLAGS} >/dev/null
        then
            echo
        else
            echo "ERROR : cmake externals in ${BUILD_SRC} from $(pwd)"
            exit 1
        fi
    else
        if $CMAKE . && make ${JFLAGS}
        then
            echo
        else
            echo "ERROR : cmake externals in ${BUILD_SRC} from $(pwd)"
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
    cd ${BUILD_PREFIX}-${ABI_NAME}

    echo " * building $1 for target ${PLATFORM_TRIPLET}"

    mkdir -p $1-${ABI_NAME}
    cd $1-${ABI_NAME}
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

em_make () {
    if emmake make install |egrep -v "libtool|install"
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

for ABI_NAME in $ARCHITECTURES
do
    unset NDK_PREFIX
    unset TOOLCHAIN

    if echo $ARCHITECTURES|grep -q hostonly
    then
        break
    fi


    cd ${ROOT}



    export APKUSR=${ROOT}/apkroot-${ABI_NAME}/usr

    export PKG_CONFIG_PATH=${APKUSR}/lib/pkgconfig

    # == a shell for one arch, with a ready to use cmake cross compile command
    cat > $ORIGIN/shell.${ABI_NAME}.sh <<END
#!/bin/sh
. ${HOST}/${ABI_NAME}.sh

. ${ROOT}/bin/activate

export PKG_CONFIG_PATH=${APKUSR}/lib/pkgconfig

export PS1="[PyDK:$ABI_NAME] \w \$ "

acmake () {
        reset
        echo "  == cmake for target ${ABI_NAME} =="
        ${ACMAKE} \$@
}

wcmake () {
        reset
        echo "  == cmake for target ${ABI_NAME} =="
        echo $WCMAKE \$@
}


END



    # ndk specifics

    export TOOLCHAIN=$NDK_HOME/toolchains/llvm/prebuilt/$HOST_TAG

    ANDROID_NDK_ABI_NAME=${ABI_NAME}
    # except for armv7
    ABI=android

    case "$ABI_NAME" in
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
        wasm)
            PLATFORM_TRIPLET=wasm-unknown-emscripten
            ABI="wasm"
            API="wasm"
            export ABI API PLATFORM_TRIPLET
            export LIBPYTHON=libpython${PYMAJOR}.${PYMINOR}.a
            break
            ;;
        asmjs)
            PLATFORM_TRIPLET=asmjs-unknown-emscripten
            ABI="asmjs"
            API="asmjs"
            export ABI API PLATFORM_TRIPLET
            export LIBPYTHON=libpython${PYMAJOR}.${PYMINOR}.so
            echo "ASM.JS support has been dropped"
            exit 1
            break
            ;;
    esac


    mkdir -p ${BUILD_PREFIX}-${ABI_NAME}

    if cd ${BUILD_PREFIX}-${ABI_NAME}
    then
        echo "Current architecture : $ABI_NAME"
    else
        echo "bad arch"
        continue
    fi


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

#TODO: ANDROID_ARM_NEON // no need with ndk21+ neon is default

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

set(OGG_LIBRARY "${APKUSR}/lib/libogg.so")
set(OGG_INCLUDE_DIR "${APKUSR}/include/ogg")
set(OGG_FOUND YES)


set(CMAKE_CONFIGURATION_TYPES "Release")
set(CMAKE_BUILD_TYPE "Release")
END

    # == that env file can be handy for debugging compile failures.
    export ACMAKE="$CMAKE -DANDROID_ABI=${ANDROID_NDK_ABI_NAME}\
 -DCMAKE_TOOLCHAIN_FILE=${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/toolchain.cmake\
 -DCMAKE_INSTALL_PREFIX=${APKUSR}"

    cat > ${HOST}/${ANDROID_NDK_ABI_NAME}.sh <<END
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




    grep -v 'Using custom NDK path'  ${NDK_HOME}/build/cmake/android.toolchain.cmake >> ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/toolchain.cmake

    # == building bzip2

    # == building xz liblzma

    # == building libffi

    # == building openssl

    # == building python

    do_steps crosscompile
done

# if CI does not use bash
if $NOBASH
then
    unset ENV ROOT BUILD_PREFIX SUPPORT APKUSR PKG_CONFIG_PATH TOOLCHAIN UNITS PYTHON3_URL PYTHON3_HASH
fi

# until webgl is merged into master
unset PANDA3D_URL
unset PANDA3D_HASH

if echo $ABI_NAME|grep -q wasm
then
    echo "switching sdk to $ABI_NAME"
else
    exit 0
fi

cd ${ORIGIN}

echo " * adding wasm build"

# select a place for wasm build
export ENV="wasm"
export ROOT="${ORIGIN}/${ENV}"
export BUILD_PREFIX="${ROOT}/build"

export SUPPORT="${ORIGIN}/sources.${ENV}"
export APKUSR="${ROOT}/apkroot-${ABI_NAME}/usr"
export PKG_CONFIG_PATH="${APKUSR}/lib/pkgconfig"

# for disposal of things we don't want to land in prebuilt folder
export DISPOSE="${ROOT}/apkroot-${ABI_NAME}-discard"

echo " * checking host python"
mkdir -p ${ROOT}
. sources/python_host.sh

export TOOLCHAIN="${ORIGIN}/emsdk/emsdk_env.sh"

export WCMAKE="emcmake $CMAKE -Wno-dev -DCMAKE_INSTALL_PREFIX=${APKUSR}"

cat > ${HOST}/${ABI_NAME}.sh <<END
#!/bin/sh

export PATH=${HOST}/bin:${ROOT}/bin:/bin:/usr/bin:/usr/local/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HOST}/lib64:${HOST}/lib

. ${TOOLCHAIN}

#export STRIP=$STRIP
#export READELF=$READELF
#export AR=$AR
#export AS=$AS
#export LD=$LD
#export CXX=$CXX
#export CC=$CC
#export RANLIB=$RANLIB

export PLATFORM_TRIPLET=${PLATFORM_TRIPLET}

export WCMAKE="$WCMAKE"

END


export UNITS="openssl python3 vorbis panda3d"

for unit in $UNITS
do
    echo -n "  +  $unit from : "
    egrep 'URL |GIT' ${SUPPORT}/${unit}.${ENV}.sh|grep -v ^# |cut -d' ' -f 3-|cut -f1 -d\"
    echo
    . ${SUPPORT}/${unit}.${ENV}.sh
done


if true
then

    mkdir -p ${BUILD_PREFIX}-${ABI_NAME}

    if cd ${BUILD_PREFIX}-${ABI_NAME}
    then
        echo "Current architecture : $ABI_NAME"
    else
        echo "bad arch"
        continue
    fi

    . $TOOLCHAIN

    ALL="zlib bzip2 freetype harfbuzz ogg vorbis libpng bullet"
    #embuilder --pic build $ALL
    embuilder build $ALL

    do_steps crosscompile

fi



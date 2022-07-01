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

export PYMAJOR=3
export PYMINOR=${PYMINOR:-10}
export PYMICRO=${PYMICRO:-5}

export PYVER=${PYMAJOR}.${PYMINOR}.${PYMICRO}

# python 3.7.x
# export OPENSSL_VERSION="1.0.2t"

# python 3.8 +
export OPENSSL_VERSION="1.1.1m"

export LIBFFI_VERSION=3.3

export HOST_TRIPLET=x86_64-linux-gnu
export HOST_TAG=linux-x86_64

#tested
#export CMAKE_VERSION=3.13.0
export CMAKE_VERSION=3.22.1




export ORIGIN=$(pwd)
export PYDK=$(pwd)

export HOST="${ORIGIN}/host"
export BUILD_SRC=${ORIGIN}/src

export LIBPYTHON=libpython${PYMAJOR}.${PYMINOR}.so

if echo " 11" | grep -q " $PYMINOR"
then
    export ARCHITECTURES=${ARCHITECTURES:-"armeabi-v7a arm64-v8a x86 x86_64 wasm"}
else
    export ARCHITECTURES=${ARCHITECTURES:-"armeabi-v7a arm64-v8a x86 x86_64"}
fi


export PYTHONPYCACHEPREFIX=${ORIGIN}/pycache
export HOME=${PYTHONPYCACHEPREFIX}

#UNITS="unit"
UNITS=""

# select a place for android build
export ENV=aosp
ROOT="${ORIGIN}/${ENV}"
BUILD_PREFIX="${ROOT}/build"

# sdk tools https://developer.android.com/studio/releases/platform-tools
export ANDROID_HOME="${ANDROID_HOME:-$(pwd)/android-sdk}"

# 28.0.3 at time of ndk 21/22/23
export BUILD_TOOLS="${ANDROID_HOME}/build-tools/28.0.3"

# ndk https://developer.android.com/ndk/downloads
export NDK_HOME=${NDK_HOME:-${ANDROID_HOME}/ndk-bundle}
export ANDROID_NDK_HOME=${NDK_HOME}


export STEP=${STEP:-false}

# above are the defaults, can be overridden via CONFIG

if [ -f "CONFIG" ]
then
pwd
    . $(pwd)/CONFIG
fi

#tested
URL_PATCHELF="URL https://github.com/NixOS/patchelf/archive/0.12.tar.gz"
HASH_PATCHELF="URL_HASH SHA256=3dca33fb862213b3541350e1da262249959595903f559eae0fbc68966e9c3f56"


URL_ADBFS="GIT_REPOSITORY https://github.com/spion/adbfs-rootless.git"
#tested
HASH_ADBFS="GIT_TAG ba64c22dbd373499eea9c9a9d2a9dd1cd25c33e1 # 14 july 2019"

#new
HASH_ADBFS="GIT_TAG 5b091a50cd2419e1cebe42aa1d0e1ad1f90fdfad # 29 feb 2020"

# optionnal urls for sources packages
if [ -f "CACHE_URL" ]
then
    . $(pwd)/CACHE_URL
fi

#base python
UNITS="unit bz2 lzma libffi sqlite3 openssl python3"

#extra
UNITS="$UNITS freetype2 harfbuzz ft2_hb bullet3 openal ogg vorbis panda3d sdl2 pcre2"



# specific to host python that will drive the build
mkdir -p "${HOST}"
mkdir -p "${PYTHONPYCACHEPREFIX}"



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



. sources/python_host.sh



#FIXME: NDK

NDK_BAD=true

if grep "^Pkg.Revision = 21" $NDK_HOME/source.properties
then
    echo NDK 21+ found
    NDK_BAD=false
fi

if grep "^Pkg.Revision = 23" $NDK_HOME/source.properties
then
        echo NDK 23+ found
        cat > /tmp/arm-linux-androideabi <<END
#!/bin/bash
if llvm-ar "\$@" 2>&1 >/dev/null
then
echo -n
else
    echo "---------------------------------------------------"
    echo "PATCHED llvm-ar \$@"
    echo "---------------------------------------------------"
fi
exit 0
END
    cat > /tmp/fix-ndk <<END
#!/bin/bash

chmod gou+x /tmp/arm-linux-androideabi
cp -a /tmp/arm-linux-androideabi \
    ${ANDROID_HOME:-/usr/local/lib/android/sdk}/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/arm-linux-androideabi-ar

mv /tmp/arm-linux-androideabi \
    ${ANDROID_HOME:-/usr/local/lib/android/sdk}/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/arm-linux-androideabi-ranlib
END
    chmod +x /tmp/fix-ndk
    sudo /tmp/fix-ndk

else
    NDK_BAD=true
fi


if $NDK_BAD
then
    echo "

WARNING: NDK_BAD=$NDK_BAD

Only NDK 21 has been tested and is expected to be found in :
   NDK_HOME=$NDK_HOME or ANDROID_HOME=${ANDROID_HOME} + ndk-bundle

    Found $(grep Revision $NDK_HOME/source.properties)

press <enter> to continue anyway
"
    read cont
fi



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
        if $STEP
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
export LD_LIBRARY_PATH="${HOST}/lib64:${HOST}/lib:$LD_LIBRARY_PATH"
export BASEPATH="${HOST}/bin:$NDK_HOME:${ROOT}/bin:${PYTHONPYCACHEPREFIX}/bin:/bin:/usr/bin:/usr/local/bin"

# prevent system path interference in build tools
export PATH="$BASEPATH"

# == a shell for host tools, with a ready to use cmake cross compile command
ABI_NAME="host"
export APKUSR="${HOST}"

cat > $HOST/toolchain.cmake <<END



END


cat > $ORIGIN/shell.${ABI_NAME}.sh <<END
#!/bin/sh
# . ${HOST}/${ABI_NAME}.sh

. ${ROOT}/bin/activate

export LD_LIBRARY_PATH="${HOST}/lib64:${HOST}/lib:$LD_LIBRARY_PATH"

export PATH="$BASEPATH"

export PYDK="${ORIGIN}"

export CMAKE_INSTALL_PREFIX=${APKUSR}
export PREFIX="${APKUSR}"


export PYTHONPATH=${HOST}/lib/python$PYVER:${HOST}/lib/python${PYMAJOR}.${PYMINOR}/site-packages

alias python="${HOST}/bin/python${PYMAJOR}.${PYMINOR} -i -u -B"

export PKG_CONFIG_PATH="${APKUSR}/lib/pkgconfig"

export PS1="[PyDK:$ABI_NAME] \w \$ "

hcmake () {
        reset
        echo "  == cmake for target ${ABI_NAME} =="
        cmake\
 -DCMAKE_FIND_LIBRARY_PREFIXES="lib"\
 -DCMAKE_FIND_LIBRARY_SUFFIXES="so"\
 -DCMAKE_TOOLCHAIN_FILE=${HOST}/toolchain.cmake\
 -DCMAKE_INSTALL_PREFIX="${APKUSR}" \$@
}

END












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

# TODO: check wasm/wasi cmake +  CMAKE_CACHE_ARGS "-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true"

    cat > CMakeLists.txt <<END

cmake_minimum_required(VERSION 3.13.0)

project(${ENV})

include(ExternalProject)

set(_downloadOptions SHOW_PROGRESS)

ExternalProject_Add(
    patchelf
    ${URL_PATCHELF}
    ${HASH_PATCHELF}

    DOWNLOAD_NO_PROGRESS ${CI}

    PATCH_COMMAND "./bootstrap.sh"
    CONFIGURE_COMMAND sh -c "cd ${PATCHELF_SRC} && ./configure --prefix=${HOST}"
    BUILD_COMMAND sh -c "cd ${PATCHELF_SRC} && make"
    INSTALL_COMMAND sh -c "cd ${PATCHELF_SRC} && make install"
)

# license BSD https://github.com/spion/adbfs-rootless/blob/master/license

ExternalProject_Add(
    adbfs
    ${URL_ADBFS}
    ${HASH_ADBFS}

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
            $PYTHON/bin/python3 -m pip install --upgrade pip
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

    echo "  -> upgrading host build pip"
    #FIXME PYPA
    "${HOST}/bin/python3" -m pip install --upgrade pip
    #"${HOST}/bin/python3" -m pip install pip==20.3.1
fi

# small fix for panda3d and cmake 3.13
mkdir -p "${HOST}/lib/python${PYMAJOR}.${PYMINOR}/site-packages/panda3d"
touch "${HOST}/lib/python${PYMAJOR}.${PYMINOR}/site-packages/panda3d/__init__.py"


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

echo "
    * cross compilation begins
"


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


    # == that can be handy for debugging compile failures, put it in the shell too.
    export ACMAKE="$CMAKE -DANDROID_ABI=${ABI_NAME}\
 -DCMAKE_TOOLCHAIN_FILE=${BUILD_PREFIX}-${ABI_NAME}/toolchain.cmake\
 -DCMAKE_INSTALL_PREFIX=${APKUSR}"


    # ndk specifics

    export TOOLCHAIN=$NDK_HOME/toolchains/llvm/prebuilt/$HOST_TAG

    # except for armv7
    ABI=android
    unset PLATABI

    case "$ABI_NAME" in
        armeabi-v7a)
            PLATFORM_TRIPLET=armv7a-linux-androideabi
            PLATABI=android
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
            PLATFORM_TRIPLET=wasm32-unknown-emscripten
            ARCH=wasm32
            API=1
            ABI=emscripten
            LIBPYTHON=libpython${PYMAJOR}.${PYMINOR}.a
            ;;
        wasi32)
            PLATFORM_TRIPLET=wasm32-unknow-wasi
            ARCH=wasm32
            API=1
            ABI=wasi
            LIBPYTHON=libpython${PYMAJOR}.${PYMINOR}.a
            ;;
        wasi64)
            PLATFORM_TRIPLET=wasm64-unknow-wasi
            ARCH=wasm64
            API=1
            ABI=wasi
            LIBPYTHON=libpython${PYMAJOR}.${PYMINOR}.a
            ;;
        asmjs)
            PLATFORM_TRIPLET=asmjs-unknown-emscripten
            ARCH=asmjs
            API=1
            ABI=fastcomp
            LIBPYTHON=libpython${PYMAJOR}.${PYMINOR}.so
            echo "ASM.JS support has been dropped"
            exit 1
            ;;
    esac

    export ABI ABI_NAME API PLATFORM_TRIPLET LIBPYTHON
    export HOST_PLATFORM=${ARCH}_${API}_${PLATABI:-$ABI}

    unset PLATABI


    # == a shell for one arch, with a ready to use cmake cross compile command
    cat > $ORIGIN/shell.${ABI_NAME}.sh <<END
#!/bin/bash
. ${HOST}/${ABI_NAME}.sh

. ${ROOT}/bin/activate

export PKG_CONFIG_PATH=${APKUSR}/lib/pkgconfig

export CMAKE_INSTALL_PREFIX=${APKUSR}
export PREFIX=${APKUSR}

export PS1="[PyDK:$ABI_NAME] \w \$ "

export PYDK="${ORIGIN}"

ndk_build () {
    ndk-build \
 APP_PLATFORM=\${APP_PLATFORM} APP_ABI=\${APP_ABI} \
 NDK_PROJECT_PATH=. \
 APP_BUILD_SCRIPT=Android.mk \
 APP_ALLOW_MISSING_DEPS=true \
 PREFIX=${PREFIX} \
 CFLAGS=-fPIC \$@
}

acmake () {
        reset
        echo "  == cmake for target ${ABI_NAME} =="
        ${ACMAKE} \$@
}

aconfigure () {
        reset
        echo " == configure for target ${ABI_NAME} == "
        ./configure --target=${PLATFORM_TRIPLET} --host=${PLATFORM_TRIPLET} --build=${HOST_TRIPLET} --prefix=${APKUSR} \$@
}

if echo "script:\$1" |grep -q sh\$
then
    echo "Running ${ABI_NAME} script \$1"
    . \$1
fi

END



    mkdir -p ${BUILD_PREFIX}-${ABI_NAME}

    #FIXME: NDK

    cp ${ANDROID_HOME:-/usr/local/lib/android/sdk}/ndk-bundle/build/cmake/android-legacy.toolchain.cmake \
        ${BUILD_PREFIX}-${ABI_NAME}/


    if cd ${BUILD_PREFIX}-${ABI_NAME}
    then
        echo "


        Current architecture : $ABI_NAME HOST_PLATFORM = $HOST_PLATFORM
    ============================================================================

        "
    else
        echo "bad arch"
        continue
    fi

    if echo $PLATFORM_TRIPLET|grep -q wasm
    then
        break
    fi

    if echo $PLATFORM_TRIPLET|grep -q asmjs
    then
        break
    fi


    # for disposal of things we don't want to land in prebuilt folder
    export DISPOSE=${ROOT}/apkroot-${ABI_NAME}-discard

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

    # ndk 23 does not use proper triplet names in toolchain /bin folder
    # for
    # export AR=$TOOLCHAIN/bin/${NDK_PREFIX}-ar
    # export RANLIB=$TOOLCHAIN/bin/${NDK_PREFIX}-ranlib

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

    cat > ${BUILD_PREFIX}-${ABI_NAME}/toolchain.cmake <<END
set(ANDROID_NDK_ROOT ${NDK_HOME})
set(ANDROID_NDK ${NDK_HOME})
set(ANDROID_NATIVE_API_LEVEL ${API})
set(ANDROID_PLATFORM_LEVEL ${API})
set(ANDROID_PLATFORM "android-${API}")
set(ANDROID_ARCH ${ABI_NAME})
set(ANDROID_ABI ${ABI_NAME})
set(CMAKE_CROSSCOMPILING ON)
set(CMAKE_FIND_LIBRARY_PREFIXES lib)
set(CMAKE_FIND_LIBRARY_SUFFIXES .so)

#unset(CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES)
#unset(CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES)
list(APPEND CMAKE_PREFIX_PATH "${APKUSR}")


set(BZIP2_LIBRARIES "${APKUSR}/lib/libbz2.a")
set(BZIP2_INCLUDE_DIR "${APKUSR}/include")

set(HARFBUZZ_INCLUDE_DIRS "${APKUSR}/include/harfbuzz")
set(HARFBUZZ_LIBRARIES "${APKUSR}/lib/libharfbuzz.so")

set(HARFBUZZ_INCLUDE_DIR "${APKUSR}/include/harfbuzz")
set(HARFBUZZ_LIBRARY "${APKUSR}/lib/libharfbuzz.so")

#set(OGG_LIBRARY "${APKUSR}/lib/libogg.so")
#set(OGG_INCLUDE_DIR "${APKUSR}/include/ogg")
set(OGG_LIBRARIES "${APKUSR}/lib/libogg.so")
set(OGG_INCLUDE_DIRS "${APKUSR}/include")
set(OGG_FOUND YES)


set(CMAKE_CONFIGURATION_TYPES "Release")
set(CMAKE_BUILD_TYPE "Release")
set(LINK_OPTIONS -s)

END


    cat > ${HOST}/${ABI_NAME}.sh <<END
#!/bin/bash
export ANDROID_NDK_HOME=${NDK_HOME}
export STRIP=$STRIP
export READELF=$READELF
export AR=$AR
export AS=$AS
export LD=$LD
export CXX=$CXX
export CC=$CC
export RANLIB=$RANLIB

#ndk-build
export APP_PREFIX="${APKUSR}"
export APP_ABI=$ABI_NAME
export APP_PLATFORM=android-$API

export PATH=${NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin:${BUILD_TOOLS}:$BASEPATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH

END




    grep -v 'Using custom NDK path'  ${NDK_HOME}/build/cmake/android.toolchain.cmake >> ${BUILD_PREFIX}-${ABI_NAME}/toolchain.cmake

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
    unset ENV ROOT BUILD_PREFIX SUPPORT APKUSR PKG_CONFIG_PATH TOOLCHAIN UNITS URL_PYTHON3 HASH_PYTHON3
fi

# until webgl is merged into master
unset URL_PANDA3D
unset HASH_PANDA3D

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
export BITS=32
export ROOT="${ORIGIN}/${ENV}"
export BUILD_PREFIX="${ROOT}/build"
export CMAKE=${ROOT}/bin/cmake

export SUPPORT="${ORIGIN}/sources.${ENV}"
export APKUSR="${ROOT}/apkroot-${ABI_NAME}/usr"
export PKG_CONFIG_PATH="${APKUSR}/lib/pkgconfig"

# for disposal of things we don't want to land in prebuilt folder
export DISPOSE="${ROOT}/apkroot-${ABI_NAME}-discard"

echo " * checking host python"
mkdir -p ${ROOT}
. sources/python_host.sh

export TOOLCHAIN="${ORIGIN}/emsdk/emsdk_env.sh"

. $TOOLCHAIN
export PATH="$EMSDK/upstream/emscripten:$BASEPATH"

export WCMAKE="emcmake $CMAKE -DCMAKE_POSITION_INDEPENDENT_CODE=ON -Wno-dev -DCMAKE_INSTALL_PREFIX=${APKUSR}"

cat > ${HOST}/${ABI_NAME}.sh <<END
#!/bin/sh

export PATH=${HOST}/bin:${ROOT}/bin:${PYTHONPYCACHEPREFIX}/bin::/bin:/usr/bin:/usr/local/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HOST}/lib64:${HOST}/lib

. ${TOOLCHAIN}

export PATH="$EMSDK/upstream/emscripten/system/bin:$EMSDK/upstream/emscripten:$BASEPATH"

export PYDK="${ORIGIN}"

#export STRIP=STRIP
#export READELF=READELF
#export AR=AR
#export AS=AS
#export LD=LD
#export CXX=CXX
#export CC=CC
#export RANLIB=RANLIB

export PLATFORM_TRIPLET=${HOST_PLATFORM}

export WCMAKE="$WCMAKE"

END

# == a shell for one arch, with a ready to use cmake cross compile command
cat > $ORIGIN/shell.${ABI_NAME}.sh <<END
#!/bin/bash
. ${HOST}/${ABI_NAME}.sh

. ${ROOT}/bin/activate

export PKG_CONFIG_PATH="${APKUSR}/lib/pkgconfig"

export PS1="[PyDK:$ABI_NAME] \w \$ "

export PYDK="${ORIGIN}"

export CMAKE_INSTALL_PREFIX=${APKUSR}
export PREFIX="${APKUSR}"

# gather \$HOME/.local/bin

export HOME="${PYTHONPYCACHEPREFIX}"
rm "${PYTHONPYCACHEPREFIX}/.local"
ln -s "${PYTHONPYCACHEPREFIX}" "${PYTHONPYCACHEPREFIX}/.local"


wconfigure () {
    CC=emcc CXX=em++ ./configure --prefix=${APKUSR} \$@
}

wcmake () {
        reset
        echo "  == cmake for target ${ABI_NAME} =="
        echo $WCMAKE \$@
}

if echo "script:\$1" |grep -q sh\$
then
    echo "Running ${ABI_NAME} script \$1"
    . \$1
fi

END

export UNITS="openssl libffi python3 vorbis panda3d panda3dffi pcre2"

if [ -f "${SUPPORT}/cross_pip.wasm.sh" ]
then
    UNITS="$UNITS cross_pip"
else
    echo "
    ********************************************************************************
    cross-pip not found ${SUPPORT}/cross_pip.wasm.sh
    cross-modules wont't run, that means disabling *any* extra python modules
    ********************************************************************************
    "
fi

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
        if [ -f embuilt ]
        then
            echo "emsdk libs ready"
        else
            ALL="struct_info libfetch zlib bzip2 freetype harfbuzz ogg vorbis libpng bullet"
            ALL="$ALL libjpeg sdl2_image"
            for one in $ALL
            do
                embuilder --pic build $one
                embuilder build $one
            done
            touch embuilt
        fi
    else
        echo "bad arch"
        continue
    fi

    do_steps crosscompile

fi



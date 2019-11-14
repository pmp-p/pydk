#!/bin/sh
export HOST_TRIPLET=x86_64-linux-gnu
export HOST_TAG=linux-x86_64
export ENV=aosp
export CMAKE_VERSION=3.10.3
export ARCHITECTURES=${ARCHITECTURES:-"armeabi-v7a arm64-v8a x86 x86_64"}

export ANDROID_HOME=${ANDROID_HOME:-$(pwd)/android-sdk}
export NDK_HOME=${NDK_HOME:-${ANDROID_HOME}/ndk-bundle}

export DN=org.${DN}

export PYMAJOR=3

#UNITS="unit"

UNITS="bzip2 lzma libffi"


if true
then
    export PYMINOR=7
    export PYVER=${PYMAJOR}.${PYMINOR}.5
    UNITS="${UNITS} openssl_1_0_2t python_${PYMAJOR}_${PYMINOR}_5"
    PYTHON3_HASH=349ac7b4a9d399302542163fdf5496e1c9d1e5d876a4de771eec5acde76a1f8a

    export OPENSSL_VERSION="1.0.2t"
    OPENSSL_HASH=14cb464efe7ac6b54799b34456bd69558a749a4931ecfd9cf9f71d7881cac7bc
else
    export PYMINOR=8
    export PYVER=${PYMAJOR}.${PYMINOR}.0
    UNITS="${UNITS} openssl_1_1_1d python_${PYMAJOR}_${PYMINOR}_0"

    PYTHON3_HASH=fc00204447b553c2dd7495929411f567cc480be00c49b11a14aee7ea18750981

    export OPENSSL_VERSION="1.1.1d"
    OPENSSL_HASH=1e3a91bc1f9dfce01af26026f856e064eab4c8ee0a8f457b5ae30b40b8b711f2
fi

export LIBPYTHON=libpython${PYMAJOR}.${PYMINOR}.so





LIBFFI_HASH=403d67aabf1c05157855ea2b1d9950263fb6316536c8c333f5b9ab1eb2f20ecf
BZ2_HASH=ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269
PATCHELF_HASH=b3cb6bdedcef5607ce34a350cf0b182eb979f8f7bc31eae55a93a70a3f020d13
LZMA_HASH=3313fd2a95f43d88e44264e6b015e7d03053e681860b0d5d3f9baca79c57b7bf
SQLITE_HASH=8c5a50db089bd2a1b08dbc5b00d2027602ca7ff238ba7658fabca454d4298e60

# above are the defaults, can be overridden via CONFIG

if [ -f "CONFIG" ]
then
pwd
    . $(pwd)/CONFIG
fi

# optionnal urls for sources packages
if [ -f "CACHE_URL" ]
then
    . $(pwd)/CACHE_URL
else
    LIBFFI_URL="https://github.com/libffi/libffi/releases/download/v3.3-rc0/libffi-3.3-rc0.tar.gz"
    OPENSSL_URL="https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"
    BZ2_URL="https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz"
    PYTHON3_URL="https://github.com/python/cpython/archive/v${PYVER}.tar.gz"
    PATCHELF_URL="https://github.com/NixOS/patchelf/archive/0.10.tar.gz"
    LZMA_URL="https://tukaani.org/xz/xz-5.2.4.tar.bz2"
    SQLITE_URL="https://www.sqlite.org/2019/sqlite-autoconf-3300100.tar.gz"
fi

UNITS="$UNITS openal panda3d"


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


OLD_PATH=$PATH
ORIGIN=$(pwd)
ROOT="${ORIGIN}/${ENV}"
HOST="${ORIGIN}/${ENV}/host"
BUILD_PREFIX="${ROOT}/build"
BUILD_SRC=${ROOT}/src

export SUPPORT=${ORIGIN}/sources.${ENV}

PYSRC="${BUILD_SRC}/python3-prefix/src/python3"
PATCHELF_SRC="${BUILD_SRC}/patchelf-prefix/src/patchelf"
ADBFS_SRC="${BUILD_SRC}/adbfs-prefix/src/adbfs"
LZMA_SRC="${BUILD_SRC}/lzma-prefix/src/lzma"

export CMAKE=${ROOT}/bin/cmake

export APK=/data/data/${DN}.${APP}

export PYTHONDONTWRITEBYTECODE=1

if echo $CI|grep -q true
then
    echo "CI-force-test python3.6, ncpu=4"
    JOBS=4
    export PYTHON=/usr/local/bin/python3.6
else
    for py in 8 7 6 5
    do
        if command -v python3.${py}
        then
            export PYTHON=$(command -v python3.${py})
            break
        fi
    done
fi


if echo $PYTHON |grep -q python3.6
then
    CI=true
    JOBS=${JOBS:-8}
    JFLAGS="-s -j $JOBS"
    if [ -d ${ENV} ]
    then
        echo " * using previous build dir ${ROOT} (CI)"
    else
        echo " * create venv ${ROOT} (CI)"
        #pclinuxos 3.6.5 --without-pip  ?
        $PYTHON -m venv --prompt pydk-${ENV} ${ENV}
        touch ${ENV}/new_env
    fi
else
    CI=false
    JOBS=${JOBS:-4}
    JFLAGS="-j $JOBS"
    if [ -d ${ENV} ]
    then
        echo " * using previous build dir ${ROOT}"
    else
        echo " * create venv ${ROOT}"
        $PYTHON -m venv --prompt pydk-${ENV} ${ENV}
        touch ${ENV}/new_env
    fi
fi


cd ${ROOT}

. bin/activate

cd ${ROOT}

mkdir -p ${BUILD_SRC}

date > ${BUILD_SRC}/build.log
env >> ${BUILD_SRC}/build.log
echo  >> ${BUILD_SRC}/build.log
echo  >> ${BUILD_SRC}/build.log

if $CI
then
    echo CI - no pip upgrade
    export QUIET="1>/dev/null"
else
    pip3 install --upgrade pip
fi

if [ -f new_env ]
then

    if pip3 install scikit-build
    then
        if pip3 install "cmake==${CMAKE_VERSION}"
        then
            rm new_env
        fi
    fi
fi

export UNITS
export JFLAGS


#function step {
step () {
    if $CI
    then
        echo
        echo "== CI $1: now in $3-$2 =="
        echo
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
    echo "  + adding $unit"
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
    URL ${PATCHELF_URL}
    URL_HASH SHA256=${PATCHELF_HASH}

    DOWNLOAD_NO_PROGRESS ${CI}

    PATCH_COMMAND "./bootstrap.sh"
    CONFIGURE_COMMAND sh -c "cd ${PATCHELF_SRC} && ./configure --prefix=${HOST}"
    BUILD_COMMAND sh -c "cd ${PATCHELF_SRC} && make"
    INSTALL_COMMAND sh -c "cd ${PATCHELF_SRC} && make install"
)

# license BSD https://github.com/spion/adbfs-rootless/blob/master/license

ExternalProject_Add(
    adbfs
    GIT_REPOSITORY https://github.com/spion/adbfs-rootless.git
    GIT_TAG ba64c22dbd373499eea9c9a9d2a9dd1cd25c33e1 # 14 july 2019

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
        $CMAKE .. >/dev/null && make ${JFLAGS} >/dev/null
    else
        $CMAKE .. && make ${JFLAGS}
    fi
    echo "  -> host tools now in CMAKE_INSTALL_PREFIX=${HOST}"
fi


# == can't save space here with patching an existing host source python tree after a cleanup
# == because we may need a full sourcetree+host python too for some complex libs (eg Panda3D )

do_steps patch


cd ${ROOT}

PrepareBuild () {
    cd ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}

    echo " * configure target==$1 ${PLATFORM_TRIPLET}"

    mkdir -p $1-${ANDROID_NDK_ABI_NAME}
    cd $1-${ANDROID_NDK_ABI_NAME}
}

Building () {
    PrepareBuild $1
    /bin/cp -aRfxp ${BUILD_SRC}/$1-prefix/src/$1/. ./
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



    # == that env file can be handy for debugging compile failures.

    cat > $ROOT/${ANDROID_NDK_ABI_NAME}.sh <<END
#!/bin/sh
export STRIP=$STRIP
export READELF=$READELF
export AR=$AR
export AS=$AS
export LD=$LD
export CXX=$CXX
export CC=$CC
export RANLIB=$RANLIB

export PATH=/bin:/usr/bin:/usr/local/bin:${HOST}/bin

END

    # == set up the basic cmake toolchain


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

END


    grep -v 'Using custom NDK path'  ${NDK_HOME}/build/cmake/android.toolchain.cmake >> ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/toolchain.cmake

    # == building bzip2

    # == building xz liblzma

    # == building libffi

    # == building openssl

    # == building python

    do_steps crosscompile
done


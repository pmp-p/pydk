#!/bin/sh

export PYTHON3_URL=${PYTHON3_URL:-"URL https://github.com/python/cpython/archive/v${PYVER}.tar.gz"}


if [ "$PYVER" == "3.7.5" ]; then
    export PYTHON3_HASH=${PYTHON3_HASH:-"URL_HASH SHA256=349ac7b4a9d399302542163fdf5496e1c9d1e5d876a4de771eec5acde76a1f8a"}
fi

if [ "$PYVER" == "3.8.0" ]; then
    export PYTHON3_HASH=${PYTHON3_HASH:-"URL_HASH SHA256=fc00204447b553c2dd7495929411f567cc480be00c49b11a14aee7ea18750981"}
fi


#REPOSITORY https://github.com/python/cpython.git
#TAG 4082f600a5bd69c8f4a36111fa5eb197d7547756 # 3.7.5rc1



export PYDROID="${BUILD_SRC}/python3-android"

export PYOPTS="--without-gcc --without-pymalloc --without-pydebug\
 --disable-ipv6 --without-ensurepip --with-c-locale-coercion\
 --enable-shared --with-computed-gotos"


#for arm: ac_cv_mixed_endian_double=yes
# ac_cv_little_endian_double=yes



python_ac_cv_patch () {
    cat >$1 <<END
ac_cv_little_endian_double=yes
ac_cv_file__dev_ptmx=yes
ac_cv_file__dev_ptc=no


ac_cv_func_pwrite=no
ac_cv_func_pwritev=no
ac_cv_func_pwritev2=no


ac_cv_lib_util_forkpty=no

ac_cv_func_getspnam=no
ac_cv_func_getspent=no
ac_cv_func_getgrouplist=no

ac_cv_header_uuid_h=no
ac_cv_header_uuid_uuid_h=no

ac_cv_func_wcsftime=no
ac_cv_func_crypt_r=no
ac_cv_search_crypt_r=no
END

}



python_module_setup_local () {
    cat > $1 <<END
*static*

_struct _struct.c   # binary structure packing/unpacking
_queue _queuemodule.c
parser parsermodule.c

math mathmodule.c _math.c # -lm # math library functions, e.g. sin()
cmath cmathmodule.c  # -lm # complex math library functions

#_weakref _weakref.c
#_codecs _codecsmodule.c         # access to the builtin codecs and codec registry
#_weakref _weakref.c         # weak references
#_functools _functoolsmodule.c   # Tools for working with functions and callable objects
#_operator _operator.c   # operator.add() and similar goodies
#itertools itertoolsmodule.c    # Functions creating iterators for efficient looping
#time timemodule.c # -lm # time operations and variables
#_sre _sre.c             # Fredrik Lundh's new regular expressions
#_collections _collectionsmodule.c # Container types

_datetime _datetimemodule.c # datetime accelerator

array arraymodule.c # array objects
_contextvars _contextvarsmodule.c


_random _randommodule.c # Random number generator



_bisect _bisectmodule.c # Bisection algorithms
_json _json.c
binascii binascii.c
#asyncio req
select selectmodule.c
fcntl fcntlmodule.c
_sha1 sha1module.c
_sha256 sha256module.c
_sha512 sha512module.c
_md5 md5module.c
#
termios termios.c
_sha3 _sha3/sha3module.c
_blake2 _blake2/blake2module.c _blake2/blake2b_impl.c _blake2/blake2s_impl.c
#aiohttp
unicodedata unicodedata.c
zlib zlibmodule.c -DUSE_ZLIB_CRC32 -lz
#future_builtins future_builtins.c

_heapq _heapqmodule.c   # Heap queue algorithm
_pickle _pickle.c   # pickle accelerator
_posixsubprocess _posixsubprocess.c  # POSIX subprocess module helper

_socket socketmodule.c

_lzma _lzmamodule.c -I${APKUSR}/include -L${APKUSR}/lib ${APKUSR}/lib/liblzma.a

_bz2 _bz2module.c -I${APKUSR}/include -L${APKUSR}/lib  ${APKUSR}/lib/libbz2.a

_hashlib _hashopenssl.c -I${APKUSR}/include -L${APKUSR}/lib -lsslpython -lcryptopython
_ssl _ssl.c -DUSE_SSL -I${APKUSR}/include -L${APKUSR}/lib -lsslpython -lcryptopython #${APKUSR}/lib/libssl.a ${APKUSR}/lib/libcrypto.a

_elementtree -I${PYDROID}/Modules/expat -DHAVE_EXPAT_CONFIG_H -DUSE_PYEXPAT_CAPI _elementtree.c # elementtree accelerator

_ctypes _ctypes/_ctypes.c \
 _ctypes/callbacks.c \
 _ctypes/callproc.c \
 _ctypes/stgdict.c \
 _ctypes/cfield.c -I${PYDROID}/Modules/_ctypes -I${APKUSR}/include -L${APKUSR}/lib -lffi # ${APKUSR}/lib/libffi.a

_decimal _decimal/_decimal.c \
 _decimal/libmpdec/basearith.c \
 _decimal/libmpdec/constants.c \
 _decimal/libmpdec/context.c \
 _decimal/libmpdec/convolute.c \
 _decimal/libmpdec/crt.c \
 _decimal/libmpdec/difradix2.c \
 _decimal/libmpdec/fnt.c \
 _decimal/libmpdec/fourstep.c \
 _decimal/libmpdec/io.c \
 _decimal/libmpdec/memory.c \
 _decimal/libmpdec/mpdecimal.c \
 _decimal/libmpdec/numbertheory.c \
 _decimal/libmpdec/sixstep.c \
 _decimal/libmpdec/transpose.c \
 -DCONFIG_${BITS} -DANSI -I${PYDROID}/Modules/_decimal/libmpdec

END
}


python3_host_cmake () {

cat >> CMakeLists.txt <<END
ExternalProject_Add(
    python3
    DEPENDS openssl
    DEPENDS libffi
    DEPENDS bz2
    DEPENDS lzma
    DEPENDS sqlite3
    ${PYTHON3_URL}
    ${PYTHON3_HASH}

    DOWNLOAD_NO_PROGRESS ${CI}

    PATCH_COMMAND sh -c "/bin/cp -aRfxp ${PYSRC} ${PYDROID}"

    CONFIGURE_COMMAND sh -c "cd ${PYSRC} && CC=clang ./configure --prefix=${HOST} --with-cxx-main=clang $PYOPTS >/dev/null"

    BUILD_COMMAND sh -c "cd ${PYSRC} && make ${JFLAGS}"

    INSTALL_COMMAND sh -c "cd ${PYSRC} && make ${JFLAGS} install >/dev/null 2>&1"
)
END

}


python3_patch () {

    cd ${PYDROID}

    if [ -f Patched ]
    then
        echo " * Python-${PYVER} tree already patched"
    else
        for PATCH in ${SUPPORT}/Python-${PYVER}/*.diff
        do
            echo " * applying ${PATCH}"
            patch -p1 < ${PATCH}
        done
        touch Patched

        # prevent __pycache__ filling up everywhere
        > ./Lib/compileall.py

        #remove the binary blobs
        rm -f ./Python/importlib.h ./Python/importlib_external.h
    fi

    # without regen importlib is a binary blob ! Use the host python build process to regen the target one then clean up
    # make regen-importlib
    if [ -f ./Python/importlib_external.h ]
    then
        echo
        echo "  ***********************************************************************"
        echo "  **    warning : re-using binary blobs found in python source tree    **"
        echo "  ***********************************************************************"
        echo
    else
        echo " - regenerating importlib binary blobs -"

        #make it closer to target parameters
        python_ac_cv_patch config.site
        echo "CONFIG_SITE=config.site CC=clang ./configure --prefix=${HOST} --with-cxx-main=clang $PYOPTS" > build.sh
        chmod +x build.sh

        if ./build.sh >/dev/null
        then
        cat >> pyconfig.h << END
#ifdef HAVE_CRYPT_H
#undef HAVE_CRYPT_H
#endif
END
            if $CI
            then
                make ${JFLAGS} regen-importlib
                make ${JFLAGS} clean
            else
                make ${JFLAGS} regen-importlib >/dev/null
                make ${JFLAGS} clean >/dev/null
            fi
        fi
    fi
}



python_configure () {

    cp $ROOT/${ANDROID_NDK_ABI_NAME}.sh $1
    cat >> $1 <<END

export _PYTHON_PROJECT_SRC=${PYDROID}
export _PYTHON_PROJECT_BASE=$(pwd)
export PYTHONDONTWRITEBYTECODE=1
export APKUSR=${APKUSR}


$CXX -shared -fPIC -Wl,-soname,libbrokenthings.so -o ${APKUSR}/lib/libbrokenthings.so ${SUPPORT}/ndk_api19/brokenthings.cpp

#${APKUSR}/lib/libbz2.a ${APKUSR}/lib/liblzma.a
#-lbz2 -llzma

PKG_CONFIG_PATH=${APKUSR}/lib/pkgconfig \\
PLATFORM_TRIPLET=${PLATFORM_TRIPLET} \\
CONFIG_SITE=config.site \\
 CFLAGS="$CFLAGS" \\
 \${_PYTHON_PROJECT_SRC}/configure --with-libs='-L${APKUSR}/lib -lbrokenthings -lstdc++ -lz -lm' \\
 --with-openssl=${APKUSR} --host=${PLATFORM_TRIPLET} --build=${HOST_TRIPLET} --prefix=${APKUSR} \\
 $PYOPTS 2>&1 >> ${BUILD_SRC}/build.log

if [ -f Makefile ]
then
    cat >>pyconfig.h <<DEF
#ifndef HAVE_FORK
#define HAVE_FORK 1
#endif
DEF
    if $CI
    then
        echo building cpython
    else
        TERM=linux reset
    fi

    make ${JFLAGS} install | egrep -v "install|Creating|copying|renaming"

    mv -vf ${PYLIB}/_sysconfigdata__linux_${ARCH}-linux-${ABI}.py ${PYASSETS}/_sysconfigdata__android_${ARCH}-linux-${ABI}.py
else
    echo ================== ${BUILD_SRC}/build.log ===================
    tail -n 30 ${BUILD_SRC}/build.log
    echo "Configuration failed for $PLATFORM_TRIPLET"
    env
fi
END


}


python3_crosscompile () {

    # prebuilt/<arch>/ is the final place for libpython
    # but prefix is set to <apk>/usr
    # because a lot of python <prefix>/lib/* can't go in apk private <apk>/lib folder on device

    # in case of on board sdk it may be usefull to keep the <apk>/usr full tree
    # with the static libs without conflicting with that "apk root" lib folder

    if [ -f ${APKUSR}/lib/$LIBPYTHON ]
    then

        echo "    -> $LIBPYTHON already built for $ANDROID_NDK_ABI_NAME"

    else
        echo " * configure target==$LIBPYTHON $PLATFORM_TRIPLET"

        cd ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}

        mkdir -p python3-${ANDROID_NDK_ABI_NAME}
        cd python3-${ANDROID_NDK_ABI_NAME}

        _PYTHON_PROJECT_SRC=${PYDROID}
        _PYTHON_PROJECT_BASE=$(pwd)

        # defined in ${ORIGIN}/patch/Python-${PYVER}.config

        python_ac_cv_patch config.site

        mkdir -p Modules

        python_module_setup_local Modules/Setup.local

        [ -f Makefile ] && make clean && rm Makefile


# NDK also defines -ffunction-sections -funwind-tables but they result in worse OpenCV performance (Amos Wenger)

        export CFLAGS="-m${BITS} -D__USE_GNU -fPIC -target ${PLATFORM_TRIPLET}${API} -include ${SUPPORT}/ndk_api19/ndk_fix.h -isysroot $TOOLCHAIN/sysroot -isystem $TOOLCHAIN/sysroot/usr/include"

        export PYLIB=${APKUSR}/lib/python${PYMAJOR}.${PYMINOR}

        # == layout a specific folder that will merge all platforms specifics.

        export PYASSETS=${ORIGIN}/assets/python${PYMAJOR}.${PYMINOR}

        mkdir -p ${PYASSETS}

        # == prepare the cross configure + build file for cpython

        python_configure ./build.sh


        # == need a very clean env for true reproducibility

        env -i sh build.sh

        unset CFLAGS


        # == cleanup a bit, as PYTHONDONTWRITEBYTECODE respect may not be perfect

        echo " * cleanup pycache folders"

        rm -rf $(find ${_PYTHON_PROJECT_SRC}/Lib/ -type d|grep __pycache__$)
        rm -rf $(find ${PYLIB}/ -type d|grep __pycache__$)


        # we could just want to keep lib-dynload later
        # sysconfig has already been moved.

        # idea : keep testsuite support on cdn ?
        MOVE_TO_USR="site-packages lib-dynload test unittest lib2to3 contextlib.py argparse.py"

        echo " * move files not suitable for zipimport usage"

        for move in $MOVE_TO_USR
        do
            mv -vf ${PYLIB}/${move} ${DISPOSE}/
        done

        #mv -vf ${PYLIB} ${DISPOSE}/  ?Directory not empty?
        rm -rf ${PYLIB}

        mkdir -p ${PYLIB}

        # those cannot be loaded from the apk zip archive while running testsuite
        # could also be optionnal in most use cases.
        for move in $MOVE_TO_USR
        do
            mv -vf ${DISPOSE}/${move} ${PYLIB}/
        done

        echo " * copy final libs to prebuilt folder"

        if [ -f ${APKUSR}/lib/${LIBPYTHON} ]
        then

            # == default rights would prevent patching.

            chmod u+w ${APKUSR}/lib/lib*.so


            # == this will fix most ndk link problems
            # == also get rid of unfriendly (IMPORTED_NO_SONAME ON) requirement with cmake

            ${HOST}/bin/patchelf --set-soname ${LIBPYTHON} ${APKUSR}/lib/${LIBPYTHON}

            mkdir -p ${ORIGIN}/prebuilt/${ANDROID_NDK_ABI_NAME}
            #mv ${APKUSR}/lib/lib*.so ${ORIGIN}/prebuilt/${ANDROID_NDK_ABI_NAME}/

            # keep a copy so module can cross compile

            /bin/cp -vf ${APKUSR}/lib/lib*.so ${ORIGIN}/prebuilt/${ANDROID_NDK_ABI_NAME}/
            echo " done"
        else
            break
        fi
    fi



    #export JAVA_HOME=/opt/sdk/jdk
    #export CROSS_COMPILE=armv7a-linux-androideabi
    #. ${ROOT}/${ANDROID_ABI}.sh
    #export _PYTHON_SYSCONFIGDATA_NAME=_sysconfigdata__android_armv7a-linux-androideabi
    #export __ANDROID__=1

    #export ANDROID_NDK_HOME=${NDK_HOME}

    . ${ORIGIN}/cross-build.sh

}






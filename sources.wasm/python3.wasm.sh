#!/bin/sh

# defined in python_host : URL_PYTHON3 PYOPTS PYTARGET


#for arm: ac_cv_mixed_endian_double=yes
# ac_cv_little_endian_double=yes
# ac_cv_func_forkpty=no ?

python_ac_cv_patch () {
    cat >$1 <<END
ax_cv_c_float_words_bigendian=no
ac_cv_little_endian_double=yes

ac_cv_func_epoll_create=no
ac_cv_func_epoll_create1=no
ac_cv_header_linux_vm_sockets_h=no

ac_cv_func_socketpair=no
ac_cv_func_utimensat=no
ac_cv_buggy_getaddrinfo=no


# Syscalls that resulted in a segfault
ac_cv_func_utimensat=no
ac_cv_header_sys_ioctl_h=no

# Syscalls not implemented in emscripten
ac_cv_func_preadv2=no
ac_cv_func_preadv=no
ac_cv_func_pwritev2=no
ac_cv_func_pwritev=no
ac_cv_func_pipe2=no
ac_cv_func_nice=no

# aborts with bad ioctl
ac_cv_func_openpty=no
ac_cv_func_forkpty=no
ac_cv_file__dev_ptmx=no
ac_cv_file__dev_ptc=no

ac_cv_func_plock=no
ac_cv_func_getentropy=no
ac_cv_have_chflags=no
ac_cv_have_lchflags=no
ac_cv_func_sigaltstack=no

ac_cv_func_getgroups=no
ac_cv_func_setgroups=no
ac_cv_func_getpgrp=no
ac_cv_func_setpgrp=no

ac_cv_func_getresuid=no
ac_cv_func_seteuid=no
ac_cv_func_setresuid=no
ac_cv_func_setreuid=no
ac_cv_func_setuid=no


ac_cv_func_wcsftime=no
ac_cv_func_sigaction=no

ac_cv_func_sigrtmin=no
ac_cv_func_sigrtmax=no
ac_cv_func_siginterrupt=no

ac_cv_func_mknod=no

ac_cv_func_pwrite=no
ac_cv_func_pwritev=no
ac_cv_func_pwritev2=no

ac_cv_func_pread=no
ac_cv_func_preadv=no
ac_cv_func_preadv2=no

ac_cv_func_dup2=yes
ac_cv_func_dup3=no
ac_cv_func_dlopen=yes

ac_cv_func_posix_spawn=no
ac_cv_func_posix_spawnp=no
ac_cv_func_eventfd=no
ac_cv_func_memfd_create=no
ac_cv_func_prlimit=no

ac_cv_pthread_is_default=yes
ac_cv_pthread=no
ac_cv_kthread=no

ac_cv_func_clock_nanosleep=no
ac_cv_lib_rt_clock_nanosleep=no
ac_cv_func_clock_gettime=yes

ac_cv_header_uuid_uuid_h=yes

ac_cv_prog_ac_ct_READELF=true
END

}



python_module_setup_local () {
    # or link Modules/_decimal/libmpdec/libmpdec.a Modules/expat/libexpat.a at final stage
    cat > $1 <<END
*disabled*
_decimal
_elementtree
pyexpat
END

cat > /dev/null << END
*static*

_struct _struct.c   # binary structure packing/unpacking
_queue _queuemodule.c

#3.11- parser parsermodule.c

#3.11- math mathmodule.c _math.c # -lm # math library functions, e.g. sin()
math mathmodule.c

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


# Modules/_hashopenssl.c:23:10: fatal error: 'openssl/evp.h' file not found
_hashlib _hashopenssl.c  -I${APKUSR}/include -L${APKUSR}/lib -lssl -lcrypto
_ssl _ssl.c -DUSE_SSL -I${APKUSR}/include -L${APKUSR}/lib\
 -lssl -lcrypto #${APKUSR}/lib/libssl.a ${APKUSR}/lib/libcrypto.a

#_elementtree -I${PYTARGET}/Modules/expat -DHAVE_EXPAT_CONFIG_H -DUSE_PYEXPAT_CAPI _elementtree.c
# elementtree accelerator


#TODO:
_uuid _uuidmodule.c

_ctypes _ctypes/_ctypes.c \
 _ctypes/callbacks.c \
 _ctypes/callproc.c \
 _ctypes/stgdict.c \
 _ctypes/cfield.c -I${PYTARGET}/Modules/_ctypes -I${APKUSR}/include\
 -L${APKUSR}/lib -lffi ${APKUSR}/lib/libffi.a

# $(pkg-config libffi --libs-only-L --cflags-only-I)

# _decimal/libmpdec/memory.c

_decimal _decimal/_decimal.c -DCONFIG_${BITS} -DANSI -I${PYTARGET}/Modules/_decimal/libmpdec

# -DCONFIG_${BITS} -DANSI -I${PYTARGET}/Modules/_decimal/libmpdec ${_PYTHON_PROJECT_BASE}/Modules/_decimal/libmpdec/libmpdec.a

#

END
}



python3_host_cmake () {

cat >> CMakeLists.txt <<END

if(1)
    message("")
    message(" processing unit : ${unit}")
ExternalProject_Add(
    python3
    DEPENDS openssl
    DEPENDS libffi
    DEPENDS bz2
    DEPENDS lzma
    DEPENDS sqlite3
    ${URL_PYTHON3}
    ${HASH_PYTHON3}

    DOWNLOAD_NO_PROGRESS ${CI}

    PATCH_COMMAND sh -c "/bin/cp -aRfxp ${PYSRC} ${PYTARGET}"

    CONFIGURE_COMMAND sh -c "cd ${PYSRC} && CC=clang ./configure --prefix=${HOST} --with-cxx-main=clang $PYOPTS --with-ensurepip  >/dev/null"

    BUILD_COMMAND sh -c "cd ${PYSRC} && make ${JFLAGS}"

    INSTALL_COMMAND sh -c "cd ${PYSRC} && make ${JFLAGS} install >/dev/null 2>&1"
)
else()
    message(" ********************************************************************")
    message("  No cmake ExternalProject_Add defined for unit : ${unit}")
    message(" ********************************************************************")
endif()

END

}


python3_patch () {

    cd ${PYTARGET}

    if [ -f Patched ]
    then
        echo " * Python-${PYVER} tree already patched in ${PYTARGET}"
    else
        for PATCH in ${SUPPORT}/Python-${PYVER}/*.diff
        do
            echo " * applying ${PATCH} to ${PYTARGET}"
            patch -p1 < ${PATCH}
        done

        touch Patched

        # prevent __pycache__ filling up everywhere
        > ./Lib/compileall.py

        # remove the binary blobs
        #rm -f ./Python/importlib.h ./Python/importlib_external.h
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
        echo " - not regenerating importlib binary blobs for $PLATFORM_TRIPLET-"
    fi
}



python_configure () {

    cp ${HOST}/${ABI_NAME}.sh $1

    #dropped support for asm.js
    EM_MODE=""
    # nope -s ENVIRONMENT=web
    EM_FLAGS="-fPIC -Os -g0"

    cat >> $1 <<END
#======== adding to ${HOST}/${ABI_NAME}.sh

export _PYTHON_PROJECT_SRC=${PYTARGET}
export _PYTHON_PROJECT_BASE=$(pwd)
export PYTHONDONTWRITEBYTECODE=1
export PYTHONPYCACHEPREFIX=${ORIGIN}/pycache
export APKUSR=${APKUSR}

# hasardous fix for libatomic
# export LDFLAGS="-Wl,--shared-memory,--no-check-features"

# -s EXPORT_ALL=1
export LDFLAGS="-s USE_ZLIB=1 -s SOCKET_WEBRTC=0 -s SOCKET_DEBUG=1"
export CPPFLAGS='$EM_FLAGS'
export CXXFLAGS='$EM_FLAGS'
export CFLAGS='$EM_FLAGS'

# --with-libs='-L${APKUSR}/lib -lz -lm'

PKG_CONFIG_PATH=${APKUSR}/lib/pkgconfig\\
 PLATFORM_TRIPLET=${HOST_PLATFORM} \\
 CONFIG_SITE=config.site READELF=true\\
 emconfigure \${_PYTHON_PROJECT_SRC}/configure \\
 --with-build-python=${HOST}/bin/python3 --with-emscripten-target=browser \\
 --cache-file=${SUPPORT}/cache.${API}.${PLATFORM_TRIPLET} \\
 --host=wasm${BITS}-unknown-emscripten --build=${HOST_TRIPLET} --prefix=${APKUSR}\\
 $PYOPTS --without-ensurepip\\

# not needed just want lib not exe  --with-libs="-Wl,--shared-memory,--no-check-features -pthread"

# 2>&1 >> ${BUILD_SRC}/build.log

if [ -f Makefile ]
then
    cat >>pyconfig.h <<DEF

// added by python3.wasm.sh

#ifdef HAVE_FORK
    #undef HAVE_FORK
#endif

#ifdef HAVE_FORK_PTY
    #undef HAVE_FORK_PTY
#endif

#ifndef HAVE_TIMEGM
#define HAVE_TIMEGM 1
#endif

#ifndef HAVE_CLOCK
#define HAVE_CLOCK 1
#endif

#ifndef HAVE_COPYSIGN
#define HAVE_COPYSIGN 1
#endif

#ifndef HAVE_HYPOT
#define HAVE_HYPOT 1
#endif

#ifndef HAVE_DUP2
#define HAVE_DUP2 1
#endif

#undef HAVE_UUID_GENERATE_TIME_SAFE
#undef HAVE_UUID_ENC_BE
#undef HAVE_UUID_CREATE

#define uuid_generate_time uuid_generate

#define GOSH_MOVE_THEM 1
// /python3.wasm.sh

DEF

    if $CI
    then
        echo building cpython
    else
        TERM=linux reset
    fi

    . $TOOLCHAIN

    export PATH="$EMSDK/upstream/emscripten:$BASEPATH"

    emmake make inclinstall
    emmake make libinstall
    emmake make install
    EMCC_CFLAGS="-I${APKUSR}/include" emmake make install
else
    echo ================== ${BUILD_SRC}/build.log ===================
    tail -n 30 ${BUILD_SRC}/build.log
    echo "Configuration failed for $PLATFORM_TRIPLET"
    exit 1
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

        echo "    -> $LIBPYTHON already built for $ABI_NAME"

    else
        echo " * configure target==$LIBPYTHON $PLATFORM_TRIPLET"

        mkdir -p ${BUILD_PREFIX}-${ABI_NAME}
        cd ${BUILD_PREFIX}-${ABI_NAME}

        mkdir -p python3-${ABI_NAME}
        cd python3-${ABI_NAME}

        _PYTHON_PROJECT_SRC=${PYTARGET}
        _PYTHON_PROJECT_BASE=$(pwd)

        # defined in ${ORIGIN}/patch/Python-${PYVER}.config

        python_ac_cv_patch config.site


        mkdir -p Modules



        python_module_setup_local Modules/Setup.local

        [ -f Makefile ] && make clean && rm Makefile

        #export CFLAGS="-m${BITS} -D__USE_GNU -fPIC -target ${PLATFORM_TRIPLET} -include ${SUPPORT}/ndk_api19/ndk_fix.h -isysroot $TOOLCHAIN/sysroot -isystem $TOOLCHAIN/sysroot/usr/include"

        export PYLIB=${APKUSR}/lib/python${PYMAJOR}.${PYMINOR}

        # == layout a specific folder that will merge all platforms specifics.

        export PYASSETS=${ORIGIN}/assets/python${PYMAJOR}.${PYMINOR}

        mkdir -p ${PYASSETS}



        # == prepare the cross configure + build file for cpython
        if [ -f ${PYTARGET}/configure ]
        then
            echo
        else
            make -C ${PYSRC} distclean
            echo "EXTRA PATCHING ${PYSRC} -> ${PYTARGET}"
            /bin/cp -aRfxp ${PYSRC} ${PYTARGET}
        fi

        python3_patch

        cd ${BUILD_PREFIX}-${ABI_NAME}/python3-${ABI_NAME}

        python_configure ./build.sh

        #===================================================
        # == need a very clean env for true reproducibility
        if env -i sh build.sh
        then
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
            #rm -rf ${PYLIB}

            mkdir -p ${PYLIB}

            # those cannot be loaded from the apk zip archive while running testsuite
            # could also be optionnal in most use cases.
            for move in $MOVE_TO_USR
            do
                mv -vf ${DISPOSE}/${move} ${PYLIB}/
            done

            echo " * copy final libs to prebuilt folder ${PYLIB}/"

        else
            echo "failed to configure+make for ${PLATFORM_TRIPLET}"
            break
        fi

    fi

}






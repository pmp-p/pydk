# atomics linking problem : https://github.com/emscripten-core/emscripten/issues/8503
# https://github.com/emscripten-core/emscripten/issues/10370
# -pthread -s ENVIRONMENT=web,worker
# -Wl,--shared-memory,--no-check-features


libffi_host_cmake () {
    #already done in aosp
    echo
}

libffi_patch () {
    echo

}


libffi_build () {
    echo
}

libffi_crosscompile () {
    if [ -f ${APKUSR}/lib/libffi.a ]
    then
        echo "    -> libffi already built for $ABI_NAME"
    else
        FFI_SRC="${BUILD_SRC}/libffi-prefix/src/libffi"

        cd "$FFI_SRC"

        if [ -f Patched ]
        then
            echo " * libffi-${LIBFFI_VERSION} tree already patched in ${FFI_SRC}"
        else
            for PATCH in ${SUPPORT}/libffi-${LIBFFI_VERSION}/*.diff
            do
                echo " * applying ${PATCH} to ${FFI_SRC}"
                patch -p1 < ${PATCH}
            done
            autoreconf -fi && touch Patched
        fi


        echo "Building libffi from ${FFI_SRC}"

        mkdir -p "${BUILD_PREFIX}-${ABI_NAME}/libffi-${ABI_NAME}"
        cd "${BUILD_PREFIX}-${ABI_NAME}/libffi-${ABI_NAME}"

        # NDK also defines -ffunction-sections -funwind-tables but they result in worse OpenCV performance (Amos Wenger)
        #export CFLAGS="-m${BITS} -fPIC -target ${PLATFORM_TRIPLET}${API} -isysroot $TOOLCHAIN/sysroot -isystem $TOOLCHAIN/sysroot/usr/include"

        export CFLAGS="-O3"
        export CXXFLAGS="$CFLAGS"
        export EMMAKEN_CFLAGS="-s USE_PTHREADS=1"

        CNF="--enable-static --disable-shared --disable-dependency-tracking\
  --disable-builddir --disable-multi-os-directory --disable-raw-api"

  #  --build=${HOST_TRIPLET} --target=wasm32-unknown-linux\

        if emconfigure ${FFI_SRC}/configure ${CNF} --host=wasm32-unknown-linux --prefix=${APKUSR} >/dev/null
        then
            std_make $unit
        else
            echo "ERROR $unit"
            exit 1
        fi

        unset CFLAGS EMMAKEN_CFLAGS CXXFLAGS
    fi
}





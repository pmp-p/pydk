function libffi_host_cmake () {
    cat >> CMakeLists.txt <<END

#${unit}

ExternalProject_Add(
    libffi
    URL ${LIBFFI_URL}
    URL_HASH SHA256=${LIBFFI_HASH}

    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)

END
}

function libffi_patch () {
    echo
}

function libffi_build () {
    echo
}

function libffi_crosscompile () {
    if [ -f ${APKUSR}/lib/libffi.so ]
    then
        echo "    -> libffi already built for $ANDROID_NDK_ABI_NAME"
    else
        Building libffi

        # NDK also defines -ffunction-sections -funwind-tables but they result in worse OpenCV performance (Amos Wenger)
        export CFLAGS="-m${BITS} -fPIC -target ${PLATFORM_TRIPLET}${API} -isysroot $TOOLCHAIN/sysroot -isystem $TOOLCHAIN/sysroot/usr/include"

        if ./configure --target=${PLATFORM_TRIPLET} --host=${PLATFORM_TRIPLET} --build=${HOST_TRIPLET} --prefix=${APKUSR} && make && make install
        then
            echo "done"
        else
            break
        fi

        unset CFLAGS
    fi
}





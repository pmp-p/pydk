
export LIBFFI_URL=${LIBFFI_URL:-"URL https://github.com/libffi/libffi/releases/download/v3.3-rc0/libffi-3.3-rc0.tar.gz"}
export LIBFFI_HASH=${LIBFFI_HASH:-"URL_HASH SHA256=403d67aabf1c05157855ea2b1d9950263fb6316536c8c333f5b9ab1eb2f20ecf"}

libffi_host_cmake () {
    cat >> CMakeLists.txt <<END

if(1)
    message("")
    message(" processing unit : ${unit}")
ExternalProject_Add(
    libffi
    ${LIBFFI_URL}
    ${LIBFFI_HASH}

    DOWNLOAD_NO_PROGRESS ${CI}

    CONFIGURE_COMMAND sh -c "echo 1>&1;echo external.configure ${unit} 1>&2"
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)
else()
    message(" ********************************************************************")
    message("  No cmake ExternalProject_Add defined for unit : ${unit}")
    message(" ********************************************************************")
endif()

END
}

libffi_patch () {
    echo
}

libffi_build () {
    echo
}

libffi_crosscompile () {
    if [ -f ${APKUSR}/lib/libffi.so ]
    then
        echo "    -> libffi already built for $ANDROID_NDK_ABI_NAME"
    else
        Building libffi

        # NDK also defines -ffunction-sections -funwind-tables but they result in worse OpenCV performance (Amos Wenger)
        export CFLAGS="-m${BITS} -fPIC -target ${PLATFORM_TRIPLET}${API} -isysroot $TOOLCHAIN/sysroot -isystem $TOOLCHAIN/sysroot/usr/include"

        if ./configure ${CNF} --target=${PLATFORM_TRIPLET} --host=${PLATFORM_TRIPLET} --build=${HOST_TRIPLET} --prefix=${APKUSR} >/dev/null
        then
            std_make $unit
        else
            echo "ERROR $unit"
            exit 1
        fi

        unset CFLAGS
    fi
}





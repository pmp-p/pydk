#https://github.com/libffi/libffi/releases/download/v3.3-rc0/libffi-3.3-rc0.tar.gz"}
#403d67aabf1c05157855ea2b1d9950263fb6316536c8c333f5b9ab1eb2f20ecf"}

#URL http://sourceware.org/pub/libffi/libffi-3.3.tar.gz"}
export URL_LIBFFI=${URL_LIBFFI:-"URL https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz"}
export HASH_LIBFFI=${HASH_LIBFFI:-"URL_HASH SHA256=72fba7922703ddfa7a028d513ac15a85c8d54c8d67f55fa5a4802885dc652056"}



libffi_host_cmake () {
    cat >> CMakeLists.txt <<END

if(1)
    message("")
    message(" processing unit : ${unit}")
ExternalProject_Add(
    libffi
    ${URL_LIBFFI}
    ${HASH_LIBFFI}

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
        echo "    -> libffi already built for $ABI_NAME"
    else
        Building libffi

        # NDK also defines -ffunction-sections -funwind-tables but they result in worse OpenCV performance (Amos Wenger)
        export CFLAGS="-m${BITS} -fPIC -target ${PLATFORM_TRIPLET}${API} -isysroot $TOOLCHAIN/sysroot -isystem $TOOLCHAIN/sysroot/usr/include"

        if ./configure --enable-shared=no --enable-static=yes \
 ${CNF} --target=${PLATFORM_TRIPLET} --host=${PLATFORM_TRIPLET} --build=${HOST_TRIPLET} --prefix=${APKUSR} >/dev/null
        then
            std_make $unit
        else
            echo "ERROR $unit"
            exit 1
        fi

        unset CFLAGS
    fi
}





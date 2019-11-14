lzma_host_cmake () {
    cat >> CMakeLists.txt <<END

#${unit}
ExternalProject_Add(
    lzma
    URL ${LZMA_URL}
    URL_HASH SHA256=${LZMA_HASH}

    DOWNLOAD_NO_PROGRESS ${CI}

    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)

END
}

lzma_patch () {
    echo
}

lzma_build () {
    echo
}

lzma_crosscompile () {

    if [ -f ${APKUSR}/lib/liblzma.a ]
    then
        echo "    -> liblzma already built for $ANDROID_NDK_ABI_NAME"
    else
        Building lzma

        export CFLAGS="-m${BITS} -fPIC -target ${PLATFORM_TRIPLET}${API} -isysroot $TOOLCHAIN/sysroot -isystem $TOOLCHAIN/sysroot/usr/include"
        if ./configure --target=${PLATFORM_TRIPLET} --host=${PLATFORM_TRIPLET} --build=${HOST_TRIPLET} --prefix=${APKUSR} && make && make install
        then
            echo done
        else
            break
        fi

        unset CFLAGS
    fi

}





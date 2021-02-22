
export URL_LZMA=${URL_LZMA:-"URL https://tukaani.org/xz/xz-5.2.4.tar.bz2"}
export LZMA_HASH=${LZMA_HASH:-"URL_HASH SHA256=3313fd2a95f43d88e44264e6b015e7d03053e681860b0d5d3f9baca79c57b7bf"}


lzma_host_cmake () {
    cat >> CMakeLists.txt <<END

#${unit}
ExternalProject_Add(
    lzma
    ${URL_LZMA}
    ${LZMA_HASH}

    DOWNLOAD_NO_PROGRESS ${CI}

    CONFIGURE_COMMAND sh -c "echo 1>&1;echo external.configure ${unit} 1>&2"
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
        echo "    -> liblzma already built for $ABI_NAME"
    else
        Building lzma

        export CFLAGS="-m${BITS} -fPIC -target ${PLATFORM_TRIPLET}${API} -isysroot $TOOLCHAIN/sysroot -isystem $TOOLCHAIN/sysroot/usr/include"
        if ./configure ${CNF} --target=${PLATFORM_TRIPLET} --host=${PLATFORM_TRIPLET} --build=${HOST_TRIPLET} --prefix=${APKUSR}
        then
            std_make $unit
        else
            echo "ERROR $unit"
            exit 1
        fi
        unset CFLAGS
    fi

}


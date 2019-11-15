
export BZ2_URL=${BZ2_URL:-"URL https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz"}
export BZ2_HASH=${BZ2_HASH:-"URL_HASH SHA256=ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269"}

bzip2_host_cmake () {
    cat >> CMakeLists.txt <<END

#${unit}
ExternalProject_Add(
    bz2
    ${BZ2_URL}
    ${BZ2_HASH}

    DOWNLOAD_NO_PROGRESS ${CI}

    CONFIGURE_COMMAND sh -c "echo 1>&1;echo external.configure ${unit} 1>&2"
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)

END
}

bzip2_patch () {
    echo
}

bzip2_build () {
    echo
}

bzip2_crosscompile () {
    if [ -f ${APKUSR}/lib/libbz2.a ]
    then
        echo "    -> libbz2 already built for $ANDROID_NDK_ABI_NAME"
    else
        Building bz2

        unset CFLAGS
        make ${JFLAGS} CC=$CC AR=$AR RANLIB=$RANLIB PREFIX=${APKUSR} bzip2 install
        unset CFLAGS

    fi
}





function bzip2_host_cmake () {
    cat >> CMakeLists.txt <<END

#${unit}
ExternalProject_Add(
    bz2
    URL ${BZ2_URL}
    URL_HASH SHA256=${BZ2_HASH}

    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)

END
}

function bzip2_patch () {
    echo
}

function bzip2_build () {
    echo
}

function bzip2_crosscompile () {
    if [ -f ${APKUSR}/lib/libbz2.a ]
    then
        echo "    -> libbz2 already built for $ANDROID_NDK_ABI_NAME"
    else
        Building bz2

        unset CFLAGS
        make CC=$CC AR=$AR RANLIB=$RANLIB PREFIX=${APKUSR} bzip2 install
        unset CFLAGS

    fi
}





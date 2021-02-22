
export URL_BZ2=${URL_BZ2:-"URL https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz"}
export HASH_BZ2=${HASH_BZ2:-"URL_HASH SHA256=ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269"}

bzip2_host_cmake () {
    cat >> CMakeLists.txt <<END

if(1)
    message("")
    message(" processing unit : ${unit}")
ExternalProject_Add(
    bz2
    ${URL_BZ2}
    ${HASH_BZ2}

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

bzip2_patch () {
    echo
}

bzip2_build () {
    echo
}

bzip2_crosscompile () {
    if [ -f ${APKUSR}/lib/libbz2.so ]
    then
        echo "    -> libbz2 already built for $ABI_NAME"
    else
        Building bz2

        unset CFLAGS
        make ${JFLAGS} CC=$CC AR=$AR RANLIB=$RANLIB PREFIX=${APKUSR} bzip2 install
        ${CC} -shared -Wl,-soname -Wl,libbz2.so -o ${APKUSR}/lib/libbz2.so blocksort.o \
  huffman.o    \
  crctable.o   \
  randtable.o  \
  compress.o   \
  decompress.o \
  bzlib.o
        unset CFLAGS

    fi
}





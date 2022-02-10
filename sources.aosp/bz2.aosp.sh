
export URL_BZ2=${URL_BZ2:-"URL https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz"}
export HASH_BZ2=${HASH_BZ2:-"URL_HASH SHA256=ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269"}

bz2_host_cmake () {
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

bz2_patch () {
    echo
}

bz2_build () {
    echo
}

bz2_crosscompile () {
    unset CFLAGS

    if [ -f ${APKUSR}/lib/libbz2.so ]
    then
        echo "    -> libbz2 already built for $ABI_NAME"
    else
        PrepareBuild ${unit}
        cp -vf bzlib.h ${APKUSR}/include/                
        if make ${JFLAGS} CC=$CC AR=$AR RANLIB=$RANLIB PREFIX=${APKUSR}  install
        then
            echo "   -> great bzip2 can finally build"
            make -f Makefile-libbz2_so CC=$CC                 
            patchelf --set-soname libbz2.so libbz2.so.1.0.8
            cp -vf libbz2.so.1.0.8 ${APKUSR}/lib/libbz2.so                    
        else
            echo "   -> bzip2 build failed, trying to link objects into a shared lib anyway"
            pwd
            read
            # armv7a-linux-androideabi19-clang
            ${CC} -shared -Wl,-soname -Wl,libbz2.so -o ${APKUSR}/lib/libbz2.so blocksort.o \
  huffman.o    \
  crctable.o   \
  randtable.o  \
  compress.o   \
  decompress.o \
  bzlib.o
        fi
    fi
}






#BAD https://github.com/tamaskenez/harfbuzz-cmake.git

export URL_HARFBUZZ=${URL_HARFBUZZ:-"GIT_REPOSITORY https://github.com/harfbuzz/harfbuzz.git"}
export HASH_HARFBUZZ=${HASH_HARFBUZZ:-}


harfbuzz_host_cmake () {
    cat >> CMakeLists.txt <<END
if(1)
    message("")
    message(" processing unit : ${unit}")
ExternalProject_Add(
    harfbuzz
    GIT_TAG main
    ${URL_HARFBUZZ}
    ${HASH_HARFBUZZ}

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

harfbuzz_patch () {
    echo
}

harfbuzz_build () {
    echo
}

harfbuzz_crosscompile () {
    if [ -f  ${APKUSR}/lib/libharfbuzz.so ]
    then
        echo "    -> harfbuzz already built for $ABI_NAME"
    else

        PrepareBuild ${unit}

        cat ${BUILD_PREFIX}-${ABI_NAME}/toolchain.cmake > ${BUILD_PREFIX}-${ABI_NAME}/${unit}.toolchain.cmake
        cat >> ${BUILD_PREFIX}-${ABI_NAME}/${unit}.toolchain.cmake <<END

list(APPEND CMAKE_PREFIX_PATH "${APKUSR}")
list(APPEND CMAKE_PREFIX_PATH "${APKUSR}/lib")
list(APPEND CMAKE_PREFIX_PATH "${APKUSR}/lib/cmake")
list(APPEND CMAKE_PREFIX_PATH "${APKUSR}/lib/cmake/freetype")

set(THREADS_PREFER_PTHREAD_FLAG OFF)

#FIXME: that block seems useless
set(FREETYPE_DIR ${APKUSR})
set(FREETYPE_INCLUDE_DIRS "${APKUSR}/include/freetype2")
set(FREETYPE_LIBRARY "${APKUSR}/lib/libfreetype.a")
set(FREETYPE_LIBRARIES "${APKUSR}/lib/libfreetype.a" "${APKUSR}/lib/libbz2.a" "z")
set(FREETYPE_FOUND YES)
include_directories("${APKUSR}/include/freetype2")


add_library(bz2 STATIC IMPORTED)
set_target_properties(bz2 PROPERTIES IMPORTED_LOCATION ${APKUSR}/lib/libbz2.a)
set_target_properties(bz2 PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${APKUSR}/include)

#target_link_libraries(harfbuzz bz2)

END

        cat > ${BUILD_PREFIX}-${ABI_NAME}/${unit}.sh <<END
#!/bin/bash
$CMAKE -DANDROID_ABI=${ABI_NAME}\\
 -DBUILD_SHARED_LIBS=YES \\
 -DHB_HAVE_FREETYPE=ON \\
 -DHB_BUILD_TESTS=NO \\
 -DCMAKE_TOOLCHAIN_FILE=${BUILD_PREFIX}-${ABI_NAME}/${unit}.toolchain.cmake \\
 -DCMAKE_INSTALL_PREFIX=${APKUSR} \\
 -DFREETYPE_LIBRARY=${APKUSR}/lib/libfreetype.a \\
 -DTHIRD_PARTY_LIBS='bz2 -L${APKUSR}/lib -lz' \\
 -DFREETYPE_INCLUDE_DIRS=${APKUSR}/include/freetype2 \\
 ${BUILD_SRC}/${unit}-prefix/src/${unit}
END
        chmod gou+x ${BUILD_PREFIX}-${ABI_NAME}/${unit}.sh
        if ${BUILD_PREFIX}-${ABI_NAME}/${unit}.sh >/dev/null
        then
            std_make ${unit}
        else
            echo "ERROR $unit"
            exit 1
        fi
    fi
}




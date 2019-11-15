
#BAD https://github.com/tamaskenez/harfbuzz-cmake.git

export HARFBUZZ_URL=${HARFBUZZ_URL:-"GIT_REPOSITORY https://github.com/harfbuzz/harfbuzz.git"}
export HARFBUZZ_HASH=${HARFBUZZ_HASH:-}


harfbuzz_host_cmake () {
    cat >> CMakeLists.txt <<END
#${unit}

ExternalProject_Add(
    harfbuzz
    ${HARFBUZZ_URL}
    ${HARFBUZZ_HASH}

    DOWNLOAD_NO_PROGRESS ${CI}

    #PATCH_COMMAND patch -p1 < ${SUPPORT}/harfbuzz_freetype_fix.patch

    CONFIGURE_COMMAND sh -c "echo 1>&1;echo external.configure ${unit} 1>&2"
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)

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
        echo "    -> harfbuzz already built for $ANDROID_NDK_ABI_NAME"
    else

        PrepareBuild ${unit}

        cat ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/toolchain.cmake > ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/${unit}.toolchain.cmake
        cat >> ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/${unit}.toolchain.cmake <<END

set(FREETYPE_DIR ${APKUSR})
set(FREETYPE_INCLUDE_DIRS "${APKUSR}/include")
set(FREETYPE_LIBRARY "${APKUSR}/lib/libfreetype.a" "${APKUSR}/lib/libbz2.a" "z")
set(FREETYPE_LIBRARIES "${APKUSR}/lib/libfreetype.a" "${APKUSR}/lib/libbz2.a" "z")
set(FREETYPE_FOUND YES)
include_directories("${APKUSR}/include/freetype2")

END


        HARFBUZZ_CMAKE_ARGS="-DBUILD_SHARED_LIBS=YES -DHB_HAVE_FREETYPE=ON -DHB_BUILD_TESTS=NO"

        HARFBUZZ_ACMAKE="$CMAKE -DANDROID_ABI=${ANDROID_NDK_ABI_NAME}\
 -DCMAKE_TOOLCHAIN_FILE=${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/${unit}.toolchain.cmake\
 -DCMAKE_INSTALL_PREFIX=${APKUSR}"

        if $HARFBUZZ_ACMAKE $HARFBUZZ_CMAKE_ARGS ${BUILD_SRC}/${unit}-prefix/src/${unit} >/dev/null
        then
            std_make ${unit}
        else
            echo "ERROR $unit"
            exit 1
        fi
    fi
}




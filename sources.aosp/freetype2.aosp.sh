
# https://github.com/roxlu
# https://gist.github.com/roxlu/0108d45308a0434e27d4320396399153

export FREETYPE2_URL=${FREETYPE2_URL:-"URL https://download.savannah.gnu.org/releases/freetype/freetype-2.10.0.tar.bz2"}
export FREETYPE2_HASH=${FREETYPE2_HASH:-"URL_HASH SHA256=fccc62928c65192fff6c98847233b28eb7ce05f12d2fea3f6cc90e8b4e5fbe06"}



freetype2_host_cmake () {
    cat >> CMakeLists.txt <<END

if(1)
    message("")
    message(" processing unit : ${unit}")
ExternalProject_Add(
    freetype2
    ${FREETYPE2_URL}
    ${FREETYPE2_HASH}

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

freetype2_patch () {
    echo
}

freetype2_build () {
    echo
}

freetype2_crosscompile () {
    # force rebuild for removing circular deps with harfbuzz build as a static lib for hb
    PrepareBuild ${unit}
    if [ -f ${APKUSR}/lib/libfreetype.a ]
    then
        echo "    -> freetype2-static already built for $ANDROID_NDK_ABI_NAME"
    else
        FRETYPE2_CMAKE_ARGS="-DBUILD_SHARED_LIBS=NO \
 -DFT_WITH_BZIP2=ON -DFT_WITH_ZLIB=ON -DFT_WITH_PNG=NO\
 -DCMAKE_DISABLE_FIND_PACKAGE_HarfBuzz=Yes"
        if $ACMAKE $FRETYPE2_CMAKE_ARGS ${BUILD_SRC}/${unit}-prefix/src/${unit} >/dev/null
        then
            std_make $unit
        else
            echo "ERROR: cmake $unit"
            exit 1
        fi
    fi
}




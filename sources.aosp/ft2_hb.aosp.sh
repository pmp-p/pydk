
# https://github.com/roxlu
# https://gist.github.com/roxlu/0108d45308a0434e27d4320396399153

#export FREETYPE2_URL=${FREETYPE2_URL:-"URL https://download.savannah.gnu.org/releases/freetype/freetype-2.10.0.tar.bz2"}
#export FREETYPE2_HASH=${FREETYPE2_HASH:-"URL_HASH SHA256=fccc62928c65192fff6c98847233b28eb7ce05f12d2fea3f6cc90e8b4e5fbe06"}



ft2_hb_host_cmake () {
    cat >> CMakeLists.txt <<END
#${unit} : this unit is virtual to fix circular deps beetween harfbuzz and freetype2
END
}

ft2_hb_patch () {
    echo
}

ft2_hb_build () {
    echo
}

ft2_hb_crosscompile () {

    if [ -f ${APKUSR}/lib/libfreetype.so ]
    then
        echo "    -> freetype2-harfbuzz already built for $ANDROID_NDK_ABI_NAME"
    else
        PrepareBuild ${unit}

        echo " * building freetype2+harfbuzz for target ${ANDROID_ABI}"

        FRETYPE2_CMAKE_ARGS="-DBUILD_SHARED_LIBS=YES\
     -DFT_WITH_BZIP2=ON -DFT_WITH_ZLIB=ON -DFT_WITH_PNG=NO"
        if $ACMAKE $FRETYPE2_CMAKE_ARGS ${BUILD_SRC}/freetype2-prefix/src/freetype2 >/dev/null
        then
            std_make $unit
        else
            echo "ERROR: cmake $unit"
            exit 1
        fi
    fi
}




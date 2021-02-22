export URL_VORBIS=${URL_VORBIS:-"GIT_REPOSITORY https://github.com/xiph/vorbis.git"}
export VORBIS_HASH=${VORBIS_HASH:-}

vorbis_host_cmake () {
    echo
}

vorbis_patch () {
    echo
}

vorbis_build () {
    echo
}

vorbis_crosscompile () {
    if [ -f  ${APKUSR}/lib/libvorbis.a ]
    then
        echo "    -> vorbis already built for $ABI_NAME"
    else
        PrepareBuild ${unit}
        #-DBUILD_SHARED_LIBS=No  -DOGG_INCLUDE_DIR=${EM_CACHE}/wasm/include -DOGG_LIBRARY=${EM_CACHE}/wasm

        if $WCMAKE \
 -DCMAKE_CXX_FLAGS="-fPIC" -DCMAKE_C_FLAGS="-fPIC" \
 -DOGG_LIBRARY=${EM_CACHE}/sysroot/lib/wasm32-emscripten/pic/libogg.a \
 -DOGG_INCLUDE_DIR=${EM_CACHE}/sysroot/include \
 ${BUILD_SRC}/${unit}-prefix/src/${unit} >/dev/null
        then
            em_make ${unit}
        else
            echo "ERROR $unit"
            exit 1
        fi
    fi
}




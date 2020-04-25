export VORBIS_URL=${VORBIS_URL:-"GIT_REPOSITORY https://github.com/xiph/vorbis.git"}
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
        #-DBUILD_SHARED_LIBS=No
        if $WCMAKE -DOGG_LIBRARY=${EM_CACHE}/wasm -DOGG_INCLUDE_DIR=${EM_CACHE}/wasm/include ${BUILD_SRC}/${unit}-prefix/src/${unit} >/dev/null
        then
            em_make ${unit}
        else
            echo "ERROR $unit"
            exit 1
        fi
    fi
}




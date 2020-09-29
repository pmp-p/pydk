
#30c490373b740f357d219c9e9672698d739f11f3
# broken at https://github.com/xiph/vorbis/commit/ffcd784bca8b02606014f2bb43d43a6d5dcfc8ae

export VORBIS_URL=${VORBIS_URL:-"GIT_REPOSITORY https://github.com/xiph/vorbis.git"}
export VORBIS_HASH=${VORBIS_HASH:-}



#export VORBIS_URL=${VORBIS_URL:-"URL https://github.com/xiph/vorbis/archive/30c490373b740f357d219c9e9672698d739f11f3.zip"}
#export VORBIS_HAS=${VORBIS_HASH:-"URL_HASH SHA256=17f034a73d208bd230dd70f13ba3c600a9eed169aac38e3d38cd0e42dd759d7c"}


vorbis_host_cmake () {
    cat >> CMakeLists.txt <<END

if(1)
    message("")
    message(" processing unit : ${unit}")
ExternalProject_Add(
    ${unit}
    ${VORBIS_URL}
    ${VORBIS_HASH}

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

vorbis_patch () {
    echo
}

vorbis_build () {
    echo
}

vorbis_crosscompile () {
    if [ -f  ${APKUSR}/lib/libvorbis.so ]
    then
        echo "    -> vorbis already built for $ANDROID_NDK_ABI_NAME"
    else
        PrepareBuild ${unit}
        if $ACMAKE \
 -DBUILD_SHARED_LIBS=Yes ${BUILD_SRC}/${unit}-prefix/src/${unit}\
 -DOGG_LIBRARY=${APKUSR}/lib/libogg.so\
 -DOGG_INCLUDE_DIR=${APKUSR}/include >/dev/null
        then
            std_make ${unit}
        else
            echo "ERROR $unit"
            exit 1
        fi
    fi
}




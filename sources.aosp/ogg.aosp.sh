export OGG_URL=${ogg_URL:-"URL http://downloads.xiph.org/releases/ogg/libogg-1.3.4.tar.xz"}
export OGG_HASH=${ogg_HASH:-"URL_HASH SHA256=c163bc12bc300c401b6aa35907ac682671ea376f13ae0969a220f7ddf71893fe"}


ogg_host_cmake () {
    cat >> CMakeLists.txt <<END
#${unit}

if(1)
ExternalProject_Add(
    ${unit}
    ${OGG_URL}
    ${OGG_HASH}

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

ogg_patch () {
    echo
}

ogg_build () {
    echo
}

ogg_crosscompile () {
    if [ -f  ${APKUSR}/lib/libogg.so ]
    then
        echo "    -> ogg already built for $ANDROID_NDK_ABI_NAME"
    else
        PrepareBuild ${unit}
        if $ACMAKE -DBUILD_SHARED_LIBS=Yes ${BUILD_SRC}/${unit}-prefix/src/${unit} >/dev/null
        then
            std_make ${unit}
        else
            echo "ERROR $unit"
            exit 1
        fi
    fi
}




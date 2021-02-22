export URL_JPEGTURBO=${URL_JPEGTURBO:-"GIT_REPOSITORY https://github.com/libjpeg-turbo/libjpeg-turbo.git"}
export HASH_JPEGTURBO=${HASH_JPEGTURBO:-"GIT_TAG 3e9e7c70559d820d874fb2abea1ebcdd63c118b2"}


jpegturbo_host_cmake () {
    cat >> CMakeLists.txt <<END
#${unit}

if(1)
ExternalProject_Add(
    ${unit}
    ${URL_JPEGTURBO}
    ${HASH_JPEGTURBO}

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

jpegturbo_patch () {
    echo
}

jpegturbo_build () {
    echo
}

jpegturbo_crosscompile () {
    if [ -f  ${APKUSR}/lib/libturbojpeg.so ]
    then
        echo "    -> libjpeg-turbo already built for $ABI_NAME"
    else
        PrepareBuild ${unit}
        $ACMAKE ${BUILD_SRC}/${unit}-prefix/src/${unit} && make -s install
    fi
}

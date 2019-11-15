export OPENALDIR=${APKUSR}

openal_host_cmake () {
    cat >> CMakeLists.txt <<END
#${unit}

ExternalProject_Add(
    openal
    GIT_REPOSITORY https://github.com/pmp-p/pydk-openal-soft.git

    DOWNLOAD_NO_PROGRESS ${CI}

    CONFIGURE_COMMAND sh -c "echo 1>&1;echo external.configure ${unit} 1>&2"
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)

END
}

openal_patch () {
    echo
}

openal_build () {
    echo
}

openal_crosscompile () {

    if [ -f  ${APKUSR}/lib/libopenal.so ]
    then
        echo "    -> OpenAL already built for $ANDROID_NDK_ABI_NAME"
    else

        PrepareBuild ${unit}
        if $ACMAKE ${BUILD_SRC}/${unit}-prefix/src/${unit} >/dev/null
        then
            std_make ${unit}
        else
            echo "ERROR $unit"
            exit 1
        fi
    fi
}


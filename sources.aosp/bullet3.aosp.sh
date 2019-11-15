
# https://github.com/viromedia/ViroBullet
# https://github.com/bulletphysics/bullet3

export BULLET_URL=${BULLET_URL:-"GIT_REPOSITORY https://github.com/bulletphysics/bullet3.git"}
export BULLET_HASH=${BULLET_HASH:-}



bullet3_host_cmake () {
    cat >> CMakeLists.txt <<END
#${unit}

ExternalProject_Add(
    bullet3

    ${BULLET_URL}
    ${BULLET_HASH}

    DOWNLOAD_NO_PROGRESS ${CI}

    CONFIGURE_COMMAND sh -c "echo 1>&1;echo external.configure ${unit} 1>&2"
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)


END
}

bullet3_patch () {
    echo
}

bullet3_build () {
    echo
}

bullet3_crosscompile () {

        PrepareBuild ${unit}

    BULLET3_CMAKE_ARGS="-DBUILD_SHARED_LIBS=YES -DUSE_DOUBLE_PRECISION=NO\
 -DBUILD_UNIT_TESTS=NO -DBUILD_EXTRAS=NO -DBUILD_CPU_DEMOS=NO\
 -DUSE_GRAPHICAL_BENCHMARK=NO -DBUILD_OPENGL3_DEMOS=NO -DBUILD_BULLET2_DEMOS=NO\
 -DBUILD_PYBULLET=NO -DBUILD_ENET=NO -DBUILD_CLSOCKET=NO"
    if $ACMAKE $BULLET3_CMAKE_ARGS ${BUILD_SRC}/${unit}-prefix/src/${unit} >/dev/null
    then
        std_make ${unit}
    else
        echo "ERROR $unit"
        exit 1
    fi
}




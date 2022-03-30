
# https://github.com/viromedia/ViroBullet
# https://github.com/bulletphysics/bullet3

# valid
#export URL_BULLET=${URL_BULLET:-"URL https://github.com/bulletphysics/bullet3/archive/2.89.tar.gz"}
#export HASH_BULLET=${HASH_BULLET:-"URL_HASH MD5=d239b4800ec30513879834be6fcdc376"}

# mars 2022 , broken
# export URL_BULLET=${URL_BULLET:-"GIT_REPOSITORY https://github.com/bulletphysics/bullet3.git"}

export URL_BULLET=${URL_BULLET:-"GIT_REPOSITORY https://github.com/pmp-p/bullet3"}
export TAG_BULLET="GIT_TAG patch-1"


bullet3_host_cmake () {
    cat >> CMakeLists.txt <<END
if(1)
    message("")
    message(" processing unit : ${unit}")

ExternalProject_Add(
    bullet3

    ${URL_BULLET}
    ${HASH_BULLET}
    ${TAG_BULLET}

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

bullet3_patch () {
    echo
}

bullet3_build () {
    echo
}

bullet3_crosscompile () {

        PrepareBuild ${unit}
    if [ -f ${APKUSR}/lib/libLinearMath.so ]
    then
        echo "    -> bullet3 already built for $ABI_NAME"
    else
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
    fi
}




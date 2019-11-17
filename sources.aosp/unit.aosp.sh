export UNIT_URL=${UNIT_URL:-"GIT_REPOSITORY https://github.com/pmp-p/pydk.git"}
export UNIT_HASH=${UNIT_HASH:-}


unit_host_cmake () {
    cat >> CMakeLists.txt <<END
#${unit}

if(0)
ExternalProject_Add(
    ${unit}
    ${UNIT_URL}
    ${UNIT_HASH}

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

unit_patch () {
    echo
}

unit_build () {
    echo
}

unit_crosscompile () {
    echo
}




#export URL_PCRE2=${URL_PCRE2:-"URL https://ftp.pcre.org/pub/pcre/pcre2-10.36.tar.gz"}
#export HASH_PCRE2=${HASH_PCRE2:-"URL_HASH MD5=a5d9aa7d18b61b0226696510e60c9582"}

export URL_PCRE2=${URL_PCRE2:-"URL https://ftp.exim.org/pub/pcre/pcre2-10.37.tar.gz"}
export HASH_PCRE2=${HASH_PCRE2:-"URL_HASH MD5=a0b59d89828f62d2e1caac04f7c51e0b"}

# https://github.com/PCRE2Project/pcre2

pcre2_host_cmake () {
    cat >> CMakeLists.txt <<END

if(1)
    message("")
    message(" processing unit : ${unit}")
ExternalProject_Add(
    pcre2
    ${URL_PCRE2}
    ${HASH_PCRE2}

    DOWNLOAD_NO_PROGRESS ${CI}

    CONFIGURE_COMMAND ""
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

pcre2_patch () {
    echo
}

pcre2_build () {
    echo
}

pcre2_crosscompile () {
    echo
}


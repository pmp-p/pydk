#  PARALLEL BUILD WILL BREAK : always use -j1 !

export OPENSSL_URL=${OPENSSL_URL:-"URL https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"}

case "$OPENSSL_VERSION" in
    "1.0.2t" ) OPENSSL_HASH="URL_HASH SHA256=14cb464efe7ac6b54799b34456bd69558a749a4931ecfd9cf9f71d7881cac7bc";;
    "1.1.1d" ) OPENSSL_HASH="URL_HASH SHA256=1e3a91bc1f9dfce01af26026f856e064eab4c8ee0a8f457b5ae30b40b8b711f2";;
esac



openssl_host_cmake () {
    cat >> CMakeLists.txt <<END

if(1)
    message("")
    message(" processing unit : ${unit}")
ExternalProject_Add(
    openssl
    DEPENDS patchelf
    ${OPENSSL_URL}
    ${OPENSSL_HASH}

    DOWNLOAD_NO_PROGRESS ${CI}

    PATCH_COMMAND patch -p1 < ${SUPPORT}/openssl-${OPENSSL_VERSION}/Configure.diff
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

openssl_patch () {
    echo " -> was done in cmake_host step"
}

openssl_build () {
    echo
}

openssl_crosscompile () {


    # poc https://github.com/ph4r05/android-openssl

    if [ -f  ${APKUSR}/lib/libsslpython.so ]
    then
        echo "    -> openssl-${OPENSSL_VERSION} already built for $ANDROID_NDK_ABI_NAME"
    else
        Building openssl
        unset CFLAGS
        # no-ssl2 no-ssl3 no-comp
        CROSS_COMPILE="" ./Configure android shared no-hw --prefix=${APKUSR} >/dev/null && CROSS_COMPILE="" make -s -j1 depend >/dev/null && CROSS_COMPILE="" make -s -j1 install >/dev/null

        ln -sf . lib

        # == fix android libraries are not version numbered

        chmod u+w ${APKUSR}/lib/lib*.so

        if [ -L ${APKUSR}/lib/libssl.so ]
        then
            rm ${APKUSR}/lib/libssl.so
            mv ${APKUSR}/lib/libssl.so.1.0.0 ${APKUSR}/lib/libsslpython.so
            ${HOST}/bin/patchelf --set-soname libsslpython.so ${APKUSR}/lib/libsslpython.so
            ${HOST}/bin/patchelf --replace-needed libcrypto.so.1.0.0 libcryptopython.so ${APKUSR}/lib/libsslpython.so
        fi

        if [ -L ${APKUSR}/lib/libcrypto.so ]
        then
            rm ${APKUSR}/lib/libcrypto.so
            mv ${APKUSR}/lib/libcrypto.so.1.0.0 ${APKUSR}/lib/libcryptopython.so
            ${HOST}/bin/patchelf --set-soname libcryptopython.so ${APKUSR}/lib/libcryptopython.so
        fi

        if [ -f  ${APKUSR}/lib/libsslpython.so ]
        then
            echo "    -> openssl-${OPENSSL_VERSION}  built for $ANDROID_NDK_ABI_NAME"
        else
            echo "ERROR: openssl-${OPENSSL_VERSION}  $ANDROID_NDK_ABI_NAME"
            exit 1
        fi

    fi


}




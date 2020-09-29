#  PARALLEL BUILD WILL BREAK : always use -j1 !

export OPENSSL_URL=${OPENSSL_URL:-"URL https://ftp.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz"}

case "$OPENSSL_VERSION" in
    "1.0.2t" ) OPENSSL_HASH="URL_HASH SHA256=14cb464efe7ac6b54799b34456bd69558a749a4931ecfd9cf9f71d7881cac7bc";;
    "1.1.1f" ) OPENSSL_HASH="URL_HASH SHA256=186c6bfe6ecfba7a5b48c47f8a1673d0f3b0e5ba2e25602dd23b629975da3f35";;
    "1.1.1h" ) OPENSSL_HASH="URL_HASH SHA256=5c9ca8774bd7b03e5784f26ae9e9e6d749c9da2438545077e6b3d755a06595d9";;
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

    PATCH_COMMAND patch -p1 < ${SUPPORT}/openssl-${OPENSSL_VERSION}/all
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
    echo " -> openssl patch is made in cmake_host step"
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

        case "$OPENSSL_VERSION" in
            "1.0.2t" ) V11=false;;
            "1.1.1d" ) V11=true;;
            "1.1.1f" ) V11=true;;
            "1.1.1h" ) V11=true;;
        esac

        # no-ssl2 no-ssl3 no-comp

        if $V11
        then
            CROSS_COMPILE="" ARCH=${ARCH} API=${API} ./Configure -D__ANDROID_API__=${API} shared no-hw --prefix=${APKUSR} android-${ARCH}\
 >/dev/null && CROSS_COMPILE="" make -s -j1 depend >/dev/null && CROSS_COMPILE="" make -s -j1 install >/dev/null
            SOVER="1.1"
        else
            CROSS_COMPILE="" ./Configure android shared no-hw --prefix=${APKUSR} >/dev/null && CROSS_COMPILE="" make -s -j1 depend >/dev/null && CROSS_COMPILE="" make -s -j1 install >/dev/null
            SOVER="1.0.0"
        fi

        ln -sf . lib

        # == fix android libraries are not version numbered

        chmod u+w ${APKUSR}/lib/lib*.so

        if [ -L ${APKUSR}/lib/libssl.so ]
        then
            rm ${APKUSR}/lib/libssl.so
            mv ${APKUSR}/lib/libssl.so.${SOVER} ${APKUSR}/lib/libsslpython.so
            ${HOST}/bin/patchelf --set-soname libsslpython.so ${APKUSR}/lib/libsslpython.so
            ${HOST}/bin/patchelf --replace-needed libcrypto.so.${SOVER} libcryptopython.so ${APKUSR}/lib/libsslpython.so
        fi

        if [ -L ${APKUSR}/lib/libcrypto.so ]
        then
            rm ${APKUSR}/lib/libcrypto.so
            mv ${APKUSR}/lib/libcrypto.so.${SOVER} ${APKUSR}/lib/libcryptopython.so
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




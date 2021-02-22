
pcre2_host_cmake () {
    echo
}

pcre2_patch () {
    echo
}

pcre2_build () {
    echo
}

pcre2_crosscompile () {
    if [ -f  ${APKUSR}/lib/libpcre2-32.a ]
    then
        echo "    -> pcre2 already built for $ABI_NAME"
    else
        Building ${unit}

        #./autogen.sh

        # Mys can use either wasi or emsdk with emsdk compiled lib
        if emconfigure ./configure --prefix=${APKUSR} \
 --enable-pcre2-32 --enable-pcre2-16 --disable-pcre2grep-jit --disable-shared
        then
            em_make ${unit}
        else
            echo "ERROR $unit"
            exit 1
        fi
    fi
}


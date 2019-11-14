export OPENALDIR=${APKUSR}


openal_host_cmake () {
    cat >> CMakeLists.txt <<END
#${unit}
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
        #STEP=True
        PrepareBuild ${unit}
        echo " * building OpenAL for target ${ANDROID_ABI}"
        $CMAKE ${SUPPORT}/openal-soft-aosp\
 -DANDROID_ABI=${ANDROID_NDK_ABI_NAME}\
 -DCMAKE_TOOLCHAIN_FILE=${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/toolchain.cmake\
 -DCMAKE_INSTALL_PREFIX=${APKUSR} && make install
    fi
}


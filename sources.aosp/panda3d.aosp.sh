
PANDA3D_URL=${PANDA3D_URL:-https://github.com/panda3d/panda3d/archive/cmake.zip}
#PANDA3D_HASH=07f537fd2125aaaa871bbf0686f78a2c8fb1ab7e8f04cd5d72badcd91822240a


function panda3d_host_cmake () {
    cat >> CMakeLists.txt <<END

ExternalProject_Add(
    panda3d
    DEPENDS python3

    URL ${PANDA3D_URL}

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${HOST} -DPYTHON_EXECUTABLE=${HOST}/bin/python${PYMAJOR}.${PYMINOR}

)

END

}


function panda3d_patch () {
    echo
}

function panda3d_build () {
    echo
}


function panda3d_crosscompile () {
    export STEP=True
#set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} "${ORIGIN}/thirdparty.aosp/modules/")
#set(OPENALDIR ${OPENALDIR})

    PrepareBuild ${unit}

     echo " * building Panda3D for target ${ANDROID_ABI}"

    cat ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/toolchain.cmake > ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/panda3d.toolchain.cmake



    cat >> ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/panda3d.toolchain.cmake <<END
set(ASSETS ${ORIGIN}/assets)
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG YES)

set(PYMAJOR ${PYMAJOR})
set(PYMINOR ${PYMINOR})
set(PYTHON_EXECUTABLE ${HOST}/bin/python${PYMAJOR}.${PYMINOR})

set(Python_DIR "${SUPPORT}/config")


set(host_pzip ${HOST}/bin/pzip)
#set(host_interrogate ${HOST}/bin/interrogate)
set(host_interrogate_module ${HOST}/bin/interrogate_module)

#set(OPENSSL_DIR "\${CMAKE_INSTALL_PREFIX}")
set(OPENSSL_ROOT_DIR "\${CMAKE_INSTALL_PREFIX}")
set(OPENSSL_INCLUDE_DIR "\${CMAKE_INSTALL_PREFIX}/include")
set(OPENSSL_SSL_LIBRARY "\${CMAKE_INSTALL_PREFIX}/lib/libsslpython.so")
set(OPENSSL_CRYPTO_LIBRARY "\${CMAKE_INSTALL_PREFIX}/lib/libcryptopython.so")
set(OPENSSL_DIR "${SUPPORT}/config")

set(ZLIB_DIR \${CMAKE_SYSROOT})

set(OPENAL_INCLUDE_DIR ${APKUSR}/include)
set(OPENAL_LIBRARY openal)

#set(HAVE_OPENAL YES)

#set(BUILD_MODELS OFF)

add_definitions(-DOPENGLES_2=1)

#set(HAVE_EGL_AVAILABLE YES)
#set(HAVE_EGL YES)

#string(APPEND CMAKE_MODULE_LINKER_FLAGS " -L${APKUSR}/lib")

END

 PATH=${ENV}/bin:${HOST}/bin:$PATH $CMAKE ${BUILD_SRC}/panda3d-prefix/src/panda3d \
 -DANDROID_ABI=${ANDROID_NDK_ABI_NAME}\
 -DHAVE_PYTHON=YES -DHAVE_OPENAL=YES\
 -DHAVE_GL=NO -DHAVE_GLX=NO -DHAVE_X11=NO \
 -DHAVE_GLES1=NO  -DHAVE_GLES2=NO -DHAVE_EGL=NO \
 -DHAVE_EGG=NO -DHAVE_SSE2=NO \
 -DCMAKE_TOOLCHAIN_FILE=${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/panda3d.toolchain.cmake\
 -DCMAKE_INSTALL_PREFIX=${APKUSR} && make -j 4

}




export PANDA3D_URL=${PANDA3D_URL:-"URL https://github.com/panda3d/panda3d/archive/cmake.zip"}
export PANDA3D_HASH=${PANDA3D_HASH:-}

export PANDA3D_CMAKE_ARGS="-DHAVE_PYTHON=YES\
 -DHAVE_GL=NO -DHAVE_GLX=NO -DHAVE_X11=NO\
 -DHAVE_GLES1=NO  -DHAVE_GLES2=NO -DHAVE_EGL=NO\
 -DHAVE_EGG=NO -DHAVE_SSE2=NO"

panda3d_host_cmake () {
    cat >> CMakeLists.txt <<END

ExternalProject_Add(
    panda3d
    DEPENDS python3
    ${PANDA3D_URL}
    ${PANDA3D_HASH}

    DOWNLOAD_NO_PROGRESS ${CI}

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${HOST} -DPYTHON_EXECUTABLE=${HOST}/bin/python${PYMAJOR}.${PYMINOR} ${PANDA3D_CMAKE_ARGS}

)

END

}


panda3d_patch () {
    echo
}

panda3d_build () {
    echo
}


panda3d_crosscompile () {
    #export STEP=True
#set(CMAKE_MODULE_PATH \${CMAKE_MODULE_PATH} "${ORIGIN}/thirdparty.aosp/modules/")
#set(OPENALDIR ${OPENALDIR})

    PrepareBuild ${unit}

     echo " * building Panda3D for target ${ANDROID_ABI}"

    cat ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/toolchain.cmake > ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/${unit}.toolchain.cmake

    cat >> ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/${unit}.toolchain.cmake <<END

set(ASSETS ${ORIGIN}/assets)
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG YES)

set(PYMAJOR ${PYMAJOR})
set(PYMINOR ${PYMINOR})
set(PYTHON_EXECUTABLE ${HOST}/bin/python${PYMAJOR}.${PYMINOR})

set(Python_DIR "${SUPPORT}/config")

add_definitions(-DOPENGLES_2=1)
include_directories("${APKUSR}/include" "${APKUSR}/include/python${PYMAJOR}.${PYMINOR}")

set(OPENSSL_ROOT_DIR "\${CMAKE_INSTALL_PREFIX}")
set(OPENSSL_INCLUDE_DIR "\${CMAKE_INSTALL_PREFIX}/include")
set(OPENSSL_SSL_LIBRARY "\${CMAKE_INSTALL_PREFIX}/lib/libsslpython.so")
set(OPENSSL_CRYPTO_LIBRARY "\${CMAKE_INSTALL_PREFIX}/lib/libcryptopython.so")
set(OPENSSL_DIR ${APKUSR})

set(ZLIB_DIR \${CMAKE_SYSROOT})

set(OPENAL_INCLUDE_DIR ${APKUSR}/include)
set(OPENAL_LIBRARY openal)

set(FREETYPE_DIR ${APKUSR})
set(FREETYPE_INCLUDE_DIRS "${APKUSR}/include")
set(FREETYPE_LIBRARY "${APKUSR}/lib/libfreetype.so" "${APKUSR}/lib/libbz2.a" "z")
set(FREETYPE_LIBRARIES "${APKUSR}/lib/libfreetype.so" "${APKUSR}/lib/libbz2.a" "z")
set(FREETYPE_FOUND YES)
include_directories("${APKUSR}/include/freetype2")

set(HARFBUZZ_INCLUDE_DIRS "${APKUSR}/include/harfbuzz")
set(HARFBUZZ_LIBRARIES "${APKUSR}/lib/libharfbuzz.so")

set(HARFBUZZ_INCLUDE_DIR "${APKUSR}/include/harfbuzz")
set(HARFBUZZ_LIBRARY "${APKUSR}/lib/libharfbuzz.so")

set(HARFBUZZ_FOUND YES)

set(BULLET_ROOT ${APKUSR})

set(BULLET_DYNAMICS_LIBRARY BulletDynamics)
#set(BULLET_DYNAMICS_LIBRARY ${APKUSR}/lib/libBulletDynamics.so)

#set(BULLET_COLLISION_LIBRARY ${APKUSR}/lib/libBulletCollision.so)
set(BULLET_COLLISION_LIBRARY BulletCollision)

#set(BULLET_MATH_LIBRARY ${APKUSR}/lib/libLinearMath.so)
set(BULLET_MATH_LIBRARY LinearMath)

#set(BULLET_SOFTBODY_LIBRARY ${APKUSR}/lib/libBulletSoftBody.so)
set(BULLET_SOFTBODY_LIBRARY BulletSoftBody)

set(BULLET_INCLUDE_DIR ${APKUSR}/include/bullet)

set(BULLET_LIBRARIES -L${APKUSR}/lib BulletDynamics BulletCollision LinearMath BulletSoftBody)
set(BULLET_FOUND Yes)

string(APPEND CMAKE_MODULE_LINKER_FLAGS " -L${APKUSR}/lib -lpython${PYMAJOR}.${PYMINOR}")

END

    # for pandatools
    export LD_LIBRARY_PATH
    export PATH

    #set(BUILD_MODELS OFF)

    PANDA3D_ACMAKE="$CMAKE ${BUILD_SRC}/${unit}-prefix/src/${unit} \
 -DANDROID_ABI=${ANDROID_NDK_ABI_NAME}\
 -DHAVE_OPENAL=Yes -DHAVE_HARFBUZZ=Yes\
 -DCMAKE_TOOLCHAIN_FILE=${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/${unit}.toolchain.cmake\
 -DCMAKE_INSTALL_PREFIX=${APKUSR} ${PANDA3D_CMAKE_ARGS}"

    echo "$PANDA3D_ACMAKE \"\$@\""> ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/${unit}.rebuild

    # could fail once on Python export
    if $PANDA3D_ACMAKE
    then
        if $CI
        then
            make ${JFLAGS} install >/dev/null
        else
            make ${JFLAGS} install
        fi
    else
        if $CI
        then
            $PANDA3D_ACMAKE >/dev/null && make ${JFLAGS} install
        else
            $PANDA3D_ACMAKE >/dev/null && make ${JFLAGS} install >/dev/null
        fi
    fi

}



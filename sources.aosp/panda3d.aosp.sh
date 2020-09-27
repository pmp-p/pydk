
# Thanks CFSworks for cmake !
#export PANDA3D_URL=${PANDA3D_URL:-"URL https://github.com/panda3d/panda3d/archive/cmake.zip"}

# last build ok most recent first
# e787929c851c09974bfeaa376fe0ee5eb3f54b79 e85815a80ff74499df92b752f5235c18c6d046f429178ed12367c74e76d0e09d
# 00305bccae3643dda6f469f9cfe0cc46b7e5d74b 6f0cb8134b19c90ba7fd7c3069e69790852237b45093da630bd129268ac63b01
# 980c6bb38961c13e0890990651d05df3550cf30a 6745d430f34b6d6f84f88a36f51fe9d4291a02c0bbf7a1e14ecfb2de2ee7e214

# webglport
# https://github.com/panda3d/panda3d/archive/e72bd7f5c62919d76cfa3d5f4b05712f5dfaac48.zip 86e7569dd02b350826f74c0d69bf958dc4474b53deffc7f8bb48d667e2fe6fd5

#https://github.com/panda3d/panda3d/archive/v1.10.7.tar.gz"}
#b189313c4e9548e20b0facb0c078636e39467b149000919b80a7dd90b35a1939"}

export PANDA3D_URL=${PANDA3D_URL:-"URL https://github.com/panda3d/panda3d/archive/54b93116e8910dc19a68780d6325ea5e8f8636f9.zip"}
export PANDA3D_HASH=${PANDA3D_HASH:-"URL_HASH SHA256=318638ff1a39ea7aab75fea34f4dc5bea464fb47706582bd45b04f1249752ed9"}


export PANDA3D_CMAKE_ARGS_COMMON="-DHAVE_PYTHON=YES\
-DHAVE_EGG=YES -DHAVE_THREADS=NO -DHAVE_SSE2=NO -DHAVE_GTK2=No"

#  -DSTDFLOAT_DOUBLE=NO

export PANDA3D_CMAKE_ARGS="${PANDA3D_CMAKE_ARGS_COMMON}\
 -DHAVE_EGL=NO -DHAVE_GL=YES -DHAVE_GLX=YES -DHAVE_X11=YES -DHAVE_GLES1=NO -DHAVE_GLES2=YES"

panda3d_host_cmake () {
    cat ${SUPPORT}/panda3d/*.diff > ${SUPPORT}/panda3d/all
    cat >> CMakeLists.txt <<END

if(1)
    message("")
    message(" processing unit : ${unit}")
ExternalProject_Add(
    panda3d
    DEPENDS python3
    DEPENDS openal
    DEPENDS harfbuzz
    DEPENDS freetype2
    DEPENDS vorbis
    DEPENDS openssl

    ${PANDA3D_URL}
    ${PANDA3D_HASH}

    PATCH_COMMAND patch -p1 < ${SUPPORT}/panda3d/all

    DOWNLOAD_NO_PROGRESS ${CI}

    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${HOST} -DPYTHON_EXECUTABLE=${HOST}/bin/python${PYMAJOR}.${PYMINOR} ${PANDA3D_CMAKE_ARGS}

)
else()
    message(" ********************************************************************")
    message("  No cmake ExternalProject_Add defined for unit : ${unit}")
    message(" ********************************************************************")
endif()


END

}


panda3d_patch () {
    echo
}

panda3d_build () {
    echo
}


panda3d_crosscompile () {

    PrepareBuild ${unit}

    if [ -f  ${APKUSR}/lib/libpanda.so ]
    then
        echo "    -> ${unit} already built for $ANDROID_NDK_ABI_NAME"
    else
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


#
#set(OGG_LIBRARY "${APKUSR}/lib/libogg.so")
#set(OGG_INCLUDE_DIR "${APKUSR}/include/ogg")
#set(OGG_FOUND YES)

set(VORBISFILE_LIBRARY "${APKUSR}/lib/libvorbisfile.so")
set(VORBISFILE_LIBRARIES "${APKUSR}/lib/libvorbisfile.so")
set(VORBISFILE_INCLUDE_DIR "${APKUSR}/include")
set(VORBISFILE_FOUND YES)

set(FREETYPE_DIR ${APKUSR})
set(FREETYPE_INCLUDE_DIRS "${APKUSR}/include")
#set(FREETYPE_LIBRARY "${APKUSR}/lib/libfreetype.so" "${APKUSR}/lib/libbz2.a" "z")
#set(FREETYPE_LIBRARIES "${APKUSR}/lib/libfreetype.so" "${APKUSR}/lib/libbz2.a" "z")
set(FREETYPE_LIBRARY "${APKUSR}/lib/libfreetype.so" "${APKUSR}/lib/libbz2.so" "z")
set(FREETYPE_LIBRARIES "${APKUSR}/lib/libfreetype.so" "${APKUSR}/lib/libbz2.so" "z")
set(FREETYPE_FOUND YES)
include_directories("${APKUSR}/include/freetype2")

set(HARFBUZZ_INCLUDE_DIRS "${APKUSR}/include/harfbuzz")
set(HARFBUZZ_LIBRARIES "${APKUSR}/lib/libharfbuzz.so")
set(HARFBUZZ_INCLUDE_DIR "${APKUSR}/include/harfbuzz")
set(HARFBUZZ_LIBRARY "${APKUSR}/lib/libharfbuzz.so")
set(HARFBUZZ_FOUND YES)

set(BULLET_ROOT ${APKUSR})
set(BULLET_DYNAMICS_LIBRARY BulletDynamics)
set(BULLET_COLLISION_LIBRARY BulletCollision)
set(BULLET_MATH_LIBRARY LinearMath)
set(BULLET_SOFTBODY_LIBRARY BulletSoftBody)

set(BULLET_INCLUDE_DIR ${APKUSR}/include/bullet)

set(BULLET_LIBRARIES -L${APKUSR}/lib BulletDynamics BulletCollision LinearMath BulletSoftBody)
set(BULLET_FOUND Yes)

string(APPEND CMAKE_MODULE_LINKER_FLAGS " -L${APKUSR}/lib -lpython${PYMAJOR}.${PYMINOR} -lffi -lz -lbz2 -llzma -lbrokenthings")

END

        # for pandatools
        export LD_LIBRARY_PATH
        export PATH

        PANDA3D_ACMAKE="$CMAKE ${BUILD_SRC}/${unit}-prefix/src/${unit} \
     -DANDROID_ABI=${ANDROID_NDK_ABI_NAME} -DHAVE_EGL=NO -DHAVE_GL=NO -DHAVE_GLX=NO -DHAVE_X11=NO -DHAVE_GLES1=NO -DHAVE_GLES2=YES\
     -DHAVE_OPENAL=Yes -DHAVE_HARFBUZZ=Yes -DHAVE_FREETYPE=Yes -DHAVE_BULLET=Yes\
     -DHAVE_PYTHON=Yes -DHAVE_VORBIS=No\
     -DCMAKE_TOOLCHAIN_FILE=${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/${unit}.toolchain.cmake\
     -DCMAKE_INSTALL_PREFIX=${APKUSR} ${PANDA3D_CMAKE_ARGS_COMMON}"

        #HAVE_ASSIMP
        export VORBISDIR=${APKUSR}

        echo "$PANDA3D_ACMAKE \"\$@\""> ${BUILD_PREFIX}-${ANDROID_NDK_ABI_NAME}/${unit}.rebuild

        # could fail once on Python export
        if $PANDA3D_ACMAKE
        then
            if $CI
            then
                make ${JFLAGS} install >/dev/null
            else
                if make ${JFLAGS} install
                then
                    echo
                else
                    exit 1
                fi
            fi
        else
            if $CI
            then
                $PANDA3D_ACMAKE >/dev/null && make ${JFLAGS} install >/dev/null
            else
                $PANDA3D_ACMAKE >/dev/null && make ${JFLAGS} install
            fi
        fi
    fi
}



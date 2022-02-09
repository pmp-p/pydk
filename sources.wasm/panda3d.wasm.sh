#export URL_PANDA3D=${URL_PANDA3D:-"URL https://github.com/pmp-p/panda3d/archive/mobile-sandbox.zip"}
#export URL_PANDA3D=${URL_PANDA3D:-"URL https://github.com/panda3d/panda3d/archive/webgl-port.zip"}


export PANDA3D_CMAKE_ARGS_COMMON="-DHAVE_PYTHON=YES\
-DHAVE_EGG=YES -DHAVE_SSE2=NO -DHAVE_THREADS=YES"

export PANDA3D_CMAKE_ARGS="${PANDA3D_CMAKE_ARGS_COMMON}\
 -DHAVE_EGL=NO -DHAVE_GL=YES -DHAVE_GLX=YES -DHAVE_X11=YES -DHAVE_GLES1=NO -DHAVE_GLES2=YES"


panda3d_host_cmake () {
    # done in android pass
    echo
}


panda3d_patch () {
    #no need that should be webgl port by default
    echo
}

panda3d_build () {
    echo
}


panda3d_crosscompile () {

    PrepareBuild ${unit}

    BUILD_DEST=$(pwd)

    # for pandatools
    export LD_LIBRARY_PATH
    export PATH

    if [ -f  ${APKUSR}/lib/libpanda.a ]
    then
        echo "    -> ${unit} already built for $ABI_NAME"
    else
        if [ -f ${BUILD_SRC}/${unit}-prefix/src/panda3d/CMakeLists.txt ]
        then
            echo using existing archive
        else
            wget -c ${URL_PANDA3D}
            unzip -q -o *.zip && rm *.zip && mv panda3d-* ${BUILD_SRC}/${unit}-prefix/src/panda3d-webgl-port && rmdir *
        fi

if true
then
    OPT_COMMON="--optimize 3 --use-freetype --use-bullet --use-zlib --no-openssl --no-eigen --use-python --use-direct"
    OPT_COMMON="$OPT_COMMON --no-ffmpeg --no-png --no-tiff --no-jpeg --no-eigen --no-assimp --no-egg"
    OPT_COMMON="$OPT_COMMON --override HAVE_THREADS=UNDEF"

    OPT_TARGET="--nothing --target emscripten --no-pandatool --no-openssl --no-neon --no-sse2"
    OPT_TARGET="$OPT_TARGET --use-direct --no-pview --no-fftw --no-nvidiacg"
    OPT_TARGET="$OPT_TARGET --static --override HAVE_THREADS=UNDEF"

    # --override STDFLOAT_DOUBLE=1"

    GFX="--no-x11 --no-egl --no-gles --use-gles2"
    OPT_TARGET="$OPT_TARGET $GFX"

    EM_LIBS="-s USE_LIBPNG=1 -s USE_HARFBUZZ=1 -s USE_FREETYPE=1 -s USE_OGG=1 -s USE_VORBIS=1 -s USE_BULLET=1 -s USE_ZLIB=1"

    #-s OFFSCREENCANVAS_SUPPORT=1
    # -s SIDE_MODULE=1"

    # optim 4 = -O3 -fno-rtti
    # optim 3 = -O2 -frtti

    #EM_FLAGS="-O3 -fno-rtti"
    EM_FLAGS=""
    EM_FLAGS="$EM_FLAGS -s WASM=1 -s USE_WEBGL2=1 -s MIN_WEBGL_VERSION=2"
    EM_FLAGS="$EM_FLAGS -s ASSERTIONS=1 -s DEMANGLE_SUPPORT=1 -s DISABLE_EXCEPTION_CATCHING=1"
    EM_FLAGS="$EM_FLAGS -s TOTAL_MEMORY=512MB -s TOTAL_STACK=14680064"
    EM_FLAGS="$EM_FLAGS -s USE_PTHREADS=0 -s LINKABLE=1"

    # 3rd parties, in build folder not source
    export TP=${BUILD_DEST}/thirdparty/emscripten-libs
    mkdir -p ${TP}

    TP_FT2="--use-freetype"
    TP_HB="--use-harfbuzz"  # pic problem?
    TP_BUL="--use-bullet"
    TP_FT2="--use-freetype"
    TP_OA="--use-openal"


    ln -sf ${APKUSR} ${TP}/python
    TP_PY="--use-python --python-incdir=${APKUSR}/include --python-libdir=${APKUSR}/lib"

    ln -sf ${APKUSR} ${TP}/vorbis
    TP_VB="--use-vorbis --vorbis-incdir=${APKUSR}/include --vorbis-libdir=${APKUSR}/lib"
    #TP_VB="--no-vorbis"

    TP_ALL="${TP_FT2} ${TP_HB} ${TP_OA} ${TP_VB} ${TP_BUL} ${TP_PY}"

    # build it
    cd ${BUILD_SRC}/${unit}-prefix/src/panda3d

    # nope
    # -fPIC
    cat > build.sh <<END
LD_LIBRARY_PATH=$LD_LIBRARY_PATH\
 CXXFLAGS="-std=c++11 -fno-exceptions $EM_FLAGS $EM_LIBS" EMCC_FLAGS="-s USE_ZLIB=1 -s USE_BZ2=1"\
 MAKEPANDA_THIRDPARTY="$BUILD_DEST/thirdparty"\
 PATH="$HOST/bin:$EMSDK/upstream/emscripten:$BASEPATH"\
 python3 makepanda/makepanda.py $OPT_COMMON $OPT_TARGET $TP_ALL --verbose --outputdir $BUILD_DEST
END
    env -i bash build.sh

cd "$BUILD_DEST"
    echo 115-PANDA3D
    read
else
    # dreamer !
    # $WCMAKE ${BUILD_SRC}/${unit}-prefix/src/panda3d-webgl-port
    echo wcmake test
fi
    fi
}



export PANDA3D_URL=${PANDA3D_URL:-"URL https://github.com/pmp-p/panda3d/archive/mobile-sandbox.zip"}

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
        if [ -f ${BUILD_SRC}/${unit}-prefix/src/panda3d-webgl-port/CMakeLists.txt ]
        then
            echo using existing archive
        else
            wget -c ${PANDA3D_URL}
            unzip -q -o *.zip && rm *.zip && mv panda3d-* ${BUILD_SRC}/${unit}-prefix/src/panda3d-webgl-port && rmdir *
        fi

        # dreamer !
        # $WCMAKE ${BUILD_SRC}/${unit}-prefix/src/panda3d-webgl-port
if true
then
OPT_COMMON="--optimize 3 --use-freetype --use-bullet --use-zlib --no-openssl --no-eigen --use-python --use-direct"
OPT_COMMON="$OPT_COMMON --no-ffmpeg --no-png --no-tiff --no-jpeg --no-eigen --no-assimp --no-egg"
OPT_COMMON="$OPT_COMMON --override HAVE_THREADS=UNDEF"

GFX="--no-x11 --no-egl --no-gles --use-gles2"

OPT_TARGET="--nothing --target emscripten --no-pandatool --no-openssl --no-neon --no-sse2"
OPT_TARGET="$OPT_TARGET --use-direct --no-pview --no-fftw --no-nvidiacg"
OPT_TARGET="$OPT_TARGET --static --override HAVE_THREADS=UNDEF"
#--override STDFLOAT_DOUBLE=1

OPT_TARGET="$OPT_TARGET $GFX"

#-s USE_SDL=2 -s USE_SDL_IMAGE=2 -s USE_SDL_TTF=2 -s USE_SDL_NET=2
EM_LIBS="-s USE_LIBPNG=1 -s USE_HARFBUZZ=1 -s USE_FREETYPE=1 -s USE_OGG=1 -s USE_VORBIS=1 -s USE_BULLET=1 -s USE_ZLIB=1"

EM_FLAGS="-O2 -fno-rtti - -s WASM=1"
#-s OFFSCREENCANVAS_SUPPORT=1
EM_FLAGS="-s USE_WEBGL2=1 -s MIN_WEBGL_VERSION=2 -s SIDE_MODULE=1"
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

TP_ALL="${TP_FT2} ${TP_HB} ${TP_OA} ${TP_VB} ${TP_BUL} ${TP_PY}"

# build it
cd ${BUILD_SRC}/${unit}-prefix/src/panda3d-webgl-port

CXXFLAGS="-std=c++11 -fPIC -fno-exceptions $EM_FLAGS $EM_LIBS"\
 MAKEPANDA_THIRDPARTY=$BUILD_DEST/thirdparty\
 PATH=$HOST/bin:$PATH\
 python3 makepanda/makepanda.py $OPT_COMMON $OPT_TARGET $TP_ALL --verbose --outputdir $BUILD_DEST

cd "$BUILD_DEST"

else
    echo cmake test
fi
    fi
}



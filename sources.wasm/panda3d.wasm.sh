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
        # $EMCMAKE ${BUILD_SRC}/${unit}-prefix/src/panda3d-webgl-port
if true
then
OPT_COMMON="--optimize 4 --use-freetype --use-bullet --use-zlib --no-openssl --no-eigen --use-python --use-direct --use-openal"
OPT_COMMON="$OPT_COMMON --no-ffmpeg --no-png --no-tiff --no-jpeg --no-eigen --no-assimp --no-egg"
OPT_COMMON="$OPT_COMMON --override STDFLOAT_DOUBLE=1 --override HAVE_THREADS=UNDEF"

GFX="--no-x11 --no-egl --no-gles --use-gles2"

OPT_TARGET="--nothing --target emscripten --no-pandatool --no-openssl --no-neon --no-sse2"
OPT_TARGET="$OPT_TARGET --use-direct --no-pview --no-fftw --no-nvidiacg"
OPT_TARGET="$OPT_TARGET --static  --override HAVE_THREADS=UNDEF --override STDFLOAT_DOUBLE=1 "
OPT_TARGET="$OPT_TARGET $GFX"

# --outputdir ../panda3d-wasm"

EM_LIBS="-s FULL_ES2=1 -s USE_WEBGL2=1 -s OFFSCREENCANVAS_SUPPORT=1 -s USE_LIBPNG=1"
EM_LIBS="$EM_LIBS -s USE_HARFBUZZ=1 -s USE_FREETYPE=1 -s USE_OGG=1 -s USE_VORBIS=1 -s USE_BULLET=1 -s USE_ZLIB=1"

#-s USE_SDL=2 -s USE_SDL_IMAGE=2 -s USE_SDL_TTF=2 -s USE_SDL_NET=2

EM_FLAGS="-O3 -fno-rtti $EM_MODE -s EXPORT_ALL=1 -s WASM=1"
EM_FLAGS="$EM_FLAGS -s ASSERTIONS=1 -s DEMANGLE_SUPPORT=1 -s DISABLE_EXCEPTION_CATCHING=1"
EM_FLAGS="$EM_FLAGS -s TOTAL_MEMORY=512MB"

# 3rd parties

export TP=$(pwd)/thirdparty/emscripten-libs

# --python-incdir= --python-libdir=${APKUSR}/lib"
mkdir -p ${TP}/python ${TP}/python${PYVER}
ln -sf ${APKUSR}/include ${TP}/python${PYVER}/include
ln -sf ${APKUSR}/include/python${PYVER} ${TP}/python${PYVER}/include
TP_PYTHON="--use-python --python-incdir=${APKUSR}/include --python-libdir=${APKUSR}/lib"

TP_FT2="--use-freetype"
TP_VB="--use-vorbis"
TP_HB="--use-harfbuzz"
TP_BUL="--use-bullet"
TP_FT2="--use-freetype"
TP_OA="--use-openal"

TP_ALL="${TP_FT2} ${TP_HB} ${TP_OA} ${TP_VB} ${TP_BUL} ${TP_PYTHON}"

cd ${BUILD_SRC}/${unit}-prefix/src/panda3d-webgl-port

export CXXFLAGS='-std=c++11 -fno-exceptions $EM_FLAGS $EM_LIBS'
PATH=$HOST/bin:$PATH python3 makepanda/makepanda.py $OPT_COMMON $OPT_TARGET $TP_ALL --verbose --outputdir $BUILD_DEST
else
    echo cmake test
fi
    fi
}



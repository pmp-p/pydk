#!/bin/bash

mkdir -p prebuilt
if cd prebuilt
then
    echo Will build libpython.js and libpanda3d.js
else
    exit 1
fi


unset EMCC_FORCE_STDLIBS

export JAVA_HEAP_SIZE=8192m
export NODE_OPTIONS="--max_old_space_size=4096"

EM_BASE="-fno-exceptions -s TOTAL_MEMORY=512MB -s ALLOW_MEMORY_GROWTH=0 -s TOTAL_STACK=14680064" # -s TOTAL_STACK=10485760"

if false
then
    EM_FLAGS="$EM_BASE -Os -Oz -g0" #OK
    EM_FLAGS="$EM_FLAGS -s ERROR_ON_MISSING_LIBRARIES=0 -s ERROR_ON_UNDEFINED_SYMBOLS=0"
    EM_FLAGS="$EM_FLAGS -s INLINING_LIMIT=50 -s OUTLINING_LIMIT=50000"

    echo fast run, slow comp, no debug
    EM_FLAGS="$EM_FLAGS -s ASSERTIONS=1"
    EM_FLAGS="$EM_FLAGS -s DISABLE_EXCEPTION_CATCHING=1"
    EM_FLAGS="$EM_FLAGS -s DEMANGLE_SUPPORT=0"

    EM_FLAGS="$EM_FLAGS -s AGGRESSIVE_VARIABLE_ELIMINATION=1"
    EM_FLAGS="$EM_FLAGS -s ELIMINATE_DUPLICATE_FUNCTIONS=1"
#  -s FULL_ES2=1 --profiling"

else

    EM_FLAGS="$EM_BASE -O2 -g0" #OK
    EM_FLAGS="$EM_FLAGS -s ERROR_ON_MISSING_LIBRARIES=0 -s ERROR_ON_UNDEFINED_SYMBOLS=0"
    EM_FLAGS="$EM_FLAGS -s INLINING_LIMIT=50 -s OUTLINING_LIMIT=50000"

    echo avg comp, debug, slow run
    EM_FLAGS="$EM_FLAGS -s ASSERTIONS=2"
    EM_FLAGS="$EM_FLAGS -s DISABLE_EXCEPTION_CATCHING=0"
    EM_FLAGS="$EM_FLAGS -s DEMANGLE_SUPPORT=1"
    EM_FLAGS="$EM_FLAGS -s SAFE_HEAP=1 --profiling-funcs"

    #EM_FLAGS="$EM_FLAGS -s USE_PTHREADS=1 -s PTHREAD_HINT_NUM_CORES=-1"
    #EM_FLAGS="$EM_FLAGS -s EMTERPRETIFY=1 -s EMTERPRETIFY_ASYNC=1"
fi


export EM_FLAGS

export PY="../cpython-bpo-30386.${BITS}"


if pwd|grep -q wasm/
then
    echo WASM target
    EMCC="emcc -v ${EM_FLAGS} -s BINARYEN=1 -s WASM=1 -s BINARYEN_ASYNC_COMPILATION=0 -s BINARYEN_METHOD=\"native-wasm,asmjs\""
else
    echo ASM_JS target
    EMCC="emcc -v ${EM_FLAGS}" # -s ASM_JS=1
    EMCPP="em++ -v ${EM_FLAGS} -std=c++11"
fi

#LIB="-s BUILD_AS_SHARED_LIB=1"  # BAD ! dump FS to console
LIB="-s LINKABLE=1"  #  implicit because ERROR:root:-s LINKABLE=1 is not supported with -s USE_PTHREADS>0!
LIB="-s SIDE_MODULE=1" # VALID: minimal required !
LIB="-s SIDE_MODULE=1 -s LINKABLE=1" # VALID, -s LINKABLE=1 is implicit

lib="../panda3d-webgl-port/built/lib"


if [ -f $PY/lib/libpython3.7.so ]
then
    echo using shared libpython
    BC=$PY/lib/libpython3.7.so
else
    echo unsupported : using static libpython expect dup sym.
    BC=$PY/lib/libpython3.7.a
fi

if [ -f libpython.js ]
then
    echo "    - using cached dynamic libpython"
else
    echo "    - building shared libpython"
    echo "
        testing for globals hooks code python_hooks.cpp
"
    #-s EMULATE_FUNCTION_POINTER_CASTS=1 or initimport: can't import _frozen_importlib
    # rdb has patches but for py 2.7
    PYOPTS="-I../cpython-bpo-30386.em/include/python3.7 -s EMULATE_FUNCTION_POINTER_CASTS=1"
    if $EMCC ${PYOPTS} -s EXPORTED_FUNCTIONS=[\"_readline_hook\",\"_package_hook\"] -o python_hooks.bc python_hooks.cpp
    then
        echo "
        libpython with globals hook
"
        $EMCC ${PYOPTS} ${LIB} -s EXPORTED_FUNCTIONS=[\"_readline_hook\",\"_package_hook\"] -shared -o libpython.js ${BC} python_hooks.bc
    else
        echo "
        libpython no globals hook
"
        $EMCC ${PYOPTS} ${LIB} -s EXPORTED_FUNCTIONS=[\"_readline_hook\",\"_package_hook\"] -shared -o libpython.js ${BC}
    fi

    du -hs libpython.*
    echo
    echo 'ready'
fi

#$EMCPP -I../panda3d-webgl-port/built/include -s EXPORTED_FUNCTIONS=[\"_pview_init\",\"_pview_step\"] -o panda3d_hooks.bc panda3d_hooks.cpp

if [ -f libpanda3d.js ]
then
    echo "    - using cached dynamic libpanda3d"
else
    echo "    - building shared libpanda3d"
    #$EMCPP -I../panda3d-webgl-port/built/include -s EXPORTED_FUNCTIONS=[\"_pview_init\",\"_pview_step\"] -o panda3d_hooks.bc panda3d_hooks.cpp

    P3DOPTS="-s USE_FREETYPE=1 -s USE_WEBGL2=1  -s USE_OGG=1 -s USE_FREETYPE=1 -s USE_VORBIS=1"

    #OK
    plib="$lib/libpanda.bc"
    #plib="$plib ../panda3d-webgl-port/built/panda3d/core.bc ../panda3d-webgl-port/built/panda3d/direct.bc"
    plib="$plib $lib/libpandaexpress.bc $lib/libp3webgldisplay.bc $lib/libp3dtoolconfig.bc $lib/libp3dtool.bc "

    #plib="$plib $lib/libp3interrogatedb.bc $lib/libp3direct.bc"
    #
    # do not use  -s EMULATE_FUNCTION_POINTER_CASTS=1  !
    time $EMCC ${P3DOPTS} ${PRE} ${LIB} -shared -o libpanda3d.js $plib
    echo
    du -hs libpanda3d.js
    echo
fi

if [ -f libpp3d.js ]
then
    echo "    - using cached dynamic libpp3d"
else
    echo "    - building shared libpp3d"
    lib="../panda3d-webgl-port/built/lib"

    plib="$lib/libpanda.bc"
    plib="$plib ../panda3d-webgl-port/built/panda3d/core.bc ../panda3d-webgl-port/built/panda3d/direct.bc"
    plib="$plib $lib/libpandaexpress.bc $lib/libp3webgldisplay.bc $lib/libp3dtoolconfig.bc $lib/libp3dtool.bc "
    plib="$plib $lib/libp3direct.bc $lib/libp3interrogatedb.bc"

    # $lib/libpandabullet.bc"
    #  -s EXPORTED_FUNCTIONS=[\"_PyInit_core\",\"_PyInit_direct\"]  # not needed
    $EMCC ${PRE} ${LIB} -shared -o libpp3d.js $plib
    echo
    du -hs libpp3d.js
    echo
fi


#if [ -f libpview3d.js ]
#then
#    echo "    - using cached dynamic libpview3d"
#else
#    echo "    - building shared libpview3d"
#    lib="../panda3d-webgl-port/built/lib"
#    plib="$lib/libp3framework.bc"
#
#    # $lib/libpandabullet.bc"
#
#    $EMCC ${PRE} ${LIB} -shared -o libpview3d.js $plib panda3d_hooks.bc
#    echo
#    du -hs libpview3d.js
#    echo
#fi



#
#if [ -f libpanda.js ]
#then
#    echo "    - using cached dynamic libpanda3d"
#else
#    echo "    - building shared lib*"
#
#    for plib in ../panda3d-webgl-port/built/lib/libp*bc
#    do
#        jslib=$(basename $plib .bc).js
#        echo building $jslib
#        $EMCC ${PRE} ${LIB} -shared -o $jslib $plib
#    done
#    echo
#    du -hs lib??*.*
#fi



echo
du -hs lib*.js
echo
echo "==========================================================================="
echo

cp -vf lib*.js libpanda3d.js /srv/www/html/p3d/pydl/
cp -vf lib*.js libpanda3d.js /srv/www/html/p3d
sync

#now just compile *fast*

rm -f /srv/www/html/p3d/pydl/python.* /srv/www/html/p3d/pydl/lib*.js

export EMCC_FORCE_STDLIBS=1

EM_FLAGS="$EM_BASE -O1 -g0"


INC="-I$PY/include/python3.7/"

#todo so can compress lzma .js
#--memory-init-file 0

PRE="-s FORCE_FILESYSTEM=1 --preload-file ../stdlib@/lib"  # or ModuleNotFoundError: No module named 'encodings'

MAIN="-s MAIN_MODULE=1 -s TOTAL_MEMORY=512MB -s NO_EXIT_RUNTIME=1" # -s EMTERPRETIFY=1 -s EMTERPRETIFY_ASYNC=1"
# EXPORTED_FUNCTIONS = ['_main', '_malloc'];
# Module['noInitialRun'] or -s INVOKE_RUN=0

MAIN="$MAIN -s INVOKE_RUN=1 -s EXTRA_EXPORTED_RUNTIME_METHODS=[\"loadDynamicLibrary\"]"
#MAIN="$MAIN -s EMTERPRETIFY_WHITELIST=[\"_PyRun_AnyFileFlags\",\"_PyOS_ReadlineFunctionPointer_Impl\",\"_PyOS_ReadlineFunctionPointer\"] --profiling-funcs"
time $EMCC ${MAIN} ${PRE} $INC -o python.html python_dl.cpp
# libpython.bc


#   Module.dynamicLibraries = ['libsomething.js'];

mv -v python.* /srv/www/html/p3d/pydl/


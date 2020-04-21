APK=$1
PYVER=${PYVER:-"3.8"}



. $(echo -n ../*/bin/activate)


export ROOT=$(pwd)
export PYDK=${PYDK:-$(realpath $ROOT/..)}
export TOOLCHAIN_HOME=${TOOLCHAIN_HOME:-$(realpath ${PYDK}/emsdk)}

EMOPTS="-s ERROR_ON_UNDEFINED_SYMBOLS=1"
EMOPTS="$EMOPTS -g0 -O2 -s ENVIRONMENT=web -s USE_ZLIB=1 -s SOCKET_WEBRTC=0 -s SOCKET_DEBUG=1 -s EXPORT_ALL=1 -s USE_ZLIB=1 -s NO_EXIT_RUNTIME=1 -s MAIN_MODULE=0"
DBG="-s ASSERTIONS=1 -s DEMANGLE_SUPPORT=1 -s TOTAL_STACK=14680064 -s TOTAL_MEMORY=512MB"


export LIBDIR=${PYDK}/wasm/apkroot-wasm/usr/lib
export INCDIR=${PYDK}/wasm/apkroot-wasm/usr/include

./app/src/main/cpp/pythonsupport.c

reset
echo " Building $1 with ${TOOLCHAIN_HOME} and ${PYDK} from ${ROOT}"
echo "----------------------"


echo


function install_run
{
    APK_FILE=$1
    echo todo run view webserv + browser instance
    if [ -f $APK_FILE ]
    then
        echo "  * Running $APK_FILE press ctrl+c to terminate"

 PYTHONPATH=. \
 LD_LIBRARY_PATH=${PYDK}/host/lib:${PYDK}/host/lib64:${LD_LIBRARY_PATH} \
 ${PYDK}/host/bin/python3.8 -u -B -m pythons.js  -d $(pwd) ${WEB:-"8000"}
        echo "bye"
    fi
}

function do_pip
{
    echo " * processing pip requirement for application [$1]"
    # pip install -r requirements.txt
    # pip download --dest ../*/src/pip --no-binary :all: -r requirements-jni.txt
    mkdir -p assets/packages
    /bin/cp -Rfxpvu ${PYDK}/assets/python$PYVER/* assets/python$PYVER/
    echo "==========================================================="
    echo "${APKUSR}/lib/python${PYVER}/site-packages/ *filtered* => assets/packages/ "
    echo "==========================================================="

    for req in $(find ${PYDK}/assets/packages/ -maxdepth 1  | egrep -v 'info$|egg$|pth$|txt$|/$')
    do
        if find $req -type f|grep so$
        then
            echo " * can't add package : $(basename $req) not pure python"
        else
            echo " * adding pure-python pip package : $(basename $req)"
            cp -ru $req assets/packages/
        fi
    done

}

function do_stdlib
{

    if [ -f python3.8.zip ]
    then
        echo stdlib zip ready
    else
        echo " * prepare stdlib for zip archiving"
        mkdir -p assets/python$PYVER
        /bin/cp -Rfxpvu ${PYDK}/src/python3-wasm/Lib/. assets/python$PYVER/|egrep -v "test/|lib2to3"
        rm -rf assets/python$PYVER/test assets/python$PYVER/unittest
        rm -rf assets/python$PYVER/lib2to3 assets/python$PYVER/site-packages

        echo " * overwriting with specific stdlib platform support"
        /bin/cp -aRfvx ${PYDK}/sources.wasm/stdlib/. assets/

        WD=$(pwd)
        cd assets/python3.8
        zip "${WD}/python3.8.zip" -r .
        cd "${WD}"
        rm -rf assets/python$PYVER
    fi
}


function do_clean
{
    echo " * Removing old builds"

    # so install_run won't pick up last build in case of failure.
    echo todo remove webapk

    # cleanup potentially incompatible bytecode
    rm -rf $(find assets/ -type d|grep /__pycache__$)

}


if cd $1
then
    if echo $@ |grep clean
    then
        do_clean

        # go deeper.
        echo "<ctrl+C> to abort, i WILL destroy : prebuilt" assets/python3.? assets/packages
        read cont
        rm -rf  prebuilt assets/python3.? assets/packages

    else
        echo " * syncing stdlib for $PYVER"

        mkdir -p assets/python$PYVER/

        # cleanup


        # copy generic python platform support
        cp -Rfxpvu ${PYDK}/sources.py/. assets/

        # copy specific python platform support
        cp -fxpvu ${PYDK}/sources.wasm/*.py assets/

        # copy specific C platform support
        cp -fxpvu ${PYDK}/sources.wasm/*.c ./app/src/main/cpp/

        # copy test runner support
        cp -Rfxpvu ${PYDK}/sources.wasm/pythons ./

        # todo move test folder with binary cmdline support into separate archive
        # until testsuite is fixed.
        echo " * Copy/Update prebuilt from ${PYDK}/prebuilt for local project"
        echo 'skipped'
        #/bin/cp -Rfxpvu ${PYDK}/prebuilt ./ |wc -l

        echo " * Copy/Update prebuilt from ${PYDK}/prebuilt.aosp for local project (pip+thirdparty modules)"
        echo 'skipped'
        #/bin/cp -Rfxpvu ${PYDK}/prebuilt.wasm/* ./prebuilt/ |wc -l

         #$(ls ${PYDK}/prebuilt)
        for ARCH in "wasm"
        do
            echo " * Copy/Update include from $(echo ${PYDK}/*/apkroot-$ARCH/usr) for local project"
            /bin/cp -Rfxpvu ${PYDK}/*/apkroot-${ARCH}/usr/include ./prebuilt/$ARCH/ |wc -l

            echo " * Copy/Update prebuilt thirdparty libs from $(echo ${PYDK}/*/apkroot-$ARCH/usr) for local project"
            echo 'skipped NO DLOPEN yet'
            #/bin/cp -Rfxpvu ${PYDK}/*/apkroot-${ARCH}/usr/lib/lib*.so ./prebuilt/$ARCH/ |wc -l

        done

        do_pip ${APK}

        do_stdlib ${APK}

        if [ -d patches ]
        then
            echo " applying user patches"
            cp -Rfvpvu patches/. assets/
        fi


        do_clean ${APK}

        shift 1

        . ${TOOLCHAIN_HOME}/emsdk_env.sh

        emcc -static $DBG \
 -s 'EXTRA_EXPORTED_RUNTIME_METHODS=["ccall", "cwrap", "getValue", "stringToUTF8"]' \
 -I${INCDIR} -I${INCDIR}/python3.8 $EMOPTS \
 --preload-file ./assets@/assets --preload-file ./lib@/lib  --preload-file python3.8.zip \
 -o python.html ./app/src/main/cpp/pythonsupport.c\
 -L${LIBDIR} -lpython3.8 -lssl -lcrypto\
 "$@"


        #./gradlew assembleDebug "$@"
        cp -uv ./app/src/main/res/index.html ./

        if echo $@|grep -q build
        then
            echo "build-only terminated"
        else
            echo " * pushing and running apk $FILE"
            install_run $FILE
        fi
    fi
fi


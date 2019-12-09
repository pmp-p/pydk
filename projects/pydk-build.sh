APK=$1
PYVER="3.7"


. $(echo -n ../*/bin/activate)


export ROOT=$(pwd)
export PYDK=${PYDK:-$(realpath $ROOT/..)}
export ANDROID_HOME=${ANDROID_HOME:-$(realpath ${PYDK}/android-sdk)}


reset
echo " Building $1 with ${ANDROID_HOME} and ${PYDK} from ${ROOT}"
echo "----------------------"


FILE=./app/build/outputs/apk/release/app-release-unsigned.apk
FILE=./app/build/outputs/apk/debug/app-debug.apk
ADB=$ANDROID_HOME/platform-tools/adb

echo " * un-installing any previous version on test device"
$ADB uninstall $APK

echo


function install_run
{
    APK_FILE=$1
    if [ -f $APK_FILE ]
    then
        echo "  * installing $APK_FILE"
        $ADB install $APK_FILE
        aapt=$(find $ANDROID_HOME/build-tools/|grep aapt$|sort|tail -n1)
        pkg=$($aapt dump badging "$APK_FILE"|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
        act=$($aapt dump badging "$APK_FILE"|awk -F" " '/launchable-activity/ {print $2}'|awk -F"'" '/name=/ {print $2}')
        echo "Running $pkg/$act"
        $ADB shell am start -n "$pkg/$act"

        echo "press <enter> to kill app"
        read
        echo "$ADB shell am force-stop $APK"
        $ADB shell am force-stop $APK
    fi
}

function do_pip
{
    echo " * processing pip requirement for application [$1]"
    pip install -r requirements.txt
    # pip download --dest ../*/src/pip --no-binary :all: -r requirements-jni.txt
    mkdir -p assets/packages
    /bin/cp -Rfxpvu ${PYDK}/assets/python$PYVER/* assets/python$PYVER/
    echo "==========================================================="
    echo "${PYDK}/*/lib/python3.?/site-packages/ *filtered* => assets/packages/ "
    echo "==========================================================="
    for req in $(find ${PYDK}/*/lib/python3.?/site-packages/ -maxdepth 1 -type d|egrep -v '/$|/skbuild$|/cmake$|/setuptools$|/pkg_resources$|/packaging$|/__pycache__$|-info$')
    do
        if find $req -type f|grep so$
        then
            echo " * can't add package : $(basename $req) not pure python"
        else
            echo " * adding pure-python pip package : $(basename $req)"
            cp -ru $req assets/packages/
        fi
    done
    cp -u ${PYDK}/*/lib/python3.?/site-packages/*.py assets/packages/
}

function do_stdlib
{
    /bin/cp -Rfxpvu ${PYDK}/*/src/python3-android/Lib/. assets/python$PYVER/|egrep -v "test/|lib2to3"
    rm -rf assets/python$PYVER/test assets/python$PYVER/unittest assets/python$PYVER/lib2to3 assets/python$PYVER/site-packages
}


function do_clean
{
    echo " * Removing old builds"

    # so install_run won't pick up last build in case of failure.
    rm ./app/build/outputs/apk/debug/app-debug.apk ./app/build/outputs/apk/release/app-release-unsigned.apk

    # cleanup potentially incompatible bytecode
    rm -rf $(find assets/ -type d|grep /__pycache__$)

    ./gradlew clean
}


# that trick is only valid is for rooted dev. It will partially reset device

if echo $@ |grep log
then
    $ADB root
    $ADB shell stop
    $ADB shell setprop log.redirect-stdio true
    $ADB shell setprop debug.ld.all dlerror,dlopen
    $ADB shell start
    exit
fi


if cd $1
then
    if echo $@ |grep clean
    then
        do_clean

        # go deeper.
        echo "<ctrl+C> to abort, i WILL destroy : prebuilt" assets/python3.? assets/packages
        read cont
        rm -rf app/build app/.externalNativeBuild prebuilt assets/python3.? assets/packages

    else
        echo " * syncing stdlib for $PYVER"

        mkdir -p assets/python$PYVER/

        # cleanup


        # todo move test folder with binary cmdline support into separate archive
        # until testsuite is fixed.
        echo " * Copy/Update prebuilt from ${PYDK}/prebuilt for local project"
        /bin/cp -Rfxpvu ${PYDK}/prebuilt ./ |wc -l


        for ARCH in $(ls ${PYDK}/prebuilt)
        do
            echo " * Copy/Update include from $(echo ${PYDK}/*/apkroot-$ARCH/usr) for local project"
            /bin/cp -Rfxpvu ${PYDK}/*/apkroot-${ARCH}/usr/include  ./prebuilt/$ARCH/ |wc -l
        done

        do_pip ${APK}

        do_stdlib ${APK}

        do_clean ${APK}

        shift 1
        ./gradlew assembleDebug "$@"

        if echo $@|grep -q build
        then
            echo "build-only terminated"
        else
            echo " * pushing and running apk $FILE"
            install_run $FILE
        fi
    fi
fi


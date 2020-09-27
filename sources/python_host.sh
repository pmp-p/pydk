# PYTHONDONTWRITEBYTECODE
# CI : running CI flag
# JFLAGS :  make options
# CNF : configure options

export PYTHON3_URL=${PYTHON3_URL:-"URL https://github.com/python/cpython/archive/v${PYVER}.tar.gz"}

case "${PYVER}" in
    "3.7.5" ) export PYTHON3_HASH=${PYTHON3_HASH:-"URL_HASH SHA256=349ac7b4a9d399302542163fdf5496e1c9d1e5d876a4de771eec5acde76a1f8a"};;
    "3.7.7" ) export PYTHON3_HASH=${PYTHON3_HASH:-"URL_HASH SHA256=93f87673997082e7865867b5d0a511ecc9329cc57f9304df1e6d5573ccba40d6"};;
    "3.8.1" ) export PYTHON3_HASH=${PYTHON3_HASH:-"URL_HASH SHA256=48af0a22d12523bfe3c4f2e35497aa5d3dc069ad0828d4768ecc38aae8b9cf08"};;
    "3.8.2" ) export PYTHON3_HASH=${PYTHON3_HASH:-"URL_HASH SHA256=f5590c4c8978eb35a9ea14160af683ff07b6129dadf9a72b338bab3f3d493466"};;
    "3.8.3" ) export PYTHON3_HASH=${PYTHON3_HASH:-"URL_HASH SHA256=69516193a2ccba55d555375f6dd376174b0cf46242549b52c2214c36e6177f80"};;
    "3.8.5" ) export PYTHON3_HASH=${PYTHON3_HASH:-"URL_HASH SHA256=ebac44a9393c034b8e5c8387675ead5bb5b15770f78076e4376cb603864f700e"};;
esac

export PYOPTS="--without-pymalloc --without-pydebug\
 --disable-ipv6 --with-c-locale-coercion\
 --with-computed-gotos"


export PYTARGET="${BUILD_SRC}/python3-${ENV}"


export PYTHONDONTWRITEBYTECODE=1

if echo $CI|grep -q true
then
    JOBS=4
    export PYTHON=${PYTHON_FOR_CI:-$(command -v python3.6)}
    echo "CI-force-test $PYTHON, ncpu=$JOBS"

else
    #restrict $PYMINOR for env so host pip can work for populating android projects
    for py in ${PYMINOR} 7 6 5
    do
        if command -v python3.${py}
        then
            export PYTHON=$(command -v python3.${py})
            break
        fi
    done
fi

if echo $PYTHON |grep -q python3.6
then
    CI=true
else
    CI=${CI:-false}
fi

if $CI
then
    JOBS=${JOBS:-8}
    JFLAGS="-s -j $JOBS"
    CNF="--silent"
    if [ -f ${ENV}/bin/activate ]
    then
        echo " * using previous build dir ${ROOT} (CI)"
    else
        echo " * create venv ${ROOT} (CI)"
        #pclinuxos 3.6.5 --without-pip  ?
        $PYTHON -m venv --prompt pydk-${ENV} ${ENV}
        touch ${ENV}/new_env
    fi
else
    CI=false
    JOBS=${JOBS:-4}
    JFLAGS="-j $JOBS"
    CNF=""
    if [ -f ${ENV}/bin/activate ]
    then
        echo " * using previous build dir ${ROOT} because found ${ENV}"
    else
        echo " * create venv ${ROOT}"
        $PYTHON -m venv --prompt pydk-${ENV} ${ENV}
        ln -s ${ANDROID_HOME}/platform-tools/adb ${ENV}/bin/adb
        touch ${ENV}/new_env
    fi
fi


cd ${ROOT}

. bin/activate

cd ${ROOT}

mkdir -p ${BUILD_SRC}

date > ${BUILD_SRC}/build.log
env >> ${BUILD_SRC}/build.log
echo  >> ${BUILD_SRC}/build.log
echo  >> ${BUILD_SRC}/build.log

# DO NOT USE  -m pip what would not use venv
export PIP3="pip3 install --no-warn-script-location --upgrade"

if $CI
then
    echo CI - no pip upgrade
    export QUIET="1>/dev/null"
else
    $PIP3 pip
    $PIP3 setuptools
    $PIP3 Cython
fi

if [ -f new_env ]
then

    if $PIP3 scikit-build
    then
        if $PIP3 "cmake==${CMAKE_VERSION}"
        then
            rm new_env
        fi
    fi
fi

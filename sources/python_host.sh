# PYTHONDONTWRITEBYTECODE
# CI : running CI flag
# JFLAGS :  make options
# CNF : configure options

export PYTHON3_URL=${PYTHON3_URL:-"URL https://www.python.org/ftp/python/${PYVER}/Python-${PYVER}.tar.xz"}

case "${PYVER}" in
    "3.7.9" ) export PYTHON3_HASH=${PYTHON3_HASH:-"URL_HASH MD5=389d3ed26b4d97c741d9e5423da1f43b"};;
    "3.8.5" ) export PYTHON3_HASH=${PYTHON3_HASH:-"URL_HASH MD5=35b5a3d0254c1c59be9736373d429db7"};;
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
# --no-warn-script-location
export PIP3="pip3 install --upgrade"

if $CI
then
    echo CI - FORCING pip upgrade
    pip3 install --upgrade pip
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

    if [ -f ${ROOT}/bin/cmake ]
    then
        echo cmake build ok
    else
        echo "


    

        [ UNSUPPORTED ] your system could not build cmake requested version, will use system version





"
        sleep 3
        ln -s $(comman -v cmake) ${ROOT}/bin/cmake
    fi

fi

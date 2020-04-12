# PYTHONDONTWRITEBYTECODE
# CI : running CI flag
# JFLAGS :  make options
# CNF : configure options


export PYTHONDONTWRITEBYTECODE=1

if echo $CI|grep -q true
then
    echo "CI-force-test python3.6, ncpu=4"
    JOBS=4
    export PYTHON=python3
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

if $CI
then
    echo CI - no pip upgrade
    export QUIET="1>/dev/null"
else
    pip3 install --upgrade pip
    pip3 install --upgrade setuptools
    pip3 install --upgrade Cython
fi

if [ -f new_env ]
then

    if pip3 install scikit-build
    then
        if pip3 install "cmake==${CMAKE_VERSION}"
        then
            rm new_env
        fi
    fi
fi

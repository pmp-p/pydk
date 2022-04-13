# PYTHONDONTWRITEBYTECODE
# CI : running CI flag
# JFLAGS :  make options
# CNF : configure options


#export URL_PYTHON3=${URL_PYTHON3:-"URL https://www.python.org/ftp/python/3.11.0/Python-3.11.0a6.tar.xz"}

export URL_PYTHON3=${URL_PYTHON3:-"URL https://www.python.org/ftp/python/${PYVER}/Python-${PYVER}.tar.xz"}


case "${PYVER}" in
    "3.7.13" ) export  HASH_PYTHON3=${HASH_PYTHON3:-"URL_HASH MD5=10822726f75fd7efe05a94fbd6ac2258"};;
    "3.8.13" ) export  HASH_PYTHON3=${HASH_PYTHON3:-"URL_HASH MD5=c4b7100dcaace9d33ab1fda9a3a038d6"};;
    "3.9.12" ) export   HASH_PYTHON3=${HASH_PYTHON3:-"URL_HASH MD5=4b5fda03e3fbfceca833c997d501bcca"};;
    "3.10.4" ) export   HASH_PYTHON3=${HASH_PYTHON3:-"URL_HASH MD5=21f2e113e087083a1e8cf10553d93599"};;
    "3.11.0a5" ) export   HASH_PYTHON3=${HASH_PYTHON3:-"URL_HASH MD5=6bc7aafdec900b4b00ab6b5b64619dd4"};;
esac

export PYOPTS="--without-pymalloc --without-pydebug\
 --disable-ipv6 --with-c-locale-coercion\
 --with-computed-gotos"


export PYTARGET="${BUILD_SRC}/python3-${ENV}"


export PYTHONDONTWRITEBYTECODE=1

#restrict $PYMINOR for env so host pip can work for populating android projects
# if not avail take the higher one
for py in ${PYMINOR} 11 10 9 8 7 6 5
do
    if command -v python3.${py}
    then
        export PYTHON=$(command -v python3.${py})
        break
    fi
done


if echo $CI|grep -q true
then
    JOBS=4
    export PYTHON=${PYTHON_FOR_CI:-$PYTHON}
    echo "CI-force-test $PYTHON, ncpu=$JOBS"
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
export PIP3_install="pip3 install"

if $CI
then
    echo CI - FORCING pip upgrade
    #$PIP3_install pip==20.3.1
    $PIP3 pip
    export QUIET="1>/dev/null"
else
    #$PIP3_install pip==20.3.1
    $PIP3 pip
    #$PIP3_install setuptools==51.0.0
    $PIP3 setuptools
    $PIP3 Cython
fi

if [ -f new_env ]
then

    if $PIP3 scikit-build
    then
        if $PIP3 "cmake==${CMAKE_VERSION}"
        then
            echo maybe ok
        else
            echo " * NOT BUILDING CMAKE (too buggy), using anything in path"
        fi

        if command -v cmake |grep -q cmake
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
        ln -s $(command -v cmake) ${ROOT}/bin/cmake
    fi

fi

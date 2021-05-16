# PYTHONDONTWRITEBYTECODE
# CI : running CI flag
# JFLAGS :  make options
# CNF : configure options

export URL_PYTHON3=${URL_PYTHON3:-"URL https://www.python.org/ftp/python/${PYVER}/Python-${PYVER}.tar.xz"}

case "${PYVER}" in
    "3.7.9" ) export   HASH_PYTHON3=${HASH_PYTHON3:-"URL_HASH MD5=389d3ed26b4d97c741d9e5423da1f43b"};;
    "3.7.10" ) export  HASH_PYTHON3=${HASH_PYTHON3:-"URL_HASH MD5=9e34914bc804ab2e7d955b49c5e1e391"};;
    "3.8.5" ) export   HASH_PYTHON3=${HASH_PYTHON3:-"URL_HASH MD5=35b5a3d0254c1c59be9736373d429db7"};;
    "3.8.8" ) export   HASH_PYTHON3=${HASH_PYTHON3:-"URL_HASH MD5=23e6b769857233c1ac07b6be7442eff4"};;
    "3.8.10" ) export  HASH_PYTHON3=${HASH_PYTHON3:-"URL_HASH MD5=d9eee4b20155553830a2025e4dcaa7b3"};;
    "3.9.0" ) export   HASH_PYTHON3=${HASH_PYTHON3:-"URL_HASH MD5=6ebfe157f6e88d9eabfbaf3fa92129f6"};;
    "3.9.1" ) export   HASH_PYTHON3=${HASH_PYTHON3:-"URL_HASH MD5=61981498e75ac8f00adcb908281fadb6"};;
    "3.9.2" ) export   HASH_PYTHON3=${HASH_PYTHON3:-"URL_HASH MD5=f0dc9000312abeb16de4eccce9a870ab"};;
esac

export PYOPTS="--without-pymalloc --without-pydebug\
 --disable-ipv6 --with-c-locale-coercion\
 --with-computed-gotos"


export PYTARGET="${BUILD_SRC}/python3-${ENV}"


export PYTHONDONTWRITEBYTECODE=1

#restrict $PYMINOR for env so host pip can work for populating android projects
for py in ${PYMINOR} 8 7 6 5
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

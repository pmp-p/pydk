# PYTHONDONTWRITEBYTECODE
# CI : running CI flag
# JFLAGS :  make options
# CNF : configure options


export PYTHONDONTWRITEBYTECODE=1

if echo $CI|grep -q true
then
    echo "CI-force-test python3.6, ncpu=4"
    JOBS=4
    export PYTHON=/usr/local/bin/python3.6
else
    for py in 8 7 6 5
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
    if [ -d ${ENV} ]
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
    if [ -d ${ENV} ]
    then
        echo " * using previous build dir ${ROOT}"
    else
        echo " * create venv ${ROOT}"
        $PYTHON -m venv --prompt pydk-${ENV} ${ENV}
        touch ${ENV}/new_env
    fi
fi

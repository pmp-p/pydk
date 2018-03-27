#!/bin/bash


export BITS=em

reset

ORIGIN=$(dirname $(realpath "$0") )



if echo "$1"|grep -q data
then
    SDK_ROOT="$1"
    echo "
You have selected custom destination [$SDK_ROOT]
( note that /data/data may be the safest option )
    "


else
    #change that if you don't want to use current folder
    SDK_ROOT="$DIST"
fi

if echo "$2"|grep -q emsdk_set_env
then
    EMSDK="$2"
    echo "
You have selected emsdk from [$(dirname $EMSDK)]
    "
else
    echo "can't find emsdk_set_env.sh argument"
    exit 1
fi


if [ -d "$ORIGIN/archives" ]
then
    ARCHIVES="$ORIGIN/archives"
else
    ARCHIVES="$SDK_ROOT/archives"
fi

echo "
* Will cache sdk sources in [$ARCHIVES]
"


SDK=$SDK_ROOT


export ORIGIN ARCHIVES

mkdir -p ${SDK_ROOT} $ARCHIVES $SDK
cd ${SDK_ROOT}


function wait_or_break
{
    echo -n  "
 <press enter to retry, or ctrl+c to exit>



> "
    read
    clear
}

while true
do
    if which realpath >/dev/null
    then
        break
    else
        echo "Please install 'pv' utility (sudo apt-get install pv )"
        wait_or_break
    fi
done

while true
do
    if which realpath >/dev/null
    then
        break
    else
        echo "Please install 'realpath' utility ( eg sudo apt-get install realpath )"
        wait_or_break
    fi
done




cat <<END >> "$SDK_ROOT/sdk.em.env"
#sources
export ORIGIN=$ORIGIN
export ARCHIVES=$ARCHIVES
export SDK=$SDK_ROOT

#path to toolchain activation script, sourced after host builds
export TOOLCHAIN=$2
export BITS=$BITS

#tweaks
export PYTHONDONTWRITEBYTECODE=1

if [ -f $SDK/built.${BITS}.env ]
then
    source "$SDK/build.${BITS}.env"
    source "$SDK/built.${BITS}.env"
    source "$SDK/build.functions"
    source "$SDK/build.${BITS}.functions"
else
    echo "build env $SDK/build.${BITS}.env not configured yet"
fi

END






if [ -f $SDK/build.${BITS}.env ]
then
    echo "
    Previous build parameters found, preserving  :

    $SDK/build.${BITS}.env
    ${ORIGIN}/build.${BITS}.functions
    $SDK/built.${BITS}.env

"

else
    echo "Copying default build parameters : $SDK/build.${BITS}.env"
    #echo "export PDK_PATCHELF=${TOOLCHAIN}/bin/patchelf" > $SDK/built.${BITS}.env

    mkdir -p $SDK/build.${BITS}

    cp -vf ${ORIGIN}/build.${BITS}.env $SDK/
    ln ${ORIGIN}/build.${BITS}.functions $SDK/
    ln ${ORIGIN}/build.functions $SDK/

    ln ${ORIGIN}/sources.${BITS}/*.build $SDK/build.${BITS}/
    cp -aR ${ORIGIN}/sources.${BITS}/*.patchset $SDK/build.${BITS}/

    #activate the platform
    touch $SDK/built.${BITS}.env
fi






































































#

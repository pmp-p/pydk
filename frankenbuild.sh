#!/bin/bash

#==============================================================================

# changing those is totally untested feel free to test and report ...

NDK_VER=14
export BITS=32


#==============================================================================

reset

ORIGIN=$(dirname $(realpath "$0") )

if echo "$2"|grep -q \.
then
    export ADB_NET=$2
    echo "
You have selected custom adb networked device $ADB_NET:5555
    "
fi

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
NDK=android-ndk-r14b
UROOT=$SDK/u.root
UR=$SDK_ROOT/u.r

export TOOLCHAIN="${SDK_ROOT}/cross.${BITS}"
export USRC="$SDK_ROOT/u.src"
export ANDROID_SDK_ROOT="$SDK/android/sdk"
export ANDROID_NDK_ROOT="$SDK/android/$NDK"

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



echo "
-------------------------------------------------------------------------------
    The Build environnement will be located in [${SDK_ROOT}] :

    An adb device will be automatically set on $ADB_NET:5555
    fallback is adb over usb.


    * [$SDK_ROOT/sdk.env] will hold generic values for NDK [${NDK}] building

    * You need host build tools.
        eg: 'sudo apt-get install build-essential' on debian like systems.

    * You need host jdk8 or 9.
        eg: 'sudo apt-get install openjdk-9-jdk-headless' on ubuntu like systems.

    * You may need qemu-static flavor for your board if you want to install
      onboard compiler.

    * sdk will be created in [$UROOT].
        you don't need that folder on device when using cross compile.

    * runtime will go in [$UR], that is the folder you want to sync on device.

-------------------------------------------------------------------------------
"

while true
do
    if [ -d $ANDROID_SDK_ROOT/sources/android-19 ]
    then
        echo "
    found android sdk/api-19 : $ANDROID_SDK_ROOT
"
        break
    else
        echo "Please install Android SDK with API-19 in [$ANDROID_SDK_ROOT], probably use android studio to do that ...
        or symlink your existing SDK installation eg 'ln -s /opt/android/sdk $ANDROID_SDK_ROOT'
"
        wait_or_break
    fi
done


while true
do
    if grep -q $NDK_VER $ANDROID_NDK_ROOT/source.properties 2>/dev/null
    then
        echo "
    found android ndk $NDK_VER : $ANDROID_NDK_ROOT
        "
        break
    else
        echo "
Missing $NDK:

    Please get Android $NDK_VER
    from https://developer.android.com/ndk/downloads/older_releases.html
    and unpack in $SDK

    ( I look for version $NDK_VER in file [$ANDROID_NDK_ROOT/source.properties] )
    "
        wait_or_break
    fi
done

mkdir -p ${TOOLCHAIN}/bin

ln -sf /bin/bash ${UR}/shell


cd "${SDK_ROOT}"

export UROOT UR USRC

env|grep ^UR > "$SDK_ROOT/sdk.env"



cat <<END >> "$SDK_ROOT/sdk.env"
#device target
export ADB_NET=$ADB_NET
export UROOT=$UROOT
export UR=$UR
export BITS=$BITS

#sources
export ORIGIN=$ORIGIN
export ARCHIVES=$ARCHIVES
export SDK=$SDK_ROOT

#android globals
export ANDROID_NDK_ROOT=$ANDROID_NDK_ROOT
export NDK=$ANDROID_NDK_ROOT
export ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT
export ANDROID_HOME=$ANDROID_SDK_ROOT

#make patchelf/bash/ndk/gcc and toolchain available
export TOOLCHAIN=$TOOLCHAIN
export TC=${TOOLCHAIN}/bin
export CLANG=${TOOLCHAIN}/bin/clang
export CL_PP=${TOOLCHAIN}/clang++
export PATH=$SDK/android/bin:${ANDROID_NDK_ROOT}:$PATH

#tweaks
export PYTHONDONTWRITEBYTECODE=1



#say hi
echo SDK=$SDK Toolchain ${BITS} ${TOOLCHAIN}
if [ -f $SDK/built.${BITS}.env ]
then    
    . "$SDK/build.${BITS}.env"
    . "$SDK/built.${BITS}.env"
    . "$SDK/build.${BITS}.functions"   
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
        
    ln ${ORIGIN}/sources.${BITS}/*.build $SDK/build.${BITS}/
    cp -aR ${ORIGIN}/sources.${BITS}/*.patchset $SDK/build.${BITS}/

    #activate the platform
    touch $SDK/built.${BITS}.env
fi


. $SDK_ROOT/sdk.env

echo "installing armv7a-none-linux-android toolchain  in $TOOLCHAIN"
$NDK/build/tools/make_standalone_toolchain.py \
 --arch arm --api 19 --stl=gnustl --force --install-dir $TOOLCHAIN



while true
do
    if [ -x ${UROOT}/bin/patchelf ]
    then
        echo "
found patchelf tool : ${UROOT}/bin/patchelf
        "
        break
    else
        cd "${ORIGIN}/frankenstax/patchelf"
        echo "Building patchelf tool"
        if ./configure --prefix=${TOOLCHAIN} 2>&1 >build.log && make 2>&1 >> build.log
        then
            mkdir -p ${UROOT}/bin/
            cp -vf src/patchelf ${TOOLCHAIN}/bin/
            register_pdk PDK_PATCHELF ${TOOLCHAIN}/bin/patchelf
            break
        else
            echo " =============== error ================== "
            cat build.log
            wait_or_break
        fi
    fi
done


#installing frankenloader
cd $ORIGIN/frankenstax/qemu-wrapper.$BITS
mkdir -p $UR/bin

$CLANG -o $UR/bin/386 qemu-wrapper.c

cp -vf static/qemu-* $UR/bin/

mkdir -p $SDK/build.${BITS}


echo "


$SDK/build.${BITS}.env was created, you can now use:

. $SDK_ROOT/sdk.env

Before running build.${BITS}/*.build scripts

 "


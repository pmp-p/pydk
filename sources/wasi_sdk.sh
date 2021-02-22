#!/bin/bash
export WASI_SDK_PATH=$(realpath $(dirname "$BASH_SOURCE")/../wasi-sdk)
PYDK=${PYDK:-$(realpath $(dirname $WASI_SDK_PATH))}
ROOT=$(pwd)


# https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-12/wasi-sdk-12.0-linux.tar.gz
URL_WASI="https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-12/wasi-sdk-12.0-linux.tar.gz"

if [ -d "$WASI_SDK_PATH" ]
then
    echo "
    * wasi sdk found at $WASI_SDK_PATH
"
else
    # remove failed downloads if any
    echo "
about to download/unpack $URL_WASI toward $PYDK/wasi-sdk,  continue ?
<pres enter>
    "
    read
    cd $PYDK
    rm wasi-sdk-*-linux.tar.gz
    wget $URL_WASI
    tar xfz wasi-sdk-*-linux.tar.gz && rm wasi-sdk-*-linux.tar.gz && mv wasi-sdk-* wasi-sdk
    cd $ROOT
fi


export PATH=${WASI_SDK_PATH}/bin:$PATH

SYSROOT="--sysroot=$(realpath ${WASI_SDK_PATH}/share/wasi-sysroot) --target=wasm32-unknown-wasi"
FIX="-D__WASI__=1 $FIX"


export CC="${WASI_SDK_PATH}/bin/clang -g0 -Os ${SYSROOT} $FIX"
export CXX="${WASI_SDK_PATH}/bin/clang++ -g0 -Os ${SYSROOT} $FIX"
export CPP="${WASI_SDK_PATH}/bin/clang ${SYSROOT} $FIX -E"



echo " wasi sdk set as:
CC=$CC
CXX=$CXX
CPP=$CPP
"


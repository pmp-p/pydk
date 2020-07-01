#!/bin/bash
if [ -f pydk-all.sh ]
then
    rm -rf prebuilt* pycache/* src wasm aosp host
else
    echo only to be run from a pydk build root
fi

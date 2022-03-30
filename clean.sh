#!/bin/bash
if [ -f pydk-all.sh ]
then
    rm -rf prebuilt* pycache/* pycache/.???* src wasm aosp host
    rm shell.*.sh
    rmdir pycache
else
    echo only to be run from a pydk build root
fi

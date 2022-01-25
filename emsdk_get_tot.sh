#!/bin/bash

if git clone https://github.com/emscripten-core/emsdk.git
then
    cd emsdk
    ./emsdk install tot
    ./emsdk activate tot
fi

#!/bin/sh
echo SDK https://developer.android.com/studio
echo NDK https://developer.android.com/ndk/downloads

sudo apt install \
 build-essential clang git\
 python3-pip python3-venv\
 cmake ninja-build\
 libfuse-dev\
 libsqlite3-dev ninja-build bison flex zlib1g-dev\
 libgl1-mesa-dev libgles2-mesa-dev libglapi-mesa mesa-common-dev libegl1-mesa-dev\
 libbullet-dev libfreetype6-dev libjpeg-dev libode-dev libopenal-dev libpng-dev libssl-dev libogg-dev libvorbis-dev


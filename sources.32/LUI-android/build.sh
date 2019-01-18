#!/bin/bash

rm -rf linux_*_panda1.10.0_py37 android_*_panda1.10.0_py37

$PDK_PANDA3D/pandahost.sh build.py --clean "$@"

cp -vf lui.so /data/data/armhf/u.r/usr/lib/python3.7/site-packages/panda3d/
cp -vf lui.so /data/target/u.r/usr/lib/python3.7/site-packages/panda3d/

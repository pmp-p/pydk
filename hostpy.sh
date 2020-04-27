#!/bin/sh
export PYDK=$(dirname $(realpath "$0"))
PYVER=3.8

export PATH=$PYDK/host/bin:$PATH
export LD_LIBRARY_PATH=$PYDK/host/lib


export LD_LIBRARY_PATH=$PYDK/host/lib:$PYDK/host/lib64:$LD_LIBRARY_PATH
export PYTHONPATH=$PYDK/host/lib/python$PYVER:$PYDK/host/lib/python$PYVER/site-packages
python$PYVER -i -u -B "$@"

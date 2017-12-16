#!/bin/bash
reset

#FIXME paths with spaces

. /data/data/sdk.env

if echo $ANDROID_API|grep -q 19
then
    echo "WITH_LIBRARIES==$WITH_LIBRARIES =>  readline/sqlite won't fix"
    export WITH_LIBRARIES="libffi,openssl,ncurses"    
    echo "using WITH_LIBRARIES=$WITH_LIBRARIES"

fi    

echo "panda3d not clang ready"
export NDK_GCC="gcc"

echo "<enter> to continue"
read


ROOT=$(pwd)

OPT_COMMON="--no-eigen --use-gles --use-gles2 --use-zlib"
OPT_ANDROID="--arch $ANDROID_ARCH --target android --no-pview --no-pandatool --use-neon --no-sse2"


export DEV_PATHS DEV_TARGET PYVER PYDOT PYMODE OPT_COMMON OPT_ANDROID

export PYTHONDONTWRITEBYTECODE=1


#export PYTHONDEVMODE=1
PYTHON=$(pwd)/cpython-bpo-30386/Android/build/python-native/python


if [ -f $PYTHON ]
then
    echo "
    * found TARGET $PYTHON - skipping HOST + TARGET build
"    
else
	if mkdir -p ${DEV_TARGET}
	then
		echo Building HOST + TARGET cpython${PYVER}${PYMODE}
		cd cpython-bpo-30386/Android
		if ./makesetup $DEV_PATHS --without-ensurepip --with-c-locale-coercion --disable-ipv6 --with-computed-gotos --with-system-ffi --enable-shared
		then
		
			#will fail on ncurses as first pass 
			if make
			then
			    echo "great built on first pass - you lucky owner of a perfect build env"
			else
			    echo 'that was expected because i told you so'
        		cp -vf ${ROOT}/external_patched/ncurses-6.0.tar.gz ${ROOT}/cpython-bpo-30386/Android/build/external-libraries/			    
    			echo "fixed stuff ... maybe,  press <enter>"			
    			read
			    make
			fi
			#make install 			
			cp -vf ./build/python3.7-android-${ANDROID_API}-${ANDROID_ARCH}/python ${DEV_TARGET}/usr/bin/python3.7
			cp -vf ./build/python3.7-android-${ANDROID_API}-${ANDROID_ARCH}/libpython3.*.so ${DEV_TARGET}/lib-armhf/
		fi
	fi

fi

cd ${ROOT}


if [ -f $PYTHON ] 
then
    echo "
	    * cleaning up thirdparties
    "
    rm -rf android-libs-armv7 panda3d/thirdparty

    cd ${ROOT}/panda3d

#    echo "sudo apt-get install build-essential checkinstall pkg-config python-dev libpng-dev libjpeg-dev libtiff-dev zlib1g-dev libssl-dev libx11-dev libgl1-mesa-dev libxrandr-dev # libxxf86dga-dev libxcursor-dev bison flex libfreetype6-dev libvorbis-dev libeigen3-dev libopenal-dev libode-dev libbullet-dev nvidia-cg-toolkit libgtk2.0-dev libgles2-mesa-dev"

    echo "
	    * Entering $(pwd)
    "
    mkdir -p thirdparty
    mkdir -p ../android-libs-${ANDROID_ARCH}
    ln -sf ../../android-libs-${ANDROID_ARCH} ./thirdparty/

    export TP=$(pwd)/thirdparty/android-libs-${ANDROID_ARCH}


    echo "
        * Setting Host python ${TP}/python include+lib
    "
    mkdir -p ${TP}/python${PYVER}/{lib,include,include/python${PYDOT}${PYMODE}}
    rm ${TP}/python || echo -n
    ln -sf ${TP}/python${PYVER} ${TP}/python


    cp -f ../cpython-bpo-30386/Include/*.h ${TP}/python${PYVER}/include/python${PYDOT}${PYMODE}/
    cp -vf ../cpython-bpo-30386/Android/build/python-native/pyconfig.h ${TP}/python${PYVER}/include/python${PYDOT}${PYMODE}/
    cp -vf ../cpython-bpo-30386/Android/build/python-native/libpython${PYDOT}${PYMODE}.a  ${TP}/python${PYVER}/lib/

    TP_PYTHON="--use-python --python-incdir=${TP}/python${PYVER}/include --python-libdir=${TP}/python${PYVER}/lib"

    if [ -d host ]
    then
        echo "
        * Host tools found
    "
    else

        $PYTHON makepanda/makepanda.py --everything --threads 2 $OPT_COMMON $TP_PYTHON
        mv built host
    fi

    cp -vf ../cpython-bpo-30386/Android/build/python${PYDOT}-android-${ANDROID_API}-${ANDROID_ARCH}/pyconfig.h ${TP}/python${PYVER}/include/python${PYDOT}${PYMODE}/
    export LD_LIBRARY_PATH=$(pwd)/host/lib
    export PATH=$(pwd)/host/bin:$PATH

    echo "
        * interrogate is $(which interrogate)
    "

    rm -vf ${TP}/python${PYVER}/lib/libpython${PYDOT}${PYMODE}.a
    cp -vf ../cpython-bpo-30386/Android/build/python${PYDOT}-android-${ANDROID_API}-${ANDROID_ARCH}/libpython${PYDOT}${PYMODE}.so ${TP}/python${PYVER}/lib/
    rm -vf ${TP}/python${PYVER}/include/python${PYDOT}
    ln -sf ${TP}/python${PYVER}/include/python${PYDOT}${PYMODE} ${TP}/python${PYVER}/include/python${PYDOT}

    cmd="$PYTHON makepanda/makepanda.py $OPT_COMMON $OPT_ANDROID $TP_PYTHON"
    echo $cmd
    $cmd
else 
    echo "FATAL: Can't find static python $PYTHON"
fi

echo "Installing to $DEV_TARGET"
cd ${ROOT}

mkdir -p "$DEV_TARGET/lib-${ANDROID_ARCH}/"
mkdir -p "$DEV_TARGET/usr/lib-${ANDROID_ARCH}/panda3d/"

if [ -f panda3d/built/lib/libpython3.7m.so ]
then 
    mv -vf panda3d/built/lib/libpython3.7m.so "$DEV_TARGET/lib-${ANDROID_ARCH}/"
fi

PY_PANDA3D="$DEV_TARGET/usr/lib/python${PYDOT}/site-packages/panda3d"
mkdir -p $PY_PANDA3D

if touch $PY_PANDA3D/__init__.py
then
    cat > $PY_PANDA3D/__init__.py <<END
import sys
from ctypes import CDLL
LIBS = """
libgnustl_shared.so
libp3dtool.so
libp3dtoolconfig.so
libpandaexpress.so
libpanda.so
libp3direct.so
libp3dcparse.so
libpandaphysics.so
libmultify.so
libp3framework.so
libpzip.so
libpandafx.so
libp3interrogatedb.so
libinterrogate.so
libinterrogate_module.so
libpunzip.so
libp3android.so
libpandaskel.so
libparse_file.so
libpandagles.so
libpandaai.so
libp3vision.so
libpandaegg.so
libtest_interrogate.so
""".strip()

DLLS = list( map(str.strip, LIBS.split('\n') ) )

for lpass in (3,2,1):
    for dll in DLLS:
        try:
            CDLL( "$DEV_APPDIR/usr/lib-$ANDROID_ARCH/panda3d/%s" % dll )
        except Exception as e:
            print(lpass,dll,e,file=sys.stderr)
END

    if [ -d panda3d/built/libs ]
    then
        # first move python lib
        for pylib in $(find panda3d/built/libs/*/*cpython*.so)
        do
            mv -vf $pylib $PY_PANDA3D/$(basename $pylib|cut -f1 -d.).so
        done
        
        # then panda
        for pandalib in $(find panda3d/built/libs/*/lib*.so)
        do
            mv -vf $pandalib $DEV_TARGET/usr/lib-$ANDROID_ARCH/panda3d/
        done
        rmdir  panda3d/built/libs/* panda3d/built/libs
    fi
            
    echo "
    
    Installed in $DEV_APPDIR via $DEV_TARGET
    
"   

else
    echo "PY_PANDA3D: wrong target path '$PY_PANDA3D'"
fi   











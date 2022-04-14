# pydk : Android generic ( 4.4/32 api19 , 5+/64 api21) + emscripten tip of tree/incoming

PyDK (Python Developpement Kit) allows you to efforless build CPython , Panda3D and gives you prebuilt libraries
ready to use pip modules and runtime loaders.

for use on :

- Android starting with API19(kitkat 4.4)

- Web browsers, Electron.

There's two gitter channels for support and general interest in supporting the platforms for cpython:
for Android:
https://gitter.im/Wasm-Python/pydk
Browser:
https://gitter.im/Wasm-Python/community

embedding is one part of the process and packaging is another : embedding is not specific to PyDK
You are welcome to discuss how to improve Python embedding on mobile/web/wasi no matter which packager you prefer (Panda3D/Beeware/Kivy).

PyDK packaging ability is minimal, just enough to run tests.
The main goal is and will remain building interpreter + extensions and support libs.

PyDK was made to make Python core adjustments easier
Its next big step is to package only testsuites and provides local wheels.


# pydk : Android generic ( 4.4/32 api19 , 5+/64 api21)


```
Requirements:
    * C-Python ® 3.6+ installed
    * clang/clang++ 8+ full build env <- this is very important.
    * git, wget, patch
    * android-sdk + android-ndk 21 or 23
    * all Panda3D requirements
    * about 16 GiB free disk space
    * 4 GiB MEM-SWAP for panda3d linking

( for debian/ubuntu/mint maybe just have a look at the .github/workflows/blank.yml CI apt-get lines )

```

Clone this repo and go into folder pydk

add sdk as "android-sdk" and ndk as "android-sdk/ndk-bundle" (ndk21 or 23) in the folder, symlink is ok too


Tehen launch :


ARCHITECTURES="armeabi-v7a arm64-v8a x86 x86_64" ./pydk-all.sh

use PYMINOR/PYMICRO to pick the CPython version ( look in sources.* for what's available as i'm often dragging behind )


To launch step by step use instead for eg CPython 3.7.13 :


STEP=true ARCHITECTURES="armeabi-v7a arm64-v8a x86 x86_64" PYMINOR=7 PYMICRO=13 ./pydk-all.sh

```
sources used:
  +  bzip2 from : https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
  +  lzma from : https://tukaani.org/xz/xz-5.2.4.tar.bz2
  +  libffi from : http://sourceware.org/pub/libffi/libffi-3.3.tar.gz + Brion Vibber patches
  +  sqlite3 from : https://github.com/azadkuh/sqlite-amalgamation.git
  +  openssl from : https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
  +  python3 from : https://github.com/python/cpython/archive/v${PYVER}.tar.gz
  +  freetype2 from : https://download.savannah.gnu.org/releases/freetype/freetype-2.10.0.tar.bz2
  +  harfbuzz from : https://github.com/harfbuzz/harfbuzz.git
  +  ft2_hb from : https://download.savannah.gnu.org/releases/freetype/freetype-2.10.0.tar.bz2
  +  bullet3 from : https://github.com/bulletphysics/bullet3/archive/2.89.tar.gz
  +  openal from : https://github.com/pmp-p/pydk-openal-soft.git
  +  ogg from : http://downloads.xiph.org/releases/ogg/libogg-1.3.4.tar.xz
  +  vorbis from : https://github.com/xiph/vorbis.git
  +  panda3d from : GIT + android patches + webgl port branch merged
  +  SDL2/SDL2_image/SDL2_mixer/SDL2_ttf stable from libsdl.org
```

NOTE: now has limited pip support and will detect  your ./projects/*/requirements.txt.
and will do its best to package them for an android apk.

You can also use pip-cross via the various venv shell.[ARCHITECTURE].sh (to be sourced)
( when in the shell you have python3-xxxxxx and pip3-xxxxxx cross compiler scripts )



NOTE: an emscripten android project emulation is actually brewing.
it allows deploying your apk untouched in browsers.


Beerware : [![PayPayl](https://img.shields.io/badge/Paypal-Me-yellow.svg)](http://paypal.me/pmpp)


[![la rache](https://www.la-rache.com/img/kro.jpg)](https://www.la-rache.com)



A simple python created button calling Panda3D engine to render on a python created View :

![p3d1](https://raw.githubusercontent.com/pmp-p/pydk/master/docs/Panda3D/pandapk-step1.png)(https://www.panda3d.org)

![p3d2](https://raw.githubusercontent.com/pmp-p/pydk/master/docs/Panda3D/pandapk-step2.png)(https://www.panda3d.org)



# pydk : Emscripten

Requirements : GNU/Linux os , internet connection.

ARCHITECTURES="wasm" ./pydk-all.sh



demo :  https://pmp-p.github.io/panda3d-next/py3/


![p3d3](https://raw.githubusercontent.com/pmp-p/pydk/master/docs/Panda3D/pandapk-step3.png)(https://pmp-p.github.io/panda3d-next/py3/)






ref:

https://pythondev.readthedocs.io/android.html

https://pythondev.readthedocs.io/wasm.html

--


PyDK (Python Developpement Kit) allows you to efforless build CPython , Panda3D and gives you prebuilt libraries
ready to use pip modules and runtime loaders.

for use on :

- Android starting with API19(kitkat 4.4)

- Web browsers and Electron.



# pydk : Android generic ( 4.4/32 api19 , 5+/64 api21) + emscripten tip of tree/incoming


```
Requirements:
    * python 3.7/8 installed
    * clang/clang++ 8+ full build env
    * android-sdk + android-ndk
    * about 16 GiB free disk space
    * 4 GiB MEM-SWAP for panda3d linking
```

clone this repo and go into folder pydk
add sdk as "android-sdk" and ndk as "android-sdk/ndk-bundle" (ndk20) in the folder
launch

ARCHITECTURES="armeabi-v7a arm64-v8a x86 x86_64" ./pydk-all.sh

```
sources used:
  +  bzip2 from : https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
  +  lzma from : https://tukaani.org/xz/xz-5.2.4.tar.bz2
  +  libffi from : https://github.com/libffi/libffi/releases/download/v3.3-rc0/libffi-3.3-rc0.tar.gz
  +  sqlite3 from : https://github.com/azadkuh/sqlite-amalgamation.git
  +  openssl from : https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
  +  python3 from : https://github.com/python/cpython/archive/v${PYVER}.tar.gz
  +  freetype2 from : https://download.savannah.gnu.org/releases/freetype/freetype-2.10.0.tar.bz2
  +  harfbuzz from : https://github.com/harfbuzz/harfbuzz.git
  +  ft2_hb from : https://download.savannah.gnu.org/releases/freetype/freetype-2.10.0.tar.bz2
  +  bullet3 from : https://github.com/bulletphysics/bullet3.git
  +  openal from :   GIT_REPOSITORY https://github.com/pmp-p/pydk-openal-soft.git
  +  ogg from : http://downloads.xiph.org/releases/ogg/libogg-1.3.4.tar.xz
  +  vorbis from : https://github.com/xiph/vorbis.git
  +  panda3d from : https://github.com/panda3d/panda3d/archive/cmake.zip
```

NOTE: now has limited pip support and will detect  your ./projects/*/requirements.txt.
and will do its best to package them for an android apk.

NOTE: an emscripten android project emulation is expected.
it will allow deploying your apk untouched in browsers.


Beerware : [![PayPayl](https://img.shields.io/badge/Paypal-Me-yellow.svg)](http://paypal.me/pmpp)


[![la rache](https://www.la-rache.com/img/kro.jpg)](https://www.la-rache.com)



A simple python created button calling Panda3D engine to render on a python created View :

[![p3d1](https://raw.githubusercontent.com/pmp-p/pydk/master/docs/Panda3D/pandapk-step1.png)(https://www.panda3d.org)

[![p3d2](https://raw.githubusercontent.com/pmp-p/pydk/master/docs/Panda3D/pandapk-step2.png)(https://www.panda3d.org)



# pydk : Emscripten

Requirements : GNU/Linux os , internet connection.

ARCHITECTURES="wasm" ./pydk-all.sh



demo :  https://pmp-p.github.io/panda3d-next/py3/


[![p3d3](https://raw.githubusercontent.com/pmp-p/pydk/master/docs/Panda3D/pandapk-step3.png)(https://www.panda3d.org)










# pydk : H3Droid ( and most kitkat devices )
# deprecated, some assembly required....

While helping to cross-compile, the script also try to prepare a onboard sdk (armv7 currently).

note that apk demo is a full python3.7 and does not require root at all.

You only need root for building, not using.

On the other hand the onboard sdk - called u.root - will need it or at least a root adb shell ( though preferred way is ssh via dropbear)

Requirements : GNU/Linux os , NDK 14b/16b and SDK

Note: /dev/pts support may vary on non-h3droid devices, sudo is only supported on h3droid.


Usage for cross compile :
--

i like "/data/data/u.root.kit" path so it fits in the devices layout



```
sudo mkdir /data

sudo chown $(whoami) /data

bash ./frankenbuild.sh /data/data/u.root.kit 192.168.0.xxx*
```

*The ip addr is for targeting an adb networked device such as an h3droid board, ( no IP would mean use classic adb over usb : actually untested).


After installation, running  ```.  /data/data/sdk.env```  will enter the build zone.

It behaves like a virtualenv : your prompt will reflect that fact.

In the build folder you'll find various .build files which are recipes to download / patch / build some software for your presets.


The onboard sdk rely on an elf loader / qemu trick around debian jessie and the NDK, enough to make setuptools and pip work, so i did not push files.


If you need more info or have use for onboard sdk contact me via #H3Droid on freenode irc.

Running test apk on H3Droid :

[![PayPayl](https://raw.githubusercontent.com/pmp-p/h3droid/sdk/usr/src/projects/b0.png)](http://paypal.me/pmpp)

EGL Terminal running Panda3D+LUI GLES 2.0  and Tilde VT100 editor at the same time ( H3droid 4.4.2 / Orange PI PC Mali400 MP2 )

* [Panda3D](https://github.com/panda3d/panda3d) *the* python 3d engine  #panda3d on freenode

* [Tilde](https://github.com/gphalkes/tilde) The Tilde Text Editor  #tilde on freenode

* [H3droid](https://h3droid.com) An image developed specifically to work on Allwinner H3 based devices #h3droid on freenode

--



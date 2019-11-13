# pydk : Android generic ( 4.4/32 api19 , 5+/64 api21)

Requirements: python 3.7/8 installed, clang/clang++ 8+ full build env
clone this repo, add android-sdk and android-sdk/ndk-bundle (ndk20) in the folder
launch ./pydk-android-all.sh



# pydk : H3Droid ( and most kitkat devices )

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



# pydk : Emscripten

Requirements : GNU/Linux os , emsdk portable incoming branch

--

```
sudo mkdir /data

sudo chown $(whoami) /data

bash ./emsdkbuild.sh /data/data/u.root.web /path/to/emsdk_set_env.sh
```

After installation, running  ```.  /data/data/u.root.web/sdk.em.env```  will enter the build zone.

It behaves like a virtualenv : your prompt will reflect that fact.

In the build folder you'll find various .build files which are recipes to download / patch / build some software for your presets.

[demo, basic python with emscripten loader](http://pmpp.pagesperso-orange.fr/python_em.html)

--

[demo, vt100 python + nanotui3](http://pmpp.pagesperso-orange.fr/python_vt100.html)

* [xtermjs](https://github.com/xtermjs/xtermjs.org)

--

[demo, xterm.js python + nanotui3 + panda3d](http://pmpp.pagesperso-orange.fr/python_em.html)

* [Panda3D WebGL port](https://github.com/panda3d/panda3d/tree/webgl-port)



--



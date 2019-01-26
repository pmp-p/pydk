## emscripten ( emsdk portable )
---

https://kripken.github.io/emscripten-site/docs/getting_started/downloads.html
```
# Get the emsdk repo ( once )

git clone https://github.com/juj/emsdk.git

# Enter that directory

cd emsdk

# Fetch the latest version of the emsdk (not needed the first time you clone)
git pull

# Download and install the latest SDK tools.

./emsdk install --enable-wasm latest

# Make the "latest" SDK "active" for the current user. (writes ~/.emscripten file)

./emsdk activate --embedded latest

# get your emsdk_env.sh config path, and write it down
# will call it EMSDK from now on

echo $(pwd)/emsdk_env.sh
export EMSDK=$(pwd)/emsdk_env.sh


# go up
cd ..
```

## setting up build env
---

```
# get the unconfigured env

git clone https://github.com/pmp-p/pydk.git

# set it up in a directory of your choice
# can be anywhere you can write files.
# on android i use /data/data/u.root.web which is writeable

sudo mkdir /data
sudo chown $(whoami) /data

# configure it for that path and tell it where is emsdk_env.sh

bash ./emsdkbuild.sh /data/data/u.root.web $EMSDK
```


## using
---

. /data/data/u.root.web/sdk.em.env

./Python-3.7.1.build asm

./panda3d-webgl-port.build asm

./prebuilt.build asm




## history

Thanks to 

https://github.com/rdb / https://github.com/Maratyszcza / https://github.com/iodide-project/pyodide / https://github.com/dgym/cpython-emscripten

Why not brython ?

https://github.com/brython-dev/brython/issues/275

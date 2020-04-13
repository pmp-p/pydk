
#export JAVA_HOME=/opt/sdk/jdk
#export CROSS_COMPILE=armv7a-linux-androideabi
#. ${ROOT}/${ANDROID_ABI}.sh
#export _PYTHON_SYSCONFIGDATA_NAME=_sysconfigdata__android_armv7a-linux-androideabi
#export __ANDROID__=1



cross_pip_host_cmake () {
    cat >> CMakeLists.txt <<END
#${unit}

if(0)
ExternalProject_Add(
    ${unit}
    ${cross_pip_URL}
    ${cross_pip_HASH}

    DOWNLOAD_NO_PROGRESS ${CI}

    CONFIGURE_COMMAND sh -c "echo 1>&1;echo external.configure ${unit} 1>&2"
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)
endif(0)

END
}

cross_pip_patch () {
    echo
}

cross_pip_build () {
    echo
}

cross_pip_crosscompile () {
    # == a shell for one arch, with a ready to use cmake cross compile command
    cat > ${ROOT}/bin/python3-${ANDROID_NDK_ABI_NAME} <<END
#!/bin/sh
. $ROOT/${ANDROID_NDK_ABI_NAME}.sh

#. ${ROOT}/bin/activate

export PKG_CONFIG_PATH=${APKUSR}/lib/pkgconfig

export PS1="[PyDK:$ANDROID_NDK_ABI_NAME] \w \$ "

export HOSTPYPATH=${HOST}/lib/python${PYMAJOR}.${PYMINOR}:${HOST}/lib/python${PYMAJOR}.${PYMINOR}/lib-dynload
export PYTHONPATH=${ORIGIN}/assets/python${PYMAJOR}.${PYMINOR}:${APKUSR}/lib/python${PYMAJOR}.${PYMINOR}:\$HOSTPYPATH:${PYDROID}/Lib
export _PYTHON_SYSCONFIGDATA_NAME=_sysconfigdata__android_${ARCH}-linux-${ABI}
export PYTHONHOME=${APKUSR}

${HOST}/bin/python3 -u -B "\$@"
END
    chmod +x ${ROOT}/bin/python3-${ANDROID_NDK_ABI_NAME}

    . ${ORIGIN}/cross-modules.sh
}

# pypiserver - minimal PyPI server for use with pip/easy_install https://pypi.org/project/pypiserver/
# Upload source distributions of your requirements to your PyPI server. https://pypi.org/project/pypi-uploader/
# pip2pi builds a PyPI-compatible package repository from pip requirements. https://github.com/wolever/pip2pi
#
# Guide for how to create a (minimal) private PyPI repo, just using Apache with directory autoindex, and pip with an extra index URL.
# https://gist.github.com/Jaza/fcea493dd0ba6ebf09d3

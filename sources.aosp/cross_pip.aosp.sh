# https://packaging.python.org/guides/hosting-your-own-index/
# pypiserver - minimal PyPI server for use with pip/easy_inst
# all https://pypi.org/project/pypiserver/

# Upload source distributions of your requirements to your PyPI server. https://pypi.org/project/pypi-uploader/

# pip2pi builds a PyPI-compatible package repository from pip requirements. https://github.com/wolever/pip2pi

# Guide for how to create a (minimal) private PyPI repo, just using Apache with directory autoindex, and pip with an extra index URL.
# https://gist.github.com/Jaza/fcea493dd0ba6ebf09d3

# https://www.freecodecamp.org/news/how-to-use-github-as-a-pypi-server-1c3b0d07db2/




cross_pip_host_cmake () {
    cat >> CMakeLists.txt <<END
#${unit}

if(0)
ExternalProject_Add(
    ${unit}
    ${URL_cross_pip}
    ${HASH_cross_pip}

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
    cat > ${ROOT}/bin/python3-${ABI_NAME} <<END
#!/bin/bash
. ${HOST}/${ABI_NAME}.sh

#. ${ROOT}/bin/activate

export _PYTHON_HOST_PLATFORM=$HOST_PLATFORM

export PREFIX="${APKUSR}"

export PKG_CONFIG_PATH=${APKUSR}/lib/pkgconfig

export PS1="[PyDK:$ABI_NAME] \w \$ "

export PYTHONPYCACHEPREFIX=${PYTHONPYCACHEPREFIX}
export HOME="${APKUSR}"

rm "${APKUSR}/.local"
ln -s "${APKUSR}" "${APKUSR}/.local"

cat >$PYTHONPYCACHEPREFIX/.numpy-site.cfg <<NUMPY
[DEFAULT]
library_dirs = ${APKUSR}/lib
include_dirs = ${APKUSR}/include
NUMPY

export PYTHONPATH=\
${ORIGIN}/assets/python${PYMAJOR}.${PYMINOR}:\
${APKUSR}/lib/python${PYMAJOR}.${PYMINOR}:\
${HOST}/lib/python${PYMAJOR}.${PYMINOR}:\
${HOST}/lib/python${PYMAJOR}.${PYMINOR}/site-packages:\
${HOST}/lib/python${PYMAJOR}.${PYMINOR}/lib-dynload


export _PYTHON_SYSCONFIGDATA_NAME=_sysconfigdata__linux_${HOST_PLATFORM}
export PYTHONHOME=${APKUSR}

${HOST}/bin/python3 -u -B "\$@"

END

    cat > ${ROOT}/bin/pip3-${ABI_NAME} <<END
#!/bin/bash
MODE=\$1
shift
${ROOT}/bin/python3-${ABI_NAME} -m pip \$MODE --use-feature=2020-resolver --no-use-pep517 --no-binary :all: \$@
END

    chmod +x ${ROOT}/bin/python3-${ABI_NAME} ${ROOT}/bin/pip3-${ABI_NAME}
    . ${ORIGIN}/cross-modules.sh
}



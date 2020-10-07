#
# BUILD python is the python of venv => mainly used for cmake and pip downloads.
# HOST python is the python matching TARGET conditions but built for BUILD  => you can run it
# TARGET python is never used, and you cannot run it normally unless root on target device.
#

# https://bugs.python.org/issue28833 cross compilation of third-party extension modules


mkdir -p ${ORIGIN}/pydk-min/prebuilt/${ABI_NAME}

# put a copy into prebuilt for packaging support lib
/bin/cp -f ${APKUSR}/lib/lib*.so ${ORIGIN}/pydk-min/prebuilt/${ABI_NAME}/

# put the sysroot for projects building
# TODO: dedup  common + arch folder
mkdir -p ${ORIGIN}/pydk-min/${ENV}/apkroot-${ABI_NAME}/usr
/bin/cp -rf ${APKUSR}/include ${ORIGIN}/pydk-min/${ENV}/apkroot-${ABI_NAME}/usr


echo " * cross compiling third party modules"

cd ${BUILD_PREFIX}-${ABI_NAME}

mkdir -p pip-${ABI_NAME}

cd pip-${ABI_NAME}

export CROSSDIR=$(pwd)

#six
PREREQ="pip wheel"

${ROOT}/bin/pip3 download --dest ${CROSSDIR} --no-binary :all: setuptools ${PREREQ}

cd ${CROSSDIR}

unzip -q -o setuptools-*.zip && rm setuptools-*.zip

#tar xfz Cython-*.tar.gz && rm Cython-*.tar.gz


for mod in $PREREQ
do
    tar xfz ${mod}-*.tar.gz && rm ${mod}-*.tar.gz
done

for PKG in setuptools ${PREREQ}
do
    cd ${CROSSDIR}
    if cd ${PKG}-*
    then
        if ${ROOT}/bin/python3-${ABI_NAME} -c "import ${PKG};print(${PKG}.__file__)" |grep apkroot
        then
            echo "  * ${PKG} already ready for ${ABI_NAME}"
        else
            if ${ROOT}/bin/python3-${ABI_NAME} setup.py install
            then
                echo "  -> ${PKG} installed for ${ABI_NAME}"
            else
                echo "ERROR can't install ${PKG} from ${CROSSDIR}"
                exit 1
            fi
        fi
        cd ${CROSSDIR}
        rm -rf ./${PKG}-*
    else
        echo "ERROR can't find ${PKG}-* in ${CROSSDIR}"
        exit 1
    fi
done


for req in ${ORIGIN}/projects/*/requirements.txt
do
    if ${ROOT}/bin/python3-${ABI_NAME} -m pip install --no-use-pep517 --no-binary :all: -r $req
    then
        echo ok
    else
        echo "ERROR: pip install $req failed"
        #exit 1
        #read
    fi
done


# TODO: build/patch from sources pip packages here.
# ${ROOT}/bin/pip3 download --dest ${CROSSDIR} --no-binary :all: setuptools pip

mkdir -p ${ORIGIN}/assets/packages

for req in $(find ${APKUSR}/lib/python${PYMAJOR}.${PYMINOR}/site-packages/ -maxdepth 1  | egrep -v 'pth$|info$|egg$|txt$|/$')
do
    if find $req -type f|grep so$
    then
        echo " * can't add package yet : $(basename $req) not pure python"
    else
        echo " * adding pure-python pip package : $(basename $req)"
        cp -ru $req ${ORIGIN}/assets/packages/
    fi
done






if false
then

    for req in ${ORIGIN}/projects/*/requirements-jni.txt
    do
        if $CROSSPIP -r $req
        then
            echo $req OK
        else
            echo "ERROR: failed to cross build [$req]"
        fi
    done


    ls ${BUILD_SRC}/pip


fi

cat > ${BUILD_PREFIX}-${ABI_NAME}/pip_lib.py  <<END
import os
import shutil

libdef = []
liblist = []

FOUND="""$(find ${APKUSR}/lib/python3.?|grep so$)""".split("\n")

PREBUILT="${ORIGIN}/pydk-min/prebuilt/${ABI_NAME}/"

PREFIX='/lib/python${PYMAJOR}.${PYMINOR}/'

NEEDED = 'libpython${PYMAJOR}.${PYMINOR}.so'

print(f"PREFIX = {PREFIX}")

# no multiarch
if 0:
    for libpath in FOUND:
        if libpath.find('lib-dynload/_testcapi.cpython-3'):
            SUFFIX = '.'+libpath.rsplit('.',2)[-2] + '.so'
            break
else:
    SUFFIX= ".so"
print(f"SUFFIX = {SUFFIX}")

for libpath in FOUND:
    folder, lib = libpath.rsplit('/',1)

    # module can be in "site-packages" "lib-dynload" or none of them
    modpath = libpath.rsplit(PREFIX,1)[-1]

    modpath = modpath.split('/')

    # make all modules relative to same base path
    if modpath[0] in ["site-packages","lib-dynload"]:
        modpath.pop(0)


    # get modname +  { .suffix  or .so }
    modname = modpath.pop()

    if modname.find(SUFFIX)>=0:
        modname = lib.rsplit(SUFFIX,1)[0]
    else:
        modname = lib.rsplit('.',1)[0]

    cmk_name = '_'.join(modpath) + '_' + modname
    lib = "lib" + '.'.join(modpath) + '.' + modname + SUFFIX

    print(f"    Module : {modpath} | {modname} => {lib}")

    libdef.append(f"""
add_library({cmk_name} SHARED IMPORTED )
set_target_properties({cmk_name} PROPERTIES IMPORTED_LOCATION \${{PREBUILT}}+{lib})
""")
    liblist.append(f'    {cmk_name}\n')

    os.makedirs(PREBUILT, exist_ok=True)
    shutil.copyfile(libpath,PREBUILT+lib)
    os.system(f"patchelf --set-soname {lib} {PREBUILT+lib}")
    if not os.popen(f"patchelf --print-needed {libpath}").read().count(NEEDED):
        print(f"#FIXME: python module {modpath} {modname} lacked dynamic ref to libpython !")
        os.system(f"patchelf --add-needed {NEEDED} {PREBUILT+lib}")

print(PREBUILT)


with open("${ORIGIN}/prebuilt/${ABI_NAME}.include","w") as file:
    print(f"""
add_library(jnilink SHARED jnilink.c)

{''.join(libdef)}

target_link_libraries(jnilink
{''.join(liblist)})
""",file=file)

END

${HOST}/bin/python3 -u -B ${BUILD_PREFIX}-${ABI_NAME}/pip_lib.py




















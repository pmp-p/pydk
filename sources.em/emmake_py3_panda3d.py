import sys, os

def grep(pattern,*filenames):
    import re
    multi = len(filenames)
    for filename in filenames:
        with open(filename, 'r') as file:
            while True:
                line = file.readline()
                if not line:break
                if len( re.findall(fr'{pattern}',line) ):
                    if multi:
                        yield f'{filename}:{line}'
                    else:
                        yield line

def check_dir(dn):
    dn = dn.replace('\\','/').replace('//','/')
    if not os.path.isdir(dn):
        print("could not find directory '%s'"%dn)
        raise SystemExit
    return dn

def check_file(dn):
    dn = dn.replace('\\','/').replace('//','/')
    if not os.path.isfile(dn):
        print("could not find file '%s'"%dn)
        raise SystemExit
    return dn


RAM = 400 # MB ram you'll need, 950 seems chrome v8 hard limit , 500 MB on mobile
FIXED = 0 # ALLOW_MEMORY_GROWTH=

"""

To enable OpenGL ES 2.0 emulation, specify the emcc option -s FULL_ES2=1 when linking the final executable (.js/.html)
of the project.

To enable OpenGL ES 3.0 emulation, specify the emcc option -s FULL_ES3=1 when linking the final executable (.js/.html)
of the project. This adds emulation for mapping memory blocks to client side memory.

The flags -s FULL_ES2=1 -s FULL_ES3=1 are orthogonal, so either one or both can be specified to emulate different features.


Optimization settings
In this mode (-s LEGACY_GL_EMULATION=1), there are a few extra flags that can be used to tune the performance of the GL emulation layer:

-s GL_UNSAFE_OPTS=1 attempts to skip redundant GL work and cleanup.
This optimization is unsafe, so is not enabled by default.

-s GL_FFP_ONLY=1 tells the GL emulation layer that your code will not use the programmable pipeline/shaders at all.
This allows the GL emulation code to perform extra optimizations when it knows that it is safe to do so.
Add the Module.GL_MAX_TEXTURE_IMAGE_UNITS integer to your shell .html file to signal
the maximum number of texture units used by the code.

This ensures that the GL emulation layer does not waste clock cycles iterating over unused texture units
when examining which Fixed Function Pipeline (FFP) emulation shader to run.

----------------------------------------------

Can I use multiple Emscripten-compiled programs on one Web page?

But by putting each module in a function scope, that problem is avoided.
Emscripten even has a compile flag for this, MODULARIZE, useful in conjunction with EXPORT_NAME (details in settings.js).




"""


#freeze plugbase ?
friz = False


SDK="/data/data/build.em"

EMBUILT  = check_dir( f'{SDK}/panda3d-webgl-port/built' )

INC_P3D = check_dir( f'{EMBUILT}/include' )
LIB_P3D = check_dir( f'{EMBUILT}/lib' )


#../cpython-bpo-30386.em/')

#TP = check_dir( '../thirdparty/emscripten-libs')
#third_parties='openssl/lib/libssl.a openssl/lib/libcrypto.a'

PYTHON_VER = sys.version[:3]

INC_PY = check_dir( f"{SDK}/cpython-bpo-30386.em/include/python{PYTHON_VER}" )

print(f"PYTHON_VER:{PYTHON_VER} -I{INC_PY}")

if sys.argv[-1] is sys.argv[0]:
    print("usage: %s main_code.cpp"% sys.argv[0])
    raise SystemExit

SOURCE = sys.argv[-1]

#dev
TARGET = SOURCE.rsplit('_em.',1)[0]+'.html'


EM_USE = ["-s USE_ZLIB=1","-s USE_WEBGL2=1"]

BC_P3D = []
BC_PY = []

EM_FS = ""
EM_FS = f"{EM_FS} --preload-file ../stdlib@lib" # "
EM_FS = f"{EM_FS} --preload-file /Volumes/Roaming/lib/xpy@lib/xpy"
EM_FS = f"{EM_FS} --preload-file /Volumes/Roaming/lib/nanotui3@lib/nanotui3"
EM_FS = f"{EM_FS} --preload-file test"
EM_FS = f"{EM_FS} --preload-file p3d_test.py"


#panda stdlib and panda flags
if list(grep("#define PANDA3D 1",SOURCE)):
    print("\t+ panda3d") # pandabullet

    for use in 'WEBGL2 OGG LIBPNG FREETYPE VORBIS'.split(' '):
        EM_USE.append(f'-s USE_{use}=1')

    EM_FS= f"{EM_FS} --preload-file ../stdlib.panda3d@lib"

#    for bc in 'panda pandaexpress p3webgldisplay p3dtoolconfig p3dtool'.split(' '):
#        BC_P3D.append( check_file( f"{EMBUILT}/lib/lib{bc}.bc" ) )
#
#
#    if 0:
#        for bc in 'core direct'.split(' '):
#            BC_PY.append( check_file( f"{EMBUILT}/panda3d/{bc}.bc" ) )
#
#
#        for bc in 'p3interrogatedb p3direct pandabullet'.split(' '):
#            BC_P3D.append( check_file( f"{EMBUILT}/lib/lib{bc}.bc" ) )
#
#        for bc in 'interrogatedb core direct'.split(' '):
#            BC_PY.append( check_file( f"{EMBUILT}/panda3d/{bc}.bc" ) )


else:
    print("\t- panda3d")

LIB_PY = "" #check_file( f"../cpython-bpo-30386.em/lib/libpython{PYTHON_VER}.a" )


#optionnal
#P3DBC += " lib/lib.bc panda3d/egg.so"
#P3DBC += " panda3d/lui.bc"
#P3DBC += " lib/libp3openal_audio.bc"

"""
https://github.com/kripken/emscripten/blob/4ae305542c80f31b06c5e8325c63ade2bb4a3f33/tests/test_browser.py#L1227

var xmlhttp=new XMLHttpRequest();
xmlhttp.open("GET","data.dat",false);
xmlhttp.setRequestHeader("Range", "bytes=100-200");
xmlhttp.send();
console.info(xmlhttp); //--> returns only the partial content
"""

#EM_FN=["_PyRun_SimpleString","Pointer_stringify"]

os.environ['EMCC_FORCE_STDLIBS']= '1'  #mandatory for C++ libs !

os.environ['NODE_OPTIONS']= "--max_old_space_size=4096"


EM_FLAGS=[]
for emf in [
    'TOTAL_MEMORY=512MB', # 768MB
    'ALLOW_MEMORY_GROWTH=0',
    'TOTAL_STACK=10485760', #12582912 10485760 14680064
    'NO_EXIT_RUNTIME=1',
    'FORCE_FILESYSTEM=1',
#    'EMULATE_FUNCTION_POINTER_CASTS=1', #only for libpython
    ]:
    EM_FLAGS.append(f'-s {emf}')

EM_EXP=[]
for emf in [
    'WARN_ON_UNDEFINED_SYMBOLS=0',
    'INLINING_LIMIT=50',
    'OUTLINING_LIMIT=50000',
    'FULL_ES2=1',
    'FULL_ES3=1',
#    'LEGACY_GL_EMULATION=1',
    '\'EXTRA_EXPORTED_RUNTIME_METHODS=["loadDynamicLibrary"]\'',
    'MAIN_MODULE=1',
    ]:
    EM_EXP.append(f'-s {emf}')


#FIXME: use grep SAFE_HEAP in lzma libs to detect debug mode
if 1:
    #release
    EM_C = "em++ -std=c++11 -O3 -fno-exceptions"
    #EM_C = f"{EM_C} -s AGGRESSIVE_VARIABLE_ELIMINATION=1 -s ELIMINATE_DUPLICATE_FUNCTIONS=1"
    EM_C = f"{EM_C} -s LZ4=1 -s ASM_JS=1"
    EM_C = f"{EM_C} -s DEMANGLE_SUPPORT=0 -s DISABLE_EXCEPTION_CATCHING=1 -s ASSERTIONS=1"
else:
#debug quick
    EM_C = "em++ -std=c++11 -O2 -g0 -fno-exceptions -s SAFE_HEAP=1 --profiling-funcs"
    EM_C = f"{EM_C} -s DEMANGLE_SUPPORT=1 -s DISABLE_EXCEPTION_CATCHING=0 -s ASSERTIONS=2"

EM_EXP = ' '.join(EM_EXP)
EM_FLAGS = ' '.join(EM_FLAGS)
EM_USE = ' '.join(EM_USE)

EM_INC  = f"-I{INC_P3D} -I{INC_PY}"
EM_LIBS = f"-L/usr/lib -L{LIB_P3D} {LIB_PY} %s %s -lopenal" % ( ' '.join( BC_P3D ) , ' '.join(BC_PY) )

#

print()

build = f"{EM_C} {EM_FLAGS} {EM_EXP} {EM_USE} {EM_FS} {EM_INC} -o {TARGET} {SOURCE} {EM_LIBS}"

print(build)

os.system(build)

#
#
#warning: unresolved symbol: epoll_ctl
#warning: unresolved symbol: posix_spawn_file_actions_destroy
#warning: unresolved symbol: posix_spawn_file_actions_adddup2
#warning: unresolved symbol: epoll_create
#warning: unresolved symbol: posix_spawn_file_actions_init
#warning: unresolved symbol: epoll_wait
#


"""
libgnustl_shared.so

#libogg.so
#libvorbisfile.so
#libvorbis.so
#libfreetype.so
#libharfbuzz.so
#libopenal.so

libp3dtool.so
libp3dtoolconfig.so
libpandaexpress.so
libpanda.so

#libp3openal_audio.so
#libp3direct.so
#libp3dcparse.so
#libpandaphysics.so
#libmultify.so
#libp3framework.so
#libpzip.so
#libpandafx.so
#libp3interrogatedb.so
#libinterrogate.so
#libinterrogate_module.so
#libpunzip.so

libp3android.so

#libpandaskel.so
#libpandabullet.so
#libparse_file.so
#libpandagles2.so
#libpandaai.so
#libp3vision.so
#libpandaegg.so
#libtest_interrogate.so
""".strip()


# tar -C ../cpython-bpo-30386.em -cf - --files-from lib_files | tar -C usr -xf -


"""
lib/python3.7/__future__.py
lib/python3.7/asyncio
lib/python3.7/asynchat.py
lib/python3.7/asyncore.py
lib/python3.7/concurrent
lib/python3.7/logging
lib/python3.7/string.py
lib/python3.7/queue.py
lib/python3.7/multiprocessing
lib/python3.7/signal.py
lib/python3.7/pickle.py
lib/python3.7/struct.py
lib/python3.7/socketserver.py
lib/python3.7/selectors.py
lib/python3.7/_compat_pickle.py
lib/python3.7/tempfile.py
lib/python3.7/random.py
lib/python3.7/hashlib.py
lib/python3.7/bisect.py
lib/python3.7/subprocess.py
lib/python3.7/inspect.py
lib/python3.7/ast.py
lib/python3.7/dis.py
lib/python3.7/opcode.py
lib/python3.7/_dummy_thread.py
lib/python3.7/dummy_threading.py
lib/python3.7/_collections_abc.py
lib/python3.7/_compression.py
lib/python3.7/_sitebuiltins.py
lib/python3.7/_sysconfigdata__emscripten_x86_64-linux-gnu.py
lib/python3.7/_threading_local.py
lib/python3.7/_weakrefset.py
lib/python3.7/abc.py
lib/python3.7/codecs.py
lib/python3.7/collections/__init__.py
lib/python3.7/collections/abc.py
lib/python3.7/contextlib.py
lib/python3.7/copy.py
lib/python3.7/copyreg.py
lib/python3.7/dummy_threading.py
lib/python3.7/enum.py
lib/python3.7/encodings/__init__.py
lib/python3.7/encodings/aliases.py
lib/python3.7/encodings/cp437.py
lib/python3.7/encodings/latin_1.py
lib/python3.7/encodings/utf_8.py
lib/python3.7/fnmatch.py
lib/python3.7/functools.py
lib/python3.7/genericpath.py
lib/python3.7/glob.py
lib/python3.7/heapq.py
lib/python3.7/importlib/__init__.py
lib/python3.7/importlib/_bootstrap.py
lib/python3.7/importlib/_bootstrap_external.py
lib/python3.7/importlib/abc.py
lib/python3.7/importlib/machinery.py
lib/python3.7/importlib/util.py
lib/python3.7/io.py
lib/python3.7/keyword.py
lib/python3.7/linecache.py
lib/python3.7/operator.py
lib/python3.7/os.py
lib/python3.7/pkgutil.py
lib/python3.7/posixpath.py
lib/python3.7/re.py
lib/python3.7/reprlib.py
lib/python3.7/runpy.py
lib/python3.7/shutil.py
lib/python3.7/site.py
lib/python3.7/sre_compile.py
lib/python3.7/sre_constants.py
lib/python3.7/sre_parse.py
lib/python3.7/stat.py
lib/python3.7/struct.py
lib/python3.7/sysconfig.py
lib/python3.7/tarfile.py
lib/python3.7/token.py
lib/python3.7/tokenize.py
lib/python3.7/traceback.py
lib/python3.7/types.py
lib/python3.7/warnings.py
lib/python3.7/weakref.py
lib/python3.7/zipfile.py
lib/python3.7/contextlib.py
lib/python3.7/configparser.py
lib/python3.7/encodings/ascii.py
lib/python3.7/bdb.py
lib/python3.7/locale.py
lib/python3.7/tty.py
lib/python3.7/textwrap.py
lib/python3.7/datetime.py
lib/python3.7/shlex.py
lib/python3.7/platform.py
lib/python3.7/difflib.py
lib/python3.7/imp.py
lib/python3.7/pydoc_data
lib/python3.7/pydoc.py
lib/python3.7/urllib
lib/python3.7/codeop.py
lib/python3.7/code.py
lib/python3.7/argparse.py
lib/python3.7/unittest
lib/python3.7/pprint.py
lib/python3.7/base64.py
"""

"""
ac_cv_func_getpgrp=no
ac_cv_func_setpgrp=no

ac_cv_func_getresuid=no
ac_cv_func_seteuid=no
ac_cv_func_setresuid=no
ac_cv_func_setreuid=no
ac_cv_func_setuid=no

ac_cv_func_sethostname=no


ac_cv_func_sigtimedwait=no
ac_cv_func_sigwait=no
ac_cv_func_sigwaitinfo=no

ac_cv_func_pthread_kill=no
ac_cv_func_pthread_sigmask=no
ac_cv_func_pthread_sigmask=no
ac_cv_func_pthread_getcpuclockid=no

ac_cv_func_sched_get_priority_max=no
ac_cv_func_sched_get_priority_min=no
ac_cv_func_sched_getaffinity=no
ac_cv_func_sched_getparam=no
ac_cv_func_sched_getscheduler=no
ac_cv_func_sched_rr_get_interval=no
ac_cv_func_sched_setaffinity=no
ac_cv_func_sched_setparam=no
ac_cv_func_sched_setscheduler=no
ac_cv_func_sem_timedwait=no
ac_cv_func_wcsftime=no
"""


"""
>>> import logging
>>> logging.NOTE = logging.INFO + 5
>>> logging.addLevelName(logging.INFO + 5, 'NOTE')
>>> class MyLogger(logging.getLoggerClass()):
...:    def note(self, msg, *args, **kwargs):
...:        self.log(logging.NOTE, msg, *args, **kwargs)
...:
>>> logging.setLoggerClass(MyLogger)

>>> logging.basicConfig(level=logging.INFO)
>>> logger.note("hello %s", "Guido")
NOTE:foo:hello Guido
"""































#

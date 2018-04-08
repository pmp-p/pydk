import sys, os

def check_dir(dn):
    dn = dn.replace('\\','/').replace('//','/')
    if not os.path.isdir(dn):
        print("could not find Directory '%s'"%dn)
        raise SystemExit
    return dn

def check_file(dn):
    dn = dn.replace('\\','/').replace('//','/')
    if not os.path.isfile(dn):
        print("could not find Directory '%s'"%dn)
        raise SystemExit
    return dn


RAM = 400 # MB ram you'll need, 950 seems chrome v8 hard limit , 500 MB on mobile
FIXED = 0 # ALLOW_MEMORY_GROWTH=



#freeze plugbase ?
friz = False


EMBUILT  = check_dir( '../panda3d-webgl-port/built' )

INC_P3D = check_dir( f'{EMBUILT}/include' )
LIB_P3D = check_dir( f'{EMBUILT}/lib' )


#../cpython-bpo-30386.em/')

#TP = check_dir( '../thirdparty/emscripten-libs')
#third_parties='openssl/lib/libssl.a openssl/lib/libcrypto.a'

PYTHON_VER = sys.version[:3]

INC_PY = check_dir( f"../cpython-bpo-30386.em/include/python{PYTHON_VER}" )

BC_P3D= []

#pandaegg
for bc in 'p3dtoolconfig p3webgldisplay p3framework p3dtool panda pandaexpress p3direct'.split(' '):
#for bc in 'p3dtool p3dtoolconfig p3framework pandaexpress p3webgldisplay p3interrogatedb panda p3direct pandabullet'.split(' '):
    BC_P3D.append( check_file( f"{EMBUILT}/lib/lib{bc}.bc" ) )

BC_PY=[]

LIB_PY = check_file( f"../cpython-bpo-30386.em/lib/libpython{PYTHON_VER}.a" )
#
#for bc in 'interrogatedb core direct bullet'.split(' '):
#    BC_PY.append( check_file( f"{EMBUILT}/panda3d/{bc}.bc" ) )




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

print(f"PYTHON_VER:{PYTHON_VER} -I{INC_PY}")

if sys.argv[-1] is sys.argv[0]:
    print("usage: %s main_code.cpp"% sys.argv[0])
    raise SystemExit

SOURCE = sys.argv[-1]

#dev
TARGET = SOURCE.rsplit('.',1)[0]+'.html'


#EM_LIBS = "-s USE_WEBGL2=1 -s USE_OGG=1 USE_BULLET=1 -s SDL=2",
EM_USE = []
for use in 'LIBPNG FREETYPE VORBIS ZLIB'.split(' '):
    EM_USE.append(f'-s USE_{use}=1')

EM_FN=["_PyRun_SimpleString","Pointer_stringify"]

EM_FLAGS=[]

#dist VERY slow !
#EMODE += " -s LZ4=1 -s ASM_JS=1 -s ELIMINATE_DUPLICATE_FUNCTIONS=1 -s INLINING_LIMIT=1"
#FULL_ES2=1

for emf in [
    'TOTAL_MEMORY=512MB',
    'NO_EXIT_RUNTIME=1',
    'FORCE_FILESYSTEM=1',
    'EMULATE_FUNCTION_POINTER_CASTS=1',
    ]:
    EM_FLAGS.append(f'-s {emf}')

EM_EXP=[]
for emf in [
#    'ALLOW_MEMORY_GROWTH=1',
#    'INLINING_LIMIT=1',
#    'OUTLINING_LIMIT=20000',
#    'ELIMINATE_DUPLICATE_FUNCTIONS=1',
#    'AGGRESSIVE_VARIABLE_ELIMINATION=1',
#    'LEGACY_GL_EMULATION=1',
#    'FULL_ES2=1',
    ]:
    EM_EXP.append(f'-s {emf}')


EM_C = "em++ -std=c++11 -Os -O3 -g0 -s AGGRESSIVE_VARIABLE_ELIMINATION=1 -s WARN_ON_UNDEFINED_SYMBOLS=1"

# O2    3min
# O0    50sec
if 0:
    EM_C = f"{EM_C}" #--closure 1
    EM_C = f"{EM_C} -s LZ4=1 -s ASM_JS=1 -s DEMANGLE_SUPPORT=0 -s DISABLE_EXCEPTION_CATCHING=1 -s ASSERTIONS=0"

else:
#debug
    # -Os -O0 --profiling
    # -s ERROR_ON_UNDEFINED_SYMBOLS=1
    EM_C = f"{EM_C} -s ALLOW_MEMORY_GROWTH=0 -s DEMANGLE_SUPPORT=1 -s DISABLE_EXCEPTION_CATCHING=0 -s ASSERTIONS=2"

EM_FN = "-s \"EXPORTED_FUNCTIONS=['%s']\"" % "','".join(EM_FN)
EM_EXP = ' '.join(EM_EXP)
EM_FS = "--preload-file lib --preload-file models"
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



# tar -C ../cpython-bpo-30386.em -cf - --files-from lib_files | tar -C usr -xf -


"""
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
"""


























































#

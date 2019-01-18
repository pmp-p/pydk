
import shutil
import sys
import multiprocessing
from os import chdir, _exit
from os.path import isdir, isfile
from panda3d.core import PandaSystem

from .common import get_output_dir, try_makedir, fatal_error, is_windows
from .common import is_linux, join_abs, get_panda_lib_path, is_64_bit
from .common import try_execute, get_script_dir, get_panda_mscv_version
from .common import have_eigen, have_bullet, have_freetype, print_error
from .common import is_macos, is_freebsd

"""
UNUSED
    CMAKE_MULTILIB_PATH
    LOCAL_PANDA_PATH
    PANDA_LDFLAGS
    PANDA_LIBRARY_DIRS
    STDFLOAT_DOUBLE

"""


import os
from collections import namedtuple
def dict_as_nt(obj=None,**kw):
    if obj is None:
        obj = kw
    kw.pop('_',None)
    if isinstance(obj, dict):
        for key, value in obj.items():
            obj[key] = dict_as_nt(value)
        return namedtuple('GenericDict', obj.keys())(**obj)
    elif isinstance(obj, list):
        return [dict_as_nt(item) for item in obj]
    else:
        return obj



def make_output_dir(clean=False):
    """ Creates the output directory and sets the CWD into that directory. If
    clean is True, the output dir will be cleaned up. """
    output_dir = get_output_dir()

    # Cleanup output directory in case clean is specified
    if isdir(output_dir) and clean:
        print("Cleaning up output directory ..")
        shutil.rmtree(output_dir)

    try_makedir(output_dir)
    if not isdir(output_dir):
        fatal_error("Could not create output directory at:", output_dir)
    chdir(output_dir)


def handle_cmake_error(output):
    """ Improves the cmake output messages """
    print_error("\n\n\n")
    print_error("-" * 60)
    print_error("\nCMake Error:")

    if "Re-run cmake with a different source directory." in output:
        print_error("You moved the project folder, please add ' --clean' to the command line.")

    elif "No CMAKE_CXX_COMPILER could be found." in output or "No CMAKE_C_COMPILER could be found." in output:
        print_error("Could not find the required compiler!")
        if is_windows():
            print_error("\nPlease make sure you installed the following compiler:")
            bitness = "64 bit" if is_64_bit() else ""
            print_error(get_panda_mscv_version().cmake_str, bitness)
        else:
            print_error("The required compiler is:", PandaSystem.get_compiler())


    print_error("\n")
    print_error("-" * 60)
    print_error("\n\n\n")
    exit(-1)


def run_cmake(config, args):
    """ Runs cmake in the output dir """

    configuration = "Release"
    if config["generate_pdb"].lower() in ["1", "true", "yes", "y"]:
        configuration = "RelWithDebInfo"

    cmake_args = ["-DCMAKE_BUILD_TYPE=" + configuration]
    cmake_args += ["-DPYTHON_EXECUTABLE:STRING=" + sys.executable]
    cmake_args += ["-DPROJECT_NAME:STRING=" + config["module_name"]]

    lib_prefix = "lib" if is_windows() else ""

    # Check for the right interrogate lib
    if PandaSystem.get_major_version() > 1 or PandaSystem.get_minor_version() > 9:
        cmake_args += ["-DINTERROGATE_LIB:STRING=" + lib_prefix + "p3interrogatedb"]
    else:

        # Buildbot versions do not have the core lib, instead try using libpanda
        if not isfile(join_abs(get_panda_lib_path(), "core.lib")):
            cmake_args += ["-DINTERROGATE_LIB:STRING=" + lib_prefix + "panda"]
        else:
            cmake_args += ["-DINTERROGATE_LIB:STRING=core"]

    if is_windows():
        # Specify 64-bit compiler when using a 64 bit panda sdk build
        bit_suffix = " Win64" if is_64_bit() else ""
        cmake_args += ["-G" + get_panda_mscv_version().cmake_str + bit_suffix]
    elif is_macos():
        # Panda is 64-bit only on macOS.
        cmake_args += ["-DCMAKE_CL_64:STRING=1"]

    # Specify python version, once as integer, once seperated by a dot
    pyver = "{}{}".format(sys.version_info.major, sys.version_info.minor)
    pyver_dot = "{}.{}".format(sys.version_info.major, sys.version_info.minor)

    if is_windows():
        cmake_args += ["-DPYTHONVER:STRING=" + pyver]

    if is_linux() or is_freebsd():
        cmake_args += ["-DPYTHONVERDOT:STRING=" + pyver_dot]

    # Libraries
    def is_required(lib):
        if "require_lib_" + lib in config and config["require_lib_" + lib] in ["1", "yes", "y"]:
            return True
        return False

    """
    if is_required("eigen"):
        if not have_eigen():
            fatal_error("Your Panda3D build was not compiled with eigen support, but it is required!")
    """
    # Eigen is always included in 1.9.1 and up
    cmake_args += ["-DHAVE_LIB_EIGEN=FALSE"]

    if is_required("bullet"):
        if not have_bullet():
            fatal_error("Your Panda3D build was not compiled with bullet support, but it is required!")
        cmake_args += ["-DHAVE_LIB_BULLET=TRUE"]

    if is_required("freetype"):
        if not have_freetype():
             fatal_error("Your Panda3D build was not compiled with freetype support, but it is required!")
        cmake_args += ["-DHAVE_LIB_FREETYPE=TRUE"]

    # Optimization level
    optimize = 3

    if args.optimize is None:
        # No optimization level set. Try to find it in the config
        if "optimize" in config:
            optimize = config["optimize"]
    else:
        optimize = args.optimize

    # Verbose level
    if "verbose_igate" in config:
        cmake_args += ["-DIGATE_VERBOSE=" + str(config["verbose_igate"])]
    else:
        cmake_args += ["-DIGATE_VERBOSE=0"]

    cmake_args += ["-DOPTIMIZE=" + str(optimize)]
    print("="*80)
    print( cmake_args )


    e = dict_as_nt(**os.environ)

    #cmake_args.append( f"-DCMAKE_REQUIRED_INCLUDES={PDK}/built/include" )
    print("="*80)
    cmake_args.append( f"-DPANDA_INCLUDE_DIR={e.PDK_PANDA3D}/built/include")
    cmake_args.append( f"-DPANDA_LIBRARY_DIRS={e.PDK_LIB_PANDA3D}")
    cmake_args.append( f"-DPANDA_LIBRARY_DIR={e.PDK_LIB_PANDA3D}")
    cmake_args.append( f"-DLOCAL_PANDA_PATH={e.DEV_APPDIR}/usr" )
    cmake_args.append( f"-DCMAKE_TOOLCHAIN_FILE={e.SDK}/build.{e.BITS}/toolchain.android.cmake" )
    cmake_args.append( f"-DFREETYPE_LIBRARY={e.PDK_LIB_PANDA3D}" )
    cmake_args.append( f"-DFREETYPE_INCLUDE_DIRS={e.PDK_FREETYPE}/include" )


    #====================================================
    #FIXME: target specific !
    cmake_args.append( f"-DCMAKE_MULTILIB_PATH=armv7" )
    cmake_args.append( f"-DPYTHON_INCLUDE_DIRS={e.PDK_PANDA3D}/thirdparty/android-libs-armv7a/python/include/python3.7m" )
    cmake_args.append( f"-DPYTHON_LIBRARIES={e.PDK_LIB_PYTHON}/libpython3.7m.so" )
    #-O3 -ffast-math
    cmake_args.append( f"-DPANDA_LDFLAGS=-fPIE -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--fix-cortex-a8")
    cmake_args.append( f"-DPANDA_FLAGS=-fno-rtti -march=armv7-a")
    cmake_args.append( f"-DPANDA_CORE_PATH={e.PDK_LIB_PYTHON}/../lib/python3.7/site-packages/panda3d/core.cpython-37m.so")
    #======================================================================

    cmake_args.append( f"-DPYTHON_EXECUTABLE={e.PDK_PYTHON}" )
    #cmake_args.append( f"-DHAVE_LIB_EIGEN=0")
    cmake_args.append( f"-DPYTHONVERDOT=3.7m")
    cmake_args.append( f"-DOPTIMIZE=3" )
    cmake_args.append( f"-DSTDFLOAT_DOUBLE=1")

    #
    for libname in "panda pandaexpress p3dtool p3dtoolconfig p3direct p3interrogatedb p3framework".split(' '):
        cmake_args.append( f"-DPANDA_LIBRARY_{libname}={e.PDK_LIB_PANDA3D}/lib{libname}.so" )
    for arg in cmake_args:
        print(arg)
    print("="*80)
    print(f"LD_LIBRARY_PATH={e.LD_LIBRARY_PATH}", os.popen('which interrogate').read() )
    #raise SystemExit
    output = try_execute("cmake", join_abs(get_script_dir(), ".."), *cmake_args, error_formatter=handle_cmake_error)


def run_cmake_build(config, args):
    """ Runs the cmake build which builds the final output """

    configuration = "Release"
    if config["generate_pdb"].lower() in ["1", "true", "yes", "y"]:
        configuration = "RelWithDebInfo"

    # get number of cores, leave one for the system though
    num_cores = max(1, multiprocessing.cpu_count() - 1)

    core_option = ""
    if is_linux() or is_macos() or is_freebsd():
        # On linux, use all available cores
        core_option = "-j" + str(num_cores)
    if is_windows():
        # Specifying no cpu count makes MSBuild use all available ones
        core_option = "/m"

    try_execute("cmake", "--build", ".", "--config", configuration, "--", core_option)

"""

Common functions for the build system

"""

from __future__ import print_function

import locale
import sys
import subprocess
import platform

from os.path import dirname, realpath, join, isdir, isfile
from os import makedirs
from sys import argv, stdout, stderr, exit
from panda3d.core import PandaSystem, Filename, ExecutionEnvironment


class MSVCVersion(object):
    def __init__(self, msc_ver, cmake_str, suffix):
        self.version = msc_ver
        self.cmake_str = cmake_str
        self.suffix = suffix

    @property
    def compiler_search_string(self):
        return "MSC v." + str(self.version)

MSVC_VERSIONS = [
    MSVCVersion(1400, "Visual Studio 8 2005",  "vc80"),
    MSVCVersion(1500, "Visual Studio 9 2008",  "vc90"),
    MSVCVersion(1600, "Visual Studio 10 2010", "vc100"),
    MSVCVersion(1700, "Visual Studio 11 2012", "vc110"),
    MSVCVersion(1800, "Visual Studio 12 2013", "vc120"),
    MSVCVersion(1900, "Visual Studio 14 2015", "vc140")
]

def get_output_name():
    """ Returns the name of the output dir, depending on the system architecture """
    compiler_suffix = ""
    if is_windows():
        compiler_suffix = "_" + get_panda_mscv_version().suffix

    version_suffix = "panda" + PandaSystem.get_version_string()

    return PandaSystem.getPlatform().lower() + "_{}_py{}{}{}".format(
        version_suffix, sys.version_info.major,
        sys.version_info.minor, compiler_suffix)


def get_script_dir():
    """ Returns the name of the directory the scripts are located in """
    return dirname(realpath(__file__))


def get_basepath():
    """ Returns the basepath, based on the script dir """
    return join(get_script_dir(), "..")


def get_output_dir():
    """ Returns the output directory where CMake generates the build files into """
    return join(get_basepath(), get_output_name())


def get_panda_sdk_path():
    """ Returns the path of the panda3d sdk, under windows """
    # Import the base panda3d module
    import panda3d

    # Path of the module
    p3d_module = dirname(panda3d.__file__)
    p3d_sdk = join(p3d_module, "..")

    # Convert it to a valid filename
    fname = Filename.from_os_specific(p3d_sdk)
    fname.make_absolute()
    return fname.to_os_specific()


def get_panda_core_lib_path():
    """ Returns of the path of the core panda3d module, either core.pyd on windows
    or core.so on linux. This is an absolute path """
    import panda3d.core
    return panda3d.core.__file__


def get_panda_bin_path():
    """ Returns the path to the panda3d binaries """
    if is_windows():
        return first_existing_path([join(get_panda_sdk_path(), "bin")], "interrogate.exe")
    elif is_linux() or is_freebsd():
        libpath = get_panda_lib_path()
        search = [
            join(libpath, "../bin"),
            "/usr/bin",
            "/usr/local/bin",
        ]
        return first_existing_path(search, "interrogate")
    elif is_macos():
        return first_existing_path([join(get_panda_sdk_path(), "bin")], "interrogate")
    raise NotImplementedError("Unsupported OS")


def get_panda_lib_path():
    """ Returns the path to the panda3d libraries """
    if is_windows():
        return first_existing_path([join(get_panda_sdk_path(), "lib")], "libpanda.lib")
    elif is_linux() or is_macos() or is_freebsd():
        return dirname(ExecutionEnvironment.get_dtool_name())
    raise NotImplementedError("Unsupported OS")


def get_panda_include_path():
    """ Returns the path to the panda3d includes """
    if is_windows() or is_macos():
        return first_existing_path([join(get_panda_sdk_path(), "include")], "dtoolbase.h")
    elif is_linux() or is_freebsd():
        libpath = get_panda_lib_path()
        search = [
            join(libpath, "../include/"),
            "/usr/include/panda3d",
            "/usr/local/include/panda3d"
        ]
        return first_existing_path(search, "dtoolbase.h")
    raise NotImplementedError("Unsupported OS")


def first_existing_path(paths, required_file=None):
    """ Returns the first path out of a given list of paths which exists.
    If required_file is set, the path additionally has to contain the given
    filename """
    for pth in paths:
        if isdir(pth) and (required_file is None or isfile(join(pth, required_file))):
            return pth
    debug_out("No path out of the given list exists!")
    for pth in paths:
        debug_out("[-]", pth)
    fatal_error("Failed to match path")


def is_64_bit():
    """ Returns whether the build system is 64 bit (=True) or 32 bit (=False) """
    return PandaSystem.get_platform() in ["win_amd64"]


def is_windows():
    """ Returns whether the build system is windows """
    return platform.system().lower() == "windows"


def is_linux():
    """ Returns wheter the build system is linux """
    return platform.system().lower() == "linux"

def is_macos():
    """ Returns whether the build system is macos (darwin) """
    return platform.system().lower() == "darwin"

def is_freebsd():
    """ Returns whether the build system is freebsd """
    return platform.system().lower() == "freebsd"


def get_compiler_name():
    """ Returns the name of the used compiler, either 'MSC', 'GCC' or 'CLANG' """
    full_name = PandaSystem.get_compiler()
    compiler_name = full_name.split()[0]
    return compiler_name.upper()

def decode_str(s):
    if sys.version_info.major >= 3:
        if isinstance(s, str):
            return s.encode("ascii", "ignore").decode("ascii", "ignore")
        else:
            return str(s)
    else:
        return s.encode("ascii", "ignore")


def fatal_error(*args):
    """ Prints an error to stderr and then exits with a nonzero status code """

    print("\n\n[!] FATAL ERROR:", *[decode_str(i) for i in args], file=stderr)
    exit(1)


def debug_out(*args):
    """ Prints a debug output string """
    print(*[decode_str(i) for i in args])


def print_error(*args):
    """ Prints a debug output string """
    print(*[decode_str(i) for i in args], file=sys.stderr)


def try_makedir(dirname):
    """ Tries to make the specified dir, but in case it fails it does nothing """
    debug_out("Creating directory", dirname)
    try:
        makedirs(dirname)
    except:
        pass


def try_execute(*args, **kwargs):
    """ Tries to execute the given process, if everything wents good, it just
    returns, otherwise it prints the output to stderr and exits with a nonzero
    status code """
    error_formatter = kwargs.get("error_formatter", None) # Fix for Py < 3
    debug_out("Executing command: ", ' '.join(args), "\n")
    try:
        process = subprocess.Popen(args, shell=False, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        line = process.stdout.readline()
        output = line
        while line:
            debug_out(line.decode(locale.getpreferredencoding(), errors="ignore").rstrip("\r\n"))
            line = process.stdout.readline()
            output += line
        process.wait()
        if process.returncode != 0:
            if error_formatter:
                error_formatter(decode_str(output))
            raise Exception("Process had non-zero returncode:", process.returncode)

    except subprocess.CalledProcessError as msg:
        debug_out("Process error:")
        output = msg.output.decode(locale.getpreferredencoding(), errors="ignore")
        if error_formatter:
            error_formatter(decode_str(output))
        else:
            debug_out(output)
        fatal_error("Subprocess returned no-zero statuscode!")


def join_abs(*args):
    """ Behaves like os.path.join, but replaces stuff like '/../' """
    joined = join(*args)
    fname = Filename.from_os_specific(joined)
    fname.make_absolute()
    return fname.to_os_generic()


def get_ini_conf(fname):
    """ Very simple one-lined .ini file reader, with no error checking """
    with open(fname, "r") as handle:
        return {i.split("=")[0].strip(): i.split("=")[-1].strip() for i in handle.readlines() if i.strip()}  # noqa


def write_ini_conf(config, fname):
    """ Very simple .ini file writer, with no error checking """
    with open(fname, "w") as handle:
        handle.write(''.join("{}={}\n".format(k, v) for k, v in sorted(config.items())))

def get_panda_mscv_version():
    """ Returns the MSVC version panda was built with """
    compiler = PandaSystem.get_compiler()
    for msvc_version in MSVC_VERSIONS:
        if msvc_version.compiler_search_string in compiler:
            return msvc_version

    print("FATAL ERROR: Unable to detect visual studio version of your Panda3D Build!", file=sys.stderr)
    print("Unkown compiler string was: '" + compiler + "'", file=sys.stderr)
    print("", file=sys.stderr)
    print("Known visual studio versions are:", file=sys.stderr)
    for msvc_version in MSVC_VERSIONS:
        print("-", msvc_version.cmake_str, "(" + msvc_version.compiler_search_string + ")", file=sys.stderr)
    print("", file=sys.stderr)
    fatal_error("Unable to determine compiler")

def get_panda_short_version():
    return PandaSystem.getVersionString().replace(".0", "")

def have_eigen():
    """ Returns whether this panda3d build has eigen support """
    return PandaSystem.get_global_ptr().has_system("eigen")

def have_bullet():
    """ Returns whether this panda3d build has bullet support """
    try:
        import panda3d.bullet
    except Exception as msg:
        return False

    return PandaSystem.get_global_ptr().has_system("Bullet")

def have_freetype():
    """ Returns whether this panda3d build has freetype support """
    return PandaSystem.get_global_ptr().has_system("Freetype")


if __name__ == "__main__":

    # Command line scripts

    if len(argv) != 2:
        fatal_error("USAGE: ppython common.py <option>")

    if "--print-sdk-path" in argv:
        stdout.write(get_panda_sdk_path())
        exit(0)

    elif "--print-core-path" in argv:
        stdout.write(get_panda_core_lib_path())
        exit(0)

    elif "--print-lib-path" in argv:
        stdout.write(get_panda_lib_path())
        exit(0)

    elif "--print-short-version" in argv:
        stdout.write(get_panda_short_version())
        exit(0)

    elif "--print-paths" in argv:
        debug_out("SDK-Path:", get_panda_sdk_path())
        debug_out("BIN-Path:", get_panda_bin_path())
        debug_out("LIB-Path:", get_panda_lib_path())
        debug_out("INC-Path:", get_panda_include_path())
        debug_out("Compiler:", get_compiler_name())

    else:
        fatal_error("Unkown options: ", ' '.join(argv[1:]))

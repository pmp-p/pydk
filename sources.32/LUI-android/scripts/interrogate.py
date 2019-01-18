
"""

Runs the interrogate and interrogate_module commands from Panda3D.

"""

import sys
from os import listdir, chdir
from os.path import join, isfile, isdir

from panda3d.core import PandaSystem
from common import debug_out, get_panda_bin_path, get_panda_include_path
from common import get_compiler_name, is_64_bit, try_execute, join_abs, get_script_dir

if len(sys.argv) != 3:
    debug_out("Usage: python interrogate.py <module-name> <verbose-level>")
    sys.exit(1)


# Parameters
MODULE_NAME = "panda3d."+sys.argv[1]
LIB_NAME = sys.argv[1]
VERBOSE_LVL = int(sys.argv[2])  # Assume the user did specify something valid
VERBOSE_LVL = 2

def check_ignore(source):
    """ This function checks if a file is on the ignore list """
    for f in ["interrogate_module.cpp", "interrogate_wrapper.cpp"]:
        if f.lower() in source.lower():
            return False
    return True


def find_sources(base_dir):
    """ Collects all header files recursively """
    sources = []
    files = listdir(base_dir)
    for f in files:
        fpath = join(base_dir, f)
        if isfile(fpath) and check_ignore(f) and f.endswith(".h"):
            if f.endswith(".pb.h"):
                continue # Skip protobuf
            sources.append(fpath)
        elif isdir(fpath):
            sources += find_sources(fpath)
    return sources


def interrogate():
    """ Runs interrogate over the source directory """

    # Collect source files and convert them to a relative path
    all_sources = find_sources(".")

    # Create the interrogate command
    cmd = [join(get_panda_bin_path(), 'interrogate')]

    if VERBOSE_LVL == 1:
        cmd += ["-v"]
    elif VERBOSE_LVL == 2:
        cmd += ["-vv"]

    cmd += ["-fnames", "-string", "-refcount", "-assert", "-python-native"]
    cmd += ["-S" + get_panda_include_path() + "/parser-inc"]
    cmd += ["-S" + get_panda_include_path() + "/"]

    # Add all subdirectories
    for pth in listdir("."):
        if isdir(pth):
            cmd += ["-I" + pth]

    cmd += ["-srcdir", "."]
    cmd += ["-oc", "interrogate_wrapper.cpp"]
    cmd += ["-od", "interrogate.in"]
    cmd += ["-module", MODULE_NAME]
    cmd += ["-library", LIB_NAME]

    if PandaSystem.get_major_version() > 1 or PandaSystem.get_minor_version() > 9:
        # Add nomangle option, but only for recent builds
        cmd += ["-nomangle"]

    if PandaSystem.get_major_version() == 1 and PandaSystem.get_minor_version() < 10:
        # Old interrogate options cant handle volatile
        cmd += ["-Dvolatile="]

    # Defines required to parse the panda source
    defines = ["INTERROGATE", "CPPPARSER", "__STDC__=1", "__cplusplus=201103L"]

    if get_compiler_name() == "MSC":
        defines += ["__inline", "_X86_", "WIN32_VC", "WIN32", "_WIN32"]
        if is_64_bit():
            defines += ["WIN64_VC", "WIN64", "_WIN64"]
        # NOTE: this 1600 value is the version number for VC2010.
        defines += ["_MSC_VER=1600", '"__declspec(param)="', "__cdecl", "_near",
                    "_far", "__near", "__far", "__stdcall"]

    if get_compiler_name() == "GCC":
        defines += ['__attribute__\(x\)=']
        if is_64_bit():
            defines += ['_LP64']
        else:
            defines += ['__i386__']

    for define in defines:
        cmd += ["-D" + define]

    cmd += all_sources
    try_execute(*cmd)


def interrogate_module():
    """ Runs the interrogate module command """

    # Create module command
    cmd = [join_abs(get_panda_bin_path(), "interrogate_module")]
    cmd += ["-python-native"]

    if PandaSystem.get_major_version() > 1 or PandaSystem.get_minor_version() > 9:
        # Older panda3d versions don't have this
        cmd += ["-import", "panda3d.core"]

    cmd += ["-module", MODULE_NAME]
    cmd += ["-library", LIB_NAME]
    cmd += ["-oc", "interrogate_module.cpp"]
    cmd += ["interrogate.in"]

    try_execute(*cmd)

if __name__ == "__main__":

    # Change into the source directory
    source_dir = join(get_script_dir(), "../source/")
    chdir(source_dir)

    interrogate()
    interrogate_module()

    sys.exit(0)

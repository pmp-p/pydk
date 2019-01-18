
# Important: import panda3d as the very first library - otherwise it crashes
import panda3d.core  # noqa

import sys

from shutil import copyfile
from os.path import isfile, join
from common import is_windows, get_output_dir, fatal_error, get_script_dir


def find_binary():
    """ Returns the path to the generated binary and pdb file """

    source_file = None
    pdb_file = None
    possible_files = []

    if is_windows():

        # Check the different Configurations
        configurations = ["RelWithDebInfo", "Release"]
        target_file = MODULE_NAME + ".pyd"

        for config in configurations:
            possible_files.append(join(get_output_dir(), config, MODULE_NAME + ".dll"))

    else:
        target_file = MODULE_NAME + ".so"
        possible_files.append(join(get_output_dir(), target_file))

    for file in possible_files:
        if isfile(file):
            source_file = file

            pdb_name = file.replace(".so", ".pdb").replace(".dll", ".pdb")
            if isfile(pdb_name):
                pdb_file = pdb_name

    return source_file, pdb_file, target_file

if __name__ == "__main__":

    if len(sys.argv) != 2:
        fatal_error("Usage: finalize.py <module-name>")

    MODULE_NAME = sys.argv[1]
    source_file, pdb_file, target_file = find_binary()
    target_pdb_file = MODULE_NAME + ".pdb"

    if source_file:
        dest_folder = join(get_script_dir(), "../")

        # Copy the generated DLL
        copyfile(source_file, join(dest_folder, target_file))

        # Copy the generated PDB (if it was generated)
        if pdb_file:
            copyfile(pdb_file, join(dest_folder, target_pdb_file))

    else:
        fatal_error("Failed to find generated binary!")

    sys.exit(0)

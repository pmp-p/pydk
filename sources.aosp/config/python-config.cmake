set(Python_ROOT_DIR "${CMAKE_INSTALL_PREFIX}")
set(Python_VERSION "${PYMAJOR}.${PYMINOR}")
set(PYTHON_VERSION_STRING "${PYMAJOR}.${PYMINOR}")
set(PYTHON_EXTENSION_SUFFIX ".so")

#TODO set(Python_SOABI
# Python_SOABI    New in version 3.17. Extension suffix for modules.
#   Information returned by distutils.sysconfig.get_config_var('SOABI')
# or computed from distutils.sysconfig.get_config_var('EXT_SUFFIX') or python-config --extension-suffix.
#  If package distutils.sysconfig is not available, sysconfig.get_config_var('SOABI') or sysconfig.get_config_var('EXT_SUFFIX') are used.

set(Python_INCLUDE_DIR "${CMAKE_INSTALL_PREFIX}/include/python${PYMAJOR}.${PYMINOR}")
set(Python_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/include/python${PYMAJOR}.${PYMINOR}")

set(Python_LIBRARY "${CMAKE_INSTALL_PREFIX}/lib")
set(Python_LIBRARY_DIRS "${CMAKE_INSTALL_PREFIX}/lib")
set(Python_STDLIB "${CMAKE_INSTALL_PREFIX}/lib/python${Python_VERSION}")
set(Python_SITELIB "${CMAKE_INSTALL_PREFIX}/lib/python${Python_VERSION}/site-packages")
set(Python_FOUND YES)

set(PYTHON_ARCH_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/lib/python${Python_VERSION}")
set(PYTHON_LIB_INSTALL_DIR "${ASSETS}/python${Python_VERSION}")


message(">>>>>>>>>>>>>> python ${PYTHON_VERSION_STRING} <<<<<<<<<<<<<<<<<<<<<<<")
message(">>> CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} <<<")
message(">>> CMAKE_CROSSCOMPILING=${CMAKE_CROSSCOMPILING} <<<")
message(">>> ANDROID=${ANDROID} <<<")
message(">>> CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES=${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES}")
message(">>> CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES=${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES}")
message(">>> PATH=$ENV{PATH} <<<")
message(">>> LD_LIBRARY_PATH=$ENV{LD_LIBRARY_PATH}")
message(">>> PYTHON_EXTENSION_SUFFIX=${PYTHON_EXTENSION_SUFFIX} <<<")
message(">>> PYTHON_ARCH_INSTALL_DIR=${PYTHON_ARCH_INSTALL_DIR} <<<")
message(">>> PYTHON_LIB_INSTALL_DIR=${PYTHON_LIB_INSTALL_DIR} <<<")
message(">>> INTERROGATE_PYTHON_INTERFACE=${INTERROGATE_PYTHON_INTERFACE} <<<")






set(PROJECT_NAME CACHE STRING "Module")

cmake_minimum_required (VERSION 2.6)
project (${PROJECT_NAME})

# Project configuration
set(CMAKE_BUILD_TYPE "Release")

# Libraries and options set by the module builder
set(HAVE_LIB_EIGEN CACHE BOOL FALSE)
set(HAVE_LIB_BULLET CACHE BOOL TRUE)
set(HAVE_LIB_FREETYPE CACHE BOOL TRUE)
set(OPTIMIZE CACHE STRING "3")
set(IGATE_VERBOSE CACHE STRING "0")
set(INTERROGATE_LIB CACHE STRING "p3interrogatedb")
set(PYTHON_EXECUTABLE CACHE STRING "python")


# --- User controllable variables ---

# Whether to enable SSE. This only has effect on 32 bit.
# Should probably match the setting for the Panda3D build
set(ENABLE_SSE2 CACHE BOOL 0)
set(TOUCHINPUT_ENABLED CACHE BOOL 0)


# --- End of user variables --

# Reset cmake flags - we user our own
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "")
set(CMAKE_CXX_FLAGS_RELEASE "")
set(CMAKE_CXX_FLAGS_MINSIZEREL "")


set(LIBRARIES "")

# Windows - 32 and 64 bit
if (WIN32)
  if (CMAKE_CL_64 STREQUAL "1")
    message(STATUS "Bitness: 64 bit ('${CMAKE_CL_64}')")
    set(IS_64_BIT TRUE)
    set(IS_32_BIT FALSE)
  else()
    message(STATUS "Bitness: 32 bit ('${CMAKE_CL_64}')")
    set(IS_64_BIT TRUE)
    set(IS_32_BIT FALSE)
  endif()

  set(PYTHONVER CACHE STRING "27")

  # Find panda path
  execute_process(
    COMMAND "${PYTHON_EXECUTABLE}" "-B" "scripts/common.py" "--print-sdk-path"
    OUTPUT_VARIABLE WIN_PANDA_PATH
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
  message(STATUS "Detected panda3d installation: ${WIN_PANDA_PATH}")


  # Determine bitness
  set(THIRDPARTY_SUFFIX "-x64")
  if (IS_32_BIT)
    set(THIRDPARTY_SUFFIX "")
  endif()



  # Find visual studio version
  if (MSVC10)
    set(MSVC_VERSION_SHORT "vc10")
  elseif (MSVC12)
    set(MSVC_VERSION_SHORT "vc12")
  elseif(MSVC14)
    set(MSVC_VERSION_SHORT "vc14")
  else()
    message(WARMING "Unable to determine visual studio version, assuming Visual Studio 2010")
    set(MSVC_VERSION_SHORT "vc10")
  endif()
  message(STATUS "Detected visual studio version: ${MSVC_VERSION_SHORT}")


  # Find thirdparty directory
  set(THIRDPARTY_DIR "${WIN_PANDA_PATH}/../thirdparty/win-libs-${MSVC_VERSION_SHORT}${THIRDPARTY_SUFFIX}")
  if (NOT (EXISTS "${THIRDPARTY_DIR}"))
    set(THIRDPARTY_DIR "${WIN_PANDA_PATH}/thirdparty/win-libs-${MSVC_VERSION_SHORT}${THIRDPARTY_SUFFIX}")
  endif()

  if (NOT (EXISTS "${THIRDPARTY_DIR}"))
    message(WARNING "Unable to find thirdparty directory! Expected it at: ${THIRDPARTY_DIR}")
  else()
    message(STATUS "Detected thirdparty directory: ${THIRDPARTY_DIR}")
  endif()


  # Find lib and include directory
  set(PANDA_LIBRARY_DIRS "${WIN_PANDA_PATH}/lib")
  set(PANDA_INCLUDE_DIR "${WIN_PANDA_PATH}/include")

  if (NOT (EXISTS "${PANDA_LIBRARY_DIRS}"))
    message(WARNING "Panda3D library directory does not exist! Expected it at: ${PANDA_LIBRARY_DIRS}")
  endif()

  set(PYTHON_LIBRARIES "${WIN_PANDA_PATH}/python/libs/python${PYTHONVER}.lib")
  set(PYTHON_INCLUDE_DIRS "${WIN_PANDA_PATH}/python/include")

  # [LIB] Bullet
  if(HAVE_LIB_BULLET)

    if (NOT (EXISTS "${PANDA_INCLUDE_DIR}/bullet_includes.h"))
      message(FATAL_ERROR "This module requires the bullet library, but your Panda3D Build was copmiled without bullet support! Use --use-bullet when compiling.")
    endif()

    include_directories("${THIRDPARTY_DIR}/bullet/include/")
    link_directories("${THIRDPARTY_DIR}/bullet/lib/")

    if(EXISTS "${THIRDPARTY_DIR}/bullet/lib/LinearMath_x64.lib")
      set(LIBRARIES "${LIBRARIES};LinearMath_x64;BulletCollision_x64;BulletDynamics_x64;BulletSoftBody_x64")
    else()
      set(LIBRARIES "${LIBRARIES};LinearMath;BulletCollision;BulletDynamics;BulletSoftBody")
    endif()
  endif()

  # [LIB] Eigen 3
  if (HAVE_LIB_EIGEN)
    include_directories("${THIRDPARTY_DIR}/eigen/include")

    # Eigen build flags (sync with Panda)
    if (HAVE_LIB_EIGEN)
      add_definitions("/DEIGEN_MPL2_ONLY=")
      if ((OPTIMIZE STREQUAL "3") OR (OPTIMIZE STREQUAL "4"))
        add_definitions("/DEIGEN_NO_DEBUG=")
        if (MSVC)
          # Squeeze out a bit more performance on MSVC builds...
          # Only do this if EIGEN_NO_DEBUG is also set, otherwise it
          # will turn them into runtime assertions.
          add_definitions("/DEIGEN_NO_STATIC_ASSERT=")
        endif()
      endif()
    endif()
  endif()

  # [LIB] Freetype
  if (HAVE_LIB_FREETYPE)
    include_directories("${THIRDPARTY_DIR}/freetype/include")
    include_directories("${THIRDPARTY_DIR}/freetype/include/freetype2")
    link_directories("${THIRDPARTY_DIR}/freetype/lib")
    set(LIBRARIES "${LIBRARIES};freetype")
  endif()

  # Check if all supplied files exist
  set(CHECK_PATHS ${PANDA_LIBRARY_DIRS} ${PANDA_INCLUDE_DIR} ${PYTHON_LIBRARIES} ${PYTHON_INCLUDE_DIRS})
  foreach(PATH ${CHECK_PATHS})
    if(NOT (EXISTS "${PATH}"))
        message(FATAL_ERROR "The supplied path '${PATH}' could not be found!")
    endif()
  endforeach()

  # Link panda libraries
  set(PANDA_LIBRARIES "libp3framework;libpanda;libpandaexpress;libp3dtool;libp3dtoolconfig;libp3direct;${INTERROGATE_LIB}")
  if(HAVE_LIB_BULLET)
    set(PANDA_LIBRARIES "libpandabullet;${PANDA_LIBRARIES}")
  endif()
  link_directories("${PANDA_LIBRARY_DIRS}")

else()
  set(PYTHONVERDOT CACHE STRING "3.7")
  set(Python_ADDITIONAL_VERSIONS ${PYTHONVERDOT})
  #find_package(PythonLibs REQUIRED)

  # [LIB] Bullet
  if (HAVE_LIB_BULLET)
    find_package(Bullet REQUIRED)
    include_directories(${BULLET_INCLUDE_DIRS})
    set(LIBRARIES "${LIBRARIES};${BULLET_LIBRARIES}")
  endif()

  # [LIB] Eigen 3
  if (HAVE_LIB_EIGEN)
    if (${CMAKE_SYSTEM_NAME} MATCHES "FreeBSD")
      include_directories(BEFORE "/usr/local/include/eigen3/")
    else()
      include_directories(BEFORE "/usr/include/eigen3/")
    endif()

    # Eigen build flags (sync with Panda)
    if (HAVE_LIB_EIGEN)
      add_definitions("/DEIGEN_MPL2_ONLY=")
      if ((OPTIMIZE STREQUAL "3") OR (OPTIMIZE STREQUAL "4"))
        add_definitions("/DEIGEN_NO_DEBUG=")
      endif()
    endif()
  endif()

  # [LIB] Freetype
  if(HAVE_LIB_FREETYPE)
    find_package(Freetype REQUIRED)
    include_directories(${FREETYPE_INCLUDE_DIRS})
    set(LIBRARIES "${LIBRARIES};${FREETYPE_LIBRARIES}")
  endif()

  # Locate the Panda3D headers
  find_path(PANDA_INCLUDE_DIR dtoolbase.h PATH_SUFFIXES panda3d)

  # Locate the Panda3D libraries
  set(REQ_LIBRARIES p3framework panda pandaexpress p3dtool p3dtoolconfig p3direct ${INTERROGATE_LIB})
  if(HAVE_LIB_BULLET)
    set(REQ_LIBRARIES pandabullet ${REQ_LIBRARIES})
  endif()

  set(PANDA_LIBRARIES "")
  foreach (lib ${REQ_LIBRARIES})
    find_library(PANDA_LIBRARY_${lib} ${lib} PATH_SUFFIXES panda3d)
    set(PANDA_LIBRARIES "${PANDA_LIBRARIES};${PANDA_LIBRARY_${lib}}")
  endforeach()

  find_package_handle_standard_args(Panda DEFAULT_MSG PANDA_LIBRARIES PANDA_INCLUDE_DIR)

  if (NOT EXISTS ${PANDA_INCLUDE_DIR})
    # Okay, the standard package handling failed. Try finding a local panda3d installation

    # Find panda path
    execute_process(
      COMMAND "${PYTHON_EXECUTABLE}" "-B" "scripts/common.py" "--print-sdk-path"
      OUTPUT_VARIABLE LOCAL_PANDA_PATH
      WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

    if (NOT EXISTS "${LOCAL_PANDA_PATH}/include")
      message(FATAL_ERROR "Could not find system wide panda3d headers, and no local installation was found!")
    endif()

    set(PANDA_INCLUDE_DIR "${LOCAL_PANDA_PATH}/include")

    set(PANDA_LIBRARIES "")
    foreach(lib ${REQ_LIBRARIES})
      find_library(PANDA_LIBRARY_${lib} ${lib} PATHS "${LOCAL_PANDA_PATH}/lib/")
      #set(PANDA_LIBRARIES "${PANDA_LIBRARIES};${PANDA_LIBRARY_${lib}}")
      set(PANDA_LIBRARIES "${PANDA_LIBRARIES} -l{lib}")
    endforeach()
  endif()

  set(PANDA_LIBRARIES "-L${PANDA_LIBRARY_DIR} -lpanda -lpandaexpress -lp3dtool -lp3dtoolconfig -lp3direct -lp3interrogatedb -lp3framework")

endif()

# Find core.so/core.pyd path
#execute_process(
#  COMMAND "${PYTHON_EXECUTABLE}" "-B" "scripts/common.py" "--print-core-path"
#  OUTPUT_VARIABLE PANDA_CORE_PATH
#  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

add_definitions("${PANDA_FLAGS}")

# Link panda includes / libraries
include_directories("${PANDA_INCLUDE_DIR}")
include_directories("${PYTHON_INCLUDE_DIRS}")

# Run interrogate over the files
execute_process(
    COMMAND "${PYTHON_EXECUTABLE}" "-B" "scripts/interrogate.py" "${PROJECT_NAME}" "${IGATE_VERBOSE}"
    OUTPUT_VARIABLE output
    ERROR_VARIABLE errors
    RESULT_VARIABLE return_code
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

if (NOT ("${IGATE_VERBOSE}" STREQUAL "0" ))
  message(STATUS "IGATE stdout = ${output}")
  message(STATUS "IGATE stderr = ${errors}")
endif()

if(NOT ("${return_code}" STREQUAL "0"))
    message(FATAL_ERROR "Interrogate failed: ${output} ${errors}")
endif()

add_definitions("-pthread -std=c++11 -fno-exceptions -ftemplate-depth-70 -fPIE -fPIC -c")


# Define the module name
add_definitions("/DPB_MODULE=${PROJECT_NAME}")
add_definitions("/DPB_CFG_MODULE=${PROJECT_NAME}")

# Collect sources for compiling
file(GLOB_RECURSE SOURCES source/*.cpp source/*.cxx source/*.I source/*.hpp source/*.h source/*.cc source/*.c)
include_directories("source/")
set(SOURCES ${SOURCES_H} ${SOURCES})

# Collect subdirs for compiling
file(GLOB POSSIBLE_DIRS RELATIVE ${CMAKE_CURRENT_LIST_DIR} source/*)
foreach(PDIR ${POSSIBLE_DIRS})
  if (IS_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${PDIR})
    include_directories("${PDIR}")
    file(GLOB POSSIBLE_SUB_DIRS RELATIVE ${CMAKE_CURRENT_LIST_DIR}/${PDIR} ${PDIR}/*)
    foreach(PSUBDIR ${POSSIBLE_SUB_DIRS})
      if (IS_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${PDIR}/${PSUBDIR})
        include_directories("${PDIR}/${PSUBDIR}")
      endif()
    endforeach()
  endif()
endforeach()


if ((EXISTS "${CMAKE_CURRENT_LIST_DIR}/additional_libs.cmake"))
  include("${CMAKE_CURRENT_LIST_DIR}/additional_libs.cmake")
endif()


# Build library
if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  # macOS won't let us link a .so with another .so, so make a .dylib
  add_library(${PROJECT_NAME} SHARED ${SOURCES})
  # Python doesn't detect .dylibs, so rename it .so
  set(CMAKE_SHARED_LIBRARY_SUFFIX ".so")
else()
  add_library(${PROJECT_NAME} MODULE ${SOURCES})
endif()

# Don't add lib prefix on Linux
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "")

# Add the required libraries
target_link_libraries(${PROJECT_NAME} ${PYTHON_LIBRARIES} ${PANDA_LIBRARIES} ${LIBRARIES})

if(WIN32)
#   # Eventually link core.pyd?
else()
  set(CMAKE_MODULE_LINKER_FLAGS ${PANDA_CORE_PATH})
endif()

# After building, copy the file to the current directory
add_custom_command(
    TARGET ${PROJECT_NAME}
    POST_BUILD
    COMMAND "${PYTHON_EXECUTABLE}" "-B" "${CMAKE_CURRENT_LIST_DIR}/scripts/finalize.py" "${PROJECT_NAME}"
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

# Make shared library paths absolute on macOS
if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  execute_process(
    COMMAND "${PYTHON_EXECUTABLE}" "-B" "scripts/common.py" "--print-lib-path"
    OUTPUT_VARIABLE PANDA_LIB_PATH
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
  execute_process(
    COMMAND "${PYTHON_EXECUTABLE}" "-B" "scripts/common.py" "--print-short-version"
    OUTPUT_VARIABLE PANDA_SHORT_VERSION
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
  )

  foreach(lib ${REQ_LIBRARIES})
    add_custom_command(
      TARGET ${PROJECT_NAME}
      POST_BUILD
      COMMAND "install_name_tool" "-change" "@loader_path/../lib/lib${lib}.${PANDA_SHORT_VERSION}.dylib" "${PANDA_LIB_PATH}/lib${lib}.dylib" "${PROJECT_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}"
      WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
  endforeach()
endif()

cmake_minimum_required(VERSION 2.8.7)
if(POLICY CMP0046)
  cmake_policy(SET CMP0046 NEW)
endif()
if(POLICY CMP0054)
  cmake_policy(SET CMP0054 NEW)
endif()

# ---[ DeepSTD project
project(DeepSTD C CXX)

# ---[ Caffe version
set(DEEPSTD_TARGET_VERSION "1.0.0")
set(DEEPSTD_TARGET_SOVERSION "1.0.0")
add_definitions(-DDEEPSTD_VERSION=${DEEPSTD_TARGET_VERSION})

# ---[ Using cmake scripts and modules
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules)

include(cmake/Utils.cmake)

# ---[ Options
deepstd_option(BUILD_python "Build Python wrapper" ON)

# ---[ Dependencies
include(cmake/Dependencies.cmake)
include(cmake/Summary.cmake)

# ---[ Flags
if(UNIX OR APPLE)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -Wall")
endif()

#deepstd_set_deepstd_link()

if(USE_libstdcpp)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libstdc++")
  message("-- Warning: forcing libstdc++ (controlled by USE_libstdcpp option in cmake)")
endif()

# ---[ Includes
set(DEEPSTD_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include)
include_directories(${DEEPSTD_INCLUDE_DIR} ${PROJECT_BINARY_DIR})

# ---[ Subdirectories
add_subdirectory(features/mser)

# ---[ Configuration summary
deepstd_print_configuration_summary()

# add this
deepstd_print_configuration_summary()



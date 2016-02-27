if(NOT HAVE_PYTHON)
  message(STATUS "Python interface is disabled or not all required dependencies found. Building without it...")
  return()
endif()

include_directories(${PYTHON_INCLUDE_DIRS} ${NUMPY_INCLUDE_DIR} ${Boost_INCLUDE_DIRS})
file(GLOB_RECURSE mser_srcs ${PROJECT_SOURCE_DIR}/features/mser/*.cpp)

add_library(pymser SHARED ${mser_srcs})
target_link_libraries(pymser ${PYTHON_LIBRARIES} ${Boost_LIBRARIES})
set_target_properties(pymser PROPERTIES PREFIX "" OUTPUT_NAME "_mser")

if(UNIX OR APPLE)
    set(__linkname "${PROJECT_SOURCE_DIR}/features/mser/_mser.so")
    add_custom_command(TARGET pymser POST_BUILD
                       COMMAND ln -sf $<TARGET_LINKER_FILE:pymser> "${__linkname}"
                       COMMENT "Creating symlink ${__linkname} -> ${PROJECT_BINARY_DIR}/lib/_mser.so")
endif()


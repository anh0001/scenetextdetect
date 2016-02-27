################################################################################################
# Deepstd status report function.
# Automatically align right column and selects text based on condition.
# Usage:
#   deepstd_status(<text>)
#   deepstd_status(<heading> <value1> [<value2> ...])
#   deepstd_status(<heading> <condition> THEN <text for TRUE> ELSE <text for FALSE> )
function(deepstd_status text)
  set(status_cond)
  set(status_then)
  set(status_else)

  set(status_current_name "cond")
  foreach(arg ${ARGN})
    if(arg STREQUAL "THEN")
      set(status_current_name "then")
    elseif(arg STREQUAL "ELSE")
      set(status_current_name "else")
    else()
      list(APPEND status_${status_current_name} ${arg})
    endif()
  endforeach()

  if(DEFINED status_cond)
    set(status_placeholder_length 23)
    string(RANDOM LENGTH ${status_placeholder_length} ALPHABET " " status_placeholder)
    string(LENGTH "${text}" status_text_length)
    if(status_text_length LESS status_placeholder_length)
      string(SUBSTRING "${text}${status_placeholder}" 0 ${status_placeholder_length} status_text)
    elseif(DEFINED status_then OR DEFINED status_else)
      message(STATUS "${text}")
      set(status_text "${status_placeholder}")
    else()
      set(status_text "${text}")
    endif()

    if(DEFINED status_then OR DEFINED status_else)
      if(${status_cond})
        string(REPLACE ";" " " status_then "${status_then}")
        string(REGEX REPLACE "^[ \t]+" "" status_then "${status_then}")
        message(STATUS "${status_text} ${status_then}")
      else()
        string(REPLACE ";" " " status_else "${status_else}")
        string(REGEX REPLACE "^[ \t]+" "" status_else "${status_else}")
        message(STATUS "${status_text} ${status_else}")
      endif()
    else()
      string(REPLACE ";" " " status_cond "${status_cond}")
      string(REGEX REPLACE "^[ \t]+" "" status_cond "${status_cond}")
      message(STATUS "${status_text} ${status_cond}")
    endif()
  else()
    message(STATUS "${text}")
  endif()
endfunction()


################################################################################################
# Function for fetching Deepstd version from git and headers
# Usage:
#   deepstd_extract_deepstd_version()
function(deepstd_extract_deepstd_version)
  set(DEEPSTD_GIT_VERSION "unknown")
  find_package(Git)
  if(GIT_FOUND)
    execute_process(COMMAND ${GIT_EXECUTABLE} describe --tags --always --dirty
                    ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE
                    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
                    OUTPUT_VARIABLE DEEPSTD_GIT_VERSION
                    RESULT_VARIABLE __git_result)
    if(NOT ${__git_result} EQUAL 0)
      set(DEEPSTD_GIT_VERSION "unknown")
    endif()
  endif()

  set(DEEPSTD_GIT_VERSION ${DEEPSTD_GIT_VERSION} PARENT_SCOPE)
  set(DEEPSTD_VERSION "<TODO> (DeepSTD doesn't declare its version in headers)" PARENT_SCOPE)

  # deepstd_parse_header(${DEEPSTD_INCLUDE_DIR}/deepstd/version.hpp DEEPSTD_VERSION_LINES DEEPSTD_MAJOR DEEPSTD_MINOR DEEPSTD_PATCH)
  # set(DEEPSTD_VERSION "${DEEPSTD_MAJOR}.${DEEPSTD_MINOR}.${DEEPSTD_PATCH}" PARENT_SCOPE)

  # or for #define DEEPSTD_VERSION "x.x.x"
  # deepstd_parse_header_single_define(DEEPSTD ${DEEPSTD_INCLUDE_DIR}/deepstd/version.hpp DEEPSTD_VERSION)
  # set(DEEPSTD_VERSION ${DEEPSTD_VERSION_STRING} PARENT_SCOPE)

endfunction()


################################################################################################
# Prints accumulated deepstd configuration summary
# Usage:
#   deepstd_print_configuration_summary()

function(deepstd_print_configuration_summary)
  deepstd_extract_deepstd_version()
  set(DEEPSTD_VERSION ${DEEPSTD_VERSION} PARENT_SCOPE)

  deepstd_merge_flag_lists(__flags_rel CMAKE_CXX_FLAGS_RELEASE CMAKE_CXX_FLAGS)
  deepstd_merge_flag_lists(__flags_deb CMAKE_CXX_FLAGS_DEBUG   CMAKE_CXX_FLAGS)

  deepstd_status("")
  deepstd_status("******************* Deepstd Configuration Summary *******************")
  deepstd_status("General:")
  deepstd_status("  Version           :   ${DEEPSTD_TARGET_VERSION}")
  deepstd_status("  Git               :   ${DEEPSTD_GIT_VERSION}")
  deepstd_status("  System            :   ${CMAKE_SYSTEM_NAME}")
  deepstd_status("  C++ compiler      :   ${CMAKE_CXX_COMPILER}")
  deepstd_status("  Release CXX flags :   ${__flags_rel}")
  deepstd_status("  Debug CXX flags   :   ${__flags_deb}")
  deepstd_status("  Build type        :   ${CMAKE_BUILD_TYPE}")
  deepstd_status("")
  deepstd_status("  BUILD_SHARED_LIBS :   ${BUILD_SHARED_LIBS}")
  deepstd_status("  BUILD_python      :   ${BUILD_python}")
  deepstd_status("  BUILD_docs        :   ${BUILD_docs}")
  deepstd_status("  USE_OPENCV        :   ${USE_OPENCV}")
  deepstd_status("")
  deepstd_status("Dependencies:")
  deepstd_status("  Boost             :   Yes (ver. ${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION})")
  if(USE_OPENCV)
    deepstd_status("  OpenCV            :   Yes (ver. ${OpenCV_VERSION})")
  endif()
  deepstd_status("  CUDA              : " HAVE_CUDA THEN "Yes (ver. ${CUDA_VERSION})" ELSE "No" )
  deepstd_status("")
  if(HAVE_CUDA)
    deepstd_status("NVIDIA CUDA:")
    deepstd_status("  Target GPU(s)     :   ${CUDA_ARCH_NAME}" )
    deepstd_status("  GPU arch(s)       :   ${NVCC_FLAGS_EXTRA_readable}")
    if(USE_CUDNN)
      deepstd_status("  cuDNN             : " HAVE_CUDNN THEN "Yes (ver. ${CUDNN_VERSION})" ELSE "Not found")
    else()
      deepstd_status("  cuDNN             :   Disabled")
    endif()
    deepstd_status("")
  endif()
  if(HAVE_PYTHON)
    deepstd_status("Python:")
    deepstd_status("  Interpreter       :" PYTHON_EXECUTABLE THEN "${PYTHON_EXECUTABLE} (ver. ${PYTHON_VERSION_STRING})" ELSE "No")
    deepstd_status("  Libraries         :" PYTHONLIBS_FOUND  THEN "${PYTHON_LIBRARIES} (ver ${PYTHONLIBS_VERSION_STRING})" ELSE "No")
    deepstd_status("  NumPy             :" NUMPY_FOUND  THEN "${NUMPY_INCLUDE_DIR} (ver ${NUMPY_VERSION})" ELSE "No")
    deepstd_status("")
  endif()
  if(BUILD_docs)
    deepstd_status("Documentaion:")
    deepstd_status("  Doxygen           :" DOXYGEN_FOUND THEN "${DOXYGEN_EXECUTABLE} (${DOXYGEN_VERSION})" ELSE "No")
    deepstd_status("  config_file       :   ${DOXYGEN_config_file}")

    deepstd_status("")
  endif()
  deepstd_status("Install:")
  deepstd_status("  Install path      :   ${CMAKE_INSTALL_PREFIX}")
  deepstd_status("")
endfunction()

#=============================================================================
# Copyright 2014-2015 Ruslan Baratov
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

# Function to print messages of this module
function(install_universal_ios_message)
  message("[iOS universal] " ${ARGN})
endfunction()

# Get build settings for the current target/config/SDK by running
# `xcodebuild -sdk ... -showBuildSettings` and parsing it's output
function(install_universal_ios_get sdk variable resultvar)
  if("${sdk}" STREQUAL "")
    message(FATAL_ERROR "`sdk` is empty")
  endif()

  if("${variable}" STREQUAL "")
    message(FATAL_ERROR "`variable` is empty")
  endif()

  if("${resultvar}" STREQUAL "")
    message(FATAL_ERROR "`resultvar` is empty")
  endif()

  set(
      cmd
      xcodebuild -showBuildSettings
      -sdk "${sdk}"
      -target "${CURRENT_TARGET}"
      -config "${CURRENT_CONFIG}"
  )

  execute_process(
      COMMAND ${cmd}
      WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
      RESULT_VARIABLE result
      OUTPUT_VARIABLE output
  )

  if(NOT result EQUAL 0)
    message(FATAL_ERROR "Command failed (${result}): ${cmd}")
  endif()

  if(NOT output MATCHES " ${variable} = ([^\n]*)")
    message(FATAL_ERROR "${variable} not found.")
  endif()

  set("${resultvar}" "${CMAKE_MATCH_1}" PARENT_SCOPE)
endfunction()

# Get architectures of given SDK (iphonesimulator/iphoneos)
function(install_universal_ios_get_valid_archs sdk resultvar)
  cmake_policy(SET CMP0007 NEW)

  if("${resultvar}" STREQUAL "")
    message(FATAL_ERROR "`resultvar` is empty")
  endif()

  install_universal_ios_get("${sdk}" "VALID_ARCHS" valid_archs)

  separate_arguments(valid_archs)
  list(REMOVE_ITEM valid_archs "") # remove empty elements
  list(REMOVE_DUPLICATES valid_archs)

  set("${resultvar}" "${valid_archs}" PARENT_SCOPE)
endfunction()

# Final target can contain more architectures that specified by SDK. This
# function will run 'lipo -info' and parse output. Result will be returned
# as a CMake list.
function(install_universal_ios_get_real_archs filename resultvar)
  set(cmd "${_lipo_path}" -info "${filename}")
  execute_process(
      COMMAND ${cmd}
      RESULT_VARIABLE result
      OUTPUT_VARIABLE output
      ERROR_VARIABLE output
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_STRIP_TRAILING_WHITESPACE
  )
  if(NOT result EQUAL 0)
    message(
        FATAL_ERROR "Command failed (${result}): ${cmd}\n\nOutput:\n${output}"
    )
  endif()

  if(NOT output MATCHES "(Architectures in the fat file: [^\n]+ are|Non-fat file: [^\n]+ is architecture): ([^\n]*)")
    message(FATAL_ERROR "Could not detect architecture from: ${output}")
  endif()

  separate_arguments(CMAKE_MATCH_2)
  set(${resultvar} ${CMAKE_MATCH_2} PARENT_SCOPE)
endfunction()

# Run build command for the given SDK
function(install_universal_ios_build sdk)
  if("${sdk}" STREQUAL "")
    message(FATAL_ERROR "`sdk` is empty")
  endif()

  install_universal_ios_message("Build `${CURRENT_TARGET}` for `${sdk}`")

  execute_process(
      COMMAND
      "${CMAKE_COMMAND}"
      --build
      .
      --target "${CURRENT_TARGET}"
      --config ${CURRENT_CONFIG}
      --
      -sdk "${sdk}"
      WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
      RESULT_VARIABLE result
  )

  if(NOT result EQUAL 0)
    message(FATAL_ERROR "Build failed")
  endif()
endfunction()

# Remove given architecture from file. This step needed only in rare cases
# when target was built in "unusual" way. Emit warning message.
function(install_universal_ios_remove_arch lib arch)
  install_universal_ios_message(
    "Warning! Unexpected architecture `${arch}` detected and will be removed "
    "from file `${lib}`")
  set(cmd "${_lipo_path}" -remove ${arch} -output ${lib} ${lib})
  execute_process(
      COMMAND ${cmd}
      RESULT_VARIABLE result
      OUTPUT_VARIABLE output
      ERROR_VARIABLE output
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_STRIP_TRAILING_WHITESPACE
  )
  if(NOT result EQUAL 0)
    message(
        FATAL_ERROR "Command failed (${result}): ${cmd}\n\nOutput:\n${output}"
    )
  endif()
endfunction()

# Check that 'lib' contains only 'archs' architectures (remove others).
function(install_universal_ios_keep_archs lib archs)
  install_universal_ios_get_real_archs("${lib}" real_archs)
  set(archs_to_remove ${real_archs})
  list(REMOVE_ITEM archs_to_remove ${archs})
  foreach(x ${archs_to_remove})
    install_universal_ios_remove_arch("${lib}" "${x}")
  endforeach()
endfunction()

function(install_universal_ios_detect_sdks this_sdk_var corr_sdk_var)
  cmake_policy(SET CMP0057 NEW)

  set(this_sdk "$ENV{PLATFORM_NAME}")
  if("${this_sdk}" STREQUAL "")
    message(FATAL_ERROR "Environment variable PLATFORM_NAME is empty")
  endif()

  set(all_platforms "$ENV{SUPPORTED_PLATFORMS}")
  if("${all_platforms}" STREQUAL "")
    message(FATAL_ERROR "Environment variable SUPPORTED_PLATFORMS is empty")
  endif()

  separate_arguments(all_platforms)
  if(NOT this_sdk IN_LIST all_platforms)
    message(FATAL_ERROR "`${this_sdk}` not found in `${all_platforms}`")
  endif()

  list(REMOVE_ITEM all_platforms "" "${this_sdk}")
  list(LENGTH all_platforms all_platforms_length)
  if(NOT all_platforms_length EQUAL 1)
    message(FATAL_ERROR "Expected one element: ${all_platforms}")
  endif()

  set(${this_sdk_var} "${this_sdk}" PARENT_SCOPE)
  set(${corr_sdk_var} "${all_platforms}" PARENT_SCOPE)
endfunction()

# Create universal library for the given target.
#
# Preconditions:
#  * Library already installed to ${destination} directory
#    for the ${PLATFORM_NAME} platform
#
# This function will:
#  * Run build for the lacking platform,
#    i.e. opposite to the ${PLATFORM_NAME}
#  * Fuse both libraries by running `lipo -create ${src} ${dst} -output ${dst}`
#     src: library that was just built
#     dst: installed library
function(install_universal_ios_library target destination)
  if("${target}" STREQUAL "")
    message(FATAL_ERROR "`target` is empty")
  endif()

  if("${destination}" STREQUAL "")
    message(FATAL_ERROR "`destination` is empty")
  endif()

  if(NOT IS_ABSOLUTE "${destination}")
    message(FATAL_ERROR "`destination` is not absolute: ${destination}")
  endif()

  if(NOT IS_DIRECTORY "${destination}")
    message(FATAL_ERROR "`destination` is no directory: ${destination}")
  endif()

  if(NOT EXISTS "${destination}")
    message(FATAL_ERROR "`destination` not exists: ${destination}")
  endif()

  if("${CMAKE_BINARY_DIR}" STREQUAL "")
    message(FATAL_ERROR "`CMAKE_BINARY_DIR` is empty")
  endif()

  if(NOT IS_DIRECTORY "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR "Is not a directory: ${CMAKE_BINARY_DIR}")
  endif()

  if(NOT EXISTS "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR "Not exists: ${CMAKE_BINARY_DIR}")
  endif()

  if("${CMAKE_INSTALL_CONFIG_NAME}" STREQUAL "")
    message(FATAL_ERROR "CMAKE_INSTALL_CONFIG_NAME is empty")
  endif()

  set(cmd xcrun -f lipo)
  execute_process(
      COMMAND ${cmd}
      RESULT_VARIABLE result
      OUTPUT_VARIABLE output
      ERROR_VARIABLE output
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_STRIP_TRAILING_WHITESPACE
  )
  if(NOT result EQUAL 0)
    message(
        FATAL_ERROR "Command failed (${result}): ${cmd}\n\nOutput:\n${output}"
    )
  endif()
  set(_lipo_path ${output})

  set(CURRENT_CONFIG "${CMAKE_INSTALL_CONFIG_NAME}")
  set(CURRENT_TARGET "${target}")

  install_universal_ios_message("Target: ${CURRENT_TARGET}")
  install_universal_ios_message("Config: ${CURRENT_CONFIG}")
  install_universal_ios_message("Destination: ${destination}")

  # Get SDKs
  install_universal_ios_detect_sdks(this_sdk corr_sdk)

  # Get architectures of the target
  install_universal_ios_get_valid_archs("${corr_sdk}" corr_valid_archs)
  install_universal_ios_get_valid_archs("${this_sdk}" this_valid_archs)

  # Return if there are no valid architectures for the SDK.
  # (note that library already installed)
  if("${corr_valid_archs}" STREQUAL "")
    install_universal_ios_message(
        "No architectures detected for `${corr_sdk}` (skip)"
    )
    return()
  endif()

  # Get location of the library in build directory
  install_universal_ios_get("${corr_sdk}" "CODESIGNING_FOLDER_PATH" src)

  # Library output name
  install_universal_ios_get("${corr_sdk}" "EXECUTABLE_NAME" corr_libname)
  install_universal_ios_get("${this_sdk}" "EXECUTABLE_NAME" this_libname)

  if("${corr_libname}" STREQUAL "${this_libname}")
    set(libname "${corr_libname}")
  else()
    message(FATAL_ERROR "Library names differs: ${corr_libname} ${this_libname}")
  endif()

  set(dst "${destination}/${libname}")

  install_universal_ios_build("${corr_sdk}")

  install_universal_ios_keep_archs("${src}" "${corr_valid_archs}")
  install_universal_ios_keep_archs("${dst}" "${this_valid_archs}")

  install_universal_ios_message("Current: ${dst}")
  install_universal_ios_message("Corresponding: ${src}")

  set(cmd "${_lipo_path}" -create ${src} ${dst} -output ${dst})

  execute_process(
      COMMAND ${cmd}
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      RESULT_VARIABLE result
  )

  if(NOT result EQUAL 0)
    message(FATAL_ERROR "Command failed: ${cmd}")
  endif()

  install_universal_ios_message("Install done: ${dst}")
endfunction()

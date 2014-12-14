cmake_minimum_required(VERSION 3.1)

set(CMAKE_OSX_SYSROOT macosx)

project(XcodePlatformFrameworks)

# detect Xcode version

execute_process(
  COMMAND xcodebuild -version
  OUTPUT_VARIABLE _stdout
  OUTPUT_STRIP_TRAILING_WHITESPACE
  ERROR_VARIABLE _stderr
  RESULT_VARIABLE _failed
  )

if(_failed)
  message(FATAL_ERROR "Error while running xcodebuild: ${_stderr}")
endif()

set(XCODE_VERSION_REGEX ".*Xcode +([0-9.]+).*")

if(NOT _stdout MATCHES ${XCODE_VERSION_REGEX})
  message(FATAL_ERROR "Cannot find Xcode version in ${_stdout}")
endif()

string(REGEX REPLACE "${XCODE_VERSION_REGEX}" "\\1" XCODE_VERSION ${_stdout})

message(STATUS "Xcode version: ${XCODE_VERSION}")

if(NOT XCODE_VERSION VERSION_LESS "5.0")
  find_library(XCTEST_LIBRARY XCTest)
  if(XCTEST_LIBRARY)
    message(STATUS "XCTest found: ${XCTEST_LIBRARY}")
  else()
    message(FATAL_ERROR "XCTest Framework not found.")
  endif()
endif()

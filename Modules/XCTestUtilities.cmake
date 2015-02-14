#.rst:
# XCTestUtilities
# ---------------
#
# Functions to help creating and executing XCTest bundles.
#
# An XCTest bundle is a CFBundle with a special product-type
# and bundle extension. For more information about XCTest visit
# the Mac Developer library at:
# http://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/testing_with_xcode/
#
# The following functions are provided by this module:
#
# ::
#
#    add_xctest
#    add_test_xctest
#
# ::
#
#   add_xctest(<target> <testee>)
#
# Create a XCTest bundle named <target> which will test the target
# <testee>. Supported target types for testee are Frameworks and
# App Bundles.
#
# ::
#
#   add_test_xctest(<target>)
#
# Add an XCTest bundle to the project to be run by :manual:`ctest(1)`.

#=============================================================================
# Copyright 2015 Gregor Jasny
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

function(add_xctest target testee)

  if(NOT CMAKE_OSX_SYSROOT)
    message(STATUS "Adding XCTest bundles requires CMAKE_OSX_SYSROOT to be set.")
  endif()

  # check that testee is a valid target type
  get_target_property(TESTEE_TYPE ${testee} TYPE)
  get_target_property(TESTEE_FRAMEWORK ${testee} FRAMEWORK)
  get_target_property(TESTEE_MACOSX_BUNDLE ${testee} MACOSX_BUNDLE)

  if(TESTEE_TYPE STREQUAL "SHARED_LIBRARY" AND TESTEE_FRAMEWORK)
    # found a framework
  elseif(TESTEE_TYPE STREQUAL "EXECUTABLE" AND TESTEE_MACOSX_BUNDLE)
    # found an app bundle
  else()
  	message(FATAL_ERROR "Testee ${testee} is of unsupported type: ${TESTEE_TYPE}")
  endif()

  add_library(${target} MODULE ${ARGN})

  set_target_properties(${target} PROPERTIES
    BUNDLE TRUE
    XCTEST TRUE)

  find_library(FOUNDATION_LIBRARY Foundation)
  if(NOT FOUNDATION_LIBRARY)
    message(STATUS "Could not find Foundation Framework.")
  endif()

  find_library(XCTEST_LIBRARY XCTest)
  if(NOT XCTEST_LIBRARY)
    message(STATUS "Could not find XCTest Framework.")
  endif()

  target_link_libraries(${target} PRIVATE ${FOUNDATION_LIBRARY} ${XCTEST_LIBRARY})

  if(TESTEE_TYPE STREQUAL "SHARED_LIBRARY" AND TESTEE_FRAMEWORK)
    target_link_libraries(${target} PRIVATE ${testee})

    # set rpath to find testee
    target_link_libraries(${target} PRIVATE "${CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG}$<TARGET_LINKER_FILE_DIR:${testee}>")
  elseif(TESTEE_TYPE STREQUAL "EXECUTABLE" AND TESTEE_MACOSX_BUNDLE)
    add_dependencies(${target} ${testee})
    if(XCODE)
      set_target_properties(${target} PROPERTIES
        XCODE_ATTRIBUTE_BUNDLE_LOADER "$(TEST_HOST)"
        XCODE_ATTRIBUTE_TEST_HOST "$<TARGET_FILE:${testee}>")
    else(XCODE)
      target_link_libraries(${target} PRIVATE "-bundle_loader $<TARGET_FILE:${testee}>")
    endif(XCODE)
  endif()
endfunction(add_xctest)

function(add_test_xctest target)
  get_target_property(TARGET_TYPE ${target} TYPE)
  get_target_property(TARGET_XCTEST ${target} XCTEST)

  if(NOT TARGET_TYPE STREQUAL "MODULE_LIBRARY" OR NOT TARGET_XCTEST)
  	message(FATAL_ERROR "Test ${target} is not a XCTest")
  endif()

  execute_process(
    COMMAND xcrun --find xctest
    OUTPUT_VARIABLE XCTEST_EXECUTABLE
    OUTPUT_STRIP_TRAILING_WHITESPACE)

  if(NOT XCTEST_EXECUTABLE)
    message(STATUS "Unable to finc xctest binary.")
  endif()

  add_test(
    NAME ${target}
    COMMAND ${XCTEST_EXECUTABLE} $<TARGET_LINKER_FILE_DIR:${target}>/../..)
endfunction(add_test_xctest)

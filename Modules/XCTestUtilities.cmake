#[=======================================================================[.rst:
XCTestUtilities
---------------

Functions to help creating and executing XCTest bundles.

An XCTest bundle is a CFBundle with a special product-type
and bundle extension. For more information about XCTest visit
the Mac Developer library at:
http://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/testing_with_xcode/

Module Functions
^^^^^^^^^^^^^^^^

.. command:: xctest_add_bundle

  The ``xctest_add_bundle`` function creates a XCTest bundle named
  <target> which will test the target <testee>. Supported target types
  for testee are Frameworks and App Bundles::

    xctest_add_bundle(
      <target>  # Name of the XCTest bundle
      <testee>  # Target name of the testee
      )

.. command:: xctest_add_test

  The ``xctest_add_test`` function adds an XCTest bundle to the
  project to be run by :manual:`ctest(1)`. The test will be named
  <name> and tests <bundle>::

    xctest_add_test(
      <name>    # Test name
      <bundle>  # Target name of XCTest bundle
      )

Module Variables
^^^^^^^^^^^^^^^^

The following variables are set by including this module:

.. variable:: XCTEST_EXECUTABLE

  The ``XCTEST_EXECUTABLE`` variable contains the path to the xctest
  command line tool used to execute XCTest bundles.

.. variable:: XCTEST_LIBRARY

  The ``XCTEST_LIBRARY`` variable contains the location of the XCTest
  Framework.

#]=======================================================================]

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

find_library(XCTEST_LIBRARY XCTest)
mark_as_advanced(XCTEST_LIBRARY)

execute_process(
  COMMAND xcrun --find xctest
  OUTPUT_VARIABLE _xcrun_out OUTPUT_STRIP_TRAILING_WHITESPACE
  ERROR_VARIABLE _xcrun_err)
if(_xcrun_out)
  set(XCTEST_EXECUTABLE "${_xcrun_out}" CACHE FILEPATH "xctest executable")
  mark_as_advanced(XCTEST_EXECUTABLE)
endif()

function(xctest_add_bundle target testee)
  if(NOT CMAKE_OSX_SYSROOT)
    message(FATAL_ERROR "Adding XCTest bundles requires CMAKE_OSX_SYSROOT to be set.")
  endif()

  # check that testee is a valid target type
  get_property(TESTEE_TYPE TARGET ${testee} PROPERTY TYPE)
  get_property(TESTEE_FRAMEWORK TARGET ${testee} PROPERTY FRAMEWORK)
  get_property(TESTEE_MACOSX_BUNDLE TARGET ${testee} PROPERTY MACOSX_BUNDLE)

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

  target_link_libraries(${target} PRIVATE "-framework Foundation")
  target_link_libraries(${target} PRIVATE ${XCTEST_LIBRARY})

  if(TESTEE_TYPE STREQUAL "SHARED_LIBRARY" AND TESTEE_FRAMEWORK)
    set_target_properties(${testee} PROPERTIES
      BUILD_WITH_INSTALL_RPATH TRUE
      INSTALL_NAME_DIR "@rpath")

    target_link_libraries(${target} PRIVATE ${testee})
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
endfunction(xctest_add_bundle)

function(xctest_add_test name bundle)
  get_property(TARGET_TYPE TARGET ${bundle} PROPERTY TYPE)
  get_property(TARGET_XCTEST TARGET ${bundle} PROPERTY XCTEST)

  if(NOT TARGET_TYPE STREQUAL "MODULE_LIBRARY" OR NOT TARGET_XCTEST)
  	message(FATAL_ERROR "Test ${bundle} is not a XCTest")
  endif()

  if(NOT XCTEST_EXECUTABLE)
    message(FATAL_ERROR "Unable to finc xctest binary.")
  endif()

  add_test(
    NAME ${name}
    COMMAND ${XCTEST_EXECUTABLE} $<TARGET_LINKER_FILE_DIR:${bundle}>/../..)
endfunction(xctest_add_test)

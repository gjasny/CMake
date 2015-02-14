function(add_xctest target testee)

  if(NOT CMAKE_OSX_SYSROOT)
    message(STATUS "Adding XCTest bundles requires CMAKE_OSX_SYSROOT to be set.")
  endif()

  # check that testee is a valid target type
  get_target_property(TESTEE_TYPE ${testee} TYPE)
  get_target_property(TESTEE_FRAMEWORK ${testee} FRAMEWORK)
  if(TESTEE_TYPE STREQUAL "SHARED_LIBRARY" AND TESTEE_FRAMEWORK)
    # found a framework
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

  target_link_libraries(${target} PRIVATE ${testee} ${FOUNDATION_LIBRARY} ${XCTEST_LIBRARY})

  # set rpath to find testee
  target_link_libraries(${target} PRIVATE "${CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG}$<TARGET_LINKER_FILE_DIR:${testee}>")
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
    NAME FrameworkExampleTests
    COMMAND ${XCTEST_EXECUTABLE} $<TARGET_LINKER_FILE_DIR:${target}>/../..)
endfunction(add_test_xctest)
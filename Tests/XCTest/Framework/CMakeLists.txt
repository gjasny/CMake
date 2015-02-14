cmake_minimum_required(VERSION 3.1)
 
set(CMAKE_OSX_SYSROOT macosx)

project(XCTestFramework)

enable_testing()

#find_library(APPKIT_LIBRARY AppKit)
find_library(FOUNDATION_LIBRARY Foundation)
find_library(XCTEST_LIBRARY XCTest)

# Framework

add_library(FrameworkExample SHARED
  FrameworkExample/FrameworkExample.c
  FrameworkExample/FrameworkExample.h
  FrameworkExample/Info.plist
  )

target_include_directories(FrameworkExample PUBLIC .)

set_target_properties(FrameworkExample PROPERTIES
  FRAMEWORK TRUE
  VERSION "1.0.0"
  SOVERSION "1.0.0"
  FRAMEWORK_VERSION "A"
  MACOSX_FRAMEWORK_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/FrameworkExample/Info.plist
  PUBLIC_HEADER FrameworkExample/FrameworkExample.h)

# XCTest for Framework

add_library(FrameworkExampleTests MODULE
  FrameworkExampleTests/FrameworkExampleTests.m
  FrameworkExampleTests/Info.plist)

target_link_libraries(FrameworkExampleTests PRIVATE FrameworkExample ${FOUNDATION_LIBRARY} ${XCTEST_LIBRARY})
 
set_target_properties(FrameworkExampleTests PROPERTIES
  BUNDLE TRUE
  XCTEST TRUE
  MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/FrameworkExampleTests/Info.plist
  )

target_link_libraries(FrameworkExampleTests PRIVATE "${CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG}$<TARGET_LINKER_FILE_DIR:FrameworkExample>")

execute_process(
  COMMAND xcrun --find xctest
  OUTPUT_VARIABLE XCTEST_EXECUTABLE
  OUTPUT_STRIP_TRAILING_WHITESPACE)

if(XCTEST_EXECUTABLE)
  add_test(
    NAME FrameworkExampleTests
    COMMAND ${XCTEST_EXECUTABLE} $<TARGET_LINKER_FILE_DIR:FrameworkExampleTests>/../..)
endif(XCTEST_EXECUTABLE)

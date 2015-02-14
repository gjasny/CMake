cmake_minimum_required(VERSION 3.1)

set(CMAKE_OSX_SYSROOT macosx)

project(XCTestFramework)

include(XCTestUtilities)

enable_testing()

# Framework

add_library(FrameworkExample SHARED
  FrameworkExample/FrameworkExample.c
  FrameworkExample/FrameworkExample.h
  FrameworkExample/Info.plist)

target_include_directories(FrameworkExample PUBLIC .)

set_target_properties(FrameworkExample PROPERTIES
  FRAMEWORK TRUE
  VERSION "1.0.0"
  SOVERSION "1.0.0"
  FRAMEWORK_VERSION "A"
  MACOSX_FRAMEWORK_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/FrameworkExample/Info.plist
  PUBLIC_HEADER FrameworkExample/FrameworkExample.h)

# XCTest for Framework

add_xctest(FrameworkExampleTests FrameworkExample
  FrameworkExampleTests/FrameworkExampleTests.m
  FrameworkExampleTests/Info.plist)
 
set_target_properties(FrameworkExampleTests PROPERTIES
  MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/FrameworkExampleTests/Info.plist
  )

add_test_xctest(FrameworkExampleTests)

cmake_minimum_required(VERSION 3.1)

set(CMAKE_OSX_SYSROOT macosx)

project(XCTestExamples)

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

# Cocoa App Bundle

add_executable(CocoaExample MACOSX_BUNDLE
  CocoaExample/main.m
  CocoaExample/AppDelegate.m
  CocoaExample/AppDelegate.h
  CocoaExample/MainMenu.xib
)

find_library(FOUNDATION_LIBRARY Foundation)
find_library(APPKIT_LIBRARY AppKit)
mark_as_advanced(FOUNDATION_LIBRARY APPKIT_LIBRARY)

target_link_libraries(CocoaExample PRIVATE ${FOUNDATION_LIBRARY} ${APPKIT_LIBRARY})

set_target_properties(CocoaExample PROPERTIES
  MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/CocoaExample/Info.plist
  RESOURCE "CocoaExample/MainMenu.xib")

# XCTest for Cocoa App Bundle

add_xctest(CocoaExampleTests CocoaExample
  CocoaExampleTests/CocoaExampleTests.m)

add_test_xctest(CocoaExampleTests)

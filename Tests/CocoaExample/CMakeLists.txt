cmake_minimum_required(VERSION 3.1)

project(CocoaExample)

if(NOT XCODE)
  message(FATAL_ERROR "Only Xcode Generator is currently supported.")
endif(NOT XCODE)

add_executable(CocoaExample MACOSX_BUNDLE
  CocoaExample/main.m
  CocoaExample/AppDelegate.m
  CocoaExample/AppDelegate.h
  CocoaExample/MainMenu.xib
)

target_link_libraries(CocoaExample "-framework Foundation" "-framework AppKit")

set_target_properties(CocoaExample PROPERTIES
  MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/CocoaExample/Info.plist.in
  RESOURCE "CocoaExample/MainMenu.xib")

add_library(CocoaExampleTest MODULE
  CocoaExampleTests/CocoaExampleTests.m
)

set_target_properties(CocoaExampleTest PROPERTIES
#  XCTEST TRUE
#  XCTEST_HOST CocoaExample
   BUNDLE TRUE
   BUNDLE_EXTENSION "xctest"
   CMAKE_XCODE_ATTRIBUTE_BUNDLE_LOADER "$(TEST_HOST)"
   CMAKE_XCODE_ATTRIBUTE_TEST_HOST "FooBar3000"
)

add_dependencies(CocoaExampleTest CocoaExample)

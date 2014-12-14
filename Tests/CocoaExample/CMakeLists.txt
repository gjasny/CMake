cmake_minimum_required(VERSION 3.1)

set(CMAKE_OSX_SYSROOT macosx)

project(CocoaExample)

find_library(APPKIT_LIBRARY AppKit)
find_library(FOUNDATION_LIBRARY Foundation)
find_library(XCTEST_LIBRARY XCTest)

add_executable(CocoaExample MACOSX_BUNDLE
  CocoaExample/main.m
  CocoaExample/AppDelegate.m
  CocoaExample/AppDelegate.h
  CocoaExample/MainMenu.xib
)

target_link_libraries(CocoaExample ${FOUNDATION_LIBRARY} ${APPKIT_LIBRARY})

set_target_properties(CocoaExample PROPERTIES
  MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/CocoaExample/Info.plist.in
  RESOURCE "CocoaExample/MainMenu.xib")

add_library(CocoaExampleTest MODULE
  CocoaExampleTests/CocoaExampleTests.m
)

target_link_libraries(CocoaExampleTest ${FOUNDATION_LIBRARY} ${XCTEST_LIBRARY})

set_target_properties(CocoaExampleTest PROPERTIES
  XCTEST TRUE
  XCTEST_HOST CocoaExample
)

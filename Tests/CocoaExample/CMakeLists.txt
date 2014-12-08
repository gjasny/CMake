cmake_minimum_required(VERSION 3.1)

project(CocoaExample)

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
  XCTEST TRUE
  XCTEST_HOST CocoaExample
)

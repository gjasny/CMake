cmake_minimum_required(VERSION 3.3)

project(XcodeInstallIOS)

set(CMAKE_OSX_SYSROOT iphoneos)
set(XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")

set(CMAKE_OSX_ARCHITECTURES "armv7;i386")
set(CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphoneos;-iphonesimulator")

add_library(foo STATIC foo.cpp)
install(TARGETS foo ARCHIVE DESTINATION lib)
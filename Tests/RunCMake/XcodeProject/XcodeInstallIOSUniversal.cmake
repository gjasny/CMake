cmake_minimum_required(VERSION 3.3)

project(XcodeInstallIOSUniversal CXX)

set(CMAKE_OSX_SYSROOT iphoneos)
set(XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")
set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "NO")

set(CMAKE_OSX_ARCHITECTURES "armv7;arm64;i386;x86_64")

add_library(foo STATIC foo.cpp)
install(TARGETS foo ARCHIVE DESTINATION lib)

enable_language(C)

if(NOT XCODE_VERSION VERSION_LESS "5.0")
  find_library(XCTEST_LIBRARY XCTest)
  if(NOT XCTEST_LIBRARY)
    message(FATAL_ERROR "XCTest Framework not found.")
  endif()
endif()

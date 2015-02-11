set(expect "TEST_HOST = \"${RunCMake_TEST_BINARY_DIR}/.*/some\"")
file(STRINGS ${RunCMake_TEST_BINARY_DIR}/XcodeAttributeGenex.xcodeproj/project.pbxproj actual
     REGEX "TEST_HOST = .*;" LIMIT_COUNT 1)
if(NOT "${actual}" MATCHES "${expect}")
  message(SEND_ERROR "does not match '${expect}':\n ${actual}")
endif()

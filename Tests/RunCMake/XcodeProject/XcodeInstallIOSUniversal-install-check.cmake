execute_process(
  COMMAND xcrun otool -vf ${RunCMake_TEST_BINARY_DIR}/_install/lib/libfoo.a
  OUTPUT_VARIABLE otool_out
  ERROR_VARIABLE otool_err
  RESULT_VARIABLE otool_result)
if(NOT otool_result EQUAL "0")
  message(SEND_ERROR "Could not retrieve fat headers: ${otool_err}")
  return()
endif()

string(REGEX MATCHALL "architecture [^ \n\t]+" architectures ${otool_out})
string(REPLACE "architecture " "" actual "${architectures}")
list(SORT actual)

set(expected arm64 armv7 i386 x86_64)

if(NOT actual STREQUAL expected)
  message(SEND_ERROR
    "The actual library contains the architectures:\n ${actual} \n"
    "which do not match expected ones:\n ${expected} \n"
    "otool output:\n${otool_out}")
endif()

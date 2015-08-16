include(RunCMake)

if(FALSE)
run_cmake(XcodeFileType)
run_cmake(XcodeAttributeGenex)
run_cmake(XcodeAttributeGenexError)
run_cmake(XcodeObjectNeedsQuote)
if (NOT XCODE_VERSION VERSION_LESS 6)
  run_cmake(XcodePlatformFrameworks)
endif()
endif(FALSE)

# Use a single build tree for a few tests without cleaning.

foreach(test XcodeIosInstall XcodeIosInstallEffectivePlatforms)
    set(RunCMake_TEST_BINARY_DIR ${RunCMake_BINARY_DIR}/${test}-build)
    set(RunCMake_TEST_NO_CLEAN 1)
    set(RunCMake_TEST_OPTIONS "-DCMAKE_INSTALL_PREFIX:PATH=${RunCMake_TEST_BINARY_DIR}/ios_install")

    file(REMOVE_RECURSE "${RunCMake_TEST_BINARY_DIR}")
    file(MAKE_DIRECTORY "${RunCMake_TEST_BINARY_DIR}")

    run_cmake(${test})
    run_cmake_command(XcodeIosInstall-install ${CMAKE_COMMAND} --build . --target install)

    unset(RunCMake_TEST_BINARY_DIR)
    unset(RunCMake_TEST_NO_CLEAN)
    unset(RunCMake_TEST_OPTIONS)
endforeach()

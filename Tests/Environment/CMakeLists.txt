cmake_minimum_required(VERSION 2.6)
project(EnvironmentProj)

add_executable(Environment main.cxx)
set_property(TARGET Environment PROPERTY FOO Bar)

enable_testing()

add_test(Environment1 Environment)
add_test(Environment2 Environment)
add_test(EchoEnvironment1 ${CMAKE_COMMAND} -E environment)
add_test(EchoEnvironment2 ${CMAKE_COMMAND} -E environment)

# Make sure "CMAKE_ENV.*Happy Thanksgiving" is in the output of
# the "1" tests:
#
set_tests_properties(Environment1 EchoEnvironment1 PROPERTIES
  ENVIRONMENT "CMAKE_ENVIRONMENT_TEST_VAR=Happy Thanksgiving!"
  PASS_REGULAR_EXPRESSION "CMAKE_ENV.*Happy Thanksgiving"
)

# Make sure "CMAKE_ENV.*Happy Thanksgiving" is *NOT* in the output of
# the "2" tests:
#
set_tests_properties(Environment2 EchoEnvironment2 PROPERTIES
  FAIL_REGULAR_EXPRESSION "CMAKE_ENV.*Happy Thanksgiving"
)

# Test with generator expression
# Note: this requires a "new-style" add_test signature
#
add_test(NAME Environment3 COMMAND Environment)
add_test(NAME EchoEnvironment3 COMMAND ${CMAKE_COMMAND} -E environment)

set_tests_properties(Environment3 EchoEnvironment3 PROPERTIES
  ENVIRONMENT "CMAKE_ENVIRONMENT_TEST_VAR=$<TARGET_PROPERTY:Environment,FOO>"
  PASS_REGULAR_EXPRESSION "CMAKE_ENV.*Bar"
)

cmake_minimum_required(VERSION 3.1)

add_library(MyFramework SHARED dummy.c)
set_target_properties(MyFramework PROPERTIES FRAMEWORK TRUE)

add_library(MyBundle MODULE dummy.c)
set_target_properties(MyBundle PROPERTIES BUNDLE TRUE)


file(GENERATE
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/foo.txt"
  CONTENT "
Framework
TARGET_FILE_DIR $<TARGET_FILE_DIR:MyFramework>
TARGET_LINKER_FILE $<TARGET_LINKER_FILE:MyFramework>
TARGET_LINKER_FILE_DIR $<TARGET_LINKER_FILE_DIR:MyFramework>

Bundle
TARGET_FILE_DIR $<TARGET_FILE_DIR:MyBundle>
TARGET_LINKER_FILE $<TARGET_LINKER_FILE:MyBundle>
TARGET_LINKER_FILE_DIR $<TARGET_LINKER_FILE_DIR:MyBundle>
")

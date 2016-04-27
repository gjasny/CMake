PREFIX_FOLDERS
--------------

Use the PREFIX_FOLDERS property to prefix all targets with their associated
project name.

If set, CMake prefixes the target folder with the surrounding
variable:`PROJECT_NAME`. To be effective the :prop_gbl:`USE_FOLDERS` property
also needs to be enabled.

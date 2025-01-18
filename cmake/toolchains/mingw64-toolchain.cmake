
# Specify the target platform
set(CMAKE_SYSTEM_NAME "Windows")
set(CMAKE_SYSTEM_PROCESSOR "x86_64")
set(MINGW ON)

# Specify the cross compiler
set(CMAKE_C_COMPILER "x86_64-w64-mingw32-gcc")
set(CMAKE_CXX_COMPILER "x86_64-w64-mingw32-g++")

# Where is the target environment
list(APPEND CMAKE_FIND_ROOT_PATH "/usr/x86_64-w64-mingw32/sys-root/mingw")
# Search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# For libraries, headers and packages in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Specify flags
set(CMAKE_C_FLAGS_INIT "${CMAKE_C_FLAGS_INIT} -static")
set(CMAKE_CXX_FLAGS_INIT "${CMAKE_CXX_FLAGS_INIT} -static")

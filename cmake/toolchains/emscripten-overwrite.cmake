
# This is so that emscripten can create shared library (it doesn't by default)
# This is used with the emscripten toolchain file (provided by emsdk)
# This is to be used via CMAKE_PROJECT_INCLUDE

set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS ON)
set(CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS "-s SIDE_MODULE=1")
set(CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS "-s SIDE_MODULE=1")
set(CMAKE_STRIP OFF)

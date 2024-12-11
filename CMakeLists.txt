
cmake_minimum_required(VERSION 3.30)

project("gdextension_example_bullet_shower")

include("cmake/options.cmake")

# For some reason CMake puts the project's outputs in arbitrary directories
# So this is used to helps keeps things organised
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/lib")

add_subdirectory("src/")


cmake_minimum_required(VERSION 3.30)

include("cmake/pre_project.cmake")

project("gdextension_example_bullet_shower")

get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

include("cmake/options.cmake")

if(NOT PRESET_USED)
    message(NOTICE
        "Presets are recommended.\n"
        "Check out 'CMakePresets.json' for a list of pre-made presets.\n"
        "You might want to create a custom preset via 'CMakeUserPresets.json' for a custom build."
    )
endif()
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(WARNING
        "In-source builds are not recommended.\n"
        "You may want to delete 'CMakeCache.txt' and 'CMakeFiles/' first."
    )
endif()

# Make godot ignore the build directory
if(NOT UPPER_BUILD_FOLDER STREQUAL PROJECT_BINARY_DIR)
    file(TOUCH "${PROJECT_BINARY_DIR}/.gdignore")
endif()

add_subdirectory("src/")

include("cmake/install.cmake")

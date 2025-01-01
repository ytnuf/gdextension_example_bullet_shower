
cmake_minimum_required(VERSION 3.29)

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
if( (NOT CMAKE_BUILD_TYPE) AND (NOT IS_MULTICONFIG) )
    message(WARNING
        "CMAKE_BUILD_TYPE is not set.\n"
        "It is recommended to specify a build type, either Debug or Release.\n"
        "CMAKE_BUILD_TYPE will be defaulted to Debug."
    )
    set(CMAKE_BUILD_TYPE "Debug")
endif()

# Make godot ignore the build directory
file(TOUCH "${PROJECT_BINARY_DIR}/.gdignore")
file(MAKE_DIRECTORY "${SHARED_BUILD_FOLDER}/misc")
file(TOUCH "${SHARED_BUILD_FOLDER}/misc/.gdignore")


add_subdirectory("src/")

install(FILES "${PROJECT_SOURCE_DIR}/LICENSE.txt"
    DESTINATION "."
)

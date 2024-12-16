
cmake_minimum_required(VERSION 3.30)

project("gdextension_example_bullet_shower")

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
file(TOUCH "${PROJECT_BINARY_DIR}/.gdignore")

include("cmake/gdextension.cmake")

add_subdirectory("src/")

include("cmake/install.cmake")

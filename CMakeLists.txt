
cmake_minimum_required(VERSION 3.29)

include("cmake/pre_project.cmake")

project("gdextension_example_bullet_shower"
    LANGUAGES "CXX"
)

# Editor builds have the Debug builds flags but with TOOLS_ENABLED
set(CMAKE_C_FLAGS_EDITOR "${CMAKE_C_FLAGS_DEBUG} -DTOOLS_ENABLED" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_EDITOR "${CMAKE_CXX_FLAGS_DEBUG} -DTOOLS_ENABLED" CACHE STRING "" FORCE)
set(CMAKE_EXE_LINKER_FLAGS_EDITOR "${CMAKE_EXE_LINKER_FLAGS_DEBUG}" CACHE STRING "" FORCE)
set(CMAKE_STATIC_LINKER_FLAGS_EDITOR "${CMAKE_STATIC_LINKER_FLAGS_DEBUG}" CACHE STRING "" FORCE)
set(CMAKE_SHARED_LINKER_FLAGS_EDITOR "${CMAKE_SHARED_LINKER_FLAGS_DEBUG}" CACHE STRING "" FORCE)

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


add_subdirectory("src/")

install(FILES "${PROJECT_SOURCE_DIR}/LICENSE.txt"
    DESTINATION "."
)


# Typically we want godot to ignore the build directory
# However it may contain the .gdextension file (which cannot be ignored)
# As the build folder and the folder that contains the .gdextension are specified externally
block()
    # Check if the build directory is a ancestor of the .gdextension file
    set(GDEXTENSION_FILE_INSIDE_BUILD_DIRECTORY OFF)
    set(TO_SHARED_FOLDER "${CMAKE_SOURCE_DIR}")
    if(TO_SHARED_FOLDER STREQUAL PROJECT_BINARY_DIR)
        set(GDEXTENSION_FILE_INSIDE_BUILD_DIRECTORY ON)
    endif()
    string(REGEX REPLACE "/" ";" SHARED_BUILD_COMPONENT_LST "${SHARED_BUILD_FOLDER_REL}")
    foreach(SHARED_FOLDER_COMPONETNS IN LISTS SHARED_BUILD_COMPONENT_LST)
        set(TO_SHARED_FOLDER "${TO_SHARED_FOLDER}/${SHARED_FOLDER_COMPONETNS}")
        if(TO_SHARED_FOLDER STREQUAL PROJECT_BINARY_DIR)
            set(GDEXTENSION_FILE_INSIDE_BUILD_DIRECTORY ON)
        endif()
    endforeach()
    # And add a .gdignore there if that's not the case
    if(NOT GDEXTENSION_FILE_INSIDE_BUILD_DIRECTORY)
        file(TOUCH "${PROJECT_BINARY_DIR}/.gdignore")
    endif()
endblock()
# Also a .gdignore file for the misc directory too
file(MAKE_DIRECTORY "${SHARED_BUILD_FOLDER_ABS}/misc")
file(TOUCH "${SHARED_BUILD_FOLDER_ABS}/misc/.gdignore")

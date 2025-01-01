
# These variables should be set by presets
option(USE_CCACHE "Use ccache if found" OFF)
option(USE_VCPKG "Fetch vcpkg if not found" ON)

set(SHARED_BUILD_FOLDER_REL "build/_shared" CACHE STRING "The relative folder that contains the .gdextension file and misc that are shared amongst build configurations")
set(SHARED_BUILD_FOLDER_ABS "${CMAKE_SOURCE_DIR}/${SHARED_BUILD_FOLDER_REL}")


# Note: CMAKE_TOOLCHAIN_FILE must be set before the project() call
function(obtain_vcpkg_)
    if(EXISTS "${CMAKE_TOOLCHAIN_FILE}")
        get_filename_component(TOOLCHAIN_FILENAME_ "${CMAKE_TOOLCHAIN_FILE}" NAME)
        if(TOOLCHAIN_FILENAME_ STREQUAL "vcpkg.cmake")
            set(IS_VCPKG_FOUND_ ON)
        else()
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_TOOLCHAIN_FILE}" CACHE FILEPATH "Toolchain file to be used alongside vcpkg")
        endif()
    endif()
    if(NOT IS_VCPKG_FOUND_)
        set(PATH_TO_VCPKG_ "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
        if(NOT EXISTS "${PATH_TO_VCPKG_}")
            message(STATUS "Cannot find vcpkg, falling back to FetchContent")
            include("FetchContent")
            set(FETCHED_VCPKG_DIR_ "${SHARED_BUILD_FOLDER_ABS}/misc/vcpkg")
            FetchContent_Populate("vcpkg"
                GIT_REPOSITORY "https://github.com/microsoft/vcpkg.git"
                GIT_TAG        "master"
                SOURCE_DIR     "${FETCHED_VCPKG_DIR_}"
            )
            if(WIN32)
                execute_process(COMMAND "${FETCHED_VCPKG_DIR_}/bootstrap-vcpkg.bat" "-disableMetrics")
            else()
                execute_process(COMMAND "${FETCHED_VCPKG_DIR_}/bootstrap-vcpkg.sh" "-disableMetrics")
            endif()
            set(PATH_TO_VCPKG_ "${FETCHED_VCPKG_DIR_}/scripts/buildsystems/vcpkg.cmake")
        endif()
        set(CMAKE_TOOLCHAIN_FILE "${PATH_TO_VCPKG_}" CACHE FILEPATH "Use vcpkg as the toolchain" FORCE)
    endif()
endfunction()

if(USE_VCPKG)
    obtain_vcpkg_()
endif()


# Note that CMAKE_<LANG>_COMPILER_LAUNCHER would need to set before the project() call
if(USE_CCACHE)
    find_program(CCACHE_PROGRAM ccache)
    if(CCACHE_PROGRAM)
        # Get version information
        execute_process(
            COMMAND "${CCACHE_PROGRAM}" "--version"
            OUTPUT_VARIABLE CCACHE_VERSION
        )
        string(REGEX MATCH "[^\r\n]*" CCACHE_VERSION "${CCACHE_VERSION}")

        message(STATUS "Using ccache: ${CCACHE_PROGRAM} (${CCACHE_VERSION})")

        # Turn on ccache for all targets
        set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
        set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    else()
        message(WARNING "Unable to find ccache")
    endif()
endif()


# These variables should be set by presets
option(USE_VCPKG "Fetch vcpkg if not found" ON)
set(UPPER_BUILD_FOLDER "${CMAKE_SOURCE_DIR}/build" CACHE PATH "The shared folder that contains the various configurations build folders")

# Note: CMAKE_TOOLCHAIN_FILE must be set before the project() call
function(obtain_vcpkg)
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
            set(FETCHED_VCPKG_DIR "${UPPER_BUILD_FOLDER}/fetched/vcpkg")
            FetchContent_Populate("vcpkg"
                GIT_REPOSITORY "https://github.com/microsoft/vcpkg.git"
                GIT_TAG        "master"
                SOURCE_DIR     "${FETCHED_VCPKG_DIR}"
            )
            file(TOUCH "${UPPER_BUILD_FOLDER}/fetched/.gdignore")
            if(WIN32)
                execute_process(COMMAND "${FETCHED_VCPKG_DIR}/bootstrap-vcpkg.bat" "-disableMetrics")
            else()
                execute_process(COMMAND "${FETCHED_VCPKG_DIR}/bootstrap-vcpkg.sh" "-disableMetrics")
            endif()
            set(PATH_TO_VCPKG_ "${FETCHED_VCPKG_DIR}/scripts/buildsystems/vcpkg.cmake")
        endif()
        set(CMAKE_TOOLCHAIN_FILE "${PATH_TO_VCPKG_}" CACHE FILEPATH "Use vcpkg as the toolchain" FORCE)
    endif()
endfunction()

if(USE_VCPKG)
    obtain_vcpkg()
endif()


# Generates the .gdextension file
# This is for the following reasons
# 1: To allow out-source builds
# Since .gdextension files point to the build output, it effectively harcodes the location
# Generating them prevents the hard-coding
# 2. To allow different configurations to target the same feature set (e.g. they differ by compiler)
# .gdxtension files only allow one library per feature set
# This prevents e.g. having a clang and gcc build for linux.x86_64.debug feature set
# Generating them allows .gdextension to point to the latest configuration

function(generate_gdextension_file TARGET_NAME)
    if(NOT TARGET_NAME)
        message(FATAL_ERROR "_generate_gdextension_file: target hasn't been set")
    endif()
    set(BUILD_GDEXTENSION "${UPPER_BUILD_FOLDER}/${TARGET_NAME}.gdextension")
    set(INSTALL_GDEXTENSION "${UPPER_BUILD_FOLDER}/.install.${TARGET_NAME}.gdextension")

    if( ALWAYS_RECREATE_GDEXTENSION_FILE OR (NOT EXISTS "${BUILD_GDEXTENSION}") OR (NOT EXISTS "${INSTALL_GDEXTENSION}") )
        message(VERBOSE "Creating a .gdextension file for ${TARGET_NAME}")
        set(ARGS_OPTIONS)
        set(ARGS_ONEVALUE "GDEXTENSION_ENTRY_SYMBOL" "GDEXTENSION_VERSION_MINIMUM" "GDEXTENSION_VERSION_MAXIMUM")
        set(ARGS_MULTIVALUE "SUPPORTED_PLAFORMS")
        cmake_parse_arguments(PARSE_ARGV 1 "arg"
            "${ARGS_OPTIONS}" "${ARGS_ONEVALUE}" "${ARGS_MULTIVALUE}"
        )
        if(NOT arg_GDEXTENSION_ENTRY_SYMBOL)
            message(FATAL_ERROR "_generate_gdextension_file: GDEXTENSION_ENTRY_SYMBOL must be specified")
        endif()
        if(NOT arg_GDEXTENSION_VERSION_MINIMUM)
            message(FATAL_ERROR "_generate_gdextension_file: GDEXTENSION_VERSION_MINIMUM must be specified")
        endif()
        if(NOT arg_GDEXTENSION_VERSION_MAXIMUM)
            set(arg_GDEXTENSION_VERSION_MAXIMUM "${arg_GDEXTENSION_VERSION_MINIMUM}")
        endif()

        foreach(PLATFORM IN LISTS arg_SUPPORTED_PLAFORMS)
            if(PLATFORM MATCHES "^linux")
                set(OUTPUT_SUFFIX ".so")
            elseif(PLATFORM MATCHES "^windows")
                set(OUTPUT_SUFFIX ".dll")
            endif()
            set(RELEASE_PATH "${PLATFORM}.release = \"res://addons/${PROJECT_NAME}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}${PROJECT_NAME}.${PLATFORM}${OUTPUT_SUFFIX}\"")
            set(DEBUG_PATH "${PLATFORM}.debug = \"res://addons/${PROJECT_NAME}/lib/${CMAKE_SHARED_LIBRARY_PREFIX}${PROJECT_NAME}.${PLATFORM}.d${OUTPUT_SUFFIX}\"")
            set(LIBRARY_PATH_LST "${LIBRARY_PATH_LST}${RELEASE_PATH}\n${DEBUG_PATH}\n")
        endforeach()

        file(WRITE "${INSTALL_GDEXTENSION}"
            "[configuration]\n"
            "entry_symbol = \"${arg_GDEXTENSION_ENTRY_SYMBOL}\"\n"
            "compatibility_minimum = \"${arg_GDEXTENSION_VERSION_MINIMUM}\"\n"
            "compatibility_maximum = \"${arg_GDEXTENSION_VERSION_MAXIMUM}\"\n"
        )
        file(COPY_FILE "${INSTALL_GDEXTENSION}" "${BUILD_GDEXTENSION}" INPUT_MAY_BE_RECENT)
        file(APPEND "${INSTALL_GDEXTENSION}"
            "reloadable = false\n"
            "\n"
            "[libraries]\n"
            "${LIBRARY_PATH_LST}"
        )
        file(APPEND "${BUILD_GDEXTENSION}"
            "reloadable = true\n"
            "\n"
            "[libraries]\n"
            "${LIBRARY_PATH_LST}"
        )
    endif()

    _gdextension_generate_library_path("${TARGET_NAME}" "${INSTALL_GDEXTENSION}" "res://addons/${PROJECT_NAME}/lib")
    get_target_property(LIB_DIR "${TARGET_NAME}" LIBRARY_OUTPUT_DIRECTORY)
    if(NOT LIB_DIR)
        get_property(LIB_DIR GLOBAL PROPERTY LIBRARY_OUTPUT_DIRECTORY)
    endif()
    _gdextension_generate_library_path("${TARGET_NAME}" "${BUILD_GDEXTENSION}" "${LIB_DIR}")
endfunction()


function(_gdextension_generate_library_path TARGET_NAME GDEXTENSION_FILENAME LIB_DIR)
    file(STRINGS "${GDEXTENSION_FILENAME}" GDEXTENSION_CONFIG)
    if(IS_MULTICONFIG)
        string(TOLOWER "${CMAKE_CONFIGURATION_TYPES}" LOWERCASE_CONFIG_LST)
    else()
        string(TOLOWER "${CMAKE_BUILD_TYPE}" LOWERCASE_CONFIG_LST)
    endif()
    string(TOLOWER "${CMAKE_SYSTEM_NAME}.${CMAKE_SYSTEM_PROCESSOR}" PLATFORM)

    foreach(LOWERCASE_BUILD_TYPE IN LISTS LOWERCASE_CONFIG_LST)
        set(FEATURE_TAG "${PLATFORM}.${LOWERCASE_BUILD_TYPE}")
        if(LOWERCASE_BUILD_TYPE STREQUAL "debug")
            get_target_property(DEBUG_POSTFIX "${TARGET_NAME}" CMAKE_DEBUG_POSTFIX)
        endif()
        foreach(CFG_LINE IN LISTS GDEXTENSION_CONFIG)
            if(CFG_LINE MATCHES "^${FEATURE_TAG}")
                list(REMOVE_ITEM GDEXTENSION_CONFIG "${CFG_LINE}")
                break()
            endif()
        endforeach()

        get_target_property(LIB_PREFIX "${TARGET_NAME}" PREFIX)
        if(NOT LIB_PREFIX)
            set(LIB_PREFIX "${CMAKE_SHARED_LIBRARY_PREFIX}")
        endif()
        get_target_property(LIB_SUFFIX "${TARGET_NAME}" SUFFIX)
        if(NOT LIB_SUFFIX)
            set(LIB_SUFFIX "${CMAKE_SHARED_LIBRARY_SUFFIX}")
        endif()
        get_target_property(LIB_NAME "${TARGET_NAME}" LIBRARY_OUTPUT_NAME)
        if(NOT LIB_NAME)
            get_target_property(LIB_NAME "${TARGET_NAME}" OUTPUT_NAME)
            if(NOT LIB_NAME)
                set(LIB_NAME "${PROJECT_NAME}")
            endif()
        endif()
        get_target_property(DEBUG_POSTFIX "${TARGET_NAME}" DEBUG_POSTFIX)
        if(NOT DEBUG_POSTFIX)
            message(AUTHOR_WARNING "DEBUG_POSTFIX property is not set for ${TARGET_NAME}")
            set(DEBUG_POSTFIX)
        endif()

        set(FULL_LIBRARY_NAME "${LIB_DIR}/${LIB_PREFIX}${LIB_NAME}${DEBUG_POSTFIX}${LIB_SUFFIX}")
        list(APPEND GDEXTENSION_CONFIG "${FEATURE_TAG} = \"${FULL_LIBRARY_NAME}\"")
    endforeach()

    string(REGEX REPLACE ";" "\n" GDEXTENSION_CONFIG "${GDEXTENSION_CONFIG}")
    file(WRITE "${GDEXTENSION_FILENAME}" "${GDEXTENSION_CONFIG}\n")
endfunction()

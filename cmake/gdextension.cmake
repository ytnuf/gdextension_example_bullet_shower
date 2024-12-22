
# This function creates a gdextension library with its respective .gdextension file:
#   add_gdextension_library(<target_name_arg>
#       GDEXTENSION_ENTRY_SYMBOL <entry_symbol_arg>
#       GDEXTENSION_VERSION_MINIMUM <version_minimum_arg>
#       GDEXTENSION_VERSION_MAXIMUM <version_maximum_optional_arg>
#       SUPPORTED_PLAFORMS  <supported_platforms_arg_list>
#   )
# Where <arg> are to be filled in by the caller
function(add_gdextension_library TARGET_NAME)
    if(NOT TARGET_NAME)
        message(FATAL_ERROR "add_gdextension_library: target hasn't been set")
    endif()

    add_library("${TARGET_NAME}" MODULE)
    set_target_properties("${TARGET_NAME}" PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY    "$<1:${PROJECT_BINARY_DIR}/${LIBDIR}>"
        CXX_VISIBILITY_PRESET       "hidden"
        DEBUG_POSTFIX               "${DEBUG_SUFFIX}"
        LIBRARY_OUTPUT_DIRECTORY    "$<1:${PROJECT_BINARY_DIR}/${LIBDIR}>"
        OUTPUT_NAME                 "${TARGET_NAME}.${GDEXTENSION_TARGET_PLATFORM}"
        PREFIX                      "${CMAKE_SHARED_LIBRARY_PREFIX}"
        RUNTIME_OUTPUT_DIRECTORY    "$<1:${PROJECT_BINARY_DIR}/${LIBDIR}>"
        RUNTIME_OUTPUT_DIRECTORY    "$<1:${PROJECT_BINARY_DIR}/${LIBDIR}>"
        SUFFIX                      "${CMAKE_SHARED_LIBRARY_SUFFIX}"
        VISIBILITY_INLINES_HIDDEN   ON
    )

    set(BUILD_GDEXTENSION_FILE "${UPPER_BUILD_FOLDER}/${TARGET_NAME}.build.gdextension")
    set(INSTALL_GDEXTENSION_FILE "${UPPER_BUILD_FOLDER}/.install.${TARGET_NAME}.gdextension")
    if( (NOT EXISTS "${BUILD_GDEXTENSION_FILE}") OR (NOT EXISTS "${INSTALL_GDEXTENSION_FILE}") )
        _create_gdextension_file(${ARGV})
    endif()

    _gdextension_regenerate_library_path("${TARGET_NAME}" "${BUILD_GDEXTENSION_FILE}" "${PROJECT_BINARY_DIR}/${LIBDIR}")
    _gdextension_regenerate_library_path("${TARGET_NAME}" "${INSTALL_GDEXTENSION_FILE}" "res://addons/${PROJECT_NAME}/${LIBDIR}")
endfunction()

# Initial creation of the .gdextension file
function(_create_gdextension_file TARGET_NAME)
    message(VERBOSE "Creating a .gdextension file for ${TARGET_NAME}")

    # Parse and validate the arguments of add_gdextension_library
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
        message(STATUS "_generate_gdextension_file, GDEXTENSION_VERSION_MAXIMUM will be set to GDEXTENSION_VERSION_MINIMUM")
        set(arg_GDEXTENSION_VERSION_MAXIMUM "${arg_GDEXTENSION_VERSION_MINIMUM}")
    endif()

    # Create the configuration section of the gdextension configuration
    string(CONCAT CONFIGURATION_SECTION
        "[configuration]\n"
        "entry_symbol = \"${arg_GDEXTENSION_ENTRY_SYMBOL}\"\n"
        "compatibility_minimum = \"${arg_GDEXTENSION_VERSION_MINIMUM}\"\n"
        "compatibility_maximum = \"${arg_GDEXTENSION_VERSION_MAXIMUM}\"\n"
    )

    # Create the default library section of the gdextension configuration
    set(LIBRARY_SECTION "[libraries]\n")
    foreach(PLATFORM IN LISTS arg_SUPPORTED_PLAFORMS)
        if(PLATFORM MATCHES "^linux")
            set(OUTPUT_SUFFIX ".so")
        elseif(PLATFORM MATCHES "^windows")
            set(OUTPUT_SUFFIX ".dll")
        endif()
        set(RELEASE_PATH "${PLATFORM}.release = \"res://addons/${PROJECT_NAME}/${LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}${PROJECT_NAME}.${PLATFORM}${OUTPUT_SUFFIX}\"")
        set(DEBUG_PATH "${PLATFORM}.debug = \"res://addons/${PROJECT_NAME}/${LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}${PROJECT_NAME}.${PLATFORM}${DEBUG_SUFFIX}${OUTPUT_SUFFIX}\"")
        set(LIBRARY_SECTION "${LIBRARY_SECTION}${RELEASE_PATH}\n${DEBUG_PATH}\n")
    endforeach()

    # Create the gdextension files
    # One of them is used for development (BUILD_GDEXTENSION_FILE)
    # The other is to be installed to the addons folder (INSTALL_GDEXTENSION_FILE)
    # They differ in reloadable configuration
    set(BUILD_GDEXTENSION_FILE "${UPPER_BUILD_FOLDER}/${TARGET_NAME}.build.gdextension")
    set(INSTALL_GDEXTENSION_FILE "${UPPER_BUILD_FOLDER}/.install.${TARGET_NAME}.gdextension")
    file(WRITE "${BUILD_GDEXTENSION_FILE}" "${CONFIGURATION_SECTION}")
    file(APPEND "${BUILD_GDEXTENSION_FILE}" "reloadable=true\n")
    file(APPEND "${BUILD_GDEXTENSION_FILE}" "${LIBRARY_SECTION}")
    file(WRITE "${INSTALL_GDEXTENSION_FILE}" "${CONFIGURATION_SECTION}")
    file(APPEND "${INSTALL_GDEXTENSION_FILE}" "reloadable=false\n")
    file(APPEND "${INSTALL_GDEXTENSION_FILE}" "${LIBRARY_SECTION}")
endfunction()

# This regenerates the library path in the .gdextension during configration
function(_gdextension_regenerate_library_path TARGET_NAME GDEXTENSION_FILENAME LIBRARY_PATH_DIR)
    # Put in contents of the gdextension file into a list of lines
    # (due to an annoying limitation of cmake lists, this doesn't handle semi-colons well)
    file(STRINGS "${GDEXTENSION_FILENAME}" GDEXTENSION_CONFIG)
    # Handle the difference between single and multi config by putting the configs in a list
    if(IS_MULTICONFIG)
        string(TOLOWER "${CMAKE_CONFIGURATION_TYPES}" LOWERCASE_CONFIG_LST)
    else()
        string(TOLOWER "${CMAKE_BUILD_TYPE}" LOWERCASE_CONFIG_LST)
    endif()

    foreach(LOWERCASE_BUILD_TYPE IN LISTS LOWERCASE_CONFIG_LST)
        # Remove the line that contains the feature tag for this configuration
        set(FEATURE_TAG "${GDEXTENSION_TARGET_PLATFORM}.${LOWERCASE_BUILD_TYPE}")
        foreach(CFG_LINE IN LISTS GDEXTENSION_CONFIG)
            if(CFG_LINE MATCHES "^${FEATURE_TAG}")
                list(REMOVE_ITEM GDEXTENSION_CONFIG "${CFG_LINE}")
                break()
            endif()
        endforeach()

        # Obtain the library's filename from the target's properties
        get_target_property(PREFIX "${TARGET_NAME}" PREFIX)
        get_target_property(OUTPUT_NAME "${TARGET_NAME}" OUTPUT_NAME)
        get_target_property(SUFFIX "${TARGET_NAME}" SUFFIX)
        if(LOWERCASE_BUILD_TYPE STREQUAL "debug")
            get_target_property(DEBUG_POSTFIX "${TARGET_NAME}" DEBUG_POSTFIX)
        else()
            set(DEBUG_POSTFIX)
        endif()
        set(FULL_LIBRARY_NAME "${LIBRARY_PATH_DIR}/${PREFIX}${OUTPUT_NAME}${DEBUG_POSTFIX}${SUFFIX}")
        # Add the new filepath to the config list
        list(APPEND GDEXTENSION_CONFIG "${FEATURE_TAG} = \"${FULL_LIBRARY_NAME}\"")
    endforeach()
    
    # Write the new config list into the gdextension file
    string(REGEX REPLACE ";" "\n" GDEXTENSION_CONFIG "${GDEXTENSION_CONFIG}")
    file(WRITE "${GDEXTENSION_FILENAME}" "${GDEXTENSION_CONFIG}\n")
endfunction()

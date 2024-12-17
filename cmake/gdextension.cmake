
# Generates the .gdextension file
# This is for the following reasons
# 1: To allow out-source builds
# Since .gdextension files point to the build output, it effectively harcodes the location
# Generating them prevents the hard-coding
# 2. To allow different configurations to target the same feature set (e.g. they differ by compiler)
# .gdxtension files only allow one library per feature set
# This prevents e.g. having a clang and gcc build for linux.x86_64.debug feature set
# Generating them allows .gdextension to point to the latest configuration

set(GDEXTENSION_ENTRY_SYMBOL "bullet_shower_init")
set(GDEXTENSION_VERSION_MINIMUM "4.3")
set(GDEXTENSION_VERSION_MAXIMUM "${GDEXTENSION_VERSION_MINIMUM}")

set(GDEXTENSION_SUPPORTED_FEATURE_TAGS
    "windows.x86_64.debug"
    "windows.x86_64.release"
    "linux.x86_64.debug"
    "linux.x86_64.release"
)

function(create_gdextension_file GDEXTENSION_FILENAME)
    set(LIBRARY_INFO_LST)
    foreach(TAG IN LISTS GDEXTENSION_SUPPORTED_FEATURE_TAGS)
        if(TAG MATCHES "^linux")
            set(TAG_SUFFIX "so")
        elseif(TAG MATCHES "^windows")
            set(TAG_SUFFIX "dll")
        endif()
        if(TAG MATCHES ".*debug.*")
            set(DEBUG_SUFFIX ".d")
        endif()
        set(LIB_INFO "${TAG} = \"res://addons/${PROJECT_NAME}/lib${PROJECT_NAME}${DEBUG_SUFFIX}.${TAG_SUFFIX}\"")
        set(LIBRARY_INFO_LST "${LIBRARY_INFO_LST}${LIB_INFO}\n")
    endforeach()

    file(WRITE "${GDEXTENSION_FILENAME}"
        "[configuration]\n"
        "entry_symbol = \"${GDEXTENSION_ENTRY_SYMBOL}\"\n"
        "compatibility_minimum = \"${GDEXTENSION_VERSION_MINIMUM}\"\n"
        "compatibility_maximum = \"${GDEXTENSION_VERSION_MAXIMUM}\"\n"
        "reloadable = false\n"
        "\n"
        "[libraries]\n"
        "${LIBRARY_INFO_LST}"
    )
endfunction()

function(reconfigure_gdextension_file GDEXTENSION_FILENAME FEATURE_TAG)
    file(STRINGS "${GDEXTENSION_FILENAME}" GDEXTENSION_CONFIG)
    if(IS_MULTICONFIG)
        string(TOLOWER "${CMAKE_CONFIGURATION_TYPES}" LOWERCASE_CONFIG_LST)
    else()
        string(TOLOWER "${CMAKE_BUILD_TYPE}" LOWERCASE_CONFIG_LST)
    endif()
    foreach(LOWERCASE_BUILD_TYPE IN LISTS LOWERCASE_CONFIG_LST)
        set(FULL_FEATURE_TAG "${FEATURE_TAG}.${LOWERCASE_BUILD_TYPE}")
        set(DEBUG_SUFFIX)
        if(LOWERCASE_BUILD_TYPE STREQUAL "debug")
            set(DEBUG_SUFFIX ".d")
        endif()
        foreach(CFG_LINE IN LISTS GDEXTENSION_CONFIG)
            if(CFG_LINE MATCHES "^${FULL_FEATURE_TAG}")
                list(REMOVE_ITEM GDEXTENSION_CONFIG "${CFG_LINE}")
                break()
            endif()
        endforeach()
        list(APPEND GDEXTENSION_CONFIG "${FULL_FEATURE_TAG} = \"${PROJECT_BINARY_DIR}/lib/lib${PROJECT_NAME}.${FEATURE_TAG}${DEBUG_SUFFIX}${CMAKE_SHARED_LIBRARY_SUFFIX}\"")
        string(REGEX REPLACE ";" "\n" GDEXTENSION_CONFIG "${GDEXTENSION_CONFIG}")
        file(WRITE "${GDEXTENSION_FILENAME}" "${GDEXTENSION_CONFIG}")
    endforeach()
endfunction()

if(NOT EXISTS "${UPPER_BUILD_FOLDER}/${PROJECT_NAME}.build.gdextension")
    create_gdextension_file("${UPPER_BUILD_FOLDER}/.install.gdextension")
    create_gdextension_file("${UPPER_BUILD_FOLDER}/${PROJECT_NAME}.build.gdextension")
endif()

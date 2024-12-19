
add_library("${PROJECT_NAME}" SHARED)
target_sources("${PROJECT_NAME}" PRIVATE
    "bullets.cpp" "bullets.hpp"
    "register_types.cpp" "register_types.hpp"
)

target_compile_features("${PROJECT_NAME}" PRIVATE "cxx_std_17")

find_package("unofficial-godot-cpp" 4.3 REQUIRED CONFIG)

target_link_libraries("${PROJECT_NAME}"
    PRIVATE "project::options"
    PRIVATE "unofficial::godot::cpp"
)

# Name the output according to the feature flags
string(TOLOWER "${CMAKE_SYSTEM_NAME}.${CMAKE_SYSTEM_PROCESSOR}" FEATURE_FLAGS)
set_target_properties("${PROJECT_NAME}" PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY    "${PROJECT_BINARY_DIR}/lib"
    CXX_VISIBILITY_PRESET       "hidden"
    DEBUG_POSTFIX               ".d"
    LIBRARY_OUTPUT_DIRECTORY    "${PROJECT_BINARY_DIR}/lib"
    OUTPUT_NAME                 "${PROJECT_NAME}.${FEATURE_FLAGS}"
    RUNTIME_OUTPUT_DIRECTORY    "${PROJECT_BINARY_DIR}/lib"
    VISIBILITY_INLINES_HIDDEN   ON
)

generate_gdextension_file("${PROJECT_NAME}"
    GDEXTENSION_ENTRY_SYMBOL "bullet_shower_init"
    GDEXTENSION_VERSION_MINIMUM "4.3"
    GDEXTENSION_VERSION_MAXIMUM "4.3"
    SUPPORTED_PLAFORMS
        "linux.x86_64"
        "windows.x86_64"
)

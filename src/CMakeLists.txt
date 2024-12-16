
add_library("${PROJECT_NAME}" SHARED)
target_sources("${PROJECT_NAME}" PRIVATE
    "bullets.cpp" "bullets.hpp"
    "register_types.cpp" "register_types.hpp"
)

target_compile_features("${PROJECT_NAME}" PRIVATE "cxx_std_20")

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

# Kinda hacky, but the .gdextension file is annoyingly restrictive
reconfigure_gdextension_file("${UPPER_BUILD_FOLDER}/${PROJECT_NAME}.build.gdextension" "${FEATURE_FLAGS}")

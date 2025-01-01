
include("${PROJECT_SOURCE_DIR}/cmake/gdextension.cmake")

add_gdextension_library("${PROJECT_NAME}"
    GDEXTENSION_ENTRY_SYMBOL "bullet_shower_init"
    GDEXTENSION_VERSION_MINIMUM "4.3"
    GDEXTENSION_VERSION_MAXIMUM "4.3"
    SUPPORTED_PLAFORMS
        "linux.x86_64"
        "windows.x86_64"
        "web.wasm32"
        "android.arm64"
)

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

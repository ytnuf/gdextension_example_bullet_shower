
add_library("bullet-shower" SHARED)
target_sources("bullet-shower" PRIVATE
    "bullets.cpp" "bullets.hpp"
    "gdexample.cpp" "gdexample.hpp"
    "register_types.cpp" "register_types.hpp"
)

target_compile_features("bullet-shower" PRIVATE "cxx_std_20")

find_package("unofficial-godot-cpp" 4.3 REQUIRED CONFIG)


target_link_libraries("bullet-shower" 
    PRIVATE "bullet-shower::options"
    PRIVATE "unofficial::godot::cpp"
)

string(TOLOWER "bulletshower.${CMAKE_SYSTEM_NAME}.${CMAKE_SYSTEM_PROCESSOR}" "BULLET_SHOWER_OUTPUT_NAME")
set_target_properties("bullet-shower" PROPERTIES
    CXX_VISIBILITY_PRESET "hidden"
    DEBUG_POSTFIX ".d"
    OUTPUT_NAME "${BULLET_SHOWER_OUTPUT_NAME}"
    VISIBILITY_INLINES_HIDDEN ON
)

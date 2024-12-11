
add_library("bullet-shower" SHARED)
target_sources("bullet-shower" PRIVATE
    "gdexample.cpp" "gdexample.hpp"
    "register_types.cpp" "register_types.hpp"
)

target_compile_features("bullet-shower" PRIVATE "cxx_std_20")

find_package("unofficial-godot-cpp" 4.3 REQUIRED CONFIG)


target_link_libraries("bullet-shower" 
    PRIVATE "bullet-shower::options"
    PRIVATE "unofficial::godot::cpp"
)

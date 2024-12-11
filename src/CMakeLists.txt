
add_executable("example_exe")
target_sources("example_exe" PRIVATE
    "main.cpp"
)

target_compile_features("example_exe" PRIVATE "cxx_std_20")

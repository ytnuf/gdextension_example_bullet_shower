
option(ENABLE_ADDITIONAL_WARNINGS "Turn on addtional warnings" OFF)

# The sanitisers runtime libraries (e.g libubsan) may need to be installed
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    option(ENABLE_ADDRESS_SANTISER "Turn on sanitiser for memory errors, can noticeable slow down execution" OFF)
endif()
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    option(ENABLE_UNDEFINED_BEHAVIOUR_SANTISER "Turn on sanitiser for undefined behaviour" OFF)
endif()

option(ALWAYS_RECREATE_GDEXTENSION_FILE "Always recreate the .gdextension file from scratch on configuration" OFF)


add_library("project-options" INTERFACE)
add_library("project::options" ALIAS "project-options")


if(ENABLE_ADDITIONAL_WARNINGS)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        #GCC and Clang share these warnings
        target_compile_options("project-options" INTERFACE
            "-Wall"
            "-Wextra"
            "-Wpedantic"
            "-Warray-bounds"
            "-Wcast-align"
            "-Wconversion"
            "-Wdangling-else"
            "-Wimplicit-fallthrough"
            "-Wfloat-equal"
            "-Winit-self"
            "-Wmain"
            "-Wmissing-declarations"
            "-Wnon-virtual-dtor"
            "-Wparentheses"
            "-Wpointer-arith"
            "-Wredundant-decls"
            "-Wswitch"
            "-Wstrict-overflow"
            "-Wuninitialized"
            "-Wundef"
            "-Wunreachable-code"
            "-Wunused"

            "-Wno-float-conversion"
        )
        #Clang has additional warnings
        if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
            target_compile_options("project-options" INTERFACE
                "-Wcovered-switch-default"
                "-Wdeprecated"
                "-Wdeprecated-copy"
                "-Wdeprecated-copy-dtor"
                "-Wmissing-prototypes"
                "-Wmissing-variable-declarations"
                "-Wsuggest-destructor-override"
                "-Wnewline-eof"
                "-Wunused-exception-parameter"
            )
        endif()
    else()
        message(AUTHOR_WARNING "TODO: Add MSVC warnings")
    endif()
endif()


if(ENABLE_UNDEFINED_BEHAVIOUR_SANTISER)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        target_compile_options("project-options" INTERFACE "-fsanitize=undefined")
        target_link_options("project-options" INTERFACE "-fsanitize=undefined")
    endif()
endif()

if(ENABLE_ADDRESS_SANTISER)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        target_compile_options("project-options" INTERFACE "-fsanitize=address")
        target_link_options("project-options" INTERFACE "-fsanitize=address")
    else()
        message(AUTHOR_WARNING "TODO: Enable MSVC flags for ASAN")
    endif()
endif()

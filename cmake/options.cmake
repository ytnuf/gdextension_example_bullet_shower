
option(ENABLE_ADDITIONAL_WARNINGS "Turn on addtional warnings" OFF)

# The sanitisers runtime libraries (e.g libubsan) may need to be installed
option(ENABLE_ADDRESS_SANTISER "Turn on sanitiser for memory errors, can noticeable slow down execution (for GCC, Clang & MSVC)" OFF)
option(ENABLE_UNDEFINED_BEHAVIOUR_SANTISER "Turn on sanitiser for undefined behaviour (for GCC & Clang)" OFF)

string(TOLOWER "${CMAKE_SYSTEM_NAME}.${CMAKE_SYSTEM_PROCESSOR}" _GDEXTENSION_TARGET_PLATFORM_)
set(GDEXTENSION_TARGET_PLATFORM "${_GDEXTENSION_TARGET_PLATFORM_}" CACHE STRING "The platform this gdextension is targetted for")


add_library("project-options" INTERFACE)
add_library("project::options" ALIAS "project-options")


# Some helper variables to help with generator expression since they are notorious unreadable
set(COMPILER_IS_GCC "$<CXX_COMPILER_ID:GNU>")
set(COMPILER_IS_CLANG "$<OR:$<CXX_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:Clang>>")
set(COMPILER_IS_GCC_OR_CLANG "$<OR:${COMPILER_IS_GCC},${COMPILER_IS_CLANG}>")
set(COMPILER_IS_MSVC "$<CXX_COMPILER_ID:MSVC>")


if(ENABLE_ADDITIONAL_WARNINGS)
    target_compile_options("project-options" INTERFACE
        $<${COMPILER_IS_GCC_OR_CLANG}:
            # Basic warnings
            -Wall
            -Wextra
            -Wpedantic
            # Additional warnings
            -Warray-bounds
            -Wcast-align
            -Wconversion
            -Wdangling-else
            -Wimplicit-fallthrough
            -Wfloat-equal
            -Winit-self
            -Wmain
            -Wmissing-declarations
            -Wnon-virtual-dtor
            -Woverloaded-virtual
            -Wparentheses
            -Wpointer-arith
            -Wredundant-decls
            -Wshadow
            -Wswitch
            -Wstrict-overflow
            -Wuninitialized
            -Wundef
            -Wunreachable-code
            -Wunused
            -Wwrite-strings
            # Unfortunately gdextension code typically has a lot of float & double mixing
            -Wno-float-conversion
            -Wno-implicit-float-conversion
        >
        $<${COMPILER_IS_GCC}:
            -Walloc-zero
            -Wduplicated-branches
            -Wduplicated-cond
            -Wlogical-op
        >
        $<${COMPILER_IS_CLANG}:
            -Wcovered-switch-default
            -Wdeprecated
            -Wdeprecated-copy
            -Wdeprecated-copy-dtor
            -Wdocumentation
            -Wmissing-prototypes
            -Wmissing-variable-declarations
            -Wsuggest-destructor-override
            -Wnewline-eof
            -Wunused-exception-parameter
        >
    )
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        message(AUTHOR_WARNING "TODO: Add MSVC warning flags")
    endif()
endif()


if(ENABLE_UNDEFINED_BEHAVIOUR_SANTISER)
    target_compile_options("project-options" INTERFACE
        $<${COMPILER_IS_GCC_OR_CLANG}:
            -fsanitize=undefined
        >
    )
    target_link_options("project-options" INTERFACE
        $<${COMPILER_IS_GCC_OR_CLANG}:
            -fsanitize=undefined
        >
    )
endif()

if(ENABLE_ADDRESS_SANTISER)
    target_compile_options("project-options" INTERFACE
        $<${COMPILER_IS_GCC_OR_CLANG}:
            -fsanitize=address
        >
    )
    target_link_options("project-options" INTERFACE
        $<${COMPILER_IS_GCC_OR_CLANG}:
            -fsanitize=address
        >
    )
    if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        message(AUTHOR_WARNING "TODO: Enable MSVC flags for ASAN")
    endif()
endif()

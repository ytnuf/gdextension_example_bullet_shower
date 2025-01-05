
option(ENABLE_ADDITIONAL_WARNINGS "Turn on addtional warnings" OFF)

# The sanitisers runtime libraries (e.g libubsan) may need to be installed
option(ENABLE_ADDRESS_SANTISER "Turn on sanitiser for memory errors, can noticeable slow down execution (for GCC, Clang & MSVC)" OFF)
option(ENABLE_UNDEFINED_BEHAVIOUR_SANTISER "Turn on sanitiser for undefined behaviour (for GCC & Clang)" OFF)

string(TOLOWER "${CMAKE_SYSTEM_NAME}.${CMAKE_SYSTEM_PROCESSOR}" _GDEXTENSION_TARGET_PLATFORM_)
string(REGEX REPLACE "amd64" "x86_64" _GDEXTENSION_TARGET_PLATFORM_ "${_GDEXTENSION_TARGET_PLATFORM_}")
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
        $<${COMPILER_IS_MSVC}:
            /W4

            /w14062 # enumerator 'identifier' in switch of enum 'enumeration' is not handled
            /w14263 # 'function' : member function does not override any base class virtual member function
            /w14264 # 'virtual_function' : no override available for virtual member function from base 'class'; function is hidden
            /w14266 # 'function' : no override available for virtual member function from base 'type'; function is hidden
            /w14311 # 'variable' : pointer truncation from 'type' to 'type'
            /w14545 # expression before comma evaluates to a function which is missing an argument list
            /w14546 # function call before comma missing argument list
            /w14547 # 'operator' : operator before comma has no effect; expected operator with side-effect
            /w14548 # expression before comma has no effect; expected expression with side-effect
            /w14549 # 'operator' : operator before comma has no effect; did you intend 'operator'?
            /w14555 # expression has no effect; expected expression with side-effect
            /w14596 # 'name': illegal qualified name in member declaration
            /w14608 # 'union_member' has already been initialized by another union member in the initializer list, 'union_member'
            /w14946 # reinterpret_cast used between related classes: 'class1' and 'class2'

            /w24296 # 'operator' : expression is always false
            /w24388 # 'token' : signed/unsigned mismatch
            /w24822 # 'member' : local class member function does not have a body
            /w24841 # non-standard extension used: compound member designator used in offsetof
            /w24928 # illegal copy-initialization; more than one user-defined conversion has been implicitly applied
            /w25267 # definition of implicit copy constructor/assignment operator for 'type' is deprecated because it has a user-provided assignment operator/copy constructor

            /w35027 # 'type': move assignment operator was implicitly defined as deleted
            /w34619 # #pragma warning : there is no warning number 'number'
            /w34668 # 'symbol' is not defined as a preprocessor macro, replacing with '0' for 'directives'

            /w44640 # 'instance' : construction of local static object is not thread-safe
            /w44866 # 'file(line_number)' compiler may not enforce left-to-right evaluation order for call to operator_name
            /w44868 # 'file(line_number)' compiler may not enforce left-to-right evaluation order in braced initializer list

            /wd4244 # Unfortunately gdextension code typically has a lot of float & double mixing
        >
    )
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

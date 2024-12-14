
#ifndef HPP_REGISTERTYPES_
#define HPP_REGISTERTYPES_

#include <godot_cpp/core/class_db.hpp>

extern "C" GDExtensionBool GDE_EXPORT bullet_shower_init(
        GDExtensionInterfaceGetProcAddress p_get_proc_address,
        GDExtensionClassLibraryPtr p_library,
        GDExtensionInitialization* r_initialization);

#endif // ifndef HPP_REGISTERTYPES_

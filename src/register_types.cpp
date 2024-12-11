
#include "register_types.hpp"

#include "bullets.hpp"
#include "gdexample.hpp"

#include <gdextension_interface.h>

#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

using namespace godot;


namespace
{


void initialise_bullet_shower_module(ModuleInitializationLevel p_level) {
    if(p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
        return;

    GDREGISTER_CLASS(GDExample);
    GDREGISTER_CLASS(Bullets);
}

void uninitialise_bullet_shower_module(ModuleInitializationLevel p_level) {
    if(p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
        return;
}


} // namespace


// Initialization.
extern "C" GDE_EXPORT GDExtensionBool bullet_shower_init(
        GDExtensionInterfaceGetProcAddress p_get_proc_address,
        GDExtensionClassLibraryPtr p_library,
        GDExtensionInitialization* r_initialization)
{
    godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

    init_obj.register_initializer(initialise_bullet_shower_module);
    init_obj.register_terminator(uninitialise_bullet_shower_module);
    init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

    return init_obj.init();
}

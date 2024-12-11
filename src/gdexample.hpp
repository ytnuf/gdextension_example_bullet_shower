
#ifndef HPP_GDEXAMPLE_
#define HPP_GDEXAMPLE_

#include <godot_cpp/classes/sprite2d.hpp>



class GDExample : public godot::Sprite2D {
    GDCLASS(GDExample, godot::Sprite2D)

private:
    double time_passed = 0.0;

protected:
    static void _bind_methods();

public:
    void _process(double delta) override;
};

#endif // ifndef HPP_GDEXAMPLE_

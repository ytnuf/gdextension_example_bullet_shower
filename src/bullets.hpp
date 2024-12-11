
#ifndef HPP_BULLETS_
#define HPP_BULLETS_

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/ref.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/variant/rid.hpp>

#include <vector>

struct Bullet {
    godot::Vector2 position{};
    real_t speed = 1.0;
    godot::RID body{};
};

class Bullets : public godot::Node2D {
    GDCLASS(Bullets, godot::Node2D)

public:
    void _ready() override;
    void _process(double dt) override;
    void _physics_process(double dt) override;
    void _draw() override;
    void _exit_tree() override;

private:
    godot::Ref<godot::Texture2D> m_bullet_image;
    godot::RID m_shape;
    std::vector<Bullet> m_bullets;
};

#endif // ifndef HPP_BULLETS_

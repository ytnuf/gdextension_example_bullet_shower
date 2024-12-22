
#include "bullets.hpp"

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/physics_server2d.hpp>
#include <godot_cpp/classes/random_number_generator.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/world2d.hpp>
#include <godot_cpp/variant/rid.hpp>
#include <godot_cpp/variant/transform2d.hpp>
#include <godot_cpp/variant/vector2.hpp>

#include <random>


namespace
{


constexpr int BULLET_COUNT = 500;
constexpr int SPEED_MIN = 20;
constexpr int SPEED_MAX = 80;

double randf_range(double from, double to) {
    static auto s_rng = [](){
        godot::Ref<godot::RandomNumberGenerator> rng_;
        rng_.instantiate();
        std::random_device rd;
        const uint64_t seed = (static_cast<uint64_t>(rd() ) << 32) | rd();
        rng_->set_seed(seed);
        return rng_;
    }();
    return s_rng->randf_range(from, to);
}


} // namespace


void Bullets::_ready() {
    if(godot::Engine::get_singleton()->is_editor_hint() )
        return;

    auto& physics_server = *godot::PhysicsServer2D::get_singleton();
    m_texture = godot::ResourceLoader::get_singleton()->load("res://demo/bullet.png");

    m_shape = physics_server.circle_shape_create();
    // Set the collision shape's radius for each bullet in pixels.
    physics_server.shape_set_data(m_shape, 8);

    for(int i=0; i<BULLET_COUNT; ++i) {
        BulletData bullet;
        // Give each bullet its own random speed.
        bullet.speed = randf_range(SPEED_MIN, SPEED_MAX);
        bullet.body = physics_server.body_create();

        physics_server.body_set_space(bullet.body, get_world_2d()->get_space() );
        physics_server.body_add_shape(bullet.body, m_shape);
        //  Don't make bullets check collision with other bullets to improve performance.
        physics_server.body_set_collision_mask(bullet.body, 0);

        // Place bullets randomly on the viewport and move bullets outside the play area so that they fade in nicely.
        bullet.position = godot::Vector2(
            randf_range(0, get_viewport_rect().size.x) + get_viewport_rect().size.x,
            randf_range(0, get_viewport_rect().size.y)
        );

        godot::Transform2D transform2d;
        transform2d.set_origin(bullet.position);
        physics_server.body_set_state(bullet.body, godot::PhysicsServer2D::BODY_STATE_TRANSFORM, transform2d);

        m_bullet_lst.push_back(bullet);
    }
}

void Bullets::_process(double) {
    if(godot::Engine::get_singleton()->is_editor_hint() )
        return;

    queue_redraw();
}

void Bullets::_physics_process(double dt) {
    if(godot::Engine::get_singleton()->is_editor_hint() )
        return;

    auto& physics_server = *godot::PhysicsServer2D::get_singleton();
    godot::Transform2D transform2d;
    const auto offset = get_viewport_rect().size.x + 16.0;

    for(BulletData& bullet : m_bullet_lst) {
        bullet.position.x -= bullet.speed * dt;
        if(bullet.position.x < -16.0) {
            // Move the bullet back to the right when it left the screen.
            bullet.position.x = offset;
        }
        transform2d.set_origin(bullet.position);
        physics_server.body_set_state(bullet.body, godot::PhysicsServer2D::BODY_STATE_TRANSFORM, transform2d);
    }
}

void Bullets::_draw() {
    if(godot::Engine::get_singleton()->is_editor_hint() )
        return;

    const auto offset = -m_texture->get_size() * 0.5;
    for(const BulletData& bullet : m_bullet_lst)
        draw_texture(m_texture, bullet.position + offset);
}

void Bullets::_exit_tree() {
    if(godot::Engine::get_singleton()->is_editor_hint() )
        return;

    auto& physics_server = *godot::PhysicsServer2D::get_singleton();

    for(BulletData& bullet : m_bullet_lst)
        physics_server.free_rid(bullet.body);

    physics_server.free_rid(m_shape);
    m_bullet_lst.clear();
}


#include "bullets.hpp"

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/physics_server2d.hpp>
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

// Do note this is slightly different from gdscript's randf_range
// As the output range is half-open
// And a difference of random engine
real_t randf_range(real_t from, real_t to) {
    static std::default_random_engine rng{std::random_device{}()};
    std::uniform_real_distribution dist{from, to};
    return dist(rng);
}


} // namespace


void Bullets::_ready() {
    if(godot::Engine::get_singleton()->is_editor_hint() )
        return;

    auto& physics_server = *godot::PhysicsServer2D::get_singleton();

    m_shape = physics_server.circle_shape_create();
    // Set the collision shape's radius for each bullet in pixels.
    physics_server.shape_set_data(m_shape, 8);

    for(int i=0; i<BULLET_COUNT; ++i) {
        Bullet bullet;
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

        m_bullets.push_back(bullet);
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

    for(Bullet& bullet : m_bullets) {
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

    const auto offset = -m_bullet_image->get_size() * 0.5;
    for(const Bullet& bullet : m_bullets)
        draw_texture(m_bullet_image, bullet.position + offset);
}

void Bullets::_exit_tree() {
    if(godot::Engine::get_singleton()->is_editor_hint() )
        return;

    auto& physics_server = *godot::PhysicsServer2D::get_singleton();

    for(Bullet& bullet : m_bullets)
        physics_server.free_rid(bullet.body);

    physics_server.free_rid(m_shape);
    m_bullets.clear();
}


[[nodiscard]] godot::Ref<godot::Texture2D> Bullets::get_bullet_image() const {
    return m_bullet_image;
}

void Bullets::set_bullet_image(const godot::Ref<godot::Texture2D>& bullet_image_) {
    m_bullet_image = bullet_image_;
}

void Bullets::_bind_methods() {
    using namespace godot;

    ClassDB::bind_method(D_METHOD("set_bullet_image", "bullet_image_"), &Bullets::set_bullet_image);
    ClassDB::bind_method(D_METHOD("get_bullet_image"), &Bullets::get_bullet_image);
    ADD_PROPERTY(
        PropertyInfo(Variant::OBJECT, "bullet_image", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"),
        "set_bullet_image", "get_bullet_image"
    );
}

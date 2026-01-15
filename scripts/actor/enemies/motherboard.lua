require "scripts.util"
local Enemy             = require "scripts.actor.enemy"
local sounds            = require "data.sounds"
local images            = require "data.images"
local ElectricRays      = require "scripts.actor.enemies.electric_rays"
local ElectricBullet    = require "scripts.actor.enemies.electric_bullet"
local StateMachine      = require "scripts.state_machine"
local Timer             = require "scripts.timer"
local Segment           = require "scripts.math.segment"
local guns              = require "data.guns"
local ElectricArc       = require "scripts.actor.enemies.electric_arc"
local ChipperMinion     = require "scripts.actor.enemies.chipper_minion"
local Pendulum          = require "scripts.actor.enemies.pendulum"
local Chipper           = require "scripts.actor.enemies.chipper"
local BigBeelet         = require "scripts.actor.enemies.big_beelet"
local MotherboardButton = require "scripts.actor.enemies.motherboard_button"
local FlyingDung        = require "scripts.actor.enemies.flying_dung"
local Fly               = require "scripts.actor.enemies.fly"
local AnimatedSprite    = require "scripts.graphics.animated_sprite"
local UI                = require "scripts.ui.ui"
local Explosion         = require "scripts.actor.enemies.explosion"
local Sprite            = require "scripts.graphics.sprite"
local shaders           = require "data.shaders"
local Rect              = require "scripts.math.rect"

local Motherboard       = Enemy:inherit()

function Motherboard:init(x, y)
    self:init_enemy(x, y, images.motherboard, 24 * 16, 4)
    self.name = "motherboard"

    self.is_boss = true

    self.damage = 0
    self.spr_base_ox = 0
    self.spr_base_oy = 10
    self.spr:update_offset(self.spr_base_ox, self.spr_base_oy)

    -- Parameters
    self.follow_player = false
    self.max_life = 320
    self.life = self.max_life
    self.self_knockback_mult = 0
    self.is_pushable = false
    self.is_stompable = false
    self.gravity = 0
    self.is_killed_on_negative_life = false
    self.bullet_bounce_mode = BULLET_BOUNCE_MODE_NORMAL
    self.is_front = true
    self.is_affected_by_bounds = false
    self.is_affected_by_walls = false
    self.laser_count = 15

    -- Graphics
    self.flash_white_shader = shaders.multiply_color
    self.flash_white_shader:send("multColor", { 3, 3, 3, 1 })
    self.spr.white_flash_shader = self.flash_white_shader

    -- Rays and arcs
    self.rays = ElectricRays:new(self.mid_x, self.y + self.h + 24, {
        angle_speed = 0.2,
        n_rays = 7,
        spawn_state = "disabled",
    })
    game:new_actor(self.rays)

    -- timers
    self.state_timer = Timer:new(0)
    self.ray_timer = Timer:new(1.0)
    self.spawn_timer = Timer:new({ 0.5, 1.5 })
    self.new_button_timer = Timer:new(2.5)

    -- state management
    self.next_state = nil

    -- guns
    self.plug_gun_offset = 26
    self.burst_gun = guns.unlootable.W2BossBurst:new(self)
    self.turret_gun = guns.unlootable.W2BossTurretGun:new(self)

    -- plugs
    self.plug_y = self.h - 9
    self.plug_offset = 0
    self.plug_sprite = AnimatedSprite:new({
        rays = { {
            images.motherboard_plug_rays_1,
            images.motherboard_plug_rays_2,
        }, 0.05 },
        bullets = { {
            images.motherboard_plug_bullets,
        }, 0.05 },
    }, "rays", SPRITE_ANCHOR_CENTER_TOP, { frame_duration = 0.05 })

    -- shield
    self.shield_sprite = Sprite:new(images.motherboard_shield, SPRITE_ANCHOR_CENTER_TOP)

    -- enemies
    self.max_chippers = 6
    self.dung_damage = 20
    self.enemy_mix = {
        { Chipper,    1 },
        { Fly,        1 },
        { FlyingDung, 2 },
    }
    self.wave_enemies = {}
    self.can_spawn_button = true

    self.hard_mode = false
    self.score = 500

    local removeme_timer_mult = 1 --0.1
    self.state_machine = StateMachine:new({
        intro = {
            enter = function(state)
                state.intro_target_y = 3 * 16 + 4
                self.vy = 1000
            end,
            update = function(state, dt)
                if self.y > state.intro_target_y then
                    return "intro_linger"
                end
            end,
            exit = function(state)
                self.y = state.intro_target_y
                self.vy = 0

                for ix = self.x, self.x + self.w, 16 do
                    Particles:image(ix, self.y + self.h, 5,
                        { images.cabin_fragment_1, images.cabin_fragment_2, images.cabin_fragment_3 }, 4, nil, nil, nil,
                        {
                            vx1 = -50,
                            vx2 = 50,

                            vy1 = 80,
                            vy2 = 200,
                        })
                end

                game:screenshake(8)
                Input:vibrate_all(0.5, 1.0)
            end
        },
        intro_linger = {
            enter = function(state)
                self.state_timer:start(1.0)
            end,
            update = function(state, dt)
                local r = self.state_timer.time / self.state_timer.duration
                self.spr:update_offset(self.spr_base_ox + random_neighbor(r * 8), self.spr_base_oy + random_neighbor(r * 8))

                if self.state_timer:update(dt) then
                    self:randomize_button_position()
                    self:spawn_button()
                    self:transition_to_random_state()
                end
            end,
            exit = function(state)
                self.spr:update_offset(self.spr_base_ox, self.spr_base_oy)
                
                if not Options:get("skip_boss_intros") then
                    game.menu_manager:set_menu("w3_boss_intro")
                end
            end
        },

        chippers = {
            enter = function(state)
                local bounds = game.level.cabin_inner_rect
                self.chippers = {}

                local oy = 16 + random_range_int(0, 1) * 32
                for _, info in pairs({
                    { x = bounds.ax,      y = bounds.ay,      direction = 0 },
                    { x = bounds.bx - 12, y = bounds.ay + 32, direction = 2 } }
                ) do
                    local iy = info.y - oy
                    while iy < bounds.by do
                        if iy >= bounds.ay then
                            local delay = 0.7 + 0.05*(14 - iy/16)
                            if self.hard_mode then
                                delay = delay / 2
                            end

                            local chipper = ChipperMinion:new(info.x, iy, info.direction, ternary(self.hard_mode, 140, 100), delay)
                            table.insert(self.chippers, chipper)
                            game:new_actor(chipper)
                        end
                        iy = iy + 64
                    end
                end

                self.state_timer:start(2.8)
            end,

            update = function(state, dt)
                if self.state_timer:update(dt) then
                    self:transition_to_random_state()
                end
            end
        },

        pendulum = {
            enter = function(state)
                local bounds = game.level.cabin_inner_rect
                local n = ternary(self.hard_mode, 2, 1)

                local rand = random_range_int(0, 1)

                self.pendulums = {}
                for i = 1, n do
                    -- x, y, angle_range, radius, swing_speed, initial_angle_t
                    local p = Pendulum:new((bounds.ax + bounds.bx) / 2, bounds.ay, nil,
                        ternary(i == 1, 200, 150),
                        ternary(self.hard_mode, 2.5, 2),
                        ternary(i == 1, rand * pi, (1 - rand) * pi)
                    )
                    game:new_actor(p)
                    table.insert(self.pendulums, p)
                end

                self.state_timer:start(random_range(4.0, 8.0) * removeme_timer_mult)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    self:transition_to_random_state()
                end
            end,
            exit = function(state)
                for _, p in pairs(self.pendulums) do
                    p:remove()
                end
                self.pendulums = {}
            end,
        },

        big_chipper = {
            enter = function(state)
                local bounds = game.level.cabin_inner_rect
                local n = ternary(self.hard_mode, 4, 2)
                self.big_chippers = {}
                for _ = 1, n do
                    local chipper = BigBeelet:new((bounds.ax + bounds.bx) / 2, bounds.ay)
                    table.insert(self.big_chippers, chipper)
                    game:new_actor(chipper)
                end

                self.state_timer:start(random_range(4.0, 8.0) * removeme_timer_mult)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    self:transition_to_random_state()
                end
            end,
            exit = function(state)
                for _, c in pairs(self.big_chippers) do
                    c.score = 0
                    c.death_counts_for_fury_combo = false
                    c:kill()
                end
            end
        },

        ray_lasers = {
            enter = function(state)
                self.state_timer:start(random_range(4.0, 4.0) * removeme_timer_mult)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    self:transition_to_random_state()
                end
            end
        },

        _template = {
            enter = function(state)
                self.state_timer:start(random_range(4.0, 8.0) * removeme_timer_mult)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    self:transition_to_random_state()
                end
            end
        },

        transition = {
            enter = function(state)
                self.plug_offset = 16
                self.plug_offset_speed = 0
            end,
            update = function(state, dt)
                self.plug_offset_speed = self.plug_offset_speed - 400 * dt
                self.plug_offset = self.plug_offset + self.plug_offset_speed * dt
                if self.plug_offset < -6 then
                    self.plug_offset = 0
                    if self.next_state then
                        self.state_machine:set_state(self.next_state)
                    end
                end
            end,
        },

        mid_transition = {
            enter = function(state)
                self.hard_mode = true

                self.state_timer:start(2.0)

                self.new_button_timer:stop()

                self.button.score = 0
                self.button:kill()
                self.button = nil
            end,

            update = function(state, dt)
                self.spr:set_flashing_white(self.t % 0.2 < 0.1)

                self.spr:update_offset(self.spr_base_ox + random_neighbor(2), self.spr_base_oy + random_neighbor(2))
                if self.state_timer:update(dt) then
                    self:transition_to_random_state()
                end
            end,

            exit = function(state)
                self.spr:set_flashing_white(false)

                self.spr.color = COL_WHITE
                self.spr:update_offset(self.spr_base_ox, self.spr_base_oy)

                self.new_button_timer:start()
            end
        },

        dying = {
            enter = function(state)
                self.plug_sprite.is_visible = false

                self.dying_timer = Timer:new(4.0)
                self.explosion_timer = Timer:new(0.3)
                self.dying_timer:start()
                self.explosion_timer:start()

                self.new_button_timer:stop()
                self.button:remove()
                self.button = nil

                self.kill_on_next_frame = false
                self.is_immune_to_bullets = true

                self.can_spawn_button = false

                for _, a in pairs(game.actors) do
                    if a.name == "chipper_minion" then
                        a:kill()
                    end
                end
            end,

            update = function(state, dt)
                if self.explosion_timer:update(dt) then
                    local explosion = Explosion:new(random_range(self.x, self.x + self.w),
                        random_range(self.y - 42, self.y + self.h), { use_gun = false, particle_layer = PARTICLE_LAYER_HUD })
                    explosion.is_front = true
                    game:new_actor(explosion)
                    self.explosion_timer:start()
                end

                if random_range(0, 1) < 0.05 then
                    Particles:spark(self.x + self.w * random_range(0, 1), random_range(self.y - 42, self.y + self.h))
                end

                if self.dying_timer:update(dt) then
                    self.kill_on_next_frame = true
                    game:frameskip(10)
                end

                if self.kill_on_next_frame then
                    self.kill_on_next_frame = false
                    self:kill()

                    for r = 0, 1, 0.1 do
                        local explosion = Explosion:new(self.x + self.w * r, random_range(self.y - 42, self.y + self.h),
                            { use_gun = false })
                        explosion.is_front = true
                        game:new_actor(explosion)
                    end
                end

                self.spr:update_offset(self.spr_base_ox + random_neighbor(5), self.spr_base_oy + random_neighbor(5))
            end
        }
    }, "intro")

    self:set_bouncy(true)
end

function Motherboard:set_bouncy(val)
    Motherboard.super.set_bouncy(self, val)

    self.shield_sprite:set_visible(val)
end

function Motherboard:transition_to_random_state(force_state)
    local state = force_state
    if not state then
        local i = 0
        while i < 10 and (not state or state == self.state_machine.current_state_name) do
            state = random_sample {
                "chippers",
                "pendulum",
                "big_chipper",
            }
            i = i + 1
        end
    end

    self.next_state = state
    self.state_machine:set_state("transition")
end

function Motherboard:on_hit_flying_dung(dung)
    self:do_damage(self.dung_damage)
end

function Motherboard:update(dt)
    self:update_enemy(dt)

    self.state_machine:update(dt)
    if self.gun_directions then
        for gun_type, _ in pairs(self.gun_directions) do
            if not self.gun_directions[gun_type].a_lerp then
                self.gun_directions[gun_type].a_lerp = self.gun_directions[gun_type].a
            else
                self.gun_directions[gun_type].a_lerp = lerp_angle(self.gun_directions[gun_type].a_lerp,
                    self.gun_directions[gun_type].a, 0.2)
            end
        end
    end

    self:update_random_button(dt)

    if not self.has_done_midpoint_animation and self.life <= self.max_life / 2 then
        self.has_done_midpoint_animation = true
        self:transition_to_random_state("mid_transition")
    end
    self:do_low_hp_particles()
    
    self.shield_sprite:set_scale(nil, lerp(self.shield_sprite.sy, 1, 0.05))
end

function Motherboard:do_low_hp_particles()
    if self.life <= self.max_life / 2 then
        local p1 = ternary(self.life <= self.max_life / 4, 0.3, 1)
        local p2 = ternary(self.life <= self.max_life / 4, 0.04, 0.05)
        local gradient = {
            type = "gradient",
            COL_DARK_GRAY, COL_BLACK_BLUE
        }
        if self.life <= self.max_life / 4 then
            gradient = {
                type = "gradient",
                COL_WHITE, COL_YELLOW, COL_ORANGE, COL_DARK_RED, COL_DARK_GRAY, COL_BLACK_BLUE
            }
        end

        if random_range(0, 1) < p1 then
            Particles:push_layer(PARTICLE_LAYER_HUD)
            local params = {
                vx = 0, 
                vx_variation = 20, 
                vy = -50, 
                vy_variation = 10,
                min_spawn_delay = 0,
                max_spawn_delay = 0.1,
            }
            Particles:smoke_big(349, 40, gradient, 8, 1, params)
            Particles:smoke_big(170, 30, gradient, 8, 1, params)
            Particles:smoke_big(60, 40, gradient, 8, 1, params)
            if self.life <= self.max_life / 4 then
                Particles:smoke_big(117, 57, gradient, 8, 1, params)
                Particles:smoke_big(257, 25, gradient, 8, 1, params)
                Particles:smoke_big(430, 40, gradient, 8, 1, params)
            end
            Particles:pop_layer()
        end
        if random_range(0, 1) < p2 then
            Particles:spark(random_range(self.x, self.x + self.w), self.mid_y, 1)
        end
    end

    if self.life <= self.max_life / 4 then
        self.spr:update_offset(self.spr_base_ox + random_neighbor(1), self.spr_base_oy + random_neighbor(1))
    end
end

function Motherboard:spawn_button()
    local button = MotherboardButton:new(self.mid_x + self.button_position[1], self.y + self.button_position[2], self)
    game:new_actor(button)
    self.button = button
end

function Motherboard:randomize_button_position()
    self.button_position = random_sample {
        { -5 * BW,  0 },
        { 2 * BW,   0 },
        { -11 * BW, -6 },
        { 8 * BW,   -6 },
    }
end

function Motherboard:update_random_button(dt)
    if self.new_button_timer:update(dt) and self.can_spawn_button then
        self:spawn_button()
    end
end

function Motherboard:on_motherboard_button_pressed(button)
    self:randomize_button_position()
    self.new_button_timer:start()
end

function Motherboard:draw()
    self:draw_enemy()
    local x, y = self.x + 193 + self.spr.ox, self.y - 19 + self.spr.oy - 5
    UI:draw_icon_bar(x, y, 8 * (self.life / self.max_life), 8, 0, images.motherboard_led_on, images.motherboard_led_off,
        nil, 1)

    if self.gun_directions then
        for gun_name, gun_params in pairs(self.gun_directions) do
            draw_centered(images.motherboard_bullet_cannon, self.mid_x, self.y + self.plug_y + self.plug_gun_offset,
                gun_params.a_lerp)
        end
    end

    self.state_machine:draw()

    if DEBUG_MODE then
        -- print_outline(nil, nil, self.state_machine.current_state_name, self.x, self.y + 128)
    end
end

function Motherboard:on_death()
    if self.wave_enemies then
        for _, e in pairs(self.wave_enemies) do
            -- e.score = 0
            e:kill()
        end
    end

    self.rays:kill()

    game.level:add_fury(3.5)
end

function Motherboard:on_negative_life()
    if self.state_machine.current_state_name ~= "dying" then
        self.state_machine:set_state("dying")
    end
end

function Motherboard:on_bullet_bounced(bullet, col)
    self.shield_sprite:set_scale(nil, 1.5)
end

return Motherboard

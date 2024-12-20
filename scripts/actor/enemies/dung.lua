require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Larva = require "scripts.actor.enemies.larva"
local sounds = require "data.sounds"
local images = require "data.images"
local DungBeetle = require "scripts.actor.enemies.dung_beetle"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local DungProjectile = require "scripts.actor.enemies.dung_projectile"

local Dung = Enemy:inherit()

function Dung:init(x, y, spr, w, h)
    self:init_dung(x, y, spr, w, h)
end

function Dung:init_dung(x, y, spr, w, h)
    self:init_enemy(x, y, spr or images.dung, w or 24, h or 30)
    self.name = "dung"
    self.follow_player = false

    self.life = 80

    self.friction_x = 0.999
    self.speed_x = 1
    self.self_knockback_mult = 200

    self.is_stompable = false
    self.destroy_bullet_on_impact = false
    self.is_immune_to_bullets = true
    self.is_bouncy_to_bullets = true

    self.player_stationary_counters = {}
    self.player_stationary_detect_range = 64
    self.stationary_max_time = 2

    self.rot_mult = 0.06

    self.bounce_restitution = 0.4
    -- self.sound_damage = {"larva_damage1", "larva_damage2", "larva_damage3"}
    -- self.sound_death = "larva_death"
    -- self.anim_frame_len = 0.2
    -- self.anim_frames = {images.larva1, images.larva2}
    -- self.audio_delay = love.math.random(0.3, 1)

    self.state_timer = Timer:new(1)

    self.jump_speed = 500
    self.jump_flag = false

    self.state_machine = StateMachine:new({
        random = {
            enter = function(state)
            end,
            update = function(state, dt)
                return random_sample {
                    "chase", "bunny_hopping_telegraph", "throw_projectile"
                }
            end,
        },
        idle = {
            enter = function(state)
                self.friction_x = 0.7
                self.speed_x = 0
                self.bounce_restitution = 0.5
            end,
            on_damage = function(state)
                game:frameskip(15)
                game:screenshake(8)

                Audio:play_var("glass_fracture", 0.1, 1.1)
                Particles:image(self.rider.mid_x, self.rider.mid_y, 15, images.glass_shard, self.rider.h)
                self.state_machine:set_state("chase")
            end,
        },
        chase = {
            enter = function(state)
                self.friction_x = 0.999
                self.speed_x = 1
                self.bounce_restitution = 0.4

                self.chase_target = self:get_random_player()
                self.state_timer:start(random_range(4.0, 6.0))
            end,
            update = function(state, dt)
                self:chase_player(dt)

                if self.state_timer:update(dt) then
                    return "random"
                end
            end,
        },
        bunny_hopping_telegraph = {
            enter = function(state)
                -- self.spr:update_offset(random_neighbor(5), random_neighbor(5))
                -- self.rider.spr:update_offset(random_neighbor(5), random_neighbor(5))
                self.speed_x = 0
                self.state_timer:start(1.0)
            end,
            update = function(state, dt)
                self.spr:update_offset(random_neighbor(3), random_neighbor(3))
                self.rider.spr:update_offset(random_neighbor(3), random_neighbor(3))

                if self.state_timer:update(dt) then
                    return "bunny_hopping"
                end
            end
        },
        bunny_hopping = {
            enter = function(state)
                self.friction_x = 0.999
                self.speed_x = 1.5
                self.bounce_restitution = 0.5

                self.chase_target = self:get_random_player()
                self.jump_speed = 500

                self.bounces = 3
            end,
            update = function(state, dt)
                self:chase_player(dt)

                if self.is_grounded and self.bounces > 0 then
                    self.bounces = self.bounces - 1
                    self:jump()

                    if self.bounces <= 0 then
                        self.state_timer:start(3.0)
                    end
                end

                if self.state_timer:update(dt) then
                    return "random"
                end
            end,
            exit = function(state)
                self.spr:update_offset(0, 0)
                self.rider.spr:update_offset(0, 0)
            end,
            after_collision = function(state, col)
                if col.type ~= "cross" and self.bounces > 0 then
                    game:screenshake(4)
                end
            end
        },
        throw_projectile = {
            enter = function(state)
                self.friction_x = 0.8
                self.speed_x = 0
                self.bounce_restitution = 0.5

                self.state_timer:start(random_range(3.0, 5.0))
                self.projectile_timer = Timer:new(0.25)
                self.projectile_timer:start()
            end,
            update = function(state, dt)
                if self.projectile_timer:update(dt) then
                    local projectile = DungProjectile:new(self.rider.mid_x, self.rider.mid_y)
                    game:new_actor(projectile)
                    self.projectile_timer:start()
                end

                if self.state_timer:update(dt) then
                    return "random"
                end
            end,
        }
    }, "idle")

    self:add_constant_sound("ball_roll", "ball_roll")
    self:set_constant_sound_volume("ball_roll", 0)

    local beetle = DungBeetle:new(self.x, self.y - 16)
    game:new_actor(beetle)
    self:set_rider(beetle)

    self.z = 1
end

function Dung:update(dt)
    self:update_dung(dt)
end

function Dung:update_dung(dt)
    self.state_machine:update(dt)

    -- scotch
    if self.buffer_vx then
        self.vx = self.buffer_vx
        self.buffer_vx = nil
    end

    -- if self.jump_timer:update(dt) then
    --     self.jump_timer:start(random_range(2, 6))
    --     self:jump()
    -- end

    -- scotch
    if self.jump_flag then
        self.vy = -self.jump_speed
        self.jump_flag = false
    end

    self:update_enemy(dt)

    self.spr:set_rotation(self.spr.rot + self.vx * self.rot_mult * dt)

    if self.is_grounded and math.abs(self.vx) > 20 then
        Particles:dust(self.mid_x, self.y + self.h)
    end
    self:set_constant_sound_volume(math.abs(self.vx) / 400)
end

function Dung:on_damage()
    self.state_machine:_call("on_damage")
end

function Dung:chase_player(dt)
    if self.chase_target then
        self.vx = self.vx + sign0(self.chase_target.x - self.x) * self.speed_x
    end
end

function Dung:after_collision(col, other)
    self.state_machine:_call("after_collision", col)

    if col.type ~= "cross" then
        if col.normal.y == 0 then
            -- scotch scotch scotch
            self.buffer_vx = col.normal.x * math.abs(self.vx) * self.bounce_restitution
        end
    end
end

function Dung:jump()
    self.jump_flag = true
end

function Dung:draw()
    self:draw_enemy()

    if game.debug.colview_mode then
        rect_color({ 1, 0, 0, 0.4 }, "fill", self.mid_x - self.player_stationary_detect_range, 0,
            self.player_stationary_detect_range * 2, CANVAS_HEIGHT)
    end

    for _, player in pairs(game.players) do
        local c = self.player_stationary_counters[player.n]
        local s = (c ~= nil) and concat(round(c, 2)) or "?"
        -- print_centered_outline(nil, nil, s, player.mid_x, player.y - 8)
    end

    if self.state_timer then
        -- print_centered_outline(nil, nil, concat(self.telegraph_timer.time), self.mid_x, self.y - 32)
    end
end

return Dung

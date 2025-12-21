require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local WallWalker = require "scripts.actor.enemies.wall_walker"
local AnimatedSprite = require "scripts.graphics.animated_sprite"

local MoleBoss = WallWalker:inherit()

-- This ant will walk around corners, but this code will not work for "ledges".
-- Please look at the code of my old project (gameaweek1) if needed
function MoleBoss:init(x, y) 
    -- this hitbox is too big, but it works for walls
    -- self:init_enemy(x, y, images.mushroom_ant, 20, 20)
    MoleBoss.super.init(self, x, y, images.mole_boss_digging_1, 80, 80)
    self.name = "mole_boss"
    self.is_pushable = false
    self.is_boss = true

    self.spr = AnimatedSprite:new({
        digging = {
            {images.mole_boss_digging_1}, 0.1
        },
        telegraph = {
            {images.mole_boss_telegraph_1}, 0.1
        },
        flying = {
            {images.mole_boss_outside}, 0.1
        },
        rolling = {
            {images.mole_boss_roll}, 0.1
        },
    })
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)

    self:set_max_life(300)
    self.is_killed_on_stomp = false

    self.fly_speed = 350
    self.def_walk_speed = 300
    self.def_roll_speed = 300
    self.is_stompable = true
    self.score = 10

    self.sound_death = "sfx_enemy_kill_general_gore_{01-10}"
    self.sound_stomp = "sfx_enemy_kill_general_gore_{01-10}"

    self.state_timer = Timer:new()
    self.state_machine = StateMachine:new({
        dig_linger = {
            enter = function(state)
                self.walk_speed = 0
                self.damage = 0
                self.state_timer:start(0.5)
                self.spr:set_animation("digging")

                self.gravity = 0
                self.is_stompable = false
                self.is_wall_walking = true

                self.destroy_bullet_on_impact = false
                self.is_immune_to_bullets = true
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    return "dig"
                end
            end,
        },
        dig = {
            enter = function(state)
                self.walk_speed = self.def_walk_speed
                self.damage = 0
                self.walk_dir = state.override_walk_dir or random_sample{-1, 1}
                self.state_timer:start(random_range(0.5, 2))
                self.spr:set_animation("digging")

                self.is_stompable = false
                self.is_wall_walking = true

                self.destroy_bullet_on_impact = false
                self.is_immune_to_bullets = true

                state.override_walk_dir = nil                
            end,
            update = function(state, dt)
                local ox, oy = get_orthogonal(self.up_vect.x, self.up_vect.y, self.walk_dir)
                local x = self.mid_x - self.up_vect.x * self.h * 0.5 + ox * random_neighbor(self.w * 0.5) 
                local y = self.mid_y - self.up_vect.y * self.h * 0.5 + oy * random_neighbor(self.w * 0.5)
                Particles:image(x, y, 1, {images.dung_particle_1, images.dung_particle_2, images.dung_particle_3}, 8, nil, nil, nil, {
                    vx1 = -100,
                    vx2 = 100,
                    vy1 = -100,
                    vy2 = 100,
                })

                if self.state_timer:update(dt) then
                    return "telegraph"
                end
            end,
            exit = function(state)
                self.destroy_bullet_on_impact = true
                self.is_immune_to_bullets = false
            end
        },
        telegraph = {
            enter = function(state)
                self.walk_speed = 0
                self.damage = 0
                self.spr:update_offset(0, 0)
                self.spr:set_animation("telegraph")
                self.gravity = 0

                self.destroy_bullet_on_impact = false
                self.is_immune_to_bullets = true

                self.is_stompable = true
                self.state_timer:start(0.5)
            end,
            update = function(state, dt)
                self.spr:update_offset(random_polar(3), random_polar(3))
                
                if self.state_timer:update(dt) then
                    return "jump"
                end

                if random_range(0, 1) < 0.2 then
                    Particles:image(self.mid_x, self.mid_y, 1, {images.dung_particle_1, images.dung_particle_2, images.dung_particle_3}, 8)
                end
            end,
            draw = function(state)
                self.spr:update_offset(0, 0)
            end,
        },
        jump = {
            enter = function(state)
                self.is_wall_walking = false
                self.damage = 1
                self.vx = self.up_vect.x * self.fly_speed
                self.vy = self.up_vect.y * self.fly_speed

                self.destroy_bullet_on_impact = true
                self.is_immune_to_bullets = false

                self.is_stompable = true
                self.gravity = self.default_gravity/2
                self.spr:set_animation("flying")

                Particles:image(self.mid_x, self.mid_y, 20, {images.dung_particle_1, images.dung_particle_2, images.dung_particle_3}, 8)
            	Particles:jump_dust_kick(self.mid_x, self.mid_y, math.atan2(self.vy, self.vx) + pi/2)
            end,

            update = function(state, dt)
            end,

            on_collision = function(state, col, other)
                if col.type ~= "cross" and not (col.normal.x == 0 and col.normal.y == 1) then
                    self.is_on_wall = true
                    self.is_wall_walking = true
                    self.up_vect.x = col.normal.x
                    self.up_vect.y = col.normal.y

                    Input:vibrate_all(0.3, 0.7)
                    game:screenshake(7)

                    self.state_machine:set_state("linger")
                end
            end,
        },
        linger = {
            enter = function(state)
                self.is_stompable = true
                self.is_wall_walking = true
                self.walk_speed = 0
                self.state_timer:start(1.0)
                self.spr:set_animation("flying")

                self.destroy_bullet_on_impact = true
                self.is_immune_to_bullets = false

                Particles:image(self.mid_x, self.mid_y, 20, {images.dung_particle_1, images.dung_particle_2, images.dung_particle_3}, 8)
            end,
            update = function(state, dt)
                local r = 4 * clamp((self.state_timer.time-1) / (self.state_timer.duration-1), 0, 1)
                self.spr:update_offset(random_neighbor(r), random_neighbor(r))
                if self.state_timer:update(dt) then
                    return "walk_to_wall"
                end
            end,
            exit = function (state)
                self.spr:update_offset(0, 0)
            end
        },
        walk_to_wall = {
            enter = function(state)
                state.dir = ternary(self.mid_x < CANVAS_WIDTH/2, 1, -1)

                self.is_stompable = false
                self.is_wall_walking = false
                self.walk_speed = self.def_roll_speed
                self.unstompable_timer = Timer:new(0.5):start()
                self.state_timer:start(2.0)
                self.spr:set_animation("rolling")
            end,
            update = function(state, dt)
                self.vx = state.dir * self.walk_speed
                self.spr:set_rotation(self.spr.rot + (self.vx * dt) / (self.h * 0.5))
                if self.unstompable_timer:update(dt) then
                    self.is_stompable = false
                end
            end,
            on_collision = function(state, col, other)
                if col.type ~= "cross" and col.normal.y == 0 then
                    if col.normal.x == 1 then
                        state.override_walk_dir = -1 
                    else
                        state.override_walk_dir = 1 
                    end

                    self.state_machine:set_state("dig_linger")
                end
            end,
        },
        
        -- walk_around = {
        --     enter = function(state)
        --         self.walk_speed = 200
        --         self.damage = 0

        --         -- get random x target location that is far enough from enemy
        --         local tries = 10
        --         state.target_x = self.x
        --         while tries > 0 and math.abs(state.target_x - self.x) <= 64 do
        --             state.target_x = random_range(game.level.cabin_inner_rect.ax + 16, game.level.cabin_inner_rect.bx - self.w - 16)
        --             tries = tries - 1
        --         end
        --         state.dir_sign = sign(state.target_x - self.x)
        --         self.vx = state.dir_sign * self.walk_speed
        --         self.spr:set_animation("flying")

        --         self.gravity = self.default_gravity
        --         self.is_stompable = true
        --         self.is_wall_walking = false
        --     end,
        --     update = function(state, dt)
        --         if (state.dir_sign == 1 and self.x > state.target_x) or (state.dir_sign == -1 and self.x < state.target_x)then
        --             return "jump_in"
        --         end
        --     end,
        -- },
        -- jump_in = {
        --     enter = function(state)
        --         self.is_stompable = true
        --         self.vx = 0
        --         self.state_timer:start(0.4)
        --         self.spr:set_animation("flying")

        --         self.is_affected_by_walls = false
        --         self.is_affected_by_bounds = false
                
        --         self.gravity = self.default_gravity
        --         self.vy = -300
        --         state.original_y = self.y
        --         state.oy_threshold = 16
        --     end,
        --     update = function(state, dt)
        --         if self.y > state.original_y + state.oy_threshold then
        --             return "dig"
        --         end
        --     end,
        --     exit = function (state)
        --         self.is_affected_by_walls = true
        --         self.is_affected_by_bounds = true
        --     end
        -- },
    }, "dig")
end

function MoleBoss:update(dt)
    self.state_machine:update(dt)

    self.debug_values[1] = self.state_machine.current_state_name
    MoleBoss.super.update(self, dt)
end

function MoleBoss:on_collision(col, other)
    MoleBoss.super.on_collision(self, col, other)
    self.state_machine:_call("on_collision", col, other)
end

function MoleBoss:draw()
    MoleBoss.super.draw(self)
end

return MoleBoss
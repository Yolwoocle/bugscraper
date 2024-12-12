require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local ElectricRays = require "scripts.actor.enemies.electric_rays"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local Segment = require "scripts.math.segment"
local guns  = require "data.guns"

local W2boss = Enemy:inherit()

function W2boss:init(x, y)
    self:init_enemy(x,y, images.chipper_1, 32, 32)
    self.name = "w2_boss"  --removeme(dont actually)

    -- Parameters 
    self.life = 300
    self.is_flying = true
    self.gravity = 0
    self.follow_player = false
    self.self_knockback_mult = 0
    -- self.is_stompable = false
    self.stomps = math.huge
    self.damage_on_stomp = 5
    self.friction_y = self.friction_x

    -- Animation
    self.anim_frame_len = 0.2
    self.anim_frames = {images.chipper_1, images.chipper_2, images.chipper_3, images.chipper_2}
    self.normal_anim_frames = {images.chipper_1, images.chipper_2, images.chipper_3, images.chipper_2}
    self.attack_anim_frames = {images.chipper_attack_1, images.chipper_attack_2, images.chipper_attack_3, images.chipper_attack_2}
    self.spr:set_scale(2, 2)
	self.flip_mode = ENEMY_FLIP_MODE_MANUAL
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
    
    -- States
    --- Wander
    -- self.wander_timer = Timer:new({5.0, 8.0})
    self.wander_timer = Timer:new(1)
    self.wander_spawn_timer = Timer:new(3.0)
    self.player_detection_range = 256
    self.player_detection_width = 16
    
    --- Rays
    self.rays_telegraph_duration = 1.0
    self.rays_stay_duration = 1.5
    self.rays = ElectricRays:new(self.mid_x, self.mid_y, {
        n_rays = 9,
        angle_speed = 0,
    })
    self.rays:set_state("disabled")
    game:new_actor(self.rays)
    self.rays_activated_timer = Timer:new(3.0)

    --- Telegraph
    self.telegraph_timer = Timer:new(0.5)
    self.telegraph_source = Audio:get_sound("chipper_telegraph"):clone()
    self.telegraph_source:set_pitch(0.7)
    
    --- Attack
    self.attack_speed = 100
    self.attack_bounces = 12
    self.attack_bounces_counter = self.attack_bounces
    
    --- Post-attack
    self.post_attack_timer = Timer:new(0.5)

    self.direction = random_range(0, pi*2)
    self.direction_speed = random_sample({-1, 1}) * 3

    self.gun = guns.unlootable.W2BossGun:new(self)
    self.gun8 = guns.unlootable.W2boss8bullets:new(self)

    self.state_machine = StateMachine:new({
        wander = {
            enter = function(state)
                self.anim_frames = self.normal_anim_frames
                self.wander_spawn_timer:start()
                self.wander_timer:start()
                self.gun_target = self:get_random_player()

                self.rays:set_state("disabled")
            end,
            update = function(state, dt)
                self.rays:set_pos(self.mid_x, self.mid_y)
                self.rays:set_state("disabled")

                -- Shoot bullets
                self.gun:update(dt)
                if self.gun_target then
                    local dx, dy = get_direction_vector(self.mid_x, self.mid_y, self.gun_target.mid_x, self.gun_target.mid_y)
                    self.gun:shoot(dt, self, self.mid_x, self.mid_y, dx, dy)
                end

                local a = random_range(0, pi*2)
                self.gun:shoot(dt, self, self.mid_x, self.mid_y, math.cos(a), math.sin(a))

                -- Movement
                self.direction_speed = random_sample({-1, 1}) * 3
                if random_range(0, 1) < 1/10 then
                    self.direction_speed = -self.direction_speed
                end
                
                self.vx = self.vx + math.cos(self.direction) * self.speed
                self.vy = self.vy + math.sin(self.direction) * self.speed
                
                -- State management
                if self.wander_timer:update(dt) then
                    local r = random_sample{1, 2}
                    self.state_machine:set_state("telegraph")
                    -- if r == 1 then
                    --     self.state_machine:set_state("rays")
                    -- else
                    -- end
                end
            end,
        },
        rays = {
            enter = function()
                self.vx = 0
                self.vy = 0
                self.angle_speed = 3

                self.rays:start_activation_timer(self.rays_telegraph_duration)
                self.rays.angle = random_range(0, pi*2)
                self.rays_activated_timer:start(self.rays_telegraph_duration + self.rays_stay_duration)

                -- self.ray_target = self:get_random_player()
            end,
            update = function(state, dt)
                if self.rays.state == "telegraph" then
                    self.rays.angle_speed = 0.1
                else
                    -- self.rays.angle_speed = 0
                end
                
                if self.rays_activated_timer:update(dt) then
                    self.rays:set_state("disabled")
                    self.state_machine:set_state("wander")
                end
            end,
        },
        telegraph = {
            enter = function(state) 
                self.vx = 0
                self.vy = 0
                self.direction_speed = 0

                self.anim_frames = self.attack_anim_frames
                self.telegraph_timer:start()
                self.telegraph_source:play()

                local player = self:get_random_player()
                if player then
                    self.direction = math.atan2(player.mid_y - self.mid_y, player.mid_x - self.mid_x)
                end
            end,
            update = function(state, dt)
                if self.telegraph_timer:update(dt) then
                    self.state_machine:set_state("attack")
                end
            end
        },
        attack = {
            enter = function()
                self.anim_frames = self.attack_anim_frames
                self.attack_bounces_counter = self.attack_bounces
            end,
            update = function(state, dt)
                local a = self.direction
                self.vx = self.vx + math.cos(a) * self.attack_speed
                self.vy = self.vy + math.sin(a) * self.attack_speed

                self.gun8:update(dt)

                Particles:dust(self.mid_x, self.mid_y)
                Particles:static_image(random_sample{images.particle_bit_zero, images.particle_bit_one}, self.mid_x, self.mid_y, 0, 0.25)
            end,
            after_collision = function(state, col)
                if col.type == "cross" then
                    return
                end

                game:screenshake(3)
            	Input:vibrate_all(0.1, 0.45)

                self.attack_bounces_counter = math.max(0, self.attack_bounces_counter - 1)
                if self.attack_bounces_counter <= 0 then
                    self.state_machine:set_state("post_attack")
                end
            end,
        },
        post_attack = {
            enter = function(state)
                self.anim_frames = self.normal_anim_frames
                self.post_attack_timer:start()
                self.telegraph_source:stop()
            
				Audio:play_var("bullet_bounce_"..random_sample{"1","2"}, 0.2, 1.2)
                Audio:play_var("metal_impact", 0, 1)
                -- local s = "metalfootstep_0"..tostring(love.sume=0.5})

            end,
            update = function(state, dt)
                local r = 3 * self.post_attack_timer:get_time() / self.post_attack_timer:get_duration()
                self.spr:update_offset(random_neighbor(r), random_neighbor(r))

                if self.post_attack_timer:update(dt) then
                    self.state_machine:set_state("wander")
                end
            end,
        },
    }, "wander")

    self.rays:set_state("disabled")

end

function W2boss:detect_player_in_range()
    local detection_segment = Segment:new(self.mid_x, self.mid_y, self.mid_x + math.cos(self.direction)*600, self.mid_y + math.sin(self.direction)*600)
    self.detection_segment = detection_segment

    for _, p in pairs(game.players) do
        local coll = p:get_rect(self.player_detection_width):segment_intersection(detection_segment)
        if coll then
            return true
        end
    end
    return false
end

function W2boss:update(dt)
    self:update_enemy(dt)

    self.direction = self.direction + self.direction_speed*dt
    self.spr:set_rotation(self.direction)
    self.state_machine:update(dt)

    -- self.debug_values[1] = self.state_machine.current_state_name
    -- self.debug_values[2] = self.attack_bounces_counter
    self.debug_values[2] = concat(self.life,"❤")
end


function W2boss:after_collision(col, other)
    self.state_machine:_call("after_collision", col)
    if col.type ~= "cross" then
        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
        self.direction = math.atan2(new_vy, new_vx)

        local a = random_range(0, pi2)
        local dx, dy = math.cos(a), math.sin(a)
        self.gun8:shoot(0, self, self.mid_x, self.mid_y, dx, dy)
    end
end

function W2boss:draw()
    self:draw_enemy()
    -- if self.detection_segment then
    --     line_color(COL_RED, self.detection_segment.ax, self.detection_segment.ay, self.detection_segment.bx, self.detection_segment.by)
    -- end
end

return W2boss
require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local Segment = require "scripts.math.segment"
local guns  = require "data.guns"

local Chipper360 = Enemy:inherit()

function Chipper360:init(x, y)
    self:init_enemy(x,y, images.chipper_1, 12, 12)
    self.name = "todo_changeme"

    -- Parameters 
    self.life = 12
    self.is_flying = true
    self.gravity = 0
    self.follow_player = false
    self.self_knockback_mult = 0
    -- self.stomps = 1
    self.friction_y = self.friction_x

    -- Animation
    self.anim_frame_len = 0.2
    self.anim_frames = {images.chipper_1, images.chipper_2, images.chipper_3, images.chipper_2}
    self.normal_anim_frames = {images.chipper_1, images.chipper_2, images.chipper_3, images.chipper_2}
    self.attack_anim_frames = {images.chipper_attack_1, images.chipper_attack_2, images.chipper_attack_3, images.chipper_attack_2}
	self.flip_mode = ENEMY_FLIP_MODE_MANUAL
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
    
    -- States
    --- Wander
    self.wander_no_attack_timer = Timer:new(1.0)
    self.wander_spawn_timer = Timer:new(3.0)
    self.player_detection_range = 256
    self.player_detection_width = 16
    
    --- Telegraph
    self.telegraph_timer = Timer:new(0.5)
    self.telegraph_source = Audio:get_sound("chipper_telegraph"):clone()
    self.telegraph_source:set_pitch(0.7)
    
    --- Attack
    self.force_charge_flag = false
    self.attack_speed = 100
    self.attack_bounces = 5
    self.attack_bounces_counter = self.attack_bounces
    
    --- Post-attack
    self.post_attack_timer = Timer:new(0.5)

    self.direction = random_range(0, pi*2)
    self.direction_speed = random_sample{-1, 1} * 3

    self.state_machine = StateMachine:new({
        wander = {
            enter = function(state)
                self.anim_frames = self.normal_anim_frames
                self.wander_no_attack_timer:start(1.0)
                self.wander_spawn_timer:start()
                self:enter_wander()
            end,
            update = function(state, dt)
                self.direction_speed = random_sample({-1, 1}) * 3
                if random_range(0, 1) < 1/10 then
                    self.direction_speed = -self.direction_speed
                end
                
                self.vx = self.vx + math.cos(self.direction) * self.speed
                self.vy = self.vy + math.sin(self.direction) * self.speed
                
                self.wander_no_attack_timer:update(dt)
                if not self.wander_no_attack_timer.is_active then
                    local detected = self:detect_player_in_range()
                    if detected or self.force_charge_flag then
                        self.force_charge_flag = false
                        self.state_machine:set_state("telegraph")
                    end
                end
            end,
            after_collision = function(state, col)
                if col.type ~= "cross" then
                    self.wander_no_attack_timer:start(0.5)
                end
            end
        },
        telegraph = {
            enter = function(state) 
                self.vx = 0
                self.vy = 0
                self.direction_speed = 0

                self.anim_frames = self.attack_anim_frames
                self.telegraph_timer:start()
                self.telegraph_source:play()
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
end

function Chipper360:enter_wander()
end

function Chipper360:detect_player_in_range()
    local dx, dy = math.cos(self.direction), math.sin(self.direction)
    local detection_segment = Segment:new(
        self.mid_x + dx*self.player_detection_width, 
        self.mid_y + dy*self.player_detection_width, 
        self.mid_x + dx*600, 
        self.mid_y + dy*600)
    self.detection_segment = detection_segment

    for _, p in pairs(game.players) do
        local coll = p:get_rect(self.player_detection_width):segment_intersection(detection_segment)
        if coll then
            return true
        end
    end
    return false
end

function Chipper360:update(dt)
    self:update_enemy(dt)

    self.direction = self.direction + self.direction_speed*dt
    self.spr:set_rotation(lerp_angle(self.spr:get_rotation(), self.direction, 0.2))
    self.state_machine:update(dt)

    -- self.debug_values[2] = concat(self.life,"❤")
end


function Chipper360:after_collision(col, other)
    self.state_machine:_call("after_collision", col)
    if col.type ~= "cross" then
        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
        self.direction = math.atan2(new_vy, new_vx)
    end
end

function Chipper360:draw()
    self:draw_enemy()

    if game.debug.colview_mode and self.detection_segment then
        line_color(COL_RED, self.detection_segment.ax, self.detection_segment.ay, self.detection_segment.bx, self.detection_segment.by)
        rect_color(COL_RED, "line", self.detection_segment.ax - self.player_detection_width/2, self.detection_segment.ay - self.player_detection_width/2, self.player_detection_width, self.player_detection_width)
    end
end

return Chipper360
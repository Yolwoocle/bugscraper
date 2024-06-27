require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Timer = require "scripts.timer"
local StateMachine = require "scripts.state_machine"
local Rect = require "scripts.math.rect"
local sounds = require "data.sounds"
local images = require "data.images"

local Chipper = Enemy:inherit()
	
function Chipper:init(x, y, spr)
    self:init_fly(x, y)
end

function Chipper:init_fly(x, y, spr)
    self:init_enemy(x,y, spr or images.chipper_1)
    self.name = "chipper"
    self.is_flying = true
    self.life = 10
    self.follow_player = false
    --self.speed_y = 0--self.speed * 0.5
    
    self.speed = random_range(7,13) --10
    -- self.speed_x = self.speed
    -- self.speed_y = self.speed

    self.direction = random_range_int(0, 3)
    self.target_rot = self.spr.rot

    self.gravity = 0
    self.friction_y = self.friction_x

    self.anim_frame_len = 0.2
    self.anim_frames = {images.chipper_1, images.chipper_2, images.chipper_3, images.chipper_2}
    self.normal_anim_frames = {images.chipper_1, images.chipper_2, images.chipper_3, images.chipper_2}
    self.attack_anim_frames = {images.chipper_attack_1, images.chipper_attack_2, images.chipper_attack_3, images.chipper_attack_2}
	self.flip_mode = ENEMY_FLIP_MODE_MANUAL

    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
    self.min_walk_duration = 0.6
    self.max_walk_duration = 2.0
    self.turn_timer = Timer:new(self:get_random_walk_duration())
    self.turn_timer:start()
    
    self.wander_no_attack_timer = Timer:new(1.0)
    self.player_detection_range = 256
    self.player_detection_width = 16
    self.telegraph_timer = Timer:new(0.5)
    self.telegraph_source = Audio:get_sound("chipper_telegraph"):clone()
    self.attack_speed = 100
    self.post_attack_timer = Timer:new(1.0)

    self.state_machine = StateMachine:new({
        wander = {
            enter = function(state)
                self.anim_frames = self.normal_anim_frames
                self.wander_no_attack_timer:start()
            end,
            update = function(state, dt)
                if self.turn_timer:update(dt) then
                    self.turn_timer:set_duration(self:get_random_walk_duration())
                    self.turn_timer:start()
            
                    self.direction = (self.direction + random_sample({-1, 1})) % 4
                end
                
                self.vx = self.vx + math.cos(self.direction * pi/2) * self.speed
                self.vy = self.vy + math.sin(self.direction * pi/2) * self.speed
                
                self.target_rot = self.direction * pi/2
                
                self.wander_no_attack_timer:update(dt)
                if not self.wander_no_attack_timer.is_active then
                    local detected = self:detect_player_in_range()
                    if detected then
                        self.state_machine:set_state("telegraph")
                    end
                end
                -- self.state_machine:set_state("exploding")
            end,
        },
        telegraph = {
            enter = function(state) 
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
            end,
            update = function(state, dt)
                local a = self.direction * pi/2
                self.vx = self.vx + math.cos(a) * self.attack_speed
                self.vy = self.vy + math.sin(a) * self.attack_speed

                Particles:dust(self.mid_x, self.mid_y)
                Particles:static_image(random_sample{images.particle_bit_zero, images.particle_bit_one}, self.mid_x, self.mid_y, 0, 0.25)
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

function Chipper:update(dt)
    self:update_stink_bug(dt)
end

function Chipper:update_stink_bug(dt)
    self:update_enemy(dt)

    self.spr:set_rotation(lerp_angle(self.spr:get_rotation(), self.target_rot, 0.2))
    self.state_machine:update(dt)

    if random_range(0, 1) < 0.02 then
        -- Particles:word(self.mid_x, self.mid_y, random_sample{"0", "1"}, random_sample{COL_LIGHT_GREEN, COL_MID_GREEN})
    end
end

function Chipper:get_random_walk_duration()
    return random_range(self.min_walk_duration, self.max_walk_duration)
end

function Chipper:detect_player_in_range()
    -- for fuck's sake please use vectors i'm begging you
    local a = self.direction * pi/2
    local w = self.player_detection_width
    local r = self.player_detection_range
    local forward_x, forward_y = math.cos(a), math.sin(a)
    local side_x, side_y = math.cos(a + pi/2), math.sin(a + pi/2)

    local rect = Rect:new(
        self.mid_x + side_x*w, 
        self.mid_y + side_y*w, 
        self.mid_x - side_x*w + forward_x*r, 
        self.mid_y - side_y*w + forward_y*r
    )

    local intersects = false
    for _, player in pairs(game.players) do
        if rect:rectangle_intersection(Rect:new(player.x, player.y, player.x + player.w, player.y + player.h)) then
            intersects = true
            break
        end
    end
    self.vision_rect = rect

    return intersects
end

function Chipper:draw()
	self:draw_enemy()

    -- circle_color(COL_YELLOW, "fill", self.x, self.y, 10)
    if self.vision_rect and game.debug and game.debug.colview_mode then
        rect_color(COL_RED, "line", self.vision_rect.x, self.vision_rect.y, self.vision_rect.w, self.vision_rect.h)
    end
end

function Chipper:after_collision(col, other)
    -- Pong-like bounce
    if col.type ~= "cross" then
        -- Particles:smoke(col.touch.x, col.touch.y)

        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction * pi/2), math.sin(self.direction * pi/2), col.normal.x, col.normal.y)
        self.direction = math.floor(math.atan2(new_vy, new_vx) / (pi/2))

        if self.state_machine:in_state("attack") then
            self.state_machine:set_state("post_attack")
        end
    end
end

return Chipper
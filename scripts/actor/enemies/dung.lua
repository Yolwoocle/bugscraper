require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Larva = require "scripts.actor.enemies.larva"
local sounds = require "data.sounds"
local images = require "data.images"
local DungBeetle = require "scripts.actor.enemies.dung_beetle"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"

local Dung = Enemy:inherit()
	
function Dung:init(x, y, spr, w, h)
    self:init_dung(x, y, spr, w, h)
end

function Dung:init_dung(x, y, spr, w, h)
    self:init_enemy(x,y, spr or images.dung, w or 24, h or 30)
    self.name = "dung"
    self.follow_player = false
    
    self.life = 50

    self.friction_x = 0.999
    self.speed_x = 1
    self.self_knockback_mult = 200
    
    self.is_stompable = false
    self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true
    self.is_bouncy_to_bullets = true

    self.rot_mult = 0.06

    self.bounce_restitution = 0.4
    -- self.sound_damage = {"larva_damage1", "larva_damage2", "larva_damage3"}
    -- self.sound_death = "larva_death"
    -- self.anim_frame_len = 0.2
    -- self.anim_frames = {images.larva1, images.larva2}
    -- self.audio_delay = love.math.random(0.3, 1)

    self.jump_timer = Timer:new(5, { 
    })
    self.jump_timer:start()
    self.jump_speed = 600
    self.jump_flag = false

    self.state_machine = StateMachine:new({
        chase = {
            enter = function(state)
                self.chase_target = self:get_random_player()
            end,
            update = function(state, dt)
	            self.vx = self.vx + sign0(self.chase_target.x - self.x) * self.speed_x
                
            end,
        },
        jump = {
            update = function(state, dt)
                
            end,
        }
    }, "chase")

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

    -- -- scotch
    -- if self.jump_flag then
    --     self.vy = -self.jump_speed
    --     self.jump_flag = false
    -- end

    self:update_enemy(dt)

    self.spr:set_rotation(self.spr.rot + self.vx * self.rot_mult * dt)
    
    if self.is_grounded and math.abs(self.vx) > 20 then
        Particles:dust(self.mid_x, self.y + self.h)
    end
    self:set_constant_sound_volume(math.abs(self.vx) / 400)
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

-- function Dung:follow_nearest_player(dt)
-- 	self.target = nil
-- 	if not self.follow_player then
-- 		return
-- 	end

-- 	-- Find closest player
-- 	local nearest_player = self:get_nearest_player()
-- 	if not nearest_player then
-- 		return
-- 	end
-- 	self.target = nearest_player
	
-- 	self.speed_x = self.speed_x or self.speed
-- 	if self.is_flying then    self.speed_y = self.speed_y or self.speed 
-- 	else                      self.speed_y = self.speed_y or 0    end 

-- 	self.vx = self.vx + sign0(nearest_player.x - self.x) * self.speed_x * 0.3
-- 	-- self.vy = self.vy + sign0(nearest_player.y - self.y) * self.speed_y * 0.3
-- end

function Dung:jump()
    self.jump_flag = true
end

return Dung

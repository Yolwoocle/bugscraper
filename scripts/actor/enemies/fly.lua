require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"

local Fly = Enemy:inherit()
	
function Fly:init(x, y, spr, w, h)
    self:init_fly(x, y, spr, w, h)
end

function Fly:init_fly(x, y, spr, w, h)
    self:init_enemy(x,y, spr or images.fly1, w, h)
    self.name = "fly"
    self.is_flying = true
    self.life = 10
    --self.speed_y = 0--self.speed * 0.5
    
    self.speed = random_range(7,13) --10
    self.speed_x = self.speed
    self.speed_y = self.speed

    self.gravity = 0
    self.friction_y = self.friction_x

    self.anim_frame_len = 0.05
    self.anim_frames = {images.fly1, images.fly2}

    self:add_constant_sound("buzz", "fly_buzz", false)
    self:seek_constant_sound("buzz", random_range(0, self:get_constant_sound("buzz"):get_duration())) 
    self.is_buzz_enabled = true
    self.buzz_is_started = false
end

function Fly:update(dt)
    self:update_fly(dt)
end

function Fly:disable_buzzing()
    self.is_buzz_enabled = false
    self:stop_constant_sound("buzz")
end

function Fly:update_fly(dt)
    self:update_enemy(dt)
    self:update_buzz(dt)
end

function Fly:update_buzz(dt)
    if self.is_buzz_enabled and not self.buzz_is_started then
        self:play_constant_sound("buzz")
    end
    local spd = dist(0, 0, self.vx, self.vy)
    if spd >= 0.001 then
        self:set_constant_sound_volume("buzz", 1)
    else
        self:set_constant_sound_volume("buzz", 0)
    end
end

return Fly
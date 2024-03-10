require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"

local Fly = Enemy:inherit()
	
function Fly:init(x, y, spr)
    self:init_fly(x, y)
end

function Fly:init_fly(x, y, spr)
    self:init_enemy(x,y, spr or images.fly1)
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

    self.buzz_source = sounds.fly_buzz[1]:clone()
    self.buzz_source:seek(random_range(0, self.buzz_source:getDuration()))
    self.buzz_is_started = false
end

function Fly:update(dt)
    self:update_fly(dt)
end

function Fly:update_fly(dt)
    self:update_enemy(dt)

    if not self.buzz_is_started then  self.buzz_source:play() self.buzz_is_started = true end
    local spd = dist(0, 0, self.vx, self.vy)
    if spd >= 0.001 then
        self.buzz_source:setVolume(1)
    else
        self.buzz_source:setVolume(0)
    end
    -- audio:set_source_position_relative_to_object(self.buzz_source, self)
end

function Fly:pause_repeating_sounds()
    self.buzz_source:setVolume(0)
end
function Fly:play_repeating_sounds()
    self.buzz_source:setVolume(1)
end

function Fly:on_death()
    self.buzz_source:stop()
end

return Fly
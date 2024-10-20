require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"

local SinusoidalFlyer = Enemy:inherit()

function SinusoidalFlyer:init(x, y, spr, w, h)
    self:init_enemy(x,y, spr or images.spiked_fly, w or 20, h or 14)
    self.name = "sinusoidal_flyer"
    self.follow_player = false

    self.life = 60
    self.speed = 0
    self.speed_x = 0

    self.is_flying = true
    self.gravity = 0
    self.speed = 100
    self.is_stompable = false
    self.self_knockback_mult = 0

    self.sin_x_value = 0
    self.sin_y_value = 0
end

function SinusoidalFlyer:update(dt)
    self:update_enemy(dt)

    self.sin_x_value = self.sin_x_value + dt
    self.sin_y_value = self.sin_y_value + dt * 7
    self.vx = math.cos(self.sin_x_value) * self.speed
    self.vy = math.sin(self.sin_y_value) * self.speed
end

return SinusoidalFlyer

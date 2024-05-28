require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local guns = require "data.guns"
local images = require "data.images"

local Woodlouse = Enemy:inherit()

function Woodlouse:init(x, y, spr, w, h)
    self:init_enemy(x,y, spr or images.woodlouse_1, w or 20, h or 14)
    self.name = "woodlouse"
    self.follow_player = false

    self.life = 60
    self.speed = 0
    self.speed_x = 0

    self.is_stompable = false
    self.self_knockback_mult = 0

    self.gun = guns.unlootable.TurretGun:new(self)
end

function Woodlouse:update(dt)
    self:update_enemy(dt)

    self.gun:update(dt)
    
    self.target = self:get_nearest_player()
    if self.target then
        local dx, dy = get_direction_vector(self.mid_x, self.mid_y, self.target.mid_x, self.target.mid_y)
        self.gun:shoot(dt, self, self.mid_x, self.mid_y, dx, dy)
    end
end

function Woodlouse:after_collision(col, other)
    if col.type ~= "cross" then
    end
end

return Woodlouse

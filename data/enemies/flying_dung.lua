require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"
local SnailShelled = require "data.enemies.snail_shelled"

local FlyingDung = SnailShelled:inherit()

function FlyingDung:init(x, y)
    self:init_flying_dung(x, y)
end

function FlyingDung:init_flying_dung(x, y)
    self:init_snail_shelled(x,y, images.dung_1, 16, 16)
    self.name = "flying_dung"

    self.is_bouncy_to_bullets = false
    self.destroy_bullet_on_impact = false
    self.is_stompable = false
end

function FlyingDung:update(dt)
    self:update_snail_shelled(dt)
end

function FlyingDung:draw()
    self:draw_enemy()
end

function FlyingDung:on_death()
end

return FlyingDung
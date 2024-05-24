require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local skins = require "data.skins"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local Rect = require "scripts.math.rect"
local Segment = require "scripts.math.segment"

local utf8 = require "utf8"

local Explosion = Prop:inherit()

function Explosion:init(x, y)
    self:init_prop(x, y, images.empty, 1, 1)
    self.name = "explosion"

    self.explosion_damage = 1
end

function Explosion:update(dt)
    self:update_prop(dt)
end

--- Returns whether an actor is considered an enemy or not. 
function Explosion:is_my_enemy(actor)
    if not actor.is_actor then
        return false
    end
    if self.arc_target then
        return self.arc_target.is_enemy ~= actor.is_enemy
    end
    return actor.is_player
end

function Explosion:draw()
    self:draw_prop()
end

return Explosion
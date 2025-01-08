require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"

local Prop = Enemy:inherit()

function Prop:init(x, y, img, w, h)
    self:init_prop(x, y, img, w, h)
end
function Prop:init_prop(x, y, img, w, h)
    self:init_enemy(x,y, img or images.dummy_target, w or 16, h or 16)
    self.name = "prop"

    self.life = 10
    self.loot = {}

    self.damage = 0
    self.gravity = 0
    self.knockback = 0

    self.is_pushable = false
    self.is_knockbackable = false
    self.is_flying = true
    self.follow_player = false
    self.is_stompable = false
    self.is_killed_on_stomp = false
	self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true

    self.score = 0
end

function Prop:update(dt)
    self:update_prop(dt)
end
function Prop:update_prop(dt)
    self:update_enemy(dt)
end

function Prop:draw()
    self:draw_prop()
end
function Prop:draw_prop()
    self:draw_enemy()
end

return Prop
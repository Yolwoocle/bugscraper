require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"

local utf8 = require "utf8"

local StaticProp = Prop:inherit()

function StaticProp:init(x, y, spr, w, h)
    spr = spr or images.upgrade_jar
    StaticProp.super.init(self, x, y, spr, w or spr:getWidth(), h or spr:getHeight())
    self.name = "static_prop"
    
    self.gravity = 0

    self.life = 10
    self.loot = {}

	self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true

	-- self.sound_damage = "glass_fracture"
	-- self.sound_death = "glass_break_weak"
end

function StaticProp:update(dt)
    StaticProp.super.update(self, dt)
end

function StaticProp:draw()
	StaticProp.super.draw(self)
end

return StaticProp
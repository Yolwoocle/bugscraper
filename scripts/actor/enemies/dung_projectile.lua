require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local EffectSlowness = require "scripts.effect.effect_slowness"
local Timer = require "scripts.timer"
local sounds = require "data.sounds"
local images = require "data.images"
local Projectile = require "scripts.actor.enemies.projectile"

local DungProjectile = Projectile:inherit()
	
function DungProjectile:init(x, y)
    self.super.init(self, x,y, images.dung_projectile, 8, 8)
    self.name = "dung_projectile"
end

return DungProjectile

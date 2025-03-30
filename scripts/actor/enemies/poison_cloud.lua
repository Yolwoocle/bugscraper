require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local EffectCloud = require "scripts.actor.enemies.effect_cloud"

local PoisonCloud = EffectCloud:inherit()
	
function PoisonCloud:init(x, y, spr)
    PoisonCloud.super.init(self, x,y, spr or images.poison_cloud, 20, 20)
    self.name = "poison_cloud"

    self.is_poisonous = true
end

function PoisonCloud:update(dt)
    PoisonCloud.super.update(self, dt)
end

function PoisonCloud:draw()
    PoisonCloud.super.draw(self)
end

return PoisonCloud
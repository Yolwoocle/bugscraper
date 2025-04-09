require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local EffectCloud = require "scripts.actor.enemies.effect_cloud"

local RainbowCloud = EffectCloud:inherit()
	
function RainbowCloud:init(x, y, spr)
    RainbowCloud.super.init(self, x,y, spr or images.poison_cloud, 1, 1)
    self.name = "rainbow_cloud"

    self.z = -200

    self.cloud_scale = random_range(0.7, 1.3)
end

function RainbowCloud:update(dt)
    RainbowCloud.super.update(self, dt)    
end

function RainbowCloud:draw()
    RainbowCloud.super.super.draw(self)
end

return RainbowCloud
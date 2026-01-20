require "scripts.util"
local images = require "data.images"
local Projectile = require "scripts.actor.enemies.projectile"

local LarvaProjectileBoss = Projectile:inherit()
	
function LarvaProjectileBoss:init(x, y)
    LarvaProjectileBoss.super.init(self, x,y, images.larva_projectile, 8, 8)
    self.name = "larva_projectile_boss"

    self.is_pushable = false
end

function LarvaProjectileBoss:update(dt)
    LarvaProjectileBoss.super.update(self, dt)
    Particles:push_layer(PARTICLE_LAYER_BACK)
    Particles:dust(self.mid_x, self.mid_y)
    Particles:pop_layer()
end

return LarvaProjectileBoss

require "scripts.util"
local images = require "data.images"
local Projectile = require "scripts.actor.enemies.projectile"

local DungProjectile = Projectile:inherit()
	
function DungProjectile:init(x, y)
    DungProjectile.super.init(self, x,y, images.dung_projectile, 8, 8)
    self.name = "dung_projectile"

    self.is_pushable = false
end

function DungProjectile:update(dt)
    DungProjectile.super.update(self, dt)
    Particles:push_layer(PARTICLE_LAYER_BACK)
    Particles:dust(self.mid_x, self.mid_y)
    Particles:pop_layer()
end

return DungProjectile

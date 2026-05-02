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

function DungProjectile:on_projectile_land()
    self:play_sound_var("sfx_enemy_kill_general_gore_{01-10}", 0.2, 1.2)
end

return DungProjectile

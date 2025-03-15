require "scripts.util"
local images = require "data.images"
local Projectile = require "scripts.actor.enemies.projectile"
local Larva = require "scripts.actor.enemies.larva"

local LarvaProjectile = Projectile:inherit()

function LarvaProjectile:init(x, y, angle)
    LarvaProjectile.super.init(self, x, y, images.larva_projectile, 8, 8, nil, angle, 300, 300)
    self.gravity_mult = 0.4
    self.name = "larva_projectile"

    self.larva = nil
    self.spr.rot = random_range(0, pi2)
end

function LarvaProjectile:update(dt)
    LarvaProjectile.super.update(self, dt)
    
    self.spr.rot = self.spr.rot + dt
    Particles:push_layer(PARTICLE_LAYER_BACK)
    Particles:dust(self.mid_x, self.mid_y)
    Particles:pop_layer()
end

function LarvaProjectile:on_projectile_land()
    self:kill()

    local larva = Larva:new(self.mid_x, self.mid_y)
    larva.loot = {}
    larva.score = 0
    game:new_actor(larva)

    self.larva = larva
end

return LarvaProjectile

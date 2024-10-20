require "scripts.util"
local SinusoidalFlyer = require "scripts.actor.enemies.sinusoidal_flyer"
local images = require "data.images"
local Timer = require "scripts.timer"
local Larva = require "scripts.actor.enemies.larva"
local LarvaProjectile = require "scripts.actor.enemies.larva_projectile"
local images = require "data.images"
local AnimatedSprite = require "scripts.graphics.animated_sprite"

local FlyingSpawner = SinusoidalFlyer:inherit()

function FlyingSpawner:init(x, y, spr, w, h)
    self.super.init(self, x,y, spr or images.flying_spawner_1, w or 16, h or 18)
    self.name = "sinusoidal_flyer"

    self.spr = AnimatedSprite:new({
        normal = {{images.flying_spawner_1, images.flying_spawner_2}, 0.05}
    }, "normal", SPRITE_ANCHOR_CENTER_CENTER)

    self.flip_mode = ENEMY_FLIP_MODE_MANUAL

    self.life = 25

    self.spawn_larva_timer = Timer:new({1, 2})
    self.spawn_larva_timer:start()
    self.larva_projectiles = {}
    self.larvae = {}
    self.max_larvae = 6

    self.target_y = (game.level.cabin_inner_rect.ay + game.level.cabin_inner_rect.by) / 2
end

function FlyingSpawner:update(dt)
    self.super.update(self, dt)
    
    if (#self.larvae + #self.larva_projectiles < self.max_larvae) and not self.spawn_larva_timer.is_active then
        self.spawn_larva_timer:start()
    end
    
    if self.spawn_larva_timer:update(dt) then
        local larva_projectile = LarvaProjectile:new(self.mid_x, self.mid_y)
        game:new_actor(larva_projectile)
        table.insert(self.larva_projectiles, larva_projectile)
    end
    
    for i=#self.larva_projectiles, 1, -1 do
        local larva_projectile = self.larva_projectiles[i]
        if larva_projectile.is_dead then
            table.remove(self.larva_projectiles, i)
            
            if larva_projectile.larva then
                table.insert(self.larvae, larva_projectile.larva)
            else
                assert(false, "larva_projectile.larva = nil")
            end
        end
    end
    
    for i=#self.larvae, 1, -1 do
        if self.larvae[i].is_dead then
            table.remove(self.larvae, i)
        end
    end
end

return FlyingSpawner

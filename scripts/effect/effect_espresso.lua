require "scripts.util"
local Effect = require "scripts.effect.effect"
local images = require "data.images"

local EffectEspresso = Effect:inherit()

function EffectEspresso:init()
    self:init_effect()
    self.name = "effect_coffee"
    self.strength = 2.0
end

function EffectEspresso:on_apply(player, duration)
    player:multiply_gun_cooldown_multiplier(1/self.strength)
end

function EffectEspresso:update(dt, player)
    self:update_effect(dt)
    
    -- number, col, spw_rad, size, sizevar, layer
    player.spr:update_offset(random_neighbor(1), random_neighbor(1))
    Particles:smoke(player.mid_x, player.mid_y, 1, random_sample{COL_MID_BROWN, COL_DARK_BROWN}, nil, nil, nil, PARTICLE_LAYER_BACK)
end

function EffectEspresso:on_finish(player)
    player.spr:update_offset(0, 0)
    player:multiply_gun_cooldown_multiplier(self.strength)
end

return EffectEspresso
require "scripts.util"
local Effect = require "scripts.effect.effect"
local images = require "data.images"

local EffectSlowness = Effect:inherit()

function EffectSlowness:init()
    self:init_effect()
    self.name = "effect_coffee"
    self.strength = 2.0
end

function EffectSlowness:on_apply(player, duration)
    player:multiply_gun_cooldown_multiplier(1/self.strength)
end

function EffectSlowness:update(dt, player)
    self:update_effect(dt)
    
    Particles:smoke(player.mid_x, player.mid_y, 1, random_sample{COL_MID_BROWN, COL_DARK_BROWN})
end

function EffectSlowness:on_finish(player)
    player:multiply_gun_cooldown_multiplier(self.strength)
end

return EffectSlowness
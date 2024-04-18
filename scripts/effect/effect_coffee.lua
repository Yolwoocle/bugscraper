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

-- function EffectSlowness:draw_overlay(spr_x, spr_y)
--     local a = clamp(self.duration - (self.duration - self.timer), 0, 1)
--     exec_with_color({1, 1, 1, a}, function()
--         love.graphics.draw(images.honey_blob, spr_x, spr_y)
--     end)
-- end

return EffectSlowness
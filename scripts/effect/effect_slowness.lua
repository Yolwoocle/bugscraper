require "scripts.util"
local Effect = require "scripts.effect.effect"
local images = require "data.images"

local EffectSlowness = Effect:inherit()

function EffectSlowness:init(sleep_mult, jump_speed_mult)
    self:init_effect()
    self.name = "effect_slowness"

    self.sleep_mult = sleep_mult or 0.3
    self.jump_speed_mult = jump_speed_mult or 0.5
end

function EffectSlowness:on_apply(player, duration)
end

function EffectSlowness:update(dt)
    self:update_effect(dt)

    if self.player then
        self.player.speed_mult = self.sleep_mult
        self.player.jump_speed_mult = self.jump_speed_mult
    end
    
end

function EffectSlowness:on_finish(player)
    player.speed_mult = 1.0
    player.jump_speed_mult = 1.0
end

function EffectSlowness:draw_overlay(spr_x, spr_y)
    local a = clamp(self.duration - (self.duration - self.timer), 0, 1)
    exec_with_color({1, 1, 1, a}, function()
        love.graphics.draw(images.honey_blob, spr_x, spr_y)
    end)
end

return EffectSlowness
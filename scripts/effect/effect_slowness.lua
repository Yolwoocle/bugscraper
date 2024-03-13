require "scripts.util"
local Effect = require "scripts.effect.effect"
local images = require "data.images"

local EffectSlowness = Effect:inherit()

function EffectSlowness:init()
    self:init_effect()
    self.name = "effect_slowness"
end

function EffectSlowness:on_apply(actor, duration)
    actor.speed_mult = 0.3
    actor.jump_speed_mult = 0.5
end

function EffectSlowness:update(dt)
    self:update_effect(dt)
end

function EffectSlowness:on_finish(actor)
    actor.speed_mult = 1.0
    actor.jump_speed_mult = 1.0
end

function EffectSlowness:draw_overlay(spr_x, spr_y)
    local a = clamp(self.duration - (self.duration - self.timer), 0, 1)
    exec_with_color({1, 1, 1, a}, function()
        love.graphics.draw(images.honey_blob, spr_x, spr_y)
    end)
end

return EffectSlowness
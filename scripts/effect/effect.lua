require "scripts.util"
local Class = require "scripts.meta.class"

local Effect = Class:inherit()

function Effect:init()
    self:init_effect()
end

function Effect:init_effect()
    self.name = "effect"
    self.is_active = false

    self.actor = nil
    self.duration = 5.0
    self.timer = 0.0
end

function Effect:apply(actor, duration)
    self.actor = actor
    
    self.duration = duration

    self.timer = self.duration
    self.is_active = true
    self:on_apply(actor, duration)
end

function Effect:finish()
    self:on_finish(self.actor)
    self.is_active = false
    self.actor = nil
end 

function Effect:update_effect(dt)
    self.timer = math.max(0.0, self.timer - dt)
    if self.timer == 0.0 then
        self:finish()
    end
end

function Effect:on_apply(actor, duration)
end

function Effect:update(dt)
    self:update_effect(dt)
end

function Effect:on_finish(actor)
end

function Effect:draw_overlay(spr_x, spr_y)
end

return Effect
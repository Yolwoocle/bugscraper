require "scripts.util"
local Class = require "scripts.meta.class"
local vec2 = require "lib.batteries.vec2"
local Segment = require "scripts.math.segment"

local Light = Class:inherit()

function Light:init(x, y, params)
    -- angle, spread, range, rect, is_active
    params = params or {}

    self.position = vec2(x, y)
    self.angle = param(params.angle, 0)
    self.spread = param(params.spread, pi/8)
    self.range = param(params.range, 800)

    self.oscillation_enabled = false
    self.oscillation_speed = 0
    self.oscillation_amplitude = 0
    self.oscillation_angle_offset = 0
    self.oscillation_angle_value = 0

    self.is_active = param(params.is_active, true)

    self.target = nil
end

function Light:update(dt)
    if self.target then
        local a = math.atan2(self.target.mid_y - self.position.y, self.target.mid_x - self.position.x)
        self.angle = a
        
    elseif self.oscillation_enabled then
        self.oscillation_angle_value = self.oscillation_angle_value + self.oscillation_speed * dt
        self.oscillation_angle_offset = math.sin(self.oscillation_angle_value) * self.oscillation_amplitude
    end
end

function Light:set_active(value)
    self.is_active = value
end

function Light:get_segments(bounds)
    local angle = self.angle + self.oscillation_angle_offset
    local s1 = Segment:new(self.position.x, self.position.y, self.position.x + math.cos(angle + self.spread) * self.range, self.position.y + math.sin(angle + self.spread) * self.range)
    local s2 = Segment:new(self.position.x, self.position.y, self.position.x + math.cos(angle - self.spread) * self.range, self.position.y + math.sin(angle - self.spread) * self.range)

    if bounds then
        return Segment:new(clamp_segment_to_rectangle(s1, bounds)), Segment:new(clamp_segment_to_rectangle(s2, bounds))
    else
        return s1, s2
    end
end

function Light:draw(bounds)
    if not self.is_active then
        return
    end

    local s1, s2 = self:get_segments(bounds)
    if s1 and s2 and s1.ax and s1.bx and s2.ax and s1.bx then
        love.graphics.polygon("fill", s1.ax, s1.ay, s1.bx, s1.by, s2.bx, s2.by, s2.ax, s2.ay)
    end
end

return Light
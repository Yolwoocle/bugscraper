require "scripts.util"
local Class = require "scripts.meta.class"
local vec2 = require "lib.batteries.vec2"
local Segment = require "scripts.math.segment"

local Light = Class:inherit()

function Light:init(x, y, angle, spread, range, rect, is_active)
    self.position = vec2(x, y)
    self.angle = angle
    self.spread = spread
    self.range = 800 or range
    self.bounds = rect

    self.o = random_range(0, pi*2)

    self.is_active = param(is_active, true)
end

function Light:set_active(value)
    self.is_active = value
end

function Light:get_segments()
    local angle = self.angle --+ math.sin(game.t + self.o) * pi*0.1
    local s1 = Segment:new(self.position.x, self.position.y, self.position.x + math.cos(angle + self.spread) * self.range, self.position.y + math.sin(angle + self.spread) * self.range)
    local s2 = Segment:new(self.position.x, self.position.y, self.position.x + math.cos(angle - self.spread) * self.range, self.position.y + math.sin(angle - self.spread) * self.range)

    if self.bounds then
        return Segment:new(clamp_segment_to_rectangle(s1, self.bounds)), Segment:new(clamp_segment_to_rectangle(s2, self.bounds))
    else
        return s1, s2
    end
end

function Light:draw()
    if not self.is_active then
        return
    end

    local s1, s2 = self:get_segments()
    if s1 and s2 then
        love.graphics.polygon("fill", s1.ax, s1.ay, s1.bx, s1.by, s2.bx, s2.by, s2.ax, s2.ay)
    end
end

return Light
require "scripts.util"
local Class = require "scripts.meta.class"

local Segment = Class:inherit()

function Segment:init(ax, ay, bx, by)
    self:set_bounds(ax, ay, bx, by)
end

function Segment:set_bounds(ax, ay, bx, by)
    self.ax = ax
    self.ay = ay
    self.bx = bx
    self.by = by
end

function Segment:clone()
    return Segment:new(self.ax, self.ay, self.bx, self.by)
end

function Segment:scale(val)
    self:set_bounds(self.ax * val, self.ay * val, self.bx * val, self.by * val)
    return self
end

function Segment:get_direction()
    return normalize_vect(self.bx - self.ax, self.by - self.ay)
end

function Segment:get_length()
    return dist(self.bx - self.ax, self.by - self.ay)
end

return Segment
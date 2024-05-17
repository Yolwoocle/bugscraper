require "scripts.util"
local Class = require "scripts.meta.class"
local Segment = require "scripts.math.segment"

local Rect = Class:inherit()

function Rect:init(ax, ay, bx, by)
    self:set_bounds(ax, ay, bx, by)
end

function Rect:set_bounds(ax, ay, bx, by)
    self.ax = ax
    self.ay = ay
    self.bx = bx
    self.by = by

    self.x = ax
    self.y = ay
    self.w = bx - ax
    self.h = by - ay
end

function Rect:clone()
    return Rect:new(self.ax, self.ay, self.bx, self.by)
end

function Rect:expand(val)
    self:set_bounds(self.ax - val, self.ay - val, self.bx + val, self.by + val)
    return self
end

function Rect:scale(val)
    self:set_bounds(self.ax * val, self.ay * val, self.bx * val, self.by * val)
    return self
end

function Rect:is_point_in_inclusive(px, py)
	return (self.ax <= px and px <= self.bx) and (self.ay <= py and py <= self.by)
end

function Rect:segment_intersection(segment)
    local bool1 = segment_intersect(segment, Segment:new(self.ax, self.ay, self.bx, self.ay))
    local bool2 = segment_intersect(segment, Segment:new(self.ax, self.ay, self.ax, self.by))
    local bool3 = segment_intersect(segment, Segment:new(self.bx, self.ay, self.bx, self.by))
    local bool4 = segment_intersect(segment, Segment:new(self.ax, self.by, self.bx, self.by))
    return bool1 or bool2 or bool3 or bool4 or self:is_point_in_inclusive(segment.ax, segment.ay) or self:is_point_in_inclusive(segment.bx, segment.by)
end

return Rect
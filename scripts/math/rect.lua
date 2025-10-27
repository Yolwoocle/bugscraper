require "scripts.util"
local Class = require "scripts.meta.class"
local Segment = require "scripts.math.segment"

local Rect = Class:inherit()

function Rect:init(ax, ay, bx, by)
    self:set_bounds(ax, ay, bx, by)
end

-- ax, ay: top left
-- bx, by: bottom right
function Rect:set_bounds(ax, ay, bx, by)
    ax = ax or self.ax
    ay = ay or self.ay
    bx = bx or self.bx
    by = by or self.by

    --  invert a and b if in this case:
    --   + (bx, by)    
    --                 
    --       + (ax, ay)
    if bx < ax and by < ay then
        ax, ay, bx, by = bx, by, ax, ay

    --       + (ax, ay)      + (bx, ay)    
    --                   ->                
    --   + (bx, by)              + (ax, by)
    elseif bx < ax then
        ax, ay, bx, by = bx, ay, ax, by

    --       + (bx, by)      + (ax, by)    
    --                   ->                
    --   + (ax, ay)              + (bx, ay)
    elseif by < ay then
        ax, ay, bx, by = ax, by, bx, ay
    end

    self.ax = ax
    self.ay = ay
    self.bx = bx
    self.by = by

    self.x = ax
    self.y = ay
    self.w = bx - ax
    self.h = by - ay
end

function Rect:set_ax(ax)
    self:set_bounds(ax, self.ay, self.bx, self.by)
end
function Rect:set_ay(ay)
    self:set_bounds(self.ax, ay, self.bx, self.by)
end
function Rect:set_bx(bx)
    self:set_bounds(self.ax, self.ay, bx, self.by)
end
function Rect:set_by(by)
    self:set_bounds(self.ax, self.ay, self.bx, by)
end

function Rect:get_x_center()
    return (self.ax + self.bx) / 2
end
function Rect:get_y_center()
    return (self.ay + self.by) / 2
end
function Rect:get_center()
    return self:get_x_center(), self:get_y_center()
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

--- Returns whether the rectangle intersects a segment
function Rect:segment_intersection(segment)
    local bool1 = segment_intersect(segment, Segment:new(self.ax, self.ay, self.bx, self.ay))
    local bool2 = segment_intersect(segment, Segment:new(self.ax, self.ay, self.ax, self.by))
    local bool3 = segment_intersect(segment, Segment:new(self.bx, self.ay, self.bx, self.by))
    local bool4 = segment_intersect(segment, Segment:new(self.ax, self.by, self.bx, self.by))
    return bool1 or bool2 or bool3 or bool4 or self:is_point_in_inclusive(segment.ax, segment.ay) or self:is_point_in_inclusive(segment.bx, segment.by)
end

--- Check if two rectangles collide
function Rect:rectangle_intersection(other)
    -- https://stackoverflow.com/questions/13390333/two-rectangles-intersection

    -- return !(x_1 > x_2+width_2       || x_1+width_1 < x_2       || y_1 > y_2+height_2       || y_1+height_1 < y_2);
    return not (self.x > other.x+other.w or self.x+self.w < other.x or self.y > other.y+other.h or self.y+self.h < other.y);
end

return Rect
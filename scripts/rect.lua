require "scripts.util"
local Class = require "scripts.meta.class"

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

return Rect
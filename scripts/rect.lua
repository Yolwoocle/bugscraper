require "scripts.util"
local Class = require "scripts.meta.class"

local Rect = Class:inherit()

function Rect:init(ax, ay, bx, by)
    self.ax = ax
    self.ay = ay
    self.bx = bx
    self.by = by
end

return Rect
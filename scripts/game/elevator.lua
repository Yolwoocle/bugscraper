require "scripts.util"
local Class = require "scripts.meta.class"

local Elevator = Class:inherit()

function Elevator:init(level)
    self.level = level
end

function Elevator:update(dt)
	--
end

function Elevator:draw()
	--
end

return Elevator
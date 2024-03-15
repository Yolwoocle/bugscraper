local Class = require "scripts.meta.class"

local Background = Class:inherit()

function Background:init(elevator)
	self:init_background(elevator)
end
function Background:init_background(elevator)
	self.elevator = elevator
end

function Background:update_background(dt)
end

function Background:draw_background(dt)
end

return Background
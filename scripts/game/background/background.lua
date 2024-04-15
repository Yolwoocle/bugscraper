local Class = require "scripts.meta.class"

local Background = Class:inherit()

function Background:init_background(level)
	self.level = level

	self.speed = 0.0
end

-----------------------------------------------------

function Background:update(dt)
	self:update_background(dt)
end

function Background:update_background(dt)
end

function Background:set_speed(val)
	self.speed = val
end
function Background:set_def_speed(val)
	self.def_speed = val
end

-----------------------------------------------------

function Background:draw()
end

return Background
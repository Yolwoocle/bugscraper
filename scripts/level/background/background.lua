local Class = require "scripts.meta.class"

local Background = Class:inherit()

function Background:init(level)
	self.level = level
	self.clear_color = COL_BLACK

	self.speed = 0.0
end

function Background:set_level(level)
	self.level = level
end

-----------------------------------------------------

function Background:update(dt)
	print(concat("update frame ", _G_fixed_frame))
end

function Background:get_speed()
	return self.speed * Options:get("background_speed")
end
function Background:set_speed(val)
	self.speed = val
end
function Background:set_def_speed(val)
	self.def_speed = val
end

-----------------------------------------------------

function Background:draw()
	love.graphics.clear(self.clear_color)
end

return Background
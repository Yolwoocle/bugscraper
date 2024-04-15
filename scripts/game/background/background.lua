local Class = require "scripts.meta.class"

local Background = Class:inherit()

function Background:init_background(level)
	self.level = level
end

-----------------------------------------------------

function Background:update(dt)
	self:update_background(dt)
end

function Background:update_background(dt)
end

-----------------------------------------------------

function Background:draw()
end

return Background
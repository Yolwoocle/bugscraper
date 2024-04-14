local Class = require "scripts.meta.class"

local Background = Class:inherit()

function Background:init(level)
	self:init_background(level)
end
function Background:init_background(level)
	self.level = level
end

function Background:update_background(dt)
end

function Background:draw_background(dt)
end

return Background
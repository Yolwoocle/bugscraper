local Class = require "scripts.meta.class"
local Background = require "scripts.level.background.background"

local BackgroundPlain = Background:inherit()

function BackgroundPlain:init(level)
	self:init_background(level)
end
-----------------------------------------------------

function BackgroundPlain:update(dt)
	self:update_background(dt)
end

function BackgroundPlain:draw()
	-- self:draw_background()
	love.graphics.clear(COL_LIGHT_GRAY)
end

return BackgroundPlain
require "scripts.util"
local Background = require "scripts.level.background.background"
local images     = require "data.images"

local BackgroundCafeteria = Background:inherit()

function BackgroundCafeteria:init(level)
	self:init_background(level)

	self.clear_color = COL_DARK_GREEN
end

-----------------------------------------------------

function BackgroundCafeteria:update(dt)
	self:update_background(dt)

end

-----------------------------------------------------

function BackgroundCafeteria:draw()
	self:draw_background()

	love.graphics.draw(images.cafeteria, 0, 0)
end

return BackgroundCafeteria
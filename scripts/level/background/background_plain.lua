local Class = require "scripts.meta.class"
local Background = require "scripts.level.background.background"

local BackgroundPlain = Background:inherit()

function BackgroundPlain:init(level)
	self.super.init(self, level)
	self.name = "background_plain"
end
-----------------------------------------------------

function BackgroundPlain:update(dt)
	self.super.update(self, dt)
end

function BackgroundPlain:draw()
	love.graphics.clear(COL_BLACK_BLUE)
end

return BackgroundPlain
require "scripts.util"
local Class = require "scripts.meta.class"

local BackgroundLayer = Class:inherit()

function BackgroundLayer:init(background, parallax)
    self.background = background
    self.parallax = parallax or 1

    self.layer_y = 0.0
end

function BackgroundLayer:update(dt)
	self.layer_y = self.layer_y - self.background:get_speed() * dt 
end

function BackgroundLayer:draw()
	--
end

return BackgroundLayer
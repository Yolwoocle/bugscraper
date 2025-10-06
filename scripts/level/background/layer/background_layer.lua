require "scripts.util"
local Class = require "scripts.meta.class"

local BackgroundLayer = Class:inherit()

function BackgroundLayer:init(background, parallax, params)
    params = params or {}
    self.background = background
    self.parallax = parallax or 1

    self.initial_x = params.initial_x or 0.0
    self.initial_y = params.initial_y or 0.0
    self.layer_x = self.initial_x 
    self.layer_y = self.initial_y 
end

function BackgroundLayer:update(dt)
	self.layer_y = self.layer_y + self.background:get_speed() * dt 
end

function BackgroundLayer:draw()
	--
end

return BackgroundLayer
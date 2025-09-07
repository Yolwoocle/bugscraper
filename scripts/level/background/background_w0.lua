require "scripts.util"
local images = require "data.images"
local BackgroundLayered = require "scripts.level.background.background_layered"
local BackgroundLayerParticles = require "scripts.level.background.layer.background_layer_particles"
local BackgroundLayerPattern = require "scripts.level.background.layer.background_layer_pattern"

local BackgroundW0 = BackgroundLayered:inherit()

function BackgroundW0:init(level)
	BackgroundW0.super.init(self, level)
	self.name = "background_w0"

	self.clear_color = COL_BLACK_BLUE
end

function BackgroundW0:update(dt)
	BackgroundW0.super.update(self, dt)
end

function BackgroundW0:draw()
	BackgroundW0.super.draw(self)
end

return BackgroundW0
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

	
	self:add_layer(BackgroundLayerPattern:new(self, 0.07, {
		pattern_images = {images.bg_w1_back_bricks},
	}))

	self:add_layer(BackgroundLayerParticles:new(self, 0.07, {
		y_range = {-CANVAS_HEIGHT, 0},
		particles = {
			{
				images = {images.bg_w1_pipe_far_1, images.bg_w1_pipe_far_2, images.bg_w1_pipe_far_3},
				x_anchor = "random",
			}, 
		},
		amount = 3,
	}))

	self:add_layer(BackgroundLayerParticles:new(self, 0.2, {
		y_range = {-CANVAS_HEIGHT*2, 0},
		particles = {
			{
				images = {images.bg_w1_beams_far},
				x_anchor = "left",
				x_anchor_offset_range = {-12, -6}
			}, 
		},
		amount = 1,
	}))
end

function BackgroundW0:update(dt)
	BackgroundW0.super.update(self, dt)
end

function BackgroundW0:draw()
	BackgroundW0.super.draw(self)
end

return BackgroundW0
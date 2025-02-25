require "scripts.util"
local images = require "data.images"
local BackgroundLayered = require "scripts.level.background.background_layered"
local BackgroundLayerParticles = require "scripts.level.background.layer.background_layer_particles"
local BackgroundLayerPattern = require "scripts.level.background.layer.background_layer_pattern"

local BackgroundW1 = BackgroundLayered:inherit()

function BackgroundW1:init(level)
	BackgroundW1.super.init(self, level)

	self.clear_color = COL_BLACK_BLUE

	-- self:add_layer(BackgroundLayerParticles:new(self, 1, {
	-- 	images = {images.cabin_grid}
	-- }))
	
	--[[
		-top-
			speed: 8x	pipe_1 		- Particle, can be mirrored, keep centered.
			speed: 8x	pipe_2		- Particle, can be mirrored, anchor to left side. (Right if mirrored.)
			speed: 8x	beams_close 	- Particle, can be mirrored, if possible keep partially outside of viewport
			speed: 8x	rope		- Particle, can be mirrored, anchor to left side. (Right if mirrored.)
			speed: 4x	bricks		- Sprite(tiling), can be mirrored. (It will tile with the mirrored version of itself too)
			speed: 2x	beams_far	- Particle, can be mirrored, if possible keep partially outside of viewport
			speed: 1x	lights		- Particle, can be mirrored, can go anywhere.
			static		backdrop, solid color. (darkest color in the palette)
		-bottom-
	]]

	self:add_layer(BackgroundLayerPattern:new(self, 0.07, {
		pattern_images = {images.bg_w1_back_bricks},
		pattern_x_offsets = {0, 8},
		-- pattern_y_offsets = {-7, -7},
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

	self:add_layer(BackgroundLayerParticles:new(self, 0.1, {
		y_range = {-CANVAS_HEIGHT/2, 0},
		particles = {
			{
				images = {images.bg_w1_lights},
				x_anchor = "random",
				x_range = {92, CANVAS_WIDTH-92},
			}, 
		},
		amount = 2,
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

	self:add_layer(BackgroundLayerParticles:new(self, 0.2, {
		y_range = {-CANVAS_HEIGHT*2, 0},
		particles = {
			{
				images = {images.bg_w1_beams_far},
				x_anchor = "right",
				x_anchor_offset_range = {6, 12}
			}, 
		},
		amount = 1,
	}))

	self:add_layer(BackgroundLayerPattern:new(self, 0.4, {
		pattern_images = {images.bg_w1_bricks},
	}))

	self:add_layer(BackgroundLayerParticles:new(self, 0.8, {
		y_range = {-CANVAS_HEIGHT/2, 0},
		particles = {
			{
				images = {images.bg_w1_rope},
				x_anchor = "leftright",
			}, 
			{
				images = {images.bg_w1_beams_close},
				x_anchor = "left",
				x_anchor_offset_range = {-16, -7}
			}, 
			{
				images = {images.bg_w1_beams_close},
				x_anchor = "right",
				x_anchor_offset_range = {7, 16},
				flip_if_on_right_edge = true,
			}, 
			{
				images = {images.bg_w1_pipe_2},
				x_anchor = "leftright",
			}, 
			{
				images = {images.bg_w1_pipe_1},
				x_anchor = "center",
			}, 
		},
		amount = 1,
	}))
end

function BackgroundW1:update(dt)
	BackgroundW1.super.update(self, dt)
end

function BackgroundW1:draw()
	BackgroundW1.super.draw(self)
end

return BackgroundW1
require "scripts.util"
local images = require "data.images"
local BackgroundLayered = require "scripts.level.background.background_layered"
local BackgroundLayerParticles = require "scripts.level.background.layer.background_layer_particles"
local BackgroundLayerSprite = require "scripts.level.background.layer.background_layer_sprite"
local BackgroundLayerPattern = require "scripts.level.background.layer.background_layer_pattern"

local BackgroundGreenhouse = BackgroundLayered:inherit()

function BackgroundGreenhouse:init(level)
	BackgroundGreenhouse.super.init(self, level)

	self.clear_color = COL_BLACK_BLUE

	-- self:add_layer(BackgroundLayerParticles:new(self, 1, {
	-- 	images = {images.cabin_grid}
	-- }))
	self:add_layer(BackgroundLayerSprite:new(self, 0, {
		image = images.bg_city_0
	}))
	self:add_layer(BackgroundLayerSprite:new(self, 0.001, {
		image = images.bg_city_1
	}))
	self:add_layer(BackgroundLayerSprite:new(self, 0.005, {
		image = images.bg_city_2
	}))
	self:add_layer(BackgroundLayerSprite:new(self, 0.01, {
		image = images.bg_city_3
	}))
	self:add_layer(BackgroundLayerSprite:new(self, 0, {
		image = images._test_shine
	}))

	self:add_layer(BackgroundLayerPattern:new(self, 0.6, {
		pattern_image = images._test_window,
		pattern_x_offsets = {0, 32},
		pattern_y_offsets = {0, 0},
		determinant_function = function(_self, x, y)
			return true
		end
	}))
end

function BackgroundGreenhouse:update(dt)
	BackgroundGreenhouse.super.update(self, dt)
end

function BackgroundGreenhouse:draw()
	BackgroundGreenhouse.super.draw(self)
end

return BackgroundGreenhouse
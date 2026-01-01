require "scripts.util"
local images = require "data.images"
local BackgroundLayered = require "scripts.level.background.background_layered"
local BackgroundLayerSolidColor = require "scripts.level.background.layer.background_layer_solid_color"
local BackgroundLayerSprite = require "scripts.level.background.layer.background_layer_sprite"

local BackgroundAboveCity = BackgroundLayered:inherit()

function BackgroundAboveCity:init(level)
	BackgroundAboveCity.super.init(self, level)
	self.name = "background_above_city"

	self.clear_color = COL_BLACK_BLUE


	-- self:add_layer(BackgroundLayerParticles:new(self, 1, {
	-- 	images = {images.cabin_grid}
	-- }))
	
	self:add_layer(BackgroundLayerSolidColor:new(self, 0.01, { 
		color = COL_WHITE,
	}))
	self:add_layer(BackgroundLayerSprite:new(self, 0, {
		image = images.bg_city_0,
		initial_y = 1000,
	}))
	self:add_layer(BackgroundLayerSprite:new(self, 0.001, {
		image = images.bg_city_1,
		initial_y = 1000,
	}))
	self:add_layer(BackgroundLayerSprite:new(self, 0.005, {
		image = images.bg_city_2,
		initial_y = 1000,
	}))
	self:add_layer(BackgroundLayerSprite:new(self, 0.01, { 
		image = images.bg_city_3,
		initial_y = 1000,
	}))
end

function BackgroundAboveCity:update(dt)
	BackgroundAboveCity.super.update(self, dt)
end

function BackgroundAboveCity:draw()
	BackgroundAboveCity.super.draw(self)
end

return BackgroundAboveCity
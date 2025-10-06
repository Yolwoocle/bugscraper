require "scripts.util"
local images = require "data.images"
local BackgroundLayered = require "scripts.level.background.background_layered"
local BackgroundLayerParticles = require "scripts.level.background.layer.background_layer_particles"
local BackgroundLayerSprite = require "scripts.level.background.layer.background_layer_sprite"
local BackgroundLayerPattern = require "scripts.level.background.layer.background_layer_pattern"
local BackgroundLayer3D = require "scripts.level.background.layer.background_layer_3d"
local BackgroundLayerSolidColor = require "scripts.level.background.layer.background_layer_solid_color"

local w4_tower = require "data.models.w4_tower"

local BackgroundGreenhouse = BackgroundLayered:inherit()

function BackgroundGreenhouse:init(level)
	BackgroundGreenhouse.super.init(self, level)
	self.name = "background_greenhouse"

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

	self:add_layer(BackgroundLayerSolidColor:new(self, 0.01, { 
		color = transparent_color(COL_DARK_BLUE, 0.5)
	}))

	self:add_layer(BackgroundLayer3D:new(self, 0.3, {
		model = w4_tower,

		tile_h = 200,
		tile_count = 12,
		tile_max_y = 1400,

		object_scale_x = 1000,
		object_scale_y = -1000,
		object_scale_z = -1000,

		object_z = 1000,
	}))

	
	self:add_layer(BackgroundLayerParticles:new(self, 0.3, {
		y_range = {-CANVAS_HEIGHT/2, -CANVAS_HEIGHT/2},
		particles = {
			{
				images = {images.bg_w4_platform_1_back},
				x_anchor = "center",
			}, 
		},
		amount = 1,
	}))
	
	self:add_layer(BackgroundLayerSprite:new(self, 0.5, { 
		initial_y = (CANVAS_HEIGHT - 480) / 0.5,
		image = images.bg_w4_base,
	}))
	
	self:add_layer(BackgroundLayerParticles:new(self, 0.8, {
		y_range = {0, 0},
		particles = {
			{
				images = {images.bg_w4_platform_1},
				x_anchor = "center",
			}, 
		},
		amount = 1,
	}))
end

function BackgroundGreenhouse:update(dt)
	BackgroundGreenhouse.super.update(self, dt)
end

function BackgroundGreenhouse:draw()
	BackgroundGreenhouse.super.draw(self)
end

return BackgroundGreenhouse
require "scripts.util"
local Background = require "scripts.level.background.background"
local Sprite = require "scripts.graphics.sprite"
local images = require "data.images"

local BackgroundCity = Background:inherit()

function BackgroundCity:init(level)
	BackgroundCity.super.init(self, level)
	self.name = "background_city"

	self.clear_color = COL_LIGHT_BLUE
	self.t = 0

	self.speed = 0

	-- Note: this was made before BackgroundLayered was coded and tbh I didn't feel like porting 
	-- this background to the new system. It's good enough.
	self.layers = {
		{sprite = Sprite:new(images.bg_city_0, SPRITE_ANCHOR_LEFT_TOP), y = 0,  z = math.huge},
		{sprite = Sprite:new(images.bg_city_1, SPRITE_ANCHOR_LEFT_TOP), y = 16, z = 16},
		{sprite = Sprite:new(images.bg_city_2, SPRITE_ANCHOR_LEFT_TOP), y = 32, z = 8},
		{sprite = Sprite:new(images.bg_city_3, SPRITE_ANCHOR_LEFT_TOP), y = 64, z = 4},
	}
	
	self.offset_x = 0.0
	self.offset_y = 0.0
end

function BackgroundCity:update(dt)
	BackgroundCity.super.update(self, dt)
end

-----------------------------------------------------

function BackgroundCity:draw()
	BackgroundCity.super.draw(self)

	local cam_x, cam_y = game.camera:get_real_position()
	cam_x = math.floor(cam_x + self.offset_x)
	cam_y = math.floor(cam_y + self.offset_y)
	for i, layer in pairs(self.layers) do
		local z = layer.z
		local x = cam_x * (1 - 1/z)
		local y = cam_y * (1 - 1/z)
		for ix = x, cam_x + CANVAS_WIDTH + 16, layer.sprite.w do
			layer.sprite:draw(math.floor(ix), math.floor(y))
		end
	end
end

return BackgroundCity
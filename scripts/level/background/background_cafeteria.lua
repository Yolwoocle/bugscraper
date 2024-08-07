require "scripts.util"
local Background = require "scripts.level.background.background"
local Sprite = require "scripts.graphics.sprite"
local images = require "data.images"

local BackgroundCafeteria = Background:inherit()

function BackgroundCafeteria:init(level)
	self.super.init(self, level)

	self.clear_color = COL_BLACK_BLUE
	self.t = 0

	self.speed = 0

	self.layers = {
		{sprite = Sprite:new(images.bg_city_0, SPRITE_ANCHOR_TOP_LEFT), y = 0,  z = math.huge},
		{sprite = Sprite:new(images.bg_city_1, SPRITE_ANCHOR_TOP_LEFT), y = 16, z = 16},
		{sprite = Sprite:new(images.bg_city_2, SPRITE_ANCHOR_TOP_LEFT), y = 32, z = 8},
		{sprite = Sprite:new(images.bg_city_3, SPRITE_ANCHOR_TOP_LEFT), y = 64, z = 4},
	}
	self.shine_sprite = Sprite:new(images.bg_city_shine, SPRITE_ANCHOR_TOP_LEFT)
end

function BackgroundCafeteria:update(dt)
	self.super.update(self, dt)
end

-----------------------------------------------------

function BackgroundCafeteria:draw()
	self.super.draw(self)

	local cam_x, cam_y = game.camera:get_real_position()
	cam_x = math.floor(cam_x)
	cam_y = math.floor(cam_y)
	for i, layer in pairs(self.layers) do
		local y = layer.y
		local z = layer.z
		local x = cam_x * (1 - 1/z)
		for ix = x, cam_x + CANVAS_WIDTH + 16, layer.sprite.image:getWidth() do
			layer.sprite:draw(math.floor(ix), math.floor(cam_y + y))
		end
	end
	self.shine_sprite:draw(cam_x, cam_y)
end

return BackgroundCafeteria
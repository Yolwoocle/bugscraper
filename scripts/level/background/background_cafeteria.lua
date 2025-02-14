require "scripts.util"
local BackgroundCity = require "scripts.level.background.background_city"
local Sprite = require "scripts.graphics.sprite"
local images = require "data.images"

local BackgroundCafeteria = BackgroundCity:inherit()

function BackgroundCafeteria:init(level)
	BackgroundCafeteria.super.init(self, level)
	self.shine_sprite = Sprite:new(images.bg_city_shine, SPRITE_ANCHOR_LEFT_TOP)
end

function BackgroundCafeteria:update(dt)
	BackgroundCafeteria.super.update(self, dt)
end

-----------------------------------------------------

function BackgroundCafeteria:draw()
	BackgroundCafeteria.super.draw(self)

	local cam_x, cam_y = game.camera:get_real_position()
	cam_x = math.floor(cam_x)
	cam_y = math.floor(cam_y)
	self.shine_sprite:draw(cam_x, cam_y)
end

return BackgroundCafeteria
require "scripts.util"
local BackgroundCity = require "scripts.level.background.background_city"
local Sprite = require "scripts.graphics.sprite"
local images = require "data.images"

local BackgroundFinalBossIntro = BackgroundCity:inherit()

function BackgroundFinalBossIntro:init(level)
	BackgroundFinalBossIntro.super.init(self, level)

	self.name = "background_final_boss_intro"

	self.city = Sprite:new(images.final_boss_intro_building, SPRITE_ANCHOR_CENTER_TOP)

	self.rocket_y = CANVAS_CENTER[2] + 5
	self.rocket = Sprite:new(images.basement_rocket_small, SPRITE_ANCHOR_CENTER_TOP)
	self.house = Sprite:new(images.final_boss_intro_house, SPRITE_ANCHOR_RIGHT_BOTTOM)

	self.draw_star = false
end

function BackgroundFinalBossIntro:update(dt)
	BackgroundFinalBossIntro.super.update(self, dt)
end

-----------------------------------------------------

function BackgroundFinalBossIntro:draw()
	BackgroundFinalBossIntro.super.draw(self)

	local cam_x, cam_y = game.camera:get_real_position()
	cam_x = math.floor(cam_x)
	cam_y = math.floor(cam_y)
	
	Particles:draw_layer(PARTICLE_LAYER_CAFETERIA_BACKGROUND)

	if self.draw_star then
		draw_centered(images.star_big, CANVAS_WIDTH + CANVAS_CENTER[1], CANVAS_CENTER[2], -pi/2, 1, 1)
		exec_color(COL_YELLOW_ORANGE, function()
			draw_centered(images.star_big, CANVAS_WIDTH + CANVAS_CENTER[1], CANVAS_CENTER[2], -pi/2, 0.8, 0.8)
		end)
	end

	self.rocket:draw(CANVAS_WIDTH + CANVAS_CENTER[1], self.rocket_y)
	self.city:draw(CANVAS_WIDTH + CANVAS_CENTER[1], CANVAS_CENTER[2])
	self.house:draw(CANVAS_WIDTH * 2.0 + 20, CANVAS_HEIGHT)
end

return BackgroundFinalBossIntro
require "scripts.util"
local BackgroundCity = require "scripts.level.background.background_city"
local Sprite = require "scripts.graphics.sprite"
local images = require "data.images"

local BackgroundFinalBossIntro = BackgroundCity:inherit()

function BackgroundFinalBossIntro:init(level)
	BackgroundFinalBossIntro.super.init(self, level)

	self.name = "background_final_boss_intro"

	self.rocket_ox = 0
	self.rocket_oy = 0
	self.rocket_y = CANVAS_CENTER[2] + 5
	self.rocket = Sprite:new(images.basement_rocket_small, SPRITE_ANCHOR_CENTER_TOP)

	self.layers = {
		{sprite = Sprite:new(images.bg_city_1, SPRITE_ANCHOR_LEFT_TOP), y = 100, z = 16},
	}

	self.draw_star = false
end

function BackgroundFinalBossIntro:update(dt)
	BackgroundFinalBossIntro.super.update(self, dt)
end

-----------------------------------------------------

function BackgroundFinalBossIntro:draw()
	
	BackgroundFinalBossIntro.super.draw(self)
	
	local cam_x, cam_y = game.camera:get_real_position()
	love.graphics.draw(images.bg_city_0, cam_x, cam_y+120)

	cam_x = math.floor(cam_x)
	cam_y = math.floor(cam_y)
	
	if self.draw_star then
		draw_centered(images.rays_big, CANVAS_WIDTH + CANVAS_CENTER[1], CANVAS_CENTER[2], -pi/2, 1, 1)
		exec_color(COL_YELLOW_ORANGE, function()
			draw_centered(images.rays_big, CANVAS_WIDTH + CANVAS_CENTER[1], CANVAS_CENTER[2], -pi/2, 0.8, 0.8)
		end)
	end

	Particles:draw_layer(PARTICLE_LAYER_CAFETERIA_BACKGROUND)

	self.rocket:draw(CANVAS_WIDTH + CANVAS_CENTER[1] + self.rocket_ox, self.rocket_y + self.rocket_oy)
end

return BackgroundFinalBossIntro
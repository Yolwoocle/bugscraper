local Class = require "scripts.meta.class"
local Background = require "scripts.level.background.background"
local images     = require "data.images"
local shaders = require "data.shaders"

local BackgroundFinal = Background:inherit()

function BackgroundFinal:init(level)
	self.super.init(self, level)
	self.name = "background_final"

	self.clear_color = COL_LIGHT_BLUE
	
	self.parallax_y = 0
	self.bg_lines = {}
	for i=1, 30 do 
		table.insert(self.bg_lines, self:new_bg_line())
	end
end

function BackgroundFinal:new_bg_line()
	return {
		x = random_range(0, 480), 
		y = -80,
		dy = random_range(8, 16),
		h = random_range(30, 60),
	}
end

function BackgroundFinal:update(dt)
	self.super.update(self, dt)

	for i=1, #self.bg_lines do
		self.bg_lines[i].y = self.bg_lines[i].y + self.bg_lines[i].dy
		love.graphics.line(self.bg_lines[i].x, self.bg_lines[i].y, self.bg_lines[i].x, self.bg_lines[i].y + self.bg_lines[i].h)
		if self.bg_lines[i].y > CANVAS_HEIGHT then
			self.bg_lines[i] = self:new_bg_line()
		end
	end

	self.parallax_y = self.parallax_y + self:get_speed()*dt*0.06
end

function BackgroundFinal:draw()
	BackgroundFinal.super.draw(self)

	love.graphics.setColor(COL_WHITE)

	love.graphics.draw(images.bg_city_0, 0, 0)
	love.graphics.draw(images.bg_city_1, 0, self.parallax_y * 0.01)
	love.graphics.draw(images.bg_city_2, 0, self.parallax_y * 0.05)
	love.graphics.draw(images.bg_city_3, 0, self.parallax_y * 0.1)

	love.graphics.draw(images._test_shine, 0, 0)

	exec_using_shader(shaders.lighten, function()
		love.graphics.draw(game.layers[LAYER_OBJECTS].canvas, -4, -12)
	end)
	local y0 = (self.parallax_y * 5) % (96*2)
	local i_line = 1
	for iy=y0-(96*2), CANVAS_HEIGHT+100, 96 do
		local x0 = ternary(i_line % 2 == 0, -16, -16 - 32)
		for ix=x0, CANVAS_WIDTH, 64 do
			love.graphics.draw(images._test_window, ix, iy)
		end
		i_line = i_line + 1
	end

	for i=1, #self.bg_lines do
		love.graphics.line(self.bg_lines[i].x, self.bg_lines[i].y, self.bg_lines[i].x, self.bg_lines[i].y + self.bg_lines[i].h)
	end
end

return BackgroundFinal
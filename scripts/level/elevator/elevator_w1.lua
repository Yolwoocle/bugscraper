require "scripts.util"
local Elevator = require "scripts.level.elevator.elevator"
local ElevatorDoor = require "scripts.level.elevator_door"
local Timer = require "scripts.timer"

local teapot3d = require "data.models.teapot"
local Renderer3D = require "scripts.graphics.3d.renderer_3d"
local Object3D = require "scripts.graphics.3d.object_3d"

local images = require "data.images"

local ElevatorW1 = Elevator:inherit()

function ElevatorW1:init(level)
	ElevatorW1.super.init(self, level)
end

function ElevatorW1:update(dt)
	ElevatorW1.super.update(self, dt)
end

function ElevatorW1:draw(enemy_buffer, wave_progress)
	ElevatorW1.super.draw(self, enemy_buffer)
end

function ElevatorW1:draw_front()
	ElevatorW1.super.draw_front(self)
end

function ElevatorW1:draw_cabin()
	local cabin_rect = self.level.cabin_rect

	if self.layers["w3_cabin"] then
		rect_color(COL_DARK_GREEN, "fill", self.object_3d.position.x - 16, self.object_3d.position.y - 16, 34, 34)
		self.renderer_3d:draw()

		rect_color(COL_DARK_GREEN, "fill", cabin_rect.ax + 189, cabin_rect.ay + 39, 38, 12)
		draw_centered(images.cabin_bg_w3_tape, cabin_rect.ax + 195, cabin_rect.ay + 45, self.bg_fan_spin, 0.5, 0.5)
		draw_centered(images.cabin_bg_w3_tape, cabin_rect.ax + 221, cabin_rect.ay + 45, self.bg_fan_spin+1, 0.5, 0.5)
	end
	
	if self.layers["door"] then
		self.door:draw()
	end

	-- Cabin background
	if self.layers["cabin_bg"] then
		love.graphics.draw(self.layers["cabin_bg"], cabin_rect.ax, cabin_rect.ay)
	end
	if self.layers["bg_fan"] then
		draw_centered(images.cabin_bg_w2_fan, cabin_rect.ax + 367, cabin_rect.ay + 42, self.bg_fan_spin)
	end
	if self.layers["w3_cabin"] then
		exec_color({1, 1, 1, ternary(_G_fixed_frame % 4 < 2, 0.2, 0.7)}, function()
			love.graphics.draw(images.cabin_bg_w3_scanlines, cabin_rect.ax + 283, cabin_rect.ay + 113)
			love.graphics.draw(images.cabin_bg_w3_scanlines_big, cabin_rect.ax + 105, cabin_rect.ay + 106)
		end)
	end
	love.graphics.draw(images.cabin_bg_ambient_occlusion, cabin_rect.ax, cabin_rect.ay)
	
	if self.layers["bg_grid"] then
		love.graphics.draw(images.cabin_grid, cabin_rect.ax +   16, cabin_rect.ay + 4*16)
		love.graphics.draw(images.cabin_grid, cabin_rect.ax + 19*16, cabin_rect.ay + 4*16)
	end
	
	if self.layers["counter"] then
		self:draw_counter()
	end
end

function ElevatorW1:draw_counter()
	local door_x, door_y = self.level.door_rect.ax, self.level.door_rect.ay 
	
	-- Level counter clock thing
	local x1, y1 = door_x + 54.5, door_y - 33
	self.clock_ang = lerp(self.clock_ang, pi + clamp(self.level.floor / self.level.max_floor, 0, 1) * pi, 0.1)
	local a = self.clock_ang
	love.graphics.line(x1, y1, x1 + cos(a)*11, y1 + sin(a)*11)
	
	-- Level counter
	love.graphics.setFont(FONT_7SEG)
	print_color(COL_WHITE, string.sub("00000"..tostring(self.level.floor), -3, -1), 198+16*2, 97+16*2)
	love.graphics.setFont(FONT_REGULAR)
end

function ElevatorW1:start_grid_timer(time)
	self.grid_timer:set_duration(time)
	self.grid_timer:start()
end

return ElevatorW1
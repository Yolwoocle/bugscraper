require "scripts.util"
local Elevator = require "scripts.level.elevator.elevator"
local Timer = require "scripts.timer"

local teapot3d = require "data.models.teapot"
local Renderer3D = require "scripts.graphics.3d.renderer_3d"
local Object3D = require "scripts.graphics.3d.object_3d"

local images = require "data.images"

local ElevatorW3 = Elevator:inherit()

function ElevatorW3:init(level)
	ElevatorW3.super.init(self, level)

	self.layers["cabin_bg"] = images.cabin_bg_w3
	self.layers["walls"] = images.cabin_walls_w3
	
	self.layers["fg_grid"] = false
	self.layers["bg_grid"] = true
	
	self.def_ball_scale = 5
    self.object_3d = Object3D:new(teapot3d)
    self.renderer_3d = Renderer3D:new({self.object_3d})
    self.object_3d.scale:sset(self.def_ball_scale)
    self.object_3d.position.x = 150
    self.object_3d.position.y = 145
	self.renderer_3d.lighting_palette = {COL_MID_DARK_GREEN, COL_MID_GREEN, COL_LIGHT_GREEN}
	self.renderer_3d.line_color = {1, 1, 1, 0}

	self.grid_timer = Timer:new(1.5)

	self.bg_tape_spin = 0
	self.bg_tape_spin_speed = 2

	self.door:set_images(
		images.cabin_door_empty,
		images.cabin_door_w3_left_center,
		images.cabin_door_empty,
		images.cabin_door_w3_right_center
	)
end

function ElevatorW3:update(dt)
	ElevatorW3.super.update(self, dt)

	self.object_3d.rotation.x = self.object_3d.rotation.x + dt*0.34
    self.object_3d.rotation.y = self.object_3d.rotation.y + dt
	self.renderer_3d:update(dt)
	
	if self.grid_timer:update(dt) then
		self:set_layer("fg_grid", true)
	end

	self.bg_tape_spin = self.bg_tape_spin + self.bg_tape_spin_speed*dt
end

function ElevatorW3:draw(enemy_buffer, wave_progress)
	ElevatorW3.super.draw(self, enemy_buffer)
end

function ElevatorW3:draw_front()
	local cabin_rect = self.level.cabin_rect

	ElevatorW3.super.draw_front(self)

	if self.layers["fg_grid"] then
		love.graphics.draw(images.cabin_grid_platform, cabin_rect.ax +    16, cabin_rect.ay + 6*16)
		love.graphics.draw(images.cabin_grid_platform, cabin_rect.ax + 19*16, cabin_rect.ay + 6*16)
	end
end

function ElevatorW3:draw_cabin()
	local cabin_rect = self.level.cabin_rect

	-- 3D teapot
	rect_color(COL_DARK_GREEN, "fill", self.object_3d.position.x - 16, self.object_3d.position.y - 16, 34, 34)
	self.renderer_3d:draw()

	-- Rolling tape 
	rect_color(COL_DARK_GREEN, "fill", cabin_rect.ax + 189, cabin_rect.ay + 39, 38, 12)
	draw_centered(images.cabin_bg_w3_tape, cabin_rect.ax + 195, cabin_rect.ay + 45, self.bg_tape_spin, 0.5, 0.5)
	draw_centered(images.cabin_bg_w3_tape, cabin_rect.ax + 221, cabin_rect.ay + 45, self.bg_tape_spin+1, 0.5, 0.5)

	ElevatorW3.super.draw_cabin(self)
	
	-- Screen scanlines
	exec_color({1, 1, 1, ternary(_G_fixed_frame % 4 < 2, 0.2, 0.7)}, function()
		love.graphics.draw(images.cabin_bg_w3_scanlines, cabin_rect.ax + 283, cabin_rect.ay + 113)
		love.graphics.draw(images.cabin_bg_w3_scanlines_big, cabin_rect.ax + 105, cabin_rect.ay + 106)
	end)

	-- Grid images
	if self.layers["bg_grid"] then
		love.graphics.draw(images.cabin_grid, cabin_rect.ax +   16, cabin_rect.ay + 4*16)
		love.graphics.draw(images.cabin_grid, cabin_rect.ax + 19*16, cabin_rect.ay + 4*16)
	end
end

function ElevatorW3:draw_counter()
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

function ElevatorW3:start_grid_timer(time)
	self.grid_timer:set_duration(time)
	self.grid_timer:start()
end

return ElevatorW3
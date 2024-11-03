require "scripts.util"
local Class = require "scripts.meta.class"
local ElevatorDoor = require "scripts.level.elevator_door"
local Timer = require "scripts.timer"

local images = require "data.images"
local sounds = require "data.sounds"

local Elevator = Class:inherit()

function Elevator:init(level)
    self.level = level

	self.door = ElevatorDoor:new(self.level.door_rect.ax, self.level.door_rect.ay)
	self.door:close()

	self.floor_progress = 0.0
	self.door_animation = false
	self.has_switched_to_next_floor = false 

	self.door_animation_timer = Timer:new(1.0)
	self.layers = {
		["cabin"] = true,
		["walls"] = true,
		["bg_grid"] = true,
		["fg_grid"] = false,

		["cabin_brown"] = false,
		["walls_brown"] = false,
		["bg_grid_brown"] = false,
	}

	self.grid_timer = Timer:new(1.5)

	self.clock_ang = pi
end

function Elevator:update(dt)
	self:update_door_animation(dt)
	
	if self.door_animation_timer:update(dt) then
		self:close_door()
	end

	if self.grid_timer:update(dt) then
		self:set_layer("fg_grid", true)
	end
end

function Elevator:open_door(close_timer)
	self.door:open()
	sounds.elev_door_open.source:play()
	if close_timer then
		self.door_animation_timer:set_duration(close_timer)
		self.door_animation_timer:start()
	end
end

function Elevator:close_door()
	self.door:close()
	sounds.elev_door_close.source:play()
	self.door_animation_timer:stop()
	self.level:on_door_close()
end

function Elevator:update_door_animation(dt)
	self.door:update(dt)
	if self.floor_progress == 0 then return end
end

function Elevator:set_floor_progress(val)
	self.floor_progress = val
end

function Elevator:set_layer(layer, val)
	self.layers[layer] = val
end

---------------------------------------------

function Elevator:draw(enemy_buffer, wave_progress)
	-- Door
	local x, y = self.level.door_rect.ax, self.level.door_rect.ay
	local w, h = self.level.door_rect.bx - self.level.door_rect.ax+1, self.level.door_rect.by - self.level.door_rect.ay+1
	rect_color(self.level.background.clear_color, "fill", x, y, w, h);
	
	-- Draw buffered enemies
	for i,e in pairs(enemy_buffer) do
		e:draw()
	end
	-- local r = self.door_animation_timer.time / self.door_animation_timer.duration
	-- local col = self.level.background.clear_color
	-- rect_color({col[1], col[2], col[3], r}, "fill", self.level.door_rect.x, self.level.door_rect.y, self.level.door_rect.w, self.level.door_rect.h)
	-- print_outline(nil,nil,round(self.door_animation_timer.time / self.door_animation_timer.duration, 3), CANVAS_CENTER[1], CANVAS_CENTER[2])
	
	if self.layers["cabin"] then
		self:draw_cabin()
	end
end

function Elevator:draw_front()
	local cabin_rect = self.level.cabin_rect

	if self.layers["walls"] then
		gfx.draw(images.cabin_walls, self.level.cabin_rect.ax, self.level.cabin_rect.ay)
	end
	if self.layers["walls_brown"] then
		gfx.draw(images.cabin_walls_brown, self.level.cabin_rect.ax, self.level.cabin_rect.ay)
	end
	if self.layers["test"] then
		gfx.draw(images.test, self.level.cabin_rect.ax, self.level.cabin_rect.ay)
	end
	if self.layers["fg_grid"] then
		love.graphics.draw(images.cabin_grid_platform, cabin_rect.ax +    16, cabin_rect.ay + 6*16)
		love.graphics.draw(images.cabin_grid_platform, cabin_rect.ax + 19*16, cabin_rect.ay + 6*16)
	end
end

function Elevator:draw_cabin()
	local cabin_rect = self.level.cabin_rect

	self.door:draw()

	-- Cabin background
	if self.layers["cabin_brown"] then
		love.graphics.draw(images.cabin_bg_brown, cabin_rect.ax, cabin_rect.ay)
	else
		love.graphics.draw(images.cabin_bg, cabin_rect.ax, cabin_rect.ay)
	end
	love.graphics.draw(images.cabin_bg_ambient_occlusion, cabin_rect.ax, cabin_rect.ay)
	
	if self.layers["bg_grid"] then
		love.graphics.draw(images.cabin_grid, cabin_rect.ax +   16, cabin_rect.ay + 4*16)
		love.graphics.draw(images.cabin_grid, cabin_rect.ax + 19*16, cabin_rect.ay + 4*16)
	end
	if self.layers["bg_grid_brown"] then
		love.graphics.draw(images.cabin_grid_brown, cabin_rect.ax +   16, cabin_rect.ay + 4*16)
		love.graphics.draw(images.cabin_grid_brown, cabin_rect.ax + 19*16, cabin_rect.ay + 4*16)
	end
	
	self:draw_counter()
end

function Elevator:draw_counter()
	local cabin_x, cabin_y = self.level.cabin_rect.ax, self.level.cabin_rect.ay 
	
	-- Level counter clock thing
	local x1, y1 = cabin_x + 207.5, cabin_y + 89
	self.clock_ang = lerp(self.clock_ang, pi + clamp(self.level.floor / self.level.max_floor, 0, 1) * pi, 0.1)
	local a = self.clock_ang
	gfx.line(x1, y1, x1 + cos(a)*11, y1 + sin(a)*11)
	
	-- Level counter
	gfx.setFont(FONT_7SEG)
	print_color(COL_WHITE, string.sub("00000"..tostring(self.level.floor), -3, -1), 198+16*2, 97+16*2)
	gfx.setFont(FONT_REGULAR)
end

function Elevator:start_grid_timer(time)
	self.grid_timer:set_duration(time)
	self.grid_timer:start()
end

return Elevator
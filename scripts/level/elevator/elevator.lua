require "scripts.util"
local Class = require "scripts.meta.class"
local ElevatorDoor = require "scripts.level.elevator_door"
local Timer = require "scripts.timer"

local teapot3d = require "data.models.teapot"
local Renderer3D = require "scripts.graphics.3d.renderer_3d"
local Object3D = require "scripts.graphics.3d.object_3d"

local images = require "data.images"

local Elevator = Class:inherit()

function Elevator:init(level)
    self.level = level

	self.door = ElevatorDoor:new(self.level.door_rect.ax, self.level.door_rect.ay)
	self.door:close(false)

	self.floor_progress = 0.0
	self.door_animation = false

	self.door_animation_timer = Timer:new(1.0)
	self.layers = {
		["cabin"] = true,
		["counter"] = true,
		["door"] = true,
		["door_background"] = true,
		
		["bg_grid"] = false,
		["fg_grid"] = false,
		
		["cabin_bg"] = images.cabin_bg_w1,
		["walls"] = images.cabin_walls_w1,
		-- ["walls"] = true,

		["bg_fan"] = false,	
		["bg_grid_brown"] = false,	
		["w3_cabin"] = false,
		-- ["cabin_w3"] = false,
		-- ["walls_w3"] = false,

		["cabin_w4"] = false,
	}

	self.def_ball_scale = 5
    self.object_3d = Object3D:new(teapot3d)
    self.renderer_3d = Renderer3D:new({self.object_3d})
    self.object_3d.scale:sset(self.def_ball_scale)
    self.object_3d.position.x = 150
    self.object_3d.position.y = 145
	self.renderer_3d.lighting_palette = {COL_MID_DARK_GREEN, COL_MID_GREEN, COL_LIGHT_GREEN}
	self.renderer_3d.line_color = {1, 1, 1, 0}

	self.bg_fan_spin = 0
	self.bg_fan_spin_speed = 2

	self.grid_timer = Timer:new(1.5)

	self.clock_ang = pi
end

function Elevator:update(dt)
	self:update_door_animation(dt)

	self.object_3d.rotation.x = self.object_3d.rotation.x + dt
    self.object_3d.rotation.y = self.object_3d.rotation.y + dt
	self.renderer_3d:update(dt)

	self.bg_fan_spin = self.bg_fan_spin + self.bg_fan_spin_speed * dt
	
	if self.door_animation_timer:update(dt) then
		self:close_door()
	end

	if self.grid_timer:update(dt) then
		self:set_layer("fg_grid", true)
	end
end

function Elevator:set_door_opened(value)
	self.door:set_opened(value)
end

function Elevator:open_door(close_timer)
	self.door:open()
	if close_timer then
		self.door_animation_timer:set_duration(close_timer)
		self.door_animation_timer:start()
	end
end

function Elevator:close_door()
	self.door:close()
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

function Elevator:draw(enemy_buffer)
	-- Door
	if self.layers["cabin"] and self.layers["door"] and self.layers["door_background"] then
		local x, y = self.level.door_rect.ax, self.level.door_rect.ay
		local w, h = self.level.door_rect.bx - self.level.door_rect.ax+1, self.level.door_rect.by - self.level.door_rect.ay+1
		rect_color(self.level.background.clear_color, "fill", x, y, w, h);
	end
	
	-- Draw buffered enemies
	for i,e in pairs(enemy_buffer) do
		e:draw()
	end
	
	if self.layers["cabin"] then
		self:draw_cabin()
	end
end

function Elevator:draw_front()
	local cabin_rect = self.level.cabin_rect

	if self.layers["walls"] then
		love.graphics.draw(self.layers["walls"], self.level.cabin_rect.ax, self.level.cabin_rect.ay)
	end
	if self.layers["fg_grid"] then
		love.graphics.draw(images.cabin_grid_platform, cabin_rect.ax +    16, cabin_rect.ay + 6*16)
		love.graphics.draw(images.cabin_grid_platform, cabin_rect.ax + 19*16, cabin_rect.ay + 6*16)
	end
end

function Elevator:draw_cabin()
	local cabin_rect = self.level.cabin_rect
	
	if self.layers["door"] then
		self.door:draw()
	end

	-- Cabin background
	if self.layers["cabin_bg"] then
		love.graphics.draw(self.layers["cabin_bg"], cabin_rect.ax, cabin_rect.ay)
	end
	love.graphics.draw(images.cabin_bg_ambient_occlusion, cabin_rect.ax, cabin_rect.ay)
	
	if self.layers["counter"] then
		self:draw_counter()
	end
end

function Elevator:draw_counter()
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

function Elevator:start_grid_timer(time)
	self.grid_timer:set_duration(time)
	self.grid_timer:start()
end

return Elevator
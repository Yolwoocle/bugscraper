require "scripts.util"
local Class = require "scripts.meta.class"
local ElevatorDoorSlidingLarge = require "scripts.level.door.elevator_door_sliding_large"
local Timer = require "scripts.timer"
local Rect  = require "scripts.math.rect"

local images = require "data.images"

local Elevator = Class:inherit()

function Elevator:init(level)
    self.level = level

	self.name = "elevator"

	self.entrances = {
		main = {
			door = ElevatorDoorSlidingLarge:new(self.level.door_rect.ax, self.level.door_rect.ay),
			rect = Rect:new(186, 154, 293, 239)
		},
	}
	self.entrance_names = table_keys(self.entrances)

	self.floor_progress = 0.0
	self.door_animation = false

	self.door_animation_timer = Timer:new(1.0)
	self.layers = {
		["cabin"] = true,
		["counter"] = true,
		["door"] = true,
		["door_background"] = true,
		
		["ambient_occlusion"] = images.cabin_bg_ambient_occlusion,
		["cabin_bg"] = images.empty,
		["walls"] = images.empty,
	}

	self.clock_ang = pi

	self.counter_display_func = function(number)
		return number
	end
end

function Elevator:update(dt)
	self:update_door_animation(dt)

	if self.door_animation_timer:update(dt) then
		self:close_door()
	end
end

function Elevator:set_door_opened(entrance_name, value)
	assert(self.entrances[entrance_name], "Invalid entrance "..tostring(entrance_name))
	self.entrances[entrance_name].door:set_opened(value)
end

function Elevator:add_entrance(entrance_name, entrance)
	self.entrances[entrance_name] = entrance
	self.entrance_names = table_keys(self.entrances)
end

function Elevator:get_entrance(entrance_name)
	return self.entrances[entrance_name]
end

function Elevator:get_door(entrance_name)
	return (self.entrances[entrance_name] or {}).door
end

function Elevator:open_door(entrance_names, close_timer)
	entrance_names = entrance_names or self.entrance_names
	for _, entrance_name in pairs(entrance_names) do
		local entrance = self.entrances[entrance_name]
		if entrance then
			entrance.door:open()
		end
	end

	if close_timer then
		self.door_animation_timer:set_duration(close_timer)
		self.door_animation_timer:start()
	end
end

function Elevator:close_door(entrance_names)
	entrance_names = entrance_names or self.entrance_names
	for _, entrance_name in pairs(entrance_names) do
		local entrance = self.entrances[entrance_name]
		if entrance then
			entrance.door:close()
		end
	end

	self.door_animation_timer:stop()
	self.level:on_door_close()
end

function Elevator:update_door_animation(dt)
	for _, entrance in pairs(self.entrances) do
		entrance.door:update(dt)
	end
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
		for _, entrance in pairs(self.entrances) do
			rect_color(self.level.background.clear_color, "fill", entrance.rect.x, entrance.rect.y, entrance.rect.w+1, entrance.rect.h+1);
		end
	end
	
	-- Draw buffered enemies
	for i,e in pairs(enemy_buffer) do
		e:draw()
	end
	
	if self.layers["cabin"] then
		self:draw_cabin()
	end
	
	if self.layers["door"] then
		for _, entrance in pairs(self.entrances) do
			entrance.door:draw_front()
		end
	end
end

function Elevator:draw_front()
	if self.layers["walls"] then
		love.graphics.draw(self.layers["walls"], self.level.cabin_rect.ax, self.level.cabin_rect.ay)
	end
end

function Elevator:draw_cabin()
	local cabin_rect = self.level.cabin_rect
	
	if self.layers["door"] then
		for _, entrance in pairs(self.entrances) do
			entrance.door:draw()
		end
	end

	-- Cabin background
	if self.layers["cabin_bg"] then
		love.graphics.draw(self.layers["cabin_bg"], cabin_rect.ax, cabin_rect.ay)
	end
	if self.layers["ambient_occlusion"] then
		love.graphics.draw(self.layers["ambient_occlusion"], cabin_rect.ax, cabin_rect.ay)
	end
	
	if self.layers["counter"] then
		self:draw_counter()
	end
end

function Elevator:draw_counter()
	local door_x, door_y = self.level.door_rect.ax, self.level.door_rect.ay 
	
	-- Level counter clock thing
	local x1, y1 = door_x + 54.5, door_y - 33
	self.clock_ang = lerp(self.clock_ang, pi + clamp(self.counter_display_func(self.level.floor) / self.level.max_display_floor, 0, 1) * pi, 0.1)
	local a = self.clock_ang
	love.graphics.line(x1, y1, x1 + cos(a)*11, y1 + sin(a)*11)
	
	-- Level counter<
	love.graphics.setFont(FONT_7SEG)
	print_color(COL_WHITE, elevator_counter_format(self.counter_display_func(self.level.floor)), 198+16*2, 97+16*2)
	love.graphics.setFont(FONT_REGULAR)
end

return Elevator
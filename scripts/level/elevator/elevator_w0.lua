require "scripts.util"
local Elevator = require "scripts.level.elevator.elevator"
local ElevatorDoorSlidingLarge = require "scripts.level.door.elevator_door_sliding_large"
local ElevatorDoorTrapdoor = require "scripts.level.door.elevator_door_trapdoor"
local Rect  = require "scripts.math.rect"

local images = require "data.images"

local ElevatorW0 = Elevator:inherit()

function ElevatorW0:init(level)
	ElevatorW0.super.init(self, level)
	self.name = "elevator_w1"

	level:set_bounds(Rect:new(unpack(RECT_ELEVATOR_PARAMS)))

	self.layers["cabin_bg"] = images.cabin_bg_w1
	self.layers["walls"] = images.cabin_walls_w1

	self:get_door("main"):set_images(
		images.cabin_door_left_far,
		images.cabin_door_left_center,
		images.cabin_door_right_far,
		images.cabin_door_right_center
	)
	
	local cabin_rect_x = 32
	local cabin_rect_y = 32
	self:add_entrance("left_trapdoor", {
		door = ElevatorDoorTrapdoor:new(cabin_rect_x+33, cabin_rect_y+22, 44, 38, images.cabin_bg_w1_trapdoor, {direction = "down"}),
		rect = Rect:new(cabin_rect_x+33, cabin_rect_y+22, cabin_rect_x+76, cabin_rect_y+59)
	})
	self:add_entrance("right_trapdoor", {
		door = ElevatorDoorTrapdoor:new(cabin_rect_x+339, cabin_rect_y+22, 44, 38, images.cabin_bg_w1_trapdoor, {direction = "down"}),
		rect = Rect:new(cabin_rect_x+339, cabin_rect_y+22, cabin_rect_x+382, cabin_rect_y+59)
	})
	self:add_entrance("left_vent", {
		door = ElevatorDoorTrapdoor:new(cabin_rect_x+32, cabin_rect_y+153, 66, 50, images.cabin_bg_w1_ventilation_shaft, {direction = "up"}),
		rect = Rect:new(cabin_rect_x+32, cabin_rect_y+153, cabin_rect_x+97, cabin_rect_y+202)
	})
	self:add_entrance("right_vent", {
		door = ElevatorDoorTrapdoor:new(cabin_rect_x+318, cabin_rect_y+153, 66, 50, images.cabin_bg_w1_ventilation_shaft, {direction = "up"}),
		rect = Rect:new(cabin_rect_x+318, cabin_rect_y+153, cabin_rect_x+383, cabin_rect_y+202)
	})
end

function ElevatorW0:update(dt)
	ElevatorW0.super.update(self, dt)
end

function ElevatorW0:draw(enemy_buffer, wave_progress)
	ElevatorW0.super.draw(self, enemy_buffer)
end

function ElevatorW0:draw_front()
	ElevatorW0.super.draw_front(self)
end

function ElevatorW0:draw_cabin()
	ElevatorW0.super.draw_cabin(self)
end

return ElevatorW0
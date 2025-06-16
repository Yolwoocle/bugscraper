require "scripts.util"
local Elevator = require "scripts.level.elevator.elevator"
local ElevatorDoorSlidingLarge = require "scripts.level.door.elevator_door_sliding_large"
local ElevatorDoorTrapdoor = require "scripts.level.door.elevator_door_trapdoor"
local Rect  = require "scripts.math.rect"

local images = require "data.images"

local ElevatorW1 = Elevator:inherit()

function ElevatorW1:init(level)
	ElevatorW1.super.init(self, level)

	self.layers["cabin_bg"] = images.cabin_bg_w1
	self.layers["walls"] = images.cabin_walls_w1

	self:get_door("main"):set_images(
		images.cabin_door_left_far,
		images.cabin_door_left_center,
		images.cabin_door_right_far,
		images.cabin_door_right_center
	)
	
	self:add_entrance("left_trapdoor", {
		door = ElevatorDoorTrapdoor:new(level.cabin_rect.ax+33, level.cabin_rect.ay+22, 44, 38, images.cabin_bg_w1_trapdoor, {direction = "down"}),
		rect = Rect:new(level.cabin_rect.ax+33, level.cabin_rect.ay+22, level.cabin_rect.ax+76, level.cabin_rect.ay+59)
	})
	self:add_entrance("right_trapdoor", {
		door = ElevatorDoorTrapdoor:new(level.cabin_rect.ax+339, level.cabin_rect.ay+22, 44, 38, images.cabin_bg_w1_trapdoor, {direction = "down"}),
		rect = Rect:new(level.cabin_rect.ax+339, level.cabin_rect.ay+22, level.cabin_rect.ax+382, level.cabin_rect.ay+59)
	})
	self:add_entrance("left_vent", {
		door = ElevatorDoorTrapdoor:new(level.cabin_rect.ax+32, level.cabin_rect.ay+153, 66, 50, images.cabin_bg_w1_ventilation_shaft, {direction = "up"}),
		rect = Rect:new(level.cabin_rect.ax+32, level.cabin_rect.ay+153, level.cabin_rect.ax+97, level.cabin_rect.ay+202)
	})
	self:add_entrance("right_vent", {
		door = ElevatorDoorTrapdoor:new(level.cabin_rect.ax+318, level.cabin_rect.ay+153, 66, 50, images.cabin_bg_w1_ventilation_shaft, {direction = "up"}),
		rect = Rect:new(level.cabin_rect.ax+318, level.cabin_rect.ay+153, level.cabin_rect.ax+383, level.cabin_rect.ay+202)
	})
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
	ElevatorW1.super.draw_cabin(self)
end

return ElevatorW1
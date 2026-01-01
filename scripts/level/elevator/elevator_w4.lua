require "scripts.util"
local Elevator                 = require "scripts.level.elevator.elevator"
local ElevatorDoorSlidingLarge = require "scripts.level.door.elevator_door_sliding_large"
local ElevatorDoorTrapdoor     = require "scripts.level.door.elevator_door_trapdoor"
local Rect                     = require "scripts.math.rect"

local images                   = require "data.images"

local ElevatorW4               = Elevator:inherit()

function ElevatorW4:init(level)
	ElevatorW4.super.init(self, level)
	self.name = "elevator_w4"

	level:set_bounds(Rect:new(unpack(RECT_ELEVATOR_PARAMS)))

	self.layers["cabin_bg"] = images.cabin_bg_w4
	self.layers["walls"] = images.cabin_walls_w4

	self:get_door("main"):set_images(
		images.cabin_door_w4_left_far,
		images.cabin_door_w4_left_center,
		images.cabin_door_w4_right_far,
		images.cabin_door_w4_right_center
	)
end

function ElevatorW4:update(dt)
	ElevatorW4.super.update(self, dt)
end

function ElevatorW4:draw(enemy_buffer, wave_progress)
	ElevatorW4.super.draw(self, enemy_buffer)
end

function ElevatorW4:draw_front()
	ElevatorW4.super.draw_front(self)
end

function ElevatorW4:draw_cabin()
	ElevatorW4.super.draw_cabin(self)
end

return ElevatorW4

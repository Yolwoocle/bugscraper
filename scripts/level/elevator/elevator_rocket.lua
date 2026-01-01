require "scripts.util"
local Elevator                 = require "scripts.level.elevator.elevator"
local ElevatorDoorSlidingLarge = require "scripts.level.door.elevator_door_sliding_large"
local ElevatorDoorTrapdoor     = require "scripts.level.door.elevator_door_trapdoor"
local Rect                     = require "scripts.math.rect"

local images                   = require "data.images"

local ElevatorRocket               = Elevator:inherit()

function ElevatorRocket:init(level)
	ElevatorRocket.super.init(self, level)
	self.name = "elevator_rocket"

	level:set_bounds(Rect:new(unpack(RECT_ELEVATOR_PARAMS)))

	self.layers["cabin_bg"] = images.cabin_bg_rocket
	self.layers["walls"] = images.empty

	self:get_door("main"):set_images(
		images.cabin_door_left_far,
		images.cabin_door_left_center,
		images.cabin_door_right_far,
		images.cabin_door_right_center
	)
end

function ElevatorRocket:update(dt)
	ElevatorRocket.super.update(self, dt)
end

function ElevatorRocket:draw(enemy_buffer, wave_progress)
	ElevatorRocket.super.draw(self, enemy_buffer)
end

function ElevatorRocket:draw_front()
	ElevatorRocket.super.draw_front(self)

	love.graphics.draw(images.cabin_walls_rocket, 0, 0)
end

function ElevatorRocket:draw_cabin()
	ElevatorRocket.super.draw_cabin(self)
end

return ElevatorRocket

require "scripts.util"
local images = require "data.images"

local ElevatorDoor = require "scripts.level.door.elevator_door"
local sounds = require "data.sounds"

local ElevatorDoorSliding = ElevatorDoor:inherit()

function ElevatorDoorSliding:init(x, y, w, h, image_left_far, image_left_center, image_right_far, image_right_center)
	ElevatorDoorSliding.super.init(self, x, y, w or 108, h or 86)

	self:set_images(
		image_left_far or images.cabin_door_left_far,
		image_left_center or images.cabin_door_left_center,
		image_right_far or images.cabin_door_right_far,
		image_right_center or images.cabin_door_right_center
	)

	self.half_width = 54
end

function ElevatorDoorSliding:set_images(image_left_far, image_left_center, image_right_far, image_right_center)
	self.image_left_far = image_left_far or images.cabin_door_left_far
	self.image_left_center = image_left_center or images.cabin_door_left_center
	self.image_right_far = image_right_far or images.cabin_door_right_far
	self.image_right_center = image_right_center or images.cabin_door_right_center
end

function ElevatorDoorSliding:update(dt)
	ElevatorDoorSliding.super.update(self, dt)
end

function ElevatorDoorSliding:draw()
	-- Doors
	local offset = self.offset * self.w/2
	local door_x_left_center =  self.x - offset
	local door_x_right_center = self.x + offset
	local door_x_left_far =     self.x - math.max(0, offset - 54/2)
	local door_x_right_far =    self.x + math.max(0, offset - 54/2)
	local door_y = self.y
	love.graphics.draw(self.image_left_center,  door_x_left_center,  door_y)
	love.graphics.draw(self.image_right_center, door_x_right_center, door_y)
	love.graphics.draw(self.image_left_far,     door_x_left_far,     door_y)
	love.graphics.draw(self.image_right_far,    door_x_right_far,    door_y)
end

return ElevatorDoorSliding
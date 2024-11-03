require "scripts.util"
local images = require "data.images"

local Class = require "scripts.meta.class"

local ElevatorDoor = Class:inherit()

function ElevatorDoor:init(x, y, image_left_far, image_left_center, image_right_far, image_right_center)
	self.offset = 0.0
	self.offset_target = 0.0

	self.image_left_far = image_left_far or images.cabin_door_left_far
	self.image_left_center = image_left_center or images.cabin_door_left_center
	self.image_right_far = image_right_far or images.cabin_door_right_far
	self.image_right_center = image_right_center or images.cabin_door_right_center

	self.half_width = 54
	
	self.x = x
	self.y = y

	self.w = w or 108
	self.is_opened = false
end

function ElevatorDoor:set_images(image_left_far, image_left_center, image_right_far, image_right_center)
	self.image_left_far = image_left_far or images.cabin_door_left_far
	self.image_left_center = image_left_center or images.cabin_door_left_center
	self.image_right_far = image_right_far or images.cabin_door_right_far
	self.image_right_center = image_right_center or images.cabin_door_right_center
end

function ElevatorDoor:update(dt)
	self.offset = lerp(self.offset, self.offset_target, 0.1)
end

function ElevatorDoor:close()
	self.is_opened = false
	self.offset_target = 0
end

function ElevatorDoor:open()
	self.is_opened = true
	self.offset_target = self.half_width
end

function ElevatorDoor:draw()
	-- Doors
	local door_x_left_center =  self.x - self.offset
	local door_x_right_center = self.x + self.w/2 + self.offset
	local door_x_left_far =     self.x - math.max(0, self.offset - 54/2)
	local door_x_right_far =    self.x + self.w/2 + math.max(0, self.offset - 54/2)
	local door_y = self.y
	gfx.draw(self.image_left_center,  door_x_left_center,  door_y)
	gfx.draw(self.image_right_center, door_x_right_center, door_y)
	gfx.draw(self.image_left_far,     door_x_left_far,     door_y)
	gfx.draw(self.image_right_far,    door_x_right_far,    door_y)
end

return ElevatorDoor
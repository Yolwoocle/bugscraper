require "scripts.util"
local images = require "data.images"

local Class = require "scripts.meta.class"

local ElevatorDoor = Class:inherit()

function ElevatorDoor:init(x, y, w)
	self.offset = 0.0
	self.offset_target = 0.0

	self.half_width = 54
	
	self.x = x
	self.y = y

	self.w = w or 108
end

function ElevatorDoor:update(dt)
	self.offset = lerp(self.offset, self.offset_target, 0.1)
end

function ElevatorDoor:close()
	self.offset_target = 0
end

function ElevatorDoor:open()
	self.offset_target = self.half_width
end

function ElevatorDoor:draw()
	-- Doors
	local door_x_left_center =  self.x - self.offset
	local door_x_right_center = self.x + self.w/2 + self.offset
	local door_x_left_far =     self.x - math.max(0, self.offset - 54/2)
	local door_x_right_far =    self.x + self.w/2 + math.max(0, self.offset - 54/2)
	local door_y = self.y
	gfx.draw(images.cabin_door_left_center,  door_x_left_center,  door_y)
	gfx.draw(images.cabin_door_right_center, door_x_right_center, door_y)
	gfx.draw(images.cabin_door_left_far,     door_x_left_far,     door_y)
	gfx.draw(images.cabin_door_right_far,    door_x_right_far,    door_y)
end

return ElevatorDoor
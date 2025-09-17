require "scripts.util"
local images = require "data.images"

local ElevatorDoorSliding = require "scripts.level.door.elevator_door_sliding"
local sounds = require "data.sounds"

local ElevatorDoorSlidingLarge = ElevatorDoorSliding:inherit()

function ElevatorDoorSlidingLarge:init(x, y)
	ElevatorDoorSlidingLarge.super.init(self, x, y, 108, 86,
		images.cabin_door_left_far,
		images.cabin_door_left_center,
		images.cabin_door_right_far,
		images.cabin_door_right_center
	)
	
    self.sound_open = "sfx_door_open"
    self.sound_close = "sfx_door_close"
end

return ElevatorDoorSlidingLarge
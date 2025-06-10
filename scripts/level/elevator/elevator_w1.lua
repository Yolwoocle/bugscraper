require "scripts.util"
local Elevator = require "scripts.level.elevator.elevator"

local images = require "data.images"

local ElevatorW1 = Elevator:inherit()

function ElevatorW1:init(level)
	ElevatorW1.super.init(self, level)

	self.layers["cabin_bg"] = images.cabin_bg_w1
	self.layers["walls"] = images.cabin_walls_w1
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
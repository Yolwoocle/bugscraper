require "scripts.util"
local Elevator = require "scripts.level.elevator.elevator"

local images = require "data.images"

local ElevatorW2 = Elevator:inherit()

function ElevatorW2:init(level)
	ElevatorW2.super.init(self, level)

	self.name = "elevator_w2"

	self.layers["cabin_bg"] = images.cabin_bg_w2
	self.layers["walls"] = images.cabin_walls_w2
	
	self.bg_fan_spin = 0
	self.bg_fan_spin_speed = 2

	self:get_door("main"):set_images(
		images.cabin_door_bee_left_far,
		images.cabin_door_bee_left_center,
		images.cabin_door_bee_right_far,
		images.cabin_door_bee_right_center
	)
end

function ElevatorW2:update(dt)
	ElevatorW2.super.update(self, dt)

	self.bg_fan_spin = self.bg_fan_spin + self.bg_fan_spin_speed * dt
end

function ElevatorW2:draw(enemy_buffer, wave_progress)
	ElevatorW2.super.draw(self, enemy_buffer)
end

function ElevatorW2:draw_front()
	ElevatorW2.super.draw_front(self)
end

function ElevatorW2:draw_cabin()
	ElevatorW2.super.draw_cabin(self)

	local cabin_rect = self.level.cabin_rect

	draw_centered(images.cabin_bg_w2_fan, cabin_rect.ax + 367, cabin_rect.ay + 42, self.bg_fan_spin)
end

function ElevatorW2:start_grid_timer(time)
	self.grid_timer:set_duration(time)
	self.grid_timer:start()
end

return ElevatorW2
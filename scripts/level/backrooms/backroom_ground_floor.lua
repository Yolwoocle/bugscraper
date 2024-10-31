require "scripts.util"
local upgrades = require "data.upgrades"
local images = require "data.images"
local Backroom = require "scripts.level.backrooms.backroom"
local BackgroundCafeteria = require "scripts.level.background.background_cafeteria"
local ElevatorDoor       = require "scripts.level.elevator_door"

local BackroomGroundFloor = Backroom:inherit()

function BackroomGroundFloor:init()
    BackroomGroundFloor.super.init()

	self.cafeteria_background = BackgroundCafeteria:new(self)
	self.door = ElevatorDoor:new(186, 154, images.cabin_door_light_left_far, images.cabin_door_light_left_center, images.cabin_door_light_right_far, images.cabin_door_light_right_center)

	self.has_opened_door = false
	self.all_in_front = false

	self.close_door_timer = 0.5
end

function BackroomGroundFloor:generate(world_generator)
    world_generator:generate_ground_floor()
end

function BackroomGroundFloor:can_exit()
	if not game.can_start_game then
		return false
	end
	
	if #game.players == 0 then
		return false
	end
	for _, p in pairs(game.players) do
		if not is_point_in_rect(p.mid_x, p.mid_y, game.level.door_rect) then
			return false
		end
	end
	return true
end

function BackroomGroundFloor:on_exit()
    game:start_game()

	self.all_in_front = true
end

function BackroomGroundFloor:update(dt)
	if self.all_in_front then
		self.close_door_timer = self.close_door_timer - dt
		if self.close_door_timer < 0 then
			self.door:close()
		end
	end

	self.door:update(dt)

	if game.can_start_game and not self.has_opened_door then
		self.door:open()
		self.has_opened_door = true
	end
end


function BackroomGroundFloor:draw()	
	self.cafeteria_background:draw()
	love.graphics.draw(images.elevator_through_door, self.door.x, self.door.y)

	if not self.all_in_front then
		self:draw_all()
	end
end

function BackroomGroundFloor:draw_all()	
	self.door:draw()
	love.graphics.draw(images.ground_floor, -16, -16)
end

function BackroomGroundFloor:draw_front()	
	if self.all_in_front then
		self:draw_all()
	else
		love.graphics.draw(images.ground_floor_front, -16, -16)
	end
end

return BackroomGroundFloor
require "scripts.util"
local upgrades = require "data.upgrades"
local images = require "data.images"
local enemies = require "data.enemies"
local Backroom = require "scripts.level.backrooms.backroom"
local BackgroundCafeteria = require "scripts.level.background.background_cafeteria"
local ElevatorDoor       = require "scripts.level.elevator_door"
local TvPresentation    = require "scripts.level.background.layer.tv_presentation"
local WaterDispenser   = require "scripts.actor.enemies.vending_machine.water_dispenser"

local BackroomWithDoor = Backroom:inherit()

function BackroomWithDoor:init()
    BackroomWithDoor.super.init(self)
	self.name = "backroom_with_door"

	self.door = ElevatorDoor:new(186, 154, images.cabin_door_light_left_far, images.cabin_door_light_left_center, images.cabin_door_light_right_far, images.cabin_door_light_right_center)

	self.all_in_front = false

	self.close_door_timer = 0.5
end

function BackroomWithDoor:can_exit()
	-- By default, axit if all players are on the door 
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

function BackroomWithDoor:on_exit()
	self.all_in_front = true
end

function BackroomWithDoor:update(dt)
	if self.all_in_front then
		self.close_door_timer = self.close_door_timer - dt
		if self.close_door_timer < 0 then
			self.door:close()
		end
	end

	self.door:update(dt)
end

function BackroomWithDoor:close_door(play_sound)
	self.door:close(play_sound)
end

function BackroomWithDoor:open_door(play_sound)
	self.door:open(play_sound)
end

function BackroomWithDoor:draw_background()
end

function BackroomWithDoor:draw_items()	
	self.door:draw()
end

function BackroomWithDoor:draw_front_walls()
end

function BackroomWithDoor:draw()	
	self:draw_background()

	if not self.all_in_front then
		self:draw_items()
	end
end

function BackroomWithDoor:draw_front()
	if self.all_in_front then
		self:draw_items()
	end
	self:draw_front_walls()
	
end

return BackroomWithDoor
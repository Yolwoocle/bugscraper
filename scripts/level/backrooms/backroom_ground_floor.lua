require "scripts.util"
local upgrades = require "data.upgrades"
local images = require "data.images"
local enemies = require "data.enemies"
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
	
	for _, prop_data in pairs({
		{x = 482-16, y = 219-16, img = images.ground_floor_cactus},
		{x = 433-16, y = 224-16, img = images.ground_floor_computer_left},
		{x = 518-16, y = 223-16, img = images.ground_floor_computer_left},
		{x = 454-16, y = 232-16, img = images.ground_floor_mug},
		{x = 79-16, y = 213-16, img = images.ground_floor_potted_tree},
		{x = 715-16, y = 213-16, img = images.ground_floor_potted_plant},
		{x = 644-16, y = 222-16, img = images.ground_floor_lamp},
		{x = 574-16, y = 222-16, img = images.ground_floor_computer_right},
		{x = 651-16, y = 222-16, img = images.ground_floor_computer_right},

		{x = 386-16, y = 212-16, z = -10, img = images.ground_floor_stack_papers_big},
		{x = 404-16, y = 208-16, z = -10, img = images.ground_floor_stack_papers_medium},
		{x = 412-16, y = 224-16, z = -11, img = images.ground_floor_stack_papers_medium},
		{x = 422-16, y = 232-16, z = -11, img = images.ground_floor_stack_papers_small},
		{x = 494-16, y = 224-16, z = -10, img = images.ground_floor_stack_papers_medium_b},
		{x = 528-16, y = 232-16, z = -10, img = images.ground_floor_stack_papers_small},
		{x = 500-16, y = 190-16, z = -10, img = images.ground_floor_stack_papers_big},
		{x = 563-16, y = 212-16, z = -10, img = images.ground_floor_stack_papers_big},
		{x = 558-16, y = 248-16, z = -11, img = images.ground_floor_stack_papers_small},
		{x = 618-16, y = 225-16, z = -11, img = images.ground_floor_stack_papers_medium_b},
		{x = 696-16, y = 212-16, z = -11, img = images.ground_floor_stack_papers_big},
		{x = 688-16, y = 225-16, z = -12, img = images.ground_floor_stack_papers_medium},
		{x = 678-16, y = 225-16, z = -12, img = images.ground_floor_stack_papers_small},
	}) do
		local prop = enemies.JumpingProp:new(prop_data.x, prop_data.y, prop_data.img)
		if prop_data.z then
			prop.z = prop_data.z
		end
		game:new_actor(prop)
	end
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
	game.level.elevator:draw_counter()
	print_centered_outline(COL_WHITE, COL_BLACK_BLUE, Text:text("menu.credits.game_by_template", "Léo Bernard"), 536, 7*16)

	--215, 79
	for ix = 0, 54 do
		for iy = 0, 30 do
			exec_color(random_sample {COL_WHITE, COL_LIGHTEST_GRAY, COL_LIGHT_GRAY}, function()
				love.graphics.points(715 + ix, 79 + iy)
			end)
		end
	end
end

function BackroomGroundFloor:draw_front()	
	if self.all_in_front then
		self:draw_all()
	else
		love.graphics.draw(images.ground_floor_front, -16, -16)
	end
end

return BackroomGroundFloor
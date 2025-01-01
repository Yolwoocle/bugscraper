require "scripts.util"
local images = require "data.images"
local enemies = require "data.enemies"
local BackroomWithDoor = require "scripts.level.backrooms.backroom_with_door"
local BackgroundCafeteria = require "scripts.level.background.background_cafeteria"
local ElevatorDoor       = require "scripts.level.elevator_door"
local TvPresentation    = require "scripts.level.background.tv_presentation"
local WaterDispenser   = require "scripts.actor.enemies.vending_machine.water_dispenser"

local BackroomGroundFloor = BackroomWithDoor:inherit()

function BackroomGroundFloor:init()
    BackroomGroundFloor.super.init(self)
	self.name = "ground_floor"

	self.cafeteria_background = BackgroundCafeteria:new(self)
	self.door = ElevatorDoor:new(186, 154, images.cabin_door_light_left_far, images.cabin_door_light_left_center, images.cabin_door_light_right_far, images.cabin_door_light_right_center)

	self.all_in_front = false

	self.close_door_timer = 0.5
	self.tv_presentation = TvPresentation:new(715, 100)

	self.has_opened_door = false
end

function BackroomGroundFloor:generate(world_generator)
	game.camera.max_x = CANVAS_WIDTH
	
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

	-- Water dispenser
	game:new_actor(WaterDispenser:new(845, 212-16))

	-- Start button
	local nx = CANVAS_WIDTH * 0.7
	local ny = game.level.cabin_inner_rect.by
	local l = create_actor_centered(enemies.ButtonSmallGlass, floor(nx), floor(ny))
	game:new_actor(l)

	-- Exit sign
	local exit_x = CANVAS_WIDTH * 0.25
	game:new_actor(create_actor_centered(enemies.ExitSign, floor(744), floor(ny)))

	game:new_actor(create_actor_centered(enemies.Clock, floor(440), floor(105)))
end

function BackroomGroundFloor:can_exit()
	if not game.can_start_game then
		return false
	end
	if not self.has_opened_door then
		return false
	end
	
	return BackroomGroundFloor.super.can_exit(self)
end

function BackroomGroundFloor:on_exit()
	BackroomGroundFloor.super.on_exit(self)
    game:start_game()
end

function BackroomGroundFloor:update(dt)
	BackroomGroundFloor.super.update(self, dt)

	self.tv_presentation:update(dt)

	if game.can_start_game and not self.has_opened_door then
		self:open_door()
		self.has_opened_door = true
	end
end

function BackroomGroundFloor:draw_background()
	self.cafeteria_background:draw()
	love.graphics.draw(images.elevator_through_door, self.door.x, self.door.y)
end

function BackroomGroundFloor:draw_items()
	self.door:draw()
	love.graphics.draw(images.ground_floor, -16, -16)
	game.level.elevator:draw_counter()

	self.tv_presentation:draw()
end

function BackroomGroundFloor:draw_front_walls()
	love.graphics.draw(images.ground_floor_front, -16, -16)
end

return BackroomGroundFloor
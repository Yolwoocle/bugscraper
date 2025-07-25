require "scripts.util"
local images = require "data.images"
local enemies = require "data.enemies"
local npcs = require "data.npcs"
local BackroomWithDoor = require "scripts.level.backroom.backroom_with_door"
local BackgroundCafeteria = require "scripts.level.background.background_cafeteria"
local ElevatorDoorSlidingLarge = require "scripts.level.door.elevator_door_sliding_large"
local TvPresentation    = require "scripts.level.background.tv_presentation"
local WaterDispenser   = require "scripts.actor.enemies.vending_machine.water_dispenser"
local Rect = require "scripts.math.rect"

local BackroomGroundFloor = BackroomWithDoor:inherit()

function BackroomGroundFloor:init(params)
	params = params or {}
    BackroomGroundFloor.super.init(self, params)
	self.name = "ground_floor"

	self.cafeteria_background = BackgroundCafeteria:new(self)
	self.door = ElevatorDoorSlidingLarge:new(186, 154)
	self.door:set_images(images.cabin_door_light_left_far, images.cabin_door_light_left_center, images.cabin_door_light_right_far, images.cabin_door_light_right_center)

	self.all_in_front = false

	self.close_door_timer = 0.5
	self.tv_presentation = TvPresentation:new(715, 100)

	self.has_opened_door = false
end

function BackroomGroundFloor:generate(world_generator)
	game.camera.max_x = CANVAS_WIDTH + 11*16
	
    world_generator:reset()
	world_generator:write_rect(Rect:new(2, 3, 68, 15), TILE_METAL)
	world_generator:write_rect(Rect:new(2, 15, 68, 15), TILE_CARPET)

	-- tables
	for _, params in pairs({
		{Rect:new(24, 14, 27, 14), TILE_WOOD_SEMISOLID}, -- Desks
		{Rect:new(24+5*1, 14, 27+5*1, 14), TILE_WOOD_SEMISOLID}, -- Desks
		{Rect:new(24+5*2, 14, 27+5*2, 14), TILE_WOOD_SEMISOLID}, -- Desks
		{Rect:new(24+5*3, 14, 27+5*3, 14), TILE_WOOD_SEMISOLID}, -- Desks
		{Rect:new(51, 12, 54, 12), TILE_METAL_SEMISOLID}, -- Machines
		{Rect:new(64, 10, 65, 10), TILE_METAL_SEMISOLID}, -- Ladder
	}) do
		world_generator:write_rect(params[1], params[2])
	end
	
	for _, prop_data in pairs({
		{x = 482-16, y = 218-16, z = 0, img = images.ground_floor_cactus,                sound = "sfx_actor_jumping_prop_plant_small_{01-04}"},
		{x = 433-16, y = 223-16, z = 0, img = images.ground_floor_computer_left,         sound = "sfx_actor_jumping_prop_screen_{01-04}"},
		{x = 518-16, y = 223-16, z = 0, img = images.ground_floor_computer_left,         sound = "sfx_actor_jumping_prop_screen_{01-04}"},
		{x = 454-16, y = 232-16, z = 0, img = images.ground_floor_mug,                   sound = "sfx_actor_jumping_prop_mug_{01-02}"},
		{x = 79-16,  y = 213-16, z = 0, img = images.ground_floor_potted_tree,           sound = "empty"},
		{x = 146,    y = 213-16, z = 0, img = images.ground_floor_potted_plant,          sound = "empty"},
		{x = 644-16, y = 222-16, z = 0, img = images.ground_floor_lamp,                  sound = "empty"},
		{x = 574-16, y = 222-16, z = 0, img = images.ground_floor_computer_right,        sound = "sfx_actor_jumping_prop_screen_{01-04}"},
		{x = 651-16, y = 222-16, z = 0, img = images.ground_floor_computer_right,        sound = "sfx_actor_jumping_prop_screen_{01-04}"},
		{x = 386-16, y = 211-16, z = 2, img = images.ground_floor_stack_papers_big,      sound = "sfx_actor_jumping_prop_paper_stack_{01-04}"},
		{x = 404-16, y = 207-16, z = 2, img = images.ground_floor_stack_papers_medium,   sound = "sfx_actor_jumping_prop_paper_stack_{01-04}"},
		{x = 412-16, y = 224-16, z = 1, img = images.ground_floor_stack_papers_medium,   sound = "sfx_actor_jumping_prop_paper_stack_{01-04}"},
		{x = 422-16, y = 232-16, z = 1, img = images.ground_floor_stack_papers_small,    sound = "sfx_actor_jumping_prop_paper_stack_{01-04}"},
		{x = 494-16, y = 224-16, z = 2, img = images.ground_floor_stack_papers_medium_b, sound = "sfx_actor_jumping_prop_paper_stack_{01-04}"},
		{x = 528-16, y = 232-16, z = 2, img = images.ground_floor_stack_papers_small,    sound = "sfx_actor_jumping_prop_paper_stack_{01-04}"},
		{x = 500-16, y = 190-16, z = 2, img = images.ground_floor_stack_papers_big,      sound = "sfx_actor_jumping_prop_paper_stack_{01-04}"},
		{x = 563-16, y = 212-16, z = 2, img = images.ground_floor_stack_papers_big,      sound = "sfx_actor_jumping_prop_paper_stack_{01-04}"},
		{x = 558-16, y = 248-16, z = 1, img = images.ground_floor_stack_papers_small,    sound = "sfx_actor_jumping_prop_paper_stack_{01-04}"},
		{x = 618-16, y = 225-16, z = 1, img = images.ground_floor_stack_papers_medium_b, sound = "sfx_actor_jumping_prop_paper_stack_{01-04}"},
		{x = 696-16, y = 212-16, z = 1, img = images.ground_floor_stack_papers_big,      sound = "sfx_actor_jumping_prop_paper_stack_{01-04}"},
		{x = 688-16, y = 225-16, z = 0, img = images.ground_floor_stack_papers_medium,   sound = "sfx_actor_jumping_prop_paper_stack_{01-04}"},
		{x = 678-16, y = 225-16, z = 0, img = images.ground_floor_stack_papers_small,    sound = "sfx_actor_jumping_prop_paper_stack_{01-04}"},
		{x = 1007-16, y = 247-16, z = 0, img = images.ground_floor_bucket_1,             sound = "empty"},
		{x = 1088-16, y = 247-16, z = 0, img = images.ground_floor_bucket_2,             sound = "empty"},
		{x = 978-16, y = 228-16, z = 0, img = images.ground_floor_caution_sign,          sound = "empty"},
	}) do
		local prop = enemies.JumpingProp:new(prop_data.x, prop_data.y, prop_data.img, prop_data.sound)
		if prop_data.z then
			prop.z = prop_data.z
		end
		game:new_actor(prop)
	end

	-- Water dispenser
	game:new_actor(WaterDispenser:new(790, 212-16))

	-- Start button
	local nx = CANVAS_WIDTH * 0.7
	local ny = game.level.cabin_inner_rect.by
	local l = create_actor_centered(enemies.ButtonSmallGlass, floor(nx), floor(ny))
	game:new_actor(l)

	-- Exit sign
	local exit_x = CANVAS_WIDTH * 0.25
	game:new_actor(create_actor_centered(enemies.ExitSign, floor(744), floor(ny)))

	game:new_actor(create_actor_centered(enemies.Clock, floor(440), floor(105)))

	-- local npc = random_sample(npcs)
	-- game:new_actor(enemies.NPC:new(1000, 226, {
	-- 	animation = npc.animation,
	-- 	dialogue_key = "dialogue.npc." .. npc.key,
	-- }))
	local npc = game:new_actor(enemies.NPC:new(780, 226, {
		npc_name = "brown",
		animation = {images.npc_brown, 0.2, 4},
		flip_x = true,
	}))
	npc.z = -2
end

function BackroomGroundFloor:get_default_camera_position()
	return 312 - 16, 48
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

function BackroomGroundFloor:on_new_player()
	if game.game_state == GAME_STATE_WAITING then
		game.music_player:set_disk("ground_floor_players", {
			continue_previous_pos = true,
		})
	end
end

function BackroomGroundFloor:on_player_leave()
	if game.game_state == GAME_STATE_WAITING then
		if game:get_number_of_alive_players() <= 0 then
			game.music_player:set_disk("ground_floor_empty", {
				continue_previous_pos = true,
			})
		end
	end
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
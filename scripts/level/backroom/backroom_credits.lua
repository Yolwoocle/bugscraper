require "scripts.util"
local images = require "data.images"
local enemies = require "data.enemies"
local BackroomWithDoor = require "scripts.level.backroom.backroom_with_door"
local BackgroundCity = require "scripts.level.background.background_city"
local Rect = require "scripts.math.rect"
local Loot = require "scripts.actor.loot"

local guns = require "data.guns"

local BackroomCredits = BackroomWithDoor:inherit()

function BackroomCredits:init(params)
	params = params or {}
    BackroomCredits.super.init(self, params)
	self.name = "credits"

	self.cafeteria_background = BackgroundCity:new(self)
	self.cafeteria_background.offset_y = 100
end

function BackroomCredits:generate(world_generator)
	game.level:set_bounds(Rect:new(unpack(RECT_CREDITS_PARAMS)))

	-- Collision 
	world_generator:reset()
	world_generator:write_rect(Rect:new(4, 15, 32, 16), TILE_STONE) -- Walls
	world_generator:write_rect(Rect:new(19, 13, 32, 15), TILE_STONE) -- Walls

	game.game_ui.logo_y = -70
	game.game_ui.logo_y_target = -70

	game.camera.max_x = 0

	-- Start cutscene
	game:play_cutscene("credits")
end

function BackroomCredits:get_default_player_position(player_n)
	return 3*16, 12*16
end

function BackroomCredits:get_default_player_gun()
	return guns.unlootable.Machinegun:new()
end

function BackroomCredits:get_default_camera_position()
	return 0, 0
end

function BackroomCredits:get_x_target_after_join_game()
	return 95
end

function BackroomCredits:can_exit()
	return false
end

function BackroomCredits:on_player_joined(player)
end

function BackroomCredits:update(dt)
	BackroomCredits.super.update(self, dt)
end

function BackroomCredits:on_fully_entered()
end

function BackroomCredits:draw_background()
	self.cafeteria_background:draw()
end

function BackroomCredits:draw_items()
	-- love.graphics.draw(images.credits_removeme_characters, 320, 144)
end

function BackroomCredits:draw_front_walls()
	love.graphics.draw(images.credits_building, 48, 208)
end

return BackroomCredits
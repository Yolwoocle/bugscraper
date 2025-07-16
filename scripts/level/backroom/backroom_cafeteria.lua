require "scripts.util"
local images = require "data.images"
local BackroomWithDoor = require "scripts.level.backroom.backroom_with_door"
local BackgroundCafeteria = require "scripts.level.background.background_cafeteria"
local Rect = require "scripts.math.rect"
local TvPresentation    = require "scripts.level.background.tv_presentation"
local upgrades          = require "data.upgrades"
local enemies = require "data.enemies"
local cutscenes = require "data.cutscenes"

local BackroomCafeteria = BackroomWithDoor:inherit()

function BackroomCafeteria:init(params)
	params = params or {}
    BackroomCafeteria.super.init(self, params)
	self.name = "cafeteria"

	self.cafeteria_background = BackgroundCafeteria:new(self)
	self.tv_presentation = TvPresentation:new(349-16, 112-16)

	self:open_door(false)
	self.door:set_images(
		images.cabin_door_brown_left_far,
		images.cabin_door_brown_left_center,
		images.cabin_door_brown_right_far,
		images.cabin_door_brown_right_center
	)

	self.cafeteria_glass_hole = false
	self.cafeteria_glass_hole_x = nil
	self.cafeteria_glass_hole_y = nil

	self.w1_ceo = params.w1_ceo
end

function BackroomCafeteria:generate(world_generator)
	game.level:set_bounds(Rect:new(unpack(RECT_CAFETERIA_PARAMS)))

	world_generator:reset()
	world_generator:write_rect(Rect:new(2, 2, 58, 15),   TILE_METAL)
	world_generator:write_rect(Rect:new(28, 13, 41, 13), TILE_SEMISOLID)
	world_generator:write_rect(Rect:new(46, 13, 48, 13), TILE_SEMISOLID)
	world_generator:write_rect(Rect:new(51, 13, 53, 13), TILE_SEMISOLID)

    self:assign_cafeteria_upgrades()

	game.camera.max_x = CANVAS_WIDTH

	if self.w1_ceo then
		local ceo = game:new_actor(enemies.NPC:new(866, 223, {
			npc_name = "ceo",
			animations = {
				normal = {images.ceo_npc_idle, 0.2, 4},
				shocked = {images.ceo_npc_shocked, 0.2, 1},
				airborne = {images.ceo_npc_airborne, 0.2, 1},
				jetpack = {images.ceo_npc_jetpack, 0.2, 1},
			},
			flip_x = true,
		}))
		ceo.gravity = 0
		ceo.is_affected_by_bounds = false

		game:new_actor(enemies.PlayerTrigger:new(46*16, 3*16, 2*16, 12*16, function()
			game:play_cutscene(cutscenes.ceo_escape_w1)
		end, {min_player_trigger = 1}))

		game:new_actor(enemies.JumpingProp:new(827, 190, images.ground_floor_boba))
		game:new_actor(enemies.JumpingProp:new(833, 190, images.ground_floor_laptop))
	end
end

function BackroomCafeteria:can_exit()
	for _, a in pairs(game.actors) do
		if a.name == "upgrade_display" then
			return false
		end
	end

	return BackroomCafeteria.super.can_exit(self)
end

function BackroomCafeteria:update(dt)
	BackroomCafeteria.super.update(self, dt)

	self.tv_presentation:update(dt)
end

function BackroomCafeteria:on_fully_entered()
	self:close_door()
end

function BackroomCafeteria:assign_cafeteria_upgrades()
	local bag = copy_table_shallow(game.level.upgrade_bag)

	for _, actor in pairs(game.actors) do
		if actor.name == "upgrade_display" then
			local upgrade, _, i = random_weighted(bag)
			table.remove(bag, i)

			if upgrade then
				actor:assign_upgrade(upgrade)
			end
		end
	end
end


function BackroomCafeteria:draw_background()
	self.cafeteria_background:draw() 
	love.graphics.draw(images.elevator_through_door, self.door.x, self.door.y)
	
	Particles:draw_layer(PARTICLE_LAYER_CAFETERIA_BACKGROUND)
	for _, actor in pairs(game.actors) do
		if actor.draw_behind_windows_in_cafeterias then
			actor:draw()
		end
	end
end

function BackroomCafeteria:draw_items()
	self.door:draw()
	love.graphics.draw(images.cafeteria, -16, -16)
	if self.cafeteria_glass_hole then
		love.graphics.draw(images.cafeteria_glass_hole, self.cafeteria_glass_hole_x, self.cafeteria_glass_hole_y)
	end
	game.level.elevator:draw_counter()
	
	self.tv_presentation:draw()
end

function BackroomCafeteria:draw_front_walls()
	love.graphics.draw(images.cafeteria_front, -16, -16)
end

return BackroomCafeteria
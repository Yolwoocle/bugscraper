require "scripts.util"
local upgrade_probabilities = require "data.upgrade_probabilities"
local images = require "data.images"
local BackroomWithDoor = require "scripts.level.backrooms.backroom_with_door"
local BackgroundCafeteria = require "scripts.level.background.background_cafeteria"
local Rect = require "scripts.math.rect"
local TvPresentation    = require "scripts.level.background.tv_presentation"

local BackroomCafeteria = BackroomWithDoor:inherit()

function BackroomCafeteria:init()
    BackroomCafeteria.super.init(self)
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
end

function BackroomCafeteria:generate(world_generator)
	world_generator:reset()
	world_generator:write_rect(Rect:new(2, 2, 58, 15),   TILE_METAL)
	world_generator:write_rect(Rect:new(28, 13, 41, 13), TILE_SEMISOLID)
	world_generator:write_rect(Rect:new(46, 13, 48, 13), TILE_SEMISOLID)
	world_generator:write_rect(Rect:new(51, 13, 53, 13), TILE_SEMISOLID)

    self:assign_cafeteria_upgrades()
	
	game.camera.max_x = CANVAS_WIDTH
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
end

function BackroomCafeteria:draw_items()
	self.door:draw()
	love.graphics.draw(images.cafeteria, -16, -16)
	game.level.elevator:draw_counter()
	
	self.tv_presentation:draw()
end

function BackroomCafeteria:draw_front_walls()
	love.graphics.draw(images.cafeteria_front, -16, -16)
end

return BackroomCafeteria
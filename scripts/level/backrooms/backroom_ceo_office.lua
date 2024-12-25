require "scripts.util"
local upgrades = require "data.upgrades"
local enemies = require "data.enemies"
local images = require "data.images"
local Backroom = require "scripts.level.backrooms.backroom"
local BackgroundCafeteria = require "scripts.level.background.background_cafeteria"

local BackroomCEOOffice = Backroom:inherit()

function BackroomCEOOffice:init()
    BackroomCEOOffice.super.init(self)
	self.name = "ceo_office"

	self.cafeteria_background = BackgroundCafeteria:new(self)
end

function BackroomCEOOffice:generate(world_generator)
    world_generator:generate_ceo_office()
	
	game.camera.max_x = 50*16

	game:new_actor(enemies.UpgradeDisplay:new(53*16, 14*16))
	game:new_actor(enemies.BossDoor:new(78*16, 10*16))
	
	game:new_actor(enemies.FinalBoss:new(88*16, 14*16))
end

function BackroomCEOOffice:can_exit()
	return false
end

function BackroomCEOOffice:update(dt)

end

function BackroomCEOOffice:draw()
	self.cafeteria_background:draw()
	love.graphics.draw(images.ceo_office_room, -16, -16)
end

return BackroomCEOOffice
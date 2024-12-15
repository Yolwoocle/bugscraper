require "scripts.util"
local upgrades = require "data.upgrades"
local enemies = require "data.enemies"
local images = require "data.images"
local Backroom = require "scripts.level.backrooms.backroom"
local BackgroundCafeteria = require "scripts.level.background.background_cafeteria"

local BackroomBossOffice = Backroom:inherit()

function BackroomBossOffice:init()
    BackroomBossOffice.super.init(self)
	self.name = "boss_office"

	self.cafeteria_background = BackgroundCafeteria:new(self)
end

function BackroomBossOffice:generate(world_generator)
    world_generator:generate_boss_office()
	
	game.camera.max_x = 50*16

	game:new_actor(enemies.Dummy:new(1500, 100))
	game:new_actor(enemies.UpgradeDisplay:new(53*16, 14*16))
	game:new_actor(enemies.BossDoor:new(78*16, 10*16))
end

function BackroomBossOffice:can_exit()
	return false
end

function BackroomBossOffice:update(dt)

end

function BackroomBossOffice:draw()
	self.cafeteria_background:draw()
	love.graphics.draw(images.boss_office, 0, 0)
end

return BackroomBossOffice
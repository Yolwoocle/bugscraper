require "scripts.util"
local upgrades = require "data.upgrades"
local images = require "data.images"
local Backroom = require "scripts.level.backrooms.backroom"
local BackgroundCafeteria = require "scripts.level.background.background_cafeteria"

local BackroomCafeteria = Backroom:inherit()

function BackroomCafeteria:init()
    BackroomCafeteria.super.init(self)
	self.name = "cafeteria"

	self.cafeteria_background = BackgroundCafeteria:new(self)
end

function BackroomCafeteria:generate(world_generator)
    world_generator:generate_cafeteria()
    self:assign_cafeteria_upgrades()
	
	game.camera.max_x = CANVAS_WIDTH
end

function BackroomCafeteria:can_exit()
	for _, a in pairs(game.actors) do
		if a.name == "upgrade_display" then
			return false
		end
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

function BackroomCafeteria:update(dt)

end

function BackroomCafeteria:assign_cafeteria_upgrades()
	local bag = {
		{upgrades.UpgradeTea, 1},
		{upgrades.UpgradeEspresso, 1},
		{upgrades.UpgradeMilk, 1},
		{upgrades.UpgradePeanut, 1},
		-- {upgrades.UpgradeEnergyDrink, 1},
		{upgrades.UpgradeSoda, 1},
	}

	for _, actor in pairs(game.actors) do
		if actor.name == "upgrade_display" then
			local upgrade, _, i = random_weighted(bag)
			table.remove(bag, i)

			actor:assign_upgrade(upgrade:new())
		end
	end
end

function BackroomCafeteria:draw()
	self.cafeteria_background:draw()
	love.graphics.draw(images.cafeteria, -16, -16)
end

return BackroomCafeteria
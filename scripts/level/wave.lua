require "scripts.util"
local Class = require "scripts.meta.class"
local Enemies = require "data.enemies"

local Wave = Class:inherit()

function Wave:init(params)
	self.min = param(params.min, 1)
	self.max = param(params.max, 1)
	self.enemies = param(params.enemies, {})
end

function Wave:roll()
	local number_of_enemies = love.math.random(self.min, self.max)

	local output = {}
	for i=1, number_of_enemies do
		local enemy_class = random_weighted(self.enemies)
		table.insert(output, {
			enemy_class = enemy_class,
			args = {},
		})
	end

	self:add_cocoons(output)
	
	return output
end

function Wave:add_cocoons(enemy_classes)
	if game:get_number_of_alive_players() < Input:get_number_of_users() then
		for i = 1, MAX_NUMBER_OF_PLAYERS do
			if self.game.waves_until_respawn[i] ~= -1 and self.game.waves_until_respawn[i] == 0 then
				table.insert(enemy_classes, {
					enemy_class = Enemies.Cocoon,
					args = {i},
				})
			end
		end
	end
end

function Wave:spawn(ax, ay, bx, by)
	local enemy_classes = self:roll()

	local spawned_enemies = {}
	for i=1, #enemy_classes do
		local x = love.math.random(ax + 16, bx - 16)
		local y = love.math.random(ay + 16, by - 16)

		local enemy_class = enemy_classes[i].enemy_class
		local args = enemy_classes[i].args
		
		local enemy_instance = enemy_class:new(x,y, unpack(args))
		enemy_instance:set_active(false)

		-- If button is summoned, last wave happened
		-- Center enemy
		-- enemy_instance.x = floor(enemy_instance.x - enemy_instance.w/2)
		-- enemy_instance.y = floor(enemy_instance.y - enemy_instance.h/2)
		-- self.game:on_button_glass_spawn(enemy_instance)
		
		-- Prevent collisions with floor
		if enemy_instance.y + enemy_instance.h > by then
			enemy_instance.y = by - enemy_instance.h
		end

		game:new_actor(enemy_instance)
		table.insert(spawned_enemies, enemy_instance)
	end
	
	return spawned_enemies
end

return Wave
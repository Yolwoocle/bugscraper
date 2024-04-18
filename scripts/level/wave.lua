require "scripts.util"
local Class = require "scripts.meta.class"
local Enemies = require "data.enemies"

local Wave = Class:inherit()

function Wave:init(params)
	self.floor_type = param(params.floor_type, FLOOR_TYPE_NORMAL)
	self.roll_type = param(params.roll_type, WAVE_ROLL_TYPE_RANDOM)
	self.music = param(params.music, nil)

	self.min = param(params.min, 1)
	self.max = param(params.max, 1)
	self.enemies = param(params.enemies, {})

	self.background = param(params.background, nil)
end

function Wave:roll()
	if self.roll_type == WAVE_ROLL_TYPE_RANDOM then
		return self:roll_random()
	elseif self.roll_type == WAVE_ROLL_TYPE_FIXED then
		return self:roll_fixed()
	end
end

function Wave:roll_random()
	local number_of_enemies = love.math.random(self.min, self.max)

	local output = {}
	for i=1, number_of_enemies do
		local _, enemy_table = random_weighted(self.enemies)
		table.insert(output, {
			enemy_class = enemy_table[1],
			args = {},
			position = enemy_table.position,
		})
	end

	self:add_cocoons(output)
	
	return output
end

function Wave:roll_fixed()
	local output = {}
	for i=1, #self.enemies do
		local enemy_table = self.enemies[i]
		for j=1, enemy_table[2] do
			table.insert(output, {
				enemy_class = enemy_table[1],
				args = {},
				position = enemy_table.position,
			})
		end
	end

	self:add_cocoons(output)
	
	return output
end

function Wave:add_cocoons(enemy_classes)
	if game:get_number_of_alive_players() < Input:get_number_of_users() then
		for i = 1, MAX_NUMBER_OF_PLAYERS do
			if game.waves_until_respawn[i] ~= -1 and game.waves_until_respawn[i] == 0 then
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
		local position = enemy_classes[i].position or {x, y}
		
		local enemy_instance = enemy_class:new(position[1], position[2], unpack(args))
		enemy_instance:set_active(false)

		-- Center enemy
		enemy_instance.x = floor(enemy_instance.x - enemy_instance.w/2)
		enemy_instance.y = floor(enemy_instance.y - enemy_instance.h/2)
		-- If button is summoned, last wave happened
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

function Wave:get_floor_type()
	return self.floor_type
end

return Wave
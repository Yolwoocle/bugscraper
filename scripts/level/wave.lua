require "scripts.util"
local Class = require "scripts.meta.class"
local Enemies = require "data.enemies"

local Wave = Class:inherit()

function Wave:init(params)
	self.floor_type = param(params.floor_type, FLOOR_TYPE_NORMAL)
	self.roll_type = param(params.roll_type, WAVE_ROLL_TYPE_RANDOM)
	self.music = param(params.music, nil)
	self.bounds = param(params.bounds, nil)

	self.min = param(params.min, 1)
	self.max = param(params.max, 1)
	self.enemies = param(params.enemies, {})
	self.level_geometry = param(params.level_geometry, nil)
	self.elevator_layers = param(params.elevator_layers, {})
	self.run = param(params.run, nil)

	self.enable_stomp_arrow_tutorial = param(params.enable_stomp_arrow_tutorial, false)

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

function Wave:spawn(rect)
	local enemy_classes = self:roll()

	local spawned_enemies = {}
	for i=1, #enemy_classes do
		local x = love.math.random(rect.ax + 16, rect.bx - 16)
		local y = love.math.random(rect.ay + 16, rect.by - 16)

		local enemy_class = enemy_classes[i].enemy_class
		local args = enemy_classes[i].args
		local position = enemy_classes[i].position or {x, y}
		
		local enemy_instance = enemy_class:new(position[1], position[2], unpack(args))

		-- Center enemy
		-- enemy_instance:set_pos(
		-- 	floor(enemy_instance.x - enemy_instance.w/2),
		-- 	floor(enemy_instance.y - enemy_instance.h/2)
		-- )
		-- If button is summoned, last wave happened
		-- self.game:on_button_glass_spawn(enemy_instance)
		
		-- Prevent collisions with floor
		if enemy_instance.y + enemy_instance.h > rect.by then
			enemy_instance:set_pos(enemy_instance.x, rect.by - enemy_instance.h)
		end

		game:new_actor(enemy_instance)
		
		local cur_enemy = enemy_instance
		local limit = 10
		while cur_enemy ~= nil and limit >= 0 do
			table.insert(spawned_enemies, cur_enemy)
			cur_enemy:set_active(false)

			cur_enemy = cur_enemy.rider
			limit = limit - 1
		end
	end
	
	return spawned_enemies
end

function Wave:get_floor_type()
	return self.floor_type
end

function Wave:enable_wave_side_effects(level)
	if self.background then
		self:set_background(self.background)
	end
	if self.music then
		game.music_player:fade_out(self.music, 1.0)
	end
	if self.level_geometry then
		self.level_geometry:apply(level)
	end
	if self.bounds then
		level:set_bounds(self.bounds)
	end
	if self.elevator_layers then
		for layer, value in pairs(self.elevator_layers) do
			level.elevator:set_layer(layer, value)
		end
	end
	if self.run then
		self:run(level)
	end

	if self.enable_stomp_arrow_tutorial then
		game.game_ui:set_stomp_arrow_target(level.enemy_buffer[1])
	end
end

return Wave
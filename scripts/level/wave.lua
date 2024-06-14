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
	self.fixed_enemies = param(params.fixed_enemies, {})
	self.level_geometry = param(params.level_geometry, nil)
	self.elevator_layers = param(params.elevator_layers, {})
	self.run = param(params.run, nil)

	self.title = param(params.title, nil)
	self.title_x = param(params.title_x, CANVAS_WIDTH/2)
	self.title_y = param(params.title_y, CANVAS_HEIGHT/2)
	self.title_color = param(params.title_color, COL_BLACK_BLUE)
	self.title_stay_time = param(params.title_stay_time, 3)
	self.title_scale = param(params.title_scale, 2)
	self.title_outline_color = param(params.title_outline_color, COL_WHITE)

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

function Wave:roll_random(enemies)
	enemies = param(enemies, self.enemies)
	local number_of_enemies = love.math.random(self.min, self.max)
	if number_of_enemies == 0 then
		return {}
	end

	local output = {}
	for i=1, number_of_enemies do
		local _, enemy_table = random_weighted(enemies)
		table.insert(output, {
			enemy_class = enemy_table[1],
			args = {},
			position = enemy_table.position,
		})
	end
	
	return output
end

function Wave:roll_fixed(enemies)
	enemies = param(enemies, self.enemies)
	local output = {}
	for i=1, #enemies do
		local enemy_table = enemies[i]
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
	local spawned_enemies = {}

	self:spawn_roll(rect, self:roll(), spawned_enemies)
	if self.fixed_enemies then
		self:spawn_roll(rect, self:roll_fixed(self.fixed_enemies), spawned_enemies)
	end

	return spawned_enemies
end

function Wave:spawn_roll(rect, roll, spawned_enemies)
	local enemy_classes = roll

	for i=1, #enemy_classes do
		local x = love.math.random(rect.ax + 16, rect.bx - 16)
		local y = love.math.random(rect.ay + 16, rect.by - 16)

		local enemy_class = enemy_classes[i].enemy_class
		local args = enemy_classes[i].args
		local position = enemy_classes[i].position or {x, y}
		
		local enemy_instance = enemy_class:new(position[1], position[2], unpack(args))

		-- Prevent collisions with floor
		if enemy_instance.y + enemy_instance.h > rect.by then
			enemy_instance:set_pos(enemy_instance.x, rect.by - enemy_instance.h)
		end

		game:new_actor(enemy_instance)
		
		-- Passengers / riders
		local cur_rider = enemy_instance
		local limit = 10
		while cur_rider ~= nil and limit >= 0 do
			table.insert(spawned_enemies, cur_rider)
			cur_rider:set_active(false)
			
			cur_rider = cur_rider.rider
			limit = limit - 1
		end
		
		-- Extra spawned enemies
		for _, extra_enemy in pairs(enemy_instance.spawned_actors or {}) do
			table.insert(spawned_enemies, extra_enemy)
			extra_enemy:set_active(false)
		end
	end

	return spawned_enemies
end

function Wave:get_floor_type()
	return self.floor_type
end

function Wave:show_title()
	if self.title then
		Particles:word(self.title_x, self.title_y, self.title, self.title_color, self.title_stay_time, self.title_scale, self.title_outline_color)
	end
end

function Wave:enable_wave_side_effects(level)
	if self.background then
		level:set_background(self.background)
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
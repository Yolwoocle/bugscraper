require "scripts.util"
local backgrounds = require "data.backgrounds"
local enemies = require "data.enemies"
local cutscenes = require "data.cutscenes"

local Rect = require "scripts.math.rect"
local LevelGeometry = require "scripts.level.level_geometry"
local Wave = require "scripts.level.wave"
local E = require "data.enemies"

RECT_ELEVATOR = Rect:new(2, 2, 28, 16)
RECT_CAFETERIA = Rect:new(2, 2, 53, 16)

local function new_cafeteria(run_func)
	run_func = run_func or function(...) end
	return Wave:new({
		floor_type = FLOOR_TYPE_CAFETERIA,
		roll_type = WAVE_ROLL_TYPE_FIXED,
		music = "cafeteria",
		run = function(self, level)
			for _, actor in pairs(game.actors) do
				if actor.name == "poison_cloud" then
					actor.lifespan = 1
				end
			end
			run_func(self, level)
		end,
		
		min = 1,
		max = 1,
		bounds = RECT_CAFETERIA,
		enemies = {
			{E.UpgradeDisplay, 1, position = {488, 192}},
			{E.UpgradeDisplay, 1, position = {544, 192}},
			{E.UpgradeDisplay, 1, position = {600, 192}},
		},
	})
end

local function debug_wave()
	return Wave:new({
		-- roll_type = WAVE_ROLL_TYPE_FIXED,
		min = 1,
		max = 1,
		enable_stomp_arrow_tutorial = true,
		
		level_geometry = LevelGeometry:new({
			{rect = Rect:new(3, 8, 8, 8), tile = TILE_SEMISOLID}, 
			{rect = Rect:new(21, 8, 26, 8), tile = TILE_SEMISOLID}, 
		}),
		elevator_layers = {
			["bg_grid"] = false,
		},
		run = function(self, level)
			local cabin_rect = game.level.cabin_rect
			Particles:falling_grid(cabin_rect.ax +   16, cabin_rect.ay + 6*16)
			Particles:falling_grid(cabin_rect.bx - 7*16, cabin_rect.ay + 6*16)
			level.elevator:start_grid_timer(2.5)
		end,
		enemies = {
			{E.MushroomAnt, 1},
		}
	})
end

local function new_wave(params)
	params.bounds = params.bounds or RECT_ELEVATOR
	return Wave:new(params)
end

local function get_world_name(n)
	return string.format("%s - %s", Text:text("level.short_world_prefix", tostring(n)), Text:text("level.world_"..tostring(n)))
end

local function spawn_timed_spikes()
	local j = 0
	for ix = 3, CANVAS_WIDTH/16 - 4 do
		local spikes = enemies.TimedSpikes:new(ix * BW, CANVAS_HEIGHT*0.85, 4, 1, 0.5, j*0.2)
		spikes.z = 3 - j/100
		game:new_actor(spikes)
		j = j + 1
	end
end

local waves = {	
	-- debug_wave(),
	-- new_cafeteria(),
	-- [[
	new_wave({
		min = 5,
		max = 5,
		enemies = {
			{E.Larva, 3},
			{E.Fly, 3},
		},
		music = "w1",

		title = get_world_name("1"),
		title_color = COL_MID_BLUE,
	}),

	
}


-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------


local demo_waves = {
	new_wave({
		min = 5,
		max = 5,
		enemies = {
			{E.Larva, 3},
			{E.Fly, 3},
		},
		music = "w1",

		title = get_world_name("1"),
		title_color = COL_MID_BLUE,
	}),

	
	new_wave({
		-- Woodlouse intro
		min = 4,
		max = 6,
		enemies = {
			{E.Woodlouse, 2},
		},
	}),

	new_wave({
		min = 4,
		max = 6,
		enemies = {
			{E.Larva, 2},
			{E.Fly, 3},
			{E.Woodlouse, 2},
		},
	}),

	new_wave({
		-- Slug intro
		min = 4,
		max = 6,
		enemies = {
			{E.Larva, 2},
			{E.Fly, 2},
			{E.Slug, 4},
		},
	}),

	
	new_wave({
		min = 3,
		max = 5,
		enemies = {
			-- Shelled Snail intro
			{E.SnailShelled, 3},
		},
	}),

	new_wave({
		min = 6,
		max = 8,
		enemies = {
			-- 
			{E.Larva, 4},
			{E.Fly, 4},
			{E.Woodlouse, 2},
			{E.SnailShelled, 3},
			{E.Slug, 2},
		},
	}),
	
	new_wave({ 
		min = 7,
		max = 9,
		enemies = {
			{E.SnailShelled, 4},
			{E.SpikedFly, 3},
			{E.Fly, 3},
		},
	}),

	new_wave({
		-- Mushroom ant intro
		roll_type = WAVE_ROLL_TYPE_FIXED,
		enemies = {
			{E.Fly, 2},
			{E.Boomshroom, 4},
		},
	}),

	new_wave({
		min = 8,
		max = 10,
		enemies = {
			{E.Fly, 5},
			{E.Slug, 2},
			{E.SpikedFly, 4},
			{E.Woodlouse, 4},
			{E.SnailShelled, 4},
		},
	}),

	new_cafeteria(),

	new_wave({ 
		-- Spiked Fly intro
		min = 6,
		max = 8,
		music = "w1",

		enemies = {
			{E.Larva, 1},
			{E.Fly, 2},
			{E.SpikedFly, 4},
		},
	}),

	new_wave({
		min = 6,
		max = 8,
		enemies = {
			{E.Larva, 1},
			{E.Fly, 2},
			{E.SpikedFly, 2},
			{E.Boomshroom, 4},
			{E.Slug, 2},
			{E.SnailShelled, 2},
		},
	}),

	new_wave({
		-- Spider intro
		min = 6,
		max = 8,
		enemies = {
			{E.Larva, 1},
			{E.Slug, 2},
			{E.Spider, 4},
		},
	}),

	new_wave({
		min = 6,
		max = 8,
		enemies = {
			{E.Fly, 2},
			{E.SnailShelled, 2},
			{E.Spider, 4},
		},
	}),

	new_wave({
		min = 8,
		max = 9,
		enemies = {
			{E.Fly, 2},
			{E.SpikedFly, 2},
			{E.SnailShelled, 2},
			{E.Slug, 2},
			{E.Spider, 4},
		},
	}),

	new_wave({ 
		-- Stink bug intro
		min = 5,
		max = 6,
		enemies = {
			{E.StinkBug, 3},
		},
	}),

	new_wave({ 
		min = 7,
		max = 9,
		enemies = {
			{E.Larva, 1},
			{E.SpikedFly, 2},
			{E.Boomshroom, 2},
			{E.SnailShelled, 2},
			{E.Spider, 2},
			{E.StinkBug, 4},
		},
	}),

	new_wave({ 
		min = 8,
		max = 10,
		enemies = {
			{E.Fly, 2},
			{E.Slug, 2},
			{E.Woodlouse, 2},
			{E.SpikedFly, 2},
			{E.Boomshroom, 2},
			{E.SnailShelled, 2},
			{E.Spider, 2},
			{E.StinkBug, 2},
		},
	}),

	new_wave({
		-- roll_type = WAVE_ROLL_TYPE_FIXED,
		min = 1,
		max = 1,
		enemies = {	
			{E.Dung, 1, position = {240, 200}},			
		},
		music = "miniboss",
	}),

	
	-- Last wave
	new_wave({ 
		min = 1,
		max = 1,
		enemies = {
			{E.ButtonBigGlass, 1, position = {211, 194}}
		},
		music = "off",
	})
}

local function sanity_check_waves()
	for i, wave in ipairs(waves) do
		assert((wave.min <= wave.max), "max > min for wave "..tostring(i))

		for j, enemy_pair in ipairs(wave.enemies) do
			local enemy_class = enemy_pair[1]
			local weight = enemy_pair[2]

			assert(enemy_class ~= nil, "enemy "..tostring(j).." for wave "..tostring(i).." doesn't exist")
			assert(type(weight) == "number", "weight for enemy "..tostring(j).." for wave "..tostring(i).." isn't a number")
			assert(weight >= 0, "weight for enemy "..tostring(j).." for wave "..tostring(i).." is negative")
		end
	end
end

sanity_check_waves()

for i, wave in pairs(waves) do
	table.sort(wave.enemies, function(a,b) return a[2] > b[2] end)
end

return ternary(DEMO_BUILD, demo_waves, waves)
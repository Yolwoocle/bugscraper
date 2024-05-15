require "scripts.util"
local images = require "data.images"
local backgrounds = require "data.backgrounds"

local Rect = require "scripts.rect"
local LevelGeometry = require "scripts.level.level_geometry"
local Wave = require "scripts.level.wave"
local E = require "data.enemies"

RECT_ELEVATOR = Rect:new(2, 2, 28, 16)
RECT_CAFETERIA = Rect:new(2, 2, 69, 16)

local function new_cafeteria()
	return Wave:new({
		floor_type = FLOOR_TYPE_CAFETERIA,
		roll_type = WAVE_ROLL_TYPE_FIXED,
		music = "cafeteria",
		
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
		enemies = {	
			{E.Dung, 1, position = {240, 200}},
			-- {E.FlyingDung, 1, position = {CANVAS_WIDTH/2, 200}},
			-- {E.Fly, 1},
			-- {E.VendingMachine, 1},
			-- {E.HoneypotAnt, 1},
			-- {E.FlyingDung, 1},
			-- {E.SnailShelled, 1},
			-- {E.PoisonCloud, 1},
			-- {E.SnailShelled, 1},
			-- {E.Fly, 1},
			-- {E.Mosquito, 1},
			-- {E.HoneypotAnt, 1},
			-- {E.Larva, 1},
			-- {E.Fly, 1},
			-- {E.SpikedFly, 1},
			-- {E.SnailShelled, 1},
			-- {E.Slug, 1},
			-- {E.Grasshopper, 1},
			-- {E.MushroomAnt, 1},

			-- {E.ButtonBigGlass, 1, position={CANVAS_WIDTH/2, CANVAS_HEIGHT/2}},
			
		}
	})
end

local function new_wave(params)
	params.bounds = RECT_ELEVATOR
	return Wave:new(params)
end

local waves = {	
	-- debug_wave(),
	-- new_cafeteria(),
	-- [[
	new_wave({
		min = 4,
		max = 6,
		enemies = {
			{E.Larva, 3},
			{E.Fly, 3},
		},
		music = "w1",
		
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
		end
	}),

	
	new_wave({
		-- Woodlouse intro
		min = 4,
		max = 6,
		enable_stomp_arrow_tutorial = true,
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
			{E.Slug, 2},
		},
	}),
	
	new_wave({
		-- Spider intro
		min = 4,
		max = 6,
		enemies = {
			{E.Larva, 2},
			{E.Spider, 4},
		},
	}),

	new_wave({
		min = 6,
		max = 8,
		enemies = {
			{E.Fly, 5},
			{E.Slug, 2},
			{E.Spider, 3},
			{E.Woodlouse, 2},
		},
	}),

	new_wave({
		-- Mosquito intro
		min = 6,
		max = 8,
		enemies = {
			{E.Fly, 3},
			{E.Mosquito, 4},
		},
	}),

	new_wave({ 
		min = 6,
		max = 8,
		enemies = {
			{E.Larva, 2},
			{E.Slug, 5},
			{E.Fly, 2},
			{E.Mosquito, 2},
			{E.Woodlouse, 2},
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
			{E.Mosquito, 3},
			{E.Fly, 4},
			{E.Larva, 4},
			{E.SnailShelled, 3},
			{E.Spider, 3},
		},
	}),

	new_wave({ 
		-- Spiked Fly intro
		min = 6,
		max = 8,
		enemies = {
			{E.Larva, 1},
			{E.Fly, 2},
			{E.Mosquito, 2},
			{E.SpikedFly, 4},
		},
	}),

	new_wave({ 
		min = 7,
		max = 9,
		enemies = {
			{E.Fly, 2},
			{E.Mosquito, 4},
			{E.SpikedFly, 4},
			{E.Spider, 4},
		},
	}),

	new_cafeteria(),

	new_wave({ 
		-- Grasshopper intro
		min = 4,
		max = 4,
		enemies = {
			{E.Grasshopper, 8},
		},
		music = "w1",
	}),

	new_wave({ 
		min = 7,
		max = 9,
		enemies = {
			{E.Fly, 2},
			{E.Mosquito, 4},
			{E.Grasshopper, 8},
			{E.Woodlouse, 2},
			{E.SpikedFly, 4},
			{E.Spider, 4},
		},
	}),

	new_wave({ 
		-- Mushroom Ant intro
		min = 5,
		max = 6,
		enemies = {
			{E.Fly, 3},
			{E.Mosquito, 3},
			{E.MushroomAnt, 3},
		},
	}),


	new_wave({ 
		min = 8,
		max = 10,
		enemies = {
			{E.MushroomAnt, 3},
			{E.Woodlouse, 2},
			{E.Fly, 1},
			{E.SpikedFly, 1},
			{E.Spider, 2},
		},
	}),

	new_wave({ 
		-- Honeypot ant intro
		min = 6,
		max = 8,
		enemies = {
			{E.Larva, 3},
			{E.HoneypotAnt, 6},
			{E.MushroomAnt, 3},
			{E.SpikedFly, 3},
		},
	}),

	new_wave({ -- 12
		-- ALL
		min = 6,
		max = 8,
		enemies = {
			{E.Larva, 4},
			{E.Fly, 3},
			{E.SnailShelled, 3},
			{E.Mosquito, 3},
			{E.Slug, 2},
			{E.HoneypotAnt, 2},
			{E.SpikedFly, 1},
			{E.Grasshopper, 1},
			{E.MushroomAnt, 1},
			{E.Spider, 1},
		},
	}),

	-- unpack(duplicate_table({
	-- ALL BUT HARDER
	new_wave({
		min = 8,
		max = 10,
		enemies = {
			{E.Fly, 3},
			{E.SnailShelled, 3},
			{E.Slug, 2},
			{E.Mosquito, 3},
			{E.SpikedFly, 1},
			-- {E.Grasshopper, 1},
			-- {E.MushroomAnt, 1},
			-- {E.Spider, 1},
		},
	}),
	new_wave({
		min = 10,
		max = 12,
		enemies = {
			-- {E.Larva, 4},
			-- {E.Fly, 3},
			-- {E.SnailShelled, 3},
			-- {E.Slug, 2},
			{E.HoneypotAnt, 2},
			{E.SpikedFly, 1},
			{E.Grasshopper, 1},
			{E.Mosquito, 3},
			{E.MushroomAnt, 1},
			{E.Woodlouse, 1},
			{E.Spider, 1},
		},
	}),
	new_wave({
		min = 14,
		max = 16,
		enemies = {
			{E.Fly, 3},
			{E.HoneypotAnt, 2},
			{E.SnailShelled, 3},
			{E.Woodlouse, 1},
			{E.Slug, 2},
			{E.Mosquito, 3},
			{E.SpikedFly, 1},
			{E.Grasshopper, 1},
			{E.MushroomAnt, 1},
			{E.Spider, 1},
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
	-- }, 4)),
	--]]
	
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

return waves
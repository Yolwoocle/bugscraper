require "scripts.util"
local images = require "data.images"
local backgrounds = require "data.backgrounds"

local Class = require "scripts.meta.class"
local Gun = require "scripts.game.gun"
local Wave = require "scripts.level.wave"
local E = require "data.enemies"

local function new_cafeteria()
	return Wave:new({
		floor_type = FLOOR_TYPE_CAFETERIA,
		roll_type = WAVE_ROLL_TYPE_FIXED,
		music = "cafeteria",
		
		min = 1,
		max = 1,
		enemies = {
			{E.Dummy, 1, position = {5000, 200}},
			{E.UpgradeDisplay, 1, position = {488, 200}},
			{E.UpgradeDisplay, 1, position = {544, 200}},
			{E.UpgradeDisplay, 1, position = {600, 200}},
		},
	})
end

local waves = {
	Wave:new({
		min = 4,
		max = 4,
		enable_stomp_arrow_tutorial = true,
		enemies = {	
			{E.Woodlouse, 4},
			-- {E.Dung, 4, position = {240, 200}},
			-- {E.FlyingDung, 4, position = {CANVAS_WIDTH/2, 200}},
			-- {E.Fly, 3},
			-- {E.VendingMachine, 3},
			-- {E.HoneypotAnt, 4},
			-- {E.FlyingDung, 4},
			-- {E.SnailShelled, 3},
			-- {E.PoisonCloud, 4},
			-- {E.SnailShelled, 4},

			-- {E.Mosquito, 4},
			-- {E.HoneypotAnt, 4},
			-- {E.Larva, 4},
			-- {E.Fly, 3},
			-- {E.SpikedFly, 3},
			-- {E.SnailShelled, 3},
			-- {E.Slug, 2},
			-- {E.Grasshopper, 1},
			-- {E.MushroomAnt, 10},
		}
	}),

	-- Wave:new({
	-- 	min = 1,
	-- 	max = 1,
	-- 	enemies = {
	-- 		{E.Dung, 3, position = {200, 200}},
	-- 	},
	-- 	-- background = backgrounds.BackgroundDots:new(),
	-- }),
	
	-- Wave:new({
	-- 	music = "w1",
	-- 	background = backgrounds.BackgroundServers:new(),
	
	-- 	min = 1,
	-- 	max = 1,
	-- 	enemies = {
	-- 		{E.Larva, 3},
	-- 		{E.Fly, 3},
	-- 	},
	-- }),

	---------------------------------------------
	
	Wave:new({
		-- music = "w1",

		min = 4,
		max = 6,
		enemies = {
			{E.Larva, 3},
			{E.Fly, 3},
		},
	}),
	
	Wave:new({
		-- Woodlouse intro
		min = 4,
		max = 6,
		enable_stomp_arrow_tutorial = true,
		enemies = {
			{E.Woodlouse, 2},
		},
	}),

	Wave:new({
		min = 4,
		max = 6,
		enemies = {
			{E.Larva, 2},
			{E.Fly, 3},
			{E.Woodlouse, 2},
		},
	}),

	Wave:new({
		-- Slug intro
		min = 4,
		max = 6,
		enemies = {
			{E.Larva, 2},
			{E.Fly, 2},
			{E.Slug, 2},
		},
	}),
	
	Wave:new({
		-- Spider intro
		min = 4,
		max = 6,
		enemies = {
			{E.Larva, 2},
			{E.Spider, 4},
		},
	}),

	Wave:new({
		min = 6,
		max = 8,
		enemies = {
			{E.Fly, 5},
			{E.Slug, 2},
			{E.Spider, 3},
			{E.Woodlouse, 2},
		},
	}),

	Wave:new({
		-- Mosquito intro
		min = 6,
		max = 8,
		enemies = {
			{E.Fly, 3},
			{E.Mosquito, 4},
		},
	}),

	Wave:new({ 
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

	Wave:new({
		min = 3,
		max = 5,
		enemies = {
			-- Shelled Snail intro
			{E.SnailShelled, 3},
		},
	}),

	Wave:new({
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

	Wave:new({ 
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

	Wave:new({ 
		min = 7,
		max = 9,
		enemies = {
			{E.Fly, 2},
			{E.Mosquito, 4},
			{E.SpikedFly, 4},
			{E.Spider, 4},
		},
	}),


	Wave:new({
		floor_type = FLOOR_TYPE_CAFETERIA,
		roll_type = WAVE_ROLL_TYPE_FIXED,
		music = "cafeteria",
		
		min = 1,
		max = 1,
		enemies = {
			{E.Dummy, 1, position = {5000, 200}},
			{E.UpgradeDisplay, 1, position = {488, 200}},
			{E.UpgradeDisplay, 1, position = {544, 200}},
			{E.UpgradeDisplay, 1, position = {600, 200}},
		},
	}),

	Wave:new({ 
		-- Grasshopper intro
		min = 4,
		max = 4,
		enemies = {
			{E.Grasshopper, 8},
		},
	}),

	Wave:new({ 
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

	Wave:new({ 
		-- Mushroom Ant intro
		min = 5,
		max = 6,
		enemies = {
			{E.Fly, 3},
			{E.Mosquito, 3},
			{E.MushroomAnt, 3},
		},
	}),


	Wave:new({ 
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

	Wave:new({ 
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

	Wave:new({ -- 12
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
		Wave:new({
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
	Wave:new({
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
	Wave:new({
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
	-- }, 4)),

	-- Last wave
	Wave:new({ 
		min = 1,
		max = 1,
		enemies = {
			{E.ButtonBigGlass, 1}
		}
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
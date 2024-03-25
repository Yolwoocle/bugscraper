require "scripts.util"
local Class = require "scripts.meta.class"
local Gun = require "scripts.game.gun"
local images = require "data.images"
local E = require "data.enemies"

local waves = {
	{
		min = 14,
		max = 14,
		enemies = {
			-- {E.VendingMachine, 3},
			{E.StinkBug, 4},
			-- {E.PoisonCloud, 4},
			-- {E.SnailShelled, 4},
		}
	},
	{
		min = 4,
		max = 6,
		enemies = {
			{E.Larva, 3},
			{E.Fly, 3},

			-- {E.Mosquito, 4},
			-- {E.HoneypotAnt, 4},
			-- {E.Larva, 4},
			-- {E.Fly, 3},
			-- {E.SpikedFly, 3},
			-- {E.SnailShelled, 3},
			-- {E.Slug, 2},
			-- {E.Grasshopper, 1},
			-- {E.MushroomAnt, 10},
		},
	},

	{
		-- Slug intro
		min = 4,
		max = 6,
		enemies = {
			{E.Larva, 2},
			{E.Fly, 2},
			{E.Slug, 2},
		},
	},
	
	{
		-- Spider intro
		min = 4,
		max = 6,
		enemies = {
			{E.Larva, 2},
			{E.Spider, 4},
		},
	},

	{
		min = 6,
		max = 8,
		enemies = {
			{E.Larva, 2},
			{E.Fly, 5},
			{E.Slug, 2},
			{E.Spider, 3},
		},
	},

	{
		-- Grasshopper intro
		min = 6,
		max = 8,
		enemies = {
			{E.Grasshopper, 8},
			{E.Larva, 4},
		},
	},

	{
		-- 
		min = 6,
		max = 8,
		enemies = {
			{E.Larva, 3},
			{E.Slug, 3},
			{E.Grasshopper, 8},
			{E.Fly, 3},
		},
	},

	{
		-- Mosquito intro
		min = 6,
		max = 8,
		enemies = {
			{E.Fly, 3},
			{E.Mosquito, 4},
		},
	},

	{ 
		min = 6,
		max = 8,
		enemies = {
			{E.Larva, 2},
			{E.Slug, 5},
			{E.Fly, 2},
			{E.Mosquito, 2},
		},
	},

	{
		min = 3,
		max = 5,
		enemies = {
			-- Shelled Snail intro
			{E.SnailShelled, 3},
		},
	},

	{
		min = 6,
		max = 8,
		enemies = {
			-- 
			{E.Mosquito, 3},
			{E.Fly, 4},
			{E.Larva, 4},
			{E.SnailShelled, 3},
			{E.Grasshopper, 3},
			{E.Spider, 3},
		},
	},

	{ 
		-- Spiked Fly intro
		min = 6,
		max = 8,
		enemies = {
			{E.Larva, 1},
			{E.Fly, 2},
			{E.Mosquito, 2},
			{E.SpikedFly, 4},
		},
	},

	{ 
		min = 7,
		max = 9,
		enemies = {
			{E.Fly, 2},
			{E.Mosquito, 4},
			{E.SpikedFly, 4},
			{E.Spider, 4},
		},
	},

	{ 
		-- Mushroom Ant intro
		min = 5,
		max = 6,
		enemies = {
			{E.Fly, 3},
			{E.Mosquito, 3},
			{E.MushroomAnt, 3},
		},
	},


	{ 
		min = 8,
		max = 10,
		enemies = {
			{E.MushroomAnt, 3},
			{E.Fly, 1},
			{E.SpikedFly, 1},
			{E.Spider, 2},
		},
	},

	{ 
		-- Honeypot ant intro
		min = 6,
		max = 8,
		enemies = {
			{E.Larva, 3},
			{E.HoneypotAnt, 6},
			{E.MushroomAnt, 3},
			{E.SpikedFly, 3},
		},
	},

	{ -- 12
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
	},

	-- unpack(duplicate_table({
		-- ALL BUT HARDER
		-- 13, 14, 15
	{
		min = 8,
		max = 10,
		enemies = {
			{E.Larva, 4},
			{E.Fly, 3},
			{E.SnailShelled, 3},
			{E.Slug, 2},
			{E.Mosquito, 3},
			{E.SpikedFly, 1},
			-- {E.Grasshopper, 1},
			-- {E.MushroomAnt, 1},
			-- {E.Spider, 1},
		},
	},
	{
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
			{E.Spider, 1},
		},
	},
	{
		min = 14,
		max = 16,
		enemies = {
			{E.Larva, 4},
			{E.Fly, 3},
			{E.HoneypotAnt, 2},
			{E.SnailShelled, 3},
			{E.Slug, 2},
			{E.Mosquito, 3},
			{E.SpikedFly, 1},
			{E.Grasshopper, 1},
			{E.MushroomAnt, 1},
			{E.Spider, 1},
		},
	},
	-- }, 4)),

	-- Last wave
	{ 
		min = 1,
		max = 1,
		enemies = {
			{E.ButtonBigGlass, 1}
		}
	}
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
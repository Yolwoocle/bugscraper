require "util"
local Class = require "class"
local Gun = require "gun"
local images = require "data.images"
local E = require "data.enemies"

local waves = {

{ -- 1
	min = 4,
	max = 6,
	enemies = {
		{E.Larva, 1},
		{E.Fly, 1},
	},
},

{ -- 2
	-- Slug intro
	min = 6,
	max = 8,
	enemies = {
		{E.Larva, 2},
		{E.Fly, 2},
		{E.Slug, 5},
	},
},


{ -- 3
	-- Grasshopper intro
	min = 4,
	max = 6,
	enemies = {
		{E.Slug, 2},
		{E.Grasshopper, 4},
	},
},


{ -- 4
	-- 
	min = 6,
	max = 8,
	enemies = {
		{E.Larva, 2},
		{E.Fly, 2},
		{E.Slug, 5},
		{E.Grasshopper, 1},
	},
},


{ -- 5
	-- Shelled Snail intro
	min = 4,
	max = 6,
	enemies = {
		{E.Slug, 2},
		{E.SnailShelled, 4},
	},
},


{ -- 6
	-- Spiked Fly intro
	min = 6,
	max = 8,
	enemies = {
		{E.Larva, 3},
		{E.Fly, 3},
		{E.SnailShelled, 3},
		{E.Slug, 2},
		{E.SpikedFly, 20},
	},
},

{ -- 7
	min = 7,
	max = 9,
	enemies = {
		{E.Fly, 2},
		{E.Grasshopper, 1},
	},
},

{ -- 8
	-- ALL
	min = 10,
	max = 14,
	enemies = {
		{E.Larva, 4},
		{E.Fly, 3},
		{E.SnailShelled, 3},
		{E.Slug, 2},
		{E.Grasshopper, 1},
		{E.SpikedFly, 1},
	},
},

{ -- 9
	-- Mushroom Ant intro
	min = 3,
	max = 4,
	enemies = {
		{E.MushroomAnt, 3},
	},
},


{ -- 10
	min = 6,
	max = 8,
	enemies = {
		{E.MushroomAnt, 3},
		{E.Fly, 1},
		{E.SpikedFly, 1},
	},
},

{ -- 11
	-- ALL
	min = 10,
	max = 14,
	enemies = {
		{E.Larva, 4},
		{E.Fly, 3},
		{E.SpikedFly, 3},
		{E.SnailShelled, 3},
		{E.Slug, 2},
		{E.Grasshopper, 1},
		{E.MushroomAnt, 1},
	},
},

unpack(duplicate_table({
	-- ALL BUT HARDER
	-- 12, 13, 14, 15
	min = 12,
	max = 16,
	enemies = {
		{E.Larva, 4},
		{E.Fly, 3},
		{E.SpikedFly, 3},
		{E.SnailShelled, 3},
		{E.Slug, 2},
		{E.Grasshopper, 1},
		{E.MushroomAnt, 1},
	},
}, 4)),

-- Last wave
{
	min = 1,
	max = 1,
	enemies = {
		{E.ButtonGlass, 1}
	}
}

}

return waves
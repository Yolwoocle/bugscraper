require "util"
local Class = require "class"
local Gun = require "gun"
local images = require "images"
local E = require "stats.enemies"

local waves = {}

waves[1] = {
	min = 3,
	max = 5,
	enemies = {
		{E.Larva, 1},
	},
}

waves[2] = {
	min = 4,
	max = 8,
	enemies = {
		{E.Larva, 2},
		{E.Fly, 1},
	},
}

waves[3] = {
	min = 4,
	max = 8,
	enemies = {
		{E.Larva, 1},
		{E.Fly, 2},
	},
}

waves[4] = {
	min = 6,
	max = 10,
	enemies = {
		{E.Larva, 2},
		{E.Fly, 2},
		{E.Slug, 10},
	},
}

waves[5] = {
	min = 6,
	max = 10,
	enemies = {
		{E.SnailShelled, 3},
		{E.Slug, 2},
	},
}

waves[6] = {
	min = 8,
	max = 13,
	enemies = {
		{E.SnailShelled, 3},
		{E.Slug, 2},
	},
}

waves[6] = {
	min = 10,
	max = 13,
	enemies = {
		{E.Larva, 3},
		{E.Fly, 3},
		{E.SnailShelled, 3},
		{E.Slug, 2},
	},
}

waves[7] = {
	min = 5,
	max = 7,
	enemies = {
		{E.Slug, 2},
		{E.Grasshopper, 4},
	},
}

waves[8] = {
	min = 7,
	max = 9,
	enemies = {
		{E.Fly, 1},
		{E.Grasshopper, 1},
	},
}

waves[9] = {
	min = 10,
	max = 14,
	enemies = {
		{E.Larva, 4},
		{E.Fly, 3},
		{E.SnailShelled, 3},
		{E.Slug, 2},
		{E.Grasshopper, 1},
	},
}


waves[10] = {
	min = 100,
	max = 100,
	enemies = {
		{E.Larva, 4},
		{E.Fly, 3},
		{E.SnailShelled, 3},
		{E.Slug, 2},
		{E.Grasshopper, 1},
	},
}

return waves
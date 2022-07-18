require "util"
local Class = require "class"
local Gun = require "gun"
local images = require "images"
local E = require "stats.enemies"

local waves = {

{
	min = 4,
	max = 6,
	enemies = {
		{E.Larva, 1},
		{E.Fly, 1},
		-- {E.MushroomAnt, 10},
	},
},

{
	min = 6,
	max = 8,
	enemies = {
		{E.Larva, 2},
		{E.Fly, 2},
		{E.Slug, 5},
	},
},

{
	min = 6,
	max = 8,
	enemies = {
		{E.SnailShelled, 1},
		{E.Slug, 2},
	},
},

{
	min = 4,
	max = 6,
	enemies = {
		{E.SnailShelled, 3},
		{E.Slug, 2},
	},
},

{
	min = 6,
	max = 8,
	enemies = {
		{E.Larva, 3},
		{E.Fly, 3},
		{E.SnailShelled, 3},
		{E.Slug, 2},
	},
},

{
	min = 5,
	max = 7,
	enemies = {
		{E.Slug, 2},
		{E.Grasshopper, 4},
	},
},

{
	min = 7,
	max = 9,
	enemies = {
		{E.Fly, 1},
		{E.Grasshopper, 1},
	},
},

{
	min = 10,
	max = 14,
	enemies = {
		{E.Larva, 4},
		{E.Fly, 3},
		{E.SnailShelled, 3},
		{E.Slug, 2},
		{E.Grasshopper, 1},
	},
},

{
	min = 12,
	max = 16,
	enemies = {
		{E.Larva, 4},
		{E.Fly, 3},
		{E.SnailShelled, 3},
		{E.Slug, 2},
		{E.Grasshopper, 1},
	},
},

}

return waves
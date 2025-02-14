require "scripts.util"
local images = require "data.images"

local Class = require "scripts.meta.class"
local Tile = require "scripts.level.tile"
local CollisionInfo = require "scripts.physics.collision_info"

local Tiles = Class:inherit()

local function make_tile(init)
	local tile = Tile:inherit()
	tile.init = init
	return tile
end


function Tiles:init()
	self.tiles = {}
	
	-- Air
	self.tiles[TILE_AIR] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_AIR
		
		self.name = "air"
		self.spr = nil
	end)

	-- Metal
	self.tiles[TILE_METAL] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_METAL
		self.name = "metal"
		self.spr = nil
		
		self.collision_info = CollisionInfo:new {
			type = COLLISION_TYPE_SOLID,
			is_slidable = true,
		}
	end)

	-- Rubble
	self.tiles[TILE_RUBBLE] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_RUBBLE
		self.name = "rubble"
		self.spr = images.empty
		
		self.collision_info = CollisionInfo:new {
			type = COLLISION_TYPE_SOLID,
			is_slidable = false,
		}
	end)

	-- Semi-solid
	self.tiles[TILE_SEMISOLID] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_SEMISOLID
		self.name = "semisolid"
		-- self.spr = images.semisolid
		
		self.collision_info = CollisionInfo:new {
			type = COLLISION_TYPE_SEMISOLID,
			is_slidable = false,
		}
	end)

	-- Chain
	self.tiles[TILE_CHAIN] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_CHAIN

		self.name = "chain"
		self.spr = images.chain
	end)

	-- Border
	self.tiles[TILE_BORDER] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_BORDER

		self.name = "border"
		self.spr = images.semisolid
	end)

	-- Flip tile on
	self.tiles[TILE_FLIP_ON] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_FLIP_ON

		self.name = "flip_on"
		self.spr = images.metal

		self.collision_info = CollisionInfo:new {
			type = COLLISION_TYPE_SOLID,
			is_slidable = true,
		}
	end)

	-- Flip tile off
	self.tiles[TILE_FLIP_OFF] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_FLIP_OFF

		self.name = "flip_off"
		self.spr = images.bg_plate

		self.collision_info = CollisionInfo:new {
			type = COLLISION_TYPE_PLAYER_NONSOLID,
			is_slidable = false,
		}
	end)
end

function Tiles:new_tile(x, y, n, ...)
	local tile_class = self.tiles[n]
	local tile = tile_class:new(x, y, ...)

	return tile
end

return Tiles:new()
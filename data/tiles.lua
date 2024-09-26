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

	-- self.tiles[5] = make_tile(function(self, x, y, w)
	-- 	self:init_tile(x, y, w)
	-- 	self.id = 5
		
	-- 	self.name = "bg_plate"
	-- 	self.spr = images.bg_plate
	-- end)
end

function Tiles:new_tile(n, x, y, w, ...)
	local tile_class = self.tiles[n]
	local tile = tile_class:new(x, y, w, ...)

	-- Init collision box
	if tile.collision_info then
		Collision:add(tile, tile.x, tile.y, tile.w, tile.w)
	end

	return tile
end

return Tiles:new()
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
			walk_sound = "sfx_player_footstep_metal_{01-10}",
			slide_sound = "sfx_player_wall_slide_metal_{01-02}",
			land_sound = "sfx_player_footstep_land_metal_{01-04}",
		}
	end)

	-- Semi-solid metal
	self.tiles[TILE_METAL_SEMISOLID] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_METAL_SEMISOLID
		self.name = "metal_semisolid"
		self.spr = nil

		
		self.collision_info = CollisionInfo:new {
			type = COLLISION_TYPE_SEMISOLID,
			is_slidable = false,
			walk_sound = "sfx_player_footstep_metal_{01-10}",
			slide_sound = "sfx_player_wall_slide_metal_{01-02}",
			land_sound = "sfx_player_footstep_land_metal_{01-04}",
		}
	end)

	-- Rubble
	self.tiles[TILE_RUBBLE] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_RUBBLE
		self.name = "rubble"
		self.spr = nil

		self.collision_info = CollisionInfo:new {
			type = COLLISION_TYPE_SOLID,
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

	
	-- Carpet
	self.tiles[TILE_CARPET] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_CARPET
		self.name = "carpet"
		self.spr = nil

		self.collision_info = CollisionInfo:new {
			type = COLLISION_TYPE_SOLID,
			is_slidable = true,
			walk_sound = "sfx_player_footstep_carpet_{01-10}",
			slide_sound = "sfx_player_wall_slide_metal_{01-02}",
			land_sound = "sfx_player_footstep_land_carpet_{01-04}",
		}
	end)

	-- Sand
	self.tiles[TILE_SAND] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_SAND
		self.name = "sand"
		self.spr = nil
		
		self.collision_info = CollisionInfo:new {
			type = COLLISION_TYPE_SOLID,
			is_slidable = true,
			walk_sound = "sfx_player_footstep_sand_{01-10}",
			slide_sound = "sfx_player_wall_slide_stone_{01-02}",
			land_sound = "sfx_player_footstep_land_sand_{01-04}",
		}
	end)

	-- Stone
	self.tiles[TILE_STONE] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_STONE
		self.name = "stone"
		self.spr = nil

		self.collision_info = CollisionInfo:new {
			type = COLLISION_TYPE_SOLID,
			is_slidable = true,
			walk_sound = "sfx_player_footstep_stone_{01-10}",
			slide_sound = "sfx_player_wall_slide_stone_{01-02}",
			land_sound = "sfx_player_footstep_land_stone_{01-04}",
		}
	end)

	-- Wood
	self.tiles[TILE_WOOD] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_WOOD
		self.name = "wood"
		self.spr = nil
		
		self.collision_info = CollisionInfo:new {
			type = COLLISION_TYPE_SOLID,
			is_slidable = true,
			walk_sound = "sfx_player_footstep_wood_{01-06}",
			slide_sound = "sfx_player_wall_slide_metal_{01-02}", -- Make wood slide sound if needed 
			land_sound = "sfx_player_footstep_land_wood_{01-04}",
		}
	end)

	-- Semi-solid Wood
	self.tiles[TILE_WOOD_SEMISOLID] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_WOOD_SEMISOLID
		self.name = "wood_semisolid"
		self.spr = nil
		
		self.collision_info = CollisionInfo:new {
			type = COLLISION_TYPE_SEMISOLID,
			is_slidable = false,
			walk_sound = "sfx_player_footstep_wood_{01-06}",
			slide_sound = "sfx_player_wall_slide_metal_{01-02}",
			land_sound = "sfx_player_footstep_land_wood_{01-04}",
		}
	end)
	
	-- Glass
	self.tiles[TILE_GLASS] = make_tile(function(self, x, y, w)
		self:init_tile(x, y, w)
		self.id = TILE_GLASS
		self.name = "glass"
		self.spr = nil
		
		self.collision_info = CollisionInfo:new {
			type = COLLISION_TYPE_SOLID,
			is_slidable = true,
			walk_sound = "sfx_player_footstep_glass_{01-06}",
			slide_sound = "sfx_player_wall_slide_glass_{01-02}",
			land_sound = "sfx_player_footstep_glass_{01-06}",
		}
	end)
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

require "util"
local Class = require "class"

local WorldGenerator = Class:inherit()

function WorldGenerator:init(map, seed)
	self.map = map
	self.seed = seed or love.math.random(-999999, 999999)
	self.noise_scale = 7
	self.scale_y = 3
end

function WorldGenerator:generate(seed)
	local map = self.map
	local seed = self.seed
	local seed_details = self.seed + 50.3242
	
	local map_w = map.width
	local map_h = map.height
	local map_mid_w = floor(map.width / 2) 
	local map_mid_h = floor(map.height / 2)

	local floor_oy = -3

	map:reset()

	-- Box around map 
	self:make_floor()
	--[[

	-- Generate cave
	map:for_all_tiles(function(tile, x, y)
		local s = 7
		local n = noise01(seed, x/s, y/s) 
		-- More likely to have block the farther away
		--local thresh = distsqr(x/map_mid_w, y/map_mid_h, 1, 1) 
		local thresh = (y+floor_oy)/map_h 

		if n < thresh + noise(seed_details, x/s, y/s)*0.5 then 
			map:set_tile(x, y, 2)
		end
	end)

	-- Grassify
	self:grassify()
	--]]
end

function WorldGenerator:make_box()
	local map = self.map
	
	for ix=0, map.width-1 do
		map:set_tile(ix, 0, 1)
		map:set_tile(ix, map.height-1, 1)
	end

	for iy=1, map.height-2 do
		map:set_tile(0, iy, 1)
		map:set_tile(map.width-1, iy, 1)
	end
end

function WorldGenerator:make_floor()
	local map = self.map
	
	local i = 0
	for iy=map.height-4, map.height-1 do
		for ix=0, map.width-1 do
			local s = (i==0) and 1 or 2
			map:set_tile(ix, iy, s)
		end
		i=i+1
	end
end

function WorldGenerator:grassify()
	local map = self.map

	map:for_all_tiles(function(tile, x, y)
		if y == 0 then    return    end

		if tile.name == "dirt" and map:get_tile(x, y-1).name == "air" then
			map:set_tile(x, y, 1)
		end
	end)
end

function WorldGenerator:draw()
	if self.canvas then
		gfx.draw(self.canvas, 0,0)
	end
end



return WorldGenerator
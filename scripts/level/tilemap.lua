local Class = require "scripts.meta.class"
local Tiles = require "data.tiles"
local Rect = require "scripts.math.rect"

local TileMap = Class:inherit()

function TileMap:init(w,h)
	self.map = {}
	self.width = w
	self.height = h
	self.tile_size = 16

	for ix = 0, w-1 do
		self.map[ix] = {}
		for iy = 0, h-1 do
			self.map[ix][iy] = Tiles:new_tile(ix, iy, 0)
		end
	end

	self.has_changed = false
	self.world_items = {}
end

function TileMap:update(dt)
	if self.has_changed then
		self:rectangularize()
		self.has_changed = false
	end
end

function TileMap:draw()
	self:for_all_tiles(function(tile)
		tile:draw()
	end)
end


function TileMap:for_all_tiles(func)
	for ix=0,self.width-1 do
		for iy=0,self.height-1 do
			func(self.map[ix][iy], ix, iy)
		end
	end
end

function TileMap:reset()
	self:for_all_tiles(function(tile, ix, iy)
		self:set_tile(ix, iy, 0)
	end)
end

function TileMap:get_tile(x,y)
	if not self:is_valid_tile(x,y) then  return   end
	return self.map[x][y]
end

function TileMap:set_tile(x,y,n)
	-- Assertions
	if not self:is_valid_tile(x,y) then
		return
	end
	if self:get_tile(x, y).id == n then
		return
	end

	-- Create tile class
	local tile = Tiles:new_tile(x, y, n)
	self.map[x][y] = tile
	self.has_changed = true
end

function TileMap:add_collision(rect)
	Collision:add(rect, rect.x, rect.y, rect.w, rect.h)
	table.insert(self.world_items, rect)
end

function TileMap:is_valid_tile(x,y)
	return (0 <= x and x < self.width) and (0 <= y and y < self.height)
end

-----------------------------------------------------
-- Collision merging 

-- Checks whether all tiles on the side of the given rectange are free
-- ex: is_side_free(grid, rect, {1, 0}) will check if all tiles on the right of the rectangle are free
-- 
-- A = rect, X = checked tiles
-- A A A X
-- A A A X 
-- A A A X 
-- A A A X
-- A A A X 
function TileMap:is_side_free(rect, direction)
	local normal =  {math.abs(direction[2]), math.abs(direction[1])}
	local axis = (normal[1] == 1) and "x" or "y"
	local base_tile = self:get_tile(rect.ax, rect.ay)
	assert(base_tile ~= nil)

	if axis == "x" then

		local w = rect.bx - rect.ax
		local y = (direction[2] == 1) and rect.by or rect.ay - 1
		for i = 0, w-1 do
			local tile = self:get_tile(rect.ax + i, y)
			if (not tile) or (tile and (tile.id == TILE_AIR or tile.id ~= base_tile.id or tile._is_visited)) then
				return false
			end
		end
		return true
	else
		local h = rect.by - rect.ay
		local x = (direction[1] == 1) and rect.bx or rect.ax - 1
		for i = 0, h-1 do
			local tile = self:get_tile(x, rect.ay + i)
			if (not tile) or (tile and (tile.id == TILE_AIR or tile.id ~= base_tile.id or tile._is_visited)) then
				return false
			end
		end
		return true
	end
end


-- Expands a rect in the given direction by 1 tile
function TileMap:expand_rect(rect, dir)
	local dx, dy = dir[1], dir[2]
	if dx == -1 and dy == 0 then --left
		rect:set_ax(rect.ax - 1)
	elseif dx == 1 and dy == 0 then --right
		rect:set_bx(rect.bx + 1)
	elseif dx == 0 and dy == -1 then --up
		rect:set_ay(rect.ay - 1)
	elseif dx == 0 and dy == 1 then --down
		rect:set_by(rect.by + 1)
	end
end


-- Search for the biggest rectangle that fits, from the tile at (ix, iy) 
function TileMap:biggest_rect(ix, iy)
	local function all_invalid(tab)
		for k, v in pairs(tab) do
			if v then return false end
		end
		return true
	end
	local directions = {
		[{-1,  0}] = true,
		[{ 1,  0}] = true,
		[{ 0, -1}] = true,
		[{ 0,  1}] = true
	}

	local current_rect = Rect:new(ix, iy, ix + 1, iy + 1)
	while not all_invalid(directions) do
		for dir, valid in pairs(directions) do
			if valid then
				local is_free = self:is_side_free(current_rect, dir)
				if is_free then
					self:expand_rect(current_rect, dir)
				else
					directions[dir] = false
				end
			end
		end
	end
	return current_rect
end

function TileMap:set_visited(val)
	for ix = 0, self.width-1 do
		for iy = 0, self.height-1 do
			local tile = self:get_tile(ix, iy)
			if tile then
				tile._is_visited = val
			end
		end
	end
end

--- Converts a grid of squares into a grid with the same collision but with rectangles instead.
--- ex:
--- With each distinct letter representing a rectangle
--- This grid of 8 tiles
--- A B C D
---   E F
---   G H
--- 
--- becomes this with just 2 tiles:
--- A A A A
---   B B
---   B B
function TileMap:rectangularize()
	self:set_visited(false)

	for _, item in pairs(self.world_items) do
		Collision:remove(item)
	end
	self.world_items = {}

	local rectangles = {}	
	for ix = 0, self.width-1 do
		for iy = 0, self.height-1 do
			local tile = self:get_tile(ix, iy)

			if tile and tile.id > 0 and not tile._is_visited then
				local rect = self:biggest_rect(ix, iy)
				table.insert(rectangles, rect)
				for rectx = rect.ax, rect.bx-1 do
					for recty = rect.ay, rect.by-1 do
						local rect_tile = self:get_tile(rectx, recty)

						if rect_tile then
							rect_tile._is_visited = true
						end
					end
				end
			end
		end
	end

	self:set_visited(nil)

	self._removeme_rectangles = rectangles
	for _, rect in pairs(rectangles) do
		local tile = self:get_tile(rect.ax, rect.ay)
		if tile then
			tile.x = rect.x * 16
			tile.y = rect.y * 16
			tile.w = rect.w * 16
			tile.h = rect.h * 16
			Collision:add(tile, rect.x*16, rect.y*16, rect.w*16, rect.h*16)
			table.insert(self.world_items, tile)
		end
	end
	return rectangles
end

return TileMap
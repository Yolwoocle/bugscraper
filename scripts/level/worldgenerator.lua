require "scripts.util"
local Class = require "scripts.meta.class"
local Rect = require "scripts.rect"

local WorldGenerator = Class:inherit()

function WorldGenerator:init(map)
	self.map = map

	self.screen_w = math.ceil(CANVAS_WIDTH / BW)
	self.screen_h = math.ceil(CANVAS_HEIGHT / BW)

	self.end_rubble_slices = {
		Rect:new(0, 16, 29, 16),
		Rect:new(5, 15, 25, 15),
		Rect:new(7, 14, 23, 14),
		Rect:new(10, 13, 22, 13),
		Rect:new(16, 12, 17, 12),
	}

	-- 16, 17
	-- 10, 22
	-- 7, 23
	-- 5, 25
end

function WorldGenerator:reset()
	self.map:reset()
end

function WorldGenerator:set_shaft_rect(rect)
	self.shaft_rect = rect
end

function WorldGenerator:generate_cabin()
	self:reset()

	local map = self.map
	
	-- local ax, ay = floor((map.width - w)/2) + ox, floor((map.height - h)/2) + oy
	-- local bx, by = ax+w-1, ay+h-1
	-- local x, y, w, h = self.shaft_x, self.shaft_y, self.shaft_w, self.shaft_h
	-- local ax, ay = x, y
	-- local bx, by = ax+w, ay+h

	-- cabin
	self:write_rect(self.shaft_rect, 1)
	
	-- chains
	for iy = 0,self.shaft_rect.ay-1 do
		map:set_tile(4, iy, 4)
		map:set_tile(self.shaft_rect.bx-2, iy, 4)
	end
end

function WorldGenerator:generate_cafeteria()
	self:reset()
	self:write_rect(Rect:new(2, 2, 68, 15), 1)

	-- table
	self:write_rect(Rect:new(27, 13, 40, 13), 3)
end

function WorldGenerator:generate_end_rubble()
	self:reset()

	-- Bounds
	-- self:write_rect(Rect:new(0, 0, 29, 0), 1)
	
	-- map collision
	local slices = self.end_rubble_slices
	for i = 1, #slices do
		local tile = ternary(i==1, 1, 2)
		self:write_rect(slices[i], tile)
	end
end

function WorldGenerator:write_rect(rect, value)
	-- Floor/Ceiling
	for ix=rect.ax, rect.bx do
		self.map:set_tile(ix, rect.ay, value)
		self.map:set_tile(ix, rect.by, value)
	end
	-- Left/Right walls
	for iy=rect.ay, rect.by do
		self.map:set_tile(rect.ax, iy, value)
		self.map:set_tile(rect.bx, iy, value)
	end
end


function WorldGenerator:write_rect_fill(ax, ay, bx, by, value)
	for ix=ax, bx do
		for iy=ay, by do
			self.map:set_tile(ix, iy, value)
		end
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

function WorldGenerator:draw()
	if self.canvas then
		gfx.draw(self.canvas, 0,0)
	end
end



return WorldGenerator
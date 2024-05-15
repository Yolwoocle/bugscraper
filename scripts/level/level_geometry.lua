require "scripts.util"
local Class = require "scripts.meta.class"

-- Represents a tilemap preset
local LevelGeometry = Class:inherit()

function LevelGeometry:init(rectangles, reset)
	self.reset = reset
	self.rectangles = rectangles
end

function LevelGeometry:apply(level)
	if self.reset then
		level.world_generator:reset()
	end
	for _, rect_info in pairs(self.rectangles) do
		local tile = rect_info.tile
		local rect = rect_info.rect
		level.world_generator:write_rect(rect, tile) 
	end
end

return LevelGeometry
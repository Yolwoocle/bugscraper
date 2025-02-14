local Class = require "scripts.meta.class"
local Actor = require "scripts.actor.actor"
require "scripts.util"

local Tile = Class:inherit()

function Tile:init_tile(x, y, spr)
	self.type = "tile"
	self.name = "tile"
	self.id = -1

	self.ix = x
	self.iy = y
	self.x = x * BW
	self.y = y * BW
	self.w = BW
	self.h = BW
	self.mine_time = 0

	self.spr = spr

	self.collision_info = nil
end

function Tile:update(dt)
	--
end

function Tile:draw()
	if self.spr then
		love.graphics.draw(self.spr, self.x, self.y)
	end
end

return Tile
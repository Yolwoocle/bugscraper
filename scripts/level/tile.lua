local Class = require "scripts.meta.class"
local Actor = require "scripts.actor.actor"
require "scripts.util"

local Tile = Class:inherit()

function Tile:init_tile(x, y, w, spr)
	self.type = "tile"
	self.name = "tile"
	self.id = -1

	self.mine_time = 0

	self.ix = x
	self.iy = y
	self.x = x * w
	self.y = y * w
	self.w = w
	self.h = w
	self.spr = spr

	self.walk_sound = nil

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
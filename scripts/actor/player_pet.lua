require "scripts.util"
require "scripts.meta.constants"
local Class = require "scripts.meta.class"

local PlayerPet = Class:inherit()

function PlayerPet:init(player, x, y)
	self.player = player
	self.x = x
	self.y = y
end

function PlayerPet:update(dt)
end

function PlayerPet:draw(dt)
end
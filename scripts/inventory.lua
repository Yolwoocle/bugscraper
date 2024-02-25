require "scripts.util"
require "scripts.constants"
local Class = require "scripts.class"

local Inventory = Class:inherit()

function Inventory:init(x,y)
	self.inventory = {}
	for i=1,12 do
		self.inventory[i] = {
			item = nil,
			quantity = 0,
		}
	end
end

function Inventory:update(dt)
	-- 
end

function Inventory:draw()
	--
end

return Inventory
require "scripts.util"
local Class = require "scripts.meta.class"

local Wave = Class:inherit()

function Wave:init(params)
	self.min = param(params.min, 1)
	self.max = param(params.max, 1)
	self.enemies = param(params.enemies, {})
end

function Wave:update(dt)
	--
end

function Wave:draw()
	--
end

return Wave
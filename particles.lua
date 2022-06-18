require "util"
local Class = require "class"
local images = require "images"

local Particle = Class:inherit()

function Particle:init(x,y)

end
function Particle:update(dt)

end
function Particle:draw()

end

------------------------------------------------------------

local ParticleSystem = Class:inherit()

function ParticleSystem:init(x,y)
	self.particles = {}
end

function ParticleSystem:update(dt)
	
end

function ParticleSystem:draw()
	-- gfx.draw(self.system, CANVAS_WIDTH * 0.5, CANVAS_HEIGHT * 0.5)
end

return ParticleSystem
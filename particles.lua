require "util"
local Class = require "class"
local images = require "images"

local Particle = Class:inherit()

function Particle:init(x,y,r,col, vx,vy,vr, life)
	self.x, self.y = x, y
	self.vx, self.vy = vx or 0, vy or 0

	self.col = col or COL_WHITE
	self.r = r
	self.vr = vr or 20
	
	self.max_life = life or 5
	self.life = self.max_life

	self.is_removed = false
end
function Particle:update(dt)
	self.x = self.x - self.vx*dt 
	self.y = self.y - self.vy*dt
	self.r = self.r - self.vr*dt 

	self.life = self.life - dt

	if self.r <= 0 or self.life <= 0 then
		self.is_removed = true
	end
end
function Particle:draw()
	circle_color(self.col, "fill", self.x, self.y, self.r)
end

------------------------------------------------------------

local ParticleSystem = Class:inherit()

function ParticleSystem:init(x,y)
	self.particles = {}
end

function ParticleSystem:update(dt)
	for i,p in pairs(self.particles) do
		p:update(dt)
		if p.is_removed then
			table.remove(self.particles, i)
		end
	end
end

function ParticleSystem:draw()
	for i,p in pairs(self.particles) do
		p:draw()
	end
end

function ParticleSystem:add_particle(...)
	table.insert(self.particles, Particle:new(...))
end

function ParticleSystem:clear()
	self.particles = {}
end

function ParticleSystem:smoke(x, y, number, col, spw_rad, size, sizevar)
	number = number or 10
	col = col or COL_WHITE
	spw_rad = spw_rad or 8
	size = size or 4
	sizevar = sizevar or 2

	for i=1,number do
		local ang = love.math.random() * pi2
		local dist = love.math.random() * spw_rad
		local dx, dy = cos(ang)*dist, sin(ang)*dist
		local dsize = random_neighbor(sizevar)
		self:add_particle(x+dx, y+dy, size+dsize, col, 0, 0, _vr, _life)
	end
end

return ParticleSystem
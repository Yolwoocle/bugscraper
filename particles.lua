require "util"
local Class = require "class"
local images = require "images"

local Particle = Class:inherit()

function Particle:init_particle(x,y,s,r, vx,vy,vs,vr, life, g)
	self.x, self.y = x, y
	self.vx, self.vy = vx or 0, vy or 0

	self.s = s -- size or radius
	self.vs = vs or 20
	
	self.r = r
	self.vr = vr or 0

	self.gravity = g or 0

	self.max_life = life or 5
	self.life = self.max_life

	self.is_removed = false
end

function Particle:update_particle(dt)
	self.x = self.x + self.vx*dt
	self.y = self.y + self.vy*dt
	self.s = self.s - self.vs*dt

	self.vy = self.vy + self.gravity
	self.life = self.life - dt

	if self.s <= 0 or self.life <= 0 then
		self.is_removed = true
	end
end
function Particle:update(dt)
	self:update_particle(dt)
end
function Particle:draw()
end

-----------

local CircleParticle = Particle:inherit()

function CircleParticle:init(x,y,s,col, vx,vy,vs, life, g)
	self:init_particle(x,y,s,0, vx,vy,vs,0, life, g)

	self.col = col or COL_WHITE
	self.type = "circle"
end
function CircleParticle:update(dt)
	self:update_particle(dt)
end
function CircleParticle:draw()
	circle_color(self.col, "fill", self.x, self.y, self.s)
end
------------------------------------------------------------

local ImageParticle = Particle:inherit()

function ImageParticle:init(spr, x,y,s,r, vx,vy,vs,vr, life, g)
	self:init_particle(x,y,s,r, vx,vy,vs,vr, life, g)
	self.spr = spr

	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getWidth()
	self.spr_ox = self.spr_w / 2
	self.spr_oy = self.spr_h / 2
end
function ImageParticle:draw()
	love.graphics.draw(self.spr, self.x, self.y, self.r, self.s, self.s, self.spr_ox, self.spr_oy)
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

function ParticleSystem:add_particle(ptc)
	table.insert(self.particles, ptc)
end

function ParticleSystem:clear()
	self.particles = {}
end

function ParticleSystem:smoke_big(x, y)
	self:smoke(x, y, 15, COL_WHITE, 16, 8, 4)
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
		self:add_particle(CircleParticle:new(x+dx, y+dy, size+dsize, col, 0, 0, _vr, _life))
	end
end

function ParticleSystem:dust(x, y, col, size, rnd_pos, sizevar)
	col = col or COL_WHITE
	rnd_pos = rnd_pos or 3
	size = size or 4
	sizevar = sizevar or 2

	local dx, dy = random_neighbor(rnd_pos), random_neighbor(rnd_pos)
	local dsize = random_neighbor(sizevar)
	self:add_particle(CircleParticle:new(x+dx, y+dy, size+dsize, col, 0, 0, _vr, _life))
end

function ParticleSystem:flash(x, y)
	-- x,y,r,col, vx,vy,vr, life
	local r = 8 + random_neighbor(2)
	-- self:add_particle(x, y, r, COL_LIGHT_YELLOW, 0, 0, 220, _life)
	self:add_particle(CircleParticle:new(x, y, r, COL_WHITE, 0, 0, 220, _life))
end

function ParticleSystem:image(x, y, number, spr, spw_rad, life)
	number = number or 10
	spw_rad = spw_rad or 8
	life = life or 1
	-- size = size or 4
	-- sizevar = sizevar or 2

	for i=1,number do
		local ang = love.math.random() * pi2
		local dist = love.math.random() * spw_rad
		local dx, dy = cos(ang)*dist, sin(ang)*dist
		-- local dsize = random_neighbor(sizevar)

		local rot = random_neighbor(pi)
		local vx = random_neighbor(100)
		local vy = -random_range(40, 80)
		local vs = random_range(1, 0.5)
		local vr = random_neighbor(1)
		local life = life + random_neighbor(0.5)
		local g = 3
		self:add_particle(ImageParticle:new(spr, x+dx, y+dy, 1, rot, vx,vy,vs,vr, life, g))
	end
end

return ParticleSystem
require "scripts.util"
local Class = require "scripts.meta.class"
local Sprite = require "scripts.graphics.sprite"
local images = require "data.images"
local utf8 = require "utf8"

local Particle = Class:inherit()

function Particle:init_particle(x,y,s,r, vx,vy,vs,vr, life, g, is_solid)
	self.x, self.y = x, y
	self.vx, self.vy = vx or 0, vy or 0

	self.s = s or 1.0-- size or radius
	self.vs = vs or 20 
	
	self.r = r or 0
	self.vr = vr or 0

	self.gravity = g or 0
	self.is_solid = is_solid or false
	self.bounces = 2
	self.bounce_force = 100

	self.max_life = life or 5
	self.life = self.max_life

	self.is_removed = false
end

function Particle:update_particle(dt)
	self.x = self.x + self.vx*dt
	self.y = self.y + self.vy*dt
	self.s = self.s - self.vs*dt
	self.r = self.r + self.vr*dt

	self.vy = self.vy + self.gravity
	self.life = self.life - dt

	if self.is_solid then
		local items, len = Collision.world:queryPoint(self.x, self.y, function(item) 
			return (item.collision_info and item.collision_info.type == COLLISION_TYPE_SOLID) or item.is_player
		end) --FIXME: particles can go through walls bc no checks on the collision vector are made 
		if len > 0 then
			self.bounces = self.bounces - 1
			self.vy = -self.bounce_force - random_neighbor(40)
		end
	end

	if self.s <= 0 or self.life <= 0 then
		self.is_removed = true
	end
end
function Particle:update(dt)
	self:update_particle(dt)
end
function Particle:draw()
end
function Particle:remove()
	self.is_removed = true
end

-----------

local CircleParticle = Particle:inherit()

function CircleParticle:init(x,y,s,col, vx,vy,vs, life, g, fill_mode)
	self:init_particle(x,y,s,0, vx,vy,vs,0, life, g)

	self.col = col or COL_WHITE
	self.fill_mode = fill_mode or "fill"
	self.type = "circle"
end
function CircleParticle:update(dt)
	self:update_particle(dt)
end
function CircleParticle:draw()
	circle_color(self.col, self.fill_mode, self.x, self.y, self.s)
end
------------------------------------------------------------

local ImageParticle = Particle:inherit()

function ImageParticle:init(spr, x,y,s,r, vx,vy,vs,vr, life, g, is_solid)
	self:init_image_particle(spr, x,y,s,r, vx,vy,vs,vr, life, g, is_solid)
end
function ImageParticle:init_image_particle(spr, x,y,s,r, vx,vy,vs,vr, life, g, is_solid)
	self:init_particle(x,y,s,r, vx,vy,vs,vr, life, g, is_solid)
	self.spr = spr

	self.is_animated = (type(spr) == "table")
	if self.is_animated then
		self.spr_table = spr
		self.spr = spr[1]
	end
	
	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getWidth()
	self.spr_ox = self.spr_w / 2
	self.spr_oy = self.spr_h / 2
	
	self.is_solid = is_solid
end
function ImageParticle:update(dt)
	self:update_particle(dt)

	if self.is_animated then
		local frame_i = clamp(math.ceil(#self.spr_table * (1 - self.life/self.max_life)), 1, #self.spr_table)
		self.spr = self.spr_table[frame_i]
	end
end
function ImageParticle:draw()
	love.graphics.draw(self.spr, self.x, self.y, self.r, self.s, self.s, self.spr_ox, self.spr_oy)
end

------------------------------------------------------------

local TextParticle = Particle:inherit()

function TextParticle:init(x,y,str,spawn_delay,col)
	self:init_particle(x,y,s,r, vx,vy,vs,vr, life, g, is_solid)
	self.str = str

	self.col_in = col
	self.vy = -5
	self.vy2 = 0
	self.spawn_delay = spawn_delay
end
function TextParticle:update(dt)
	if self.spawn_delay > 0 then
		self.spawn_delay = self.spawn_delay - dt
		return
	end

	self.vy = self.vy * 0.9
	self.y = self.y + self.vy
	
	if abs(self.vy) <= 0.005 then
		self.vy2 = self.vy2 - dt*2
		self.y = self.y + self.vy2
	end
	if abs(self.vy) <= 0.001 then
		self.is_removed = true
	end
end
function TextParticle:draw()
	if self.spawn_delay > 0 then
		return
	end

	local col = COL_WHITE
	if self.col_in then col = self.col_in end
	print_outline(col, COL_BLACK_BLUE, self.str, self.x, self.y)
end


------------------------------------------------------------

local StompedEnemyParticle = Particle:inherit()

function StompedEnemyParticle:init(x,y,spr)
	--                 x,y,s,r, vx,vy,vs,vr, life, g, is_solid
	self:init_particle(x,y,1,0, 0,0,0,0,     2, 0, false)
	self.spr = spr
	
	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getHeight()
	self.spr_ox = self.spr_w / 2
	self.spr_oy = self.spr_h

	self.sx = 1
	self.sy = 1
	self.squash = 1
	self.squash_target = 2
end
function StompedEnemyParticle:update(dt)
	self:update_particle(dt)
	self.squash = lerp(self.squash, self.squash_target, 0.2)

	self.sx = self.squash
	self.sy = (1/self.squash) * 0.5

	if abs(self.squash_target - self.squash) <= 0.01 then
		self.is_removed = true
		Particles:smoke(self.x, self.y)
	end
end
function StompedEnemyParticle:draw()
	-- local oy = self.spr_h*.5 - self.spr_h*.5*self.sy
	love.graphics.draw(self.spr, self.x, self.y, self.r, self.sx, self.sy, self.spr_ox, self.spr_oy)
end

------------------------------------------------------------

local DeadPlayerParticle = Particle:inherit()

function DeadPlayerParticle:init(x,y,spr, colors, dir_x)
	--                 x,y,s,r, vx,vy,vs,vr, life, g, is_solid
	self:init_particle(x,y,1,0, 0,0,0,0,     10, 0, false)
	self.spr = spr
	
	self.dir_x = dir_x
	
	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getHeight()
	self.spr_ox = self.spr_w / 2
	self.spr_oy = self.spr_h / 2

	self.oy = 0

	self.sx = 1
	self.sy = 1

	self.r = 0

	self.cols = colors

	Particles:splash(self.x, self.y - self.oy, 40, self.cols)
end
function DeadPlayerParticle:update(dt)
	self:update_particle(dt)

	local goal_r = 5*sign(self.dir_x)*pi2
	self.r = lerp(self.r, goal_r, 0.06)
	self.oy = lerp(self.oy, 40, 0.05)

	if abs(self.r - goal_r) < 0.1 then
		game:screenshake(10)
		Audio:play("explosion")
		Particles:splash(self.x, self.y - self.oy, 40, {COL_LIGHT_YELLOW, COL_ORANGE, COL_LIGHT_RED, COL_WHITE})
		self.is_removed = true
	end
end
function DeadPlayerParticle:draw()
	love.graphics.draw(self.spr, self.x, self.y - self.oy, self.r, self.sx, self.sy, self.spr_ox, self.spr_oy)
end

------------------------------------------------------------


local EjectedPlayerParticle = Particle:inherit()

function EjectedPlayerParticle:init(spr, x, y, vx, vy)
	--                (x,y,s,r, vx,vy,vs,vr,                    life, g, is_solid)
	self:init_particle(x,y,1,0, vx,vy,0,random_range(10, 20),   3,    15)
	self.spr = spr
	
	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getWidth()
	self.spr_ox = self.spr_w / 2
	self.spr_oy = self.spr_h / 2
	
	self.is_solid = false
end
function EjectedPlayerParticle:update(dt)
	self:update_particle(dt)
	Particles:dust(self.x, self.y, COL_WHITE, nil, nil, nil, true)
end
function EjectedPlayerParticle:draw()
	love.graphics.draw(self.spr, self.x, self.y, self.r, self.s, self.s, self.spr_ox, self.spr_oy)
end

------------------------------------------------------------


local SmashedPlayerParticle = Particle:inherit()

function SmashedPlayerParticle:init(spr, x, y, vx, vy)
	--                (x,y,s,r, vx,vy,vs,vr,                    life, g, is_solid)
	self:init_particle(x,y,1,0, 0,0,0,0,   3,    0)
	self.future_vx = vx
	self.future_vy = vy
	self.future_vr = random_range(10, 20)

	self.ox = 0
	self.oy = 0

	self.spr = spr
	
	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getWidth()
	self.spr_ox = self.spr_w / 2
	self.spr_oy = self.spr_h / 2
	
	self.freeze_duration = 1.0

	self.is_solid = false
end
function SmashedPlayerParticle:update(dt)
	self:update_particle(dt)

	self.freeze_duration = max(0.0, self.freeze_duration - dt)
	if self.freeze_duration <= 0 then
		self.vx = self.future_vx
		self.vy = self.future_vy
		self.vr = self.future_vr
	-- else
		-- self.ox = random_neighbor(3)
		-- self.oy = random_neighbor(3)
	end

	if self.y <= -8 then
		local a = atan2(self.vy, self.vx)
		game:screenshake(15)
		Particles:smash_flash(self.x, -80, a, COL_LIGHT_BLUE)
		Particles:smash_flash(self.x, -80, a, color(0xf6757a))
		Particles:smash_flash(self.x, -80, a, COL_WHITE)
		self:remove()
	end

	Particles:dust(self.x, self.y, COL_WHITE, nil, nil, nil, true)
end
function SmashedPlayerParticle:draw()
	love.graphics.draw(self.spr, self.x + self.ox, self.y + self.oy, self.r, self.s, self.s, self.spr_ox, self.spr_oy)
end

------------------------------------------------------------


local SmashFlashParticle = Particle:inherit()

function SmashFlashParticle:init(x, y, r, col)
	--                (x,y,s,r, vx,vy,vs,vr, life, g, is_solid)
	self:init_particle(x,y,1,r, 0,0,0,0,     1,    0)
	self.spr = images.smash_flash
	self.col = col

	self.sx = 1
	self.sy = 1
	self.flip_y = false
	self.flash_size = 1.0

	self.spr_w = self.spr:getWidth()
	self.spr_h = self.spr:getWidth()
	self.spr_ox = self.spr_w
	self.spr_oy = 0
	
	self.is_solid = false

	self.points = {}
end
function SmashFlashParticle:update(dt)
	self:update_particle(dt)
	
	self.ox = random_neighbor(10)
	self.oy = random_neighbor(10)

	self.flash_size = (self.life / self.max_life)
	self.sy = random_range(0.8, 1.2) * self.flash_size
	-- self.sx = 0.5 * self.flash_size
	-- if random_sample{0, 1} == 1 then
	-- 	self.flip_y = not self.flip_y
	-- end
end
function SmashFlashParticle:draw()
	exec_color(self.col, function()
		local fy = 1-- ternary(self.flip_y, -1, 1)
		love.graphics.draw(self.spr, self.x + self.ox, self.y + self.oy, self.r, self.sx, fy*self.sy, self.spr_ox, self.spr_oy)
	end)
end

------------------------------------------------------------

local FallingGridParticle = Particle:inherit()

function FallingGridParticle:init(img_side, img_top, x,y)
	self:init_particle(x,y,s,r, vx,vy,0,vr, 2.5, g, false)
	self.spr_side = Sprite:new(img_side, SPRITE_ANCHOR_LEFT_BOTTOM)
	self.spr_top =  Sprite:new(img_top,  SPRITE_ANCHOR_LEFT_BOTTOM)
	self.spr_top:set_scale(nil, 0)

	self.orig_y = y

	-- self.spr_w = self.spr:getWidth()
	-- self.spr_h = self.spr:getWidth()
	-- self.spr_ox = self.spr_w / 2
	-- self.spr_oy = self.spr_h / 2
	
	self.t = 0 
	self.rot_3d = math.pi/2
	self.rot_3d_vel = 0 
	self.rot_3d_acc = -6
	self.rot_3d_bounce = 0.5
end

function FallingGridParticle:update(dt)
	self:update_particle(dt)

	self.t = self.t + dt*4
	if self.rot_3d > 0 then
		self.rot_3d_vel = self.rot_3d_vel + self.rot_3d_acc*dt 
	end
	self.rot_3d = math.max(0, self.rot_3d + self.rot_3d_vel*dt)
	
	if self.rot_3d <= 0 and math.abs(self.rot_3d_vel) >= 0.5 then
		self.rot_3d_vel = math.abs(self.rot_3d_vel) * self.rot_3d_bounce

		local w = self.spr_side.image:getWidth()
		for ix = 0, w, 4 do
			Particles:dust(self.x + ix, self.y)
		end
	end

	self.spr_side:set_scale(nil, math.sin(self.rot_3d))
	self.spr_top:set_scale(nil, math.cos(self.rot_3d))
	
	self.y = self.orig_y + math.cos(self.rot_3d) * self.spr_top.image:getHeight()
end

function FallingGridParticle:draw()
	self.spr_side:draw(self.x, self.y)
	self.spr_top:draw(self.x, self.y - math.sin(self.rot_3d) * self.spr_side.image:getHeight())
	-- love.graphics.line(self.x-32, self.orig_y, self.x+32, self.orig_y)
end

------------------------------------------------------------

local SparkParticle = Particle:inherit()

function SparkParticle:init(x,y, life, g, is_solid)
	local vx, vy = random_neighbor(150), -70 + random_neighbor(15)
	local g = 10 + random_neighbor(3)
	self:init_particle(x,y,__s,__r, vx,vy,0,1, life, g, is_solid)

	self.is_solid = false --param(is_solid, true)
	self.color = random_sample{COL_WHITE, COL_WHITE, COL_WHITE, COL_LIGHT_YELLOW, COL_YELLOW_ORANGE}
end
function SparkParticle:update(dt)
	self:update_particle(dt)

end
function SparkParticle:draw()
	local mult = 0.05
	line_color(self.color, self.x, self.y, self.x + self.vx*mult, self.y + self.vy*mult)
end

------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------

local ParticleSystem = Class:inherit()

function ParticleSystem:init(x,y)
	self.layers = {}
	self.layer_count = PARTICLE_LAYER_COUNT
	for i = 1, self.layer_count do
		self.layers[i] = {}
	end
end

function ParticleSystem:update(dt) 
	for _, layer in pairs(self.layers) do
		for i, p in pairs(layer) do
			p:update(dt)
			if p.is_removed then
				-- OPTI: maybe performance can improved by doing layer[i] = nil instead as it won't 
				-- shift all items in the table  
				table.remove(layer, i)
			end
		end
	end
end

function ParticleSystem:draw_layer(layer_id)
	layer_id = param(layer_id, PARTICLE_LAYER_NORMAL)
	for i,p in pairs(self.layers[layer_id]) do
		p:draw()
	end
end

function ParticleSystem:add_particle(ptc, layer_id)
	layer_id = param(layer_id, PARTICLE_LAYER_NORMAL)
	assert(self.layers[layer_id] ~= nil, "layer doesn't exist")
	table.insert(self.layers[layer_id], ptc)
end

function ParticleSystem:clear(layer_id)
	if layer_id == nil then
		for i=1, self.layer_count do
			self.layers[i] = {}
		end
	else
		self.layers[layer_id] = {}
	end
end

function ParticleSystem:smoke_big(x, y, col)
	self:smoke(x, y, 15, col or COL_WHITE, 16, 8, 4)
end

function ParticleSystem:smoke(x, y, number, col, spw_rad, size, sizevar, layer, fill_mode)
	number = number or 10
	spw_rad = spw_rad or 8
	size = size or 4
	sizevar = sizevar or 2
	layer = param(layer, PARTICLE_LAYER_FRONT)

	for i=1,number do
		local ang = love.math.random() * pi2
		local dist = love.math.random() * spw_rad
		local dx, dy = cos(ang)*dist, sin(ang)*dist
		local dsize = random_neighbor(sizevar)
		
		local v = random_range(0.6, 1)
		local col = col or {v,v,v,1}
		-- x,y,s,col, vx,vy,vs, life, g, fill_mode
		local particle = CircleParticle:new(x+dx, y+dy, size+dsize, col, 0, 0, _vs, _vr, _life, fill_mode)
		self:add_particle(particle, layer)
	end
end

function ParticleSystem:dust(x, y, col, size, rnd_pos, sizevar)
	rnd_pos = param(rnd_pos, 3)
	size = param(size, 4)
	sizevar = param(sizevar, 2)

	local dx, dy = random_neighbor(rnd_pos), random_neighbor(rnd_pos)
	local dsize = random_neighbor(sizevar)

	local v = random_range(0.6, 1)
	local col = col or {v,v,v,1}
	self:add_particle(CircleParticle:new(x+dx, y+dy, size+dsize, col, 0, 0, _vr, _life))
end


function ParticleSystem:fire(x, y, size, sizevar, velvar, vely)
	rnd_pos = rnd_pos or 3
	size = size or 4
	sizevar = sizevar or 2

	local dx, dy = random_neighbor(rnd_pos), random_neighbor(rnd_pos)
	local dsize = random_neighbor(sizevar)

	local col_fire = {1, random_range(0, 1),0.2,1}
	local v = random_range(0.6, 1)
	local col_smoke = {v,v,v,1}
	local col = random_sample{col_fire, col_smoke}

	velvar = velvar or 5
	vely = vely or -2
	local vy = random_range(vely - velvar, vely)
	local particle = CircleParticle:new(x+dx, y+dy, size+dsize, col, 0, vy, _vr, _life)
	self:add_particle(particle)
end


function ParticleSystem:splash(x, y, number, col, spw_rad, size, sizevar)
	number = number or 10
	spw_rad = spw_rad or 8
	size = size or 4
	sizevar = sizevar or 2

	for i=1,number do
		local ang = love.math.random() * pi2
		local dist = love.math.random() * spw_rad
		local dx, dy = cos(ang)*dist, sin(ang)*dist
		local dsize = random_neighbor(sizevar)
		
		local v = random_range(0.6, 1)
		local c = col or {v,v,v,1}
		if type(col) == "table" then
			c = random_sample(col)
		end

		local vx = random_neighbor(50)
		local vy = random_range(-200, 0)
		local vy = random_neighbor(50)
		local vs = random_range(6,12)

		self:add_particle(CircleParticle:new(x+dx, y+dy, size+dsize, c, vx, vy, vs, _life, 0))
	end
end


function ParticleSystem:glow_dust(x, y, size, sizevar)
	size = size or 4
	sizevar = sizevar or 2

	local ang = love.math.random() * pi2
	local spd = random_neighbor(50)
	local vx = cos(ang) * spd
	local vy = sin(ang) * spd
	local vs = random_range(6,12)
	local dsize = random_neighbor(sizevar)

	self:add_particle(CircleParticle:new(x, y, size+dsize, COL_WHITE, vx, vy, vs, _life, 0))
end


function ParticleSystem:flash(x, y)
	-- x,y,r,col, vx,vy,vr, life
	local r = 8 + random_neighbor(2)
	-- self:add_particle(x, y, r, COL_LIGHT_YELLOW, 0, 0, 220, _life)
	self:add_particle(CircleParticle:new(x, y, r, COL_WHITE, 0, 0, 220, _life))
end

-- FIXME giant scotch, fix for later
function ParticleSystem:image(x, y, number, spr, spw_rad, life, vs, g, parms)
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
		local vs = vs or random_range(1, 0.5)
		local vr = random_neighbor(1)
		local life = life + random_neighbor(0.5)
		local g = (g or 1) * 3
		local is_solid = true
		local is_animated = false

		if parms and parms.vx1 ~= nil and parms.vx2 ~= nil then
			vx = random_range(parms.vx1, parms.vx2)
		end
		if parms and parms.vy1 ~= nil and parms.vy2 ~= nil then
			vy = random_range(parms.vy1, parms.vy2)
		end
		if parms and parms.vr1 ~= nil and parms.vr2 ~= nil then
			vr = random_range(parms.vr1, parms.vr2)
		end
		if parms and parms.rot ~= nil then
			rot = parms.rot
		end
		if parms and parms.is_solid ~= nil then
			is_solid = parms.is_solid
		end
		if parms and parms.is_animated ~= nil then
			is_animated = parms.is_animated
		end
		if parms and parms.life ~= nil then
			life = parms.life
		end
		
		local sprite = spr
		if (not is_animated) and type(spr) == "table" then
			sprite = random_sample(spr)
		end
		--spr, x,y,s,r, vx,vy,vs,vr, life, g, is_solid
		self:add_particle(ImageParticle:new(sprite, x+dx, y+dy, 1, rot, vx,vy,vs,vr, life, g, is_solid))
	end
end

-- FIXME: scotch
function ParticleSystem:static_image(img, x, y, rot)
	Particles:image(x, y, 1, img, 0, nil, 0, 0, {
		is_solid = false,
		rot = rot,
		vx1 = 0,
		vx2 = 0,
		vy1 = 0,
		vy2 = 0,
		vr1 = 0,
		vr2 = 0,
		life = 0.12,
		is_animated = true
	})
end

-- FIXME: scotch
function ParticleSystem:bullet_vanish(x, y, rot)
	self:static_image({
		images.bullet_vanish_1,
		images.bullet_vanish_2,
		images.bullet_vanish_3,
	}, x, y, rot)
end

function ParticleSystem:stomped_enemy(x, y, spr)
	self:add_particle(StompedEnemyParticle:new(x, y, spr))
end

function ParticleSystem:dead_player(x, y, spr, colors, dir_x)
	self:add_particle(DeadPlayerParticle:new(x, y, spr, colors, dir_x), PARTICLE_LAYER_FRONT)
end

function ParticleSystem:ejected_player(spr, x, y, vx, vy)
	self:add_particle(EjectedPlayerParticle:new(spr, x, y, vx or random_range(100, 300), vy or -random_range(400, 600)), PARTICLE_LAYER_FRONT)
end

function ParticleSystem:smashed_player(spr, x, y, vx, vy)
	self:add_particle(SmashedPlayerParticle:new(spr, x, y, vx or 400, vy or -random_range(600, 600)), PARTICLE_LAYER_FRONT)
end

function ParticleSystem:smash_flash(x, y, r, col)
	self:add_particle(SmashFlashParticle:new(x, y, r, col), PARTICLE_LAYER_FRONT)
end

function ParticleSystem:letter(x, y, str, spawn_delay, col)
	self:add_particle(TextParticle:new(x, y, str, spawn_delay, col))
end

function ParticleSystem:word(x, y, str, col)
	local x = x - get_text_width(str)/2
	for i=1, #str do
		local letter = utf8.sub(str, i,i)
		Particles:letter(x, y, letter, i*0.05, col)
		x = x + get_text_width(letter)
	end
end

function ParticleSystem:falling_grid(x, y)
	self:add_particle(FallingGridParticle:new(images.cabin_grid, images.cabin_grid_platform, x, y), PARTICLE_LAYER_SHADOWLESS)
end

function ParticleSystem:spark(x, y, amount)
	amount = param(amount, 1)
	local life = 3 + random_neighbor(0.2)
	local g = nil
	local is_solid = false
	for i=1, amount do 
		self:add_particle(SparkParticle:new(x,y, life, g, is_solid), PARTICLE_LAYER_FRONT)
	end
end

ParticleSystem.text = ParticleSystem.word



return ParticleSystem
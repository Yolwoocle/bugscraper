require "util"
local Class = require "class"
local Enemy = require "enemy"
local images = require "images"

local Enemies = Class:inherit()

function Enemies:init()
	self.Bug = Enemy:inherit()
	function self.Bug:init(x, y)
		self:init_enemy(x,y)
		self.name = "bug"
		self.life = 10
		self.color = rgb(0,50,190)
	end

	-----------------
	
	self.Fly = Enemy:inherit()
	
	function self.Fly:init(x, y)
		self:init_enemy(x,y, images.fly)
		self.name = "fly"
		self.is_flying = true
		self.life = 10
		--self.speed_y = 0--self.speed * 0.5
		
		self.speed = 10
		self.speed_x = self.speed
		self.speed_y = self.speed

		self.gravity = 0
		self.friction_y = self.friction_x
	end

	-------------

	self.Larva = Enemy:inherit()
	
	function self.Larva:init(x, y)
		self:init_enemy(x,y, images.larva, 11, 11)
		self.name = "larva"

		self.life = 5
		self.speed = 5
	end

	-------------

	self.Grasshopper = Enemy:inherit()
	
	function self.Grasshopper:init(x, y)
		self:init_enemy(x,y, images.grasshopper, 12, 12)
		self.name = "grasshopper"
		self.life = 10
		self.follow_player = false
		
		self.speed = 100
		self.vx = self.speed
		self.friction = 1
		self.friction_x = 1
		self.friction_y = 1
		self.walk_dir_x = random_sample{-1, 1}

		local v = 0.5
		self.gravity = self.gravity * v

		self.jump_speed = 300
	end

	function self.Grasshopper:update(dt)
		self:update_enemy(dt)
		self.vx = self.speed * self.walk_dir_x
	end

	function self.Grasshopper:draw()
		self:draw_enemy()
	end

	function self.Grasshopper:on_collision(col, other)
		if other.is_solid then
			if col.normal.y == 0 then
				self.walk_dir_x = col.normal.x
			end
		end
	end

	function self.Grasshopper:on_grounded()
		self.vy = -self.jump_speed
	end

	--------

	self.Slug = Enemy:inherit()

	function self.Slug:init(x, y) 
		self:init_enemy(x, y, images.slug, 14, 9)
		self.follow_player = true
	end

	
	------------------

	self.SnailShelled = Enemy:inherit()

	function self.SnailShelled:init(x, y)
		self:init_enemy(x,y, images.snail_shell, 16, 16)
		self.is_flying = true
		self.follow_player = false

		self.rot_speed = 3

		self.gravity = 0
		self.friction_y = self.friction_x 

		self.pong_speed = 40
		self.dir = (pi/4 + pi/2 * love.math.random(0,3)) % pi2
		self.pong_vx = cos(self.dir) * self.pong_speed
		self.pong_vy = sin(self.dir) * self.pong_speed

		self.spr_oy = floor((self.spr_h - self.h) / 2)
	end

	function self.SnailShelled:update(dt)
		self:update_enemy(dt)
		self.rot = self.rot + self.rot_speed * dt 

		self.vx = self.vx + (self.pong_vx or 0)
		self.vy = self.vy + (self.pong_vy or 0)
	end

	function self.SnailShelled:on_collision(col, other)
		-- Pong-like bounce
		if col.other.is_solid or col.other.name == "" then
			particles:smoke(col.touch.x, col.touch.y)

			if col.normal.x ~= 0 then    self.pong_vx = sign(col.normal.x) * abs(self.pong_vx)    end
			if col.normal.y ~= 0 then    self.pong_vy = sign(col.normal.y) * abs(self.pong_vy)    end
		end
	end

	function self.SnailShelled:draw()
		self:draw_enemy()
	end

	local Slug = self.Slug
	function self.SnailShelled:on_death()
		game:new_actor(Slug:new(self.x, self.y))
	end
end

return Enemies:new()
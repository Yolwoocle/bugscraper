require "util"
local Class = require "class"
local Enemy = require "enemy"
local images = require "images"

local Enemies = Class:inherit()

function Enemies:init()
	self.Bug = Enemy:inherit()
	self.Bug.init = function(self, x, y)
		self:init_enemy(x,y)
		self.life = 10
		self.color = rgb(0,50,190)
	end

	-----------------
	
	self.Fly = Enemy:inherit()
	
	self.Fly.init = function(self, x, y)
		self:init_enemy(x,y, images.fly)
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
	
	self.Larva.init = function(self, x, y)
		self:init_enemy(x,y, images.larva, 7, 7)

		self.life = 5
		self.speed = 5
	end

	-------------

	self.Grasshopper = Enemy:inherit()
	
	function self.Grasshopper:init(x, y)
		self:init_enemy(x,y, images.grasshopper, 12, 12)
		self.life = 10
		self.speed = 20
		self.follow_player = false

		local v = 0.5
		self.gravity = self.gravity * v
		self.jump_speed = 300
	end

	function self.Grasshopper:update(dt)
		self:update_enemy(dt)
		self.vx = self.speed
	end

	function self.Grasshopper:on_collision(col, other)
		if other.is_solid then
			if col.normal.y == 0 then
				self.vx = self.vx * col.normal.x
			end
		end
	end

	function self.Grasshopper:on_grounded()
		self.vy = -self.jump_speed
	end
end

return Enemies:new()
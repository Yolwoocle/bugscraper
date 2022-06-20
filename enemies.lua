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
	
	self.Bee = Enemy:inherit()
	
	self.Bee.init = function(self, x, y)
		self:init_enemy(x,y, images.bee)
		self.is_flying = true
		self.life = 10
		--self.speed_y = 0--self.speed * 0.5
		
		self.speed = 10
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
end

return Enemies:new()
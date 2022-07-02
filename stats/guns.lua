require "util"
local Class = require "class"
local Gun = require "gun"
local images = require "images"

local Guns = Class:inherit()

function Guns:init()
	self.Machinegun = Gun:inherit()

	function self.Machinegun:init(user)
		self:init_gun(user)
		self.name = "machinegun"
		self.spr = images.gun_machinegun
		self.max_ammo = 1000
		self.cooldown = 0.1
	end

	-------

	self.Triple = Gun:inherit()

	function self.Triple:init(user)
		self:init_gun(user)
		self.name = "triple"
		self.spr = images.gun_triple
		self.max_ammo = 1000
		self.cooldown = 0.1
		self.bullet_number = 3
		self.random_angle_offset = 0
	end

	--------

	self.Burst = Gun:inherit()

	function self.Burst:init(user)
		self:init_gun(user)
		self.name = "burst"
		self.spr = images.gun_burst
		self.bullet_spread = 0.2
		
		self.is_burst = true
		self.burst_count = 5
		self.burst_delay = 0.05
		self.cooldown = 1
	end

	----------------

	self.Shotgun = Gun:inherit()

	function self.Shotgun:init(user)
		self:init_gun(user)
		self.name = "shotgun"
		self.spr = images.gun_shotgun
		
		self.cooldown = 0.4
		self.bullet_speed = 800 --def: 400
		self.bullet_number = 12
		self.bullet_spread = 0
		self.bullet_friction = 0.95
		self.random_angle_offset = 0.3
		self.random_friction_offset = 0.05

		self.speed_floor = 200

		self.jetpack_force = 700 --def: 340
	end	
end

return Guns:new()
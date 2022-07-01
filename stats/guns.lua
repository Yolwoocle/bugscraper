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
		self.sprite = images.gun_machinegun
		self.max_ammo = 1000
		self.cooldown = 0.1
	end

	-------

	self.Triple = Gun:inherit()

	function self.Triple:init(user)
		self:init_gun(user)
		self.name = "triple"
		self.sprite = images.gun_triple
		self.max_ammo = 1000
		self.cooldown = 0.1
		self.bullet_number = 3
	end

	--------

	self.Burst = Gun:inherit()

	function self.Burst:init(user)
		self:init_gun(user)
		self.name = "burst"
		self.sprite = images.gun_burst
		
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
		self.sprite = images.gun_shotgun
	end	
end

return Guns:new()
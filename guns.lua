require "util"
local Class = require "class"
local Gun = require "gun"
local images = require "images"

local Guns = Class:inherit()

function Guns:init()
	self.Machinegun = Gun:inherit()

	function self.Machinegun:init()
		self:init_gun()
		self.sprite = images.gun_machinegun
		self.ammo = 1000
		self.cooldown = 0.1
	end

	-------

	self.Triple = Gun:inherit()

	function self.Triple:init()
		self:init_gun()
		self.sprite = images.gun_triple
		self.ammo = 1000
		self.cooldown = 0.1
		self.bullet_number = 3
	end
end

return Guns:new()
require "util"
local Class = require "class"
local Gun = require "gun"
local images = require "data.images"
local sounds = require "data.sounds"

local Guns = Class:inherit()

function Guns:init()
	self.Machinegun = Gun:inherit()

	function self.Machinegun:init(user)
		self:init_gun(user)
		self.name = "machinegun"
		self.display_name = "machinegun"
		
		self.sfx = "mushroom_ant_pop"
		self.damage = 1.5
		self.max_ammo = 25
		self.max_reload_timer = 1.5
		self.is_auto = true
		self.spr = images.gun_machinegun

		self.cooldown = 0.1
		self.jetpack_force = 440
		self.screenshake = 2
	end

	-------

	self.Triple = Gun:inherit()

	function self.Triple:init(user)
		self:init_gun(user)
		self.name = "triple"
		self.display_name = "triple"

		self.max_ammo = 15

		self.damage = 1.5
		self.is_auto = true
		self.spr = images.gun_triple
		self.sfx = "triple_pop"
		self.sfx_pitch = 0.9
		self.cooldown = 0.2
		self.bullet_number = 3
		self.random_angle_offset = 0
		self.jetpack_force = self.default_jetpack_force * 2

		self.screenshake = 2
	end

	--------

	self.Burst = Gun:inherit()

	function self.Burst:init(user)
		self:init_gun(user)
		self.name = "burst"
		self.display_name = "burst"
		self.spr = images.gun_burst
		self.sfx = "mushroom_ant_pop"
		self.sfx_pitch = 1.1
		self.bullet_spread = 0.2
		
		self.is_auto = false
		self.is_burst = true
		
		self.damage = 1.5
		self.cooldown = 0.4
		self.burst_count = 5
		self.burst_delay = 0.05
		
		self.max_ammo = self.burst_count * 6

		self.screenshake = 1.5
	end

	----------------

	self.Shotgun = Gun:inherit()

	function self.Shotgun:init(user)
		self:init_gun(user)
		self.name = "shotgun"
		self.display_name = "shotgun"
		self.spr = images.gun_shotgun
		self.sfx = "mushroom_ant_pop"
		self.sfx_pitch = 0.6
		self.is_auto = false

		self.damage = 1
		self.cooldown = 0.4
		self.bullet_speed = 800 --def: 400
		self.bullet_number = 12

		self.max_ammo = 7
		self.max_reload_timer = 2

		self.bullet_spread = 0
		self.bullet_friction = 0.95
		self.random_angle_offset = 0.3
		self.random_friction_offset = 0.05

		self.speed_floor = 200

		self.jetpack_force = 1200 --def: 340

		self.screenshake = 4
	end

	--------

	self.Minigun = Gun:inherit()

	function self.Minigun:init(user)
		self:init_gun(user)
		self.name = "machinegun"
		self.display_name = "machinegun"
		
		self.max_ammo = 150
		self.max_reload_timer = 1.5

		self.random_angle_offset = 0.5
		self.damage = 1
		self.is_auto = true
		self.spr = images.gun_minigun
		self.sfx = "mushroom_ant_pop"
		self.sfx_pitch = 1.2

		self.cooldown = 0.03
		self.jetpack_force = 200

		self.screenshake = 0.7
	end

	-----

	self.MushroomCannon = Gun:inherit()

	function self.MushroomCannon:init(user)
		self:init_gun(user)
		self.name = "mushroom_cannon"
		self.display_name = "mushroom cannon"
		
		self.sfx = "mushroom_ant_pop"
		self.sfx_pitch = 0.7
		self.damage = 4
		self.is_auto = true
		self.spr = images.gun_mushroom_cannon
		self.bullet_spr = images.mushroom_yellow
		self.bullet_speed = 300
		self.bul_w = 14
		self.bul_h = 14

		self.max_ammo = 20

		self.cooldown = 0.2
		self.jetpack_force = 640

		self.screenshake = 2
	end

	-----

	self.unlootable = {}

	self.unlootable.MushroomAntGun = Gun:inherit()

	function self.unlootable.MushroomAntGun:init(user)
		self:init_gun(user)
		self.name = "mushroom_ant_gun"
		self.is_lootable = false
		
		self.sfx = "mushroom_ant_pop"
		self.damage = 1
		self.is_auto = true
		self.spr = images.empty
		self.bullet_spr = images.mushroom
		self.max_ammo = 20
		self.bullet_speed = 100
		self.random_angle_offset = 0.5

		self.cooldown = 0
		self.jetpack_force = 340
	end

	------
	self.unlootable.DebugGun = Gun:inherit()

	function self.unlootable.DebugGun:init(user)
		self:init_gun(user)
		self.name = "debug_gun"
		
		self.sfx = "shot1"
		self.damage = 200
		self.is_auto = true
		self.spr = images.metal
		self.max_ammo = math.huge
		
		self.cooldown = 0
		self.jetpack_force = 400
		self.recoil_force = 0
	end
	function self.unlootable.DebugGun:on_shoot(user)
		game.players[1].life = game.players[1].life + 1
	end
end

local guns_instance = Guns:new()

----------------
-- Random Gun --
----------------

local all_guns = {}
for k, gun in pairs(guns_instance) do
	if k ~= "unlootable" then
		table.insert(all_guns, gun)
	end
end

function Guns:get_random_gun(user)
	local gun = random_sample(all_guns) or self.Machinegun
	return gun:new(user)
end


return guns_instance
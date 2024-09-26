require "scripts.util"
local Class = require "scripts.meta.class"
local Gun = require "scripts.game.gun"
local images = require "data.images"
local sounds = require "data.sounds"
local Model = require "scripts.graphics.3d.model"
local honeycomb_panel = require "data.models.honeycomb_panel"

local Guns = Class:inherit()

function Guns:init()
	self.Machinegun = Gun:inherit()

	function self.Machinegun:init(user)
		self.name = "machinegun"
		self:init_gun(user)
		
		self.sfx = "mushroom_ant_pop"
		self.damage = 1.5
		self.max_ammo = 25
		self.max_reload_timer = 1.5
		self.is_auto = true
		self.spr = images.gun_machinegun
		self.bullet_spr = images.bullet_pea
		self.bul_w = 10
		self.bul_h = 10

		self.cooldown = 0.1
		self.jetpack_force = 440
		self.screenshake = 2
	end

	-------

	self.Triple = Gun:inherit()

	function self.Triple:init(user)
		self.name = "triple"
		self:init_gun(user)

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

		self.max_reload_timer = 1
		self.natural_recharge_time = 4.0
		
		self.bullet_spr = images.bullet_red

		self.screenshake = 2
	end

	--------

	self.Burst = Gun:inherit()

	function self.Burst:init(user)
		self.name = "burst"
		self:init_gun(user)

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
		self.name = "shotgun"
		self:init_gun(user)

		self.spr = images.gun_shotgun
		self.sfx = "mushroom_ant_pop"
		self.sfx_pitch = 0.6
		self.is_auto = false

		self.damage = 1
		self.cooldown = 0.4
		self.bullet_speed = 500 --800 --def: 400
		self.bullet_number = 12

		self.max_ammo = 7
		self.max_reload_timer = 1.5

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
		self.name = "minigun"
		self:init_gun(user)
		
		self.max_ammo = 50
		self.max_reload_timer = 1.5

		self.random_angle_offset = 0.5
		self.damage = 2.5
		self.is_auto = true
		self.spr = images.gun_minigun
		self.sfx = "mushroom_ant_pop"
		self.sfx_pitch = 1.2

		self.cooldown = 0.06
		self.jetpack_force = 300

		self.bullet_spr = images.bullet_pea
		self.bul_w = 10
		self.bul_h = 10

		self.screenshake = 0.7
	end

	-----

	self.Ring = Gun:inherit()

	function self.Ring:init(user)
		self.name = "ring"
		self:init_gun(user)
		
		self.max_ammo = 8
		self.max_reload_timer = 1.3
		self.bullet_number = 24
		self.bullet_spread = pi2
		self.bullet_friction = 0.9
		self.random_angle_offset = 0

		self.random_angle_offset = 0
		self.damage = 2
		self.is_auto = true
		self.spr = images.gun_ring
		self.sfx = {"gunshot_ring_1", "gunshot_ring_2", "gunshot_ring_3"}
		self.sfx2 = "pop_ring"
		self.sfx_volume = 1
		self.sfx_pitch = 1.4
		
		self.cooldown = 0.5
		self.jetpack_force = 1000
		
		self.bullet_spr = images.bullet_ring
		self.bul_w = 10
		self.bul_h = 10

		self.screenshake = 4
	end

	-----

	self.MushroomCannon = Gun:inherit()

	function self.MushroomCannon:init(user)
		self.name = "mushroom_cannon"
		self:init_gun(user)
		
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
		self.name = "mushroom_ant_gun"
		self:init_gun(user)
		self.is_lootable = false
		
		self.sfx = "mushroom_ant_pop"
		self.damage = 1
		self.is_auto = true
		self.spr = images.empty
		self.bullet_spr = images.mushroom
		self.max_ammo = 20
		self.bullet_speed = 100
		self.random_angle_offset = 0.5
		self.harmless_time = 0.4

		self.cooldown = 0
		self.jetpack_force = 340
	end

	------
	self.unlootable.DebugGun = Gun:inherit()

	function self.unlootable.DebugGun:init(user)
		self.name = "debug_gun"
		self:init_gun(user)
		
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
		if user.heal then
			user:heal(1)
		end
	end

	------
	self.unlootable.DebugGunManual = Gun:inherit()

	function self.unlootable.DebugGunManual:init(user)
		self.name = "debug_gun_manual"
		self:init_gun(user)
		
		self.sfx = "shot1"
		self.damage = 40
		self.is_auto = false
		self.spr = images.honey_blob
		self.max_ammo = math.huge
		
		self.cooldown = 0
		self.jetpack_force = 400
		self.recoil_force = 0
	end
	function self.unlootable.DebugGunManual:on_shoot(user)
		user:heal(1)
	end

	-------

	self.unlootable.W2BossGun = Gun:inherit()

	function self.unlootable.W2BossGun:init(user)
		self.name = "w2_boss_gun"
		self:init_gun(user)
		
		self.sfx = "mushroom_ant_pop"
		self.damage = 1
		self.max_ammo = math.huge
		self.max_reload_timer = 1.5
		self.is_auto = true
		self.spr = images.gun_machinegun
		self.bullet_spr = images.bullet_blue
		self.bul_w = 10
		self.bul_h = 10

		self.bullet_speed = 125-- 200
		self.cooldown = 0.4
		-- self.screenshake = 2
	end

	-------

	self.unlootable.W2BossTurretGun = Gun:inherit()

	function self.unlootable.W2BossTurretGun:init(user)
		self.name = "w2_boss_turret_gun"
		self:init_gun(user)
		
		self.sfx = "mushroom_ant_pop"
		self.damage = 1
		self.max_ammo = math.huge
		self.is_auto = true
		self.spr = images.gun_machinegun
		self.bullet_spr = images.bullet_blue
		self.bul_w = 10
		self.bul_h = 10

		-- self.random_angle_offset = pi/2

		self.bullet_speed = 125-- 200
		self.cooldown = 0.4
		self.max_reload_timer = 1.5

		-- self.screenshake = 2
	end

	-----

	self.unlootable.W2boss8bullets = Gun:inherit()

	function self.unlootable.W2boss8bullets:init(user)
		self.name = "ring"
		self:init_gun(user)
		
		self.max_ammo = 8
		self.max_reload_timer = 1.3
		self.bullet_number = 8
		self.bullet_spread = pi2
		self.random_angle_offset = 0

		self.random_angle_offset = 0
		self.damage = 2
		self.is_auto = true
		self.spr = images.gun_ring
		self.sfx = {"gunshot_ring_1", "gunshot_ring_2", "gunshot_ring_3"}
		self.sfx2 = "pop_ring"
		self.sfx_volume = 1
		self.sfx_pitch = 1.4
		
		self.cooldown = 0.5
		self.jetpack_force = 1000
		self.bullet_speed = 125-- 200
		
		self.bullet_spr = images.bullet_ring
		self.bul_w = 10
		self.bul_h = 10

		self.screenshake = 4
	end

	--------

	self.unlootable.W2BossBurst = Gun:inherit()

	function self.unlootable.W2BossBurst:init(user)
		self.name = "burst"
		self:init_gun(user)

		self.spr = images.gun_burst
		self.sfx = "mushroom_ant_pop"
		self.sfx_pitch = 1.1
		self.bullet_spread = 0.1
		
		self.is_auto = false
		self.is_burst = true
		
		self.damage = 1
		self.cooldown = 0.05
		self.max_ammo = 5
		self.max_reload_timer = 0.7
		self.random_speed_offset = 0
		self.random_angle_offset = 0.005
		-- self.burst_delay = 0.05
		
		self.bullet_speed = 140

		self.screenshake = 1.5
	end

	-------

	self.unlootable.TurretGun = Gun:inherit()

	function self.unlootable.TurretGun:init(user)
		self.name = "turret_gun"
		self:init_gun(user)
		
		self.sfx = "mushroom_ant_pop"
		self.damage = 1
		self.max_ammo = 15
		self.max_reload_timer = 1.5
		self.is_auto = true
		self.spr = images.gun_machinegun
		self.bullet_spr = images.bullet_blue
		self.bul_w = 10
		self.bul_h = 10

		self.bullet_speed = 125-- 200
		self.cooldown = 0.6--0.35
		self.screenshake = 2
	end

	-------

	self.unlootable.ExplosionGun = Gun:inherit()

	function self.unlootable.ExplosionGun:init(user, radius, damage, resolution, args)
		args = args or {} 

		self.name = "explosion_gun"
		self:init_gun(user)
		
		-- self.sfx = "mushroom_ant_pop"
		self.damage = damage or 1
		self.max_ammo = math.huge
		self.cooldown = 0

		self.bullet_number = resolution or 24
		self.bullet_spread = pi2
		self.bullet_range = radius or 32
		-- self.bullet_friction = 0.9
		self.random_angle_offset = 0

		self.random_angle_offset = 0
		self.is_auto = true
		self.spr = images.boomshroom_1
		self.sfx_volume = 1
		self.sfx_pitch = 1.4
		self.play_sfx = false
		
		self.cooldown = 0.5
		self.jetpack_force = 1000
		
		self.override_enemy_damage = args.override_enemy_damage or 6
		self.bullet_spr = images.empty
		self.bul_w = 10
		self.bul_h = 10
		self.bullet_target_type = "everyone"

		self.screenshake = 4
		self.do_particles = false
		
		self.bullet_speed = 250
		self.random_speed_offset = 0
		self.cooldown = 0.6

		self.shoot_offset_x = 0

		self.is_explosion = true
		-- self.screenshake = 2
	end

	----------------

	
	self.unlootable.HoneycombFootballGun = Gun:inherit()

	function self.unlootable.HoneycombFootballGun:init(user)
		self.name = "honeycomb_football_gun"
		self:init_gun(user)
		
		self.max_ammo = 8
		self.max_reload_timer = 1.3
		self.bullet_number = 24
		self.bullet_speed = 125
		self.bullet_spread = pi2
		self.random_angle_offset = 0

		self.random_angle_offset = 0
		self.damage = 1
		self.is_auto = true
		self.spr = images.shovel_bee
		self.sfx = {"gunshot_ring_1", "gunshot_ring_2", "gunshot_ring_3"}
		self.sfx2 = "pop_ring"
		self.sfx_volume = 1
		self.sfx_pitch = 1.4
		
		self.cooldown = 0.5
		self.jetpack_force = 1000
		
		self.bullet_spr = images.empty
		self.bul_w = 10
		self.bul_h = 10

		self.screenshake = 4

		self.bullet_model = honeycomb_panel
		self.object_3d_rot_speed = {4, 6}
		self.object_3d_scale = 10
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

function Guns:get_all_guns()
	return all_guns
end

function Guns:get_current_used_gun()
	
	for _, p in pairs(game.players) do
		if p.gun then
			return p.gun.name
		end
	end
end

function Guns:get_random_gun(user)
	local gun = random_sample(all_guns) or self.Machinegun
	local inst = gun:new(user)
	
	if game:get_floor() <= 5 then
		local limit = 10
		while limit > 0 and inst.name == "ring" do
			inst = random_sample(all_guns):new(user)
			limit = limit - 1
		end
	end

	return inst
end


return guns_instance
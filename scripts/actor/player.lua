local Actor = require "scripts.actor.actor"
local Guns = require "data.guns"
local Enemies = require "data.enemies"
local AnimatedSprite = require "scripts.graphics.animated_sprite"
local images = require "data.images"
local ui = require "scripts.ui.ui"
require "scripts.util"
require "scripts.meta.constants"

local Player = Actor:inherit()

function Player:init(n, x, y, skin)
	n = n or 1
	x = x or 0
	y = y or 0
	self:init_actor(x, y, 14, 14, images.ant1)
	self.is_player = true
	self.is_being = true
	self.name = concat("player", n)
	self.player_type = "ant"

	-- Meta
	self.n = n
	self.is_enemy = false

	-- Life
	self.max_life = 4
	self.life = self.max_life
	self.temporary_life = 0
	
	-- Death
	self.is_dead = false
	
	-- Animation
	self.color_palette = skin.color_palette
	self.skin = skin
	self.spr = AnimatedSprite:new({
		idle = skin.anim_idle,
		walk_down = {skin.img_walk_down},
		airborne = {skin.img_airborne},
		wall_slide = skin.anim_wall_slide,
	}, "idle", SPRITE_ANCHOR_CENTER_BOTTOM)

	self.is_grounded = true
	self.is_walking = false
	self.squash = 1
	self.jump_squash = 1
	self.walkbounce_oy = 0
	self.walkbounce_t = 0
	self.walkbounce_squash = 0
	self.bounce_vy = 0
	self.old_bounce_vy = 0

	self.walk_timer = 0

	self.mid_x = self.x + floor(self.w / 2)
	self.mid_y = self.y + floor(self.h / 2)
	self.dir_x = 1
	self.dir_y = 0
	
	-- Speed 
	self.speed = 50 --This is acceleration not speed but I'm too lazy to change now
	self.speed_mult = 1.0

	-- Jump
	self.can_do_midair_jump = false
	self.max_jumps = 1
	self.jumps = self.max_jumps
	self.jump_speed = 450
	self.jump_speed_mult = 1.0
	self.buffer_jump_timer = 0
	self.max_buffer_jump_timer = 8
	self.coyote_time = 0
	self.default_coyote_time = 6
	self.stomp_jump_speed = 500

	-- Air time
	self.air_time = 0
	self.jump_air_time = 0.3
	self.air_jump_force = 22

	self.frames_since_land = 0

	-- Wall sliding & jumping
	self.is_walled = false
	self.wall_jump_kick_speed = 300
	self.wall_slide_speed = 30
	self.is_wall_sliding = false
	self.wall_slide_particle_timer = 0

	self.wall_jump_margin = 8
	self.wall_collision_box = { --Move this to a seperate class if needed
		x = self.x,
		y = self.y,
		w = self.w + self.wall_jump_margin*2,
		h = self.h,
	}
	Collision:add(self.wall_collision_box)

	-- Visuals
	self.color = ({COL_RED, COL_GREEN, COL_DARK_RED, COL_YELLOW})[self.n]
	self.color = self.color or COL_RED

	-- Invicibility
	self.is_invincible = false
	self.invincible_time = 0
	self.max_invincible_time = 3
	self.iframe_blink_freq = 0.1
	self.iframe_blink_timer = 0

	-- Shooting & guns (keep it or ditch for family friendliness?)	
	self.is_shooting = false
	self.shoot_dir_x = 1
	self.shoot_dir_y = 0
	self.shoot_ang = 0
	self.gun_cooldown_multiplier = 1.0
	self.max_ammo_multiplier = 1.0
	
	self:equip_gun(Guns.unlootable.Machinegun:new())
	-- self:equip_gun(Guns.unlootable.DebugGun:new())
	-- FOR DEBUGGING
	self.guns = {
		Guns.unlootable.Machinegun:new(self),
		Guns.unlootable.DebugGun:new(self),
		Guns.unlootable.DebugGunManual:new(self),
		Guns.unlootable.ExplosionGun:new(self),
		Guns.unlootable.HoneycombFootballGun:new(self),
		Guns.Triple:new(self),
		Guns.Burst:new(self),
		Guns.Shotgun:new(self),
		Guns.Minigun:new(self),
		Guns.MushroomCannon:new(self),
		Guns.Ring:new(self),
	}
	self.gun_number = 1

	self.is_dead = false

	-- UI
	self.ui_x = self.x
	self.ui_y = self.y
	self.ui_col_gradient = 0
	self.controls_oy = 0

	-- SFX
	self:add_constant_sound("sfx_wall_slide", "sliding_wall_metal")
	self:set_constant_sound_volume("sfx_wall_slide", 0)
	-- self.sfx_wall_slide:play()
	self.sfx_wall_slide_volume = 0
	self.sfx_wall_slide_max_volume = 0.1

	-- Combo / fury
	self.combo = 0
	self.max_combo = 0
	self.fury_bar = 0.0
	self.fury_threshold = 2.5
	self.def_fury_max = 5.0
	self.fury_max = self.def_fury_max
	self.fury_gun_cooldown_multiplier = 0.8
	self.fury_gun_damage_multiplier = 1.5
	self.fury_speed = 0.9
	self.fury_stomp_value = 0.8 -- How much is added to the fury bar when stomping an enemy
	self.fury_bullet_damage_value_multiplier = 0.18  -- Percentage of the bullet damage that is added to the fury bar when hitting an enemy 
	self.has_energy_drink = false

	-- Upgrades
	self.upgrades = {}

	-- Effects
	self.effects = {}
	self.poison_cloud = nil
	self.poison_timer = 0.0
	self.poison_damage_time = 0.6

	-- Exiting 
	self.is_touching_exit_sign = false

	self.debug_god_mode = false

	-- Debug 
	self.dt = 1
end

function Player:update(dt)
	self.dt = dt
	
	self:update_upgrades(dt)
	self:update_effects(dt)
	self:move(dt)
	self:do_wall_sliding(dt)
	self:update_jumping(dt)
	self:do_gravity(dt) -- FIXME: ouch, this is already called in update_actor so there is x2 gravity here
	self:update_actor(dt)
	self:do_aiming(dt)
	self.mid_x = self.x + floor(self.w/2)
	self.mid_y = self.y + floor(self.h/2)
	self.is_walking = self.is_grounded and abs(self.vx) > 50
	self:do_invincibility(dt)
	self:animate_walk(dt)
	self:update_color(dt)
	self:update_sprite(dt)
	self:do_particles(dt)
	self:update_poison(dt)
	self:leave_game_if_possible(dt)

	if self.life <= 0 and not self.is_killed then
		self:kill()
	end
	
	if self.is_grounded then
		self.frames_since_land = self.frames_since_land + 1
	else
		self.frames_since_land = 0
	end

	-- self:update_fury(dt)

	self.gun:update(dt)
	self:shoot(dt, false)
	self:update_gun_pos(dt)

	self.ui_x = lerp(self.ui_x, floor(self.mid_x), 0.2)
	self.ui_y = lerp(self.ui_y, floor(self.y), 0.2)

	-- Visuals
	self:update_visuals()
	if self:is_in_poison_cloud() then
		Particles:dust(self.mid_x + random_neighbor(7), self.mid_y + random_neighbor(7), random_sample{color(0x3e8948), color(0x265c42), color(0x193c3e)})
	end

	self.flag_has_jumped_on_current_frame = false
end

------------------------------------------
--- Life ---

function Player:set_player_n(n)
	self.n = n
end

function Player:set_life(val)
	self.life = clamp(val, 0, self.max_life)
end

function Player:heal(val)
	local overflow = self.max_life - (self.life + val)
	if overflow >= 0 then
		self.life = self.life + val
		return true
	else
		self.life = self.max_life
		return false, -overflow
	end
end

function Player:add_max_life(val)
	self.max_life = self.max_life + val
end

function Player:add_temporary_life(val)
	self.temporary_life = self.temporary_life + val
end

function Player:do_invincibility(dt)
	self.invincible_time = max(0, self.invincible_time - dt)

	self.is_invincible = false
	if self.invincible_time > 0 and game.frames_to_skip <= 0 then
		self.is_invincible = true
		self.iframe_blink_timer = (self.iframe_blink_timer + dt) % self.iframe_blink_freq
	end
end

function Player:set_invincibility(n)
	self.invincible_time = math.max(n, self.invincible_time)
end

function Player:kill()
	if self.is_dead then return end
	
	game:screenshake(10)
	game:frameskip(30)
	Input:vibrate(self.n, 0.6, 0.4)

	local ox, oy = self.spr:get_total_centered_offset_position(self.x, self.y, self.w, self.h)
	Particles:dead_player(ox, oy, self.skin.spr_dead, self.color_palette, self.dir_x)

	self:on_death()
	game:on_kill(self)
	
	self.timer_before_death = self.max_timer_before_death
	Audio:play("death")

	self.is_dead = true
	self:remove()
end

function Player:on_death()
	
end

function Player:on_removed()
	Collision:remove(self.wall_collision_box)
end

function Player:do_damage(n, source)
	if self.debug_god_mode then
		return false
	end
	if self.invincible_time > 0 then
		return false
	end
	if n <= 0 then
		return false
	end

	game:frameskip(8)
	game:screenshake(5)
	Input:vibrate(self.n, 0.3, 0.45)
	Audio:play("hurt")
	Particles:word(self.mid_x, self.mid_y, concat("-",n), COL_LIGHT_RED)
	
	if self.is_knockbackable and source then
		self.vx = self.vx + sign(self.mid_x - source.mid_x)*source.knockback
		self.vy = self.vy - 50
	end

	local old_life = self.life
	local old_temporary_life = self.temporary_life
	self:subtract_life(n)
	local permanent_life_diff = old_life - self.life
	local temporary_life_diff = old_temporary_life - self.temporary_life
	if temporary_life_diff > 0 then
		Particles:image(self.ui_x, self.ui_y - 16, temporary_life_diff, images.particle_leaf, 5, 1.5, 0.6, 0.5)
	end
	
	self:set_invincibility(self.max_invincible_time)
	self:set_fury(0)
	
	if self.life <= 0 then
		self.life = 0 
		self:kill()
	end

	self:remove_water_upgrade()

	if source then
		self.last_damage_source_name = source.name
	end
	
	return true
end

function Player:remove_water_upgrade()
	for i, upgrade in pairs(self.upgrades) do 
		if upgrade.name == "water" then
			game:revoke_upgrade(i)
			return
		end
	end
end

function Player:subtract_life(n)
	if self.temporary_life > 0 then
		self.temporary_life = self.temporary_life - n
		n = math.max(0, -self.temporary_life)
		self.temporary_life = math.max(0, self.temporary_life)
	end

	self.life = self.life - n
	self.life = math.max(0, self.life)
end


------------------------------------------
--- Physics ---

function Player:move(dt)
	-- compute movement dir
	local dir = {x=0, y=0}
	if Input:action_down(self.n, 'left') then   dir.x = dir.x - 1   end
	if Input:action_down(self.n, 'right') then   dir.x = dir.x + 1   end

	if dir.x ~= 0 then
		self.dir_x = dir.x

		-- If not shooting, update shooting direction
		if not self.is_shooting then
			-- self.shoot_dir_x = dir.x
			-- self.shoot_dir
		end
	end

	-- Apply velocity 
	self.vx = self.vx + dir.x * self.speed * self.speed_mult
	self.vy = self.vy + dir.y * self.speed * self.speed_mult
end

function Player:do_wall_sliding(dt)
	-- Check if wall sliding
	local old_is_walled = self.is_walled
	self.is_wall_sliding = false
	self.is_walled = false

	self.sfx_wall_slide_volume = lerp(self.sfx_wall_slide_volume, 0, 0.3)
	self:set_constant_sound_volume("sfx_wall_slide", self.sfx_wall_slide_volume)

	-- Update wall variables
	if self.wall_col then
		local col_normal = self.wall_col.normal
		local is_walled = (col_normal.y == 0)
		local is_falling = (self.vy > 0)
		local holding_left = Input:action_down(self.n, 'left') and col_normal.x == 1
		local holding_right = Input:action_down(self.n, 'right') and col_normal.x == -1
		
		local is_wall_sliding = is_walled and is_falling and (holding_left or holding_right) 
			and (self.wall_col.other.collision_info and self.wall_col.other.collision_info.is_slidable)
		self.is_wall_sliding = is_wall_sliding
		self.is_walled = is_walled
	end

	-- Reduce jumps if leave wall 
	if old_is_walled and not self.is_walled then
		self.jumps = math.max(0, self.jumps-1)
	end

	-- Perform wall sliding
	if self.is_wall_sliding then
		-- Orient player opposite if wall sliding
		self.dir_x = self.wall_col.normal.x
		self.shoot_dir_x = self.wall_col.normal.x
	
		-- Slow down descent
		self.gravity = 0
		self.vy = self.wall_slide_speed

		-- Particles
		self.wall_slide_particle_timer = self.wall_slide_particle_timer + 1
		if self.wall_slide_particle_timer % 1 == 0 then
			Particles:dust(self.mid_x + (self.w/2) * -self.dir_x, self.y)
		end

		-- SFX
		self.sfx_wall_slide_volume = lerp(self.sfx_wall_slide_volume, self.sfx_wall_slide_max_volume, 0.3)
		self:set_constant_sound_volume("sfx_wall_slide", self.sfx_wall_slide_volume)
	else
		self.gravity = self.default_gravity
	end
end


local removeme_n = 0
function Player:update_jumping(dt)
	-- self.debug_values[1] = concat(self.jumps, "/", self.max_jumps)
	-- Update number of jumps
	if self.is_grounded or self.is_wall_sliding then
		self.jumps = self.max_jumps
	end 

	-- This buffer is so that you still jump even if you're a few frames behind
	self.buffer_jump_timer = self.buffer_jump_timer - 1
	if Input:action_pressed(self.n, "jump") then
		removeme_n = removeme_n + 1

		self.buffer_jump_timer = self.max_buffer_jump_timer
	end

	-- Update air time (I think that is used to make you jump higher when holding jump)
	self.air_time = self.air_time + dt
	if self.is_grounded then self.air_time = 0 end
	if self.air_time < self.jump_air_time and not self.is_grounded then
		if Input:action_down(self.n, "jump") then
			self.vy = self.vy - self.air_jump_force
		end
	end

	-- Coyote time
	-- TODO FIXME scotch: if you press jump really fast, you can exploit coyote time and double jump 
	self.coyote_time = self.coyote_time - 1
	
	if self.buffer_jump_timer > 0 then
		-- Detect nearby walls using a collision box
		local wall_normal = self:get_nearby_wall()

		if self.is_grounded or self.coyote_time > 0 then 
			-- Regular jump
			self:jump(dt)
			self:on_jump()
		
		elseif wall_normal then
			-- Conditions for a wall jump ("wall kick")
			local left_jump  = (wall_normal.x == 1) and Input:action_down(self.n, "right")
			local right_jump = (wall_normal.x == -1) and Input:action_down(self.n, "left")
			
			-- Conditions for a wall jump used for climbing, while sliding ("wall climb")
			local wall_climb = self.is_wall_sliding

			if left_jump or right_jump or wall_climb then
				self:wall_jump(wall_normal)
				self:on_jump()
			end
				
		elseif not self.is_grounded and (self.jumps > 0) then 
			-- Midair jump
			self:jump(dt, 1.2)
			self.jumps = math.max(0, self.jumps - 1)
			self:on_jump()
			
			-- :smoke      (x,          y,            number, col, spw_rad, size, sizevar, layer, fill_mode)
			Particles:smoke(self.mid_x, self.y+self.h, nil,   nil, nil,     nil,  nil,     nil, "line")
		end
	end
end

function Player:on_grounded_state_change(new_state)
	-- When player has just left the grounded 
	if not new_state then
		self.jumps = math.max(0, self.jumps - 1)
	end
end

function Player:get_nearby_wall()
	-- Returns whether the player is near a wall on its side
	-- This does not count floor and ceilings
	local null_filter = function()
		return "cross"
	end
	
	local box = self.wall_collision_box
	box.x = self.x - self.wall_jump_margin
	box.y = self.y - self.wall_jump_margin
	box.w = self.w + self.wall_jump_margin*2
	box.h = self.h + self.wall_jump_margin*2
	Collision:update(box)
	
	local x,y, cols, len = Collision:move(box, box.x, box.y, null_filter)
	for _,col in pairs(cols) do
		if col.normal.y == 0 and col.other.collision_info and col.other.collision_info.type == COLLISION_TYPE_SOLID then 
			return col.normal	
		end
	end

	return false
end

function Player:jump(dt, multiplier)
	self.vy = -self.jump_speed * self.jump_speed_mult * (multiplier or 1)
	
	Particles:smoke(self.mid_x, self.y+self.h)
	-- Particles:jump_dust_kick(self.mid_x, self.y+self.h - 12, 0)
	Particles:jump_dust_kick(self.mid_x, self.y+self.h - 12, math.atan2(self.vy, self.vx) + pi/2)
	Audio:play_var("jump", 0, 1.2)
	self.jump_squash = 1/3
end

function Player:wall_jump(normal)
	self.vx = normal.x * self.wall_jump_kick_speed
	self.vy = -self.jump_speed * self.jump_speed_mult
	
	Particles:jump_dust_kick(self.mid_x, self.y+self.h - 12, math.atan2(self.vy, self.vx) + pi/2)
	Audio:play_var("jump", 0, 1.2)
	self.jump_squash = 1/3
end

function Player:on_jump()
	self.buffer_jump_timer = 0
	self.coyote_time = 0

	self.flag_has_jumped_on_current_frame = true
end

function Player:add_max_jumps(val)
	self.max_jumps = self.max_jumps + val
end

function Player:on_leaving_ground()
	if not self.flag_has_jumped_on_current_frame then
		self.coyote_time = self.default_coyote_time
	end
end

function Player:on_leaving_collision()
	self.coyote_time = self.default_coyote_time
end

function Player:on_collision(col, other)
	if col.type ~= "cross" and col.normal.y == -1 then
		-- self.jumps = self.max_jumps
	end
end

function Player:on_grounded()
	-- On land
	local s = "metalfootstep_0"..tostring(love.math.random(0,4))
	if self.grounded_col and self.grounded_col.other.name == "rubble" then
		s = "gravel_footstep_"..tostring(love.math.random(1,6))
	end
	Audio:play_var(s, 0.3, 1, {pitch=0.5, volume=0.5})

	self.jump_squash = 1.5
	self.spr:set_animation("idle")
	Particles:smoke(self.mid_x, self.y+self.h, 10, COL_WHITE, 8, 4, 2)

	self.air_time = 0
end

------------------------------------------
--- Guns ---

function Player:shoot(dt, is_burst)
	is_burst = param(is_burst, false)
	
	-- Update aiming direction
	local dx, dy = self.dir_x, self.dir_y
	local aim_horizontal = (Input:action_down(self.n, "left") or Input:action_down(self.n, "right"))
	-- Allow aiming upwards 
	if self.dir_y ~= 0 and not aim_horizontal then    dx = 0    end

	-- Update shoot dir
	self.shoot_ang = atan2(dy, dx)
	self.shoot_dir_x = cos(self.shoot_ang)
	self.shoot_dir_y = sin(self.shoot_ang)

	local btn_auto = (self.gun.is_auto and Input:action_down(self.n, "shoot"))
	local btn_manu = (not self.gun.is_auto and Input:action_pressed(self.n, "shoot"))
	if btn_auto or btn_manu or is_burst then
		self.is_shooting = true

		local ox = dx * self.gun.bul_w
		local oy = dy * self.gun.bul_h
		local success = self.gun:shoot(dt, self, self.mid_x + ox, self.y + oy, dx, dy, is_burst)

		if success then
			-- screenshake
			game:screenshake(self.gun.screenshake)
			if dx ~= 0 then
				self.vx = self.vx - self.dir_x * self.gun.recoil_force
			end
		end

		if self.is_flying then
			-- (When elevator is going down)
			if success then
				self.vx = (self.vx - dx*self.gun.jetpack_force) * self.friction_x
				self.vy = (self.vy - dy*self.gun.jetpack_force) * self.friction_x
			end
		else
			-- (Normal behaviour) If shooting downwards, then go up like a jetpack
			if Input:action_down(self.n, "down") and success then
				self.vy = self.vy - self.gun.jetpack_force
				self.vy = self.vy * self.friction_x
			end
		end
	else
		self.is_shooting = false
	end
end

function Player:get_gun_pos()
	local gunw = self.gun.spr:getWidth()
	local gunh = self.gun.spr:getHeight()
	local top_y = self.y + self.h - self.spr.h
	local hand_oy = 15

	-- x pos is player sprite width minus a bit, plus gun width 
	local w = (self.spr.w/2-5 + gunw/2)
	local hand_y = top_y + hand_oy - self.walkbounce_oy
	local x = self.mid_x 
	local y = hand_y - gunh/2 
	return x, y, self.shoot_dir_x * w, self.shoot_dir_y * gunh
end

function Player:update_gun_pos(dt, lerpval)
	-- Why do I keep overcomplicating these things
	-- TODO: move to Gun?
	-- Gun is drawn at its center
	lerpval = lerpval or 0.5

	local tar_x, tar_y, ox, oy = self:get_gun_pos()
	local ang = self.shoot_ang
	
	self.gun.ox = lerp(self.gun.ox, ox, lerpval)
	self.gun.oy = lerp(self.gun.oy, oy, lerpval)
	self.gun.x = tar_x + self.gun.ox
	self.gun.y = tar_y + self.gun.oy
	self.gun.rot = lerp_angle(self.gun.rot, ang, 0.3)
end

function Player:do_aiming(dt)
	self.dir_y = 0
	if Input:action_down(self.n, "up") then      self.dir_y = -1    end
	if Input:action_down(self.n, "down") then    self.dir_y = 1     end
end

function Player:equip_gun(gun)
	self.gun = gun
	self.gun.user = self

	self:get_gun_pos()
	self:update_gun_pos(1)
end

function Player:get_max_ammo_multiplier()
	return self.max_ammo_multiplier
end
function Player:set_max_ammo_multiplier(val)
	self.max_ammo_multiplier = val
end
function Player:multiply_max_ammo_multiplier(val)
	self.max_ammo_multiplier = self.max_ammo_multiplier * val
end

function Player:set_gun_cooldown_multiplier(val)
	self.gun_cooldown_multiplier = val
end
function Player:multiply_gun_cooldown_multiplier(val)
	self.gun_cooldown_multiplier = self.gun_cooldown_multiplier * val
end
function Player:get_gun_cooldown_multiplier()
	local value = self.gun_cooldown_multiplier
	if self.fury_active then 
		value = value * self.fury_gun_cooldown_multiplier
	end
	return value
end

function Player:get_gun_damage_multiplier()
	local value = 1.0
	if self.fury_active then 
		value = value * self.fury_gun_damage_multiplier
	end
	return value
end

function Player:next_gun()
	self.gun_number = mod_plus_1(self.gun_number + 1, #self.guns)
	self:equip_gun(self.guns[self.gun_number])
end

------------------------------------------
--- Combat ---

function Player:on_stomp(enemy)
	local spd = -self.stomp_jump_speed
	if Input:action_down(self.n, "jump") or self.buffer_jump_timer > 0 then
		spd = spd * 1.3
	end
	self.vy = spd
	self:set_invincibility(0.15) --0.1

	self.combo = self.combo + 1
	
	-- if self.combo >= 4 then
	-- 	Particles:word(self.mid_x, self.mid_y, tostring(self.combo), COL_LIGHT_BLUE)
	-- end

	self:add_fury(self.fury_stomp_value)
end

--- When an enemy bullet hits the player
function Player:on_hit_bullet(bullet, col)
	if bullet.player == self then   return   end
	if self.invincible_time > 0 then   return   end

	self:do_damage(bullet.damage, bullet)
	self.vx = self.vx + sign(bullet.vx) * bullet.knockback
	return true
end

--- When a bullet the player shot hits an enemy
function Player:on_my_bullet_hit(bullet, victim, col)
	-- Why tf would this happen
	if bullet.player ~= self then   return   end

	self:add_fury(bullet.damage * self.fury_bullet_damage_value_multiplier)
end

------------------------------------------
--- Upgrades & effects ---
------------------------------------------

function Player:apply_upgrade(upgrade, is_revive)
	is_revive = param(is_revive, false)
	
	upgrade:apply(self, is_revive)
	table.insert(self.upgrades, upgrade)
end

function Player:revoke_upgrade(upgrade_index)
	assert(self.upgrades[upgrade_index] ~= nil)

	self.upgrades[upgrade_index]:finish(self)
	table.remove(self.upgrades, upgrade_index)
end

function Player:update_upgrades(dt)
	for i, upgrade in pairs(self.upgrades) do
		upgrade:update(dt)
	end
end

function Player:apply_effect(effect, duration)
	effect:apply(self, duration)
	table.insert(self.effects, effect)
end

function Player:update_effects(dt)
	for i=1, #self.effects do 
		local effect = self.effects[i]
		effect:update(dt, self)
	end
	
	for i=#self.effects, 1, -1 do 
		local effect = self.effects[i]
		if not effect.is_active then
			table.remove(self.effects, i)
		end
	end
end


------------------------------------------
--- Misc ---

function Player:is_in_poison_cloud()
	local is_touching, col = self:is_touching_collider(function(col) return col.other.is_poisonous end)
	if col then
		self.poison_cloud = col.other
	else
		self.poison_cloud = nil
	end
	return is_touching
end

function Player:update_poison(dt)
	if self:is_in_poison_cloud() and not self.is_invincible then
		self.poison_timer = self.poison_timer + dt

		if self.poison_timer >= self.poison_damage_time then
			self:do_damage(1, self.poison_cloud)
			self.poison_timer = 0.0	
			Particles:rising_image(self.mid_x, self.mid_y, images.poison_skull, nil, nil, nil, {rising_squish_x = true})
		end
	else
		self.poison_timer = math.max(0.0, self.poison_timer - dt)	
	end
end

function Player:leave_game_if_possible(dt)
	local is_touching, exit_sign = self:is_touching_collider(function(col) return col.other.is_exit_sign end)

	self.is_touching_exit_sign = is_touching
	if is_touching then
		self.controls_oy = lerp(self.controls_oy, 0, 0.3)
		if Input:action_pressed(self.n, "leave_game") and game.game_state == GAME_STATE_WAITING then
			exit_sign.other:activate(self)
		end
	else
		self.controls_oy = lerp(self.controls_oy, 0, 0.3)
	end
end

function Player:update_fury(dt)
	local final_fury_speed = self.fury_speed
	if not self.is_grounded then
		final_fury_speed = final_fury_speed * 0.5
	end

	if game:get_enemy_count() > 0 and not game.level:is_on_cafeteria() then
		self.fury_bar = math.max(self.fury_bar - dt*final_fury_speed, 0.0)
	end
	self.fury_bar = clamp(self.fury_bar, 0.0, self.fury_max)

	local old_fury_active = self.fury_active
	self.fury_active = (self.fury_bar >= self.fury_threshold)

	-- Particles when fury is activated 
	if not old_fury_active and self.fury_active then
		-- Particles:word(self.mid_x, self.mid_y, "FURY", COL_LIGHT_YELLOW)
		-- Particles:smoke_big(self.mid_x, self.mid_y, random_sample{COL_LIGHT_YELLOW, COL_ORANGE})
	end

	if self.fury_active then
		local fury_colors = ternary(
			self.has_energy_drink, 
			{COL_MID_BLUE, COL_DARK_BLUE},
			{COL_LIGHT_YELLOW, COL_ORANGE}
		)
		-- number, col, spw_rad, size, sizevar, is_front, is_back
		Particles:smoke(self.mid_x, self.mid_y, 1, random_sample(fury_colors), 12, nil, nil, PARTICLE_LAYER_BACK)
	end
end

function Player:add_fury(val)
	self.fury_bar = self.fury_bar + val
end

function Player:set_fury(val)
	self.fury_bar = val
end
function Player:add_fury_max(val)
	self.fury_max = self.fury_max + val
end
function Player:multiply_fury_speed(val)
	self.fury_speed = self.fury_speed * val
end

-----------------------------------------------------
--- Visuals ---

function Player:update_visuals()
	self.jump_squash       = lerp(self.jump_squash,       1, 0.15)
	self.walkbounce_squash = lerp(self.walkbounce_squash, 1, 0.2)
	self.squash = self.jump_squash * self.walkbounce_squash

	self.spr:set_scale(self.squash, 1/self.squash)
end

function Player:draw()
	if self.is_removed then   return   end
	if self.is_dead then    return    end

	-- Draw gun
	self.gun:draw(1, self.dir_x)

	-- Draw self
	self:draw_player()
	gfx.setColor(COL_WHITE)

	-- print_outline(nil, nil, tostring(self.jumps), self.x + 20, self.y)
end

function Player:draw_hud()
	if self.is_removed or self.is_dead then    return    end

	local ui_x = floor(self.ui_x)
	local ui_y = floor(self.ui_y) - self.spr.h - 12

	self:draw_life_bar(ui_x, ui_y)
	self:draw_ammo_bar(ui_x, ui_y)

	if game.game_state == GAME_STATE_WAITING then
		if Input:get_number_of_users() > 1 then
			print_centered_outline(self.color_palette[1], nil, Text:text("player.abbreviation", self.n), ui_x, ui_y- 8)
		end
		self:draw_controls()
	end
end

function Player:draw_life_bar(ui_x, ui_y)
	local life = self.life
	local max_life = self.max_life
	if self.temporary_life > 0 then
		life = life + self.temporary_life
		max_life = max_life + self.temporary_life
	end
	ui:draw_icon_bar(ui_x, ui_y, self.life, self.max_life, self.temporary_life, images.heart, images.heart_empty, images.heart_temporary)
end

function Player:draw_ammo_bar(ui_x, ui_y)
	-- Please make an ui library and stop doing this shit
	local ammo_icon_w = images.ammo:getWidth()
	local slider_w = 23 * (1 + (self:get_max_ammo_multiplier() - 1)/2)
	local bar_w = slider_w + ammo_icon_w + 2

	local x = floor(ui_x) - floor(bar_w/2)
	local y = floor(ui_y) + 8
	gfx.draw(images.ammo, x, y)

	local text = self.gun.ammo
	local col_shad = COL_DARK_BLUE
	local col_fill = COL_MID_BLUE
	local val, maxval = self.gun.ammo, self.gun:get_max_ammo()
	if val <= maxval * 0.35 then
		col_fill = COL_ORANGE
		col_shad = COL_LIGHT_RED
	end

	if self.gun.is_reloading then
		text = ""
		col_fill = COL_WHITE
		col_shad = COL_LIGHTEST_GRAY
		val, maxval = self.gun.max_reload_timer - self.gun.reload_timer, self.gun.max_reload_timer
	end

	self.ui_col_gradient = self.ui_col_gradient * 0.9
	if self.ui_col_gradient >= 0.02 then
		col_fill = lerp_color(col_fill, COL_WHITE, self.ui_col_gradient)
		col_shad = lerp_color(col_fill, COL_LIGHTEST_GRAY, self.ui_col_gradient)
	end

	-- (x, y, w, h, val, max_val, col_fill, col_out, col_fill_shadow, text, text_col, font);
	local bar_x = x+ammo_icon_w+2
	ui:draw_progress_bar(bar_x, y, slider_w, ammo_icon_w, val, maxval, 
						col_fill, COL_BLACK_BLUE, col_shad, text)


	-- self:draw_fury_bar(bar_x, y+ammo_icon_w-1, slider_w, 4)
end

function Player:draw_fury_bar(x, y, w, h)
	-- Fury bar
	local fury_color =  ternary(self.has_energy_drink, COL_MID_BLUE,  COL_LIGHT_YELLOW)
	local fury_shadow = ternary(self.has_energy_drink, COL_DARK_BLUE, COL_ORANGE)
	if self.fury_active then
		local flash_color = ternary(self.has_energy_drink, COL_WHITE, COL_RED)
		fury_color = ternary(game.t % 0.2 <= 0.1, fury_color, flash_color)
	end
	
	ui:draw_progress_bar(x, y, w, h, self.fury_bar, self.fury_threshold, fury_color, COL_BLACK_BLUE, fury_shadow)
end

function Player:get_controls_tutorial_values()
	if self.is_touching_exit_sign then
		return {
			{{"leave_game"}, "input.prompts.leave_game"},
		}
	end
	return {}
end

function Player:get_controls_text_color(i)
	local color
	if Input:get_number_of_users() == 1 then
		if self.is_touching_exit_sign then
			color = COL_LIGHT_GREEN
		else
			color = LOGO_COLS[i]
		end
	else
		color = self.color_palette[1] 
	end 
	return color or COL_WHITE
end

function Player:draw_controls()
	if game.debug and not game.debug.title_junk then
		return 
	end

	local tutorials = self:get_controls_tutorial_values()

	local x = self.ui_x
	local y = self.ui_y - 45 + self.controls_oy
	-- local x = (CANVAS_WIDTH * 0.15) + (CANVAS_WIDTH * 0.9) * (self.n-1)/4
	-- local y = 140

	-- love.graphics.line(x, y, self.ui_x, self.ui_y - 30)
	for i, tuto in ipairs(tutorials) do
		y = y - 16
		local btn_x = x - 2

		local shown_duration = 0.5
		local actions = tuto[1]
		local label = Text:text(tuto[2])
		local show_in_keybaord_form = tuto[3]

		local x_of_second_button = 0
		if not show_in_keybaord_form then
			local action_index = math.floor((game.t % (shown_duration * #actions)) / shown_duration) + 1
			actions = {actions[action_index]}
		end
		for i_action = 1, #actions do
			local action = actions[i_action]

			local icon = Input:get_action_primary_icon(self.n, action)
			local w = icon:getWidth()

			btn_x = btn_x - w
			if not (show_in_keybaord_form and i_action == 4) then
				love.graphics.draw(icon, btn_x, y)
			end

			if show_in_keybaord_form then
				if i_action == 2 then
					x_of_second_button = btn_x
				elseif i_action == 4 then
					love.graphics.draw(icon, x_of_second_button, y - 16)
				end
			end
		end
		
		local text_color = self:get_controls_text_color(i)
		print_outline(text_color, COL_BLACK_BLUE, label, x, y)
	end
end

function Player:draw_player()
	self.spr:draw(self.x, self.y - self.walkbounce_oy, self.w, self.h)

	local post_x, post_y = self.spr:get_total_offset_position(self.x, self.y, self.w, self.h)
	self:post_draw(post_x, post_y)

	if game.debug_mode then
		local i = 0
		local th = get_text_height()
		for _, val in pairs(self.debug_values) do
			local txt = tostring(val)
			print_outline(nil, nil, txt, self.x - get_text_width(txt)/2 + self.w/2, self.y - i*th)
			i = i + 1
		end
	end

	if self.debug_god_mode then
		print_outline(nil, nil, "god", self.x, self.y - 16)
	end
end

function Player:post_draw(x, y)
	self:draw_effect_overlays(x, y)
end

function Player:draw_effect_overlays(x, y)
	for i, effect in pairs(self.effects) do
		effect:draw_overlay(x, y)
	end 
end

function Player:animate_walk(dt)
	-- Ridiculously overengineered bounce + squash & stretch while walking
	local old_bounce = self.walkbounce_oy

	local t_speed = 15
	local bounce_height = 5
	local squash_amount = 0.17
	
	self.walkbounce_t = self.walkbounce_t + dt * t_speed

	if self.is_walking then
		self.walkbounce_t = self.walkbounce_t % pi
	end

	if self.walkbounce_t < pi + 0.001 then
		self.is_doing_walksquash = true

		--- Compute bounce height
		local sin_a = sin(self.walkbounce_t)
		self.walkbounce_y = abs(sin_a) * bounce_height
		self.walkbounce_oy = self.walkbounce_y
		
		--- Bounce squash
		--cos is the derivative, aka rate of change ("speed") of sin
		local speed_t = math.cos(self.walkbounce_t)
		self.walkbounce_squash = speed_t*squash_amount + 1
	else
		-- If not walking and close enough to ground, reset
		self.walkbounce_squash = 1
		self.walkbounce_oy = 0
		self.walkbounce_t = pi
	end

	self.old_bounce_vy = self.bounce_vy
	self.bounce_vy = old_bounce - self.walkbounce_y
	
	-- Walk SFX
	if sign(self.old_bounce_vy) == 1 and sign(self.bounce_vy) == -1 then
		local s = "metalfootstep_0"..tostring(love.math.random(0,4))
		if self.grounded_col and self.grounded_col.other.name == "rubble" then
			s = "gravel_footstep_"..tostring(love.math.random(1,6))
		end
		Audio:play_var(s, 0.3, 1.1, {pitch=0.4, volume=0.5})
	end
end

function Player:update_color(dt)
	self.spr:set_color{1, 1, 1, 1}
	if self.poison_timer > 0.1 then
		local v = 1 - (self.poison_timer / self.poison_damage_time)
		self.spr:set_color{v, 1, v, 1}
	end

	if self.is_invincible then
		local v = 1 - (self.invincible_time / self.max_invincible_time)
		local a = 1
		if self.iframe_blink_timer < self.iframe_blink_freq/2 then
			a = 0.5
		end

		self.spr:set_color{1, v, v, a}
		if self.last_damage_source_name == "poison_cloud" then
			self.spr:set_color{v, 1, v, a}
		end
	end
end

function Player:update_sprite(dt)
	-- Outline color
	if Input:get_number_of_users() > 1 then
		self.spr:set_outline(self.color_palette[1], "round")
	else
		self.spr:set_outline(nil)
	end

	-- Flipping
	self.spr:set_flip_x(self.dir_x < 0)

	-- Set sprite 
	self.spr:set_animation("idle")
	if not self.is_grounded then
		self.spr:set_animation("airborne")
	end
	if self.is_wall_sliding then
		self.spr:set_animation("wall_slide")
	end
	if self.is_walking then
		if self.walkbounce_y < 4 then
			self.spr:set_animation("walk_down")
		else
			self.spr:set_animation("airborne")
		end
	end
end

function Player:do_particles(dt)
	local flr_y = self.y + self.h
	if self.is_walking then
		self.walk_timer = self.walk_timer + 1
		if self.walk_timer % 7 == 0 then
			Particles:dust(self.mid_x, flr_y)
		end
	end
end


return Player
require "util"
local Class = require "class"
local Bullet = require "bullet"
local sounds = require "stats.sounds"
local images = require "images"

local Gun = Class:inherit()

function Gun:init_gun(user)
	self.sprite = images.gun_machinegun
	self.x, self.y = 0, 0
	self.rot = 0

	self.user = user -- The actor using the gun

	-- Bullet
	self.bul_w = 12
	self.bul_h = 12
	
	self.bullet_speed = 400
	self.bullet_number = 1
	self.bullet_spread = 0.2
	
	-- Ammo
	self.max_ammo = 1000
	self.ammo = math.huge

	-- Cooldown
	self.cooldown = 0.3
	self.cooldown_timer = 0

	-- Burst
	self.is_burst = false
	self.burst_count = 1
	self.burst_delay = 0

	self.burst_counter = 0
	self.burst_delay_timer = 0

	-- Jetpack
	self.jetpack_force = 340

	-- Sounds
	self.sfx = sounds.shot3
	self.sfx_pitch_var = 1.15
end

function Gun:update(dt)
	self.dt = dt
	self.cooldown_timer = max(self.cooldown_timer - dt, 0)
	self.ammo = clamp(self.ammo, 0, self.max_ammo)

	-- Burst
	self.burst_delay_timer = max(0, self.burst_delay_timer - dt)

	if self.is_burst and   self.burst_counter > 0 and self.burst_delay_timer <= 0 then
		self.burst_delay_timer = self.burst_delay_timer + self.burst_delay
		self.burst_counter = self.burst_counter - 1

		-- Force shoot
		self.user:shoot(dt, true)
	end
end

function Gun:draw(flip_x, flip_y, rot)
	local ox, oy = floor(self.sprite:getWidth()/2), floor(self.sprite:getHeight()/2)
	flip_x, flip_y = bool_to_dir(flip_x), bool_to_dir(flip_y)

	gfx.draw(self.sprite, floor(self.x), floor(self.y), self.rot, flip_x, flip_y, ox, oy)
	-- love.graphics.draw(drawable,x,y,r,sx,sy,ox,oy)

	-- gfx.setColor(COL_WHITE)
	-- gfx.print(concat("dt: ", self.dt), self.x, self.y - 16*6)
	-- gfx.print(concat("burst_count: ", self.burst_count), self.x, self.y - 16*5)
	-- gfx.print(concat("burst_delay: ", self.burst_delay), self.x, self.y - 16*4)
	-- gfx.print(concat("burst_counter: ", self.burst_counter), self.x, self.y - 16*3)
	-- gfx.print(concat("burst_delay_timer: ", self.burst_delay_timer), self.x, self.y - 16*2)
end

function Gun:shoot(dt, player, x, y, vx, vy, is_burst)
	vx = vx or 0
	vy = vy or 0
	-- Normalize direction vector
	local d = dist(vx, vy)
	vx = vx/d
	vy = vy/d
	local is_first_fire = not is_burst

	-- If first fire, reset burst timer & cooldown
	if is_first_fire and self.is_burst then
		self.burst_counter = self.burst_count
	end

	-- Sanity checks
	if self.ammo < 0 then      return false     end
	-- If first shot but cooldown too big, escape
	if is_first_fire and self.cooldown_timer > 0 then    return false    end
	
	-- Now, FIRE!!
	audio:play_var(self.sfx, 0.2, 1.4)
	if is_first_fire then    self.cooldown_timer = self.cooldown    end
	self.ammo = self.ammo - self.bullet_number

	local x = floor(x)
	local y = floor(y)
	local ang = atan2(vy, vx)

	if self.bullet_number == 1 then
		-- If only fire 1 bullet 
		self:fire_bullet(dt, player, x, y, self.bul_w, self.bul_h, vx, vy)
	else
		-- If fire multiple bullets
		local step = (self.bullet_spread*2) / (self.bullet_number-1)
		for i = 0, self.bullet_number-1 do
			-- Compute fire angle
			local a = ang-self.bullet_spread + i*step
			local vx = cos(a)
			local vy = sin(a)
			self:fire_bullet(dt, player, x, y, self.bul_w, self.bul_h, vx, vy)
		end
	end

	return true
end	

function Gun:fire_bullet(dt, player, x, y, bul_w, bul_h, vx, vy)
	local spd_x = vx * self.bullet_speed 
	local spd_y = vy * self.bullet_speed 
	game:new_actor(Bullet:new(self, player, x, y, bul_w, bul_h, spd_x, spd_y))
end

return Gun
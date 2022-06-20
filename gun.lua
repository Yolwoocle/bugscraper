require "util"
local Class = require "class"
local Bullet = require "bullet"
local sounds = require "sounds"

local Gun = Class:inherit()

function Gun:init_gun()
	self.bul_w = 8
	self.bul_h = 8

	self.ammo = 1000
	self.bullet_speed = 500

	self.cooldown = 0.3
	self.cooldown_timer = 0

	self.sfx = sounds.shot3
	self.sfx_pitch_var = 1.15
end

function Gun:update(dt)
	self.cooldown_timer = max(self.cooldown_timer - dt, 0)
end

function Gun:draw()
	--
end

function Gun:shoot(dt, player, x, y, vx, vy)
	vx = vx or 0
	vy = vy or 0
	-- normalize 
	local d = dist(vx, vy)
	vx = vx/d
	vy = vy/d
	if self.ammo > 0 and self.cooldown_timer <= 0 then
		local x = floor(x)
		local y = floor(y)
		audio:play_var(self.sfx, 0.2, 1.4)
		self:fire_bullet(dt, player, x, y, self.bul_w, self.bul_h, vx, vy)
	end
end	

function Gun:fire_bullet(dt, player, x, y, bul_w, bul_h, vx, vy)
	local spd_x = vx * self.bullet_speed 
	local spd_y = vy * self.bullet_speed 
	game:new_actor(Bullet:new(self, player, x, y, bul_w, bul_h, spd_x, spd_y))
	
	self.cooldown_timer = self.cooldown
end

return Gun
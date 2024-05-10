local Class = require "scripts.meta.class"
local Actor = require "scripts.actor.actor"
local Timer = require "scripts.timer"
local images = require "data.images"

local Bullet = Actor:inherit()

function Bullet:init(gun, player, damage, x, y, w, h, vx, vy)
	local x, y = x-w/2, y-h/2
	self:init_actor(x, y, w, h, gun.bullet_spr or images.bullet)
	self.name = "bullet"
	self.gun = gun
	self.player = player
	self.is_enemy_bul = player.is_enemy
	self.is_bullet = true

	self.friction = gun.bullet_friction - random_range(0, gun.random_friction_offset)
	self.friction_x = self.friction
	self.friction_y = self.friction
	self.gravity = 0

	self.speed = 1--300
	self.dir = 0
	
	self.vx = vx or 0
	self.vy = vy or 0
	self.speed_floor = gun.speed_floor

	self.life = 5

	self.damage = damage
	self.knockback = gun.knockback or 500
	self.harmless_timer = Timer:new(gun.harmless_time or 0.0) 
	if self.harmless_timer.duration > 0 then
		self.harmless_timer:start()
	end

	self.bounce_immunity_timer = 0.0
	self.bounce_immunity_duration = 0.1

	self.is_affected_by_bounds = false
end

function Bullet:update(dt)
	self:update_actor(dt)

	self.harmless_timer:update(dt)
	self.spr:set_rotation(atan2(self.vy, self.vx))

	self.life = self.life - dt
	if self.life < 0 then
		self:remove()
	end

	local v_sq = distsqr(self.vx, self.vy)
	if v_sq <= self.speed_floor then
		self:kill()
	end 

	self.bounce_immunity_timer = math.max(0.0, self.bounce_immunity_timer - dt)
end

function Bullet:draw()
	self:draw_actor()

	-- print_centered_outline(nil, nil, ternary(self.harmless_timer.is_active, "O", "X"), self.x, self.y)
end

function Bullet:on_collision(col)
	if self.is_removed then    return    end
	if col.other == self.player then    return   end

	if col.type ~= "cross" then
		-- Solid collision
		local s = "metalfootstep_0"..tostring(love.math.random(0,4))
		Audio:play_var(s, 0.3, 1, {pitch=0.7, volume=0.5})
		self:kill()
	end
		
	if self.harmless_timer.is_active then return end
	if col.other.on_hit_bullet and col.other.is_enemy ~= self.is_enemy_bul then
		local damaged = col.other:on_hit_bullet(self, col)
		if damaged and self.player and self.player.is_player then
			self.player:on_my_bullet_hit(self, col.other, col)
		end

		if col.other.destroy_bullet_on_impact then
			local s = "metalfootstep_0"..tostring(love.math.random(0,4))
			Audio:play_var(s, 0.3, 1, {pitch=0.7, volume=0.5})
			self:kill()
		end

		if col.other.is_bouncy_to_bullets and self.bounce_immunity_timer <= 0 then
			local bounce_x = (self.mid_x - col.other.mid_x)
			local bounce_y = (self.mid_y - col.other.mid_y)
			local normal_x, normal_y = normalise_vect(bounce_x, bounce_y)

			local new_vel_x, new_vel_y = bounce_vector(self.vx, self.vy, normal_x, normal_y)
			local spd_slow = 1
			-- self.friction_x = spd_slow
			-- self.friction_y = spd_slow
			self.vx = new_vel_x * spd_slow
			self.vy = new_vel_y * spd_slow

			self.bounce_immunity_timer = self.bounce_immunity_duration
		end
	end
	
	self:after_collision(col)
end

function Bullet:kill()
	Particles:smoke(self.x + self.w/2, self.y + self.h/2)
	self:remove()
end

function Bullet:after_collision(col)
	local other = col.other
	--[[
	if other.type == "tile" then
		game.map:set_tile(other.ix, other.iy, 0)
	end
	--]]
end

return Bullet
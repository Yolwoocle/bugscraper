local Class = require "scripts.meta.class"
local Actor = require "scripts.actor.actor"
local Timer = require "scripts.timer"
local images = require "data.images"

local Bullet = Actor:inherit()

function Bullet:init(gun, player, damage, x, y, w, h, vx, vy, args)
	gun = gun or {}
	args = args or {}

	local x, y = x-w/2, y-h/2
	self:init_actor(x, y, w, h, gun.bullet_spr or images.bullet)
	self.name = "bullet"
	self.gun = gun
	self.player = player
	self.is_bullet = true

	--target_type: what kind of enemy the bullet can target: "player", "enemy", "everyone"
	self.target_type = args.target_type or ternary(player.is_enemy, "player", "enemy") 

	self.friction = (gun.bullet_friction or 1.0) - random_range(0, (gun.random_friction_offset or 0))
	self.friction_x = self.friction
	self.friction_y = self.friction
	self.gravity = 0

	self.speed = 1--300
	self.dir = 0
	
	self.vx = vx or 0
	self.vy = vy or 0
	self.speed_floor = (gun.speed_floor or 3) -- min speed before it despawns

	self.start_x = x
	self.start_y = y
	self.life = args.life or 5
	self.range = args.range or math.huge

	self.do_particles = param(args.do_particles, true)
	self.play_sfx = param(args.play_sfx, true)

	self.damage = damage
	self.override_enemy_damage = args.override_enemy_damage -- Damage value that overrides the `damage` 
	self.knockback = gun.knockback or 500
	self.harmless_timer = Timer:new(gun.harmless_time or 0.0) 
	if self.harmless_timer.duration > 0 then
		self.harmless_timer:start()
	end

	self.bounce_immunity_timer = 0.0
	self.bounce_immunity_duration = 0.1

	self.is_affected_by_bounds = false
	self.is_explosion = param(args.is_explosion, false)

	local old_filter = self.collision_filter
	self.collision_filter = function(item, other)
		if other.is_bullet then
			return false
		end
		return old_filter(item, other)
	end
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
	if distsqr(self.start_x, self.start_y, self.x, self.y) > self.range * self.range then
		self:kill()
	end 

	self.bounce_immunity_timer = math.max(0.0, self.bounce_immunity_timer - dt)
end

function Bullet:draw()
	self:draw_actor()

	-- print_centered_outline(nil, nil, ternary(self.harmless_timer.is_active, "O", "X"), self.x, self.y)
end

function Bullet:is_actor_my_enemy(actor)
	if not actor.is_actor then
		return false
	end
	if self.is_explosion and actor.is_immune_to_explosions then
		return false
	end

	if self.target_type == "player" then
		return not actor.is_enemy
	elseif self.target_type == "enemy" then
		return actor.is_enemy
	elseif self.target_type == "everyone" then
		return true
	end
end

function Bullet:on_collision(col)
	if self.is_removed then             return   end
	if col.other == self.player then    return   end

	if col.type ~= "cross" then
		-- Solid collision
		local s = "metalfootstep_0"..tostring(love.math.random(0,4))
		if self.play_sfx then
			Audio:play_var(s, 0.3, 1, {pitch=0.7, volume=0.5})
		end
		self:kill()
	end
		
	if self.harmless_timer.is_active then return end
	if col.other.on_hit_bullet and self:is_actor_my_enemy(col.other) then
		local damaged = col.other:on_hit_bullet(self, col)
		if damaged and self.player and self.player.is_player then
			self.player:on_my_bullet_hit(self, col.other, col)
		end

		if col.other.destroy_bullet_on_impact then
			local s = "metalfootstep_0"..tostring(love.math.random(0,4))
			if self.play_sfx then
				Audio:play_var(s, 0.3, 1, {pitch=0.7, volume=0.5})
			end
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

			local ang = math.atan2(new_vel_y, new_vel_x)
			if self.do_particles then
				Particles:bullet_vanish(self.mid_x, self.y, ang + pi/2)
			end
			if self.play_sfx then
				Audio:play_var("bullet_bounce_"..random_sample{"1","2"}, 0.2, 1.2)
			end
			-- Audio:play_var("bullet_bounce", 0.2, 1.5)
		end
	end
	
	self:after_collision(col)
end

function Bullet:kill()
	-- Audio:play_var("bullet_bounce", 0.2, 1.2)
	if self.do_particles then
		Particles:smoke(self.x + self.w/2, self.y + self.h/2, 4)
		Particles:bullet_vanish(self.x + self.w/2, self.y + self.h/2, self.spr.rot - pi/2)
	end
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
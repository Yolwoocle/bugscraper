local Class = require "class"
local Actor = require "actor"
local images = require "images"

local Bullet = Actor:inherit()

function Bullet:init(gun, player, x, y, w, h, vx, vy)
	local x, y = x-w/2, y-h/2
	self:init_actor(x, y, w, h, images.bullet)
	self.gun = gun
	self.player = player
	self.is_enemy = player.is_enemy
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

	self.damage = 2
	self.knockback = 500
end

function Bullet:update(dt)
	self:update_actor(dt)

	self.rot = atan2(self.vy, self.vx)

	self.life = self.life - dt
	if self.life < 0 then
		self:remove()
	end

	local v_sq = distsqr(self.vx, self.vy)
	if v_sq <= self.speed_floor then
		self:kill()
	end 
end

function Bullet:draw()
	self:draw_actor()
	--gfx.draw(self.sprite, self.x, self.y)
end

function Bullet:on_collision(col)
	if col.other == self.player then    return   end
	
	if not self.is_removed and col.other.is_solid then
		self:kill()
	end
	
	if col.other.on_hit_bullet and col.other.is_enemy ~= self.is_enemy then
		col.other:on_hit_bullet(self, col)
		self:kill()
	end
	
	self:after_collision(col)
end

function Bullet:kill()
	particles:smoke(self.x + self.w/2, self.y + self.h/2)
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
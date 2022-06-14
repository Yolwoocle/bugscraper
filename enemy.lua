require "util"
local Class = require "class"
local Actor = require "actor"
local images = require "images"

local Enemy = Actor:inherit()

function Enemy:init_enemy(x,y)
	self:init_actor(x, y, 32, 32, images.duck)
	self.life = 10
	self.color = COL_BLUE
end

function Enemy:update_enemy(dt)
	self:update_actor(dt)
	if self.life <= 0 then
		self:remove()
	end
end
function Enemy:update(dt)
	self:update_enemy(dt)
end

function Enemy:draw()
	self:draw_actor()

	gfx.draw(images.heart, self.x-7 -2+16, self.y-16)
	print_outline(COL_WHITE, COL_DARK_BLUE, self.life, self.x+16, self.y-16-2)
end

function Enemy:on_collision(col)
	if col.other.is_solid and col.normal.y == 0 then
		self.vx = -self.vx
	end
end

function Enemy:on_hit_bullet(bullet, col)
	self:damage(bullet.damage)
end

function Enemy:damage(n)
	self.life = self.life - n
	if self.life <= 0 then
		self:kill()
	end
end

function Enemy:kill()
	self:remove()
end

return Enemy
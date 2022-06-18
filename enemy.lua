require "util"
local Class = require "class"
local Actor = require "actor"
local images = require "images"

local Enemy = Actor:inherit()

function Enemy:init_enemy(x,y, img, w,h)
	w,h = w or 12, h or 12
	self:init_actor(x, y, w, h, img or images.duck)
	self.is_enemy = true
	self.is_flying = false

	self.life = 10
	self.color = COL_BLUE
	self.speed = 20

	self.damage = 2
	self.knockback = 1200
end

function Enemy:update_enemy(dt)
	self:update_actor(dt)
	self:follow_nearest_player(dt)
	if self.life <= 0 then
		self:remove()
	end
end
function Enemy:update(dt)
	self:update_enemy(dt)
end

function Enemy:get_nearest_player()
	local shortest_dist = math.huge
	local nearest_player 
	for _, ply in pairs(game.players) do
		local dist = distsqr(self.x, self.y, ply.x, ply.y)
		if dist < shortest_dist then
			shortest_dist = dist
			nearest_player = ply
		end
	end
	return nearest_player
end

function Enemy:follow_nearest_player(dt)
	-- Find closest player
	local nearest_player = self:get_nearest_player()
	if not nearest_player then    return    end
	
	self.speed_x = self.speed_x or self.speed
	self.speed_y = self.speed_y or self.speed

	self.vx = self.vx + sign0(nearest_player.x - self.x) * self.speed_x
	self.vy = self.vy + sign0(nearest_player.y - self.y) * self.speed_y
end

function Enemy:draw()
	self:draw_actor()

	--gfx.draw(images.heart, self.x-7 -2+16, self.y-16)
	--print_outline(COL_WHITE, COL_DARK_BLUE, self.life, self.x+16, self.y-16-2)
end

function Enemy:on_collision(col)
	if col.other.is_solid and col.normal.y == 0 then
		self.vx = -self.vx
	end
end

function Enemy:on_hit_bullet(bullet, col)
	self:do_damage(bullet.damage)
end

function Enemy:do_damage(n)
	self.life = self.life - n
	if self.life <= 0 then
		self:kill()
	end
end

function Enemy:kill()
	self:remove()
end

function Enemy:on_hit_bullet(bul, col)
	self:do_damage(bul.damage)
	
	local ang = atan2(bul.vy, bul.vx)
	self.vx = self.vx + cos(ang) * bul.knockback
	self.vy = self.vy + sin(ang) * bul.knockback
end

return Enemy
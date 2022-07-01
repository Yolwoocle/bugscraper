require "util"
local Class = require "class"
local Actor = require "actor"
local images = require "images"

local Enemy = Actor:inherit()

function Enemy:init_enemy(x,y, img, w,h)
	w,h = w or 12, h or 12
	self:init_actor(x, y, w, h, img or images.duck)
	self.name = "enemy"
	self.is_being = true -- "Being" means players, enemies, etc, but not bullets, etc
	self.is_enemy = true
	self.is_flying = false
	self.is_active = true
	self.follow_player = true

	self.harmless_frames = 0

	self.life = 10
	self.color = COL_BLUE
	self.speed = 20
	self.speed_x = self.speed
	self.speed_y = 0

	self.is_stompable = true

	self.damage = 1
	self.knockback = 1200
end

function Enemy:update_enemy(dt)
	-- if not self.is_active then    return    end
	self:update_actor(dt)
	self:follow_nearest_player(dt)
	self.harmless_frames = max(self.harmless_frames - dt, 0)

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
	if not self.follow_player then    return    end

	-- Find closest player
	local nearest_player = self:get_nearest_player()
	if not nearest_player then    return    end
	
	self.speed_x = self.speed_x or self.speed
	if self.is_flying then    self.speed_y = self.speed_y or self.speed 
	else                      self.speed_y = self.speed_y or 0    end 

	self.vx = self.vx + sign0(nearest_player.x - self.x) * self.speed_x
	self.vy = self.vy + sign0(nearest_player.y - self.y) * self.speed_y
end

function Enemy:draw_enemy()
	self:draw_actor(self.vx < 0)

	if game.debug_mode then
		gfx.draw(images.heart, self.x-7 -2+16, self.y-16)
		print_outline(COL_WHITE, COL_DARK_BLUE, self.life, self.x+16, self.y-16-2)
	end
end

function Enemy:draw()
	self:draw_enemy()
end

function Enemy:on_collision(col, other)
	if self.name == "grasshopper" then print("grasshopper on_coll")  end
	-- If hit wall, reverse x vel (why is this here?????)
	if col.other.is_solid and col.normal.y == 0 then
		self.vx = -self.vx
	end

	-- Player
	if col.other.is_player then
		local player = col.other
		
		-- Begin stomped
		local epsilon = 0.01
		if player.vy > epsilon and self.is_stompable then
			if self.name == "grasshopper" then print("grasshopper stomp")  end
			player.vy = 0
			player:on_stomp(self)
			self:kill()
		
		else
			-- Damage player
			if self.harmless_frames <= 0 then	
				if self.name == "grasshopper" then print("grasshopper damage")  end
				player:do_damage(self.damage, self)
			end
		end

	end
	
	-- Being collider push force
	if col.other.is_being then
		self:do_knockback(10, col.other)
		col.other:do_knockback(10, self)
	end

	self:after_collision(col, col.other)
end

function Enemy:after_collision(col, other)  end

function Enemy:do_damage(n)
	self.life = self.life - n
	if self.life <= 0 then
		self:kill()
	end
end

function Enemy:kill()
	if self.is_removed then print(concat(self.name, "(", self, ") was killed while destroyed")) end

	self:on_death()
	game:on_kill(self)
	self:remove()
	particles:smoke(self.mid_x, self.mid_y)
end

function Enemy:on_death()
	
end

function Enemy:on_hit_bullet(bul, col)
	self:do_damage(bul.damage)
	
	local ang = atan2(bul.vy, bul.vx)
	self.vx = self.vx + cos(ang) * bul.knockback
	self.vy = self.vy + sin(ang) * bul.knockback
end

return Enemy
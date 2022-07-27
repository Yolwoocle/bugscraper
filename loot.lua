local Class = require "class"
local Actor = require "actor"
local images = require "data.images"
local Guns = require "data.guns"
local sounds = require "data.sounds"

local Loot = Actor:inherit()

function Loot:init_loot(spr, x, y, w, h, val, vx, vy)
	local x, y = x-w/2, y-h/2
	self:init_actor(x, y, w, h, spr)
	self.is_loot = true

	self.speed = 300
	self.life = 30
	
	self.friction_x = 1
	self.vx = vx or 0
	self.vy = vy or 0

	self.move_dir_x = 1

	self.speed = 10
	self.speed_min = 100
	self.speed_max = 200

	self.jump_speed_min = 100
	self.jump_speed_max = 250

	self.value = val

	self.target_player = nil
	self.min_attract_dist = math.huge
	self.is_attracted = true

	self.ghost_time = random_range(0.4, 0.8)
	self.ghost_timer = self.ghost_time

	local actual_x, actual_y, cols, len = collision:check(self, self.x, self.y)
	local is_coll = false
	for _,c in pairs(cols) do
		if c.is_solid then
			is_coll = true
		end
	end
	if is_coll then
		self:set_pos(CANVAS_WIDTH/2, CANVAS_HEIGHT/2)
	end
end

function Loot:update(dt)
	self:update_actor(dt)

	self.life = self.life - dt
	self.ghost_timer = self.ghost_timer - dt
	if self.target_player then
		self:attract_to_player(dt)
	else
		self:find_close_player(dt)
	end

	if self.life < 0 then
		self:remove()
	end
end

function Loot:draw()
	self:draw_actor()
	--gfx.draw(self.spr, self.x, self.y)
end

function Loot:find_close_player(dt)
	-- Be attracted to players

	local near_ply
	local min_dist = math.huge
	for _, p in pairs(game.players) do
		local d = dist(self.mid_x, self.mid_y, p.mid_x, p.mid_y) 
		if d < min_dist then
			min_dist = d
			near_ply = p
		end
	end

	if not near_ply then    return false, "No nearest player"    end

	if min_dist < self.min_attract_dist then
		self.target_player = near_ply
		self.vx = self.vx * 0.1
		self.vy = self.vy * 0.1
		self:set_flying(true)
	end

	return true
end

function Loot:attract_to_player(dt)
	if not self.is_attracted then    return   end
	
	local diff_x = (self.target_player.mid_x - self.mid_x)
	local diff_y = (self.target_player.mid_y - self.mid_y)
	diff_x, diff_y = normalize_vect(diff_x, diff_y)

	self.vx = self.vx + diff_x * self.speed
	self.vy = self.vy + diff_y * self.speed
end

function Loot:on_collision(col, other)
	if col.other == self.player then    return   end
	
	if not self.is_removed and col.other.is_player and self.ghost_timer <= 0 then
		self:on_collect(other)
	end

	if other.is_solid then
		if col.normal.y == 0 then
			self.move_dir_x = col.normal.x
		end
	end
end

function Loot:on_grounded()
	-- self.vy = -random_range(self.jump_speed_min, self.jump_speed_max)
end

function Loot:on_collect(player)
end

--- [[[[[[[[[[[]]]]]]]]]]] ---

Loot.Ammo = Loot:inherit()

function Loot.Ammo:init(x, y, val, vx, vy)
	self:init_loot(images.loot_ammo, x, y, 2, 2, val, vx, vy)
	self.loot_type = "ammo"
	self.value = val
end

function Loot.Ammo:on_collect(player)
	particles:smoke(self.mid_x, self.mid_y, nil, COL_LIGHT_BLUE)
	audio:play(sounds.item_collect)
	
	local success, overflow = player.gun:add_ammo(self.value)
	if not success then
		--TODO
	end
	self:remove()
	
	-- if success then
	-- 	self:remove()
	-- else
	-- 	self.quantity = overflow
	-- end
end

--- [[[[[[[]]]]]]] ---

Loot.Life = Loot:inherit()

function Loot.Life:init(x, y, val, vx, vy)
	self:init_loot(images.loot_life, x, y, 2, 2, val, vx, vy)
	self.loot_type = "life"
	self.value = val
end

function Loot.Life:on_collect(player)
	local success, overflow = player:heal(self.value)
	particles:smoke(self.mid_x, self.mid_y, nil, COL_LIGHT_RED)
	audio:play(sounds.item_collect)

	if not success then
		--TODO
	end
	self:remove()
	
	-- if success then
	-- 	self:remove()
	-- else
	-- 	self.quantity = overflow
	-- end
end

-- [[[[[[[[[[]]]]]]]]]]

Loot.Gun = Loot:inherit()

function Loot.Gun:init(x, y, val, vx, vy)
	local gun = Guns:get_random_gun()
	self.gun = gun
	
	self:init_loot(gun.spr, x, y, 2, 2, val, vx, vy)
	self.min_attract_dist = 16
	
	self.friction_x = self.default_friction
	
	self.loot_type = "gun"
end

function Loot.Gun:on_collect(player)
	player:equip_gun(self.gun)
	
	particles:smoke(self.mid_x, self.mid_y, nil, COL_LIGHT_BROWN)
	audio:play(sounds.item_collect)
	
	self:remove()
end

return Loot
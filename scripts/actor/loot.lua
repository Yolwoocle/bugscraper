require "scripts.util"

local Class = require "scripts.meta.class"
local Actor = require "scripts.actor.actor"
local images = require "data.images"
local Guns = require "data.guns"

local sounds = require "data.sounds"
local utf8 = require "utf8"

local Loot = Actor:inherit()

function Loot:init_loot(spr, x, y, w, h, val, vx, vy)
	local x, y = x-w/2, y-h/2
	self:init_actor(x, y, w, h, spr)
	self.is_loot = true

	self.vx = vx or 0
	self.vy = vy or 0

	self.value = val

	-- Verify if the loot is spawned through the wall
	local actual_x, actual_y, cols, len = Collision:check(self, self.x, self.y, self.collision_filter)
	local is_coll = false
	for _,c in pairs(cols) do
		if c.type ~= "cross" then
			is_coll = true
		end
	end
	if is_coll then
		self:set_pos(CANVAS_WIDTH/2, CANVAS_HEIGHT/2)
	end

	self:reset()
end

function Loot:reset()
	self:reset_loot()
end
function Loot:reset_loot()
	self.max_life = 10
	self.life = self.max_life

	self.max_blink_timer = 0.1
	self.blink_timer = self.max_blink_timer
	self.blink_is_shown = true

	self.is_collectable = false
	self.uncollectable_timer = 0.7
	self.destroy_on_collect = false
	
	self.friction_x = 1

	self.move_dir_x = 1

	self.speed = 0
	self.accel = 300
	self.speed_min = 100
	self.speed_max = 200

	self.jump_speed_min = 100
	self.jump_speed_max = 250

	self.target_player = nil
	self.min_attract_dist = math.huge
	self.is_attracted = true

	self.ghost_time = random_range(0.4, 0.8)
	self.ghost_timer = self.ghost_time
end

function Loot:update_loot(dt)
	self:update_actor(dt)

	-- uncollectable timer 
	self.uncollectable_timer = math.max(self.uncollectable_timer - dt, 0)
	self.is_collectable = self.uncollectable_timer <= 0

	self.life = self.life - dt
	self.ghost_timer = self.ghost_timer - dt
	if self.is_collectable then
		if self.target_player then
			self:attract_to_player(dt)
		else
			self:assign_attract_player(dt)
		end
	end

	-- blink timer 
	if self.life < self.max_life * 0.5 then
		self.blink_timer = self.blink_timer - dt
		
		if self.blink_timer < 0 then
			local val = self.max_blink_timer
			if self.life < self.max_life * 0.25 then
				val = self.max_blink_timer * .5
			end
			self.blink_timer = val
			self.blink_is_shown = not self.blink_is_shown
		end
	end
	
	self.spr:set_color(ternary(self.blink_is_shown, COL_WHITE, {1,1,1, 0.2}))

	-- if outside bounds
	-- if self.x <= 0 or self.x > CANVAS_WIDTH or self.y <= 0 or self.y > CANVAS_HEIGHT then
	-- 	self:set_pos(CANVAS_WIDTH/2, CANVAS_HEIGHT/2)
	-- end

	if self.life < 0 then
		Particles:smoke(self.mid_x, self.mid_y - 8)
		self:remove()
	end
end
function Loot:update(dt)
	self:update_loot(dt)
end

function Loot:draw()
	self:draw_actor()
	--gfx.draw(self.spr, self.x, self.y)
end

--- Used in find_close_player to find the player that the loot should be attracted to. 
--- Returns the score assigned to the given player. For example, if the 
--- loot should be attracted to the closest player, this value should be the distance 
--- to the player). The lower the score, the better that candidate is.
--- @return function score_func The score function assigned to that player.
function Loot:get_player_score_function()
	return function(player)
		return distsqr(self.mid_x, self.mid_y, player.mid_x, player.mid_y) 
	end
end

--- Return a table containing the player with the lowest score as defined in the score_function ((player) -> number)
function Loot:get_attract_candidates(score_function)
	local best_candidates = {}
	local min_score = math.huge
	for _, player in pairs(game.players) do
		local score = score_function(player)
		local d = distsqr(self.mid_x, self.mid_y, player.mid_x, player.mid_y)
		if score <= min_score and d <= sqr(self.min_attract_dist) then
			if score < min_score then
				min_score = score
				best_candidates = {}
			end
			table.insert(best_candidates, player)
		end
	end
	return best_candidates
end

function Loot:assign_attract_player(dt)
	local best_candidates = self:get_attract_candidates(self:get_player_score_function())

	if #best_candidates == 0 then
		return false, "No best player"
	end

	local winner = best_candidates[1]
	if #best_candidates > 1 then
		-- If more than one candidate, then take the closest player
		local distance_candidates = self:get_attract_candidates(function(player)
			return dist(self.mid_x, self.mid_y, player.mid_x, player.mid_y)
		end)

		if #distance_candidates == 0 then
			return false, "No nearest player (somehow, this should never happen???)"
		end
		winner = distance_candidates[1]
	end

	self.target_player = winner
	-- self.vx = self.vx * 0.1
	-- self.vy = self.vy * 0.1
	self:set_flying(true)

	return true, ""
end

function Loot:attract_to_player(dt)
	if not self.is_attracted then    return   end
	
	local diff_x = (self.target_player.mid_x - self.mid_x)
	local diff_y = (self.target_player.mid_y - self.mid_y)
	diff_x, diff_y = normalize_vect(diff_x, diff_y)

	self.speed = self.speed + self.accel*dt
	self.vx = diff_x * self.speed
	self.vy = diff_y * self.speed
end

function Loot:on_collision(col, other)
	-- if col.other == self.player then    return   end
	if not self.is_collectable or self.is_removed then
		return
	end

	if col.other.is_player and self.ghost_timer <= 0 then
		self:on_collect(other)
	end

	if col.type ~= "cross" and col.normal.y == 0 then
		self.move_dir_x = col.normal.x
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
	Particles:smoke(self.mid_x, self.mid_y, nil, COL_LIGHT_BLUE)
	Audio:play("item_collect")
	
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

----------------------------------

Loot.Life = Loot:inherit()

function Loot.Life:init(x, y, val, vx, vy)
	self:init_loot(images.loot_life, x, y, 2, 2, val, vx, vy)
	self.loot_type = "life"
	self.value = val
end

function Loot.Life:get_player_score_function()
	return function(player)
		return player.life
	end
end

function Loot.Life:on_collect(player)
	local success, overflow = player:heal(self.value)
	Particles:smoke(self.mid_x, self.mid_y, nil, COL_LIGHT_RED)
	Audio:play("item_collect")

	Particles:word(self.mid_x, self.mid_y, concat("+",self.value), COL_LIGHT_RED)

	if not success then
		--TODO
	end
	self:remove()
end

----------------------------------

Loot.Gun = Loot:inherit()

function Loot.Gun:init(x, y, val, vx, vy)
	local gun = Guns:get_random_gun()
	self.gun = gun
	
	self:init_loot(gun.spr, x, y, 2, 2, val, vx, vy)
	
	self.max_life = 15
	self.life = self.max_life
end

function Loot.Gun:reset()
	self:reset_loot()
	
	self.max_life = 15
	self.life = self.max_life

	self.vx = 0
	self.vy = 0

	self.min_attract_dist = 16
	self.uncollectable_timer = 1.0
	
	self.friction_x = self.default_friction
	
	self.loot_type = "gun"
	self.t = 0

	self.sprite_ox = 0
	self.sprite_oy = 0
end

function Loot.Gun:on_collect(player)
	local old_gun = player.gun
	player:equip_gun(self.gun)
	
	Particles:smoke(self.mid_x, self.mid_y, 10, COL_LIGHT_BROWN)
	Audio:play("item_collect")

	local old_life = self.life
	Particles:word(self.mid_x, self.mid_y, string.upper(self.gun.display_name or self.gun.name), COL_LIGHT_YELLOW)
	self:reset()
	
	local new_loot = Loot.Gun:new(self.x, self.y, self.value, 0, 0)
	new_loot.life = old_life
	new_loot.gun = old_gun
	new_loot:set_image(old_gun.spr)
	game:new_actor(new_loot)

	-- self.uncollectable_timer = 1.0
	-- self:remove()

	self:remove()
end

function Loot.Gun:update(dt)
	self:update_loot(dt)

	self.t = self.t + dt

	self.spr:update_offset(nil, -6 - sin(self.t * 4) * 4)
	self.spr:set_rotation(sin(self.t * 4 + 0.4) * 0.1)

	if not self.blink_is_shown then
		self.spr:set_color{1, 1, 1, 0.2}
	end
end

-- function Loot.Gun:draw(fx, fy, custom_draw)
-- end

return Loot
local Class = require "scripts.meta.class"
local Sprite = require "scripts.graphics.sprite"
local Rect = require "scripts.math.rect"
local CollisionInfo = require "scripts.physics.collision_info"

local Actor = Class:inherit()
local creation_index = 0

function Actor:init_actor(x, y, w, h, spr, args)
	if not args then   args = {}   end
	if args.add_collision == nil then   args.add_collision = true   end

	self.creation_index = creation_index
	creation_index = creation_index + 1

	self.is_actor = true
	self.is_active = true
	self.x = x or 0
	self.y = y or 0
	self.z = 0
	self.w = w or 32
	self.h = h or 32

	self.mid_x = 0
	self.mid_y = 0
	self:update_mid_position()

	self.sx = 1
	self.sy = 1

	self.dx = 0
	self.dy = 0

	self.vx = 0
	self.vy = 0

	self.default_gravity = 20
	self.gravity = self.default_gravity
	self.gravity_cap = 400
	self.gravity_mult = 1
	
	self.default_friction = 0.8
	self.friction_x = self.default_friction -- !!!!! This assumes that the game is running at 60FPS
	self.friction_y = 1 -- By default we don't apply friction to the Y axis for gravity

	self.speed_cap = 10000

	self.is_grounded = false
	self.is_walled = false

	self.is_knockbackable = true

	self.collisions = {}
	self.wall_col = nil

	self.is_removed = false
	self:add_collision()
	
	-- Visuals
	self.spr = Sprite:new()
	self.draw_shadow = true
	if spr then
		self:set_image(spr)
	end

	self.outline_color = nil

	self.anim_frame_len = 0.2
	self.anim_t = random_range(0, self.anim_frame_len)
	self.anim_frames = nil
	self.anim_cur_frame = 1
	self:update_sprite_position()
	
	-- Rider
	self.rider = nil
	self.vehicle = nil
	self.rider_ox = 0
	self.rider_oy = 0

	-- Whether the actor should be teleported within bounds
	self.is_affected_by_bounds = true
	self.affected_by_walls = true

	self.collision_filter = function(item, other)
		-- By default, do not react to collisions
		local type = "cross"

		if not self.collision_info.enabled then
			return false
		end

		if other.is_active ~= nil and not other.is_active then 
			return false
		end

		if other.collision_info then
			local collision_info = other.collision_info
			if not collision_info.enabled then
				return false
			elseif collision_info.type == COLLISION_TYPE_SOLID then
				if not self.affected_by_walls then
					type = "cross"
				else
					type = "slide"
				end
			elseif collision_info.type == COLLISION_TYPE_SEMISOLID then
				type = ternary((self.y + self.h <= other.y) and (self.vy >= 0), "slide", "cross")
			end
		end

		return type
	end

	-- If an actor spawns other enemies, it should put them into this table
	self.spawned_actors = {}

	self.constant_sounds = {}

	self.debug_values = {}
end

function Actor:set_active(val)
	self.is_active = val
end

function Actor:get_rect(expand_value)
	local expand_value = expand_value or 0
	return Rect:new(self.x, self.y, self.x+self.w, self.y+self.h):expand(expand_value)
	-- :segment_intersection(self.segment)
end

function Actor:set_image(image)
	self.spr:set_image(image)
end

function Actor:update_sprite_position()
	-- Sprite
	-- local spr_w2 = floor(self.spr.image:getWidth() / 2)
	-- local spr_h2 = floor(self.spr.image:getHeight() / 2)

	-- local ox = math.floor(spr_w2)-- - self.spr_centering_ox)
	-- local oy = math.floor(spr_h2)-- - self.spr_centering_oy)
	-- self.spr:update_offset(ox, oy)
end

function Actor:set_dimensions(w, h)
	self.w = w or self.w
	self.h = h or self.h
	Collision:update(self, self.x, self.y, self.w, self.h)
end

function Actor:center_actor()
	self.x = self.x - self.w/2
	self.y = self.y - self.h/2
end

function Actor:clamp_to_bounds(rect)
	local x = clamp(self.x, rect.ax, rect.bx-self.w)
	local y = clamp(self.y, rect.ay, rect.by-self.h)
	
	if self.name == "button_small" then
		-- print_debug("y", round(self.y), y, "rect", rect.ay, rect.by-self.h, " | ", random_neighbor(1))
	end
	self:set_pos(x, y)
end

function Actor:update_mid_position()
	self.mid_x = self.x + self.w/2
	self.mid_y = self.y + self.h/2
end

function Actor:update(dt)
	error("update not implemented")
end

function Actor:add_collision()
	self.collision_info = CollisionInfo:new {
        type = COLLISION_TYPE_NONSOLID,
        is_slidable = true,
    }
	Collision:add(self, self.x, self.y, self.w, self.h)
end

function Actor:do_gravity(dt)
	self.vy = self.vy + self.gravity * self.gravity_mult
	if self.gravity * self.gravity_mult > 0 then
		self.vy = min(self.vy, self.gravity_cap)
	end
end

function Actor:update_actor(dt)
	if self.is_removed then   return   end
	self:do_gravity(dt)

	-- apply friction
	self.vx = self.vx * self.friction_x
	self.vy = self.vy * self.friction_y
	
	-- apply position
	local goal_x = self.x + self.vx * dt
	local goal_y = self.y + self.vy * dt

	self.collisions = {}
	local actual_x, actual_y, cols, len = Collision:move(self, goal_x, goal_y, self.collision_filter)
	self.x = actual_x
	self.y = actual_y
	
	-- react to collisions
	local old_grounded = self.is_grounded
	self.is_grounded = false
	self.wall_col = nil
	for _,col in pairs(cols) do
		self:on_collision(col, col.other)
		self:react_to_collision(col)
		table.insert(self.collisions, col)
	end
	if old_grounded ~= self.is_grounded then
		self:on_grounded_state_change(self.is_grounded)
	end

	-- Grounding events
	if not old_grounded and self.is_grounded then
		self:on_grounded()
	end
	if old_grounded and not self.is_grounded then
		self:on_leaving_ground()
	end

	-- Cap velocity
	local cap = self.speed_cap
	self.vx = clamp(self.vx, -cap, cap)
	self.vy = clamp(self.vy, -cap, cap)

	self:update_mid_position()

	-- animation
	if self.anim_frames ~= nil then
		self.anim_t = self.anim_t + dt
		if self.anim_t >= self.anim_frame_len then
			self.anim_t = self.anim_t - self.anim_frame_len
			self.anim_cur_frame = mod_plus_1((self.anim_cur_frame + 1), #self.anim_frames)
		end
		self.spr:set_image(self.anim_frames[self.anim_cur_frame])
	end

	self:update_sprite_position()

	-- Rider
	if self.rider and self.rider.is_removed then
		self.rider = nil
	end
	if self.rider then
        self.rider:move_to(self.x + self.rider_ox, self.y - self.rider.h + self.rider_oy)
		self.rider.vx = 0
		self.rider.vy = 0
    end
end

function Actor:draw()
	error("draw not implemented")
end

function Actor:draw_actor()
	if self.is_removed then   return   end

	if self.spr then
		self.spr:draw(self.x, self.y, self.w, self.h)
	end

	if game.debug_mode then
		local i = 0
		local th = get_text_height()
		for _, val in pairs(self.debug_values) do
			print_outline(nil, nil, tostring(val), self.x, self.y - i*th)
			i = i + 1
		end		 
	end
end

function Actor:react_to_collision(col)
	-- wall col
	if col.type ~= "cross" then
		-- save wall collision
		self.wall_col = col
		
		-- cancel velocity
		if col.normal.x ~= 0 then   self.vx = 0   end
		if col.normal.y ~= 0 then   self.vy = 0   end
		
		-- is grounded
		if col.normal.y == -1 then
			self.is_grounded = true
			self.grounded_col = col
		end
	end
end

function Actor:on_grounded_state_change(new_state)
end

function Actor:is_touching_collider(condition)
	for i, col in pairs(self.collisions) do
		if condition(col) then
			return true, col
		end
	end
	return false, nil
end

function Actor:set_flying(bool)
	if bool then
		self.is_flying = true
		self.friction_x = 1
		self.friction_y = 1
		self.gravity = 0
	else
		self.is_flying = false
		self.friction_x = self.default_friction
		self.friction_y = 1
		self.gravity = self.default_gravity
		
	end
end

function Actor:apply_force(q, force_x, force_y)
	force_x, force_y = normalize_vect(force_x, force_y)
	self.vx = self.vx + force_x * q
	self.vy = self.vy + force_y * q
end

function Actor:apply_force_from(q, source, ox, oy)
	ox, oy = ox or 0, oy or 0
	--if not source then    return    end
	local knockback_x, knockback_y = normalize_vect(source.x-self.x + ox, source.y-self.y + oy)
	self:apply_force(q, -knockback_x, -knockback_y)
end

function Actor:do_knockback(q, force_x, force_y)
	if not self.is_knockbackable then    return    end
	self:apply_force(q, force_x, force_y)
end

function Actor:do_knockback_from(q, source, ox, oy)
	if not self.is_knockbackable then    return    end
	self:apply_force_from(q, source, ox, oy)
end

-- When the enemy is buffered for the next wave of enemies
function Actor:on_buffered()
end

function Actor:on_collision(col, other)
	-- Implement on_collision
end

function Actor:on_grounded()
	-- 
end

function Actor:on_leaving_ground()

end

function Actor:on_removed()
end

function Actor:remove()
	-- This doesn't immediately remove the Actor, but queues its removal
	if not self.is_removed then
		self.is_removed = true

		if self.rider then
			self.rider:remove_vehicle()
		end
		if self.vehicle then
			self.vehicle:remove_rider()
		end
	end
end

function Actor:final_remove()
	Collision:remove(self)
	self:stop_constant_sounds()
	self:on_removed()
end

function Actor:move_to(goal_x, goal_y)
	local actual_x, actual_y, cols, len = Collision:move(self, goal_x, goal_y)
	self.x = actual_x
	self.y = actual_y
end

function Actor:set_pos(x, y)
	self.x = x or self.x
	self.y = y or self.y 

	Collision:update(self, self.x, self.y)
end

function Actor:set_rider(actor)
	self.rider = nil
	self.rider = actor
	actor.vehicle = self 
end

function Actor:remove_vehicle()
	self.vehicle = nil
end

function Actor:remove_rider()
	self.rider = nil
end

function Actor:add_constant_sound(name, sound_name, play, volume, pitch, params)
	play = param(play, true)

	local sound = Audio:get_sound(sound_name)
	if not sound then
		return
	end

	local new_sound = sound:clone(volume, pitch, params)
	self.constant_sounds[name] = new_sound
	if play then
		new_sound:play()
	end
end

function Actor:get_constant_sound(name)
	return self.constant_sounds[name]
end

function Actor:set_constant_sound_volume(name, volume)
	local sound = self:get_constant_sound(name)
	if not sound then return end

	sound:set_volume(volume)
	-- sound
end

function Actor:remove_constant_sound(name)
	self.constant_sounds[name] = nil
end

function Actor:pause_constant_sound(name)
	local sound = self:get_constant_sound(name)
	if not sound then return end
	sound:pause()
end

function Actor:resume_constant_sound(name)
	local sound = self:get_constant_sound(name)
	if not sound then return end
	sound:resume()
end

function Actor:stop_constant_sound(name)
	local sound = self:get_constant_sound(name)
	if not sound then return end
	sound:stop()
end

function Actor:play_constant_sound(name)
	local sound = self:get_constant_sound(name)
	if not sound then return end
	sound:play()
end

function Actor:seek_constant_sound(name, time)
	local sound = self:get_constant_sound(name)
	if not sound then return end
	sound:seek(time)
end


function Actor:pause_constant_sounds()
	for sound_name, sound in pairs(self.constant_sounds) do
		self:pause_constant_sound(sound_name)
	end
end

function Actor:resume_constant_sounds()
	for sound_name, sound in pairs(self.constant_sounds) do
		self:resume_constant_sound(sound_name)
	end
end

function Actor:stop_constant_sounds()
	for sound_name, sound in pairs(self.constant_sounds) do
		self:stop_constant_sound(sound_name)
	end
end

return Actor
local Class = require "class"
local Actor = require "actor"
local Guns = require "stats.guns"
local Bullet = require "bullet"
local images = require "images"
local sounds = require "stats.sounds"
local ui = require "ui"
require "util"
require "constants"

local Player = Actor:inherit()

function Player:init(n, x, y, spr, controls)
	n = n or 1
	x = x or 0
	y = y or 0
	spr = spr or images.ant1
	self:init_actor(x, y, 14, 14, spr)
	self.is_player = true
	self.is_being = true
	
	-- Life
	self.max_life = 4
	self.life = self.max_life
	
	-- Meta
	self.n = n
	self.is_enemy = false
	self.controls = controls
	self:init_last_input_state()
	
	-- Animation
	self.spr_idle = images.ant1
	self.spr_jump = images.ant2
	self.spr = self.spr_idle
	self.is_walking = false
	self.squash = 1
	self.jump_squash = 1
	self.walkbounce_oy = 0
	self.walkbounce_t = 0
	self.walkbounce_squash = 0
	
	self.walk_timer = 0

	self.mid_x = self.x + floor(self.w / 2)
	self.mid_y = self.y + floor(self.h / 2)
	self.dir_x = 1
	self.dir_y = 0
	
	-- Speed 
	self.speed = 50 --This is acceleration not speed but I'm too lazy to change now

	-- Jump
	self.jump_speed = 480--450
	self.buffer_jump_timer = 0
	self.coyote_time = 0
	self.default_coyote_time = 6
	self.stomp_jump_speed = 500

	-- Wall sliding & jumping
	self.is_walled = false
	self.wall_jump_kick_speed = 300
	self.wall_slide_speed = 30
	self.is_wall_sliding = false
	self.wall_slide_particle_timer = 0

	self.wall_jump_margin = 8
	self.wall_collision_box = { --Move this to a seperate class if needed
		x = self.x,
		y = self.y,
		w = self.w + self.wall_jump_margin*2,
		h = self.h,
	}
	collision:add(self.wall_collision_box)

	-- Visuals
	self.color = ({COL_RED, COL_GREEN, COL_CYAN, COL_YELLOW})[self.n]
	self.color = self.color or COL_RED

	-- Shooting & guns (keep it or ditch for family friendliness?)
	self:equip_gun(Guns.Machinegun:new())
	self.guns = {
		Guns.Machinegun:new(self),
		Guns.Triple:new(self),
		Guns.Burst:new(self),
		Guns.Shotgun:new(self),
		Guns.Minigun:new(self),
	}
	self.gun_number = 1

	self.is_shooting = false
	self.shoot_dir_x = 1
	self.shoot_dir_y = 0
	self.shoot_ang = 0

	-- Loot & drops
	self.min_loot_dist = BLOCK_WIDTH*5

	-- Cursor
	self.cu_x = 0
	self.cu_y = 0
	self.mine_timer = 0
	self.cu_target = nil

	-- Invicibility
	self.is_invincible = false
	self.iframes = 0
	self.max_iframes = 3
	self.iframe_blink_freq = 0.1
	self.iframe_blink_timer = 0

	-- Debug 
	self.dt = 1
end

function Player:update(dt)
	self.dt = dt

	-- Movement
	self:move(dt)
	self:do_wall_sliding(dt)
	self:do_jumping(dt)
	self:do_gravity(dt)
	self:update_actor(dt)
	self:do_aiming(dt)
	self.mid_x = self.x + floor(self.w/2)
	self.mid_y = self.y + floor(self.h/2)
	self.is_walking = self.is_grounded and abs(self.vx) > 50
	self:do_invincibility(dt)
	self:animate_walk(dt)
	self:update_sprite(dt)
	self:do_particles(dt)
	
	-- Gun
	if self:button_pressed("switchgun") then
		self.gun_number = mod_plus_1((self.gun_number + 1), #self.guns)
		self:equip_gun(self.guns[self.gun_number])
	end

	self.gun:update(dt)
	self:shoot(dt, false)
	self:update_gun_pos(dt)

	--self:do_snowballing()

	-- self:update_button_state() --> moved to Game

	--Visuals
	self:update_visuals()
end

function Player:draw()
	if self.is_removed then   return   end
	
	if self.is_invincible then
		local v = 1 - (self.iframes / self.max_iframes)
		local a = 1
		if self.iframe_blink_timer < self.iframe_blink_freq/2 then
			a = 0.5
		end
		gfx.setColor(1, v, v, a)
	end

	-- Draw gun
	self.gun:draw(1, self.dir_x)

	-- Draw self
	self:draw_player()

	gfx.setColor(COL_WHITE)
end

function Player:draw_hud()
	-- Life
	local ui_y = floor(self.y - self.spr:getHeight() - 6)
	ui:draw_icon_bar(self.mid_x, ui_y, self.life, self.max_life, images.heart, images.heart_empty)
	-- Ammo bar
	local bar_w = 32
	local x = floor(self.mid_x - bar_w/2)
	local y = ui_y + 8
	local ammo_w = images.ammo:getWidth()
	gfx.draw(images.ammo, x, y)
	ui:draw_progress_bar(x+ammo_w+2, y, bar_w-ammo_w-2, ammo_w, self.gun.ammo, self.gun.max_ammo, 
						COL_MID_BLUE, COL_BLACK_BLUE, COL_DARK_BLUE, self.gun.ammo)

	-- rect_color(COL_GREEN, "fill", self.mid_x, self.y-32, 1, 60)

	if game.debug_mode then
		print_outline(COL_WHITE, COL_DARK_BLUE, string.format("x,y: %d / %d",self.x,self.y), self.x+16, ui_y-8*1)
		print_outline(COL_WHITE, COL_DARK_BLUE, string.format("dir: %d / %d",self.dir_x,self.dir_y), self.x+16, ui_y-8*2)
		print_outline(COL_WHITE, COL_DARK_BLUE, string.format("shoot_dir: %d / %d",self.shoot_dir_x,self.shoot_dir_y), self.x+16, ui_y-8*3)
	end
end

function Player:draw_player()
	local fx = self.dir_x * self.sx
	local fy = 				self.sy
	
	local spr_w2 = floor(self.spr:getWidth() / 2)
	local spr_h2 = floor(self.spr:getHeight() / 2)

	local x = self.x + spr_w2 - self.spr_ox
	local y = self.y + spr_h2 - self.spr_oy - self.walkbounce_oy
	if self.spr then
		local old_col = {gfx.getColor()}

		if self.draw_shadow then
			local o = ((self.x / CANVAS_WIDTH)-.5) * 6
			love.graphics.setColor(0, 0, 0, 0.5)
			love.graphics.draw(self.spr, x+o, y+3, 0, fx, fy, spr_w2, spr_h2)
		end
		
		-- Draw
		love.graphics.setColor(old_col)
		gfx.draw(self.spr, x, y, self.rot, fx, fy, spr_w2, spr_h2)
	end
end

function Player:heal(val)
	local overflow = self.max_life - (self.life + val)
	if overflow >= 0 then
		self.life = self.life + val
		return true
	else
		self.life = self.max_life
		return false, -overflow
	end
end

function Player:move(dt)
	-- compute movement dir
	local dir = {x=0, y=0}
	if self:button_down('left') then   dir.x = dir.x - 1   end
	if self:button_down('right') then   dir.x = dir.x + 1   end

	if dir.x ~= 0 then
		self.dir_x = dir.x

		-- If not shooting, update shooting direction
		if not self.is_shooting then
			-- self.shoot_dir_x = dir.x
			-- self.shoot_dir
		end
	end

	-- Apply velocity 
	self.vx = self.vx + dir.x * self.speed
	self.vy = self.vy + dir.y * self.speed
end

function Player:do_invincibility(dt)
	self.iframes = max(0, self.iframes - dt)

	self.is_invincible = false
	if self.iframes > 0 then
		self.is_invincible = true
		self.iframe_blink_timer = (self.iframe_blink_timer + dt) % self.iframe_blink_freq
	end
end

function Player:set_invincibility(n)
	self.iframes = n
end

function Player:do_wall_sliding(dt)
	-- Check if wall sliding
	self.is_wall_sliding = false
	self.is_walled = false
	if self.wall_col then
		local col_normal = self.wall_col.normal
		local is_walled = (col_normal.y == 0)
		local is_falling = (self.vy > 0)
		local holding_left = self:button_down('left') and col_normal.x == 1
		local holding_right = self:button_down('right') and col_normal.x == -1
		
		local is_wall_sliding = is_walled and is_falling and (holding_left or holding_right)
		self.is_wall_sliding = is_wall_sliding
		self.is_walled = is_walled
	end

	
	-- Perform wall sliding
	if self.is_wall_sliding then
		-- Orient player opposite if wall sliding
		self.dir_x = self.wall_col.normal.x
		self.shoot_dir_x = self.wall_col.normal.x
	
		-- Slow down descent
		self.gravity = 0
		self.vy = self.wall_slide_speed

		-- Particles
		self.wall_slide_particle_timer = self.wall_slide_particle_timer + 1
		if self.wall_slide_particle_timer % 5 == 0 then
			particles:dust(self.mid_x + (self.w/2) * -self.dir_x, self.y)
		end
	else
		self.gravity = self.default_gravity
	end
end

function Player:do_jumping(dt)
	local do_jump = false

	-- This buffer is so that you still jump even if you're a few frames behind
	self.buffer_jump_timer = self.buffer_jump_timer - 1
	if self:button_pressed("jump") then
		self.buffer_jump_timer = 12
	end

	-- Coyote time
	--FIXME: if you press jump really fast, you can exploit coyote time and double jump 
	self.coyote_time = self.coyote_time - 1
	
	if self.buffer_jump_timer > 0 then
		-- Detect nearby walls using a collision box
		local wall_normal = self:get_nearby_wall()

		if self.is_grounded or self.coyote_time > 0 then 
			-- Regular jump
			self:jump(dt)
			self:on_jump()

		elseif wall_normal then
			-- Conditions for a wall jump ("wall kick")
			local left_jump  = (wall_normal.x == 1) and self:button_down("right")
			local right_jump = (wall_normal.x == -1) and self:button_down("left")
			
			-- Conditions for a wall jump used for climbing, while sliding ("wall climb")
			local wall_climb = self.is_wall_sliding

			if left_jump or right_jump or wall_climb then
				self:wall_jump(wall_normal)
			end
			self:on_jump()
		end
	end
end

function Player:get_nearby_wall()
	-- Returns whether the player is near a wall on its side
	-- This does not count floor and ceilings
	local null_filter = function()
		return "cross"
	end
	
	local box = self.wall_collision_box
	box.x = self.x - self.wall_jump_margin
	box.y = self.y - self.wall_jump_margin
	box.w = self.w + self.wall_jump_margin*2
	box.h = self.h + self.wall_jump_margin*2
	collision:update(box)
	
	local x,y, cols, len = collision:move(box, box.x, box.y, null_filter)
	for _,col in pairs(cols) do
		if col.other.is_solid and col.normal.y == 0 then 
			return col.normal	
		end
	end

	return false
end

function Player:jump(dt)
	self.vy = -self.jump_speed
	
	particles:smoke(self.mid_x, self.y+self.h)
	audio:play_var(sounds.jump, 0, 1.2)
	self.jump_squash = 1/4
end

function Player:wall_jump(normal)
	self.vx = normal.x * self.wall_jump_kick_speed
	self.vy = -self.jump_speed
	
	audio:play_var(sounds.jump, 0, 1.2)
	self.jump_squash = 1/4
end

function Player:on_jump()
	self.buffer_jump_timer = 0
	self.coyote_time = 0
end

function Player:on_leaving_ground()
	self.coyote_time = self.default_coyote_time
end

function Player:on_leaving_collision()
	self.coyote_time = self.default_coyote_time
end

function Player:shoot(dt, is_burst)
	if is_burst == nil then     is_burst = false    end
	-- Update aiming direction
	local dx, dy = self.dir_x, self.dir_y
	local aim_horizontal = (self:button_down("left") or self:button_down("right"))
	-- Allow aiming upwards 
	if self.dir_y ~= 0 and not aim_horizontal then    dx = 0    end

	-- Update shoot dir
	self.shoot_ang = atan2(dy, dx)
	self.shoot_dir_x = cos(self.shoot_ang)
	self.shoot_dir_y = sin(self.shoot_ang)

	local btn_auto = (self.gun.is_auto and self:button_down("shoot"))
	local btn_manu = (not self.gun.is_auto and self:button_pressed("shoot"))
	if btn_auto or btn_manu or is_burst then
		self.is_shooting = true

		local ox = dx * self.gun.bul_w
		local oy = dy * self.gun.bul_h
		local success = self.gun:shoot(dt, self, self.mid_x + ox, self.y + oy, dx, dy, is_burst)
		
		-- If shooting downwards, then go up like a jetpack
		if self:button_down("down") and success then
			self.vy = self.vy - self.gun.jetpack_force
			self.vy = self.vy * self.friction_x
		end
	else
		self.is_shooting = false
	end
end

function Player:update_gun_pos(dt)
	-- Why do I keep overcomplicating these things
	-- TODO: move to Gun?
	-- Gun is drawn at its center
	local gunw = self.gun.spr:getWidth()
	local gunh = self.gun.spr:getHeight()
	local top_y = self.y + self.h - self.spr:getHeight()
	local hand_oy = 15

	-- x pos is player sprite width minus a bit, plus gun width 
	local w = (self.spr:getWidth()/2-5 + gunw/2)
	
	local hand_y = top_y + hand_oy - self.walkbounce_oy

	local tar_x = self.mid_x + self.shoot_dir_x * w
	local tar_y = hand_y - gunh/2 + self.shoot_dir_y * gunh
	local ang = self.shoot_ang
	
	self.gun.x = lerp(self.gun.x, tar_x, 0.5)
	self.gun.y = lerp(self.gun.y, tar_y, 0.5)

--[[	local rot_offset = ang - atan2(-self.vy, -self.vx)
	local d = dist(self.vx, self.vy)
	rot_offset = rot_offset * 0.2
	if abs(d) < 0.01 then    rot_offset = 0    end
--]]
	self.gun.rot = lerp_angle(self.gun.rot, ang, 0.3)
end

function Player:button_down(btn)
	-- TODO: move this to some input.lua or something
	local keys = self.controls[btn]
	if not keys then   error(concat("Attempt to access button '",concat(btn),"'"))   end

	for i, k in pairs(keys) do
		if love.keyboard.isScancodeDown(k) then
			return true
		end
	end
	return false
end

function Player:init_last_input_state()
	self.last_input_state = {}
	for btn, _ in pairs(self.controls) do
		if btn ~= "type" then
			self.last_input_state[btn] = false
		end
	end
end

function Player:button_pressed(btn)
	-- This makes sure that the button state table assigns "true" to buttons
	-- that have been just pressed 
	local last = self.last_input_state[btn]
	local now = self:button_down(btn)
	return not last and now
end

function Player:update_button_state()
	for btn, v in pairs(self.last_input_state) do
		self.last_input_state[btn] = self:button_down(btn)
	end
end

function Player:on_collision(col, other)
	
end

function Player:on_stomp(enemy)
	self.vy = -self.stomp_jump_speed
	self:set_invincibility(0.2)
end

function Player:do_damage(n, source)
	if self.iframes > 0 then    return    end
	if n <= 0 then    return    end

	audio:play("hurt")
	self:do_knockback(source.knockback, source)--, 0, source.h/2)
	--source:do_knockback(source.knockback*0.75, self)

	self.life = self.life - n
	self.life = clamp(self.life, 0, self.max_life)

	self.iframes = self.max_iframes

	if self.life <= 0 then
		self:die()
	end
end

function Player:die()
	self.life = 0
end

function Player:on_hit_bullet(bul, col)
	if bul.player == self then   return   end

	self:do_damage(bul.damage, bul)
	self.vx = self.vx + sign(bul.vx) * bul.knockback
end

function Player:update_visuals()
	self.jump_squash       = lerp(self.jump_squash,       1, 0.2)
	self.walkbounce_squash = lerp(self.walkbounce_squash, 1, 0.2)
	self.squash = self.jump_squash * self.walkbounce_squash

	self.sx = self.squash
	self.sy = 1/self.squash
end

function Player:on_grounded()
	-- On land
	audio:play("land")
	self.jump_squash = 2
	self.spr = self.spr_idle
	particles:smoke(self.mid_x, self.y+self.h, 10, COL_WHITE, 8, 4, 2)
end

function Player:do_aiming(dt)
	self.dir_y = 0
	if self:button_down("up") then      self.dir_y = -1    end
	if self:button_down("down") then    self.dir_y = 1     end
end

function Player:do_snowballing()
	local moving = self:button_down("left") or self:button_down("right")
	if self.is_grounded and self:button_down("down") and moving then
		self.snowball_size = self.snowball_size + 0.1
	end

	if self:button_down("shoot") then
		local spd = self.snowball_speed * self.dir_x
		game:new_actor(Bullet:new(self, self.mid_x, self.mid_y, 10, 10, spd, -self.snowball_speed))
	end
end

function Player:equip_gun(gun)
	self.gun = gun
	self.gun.user = self
end

function Player:animate_walk(dt)
	-- Ridiculously overengineered bounce + squash & stretch while walking
	-- Holy shit this is so complicated
	
	local t_speed = 15
	local bounce_height = 5
	local squash_amount = 0.17
	
	self.walkbounce_t = self.walkbounce_t + dt * t_speed

	if self.is_walking then
		self.walkbounce_t = self.walkbounce_t % pi
	end

	if self.walkbounce_t < pi + 0.001 then
		self.is_doing_walksquash = true

		--- Compute bounce height
		local sin_a = sin(self.walkbounce_t)
		self.walkbounce_y = abs(sin_a) * bounce_height
		self.walkbounce_oy = self.walkbounce_y
		
		--- Bounce squash
		--cos is the derivative, aka rate of change of sin
		local speed_t = math.cos(self.walkbounce_t)
		self.walkbounce_squash = speed_t*squash_amount + 1

		--- Jump sprite
		self.spr = self.spr_idle
		if self.is_walking and self.walkbounce_y > 4 then
			self.spr = self.spr_jump
		end
	else
		-- If not walking and close enough to ground, reset
		self.walkbounce_squash = 1
		self.walkbounce_oy = 0
		self.walkbounce_t = pi
	end
end

function Player:update_sprite(dt)
	if not self.is_grounded then
		self.spr = self.spr_jump
	end
end

function Player:do_particles(dt)
	local flr_y = self.y + self.h
	if self.is_walking then
		self.walk_timer = self.walk_timer + 1
		if self.walk_timer % 10 == 0 then
			particles:dust(self.mid_x, flr_y)
		end
	end

end

return Player
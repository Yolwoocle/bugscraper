local Class = require "class"
local Actor = require "actor"
local Guns = require "guns"
local Bullet = require "bullet"
local images = require "images"
require "util"
require "constants"

local Player = Actor:inherit()

function Player:init(n, x, y, spr, controls)
	n = n or 1
	x = x or 0
	y = y or 0
	spr = spr or images.ant
	self:init_actor(x, y, 10, 10, spr)
	
	-- Life
	self.max_life = 20
	self.life = self.max_life
	
	-- Meta
	self.n = n
	self.is_enemy = false
	self.controls = controls
	self:init_last_input_state()
	
	-- Animation
	self.squash = 1

	self.mid_x = self.x + floor(self.w / 2)
	self.mid_y = self.y + floor(self.h / 2)
	self.move_dir_x = 1
	
	-- Speed 
	self.speed = 50

	-- Jump
	self.jump_speed = 450
	self.buffer_jump_timer = 0
	self.coyote_time = 0
	self.default_coyote_time = 6

	-- Wall sliding & jumping
	self.is_walled = false
	self.wall_jump_kick_speed = 300
	self.wall_slide_speed = 30
	self.is_wall_sliding = false

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
	self.gun = Guns.Machinegun:new()
	self.is_shooting = false
	self.shoot_dir_x = 1
	
	-- Cursor
	self.cu_x = 0
	self.cu_y = 0
	self.mine_timer = 0
	self.cu_target = nil

	-- Invicibility
	self.iframes = 0
	self.max_iframes = 3

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
	self.mid_x = self.x + floor(self.w/2)
	self.mid_y = self.y + floor(self.h/2)
	self.iframes = max(0, self.iframes - dt)
	
	-- Gun
	self.gun:update(dt)
	self:shoot(dt)

	--self:do_snowballing()
	self:update_button_state()

	--Visuals
	self:update_visuals()
end

function Player:draw()
	if self.iframes > 0 then    
		-- Red for invincibility
		local v = 1 - (self.iframes / self.max_iframes)
		gfx.setColor({1,v,v})   
	end
	self:draw_actor(self.move_dir_x)
	gfx.setColor(COL_WHITE)

	-- Cursor
	if self.cu_target then
		rect_color(COL_WHITE, "line", self.cu_x*BW, self.cu_y*BW, BLOCK_WIDTH, BLOCK_WIDTH)
	end
	
	-- Text
	local y = self.y-self.sprite:getHeight()-2
	gfx.draw(images.heart, self.mid_x-7 -2, y)
	print_outline(COL_WHITE, COL_DARK_BLUE, concat(self.life), self.mid_x, y-4)
	if game.debug_mode then
		print_outline(COL_WHITE, COL_DARK_BLUE, string.format("x,y: %d / %d",self.x,self.y), self.x+16, y-4)
	end
end

function Player:move(dt)
	-- compute movement dir
	local dir = {x=0, y=0}
	if self:button_down('left') then   dir.x = dir.x - 1   end
	if self:button_down('right') then   dir.x = dir.x + 1   end

	if dir.x ~= 0 then
		self.move_dir_x = dir.x

		-- If not shooting, update shooting direction
		if not self.is_shooting then
			self.shoot_dir_x = dir.x
		end
	end

	-- Apply velocity 
	self.vx = self.vx + dir.x * self.speed
	self.vy = self.vy + dir.y * self.speed
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
		self.gravity = 0
		self.vy = self.wall_slide_speed
	else
		self.gravity = self.default_gravity
	end

	-- Orient player opposite if wall sliding
	if self.is_wall_sliding then
		self.move_dir_x = self.wall_col.normal.x
		self.shoot_dir_x = self.wall_col.normal.x
	end
end

function Player:do_jumping(dt)
	local do_jump = false

	-- This buffer is so that you still jump even if you're a few frames behind
	self.buffer_jump_timer = self.buffer_jump_timer - 1
	if self:button_pressed("up") then
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
	self.squash = 1/4
end

function Player:wall_jump(normal)
	self.vx = normal.x * self.wall_jump_kick_speed
	self.vy = -self.jump_speed
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

function Player:shoot(dt)
	if self:button_down("fire") then
		self.is_shooting = true
		self.gun:shoot(dt, self, self.mid_x + self.move_dir_x*18, self.mid_y, self.move_dir_x, 0)
	else
		self.is_shooting = false
	end
end

function Player:button_down(btn)
	-- TODO: move this to some input.lua or something
	local keys = self.controls[btn]
	if not keys then   return   end

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
 
function Player:update_cursor(dt)
	local old_cu_x = self.cu_x
	local old_cu_y = self.cu_y

	local tx = floor(self.mid_x / BLOCK_WIDTH) 
	local ty = floor(self.mid_y / BLOCK_WIDTH) 
	local dx, dy = 0, 0

	-- Target up and down 
	local btn_up = self:button_down("up")
	local btn_down = self:button_down("down")
	if btn_up or btn_down then
		dx = 0
		if btn_up then    dy = -1    end
		if btn_down then  dy = 1     end
	else
		-- By default, target sideways
		dx = self.move_dir_x
	end

	-- Update target position
	self.cu_x = tx + dx
	self.cu_y = ty + dy

	-- Update target tile
	local target_tile = game.map:get_tile(self.cu_x, self.cu_y)
	self.cu_target = nil
	if target_tile and target_tile.is_solid then
		self.cu_target = target_tile
	end
	
	-- If changed cursor pos, reset cursor
	if (old_cu_x ~= self.cu_x) or (old_cu_y ~= self.cu_y) then
		self.mine_timer = 0
	end
end

function Player:mine(dt)
	if not self.cu_target then   return    end
	
	if self:button_down("fire") then
		self.mine_timer = self.mine_timer + dt

		if self.mine_timer > self.cu_target.mine_time then
			local drop = self.cu_target.drop
			game.map:set_tile(self.cu_x, self.cu_y, 0)
			--game.inventory:add_item(drop)
		end
	else
		self.mine_timer = 0
	end
end

function Player:on_collision(col, other)
	if other.is_enemy then 
		self:do_damage(other.damage, other)
	end
end

function Player:do_damage(n, source)
	if self.iframes > 0 then    return    end

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
	print("oh no i died")
end

function Player:on_hit_bullet(bul, col)
	if bul.player == self then   return   end

	self:do_damage(bul.damage)
	self.vx = self.vx + sign(bul.vx) * bul.knockback
end

function Player:update_visuals()
	self.squash = lerp(self.squash, 1, 0.3)

	self.sx = self.squash
	self.sy = 1/self.squash
end

function Player:on_grounded()
	self.squash = 2
end

function Player:do_snowballing()
	local moving = self:button_down("left") or self:button_down("right")
	if self.is_grounded and self:button_down("down") and moving then
		self.snowball_size = self.snowball_size + 0.1
	end

	if self:button_down("fire") then
		local spd = self.snowball_speed * self.move_dir_x
		game:new_actor(Bullet:new(self, self.mid_x, self.mid_y, 10, 10, spd, -self.snowball_speed))
	end
end

return Player
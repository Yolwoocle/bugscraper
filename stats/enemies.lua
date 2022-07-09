require "util"
local Class = require "class"
local Enemy = require "enemy"
local Loot = require "loot"

local images = require "images"

local Enemies = Class:inherit()

function Enemies:init()
	self.Bug = Enemy:inherit()
	function self.Bug:init(x, y)
		self:init_enemy(x,y)
		self.name = "bug"
		self.life = 10
		self.color = rgb(0,50,190)
	end

	----------------

	self.Button = Enemy:inherit()
	function self.Button:init(x, y)
		-- We can reuse this for other stuff
		self:init_enemy(x,y, images.big_red_button, 34, 40)
		self.name = "button"
		self.follow_player = false

		self.max_life = 9999
		self.life = self.max_life
		
		self.knockback = 0
		self.is_solid = false
		self.is_stompable = true
		self.is_pushable = false
		self.is_knockbackable = false
		self.loot = {}

		self.damage = 0
	end

	function self.Button:update(dt)
		self:update_enemy(dt)
	end
	
	function self.Button:draw()
		self:draw_enemy()

		gfx.print(concat(self.x, " ", self.y), 128, 128)
	end

	function self.Button:on_stomped(damager)
		game:screenshake(10)
	end

	-----------------
	
	self.ButtonGlass = Enemy:inherit()

	function self.ButtonGlass:init(x, y)
		-- We can reuse this for other stuff
		self:init_enemy(x,y, images.big_red_button_crack3, 58, 45)
		self.name = "button_glass"
		self.follow_player = false

		self.max_life = 200
		self.life = self.max_life
		self.activ_thresh = 40
		self.break_range = self.life - self.activ_thresh 
		self.knockback = 0

		self.is_solid = true
		self.is_stompable = false
		self.is_pushable = false
		self.is_knockbackable = false

		self.damage = 0
		self.screenshake = 0
		self.max_screenshake = 4

		self.break_state = 3
		self.loot = {}
	end

	function self.ButtonGlass:update(dt)
		self:update_enemy(dt)

		if self.life < self.activ_thresh then
			--self.spr = images.big_red_button
		end
	end
	
	function self.ButtonGlass:on_damage(n, old_life)
		local k = 4
		local old_state = self.break_state
		local part = self.max_life / k
		local new_state = floor(self.life / part)
		
		if old_state ~= new_state then
			self.break_state = new_state
			local spr = images["big_red_button_crack"..tostring(self.break_state)]
			spr = spr or images.big_red_button_crack3

			self.spr = spr
			game:screenshake(10)
			particles:image(self.mid_x, self.mid_y, 100, images.ptc_glass_shard, self.h)
		end

		if game.screenshake_q < 5 then
			game:screenshake(2)
		end 
	end

	local Button = self.Button
	function self.ButtonGlass:on_death()
		game:screenshake(20)
		particles:image(self.mid_x, self.mid_y, 300, images.ptc_glass_shard, self.h)

		local b = create_actor_centered(Button, CANVAS_WIDTH/2, game.world_generator.box_rby)
		game:new_actor(b)
	end
	

	-----------------
	
	self.Fly = Enemy:inherit()
	
	function self.Fly:init(x, y)
		self:init_enemy(x,y, images.fly)
		self.name = "fly"
		self.is_flying = true
		self.life = 10
		--self.speed_y = 0--self.speed * 0.5
		
		self.speed = 10
		self.speed_x = self.speed
		self.speed_y = self.speed

		self.gravity = 0
		self.friction_y = self.friction_x
	end

	-------------

	self.Larva = Enemy:inherit()
	
	function self.Larva:init(x, y)
		self:init_enemy(x,y, images.larva1, 11, 11)
		self.name = "larva"
		self.follow_player = false

		self.friction_x = 1
		self.life = random_range(3, 7)
		self.speed = 40
		self.walk_dir_x = random_sample{-1, 1}
	end

	function self.Larva:update(dt)
		self:update_enemy(dt)
		self.vx = self.speed * self.walk_dir_x
	end

	function self.Larva:after_collision(col, other)
		if other.is_solid then
			if col.normal.y == 0 then
				self.walk_dir_x = col.normal.x
			end
		end
	end

	-------------

	self.Grasshopper = Enemy:inherit()
	
	function self.Grasshopper:init(x, y)
		self:init_enemy(x,y, images.grasshopper, 12, 12)
		self.name = "grasshopper"
		self.life = 10
		self.follow_player = false
		
		self.speed = 100
		self.vx = self.speed
		self.friction = 1
		self.friction_x = 1
		self.friction_y = 1
		self.walk_dir_x = random_sample{-1, 1}

		self.gravity = self.gravity * 0.5

		self.jump_speed = 300
	end

	function self.Grasshopper:update(dt)
		self:update_enemy(dt)
		self.vx = self.speed * self.walk_dir_x
	end

	function self.Grasshopper:draw()
		self:draw_enemy()
	end

	function self.Grasshopper:after_collision(col, other)
		if other.is_solid then
			if col.normal.y == 0 then
				self.walk_dir_x = col.normal.x
			end
		end
	end

	function self.Grasshopper:on_grounded()
		self.vy = -self.jump_speed
	end

	--------

	self.Slug = Enemy:inherit()

	function self.Slug:init(x, y) 
		self:init_enemy(x, y, images.slug, 14, 9)
		self.name = "slug"
		self.follow_player = true
	end

	
	------------------

	self.SnailShelled = Enemy:inherit()

	function self.SnailShelled:init(x, y)
		self:init_enemy(x,y, images.snail_shell, 16, 16)
		self.name = "snail_shelled"
		self.is_flying = true
		self.follow_player = false

		self.rot_speed = 3

		self.gravity = 0
		self.friction_y = self.friction_x 

		self.pong_speed = 40
		self.dir = (pi/4 + pi/2 * love.math.random(0,3)) % pi2
		self.pong_vx = cos(self.dir) * self.pong_speed
		self.pong_vy = sin(self.dir) * self.pong_speed

		self.spr_oy = floor((self.spr_h - self.h) / 2)
	end

	function self.SnailShelled:update(dt)
		self:update_enemy(dt)
		self.rot = self.rot + self.rot_speed * dt 

		self.vx = self.vx + (self.pong_vx or 0)
		self.vy = self.vy + (self.pong_vy or 0)
	end

	function self.SnailShelled:after_collision(col, other)
		-- Pong-like bounce
		if col.other.is_solid or col.other.name == "" then
			particles:smoke(col.touch.x, col.touch.y)

			if col.normal.x ~= 0 then    self.pong_vx = sign(col.normal.x) * abs(self.pong_vx)    end
			if col.normal.y ~= 0 then    self.pong_vy = sign(col.normal.y) * abs(self.pong_vy)    end
		end
	end

	function self.SnailShelled:draw()
		self:draw_enemy()
	end

	local Slug = self.Slug
	function self.SnailShelled:on_death()
		particles:image(self.mid_x, self.mid_y, 30, images.snail_shell_fragment, 13, nil, 0, 10)
		game:new_actor(Slug:new(self.x, self.y))
	end

	------- 

	self.DummyTarget = Enemy:inherit()
	
	function self.DummyTarget:init(x, y)
		self:init_enemy(x,y, images.dummy_target, 15, 26)
		self.name = "dummy_target"
		self.follow_player = false

		self.life = 20
		self.damage = 0
		self.self_knockback_mult = 0.1

		self.knockback = 0
		
		self.is_pushable = false
		self.is_knockbackable = false
		self.loot = {}
	end

	function self.DummyTarget:update(dt)
		self:update_enemy(dt)
	end
end

return Enemies:new()